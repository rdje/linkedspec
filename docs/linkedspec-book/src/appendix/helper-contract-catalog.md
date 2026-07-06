# Helper Contract Catalog

This appendix is the **canonical behavioral reference** for every ActionIR helper.
Each entry defines the helper's contract — signature, input/output types, semantics,
edge cases — at enough precision for a Rust, Julia, or Dart backend to implement
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
return(array(true, false, "ready", 42, undef));
flag = true;
items += false;
meta["enabled"] = true;
if(false); return("bad"); else(); return("good"); endif()
```

Literal recognition is exact. Prefix identifiers such as `trueword`, `false_alarm`, and
`undefine` are ordinary identifiers, not primitive literals.

## 0.1 Shape Value Literals

The Perl reference and Rust backend accept direct array and hash shape literals as value expressions:

```text
[]
[value, cat("a", "b"), true, []]
{ key => value, "fixed" => [value] }
```

Shape literals are accepted in value-consuming sites such as `return(payload)`, scalar assignment sources,
array append RHS values, hash-index assignment RHS values, `push(target, value)`, and nested constructor
payloads. Array elements, hash keys, and hash values lower through the scoped DSL value-expression rules:
primitive literals stay typed, recognized helper calls compose, direct nested access keeps its own bracket
semantics, nested shape literals recurse, and non-reserved bare names are scalar working-variable reads.

A bare hash-literal key is a dynamic scalar key, not a fixed string field name:

```text
set(key, "kind");
set(value, "token");
return({ key => value });       # {"kind": "token"}
return({ "kind" => value });    # fixed "kind" field
```

Direct shape literals are typed RHS values for bare assignment targets on the Perl reference and Rust backend:

```text
items = [value, cat("a", "b")];      # items holds an array value
meta = { key => value };             # meta holds a hash value
set(items, []);                      # items holds an empty array value
set(meta, {});                       # meta holds an empty hash value
set(array(items), []);               # explicit aggregate array reset
set(hash(meta), {});                 # explicit aggregate hash reset
```

The scalar-slot shorthand remains an explicit scalar read/target spelling in pre-`.15` examples:
`set(:payload, [value])` stores the whole array payload in scalar `payload`. In value positions, `:name` reads the
scalar slot named `name`.
Direct-access brackets (`payload["items"][i]`), hash-index assignment brackets (`meta[key] = value`),
control-flow/block braces, and all-bare child-call routing remain separate surfaces.

The Perl reference and Rust backend accept expression-valued blocks in value-consuming sites. A non-empty
brace payload with no top-level `=>` evaluates its statements and yields the final expression. A
`return(expr)` anywhere in the block exits only that expression-valued block, skips later block statements,
and yields `expr` as the block value. Hash literals keep precedence: `{}` and `{ key => value }` remain hash
shapes.

```text
return({ set(x, "a"); x });                    # "a"
set(out, { set(x, "a"); return(x) });          # $out = "a"
return({ return("a"); "b" });                  # "a"
set(out, { set(x, "a"); return(x); set(x, "b"); x });  # $out = "a"
return(array({ set(x, "a"); x }, { "k" => x }));
return({ [3, 1, 2] }.sorted().join_values(","));        # "1,2,3"
return({ " a-b " }.trim().split("-").count());          # 2
```

Expression-valued blocks are ordinary value expressions when used as receiver-dot receivers. The block
evaluates first, including any block-local `return(expr)`, and the yielded value is consumed by the same
compatible receiver family selected by the first method. Blocks do not create a separate block-only receiver
dispatch rule.

## 1. Declaration Helpers

> **Declaration is optional — working variables auto-exist.** Referencing a variable through a
> typed aggregate wrapper (`array(name)` / `hash(name)`) or the scalar-slot shorthand `:name`
> auto-creates it as a per-invocation working variable of that kind, so `declare(...)` is not
> required first. The wrapper is also optional in a **type-implying argument position**: the scalar
> target of `set(name, …)` and the assignment operator `name = value`, which bind scalar, array, or hash RHS
> values as the variable's current typed value; explicit aggregate targets such as `set(array(name), ...)` and
> `set(hash(name), ...)`;
> the scalar source in `return(name)`, `set(out, name)`, and `out = name`;
> the array target of `push(name, …)`, `push_nonempty(name, …)`, and the array append operator
> `name += value`; and the hash target of
> `set_key(name, key, value)` and hash-index assignment `name[key] = value`
> auto-exist from a **bare** name too, with the kind fixed by that position. Aggregate snapshot reads
> `copy(array(name))`, `copy(hash(name))`, and array-first `copy(name)` are also type-implying read
> positions. A backend MUST supply
> the same auto-existence: a wrapper- or position-referenced variable
> with no `declare(...)` is a fresh per-invocation slot scoped to the rule — **not** a value
> carried across parses or recursive re-entries. `declare(...)` is retained as a legacy explicit form;
> new specs should use direct assignment initializers such as `name = value`, `items = []`, and `meta = {}`.
> Post-migration support is compatibility-only: existing specs may keep declaration helpers, but new examples
> and language work should not depend on them.
> The DSL literals
> `undef`/`true`/`false` and the engine's own handler locals are never treated as working-variable
> names (so `array(undef)` builds an array holding the `undef` literal, not a variable `undef`).

### `declare(scalar, name)`
- **Signature**: `declare("scalar", name: string)`
- **Returns**: void
- **Behavior**: Declares a new scalar working variable named `name` in the current rule scope. Uninitialized (`undef`).
- **Errors**: Redeclaring an existing variable in the same scope.

### `declare(scalar, name = value)`
- **Signature**: `declare("scalar", name: string, initializer: expr)`
- **Returns**: void
- **Behavior**: Declares a scalar with an initial value.
- **Edge cases**: The initializer expression is evaluated at declaration time.

### `declare(array, name)`
- **Signature**: `declare("array", name: string)`
- **Returns**: void
- **Behavior**: Declares an empty array working variable.

### `declare(hash, name)`
- **Signature**: `declare("hash", name: string)`
- **Returns**: void
- **Behavior**: Declares an empty hash/object working variable.

### `name = value` assignment operator
- **Signature**: `name = value`
- **Returns**: In statement position, the stored value is ignored. In value position, it yields the typed value stored in the target.
- **Behavior**: Sets the working variable `name` to the evaluated RHS value. If the variable was not previously declared, the reference auto-creates it as a per-invocation working variable (see the note at the top of this section); otherwise it reassigns the existing variable. Later assignments may replace a scalar with an array/hash value, or replace an array/hash value with a scalar.
- **Edge cases**: `name = [value]`, `set(name, [value])`, and `=(name, [value])` bind an array value to `name`; `name = { key => value }` binds a hash value. Use `set(array(name), [value])` or `set(hash(name), { key => value })` for aggregate working storage. In scalar assignment source slots, a bare source name or scalar-slot shorthand reads a scalar too: `out = value` and `out = :value` are equivalent.
- **Terse spelling**: `name = value` is the preferred operator spelling, and `set(name, value)` remains the helper spelling. In value positions, assignments store and yield the stored typed value. See [Terse Helper Renames](#terse-helper-renames-canonical-going-forward).

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
> are typed JSON booleans. An undefined result surfaces as a `null` element. The value-returning predicates (`matches`,
> `starts_with`, `ends_with`, `contains_substr`) may be returned directly; the
> definedness predicates (`is_defined`, `is_undefined`) are **condition-only** — use them
> inside an `if (...)` test in an `I { ... }` block (shown below), not inside `return(...)`.

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
  and wrong intermediate shapes yield `undef` and leave the root unchanged. Primitive literals and engine locals
  such as `[true]` or `[CAPTURE]` are not claimed as scalar path variables.
- **Example**:
  ```text
  Top::
   /x/ -> Done {
     set(payload, hash("children", array(hash("name", "one"), hash("name", "two"))))
     set(i, 1)
     payload["children"][i]["name"] = "updated"
     return(payload["children"][i]["name"])
   }

  Done::
   /[a-z]+/
  ```
  Input `xhello` -> `["two"]`.

### `concat(args...)`
- **Signature**: `concat(a: scalar, b: scalar, ...)`
- **Returns**: scalar
- **Behavior**: Concatenates all arguments as strings. Undef arguments are treated as empty strings.
- **Edge cases**: Non-scalar arguments (arrays, hashes) return `undef` for the whole expression.
- **Terse spelling**: `cat(args...)` is the canonical terse rename of `concat`; both spellings lower identically (`concat` is a deprecated alias). See [Terse Helper Renames](#terse-helper-renames-canonical-going-forward).
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
- **Behavior**: Converts to lowercase. Returns undef if input is undef.
- **Example**: over `/(\w+)/`, `lowercase(entry_group(0))` on `HeLLo` → `["hello"]`.

### `uppercase(s)`
- **Signature**: `uppercase(value: scalar)`
- **Returns**: scalar
- **Behavior**: Converts to uppercase. Returns undef if input is undef.
- **Example**: over `/(\w+)/`, `uppercase(entry_group(0))` on `hello` → `["HELLO"]`.

### `length(s)`
- **Signature**: `length(value: scalar|array)`
- **Returns**: int
- **Behavior**: Returns the character length of a string or the element count of an array. Returns undef for undef input.
- **Example**: over `/(\w+)/`, `length(entry_group(0))` on `hello` → `[5]`.

### `matches(s, /pattern/)`
- **Signature**: `matches(value: scalar, pattern: regex)`
- **Returns**: boolean
- **Behavior**: Returns true if the value matches the regex pattern. The pattern is a literal `/regex/` — no variable interpolation.
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

### `substr(:target, pattern, replacement, flags)` / `regex_subst(...)`
- **Signature**: `substr(:target, pattern: regex-or-scalar, replacement: scalar, flags: scalar)` or
  `regex_subst(:target, pattern, replacement, flags)`
- **Returns**: no value; mutates the named scalar target.
- **Behavior**: Applies regex substitution to the current scalar target value. `g` performs global replacement;
  `i`, `m`, `s`, and `x` are regex flags; `o` is accepted as a compatibility no-op. Replacement strings can use
  capture references such as `$1`.
- **Boundary**: This is the legacy statement-style mutation form used by shipped specs. It is intentionally
  separate from pure `substr(value, start, length?)` character slicing and from literal `replace_substr(...)`.
- **Example**: `substr(:value, "\"|\\s", "", go)` removes quotes and whitespace from `value` in place.

### String receiver-dot value chains
- **Signature**: `string_expr.method(args...).next(args...)`
- **Returns**: the documented return value of the final helper in the chain.
- **Behavior**: A compatible string receiver feeds into the first pure string helper, and each helper's return
  value feeds the next compatible helper. A bare receiver such as `raw.trim()` reads the scalar working
  variable `raw`; an explicit receiver such as `:raw.trim()` has the same value. String literals may
  be receivers too: `"abcdef".substr(1, 3).uppercase()` is equivalent to
  `uppercase(substr("abcdef", 1, 3))`.
- **Allowed string-returning links**: `trim`, `lowercase`, `uppercase`, `replace_substr`, `rm_prefix`,
  `rm_suffix`, `substr`, `concat`, `cat`, and `coalesce_nonempty`.
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

### `array(e1, e2, ...)`
- **Signature**: `array(elements: expr...)`
- **Returns**: array
- **Behavior**: Constructs a new array from the given elements. Elements are evaluated in order.

### `array_copy(arr)`
- **Signature**: `array_copy(arr: array)`
- **Returns**: array
- **Behavior**: Returns a shallow copy of the array. The new array contains the same elements but is a distinct container.
- **Compatibility**: `array_values(...)` is a retired alias — use `array_copy`.
- **Terse spelling**: `copy(arr)` is the canonical terse rename — one unified `copy(...)` subsumes both `array_copy` and `hash_copy`, resolving array-vs-hash by the wrapped symbol kind (array first). `copy(array(x))` lowers identically to `array_copy(array(x))`. See [Terse Helper Renames](#terse-helper-renames-canonical-going-forward).

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
- **Behavior**: Terse explicit-value append. Lowers identically to `push_value(target, value)` for unambiguous value expressions.
- **Examples**: `push(items, "a")`, `push(items, :value)`, `push(array(items), cat("a", "b"))`, and `push(items, call(Child))`.
- **Disambiguation**: `push(A, B)` where both arguments are bare identifiers remains a child-call form (`A` is the child rule, `B` is the target accumulator). To append a working variable by bare name, use the operator form `items += value`; `push_value(items, :value)` remains explicit and unambiguous.

### `items += value`
- **Signature**: `target += value: expr`
- **Returns**: updated array snapshot in value positions; side-effect-only behavior when used as a statement.
- **Behavior**: Array append operator. Lowers/runs identically to explicit append forms, mutates the named working array, and reads a bare RHS identifier as a scalar working variable. In value positions it evaluates to the updated array snapshot after the push.
- **Examples**: `items += "a"`, `items += cat("a", "b")`, `items += :value`, `items += value`.
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
   /x/ -> Done {
    set(value, "b")
    items.push_back("a")
    items.push_back(value)
    items.push_front("z")
    items.pop_back()
    items.pop_front()
    return(copy(items))
   }

  Done:
   /[a-z]+/
  ```
  On input `xhello`, the result is `["a"]`: the push methods build `["z", "a", "b"]`, then `pop_back()`
  removes `"b"` and `pop_front()` removes `"z"`.

