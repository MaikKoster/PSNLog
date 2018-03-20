function New-NLogRule {
    <#
        .SYNOPSIS
        Creates a new NLog logging rule.

        .DESCRIPTION
        The New-NLogRule Cmdlet returns a new NLog logging rule.

        .EXAMPLE
        PS C:>$Rule = New-NLogRule -MinimumLevel Info -Target $FileTarget

        Create a new rule to log all messages above and including the Info level.

        .EXAMPLE
        PS C:>$Rule = New-NLogRule -MinimumLevel Warn -MaximumLevel Warn -Target $FileTarget

        Create a new rule to log all Warn level messages.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdLetBinding(DefaultParameterSetName='MinLevel')]
    [OutputType([NLog.Config.LoggingRule])]
    param(
        # Specifies the Logger name pattern
        # It may include the '*' wildcard at the beginning, at the end or at both ends.
        [Parameter(ParameterSetName='DisabledRule', Position=0)]
        [Parameter(ParameterSetName='MinLevel', Position=0)]
        [Parameter(ParameterSetName='MinMaxLevel', Position=0)]
        [string]$LoggerNamePattern = '*',

        # Specifies if the rule should be disabled by default.
        [Parameter(ParameterSetName='DisabledRule', Mandatory)]
        [switch]$Disabled,

        # Specifies the minimum log level needed to trigger this rule.
        [Parameter(ParameterSetName='MinLevel', Mandatory)]
        [Parameter(ParameterSetName='MinMaxLevel', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Debug', 'Error', 'Fatal', 'Info', 'Off', 'Trace', 'Warn')]
        [Alias('MinLevel')]
        [string]$MinimumLevel,

        # Specifies the maximum log level needed to trigger this rule.
        [Parameter(ParameterSetName='MinMaxLevel', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Debug', 'Error', 'Fatal', 'Info', 'Off', 'Trace', 'Warn')]
        [Alias('MaxLevel')]
        [string]$MaximumLevel,

        # Specifies the target to be written to when the rule matches.
        [Parameter(ParameterSetName='DisabledRule', Mandatory)]
        [Parameter(ParameterSetName='MinLevel', Mandatory)]
        [Parameter(ParameterSetName='MinMaxLevel', Mandatory)]
        [ValidateNotNullOrEmpty()]
        [NLog.Targets.Target]$Target
    )

    process{
        switch ($PSCmdlet.ParameterSetName) {
            'DisabledRule' {New-Object NLog.Config.LoggingRule($LoggerNamePattern, $Target); break}
            'MinLevel' {New-Object NLog.Config.LoggingRule($LoggerNamePattern, [NLog.LogLevel]::FromString($MinimumLevel), $Target); break}
            'MinMaxLevel' {New-Object NLog.Config.LoggingRule($LoggerNamePattern, [NLog.LogLevel]::FromString($MinimumLevel), [NLog.LogLevel]::FromString($MaximumLevel), $Target); break}
        }
    }
}