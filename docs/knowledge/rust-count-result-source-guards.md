---
id: rust-count-result-source-guards
title: Rust Count guards actual results and uses Array-only source fallback
answers:
  - "how does Rust Count reject container consumers before operands and with bodies"
  - "why does Rust count text return four rather than zero"
  - "which owner resolves Rust Count String source-domain parity"
  - "does Rust Count preserve copied-null and repeated result guards"
  - "how does Rust Count preserve non-array source zero fallback"
  - "where are actual Cargo inputs for the Rust Count source fallback repair"
date: 2026-11-05
status: primary guards and non-array source73.6.2 focused-checked; full23.4 remains open
tags: [rust, count, guards, source, copy, null, composition]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.73.2; docs/checkpoints/count-guard-rust-2026-11-05/ retains original baseline/diagnostic/AST/IR/trace with its first-host custody gaps. Current73.6.2 retains20-case native/restored/plan/compiled-emitted RED/GREEN and actual pre-first-run Cargo source/manifests/locks/modules in docs/checkpoints/count-source-rust-2026-11-05/. Complete transitive/native custody stays23.4.2-owned."
reverify:
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -j 1 -p linkedspec-runtime --test count_source_fallback -- --test-threads=1"
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

The historical73.2 Rust diagnostic returned `4` for both `count("text")` and
`"text".count()`, where the Perl reference returns zero. The free Rust producer
delegated to `RuntimeValue::len`; the primary guard repair left that producer intact.
The exact observed source-domain fixture is frozen before production changes.
Mandatory P1 assessment73.6.0 owned this demonstrated parity discrepancy after
the primary backend guards and before unrelated feature selection.

Native/restored/generated-plan, independently compiled emitted modules, native
trace and direct Count/length/copied-null index controls pass. The original
baseline behavioral REDs and observer bootstrap qualifications remain retained.
Complete generated-input custody, fixture registration, general isolation and
portable/family admission remain with their explicit owners; no full suite or
new publication is inferred. Rebuild Rust applications/runtime to use the fix.

Current73.6.2 restores Count's existing Array-only source contract. Its helper
matches RuntimeValue::Array and returns that Array's length; other accepted source
values return Number0. RuntimeValue.len and general length behavior stay intact.
Initial receiver sources use the same producer; copied/produced receivers retain
their existing kind guards, so `count(copy("text"))` is0 while
`copy("text").count()` remains null. Current diagnostic assertions use the
reference zero target; the original divergent fixture stays frozen.

Twenty native/restored/plan and independently compiled emitted controls now match,
including three baseline source-domain groups, general length, zero/kinds,
source/error/snapshot/function and rejection/copy preservation. Actual root,
observer and generated Cargo source/manifests/resolved locks precede first runs
and compare exactly afterward. A first absolute-archive-membership setup failure
is retained without standalone behavioral credit; qualified acquisition is clean.
Evidence and readonly review: docs/checkpoints/count-source-rust-2026-11-05/.
Earlier custody gaps are unchanged; full transitive/native closure remains23.4.2.
Peer Boolean source repairs, registration, general isolation and full admission
remain separate. Rebuild Rust applications/runtime for the source fallback fix.
