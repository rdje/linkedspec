# Documentation Layers

LinkedSpec has more than one documentation layer on purpose.

## Public book

This book is the public-facing explanation of LinkedSpec.

It should tell the outside world:

- what LinkedSpec is
- how to use it
- how it works
- and why it is designed the way it is

## Repo-native working docs

The repository also contains working documents such as:

- `USER_GUIDE.md`
- `ARCHITECTURE_STATE.md`
- `ROADMAP.md`

These are useful, live repo documents and often go deeper or move faster than the book. They are still important, but they are not the same thing as the public book.

## Continuity docs

The repo also contains internal continuity docs such as:

- `CHANGES.md`
- `DEVELOPMENT_NOTES.md`
- `MEMORY.md`
- `COMMIT.md`

These exist for:

- crash recovery
- session handoff
- execution continuity
- implementation hygiene

They are not the public narrative of the project.

## Why the distinction matters

If these layers get mixed together, the project becomes harder to understand:

- the public story becomes noisy and implementation-fragmented
- the continuity trail becomes less useful operationally
- and readers have to infer intent from internal engineering residue

So the rule is simple:

- the book explains LinkedSpec to the world
- the continuity docs preserve execution continuity inside the repo
