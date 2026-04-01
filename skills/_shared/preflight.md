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
- `USER_ID` — required for trading endpoints. Not needed for market endpoints.

If missing, tell the user:

```bash
mkdir -p ~/.finhay/credentials
cat > ~/.finhay/credentials/.env << 'EOF'
FINHAY_API_KEY=ak_test_YOUR_API_KEY_HERE
FINHAY_API_SECRET=YOUR_64_CHAR_HEX_SECRET_HERE
FINHAY_BASE_URL=https://open-api.fhsc.com.vn
USER_ID=123456
EOF
chmod 600 ~/.finhay/credentials/.env
```

## 3. Skill version

Run once per session to check for updates:

```bash
./_shared/scripts/sync.sh {skill-name}
```

If a newer version is found, the script syncs automatically.

## 4. Request script

```bash
../_shared/scripts/request.sh METHOD PATH [QUERY]
```

Always use this script — never construct API calls manually.
