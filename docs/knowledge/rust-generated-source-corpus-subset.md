---
id: rust-generated-source-corpus-subset
title: Rust generated source has all-family compile/run proof plus a curated manifest-backed oracle corpus subset
answers:
  - "does generated Rust source run against the oracle corpus"
  - "which oracle corpus fixtures are validated by generated Rust source"
  - "does generated Rust source cover all 105 oracle fixtures"
  - "what did RUST-PARITY.8.5 add"
  - "is the Rust generated-source corpus proof exhaustive"
  - "what is the generated-source corpus subset limitation"
date: 2026-07-08
status: accepted
tags: [rust, codegen, source-emitter, oracle, corpus, RUST-PARITY, task-tree]
evidence: "RUST-PARITY.8.5 extends rust/linkedspec-runtime/tests/source_emitter.rs with generated_rust_source_matches_manifest_backed_corpus_subset. The test loads rust/linkedspec-runtime/tests/corpus/manifest.json, asserts selected fixture names are present, parses each fixture with parse_spec_with_user_functions, validates and compiles it, checks Engine::execute(input) equals [expected.json], emits generated Rust source from that CompiledSpec, then builds and runs generated modules in an isolated temporary crate. The selected subset is proof_edge_array_literal, proof_edge_scalar_literal, autoexist_array_bare_arg, terse_1_5_2_primitive_literals, terse_2_2_3_attached_if_blocks, terse_4_3_2_user_function_runtime, tclite_command_subst, and portmap_bare. The separate source-emitter matrix still covers every supported generated structural family. FUTURE-PARITY-BACKLOG.3.0 reverified that the subset remains exactly eight while the current interpreter manifest contains 105; full breadth is owned by .3.2."
evidence_update_2026_07_11_full_classifier: "FUTURE-PARITY-BACKLOG.3.2.0 preserves the recurring eight-case subset and all-family matrix while adding an explicit staged all-105 classifier. One isolated crate compiles/runs 105 separate generated modules/tests in 184.46 seconds with 105 pass and zero failures. `.3.2.1-.2` own zero-failure closeout and recurring admission."
evidence_update_2026_07_11_zero_failure_closeout: "FUTURE-PARITY-BACKLOG.3.2.1 closes the empty repair inventory; only .3.2.2 recurring admission remains."
reverify: "cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter -- --nocapture && rg -n 'GENERATED_SOURCE_CORPUS_SUBSET|generated_rust_source_matches_manifest_backed_corpus_subset|RUST-PARITY\\.8\\.5' rust/linkedspec-runtime/tests/source_emitter.rs docs/tasks/RUST-PARITY.md"
---

# Rust Generated-Source Corpus Subset

`RUST-PARITY.8.5` closes the generated-source lane by combining two proof layers:

- the synthetic all-family generated-source matrix, which compiles and runs
  generated modules for every supported structural family;
- a curated manifest-backed oracle subset, which proves generated source against
  selected checked-in corpus fixtures and their `expected.json` values.

The generated-source corpus subset is:

- `proof_edge_array_literal`
- `proof_edge_scalar_literal`
- `autoexist_array_bare_arg`
- `terse_1_5_2_primitive_literals`
- `terse_2_2_3_attached_if_blocks`
- `terse_4_3_2_user_function_runtime`
- `tclite_command_subst`
- `portmap_bare`

The recurring source-emitter gate still retains this compact subset. An
explicit staged classifier now validates generated source over all 105 oracle
fixtures with zero failures. Closeout found no repair; `.3.2.2` owns promotion
into a strict recurring admission gate.
