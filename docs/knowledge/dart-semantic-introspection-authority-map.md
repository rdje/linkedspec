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
  - "does Dart execute freshness-locked current specs/spec.spec"
  - "can Dart generated metadata reconstruct a semantic index"
  - "does Dart compiled state preserve Unicode rule labels"
  - "which Dart routes prove exact Unicode rule label identity"
  - "is specs/spec.spec aligned with Unicode rule labels"
  - "what are the Dart semantic introspection implementation leaves"
date: 2026-07-22
status: current
tags: [dart, semantic-introspection, unicode, rule-labels, source-map, diagnostics, runtime, generated-source]
evidence: docs/tasks/FUTURE-PARITY-BACKLOG.md leaves .10.5.0 and .10.5.0.2.0-.2; docs/decisions/0012-staged-linked-parsing-architecture.md; docs/decisions/0049-versioned-semantic-introspection-model-and-thin-mcp.md; docs/decisions/0051-unicode-17-xid-continue-rule-labels.md; capability_conformance/semantic_introspection_model.json; capability_conformance/unicode_rule_label_contract.json; specs/spec.spec; tools/gen_oracle_corpus.pl; rust/linkedspec-runtime/tests/corpus/spec_spec_*/input.spec; dart/lib/src/parser/unicode_rule_label.dart; dart/lib/src/parser/spec_parser.dart; dart/lib/src/validation/spec_validator.dart; dart/test/unicode_rule_label_routes_test.dart; dart/test/unicode_rule_label_identity_routes_test.dart; dart/lib/src/compiler/compiled_spec.dart; dart/lib/src/action; dart/lib/src/parser/staged_parser_registry.dart; dart/lib/src/io/spec_loader.dart; dart/lib/src/source_emitter.dart; dart/lib/src/runtime/interpreter.dart
reverify: "shasum -a 256 specs/spec.spec rust/linkedspec-runtime/tests/corpus/spec_spec_*/input.spec; python3 tools/check_semantic_introspection_contract.py; python3 tools/check_unicode_rule_label_contract.py; cd dart && dart test test/unicode_rule_label_identity_routes_test.dart && cd ..; bash tools/run_dart_local.sh; rg -n '\\\\w|isRuleLabel|takeRuleLabelPrefix|RuleHeader.fromJson|EdgeTarget.fromJson|BareEdgeTarget.fromJson|traceRegexSlotSelected|compiledRuleOrder|buildGeneratedRulePlan|sourceText' specs/spec.spec dart/lib/src -g '*.dart' -g '*.spec'"
---

Dart already owns most semantic meaning in typed, reusable layers. Staged parsing produces `SpecFile` rules and
function sidecars; validation owns accepted topology and `SpecPortableDiagnostic`; `CompiledSpec` owns definition
and compiled order, entry selection, exact rule keys, families/cursor policy, authored regex slots, normalized
action/blind edges, lifecycle payloads, typed ActionIR, and the function registry. `buildGeneratedRulePlan` owns
the existing generated-v2 ordered `{label, family}` plan. Descriptor JSON is a compatibility projection, not the
semantic schema, and neither AST JSON nor emitted Dart implementation source may cross the semantic API.

The behavior-free `.10.5.0` probe established these exact audit-time boundaries:

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
strings, not reclassify them. The generated Dart Unicode 17 classifier/complete validator/prefix scanner now exists
and is independently locked, including supplementary-safe UTF-16 slicing. Native header/action/blind/bare parsing
consumes it, prevents invalid suffix truncation, and validation rejects invalid declarations/targets from parsed,
JSON-reconstructed, and programmatic ASTs with one portable diagnostic. Function/helper identifiers, lifecycle
markers, fluent methods, and mark names remain separate grammars. All nine positive fixtures and both distinct
pairs now retain exact identity through compiled maps/order, descriptors, generated plans, reconstruction,
isolated emitted-package execution, selectors, diagnostics, traces, strict loading, and primary commands. The
remaining label prerequisites are exhaustive negative rejection and unrelated-identifier isolation before
composed signoff.

The audit also found a neutral authority conflict outside Dart's hardcoded parser. ADR `0012` makes
`specs/spec.spec` the first authoritative `.spec` grammar, but its rule-header and edge productions embedded host
`\w`. Shared leaves `.10.5.0.1.0-.1` now resolve that conflict: one generated literal class is independently
checked and consumed at all 12 declaration/reference sites, while Dart derives that atom in its bounded structural
bridge and directly executes current canonical source. The native Dart parser/validator now follow that shared
closure rather than claiming parity from grammar alone.

The earlier apparently green self-hosted corpus did not cover current authority: all four `spec_spec_*` inputs were
stale identical copies. Shared closeout `.10.5.0.1.2` regenerated them verbatim from canonical `specs/spec.spec`,
added byte/hash freshness enforcement, and composed current grammar across Perl, Rust, Dart, Julia, and Lua under
both command environments. Corpus 105/105 now refers to freshness-locked current source rather than the former
snapshot.

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
