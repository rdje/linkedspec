# KNOWLEDGE-MAP-DOC: Adopt the Knowledge Map retrieval layer

## Metadata

- Tree ID: `KNOWLEDGE-MAP-DOC`
- Status: `active`
- Roadmap lane: `Durable memory architecture (cross-project standard)`
- Created: `2026-06-05`
- Last updated: `2026-06-05`
- Active frontier: `KNOWLEDGE-MAP-DOC.1`
- Owner: repo-local workflow

## Goal

Adopt the portable, harness-agnostic **Knowledge Map (KM)** bundle — the composed,
question-keyed retrieval layer on top of `MEMORY_ARCHITECTURE.md` — so a future
session never re-derives ("archaeology") a structural/causal fact that was already
logged once. It is **additive**: it converts nothing and replaces nothing; it adds a
machine-derived index over small front-mattered fact cards. This was explicitly
deferred as a non-goal of `MEMORY-ARCHITECTURE-DOC`; this tree reverses that and
reconciles the "not adopted" notes.

## Non-Goals

- No big-bang conversion of existing docs/book/task-trees into cards (forbidden by the
  KM standard). Seed a small set of high-value cards; grow lazily thereafter.
- No always-on hosted GitHub Actions workflow (hosted CI stays disabled per
  `docs/decisions/0004-hosted-ci-disabled-local-gate.md`); the KM check is wired into
  the local gate `tools/run_ci_local.sh`.
- No code/behavior change to the parser/compiler/runtime.

## Acceptance Criteria

- The `knowledge-map/` bundle is vendored at the repo root (copied verbatim), with
  `docs/knowledge/` created and `KNOWLEDGE_MAP.md` generated (derived, deterministic).
- A seed set of durable-fact cards exists under `docs/knowledge/`, each with the
  required front-matter (`id`, `title`, `answers`, `date`, `evidence`/`reverify`) and a
  signpost body pointing at the canonical home.
- Enforcement live: the KM gate (regenerate + stage + `check_knowledge_map.sh`) is in
  `.githooks/pre-commit` (alongside the memory-arch gate) and the KM check runs in
  `tools/run_ci_local.sh`; the gate is demonstrably biting.
- The "not adopted" notes in `MEMORY_ARCHITECTURE.md` §5 and the bootstrap pointers are
  reconciled to "adopted"; the pointers route agents to `KNOWLEDGE_MAP.md`.
- A decision record records the adoption + the archaeology boundary (structural facts vs
  first-time measurement).
- Full local gate green end-to-end; each leaf committed through `COMMIT.md`.

## Task Tree

- ID: `KNOWLEDGE-MAP-DOC`
  Status: `active`
  Goal: `Adopt the Knowledge Map retrieval layer (additive to MEMORY_ARCHITECTURE.md).`
  Children: `KNOWLEDGE-MAP-DOC.1`, `KNOWLEDGE-MAP-DOC.2`, `KNOWLEDGE-MAP-DOC.3`, `KNOWLEDGE-MAP-DOC.4`

- ID: `KNOWLEDGE-MAP-DOC.1`
  Status: `done`
  Goal: `Vendor the bundle: cp -r the knowledge-map/ bundle (from the pgen reference) into the repo root verbatim; run knowledge-map/install.sh to create docs/knowledge/ and generate the initial KNOWLEDGE_MAP.md. Add a README.md doc-map pointer, and reconcile the MEMORY_ARCHITECTURE.md §5 "not adopted here" note (and the MEMORY-ARCHITECTURE-DOC tree's non-goal cross-ref) to "adopted".`
  Acceptance: `knowledge-map/ present at root; docs/knowledge/ created; KNOWLEDGE_MAP.md generated and in sync; README points at it; the §5 note says adopted (not "not adopted").`
  Verification: `2026-06-05: Vendored knowledge-map/ verbatim (10 files; diff -r identical to the pgen source). knowledge-map/install.sh created docs/knowledge/ (+ a README pointer) and generated KNOWLEDGE_MAP.md (0 facts, 0 keys); check_knowledge_map.sh reports OK (map in sync). README doc map updated: a Knowledge Map bullet under "durable memory architecture" + path-map entries for KNOWLEDGE_MAP.md / docs/knowledge/ / knowledge-map/. MEMORY_ARCHITECTURE.md §5 note reconciled "not adopted" → "adopted". Cross-ref added to the MEMORY-ARCHITECTURE-DOC changelog. No code change — perl -c perl/LinkedSpec.pm OK; phase0 1004 PASS baseline holds.`
  Commit: `pending (leaf ID in commit subject)`

