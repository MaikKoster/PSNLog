param (
	[string]$Configuration = 'Debug'
)

if (Test-Path '.\build\.buildenvironment.ps1') {
    . '.\build\.buildenvironment.ps1'
} else {
    Write-Error 'Without a build environment file we are at a loss as to what to do!'
}

# Put together our full paths. Generally leave these alone
$ModulePath = Join-Path -Path $BuildRoot -ChildPath $ModuleToBuild
$ModuleFullPath = Join-Path -Path $ModulePath -ChildPath "$ModuleToBuild.psm1"
$ScratchPath = Join-Path -Path $BuildRoot -ChildPath $ScratchFolder
$ModuleManifestFullPath = Join-Path -Path $ModulePath -ChildPath "$ModuleToBuild.psd1"
$StageReleasePath = Join-Path -Path $ScratchPath -ChildPath $ModuleToBuild
$DocumentsPath = Join-Path -Path $BuildRoot -ChildPath $DocumentsFolder
$ReleaseNotesPath = Join-Path -Path $BuildRoot -ChildPath $ReleaseNotesName
$LicensePath = Join-Path -Path $BuildRoot -ChildPath $LicenseFileName


# Additional build scripts and tools are found here (note that any dot sourced functions must be scoped at the script level)
$BuildToolPath = Join-Path -Path $BuildRoot -ChildPath $BuildToolFolder

# These are required for a full build process and will be automatically installed if they aren't available
$RequiredModules = @('BuildHelpers', 'Posh-Git', 'PlatyPS', 'PSScriptAnalyzer', 'Pester', 'Coveralls')

# Used later to determine if we are in a configured state or not
$IsConfigured = $False

# Used to update our function CBH to external help reference
$ExternalHelp = @"
<#
    .EXTERNALHELP $($ModuleToBuild)-help.xml
    #>
"@

#Synopsis: Validate system requirements are met
task ValidateRequirements {
    Write-Output '      Running Powershell version 5?'
    assert ($PSVersionTable.PSVersion.Major.ToString() -eq '5') 'Powershell 5 is required for this build to function properly (you can comment this assert out if you are able to work around this requirement)'
}

#Synopsis: Load required modules if available. Otherwise try to install, then load it.
task LoadRequiredModules {
    $RequiredModules | ForEach-Object {
        if ($null -eq (get-module $_ -ListAvailable)) {
            Write-Output "      Install $($_) Module"
            $null = Install-Module $_ -Force
        }
        if (get-module $_ -ListAvailable) {
            Write-Output "      Import $($_) Module"
            Import-Module $_ -Force
        }
        else {
            throw 'How did you even get here?'
        }
    }
}

#Synopsis: Load dot sourced functions into this build session
task LoadBuildTools {
    # Dot source any build script functions we need to use
    Get-ChildItem $BuildToolPath/dotSource -Recurse -Filter "*.ps1" -File | ForEach-Object {
        Write-Output "      Dot sourcing script file: $($_.Name)"
        . $_.FullName
    }
}

# Synopsis: Import the current module manifest file for processing
task LoadModuleManifest {
    assert (Test-Path $ModuleManifestFullPath) "Unable to locate the module manifest file: $ModuleManifestFullPath"

    Write-Output '      Load the existing module manifest for this module'
    $Script:Manifest = Import-PowerShellDataFile -Path $ModuleManifestFullPath

    # Validate we have a rootmodule defined
    if(-not $Script:Manifest.RootModule) {
        $Script:Manifest.RootModule = $Manifest.ModuleToProcess
        # If we don't then name it after the module to build
        if(-not $Script:Manifest.RootModule) {
            $Script:Manifest.RootModule = "$ModuleToBuild.psm1"
        }
    }

    # Store this for later
    $Script:ReleaseModule = Join-Path $StageReleasePath $Script:Manifest.RootModule
}

