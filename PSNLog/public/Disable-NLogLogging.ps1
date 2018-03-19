function Disable-NLogLogging {
    <#
        .SYNOPSIS
        Disables all logging.

        .DESCRIPTION
        The Disable-NLogLogging Cmdlet disables all global logging.

        .EXAMPLE
        Disable all logging

        PS C:>Disable-NLogLogging
    #>
    [CmdLetBinding(SupportsShouldProcess)]
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