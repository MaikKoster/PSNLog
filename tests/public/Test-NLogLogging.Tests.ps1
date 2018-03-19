$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'Test-NLogLogging' {
        It 'Return $true if logging is enabled' {
            Enable-NLogLogging -FilePath (Join-Path $TestDrive -ChildPath 'Test.log')
            Test-NLogLogging | Should Be $true
        }

        It 'Return $false if logging is disabled' {
            Disable-NLogLogging
            Test-NLogLogging | Should Be $false
        }
    }
}