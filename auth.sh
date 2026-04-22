#!/bin/bash

set -e

# Redirect file descriptor 3 to the terminal for interactive input
exec 3< /dev/tty

CREDS_DIR="$HOME/.finhay/credentials"
CREDS_FILE="$CREDS_DIR/.env"

echo "----------------------------------------------------"
echo "Finhay API Credentials Setup"
echo "----------------------------------------------------"

if [ ! -d "$CREDS_DIR" ]; then
    mkdir -p "$CREDS_DIR"
    echo "Created directory: $CREDS_DIR"
fi

if [ -f "$CREDS_FILE" ]; then
    printf "File %s already exists. Overwrite? (y/n): " "$CREDS_FILE" >&2
    read -r confirm <&3
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

printf "Enter FINHAY_API_KEY (e.g., ak_test_...): " >&2
read -r api_key <&3

printf "Enter FINHAY_API_SECRET: " >&2
api_secret=""
while IFS= read -r -s -n1 char <&3; do
    if [[ -z "$char" ]]; then
        printf "\n" >&2
        break
    fi
    if [[ "$char" == $'\177' || "$char" == $'\b' ]]; then
        if [ -n "$api_secret" ]; then
            api_secret="${api_secret%?}"
            printf "\b \b" >&2
        fi
    else
        api_secret+="$char"
        printf "*" >&2
    fi
done

default_url="https://open-api.fhsc.com.vn"
printf "Enter FINHAY_BASE_URL [default: %s]: " "$default_url" >&2
read -r base_url <&3

if [ -z "$base_url" ]; then
    base_url=$default_url
fi

cat << EOF > "$CREDS_FILE"
FINHAY_API_KEY=$api_key
FINHAY_API_SECRET=$api_secret
FINHAY_BASE_URL=$base_url
EOF

chmod 600 "$CREDS_FILE"

echo "----------------------------------------------------"
echo "Successfully generated $CREDS_FILE"
echo "----------------------------------------------------"
