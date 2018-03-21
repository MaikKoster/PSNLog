# Update these to suit your PowerShell module build. These variables get dot sourced into
# the build at every run. The path root of the locations are assumed to be at the root of the
# PowerShell module project directory.

# The module we are building
$ModuleToBuild = 'PSNLog'

# Project website (used for external help cab file definition)
$ModuleWebsite = 'https://github.com/MaikKoster/PSNLog'

# Name of the folder, containing the documentation
$DocumentsFolder = "docs"

# Public functions (to be exported by file name as the function name)
$PublicFunctionSource = "public"

# Private function source
$PrivateFunctionSource = "private"

# Other module source
$OtherModuleSource = "other"

# Build tool path (these scripts are dot sourced)
$BuildToolFolder = 'build'

# Scratch path - this is where all our scratch work occurs. It will be cleared out at every run.
$ScratchFolder = 'artifacts'

# Name of the Release Notes file
$ReleaseNotesName = 'CHANGELOG.md'

# Name of the License file
$LicenseFileName = "LICENSE"

# Name of the script file used to initialize the Module
# Will be added at the very end
$InitializeFileName = "PSNLog.Initialize.ps1"