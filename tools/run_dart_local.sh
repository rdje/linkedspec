#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/run_dart_local.sh" "$@"
DART_CMD="${LINKEDSPEC_DART_CMD:-dart}"

log() {
 printf '[dart-ci] %s\n' "$*"
}

fail() {
 printf '[dart-ci] ERROR: %s\n' "$*" >&2
 exit 1
}

command -v "$DART_CMD" >/dev/null 2>&1 || fail "required command not found: $DART_CMD"

cd "$REPO_ROOT/dart"

log "running Dart format"
"$DART_CMD" format --set-exit-if-changed .

log "running Dart analyzer"
"$DART_CMD" analyze --fatal-infos --fatal-warnings

log "running Dart tests"
"$DART_CMD" test

log "checking Dart CLIs"
"$DART_CMD" run bin/linkedspec_dart.dart --help >/dev/null
"$DART_CMD" run bin/corpus_runner.dart --help >/dev/null
"$DART_CMD" run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --limit 1 >/dev/null

log "running shared primary CLI contract (default environment)"
(
 cd "$REPO_ROOT"
 env -u POSIXLY_CORRECT PERL5LIB= perl tools/run_cli_conformance.pl \
  --display-command 'dart run bin/linkedspec_dart.dart' -- \
  "$DART_CMD" --packages={{REPO_ROOT}}/dart/.dart_tool/package_config.json \
  '{{REPO_ROOT}}/dart/bin/linkedspec_dart.dart'
)

log "running shared primary CLI contract (POSIX environment)"
(
 cd "$REPO_ROOT"
 env POSIXLY_CORRECT=1 PERL5LIB= perl tools/run_cli_conformance.pl \
  --display-command 'dart run bin/linkedspec_dart.dart' -- \
  "$DART_CMD" --packages={{REPO_ROOT}}/dart/.dart_tool/package_config.json \
  '{{REPO_ROOT}}/dart/bin/linkedspec_dart.dart'
)

log "running full Dart corpus gate"
"$DART_CMD" run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute

log "Dart local gate passed"
