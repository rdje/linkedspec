#!/usr/bin/env bash
# Bind a successful canonical local-CI run to the exact staged Git candidate.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"
source "$REPO_ROOT/tools/project_data_env.sh"
cd "$REPO_ROOT"

fail() {
  printf 'verification-receipt: FAIL: %s\n' "$1" >&2
  exit 1
}

receipt_path() {
  local path=${LINKEDSPEC_VERIFICATION_RECEIPT_PATH:-$LINKEDSPEC_PROJECT_DATA_ROOT/verification/canonical-v1.receipt}
  linkedspec_project_data_validate_output_path "$path" 'canonical verification receipt' >/dev/null ||
    fail "receipt path is not valid repository-volume project data: $path"
  printf '%s\n' "$path"
}

require_exact_index_worktree() {
  git diff --quiet --ignore-submodules -- ||
    fail 'unstaged tracked changes exist; stage the exact canonical candidate before running the gate'
  if [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
    fail 'untracked non-ignored files exist; stage or remove them before running the canonical gate'
  fi
}

staged_content_hash() {
  git diff --cached --binary --full-index --no-ext-diff HEAD | shasum -a 256 | awk '{print $1}'
}

commit_content_hash() {
  local parent=$1
  local commit=$2
  git diff --binary --full-index --no-ext-diff "$parent" "$commit" | shasum -a 256 | awk '{print $1}'
}

current_staged_fingerprint() {
  local head
  local content
  require_exact_index_worktree
  head=$(git rev-parse HEAD) || fail 'cannot resolve HEAD'
  content=$(staged_content_hash) || fail 'cannot hash the staged candidate'
  [[ "$content" =~ ^[0-9a-f]{64}$ ]] || fail 'staged candidate hash is malformed'
  printf '%s %s\n' "$head" "$content"
}

read_receipt() {
  local path=$1
  local version
  local state
  local head
  local content
  local gate

  [[ -f "$path" && ! -L "$path" ]] || fail "canonical receipt is missing: $path"
  [[ "$(wc -l < "$path" | tr -d ' ')" == 5 ]] || fail 'canonical receipt must contain exactly five lines'
  version=$(sed -n 's/^version=//p' "$path")
  state=$(sed -n 's/^state=//p' "$path")
  head=$(sed -n 's/^head=//p' "$path")
  content=$(sed -n 's/^content=//p' "$path")
  gate=$(sed -n 's/^gate=//p' "$path")
  [[ "$version" == 1 ]] || fail 'canonical receipt version is not 1'
  [[ "$state" == staged || "$state" == committed ]] || fail 'canonical receipt state is invalid'
  [[ "$head" =~ ^[0-9a-f]{40}$ ]] || fail 'canonical receipt HEAD is malformed'
  if [[ "$state" == staged ]]; then
    [[ "$content" =~ ^[0-9a-f]{64}$ ]] || fail 'canonical staged-content hash is malformed'
  else
    [[ "$content" =~ ^[0-9a-f]{40}$ ]] || fail 'canonical committed-tree hash is malformed'
  fi
  [[ "$gate" == tools/run_ci_local.sh ]] || fail 'canonical receipt gate identity is invalid'
  printf '%s %s %s\n' "$state" "$head" "$content"
}

write_receipt() {
  local state=$1
  local head=$2
  local content=$3
  local path
  local directory
  local temporary

  path=$(receipt_path)
  directory=$(dirname -- "$path")
  mkdir -p -- "$directory"
  temporary="$path.tmp.$$"
  printf 'version=1\nstate=%s\nhead=%s\ncontent=%s\ngate=tools/run_ci_local.sh\n' \
    "$state" "$head" "$content" > "$temporary"
  mv -- "$temporary" "$path"
}

case "${1:-}" in
  fingerprint)
    current_staged_fingerprint
    ;;
  write-staged)
    [[ $# == 2 ]] || fail 'write-staged requires the start fingerprint as one quoted argument'
    current=$(current_staged_fingerprint)
    [[ "$current" == "$2" ]] || fail 'staged HEAD/tree changed while canonical CI was running'
    read -r head content <<< "$current"
    if git diff --cached --quiet --ignore-submodules --; then
      tree=$(git rev-parse 'HEAD^{tree}') || fail 'cannot resolve committed HEAD tree'
      write_receipt committed "$head" "$tree"
      printf 'verification-receipt: wrote committed canonical receipt for HEAD %s\n' "$head"
    else
      write_receipt staged "$head" "$content"
      printf 'verification-receipt: wrote staged canonical receipt for HEAD %s and candidate %s\n' "$head" "$content"
    fi
    ;;
  check-staged)
    [[ $# == 1 ]] || fail 'check-staged takes no additional arguments'
    expected=$(current_staged_fingerprint)
    read -r head content <<< "$expected"
    if git diff --cached --quiet --ignore-submodules --; then
      tree=$(git rev-parse 'HEAD^{tree}') || fail 'cannot resolve committed HEAD tree'
      expected="committed $head $tree"
    else
      expected="staged $head $content"
    fi
    actual=$(read_receipt "$(receipt_path)")
    [[ "$actual" == "$expected" ]] || fail 'canonical receipt does not match the current HEAD and staged candidate'
    printf 'verification-receipt: canonical receipt matches %s\n' "$expected"
    ;;
  check-head)
    [[ $# == 1 ]] || fail 'check-head takes no additional arguments'
    head=$(git rev-parse HEAD) || fail 'cannot resolve HEAD'
    tree=$(git rev-parse 'HEAD^{tree}') || fail 'cannot resolve HEAD tree'
    actual=$(read_receipt "$(receipt_path)")
    [[ "$actual" == "committed $head $tree" ]] || fail 'canonical receipt does not match committed HEAD'
    printf 'verification-receipt: committed canonical receipt matches HEAD %s\n' "$head"
    ;;
  promote-post-commit)
    [[ $# == 1 ]] || fail 'promote-post-commit takes no additional arguments'
    git rev-parse 'HEAD^1' >/dev/null 2>&1 || fail 'HEAD has no first parent to promote from'
    head=$(git rev-parse HEAD)
    parent=$(git rev-parse 'HEAD^1')
    tree=$(git rev-parse 'HEAD^{tree}')
    content=$(commit_content_hash "$parent" "$head") || fail 'cannot hash the committed candidate'
    actual=$(read_receipt "$(receipt_path)")
    [[ "$actual" == "staged $parent $content" ]] || fail 'staged canonical receipt does not describe the new commit diff'
    write_receipt committed "$head" "$tree"
    printf 'verification-receipt: promoted canonical receipt to committed HEAD %s\n' "$head"
    ;;
  *)
    printf '%s\n' 'usage: tools/verification_receipt.sh {fingerprint|write-staged <fingerprint>|check-staged|check-head|promote-post-commit}' >&2
    exit 64
    ;;
esac
