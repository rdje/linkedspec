#!/usr/bin/env bash
# scripts/check_doctrines.sh — THE GENERAL DOCTRINE ENFORCER (driver + registry).
#
# DOCTRINE-ENFORCEMENT-ADOPT.2 (2026-06-22): adopt the portable Doctrine-Enforcement
# architecture (DOCTRINE_ENFORCEMENT.md — the 4th portable architecture, sibling of
# MEMORY_ARCHITECTURE.md + the Knowledge Map). This is the ONE driver that runs every
# mechanizable doctrine check, reports per-doctrine PASS/FAIL, and exits NONZERO on any
# breach. It formalizes the previously ad-hoc .githooks/pre-commit check stack into one
# registered, self-reporting framework.
#
# Enforcement layering (DOCTRINE_ENFORCEMENT.md §7 / MEMORY_ARCHITECTURE.md §9 — defense in depth):
#   E1 discovery   : README.md, TOOLBOX.md, DOCTRINE_ENFORCEMENT.md, docs/decisions/, the bootstrap pointers.
#   E2 self-check  : THIS script + each registered scripts/check_*.sh (single source of truth per doctrine).
#   E3 git hook    : .githooks/pre-commit calls this (fast local gate; activate via
#                    `git config core.hooksPath .githooks`). HONEST LIMIT: a local hook is
#                    bypassable (`--no-verify`, unset hooksPath) — it is not the backstop.
#   E4 CI          : tools/run_ci_local.sh runs the same driver. Hosted GitHub Actions is disabled
#                    (docs/decisions/0004) — the local CI gate is the source of truth, so the
#                    un-bypassable leg is only as strong as the next local-gate run.
#
# Check-script contract (DOCTRINE_ENFORCEMENT.md §4): each registered check is any executable that
# (1) exits 0 iff the doctrine holds, nonzero on breach; (2) explains breaches on stderr;
# (3) is deterministic; (4) reads the repo (a derive-and-stage step is allowed, must be idempotent);
# (5) is scope-aware where relevant; (6) resolves its own repo root; (7) is fast or CI-deferred.
#
# Registry below = the source of truth for "which doctrines are enforced by what". The
# human-readable mirror is DOCTRINE_ENFORCEMENT.md §10 (kept in lockstep). A meta-check asserts
# every registered enforcer exists + is executable, so a registry entry cannot be a dangling promise.
set -uo pipefail   # deliberately NOT `-e`: run ALL checks, collect every result, then report.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/project_data_env.sh" || exit 1
linkedspec_project_data_enter_run "$ROOT/scripts/check_doctrines.sh" "$@"
cd "$ROOT"

# Each entry: "ID|what it proves|relative/path/to/check.sh"
# Add a doctrine here AND a row in DOCTRINE_ENFORCEMENT.md §10.
DOCTRINES=(
  "MEMORY-ARCH|durable 4-layer memory architecture invariants (MEMORY_ARCHITECTURE.md §9)|scripts/check_memory_architecture.sh"
  "KNOWLEDGE-MAP|the derived Knowledge Map is in sync with its fact sources|knowledge-map/scripts/check_knowledge_map.sh"
  "TASK-TREE-METADATA|completed frontiers and pending-node activation/commit evidence stay status-consistent|scripts/check_task_tree_metadata.sh"
  "TASK-ACCEPTANCE|staged governed changes carry a task-tree acceptance checklist with LinkedSpec-tool evidence|scripts/check_diagnosis_evidence.sh"
  "REPO-ROOT-PATHS|tracked repository paths and all five primary-command roots are relocation-safe|scripts/check_repo_root_path_portability.sh"
  "PROJECT-DATA-STORAGE|tracked project-storage defaults and documented outputs stay repository-filesystem rooted|scripts/check_project_data_storage_locality.sh"
  "DOCUMENT-HISTORY|bounded current documentation views preserve exact repository-local queryable history|scripts/check_document_history.sh"
  "README-STABILITY|README and every routed destination retain reviewed resulting-tree pressure controls|scripts/check_readme_stability.sh"
)

fail=0
declare -a report=()

for entry in "${DOCTRINES[@]}"; do
  IFS='|' read -r id proves script <<< "$entry"
  if [ ! -x "$ROOT/$script" ]; then
    report+=("FAIL  ${id} — registered enforcer missing or not executable: ${script}")
    fail=1
    continue
  fi
  if out="$("$ROOT/$script" 2>&1)"; then
    report+=("PASS  ${id} — ${proves}")
  else
    report+=("FAIL  ${id} — ${proves}")
    printf '%s\n' "$out" >&2
    fail=1
  fi
done

printf '\n================ DOCTRINE ENFORCEMENT REPORT ================\n' >&2
for line in "${report[@]}"; do printf '  %s\n' "$line" >&2; done
printf '============================================================\n' >&2
if [ "$fail" -eq 0 ]; then
  printf 'doctrines: ALL %d enforced doctrines PASS.\n' "${#DOCTRINES[@]}" >&2
else
  printf 'doctrines: one or more doctrines FAILED — commit/merge blocked. Fix above; do not bypass.\n' >&2
fi
exit "$fail"
