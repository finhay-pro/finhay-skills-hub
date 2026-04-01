# finhay-skills-hub

Agent skills for the [Finhay Securities](https://fhsc.com.vn/) Open API. Works with Claude Code, Cursor, and other AI coding assistants.

## Skills

| Skill | Description |
|-------|-------------|
| `finhay-market` | Stock prices, funds, gold, crypto, macro indicators, charts |
| `finhay-trading` | Owner identity, account balance, portfolio, orders, PnL, market session |

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
npm install dotenv
mkdir -p ~/.finhay/credentials
cat > ~/.finhay/credentials/.env << 'EOF'
FINHAY_API_KEY=ak_test_YOUR_API_KEY_HERE
FINHAY_API_SECRET=YOUR_64_CHAR_HEX_SECRET_HERE
FINHAY_BASE_URL=https://open-api.fhsc.com.vn
EOF
chmod 600 ~/.finhay/credentials/.env
```

| Variable | Required | Description |
|----------|----------|-------------|
| `FINHAY_API_KEY` | Yes | `ak_test_*` or `ak_live_*` |
| `FINHAY_API_SECRET` | Yes | 64-character hex secret |
| `FINHAY_BASE_URL` | No | Defaults to `https://open-api.fhsc.com.vn` |

## Prerequisites

- `node` >= 18
- `dotenv` (`npm install -g dotenv`)
- `~/.finhay/credentials/.env` with `FINHAY_API_KEY` and `FINHAY_API_SECRET`

## License

MIT
