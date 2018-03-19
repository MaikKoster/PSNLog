$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'Set-MessageStreams' {
        It "Add correct alias" {
            if (Test-Path 'Alias:\Write-Verbose') {
                Remove-Item 'Alias:\Write-Verbose'
            }
            Set-MessageStreams -WriteVerbose

            Test-Path 'Alias:\Write-Verbose' | Should Be $true

            if (Test-Path 'Alias:\Write-Warning') {
                Remove-Item 'Alias:\Write-Warning'
            }
            Set-MessageStreams -WriteWarning

            Test-Path 'Alias:\Write-Warning' | Should Be $true

            if (Test-Path 'Alias:\Write-Error') {
                Remove-Item 'Alias:\Write-Error'
            }
            Set-MessageStreams -WriteError

            Test-Path 'Alias:\Write-Error' | Should Be $true

            if (Test-Path 'Alias:\Write-Host') {
                Remove-Item 'Alias:\Write-Host'
            }
            Set-MessageStreams -WriteHost
            Test-Path 'Alias:\Write-Host' | Should Be $true
            Remove-Item 'Alias:\Write-Host'
            Remove-Item 'Alias:\Write-Error'
            Remove-Item 'Alias:\Write-Warning'
            Remove-Item 'Alias:\Write-Verbose'
        }
    }
}