---
id: dart-rule-local-cursor-preflight
title: "Dart cursor rollout starts from global propagation, raw bare edges, descriptor/generated v1, and a staged CLI seam"
answers:
  - "what is the Dart rule local cursor preflight baseline"
  - "which Dart files own parse mode migration"
  - "why does the Dart local gate currently fail one test"
  - "why does Dart primary CLI pass only 30 of 63 cases"
  - "does Dart global parse mode propagate into child rules"
  - "how does Dart classify compact pipe"
  - "does Dart parse bare rule edges"
  - "what cursor metadata does the Dart descriptor expose"
  - "what generated source version does Dart emit"
  - "which task leaves own the Dart cursor rollout"
  - "does the Dart cursor rollout need gate hardening"
date: 2026-07-18
status: verified historical preflight; normalization through public removal implemented through .9.1.5.5
tags: [dart, dsl, cursor, parse-mode, bare-edge, descriptor, generated-source, cli, rollout, FUTURE-PARITY-BACKLOG]
evidence: "Read-only family/edge/parent-child/artifact probes plus the actual local driver establish Dart's exact pre-edit boundary. Compact pipe alone is misclassified as AND; bare edges become generic raw syntax; one engine-global parseMode controls all entered rules; descriptor metadata owns root parse_mode; generated source remains v1/format 1; focused non-primary tests pass 104/104 and corpus execution passes 105/105. The complete package reaches 244 pass / 1 expected shared-help failure, while the shared primary projection is exactly 30/63 in both default and POSIX environments because the reference fixtures already removed the option and trace field. The neutral checker remains 36/18/8 with 14 Perl roles, 15 Rust roles, 68 files, 3 complete / 5 pending, and 34 rejected mutations."
evidence_update_2026_07_18_descriptor: "FUTURE-PARITY-BACKLOG.9.1.5.3 replaces the preflight descriptor boundary with cursor v1. Root parse_mode is gone; every rule publishes derived family/policy/ownership/resolved edges; direct, normalized SpecFile-JSON, and loaded projections agree. Generated v1 and public/CLI options remain staged for .4-.5."
evidence_update_2026_07_18_generated_v2: "FUTURE-PARITY-BACKLOG.9.1.5.4 replaces the preflight generated boundary with linkedspec-generated-source-v2 / format 2. Exact label/family rows reconstruct each rule's cursor/composition policy; compact Pipe is OR; v1 is rejected before lazy payload decoding. Public/CLI options remain staged for .5."
evidence_update_2026_07_18_public_removal: "FUTURE-PARITY-BACKLOG.9.1.5.5 removes every caller-owned Dart global cursor override and the primary request field, returns exact retired-flag guidance, and passes 260 package tests, 63x2 primary, and 105/105 corpus. Neutral inventory is 66/3-of-5/34."
reverify: "python3 tools/check_rule_local_cursor_contract.py; bash tools/run_dart_local.sh"
---

The governed token inventory has eleven Dart paths:

- `dart/lib/src/cli/primary_cli.dart`
- `dart/lib/src/corpus/manifest_runner.dart`
- `dart/lib/src/io/spec_loader.dart`
- `dart/lib/src/parser/spec_parser.dart`
- `dart/lib/src/parser/user_function_definition_parser.dart`
- `dart/lib/src/runtime/interpreter.dart`
- `dart/lib/src/runtime/matching.dart`
- `dart/test/primary_cli_test.dart`
- `dart/test/rule_local_cursor_descriptor_test.dart`
- `dart/test/runtime_interpreter_test.dart`
- `dart/test/runtime_matching_test.dart`

Non-token owners also matter: AST rule modes, validation, compiled action/blind
dispatch, `dart/lib/src/source_emitter.dart`, normalized JSON reconstruction,
generated-host tests, public exports, loader/corpus/primary adapters, shared CLI
fixtures, local/canonical drivers, and user-facing documentation.

The exact pre-edit semantic boundary is:

