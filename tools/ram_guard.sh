#!/usr/bin/env bash
# tools/ram_guard.sh — memory-guarded command wrapper
#
# Usage: ram_guard.sh [--ceiling-mb N] [--danger-pct N] -- <command...>
#
# Refuses to run if system RAM usage exceeds the danger threshold.
# Applies ulimit -v ceiling to the child process (macOS + Linux).
# Exits 77 (skip) if pre-check fails, propagates the command's exit code otherwise.
#
# Examples:
#   ram_guard.sh -- prove -Iperl t/phase0_regression.t
#   ram_guard.sh --ceiling-mb 4096 -- perl -Iperl -e '...'
#   LINKEDSPEC_DANGER_PCT=90 ram_guard.sh -- make test
set -euo pipefail

# --- config ---------------------------------------------------------
CEILING_MB=8192                           # ulimit -v ceiling (MB)
DANGER_PCT="${LINKEDSPEC_DANGER_PCT:-88}" # bail if RAM usage >= this %

# --- parse args -----------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --ceiling-mb) CEILING_MB="$2"; shift 2 ;;
    --danger-pct) DANGER_PCT="$2"; shift 2 ;;
    --) shift; break ;;
    *)  break ;;
  esac
done

[[ $# -ge 1 ]] || { echo "usage: ram_guard.sh [opts] -- <command...>" >&2; exit 2; }

# --- detect RAM usage -----------------------------------------------
_used_pct() {
  if [[ "$(uname -s)" == "Darwin" ]]; then
    local ps="${1:-16384}"
    local fp=$(vm_stat 2>/dev/null | awk '/Pages free/        {print $NF}' | tr -d '.')
    local ip=$(vm_stat 2>/dev/null | awk '/Pages inactive/     {print $NF}' | tr -d '.')
    local sp=$(vm_stat 2>/dev/null | awk '/Pages speculative/  {print $NF}' | tr -d '.')
    local tr=$(sysctl -n hw.memsize 2>/dev/null || echo 17179869184)
    echo $(( 100 - ( (${fp:-0}+${ip:-0}+${sp:-0}) * ps * 100 / tr ) ))
  else
    awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%d",100-(a*100/t)}' /proc/meminfo 2>/dev/null || echo 0
  fi
}

USED=$(_used_pct "$(pagesize 2>/dev/null || echo 16384)")
if [[ "${USED}" -ge "${DANGER_PCT}" ]]; then
  echo "ram_guard: BAIL — RAM ${USED}% used >= danger ${DANGER_PCT}%" >&2
  exit 77
fi
echo "ram_guard: RAM ${USED}% used (ok < ${DANGER_PCT}%), ceiling ${CEILING_MB} MB"

# --- apply ceiling and run ------------------------------------------
if [[ "$(uname -s)" == "Darwin" ]]; then
  ulimit -v $(( CEILING_MB * 1024 )) 2>/dev/null || true
else
  ulimit -v $(( CEILING_MB * 1024 )) 2>/dev/null || true
fi

exec "$@"
