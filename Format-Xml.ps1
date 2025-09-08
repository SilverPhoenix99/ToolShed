function Format-Xml {

    param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [xml] $Document
    )

    $reader = [Xml.XmlNodeReader]::new($Document)

    try {
        $null = $reader.MoveToContent()

        return [Xml.Linq.XDocument]::Load($reader).ToString()
    }
    finally {
        $reader.Close()
    }
}

New-Alias -Name fx -Value Format-Xml
