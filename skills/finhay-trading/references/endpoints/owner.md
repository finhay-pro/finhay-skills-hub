# Owner

## `GET /users/oa/me`

Owner identity and sub-accounts.

- **Config:** none
- **Response key:** `result`
- **Internal only** — service-to-service, no user auth headers.

---

### Response Schema

```yaml
OwnerResponse:
  type: object
  properties:
    # Identity
    uid: string

    # Sub-accounts
    sub_accounts:
      type: array
      items:
        id: integer
        name: string    # e.g. "Ng Van A"
        sub_account_ext: string   # e.g. "0001234567"
        product_type_name: string
        type: enum [NORMAL, MARGIN]
```
