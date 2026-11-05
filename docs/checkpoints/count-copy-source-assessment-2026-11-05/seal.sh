#!/usr/bin/env bash
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
out=docs/checkpoints/count-copy-source-assessment-2026-11-05
while IFS= read -r -d '' path; do
  test -f "$path" && test ! -L "$path"
  test ! -e "$path.gz" || exit 1
  gzip -c "$path" > "$path.gz"
  gzip -dc "$path.gz" | cmp - "$path"
  rm -- "$path"
done < <(find "$out" -type f -name '*.log' -print0)
