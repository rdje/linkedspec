---
id: write-vivification-dart-runtime
title: "Dart preserves one expression-bearing nested-write path through native, reconstructed, generated, emitted, and CLI execution"
answers:
  - "how does Dart implement nested write vivification"
  - "does Dart nested write create absent roots and intermediates"
  - "does Dart distinguish an absent nested write root from bound null"
  - "when does Dart evaluate nested write segments and RHS"
  - "are Dart nested write spans Unicode scalar offsets"
  - "does generated Dart execute write vivification"
  - "does emitted Dart execute write vivification"
  - "does the Dart primary CLI execute write vivification"
  - "how does Dart reject a malformed nested write carrier"
  - "are Dart nested write binding result input and RHS values detached"
  - "does Dart support negative array selectors"
  - "does Dart negative floating minus one select the last array entry"
  - "does Dart signed write resolve array length before or after RHS effects"
  - "does generated Dart preserve caller diagnostic sink exceptions"
date: 2026-10-25
status: write-v1 admitted under FUTURE-PARITY-BACKLOG.19.7; signed Dart implementation owned by TYPE-REFERENCE-BOOK.1.2.17.4, portable signed admission pending
tags: [dart, dsl, actionir, assignment, autovivification, diagnostics, generated-source, cli, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.4.1 replaces authored Dart one-segment assign_hash_index and parser-tagged multi-segment access with ActionWritePathSegment plus one ActionAssignNestedAccessExpr. The permanent contract test projects 5 AST / 7 syntax / 11 success / 16 structural-failure / 3 expression-failure / 3 read-exclusion rows, exact evaluation effects, same-binding composition, detachment, function presence, astral Unicode spans, malformed-carrier rejection, SpecFile JSON reconstruction, native/generated-plan/emitted-source/primary-CLI execution, and independently analyzes/runs the emitted caller package. The complete Dart gate passes format 110/0, strict analysis, 450/450 tests, 24 managed temporary owners / 47 locked packages, CLI 66/66 in default and POSIX environments, and corpus 105/105."
evidence_update_2026_10_25: "Signed17.4 retains clean activation4e6ece603 and the exact whole Dart interpreter image9f0ee763. Public113 programs/452 observations, private51 plus arithmetic12, fresh113 emitted modules and107 CLI programs/214 quiet-trace runs pass. Five actual source inverses reject; exact bytes/mode restoration returns452/0. Original package discovery636, CLI66x2, corpus105 and storage25 pass. Existing SDK format1/analyzer2 debt remains separately owned. Historical134 streams/84613241 bytes/22 recovery controls remain unchanged; exact Dart image admission adds three source denials without changing Rust admissions. Canonical acceptance and publication-input controls remain mandatory before landing."
reverify: "Dated signed17.4 proof: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-dart/publish.py. Capture writers are one-shot and retired after acceptance. Current focused regression: cd dart && bash ../tools/run_dart_project_data.sh test test/signed_array_selector_contract_test.dart test/write_vivification_contract_test.dart; whole-component SDK compatibility debt is owned separately."
---

# Dart write-vivification runtime

Dart now consumes `linkedspec-write-vivification-v1` without changing its spelling:

```text
document[section_name][0]["title"] = title
```

Every authored bracket write, including a one-segment write, lowers to one `ActionAssignNestedAccessExpr`.
`ActionWritePathSegment` retains the ordinary typed expression plus exact authored text and half-open
Unicode-scalar span. Segment spelling no longer decides key versus index: an evaluated string selects an harray,
and an integer selects a dense array. Nonnegative indexes can replace or append at the exact length; a negative
integer selects an existing position at `length + index` and never creates a root, missing child or append slot.

The interpreter evaluates every segment once from left to right and then the RHS once. Only afterward does it
read the root, distinguish absence from an explicitly bound null, copy the post-evaluation root, classify
selectors, validate/build the path, and publish once. Missing roots and intermediates are created only from the
current or next selector. Existing wrong kinds and bound null are conflicts; array index `length` appends while a
larger index is a gap. Expression failures keep their original exception identity. Structural failure publishes
no partial path, while completed ordinary expression side effects remain. Success detaches the committed binding,
returned root, initial aggregate, and aggregate RHS.

`RuntimeDiagnostic` carries the frozen invalid-selector, kind-conflict, and array-gap fields and authored segment
span. Source parsing rejects non-addressable/reserved roots and malformed segments with exact `action_parse`
diagnostics. A public compiled-state validator rejects an empty or structurally invalid typed segment sequence at
direct runtime and generated source/plan boundaries, so programmatic carriers fail closed.

The same node executes after `SpecFile` JSON reconstruction, through a validated generated rule plan, through
fresh emitted Dart source independently analyzed and executed in a managed caller package, and through the Dart
primary CLI. Signed integer reads resolve against their retained receiver and remain non-creating. Dart `map_leaves!` has since composed with these writes under
`.19.4.2`; portable/public capability remains owned by `.19.7-.19.9`.

Related: [[write-vivification-neutral-contract]], [[terse-nested-value-path-assignment]],
[[write-vivification-perl-reference]], [[write-vivification-rust-runtime]],
[[write-map-leaves-neutral-composition]], [[map-leaves-mutation-dart-runtime]], and ADR `0036`.

## Signed Dart boundary

Only actual Dart integers gain negative array indexing. Negative floating values, including `-1.0`, and numeric
strings keep their prior read behavior; floating write selectors retain the existing invalid-selector error.
Maps keep their existing key conversion. Writes evaluate selectors and RHS before reading and copying the root,
then resolve each negative selector against the array encountered during the isolated walk. Underflow retains
the authored index/path and adds `resolved_index`; missing negative targets keep the legacy invalid diagnostic.
The resolved identity guard wins before operand effects. Failed structural creation is discarded while completed
expression effects remain; returned roots, committed bindings, original inputs and aggregate RHS values detach.

Native, SpecFile reconstruction and the validated engine plan expose typed runtime diagnostics. The public
generated wrapper and freshly emitted modules preserve their generic generated error metadata/detail for runtime
failures. Caller diagnostic-sink failures are a separate established boundary: wrappers rethrow the exact caller
exception and stack. The primary CLI emits its stable generic invocation failure, without typed runtime details.
The dated proof retains these carriers separately instead of requiring an invented common error object. Private
store inspection runs an exact byte-verified library copy with a separate observer suffix, without new production
exports; actual authored ordinary/callable grammar and Unicode geometry have their independent public proof.

## September 11 write consumer prefix reading

Dart .1.54 reads write_vivification_contract_test.dart1-292. Neutral literal,
effect-marker and diagnostic helpers preserve fixture expressions and their order.
The malformed-carrier helper retains all surrounding compiled state while replacing
the nested-write segment list with empty. The first test pins syntax inventory and
all five valid AST rows with exact source/spans and typed segments; invalid/excluded
and runtime assertions remain in .1.55. All 43 selected tests pass, including the
whole existing write consumer and emitted caller, but no unread suffix credit is
granted. Neutral write governance remains105 mutations. No source change.

## September 11 complete write consumer reading

Dart .1.55 reads write_vivification_contract_test.dart293-767 through EOF.
Seven exact syntax denials, four exclusions and astral spans precede eleven
success/effect rows, sixteen structural failures, three injected expression
failures, three read exclusions, aggregate detachment, fresh locals and bound-null
conflicts. Injected failures originate in the diagnostic sink and preserve exception
identity and stopped evaluation. Empty typed segments reject at runtime/emission/
plan validation. The representative sections/title write runs after SpecFile
reconstruction, through a generated plan and inline CLI, and in a fresh offline
package whose pub get, analyze and emitted run each require exit0. All20 selected
tests pass, including nine write tests; neutral write remains105 mutations.
Physical coverage is complete; this does not close other owned runtime defects.
