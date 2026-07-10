#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
JULIA_CMD="${LINKEDSPEC_JULIA_CMD:-julia}"
DEFAULT_JULIA_DEPOT="${TMPDIR:-/tmp}/linkedspec-julia-depot"
JULIA_DEPOT="${LINKEDSPEC_JULIA_DEPOT_PATH:-${JULIA_DEPOT_PATH:-$DEFAULT_JULIA_DEPOT}}"

log() {
 printf '[julia-ci] %s\n' "$*"
}

fail() {
 printf '[julia-ci] ERROR: %s\n' "$*" >&2
 exit 1
}

command -v "$JULIA_CMD" >/dev/null 2>&1 || fail "required command not found: $JULIA_CMD"

export JULIA_DEPOT_PATH="$JULIA_DEPOT"
mkdir -p "$JULIA_DEPOT_PATH"
cd "$REPO_ROOT"

log "using Julia depot: $JULIA_DEPOT_PATH"
log "running Julia package tests"
"$JULIA_CMD" --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'

log "checking Julia CLIs"
LINKEDSPEC_JULIA_CMD="$JULIA_CMD" \
LINKEDSPEC_JULIA_DEPOT_PATH="$JULIA_DEPOT_PATH" \
bash tools/check_julia_primary_cli.sh
"$JULIA_CMD" --project=julia --startup-file=no --history-file=no julia/bin/corpus_runner.jl --help >/dev/null

log "running full Julia corpus gate"
"$JULIA_CMD" --project=julia --startup-file=no --history-file=no julia/bin/corpus_runner.jl \
 --corpus rust/linkedspec-runtime/tests/corpus --execute

log "Julia local gate passed"
