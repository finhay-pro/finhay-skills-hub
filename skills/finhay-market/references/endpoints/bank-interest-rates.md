# Bank Interest Rates

## `GET /market/financial-data/bank-interest-rates`

Retrieve bank deposit interest rates.

---

### OpenAPI Spec

```yaml
/market/financial-data/bank-interest-rates:
  get:
    summary: Get bank interest rates
    operationId: getBankInterestRates
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
                  type: object
                  description: >
                    Bank interest rate data. Structure depends on cached data.
                    Returns empty object `{}` if data has not been cached yet.
```

### Response Key

`data`

### Notes

- Data is served from Redis cache (`DATAFEED_FINANCIAL_DATA_BANK_INTEREST_RATES` key).
- May return `{}` if no data has been cached yet.
- The exact structure of the cached data depends on the upstream sync job.
