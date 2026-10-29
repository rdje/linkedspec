---
id: perl-invocation-handler-failure-provenance
title: Native Perl preserves real child handler failures using scoped record identity
answers:
  - "how does Perl preserve a real child runtime error through a defined parent value"
  - "why can synthetic stale runtime_handler context still be cleared"
  - "does native child error repair preserve the original exception object"
  - "does the Perl handler error provenance marker persist across parser calls"
date: 2026-10-29
status: bounded41.1 native repair verified; canonical selection/named47/referenced-blind48/Phase0 owner45/full admission separate
tags: [perl, errors, provenance, context, recovery, identity]
evidence: "TYPE41.1 perl-nested-error-repair-intake.json.gz retains actual9-source/22-call RED/GREEN,12 repaired losses/2 direct/8 healthy,30 selected groups and75 canonical nested assertions plus discovery."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/nested_handler_error.t t/capture_reset_value_block.t t/capture_boundary_number_results.t"
---

RuntimeContext owns a private slot dynamically localized by Compiler per parser
invocation. SpecEntry compile/eval failure records through the actual-failure
setter. The slot points to the existing last_error record and qualifies only
while that identical record remains current. Owning clear/replacement invalidates
it; the first actual child error remains original if a parent later fails.

Compiler returns undef/original inner eval error/context for a real failure even
when a parent constructs a defined value. Synthetic stale-context success is
unmarked and retains its existing clear branch. Ordinary null/nonmatch and next-
call reset remain; no public diagnostic field/schema/new exception/helper grant.

Normal6/9 groups RED ->9pass. Qualified9-source/22-call proof repairs12 actual
nested losses, preserves2 direct failures and8 exact healthy observations/cursors.
Normal tests verify original exception object identity and no scoped key leakage.
Three selected files30 groups/six canonical groups75 nested assertions plus
discovery and three module syntax pass. Only volatile NONE timestamp prefixes
normalized for direct/forced-compile controls, full raw channels retained. All
source/rewriter/emitted bytes and fresh outcomes/public metadata remain exact;
actual old9 modules replay before native emission, no regeneration required.

Initial pointer preparation asserted clean after the sole owned normal test was
prepared; allowed-file assertion corrected before production. Initial reader
wrongly demanded timestamp byte identity for canonical forced-compile trace;
instrument corrected without product/test changes. No peer/full gate/admission
claim; named47/referenced-blind48/Phase0 owner45, readiness31.6.4.4/SESSION17 and
exact normal canonical selection23.4.1 remain separately owned.
