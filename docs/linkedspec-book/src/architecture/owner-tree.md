# Owner Tree and Module Boundaries

The current architecture is deliberately owner-oriented.

## High-level reading

`LinkedSpec.pm` is now a thin facade.

The practical core path is:

```text
ParserFactory -> Runtime -> Compiler
```

And the main implementation semantics live in focused owners such as:

- `Validation`
- `Resolver`
- `SpecEntry`
- `RuleIR`
- `RuleIR::EmitContext`
- `CompilerState`
- `RuntimeContext`

## Why this structure exists

The goal is to reduce monolithic behavior and make the system easier to reason about:

- narrower ownership boundaries
- clearer lazy-load behavior
- less duplicated wrapper logic
- more explicit state and validation seams

For the current deep implementation reading, the repo’s `ARCHITECTURE_STATE.md` remains the denser working companion to this chapter.
