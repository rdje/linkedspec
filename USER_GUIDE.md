# USER GUIDE
This guide explains how to use LinkedSpec as a progressive extraction parser DSL.

## What LinkedSpec Is
LinkedSpec compiles `.spec` files from `specs/` into dynamic Perl parsers.
These generated parsers parse input strings and return raw AST/data structures.

LinkedSpec is intentionally optimized for:
- Nested and recursive constructs.
- Coarse-to-fine staged parsing.
- Rapid parser prototyping.

## Typical Workflow
1. Write a `.spec` grammar with rule labels, regexes, and actions.
2. Build parser:
   - `my $parser = LinkedSpec::get_parser('my_spec_name');`
3. Parse data:
   - `my $ast = $parser->(\$input_string);`
4. Optionally run additional parsing passes on selected captured substrings.

## Rule Skeleton
```text
top_rule::
 -> subrule_a
 -> subrule_b
 LX { return \@top_rule }

subrule_a: /.../
subrule_b: /.../
```

## Core Syntax
- Entry rule: `name::`
- Regular rule: `name:`
- Regex pattern(s): `/.../` (single or multiple per rule)
- Branch/action:
  - `-> rule`
  - `-> rule[idx]`
  - `-> rule { ... }`
  - `-> rule .method(args)` (method-like shorthand)
- Non-action code blocks:
  - `I { ... }` (init)
  - `LS { ... }` (loop-start hook)
  - `LE { ... }` (loop-end hook)
  - `LX { ... }` (loop-exit/fail hook)
  - Also used in advanced specs: `E`, `EX`, `IT`

## Useful Action Helpers
Inside action code, LinkedSpec supports helper forms such as:
- `call(rule)`
- `push(rule)`
- `return_a(rule)`
- `return_m(rule)`
- `return_ma(rule)`
- `$CAPTURE`
- `BACKTRACK()`, `IBACKTRACK()`

These helpers are expanded by LinkedSpec into parser runtime code.

## Multi-Pass Parsing Pattern (Recommended)
Use pass-by-pass refinement:
1. First pass: coarse anchors to chunk input.
2. Next pass(es): parse chunk content with more specialized specs.
3. Final pass: normalize/merge into final AST.

This pattern is a primary LinkedSpec strength.

## Runtime Options (current)
`LinkedSpec::Get(\$spec, %options)` supports:
- `parse_only => 1`
- `generate_only => 1`
- `return_descr => 1` (return internal `{spec=>..., gdata=>...}` descriptor instead of parser coderef)
- `pm_drive => 1` (emit generated parser code text)

## Spec Lookup Behavior (`get_parser`)
`LinkedSpec::get_parser('name')` resolves parser specs in this order:
1. If argument is already a valid file path, use it directly.
2. Try `name.spec` directly if available.
3. Try module-relative `../specs/name.spec` (relative to `perl/LinkedSpec.pm`).
4. If still unresolved, fall back to `PathSearch`.

This removes hard dependency on running from the project root.

## Known Caveats
- Current behavior is extraction-oriented and may not enforce full contiguous consumption unless spec logic does so.
- Some old specs may rely on permissive behavior.
- `specs/tclite.spec` currently has a known compile issue to be fixed.

## Debugging
- Set `LinkedSpec` verbosity via `our $DUMP_VERBOSITY`.
- Use `parse_only` and/or `pm_drive` to inspect compile/generation behavior.

## Inspect Generated Perl for `.spec` Pieces
Use the snippet inspection utility when you want to visually verify generated Perl for specific DSL fragments.

- Script: `tools/inspect_spec_codegen.pl`
- Supports:
  - lifecycle chains, e.g. `I.lowercase_each(array(parts)).filter_match(uniq(uppercase_each(array(parts))), /^[A-Z_]+$/)`
  - action edges, e.g. `/a/ -> Top .lowercase_each(array(parts)).filter_match(...)`
  - raw helper expressions, e.g. `filter_match(uniq(uppercase_each(array(parts))), /^[A-Z_]+$/)`

