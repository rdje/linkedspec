---
id: dart-generated-source-deferred
title: Dart generated source is admitted with exact ten-family and manifest proof
answers:
  - "does Dart generated source exist now"
  - "what did DART-BACKEND-PARITY.7.2 decide"
  - "why was generated Dart source deferred"
  - "what must the Dart source emitter still prove"
  - "is generated Dart source required for Dart parity"
  - "how does Dart embed Unicode generated spec state"
  - "where is the Dart generated-source compile run harness"
  - "does Dart generated source preserve punctuation light aliases"
date: 2026-07-13
status: current
tags: [dart, codegen, source-emitter, corpus, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.7.2 deferred codegen; FUTURE-PARITY-BACKLOG.3.3 later closes deterministic source, family routing, isolation, and admission. FUTURE-PARITY-BACKLOG.4.3.1 carries typed variadic signatures through normalized emitted Base64 state, generated-plan execution, and reconstruction. FUTURE-PARITY-BACKLOG.16.4 proves punctuation-light typed AST equivalence plus exact native, generated-plan, emitted-state reconstruction, and CLI results; the complete 211/61x2/105 gate passes."
reverify: "cd dart && dart test test/source_emitter_test.dart test/punctuation_light_zero_arg_contract_test.dart && dart analyze --fatal-infos --fatal-warnings && rg -n 'FUTURE-PARITY-BACKLOG\\.3\\.3|emitDartSourceV1|_compiledSpecJsonBase64|PUB_CACHE' ../docs/tasks/FUTURE-PARITY-BACKLOG.md lib/src/source_emitter.dart test/source_emitter_test.dart"
---

Generated Dart source now exists as a public scaffold. It was not required for
the scoped interpreter-corpus claim, green at 105/105, but ADR `0023` requires
it for complete public capability parity because Rust exports source emission.

`DART-BACKEND-PARITY.7.2` deliberately deferred generated Dart source. The later
implementation split under `FUTURE-PARITY-BACKLOG.3.3` now has:

- `.3.3.1` done: compatibility/v1 emitters, metadata/errors, deterministic
  effective-state emission, and isolated caller-package compile/run;
- `.3.3.2` done: exact generated family-plan metadata, four-way validation,
  portable trace roles, and direct execution for every structural family;
- `.3.3.3` done: contract-sourced manifest admission after interpreter-first
  exact comparison, independent host analyze/run, and complete recurring gates.

The scaffold reconstructs a normalized `SpecFile` from effective ordered
`CompiledSpec` functions/rules. The generated Dart library is Unicode source;
its embedded normalized JSON is encoded as strict UTF-8 then Base64. Unicode is
the character model, while UTF-8 is the selected byte encoding at this
boundary; UTF-16 and UTF-32 are other Unicode encodings, not invalid Unicode.

`DART-BACKEND-PARITY.7.5` closed the scoped interpreter-first Dart milestone
without claiming generated-source parity. Global `.3.3` has since closed that
gap. Dart and Julia now pass the complete generated-source capability census.

Variadic functions reuse this normalized-state path: the v2 signature is embedded in the Base64 JSON, reconstructed
into `FunctionDefinition`, and executed without host Dart rest or named-argument semantics.

Punctuation-light zero-argument aliases reuse the same typed state rather than creating generated-only syntax.
The `.16.4` contract reconstructs emitted Base64 normalized state and returns the same exact fixture value as the
native and generated-plan paths.

Related facts: [[user-observable-backend-cli-parity-contract]],
[[dart-backend-interpreter-first-plan]], [[rust-source-emitter-lane-split]],
[[rust-generated-source-corpus-subset]], [[dart-mdbook-usage-status]].
