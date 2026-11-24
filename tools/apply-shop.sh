#!/usr/bin/env bash
# apply-shop.sh - copy repo content to build/ with @@TOKEN@@ substituted from tools/shop.conf.
# Usage: tools/apply-shop.sh [source_dir ...]   (default: modules shared)
# Exit codes: 0 ok, 1 config error, 2 unresolved token, 3 length violation.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CONF="$ROOT/tools/shop.conf"
OUT="$ROOT/build"
SRC=("$@")
[ ${#SRC[@]} -eq 0 ] && SRC=(modules shared)

[ -f "$CONF" ] || { echo "missing $CONF" >&2; exit 1; }

declare -A V
while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in ''|\#*) continue ;; esac
  k="${line%%=*}"; v="${line#*=}"
  [[ "$k" =~ ^[A-Z0-9_]+$ ]] || { echo "bad key: $k" >&2; exit 1; }
  V["$k"]="$v"
done < "$CONF"

# Resolve nested tokens inside values (max 5 passes).
for _ in 1 2 3 4 5; do
  changed=0
  for k in "${!V[@]}"; do
    v="${V[$k]}"
    for k2 in "${!V[@]}"; do
      case "$v" in *"@@${k2}@@"*) v="${v//@@${k2}@@/${V[$k2]}}"; changed=1 ;; esac
    done
    V["$k"]="$v"
  done
  [ $changed -eq 0 ] && break
done
for k in "${!V[@]}"; do
  case "${V[$k]}" in *@@*) echo "unresolved nested token in $k: ${V[$k]}" >&2; exit 2 ;; esac
done

# Constraint checks.
[ ${#V[LABHLQ]} -le 26 ] || { echo "LABHLQ too long" >&2; exit 3; }
[ ${#V[JOBPFX]} -le 4 ]  || { echo "JOBPFX must be <= 4 chars" >&2; exit 3; }
[ ${#V[USERID]} -le 7 ]  || { echo "USERID must be <= 7 chars" >&2; exit 3; }
[ ${#V[JOBPARMS]} -le 71 ] || { echo "JOBPARMS must be <= 71 chars" >&2; exit 3; }
for z in GZONE TZ1 DZ1 TZ2 DZ2; do
  [ ${#V[$z]} -le 7 ] || { echo "$z must be <= 7 chars" >&2; exit 3; }
done

rm -rf "$OUT"; mkdir -p "$OUT"

# Build sed script. Escape sed-special chars in replacement.
SEDF="$(mktemp)"; trap 'rm -f "$SEDF"' EXIT
for k in "${!V[@]}"; do
  r="${V[$k]}"
  r="${r//\\/\\\\}"; r="${r//&/\\&}"; r="${r//|/\\|}"
  printf 's|@@%s@@|%s|g\n' "$k" "$r" >> "$SEDF"
done

for d in "${SRC[@]}"; do
  [ -d "$ROOT/$d" ] || continue
  while IFS= read -r -d '' f; do
    rel="${f#$ROOT/}"
    # Substitute tokens in file name as well.
    outrel="$(printf '%s' "$rel" | sed -f "$SEDF")"
    mkdir -p "$OUT/$(dirname "$outrel")"
    case "$f" in
      *.jcl|*.rexx|*.mcs|*.txt|*.out|*.md|*.cntl|*.parm|*.sh)
        sed -f "$SEDF" "$f" > "$OUT/$outrel" ;;
      *) cp "$f" "$OUT/$outrel" ;;
    esac
  done < <(find "$ROOT/$d" -type f -print0)
done

# Fail on residual tokens in text outputs.
if grep -rIn '@@[A-Z0-9_]\+@@' "$OUT" >/dev/null 2>&1; then
  echo "unresolved tokens remain:" >&2
  grep -rIn '@@[A-Z0-9_]\+@@' "$OUT" | head -50 >&2
  exit 2
fi

# JCL line-length check (cols 1-71 content, 80 max).
bad=0
while IFS= read -r -d '' f; do
  if awk 'length($0)>80{exit 1}' "$f"; then :; else echo "line >80 chars: $f" >&2; bad=1; fi
done < <(find "$OUT" -type f \( -name '*.jcl' -o -name '*.cntl' \) -print0)
[ $bad -eq 0 ] || exit 3

echo "build complete: $OUT"