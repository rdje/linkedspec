---
id: rust-parity-followon-closed
title: RUST-PARITY is closed; interpreter oracle is full-corpus and generated-source corpus proof is curated
answers:
  - "is RUST-PARITY closed"
  - "what is the current Rust parity status"
  - "what is the next task after RUST-PARITY"
  - "is TOP-RULE-AS-NORMAL.3.2 unblocked"
  - "does generated source cover all Rust oracle fixtures"
  - "what remains after Rust parity closeout"
date: 2026-07-04
status: accepted
tags: [rust, parity, oracle, source-emitter, task-tree, top-rule]
evidence: "RUST-PARITY.9 closed the Rust parity follow-on tree after RUST-PARITY.7 finalized the 88-fixture manifest-backed interpreter oracle, RUST-PARITY.8 closed generated-source direct execution for all current structural families, and RUST-PARITY.8.5 added the curated 8-case manifest-backed generated-source subset. ROADMAP_V2.md, docs/TASK_TREE.md, docs/tasks/RUST-PARITY.md, ARCHITECTURE_STATE.md, MEMORY.md, LIVE_ACHIEVEMENT_STATUS.md, rust/README.md, and the mdBook backend handoff record the same boundary. TOP-RULE-AS-NORMAL.3.2 is now the next PNT leaf because its RUST-PARITY recursive-grammar blocker is cleared."
reverify: "rg -n 'RUST-PARITY.9|TOP-RULE-AS-NORMAL.3.2|88 manifest|generated-source corpus proof|curated' ROADMAP_V2.md docs/TASK_TREE.md docs/tasks/RUST-PARITY.md ARCHITECTURE_STATE.md MEMORY.md LIVE_ACHIEVEMENT_STATUS.md docs/linkedspec-book/src/appendix/backend-handoff.md"
---

# Rust Parity Follow-On Closed

`RUST-PARITY` is closed as of `RUST-PARITY.9`.

Current Rust state:

- interpreter parity is guarded by the checked-in 88-fixture oracle corpus plus
  missing/stale fixture drift guards;
- generated source directly executes every currently supported structural
  family: default, OR/AND acode, AND/OR bcode, and the four explicit REP
  subfamilies;
- generated-source corpus validation is a curated 8-case manifest subset, not
  all 88 fixtures.

The next PNT leaf is `TOP-RULE-AS-NORMAL.3.2`, because its recursive-grammar
Rust blocker was cleared by the closed Rust parity work. Do not reopen
`RUST-PARITY` for that top-rule value-parity work; it is owned by the
top-rule task tree.
