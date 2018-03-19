$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'Write-NLogHost' {
        It "Forward message to Write-Host" {
            if (Test-Path 'Alias:\Write-Host') {
                Remove-Item 'Alias:\Write-Host'
            }
            Mock Get-NLogLogger {
                $Result = [PSCustomObject]@{}
                $Result | Add-Member -MemberType ScriptMethod -Name 'Info' -Value {param([string]$Message)}
                $Result
            }
            Mock Write-Host {}
            Write-NLogHost 'HostTest'
            Assert-MockCalled 'Write-Host'
        }
    }
}