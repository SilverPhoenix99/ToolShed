function ConvertFrom-Base64 {

    param(
        [Parameter(Position=0, Mandatory, ValueFromPipeline)]
        [string] $EncodedText,

        [switch] $AsByteArray
    )

    $padding = 3 - ($EncodedText.Length + 3) % 4
    $decodedBytes = [Convert]::FromBase64String($EncodedText + ('=' * $padding))

    if ($AsByteArray) {
        return $decodedBytes
    }

    [Text.Encoding]::UTF8.GetString($decodedBytes)
}
