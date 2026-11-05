#!/usr/bin/env bash
# Execute only the two actual direct consumers on each installed safe host.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
out=docs/checkpoints/count-guard-lua-2026-11-05
test ! -e "$out/compatibility-inputs.tar.gz" || exit 1
tar -czf "$out/compatibility-inputs.tar.gz" "$out/compatibility.sh" \
  lua/test/count_length_receivers_test.lua lua/test/copied_null_index_composition_test.lua \
  tests/fixtures/copied_null_index_cases.json
failed=0
for host in puc luajit; do
  for suffix in stdout.log stderr.log exit.txt; do test ! -e "$out/compatibility-$host-$suffix" || exit 1; done
  result=0
  bash tools/run_lua_project_data.sh "$host" \
    -e 'dofile("lua/test/count_length_receivers_test.lua"); dofile("lua/test/copied_null_index_composition_test.lua")' \
    > "$out/compatibility-$host-stdout.log" 2> "$out/compatibility-$host-stderr.log" || result=$?
  printf '%s\n' "$result" > "$out/compatibility-$host-exit.txt"
  printf 'compatibility %s exit=%s\n' "$host" "$result"
  if test "$result" -ne 0; then failed=1; fi
done
exit "$failed"
