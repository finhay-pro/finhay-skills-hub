# Silver Chart

## `GET /market/financial-data/silver-chart`

Retrieve silver price chart data over N days.

---

### OpenAPI Spec

```yaml
/market/financial-data/silver-chart:
  get:
    summary: Get silver price chart data
    operationId: getSilverChartData
    tags:
      - Financial Data
    parameters:
      - name: days
        in: query
        required: false
        description: Number of days of history to return. Defaults to `30`.
        schema:
          type: integer
          default: 30
          example: 30
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
                  description: Chart data points
                  items:
                    type: object
```

### Response Key

`data`

### Notes

- Same behavior and shape as `/market/financial-data/gold-chart`, but for silver prices.
- If `days` is not provided or not a valid integer, defaults to `30`.
