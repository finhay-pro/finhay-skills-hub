# finhay-skills-hub

Agent skills for the [Finhay Securities](https://fhsc.com.vn/) Open API. Works with Claude Code, Cursor, and other AI coding assistants.

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

## Setup

### Method 1: Environment Variables (Preferred for Stateless/Sandboxes)

Set the following environment variables in your terminal or CI environment:

```bash
export FINHAY_API_KEY="your_api_key"
export FINHAY_API_SECRET="your_api_secret"
```

### Method 2: Credentials File (Local Machine)

```bash
./finhay.sh auth
./finhay.sh infer
```

```powershell
.\finhay.ps1 auth
.\finhay.ps1 infer
```

This writes the necessary credentials and IDs to `~/.finhay/credentials/.env`.

| Command | Description |
|---------|-------------|
| `auth` | Configure API credentials |
| `doctor` | Verify system dependencies and setup |
| `infer` | Resolve user identity and trading sub-accounts |
| `request` | Execute signed API requests |
| `sync` | Update local skill definitions |

## Prerequisites

- `bash`, `curl`, `openssl`, `jq`, `xxd` (macOS/Linux)
- PowerShell 5.1+ (Windows)
- Authentication: Either Environment Variables (set `FINHAY_API_KEY`, `FINHAY_API_SECRET`) or local file `~/.finhay/credentials/.env`.

## License

MIT
