---
id: perl-private-emission-foundation
title: Private emitted fragments belong to one actual producer callback and source invocation
answers:
  - "how does Perl bind emitted source fragments to actual callbacks"
  - "can equal custom callback output inherit an emission packet"
  - "are duplicate source copies preserved in private emission packets"
  - "is the private emission foundation integrated with runtime replacement"
date: 2026-10-09
status: standalone foundation verified; producer and mapping integration open
tags: [perl, actionir, source-emission, callback, provenance]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1 verifies the recovered two-owner foundation with62 independent fixture assertions and16 effective production-source inverses. Initial ineffective/masked inverses and their corrected actual channels remain retained."
reverify: "PERL5LIB= prove -v -Iperl t/actionir_source_emissions.t; original source-bound proof and limits live under docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1-* and its owning claim."
---

`perl/LinkedSpec/ActionIR/SourceEmissions.pm` retains construction packets in a
private side table belonging to the actual registered callback, event, capture
object and `SourceOrigins` invocation token. Ordinary results stay scalar strings;
reference/undefined results and opaque callbacks preserve their result without
gaining source authority. Scalar context, argument aliases, reference identity,
single invocation and exception objects are fixture-verified.

Explicit append operations distinguish generated pieces from copies validated
against selected original character coordinates. Consumed occurrences are
recorded separately. Equal text selects no occurrence. Duplicate copies remain
separate fragments; later translation must decide ambiguity and consumption.
Returned descriptive packets are detached and cannot transfer retained authority.
Nested source/producer/capture scopes restore their enclosing state on success
and fatal errors, including equal-source nested invocations.

This foundation is standalone. Actual built-in producer registration, argument/node
input authority, typed and raw emission construction, interval translation, full
guarded Phase0 and independent canonical admission remain separately owned by the
selected repair plan. The quoted-first replacement defect remains open. The
original absent-module RED establishes availability only; the sixteen effective
source inverses supply the distinguishing semantic RED evidence.
