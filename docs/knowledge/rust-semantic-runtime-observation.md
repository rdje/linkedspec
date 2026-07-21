---
id: rust-semantic-runtime-observation
title: Rust runtime semantic observations are typed caller-owned evidence captured during normal execution
answers:
  - "how do I capture Rust semantic runtime events"
  - "what is RuntimeSemanticObservationSink"
  - "what does Rust with_execution_observation do"
  - "does a semantic query execute the Rust parser"
  - "where does exact Rust runtime regex slot identity come from"
  - "how is the Rust semantic runtime input identity hashed"
  - "are Rust semantic observations separate from trace and diagnostics"
  - "does a Rust observer panic preserve exact identity"
  - "which Rust runtime semantic routes are equivalent"
  - "what is the twentieth Rust semantic response digest"
  - "does failed Rust execution emit a completed semantic result"
  - "is Rust semantic introspection admitted after runtime observations"
date: 2026-07-21
status: current exact runtime observation/query surface; subsequently composed into admitted Rust surface
tags: [rust, semantic-introspection, runtime, observation, immutability, generated-source, trace, diagnostics]
evidence: rust/linkedspec-runtime/src/semantic_observation.rs; rust/linkedspec-runtime/src/semantic_index/runtime_projection.rs; rust/linkedspec-runtime/src/engine.rs; rust/linkedspec-runtime/src/runtime.rs; rust/linkedspec-runtime/tests/semantic_index_runtime_observation.rs; FUTURE-PARITY-BACKLOG.10.4.5
reverify: cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_index_runtime_observation
---

One Rust parser invocation may install a `RuntimeSemanticObservationSink` in `ExecutionOptions`. The synchronous
typed callback receives `RuntimeSemanticObservationEvent` values. Exact `regex_slot_selected` executing rule,
authored target rule, zero-based regex index, and post-match Unicode-scalar position come from the shared direct and
generated selected-slot seams. One final successful entry `rule_result` comes from each option-bearing execution
wrapper. With no sink, the runtime returns before event allocation or input hashing. A sink panic unwinds with the
caller's exact payload identity rather than becoming a parser, trace, or diagnostic failure.

After successful execution, `SemanticIndex::with_execution_observation(&events)` validates the contract, typed
field combinations, exactly one final succeeded entry result, selected rule-to-slot topology, and stable input
identity. It clones the base normalized projection, adds canonical execution/event records and `observed_as`
relations, and returns a new opaque immutable index. The base remains static; later caller mutation of the event
vector or query response cannot alter either snapshot. Querying receives only cloned projection data and never
compiles or executes.

The canonical `runtime.input` bytes are `ab\n`. Slot 0/1 appear at scalar positions 1/2, the final result appears at
position 2, and its exact input identity is
`input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece`. The derived
`runtime_events` response matches digest `36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`
through direct, loaded, reconstructed, generated-plan, source-emitter, traced/untraced, and independently compiled
emitted-module routes. Seven focused tests also prove malformed rejection, trace/diagnostic neutrality, Unicode
positions, exact observer panic identity, quiet execution, and no final result after failed entry selection.

This observation leaf did not itself promote Rust. `FUTURE-PARITY-BACKLOG.10.4.6` subsequently composes it with
the source/static/calls/query owners through one exact consumer and advances only Rust to rollout 3/9 and native
admission 2/6.

See [[rust-semantic-query-evaluator]], [[rust-semantic-static-projection]],
[[rust-semantic-call-staged-projection]], [[perl-semantic-runtime-observation]], and
[[semantic-introspection-neutral-contract]], and [[rust-semantic-introspection-admission]].
