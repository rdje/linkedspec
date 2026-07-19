#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
JULIA_CMD="${LINKEDSPEC_JULIA_CMD:-julia}"
DEFAULT_JULIA_DEPOT="${TMPDIR:-/tmp}/linkedspec-julia-depot"
JULIA_DEPOT="${LINKEDSPEC_JULIA_DEPOT_PATH:-${JULIA_DEPOT_PATH:-$DEFAULT_JULIA_DEPOT}}"
PRIMARY_CLI="$REPO_ROOT/julia/bin/linkedspec_julia.jl"

case "$(uname -s)" in
 MINGW*|MSYS*|CYGWIN*) WRITABLE_JULIA_DEPOT="${JULIA_DEPOT%%;*}" ;;
 *) WRITABLE_JULIA_DEPOT="${JULIA_DEPOT%%:*}" ;;
esac

fail() {
 printf '[julia-primary] ERROR: %s\n' "$*" >&2
 exit 1
}

command -v "$JULIA_CMD" >/dev/null 2>&1 || fail "required command not found: $JULIA_CMD"
command -v rg >/dev/null 2>&1 || fail "required command not found: rg"
[[ -n "$WRITABLE_JULIA_DEPOT" ]] || fail "first Julia depot entry must not be empty"

export JULIA_DEPOT_PATH="$JULIA_DEPOT"
mkdir -p "$WRITABLE_JULIA_DEPOT"

TEMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/linkedspec-julia-primary.XXXXXX")
cleanup() {
 rm -rf "$TEMP_ROOT"
}
trap cleanup EXIT HUP INT TERM

STDOUT_FILE="$TEMP_ROOT/stdout.txt"
STDERR_FILE="$TEMP_ROOT/stderr.txt"
EXPECTED_FILE="$TEMP_ROOT/expected.txt"
TRACE_FILE="$TEMP_ROOT/trace.log"
TRACE_PREFIX_FILE="$TEMP_ROOT/trace-prefix.txt"
JSON_SUFFIX_FILE="$TEMP_ROOT/json-suffix.txt"

run_primary() {
 local label=$1
 shift
 : >"$STDOUT_FILE"
 : >"$STDERR_FILE"
 set +e
 "$JULIA_CMD" --project="$REPO_ROOT/julia" --startup-file=no --history-file=no \
  "$PRIMARY_CLI" "$@" >"$STDOUT_FILE" 2>"$STDERR_FILE"
 PRIMARY_STATUS=$?
 set -e
 PRIMARY_LABEL=$label
}

expect_status() {
 local expected=$1
 [[ "$PRIMARY_STATUS" -eq "$expected" ]] || \
  fail "$PRIMARY_LABEL exited $PRIMARY_STATUS; expected $expected"
}

expect_empty() {
 local path=$1
 [[ ! -s "$path" ]] || fail "$PRIMARY_LABEL produced unexpected content in $path"
}

expect_exact() {
 local expected=$1
 local actual=$2
 cmp -s "$expected" "$actual" || fail "$PRIMARY_LABEL output differed from $expected"
}

expect_contains() {
 local needle=$1
 local path=$2
 rg -F -q -- "$needle" "$path" || fail "$PRIMARY_LABEL did not contain '$needle' in $path"
}

expect_first_line() {
 local expected=$1
 local path=$2
 local actual=''
 IFS= read -r actual <"$path" || true
 [[ "$actual" == "$expected" ]] || \
  fail "$PRIMARY_LABEL first line was '$actual'; expected '$expected'"
}

"$JULIA_CMD" --project="$REPO_ROOT/julia" --startup-file=no --history-file=no \
 -e 'using LinkedSpecJulia' >/dev/null

run_primary help --help
expect_status 0
expect_empty "$STDERR_FILE"
sed 's/{{COMMAND}}/linkedspec_julia/g' \
 "$REPO_ROOT/cli_conformance/cases/help/stdout.txt" >"$EXPECTED_FILE"
expect_exact "$EXPECTED_FILE" "$STDOUT_FILE"

RULE_SPEC="$TEMP_ROOT/rule.spec"
INPUT_FILE="$TEMP_ROOT/input.txt"
printf '%s' $'Top::\n /x/\n E { return(hash("z", 0, "a", hash("d", 4, "b", 2))) }\n' >"$RULE_SPEC"
printf '%s' 'x' >"$INPUT_FILE"
printf '%s\n' '{"a":{"b":2,"d":4},"z":0}' >"$EXPECTED_FILE"

