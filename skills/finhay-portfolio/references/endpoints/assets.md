# User Assets Summary

## `GET /users/v3/users/{userId}/assets/summary`

Retrieve account balance and asset overview for a user, including net asset value, product breakdown, cash, debt, and P&L.

---

### OpenAPI Spec

```yaml
/users/v3/users/{userId}/assets/summary:
  get:
    summary: Get user assets summary
    operationId: getVNSCAssetsSummaryV4
    tags:
      - Account
    parameters:
      - name: userId
        in: path
        required: true
        description: User ID
        schema:
          type: integer
          example: 123456
      - name: cache-control
        in: query
        required: false
        description: Cache control policy
        schema:
          type: string
          enum: [CACHE, NOCACHE]
          default: CACHE
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
                  $ref: '#/components/schemas/UserAssetsSummaryResponse'
```

### Response Key

`data`

### Config Required

- `{userId}` — use `$USER_ID` from env

### Components

```yaml
components:
  schemas:
    UserAssetsSummaryResponse:
      type: object
      properties:
        net_asset_value:
          type: number
          description: Total net asset value
        products:
          $ref: '#/components/schemas/ProductsSummary'
        money:
          $ref: '#/components/schemas/MoneySummary'
        debt:
          $ref: '#/components/schemas/DebtSummary'
        pnl:
          $ref: '#/components/schemas/PnlSummary'

    ProductsSummary:
      type: object
      properties:
        total:
          type: number
          description: Total product value
        stock:
          type: number
          description: Stock value
        fund:
          type: number
          description: Fund value
        saving:
          type: number
          nullable: true
          description: Saving amount
        bond:
          type: number
          description: Bond value
        hay0:
          type: number
          description: Hay0 NAV
        hay0_interest:
          type: number
          description: Hay0 interest
        hay0_depositing:
          type: number
          description: Hay0 amount being deposited
        hay0_withdrawing:
          type: number
          description: Hay0 amount being withdrawn

    MoneySummary:
      type: object
      properties:
        total:
          type: number
          description: Total cash
        ci_balance:
          type: number
          description: Cash balance in account
        ca_receiving:
          type: number
          description: Dividend cash pending
        emk_amt:
          type: number
          description: Other blocked funds
        receiving_amt:
          type: number
          description: Cash to receive
        baldefovd:
          type: number
          description: Available withdrawable amount

    DebtSummary:
      type: object
      properties:
        total:
          type: number
          description: Total debt
        secure_amount:
          type: number
          description: Secured loan amount
        advance_amt:
          type: number
          description: Advanced amount
        sms_fee_amt:
          type: number
          description: SMS fee amount
        cidepo_fee_acr:
          type: number
          description: CIDEPO fee accrual
        owe_deposit:
          type: number
          description: Deposit owed

    PnlSummary:
      type: object
      properties:
        stock:
          $ref: '#/components/schemas/PnlEntry'
        fund:
          $ref: '#/components/schemas/PnlEntry'

    PnlEntry:
      type: object
      properties:
        pnl:
          type: number
          description: Profit/loss amount
        pnl_rate:
          type: number
          description: Profit/loss rate
```

### Notes

- For Level 0/1 users, `stock`, `fund`, `bond` in `products` and `pnl` entries return `0`.
- `saving` in `products` may be `null`.
- Supports caching via `cache-control` query parameter; defaults to `CACHE`.
