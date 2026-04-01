# finhay-skills-hub

Agent skills for the [Finhay Securities](https://fhsc.com.vn/) Open API. Works with Claude Code, Cursor, and other AI coding assistants.

## Skills

| Skill | Description |
|-------|-------------|
| `finhay-market` | Stock prices, funds, gold, crypto, macro indicators, charts |
| `finhay-trading` | User profile, account balance, portfolio, orders, PnL, market session |
| `finhay-order-execution` | **DESTRUCTIVE** — Place, modify, cancel stock orders (requires explicit confirmation) |

## Install

### Claude Code plugin

```bash
claude plugin marketplace add finhay-pro/finhay-skills-hub
```

### npx (skills.sh)

```bash
npx skills add finhay-pro/finhay-skills-hub --skill finhay-market
npx skills add finhay-pro/finhay-skills-hub --skill finhay-trading
```

## Setup

```bash
mkdir -p ~/.finhay/credentials
cp credentials.example ~/.finhay/credentials/.env
# Edit with your credentials
```

| Variable | Required | Description |
|----------|----------|-------------|
| `FINHAY_API_KEY` | Yes | `ak_test_*` or `ak_live_*` |
| `FINHAY_API_SECRET` | Yes | 64-character hex secret |
| `FINHAY_BASE_URL` | No | Defaults to `https://open-api.fhsc.com.vn` |
| `USER_ID` | Trading | Profile and PnL endpoints |

## Prerequisites

- `node` >= 18

## License

MIT
