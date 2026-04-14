---
name: finhay-portfolio
description: "Owner identity, account balance, portfolio, orders, and profit/loss. Use when user asks about their account identity, account balance, total assets, trading account, stock holdings, order history, or today's PnL."
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
  homepage: "https://fhsc.com.vn/"
---

# Finhay Portfolio

Read-only trading data via the Finhay Securities Open API. All endpoints use signed `GET` requests.

> **MANDATORY**: Before any action, complete the pre-flight checks below. Required: `FINHAY_API_KEY`, `FINHAY_API_SECRET`, `USER_ID`, and the relevant `SUB_ACCOUNT_*` variable. Do not skip or defer.

## Pre-flight Checks

1. Ensure CLI is available: `finhay --help` (or use `npx -y finhay-cli --help`).
2. Ensure credentials file exists: `~/.finhay/credentials/.env`.
  If missing, create it:

  macOS/Linux:
  ```bash
  mkdir -p ~/.finhay/credentials
  cat > ~/.finhay/credentials/.env << 'EOF'
  FINHAY_API_KEY=ak_test_YOUR_API_KEY_HERE
  FINHAY_API_SECRET=YOUR_64_CHAR_HEX_SECRET_HERE
  USER_ID=YOUR_USER_ID
  SUB_ACCOUNT_NORMAL=YOUR_NORMAL_SUB_ACCOUNT_ID
  SUB_ACCOUNT_MARGIN=YOUR_MARGIN_SUB_ACCOUNT_ID
  FINHAY_BASE_URL=https://open-api.fhsc.com.vn
  EOF
  chmod 600 ~/.finhay/credentials/.env
  ```

  Windows (PowerShell):
  ```powershell
  New-Item -ItemType Directory -Force "$env:USERPROFILE\.finhay\credentials" | Out-Null
  @"
  FINHAY_API_KEY=ak_test_YOUR_API_KEY_HERE
  FINHAY_API_SECRET=YOUR_64_CHAR_HEX_SECRET_HERE
  USER_ID=YOUR_USER_ID
  SUB_ACCOUNT_NORMAL=YOUR_NORMAL_SUB_ACCOUNT_ID
  SUB_ACCOUNT_MARGIN=YOUR_MARGIN_SUB_ACCOUNT_ID
  FINHAY_BASE_URL=https://open-api.fhsc.com.vn
  "@ | Set-Content "$env:USERPROFILE\.finhay\credentials\.env"
  ```
3. Ensure required variables are set in that file:
  - `FINHAY_API_KEY` (`ak_test_*` or `ak_live_*`)
  - `FINHAY_API_SECRET` (64-char hex)
  - `USER_ID`
  - `SUB_ACCOUNT_NORMAL` and/or `SUB_ACCOUNT_MARGIN`
  - optional: `FINHAY_BASE_URL` (defaults to `https://open-api.fhsc.com.vn`)

## Setup

If `USER_ID` or `SUB_ACCOUNT_*` variables are missing, add them manually to `~/.finhay/credentials/.env`.

## Making a Request

Prerequisite: use `finhay-cli` (`npm install -g finhay-cli`) or run via `npx -y finhay-cli ...`.

Always use `finhay request`. Resolve all path variables (`{subAccountId}`, `{userId}`) before calling — the signed path must be the final, fully resolved path.

Use concrete values in `--path` (from `~/.finhay/credentials/.env`), not unresolved shell placeholders.

```bash
finhay request --path "/trading/accounts/<SUB_ACCOUNT_NORMAL>/summary"
finhay request --path "/users/v4/users/<USER_ID>/assets/summary"
finhay request --path "/trading/sub-accounts/<SUB_ACCOUNT_MARGIN>/orders" --query fromDate=2024-01-01 --query toDate=2024-01-31
finhay request --path "/trading/v2/sub-accounts/<SUB_ACCOUNT_NORMAL>/portfolio"
finhay request --path "/trading/pnl-today/<USER_ID>"
finhay request --path "/trading/market/session" --query exchange=HOSE
```

## Sub-account Selection

When `{subAccountId}` is required, ask the user whether to use NORMAL or MARGIN, then substitute the corresponding env variable:
- NORMAL → `SUB_ACCOUNT_NORMAL`
- MARGIN → `SUB_ACCOUNT_MARGIN`

## Endpoints

| Endpoint | Use when | Path param | Query params | Res key |
|----------|----------|------------|--------------|---------|
| `/trading/accounts/{subAccountId}/summary` | Account detail, margin, debt | `{subAccountId}` → ask user | — | `result` |
| `/users/v4/users/{userId}/assets/summary` | Balance, total assets, NAV | `{userId}` → `USER_ID` | `cache-control` (default `CACHE`) | `data` |
| `/trading/sub-accounts/{subAccountId}/orders` | Order history | `{subAccountId}` → ask user | `fromDate`, `toDate` (required) | `result` |
| `/trading/v1/accounts/{subAccountId}/order-book` | Today's order book | `{subAccountId}` → ask user | — | `result` |
| `/trading/v1/accounts/{subAccountId}/order-book/{orderId}` | Single order detail | `{subAccountId}` → ask user, `{orderId}` | — | `data` |
| `/trading/v2/sub-accounts/{subAccountId}/portfolio` | Stock holdings | `{subAccountId}` → ask user | — | `data` |
| `/trading/pnl-today/{userId}` | Today's P&L | `{userId}` → `USER_ID` | — | `data` |
| `/trading/v5/account/{subAccountId}/user-rights` | Trading permissions | `{subAccountId}` → ask user | — | `result` |
| `/trading/market/session` | Market open/close | — | `exchange` (e.g. `HOSE`) | `result` |

Path versions (`v1`, `v2`, `v4`, `v5`) are fixed. Always use the exact versions listed above.

### Parameter rules

- Each endpoint accepts **only** the parameters listed in its path and query columns above. Do not add extra parameters.
- All `{variables}` in the URL are **path** variables — substitute them into the URL, never pass as query params.

Details & response schemas: [references/endpoints.md](./references/endpoints.md). Enums: [references/enums.md](./references/enums.md).

## Constraints

- **Read-only** - never send non-GET requests or mutating actions.
- **Credentials** - never display full keys; mask with `********`. Never send credentials outside the configured `FINHAY_BASE_URL`. Never bypass TLS (`--insecure`, `-k`).
- **Responses** - present results to the user immediately in a readable format. Never silently discard a response.

- Never substitute `{subAccountId}` without first confirming the sub-account type with the user.
