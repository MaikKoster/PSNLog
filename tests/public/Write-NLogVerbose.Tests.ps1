$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'Write-NLogVerbose' {
        It "Forward message to Write-Verbose" {
            if (Test-Path 'Alias:\Write-Verbose') {
                Remove-Item 'Alias:\Write-Verbose'
            }
            Mock Get-NLogLogger {
                $Result = [PSCustomObject]@{}
                $Result | Add-Member -MemberType ScriptMethod -Name 'Debug' -Value {param([string]$Message)}
                $Result
            }
            Mock Write-Verbose {}
            Write-NLogVerbose 'VerboseTest'
            Assert-MockCalled 'Write-Verbose'
        }
    }
}