$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'Get-NLogConfiguration' {
        It 'Get current NLog configuration configuration' {
            Copy-Item -Path "$PSScriptRoot\..\..\PSNlog\Sample.config" -Destination "$TestDrive"
            $Config = Read-NLogConfiguration -Filename "$TestDrive\Sample.config"
            Set-NLogConfiguration -Configuration $Config

            $NewConfig = Get-NLogConfiguration

            $NewConfig | Should BeOfType [NLog.Config.LoggingConfiguration]
            [string]::Compare(($Config | ConvertTo-Json -Depth 4), ($NewConfig | ConvertTo-Json -Depth 4), $true) | Should Be 0
        }

        It 'Get new configuration' {
            [NLog.LogManager]::Configuration = $null
            $Config = Get-NLogConfiguration
            $NewConfig = New-Object NLog.Config.LoggingConfiguration
            $Config | Should BeOfType [NLog.Config.LoggingConfiguration]
            [string]::Compare(($Config | ConvertTo-Json -Depth 4), ([NLog.LogManager]::Configuration | ConvertTo-Json -Depth 4), $true) | Should Be 1
            [string]::Compare(($Config | ConvertTo-Json -Depth 4), ($NewConfig | ConvertTo-Json -Depth 4), $true) | Should Be 0

        }
    }
}