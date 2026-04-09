# Action Model and Helper Surface

LinkedSpec is in the middle of a long-term shift from older raw-Perl-shaped action habits toward a cleaner helper-driven DSL and canonical ActionIR lowering.

## The direction

The direction is:

- less raw embedded Perl
- more explicit helper contracts
- clearer lowering semantics
- better backend portability

## Why this matters

The action surface is where a lot of parser power lives, but it is also where accidental complexity can creep in fast.

Treating the helper DSL as a real language surface, with explicit semantics and documentation, makes LinkedSpec easier to trust and easier to evolve.

## What to pair with this chapter

The repo’s ActionIR-focused guides remain the deeper working references while this book grows:

- `USER_GUIDE_ActionIR_Contracts.md`
- `USER_GUIDE_ActionIR_MethodLowering.md`
- `USER_GUIDE_ActionIR_EmittedPerlReference.md`

The long-term goal is for this book to absorb that surface in progressively clearer public-facing chapters.
