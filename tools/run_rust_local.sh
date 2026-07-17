#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
CARGO_CMD="${LINKEDSPEC_CARGO_CMD:-cargo}"

log() {
 printf '[rust-ci] %s\n' "$*"
}

fail() {
 printf '[rust-ci] ERROR: %s\n' "$*" >&2
 exit 1
}

command -v "$CARGO_CMD" >/dev/null 2>&1 || fail "required command not found: $CARGO_CMD"
command -v perl >/dev/null 2>&1 || fail "required command not found: perl"

cd "$REPO_ROOT"

log "checking Rust formatting"
"$CARGO_CMD" fmt --manifest-path rust/Cargo.toml --all -- --check

log "running Rust core package tests"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-core

log "running Rust runtime package tests"
"$CARGO_CMD" test --manifest-path rust/Cargo.toml -p linkedspec-runtime

log "building Rust primary command"
"$CARGO_CMD" build --manifest-path rust/Cargo.toml -p linkedspec-runtime --bin linkedspec-rust

TARGET_DIR="${CARGO_TARGET_DIR:-$REPO_ROOT/rust/target}"
if [[ "$TARGET_DIR" != /* ]]; then
 TARGET_DIR="$REPO_ROOT/$TARGET_DIR"
fi
PRIMARY_COMMAND="$TARGET_DIR/debug/linkedspec-rust"
[[ -x "$PRIMARY_COMMAND" ]] || fail "built primary command is not executable: $PRIMARY_COMMAND"

log "running Rust primary CLI conformance (default option environment)"
PERL5LIB= perl tools/run_cli_conformance.pl \
 --display-command linkedspec-rust \
 -- "$PRIMARY_COMMAND"

log "running Rust primary CLI conformance (POSIX option environment)"
POSIXLY_CORRECT=1 PERL5LIB= perl tools/run_cli_conformance.pl \
 --display-command linkedspec-rust \
 -- "$PRIMARY_COMMAND"

log "Rust local gate passed"
