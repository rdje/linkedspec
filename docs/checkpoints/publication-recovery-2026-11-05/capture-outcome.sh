#!/usr/bin/env bash
# One-shot operational outcome acquisition; never refresh these historical events.
set -euo pipefail
root=$(git rev-parse --show-toplevel)
cd "$root"
out=docs/checkpoints/publication-recovery-2026-11-05
for name in published-at.txt local-origin-refs.txt published-ssh-main.txt published-main-ref.json published-head-runs.json published-github-status.json canonical-4683555e.receipt canonical-4683555e.log.gz push-4683555e.log.gz; do
  test ! -e "$out/$name" || { printf 'refusing to overwrite %s\n' "$out/$name" >&2; exit 1; }
done
head=$(git rev-parse HEAD)
test "$head" = 4683555ec51f04b8977812ce4e984c5cc6e6f42c
bash tools/verification_receipt.sh check-head
date -u '+%Y-%m-%dT%H:%M:%SZ' > "$out/published-at.txt"
git rev-parse HEAD refs/remotes/origin/main > "$out/local-origin-refs.txt"
git ls-remote --refs origin refs/heads/main > "$out/published-ssh-main.txt"
gh api repos/rdje/linkedspec/git/ref/heads/main > "$out/published-main-ref.json"
gh api "repos/rdje/linkedspec/actions/runs?head_sha=$head&per_page=20" --jq '{total_count,workflow_runs:[.workflow_runs[]|{id,status,conclusion,head_sha,html_url}]}' > "$out/published-head-runs.json"
curl --fail --silent --show-error https://www.githubstatus.com/api/v2/summary.json > "$out/published-github-status.json"
cp .linkedspec-data/verification/canonical-v1.receipt "$out/canonical-4683555e.receipt"
gzip -c .linkedspec-data/logs/publication-recovery-canonical-4683555e.log > "$out/canonical-4683555e.log.gz"
gzip -c .linkedspec-data/logs/publication-recovery-push-4683555e.log > "$out/push-4683555e.log.gz"
