$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'Write-NLogWarning' {
        It "Forward message to Write-Warning" {
            if (Test-Path 'Alias:\Write-Warning') {
                Remove-Item 'Alias:\Write-Warning'
            }
            Mock Get-NLogLogger {
                $Result = [PSCustomObject]@{}
                $Result | Add-Member -MemberType ScriptMethod -Name 'Warn' -Value {param([string]$Message)}
                $Result
            }
            Mock Write-Warning {}
            Write-NLogWarning 'WarningTest'
            Assert-MockCalled 'Write-Warning'
        }
    }
}