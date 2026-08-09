#!/usr/bin/env bash
# Enforce ADR 0063 / README_POLICY.md: README is a bounded stable landing page.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/tools/project_data_env.sh"
linkedspec_project_data_enter_run "$ROOT/scripts/check_readme_stability.sh" "$@"
cd "$ROOT"

fail=0
note() { printf '[readme-stability] FAIL: %s\n' "$1" >&2; fail=1; }
ok() { printf '[readme-stability] ok:   %s\n' "$1"; }

index_mode=0
if ! git diff --cached --quiet --; then
  index_mode=1
fi

is_staged() {
  git diff --cached --name-only -- "$1" | grep -Fxq "$1"
}

stream_file() {
  if [[ "$index_mode" -eq 1 ]]; then
    git show ":$1"
  else
    cat "$ROOT/$1"
  fi
}

marker_value() {
  marker="$1"
  content="$2"
  tick='`'
  prefix="- ${marker}: ${tick}"
  count=0
  value=''
  while IFS= read -r line; do
    [[ "$line" == "$prefix"*"$tick" ]] || continue
    candidate="${line#"$prefix"}"
    candidate="${candidate%"$tick"}"
    [[ "$line" == "${prefix}${candidate}${tick}" && "$candidate" =~ ^[0-9]+$ ]] || continue
    count=$((count + 1))
    value="$candidate"
  done <<< "$content"
  [[ "$count" -eq 1 ]] || return 1
  printf '%s\n' "$value"
}

within_caps() {
  [[ "$1" -le "$3" && "$2" -le "$4" ]]
}

run_count_self_tests() {
  within_caps 128 6144 128 6144 || return 1
  within_caps 127 6143 128 6144 || return 1
  ! within_caps 129 6144 128 6144 || return 1
  ! within_caps 128 6145 128 6144 || return 1
  ! within_caps 129 6145 128 6144 || return 1
}

require_readme_text() {
  needle="$1"
  description="$2"
  if ! stream_file README.md | grep -Fq "$needle"; then
    note "README is missing ${description}: ${needle}"
  fi
}

new_adr_authorizes_caps() {
  old_line="$1"
  new_line="$2"
  old_byte="$3"
  new_byte="$4"
  staged_index="$(git show :docs/decisions/INDEX.md 2>/dev/null || true)"
  found=0

  while IFS= read -r adr; do
    [[ -n "$adr" ]] || continue
    body="$(git show ":$adr" 2>/dev/null || true)"
    base="${adr##*/}"
    if printf '%s\n' "$body" | grep -Fqx -- "- Previous README line cap: \`$old_line\`" &&
       printf '%s\n' "$body" | grep -Fqx -- "- New README line cap: \`$new_line\`" &&
       printf '%s\n' "$body" | grep -Fqx -- "- Previous README byte cap: \`$old_byte\`" &&
       printf '%s\n' "$body" | grep -Fqx -- "- New README byte cap: \`$new_byte\`" &&
       printf '%s\n' "$staged_index" | grep -Fq "(${base})"; then
      found=1
      break
    fi
  done < <(git diff --cached --name-only --diff-filter=A -- 'docs/decisions/*.md')

  [[ "$found" -eq 1 ]]
}

initial_adr_authorizes_caps() {
  new_line="$1"
  new_byte="$2"
  adr='docs/decisions/0063-bounded-readme-landing-page.md'
  [[ -f "$adr" ]] || return 1
  body="$(stream_file "$adr")"
  index="$(stream_file docs/decisions/INDEX.md)"
  printf '%s\n' "$body" | grep -Fqx -- '- Previous README line cap: `unbounded`' &&
    printf '%s\n' "$body" | grep -Fqx -- "- New README line cap: \`$new_line\`" &&
    printf '%s\n' "$body" | grep -Fqx -- '- Previous README byte cap: `unbounded`' &&
    printf '%s\n' "$body" | grep -Fqx -- "- New README byte cap: \`$new_byte\`" &&
    printf '%s\n' "$index" | grep -Fq '(0063-bounded-readme-landing-page.md)'
}

