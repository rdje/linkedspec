---
id: dart-structural-pcre-parser-smoke-parity
title: Dart closes shipped structural PCRE parser-smoke fixtures with bounded matchers
answers:
  - "does Dart support shipped structural PCRE regex forms"
  - "how does Dart handle Lispish (?R)"
  - "how does Dart handle EBNF \\K and DEFINE regexes"
  - "how does Dart handle spec.spec recursive block regexes"
  - "what does push(child,index) mean in Dart action-edge blocks"
  - "which leaf closed lispish ebnf and spec.spec parser-smoke fixtures"
  - "why did ebnf_logging_annotation lose its args on Dart"
date: 2026-07-09
status: current
tags: [dart, regex, parser-smoke, action-edge, ebnf, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.6 updates dart/lib/src/runtime/matching.dart so compileRuntimeRegex(...) recognizes exact shipped structural pattern families before Dart RegExp compilation: Lispish recursive square brackets, EBNF return scalar/array/object patterns using \\K, recursive named subpatterns, and (?(DEFINE)...), and spec.spec recursive action/blind/lifecycle/function block forms. The same leaf updates dart/lib/src/runtime/interpreter.dart so action-edge push(child, numeric-index) executes the child, reads the indexed item from its return value, and appends that payload to the current rule accumulator. Focused matching/interpreter tests and corpus_manifest_test lock the behavior; the 31-fixture parser-smoke command reports 31 passed, 0 failed."
reverify: "cd dart && dart test test/runtime_matching_test.dart test/runtime_interpreter_test.dart test/corpus_manifest_test.dart && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31"
---

`DART-BACKEND-PARITY.6.2.4.6` is not a general PCRE engine replacement.

The Dart runtime recognizes only the exact structural regex families shipped in
the current specs and routes them through bounded scanners:

- Lispish recursive square brackets using `(?R)`.
- EBNF return scalar/array/object patterns that use `\K`, `(?&name)`, and
  `(?(DEFINE)...)`.
- spec.spec recursive action, blind-call, lifecycle, fluent, and
  `function_definition` block patterns.

The matchers preserve the surfaces the existing runtime consumes: group 0,
captures, named captures, match start/end, and seek/consume behavior.

The EBNF logging annotation failure was not a regex issue after those patterns
compiled. Dart still treated `push(quoted_string, 1)` as a normal two-argument
push and appended literal `1` to an array named `quoted_string`. The parity
contract is action-edge child indexing: execute the child, read item `1` from
its returned array, and append that value to the current rule accumulator. That
preserves `["expr", "term"]` under `logging_annotation`.

The shipped-spec/parser-smoke window at offset 68 / limit 31 is now 31/31 green.
The next Dart corpus frontier is `DART-BACKEND-PARITY.6.2.5` for top-level `fn`
fixtures routed through the spec-defined function shell.

Related facts: [[dart-regex-dialect-bridge]], [[dart-shipped-corpus-smoke-split]],
[[dart-residual-parser-smoke-split]], [[rust-action-edge-child-return-dispatch]],
[[rust-perl-output-oracle]].
