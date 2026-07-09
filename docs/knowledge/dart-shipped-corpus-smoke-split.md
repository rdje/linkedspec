---
id: dart-shipped-corpus-smoke-split
title: Dart shipped-spec parser-smoke corpus window is split by failure cluster
answers:
  - "what does DART-BACKEND-PARITY.6.2.4.0 prove"
  - "why is the Dart shipped corpus smoke batch split"
  - "which Dart shipped-spec corpus failures are known"
  - "what is the next Dart corpus frontier after the middle batch"
date: 2026-07-09
status: current
tags: [dart, corpus, shipped-specs, regex, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.0 runs `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31`. The window is 2/31 green (`pplugin_empty`, `tkgui_empty`). Failures cluster into Dart regex-dialect incompatibilities, missing helper/action surfaces, recursive/default-mode output mismatches, and residual shipped-spec smoke parity. DART-BACKEND-PARITY.6.2.4.1 closes the basic regex-dialect bridge; DART-BACKEND-PARITY.6.2.4.2 closes the missing helper/action bridge. Remaining PCRE structural regex blockers are routed to .6.2.4.6, and the next implementation leaf is .6.2.4.3 for recursive/default-mode parser-smoke semantics."
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

`DART-BACKEND-PARITY.6.2.4.1` closes the basic regex-dialect bridge, and
`DART-BACKEND-PARITY.6.2.4.2` closes the missing helper/action bridge. Remaining
regex `FormatException` cases are deeper PCRE structural features and are routed
to `DART-BACKEND-PARITY.6.2.4.6`; the next frontier is recursive/default-mode
parser-smoke semantics.

Related facts: [[dart-middle-corpus-batch]], [[dart-controlled-corpus-execution]],
[[dart-regex-dialect-bridge]], [[dart-helper-action-surface-bridge]],
[[rust-perl-output-oracle]].
