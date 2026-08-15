# VERIFICATION-CADENCE-POLICY: proportional commit checks and canonical boundary proof

## Metadata

- Tree ID: `VERIFICATION-CADENCE-POLICY`
- Status: `done` / `closed`
- Roadmap lane: `Repository continuity / verification economics and CI enforcement`
- Created: `2026-08-15`
- Last updated: `2026-08-15`
- Owner: repo-local workflow

## Goal

Make verification proportional to risk: ordinary commits run focused affected-surface and direct-dependent checks,
while the complete canonical local CI gate runs once at batch/push boundaries and at explicitly designated
admission, milestone, or foundational-infrastructure boundaries. Store the rule durably and enforce the selected
tier, canonical receipts, and pre-push boundary mechanically.

## Director Decision

On 2026-08-15 the director rejected complete canonical CI as the default for every ordinary commit because the
repeated long gate materially suppresses feature progress. The director requires the tiered mode to begin after
atomic 234, to be stored in the appropriate durable owners, and to be enforced from then onward.

## Non-Goals

- Weakening task-tree ownership, per-leaf commits, the eight pre-existing doctrines, or focused regression evidence.
- Removing or shrinking `tools/run_ci_local.sh` as the canonical local source of truth.
- Re-enabling hosted GitHub Actions.
- Guessing that an affected-surface test is sufficient when a leaf is an admission, public-contract, dependency,
  toolchain, CI, hook, storage/path doctrine, or other foundational boundary.
- Changing parser, compiler, runtime, backend, `.spec`, public API, schema, descriptor, or generated-format behavior.

## Task Tree

- ID: `VERIFICATION-CADENCE-POLICY`
  Status: `done`
  Goal: Adopt and enforce proportional verification without weakening canonical boundary proof.
  Children: `VERIFICATION-CADENCE-POLICY.0`

- ID: `VERIFICATION-CADENCE-POLICY.0`
  Status: `done; signoff-complete` (task-tree-first from clean atomic-234 commit `1e6d326d`; no policy, hook, or
    checker edit preceded this activation)
  Goal: Ratify the two verification tiers and mechanically enforce tier evidence, canonical receipts, and the
    clean pre-push canonical boundary.
  Verification tier: `canonical`
  Focused checks: shell syntax; policy/checker mutation cases; real staged focused/canonical receipt cases; all
    doctrine, memory, task, Knowledge, history-pressure, book, and diff checks.
  Canonical trigger: this leaf changes commit workflow, CI, Git hooks, receipt tooling, and doctrine enforcement.
  Acceptance: define exact focused and canonical tiers; require one explicit tier plus selected-check evidence in
    each new leaf commit; require canonical tier for named high-risk boundaries; bind canonical success to the
    staged Git candidate with a repository-local receipt; make pre-push run or safely reuse canonical proof for clean
    `HEAD`; keep pre-commit fast; document honest hook limits; add a decision record, Knowledge card, mdBook
    guidance, live projections, and a registered deterministic doctrine; pass focused and canonical signoff;
    commit/brief-clear/clean handoff before resuming `INTER-MATCH-GAP-CAPTURE.4.2`.
  Verification: Shell syntax passes for every changed/new hook, gate, checker, and receipt owner. Classifier
    self-test passes 6 canonical paths + 4 focused paths + 5 tier cases; the focused receipt suite passes nine
    missing/malformed/stale/matching staged and committed cases. Dirty pre-push rejects before work; structural
    proof locks exact clean-HEAD run/reuse routing. The staged doctrine rejects the canonical leaf without a
    receipt, then accepts the exact receipt created only by successful canonical local CI. Knowledge is 837 facts
    / 7,049 keys; the book renders 79 files / 14,796 KiB; both history-pressure checks, diff hygiene, and all nine
    doctrines pass. The complete canonical gate and its exact staged-candidate receipt pass before commit.
  Commit: `VERIFICATION-CADENCE-POLICY.0 - enforce tiered verification cadence` (intended atomic 235/300)

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `VERIFICATION-CADENCE-POLICY.0` | `done; signoff-complete from clean 1e6d326d` | The tiered policy is stored and mechanically enforced for intended atomic 235; Dart `.4.2` may resume afterward. |

## Decisions

