---
name: finhay-trading
description: "Owner identity, account balances, portfolio, orders, and profit/loss and order execution (place, modify, cancel stock orders). Use when user asks about their account identity, trading account, stock holdings, order history, PnL, or wants to place, modify, or cancel orders"
license: MIT
metadata:
  author: Finhay Securities
  version: "1.1.0"
  homepage: "https://fhsc.com.vn/"
---

# Finhay Trading

User and trading data via the Finhay Securities Open API. Includes read-only queries (account, portfolio, orders) and write operations (place, modify, cancel orders).

## Pre-flight

See [pre-flight checks](./_shared/preflight.md). Required: `FINHAY_API_KEY`, `FINHAY_API_SECRET`. `USER_ID` is populated by `infer-sub-account.sh`.

### Sub-account setup

Run once after credentials are configured — this fetches owner identity and all sub-accounts, then saves them to `.env`:

```bash
../_shared/scripts/infer-sub-account.sh
```

This writes `USER_ID`, `SUB_ACCOUNT_NORMAL`, `SUB_ACCOUNT_EXT_NORMAL`, and/or `SUB_ACCOUNT_MARGIN`, `SUB_ACCOUNT_EXT_MARGIN` to `~/.finhay/credentials/.env`.

## Making a Request

Use [request.sh](../_shared/scripts/request.sh) for every read call. Substitute `{subAccountId}` and `{userId}` before calling — the signed path must be the final path.

When a request requires `{subAccountId}`, **ask the user which sub-account type** they want to use (NORMAL or MARGIN), then read the corresponding value from `.env`:

```bash
# Load credentials
source ~/.finhay/credentials/.env

# Owner
./_shared/scripts/request.sh GET "/users/oa/me"

# Trading — use SUB_ACCOUNT_NORMAL or SUB_ACCOUNT_MARGIN based on user choice
../_shared/scripts/request.sh GET "/trading/accounts/$SUB_ACCOUNT_NORMAL/summary"
../_shared/scripts/request.sh GET "/trading/sub-accounts/$SUB_ACCOUNT_MARGIN/orders" "fromDate=2024-01-01&toDate=2024-01-31"
../_shared/scripts/request.sh GET "/trading/v2/sub-accounts/$SUB_ACCOUNT_NORMAL/portfolio"
../_shared/scripts/request.sh GET "/trading/pnl-today/$USER_ID"
../_shared/scripts/request.sh GET /trading/market/session "exchange=HOSE"
```

---

## Order Execution

> **DANGER — REAL MONEY OPERATIONS.** Placing, modifying, and cancelling stock orders on the Vietnam stock exchange involves real money. Every action is **irreversible once matched**. Follow the Safety Protocol below for **every** write operation — no exceptions.

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

- **Place BUY/SELL**: `GET /trading/sub-accounts/{subAccountId}/trade-info?symbol={symbol}&side={BUY|SELL}&quote_price={price}` — for BUY: check `pp0` (buying power) >= quantity x price. For SELL: check `available_quantity` >= quantity.
- **Modify/Cancel**: `GET /trading/v1/accounts/{subAccountId}/order-book/{orderId}` — check the order exists and is in a modifiable/cancellable status.

Use `request.sh` (read-only script) for these checks.

### Step 3 — Confirmation display

Present this block to the user **before** executing:

```
╔══════════════════════════════════════╗
║        ORDER CONFIRMATION            ║
╠══════════════════════════════════════╣
║  Action:    PLACE / MODIFY / CANCEL  ║
║  Side:      BUY / SELL               ║
║  Symbol:    HPG                      ║
║  Quantity:  100                      ║
║  Price:     25,500 VND               ║
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

## Making a Write Request

Use `write-request.sh` (not `request.sh`) for all write operations. The script handles HMAC-SHA256 signing with body hash automatically.

```bash
source ~/.finhay/credentials/.env

