# Descriptor Introspection

> **Rule-local descriptor v1:** ADR `0044` removes descriptor-wide
> `meta.parse_mode` and every public rule field named `parse_mode`. Perl
> `.9.1.3.3`, Rust `.9.1.4.4`, Dart `.9.1.5.3`, Julia `.9.1.6.3`, and Lua
> `.9.1.7.3` on both PUC Lua and LuaJIT expose
> `meta.cursor_contract = "linkedspec-rule-local-cursor-v1"`,
> derived per-rule `family` / `cursor_policy` / `edge_ownership`, and normalized
> `resolved_edges`. Perl, Rust, Dart, Julia, and dual-ABI Lua generated-source v2, option/CLI removal, and composed
> cursor admission are complete through `.9.1.7.6`; recurring five-backend admission `.9.1.8` now composes all
> six runtime legs and selected 5x2x5 primary proof. Duplicate regex-slot descriptor identity uses
> `linkedspec-duplicate-regex-slot-identity-v1` and has admitted Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT;
> recurring/public no-drift is closed. Independently, root-selection parity is closed
> at 7 complete / 0 pending. Its recurring
> contract composes every immutable root-selection descriptor identity; Julia root admission composes the
> root-selection descriptor identity through its exact 15-role consumer; the descriptor contains no cursor-owned
> legacy field.
>
> Lua/LuaJIT descriptor `.9.1.7.3` now projects cursor v1 directly from normalized compiled rules. Direct,
> normalized, and loaded descriptor bytes agree, including handler/root-marker identity and exact action/blind
> semantic rows. Global engine/parse/loader/corpus/generated overrides are removed as of `.9.1.7.5`.
> Generated source is v2/format 2 and derives policy from family without copying cursor state into this descriptor
> or its minimal generated plan. One exact 15-role consumer now admits this descriptor projection together with
> every other Lua cursor role on both ABIs.
>
> **Repeated-action descriptor parity:** `linkedspec-explicit-repetition-action-result-v1` has admitted Perl,
> Rust, Dart, Julia, PUC Lua, and LuaJIT. Bare `OR` descriptors report minimum-one repetition and generated
> `rep_acode`/`rep_bcode`, while pipe reports non-repetition. The outward descriptor shape stays versioned and
> unchanged; public no-drift closes at 8 complete / 0 pending.

LinkedSpec can expose descriptor information in addition to a normal runnable parser.

The descriptor is a backend-neutral concept: it is the compiler's output described as data (rule table, dependency-regex map, metadata) instead of as a runnable parser. The field names and structure below (`spec`, `dependency_regex_map`, `meta`, `dependency_refs`, …) are part of that contract. The concrete *encoding* shown — a parser coderef, a `sub { ... }` handler value, a `qr/.../` compiled regex — is the **Perl reference backend's** representation; another backend encodes the same descriptor in its own language's types.

The active public option is:

```perl
return_descriptor => 1
```

## The executable neutral semantic contract is separate

The descriptor is reusable semantic input, not the future semantic-query wire format. This distinction is
observable in the Perl reference: handler and dependency-regex entries are native coderef and compiled-regex
objects, so direct portable JSON encoding is neither supported nor meaningful. Rust, Dart, Julia, and Lua expose
the same descriptor meanings through their own typed projections.

ADRs `0049` and `0050` define a separate immutable `linkedspec-semantic-model-v1` with
`linkedspec-semantic-query-v1`. It normalizes rules, regex slots, edges, lifecycle actions, functions/helpers,
calls/bindings, inferred value and target shapes, staged/generated provenance, portable diagnostics, and ordered
explanation evidence. Ids and traversal are deterministic within a snapshot; pages and logical traversal cost are
bounded; source detail is ceiling-controlled as `none`, `identity`, `span`, or `text`, with explicit redactions.
Optional runtime answers use a caller-captured observation and never cause a query to execute the parser.

Each backend will expose idiomatic native construction/capabilities/query APIs plus the same neutral JSON
projection. MCP will only forward capabilities and query requests for a caller-registered handle. It will not
compile a spec, read an implicit path, inspect backend objects, derive facts, or invent explanations. The primary
CLI gains no v1 command or option.

The neutral schema, fixtures, exact evaluator, and 65-mutation gate are executable under
`FUTURE-PARITY-BACKLOG.10.2`. Perl is the first admitted backend. Rust now retains private source/outcome and exact
static-projection layers but exposes no public semantic query yet. `.10.3-.10.10` own Perl/Rust/Dart/Julia/Lua
rollout, recurring proof, thin MCP transport, and public closeout. Until a backend's native semantic adapter is
admitted, continue using the descriptor API documented below. [Semantic Introspection](semantic-introspection.md)
documents the exact neutral model and current rollout.

