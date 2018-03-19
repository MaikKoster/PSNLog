    function Write-NLogVerbose {
    <#
        .SYNOPSIS
        Writes a message on 'Debug' log level and to the Verbose Message stream.

        .DESCRIPTION
        Writes a message on 'Debug' log level and to the Verbose Message stream.
        Can be used to override the native Write-Verbose CmdLet.
    #>
    [CmdLetBinding()]
    param(
        [Parameter(Position=0, Mandatory, ValueFromPipeline)]
        [AllowEmptyString()]
        [Alias('Msg')]
        [string]$Message
    )

    begin {
        $Logger = Get-NLogLogger
    }

    process {
        # Write to Log if possible
        if ($null -ne $Logger) {
            $Logger.Debug($Message)
        }

        # Write to original Message Stream
        Microsoft.PowerShell.Utility\Write-Verbose $PSBoundParameters
    }
}