# PnL Today

## `GET /trading/pnl-today/{userId}`

Retrieve today's profit and loss for a user.

---

### OpenAPI Spec

```yaml
/trading/pnl-today/{userId}:
  get:
    summary: Get today's PnL
    operationId: getPnlToday
    tags:
      - PnL
    parameters:
      - name: userId
        in: path
        required: true
        description: User ID
        schema:
          type: integer
          format: int64
          example: 123456
      - name: sub-account-id
        in: query
        required: false
        description: Sub-account ID filter. Use `ALL` for all sub-accounts.
        schema:
          type: string
          default: ALL
          example: "0001234567"
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
                  $ref: '#/components/schemas/PnlTodayResponse'
```

### Response Key

`data`

### Config Required

- `USER_ID` — used as `{userId}` path parameter

### Components

```yaml
components:
  schemas:
    PnlTodayResponse:
      type: object
      properties:
        sub_account_id:
          type: string
          description: Sub-account ID or `ALL`
          example: "0001234567"
        pnl_amount:
          type: integer
          format: int64
          description: Today's PnL amount (VND)
          example: 1500000
        pnl_rate:
          type: number
          format: double
          description: Today's PnL rate (percentage)
          example: 2.5
```

### Notes

- Uses `USER_ID` as the path parameter.
- `sub-account-id` query param defaults to `ALL` — returns aggregated PnL across all sub-accounts.
