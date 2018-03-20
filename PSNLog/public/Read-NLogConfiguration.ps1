function Read-NLogConfiguration {
    <#
        .SYNOPSIS
        Returns a NLog configuration based on a configuration file.

        .DESCRIPTION
        The Read-NLogConfiguration Cmdlet returns the specified NLog logging configuration

        .EXAMPLE
        PS C:\>$Config = Read-NLogConfiguration '.\Sample.config'

        Read configuration from config file

        .EXAMPLE
        PS C:\>Read-NLogConfiguration '.\Sample.config' | Set-NLogConfiguration

        Read configuration from config file and set as configuration for all logging.

    #>
    [CmdLetBinding()]
    [OutputType([NLog.Config.LoggingConfiguration])]
    param(
        # Specifies the name and path to the NLog configuration file
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({(Test-Path $_) -and ((Get-Item $_).Extension -match '\.(config|nlog)')})]
        [Alias('FullName')]
        [string]$Filename
    )

    process{
        New-Object NLog.Config.XmlLoggingConfiguration($Filename, $true)
    }
}