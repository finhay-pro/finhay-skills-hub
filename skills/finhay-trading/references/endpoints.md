# Trading Endpoints

Signing: see [authentication.md](../../_shared/authentication.md). Query params are not signed.

## Config

From `~/.finhay/credentials/.env`:
- `USER_ID` — required for PnL endpoints; written by `infer-sub-account.sh` after fetching owner info
- `SUB_ACCOUNT_NORMAL`, `SUB_ACCOUNT_MARGIN` — written by [infer-sub-account.sh](../../_shared/scripts/infer-sub-account.sh), used as `{subAccountId}` in path
- `SUB_ACCOUNT_EXT_NORMAL`, `SUB_ACCOUNT_EXT_MARGIN` — written by `infer-sub-account.sh`, used as `sub_account` in request body (order execution)

## Errors

`400` = invalid request, `401` = auth failure, `403` = scope/IP denied, `429` = rate limited.

Common causes: missing API key, wrong path prefix, missing `USER_ID`, missing `fromDate`/`toDate` for orders, path mismatch in signature.

Order-level errors are returned in `result[].code` and `result[].rejected_reason`. See [error-codes.md](./error-codes.md).

## Path Versions

`v1` = order book, `v2` = portfolio, `v5` = user rights. No prefix = original API. Always use exact versions below.

## Signing for Write Operations

Write operations use a **different signing payload** than GET requests. The body hash is included:

```
{TIMESTAMP}\n{METHOD}\n{PATH}\n{BODY_HASH}
```

Where `BODY_HASH = SHA256(request_body_json)`. The `X-FH-BODYHASH` header is also sent. The `write-request.sh` script handles this automatically.

## Endpoint Versioning

Write operations use the `/trading/oa/` prefix **without** version numbers (e.g. `/trading/oa/sub-accounts/...`). This differs from read endpoints which use versioned prefixes like `/trading/v1/`, `/trading/v2/`, or `/trading/v5/`. Do not add version numbers to write paths.

## Response Keys

- `result` — owner, account-summary, orders, order-book (list), trade-info, user-rights, market-session, order execution
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

## Trade Info (Pre-execution Check)

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 7 | GET | `/trading/sub-accounts/{subAccountId}/trade-info` | `symbol`, `side`, `quote_price` | `result` | [detail](./endpoints/trade-info.md) |

## Portfolio

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 8 | GET | `/trading/v2/sub-accounts/{subAccountId}/portfolio` | — | `data` | [detail](./endpoints/portfolio.md) |

## PnL

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 9 | GET | `/trading/pnl-today/{userId}` | — | `data` | [detail](./endpoints/pnl-today.md) |

## User Rights

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 10 | GET | `/trading/v5/account/{subAccountId}/user-rights` | — | `result` | [detail](./endpoints/user-rights.md) |

## Market Session

| # | Method | Path | Params | Res key | Detail |
|---|--------|------|--------|---------|--------|
| 11 | GET | `/trading/market/session` | `exchange` | `result` | [detail](./endpoints/market-session.md) |

---

## Order Execution (Write)

All three endpoints return data in the `result` key as an array of order results.

### Place Order

| # | Method | Path | Body | Res key | Detail |
|---|--------|------|------|---------|--------|
| 12 | POST | `/trading/oa/sub-accounts/{subAccountId}/orders` | sub_account, side, symbol, quantity, type, limit_price, market_price, stock_type | `result` | [detail](./endpoints/place-order.md) |

### Modify Order

| # | Method | Path | Body | Res key | Detail |
|---|--------|------|------|---------|--------|
| 13 | PUT | `/trading/oa/sub-accounts/{subAccountId}/orders/{orderId}` | quantity, price | `result` | [detail](./endpoints/modify-order.md) |

### Cancel Order

| # | Method | Path | Body | Res key | Detail |
|---|--------|------|------|---------|--------|
| 14 | DELETE | `/trading/oa/sub-accounts/{subAccountId}/orders/{orderId}` | sub_account | `result` | [detail](./endpoints/cancel-order.md) |
