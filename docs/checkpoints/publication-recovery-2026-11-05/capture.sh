#!/usr/bin/env bash
# One-shot read-only event acquisition; historical responses are never refreshed.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
out=docs/checkpoints/publication-recovery-2026-11-05
for name in acquired-at.txt github-status.json ssh-main.txt main-ref.json workflows.json; do
  test ! -e "$out/$name" || { printf 'refusing to overwrite %s\n' "$out/$name" >&2; exit 1; }
done
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$out/acquired-at.txt"
curl --fail --silent --show-error https://www.githubstatus.com/api/v2/summary.json > "$out/github-status.json"
git ls-remote --refs origin refs/heads/main > "$out/ssh-main.txt"
gh api repos/rdje/linkedspec/git/ref/heads/main > "$out/main-ref.json"
gh api repos/rdje/linkedspec/actions/workflows > "$out/workflows.json"
