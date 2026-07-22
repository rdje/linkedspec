---
id: dart-semantic-runtime-observation-authority-map
title: Dart runtime semantics use typed post-match and successful-result capture seams
answers:
  - "does Dart already have a semantic runtime observation sink"
  - "where must Dart capture regex slot semantic events"
  - "where must Dart capture final semantic result events"
  - "should Dart semantic observations reuse trace output"
  - "should Dart semantic observations reuse diagnostic output"
  - "what happens when no Dart semantic observation sink is installed"
  - "how must Dart semantic observer callback failures propagate"
  - "why do Dart generated wrappers need semantic observer failure passthrough"
  - "which Dart execution routes reuse the runtime observation seams"
  - "how does Dart derive an observed semantic index"
  - "can Dart semantic query execute the parser"
  - "what is the Dart semantic runtime observation implementation split"
date: 2026-07-22
status: current typed direct-engine capture; immutable observed-index derivation active next
tags: [dart, semantic-introspection, runtime, observation, trace, diagnostics, generated-source]
evidence: dart/lib/src/runtime/semantic_observation.dart; dart/lib/src/runtime/interpreter.dart; dart/lib/src/source_emitter.dart; dart/lib/src/io/spec_loader.dart; dart/test/semantic_index_runtime_observation_test.dart; capability_conformance/semantic_introspection_model.json; docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.5.5.0-.1
last_verified: 2026-07-22
reverify:
  - "rg -n 'RuntimeDiagnosticOutputSink|_recordRegexSlotSelected|RuntimeParseResult|executeGeneratedWithPlan|semanticObservationSink' dart/lib/src/runtime/interpreter.dart"
  - "rg -n '_GeneratedDiagnosticOutputSinkFailure|executeGeneratedParserV2|executeGeneratedParserWithTraceV2|Object\\? execute\\(' dart/lib/src/source_emitter.dart"
  - "sed -n '134,150p' dart/lib/src/io/spec_loader.dart"
  - "sed -n '143,178p' capability_conformance/semantic_introspection_model.json"
  - "sed -n '236,248p' capability_conformance/semantic_introspection_contract.json"
  - "sed -n '1,140p' rust/linkedspec-runtime/src/semantic_observation.rs"
---

# Dart semantic runtime observation authority map

## Current fact

Dart had no semantic runtime-observation sink at the `.10.5.5.0` audit boundary. `.10.5.5.1` now exports the exact
typed v1 event/sink API and threads it through the direct engine topology. Trace and diagnostic output remain
separate optional runtime products; neither is a normalized semantic event authority.

The exact regex-slot seam is the audited selection call site, now named `_recordRegexSlotSelected(...)`, in
`dart/lib/src/runtime/interpreter.dart`, not the trace text it emits. Each call happens only after a regex match
exists and any ordered structural identity check succeeds, and before `_acceptRegexMatch(...)` applies match
effects. The seam has the executing `CompiledRule`, every selected `CompiledRegexSlotIdentity` target/index, and
the post-match Unicode-scalar cursor through the execution context.

The exact final-result seam is the successful public `_parse(...)` wrapper immediately after it constructs
`RuntimeParseResult`. It has the resolved entry label, final Unicode-scalar cursor, exact input, and successful
result. Failed entry execution must not emit a final `rule_result` event.

## Required native boundary

The public API exposes immutable typed `regex_slot_selected` and `rule_result` events under
`linkedspec-semantic-execution-observation-v1`, delivered synchronously to an optional invocation-local callback.
It is distinct from `LinkedSpecTraceEmitter` and `RuntimeDiagnosticOutputSink`. Explicit null guards precede event
construction and final input hashing. A caller callback failure escapes as the exact original object with its
original stack after any active trace scope is closed.

Direct `parse`/`execute`, their traced convenience forms, `LoadedCompiledSpec.createEngine()`, reconstructed
`CompiledSpec`, and the validated generated-plan engine entry now reuse the same `_parse` and rule-execution seams.
The public generated/source-emitter adapters need extra protection: they currently catch arbitrary `Object` values
and translate them into `GeneratedSourceException`. Observer failures therefore need a private wrapper/passthrough
parallel to `_GeneratedDiagnosticOutputSinkFailure`; otherwise adding the optional parameter would silently change
caller exception identity.

## Required immutable derivation boundary

Captured host values are evidence, not semantic records by themselves. `SemanticIndex.withExecutionObservation`
must accept caller-retained typed events, validate the versioned contract and complete topology, and map them only
through the base index's detached static rule, regex-slot, and `selects_regex` evidence. It derives value shapes
from static records, never from the host result object. Exactly one successful final event must occur last. The
derived index adds one canonical execution record, ordered event records, and `observed_as` relations to a new
snapshot with `has_execution = true`; the base index stays static and immutable.

Semantic query remains projection-only. It can read the derived snapshot but cannot execute a parser, enable
trace, install a sink, hash a new input, or mutate either index.

## Dependency order

- `.10.5.5.1`: complete public typed events/sink and direct, loaded, reconstructed, traced-convenience, and
  generated-plan engine capture.
- `.10.5.5.2`: active validated immutable derivation and exact twentieth response digest.
- `.10.5.5.3`: generated-plan, emitted-source, traced/untraced propagation and callback identity.
- `.10.5.5.4`: complete composition/signoff and parent closure without Dart admission promotion.

## Exact neutral anchor

The governed input is the three UTF-8 bytes `61 62 0a` (`ab\n`). Its identity is
`input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece`. The expected events select
`Top[0]` at scalar position 1, select `Top[1]` at position 2, then complete `Top` at position 2. Query case
`runtime_events` must retain response digest
`36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`.
