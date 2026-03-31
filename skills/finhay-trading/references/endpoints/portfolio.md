# Portfolio

## `GET /trading/v2/sub-accounts/{subAccountId}/portfolio`

Retrieve portfolio holdings with realtime prices and PnL for a sub-account.

---

### OpenAPI Spec

```yaml
/trading/v2/sub-accounts/{subAccountId}/portfolio:
  get:
    summary: Get portfolio
    operationId: getPortfolio
    tags:
      - Portfolio
    parameters:
      - name: subAccountId
        in: path
        required: true
        description: Sub-account ID
        schema:
          type: string
          example: "0001234567"
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
                  $ref: '#/components/schemas/GetPortfolioResponse'
```

### Response Key

`data`

### Config Required

- `{subAccountId}` — inferred via `infer-sub-account.sh`

### Components

```yaml
components:
  schemas:
    GetPortfolioResponse:
      type: object
      properties:
        portfolio:
          type: array
          items:
            $ref: '#/components/schemas/PortfolioEntry'
        is_snapshot:
          type: boolean
          description: Whether the data is from a cached snapshot

    PortfolioEntry:
      type: object
      properties:
        sub_account_id:
          type: string
        symbol:
          type: string
          example: VNM
        securities_type:
          type: string
          description: Type of securities
        total:
          type: integer
          format: int64
          description: Total shares held
        available:
          type: integer
          format: int64
          description: Shares available to sell
        blocked:
          type: integer
          format: int64
          description: Blocked shares
        mortgage:
          type: integer
          format: int64
          description: Mortgaged shares
        vsd_mortgage:
          type: integer
          format: int64
          description: VSD mortgaged shares
        restrict:
          type: integer
          format: int64
          description: Restricted shares
        receiving_right:
          type: integer
          format: int64
        receiving_t0:
          type: integer
          format: int64
          description: Receiving shares T+0
        receiving_t1:
          type: integer
          format: int64
          description: Receiving shares T+1
        receiving_t2:
          type: integer
          format: int64
          description: Receiving shares T+2
        matching_amount:
          type: integer
          format: int64
        withdraw:
          type: integer
          format: int64
        cost_price:
          type: integer
          format: int64
          description: Average cost price
        basic_price:
          type: integer
          format: int64
          description: Basic (reference) price
        is_sellable:
          type: boolean
          description: Whether the stock can be sold
        custodycd:
          type: string
        pnl_amount:
          type: integer
          format: int64
          description: Profit/Loss amount
        pnl_rate:
          type: number
          format: double
          description: Profit/Loss rate (percentage)
        close_price:
          type: integer
          format: int64
          description: Close (current) price
        cost_price_amount:
          type: integer
          format: int64
          description: Total cost value
        basic_price_amount:
          type: integer
          format: int64
          description: Total basic value
        total_pnl:
          type: integer
          format: int64
          description: Total PnL
        sending_t0:
          type: integer
          format: int64
        sending_t1:
          type: integer
          format: int64
        sending_t2:
          type: integer
          format: int64
        has_newest_news:
          type: boolean
          description: Whether the stock has recent news
        trade:
          type: integer
          format: int64
          deprecated: true
          description: Deprecated field
```

### Notes

- `is_snapshot` indicates whether the response came from cache.
- App version `5.32.8` forces `CACHE` mode regardless of the query parameter.
- `close_price` is enriched from realtime price data.
- `trade` field is deprecated.
