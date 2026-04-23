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

> **MANDATORY**: Before any action, read and complete [pre-flight checks](./_shared/preflight.md). Required: `FINHAY_API_KEY`, `FINHAY_API_SECRET`, `USER_ID`, and the relevant `SUB_ACCOUNT_*` variable. Do not skip or defer.

## Setup

If `USER_ID` or `SUB_ACCOUNT_*` variables are missing, run once:

```bash
./_shared/scripts/infer-sub-account.sh
```

This writes `USER_ID`, `SUB_ACCOUNT_NORMAL`, and/or `SUB_ACCOUNT_MARGIN` to `~/.finhay/credentials/.env`.

## Making a Request

Always use `request.sh`. Resolve all path variables (`{subAccountId}`, `{userId}`) before calling — the signed path must be the final, fully resolved path.

```bash
source ~/.finhay/credentials/.env

./_shared/scripts/request.sh GET "/trading/accounts/$SUB_ACCOUNT_NORMAL/summary"
./_shared/scripts/request.sh GET "/users/v4/users/$USER_ID/assets/summary"
./_shared/scripts/request.sh GET "/trading/sub-accounts/$SUB_ACCOUNT_MARGIN/orders" "fromDate=2024-01-01&toDate=2024-01-31"
./_shared/scripts/request.sh GET "/trading/v2/sub-accounts/$SUB_ACCOUNT_NORMAL/portfolio"
./_shared/scripts/request.sh GET "/trading/pnl-today/$USER_ID"
./_shared/scripts/request.sh GET "/trading/market/session" "exchange=HOSE"
```

## Sub-account Selection

When `{subAccountId}` is required, ask the user whether to use NORMAL or MARGIN, then substitute the corresponding env variable:
- NORMAL → `$SUB_ACCOUNT_NORMAL`
- MARGIN → `$SUB_ACCOUNT_MARGIN`

## Endpoints

| Endpoint | Use when | Path param | Query params | Res key |
|----------|----------|------------|--------------|---------|
| `/trading/accounts/{subAccountId}/summary` | Account detail, margin, debt | `{subAccountId}` → ask user | — | `result` |
| `/users/v4/users/{userId}/assets/summary` | Balance, total assets, NAV | `{userId}` → `$USER_ID` | `cache-control` (default `CACHE`) | `data` |
| `/trading/sub-accounts/{subAccountId}/orders` | Order history | `{subAccountId}` → ask user | `fromDate`, `toDate` (required) | `result` |
| `/trading/v1/accounts/{subAccountId}/order-book` | Today's order book | `{subAccountId}` → ask user | — | `result` |
| `/trading/v1/accounts/{subAccountId}/order-book/{orderId}` | Single order detail | `{subAccountId}` → ask user, `{orderId}` | — | `data` |
| `/trading/v2/sub-accounts/{subAccountId}/portfolio` | Stock holdings | `{subAccountId}` → ask user | — | `data` |
| `/trading/pnl-today/{userId}` | Today's P&L | `{userId}` → `$USER_ID` | — | `data` |
| `/trading/v5/account/{subAccountId}/user-rights` | Trading permissions | `{subAccountId}` → ask user | — | `result` |
| `/trading/market/session` | Market open/close | — | `exchange` (e.g. `HOSE`) | `result` |

Path versions (`v1`, `v2`, `v4`, `v5`) are fixed. Always use the exact versions listed above.
For order history, `fromDate` and `toDate` are required and must be in `YYYY-MM-DD` format.
For account balance alway use combination of the `/users/v4/users/{userId}/assets/summary` & `/trading/accounts/{subAccountId}/summary` endpoints, to get the most accurate total assets and NAV.

### Parameter rules

- Each endpoint accepts **only** the parameters listed in its path and query columns above. Do not add extra parameters.
- All `{variables}` in the URL are **path** variables — substitute them into the URL, never pass as query params.

Details & response schemas: [references/endpoints.md](./references/endpoints.md). Enums: [references/enums.md](./references/enums.md).

## Constraints

See [shared constraints](./_shared/constraints.md), plus:

- Never substitute `{subAccountId}` without first confirming the sub-account type with the user.
