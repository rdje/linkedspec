# Documentation Layers

LinkedSpec has more than one documentation layer on purpose. Each layer serves a different audience and updates at a different pace.

## Public book

This book (`docs/linkedspec-book/`) is the public-facing explanation of LinkedSpec. It is built with mdBook and is meant to be read as a structured narrative.

It tells the outside world:

- what LinkedSpec is and what it's good at
- how to use it (the public API, DSL families, worked examples)
- how it works (compiler pipeline, state models, handler generation)
- why it is designed the way it is (design rationale, owner-oriented architecture)

The book changes more slowly than the repo-native docs. It should be stable enough that a reader returning after months can still trust its explanations.

## Repo-native working docs

The repository root also contains working documents that go deeper or move faster than the book:

- `USER_GUIDE.md` and `USER_GUIDE_*.md` — exhaustive ActionIR lowering references, including the Perl reference backend's emitted-code contracts
- `ARCHITECTURE_STATE.md` — the live architecture snapshot, updated when structural understanding changes
- `ROADMAP.md` and `ROADMAP_V2.md` — the project roadmap with phase tracking and exit criteria

These are often more current and more detailed than the book, but they assume more context. Use them when you need implementation-level depth or the latest status.

## Continuity docs

The repo also contains internal continuity docs:

- `CHANGES.md` — chronological technical history of every change
- `DEVELOPMENT_NOTES.md` — engineering rationale for architectural decisions
- `MEMORY.md` — compact session memory for interruption-safe continuation
- `COMMIT.md` — the commit workflow contract

These exist for crash recovery, session handoff, execution continuity, and implementation hygiene. They are internal engineering trail, not the public narrative.

## Reading order

If you are new to LinkedSpec:

1. Read this book's Overview and User Model sections first.
2. Read `USER_GUIDE.md` for the ActionIR lowering surface.
3. Read `ARCHITECTURE_STATE.md` when you need to understand module ownership and boundaries.
4. Read `ROADMAP_V2.md` when you need the current workstream status.

If you are contributing:

1. Read `COMMIT.md` for the commit workflow.
2. Read the Development section of this book for local CI and documentation conventions.
3. Read `docs/TASK_TREE.md` for the task-tree workflow.

## Why the distinction matters

If these layers get mixed together, the project becomes harder to understand at every level:

- the public story becomes noisy and implementation-fragmented
- the continuity trail becomes less useful operationally
- readers have to infer intent from internal engineering residue
- contributors can't find the right document for their task

The rule is simple: the book explains LinkedSpec to the world, the working docs support active development, and the continuity docs preserve execution trail inside the repo.
