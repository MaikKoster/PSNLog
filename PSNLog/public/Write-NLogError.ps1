function Write-NLogError {
    <#
        .SYNOPSIS
        Writes a message on 'Error' log leve and to the Error Message stream.

        .DESCRIPTION
        Writes a message on 'Error' log leve and to the Error Message stream.
        Can be used to override the native Write-Error CmdLet.
    #>
    [CmdLetBinding()]
    param(
        [Parameter(ParameterSetName='WithException', Mandatory)]
        [Exception]$Exception,

        [Parameter(Position=0, ParameterSetName='NoException', Mandatory, ValueFromPipeline)]
        [Parameter(ParameterSetName='WithException')]
        [AllowNull()]
        [AllowEmptyString()]
        [Alias('Msg')]
        [string]$Message,

        [Parameter(ParameterSetName='ErrorRecord', Mandatory)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,

        [Parameter(ParameterSetName='NoException')]
        [Parameter(ParameterSetName='WithException')]
        [System.Management.Automation.ErrorCategory]$Category,

        [Parameter(ParameterSetName='NoException')]
        [Parameter(ParameterSetName='WithException')]
        [String]$ErrorId,

        [Parameter(ParameterSetName='NoException')]
        [Parameter(ParameterSetName='WithException')]
        [Object]$TargetObject,

        [string]$RecommendedAction,

        [Alias('Activity')]
        [string]$CategoryActivity,

        [Alias('Reason')]
        [string]$CategoryReason,

        [Alias('TargetName')]
        [string]$CategoryTargetName,

        [Alias('TargetType')]
        [string]$CategoryTargetType
    )

    begin {
        $Logger = Get-NLogLogger
    }

    process {
        # Write to Log if possible
        if ($null -ne $Logger) {
            $Logger.Error($Message)
        }

        # Write to original Message Stream
        Microsoft.PowerShell.Utility\Write-Error $PSBoundParameters
    }
}