# 0017 — Function-definition staged AST shape is predicted before implementation

- Date: 2026-07-02
- Status: accepted
- Tags: architecture, staged-parsing, user-functions, ast, source-provenance, language-neutral

## Context

`STAGED-LINKED-PARSING.5.1` selected user-defined function body text as the first
staged parsing prototype payload. The next implementation must not only preserve
runtime user-function behavior; it must prove the returned function-definition AST
shape across many variations.

The `.5.2` audit found several current seams:

- A direct top regex rule cannot read its own captures through `entry_group(...)`;
  top rules have no entering match. A focused test harness must dispatch from a tiny
  wrapper top rule into a normal `function_definition` rule.
- The current `specs/spec.spec` `function_definition` rule uses numbered captures
  around an optional parameter list. Because numbered captures are compacted to
  participating captures, zero-argument functions mis-shape as `params = "{ ... }"` and
  `body = null`.
- The current body regex protects quoted strings and nested braces but not regex
  literals containing `{` or `}`, so regex-looking function bodies can be missed or
  truncated.
- Current bridges differ: the Perl reference stores exact inner `body_source` plus byte
  spans, while Rust stores line spans and trims `body_source`.

## Decision

The staged function-definition prototype must use this neutral AST contract:

1. Focused AST-shape tests use a dedicated small spec file/top rule:
   - a wrapper top rule, for example `function_file::`, owns the accumulator;
   - it dispatches to a normal `function_definition:` rule;
   - it returns a source-ordered array of function-definition nodes.
2. The `function_definition` rule must use named captures for `name`, `params`, and
   `body` or an equivalent structured parse. Numbered captures are not acceptable for
   optional fields.
3. Before staged body dispatch, each returned function-definition node has this neutral
   shape:

```json
{
  "type": "function_definition",
  "name": "normalize",
  "params": ["value"],
  "arity": 1,
  "source_text": "fn normalize(value) { return(trim(value)) }",
  "source_span": {
    "start": 0,
    "end": 43,
    "line_start": 1,
    "line_end": 1
  },
  "body_source": " return(trim(value)) ",
  "body_span": {
    "start": 21,
    "end": 42,
    "line_start": 1,
    "line_end": 1
  },
  "body_parse_job": {
    "payload_kind": "function_body",
    "parser_spec_id": "actionir-body.spec",
    "top_rule": "action_block",
    "result_policy": "replace_field",
    "failure_policy": "fail"
  }
}
```

4. After staged dispatch, the stitched node keeps those fields and adds a neutral
   `body_ast` field containing the parsed function body. The `body_ast` shape must be
   asserted directly; runtime behavior alone is insufficient.
5. `body_source` is the exact inner text between braces, preserving whitespace for
   provenance. The full braced text remains in `source_text`; implementations may trim
   only inside the later body parser if that parser's grammar says so.
6. Source spans are neutral source coordinates. The example above uses zero-based
   half-open offsets. A backend may store extra local metadata, but the portable
   contract includes byte/character offsets plus line spans or a documented equivalent
   provenance list.
7. The variation matrix must include at least: zero params, one param, multiple params,
   whitespace/newline variants, functions before the first rule and between rules,
   nested bodies, quoted braces, escaped quotes, regex literals containing braces,
   adjacent comments/rules, malformed headers, unclosed parameter/body delimiters,
   invalid identifiers, duplicate params, duplicate functions, collisions with rule
   labels and built-ins, and reserved parameters.

## Consequences

- `STAGED-LINKED-PARSING.5.3` must preserve enough source provenance to build this
  neutral node shape before dispatch.
- `STAGED-LINKED-PARSING.5.4` must represent the body payload as a parse job rather than
  backend-private callback state.
- `STAGED-LINKED-PARSING.5.6` must assert the predicted AST shape with the dedicated
  small spec/top rule and the variation matrix before accepting the staged prototype.
- Existing Perl/Rust bridge shapes are evidence only. They do not define the portable
  AST contract.

## Current implementation note (2026-08-25)

The predicted function-definition shell, `body_payload`, `body_parse_job`, stitched
`body_ast`, descriptor projection, and runtime behavior are now current on Perl, Rust,
Dart, Julia, PUC Lua, and LuaJIT. The exact current registry/policy/diagnostic boundary is
recorded by `FUTURE-PARITY-BACKLOG.14.7.0` and
`docs/knowledge/general-staged-ast-current-boundary.md`; it must remain compatible while
the separate general authored/recursive contract lands.

## Links

- Task tree: `docs/tasks/STAGED-LINKED-PARSING.md`
- Related: ADR `0016` staged parsing language neutrality, ADR `0014` staged parse-job
  annotation contract, ADR `0015` staged parser registry/dispatch contract, ADR `0011`
  text-to-AST backend doctrine
