---
id: nested-tree-rust-carrier-readiness
title: Rust nesting proof distinguishes retained engines from per-call generated entries
answers:
  - which Rust nesting carriers preserve values and Unicode spans
  - does Rust nesting rejection recovery reuse the same engine
  - how does the Rust nesting test verify freshly emitted modules
  - which grammar mutations does the Rust nesting oracle detect
date: 2026-09-27
status: bounded Rust carrier proof verified
tags: [language-readiness, rust, generated-source, recovery, spans]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.2: two outer tests and four fresh emitted child tests pass; six routes each execute40 original calls and three controlled grammar mutations; four retained-engine routes prove56 rejection recoveries. Leading-input3 and strict-document1 compatibility tests pass."
reverify: "bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test nested_tree_readiness --test leading_input_trivia --test sexpr_document_v1"
---

The native and JSON-reconstructed `Engine` each expose native and generated-plan typed execution. These four
routes retain the engine across every status1 Exit and immediately subsequent valid parse. Public serialized v2
and emitted module entries construct an engine per call; their subsequent valid parses carry no retained-engine
recovery claim. Shared independent JSON oracles check exact kinds and half-open Unicode scalar spans.

`rust/linkedspec-runtime/tests/nested_tree_readiness.rs` compiles four modules from unchanged grammar and three
controlled mutations: remove the prefix guard, remove gap rejection, corrupt the list start coordinate. The child
checks v2 metadata, source identity and plan, then executes the original40 calls or the corresponding mutant.
The parent requires actual process success and exactly four executed child tests. The scratch crate is exclusively
owned; its runtime dependency is relative, source data stays in files and its target cache remains repository-local.
No runtime code, contract, fixture oracle or dependency lockfile changes in this evidence leaf.

The ledger is `docs/language-readiness/nested-tree-native.md`; the exact leaf checkpoint stores commands/log hashes.
Related: [[nested-tree-public-native-readiness]], [[perl-emitted-public-entry-trivia]].
This bounded grammar does not admit standard formats or establish arbitrary-depth resource safety.
