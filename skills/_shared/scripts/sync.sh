#!/usr/bin/env bash
set -euo pipefail

SKILL="${1:-}"; [ -n "$SKILL" ] || { echo "Usage: sync.sh <skill>" >&2; exit 1; }

REPO="finhay-pro/finhay-skills-hub"; BRANCH="main"
RAW="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
API="https://api.github.com/repos/${REPO}"
TTL=$(( 12 * 3600 ))
REF_ENV="$HOME/.finhay/ref/.env"

ROOT="$(cd "$(dirname "$0")" && pwd)"
while [ "$(basename "$ROOT")" != "skills" ]; do
  P="$(dirname "$ROOT")"; [ "$P" != "$ROOT" ] || { echo "ERROR: skills/ not found" >&2; exit 1; }
  ROOT="$P"
done

[ -f "${ROOT}/${SKILL}/SKILL.md" ] || { echo "ERROR: skill not found: $SKILL" >&2; exit 1; }

[ -f "$REF_ENV" ] && { set -a; source "$REF_ENV"; set +a; } || true

now=$(date -u +%s)
TOKEN=$(printf '%s' "$SKILL" | tr '[:lower:]' '[:upper:]' | tr -c 'A-Z0-9\n' '_')
SK="SKILL_${TOKEN}_SYNC_AT"

shared_stale=$(( now - ${SHARED_SYNC_AT:-0} > TTL ))
skill_stale=$(( now - ${!SK:-0} > TTL ))

[ "$shared_stale" -ne 0 ] || [ "$skill_stale" -ne 0 ] || { echo "$SKILL: up-to-date"; exit 0; }

TREE=$(curl -sf "${API}/git/trees/${BRANCH}?recursive=1")

# Output: mode<TAB>path for all blobs (incl. symlinks) under skills/<prefix>/
list_blobs() {
  printf '%s' "$TREE" | awk -v p="skills/$1/" '
    /[{]/  { path=""; mode="" }
    /"path"[[:space:]]*:/ { line=$0; sub(/.*"path"[[:space:]]*:[[:space:]]*"/,"",line); sub(/".*$/,"",line); path=line }
    /"mode"[[:space:]]*:/ { line=$0; sub(/.*"mode"[[:space:]]*:[[:space:]]*"/,"",line); sub(/".*$/,"",line); mode=line }
    /"type"[[:space:]]*:[[:space:]]*"blob"/ { if (path!="" && substr(path,1,length(p))==p) print mode"\t"path; path=""; mode="" }
  '
}

sync_component() {
  local name="$1" dest="$2" prefix="$3" ver tmp
  ver=$(curl -sf "${RAW}/skills/${prefix}/.version" || echo "unknown")
  tmp=$(mktemp -d)
  trap "rm -rf '$tmp'" RETURN    # shellcheck disable=SC2064

  while IFS=$'\t' read -r mode file; do
    local out="${tmp}/${file#skills/}"
    mkdir -p "$(dirname "$out")"
    if [ "$mode" = "120000" ]; then
      ln -s "$(curl -sf "${RAW}/${file}")" "$out"
    else
      curl -sf "${RAW}/${file}" -o "$out"
    fi
  done < <(list_blobs "$prefix")

  rm -rf "$dest"
  cp -r "${tmp}/${prefix}" "$dest"
  find "$dest" -name "*.sh" -exec chmod +x {} +
  echo "${name}: synced (${ver})"
}

[ "$shared_stale" -ne 0 ] && sync_component "_shared" "${ROOT}/_shared" "_shared"
[ "$skill_stale"  -ne 0 ] && sync_component "$SKILL"  "${ROOT}/${SKILL}" "$SKILL"

TMPREF=$(mktemp); trap 'rm -f "$TMPREF"' EXIT
[ -f "$REF_ENV" ] && grep -vE "^(SHARED_SYNC_AT|${SK})=" "$REF_ENV" > "$TMPREF" || true
[ "$shared_stale" -ne 0 ] && printf 'SHARED_SYNC_AT=%s\n' "$now" >> "$TMPREF"
[ "$skill_stale"  -ne 0 ] && printf '%s=%s\n' "$SK" "$now" >> "$TMPREF"
mv "$TMPREF" "$REF_ENV"
