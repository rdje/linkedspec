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
      kind => 'user_function_definition',
      version => 1,
      name => 'normalize',
      params => ['value'],
      arity => 1,
      source_span => { line_start => 1, line_end => 3, ... },
      body_span => { ... },
      body_source => "\n return(trim(value))\n",
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

The descriptor records the definition by name, including ordered parameter names, exact arity, source/body
spans, original body source, and the parsed ActionIR `action_block` body AST. Function definitions are validated
before runtime: duplicate names, invalid or duplicate parameters, reserved runtime/lifecycle/function symbols,
built-in helper/control-name collisions, and rule-label collisions are rejected.

The compiler also uses this registry while lowering rule actions. Calls such as
`return(normalize(" x "))` now resolve on the Perl reference when the callee is registered
and the arity matches. Wrong-arity registered calls still report unresolved-helper
metadata with zero raw fallback. A standalone `normalize(" x ")` lowers as a canonical
`VALUE_DROP`: the value is computed through the function resolver and then discarded.
Rust runtime parity remains follow-on work.

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
