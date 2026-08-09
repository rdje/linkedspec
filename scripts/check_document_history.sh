#!/usr/bin/env bash
# Enforce ADR 0066: exact repository-local history over bounded current documentation views.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$ROOT/scripts/check_document_history.sh" "$@"
cd "$ROOT"

perl scripts/check_document_history.pl --self-test
perl scripts/check_document_history.pl
