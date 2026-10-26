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
status: arithmetic current; numeric comparison result rollout frozen
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

TYPE23.2.15 freezes compatible comparison result continuation as a new feature;
prior terminal scope was intentional. Public Perl native/fresh gives six true/
false numeric pairs, strict invalid-null and nested[1!,0!,2,X]. Continued methods
currently lower to undef before effects, versus nested1!/SOC/final-null. WHY:
MethodLowering _number_receiver_value_chain_return_family marks them terminal;
preflight rejects later links. Missing/extra short calls already skip effects.
Frozen numeric-comparison-results.md / implementations23.3.15.1-.5 preserve
strict domains, raw numeric kinds, source order and defaults/bridges. Perl1 is
next; other backends require independent controls, no inferred producer defect.
Canonical num_* method names remain outside this short-method result scope.

Array reducers have their own current result/arity contract:
[[terse-array-numeric-reducer-receiver-methods]]. Statement/lifecycle declare is
not a Number method. Block/user-function results use their actual returned kind.

Original July1 implementation, exact source/commands,999-test evidence and then-
terminal comparison/reducer policy are preserved in this file at Git
77a853d50d4cfbcd02d125b6e591cf987e2f2786. Historical next2.3.5.5 described block-yielded
receiver work; current work follows MEMORY.md, not that old milestone pointer.
