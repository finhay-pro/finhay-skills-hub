$ErrorActionPreference = "Stop"

function Invoke-FinhayInstall {
    Write-Host ""
    Write-Host "  Finhay MCP Server — Cai dat cho Claude Desktop"
    Write-Host ""

    # --- Check & install Node.js ---
    $NodeExe = $null
    $NodeInstallDir = Join-Path $env:USERPROFILE ".finhay\nodejs"
    $PortableNode = Join-Path $NodeInstallDir "node.exe"

    if (Get-Command node -ErrorAction SilentlyContinue) {
        $NodeExe = "node"
    } elseif (Test-Path $PortableNode) {
        $NodeExe = $PortableNode
        $env:PATH = "$NodeInstallDir;$env:PATH"
    } else {
        Write-Host "  Node.js chua duoc cai dat. Dang tai ban portable (khong can quyen admin)..."
        Write-Host ""

        $TmpDir = Join-Path $env:TEMP "finhay-node-install"
        New-Item -ItemType Directory -Force -Path $TmpDir | Out-Null

        # Use portable zip — no admin rights needed
        $Arch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
        $NodeZip = Join-Path $TmpDir "node.zip"
        $NodeUrl = "https://nodejs.org/dist/v22.14.0/node-v22.14.0-win-$Arch.zip"

        Write-Host "  Dang tai Node.js tu nodejs.org ($Arch)..."
        Invoke-WebRequest -Uri $NodeUrl -OutFile $NodeZip -UseBasicParsing

        Write-Host "  Dang giai nen Node.js vao $NodeInstallDir..."
        if (Test-Path $NodeInstallDir) {
            Remove-Item -Recurse -Force $NodeInstallDir -ErrorAction SilentlyContinue
        }
        New-Item -ItemType Directory -Force -Path $NodeInstallDir | Out-Null

        Expand-Archive -Path $NodeZip -DestinationPath $TmpDir -Force

        # Move contents of extracted node-vXX folder to NodeInstallDir
        $ExtractedFolder = Get-ChildItem -Path $TmpDir -Directory | Where-Object { $_.Name -like "node-v*" } | Select-Object -First 1
        if (-not $ExtractedFolder) {
            throw "Khong tim thay thu muc Node.js sau khi giai nen."
        }
        Get-ChildItem -Path $ExtractedFolder.FullName | Move-Item -Destination $NodeInstallDir -Force

        Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue

        if (-not (Test-Path $PortableNode)) {
            throw "Khong the cai Node.js. Hay cai thu cong tai https://nodejs.org"
        }

        $NodeExe = $PortableNode
        $env:PATH = "$NodeInstallDir;$env:PATH"

        # Add to user PATH permanently
        $CurrentUserPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
        if ($CurrentUserPath -notlike "*$NodeInstallDir*") {
            [System.Environment]::SetEnvironmentVariable("PATH", "$NodeInstallDir;$CurrentUserPath", "User")
        }

        $NodeVersion = & $NodeExe -v
        Write-Host "  Node.js $NodeVersion da duoc cai dat."
        Write-Host ""
    }

    # --- Credentials ---
    $CredsDir = Join-Path $env:USERPROFILE ".finhay\credentials"
    $CredsFile = Join-Path $CredsDir ".env"

    $ApiKey = ""
    $ApiSecret = ""

    if (Test-Path $CredsFile) {
        $Content = Get-Content $CredsFile -Raw
        $KeyMatch = [regex]::Match($Content, 'FINHAY_API_KEY=(.+)')
        $SecretMatch = [regex]::Match($Content, 'FINHAY_API_SECRET=(.+)')

        if ($KeyMatch.Success -and $SecretMatch.Success) {
            $ExistingKey = $KeyMatch.Groups[1].Value.Trim()
            $ExistingSecret = $SecretMatch.Groups[1].Value.Trim()
            $MaskedKey = $ExistingKey.Substring(0, [Math]::Min(8, $ExistingKey.Length)) + "***"

            Write-Host "  Tim thay credentials tai $CredsFile"
            Write-Host "  API Key: $MaskedKey"
            Write-Host ""
            $Reuse = Read-Host "  Su dung credentials nay? (Y/n)"
            if ($Reuse -ne "n") {
                $ApiKey = $ExistingKey
                $ApiSecret = $ExistingSecret
            }
            Write-Host ""
        }
    }

    if (-not $ApiKey) {
        Write-Host "  Tao API Key tai: https://www.finhay.com.vn/finhay-skills"
        Write-Host ""
        $ApiKey = Read-Host "  API Key"
        if (-not $ApiKey) {
            throw "API Key khong duoc de trong."
        }

        $SecureSecret = Read-Host "  API Secret" -AsSecureString
        $ApiSecret = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureSecret)
        )
        if (-not $ApiSecret) {
            throw "API Secret khong duoc de trong."
        }

        # Save credentials
        New-Item -ItemType Directory -Force -Path $CredsDir | Out-Null
        @"
