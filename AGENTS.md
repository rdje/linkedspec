# Agent bootstrap — read this first, whatever AI or harness you are

This file is the tool-neutral entrypoint (the common `AGENTS.md` convention). Other
harnesses' bootstrap files (`CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`)
point back here. The system of record is **`README.md`** (the project) +
**`MEMORY_ARCHITECTURE.md`** (how memory + continuity work).

## On every session start / resume

1. Read **`README.md`** — project objective, layout, standard commands.
2. Read **`MEMORY_ARCHITECTURE.md`** — the durable memory system (MANDATORY; it is
   mechanically enforced — see Enforcement below).
3. Resume from **`MEMORY.md`** — the bounded layer-A resume pointer: latest commit, the
   active task-tree frontier leaf, the single next action, any in-flight uncommitted work.
4. Read **`SESSION_BOOTSTRAP.md`** and open the active **task-tree** under `docs/tasks/`
   (index: `docs/TASK_TREE.md`); its frontier row is your precise next step.
5. Pull only the relevant **decision records** under `docs/decisions/` (index: `INDEX.md`).

## Non-negotiable working rules

- **No change without an owning task-tree leaf first** (`docs/TASK_TREE_README.md`;
  doctrine: `docs/decisions/0001-task-tree-and-commit-doctrine.md`).
- **Route every durable thing to a layer and commit before the turn ends** — resume
  pointer (`MEMORY.md`, overwrite-only, capped) / task-trees (`docs/tasks/`) / decision
  records (`docs/decisions/`) / git history. Nothing important may live only in this
  conversation.
- **Commit per `COMMIT.md`** after every slice, with the **task-tree leaf id in the
  subject**; use `git_message_brief.txt` (untracked; cleared to 0 bytes after commit).
- **Before committing, run `scripts/check_memory_architecture.sh`** — git hooks and the
  local CI gate (`tools/run_ci_local.sh`) run it too; a non-compliant change fails and
  cannot land.

## Enforcement (why this is hard to ignore)

`MEMORY_ARCHITECTURE.md` §9 wires four gates: these bootstrap pointers (E1 discovery),
`scripts/check_memory_architecture.sh` (E2 invariants), `.githooks/` (E3 local gate —
activate once with `git config core.hooksPath .githooks`), and the local CI gate
`tools/run_ci_local.sh` (E4 backstop, which runs the self-check first). Hosted GitHub
Actions is disabled (`docs/decisions/0004-hosted-ci-disabled-local-gate.md`), so the
local gate is the source of truth. The optional composed "Knowledge Map" retrieval layer
is **not adopted** in this repo (see `MEMORY_ARCHITECTURE.md` §5).
