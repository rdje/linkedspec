#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
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

log "running full Dart corpus gate"
"$DART_CMD" run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute

log "Dart local gate passed"
