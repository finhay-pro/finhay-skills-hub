# Funds

## `GET /market/funds`

Retrieve all available funds.

---

### OpenAPI Spec

```yaml
/market/funds:
  get:
    summary: Get all funds
    operationId: getFunds
    tags:
      - Funds
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
                    $ref: '#/components/schemas/Fund'
```

### Response Key

`data`

### Components

```yaml
components:
  schemas:
    Fund:
      type: object
      properties:
        code:
          type: string
          description: Fund code identifier
          example: DCDS
        name:
          type: string
          description: Fund name
          example: Quỹ Đầu tư Cổ phiếu Dragon Capital Việt Nam
        image_url:
          type: string
          description: Fund logo/image URL
          example: https://example.com/fund-logo.png
        desc:
          type: string
          description: Fund description
        info_url:
          type: string
          description: URL to fund information page
        performances:
          type: array
          description: Fund performance data
          items:
            type: object
```
