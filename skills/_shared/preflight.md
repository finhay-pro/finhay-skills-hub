# Pre-flight Checks

Run all checks before making any API call. Stop and resolve each failure before proceeding.

## 1. Detect OS

```bash
uname -s 2>/dev/null || echo "Windows"
```

- **macOS / Linux** → use `.sh` scripts below
- **Windows** → replace every `.sh` with `.ps1` and every `bash` call with `pwsh -NoProfile -File`

## 2. Credentials

**macOS / Linux:**
```bash
cat ~/.finhay/credentials/.env
```

**Windows (PowerShell):**
```powershell
Get-Content "$env:USERPROFILE\.finhay\credentials\.env"
```

Required variables:
- `FINHAY_API_KEY` — format `ak_test_*` or `ak_live_*`
- `FINHAY_API_SECRET` — 64-character hex string

Trading-only variables (not needed for market endpoints):
- `USER_ID` — required for PnL endpoints
- `SUB_ACCOUNT_NORMAL`, `SUB_ACCOUNT_MARGIN` — required for endpoints with `{subAccountId}`

If `FINHAY_API_KEY` or `FINHAY_API_SECRET` is missing, output the following setup instructions to the user:

**macOS / Linux:**
```bash
mkdir -p ~/.finhay/credentials
cat > ~/.finhay/credentials/.env << 'EOF'
FINHAY_API_KEY=ak_test_YOUR_API_KEY_HERE
FINHAY_API_SECRET=YOUR_64_CHAR_HEX_SECRET_HERE
FINHAY_BASE_URL=https://open-api.fhsc.com.vn
EOF
chmod 600 ~/.finhay/credentials/.env
```

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.finhay\credentials" | Out-Null
@"
FINHAY_API_KEY=ak_test_YOUR_API_KEY_HERE
FINHAY_API_SECRET=YOUR_64_CHAR_HEX_SECRET_HERE
FINHAY_BASE_URL=https://open-api.fhsc.com.vn
"@ | Set-Content "$env:USERPROFILE\.finhay\credentials\.env"
```

If `USER_ID`, `SUB_ACCOUNT_NORMAL`, or `SUB_ACCOUNT_MARGIN` is missing (trading only), run:

**macOS / Linux:**
```bash
./_shared/scripts/infer-sub-account.sh
```

**Windows (PowerShell):**
```powershell
pwsh -NoProfile -File .\_shared\scripts\infer-sub-account.ps1
```

## 3. Skill version

**macOS / Linux:**
```bash
cat ~/.finhay/ref/.env
```

**Windows (PowerShell):**
```powershell
Get-Content "$env:USERPROFILE\.finhay\ref\.env"
```

If it does not exist, create it:

**macOS / Linux:**
```bash
mkdir -p ~/.finhay/ref
cat > ~/.finhay/ref/.env << 'EOF'
SHARED_SYNC_AT=0
SKILL_FINHAY_TRADING_SYNC_AT=0
SKILL_FINHAY_MARKET_SYNC_AT=0
EOF
```

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.finhay\ref" | Out-Null
@"
SHARED_SYNC_AT=0
SKILL_FINHAY_TRADING_SYNC_AT=0
SKILL_FINHAY_MARKET_SYNC_AT=0
"@ | Set-Content "$env:USERPROFILE\.finhay\ref\.env"
```

Then run to sync:

**macOS / Linux:**
```bash
./_shared/scripts/sync.sh {skill-name}
```

**Windows (PowerShell):**
```powershell
pwsh -NoProfile -File .\_shared\scripts\sync.ps1 {skill-name}
```

## 4. Request script

**macOS / Linux:**
```bash
./_shared/scripts/request.sh METHOD PATH [QUERY]
```

**Windows (PowerShell):**
```powershell
pwsh -NoProfile -File .\_shared\scripts\request.ps1 METHOD PATH [QUERY]
```

Never construct API calls manually. Always use this script.
