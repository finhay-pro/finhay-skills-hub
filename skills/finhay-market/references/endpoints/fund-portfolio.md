# Fund Portfolio

## `GET /market/funds/{fund}/portfolio`

Retrieve the portfolio holdings of a specific fund for a given month.

---

### OpenAPI Spec

```yaml
/market/funds/{fund}/portfolio:
  get:
    summary: Get fund portfolio
    operationId: getFundPortfolio
    tags:
      - Funds
    parameters:
      - name: fund
        in: path
        required: true
        description: Fund code
        schema:
          type: string
          example: DCDS
      - name: month
        in: query
        required: false
        description: Month in format to filter portfolio (e.g. `2024-01`). If omitted, returns the latest available month.
        schema:
          type: string
          example: "2024-01"
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
                  $ref: '#/components/schemas/PortfolioFund'
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    PortfolioFund:
      type: object
      properties:
        month:
          type: string
          description: Portfolio month
          example: "2024-01"
        entries:
          type: array
          description: Portfolio holdings sorted by per_nav descending
          items:
            $ref: '#/components/schemas/PortfolioFundEntry'
        stocks_info:
          type: array
          description: Realtime stock info for the holdings
          items:
            $ref: '#/components/schemas/StockInfoV1'

    PortfolioFundEntry:
      type: object
      properties:
        fund_code:
          type: string
          example: DCDS
        symbol:
          type: string
          example: FPT
        sector:
          type: string
          example: Technology
        per_nav:
          type: number
          description: Percentage of NAV
          example: 8.5
        month:
          type: string
          example: "2024-01"

    StockInfoV1:
      type: object
      properties:
        symbol:
          type: string
          example: FPT
        name:
          type: string
          example: CTCP FPT
        exchange:
          type: string
          enum: [HOSE, HNX, UPCOM]
        floor:
          type: number
          description: Floor price
        ceiling:
          type: number
          description: Ceiling price
        reference:
          type: number
          description: Reference price
        stock_type:
          type: string
          enum: [STOCK, ETF, BOND, CW, FUTURES]
        price:
          type: number
        price_change:
          type: number
        price_change_percent:
          type: number
        volume:
          type: number
          nullable: true
        total_volume:
          type: number
          nullable: true
```
