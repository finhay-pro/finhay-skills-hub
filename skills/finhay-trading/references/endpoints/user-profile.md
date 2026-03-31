# User Profile

## `GET /internal/users/{userId}/profile`

User identity and sub-accounts.

- **Config:** `USER_ID` → `{userId}`
- **Response key:** `result`
- **Internal only** — service-to-service, no user auth headers.

---

### Response Schema

```yaml
UserProfileResponse:
  type: object
  properties:
    # Identity
    user_id: string
    full_name: string
    dob: string
    gender: enum [MALE, FEMALE]
    identity_number: string          # ID card / passport
    identity_type: string
    id_issue_date: string
    expired_date: string
    id_issue_address: string

    # Sub-accounts
    sub_accounts:
      type: array
      items:
        sub_account_id: integer
        sub_account_ext: string      # e.g. "0001234567"
        product_type_name: string
        account_type: enum [NORMAL, MARGIN]
        account_type_as_text: string  # Tiểu khoản thường / margin
        fee_rate: number
        loan_interest_rate_on_time: number
```
