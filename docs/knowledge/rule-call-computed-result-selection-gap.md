---
id: rule-call-computed-result-selection-gap
title: Rule-call direct bracket reads lack a governed source role and named selector writes hit recovery
answers:
  - "can call Child results be indexed directly before String methods"
  - "why does call Child bracket selection fail Perl compilation"
  - "why does an assignment in a closed named array selector report a nested write error"
  - "which task owns rule-call result selection and closed selector recovery"
date: 2026-10-30
status: target54 frozen; P1 closed-read prerequisite54.0 before Perl54.1; peers independent
tags: [perl, actionir, selection, rule-call, parser, fluent, effects]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.1.15; rule-call-result-selection-intake.json.gz retains six healthy controls, two direct Array/Hash failures, scalar null policy, minimal closed-read distinction, healthy shared13 fluent carrier and actual instrument epochs/inputs."
reverify: "Recover probe_rule_call_result_assessment.pl/finite cases from rule-call-result-selection-intake.json.gz; run project Perl wrapper with explicit local outputs. No historical source swaps."
---

At2b3135fa2, primitive/bound/method rule-call results already work native/fresh.
Direct brackets after call(Child) fail compilation with raw1/unready. Existing
MethodLowering early call value dispatch supplies the original child-handler ABI;
AST Parser::_parse_value_access_expr delegates direct Call acceptance to
MethodLowering::_actionir_ast_computed_data_call_method, which excludes call.
54.1 owns a governed ordinary role through existing typed value_access, retaining
callable/deferred/function/child-frame/cursor/error and format contracts.

Separately, a valid closed named-array read with selector assignment raises
nested_write_segment_unclosed. The recovery-only branch of AST Parser::
_find_nested_write_assignment_eq treats the inner assignment as a write delimiter
without establishing an unclosed segment. Existing fluent carrier returns the
same expected [TAIL,I]. P1 prerequisite54.0 owns a narrow parser repair and real
write/diagnostic preservation before54.1. This does not grant computed writes.

Original String-character expectation and probe/calibration faults are disclosed
in the target and packet; only valid Array/Hash gaps/closed-read RED get product
credit. No production or peer/portable/isolated package/full admission here.
