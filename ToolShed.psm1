
$ErrorActionPreference = 'Stop'

$scriptName = (Get-Item $PSCommandPath).BaseName

$psd1 = Get-Content (Join-Path $PSScriptRoot "$scriptName.psd1") -Raw `
    | Invoke-Expression

$files = $psd1.VariablesToExport + $psd1.FunctionsToExport

Get-ChildItem $PSScriptRoot -Filter *.ps1 `
    | Where-Object BaseName -In $files `
    | ForEach-Object { . $_ }

Export-ModuleMember `
    -Variable $psd1.VariablesToExport `
    -Function $psd1.FunctionsToExport `
    -Alias    $psd1.AliasesToExport
