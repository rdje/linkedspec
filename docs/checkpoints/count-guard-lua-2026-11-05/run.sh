#!/usr/bin/env bash
# Retain each actual installed host's direct inputs and public observations.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
case "${1:-}" in baseline|qualified|final) phase=$1 ;; *) exit 64 ;; esac
out=docs/checkpoints/count-guard-lua-2026-11-05
for suffix in inputs.tar.gz head.txt; do test ! -e "$out/$phase-$suffix" || exit 1; done
git rev-parse HEAD > "$out/$phase-head.txt"
tar -czf "$out/$phase-inputs.tar.gz" "$out/run.sh" \
  lua/src/linkedspec/interpreter.lua lua/test/run.lua \
  lua/test/count_result_guard_composition_test.lua \
  tests/fixtures/count_result_guard_cases.json \
  tests/fixtures/count_result_guard_source_owner_cases.json \
  tests/fixtures/count_result_guard_excluded_ast.json \
  tests/fixtures/count_result_guard_lua_ast.json \
  tests/fixtures/count_result_guard_lua_domain.json \
  tests/fixtures/count_result_guard_lua_errors.json \
  tools/run_lua_project_data.sh tools/build_lua_native.sh \
  tools/project_data_env.sh tools/project_data_run.sh
failed=0
for host in puc luajit; do
  for suffix in stdout.log stderr.log exit.txt version-stdout.log version-stderr.log; do
    test ! -e "$out/$phase-$host-$suffix" || exit 1
  done
  bash tools/run_lua_project_data.sh "$host" -v \
    > "$out/$phase-$host-version-stdout.log" 2> "$out/$phase-$host-version-stderr.log"
  result=0
  LINKEDSPEC_COUNT_GUARD_CAPTURE=1 bash tools/run_lua_project_data.sh "$host" \
    lua/test/count_result_guard_composition_test.lua \
    > "$out/$phase-$host-stdout.log" 2> "$out/$phase-$host-stderr.log" || result=$?
  printf '%s\n' "$result" > "$out/$phase-$host-exit.txt"
  printf '%s %s exit=%s\n' "$phase" "$host" "$result"
  if test "$result" -ne 0; then failed=1; fi
done
exit "$failed"
