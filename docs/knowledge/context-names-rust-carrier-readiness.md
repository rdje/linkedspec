---
id: context-names-rust-carrier-readiness
title: Rust preserves bounded closing-name context through six typed carriers
answers:
  - do Rust generated and reconstructed parsers preserve closing-name context
  - how is typed Rust context-name rejection distinguished from null
  - how many retained Rust context-name recovery transitions are verified
  - why did parallel emitted readiness crates collide despite nanosecond names
date: 2026-09-27
status: bounded proof verified; cross-runtime milestone recorded separately
tags: [language-readiness, context, rust, generated-source, recovery]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.3 verifies six routes with90 calls and three mutants each, including136 recovery transitions on four retained engines. Four outer readiness tests and four direct-dependent tests pass; two fresh emitted children each actually execute four tests and exit0. The first combined run exposed a timestamp-only scratch-name race, repaired by adding an atomic process-local sequence."
reverify: "bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test nested_tree_readiness --test leading_input_trivia --test sexpr_document_v1 -- --nocapture"
---

`docs/language-readiness/context-names.md` owns the route table and authoring limits. Native compiled and
JSON-reconstructed engines each run native and generated-plan execution, retaining an engine across all
rejections and 34 immediate successes. The public serialized v2 and fresh emitted entry create an engine per
call; they establish isolation instead. The shared checker returns Result<Value,i32>, matches only public
native/generated Exit variants, and compares each authored status. Ok(null) cannot satisfy a rejected input.
Comparison/state/span mutations separately expose wrong acceptance, parent-state corruption and wrong spans.
The11/17 context and original nesting source/oracles stay unchanged. No runtime or generated-format change.

The existing test helper used PID and SystemTime nanoseconds, which do not guarantee uniqueness between
threads. Adding a second emitted test reproduced AlreadyExists while its peer passed. An AtomicU64 sequence
now makes same-process names distinct even if time repeats; exclusive create_dir still refuses pre-existing
paths. The successful combined rerun exercises both children concurrently. Stores and output roots are
unchanged; no global storage policy change. This is test allocation repair, not parser behavior.

Related: [[context-names-public-native-readiness]], [[context-names-perl-readiness]],
[[nested-tree-rust-carrier-readiness]].

[[context-names-readiness-reconciliation]] records the complete bounded matrix, authoring costs and canonical milestone.
