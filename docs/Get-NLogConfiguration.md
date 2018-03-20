---
external help file: PSNLog-help.xml
Module Name: PSNLog
online version:
schema: 2.0.0
---

# Get-NLogConfiguration

## SYNOPSIS
Returns the current NLog configuration.

## SYNTAX

```
Get-NLogConfiguration [<CommonParameters>]
```

## DESCRIPTION
The Get-NLogConfiguration Cmdlet returns the current NLog configuration.
If there is no current configuration yet, a new LoggingConfiguration will be returned.

## EXAMPLES

### EXAMPLE 1
```
$Config = Get-NLogConfiguration
```

Get the current logging configuration

## PARAMETERS

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### NLog.Config.LoggingConfiguration

## NOTES

## RELATED LINKS
