---
id: dart-rule-local-cursor-descriptor
title: Dart cursor descriptor v1 is a pure projection of normalized compiled state
answers:
  - how does Dart project rule local cursor descriptor v1
  - what cursor metadata does the Dart descriptor expose now
  - does Dart descriptor metadata still contain parse_mode
  - what fields are in Dart resolved edge descriptors
  - does Dart descriptor retain bare versus explicit source form
  - does Dart have a descriptor input decoder
  - does Dart descriptor survive normalized SpecFile JSON reconstruction
  - does loaded Dart descriptor match direct compilation
  - how is Dart descriptor cursor policy derived
  - what tests prove Dart cursor descriptor v1
date: 2026-07-18
status: verified implementation and full signoff; generated-v2/public removal/admission remain .9.1.5.4-.6
tags: [dart, descriptor, compiler, cursor, rule-family, loading, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.5.3 removes root meta.parse_mode and projects meta.cursor_contract=linkedspec-rule-local-cursor-v1. Every rule derives family, cursor_policy, edge_ownership, and ordered ownership/target/regex_index/block/fluent rows from exact mode metadata and normalized compiled action/blind tables. Handler label and rule label/line/is_top/mode retain source identity; optional source_form is omitted as non-semantic because compiled state does not retain it. Dart has no descriptor decoder: direct, normalized SpecFile-JSON, and loaded compilation project identical values, and invalid reconstructed state preserves portable validation failures. Focused proof passes 4/4 plus adjacent 18/18; complete package reaches 257/1 only at staged help, corpus 105/105, primary 30/63x2, neutral remains 68 files/34 mutations, Knowledge Map is 591/4,207, and canonical CI passes Perl admission 288, reference primary 63x2, and Phase 0 1,031/1,031 in 624 seconds."
reverify: "cd dart && dart analyze --fatal-infos --fatal-warnings && dart test test/compiled_spec_test.dart test/rule_local_cursor_descriptor_test.dart test/rule_local_cursor_execution_test.dart test/rule_local_cursor_normalization_test.dart; cd .. && python3 tools/check_rule_local_cursor_contract.py"
---

Dart descriptor construction remains a pure outward projection in
`dart/lib/src/compiler/compiled_spec.dart`. `CompiledDescriptorState.toJson()`
now selects the shared `rule_local_cursor_v1` metadata variant:

- root `meta.cursor_contract` is `linkedspec-rule-local-cursor-v1`;
- root and rule metadata expose no global cursor field;
- exact AND metadata derives `family=and` and `cursor_policy=consume`;
- OR/default metadata derives `family=or_default` and `cursor_policy=seek`;
- `edge_ownership` is `action`, `blind`, `none`, or `mixed` from the normalized
  compiled tables; valid compiled rules never mix ownership;
- `resolved_edges` contains exactly `ownership`, `target`, `regex_index`,
  `block`, and `fluent` in deterministic normalized order.

Action rows publish the target's resolved child-regex index, including zero for
an omitted authored index. Blind rows use null because they do not select a
target regex through action dispatch. Blocks derive from the compiled edge code;
fluent calls render as one normalized dot chain or null.

The existing handler label and rule `label`, `line`, `is_top`, and `mode` facts
remain the exact source identity available in compiled state. Dart deliberately
omits optional `source_form=bare|explicit`: normalization no longer retains it,
and ADR `0044` says that provenance is non-semantic.

Dart does not deserialize descriptors or expose a `CompiledSpec.fromJson`
boundary. Its real reconstruction route serializes normalized `SpecFile` JSON,
reconstructs the AST, and recompiles normally. Descriptor proof therefore
compares direct and normalized-AST projections, checks file-loaded identity, and
requires invalid reconstructed state to fail with the same portable diagnostic
before any descriptor can be produced. No descriptor-owned cursor field can
override runtime behavior.

`dart/test/rule_local_cursor_descriptor_test.dart` consumes all 36 neutral
families, every valid edge case, every portable invalid edge/set case, exact
outer/root/row fields, loaded identity, and loaded AND execution. Removing the
compiler's last global-mode token makes that implementation path token-free;
the new forbidden-field test replaces it in the exact 68-file migration
inventory.

Related: [[dart-compiled-spec-state]],
[[dart-rule-local-cursor-normalization]],
[[dart-rule-local-cursor-execution]],
[[outward-compiled-descriptor-four-backend-contract]], and
[[rule-local-cursor-and-bare-edge-contract]].
