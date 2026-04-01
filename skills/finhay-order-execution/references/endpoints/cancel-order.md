# Cancel Order

## `DELETE /oa/sub-accounts/{accountId}/orders/{orderId}`

Cancel an existing order. Note: this is a DELETE request **with a body**.

---

### OpenAPI Spec

```yaml
/oa/sub-accounts/{accountId}/orders/{orderId}:
  delete:
    summary: Cancel an existing order
    operationId: cancelOrder
    tags:
      - Order Execution
    parameters:
      - name: accountId
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

- `{accountId}` — from `.env`
- `{orderId}` — must be obtained from order-book query first

### Components

```yaml
components:
  schemas:
    CancelOrderRequest:
      type: object
      required: [sub_account, cus_id]
      properties:
        sub_account:
          type: string
          description: Sub-account ID (same as path accountId)
          example: "0881234567"
        cus_id:
          type: string
          description: Customer ID
          example: "088C123456"
        channel:
          type: string
          enum: [ONLINE, MOBILE_ANDROID, MOBILE_IOS, INTERNAL]
          description: Channel. Default ONLINE.
          default: ONLINE
```

### Notes

- **Pre-check required**: Before cancelling, query the order detail (`GET /trading/v1/accounts/{accountId}/order-book/{orderId}`) and verify the order is in a cancellable status.
- **Cancellable statuses**: Generally `SENT`, `WAITING_TO_SEND`. Orders that are `MATCHED`, `MATCHED_ALL`, `CANCELLED`, `COMPLETED`, `FAILED` cannot be cancelled.
- **Partially matched orders**: If partially matched, cancellation applies only to the unmatched portion.
- **DELETE with body**: This endpoint requires a request body despite being a DELETE method. The `write-request.sh` script handles this correctly.
