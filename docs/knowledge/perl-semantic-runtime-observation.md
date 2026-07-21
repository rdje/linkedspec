---
id: perl-semantic-runtime-observation
title: Perl runtime semantic observations are typed caller-owned evidence captured during normal parsing
answers:
  - "how do I capture Perl semantic runtime events"
  - "what is semantic_observation_sink"
  - "what does with_execution_observation do"
  - "does a semantic query execute the Perl parser"
  - "where does exact runtime regex slot identity come from"
  - "how is the semantic runtime input identity hashed"
  - "does the runtime input digest include a trailing newline"
  - "are semantic observations separate from trace and diagnostic output"
  - "does observer failure preserve exact exception identity"
  - "which Perl runtime semantic routes are equivalent"
  - "what is the twentieth Perl semantic response digest"
  - "is Perl semantic introspection admitted after runtime observations"
date: 2026-07-21
status: current runtime observation/query surface; composed admission pending
tags: [perl, semantic-introspection, runtime, observation, immutability, generated-source, trace, diagnostics]
evidence: perl/LinkedSpec/RuntimeSemanticObservation.pm; perl/LinkedSpec/SemanticRuntimeProjection.pm; perl/LinkedSpec/HandlerVariantEmitter.pm; perl/LinkedSpec/Compiler.pm; t/semantic_index_perl_runtime_observation.t; FUTURE-PARITY-BACKLOG.10.3.5
reverify: PERL5LIB= prove -Iperl t/semantic_index_perl_runtime_observation.t
---

Normal Perl parser invocation may receive `{semantic_observation_sink => sub { ... }}`. The callback synchronously
receives native `LinkedSpec::RuntimeSemanticObservationEvent` objects. Exact `regex_slot_selected` target rule,
authored regex index, and post-match position come from `HandlerVariantEmitter`'s shared selected-slot identity
seam; one final `rule_result` comes from the live or generated entry wrapper. Semantic delivery has descriptor
slots and exact control-error marking separate from both text trace and `diagnostic_sink`. With no sink, emitters
return without event allocation or input hashing. A sink exception is rethrown with exact caller object identity.

After successful parsing, `$index->with_execution_observation(\@events)` validates native type/schema, final entry
identity, and selected rule-to-slot topology, then returns a new opaque immutable index. It clones the base static
projection, adds `execution`/`event` records plus `observed_as` relations, and reuses static rule/edge value shapes
and canonical ordering. It never infers facts from host return types. The base index stays static; later event or
response mutation cannot alter the derived snapshot; querying never compiles or executes.

The canonical `runtime.input` bytes are `ab\n`. Slot 0/1 appear at positions 1/2, the final result appears at
position 2, and the input identity hashes all three bytes as
`input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece`. The derived
`runtime_events` response matches digest `36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`
through direct, loaded-spec, portable-loader, captured generated direct/Get, independently loaded generated
direct/traced, and validated reconstructed-plan roles. The focused test has 106 assertions and proves malformed/
foreign rejection plus trace/diagnostic neutrality. Composed Perl admission remains `.10.3.6`, so rollout and
admission remain 1/9 and 0/6.

Related facts: [[perl-semantic-query-evaluator]], [[perl-semantic-introspection-authority-map]],
[[perl-duplicate-regex-slot-identity-admission]], [[diagnostic-output-neutral-contract]],
[[trace-cross-variant-capability-contract]].
