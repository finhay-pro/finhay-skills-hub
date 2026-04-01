# Order Execution Enums

Use these values exactly as documented.

## OrderSide

`BUY` | `SELL`

## Type (order placement)

`LIMIT` | `MARKET`

- `LIMIT` → use `limit_price` field (human price × 1000)
- `MARKET` → use `market_price` field (see MarketPrice enum)

## MarketPrice

`MP` | `ATO` | `ATC` | `MAK` | `MOK` | `MTL` | `PLO` | `FOK` | `FAK`

| Value | Name | Description |
|-------|------|-------------|
| `MP` | Market Price | Match at best available price |
| `ATO` | At The Open | Match at opening session |
| `ATC` | At The Close | Match at closing session |
| `MAK` | Make or Kill | Fill partially or cancel entirely |
| `MOK` | Moment or Kill | Fill completely or cancel entirely |
| `MTL` | Moment To Limit | Fill at market then convert remainder to limit |
| `PLO` | Post Limit Order | Limit order after ATC session (HNX only) |
| `FOK` | Fill or Kill | Fill completely or cancel entirely |
| `FAK` | Fill and Kill | Fill partially, cancel remainder |

### Order types by exchange

| Exchange | Supported |
|----------|-----------|
| HOSE | LO, MP, ATO, ATC |
| HNX | LO, MTL, MOK, MAK, PLO, ATC |
| UPCOM | LO only |

## StockType

`STOCK` | `BOND` | `FUND_CERTIFICATE` | `WARRANT` | `ETF`

Default: `STOCK` for most equity orders.

## Channel

`ONLINE` | `MOBILE_ANDROID` | `MOBILE_IOS` | `INTERNAL`

Default: `ONLINE` for OpenAPI orders.

## LotType

`EVEN` | `ODD`

- `EVEN` — round lot (100 shares minimum on HOSE/HNX)
- `ODD` — odd lot (1-99 shares). Only `LO` order type allowed.

## OrderStatus

`RECEIVED` | `SENT` | `MATCHED` | `MATCHED_ALL` | `CANCELLED` | `CANCELLING` | `REJECTED` | `COMPLETED` | `FAILED` | `WAITING_TO_SEND` | `WAITING_TO_ACTIVATE` | `SENDING` | `FIXING` | `FIXED` | `EXPIRED`

Key statuses after placement:
- `RECEIVED` — order accepted by system
- `SENT` — order sent to exchange
- `MATCHED` — partially matched
- `MATCHED_ALL` — fully matched
- `REJECTED` — rejected by exchange (check `rejected_reason`)
- `CANCELLED` — successfully cancelled
