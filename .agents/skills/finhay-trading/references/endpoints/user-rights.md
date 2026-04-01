# User Rights

## `GET /trading/v5/account/{subAccountId}/user-rights`

Retrieve corporate action rights (dividends, stock rights, meetings, etc.) for a sub-account.

---

### OpenAPI Spec

```yaml
/trading/v5/account/{subAccountId}/user-rights:
  get:
    summary: Get user rights
    operationId: getUserRights
    tags:
      - User Rights
    parameters:
      - name: subAccountId
        in: path
        required: true
        description: Sub-account ID
        schema:
          type: string
          example: "0001234567"
      - name: fromDate
        in: query
        required: false
        description: Start date filter
        schema:
          type: string
          format: date
          example: "2024-01-01"
      - name: toDate
        in: query
        required: false
        description: End date filter
        schema:
          type: string
          format: date
          example: "2024-12-31"
      - name: catType
        in: query
        required: false
        description: >
          Category type filter (comma-separated for multiple).
          Use `ALL` for all types.
        schema:
          type: string
          default: ALL
      - name: isCom
        in: query
        required: false
        description: Is company event filter
        schema:
          type: string
          default: ALL
      - name: symbol
        in: query
        required: false
        description: Filter by stock symbol
        schema:
          type: string
          default: ALL
      - name: status
        in: query
        required: false
        description: >
          Filter by registration status (comma-separated for multiple).
          Use `ALL` for all statuses.
        schema:
          type: string
          default: ALL
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
                    $ref: '#/components/schemas/UserRight'
```

### Response Key

`result`

### Config Required

- `{subAccountId}` — inferred via `infer-sub-account.sh`

### Components

```yaml
components:
  schemas:
    UserRight:
      type: object
      properties:
        accountId:
          type: string
        depositoryNumber:
          type: string
        fullName:
          type: string
        ownNumberOfShare:
          type: integer
          format: int64
          description: Number of shares owned at record date
        ratio:
          type: string
          description: Right ratio (e.g. "1:5")
        status:
          type: string
          enum:
            - WAIT_FOR_REVIEW
            - WAIT_EXECUTED
            - WAITING_FOR_APPROVE
            - NAVIGATING
            - COMPLETED
            - ALLOCATION_COMPLETED
            - CANCELED
            - EMPTY_STOCK
            - APPROVED
            - REJECTED
            - READY_FOR_TRADE
            - READY_FOR_CLOSE
            - STOCK_ALLOTTED
            - MONEY_ALLOTTED
            - PARTIALLY_DONE
            - VERIFIED
            - DELETED
            - REGISTERED
          description: Corporate action status
        userRightRegisterStatus:
          type: string
          enum:
            - UNREGISTER
            - REGISTERED
            - EXPIRED
            - RECEIVED
            - PARTIAL_REGISTERED
            - PENDING
            - PARTIAL_RECEIVED
            - WAIT_REGISTER
            - REGISTERED_V2
            - WAIT_RECEIVE
            - WAIT_STOCK
            - PARTIAL_RECEIVED_V2
            - UNKNOWN
          description: User registration status
        caMastId:
          type: string
          description: Corporate action master ID
        amount:
          type: integer
          format: int64
        symbol:
          type: string
          example: VNM
        toSymbol:
          type: string
          nullable: true
          description: Target symbol (for stock conversion events)
        numberOfWaitingStock:
          type: integer
          format: int64
        waitingAmountForReturn:
          type: integer
          format: int64
        rightOffRate:
          type: string
          description: Right offering rate
        buyPrice:
          type: integer
          format: int64
          description: Subscription price (for stock rights)
        allowRegister:
          type: boolean
          description: Whether registration is allowed
        totalStocksCanBuy:
          type: integer
          format: int64
        totalPayAmount:
          type: integer
          format: int64
        startDate:
          type: string
          format: date
        finishDate:
          type: string
          format: date
        startDateTransfer:
          type: string
          format: date
        actionDate:
          type: string
          format: date
          description: Record date / Ex-date
        finishDateTransfer:
          type: string
          format: date
        reportDate:
          type: string
          format: date
          description: Used for sorting (descending)
        type:
          type: string
          enum:
            - OTC_BOND_INTEREST
            - SHAREHOLDER_MEETING
            - SOLICIT_SHAREHOLDER_OPINIONS
            - CASH_DIVIDEND
            - STOCK_DIVIDEND
            - STOCK_RIGHT
            - BOND_INTEREST
            - BOND_PRINCIPAL_AND_INTEREST
            - CONVERT_BONDS_TO_STOCKS
            - CONVERT_STOCKS_TO_OTHER_STOCKS
            - BONUS_SHARES
            - VOTING_RIGHTS
            - CONVERTIBLE_BOND
            - TRANSFER_PENDING_STOCKS
            - WARRANT_DIVIDENDS
          description: Type of corporate action
        stockName:
          type: string
        totalVolume:
          type: integer
          format: int64
        totalValue:
          type: integer
          format: int64
        referencePrice:
          type: integer
          format: int64
        closePrice:
          type: integer
          format: int64
        ceilingPrice:
          type: integer
          format: int64
        floorPrice:
          type: integer
          format: int64
        predictPrice:
          type: integer
          format: int64
        changePrice:
          type: integer
          format: int64
        hasRead:
          type: boolean
          description: Whether the user has read this right notification
```

### Notes

- Results are sorted by `reportDate` descending (most recent first).
- `catType` and `status` support comma-separated values for filtering multiple types/statuses.
- When `status` is not `ALL`, the result is filtered client-side after fetching.
