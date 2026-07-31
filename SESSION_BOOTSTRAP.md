# Session Bootstrap

Read `README.md`, then read and thoroughly understand:

- `MEMORY_ARCHITECTURE.md` — the durable, harness-agnostic memory system (mandatory; mechanically enforced). It defines the four memory layers and the write/read paths; derive current `HEAD` from Git, then resume from `MEMORY.md` (the bounded layer-A pointer whose `activation_commit` names the clean leaf base).
- `COMMIT.md` — commit workflow and hygiene conventions.
- `ROADMAP_V2.md` — current active lanes and tracker status.
- `docs/TASK_TREE.md` — active task trees, current frontier, and PNT selection rules.
- Active task files listed in `docs/TASK_TREE.md` — the detailed task breakdown and current executable leaf.
- Relevant records under `docs/decisions/` — durable cross-cutting facts/decisions (memory layer C).

Before editing root `README.md`, read `README_POLICY.md`; changing detail routes to its canonical owner and the
registered `README-STABILITY` doctrine enforces the reviewed line/byte budgets and cap-increase decision rule.

After reading the above, thoroughly, meticulously and precisely analyze `LinkedSpec.pm` and its import tree.

When done, update `ARCHITECTURE_STATE.md` if deemed necessary, then help me fulfil all the objectives as captured in the roadmap. When PNT is requested, select the first eligible leaf from the active task tree's current frontier.