Examples:
- `perl tools/inspect_spec_codegen.pl --label Top --snippet 'I.lowercase_each(array(parts)).filter_match(uniq(uppercase_each(array(parts))), /^[A-Z_]+$/)'`
- `perl tools/inspect_spec_codegen.pl --label Top --snippet '/a/ -> Top .lowercase_each(array(parts)).filter_match(uniq(uppercase_each(array(parts))), /^[A-Z_]+$/)'`
- `perl tools/inspect_spec_codegen.pl --snippet-file path/to/snippets.txt`

Output includes:
- normalized helper code,
- generated Perl code,
- canonical action-IR nodes,
- RAW_PERL fallback count and unresolved-helper count.

## Composable Array-String Method Routines
Current composable method routines include:
- `split(array(...), scalar(...), /.../)`
- `trim_each(array(...))`
- `filter_nonempty(array(...))`
- `lowercase_each(array(...))`
- `uppercase_each(array(...))`
- `uniq(array(...))`
- `filter_match(array(...), /.../)`

Both styles are supported:
- dot-chained method style,
- nested functional composition style (including mixed usage).

## Fluent Control-Flow Example (`pipe_operator` with `if/else`)
You can express branch logic without `{...}` blocks by chaining fluent control-flow methods.

Example rule intent:
- parse `|` via a `pipe_operator` rule,
- if container context is enabled (`on`), push parsed pipe node into `rule`,
- otherwise emit an error and return `undef`.

```text
pipe_operator:
 /\|/ -> pipe_operator { return_a(pipe_operator) }

Top::&
 /\|/ -> Top
   .if(scalar(on))
     .push(pipe_operator, rule)
   .else()
     .say("Error: '|' operator occurrence with no container rule context")
     .return_undef()
   .endif()
```

Quick snippet inspection:
- `perl tools/inspect_spec_codegen.pl --label Top --snippet 'if(scalar(on)); push(pipe_operator, rule); else(); say("Error: '\''|'\'' operator occurrence with no container rule context"); return_undef(); endif()'`

## Unified Lisp-Style Control-Flow Conditions
Fluent control-flow condition/value arguments support nested Lisp-style expressions.

Examples:
- `if(or(scalar(on), and(not(scalar(off)), is_empty(scalar(name)))))`
- `elseif(matches(scalar(token), /^[A-Z_]+$/))`
- `switch(or(scalar(op_ready), not(is_empty(scalar(op)))))`

Supported condition helpers include:
- boolean composition: `or(...)`, `and(...)`, `not(...)`
- emptiness checks: `is_empty(...)`, `is_nonempty(...)`
- comparisons: `eq/ne/gt/ge/lt/le` and numeric `num_eq/num_ne/num_gt/num_ge/num_lt/num_le`
- regex predicate: `matches(lhs, /regex/)`

## Scalar Collection Entry Access in Conditions
Control-flow expressions support scalar collection-entry access through:
- `scalar(container, key_or_index)`

Examples:
- `scalar(foo_arr, idx)` -> array entry value form
- `scalar(foo_hash, key)` -> hash entry value form
- explicit forms:
  - `scalar(array(foo_arr), idx)`
  - `scalar(hash(foo_hash), key)`

Single-argument scalar form remains:
- `scalar(name)`

Compatibility form remains:
- `scalar(IMATCH_LIST, n)`

## Inline Composite `switch(...)` Branch Form
In addition to marker-style fluent chains (`switch(); case(); default(); endswitch()`), you can encode branches directly in `switch(...)` arguments.

Example:
```text
Top::&
 /a/ -> Top .switch(
   scalar(op),
   case("|", push(pipe_operator, rule)),
   case("&", say("amp")),
   default(say("Error"), return_undef())
 )
```

