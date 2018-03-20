function Set-NLogConfiguration {
    <#
        .SYNOPSIS
        Sets the NLog logging configuration.

        .DESCRIPTION
        The Set-NLogConfiguration Cmdlet sets the logging configuration.

        .EXAMPLE
        PS C:\>Read-NLogConfiguration '.\Sample.config' | Set-NLogConfiguration

        Set new logging configuration from configuration file.

    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdLetBinding()]
    [OutputType([NLog.Config.LoggingConfiguration])]
    param(
        # Specifies the NLog configuration
        [Parameter(Mandatory, Position=0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [NLog.Config.LoggingConfiguration]$Configuration
    )

    process{
        [NLog.LogManager]::Configuration = $Configuration
        Set-ScriptRoot
    }
}