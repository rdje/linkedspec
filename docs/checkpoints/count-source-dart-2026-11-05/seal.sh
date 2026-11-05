#!/usr/bin/env bash
set -euo pipefail
source tools/project_data_env.sh
base=docs/checkpoints/count-source-dart-2026-11-05
while IFS= read -r -d '' path; do
 gzip -n -c "$path" > "$path.gz"
 gzip -cd "$path.gz" | cmp - "$path"
 rm -- "$path"
done < <(find "$base" -type f \( -name '*.log' -o -name '*.stdout' -o -name '*.stderr' -o -name '*.diff' -o -name '*-command.json' \) -print0)
