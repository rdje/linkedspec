# ADR 0074: Dart gap admission adds a regression mutation instead of replacing a nonexistent one

- Date: 2026-08-15
- Status: accepted; implementation owned by `INTER-MATCH-GAP-CAPTURE.4.5`
- Tags: architecture, capture, dart, admission, mutations, verification, continuity

## Context

The behavior-free Dart freeze said final admission would replace
`dart_runtime_premature` with `dart_runtime_regression` while retaining 56
semantic mutations. Exact contract and Git-history evidence disproves that
premise. Perl admission created mutation 56 as `rust_runtime_premature`; Rust
admission replaced that same row with `rust_runtime_regression` and did not add
a Dart-premature successor. Consequently, the pre-Dart contract contains 56
valuable mutations but no Dart rollout mutation that can be renamed.

Silently relabeling an unrelated mutation would weaken a different semantic
guard. Omitting a Dart regression would make the newly complete rollout less
protected than Perl and Rust. Preserving the stale planned count is therefore
incompatible with the ratified mutation purpose.

## Decision

`INTER-MATCH-GAP-CAPTURE.4.5` preserves all 56 existing semantic mutations and
adds `dart_runtime_regression` as mutation 57. The mutation changes only the
admitted Dart rollout row from complete back to pending and must fail with the
exact `dart_runtime rollout drifted` reason.

The separate ten Dart dormancy mutations become ten admission/regression
mutations covering consumer identity, the role ledger, ordinary discovery,
primary execution, canonical and recurring registration/duplication, the next
pending-runtime skip, and public-facade absence. This does not create a public
surface or alter generated plan v2.

## Consequences

- Gap governance advances from `3/6/56` to `4/5/57`, not `4/5/56`.
- Every preexisting semantic mutation remains independently executed.
- Perl, Rust, and Dart each have an exact complete-to-pending rollout guard.
- The frozen `.4.0` count statement is retained in Git history but superseded
  by this evidence-backed correction.

## Links

- Owning tree: `docs/tasks/INTER-MATCH-GAP-CAPTURE.md`
- Original decision: ADR `0045`
- Contract: `capability_conformance/inter_match_gap_capture_contract.json`
- Checker: `tools/check_inter_match_gap_capture_contract.py`