For orientation, the executable neutral contract represents “describe `Top`, with spans but no source text” as:

```json
{
  "contract": "linkedspec-semantic-query-v1",
  "operation": "get",
  "subjects": ["rule:Top"],
  "record_kinds": [],
  "relation_kinds": [],
  "direction": "outgoing",
  "page": {"after_id": null, "limit": 100},
  "budget": {"max_records": 1000, "max_relations": 2000, "max_depth": 4},
  "source": {"detail": "span", "include_content_digest": false}
}
```

The future native response and MCP response must be identical after canonical JSON encoding. A request for
`text` against an index whose ceiling is `span` is rejected; MCP cannot raise that ceiling. This example is a
contract example, not an available backend call.

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
      meta => {
        is_top => 1,
        family => 'and',
        cursor_policy => 'consume',
        edge_ownership => 'blind',
        resolved_edges => [
          {
            ownership => 'blind',
            target => 'Child',
            regex_index => undef,
            block => 0,
            fluent => undef,
            source_form => 'bare',
          },
        ],
        ...
      },
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
    cursor_contract => 'linkedspec-rule-local-cursor-v1',
    regex_slot_identity_contract => 'linkedspec-duplicate-regex-slot-identity-v1',
    entry_rule_contract => 'linkedspec-root-rule-selection-v1',
    definition_order => [ ... ],
    compiled_rule_order => [ ... ],
    redefined_rule_labels => [ ... ],
    function_order => [ 'normalize' ],
    function_count => 1,
  },
}
```

### Root-selection identity

The Perl reference, Rust, and Dart descriptors publish
`meta.entry_rule_contract = "linkedspec-root-rule-selection-v1"`, exact
`meta.definition_order`, and per-rule `spec.<label>.meta.is_top` authored identity
(normalized `0`/`1` on Perl and a boolean on Rust/Dart). `is_top` records whether the
source used `Rule::`; it is not the current invocation choice.

For example, given `Earlier:` followed by `Marked::`, a descriptor requested
with `top_rule => 'Earlier'` still reports `Earlier.is_top = 0` and
`Marked.is_top = 1`. The explicit selector controls execution and wins over the
marker, but it does not rewrite authored source identity. With no explicit
selector, the first marked rule wins; with no marker, the first rule in
`definition_order` wins.

Rust direct, loaded, ordinary `CompiledSpec` JSON-reconstructed, generated-plan, and emitted-source execution all
reuse that identity. A generated invocation selector lives only in `ExecutionOptions`; neither descriptor JSON nor
the generated `{label, family}` plan gains `entry_rule` or `selected_entry_rule`. Projecting a descriptor before
and after explicit generated or native execution therefore produces the same definition order and authored bits.

In the Perl reference backend, `handler` is a coderef (`sub { ... }`) and each `dependency_regex_map` value is a compiled regex (`qr/.../`). Those are encoding details: another backend represents the same `handler` and dependency-regex fields with its own callable and regex types. The field names and their meaning are the backend-neutral part.

### Dart projection example

Dart projects the same semantic descriptor as JSON-compatible maps without
creating a second descriptor-owned runtime state:

```dart
final compiled = compileSpec(parseSpec(r'''
Top::AND
 Child.return(child_result)
Child:
 /x/
'''));

final descriptor = compiled.toDescriptorJson();
```

The relevant result is:

```json
{
  "meta": {
    "cursor_contract": "linkedspec-rule-local-cursor-v1",
    "regex_slot_identity_contract": "linkedspec-duplicate-regex-slot-identity-v1"
  },
  "spec": {
    "Top": {
      "meta": {
        "label": "Top",
        "line": 1,
        "is_top": true,
        "family": "and",
        "cursor_policy": "consume",
        "edge_ownership": "blind",
        "resolved_edges": [
          {
            "ownership": "blind",
            "target": "Child",
            "regex_index": null,
            "block": false,
            "fluent": "return(child_result)"
          }
        ]
      }
    }
  }
}
```

The full root `meta` object also retains the model identities, deterministic rule/function order, redefinition
labels, and function count shown earlier. Dart has no descriptor-input decoder. To reconstruct, serialize the
normalized `SpecFile`, call `SpecFile.fromJson(...)`, compile normally, and project again; direct, reconstructed,
and file-loaded descriptor values are identical. Invalid reconstructed AST state fails validation with the same
portable diagnostic. Duplicate action patterns remain separate `resolved_edges` rows: `/a/ -> Top[0]` and
`/a/ -> Top[1]` project `Top#0` and `Top#1`, respectively, even though their `re` text is equal. Dart validates
those target/index identities before descriptor projection rather than trying to infer them from regex text.

## `spec`

`spec` is the outward rule table.

