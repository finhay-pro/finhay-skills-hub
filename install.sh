#!/bin/bash
# Script to clone finhay-market and finhay-portfolio from GitHub and zip them

set -e

REPO_URL="https://github.com/finhay-pro/finhay-skills-hub.git"
WORKDIR="_tmp_finhay_skills_hub"
CURDIR="$(pwd)"

# Remove old folders/zips if exist
rm -rf "$CURDIR/finhay-market" "$CURDIR/finhay-portfolio" "$CURDIR/finhay-market.zip" "$CURDIR/finhay-portfolio.zip" "$CURDIR/$WORKDIR"

# Clone toàn bộ repo về
git clone "$REPO_URL" "$CURDIR/$WORKDIR" || { echo "Clone repo failed" >&2; exit 1; }

# Zip 2 thư mục skills cần thiết
cd "$CURDIR/$WORKDIR/skills" || { echo "Cannot cd to skills folder" >&2; exit 1; }
zip -r "$CURDIR/finhay-market.zip" finhay-market || { echo "Zip finhay-market failed" >&2; exit 1; }
zip -r "$CURDIR/finhay-portfolio.zip" finhay-portfolio || { echo "Zip finhay-portfolio failed" >&2; exit 1; }
cd "$CURDIR"

# Cleanup
rm -rf "$CURDIR/$WORKDIR"

echo "Done. Created $CURDIR/finhay-market.zip and $CURDIR/finhay-portfolio.zip."
