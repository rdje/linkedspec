---
id: generated-source-contract-v1
title: Generated-source v1 fixes semantic roles while keeping host APIs and source syntax idiomatic
answers:
  - "what is the neutral generated-source contract"
  - "must generated source bytes be identical across backends"
  - "which generated rule families must every backend support"
  - "what corpus subset proves a new source emitter"
  - "what errors must generated-source APIs expose"
  - "how is generated-source conformance checked"
date: 2026-07-15
status: current
tags: [generated-source, contract, parity, codegen, conformance]
evidence: "FUTURE-PARITY-BACKLOG.3.1.1 adds capability_conformance/generated_source_contract.json and tools/check_generated_source_contract.pl, wired into tools/run_ci_local.sh. The v1 contract fixes compiled-spec-plus-identity input, host source output, deterministic format/version/identity markers, execute and execute-with-trace roles, seven ordered pipeline stages, ten structural families, exact family-plan validation and four rejection codes, stable generated_source_error stages/fields/codes, one direct result/trace/identity fixture, the accepted eight-case manifest subset, the 105-case primary interpreter manifest, and live backend states. ADR 0023 still permits idiomatic host names and backend-native source syntax; source bytes are explicitly not required to match."
evidence_update_2026_07_11_perl: "FUTURE-PARITY-BACKLOG.3.1.2 implements the v1 roles on Perl through LinkedSpec::emit_generated_source, LinkedSpec::GeneratedSource, Compiler reconstruction, and t/generated_source_contract.t; explicit capability promotion remains .3.1.3."
evidence_update_2026_07_11_rust_audit: "FUTURE-PARITY-BACKLOG.3.1.3.0 proves the existing Rust scaffold predates v1 identity, structured error, exact unknown-family rejection, and neutral generated trace-role requirements; .3.1.3.1-.3 now own alignment and admission."
evidence_update_2026_07_11_rust_metadata_errors: "FUTURE-PARITY-BACKLOG.3.1.3.1 implements Rust caller identity, deterministic contract/version/identity metadata, typed generated_source_error stages/codes/attribution, host compile/load projection, typed generated execution, and exact compatibility adapters. Focused 4/4 and complete Rust 137/105/196/5/4/5/10 plus 61x2 pass; exact neutral plan/trace remains .3.1.3.2."
evidence_update_2026_07_11_rust_plan_trace: "FUTURE-PARITY-BACKLOG.3.1.3.2 implements exact neutral plan rows/ten families/four rejections, direct v1 top-rule result, and three portable trace roles beside native detail. It preserves the legacy accumulator envelope and trace. Focused 5/5 + 10/10 and clean full Rust 137/105/196/5/5/5/10 plus 61x2 pass; admission remains .3.1.3.3."
evidence_update_2026_07_11_admission: "FUTURE-PARITY-BACKLOG.3.1.3.3 passes the focused 69-assertion Perl contract, focused Rust 5/5 source-emitter test, canonical Perl gate including Phase 0 1..1030 and 61x2 CLI, and complete Rust 137/105/196/5/5/5/10 plus 61x2 CLI gate. The baseline contract is admitted: Perl passes, Rust remains partial only for 8/105 generated compile/run breadth, and .3.1 closes."
evidence_update_2026_07_11_rust_breadth_admission: "FUTURE-PARITY-BACKLOG.3.2.2 adds the exact Rust full-manifest test path to corpus_proof and makes the checker enforce file existence, 105 count, no ignore attribute, and unconditional failure rejection. Independent and complete Rust gates pass; Rust promotes at census 58/0/2."
evidence_update_2026_07_11_dart_scaffold: "FUTURE-PARITY-BACKLOG.3.3.1 adds public Dart compatibility/v1 emission, exact metadata and portable emit/compile-load/execution errors, deterministic effective-compiled-state normalization, strict-UTF-8/Base64 payload embedding, ordinary/traced direct-value entrypoints, and a caller-owned isolated offline analyze/run harness. Focused 3/3 and complete Dart 178/61x2/105 pass; Dart remains gap pending family-plan .3.3.2 and corpus admission .3.3.3."
evidence_update_2026_07_11_dart_family_execution: "FUTURE-PARITY-BACKLOG.3.3.2 adds exact ten-family ordered rows, distinct count/label/family/unknown rejections, validated typed per-rule acode/bcode structural dispatch, portable enter/decision/exit trace roles, attributed failures, and one isolated offline all-family package compared with interpreter values. Focused 5/5 and complete Dart 180/61x2/105 pass; admission remains .3.3.3."
evidence_update_2026_07_11_dart_admission: "FUTURE-PARITY-BACKLOG.3.3.3 adds the exact Dart accepted-subset test path to the contract, consumes its eight names directly, proves interpreter expected values before emission, runs all emitted libraries in one isolated offline package with exact metadata/plans/trace identity, and passes complete 181/61x2/105 gates. Dart promotes at census 59/0/1."
evidence_update_2026_07_11_julia_admission: "FUTURE-PARITY-BACKLOG.3.4.3 adds the exact Julia accepted-subset test path, consumes the eight contract names directly, proves interpreter expected values before emission, loads eight modules in one isolated offline host with exact metadata/plans/trace identity, and passes complete 1,168/61x2/105 gates. Julia promotes at census 60/0/0."
evidence_update_2026_07_11_final_closeout: "FUTURE-PARITY-BACKLOG.3.5 rechecks all four focused generated-source proofs plus adjacent complete backend gates, confirms executable contract/capability 60/0/0, closes .3, and hands the complete v1 obligation to active Lua planning .1.3."
evidence_update_2026_07_15_acceleration_horizon: "ADR 0038 and FUTURE-PARITY-BACKLOG.18.3 preserve v1 as the semantic portability foundation for any future native parser accelerator. Existing source wrappers and state reconstruction prove identity, loadability, trace roles, and oracle equivalence; they do not by themselves establish optimizing compilation or a speed advantage."
evidence_update_2026_07_16_lua_scaffold_split: "LUA-BACKEND-PARITY.8.1.0 corrects the older Lua leaf against ADR 0041's later final-codeblock-v3 union and splits deterministic v1/v2/v3 emitter core .8.1.1 from fresh-process dual-ABI load/run .8.1.2 before family-plan .8.2 and subset admission .8.3."
evidence_update_2026_07_16_lua_emitter_core: "LUA-BACKEND-PARITY.8.1.1 adds Lua compatibility/source-identified emitters, exact v1 metadata and portable error stages/codes, deterministic effective fixed-v1/variadic-v2/final-codeblock-v3 SpecFile reconstruction, canonical strict-UTF-8 JSON/source-identity ASCII hex, and generated direct/traced result roles. Focused PUC Lua and LuaJIT gates pass 172/172; canonical reference CLI is 61x2 and Phase 0 is 1031/1031 in 620 seconds. Fresh-process isolation, plan families, subset proof, and census remain .8.1.2-.8.4."
reverify: "perl -c tools/check_generated_source_contract.pl && perl tools/check_generated_source_contract.pl && perl tools/check_capability_conformance.pl && rg -n 'check_generated_source_contract|generated_source_contract' tools/run_ci_local.sh capability_conformance/README.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

