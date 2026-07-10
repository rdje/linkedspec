---
id: rust-native-direct-value-execution
title: Rust exposes direct top-rule value execution with per-invocation entry and parse-mode controls
answers:
  - how does Rust return a LinkedSpec top rule value directly
  - what is Rust ExecutionOptions
  - how does Rust select an entry rule without mutating CompiledSpec
  - how does Rust globally override seek or consume per invocation
  - does Engine execute still return the accumulator wrapper
  - why did the Rust CLI advance from 29 to 41 cases
  - does Rust hash constructor preserve nested hashes
  - when does Rust hash constructor splice a hash
date: 2026-07-10
status: current
tags: [rust, runtime, cli, top-rule, parse-mode, hash, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.2.2 adds ExecutionOptions/execute_value, effective per-context parse mode, explicit hash splicing, and an exact 41/61 CLI baseline."
reverify: "rg -n 'pub struct ExecutionOptions|pub fn execute_value|effective_parse_mode|is_hash_context_splice_arg' rust/linkedspec-runtime/src/{engine,runtime}.rs; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime execute_value --lib; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime hash_constructor_only_splices_explicit_flat_hash_args --lib"
---

`linkedspec_runtime::engine::ExecutionOptions` carries an optional owned entry-rule label and optional global
`ParseMode`. `Engine::execute_value(input, &options)` creates a fresh `RuntimeContext`, applies the parse-mode
override only to that invocation, enters the selected rule (or the compiled top rule), and returns that rule's
`RuntimeValue` as JSON directly. The companion `execute_value_with_trace` and
`execute_value_with_trace_emitter` methods retain rich native tracing. Invalid selected rules diagnose rather than
silently falling back. `CompiledSpec` is not mutated, so one engine can be reused safely with different options.

The existing `Engine::execute` API intentionally remains backward compatible and returns the accumulator array.
Primary commands and new native consumers that need the backend-neutral parser contract use `execute_value`; they
must not guess by unwrapping one-element JSON arrays.

The same slice corrected a related Rust-only nested-value drift exposed by the shared CLI fixture. `hash(key,
value, ...)` now preserves an ordinary hash-valued `value` as a nested object. Only explicit `flat(...)` or
`flat_hash(...)` arguments splice entries into the surrounding constructor, matching the already-documented
Perl/Dart/Julia behavior. This slice established the 41/61 direct-result baseline; `.1.5.2.3` has since added the
canonical CLI trace projection and brought `linkedspec-rust` to 61/61 unchanged cases.

Related facts: [[rust-perl-output-oracle]], [[rust-primary-cli-mechanism-audit]],
[[user-observable-backend-cli-parity-contract]], [[julia-runtime-hash-helpers]],
[[dart-runtime-hash-helpers]], [[canonical-primary-cli-trace-protocol]],
[[rust-canonical-primary-cli-trace]].
