$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'New-NLogTarget' {
        It 'Throw on invalid parameters' {
            {New-NLogTarget '' ''} | Should Throw
            {New-NLogTarget $null $null} | Should Throw
            {New-NLogTarget -NonExistingTarget } | Should Throw
        }

        It 'Create by target type name' {
            New-NLogTarget 'Testname' 'NullTarget' | Should BeOfType [NLog.Targets.NullTarget]
            New-NLogTarget 'Testname' 'Targets.ConsoleTarget' | Should BeOfType [NLog.Targets.ConsoleTarget]
            New-NLogTarget 'Testname' 'NLog.Targets.DatabaseTarget' | Should BeOfType [NLog.Targets.DatabaseTarget]
            New-NLogTarget 'Testname' 'DebugTarget' | Should BeOfType [NLog.Targets.DebugTarget]
            New-NLogTarget 'Testname' 'Targets.EventLogTarget' | Should BeOfType [NLog.Targets.EventLogTarget]
            New-NLogTarget 'Testname' 'NLog.Targets.FileTarget' | Should BeOfType [NLog.Targets.FileTarget]
            New-NLogTarget 'Testname' 'MailTarget' | Should BeOfType [NLog.Targets.MailTarget]
            New-NLogTarget 'Testname' 'Targets.MemoryTarget' | Should BeOfType [NLog.Targets.MemoryTarget]
            New-NLogTarget 'Testname' 'NLog.Targets.NetworkTarget' | Should BeOfType [NLog.Targets.NetworkTarget]
            New-NLogTarget 'Testname' 'NLogViewerTarget' | Should BeOfType [NLog.Targets.NLogViewerTarget]
            New-NLogTarget 'Testname' 'Targets.PerformanceCounterTarget' | Should BeOfType [NLog.Targets.PerformanceCounterTarget]
            New-NLogTarget 'Testname' 'NLog.Targets.WebServiceTarget' | Should BeOfType [NLog.Targets.WebServiceTarget]
        }

        It 'Create by taget type' {
            New-NLogTarget -Name 'Testname' -NullTarget | Should BeOfType [NLog.Targets.NullTarget]
            New-NLogTarget -Name 'Testname' -ConsoleTarget | Should BeOfType [NLog.Targets.ConsoleTarget]
            New-NLogTarget -Name 'Testname' -DatabaseTarget | Should BeOfType [NLog.Targets.DatabaseTarget]
            New-NLogTarget -Name 'Testname' -DebugTarget | Should BeOfType [NLog.Targets.DebugTarget]
            New-NLogTarget -Name 'Testname' -EventLogTarget | Should BeOfType [NLog.Targets.EventLogTarget]
            New-NLogTarget -Name 'Testname' -FileTarget | Should BeOfType [NLog.Targets.FileTarget]
            New-NLogTarget -Name 'Testname' -MailTarget | Should BeOfType [NLog.Targets.MailTarget]
            New-NLogTarget -Name 'Testname' -MemoryTarget | Should BeOfType [NLog.Targets.MemoryTarget]
            New-NLogTarget -Name 'Testname' -NetworkTarget | Should BeOfType [NLog.Targets.NetworkTarget]
            New-NLogTarget -Name 'Testname' -NLogViewerTarget | Should BeOfType [NLog.Targets.NLogViewerTarget]
            New-NLogTarget -Name 'Testname' -PerformanceCounterTarget | Should BeOfType [NLog.Targets.PerformanceCounterTarget]
            New-NLogTarget -Name 'Testname' -WebServiceTarget | Should BeOfType [NLog.Targets.WebServiceTarget]
        }
    }
}