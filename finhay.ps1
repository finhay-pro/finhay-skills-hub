$CredsDir = Join-Path $HOME ".finhay\credentials"
$CredsFile = Join-Path $CredsDir ".env"
$RefEnv = Join-Path $HOME ".finhay\ref\.env"
$BaseUrlDefault = "https://open-api.fhsc.com.vn"
$Repo = "finhay-pro/finhay-skills-hub"
$Branch = "main"

function Show-Help {
    Write-Host "Usage: .\finhay.ps1 {auth|doctor|infer|request|sync}"
}

function Request-Internal {
    param($Method, $Endpoint, $Query, $Body)
    
    $AK = $env:FINHAY_API_KEY
    $AS = $env:FINHAY_API_SECRET
    $BU = $env:FINHAY_BASE_URL
    $UI = $env:USER_ID

    if (Test-Path $CredsFile) {
        $FileData = ConvertFrom-StringData (Get-Content $CredsFile -Raw)
        if (-not $AK) { $AK = $FileData.FINHAY_API_KEY }
        if (-not $AS) { $AS = $FileData.FINHAY_API_SECRET }
        if (-not $BU) { $BU = $FileData.FINHAY_BASE_URL }
        if (-not $UI) { $UI = $FileData.USER_ID }
    }

    if (-not $AK -or -not $AS) { return }
    if (-not $BU) { $BU = $BaseUrlDefault }
    $TS = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
    $Nonce = [Guid]::NewGuid().ToString("n").Substring(0, 32)
    $Payload = "$TS`n$Method`n$Endpoint`n"
    if ($Body) { $Payload += "$Body`n" }
    $Hmac = New-Object System.Security.Cryptography.HMACSHA256
    $Hmac.Key = [System.Text.Encoding]::UTF8.GetBytes($AS)
    $SigBytes = $Hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Payload))
    $Sig = [BitConverter]::ToString($SigBytes).Replace("-", "").ToLower()
    $Url = "$BU$Endpoint"
    if ($Query) { $Url += "?$Query" }
    $Headers = @{ 
        "X-FH-APIKEY" = $AK; 
        "X-FH-USER-ID" = $UI;
        "X-FH-TIMESTAMP" = $TS; 
        "X-FH-NONCE" = $Nonce; 
        "X-FH-SIGNATURE" = $Sig 
    }
    try {
        $Params = @{ Uri = $Url; Method = $Method; Headers = $Headers; ContentType = "application/json" }
        if ($Body) { $Params.Body = $Body }
        $Resp = Invoke-RestMethod @Params
        return $Resp | ConvertTo-Json -Depth 10
    } catch {
        return
    }
}

function Cmd-Auth {
    Write-Host "Finhay API Setup"
    if (-not (Test-Path $CredsDir)) { New-Item -ItemType Directory -Path $CredsDir | Out-Null }
    $ak = Read-Host "Enter API Key"
    Write-Host -NoNewline "Enter Secret: "
    $as = ""
    while($true) {
        $key = [System.Console]::ReadKey($true)
        if ($key.Key -eq [System.ConsoleKey]::Enter) { Write-Host ""; break }
        if ($key.Key -eq [System.ConsoleKey]::Backspace) {
            if ($as.Length -gt 0) { $as = $as.Substring(0, $as.Length - 1); Write-Host -NoNewline "`b `b" }
        } else { $as += $key.KeyChar; Write-Host -NoNewline "*" }
    }
    $Content = "FINHAY_API_KEY=$ak`nFINHAY_API_SECRET=$as`nFINHAY_BASE_URL=$BaseUrlDefault"
    Set-Content -Path $CredsFile -Value $Content
    Write-Host "Saved to $CredsFile"
}

function Cmd-Doctor {
    $AK = $env:FINHAY_API_KEY
    $AS = $env:FINHAY_API_SECRET
    if (Test-Path $CredsFile) {
        try {
            $FileData = ConvertFrom-StringData (Get-Content $CredsFile -Raw)
            if (-not $AK) { $AK = $FileData.FINHAY_API_KEY }
            if (-not $AS) { $AS = $FileData.FINHAY_API_SECRET }
        } catch {}
    }

    if ($AK -and $AS) { 
        Write-Host "✅ Credentials: OK"
        $DisplayBU = if ($BU) { $BU } else { $BaseUrlDefault }
        Write-Host "🌐 Base URL: $DisplayBU"
    } else { 
        Write-Host "❌ Credentials: MISSING (Set environment variables or run auth)" 
    }
    foreach ($c in @("curl", "jq", "openssl", "xxd")) {
        if (Get-Command $c -ErrorAction SilentlyContinue) { Write-Host "✅ $c: OK" } else { Write-Host "❌ $c: MISSING" }
    }
}

