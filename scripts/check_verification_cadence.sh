#!/usr/bin/env bash
# VERIFICATION-CADENCE: enforce explicit per-leaf tiers and canonical receipts.
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "$ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$ROOT/scripts/check_verification_cadence.sh" "$@"
cd "$ROOT"

fail() {
  printf 'verification-cadence: FAIL: %s\n' "$1" >&2
  exit 1
}

require_literal() {
  local file=$1
  local literal=$2
  [[ -f "$file" && ! -L "$file" ]] || fail "required policy owner is missing or symlinked: $file"
  grep -Fq -- "$literal" "$file" || fail "required policy marker is missing from $file: $literal"
}

is_canonical_path() {
  case "$1" in
    .github/workflows/*|.githooks/*|COMMIT.md|DOCTRINE_ENFORCEMENT.md|tools/run_ci_local.sh|tools/run_*_local.sh|scripts/check_doctrines.sh|scripts/check_memory_architecture.sh|scripts/check_task_tree_metadata.sh|scripts/check_diagnosis_evidence.sh|scripts/check_repo_root_path_portability.sh|scripts/check_project_data_storage_locality.sh|scripts/check_document_history.sh|scripts/check_readme_stability.sh|*/Cargo.lock|*/pubspec.lock|*/Manifest.toml|*/Project.toml)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

tier_action() {
  local tier=$1
  local canonical_required=$2
  local gate_in_progress=$3

  if [[ "$canonical_required" == 1 && "$tier" != canonical ]]; then
    return 1
  fi
  if [[ "$tier" == canonical && "$gate_in_progress" != 1 ]]; then
    printf '%s\n' receipt
  else
    printf '%s\n' no-receipt
  fi
}

self_test() {
  local path
  local -a canonical=(
    '.githooks/pre-push'
    'tools/run_ci_local.sh'
    'scripts/check_doctrines.sh'
    'COMMIT.md'
    'rust/Cargo.lock'
    'julia/Project.toml'
  )
  local -a focused=(
    'dart/lib/src/parser/spec_parser.dart'
    'rust/linkedspec-core/src/lib.rs'
    'perl/LinkedSpec.pm'
    'docs/linkedspec-book/src/user-model/regex-in-spec.md'
  )

  for path in "${canonical[@]}"; do
    is_canonical_path "$path" || fail "self-test misclassified canonical path: $path"
  done
  for path in "${focused[@]}"; do
    if is_canonical_path "$path"; then
      fail "self-test misclassified focused-eligible path: $path"
    fi
  done
  [[ "$(tier_action focused 0 0)" == no-receipt ]] || fail 'self-test rejected ordinary focused tier'
  if tier_action focused 1 0 >/dev/null; then
    fail 'self-test accepted focused tier for a canonical-required path'
  fi
  [[ "$(tier_action canonical 0 0)" == receipt ]] || fail 'self-test omitted ordinary canonical receipt'
  [[ "$(tier_action canonical 1 0)" == receipt ]] || fail 'self-test omitted required canonical receipt'
  [[ "$(tier_action canonical 1 1)" == no-receipt ]] || fail 'self-test did not allow in-progress canonical gate'
  printf 'verification-cadence: self-test OK (%d canonical + %d focused paths + 5 tier cases)\n' \
    "${#canonical[@]}" "${#focused[@]}"
}

if [[ "${1:-}" == '--self-test' ]]; then
  [[ $# == 1 ]] || fail '--self-test takes no additional arguments'
  self_test
  exit 0
fi
[[ $# == 0 ]] || fail 'unexpected arguments'

require_literal COMMIT.md '## Verification tiers (mandatory from atomic 235 onward)'
require_literal AGENTS.md 'Do not run the full gate automatically for every ordinary commit.'
require_literal docs/decisions/0073-tiered-verification-cadence.md '# ADR 0073: Verification is focused per ordinary commit and canonical at boundaries'
require_literal .githooks/pre-commit 'fast ordinary-commit enforcement boundary'
require_literal .githooks/pre-push 'tools/run_ci_local.sh'
require_literal .githooks/post-commit 'promote-post-commit'
require_literal tools/run_ci_local.sh 'LINKEDSPEC_CANONICAL_GATE_IN_PROGRESS=1'
require_literal tools/run_ci_local.sh 'write-staged'
require_literal docs/linkedspec-book/src/development/local-ci-and-regression.md '## Verification tiers'
require_literal docs/TASK_TREE.md 'Verification tier:'

if grep -v '^[[:space:]]*#' .githooks/pre-commit | grep -Fq 'tools/run_ci_local.sh'; then
  fail 'pre-commit must remain focused and must not invoke the canonical local CI gate'
fi
[[ -x tools/verification_receipt.sh ]] || fail 'tools/verification_receipt.sh is not executable'
[[ -x .githooks/pre-push ]] || fail '.githooks/pre-push is not executable'

mapfile -t staged_paths < <(git diff --cached --name-only --diff-filter=ACMRTD)
if [[ ${#staged_paths[@]} == 0 ]]; then
  printf 'verification-cadence: OK (structural policy; no staged slice)\n'
  exit 0
fi

task_files=()
canonical_required=0
for path in "${staged_paths[@]}"; do
  [[ "$path" == docs/tasks/*.md ]] && task_files+=("$path")
  is_canonical_path "$path" && canonical_required=1
done
[[ ${#task_files[@]} -gt 0 ]] || fail 'every staged slice requires its owning docs/tasks/*.md update'

tier_lines=()
focused_lines=0
trigger_lines=0
for path in "${task_files[@]}"; do
  while IFS= read -r tier; do
    [[ -n "$tier" ]] && tier_lines+=("$tier")
  done < <(git diff --cached --unified=0 -- "$path" |
    sed -n 's/^+[^+].*Verification tier: `\([^`]*\)`.*/\1/p')
  focused_lines=$((focused_lines + $(git diff --cached --unified=0 -- "$path" |
    grep -Ec '^\+[^+].*Focused checks:' || true)))
  trigger_lines=$((trigger_lines + $(git diff --cached --unified=0 -- "$path" |
    grep -Ec '^\+[^+].*Canonical trigger:' || true)))
done

[[ ${#tier_lines[@]} == 1 ]] || fail 'the staged owning leaf must add exactly one Verification tier: `focused` or `canonical` line'
tier=${tier_lines[0]}
[[ "$tier" == focused || "$tier" == canonical ]] || fail "unsupported verification tier: $tier"
[[ $focused_lines == 1 ]] || fail 'the staged owning leaf must add exactly one non-empty Focused checks: line'
[[ $trigger_lines == 1 ]] || fail 'the staged owning leaf must add exactly one Canonical trigger: line'

if ! action=$(tier_action "$tier" "$canonical_required" "${LINKEDSPEC_CANONICAL_GATE_IN_PROGRESS:-0}"); then
  fail 'the staged paths include CI/hook/doctrine/dependency infrastructure and require Verification tier: `canonical`'
fi

if [[ "$action" == receipt ]]; then
  "$ROOT/tools/verification_receipt.sh" check-staged >/dev/null ||
    fail 'canonical tier requires a successful receipt for the exact staged candidate'
fi

printf 'verification-cadence: OK (staged tier %s; canonical-path requirement %s)\n' \
  "$tier" "$canonical_required"
