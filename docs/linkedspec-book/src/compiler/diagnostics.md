# Diagnostics

Diagnostics are a first-class part of LinkedSpec’s architecture, not just an afterthought.

## What the project is aiming for

- deterministic validation failures
- structured runtime and compiler context
- clear ownership and stage attribution
- preserved rule labels and handler identity when known

## Why that matters

If a dynamic parser system cannot explain its failures clearly, it becomes expensive to use and hard to trust.

That is why recent work has focused so much on:

- `runtime_ctx->{last_error}`
- owner/stage naming
- compile-time attribution
- parser-factory continuity
- handler-source labels

These are part of the product quality story, not just developer convenience.
