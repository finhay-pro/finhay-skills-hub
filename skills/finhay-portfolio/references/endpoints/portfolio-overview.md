# Portfolio Overview

## `GET /users/v4/users/{userId}/assets/summary`

Retrieve a comprehensive summary of a user's entire wealth, including Net Asset Value (NAV), product breakdown, cash positions, debts, and profit/loss.

---

### OpenAPI Spec

```yaml
/users/v4/users/{userId}/assets/summary:
  get:
    summary: Get total portfolio overview
    operationId: getTotalPortfolioOverview
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

### Components

```yaml
components:
  schemas:
    UserAssetsSummaryResponse:
      type: object
      properties:
        net_asset_value:
          type: number
          description: Total net asset value (Total Wealth)
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
          description: Total stock value
        fund:
          type: number
          description: Total fund value
        saving:
          type: number
          nullable: true
          description: Total saving amount
        bond:
          type: number
          description: Total bond value
        hay0:
          type: number
          description: Hay0 NAV
        hay0_interest:
          type: number
          description: Hay0 interest earned
        hay0_depositing:
          type: number
          description: Hay0 amount in deposit queue
        hay0_withdrawing:
          type: number
          description: Hay0 amount in withdrawal queue

    MoneySummary:
      type: object
      properties:
        total:
          type: number
          description: Total cash across all profiles
        ci_balance:
          type: number
          description: Cash balance available in account
        ca_receiving:
          type: number
          description: Pending dividend cash
        emk_amt:
          type: number
          description: Other blocked/earmarked funds
        receiving_amt:
          type: number
          description: Cash to receive from sold assets
        baldefovd:
          type: number
          description: Total available withdrawable amount

    DebtSummary:
      type: object
      properties:
        total:
          type: number
          description: Total outstanding debt
        secure_amount:
          type: number
          description: Secured loan amount
        advance_amt:
          type: number
          description: Advanced cash amount
        sms_fee_amt:
          type: number
          description: Accrued SMS fees
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
          description: Profit/loss rate (%)
```

### Notes

- This is the **primary global endpoint** for checking a user's net worth and overall financial health.
- For Level 0/1 users, some fields like `stock` or `fund` may return `0`.
- Supports caching via `cache-control` query parameter (default: `CACHE`).
