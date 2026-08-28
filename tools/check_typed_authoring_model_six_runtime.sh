#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/check_typed_authoring_model_six_runtime.sh" "$@"

log() {
 printf '[typed-authoring-model-six] %s\n' "$*"
}

cd -- "$REPO_ROOT"

log "checking the complete typed source-location value and projection authority"
bash "$REPO_ROOT/tools/check_typed_source_location_six_runtime.sh"

log "checking the complete recognition-transaction authority"
bash "$REPO_ROOT/tools/check_recognition_transaction_six_runtime.sh"

log "checking the complete recursive-observation authority"
bash "$REPO_ROOT/tools/check_recursive_observation_six_runtime.sh"

log "checking the complete typed lossless-gap composition"
bash "$REPO_ROOT/tools/check_typed_gap_composition_six_runtime.sh"

log "checking the complete progressive span-dispatch authority"
bash "$REPO_ROOT/tools/check_progressive_span_dispatch_six_runtime.sh"

log "checking the complete staged-AST enrichment authority"
bash "$REPO_ROOT/tools/check_staged_ast_enrichment_six_runtime.sh"

log "PASS: complete typed authoring model, all six recurring authorities, and public no-drift"
