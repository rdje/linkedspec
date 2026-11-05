---
id: perl-count-logical-rejection
title: Perl Count logical consumers run inside the persistent rejection chain
answers:
  - "how does Perl Count preserve rejection through and or not with or without copy"
  - "why does Count take and with run after a rejected prefix"
  - "do valid Count null and zero still evaluate eager logical operands"
  - "does Count logical rejection change malformed receiver shape preflight"
date: 2026-11-05
status: focused repair; source-domain peers and full admission separate
tags: [perl, count, logical, copy, rejection, eager, null]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.73.6.6; docs/checkpoints/count-logical-perl-2026-11-05/ retains unchanged14-case before/after owner/normal/fixture, actual pre-load emitted modules, public lowering and raw channels."
reverify: "source tools/project_data_env.sh; perl -Iperl t/count_logical_source_composition.t"
---

Canonical Count chains containing and/or/not bypass generic logical/copy folding.
That folding otherwise lowers the prefix separately and passes ordinary null
to the logical producer after an incompatible consumer, losing rejection state.
The existing Count dispatcher now carries its flag through logical and copy links
with or without a final with. Each logical link reuses the existing typed eager
producer over the captured current value and authored operands; no new truthiness,
arity, Boolean conversion or lazy policy is introduced.

Malformed receiver shapes still preflight before source effects. Valid null and
Number0 leave the rejection flag clear, so logical operands run eagerly in order;
needed errors propagate. Incompatible consumers set the flag before their
operands and later logical/default/with bodies. Actual Boolean results still
dispatch by kind, including rejection before a later Array consumer/copy/with.
Source-once snapshots, function bindings and copied-source Count guards remain.

The finite fourteen native/fresh groups retain seven baseline value/effect REDs
and fourteen final passes, warning-free with ready metadata. P2 compiler scaling73.7,
Rust/peer source repairs, recurring registration, complete input custody and full
admission remain separate. Historical acquisition writers must not be replayed.
