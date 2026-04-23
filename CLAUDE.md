# CLAUDE.md

Claude Code plugin — agent skills for the Finhay Securities Open API.

## Architecture

- **skills/** — 2 skills (each has `SKILL.md` + endpoint references)
- **finhay.sh** — Unified CLI for macOS/Linux
- **finhay.ps1** — Unified CLI for Windows
- **.claude-plugin/** — Plugin metadata

## CLI Commands

| Command | Description |
|---------|-------------|
| `auth` | Configure API credentials |
| `doctor` | Verify system dependencies and setup |
| `infer` | Resolve user identity and trading sub-accounts |
| `request` | Execute signed API requests |
| `sync` | Update local skill definitions |

## Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| finhay-market | Stock prices, funds, gold, crypto, macro indicators, charts | Prices, rates, market data |
| finhay-portfolio | User identity, balances, holdings, and order history | Profile, trading account, performance |

## Prerequisites

- `bash`, `curl`, `openssl`, `jq`, `xxd` (macOS/Linux)
- PowerShell 5.1+ (Windows)
- `~/.finhay/credentials/.env` with `FINHAY_API_KEY` and `FINHAY_API_SECRET`

## API Requests

All skills use `finhay.sh` (or `finhay.ps1`) for credential loading, HMAC-SHA256 signing, and error checking.

```bash
./finhay.sh request GET /market/stock-realtime "symbol=VNM"
```
