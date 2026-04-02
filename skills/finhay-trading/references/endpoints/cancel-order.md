# Cancel Order

## `DELETE /trading/oa/sub-accounts/{subAccountId}/orders/{orderId}`

Cancel an existing order. Note: this is a DELETE request **with a body**.

---

### OpenAPI Spec

```yaml
/trading/oa/sub-accounts/{subAccountId}/orders/{orderId}:
  delete:
    summary: Cancel an existing order
    operationId: cancelOrder
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
        description: Order ID to cancel (from order-book)
        schema:
          type: string
    requestBody:
      required: true
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/CancelOrderRequest'
    responses:
      '200':
        description: Cancellation result
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
- `sub_account` in body — use `SUB_ACCOUNT_EXT_NORMAL` or `SUB_ACCOUNT_EXT_MARGIN` from `.env`
- `{orderId}` — must be obtained from order-book query first

### Components

```yaml
components:
  schemas:
    CancelOrderRequest:
      type: object
      required: [sub_account]
      properties:
        sub_account:
          type: string
          description: Extended sub-account ID (use SUB_ACCOUNT_EXT_NORMAL or SUB_ACCOUNT_EXT_MARGIN from .env)
          example: "120C000008.1"
```

### Notes

- **Pre-check required**: Before cancelling, query the order detail (`GET /trading/v1/accounts/{subAccountId}/order-book/{orderId}`) and verify the order is in a cancellable status.
- **Cancellable statuses**: Generally `SENT`, `WAITING_TO_SEND`. Orders that are `MATCHED`, `MATCHED_ALL`, `CANCELLED`, `COMPLETED`, `FAILED` cannot be cancelled.
- **Partially matched orders**: If partially matched, cancellation applies only to the unmatched portion.
- **DELETE with body**: This endpoint requires a request body despite being a DELETE method. The `write-request.sh` script handles this correctly.