FINHAY_API_KEY=$ApiKey
FINHAY_API_SECRET=$ApiSecret
FINHAY_BASE_URL=https://open-api.fhsc.com.vn
"@ | Set-Content -Path $CredsFile -Encoding UTF8

        Write-Host ""
        Write-Host "  Credentials: $CredsFile"
        Write-Host ""
    }

    # --- Claude Desktop config ---
    # Try all possible Claude Desktop paths (Microsoft Store, standard installer, and Anthropic's newer locations)
    $StorePath = Join-Path $env:LOCALAPPDATA "Packages\Claude_pzs8sxrjxfjjc\LocalCache\Roaming\Claude\claude_desktop_config.json"
    $StandardPath = Join-Path $env:APPDATA "Claude\claude_desktop_config.json"

    # Prefer existing config file; if neither exists, prefer Store path if its parent dir exists, else standard
    $ConfigPath = $null
    if (Test-Path $StorePath) {
        $ConfigPath = $StorePath
    } elseif (Test-Path $StandardPath) {
        $ConfigPath = $StandardPath
    } elseif (Test-Path (Split-Path $StorePath -Parent)) {
        $ConfigPath = $StorePath
    } else {
        $ConfigPath = $StandardPath
    }

    Write-Host "  Ghi config vao: $ConfigPath"

    $ConfigDir = Split-Path $ConfigPath -Parent
    if (-not (Test-Path $ConfigDir)) {
        New-Item -ItemType Directory -Force -Path $ConfigDir | Out-Null
    }

    # Build full config as hashtable, merge with existing if any
    $ConfigHash = @{ mcpServers = @{} }

    if (Test-Path $ConfigPath) {
        try {
            $ExistingJson = Get-Content $ConfigPath -Raw -ErrorAction Stop
            if ($ExistingJson.Trim()) {
                $Existing = $ExistingJson | ConvertFrom-Json -ErrorAction Stop
                # Convert PSCustomObject to hashtable recursively
                $ConfigHash = @{}
                foreach ($prop in $Existing.PSObject.Properties) {
                    if ($prop.Name -eq "mcpServers") {
                        $mcpHash = @{}
                        foreach ($server in $prop.Value.PSObject.Properties) {
                            $serverHash = @{}
                            foreach ($p in $server.Value.PSObject.Properties) {
                                $serverHash[$p.Name] = $p.Value
                            }
                            $mcpHash[$server.Name] = $serverHash
                        }
                        $ConfigHash["mcpServers"] = $mcpHash
                    } else {
                        $ConfigHash[$prop.Name] = $prop.Value
                    }
                }
                if (-not $ConfigHash.ContainsKey("mcpServers")) {
                    $ConfigHash["mcpServers"] = @{}
                }
            }
        } catch {
            Write-Host "  Canh bao: Khong doc duoc config cu, se tao moi. Loi: $($_.Exception.Message)"
            $ConfigHash = @{ mcpServers = @{} }
        }
    }

    # Add/update finhay entry
    if ($ConfigHash["mcpServers"].ContainsKey("finhay")) {
        Write-Host "  Entry 'finhay' da ton tai, cap nhat lai."
    }
    $ConfigHash["mcpServers"]["finhay"] = @{
        command = "npx"
        args = @("-y", "finhay-mcp-server")
    }

    # Write config
    $JsonOutput = $ConfigHash | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($ConfigPath, $JsonOutput, [System.Text.Encoding]::UTF8)

    Write-Host "  Claude Desktop config: $ConfigPath"
    Write-Host ""
    Write-Host "  Da cai dat thanh cong!"
    Write-Host "  Hay khoi dong lai Claude Desktop de su dung."
    Write-Host ""
}

try {
    Invoke-FinhayInstall
} catch {
    Write-Host ""
    Write-Host "  Loi: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
}
