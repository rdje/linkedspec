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
date: 2026-07-11
status: current
tags: [generated-source, contract, parity, codegen, conformance]
evidence: "FUTURE-PARITY-BACKLOG.3.1.1 adds capability_conformance/generated_source_contract.json and tools/check_generated_source_contract.pl, wired into tools/run_ci_local.sh. The v1 contract fixes compiled-spec-plus-identity input, host source output, deterministic format/version/identity markers, execute and execute-with-trace roles, seven ordered pipeline stages, ten structural families, exact family-plan validation and four rejection codes, stable generated_source_error stages/fields/codes, one direct result/trace/identity fixture, the accepted eight-case manifest subset, the 105-case primary interpreter manifest, and live backend states. ADR 0023 still permits idiomatic host names and backend-native source syntax; source bytes are explicitly not required to match."
evidence_update_2026_07_11_perl: "FUTURE-PARITY-BACKLOG.3.1.2 implements the v1 roles on Perl through LinkedSpec::emit_generated_source, LinkedSpec::GeneratedSource, Compiler reconstruction, and t/generated_source_contract.t; explicit capability promotion remains .3.1.3."
evidence_update_2026_07_11_rust_audit: "FUTURE-PARITY-BACKLOG.3.1.3.0 proves the existing Rust scaffold predates v1 identity, structured error, exact unknown-family rejection, and neutral generated trace-role requirements; .3.1.3.1-.3 now own alignment and admission."
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

Related facts: [[generated-source-parity-audit]],
[[perl-generated-source-capture-not-standalone]],
[[rust-generated-source-contract-v1-gap]],
[[rust-generated-source-corpus-subset]],
[[user-observable-backend-cli-parity-contract]].
