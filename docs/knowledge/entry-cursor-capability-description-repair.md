---
id: entry-cursor-capability-description-repair
title: Stable entry/cursor capability identity describes intrinsic policy and rejects removed overrides
answers:
  - "does runtime top rule and parse mode controls advertise a supported global option"
  - "how is the stale parse mode capability description guarded"
  - "why did finite gap documentation fail the cursor inventory"
  - "why is the current cursor migration inventory 79 files"
date: 2026-10-01
status: stale description and two missing inventory registrations repaired; canonical acceptance required
tags: [capability, cursor, root-selection, regression, migration-inventory]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.5 retains runtime.top_rule_and_parse_mode_controls and all census IDs/states, corrects its prose/sources, and adds fifteen reason-sensitive mutations. The old checker accepts the historical contradiction; the new checker rejects it for the exact contract-authority reason. The .1.1.4 architecture paragraph and new checker each match the existing cursor token census and require registration, moving77->79 without semantic/rollout movement."
reverify: "env PERL5LIB= bash tools/project_data_run.sh perl tools/check_capability_conformance.pl && bash tools/run_python_project_data.sh tools/check_rule_local_cursor_contract.py && bash tools/run_python_project_data.sh tools/check_root_rule_selection_contract.py"
---

The general checker previously required only nonempty contract prose for this row.
Its old description accepted global controls removed by the specific cursor contract.
The corrected stable row selects explicit root, then first authored marker/rule;
AND consumes, OR/default seeks and every child owns its policy. Public/global
overrides are removed. Preserving the historical ID avoids inventing a new capability.

`tools/check_capability_conformance.pl` now checks exact category/prose/sources and
the relevant root/cursor authority identities, precedence and policy fields.
Fifteen in-memory mutations cover historical/ignored override claims, missing or
renamed row, category/source drift, authority identities, precedence and four cursor
policies. Each must fail for its exact expected reason, not merely some error.
An unrelated-error control also falsifies the reason assertion on every run.
The original twenty capabilities and100/0/0 states remain unchanged; runtime,
generated formats, full authority semantics and backend admission do not move.

The cursor check correctly caught an omitted documentation registration introduced
by `.1.1.4`: its new architecture paragraph contains the scanned `parse-mode` token.
The newly guarded capability check also introduces the scanned stable identifier.
Both paths are added to the existing public/neutral migration groups, with current
census mirrors at79/8/0/60. The original omission mutation recurs. Earlier dated
measurements retain their counts. The stable task-index marker verifier is also a
current census mirror; update it with the marker while preserving sentinel placement
and all anchor mutations. [[task-index-marker-anchor-hazard]] owns that dependency.
This is documentation/governance repair, not a
cursor runtime defect. Startup `.41.2` still owns broader guide reconciliation.

[[finite-language-readiness-gap-selection]] supplies the next closure/neutral/audit
requirements; no successful finite probe selects a new missing parsing primitive.