# Synopsis: Create new module manifest
task CreateModuleManifest -After CreateModulePSM1 {
    Write-Output "      Create new module manifest file at '$StageReleasePath\$ModuleToBuild.psd1'"
    $Script:Manifest.ModuleVersion = $Script:Version
    $Script:Manifest.FunctionsToExport = $Script:FunctionsToExport
    $Script:Manifest.CmdletsToExport = $Script:Module.ExportedCmdlets.Keys
    $Script:Manifest.VariablesToExport = $Script:Module.ExportedVariables.Keys
    $Script:Manifest.AliasesToExport = $Script:Module.ExportedAliases.Keys
    $Script:Manifest.WorkflowsToExport = $Script:Module.ExportedWorkflows.Keys
    $Script:Manifest.DscResourcesToExport = $Script:Module.ExportedDscResources.Keys
    $Script:Manifest.FormatFilesToExport = $Script:Module.ExportedFormatFiles.Keys
    $Script:Manifest.TypeFilesToExport = $Script:Module.ExportedTypeFiles.Keys

    # Update the private data element so it will work properly with new-modulemanifest
    $tempPSData = $Script:Manifest.PrivateData.PSdata

    if ( $tempPSData.Keys -contains 'Tags') {
        $tempPSData.Tags = @($tempPSData.Tags | ForEach-Object {$_})
    }
    $NewPrivateDataString = "PrivateData = @{`r`n"
    $NewPrivateDataString += '  PSData = '
    $NewPrivateDataString += (Convert-HashToString $tempPSData)
    $NewPrivateDataString +=  "`r`n}"

    # We do this because private data never seems to give the results I want in the manifest file
    # Later we replace the whole string in the manifest with what we want.
    $Script:Manifest.PrivateData = ''

    # Remove some hash elements which cannot be passed to new-modulemanifest
    if ($Script:Manifest.Keys -contains 'TypeFilesToExport') {
        $Script:Manifest.Remove('TypeFilesToExport')
    }

    if ($Script:Manifest.Keys -contains 'WorkflowsToExport') {
        $Script:Manifest.Remove('WorkflowsToExport')
    }

    if ($Script:Manifest.Keys -contains 'FormatFilesToExport') {
        $Script:Manifest.Remove('FormatFilesToExport')
    }

    $MyManifest = $Script:Manifest
    New-ModuleManifest @MyManifest -Path $StageReleasePath\$ModuleToBuild.psd1

    # Replace the whole private data section with our own string instead
    Replace-FileString -Pattern "PrivateData = ''"  $NewPrivateDataString "$StageReleasePath\$ModuleToBuild.psd1" -Overwrite -Encoding 'UTF8'
}

# Synopsis: Load the module project
task LoadModule {
    Write-Output '      Load the project module.'
    try {
        $Script:Module = Import-Module $ModuleManifestFullPath -Force -PassThru
    } catch {
        throw "Unable to load the project module: $($ModuleManifestFullPath)"
    }
}

# Synopsis: Identify current Module Version.
# Also generate appropriate "Build-Version" if running in CI
task Version LoadModuleManifest, {
    # Module Version follows SemVer convention (http://semver.org/)
    # SPOT for Module Version is the .psd1 file
    # All changes to the Module Version are handled manually!
    # BuildNumber from CI is appended to the CI Build-Version. However has no relevance for any public release
    # This needs to be adjusted for other CI systems
    Write-Output '      Validate Version'

    $Script:Version = $Manifest.ModuleVersion
    Write-Output "      Current Version: $Version"

    if ($Env:APPVEYOR) {
        $BuildVersion = "$Version+$($Env:APPVEYOR_BUILD_NUMBER)"
        Write-Output "      Build Version: $BuildVersion"
        Update-AppveyorBuild -Version "$BuildVersion"
        Write-Output "      Update AppVeyor Build version to '$BuildVersion'"
    } else {
        # Update appveyor.yml file with current version
        $VersionRegEx = '(?<=version: )(.*)'
        $AppVeyorConfigPath = Join-Path -Path $BuildRoot -ChildPath "Appveyor.yml"

        if (Test-Path $AppVeyorConfigPath) {
            $AppVeyorConfig = Get-Content -Path $AppVeyorConfigPath -Raw
            $AppVeyorConfig = $AppVeyorConfig -replace $VersionRegEx,"$Version+{build}"
            $null = $AppVeyorConfig | Set-Content -Path $AppVeyorConfigPath -Force
            Write-Output "      Update version string in 'Appveyor.yml'"
        }
    }
}

# Synopsis: Updates the Module manifest version
# Module manifest is SPOT for version. Handle with care.
task UpdateModuleManifest Version, {
    # Update Modulemanifest
    if ($Manifest.ModuleVersion -ne $Version) {
        Write-Output "      Update the module manifest version ($($Manifest.ModuleVersion)) to $(($Version).ToString())"
        Update-Metadata -Path $ModuleManifestFullPath -PropertyName ModuleVersion -Value $Version
    }
}

