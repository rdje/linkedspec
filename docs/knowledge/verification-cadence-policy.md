---
id: verification-cadence-policy
title: Ordinary commits use focused proof and canonical CI runs at designated or push boundaries
answers:
  - "does every commit run full CI"
  - "when should I run tools run_ci_local"
  - "what checks should an ordinary LinkedSpec commit run"
  - "what is the focused verification tier"
  - "what is the canonical verification tier"
  - "when is canonical CI mandatory"
  - "how is a canonical local CI run remembered"
  - "what does the pre push hook verify"
  - "can a canonical CI receipt be reused before push"
  - "why does canonical CI require staged files"
  - "why does adding verification metadata to pending child tasks fail a focused commit"
  - "where does canonical CI write Phase0 progress"
  - "does check-head prove the working tree is clean"
  - "does a publication outcome record inherit the pushed commit receipt"
date: 2026-11-05
status: accepted and implemented under ADR 0073 / VERIFICATION-CADENCE-POLICY.0
tags: [verification, testing, local-ci, commit-workflow, hooks, doctrine, receipts]
evidence: "Atomic 234 at 1e6d326d is the clean activation boundary. The director requires proportional verification after that commit: focused changed-surface and direct-dependent proof for ordinary leaves, complete canonical CI for designated high-risk leaves and the final clean push boundary. ADR 0073, COMMIT.md, task-tier metadata, the VERIFICATION-CADENCE doctrine, exact staged-candidate receipts, and pre-push routing are the canonical owners."
evidence_update_2026_08_15: "Implementation adds exact tier/check/trigger evidence, 15 path/tier cases, nine missing/malformed/stale/matching receipt cases, fast pre-commit, exact post-commit promotion, and clean pre-push run/reuse. The first staged check proved git write-tree can acquire .git/index.lock under a read-only sandbox, so the final receipt uses base HEAD plus SHA-256 of Git's full-index binary staged diff and replays the parent-to-commit diff before promotion. Knowledge is 837 facts / 7,049 keys, the book renders 79 files / 14,796 KiB, all nine doctrines pass, and the foundational policy leaf requires the complete receipt-bound canonical gate before intended atomic 235."
evidence_update_2026_11_05: "Recovery23.4.10.2 retains actual default canonical completion, exact committed receipt, normal successful push and independent read-back in docs/checkpoints/publication-recovery-2026-11-05/. The current driver directly invokes prove -v for Phase0; verification_receipt.sh check-head compares committed HEAD/tree only, while pre-push separately checks worktree/index/untracked cleanliness. Later outcome records need their own future publication proof."
reverify:
  - "perl tools/check_task_verification_fields.pl --self-test"
  - "bash scripts/check_verification_cadence.sh --self-test"
  - "bash tools/test_verification_cadence_policy.sh"
  - "bash scripts/check_doctrines.sh"
---

# Tiered verification cadence

Use `focused` for an ordinary bounded leaf. Record and run the exact changed-behavior tests, direct-dependent
matrices, relevant backend/component local gate, all doctrines, Knowledge and bounded-history synchronization,
diff hygiene, and mdBook rendering when affected. Complete canonical CI is not required for that commit.

Use `canonical` for admission/promotion, milestone or parent closeout, public/cross-backend contract or generated-
format movement, dependencies/toolchains, CI/hooks/gates, storage/path/doctrine infrastructure, or systemic
uncertainty. Stage the exact candidate first; `tools/run_ci_local.sh` writes a receipt for `HEAD` plus the staged
tree. Pre-commit verifies that receipt, post-commit may promote it, and pre-push reuses it only for exact committed
`HEAD`; otherwise pre-push runs the full gate.

ADR `0004` still disables hosted CI and names the local gate as the source of truth. ADR `0073` changes only the
cadence so a batch runs focused proof per slice and complete proof at its final push boundary.

As of containment `.16.2` (2026-09-24), the cadence checker compares verification
declarations by stable task ID and exact field value between `HEAD` and the index
across changed task files. Unchanged declarations moved with their node do not
create another slice. Exactly one leaf must have changed declarations, and its
staged node must contain one nonempty `Verification tier`, `Focused checks` and
`Canonical trigger`; missing, duplicate, unowned or split declarations fail.
`tools/check_task_verification_fields.pl --self-test` exercises fourteen controls,
including relocation, changed historical fields and duplicate moved nodes.

When decomposing future work, keep its proposed proof under planned fields until
activation. Startup `.47.1` encountered the former added-line counter after its
first hook rejected three declarations. That historical result remains valid;
the current identity-based check preserves the one-leaf requirement while allowing
lossless partition moves. Receipt and canonical-boundary requirements are unchanged.

The canonical driver invokes `prove -v -Iperl t/phase0_regression.t` directly,
with inherited output. A caller's redirected canonical log is therefore the log
to retain; the driver creates no separate Phase0 progress log. Quiet output alone
does not establish a hang or success. Inspect the actual running process and wait
for the complete exit/result before relying on the receipt.

`tools/verification_receipt.sh check-head` compares the retained committed receipt
with Git's current `HEAD` and tree identity. It does not inspect worktree cleanliness.
`.githooks/pre-push` separately rejects unstaged, staged and untracked non-ignored
inputs before checking or obtaining that receipt. A successful publication can be
recorded in a later focused commit; that later commit needs fresh exact-HEAD proof
at its own publication boundary. The earlier receipt remains historical evidence.
