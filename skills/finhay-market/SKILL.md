---
name: finhay-market
description: "Stock prices, commodities, macro indicators, charts, and company financials. Use for market analysis, price lookups, and corporate performance data."
license: MIT
metadata:
  author: Finhay Securities
  version: "1.0.0"
---

# Finhay Market

Read-only market data via the Finhay Securities Open API.

> **MANDATORY**: Ensure credentials are set (via environment variables `FINHAY_API_KEY`/`FINHAY_API_SECRET` or via `./finhay.sh auth`). Run `./finhay.sh doctor` to verify.

## Usage Examples

```bash
# Get real-time stock quote
./finhay.sh request GET /market/stock-realtime "symbol=VNM"

# Get gold spot price
./finhay.sh request GET /market/financial-data/gold

# Get historical OHLCV chart data
./finhay.sh request GET /market/price-histories-chart "symbol=VNM&resolution=1D&from=1609459200&to=1704067200"
```

## Endpoints

| Endpoint | Description | Params |
|----------|-------------|--------|
| `/market/stock-realtime` | **Stock Quotes**: Real-time pricing for symbols or exchanges. | `symbol`, `symbols`, or `exchange` |
| `/market/news` | **Market News**: Corporate events, dividends, and AGM dates. | `stock`, `from_date`, `to_date` |
| `/market/financial-data/gold` | **Gold Prices**: Real-time SJC and global gold spot prices. | — |
| `/market/financial-data/silver` | **Silver Prices**: Real-time silver spot prices. | — |
| `/market/financial-data/gold-chart` | **Gold Charts**: Historical gold price data for N days. | `days` |
| `/market/financial-data/silver-chart` | **Silver Charts**: Historical silver price data for N days. | `days` |
| `/market/financial-data/gold-providers` | **Gold by Provider**: Gold prices from PNJ, DOJI, SJC, etc. | — |
| `/market/financial-data/bank-interest-rates` | **Interest Rates**: Current bank deposit rates. | — |
| `/market/financial-data/cryptos/top-trending` | **Crypto Trends**: List of trending cryptocurrencies. | — |
| `/market/financial-data/macro` | **Macro Indicators**: CPI, PMI, and national interest rates. | `type`, `country`, `period` |
| `/market/recommendation-reports/:symbol` | **Analyst Reports**: Professional stock recommendation reports. | `:symbol` (path) |
| `/market/price-histories-chart` | **Historical Data**: OHLCV data for technical analysis and charts. | `symbol`, `resolution`, `from`, `to` |
| `/market/company-financial/overview` | **Corporate Ratios**: Key metrics (PE, PB, ROE, EPS). | `symbol` |
| `/market/company-financial/analysis` | **Financial Analysis**: Historical ratio trends by period. | `symbol`, `period` |
| `/market/v2/financial-statement/statement` | **Financial Reports**: Income statements and balance sheets. | `symbol`, `type`, `period` |

## Constraints

- **Read-only**: Execute `GET` requests only.
- **Privacy**: Mask sensitive credentials in all output.
- **Parameters**: Pass exactly one identifier for stock quotes (symbol, symbols, or exchange).
- **Timeframes**: Price history timestamps must be in **seconds**. Default to the last 5 years if range is not provided.
