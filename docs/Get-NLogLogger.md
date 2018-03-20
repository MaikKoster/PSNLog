---
external help file: PSNLog-help.xml
Module Name: PSNLog
online version:
schema: 2.0.0
---

# Get-NLogLogger

## SYNOPSIS
Gets a NLog Logger instance

## SYNTAX

```
Get-NLogLogger [[-LoggerName] <String>] [<CommonParameters>]
```

## DESCRIPTION
The Get-NLogLogger Cmdlet gets the specified NLog logger.
On default, the LoggerName will have the name of the calling PowerShell CmdLet\Function.

## EXAMPLES

### EXAMPLE 1
```
$Logger = Get-NLogLogger
```

Get a default NLog logger instance

### EXAMPLE 2
```
$Logger = Get-NLogLogger -LoggerName 'MyNlogLogger'
```

Get a NLog logger instance with a specific name

## PARAMETERS

### -LoggerName
Specifies the name of the NLog logger

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: (Get-PSCallStack)[1].Command
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### NLog.Logger

## NOTES

## RELATED LINKS