This form keeps branch structure and branch actions co-located while still lowering through the same helper-contract pipeline.
## Complete Method/Helper Reference (Current)
This section summarizes the helper/method surface currently recognized by the action rewriter.

### 1) Control-flow markers
- `if(cond)` / `i(cond)`
- `elseif(cond)` / `elif(cond)`
- `else()`
- `endif()`
- `switch(cond)` (marker form)
- `case(value)` (marker form)
- `default()` (marker form)
- `endcase()` (optional in switch marker flow)
- `endswitch()`
- inline composite form:
  - `switch(cond, case(v1, action1, ...), case(v2, ...), default(actionN, ...))`

### 2) Condition/value expression helpers used inside `if/elseif/switch`
- Boolean composition:
  - `or(expr1, expr2, ...)`
  - `and(expr1, expr2, ...)`
  - `not(expr)`
- Emptiness predicates:
  - `is_empty(expr)`
  - `is_nonempty(expr)`
- String comparisons:
  - `eq(lhs, rhs)`, `ne(lhs, rhs)`, `gt(lhs, rhs)`, `ge(lhs, rhs)`, `lt(lhs, rhs)`, `le(lhs, rhs)`
- Numeric comparisons:
  - `num_eq(lhs, rhs)`, `num_ne(lhs, rhs)`, `num_gt(lhs, rhs)`, `num_ge(lhs, rhs)`, `num_lt(lhs, rhs)`, `num_le(lhs, rhs)`
- Regex predicate:
  - `matches(lhs, /regex/)`

### 3) Scalar/array/hash value helpers
- `scalar(name)` -> scalar variable value
- `scalar(container, key_or_index)` -> collection entry value
  - examples:
    - `scalar(foo_arr, idx)` -> array entry access
    - `scalar(foo_hash, key)` -> hash entry access
  - explicit forms:
    - `scalar(array(foo_arr), idx)`
    - `scalar(hash(foo_hash), key)`
- compatibility:
  - `scalar(IMATCH_LIST, n)`
- reference-path scalar helper:
  - `scalaref(base_ref, [path][segments]{...})` -> chained dereference from scalar ref base
  - examples:
    - `scalaref(myref, [A][B]{C}[D])` -> `$myref->[A]->[B]->{C}->[D]`
    - `scalaref(myref, {A}[B]{C}[D])` -> `$myref->{A}->[B]->{C}->[D]`
- array constructor/value helper:
  - `array(v1, v2, ...)`

### 4) Branch/action statements
- `say(v1, v2, ...)`
- `print(v1, v2, ...)`
- `return_undef()`

### 5) Call/push/capture/backtrack helpers
- `call(rule)`
- `push(rule)` (push to current label array)
- `push(rule, target)` (push to explicit target array)
- `push(scope, rule, target)` (scope-injected form emitted by chained-method rendering)
- `$CAPTURE`
- `capture(label)`
- `capture_if(label)` / `CAPTURE_IF()`
- `ibacktrack(label)` / `IBACKTRACK()`
- `backtrack(label)` / `BACKTRACK()`

### 6) Return helpers
- `return(payload)` (general payload form)
  - supports nested `[]` / `{}` literals, quoted strings, numbers, and embedded `scalar(...)` / `array(...)` helper values
- `return_a(label[, arg])`
- `return_m(label)`
- `return_ma(label)`
- `return_imatch(tag)` / `return_im(tag)`
- `return_array(tag, payload)`
- `return(label, arg)` (legacy tagged return helper form)
- `return call(rule)` (call-wrapper lowering form)

### 7) Declaration/assignment/transform helpers
- declarations:
  - `declare(type, names...)` where `type` is `array|scalar|hash`
  - aliases: `declare_a/s/h`, `declare_array/scalar/hash`
- assignment/capture source:
  - `assign(target, CAPTURE|IMATCH|LMATCH)`
