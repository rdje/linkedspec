---
id: perl-progressive-span-dispatch-admission
title: Perl progressive span dispatch is privately admitted without claiming shared helper parity
answers:
  - "is Perl progressive span dispatch admitted"
  - "where does canonical CI run the Perl progressive span dispatch consumer"
  - "what is the current progressive span dispatch rollout"
  - "why is dispatch_span still excluded from the public call inventory after Perl admission"
  - "which recognition effect owns PROGRESSIVE_DISPATCH_SPAN"
  - "how many current ActionIR node rows exist after Perl progressive admission"
  - "what progressive span dispatch work remains after Perl admission"
date: 2026-08-17
status: current private Perl admission; Rust also admitted; later backends, recurrence, and outward projection pending
tags: [perl, progressive, dispatch, admission, ci, actionir, coverage, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.6.2.3 requires and syntax-checks t/progressive_span_dispatch_perl_contract.t, logs running exact Perl progressive span-dispatch admission consumer, and executes PERL5LIB= prove -Iperl t/progressive_span_dispatch_perl_contract.t exactly once in tools/run_ci_local.sh. The unchanged consumer passes 125 assertions. progressive_span_dispatch_contract.json is neutral + Perl 2/9 complete with 4 pending-backend groups/14 paths, ten outward guards, 26 diagnostics, and 86 mutations. recognition_transaction_contract.json is 134 current + 4 dedicated nodes, 250 calls, and 58 mutations; PROGRESSIVE_DISPATCH_SPAN is the sole parser_registry_or_staged_dispatch ActionIR row and no call row exists. All admitted Rust/Dart/Julia/Lua recognition consumers snapshot the recomposed counts in lockstep. tools/check_language_capability_coverage.pl retains dispatch_span as the fifteenth non-public classification because a Perl-only dedicated intrinsic does not prove shared Dart/Julia/Lua helper support. Rust, Dart, Julia, Lua progressive behavior, recurring, typed progressive, public no-drift, generated format, and outward surfaces remain pending or unchanged."
evidence_update_2026_08_17_rust_admission: "FUTURE-PARITY-BACKLOG.14.6.3.3 updates only Perl's neutral governance snapshots: its execution behavior remains exact at 126 assertions while Rust becomes the second privately admitted backend. Progressive rollout is 3/9 with 95 mutations; Dart/Julia/Lua, recurring, typed progressive, public no-drift, generated format, and outward surfaces remain pending or unchanged."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py"
  - "PERL5LIB= prove -q -Iperl t/progressive_span_dispatch_perl_contract.t"
  - "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py"
  - "perl tools/check_language_capability_coverage.pl"
  - "test \"$(rg -c 'PERL5LIB= prove -Iperl t/progressive_span_dispatch_perl_contract[.]t' tools/run_ci_local.sh)\" -eq 1"
---

# Perl progressive span-dispatch admission

Private Perl progressive span dispatch is canonically admitted. The admission
does not change its syntax, runtime, generated carriers, or host authority; it
routes the already-green final-path consumer and advances only the Perl rollout
row. The neutral contract rejects regression of that row and promotion of any
later row.

The recognition effect inventory now includes `PROGRESSIVE_DISPATCH_SPAN` as
the only current `parser_registry_or_staged_dispatch` node. It remains rejected
inside uncommitted recognition and has no canonical call row. This raises the
current ActionIR census to 134 plus four dedicated transaction nodes.

`dispatch_span` remains outside the shared public-call inventory. Perl owns it
as a dedicated intrinsic, whereas the 250-name inventory asserts equal current
Dart, Julia, and Lua call support. Removing the exclusion at Perl admission
would therefore create a false cross-backend claim. Exact recurrence after the
remaining backend admissions is the first safe owner for reclassification.

## Links

- Neutral model: [[progressive-span-dispatch-audit-plan]].
- Private authority: [[perl-progressive-span-dispatch-authority]].
- Four carriers: [[perl-progressive-span-dispatch-carriers]].
- Inventory boundary: [[public-call-inventory-independent-coverage]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.6.2.3`.
