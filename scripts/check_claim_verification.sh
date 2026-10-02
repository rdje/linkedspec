#!/usr/bin/env bash
# CLAIM-VERIFICATION: recorded legs and tracked, hash-bound claim inputs.
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
source "$ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$ROOT/scripts/check_claim_verification.sh" "$@"
cd "$ROOT"
exec bash tools/run_python_project_data.sh tools/check_claim_verification.py "$@"
