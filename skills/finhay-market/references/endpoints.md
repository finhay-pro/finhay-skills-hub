# Market Endpoints

Signing: use `./finhay.sh request` (or `.\finhay.ps1 request`). Query params are not signed. No `USER_ID` needed.

## Errors

`400` = invalid request, `401` = auth failure, `429` = rate limited.

Common causes: missing API key, combining `symbol`/`symbols`/`exchange`, path mismatch in signature.

## Response Keys

- `result` — stock-realtime
- `data` — all other endpoints

---

## Stock

| # | Path | Params | Res key | Note | Detail |
|---|------|--------|---------|------|--------|
| 1 | `/market/stock-realtime` | 1-of: `symbol`, `symbols`, `exchange` | `result` | object for `symbol`, array for `symbols`/`exchange` | [detail](./endpoints/stock-realtime.md) |

## News

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 2 | `/market/news` | `stock`, `stocks`, `from_date`, `to_date` (all optional) | `result` | [detail](./endpoints/news.md) |

## Financial Data — Precious Metals

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 3 | `/market/financial-data` | — | `data` | [detail](./endpoints/financial-data.md) |
| 4 | `/market/financial-data/gold` | — | `data` | [detail](./endpoints/gold.md) |
| 5 | `/market/financial-data/silver` | — | `data` | [detail](./endpoints/silver.md) |
| 6 | `/market/financial-data/gold-chart` | `days` (default 30) | `data` | [detail](./endpoints/gold-chart.md) |
| 7 | `/market/financial-data/silver-chart` | `days` (default 30) | `data` | [detail](./endpoints/silver-chart.md) |
| 8 | `/market/financial-data/gold-providers` | — | `data` | [detail](./endpoints/gold-providers.md) |
| 9 | `/market/financial-data/metal-providers` | — | `data` | [detail](./endpoints/metal-providers.md) |

## Financial Data — Other

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 10 | `/market/financial-data/bank-interest-rates` | — | `data` | [detail](./endpoints/bank-interest-rates.md) |
| 11 | `/market/financial-data/cryptos/top-trending` | — | `data` | [detail](./endpoints/cryptos-top-trending.md) |
| 12 | `/market/financial-data/macro` | `type`*, `country`*, `period` | `data` | [detail](./endpoints/macro.md) |

## Reports

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 13 | `/market/recommendation-reports/:symbol` | `symbol`* (path) | `data` | [detail](./endpoints/recommendation-reports.md) |

## Price History

| # | Path | Params | Res key | Note | Detail |
|---|------|--------|---------|------|--------|
| 14 | `/market/price-histories-chart` | `symbol`*, `resolution`* (`1D`, `5`, `15`, `30`, `1H`, `4H`, default `1D`), `from`*, `to`* (seconds) | `data` | `from`/`to` in **seconds** not ms | [detail](./endpoints/price-histories-chart.md) |

## Company Financial

| # | Path | Params | Res key | Detail |
|---|------|--------|---------|--------|
| 15 | `/market/company-financial/overview` | `symbol`* | `data` | [detail](./endpoints/company-financial-overview.md) |
| 16 | `/market/company-financial/analysis` | `symbol`*, `period` | `data` | [detail](./endpoints/company-financial-analysis.md) |
| 17 | `/market/v2/financial-statement/statement` | `symbol`*, `type`*, `period`, `limit` | `data` | [detail](./endpoints/financial-statement.md) |

---

## Choosing the Right Company Financial Endpoint

| Need | Endpoint |
|------|----------|
| Current ratios (PE, PB, ROE, EPS…) | `/company-financial/overview` |
| Trend of ratios over years/quarters | `/company-financial/analysis` |
| Income statement / balance sheet / cash flow | `/market/v2/financial-statement/statement` |

`type` values for statement endpoints: `income-statement`, `balance-sheet`, `cash-flow`
`period` values: `annual`, `quarterly`

---

## Choosing the Right Financial Data Endpoint

| Need | Endpoint |
|------|----------|
| Everything (gold + silver + crypto + bank rates) | `/market/financial-data` |
| Only gold (SJC + global) | `/market/financial-data/gold` |
| Gold by provider (PNJ, DOJI, BTMC...) | `/market/financial-data/gold-providers` |
| Gold chart (N days) | `/market/financial-data/gold-chart?days=N` |
| Silver equivalents | replace `gold` → `silver` |
| Macro (CPI, PMI, interest rates...) | `/market/financial-data/macro` |
| Bank deposit rates | `/market/financial-data/bank-interest-rates` |
| Top crypto | `/market/financial-data/cryptos/top-trending` |
