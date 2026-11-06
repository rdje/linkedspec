---
id: perl-hash-view-initial-source-ownership
title: Perl initial Hash views keep producer policy before Array result guards
answers:
  - "did Perl Hash-view guards change initial receiver source policy"
  - "why does undef sorted_values with stop running its empty Array body"
  - "why did initial Array Hash-view errors become null"
  - "which task repairs first-view source permission and numeric sorted_keys isolation"
  - "why does sorted_keys numeric3 no longer read main Hash3"
  - "does sorted_keys preserve initial Array errors and valid named Hashes"
date: 2026-11-06
status: eight76.1 regressions and bounded numeric source drift repaired with focused59 proof
tags: [perl, hash, arrays, source, guards, regression]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.76.6; hash-view-receiver-policy-perl-2026-11-06/REVIEW.md retains same-path original/current13, localized numeric4/three states/native-fresh proof and unchanged17 normal11RED to17PASS/direct59. All13 original policies restored,12 healthy observations exact,25 final/direct module+handler pairs equal; eight recovery corruptions pass."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -j1 -Iperl t/hash_view_receiver_source_policy.t t/hash_view_result_guard_composition.t t/sorted_values_scalar_isolation.t t/copy_result_guard_composition.t"
  - "bash tools/run_python_project_data.sh docs/checkpoints/hash-view-receiver-policy-perl-2026-11-06/review.py"
---

Original684597174 owner versus currentf5dded000 owner at one private path shows
eight regressions introduced by76.1. Initial Number/null sorted_keys/sorted_values
returned[]; current returns null. Initial Array sources raised their existing
Not-a-HASH-reference native/fresh errors; current suppresses them. Both null-source
with bodies originally yield[0,W], but current gives[null,empty]. Five valid Hash/
produced Count/CountKeys/Length controls are unchanged. No Rust policy is imported.

Perl76.6 restores all13 original semantic observations, with only generated eval
serials normalized. Terminal first views retain the original producer; longer
chains lower that first step once before guarding the produced Array. Existing
produced/selected/copy/size/logical owners keep their guards. The new17 normal moves
11failed groups to17PASS; direct four files59 pass. Twelve pre-change healthy
observations and25 actual final/direct module+handler pairs stay exact. Eight
readonly recovery corruptions reject. Regenerate affected emitted Perl.

Actual substitution puts `ref($__ls_selected_default) eq 'HASH'` before the first
view producer. MethodLowering's new view source role conflates initial input with
the produced Array. Restore first-view producer permission only without an earlier
result owner, then retain actual-kind rejection for every later consumer. Current
result-guard repairs and produced source owners must remain intact.

Historical3.sorted_keys emits[sort keys %3], reaching the known
[[perl-wrong-kind-collection-host-slot-drift]] boundary. Actual localized empty/
outer/main::3 probes distinguish the read; current free/computed numeric sources
still read main::3 before repair. Exclude Number ASTs from the named-Hash shortcut
and require a reference before computed dereference. All measured numeric rows
now yield[] with host values unchanged. Keep actual reference/Array-source errors
and valid named Hashes[a,b] in every state. This is a bounded source prerequisite;
broad bare/absent host-slot isolation remains SESSION17-owned. Full native/cache/
context custody, registration and admission remain separate. Independent Dart76.3
must establish its own profiles; current frontier is MEMORY.md.
