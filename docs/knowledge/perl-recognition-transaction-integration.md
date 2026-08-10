---
id: perl-recognition-transaction-integration
title: Perl recognition transactions are internally integrated but remain unadmitted
answers:
  - "where are Perl recognition transactions integrated"
  - "which Perl modules implement recognition transaction lowering and runtime behavior"
  - "does Perl have the four dedicated recognition transaction ActionIR nodes"
  - "how does Perl validate recognition transaction effects"
  - "how does Perl preserve falsey recognized payloads"
  - "how does Perl isolate recursive same-label marks during recognition"
  - "how does Perl diagnose zero-progress recognition recursion and repetition"
  - "does independently generated Perl source execute recognition transactions"
  - "is the Perl recognition transaction final-path consumer green"
  - "are Perl recognition transactions admitted or public"
  - "why is the Perl final-path transaction test absent from canonical CI"
  - "why are Perl recognition transaction intrinsics absent from the 246-name helper inventory"
date: 2026-08-10
status: current internal Perl integration; final-path GREEN but admission and public claims remain pending
tags: [perl, recognition, transaction, ActionIR, effects, marks, progress, generated-source, unadmitted, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.2.2 adds dedicated ActionIR scanning/lowering, post-descriptor recursive effect validation, live/generated invocation guards, private-authority state synchronization, falsey-safe acceptance, cursor-only repetition/recursion progress errors, and optional generated recognition regex carriers. t/recognition_transaction_perl_contract.t is GREEN at 51 outer assertions with its nested integration body covering exact event arguments, construction-time linearity/static/effect failures, all eight token results, compatibility controls, direct/mutual progress failures, and independently loaded emitted execution. Canonical CI tracks and syntax-checks the three production integration modules but deliberately neither tracks nor executes that final-path consumer; FUTURE-PARITY-BACKLOG.14.3.2.3 exclusively owns admission. The neutral artifact remains 1/9 and public sequence remains guarded at three documents/eight forbidden claims/thirteen mutations."
evidence_update_2026_08_10_signoff: "After exact classification of the four grammar-owned intrinsics outside the 246-name ordinary helper inventory, definitive canonical CI passes all eight doctrines, repository containment/relocation, both primary CLI environments at 66/66, RAM 58%, and Phase 0 at 1,031/1,031 in 727 wall-clock seconds before the exact pass marker. The dormant final-path consumer remains absent from canonical discovery."
reverify: "perl -Iperl -c perl/LinkedSpec/RecognitionTransactionPolicy.pm && perl -Iperl -c perl/LinkedSpec/RecognitionTransactionRuntime.pm && perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/RecognitionTransactionRules.pm && prove -Iperl t/recognition_transaction_perl_authority.t t/recognition_transaction_perl_contract.t t/generated_source_contract.t && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && ! rg -q 'recognition_transaction_perl_contract[.]t' tools/run_ci_local.sh"
---

# Internally integrated Perl recognition transactions

Perl now recognizes the four exact authored forms as dedicated canonical
ActionIR. The scanner preserves direct token/result slots and the unevaluated
static `call(Rule)` operand; generic call and assignment scanners do not
duplicate or eagerly evaluate those nodes. After ordinary descriptor
construction and validation have retained diagnostic precedence, a closed
132-node effect table computes named-rule dependencies to a recursive fixed
point and rejects dynamic, forbidden, or unknown recognition callees before
execution.

Every live or emitted handler enters one source-local invocation frame. During
`recognize_once`, the runtime executes the static child once, carries acceptance
separately from its payload, synchronizes the real cursor, anonymous boundary,
and current-invocation marks with the private authority, and restores recursive
same-label mark buckets on exit. Commit invalidates before retaining candidate
state and exposing false, zero, empty, undef, or ordinary payloads. Rollback and
missing-terminal unwind restore before invalidation.

Only accepted repetition iterations and recursive re-entry while recognition is
active acquire the stricter cursor-progress rule. Zero or backward movement
throws the portable typed repetition or recursive-cycle error; one-shot
zero-width recognition remains legal. Independently emitted v2 source loads the
same runtime and carries local regexes only when a transaction needs them.

This is an internal implementation boundary, not admission. The final-path
consumer is intentionally absent from ordinary/canonical discovery until
`.14.3.2.3` promotes the Perl rollout leg and updates public-current governance.
The four grammar-owned transaction intrinsics remain outside the aligned
246-name ordinary helper-call inventories: their contracts lower directly to
dedicated `RECOGNITION_*` nodes. The independent language-coverage checker
classifies those four exact names, requires them to exist in Perl, and rejects
their accidental admission as shared backend helpers while continuing to prove
all 122 ordinary public Perl calls.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Authored/static contract: [[cursor-transaction-authored-contract]].
- Historical dormant RED: [[perl-recognition-transaction-dormant-red]].
- Private state foundation: [[perl-recognition-transaction-private-authority]].
- Generated carrier: [[perl-generated-source-contract-v2]].
- Owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.2.2`.
