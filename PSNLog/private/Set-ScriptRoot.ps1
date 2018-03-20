function Set-ScriptRoot {
    <#
        .SYNOPSIS
        Sets the 'scriptroot' variable.

        .DESCRIPTION
        Sets the NLog 'scriptroot' variable to the location of the calling script.
        This variable can be used to automatically create log files at the same location as the script.

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdLetBinding()]
    param()

    process {
        if ($null -ne [NLog.LogManager]::Configuration) {
            $ScriptName = Get-PSCallStack | Select-Object -Last 1 -ExpandProperty 'ScriptName'
            if ([string]::IsNullOrEmpty($ScriptName)) {
                $ScriptLocation = (Get-Location).ToString()
            } else {
                $ScriptLocation = Split-Path -Path $ScriptName -Parent
            }
            [NLog.LogManager]::Configuration.Variables['scriptroot'] = $ScriptLocation
        }
    }
}