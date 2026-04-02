# Place Order

## `POST /trading/oa/sub-accounts/{subAccountId}/orders`

Place a new stock order on the exchange.

---

### OpenAPI Spec

```yaml
/trading/oa/sub-accounts/{subAccountId}/orders:
  post:
    summary: Place a new order
    operationId: createOrder
    tags:
      - Order Execution
    parameters:
      - name: subAccountId
        in: path
        required: true
        description: Sub-account ID (e.g. "0881234567")
        schema:
          type: string
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/CreateOrderRequest'
    responses:
      '200':
        description: Order result (may contain per-order errors in result[].code)
        content:
          application/json:
            schema:
              type: object
              properties:
                error_code:
                  type: string
                  nullable: true
                message:
                  type: string
                  nullable: true
                result:
                  type: array
                  items:
                    $ref: '#/components/schemas/OrderResponse'
```

### Response Key

`result`

### Config Required

- `{subAccountId}` — use `SUB_ACCOUNT_NORMAL` or `SUB_ACCOUNT_MARGIN` from `.env`
- `sub_account` in body — use `SUB_ACCOUNT_EXT_NORMAL` or `SUB_ACCOUNT_EXT_MARGIN` from `.env` (written by `infer-sub-account.sh`)

### Components

```yaml
components:
  schemas:
    CreateOrderRequest:
      type: object
      required: [side, symbol, quantity, type]
      properties:
        sub_account:
          type: string
          description: Sub-account ID
          example: "120C000008.1"
        side:
          type: string
          enum: [BUY, SELL]
          description: Order side
        symbol:
          type: string
          description: Stock symbol (e.g. HPG, VNM, FPT)
          example: "HPG"
        quantity:
          type: integer
          format: int64
          minimum: 1
          description: Number of shares
          example: 100
        type:
          type: string
          enum: [LIMIT, MARKET]
          description: Order type. Determines which price field to use.
        limit_price:
          type: integer
          format: int64
          nullable: true
          description: "Limit price in VND. Set when type=LIMIT, null when type=MARKET."
          example: 25500
        market_price:
          type: string
          nullable: true
          enum: [MP, ATO, ATC, MAK, MOK, MTL, PLO, FOK, FAK]
          description: "Market price type. Set when type=MARKET, null when type=LIMIT."
        stock_type:
          type: string
          enum: [STOCK, BOND, FUND_CERTIFICATE, WARRANT, ETF]
          description: Securities type. Default STOCK for most orders.
          default: STOCK

    OrderResponse:
      type: object
      properties:
        order_id:
          type: string
          description: Exchange order ID
        account_id:
          type: string
        transaction_date:
          type: string
        symbol:
          type: string
        order_side:
          type: string
          enum: [BUY, SELL]
        order_quantity:
          type: integer
          format: int64
        limit_price:
          type: integer
          format: int64
        market_price:
          type: string
        execute_quantity:
          type: integer
          format: int64
        execute_price:
          type: integer
          format: int64
        order_status:
          type: string
          enum: [RECEIVED, SENT, MATCHED, CANCELLED, REJECTED, FAILED]
          description: Initial status after placement (usually RECEIVED or SENT)
        fee_amount:
          type: number
        tax_amount:
          type: number
        execute_amount:
          type: integer
          format: int64
        order_type:
          type: string
          enum: [LO, MP, ATO, ATC, MAK, MOK, MTL, PLO, FOK, FAK]
        code:
          type: string
          nullable: true
          description: Error code if order was rejected. See error-codes.md.
        rejected_reason:
          type: string
          nullable: true
          description: Human-readable rejection reason
        lot:
          type: string
          enum: [EVEN, ODD]
          description: "EVEN = round lot (≥100 shares), ODD = odd lot (1-99 shares)"
```

### Notes

- **Price encoding**: `limit_price` = price in VND. Example: stock price 25,500 VND → `limit_price: 25500`. No multiplication needed.
- **type determines price field**: Both `limit_price` and `market_price` are always present in the body. When `type=LIMIT`: set `limit_price` to price in VND, set `market_price` to `null`. When `type=MARKET`: set `market_price` to the market price type (e.g. `ATC`, `ATO`, `MP`), set `limit_price` to `null`.
- **stock_type**: Default `STOCK` for equities. Use `BOND` for bonds, `ETF` for ETFs, etc.
- **Lot size**: HOSE/HNX round lots are 100 shares. Orders of 1-99 shares are odd lots (`ODD`) with limited order types (LO only).
- **Order type by exchange**: HOSE supports LO/MP/ATO/ATC. HNX supports LO/MTL/MOK/MAK/PLO/ATC. UPCOM supports LO only.
- A successful response does not guarantee execution — the order enters the exchange queue. Check order-book for final status.
