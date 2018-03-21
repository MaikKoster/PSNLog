function Write-NLogWarning {
    <#
        .SYNOPSIS
        Writes a message on 'Warn' log level and to the Warning Message stream.

        .DESCRIPTION
        Writes a message on 'Warn' log level and to the Warning Message stream.
        Can be used to override the native Write-Warning CmdLet.
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
            $Logger.Warn($Message)
        }

        # Write to original Message Stream
        Microsoft.PowerShell.Utility\Write-Warning @PSBoundParameters
    }
}