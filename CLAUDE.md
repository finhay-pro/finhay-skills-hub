# CLAUDE.md

Claude Code plugin — agent skills for the Finhay Securities Open API.

## Architecture

- **skills/** — 2 skills (each has `SKILL.md` + endpoint references)
- **.claude-plugin/** — Plugin metadata

## Skills

| Skill | Purpose | When to Use |
|-------|---------|-------------|
| finhay-market | Stock prices, funds, gold, crypto, macro indicators, charts | Prices, rates, market data |
| finhay-portfolio | User profile, balance, portfolio, orders, PnL, user rights, market session | Profile, trading account, holdings, order history |

## Prerequisites

- Skills plugin runtime (`npx skills` or Claude Code plugin)

## API Requests

Use the separate `finhay-cli` project/package for credential loading, HMAC-SHA256 signing, and error checking.

```bash
finhay request --path /market/stock-realtime --query symbol=VNM
```
