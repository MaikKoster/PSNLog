
function Get-NLogLogger {
    <#
        .SYNOPSIS
        Gets a NLog Logger instance

        .DESCRIPTION
        The Get-NLogLogger Cmdlet gets the specified NLog logger.
        On default, the LoggerName will have the name of the calling PowerShell CmdLet\Function.

        .EXAMPLE
        PS C:\>$Logger = Get-NLogLogger

        Get a default NLog logger instance

        .EXAMPLE
        PS C:\>$Logger = Get-NLogLogger -LoggerName 'MyNlogLogger'

        Get a NLog logger instance with a specific name
    #>
    [CmdLetBinding()]
    [OutputType([NLog.Logger])]
    param(
        # Specifies the name of the NLog logger
        [Parameter(Position=0)]
        [string]$LoggerName = (Get-PSCallStack)[1].Command
    )

    process{
        [NLog.LogManager]::GetLogger($LoggerName)
    }
}