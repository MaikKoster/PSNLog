function Write-NLogHost {
    <#
        .SYNOPSIS
        Writes a message on 'Info' log level and to the Host.

        .DESCRIPTION
        Writes a message on 'Info' log level and to the Host.
        Can be used to override the native Write-Host CmdLet.
    #>
    [CmdLetBinding()]
    param(
        [Parameter(Position=0)]
        [object]$Object,
        [switch]$NoNewline,
        [object]$Separator,
        [ConsoleColor]$ForegroundColor,
        [ConsoleColor]$BackgroundColor
    )

    begin {
        $Logger = Get-NLogLogger
    }

    process {
        # Write to Log if possible
        if ($null -ne $Logger) {
            $Logger.Info($Object.ToString())
        }

        # Write to original Message Stream
        Microsoft.PowerShell.Utility\Write-Host $PSBoundParameters
    }
}