# Safety Protocol — Detailed Reference

This document expands on the Safety Protocol in SKILL.md. Every order operation **must** follow all 5 steps.

## Confirmation Dialog Examples

### Place Order

```
╔══════════════════════════════════════╗
║        ORDER CONFIRMATION            ║
╠══════════════════════════════════════╣
║  Action:    PLACE                    ║
║  Side:      BUY                      ║
║  Symbol:    HPG                      ║
║  Quantity:  100                      ║
║  Price:     25,500 VND               ║
║  API price: 25500000 (× 1000)        ║
║  Est. cost: 2,550,000 VND            ║
║  Type:      LIMIT                    ║
║  Account:   0881234567 (NORMAL)      ║
╚══════════════════════════════════════╝
Type "confirm" to execute or "cancel" to abort.
```

### Modify Order

```
╔══════════════════════════════════════╗
║       MODIFY ORDER CONFIRMATION      ║
╠══════════════════════════════════════╣
║  Order ID:  ORD20240101001           ║
║  Symbol:    HPG (BUY)                ║
║  Current:   100 shares @ 25,500      ║
║  New:       200 shares @ 26,000      ║
║  API price: 26000000 (× 1000)        ║
║  Account:   0881234567 (NORMAL)      ║
╚══════════════════════════════════════╝
Type "confirm" to execute or "cancel" to abort.
```

### Cancel Order

```
╔══════════════════════════════════════╗
║       CANCEL ORDER CONFIRMATION      ║
╠══════════════════════════════════════╣
║  Order ID:  ORD20240101001           ║
║  Symbol:    HPG (BUY)                ║
║  Quantity:  100 shares @ 25,500      ║
║  Status:    SENT                     ║
║  Account:   0881234567 (NORMAL)      ║
╚══════════════════════════════════════╝
Type "confirm" to execute or "cancel" to abort.
```

## Duplicate Detection

Before placing a new order:

1. Fetch current order book: `GET /trading/v1/accounts/{accountId}/order-book`
2. Filter for orders with status in: `RECEIVED`, `SENT`, `WAITING_TO_SEND`, `SENDING`
3. Check if any match **all four**: same `symbol` + same `order_side` + same `order_quantity` + same `limit_price`
4. If match found → show duplicate warning, require `"confirm-duplicate"` instead of `"confirm"`

## Modifiable / Cancellable Statuses

### Can modify

`SENT`, `WAITING_TO_SEND`

### Can cancel

`SENT`, `WAITING_TO_SEND`, `SENDING`

### Cannot modify or cancel

`MATCHED`, `MATCHED_ALL`, `CANCELLED`, `COMPLETED`, `FAILED`, `REJECTED`, `EXPIRED`

Always verify by checking the order detail endpoint before attempting modify/cancel.

## Recovery from Failures

### Timeout or network error during order placement

1. **Do not retry immediately.**
2. Check the order book: `GET /trading/v1/accounts/{accountId}/order-book`
3. Search for a recent order matching the attempted symbol + side + quantity + price.
4. If found → the order was placed successfully. Report it to the user.
5. If not found → the order was not placed. Ask the user if they want to retry.

### Timeout during modify/cancel

1. Check the order detail: `GET /trading/v1/accounts/{accountId}/order-book/{orderId}`
2. If the order status changed → the operation succeeded.
3. If unchanged → the operation may have failed. Ask the user if they want to retry.

## Production vs Test Keys

| Key prefix | Environment | Extra warnings |
|------------|-------------|----------------|
| `ak_test_*` | Test/sandbox | None |
| `ak_live_*` | Production | Add `⚠ PRODUCTION — REAL MONEY` to every confirmation |
