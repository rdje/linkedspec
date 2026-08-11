---
id: recognition-transaction-current-boundary-policy-drift
title: Recognition transaction current-boundary prose is derived from the expected rollout
answers:
  - "why did the neutral transaction policy say Rust was unavailable after Rust admission"
  - "what did Rust transaction admission omit from the neutral contract"
  - "how is recognition transaction current_boundary kept aligned with rollout"
  - "does the transaction checker derive current backend prose from rollout"
  - "which task repaired the stale Perl-only transaction policy"
date: 2026-08-11
status: current and repaired by FUTURE-PARITY-BACKLOG.14.3.4.0.0
tags: [transactions, recognition, rollout, policy, governance, drift]
evidence: "Dart RED retrieval found contract status/authored availability/rollout at neutral+Perl+Rust 3/9 while policy.current_boundary and the canonical checker still required current Perl only and called Rust unavailable. Blame traced both literals to neutral commit e0cc7182; Rust admission 02c612f5 updated the other rollout projections but omitted this field. FUTURE-PARITY-BACKLOG.14.3.4.0.0 corrects the JSON and makes the checker generate its exact boundary from EXPECTED_ROLLOUT, preserving 132/246/42 and all separate public/guide/admission counts; definitive CI passes Phase 0 1031/1031 in 721 seconds."
reverify: "jq -r '.status, .authored_surface.availability, .policy.current_boundary, (.rollout[] | [.leg,.status] | @tsv)' capability_conformance/recognition_transaction_contract.json && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py"
---

Rust admission advanced the neutral contract's top-level status, authored availability, rollout row/path, and
mutation count, but it did not update `policy.current_boundary`. The checker carried the same stale literal, so the
canonical gate passed by enforcing a contradiction: Rust was simultaneously complete and unavailable.

The repaired checker constructs the exact current-boundary sentence from `EXPECTED_ROLLOUT`. Backend display names
remain explicit, but complete and RED membership is no longer duplicated in an independent prose constant. A later
admission that changes the expected rollout therefore changes the required boundary automatically; an omitted JSON
update fails the existing `current_boundary` invariant and mutation without adding a new mutation domain.

The repair changes no transaction syntax, effect row, fixture, diagnostic, runtime, schema, public claim, or rollout
status. Current governance remains 132 ActionIR rows, 246 call rows, 42 semantic mutations, rollout 3/9, public
3/11/25, capability guide 1/4/8, and Rust registration/dormancy 8.

Related: [[recognition-transaction-neutral-contract]], [[cursor-transaction-authored-contract]],
[[recognition-transaction-book-sequence-drift]], and [[rust-recognition-transaction-dormant-red]].
