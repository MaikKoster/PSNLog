$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'Get-NLogLogger' {
        It 'Return default logger' {
            $Logger = Get-NLogLogger

            $Logger | Should BeOfType [NLog.Logger]
            $Logger.Name | Should Be "Invoke-Test"
        }

        It 'Return specified logger' {
            $Logger = Get-NLogLogger -LoggerName 'PSNLogTest'

            $Logger | Should BeOfType [NLog.Logger]
            $Logger.Name | Should Be "PSNLogTest"
        }
    }
}