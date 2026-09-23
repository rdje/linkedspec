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
date: 2026-09-23
status: accepted and implemented under ADR 0073 / VERIFICATION-CADENCE-POLICY.0
tags: [verification, testing, local-ci, commit-workflow, hooks, doctrine, receipts]
evidence: "Atomic 234 at 1e6d326d is the clean activation boundary. The director requires proportional verification after that commit: focused changed-surface and direct-dependent proof for ordinary leaves, complete canonical CI for designated high-risk leaves and the final clean push boundary. ADR 0073, COMMIT.md, task-tier metadata, the VERIFICATION-CADENCE doctrine, exact staged-candidate receipts, and pre-push routing are the canonical owners."
evidence_update_2026_08_15: "Implementation adds exact tier/check/trigger evidence, 15 path/tier cases, nine missing/malformed/stale/matching receipt cases, fast pre-commit, exact post-commit promotion, and clean pre-push run/reuse. The first staged check proved git write-tree can acquire .git/index.lock under a read-only sandbox, so the final receipt uses base HEAD plus SHA-256 of Git's full-index binary staged diff and replays the parent-to-commit diff before promotion. Knowledge is 837 facts / 7,049 keys, the book renders 79 files / 14,796 KiB, all nine doctrines pass, and the foundational policy leaf requires the complete receipt-bound canonical gate before intended atomic 235."
reverify:
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

The cadence checker counts added verification metadata lines across the staged
task-file diff, not only the commit-subject node. Exactly one `Verification tier`,
`Focused checks` and `Canonical trigger` must be added for the committing leaf.
When decomposing future work, keep its proposed proof under planned fields until
activation. Startup `.47.1` verified this boundary after the first hook rejected
three declarations; its immediate `.47.2`/`.47.3` proof requirements remain intact.
