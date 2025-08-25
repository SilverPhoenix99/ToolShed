
function Invoke-WithEnv {

    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [hashtable] $EnvVars,

        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [scriptblock] $Script
    )

    $oldEnv = @{}
    foreach ($name in $EnvVars.Keys) {
        $oldEnv[$name] = (Get-Item "Env:$name" -ErrorAction SilentlyContinue).Value
    }

    try {
        foreach ($var in $EnvVars.GetEnumerator()) {
            Set-Item "Env:$($var.Name)" $var.Value
        }

        & $Script
    }
    finally {
        foreach ($var in $oldEnv.GetEnumerator()) {
            Set-Item "Env:$($var.Name)" $var.Value
        }
    }
}

New-Alias env Invoke-WithEnv
