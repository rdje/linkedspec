---
id: dart-recursive-dispatch-rule-local-scope
title: Dart resolves edge-only action dispatch and scopes typed initializers per rule invocation
answers:
  - "why do Dart tclite fixtures pass"
  - "how does Dart resolve action edge regex indices"
  - "does Dart scope set array resets per recursive rule invocation"
  - "does Dart preserve undeclared child mutations across rule calls"
  - "does Dart treat a missing compiled rule name as an empty accumulator"
  - "what does DART-BACKEND-PARITY.6.2.4.3 prove"
date: 2026-07-09
status: current
tags: [dart, runtime, compiler, recursion, corpus, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.3 ports the Rust/Perl action-edge dependency model and scopes explicit aggregate resets per rule invocation. FUTURE-PARITY-BACKLOG.12.1.7.2 migrates the recursive fixtures to bare I assignments and extends the same first-write scope to direct initializer assignment; an otherwise absent binding named for a compiled rule reads as its empty implicit array accumulator. Permanent native/generated uniform-binding tests and the complete 105-case corpus pass."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/compiled_spec_test[.]dart test/runtime_interpreter_test.dart && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings && bash ../tools/run_dart_project_data.sh run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31 || true"
---

This fact is the Dart analogue of the Rust fixes recorded under
[[rust-tclite-default-mode-repetition-gap]] and
[[rust-declare-type-token-rule-scope]].

The runtime no longer infers action-edge dispatch from edge list position.
Compiled action edges now carry the regex alternative that triggers them, so
tclite-style close edges work even when interior child choices appear before the
close action or when opener and closer reuse the same regex slot.

The rule-local aggregate reset boundary is deliberately narrow:

- `set(array(name), value)` and `set(hash(name), value)` create a local binding
  for the current rule invocation.
- The first such reset snapshots the previous scalar/array/hash binding and
  restores it on rule exit.
- Plain `push(array(name), value)` without an explicit reset remains shared and
  caller-visible.
- User functions keep their existing whole-store local execution model and do
  not participate in the enclosing rule-local reset tracker.

Selector-free recursive sources use `I { items = [] }`; direct initializer assignments now enter that same
rule-invocation scope. When a compiled rule name has no explicit binding yet, reading it yields the rule's empty
implicit array accumulator, preserving accumulator-oriented rule bodies without a selector.

Remaining failures after this leaf are not the tclite/default-mode or recursive
top-rule value gap. Lispish still hits a deeper recursive PCRE `(?R)` construct
owned by `DART-BACKEND-PARITY.6.2.4.6`; residual hlink, output-shape, and helper
parity fixtures are owned by `DART-BACKEND-PARITY.6.2.4.4`.

Related facts: [[dart-shipped-corpus-smoke-split]],
[[rust-tclite-default-mode-repetition-gap]],
[[rust-declare-type-token-rule-scope]],
[[top-rule-recursion-forward-progress-guard]].
