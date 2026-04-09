# Compiled State Model

The compiler is moving toward explicit state models rather than loose historical parallel hashes.

## Current active internal models

The active architecture now talks in terms of:

- `compiled_spec_state`
- `compiled_dependency_regex_state`
- `compiled_descriptor_state`

## Why this is better

Explicit state models make it easier to:

- validate shape deliberately
- keep naming honest
- separate internal truth from outward compatibility projection
- evolve the compiler without losing clarity

## Outward compatibility versus internal truth

The outward descriptor still exists because it is useful and stable for users/tools, but the compiler should reason from the internal state models first, then project outward as needed.
