#!/usr/bin/env bash
# Retain actual direct inputs and public native/generated observations per phase.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
case "${1:-}" in baseline|qualified|final) phase=$1 ;; *) exit 64 ;; esac
out=docs/checkpoints/count-guard-julia-2026-11-05
for suffix in inputs.tar.gz head.txt stdout.log stderr.log exit.txt; do
  test ! -e "$out/$phase-$suffix" || { printf 'refusing to overwrite %s\n' "$out/$phase-$suffix" >&2; exit 1; }
done
git rev-parse HEAD > "$out/$phase-head.txt"
tar -czf "$out/$phase-inputs.tar.gz" "$out/run.sh" \
  julia/src/runtime/Interpreter.jl julia/test/count_result_guard_composition_test.jl \
  julia/test/runtests.jl julia/Project.toml julia/Manifest.toml \
  tests/fixtures/count_result_guard_cases.json \
  tests/fixtures/count_result_guard_source_owner_cases.json \
  tests/fixtures/count_result_guard_excluded_ast.json \
  tests/fixtures/count_result_guard_julia_ast.json \
  tests/fixtures/count_result_guard_julia_domain.json \
  tests/fixtures/count_result_guard_julia_errors.json \
  tools/run_julia_project_data.sh tools/project_data_env.sh tools/project_data_run.sh
result=0
LINKEDSPEC_COUNT_GUARD_CAPTURE=1 bash tools/run_julia_project_data.sh \
  --project=julia --depwarn=error julia/test/count_result_guard_composition_test.jl \
  > "$out/$phase-stdout.log" 2> "$out/$phase-stderr.log" || result=$?
printf '%s\n' "$result" > "$out/$phase-exit.txt"
printf '%s exit=%s\n' "$phase" "$result"
exit "$result"
