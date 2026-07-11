---
id: governed-capture-helpers-missing-shared-inventory
title: Final admission resolved two governed capture-helper omissions in the provisional shared inventory
answers:
  - "is the 237 current ActionIR call count final"
  - "which current capture helpers are missing from the Dart Julia call inventories"
  - "does strict capability coverage compare backend inventories to Perl contracts"
  - "why must final capability admission reconcile the call-name inventory"
date: 2026-07-10
status: resolved
tags: [capability, inventory, capture, dart, julia, perl, FUTURE-PARITY-BACKLOG]
evidence: "During FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.2, start_capture_slice_from and mark_capture_slice were found in the current Perl contract registry and governed sources but absent from both provisional 237-name backend inventories. FUTURE-PARITY-BACKLOG.1.6.1.2.2.5 adds both names to Dart and Julia, producing the corrected 239-name inventory, and strengthens tools/check_language_capability_coverage.pl with a reverse check from neutral Perl-contract calls to both backend inventories. The final checker reports 239 names in 105 fixtures with zero omissions."
reverify: "rg -n 'start_capture_slice_from|mark_capture_slice' perl/LinkedSpec/ActionIR/Contracts.pm dart/lib/src/action/action_contracts.dart julia/src/action/ActionContracts.jl capability_conformance/fixtures && perl tools/check_language_capability_coverage.pl --report"
---

# Governed Capture Helpers Missing From Shared Inventory

The provisional shared count of 237 omitted `start_capture_slice_from` and `mark_capture_slice`. Both are current
Perl ActionIR contracts used by governed capture sources. Final admission added them to Dart and Julia, so the
reconciled current inventory contains 239 names.

The checker now proves more than backend agreement. It also extracts call-shaped names from the neutral corpus,
intersects them with the current Perl contract registry, and rejects any resulting reference call missing from a
backend inventory. This closes the identical-omission blind spot that exposed the provisional count.
