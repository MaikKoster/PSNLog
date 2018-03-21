$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'Enable-NLogLogging' {
        It 'Enable very simple file loging ' {
            Enable-NLogLogging

            $Logger = Get-NLogLogger
            $Logger.IsInfoEnabled | Should Be $true
            $Logger.Info("Some Test")
            $config = Get-NLogConfiguration
            $Config.AllTargets | Select-Object -First 1 -ExpandProperty Layout | Select-Object -ExpandProperty OriginalText | Should Be '${cmtrace}'
            Disable-NLogLogging
        }

        It 'Enable simple file logging' {
            $TestPath = Join-Path -Path $TestDrive -ChildPath 'SimpleFileLogging1.log'
            Enable-NLogLogging -Filename $TestPath

            $Logger = Get-NLogLogger
            $Logger.IsInfoEnabled | Should Be $true
            $Logger.Info("Some Test")
            Test-Path -Path $TestPath | Should Be $true
            Disable-NLogLogging
        }

        It 'Enable simple file logging and automatically redirect messages' {
            $TestPath = Join-Path -Path $TestDrive -ChildPath 'SimpleFileLogging1.log'
            Enable-NLogLogging -Filename $TestPath

            $Logger = Get-NLogLogger
            $Logger.IsInfoEnabled | Should Be $true
            $Logger.Info("Some Test")
            Test-Path -Path $TestPath | Should Be $true
            Test-Path -Path 'Alias:\Write-Verbose' | Should Be $true
            Test-Path -Path 'Alias:\Write-Warning' | Should Be $true
            Test-Path -Path 'Alias:\Write-Error' | Should Be $true
            Test-Path -Path 'Alias:\Write-Host' | Should Be $false
            Set-MessageStreams -Remove
            Disable-NLogLogging
        }

        It 'Enable simple file logging and do not redirect messages' {
            $TestPath = Join-Path -Path $TestDrive -ChildPath 'SimpleFileLogging1.log'
            Enable-NLogLogging -Filename $TestPath -DontRedirectMessages

            $Logger = Get-NLogLogger
            $Logger.IsInfoEnabled | Should Be $true
            $Logger.Info("Some Test")
            Test-Path -Path $TestPath | Should Be $true
            Test-Path -Path 'Alias:\Write-Verbose' | Should Be $false
            Test-Path -Path 'Alias:\Write-Warning' | Should Be $false
            Test-Path -Path 'Alias:\Write-Error' | Should Be $false
            Test-Path -Path 'Alias:\Write-Host' | Should Be $false
            Set-MessageStreams -Remove
            Disable-NLogLogging
        }

        It 'Enable simple file logging with min level' {
            $TestPath = Join-Path -Path $TestDrive -ChildPath 'SimpleFileLogging2.log'
            Enable-NLogLogging -Filename $TestPath -MinLevel 'Warn'

            $Logger = Get-NLogLogger
            $Logger.IsInfoEnabled | Should Be $false
            $Logger.IsWarnEnabled | Should Be $true
            $Logger.Info("Some Test")
            Test-Path -Path $TestPath | Should Be $false
            $Logger.Warn("Some Test")
            Test-Path -Path $TestPath | Should Be $true
            Disable-NLogLogging
        }

        It 'Enable simple target logging' {
            $Target = New-NLogTarget -DebugTarget -Name 'TestTarget'
            Enable-NLogLogging -Target $Target

            $Logger = Get-NLogLogger
            $Logger.IsInfoEnabled | Should Be $true
            $Logger.Info("Some Test")
            $Target.Counter | Should Be 1
            Disable-NLogLogging
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
            Disable-NLogLogging
        }
    }
}