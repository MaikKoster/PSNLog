$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'New-NLogFileTarget' {
        It 'Throw on invalid parameters' {
            {New-NLogFileTarget '' ''} | Should Throw
            {New-NLogFileTarget $null $null} | Should Throw
            {New-NLogFileTarget -NonExistingTarget } | Should Throw
        }

        It 'Create simple file target' {
            $Target = New-NlogFileTarget -Name 'Testname' -FileName 'TestDrive:\Test.log'

            $Target | Should BeOfType [NLog.Targets.FileTarget]
            $Target.Name | Should Be 'Testname'
            $Target.FileName | Should Be "'TestDrive:\Test.log'"
        }

        It 'Use supplied archive settings' {
            $Target = New-NLogFileTarget -Name 'Testname' `
                                        -Filename 'TestDrive:\Test.log' `
                                        -ArchiveFileName 'TestDrive:\Temp\MyLog.{#}.log' `
                                        -ArchiveNumbering Date `
                                        -ArchiveEvery Day `
                                        -MaxArchiveFiles 14 `
                                        -ArchiveDateFormat 'yyyyMMdd' `
                                        -EnableArchiveFileCompression

            $Target | Should BeOfType [NLog.Targets.FileTarget]
            $Target.Name | Should Be 'Testname'
            $Target.FileName | Should Be "'TestDrive:\Test.log'"
            $Target.ArchiveFileName | Should Be "'TestDrive:\Temp\MyLog.{#}.log'"
            $Target.ArchiveNumbering | Should Be 'Date'
            $Target.ArchiveEvery | Should Be 'Day'
            $Target.MaxArchiveFiles | Should Be 14
            $Target.ArchiveDateFormat | Should Be 'yyyyMMdd'
            $Target.EnableArchiveFileCompression | Should Be $true

        }
    }
}