Each rule entry contains the generated handler plus the rule-level metadata needed by runtime dispatch and tooling.

The important active field for child/dependency mapping is:

```perl
dependency_refs
```

That list describes which other rule regexes this rule depends on when building combined dependency regex dispatch.

Migrated Perl, Rust, Dart, and Julia rule metadata exposes `resolved_edges` in normalized source order. A grouped action edge produces one row per
target. The semantic fields are exactly `ownership`, `target`, `regex_index`, `block`, and `fluent`:

- action edges always carry their resolved zero-based regex index, including `0` when the source omitted it;
- blind edges use `undef` for `regex_index` because blind dispatch does not select a target regex slot through the action-edge matcher;
- `block` is `0` or `1`, and `fluent` is the normalized method chain or `undef`;
- optional `source_form` is `bare` or `explicit`, but is provenance only. Perl retains it; Rust and Dart omit it
  because their normalized compiled state does not retain it. Removing it yields identical semantic rows for
  equivalent bare and explicit spellings, and runtime dispatch never reads it.

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

Every variant records the definition by name through one exact versioned union. The common fields are `index`,
`kind`, `version`, `name`, followed by one variant's parameter fields and the shared `source_text`, `source_span`,
`body_span`, `body_source`, `body_payload`, `body_parse_job`, and `body_ast` suffix. `index` is zero-based source
order and `kind` is `user_function_definition`.

| Variant | Version | Exact parameter fields |
| --- | ---: | --- |
| fixed | 1 | `params`, `arity` |
| variadic | 2 | `signature` |
| fixed with final codeblock intent | 3 | `params`, `arity`, `parameter_kinds` |

The authoritative executable union is
`capability_conformance/outward_descriptor_contract.json:function_record_variants`. Its checker rejects variant,
field-order, version, storage, or final-codeblock-policy drift. Focused backend tests reject missing or
backend-specific extra fields. `source_text` is the complete original definition while `body_source` is the exact
text inside its braces.

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

### Variadic descriptor version (Perl, Rust, Dart, Julia, and Lua implemented)

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
`capability_conformance/callable_signature_contract.json` governs the signature object and execution fixture;
`outward_descriptor_contract.json` governs its exact version-2 record placement. Perl, Rust, Dart, Julia, and Lua
expose this v1/v2 union and its staged records exactly. Rust's typed `CallableSignature` survives compiled-state serialization,
source emission, and generated-plan execution. Dart's corresponding typed value survives normalized emitted JSON,
generated-plan execution, and reconstruction. Julia's typed value survives canonical JSON/ASCII-hex emission,
generated-plan execution, and reconstruction through the same compiler/runtime. Consumers must branch on
function-record `version`, never on field presence alone.

### Final-codeblock descriptor version (Perl and Lua implemented)

A fixed function whose final parameter is declared `name: codeblock` uses version 3. It retains the ordinary
fixed `params` and `arity`, then adds one exact `parameter_kinds` object:

```json
{
  "version": 3,
  "params": ["value", "callback"],
  "arity": 2,
  "parameter_kinds": {"callback": "codeblock"}
}
```

The object must contain exactly one entry, its key must be the final parameter name, and its value must be
`codeblock`. Empty, extra, non-final, or differently valued entries are invalid; version 3 never carries a
variadic `signature`. The same `parameter_kinds` value is preserved in `body_payload` and `body_parse_job`.
Perl and Lua currently expose this exact record because both already implement contextual final-codeblock user
functions. This descriptor fact does not promote the separately future generic callable-codeblock capability.

## `meta`

`meta` carries descriptor-level metadata.

Important current fields include:

- `descriptor_model`
- `cursor_contract` (`linkedspec-rule-local-cursor-v1` on admitted Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT)
- `regex_slot_identity_contract` (`linkedspec-duplicate-regex-slot-identity-v1` on admitted Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT)
- `entry_rule_contract` (`linkedspec-root-rule-selection-v1` on admitted Perl, Rust, Dart, Julia, and Lua routes)
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
assert_eq!(descriptor.meta.cursor_contract, "linkedspec-rule-local-cursor-v1");
assert_eq!(
    descriptor.meta.regex_slot_identity_contract,
    "linkedspec-duplicate-regex-slot-identity-v1",
);
assert_eq!(descriptor.meta.entry_rule_contract, "linkedspec-root-rule-selection-v1");
assert_eq!(descriptor.meta.compiled_rule_order, ["Top", "Child"]);
assert_eq!(descriptor.spec["Top"].dependency_refs[0].label, "Child");
assert_eq!(descriptor.spec["Top"].meta.family, "or_default");
assert_eq!(
    descriptor.spec["Top"].meta.cursor_policy,
    linkedspec_core::types::ParseMode::Seek,
);

