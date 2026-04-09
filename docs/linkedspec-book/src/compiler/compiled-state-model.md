# Compiled State Model

The compiler is moving toward explicit state models rather than loose historical parallel hashes.

## Current active internal models

The active architecture now talks in terms of:

- `compiled_spec_state`
- `compiled_dependency_regex_state`
- `compiled_descriptor_state`

In broad terms:

```text
compiled_spec_state
  owns the compiled rules

compiled_dependency_regex_state
  owns derived dependency-regex dispatch data

compiled_descriptor_state
  composes both before outward descriptor projection
```

## Why this is better

Explicit state models make it easier to:

- validate shape deliberately
- keep naming honest
- separate internal truth from outward compatibility projection
- evolve the compiler without losing clarity

## Outward compatibility versus internal truth

The outward descriptor still exists because it is useful and stable for users/tools, but the compiler should reason from the internal state models first, then project outward as needed.

## `compiled_spec_state`

`compiled_spec_state` is the compiled rule-table model.

It contains the information the compiler needs to reason about rules:

- `definition_order`
- `compiled_rule_order`
- `rules_by_label`
- `redefined_rule_labels`

The distinction between definition order and compiled rule order matters:

- `definition_order` tracks source definitions, including repeated/redefined labels.
- `compiled_rule_order` is the deterministic unique compiled-rule sequence.
- `redefined_rule_labels` records labels whose later definitions replaced earlier ones.

That makes the “last definition wins” reality visible instead of hiding it inside a loose hash overwrite.

## Per-rule compiled info

Each compiled rule entry can carry fields such as:

- generated handler
- regex list
- dependency refs
- rule metadata

The active name for rule-local dependency references is:

```text
dependency_refs
```

Example shape:

```perl
{
  re => [ ... ],
  handler => sub { ... },
  dependency_refs => [
    { label => 'Child', idx => 0 },
  ],
  meta => { ... },
}
```

`dependency_refs` is deliberately explicit. It is a list of references to dependency regexes, not arbitrary data.

## `compiled_dependency_regex_state`

This state contains derived regex dispatch data.

Its active outward projection is:

```text
dependency_regex_map
```

Example shape:

```perl
{
  Top => qr/.../,
}
```

Rules with no compiled dependency regex may be absent from the map.

## `compiled_descriptor_state`

`compiled_descriptor_state` composes:

- `compiled_spec_state`
- `compiled_dependency_regex_state`

This state exists so the compiler can validate generated descriptor consistency before projecting public data.

The important design rule is:

```text
validate internal descriptor state first,
then project outward descriptor data
```

That keeps the compiler from treating compatibility-shaped output as the internal source of truth.

## Public projection

When a caller asks for descriptor introspection, the public outward descriptor shape is:

```perl
{
  spec => { ... },
  dependency_regex_map => { ... },
  meta => { ... },
}
```

That is the shape users and tools should inspect.

The internal compiler should still prefer the explicit state records while building and validating that shape.
