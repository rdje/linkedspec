---
id: rust-with-callback-name-collision
title: Rust distinct nested with callbacks collide in the active helper-name stack
answers:
  - why does nested Rust with report codeblock_recursion_unsupported
  - can two distinct Rust contextual with blocks run nested
  - does Rust callback recursion compare helper names or callable identities
  - which task owns Rust with false recursion and callback identity
date: 2026-10-27
status: P1 owned31.6.1 after bounded backend31 children, before unrelated selection/parent admission
tags: [rust, with, codeblock, recursion, identity, defect]
evidence: "TYPE31.2 original five-test producer/log/nested source retained in with-hash-rust-intake.json.gz at clean0f7ccfe81. First-native assertion is the observed RED; later routes are not inferred RED."
reverify: "Restore the exact retained nested test under TYPE-REFERENCE-BOOK.1.2.23.3.31.6.1, then use tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test with_hash_results nested_hash_results_keep_inner_and_outer_value_scopes."
---

Distinct nested contextual with blocks reject as codeblock_recursion_unsupported,
callable_name with, cycle [with,with], rather than producing outside/inside and
restoring outer value. The unchanged frozen Hash flow and pure-function/indexed
reader fences pass. This is independent of the scalar wrong-consumer guard repair.

Engine execute_codeblock_value passes the invocation helper name to RuntimeContext
enter_codeblock; the active String stack compares that name and rejects a second
with even when its literal/body is distinct. Existing real direct/mutual recursion
must still reject with contracted diagnostics and cleanup. Disabling the guard or
merely renaming every invocation would hide true helper-mediated cycles.

31.6.1 owns identity-authority reconciliation and a bounded correct repair before
unrelated selection or parent31/full23.4 admission. Exact original test and nested
reproduction remain recoverable in the packet; the known failing case is separated
from the passing guard fixture rather than silently ignored or called covered.
Existing [[dart-callback-helper-recursion-identity-gap]] and
[[julia-callback-helper-recursion-identity-gap]] retain independent owners; no Lua/
Perl or full-backend identity failure is inferred. No runtime identity/schema fix
or nested scope admission is claimed by31.2.1.
