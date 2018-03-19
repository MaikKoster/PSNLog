$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'Enable-NLogLogging' {
        It 'Enable simple file logging' {
            $TestPath = Join-Path -Path $TestDrive -ChildPath 'SimpleFileLogging1.log'
            Enable-NLogLogging -FilePath $TestPath

            $Logger = Get-NLogLogger
            $Logger.IsInfoEnabled | Should Be $true
            $Logger.Info("Some Test")
            Test-Path -Path $TestPath | Should Be $true
        }

        It 'Enable simple file logging with min level' {
            $TestPath = Join-Path -Path $TestDrive -ChildPath 'SimpleFileLogging2.log'
            Enable-NLogLogging -FilePath $TestPath -MinLevel 'Warn'

            $Logger = Get-NLogLogger
            $Logger.IsInfoEnabled | Should Be $false
            $Logger.IsWarnEnabled | Should Be $true
            $Logger.Info("Some Test")
            Test-Path -Path $TestPath | Should Be $false
            $Logger.Warn("Some Test")
            Test-Path -Path $TestPath | Should Be $true
        }

        It 'Enable simple target logging' {
            $Target = New-NLogTarget -DebugTarget -Name 'TestTarget'
            Enable-NLogLogging -Target $Target

            $Logger = Get-NLogLogger
            $Logger.IsInfoEnabled | Should Be $true
            $Logger.Info("Some Test")
            $Target.Counter | Should Be 1
        }

        It 'Enable simple target logging with min level' {
            $Target = New-NLogTarget -DebugTarget  -Name 'TestTarget'
            Enable-NLogLogging -Target $Target -MinLevel 'Warn'

            $Logger = Get-NLogLogger
            $Logger.IsInfoEnabled | Should Be $false
            $Logger.IsWarnEnabled | Should Be $true
            $Logger.Info("Some Test")
            $Target.Counter | Should Be 0
            $Logger.Warn("Some Test")
            $Target.Counter | Should Be 1
        }
    }
}