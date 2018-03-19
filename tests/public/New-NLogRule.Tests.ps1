$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'New-NLogRule' {
        It 'Throw on invalid parameters' {
            {New-NLogRule -Disabled -Target $null} | Should Throw
            {New-NLogRule -MinLevel 'Warn' -Target $null} | Should Throw
        }

        It 'Create disabled rule' {
            $Target = New-NLogTarget -NullTarget  -Name 'TestTarget'
            $Rule = New-NLogRule -Target $Target -Disabled

            $Rule | Should BeOfType [NLog.Config.LoggingRule]
            $Rule.LoggerNamePattern | Should Be '*'
        }

        It 'Create logging rule with minimum level' {
            $Target = New-NLogTarget -NullTarget  -Name 'TestTarget'
            $Rule = New-NLogRule -Target $Target -MinLevel 'Warn'

            $Rule | Should BeOfType [NLog.Config.LoggingRule]
            $Rule.LoggerNamePattern | Should Be '*'
            $Rule.IsLoggingEnabledForLevel([NLog.LogLevel]::Info) | Should Be $false
            $Rule.IsLoggingEnabledForLevel([NLog.LogLevel]::Warn) | Should Be $true

        }

        It 'Create logging rule with level range' {
            $Target = New-NLogTarget -NullTarget  -Name 'TestTarget'
            $Rule = New-NLogRule -Target $Target -MinLevel 'Info' -MaxLevel 'Warn'

            $Rule | Should BeOfType [NLog.Config.LoggingRule]
            $Rule.LoggerNamePattern | Should Be '*'
            $Rule.IsLoggingEnabledForLevel([NLog.LogLevel]::Debug) | Should Be $false
            $Rule.IsLoggingEnabledForLevel([NLog.LogLevel]::Info) | Should Be $true
            $Rule.IsLoggingEnabledForLevel([NLog.LogLevel]::Warn) | Should Be $true
            $Rule.IsLoggingEnabledForLevel([NLog.LogLevel]::Error) | Should Be $false
        }
    }
}