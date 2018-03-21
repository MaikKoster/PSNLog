# Create a logger instance in module scope
$Script:Logger = Get-NLogLogger -LoggerName 'PSNLog'

# Create a 'scriptroot' variable based on the script file importing the module or the current location
# This eases defining a proper log path
Set-ScriptRoot

# Add CMTrace Layout renderer
Add-CMTraceLayoutRenderer