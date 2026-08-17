#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)

source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_typed_gap_composition_six_runtime.sh" "$@"

log() {
 printf '[typed-gap-composition] %s\n' "$*"
}

cd -- "$REPO_ROOT"

log "checking the typed source-location composition contract"
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py

log "checking the complete neutral, six-runtime, recurring, and public gap authority"
bash tools/check_inter_match_gap_capture_six_runtime.sh

log "checking recognition ownership and the generated, capability, and language ledgers"
bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py
perl tools/check_generated_source_contract.pl
perl tools/check_capability_conformance.pl
perl tools/check_language_capability_coverage.pl

log "PASS: typed lossless-gap composition, all six gap runtimes, and support ledgers complete"
