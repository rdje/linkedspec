---
id: perl-match-alias-writability
title: On Perl 5.34.1 the readonly flag does not identify writable match arguments
answers:
  - "does Internals SvREADONLY zero mean an argument is writable"
  - "why does a Perl match argument reject writes with its readonly flag clear"
  - "can copying a Perl match argument change callback behavior"
  - "how is the original Perl match slot distinguished from a copied scalar"
  - "where is match alias writability independently verified"
date: 2026-10-11
status: observed with an independent four-case Perl oracle and an effective callback argument-copy fault
tags: [perl, aliases, callbacks, native-oracle, readonly]
evidence: "The source-bound pure-Perl oracle retains four actual rows on v5.34.1: lexical/literal/match/copied-match flags0/1/0/0 and actual-slot identity1/0/1/1. Lexical and copied-match writes succeed; literal and actual-match writes fail. The legacy callback argument-copy source fault is syntax-valid and causes nine regression failures, including the named actual readonly match-alias assertion. Original observations and full command channels are retained."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-review.py on its original accepted Git inputs. The match-alias.py capture is one-shot."
---

The native legacy callback exposed a false fixture assumption: its match argument
reports `Internals::SvREADONLY` as zero, but assignment still raises Perl's
read-only-value error. The independent probe passes the actual `$1` slot and
checks its reference identity before attempting the write. It receives that same
slot, with a clear flag, and the write fails.

A copied match value has the same text and clear flag, but its lexical slot accepts
the write. A normal lexical scalar is likewise writable; a literal reports a set
flag and rejects the write. These controls distinguish actual write behavior from
the flag alone. The evidence is scoped to the recorded Perl5.34.1 interpreter;
it does not measure other Perl versions or expose an internal scalar layout.

The compiler fix preserves the original argument alias. The regression asserts
the clear native flag and actual write rejection separately. An effective source
fault that copies the argument keeps the clear flag while losing the write
constraint, so value equality or a flag-only test would miss the changed behavior.

Producers and results are retained under the
`docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1-` prefix. The owning repair
is `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1`.