# Synposis. Updates the download link in the ReadMe file
# Should only be called when a release is pushed
task UpdateReadMe Version, {
    $ReadMePath = Join-Path -Path $BuildRoot -ChildPath 'README.md'

    if (Test-Path ($ReadMePath)) {
        Write-Output "      Update ReadMe"

        $ReadMe = Get-Content -Path $ReadMePath -Raw
        # Remove several empty lines
        Write-Output "      Remove multiple empty lines"
        $EmptyLinesRegex = '(?:\r\n[\s-[\rn]]*){3,}'
        $ReadMe = $ReadMe -replace $EmptyLinesRegex, "$([Environment]::NewLine)$([Environment]::NewLine)"

        Write-Output '      Update download link'
        $LinkRegex =  "(?<=Download )(\[$ModuleToBuild.*zip\))"
        $NewDownloadLink = "[$ModuleToBuild-$Version.zip]($ModuleWebsite/releases/download/v$Version/$ModuleToBuild-$Version.zip)"
        $ReadMe = $ReadMe -replace $LinkRegex, $NewDownloadLink

        # Write back changes
        Write-Output "      Save changes to '$ReadMepath'"
        $ReadMe | Set-Content -Path $ReadMePath -Encoding UTF8 -Force

        if (Test-Path $StageReleasePath) {
            # Copy updated file to the Release folder
            Copy-Item -Path $ReadMePath -Destination $StageReleasePath -Force
            Write-Output "      Copy updated ReadMed to '$StageReleasePath'"
        }
    }
}

#Synopsis: Validate script requirements are met, load required modules, load project manifest and module, and load additional build tools.
task Configure ValidateRequirements, LoadRequiredModules, LoadBuildTools, LoadModuleManifest, LoadModule, Version, Clean, {
    # If we made it this far then we are configured!
    $Script:IsConfigured = $True
    Write-Build green '      Configured build environment'
}

# Synopsis: Remove/regenerate scratch staging directory
task Clean {
    Write-Output "      Clean up scratch/staging directory at $($ScratchPath)"
    if(Test-Path -Path $ScratchPath) {
        $null = Remove-Item "$ScratchPath\*" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    }

    $null = New-Item -ItemType Directory -Path $ScratchPath -Force
}

# Synopsis: Create base content tree in scratch staging area
task PrepareStage {
    Write-Output "      Prepare stage path at '$StageReleasePath'"
    # Create the directories
    if (-not (Test-Path -Path $StageReleasePath)){
        $null = New-Item $StageReleasePath -ItemType:Directory -Force
    }

    Copy-Item -Path $ModuleFullPath -Destination $ScratchPath
    Copy-Item -Path $ModuleManifestFullPath -Destination $ScratchPath
    Copy-Item -Path "$($ModulePath)\$($PublicFunctionSource)" -Recurse -Destination "$($ScratchPath)\$($PublicFunctionSource)"
    Copy-Item -Path "$($ModulePath)\$($PrivateFunctionSource)" -Recurse -Destination "$($ScratchPath)\$($PrivateFunctionSource)"
    if (Test-Path "$($ModulePath)\$($OtherModuleSource)") {
        Copy-Item -Path "$($ModulePath)\$($OtherModuleSource)" -Recurse -Destination "$($ScratchPath)\$($OtherModuleSource)"
    }

    if (Test-Path "$($ModulePath)\en-US") {
        Copy-Item -Path "$($ModulePath)\en-US" -Recurse -Destination $StageReleasePath
    } else {
        $null = New-Item "$ScratchPath\en-US" -ItemType:Directory -Force
    }
    Copy-Item -Path "$BuildRoot\README.md" -Destination $StageReleasePath
    Copy-Item -Path $LicensePath -Destination $StageReleasePath
}, GetPublicFunctions

# Synopsis:  Collect a list of our public methods for later module manifest updates
task GetPublicFunctions {
    Write-Output '      Parsing for public (exported) function names'
    $Exported = @()
    Get-ChildItem "$($ModulePath)\$($PublicFunctionSource)" -Recurse -Filter "*.ps1" -File | Sort-Object Name | ForEach-Object {
       $Exported += ([System.Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref]$null, [ref]$null)).FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false) | ForEach-Object {$_.Name}
    }

    $Script:FunctionsToExport = $Exported
}

