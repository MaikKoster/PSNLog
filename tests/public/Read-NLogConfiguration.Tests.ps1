$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'Read-NLogConfiguration' {
        It 'Return sample configuration' {
            Copy-Item -Path "$PSScriptRoot\..\..\PSNlog\Sample.config" -Destination "$TestDrive"
            $Config = Read-NLogConfiguration -Filename "$TestDrive\Sample.config"

            $Config | Should BeOfType [NLog.Config.LoggingConfiguration]
        }
    }
}