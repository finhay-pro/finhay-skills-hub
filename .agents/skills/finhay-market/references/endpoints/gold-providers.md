# Gold Providers

## `GET /market/financial-data/gold-providers`

Retrieve gold prices grouped by provider (PNJ, DOJI, BTMC, SJC, etc.).

---

### OpenAPI Spec

```yaml
/market/financial-data/gold-providers:
  get:
    summary: Get gold prices by provider
    operationId: getGoldProviderData
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

- Returns gold prices from multiple providers: PNJ, DOJI, BTMC, SJC, etc.
- Each entry includes `provider` and `provider_icon` fields to identify the source.
