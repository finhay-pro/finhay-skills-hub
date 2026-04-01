# Macro Data

## `GET /market/financial-data/macro`

Retrieve macroeconomic data for Vietnam or the US.

---

### OpenAPI Spec

```yaml
/market/financial-data/macro:
  get:
    summary: Get macroeconomic data
    operationId: getMacroData
    tags:
      - Financial Data
    parameters:
      - name: type
        in: query
        required: true
        description: Macro data type
        schema:
          type: string
          enum:
            - IIP
            - CPI
            - PMI
            - PCE
            - CORE_PCE
            - NFP
            - GOODS_RETAIL
            - SERVICE_RETAIL
            - TOTAL_EXPORT
            - FDI_EXPORT
            - DOMESTIC_EXPORT
            - FED_FUNDS_RATE
            - INTERBANK_RATE
            - GOVERNMENT_10Y_BOND_YIELD
            - UNEMPLOYMENT_RATE
      - name: country
        in: query
        required: true
        description: Country code
        schema:
          type: string
          enum:
            - VN
            - US
      - name: period
        in: query
        required: false
        description: Time period filter
        schema:
          type: string
          enum:
            - ONE_MONTH
            - ONE_YEAR
            - YTD
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
                    $ref: '#/components/schemas/MacroData'
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    MacroData:
      type: object
      properties:
        type:
          type: string
          description: Macro data type
          enum: [IIP, CPI, PMI, PCE, CORE_PCE, NFP, GOODS_RETAIL, SERVICE_RETAIL, TOTAL_EXPORT, FDI_EXPORT, DOMESTIC_EXPORT, FED_FUNDS_RATE, INTERBANK_RATE, GOVERNMENT_10Y_BOND_YIELD, UNEMPLOYMENT_RATE]
          example: CPI
        country:
          type: string
          enum: [VN, US]
          example: VN
        month:
          type: string
          description: Year-month in `YYYY-MM` format
          example: "2024-03"
        value:
          type: number
          description: Macro indicator value
          example: 3.5
        date:
          type: string
          nullable: true
          description: Exact date in `YYYY-MM-DD` format (if available)
          example: "2024-03-15"
```

### Notes

- `type` and `country` are required. `period` is optional.
- Data is cached with a TTL of 360 seconds.
- `month` is formatted as `YYYY-MM` from year/month stored in DB.
- `date` is only present when the exact date is available in the source data.
