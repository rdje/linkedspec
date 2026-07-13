---
id: spec-facing-aggregate-selector-retirement-inventory
title: "Exact array(name) and hash(name) selectors are scheduled for removal through bare typed bindings"
answers:
  - "are array name and hash name selector forms going away"
  - "is aggregate selector removal still unresolved"
  - "how many spec files still use array identifier or hash identifier"
  - "why can array name not be mechanically replaced yet"
  - "what replaces push array name and split array name"
  - "does one LinkedSpec binding require one host storage map"
  - "which task removes spec facing aggregate selectors"
date: 2026-07-12
status: current
tags: [language, bindings, array, harray, compatibility, retirement, FUTURE-PARITY-BACKLOG]
evidence: "Director clarification 2026-07-12 settles removal. The corrected baseline is 600 exact selector-shaped calls across 82 tracked .spec files, including 210 across 15 shipped specs; earlier 651/227 figures included 51/17 flat_array(name) suffixes. Leaves .12.1.2-.6 enable bare behavior on every backend, .12.1.7.1 removes 210 shipped occurrences, and .12.1.7.2 removes the remaining 390 from 67 file-backed fixtures/corpora. Every tracked .spec file now scans at zero; embedded source strings remain under .12.1.7.3 before hard rejection."
reverify: "git grep -o -P '\\b(?:array|hash)\\(\\s*[A-Za-z_][A-Za-z0-9_]*\\s*\\)' -- '*.spec' | wc -l && perl -Iperl -MLinkedSpec -e 'for my $s (q{push(array(items), value)}, q{push(items, value)}, q{split(array(parts), raw, /,/)}, q{split(parts, raw, /,/)}) { print "$s => ", LinkedSpec::call_spec_handler_subst("Top", $s), "\\n" }'"
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
- every tracked `.spec` file now scans at zero; embedded spec strings remain owned by `.12.1.7.3`;
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
file-backed migration `.12.1.7.1-.2` is complete, embedded-source `.12.1.7.3` is next, and hard rejection follows
all source migration.

Related facts: [[uniform-expression-compatibility-retirement-doctrine]],
[[uniform-binding-neutral-contract]],
[[terse-duck-typed-assignment-perl-reference]], [[terse-rust-duck-typed-assignment-parity]],
[[terse-mutation-surface-ground-truth]].
