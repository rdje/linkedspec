#!/usr/bin/env bash
# Selected direct consumers only; preserve their actual inline/literal inputs.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
out=docs/checkpoints/count-guard-julia-2026-11-05
for suffix in inputs.tar.gz stdout.log stderr.log exit.txt; do
  test ! -e "$out/compatibility-$suffix" || exit 1
done
tar -czf "$out/compatibility-inputs.tar.gz" "$out/compatibility.sh" \
  julia/test/count_length_receivers_test.jl julia/test/copied_null_index_composition_test.jl \
  tests/fixtures/copied_null_index_cases.json julia/Project.toml julia/Manifest.toml
result=0
bash tools/run_julia_project_data.sh --project=julia --depwarn=error \
  -e 'using LinkedSpecJulia, JSON3, Test; include(ARGS[1]); include(ARGS[2])' \
  julia/test/count_length_receivers_test.jl julia/test/copied_null_index_composition_test.jl \
  > "$out/compatibility-stdout.log" 2> "$out/compatibility-stderr.log" || result=$?
printf '%s\n' "$result" > "$out/compatibility-exit.txt"
printf 'compatibility exit=%s\n' "$result"
exit "$result"
