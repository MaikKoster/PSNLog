function Disable-NLogLogging {
    <#
        .SYNOPSIS
        Disables all logging.

        .DESCRIPTION
        The Disable-NLogLogging Cmdlet disables all global logging.

        .EXAMPLE
        PS C:>Disable-NLogLogging

        Disable all logging
    #>
    [CmdLetBinding()]
    param(
    )

    process{
        do {
            if ([NLog.Logmanager]::IsLoggingEnabled()) {
                $null = [NLog.Logmanager]::DisableLogging()
            }
        } while ([NLog.Logmanager]::IsLoggingEnabled())
    }
}