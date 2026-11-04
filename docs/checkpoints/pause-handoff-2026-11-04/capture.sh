#!/usr/bin/env bash
# Explicit read-only operational acquisition; historical outputs are not refreshed on replay.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
out=docs/checkpoints/pause-handoff-2026-11-04
for name in github-status.json main-ref.json repository.json workflows.json; do
  test ! -e "$out/$name" || { printf 'refusing to overwrite %s\n' "$out/$name" >&2; exit 1; }
done
curl --fail --silent --show-error https://www.githubstatus.com/api/v2/summary.json > "$out/github-status.json"
gh api repos/rdje/linkedspec/git/ref/heads/main > "$out/main-ref.json"
gh api repos/rdje/linkedspec --jq '{full_name,size,archived,disabled,default_branch,pushed_at}' > "$out/repository.json"
gh api repos/rdje/linkedspec/actions/workflows > "$out/workflows.json"
