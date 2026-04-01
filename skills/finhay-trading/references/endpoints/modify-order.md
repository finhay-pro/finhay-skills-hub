# Modify Order

## `PUT /trading/oa/sub-accounts/{subAccountId}/orders/{orderId}`

Modify the quantity and/or price of an existing order.

---

### OpenAPI Spec

```yaml
/trading/oa/sub-accounts/{subAccountId}/orders/{orderId}:
  put:
    summary: Modify an existing order
    operationId: updateOrder
    tags:
      - Order Execution
    parameters:
      - name: subAccountId
        in: path
        required: true
        description: Sub-account ID
        schema:
          type: string
      - name: orderId
        in: path
        required: true
        description: Order ID to modify (from order-book)
        schema:
          type: string
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/UpdateOrderRequest'
    responses:
      '200':
        description: Modification result
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

- `{subAccountId}` — from `.env`
- `{orderId}` — must be obtained from order-book query first

### Components

```yaml
components:
  schemas:
    UpdateOrderRequest:
      type: object
      properties:
        quantity:
          type: integer
          format: int64
          minimum: 1
          description: New quantity
        price:
          type: integer
          format: int64
          description: "New limit price in VND"
```

### Notes

- **Pre-check required**: Before modifying, query the order detail (`GET /trading/v1/accounts/{subAccountId}/order-book/{orderId}`) and verify the order is in a modifiable status.
- **Modifiable statuses**: Generally `SENT`, `WAITING_TO_SEND`. Orders that are `MATCHED`, `CANCELLED`, `COMPLETED`, `FAILED` cannot be modified.
- **Partially matched orders**: If an order has been partially matched, only the unmatched portion can be modified. The `rejected_reason` will indicate this.
- **Price encoding**: Same as place order — `price` = price in VND. No multiplication needed.