# Generated-Source Contract v1

Every backend generates a different host language, so conformance is defined by
semantic roles rather than shared source text or non-idiomatic symbol names.

The v1 contract requires:

- compiled specification plus source identity as emitter input;
- deterministic host-language Unicode source, encoded as strict UTF-8 when
  persisted, with contract/version/identity markers;
- independently loadable source with execute and execute-with-trace roles;
- a validated ordered label/family plan over ten default/OR/AND/repetition
  acode and bcode families;
- pre-execution rejection of count, label, family, and unknown-family drift;
- stable generated-source error stages, codes, and source attribution;
- exact generated result, trace-role, and identity proof;
- interpreter-first comparison against a shared manifest subset.

The accepted initial subset is the same eight fixtures already used by Rust's
generated-source test. Rust must additionally expand to all 105 interpreter
fixtures under `.3.2`; new Dart and Julia emitters must prove the subset plus
all generated families. The interpreter corpus remains the primary oracle.

Generated-source v1 is deliberately a semantic contract, not an optimization claim. A future optional native
accelerator may build on its normalized state, source identity, independent loading, trace roles, and dynamic-oracle
comparison, but must separately prove specialized execution, exact equivalence, and an objective break-even benefit
under ADR `0038`.

The Perl/Rust v1 baseline is admitted under `.3.1.3.3`. Rust's separate
full-manifest claim is admitted under `.3.2.2` through an unconditional,
contract-checked 105/105 recurring test. Both backends now pass.

Dart's `.3.3.1` scaffold implements emission, metadata, stable failures, and
isolated compile/run. `.3.3.2` adds exact family-plan validation, direct
structural-family routing, and portable generated trace roles. `.3.3.3`
completes manifest-backed admission: the contract checker locks its path/count/
order/host proof/trace/cleanup/no-skip properties, and Dart passes.

Related facts: [[generated-source-parity-audit]],
[[perl-generated-source-capture-not-standalone]],
[[rust-generated-source-contract-v1-gap]],
[[rust-generated-source-v1-metadata-errors]],
[[rust-generated-source-v1-result-projection]],
[[rust-generated-source-corpus-subset]],
[[dart-generated-source-deferred]],
[[lua-generated-source-scaffold-split]],
[[lua-generated-source-emitter-core]],
[[optional-native-parser-acceleration]],
[[user-observable-backend-cli-parity-contract]].
