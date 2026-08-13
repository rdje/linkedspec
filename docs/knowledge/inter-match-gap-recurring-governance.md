---
id: inter-match-gap-recurring-governance
title: Inter-match gap recurrence is current governance over one complete neutral row and six pending runtime routes
answers:
  - "how do I run the inter match gap recurring gate"
  - "what does LINKEDSPEC_RUN_INTER_MATCH_GAP_MATRIX run"
  - "does the inter match gap recurring driver run backend tests yet"
  - "which inter match gap runtime routes are pending"
  - "why is inter match gap recurrence still pending when its driver exists"
  - "how is inter match gap project data kept on repository storage"
  - "what prevents capture_gaps public overclaim before implementation"
  - "which public surfaces are guarded for inter match gap capture"
  - "how many inter match gap mutations exist after recurring governance"
  - "what is the current inter match gap rollout"
date: 2026-08-13
status: current governance; rollout remains 1 complete + 8 pending with no runtime or public admission
tags: [capture, segmentation, recurring-gate, project-data, no-overclaim, local-ci, rollout]
evidence: "INTER-MATCH-GAP-CAPTURE.1.2 adds one repository-routed driver, canonical always-on neutral checking plus opt-in ordered governance, five topology/storage/public mutations, and exact outward-surface guards. Focused proof passes 55 rejected mutations, one neutral execution, six explicit pending skips, tool-storage locality, and outside-CWD routing. Perl .2.1 adds a dormant metadata/live/generated consumer behind 10 independent mutations; no runtime consumer executes canonically or recurrently."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py"
  - "bash tools/check_inter_match_gap_capture_six_runtime.sh"
  - "bash tools/test_project_data_workflow_routing.sh"
  - "bash tools/test_tool_project_data_storage.sh"
---

# Inter-match gap recurring governance

`tools/check_inter_match_gap_capture_six_runtime.sh` is the one ordered recurring driver. It derives
`REPO_ROOT` from its own path, enters `tools/project_data_env.sh`, and runs
`bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py` exactly once. Because only
`neutral_contract` is complete, it then reports—but does not invoke—the exact pending Perl, Rust, Dart, Julia,
PUC Lua, and LuaJIT consumer routes.

Perl now has a dormant final-path consumer whose metadata phase passes, while its live/generated gap phases fail
deliberately. Ten checker-local mutations keep that consumer out of this driver, canonical execution, and the
public facade until `.2.4`; therefore the six pending skips and neutral ledger do not move.

Canonical `tools/run_ci_local.sh` always executes the neutral checker. Setting
`LINKEDSPEC_RUN_INTER_MATCH_GAP_MATRIX=1` additionally invokes the ordered driver. This switch currently proves
route order and repository-volume storage, not backend support. Runtime admissions remain owned by
`INTER-MATCH-GAP-CAPTURE.2-.6`; `.7` alone can promote `recurring` and `public_no_drift` after all six runtime
proofs exist.

The format-1 contract fixes the neutral-plus-six route order, pending runtime statuses, storage initializer,
managed entrypoint, canonical switch, five exact documentation markers, and ten guarded outward
facade/schema/CLI/README paths. Those outward paths reject the planned `@capture_gaps`, `entry_slot`, `gap_span`,
`gap_text`, `gap_kind`, `Rule[name]`, and `name=/regex/` tokens until public admission. Five new reason-checked
corruptions bring current governance to 55 mutations while the rollout stays 1 complete + 8 pending.

Related: [[inter-match-gap-executable-contract-plan]], [[inter-match-gap-capture-origin-and-contract]],
[[lossless-gap-cross-tree-handoff]], and ADR `0045`.
