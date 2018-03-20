[![Build status](https://ci.appveyor.com/api/projects/status/rrb6quib6y72qjcg/branch/master?svg=true)](https://ci.appveyor.com/project/MKoster/PSNlog/branch/master)


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

    The Module hasn't been published to Powershell Gallery yet.

### Manual Install

    Import-Module PSNlog

## Add logging to scripts/modules

### Quickly add logging capabilities to existing scripts/modules

The easiest and quickest way to make use of this requires two easy steps

1. Install the Module
2. Create a simple configuration for NLog and redirect native functions.

```
    Import-Module PSNlog
    Enable-NLogLogging -FilePath 'C:\Temp\MyLogging.log' -MinimumLevel 'Debug' -RedirectMessages
```

This will create a very simple standard configuration, which allows to write log messages to the specified Log path. In this sample *'C:\Temp\MyLogging.log'*. The **RedirectMessages** parameter will implement a little trick that basically writes the content of every call to **Write-Verbose**, **Write-Warning** and **Write-Error** into the log file as well.

On default, messages written by **Write-Verbose** will have a log level of **Debug**, **Write-Warning** a log level of **Warn** and **Write-Error** a log level of **Error**. Please see the [NLog Wiki](https://github.com/NLog/NLog/wiki/Configuration-file#log-levels) for more details about the different log levels.

### Implement more complex logging

TBD

## Contributors

* [Maik Koster](https://github.com/MaikKoster)

## License

* see [LICENSE](LICENSE.md) file

## Contact

* Twitter: [@Maik_Koster](https://twitter.com/Maik_Koster)
* Blog: [MaikKoster.com](http://MaikKoster.com/)