### `push_value(arr, value)`
- **Signature**: `push_value(target: array, value: expr)`
- **Returns**: void
- **Behavior**: Appends a value to the named accumulator. `push(target, value)` is the terse spelling for unambiguous value expressions; `push_value` stays accepted and is still the clearest form when both arguments are bare identifiers.
- **Edge cases**: Value can be any expression type. Undef values are appended as-is (use `push_nonempty` to skip). The target may be wrapped (`array(items)`) or a **bare** name (`items`); a bare target auto-exists as an array.

### `push_nonempty(arr, value)`
- **Signature**: `push_nonempty(target: array, value: expr)`
- **Returns**: void
- **Behavior**: Appends the value only if it is defined and non-empty. Skips undef and empty strings.
- **Edge cases**: Like `push_value`, the target may be wrapped (`array(items)`) or a **bare** name (`items`) that auto-exists as an array.

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
- **Retired short alias**: `a(...)`; use `array(...)`.
- **Boundary**: The bare one-argument name form is a direct working-variable name, not an indirect scalar
  lookup. `array(alias)` reads the working array named `alias`; it does not read scalar `alias` and then use
  that scalar as another variable name. Prefer direct shape literals such as `["items"]` as the terse
  constructor spelling in new examples.

### Array receiver-dot value chains
- **Signature**: `array_expr.method(args...).next(args...)`
- **Returns**: the documented return value of the final helper in the chain.
- **Behavior**: A compatible array receiver feeds into the first pure array helper, and each helper's return
  value feeds the next helper. For example, `items.sorted().drop_front(2).first()` is equivalent to
  `first(drop_front(sorted(items), 2))`, and `items.uniq().join_values(",")` is equivalent to
  `join_values(",", uniq(items))`.
