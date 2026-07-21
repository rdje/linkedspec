---
id: dart-semantic-introspection-authority-map
title: Dart semantic introspection must compose typed compiler authorities after Unicode label closure
answers:
  - "which Dart authorities can build the semantic index"
  - "can Dart parse the semantic privacy fixture Töp"
  - "does Dart silently truncate Unicode action or blind targets"
  - "does Dart validate rule labels in deserialized ASTs"
  - "where do Dart semantic source spans need to come from"
  - "what Dart failure does failed.spec report"
  - "does Dart already have a semantic observation sink"
  - "where can Dart semantic slot events be captured"
  - "are the spec_spec corpus fixtures current with specs/spec.spec"
  - "does the Dart 105 fixture corpus prove the current self-hosted grammar"
  - "can Dart execute current specs/spec.spec while the corpus remains stale"
  - "can Dart generated metadata reconstruct a semantic index"
  - "does Dart compiled state preserve Unicode rule labels"
  - "is specs/spec.spec aligned with Unicode rule labels"
  - "what are the Dart semantic introspection implementation leaves"
date: 2026-07-21
status: current
tags: [dart, semantic-introspection, unicode, rule-labels, source-map, diagnostics, runtime, generated-source]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaf .10.5.0; docs/decisions/0012-staged-linked-parsing-architecture.md; docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md; docs/decisions/0051-unicode-17-xid-continue-rule-labels.md; capability_conformance/semantic_introspection_model.json; capability_conformance/unicode_rule_label_contract.json; specs/spec.spec; tools/gen_oracle_corpus.pl; rust/linkedspec-runtime/tests/corpus/spec_spec_*/input.spec; dart/lib/src/parser/spec_parser.dart; dart/lib/src/validation/spec_validator.dart; dart/lib/src/compiler/compiled_spec.dart; dart/lib/src/action; dart/lib/src/parser/staged_parser_registry.dart; dart/lib/src/io/spec_loader.dart; dart/lib/src/source_emitter.dart; dart/lib/src/runtime/interpreter.dart
reverify: "shasum -a 256 specs/spec.spec rust/linkedspec-runtime/tests/corpus/spec_spec_*/input.spec; python3 tools/check_semantic_introspection_contract.py; python3 tools/check_unicode_rule_label_contract.py; bash tools/run_dart_local.sh; rg -n '\\\\w|RuleHeader.fromJson|EdgeTarget.fromJson|BareEdgeTarget.fromJson|traceRegexSlotSelected|compiledRuleOrder|buildGeneratedRulePlan|sourceText' specs/spec.spec dart/lib/src -g '*.dart' -g '*.spec'"
---

Dart already owns most semantic meaning in typed, reusable layers. Staged parsing produces `SpecFile` rules and
function sidecars; validation owns accepted topology and `SpecPortableDiagnostic`; `CompiledSpec` owns definition
and compiled order, entry selection, exact rule keys, families/cursor policy, authored regex slots, normalized
action/blind edges, lifecycle payloads, typed ActionIR, and the function registry. `buildGeneratedRulePlan` owns
the existing generated-v2 ordered `{label, family}` plan. Descriptor JSON is a compatibility projection, not the
semantic schema, and neither AST JSON nor emitted Dart implementation source may cross the semantic API.

The behavior-free `.10.5.0` probe establishes these exact current boundaries:

- `graph`, `calls_and_staging`, and `runtime` parse, validate, compile, rebuild through `SpecFile` JSON, and retain
  ordered generated plans; the runtime fixture returns `["A","B"]`;
- `failed.spec` reports `bare_edge_target_undefined` at `normalize_edges`, so Dart needs the same deliberate
  `unknown_rule_reference` / `compile` semantic normalization already required on Rust;
- `privacy.spec` fails before validation at `Töp::` because `spec_parser.dart` uses host `\w` for declarations;
- action and blind references are worse than a clean rejection: `-> Töp` and `=> Töp` parse as target `T`, while
  a bare `Töp` line remains raw; and
