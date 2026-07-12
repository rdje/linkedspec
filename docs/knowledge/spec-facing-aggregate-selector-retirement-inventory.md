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
evidence: "Director clarification 2026-07-12 settles removal. FUTURE-PARITY-BACKLOG.12.1.0 inventory finds 651 exact selector-shaped calls across 82 tracked .spec files, including 227 across 15 shipped specs. Parent calls include copy/push/set/is_nonempty/split plus receiver forms. LinkedSpec toolbox lowering proves bare reads and receivers already exist on Perl, but push(items,value) still takes child-rule semantics and split(parts,source,delimiter) is unsupported. Backend owner scans locate Perl ValueExpr/MethodLowering/EmitContext, Rust target resolvers and constructor branches, Dart/Julia target-name helpers, and Lua target_descriptor/constructor branches."
reverify: "git grep -E -o 'array\\([[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\\)|hash\\([[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\\)' -- '*.spec' | wc -l && perl -Iperl -MLinkedSpec -e 'for my $s (q{push(array(items), value)}, q{push(items, value)}, q{split(array(parts), raw, /,/)}, q{split(parts, raw, /,/)}) { print "$s => ", LinkedSpec::call_spec_handler_subst("Top", $s), "\\n" }'"
---

# Spec-facing aggregate-selector retirement inventory

The decision is final: exact `.spec` forms `array(IDENTIFIER)` and `hash(IDENTIFIER)` will not remain as namespace
selectors, typed reads, mutation targets, or mutation authority. Active `FUTURE-PARITY-BACKLOG.12.1` implements
and retires them before Rust callable-codeblock parity or resumed Lua feature work. Only the treatment of ordinary
non-selector constructor calls remains separately classified.

The current tracked surface is large enough to require ordered migration rather than blind replacement:

- 651 exact selector-shaped occurrences across 82 tracked `.spec` files;
- 227 occurrences across 15 shipped `specs/*.spec` files;
- common direct parents are `copy` (172), `push` (158), `set` (72), `is_nonempty` (50), and `split` (13);
- 17 occurrences are direct receiver expressions.

The replacement language is one observable binding per identifier. A bare name reads its current scalar, array,
harray, or codeblock value; mutation dispatches from the callable contract plus runtime value, and absent mutable
bindings auto-create only where the contract says so. `set(name, value)` returns the post-assignment value of
`name`. This public model does not require a backend to use one physical host map: internal storage is permitted as
an implementation detail so long as no alternate namespace is observable.

Migration cannot yet be purely mechanical. On the Perl reference, `copy(items)`, `items.first()`, and typed
`set(items, value)` already have selector-free forms, but `push(items, value)` currently selects child-rule push
semantics and `split(parts, source, delimiter)` is unsupported. Neutral leaf `.12.1.1` now fixes static-rule
precedence, bare mutation, three-argument mutable split, expression results, exact diagnostics, and constructor
classification in `linkedspec-uniform-binding-v1`. Source migration follows only after all five backends execute
those alternatives; hard rejection follows migration.

Related facts: [[uniform-expression-compatibility-retirement-doctrine]],
[[uniform-binding-neutral-contract]],
[[terse-duck-typed-assignment-perl-reference]], [[terse-rust-duck-typed-assignment-parity]],
[[terse-mutation-surface-ground-truth]].
