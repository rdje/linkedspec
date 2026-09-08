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
date: 2026-09-08
status: eight-case subset retained; full-classifier child-status repair .77 pending
tags: [rust, codegen, source-emitter, oracle, corpus, RUST-PARITY, task-tree]
evidence: "Historical RUST-PARITY.8.5 extends rust/linkedspec-runtime/tests/source_emitter.rs with generated_rust_source_matches_manifest_backed_corpus_subset. The test loads rust/linkedspec-runtime/tests/corpus/manifest.json, asserts selected fixture names are present, parses each fixture with parse_spec_with_user_functions, validates and compiles it, checks Engine::execute(input) equals [expected.json], emits generated Rust source from that CompiledSpec, then builds and runs generated modules in an isolated temporary crate. The selected subset is proof_edge_array_literal, proof_edge_scalar_literal, autoexist_array_bare_arg, terse_1_5_2_primitive_literals, terse_2_2_3_attached_if_blocks, terse_4_3_2_user_function_runtime, tclite_command_subst, and portmap_bare. The separate source-emitter matrix still covers every supported generated structural family. FUTURE-PARITY-BACKLOG.3.0 reverified that the subset remains exactly eight while the then-current interpreter manifest contains 105; the later .3.2 admission is historical, and startup .77 now owns its reproduced child-status gap."
evidence_update_2026_07_11_full_classifier: "FUTURE-PARITY-BACKLOG.3.2.0 preserves the recurring eight-case subset and all-family matrix while adding an explicit staged all-105 classifier. One isolated crate compiles/runs 105 separate generated modules/tests in 184.46 seconds with 105 pass and zero failures. `.3.2.1-.2` own zero-failure closeout and recurring admission."
evidence_update_2026_07_11_zero_failure_closeout: "FUTURE-PARITY-BACKLOG.3.2.1 closes the empty repair inventory; only .3.2.2 recurring admission remains."
evidence_update_2026_07_11_full_admission: "FUTURE-PARITY-BACKLOG.3.2.2 retains the focused subset but admits an unconditional contract-gated all-105 recurring test; Rust promotes to pass."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test source_emitter -- --nocapture && rg -n 'GENERATED_SOURCE_CORPUS_SUBSET|generated_rust_source_matches_manifest_backed_corpus_subset|RUST-PARITY\\.8\\.5' rust/linkedspec-runtime/tests/source_emitter.rs docs/tasks/RUST-PARITY.md"
---

# Rust Generated-Source Corpus Subset

`RUST-PARITY.8.5` historically closed its generated-source lane by combining two proof layers:

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

The recurring source-emitter target retains exactly these eight cases. Source reading in
`SESSION-STARTUP-READING.3.3.62/.63` confirms that each case first satisfies direct-value and
compatibility-array interpreter expectations, then becomes an independently compiled emitted
module with both entry points and plan validation. Its shared child runner requires process
success. The synthetic matrix uses fourteen fixtures to cover exactly ten neutral families,
including their derived cursor policies and direct/compatibility result shapes.

The all-105 classifier was separately registered and admitted; the July 11 entries above are
dated reports. Startup repair `.77` establishes that its host-run accounting can accept all
105 pass markers even when that child returns failure. Registration and marker totals do not
close that process-status gap. This finding does not establish a parser-output defect or
invalidate a particular historical run. See [[rust-generated-classifier-child-status-gap]]
and [[rust-generated-source-full-manifest-classification]].

The eight-case target and all-family test still contain JSON-as-Rust literal construction
owned by `.71` and an absolute authored Cargo dependency owned by `.78`. These are separate
from the classifier's `.77` accounting defect. This reading checkpoint does not claim a new
execution of the full source-emitter target; its reverify command uses managed locked/offline
Cargo. All three repairs remain behind the startup reading and policy prerequisites.
