# Trading Account Detail

## `GET /trading/accounts/{subAccountId}/summary`

Provides the specific financial position of a single stock trading sub-account. Use this to retrieve granular data such as available cash for stocks, margin debt, and purchasing power.

---

### OpenAPI Spec

```yaml
/trading/accounts/{subAccountId}/summary:
  get:
    summary: Get specific trading account details
    operationId: getTradingAccountDetail
    tags:
      - Account
    parameters:
      - name: subAccountId
        in: path
        required: true
        description: Sub-account ID (NORMAL or MARGIN)
        schema:
          type: string
```

### Response Key

`result`

### Components

```yaml
components:
  schemas:
    TradingAccountDetail:
      type: object
      properties:
        balance:
          type: integer
          description: Total available balance in this sub-account
        ci_balance:
          type: integer
          description: Actual cash balance
        receiving_amt:
          type: integer
          description: Amount from sold securities pending settlement
        total_debt_amt:
          type: integer
          description: Total outstanding margin debt
        margin_rate:
          type: integer
          description: Current margin ratio
```

### Notes

- This is a **stock-specific** endpoint. It does not include funds, bonds, or other non-trading assets.