# Synopsis: Assemble the module for release
task CreateModulePSM1 {
    Write-Output '      Combine module functions and data into single PSM1 file'
    $CombineFiles = ""

    # Put the License on top
    If (Test-Path($LicensePath)) {
        Write-Output '      Add License'
        $CombineFiles += (Get-Content -Path "$LicensePath" | ForEach-Object{"# $_"}) + "`r`n`r`n"
    }

    $PublicPath = Join-Path -Path $ScratchPath -ChildPath $PublicFunctionSource
    if (Test-Path -Path $PublicPath) {
        Write-Output "      Combine public source files from '$PublicPath'"
        $CombineFiles += "#region Public module functions and data `r`n`r`n"
        Get-childitem  "$PublicPath\*.ps1" | ForEach-Object {
            Write-Output "             $($_.Name)"
            $CombineFiles += (Get-Content $_ -Raw) + "`r`n`r`n"
        }
        $CombineFiles += "#endregion"
    }

    # "Other" files might not always exist
    $OtherPath = Join-Path -Path $ScratchPath -ChildPath $OtherModuleSource
    if (Test-Path -Path $OtherPath) {
        Write-Output "      Combine other source files from '$OtherPath'"
        $CombineFiles += "#region Other Module functions and data `r`n`r`n"
        Get-Childitem -Path"$OtherPath\*.ps1" | ForEach-Object {
            Write-Output "             $($_.Name)"
            $CombineFiles += (Get-content $_ -Raw) + "`r`n`r`n"
        }
        $CombineFiles += "#endregion"
    }

    $PrivatePath = Join-Path -Path $ScratchPath -ChildPath $PrivateFunctionSource
    if (Test-Path -Path $PrivatePath) {
        Write-Output "      Combine private source files from '$PrivatePath'"
        $CombineFiles += "#region Private Module functions and data`r`n`r`n"
        Get-childitem  "$PrivatePath\*.ps1" | ForEach-Object {
            Write-Output "             $($_.Name)"
            $CombineFiles += (Get-Content $_ -Raw) + "`r`n`r`n"
        }
        $CombineFiles += "#endregion"
    }

    $CombinedModulePath = Join-Path -Path $StageReleasePath -ChildPath "$ModuleToBuild.psm1"
    Write-Output "      Write changes to '$CombinedModulePath'"
    Set-Content -Path $CombinedModulePath -Value $CombineFiles -Encoding UTF8
}

# Synopsis: Warn about not empty git status if .git exists.
task GitStatus -If (Test-Path .git) {
	$status = exec { git status -s }
	if ($status) {
		Write-Warning "      Git status: $($status -join ', ')"
	}
}

# Synopsis: Replace comment based help with external help in all public functions for this project
task UpdateCBH -Before CreateModulePSM1 {
    $CBHPattern = "(?ms)(\<#.*\.SYNOPSIS.*?#>)"
    Get-ChildItem -Path "$($ScratchPath)\$($PublicFunctionSource)\*.ps1" -File | ForEach-Object {
            $FormattedOutFile = $_.FullName
            Write-Output "      Replace CBH in file: $($FormattedOutFile)"
            $UpdatedFile = (Get-Content  $FormattedOutFile -raw) -Replace $CBHPattern, $ExternalHelp
            $UpdatedFile | Out-File -FilePath $FormattedOutFile -Force -Encoding:utf8
    }
}

# Synopsis: Run PSScriptAnalyzer against the assembled module
task AnalyzeScript -After CreateModulePSM1 {
    $scriptAnalyzerParams = @{
        Path = $StageReleasePath
        Severity = @('Error', 'Warning', 'Information')
        Recurse = $true
        Verbose = $false
        #ExcludeRules = @('PSAvoidGlobalVars')
    }

    Write-Output '      Analyze Script Module using PSScriptAnalyzer'
    $saResults = Invoke-ScriptAnalyzer @scriptAnalyzerParams

    # Save Analyze Results as JSON
    $saResultPath = Join-Path -Path $ScratchPath -ChildPath "ScriptAnalyzerResults.json"
    Write-Output "      Write results to '$saResultPath'"
    $saResults | ConvertTo-Json | Set-Content $saResultPath

    #if ($saResults) {
    #    $saResults | Format-Table
    #    throw "One or more PSScriptAnalyzer errors/warnings where found."
    #}

    $saErrors = @($saResults | Where-Object {@('Information','Warning') -notcontains $_.Severity})
    if ($saErrors.Count -ne 0) {
        throw 'Script Analysis came up with some errors!'
    }

    $saWarnings = @($saResults | Where-Object {$_.Severity -eq 'Warning'})
    $saInfo =  @($saResults | Where-Object {$_.Severity -eq 'Information'})
    Write-Build  Yellow "          Script Analysis Warnings = $($saWarnings.Count)"
    Write-Output "          Script Analysis Informational = $($saInfo.Count)"
}

