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
 done < <(git status --short --untracked-files=all -- .github/workflows tools/run_ci_local.sh specs conf tablescript ebnf perl t)

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

log "running the general doctrine enforcer (DOCTRINE_ENFORCEMENT.md §5/§7 — E4 backstop): the registry driver runs every registered check (memory-architecture, Knowledge Map, ...)"
bash "$REPO_ROOT/scripts/check_doctrines.sh"

log "auditing git-tracked CI inputs"
require_tracked_file .github/workflows/ci.yml
require_tracked_file tools/run_ci_local.sh
require_tracked_file perl/LinkedSpec.pm
require_tracked_file t/phase0_regression.t
require_tracked_file scripts/check_memory_architecture.sh
require_tracked_file scripts/check_doctrines.sh
require_tracked_file scripts/check_diagnosis_evidence.sh
require_tracked_file DOCTRINE_ENFORCEMENT.md
require_tracked_file TOOLBOX.md
require_tracked_file MEMORY_ARCHITECTURE.md
require_tracked_file KNOWLEDGE_MAP.md
require_tracked_file knowledge-map/scripts/gen_knowledge_map.sh
require_tracked_file knowledge-map/scripts/check_knowledge_map.sh
# NOTE: 'plugin' is intentionally NOT required here — NONCORE-QUARANTINE.3 git mv'd the 13 .plg to
# noncore/plugin/ and removed the top-level plugin/ dir. The core gate stays core-only and does not reach
# into noncore/ (same core-only precedent as PHASE0-BACKHALF-TRIAGE.5.1/.5.4). (PHASE0-BACKHALF-TRIAGE.5.3.1)
for path in specs conf tablescript ebnf perl t; do
 require_tracked_tree "$path"
done
check_no_untracked_ci_inputs

log "auditing CI-local path usage"
audit_no_machine_specific_absolute_paths

log "running syntax checks"
perl -c perl/LinkedSpec.pm
perl -c -Iperl t/actionir_ast_parser.t
perl -c -Iperl t/phase0_regression.t

log "running ActionIR AST parser focused suite"
prove -Iperl t/actionir_ast_parser.t

# Memory guard — bail if system RAM is critically low before running the heavy suite
_ram_used_pct() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    local page_size free_pages inactive_pages speculative_pages total_ram avail_pages
    page_size=$(pagesize 2>/dev/null || echo 16384)
    free_pages=$(vm_stat 2>/dev/null | awk '/Pages free/               {print $NF}' | tr -d '.')
    inactive_pages=$(vm_stat 2>/dev/null | awk '/Pages inactive/         {print $NF}' | tr -d '.')
    speculative_pages=$(vm_stat 2>/dev/null | awk '/Pages speculative/    {print $NF}' | tr -d '.')
    avail_pages=$(( ${free_pages:-0} + ${inactive_pages:-0} + ${speculative_pages:-0} ))
    total_ram=$(sysctl -n hw.memsize 2>/dev/null || echo 17179869184)
    echo $(( 100 - (avail_pages * page_size * 100 / total_ram) ))
  else
    awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%d", 100-(a*100/t)}' /proc/meminfo 2>/dev/null || echo 0
  fi
}
GUARD_PCT=$(_ram_used_pct)
DANGER_PCT="${LINKEDSPEC_TEST_DANGER_PCT:-88}"
if [[ "${GUARD_PCT}" -ge "${DANGER_PCT}" ]]; then
  fail "RAM ${GUARD_PCT}% used (danger threshold ${DANGER_PCT}%) — refusing to run heavy suite. Free RAM and retry, or set LINKEDSPEC_TEST_DANGER_PCT higher."
fi
log "RAM ${GUARD_PCT}% used — within threshold (${DANGER_PCT}%)"

log "running phase0 regression suite"
prove -v -Iperl t/phase0_regression.t

if [[ "${LINKEDSPEC_RUN_DART:-0}" == "1" ]]; then
 log "running optional Dart local gate (LINKEDSPEC_RUN_DART=1)"
 require_tracked_file tools/run_dart_local.sh
 bash "$REPO_ROOT/tools/run_dart_local.sh"
else
 log "skipping optional Dart local gate (set LINKEDSPEC_RUN_DART=1 to include it when a Dart SDK is available)"
fi

log "local CI gate passed"
