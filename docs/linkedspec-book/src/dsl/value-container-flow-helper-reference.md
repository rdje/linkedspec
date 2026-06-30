# Value, Container, and Flow Helper Reference

This chapter is the public reference for LinkedSpec's value, container, array-pipeline, predicate, and structured-flow helper family.

Read [Values, Containers, and Flow Helpers](values-containers-and-flow-helpers.md) first if the mental model is still new. That chapter explains the style. This chapter is for authors who are writing `.spec` action blocks and need exact helper choices, rationale, and examples.

The design goal is simple: rule actions should say what parser-facing value they are building instead of hiding that intent inside host-language Perl fragments. A reader should be able to see "copy this array", "normalize this scalar", "append this child result", or "branch on this parser predicate" directly from the helper name.

## Where value helpers compose

Most value helpers return one expression. They become useful when they are placed inside a statement or another helper that consumes values.

| Site | Shape | Use it when |
| --- | --- | --- |
| Declaration initializer | `declare(scalar, name=expr)` | a working variable should start with one explicit value. |
| Assignment | `assign(target, source)` | an existing scalar, array, or hash slot should be replaced. |
| Array append | `items += expr` / `push(target, expr)` / `push_value(array(target), expr)` | one explicit value expression should be appended without replacing the whole array. |
| Hash field assignment | `meta[key_expr] = expr` / `set_key(name, key_expr, expr)` | one field of a named working hash should be updated in place. |
| Return payload | `return(payload)` | the rule should return one structured value. |
| Predicate | `if(condition)` / `elseif(condition)` | helper logic should drive control flow. |
| Switch driver | `switch(value)` | one value should drive equality cases. |
| Constructor payload | `array(...)` / `hash(...)` | nested values should become one array or hash payload. |

Example:

```text
Token::AND
 /(\w+)/
 -> Token[0] {
   declare(scalar, text=lowercase(trim(entry_group(0))));
   return(hash(
     "kind", "token",
     "text", scalar(text),
     "text_length", length(scalar(text))
   ));
 }
```

That rule keeps each concern explicit:

- `entry_group(0)` reads the match group.
- `trim(...)` removes boundary whitespace.
- `lowercase(...)` normalizes case.
- `declare(...)` names the intermediate value.
- `return(hash(...))` returns one structured payload.

## Per-rule default accumulator convention

Each generated rule handler starts with one rule-local array named after that rule. A rule named `Parent` has a fresh `@Parent` array for that handler invocation; a rule named `logging_annotation` has `@logging_annotation`; a rule named `sub_gui_list` has `@sub_gui_list`.

This is a convention, not global state. The array is local to the generated handler call and starts empty for that call. It exists so simple accumulator rules do not need to declare a separate array just to collect repeated child results.

The current helper surface uses that convention in these implicit child-call forms:

```text
push(Child)
push(Child, 1)
```

Read those as:

```text
# inside rule Parent
push(Child)     # append call(Child) into @Parent
push(Child, 1)  # append call(Child)->[1] into @Parent
```

LinkedSpec standardizes child-call appends on `push(...)`: the first argument is the child rule being called, the optional second bare-word argument is the target array, and a numeric final argument selects one indexed element from the child return.

Use the convention when the rule itself is the natural accumulator:

```text
Parent::
 -> Child {
   push(Child)
 }
 LX {
   return(hash("kind", "parent", "children", array_copy(array(Parent))));
 }
```

If the accumulator has a domain name that is clearer than the rule name, use an explicit target instead:

```text
Parent:: I { declare(array, children); }
 -> Child {
   push(Child, children)
 }
 LX {
   return(hash("kind", "parent", "children", array_copy(array(children))));
 }
```

Other modern helpers do not silently guess the current rule accumulator. They can still use it when you name it explicitly:

```text
push_value(array(Parent), capture_slice());
push_nonempty(array(Parent), trim(capture_slice()));
assign(array(Parent), array());
return(hash("children", array_copy(array(Parent))));
```

Older capture and return helpers also use this convention:

| Helper | Current-rule accumulator behavior | Modern direction |
| --- | --- | --- |
| `capture(label)` | appends the anonymous capture slice into `@CurrentRule`; the label argument is compatibility syntax | prefer `push_value(array(CurrentRule), capture_slice())` or an explicit domain array |
| `capture_if(label)` | trims and conditionally appends the anonymous capture slice into `@CurrentRule`; the label argument is compatibility syntax | prefer `push_nonempty(array(CurrentRule), trim(capture_slice()))` or an explicit domain array |
| `CAPTURE_IF()` | trims and conditionally appends the anonymous capture slice into `@CurrentRule` | prefer `push_nonempty(array(CurrentRule), trim(capture_slice()))` |
| *(removed 2026-06-14)* | `return_a`, `return_m`, `return_ma` were legacy tagged return shortcuts | Retired. Use `return(array(...))` with `array_copy(array(CurrentRule))` and/or `flat_array(entry_groups())` so payload shape is visible. |

Historically, a VHDL-style rule might have used the now-removed `return_ma(generate_statement)` shorthand. The modern spelling makes each part explicit:

```text
return(array(
  "?generate_statement:",
  flat_array(entry_groups()),
  array_copy(array(generate_statement))
));
```

For new specs, prefer `push(...)` for child-call appends. Prefer explicit targets when there is any chance the reader would wonder which collection is being mutated.

### Convention health (2026 audit)

An audit of all 20 shipped `.spec` files (88 total accumulator operations, June 2026) confirmed the convention is healthy and idiomatic:

| Form | Count | Share |
| --- | --- | --- |
| `push_value(array(…), …)` | 63 | 71.6% |
| Fluent `.push(…)` with explicit target | 19 | 21.6% |
| `push_nonempty(array(…), …)` | 2 | 2.3% |
| Convention-based `push(Child)` | 4 | 4.5% |

**95.5% of accumulator operations already use explicit targets.** The four remaining convention-based uses (across `regdef`, `tkgui`, and `ebnf`) are idiomatic — the rule name is the clearest name for the collection.

**Bottom line:** the per-rule default accumulator is a deliberate framework design choice, not migration debt. `push_value` is the preferred explicit spelling for new `.spec` code, and the convention-based `push(Child)` remains fully supported when the rule IS the natural accumulator.

## Containers and accessors

These helpers are the entry point into local working state and structured values.

