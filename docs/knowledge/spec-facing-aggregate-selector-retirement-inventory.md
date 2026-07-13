---
id: spec-facing-aggregate-selector-retirement-inventory
title: "Exact array(name) and hash(name) selectors are migrated everywhere and hard-rejected on Perl, Rust, and Dart"
answers:
  - "are array name and hash name selector forms going away"
  - "is aggregate selector removal still unresolved"
  - "how many spec files still use array identifier or hash identifier"
  - "why can array name not be mechanically replaced yet"
  - "what replaces push array name and split array name"
  - "does one LinkedSpec binding require one host storage map"
  - "which task removes spec facing aggregate selectors"
  - "are embedded executable selector sources migrated"
  - "which backend rejects aggregate selectors now"
date: 2026-07-12
status: current
tags: [language, bindings, array, harray, compatibility, retirement, FUTURE-PARITY-BACKLOG]
evidence: "Director clarification 2026-07-12 settles removal. The corrected baseline is 600 exact selector-shaped calls across 82 tracked .spec files, including 210 across 15 shipped specs; earlier 651/227 figures included 51/17 flat_array(name) suffixes. Leaves .12.1.2-.6 enable bare behavior on every backend, .12.1.7.1 removes 210 shipped occurrences, .12.1.7.2 removes the remaining 390 from 67 file-backed fixtures/corpora, and .12.1.7.3 removes 1,356 positive occurrences from 25 embedded test/tool/backend source owners. FUTURE-PARITY-BACKLOG.12.1.8.1, .12.1.8.2, and .12.1.8.3.1 hard-reject exact selector nodes on Perl, Rust, and Dart. The executable scanner reports zero positives and 14 classified rejection-test/implementation occurrences."
reverify: "python3 tools/check_executable_aggregate_selector_sources.py && prove -Iperl t/uniform_binding_contract.t t/trace_emit_context_bridge.t"
---

# Spec-facing aggregate-selector retirement inventory

The decision is final: exact `.spec` forms `array(IDENTIFIER)` and `hash(IDENTIFIER)` will not remain as namespace
selectors, typed reads, mutation targets, or mutation authority. Active `FUTURE-PARITY-BACKLOG.12.1` implements
and retires them before Rust callable-codeblock parity or resumed Lua feature work. Only the treatment of ordinary
non-selector constructor calls remains separately classified.

The current tracked surface is large enough to require ordered migration rather than blind replacement:

- 600 exact selector-shaped occurrences across 82 tracked `.spec` files at the pre-migration baseline;
- 210 occurrences across 15 shipped `specs/*.spec` files, all removed by `.12.1.7.1`;
- 390 occurrences across 67 file-backed fixture/corpus specs, all removed by `.12.1.7.2`;
- every tracked `.spec` file and executable embedded source now scans at zero;
- the embedded baseline was 1,356 positive occurrences across 25 source owners; the strengthened whitespace-aware
  scanner reports zero positives and 19 classified implementation, diagnostic, and rejection-test occurrences;
- the original 651/227 counts were 51/17 too high because their regex also matched the `array(name)` suffix inside
  ordinary `flat_array(name)` calls;
- common direct parents are `copy` (172), `push` (158), `set` (72), `is_nonempty` (50), and `split` (13);
- 17 occurrences are direct receiver expressions.

The replacement language is one observable binding per identifier. A bare name reads its current scalar, array,
harray, or codeblock value; mutation dispatches from the callable contract plus runtime value, and absent mutable
bindings auto-create only where the contract says so. `set(name, value)` returns the post-assignment value of
`name`. This public model does not require a backend to use one physical host map: internal storage is permitted as
an implementation detail so long as no alternate namespace is observable.

Neutral leaf `.12.1.1` fixes static-rule precedence, bare mutation, three-argument mutable split, expression results,
exact diagnostics, and constructor classification in `linkedspec-uniform-binding-v1`. Perl/Rust/Dart/Julia/Lua
leaves `.12.1.2` through `.12.1.6` now execute those alternatives. Migration remains ordered rather than blind
because selector-shaped one-argument calls must be classified as reads/targets versus intended constructors;
source migration `.12.1.7.1-.3` is complete. Perl `.12.1.8.1`, Rust `.12.1.8.2`, and Dart `.12.1.8.3.1` now
hard-reject exact selector nodes; Julia/Lua rejection remains dependency-ordered under `.12.1.8.4-.5` after Dart
full-gate closure.

Related facts: [[uniform-expression-compatibility-retirement-doctrine]],
[[uniform-binding-neutral-contract]],
[[perl-aggregate-selector-compile-rejection]],
[[rust-aggregate-selector-compile-rejection]], [[dart-aggregate-selector-compile-rejection]],
[[terse-duck-typed-assignment-perl-reference]], [[terse-rust-duck-typed-assignment-parity]],
[[terse-mutation-surface-ground-truth]].
