# Descriptor Introspection

LinkedSpec can expose descriptor information in addition to a normal runnable parser.

The descriptor is a backend-neutral concept: it is the compiler's output described as data (rule table, dependency-regex map, metadata) instead of as a runnable parser. The field names and structure below (`spec`, `dependency_regex_map`, `meta`, `dependency_refs`, …) are part of that contract. The concrete *encoding* shown — a parser coderef, a `sub { ... }` handler value, a `qr/.../` compiled regex — is the **Perl reference backend's** representation; another backend encodes the same descriptor in its own language's types.

The active public option is:

```perl
return_descriptor => 1
```

Example:

```perl
my $descr = LinkedSpec::Get(
  \$spec,
  return_descriptor => 1,
);
```

The file-oriented path supports the same idea:

```perl
my $descr = LinkedSpec::get_parser(
  'Lispish',
  return_descriptor => 1,
);
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
- `functions`
- `dependency_regex_map`
- `meta`

That shape is an outward projection of richer internal compiler state models rather than the compiler’s preferred internal source of truth.

In rough form:

```perl
{
  spec => {
    Top => {
      handler => sub { ... },
      re => [ ... ],
      dependency_refs => [
        { label => 'Child', idx => 0 },
      ],
      meta => { ... },
    },
  },
  dependency_regex_map => {
    Top => qr/.../,
  },
  functions => {
    normalize => {
      index => 0,
      kind => 'user_function_definition',
      version => 1,
      name => 'normalize',
      params => ['value'],
      arity => 1,
      source_text => "fn normalize(value) {\n return(trim(value))\n}",
      source_span => { line_start => 1, line_end => 3, ... },
      body_span => { ... },
      body_source => "\n return(trim(value))\n",
      body_payload => {
        kind => 'staged_payload',
        node_kind => 'function_definition',
        payload_kind => 'function_body',
        parent_ast_path => ['functions', '0', 'body_source'],
        function_name => 'normalize',
        params => ['value'],
        arity => 1,
        text => "\n return(trim(value))\n",
        source_span => { start => 21, end => 43, line_start => 1, line_end => 3 },
        provenance => [
          { kind => 'source_slice', source_span => { ... } },
        ],
      },
      body_parse_job => {
        kind => 'parse_job',
        job_id => 'parse_job:function_body:functions.0.body_source:actionir-body.spec:action_block:21-43',
        parent_ast_path => ['functions', '0', 'body_source'],
        node_kind => 'function_definition',
        payload_kind => 'function_body',
        parser_spec_id => 'actionir-body.spec',
        top_rule => 'action_block',
        result_policy => 'replace_field',
        result_field => 'body_ast',
        failure_policy => 'fail',
        text => "\n return(trim(value))\n",
        source_span => { start => 21, end => 43, line_start => 1, line_end => 3 },
      },
      body_ast => { kind => 'action_block', ... },
    },
  },
  meta => {
    descriptor_model => 'compiled_descriptor_state',
    parse_mode => 'seek',
    definition_order => [ ... ],
    compiled_rule_order => [ ... ],
    redefined_rule_labels => [ ... ],
    function_order => [ 'normalize' ],
    function_count => 1,
  },
}
```

In the Perl reference backend, `handler` is a coderef (`sub { ... }`) and each `dependency_regex_map` value is a compiled regex (`qr/.../`). Those are encoding details: another backend represents the same `handler` and dependency-regex fields with its own callable and regex types. The field names and their meaning are the backend-neutral part.

## `spec`

`spec` is the outward rule table.

Each rule entry contains the generated handler plus the rule-level metadata needed by runtime dispatch and tooling.

The important active field for child/dependency mapping is:

```perl
dependency_refs
```

That list describes which other rule regexes this rule depends on when building combined dependency regex dispatch.

## `dependency_regex_map`

`dependency_regex_map` is the outward compiled dependency-regex table.

It is keyed by rule label. Rules that have no combined dependency regex may not appear in this map.

This name is intentionally explicit. It replaced older vague vocabulary because the value is not arbitrary “data”; it is a derived map of dependency regexes used by generated dispatch.

## `functions`

`functions` is the outward user-function registry.

As of `SPEC-FORMAT-TERSE.4.2.3`, the Perl reference accepts top-level definitions and
executes registered exact-arity calls in value positions and standalone discard statements:

```text
fn normalize(value) {
 return(trim(value))
}
```

Every variant records the definition by name with the same exact outer fields: `index`, `kind`, `version`, `name`,
`params`, `arity`, `source_text`, `source_span`, `body_span`, `body_source`, `body_payload`, `body_parse_job`, and
`body_ast`. `index` is zero-based source order; `kind` is `user_function_definition`; `version` is `1`.
`source_text` is the complete original definition while `body_source` is the exact text inside its braces. The
shared executable schema is `capability_conformance/outward_descriptor_contract.json`; focused Perl, Rust, Dart,
and Julia tests consume that file and reject missing or backend-specific extra fields.

The descriptor therefore includes ordered parameter names, exact arity, source/body spans, original body source,
a neutral staged `body_payload`, a neutral `body_parse_job`, and the
stitched ActionIR `action_block` body AST. The definition shell is parsed by
`specs/user_function_definition.spec`; active backends consume that returned AST rather than raw-scanning the
`fn` syntax. The `body_payload` is the implementation-language-neutral text island for staged dispatch:
it carries the exact body text, half-open source span, source-slice provenance, source-order parent path,
function name, params, arity, and `payload_kind = function_body`. The `body_parse_job` is the parse-intent
sidecar for the same text island: it records the deterministic job id, parent AST path, parser spec identity,
top rule, result/failure policies, exact text, and source span. Current shipped parsers dispatch this one job
through the minimal staged registry provider for `actionir-body.spec` / `action_block` and stitch the result into
`body_ast`; general public `parse_job(...)` authoring and provider search remain future work. The definition
parser uses linked body-island rules for nested braces, strings, comments, and regex literals, so normal
nested function-body constructs do not depend on a host-language scanner.

Julia exposes the same staged function-body shape through `execute_staged_parse_jobs(...)`,
`dispatch_function_body_parse_jobs(...)`, `stitch_function_body_parse_jobs(...)`, and
`parse_spec_with_staged_user_function_definition_asts(...)`. Its dispatch results include the stable queue index,
four registry phases, resolved built-in identity, cache key, compiled-parser record, source/job policies, and
neutral `action_block` result. The stitched `FunctionDefinition` retains the original `body_payload` and
`body_parse_job`; only `body_ast` is added on a new immutable `SpecFile` value.

Julia also has an executable descriptor-shape lock over two source-ordered definitions. The proof starts from the
neutral spec-returned `function_definition` nodes, dispatches and stitches their jobs, compiles that same spec, and
asserts the public `functions` records plus runtime output. It verifies:

- `body_payload` kind/name/params/text/span and source-slice provenance
- normalized `body_parse_job` id, zero-based parent path, parser/top rule, result/failure policies, and owner
- stitched ActionIR `body_ast`
- descriptor entry indices and `meta.function_order` / `meta.function_count`

No Julia-specific descriptor fields are introduced, and no separate serialization-only fixture is used.
Function definitions are validated before runtime: duplicate names, invalid or duplicate parameters, reserved
runtime/lifecycle/function symbols, built-in helper/control-name collisions including numeric word aliases, and
rule-label collisions are rejected.

The compiler also uses this registry while lowering rule actions. Calls such as
`return(normalize(" x "))` now resolve on the Perl reference when the callee is registered
and the arity matches. Wrong-arity registered calls still report unresolved-helper
metadata with zero raw fallback. A standalone `normalize(" x ")` lowers as a canonical
`VALUE_DROP`: the value is computed through the function resolver and then discarded.
The Rust backend has matching parsed/compiled registry support and runtime MVP execution:
registered calls resolve before helper fallback, run in fresh function-local stores, feed
compatible receiver chains, and discard standalone results.
The Dart backend now preserves the same neutral staged fields through parsed
`SpecFile.functions`, compiled `UserFunctionRegistry` entries, public descriptor
projection, and runtime execution: focused descriptor tests assert `body_payload`,
normalized `body_parse_job`, stitched `body_ast`, `function_order`, and stable
runtime output from registered calls.

The `functions` registry is a flat MVP registry keyed by function name. It does not yet
model namespaces/modules, overload sets, optional-argument variants, closures, lambdas, or
curried/partial applications; those are deferred language-extension topics rather than
descriptor fields a tool should expect today.

### Variadic descriptor version (Perl and Rust implemented)

ADR 0030 adopts a versioned union instead of changing the meaning of the current `arity` field. Fixed definitions
remain version 1 with the exact fields documented above. A variadic definition is version 2 and
replaces top-level `params`/`arity` with:

```json
"signature": {
  "kind": "callable_signature",
  "version": 1,
  "positional_params": ["prefix"],
  "rest_param": "items",
  "min_arity": 1,
  "max_arity": null
}
```

The same `signature` is preserved in the staged body payload and parse job. `max_arity: null` means purposefully
unbounded; it does not mean unknown. Extras bind as one fresh typed array. Function names remain unique and calls
remain positional-only, so tools must not infer overloads, defaults, keyword mapping, or host-language splats.
`capability_conformance/callable_signature_contract.json` is the schema. Perl and Rust currently expose this v1/v2
union and its staged records exactly. Rust's typed `CallableSignature` also survives compiled-state serialization,
source emission, and generated-plan execution. The existing exact `outward_descriptor_contract.json` remains the
four-backend fixed-function v1 admission while Dart/Julia variadic projection is still rolling out; consumers must
branch on function-record `version`, never on field presence alone.

## `meta`

`meta` carries descriptor-level metadata.

Important current fields include:

- `descriptor_model`
- `parse_mode`
- `definition_order`
- `compiled_rule_order`
- `redefined_rule_labels`
- `function_order`
- `function_count`

These fields help tooling understand the descriptor without relying on historical implementation guesses.

## Internal state versus outward descriptor

Internally, the compiler prefers explicit state models:

- `compiled_spec_state`
- `compiled_dependency_regex_state`
- `compiled_descriptor_state`

The outward descriptor is a projection of those models for public/tooling consumption.

That distinction is important. The public descriptor is useful, but it is not the same thing as saying the compiler should reason from loose historical parallel hashes internally.

## Rust in-memory descriptor API

Rust projects the same public concept without depending on its runtime engine:

```rust
use linkedspec_core::compiler::compile;
use linkedspec_core::parser::parse_spec;

let spec = parse_spec("Top::\n -> Child\n\nChild:\n /x/\n")?;
let compiled = compile(&spec)?;

let descriptor = compiled.descriptor_state();
assert_eq!(descriptor.meta.descriptor_model, "compiled_descriptor_state");
assert_eq!(descriptor.meta.compiled_rule_order, ["Top", "Child"]);
assert_eq!(descriptor.spec["Top"].dependency_refs[0].label, "Child");

let json = compiled.to_descriptor_json()?;
assert!(json.get("functions").is_some());
# Ok::<(), Box<dyn std::error::Error>>(())
```

`descriptor_state()` returns typed serializable records from `linkedspec_core::descriptor`.
`to_descriptor_json()` returns their JSON representation. Both are projections over `CompiledSpec`; neither
launches a subprocess or requires `linkedspec-runtime`. Ordered `dependency_refs`, function order, staged
`body_payload` / `body_parse_job` / `body_ast`, definition order, last-definition compile order, and model
identities survive compiled-state serialization round trips.

All four implemented variants expose the exact top-level projection, composing/nested model identities, and
canonical outer function records. Rust's typed/API implementation landed under `.1.6.2.2`; the shared executable
contract and final four-backend admission closed under `.1.6.2.3`.
