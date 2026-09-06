---
id: perl-bare-explicit-edge-order-drift
title: Perl normalizes bare edges after explicit edges and can reverse authored execution order
answers:
  - "why does a bare edge before an explicit edge execute second"
  - "why do Perl resolved_edges and dependency_refs have different order"
  - "can mixing bare and explicit edge spellings change OR priority"
  - "why does an AND rule call explicit children before earlier bare children"
  - "which task repairs Perl bare explicit edge ordering"
date: 2026-09-06
status: confirmed native parser-result defect; SESSION-STARTUP-READING.12 owns repair after required reading
tags: [perl, rule-ir, normalization, edges, ordering, descriptor, defect]
evidence: "SESSION-STARTUP-READING.3.2.11 read all 987 RuleIR lines at unchanged baeb984e and used Get descriptor/native probes plus direct collect/normalize probes. Bare-first OR returns second with reversed dependencies despite authored metadata; three equivalent-spelling controls return first. Bare-first AND returns second then first. Source collection separates bare candidates; normalization appends them to executable arrays while metadata independently uses edge_sequence."
reverify: "rg -n 'bare_edge_entries|edge_sequence|push @.*acode_entries|push @.*bcode_entries|resolved_edges' perl/LinkedSpec/RuleIR.pm"
---

The public reference accepts this one-ownership OR source:

```text
Top::OR
 First { return("first") }
 -> Second { return("second") }

First:
 /x/

Second:
 /x/
```

For input `x`, the parser returned by `LinkedSpec::Get` yields `["second"]`. The descriptor's `resolved_edges` retains
`First, Second`, but `dependency_refs` is `Second, First`. Replacing the two edge prefixes gives:

| First / Second spelling | Result | Dependency order |
| --- | --- | --- |
| Bare / explicit `->` | `["second"]` | Second, First |
| Explicit `->` / bare | `["first"]` | First, Second |
| Bare / bare | `["first"]` | First, Second |
| Explicit `->` / explicit `->` | `["first"]` | First, Second |

Every control's metadata retains authored `First, Second`. A separate `Top::AND` with bare `First`
then `=> Second`, and child I-blocks returning their names, returns `["second","first"]` while
its metadata again says `First, Second`. Neither example mixes action and blind ownership.

The direct owner probe isolates the mechanism without the bootstrap/emitter/runtime:

1. `_collect_rule_ir` retains explicit ACODE/BCODE entries immediately but stores bare candidates in
   `bare_edge_entries`. It also retains the complete authored metadata order in `edge_sequence`.
2. `_normalize_rule_ir_edges` appends normalized bare entries to the already populated executable arrays.
   The bare-first control therefore changes from collected explicit `[Second]` to `[Second, First]`.
3. The same function builds descriptor `resolved_edges` independently from `edge_sequence`, yielding
   `[First, Second]`. The discrepancy exists before emission and is visible in public parser results.

Repair `.12` must preserve one authored execution order across both spellings and reconcile metadata,
dependency slots, native handlers, and supported generated carriers. Per-regex lifecycle actions and
grouped/named/indexed/repeated cases need independent controls so correcting bare normalization does not
drop synthetic actions or reorder duplicate slots. Generated and other-backend failures were not measured
in this reading slice; their comparison belongs to the repair verification. Product source remains unchanged.

Related: [[perl-rule-local-cursor-rollout-boundaries]], [[rule-local-cursor-and-bare-edge-contract]],
[[spec-edge-syntax-contract]], [[perl-sparse-and-structural-slots]].