- `2026-08-15`: Ordinary leaf commits use the focused tier: exact changed behavior, direct dependents, relevant
  language/component gates, all doctrines, bounded-history checks, Knowledge synchronization, and diff hygiene.
- `2026-08-15`: Full canonical CI is mandatory at a batch/push boundary and at a leaf explicitly classified as an
  admission, milestone/parent closeout, public/cross-backend contract, dependency/toolchain, CI/hook/gate, or
  storage/path/doctrine boundary. Uncertainty after focused failures may escalate a leaf to canonical.
- `2026-08-15`: Pre-commit remains fast and runs doctrine enforcement; pre-push owns the automatic canonical gate.
  A canonical leaf must also carry a receipt bound to its staged Git candidate so the commit cannot claim an unrun gate.
- `2026-08-15`: A valid canonical receipt for the exact new commit may be promoted post-commit and reused at the
  immediate push boundary. Any later focused commit invalidates that receipt by changing `HEAD`/tree identity.
- `2026-08-15`: The first real missing-receipt check exposed that `git write-tree` may acquire `.git/index.lock`,
  violating the receipt checker's read-only/sandbox contract. Use base `HEAD` plus SHA-256 of Git's full-index
  binary staged diff; post-commit recomputes the same parent-to-commit diff before promotion.

## Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — `rg -n` and hook/source reads prove pre-commit already ran only doctrines, no
  pre-push owner existed, no tier/receipt existed, and the immediately preceding canonical gate took 745 seconds.
- [x] **ROOT CAUSE (WHY + WHERE)** — The missing mechanism was localized to `COMMIT.md`, `.githooks/`,
  `tools/run_ci_local.sh`, and `scripts/check_doctrines.sh`: complete CI was authoritative but cadence and exact
  candidate identity were prose-only, and no push boundary consumed them.
- [x] **FIX** — ADR `0073`, `COMMIT.md`, `tools/verification_receipt.sh`, all three hooks,
  `scripts/check_verification_cadence.sh`, and the nine-doctrine registry now implement one exact tier/receipt/
  push contract without product behavior change.
- [x] **ADDRESSED (verified)** — `bash scripts/check_verification_cadence.sh --self-test` passes 15 path/tier cases;
  `bash tools/test_verification_cadence_policy.sh` passes nine receipt cases. The real staged policy leaf rejects a
  missing receipt, then accepts the canonical gate's exact receipt; dirty pre-push rejects before execution. The
  index-lock RED is removed by the read-only staged-diff fingerprint.
- [x] **NO REGRESSION** — `bash -n`, the focused policy suite, Knowledge 837/7,049, book 79/14,796 KiB, both
  history-pressure checks, `git diff --check`, all nine doctrines, and `bash tools/run_ci_local.sh` pass.
- [x] **LOCKSTEP** — ADR/index, task/index, `COMMIT.md`, hooks, receipt/gate/checker, doctrine registry, README/
  TOOLBOX, mdBook, Knowledge, both roadmaps, live docs, and memory describe one policy before intended atomic 235.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-08-15` | `VERIFICATION-CADENCE-POLICY.0` | Clean `1e6d326d` activation; source/routing audit; shell syntax; 15 classifier/tier cases; nine receipt cases; real missing/exact receipt boundary; dirty pre-push rejection; Knowledge; rendered mdBook; history pressure; diff; nine doctrines; canonical local CI | Pass: ordinary staged leaves may select focused proof without a canonical receipt; CI/hook/doctrine/dependency paths require canonical tier; stale or missing receipts reject; exact staged and committed identities pass. Knowledge is 837/7,049 and book 79/14,796 KiB. The full canonical gate writes the exact staged-candidate receipt and exits 0 before atomic 235. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `VERIFICATION-CADENCE-POLICY.0` | `VERIFICATION-CADENCE-POLICY.0 - enforce tiered verification cadence` | Intended atomic 235/300 from clean `1e6d326d`; no push. |

## Changelog

- `2026-08-15`: Activated the director-requested tiered-verification owner from clean atomic 234 at `1e6d326d`
  before policy, hook, receipt, checker, or documentation implementation.
- `2026-08-15`: Completed the two-tier policy and its ninth doctrine. Ordinary commits now select focused proof;
  designated leaves and clean push boundaries use exact receipt-bound canonical proof. Hosted CI remains disabled
  and `tools/run_ci_local.sh` remains authoritative.
