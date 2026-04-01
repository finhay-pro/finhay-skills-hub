---
name: finhay-order-execution
description: "Place, modify, and cancel stock orders via Finhay OpenAPI. DESTRUCTIVE — real money operations that cannot be undone. Use ONLY when user explicitly asks to place, modify, or cancel a stock order."
disable-model-invocation: true
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
  homepage: "https://fhsc.com.vn/"
---

# Finhay Order Execution

> **DANGER — REAL MONEY OPERATIONS.** This skill places, modifies, and cancels stock orders on the Vietnam stock exchange. Every action is **irreversible once matched**. Follow the Safety Protocol below for **every** operation — no exceptions.

## Pre-flight

See [pre-flight checks](../_shared/preflight.md). Required: `FINHAY_API_KEY`, `FINHAY_API_SECRET`, `USER_ID`, plus sub-account setup.

Run once if not already done:

```bash
../_shared/scripts/infer-sub-account.sh
```

## Safety Protocol

**Follow ALL 5 steps for every order action. Never skip a step.**

### Step 1 — Gather parameters

Ask the user explicitly for every required field. **Never assume or default** side, symbol, quantity, or price.

| Action | Required from user |
|--------|--------------------|
| Place  | side (BUY/SELL), symbol, quantity, price, type (LIMIT/MARKET) |
| Modify | orderId, new quantity and/or new price |
| Cancel | orderId |

### Step 2 — Pre-execution checks

Before calling the write API, verify via read endpoints:

- **Market session**: `GET /trading/market/session?exchange=HOSE` — reject if session is closed.
- **Place BUY**: `GET /trading/accounts/{subAccountId}/summary` — check buying power is sufficient (quantity × price).
- **Place SELL**: `GET /trading/v2/sub-accounts/{subAccountId}/portfolio` — check user holds enough shares of the symbol.
- **Modify/Cancel**: `GET /trading/v1/accounts/{subAccountId}/order-book/{orderId}` — check the order exists and is in a modifiable/cancellable status.

Use `request.sh` (read-only script) for these checks.

### Step 3 — Confirmation display

Present this block to the user **before** executing:

```
╔═════════���════════════════════════════╗
║        ORDER CONFIRMATION            ║
╠══════════════════════════════════════╣
║  Action:    PLACE / MODIFY / CANCEL  ║
║  Side:      BUY / SELL               ║
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

If credentials contain `ak_live_`, add a **PRODUCTION** warning line.

### Step 4 — Wait for explicit confirmation

**Only proceed if the user types "confirm"**. Do not accept "ok", "yes", "sure", "go", or any other variation. If the user types anything else, treat it as cancellation and ask if they want to retry.

### Step 5 — Execute and report

Call `write-request.sh`, then display:

- `order_id` and `order_status`
- `rejected_reason` or `code` if present
- Full result summary in readable format

If the API call fails or times out, **immediately** check the order book (GET) to determine whether the order was actually placed.

## Duplicate Guard

Before placing a new order, check the current order book (`GET /trading/v1/accounts/{subAccountId}/order-book`). If a pending order exists with the **same symbol + side + quantity + price**, warn the user:

```
⚠ DUPLICATE WARNING: A pending order already exists:
  Order ID: ORD20240101001, Status: SENT
  Same symbol (HPG), side (BUY), quantity (100), price (25,500)

This may be a duplicate. Type "confirm-duplicate" to proceed anyway.
```

## Making a Request

Use `write-request.sh` (not `request.sh`) for all write operations. The script handles HMAC-SHA256 signing with body hash automatically.

```bash
source ~/.finhay/credentials/.env

# Place order
../_shared/scripts/write-request.sh POST \
  "/oa/sub-accounts/$SUB_ACCOUNT_NORMAL/orders" \
  '{"sub_account":"'"$SUB_ACCOUNT_NORMAL"'","cus_id":"'"$CUST_ID"'","side":"BUY","symbol":"HPG","quantity":100,"type":"LIMIT","limit_price":25500000,"stock_type":"STOCK"}'

# Modify order
../_shared/scripts/write-request.sh PUT \
  "/oa/sub-accounts/$SUB_ACCOUNT_NORMAL/orders/ORDER_ID" \
  '{"quantity":200,"price":26000000,"channel":"ONLINE"}'

# Cancel order
../_shared/scripts/write-request.sh DELETE \
  "/oa/sub-accounts/$SUB_ACCOUNT_NORMAL/orders/ORDER_ID" \
  '{"sub_account":"'"$SUB_ACCOUNT_NORMAL"'","cus_id":"'"$CUST_ID"'","channel":"ONLINE"}'

# Dry run (preview request without sending)
../_shared/scripts/write-request.sh POST \
  "/oa/sub-accounts/$SUB_ACCOUNT_NORMAL/orders" \
  '{"side":"BUY","symbol":"HPG","quantity":100}' --dry-run
```

## Endpoints

| # | Method | Path | Body fields | Res key |
|---|--------|------|-------------|---------|
| 1 | POST | `/oa/sub-accounts/{accountId}/orders` | sub_account, cus_id, side, symbol, quantity, type, limit_price/market_price, stock_type | `result` |
| 2 | PUT | `/oa/sub-accounts/{accountId}/orders/{orderId}` | quantity, price, channel | `result` |
| 3 | DELETE | `/oa/sub-accounts/{accountId}/orders/{orderId}` | sub_account, cus_id, channel | `result` |

Details & response shapes: [references/endpoints.md](./references/endpoints.md). Enums: [references/enums.md](./references/enums.md). Error codes: [references/error-codes.md](./references/error-codes.md). Safety details: [references/safety.md](./references/safety.md).

## Constraints

- **Write-enabled** — this skill overrides the shared "read-only" constraint. Uses `write-request.sh` for POST/PUT/DELETE.
- **One order per confirmation cycle** — never batch multiple orders. Complete the full 5-step protocol for each.
- **Price encoding** — `limit_price` = human price × 1000. Always display both values to the user.
- **Channel** — default to `ONLINE` unless the user specifies otherwise.
- **Credential safety** — never display full keys; mask with `********`. Never send credentials outside the configured `BASE_URL`.
- **Response handling** — always present results to the user immediately. Never silently discard a response.
- **Production detection** — if API key starts with `ak_live_`, add a `⚠ PRODUCTION` warning to every confirmation.
