# Silver Data

## `GET /market/financial-data/silver`

Retrieve silver price data.

---

### OpenAPI Spec

```yaml
/market/financial-data/silver:
  get:
    summary: Get silver price data
    operationId: getSilverData
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
                    $ref: '#/components/schemas/CommodityIndexData'
```

### Response Key

`data`

### Components

Uses the same `CommodityIndexData` schema as [`gold.md`](./gold.md).

### Notes

- Same response shape as `/market/financial-data/gold`.
