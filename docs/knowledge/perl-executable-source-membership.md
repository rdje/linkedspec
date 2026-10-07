---
id: perl-executable-source-membership
title: Private Perl source selection requires original event-bound scalar authority
answers:
  - "how are helper-looking quoted occurrences excluded from executable membership"
  - "does the source membership selector change compiler discovery"
  - "why must a literal receiver quote opener remain executable"
  - "can equal raw event text authorize source membership"
  - "which tests verify private executable source membership"
date: 2026-10-07
status: selector connected to compiler; callable correction and canonical membership acceptance remain open
tags: [perl, actionir, scanner, source-membership, source-span, identity]
evidence: "The private SourceMembership selector uses actual producer event references and original scalar intervals; the original scanner/source/compiler remain unchanged. The authored fixture includes36 sources plus five authority/error guards. Closed before/after proof and distinguishing actual producer variants are retained under SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0."
reverify:
  - "bash tools/project_data_run.sh prove -v -Iperl t/actionir_executable_source_membership.t"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1-review.py"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2-review.py"
---

`SourceMembership::_select_executable_source_events` reuses MethodExpr's host
quote, helper-pattern and numeric-slash contracts. It rejects an occurrence whose
original start lies inside literal data. A start at the delimiter remains eligible:
`' 雪 '.trim()` is a genuine literal receiver. Arguments are never parsed from
masked source; event, argument and selected-origin objects remain the originals.

Only an origin bound to the actual event object and the exact action source can
authorize coordinates. Missing or foreign origins keep the original result.
Copied equal-raw events grant no authority. Matching-source spans must be scalar,
bounded and recover the exact raw slice; malformed authority fails explicitly.
An unchanged selection returns the original scan object. Active selection
preserves caller error state through OwnerDispatch.

The original syntactic scan is retained. Compiler discovery now reaches the
selector through Scanner::_scan_executable_contract_ir_events and the existing
EmitContext dependency callback. Retrieve [[perl-compiler-source-membership]]
for compiler and native/fresh behavior. Original .2.0 reviewer and supplemental
proof are historical at31395e440; replay there rather than refreshing them against
changed compiler or teaching inputs.
Precise replacement .0.3 and source-comment classification .7.3 remain separate.
The36 authored sources cover lexical membership and seven representative producer
families, not all174 contracts, arbitrary callbacks, native execution or new
grammar/backend admission. Numeric slash and indexed quote forms used by the
scanner fixture are lexical controls rather than executable-syntax promotion.

Initial closed evidence correctly failed review because one baseline probe
emitted the known `project_data_run.sh` setpgid warning despite exit0. Exact
original snapshots and the actual reviewer rejection remain retained; subsequent
host remeasurement uses the unchanged producer and oracle. The startup defect
remains owned by `SESSION-STARTUP-READING.7`; recovery/purge are prohibited.
