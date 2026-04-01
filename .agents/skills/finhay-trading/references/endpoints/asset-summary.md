# Asset Summary

## `GET /trading/sub-accounts/{subAccountId}/asset-summary`

Retrieve detailed asset summary for a sub-account, including balance breakdown and bank info.

---

### OpenAPI Spec

```yaml
/trading/sub-accounts/{subAccountId}/asset-summary:
  get:
    summary: Get asset summary
    operationId: getAssetSummary
    tags:
      - Account
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
                data:
                  $ref: '#/components/schemas/GetAssetResponse'
```

### Response Key

`data`

### Config Required

- `{subAccountId}` — inferred via `infer-sub-account.sh`

### Components

```yaml
components:
  schemas:
    GetAssetResponse:
      type: object
      properties:
        asset:
          $ref: '#/components/schemas/AssetResponse'
        is_snapshot:
          type: boolean
          description: Whether the data is from a cached snapshot

    AssetResponse:
      type: object
      properties:
        sub_account_id:
          type: string
        balance:
          type: integer
          format: int64
          description: Available balance
        ci_balance:
          type: integer
          format: int64
        td_balance:
          type: integer
          format: int64
        interest_balance:
          type: integer
          format: int64
        ca_receiving:
          type: integer
          format: int64
        receiving_t1:
          type: integer
          format: int64
        receiving_t2:
          type: integer
          format: int64
        receiving_t3:
          type: integer
          format: int64
        securities_amount:
          type: integer
          format: int64
        total_debt_amount:
          type: integer
          format: int64
        secure_amount:
          type: integer
          format: int64
        margin_amount:
          type: integer
          format: int64
        t0_debt_amount:
          type: integer
          format: int64
        advanced_amount:
          type: integer
          format: int64
        cidepo_fee_acr:
          type: integer
          format: int64
        net_asset_value:
          type: integer
          format: int64
        mrcr_limit:
          type: integer
          format: int64
        debt_amount:
          type: integer
          format: int64
        advance_max_amount_fee:
          type: integer
          format: int64
        receiving_amount:
          type: integer
          format: int64
        margin_rate:
          type: integer
          format: int64
        sms_fee_amount:
          type: integer
          format: int64
        hold_balance:
          type: integer
          format: int64
        mri_rate:
          type: integer
          format: int64
        mrm_rate:
          type: integer
          format: int64
        cidepo_fee:
          type: integer
          format: int64
        tdint_amount:
          type: integer
          format: int64
        add_vnd:
          type: integer
          format: int64
        add_vnd_1:
          type: integer
          format: int64
        core_bank:
          type: string
        bankacct_no:
          type: string
        bank_name:
          type: string
        emk_amount:
          type: integer
          format: int64
        baldefovd:
          type: string
        mrcr_limit_max:
          type: integer
          format: int64
```

### Notes

- Field naming uses `_amount` suffix (e.g. `securities_amount`) vs account-summary which uses `_amt` (e.g. `securities_amt`).
- `is_snapshot` indicates whether the response came from cache. When `cache-control=CACHE`, cached data may be returned.
- App version `5.32.8` forces `CACHE` mode regardless of the query parameter.
