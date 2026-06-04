#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)

cd "$REPO_ROOT"

log() {
 printf '[ci] %s\n' "$*"
}

fail() {
 printf '[ci] ERROR: %s\n' "$*" >&2
 exit 1
}

require_command() {
 command -v "$1" >/dev/null 2>&1 || fail "required command not found: $1"
}

require_tracked_file() {
 local path="$1"
 [[ -f "$path" ]] || fail "required file missing: $path"
 git ls-files --error-unmatch -- "$path" >/dev/null 2>&1 || fail "required file is not git-tracked: $path"
}

require_tracked_tree() {
 local path="$1"
 [[ -d "$path" ]] || fail "required directory missing: $path"
 if ! git ls-files -- "$path" | grep -q .; then
  fail "required directory has no git-tracked files: $path"
 fi
}

check_no_untracked_ci_inputs() {
 local status_line
 local found=0

 while IFS= read -r status_line; do
  [[ "$status_line" == '?? '* ]] || continue
  printf '[ci] ERROR: untracked CI input: %s\n' "${status_line#?? }" >&2
  found=1
 done < <(git status --short --untracked-files=all -- .github/workflows tools/run_ci_local.sh specs plugin conf tablescript ebnf perl t)

 (( found == 0 )) || exit 1
}

audit_no_machine_specific_absolute_paths() {
 local path
 local matches
 local found=0

 while IFS= read -r path; do
  [[ -f "$path" ]] || continue
  matches=$(grep -nE '/(Users|home)/[^[:space:]]*|[[:alpha:]]:\\\\' "$path" || true)
  if [[ -n "$matches" ]]; then
   printf '[ci] ERROR: machine-specific absolute path(s) in %s:\n%s\n' "$path" "$matches" >&2
   found=1
  fi
 done < <(git ls-files -- .github/workflows/ci.yml tools/run_ci_local.sh t/phase0_regression.t perl/LinkedSpec.pm perl/LinkedSpec)

 (( found == 0 )) || exit 1
}

log "repo root: $REPO_ROOT"
log "checking required commands"
require_command git
require_command perl
require_command prove

log "running memory-architecture self-check (MEMORY_ARCHITECTURE.md §9 — E2/E4 backstop)"
bash "$REPO_ROOT/scripts/check_memory_architecture.sh"

log "auditing git-tracked CI inputs"
require_tracked_file .github/workflows/ci.yml
require_tracked_file tools/run_ci_local.sh
require_tracked_file perl/LinkedSpec.pm
require_tracked_file t/phase0_regression.t
require_tracked_file scripts/check_memory_architecture.sh
require_tracked_file MEMORY_ARCHITECTURE.md
for path in specs plugin conf tablescript ebnf perl t; do
 require_tracked_tree "$path"
done
check_no_untracked_ci_inputs

log "auditing CI-local path usage"
audit_no_machine_specific_absolute_paths

log "running syntax checks"
perl -c perl/LinkedSpec.pm
perl -c -Iperl t/phase0_regression.t

log "running phase0 regression suite"
prove -v -Iperl t/phase0_regression.t

log "local CI gate passed"
