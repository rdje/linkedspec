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
date: 2026-09-02
status: implemented under FUTURE-PARITY-BACKLOG.19.4.1; Dart map_leaves! and portable/public admission pending
tags: [dart, dsl, actionir, assignment, autovivification, diagnostics, generated-source, cli, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.4.1 replaces authored Dart one-segment assign_hash_index and parser-tagged multi-segment access with ActionWritePathSegment plus one ActionAssignNestedAccessExpr. The permanent contract test projects 5 AST / 7 syntax / 11 success / 16 structural-failure / 3 expression-failure / 3 read-exclusion rows, exact evaluation effects, same-binding composition, detachment, function presence, astral Unicode spans, malformed-carrier rejection, SpecFile JSON reconstruction, native/generated-plan/emitted-source/primary-CLI execution, and independently analyzes/runs the emitted caller package. The complete Dart gate passes format 110/0, strict analysis, 450/450 tests, 24 managed temporary owners / 47 locked packages, CLI 66/66 in default and POSIX environments, and corpus 105/105."
reverify: "bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py && bash tools/run_dart_local.sh"
---

# Dart write-vivification runtime

Dart now consumes `linkedspec-write-vivification-v1` without changing its spelling:

```text
document[section_name][0]["title"] = title
```

Every authored bracket write, including a one-segment write, lowers to one `ActionAssignNestedAccessExpr`.
`ActionWritePathSegment` retains the ordinary typed expression plus exact authored text and half-open
Unicode-scalar span. Segment spelling no longer decides key versus index: an evaluated string selects an harray,
and a nonnegative integer selects a zero-based dense array.

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
primary CLI. Reads remain unchanged and non-creating. This leaf does not implement Dart `map_leaves!` and does not
admit a portable/public capability; those boundaries remain owned by `.19.4.2` and `.19.7-.19.9`.

Related: [[write-vivification-neutral-contract]], [[terse-nested-value-path-assignment]],
[[write-vivification-perl-reference]], [[write-vivification-rust-runtime]],
[[write-map-leaves-neutral-composition]], and ADR `0036`.
