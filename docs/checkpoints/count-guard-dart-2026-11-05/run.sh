#!/usr/bin/env bash
# Retain direct inputs and focused Dart native/emitted outcomes once per phase.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
case "${1:-}" in baseline|candidate|final) phase=$1 ;; *) exit 64 ;; esac
out=docs/checkpoints/count-guard-dart-2026-11-05
for suffix in inputs.tar.gz head.txt native.log fresh.log exits.txt; do
  test ! -e "$out/$phase-$suffix" || { printf 'refusing to overwrite %s\n' "$out/$phase-$suffix" >&2; exit 1; }
done
git rev-parse HEAD > "$out/$phase-head.txt"
tar -czf "$out/$phase-inputs.tar.gz" \
  "$out/run.sh" \
  dart/lib/src/runtime/interpreter.dart \
  dart/test/count_result_guard_composition_test.dart dart/test/source_emitter_test.dart \
  tests/fixtures/count_result_guard_cases.json \
  tests/fixtures/count_result_guard_source_owner_cases.json \
  tests/fixtures/count_result_guard_excluded_ast.json \
  tests/fixtures/count_result_guard_dart_ast.json \
  tests/fixtures/count_result_guard_dart_domain.json \
  dart/pubspec.yaml dart/pubspec.lock dart/.dart_tool/package_config.json \
  tools/run_dart_project_data.sh tools/project_data_run.sh tools/project_data_env.sh
native_exit=0
(cd dart && bash ../tools/run_dart_project_data.sh test --reporter expanded \
  test/count_result_guard_composition_test.dart) \
  > "$out/$phase-native.log" 2>&1 || native_exit=$?
fresh_exit=0
(cd dart && bash ../tools/run_dart_project_data.sh test --reporter expanded \
  test/source_emitter_test.dart --name '^Count source guards in compiled emission$') \
  > "$out/$phase-fresh.log" 2>&1 || fresh_exit=$?
printf 'native=%s\nfresh=%s\n' "$native_exit" "$fresh_exit" > "$out/$phase-exits.txt"
cat "$out/$phase-exits.txt"
test "$native_exit" -eq 0 && test "$fresh_exit" -eq 0
