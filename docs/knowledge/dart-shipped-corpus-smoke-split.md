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
evidence: "DART-BACKEND-PARITY.6.2.4.0 runs `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31`. The window is 2/31 green (`pplugin_empty`, `tkgui_empty`). Failures cluster into Dart regex-dialect incompatibilities (POSIX classes, inline flags, possessive quantifiers), missing helper/action surfaces (`capture_slice`, diagnostic `print`, logical `not`, raw `print(...)` expression parsing), recursive/default-mode output mismatches, and residual shipped-spec smoke parity. The next implementation leaf is DART-BACKEND-PARITY.6.2.4.1 for the regex-dialect bridge."
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

Related facts: [[dart-middle-corpus-batch]], [[dart-controlled-corpus-execution]],
[[rust-perl-output-oracle]].
