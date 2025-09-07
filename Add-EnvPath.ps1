
# Appends $Path to the variable referenced by $Variable,
# if it's an existing directory,
# and it's not already included.

function Add-EnvPath {
    param(
        [ValidateNotNullOrEmpty()]
        [ArgumentCompleter({
            param($cmd, $param, $wordToComplete)
            (Get-ChildItem Env:).Key -like "${wordToComplete}*"
        })]
        [string] $Variable = 'PATH',

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string[]] $Path,

        [switch] $PassThru,
        [switch] $Prepend
    )

    begin {
        [string[]] $allPaths = @()
    }
    process {
        $allPaths += $Path
    }
    end {

        $callerErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

        try {
            if ($Variable -notlike 'Env:*') {
                $Variable = "Env:$Variable"
            }

            $envValue = Get-Content $Variable -ErrorAction Ignore
            $envPaths = if ($null -ne $envValue) {
                $envValue -split [IO.Path]::PathSeparator
            }

            $filteredPaths = $allPaths `
                | Where-Object { Test-Path -LiteralPath $_ -PathType Container } `
                | Where-Object { $_ -notin $envPaths }

            if (!$filteredPaths) {
                return
            }

            if ($Prepend) {
                $envPaths = ($filteredPaths, $envPaths)
            }
            else {
                $envPaths = ($envPaths, $filteredPaths)
            }

            # ForEach+Where == flatten and exclude null/empty
            $envValue = $envPaths.ForEach({$_}).Where({$_}) -join [IO.Path]::PathSeparator

            Set-Content $Variable -Value $envValue -PassThru:$PassThru
        }
        catch {
            $global:Error.RemoveAt(0)
            Write-Error $_ -ErrorAction $callerErrorActionPreference
        }
    }
}
