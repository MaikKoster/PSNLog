---
external help file: PSNLog-help.xml
Module Name: PSNLog
online version:
schema: 2.0.0
---

# New-NLogTarget

## SYNOPSIS
Creates a new NLog logging target.

## SYNTAX

### ByTypeName (Default)
```
New-NLogTarget [-Name] <String> [-TargetType] <String> [<CommonParameters>]
```

### NullTarget
```
New-NLogTarget [-Name] <String> [-NullTarget] [<CommonParameters>]
```

### ConsoleTarget
```
New-NLogTarget [-Name] <String> [-ConsoleTarget] [<CommonParameters>]
```

### DatabaseTarget
```
New-NLogTarget [-Name] <String> [-DatabaseTarget] [<CommonParameters>]
```

### DebugTarget
```
New-NLogTarget [-Name] <String> [-DebugTarget] [<CommonParameters>]
```

### EventLogTarget
```
New-NLogTarget [-Name] <String> [-EventLogTarget] [<CommonParameters>]
```

### FileTarget
```
New-NLogTarget [-Name] <String> [-FileTarget] [<CommonParameters>]
```

### MailTarget
```
New-NLogTarget [-Name] <String> [-MailTarget] [<CommonParameters>]
```

### MemoryTarget
```
New-NLogTarget [-Name] <String> [-MemoryTarget] [<CommonParameters>]
```

### NetworkTarget
```
New-NLogTarget [-Name] <String> [-NetworkTarget] [<CommonParameters>]
```

### NLogViewerTarget
```
New-NLogTarget [-Name] <String> [-NLogViewerTarget] [<CommonParameters>]
```

### PerformanceCounterTarget
```
New-NLogTarget [-Name] <String> [-PerformanceCounterTarget] [<CommonParameters>]
```

### WebServiceTarget
```
New-NLogTarget [-Name] <String> [-WebServiceTarget] [<CommonParameters>]
```

## DESCRIPTION
The New-NLogRule Cmdlet returns a new NLog logging target.

## EXAMPLES

### EXAMPLE 1
```
Create a new file target
```

PS C:\\\>$FileTarget = New-NLogTarget -Name 'AllWarnings' -FileTarget
PS C:\\\>$FileTarget.FileName = 'C:\Temp\AllWarnings.log'

## PARAMETERS

### -Name
Specifies the Name of the target

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TargetType
Specifies the type name of the target.
Can be used to create targets not explicitly covered by any switch

```yaml
Type: String
Parameter Sets: ByTypeName
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NullTarget
Specifies to create a new NullTarget
NullTargets discards any log messages.
Used mainly for debugging and benchmarking.

```yaml
Type: SwitchParameter
Parameter Sets: NullTarget
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConsoleTarget
Specifies to create a new ConsoleTarget
Writes log messages to the console.

```yaml
Type: SwitchParameter
Parameter Sets: ConsoleTarget
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DatabaseTarget
Specifies to create a new DatabaseTarget
Writes log messages to the database using an ADO.NET provider.

```yaml
Type: SwitchParameter
Parameter Sets: DatabaseTarget
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -DebugTarget
Specifies to create a new DebugTarget
Mock target - useful for testing.

```yaml
Type: SwitchParameter
Parameter Sets: DebugTarget
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -EventLogTarget
Specifies to create a new EventLogTarget
Writes log message to the Event Log.

```yaml
Type: SwitchParameter
Parameter Sets: EventLogTarget
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileTarget
Specifies to create a new FileTarget
Writes log messages to one or more files.

```yaml
Type: SwitchParameter
Parameter Sets: FileTarget
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MailTarget
Specifies to create a new MailTarget
Sends log messages by email using SMTP protocol.

```yaml
Type: SwitchParameter
Parameter Sets: MailTarget
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MemoryTarget
Specifies to create a new MemoryTarget
Writes log messages to an ArrayList in memory for programmatic retrieval.

```yaml
Type: SwitchParameter
Parameter Sets: MemoryTarget
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NetworkTarget
Specifies to create a new NetworkTarget
Sends log messages over the network.

```yaml
Type: SwitchParameter
Parameter Sets: NetworkTarget
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -NLogViewerTarget
Specifies to create a new NLogViewerTarget
Sends log messages to the remote instance of NLog Viewer.

```yaml
Type: SwitchParameter
Parameter Sets: NLogViewerTarget
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -PerformanceCounterTarget
Specifies to create a new PerformanceCounterTarget
Increments specified performance counter on each write.

```yaml
Type: SwitchParameter
Parameter Sets: PerformanceCounterTarget
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WebServiceTarget
Specifies to create a new WebServiceTarget
Calls the specified web service on each log message.

```yaml
Type: SwitchParameter
Parameter Sets: WebServiceTarget
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### NLog.Targets.Target

## NOTES

## RELATED LINKS
