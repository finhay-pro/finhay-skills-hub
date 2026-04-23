---
name: finhay-portfolio
description: "User identity, account balances, stock holdings, and order history. Use for net worth queries, purchasing power, or trading performance."
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
---

# Finhay Portfolio

Read-only trading data via the Finhay Securities Open API.

> **MANDATORY**: Ensure credentials are set (via environment variables `FINHAY_API_KEY`/`FINHAY_API_SECRET` or via `./finhay.sh auth`). Run `./finhay.sh doctor` to verify. If IDs are missing, run `./finhay.sh infer`.

## Usage Examples

```bash
# Get global net worth across all asset classes
./finhay.sh request GET "/users/v4/users/$USER_ID/assets/summary"

# Get cash and buying power for a specific trading account
./finhay.sh request GET "/trading/accounts/$SUB_ACCOUNT_NORMAL/summary"
```

## Endpoints

| Endpoint | Description | Params |
|----------|-------------|--------|
| `/users/v4/users/{userId}/assets/summary` | **Portfolio Overview**: Aggregated NAV and balances for all investment products. | `{userId}` → `$USER_ID` |
| `/trading/accounts/{subAccountId}/summary` | **Account Detail**: Granular cash, buying power, and debt for a specific sub-account. | `{subAccountId}` → ask user |
| `/trading/v2/sub-accounts/{subAccountId}/portfolio` | **Stock Holdings**: Real-time quantity, average price, and market value. | `{subAccountId}` → ask user |
| `/trading/sub-accounts/{subAccountId}/orders` | **Order History**: History of buy/sell transactions. | `{subAccountId}`, `fromDate`, `toDate` |
| `/trading/v1/accounts/{subAccountId}/order-book` | **Order Book**: List of current day's active orders. | `{subAccountId}` → ask user |
| `/trading/pnl-today/{userId}` | **Daily P&L**: Profit and loss performance for the current session. | `{userId}` → `$USER_ID` |
| `/trading/v5/account/{subAccountId}/user-rights` | **User Rights**: Trading permissions and account restrictions. | `{subAccountId}` → ask user |
| `/trading/market/session` | **Market Session**: Current status of the stock exchange (Open/Closed). | `exchange` (e.g., HOSE) |

## Sub-account Selection

- **NORMAL** → `$SUB_ACCOUNT_NORMAL`
- **MARGIN** → `$SUB_ACCOUNT_MARGIN`

## Constraints

- **Read-only**: Execute `GET` requests only.
- **Privacy**: Mask API keys and sensitive credentials in all output.
- **Sub-accounts**: Always confirm the specific account (Normal/Margin) with the user before querying detail endpoints.
