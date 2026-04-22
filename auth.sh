#!/bin/bash

{

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
    read -p "File $CREDS_FILE already exists. Overwrite? (y/n): " confirm < /dev/tty
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

if [ -z "$FINHAY_API_KEY" ]; then
    echo -n "Enter FINHAY_API_KEY (e.g., ak_test_...): "
    read api_key < /dev/tty
else
    api_key=$FINHAY_API_KEY
    echo "Using FINHAY_API_KEY from environment."
fi

if [ -z "$FINHAY_API_SECRET" ]; then
    echo -n "Enter FINHAY_API_SECRET: "
    api_secret=""
    while IFS= read -r -s -n1 char < /dev/tty; do
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
else
    api_secret=$FINHAY_API_SECRET
    echo "Using FINHAY_API_SECRET from environment."
fi

default_url="https://open-api.fhsc.com.vn"
if [ -z "$FINHAY_BASE_URL" ]; then
    echo -n "Enter FINHAY_BASE_URL [default: $default_url]: "
    read base_url < /dev/tty
    if [ -z "$base_url" ]; then
        base_url=$default_url
    fi
else
    base_url=$FINHAY_BASE_URL
    echo "Using FINHAY_BASE_URL from environment: $base_url"
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

}