- ID: `KNOWLEDGE-MAP-DOC.2`
  Status: `pending`
  Goal: `Seed durable-fact cards under docs/knowledge/ for high-value, archaeology-prone structural/causal facts (e.g. ActionRewriter.pm was deleted in Phase 1 and the helper-rewrite entrypoint moved; LinkedSpec.pm is a thin facade with the ParserFactory→Runtime→Compiler spine; the phase0 all-target ActionIR-ready invariant; hosted CI disabled / run the local gate; the AND++LX self-hosting hang gotcha; spec.spec is the self-hosted grammar). Each card: required front-matter + a signpost body pointing to the canonical home. Regenerate the map; check passes.`
  Acceptance: `Several valid fact cards exist; check_knowledge_map.sh passes (fields valid, ids unique, map in sync); KNOWLEDGE_MAP.md shows the question keys. Every carded fact verified true against the repo before writing its reverify command.`
  Verification: `2026-06-05: Authored 6 durable-fact cards under docs/knowledge/: actionrewriter-removed-phase1, linkedspec-pm-is-thin-facade, phase0-all-target-actionir-ready-invariant, hosted-ci-disabled-run-local-gate, spec-spec-self-hosted-grammar, andplusplus-lx-parser-hang. Each fact was verified true against the repo BEFORE writing its reverify: ActionRewriter.pm absent + rewrite_action_code_for_compat present in RuleIR/EmitContext.pm; perl/LinkedSpec.pm = 258 lines + OwnerDispatch.pm present; language_agnostic_ready_ratio present in t/phase0_regression.t (4 hits); ci.yml workflow_dispatch-only; specs/spec.spec present; PHASE7 documents the AND++LX hang (5 hits). Regenerated KNOWLEDGE_MAP.md -> 6 facts, 29 question keys; check_knowledge_map.sh OK (fields valid, ids unique, map in sync). No code change — perl -c perl/LinkedSpec.pm OK; phase0 1004 PASS baseline holds.`
  Commit: `pending (leaf ID in commit subject)`

- ID: `KNOWLEDGE-MAP-DOC.3`
  Status: `pending`
  Goal: `Wire enforcement and reconcile discovery. Replace the exec-based .githooks/pre-commit with a form that runs BOTH the memory-arch self-check AND the KM gate (regenerate + git add the map + check_knowledge_map.sh). Add the KM check to tools/run_ci_local.sh. Update the bootstrap pointers (AGENTS.md + CLAUDE.md/.cursorrules/.github/copilot-instructions.md) to route agents to KNOWLEDGE_MAP.md and to "write a card when you establish a durable fact or catch archaeology". Add a decision record (0005) for the KM adoption + the archaeology boundary. Prove the KM gate bites.`
  Acceptance: `pre-commit runs both gates; run_ci_local.sh runs the KM check; bootstrap pointers reference the KM (no "not adopted" left); 0005 record added + indexed; the KM check fails on an injected invalid card / out-of-sync map and passes on the clean tree; the .3 commit passes through the now-KM-gated hooks.`
  Verification: `pending`
  Commit: `pending`