# Synopsis: Test the project with Pester. Publish Test and Coverage Reports
# Tests are executed against the source files to get proper Code coverage metrics.
task RunTests {
    $invokePesterParams = @{
        Script = (Join-Path -Path $BuildRoot -ChildPath 'tests')
        OutputFile =  (Join-Path -Path $ScratchPath -ChildPath 'TestResults.xml')
        OutputFormat = 'NUnitXml'
        Strict = $true
        PassThru = $true
        Verbose = $false
        EnableExit = $false
        CodeCoverage = (Get-ChildItem -Path "$ModulePath\*.ps1" -Exclude "*.Tests.*" -Recurse).FullName
    }

    # Ensure current module scope is removed.
    # Will be loaded properly by first pester test.
    Get-Module -Name $ModuleToBuild -All | Remove-Module -Force -ErrorAction Stop

    Write-Output '      Run Tests using Pester'
    $testResults = Invoke-Pester @invokePesterParams

    # Save Test Results as JSON
    $PesterResultPath = Join-Path -Path $ScratchPath -ChildPath 'PesterResults.json'
    Write-Output "      Write results to '$PesterResultPath'"
    $testresults | ConvertTo-Json -Depth 5 | Set-Content  $PesterResultPath

    # Upload Tests to AppVeyor if running in CI environment
    if ($Env:APPVEYOR) {
        $wc = New-Object 'System.Net.WebClient'
        $wc.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path(Join-Path $ScratchPath 'TestResults.xml')))

        Write-Output '      Upload Testresults to AppVeyor'
        $CurrentBranch = $Env:APPVEYOR_REPO_BRANCH

        # Upload Code Coverage to Coverall
        if (-not([string]::IsNullOrEmpty($Env:CoverallKey))) {
            Write-Output '      Upload CodeCoverage to Coverall'
            $Coverage = Format-Coverage -PesterResults $testResults -CoverallsApiToken "$Env:CoverallKey"  -BranchName $CurrentBranch -Verbose
            Publish-Coverage $Coverage -Verbose
        }
    }
}

# Synopsis: Throws an error if any tests do not pass for CI usage
task ConfirmTestsPassed -After RunTests {
    Write-Output '      Confirm Test results'
    # Fail Build after reports are created, this allows CI to publish test results before failing
    [xml] $xml = Get-Content (Join-Path -Path $ScratchPath -ChildPath 'TestResults.xml')
    $numberFails = $xml."test-results".failures
    assert($numberFails -eq 0) ('Failed "{0}" unit tests.' -f $numberFails)

    # Fail Build if Coverage is under requirement
    $json = Get-Content (Join-Path -Path $ScratchPath -ChildPath 'PesterResults.json') -Raw | ConvertFrom-Json
    $overallCoverage = [Math]::Floor(($json.CodeCoverage.NumberOfCommandsExecuted / $json.CodeCoverage.NumberOfCommandsAnalyzed) * 100)
    assert($OverallCoverage -gt $PercentCompliance) ('A Code Coverage of "{0}" does not meet the build requirement of "{1}"' -f $overallCoverage, $PercentCompliance)
}

# Synopsis: Build help files for module
task CreateHelp CreateMarkdownHelp, CreateExternalHelp, CreateUpdateableHelpCAB, {
    Write-Output '      Create help files'
}

task UpdateHelp UpdateMarkdownHelp, CreateExternalHelp, CreateUpdateableHelpCAB, {
    Write-Output '      Update help files'
}

# Synopsis: Build help files for module and ignore missing section errors
task TestCreateHelp Configure, CreateMarkdownHelp, CreateExternalHelp, CreateUpdateableHelpCAB,  {
    Write-Output '      Create help files'
}

task TestUpdateHelp Configure, UpdateMarkdownHelp, CreateExternalHelp, CreateUpdateableHelpCAB, {
    Write-Output '      Update help files'
}

# Synopsis: Build the markdown help files with PlatyPS
task UpdateMarkdownHelp {
    # Create the .md files and the generic module page md as well
    $null = Update-MarkdownHelpModule -Path $DocumentsPath -RefreshModulePage

    # Replace each missing element we need for a proper generic module page .md file
    $ModulePage = Join-Path -Path $DocumentsPath -ChildPath "$ModuleToBuild.md"
    $ModulePageFileContent = Get-Content -Raw $ModulePage
    $ModulePageFileContent = $ModulePageFileContent -replace '{{Manually Enter Description Here}}', $Manifest.Description

    # Function Description should have been updated by PlatyPS
    $ModulePageFileContent | Out-File $ModulePage -Force -Encoding:utf8

    Write-Output "      Update markdown documentation with PlatyPS at '$DocumentsPath'"
    $MissingDocumentation = Select-String -Path "$DocumentsPath\*.md" -Pattern "({{.*}})"
    if ($MissingDocumentation.Count -gt 0) {
        Write-Build Yellow ''
        Write-Build Yellow '   The documentation that got generated resulted in missing sections which should be filled out.'
        Write-Build Yellow '   Please review the following sections in your comment based help, fill out missing information and rerun this build:'
        Write-Build Yellow '   (Note: This can happen if the .EXTERNALHELP CBH is defined for a function before running this build.)'
        Write-Build Yellow ''
        Write-Build Yellow "Path of files with issues: $DocumentsPath\"
        Write-Build Yellow ''
        $MissingDocumentation | Select-Object FileName,Matches | Format-Table -auto
        Write-Build Yellow ''
        #pause

       # throw 'Missing documentation. Please review and rebuild.'
    }
}

