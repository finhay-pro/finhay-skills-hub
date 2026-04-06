$ErrorActionPreference = "Stop"
$CredsPath  = Join-Path $env:USERPROFILE ".finhay\credentials\.env"
$RequestPs1 = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "request.ps1"
$PsExe      = if (Get-Command pwsh -ErrorAction SilentlyContinue) { "pwsh" } else { "powershell" }

if (-not (Test-Path $CredsPath)) { Write-Error "ERROR: $CredsPath not found"; exit 1 }

foreach ($line in Get-Content $CredsPath) {
    if ($line -match '^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.+?)\s*$') {
        [System.Environment]::SetEnvironmentVariable($Matches[1], $Matches[2], 'Process')
    }
}

if ($env:USER_ID -and ($env:SUB_ACCOUNT_NORMAL -or $env:SUB_ACCOUNT_MARGIN)) { Write-Host "✅ Credentials already set"; exit 0 }
if (-not $env:FINHAY_API_KEY -or -not $env:FINHAY_API_SECRET) { Write-Error "ERROR: FINHAY_API_KEY and FINHAY_API_SECRET required"; exit 1 }

function req([string]$M, [string]$E) {
    $out = & $PsExe -NoProfile -File "$RequestPs1" $M $E 2>$null
    if ($LASTEXITCODE -ne 0) { throw "request failed: $M $E" }
    return ($out -join "`n") | ConvertFrom-Json
}

$UserId      = (req GET /users/v1/users/me).result.user_id
if (-not $UserId) { Write-Error "ERROR: user_id missing in response"; exit 1 }
$subAccounts = (req GET "/users/v1/users/$UserId/sub-accounts").result

$env_data = [ordered]@{}
foreach ($line in Get-Content $CredsPath) {
    if ($line -match '^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.+?)\s*$') { $env_data[$Matches[1]] = $Matches[2] }
}

$env_data["USER_ID"] = $UserId
foreach ($sba in $subAccounts) {
    $t = if ($sba.type) { $sba.type.ToUpper() } else { "UNKNOWN" }
    $env_data["SUB_ACCOUNT_$t"] = [string]$sba.id
    $env_data["SUB_ACCOUNT_EXT_$t"] = [string]$sba.sub_account_ext
}

$tmp = "$CredsPath.tmp"
($env_data.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) | Set-Content $tmp -Encoding UTF8
Move-Item -Force $tmp $CredsPath
Write-Host "✅ Credentials updated successfully"
