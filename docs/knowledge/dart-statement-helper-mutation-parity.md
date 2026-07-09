---
id: dart-statement-helper-mutation-parity
title: Dart statement helper mutation closes simenv and lib_reader parser smokes
answers:
  - "which leaf fixed Dart statement-form substr regex_subst mutation"
  - "does Dart split array target mutation replace explicit targets"
  - "why did Dart lib_reader_sattribute keep quotes"
  - "why did Dart lib_reader_cattribute produce an empty list"
  - "does Dart expose match_line and entry_line helpers"
date: 2026-07-09
status: current
tags: [dart, runtime, helpers, corpus, parser-smoke, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.4.3 updates dart/lib/src/runtime/interpreter.dart so statement-context `substr(...)` and `regex_subst(...)` mutate scalar targets, replacement strings expand `$n` capture placeholders, helper regex flags feed the shared runtime compiler, explicit `split(array(target), source, delimiter)` replaces the aggregate target, and `entry_line` / `entry_col` / `match_line` / `match_col` read entry/local match start locations. Focused runtime tests cover newline-separated statements, helper mutation, split replacement, and line helpers. corpus_manifest_test executes `simenv_multiline_value`, `lib_reader_sattribute`, and `lib_reader_cattribute`; the focused corpus command passes 3/3; the 31-fixture parser-smoke diagnostic window is 22/31 green."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart test/corpus_manifest_test.dart && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case simenv_multiline_value --case lib_reader_sattribute --case lib_reader_cattribute && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31 || true"
---

The failing `lib_reader` fixtures were statement-mutation gaps, not capture
propagation gaps. `lib_reader.spec` uses `substr(...)` to strip quotes from
group names and scalar values, then uses `split(array(value_items), value, /,/)`
to mutate an explicit aggregate target. Dart had pure helper behavior but did
not mutate those targets in statement context.

Dart now handles statement-form scalar regex substitution and explicit split
target replacement. Replacement strings expand `$n` capture placeholders, and
helper flags such as `g`, `i`, `m`, and `s` feed the shared runtime regex
compiler.

The `simenv_multiline_value` fixture also needed line helper coverage. Dart now
exposes entry/local match start line and column helpers.

Related facts: [[rust-statement-mutation-helpers]],
[[dart-residual-parser-smoke-split]], [[dart-shipped-corpus-smoke-split]],
[[dart-hlink-scalar-held-array-append]], [[rust-perl-output-oracle]].
