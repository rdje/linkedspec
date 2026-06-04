# 0005 — Adopt the Knowledge Map retrieval layer (archaeology eliminated for structural facts only)

- Date: 2026-06-05
- Status: accepted
- Tags: memory, retrieval, knowledge-map

## Context

`MEMORY_ARCHITECTURE.md` makes durable facts *survive* (layers A–D). It does not make them
*findable by question*: a fresh agent could still re-derive a fact from code/runtime that was
already logged once — **archaeology**, a retrieval failure. The portable Knowledge Map (KM)
bundle adds a derived, question-keyed index over small front-mattered fact cards. The
`MEMORY-ARCHITECTURE-DOC` tree deferred it as a non-goal; this record reverses that.

## Decision

Adopt the KM as an **additive** layer (it converts nothing, replaces nothing):

1. The `knowledge-map/` bundle is vendored at the repo root; its standard is
   `knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md`.
2. A **fact** is one `.md` under `docs/knowledge/` (or a `docs/decisions/` record given an
   `answers:` block) whose front-matter has a non-empty `answers:` list plus
   `id`/`title`/`date` and `evidence`/`reverify`. The card is a **signpost** to the canonical
   home (book/code/decision/task-tree) — never a copy.
3. `KNOWLEDGE_MAP.md` (repo root) is **derived + deterministic** — never hand-edited. The
   pre-commit hook regenerates + stages it; `knowledge-map/scripts/check_knowledge_map.sh`
   runs in `.githooks/pre-commit` and `tools/run_ci_local.sh` (derive-and-diff sync gate).
4. Cards are written **lazily** — one whenever a durable fact is established or archaeology is
   caught. No migration project.

**The boundary (do not oversell):** the KM eliminates archaeology for **durable
structural/causal facts** (root causes, architectural constraints, gotchas, where-things-live).
It does **not** remove first-time **measurement** of changing runtime state — you cannot
pre-write a measurement you have not taken; that is legitimate diagnostics. The rule there is
that the durable **conclusion** of a measurement becomes a card so nobody measures it twice.

## Consequences

- A future session greps `KNOWLEDGE_MAP.md` before excavating; the flagship seed card
  `actionrewriter-removed-phase1` directly answers the question whose stale answer triggered
  the `DOC-CODEBASE-ALIGNMENT` cleanup.
- Bundle default knobs fit this repo (`KM_SCAN_DIRS=docs/knowledge docs/decisions`,
  `KM_OUTPUT=KNOWLEDGE_MAP.md`); no `.knowledge_map.conf` override is needed.
- The KM gate composes with `MEMORY_ARCHITECTURE.md` §9 enforcement in the same hook + local
  CI gate, so the map cannot drift.

## Links

- Standard + tooling: `knowledge-map/` (bundle), `KNOWLEDGE_MAP.md`, `docs/knowledge/`.
- Tree: `docs/tasks/KNOWLEDGE-MAP-DOC.md`. Memory standard: `MEMORY_ARCHITECTURE.md` §5.
