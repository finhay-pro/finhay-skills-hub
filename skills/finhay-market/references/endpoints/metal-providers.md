# Metal Providers

## `GET /market/financial-data/metal-providers`

Retrieve both gold and silver prices grouped by provider.

---

### OpenAPI Spec

```yaml
/market/financial-data/metal-providers:
  get:
    summary: Get gold and silver prices by provider
    operationId: getMetalProviderData
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

- Superset of `/gold-providers` — includes both gold and silver entries from all providers.
