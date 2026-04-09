# Documentation Workflow

LinkedSpec needs both public documentation and internal continuity documentation.

## Public book

This book is for:

- users
- adopters
- contributors
- evaluators
- future readers outside the immediate implementation loop

It should explain the project clearly and transparently.

## Internal continuity docs

The repo continuity docs are for:

- crash recovery
- session handoff
- implementation continuity
- commit hygiene

Examples:

- `CHANGES.md`
- `DEVELOPMENT_NOTES.md`
- `MEMORY.md`
- `COMMIT.md`

## Definition of done

If a slice changes what the outside world needs to understand about LinkedSpec, the book should move too.

If a slice changes implementation continuity, rationale, or crash-recovery knowledge, the continuity docs should move too.

Those two obligations overlap sometimes, but they are not the same obligation.
