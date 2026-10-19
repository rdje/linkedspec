---
id: rust-dependency-warning-baseline
title: Dependency warning output is upstream-owned black-box evidence
answers:
  - why does canonical Rust compilation print thousands of warnings
  - how many warnings does pgen currently emit
  - which task owns Rust dependency warning reports
  - may LinkedSpec patch RGX or PGEN warning causes
  - what git boundary owns rgx and pgen warning fixes
  - what does the current canonical output report for PGEN warnings
  - does 7093 mean distinct PGEN defects
date: 2026-10-19
status: dated public summaries retained; fuller census/upstream work remains open
tags: [rust, dependencies, warnings, public-contract, task-tree]
evidence: "Canonical e953f69a9 retains 24 summary occurrences; exact raw-line/phase/count and Git-receipt review pass. Reported counts and dated1870/26 stay scoped in the preserved body."
reverify: "Readonly: bash tools/run_python_project_data.sh docs/checkpoints/knowledge-fields/publish.py. Prior:f7e8b292f."
---

# Public warning-output account

LinkedSpec integrates only with RGX through its published integration document, APIs and contracts. RGX owns PGEN/transitive preparation. Do not inspect or edit either implementation, reconstruct a separate PGEN procedure, change pins, execute source-changing cargo suggestions or suppress warnings to claim a clean build.

The warranted canonical run admitted at e953f69a9 contains 24 summary-line occurrences: 12 report 7093 for pgen; 12 report 26 for rgx-core. The complete successful log, original staged and promoted receipts, separate partial/final observations and observed CLI tool identities are retained under docs/checkpoints/REPO-HYGIENE.19/. Independent review derives every raw line, nearest public phase, crate/count and actual accepted parent/diff/tree. Defaults read captured evidence; no new build is run.

These are compiler-reported summaries, not counts of distinct diagnostics/bugs, proven comparable configurations or an internal cause. The earlier dated account reported 1870/26; its whole original header/body remains at e953f69a9 and warning-historical-card.md. Preserve that history rather than relabeling it as a new run.

RUST-DEPENDENCY-WARNING-ZERO.1 owns the fuller public census; .2 owns an upstream RGX report and evaluation of published results. This partial output account closes neither. Keep the program non-blocking behind active residual repair. Observe future counts only through otherwise warranted documented builds; retain command, identity, exit and full channels.

The September20 boundary already governed the canonical task/card. RUST-DEPENDENCY-WARNING-ZERO.8 corrected contrary current roadmap internal-repair/pin plans on October10; no old output was refreshed. LinkedSpec-owned diagnostics may be repaired only in their own task-owned slices. Related: [[rust-ci-pgen-missing-input-rebuilds]], [[verification-cadence-policy]].
