---
id: rust-parity-followon-closed
title: RUST-PARITY is closed; interpreter oracle is full-corpus and generated-source corpus proof is curated
answers:
  - "is RUST-PARITY closed"
  - "what is the current Rust parity status"
  - "what is the next task after RUST-PARITY"
  - "is TOP-RULE-AS-NORMAL.3.2 unblocked"
  - "is TOP-RULE-AS-NORMAL.3.2 closed"
  - "does generated source cover all Rust oracle fixtures"
  - "what remains after Rust parity closeout"
date: 2026-07-08
status: accepted
tags: [rust, parity, oracle, source-emitter, task-tree, top-rule]
evidence: "RUST-PARITY.9 closed the Rust parity follow-on tree after RUST-PARITY.7 finalized the 88-fixture manifest-backed interpreter oracle, RUST-PARITY.8 closed generated-source direct execution for all current structural families, and RUST-PARITY.8.5 added the curated 8-case manifest-backed generated-source subset. That closeout unblocked TOP-RULE-AS-NORMAL.3.2. TOP-RULE-AS-NORMAL.3.2 has since closed: Rust declare type-token resolution and per-rule declared-variable scoping fixed recursive top/body value parity, raising the interpreter oracle to 91 fixtures. Later terse-language leaves raised the checked-in interpreter oracle manifest to 96 fixtures; generated-source corpus validation remains the curated subset, not the full manifest. TRACE-OBSERVABILITY has since closed through .4.5, so no trace frontier remains."
reverify: "rg -n 'RUST-PARITY.9|TOP-RULE-AS-NORMAL.3.2|96 fixtures|generated-source corpus proof|TRACE-OBSERVABILITY.4.5|curated' ROADMAP_V2.md docs/TASK_TREE.md docs/tasks/RUST-PARITY.md docs/tasks/TOP-RULE-AS-NORMAL.md docs/tasks/TRACE-OBSERVABILITY.md MEMORY.md LIVE_ACHIEVEMENT_STATUS.md docs/linkedspec-book/src/appendix/backend-handoff.md docs/linkedspec-book/src/overview/project-status.md && rg -n '\"case_count\" : 96' rust/linkedspec-runtime/tests/corpus/manifest.json"
---

# Rust Parity Follow-On Closed

`RUST-PARITY` is closed as of `RUST-PARITY.9`.

Current Rust state:

- interpreter parity is guarded by the checked-in 96-fixture oracle corpus plus
  missing/stale fixture drift guards;
- generated source directly executes every currently supported structural
  family: default, OR/AND acode, AND/OR bcode, and the four explicit REP
  subfamilies;
- generated-source corpus validation is a curated 8-case manifest subset, not
  all 96 fixtures.

`TOP-RULE-AS-NORMAL.3.2` was the next leaf after `RUST-PARITY.9`; it is now
closed under the top-rule task tree. `TRACE-OBSERVABILITY` has since closed through `.4.5`, so no trace frontier
remains.
