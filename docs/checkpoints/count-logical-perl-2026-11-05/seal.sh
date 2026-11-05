#!/usr/bin/env bash
# Lossless custody packaging of this leaf's completed acquisition files only.
set -euo pipefail
source tools/project_data_env.sh
base=docs/checkpoints/count-logical-perl-2026-11-05
for phase in before after; do
 for path in "$base/$phase/MethodLowering.pm" "$base/$phase/normal.t" "$base/$phase/perl-version.txt" \
  "$base/$phase/stdout.tap" "$base/$phase/stderr.log" \
  "$base/$phase/lowering.log" "$base/$phase/lowering-stderr.log" \
  "$base/$phase/emitted/"*.pl; do
  gzip -n -c "$path" > "$path.gz"
  gzip -cd "$path.gz" | cmp - "$path"
  rm -- "$path"
 done
done
