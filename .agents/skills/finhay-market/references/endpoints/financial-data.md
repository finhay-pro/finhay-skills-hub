# Financial Data (All Types)

## `GET /market/financial-data`

Retrieve all financial data: gold, silver, crypto, bank rates, USD exchange rates, etc.

---

### OpenAPI Spec

```yaml
/market/financial-data:
  get:
    summary: Get all financial data
    operationId: getFinancialData
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
                    $ref: '#/components/schemas/FinancialData'
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    FinancialData:
      type: object
      properties:
        financial_type:
          type: string
          description: Type of financial data
          enum:
            - GOLD
            - SILVER
            - CRYPTO
            - BANK_INTEREST_RATE
            - USD_EXCHANGE_RATE
        name:
          type: string
          description: Display name of the financial type
        values:
          type: array
          description: >
            Array of financial data values. Shape varies by `financial_type`:
            single-value types use `FinancialDataSingleValue`,
            buy/sell types use `FinancialDataBuySellValue`,
            USD/VND types use `FinancialDataUSDVNDValue`.
          items:
            oneOf:
              - $ref: '#/components/schemas/FinancialDataSingleValue'
              - $ref: '#/components/schemas/FinancialDataBuySellValue'
              - $ref: '#/components/schemas/FinancialDataUSDVNDValue'
        last_updated:
          type: string
          description: ISO timestamp of last update

    FinancialDataSingleValue:
      type: object
      properties:
        name:
          type: string
        value:
          type: number
        change_percent:
          type: number

    FinancialDataBuySellValue:
      type: object
      properties:
        name:
          type: string
        buy_value:
          type: number
        sell_value:
          type: number
        change_percent:
          type: number

    FinancialDataUSDVNDValue:
      type: object
      properties:
        name:
          type: string
        usd_value:
          type: number
        vnd_value:
          type: number
```

### Notes

- This is the all-in-one endpoint. For specific data types, use the dedicated endpoints (`/gold`, `/silver`, `/bank-interest-rates`, etc.).
- USD exchange rate values are sorted by `sortValue`.
