# Top Trending Cryptos

## `GET /market/financial-data/cryptos/top-trending`

Retrieve top trending cryptocurrencies.

---

### OpenAPI Spec

```yaml
/market/financial-data/cryptos/top-trending:
  get:
    summary: Get top trending cryptocurrencies
    operationId: getTopTrendingCryptos
    tags:
      - Financial Data
    parameters: []
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
                  type: array
                  items:
                    $ref: '#/components/schemas/CryptoCurrency'
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    CryptoCurrency:
      type: object
      properties:
        name:
          type: string
          description: Cryptocurrency name
          example: Bitcoin
        symbol:
          type: string
          description: Cryptocurrency symbol
          example: BTC
        icon_url:
          type: string
          description: Icon URL
          example: https://example.com/btc.png
        price:
          type: number
          description: Current price in USD
          example: 67500.25
        formatted_price:
          type: string
          description: Price formatted in Vietnamese locale
          example: "67.500,25"
        percent_change_1h:
          type: number
          description: Price change in the last 1 hour (%)
          example: 0.5
        percent_change_24h:
          type: number
          description: Price change in the last 24 hours (%)
          example: -1.2
        percent_change_7d:
          type: number
          description: Price change in the last 7 days (%)
          example: 3.8
        percent_change_30d:
          type: number
          description: Price change in the last 30 days (%)
          example: 12.5
        market_cap:
          type: number
          description: Market capitalization in USD
          example: 1325000000000
        last_30d_chart:
          type: string
          description: URL or data for 30-day sparkline chart
```
