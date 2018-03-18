<#
    .SYNOPSIS
        Converts array to a Powershell string representing the array as a codeblock.
    .DESCRIPTION
        Converts array to a Powershell string representing the array as a codeblock.
    .PARAMETER Array
        Array to convert.
    .PARAMETER Flatten
        No newlines in output.
    .EXAMPLE
        $test = @('a','b','c')
        Convert-ArrayToString $test
        Description
        -----------
        Outputs the following to the screen:
        @(
            'a',
            'b',
            'c'
        )
    .NOTES
        None
    .LINK
        None
    .LINK
        None
#>
function Script:Convert-ArrayToString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,Position=0)]
        [AllowEmptyCollection()]
        [Array]$Array,

        [Parameter(Mandatory)]
        [switch]$Flatten
    )

    begin{
        if($Flatten) {
            $Mode = 'Append'
        } else {
            $Mode = 'AppendLine'
        }

        if($Flatten -or $Array.Count -eq 0) {
            $Indenting = ''
            $RecursiveIndenting = ''
        } else {
            $Indenting = '    '
            $RecursiveIndenting = '    ' * (Get-PSCallStack).Where({$_.Command -match 'Convert-ArrayToString|Convert-HashToSTring' -and $_.InvocationInfo.CommandOrigin -eq 'Internal' -and $_.InvocationInfo.Line -notmatch '\$This'}).Count
        }
    }

    process{
        $StringBuilder = [System.Text.StringBuilder]::new()

        if($Array.Count -ge 1) {
            [void]$StringBuilder.$Mode("@(")
        } else {
            [void]$StringBuilder.Append("@(")
        }

        for($i = 0; $i -lt $Array.Count; $i++) {
            $Item = $Array[$i]

            if($Item -is [String]) {
                [void]$StringBuilder.Append($Indenting + $RecursiveIndenting + "'$Item'")
            } elseif ($Item -is [int] -or $Value -is [double]) {
                [void]$StringBuilder.Append($Indenting + $RecursiveIndenting + "$($Item.ToString())")
            } elseif ($Item -is [bool]) {
                [void]$StringBuilder.Append($Indenting + $RecursiveIndenting + "`$$Item")
            } elseif ($Item -is [array]) {
                $Value = Convert-ArrayToString -Array $Item -Flatten:$Flatten

                [void]$StringBuilder.Append($Indenting + $RecursiveIndenting + $Value)
            } elseif ($Item -is [hashtable]) {
                $Value = Convert-HashToSTring -Hashtable $Item -Flatten:$Flatten

                [void]$StringBuilder.Append($Indenting + $RecursiveIndenting + $Value)
            } else {
                throw "Array element is not of known type."
            }

            if($i -lt ($Array.Count - 1)) {
                [void]$StringBuilder.$Mode(', ')
            } elseif (-not $Flatten) {
                [void]$StringBuilder.AppendLine('')
            }
        }

        [void]$StringBuilder.Append($RecursiveIndenting + ')')

        $StringBuilder.ToString()
    }
}