# finhay-skills-hub

Agent skills for the [Finhay Securities](https://fhsc.com.vn/) Open API. Works with Claude Code, Cursor, and other AI coding assistants.

This repository is the skills project.

For CLI usage, use the separate project/package: `finhay-cli`.

## Skills

| Skill | Description |
|-------|-------------|
| `finhay-market` | Stock prices, funds, gold, crypto, macro indicators, charts |
| `finhay-portfolio` | Owner identity, account balance, portfolio, orders, PnL, market session |

## Install

### Claude Code plugin

```bash
claude plugin marketplace add finhay-pro/finhay-skills-hub
```

### npx (skills.sh)

```bash
npx skills add finhay-pro/finhay-skills-hub --skill finhay-market
npx skills add finhay-pro/finhay-skills-hub --skill finhay-portfolio
```

### CLI (Separate Project: `finhay-cli`)

```bash
npm install -g finhay-cli
finhay --help
finhay request --path /market/stock-realtime --query symbol=VNM
finhay request --path /market/price-histories-chart --query symbol=VNM --query resolution=1D --query from=1704067200 --query to=1711929600
finhay skills sync
```

Or run without global install:

```bash
npx -y finhay-cli --help
npx -y finhay-cli request --path /market/stock-realtime --query symbol=VNM
```

## Setup

```bash
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

- `npx skills` or Claude Code plugin for skill installation
- `finhay-cli` for API requests (`npm install -g finhay-cli` or `npx -y finhay-cli ...`)

## License

MIT