- **Allowed array-returning links**: `array_copy`, `copy`, `sorted`, `reversed`, `take`, `take_last`,
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
  `push_front`, `pop_back`, `pop_front`) remain mutations, not value-chain links.
- **Block receivers**: An expression-valued block whose value is an array can be the receiver, for example
  `{ [3, 1, 2] }.sorted().join_values(",")`. A block-local `return(array_expr)` yields the receiver value and
  skips later block statements before the array chain runs.

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
- **Allowed hash-returning links**: `hash_copy`, `merge_hash`, `set_key`, `rename_key`, `drop_keys`,
  `pick_keys`, and `flat_hash`. `merge_hash` preserves the canonical helper contract: later arguments
  override earlier keys.
- **Allowed terminal/bridge links**: `sorted_keys` and `sorted_values` return arrays and may continue through
  compatible array receiver helpers. `count_keys` and `has_key` return number and boolean terminal values.
  Field reads from a named working hash use `hash(name).pick_keys(key).sorted_values().first()` after storing expression receivers in a
  named hash. Direct bracket reads such as `retv["key"]` are for scalar hashref payloads, not working-hash
  value reads.
- **Boundary**: `set_key(name, key, value)` and `name[key] = value` mutate the named working hash; hash-index
  assignment also yields the updated hash snapshot in value positions. Receiver-dot `meta.set_key(key, value)` is
  pure value composition; it mutates nothing unless its result is explicitly assigned back.
