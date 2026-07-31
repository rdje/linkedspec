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
   (index: `docs/TASK_TREE.md`); its frontier row is your precise next step.
5. Pull only the relevant **decision records** under `docs/decisions/` (index: `INDEX.md`).
6. **Before re-deriving any fact from code or runtime, check `KNOWLEDGE_MAP.md`** — grep your
   question, follow the one pointer to the canonical home, and trust the dated fact or run its
   `reverify` command. Re-deriving a fact that was already logged once is *archaeology*
   (`knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md`).
7. **When debugging, reach for LinkedSpec's own tools FIRST** — read `TOOLBOX.md` (the
   `LinkedSpec::Get`/`return_descriptor`/`call_spec_handler_subst`/`dump_parser_source` probes, the
   `LINKEDSPEC_TRACE_LEVEL` trace framework, the `tools/` scripts, the gates). Never eyeball a `.spec`
   or guess a root cause before the toolbox has shown the exact mechanism + source location.
8. **Doctrines are mechanically enforced** (`DOCTRINE_ENFORCEMENT.md`, the 4th portable architecture):
   every rule pairs with a `scripts/check_*.sh` run by the registry driver `scripts/check_doctrines.sh`
   via `.githooks/pre-commit` (E3) + `tools/run_ci_local.sh` (E4). Add a doctrine = a check + one
   registry line.

## Non-negotiable working rules

- **No change without an owning task-tree leaf first** (`docs/TASK_TREE_README.md`;
  doctrine: `docs/decisions/0001-task-tree-and-commit-doctrine.md`).
- **Keep `README.md` a bounded stable landing page** (`README_POLICY.md`, ADR `0063`). Route changing detail to
  its canonical owner; `scripts/check_readme_stability.sh` enforces both budgets and reviewed cap increases.
- **Route every durable thing to a layer and commit before the turn ends** — resume
  pointer (`MEMORY.md`, overwrite-only, capped) / task-trees (`docs/tasks/`) / decision
  records (`docs/decisions/`) / git history. Nothing important may live only in this
  conversation.
- **Commit per `COMMIT.md`** after every slice, with the **task-tree leaf id in the
  subject**; use `git_message_brief.txt` (untracked; cleared to 0 bytes after commit).
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
`scripts/check_memory_architecture.sh` (E2 invariants), `.githooks/` (E3 local gate —
activate once with `git config core.hooksPath .githooks`), and the local CI gate
`tools/run_ci_local.sh` (E4 backstop, which runs the self-check first). Hosted GitHub
Actions is disabled (`docs/decisions/0004-hosted-ci-disabled-local-gate.md`), so the
local gate is the source of truth. The composed **Knowledge Map** retrieval layer **is
adopted** here (`knowledge-map/` bundle, derived `KNOWLEDGE_MAP.md`, fact cards in
`docs/knowledge/`); its gate (`knowledge-map/scripts/check_knowledge_map.sh` + the
regenerate-and-stage pre-commit step) runs in `.githooks/pre-commit` and `tools/run_ci_local.sh`.
