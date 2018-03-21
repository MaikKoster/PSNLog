---
external help file: PSNLog-help.xml
Module Name: PSNLog
online version:
schema: 2.0.0
---

# New-NLogFileTarget

## SYNOPSIS
Creates a new NLog file logging target.

## SYNTAX

```
New-NLogFileTarget [[-Name] <String>] [[-FileName] <String>] [-Layout <String>] [-ArchiveFileName <String>]
 [-ArchiveNumbering <String>] [-ArchiveDateFormat <String>] [-ArchiveEvery <String>] [-MaxArchiveFiles <Int32>]
 [-EnableArchiveFileCompression] [<CommonParameters>]
```

## DESCRIPTION
The New-NLogFileTarget Cmdlet returns a new NLog file logging target.
In addition to creating a FileTarget using the New-NLogTarget CmdLet, this CmdLet allows to
supply common parameters.

## EXAMPLES

### EXAMPLE 1
```
$FileTarget = New-NLogFileTarget -Name 'f1' -Filename 'C:\Temp\MyLog.log'
```

Create a new file target, that writes log messages to the file C:\Temp\MyLog.log.

### EXAMPLE 2
```
$FileTarget = New-NLogFileTarget -Name 'f1' -Filename 'C:\Temp\MyLog.log' -Layout '${cmtrace}'
```

Create a new file target, that writes log messages to the file C:\Temp\MyLog.log using the CMTrace
Layout renderer.

### EXAMPLE 3
```
$FileTarget = New-NLogFileTarget -Name 'f1' -Filename '${env:scriptroot}/${level}.log'
```

Creates a new file target, that writes log messages to a log file that corresponds to the log level.

### EXAMPLE 4
```
$FileTarget = New-NLogFileTarget -Name 'f1' `
```

-Filename 'C:\Temp\MyLog.log' \`
                                        -ArchiveFileName 'C:\Temp\MyLog.{#}.log' \`
                                        -ArchiveNumbering Date \`
                                        -ArchiveEvery Day \`
                                        -MaxArchiveFiles 14 \`
                                        -ArchiveDateFormat 'yyyyMMdd'
                                        -EnableArchiveFileCompression


Creates a new file target, that writes log messages to the file C:\Temp\MyLog.log and archives the
compressed log file every day into a subfolder 'archive'.
All archived files older than 14 days will
be removed.

## PARAMETERS

### -Name
Specifies the Name of the target
If no name is supplied, a random string will be used

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FileName
Specifies the name and path to write to.
This FileName string is a layout which may include instances of layout renderers.
This lets
you use a single target to write to multiple files.
The following value makes NLog write logging events to files based on the log level in the
directory where the script runs.
${env:scriptroot}/${level}.log
All Debug messages will go to Debug.log, all Info messages will go to Info.log and so on.
You can combine as many of the layout renderers as you want to produce an arbitrary log file name.
If no filename is supplied, the name of the calling script will be used and written to the
current users %Temp% directory.
if not called from a script, the name will default to 'PSNLog'

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Layout
Specifies the layout that is used to render the log message

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ArchiveFileName
Specifies the name of the file to be used for an archive.
It may contain a special placeholder {#####} that will be replaced with a sequence of numbers
depending on the archiving strategy.
The number of hash characters used determines the number
of numerical digits to be used for numbering files.
warning when deleting archives files is enabled (e.g.
maxArchiveFiles ), the folder of the
archives should different than the log files.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ArchiveNumbering
Specifies the way archives are numbered.
Possible values:
- Rolling  - Rolling style numbering (the most recent is always #0 then #1, ..., #N).
- Sequence - Sequence style numbering.
The most recent archive has the highest number.
- Date     - Date style numbering.
The date is formatted according to the value of archiveDateFormat.
             Warning: combining this mode with archiveAboveSize is not supported.
Archive files are not merged.
- DateAndSequence - Combination of Date and Sequence .Archives will be stamped with the prior period
                    (Year, Month, Day) datetime.
The most recent archive has the highest number
                    (in combination with the date).
The date is formatted according to the value of archiveDateFormat.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ArchiveDateFormat
Specifies the date format used for archive numbering.
Default format depends on the archive period.
This option works only when the "ArchiveNumbering" parameter is set to Date or DateAndSequence

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ArchiveEvery
Specifies wheter to automatically archive log files every time the specified time passes.
Possible values are:
Day - Archive daily.
Hour - Archive every hour.
Minute - Archive every minute.
Month - Archive every month.
None - Don't archive based on time.
Year - Archive every year.
Sunday - Archive every Sunday.
Introduced in NLog 4.4.4.
Monday - Archive every Monday.
Introduced in NLog 4.4.4.
Tuesday - Archive every Tuesday.
Introduced in NLog 4.4.4.
Wednesday - Archive every Wednesday.
Introduced in NLog 4.4.4.
Thursday - Archive every Thursday.
Introduced in NLog 4.4.4.
Friday - Archive every Friday.
Introduced in NLog 4.4.4.
Saturday - Archive every Saturday.
Introduced in NLog 4.4.4.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MaxArchiveFiles
Specifies the maximum number of archive files that should be kept.
If MaxArchiveFiles is less or equal to 0, old files aren't deleted

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -EnableArchiveFileCompression
Specifies whether to compress the archive files into the zip files.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
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

### NLog.Targets.FileTarget

## NOTES
The New-NlogFileTarget CmdLet does not support all properties supported by the native NLog
FileTarget.
However those properties can be changed/added later on the returned object.

## RELATED LINKS
