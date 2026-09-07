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
  - "when does Rust emit the entry result relative to staged AST enrichment"
  - "is Rust semantic introspection admitted after runtime observations"
date: 2026-09-07
status: current exact runtime observation/query surface; subsequently composed into admitted Rust surface
tags: [rust, semantic-introspection, runtime, observation, immutability, generated-source, trace, diagnostics]
evidence: rust/linkedspec-runtime/src/semantic_observation.rs; rust/linkedspec-runtime/src/semantic_index/runtime_projection.rs; rust/linkedspec-runtime/src/engine.rs; rust/linkedspec-runtime/src/runtime.rs; rust/linkedspec-runtime/tests/semantic_index_runtime_observation.rs; FUTURE-PARITY-BACKLOG.10.4.5
reverify: bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test semantic_index_runtime_observation
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

## September 7 entry-result ordering reading

`SESSION-STARTUP-READING.3.3.16` confirms the option-bearing engine wrappers
emit `rule_result` only after successful parent rule execution, then call staged-AST
completion. It records parent-entry success; it is not a guarantee that later enrichment
or trace delivery succeeds. Failed entry selection returns before that event. The July
native assertions above remain dated; no combined observation/enrichment failure is
freshly executed here. Fresh neutral proof passes six fixture groups, twenty exact
queries, 128 mutations and all nine rollout/six admission legs.

See [[rust-semantic-query-evaluator]], [[rust-semantic-static-projection]],
[[rust-semantic-call-staged-projection]], [[perl-semantic-runtime-observation]], and
[[semantic-introspection-neutral-contract]], and [[rust-semantic-introspection-admission]].

## September 7 complete derivation reading

`SESSION-STARTUP-READING.3.3.32` reads all 273 lines of runtime_projection.rs. It requires a compiled
static snapshot with no prior execution, validates each typed event, and accepts exactly one final succeeded
entry-rule result with a lowercase 64-hex SHA-256 input identity. Slot events cannot carry result identity/status;
result events cannot carry slot identity. Selected rule/slot pairs must exist in the static selects_regex topology.
The first matching selecting edge supplies that event's static value shape; final result shape comes from the
entry rule. The cloned model gains one execution plus ordered event records and observed_as relations with
static evidence ids, then canonicalizes. Caller-supplied positions are retained as typed values; this projector
does not possess input bytes to re-verify a digest or replay the observed execution. This source reading does not
claim fresh execution of the seven historical native tests. Current neutral 6/20/128 remains green.

## September 7 complete event/sink definition reading

`SESSION-STARTUP-READING.3.3.33` reads all 133 lines of semantic_observation.rs. Constructors separate
selected-slot fields from final succeeded-result fields; final identity hashes the exact UTF-8 input bytes to
lowercase SHA-256. The synchronous FnMut sink is shared by Rc/RefCell clones, compares callback allocation
identity, and hides callback details in Debug. Emit invokes the borrowed callback directly, with no error
translation; this is source confirmation, not a new native panic/reentrancy execution result.
