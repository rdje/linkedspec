---
id: perl-boundary-phase0-existing-failures
title: TYPE37 leaves the exact selected existing Phase0 failures unchanged
answers:
  - "is Phase0 green after the emitted Perl boundary catalog repair"
  - "did the Perl boundary catalog change introduce the current Phase0 failures"
  - "who owns the 28 Phase0 failures retained with TYPE37"
date: 2026-10-29
status: P1 TYPE-REFERENCE-BOOK.1.2.23.3.45 after40/41 before wider features/admission/push
tags: [perl, phase0, regression, ownership]
evidence: "TYPE37 perl-emitted-boundary-catalog-intake.json.gz retains full primary run, exact selected28 names, actual baseline/candidate TAP/stderr, canonical snapshots, producer and comparison receipt."
reverify: "Recover replay_boundary_phase0_selected.py and probe_boundary_phase0_selected.pl from the retained TYPE37 packet; use the repository Python wrapper and preserve canonical candidate restoration."
---

The additional standard Phase0 run fails28/1035 groups. The exact28 failing groups
are replayed from the unchanged canonical test using Test::More subtest selection:
all nested assertions run for a selected group; other groups are skipped without
credit. Canonical Compiler.pm/ActionIR/Contracts.pm committed-baseline versus
candidate bytes produce byte-identical selected TAP/stderr and exit28. Candidate
files and the resume pointer are restored exactly. No full baseline rerun is
claimed. Initial lexical-local selector setup failed before tests and receives no
product failure credit; its bytes and diagnostics remain retained.

This separates these failures from the TYPE37 patch. It does not classify them
all as stale: source-shape expectations and wrong runtime results both occur.
P1 TYPE-REFERENCE-BOOK.1.2.23.3.45 owns every exact retained name after40/41,
before wider feature expansion/full23.4/push, with contract-led bounded repair
children and public source/context/debug proof. Historical evidence is immutable;
neither global expectation refresh nor silent null acceptance is authorized.
The focused boundary/generated/quoted consumers pass; Phase0 is not green.