- ID: `KNOWLEDGE-MAP-DOC.4`
  Status: `pending`
  Goal: `Verify end-to-end: run the full local gate (bash tools/run_ci_local.sh — memory-arch self-check, KM check, perl -c, phase0), confirm green; sync the live docs; close the tree.`
  Acceptance: `tools/run_ci_local.sh exits 0 with both the memory-arch and KM checks passing and phase0 PASS; live docs synced; tree marked done and moved to Completed in docs/TASK_TREE.md.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `KNOWLEDGE-MAP-DOC.1` | `done` | Bundle vendored, map generated (in sync), README + §5 reconciled. perl -c OK. |
| 2 | `KNOWLEDGE-MAP-DOC.2` | `done` | 6 verified fact cards seeded; map regenerated (6 facts/29 keys); check OK. |
| 3 | `KNOWLEDGE-MAP-DOC.3` | `pending` | Wire the gates once the cards/map are valid; reconcile discovery; record the decision. |
| 4 | `KNOWLEDGE-MAP-DOC.4` | `pending` | Final end-to-end verification + live-doc sync + close. |

## Decisions

- `2026-06-05`: Adopt the KM bundle verbatim (it is project-agnostic). Use the bundle
  default knobs (`KM_SCAN_DIRS=docs/knowledge docs/decisions`, `KM_OUTPUT=KNOWLEDGE_MAP.md`)
  — they already fit linkedspec — so no repo-root `.knowledge_map.conf` override is needed.
- `2026-06-05`: The current `.githooks/pre-commit` uses `exec`, which would prevent any
  appended gate from running; replace it with a form that calls both the memory-arch
  self-check and the KM gate sequentially.
- `2026-06-05`: Wire the KM check into the local gate (`tools/run_ci_local.sh`), not a new
  hosted GitHub Actions workflow, to stay consistent with `docs/decisions/0004`.
- `2026-06-05`: This reverses the `MEMORY-ARCHITECTURE-DOC` non-goal that excluded the KM;
  reconcile the "not adopted" notes (no-drift) rather than leaving them stale.

## Open Questions

- None blocking.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-05` | `KNOWLEDGE-MAP-DOC.1` | `diff -r` bundle vs pgen source (identical); `knowledge-map/install.sh` (map generated, check OK); README/§5 review; `perl -c perl/LinkedSpec.pm`. | Pass — bundle vendored, initial map in sync, discovery + §5 reconciled; no code change; phase0 1004 PASS baseline holds. Frontier → `.2`. |
| `2026-06-05` | `KNOWLEDGE-MAP-DOC.2` | Verified all 6 facts against the repo; `gen_knowledge_map.sh` (6 facts/29 keys); `check_knowledge_map.sh` OK; `perl -c perl/LinkedSpec.pm`. | Pass — 6 valid, evidence-backed fact cards seeded; map in sync; no code change; phase0 1004 PASS baseline holds. Frontier → `.3`. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `KNOWLEDGE-MAP-DOC.1` | `Vendor knowledge-map bundle + generate initial map (KNOWLEDGE-MAP-DOC.1)` | Hash `4401355`. |
| `KNOWLEDGE-MAP-DOC.2` | `Seed 6 durable-fact cards under docs/knowledge (KNOWLEDGE-MAP-DOC.2)` | Hash backfilled later if useful. |

## Changelog

- `2026-06-05`: Completed `KNOWLEDGE-MAP-DOC.2` — seeded 6 verified durable-fact cards (ActionRewriter-removed, thin-façade, phase0 invariant, hosted-CI-disabled, spec.spec self-hosting, AND++LX hang); regenerated the map (6 facts / 29 question keys); check passes. Active frontier: `.3`.
- `2026-06-05`: Completed `KNOWLEDGE-MAP-DOC.1` — vendored the `knowledge-map/` bundle, generated the initial `KNOWLEDGE_MAP.md`, wired README discovery, and reconciled the `MEMORY_ARCHITECTURE.md` §5 "not adopted" note to "adopted". Active frontier: `.2`.
- `2026-06-05`: Created task tree to adopt the Knowledge Map retrieval layer (the composed layer deferred during `MEMORY-ARCHITECTURE-DOC`), after the user directed adopting `KNOWLEDGE_MAP_ARCHITECTURE.md` here.
