---
id: perl-callable-replay-instrument-recovery
title: Historical Perl callable observers are preserved independently of current regression growth
answers:
  - "can a fresh checkout recover the old callable scope and bridge probe instruments"
  - "does preserving old callable probes rerun their historical runtime claims"
  - "which callable observers had only ignored path and hash records"
  - "why must old callable replay use33 cases rather than the current71"
date: 2026-10-02
status: source recovery verified; policy adoption remains separately owned
tags: [perl, callable, evidence, recovery, durability, history]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.0 at clean f9c683543: three original checkpoints remain byte-exact. New recovery checkpoint archives15 inputs, including seven historical observer/writer programs and three recovery instruments; nine prior-recorded instrument/Git inputs match. Six bad-input controls reject before recovered file writes. No historical runtime re-execution is claimed."
reverify: "Use the archived recover.py bootstrap in the structured-format-program book chapter, then inspect the original checkpoint boundaries and archived review.py; historical writers must not run in the current checkout."
---

The diagnosis .0.2.0.0, scope repair .0.2.0.1 and bridge design .0.2.1.0 recorded
standalone observers as ignored paths/hashes. Their source bodies now live in
`docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.0-recovery.json`.
Required diagnosis source data and two book examples are included. The old33-case
regression and pre-scope-repair MethodLowering are recovered from exact Git blobs;
they are not replaced with the current71-case test. Source hashes already recorded
by the original checkpoints match; newly archived literal inputs are independently
matched to each original observation's exact source and oracle.

The archive's dependency table distinguishes external literal reads, Git inputs,
children and derived artifacts. Original Get/emit probes generate the source,
dump and emitted inputs their children consume. The historical review.py writes
its original tracked contract: preserve it for inspection or an isolated captured
workspace, never execute it in the current checkout. The archive includes its own
capture, recovery and review instruments.

Recovery restores into an owned mirror and validates every identity, lexical path,
resolved destination and filesystem device before recovered file writes. Actual
controls reject wrong hashes, escaping paths, undeclared roots, duplicates, invalid
Git capture IDs and an existing escaping symlink; each reports zero file writes.
The review derives original instrument membership from the prior checkpoints and
literal data dependencies from the actual consumers' reads.

This establishes source recovery, not a new runtime/RED/Phase0/canonical result.
Historical claims keep their original revisions, inputs, results and limitations.
Tracked regression tests already retain their own value and actual identity oracles;
missing standalone source bodies did not make every test claim unreproducible.
Source recovery does not assemble a complete historical execution workspace or
package dependencies. Replay requires the named captured implementation boundary
and published dependency integration instructions. Current runtime proof remains
owned by the bridge regression and its committed canonical receipt.

Claim-policy adoption is next .4.1. The wider constants/producers/controls audit
remains SESSION-STARTUP-READING.5 and its diagnostic path repair .29. This bounded
archive does not certify every earlier callable or repository-wide measurement.