- a deserialized/programmatic AST containing invalid label `Top-Rule` passes `validateSpec` and compiles. The
  validator checks existence/collisions but does not apply ADR `0051` to declarations or references.

Once a valid Unicode label is supplied programmatically, current compiled maps, descriptor output, generated plan,
emitted source, and explicit selector preserve `Töp` exactly. That proves these consumers should compare immutable
strings, not reclassify them. The missing prerequisite is one generated Dart Unicode 17 classifier consumed by
header/action/blind/bare scanners and validation of externally constructed ASTs. Function/helper identifiers,
lifecycle markers, fluent methods, and mark names are separate grammars and must not be broadened accidentally.

The audit also found a neutral authority conflict outside Dart's hardcoded parser. ADR `0012` makes
`specs/spec.spec` the first authoritative `.spec` grammar, but its rule-header and edge productions embedded host
`\w`. Shared leaves `.10.5.0.1.0-.1` now resolve that conflict: one generated literal class is independently
checked and consumed at all 12 declaration/reference sites, while Dart derives that atom in its bounded structural
bridge and directly executes current canonical source. This does not change Dart's hardcoded parser/validator;
the Dart-specific label leaf still follows the shared closure rather than claiming parity from grammar alone.

The apparently green self-hosted corpus does not cover that current authority. All four checked-in
`rust/linkedspec-runtime/tests/corpus/spec_spec_*/input.spec` files share stale SHA-256
`e0a1b63b276c2a896c577192d4b399c88f21539555835018ce8117b91a14b25f`; current `specs/spec.spec` is
`43cddeaea03cfaddce941ca87f66185de1abf81e281e86c29156fbad16f6d2ce`. The frozen copies omit the newer
bare-edge productions and retain broad lifecycle `(\w++)`, whereas canonical source has explicit
`(I|LS|LE|LX|E|EX|IT)`. `tools/gen_oracle_corpus.pl` promises and implements a verbatim source copy, so the remaining
defect is missed regeneration/freshness enforcement. Direct Dart execution of current canonical source now passes
after `.10.5.0.1.1` adds explicit lifecycle and bare-edge structural recognition, but the unchanged stale corpus
still cannot prove that route. Leaf `.10.5.0.1.2` must regenerate all four inputs, reject future byte/hash drift,
and compose cross-runtime proof before corpus green counts as current self-hosted grammar evidence.

Exact source evidence is adapter work. Ordinary Dart rule headers/body elements retain one-based lines, while
`ActionSourceSpan` is local to normalized action text rather than a general source map. Function-definition
sidecars are richer and retain source/body spans, payload/job/result policy, and typed body AST. A semantic
constructor must copy accepted decoded text/canonical UTF-8 bytes plus a caller logical name, build zero-based
half-open byte and one-based Unicode-scalar coordinates, and correlate typed owners without exposing AST layout.
`LoadedSpec` retains exact strict-decoded source but also a resolved host path, so it cannot supply semantic identity
implicitly.

Dart has no semantic index or query evaluator today. Runtime already exposes authoritative internal evidence:
`_traceRegexSlotSelected` runs after accepted structural slot selection and the entry wrapper constructs the final
`RuntimeParseResult`. Text trace and `RuntimeDiagnosticOutputSink` are different products. A later leaf must add an
optional invocation-local typed semantic sink at those seams and derive a new immutable observed index; query must
remain unable to execute.

The safe split is shared executable-label authority, Dart Unicode-label parity, opaque source/outcome foundation,
static projection, call/staged/generated projection, immutable query, typed runtime observation, and one composed
admission consumer. Until those leaves pass, semantic governance remains 6 fixture groups / 20 exact queries / 73
rejected mutations, rollout 3 complete / 6 pending, and native admission 2 complete / 4 pending. See
[[unicode-rule-label-contract]], [[semantic-introspection-neutral-contract]],
[[outward-descriptor-is-not-semantic-wire-model]], [[dart-compiled-spec-state]],
[[dart-function-definition-shell-projection]], [[dart-generated-source-v2-rule-local-cursor]],
[[dart-runtime-structured-diagnostics]], and [[dart-native-spec-resolution]].
