# Helper Contract Catalog

This appendix is the **canonical behavioral reference** for every ActionIR helper.
Each entry defines the helper's contract — signature, input/output types, semantics,
edge cases — at enough precision for a Rust, Dart, Julia, or Lua backend to implement
identically. No Perl implementation knowledge is required.

Helper calls use the `callee(args)` shape. Whitespace before the opening parenthesis
is accepted (`set (name, value)` is the same call as `set(name, value)`), but the
parentheses remain mandatory; no-parenthesis spellings such as `set name, value` or
`return scalar name` are not helper calls.

## 0. Primitive Value Literals

Primitive literals are value expressions, not helper calls or working-variable names.

- **Strings**: `"text"` and `'text'`.
- **Numbers**: integer and decimal forms such as `42`, `-1`, and `3.14`.
- **Booleans**: `true` and `false`, serialized as JSON booleans when returned or placed in containers.
- **Undefined**: `undef`, serialized as JSON `null`.

These literals are accepted in return payloads, constructor payloads, assignment RHS values,
append RHS values, hash keys/values, and flow predicates:

```text
return(array(true, false, "ready", 42, undef))
flag = true
items += false
meta["enabled"] = true
if(false); return("bad"); else(); return("good"); endif()
```

Literal recognition is exact. Prefix identifiers such as `trueword`, `false_alarm`, and
`undefine` are ordinary identifiers, not primitive literals.

## 0.1 Shape Value Literals

The Perl reference and Rust backend accept direct array and hash shape literals as value expressions:

```text
[]
[value, cat("a", "b"), true, []]
{ key : value, "fixed" : [value] }
```

Shape literals are accepted in value-consuming sites such as `return(payload)`, scalar assignment sources,
array append RHS values, hash-index assignment RHS values, `push(target, value)`, and nested constructor
payloads. Array elements, hash keys, and hash values lower through the scoped DSL value-expression rules:
primitive literals stay typed, recognized helper calls compose, direct nested access keeps its own bracket
semantics, nested shape literals recurse, and non-reserved bare names are scalar working-variable reads.
Perl and Rust both use `:` as the direct hash-literal key/value separator. Old `{ key => value }` ActionIR
value syntax is retired and reports `hash_literal_use_colon`; `=>` remains valid only for other owned surfaces
such as blind-call edges, source-language payloads, generated Perl host hashrefs, and historical records.

A bare hash-literal key is a dynamic scalar key, not a fixed string field name:

```text
set(key, "kind")
set(value, "token")
return({ key : value });       # {"kind": "token"}
return({ "kind" : value });    # fixed "kind" field
```

Direct shape literals are typed RHS values for bare assignment targets on the Perl reference and Rust backend:

```text
items = [value, cat("a", "b")];      # items holds an array value
meta = { key : value };             # meta holds a hash value
set(items, []);                      # items holds an empty array value
set(meta, {});                       # meta holds an empty hash value
set(array(items), []);               # explicit aggregate array reset
set(hash(meta), {});                 # explicit aggregate hash reset
```

Bare working-variable reads and targets are the current scalar surface:
`set(payload, [value])` stores the whole array payload in `payload`. In value positions, `name` reads the
working variable named `name`.
Direct-access brackets (`payload["items"][i]`), hash-index assignment brackets (`meta[key] = value`),
control-flow/block braces, and all-bare child-call routing remain separate surfaces.

The Perl reference and Rust backend accept expression-valued blocks in value-consuming sites. A non-empty
brace payload with no top-level hash-pair delimiter evaluates its statements and yields the final expression. A
`return(expr)` anywhere in the block exits only that expression-valued block, skips later block statements,
and yields `expr` as the block value. Hash literals keep precedence: `{}` and `{ key : value }`
remain hash shapes; old `{ key => value }` is retired and is not a block fallback.

```text
return({ set(x, "a"); x });                    # "a"
set(out, { set(x, "a"); return(x) });          # $out = "a"
return({ return("a"); "b" });                  # "a"
set(out, { set(x, "a"); return(x); set(x, "b"); x });  # $out = "a"
return(array({ set(x, "a"); x }, { "k" : x }))
return({ [3, 1, 2] }.sorted().join_values(","));        # "1,2,3"
return({ " a-b " }.trim().split("-").count());          # 2
```

Expression-valued blocks are ordinary value expressions when used as receiver-dot receivers. The block
evaluates first, including any block-local `return(expr)`, and the yielded value is consumed by the same
compatible receiver family selected by the first method. Blocks do not create a separate block-only receiver
dispatch rule.

### Trailing block helper: `with(value) { ... }` / `.with() { ... }`

- **Signature**: `with(value?: expr) { block }`; receiver form `receiver.with() { block }`
- **Returns**: the immediate block result.
- **Backend status**: Perl, Rust, Dart, and Julia support the current helper and receiver forms. Lua is not yet
  implemented. Bare `with { ... }`, explicit receiver `.with(value) { ... }`, and the equivalent parenthesized
  final-codeblock spelling `with(value, { ... })` are not current portable surfaces.
- **Behavior**: Helper form evaluates the optional value argument, binds scoped scalar `value` while the trailing
  block executes, restores any surrounding `value` binding afterward, and yields the block result. `with() { ... }`
  binds `value` to `undef`. Receiver form evaluates the receiver first, binds that receiver value as scoped
  `value`, and yields the block result as the terminal value or as the input to later compatible receiver-family
  links.
- **Execution context**: The block runs immediately in the caller's current action/runtime context. Captures,
  `retv`, cursor state, helper/function visibility, and ordinary working-variable side effects are shared with the
  call site. Only the scalar binding `value` is portable as the scoped block parameter in this MVP; mutations to
  other variable names persist after `with` returns.
- **Return semantics**: `return(expr)` inside the trailing block is block-local, exactly like expression-valued
  blocks: it yields `expr` from the block and skips later block statements; it does not return from the surrounding
  rule/action.
- **Examples**:
  - `return(with("x") { return(cat(value, "!")) })` yields `"x!"`.
  - `return(with() { return(is_undefined(value)) })` yields true.
  - `return(" x ".with() { return(cat(value, "!")) }.trim())` yields `"x !"`.
  - `return(" a-b ".trim().with() { return(value.split("-")) }.count())` yields `2`.
  - `set(value, "outer"); return(array(with("inner") { return(value) }, value))` yields `["inner", "outer"]`.

> **Corrective direction:** `with` is currently a special-cased MVP, not the final syntax abstraction. The language
> model has scalar, array, harray/hash, and codeblock values. A block-taking callable should declare a final
> codeblock parameter, after which attached/contextual final-block forms normalize to the same call on helper,
> user-function, and receiver-method surfaces. ADR 0031 selects future explicit literals as `{|args| body }`,
> dynamic caller context without lexical capture, and retained `with`. Neutral contract `.11.2` is adopted and
> checked. Perl now preserves inert literal records, but invocation `.11.3.2` is still active; do not infer future
> call/final-block equivalence from current behavior.

## 1. Working Variables and Setup

> **Working variables auto-exist.** Referencing a variable through a typed aggregate wrapper
> (`array(name)` / `hash(name)`) or a bare scalar read/target position auto-creates it as a
> per-invocation working variable of that kind. The wrapper is also optional in a
> **type-implying argument position**: the scalar target of `set(name, ...)` and the assignment
> operator `name = value`, which bind scalar, array, or hash RHS values as the variable's current
> typed value; explicit aggregate targets such as `set(array(name), ...)` and `set(hash(name), ...)`;
> the scalar source in `return(name)`, `set(out, name)`, and `out = name`; the array target of
> `push(name, ...)` and the array append operator `name += value`; and the hash target of
> `set_key(name, key, value)` and hash-index assignment `name[key] = value` auto-exist from a
> **bare** name too, with the kind fixed by that position. Aggregate snapshot reads
> `copy(array(name))`, `copy(hash(name))`, and array-first `copy(name)` are also type-implying
> read positions. A backend MUST supply the same auto-existence: a wrapper- or
> position-referenced variable is a fresh working slot for the parse, not a value carried across
> parses. Recursive re-entry uses explicit aggregate reset forms:
> `set(array(name), [])` and `set(hash(name), {})` establish rule-local aggregate bindings before
> mutation. New specs should use direct assignment initializers such as `name = value` or explicit
> aggregate resets such as `set(array(items), [])` and `set(hash(meta), {})`.
> The DSL literals `undef`/`true`/`false` and the engine's own handler locals are never treated as
> working-variable names (so `array(undef)` builds an array holding the `undef` literal, not a
> variable `undef`).

