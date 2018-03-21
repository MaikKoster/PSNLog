﻿# PSNLog Module Release History

## [0.2.3] - Unreleased

### Added

- Added tests for the module.

### Changed

- Updated the ReadMe with details on how to make use of the cmtrace Layout Renderer

### Fixed

- Fixed typo in the Write-NlogVerbose, Write-NLogHost, Write-NLogWarning, and Write-NLogError, which prevented them to properly foward the original message.
- Fixed the New-NLogTarget CmdLet to properly use the supplied name.

## [0.2.2] - 2018-03-21

Initial public release, supporting the following actions:

- Reference NLog.dll
- Create Logger
- Create Rules
- Create Target
- Read and apply config file
- Support SimpleConfiguration
- Redirect existing Write-Verbose, Write-Warning, Write-Error calls