# Place order
../_shared/scripts/write-request.sh POST \
  "/trading/oa/sub-accounts/$SUB_ACCOUNT_NORMAL/orders" \
  '{"sub_account":"'"$SUB_ACCOUNT_EXT_NORMAL"'","side":"BUY","symbol":"HPG","quantity":100,"type":"LIMIT","limit_price":25500,"stock_type":"STOCK"}'

# Modify order
../_shared/scripts/write-request.sh PUT \
  "/trading/oa/sub-accounts/$SUB_ACCOUNT_NORMAL/orders/ORDER_ID" \
  '{"quantity":200,"price":26000}'

# Cancel order
../_shared/scripts/write-request.sh DELETE \
  "/trading/oa/sub-accounts/$SUB_ACCOUNT_NORMAL/orders/ORDER_ID" \
  '{"sub_account":"'"$SUB_ACCOUNT_EXT_NORMAL"'"}'

# Dry run (preview request without sending)
../_shared/scripts/write-request.sh POST \
  "/trading/oa/sub-accounts/$SUB_ACCOUNT_NORMAL/orders" \
  '{"side":"BUY","symbol":"HPG","quantity":100}' --dry-run
```

## Read Endpoints

| Endpoint | Path param | Key params | Res key |
|----------|------------|------------|---------|
| `/users/oa/me` | — | — | `result` |
| `/trading/accounts/{subAccountId}/summary` | ask user | — | `result` |
| `/trading/sub-accounts/{subAccountId}/asset-summary` | ask user | — | `data` |
| `/trading/sub-accounts/{subAccountId}/orders` | ask user | `fromDate`, `toDate` | `result` |
| `/trading/v1/accounts/{subAccountId}/order-book` | ask user | — | `result` |
| `/trading/v1/accounts/{subAccountId}/order-book/{orderId}` | ask user | `orderId` (path) | `data` |
| `/trading/v2/sub-accounts/{subAccountId}/portfolio` | ask user | — | `data` |
| `/trading/pnl-today/{userId}` | `USER_ID` | — | `data` |
| `/trading/v5/account/{subAccountId}/user-rights` | ask user | — | `result` |
| `/trading/sub-accounts/{subAccountId}/trade-info` | ask user | `symbol`, `side`, `quote_price` | `result` |
| `/trading/market/session` | — | `exchange` | `result` |

Path versions (`v1`, `v2`, `v5`) are historical — always use the exact version above.

## Write Endpoints (Order Execution)

| # | Method | Path | Body fields | Res key |
|---|--------|------|-------------|---------|
| 1 | POST | `/trading/oa/sub-accounts/{subAccountId}/orders` | sub_account, side, symbol, quantity, type, limit_price/market_price, stock_type | `result` |
| 2 | PUT | `/trading/oa/sub-accounts/{subAccountId}/orders/{orderId}` | quantity, price | `result` |
| 3 | DELETE | `/trading/oa/sub-accounts/{subAccountId}/orders/{orderId}` | sub_account | `result` |

Details & response shapes: [references/endpoints.md](./references/endpoints.md). Enums: [references/enums.md](./references/enums.md). Error codes: [references/error-codes.md](./references/error-codes.md). Safety details: [references/safety.md](./references/safety.md).

## Constraints

See [shared constraints](../_shared/constraints.md), plus:

- `fromDate` and `toDate` are always required for the orders endpoint.
- When `{subAccountId}` is needed, ask the user to choose between NORMAL and MARGIN, then use `SUB_ACCOUNT_NORMAL` or `SUB_ACCOUNT_MARGIN` from `.env`.
- **Write-enabled** — this skill overrides the shared "read-only" constraint for order execution. Uses `write-request.sh` for POST/PUT/DELETE.
- **One order per confirmation cycle** — never batch multiple orders. Complete the full 5-step protocol for each.
- **Price encoding** — `limit_price` = price in VND (e.g. 25500 for 25,500 VND). No multiplication needed.
- **Channel** — default to `ONLINE` unless the user specifies otherwise.
- **Credential safety** — never display full keys; mask with `********`. Never send credentials outside the configured `BASE_URL`.
- **Production detection** — if API key starts with `ak_live_`, add a `⚠ PRODUCTION` warning to every confirmation.