let json = compiled.to_descriptor_json()?;
assert!(json.get("functions").is_some());
# Ok::<(), Box<dyn std::error::Error>>(())
```

`descriptor_state()` returns typed serializable records from `linkedspec_core::descriptor`.
`to_descriptor_json()` returns their JSON representation. Both are projections over `CompiledSpec`; neither
launches a subprocess or requires `linkedspec-runtime`. Ordered `dependency_refs`, function order, staged
`body_payload` / `body_parse_job` / `body_ast`, definition order, last-definition compile order, and model
identities survive compiled-state serialization round trips.

Rust uses the rule-local cursor descriptor-v1 metadata variant and root-rule selection v1. Descriptor-wide
metadata contains `cursor_contract = "linkedspec-rule-local-cursor-v1"`,
`regex_slot_identity_contract = "linkedspec-duplicate-regex-slot-identity-v1"`,
`entry_rule_contract = "linkedspec-root-rule-selection-v1"`, and no global cursor field. Definition order and
each rule's boolean `is_top` remain authored identity even when an explicit ordinary rule executes first. Each
rule's metadata also contains:

- `family`: normalized `and` or `or_default` authored identity;
- `cursor_policy`: derived `consume` or `seek`;
- `edge_ownership`: `action`, `blind`, or `none`; and
- `resolved_edges`: deterministic semantic rows with `ownership`, `target`, child `regex_index`, `block`, and
  `fluent`.

For example, this AND-family action exception remains consume at the rule level while its explicit edge selects
child regex slot 1:

```rust
let spec = parse_spec(
    "Top::AND\n -> Child[1] { return(\"hit\") }\nChild:\n /a/\n /b/\n",
)?;
let descriptor = compile(&spec)?.descriptor_state();
let top = &descriptor.spec["Top"].meta;

assert_eq!(top.family, "and");
assert_eq!(top.cursor_policy, linkedspec_core::types::ParseMode::Consume);
assert_eq!(top.edge_ownership, "action");
assert_eq!(top.resolved_edges[0].target, "Child");
assert_eq!(top.resolved_edges[0].regex_index, Some(1));
assert!(top.resolved_edges[0].block);
# Ok::<(), Box<dyn std::error::Error>>(())
```

Bare and explicit equivalent edges project the same semantic row. The neutral contract allows an optional
non-semantic `source_form`, but Rust intentionally omits it because compiled normalization does not retain that
provenance. Direct, file-loaded, and ordinary compiled-JSON-reconstructed descriptors agree, and their policy is
the same policy normal live execution spends. Generated-source v2 is a separate artifact contract that derives
the same policy from its minimal neutral family plan rather than copying descriptor fields.

## Julia in-memory cursor descriptor API

Julia exposes the same rule-local cursor-v1 facts through the existing outward projection:

```julia
using LinkedSpecJulia

source = """
Top::AND
 -> Child[1] { return(\"hit\") }
Child:
 /a/
 /b/
"""

compiled = compile_spec(parse_spec(source))
descriptor = to_descriptor_json(compiled)
top = descriptor["spec"]["Top"]["meta"]

@assert descriptor["meta"]["cursor_contract"] ==
    "linkedspec-rule-local-cursor-v1"
@assert !haskey(descriptor["meta"], "parse_mode")
@assert top["family"] == "and"
@assert top["cursor_policy"] == "consume"
@assert top["edge_ownership"] == "action"
@assert top["resolved_edges"][1] == Dict(
    "ownership" => "action",
    "target" => "Child",
    "regex_index" => 1,
    "block" => true,
    "fluent" => nothing,
)
```

Julia derives these fields from `CompiledRuleModeMetadata` and the normalized action/blind tables; the descriptor
does not add mutable execution state. Action rows identify the child's selected regex slot. Blind rows use a null
index because they do not select a child slot. Fluent-only edges retain `block = false` and publish their fluent
chain separately. Bare and explicit equivalent edges converge, and optional `source_form` is omitted because
compiled state does not retain that non-semantic provenance.

Julia does not deserialize the outward descriptor. Its reconstruction route round-trips normalized `SpecFile`
JSON and recompiles; file loading invokes that same compiler. Direct, normalized, and file-loaded projections are
JSON-byte-identical, while invalid reconstructed edge state fails portable validation before projection. Generated
source is a separate v2 artifact contract derived from the same family facts; it does not deserialize descriptor
cursor fields.

All five implemented backends expose the exact top-level projection, composing/nested model identities, and
canonical outer function records. Rust's typed/API implementation landed under `.1.6.2.2`; the shared executable
contract and final four-backend admission closed under `.1.6.2.3`. Cursor metadata then migrated by explicit
variant: Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT consume rule-local v1 and are composed-admitted. Public
cursor no-drift is closed at 8 complete / 0 pending.
