#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd -P)
source "$REPO_ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$REPO_ROOT/tools/run_mdbook_local.sh" "$@"

fail() {
 printf '[mdbook] ERROR: %s\n' "$*" >&2
 exit 1
}

BOOK_ROOT="$REPO_ROOT/docs/linkedspec-book"
destinations=()
[[ -z "${MDBOOK_BUILD__BUILD_DIR:-}" ]] || destinations+=("$MDBOOK_BUILD__BUILD_DIR")

arguments=("$@")
for (( index=0; index < ${#arguments[@]}; index++ )); do
 case "${arguments[index]}" in
  -d|--dest-dir)
   (( index + 1 < ${#arguments[@]} )) || fail "${arguments[index]} requires a destination"
   (( index += 1 ))
   destinations+=("${arguments[index]}")
   ;;
  --dest-dir=*) destinations+=("${arguments[index]#*=}") ;;
  -d?*) destinations+=("${arguments[index]#-d}") ;;
 esac
done
(( ${#destinations[@]} > 0 )) || destinations+=(book)

OUTPUT_PATH=''
for destination in "${destinations[@]}"; do
 [[ -n "$destination" ]] || fail 'mdBook destination must not be empty'
 case "$destination" in
  /*) OUTPUT_PATH=$destination ;;
  *) OUTPUT_PATH="$BOOK_ROOT/$destination" ;;
 esac
 linkedspec_project_data_validate_output_path "$OUTPUT_PATH" 'mdBook output' || exit 1
done

MDBOOK_CMD=${LINKEDSPEC_MDBOOK_CMD:-mdbook}
command -v "$MDBOOK_CMD" >/dev/null 2>&1 || {
 fail "required command not found: $MDBOOK_CMD"
}

cd "$REPO_ROOT"
printf '%s\n' '[mdbook] building LinkedSpec book with repo-local project data'
"$MDBOOK_CMD" build docs/linkedspec-book "$@"
[[ -d "$OUTPUT_PATH" && ! -L "$OUTPUT_PATH" ]] || fail "mdBook did not create a real output directory: $OUTPUT_PATH"
linkedspec_project_data_validate_output_path "$OUTPUT_PATH" 'mdBook output'
