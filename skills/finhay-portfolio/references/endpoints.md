# Trading Endpoints

Signing: see [authentication.md](../_shared/authentication.md). Query params are not signed.

## Config Envs

From `~/.finhay/credentials/.env`:

- `USER_ID` — required for assets summary and PnL; written by `infer-sub-account.sh`
- `SUB_ACCOUNT_NORMAL`, `SUB_ACCOUNT_MARGIN` — used as `{subAccountId}`; written by `infer-sub-account.sh`

## Error Codes

| Code | Meaning |
|------|---------|
| `400` | Invalid request |
| `401` | Auth failure |
| `429` | Rate limited |

Common causes: missing `FINHAY_API_KEY`, wrong path prefix (`/trading/` vs `/users/`), missing `USER_ID`, missing `fromDate`/`toDate` for orders, path mismatch in signature.

## Path Versions

Versions are fixed per endpoint — do not change them:
- `v1` → order book
- `v2` → portfolio
- `v4` → assets
- `v5` → user rights
- (no prefix) → account summary, orders, PnL, market session

## Response Keys

- `result` — account-summary, orders, order-book (list), user-rights, market-session
- `data` — assets, order-book (detail), portfolio, pnl-today

---

## Account

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 1 | GET | `/trading/accounts/{subAccountId}/summary` | — | `result` | [detail](./endpoints/account-summary.md) |
| 2 | GET | `/users/v3/users/{userId}/assets/summary` | `cache-control` | `data` | [detail](./endpoints/assets.md) |

## Orders

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 3 | GET | `/trading/sub-accounts/{subAccountId}/orders` | `fromDate`, `toDate` | `result` | [detail](./endpoints/orders.md) |
| 4 | GET | `/trading/v1/accounts/{subAccountId}/order-book` | — | `result` | [detail](./endpoints/order-book.md) |
| 5 | GET | `/trading/v1/accounts/{subAccountId}/order-book/{orderId}` | `orderId` (path) | `data` | [detail](./endpoints/order-book-detail.md) |

## Portfolio

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 6 | GET | `/trading/v2/sub-accounts/{subAccountId}/portfolio` | — | `data` | [detail](./endpoints/portfolio.md) |

## PnL

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 7 | GET | `/trading/pnl-today/{userId}` | — | `data` | [detail](./endpoints/pnl-today.md) |

## User Rights

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 8 | GET | `/trading/v5/account/{subAccountId}/user-rights` | — | `result` | [detail](./endpoints/user-rights.md) |

## Market Session

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 9 | GET | `/trading/market/session` | `exchange` | `result` | [detail](./endpoints/market-session.md) |