task CreateMarkdownHelp GetPublicFunctions, {
    $OnlineModuleLocation = "$($ModuleWebsite)/$($BaseReleaseFolder)/blob/master"
    $FwLink = "$($OnlineModuleLocation)/docs/$($ModuleToBuild).md"
    $ModulePage = Join-Path -Path $DocumentsPath -ChildPath "$ModuleToBuild.md"

    # Create the .md files and the generic module page md as well
    Write-Output "      Create markdown documentation with PlatyPS at '$DocumentsPath'"
    $null = New-MarkdownHelp -Module $ModuleToBuild -OutputFolder $DocumentsPath -Force -WithModulePage -Locale 'en-US' -FwLink $FwLink -HelpVersion $Version

    Write-Output '      Update missing information in new markdown files'
    # Replace each missing element we need for a proper generic module page .md file
    $ModulePageFileContent = Get-Content -Raw $ModulePage
    $ModulePageFileContent = $ModulePageFileContent -replace '{{Manually Enter Description Here}}', $Manifest.Description
    $Script:FunctionsToExport | Foreach-Object {
        Write-Output "      Update definition for the following function: $($_)"
        $TextToReplace = "{{Manually Enter $($_) Description Here}}"
        $ReplacementText = (Get-Help -Detailed $_).Synopsis
        $ModulePageFileContent = $ModulePageFileContent -replace $TextToReplace, $ReplacementText
    }
    $ModulePageFileContent | Out-File $ModulePage -Force -Encoding:utf8

    $MissingDocumentation = Select-String -Path "$($DocumentsPath)\*.md" -Pattern "({{.*}})"
    if ($MissingDocumentation.Count -gt 0) {
        Write-Build Yellow ''
        Write-Build Yellow '   The documentation that got generated resulted in missing sections which should be filled out.'
        Write-Build Yellow '   Please review the following sections in your comment based help, fill out missing information and rerun this build:'
        Write-Build Yellow '   (Note: This can happen if the .EXTERNALHELP CBH is defined for a function before running this build.)'
        Write-Build Yellow ''
        Write-Build Yellow "Path of files with issues: $($DocumentsPath)\"
        Write-Build Yellow
        $MissingDocumentation | Select-Object FileName,Matches | Format-Table -auto
        Write-Build Yellow ''
        #pause

       # throw 'Missing documentation. Please review and rebuild.'
    }
}

# Synopsis: Build the external help files with PlatyPS
task CreateExternalHelp {
    $HelpPath = Join-Path -Path $StageReleasePath -ChildPath "en-US"

    Write-Output "      Create external help file at '$HelpPath'"
    if (-not(Test-Path -Path "$HelpPath")) {
        $null = New-Item -ItemType Directory -Path "$HelpPath" -Force
    }
    $null = New-ExternalHelp $DocumentsPath -OutputPath "$HelpPath\" -Force
}

# Synopsis: Build the help file CAB with PlatyPS
task CreateUpdateableHelpCAB CreateExternalHelp,  {
    Write-Output '      Create updateable help cab file'
    # Remove files from previous build as New-ExternalHelpCab will fail otherwise
    $HelpPath = Join-Path -Path $StageReleasePath -ChildPath "en-US"

    $null = Get-ChildItem -Path "$HelpPath\$($ModuleToBuild)_*"  | Remove-Item -Force
    $LandingPage = "$DocumentsPath\$ModuleToBuild.md"
    $null = New-ExternalHelpCab -CabFilesFolder "$HelpPath\" -LandingPagePath $LandingPage -OutputFolder "$HelpPath\"
}

