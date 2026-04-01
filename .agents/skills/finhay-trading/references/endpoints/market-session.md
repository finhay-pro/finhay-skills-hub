# Market Session

## `GET /trading/market/session`

Retrieve current market session info and available order types for an exchange.

---

### OpenAPI Spec

```yaml
/trading/market/session:
  get:
    summary: Get market session info
    operationId: getMarketSession
    tags:
      - Market
    parameters:
      - name: exchange
        in: query
        required: true
        description: Exchange code
        schema:
          type: string
          enum: [HOSE, HNX, UPCOM, HCX]
          example: HOSE
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
                result:
                  $ref: '#/components/schemas/ExchangeSessionInfo'
```

### Response Key

`result`

### Config Required

None — this endpoint does not require `USER_ID`.

### Components

```yaml
components:
  schemas:
    ExchangeSessionInfo:
      type: object
      properties:
        exchange:
          type: string
          enum: [HOSE, HNX, UPCOM, HCX]
          description: Exchange code
          example: HOSE
        exchange_session:
          type: string
          enum:
            - OPEN
            - PROGRESS
            - BREAK
            - CLOSED
            - PRE_CLOSED
            - PUT_THROUGH
            - POST_SESSION
            - CA
          description: >
            Current session:
            `OPEN` = ATO (opening auction),
            `PROGRESS` = continuous matching,
            `BREAK` = lunch break,
            `CLOSED` = market closed,
            `PRE_CLOSED` = ATC (closing auction),
            `PUT_THROUGH` = put-through session,
            `POST_SESSION` = HNX post-session,
            `CA` = periodic auction
        available_order_types:
          type: array
          description: Order types available in the current session
          items:
            type: string
            enum: [LO, MP, ATO, ATC, MAK, MOK, MTL, PLO, FOK, FAK]
          example: [LO, MP, ATC]
```

### Notes

- `exchange` is the only required parameter. No authentication config needed.
- `available_order_types` changes based on the current session. For example, `ATO` is only available during `OPEN` session.
- `HCX` is the derivative exchange (HoChiMinh Commodity Exchange).
