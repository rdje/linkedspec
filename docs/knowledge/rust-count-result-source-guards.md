---
id: rust-count-result-source-guards
title: Rust Count continuations guard actual kinds while preserving initial source behavior
answers:
  - "how does Rust Count reject container consumers before operands and with bodies"
  - "why does Rust count text return four rather than zero"
  - "which owner resolves Rust Count String source-domain parity"
  - "does Rust Count preserve copied-null and repeated result guards"
date: 2026-11-05
status: focused implementation checked; source-domain assessment73.6 and full23.4 remain open
tags: [rust, count, guards, source, copy, null, composition]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.73.2; docs/checkpoints/count-guard-rust-2026-11-05/ retains unchanged baseline, frozen diagnostic/AST, native compiled IR/trace, candidate/final results and direct source archives. First host-project generation-input closure is explicitly incomplete and23.4.2-owned."
reverify:
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test count_result_guard_composition -- --nocapture"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test generated_source_full_manifest_classifier count_result_guard -- --nocapture"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test count_length_receivers --test copied_null_index_composition"
---

`Engine::is_ordinary_count_result_chain` admits canonical positional free-one
Count sources and zero-extra Count receiver prefixes, excluding traversal chains.
Both direct dispatch and trailing-block execution join the existing actual-kind
guards. An incompatible Array/Hash consumer returns before its operands and
later `with` bodies. Legitimate null still enters `with`; numeric zero, snapshots,
source errors and compatible scalar/default/Array transitions stay intact.

Only an initial Count source with no existing result owner retains its legacy
domain behavior. A Count result consumed by another Count is already produced
data and keeps the Array-kind guard. Existing copied-null behavior stays null.

The unchanged Rust diagnostic returns `4` for both `count("text")` and
`"text".count()`, where the Perl reference returns zero. The free Rust producer
delegates to `RuntimeValue::len`; this guard repair leaves that producer intact.
The exact observed source-domain fixture is frozen before production changes.
Mandatory P1 assessment73.6.0 owns this demonstrated parity discrepancy after
the primary backend guards and before unrelated feature selection.

Native/restored/generated-plan, independently compiled emitted modules, native
trace and direct Count/length/copied-null index controls pass. The original
baseline behavioral REDs and observer bootstrap qualifications remain retained.
Complete generated-input custody, fixture registration, general isolation and
portable/family admission remain with their explicit owners; no full suite or
new publication is inferred. Rebuild Rust applications/runtime to use the fix.
