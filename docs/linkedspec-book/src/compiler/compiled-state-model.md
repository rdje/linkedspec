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

The Rust backend now carries the same registry shape after executing the spec-defined definition parser.
`linkedspec-runtime::spec_parser` runs `specs/user_function_definition.spec`, validates returned AST nodes, strips
definition spans, and then feeds rule-only source to the core parser. `SpecFile.functions` records those
spec-returned definitions, and `CompiledSpec.functions` stores `CompiledUserFunction` entries with parsed
`CodeBlock` bodies, source metadata, the neutral `body_payload`, the neutral `body_parse_job` sidecar, and the
stitched `body_ast` returned by the minimal staged registry dispatch. The current dispatch path resolves
`actionir-body.spec` through a built-in registry provider for top rule `action_block`; function execution still
runs through the compiled ActionIR body. The Rust runtime resolves those compiled functions before ordinary helper fallback,
executes them in fresh function-local variable stores, restores caller stores after return, and supports
compatible receiver chains and standalone discard.

Rust also projects its compiled state outward through `CompiledSpec::descriptor_state()` and
`CompiledSpec::to_descriptor_json()`. The typed records live in `linkedspec_core::descriptor`, preserve ordered
rule dependencies and staged function metadata, derive deterministic definition/compile/redefinition order, and
remain independent of the runtime engine. `CompiledRule.dependency_refs` preserves source order explicitly;
deserialized older compiled state can still derive the same public refs from dispatch entries.

The Dart backend now has the same compiled-state boundary. `compileSpec(...)` in
`dart/lib/src/compiler/compiled_spec.dart` validates parsed `SpecFile` input by default, builds ordered
`CompiledSpec` / `CompiledRule` records, carries the `UserFunctionRegistry`, records mode metadata, regexes,
dependency refs, action/blind edges, and lifecycle/plain/edge `ActionBlock` payloads, derives structured
`CompiledDependencyRegexState`, and projects `CompiledDescriptorState` as `spec`, `functions`,
`dependency_regex_map`, and `meta`. Dart's staged registry can now dispatch preserved function-body
`body_parse_job` records through the built-in `actionir-body.spec` / `action_block` provider and stitch the
returned `action_block` JSON into `body_ast` before compile state is built. Dart stores dependency regexes as
structured refs plus pattern strings until the runtime interpreter consumes them for executable match dispatch.
`LinkedSpecRuntimeEngine` now uses this state for rule-family dispatch, action-edge and blind-call child execution,
lifecycle blocks, `retv`, accumulator collection, bounded repetition, zero-progress cutoffs, and recursion
cutoffs. It also resolves registered exact-arity user-function calls before ordinary helper fallback, evaluates
arguments eagerly in the caller, binds params into fresh function-local scalar/array/hash stores, executes the
function body as an ActionIR value block, returns the final expression or local `return(...)` payload, feeds
returned values into compatible receiver chains, discards standalone call results, and diagnoses direct or mutual
recursion.

Dart's private inter-match-gap metadata extends that internal rule state and projects separate compatible
descriptor metadata without widening existing fields.
Each authored regex has a `regex_slots` row containing `regex_index`, nullable `slot_id`, logical `source_id`, and
physical `line`; an authored directive has one nullable `capture_gaps` record. Action edges retain selector kind,
authored selector, target rule, resolved child index, nullable target slot id, and source provenance. Legacy
`dependency_refs` stay `{label,idx}`, existing descriptor `resolved_edges` stay unchanged, and generated plan v2
stays `{label,family}`. Rule metadata separately exposes detached `regex_slots`, `capture_gaps`, and five-field
`resolved_slot_edges` values.

Native execution now consumes that private directive metadata without adding another compiled carrier. The
existing recognition invocation owns capture activation and detached child entry identity; its checkpoint adds
only committed gap cursor, accepted-edge count, and current candidate/tail. The observable recognition frame
remains cursor/boundary/marks. Ordinary normalized JSON reconstruction now preserves and executes that same state,
and both direct and traced generated-plan routes use the same engine lifecycle and typed failures.
Independently emitted Dart libraries embed that normalized state unchanged. One managed offline caller package
now strictly analyzes and executes ten value modules plus two typed-error modules through paired direct/traced
entrypoints. Exact Unicode/empty gaps, falsey results, lifecycle order, child cursors, entry identity, nesting,
rollback, terminal tails, failed minimums, direct entry, legacy behavior, and typed errors agree with native
compiled state. The production emitter and the v2 `{label,family}` plan are unchanged.
The admitted final consumer composes native, reconstructed, descriptor, generated-plan, emitted-source,
lifecycle, recursion/rollback, diagnostic, and existing-primary roles exactly once; this composition adds no
compiled field or second state authority.

