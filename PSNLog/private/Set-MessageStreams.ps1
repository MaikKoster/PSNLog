function Set-MessageStreams {
    <#
        .SYNOPSIS
        Overrides Write-Verbose, Write-Host, Write-Warning and Write-Error to write to a log file.

        .DESCRIPTION
        Overrides Write-Verbose, Write-Host, Write-Warning and Write-Error to write to a log file.
        The native Cmdlets will be called as well.

        .EXAMPLE
        PS C:>Set-MessageStreams -WriteVerbose -WriteWarning -WriteError

        Redirect Write-Verbose, Write-Warning and Write-Error
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [CmdLetBinding(SupportsShouldProcess)]
    param(
        # Specifies if Write-Verbose calls should be redirected to Write-NLogVerbose
        [Parameter(ParameterSetName='Add')]
        [switch]$WriteVerbose,

        # Specifies if Write-Host calls should be redirected to Write-NLogHost
        [Parameter(ParameterSetName='Add')]
        [switch]$WriteHost,

        # Specifies if Write-Warning calls should be redirected to Write-NLogWarning
        [Parameter(ParameterSetName='Add')]
        [switch]$WriteWarning,

        # Specifies if Write-Error calls should be redirecte to Write-NLogError
        [Parameter(ParameterSetName='Add')]
        [switch]$WriteError,

        # Specifies if the alias added by this function should be removed
        [Parameter(ParameterSetName='Remove')]
        [switch]$Remove
    )

    process {
        if ($WriteVerbose.IsPresent) {
            if (-Not(Test-Path 'Alias:\Write-Verbose')) {
                New-Alias -Name 'Write-Verbose' -Value 'Write-NLogVerbose' -Scope Global
            }
        }
        if ($WriteHost.IsPresent) {
            if (-Not(Test-Path 'Alias:\Write-Host')) {
                New-Alias -Name 'Write-Host' -Value 'Write-NLogHost' -Scope Global
            }
        }
        if ($WriteWarning.IsPresent) {
            if (-Not(Test-Path 'Alias:\Write-Warning')) {
                New-Alias -Name 'Write-Warning' -Value 'Write-NLogWarning' -Scope Global
            }
        }
        if ($WriteError.IsPresent) {
            if (-Not(Test-Path 'Alias:\Write-Error')) {
                New-Alias -Name 'Write-Error' -Value 'Write-NLogError' -Scope Global
            }
        }
        if ($Remove.IsPresent){
            if (Test-Path 'Alias:\Write-Verbose') {
                Remove-Item 'Alias:\Write-Verbose' -Force
            }
            if (Test-Path 'Alias:\Write-Warning') {
                Remove-Item 'Alias:\Write-Warning' -Force
            }
            if (Test-Path 'Alias:\Write-Error') {
                Remove-Item 'Alias:\Write-Error' -Force
            }
            if (Test-Path 'Alias:\Write-Host') {
                Remove-Item 'Alias:\Write-Host' -Force
            }
        }
    }
}