### `name = value` assignment operator
- **Signature**: `name = value`
- **Returns**: In statement position, the stored value is ignored. In value position, it yields the typed value stored in the target.
- **Behavior**: Sets the working variable `name` to the evaluated RHS value. If the variable was not previously declared, the reference auto-creates it as a per-invocation working variable (see the note at the top of this section); otherwise it reassigns the existing variable. Later assignments may replace a scalar with an array/hash value, or replace an array/hash value with a scalar.
- **Edge cases**: `name = [value]`, `set(name, [value])`, and `=(name, [value])` bind an array value to `name`; `name = { key : value }` binds a hash value. Use `set(array(name), [value])` or `set(hash(name), { key : value })` for aggregate working storage. In scalar assignment source slots, a bare source name reads the working scalar: `out = value`.
- **Terse spelling**: `name = value` is the preferred operator spelling, and `set(name, value)` remains the helper spelling. In value positions, assignments store and yield the stored typed value. See [Terse Helper Renames](#terse-helper-renames-canonical-going-forward).
- **Worked example**:
  ```text
  demo::
   -> value .push
   LX { return(copy(array(demo))) }

  value : /(\w+)/
   I {
     value = entry_group(0)
     set(array(items), [value, cat(value, "!")])
     set(hash(meta), { "value" : value })
     return(array(value, array(items), hash(meta), name = value, name))
   }
  ```
  Input `ok` returns `[["ok",["ok","ok!"],{"value":"ok"},"ok","ok"]]`.
  The scalar assignment `name = value` stores and yields `"ok"` in value position; the explicit
  aggregate resets establish `items` and `meta`.

## 2. Scalar Helpers

> **Worked examples.** Each example below is a complete, runnable `.spec` written in the
> recommended **two-rule idiom**: a **top (`::`) entry rule** — which carries **no regex**
> of its own (it is the dispatch loop) — plus a **normal (`:`) rule** that carries the
> regex and computes the value. (This is the clean idiom for these helper demos, not a
> hard minimum — `::` is just an entry marker, and a top rule may itself carry a regex or
> recurse; see [.spec Files and Rule Paragraphs](../user-model/spec-files-and-rule-paragraphs.md).)
> The shared shape is:
>
> ```text
> demo::  -> value  .push
> LX { return(copy(array(demo))) }
>
> value : /<regex>/  I.return( <helper-expression> )
> ```
>
> The top rule dispatches to `value`, pushes its returned value into the accumulator
> (named after the top rule), and a terminal `LX` returns a snapshot of it. The `value`
> rule matches the input and reads its captures with **`entry_group(N)`** (the entering
> match) — `entry_group(0)` is the **first capture group** of `<regex>` (0-based; see
> [Regex in `.spec`](../user-model/regex-in-spec.md#capture-groups)). Because the parser's
> output is the top rule's accumulator, it is a **one-element array** holding the helper's
> value (see [Runtime Semantics §5.5](runtime-semantics.md)). Each compact "over
> `/<regex>/`, `<expr>` on `<input>` → `<output>`" line plugs into this shape: `value`
> carries `/<regex>/`, its `I.return(<expr>)` computes the result, and `<output>` is the
> parser's array. Predicate helper results in these examples surface in the reference
> boolean shape (`1` for true, `0` for false); primitive literal `true`/`false` values
> are typed JSON booleans. An undefined result surfaces as a `null` element. The value-returning predicates
> (`matches`, `starts_with`, `ends_with`, `contains_substr`) may be returned directly. The definedness predicates
> (`is_defined`, `is_undefined`) are portable in `if (...)` conditions and in current Perl/Rust ActionIR AST value
> contexts such as `with() { return(is_undefined(value)) }`.

### `container[key]`
- **Signature**: `container: array|hash[key: int|string]`
- **Returns**: scalar or undef
- **Behavior**: Reads a single value from an array (by 0-based index) or hash (by string key).
- **Edge cases**: Returns `undef` if the key does not exist or container is not array/hash.
- **Example**: over `/(\w+),(\w+),(\w+)/`, `array(entry_group(0), entry_group(1), entry_group(2))[1]` on `a,b,c` → `["b"]`.

### Direct nested access and value-path assignment: `base["key"][index]`
- **Signature**: `base[path_segment...]`, where `base` is a working scalar containing an array/hash payload.
- **Returns**: read form returns the selected value or `undef`; assignment form returns the updated root value on
  success or `undef` on failure.
- **Behavior**: Reads any-depth mixed hash/array paths directly from a structured payload. Quoted string
  segments such as `["children"]` or `['children']` are hash keys. Numeric segments and explicit helper/value
  expressions such as `[0]` or `[i]` are array indexes. A non-reserved bare path atom such as `[i]`
  is also a scalar array-index read, equivalent to `[i]`. The same direct path may be used as an assignment
  target, for example `payload["children"][0]["name"] = value`.
- **Edge cases**: Reads return `undef` when a segment does not exist or the current value has the wrong container
  kind. Writes do not autovivify intermediate containers: every intermediate hash key or array element must
  already exist and have the required array/hash shape. The final segment may create or replace a hash key, replace
  an existing array element, or append exactly at the current array length. Array gaps, missing intermediate keys,
  and wrong intermediate shapes yield `undef` and leave the root unchanged. Segment index expressions are evaluated
  before the RHS value expression; the root path check and mutation happen after both. Primitive literals and engine
  locals such as `[true]` or `[CAPTURE]` are not claimed as scalar path variables.
- **Example**:
  ```text
  Top::
   -> Done {
     set(payload, hash("children", array(hash("name", "one"), hash("name", "two"))))
     set(i, 1)
     payload["children"][i]["name"] = "updated"
     return(payload["children"][i]["name"])
   }

  Done:
   /[a-z]+/
  ```
  Input `xhello` -> `"updated"`.

### `cat(args...)`
- **Signature**: `cat(a: scalar, b: scalar, ...)`
- **Returns**: scalar
- **Behavior**: Concatenates all arguments as strings. Undef arguments are treated as empty strings.
- **Edge cases**: Non-scalar arguments (arrays, hashes) return `undef` for the whole expression.
- **Retirement note**: the former `concat` spelling diagnoses on current runtimes. See [Terse Helper Renames](#terse-helper-renames-canonical-going-forward).
- **Example**:
  ```text
  demo::  -> value  .push
  LX { return(copy(array(demo))) }

  value : /(\w+) (\w+)/  I.return( cat(entry_group(0), "-", entry_group(1)) )
  ```
  Input `hello world` → `["hello-world"]`.

### `coalesce(a, b, ...)`
- **Signature**: `coalesce(values: scalar...)`
- **Returns**: scalar
- **Behavior**: Returns the first argument that is defined (not undef). Evaluates left-to-right, short-circuiting.
- **Edge cases**: Returns `undef` if all arguments are undef.
- **Example**: over `/(\w+)/`, `coalesce(array(entry_group(0))[5], "fallback")` on `hi` → `["fallback"]` (the index-5 read is out of range, so the literal default is used).

### `coalesce_nonempty(a, b, ...)`
- **Signature**: `coalesce_nonempty(values: scalar...)`
- **Returns**: scalar
- **Behavior**: Returns the first argument that is defined and not the empty string `""`. Preserves `0` and other defined values.
- **Edge cases**: Returns `undef` only if all arguments are undef or `""`.
- **Example**: over `/(\w+)/`, `coalesce_nonempty("", entry_group(0))` on `value` → `["value"]` (the empty string is skipped).

### `is_defined(expr)`
- **Signature**: `is_defined(value: expr)`
- **Returns**: boolean
- **Behavior**: Returns true if the value is not undef. Accepts any expression type.
- **Edge cases**: Empty string, `0`, and empty arrays are defined.
- **Usage**: condition-only — `is_defined(...)` is a flow predicate, used inside an
  `if (...)` / `elseif (...)` test, not as a `return(...)` value.
- **Example**:
  ```text
  demo::  -> value  .push
  LX { return(copy(array(demo))) }

  value : /(\w+)/  I { if (is_defined(entry_group(0))) { return("present") } else { return("absent") } }
  ```
  Input `hi` → `["present"]`.

### `is_undefined(expr)`
- **Signature**: `is_undefined(value: expr)`
- **Returns**: boolean
- **Behavior**: Returns true if the value is undef. Logical inverse of `is_defined`.
- **Usage**: condition-only, like `is_defined` (use inside `if (...)`).
- **Example**: over `/(\w+)/`, `if (is_undefined(array(entry_group(0))[9])) { return("missing") } else { return("present") }` on `hi` → `["missing"]` (index 9 is out of range, so the read is undef).

### `trim(s)`
- **Signature**: `trim(value: scalar)`
- **Returns**: scalar
- **Behavior**: Removes leading and trailing whitespace. Returns undef if input is undef.
- **Edge cases**: A string of only whitespace becomes `""`.
- **Example**:
  ```text
  demo::  -> value  .push
  LX { return(copy(array(demo))) }

  value : /\[([^\]]*)\]/  I.return( trim(entry_group(0)) )
  ```
  Input `[  hello  ]` → `["hello"]` (capture group `0` is the bracketed, padded text).

### `lowercase(s)`
- **Signature**: `lowercase(value: scalar)`
- **Returns**: scalar
- **Behavior**: Applies Unicode 17.0.0 full Default Lowercase (R2), locale-independent, including contextual
  `Final_Sigma`, with no implicit normalization. Returns undef if input is undef.
- **Example**: `lowercase("ΟΣ")` → `"ος"`; `lowercase("İ")` → `"i\u{0307}"`.

### `uppercase(s)`
- **Signature**: `uppercase(value: scalar)`
- **Returns**: scalar
- **Behavior**: Applies Unicode 17.0.0 full Default Uppercase (R1), locale-independent, with expansion and no
  implicit normalization. Returns undef if input is undef.
- **Example**: `uppercase("Straße ﬃ")` → `"STRASSE FFI"`.

### `length(s)`
- **Signature**: `length(value: scalar|array)`
- **Returns**: int
- **Behavior**: Returns the character length of a string or the element count of an array. Returns undef for undef input.
- **Example**: over `/(\w+)/`, `length(entry_group(0))` on `hello` → `[5]`.

### `matches(s, /pattern/)`
- **Signature**: `matches(value: scalar, pattern: regex)`
- **Returns**: boolean
- **Behavior**: Returns true if the value matches the regex pattern. The pattern is a literal `/regex/` — no variable interpolation.
- **Regex flags**: `i`, `m`, `s`, and `x` affect compilation. Operation-only `g` and Perl compile-once `o` are
  accepted compile-time no-ops. Unknown flags or invalid patterns return false.
- **Edge cases**: Returns false for undef input.
- **Example**: over `/(\w+)/`, `matches(entry_group(0), /^\d+$/)` returns `[1]` on `123` and `[0]` on `abc`.

### `starts_with(s, prefix)`
- **Signature**: `starts_with(value: scalar, prefix: scalar)`
- **Returns**: boolean
- **Behavior**: Returns true if the value starts with the exact prefix string.
- **Example**: over `/(\S+)/`, `starts_with(entry_group(0), "foo")` on `foobar` → `[1]`.

### `ends_with(s, suffix)`
- **Signature**: `ends_with(value: scalar, suffix: scalar)`
- **Returns**: boolean
- **Behavior**: Returns true if the value ends with the exact suffix string.
- **Example**: over `/(\S+)/`, `ends_with(entry_group(0), "bar")` on `foobar` → `[1]`.

### `contains_substr(s, needle)`
- **Signature**: `contains_substr(value: scalar, needle: scalar)`
- **Returns**: boolean
- **Behavior**: Returns true if the value contains the needle as a substring.
- **Example**: over `/(\S+)/`, `contains_substr(entry_group(0), "oob")` on `foobar` → `[1]`.

### `replace_substr(s, old, new)`
- **Signature**: `replace_substr(value: scalar, old: scalar, new: scalar)`
- **Returns**: scalar
- **Behavior**: Replaces all literal occurrences of `old` with `new`. Returns undef if value is undef. This is a **literal** replacement, not a regex substitution.
- **Edge cases**: If `old` is empty, returns the value unchanged.
- **Example**: over `/(\S+)/`, `replace_substr(entry_group(0), "-", "_")` on `a-b-c` → `["a_b_c"]`.

### `rm_prefix(s, prefix)`
- **Signature**: `rm_prefix(value: scalar, prefix: scalar)`
- **Returns**: scalar
- **Behavior**: Removes the prefix from the value if present. Returns the value unchanged if the prefix does not match. Returns undef if value is undef.
- **Example**: over `/(\S+)/`, `rm_prefix(entry_group(0), "lib")` on `libparser` → `["parser"]`.

### `rm_suffix(s, suffix)`
- **Signature**: `rm_suffix(value: scalar, suffix: scalar)`
- **Returns**: scalar
- **Behavior**: Removes the suffix from the value if present. Returns the value unchanged if the suffix does not match. Returns undef if value is undef.
- **Example**: over `/(\S+)/`, `rm_suffix(entry_group(0), ".spec")` on `parser.spec` → `["parser"]`.

### `substr(s, start, length?)`
- **Signature**: `substr(value: scalar, start: int, length: int?)`
- **Returns**: scalar
- **Behavior**: Returns a substring of `value` starting at zero-based `start`. When `length` is supplied,
  returns at most that many characters; when omitted, returns from `start` through the end.
- **Edge cases**: Returns undef if `value` or `start` is undef. Negative or non-integer `start` is normalized
  to `0`; negative or non-integer `length` is normalized to `0`.
- **Example**: over `/(\S+)/`, `substr(entry_group(0), 1, 3)` on `abcdef` → `["bcd"]`.

### `substr(target, pattern, replacement, flags)` / `regex_subst(...)`
- **Signature**: `substr(target, pattern: regex-or-scalar, replacement: scalar, flags: scalar)` or
  `regex_subst(target, pattern, replacement, flags)`
- **Returns**: no value; mutates the named scalar target.
- **Behavior**: Applies regex substitution to the current scalar target value. `g` performs global replacement;
  `i`, `m`, `s`, and `x` are regex flags; `o` is accepted as a compatibility no-op. Replacement strings can use
  `$0` for the whole match and numbered capture references such as `$1`.
- **Boundary**: This is the legacy statement-style mutation form used by shipped specs. It is intentionally
  separate from pure `substr(value, start, length?)` character slicing and from literal `replace_substr(...)`.
- **Example**: `substr(value, '"|\s', "", go)` removes quotes and whitespace from `value` in place. Single quotes
  keep the embedded double quote readable; the equivalent double-quoted pattern remains valid.

### `split(array(target), source, delimiter)`
- **Signature**: `split(array(target), source: scalar, delimiter: regex-or-scalar)`
- **Returns**: no value; replaces the named explicit array target.
- **Behavior**: Uses the same literal, regex, Unicode-empty-delimiter, and empty-field policy as pure
  `split(source, delimiter)`, then stores a copied typed array. The source scalar is not mutated.
- **Boundary**: Mutation requires both dropped-statement context and the explicit `array(target)` wrapper. An
  ordinary dropped split call is simply a discarded pure expression.

### String receiver-dot value chains
- **Signature**: `string_expr.method(args...).next(args...)`
- **Returns**: the documented return value of the final helper in the chain.
- **Behavior**: A compatible string receiver feeds into the first pure string helper, and each helper's return
  value feeds the next compatible helper. A bare receiver such as `raw.trim()` reads the scalar working
  variable `raw`; an explicit receiver such as `raw.trim()` has the same value. String literals may
  be receivers too: `"abcdef".substr(1, 3).uppercase()` is equivalent to
  `uppercase(substr("abcdef", 1, 3))`.
- **Allowed string-returning links**: `trim`, `lowercase`, `uppercase`, `replace_substr`, `rm_prefix`,
  `rm_suffix`, `substr`, `cat`, and `coalesce_nonempty`. The old `concat` spelling is retired.
- **Allowed array bridge**: `split(delim)` returns an array and may continue through compatible array
  receiver helpers, for example `raw.trim().split("-").trim_each().lowercase_each().join_values("|")`.
- **Allowed terminal links**: `length`, `starts_with`, `ends_with`, `contains_substr`, and `matches` return
  number/boolean values and end the string-family chain.
- **Boundary**: `substr(value, start, length?)` here is the pure value substring helper. It is separate from
  any statement-style or host-language substitution idiom. A terminal string method followed by another
  receiver-dot call yields `undef` rather than a partially lowered host expression.
- **Block receivers**: An expression-valued block whose value is a string can be the receiver, for example
  `{ " a-b " }.trim().split("-").count()`.

## 3. Array Helpers

> **Worked examples.** Array examples use the same complete two-rule scaffold as the
> Scalar/Numeric examples:
>
> ```text
> demo::
>  -> value .push
>  LX { return(copy(array(demo))) }
>
> value : /<regex>/
>  I { return(<array-expression>) }
> ```
>
> The top `demo::` rule has no regex; it dispatches to the regex-owning `value:` rule,
> pushes the child value, and returns the accumulator snapshot. Outputs below are therefore
> one-element arrays holding the helper result. Multi-statement examples use the same
> scaffold but put the shown statements inside the `I { ... }` block.

**Verified value examples:**

| Surface | Example | Input | Output |
| --- | --- | --- | --- |
| Construct | `array(entry_group(0), entry_group(1), entry_group(2))` over `/(\w+),(\w+),(\w+)/` | `a,b,c` | `[["a","b","c"]]` |
| Copy | `copy(array(entry_group(0), entry_group(1), entry_group(2)))` over `/(\w+),(\w+),(\w+)/` | `a,b,c` | `[["a","b","c"]]` |
| Splice | `array("tag", flat_array(array(entry_group(0), entry_group(1))))` over `/(\w+),(\w+)/` | `a,b` | `[["tag","a","b"]]` |
| Concatenate | `concat_arrays(array(entry_group(0), entry_group(1)), array(entry_group(2)))` over `/(\w+),(\w+),(\w+)/` | `a,b,c` | `[["a","b","c"]]` |
| Count/select | `count(array(entry_group(0), entry_group(1), entry_group(2)))` / `first(...)` / `last(...)` | `a,b,c` | `[3]` / `["a"]` / `["c"]` |
| Edge slices | `take(..., 2)` / `take_last(..., 2)` / `drop_front(..., 1)` / `drop_back(..., 1)` / `slice(..., 1, 2)` | `a,b,c` | `[["a","b"]]` / `[["b","c"]]` / `[["b","c"]]` / `[["a","b"]]` / `[["b","c"]]` |
| Order | `sorted(array("b", "a", "c"))` / `reversed(array("a", "b", "c"))` | `x` | `[["a","b","c"]]` / `[["c","b","a"]]` |
| Membership | `contains(array("a", "b", "c"), "b")` / `index_of(array("a", "b", "c"), "b")` / missing `index_of(..., "z")` | `x` | `[1]` / `[1]` / `[null]` |
| Emptiness | `is_empty([])` / `is_nonempty(["a"])` | `x` | `[1]` / `[1]` |
| Join | `join_values(",", array("a", "b", "c"))` | `x` | `["a,b,c"]` |
| Split bridge | `entry_group(0).split(",")` over `/(.+)/` | `a,b,c` | `[["a","b","c"]]` |
| Receiver chain | `items.sorted().drop_front(1).first()` after `set(array(items), ["b", "a", "b", "c"])` | `x` | `["b"]` |
| Pipeline receiver | `items.trim_each().filter_nonempty().join_values("|")` after `set(array(items), [" a ", "", " b "])` | `x` | `["a|b"]` |

**Verified mutation/pipeline examples:**

| Body inside `value`'s `I { ... }` block | Input | Output |
| --- | --- | --- |
| `set(source, entry_group(0)); split(array(items), source, /,/); return(copy(array(items)))` over `/(.+)/` | `a,b,c` | `[["a","b","c"]]` |
| `set(array(items), ["a:b", "c:d"]); split_each(array(items), ":"); return(copy(array(items)))` | `x` | `[["a","b","c","d"]]` |
| `set(array(items), [" a ", " b"]); trim_each(array(items)); return(copy(array(items)))` | `x` | `[["a","b"]]` |
| `set(array(items), ["a", "", undef, "0", "b"]); filter_nonempty(array(items)); return(copy(array(items)))` | `x` | `[["a","0","b"]]` |
| `set(array(items), ["alpha", "beta", "atom"]); filter_match(array(items), /^a/); return(copy(array(items)))` | `x` | `[["alpha","atom"]]` |
| `set(array(items), ["a", "b", "a", "c", "b"]); uniq(array(items)); return(copy(array(items)))` | `x` | `[["a","b","c"]]` |
| `set(array(items), ["A", "bC"]); lowercase_each(array(items)); return(copy(array(items)))` | `x` | `[["a","bc"]]` |
| `set(array(items), ["a", "bC"]); uppercase_each(array(items)); return(copy(array(items)))` | `x` | `[["A","BC"]]` |
| `set(value, entry_group(0)); push(array(items), value); items += "tail"; return(copy(array(items)))` over `/(\w+)/` | `head` | `[["head","tail"]]` |
| `set(value, entry_group(0)); if(is_nonempty(value)) { push(array(items), value) }; set(value, ""); if(is_nonempty(value)) { push(array(items), value) }; return(copy(array(items)))` over `/(\w+)/` | `keep` | `[["keep"]]` |

> **Current Perl caveats.** For `split(value, delim)`, prefer receiver form
> `value.split(delim)` or block form `I { return(split(value, delim)) }`. Compact
> lifecycle shorthand `I.return(split(...))` currently routes through an older tagged
> shorthand shape on the Perl reference. For array pipeline helpers (`split_each`,
> `trim_each`, `filter_nonempty`, `lowercase_each`, `uppercase_each`, `uniq`, and
> `filter_match`), return a receiver chain (`items.trim_each()`) or assign/copy the
> named target as shown above; a direct `return(split_each(array(items), ":"))` is
> shape-sensitive on current Perl and does not document the portable array value.

### `array(e1, e2, ...)`
- **Signature**: `array(elements: expr...)`
- **Returns**: array
- **Behavior**: Constructs a new array from the given elements. Elements are evaluated in order.

### `array_copy(arr)`
- **Signature**: `array_copy(arr: array)`
- **Returns**: array
- **Behavior**: Returns a shallow copy of the array. The new array contains the same elements but is a distinct container.
- **Compatibility**: `array_values(...)` and `array_copy(...)` are retired on current runtimes — use `copy(...)`.
- **Terse spelling**: `copy(arr)` is the canonical spelling — one unified `copy(...)` subsumes both legacy array and hash copy forms, resolving array-vs-hash by the wrapped symbol kind (array first). See [Terse Helper Renames](#terse-helper-renames-canonical-going-forward).

### `flat_array(arr)`
- **Signature**: `flat_array(arr: array)`
- **Returns**: list (splices into parent context)
- **Behavior**: Flattens an array into list context for insertion into a parent container. Used with `hash(...)`, `array(...)`, and lifecycle accumulator returns.

### `concat_arrays(a1, a2)`
- **Signature**: `concat_arrays(a: array, b: array)`
- **Returns**: array
- **Behavior**: Returns a new array containing all elements of `a1` followed by all elements of `a2`. Neither input is mutated.

### `push(Child)` / `push(Child, target)`
- **Signature**: `push(child_rule: rule[, target: array])`
- **Returns**: void
- **Behavior**: Calls `Child` and appends the child result to an accumulator array. With one argument, the target is the current rule's implicit accumulator; with a second bare identifier, that identifier is the target accumulator.
- **Convention**: The all-bare child-call forms keep precedence: `push(Child)`, `push(Child, target)`, `push(Child, index)`, and `push(Child, target, index)` are parser child-call helpers.
- **Action-edge fluent form**: after `-> Child`, `.push(target)` uses the edge's `Child` as the child rule and appends its return value to `target`; `.push(Child, target)` is the explicit child-and-target spelling used inside gated fluent chains.

### `push(Child, index)` / `push(Child, target, index)`
- **Signature**: `push(child_rule: rule, index: int)` or `push(child_rule: rule, target: array, index: int)`
- **Returns**: void
- **Behavior**: Calls `Child`, selects one element from the child result, and appends that element to the implicit or explicit accumulator.
- **Edge cases**: The disambiguation relies on integer matching before bare target-name matching. `push(Child, 0)` means index 0 into `Child`'s result; `push(Child, target, 0)` appends index 0 to `target`.

### `push(arr, value)`
- **Signature**: `push(target: array, value: expr)`
- **Returns**: void
- **Behavior**: Terse explicit-value append. Lowers identically to the legacy explicit-value append helper for unambiguous value expressions.
- **Examples**: `push(items, "a")`, `push(array(items), value)`, `push(array(items), cat("a", "b"))`, and `push(items, call(Child))`.
- **Disambiguation**: `push(A, B)` where both arguments are bare identifiers remains a child-call form (`A` is the child rule, `B` is the target accumulator). To append a working variable by bare name, use the operator form `items += value` or wrap the target as `push(array(items), value)`.

### `items += value`
- **Signature**: `target += value: expr`
- **Returns**: updated array snapshot in value positions; side-effect-only behavior when used as a statement.
- **Behavior**: Array append operator. Lowers/runs identically to explicit append forms, mutates the named working array, and reads a bare RHS identifier as a scalar working variable. In value positions it evaluates to the updated array snapshot after the push.
- **Examples**: `items += "a"`, `items += cat("a", "b")`, `items += value`, `items += value`.
- **Edge cases**: The target is still an array working variable and auto-exists as `@target`. A bare RHS such as `items += value` reads `$value`; reserved literals such as `true`, `false`, and `undef` keep their literal meaning.

### `items.push_back(value)` / `items.push_front(value)` / `items.pop_back()` / `items.pop_front()`
- **Signature**: `target.push_back(value: expr)`, `target.push_front(value: expr)`, `target.pop_back()`, `target.pop_front()`
- **Returns**: void
- **Behavior**: Statement-level array end mutations on a named working array. `push_back` appends, `push_front` prepends, `pop_back` removes the last element, and `pop_front` removes the first element. Pop methods discard the removed value.
- **Examples**: `items.push_back("tail")`, `items.push_front(value)`, `array(items).pop_back()`, `array(items).pop_front()`.
- **Edge cases**: The receiver may be a bare array working variable (`items`) or an explicit array receiver (`array(items)`), and it auto-exists as an array. A bare push value reads a scalar working variable, just like `items += value`. These are statement-only mutations; value-returning forms such as `return(items.pop_back())` are outside this contract.
- **Worked example**:
  ```text
  Top::
   -> Done {
    set(value, "b")
    items.push_back("a")
    items.push_back(value)
    items.push_front("z")
    items.pop_back()
    items.pop_front()
    return(copy(array(items)))
   }

  Done:
   /[a-z]+/
  ```
  On input `xhello`, the result is `["a"]`: the push methods build `["z", "a", "b"]`, then `pop_back()`
  removes `"b"` and `pop_front()` removes `"z"`.

### `count(arr)`
- **Signature**: `count(arr: array)`
- **Returns**: int
- **Behavior**: Returns the number of elements in the array. Returns undef for non-array or undef input.

### `first(arr)`
- **Signature**: `first(arr: array)`
- **Returns**: scalar
- **Behavior**: Returns the first element. Returns undef for empty array or non-array input.

### `last(arr)`
- **Signature**: `last(arr: array)`
- **Returns**: scalar
- **Behavior**: Returns the last element. Returns undef for empty array or non-array input.

### `take(arr, n)`
- **Signature**: `take(arr: array, n: int = 1)`
- **Returns**: array
- **Behavior**: Returns the first `n` elements as a new array. When `n` is omitted, returns the first element as an array.
- **Edge cases**: If `n` > array length, returns the entire array. Returns undef for non-array input.

### `take_last(arr, n)`
- **Signature**: `take_last(arr: array, n: int = 1)`
- **Returns**: array
- **Behavior**: Returns the last `n` elements as a new array.
- **Edge cases**: If `n` > array length, returns the entire array.

### `drop_front(arr, n)`
- **Signature**: `drop_front(arr: array, n: int = 1)`
- **Returns**: array
- **Behavior**: Returns a new array with the first `n` elements removed. When `n` is omitted, drops 1 element.
- **Compatibility**: `tail(...)` is a retired alias.

### `drop_back(arr, n)`
- **Signature**: `drop_back(arr: array, n: int = 1)`
- **Returns**: array
- **Behavior**: Returns a new array with the last `n` elements removed.
- **Compatibility**: `drop_last(...)` is a retired alias.

### `slice(arr, start, n)`
- **Signature**: `slice(arr: array, start: int, n: int?)`
- **Returns**: array
- **Behavior**: Returns elements from index `start`. When `n` is provided, returns up to `n` elements. When `n` is omitted, returns from `start` to the end.
- **Edge cases**: If `start` exceeds array length, returns empty array.

### `sorted(arr)`
- **Signature**: `sorted(arr: array)`
- **Returns**: array
- **Behavior**: Returns a new array sorted in ascending (string/lexicographic) order. Does not mutate the input.

### `reversed(arr)`
- **Signature**: `reversed(arr: array)`
- **Returns**: array
- **Behavior**: Returns a new array in reverse order. Does not mutate the input.

### `array(name)` / `array(e1, e2, ...)`
- **Signature**: `array(name: name-token)` or `array(values: expr...)`
- **Returns**: array
- **Behavior**: With exactly one bare name token, reads the named array/list working variable:
  `array(items)` reads the working array `items`. Quoted strings are literal constructor payloads, so
  `array("items")` constructs an array containing the string `"items"`. With zero or multiple arguments it
  constructs an array from the evaluated values.
- **Boundary**: The bare one-argument name form is a direct working-variable name, not an indirect scalar
  lookup. `array(alias)` reads the working array named `alias`; it does not read scalar `alias` and then use
  that scalar as another variable name. Prefer direct shape literals such as `["items"]` as the terse
  constructor spelling in new examples.

### Array receiver-dot value chains
- **Signature**: `array_expr.method(args...).next(args...)`
- **Returns**: the documented return value of the final helper in the chain.
- **Behavior**: A compatible array receiver feeds into verified array helper chains. Pure array links compose
  through later pure links and terminals, for example `items.sorted().drop_front(2).first()` is equivalent to
  `first(drop_front(sorted(items), 2))`. Pipeline links compose through pipeline/terminal continuations that are
  locked by the runtime, for example `items.uniq().join_values(",")` and
  `phrases.split_each("-").filter_match(/^aa$/).count()`.
- **Allowed array-returning links**: `copy`, `sorted`, `reversed`, `take`, `take_last`,
  `drop_front`, `drop_back`, `slice`, `concat_arrays`, `split_each`, `trim_each`, `filter_nonempty`,
  `lowercase_each`, `uppercase_each`, `uniq`, and `filter_match`.
- **Allowed terminal links**: `count`, `first`, `last`, `contains`, `index_of`, `is_empty`, `is_nonempty`,
  `join_values`, `sum`, `avg`, `median`, `range`, `min`, and `max`. Receiver-dot
  `items.join_values(delim)` keeps the helper's canonical delimiter-first contract: it maps to
  `join_values(delim, items)`. Receiver-dot numeric reducers such as `scores.sum()` and `scores.min()` are
  array-consuming terminal links over the same numeric aggregate helper family.
- **Boundary**: `split(value, delim)` belongs to the scalar/string receiver family because its receiver is the
  string being split. Numeric reducer terminals do not continue through later array methods; compose the helper
  form explicitly when another numeric operation is needed. Statement-only end mutations (`push_back`,
  `push_front`, `pop_back`, `pop_front`) remain mutations, not value-chain links. The portable contract does not
  promise every possible pipeline-to-pure continuation; use verified chains such as
  `items.uniq().join_values(",")`, `items.filter_match(/^a/).count()`, or pure chains such as
  `items.sorted().drop_front(1).first()`.
- **Block receivers**: An expression-valued block whose value is an array can be the receiver, for example
  `{ [3, 1, 2] }.sorted().join_values(",")`. A block-local `return(array_expr)` yields the receiver value and
  skips later block statements before the array chain runs.

### Array-tree receiver block traversal: `walk_leaves`, `map_leaves`, `reduce_leaves`
- **Signatures**:
  - `array_expr.walk_leaves() { block }`
  - `array_expr.map_leaves() { block }`
  - `array_expr.reduce_leaves(initial_acc: expr) { block }`
- **Returns**:
  - `walk_leaves` returns the original array tree after running callbacks.
  - `map_leaves` returns a new array tree with the same nested-array structure and each leaf replaced by the
    callback result.
  - `reduce_leaves` returns the final accumulator.
- **Backend status**: Perl reference support landed under `SPEC-FORMAT-TERSE.13.2`; Rust interpreter and
  generated-oracle parity landed under `SPEC-FORMAT-TERSE.13.3`.
- **Tree shape**: The receiver must be an array. Nested arrays are interior nodes. Scalar values and hash values
  are leaves; hash values are not traversed recursively by this surface.
- **Traversal order**: Depth-first by zero-based array index. For `["a", ["b", "c"], { "h" : "H" }]`, callbacks
  run for paths `0`, `1/0`, `1/1`, then `2`.
- **Callback bindings**: Each callback runs immediately in the caller's current action/runtime context with scoped
  scalar bindings:
  - `value`: current leaf value.
  - `index`: zero-based index of the leaf in its parent array.
  - `path`: array value containing root-to-leaf indexes.
  - `depth`: number of path segments.
  - `acc`: current accumulator for `reduce_leaves` only.
- **Binding restoration**: The traversal restores those scoped names after each callback and after traversal
  completes. Mutations to other working variables are ordinary side effects and persist.
- **Edge cases**: A non-array/non-hash scalar receiver yields `undef` and does not execute the callback. Empty
  arrays run no callbacks; `reduce_leaves(initial)` returns the initial accumulator. `walk_leaves()` and
  `map_leaves()` take no parenthesized arguments. `reduce_leaves(initial)` requires exactly one parenthesized
  initial accumulator expression. `walk_leaves()` and `map_leaves()` can feed later compatible array receiver links
  such as `.count()`. `reduce_leaves(...)` is terminal.
- **Examples**:
  - After `set(array(items), ["a", ["b", "c"]])`,
    `return(items.map_leaves() { return(cat(join_values("/", array(path)), "=", value)) })`
    yields `[["0=a",["1/0=b","1/1=c"]]]` through the standard `demo::` wrapper.
  - After `set(array(items), ["a", ["b", "c"]])`,
    `set(out, items.walk_leaves() { paths += join_values("/", array(path)); return(value) }); return(copy(array(paths)))`
    yields `[["0","1/0","1/1"]]`.
  - After `set(array(items), ["a", ["b", "c"]])`,
    `return(items.reduce_leaves(0) { return(acc.add(1)) })` yields `[3]`.
  - `return(items.map_leaves() { return(value) }.count())` yields `[2]`: the top-level mapped array has two
    elements, even though traversal visited three leaves.

### `contains(arr, needle)`
- **Signature**: `contains(arr: array, needle: scalar)`
- **Returns**: boolean
- **Behavior**: Returns true if the array contains the needle value. Works on direct arrays and projected expressions (`sorted_keys(...)`, `sorted_values(...)`).
- **Edge cases**: Returns false for non-array or undef input.

### `index_of(arr, needle)`
- **Signature**: `index_of(arr: array, needle: scalar)`
- **Returns**: int or undef
- **Behavior**: Returns the 0-based index of the first match. Returns `0` when the match is at the first position. Returns `undef` for missing, non-array, or no-match cases.

### `is_empty(arr)`
- **Signature**: `is_empty(value: array|hash|expr)`
- **Returns**: boolean
- **Behavior**: Returns true if the array or hash has zero elements. Treats composed array-valued and hash-valued expressions as aggregates, not Perl references.
- **Edge cases**: Returns true for undef (treated as empty).

### `is_nonempty(arr)`
- **Signature**: `is_nonempty(value: array|hash|expr)`
- **Returns**: boolean
- **Behavior**: Logical inverse of `is_empty`. True if the aggregate has at least one element.

### `join_values(delim, arr)`
- **Signature**: `join_values(delim: scalar, arr: array)`
- **Returns**: scalar
- **Behavior**: Joins array elements into a string with the delimiter between each element. Accepts composed array-valued expressions.
- **Edge cases**: Returns empty string for empty array. Returns undef for non-array input.

### `split(s, delim)`
- **Signature**: `split(value: scalar, delim: scalar)`
- **Returns**: array
- **Behavior**: Splits a string on the delimiter, returning an array of substrings.
- **Regex flags**: Regex delimiters preserve `i`, `m`, `s`, and `x`; operation-only `g` and Perl compile-once `o`
  are accepted compile-time no-ops. Unknown flags or invalid patterns return an empty array.
- **Examples**: over `/(.+)/`, `entry_group(0).split(",")` on `a,b,c` → `[["a","b","c"]]`.
  `count(entry_group(0).split(","))` on the same input → `[3]`.
- **Current Perl caveat**: use receiver form (`value.split(delim)`) or block form
  `I { return(split(value, delim)) }` in runnable examples. Compact `I.return(split(...))`
  currently surfaces an older tagged shorthand shape in the Perl reference.

### `split(array(target), source, delimiter)`
- **Signature**: `split(array(target), source, delimiter: regex-or-scalar)`
- **Returns**: no value; mutates the named array target.
- **Behavior**: Splits `source` on `delimiter` and replaces `target` with the resulting list. Regex delimiters
  split by regex match; scalar delimiters split literally.
- **Boundary**: This statement-style array pipeline helper is separate from pure `split(value, delim)`, which
  returns an array value for expression and receiver-chain use.

### `split_each(arr, delim)`
- **Signature**: `split_each(arr: array, delim: scalar)`
- **Returns**: array
- **Behavior**: Splits each element of the array on the delimiter. Results are concatenated into a single flat array.
- **Example**: after `set(array(items), ["a:b", "c:d"])`, `return(items.split_each(":"))`
  yields `[["a","b","c","d"]]`.

### `trim_each(arr)`
- **Signature**: `trim_each(arr: array)`
- **Returns**: array
- **Behavior**: Trims whitespace from each element of the array.
- **Example**: after `set(array(items), [" a ", " b"])`, `return(items.trim_each())`
  yields `[["a","b"]]`.

### `filter_nonempty(arr)`
- **Signature**: `filter_nonempty(arr: array)`
- **Returns**: array
- **Behavior**: Returns a new array with empty/undef elements removed.
- **Example**: after `set(array(items), ["a", "", undef, "0", "b"])`,
  `return(items.filter_nonempty())` yields `[["a","0","b"]]`.

### `filter_match(arr, /pattern/)`
- **Signature**: `filter_match(arr: array, pattern: regex)`
- **Returns**: array
- **Behavior**: Returns elements matching the regex pattern.
- **Example**: after `set(array(items), ["alpha", "beta", "atom"])`,
  `return(items.filter_match(/^a/))` yields `[["alpha","atom"]]`.

### `uniq(arr)`
- **Signature**: `uniq(arr: array)`
- **Returns**: array
- **Behavior**: Returns a new array with duplicates removed. Order of first occurrence is preserved.
- **Example**: after `set(array(items), ["a", "b", "a", "c", "b"])`,
  `return(items.uniq())` yields `[["a","b","c"]]`.

### `lowercase_each(arr)`
- **Signature**: `lowercase_each(arr: array)`
- **Returns**: array
- **Behavior**: Lowercases each element with the same Unicode 17 contract as `lowercase`.
- **Example**: after `set(array(items), ["A", "bC"])`, `return(items.lowercase_each())`
  yields `[["a","bc"]]`.

### `uppercase_each(arr)`
- **Signature**: `uppercase_each(arr: array)`
- **Returns**: array
- **Behavior**: Uppercases each element with the same Unicode 17 contract as `uppercase`.
- **Example**: after `set(array(items), ["a", "bC"])`, `return(items.uppercase_each())`
  yields `[["A","BC"]]`.

### `print_each(arr)`
- **Signature**: `print_each(arr: array)`
- **Returns**: void
- **Behavior**: Debug helper — prints each element to the trace/output channel. No return value.

## 4. Hash Helpers

> **Worked examples** use the same runnable two-rule scaffold as the Array section:
>
> ```text
> demo::
>  -> value .push
>  LX { return(copy(array(demo))) }
>
> value : /<regex>/
>  I { <statements>; return(<hash-or-derived-value>) }
> ```
>
> Outputs are the parser's accumulator array after `demo` pushes each `value` result.

**Verified value, mutation, and receiver examples:**

| Surface | Body inside `value`'s `I { ... }` block | Input | Output |
| --- | --- | --- | --- |
| Construct | `return(hash("b", 2, "a", 1))` | `x` | `[{"a":1,"b":2}]` |
| Explicit null value | `return(hash("a", 1, "missing", undef))` | `x` | `[{"a":1,"missing":null}]` |
| Splice count | `return(count(array(flat_hash(hash("a", 1, "b", 2)))))` | `x` | `[4]` |
| Copy snapshot | `set(hash(meta), { "a" : 1 }); set(hash(saved), copy(hash(meta))); meta["b"] = 2; return(array(count_keys(hash(meta)), count_keys(hash(saved))))` | `x` | `[[2,1]]` |
| Merge override | `return(merge_hash(hash("a", 1, "b", 2), hash("b", 9, "c", 3)))` | `x` | `[{"a":1,"b":9,"c":3}]` |
| Pure `set_key` | `set(hash(meta), { "a" : 1 }); return(array(meta.set_key("b", 2).count_keys(), count_keys(hash(meta))))` | `x` | `[[2,1]]` |
| Statement `set_key` | `set_key(meta, "a", 1); set_key(meta, "b", 2); return(copy(hash(meta)))` | `x` | `[{"a":1,"b":2}]` |
| Hash-index assignment | `key = "stage"; value = "ok"; meta[key] = value; return(copy(hash(meta)))` | `x` | `[{"stage":"ok"}]` |
| Rename/drop/pick | `return(rename_key(hash("old", 1, "keep", 2), "old", "new"))` / `return(drop_keys(hash("a", 1, "b", 2, "c", 3), "b", "c"))` / `return(pick_keys(hash("a", 1, "b", 2, "c", 3), "b", "missing"))` | `x` | `[{"keep":2,"new":1}]` / `[{"a":1}]` / `[{"b":2}]` |
| Membership/count | `return(array(has_key(hash("a", 1), "a"), has_key(hash("a", 1), "missing")))` / `return(count_keys(hash("a", 1, "b", 2)))` | `x` | `[[1,0]]` / `[2]` |
| Sorted views | `return(sorted_keys(hash("b", 2, "a", 1)))` / `return(sorted_values(hash("b", 2, "a", 1)))` | `x` | `[["a","b"]]` / `[[1,2]]` |
| Receiver chain | `set_key(meta, "b", 2); set_key(meta, "a", 1); return(meta.set_key("c", 3).sorted_keys().join_values(","))` | `x` | `["a,b,c"]` |
| Block receiver | `return({ { "b" : 2, "a" : 1 } }.sorted_keys().join_values(","))` | `x` | `["a,b"]` |
| Hash-tree map | `set(hash(meta), { "b" : { "y" : "B" }, "a" : "A" }); return(meta.map_leaves() { return(cat(join_values("/", array(path)), "=", value)) })` | `x` | `[{"a":"a=A","b":{"y":"b/y=B"}}]` |
| Hash-tree walk | `set(hash(meta), { "b" : { "y" : "B" }, "a" : "A" }); return(array(meta.walk_leaves() { paths += join_values("/", array(path)); return(value) }.count_keys(), array(paths)))` | `x` | `[[2,["a","b/y"]]]` |
| Hash-tree reduce | `set(hash(meta), { "b" : { "y" : "B" }, "a" : "A" }); return(meta.reduce_leaves("") { return(cat(acc, key)) })` | `x` | `["ay"]` |

> **Current Perl caveat.** Direct odd-arity constructor calls such as
> `hash("a", 1, "missing")` are not the portable "trailing undef" spelling on the
> current Perl reference; they lower to an unsupported-helper sentinel and return
> `undef` (`[null]` through this scaffold). Spell the missing value explicitly
> as `hash("a", 1, "missing", undef)`, or pass a list-valued splice such as
> `hash(flat_array(array("a", 1, "missing")))` when that list context is intended.

### `hash(k1, v1, k2, v2, ...)`
- **Signature**: `hash(keys_and_values: scalar...)`
- **Returns**: hash
- **Behavior**: With exactly one bare name token, reads the named hash/associative-array working variable:
  `hash(meta)` reads the working hash `meta`. Quoted strings are literal constructor payloads, so
  `hash("key", value)` constructs a hash entry whose key is `"key"`. With zero or multiple arguments it
  constructs a hash from flat key/value pairs. Arguments are interpreted as alternating keys and values. Accepts
  `flat_array(...)` and `flat_hash(...)` for list-context insertion.
- **Boundary**: The bare one-argument name form is a direct working-variable name, not an indirect scalar
  lookup. `hash(alias)` reads the working hash named `alias`; it does not read scalar `alias` and then use
  that scalar as another variable name. Prefer direct shape literals such as `{ "alias" : value }` as the
  terse constructor spelling in new examples.
- **Edge cases**: Duplicate keys: last value wins. Direct multi-argument constructor calls should pass paired
  key/value arguments; use an explicit `undef` value for a null-valued trailing key.

### `flat_hash(h)`
- **Signature**: `flat_hash(h: hash)`
- **Returns**: list (splices into parent context)
- **Behavior**: Flattens a hash into alternating key/value list context for insertion into `hash(...)` or `array(...)`.

### `hash_copy(h)`
- **Signature**: `hash_copy(h: hash)`
- **Returns**: hash
- **Behavior**: Shallow copy. The new hash has the same keys and values but is a distinct container.
- **Compatibility status**: Retired on current runtimes.
- **Terse spelling**: `copy(h)` / receiver `.copy()` is the unified canonical spelling (the same `copy(...)` that subsumes legacy array/hash copy helpers). See [Terse Helper Renames](#terse-helper-renames-canonical-going-forward).

### `merge_hash(h1, h2)`
- **Signature**: `merge_hash(base: hash, overlay: hash)`
- **Returns**: hash
- **Behavior**: Merges `h2` into `h1`. Keys in `h2` override keys in `h1`. Neither input is mutated — returns a new hash.

### `set_key(h, key, value)`
- **Signature**: `set_key(h: hash, key: string, value: expr)`
- **Returns**: hash
- **Behavior**: Returns a new hash with the key set to the value. Does not mutate the input.
- **Statement form**: `set_key(name, key, value)` mutates the named working hash `name` directly.
- **Operator form**: `name[key] = value` mutates the same named working hash directly, and yields the updated hash snapshot in value positions; bare key/RHS identifiers in the mutation slot read scalar working variables.

### `name[key] = value`
- **Signature**: `target[key_expr] = value_expr`
- **Returns**: updated hash snapshot in value positions; side-effect-only behavior when used as a statement.
- **Behavior**: Hash-index assignment. Mutates the named working hash `target` at the evaluated string key. Lowers and runs identically to `set_key(target, key_expr, value_expr)` for accepted key/value expressions, and evaluates to the updated hash snapshot when used as a value.
- **Examples**: `meta["stage"] = "normalized"`, `meta[cat("source", "_kind")] = kind`, `meta[field_name] = field_value`, `meta[field_name] = field_value`.
- **Edge cases**: The left side target is a bare hash target and auto-exists as a per-invocation working hash
  unless the name currently holds a scalar-bound array/hash value from bare assignment. In that scalar-held case,
  a single-segment assignment mutates the held root: hash keys update/create hash entries, while numeric array
  indexes replace or append at len. Bare key/RHS identifiers read scalar working variables in this mutation slot.
  Receiver-dot `meta.set_key(key, value)` remains pure copy-valued composition; use `meta[key] = value` when you
  want mutation.

### `rename_key(h, old, new)`
- **Signature**: `rename_key(h: hash, old_key: string, new_key: string)`
- **Returns**: hash
- **Behavior**: Returns a new hash with the key renamed. The value is preserved. If the old key does not exist, the hash is returned unchanged.

### `drop_keys(h, k1, k2, ...)`
- **Signature**: `drop_keys(h: hash, keys: string...)`
- **Returns**: hash
- **Behavior**: Returns a new hash with the named keys removed. Does not mutate the input.

### `pick_keys(h, k1, k2, ...)`
- **Signature**: `pick_keys(h: hash, keys: string...)`
- **Returns**: hash
- **Behavior**: Returns a new hash containing only the named keys. Does not mutate the input.

### `has_key(h, key)`
- **Signature**: `has_key(h: hash, key: string)`
- **Returns**: boolean
- **Behavior**: Returns true if the hash contains the named key.

### `count_keys(h)`
- **Signature**: `count_keys(h: hash)`
- **Returns**: int
- **Behavior**: Returns the number of keys in the hash. Returns undef for non-hash input.

### `sorted_keys(hash)`
- **Signature**: `sorted_keys(h: hash)`
- **Returns**: array
- **Behavior**: Returns the hash's keys as an array, sorted alphabetically. Deterministic — does not depend on host-language hash iteration order.

### `sorted_values(hash)`
- **Signature**: `sorted_values(h: hash)`
- **Returns**: array
- **Behavior**: Returns the hash's values as an array, sorted by their corresponding keys alphabetically. Deterministic.

### Hash receiver-dot value chains
- **Signature**: `hash_expr.method(args...).next(args...)`
- **Returns**: the documented return value of the final helper in the chain.
- **Behavior**: A compatible hash receiver feeds into the first pure hash helper, and each helper's return
  value feeds the next compatible helper. For example,
  `meta.set_key("stage", "normalized").count_keys()` is equivalent to
  `count_keys(set_key(hash(meta), "stage", "normalized"))`. `meta.sorted_keys().join_values(",")` first
  derives the sorted key array, then continues through the array receiver-chain family.
- **Allowed hash-returning links**: `copy`, `merge_hash`, `set_key`, `rename_key`, `drop_keys`,
  `pick_keys`, and `flat_hash`. `merge_hash` preserves the canonical helper contract: later arguments
  override earlier keys.
- **Allowed terminal/bridge links**: `sorted_keys` and `sorted_values` return arrays and may continue through
  compatible array receiver helpers. `count_keys` and `has_key` return number and boolean terminal values.
  Field reads from a named working hash use `hash(name).pick_keys(key).sorted_values().first()` after storing
  expression receivers in a named hash. Direct bracket reads such as `retv["key"]` are for scalar hashref
  payloads, not working-hash value reads.
- **Boundary**: `set_key(name, key, value)` and `name[key] = value` mutate the named working hash; hash-index
  assignment also yields the updated hash snapshot in value positions. Receiver-dot `meta.set_key(key, value)` is
  pure value composition; it mutates nothing unless its result is explicitly assigned back.
- **Block receivers**: An expression-valued block whose value is a hash can be the receiver, for example
  `{ { "b" : 2, "a" : 1 } }.sorted_keys().join_values(",")`.

### Hash-tree receiver block traversal: `walk_leaves`, `map_leaves`, `reduce_leaves`
- **Signatures**:
  - `hash_expr.walk_leaves() { block }`
  - `hash_expr.map_leaves() { block }`
  - `hash_expr.reduce_leaves(initial_acc: expr) { block }`
- **Returns**:
  - `walk_leaves` returns the original hash tree after running callbacks.
  - `map_leaves` returns a new hash tree with each leaf replaced by the callback result.
  - `reduce_leaves` returns the final accumulator.
- **Backend status**: Perl reference and Rust interpreter support are current.
- **Tree shape**: The receiver must be a hash. Nested hashes are interior nodes. Every non-hash value is a leaf,
  including arrays.
- **Traversal order**: Sorted-key depth-first traversal. For `{ "a" : "A", "arr" : ["u", "v"], "b" : { "y" : "B" } }`,
  callbacks run for paths `a`, `arr`, then `b/y`.
- **Callback bindings**: Each callback runs immediately in the caller's current action/runtime context with scoped
  scalar bindings:
  - `value`: current leaf value.
  - `key`: current leaf key.
  - `path`: array value containing root-to-leaf path segments.
  - `depth`: zero-based leaf depth.
  - `acc`: current accumulator for `reduce_leaves` only.
- **Binding restoration**: The traversal restores those scoped names after each callback and after traversal
  completes. Mutations to other working variables are ordinary side effects and persist.
- **Return semantics**: `return(expr)` inside the callback is block-local and supplies that callback's result. In
  `map_leaves`, the result replaces the current leaf. In `reduce_leaves`, the result becomes the next accumulator.
  In `walk_leaves`, the result is ignored.
- **Edge cases**: A non-hash receiver yields `undef` and does not execute the callback. `walk_leaves()` and
  `map_leaves()` take no parenthesized arguments. `reduce_leaves(initial)` requires exactly one parenthesized
  initial accumulator expression. `walk_leaves()` and `map_leaves()` return hash values and can feed later hash
  receiver links such as `.count_keys()`. `reduce_leaves(...)` is terminal. These are immediate receiver block
  methods, not closures or delayed callbacks.
- **Examples**:
  - After `set(hash(meta), { "b" : { "y" : "B" }, "a" : "A" })`,
    `return(meta.map_leaves() { return(cat(join_values("/", array(path)), "=", value)) })`
    yields `[{"a":"a=A","b":{"y":"b/y=B"}}]` through the standard `demo::` wrapper.
  - After `set(hash(meta), { "b" : { "y" : "B" }, "a" : "A" })`,
    `return(array(meta.walk_leaves() { paths += join_values("/", array(path)); return(value) }.count_keys(), array(paths)))`
    yields `[[2,["a","b/y"]]]`.
  - After `set(hash(meta), { "b" : { "y" : "B" }, "a" : "A" })`,
    `return(meta.reduce_leaves("") { return(cat(acc, key)) })` yields `["ay"]`.

## 5. Numeric Helpers

All numeric helpers return `undef` if any input is missing, non-numeric, wrong-arity, non-finite, or (for
division/modulo) a zero divisor, unless wrapped in `coalesce(...)`. Numeric inputs are finite numbers or untrimmed
decimal strings matching `-?(?:digits(?:.digits)?|.digits)`. Booleans, null, arrays, harrays, plus/exponent/hex,
surrounding-whitespace, and trailing-dot strings are not numeric. Comparisons return numeric `1`/`0` when valid and
`undef` when invalid. Rounding sends exact halves away from zero; signed integer modulo uses floor/Euclidean
remainder, so a nonzero result has the divisor's sign. These rules are versioned by
`capability_conformance/scalar_numeric_contract.json` rather than delegated to host arithmetic APIs.

`num_add`, `num_mul`, and scalar `num_min`/`num_max` accept two or more operands. `num_sub`, `num_div`, `num_mod`,
and numeric comparisons require exactly two; unary helpers exactly one; clamp exactly three. Array-form min/max
and aggregate reducers keep their one-array signatures below.

Number receiver-dot value chains are pure value composition over this same family. Receiver methods use terse
names and map to `num_*`: `value.abs()` -> `num_abs(value)`, `value.add(2, 3)` -> `num_add(value, 2, 3)`,
`value.clamp(0, 10)` -> `num_clamp(value, 0, 10)`, and `value.gt(3)` -> `num_gt(value, 3)`. Bare receiver
identifiers read scalar working variables. Integer and float literal receivers are accepted (`5.mod(2)`,
`3.5.floor().add(1)`). Comparisons (`eq`, `ne`, `gt`, `ge`, `lt`, `le`) are terminal boolean values; a later
receiver-dot call after a comparison returns `undef`/`null`. Statement and lifecycle methods are not numeric receiver methods. An expression-valued block whose value is numeric can be the
receiver, for example `{ 3.5 }.floor().add(2)`.

The same numeric family also has function-form word aliases:
`add`, `sub`, `mul`, `div`, `mod`, `abs`, `floor`, `ceil`, `round`, `min`,
`max`, `clamp`, `sum`, `avg`, `median`, `range`, `eq`, `ne`, `gt`, `ge`, `lt`,
and `le`. These are exact aliases for the corresponding `num_*` helpers.
Arithmetic symbol callees are accepted as the same ordinary call form for the
arithmetic subset: `+(a, b)`, `-(a, b)`, `*(a, b)`, `/(a, b)`, and `%(a, b)`
map to `num_add`, `num_sub`, `num_mul`, `num_div`, and `num_mod`. These aliases
remain ordinary `callee(args)` calls, so there is no operator precedence; write
`+(*(a, b), c)` when you need explicit grouping. Comparison symbol callees are
accepted as numeric aliases too: `==(a, b)`, `!=(a, b)`, `>(a, b)`, `>=(a, b)`,
`<(a, b)`, and `<=(a, b)` map to the corresponding `num_*` comparison helpers.
The shipped explicit string bridge names are `str_eq`, `str_ne`, `str_gt`,
`str_ge`, `str_lt`, and `str_le`; use them for lexical string comparisons.

> **Worked examples** use the same runnable two-rule shape as §2 (a top `::` entry rule
> — no regex — dispatching to a `value` rule that carries the regex and reads
> `entry_group(N)`; output = the parser's one-element accumulator array). The array-form
> reducers (`num_sum`, `num_avg`, `num_median`, `num_range`, and the array form of
> `num_min`/`num_max`) take an array of numeric values: use explicit `array(...)` in function form, or a
> compatible array receiver such as `scores.sum()` / `scores.min()`. Build literal arrays from
> capture groups (`array(entry_group(0), entry_group(1), …)`) or numeric literals. An
> `undef` result (e.g. divide-by-zero) surfaces as a `null` element.

### `num_add(a, b)`
- **Signature**: `num_add(a: numeric, b: numeric)`
- **Returns**: numeric
- **Behavior**: Adds two numbers. Returns `undef` if either operand is non-numeric.
- **Example**:
  ```text
  demo::  -> value  .push
  LX { return(copy(array(demo))) }

  value : /(\d+)\+(\d+)/  I.return( num_add(entry_group(0), entry_group(1)) )
  ```
  Input `2+3` → `[5]`.

### `num_sub(a, b)`
- **Signature**: `num_sub(a: numeric, b: numeric)`
- **Returns**: numeric
- **Behavior**: Subtracts `b` from `a`.
- **Example**: over `/(\d+)-(\d+)/`, `num_sub(entry_group(0), entry_group(1))` on `10-4` → `[6]`.

### `num_mul(a, b)`
- **Signature**: `num_mul(a: numeric, b: numeric)`
- **Returns**: numeric
- **Behavior**: Multiplies two numbers.
- **Example**: over `/(\d+)x(\d+)/`, `num_mul(entry_group(0), entry_group(1))` on `6x7` → `[42]`.

### `num_div(a, b)`
- **Signature**: `num_div(a: numeric, b: numeric)`
- **Returns**: numeric
- **Behavior**: Divides `a` by `b`. Returns `undef` on divide-by-zero.
- **Example**: over `/(\d+)\/(\d+)/`, `num_div(entry_group(0), entry_group(1))` gives `[5]` on `20/4`, `[3.5]` on `7/2`, and `[null]` on `5/0`.

### `num_mod(a, b)`
- **Signature**: `num_mod(a: numeric, b: numeric)`
- **Returns**: int
- **Behavior**: Modulo operation. Returns `undef` for divide-by-zero or non-integer operands.
- **Example**: over `/(\d+)%(\d+)/`, `num_mod(entry_group(0), entry_group(1))` on `17%5` → `[2]`.

### `num_abs(x)`
- **Signature**: `num_abs(x: numeric)`
- **Returns**: numeric
- **Behavior**: Absolute value.
- **Example**: over `/(-?\d+)/`, `num_abs(entry_group(0))` on `-7` → `[7]`.

### `num_floor(x)`
- **Signature**: `num_floor(x: numeric)`
- **Returns**: int
- **Behavior**: Floor — largest integer ≤ x.
- **Example**: over `/([\d.]+)/`, `num_floor(entry_group(0))` on `3.7` → `[3]`.

### `num_ceil(x)`
- **Signature**: `num_ceil(x: numeric)`
- **Returns**: int
- **Behavior**: Ceiling — smallest integer ≥ x.
- **Example**: over `/([\d.]+)/`, `num_ceil(entry_group(0))` on `3.2` → `[4]`.

### `num_round(x)`
- **Signature**: `num_round(x: numeric)`
- **Returns**: int
- **Behavior**: Rounds to nearest integer (half-up).
- **Example**: over `/([\d.]+)/`, `num_round(entry_group(0))` on `3.5` → `[4]`.

### `num_min(a, b)` / `num_min(arr)`
- **Signature**: `num_min(a: numeric, b: numeric)` or `num_min(arr: array)`
- **Returns**: numeric
- **Behavior**: Two-argument form: returns the smaller of two numbers. Array form: returns the minimum element. Returns `undef` for empty array, non-array, or non-numeric elements.
- **Example**: 2-arg — over `/(\d+),(\d+)/`, `num_min(entry_group(0), entry_group(1))` on `8,3` → `[3]`. Array — over `/(\d+),(\d+),(\d+),(\d+)/`, `num_min(array(entry_group(0), entry_group(1), entry_group(2), entry_group(3)))` on `8,3,5,1` → `[1]`.

### `num_max(a, b)` / `num_max(arr)`
- **Signature**: `num_max(a: numeric, b: numeric)` or `num_max(arr: array)`
- **Returns**: numeric
- **Behavior**: Two-argument form: returns the larger. Array form: returns the maximum element.
- **Example**: 2-arg — over `/(\d+),(\d+)/`, `num_max(entry_group(0), entry_group(1))` on `8,3` → `[8]`. Array — over `/(\d+),(\d+),(\d+),(\d+)/`, `num_max(array(entry_group(0), entry_group(1), entry_group(2), entry_group(3)))` on `8,3,5,1` → `[8]`.

### `num_clamp(x, lo, hi)`
- **Signature**: `num_clamp(x: numeric, lo: numeric, hi: numeric)`
- **Returns**: numeric
- **Behavior**: Clamps `x` to the `[lo, hi]` range. Returns `undef` if bounds are inverted (`lo > hi`).
- **Example**: over `/(\d+)/`, `num_clamp(entry_group(0), 0, 10)` gives `[10]` on `42` and `[7]` on `7`.

### `num_sum(arr)`
- **Signature**: `num_sum(arr: array)`
- **Returns**: numeric
- **Behavior**: Sum of array elements. Returns `0` for empty array. Returns `undef` for non-array or non-numeric element sources.
- **Example**:
  ```text
  demo::  -> value  .push
  LX { return(copy(array(demo))) }

  value : /(\d+),(\d+),(\d+),(\d+)/  I.return( num_sum(array(entry_group(0), entry_group(1), entry_group(2), entry_group(3))) )
  ```
  Input `1,2,3,4` → `[10]`.

### `num_avg(arr)`
- **Signature**: `num_avg(arr: array)`
- **Returns**: numeric
- **Behavior**: Arithmetic mean of array elements. Returns `undef` for empty array, non-array, or non-numeric elements.
- **Example**: over `/(\d+),(\d+),(\d+)/`, `num_avg(array(entry_group(0), entry_group(1), entry_group(2)))` on `2,4,6` → `[4]`.

### `num_median(arr)`
- **Signature**: `num_median(arr: array)`
- **Returns**: numeric
- **Behavior**: Median of array elements after numeric sort. For even-length arrays, returns the average of the two middle elements. Returns `undef` for empty array, non-array, or non-numeric elements.
- **Example**: over `/(\d+),(\d+),(\d+),(\d+),(\d+)/`, `num_median(array(entry_group(0), entry_group(1), entry_group(2), entry_group(3), entry_group(4)))` on `5,1,3,2,4` → `[3]` (sorted `1,2,3,4,5`; middle element).

### `num_range(arr)`
- **Signature**: `num_range(arr: array)`
- **Returns**: numeric
- **Behavior**: `max - min` of array elements. Returns `undef` for empty array, non-array, or non-numeric elements.
- **Example**: over `/(\d+),(\d+),(\d+),(\d+)/`, `num_range(array(entry_group(0), entry_group(1), entry_group(2), entry_group(3)))` on `3,9,1,7` → `[8]` (`9 - 1`).

## 6. Control Flow Helpers

> **Worked examples** use the standard `demo:: -> value .push` scaffold unless stated otherwise.
> Examples that read `entry_group(0)` use a regex with an explicit capture group.

**Verified branch, loop, and return examples:**

| Surface | Body inside `value`'s `I { ... }` block | Input | Output |
| --- | --- | --- | --- |
| Inline `if(...)` value | `return(if(str_eq(entry_group(0), "hot"), "H", else("C")))` over `/([A-Za-z]+)/` | `hot` | `["H"]` |
| Marker `if`/`elseif`/`else` | `kind = entry_group(0); if(str_eq(kind, "a")); return("A"); elseif(str_eq(kind, "b")); return("B"); else(); return("Z"); endif()` over `/([A-Za-z]+)/` | `b` | `["B"]` |
| Attached `if` blocks | `kind = entry_group(0); if(str_eq(kind, "a")) { return("A") } elseif(str_eq(kind, "b")) { return("B") } else { return("Z") }` over `/([A-Za-z]+)/` | `b` | `["B"]` |
| `when` / `otherwise` | `kind = entry_group(0); when(str_eq(kind, "yes")) { return("Y") } otherwise { return("N") }` over `/([A-Za-z]+)/` | `yes` | `["Y"]` |
| Inline `switch(...)` value | `kind = entry_group(0); return(switch(kind, case("a", "A"), case("b", "B"), default("Z")))` over `/([A-Za-z]+)/` | `b` | `["B"]` |
| Attached `switch` blocks | `kind = entry_group(0); switch(kind) { case("a") { return("A") } case("b") { return("B") } default { return("Z") } }` over `/([A-Za-z]+)/` | `b` | `["B"]` |
| `while` loop | `count = 0; while(num_lt(count, 3)) { count = num_add(count, 1) }; return(count)` | `x` | `[3]` |
| `return(value)` | `return(entry_group(0))` over `/([A-Za-z]+)/` | `ok` | `["ok"]` |
| `return_undef()` | `if(str_eq(entry_group(0), "skip")) { return_undef() } else { return(entry_group(0)) }` over `/([A-Za-z]+)/` | `skip` | `[null]` |

**Verified repetition-control example:**

```text
demo::
 -> value .push
 LX { return(copy(array(demo))) }

value : /(keep|skip|take)\s*/
 I { if(str_eq(entry_group(0), "skip")) { next() } else { return(entry_group(0)) } }
```

Input `keep skip take ` yields `["keep","take"]`: `next()` consumes the `skip` repetition without appending a
value to `demo`'s accumulator.

**Compile-only fatal-exit example:** `exit_now(2)` is descriptor-verified as language-agnostic control metadata
(`ready=1`, `raw=0`, `fallback=0`, `unresolved=0`, canonical nodes `["EXIT"]`). It is not run in the example
table because its runtime behavior is to terminate the parser process.

### `if(cond, then, elseif(cond2, then2), else(default))`
- **Signature**: Inline composite value form.
- **Returns**: value of the selected branch in supported value positions.
- **Behavior**: Evaluates conditions left-to-right and evaluates only the selected branch payload. First true
  condition's branch is returned. If none match, the `else(...)` branch or plain third-argument fallback is
  returned. If no fallback matches, returns `undef`.
- **Portability status**: Portable on Perl and Rust in `return(...)`, assignment RHS, and fluent
  `.return(...)` value positions.

### `if(cond); ... elseif(cond2); ... else(); ... endif()`
- **Signature**: Statement-marker form.
- **Returns**: no value of its own; branch statements provide side effects or `return(...)` values.
- **Behavior**: Conditions are evaluated left-to-right. Only statements in the active branch execute. `else`
  runs when no prior branch matched, and `endif()` closes the chain.
- **Sugar**: `else` and `endif` bare-keyword forms are equivalent to `else()` and `endif()`.

### `if(cond) { ... } elseif(cond2) { ... } else { ... }`
- **Signature**: Attached-block statement form.
- **Returns**: no value of its own; branch statements provide side effects or `return(...)` values.
- **Behavior**: Conditions are evaluated left-to-right. Only statements in the active branch execute. The
  implicit close at the end of the attached chain is equivalent to `endif()`.
- **Sugar**: Compact continuations such as `} elseif(cond2) {` and `} else {` are accepted. A following
  same-line statement still needs the normal semicolon separator after the final `}`.

### `when(cond) { ... } otherwise { ... }`
- **Signature**: Attached-block alias form.
- **Returns**: no value of its own; branch statements provide side effects or `return(...)` values.
- **Behavior**: Equivalent to `if(cond) { ... } else { ... }`. The Perl reference and Rust backend
  normalize the aliases to canonical `if`/`else` control flow; they are not host-language `when` blocks.

### `switch(expr, case(val, body), default(body))`
- **Signature**: Inline composite form.
- **Returns**: value of the first matching `case` body, or the `default` body when no case matches.
- **Behavior**: Evaluates `expr` once, compares it to each `case(val)` in order, and evaluates only the
  selected branch payload. A bare switch subject such as `switch(kind, ...)` reads scalar `kind`; a bare case
  value such as `case(foo, body)` is a literal tag named `foo`, matching attached-switch case labels.
- **Portability status**: Portable on Perl and Rust in `return(...)`, assignment RHS, and fluent
  `.return(...)` value positions.

### `switch(expr) { case(val) { ... } default { ... } }`
- **Signature**: Attached-block statement form.
- **Returns**: no value of its own; branch statements provide side effects or `return(...)` values.
- **Behavior**: Evaluates `expr` once. `case(...)` branches are tested in order, only the first matching branch
  executes, and `default` executes only when no case matched. A bare switch subject reads the working scalar; a
  bare case label is a literal tag, so `switch(kind) { case(foo) { ... } }` compares scalar `kind` to `"foo"`.
- **Sugar**: `default() { ... }` is equivalent to `default { ... }`. A following same-line statement still
  needs the normal semicolon separator after the final `}`.

### `while(cond) { ... }`
- **Signature**: Attached-block statement form.
- **Returns**: no value of its own; body statements provide side effects or `return(...)` values.
- **Behavior**: Perl and Rust evaluate `cond` before every iteration and execute the body while the condition
  stays true. A `return(expr)` inside the body returns from the surrounding rule/action.
- **Safety**: Each lowered loop has a deterministic 10000-iteration guard. A non-terminating loop fails the
  rule instead of hanging the generated parser.
- **Portability status**: Portable on Perl and Rust as of `SPEC-FORMAT-TERSE.2.2.6.2`.

### `case(val, body)`
- **Signature**: Inline switch branch.
- **Returns**: branch body value.
- **Behavior**: Embedded in inline-composite `switch(expr, case(...), ...)`. A bare first argument is a literal
  tag. Use a value expression such as `case(cat(foo, ""), body)` when the case value should be read dynamically
  from a working variable.

### `default(body)`
- **Signature**: Default switch branch.
- **Returns**: branch body value.

### `exit_now(status)`
- **Signature**: `exit_now(status: int)`
- **Returns**: never returns — terminates parser immediately.
- **Behavior**: Exits the parser with the given exit status. Used for fatal diagnostic paths.
- **Compatibility**: Bare `exit` is legacy; `exit_now(...)` contributes canonical `EXIT` metadata.

### `next()`
- **Signature**: `next()`
- **Returns**: control flow — skips to next repetition.
- **Behavior**: Skip the current repetition and advance to the next in repeated-rule loops. Consumes/recognizes input without appending a value.
- **Compatibility**: Bare `next` is legacy; `next()` contributes canonical `NEXT` metadata.

### `return(value)`
- **Signature**: `return(value: expr)`
- **Returns**: the supplied value through the active return channel.
- **Behavior**: As a top-level action or lifecycle statement, writes the surrounding rule/action return channel. Inside an expression-valued block, it is block-local: it yields that block's value and skips later statements in the block.
- **Edge cases**: `return(array(...))` returns an array value. A bare scalar source such as `return(count)` reads the working scalar `count`; primitive literals stay exact, so `return(true)` is the boolean literal and `return(undef)` is `undef`. A final non-`return(...)` statement in a lifecycle block is evaluated as a statement and is not an implicit rule return.

### `return_undef()`
- **Signature**: `return_undef()`
- **Returns**: undef.
- **Behavior**: Explicitly returns undef. Used for flow-stop edges.

## 7. Capture and Mark Helpers

LinkedSpec tracks two kinds of capture origin: a single **anonymous capture
cursor** (set by `start_capture_slice()`) and any number of **named marks** (set
by `mark_here(name)`, `mark_input_start(name)`, and the other `mark_*` helpers).
The capture readers below extract text — or its character length — between such
an origin and one of three endpoints:

- the **start of the current match** — the non-cursor readers (`capture_slice`,
  `capture_slice_len`, `capture_take`, `capture_take_len`, `capture_from`,
  `capture_len_from`, `capture_take_len_from`);
- the **current scan position** (the cursor) — the `*_until_cursor*` readers;
- the **end of input** — the `*_rest*` readers.

The `capture_until_boundary(rule[, ...])` helper is the structural-lookahead
member of this family. It does not read from the anonymous capture cursor or a
named mark. It starts at the live cursor, seeks for named rule boundaries, and
captures the text before the earliest boundary match without consuming that
boundary.

Text readers return the captured substring; `*_len*` readers return its length in
**characters** (not bytes). A reader whose mark is unset, or whose span is
reversed (end before start), returns `undef`. The `capture_take*` variants are
destructive: after reading they advance the capture origin — the anonymous cursor
or the named mark — to the **current scan position** (or to **end of input** for
the `_rest` readers), so the next capture continues from there. Note that the
match-start readers (`capture_take`, `capture_take_len`, `capture_take_len_from`)
read up to the match start but still advance the origin to the scan position.

> **Worked examples.** Boundary-oriented capture examples are often naturally
> `seek`-mode snippets: an opener match records a boundary, the parser seeks to a
> later delimiter match, and the capture helper reads the text between them.

Anonymous capture cursor:

```text
demo::
 -> body .push
 LX { return(copy(array(demo))) }

body: /BEGIN/ /END/
 -> body[1] {
   return(hash("body", trim(capture_slice()), "width", capture_slice_len()))
 }
```

With `parse_mode => "seek"`, input `BEGIN alpha END` returns
`[{"body":"alpha","width":7}]`: `capture_slice()` spans the text between the
`BEGIN` match and the later `END` match, while `trim(...)` removes the surrounding
spaces for the displayed body.

Named marks and explicit span endpoints:

```text
demo::AND
 => pair

pair:AND
 /\[/
 /\w+/
 /:/
 /\w+/
 /\]/
 -> pair[0] { mark_here(body_start) }
 -> pair[2] {
   mark_match_start(colon_start)
   left = capture_between(body_start, colon_start)
   mark_here(right_start)
 }
 -> pair[4] {
   mark_match_start(close_start)
   return(hash(
     "left", left,
     "left_len", capture_len_between(body_start, colon_start),
     "right", capture_between(right_start, close_start)
   ))
 }
```

With `parse_mode => "seek"`, input `[left:right]` returns
`[{"left":"left","left_len":4,"right":"right"}]`. The first action records the
left boundary, the colon action records an exact right boundary for `left` and a
new start for `right`, and the closing-bracket action records the final right edge.

### `start_capture_slice()`
- **Signature**: `start_capture_slice()`
- **Returns**: void
- **Behavior**: Moves the anonymous capture cursor to the current scan position.
- **Compatibility**: `capture_slice_here()` is a retired alias.

### `capture_slice()`
- **Signature**: `capture_slice()`
- **Returns**: scalar
- **Behavior**: Returns the text from the anonymous capture cursor to the start of the current match.
- **Compatibility**: `capture_from_rule_start()` is a retired alias.

### `capture_slice_len()`
- **Signature**: `capture_slice_len()`
- **Returns**: int
- **Behavior**: Character length of `capture_slice()`. Preferred over raw position arithmetic.
- **Compatibility**: `capture_slice_length()` is a retired alias.

### `capture_slice_until_cursor()`
- **Signature**: `capture_slice_until_cursor()`
- **Returns**: scalar or undef
- **Behavior**: Returns the text from the anonymous capture cursor to the **current scan position** (cursor).

### `capture_slice_until_cursor_len()`
- **Signature**: `capture_slice_until_cursor_len()`
- **Returns**: int or undef
- **Behavior**: Character length of `capture_slice_until_cursor()`.

### `capture_until_boundary(...)`
- **Signature**: `capture_until_boundary(rule[, rule...])`
- **Returns**: scalar or undef
- **Behavior**: Treats each argument as a named boundary rule, quoted or bare. From the current live cursor, seeks for the earliest match of any valid boundary rule, returns the text from the original cursor to that boundary start, and moves the live cursor to that boundary start. The boundary match itself is not consumed. If at least one valid boundary rule exists but no boundary is found, captures through end-of-input and moves the cursor to end-of-input. If no requested boundary rule can be resolved to a pattern, returns `undef` and leaves the cursor unchanged.
- **Use it when**: an open-ended body should stop at the next structural token and that token must remain available to the normal rule path. This is different from `save_cursor()` / `restore_cursor()` and from `rewind_match_start()` / `rewind_entry_start()`: those helpers move an already-consumed cursor, while `capture_until_boundary(...)` avoids consuming the structural boundary in the first place.

### `capture_take()`
- **Signature**: `capture_take()`
- **Returns**: scalar or undef
- **Behavior**: Like `capture_slice()` (anonymous cursor to the start of the current match), then advances the anonymous cursor to the **current scan position**.

### `capture_take_len()`
- **Signature**: `capture_take_len()`
- **Returns**: int or undef
- **Behavior**: Character length from the anonymous cursor to the start of the current match, then advances the anonymous cursor to the **current scan position**.

### `capture_take_until_cursor()`
- **Signature**: `capture_take_until_cursor()`
- **Returns**: scalar or undef
- **Behavior**: Like `capture_slice_until_cursor()`, then advances the anonymous cursor to the cursor.

### `capture_take_until_cursor_len()`
- **Signature**: `capture_take_until_cursor_len()`
- **Returns**: int or undef
- **Behavior**: Like `capture_slice_until_cursor_len()`, then advances the anonymous cursor to the cursor.

### `capture_rest()`
- **Signature**: `capture_rest()`
- **Returns**: scalar or undef
- **Behavior**: Returns the text from the anonymous capture cursor to the **end of input**.

### `capture_rest_len()`
- **Signature**: `capture_rest_len()`
- **Returns**: int or undef
- **Behavior**: Character length of `capture_rest()`.
- **Compatibility**: `capture_rest_length()` is a retired alias.

### `capture_take_rest()`
- **Signature**: `capture_take_rest()`
- **Returns**: scalar or undef
- **Behavior**: Like `capture_rest()`, then advances the anonymous cursor to end of input.

### `capture_take_rest_len()`
- **Signature**: `capture_take_rest_len()`
- **Returns**: int or undef
- **Behavior**: Like `capture_rest_len()`, then advances the anonymous cursor to end of input.

### `mark_input_start(name)`
- **Signature**: `mark_input_start(mark_name: string)`
- **Returns**: void
- **Behavior**: Stores the absolute start-of-input position (0) under the named mark. Used for whole-input capture.

### `mark_input_end(name)`
- **Signature**: `mark_input_end(mark_name: string)`
- **Returns**: void
- **Behavior**: Stores the absolute end-of-input position under the named mark.

### `mark_copy(target, source)`
- **Signature**: `mark_copy(target_mark: string, source_mark: string)`
- **Returns**: void
- **Behavior**: Copies the `source` mark's position onto the `target` mark. If `source` is unset, the `target` mark is removed instead.

### `capture_from(name)`
- **Signature**: `capture_from(mark_name: string)`
- **Returns**: scalar or undef
- **Behavior**: Returns text from the named mark to the **start of the current match**.

### `capture_len_from(name)`
- **Signature**: `capture_len_from(mark_name: string)`
- **Returns**: int or undef
- **Behavior**: Character length of `capture_from(name)`.

### `capture_until_cursor_from(name)`
- **Signature**: `capture_until_cursor_from(mark_name: string)`
- **Returns**: scalar or undef
- **Behavior**: Returns text from the named mark to the **current scan position** (cursor).

### `capture_until_cursor_len_from(name)`
- **Signature**: `capture_until_cursor_len_from(mark_name: string)`
- **Returns**: int or undef
- **Behavior**: Character length of `capture_until_cursor_from(name)`.

### `capture_take_until_cursor_from(name)`
- **Signature**: `capture_take_until_cursor_from(mark_name: string)`
- **Returns**: scalar or undef
- **Behavior**: Like `capture_until_cursor_from(name)`, then advances the mark to the cursor.

### `capture_take_until_cursor_len_from(name)`
- **Signature**: `capture_take_until_cursor_len_from(mark_name: string)`
- **Returns**: int or undef
- **Behavior**: Like `capture_until_cursor_len_from(name)`, then advances the mark to the cursor.

### `capture_take_len_from(name)`
- **Signature**: `capture_take_len_from(mark_name: string)`
- **Returns**: int or undef
- **Behavior**: Character length from the mark to the start of the current match, then advances the mark to the cursor.

### `capture_rest_from(name)`
- **Signature**: `capture_rest_from(mark_name: string)`
- **Returns**: scalar or undef
- **Behavior**: Returns text from the named mark to the **end of input**.

### `capture_rest_len_from(name)`
- **Signature**: `capture_rest_len_from(mark_name: string)`
- **Returns**: int or undef
- **Behavior**: Character length of `capture_rest_from(name)`.

### `capture_take_rest_from(name)`
- **Signature**: `capture_take_rest_from(mark_name: string)`
- **Returns**: scalar or undef
- **Behavior**: Like `capture_rest_from(name)`, then advances the mark to end of input.

### `capture_take_rest_len_from(name)`
- **Signature**: `capture_take_rest_len_from(mark_name: string)`
- **Returns**: int or undef
- **Behavior**: Like `capture_rest_len_from(name)`, then advances the mark to end of input.

### `capture_between(start, end)`
- **Signature**: `capture_between(start_mark: string, end_mark: string)`
- **Returns**: scalar or undef
- **Behavior**: Returns text between two named marks (requires `start` ≤ `end`).

### `capture_len_between(start, end)`
- **Signature**: `capture_len_between(start_mark: string, end_mark: string)`
- **Returns**: int or undef
- **Behavior**: Character length of `capture_between(start, end)`.

## 8. Entry and Match Helpers

These helpers read from the **current match** — the regex capture that triggered the current code block.

> **Worked example: entry versus local match.** A no-regex top dispatcher enters an
> ordered child rule through the first slot (`name`) and the child returns from a
> later local slot (`Alpha`):
>
> ```text
> demo::
>  -> value .push
>  LX { return(copy(array(demo))) }
>
> value:AND
>  /(?<head>name)/
>  /\s*=\s*/
>  /(?<value>[A-Za-z_]+)/
>  -> value[1] {
>    eq = match_text()
>  }
>  -> value[2] {
>    return(hash(
>      "entry_text", entry_text(),
>      "entry_named", entry_named(head),
>      "entry_groups", entry_groups(),
>      "entry_map", entry_map(),
>      "entry_start", entry_start_pos(),
>      "entry_end", entry_end_pos(),
>      "local_text", match_text(),
>      "local_named", match_named(value),
>      "local_groups", match_groups(),
>      "local_map", match_map(),
>      "local_start", match_start_pos(),
>      "local_end", match_end_pos(),
>      "separator", trim(eq)
>    ))
>  }
> ```
>
> Input `name=Alpha` returns
> `[{"entry_end":4,"entry_groups":["name"],"entry_map":{"head":"name"},"entry_named":"name","entry_start":0,"entry_text":"name","local_end":10,"local_groups":["Alpha"],"local_map":{"value":"Alpha"},"local_named":"Alpha","local_start":5,"local_text":"Alpha","separator":"="}]`.
> The `entry_*` helpers read the match that entered `value` (the first slot, `name`);
> the `match_*` helpers in the final action read the current local slot (`Alpha`).

### `entry_text()`
- **Signature**: `entry_text()`
- **Returns**: scalar
- **Behavior**: Full text matched by the current match entry.

### `entry_group(index)`
- **Signature**: `entry_group(index: int)`
- **Returns**: scalar or undef
- **Behavior**: Numbered capture group by 0-based index over the **captured groups**.
  Index `0` is the **first** capture group (not the whole match — read the whole match
  with `entry_text()`). The list is **compacted**: capture groups that did not participate
  in the match are omitted, which shifts the indices of the groups that follow. Returns
  `undef` for an out-of-range index. See [Regex in `.spec`](../user-model/regex-in-spec.md#capture-groups).

### `entry_groups()`
- **Signature**: `entry_groups()`
- **Returns**: array (flat list of all captured groups, compacted — see `entry_group(index)`)

### `entry_named(name)`
- **Signature**: `entry_named(name: string)`
- **Returns**: scalar or undef
- **Behavior**: Named capture group. Returns undef if the group does not exist.

### `entry_has(name)`
- **Signature**: `entry_has(name: string)`
- **Returns**: integer `1` or `0`
- **Behavior**: Returns `1` if the named capture group exists in the entry match, else `0`.

### `entry_map()`
- **Signature**: `entry_map()`
- **Returns**: hash
- **Behavior**: All named capture groups as a hash (name → value).
- **Compatibility**: `entry_named_map()` is a retired alias.

### `entry_len()`
- **Signature**: `entry_len()`
- **Returns**: int
- **Behavior**: Length of the matched text.

### `entry_start_pos()`, `entry_end_pos()`
- **Signature**: `entry_start_pos()`, `entry_end_pos()`
- **Returns**: int
- **Behavior**: Absolute start/end positions in the input.

### `entry_end_line()`, `entry_end_col()`
- **Signature**: `entry_end_line()`, `entry_end_col()`
- **Returns**: int
- **Behavior**: Line number and column of the match end position.

### `match_text()`, `match_group(index)`, `match_groups()`, `match_named(name)`, `match_has(name)`, `match_map()`, `match_len()`, `match_start_pos()`, `match_end_pos()`
- Same semantics as their `entry_*` counterparts but for the **local match** (the immediate regex match inside a code block, which may differ from the rule's entry match in nested contexts).
- If no local match exists, text/group/named/length/start/end values are `undef`, `match_groups()` is `[]`,
  `match_map()` is `{}`, and `match_has(name)` is `0`. Line and column readers retain their 1-based default of `1`.
  A real zero-width local match is different: its text/capture may be empty, but its length is `0`, its positions
  are the actual (possibly zero) offsets, and a present named empty capture makes `match_has(name)` return `1`.

## 9. Input Helpers

> **Worked example.** Input helpers read the whole input, not the current cursor,
> entry match, or local match:
>
> ```text
> demo::
>  -> value .push
>  LX { return(copy(array(demo))) }
>
> value : /.+/
>  I {
>    return(hash(
>      "text", input_text(),
>      "len", input_len(),
>      "slice", input_slice(1, 2),
>      "line", input_end_line(),
>      "col", input_end_col()
>    ))
>  }
> ```
>
> Input `abcd` returns `[{"col":5,"len":4,"line":1,"slice":"bc","text":"abcd"}]`.

### `input_text()`
- **Signature**: `input_text()`
- **Returns**: scalar
- **Behavior**: Returns the entire current input as a string.

### `input_slice(start, len)`
- **Signature**: `input_slice(start: int, length: int)`
- **Returns**: scalar
- **Behavior**: Returns a substring of the current input from `start` for `length` characters.

### `input_len()`
- **Signature**: `input_len()`
- **Returns**: int
- **Behavior**: Total length of the current input.

### `input_end_line()`, `input_end_col()`
- **Signature**: `input_end_line()`, `input_end_col()`
- **Returns**: int
- **Behavior**: Line/column of the last character in the input. Computed without storing explicit marks.

## 10. Call Expression

### `call(child_rule)`
- **Signature**: `call(rule_name: bare rule-label token)`
- **Returns**: the child rule's return value
- **Behavior**: Invokes a child rule directly from action code and returns its result. Used for nested parsing delegation.
- **Edge cases**: The child rule must exist and be a valid body rule in the same `.spec` file. Use the bare
  rule label (`call(child)`), not a quoted string: current runtimes resolve the target from the raw action
  argument token.
- **Worked example**:
  ```text
  demo::
   -> child {
     retv = call(child)
     return(hash("child", retv, "len", length(retv)))
   }

  child: /(\w+)/
   I { return(uppercase(entry_text())) }
  ```
  Input `abc` returns `{"child":"ABC","len":3}`. The top action calls `child`, stores the child return in
  `retv`, and returns a hash directly; this example does not use the top accumulator wrapper.

## Cross-Cutting Contracts

### Composition Guarantee
Pure value helpers support **unlimited nested composition**. Example:
```
count(drop_front(sorted_keys(merge_hash(copy(hash(base)), overlay))))
```
Any portable pure helper that accepts an array can receive the output of an array-returning helper. Any
portable pure helper that accepts a scalar can receive the output of a scalar-returning helper. Hash-consuming
later helper argument slots accept bare hash working variables as snapshots, so `merge_hash(copy(hash(base)), overlay)`
is equivalent to the explicit `hash(overlay)` form for the overlay argument. Array-consuming helper argument slots likewise accept bare
array working variables as snapshots, so `count(drop_front(sorted(items)))` is portable. Array receiver-dot
value chains are the same composition written from the receiver side, so
`items.sorted().drop_front(2).first()` and `items.filter_match(/^a$/).count()` are portable. Hash receiver-dot
value chains apply the same rule to hash helpers, so
`meta.set_key("stage", "normalized").sorted_keys().join_values(",")` is portable and pure. String receiver-dot
chains apply the same rule to scalar string helpers, so `raw.trim().lowercase().substr(0, 12)` is portable,
and `raw.trim().split("-").lowercase_each().join_values("_")` bridges explicitly into the array family. Use explicit
aggregate wrappers such as `array(name)` and `hash(name)` anywhere a helper contract does not say a bare
aggregate read is accepted; quoted strings are literal constructor payloads, not aggregate-name aliases or
scalar-indirect lookup. Mutation statement forms remain available, and assignment/mutation operators also have
expression values where documented: `name = value` yields the stored value, `items += value` yields the updated
array snapshot, and `name[key] = value` yields the updated hash snapshot. Array end mutations such as
`items.push_back(value)` remain statement-only. Inline value `if`/`switch` is portable in the supported
value-consuming slots (`return(...)`,
assignment RHS, and fluent `.return(...)`), and its contract is the selected payload value rather than any
specific compatibility tag string.

### Receiver-Dot Method Families
Receiver-dot methods are available for the value families that have a typed receiver table:

- **String/scalar** receivers support pure string links such as `trim`, `lowercase`, `uppercase`,
  `replace_substr`, `rm_prefix`, `rm_suffix`, `substr`, `cat`, and `coalesce_nonempty`; `split(delim)`
  bridges to array chains; `length`, `starts_with`, `ends_with`, `contains_substr`, and `matches` are terminal.
- **Array/list** receivers support pure array links such as `copy`, `sorted`, `reversed`, `take`, `drop_front`,
  `slice`, `concat_arrays`, `split_each`, `trim_each`, `filter_nonempty`, `uniq`, and `filter_match`. Terminal
  links include `count`, `first`, `last`, `contains`, `index_of`, `is_empty`, `is_nonempty`, `join_values`,
  `sum`, `avg`, `median`, `range`, `min`, and `max`.
- **Hash** receivers support pure hash links such as `copy`, `merge_hash`, `set_key`, `rename_key`,
  `drop_keys`, `pick_keys`, and `flat_hash`; `sorted_keys` and `sorted_values` bridge to array chains; `count_keys`
  and `has_key` are terminal. Hash-tree traversal receiver methods `walk_leaves`, `map_leaves`, and
  `reduce_leaves` are immediate block-bearing links with their own scoped callback bindings.
- **Array-tree traversal** uses the same block-bearing receiver method names on array-valued receivers, with
  Perl reference support from `SPEC-FORMAT-TERSE.13.2` and Rust/oracle parity from `SPEC-FORMAT-TERSE.13.3`.
- **Number** receivers support terse numeric links such as `abs`, `floor`, `ceil`, `round`, `add`, `sub`, `mul`,
  `div`, `mod`, `clamp`, `min`, and `max`; `eq`, `ne`, `gt`, `ge`, `lt`, and `le` are terminal numeric
  comparisons.

Booleans and flow-result values are terminal today. Expression-valued blocks and pure user-function returns do not
have separate method tables: the yielded runtime value selects the compatible family above. Mutation forms,
lifecycle/control helpers, parser-state readers (`entry_*`, `match_*`, capture/input/mark helpers), declaration
helpers, and child-dispatch calls remain function, statement, or lifecycle surfaces unless a future task explicitly
adds type-correct receiver semantics.

### Fluent / Block Equivalence
For the locked ordinary helper families, structured-block form (`I { name = value }`) and compact
lifecycle-marker fluent-chain form (`I.set(name, value)`) produce the same behavior. Receiver-fluent
`when/otherwise` block chains are portable on action-edge and lifecycle-marker surfaces, and no-arg
action-edge `.push` / `.return(expr)` continuations are portable too. Explicit/flow action-edge chains beyond
that subset remain a separately locked surface.

### Undef Propagation
Most helpers propagate `undef` from their inputs to their outputs. Explicit `coalesce(...)` is the canonical way to provide a default. No helper silently converts `undef` to `0` or `""` unless documented otherwise.

### No Mutation Guarantee
Value and receiver forms that return arrays or hashes (`copy`, `merge_hash`, value-form `set_key(hash_expr, key, value)`, `rename_key`, `drop_keys`, `pick_keys`, `sorted_keys`, `sorted_values`, `map_leaves`, `drop_front`, `drop_back`, `take`, `take_last`, `slice`, `sorted`, `reversed`, `concat_arrays`, `filter_nonempty`, `filter_match`, `uniq`, `split`, `split_each`, `trim_each`, `lowercase_each`, `uppercase_each`) do **not** mutate their inputs. They return new containers. A standalone `trim_each(array(name))`, `lowercase_each(array(name))`, or `uppercase_each(array(name))` call is a statement form and writes its result back to that explicit working array. `walk_leaves` is the explicit tree side-effect traversal: it returns the original hash or array tree and preserves ordinary callback side effects. Other explicit mutation forms include `name = value`, `items += value`, `items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`, `items.pop_front()`, `set_key(name, key, value)`, and `name[key] = value`.

### Canonical Terse Forms
The `.spec` format has migrated these helper families to terser spellings. The **terse spelling is canonical**:

| Canonical form | Related form | Notes |
|---|---|---|
| `set(target, value)` | `target = value` | typed value assignment. Bare assignments bind scalar, array, or hash RHS values and yield the stored value in value positions. Explicit `array(...)` / `hash(...)` targets keep aggregate storage. A bare scalar source `set(out, name)` reads `name`. |
| `name = value` / `=(name, value)` | `set(name, value)` / `name = value` | assignment expression/operator spelling. It stores the target and yields the stored typed value in value positions. |
| `items += value` | `push(array(items), value)` | array append operator. A bare RHS reads a scalar working variable; all-bare `push(A,B)` remains child-call syntax; in value positions it yields the updated array snapshot. |
| `items.push_back(value)` / `items.push_front(value)` / `items.pop_back()` / `items.pop_front()` | `items += value` for back append only | array end-mutation methods; statement-level only. The receiver may be bare or `array(...)`; pop methods discard the removed value. |
| `meta[key] = value` | `set_key(meta, key, value)` | hash-index assignment operator. Bare key/RHS identifiers read scalar working variables in mutation slots; in value positions it yields the updated hash snapshot. |
| `payload["items"][0]["name"] = value` | direct nested access assignment | mutates a scalar-held array/hash value path. Intermediate containers must exist; final hash keys may be created; final array indexes may replace or append at len. |
| `cat(args...)` | string value expression | String concatenation through the portable scalar-to-text contract: strings unchanged, booleans `1`/`0`, stable finite decimal text (`-0.0` → `0`, `1.0` → `1`), and null for any null/array/harray/codeblock argument. Retired `concat` remains unsupported. |
| `copy(container)` | array/hash snapshot | one unified `copy(...)` resolves array-vs-hash by the wrapped symbol kind (array first); a bare `copy(x)` resolves as an array. |

Direct nested access, for example `payload["children"][0]["name"]` or `payload["children"][i]["name"]`, is
also part of the terse surface. It is not a helper rename; it is the replacement surface for the older nested
path helper spelling. Quoted segments are hash keys, and bare path atoms such as `[i]` read scalar working
variables as array indexes. As an lvalue, a direct nested path mutates an existing scalar-held array/hash value
tree with the no-autovivification write rules described above.

The current helper aliases above lower within their supported statement/helper families. Assignment forms
(`set(...)`, `name = value`, and `=(name, value)`) now compose as value expressions when the
target receives a scalar, array, or hash RHS value. Mutation assignment operators also compose as value
expressions: `items += value` yields the updated array snapshot and `meta[key] = value` yields the updated hash
snapshot; nested value-path assignment yields the updated root value on success and `undef` on failed path checks.
Array end mutations remain statement-only.
Value-producing helper aliases such as `cat(...)` and `copy(...)` compose in the value positions documented by
their contracts. New `.spec` authoring should prefer the terse names.

### Removed Helper Spellings

This catalog intentionally lists the current helper surface only. Deleted helper spellings are not contract
entries, not canonical ActionIR events, and not compatibility lowering paths. Update old specs to the current
forms documented above.
