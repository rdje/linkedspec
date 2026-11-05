#!/usr/bin/env bash
# Retain complete exact logs without redundant plaintext evidence.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
out=docs/checkpoints/count-guard-lua-2026-11-05
for path in "$out"/*.log; do
  test -e "$path" || continue
  test -f "$path" && test ! -L "$path"
  test ! -e "$path.gz" || exit 1
  gzip -c "$path" > "$path.gz"
  gzip -dc "$path.gz" | cmp - "$path"
  rm -- "$path"
done
