---
external help file: PSNLog-help.xml
Module Name: PSNLog
online version:
schema: 2.0.0
---

# Set-NLogConfiguration

## SYNOPSIS
Sets the NLog logging configuration.

## SYNTAX

```
Set-NLogConfiguration [-Configuration] <LoggingConfiguration> [<CommonParameters>]
```

## DESCRIPTION
The Set-NLogConfiguration Cmdlet sets the logging configuration.

## EXAMPLES

### EXAMPLE 1
```
Read-NLogConfiguration '.\Sample.config' | Set-NLogConfiguration
```

Set new logging configuration from configuration file.

## PARAMETERS

### -Configuration
Specifies the NLog configuration

```yaml
Type: LoggingConfiguration
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### NLog.Config.LoggingConfiguration

## NOTES

## RELATED LINKS