- **Block receivers**: An expression-valued block whose value is a hash can be the receiver, for example
  `{ { "b" => 2, "a" => 1 } }.sorted_keys().join_values(",")`.

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

### `split(array(target), :source, delimiter)`
- **Signature**: `split(array(target), :source, delimiter: regex-or-scalar)`
- **Returns**: no value; mutates the named array target.
- **Behavior**: Splits `source` on `delimiter` and replaces `target` with the resulting list. Regex delimiters
  split by regex match; scalar delimiters split literally.
- **Boundary**: This statement-style array pipeline helper is separate from pure `split(value, delim)`, which
  returns an array value for expression and receiver-chain use.

### `split_each(arr, delim)`
- **Signature**: `split_each(arr: array, delim: scalar)`
- **Returns**: array
- **Behavior**: Splits each element of the array on the delimiter. Results are concatenated into a single flat array.

### `trim_each(arr)`
- **Signature**: `trim_each(arr: array)`
- **Returns**: array
- **Behavior**: Trims whitespace from each element of the array.

### `filter_nonempty(arr)`
- **Signature**: `filter_nonempty(arr: array)`
- **Returns**: array
- **Behavior**: Returns a new array with empty/undef elements removed.

### `filter_match(arr, /pattern/)`
- **Signature**: `filter_match(arr: array, pattern: regex)`
- **Returns**: array
- **Behavior**: Returns elements matching the regex pattern.

