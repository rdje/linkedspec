---
id: dart-structural-pcre-parser-smoke-parity
title: Dart closes shipped structural PCRE parser-smoke fixtures with bounded matchers
answers:
  - "does Dart support shipped structural PCRE regex forms"
  - "how does Dart handle Lispish (?R)"
  - "how does Dart handle EBNF \\K and DEFINE regexes"
  - "how does Dart handle spec.spec recursive block regexes"
  - "how does Dart handle spec.spec variadic function definition regexes"
  - "what are blkFN and blkVFN in the Dart regex bridge"
  - "what does push(child,index) mean in Dart action-edge blocks"
  - "which leaf closed lispish ebnf and spec.spec parser-smoke fixtures"
  - "why did ebnf_logging_annotation lose its args on Dart"
  - "can Dart execute current specs/spec.spec directly"
  - "how does the Dart structural bridge consume the self-hosted Unicode label class"
  - "how does Dart handle self-hosted blkLBL and blkSLB recursive blocks"
  - "why did same-line standalone lifecycle grammar fail with Invalid group on Dart"
  - "how does Dart preserve cursor anchors for same-line bare lifecycle members"
date: 2026-09-24
status: current
tags: [dart, regex, parser-smoke, action-edge, ebnf, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.6 updates dart/lib/src/runtime/matching.dart so compileRuntimeRegex(...) recognizes exact shipped structural pattern families before Dart RegExp compilation: Lispish recursive square brackets, EBNF return scalar/array/object patterns using \\K, recursive named subpatterns, and spec.spec recursive action/blind/lifecycle/function block forms. FUTURE-PARITY-BACKLOG.12.1.8.3.2 extends that bounded function family from fixed blkFN to the later exact variadic blkVFN pattern, preserving name/fixed/rest/body captures and named-block identity. FUTURE-PARITY-BACKLOG.10.5.0.1.1 derives the generated rule-label atom from canonical structural patterns and enables Unicode mode for supplementary literals. FUTURE-PARITY-BACKLOG.19.3.3 closes the later standalone-lifecycle grammar delta by adding exact physical-line matchers for explicit blkLBL and shorthand blkSLB, preserving positional/named captures and rejecting suffix text. Focused parser/matcher tests pass 19 and the unchanged corpus passes 105/105. SESSION-STARTUP-READING.86.5.3 extends only the exact standalone member spelling: cursor-whitespace or physical-line prefix, balanced block and retained suffix. Focused20, package502, grammar6x2 on three Dart carriers, CLI66x2 and corpus105 pass; complete gate remains blocked by separately owned formatter/SDK diagnostics."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/runtime_matching_test[.]dart test/runtime_interpreter_test[.]dart test/corpus_manifest_test.dart && bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31"
---

`DART-BACKEND-PARITY.6.2.4.6` is not a general PCRE engine replacement.

The Dart runtime recognizes only the exact structural regex families shipped in
the current specs and routes them through bounded scanners:

- Lispish recursive square brackets using `(?R)`.
- EBNF return scalar/array/object patterns that use `\K`, `(?&name)`, and
  `(?(DEFINE)...)`.
- spec.spec recursive action, blind-call, lifecycle, fluent, and
  `function_definition` block patterns. Fixed `blkFN` and variadic `blkVFN`
  use separate prefixes and preserve their respective capture shapes.
- The complete-line explicit lifecycle `blkLBL` and standalone lifecycle
  `blkSLB` legacy families use physical-line bounded scanners. The current standalone
  member spelling also accepts the requested search cursor and retains suffix
  members. They are exact shipped
  families, not general recursive-PCRE admission.

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

The later `.10.5.0.1.1` shared-grammar repair extends only this bounded bridge. Structural action/blind/bare
patterns derive their rule-label atom from the authored canonical pattern, so Dart does not duplicate the pinned
806-range table. Patterns containing supplementary literal endpoints compile in Unicode mode. Exact explicit
`I|LS|LE|LX|E|EX|IT` lifecycle forms and physical-line bare-edge block/fluent forms retain the captures consumed
by `spec.spec`. Current canonical source now executes directly; the four stale checked-in corpus copies remain
accepted until their separate `.10.5.0.1.2` regeneration/freshness closeout.

Related facts: [[dart-regex-dialect-bridge]], [[dart-shipped-corpus-smoke-split]],
[[dart-residual-parser-smoke-split]], [[rust-action-edge-child-return-dispatch]],
[[rust-perl-output-oracle]].

## Same-line standalone members

Startup `.86.5.3` adds an exact bridge for the shipped `blkSLB` member pattern
`(?:\G\s*|(?m:^[ \t]*))` plus its existing recursive block. The clean grammar
loaded successfully, while this new spelling initially fell through to ordinary
Dart RegExp and raised `FormatException: Invalid group`. The bounded matcher now
tries the cursor alternative only at the requested start or after a successful
match; a failed attempt cannot slide to a later brace on the same line. Its
physical-line alternative remains available, and the legacy complete-line
pattern keeps its old matching and suffix rejection.

`dart/test/same_line_regex_slot_grammar_test.dart` reads the current permanent
pattern directly. It covers exact captures/spans, nested and quoted braces,
whitespace, unknown prefixes, physical-line fallback and repeated cursor anchors,
plus all six permanent CLI AST cases under LF/CRLF through native, reconstructed
and generated-plan execution. Focused20 and package502 pass; storage25/47,
primary CLI66 twice and corpus105 pass independently. The complete gate still
fails at the existing formatter/SDK owners; see
[[dart-component-gate-sdk-compatibility]]. No general PCRE or SDK migration claim.
