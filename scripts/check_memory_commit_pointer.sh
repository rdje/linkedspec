#!/usr/bin/env bash
# Validate MEMORY.md's clean activation boundary without asking a Git commit to contain its own hash.
set -euo pipefail

usage() {
 printf '%s\n' \
  'usage: scripts/check_memory_commit_pointer.sh [--phase auto|pre-commit|post-commit] [--repo-root PATH]' >&2
 exit 64
}

phase=auto
repo_root=''
while (( $# > 0 )); do
 case "$1" in
  --phase)
   (( $# >= 2 )) || usage
   phase=$2
   shift 2
   ;;
  --repo-root)
   (( $# >= 2 )) || usage
   repo_root=$2
   shift 2
   ;;
  -h|--help)
   usage
   ;;
  *)
   usage
   ;;
 esac
done

case "$phase" in
 auto|pre-commit|post-commit) ;;
 *) usage ;;
esac

if [[ -z "$repo_root" ]]; then
 repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || {
  printf '%s\n' '[memory-pointer] FAIL: not inside a Git worktree' >&2
  exit 1
 }
fi
repo_root=$(cd -P -- "$repo_root" 2>/dev/null && pwd -P) || {
 printf '[memory-pointer] FAIL: repository root is unavailable: %s\n' "$repo_root" >&2
 exit 1
}
cd "$repo_root"

fail() {
 printf '[memory-pointer] FAIL (%s): %s\n' "$effective_phase" "$*" >&2
 exit 1
}

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
 effective_phase=$phase
 fail "not a Git worktree: $repo_root"
}

memory_text=''
effective_phase=$phase
expected_full=''
expected_description=''

load_worktree_memory() {
 [[ -f MEMORY.md ]] || fail 'working-tree MEMORY.md is missing'
 memory_text=$(<MEMORY.md)
}

load_index_memory() {
 memory_text=$(git show :MEMORY.md 2>/dev/null) || fail 'staged MEMORY.md is missing from the index'
}

load_committed_memory() {
 memory_text=$(git show HEAD:MEMORY.md 2>/dev/null) || fail 'committed HEAD:MEMORY.md is missing'
}

expect_pre_commit_boundary() {
 if expected_full=$(git rev-parse --verify 'HEAD^{commit}' 2>/dev/null); then
  expected_description='current HEAD'
 else
  expected_full=root
  expected_description='the root sentinel before the first commit'
 fi
}

expect_post_commit_boundary() {
 git rev-parse --verify 'HEAD^{commit}' >/dev/null 2>&1 || fail 'post-commit verification requires HEAD'
 if expected_full=$(git rev-parse --verify 'HEAD^1' 2>/dev/null); then
  expected_description='first parent HEAD^1'
 else
  expected_full=root
  expected_description='the root sentinel in the first commit'
 fi
}

case "$phase" in
 pre-commit)
  effective_phase=pre-commit
  if ! git diff --quiet -- MEMORY.md; then
   fail 'MEMORY.md has unstaged changes; stage the exact handoff pointer before committing'
  fi
  load_index_memory
  expect_pre_commit_boundary
  ;;
 post-commit)
  effective_phase=post-commit
  load_committed_memory
  expect_post_commit_boundary
  ;;
 auto)
  index_changed=0
  worktree_changed=0
  git diff --cached --quiet -- MEMORY.md || index_changed=1
  git diff --quiet -- MEMORY.md || worktree_changed=1

  if (( index_changed && worktree_changed )); then
   effective_phase=auto
   fail 'MEMORY.md has both staged and unstaged changes; make its handoff state unambiguous'
  elif (( index_changed )); then
   effective_phase=auto-pre-commit-index
   load_index_memory
   expect_pre_commit_boundary
  elif (( worktree_changed )); then
   effective_phase=auto-pre-commit-worktree
   load_worktree_memory
   expect_pre_commit_boundary
  else
   effective_phase=auto-post-commit
   load_committed_memory
   expect_post_commit_boundary
  fi
  ;;
esac

matches=$(printf '%s\n' "$memory_text" | sed -nE \
 's/^[[:space:]]*-[[:space:]]*activation_commit:[[:space:]]*`(root|[0-9a-f]{7,40})`([[:space:]].*)?$/\1/p')
[[ -n "$matches" ]] ||
 fail 'activation_commit is missing or malformed; expected one `root` or hexadecimal Git commit value'
[[ "$matches" != *$'\n'* ]] || fail 'MEMORY.md must contain exactly one parseable activation_commit field'
stated=$matches

if [[ "$expected_full" == root ]]; then
 [[ "$stated" == root ]] || fail "activation_commit says $stated; expected root for $expected_description"
 printf '[memory-pointer] ok: %s activation_commit is root (%s)\n' "$effective_phase" "$expected_description"
 exit 0
fi

[[ "$stated" != root ]] || fail "activation_commit says root; expected $expected_description"
resolved=$(git rev-parse --verify "${stated}^{commit}" 2>/dev/null) ||
 fail "activation_commit does not resolve to a commit: $stated"
expected_short=$(git rev-parse --short=8 "$expected_full")
[[ "$resolved" == "$expected_full" ]] ||
 fail "activation_commit $stated resolves to ${resolved:0:8}; expected $expected_description $expected_short"

printf '[memory-pointer] ok: %s activation_commit %s resolves to %s %s\n' \
 "$effective_phase" "$stated" "$expected_description" "$expected_short"