[[ -f README.md ]] || note 'README.md is missing'
[[ -f README_POLICY.md ]] || note 'README_POLICY.md is missing'
if ! perl "$ROOT/scripts/check_readme_routing_pressure.pl"; then
  note 'routed-destination closure or pressure control failed'
fi
if [[ "$fail" -ne 0 ]]; then exit 1; fi

run_count_self_tests || note 'internal cap-boundary self-tests failed'

policy="$(stream_file README_POLICY.md)"
if ! line_cap="$(marker_value 'Machine line cap' "$policy")"; then
  note 'README_POLICY.md must contain exactly one machine line-cap marker'
  line_cap=0
fi
if ! byte_cap="$(marker_value 'Machine byte cap' "$policy")"; then
  note 'README_POLICY.md must contain exactly one machine byte-cap marker'
  byte_cap=0
fi

read -r readme_lines readme_bytes < <(stream_file README.md | wc -l -c)
if within_caps "$readme_lines" "$readme_bytes" "$line_cap" "$byte_cap"; then
  ok "README.md is ${readme_lines}/${line_cap} lines and ${readme_bytes}/${byte_cap} bytes"
else
  note "README.md is ${readme_lines}/${line_cap} lines and ${readme_bytes}/${byte_cap} bytes; route changing detail per README_POLICY.md"
fi

for heading in \
  '# LinkedSpec' \
  '## Why LinkedSpec' \
  '## Quick start' \
  '## Architecture at a glance' \
  '## Documentation' \
  '## Repository layout' \
  '## Development and contribution' \
  '## Status and support' \
  '## License and notices'; do
  require_readme_text "$heading" "stable heading"
done

for link in \
  'README_POLICY.md' \
  'USER_GUIDE.md' \
  'docs/linkedspec-book/src/SUMMARY.md' \
  'ROADMAP.md' \
  'docs/TASK_TREE.md' \
  'TOOLBOX.md' \
  'COMMIT.md'; do
  require_readme_text "$link" "canonical navigation anchor"
done

for forbidden in \
  '## Current design frontier' \
  '## Repository relocation invariant' \
  '## Project data locality and same-volume storage' \
  '## Documentation Layers' \
  '## Project Objective' \
  '## Fast Ramp-Up Documentation Map' \
  '## Project File/Path Map' \
  '## Local CI' \
  '## Maintenance Policy for README' \
  '## Git Version-Control Status'; do
  if stream_file README.md | grep -Fxq "$forbidden"; then
    note "README reintroduces routed status/history/inventory heading: $forbidden"
  fi
done

if git cat-file -e HEAD:README_POLICY.md 2>/dev/null; then
  old_policy="$(git show HEAD:README_POLICY.md)"
  if ! old_line="$(marker_value 'Machine line cap' "$old_policy")" ||
     ! old_byte="$(marker_value 'Machine byte cap' "$old_policy")"; then
    note 'HEAD README_POLICY.md has invalid machine cap markers'
  elif [[ "$line_cap" -gt "$old_line" || "$byte_cap" -gt "$old_byte" ]]; then
    if new_adr_authorizes_caps "$old_line" "$line_cap" "$old_byte" "$byte_cap"; then
      ok "staged cap increase ${old_line}/${old_byte} -> ${line_cap}/${byte_cap} has a new indexed ADR"
    else
      note "cap increase ${old_line}/${old_byte} -> ${line_cap}/${byte_cap} requires a newly added, staged, indexed ADR with exact transition markers"
    fi
  fi
elif is_staged README_POLICY.md; then
  if initial_adr_authorizes_caps "$line_cap" "$byte_cap"; then
    ok 'initial README caps are authorized by accepted, indexed ADR 0063'
  else
    note 'initial README caps require accepted, indexed ADR 0063 with unbounded-to-cap transition markers'
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  printf '[readme-stability] README doctrine FAILED — keep README stable and route detail using README_POLICY.md\n' >&2
  exit 1
fi

ok 'cap self-tests, stable content, routed-heading exclusions, cap governance, and routing-pressure closure pass'