> **Working variables auto-exist.** `scalar(name)`, `array(name)`, and `hash(name)` (and the `s()`/`a()`/`h()` aliases) reference a per-rule working variable. You do **not** have to `declare(...)` it first — referencing one through its typed wrapper auto-creates it as a fresh per-invocation working value of that kind. The wrapper is also optional in type-implying positions: a **bare** name works as the scalar target of `assign(name, …)`, `set(name, …)`, and the scalar assignment operator `name = value` for non-shape RHS values; as an array/hash target when that bare assignment receives a direct RHS shape literal (`name = []` / `set(name, [value])` -> array, `name = {}` / `set(name, { key => value })` -> hash); the scalar source in `return(name)`, `set(out, name)`, and `out = name`; the array target of `push_value(name, …)`, `push_nonempty(name, …)`, and the array append operator `name += expr`; the hash target of statement-level `set_key(name, key, value)` and hash-index assignment `name[key] = value`; and the aggregate snapshot reads `array_copy(name)`, `hash_copy(name)`, and array-first `copy(name)`. The name takes its kind from that position. Use `scalar(name)` as the target when you intentionally want to store an array/hash payload in a scalar (`set(scalar(name), [value])`). `declare(...)` stays available for initializers and explicit intent. See the [Declaration Helper Reference](declaration-helper-reference.md#declarations-are-optional-working-variables-auto-exist).

> **Primitive literals are typed values.** Quoted strings (`"text"` or `'text'`), numbers
> (`42`, `3.14`), `true`, `false`, and `undef` can be used anywhere an explicit value
> expression is accepted: returns, constructor payloads, assignment RHS values, append RHS
> values, hash keys/values, and flow predicates. `true` and `false` are JSON booleans when
> returned or placed in containers, not the strings `"true"` and `"false"`; `undef` serializes
> as JSON `null`. Literal matching is exact, so names like `trueword` and `undefine` remain
> identifiers; in supported scalar source slots they are working-variable names, not booleans
> or `undef`.

Examples:

```text
return(array(true, false, "ready", 42, undef));
flag = true;
items += false;
push(items, true);
meta["enabled"] = true;
if(false); return("unreachable"); else(); return("reachable"); endif()
```

> **Shape literals are value expressions on the Perl reference and Rust backend.** Direct array and hash literals are
> accepted in value positions: `[]`, `[value, cat("a", "b")]`, `{ key => value }`, and nested combinations.
> Shape members lower through the same scoped DSL value-expression rules as the surrounding site: primitive
> literals stay typed, recognized helpers compose, direct access keeps its own bracket rules, and non-reserved
> bare names read scalar working variables. A bare hash key is therefore dynamic (`{ key => value }` reads
> `$key`), not a string literal; quote fixed field names (`{ "kind" => value }`). When a direct shape literal
> is the RHS of a bare assignment target, it infers the aggregate target kind on both variants:
> `items = [value]` / `set(items, [])` assign the array working variable, and
> `meta = { key => value }` / `set(meta, {})` assign the hash working variable. Explicit scalar targets keep
> scalar payload assignment: `set(scalar(payload), [value])` assigns the whole array payload to scalar
> `payload`.

| Helper | Result | Use it when |
| --- | --- | --- |
| `scalar(name)` | scalar value | read the working scalar `name`. |
| `s(name)` | scalar value | short alias for `scalar(name)`. Prefer `scalar(...)` in public examples when space is not tight. |
| `scalar(array(items), index)` | scalar value or `undef` | read one zero-based element from an array value. |
| `scalar(hash(meta), key)` | scalar value or `undef` | read one field from a hash value. |
| `scalaref(base, path)` | scalar value or `undef` | read a nested hash/array path such as `{content}` or `[0]{name}`. |
| `base["field"][0][i]` | scalar value or `undef` | read a nested hash/array path directly from a working scalar container; a bare path atom such as `[i]` reads scalar `i` as an array index. |
| `array(name)` | array value | read the working array `name`. |
| `a(name)` | array value | short alias for `array(name)`. |
| `hash(name)` | hash value | read the working hash `name`. |
| `h(name)` | hash value | short alias for `hash(name)`. |
| `array(...)` | array value | construct one new array payload from the arguments. |
| `hash(...)` | hash value | construct one new hash/object payload from key/value pairs or flattened hashes. |
| `[]` / `[expr, ...]` | array value | construct one new array payload with direct literal syntax. |
| `{ key_expr => value_expr, ... }` | hash value | construct one new hash/object payload with direct literal syntax; bare keys are scalar reads, so quote fixed field names. |
| `array_copy(array_expr)` / `array_copy(name)` | array value | snapshot an array value as one nested payload. A bare name reads the working array of that name. |
| `hash_copy(hash_expr)` / `hash_copy(name)` | hash value | snapshot a hash value as one nested payload. A bare name reads the working hash of that name. |

In return and assignment-like scalar source slots, a bare scalar name is the same read as
`scalar(name)`: `return(count)`, `set(out, count)`, and `out = count` read `$count`. This
source-slot shorthand is intentionally narrower than every value expression. Mutation slots now support the
same scalar read for array append RHS and hash mutation key/RHS positions: `items += value`,
`set_key(meta, key, value)`, and `meta[key] = value` read `$value` / `$key` where those slots are scalar-valued.
Direct path atoms use the same scalar read rule when the atom is not a primitive literal or engine local.

> **Terse spellings (canonical going forward).** The `.spec` format is migrating to terser helper
> names: `set(target, source)` is the canonical rename of `assign(...)`, `cat(...)` of `concat(...)`,
> and a single unified `copy(container)` subsumes both `array_copy(...)` and `hash_copy(...)`
> (it resolves array-vs-hash by the wrapped symbol kind, array first; a bare `copy(x)` resolves as an
> array snapshot read). The scalar operator statement `name = value` is equivalent to `set(name, value)` and
> `assign(name, value)`. The array append operator `items += expr` is equivalent to the explicit
> append forms `push(items, expr)` / `push_value(items, expr)`; when the value is a working scalar,
> `items += value` reads `$value`.
> The hash-index operator `meta["key"] = expr` is equivalent to `set_key(meta, "key", expr)` when
> the key and value are scalar-valued expressions; `meta[key] = value` reads `$key` and `$value`.
> Direct nested access `payload["children"][0]["name"]` is accepted for mixed path segments.
> Quoted string segments are hash keys; numeric segments and helper/value expressions such as
> `[scalar(i)]` are array indexes. Non-reserved bare path atoms such as `[i]` are scalar array-index reads,
> equivalent to `[scalar(i)]`.
> Direct shape literals `[]` and `{ key => value }` are accepted as value expressions on the Perl reference and
> Rust backend. Bare elements/keys/values inside the shape read scalar working variables, and fixed hash field
> names should be quoted. Direct shape literals also infer the aggregate kind of a bare assignment target on
> both variants: `items = [value]` initializes the array working variable, and
> `meta = { key => value }` initializes the hash working variable; use `set(scalar(payload), [value])` for
> scalar-held shape payloads.
> Each terse helper spelling lowers **identically** to its original in every position, so both work
> during migration — the original names are deprecated aliases, not yet retired.
> See the
> [Helper Contract Catalog](../appendix/helper-contract-catalog.md#terse-helper-renames-canonical-going-forward).

Examples:

```text
assign(scalar(first_item), scalar(array(items), 0));
assign(scalar(kind), scalar(hash(meta), "kind"));
assign(scalar(content), scalaref(retv, {content}));
assign(scalar(child_name), scalaref(retv, {children}[0]{name}));
assign(scalar(child_name), retv["children"][0]["name"]);
assign(scalar(dynamic_child_name), retv["children"][i]["name"]);
assign(array(snapshot), array_copy(array(items)));
assign(hash(meta_snapshot), hash_copy(hash(meta)));
set(field, "kind");
set(value, "token");
return({ field => value, "seen" => true, "parts" => [value, entry_text()] });
```

Use `scalar(array_expr, index)` when the container is already known and the access path is one level deep.
Use direct nested access when the base is a working scalar that holds a structured array/hash payload.
`scalaref(base, path)` remains accepted and is still useful for legacy specs and for the older
`{field}[0]{name}` path notation; it keeps its historical path semantics, so use `[scalar(i)]` there when the
index should read a scalar working variable.

Example:

```text
assign(scalar(retv), call(Child));
assign(scalar(child_kind), scalaref(retv, {kind}));
assign(scalar(first_child_name), scalaref(retv, {children}[0]{name}));
assign(scalar(second_child_name), retv["children"][1]["name"]);
assign(scalar(dynamic_child_name), retv["children"][child_index]["name"]);
```

## Constructors, snapshots, and flattening

The most important collection distinction is snapshot versus flatten.

| Helper | Meaning |
| --- | --- |
| `array_copy(array(items))` | produce one nested array payload containing the items. |
| `hash_copy(hash(meta))` | produce one nested hash payload containing the fields. |
| `flat_array(array(items))` | splice array items into the surrounding constructor. |
| `flat_hash(hash(meta))` | splice hash key/value pairs into the surrounding constructor. |
| `flat(expr)` | generic flatten/splice helper for array or hash expressions. |

Snapshot example:

```text
return(hash(
  "kind", "list",
  "items", array_copy(array(items))
));
```

That returns one `items` field whose value is the array payload.

Flatten example:

```text
return(array("?node:", flat_array(array(items))));
```

That injects the array items directly into the returned array. The returned array does not contain a nested `items` array unless you explicitly ask for one with `array_copy(...)`.

Hash flattening is the same idea for key/value pairs:

```text
return(hash(
  flat_hash(hash(meta)),
  "stage", "normalized"
));
```

Use flattening when a surrounding `array(...)` or `hash(...)` is already the payload boundary and the existing collection should be opened into that boundary.

## Assignment, calls, appends, and returns

These helpers are statements. They consume values and change rule behavior.

| Helper | Effect | Use it when |
| --- | --- | --- |
| `name = expr` | replace a scalar slot | a named scalar should hold the expression result; equivalent to `set(name, expr)` / `assign(name, expr)`. |
| `assign(scalar(name), expr)` | replace a scalar slot | a named scalar should hold the expression result. |
| `assign(array(name), array_expr)` | replace an array slot | an array should become a new array value. |
| `assign(hash(name), hash_expr)` | replace a hash slot | a hash should become a new hash value. |
| `items += expr` | append one value | a named array should grow by one explicit value expression; equivalent to `push(items, expr)` / `push_value(items, expr)` for accepted RHS shapes. |
| `meta[key_expr] = expr` | set one hash field | a named working hash should update one explicit key; equivalent to `set_key(meta, key_expr, expr)` for accepted key/value shapes. |
| `call(rule)` | dispatch to another rule | a child rule should run and optionally provide a value. |
| `assign(scalar(retv), call(rule))` | capture a child result | later helper logic needs the child payload. |
| `push(rule)` | call one rule and append its result | the shortest spelling is desired for appending a child result into the current rule accumulator. |
| `push(rule, index)` | call one rule and append one indexed result | one element from a shaped child return should go straight into the current rule's conventional array accumulator. |
| `push(rule, target)` | call one rule and append into a named array | a child rule result should go straight into an explicit array accumulator. |
| `push(rule, target, index)` | call one rule and append one indexed result into a named array | one element from a shaped child return should go straight into an explicit array accumulator. |
| `push_value(array(name), expr)` | append one value | an array should grow by one item. |
| `push_nonempty(array(name), expr)` | append one meaningful value | empty captures or optional child results should be ignored instead of becoming payload items. |
| `set_key(name, key, value)` | set one hash field | a named working hash should be updated in place. |
| `return(payload)` | return one value | the rule should emit a structured result. |
| `return_undef()` | return `undef` | an optional rule branch has no value. |
| `next()` | skip the current action path | comments or ignored delimiters should be recognized without adding to the current accumulator. |
| `exit_now(status)` | exit immediately with an optional status | a fatal parse-time diagnostic should stop execution after emitting its message. |
| *(removed 2026-06-14)* | `return_a(label)`, `return_m(label)`, `return_ma(label)`, `return_imatch(...)`, `return_im(...)`, `return_array(tag, payload)` were legacy tagged return shortcuts | Retired. Use `return(...)` with `array_copy(...)` and/or `flat_array(entry_groups())` for structured payloads. |

Canonical child-result pattern:

```text
Parent::AND
 I { declare(array, children); declare(scalar, retv); }
 Child
 -> Parent[0] {
   assign(scalar(retv), call(Child));
   push_value(array(children), scalar(retv));
   return(hash("kind", "parent", "children", array_copy(array(children))));
 }
```

Direct child-accumulator pattern:

```text
Parent::
 -> Child {
   push(Child)
 }
 LX {
   return(hash("kind", "parent", "children", array_copy(array(Parent))));
 }
```

`push(rule)` is the compact form for a very common parser action: run one child rule and append that child result into the current rule's conventional array. In a rule named `Parent`, `push(Child)` means "call `Child` and push the return value into `@Parent`."

Use the one-argument form when the current rule's conventional array is the accumulator:

```text
push(Item);
push(Field);
push(Node);
```

Use the targeted two-argument form when the destination should be a separate array variable:

```text
push(Item, items);
push(Field, fields);
push(Node, children);
```

This is intentionally shorter than spelling the lower-level pieces:

```text
push_value(array(children), call(Child));
```

That longer shape is still valid. It is just not the clearest spelling when the whole intent is "call and push."

Use `push_value(...)` instead when the pushed value is not simply the child result:

```text
push_value(array(items), trim(match_text()));
push_value(array(children), hash("kind", "wrapped", "node", call(Node)));
```

The terse operator form is equivalent for explicit value expressions and bare scalar RHS reads:

```text
items += trim(match_text());
children += hash("kind", "wrapped", "node", call(Node));
items += scalar(value);
items += value;
```

In the operator form, a bare RHS identifier is a scalar working-variable read. The all-bare `push(A,B)`
function-call shape remains child-call syntax, so use `items += value` when appending a working scalar by name.

Hash field assignment has the same statement shape for named hashes:

```text
meta["kind"] = "token";
meta[cat("source", "_kind")] = scalar(kind);
meta[scalar(field_name)] = scalar(field_value);
meta[field_name] = field_value;
```

In statement hash mutation slots, bare key/RHS identifiers read scalar working variables, so
`meta[key] = "token"` reads `$key` and `meta["kind"] = value` reads `$value`.

When the child returns an array-like payload and the current rule accumulator needs one element from it, pass a zero-based index as the second argument:

```text
push(quoted_string, 1);
```

That is the helper equivalent of pushing `call(quoted_string)->[1]` into the current rule's array. If the target should be a separate array, use the three-argument form:

```text
push(quoted_string, logging_annotation, 1);
```

Keep indexed forms for shaped child payloads whose convention is already clear; otherwise, prefer returning a clearer hash or typed payload from the child and pushing the whole child result.

Conditional append pattern:

```text
logging_annotation: /@(\w+)\s*\(\s*/ /\s*\)/ @capture_slice
I { declare(array, logging_annotation); }

-> quoted_string {
  push(quoted_string, 1)
}
-> comma {
  push_nonempty(array(logging_annotation), trim(capture_slice()))
}
-> logging_annotation[1] {
  push_nonempty(array(logging_annotation), trim(capture_slice()));
  return(hash(
    "kind", "logging_annotation",
    "name", match_group(0),
    "args", array_copy(array(logging_annotation))
  ))
}
```

`push_nonempty(array(target), value)` is for accumulator rules where an optional parse span may be empty after normalization. It evaluates the value once, skips `undef`, skips the empty string, skips empty array references, and skips empty hash references. It still preserves the string `"0"` because `"0"` is data, not absence. Other reference values count as present values and are appended.

Use `push_nonempty(...)` when the empty value is parser noise:

```text
push_nonempty(array(parts), trim(capture_slice()));
push_nonempty(array(children), call(OptionalChild));
push_nonempty(array(tags), lowercase(trim(match_text())));
```

Do not use it when an empty string is a meaningful token:

```text
push_value(array(fields), scalar(field_text));
```

That distinction is deliberate. `push_value(...)` says "append exactly what I computed." `push_nonempty(...)` says "append the computed value only if it survived the emptiness filter."

Append versus replace:

```text
push_value(array(children), scalar(retv));
```

That appends one value.

```text
assign(array(children), array(scalar(retv)));
```

That replaces the whole array with a one-item array. It is correct only when replacement is the intent.

## Scalar normalization helpers

These helpers produce scalar values and preserve parser intent inside the DSL expression layer.

| Helper | Result | Use it when |
| --- | --- | --- |
| `trim(value)` | scalar | remove leading and trailing whitespace. |
| `lowercase(value)` | scalar | normalize text to lower case. |
| `uppercase(value)` | scalar | normalize text to upper case. |
| `replace_substr(value, needle, replacement)` | scalar | perform a literal substring rewrite. |
| `rm_prefix(value, prefix)` | scalar | remove one literal prefix when present. |
| `rm_suffix(value, suffix)` | scalar | remove one literal suffix when present. |
| `concat(value, value, ...)` | scalar | build one string from scalar fragments. |
| `length(value)` | scalar number or `undef` | measure scalar string length. |

Examples:

```text
assign(scalar(name), lowercase(trim(entry_group(0))));
assign(scalar(key), replace_substr(lowercase(trim(scalar(name))), "-", "_"));
assign(scalar(core), rm_prefix(scalar(key), "node_"));
assign(scalar(base), rm_suffix(scalar(core), "_end"));
assign(scalar(full_key), concat(scalar(base), "::", scalar(stage)));
assign(scalar(name_len), length(scalar(name)));
```

Rationale:

- Use `replace_substr(...)` for literal replacement, not regex replacement.
- Use `rm_prefix(...)` and `rm_suffix(...)` when the boundary itself is meaningful parser metadata.
- Use `concat(...)` when the rule already knows the fragments and does not need array staging.
- Use `coalesce(length(...), 0)` when missing text should count as zero. Plain `length(undef)` stays undefined.

Example:

```text
if(num_gt(coalesce(length(trim(scalar(name))), 0), 3))
  return(hash("kind", "long_name", "name", scalar(name)));
else()
  return(hash("kind", "short_name", "name", scalar(name)));
endif()
```

## Scalar predicates and string comparisons

These helpers usually appear in `if(...)`, `elseif(...)`, and `switch(...)` expressions, but many of them can also be assigned or returned as boolean-like scalar values.

| Helper | Meaning |
| --- | --- |
| `eq(lhs, rhs)` | string equality. |
| `ne(lhs, rhs)` | string inequality. |
| `gt(lhs, rhs)` | string greater-than. |
| `ge(lhs, rhs)` | string greater-than-or-equal. |
| `lt(lhs, rhs)` | string less-than. |
| `le(lhs, rhs)` | string less-than-or-equal. |
| `starts_with(value, prefix)` | value begins with the literal prefix. |
| `ends_with(value, suffix)` | value ends with the literal suffix. |
| `contains_substr(value, needle)` | value contains the literal substring. |
| `matches(value, /regex/)` | value matches the regex. |

Examples:

```text
if(eq(lowercase(trim(scalar(kind))), "word"))
  return(hash("kind", "word", "text", scalar(text)));
elseif(starts_with(lowercase(trim(scalar(kind))), "node_"))
  return(hash("kind", "node", "text", scalar(text)));
elseif(matches(scalar(kind), /^[A-Z_]+$/))
  return(hash("kind", "keyword", "text", scalar(text)));
else()
  return(hash("kind", "unknown", "text", scalar(text)));
endif()
```

Use string comparisons for lexical text semantics. Use numeric comparisons for counts, offsets, depths, and computed numeric helpers.

## Numeric value helpers

Numeric helpers keep arithmetic and reducers explicit. They return `undef` when required numeric operands are missing or not numeric-looking.

| Helper | Result | Use it when |
| --- | --- | --- |
| `num_abs(value)` | scalar number | absolute value. |
| `num_floor(value)` | scalar number | round down to an integer. |
| `num_ceil(value)` | scalar number | round up to an integer. |
| `num_round(value)` | scalar number | round to nearest integer. |
| `num_sum(array_expr)` | scalar number or `undef` | sum numeric array items. |
| `num_avg(array_expr)` | scalar number or `undef` | average numeric array items. |
| `num_median(array_expr)` | scalar number or `undef` | median of numeric array items. |
| `num_range(array_expr)` | scalar number or `undef` | max minus min across numeric array items. |
| `num_add(lhs, rhs, ...)` | scalar number or `undef` | add two or more operands. |
| `num_sub(lhs, rhs)` | scalar number or `undef` | subtract `rhs` from `lhs`. |
| `num_mul(lhs, rhs, ...)` | scalar number or `undef` | multiply two or more operands. |
| `num_div(lhs, rhs)` | scalar number or `undef` | divide `lhs` by `rhs`; division by zero returns `undef`. |
| `num_mod(lhs, rhs)` | scalar number or `undef` | integer remainder; non-integer operands return `undef`. |
| `num_clamp(value, lower, upper)` | scalar number or `undef` | keep a number inside inclusive bounds. |
| `num_min(array_expr)` | scalar number or `undef` | minimum numeric array item. |
| `num_min(lhs, rhs, ...)` | scalar number or `undef` | minimum of two or more operands. |
| `num_max(array_expr)` | scalar number or `undef` | maximum numeric array item. |
| `num_max(lhs, rhs, ...)` | scalar number or `undef` | maximum of two or more operands. |

Examples:

```text
assign(scalar(part_count), count(array(parts)));
assign(scalar(next_depth), num_add(scalar(depth), 1));
assign(scalar(distance), num_abs(num_sub(scalar(end_pos), scalar(start_pos))));
assign(scalar(bucket), num_mod(count(array(parts)), 3));
assign(scalar(bounded_count), num_clamp(count(array(parts)), 1, 5));
assign(scalar(score_total), num_sum(array(scores)));
assign(scalar(score_average), num_avg(array(scores)));
assign(scalar(score_median), num_median(array(scores)));
assign(scalar(score_range), num_range(array(scores)));
```

Numeric helpers compose with array helpers:

```text
assign(scalar(top_score_average), num_avg(take(sorted(array(scores)), 3)));
assign(scalar(score_floor), num_min(take(array(scores), 5)));
assign(scalar(score_ceiling), num_max(concat_arrays(array(scores), array(extra_scores))));
```

## Numeric comparisons

Use numeric comparisons when the operands are numbers, counts, or numeric helper results.

| Helper | Meaning |
| --- | --- |
| `num_eq(lhs, rhs)` | numeric equality. |
| `num_ne(lhs, rhs)` | numeric inequality. |
| `num_gt(lhs, rhs)` | numeric greater-than. |
| `num_ge(lhs, rhs)` | numeric greater-than-or-equal. |
| `num_lt(lhs, rhs)` | numeric less-than. |
| `num_le(lhs, rhs)` | numeric less-than-or-equal. |

Examples:

```text
if(num_gt(count(array(parts)), 0))
  return(hash("kind", "nonempty", "count", count(array(parts))));
endif()

if(num_eq(index_of(sorted_keys(hash(meta)), "kind"), 0))
  return(hash("kind", "kind_first"));
endif()

if(num_ge(num_avg(take(array(scores), 3)), 5))
  return(hash("kind", "high_score", "average", num_avg(take(array(scores), 3))));
endif()
```

Do not use `gt(...)` or `lt(...)` for counters. Those are string comparisons and can produce surprising ordering for numeric-looking text.

## Array helpers

Array helpers return either scalar information about an array or a new array value derived from it.

| Helper | Result | Use it when |
| --- | --- | --- |
| `count(array_expr)` | scalar count | count array items; undefined array expressions count as `0`. |
| `first(array_expr)` | scalar value or `undef` | read the first item. |
| `last(array_expr)` | scalar value or `undef` | read the last item. |
| `index_of(array_expr, needle)` | scalar index or `undef` | find the first matching item by zero-based index. |
| `contains(array_expr, needle)` | `1` or `0` | test exact array membership. |
| `drop_front(array_expr)` | array value | drop the first item. |
| `drop_front(array_expr, count)` | array value | drop the first `count` items. |
| `take(array_expr)` | array value | keep the first item. |
| `take(array_expr, count)` | array value | keep the first `count` items. |
| `slice(array_expr, start)` | array value | keep from zero-based `start` through the end. |
| `slice(array_expr, start, count)` | array value | keep at most `count` items from `start`. |
| `take_last(array_expr)` | array value | keep the last item. |
| `take_last(array_expr, count)` | array value | keep the last `count` items. |
| `drop_back(array_expr)` | array value | drop the last item. |
| `drop_back(array_expr, count)` | array value | drop the last `count` items. |
| `concat_arrays(array_expr, array_expr, ...)` | array value | concatenate multiple array values without mutating them. |
| `sorted(array_expr)` | array value | return a lexical sorted copy. |
| `reversed(array_expr)` | array value | return a reversed copy. |

Examples:

```text
assign(scalar(first_part), first(array(parts)));
assign(scalar(last_part), last(array(parts)));
assign(scalar(kind_index), index_of(sorted_keys(hash(meta)), "kind"));
assign(scalar(has_tail), contains(array(parts), "tail"));
assign(array(rest_parts), drop_front(array(parts)));
assign(array(first_two), take(array(parts), 2));
assign(array(middle), slice(array(parts), 1, 3));
assign(array(last_two), take_last(array(parts), 2));
assign(array(without_last), drop_back(array(parts)));
assign(array(combined), concat_arrays(array(parts), array(extra_parts), array("tail")));
assign(array(canonical), sorted(array(combined)));
assign(array(reverse_view), reversed(array(canonical)));
assign(scalar(first_after_sort), items.sorted().drop_front(2).first());
assign(scalar(public_count), items.filter_match(/^public_/).count());
assign(scalar(csv), items.uniq().join_values(","));
```

Array helpers are pure value helpers unless you use `assign(...)` to store their result. For example, `sorted(array(parts))` does not sort `parts` in place. This is intentional: the rule text says when a working container changes.

Array receiver-dot value chains are accepted for the same pure array helpers. The receiver is the first helper
argument, except `join_values`, where `items.join_values(delim)` maps to the canonical
`join_values(delim, items)` contract. The mutating end methods `items.push_back(value)`,
`items.push_front(value)`, `items.pop_back()`, and `items.pop_front()` remain statement-only.

## Hash helpers

Hash helpers return scalar information about an object or a new hash/array value derived from it.

| Helper | Result | Use it when |
| --- | --- | --- |
| `count_keys(hash_expr)` | scalar count | count object keys; undefined hash expressions count as `0`. |
| `sorted_keys(hash_expr)` | array value | get keys in stable lexical order. |
| `sorted_values(hash_expr)` | array value | get values in the stable lexical order of their keys. |
| `has_key(hash_expr, key)` | `1` or `0` | test key existence, not value definedness. |
| `merge_hash(hash_expr, hash_expr, ...)` | hash value | layer object fields; later arguments override earlier keys. |
| `set_key(hash_expr, key, value)` | hash value | return a copy with one key set. |
| `rename_key(hash_expr, old_key, new_key)` | hash value | return a copy with one key renamed if it exists. |
| `drop_keys(hash_expr, key, ...)` | hash value | return a copy without selected keys. |
| `pick_keys(hash_expr, key, ...)` | hash value | return a copy containing only selected keys that exist. |

Examples:

```text
assign(scalar(meta_count), count_keys(hash(meta)));
assign(array(public_keys), sorted_keys(pick_keys(hash(meta), "kind", "source", "stage")));
assign(array(public_values), sorted_values(pick_keys(hash(meta), "kind", "source", "stage")));
assign(scalar(has_kind), has_key(hash(meta), "kind"));
assign(hash(layered), merge_hash(hash(meta), hash("stage", "normalized")));
assign(hash(with_owner), set_key(hash(layered), "owner", scalar(rule_name)));
assign(hash(renamed), rename_key(hash(with_owner), "old_stage", "stage"));
assign(hash(public_meta), drop_keys(hash(renamed), "debug", "span"));
assign(hash(summary_meta), pick_keys(hash(public_meta), "kind", "source", "stage"));
assign(scalar(public_key_csv), meta.pick_keys("kind", "source").sorted_keys().join_values(","));
assign(scalar(layered_kind), meta.merge_hash(hash("kind", "fallback")).scalaref("kind"));
assign(scalar(summary_count), hash(meta).drop_keys("debug", "span").count_keys());
```

Use `has_key(...)` when the question is "does this field exist?" Use `is_defined(scalar(hash(meta), "kind"))` or `is_defined(scalaref(retv, {kind}))` when the question is "is the value defined?" Those are different questions.

`set_key(...)` has two deliberate forms. As a statement with a named target, `set_key(meta, "stage", "normalized")` mutates the working hash `meta`. As a value expression, `set_key(hash(meta), "stage", "normalized")` returns a new hash value and leaves `meta` unchanged unless you store the result with `assign(hash(meta), ...)`.

Hash receiver-dot value chains are accepted for the same pure hash helpers. The receiver is the first helper
argument, so `meta.set_key("stage", "normalized").count_keys()` maps to
`count_keys(set_key(hash(meta), "stage", "normalized"))`. Hash-returning links can continue through more
hash helpers, and `sorted_keys()` / `sorted_values()` can continue through array receiver helpers such as
`join_values(...)`, `drop_front(...)`, and `first()`. Receiver-dot `scalaref(key)` reads one field from the
current hash value. Statement forms remain separate: `set_key(meta, key, value)` and `meta[key] = value`
mutate the named working hash; `meta.set_key(key, value)` is a pure derived value unless assigned back.

The terse hash-index operator is the statement form written with the key next to the target:

```text
meta["stage"] = "normalized";
meta[cat("source", "_kind")] = scalar(kind);
meta[scalar(field_name)] = scalar(field_value);
meta[field_name] = field_value;
```

These update the named working hash in place, exactly like `set_key(meta, key, value)`. In statement mutation
slots, bare key/RHS identifiers read scalar working variables. The expression form remains explicit:
`set_key(hash(meta), key, value)` returns a copy instead of mutating `meta`.

## Fallback and presence helpers

Fallback helpers choose values. Presence helpers ask what shape or value is available.

| Helper | Meaning |
| --- | --- |
| `coalesce(value1, value2, ...)` | first defined value wins. |
| `coalesce_nonempty(value1, value2, ...)` | first defined nonempty scalar wins. |
| `is_defined(value)` | true when the value is defined, even if empty. |
| `is_undefined(value)` | true when the value is undefined. |
| `is_empty(value)` | true for undefined/empty scalar, empty array, or empty hash. |
| `is_nonempty(value)` | inverse convenience helper for nonempty values. |

Examples:

```text
assign(scalar(name), coalesce(scalaref(retv, {name}), scalar(IMATCH), "UNKNOWN"));
assign(scalar(public_name), coalesce_nonempty(trim(scalar(name)), "anonymous"));
assign(scalar(has_public_name), is_defined(scalar(public_name)));
assign(scalar(missing_kind), is_undefined(scalar(hash(meta), "kind")));
assign(scalar(has_items), is_nonempty(array(items)));
assign(scalar(no_public_meta), is_empty(pick_keys(hash(meta), "kind", "source")));
```

Rationale:

- `coalesce(...)` keeps `0`, `""`, empty arrays, and empty hashes because they are defined.
- `coalesce_nonempty(...)` is for text fallback where blank text means "keep searching".
- `is_defined(...)` is not the same as `is_nonempty(...)`.
- `has_key(...)` is not the same as `is_defined(scalar(hash(...), key))`.

Example:

```text
if(and(
  has_key(hash(meta), "kind"),
  is_nonempty(scalar(hash(meta), "kind"))
))
  return(hash("kind", scalar(hash(meta), "kind")));
else()
  return(hash("kind", "unknown"));
endif()
```

## Array pipelines

Array-pipeline helpers are statements or composable array-valued transformations for common token-list cleanup.

| Helper | Effect |
| --- | --- |
| `split(array(target), scalar(source), delimiter?)` | replace `target` with the pieces from splitting `source`. |
| `split_each(array(target), delimiter)` | split every current array item and flatten the result back into `target`. |
| `trim_each(array(target))` | trim every array item in place. |
| `filter_nonempty(array(target))` | remove empty string items. |
| `lowercase_each(array(target))` | lowercase every array item. |
| `uppercase_each(array(target))` | uppercase every array item. |
| `uniq(array(target))` | remove duplicates while preserving first-seen order. |
| `filter_match(array(target), /regex/)` | keep only items that match the regex. |
| `split_tagged_records(scalar(source), delimiter, tag, field...)` | build one tagged array record for each split source item. |

Worked example:

```text
FieldList::AND
 I { declare(array, fields); declare(scalar, raw); }
 /([A-Za-z_, ]+)/
 -> FieldList[0] {
   assign(scalar(raw), entry_group(0));
   split(array(fields), scalar(raw), /,/);
   trim_each(array(fields));
   filter_nonempty(array(fields));
   lowercase_each(array(fields));
   uniq(array(fields));
   return(hash(
     "kind", "field_list",
     "fields", array_copy(array(fields)),
     "field_count", count(array(fields)),
     "first_field", first(array(fields))
   ));
 }
```

Nested composition is useful when the transformation reads naturally as one expression:

```text
assign(array(public_fields), filter_match(uniq(uppercase_each(array(fields))), /^[A-Z_]+$/));
lowercase_each(array(public_fields));
```

Receiver-dot form is equivalent when the source is a named array working variable or array-valued expression:

```text
assign(array(public_fields), fields.uppercase_each().uniq().filter_match(/^[A-Z_]+$/));
assign(scalar(public_csv), fields.uppercase_each().uniq().filter_match(/^[A-Z_]+$/).join_values(","));
```

Use statement style when each step deserves a readable line. Use nested style when the operation is compact and local.

Use `split_tagged_records(...)` when a comma-separated identifier list should become repeated tagged payload rows:

```text
return(split_tagged_records(
  scalar(identifier_list),
  /\s*,\s*/o,
  "?signal_declaration:",
  scalar(subtype_indication),
  scalar(signal_kind),
  scalar(expression)
))
```

That lowers to the traditional `map { [tag, item, ...] } split ...` shape while keeping the authoring surface helper-based.

## Boolean composition

Boolean helpers make branch conditions portable and analyzable.

| Helper | Meaning |
| --- | --- |
| `and(condition, condition, ...)` | all conditions must pass. |
| `or(condition, condition, ...)` | any condition may pass. |
| `not(condition)` | invert one condition. |

Examples:

```text
if(and(
  has_key(hash(meta), "kind"),
  eq(lowercase(trim(scalar(hash(meta), "kind"))), "node")
))
  return(hash("kind", "node"));
endif()

if(or(
  eq(scalar(kind), "word"),
  eq(scalar(kind), "identifier"),
  matches(scalar(kind), /^name_/)
))
  return(hash("kind", "named"));
endif()

if(not(is_empty(array(items))))
  return(hash("kind", "items", "items", array_copy(array(items))));
endif()
```

Prefer helper conditions over raw host-language boolean expressions. The helper form gives the compiler one explicit expression tree to lower, inspect, and port.

## Structured `if` flow

Use marker-style `if` flow when the branch body is more than a trivial expression.

| Helper | Meaning |
| --- | --- |
| `if(condition)` | open the first branch. |
| `i(condition)` | short alias for `if(condition)`. |
| `elseif(condition)` | open a later conditional branch. |
| `elif(condition)` | short alias for `elseif(condition)`. |
| `else()` | open the fallback branch. |
| `endif()` | close the flow. |

Example:

```text
if(is_undefined(scalar(hash(meta), "kind")))
  assign(hash(meta), set_key(hash(meta), "kind", "unknown"));
elseif(eq(lowercase(trim(scalar(hash(meta), "kind"))), "word"))
  assign(hash(meta), set_key(hash(meta), "normalized_kind", "word"));
else()
  assign(hash(meta), set_key(hash(meta), "normalized_kind", "other"));
endif()

return(hash_copy(hash(meta)));
```

Inline composite `if(...)` and `switch(...)` are portable value-producing helpers for compact cases in
`return(...)`, assignment RHS, and fluent `.return(...)` value slots. They evaluate only the selected payload
branch. Use marker or attached-block flow when branches contain multiple statements or read better as
statement control.

```text
set(result,
  if(is_nonempty(array(items)),
    hash("kind", "items", "items", array_copy(array(items))),
    else(undef)
  )
)
```

Use the marker form when branches contain multiple statements, nested flow, or should be visibly statement
oriented. Inline value control is the shorter portable form for single-expression branch payloads.

Attached-block form is also portable. It lowers to the same marker flow and supplies the closing
`endif()` implicitly:

```text
if(is_nonempty(array(items))) {
  return(hash("kind", "items", "items", array_copy(array(items))))
} else {
  return_undef()
}
```

For attached blocks, `when(condition) { ... }` is a readable alias for the first `if` branch and
`otherwise { ... }` is a readable alias for the fallback `else` branch:

```text
when(matches(scalar(kind), /^node_/)) {
  return(hash("kind", "node", "text", scalar(kind)))
} otherwise {
  return(hash("kind", "other", "text", scalar(kind)))
}
```

## Inline value-control flow

Inline `if(...)` and `switch(...)` are portable value expressions when simple branch payloads need to feed
`return(...)`, an assignment RHS, or fluent `.return(...)`. They evaluate only the selected payload branch.
Use attached-block control flow when a branch needs substantial statement bodies or repeated side effects.

| Helper | Meaning |
| --- | --- |
| `if(cond, then_value, branches...)` | evaluate `cond`; return `then_value` when true, otherwise choose an `elseif(...)`, `else(...)`, or plain third fallback. |
| `elseif(cond, value)` | additional inline `if` branch. |
| `else(value)` | fallback inline `if` branch. |
| `switch(value, branches...)` | evaluate `value` once and choose the first matching branch. |
| `case(value, body)` | one equality case. |
| `default(body)` | fallback branch. |

Inline `if` example:

```text
return(if(
  is_nonempty(flag),
  cat("prefix-", scalar(flag)),
  else("missing")
))
```

The plain third-argument fallback is also accepted for Rust-compatible compact forms:

```text
set(out, if(false, "bad", "fallback"))
```

Inline `switch` example:

```text
return(switch(
  lowercase(trim(scalar(kind))),
  case("word", hash("kind", "word", "text", scalar(text))),
  case("space", hash("kind", "space", "text", scalar(text))),
  default(hash("kind", "unknown", "text", scalar(text)))
))
```

Expression-valued branch blocks are allowed in selected branches:

```text
return(if(
  true,
  { set(text, "branch"); return(text) },
  else("fallback")
))
```

Use attached-block `switch` for portable branch logic:

```text
switch(scalar(kind)) {
  case("word") {
    return(hash("kind", "word", "text", scalar(text)))
  }
  case("space") {
    return(hash("kind", "space", "text", scalar(text)))
  }
  default {
    return(hash("kind", "unknown", "text", scalar(text)))
  }
}
```

The attached statement form is portable on Perl and Rust. It uses first-match semantics and runs `default`
only when no case matched.

Use `switch(...)` when the rule is classification-by-one-value. Use `if(...)` / `elseif(...)` when each branch asks a different question.

## Attached `while` flow

The Perl reference and Rust backend accept attached-block `while` for repeated statement bodies. The condition
is evaluated before each iteration, and body statements can update the values used by that condition:

```text
set(count, 0);
while(num_lt(scalar(count), 3)) {
  set(count, num_add(scalar(count), 1));
}
return(count);
```

`return(expr)` inside the loop returns from the surrounding rule/action. Each loop has a deterministic
10000-iteration guard so a non-terminating loop fails instead of hanging the generated parser or Rust
interpreter execution.

## Debug output helpers

`say(...)`, `print(...)`, and `print_each(...)` are statement helpers for simple diagnostic output in rule actions.

| Helper | Effect |
| --- | --- |
| `say(value, ...)` | print values with a trailing newline. |
| `print(value, ...)` | print values without adding a newline. |
| `print_each(array(target), prefix, suffix?)` | print each item in an array with optional text before and after it. |

Examples:

```text
say("normalized kind: ", scalar(kind));
print("token=", scalar(text), " kind=", scalar(kind), "\n");
print_each(array(matches), "match:<<", ">>\n");
```

Use `print_each(...)` when debug output should walk an accumulated array. It is the helper-form replacement for raw Perl loops such as `print "...$_..." foreach (@matches)`.

Use `next()` when a rule edge should consume a recognized item, such as a comment, and then skip adding a value to the current accumulator:

```text
-> comment {next()}
```

Keep public examples focused on structured return values. Use debug output helpers when the example is genuinely about tracing or demonstrating a branch.

## Worked example: normalize a child node

This example shows child capture, fallback, normalization, hash shaping, and a structured return.

```text
Node::AND
 I { declare(scalar, retv); declare(hash, meta); }
 Child
 -> Node[0] {
   assign(scalar(retv), call(Child));
   assign(hash(meta), hash(
     "kind", coalesce_nonempty(trim(scalaref(retv, {kind})), "node"),
     "name", coalesce_nonempty(trim(scalaref(retv, {name})), scalar(IMATCH), "anonymous")
   ));
   assign(hash(meta), set_key(hash(meta), "normalized_name", replace_substr(lowercase(trim(scalar(hash(meta), "name"))), " ", "_")));
   return(hash_copy(hash(meta)));
 }
```

Why this reads well:

- `call(Child)` is the only child dispatch.
- `coalesce_nonempty(...)` states the fallback policy.
- `set_key(...)` states that one field is added to a copy of the object.
- `hash_copy(...)` states that the final object is returned as a payload.

## Worked example: head/tail array result

This example shows array appends, boundary reads, array helpers, and branch predicates.

```text
Sequence::AND
 I { declare(array, items); declare(scalar, retv); }
 Item
 Item
 -> Sequence[0] {
   assign(scalar(retv), call(Item));
   items += scalar(retv);
 }
 -> Sequence[1] {
   assign(scalar(retv), call(Item));
   items += scalar(retv);

   if(num_gt(count(array(items)), 1))
     return(hash(
       "kind", "sequence",
       "head", first(array(items)),
       "rest", drop_front(array(items)),
       "item_count", count(array(items))
     ));
   else()
     return(hash("kind", "single", "item", first(array(items))));
   endif()
 }
```

The important choice is the append operation: each child result is appended, here with `items += scalar(retv)`. The final `return(...)` uses pure array helpers to read or derive views from the accumulated array without mutating it.

## Worked example: classify with switch

This example shows value normalization and switch classification.

```text
Kind::AND
 I { declare(scalar, raw); declare(scalar, kind); }
 /[A-Za-z_]+/
 -> Kind[0] {
   assign(scalar(raw), entry_text());
   assign(scalar(kind), replace_substr(lowercase(trim(scalar(raw))), "-", "_"));

   switch(scalar(kind)) {
     case("word") { return(hash("kind", "word", "raw", scalar(raw))) }
     case("space") { return(hash("kind", "space", "raw", scalar(raw))) }
     case("node") { return(hash("kind", "node", "raw", scalar(raw))) }
     default { return(hash("kind", "unknown", "raw", scalar(raw))) }
   }
 }
```

The switch is better than a long `elseif` ladder because every branch is driven by the same normalized value.

## Practical guidance

- Prefer `return(payload)` for new structured returns.
- Prefer `array_copy(...)` and `hash_copy(...)` when returning a nested snapshot.
- Prefer `flat_array(...)` and `flat_hash(...)` when splicing into a surrounding constructor.
- Prefer `items += expr` / `push_value(...)` when appending; do not use whole-array assignment as a disguised append.
- Prefer `meta["field"] = expr` / `set_key(meta, "field", expr)` when updating one hash field; use `set_key(hash_expr, key, value)` when you need a copied hash value.
- Prefer `has_key(...)` for field existence and `is_defined(...)` for value definedness.
- Prefer `coalesce_nonempty(trim(...), fallback)` for human text fallback.
- Prefer numeric helpers and `num_*` comparisons for counts, indexes, depths, and lengths.
- Prefer statement-style array pipelines when each normalization step deserves a readable line.
- Prefer `switch(...)` when one value drives classification; prefer `if(...)` when each branch has different logic.
