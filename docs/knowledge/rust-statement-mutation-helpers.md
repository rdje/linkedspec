---
id: rust-statement-mutation-helpers
title: Rust distinguishes pure string/array value helpers from statement-form mutation helpers for regex substitution and split
answers:
  - "does Rust support substr scalar target regex substitution"
  - "what is the difference between substr value slicing and substr regex substitution"
  - "does regex_subst mutate scalar targets in Rust"
  - "does split array target mutate arrays in Rust"
  - "why did lib_reader still have quoted or null fields after RUST-PARITY.7.3.4.1"
  - "what did RUST-PARITY.7.3.4.4 implement"
date: 2026-07-03
status: confirmed
tags: [rust, runtime, helpers, mutation, lib_reader, RUST-PARITY]
evidence: "RUST-PARITY.7.3.4.4 added Rust runtime detection for statement-form `substr(scalar(target), pattern, replacement, flags)` / `regex_subst(...)` before pure value `substr`, mutating the scalar target with regex replacement (`g` global; `i/m/s/x` inline flags; `o` no-op). It also added statement-form `split(array(target), scalar(source), delimiter)` before pure value `split`, replacing the array target. Focused integration tests cover scalar regex substitution, `$1` replacement, split mutation, and real `specs/lib_reader.spec` sattribute/cattribute execution; `lib_reader_sattribute` and `lib_reader_cattribute` are checked-in oracle fixtures."
reverify: "rg -n 'regex_subst_call_parts|split_statement_call_parts|rust_parity_7_3_4_4|lib_reader_sattribute|lib_reader_cattribute|Statement-style regex substitution' rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/tests/integration_test.rs tools/gen_oracle_corpus.pl docs/linkedspec-book/src docs/tasks/RUST-PARITY.md"
---

# Rust Statement Mutation Helpers

Confirmed 2026-07-03 (`RUST-PARITY.7.3.4.4`).

Rust now treats these as mutation statements:

- `substr(scalar(target), pattern, replacement, flags)`
- `regex_subst(scalar(target), pattern, replacement, flags)`
- `split(array(target), scalar(source), delimiter)`

This is intentionally separate from pure value helpers:

- `substr(value, start, length?)`
- `split(value, delimiter)`

The shipped `lib_reader.spec` depends on the mutation forms to strip quotes/whitespace
from scalar captures and to split comma-list attributes into a working array.
