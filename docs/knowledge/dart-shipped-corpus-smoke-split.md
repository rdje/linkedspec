---
id: dart-shipped-corpus-smoke-split
title: Dart shipped-spec parser-smoke corpus window is split by failure cluster
answers:
  - "what does DART-BACKEND-PARITY.6.2.4.0 prove"
  - "why is the Dart shipped corpus smoke batch split"
  - "which Dart shipped-spec corpus failures are known"
  - "what is the next Dart corpus frontier after the middle batch"
  - "what split follows DART-BACKEND-PARITY.6.2.4.3"
  - "what is the Dart shipped-spec parser-smoke boundary after hlink parity"
  - "what is the Dart shipped-spec parser-smoke boundary after helper mutation parity"
  - "what is the Dart shipped-spec parser-smoke boundary after regdef parity"
  - "what is the next Dart shipped-spec parser-smoke boundary after ds_vhistory split"
date: 2026-07-09
status: current
tags: [dart, corpus, shipped-specs, regex, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.0 runs `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31`. The window started 2/31 green (`pplugin_empty`, `tkgui_empty`). Failures clustered into Dart regex-dialect incompatibilities, missing helper/action surfaces, recursive/default-mode output mismatches, and residual shipped-spec smoke parity. DART-BACKEND-PARITY.6.2.4.1 closes the basic regex-dialect bridge; .6.2.4.2 closes the missing helper/action bridge; .6.2.4.3 closes tclite/default-mode action-edge dispatch and recursive rule-local aggregate reset semantics. .6.2.4.4.0 splits remaining non-PCRE parser-smoke work. .6.2.4.4.1 closes the portmap/action-edge child result shape leaf through Dart `array(flat*)` list-context splicing, and `vhdl_library_use` also passes. .6.2.4.4.2 closes hlink delimiter/capture parity through `retv` refresh and scalar-held array append, and `tablegrep_simple_term` also passes. .6.2.4.4.3 closes helper mutation/text-normalization parity through statement-form scalar regex mutation, explicit split target replacement, and entry/local line helpers; `simenv_multiline_value`, `lib_reader_sattribute`, and `lib_reader_cattribute` pass. .6.2.4.4.4 closes `regdef_nested_register_fields` through the `push(Child)` current-accumulator convention. .6.2.4.4.5 splits `ds_vhistory_version_entry` with public-parser, descriptor-handler, scalar-held indexed-read, and leading-newline evidence rather than weakening Dart direct access. The window is now 23/31 green. Remaining PCRE structural regex blockers are routed to .6.2.4.6, and the next implementation leaf is .6.2.4.4.6."
reverify: "cd dart && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31 || true"
---

`DART-BACKEND-PARITY.6.2.4.0` is a planning split, not a runtime fix.

The owned final corpus window starts at manifest offset 68 and has 31 fixtures:
the tclite, Lispish, recursive top-rule, hlink, portmap, EBNF, spec.spec,
regdef, tablegrep, simenv, VHDL/library, history, plugin, and library smoke
fixtures.

The first diagnostic run is useful because it separates early blockers:

- Regex dialect translation blocks many shipped-spec smokes before Dart can
  measure runtime semantics.
- Missing helper/action surfaces block hlink, tablegrep, and simenv style
  fixtures.
- Tclite, Lispish, and recursive top-rule cases need a separate
  recursion/output-semantics pass.
- Residual shipped-spec output parity should wait until those lower blockers
  are removed.

`DART-BACKEND-PARITY.6.2.4.1` closes the basic regex-dialect bridge,
`DART-BACKEND-PARITY.6.2.4.2` closes the missing helper/action bridge, and
`DART-BACKEND-PARITY.6.2.4.3` closes the tclite/default-mode and recursive
top-rule value gap. `DART-BACKEND-PARITY.6.2.4.4.1` closes the portmap result
shape gap by adding Dart list-context splicing for explicit `flat*` calls inside
`array(...)`; `vhdl_library_use` also passes from the same fix. The diagnostic
window is then 13/31 green. `DART-BACKEND-PARITY.6.2.4.4.2` closes hlink
delimiter/capture parity through Dart `retv` refresh and scalar-held array
append behavior; `tablegrep_simple_term` also passes from the same append fix.
`DART-BACKEND-PARITY.6.2.4.4.3` closes helper mutation/text-normalization
parity through statement-form scalar regex mutation, explicit split target
replacement, and entry/local line helpers; `simenv_multiline_value`,
`lib_reader_sattribute`, and `lib_reader_cattribute` pass. The diagnostic
window is then 22/31 green. `DART-BACKEND-PARITY.6.2.4.4.4` closes
`regdef_nested_register_fields` by restoring the `push(Child)` current-rule
accumulator convention. `DART-BACKEND-PARITY.6.2.4.4.5` then splits
`ds_vhistory_version_entry` with public-parser, descriptor-handler,
scalar-held indexed-read, and leading-newline evidence. The diagnostic window is
now 23/31 green. Remaining regex `FormatException` cases are deeper PCRE
structural features and are routed to `DART-BACKEND-PARITY.6.2.4.6`; the
remaining non-PCRE residual is owned by `.6.2.4.4.6`.

Related facts: [[dart-middle-corpus-batch]], [[dart-controlled-corpus-execution]],
[[dart-regex-dialect-bridge]], [[dart-helper-action-surface-bridge]],
[[dart-recursive-dispatch-rule-local-scope]], [[dart-residual-parser-smoke-split]],
[[dart-array-flat-list-context-splice]], [[dart-hlink-scalar-held-array-append]],
[[dart-statement-helper-mutation-parity]], [[dart-legacy-structural-accumulator-parity]],
[[ds-vhistory-leading-newline-oracle-boundary]], [[rust-perl-output-oracle]].
