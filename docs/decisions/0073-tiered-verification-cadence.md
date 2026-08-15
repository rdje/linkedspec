# ADR 0073: Verification is focused per ordinary commit and canonical at boundaries

- Date: 2026-08-15
- Status: accepted; implementation owned by `VERIFICATION-CADENCE-POLICY.0`
- Tags: verification, testing, local-ci, commit-workflow, hooks, doctrine, productivity, receipts

## Context

LinkedSpec's complete local CI gate is intentionally broad and remains the source of truth because hosted GitHub
Actions is disabled under ADR `0004`. The gate now composes five backend implementations, six runtime routes,
project-data containment and relocation, cross-backend matrices, primary CLI conformance, and 1,031 Phase-0
tests. Recent canonical runs take roughly twelve to thirteen minutes before optional runtime routes. Repeating the
same full proof for every small implementation commit materially delays feature progress without proportionally
improving the evidence for that slice.

The existing pre-commit hook already runs only fast doctrine checks, while task leaves conventionally name
focused checks. What was missing was one durable tier-selection rule, mechanical proof that canonical claims ran
against the exact candidate, and an automatic canonical boundary before a batch is pushed.

## Decision

LinkedSpec uses two verification tiers:

- `focused` is the ordinary commit default. It covers the exact changed behavior, direct dependent matrices,
  relevant component/backend gates, all doctrines, Knowledge and bounded-history synchronization, diff hygiene,
  and mdBook rendering when affected. It does not require complete canonical local CI.
- `canonical` is required for admission/promotion, milestone or parent closeout, public/cross-backend contract or
  generated-format movement, dependency/toolchain changes, CI/hook/gate changes, storage/path/doctrine
  infrastructure, or a focused investigation that exposes systemic uncertainty.

Every new leaf commit records exactly one tier, its selected focused checks, and the canonical trigger (or
`none`). The `VERIFICATION-CADENCE` doctrine rejects missing/duplicate tier evidence and mechanically forces
canonical tier for staged gate/dependency/doctrine owners.

A canonical run starts only from a fully staged candidate with no unstaged tracked or untracked non-ignored
inputs. `tools/run_ci_local.sh` fingerprints base `HEAD` plus the SHA-256 of Git's full-index binary staged diff,
verifies that read-only identity is unchanged at success, and writes an untracked receipt under repository-local
`.linkedspec-data`. Pre-commit rejects a canonical-tier claim without the exact receipt. Post-commit may promote a
receipt only when the same parent-to-commit diff exactly became the new commit. `.githooks/pre-push` requires a
clean tree and reuses only a receipt for
exact committed `HEAD`; otherwise it runs the complete canonical gate once.

The fingerprint deliberately does not call `git write-tree`: that nominally descriptive command may acquire
`.git/index.lock`, which breaks a read-only doctrine check in restricted environments. Hashing Git's full-index
binary diff reads the exact staged modes, identities, and content without mutating `.git`; pairing it with base
`HEAD` makes the candidate identity unambiguous, and promotion replays the same diff over `HEAD^1..HEAD`.

The ordinary batch cadence is therefore focused proof plus one commit per slice, followed by one full canonical
run at the final clean push boundary. A designated canonical leaf may run it earlier because that boundary itself
requires complete proof.

## Consequences

- Feature work no longer waits for the complete multi-backend gate after every ordinary commit.
- Every ordinary commit still has task-specific behavior and direct-dependent evidence plus all structural
  doctrines; the risk window closes at the next designated or push boundary.
- Canonical claims are bound to exact Git content rather than prose or an unversioned terminal log.
- Pre-push may be long when no exact receipt exists. That cost occurs once per batch, where it buys proof of the
  complete committed state.
- Hooks remain locally bypassable. With hosted CI disabled, enforcement is strong in the normal workflow but not
  literally unbypassable; bypassing it is explicit policy non-compliance.
- ADR `0004` remains authoritative for hosted-CI status and canonical gate identity; this ADR supersedes only its
  former advice to run the full gate before every commit.

## Links

- Owning tree: `docs/tasks/VERIFICATION-CADENCE-POLICY.md`
- Commit workflow: `COMMIT.md`
- Canonical gate: `tools/run_ci_local.sh`
- Receipt owner: `tools/verification_receipt.sh`
- Doctrine: `scripts/check_verification_cadence.sh`
- Hooks: `.githooks/pre-commit`, `.githooks/post-commit`, `.githooks/pre-push`
