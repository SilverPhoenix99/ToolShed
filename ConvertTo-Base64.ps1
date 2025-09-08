function ConvertTo-Base64 {

    [CmdletBinding(DefaultParameterSetName = 'Text')]
    param(
        [Parameter(Position=0, Mandatory, ValueFromPipeline, ParameterSetName = 'Text')]
        [string] $Text,

        [Parameter(Position=0, Mandatory, ValueFromPipeline, ParameterSetName = 'ByteArray')]
        [byte[]] $ByteArray,

        [switch] $InsertBreakLines
    )

    begin {
        $base64Option = $InsertBreakLines `
            ? [Base64FormattingOptions]::InsertLineBreaks `
            : [Base64FormattingOptions]::None
        $bytes = [Collections.Generic.List[byte]]::new()
    }

    process {

        switch -Exact ($PSCmdlet.ParameterSetName) {
            'ByteArray' {
                $bytes.AddRange($ByteArray)
                break
            }
            default {
                $textBytes = [Text.Encoding]::UTF8.GetBytes($Text)
                [Convert]::ToBase64String($textBytes, $base64Option)
            }
        }
    }

    end {
        if ($PSCmdlet.ParameterSetName -ceq 'ByteArray') {
            [Convert]::ToBase64String($bytes.ToArray(), $base64Option)
        }
    }
}