# Synopsis: Push with a version tag.
# Triggers Update in ReadMe and Release Notes
task GitHubPushRelease Version, UpdateReadMe, UpdateReleaseNotes, PrepareArtifacts, GitHubPush, GetReleaseNotes, {
	$changes = exec { git status --short }
	assert (-not $changes) 'Please, commit changes'

    if (-not([string]::IsNullOrEmpty($env:GitHubKey))) {
    #if ($ENV:APPVEYOR_REPO_BRANCH -eq 'master' -and [string]::IsNullOrWhiteSpace($ENV:APPVEYOR_PULL_REQUEST_NUMBER)) {
        #Create GitHub release
        Write-Output '      Start GitHub release'
        $GitHubApiUri = ($ModuleWebsite -replace "https://github.com", "https://api.github.com/repos")
        if ($Env:APPVEYOR) {
            $CurrentBranch = $Env:APPVEYOR_REPO_BRANCH
        } else {
            $CurrentBranch = Get-GitBranch
        }

        $releaseData = @{
            tag_name         = "v$Version"
            target_commitish = "$CurrentBranch"
            name             = "v$Version"
            body             = $ReleaseNotes
            draft            = $false # adjust as necessary
        }

        if ($Version -like '*PRE*') {
            $releaseData.prerelease = $true
        } else {
            $releaseData.prerelease = $false
        }

        $auth = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($env:GitHubKey + ':x-oauth-basic'))
        $releaseParams = @{
            Uri         = "$GitHubApiUri/releases"
            Method      = 'POST'
            Headers     = @{
                Authorization = $auth
            }
            ContentType = 'application/json'
            Body        = (ConvertTo-Json -InputObject $releaseData -Compress)
        }

        Write-Output "      Create new release 'v$Version'"
        $result = Invoke-RestMethod @releaseParams

        $ZippedRelease = Split-Path -Path $ZippedReleasePath -Leaf

        $uploadUri = $result | Select-Object -ExpandProperty upload_url
        $uploadUri = $uploadUri -replace '\{\?name,label\}', "?name=$ZippedRelease"

        $uploadParams = @{
            Uri         = $uploadUri
            Method      = 'POST'
            Headers     = @{
                Authorization = $auth
            }
            ContentType = 'application/zip'
            InFile      = "$ZippedReleasePath"
        }

        Write-Output "      Upload '$ZippedRelease'"
        $result = Invoke-RestMethod @uploadParams

    } else {
        Write-Error 'GitHubKey not available.'
    }
}

# Synopsis: Commit changes and push to github
task GitHubPush {
    if ($Env:APPVEYOR) {
        $CurrentBranch = $Env:APPVEYOR_REPO_BRANCH
    } else {
        $CurrentBranch = Get-GitBranch
    }

    Write-Output "      Commit and push changes"
    Write-Output "      Current Branch: $CurrentBranch"
    Write-Output "      git checkout $CurrentBranch"
    try {
        # AppVeyor checks out only the latest commit. Get the whole branch
        # Embedded in try/catch as the notification about switching branches
        # is interpreted as error by the exec command
        exec { git checkout $CurrentBranch }
    } catch {}
    Write-Output '      git add --all'
    exec { git add --all }
    Write-Output '      git status'
    exec { git status }
    Write-Output "      git commit -s -m ""v$($Version)"""
    exec { git commit -s -m "v$($Version)"}

    Write-Output "      git push origin $CurrentBranch"
    try {
        exec { git push origin $CurrentBranch }
    } catch {}
	$changes = exec { git status --short }
	assert (-not $changes) 'Please, commit changes.'
}

# Synopsis: Push the project to PSScriptGallery
task PublishToPSGallery GetReleaseNotes, {
    if (-not([string]::IsNullOrEmpty("$Env:PSGalleryKey"))) {
        if (Test-Path -Path $StageReleasePath) {
            # Prepare Publish-Module parameters
            $PSGalleryParams = @{
                NuGetApiKey = "$Env:PSGalleryKey"
                Path = "$StageReleasePath"
                Repository = 'PSGallery'
                ReleaseNotes = $ReleaseNotes
            }

            Publish-Module @PSGalleryParams
            Write-Output  '      Upload project to PSGallery'
        } else {
            Write-Error "      Release Path '$StageReleasePath' not found"
        }
    }
}

# Synopsis: Push the project to PSScriptGallery
task PublishToMyGet GetReleaseNotes, {
    if (-not([string]::IsNullOrEmpty("$Env:MyGetKey"))) {
        if (Test-Path -Path $StageReleasePath) {
            # Prepare Publish-Module parameters
            $MyGetParams = @{
                NuGetApiKey = "$Env:MyGetKey"
                Path = "$StageReleasePath"
                Repository = 'MyGet'
                ReleaseNotes = $ReleaseNotes
            }

            Publish-Module @MyGetParams
            Write-Output '      Upload project to MyGet'
        } else {
            Write-Error "      Release Path '$StageReleasePath' not found"
        }
    }
}

# Synopsis: Extracts the current Releasenotes from the ChangeLog
task GetReleaseNotes Version, {
    # Get Version release notes from Changelog
    Write-Output "      Extract release notes from '$ReleaseNotesName'"
    if (Test-Path $ReleaseNotesPath) {
        $VersionReleaseNotes = Get-Content -Path $ReleaseNotesPath |
                                Where-Object {
                                    $line = $_
                                    if( -not $foundVersion ) {
                                        if( $line -match ('^##\s+\[{0}\]' -f [regex]::Escape($version)) ) {
                                            $foundVersion = $true
                                            return
                                        }
                                    } else {
                                        if( $line -match ('^##\s+\[(?!{0})' -f [regex]::Escape($version)) ) {
                                            $foundVersion = $false
                                        }
                                    }

                                    return( $foundVersion )
                                }
    }

    if($VersionReleaseNotes ) {
        $Script:ReleaseNotes =  ($VersionReleaseNotes -join [Environment]::NewLine)
        Write-Output "      Relase Notes for Version $($Version):"
        Write-Output "$($VersionReleaseNotes -join "$([Environment]::NewLine)      ")"
    }
}

