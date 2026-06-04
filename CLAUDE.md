# Claude Code bootstrap

Follow **`AGENTS.md`** (the tool-neutral agent bootstrap). Start by reading **`README.md`**
and **`MEMORY_ARCHITECTURE.md`**, then resume from **`MEMORY.md`** (the bounded layer-A
resume pointer) and the active task-tree under `docs/tasks/`.

Non-negotiable: no change without an owning task-tree leaf first (`docs/tasks/`; doctrine in
`docs/decisions/0001-task-tree-and-commit-doctrine.md`); route every durable thing to a memory
layer and commit per `COMMIT.md` with the task-tree leaf id in the subject; run
`scripts/check_memory_architecture.sh` before committing (git hooks + the local CI gate
`tools/run_ci_local.sh` enforce it).

Before re-deriving any fact from code/runtime, check **`KNOWLEDGE_MAP.md`** (grep your
question → follow the one pointer → trust the dated fact or run its `reverify`). Write a
`docs/knowledge/<id>.md` card when you establish a durable fact or catch archaeology
(`knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md`); the map is derived + gated — never hand-edit it.
