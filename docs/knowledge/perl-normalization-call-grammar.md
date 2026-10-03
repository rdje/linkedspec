---
id: perl-normalization-call-grammar
title: Frozen normalization uses unsupported infix expressions and needs an explicit call-form successor
answers:
  - "why does normalization fail undefined count when direct count works"
  - "is infix arithmetic admitted in the normalization objective"
  - "which correction owns normalization-calls.spec"
  - "why do raw infix expressions report language agnostic ready"
  - "does correcting the normalization fixture resolve raw expression telemetry"
date: 2026-10-03
status: explicit call-form successor verified; independent raw-readiness repair remains
tags: [perl, normalization, arithmetic, control, readiness, raw-perl, source-binding]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0 tracks eleven native/fresh controls and source-bound review; original fixture/selection/authority bytes and production remain exact. Seven admitted-form controls succeed, two infix host calls fail and two infix host-behavior controls retain incorrect DSL-intent results."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/composed_normalization_perl.t; bash tools/run_python_project_data.sh tools/check_composed_objective_contract.py; inspect the immutable .4.0 diagnosis at its captured revision rather than executing its historical snapshot writer in the current checkout."
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

## Verified successor — 2026-10-03

`.0.4.1` implements that exact source succession. `normalization.spec` remains
ba9953c282e5e66956dc4b7d22c2acc7b1e879734654e7cb467ad41275cc4249;
`normalization-calls.spec` is
f4e45215d893a3c159eb146dd4c37b5008e6670bb52e180e3deebd8139e6a83e.
The governed correction record and independent checker bind the one-loop difference
without changing sixteen case oracles or production. Seven cases on native and fresh
emitted Perl pass21 top-level tests: complete typed values, ordered diagnostics,
quiet execution, exact authored exits and eight actual-object/alias controls.
The narrow historical audit preserves24 checkpoints/257 references/149 inputs/134
logs, with12 CI/six storage/three Phase0 mutations. Earlier diagnosis/pilot results
above remain historical; the full D/P semantic-mutant lane and `.0.5/.0.6/.0.7`
are separate from this correction.

The historical audit's originally disclosed134-input recovery gap is closed by
committed `.0.4.2.1`; [[historical-objective-audit-input-recovery]] retains the
exact archive/restoration boundary. `.0.2.1.2` independently reconciles the explicit
loop difference and seven-case normalization observations before bounded parent
closure. The original infix failure and independent raw-readiness defect remain.

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
