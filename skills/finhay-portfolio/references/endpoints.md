# Trading Endpoints

Signing: use `./finhay.sh request`.

## Config Envs

- `USER_ID` — written by `./finhay.sh infer`
- `SUB_ACCOUNT_NORMAL`, `SUB_ACCOUNT_MARGIN` — written by `./finhay.sh infer`

---

## Account & Balance

| # | Method | Path | Params | Res key | Purpose | Detail |
|---|--------|------|--------|---------|---------|--------|
| 1 | GET | `/trading/accounts/{subAccountId}/summary` | — | `result` | **Trading Account Detail**: Specific financials for a single stock trading account | [detail](./endpoints/account-detail.md) |
| 2 | GET | `/users/v4/users/{userId}/assets/summary` | `cache-control` | `data` | **Portfolio Overview**: Aggregated wealth summary across all Finhay products | [detail](./endpoints/portfolio-overview.md) |

## Orders

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 3 | GET | `/trading/sub-accounts/{subAccountId}/orders` | `fromDate`, `toDate` | `result` | [detail](./endpoints/orders.md) |
| 4 | GET | `/trading/v1/accounts/{subAccountId}/order-book` | — | `result` | [detail](./endpoints/order-book.md) |

## Portfolio & PnL

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 5 | GET | `/trading/v2/sub-accounts/{subAccountId}/portfolio` | — | `data` | [detail](./endpoints/portfolio.md) |
| 6 | GET | `/trading/pnl-today/{userId}` | — | `data` | [detail](./endpoints/pnl-today.md) |

## Others

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 7 | GET | `/trading/v5/account/{subAccountId}/user-rights` | — | `result` | [detail](./endpoints/user-rights.md) |
| 8 | GET | `/trading/market/session` | `exchange` | `result` | [detail](./endpoints/market-session.md) |