run_primary rule-file --spec-file "$RULE_SPEC" --input-file "$INPUT_FILE"
expect_status 0
expect_exact "$EXPECTED_FILE" "$STDOUT_FILE"
expect_empty "$STDERR_FILE"

FUNCTION_SPEC=$'fn wrap(value) { return(hash("wrapped", value)) }\nTop::\n /x/\n E { return(wrap(match_text())) }\n'
printf '%s\n' '{"wrapped":"x"}' >"$EXPECTED_FILE"
run_primary function-inline \
 --inline-spec "$FUNCTION_SPEC" --input x --top-rule Top
expect_status 0
expect_exact "$EXPECTED_FILE" "$STDOUT_FILE"
expect_empty "$STDERR_FILE"

run_primary removed-parse-mode \
 --inline-spec 'not a spec' --input-file "$TEMP_ROOT/missing-input.txt" \
 --parse-mode consume
expect_status 2
expect_empty "$STDOUT_FILE"
expect_first_line \
 "linkedspec: --parse-mode has been removed; cursor policy is derived from each rule (OR/default=seek, AND=consume)" \
 "$STDERR_FILE"

run_primary retired-subcommand status
expect_status 2
expect_empty "$STDOUT_FILE"
expect_first_line "linkedspec: unexpected positional argument 'status'" "$STDERR_FILE"

run_primary compilation-failure \
 --inline-spec 'not a spec' --input-file "$TEMP_ROOT/missing-input.txt"
expect_status 1
expect_empty "$STDOUT_FILE"
printf '%s\n' 'linkedspec: parser compilation failed' >"$EXPECTED_FILE"
expect_exact "$EXPECTED_FILE" "$STDERR_FILE"

run_primary input-failure \
 --inline-spec $'Top::\n /x/\n' --input-file "$TEMP_ROOT/missing-input.txt"
expect_status 1
expect_empty "$STDOUT_FILE"
printf '%s\n' 'linkedspec: input load failed' >"$EXPECTED_FILE"
expect_exact "$EXPECTED_FILE" "$STDERR_FILE"

run_primary invocation-failure \
 --inline-spec $'Top::\n /x/\n' --input x --top-rule Missing
expect_status 1
expect_empty "$STDOUT_FILE"
printf '%s\n' 'linkedspec: parser invocation failed' >"$EXPECTED_FILE"
expect_exact "$EXPECTED_FILE" "$STDERR_FILE"

printf '%s\n' '"trace"' >"$EXPECTED_FILE"
run_primary routed-trace \
 --inline-spec $'Top::\n /x/\n E { return("trace") }\n' --input x \
 --trace high --trace-file "$TRACE_FILE" --trace-mode route --trace-reset --trace-emoji
expect_status 0
expect_exact "$EXPECTED_FILE" "$STDOUT_FILE"
expect_empty "$STDERR_FILE"
[[ -s "$TRACE_FILE" ]] || fail 'routed-trace did not write its trace file'
expect_contains 'ℹ️ ' "$TRACE_FILE"
expect_contains '🔎 ' "$TRACE_FILE"
expect_contains '🧭 ' "$TRACE_FILE"

run_primary mirrored-trace \
 --inline-spec $'Top::\n /x/\n E { return("trace") }\n' --input x \
 --trace high --trace-file "$TRACE_FILE" --trace-mode mirror --trace-reset
expect_status 0
expect_empty "$STDERR_FILE"
[[ -s "$TRACE_FILE" ]] || fail 'mirrored-trace did not write its trace file'
TRACE_BYTES=$(wc -c <"$TRACE_FILE")
dd if="$STDOUT_FILE" of="$TRACE_PREFIX_FILE" bs=1 count="$TRACE_BYTES" status=none
dd if="$STDOUT_FILE" of="$JSON_SUFFIX_FILE" bs=1 skip="$TRACE_BYTES" status=none
expect_exact "$TRACE_FILE" "$TRACE_PREFIX_FILE"
expect_exact "$EXPECTED_FILE" "$JSON_SUFFIX_FILE"

printf '[julia-primary] primary CLI process conformance passed\n'
