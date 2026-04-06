#!/usr/bin/env bash
set -euo pipefail

CREDS="$HOME/.finhay/credentials/.env"
DIR="$(cd "$(dirname "$0")" && pwd)"

[ -f "$CREDS" ] || { echo "ERROR: $CREDS not found" >&2; exit 1; }
set -a; source "$CREDS"; set +a

if [ -n "${USER_ID:-}" ] && ([ -n "${SUB_ACCOUNT_NORMAL:-}" ] || [ -n "${SUB_ACCOUNT_MARGIN:-}" ]); then
  echo "✅ Credentials already set"; exit 0
fi

[ -n "${FINHAY_API_KEY:-}" ] && [ -n "${FINHAY_API_SECRET:-}" ] \
  || { echo "ERROR: FINHAY_API_KEY and FINHAY_API_SECRET required" >&2; exit 1; }

req() { bash "$DIR/request.sh" "$@"; }

# Extract a JSON field value (quoted string or number) by key
jv() { printf '%s' "$2" | grep -oE "\"$1\"[[:space:]]*:[[:space:]]*(\"[^\"]*\"|[0-9]+)" \
         | sed 's/.*:[[:space:]]*//;s/"//g' | head -1; }

ME=$(req GET /users/v1/users/me)
USER_ID=$(jv user_id "$ME")
[ -n "$USER_ID" ] || { echo "ERROR: user_id missing in response" >&2; exit 1; }

SBA=$(req GET "/users/v1/users/$USER_ID/sub-accounts")

TMP=$(mktemp); trap 'rm -f "$TMP"' EXIT
grep -vE '^(USER_ID|SUB_ACCOUNT_)' "$CREDS" > "$TMP" || true
printf 'USER_ID=%s\n' "$USER_ID" >> "$TMP"

while IFS= read -r obj; do
  T=$(jv type "$obj" | tr '[:lower:]' '[:upper:]')
  [ -n "$T" ] || continue
  printf 'SUB_ACCOUNT_%s=%s\nSUB_ACCOUNT_EXT_%s=%s\n' \
    "$T" "$(jv id "$obj")" "$T" "$(jv sub_account_ext "$obj")" >> "$TMP"
done < <(printf '%s' "$SBA" | tr -d '\n' \
  | sed 's/.*"result"[[:space:]]*:[[:space:]]*\[//; s/\].*//' \
  | grep -oE '\{[^}]*\}')

mv "$TMP" "$CREDS"
echo "✅ Credentials updated successfully"
