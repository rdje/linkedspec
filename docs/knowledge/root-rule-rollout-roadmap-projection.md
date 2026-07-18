---
id: root-rule-rollout-roadmap-projection
title: "Root-selection roadmap prose drifted because recurring governance did not require either roadmap"
answers:
  - "why did ROADMAP.md still say root selection was 1 of 7"
  - "why did ROADMAP_V2.md still say root selection was 1 of 7"
  - "does the root rule selection checker verify roadmap status"
  - "which task repairs root selection roadmap drift"
  - "which task will make root selection roadmap checks mechanical"
  - "how can root governance pass while roadmap status is stale"
date: 2026-07-18
status: prose repaired in Julia preflight; mechanical enforcement assigned to final no-drift leaf
tags: [roadmap, governance, root-rule, documentation-drift, task-tree, FUTURE-PARITY-BACKLOG]
evidence: "During FUTURE-PARITY-BACKLOG.9.1.1.2.4.0, ROADMAP.md and ROADMAP_V2.md both reported the neutral commit's 1/7 rollout even though the task tree, README, mdBook, capability contract, Knowledge Map, and clean Dart admission commit 31cc78ae reported 4/7. git log/blame show both root-selection roadmap paragraphs were last changed by neutral commit 7abbc593 and were untouched by Perl, Rust, or Dart admission. tools/check_root_rule_selection_contract.py passes 34 mutations but its required tracked/current-state inputs do not include either roadmap. The behavior-free Julia preflight repairs both projections to 4/7 and active Julia .4.0. Final public no-drift leaf .9.1.1.2.6 now explicitly owns making ROADMAP.md and ROADMAP_V2.md required current-state checker inputs so the same omission cannot recur."
reverify: "git log --oneline -- ROADMAP.md ROADMAP_V2.md && git blame -L 6,11 ROADMAP.md && git blame -L 4,11 ROADMAP_V2.md && rg -n 'ROADMAP|required_tracked_file|require_tracked_file' tools/check_root_rule_selection_contract.py capability_conformance/root_rule_selection_contract.json docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

# Root-selection roadmap projection gap

The root checker correctly guarded executable semantics, admission topology, source inventory, shared primary
case identity, rollout rows, and canonical driver registration. It did not guard the two roadmap summaries. Later
backend admissions updated the stronger task/capability/book/live owners but never touched either roadmap, so a
green checker could coexist with stale 1/7 prose.

The immediate repair belongs to the active behavior-free preflight because roadmap/code/book lockstep is part of
its closeout. Mechanical prevention belongs to final public no-drift, where all five consumers and every public
projection are already composed.

Related: [[root-rule-selection-precedence]] and [[julia-root-rule-selection-preflight]].
