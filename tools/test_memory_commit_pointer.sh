#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -P -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/test_memory_commit_pointer.sh" "$@"

(( $# == 0 )) || {
 printf '[memory-pointer-test] ERROR: unexpected argument: %s\n' "$1" >&2
 exit 64
}

CHECKER="$REPO_ROOT/scripts/check_memory_commit_pointer.sh"
FIXTURE_REPO="$TMPDIR/memory-pointer-fixture"
tests=0

fail() {
 printf '[memory-pointer-test] ERROR: %s\n' "$*" >&2
 exit 1
}

write_memory() {
 local value=$1
 printf '# MEMORY fixture\n\n- activation_commit: `%s`\n' "$value" > "$FIXTURE_REPO/MEMORY.md"
}

expect_success() {
 local label=$1
 shift
 local output
 output=$("$@" 2>&1) || fail "$label unexpectedly failed: $output"
 [[ "$output" == *'[memory-pointer] ok:'* ]] || fail "$label omitted success evidence: $output"
 tests=$((tests + 1))
}

expect_failure() {
 local label=$1
 local needle=$2
 shift 2
 local output
 if output=$("$@" 2>&1); then
  fail "$label unexpectedly passed: $output"
 fi
 [[ "$output" == *"$needle"* ]] || fail "$label omitted '$needle': $output"
 tests=$((tests + 1))
}

mkdir -p -- "$FIXTURE_REPO"
git -C "$FIXTURE_REPO" init -q
git -C "$FIXTURE_REPO" config user.name 'LinkedSpec pointer fixture'
git -C "$FIXTURE_REPO" config user.email 'pointer-fixture@invalid.example'

write_memory root
git -C "$FIXTURE_REPO" add MEMORY.md
expect_success 'root pre-commit' "$CHECKER" --phase pre-commit --repo-root "$FIXTURE_REPO"
git -C "$FIXTURE_REPO" -c core.hooksPath=/dev/null commit --no-gpg-sign -qm 'FIXTURE.0 - create root'
expect_success 'root post-commit' "$CHECKER" --phase post-commit --repo-root "$FIXTURE_REPO"
expect_success 'root clean auto' "$CHECKER" --phase auto --repo-root "$FIXTURE_REPO"

root_commit=$(git -C "$FIXTURE_REPO" rev-parse --short=8 HEAD)
write_memory "$root_commit"
git -C "$FIXTURE_REPO" add MEMORY.md
expect_success 'leaf pre-commit' "$CHECKER" --phase pre-commit --repo-root "$FIXTURE_REPO"
git -C "$FIXTURE_REPO" -c core.hooksPath=/dev/null commit --no-gpg-sign -qm 'FIXTURE.1 - land leaf'
expect_success 'leaf post-commit' "$CHECKER" --phase post-commit --repo-root "$FIXTURE_REPO"
expect_success 'leaf clean auto' "$CHECKER" --phase auto --repo-root "$FIXTURE_REPO"

write_memory not-a-hash
git -C "$FIXTURE_REPO" add MEMORY.md
expect_failure 'malformed staged pointer' 'missing or malformed' \
 "$CHECKER" --phase pre-commit --repo-root "$FIXTURE_REPO"

write_memory "$root_commit"
git -C "$FIXTURE_REPO" add MEMORY.md
expect_failure 'genuine staged drift' 'expected current HEAD' \
 "$CHECKER" --phase pre-commit --repo-root "$FIXTURE_REPO"

printf '# MEMORY fixture\n\n- activation_commit: `%s`\n- activation_commit: `%s`\n' \
 "$root_commit" "$root_commit" > "$FIXTURE_REPO/MEMORY.md"
git -C "$FIXTURE_REPO" add MEMORY.md
expect_failure 'duplicate pointer' 'exactly one' \
 "$CHECKER" --phase pre-commit --repo-root "$FIXTURE_REPO"

git -C "$FIXTURE_REPO" restore --staged --worktree MEMORY.md
current_head=$(git -C "$FIXTURE_REPO" rev-parse --short=8 HEAD)
write_memory "$current_head"
expect_success 'unstaged preparation auto' "$CHECKER" --phase auto --repo-root "$FIXTURE_REPO"

git -C "$FIXTURE_REPO" add MEMORY.md
write_memory "$root_commit"
expect_failure 'staged and unstaged ambiguity' 'both staged and unstaged' \
 "$CHECKER" --phase auto --repo-root "$FIXTURE_REPO"

[[ "$tests" -eq 11 ]] || fail "expected 11 cases, ran $tests"
printf '[memory-pointer-test] PASS: %d hermetic cases; fixture stayed under repository-volume TMPDIR\n' "$tests"
