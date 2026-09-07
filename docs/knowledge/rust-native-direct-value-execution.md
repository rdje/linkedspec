---
id: rust-native-direct-value-execution
title: Rust exposes direct top-rule value execution with per-invocation entry selection
answers:
  - how does Rust return a LinkedSpec top rule value directly
  - which execution seed fields are in current Rust ExecutionOptions
  - what is Rust ExecutionOptions
  - how does Rust select an entry rule without mutating CompiledSpec
  - can Rust globally override seek or consume per invocation
  - does Engine execute still return the accumulator wrapper
  - why did the Rust CLI advance from 29 to 41 cases
  - does Rust hash constructor preserve nested hashes
  - when does Rust hash constructor splice a hash
date: 2026-09-07
status: current
tags: [rust, runtime, cli, top-rule, parse-mode, hash, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.2.2 introduced ExecutionOptions/execute_value, per-context global mode, explicit hash splicing, and a 41/61 CLI baseline. FUTURE-PARITY-BACKLOG.9.1.4.6 removes the global option/runtime state: ExecutionOptions then retained entry_rule and direct execution derived policy from each entered rule, reaching the reference-owned 63/63 primary projection in both environments. Later observation and execution-seed fields are described below."
reverify: "rg -n 'pub struct ExecutionOptions|pub fn execute_value|is_hash_context_splice_arg' rust/linkedspec-runtime/src/{engine,runtime}.rs; ! rg -n 'with_parse_mode|effective_parse_mode|parse_mode_override' rust/linkedspec-runtime/src/{engine,runtime}.rs; bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime execute_value --lib; bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime hash_constructor_only_splices_explicit_flat_hash_args --lib"
---

`linkedspec_runtime::engine::ExecutionOptions` currently carries optional entry-rule selection and a typed
semantic-observation sink, plus two opaque seeds for bounded child parsing and staged-AST enrichment. The
seed-installation builders are doc-hidden; their accessors are crate-private.
`Engine::execute_value(input, &options)` creates a fresh `RuntimeContext`, enters the selected rule (or the
compiled top rule), derives cursor policy from every rule as it is entered, and returns that rule's `RuntimeValue`
as JSON directly. The companion `execute_value_with_trace` and
`execute_value_with_trace_emitter` methods retain rich native tracing. Invalid selected rules diagnose rather than
silently falling back. `CompiledSpec` is not mutated, so one engine can be reused safely with different entry
selections. There is no caller-global seek/consume override.

The existing `Engine::execute` API intentionally remains backward compatible and returns the accumulator array.
Primary commands and new native consumers that need the backend-neutral parser contract use `execute_value`; they
must not guess by unwrapping one-element JSON arrays.

The same slice corrected a related Rust-only nested-value drift exposed by the shared CLI fixture. `hash(key,
value, ...)` now preserves an ordinary hash-valued `value` as a nested object. Only explicit `flat(...)` or
`flat_hash(...)` arguments splice entries into the surrounding constructor, matching the already-documented
Perl/Dart/Julia behavior. This slice established the historical 41/61 direct-result baseline; `.1.5.2.3` subsequently added the
canonical CLI trace projection and reached 61/61 at that milestone. Those counts are historical.

Related facts: [[rust-perl-output-oracle]], [[rust-primary-cli-mechanism-audit]],
[[user-observable-backend-cli-parity-contract]], [[julia-runtime-hash-helpers]],
[[dart-runtime-hash-helpers]], [[canonical-primary-cli-trace-protocol]],
[[rust-canonical-primary-cli-trace]].

## September 7 engine-prefix checkpoint

`SESSION-STARTUP-READING.3.3.14` reads engine lines 1–394 (13,248 bytes), through
the nested-write failure variants. It confirms all four private option fields,
builders/accessors and derived clone/equality behavior. Constructor and execution
paths continue in `.3.3.15` and later slices; reading these definitions alone does
not establish every invocation route.

The prefix also defines ordered target/slot identity checking, explicit action-family
iteration collection, strict ASCII decimal/finite numeric conversion, diagnostic/logical/
gap arity checks, and evaluated key/index segments. Fresh neutral numeric proof passes
55 cases and eighteen helpers; delivery/order callsites remain with their later owners.

## September 7 invocation-route reading

`SESSION-STARTUP-READING.3.3.16` reads engine lines 1895–3394. Native direct-value
execution starts the staged seed, installs observation and bounded-child authority,
validates typed writes and slot identities, then resolves and enters the selected rule.
Generated option-bearing contexts likewise start fresh authority and validate slot
identities; source-emitter validation owns typed-write checks before emission and
after generated JSON decode. These generated contexts expect the validated plan from
their caller; this does not claim an additional typed-write check inside each context.

Legacy native `execute` creates a fresh context without invocation options and returns
the accumulator. Generated compatibility and direct-value contexts retain their distinct
projections; the trace-role adapter with source identity selects direct value. Successful
parent entry emits its optional semantic result before staged enrichment completes.
Entry resolution leaves authored compiled state unchanged. The next reading window
continues at the native regex loop; native carrier counts remain dated evidence.
