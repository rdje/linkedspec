---
id: governed-capture-helpers-missing-shared-inventory
title: Two governed current Perl capture helpers are absent from the provisional shared Dart/Julia call inventory
answers:
  - "is the 237 current ActionIR call count final"
  - "which current capture helpers are missing from the Dart Julia call inventories"
  - "does strict capability coverage compare backend inventories to Perl contracts"
  - "why must final capability admission reconcile the call-name inventory"
date: 2026-07-10
status: gap
tags: [capability, inventory, capture, dart, julia, perl, FUTURE-PARITY-BACKLOG]
evidence: "During FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.2, rg confirms start_capture_slice_from and mark_capture_slice are current contracts in perl/LinkedSpec/ActionIR/Contracts.pm and are used by governed capture fixtures, but neither appears in Dart or Julia supported call-name sets. tools/check_language_capability_coverage.pl compares Dart and Julia only, so their identical omission leaves the reported 237 count green. Final owner: FUTURE-PARITY-BACKLOG.1.6.1.2.2.5."
reverify: "rg -n 'start_capture_slice_from|mark_capture_slice' perl/LinkedSpec/ActionIR/Contracts.pm dart/lib/src/action/action_contracts.dart julia/src/action/ActionContracts.jl capability_conformance/fixtures && perl tools/check_language_capability_coverage.pl --report"
---

# Governed Capture Helpers Missing From Shared Inventory

The shared current-call count of 237 is provisional. `start_capture_slice_from` and `mark_capture_slice` are
current Perl ActionIR contracts and are required by the governed capture sources, but both are absent from the
aligned Dart and Julia call-name inventories. The coverage checker currently proves only that those two backend
inventories match each other; an identical omission is invisible.

Runtime repair remains correctly split one backend per leaf. Final admission
`FUTURE-PARITY-BACKLOG.1.6.1.2.2.5` owns the atomic inventory reconciliation after Julia runtime execution lands,
before strict executable coverage or a final call count is claimed.
