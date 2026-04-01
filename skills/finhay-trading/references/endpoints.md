# Trading Endpoints

Signing: see [authentication.md](../_shared/authentication.md). Query params are not signed.

## Config

From `~/.finhay/credentials/.env`:

- `USER_ID` — required for PnL endpoints; written by `infer-sub-account.sh` after fetching owner info
- `SUB_ACCOUNT_NORMAL`, `SUB_ACCOUNT_MARGIN` — written by [infer-sub-account.sh](../_shared/scripts/infer-sub-account.sh), used as `{subAccountId}`

## Errors

`400` = invalid request, `401` = auth failure, `429` = rate limited.

Common causes: missing API key, wrong path prefix, missing `USER_ID`, missing `fromDate`/`toDate` for orders, path mismatch in signature.

## Path Versions

`v1` = order book, `v2` = portfolio, `v5` = user rights. No prefix = original API. Always use exact versions below.

## Response Keys

- `result` — owner, account-summary, orders, order-book (list), user-rights, market-session
- `data` — asset-summary, order-book (detail), portfolio, pnl-today

---

## Owner

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 1 | GET | `/users/oa/me` | — | `result` | [detail](./endpoints/owner.md) |

## Account

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 2 | GET | `/trading/accounts/{subAccountId}/summary` | — | `result` | [detail](./endpoints/account-summary.md) |
| 3 | GET | `/trading/sub-accounts/{subAccountId}/asset-summary` | — | `data` | [detail](./endpoints/asset-summary.md) |

## Orders

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 4 | GET | `/trading/sub-accounts/{subAccountId}/orders` | `fromDate`, `toDate` | `result` | [detail](./endpoints/orders.md) |
| 5 | GET | `/trading/v1/accounts/{subAccountId}/order-book` | — | `result` | [detail](./endpoints/order-book.md) |
| 6 | GET | `/trading/v1/accounts/{subAccountId}/order-book/{orderId}` | `orderId` (path) | `data` | [detail](./endpoints/order-book-detail.md) |

## Portfolio

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 7 | GET | `/trading/v2/sub-accounts/{subAccountId}/portfolio` | — | `data` | [detail](./endpoints/portfolio.md) |

## PnL

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 8 | GET | `/trading/pnl-today/{userId}` | — | `data` | [detail](./endpoints/pnl-today.md) |

## User Rights

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 9 | GET | `/trading/v5/account/{subAccountId}/user-rights` | — | `result` | [detail](./endpoints/user-rights.md) |

## Market Session

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 10 | GET | `/trading/market/session` | `exchange` | `result` | [detail](./endpoints/market-session.md) |
