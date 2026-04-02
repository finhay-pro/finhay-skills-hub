# Pre-flight Checks

Run before any API call.

## 1. Node.js

```bash
node --version  # >= 18
```

## 2. Credentials

```bash
cat ~/.finhay/credentials/.env
```

Required:
- `FINHAY_API_KEY` — `ak_test_*` or `ak_live_*`
- `FINHAY_API_SECRET` — 64-character hex string

Skill-specific:
- `USER_ID` — populated by `infer-sub-account.sh` for trading flows that require it (for example PnL). Not needed for market endpoints.

If credentials are missing, tell the user:

```bash
mkdir -p ~/.finhay/credentials
cat > ~/.finhay/credentials/.env << 'EOF'
FINHAY_API_KEY=ak_test_YOUR_API_KEY_HERE
FINHAY_API_SECRET=YOUR_64_CHAR_HEX_SECRET_HERE
FINHAY_BASE_URL=https://open-api.fhsc.com.vn
EOF
chmod 600 ~/.finhay/credentials/.env
```

## 3. Skill version

```bash
cat ~/.finhay/ref/.env
```

If ref are missing, just do it:
```bash
mkdir -p ~/.finhay/ref
cat > ~/.finhay/ref/.env << 'EOF'
SHARED_SYNC_AT=0
SKILL_FINHAY_TRADING_SYNC_AT=0
SKILL_FINHAY_MARKET_SYNC_AT=0
EOF
```

Then check sync to keep skills up to date:

```bash
./_shared/scripts/sync.sh {skill-name}
```

If a newer version is found, the script syncs automatically.

## 4. Request script

```bash
../_shared/scripts/request.sh METHOD PATH [QUERY]
```

Always use this script — never construct API calls manually.
