---
id: dart-shipped-corpus-smoke-split
title: Dart shipped-spec parser-smoke corpus window is split by failure cluster
answers:
  - "what does DART-BACKEND-PARITY.6.2.4.0 prove"
  - "why is the Dart shipped corpus smoke batch split"
  - "which Dart shipped-spec corpus failures are known"
  - "what is the next Dart corpus frontier after the middle batch"
  - "what split follows DART-BACKEND-PARITY.6.2.4.3"
date: 2026-07-09
status: current
tags: [dart, corpus, shipped-specs, regex, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.0 runs `dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31`. The window started 2/31 green (`pplugin_empty`, `tkgui_empty`). Failures clustered into Dart regex-dialect incompatibilities, missing helper/action surfaces, recursive/default-mode output mismatches, and residual shipped-spec smoke parity. DART-BACKEND-PARITY.6.2.4.1 closes the basic regex-dialect bridge; .6.2.4.2 closes the missing helper/action bridge; .6.2.4.3 closes tclite/default-mode action-edge dispatch and recursive rule-local aggregate reset semantics. The window is now 7/31 green. .6.2.4.4.0 splits remaining non-PCRE parser-smoke work into portmap/action-edge child result shape, hlink delimiter/capture, helper mutation/text normalization, legacy structural smoke outputs, and residual closeout. Remaining PCRE structural regex blockers are routed to .6.2.4.6, and the next implementation leaf is .6.2.4.4.1."
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
top-rule value gap. The diagnostic window is now 7/31 green. Remaining regex
`FormatException` cases are deeper PCRE structural features and are routed to
`DART-BACKEND-PARITY.6.2.4.6`; `.6.2.4.4.0` splits non-PCRE residuals into
focused leaves, with `.6.2.4.4.1` next for portmap/action-edge child result
shape parity.

Related facts: [[dart-middle-corpus-batch]], [[dart-controlled-corpus-execution]],
[[dart-regex-dialect-bridge]], [[dart-helper-action-surface-bridge]],
[[dart-recursive-dispatch-rule-local-scope]], [[dart-residual-parser-smoke-split]],
[[rust-perl-output-oracle]].
