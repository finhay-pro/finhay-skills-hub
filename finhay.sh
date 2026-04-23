#!/bin/bash

set -e

CREDS_DIR="$HOME/.finhay/credentials"
CREDS_FILE="$CREDS_DIR/.env"
REF_ENV="$HOME/.finhay/ref/.env"
REPO="finhay-pro/finhay-skills-hub"
BRANCH="main"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
API="https://api.github.com/repos/${REPO}"

exec 3< /dev/tty

_REQ() {
    local METHOD="$1"
    local ENDPOINT="$2"
    local QUERY="${3:-}"
    local BODY="${4:-}"
    
    local AK="${FINHAY_API_KEY:-$(grep "^FINHAY_API_KEY=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)}"
    local AS="${FINHAY_API_SECRET:-$(grep "^FINHAY_API_SECRET=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)}"
    local BU="${FINHAY_BASE_URL:-$(grep "^FINHAY_BASE_URL=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)}"
    local UI="${USER_ID:-$(grep "^USER_ID=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)}"

    [ -z "$AK" ] && { echo "ERROR: FINHAY_API_KEY not found" >&2; return 1; }
    [ -z "$AS" ] && { echo "ERROR: FINHAY_API_SECRET not found" >&2; return 1; }
    [ -z "$BU" ] && BU="https://open-api.fhsc.com.vn"

    local TS=$(( $(date -u +%s) * 1000 ))
    local NONCE=$(openssl rand -hex 16)
    
    local PAYLOAD="${TS}"$'\n'"${METHOD}"$'\n'"${ENDPOINT}"$'\n'
    [ -n "$BODY" ] && PAYLOAD+="${BODY}"$'\n'

    local SIG=$(printf '%s' "$PAYLOAD" | openssl dgst -sha256 -hmac "$AS" -binary | xxd -p -c 256)
    local URL="${BU}${ENDPOINT}"
    [ -n "$QUERY" ] && URL="${URL}?${QUERY}"

    local TMP=$(mktemp)
    local CODE=$(curl -sS -X "$METHOD" "$URL" \
        -H "X-FH-APIKEY: $AK" \
        -H "X-FH-USER-ID: $UI" \
        -H "X-FH-TIMESTAMP: $TS" \
        -H "X-FH-NONCE: $NONCE" \
        -H "X-FH-SIGNATURE: $SIG" \
        -H "Content-Type: application/json" \
        -d "$BODY" -o "$TMP" -w "%{http_code}")

    if [ "$CODE" -ge 400 ]; then
        echo "ERROR: HTTP $CODE" >&2
        cat "$TMP" >&2
        rm -f "$TMP"
        return 1
    fi
    cat "$TMP"
    rm -f "$TMP"
}

CMD_AUTH() {
    echo "Finhay API Setup"
    [ ! -d "$CREDS_DIR" ] && mkdir -p "$CREDS_DIR"
    printf "Enter API Key: " >&2
    read -r ak <&3
    printf "Enter Secret: " >&2
    as=""
    while IFS= read -r -s -n1 c <&3; do
        if [[ -z "$c" ]]; then printf "\n" >&2; break; fi
        if [[ "$c" == $'\177' || "$c" == $'\b' ]]; then
            if [ -n "$as" ]; then as="${as%?}"; printf "\b \b" >&2; fi
        else as+="$c"; printf "*" >&2; fi
    done
    cat << EOF > "$CREDS_FILE"
FINHAY_API_KEY=$ak
FINHAY_API_SECRET=$as
FINHAY_BASE_URL=https://open-api.fhsc.com.vn
EOF
    chmod 600 "$CREDS_FILE"
    echo "Saved to $CREDS_FILE"
}

CMD_DOCTOR() {
    local AK="${FINHAY_API_KEY:-$(grep "^FINHAY_API_KEY=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)}"
    local AS="${FINHAY_API_SECRET:-$(grep "^FINHAY_API_SECRET=" "$CREDS_FILE" 2>/dev/null | cut -d'=' -f2-)}"
    
    if [ -n "$AK" ] && [ -n "$AS" ]; then
        echo "✅ Credentials: OK"
        echo "🌐 Base URL: ${BU:-https://open-api.fhsc.com.vn}"
    else
        echo "❌ Credentials: MISSING (Set environment variables or run auth)"
    fi
    for c in curl jq openssl xxd; do
        command -v $c >/dev/null 2>&1 && echo "✅ $c: OK" || echo "❌ $c: MISSING"
    done
}

CMD_INFER() {
    local DATA=$(_REQ GET /users/v1/users/me)
    USER_ID=$(echo "$DATA" | jq -r '.data.user_id // empty')
    
    if [ -z "$USER_ID" ]; then
        echo "ERROR: Could not resolve USER_ID. Check your credentials." >&2
        [ -n "$DATA" ] && echo "$DATA" >&2
        return 1
    fi

    SBA=$(_REQ GET "/users/v1/users/${USER_ID}/sub-accounts")
    
    [ ! -d "$CREDS_DIR" ] && mkdir -p "$CREDS_DIR"
    TMP=$(mktemp)
    [ -f "$CREDS_FILE" ] && grep -vE '^(USER_ID|SUB_ACCOUNT_)' "$CREDS_FILE" > "$TMP" || true
    
    echo "USER_ID=$USER_ID" >> "$TMP"
    
    jq -r '(.result // .data // [])[]? | [.type, .id, .sub_account_ext] | @tsv' <<<"$SBA" |
    while IFS=$'\t' read -r TYPE ID EXT; do
        [ -z "$TYPE" ] && continue
        UPPER_TYPE=$(echo "$TYPE" | tr '[:lower:]' '[:upper:]')
        echo "SUB_ACCOUNT_${UPPER_TYPE}=${ID}" >> "$TMP"
        echo "SUB_ACCOUNT_EXT_${UPPER_TYPE}=${EXT}" >> "$TMP"
        echo "export SUB_ACCOUNT_${UPPER_TYPE}=\"$ID\""
        echo "export SUB_ACCOUNT_EXT_${UPPER_TYPE}=\"$EXT\""
    done
    mv "$TMP" "$CREDS_FILE"
    echo "✅ Account IDs resolved and saved to $CREDS_FILE"
}

CMD_SYNC() {
    SKILL="$1"; [ -z "$SKILL" ] && exit 1
    FILES=$(curl -sf "${API}/git/trees/${BRANCH}?recursive=1" | jq -r --arg p "skills/$SKILL/" '.tree[] | select(.path | startswith($p)) | select(.type == "blob") | .path')
    tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
    while IFS= read -r f; do
        out="${tmp}/${f#skills/}"
        mkdir -p "$(dirname "$out")"
        curl -sf "${RAW}/${f}" -o "$out"
    done <<< "$FILES"
    rm -rf "skills/$SKILL"; mkdir -p "skills/$SKILL"
    cp -a "$tmp/$SKILL/." "skills/$SKILL/"
    ln -sf ../../finhay.sh "skills/$SKILL/finhay.sh"
    ln -sf ../../finhay.ps1 "skills/$SKILL/finhay.ps1"
    echo "✅ $SKILL synced."
}

case "$1" in
    auth) CMD_AUTH ;;
    doctor) CMD_DOCTOR ;;
    infer) CMD_INFER ;;
    request) shift; _REQ "$@" ;;
    sync) CMD_SYNC "$2" ;;
    *) echo "Usage: ./finhay.sh {auth|doctor|infer|request|sync}"; exit 1 ;;
esac
