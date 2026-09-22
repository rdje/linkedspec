# Agent bootstrap — read this first, whatever AI or harness you are

This file is the tool-neutral entrypoint (the common `AGENTS.md` convention). Other
harnesses' bootstrap files (`CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`)
point back here. The system of record is **`README.md`** (the project) +
**`MEMORY_ARCHITECTURE.md`** (how memory + continuity work).

## On every session start / resume

1. Read **`README.md`** — project objective, layout, standard commands.
2. Read **`MEMORY_ARCHITECTURE.md`** — the durable memory system (MANDATORY; it is
   mechanically enforced — see Enforcement below).
3. Derive current `HEAD` from Git, then resume from **`MEMORY.md`** — the bounded
   layer-A pointer: clean leaf `activation_commit`, active task-tree frontier leaf,
   the single next action, any in-flight uncommitted work.
4. Read **`SESSION_BOOTSTRAP.md`** and open the active **task-tree** under `docs/tasks/`
   (index: `docs/TASK_TREE.md`); its frontier row is your precise next step. For a partitioned tree, resolve the
   stable leaf with `perl tools/read_task_tree.pl --tree <tree> --id <stable-id>` instead of scanning every part.
5. Pull only the relevant **decision records** under `docs/decisions/` (index: `INDEX.md`).
6. **Before re-deriving any fact from code or runtime, check `KNOWLEDGE_MAP.md`** — grep your
   question, follow the one pointer to the canonical home, and trust the dated fact or run its
   `reverify` command. Re-deriving a fact that was already logged once is *archaeology*
   (`knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md`).
7. **Before searching old live-status chronology, use the indexed history query** — run
   `perl tools/read_document_history.pl --surface live_status --grep '<literal>'`, or `--all` for exact
   reconstruction. `LIVE_ACHIEVEMENT_STATUS.md` is the bounded current view, not the historical store.
8. **After editing a mutable partitioned task part, refresh its index snapshot** — run
   `perl tools/update_task_tree_index.pl --tree <tree>` in the same slice; never edit an immutable history part.
9. **When debugging, reach for LinkedSpec's own tools FIRST** — read `TOOLBOX.md` (the
   `LinkedSpec::Get`/`return_descriptor`/`call_spec_handler_subst`/`dump_parser_source` probes, the
   `LINKEDSPEC_TRACE_LEVEL` trace framework, the `tools/` scripts, the gates). Never eyeball a `.spec`
   or guess a root cause before the toolbox has shown the exact mechanism + source location.
10. **Doctrines are mechanically enforced** (`DOCTRINE_ENFORCEMENT.md`, the 4th portable architecture):
    every rule pairs with a `scripts/check_*.sh` run by the registry driver `scripts/check_doctrines.sh`
    via fast `.githooks/pre-commit` (E3) + `tools/run_ci_local.sh` (E4); `.githooks/pre-push` requires or runs
    canonical proof for exact clean `HEAD`. Add a doctrine = a check + one registry line.

Startup uses the targeted-reading and 2–5 minute recovery guidance in `SESSION_BOOTSTRAP.md`
(ADR `0123`). The full-reading audit remains separate; recover the active task from `MEMORY.md`.

## Non-negotiable working rules

- **RGX and PGEN are black boxes (director instruction, 2026-09-20).** LinkedSpec
  integrates with RGX only: use RGX's published integration document, public APIs
  and contracts. RGX owns all transitive dependency preparation; LinkedSpec must
  not carry a separate PGEN build procedure or consult its internals. Do not inspect,
  analyze or modify their implementation, reconstruct internal build procedures, or
  change submodule pins. Source access is not authorization. Reproduce problems through
  RGX's public interface and report them to RGX. Remove implementation-derived
  dependency assumptions from maintained knowledge and plans; historical observations
  do not override this boundary. Normal documented builds and reuse of their outputs
  are permitted. This rule overrides contrary older reading or dependency task plans.
- **No change without an owning task-tree leaf first** (`docs/TASK_TREE_README.md`;
  doctrine: `docs/decisions/0001-task-tree-and-commit-doctrine.md`).
- **Keep `README.md` a bounded stable landing page** (`README_POLICY.md`, ADR `0063`). Route changing detail to
  its canonical owner; `scripts/check_readme_stability.sh` unconditionally enforces both README budgets and the
  registry-backed resulting-tree pressure controls of every reader/overflow destination.
- **Route every durable thing to a layer and commit before the turn ends** — resume
  pointer (`MEMORY.md`, overwrite-only, capped) / task-trees (`docs/tasks/`) / decision
  records (`docs/decisions/`) / git history. Nothing important may live only in this
  conversation.
- **Commit per `COMMIT.md`** after every slice, with the **task-tree leaf id in the
  subject**; use `git_message_brief.txt` (untracked; cleared to 0 bytes after commit).
- **Use ADR `0073` verification tiers:** ordinary leaf commits record and run focused changed-surface/direct-
  dependent proof; designated admission/milestone/public/infrastructure leaves and the final clean push boundary
  run receipt-bound canonical CI. Do not run the full gate automatically for every ordinary commit.
- **Before committing, run `scripts/check_memory_architecture.sh`** — git hooks and the
  local CI gate (`tools/run_ci_local.sh`) run it too; a non-compliant change fails and
  cannot land.
- **Write a Knowledge Map fact card** (`docs/knowledge/<id>.md`, front-matter with an
  `answers:` list of the questions an agent would grep) whenever you establish a durable
  structural/causal fact, or catch yourself re-deriving one — so the next session finds it
  instead of excavating it. The map (`KNOWLEDGE_MAP.md`) is **derived + gated**; never
  hand-edit it. (First-time measurement of changing runtime state is legitimate diagnostics,
  not archaeology — but its durable *conclusion* becomes a card.)

## Enforcement (why this is hard to ignore)

`MEMORY_ARCHITECTURE.md` §9 wires four gates: these bootstrap pointers (E1 discovery),
`scripts/check_memory_architecture.sh` (E2 invariants), `.githooks/` (E3 fast commit plus canonical push boundary —
activate once with `git config core.hooksPath .githooks`), and the local CI gate
`tools/run_ci_local.sh` (E4 backstop, which runs the self-check first). Hosted GitHub
Actions is disabled (`docs/decisions/0004-hosted-ci-disabled-local-gate.md`), so the
local gate is the source of truth. The composed **Knowledge Map** retrieval layer **is
adopted** here (`knowledge-map/` bundle, derived `KNOWLEDGE_MAP.md`, fact cards in
`docs/knowledge/`); its gate (`knowledge-map/scripts/check_knowledge_map.sh` + the
regenerate-and-stage pre-commit step) runs in `.githooks/pre-commit` and `tools/run_ci_local.sh`.
