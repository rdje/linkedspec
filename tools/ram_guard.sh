#!/usr/bin/env bash
# tools/ram_guard.sh — memory-guarded command wrapper
#
# Usage: ram_guard.sh [--ceiling-mb N] [--danger-pct N] -- <command...>
#
# Refuses to run if the host availability estimate reaches the configured threshold.
# Applies ulimit -v ceiling to the child process (macOS + Linux).
# Exits 77 (skip) if pre-check fails, propagates the command's exit code otherwise.
# This snapshot admission check does not monitor the running job or its trend.
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
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/host_ram_usage.sh"
if ! USED=$(linkedspec_host_ram_used_pct); then
  printf 'ram_guard: BAIL — host RAM usage unavailable; command was not started\n' >&2
  exit 77
fi
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
