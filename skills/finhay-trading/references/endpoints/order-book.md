# Order Book (List)

## `GET /trading/v1/accounts/{subAccountId}/order-book`

Retrieve the intraday order book for a sub-account.

---

### OpenAPI Spec

```yaml
/trading/v1/accounts/{subAccountId}/order-book:
  get:
    summary: Get order book
    operationId: getOrderBook
    tags:
      - Orders
    parameters:
      - name: subAccountId
        in: path
        required: true
        description: Sub-account ID
        schema:
          type: string
          example: "0001234567"
      - name: cache-control
        in: query
        required: false
        description: Cache control policy
        schema:
          type: string
          enum: [CACHE, NOCACHE]
          default: NOCACHE
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
                  type: array
                  items:
                    $ref: '#/components/schemas/OrderBookEntry'
```

### Response Key

`result`

### Config Required

- `{subAccountId}` — inferred via `infer-sub-account.sh`

### Components

```yaml
components:
  schemas:
    OrderBookEntry:
      type: object
      properties:
        custodycd:
          type: string
        txdate:
          type: string
          description: Transaction date
        custid:
          type: string
        afacctno:
          type: string
          description: Account number
        orderid:
          type: string
          description: Order ID
        odorderid:
          type: string
        txtime:
          type: string
          description: Transaction time
        symbol:
          type: string
          example: VNM
        allowcancel:
          type: string
          description: Whether cancel is allowed
        allowamend:
          type: string
          description: Whether amendment is allowed
        side_code:
          type: string
          description: Side code (raw)
        side:
          type: string
          description: Side display name (BUY/SELL)
        price:
          type: integer
          format: int64
        pricetype:
          type: string
          description: Price type code
        via_code:
          type: string
          description: Order channel code
        via:
          type: string
          description: Order channel name
        qtty:
          type: integer
          format: int64
          description: Order quantity
        execqtty:
          type: integer
          format: int64
          description: Executed quantity
        execamt:
          type: integer
          format: int64
          description: Executed amount
        execprice:
          type: integer
          format: int64
          description: Executed price
        remainqtty:
          type: integer
          format: int64
          description: Remaining quantity
        remainamt:
          type: integer
          format: int64
          description: Remaining amount
        status_code:
          type: string
          description: Status code (raw)
        status:
          type: string
          description: Status display name
        tlname:
          type: string
        username:
          type: string
        hosesession:
          type: string
          description: HOSE session info
        cancelqtty:
          type: integer
          format: int64
        adjustqtty:
          type: integer
          format: int64
        isdisposal:
          type: string
        rootorderid:
          type: string
        timetype:
          type: string
        timetypevalue:
          type: string
        feedbackmsg:
          type: string
          description: Feedback message from exchange
        quoteqtty:
          type: integer
          format: int64
        limitprice:
          type: number
          format: double
        odtimestamp:
          type: string
        matchtype_code:
          type: string
        producttypename:
          type: string
        afacctno_ext:
          type: string
        side_:
          type: string
        via_:
          type: string
        status_:
          type: string
        matchtype_:
          type: string
        strategy_id:
          type: string
          nullable: true
```

### Notes

- Returns the full intraday order book including broker-signal orders and HayBond orders.
- Use `cache-control=CACHE` for faster responses from cache.
