---
id: rust-recognition-transaction-dormant-red
title: Rust recognition transactions used two custom cfgs before ordinary admission
answers:
  - "where is the dormant Rust recognition transaction RED consumer"
  - "where is the private Rust recognition transaction authority"
  - "what is the next Rust recognition transaction RED failure"
  - "how do I run the Rust recognition transaction RED"
  - "why does ordinary Cargo run zero Rust recognition transaction tests"
  - "why did the Rust transaction RED expose test defects only after the private module existed"
  - "which cfg enables the Rust recognition transaction private authority contract"
  - "which cfg enables the Rust recognition transaction integration contract"
  - "which Rust transaction API does the dormant consumer freeze"
  - "does Rust have dedicated recognition transaction ActionIR nodes"
  - "does the Rust transaction RED cover independently compiled emitted source"
  - "does the Rust recognition transaction RED change rollout or production behavior"
date: 2026-09-07
status: historical dormant boundary resolved by FUTURE-PARITY-BACKLOG.14.3.3.3
tags: [rust, recognition, transaction, ActionIR, RED, generated-source, history, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.3.0 adds rust/linkedspec-runtime/tests/recognition_transaction_contract.rs behind outer cfg linkedspec_recognition_transaction_red and nested integration cfg linkedspec_recognition_transaction_integration_red. FUTURE-PARITY-BACKLOG.14.3.3.1 adds rust/linkedspec-runtime/src/recognition_transaction.rs and its documentation-hidden lib.rs route under the same outer custom cfg only. The authority owns source-local monotonic invocation/frame/mark/token generations, detached snapshots, strict matched/payload separation, exactly-once attempt state, restore-before-invalidate misuse handling, and terminal drop/unwind cleanup. Supplying the module exposed defects that the prior E0432 had masked in the dormant consumer: constructor shadowing, six abbreviated nonexistent neutral JSON keys, and an incomplete nonexistent syntax path. FUTURE-PARITY-BACKLOG.14.3.3.2 adds four dedicated parser/ActionIR nodes, neutral effect/progress classifiers, live cursor/boundary/mark/acceptance binding, generated-plan execution, and structurally selected emitted-source execution. Ordinary offline Cargo discovers zero tests; explicit outer-cfg execution passes 7/7 and the nested integration passes 12/12. Neither cfg has an ordinary manifest/canonical-driver route, so rollout remains 2/9 and current public behavior remains Perl-only."
evidence_update_2026_08_10_admission: "FUTURE-PARITY-BACKLOG.14.3.3.3 removes both historical cfgs from all nine governed Rust sources. Ordinary Cargo now executes the unchanged complete consumer at 12/12, canonical CI executes the exact same target once, and eight checker mutations reject stale cfg or registration drift. Rust advances to complete while Dart remains the next RED."
reverify: "bash tools/run_cargo_local.sh test --locked --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test recognition_transaction_contract && ! rg -n 'linkedspec_recognition_transaction' rust/linkedspec-core rust/linkedspec-runtime"
---

# Historical cfg-private Rust recognition-transaction boundary

Before admission, the final-path consumer was
`rust/linkedspec-runtime/tests/recognition_transaction_contract.rs`. Its
file-level custom cfg deliberately left ordinary Cargo and canonical CI with
zero active tests. At that historical stage, enabling only `linkedspec_recognition_transaction_red`
exercised the private state contract. The documentation-hidden
`linkedspec_runtime::recognition_transaction` module satisfied that outer
contract at 7/7 while remaining absent from ordinary builds.

The private module implements one source-local authority with opaque monotonic
invocation, frame, mark, and token generations; detached snapshots; recursive
same-label mark isolation; falsey-safe match/payload separation; exact
commit/rollback restoration; and portable lifecycle, escape, source, and
invocation errors. Restore precedes invalidation on retry, nesting, escape,
cross-authority misuse, unwind, and token drop. Supplying the module also made
the consumer compile far enough to expose three masked test defects: a shadowed
constructor, six stale abbreviated JSON keys, and an incomplete stale authored-
surface assertion. Those test-only repairs preserve the frozen contract and add
explicit nesting/drop cleanup coverage.

The nested integration cfg became GREEN at 12/12. It supplied dedicated
non-eager nodes, neutral effect/progress classifiers, and native,
reconstructed, generated-plan, and freshly compiled emitted-source execution
over the private authority. This remains an internal implementation boundary,
not admission.

Admission `.14.3.3.3` removed both custom cfgs after that staged proof. At that admission,
authored Rust recognized the four forms, ordinary and canonical discovery ran
the same exact 12-test consumer, and rollout was neutral + Perl + Rust 3/9.
September 7 `.3.3.27` confirms current neutral rollout 9/9 and no dormant-source
claim is current; see [[rust-recognition-transaction-integration]]. This card
preserves the history of why the two dormant seams existed.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Authored/static policy: [[cursor-transaction-authored-contract]].
- Perl reference admission: [[perl-recognition-transaction-integration]].
- Rust internal integration: [[rust-recognition-transaction-integration]].
- Safety audit: [[cursor-transaction-safety-audit-plan]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.3.0-.3`; resolved by admission `.14.3.3.3`.
