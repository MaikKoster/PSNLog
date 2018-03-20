function Test-NLogLogging {
    <#
        .SYNOPSIS
        Verifies if logging is enabled.

        .DESCRIPTION
        The Test-NLogLogging Cmdlet verifies if logging is enabled. Returns $true if enabled. $false if not.

        .EXAMPLE
        PS C:>$Enabled = Test-NLogLogging

        Test if logging is currently enabled
    #>
    [CmdLetBinding()]
    [OutputType([boolean])]
    param()

    process{
        [NLog.Logmanager]::IsLoggingEnabled()
    }
}