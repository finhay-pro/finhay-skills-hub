---
name: finhay-market
description: "Stock prices, funds, gold, silver, crypto, macro indicators, bank rates, and price charts. Use when user asks about stock prices, gold/silver prices, fund performance, interest rates, macro data, or price history charts."
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
  homepage: "https://fhsc.com.vn/"
---

# Finhay Market

Read-only market data via the Finhay Securities Open API. All requests are signed `GET`.

## Pre-flight

See [pre-flight checks](./_shared/preflight.md). Required: `FINHAY_API_KEY`, `FINHAY_API_SECRET`. (`USER_ID` not needed for market endpoints.)

## Making a Request

Use [request.sh](./_shared/scripts/request.sh) for every call.

```bash
./_shared/scripts/request.sh GET /market/stock-realtime "symbol=VNM"
./_shared/scripts/request.sh GET /market/stock-realtime "symbols=VNM,VIC,HPG"
./_shared/scripts/request.sh GET /market/stock-realtime "exchange=HOSE"
./_shared/scripts/request.sh GET /market/financial-data/gold
./_shared/scripts/request.sh GET /market/price-histories-chart "symbol=VNM&resolution=1D&from=1609459200&to=1704067200"
./_shared/scripts/request.sh GET /market/financial-data/macro "type=CPI&country=VN&period=YEARLY"
```

## Endpoints

| Category | Endpoint | Key params |
|----------|----------|------------|
| Stock | `/market/stock-realtime` | exactly one of: `symbol`, `symbols`, `exchange` |
| Funds | `/market/funds` | — |
| Fund detail | `/market/funds/:fund/portfolio` | `month` (optional) |
| Gold / Silver | `/market/financial-data/gold`, `silver` | — |
| Charts | `/market/financial-data/gold-chart`, `silver-chart` | `days` (default 30) |
| Providers | `/market/financial-data/gold-providers`, `metal-providers` | — |
| Bank rates | `/market/financial-data/bank-interest-rates` | — |
| Crypto | `/market/financial-data/cryptos/top-trending` | — |
| Macro | `/market/financial-data/macro` | `type`, `country`, `period` |
| Reports | `/market/recommendation-reports/:symbol` | — |
| Price history | `/market/price-histories-chart` | `symbol`, `resolution` (only `1D`), `from`, `to` (seconds) |

Details & response shapes: [references/endpoints.md](./references/endpoints.md).

## Constraints

See [shared constraints](./_shared/constraints.md), plus:

- **Stock realtime** — pass exactly one of `symbol`, `symbols`, or `exchange`. Never combine them.
- **Price history** — `from` and `to` are Unix timestamps in **seconds**, not milliseconds. If a value exceeds 9,999,999,999, stop and ask the user to convert. `resolution` must be `1D`. When not provided, default `to` to now and `from` to 5 years ago.
