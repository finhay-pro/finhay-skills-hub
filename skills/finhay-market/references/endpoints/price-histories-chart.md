# Price Histories Chart

## `GET /market/price-histories-chart`

Retrieve historical price data for charting. Returns columnar arrays for efficient rendering.

---

### OpenAPI Spec

```yaml
/market/price-histories-chart:
  get:
    summary: Get price history chart data
    operationId: getPriceHistoriesChart
    tags:
      - Price History
    parameters:
      - name: symbol
        in: query
        required: true
        description: Stock symbol
        schema:
          type: string
          example: VNM
      - name: resolution
        in: query
        required: true
        description: Chart resolution. Defaults to `1D`.
        schema:
          type: string
          enum:
            - 1D
            - 5
            - 15
            - 30
            - 1H
            - 4H
      - name: from
        in: query
        required: true
        description: Start timestamp in **seconds** (Unix epoch). Not milliseconds.
        schema:
          type: integer
          minimum: 0
          example: 1704067200
      - name: to
        in: query
        required: true
        description: End timestamp in **seconds** (Unix epoch). Not milliseconds.
        schema:
          type: integer
          minimum: 0
          example: 1711929600
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
                  $ref: '#/components/schemas/PriceHistoriesChart'
      '400':
        description: Validation error
        content:
          application/json:
            schema:
              type: object
              properties:
                status:
                  type: integer
                  example: 400
                error_code:
                  type: string
                  example: "400"
                message:
                  type: string
                  example: Invalid symbol
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    PriceHistoriesChart:
      type: object
      description: >
        Columnar arrays — all arrays are the same length.
        `time[i]`, `open[i]`, `close[i]`, `high[i]`, `low[i]`, `volume[i]`
        represent one data point.
      properties:
        symbol:
          type: string
          example: VNM
        resolution:
          type: string
          enum: [1D, 5, 15, 30, 1H, 4H]
          example: 1D
        time:
          type: array
          description: Unix timestamps (seconds)
          items:
            type: number
          example: [1704067200, 1704153600]
        open:
          type: array
          description: Open prices
          items:
            type: number
          example: [72000, 72500]
        close:
          type: array
          description: Close prices
          items:
            type: number
          example: [72500, 73000]
        high:
          type: array
          description: High prices
          items:
            type: number
          example: [73000, 73500]
        low:
          type: array
          description: Low prices
          items:
            type: number
          example: [71500, 72000]
        volume:
          type: array
          description: Trading volumes
          items:
            type: number
          example: [1500000, 1800000]
```

### Validation Rules

All parameters are validated before reaching the controller:

| Param | Rule |
|-------|------|
| `symbol` | Must exist, be a string, and not empty |
| `resolution` | Must exist and be a valid `Resolution` enum value (`1D`, `5`, `15`, `30`, `1H`, `4H`). Default is `1D` when omitted. |
| `from` | Must exist, be an integer >= 0 |
| `to` | Must exist, be an integer >= 0 |

### Notes

- `from` and `to` are in **seconds**, not milliseconds.
- All response arrays have the same length — index `i` across all arrays represents one candle.
- Data is served from cache when available, falling back to the database and then external API.
