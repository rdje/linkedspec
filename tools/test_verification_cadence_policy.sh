#!/usr/bin/env bash
# Focused deterministic checks for tier classification and canonical receipt integrity.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"
source "$ROOT/tools/project_data_env.sh"
cd "$ROOT"

TEST_ROOT="$LINKEDSPEC_PROJECT_DATA_ROOT/verification/test-verification-cadence"
RECEIPT="$TEST_ROOT/canonical-v1.receipt"
export LINKEDSPEC_VERIFICATION_RECEIPT_PATH="$RECEIPT"

cleanup() {
  [[ "$TEST_ROOT" == "$LINKEDSPEC_PROJECT_DATA_ROOT/verification/test-verification-cadence" ]] || return 1
  rm -rf -- "$TEST_ROOT"
}
trap cleanup EXIT
cleanup
mkdir -p -- "$TEST_ROOT"

expect_failure() {
  local label=$1
  shift
  if "$@" >/dev/null 2>&1; then
    printf 'verification-cadence-test: expected failure: %s\n' "$label" >&2
    exit 1
  fi
}

bash "$ROOT/scripts/check_verification_cadence.sh" --self-test
fingerprint=$(bash "$ROOT/tools/verification_receipt.sh" fingerprint)
read -r head content <<< "$fingerprint"

expect_failure missing bash "$ROOT/tools/verification_receipt.sh" check-staged
bash "$ROOT/tools/verification_receipt.sh" write-staged "$fingerprint" >/dev/null
bash "$ROOT/tools/verification_receipt.sh" check-staged >/dev/null

printf 'version=2\nstate=staged\nhead=%s\ncontent=%s\ngate=tools/run_ci_local.sh\n' "$head" "$content" > "$RECEIPT"
expect_failure wrong-version bash "$ROOT/tools/verification_receipt.sh" check-staged
printf 'version=1\nstate=staged\nhead=%040d\ncontent=%s\ngate=tools/run_ci_local.sh\n' 0 "$content" > "$RECEIPT"
expect_failure wrong-head bash "$ROOT/tools/verification_receipt.sh" check-staged
printf 'version=1\nstate=staged\nhead=%s\ncontent=%064d\ngate=tools/run_ci_local.sh\n' "$head" 0 > "$RECEIPT"
expect_failure wrong-content bash "$ROOT/tools/verification_receipt.sh" check-staged
printf 'version=1\nstate=staged\nhead=%s\ncontent=%s\ngate=other\n' "$head" "$content" > "$RECEIPT"
expect_failure wrong-gate bash "$ROOT/tools/verification_receipt.sh" check-staged
printf 'version=1\nstate=staged\nhead=%s\ncontent=%s\n' "$head" "$content" > "$RECEIPT"
expect_failure short-receipt bash "$ROOT/tools/verification_receipt.sh" check-staged

head_tree=$(git rev-parse 'HEAD^{tree}')
printf 'version=1\nstate=committed\nhead=%s\ncontent=%s\ngate=tools/run_ci_local.sh\n' "$head" "$head_tree" > "$RECEIPT"
bash "$ROOT/tools/verification_receipt.sh" check-head >/dev/null
printf 'version=1\nstate=staged\nhead=%s\ncontent=%s\ngate=tools/run_ci_local.sh\n' "$head" "$content" > "$RECEIPT"
expect_failure staged-is-not-head bash "$ROOT/tools/verification_receipt.sh" check-head

bash "$ROOT/tools/verification_receipt.sh" write-staged "$fingerprint" >/dev/null
bash "$ROOT/tools/verification_receipt.sh" check-staged >/dev/null
printf 'verification-cadence-test: PASS (10 path + 5 tier + 9 receipt cases)\n'
