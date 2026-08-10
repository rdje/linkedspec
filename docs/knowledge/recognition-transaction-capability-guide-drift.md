---
id: recognition-transaction-capability-guide-drift
title: Recognition transaction capability guidance has its own stale-claim guard
answers:
  - "why did the recognition transaction capability guide say both 1/9 and 2/9"
  - "which commit left stale recognition transaction capability guidance"
  - "how is stale recognition transaction rollout prose prevented"
  - "does the public sequence guard cover capability_conformance README"
  - "what does the recognition transaction capability guide guard check"
  - "how many capability guide mutations protect recognition transaction status"
date: 2026-08-10
status: current repaired and independently guarded capability guide
tags: [recognition, transaction, capability, documentation, drift, mutation, FUTURE-PARITY-BACKLOG]
evidence: "During FUTURE-PARITY-BACKLOG.14.3.3.0 review, capability_conformance/README.md contained adjacent contradictory paragraphs: current neutral + Perl 2/9 guidance followed by stale neutral-only 1/9 and all-backends-unavailable guidance. git blame assigns the current lines to Perl-admission commit a0595411 and the retained stale paragraph to neutral-contract commit e0cc7182. Atomic 187 appended the new state without deleting its predecessor. The repair keeps one current statement: Perl is current and every other runtime remains future. tools/check_recognition_transaction_contract.py now validates this canonical guide separately from the three-page mdBook public-sequence contract, requiring two unique markers, forbidding both stale claims, proving the file is tracked, and rejecting six path/marker/text mutations. Neutral semantic mutations remain 41 and mdBook public-sequence mutations remain 14."
reverify: "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && ! rg -n 'Rollout is neutral 1/9 complete|forms remain future and unavailable in every backend' capability_conformance/README.md && rg -n 'CAPABILITY_GUIDE_CONTRACT|CAPABILITY_GUIDE_MUTATION_COUNT' tools/check_recognition_transaction_contract.py"
---

# Capability-guide drift boundary

The recognition-transaction checker governs three sole-facing mdBook pages as
one public sequence, but `capability_conformance/README.md` is a distinct
canonical technical guide. Perl admission updated that guide by adding the
current 2/9 paragraph while leaving the old 1/9 paragraph directly below it.
Both sentences were individually plausible historical snapshots, so the
existing exact book-page inventory could not see the contradiction.

The checker now treats the capability guide as a separate surface. It requires
one neutral-plus-Perl marker and one Perl-current/other-runtimes-future marker,
forbids the stale neutral-only and every-backend-unavailable claims, and rejects
six mutations covering path, marker contract, deletion, duplication, and both
stale statements. This guard does not alter the neutral semantic corpus or the
book public-sequence mutation domain.

## Links

- Neutral and public checker authority: [[recognition-transaction-neutral-contract]].
- Perl admission: [[perl-recognition-transaction-integration]].
- Owning repair leaf: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.3.0`.
