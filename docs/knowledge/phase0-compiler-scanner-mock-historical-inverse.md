---
id: phase0-compiler-scanner-mock-historical-inverse
title: "Historical Phase0 audits admit exact reviewed source inverses"
answers:
  - "why did canonical membership acceptance reject unreviewed signature-regression drift"
  - "which historical audit owner admits the Phase0 compiler scanner mock change"
  - "how is the compiler scanner mock delta reconciled without refreshing historical hashes"
  - "does historical Phase0 normalization allow unrelated source edits"
date: 2026-10-19
status: current
tags: [historical-audit, phase0, source-evolution, compiler, claims]
evidence: "The first staged .0.2.2 canonical stream rejects the already committed .0.2.1 scanner mock delta. The original auditor reproduces that rejection. The repaired auditor verifies entire before/after Phase0 Git blobs differ only by the one mock entry and recovers the original historical bytes after all admitted inverses. Five source controls reject; isolated replay restores134 inputs/84,613,241 bytes,22 recovery controls and60 evolution denials with zero healthy original-log reads/tracked writes."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/type-evaluated-values/publish.py"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py"
---

Compiler integration at `af5d19971a1682f6895901fb769ff41b69842672` changes
exactly one Phase0 mock from `scan_contract_ir_events` to the private compiler
entry `_scan_executable_contract_ir_events`. Its parent is
`31395e440a38acec7a6712d470a90a90a6567863`. The historical signature ledger
had no inverse for this admitted seam correction, so canonical acceptance
stopped at `verify_signature_regression_evolution` before reaching runtime CI.

`restore_compiler_scanner_mock` first proves exact whole-file Git identity after
reversing this one line. It requires one current registration, reverses it, then
the existing inverses must recover the complete original historical file and
hash. Missing, duplicated, disabled and foreign registrations reject; an
unrelated extra edit still rejects at the whole-file comparison. No historical
hash, milestone, log, claim or Perl test is refreshed.

The acceptance leaf owns this blocking evidence-auditor prerequisite; recurring
registration `.0.4` retains its later ledger work. Complete original failed CI
channels and its staged binary candidate diff, original auditor bytes and the
corrected isolated proof are retained in the leaf-prefixed checkpoint artifacts
and bound by its claim. See [[historical-objective-audit-input-recovery]] for the
unchanged archive population and recovery contract. This replay validates the
historical evidence; it does not rerun the original runtime producers.

The evaluated-value admission adds an exact inverse of 70 reviewed
Phase0 fragments relative to real c053 source. All 368 original controls
remain effective; 210 fragment denials and a valid-JSON whitespace
identity fault reject. The full historical hash, archive recovery and zero
original-log/tracked-write boundary remain unchanged. The first added-control
KeyError and two-reference correction stay separate in
docs/checkpoints/type-values-signature/. Both reverify routes are readonly.