1. `RuleMode.isAnd` and `classifyGeneratedRuleFamily` treat `RuleMode.pipe`
   (compact `|`) as AND / `and_single_acode`. That is the only drift among all
   36 top/body family spellings. Compact `&` is correctly AND.
2. The parser recognizes explicit `->` and `=>` edges. A complete bare declared-
   rule line remains `RawBodyElementKind`, and validation emits generic
   `unrecognized body syntax`. Explicit AND action and explicit OR blind edges
   remain accepted cross-family exceptions.
3. `LinkedSpecRuntimeEngine` owns one constructor `parseMode`. Both direct rule
   matching seams spend it, so a caller/parent-selected seek or consume policy
   propagates into mixed and recursive children. `_RuntimeExecutionContext` also
   stores the value even though its copy is not read independently.
4. `CompiledDescriptorState.toJson()` emits root `meta.parse_mode: seek`. Per-rule
   metadata has no neutral cursor contract, derived policy, or ordered resolved
   semantic edge rows.
5. Dart emits `linkedspec-generated-source-v1` / format 1. Its normalized state
   reconstruction recompiles the embedded `SpecFile`; its minimal plan already
   carries only label/family rows, but family classification inherits the compact-
   pipe error. There is no v2 contract-mismatch diagnostic or mandatory `.spec`
   regeneration path.
6. The primary command still advertises and accepts `--parse-mode`, passes it to
   native/inline engines, and records `parse_mode=seek` in medium request traces.
   Loader, corpus, user-function parser, runtime helpers, and tests still contain
   staged global ownership. The public low-level enum/export is separately staged:
   `.5` must distinguish a contract-permitted matcher primitive from a caller-
   selected execution override rather than deleting it by spelling alone.

The gate state is intentionally asymmetric because the Perl reference migrated
the shared byte fixtures first. `tools/run_dart_local.sh` passes formatting and
strict analysis, then reports 244 package-test passes and one failure in the exact
shared help assertion; its `set -e` stops before later CLI/corpus steps. The
focused parser/validator/compiler/runtime/loader/generated suite independently
passes 104/104, and the full corpus passes 105/105. Both exact primary runs pass
30/63: 22 help/usage cases retain the old option/help or validation (the removed-
flag case expects a targeted migration error), and eleven request-trace cases
retain the old field. All other bytes pass. This is the measured rollout seam,
not a new regression.

The dependency-safe implementation order is `.9.1.5.1` typed family/edge
normalization, `.2` live/loaded/normalized execution, `.3` descriptor v1, `.4`
generated-source v2, `.5` API/loader/corpus/CLI/trace removal and exact 63x2, and
`.6` composed admission/closeout. No gate-hardening child is required: the Dart
driver already runs the complete package, exact primary projection twice, and all
105 corpus fixtures once the staged shared-help failure is resolved.

Normalization `.9.1.5.1`, normal execution `.2`, descriptor `.3`, and
generated-source v2 `.4` now implement the first four children exactly. Typed bare AST/JSON, authored
compact-pipe identity, six portable diagnostic identities, family-derived
compiled action/blind tables, per-entry normal execution, and cursor descriptor
v1 are current; generated plans now reconstruct rule-local execution from exact
family rows and reject v1. Follow [[dart-rule-local-cursor-normalization]],
[[dart-rule-local-cursor-execution]], and
[[dart-rule-local-cursor-descriptor]], and
[[dart-generated-source-v2-rule-local-cursor]] and
[[dart-global-cursor-option-removal]] instead of re-running this historical
pre-edit audit. Composed admission alone remains `.6`.

Related: [[rule-local-cursor-neutral-contract]],
[[rule-local-cursor-and-bare-edge-contract]],
[[dart-compiled-spec-state]], [[dart-runtime-matching-state]],
[[dart-generated-source-deferred]], [[dart-primary-cli-closeout]], and
[[FUTURE-PARITY-BACKLOG]].
