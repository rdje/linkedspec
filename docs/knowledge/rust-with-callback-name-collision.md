---
id: rust-with-callback-name-collision
title: Rust callback frames separate helper labels from active callback identity
answers:
  - why does nested Rust with report codeblock_recursion_unsupported
  - can two distinct Rust contextual with blocks run nested
  - does Rust callback recursion compare helper names or callable identities
  - which task owns Rust with false recursion and callback identity
date: 2026-10-27
status: bounded31.6.1 repaired; independent other backends and full context admission remain open
tags: [rust, with, codeblock, recursion, identity, defect]
evidence: "TYPE31.2 original five-test producer/log/nested source retained in with-hash-rust-intake.json.gz at clean0f7ccfe81. First-native assertion is the observed RED; later routes are not inferred RED."
reverify: "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test callback_identity --test with_hash_results"
---

At clean0f7ccfe81, distinct nested contextual with blocks reject as codeblock_recursion_unsupported,
callable_name with, cycle [with,with], rather than producing outside/inside and
restoring outer value. The unchanged frozen Hash flow and pure-function/indexed
reader fences pass. This is independent of the scalar wrong-consumer guard repair.

The original Engine execute_codeblock_value passes the invocation helper name to RuntimeContext
enter_codeblock; the active String stack compares that name and rejects a second
with even when its literal/body is distinct. Existing real direct/mutual recursion
must still reject with contracted diagnostics and cleanup. Disabling the guard or
merely renaming every invocation would hide true helper-mediated cycles.

31.6.1 owns the bounded repair described below before
unrelated selection or parent31/full23.4 admission. Exact original test and nested
reproduction remain recoverable in the packet; the known failing case is separated
from the passing guard fixture rather than silently ignored or called covered.
Existing [[dart-callback-helper-recursion-identity-gap]] and
[[julia-callback-helper-recursion-identity-gap]] retain independent owners; no Lua/
Perl or full-backend identity failure is inferred. No runtime identity/schema fix
or nested scope admission is claimed by31.2.1.

At cleanf101d6def, five first-native callback tests reproduce distinct with/map
false recursion and wrong helper/receiver/opaque cb cycle identity; anonymous
unknown and direct/mutual controls are healthy.31.6.1 now retains private frames
with optional bound name and immutable CodeblockValue data. Existing bound-name
fences remain; matching callback records retain opaque-value cycle safety. Helper
labels alone are not keys. All invocations stay active for unknown-helper errors;
frames pop after success/failure. Bound names flow through with and tree dispatch.

Callback7 and restored with5 pass native/restored/plan. Added typed diagnostic
native/restored check confirms stage/code/callable cb/cycle cb→cb; expanded bound/
anonymous cleanup unit and existing ordered mutual case pass. No eight-field
schema/helper/grammar/capture/deferred/unknown-call rights change. Exact evidence
is callback-identity-rust-intake.json.gz; current bounded authority is
callback-invocation-identity.md. Independent Dart31.6.2/Julia31.6.3 and remaining
scoped31.6.4 follow before unrelated selection/parent admission; full alias/context/
backend identity is not inferred from these finite controls.

Adjacent source-order31.6.5 separately repairs callback values in a caller binding
named value. See [[rust-with-final-callback-snapshot]]: value/source evaluates first,
final callback resolves once before temporary value rebinding, and argument/body
failure effects keep their correct scopes. Identity/source/with controls pass;
no environment capture or compiled-field change.
