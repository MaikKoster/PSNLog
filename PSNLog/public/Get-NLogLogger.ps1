
function Get-NLogLogger {
    <#
        .SYNOPSIS
        Gets a NLog Logger instance

        .DESCRIPTION
        The Get-NLogLogger Cmdlet gets the specified NLog logger.

    #>
    [CmdLetBinding()]
    [OutputType([NLog.Logger])]
    param(
        # Specifies the name of the NLog logger
        [string]$LoggerName = 'PSNLog'
    )

    process{
        [NLog.LogManager]::GetLogger($LoggerName)
    }
}