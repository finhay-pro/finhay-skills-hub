# Order Execution Endpoints

## Signing for Write Operations

Write operations use a **different signing payload** than GET requests. The body hash is included:

```
{TIMESTAMP}\n{METHOD}\n{PATH}\n{BODY_HASH}
```

Where `BODY_HASH = SHA256(request_body_json)`. The `X-FH-BODYHASH` header is also sent. The `write-request.sh` script handles this automatically.

See [authentication.md](../../_shared/authentication.md) for full details.

## Endpoint Versioning

Write operations use the `/oa/` prefix **without** version numbers (e.g. `/oa/sub-accounts/...`). This differs from read endpoints which use versioned prefixes like `/trading/v1/`, `/trading/v2/`, or `/trading/v5/`. Do not add version numbers to write paths.

## Errors

`400` = invalid request (missing field, bad value), `401` = auth failure, `403` = scope/IP denied, `429` = rate limited.

Order-level errors are returned in `result[].code` and `result[].rejected_reason`. See [error-codes.md](./error-codes.md).

## Response Key

All three endpoints return data in the `result` key as an array of order results.

---

## Place Order

| # | Method | Path | Body | Res key | Detail |
|---|--------|------|------|---------|--------|
| 1 | POST | `/oa/sub-accounts/{accountId}/orders` | sub_account, cus_id, side, symbol, quantity, type, limit_price, market_price, stock_type | `result` | [detail](./endpoints/place-order.md) |

## Modify Order

| # | Method | Path | Body | Res key | Detail |
|---|--------|------|------|---------|--------|
| 2 | PUT | `/oa/sub-accounts/{accountId}/orders/{orderId}` | quantity, price, channel | `result` | [detail](./endpoints/modify-order.md) |

## Cancel Order

| # | Method | Path | Body | Res key | Detail |
|---|--------|------|------|---------|--------|
| 3 | DELETE | `/oa/sub-accounts/{accountId}/orders/{orderId}` | sub_account, cus_id, channel | `result` | [detail](./endpoints/cancel-order.md) |
