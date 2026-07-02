# Compiled State Model

The compiler is moving toward explicit state models rather than loose historical parallel hashes.

The state records and field names in this chapter — `compiled_spec_state`, `compiled_dependency_regex_state`, `compiled_descriptor_state`, and fields like `definition_order`, `compiled_rule_order`, `rules_by_label`, `redefined_rule_labels`, and `dependency_refs` — are a **backend-neutral** description of the compiler's internal model. The example shapes below use Perl encodings (`sub { ... }` for a compiled handler value, `qr/.../` for a compiled regex); those encodings are the **Perl reference backend's** representation, and another backend holds the same model in its own language's types.

## Current active internal models

The active architecture now talks in terms of:

- `compiled_spec_state`
- `compiled_dependency_regex_state`
- `compiled_descriptor_state`

In broad terms:

```text
compiled_spec_state
  owns the compiled rules and user-function registry

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
- `function_order`
- `functions_by_name`

The distinction between definition order and compiled rule order matters:

- `definition_order` tracks source definitions, including repeated/redefined labels.
- `compiled_rule_order` is the deterministic unique compiled-rule sequence.
- `redefined_rule_labels` records labels whose later definitions replaced earlier ones.

That makes the “last definition wins” reality visible instead of hiding it inside a loose hash overwrite.

It also carries the user-function registry introduced by `SPEC-FORMAT-TERSE.4.2.1`:

- `function_order` preserves top-level `fn` definition order.
- `functions_by_name` maps each function name to its validated definition record.

Each function definition records its name, ordered parameter list, exact arity, source/body spans, original body
source, and parsed ActionIR body AST. The Perl reference now also passes this registry into rule ActionIR
lowering, where registered exact-arity calls execute as value-producing expressions or standalone `VALUE_DROP`
statements. Wrong-arity calls remain unresolved-helper diagnostics with zero raw fallback.

The Rust backend now carries the same registry shape through parse and compile stages. `SpecFile.functions`
records top-level definitions, and `CompiledSpec.functions` stores `CompiledUserFunction` entries with parsed
`CodeBlock` bodies and the same source metadata. The Rust runtime resolves those compiled functions before
ordinary helper fallback, executes them in fresh function-local variable stores, restores caller stores after
return, and supports compatible receiver chains and standalone discard.

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
  functions => { ... },
  dependency_regex_map => { ... },
  meta => { ... },
}
```

That is the shape users and tools should inspect.

The internal compiler should still prefer the explicit state records while building and validating that shape.
