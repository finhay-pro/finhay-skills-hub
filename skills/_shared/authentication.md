# Finhay Authentication

All requests require HMAC-SHA256 signed headers. Use [request.sh](./scripts/request.sh) for all API calls — it handles signing automatically. This document covers the internals.

## Config

Source: `~/.finhay/credentials/.env`

```bash
FINHAY_API_KEY=ak_test_...
FINHAY_API_SECRET=64_char_hex_secret
FINHAY_BASE_URL=https://open-api.fhsc.com.vn
```

| Variable | Required | Description |
|----------|----------|-------------|
| `FINHAY_API_KEY` | Yes | `X-FH-APIKEY` header |
| `FINHAY_API_SECRET` | Yes | HMAC-SHA256 signing key |
| `FINHAY_BASE_URL` | No | Defaults to `https://open-api.fhsc.com.vn` |

## Headers

| Header | Value |
|--------|-------|
| `X-FH-APIKEY` | API key |
| `X-FH-TIMESTAMP` | `Date.now()` (ms) |
| `X-FH-NONCE` | 16 random bytes, hex |
| `X-FH-SIGNATURE` | HMAC-SHA256, hex |

## Signing

`HMAC-SHA256` with `FINHAY_API_SECRET` as key. Input:

```
{TIMESTAMP}\n{METHOD}\n{REQUEST_PATH}\n
```

Query params are **not** signed.

## Setup Endpoints

Used internally by setup scripts.

| Endpoint | Description | Response key |
|----------|-------------|--------------|
| `GET /users/oa/me` | Resolve owner identity and sub-accounts | `result.uid`, `result.sub_accounts` |

## Rate Limits

Per API key, 60-second sliding window:

| Tier | Limit |
|------|-------|
| FREE | 600 |
| BASIC | 1200 |
| PRO | 3000 |
| ENTERPRISE | 10000 |

Weight = 1 per request. On 429, wait until `X-RateLimit-Reset`.
