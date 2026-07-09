---
id: dart-recursive-dispatch-rule-local-scope
title: Dart resolves edge-only action regex dispatch and scopes explicit aggregate resets per rule invocation
answers:
  - "why do Dart tclite fixtures pass"
  - "how does Dart resolve action edge regex indices"
  - "does Dart scope set array resets per recursive rule invocation"
  - "does Dart preserve undeclared child mutations across rule calls"
  - "what does DART-BACKEND-PARITY.6.2.4.3 prove"
date: 2026-07-09
status: current
tags: [dart, runtime, compiler, recursion, corpus, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.3 ports the Rust/Perl action-edge dependency model into Dart compiled state: every compiled action edge records regex_index, child_regex_index, and has_parent_regex; edge-only child regexes are resolved into the parent alternation; runtime dispatch executes every edge for the matched regex index. The same leaf makes explicit aggregate resets through set(array(name), ...) and set(hash(name), ...) rule-local by snapshotting the prior binding on first reset and restoring it on rule exit, while ordinary undeclared child mutations remain caller-visible. Focused compiler/runtime tests pass and the shipped parser-smoke window moves to 7/31 green with tclite_command_subst, tclite_double_quote, top_rule_body_recursion_sexpr, top_rule_lx_recursion_nested, top_rule_lx_recursion_sequence, pplugin_empty, and tkgui_empty passing."
reverify: "cd dart && dart test test/compiled_spec_test.dart test/runtime_interpreter_test.dart && dart analyze --fatal-infos --fatal-warnings && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --offset 68 --limit 31 || true"
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

Remaining failures after this leaf are not the tclite/default-mode or recursive
top-rule value gap. Lispish still hits a deeper recursive PCRE `(?R)` construct
owned by `DART-BACKEND-PARITY.6.2.4.6`; residual hlink, output-shape, and helper
parity fixtures are owned by `DART-BACKEND-PARITY.6.2.4.4`.

Related facts: [[dart-shipped-corpus-smoke-split]],
[[rust-tclite-default-mode-repetition-gap]],
[[rust-declare-type-token-rule-scope]],
[[top-rule-recursion-forward-progress-guard]].
