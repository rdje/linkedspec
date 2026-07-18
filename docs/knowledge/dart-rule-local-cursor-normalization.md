---
id: dart-rule-local-cursor-normalization
title: "Dart retains typed bare edges and exact authored family identity before cursor execution migration"
answers:
  - "does Dart parse bare rule edges"
  - "where does Dart normalize bare edge ownership"
  - "how does Dart classify compact pipe now"
  - "where are Dart cursor normalization diagnostics represented"
  - "what is SpecPortableDiagnostic"
  - "when was Dart usesLegacyAndInterpretation removed"
  - "does Dart generated source classify compact pipe correctly yet"
  - "which Dart leaf changes live cursor execution"
  - "how is Dart cursor execution frozen during normalization"
  - "what tests prove Dart bare edge normalization"
date: 2026-07-18
status: verified normalization; live cursor execution completed in FUTURE-PARITY-BACKLOG.9.1.5.2
tags: [dart, dsl, cursor, bare-edge, parser, compiler, validation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "Dart classifies compact `|` as authored OR and `&` as authored AND; retains complete-line/header-rest bare targets as BareEdgeBodyElementKind with nullable authored indices; validates all six neutral edge diagnostics through sorted SpecPortableDiagnostic code/stage/fields; and lowers family-derived ownership into compiled action/blind tables. Execution leaf .9.1.5.2 removed usesLegacyAndInterpretation from compiled metadata; generated-source v1 remains intentionally staged for .4 behind an interpreter-local compatibility path. The five-test normalization consumer covers all 36 family and 18 edge rows, six ownership sets, JSON roundtrips, line boundaries, compiled dispatch, and staging."
reverify: "(cd dart && dart test test/rule_local_cursor_normalization_test.dart); (cd dart && dart test test/spec_parser_test.dart test/spec_validator_test.dart test/compiled_spec_test.dart test/runtime_matching_test.dart test/runtime_interpreter_test.dart test/source_emitter_test.dart test/spec_loader_test.dart test/rule_local_cursor_normalization_test.dart); python3 tools/check_rule_local_cursor_contract.py"
---

Dart syntax and representation normalization now has four exact seams:

- `dart/lib/src/ast/spec_ast.dart` makes `RuleMode.isAnd` authored-family
  exact: compact `|` is OR/default and compact `&` is AND. It also defines
  `BareEdgeBodyElementKind`, whose `BareEdgeTarget.index` is nullable so an
  omitted slot remains distinct from authored `[0]` through AST JSON.
- `dart/lib/src/parser/spec_parser.dart` retains a syntactically complete bare
  plain/indexed/grouped/block/fluent candidate only when it begins a complete
  physical body line or the header rest. Lifecycle markers are recognized first;
  a label-like suffix after another same-line member is not reinterpreted as a
  bare edge. Forward declarations therefore survive until whole-spec validation.
- `dart/lib/src/validation/spec_validator.dart` resolves against the complete
  rule-label set, derives AND bare ownership as blind and OR/default ownership as
  action, and rejects invalid shape or mixed ownership through
  `SpecPortableDiagnostic`. Each record carries stable `code`, `stage`, human
  `message`, and deterministically sorted contract fields; it round-trips through
  JSON and is attached to `SpecValidationException`.
- `dart/lib/src/compiler/compiled_spec.dart` lowers valid normalized bare
  ownership into `blindEdges` for AND and `actionEdges` for OR/default. Blocks,
  fluent calls, target order, explicit action/blind exceptions, dependency refs,
  and nullable-authored-index semantics remain typed.

The six current portable normalization/validation codes are
`bare_edge_target_undefined`, `bare_edge_index_requires_action`,
`bare_edge_group_requires_action`, `mixed_edge_ownership`,
`grouped_action_shared_block_required`, and `blind_call_index_forbidden`.
Their stages and exact field sets come directly from
`capability_conformance/rule_local_cursor_contract.json`; generic raw-syntax
messages no longer own governed bare candidates.

Normalization stops at exact compiled family/ownership state.
`CompiledRuleModeMetadata` exposes `isAnd=false` for compact pipe; execution leaf
`.9.1.5.2` subsequently removed `usesLegacyAndInterpretation` and made normal
sequence/choice plus seek/consume execution use exact entered-rule metadata.
`classifyGeneratedRuleFamily` still emits the v1 compact-pipe family
intentionally; `.9.1.5.4` owns generated-source v2 and the hard v1
reconstruction boundary. Root descriptor global metadata and public/CLI global
options likewise remain assigned to `.3` and `.5`.

`dart/test/rule_local_cursor_normalization_test.dart` is the contract-driven
consumer. It covers all 36 top/body family spellings, 18 valid/invalid edge rows,
six multi-edge ownership sets, complete-line/header-rest/multiline recognition,
same-line exclusion, AST and diagnostic JSON roundtrips, compiled dispatch tables,
and explicit runtime/generated-v1 staging. The test intentionally contains none
of the governed global-option spellings, because existing runtime/primary tests
already own that staged boundary; the exact migration inventory therefore remains
68 rather than expanding for redundant evidence.

Related: [[dart-rule-local-cursor-preflight]],
[[dart-rule-local-cursor-execution]],
[[rule-local-cursor-and-bare-edge-contract]],
[[rule-local-cursor-neutral-contract]], [[rust-rule-local-cursor-normalization]],
and [[FUTURE-PARITY-BACKLOG]].
