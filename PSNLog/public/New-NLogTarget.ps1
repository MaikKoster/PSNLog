function New-NLogTarget {
    <#
        .SYNOPSIS
        Creates a new NLog logging target.

        .DESCRIPTION
        The New-NLogTarget Cmdlet returns a new NLog logging target.

        .EXAMPLE
        PS C:\>$FileTarget = New-NLogTarget -Name 'AllWarnings' -FileTarget
        PS C:\>$FileTarget.FileName = 'C:\Temp\AllWarnings.log'

        Create a new file target
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    [CmdLetBinding(DefaultParameterSetName='ByTypeName')]
    [OutputType([NLog.Targets.Target])]
    param(
        # Specifies the Name of the target
        # If no name is supplied, a random string will be used
        [Parameter(Position=0)]
        [string]$Name,

        # Specifies the type name of the target.
        # Can be used to create targets not explicitly covered by any switch
        [Parameter(ParameterSetName='ByTypeName', Mandatory, Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetType,

        # Specifies to create a new NullTarget
        # NullTargets discards any log messages. Used mainly for debugging and benchmarking.
        [Parameter(ParameterSetName='NullTarget', Mandatory)]
        [switch]$NullTarget,

        # Specifies to create a new ConsoleTarget
        # Writes log messages to the console.
        [Parameter(ParameterSetName='ConsoleTarget', Mandatory)]
        [switch]$ConsoleTarget,

        # Specifies to create a new DatabaseTarget
        # Writes log messages to the database using an ADO.NET provider.
        [Parameter(ParameterSetName='DatabaseTarget', Mandatory)]
        [switch]$DatabaseTarget,

        # Specifies to create a new DebugTarget
        # Mock target - useful for testing.
        [Parameter(ParameterSetName='DebugTarget', Mandatory)]
        [switch]$DebugTarget,

        # Specifies to create a new EventLogTarget
        # Writes log message to the Event Log.
        [Parameter(ParameterSetName='EventLogTarget', Mandatory)]
        [switch]$EventLogTarget,

        # Specifies to create a new FileTarget
        # Writes log messages to one or more files.
        [Parameter(ParameterSetName='FileTarget', Mandatory)]
        [switch]$FileTarget,

        # Specifies to create a new MailTarget
        # Sends log messages by email using SMTP protocol.
        [Parameter(ParameterSetName='MailTarget', Mandatory)]
        [switch]$MailTarget,

        # Specifies to create a new MemoryTarget
        # Writes log messages to an ArrayList in memory for programmatic retrieval.
        [Parameter(ParameterSetName='MemoryTarget', Mandatory)]
        [switch]$MemoryTarget,

        # Specifies to create a new NetworkTarget
        # Sends log messages over the network.
        [Parameter(ParameterSetName='NetworkTarget', Mandatory)]
        [switch]$NetworkTarget,

        # Specifies to create a new NLogViewerTarget
        # Sends log messages to the remote instance of NLog Viewer.
        [Parameter(ParameterSetName='NLogViewerTarget', Mandatory)]
        [switch]$NLogViewerTarget,

        # Specifies to create a new PerformanceCounterTarget
        # Increments specified performance counter on each write.
        [Parameter(ParameterSetName='PerformanceCounterTarget', Mandatory)]
        [switch]$PerformanceCounterTarget,

        # Specifies to create a new WebServiceTarget
        # Calls the specified web service on each log message.
        [Parameter(ParameterSetName='WebServiceTarget', Mandatory)]
        [switch]$WebServiceTarget
    )

    process{
        $Target = $null
        switch ($PSCmdlet.ParameterSetName) {
            'ByTypeName' {
                if ($TargetType -like 'NLog.Targets.*') {
                    $Target = New-Object "$TargetType"
                } elseif ($TargetType -like 'Targets.*') {
                    $Target = New-Object "NLog.$TargetType"
                } else {
                    $Target = New-Object "NLog.Targets.$TargetType"
                }
                break
            }
            'NullTarget' {$Target = New-Object NLog.Targets.NullTarget;break}
            'ConsoleTarget' {$Target = New-Object NLog.Targets.ConsoleTarget;break}
            'DatabaseTarget' {$Target = New-Object NLog.Targets.DatabaseTarget;break}
            'DebugTarget' {$Target = New-Object NLog.Targets.DebugTarget;break}
            'EventLogTarget' {$Target = New-Object NLog.Targets.EventLogTarget;break}
            'FileTarget' {$Target = New-Object NLog.Targets.FileTarget;break}
            'MailTarget' {$Target = New-Object NLog.Targets.MailTarget;break}
            'MemoryTarget' {$Target = New-Object NLog.Targets.MemoryTarget;break}
            'NetworkTarget' {$Target = New-Object NLog.Targets.NetworkTarget;break}
            'NLogViewerTarget' {$Target = New-Object NLog.Targets.NLogViewerTarget;break}
            'PerformanceCounterTarget' {$Target = New-Object NLog.Targets.PerformanceCounterTarget;break}
            'WebServiceTarget' {$Target = New-Object NLog.Targets.WebServiceTarget;break}
        }

        if ($null -ne $Target) {
            if ([string]::IsNullOrEmpty($Name)) {
                # Generate random string
                $Name = -join ((65..90) | Get-Random -Count 6 | ForEach-Object {[char]$_})
            }
            $Target.Name = $Name
            $Target
        }
    }
}