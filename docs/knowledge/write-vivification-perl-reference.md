---
id: write-vivification-perl-reference
title: "Perl reference nested writes vivify typed string/integer paths atomically"
answers:
  - "does Perl currently autovivify nested assignment paths"
  - "how does Perl distinguish an absent nested write root from bound null"
  - "does a dynamic string nested write segment select a Perl harray"
  - "does a dynamic integer nested write segment select a Perl array"
  - "what Perl runtime owns nested write vivification"
  - "are Perl one segment and multi segment writes one ActionIR node"
  - "does Perl nested write vivification work inside user functions"
  - "what typed errors does Perl nested write vivification throw"
date: 2026-08-31
status: current on the Perl reference under FUTURE-PARITY-BACKLOG.19.2.1; portable capability admitted under .19.7
tags: [dsl, actionir, assignment, autovivification, diagnostics, perl, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.2.1 unifies one- and many-segment bracket assignment as expression-bearing assign_nested_access, lowers evaluated segments left-to-right then RHS once, tracks absent versus explicitly bound null per rule/function invocation, and delegates isolated dense creation to LinkedSpec::BindingRuntime::nested_write. The runtime classifies evaluated strings as harray selectors, integer scalars as array selectors, and integral-valued number scalars as invalid numbers; it throws exact typed segment/kind/gap objects, snapshots after completed same-binding expression effects, commits no partial path, and returns detached updated roots. t/write_vivification_perl_contract.t projects all 5 AST and 7 syntax cases plus 11 success, 16 structural failure, dynamic-kind fidelity, detachment, evaluation, same-binding, both null-assignment spellings, exact live spans, and user-function boundaries from the frozen v1 fixture. Permanent ActionIR/trace/uniform suites pass 50 tests; a fresh exact-tree Phase 0 passes all 1,032 in 963 seconds after the earlier 12 stale source expectations were repaired. At this Perl-only milestone, Rust, Dart, Julia, and Lua retained their earlier behavior pending .19.3-.6; portable/public admission was outside its scope."
reverify: "prove -Iperl t/write_vivification_perl_contract.t t/actionir_ast_parser.t t/trace_actionir_method_lowering.t t/uniform_binding_contract.t && bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py"
---

# Perl reference write vivification

Perl now implements the frozen `linkedspec-write-vivification-v1` contract for assignments rooted at a bare
working binding:

```text
document[section_name][0]["title"] = title
```

Every bracket is an ordinary value expression. Its evaluated kind chooses the container: string selects harray,
and nonnegative integer selects zero-based array. Segments evaluate once from left to right, followed by the RHS.
The runtime then snapshots the post-evaluation binding and builds on an isolated copy. An absent root and missing
intermediates are created from the current/next selector kind; existing null or another wrong kind is never
coerced; arrays may replace or append exactly at length but may not create a gap.

The rule/function lowering owns an invocation-local presence map because Perl `undef` alone cannot distinguish an
unassigned lexical from an explicitly assigned null. User-function parameters begin present, including an `undef`
argument, while a fresh local target begins absent on every call.

Invalid selectors, kind conflicts, and gaps throw
`LinkedSpec::BindingRuntime::NestedWriteError` objects with the frozen codes, binding, failing segment, detached
valid prefix, authored Unicode-scalar span, and kind/gap fields. Expression failures propagate unchanged. A
structural failure commits no partial path, although a segment/RHS side effect already completed before the
snapshot remains ordinary program state. Success detaches the committed binding, expression result, initial tree,
and aggregate RHS.

Reads are unchanged and never create state. This card owns the Perl milestone. The intermediate rollout
snapshot recorded Rust/Dart completion and Julia write-only progress while Lua was pending. September 6
reading qualifies that snapshot as historical: later portable admission, six-runtime recurrence, and public
closeout belong to `FUTURE-PARITY-BACKLOG.19.7`, `.19.8`, and `.19.9`, respectively.

Related: [[write-vivification-neutral-contract]], [[terse-nested-value-path-assignment]],
[[uniform-binding-neutral-contract]], [[write-map-leaves-neutral-composition]], and ADR `0036`.
