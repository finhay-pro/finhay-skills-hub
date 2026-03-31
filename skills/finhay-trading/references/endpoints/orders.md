# Orders

## `GET /trading/sub-accounts/{subAccountId}/orders`

Retrieve order history for a sub-account within a date range.

---

### OpenAPI Spec

```yaml
/trading/sub-accounts/{subAccountId}/orders:
  get:
    summary: Get order history
    operationId: getOrders
    tags:
      - Orders
    parameters:
      - name: subAccountId
        in: path
        required: true
        description: Sub-account ID
        schema:
          type: string
          example: "0001234567"
      - name: fromDate
        in: query
        required: true
        description: Start date (inclusive)
        schema:
          type: string
          format: date
          example: "2024-01-01"
      - name: toDate
        in: query
        required: true
        description: End date (inclusive)
        schema:
          type: string
          format: date
          example: "2024-01-31"
      - name: page
        in: query
        required: false
        description: Page number
        schema:
          type: integer
          default: 1
          example: 1
      - name: orderStatus
        in: query
        required: false
        description: Filter by order status
        schema:
          type: string
          default: ALL
          example: ALL
      - name: symbol
        in: query
        required: false
        description: Filter by stock symbol
        schema:
          type: string
          default: ALL
          example: ALL
    responses:
      '200':
        description: Successful response
        content:
          application/json:
            schema:
              type: object
              properties:
                status:
                  type: integer
                  example: 200
                result:
                  $ref: '#/components/schemas/OrderHistoryResult'
```

### Response Key

`result`

### Config Required

- `{subAccountId}` — inferred via `infer-sub-account.sh`

### Components

```yaml
components:
  schemas:
    OrderHistoryResult:
      type: object
      properties:
        data:
          type: array
          items:
            $ref: '#/components/schemas/OrderHistoryEntry'

    OrderHistoryEntry:
      type: object
      properties:
        order_id:
          type: string
          description: Order ID
        account_id:
          type: string
        transaction_date:
          type: string
          description: Transaction date
        symbol:
          type: string
          example: VNM
        order_side:
          type: string
          enum: [BUY, SELL, UNKNOWN]
          description: Order side
        order_quantity:
          type: integer
          format: int64
          description: Ordered quantity
        limit_price:
          type: integer
          format: int64
          description: Limit (quote) price
        market_price:
          type: string
          description: Market price at order time
        execute_quantity:
          type: integer
          format: int64
          description: Executed quantity
        execute_price:
          type: integer
          format: int64
          description: Executed price
        order_status:
          type: string
          enum:
            - WAITING_TO_ACTIVATE
            - WAITING_TO_SEND
            - SENDING
            - SENT
            - FIXING
            - FIXED
            - CANCELLED
            - CANCELLING
            - MATCHED
            - EXPIRED
            - MATCHED_ALL
            - REJECTED
            - COMPLETED
            - FAILED
            - EXPIRED_ACTIVATION_TIME
            - EXPIRED_AUTHORIZATION
            - RECEIVED
            - INTERNAL_SENDING
            - INTERNAL_CANCELLED
            - SENDING_TO_CORE
            - CANCEL_BY_STOCK_EVENT
            - WAIT_FOR_ACCEPTING
            - ACCEPTED
            - ACCEPTING
            - REJECTING
            - UNKNOWN
        fee_amount:
          type: integer
          format: int64
          description: Fee amount
        tax_amount:
          type: integer
          format: int64
          description: Tax amount
        execute_amount:
          type: integer
          format: int64
          description: Executed amount
        order_type:
          type: string
          enum: [LO, MP, ATO, ATC, MAK, MOK, MTL, PLO, FOK, FAK]
          description: Order type
```

### Notes

- `fromDate` and `toDate` are **required** — omitting them will cause an error.
- Use `ALL` for `orderStatus` and `symbol` to get all orders without filtering.
