$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""

$ModuleName = "PSNLog"

# Import our module to use InModuleScope
Get-Module -Name $ModuleName -All | Remove-Module -Force -ErrorAction Stop
$ManifestPath = (Resolve-Path -Path (Join-Path -Path $root -ChildPath "$ModuleName\$ModuleName.psd1"))
$changeLogPath = (Resolve-Path -Path (Join-Path -Path $root -ChildPath "CHANGELOG.MD"))

#Import-Module $ManifestPath -Force

Describe "Manifest" {
    $script:manifest = $null

    It "has a valid manifest" {
        {
            $Script:Manifest = Test-ModuleManifest -Path $ManifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It "has a valid name" {
        $Script:Manifest.Name | Should Be $ModuleName
    }

	It "has a valid root module" {
        $Script:Manifest.RootModule | Should Be "$ModuleName.psm1"
    }

	It "has a valid Description" {
        $Script:Manifest.Description | Should Not BeNullOrEmpty
    }

    It "has a valid guid" {
        $Script:Manifest.Guid | Should Be 'fe52b5c2-b2f8-4804-87c6-8606410b8f7d'
    }

    It "has no prefix" {
		$Script:Manifest.Prefix | Should BeNullOrEmpty
	}

	It "has a valid copyright" {
		$Script:Manifest.CopyRight | Should Not BeNullOrEmpty
    }

    It "has a valid version in the manifest" {
        $script:manifest.Version -as [Version] | Should Not BeNullOrEmpty
    }

    # $script:changelogVersion = $null
    # It "has a valid version in the changelog" {

    #     foreach ($line in (Get-Content $changeLogPath))
    #     {
    #         if ($line -match "^\D*(?<Version>(\d+\.){1,3}\d+)")
    #         {
    #             $script:changelogVersion = $matches.Version
    #             break
    #         }
    #     }
    #     $script:changelogVersion                | Should Not BeNullOrEmpty
    #     $script:changelogVersion -as [Version]  | Should Not BeNullOrEmpty
    # }

    #It "changelog and manifest versions are the same" {
    #    $script:changelogVersion -as [Version] | Should be ( $script:manifest.Version -as [Version] )
    #}


    #It "has a valid HelpInfoUri" {
    #    $Script:Manifest.HelpInfoUri |Should Not BeNullOrEmpty
    #    { Invoke-WebRequest -Path $Module.HelpInfoUri } | Should Throw
    #}

    #foreach ($command in (Get-Command -Module $Module)) {
    #    if ($command.HelpUri) {
    #        It "$command has a valid HelpUri " {
    #            { Invoke-WebRequest -Path $command.HelpUri } | Should Not Throw
    #        }
    #    }
    #}
}

Describe "Testfiles" {

    foreach ($File in (Get-ChildItem "$root\$ModuleName" -File "*.ps1" -Recurse)) {

        It "$($File.Name) has a corresponding Testfile." {
            Get-ChildItem "$Root\tests" -Recurse -File -Filter "$($File.BaseName).Tests.ps1" | Should Not BeNullOrEmpty
        }
    }
}