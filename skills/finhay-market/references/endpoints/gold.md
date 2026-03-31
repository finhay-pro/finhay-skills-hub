# Gold Data

## `GET /market/financial-data/gold`

Retrieve SJC gold prices and global gold price.

---

### OpenAPI Spec

```yaml
/market/financial-data/gold:
  get:
    summary: Get gold price data
    operationId: getGoldData
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

```yaml
components:
  schemas:
    CommodityIndexData:
      type: object
      properties:
        index:
          type: string
          description: Index identifier
          example: SJC_GOLD
        name:
          type: string
          description: Display name
          example: Vàng SJC
        short_name:
          type: string
          description: Short display name
          example: SJC
        buy_value:
          type: number
          description: Buy price
          example: 92500000
        sell_value:
          type: number
          description: Sell price
          example: 94500000
        usd_value:
          type: number
          description: USD equivalent value
        vnd_value:
          type: number
          description: VND value
        date:
          type: string
          description: Price date
        provider:
          type: string
          description: Data provider name
          example: SJC
        provider_icon:
          type: string
          nullable: true
          description: Provider icon URL
        updated_at:
          type: string
          description: Last update timestamp
        change_percent:
          type: number
          description: Price change percentage
        buy_value_change_percent:
          type: number
          description: Buy value change percentage
        sell_value_change_percent:
          type: number
          description: Sell value change percentage
```

### Notes

- `DOJI_9999_GOLD_RING` index is renamed to `Vàng nhẫn DOJI` in the response.
- Same `CommodityIndexData` schema is shared with `/silver`, `/gold-providers`, and `/metal-providers`.
