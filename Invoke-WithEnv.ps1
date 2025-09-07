<#
Cross-platform `env`
#>
function Invoke-WithEnv {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'ScriptSet', Position = 1)]
        [Parameter(Mandatory, ParameterSetName = 'ScriptSetPrepend', Position = 0)]
        [Parameter(Mandatory, ParameterSetName = 'ScriptSetAppend', Position = 0)]
        [Parameter(Mandatory, ParameterSetName = 'ScriptSetPrependAppend', Position = 0)]
        [Parameter(Mandatory, ParameterSetName = 'ScriptPrepend', Position = 0)]
        [Parameter(Mandatory, ParameterSetName = 'ScriptAppend', Position = 0)]
        [Parameter(Mandatory, ParameterSetName = 'ScriptPrependAppend', Position = 0)]
        [scriptblock] $ScriptBlock,

        [Parameter(Mandatory, ParameterSetName = 'ScriptSet', Position = 0)]
        [Parameter(Mandatory, ParameterSetName = 'ScriptSetPrepend')]
        [Parameter(Mandatory, ParameterSetName = 'ScriptSetAppend')]
        [Parameter(Mandatory, ParameterSetName = 'ScriptSetPrependAppend')]
        [hashtable] $Set,

        [Parameter(Mandatory, ParameterSetName = 'ScriptSetPrepend')]
        [Parameter(Mandatory, ParameterSetName = 'ScriptSetPrependAppend')]
        [Parameter(Mandatory, ParameterSetName = 'ScriptPrepend')]
        [Parameter(Mandatory, ParameterSetName = 'ScriptPrependAppend')]
        [hashtable] $Prepend,

        [Parameter(Mandatory, ParameterSetName = 'ScriptSetAppend')]
        [Parameter(Mandatory, ParameterSetName = 'ScriptSetPrependAppend')]
        [Parameter(Mandatory, ParameterSetName = 'ScriptAppend')]
        [Parameter(Mandatory, ParameterSetName = 'ScriptPrependAppend')]
        [hashtable] $Append
    )

    $callerErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = [Management.Automation.ActionPreference]::Stop

    if ($PSCmdlet.ParameterSetName -eq 'Default') {
        Get-Item Env:*
        return
    }

    $keys = ($Set.Keys + $Prepend.Keys + $Append.Keys).Where({ $_ })
    $oldEnv = @{}
    foreach ($name in $keys) {
        $oldEnv[$name] = (Get-Item -LiteralPath "Env:$name" -ErrorAction Ignore).Value
    }

    try {
        foreach ($var in ${Set}?.GetEnumerator()) {
            Set-Item -LiteralPath "Env:$($var.Name)" -Value $var.Value
        }

        foreach ($var in ${Prepend}?.GetEnumerator()) {
            $envvar = (Get-Item -LiteralPath "Env:$($var.Name)" -ErrorAction Ignore).Value
            # ForEach+Where == flatten and exclude null/empty
            $value = ($var.Value, $envvar).ForEach({$_}).Where({$_}) -join [IO.Path]::PathSeparator
            Set-Item -LiteralPath "Env:$($var.Name)" -Value $value
        }

        foreach ($var in ${Append}?.GetEnumerator()) {
            $envvar = (Get-Item -LiteralPath "Env:$($var.Name)" -ErrorAction Ignore).Value
            # ForEach+Where == flatten and exclude null/empty
            $value = ($envvar, $var.Value).ForEach({$_}).Where({$_}) -join [IO.Path]::PathSeparator
            Set-Item -LiteralPath "Env:$($var.Name)" -Value $value
        }

        & $ScriptBlock
    }
    catch {
        $global:Error.RemoveAt(0)
        Write-Error $_ -ErrorAction $callerErrorActionPreference
    }
    finally {
        foreach ($var in $oldEnv.GetEnumerator()) {
            Set-Item -LiteralPath "Env:$($var.Name)" -Value $var.Value
        }
    }
}

New-Alias env Invoke-WithEnv