function Cmd-Infer {
    $Data = Request-Internal -Method "GET" -Endpoint "/users/v1/users/me"
    $UserJson = $Data | ConvertFrom-Json
    $UserId = $UserJson.data.user_id
    
    if (-not $UserId) { 
        Write-Error "ERROR: Could not resolve USER_ID. Check your credentials."
        if ($Data) { Write-Host $Data }
        return 
    }
    
    $SbaData = Request-Internal -Method "GET" -Endpoint "/users/v1/users/$UserId/sub-accounts"
    $SbaJson = $SbaData | ConvertFrom-Json
    
    if (-not (Test-Path $CredsDir)) { New-Item -ItemType Directory -Path $CredsDir | Out-Null }
    $NewContent = if (Test-Path $CredsFile) { Get-Content $CredsFile | Where-Object { $_ -notmatch "^(USER_ID|SUB_ACCOUNT_)" } } else { @() }
    
    $NewContent += "USER_ID=$UserId"
    Write-Host "`$env:USER_ID=`"$UserId`""
    
    $Accounts = if ($SbaJson.result) { $SbaJson.result } else { $SbaJson.data }
    foreach ($acc in $Accounts) {
        if (-not $acc.type) { continue }
        $Type = $acc.type.ToString().ToUpper()
        $Id = $acc.id
        $Ext = $acc.sub_account_ext
        $NewContent += "SUB_ACCOUNT_$($Type)=$Id"
        $NewContent += "SUB_ACCOUNT_EXT_$($Type)=$Ext"
        Write-Host "`$env:SUB_ACCOUNT_$($Type)=`"$Id`""
        Write-Host "`$env:SUB_ACCOUNT_EXT_$($Type)=`"$Ext`""
    }
    Set-Content -Path $CredsFile -Value ($NewContent -join "`n")
    Write-Host "✅ Account IDs resolved and saved to $CredsFile"
}

function Cmd-Sync {
    param($Skill)
    if (-not $Skill) { exit 1 }
    Write-Host "Syncing $Skill..."
    $RawUrl = "https://raw.githubusercontent.com/$Repo/$Branch"
    $ApiUrl = "https://api.github.com/repos/$Repo/git/trees/$Branch?recursive=1"
    $Tree = Invoke-RestMethod $ApiUrl
    $Files = $Tree.tree | Where-Object { $_.path -like "skills/$Skill/*" -and $_.type -eq "blob" }
    if (-not $Files) { exit 1 }
    $Tmp = Join-Path $env:TEMP ([Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $Tmp | Out-Null
    foreach ($f in $Files) {
        $Dest = Join-Path $Tmp ($f.path.Substring("skills/".Length))
        $DestDir = Split-Path $Dest
        if (-not (Test-Path $DestDir)) { New-Item -ItemType Directory -Path $DestDir | Out-Null }
        Invoke-WebRequest -Uri "$RawUrl/$($f.path)" -OutFile $Dest
    }
    $LocalSkillPath = Join-Path "skills" $Skill
    if (-not (Test-Path "skills")) { New-Item -ItemType Directory -Path "skills" | Out-Null }
    if (Test-Path $LocalSkillPath) { Remove-Item -Path $LocalSkillPath -Recurse -Force }
    Copy-Item -Path (Join-Path $Tmp $Skill) -Destination "skills" -Recurse -Force
    New-Item -ItemType SymbolicLink -Path (Join-Path $LocalSkillPath "finhay.sh") -Target "../../finhay.sh" -Force | Out-Null
    New-Item -ItemType SymbolicLink -Path (Join-Path $LocalSkillPath "finhay.ps1") -Target "../../finhay.ps1" -Force | Out-Null
    Remove-Item -Path $Tmp -Recurse -Force
    Write-Host "✅ $Skill synced."
}

$Command = $args[0]
$ArgsList = $args[1..$args.Length]
switch ($Command) {
    "auth"    { Cmd-Auth }
    "doctor"  { Cmd-Doctor }
    "infer"   { Cmd-Infer }
    "request" { Request-Internal -Method $ArgsList[0] -Endpoint $ArgsList[1] -Query $ArgsList[2] -Body $ArgsList[3] }
    "sync"    { Cmd-Sync -Skill $ArgsList[0] }
    default   { Show-Help }
}
