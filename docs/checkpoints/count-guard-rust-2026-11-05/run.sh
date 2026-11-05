#!/usr/bin/env bash
# Retain exact direct inputs and both focused observer outputs. No historical overwrite.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
case "${1:-}" in baseline|candidate|final) phase=$1 ;; *) exit 64 ;; esac
out=docs/checkpoints/count-guard-rust-2026-11-05
for suffix in inputs.tar.gz head.txt native.log fresh.log trace.log exits.txt; do
  test ! -e "$out/$phase-$suffix" || { printf 'refusing to overwrite %s\n' "$out/$phase-$suffix" >&2; exit 1; }
done
git rev-parse HEAD > "$out/$phase-head.txt"
tar -czf "$out/$phase-inputs.tar.gz" \
  "$out/run.sh" \
  rust/linkedspec-runtime/src/engine.rs \
  rust/linkedspec-runtime/tests/count_result_guard_composition.rs \
  rust/linkedspec-runtime/tests/generated_source_full_manifest_classifier.rs \
  tests/fixtures/count_result_guard_cases.json \
  tests/fixtures/count_result_guard_excluded_ast.json \
  tests/fixtures/count_result_guard_rust_ast.json \
  tests/fixtures/count_result_guard_rust_domain.json \
  tests/fixtures/count_result_guard_source_owner_cases.json \
  "$out/source-owner-reference.pl" \
  rust/Cargo.toml rust/Cargo.lock rust/linkedspec-runtime/Cargo.toml \
  tools/run_cargo_local.sh tools/project_data_run.sh tools/project_data_env.sh
native_exit=0
bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
  --test count_result_guard_composition -- --nocapture --test-threads=1 \
  > "$out/$phase-native.log" 2>&1 || native_exit=$?
fresh_exit=0
bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
  --test generated_source_full_manifest_classifier \
  count_result_guards_in_independently_compiled_emitted_source -- --nocapture \
  > "$out/$phase-fresh.log" 2>&1 || fresh_exit=$?
trace_exit=0
bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime \
  --test generated_source_full_manifest_classifier count_result_guard_native_trace -- --nocapture \
  > "$out/$phase-trace.log" 2>&1 || trace_exit=$?
printf 'native=%s\nfresh=%s\ntrace=%s\n' "$native_exit" "$fresh_exit" "$trace_exit" > "$out/$phase-exits.txt"
cat "$out/$phase-exits.txt"
test "$native_exit" -eq 0 && test "$fresh_exit" -eq 0 && test "$trace_exit" -eq 0
