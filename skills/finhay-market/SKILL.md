---
name: finhay-market
description: "Stock prices, gold, silver, crypto, macro indicators, bank rates, price charts, and company financials (income statement, balance sheet, cash flow, ratios). Use when user asks about stock prices, gold/silver prices, interest rates, macro data, price history charts, or company financial statements."
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
  homepage: "https://fhsc.com.vn/"
---

# Finhay Market

Read-only market data via the Finhay Securities Open API. All requests are signed `GET`.

> **MANDATORY**: Before any action, read and complete [pre-flight checks](./_shared/preflight.md). Required: `FINHAY_API_KEY`, `FINHAY_API_SECRET`. `USER_ID` not needed for market endpoints. Do not skip or defer.

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

| Endpoint | Use when | Path param | Query params |
|----------|----------|------------|--------------|
| `/market/stock-realtime` | Stock price, realtime quote | — | exactly one of: `symbol`, `symbols`, `exchange` |
| `/market/news` | Corporate events: dividends, rights issues, AGM dates | — | `stock`, `stocks`, `from_date`, `to_date` (all optional, dates in DD/MM/YYYY; default range: last 1 year) |
| `/market/financial-data/gold`, `silver` | Gold/silver spot price | — | — |
| `/market/financial-data/gold-chart`, `silver-chart` | Gold/silver price chart | — | `days` (default 30) |
| `/market/financial-data/gold-providers`, `metal-providers` | Price by provider (PNJ, DOJI…) | — | — |
| `/market/financial-data/bank-interest-rates` | Bank deposit rates | — | — |
| `/market/financial-data/cryptos/top-trending` | Top crypto | — | — |
| `/market/financial-data/macro` | CPI, PMI, interest rates… | — | `type`, `country`, `period` |
| `/market/recommendation-reports/:symbol` | Analyst reports | `:symbol` | — |
| `/market/price-histories-chart` | OHLCV price history | — | `symbol`, `resolution` (`1D`, `5`, `15`, `30`, `1H`, `4H`, default `1D`), `from`, `to` (seconds) |
| `/market/company-financial/overview` | Key ratios: PE, PB, ROE, EPS, dividend yield | — | `symbol` |
| `/market/company-financial/analysis` | Historical financial metrics by period | — | `symbol`, `period` (`annual`/`quarterly`) |
| `/market/v2/financial-statement/statement` | Income/balance sheet/cash flow, metric-value row format | — | `symbol`, `type`, `period`, `limit` |

### Parameter rules

- Each endpoint accepts **only** the parameters listed in its path and query columns above. Do not add extra parameters.
- All `:variables` in the URL are **path** variables — substitute them into the URL, never pass as query params.

Details & response shapes: [references/endpoints.md](./references/endpoints.md).

## Constraints

See [shared constraints](./_shared/constraints.md), plus:

- **Stock realtime** — pass exactly one of `symbol`, `symbols`, or `exchange`. Never combine them.
- **Price history** — `from` and `to` are Unix timestamps in **seconds**, not milliseconds. If a value exceeds 9,999,999,999, stop and ask the user to convert. `resolution` must be one of `1D`, `5`, `15`, `30`, `1H`, or `4H`, with a default of `1D` when not provided. When not provided, default `to` to now and `from` to 5 years ago.
