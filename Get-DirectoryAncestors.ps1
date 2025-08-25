<#
Lists all parent directories, including the InputObject, until it reaches the root directory (or drive).
#>
function Get-DirectoryAncestors {

    [OutputType([IO.DirectoryInfo])]
    param(
        [ValidateNotNull()]
        [Parameter(Position = 0, ValueFromPipeline)]
        [IO.DirectoryInfo] $InputObject = $PWD.Path
    )

    $current = $InputObject

    while ($current) {
        Write-Output $current
        $current = $current.Parent
    }
}
