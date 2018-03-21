[![Build status](https://ci.appveyor.com/api/projects/status/rrb6quib6y72qjcg/branch/master?svg=true)](https://ci.appveyor.com/project/MKoster/PSNlog/branch/master) [![PS Gallery](https://img.shields.io/badge/install-PS%20Gallery-blue.svg)](https://www.powershellgallery.com/packages/PSNLog)

# PSNLog PowerShell module

The "PSNLog" PowerShell module is a wrapper around the famous, flexible and free open source logging for .Net component [NLog](http://nlog-project.org/).

Proper logging is a common requirement within most PowerShell scripts and modules. There are a lot of possibilities to support logging within PowerShell. However, most of them are very limited in their capabilities and/or intrusive to the script/module.

This Module allows to use all the capabilities and the flexibility of NLog with as little as two lines of PowerShell.

## Requirements

PowerShell Version 3.0+

## Third party components

1) NLog - Copyright (c) 2004-2018 Jaroslaw Kowalski <jaak@jkowalski.net>, Kim Christensen, Julian Verdurmen. Please see [License](https://github.com/NLog/NLog/blob/master/LICENSE.txt).

## Install

### PowerShell Gallery Install (Requires PowerShell v5)

```powershell
    Install-Module -Name PSNLog
```

### Manual Install

Download [PSNlog-0.2.4.zip](https://github.com/MaikKoster/PSNLog/releases/download/v0.2.4/PSNLog-0.2.4.zip) and extract the contents into `'C:\Users\[User]\Documents\WindowsPowerShell\Modules\PSNlog'` (you may have to create these directories if they don't exist.). Then run

```powershell
    Get-ChildItem 'C:\Users\[User]\Documents\WindowsPowerShell\Modules\PSNLog\' -Recurse | Unblock-File
    Import-Module PSNlog
```

## Add logging to scripts/modules

### Quickly add logging capabilities to existing scripts/modules with two lines of PowerShell code

The easiest and quickest way to make use of this requires two easy steps

1. Import the Module
2. Create a simple configuration for NLog and redirect native functions.

```powershell
    Import-Module PSNlog
    Enable-NLogLogging -FilePath 'C:\Temp\MyLogging.log' -MinimumLevel Debug -RedirectMessages
```

This will create a very simple standard configuration, which allows to write log messages to the specified Log path. In this sample `'C:\Temp\MyLogging.log'`. The **RedirectMessages** parameter will implement a little trick that basically writes the content of every call to **Write-Verbose**, **Write-Warning** and **Write-Error** into the log file as well.

On default, messages written by **Write-Verbose** will have a log level of **Debug**, **Write-Warning** a log level of **Warn** and **Write-Error** a log level of **Error**. Please see the [NLog Wiki](https://github.com/NLog/NLog/wiki/Configuration-file#log-levels) for more details about the different log levels.

You can now test the behaviour by calling

```powershell
    Write-Verbose 'This is a verbose message'
    Write-Warning 'This is a warning message'
    Write-Error 'This is an error message'
```

The Cmdlets will still write proper output as they are supposed to. If you now check the `'C:\Temp\MyLogging.log'`, you should see the messages also being logged to the log file.

### Quickly add CMTrace style logging to existing scripts/modules

The log format, that is used in the before sample, is the default format from NLog. As I'm dealing a lot with ConfigMgr, I personally prefer the log file format used by CMTrace, which is also supported by this PowerShell module. Quickly enabling this slightly more customized logging only takes a little more effort. I sequezed it into a single line so it technically still takes only two lines of PowerShell to enable the logging ;)

```powershell
    Import-Module PSNlog
    New-NLogFileTarget 'f' -FileName 'C:\Temp\Debug.log' -Layout '${cmtrace}' | Enable-NLogLogging -MinLevel Debug -RedirectMessages
```

**${cmtrace}** is the name of the new Layout Renderer, that got added by this PowerShell Module.

The rest stays the same. Your log files will now be properly formatted to be viewed with CMTrace from the ConfigMgr Toolkit. Each log entry will now even show you the script name, the function and the exact line of each log message.

### Customize logging

TBD

## Contributors

* [Maik Koster](https://github.com/MaikKoster)

## License

* see [LICENSE](LICENSE.md) file

## Contact

* Twitter: [@Maik_Koster](https://twitter.com/Maik_Koster)
* Blog: [MaikKoster.com](http://MaikKoster.com/)
