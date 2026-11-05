---
id: perl-count-copy-rejection
title: Perl Count copy chains retain rejection separately from legitimate null
answers:
  - "how does Perl Count preserve rejection through copy and defaults"
  - "why must Count copy retain a separate rejection flag instead of testing null"
  - "does Count add invalid copy with still run for legitimate null"
  - "where is the Count copy source regression normal"
  - "which task owns slow compilation of long Count repeated-copy receiver chains"
date: 2026-11-05
status: focused copy repair; logical follow-up independently focused-checked; full admission separate
tags: [perl, count, copy, rejection, null, composition]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.73.6.1; docs/checkpoints/count-copy-perl-2026-11-05/ retains before/after actual owner, fixture, normal, emitted modules, public lowerings and raw channels."
reverify: "source tools/project_data_env.sh; perl -Iperl t/count_copy_source_composition.t"
---

Canonical Count's ordinary copy chain must remain in the emitted actual-kind
dispatcher. Generic logical/copy folding otherwise lowers the prefix separately,
converts its rejection into an ordinary null value, then permits a default or
with body to run. `guarded_copy_chain` includes Count beside presence, membership
and index sources, while logical producers retain their separately owned route.

The existing per-chain rejection flag is the authority: it skips later consumers,
defaults and bodies after an incompatible consumer. Numeric-domain null from
`count([]).add("bad")` leaves that flag clear, so copying still permits default
and with. Number0, String0, Bool and null remain distinct. Initial non-array-zero
source behavior, copied receiver kind guards, source/error/snapshot/function and
existing copy-depth policies remain unchanged.

The maintained normal combines the frozen source/copy controls with receiver and
repeated-copy, no-with, legitimate-null/default and function controls. It checks
native context errors, actual fresh loading/execution, readiness and warnings
independently. Capture writers are historical one-shot producers; rerun the normal
for current behavior. Logical folding73.6.6 is now independently focused-checked
in [[perl-count-logical-rejection]]. Complete input custody23.4.2, registration
and full23.4 remain open, not inferred from this fix.

The original larger added receiver/repeated-copy program remains in the baseline
capture after its compilation is interrupted. Bounded public parse_only and
substitution probes also stop before completion; a scoped substitution trace
reaches MethodLowering/ValueExpr compatibility lowering. This establishes a
pre-execution concern, not an exact amplification root cause or runtime hang.
P2 owner73.7 schedules diagnosis/repair after the six P1 Count repairs. The
smaller maintained repeated-copy control does not close that owner.