Julia's private inter-match-gap metadata now adds the same authored identities to its compiled state without
widening the descriptor. `SpecFile.source_id` is a logical caller identity, defaulted to `inline` for legacy
constructors and JSON. Each compiled regex has an ordered `regex_slots` row with `regex_index`, nullable
`slot_id`, logical `source_id`, and physical `line`; an authored `@capture_gaps` has one nullable directive
record. Compiled action edges retain unindexed/numeric/named authorship, resolved target rule/index/slot identity,
and source provenance. Legacy descriptor action edges, `resolved_edges`, and `{label,idx}` dependency references
remain unchanged; detached descriptor projections stay owned by `.5.3`.

Shared PUC Lua/LuaJIT compiled state now carries the same authored layer. `SpecFile.source_id` defaults to
`inline`, survives both staged parser layers and normalized JSON, and uses path-opaque caller identity for loaded
specs. Each rule owns ordered `regex_slots` rows and a nullable `capture_gaps` record; compiled action-edge JSON
adds `selector_kind`, `authored_selector`, `target_rule`, resolved `child_regex_index`, and nullable
`target_slot_id`. Descriptor rule metadata now adds fresh detached `regex_slots`, nullable `capture_gaps`, and
five-field `resolved_slot_edges` values while deliberately retaining the legacy action-edge shape and unchanged
`resolved_edges`/`{label,idx}` references. Loaded projections keep their caller-logical source id, inline
projections use `inline`, and neither detached result can mutate compiled state. Emitted source embeds the
normalized source id without changing format 2 or its `{label,family}` plan.

Native Lua execution now consumes that metadata through the existing recognition invocation/checkpoint authority.
Capture activation, committed gap cursor, accepted count, phase, candidate/tail, and detached child entry identity
live on that invocation; the detached transaction state remains exactly cursor/boundary/marks. Capture-enabled
rules alone preselect before `LS`, commit child-extended state before `IT`, and install successful tails before
`LX`/`EX`/`E`. The four zero-argument helpers resolve privately without entering the 246-name supported ActionIR
inventory. Normalized `SpecFile` JSON is the sole reconstruction carrier, and direct/traced generated-v2
entrypoints execute the same engine lifecycle and typed failures. Independently emitted modules now reconstruct
that same state in fresh PUC-Lua and LuaJIT children without changing the emitter, compiled shape, or plan.

The Julia backend now implements the same narrow staged provider before compiled state is built. Its public path is:

```julia
spec = parse_spec_with_user_function_definition_asts(source, definition_nodes)
dispatch = dispatch_function_body_parse_jobs(spec)
stitched = dispatch.spec
```

`execute_staged_parse_jobs(...)` orders jobs by parent AST path, source span, then job id; resolves
`actionir-body.spec` to `builtin:actionir-body.spec`; records the fixed adapter digest and portable cache/compiled
metadata; and parses each exact body through `parse_action_block(...)`. `dispatch_function_body_parse_jobs(...)`
validates the function/job sidecar contract and returns a new `SpecFile` whose matching definitions carry neutral
JSON `action_block` values in `body_ast`. The original spec and its `body_parse_job` records remain unchanged.
`parse_spec_with_staged_user_function_definition_asts(...)` is the composed projection-plus-dispatch convenience
API. General provider search and recursive staged queues remain future work.

Julia's runtime now consumes the same compiled registry. Registered calls resolve before ordinary helper fallback;
arguments evaluate eagerly in caller scope; params bind into fresh scalar, array, and hash stores; and the body runs
as a cached ActionIR value block. The returned value is the final expression or first local `return(...)` payload.
Caller stores restore after every call, so function work variables do not capture or overwrite caller locals.
Returned values can continue through compatible receiver chains, while a standalone call executes and drops its
result. Direct or mutual recursion is rejected with a structured `user_function_call` diagnostic.

```text
fn normalize(value) {
  trim(value)
}

Top::
 /x/
 E {
   normalized = normalize(" A-B ").lowercase().replace_substr("-", "_")
   normalize(" discarded ")
   return(normalized)
 }
```

Here the first call yields `"a_b"`; the second call still executes, but its value is discarded. Newlines separate
the statements, so no line-ending semicolons are used.

This registry is intentionally flat for the MVP. It is not an overload table, namespace/module model, closure
environment, lambda catalog, or currying/partial-application representation. Those extensions require their own
future contract before the internal state model grows fields for them.

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
