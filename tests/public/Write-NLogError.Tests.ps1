$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'Write-NLogError' {
        It "Forward message to Write-Error" {
            if (Test-Path 'Alias:\Write-Error') {
                Remove-Item 'Alias:\Write-Error'
            }
            Mock Get-NLogLogger {
                $Result = [PSCustomObject]@{}
                $Result | Add-Member -MemberType ScriptMethod -Name 'Error' -Value {param([string]$Message)}
                $Result
            }
            Mock Write-Error {}
            Write-NLogError 'ErrorTest'
            Assert-MockCalled 'Write-Error'
        }
    }
}