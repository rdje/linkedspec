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
date: 2026-10-26
status: current
tags: [dart, regex, corpus, DART-BACKEND-PARITY]
evidence: "Basic normalizer DART6.2.4.1 and bounded structural6.2.4.6; TYPE23.2.12 adds literal x/unknown/invalid helper boundaries. Full prior record at Gitd08fb16f5d709964351903c32fce6cfadcaa4dbe for this path."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/action_regex_mode_boundaries_test.dart test/string_predicate_result_receivers_test.dart"
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

TYPE23.2.12 extends action suffix ims to x: class/escape/comment-aware ASCII preprocessing, go no-ops, unknown suffixes fail closed. _callMatches now catches FormatException like contextual split/filter. Native/restored/plan and direct String checks pass27 tests after lost-x/ignored-q/throwing-invalid RED; Unicode escaped-space and significant non-ASCII whitespace are distinguished. No inline-x/scoped semantics, public regex type or schema expansion.

Complete grouped dotted literals have TYPE23.3.10.6 priority. Separate nested malformed /(/ becomes raw (scanner rejects slash-before-parenthesis), versus a** reaching regex compilation; the public probe in docs/checkpoints/type-operation-inventory/probe_dart_grouped_invalid_pattern.dart retains AST/source and division controls. TYPE23.3.10.7 now recognizes complete grouped/whitespace operands with following delimiter/end, preserving escapes, source spans and adjacent/nested/continued symbolic division. Native/restored/plan invalid-group false/empty and direct parser/mode/String checks pass44 tests/fatal analysis; broader grouped-brace inventory/validator DART2.2.1/.2.2.2 remain open.
