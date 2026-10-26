---
id: terse-number-receiver-value-chains
title: SPEC-FORMAT-TERSE.2.3.5.4 number receiver-dot value chains
answers:
  - "how do number receiver-dot value chains work"
  - "does score.abs().ceil().add work"
  - "does 5.mod(2) work"
  - "does 3.5.floor().add(1) work"
  - "are numeric comparison receiver methods terminal"
  - "can number terminal methods continue"
  - "are declare methods terse receiver methods"
  - "is declare a number receiver method"
  - "which task follows SPEC-FORMAT-TERSE.2.3.5.4"
date: 2026-10-26
status: Perl/Rust/Dart/Julia comparison results checked; Lua pending
tags: [number, numeric, receiver, scalar, result, spec-format-terse]
evidence: "SPEC-FORMAT-TERSE2.3.5.4 arithmetic; scalar_numeric_contract.json; TYPE23.2.15 public native/fresh/substitution and numeric-comparison-results.md."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_numeric_comparison_results.pl"
---

Number methods map short names to num_* helpers. Arithmetic chains compose:
score.abs().ceil().add(2,3).mul(2).sub(1).div(2).clamp(0,20).max(5).min(12),
5.mod(2),3.5.floor().add(1),3.5.round(). Scalar numeric policy accepts finite
numbers/untrimmed decimal Strings and rejects Bool/null/containers/bad inputs.
Comparison free functions return numeric1/0 or null, require two operands;
short eq/ne/gt/ge/lt/le receiver methods supply the first from their source.

TYPE23.2.15 freezes short comparison continuation. Perl15.1 uses scalar_result,
Number->Array dispatch after split and String-prefix numeric handoff; raw .eq/.gt
residue exposed missing bridges.59 shared/actual AST/Phase0/outer assertions pass;
seven outer rows become0x/1x/read-once, deferred/unknown-tail boundaries unchanged.
Rust15.2 removes dynamic/Number-loop terminal fences, uses shared scalar result
handoff and one-RHS preflight; eight numeric/direct/calibration tests pass native/
restored/plan after null/SO/twelve-effect RED. Producers retain numeric1/0/strict
invalid-null; source/SOC/once-only, default8/bridges and Array index kinds pass.
Canonical -0.5 literal replaces setup bare-.5, retaining String"-.5" control;
twelve shared Perl assertions pass. Dart15.3 keeps correct producers/valid flow,
fixing scalar Array[] and24 effects through common one-RHS/scalar guard set; six
focused tests/fatal analysis pass. Julia15.4 independently fixes the same guards;
42 strict numeric/direct assertions pass with Number/not-Bool identity. Lua
needs independent controls;
full admission23.4 separate. Canonical num_* method names are outside this scope.

Array reducers have their own current result/arity contract:
[[terse-array-numeric-reducer-receiver-methods]]. Statement/lifecycle declare is
not a Number method. Block/user-function results use their actual returned kind.

Original July1 implementation, exact source/commands,999-test evidence and then-
terminal comparison/reducer policy are preserved in this file at Git
77a853d50d4cfbcd02d125b6e591cf987e2f2786. Historical next2.3.5.5 described block-yielded
receiver work; current work follows MEMORY.md, not that old milestone pointer.
