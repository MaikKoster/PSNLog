#Requires -Version 5

if ($null -eq (get-module InvokeBuild -ListAvailable)) {
    Write-Host -NoNewLine "      Installing InvokeBuild module"
    $null = Install-Module InvokeBuild
    Write-Host -ForegroundColor Green '...Installed!'
}

if (get-module InvokeBuild -ListAvailable) {
    Write-Host -NoNewLine "      Importing InvokeBuild module"
    Import-Module InvokeBuild -Force
    Write-Host -ForegroundColor Green '...Loaded!'
} else {
    throw 'How did you even get here?'
}

# Kick off the standard build
try {
    Invoke-Build
} catch {
    # If it fails then show the error and try to clean up the environment
    Write-Host -ForegroundColor Red 'Build Failed with the following error:'
    Write-Output $_
}
finally {
    Write-Host ''
    Write-Host 'Attempting to clean up the session (loaded modules and such)...'
    Invoke-Build BuildSessionCleanup
    Remove-Module InvokeBuild
}