---
external help file: PSNLog-help.xml
Module Name: PSNLog
online version:
schema: 2.0.0
---

# New-NLogRule

## SYNOPSIS
Creates a new NLog logging rule.

## SYNTAX

### MinLevel (Default)
```
New-NLogRule [[-LoggerNamePattern] <String>] -MinimumLevel <String> -Target <Target> [<CommonParameters>]
```

### MinMaxLevel
```
New-NLogRule [[-LoggerNamePattern] <String>] -MinimumLevel <String> -MaximumLevel <String> -Target <Target>
 [<CommonParameters>]
```

### DisabledRule
```
New-NLogRule [[-LoggerNamePattern] <String>] [-Disabled] -Target <Target> [<CommonParameters>]
```

## DESCRIPTION
The New-NLogRule Cmdlet returns a new NLog logging rule.

## EXAMPLES

### EXAMPLE 1
```
Create a new rule to log all messages above and including the Info level.
```

PS C:\>$Rule = New-NLogRule -MinimumLevel Info -Target $FileTarget

### EXAMPLE 2
```
Create a new rule to log all Warn level messages.
```

PS C:\>$Rule = New-NLogRule -MinimumLevel Warn -MaximumLevel Warn -Target $FileTarget

## PARAMETERS

### -LoggerNamePattern
Specifies the Logger name pattern
It may include the '*' wildcard at the beginning, at the end or at both ends.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: *
Accept pipeline input: False
Accept wildcard characters: False
```

### -Disabled
Specifies if the rule should be disabled by default.

```yaml
Type: SwitchParameter
Parameter Sets: DisabledRule
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinimumLevel
Specifies the minimum log level needed to trigger this rule.

```yaml
Type: String
Parameter Sets: MinLevel, MinMaxLevel
Aliases: MinLevel

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaximumLevel
Specifies the maximum log level needed to trigger this rule.

```yaml
Type: String
Parameter Sets: MinMaxLevel
Aliases: MaxLevel

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Target
Specifies the target to be written to when the rule matches.

```yaml
Type: Target
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### NLog.Config.LoggingRule

## NOTES

## RELATED LINKS
