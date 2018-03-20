$Public  = @( Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -ErrorAction SilentlyContinue )

foreach($import in @($Public + $Private)) {
    try {
        . $import.fullname
    } catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $Public.Basename

# Create a logger instance in module scope
$Script:Logger = Get-NLogLogger -LoggerName 'PSNLog'

# Create a 'scriptroot' variable based on the script file importing the module or the current location
# This eases defining a proper log path
Set-ScriptRoot

# Add CMTrace Layout renderer
Add-CMTraceLayoutRenderer