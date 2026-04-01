# CLAUDE.md

Claude Code plugin — agent skills for the Finhay Securities Open API.

## Architecture

- **skills/** — 3 skills (each has `SKILL.md` + endpoint references)
- **skills/_shared/** — Authentication, constraints, request script
- **.claude-plugin/** — Plugin metadata
- **credentials.example** — Template for `~/.finhay/credentials/.env`

## Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| finhay-market | Stock prices, funds, gold, crypto, macro indicators, charts | Prices, rates, market data |
| finhay-trading | User profile, balance, portfolio, orders, PnL, user rights, market session | Profile, trading account, holdings, order history |
| finhay-order-execution | **DESTRUCTIVE** — Place, modify, cancel stock orders | Only when user explicitly asks to trade |

## Prerequisites

- `node` >= 18
- `~/.finhay/credentials/.env` with `FINHAY_API_KEY` and `FINHAY_API_SECRET`
- `USER_ID` also needed for trading skill

## API Requests

All skills use `skills/_shared/scripts/request.sh` for credential loading, HMAC-SHA256 signing, and error checking.

```bash
skills/_shared/scripts/request.sh GET /market/stock-realtime "symbol=VNM"
```
