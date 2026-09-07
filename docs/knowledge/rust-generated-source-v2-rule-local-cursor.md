---
id: rust-generated-source-v2-rule-local-cursor
title: Rust generated-source v2 reconstructs cursor policy from a minimal neutral family plan
answers:
  - "what is the current Rust generated source contract"
  - "how do I emit Rust generated source with source identity"
  - "does Rust generated source serialize parse mode"
  - "does Rust generated source serialize cursor policy"
  - "how does Rust generated source derive seek and consume"
  - "which Rust generated families seek"
  - "which Rust generated families consume"
  - "what happens when Rust loads a generated source v1 artifact"
  - "why must a Rust generated source v1 artifact be regenerated"
  - "why is RuleMode is_repetition not the generated repetition classifier"
  - "what proves Rust generated source v2"
date: 2026-09-07
status: current
tags: [rust, generated-source, cursor, reconstruction, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.4.5 changes new Rust emission to linkedspec-generated-source-v2 / format 2. Emitted modules retain exactly one ordered GeneratedPlanRow table containing label/family and ordinary CompiledSpec JSON with no cursor field. Reconstruction validates the artifact contract before JSON decoding, maps default/or_acode/or_bcode/rep_acode/rep_bcode to seek and the five AND families to consume, and executes direct/traced/diagnostic plus compatibility roles through that derived plan. A v1 contract fails at validate_generated_plan with generated_source_contract_version_mismatch, expected_contract, actual_contract, and regenerate-from-.spec guidance. Focused source-emitter and rule-local execution tests prove metadata, determinism, mutations, all ten policies, source/trace identity, fresh host compile/load, corpus subset, compact pipe, and default authored-family classification."
reverify: "bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter; bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test rule_local_cursor_execution; bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test generated_source_full_manifest_classifier; bash tools/run_python_project_data.sh tools/check_rule_local_cursor_contract.py"
---

Rust's current generated artifact identifies
`linkedspec-generated-source-v2` / format 2. Native callers use
`emit_rust_source_v2(&compiled, source_identity)`; the original
`emit_rust_source(&compiled)` remains a raw-string compatibility adapter with
`<inline>` identity.

An emitted module carries contract/version/identity metadata, cursor-free
`CompiledSpec` JSON, and exactly one ordered plan whose rows have only `label`
and neutral `family`. Reconstruction derives policy rather than deserializing
it:

- `default`, `or_acode`, `or_bcode`, `rep_acode`, and `rep_bcode` seek;
- `and_single_acode`, `and_acode_seq`, `and_bcode`, `rep_and_acode`, and
  `rep_and_bcode` consume.

The authored unsuffixed `Default` mode is a useful boundary. Live execution
repeats it, so core `RuleMode::is_repetition()` correctly returns true. The
generated contract nevertheless reserves the `default` family row and uses
`rep_*` only for explicit repetition suffixes. Generated classification must
therefore test explicit repetition variants rather than reuse the broader live
execution predicate.

Contract validation precedes compiled JSON decoding and plan reconstruction.
Passing a v1 artifact to the v2 boundary returns
`generated_source_contract_version_mismatch` at `validate_generated_plan`, with
exact expected/actual contract fields and guidance to regenerate from the
original `.spec`; no caller/global policy is inferred.

Typed `execute` roles retain direct top-rule values, compatibility `parse`
roles retain the historical accumulator envelope, and portable generated trace
roles retain source/rule/family identity. Related facts:
[[rust-generated-source-family-plan]],
[[rust-generated-source-v1-result-projection]],
[[rust-rule-local-cursor-execution]], and
[[perl-generated-source-contract-v2]].

## September 7 emitter prefix reading

`SESSION-STARTUP-READING.3.3.33` reads source_emitter.rs 1–437. Version 2 metadata retains source identity;
structured errors carry stage/code plus optional rule/entry/family/detail and contract/slot context. Sink failures,
exit_now and ordinary generated/compatibility errors remain distinct typed variants. Ten family names map to
five seek/five consume policies; the decoder also recognizes and_regex_only and and_bcode_seq aliases. Their
later plan validation is outside this prefix. Emission rejects empty identity and validates removed selectors,
typed writes/mutations and compiled slot identities before serializing the spec and encoding source identity.
The module body and execution adapters remain next. Fresh cursor 36/18/8/60 and generated metadata checks pass;
the latter's neutral-v1 label does not change the Rust artifact-v2 identity. No emitted module is freshly built.
