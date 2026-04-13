# News (Stock Events)

## `GET /market/news`

Retrieve stock corporate events (rights issues, dividends, AGM dates, etc.) filtered by symbol(s) and/or date range.

---

### OpenAPI Spec

```yaml
/market/news:
  get:
    summary: Get stock events / corporate actions
    operationId: getStockEvents
    tags:
      - News
    parameters:
      - name: stock
        in: query
        required: false
        description: Single stock symbol (e.g. VNM)
        schema:
          type: string
          example: VNM
      - name: stocks
        in: query
        required: false
        description: Comma-separated list of stock symbols (e.g. VNM,VIC,HPG)
        schema:
          type: string
          example: VNM,VIC,HPG
      - name: from_date
        in: query
        required: false
        description: Start date filter in DD/MM/YYYY format. Defaults to 1 year ago from today when omitted.
        schema:
          type: string
          example: 01/01/2024
      - name: to_date
        in: query
        required: false
        description: End date filter in DD/MM/YYYY format. Only applied when both from_date and to_date are provided.
        schema:
          type: string
          example: 31/12/2024
    responses:
      '200':
        description: Successful response
        content:
          application/json:
            schema:
              type: object
              properties:
                error_code:
                  type: string
                  example: "0"
                message:
                  type: string
                  example: success
                result:
                  type: array
                  items:
                    $ref: '#/components/schemas/StockEventResponse'
```

### Response Key

`result`

### Components

```yaml
components:
  schemas:
    StockEventResponse:
      type: object
      properties:
        id:
          type: integer
          nullable: true
          description: Event ID
        path:
          type: string
          nullable: true
          description: Internal path/slug of the event
        title:
          type: string
          nullable: true
          description: Event title
        stock:
          type: string
          description: Stock symbol
          example: VNM
        body:
          type: string
          nullable: true
          description: Event body/content
        createdDate:
          type: string
          description: Formatted creation date (DD/MM - HH:mm)
          example: "15/07 - 08:30"
        actionDate:
          type: string
          nullable: true
          description: Date the corporate action takes effect
        gdkhqDate:
          type: string
          nullable: true
          description: Ex-rights date (ngày GDKHQ)
        eventType:
          type: string
          nullable: true
          description: Event type code
        eventTypeName:
          type: string
          nullable: true
          description: Human-readable event type name
        createdAt:
          type: string
          format: date-time
          nullable: true
        updatedAt:
          type: string
          format: date-time
          nullable: true
        url:
          type: string
          nullable: true
          description: Full URL to the event detail page
```

### Notes

- Pass `stock` for a single symbol or `stocks` for multiple (comma-separated). Both are optional — omitting both returns all events within the date range.
- `from_date` and `to_date` must be in **DD/MM/YYYY** format.
- When **both** `from_date` and `to_date` are provided, results are filtered by that exact range.
- When either is omitted, the service defaults to **1 year ago from today** as the start with no upper bound.
- `gdkhqDate` is the ex-rights date relevant for dividend/rights-issue events.
- Returns an empty array when no events match the filters.
