---
id: rust-lossless-child-carrier-readiness
title: Rust lossless extraction and actual staged children preserve the same oracles on six carriers
answers:
  - "does Rust preserve lossless segmentation after actual child parsing"
  - "which Rust parent and child carriers verify lossless readiness"
  - "does Rust bounded child proof retain engines after a rejected child"
  - "which mutations verify Rust lossless child provenance and input containment"
date: 2026-09-27
status: bounded evidence preserved; cross-runtime milestone reconciled under .3.5
tags: [rust, language-readiness, lossless, staged-parsing, generated-source, provenance]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.1 extends the existing readiness harness with shared independent segmentation and actual-child checks. All six matched routes repeat thirteen original/enriched cases, child4/15 controls and seven mutations. Four retain engines; serialized/fresh emitted entries prove per-call isolation. Two focused outer tests and three independent emitted tests pass without runtime or oracle changes."
reverify:
  - "bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test nested_tree_readiness lossless -- --nocapture"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
---

# Matched parent and actual-child carrier proof

The canonical ledger is `docs/language-readiness/lossless-child-parsing.md`; `.3.4.1` records exact source/log
identities. The Rust harness reuses the committed `.spec` grammars and JSON oracles unchanged. It invokes each
precompiled child, which constructs its own integer-lexeme AST; the host only prepares authority and rebases spans.

Compiled and JSON-reconstructed engines each supply native and generated-plan execution. These four route pairs
retain both engines through typed child rejection and subsequent acceptance. The serialized v2 and fresh emitted
pairs reconstruct per call; they establish isolation. All pairs independently compare segment classification,
scalar slicing, reconstruction, child requests, local/global coordinates, sidecars, selected accounting and detached
results. Five in-process pairs additionally agree on the complete successful enriched records. Ten emitted modules
run original segmentation, actual child composition and seven mutants in three successful child tests.

Four mutations corrupt selection, terminal retention, item spans and skipped-prefix retention. Three alter child
leading-zero recognition, local/rebased spans or digit-only request bounds. Missing identity/top/steps reject
before callbacks; one-call exhaustion rejects after one callback. No seed leaves an inert marker. Rust's execution
wrappers retain exact staged error codes; standalone child rejection retains typed status1. Cross-language error
object identity is not claimed.

The existing `LocalCrate` allocator and emitted target cache are reused, including the process-local atomic
sequence that avoids parallel test collisions. No new output root, runtime behavior or generated format is added.
Known `.73`/`.74`/`.75` staged defects are not closed by distinct destinations, plain child results and small
counters; neither arbitrary recursive safety nor format conformance follows from this bounded corpus.

[[lossless-child-readiness-reconciliation]] records the completed bounded matrix and authoring costs; historical leaf evidence and open defect limits remain unchanged.
