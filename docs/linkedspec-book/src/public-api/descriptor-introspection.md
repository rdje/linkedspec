# Descriptor Introspection

LinkedSpec can expose descriptor information in addition to normal parser coderefs.

The active public option is:

```perl
return_descriptor => 1
```

## Why it matters

Descriptor introspection is useful for:

- tooling
- debugging
- migration work
- understanding compiler output without invoking the parser normally

## Current shape

The active outward descriptor now includes:

- `spec`
- `dependency_regex_map`
- `meta`

That shape is an outward projection of richer internal compiler state models rather than the compiler’s preferred internal source of truth.
