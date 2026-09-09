---
id: dart-regex-dialect-bridge
title: Dart bridges the basic shipped regex dialect before RegExp compilation
answers:
  - "does Dart support POSIX regex classes"
  - "does Dart support inline regex flags"
  - "does Dart support possessive regex quantifiers"
  - "what does DART-BACKEND-PARITY.6.2.4.1 prove"
  - "why do Dart regex FormatExceptions remain after the regex bridge"
  - "which Dart leaf closed the structural regex FormatExceptions"
date: 2026-07-09
status: current
tags: [dart, regex, corpus, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.1 adds compileRuntimeRegex(...) in dart/lib/src/runtime/matching.dart and routes helper regex compilation through it from interpreter.dart. The bridge normalizes POSIX character classes, inline i/m/s flag groups, scoped flag groups by lowering them to non-capturing groups plus Dart RegExp flags, possessive quantifier markers, lower-bound {,n} quantifiers, and Python-style named captures before Dart RegExp compilation. Focused runtime matching and interpreter tests lock the behavior. The final shipped-smoke window still had FormatExceptions only for deeper PCRE structural constructs such as \\K, (?&name), and (?(DEFINE)...), routed to DART-BACKEND-PARITY.6.2.4.6. That later leaf closes those exact shipped structural forms with bounded matchers, not a broad regex engine replacement."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/runtime_matching_test[.]dart test/runtime_interpreter_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings && bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31"
---

The bridge is deliberately a dialect normalizer, not a replacement regex engine.
It is enough to move the final shipped-smoke corpus past the basic Dart `RegExp`
syntax gaps:

- POSIX classes such as `[[:alpha:]]`.
- Inline flag groups such as `(?i)`, `(?m)`, and `(?is)`.
- Scoped flag groups such as `(?s:...)`, accepted by lifting the option to the
  compiled Dart `RegExp` rather than preserving PCRE-local flag scope.
- Possessive quantifier markers such as `++`, `*+`, `?+`, and `{m,n}+`.
- Lower-bound quantifier shorthand such as `{,2}`.
- Python-style named capture syntax.

The remaining regex failures after this bridge were structural PCRE features
that Dart cannot emulate by simple normalization: `\K`, recursive named
subpatterns, and `(?(DEFINE)...)`. `DART-BACKEND-PARITY.6.2.4.6` later closed
the exact shipped structural forms with bounded matchers.

Related facts: [[dart-shipped-corpus-smoke-split]],
[[dart-structural-pcre-parser-smoke-parity]], [[dart-runtime-matching-state]],
[[rust-perl-output-oracle]].

## 2026-09-09 — lower-bound normalization literal corruption

[[dart-regex-quantifier-literal-corruption]] establishes three false match decisions
with three controls. _normalizeLowerUnboundedQuantifiers at matching.dart 1619
rewrites {,2} even after an escaped opening brace or inside a character class.
Raw Dart and Perl preserve the intended literal meaning; public Dart alternation,
authored native and SpecFile-JSON parsers execute the altered pattern. Actual
a{,2} support remains a successful bridge control. Gated .2.16 owns lexical repair
and carrier/public proof; this finding changes neither the documented scoped-flag/
possessive limits nor the separately owned regex-brace scanners.
