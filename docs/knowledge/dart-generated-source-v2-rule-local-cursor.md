---
id: dart-generated-source-v2-rule-local-cursor
title: Dart generated-source v2 reconstructs cursor policy from the validated rule family
answers:
  - "what generated source version does Dart emit"
  - "how does Dart generated source choose seek or consume"
  - "does Dart generated source serialize cursor policy"
  - "how does Dart reject generated source v1"
  - "does Dart generated source classify compact pipe as OR"
  - "does generated Dart source derive policy for nested rules"
  - "what proves Dart rejects an old contract before decoding its payload"
date: 2026-07-18
status: current and fully verified
tags: [dart, generated-source, cursor, rule-family, contract-v2, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.5.4 advances Dart emission to linkedspec-generated-source-v2 / format 2. The deterministic plan remains exactly ordered label/family rows. Validation rejects any non-v2 contract before lazy payload decoding, then execution derives seek for default/OR/repetition families and consume for every AND family at each entered rule. Compact Pipe classifies as or_acode. Focused affected tests pass 76/76, the complete package reaches 257/1 at the staged shared-help seam, corpus execution passes 105/105, and primary CLI remains the expected 30/63 twice until .5. Neutral governance remains 68 files / 3-of-5 / 34 mutations; canonical CI passes Perl cursor admission 288, reference primary 63/63 twice, and Phase 0 1,031/1,031 in 641 seconds."
evidence_update_2026_07_18_public_removal: "FUTURE-PARITY-BACKLOG.9.1.5.5 leaves generated-source v2 unchanged while deleting surrounding public/global options. Current Dart proof is 260 package tests, primary 63x2, corpus 105/105, and neutral 66 files/34 mutations."
reverify: "cd dart && dart analyze --fatal-infos --fatal-warnings && dart test test/source_emitter_test.dart test/rule_local_cursor_execution_test.dart test/rule_local_cursor_normalization_test.dart test/punctuation_light_zero_arg_contract_test.dart test/diagnostic_output_contract_test.dart test/logical_helper_contract_test.dart test/complete_named_mark_contract_test.dart test/variadic_user_function_contract_test.dart test/uniform_binding_contract_test.dart"
---

Dart now emits generated-source contract v2 and format 2. The public versioned
entrypoints are `emitDartSourceV2`, `validateGeneratedRulePlanV2`,
`executeGeneratedParserV2`, and `executeGeneratedParserWithTraceV2`; the
unversioned emitter remains the current-version convenience adapter. Versioned
v1 Dart entrypoints are no longer exported, so callers with persisted v1 source
must regenerate it from the originating `.spec` file.

The generated plan deliberately remains minimal. Each ordered row contains only
`label` and `family`; no cursor field is serialized. After exact plan validation,
`GeneratedRuleFamily.cursorPolicy` derives `consume` for the five AND families
and `seek` for default, OR, and repetition families. Every nested rule lookup
selects that rule's validated family, so a parent cannot propagate its policy to
a child. Regex-versus-blind structural dispatch is derived from the same family.

`validateGeneratedSourceContractV2` raises
`generated_source_contract_version_mismatch` at
`validate_generated_plan`, with exact expected/actual contract identities and a
regeneration instruction. Emitted libraries call it before touching the lazy
Base64 normalized-state payload. The isolated host test deliberately corrupts
that payload: a v1 identity still produces the version mismatch first, while a
current v2 identity proceeds and exposes the separate compile/load failure.

Compact `Pipe` now classifies as `or_acode`, matching authored OR semantics.
All ten exact generated families, the eight parent/child mechanisms, both
structural replacements, emitted diagnostic sinks, logical helpers, variadic
state, named marks, punctuation-light aliases, and uniform binding execute
through the v2 entrypoints in focused proof.

The neutral generated-source v1 ledger remains the cross-backend semantic
baseline and still owns its accepted subset. Dart's current source format is v2;
the public/loader/corpus/CLI global parse-mode seam is removed by `.9.1.5.5`.

Related: [[generated-source-contract-v1]],
[[dart-rule-local-cursor-execution]],
[[dart-rule-local-cursor-normalization]],
[[dart-generated-source-deferred]], and
[[rule-local-cursor-ownership-decision]].
