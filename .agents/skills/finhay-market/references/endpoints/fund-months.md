# Fund Months

## `GET /market/funds/{fund}/months`

Retrieve the list of available portfolio months for a specific fund.

---

### OpenAPI Spec

```yaml
/market/funds/{fund}/months:
  get:
    summary: Get available fund months
    operationId: getFundMonths
    tags:
      - Funds
    parameters:
      - name: fund
        in: path
        required: true
        description: Fund code
        schema:
          type: string
          example: DCDS
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
                  description: List of available months
                  items:
                    type: string
                  example:
                    - "2024-01"
                    - "2024-02"
                    - "2024-03"
```

### Response Key

`data`

### Notes

- Returns a simple array of month strings.
- Use these values as the `month` query param in `/market/funds/{fund}/portfolio`.
