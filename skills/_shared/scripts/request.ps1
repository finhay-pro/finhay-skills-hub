param([Parameter(Mandatory)][string]$Method, [Parameter(Mandatory)][string]$Endpoint, [string]$Query = "")

$ErrorActionPreference = "Stop"
$CredsPath = Join-Path $env:USERPROFILE ".finhay\credentials\.env"

if (-not (Test-Path $CredsPath)) { [Console]::Error.WriteLine("ERROR: $CredsPath not found"); exit 1 }

foreach ($line in Get-Content $CredsPath) {
    if ($line -match '^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.+?)\s*$') {
        [System.Environment]::SetEnvironmentVariable($Matches[1], $Matches[2], 'Process')
    }
}

$ApiKey    = $env:FINHAY_API_KEY
$ApiSecret = $env:FINHAY_API_SECRET
$BaseUrl   = if ($env:FINHAY_BASE_URL) { $env:FINHAY_BASE_URL } else { "https://open-api.fhsc.com.vn" }

if (-not $ApiKey -or -not $ApiSecret) { [Console]::Error.WriteLine("ERROR: FINHAY_API_KEY and FINHAY_API_SECRET required."); exit 1 }

$Ts        = [System.DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds().ToString()
$NonceBytes = New-Object byte[] 16; [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($NonceBytes)
$Nonce     = ($NonceBytes | ForEach-Object { $_.ToString("x2") }) -join ""
$Hmac      = New-Object System.Security.Cryptography.HMACSHA256
$Hmac.Key  = [System.Text.Encoding]::UTF8.GetBytes($ApiSecret)
$Sig       = ($Hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes("$Ts`n$Method`n$Endpoint`n")) | ForEach-Object { $_.ToString("x2") }) -join ""
$Url       = "${BaseUrl}${Endpoint}"; if ($Query) { $Url += "?$Query" }

try {
    $Res  = Invoke-WebRequest -Uri $Url -Method $Method -TimeoutSec 30 -UseBasicParsing -Headers @{
        "X-FH-APIKEY" = $ApiKey; "X-FH-TIMESTAMP" = $Ts; "X-FH-NONCE" = $Nonce; "X-FH-SIGNATURE" = $Sig
    }
    $Body = $Res.Content
    $Ec   = [string]($Body | ConvertFrom-Json).error_code
    if ($Ec -and $Ec -ne "0") { [Console]::Error.WriteLine("ERROR: error_code=$Ec`n$Body"); exit 1 }
    Write-Output $Body
} catch {
    $Code = $null; try { $Code = $_.Exception.Response.StatusCode.value__ } catch {}
    [Console]::Error.WriteLine("ERROR: $(if ($Code -and $Code -ge 400) { "HTTP $Code" } else { $_.Exception.Message })")
    exit 1
}
