---
id: dart-residual-parser-smoke-split
title: Dart residual parser-smoke parity is split into non-PCRE leaves
answers:
  - "what does DART-BACKEND-PARITY.6.2.4.4.0 prove"
  - "what is the next Dart residual parser-smoke leaf"
  - "which Dart failures remain after 7/31 parser smoke"
  - "where are Dart hlink and portmap parser-smoke failures owned"
  - "which Dart residual parser-smoke fixtures passed after hlink parity"
  - "which Dart residual parser-smoke fixtures passed after helper mutation parity"
date: 2026-07-09
status: current
tags: [dart, corpus, parser-smoke, task-tree, DART-BACKEND-PARITY]
evidence: "docs/tasks/DART-BACKEND-PARITY.md records DART-BACKEND-PARITY.6.2.4.4.0 as the split of the 7/31 post-.6.2.4.3 diagnostic boundary. DART-BACKEND-PARITY.6.2.4.4.1 then closes portmap/action-edge child result shape by adding Dart `array(flat*)` list-context splicing; all five portmap fixtures and `vhdl_library_use` pass, and the diagnostic window is 13/31 green. DART-BACKEND-PARITY.6.2.4.4.2 closes hlink delimiter/capture parity by refreshing Dart `retv` from `call(...)` and making append-style mutations update scalar-held lists; all five hlink fixtures and `tablegrep_simple_term` pass, and the diagnostic window is 19/31 green. DART-BACKEND-PARITY.6.2.4.4.3 closes helper mutation/text-normalization parity by adding statement-form scalar regex mutation, explicit split target replacement, and entry/local line helpers; `simenv_multiline_value`, `lib_reader_sattribute`, and `lib_reader_cattribute` pass, and the diagnostic window is 22/31 green. The next leaf is .6.2.4.4.4 for remaining legacy structural smoke outputs; .6.2.4.4.5 owns residual closeout; PCRE structural regex blockers stay under .6.2.4.6."
reverify: "rg -n 'DART-BACKEND-PARITY\\.6\\.2\\.4\\.4\\.(0|1|2|3|4|5)|22/31|PCRE structural' docs/tasks/DART-BACKEND-PARITY.md docs/TASK_TREE.md MEMORY.md"
---

`DART-BACKEND-PARITY.6.2.4.4.0` is a docs-only recovery split after the
recursive/default-mode bridge moved the shipped-spec parser-smoke diagnostic
window to 7/31 green.

`DART-BACKEND-PARITY.6.2.4.4.1` closes portmap/action-edge child result shape
parity and also turns `vhdl_library_use` green through the same Dart
`array(flat*)` list-context splice fix. The diagnostic window is now 13/31
green.

`DART-BACKEND-PARITY.6.2.4.4.2` closes hlink delimiter/capture parity and also
turns `tablegrep_simple_term` green through the same scalar-held append fix. The
diagnostic window is now 19/31 green.

`DART-BACKEND-PARITY.6.2.4.4.3` closes helper mutation/text-normalization
parity. `simenv_multiline_value`, `lib_reader_sattribute`, and
`lib_reader_cattribute` pass through statement helper mutation, explicit split
target replacement, and entry/local line helpers. The diagnostic window is now
22/31 green.

The next implementation leaf is `DART-BACKEND-PARITY.6.2.4.4.4`, which owns
remaining legacy structural smoke outputs. Sibling leaves own residual closeout.
Deeper PCRE structural regex constructs remain out of this residual group and
stay routed to
`DART-BACKEND-PARITY.6.2.4.6`.

Related facts: [[dart-shipped-corpus-smoke-split]],
[[dart-recursive-dispatch-rule-local-scope]], [[dart-array-flat-list-context-splice]],
[[dart-hlink-scalar-held-array-append]], [[dart-helper-action-surface-bridge]],
[[dart-statement-helper-mutation-parity]], [[dart-regex-dialect-bridge]],
[[rust-perl-output-oracle]].
