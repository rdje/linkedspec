---
id: phase0-compiler-scanner-mock-historical-inverse
title: "Historical Phase0 audits admit exact reviewed source inverses"
answers:
  - "why did canonical membership acceptance reject unreviewed signature-regression drift"
  - "which historical audit owner admits the Phase0 compiler scanner mock change"
  - "how is the compiler scanner mock delta reconciled without refreshing historical hashes"
  - "does historical Phase0 normalization allow unrelated source edits"
  - "how are numeric Phase0 value regressions reconciled with historical evidence"
date: 2026-10-20
status: current
tags: [historical-audit, phase0, source-evolution, compiler, claims]
evidence: "Dated scanner admission .0.2.2 rejects committed .0.2.1; original auditor reproduces. Exact Git mock inverse,5 source controls, isolated134 inputs/84613241 bytes/22 recovery controls/60 evolution denials and zero healthy original-log/tracked writes. Numeric5 preserves578 controls and adds66; two actual auditor faults restore."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/type-numeric-codeblocks/publish_recurrence.py"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1-proof.py"
---

`af5d19971a1682f6895901fb769ff41b69842672` changes one Phase0 mock from
`scan_contract_ir_events` to `_scan_executable_contract_ir_events`; its parent is
`31395e440a38acec7a6712d470a90a90a6567863`. The missing inverse stopped canonical
acceptance before runtime CI.

The compiler inverse proves the entire Git blobs differ by that entry, requires
one registration, reverses it, then older inverses must recover the original
file/hash. Missing, duplicated, disabled, foreign and unrelated edits reject.
Historical hashes, milestones, logs, claims and Perl tests are never refreshed.
The acceptance owner retains failed CI/candidate, original auditor and corrected
proof; `.0.4` owns later ledger work. [[historical-objective-audit-input-recovery]]
defines the unchanged archive/guard contract. This checks evidence, not old runtime.

Evaluated-value owner3 inverses70 reviewed fragments from real c053 source.
All368 prior controls,210 added fragment denials and a valid-JSON whitespace
identity fault remain effective. Its first KeyError/two-reference correction
stays in docs/checkpoints/type-values-signature/.

Numeric owner5 inverses21 value assertions plus their shared frame before old70,
whose hunk3 overlaps. Reconstruction uses real accepted203cde315 before bytes;
all22 current fragments must occur once. Preserve578 older controls on their
pre-numeric stage; add66 current numeric denials. Missing-inverse/blind-restore
producer faults reject and restore, as does semantically identical JSON with
changed whitespace. The isolated producer explicitly closes the new table.
Archive134/84613241 bytes,22 recovery controls and zero healthy original-log or
tracked-write attempts remain exact. The separate numeric KeyError and correction
retain full source/channels. Both reverify routes are readonly.
