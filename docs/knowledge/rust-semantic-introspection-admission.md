---
id: rust-semantic-introspection-admission
title: Rust semantic introspection is admitted by one exact composed consumer
answers:
  - "is Rust semantic introspection admitted"
  - "what admits the Rust semantic index"
  - "which test composes every Rust semantic introspection path"
  - "how many Rust semantic admission roles exist"
  - "does Rust match all 20 semantic query responses"
  - "which Rust semantic runtime routes are admitted"
  - "what is semantic introspection rollout after Rust admission"
  - "what is semantic introspection native admission after Rust"
  - "how many semantic introspection mutations are rejected after Rust admission"
  - "what task follows Rust semantic introspection admission"
date: 2026-09-08
status: current fixture-bound admission; July rollout counts are historical
tags: [rust, semantic-introspection, admission, conformance, mutations, rollout, parity]
evidence: "FUTURE-PARITY-BACKLOG.10.4.6 introduced the exact twelve-role Rust consumer. Its July 21 record was 73 mutations, rollout 3/9 and admission 2/6. Startup .3.3.61/.62 reconcile the unchanged consumer against the current neutral result: six fixture groups, twenty exact query responses, 128 rejected mutations, rollout 9 complete / 0 pending and admission 6 complete / 0 pending. The .3.3.61 canonical run passed the composed Rust consumer 1/1 in 108.53 test seconds. Source-emitter-labelled routes exercise generated-plan helpers; they do not independently compile an emitted module."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test semantic_introspection_rust_admission && bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
---

# Rust Semantic Introspection Admission

Rust was the second admitted implementation of `linkedspec-semantic-model-v1` and
`linkedspec-semantic-query-v1`. Admission adds no semantic production path: the consumer composes the existing
strict source/outcome constructor, static and call/staged/generated projection, immutable typed/raw-neutral query
evaluator, invocation-local observation sink, and post-execution derivation.

Its 12 contract-declared roles execute exactly once. They cover strict byte/text convergence; compiled graph,
calls, privacy, failed, and runtime snapshots; direct, loaded, reconstructed, generated-plan, and traced execution;
native/neutral JSON identity; all 20 exact response digests; privacy, pages, budgets, portable
errors, and explanations; query non-execution and clone isolation; and denial of host paths, objects, backend IR,
or generated implementation source.

The two source-emitter-labelled routes call public generated-plan execution helpers inside the generated
and traced roles. The traced wrappers use disabled text tracing. This consumer does not compile and launch
an independent emitted Rust module.
Matching all twenty response digests covers the declared fixtures, not arbitrary authored specifications or the
pending semantic projection repairs in the startup tree. See [[rust-semantic-runtime-observation]] for the
separate, narrower independently emitted observation test.

The checker requires the exact consumer path, ordered role list, canonical driver and invocation, Rust admission
status, and Rust rollout status. The original eight Rust-specific mutations independently remove or alter
those boundaries. The July 21 early-admission mutation targeted then-pending Dart; that is historical rollout
evidence. Current neutral verification reports 128 rejected mutations with rollout 9/0 and admission 6/0.
The successful .3.3.61 composed Rust test is fresh native evidence for this consumer; separately optional full
Rust and six-runtime semantic gates were not enabled by that canonical invocation.

Related facts: [[semantic-introspection-neutral-contract]], [[rust-semantic-index-source-foundation]],
[[rust-semantic-static-projection]], [[rust-semantic-call-staged-projection]],
[[rust-semantic-query-evaluator]], and [[rust-semantic-runtime-observation]].
