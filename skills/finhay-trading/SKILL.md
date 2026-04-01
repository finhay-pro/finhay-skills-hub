---
name: finhay-trading
description: "User profile, account balances, portfolio, orders, and profit/loss. Use when user asks about their profile, trading account, stock holdings, order history, or today's PnL."
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
  homepage: "https://fhsc.com.vn/"
---

# Finhay Trading

Read-only user and trading data via the Finhay Securities Open API. All requests are signed `GET`.

## Pre-flight

See [pre-flight checks](./_shared/preflight.md). Required: `FINHAY_API_KEY`, `FINHAY_API_SECRET`, `USER_ID`.

### Sub-account setup

Run once after credentials are configured — this fetches all sub-accounts from the user profile and saves them to `.env`:

```bash
./_shared/scripts/infer-sub-account.sh
```

This writes `SUB_ACCOUNT_NORMAL` and/or `SUB_ACCOUNT_MARGIN` to `~/.finhay/credentials/.env`.

## Making a Request

Use [request.sh](./_shared/scripts/request.sh) for every call. Substitute `{subAccountId}` and `{userId}` before calling — the signed path must be the final path.

When a request requires `{subAccountId}`, **ask the user which sub-account type** they want to use (NORMAL or MARGIN), then read the corresponding value from `.env`:

```bash
# Load credentials
source ~/.finhay/credentials/.env

# User profile
./_shared/scripts/request.sh GET "/internal/users/$USER_ID/profile"

# Trading — use SUB_ACCOUNT_NORMAL or SUB_ACCOUNT_MARGIN based on user choice
./_shared/scripts/request.sh GET "/trading/accounts/$SUB_ACCOUNT_NORMAL/summary"
./_shared/scripts/request.sh GET "/trading/sub-accounts/$SUB_ACCOUNT_MARGIN/orders" "fromDate=2024-01-01&toDate=2024-01-31"
./_shared/scripts/request.sh GET "/trading/v2/sub-accounts/$SUB_ACCOUNT_NORMAL/portfolio"
./_shared/scripts/request.sh GET "/trading/pnl-today/$USER_ID"
./_shared/scripts/request.sh GET /trading/market/session "exchange=HOSE"
```

## Endpoints

| Endpoint | Path param | Key params | Res key |
|----------|------------|------------|---------|
| `/internal/users/{userId}/profile` | `USER_ID` | — | `result` |
| `/trading/accounts/{subAccountId}/summary` | ask user | — | `result` |
| `/trading/sub-accounts/{subAccountId}/asset-summary` | ask user | — | `data` |
| `/trading/sub-accounts/{subAccountId}/orders` | ask user | `fromDate`, `toDate` | `result` |
| `/trading/v1/accounts/{subAccountId}/order-book` | ask user | — | `result` |
| `/trading/v1/accounts/{subAccountId}/order-book/{orderId}` | ask user | `orderId` (path) | `data` |
| `/trading/v2/sub-accounts/{subAccountId}/portfolio` | ask user | — | `data` |
| `/trading/pnl-today/{userId}` | `USER_ID` | — | `data` |
| `/trading/v5/account/{subAccountId}/user-rights` | ask user | — | `result` |
| `/trading/market/session` | — | `exchange` | `result` |

Path versions (`v1`, `v2`, `v5`) are historical — always use the exact version above.

Details & response shapes: [references/endpoints.md](./references/endpoints.md). Enums: [references/enums.md](./references/enums.md).

## Constraints

See [shared constraints](./_shared/constraints.md), plus:

- `fromDate` and `toDate` are always required for the orders endpoint.
- When `{subAccountId}` is needed, ask the user to choose between NORMAL and MARGIN, then use `SUB_ACCOUNT_NORMAL` or `SUB_ACCOUNT_MARGIN` from `.env`.
- `/internal/users/{userId}/profile` is an internal API — service-to-service only.
