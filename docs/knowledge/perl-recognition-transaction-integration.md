---
id: perl-recognition-transaction-integration
title: Perl recognition transactions are integrated and canonically admitted
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
  - "how is the Perl final-path transaction test registered in canonical CI"
  - "why are Perl recognition transaction intrinsics absent from the generic helper inventory"
date: 2026-08-10
status: current admitted Perl integration; exact final-path consumer is canonical
tags: [perl, recognition, transaction, ActionIR, effects, marks, progress, generated-source, admitted, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.2.2 adds dedicated ActionIR scanning/lowering, post-descriptor recursive effect validation, live/generated invocation guards, private-authority state synchronization, falsey-safe acceptance, cursor-only repetition/recursion progress errors, and optional generated recognition regex carriers. t/recognition_transaction_perl_contract.t is GREEN at 51 outer assertions with its nested integration body covering exact event arguments, construction-time linearity/static/effect failures, all eight token results, compatibility controls, direct/mutual progress failures, and independently loaded emitted execution. Canonical CI tracks and syntax-checks the three production integration modules but deliberately neither tracks nor executes that final-path consumer; FUTURE-PARITY-BACKLOG.14.3.2.3 exclusively owns admission. The neutral artifact remains 1/9 and public sequence remains guarded at three documents/eight forbidden claims/thirteen mutations."
evidence_update_2026_08_10_signoff: "After exact classification of the four grammar-owned intrinsics outside the 246-name ordinary helper inventory, definitive canonical CI passes all eight doctrines, repository containment/relocation, both primary CLI environments at 66/66, RAM 58%, and Phase 0 at 1,031/1,031 in 727 wall-clock seconds before the exact pass marker. The dormant final-path consumer remains absent from canonical discovery."
evidence_update_2026_08_10_admission: "FUTURE-PARITY-BACKLOG.14.3.2.3 requires, syntax-checks, and executes t/recognition_transaction_perl_contract.t exactly once in canonical CI. Only the Perl rollout row advances, giving 2/9 complete with 41 semantic mutations and public governance at 3 documents / 8 forbidden claims / 14 mutations. The consumer changes only two admission-metadata assertions and passes all 51 tests; production implementation bytes do not change."
evidence_update_2026_08_10_admission_signoff: "The definitive staged-tree canonical gate passes all eight doctrines, exact Perl admission, mandatory cross-runtime and storage/relocation consumers, both primary CLI environments at 66/66, RAM 34%, and Phase 0 at 1,031/1,031 in 733 wall-clock seconds before the exact local-gate pass marker. Perl parent FUTURE-PARITY-BACKLOG.14.3.2 is composition-complete and Rust dormant RED .14.3.3.0 is next."
evidence_update_2026_08_10_rust_admission: "FUTURE-PARITY-BACKLOG.14.3.3.3 independently admits the unchanged Rust integration at ordinary/canonical 12/12. Perl remains the exact 51-test reference admission; shared rollout is now neutral + Perl + Rust 3/9, with Dart, Julia, PUC Lua, LuaJIT, recurring composition, and public no-drift still RED."
evidence_update_2026_09_06_reading: "SESSION-STARTUP-READING.3.2.32 re-reads pipeline/recognition scanners, ScannerCore, staged marker lowering, and StatementSplit with exact baseline identity. The managed staged Perl consumer passes 143 checks; staged governance passes 9/9/123 plus public 6/17/10/129, recognition governance passes 138/250/58 with 9/9 rollout, and language coverage passes 250 names/126 public Perl contracts. This is bounded Perl/neutral proof; other runtime execution routes are not rerun."
last_verified: 2026-09-06
reverify: "perl -Iperl -c perl/LinkedSpec/RecognitionTransactionPolicy.pm && perl -Iperl -c perl/LinkedSpec/RecognitionTransactionRuntime.pm && perl -Iperl -c perl/LinkedSpec/ActionIR/Scanner/RecognitionTransactionRules.pm && prove -Iperl t/recognition_transaction_perl_authority.t t/recognition_transaction_perl_contract.t t/generated_source_contract.t && bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py && test \"$(rg -c 'require_tracked_file t/recognition_transaction_perl_contract[.]t|perl -c -Iperl t/recognition_transaction_perl_contract[.]t|PERL5LIB= prove -Iperl t/recognition_transaction_perl_contract[.]t' tools/run_ci_local.sh)\" = 3"
---

# Admitted Perl recognition transactions

Perl now recognizes the four exact authored forms as dedicated canonical
ActionIR. The scanner preserves direct token/result slots and the unevaluated
static `call(Rule)` operand; generic call and assignment scanners do not
duplicate or eagerly evaluate those nodes. After ordinary descriptor
construction and validation have retained diagnostic precedence, the closed effect table computes
named-rule dependencies to a recursive fixed point and rejects dynamic, forbidden, or unknown
recognition callees before execution. The initial 132-node census is historical: the current neutral
checker reports 138 ActionIR rows (134 current plus four dedicated transaction nodes).

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

Admission `.14.3.2.3` requires, syntax-checks, and executes the exact final-path
consumer once in canonical CI. The Perl rollout leg is complete and public-current
guidance identifies the forms as current on Perl. At this card's August-10 checkpoint, Rust was independently
admitted while the later runtimes, recurring composition, and public closeout were pending. The 2026-09-06
reading reconciliation routes current combined status to [[typed-authoring-model-public-no-drift]]; those
historical pending rows must not be read as today's support status.
The four grammar-owned transaction intrinsics remain outside the aligned
250-name ordinary helper-call inventories: their contracts lower directly to
dedicated `RECOGNITION_*` nodes. The independent language-coverage checker
classifies those four exact names, requires them to exist in Perl, and rejects
their accidental admission as shared backend helpers while continuing to prove
all 126 public Perl contracts.

The `.3.2.32` reading checkpoint confirms the exact statement scanner and current neutral census.
[[perl-recognition-token-lexical-order-drift]] qualifies static validation claims: quoted token text
and first-token regex caching still have owned repair under `SESSION-STARTUP-READING.21`.
Passing the finite contract mutation set does not close those separately reproduced defects.

## Links

- Neutral authority: [[recognition-transaction-neutral-contract]].
- Authored/static contract: [[cursor-transaction-authored-contract]].
- Historical dormant RED: [[perl-recognition-transaction-dormant-red]].
- Private state foundation: [[perl-recognition-transaction-private-authority]].
- Generated carrier: [[perl-generated-source-contract-v2]].
- Implementation owner: [[FUTURE-PARITY-BACKLOG.14]] `.14.3.2.2`; admission owner `.14.3.2.3`.

The September 6 `.3.2.40` checkpoint reads the full core and static Policy owner. Policy first checks
transaction shape and IF/ELIF/ELSE terminal paths, then propagates named calls and dependency references to
a fixed point over the closed effect vocabulary. Missing callees, fallback/unresolved helpers, and unknown
nodes contribute unknown effects. Rejected recognition callees fail before execution. The raw token scan
and interpolated /o expression remain the already-owned `.21` exception; no lexical fix is claimed.
The managed authority/carrier pair passes 59 tests and the neutral checker passes 138/250/58 at 9/9.
[[perl-recognition-invalidated-token-restoration]] records a separate private-core terminal-state defect
under `.38`; neither static policy proof nor carrier parity establishes its repair.
