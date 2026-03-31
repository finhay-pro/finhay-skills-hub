# Stock Realtime

## `GET /market/stock-realtime`

Retrieve realtime stock price data. Accepts **exactly one** of: `symbol`, `symbols`, or `exchange`.

---

### OpenAPI Spec

```yaml
/market/stock-realtime:
  get:
    summary: Get realtime stock data
    operationId: getStockRealtime
    tags:
      - Stock
    parameters:
      - name: symbol
        in: query
        description: Single stock symbol (e.g. `VNM`). Mutually exclusive with `symbols` and `exchange`.
        required: false
        schema:
          type: string
          example: VNM
      - name: symbols
        in: query
        description: Comma-separated stock symbols (e.g. `VNM,FPT,VIC`). Mutually exclusive with `symbol` and `exchange`.
        required: false
        schema:
          type: string
          example: VNM,FPT,VIC
      - name: exchange
        in: query
        description: Exchange code to get all stocks in an exchange. Mutually exclusive with `symbol` and `symbols`.
        required: false
        schema:
          type: string
          enum: [HOSE, HNX, UPCOM]
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
                result:
                  description: >
                    Single `StockRealtime` object when `symbol` is used;
                    array of `StockRealtime` when `symbols` or `exchange` is used.
                  oneOf:
                    - $ref: '#/components/schemas/StockRealtime'
                    - type: array
                      items:
                        $ref: '#/components/schemas/StockRealtime'
      '400':
        description: Invalid request — more than one of `symbol`, `symbols`, `exchange` provided
```

### Response Key

`result` (not `data` — this is the only endpoint that uses `result`)

### Components

```yaml
components:
  schemas:
    StockRealtime:
      type: object
      properties:
        symbol:
          type: string
          example: VNM
        price:
          type: number
          nullable: true
          example: 72500
        volume:
          type: number
          nullable: true
        change:
          type: number
          nullable: true
          description: Price change from reference
        changePercent:
          type: number
          nullable: true
          description: Price change percentage from reference
        ceiling:
          type: number
          nullable: true
          description: Ceiling price
        floor:
          type: number
          nullable: true
          description: Floor price
        reference:
          type: number
          nullable: true
          description: Reference price
        average:
          type: number
          nullable: true
          description: Average (medium) price
        high:
          type: number
          nullable: true
        low:
          type: number
          nullable: true
        open:
          type: number
          nullable: true
        close:
          type: number
          nullable: true
          description: Same as `price`
        buyPrice1:
          type: number
          nullable: true
        buyPrice2:
          type: number
          nullable: true
        buyPrice3:
          type: number
          nullable: true
        buyVol1:
          type: number
          nullable: true
        buyVol2:
          type: number
          nullable: true
        buyVol3:
          type: number
          nullable: true
        sellPrice1:
          type: number
          nullable: true
        sellPrice2:
          type: number
          nullable: true
        sellPrice3:
          type: number
          nullable: true
        sellVol1:
          type: number
          nullable: true
        sellVol2:
          type: number
          nullable: true
        sellVol3:
          type: number
          nullable: true
        totalVolume:
          type: number
          nullable: true
        totalValue:
          type: number
          nullable: true
        foreignBought:
          type: number
          nullable: true
        foreignSold:
          type: number
          nullable: true
        foreignRemain:
          type: number
          nullable: true
        remainBid:
          type: number
          nullable: true
        remainAsk:
          type: number
          nullable: true
        stockType:
          type: string
          enum: [STOCK, ETF, BOND, CW, FUTURES]
          description: Normalized stock type
        exchange:
          type: string
          enum: [HOSE, HNX, UPCOM]
          description: Normalized exchange code
        name:
          type: string
          example: CTCP Sữa Việt Nam
        createdAt:
          type: number
          description: Unix timestamp
        pe:
          type: number
          nullable: true
        pb:
          type: number
          nullable: true
        roe:
          type: number
          nullable: true
        marketCap:
          type: number
          nullable: true
        marketCapCategory:
          type: string
          nullable: true
          enum: [Micro Cap, Small Cap, Mid Cap, Large Cap]
        hasNewestNews:
          type: boolean
        stockSummary:
          type: string
          nullable: true
        additionalInfo:
          type: object
          nullable: true
        symbolStatus:
          type: string
          nullable: true
          description: KRX stocks only
        symbolStatusCode:
          type: string
          nullable: true
          description: KRX stocks only
        floorCode:
          type: string
          nullable: true
          description: KRX stocks only
        influenceScore:
          type: number
          nullable: true
```

### Notes

- `close` is always equal to `price`.
- `stockType` is normalized: ETF symbols are hardcoded to return `ETF` regardless of DB value.
- `exchange` is normalized: ETF symbols are hardcoded to return `HOSE`.
- `marketCapCategory` is computed from `marketCap` thresholds: Micro (<100B), Small (<1T), Mid (<10T), Large (>=10T VND).
- `symbolStatus`, `symbolStatusCode`, `floorCode` only present for KRX stocks.
