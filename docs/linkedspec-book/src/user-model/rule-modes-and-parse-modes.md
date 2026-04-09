# Rule Modes and Parse Modes

LinkedSpec has more than one axis of behavior.

## Rule modes

Rule modes describe how a rule composes its internal structure.

Examples include the `AND` and `OR` families. These are about rule composition.

## Parse modes

Parse modes describe cursor discipline at runtime.

The current public model is:

- `seek`
- `consume`

These are about how matching progresses through input, not about how rule alternatives are composed.

## Why the distinction matters

Rule composition and cursor discipline are separate concerns.

That separation is important because it keeps the runtime model explainable:

- `AND`/`OR` tells you how the rule behaves structurally
- `seek`/`consume` tells you how the parser moves through input

This distinction is part of LinkedSpec’s effort to make behavior explicit rather than accidental.
