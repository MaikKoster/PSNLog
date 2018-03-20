$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$root = $here -replace "\\public|\\private|\\tests", ""
$ModuleName = 'PSNLog'

# Import our module to use InModuleScope
if (-Not(Get-Module -Name "$ModuleName")) {
    Import-Module (Resolve-Path "$root\$ModuleName\$ModuleName.psd1") -Force
}

InModuleScope "$ModuleName" {
    Describe 'Set-ScriptRoot' {
        It "Set proper location" {
            $ScriptName = Get-PSCallStack | Select-Object -Last 1 -ExpandProperty 'ScriptName'
            if ([string]::IsNullOrEmpty($ScriptName)) {
                $ScriptLocation = (Get-Location).ToString()
            } else {
                $ScriptLocation = Split-Path -Path $ScriptName -Parent
            }
            Set-Scriptroot
            [NLog.LogManager]::Configuration.Variables['scriptroot'] | Should Be "'$ScriptLocation'"
        }
    }
}