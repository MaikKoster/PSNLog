function Enable-NLogLogging {
    <#
        .SYNOPSIS
        Enables simple logging for trivial logging cases.

        .DESCRIPTION
        The Enable-NLogLogging Cmdlet allows to quickly enable some simple logging
        for trivial logging cases.

        .EXAMPLE
        Quickly configure NLog so that all messages above and including the Info level are written to a file.

        PS C:\>Enable-NLogLogging -FilePath 'C:\Temp\MyLogging.log'

        .EXAMPLE
        Quickly configure NLog so that all messages above and including the Debug level are written to a file.
        Automatically log all existing Write-Verbose messages to Debug, Write-Warning to Warn and Write-Error to Error.

        PS C:\>Enable-NLogLogging -FilePath 'C:\Temp\MyLogging.log' -MinimumLevel Debug -RedirectMessages

        .EXAMPLE
        Quickly configure NLog so that all messages above and including the Warn level are written to target.

        PS C:\>$Target = New-NLogTarget -Name 'Warnings' -FileTarget
        PS C:\>$Target.Filename = 'C:\Temp\MyLogging.log'
        PS C:\>$Target.CreateDirs = $true
        PS C:\>Enable-NLogLogging -Target $Target -MinLevel Warn

    #>
    [CmdLetBinding(DefaultParameterSetName='ByFilename')]
    param(
        # Specifies the Filename to write log messages to.
        [Parameter(ParameterSetName='ByFilename', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        [string]$FilePath,

        # Specifies the Target to write log messages to.
        [Parameter(ParameterSetName='ByTarget', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [NLog.Targets.Target]$Target,

        # Specifies the minimum log level.
        [Parameter(ParameterSetName='ByFilename')]
        [Parameter(ParameterSetName='ByTarget')]
        [ValidateSet('Debug', 'Error', 'Fatal', 'Info', 'Off', 'Trace', 'Warn')]
        [Alias('MinLevel')]
        [string]$MinimumLevel,

        # Specifies, if Messages written to Write-Verbose/Write-Host/Write-Warning/Write-Error should be
        # redirected to the logging Target automagically.
        # If set, the following configuration will be applied
        # Write-Verbose -> Log message on 'Debug' level
        # Write-Warning -> Log message on 'Warning' level
        # Write-Error -> Log message on 'Error' level
        [switch]$RedirectMessages,

        # Specifies, if Messages written to Write-Host should be
        # redirected to the logging Target automagically.
        # If set, the following configuration will be applied
        # Write-Host -> Log message on 'Info' level
        # Might cause some strange behaviour. So test properly.
        [switch]$RedirectHost
    )

    process{
        if ($PSCmdlet.ParameterSetName -eq 'ByFilename') {
            if ([string]::IsNullOrEmpty($MinimumLevel)) {
                [NLog.Config.SimpleConfigurator]::ConfigureForFileLogging($FilePath)
            } else {
                [NLog.Config.SimpleConfigurator]::ConfigureForFileLogging($FilePath, [NLog.LogLevel]::FromString($MinimumLevel))
            }
        } else {
            if ([string]::IsNullOrEmpty($MinimumLevel)) {
                [NLog.Config.SimpleConfigurator]::ConfigureForTargetLogging($Target)
            } else {
                [NLog.Config.SimpleConfigurator]::ConfigureForTargetLogging($Target, [NLog.LogLevel]::FromString($MinimumLevel))
            }
        }

        if (-Not([NLog.LogManager]::IsLoggingEnabled())) {
            [NLog.LogManager]::EnableLogging()
        }

        if ($RedirectMessages.IsPresent) {
            Set-MessageStreams -WriteVerbose -WriteWarning -WriteError
        }

        if ($RedirectHost.IsPresent) {
            Set-MessageStreams -WriteHost
        }
    }
}