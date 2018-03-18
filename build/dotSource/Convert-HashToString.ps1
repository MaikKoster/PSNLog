function Script:Convert-HashToString {
    [cmdletbinding()]
    param  (
        [Parameter(Mandatory=$true,Position=0)]
        [Hashtable]$Hashtable,

        [Parameter(Mandatory=$False)]
        [switch]$Flatten
    )

    begin {
        if($Flatten -or $Hashtable.Keys.Count -eq 0) {
            $Mode = 'Append'
            $Indenting = ''
            $RecursiveIndenting = ''
        } else {
            $Mode = 'Appendline'
            $Indenting = '    '
            $RecursiveIndenting = '    ' * (Get-PSCallStack).Where({$_.Command -match 'Convert-ArrayToString|Convert-HashToSTring' -and $_.InvocationInfo.CommandOrigin -eq 'Internal' -and $_.InvocationInfo.Line -notmatch '\$This'}).Count
        }
    }

    process {
        $StringBuilder = [System.Text.StringBuilder]::new()

        if($Hashtable.Keys.Count -ge 1) {
            [void]$StringBuilder.$Mode("@{")
        } else {
            [void]$StringBuilder.Append("@{")
        }

        foreach($Key in $Hashtable.Keys) {
            $Value = $Hashtable[$Key]

            if($Key -match '\s') {
                $Key = "'$Key'"
            }

            if($Value -is [String]) {
                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = '$Value'")
            } elseif ($Value -is [int] -or $Value -is [double]) {
                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = $($Value.ToString())")
            } elseif($Value -is [bool]) {
                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = `$$Value")
            } elseif($Value -is [array]) {
                $Value = Convert-ArrayToString -Array $Value -Flatten:$Flatten

                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = $Value")
            } elseif($Value -is [hashtable]) {
                $Value = Convert-HashToSTring -Hashtable $Value -Flatten:$Flatten
                [void]$StringBuilder.$Mode($Indenting + $RecursiveIndenting + "$Key = $Value")
            } else {
                throw "Key value is not of known type."
            }

            if($Flatten) {
                [void]$StringBuilder.Append("; ")
            }
        }

        [void]$StringBuilder.Append($RecursiveIndenting + "}")

        $StringBuilder.ToString().Replace("; }",'}')
    }
}