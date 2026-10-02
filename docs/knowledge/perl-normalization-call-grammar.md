---
id: perl-normalization-call-grammar
title: Frozen normalization uses unsupported infix expressions and needs an explicit call-form successor
answers:
  - "why does normalization fail undefined count when direct count works"
  - "is infix arithmetic admitted in the normalization objective"
  - "which correction owns normalization-calls.spec"
  - "why do raw infix expressions report language agnostic ready"
  - "does correcting the normalization fixture resolve raw expression telemetry"
date: 2026-10-02
status: diagnosed; canonical successor and independent raw-readiness repair remain
tags: [perl, normalization, arithmetic, control, readiness, raw-perl, source-binding]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0 tracks eleven native/fresh controls and source-bound review; original fixture/selection/authority bytes and production remain exact. Seven admitted-form controls succeed, two infix host calls fail and two infix host-behavior controls retain incorrect DSL-intent results."
reverify: "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0-probe.pl; bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0-review.py"
---

The arithmetic/comparison contract is callee(args), with explicit nested grouping:
num_add/num_lt, add/lt and +/< call names. The public helper reference explicitly
excludes infix operators. The original selected normalization fixture instead uses
`while(i < count(pieces)) { visited = visited + 1; i = i + 1 }`.

Public AST block parsing marks its condition/increments raw_perl with reason
unsupported_expression. Parser.pm::_parse_expr_without_chain ends with that raw
node (line289). ValueExpr::_lower_assignment_source_expr returns source_passthrough
when no lowerer recognizes the source (line653). Public dumped/emitted handlers
retain `truthy(i < count(pieces))`, bare visited and bare i. Both routes fail at the
host count call. Direct count returns2; num_lt/num_add, lt/add and symbol-call loops
each return2. A scratch successor replacing only the loop yields the exact selected
nested result, visits2 and restored text for ab-cd on both routes. This is one value
pilot, not seven-case/event/detachment or cross-backend execution acceptance.

.0.4.1 selects a canonical, explicit normalization-calls.spec successor with only
that loop corrected. Keep normalization.spec, the original selection/checkpoints,
sixteen case oracles/dimensions/mutation roles and all foundation inputs exact.
Bind original/successor identities and correction owner in normative governance;
recurring registration and historical audit must preserve actual earlier bytes.
No infix grammar extension or silent original-hash refresh is selected.

A separate policy defect survives fixture correction. The infix controls have raw
AST descendants yet report ready1/raw0/fallback0/unresolved0. i=2; i=i+1 returns1;
i=2 with an infix i<1 condition returns yes. CanonicalEvents.pm lines175–234 only
counts unmatched top-level statements; matching helper events conceal nested raw
children. EmitContext::_build_action_rewriter_meta lines1630–1640 derives raw/ready
from those fallback/unresolved counts. ADR0003 requires raw source to be surfaced.
P1 .0.7 owns deeper source/consumer diagnosis and a verified reporting repair after
.0.4/.0.5/.0.6, before dispatcher closeout. The repair scope is not inferred here.

The initial diagnostic instrument incorrectly used parse_action_expr on an entire
statement sequence. It raised nested_write_root_not_addressable during observation.
Using parse_action_block corrects that probe-only error; the failed producer version
and log remain captured. It is not evidence of an accepted compiler regression.
