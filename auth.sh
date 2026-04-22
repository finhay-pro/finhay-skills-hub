#!/bin/bash

set -e

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
    read -p "File $CREDS_FILE already exists. Overwrite? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

echo -n "Enter FINHAY_API_KEY (e.g., ak_...): "
read api_key

echo -n "Enter FINHAY_API_SECRET: "
api_secret=""
while IFS= read -r -s -n1 char; do
    if [[ -z $char ]]; then
        printf "\n"
        break
    fi
    if [[ $char == $'\177' || $char == $'\b' ]]; then
        if [ -n "$api_secret" ]; then
            api_secret="${api_secret%?}"
            printf "\b \b"
        fi
    else
        api_secret+="$char"
        printf "*"
    fi
done

default_url="https://open-api.fhsc.com.vn"
echo -n "Enter FINHAY_BASE_URL [default: $default_url]: "
read base_url

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
