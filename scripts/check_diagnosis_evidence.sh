#!/usr/bin/env bash
# scripts/check_diagnosis_evidence.sh — TASK-ACCEPTANCE evidence-shape gate.
#
# Scope: staged code/spec/test/tooling changes must stage an owning task-tree file
# with the TOOLBOX.md task-acceptance checklist filled in with LinkedSpec-tool
# evidence. This is intentionally a presence/signature check. The expensive
# oracle leg remains the focused validation commands and tools/run_ci_local.sh.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$ROOT/scripts/check_diagnosis_evidence.sh" "$@"
cd "$ROOT"

fail() {
  printf 'task-acceptance: FAIL: %s\n' "$1" >&2
  exit 1
}

is_governed_path() {
  case "$1" in
    .github/workflows/*|.githooks/*|bin/*|perl/*|rust/*|specs/*|t/*|tools/*|scripts/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_task_file() {
  case "$1" in
    docs/tasks/*.md) return 0 ;;
    *) return 1 ;;
  esac
}

mapfile -t staged_paths < <(git diff --cached --name-only --diff-filter=ACMRTD)

governed_paths=()
task_files=()
for path in "${staged_paths[@]}"; do
  if is_governed_path "$path"; then
    governed_paths+=("$path")
  fi
  if is_task_file "$path"; then
    task_files+=("$path")
  fi
done

if [[ "${#governed_paths[@]}" -eq 0 ]]; then
  printf 'task-acceptance: OK (no staged governed code/spec/test/tooling changes)\n'
  exit 0
fi

if [[ "${#task_files[@]}" -eq 0 ]]; then
  {
    printf 'task-acceptance: staged governed changes require an owning docs/tasks/*.md update with a TOOLBOX.md acceptance checklist\n'
    printf 'task-acceptance: governed staged paths:\n'
    printf '  %s\n' "${governed_paths[@]}"
  } >&2
  exit 1
fi

required_labels=(
  "REPRODUCE / ISSUE"
  "ROOT CAUSE (WHY + WHERE)"
  "FIX"
  "ADDRESSED (verified)"
  "NO REGRESSION"
  "LOCKSTEP"
)

tool_signature_re='(LinkedSpec::Get|LinkedSpec::get_parser|return_descriptor|dump_parser_source|parser_source_ref|parse_only|generate_only|return_state|runtime_ctx_ref|call_spec_handler_subst|LINKEDSPEC_TRACE_LEVEL|bin/linkedspec|tools/(inspect_spec_codegen|cross_check_spec_parsers|gen_oracle_corpus)\.pl|scripts/check_(doctrines|memory_architecture|task_tree_metadata|diagnosis_evidence|repo_root_path_portability)\.sh|knowledge-map/scripts/check_knowledge_map\.sh|perl -Iperl|prove -[A-Za-z0-9 -]*Iperl|cargo test|mdbook build|git diff --check|rg -n)'
why_where_re='(WHY|WHERE|root cause|mechanism|source location|file:line|[A-Za-z0-9_./-]+:[0-9]+|last_error|generated-source|generated source|descriptor|staged set|staged task file|tool-backed)'
verification_re='(PASS|FAIL->PASS|REJECT->PASS|exit 0|0 failures|new failures.*empty|comm -13|comm -23|git diff --check|mdbook build|prove|cargo test|bash scripts/check_doctrines\.sh|bash tools/run_ci_local\.sh|checks pass|Result: PASS|clean)'

task_has_complete_checklist() {
  local file="$1"
  local text
  text="$(git show ":$file" 2>/dev/null || true)"
  [[ -n "$text" ]] || return 1

  grep -Fq 'Acceptance Checklist' <<< "$text" || return 1

  local label
  local label_lines
  for label in "${required_labels[@]}"; do
    if ! grep -Fq -- "- [x] **$label**" <<< "$text" && ! grep -Fq -- "- [X] **$label**" <<< "$text"; then
      return 1
    fi
    label_lines="$(grep -F -- "**$label**" <<< "$text" || true)"
    if grep -Eq '<[^>]+>|TODO|TBD|pending' <<< "$label_lines"; then
      return 1
    fi
  done

  grep -Eq "$tool_signature_re" <<< "$text" || return 1
  grep -Eq "$why_where_re" <<< "$text" || return 1
  grep -Eq "$verification_re" <<< "$text" || return 1

  return 0
}

for task_file in "${task_files[@]}"; do
  if task_has_complete_checklist "$task_file"; then
    printf 'task-acceptance: OK (%s carries a complete tool-evidence checklist)\n' "$task_file"
    exit 0
  fi
done

{
  printf 'task-acceptance: governed staged changes need one staged docs/tasks/*.md file with a completed TOOLBOX.md acceptance checklist\n'
  printf 'task-acceptance: required checked labels:\n'
  printf '  - [x] **%s**\n' "${required_labels[@]}"
  printf 'task-acceptance: staged task files inspected:\n'
  printf '  %s\n' "${task_files[@]}"
  printf 'task-acceptance: governed staged paths:\n'
  printf '  %s\n' "${governed_paths[@]}"
} >&2
exit 1