# Synopsis: Sets the Release date for the current version when creating a release on GitHub
task UpdateReleaseNotes Version, {
    if (Test-Path $ReleaseNotesPath) {
        $ReleaseNotes = Get-Content -Path $ReleaseNotesPath -Raw

        if (-not([string]::IsNullOrEmpty($ReleaseNotes))) {
            # Update the current Release with the current date
            Write-Output '      Update release notes with current release date'
            $ReleaseRegEx = '(?<=##\s+\[{0}\] - )(Unreleased|Not Released|Not Released yet)(.*)' -f [regex]::Escape($version)
            $ReleaseDate = (Get-Date).ToString("yyyy-MM-dd")
            $ReleaseNotes = $ReleaseNotes -replace "$ReleaseRegEx", "$ReleaseDate"

            # Get list of all versions in the Release Notes
            $VersionRegEx = '(?<=(##\s+\[)).*(?=(\]))'
            $LastVersion = $ReleaseNotes | select-string -pattern $VersionRegEx -AllMatches | Select-Object -ExpandProperty Matches | Select-Object -ExpandProperty Value -First 1 -Skip 1

            if (-not([string]::IsNullOrEmpty($LastVersion))) {
                Write-Output "      Last Version: $LastVersion"
                # Build GitHub compare string
                $CompareLink = "($ModuleWebsite/compare/v$LastVersion...v$Version)"
                # Need to use a Regex object as -replace does not support replacing individual occurences
                $CompareRegEx = [Regex]'(?<=\[Full Changelog\])(.*)'
                $ReleaseNotes = $CompareRegEx.Replace($ReleaseNotes,$CompareLink,1)
                Write-Output "      Create GitHub 'Compare' link"
            }

            # Remove several empty lines
            Write-Output "      Remove multiple empty lines"
            $EmptyLinesRegex = '(?:\r\n[\s-[\rn]]*){3,}'
            $ReleaseNotes = $ReleaseNotes -replace "$EmptyLinesRegex", "$([Environment]::NewLine)$([Environment]::NewLine)"

            # Write back changes
            Write-Output "      Save changes to '$ReleaseNotesPath'"
            $ReleaseNotes | Set-Content -Path $ReleaseNotesPath -Encoding UTF8

            if (Test-Path $StageReleasePath) {
                # Copy updated file to the Release folder
                Write-Output "      Copy updated Release Notes to '$StageReleasePath'"
                Copy-Item -Path $ReleaseNotesPath -Destination $StageReleasePath -Force
            }
        } else {
            Write-Warning "      No Release Notes found at '$ReleaseNotesPath'"
        }
    }
}

# Synopsis: Prepare artifacts
task PrepareArtifacts Version, {
    # Compress current Release
    $Script:ZippedReleasePath = Join-Path -Path $ScratchPath -ChildPath "$ModuleToBuild-$Version.zip"

    if (Test-Path -Path $StageReleasePath) {
        Write-Output "      Create compressed release file at '$ZippedReleasePath'"
        Compress-Archive -Path $StageReleasePath -DestinationPath $ZippedReleasePath
    }

    if ($Env:APPVEYOR) {
        Push-AppveyorArtifact $ZippedReleasePath
    }
}

# Synopsis: Remove session artifacts like loaded modules and variables
task BuildSessionCleanup {
    # Clean up loaded modules if they are loaded
    $RequiredModules | Foreach-Object {
        Write-Output "      Remove $($_) module (if loaded)"
        Remove-Module $_  -Erroraction Ignore
    }
    Write-Output "      Remove $ModuleToBuild module  (if loaded)"
    Remove-Module $ModuleToBuild -Erroraction Ignore
}

# Synopsis: The default build
task . `
        Configure,
        PrepareStage,
        CreateHelp,
        RunTests,
        CreateModulePSM1,
        PrepareArtifacts,
        BuildSessionCleanup

task BuildAndPush `
        Configure,
        PrepareStage,
        CreateHelp,
        RunTests,
        CreateModulePSM1,
        PrepareArtifacts,
        GitHubPush,
        BuildSessionCleanup

task BuildAndRelease `
        Configure,
        PrepareStage,
        CreateHelp,
        RunTests,
        CreateModulePSM1,
        GitHubPushRelease,
        BuildSessionCleanup

task BuildAndSkipTests `
        Configure,
        PrepareStage,
        CreateHelp,
        CreateModulePSM1,
        PrepareArtifacts,
        BuildSessionCleanup
