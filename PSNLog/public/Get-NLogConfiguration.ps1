function Get-NLogConfiguration {
    <#
        .SYNOPSIS
        Returns the current NLog configuration.

        .DESCRIPTION
        The Get-NLogConfiguration Cmdlet returns the current NLog configuration.
        If there is no current configuration yet, a new LoggingConfiguration will be returned.

        .EXAMPLE
        PS C:\>$Config = Get-NLogConfiguration

        Get the current logging configuration
    #>
    [CmdLetBinding()]
    [OutputType([NLog.Config.LoggingConfiguration])]
    param()

    process{
        if ($null -eq [NLog.LogManager]::Configuration) {
            New-Object NLog.Config.LoggingConfiguration
        } else {
            [NLog.LogManager]::Configuration
        }
    }
}