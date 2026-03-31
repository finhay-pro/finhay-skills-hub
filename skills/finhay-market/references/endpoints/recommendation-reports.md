# Recommendation Reports

## `GET /market/recommendation-reports/{symbol}`

Retrieve recommendation reports for a specific stock symbol (sourced from Vietstock).

---

### OpenAPI Spec

```yaml
/market/recommendation-reports/{symbol}:
  get:
    summary: Get recommendation reports by symbol
    operationId: getRecommendationReportsBySymbol
    tags:
      - Reports
    parameters:
      - name: symbol
        in: path
        required: true
        description: Stock symbol
        schema:
          type: string
          example: VNM
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
                  oneOf:
                    - type: array
                      items: {}
                      description: Empty array when no reports found
                      example: []
                    - $ref: '#/components/schemas/RecommendationReportResponse'
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    RecommendationReportResponse:
      type: object
      properties:
        recommendation:
          type: string
          nullable: true
          description: Latest recommendation description (from the first/most recent report)
        recommendationReports:
          type: array
          items:
            $ref: '#/components/schemas/IndexRecommendationReport'

    IndexRecommendationReport:
      type: object
      properties:
        stock:
          type: string
          description: Stock symbol
          example: VNM
        title:
          type: string
          nullable: true
          description: Report title
        source:
          type: string
          nullable: true
          description: Report source, defaults to `VietStock`
          example: VietStock
        recommendation_price:
          type: number
          nullable: true
          description: Recommended entry price (currently always `null`)
        target_price:
          type: number
          nullable: true
          description: Target price
          example: 85000
        publish_date:
          type: string
          format: date-time
          nullable: true
          description: Report publish date
        description:
          type: string
          nullable: true
          description: Report description/summary
        download_url:
          type: string
          nullable: true
          description: URL to download the full report PDF
        created_at:
          type: string
          format: date-time
          nullable: true
        updated_at:
          type: string
          format: date-time
          nullable: true
```

### Notes

- Returns `[]` (empty array) if no reports are found for the symbol.
- Returns a `RecommendationReportResponse` object (not an array) when reports exist.
- `recommendation` is extracted from the first report's `description` field.
- `recommendation_price` is currently always `null` in the implementation.
- Data is synced from Vietstock (`vietstock_recommendation_report` table).
