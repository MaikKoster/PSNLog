$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'Set-NLogConfiguration' {
        Mock Set-ScriptRoot {}
        It 'Throw if no object is supplied' {
            {Set-NLogConfiguration -Configuration $null} | Should Throw
        }

        It 'Set configuration' {
            [NLog.Logmanager]::Configuration = $null
            Copy-Item -Path "$PSScriptRoot\..\..\PSNlog\Sample.config" -Destination "$TestDrive"
            $Config = Read-NLogConfiguration -Filename "$TestDrive\Sample.config"
            Set-NLogConfiguration -Configuration $Config

            [string]::Compare(($Config | ConvertTo-Json -Depth 4), ([NLog.LogManager]::Configuration | ConvertTo-Json -Depth 4), $true) | Should Be 0
            Assert-MockCalled Set-ScriptRoot -Times 1
        }
    }
}