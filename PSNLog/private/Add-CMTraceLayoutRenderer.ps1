function Add-CMTraceLayoutRenderer {
    <#
        .SYNOPSIS
        Adds a CMTrace Layout Renderer

        .DESCRIPTION
        The Add-CMTraceLayoutRenderer Cmdlet adds a new layout renderer called 'cmtrace' that
        writes the message in a format that can be easily consumed by the CMTrace.exe log viewer.

        .EXAMPLE
        PS C:\>Add-CMTraceLayoutRenderer

        Adds the CMTrace Layout renderer.

        .NOTES
        This CmdLet is called automatically, when the PSNlog module is imported.
        It's not accessible outside of the module.

    #>
    [CmdLetBinding()]
    param()

    process{
        $CMTrace = {
            param($logEvent)

            # Evaluate caller information
            $Caller = (Get-PSCallStack)[1]
            $Component = $Caller.Command
            $Source = $Caller.Location -replace '<No file>', ''

            switch ($logEvent.Level.ToString()) {
                'Debug' { $Sev = 1 }
                'Error' { $Sev = 3 }
                'Fatal' { $Sev = 3 }
                'Info' { $Sev = 1 }
                'Trace' { $Sev = 1 }
                'Warn' { $Sev = 2 }
                'Info' { $Sev = 1 }
            }

            # Get Timezone Bias to allign log entries through different timezones
            if ($null -eq $Global:TimezoneBias) {
                    [int]$Global:TimezoneBias = [System.TimeZone]::CurrentTimeZone.GetUtcOffset([datetime]::Now).TotalMinutes
            }
            $Date = Get-Date -Format 'MM-dd-yyyy'
            $Time = Get-Date -Format 'HH:mm:ss.fff'
            $TimeString = "$Time$Global:TimezoneBias"

            $Message = "<![LOG[$($logEvent.Message)]LOG]!><time=`"$TimeString`" date=`"$Date`" component=`"$Component`" context=`"`" type=`"$Sev`" thread=`"0`" file=`"$Source`">"
            $Message
        }

        [NLog.LayoutRenderers.LayoutRenderer]::Register('cmtrace', [Func[NLog.LogEventInfo, object]] $CMTrace)
    }
}