- regex substitution:
  - `substr(target, pattern, replacement, flags)`
  - `regex_subst(target, pattern, replacement, flags)`
- composable array-string transforms:
  - `split(array_target, scalar_source, delimiter?)`
  - `trim_each(array_target)`
  - `filter_nonempty(array_target)`
  - `lowercase_each(array_target)`
  - `uppercase_each(array_target)`
  - `uniq(array_target)`
  - `filter_match(array_target, regex)`

### 8) Method-chain usage forms
- action-edge chain:
  - `-> Rule .method1(...).method2(...).methodN(...)`
- lifecycle chain:
  - `I.method1(...).method2(...)`
  - also valid for `E`, `EX`, `IT`, `LX`, `LS`, `LE`

### Notes on `return_undef()` and richer return payloads
- `return_undef()` is a dedicated shorthand for `return undef` in fluent branches.
- For rich payload returns, prefer generalized `return(payload)` with nested literal structures.
- Legacy `return(label, arg)` helper remains supported for compatibility with existing specs and tagged-return behavior.
### Exhaustive `return(payload)` payload reference
`return(payload)` accepts exactly one payload argument.

Supported payload categories:
- String literals
  - `return("ok")`
  - `return('ok')`
- Numeric literals
  - `return(0)`
  - `return(-3.14)`
- Array literals (including nested)
  - `return(["semantic", 1, 2])`
  - `return([1, { k => "v" }, [2, 3]])`
- Hash literals (including nested)
  - `return({ kind => "node", ok => 1 })`
  - `return({ meta => { id => 7 }, list => [1, 2] })`
- Helper-based scalar lookups
  - `return(scalar(name))`
  - `return(scalar(foo_arr, idx))`
  - `return(scalar(foo_hash, key))`
  - `return(scalar(array(foo_arr), idx))`
  - `return(scalar(hash(foo_hash), key))`
  - `return(scalar(IMATCH_LIST, 0))`
- Helper-based ref-path lookups
  - `return(scalaref(myref, [A][B]{C}[D]))`
  - `return(scalaref(myref, {A}[B]{C}[D]))`
- Helper-based array construction
  - `return(array(scalar(name), 123, "x"))`
- Mixed nested payloads with embedded helpers
  - `return(["semantic", { key => scalar(name) }, [123, scalar(foo_arr, idx)]])`
  - `return({ item => scalar(foo_hash, key), list => [scalar(name), 123] })`
- Raw Perl expressions are also accepted in block-form payloads
  - `return($value)`
  - `return($hash{$key} // "na")`
  - `return(foo())`
  - `return(foo)` (bare identifier)

Lowering behavior examples:
- `return(["semantic", { key => scalar(name) }, [123, scalar(foo_arr, idx)]])`
  - lowers to: `return ["semantic", { key => $name }, [123, $foo_arr[$idx]]]`
- `return({ item => scalar(foo_hash, key), list => [scalar(name), 123] })`
  - lowers to: `return { item => $foo_hash{$key}, list => [$name, 123] }`
- `return(scalar(name))`
  - lowers to: `return $name`
- `return(array(scalar(name), 2))`
  - lowers to: `return [$name, 2]`

Method-chain caveat (`-> Rule .return(...)`):
- General payload mode is selected for chain payloads that start with:
  - `[` / `{`
  - quoted strings (`"..."` / `'...'`)
  - numeric literals
  - `scalar(...)`, `scalaref(...)`, `array(...)`, or `hash(...)`
- Example (general payload):
  - `-> Top .return(["semantic", { key => scalar(name) }])`
- If chain payload does not match those starts, chain rendering falls back to label-injected legacy form.
  - Example: `-> Top .return(foo)` is treated as legacy-style return with scope label injection, not generalized `return(payload)`.

## Versioning and Compatibility
- Treat existing specs as compatibility contracts.
- Before changing core semantics, validate against baseline specs and consumer modules.