### `uniq(arr)`
- **Signature**: `uniq(arr: array)`
- **Returns**: array
- **Behavior**: Returns a new array with duplicates removed. Order of first occurrence is preserved.

### `lowercase_each(arr)`
- **Signature**: `lowercase_each(arr: array)`
- **Returns**: array
- **Behavior**: Lowercases each element.

### `uppercase_each(arr)`
- **Signature**: `uppercase_each(arr: array)`
- **Returns**: array
- **Behavior**: Uppercases each element.

### `print_each(arr)`
- **Signature**: `print_each(arr: array)`
- **Returns**: void
- **Behavior**: Debug helper — prints each element to the trace/output channel. No return value.

## 4. Hash Helpers

### `hash(k1, v1, k2, v2, ...)`
- **Signature**: `hash(keys_and_values: scalar...)`
- **Returns**: hash
- **Behavior**: With exactly one bare name token, reads the named hash/associative-array working variable:
  `hash(meta)` reads the working hash `meta`. Quoted strings are literal constructor payloads, so
  `hash("key", value)` constructs a hash entry whose key is `"key"`. With zero or multiple arguments it
  constructs a hash from flat key/value pairs. Arguments are interpreted as alternating keys and values. Accepts
  `flat_array(...)` and `flat_hash(...)` for list-context insertion.
- **Retired short alias**: `h(...)`; use `hash(...)`.
- **Boundary**: The bare one-argument name form is a direct working-variable name, not an indirect scalar
  lookup. `hash(alias)` reads the working hash named `alias`; it does not read scalar `alias` and then use
  that scalar as another variable name. Prefer direct shape literals such as `{ "alias" => value }` as the
  terse constructor spelling in new examples.
- **Edge cases**: Duplicate keys: last value wins. In multi-argument constructor use, an odd final key gets
  `undef` value.

### `flat_hash(h)`
- **Signature**: `flat_hash(h: hash)`
- **Returns**: list (splices into parent context)
- **Behavior**: Flattens a hash into alternating key/value list context for insertion into `hash(...)` or `array(...)`.

