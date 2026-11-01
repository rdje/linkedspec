---
id: perl-count-result-source-guards
title: Perl Count continuation guards preserve existing source owners
answers:
  - "how does Perl count reject container consumers before their operands"
  - "why must Count source zero fallback exclude existing emitted result owners"
  - "does the Perl Count guard repair change copied-null source behavior"
date: 2026-11-01
status: targeted-checked; full admission and copy assessment separate
tags: [perl, count, guards, source, copy, composition]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.73.1; count-guard-perl-intake.json.gz retains baseline/intermediate/final observations, public lowering and owner bytes."
reverify: "perl -Iperl t/count_result_guard_composition.t; perl -Iperl t/count_result_guard_source_fences.t; perl -Iperl docs/checkpoints/type-operation-inventory/count-guard-perl-source-probe.pl"
---

`MethodLowering.pm` recognizes canonical free-one Count sources and ordinary
zero-extra receiver prefixes. They join the existing emitted actual-kind,
immediate-with rejection-state and per-link dispatch roles. Array/Hash consumers
reject before their operands; completed source effects remain, and legitimate
null results still enter `with`. The source is captured once.

The initial receiver Count keeps its old non-array-zero fallback only when the
receiver has no pre-existing emitted-result owner. Applying the exception to all
initial Count links changes `{undef}.copy().count()` from null to zero. The
separate observational diagnostic caught that intermediate candidate. Preserve
existing source owners rather than using Count to bypass their kind guards.
Copy folding and the Count producer are unchanged; independent73.6 assessment
owns copy/source/rejection combinations before unrelated feature selection.

The finite authored primary16 and separate six-zero/one-null diagnostic pass on
native/fresh Perl with ready metadata and warning-free execution. Baseline six
primary failures, the rejected intermediate diagnostic, original source18 and
selected Count/length/producer/copy checks are retained. This is focused proof,
not complete family, generated-context, portable or canonical admission.
