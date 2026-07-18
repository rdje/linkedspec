---
id: dart-rule-local-cursor-execution
title: Dart normal execution derives cursor and composition policy at every entered rule
answers:
  - how does Dart derive rule-local cursor policy
  - does a Dart parent rule propagate cursor policy to a child
  - does Dart AND consume and OR seek now
  - does Dart loaded execution use rule-local cursor policy
  - does Dart normalized SpecFile JSON execution use rule-local cursor policy
  - where does Dart trace entered rule cursor policy
  - why does Dart generated source v1 still use global cursor behavior
  - does Dart normal execution still read the engine global parse mode
  - what tests prove Dart rule-local cursor execution
date: 2026-07-18
status: verified normal execution; descriptor/generated-v2/public removal/admission remain .9.1.5.3-.6
tags: [dart, runtime, cursor, rule-family, trace, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.5.2 removes CompiledRuleModeMetadata.usesLegacyAndInterpretation and makes LinkedSpecRuntimeEngine derive consume for exact AND and seek for OR/default once at every normal _executeRule entry. The derived policy is passed through regex matching and trace, while structural AND/OR dispatch uses the same entry-local family fact; recursive child entry recalculates both. Live, loaded, and normalized SpecFile-JSON reconstruction consume all 36 family rows, eight parent/child mechanisms, and both structural replacements. Generated-source v1 alone retains engine-global cursor and compact-Pipe compatibility until .4. Focused proof passes 142/142, corpus 105/105, complete package 253/1 only at the staged help seam, and primary remains 30/63 twice."
reverify: "(cd dart && dart analyze --fatal-infos --fatal-warnings && dart test test/rule_local_cursor_execution_test.dart test/rule_local_cursor_normalization_test.dart test/runtime_matching_test.dart test/runtime_interpreter_test.dart test/spec_loader_test.dart test/source_emitter_test.dart test/trace_test.dart test/spec_parser_test.dart test/spec_validator_test.dart test/compiled_spec_test.dart test/corpus_manifest_test.dart); python3 tools/check_rule_local_cursor_contract.py"
---

Normal Dart runtime execution now derives both cursor discipline and structural
composition exactly once at the start of every `_executeRule` entry in
`dart/lib/src/runtime/interpreter.dart`:

- exact AND-family metadata maps to `consume` and ordered sequence execution;
- default/OR-family metadata maps to `seek` and choice execution;
- every child call and recursion re-enters `_executeRule`, so it recalculates
  from the child and cannot inherit the parent's policy.

The derived cursor value is passed explicitly into alternation and specific-slot
matching. The engine-global field is no longer read by normal live, loaded, or
normalized-state execution. Low-level `seek` and `consume` algorithms remain in
`runtime/matching.dart`; the migration changes policy ownership, not those
algorithms or the separate entry/local match registers.

Rule trace scopes now include `cursor_policy=seek|consume`, and regex decisions
record the same policy used for matching. Loaded specs use `LoadedCompiledSpec`
and the same engine. Generated Dart artifacts reconstruct normalized `SpecFile`
JSON before compilation, so the ordinary reconstructed path derives from the
same family state without a second serialized cursor field.

Generated-source contract v1 is a deliberately bounded exception until
`.9.1.5.4`: execution through a generated plan retains the engine-global cursor
setting and legacy compact-`Pipe` structural interpretation. Public constructor,
loader, CLI, help, and request-trace option surfaces remain staged for removal in
`.9.1.5.5`; accepting those options does not restore global authority to normal
rule execution.

`dart/test/rule_local_cursor_execution_test.dart` consumes the neutral contract's
36 family spellings, all eight mixed parent/child mechanisms, and both structural
replacements across live and normalized JSON routes. It separately proves loaded
execution, parent/child trace attribution, and the exact generated-v1 compatibility
boundary. Existing runtime/source-emitter fixtures pin the two dependent semantic
adjustments: contiguous AND landmark matching and one generated-v1 repetition
divergence that generated-source v2 will remove.

Related: [[dart-rule-local-cursor-normalization]],
[[dart-runtime-matching-state]], [[dart-runtime-rule-interpreter]],
[[rule-local-cursor-ownership-decision]], and [[rust-rule-local-cursor-execution]].
