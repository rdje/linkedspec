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
  - how does Dart generated source v2 derive cursor behavior
  - does Dart normal execution still read the engine global parse mode
  - what tests prove Dart rule-local cursor execution
date: 2026-07-18
status: verified normal and generated-v2 execution; public removal/admission remain .9.1.5.5-.6
tags: [dart, runtime, cursor, rule-family, trace, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.5.2 removes CompiledRuleModeMetadata.usesLegacyAndInterpretation and makes LinkedSpecRuntimeEngine derive consume for exact AND and seek for OR/default once at every normal _executeRule entry. FUTURE-PARITY-BACKLOG.9.1.5.4 removes the generated-v1 exception: generated-source v2 validates exact label/family rows and derives seek/consume plus structural dispatch from each entered rule's family. Live, loaded, normalized JSON, and generated-v2 execution consume all 36 family rows, eight parent/child mechanisms, and both structural replacements. Focused v2 proof passes 76/76, corpus 105/105, complete package 257/1 only at the staged help seam, and primary remains 30/63 twice until .5."
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

Generated-source contract v2 removes the former generated-v1 exception. Its
validated ordered plan remains exactly `label`/`family`; seek/consume and
regex-versus-blind composition are reconstructed from the family at every
entered rule. Compact `Pipe` is OR. Public constructor, loader, CLI, help, and
request-trace option surfaces remain staged for removal in `.9.1.5.5`; accepting
those options does not restore global authority to normal or generated-v2 rule
execution.

`dart/test/rule_local_cursor_execution_test.dart` consumes the neutral contract's
36 family spellings, all eight mixed parent/child mechanisms, and both structural
replacements across live, normalized JSON, and generated-v2 routes. It separately
proves loaded execution, parent/child trace attribution, and exact v2 family
policy. Existing runtime/source-emitter fixtures pin contiguous AND landmark
matching and exact interpreter/generated agreement.

Related: [[dart-rule-local-cursor-normalization]],
[[dart-runtime-matching-state]], [[dart-runtime-rule-interpreter]],
[[dart-generated-source-v2-rule-local-cursor]],
[[rule-local-cursor-ownership-decision]], and [[rust-rule-local-cursor-execution]].
