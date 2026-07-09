---
id: dart-regex-dialect-bridge
title: Dart bridges the basic shipped regex dialect before RegExp compilation
answers:
  - "does Dart support POSIX regex classes"
  - "does Dart support inline regex flags"
  - "does Dart support possessive regex quantifiers"
  - "what does DART-BACKEND-PARITY.6.2.4.1 prove"
  - "why do Dart regex FormatExceptions remain after the regex bridge"
date: 2026-07-09
status: current
tags: [dart, regex, corpus, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.1 adds compileRuntimeRegex(...) in dart/lib/src/runtime/matching.dart and routes helper regex compilation through it from interpreter.dart. The bridge normalizes POSIX character classes, inline i/m/s flag groups, scoped flag groups by lowering them to non-capturing groups plus Dart RegExp flags, possessive quantifier markers, lower-bound {,n} quantifiers, and Python-style named captures before Dart RegExp compilation. Focused runtime matching and interpreter tests lock the behavior. The final shipped-smoke window still has FormatExceptions only for deeper PCRE structural constructs such as \\K, (?&name), and (?(DEFINE)...), routed to DART-BACKEND-PARITY.6.2.4.6."
reverify: "cd dart && dart test test/runtime_matching_test.dart test/runtime_interpreter_test.dart && dart analyze --fatal-infos --fatal-warnings && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31 || true"
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

Remaining regex failures are structural PCRE features that Dart cannot emulate
by simple normalization: `\K`, recursive named subpatterns, and
`(?(DEFINE)...)`. Those belong to `DART-BACKEND-PARITY.6.2.4.6`.

Related facts: [[dart-shipped-corpus-smoke-split]],
[[dart-runtime-matching-state]], [[rust-perl-output-oracle]].
