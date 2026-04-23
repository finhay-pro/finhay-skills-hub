#!/bin/bash

set -e

REPO_URL="https://github.com/finhay-pro/finhay-skills-hub.git"
WORKDIR="_tmp_finhay_skills_hub"
CURDIR="$(pwd)"

rm -rf "$CURDIR/finhay-market" "$CURDIR/finhay-portfolio" "$CURDIR/finhay-market.zip" "$CURDIR/finhay-portfolio.zip" "$CURDIR/$WORKDIR"

git clone "$REPO_URL" "$CURDIR/$WORKDIR"

cd "$CURDIR/$WORKDIR"
chmod +x finhay.sh

cd "$CURDIR/$WORKDIR/skills"
zip -r "$CURDIR/finhay-market.zip" finhay-market
zip -r "$CURDIR/finhay-portfolio.zip" finhay-portfolio

cd "$CURDIR"
rm -rf "$CURDIR/$WORKDIR"

echo "Done. Created $CURDIR/finhay-market.zip and $CURDIR/finhay-portfolio.zip."
