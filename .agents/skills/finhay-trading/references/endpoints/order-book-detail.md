# Order Book Detail

## `GET /trading/v1/accounts/{subAccountId}/order-book/{orderId}`

Retrieve detail for a specific order from the order book.

---

### OpenAPI Spec

```yaml
/trading/v1/accounts/{subAccountId}/order-book/{orderId}:
  get:
    summary: Get order book detail
    operationId: getOrderBookDetail
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
      - name: orderId
        in: path
        required: true
        description: Order ID
        schema:
          type: string
          example: "ORD123456"
      - name: cache-control
        in: query
        required: false
        description: Cache control policy
        schema:
          type: string
          enum: [CACHE, NOCACHE]
          default: NOCACHE
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
                data:
                  $ref: '#/components/schemas/OrderBookEntry'
```

### Response Key

`data`

### Config Required

- `{subAccountId}` — inferred via `infer-sub-account.sh`

### Components

Uses the same `OrderBookEntry` schema as [`order-book.md`](./order-book.md), with an additional field:

```yaml
components:
  schemas:
    OrderBookEntry:
      # ... all fields from order-book.md, plus:
      properties:
        strategy_id:
          type: string
          nullable: true
          description: Strategy ID if the order is linked to a strategy
```

### Notes

- Returns a **single** `OrderBookEntry` object (not an array).
- If the order is a core order, the `orderId` is resolved internally before lookup.
- `strategy_id` is populated from the intra-day order record if available.
