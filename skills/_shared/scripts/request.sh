#!/usr/bin/env bash
set -euo pipefail

[ $# -ge 2 ] || { echo "Usage: request.sh METHOD ENDPOINT [QUERY]" >&2; exit 1; }
METHOD="$1"; ENDPOINT="$2"; QUERY="${3:-}"

CREDS="$HOME/.finhay/credentials/.env"
[ -f "$CREDS" ] || { echo "ERROR: $CREDS not found" >&2; exit 1; }
set -a; source "$CREDS"; set +a

[ -n "${FINHAY_API_KEY:-}"    ] || { echo "ERROR: FINHAY_API_KEY required." >&2; exit 1; }
[ -n "${FINHAY_API_SECRET:-}" ] || { echo "ERROR: FINHAY_API_SECRET required." >&2; exit 1; }

TS=$(( $(date -u +%s) * 1000 ))
NONCE=$(openssl rand -hex 16)
SIG=$(printf '%s\n%s\n%s\n' "$TS" "$METHOD" "$ENDPOINT" \
  | openssl dgst -sha256 -hmac "$FINHAY_API_SECRET" | grep -oE '[a-f0-9]{64}')

TMP=$(mktemp); trap 'rm -f "$TMP"' EXIT
CODE=$(curl -s --max-time 30 -o "$TMP" -w "%{http_code}" -X "$METHOD" \
  -H "X-FH-APIKEY: $FINHAY_API_KEY" -H "X-FH-TIMESTAMP: $TS" \
  -H "X-FH-NONCE: $NONCE" -H "X-FH-SIGNATURE: $SIG" \
  "${FINHAY_BASE_URL:-https://open-api.fhsc.com.vn}${ENDPOINT}${QUERY:+?${QUERY}}")

[ "${CODE:-0}" -lt 400 ] || { echo "ERROR: HTTP $CODE" >&2; cat "$TMP" >&2; exit 1; }

EC=$(grep -oE '"error_code"[[:space:]]*:[[:space:]]*(\"[^\"]*\"|[0-9]+)' "$TMP" \
  | grep -oE '("[^"]*"|[0-9]+)$' | tr -d '"' | head -1)
[ -z "$EC" ] || [ "$EC" = "0" ] || { echo "ERROR: error_code=$EC" >&2; cat "$TMP" >&2; exit 1; }

cat "$TMP"
