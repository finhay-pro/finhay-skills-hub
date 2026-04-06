param([Parameter(Mandatory)][string]$Skill)

$ErrorActionPreference = "Stop"
$Repo = "finhay-pro/finhay-skills-hub"; $Branch = "main"
$Raw  = "https://raw.githubusercontent.com/$Repo/$Branch"
$Api  = "https://api.github.com/repos/$Repo"
$Ttl  = 12 * 3600
$RefEnv = Join-Path $env:USERPROFILE ".finhay\ref\.env"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
while ([System.IO.Path]::GetFileName($Root) -ne "skills") {
    $P = Split-Path -Parent $Root
    if ($P -eq $Root) { Write-Error "ERROR: skills/ not found"; exit 1 }
    $Root = $P
}
if (-not (Test-Path (Join-Path $Root "$Skill\SKILL.md"))) { Write-Error "ERROR: skill not found: $Skill"; exit 1 }

$ref = [ordered]@{}
if (Test-Path $RefEnv) {
    foreach ($line in Get-Content $RefEnv) {
        if ($line -match '^\s*([A-Z_][A-Z0-9_]*)\s*=\s*(.+?)\s*$') { $ref[$Matches[1]] = $Matches[2] }
    }
}

$now   = [System.DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$token = $Skill.ToUpper() -replace '[^A-Z0-9]+', '_'
$SK    = "SKILL_${token}_SYNC_AT"

$sharedStale = ($now - [long](if ($ref["SHARED_SYNC_AT"]) { $ref["SHARED_SYNC_AT"] } else { 0 })) -gt $Ttl
$skillStale  = ($now - [long](if ($ref[$SK])               { $ref[$SK] }               else { 0 })) -gt $Ttl

if (-not $sharedStale -and -not $skillStale) { Write-Host "$Skill`: up-to-date"; exit 0 }

$blobs = (Invoke-RestMethod "$Api/git/trees/${Branch}?recursive=1").tree | Where-Object { $_.type -eq "blob" }

function Sync-Component([string]$Name, [string]$Dest, [string]$Prefix) {
    $ver = try { (Invoke-WebRequest "$Raw/skills/$Prefix/.version" -UseBasicParsing).Content.Trim() } catch { "unknown" }
    $tmp = Join-Path ([System.IO.Path]::GetTempPath()) "sync-$([System.IO.Path]::GetRandomFileName())"
    New-Item -ItemType Directory -Path $tmp | Out-Null
    try {
        # Download files, defer symlinks to after copy
        $symlinks = @()
        $blobs | Where-Object { $_.path -like "skills/$Prefix/*" } | ForEach-Object {
            $rel = $_.path -replace '^skills/', ''
            $out = Join-Path $tmp $rel
            New-Item -ItemType Directory -Path (Split-Path $out) -Force | Out-Null
            if ($_.mode -eq "120000") {
                $symlinks += @{ Rel = $rel; Target = (Invoke-WebRequest "$Raw/$($_.path)" -UseBasicParsing).Content.Trim() }
            } else {
                Invoke-WebRequest "$Raw/$($_.path)" -OutFile $out -UseBasicParsing
            }
        }
        if (Test-Path $Dest) { Remove-Item $Dest -Recurse -Force }
        Copy-Item (Join-Path $tmp $Prefix) $Dest -Recurse
        # Create symlinks at final destination
        foreach ($sl in $symlinks) {
            $link = Join-Path $Dest ($sl.Rel -replace "^$Prefix/", '')
            if (Test-Path $link) { Remove-Item $link -Force }
            try { New-Item -ItemType SymbolicLink -Path $link -Target $sl.Target -Force | Out-Null }
            catch {
                $absTarget = [System.IO.Path]::GetFullPath((Join-Path (Split-Path $link) $sl.Target))
                cmd /c mklink /J "`"$link`"" "`"$absTarget`"" 2>$null | Out-Null
            }
        }
        Write-Host "${Name}: synced ($ver)"
    } finally { if (Test-Path $tmp) { Remove-Item $tmp -Recurse -Force } }
}

if ($sharedStale) { Sync-Component "_shared" (Join-Path $Root "_shared") "_shared" }
if ($skillStale)  { Sync-Component $Skill   (Join-Path $Root $Skill)    $Skill }

if ($sharedStale) { $ref["SHARED_SYNC_AT"] = $now }
if ($skillStale)  { $ref[$SK] = $now }
$tmp2 = "$RefEnv.tmp"
($ref.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) | Set-Content $tmp2 -Encoding UTF8
Move-Item -Force $tmp2 $RefEnv
