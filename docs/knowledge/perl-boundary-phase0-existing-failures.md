---
id: perl-boundary-phase0-existing-failures
title: TYPE37 historical failure comparison and current-only Phase0 recovery
answers:
  - "is Phase0 green after the emitted Perl boundary catalog repair"
  - "did the Perl boundary catalog change introduce the current Phase0 failures"
  - "who owns the 28 Phase0 failures retained with TYPE37"
date: 2026-10-30
status: current selected failures owned by TYPE-REFERENCE-BOOK.1.2.23.3.45
tags: [perl, phase0, regression, ownership]
evidence: "TYPE37 perl-emitted-boundary-catalog-intake.json.gz retains full primary run, exact selected28 names, actual baseline/candidate TAP/stderr, canonical snapshots, producer and comparison receipt."
reverify: "Recover replay_phase0_current_selected.py and probe_phase0_current_selected.pl from perl-phase0-current-intake.json.gz and run bash tools/run_python_project_data.sh .linkedspec-data/verification/replay_phase0_current_selected.py. Historical replay_boundary_phase0_selected.py installs old production snapshots: never run it or --restore against current source."
---

The historical TYPE37 additional standard Phase0 run fails28/1035 groups. The exact28 failing groups
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
The focused boundary/generated/quoted consumers pass at that boundary; its full Phase0 is not green.

TYPE45.0 current-only recovery at clean d30a2f9cd37bd211b1e7c1c9faecc15c9579da8d
verifies the frozen names and decompressed primary diagnostics against the unchanged
TYPE37 packet. All28 groups still fail, with all nested assertions retained and the
shared discovery assertion passing; exit28 and the complete29-result TAP plan are
retained in perl-phase0-current-intake.json.gz. Hashes of528 named current inputs are
unchanged around execution. This is selected evidence, not a new full-suite run.
The historical comparison producer deliberately swaps old Compiler/Contracts and
MEMORY snapshots, so it is not a safe current-source replay or recovery command.
The replacement selector never installs those snapshots. Its initial lexical-local
setup error stops before tests; corrected producer evidence receives the result credit.
First bounded child45.1 owns the observed missing synthetic callback in the lazy-load
group; the remaining27 named groups stay with45 for contract-led children.

TYPE45.1 subsequently repairs only the lazy-owner synthetic callback fixture: its
unchanged40 assertions pass, alongside the native/fresh pipeline consumer6.
The other27 retained groups remain owned and are not rerun in that slice;45.2
next reconciles the helper-substitution endpoint assertions. No new full-suite
state or blanket stale-expectation conclusion follows.
