#!/usr/bin/env bash

set -euo pipefail

HUB_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="${1:-$(pwd)}"
OUT_DIR="$PROJECT_DIR/.agent/skills"

SKILLS=(finhay-market finhay-trading finhay-order-execution)

mkdir -p "$OUT_DIR"

for skill in "${SKILLS[@]}"; do
  echo "Building $skill..."

  rm -rf "$OUT_DIR/$skill"
  cp -r "$HUB_DIR/skills/$skill" "$OUT_DIR/$skill"
  cp -r "$HUB_DIR/skills/_shared" "$OUT_DIR/$skill/_shared"
done

echo "Done -> $OUT_DIR"
