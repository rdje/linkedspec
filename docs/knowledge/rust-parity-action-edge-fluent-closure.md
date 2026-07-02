---
id: rust-parity-action-edge-fluent-closure
title: "RUST-PARITY.7.5.3 is closed by the later SPEC-FORMAT-TERSE Rust action-edge fluent work"
answers:
  - "is RUST-PARITY.7.5.3 still pending"
  - "which leaf closed Rust action-edge fluent continuations"
  - "why is RUST-PARITY.7.5.3 done without new code"
  - "what is the next RUST-PARITY leaf after action-edge fluent closure"
  - "does tclite still block on action-edge fluent continuations"
date: 2026-07-02
status: current
tags: [rust, RUST-PARITY, spec-format-terse, fluent, tclite, oracle]
evidence: "RUST-PARITY.7.5.3 was a stale parity frontier after SPEC-FORMAT-TERSE landed the implementation pieces: .2.3.3.1 added ActionEdge/AcodeEntry fluent_chain metadata plus no-arg action-edge .push/.return/.return_undef runtime execution; .2.3.3.3.2 completed explicit-target and flow action-edge continuations; .2.3.3.3.3.1 fixed the separate tclite default-mode repetition and child-preamble-return gap, then restored tclite_command_subst and tclite_double_quote to the oracle corpus. The 2026-07-02 RUST-PARITY.7.5.3 reconciliation marked the leaf done, .7.5.2 later temporarily restored Lispish parity, and SCALAREF-RETIREMENT.3/.4 migrated/removed scalaref before RUST-PARITY returns to .7.2."
reverify: "rg -n 'RUST-PARITY\\.7\\.5\\.3|SPEC-FORMAT-TERSE\\.2\\.3\\.3\\.3\\.2|execute_action_edge_fluent_chain|tclite_command_subst|tclite_double_quote|RUST-PARITY\\.7\\.2|SCALAREF-RETIREMENT\\.4' docs/TASK_TREE.md docs/tasks/RUST-PARITY.md docs/tasks/SPEC-FORMAT-TERSE.md docs/tasks/SCALAREF-RETIREMENT.md rust/linkedspec-runtime/src/engine.rs tools/gen_oracle_corpus.pl"
---

# Rust Parity Action-Edge Fluent Closure

`RUST-PARITY.7.5.3` is no longer an implementation frontier. It was satisfied by later,
owned `SPEC-FORMAT-TERSE` Rust work:

- `.2.3.3.1`: action-edge `fluent_chain` metadata and no-arg `.push` / `.return(...)` / `.return_undef`.
- `.2.3.3.3.2`: explicit-target and flow-control action-edge continuations.
- `.2.3.3.3.3.1`: the separate `tclite` default-mode repetition and child-preamble-return fix, with
  `tclite_command_subst` and `tclite_double_quote` restored as active oracle fixtures.

The next RUST-PARITY frontier is `.7.2` after `SCALAREF-RETIREMENT` closes. Do not
re-audit action-edge fluent continuations before working that leaf.