### `hash_copy(h)`
- **Signature**: `hash_copy(h: hash)`
- **Returns**: hash
- **Behavior**: Shallow copy. The new hash has the same keys and values but is a distinct container.
- **Terse spelling**: `copy(h)` is the unified canonical terse rename (the same `copy(...)` that subsumes `array_copy`); `copy(hash(x))` lowers identically to `hash_copy(hash(x))`. See [Terse Helper Renames](#terse-helper-renames-canonical-going-forward).

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
- **Examples**: `meta["stage"] = "normalized"`, `meta[cat("source", "_kind")] = :kind`, `meta[field_name] = :field_value`, `meta[field_name] = field_value`.
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

## 5. Numeric Helpers

All numeric helpers return `undef` if any input is missing, non-numeric, or (for division/modulo) zero-divisor, unless wrapped in `coalesce(...)`.

Number receiver-dot value chains are pure value composition over this same family. Receiver methods use terse
names and map to `num_*`: `value.abs()` -> `num_abs(value)`, `value.add(2, 3)` -> `num_add(value, 2, 3)`,
`value.clamp(0, 10)` -> `num_clamp(value, 0, 10)`, and `value.gt(3)` -> `num_gt(value, 3)`. Bare receiver
identifiers read scalar working variables. Integer and float literal receivers are accepted (`5.mod(2)`,
`3.5.floor().add(1)`). Comparisons (`eq`, `ne`, `gt`, `ge`, `lt`, `le`) are terminal boolean values; a later
receiver-dot call after a comparison returns `undef`/`null`. `declare(...)` and other statement/lifecycle
methods are not numeric receiver methods. An expression-valued block whose value is numeric can be the
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
  executes, and `default` executes only when no case matched. A bare switch subject reads the scalar slot; a
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
  tag; during the scalar-slot transition, `case(:foo, body)` reads the scalar slot `foo` for a dynamic case
  value.

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
- **Edge cases**: `return(array(...))` returns an array value. `return(:count)` and `return(:count)` return the scalar slot `count`. A bare scalar source such as `return(count)` also reads the working scalar `count`; primitive literals stay exact, so `return(true)` is the boolean literal and `return(undef)` is `undef`. A final non-`return(...)` statement in a lifecycle block is evaluated as a statement and is not an implicit rule return.

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

Text readers return the captured substring; `*_len*` readers return its length in
**characters** (not bytes). A reader whose mark is unset, or whose span is
reversed (end before start), returns `undef`. The `capture_take*` variants are
destructive: after reading they advance the capture origin — the anonymous cursor
or the named mark — to the **current scan position** (or to **end of input** for
the `_rest` readers), so the next capture continues from there. Note that the
match-start readers (`capture_take`, `capture_take_len`, `capture_take_len_from`)
read up to the match start but still advance the origin to the scan position.

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
- **Returns**: boolean
- **Behavior**: Returns true if the named capture group exists in the current match.

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

## 9. Input Helpers

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
- **Signature**: `call(rule_name: string)`
- **Returns**: the child rule's return value
- **Behavior**: Invokes a child rule directly from action code and returns its result. Used for nested parsing delegation.
- **Edge cases**: The child rule must exist and be a valid body rule in the same `.spec` file.

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
  `replace_substr`, `rm_prefix`, `rm_suffix`, `substr`, `concat`/`cat`, and `coalesce_nonempty`; `split(delim)`
  bridges to array chains; `length`, `starts_with`, `ends_with`, `contains_substr`, and `matches` are terminal.
- **Array/list** receivers support pure array links such as `copy`, `sorted`, `reversed`, `take`, `drop_front`,
  `slice`, `concat_arrays`, `split_each`, `trim_each`, `filter_nonempty`, `uniq`, and `filter_match`. Terminal
  links include `count`, `first`, `last`, `contains`, `index_of`, `is_empty`, `is_nonempty`, `join_values`,
  `sum`, `avg`, `median`, `range`, `min`, and `max`.
- **Hash** receivers support pure hash links such as `hash_copy`, `merge_hash`, `set_key`, `rename_key`,
  `drop_keys`, `pick_keys`, and `flat_hash`; `sorted_keys` and `sorted_values` bridge to array chains; `count_keys`
  and `has_key` are terminal.
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
Helpers that return arrays or hashes (`array_copy`, `hash_copy`, `merge_hash`, value-form `set_key(hash_expr, key, value)`, `rename_key`, `drop_keys`, `pick_keys`, `sorted_keys`, `sorted_values`, `drop_front`, `drop_back`, `take`, `take_last`, `slice`, `sorted`, `reversed`, `concat_arrays`, `filter_nonempty`, `filter_match`, `uniq`, `split`, `split_each`, `trim_each`, `lowercase_each`, `uppercase_each`) do **not** mutate their inputs. They return new containers. Statement forms such as `name = value`, `items += value`, `items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`, `items.pop_front()`, `set_key(name, key, value)`, and `name[key] = value` are the explicit mutation forms.

### Terse Helper Renames (canonical going forward)
The `.spec` format is migrating to terser helper names (terse-format direction). For these three
helpers the **terse spelling is now canonical**; the original name is a **deprecated alias that
lowers identically and still works** — it is *not* retired (retirement is a later, explicit step,
unlike the Retired table below):

| Canonical (terse) | Deprecated alias | Notes |
|---|---|---|
| `set(target, value)` | `target = value` | typed value assignment. Bare assignments bind scalar, array, or hash RHS values and yield the stored value in value positions. Explicit `array(...)` / `hash(...)` targets keep aggregate storage. A bare scalar source `set(out, name)` reads `name`. |
| `name = value` / `=(name, value)` | `set(name, value)` / `name = value` | assignment expression/operator spelling. It stores the target and yields the stored typed value in value positions. |
| `items += value` | `push(items, value)` / `push_value(items, value)` | array append operator. A bare RHS reads a scalar working variable; all-bare `push(A,B)` remains child-call syntax; in value positions it yields the updated array snapshot. |
| `items.push_back(value)` / `items.push_front(value)` / `items.pop_back()` / `items.pop_front()` | `items += value` for back append only | array end-mutation methods; statement-level only. The receiver may be bare or `array(...)`; pop methods discard the removed value. |
| `meta[key] = value` | `set_key(meta, key, value)` | hash-index assignment operator. Bare key/RHS identifiers read scalar working variables in mutation slots; in value positions it yields the updated hash snapshot. |
| `payload["items"][0]["name"] = value` | direct nested access assignment | mutates a scalar-held array/hash value path. Intermediate containers must exist; final hash keys may be created; final array indexes may replace or append at len. |
| `cat(args...)` | `concat(args...)` | string concatenation. |
| `copy(container)` | `array_copy(arr)` / `hash_copy(h)` | one unified `copy(...)` resolves array-vs-hash by the wrapped symbol kind (array first); a bare `copy(x)` resolves as an array. |

Direct nested access, for example `payload["children"][0]["name"]` or `payload["children"][i]["name"]`, is
also part of the terse surface. It is not a helper rename; it is the replacement surface for the older nested
path helper spelling. Quoted segments are hash keys, and bare path atoms such as `[i]` read scalar working
variables as array indexes. As an lvalue, a direct nested path mutates an existing scalar-held array/hash value
tree with the no-autovivification write rules described above.

The helper aliases above lower identically within their supported statement/helper families. Assignment forms
(`set(...)`, `name = value`, and `=(name, value)`) now compose as value expressions when the
target receives a scalar, array, or hash RHS value. Mutation assignment operators also compose as value
expressions: `items += value` yields the updated array snapshot and `meta[key] = value` yields the updated hash
snapshot; nested value-path assignment yields the updated root value on success and `undef` on failed path checks.
Array end mutations remain statement-only.
Value-producing helper aliases such as `cat(...)` and `copy(...)` compose in the value positions documented by
their contracts. New `.spec` authoring should prefer the terse names.

### Compatibility Aliases (Retired)
The following are retired and must not be used in new `.spec` authoring. Backends may implement them for compatibility with legacy specs but should treat them as deprecated:

Declaration helpers (`declare(...)` plus declaration aliases) follow the same compatibility policy: accepted for
legacy specs, not for new authoring. See [Declaration Helper Reference](../dsl/declaration-helper-reference.md#post-migration-support-policy).

| Retired | Use Instead |
|---|---|
| `s(...)` | `...` |
| `a(...)` | `array(...)` |
| `h(...)` | `hash(...)` |
| `array_values(...)` | `array_copy(...)` |
| `flatten(...)` | `flat(...)` |
| `tail(...)` | `drop_front(...)` |
| `drop_last(...)` | `drop_back(...)` |
| `return_a`, `return_m`, `return_ma` | `return(array(...))` |
| `return_imatch`, `return_im` | `return(...)` |
| `capture_slice_here()` | `start_capture_slice()` |
| `capture_from_rule_start()` | `capture_slice()` |
| `capture_slice_length()` | `capture_slice_len()` |
| `capture_rest_length()` | `capture_rest_len()` |
| `entry_named_map()` | `entry_map()` |
