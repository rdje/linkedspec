# Value, Container, and Flow Helper Reference

This chapter is the public reference for LinkedSpec's value, container, array-pipeline, predicate, and structured-flow helper family.

Read [Values, Containers, and Flow Helpers](values-containers-and-flow-helpers.md) first if the mental model is still new. That chapter explains the style. This chapter is for authors who are writing `.spec` action blocks and need exact helper choices, rationale, and examples.

The design goal is simple: rule actions should say what parser-facing value they are building instead of hiding that intent inside host-language Perl fragments. A reader should be able to see "copy this array", "normalize this scalar", "append this child result", or "branch on this parser predicate" directly from the helper name.

## Where value helpers compose

Most value helpers return one expression. They become useful when they are placed inside a statement or another helper that consumes values.

| Site | Shape | Use it when |
| --- | --- | --- |
| Working-variable initializer | `name = expr` / `items = []` / `meta = {}` | a working variable should start with one explicit scalar, array, or hash value. |
| Assignment | `set(target, source)` / `target = source` | an existing working value should be replaced. |
| Array append | `items += expr` / `push(target, expr)` | one explicit value expression should be appended without replacing the whole array. |
| Hash field assignment | `meta[key_expr] = expr` / `set_key(name, key_expr, expr)` | one field of a named working hash should be updated in place. |
| Return payload | `return(payload)` | the rule should return one structured value. |
| Predicate | `if(condition)` / `elseif(condition)` | helper logic should drive control flow. |
| Switch driver | `switch(value)` | one value should drive equality cases. |
| Constructor payload | `array(...)` / `hash(...)` | nested values should become one array or hash payload. |

Scalar working variables are read with bare names such as `name`. Use that spelling when a payload should
visibly come from the working variable named `name`:

```text
set(value, "ok");
set(payload, [value]);          # payload now holds the array value [value]
return(array(value, payload));
```

Bare direct-shape assignment binds the shape as the variable's typed value. `set(payload, [value])`
stores the whole array value in `payload`; `payload = [value]` is the operator spelling for the same binding.

Example:

```text
Top::
 -> Token .push
 LX { return(copy(Top)) }

Token: /(\w+)/
 I {
   text = lowercase(trim(entry_group(0)));
   return(hash(
     "kind", "token",
     "text", text,
     "text_length", length(text)
   ));
 }
```

That rule keeps each concern explicit:

- `entry_group(0)` reads the match group.
- `trim(...)` removes boundary whitespace.
- `lowercase(...)` normalizes case.
- `text = ...` names the intermediate scalar value.
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

Use implicit `push(Child)` and `push(Child, index)` as statements. Their append behavior is portable, but their
expression results are not yet: Perl currently exposes the host push count, while Lua exposes the updated implicit
accumulator. Explicit-target child push returns the updated target. `FUTURE-PARITY-BACKLOG.5` owns normalization.

Use the convention when the rule itself is the natural accumulator:

```text
Parent::
 -> Child {
   push(Child)
 }
 LX {
   return(hash("kind", "parent", "children", copy(Parent)));
 }
```

If the accumulator has a domain name that is clearer than the rule name, use an explicit target instead:

```text
Parent:: I { children = []; }
 -> Child {
   push(Child, children)
 }
 LX {
   return(hash("kind", "parent", "children", copy(children)));
 }
```

Other modern helpers do not silently guess the current rule accumulator. They can still use it when you name it explicitly:

```text
push(Parent, capture_slice());
parent_part = trim(capture_slice());
if(is_nonempty(parent_part)) { push(Parent, parent_part); }
set(Parent, array());
return(hash("children", copy(Parent)));
```

Some capture helpers also use this convention:

| Helper | Current-rule accumulator behavior | Modern direction |
| --- | --- | --- |
| `capture(label)` | appends the anonymous capture slice into `@CurrentRule`; the label argument is compatibility syntax | prefer `push(CurrentRule, capture_slice())` or an explicit domain array |
| `capture_if(label)` | trims and conditionally appends the anonymous capture slice into `@CurrentRule`; the label argument is compatibility syntax | prefer `part = trim(capture_slice()); if(is_nonempty(part)) { push(CurrentRule, part) }` or an explicit domain array |
| `CAPTURE_IF()` | trims and conditionally appends the anonymous capture slice into `@CurrentRule` | prefer `part = trim(capture_slice()); if(is_nonempty(part)) { push(CurrentRule, part) }` |
For tagged aggregate returns, spell each payload part explicitly:

```text
return(array(
  "?generate_statement:",
  flat_array(entry_groups()),
  copy(generate_statement)
));
```

For new specs, prefer `push(...)` for child-call appends. Prefer explicit targets when there is any chance the reader would wonder which collection is being mutated.

### Historical convention audit

A June 2026 pre-migration audit of the then-20 shipped `.spec` files counted 88 accumulator operations. The table
preserves that historical evidence; its selector-wrapped rows are removed syntax, not current authoring examples:

| Form | Count | Share |
| --- | --- | --- |
| removed selector-wrapped `push` form | 63 | 71.6% |
| Fluent `.push(…)` with explicit target | 19 | 21.6% |
| explicit `is_nonempty(...)` guard + removed selector-wrapped `push` form | 2 | 2.3% |
| Convention-based `push(Child)` | 4 | 4.5% |

**95.5% of accumulator operations already use explicit targets.** The four remaining convention-based uses (across `regdef`, `tkgui`, and `ebnf`) are idiomatic — the rule name is the clearest name for the collection.

**Bottom line:** the per-rule default accumulator is a deliberate framework design choice, not migration debt. `push(...)` is the preferred explicit spelling for new `.spec` code, and the convention-based `push(Child)` remains fully supported when the rule IS the natural accumulator.

## Containers and accessors

These helpers are the entry point into local working state and structured values.

> **Working variables auto-exist.** A bare `name` reads its current scalar, array, harray, or codeblock value.
> `set(name, value)` and `name = value` bind the evaluated typed RHS; `push(name, value)` / `name += value` mutate
> an array; `set_key(name, key, value)` / `name[key] = value` mutate an harray; and `copy(name)` snapshots a
> container. Exact `array(IDENTIFIER)` and `hash(IDENTIFIER)` are removed language forms and must not be introduced in `.spec`
> code. All five backends reject them before execution and execute the bare replacement contract. All tracked
> source has migrated. Quoted/computed constructor calls such as
> `array("items")` and valid key/value `hash("key", value)` remain ordinary values. See
> [Working Variables and Setup](declaration-helper-reference.md#auto-existing-variables).

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
if(false); return("unreachable"); else; return("reachable"); endif
```

> **Shape literals are value expressions on the Perl reference and Rust backend.** Direct array and hash literals are
> accepted in value positions: `[]`, `[value, cat("a", "b")]`, `{ key : value }`, and nested combinations.
> Shape members lower through the same scoped DSL value-expression rules as the surrounding site: primitive
> literals stay typed, recognized helpers compose, direct access keeps its own bracket rules, and non-reserved
> bare names read scalar working variables. A direct hash key is any accepted value expression before the
> top-level `:`. A bare hash key is therefore dynamic (`{ key : value }` reads working value `key`), and a helper expression
> such as `{ cat(prefix, suffix) : value }` uses the helper result as the runtime key. Quote fixed field names
> (`{ "kind" : value }`). When a direct shape literal
> is the RHS of a bare assignment target, the array or hash is stored as the variable's typed value on both
> variants: `items = [value]` / `set(items, [])` bind array values, and
> `meta = { key : value }` / `set(meta, {})` bind hash values. In value positions, direct-shape assignments yield
> the stored typed value.

> **Expression-valued blocks are receiver-capable value expressions.** A non-empty block without a top-level
> hash-pair delimiter can feed a compatible receiver-dot helper chain. The yielded value enters the normal helper family
> selected by the method being called: `{ [3, 1, 2] }.sorted().join_values(",")` uses the array family,
> `{ " a-b " }.trim().split("-").count` uses string helpers and the explicit `split` array bridge,
> `{ { "b" : 2, "a" : 1 } }.sorted_keys().join_values(",")` uses hash then array helpers, and
> `{ 3.5 }.floor().add(2)` uses the number family. `return(expr)` inside the block is still block-local.

| Helper | Result | Use it when |
| --- | --- | --- |
| `name` | scalar value | read the working scalar `name`. |
| `items.drop_front(index).first` | scalar value or `undef` | read one zero-based element from an array value. |
| `meta.pick_keys(key).sorted_values().first` | scalar value or `undef` | read one field from a hash value. |
| `base["field"][0][i]` | scalar value or `undef` | read a nested hash/array path directly from a working scalar container; a bare path atom such as `[i]` reads scalar `i` as an array index. |
| `array(...)` | array value | construct an empty or argument-list array payload; prefer `[...]` as the terse constructor spelling in new examples. |
| `hash(...)` | hash value | construct an empty or multi-argument hash/object payload from key/value pairs or flattened hashes; use `{ "key" : undef }` for a one-field literal hash with no value. |
| `[]` / `[expr, ...]` | array value | construct one new array payload with direct literal syntax. |
| `{ key_expr : value_expr, ... }` | hash value | construct one new hash/object payload with direct literal syntax; key expressions are evaluated and stringified at runtime, so quote fixed field names. |
| `copy(array_expr)` / `copy(name)` | array value | snapshot an array value as one nested payload. A bare name reads the working array of that name. |
| `copy(hash_expr)` / `copy(name)` | hash value | snapshot a hash value as one nested payload. A bare name reads the working hash of that name. |

Use bare `name` for typed access and `array(...)` / `hash(...)` only for retained constructor shapes.

In scalar value positions, a bare scalar name reads the working variable:
`return(count)`, `set(out, count)`, `out = count`, `if(count, ...)`,
`num_lt(count, 5)`, and `switch(kind, ...)` read the current working scalar. Mutation slots use the
same scalar read for array append RHS and hash mutation key/RHS positions: `items += value`,
`set_key(meta, key, value)`, and `meta[key] = value` read `$value` / `$key` where those slots are scalar-valued.
Direct path atoms use the same scalar read rule when the atom is not a primitive literal or engine local. Switch
case labels are the deliberate exception: `case(foo)` is a literal tag named `foo`; write a quoted tag for fixed
labels and a value expression such as `case(cat(foo, ""), body)` when the case value must be read dynamically.

> **Terse spellings (canonical going forward).** The `.spec` format is migrating to terser helper
> names: use `set(target, source)` or `target = source` for assignment, `cat(...)` for concatenation,
> and a single unified `copy(container)` subsumes the former array-copy and hash-copy helpers by dispatching from
> the current runtime value kind. The assignment operator `name = value` is equivalent to `set(name, value)`; in value
> positions it yields the stored typed value. The
> array append operator `items += expr` is equivalent to the explicit
> append form `push(items, expr)`; when the value is a working variable,
> `items += value` reads that typed value, and in value positions the expression yields the updated array snapshot.
> The hash-index operator `meta["key"] = expr` is equivalent to `set_key(meta, "key", expr)` when
> the key and value are scalar-valued expressions; `meta[key] = value` reads working values `key` and `value`, and in value
> positions the expression yields the updated hash snapshot.
> Direct nested access `payload["children"][0]["name"]` is accepted for mixed path segments.
> Quoted string segments are hash keys; numeric segments and helper/value expressions such as
> `[i]` are array indexes. Non-reserved bare path atoms such as `[i]` read scalar working variables as indexes.
> The same path can be an assignment target: `payload["children"][0]["name"] = value` mutates the
> scalar-held array/hash value. Intermediate containers must already exist with the required shape; final hash
> keys may be created; final array indexes may replace an element or append exactly at the current length.
> Missing paths, wrong intermediate shapes, and array gaps yield `undef` and do not mutate the root.
> Direct shape literals `[]` and `{ key : value }` are accepted as value expressions on the Perl reference and
> Rust backend. Bare elements/keys/values inside the shape read scalar working variables, and fixed hash field
> names should be quoted. Direct shape literals bind as typed values for bare assignment targets on both variants:
> `items = [value]` / `set(items, [value])` store an array value, and `meta = { key : value }` /
> `set(meta, { key : value })` store a harray value. In value positions, assignment yields the stored value.
> Current examples use only the terse spellings.
> See the
> [Helper Contract Catalog](../appendix/helper-contract-catalog.md#terse-helper-renames-canonical-going-forward).

Examples:

```text
first_item = items.first();
kind = meta.pick_keys("kind").sorted_values().first();
content = retv["content"];
child_name = retv["children"][0]["name"];
dynamic_child_name = retv["children"][i]["name"];
set(snapshot, copy(items));
set(meta_snapshot, copy(meta));
set(field, "kind");
set(value, "token");
return({ field : value, "seen" : true, "parts" : [value, entry_text()] });
```

Use `array_expr[index]` when the container is already known and the access path is one level deep.
Use direct nested access when the base is a working scalar that holds a structured array/hash payload.
The older path-helper spelling is retirement-bound; new specs and examples should use direct nested access.

Example:

```text
retv = call(Child);
child_kind = retv["kind"];
first_child_name = retv["children"][0]["name"];
second_child_name = retv["children"][1]["name"];
dynamic_child_name = retv["children"][child_index]["name"];
```

Example write:

```text
payload = { "children" : [{ "name" : "old" }] };
payload["children"][0]["name"] = "new";
payload["children"][1] = { "name" : "second" };
return(payload);
```

## Constructors, snapshots, and flattening

The most important collection distinction is snapshot versus flatten.

| Helper | Meaning |
| --- | --- |
| `copy(items)` | produce one nested array payload containing the items. |
| `copy(meta)` | produce one nested hash payload containing the fields. |
| `flat_array(items)` | splice array items into the surrounding constructor. |
| `flat_hash(meta)` | splice hash key/value pairs into the surrounding constructor. |
| `flat(expr)` | generic flatten/splice helper for array or hash expressions, including inside direct `[...]` literals. |

Snapshot example:

```text
return(hash(
  "kind", "list",
  "items", copy(items)
));
```

That returns one `items` field whose value is the array payload.

Flatten example:

```text
return(array("?node:", flat_array(items)));
```

That injects the array items directly into the returned array. The returned array does not contain a nested `items` array unless you explicitly ask for one with `copy(...)`.

Hash flattening is the same idea for key/value pairs:

```text
return(hash(
  flat_hash(meta),
  "stage", "normalized"
));
```

Use flattening when a surrounding `array(...)` or `hash(...)` is already the payload boundary and the existing collection should be opened into that boundary.

## Assignment, calls, appends, and returns

These helpers mutate or dispatch rule state. The assignment forms also have the value contracts noted below.

| Helper | Effect | Use it when |
| --- | --- | --- |
| `name = expr` | replace the named typed value | a working variable should hold the expression result, whether scalar, array, or hash. |
| `set(name, expr)` | replace the named typed value | a working variable should visibly hold the expression result, including direct shape payloads such as `[value]`. |
| `items += expr` | append one value and yield the updated array snapshot when used as an expression | a named array should grow by one explicit value expression; equivalent to `push(items, expr)` for accepted RHS shapes. |
| `meta[key_expr] = expr` | set one hash field and yield the updated hash snapshot when used as an expression | a named working hash should update one explicit key; equivalent to `set_key(meta, key_expr, expr)` for accepted key/value shapes. |
| `call(rule)` | dispatch to another rule | a child rule should run and optionally provide a value. |
| `retv = call(rule)` | capture a child result | later helper logic needs the child payload. |
| `push(rule)` | call one rule and append its result | the shortest spelling is desired for appending a child result into the current rule accumulator. |
| `push(rule, index)` | call one rule and append one indexed result | one element from a shaped child return should go straight into the current rule's conventional array accumulator. |
| `push(rule, target)` | call one rule and append into a named array | a child rule result should go straight into an explicit array accumulator. |
| `push(rule, target, index)` | call one rule and append one indexed result into a named array | one element from a shaped child return should go straight into an explicit array accumulator. |
| `push(name, expr)` | append one value | an array should grow by one item. |
| `part = expr; if(is_nonempty(part)) { push(name, part) }` | append one meaningful value | empty captures or optional child results should be ignored instead of becoming payload items. |
| `set_key(name, key, value)` | set one hash field | a named working hash should be updated in place. |
| `return(payload)` | return one value | the rule should emit a structured result. |
| `return_undef()` | return `undef` | an optional rule branch has no value. |
| `next()`; Perl also accepts `next` | skip the current action path | comments or ignored delimiters should be recognized without adding to the current accumulator. |
| `exit_now(status)` | exit immediately with an optional status | a fatal parse-time diagnostic should stop execution after emitting its message. |
Canonical child-result pattern:

```text
Parent::AND
 I { children = []; retv = undef; }
 Child
 -> Parent[0] {
   retv = call(Child);
   push(children, retv);
   return(hash("kind", "parent", "children", copy(children)));
 }
```

Direct child-accumulator pattern:

```text
Parent::
 -> Child {
   push(Child)
 }
 LX {
   return(hash("kind", "parent", "children", copy(Parent)));
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
push(children, call(Child));
```

That longer shape is still valid. It is just not the clearest spelling when the whole intent is "call and push."

Use `push(...)` instead when the pushed value is not simply the child result:

```text
push(items, trim(match_text()));
push(children, hash("kind", "wrapped", "node", call(Node)));
```

The terse operator form is equivalent for explicit value expressions and bare scalar RHS reads:

```text
items += trim(match_text());
children += hash("kind", "wrapped", "node", call(Node));
items += value;
items += value;
```

In the operator form, a bare RHS identifier is a scalar working-variable read. The all-bare `push(A,B)`
function-call shape remains child-call syntax, so use `items += value` when appending a working scalar by name.

Hash field assignment has the same statement shape for named hashes:

```text
meta["kind"] = "token";
meta[cat("source", "_kind")] = kind;
meta[field_name] = field_value;
meta[field_name] = field_value;
```

In statement hash mutation slots, bare key/RHS identifiers read scalar working variables, so
`meta[key] = "token"` reads working value `key` and `meta["kind"] = value` reads working value `value`.

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
I { logging_annotation = []; }

-> quoted_string {
  push(quoted_string, 1)
}
-> comma {
  logging_annotation_part = trim(capture_slice())
  if(is_nonempty(logging_annotation_part)) { push(logging_annotation, logging_annotation_part) }
}
-> logging_annotation[1] {
  logging_annotation_part = trim(capture_slice());
  if(is_nonempty(logging_annotation_part)) { push(logging_annotation, logging_annotation_part); }
  return(hash(
    "kind", "logging_annotation",
    "name", match_group(0),
    "args", copy(logging_annotation)
  ))
}
```

Use an explicit non-empty guard for accumulator rules where an optional parse span may be empty after normalization. Evaluate the value once, check `is_nonempty(...)`, and then append through `push(...)`. This skips `undef`, the empty string, empty arrays, and empty hashes while preserving the string `"0"` because `"0"` is data, not absence. Other reference values count as present values and are appended.

Use the explicit filter when the empty value is parser noise:

```text
part = trim(capture_slice());
if(is_nonempty(part)) { push(parts, part); }

child = call(OptionalChild);
if(is_nonempty(child)) { push(children, child); }

tag = lowercase(trim(match_text()));
if(is_nonempty(tag)) { push(tags, tag); }
```

Do not use it when an empty string is a meaningful token:

```text
push(fields, field_text);
```

That distinction is deliberate. `push(...)` says "append exactly what I computed." The explicit guard says "append the computed value only if it survived the emptiness filter."

Append versus replace:

```text
push(children, retv);
```

That appends one value.

```text
set(children, [retv]);
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
| `substr(value, start, length?)` | scalar | take a substring by zero-based character offset. |
| `cat(value, value, ...)` | scalar | build one string from scalar fragments. |
| `length(value)` | scalar number or `undef` | measure scalar string length. |

`lowercase` and `uppercase` are Unicode operations, not byte operations; UTF-8, UTF-16, and UTF-32 are only host
representations. The canonical contract is Unicode 17.0.0 full Default Case Conversion, locale-independent, with
standard context rules and no implicit normalization. Thus `uppercase("ß")` is `"SS"`, `lowercase("İ")` is
`"i\u{0307}"`, and `uppercase("ﬃ")` is `"FFI"`. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT execute generated
tables for function, receiver, and array forms; these special cases are portable across every variant.

`cat` now uses one scalar-to-text contract on every variant. Strings are unchanged; booleans become `1` or `0`;
finite numbers use stable decimal text, so negative zero becomes `0`, `1.0` becomes `1`, and `1.25` remains
`1.25`. Null, array, harray, and codeblock values are not scalar text, so any such argument makes the whole `cat`
result null rather than silently contributing an empty fragment. The codeblock rule is a value-kind contract;
portable explicit final-codeblock call syntax remains separately tracked and is not implied here. The current
helper is `cat`; retired `concat` remains unsupported.

```text
cat("value=", true, "/", 1.0, "/", 1.25)  # "value=1/1/1.25"
cat("prefix", undef, "suffix")             # undef / JSON null
cat("prefix", [1], "suffix")               # undef / JSON null
```

Examples:

```text
name = lowercase(trim(entry_group(0)));
key = replace_substr(lowercase(trim(name)), "-", "_");
core = rm_prefix(key, "node_");
base = rm_suffix(core, "_end");
full_key = cat(base, "::", stage);
name_len = length(name);
short_key = raw.trim().lowercase().replace_substr("-", "_").substr(0, 12);
set(parts, raw.trim().split("-").trim_each().filter_nonempty());
public = raw.trim().split("-").lowercase_each().join_values("_");
```

String receiver-dot value chains are accepted for the pure scalar string helpers. The receiver is the first
helper argument, so `raw.trim().lowercase()` maps to `lowercase(trim(raw))`, and
`"abcdef".substr(1, 3).uppercase()` maps to `uppercase(substr("abcdef", 1, 3))`. String-returning links
(`trim`, `lowercase`, `uppercase`, `replace_substr`, `rm_prefix`, `rm_suffix`, `substr`, `cat`, and
`coalesce_nonempty`) can keep chaining through string helpers. `split(delim)` is the explicit bridge from a
string chain into the array receiver family, so `raw.trim().split("-").trim_each().join_values("|")` is
portable. Scalar terminals such as `length`, `starts_with`, `ends_with`, `contains_substr`, and `matches` end
the chain. A string-yielding expression-valued block can be the receiver, for example
`{ " a-b " }.trim().split("-").count()`.

Rationale:

- Use `replace_substr(...)` for literal replacement, not regex replacement.
- Use `rm_prefix(...)` and `rm_suffix(...)` when the boundary itself is meaningful parser metadata.
- Use `substr(...)` when the parser contract is a fixed offset/width slice of a value.
- Use `cat(...)` when the rule already knows the fragments and does not need array staging.
- Use `coalesce(length(...), 0)` when missing text should count as zero. Plain `length(undef)` stays undefined.

Statement-style regex substitution is a separate mutation form used by some shipped specs:

```text
substr(value, '"|\s', "", go)
regex_subst(value, /^\[(\d+)\]$/, "$1", o)
```

Those forms mutate the named scalar target. `g` applies the replacement globally; `i`, `m`, `s`, and `x` are regex
flags; `o` is accepted as a compatibility no-op. Keep this form out of receiver-dot value chains, where
`substr(value, start, length?)` means character slicing. Single-quoted and double-quoted scalar literals are the
same variant-agnostic `.spec` surface on every backend; prefer the delimiter that keeps the pattern readable.

Example:

```text
if(num_gt(coalesce(length(trim(name)), 0), 3))
  return(hash("kind", "long_name", "name", name));
else()
  return(hash("kind", "short_name", "name", name));
endif()
```

## Scalar predicates and string comparisons

These helpers usually appear in `if(...)`, `elseif(...)`, and `switch(...)` expressions, but many of them can also be assigned or returned as boolean-like scalar values.

| Helper | Meaning |
| --- | --- |
| `str_eq(lhs, rhs)` | string equality. |
| `str_ne(lhs, rhs)` | string inequality. |
| `str_gt(lhs, rhs)` | string greater-than. |
| `str_ge(lhs, rhs)` | string greater-than-or-equal. |
| `str_lt(lhs, rhs)` | string less-than. |
| `str_le(lhs, rhs)` | string less-than-or-equal. |
| `starts_with(value, prefix)` | value begins with the literal prefix. |
| `ends_with(value, suffix)` | value ends with the literal suffix. |
| `contains_substr(value, needle)` | value contains the literal substring. |
| `matches(value, /regex/)` | value matches the regex. |

Examples:

```text
if(str_eq(lowercase(trim(kind)), "word"))
  return(hash("kind", "word", "text", text));
elseif(starts_with(lowercase(trim(kind)), "node_"))
  return(hash("kind", "node", "text", text));
elseif(matches(kind, /^[A-Z_]+$/))
  return(hash("kind", "keyword", "text", text));
else()
  return(hash("kind", "unknown", "text", text));
endif()
```

Use string comparisons for lexical text semantics. Use numeric comparisons for counts, offsets, depths, and computed numeric helpers.

Compatibility bridge status:

- The explicit bridge names `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le` are shipped and
  preferred for lexical text comparisons.
- The bare helpers `eq`, `ne`, `gt`, `ge`, `lt`, and `le` are numeric comparison aliases. They are no longer
  lexical string comparisons.
- The `str_*` names are not numeric helpers and are not comparison-symbol calls.

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

The non-comparison numeric helpers also accept terse function-form aliases:
`abs`, `floor`, `ceil`, `round`, `sum`, `avg`, `median`, `range`, `add`, `sub`,
`mul`, `div`, `mod`, `clamp`, `min`, and `max`. They lower to the corresponding
`num_*` helper and compose as ordinary nested calls.

Arithmetic symbols are accepted as the equivalent call names for the binary or
variadic arithmetic family: `+(a, b)` -> `num_add(a, b)`, `-(a, b)` ->
`num_sub(a, b)`, `*(a, b)` -> `num_mul(a, b)`, `/(a, b)` -> `num_div(a, b)`,
and `%(a, b)` -> `num_mod(a, b)`. There is no operator precedence in either
form; write grouping explicitly with nested calls such as `+(*(a, b), c)` or
`add(mul(a, b), c)`.

Comparison symbols are accepted as the equivalent call names for the numeric
comparison family: `==(a, b)` -> `num_eq(a, b)`, `!=(a, b)` -> `num_ne(a, b)`,
`>(a, b)` -> `num_gt(a, b)`, `>=(a, b)` -> `num_ge(a, b)`, `<(a, b)` ->
`num_lt(a, b)`, and `<=(a, b)` -> `num_le(a, b)`. They are still ordinary
function calls, not infix operators. For lexical string comparisons, use
`str_eq(...)`, `str_ne(...)`, `str_gt(...)`, `str_ge(...)`, `str_lt(...)`, and
`str_le(...)`.

Examples:

```text
part_count = count(parts);
next_depth = num_add(depth, 1);
next_depth = add(depth, 1);
next_depth = +(depth, 1);
distance = num_abs(num_sub(end_pos, start_pos));
distance = abs(sub(end_pos, start_pos));
bucket = num_mod(count(parts), 3);
bucket = %(count(parts), 3);
bounded_count = num_clamp(count(parts), 1, 5);
score_total = num_sum(scores);
score_total = sum(scores);
score_total = scores.sum();
score_average = num_avg(scores);
score_average = scores.avg();
score_median = num_median(scores);
score_range = num_range(scores);
score_floor = scores.min();
score_ceiling = scores.max();
next_depth = depth.add(1);
weighted_count = count(parts).add(2, offset).mul(3);
score_bucket = score.abs().ceil().clamp(0, 10);
has_parts = >(count(parts), 0);
```

Number receiver-dot value chains are accepted with terse method names. The receiver is the first argument to
the corresponding `num_*` helper, so `score.abs().ceil().add(2)` maps to
`num_add(num_ceil(num_abs(score)), 2)`, and `3.5.floor().add(1)` maps to
`num_add(num_floor(3.5), 1)`. Number-returning links (`abs`, `floor`, `ceil`, `round`, `add`, `sub`, `mul`,
`div`, `mod`, `min`, `max`, and `clamp`) can keep chaining through number helpers. Comparison links (`eq`,
`ne`, `gt`, `ge`, `lt`, `le`) return booleans and end the chain. Array reducers are array-consuming: use
function form such as `num_sum(scores)` / `sum(scores)` or terminal array receiver form such as
`scores.sum()` / `scores.avg()`. They are not scalar number receiver links, and reducer terminals do not
continue through later array receiver methods. A number-yielding expression-valued block can be the receiver,
for example `{ 3.5 }.floor().add(2)`.

Numeric helpers compose with array helpers:

```text
top_score_average = num_avg(take(sorted(scores), 3));
top_score_average = scores.sorted().take(3).avg();
score_floor = num_min(take(scores, 5));
score_ceiling = num_max(concat_arrays(scores, extra_scores));
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
| `eq(lhs, rhs)` | alias for `num_eq(lhs, rhs)`. |
| `ne(lhs, rhs)` | alias for `num_ne(lhs, rhs)`. |
| `gt(lhs, rhs)` | alias for `num_gt(lhs, rhs)`. |
| `ge(lhs, rhs)` | alias for `num_ge(lhs, rhs)`. |
| `lt(lhs, rhs)` | alias for `num_lt(lhs, rhs)`. |
| `le(lhs, rhs)` | alias for `num_le(lhs, rhs)`. |
| `==(lhs, rhs)` | alias for `num_eq(lhs, rhs)`. |
| `!=(lhs, rhs)` | alias for `num_ne(lhs, rhs)`. |
| `>(lhs, rhs)` | alias for `num_gt(lhs, rhs)`. |
| `>=(lhs, rhs)` | alias for `num_ge(lhs, rhs)`. |
| `<(lhs, rhs)` | alias for `num_lt(lhs, rhs)`. |
| `<=(lhs, rhs)` | alias for `num_le(lhs, rhs)`. |

Examples:

```text
if(num_gt(count(parts), 0))
  return(hash("kind", "nonempty", "count", count(parts)));
endif()

if(gt(count(parts), 0))
  return(hash("kind", "nonempty", "count", count(parts)));
endif()

if(>(count(parts), 0))
  return(hash("kind", "nonempty", "count", count(parts)));
endif()

if(num_eq(index_of(sorted_keys(meta), "kind"), 0))
  return(hash("kind", "kind_first"));
endif()

if(num_ge(num_avg(take(scores, 3)), 5))
  return(hash("kind", "high_score", "average", num_avg(take(scores, 3))));
endif()

if(count(parts).gt(0))
  return(hash("kind", "nonempty", "count", count(parts)));
endif()
```

Do not use `str_gt(...)` or `str_lt(...)` for counters. They are string comparisons and can produce surprising ordering for numeric-looking text.

Numeric comparisons can use `num_eq`/`num_ne`/`num_gt`/`num_ge`/`num_lt`/`num_le`, bare word aliases such as
`gt(...)`, symbol callees such as `>(...)`, or number receiver terminals such as
`count(parts).gt(0)`. The explicit string bridge names are shipped as
`str_eq`/`str_ne`/`str_gt`/`str_ge`/`str_lt`/`str_le`; prefer those names in lexical string comparisons.

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
first_part = first(parts);
last_part = last(parts);
kind_index = index_of(sorted_keys(meta), "kind");
has_tail = contains(parts, "tail");
set(rest_parts, drop_front(parts));
set(first_two, take(parts, 2));
set(middle, slice(parts, 1, 3));
set(last_two, take_last(parts, 2));
set(without_last, drop_back(parts));
set(combined, concat_arrays(parts, extra_parts, ["tail"]));
set(canonical, sorted(combined));
set(reverse_view, reversed(canonical));
first_after_sort = items.sorted().drop_front(2).first();
public_count = items.filter_match(/^public_/).count();
csv = items.uniq().join_values(",");
```

Array helpers are pure value helpers unless you use `set(...)` to store their result. For example, `sorted(parts)` does not sort `parts` in place. This is intentional: the rule text says when a working container changes.

Array receiver-dot value chains are accepted for the same pure array helpers. The receiver is the first helper
argument, except `join_values`, where `items.join_values(delim)` maps to the canonical
`join_values(delim, items)` contract. The named mutating end methods `items.push_back(value)`,
`items.push_front(value)`, `items.pop_back()`, and `items.pop_front()` return independent updated arrays; pop
discards the removed element, and a continuation such as `.count()` consumes the update. An
array-yielding expression-valued block can be the receiver too:
`{ [3, 1, 2] }.sorted().join_values(",")`.

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
| `hash_expr.walk_leaves() { block }` | hash value | visit every non-hash leaf for side effects and return the original tree. |
| `hash_expr.map_leaves() { block }` | hash value | return a new tree with every non-hash leaf replaced by the block result. |
| `hash_expr.reduce_leaves(initial) { block }` | value | fold every non-hash leaf into an accumulator. |

Examples:

```text
meta_count = count_keys(meta);
set(public_keys, sorted_keys(pick_keys(meta, "kind", "source", "stage")));
set(public_values, sorted_values(pick_keys(meta, "kind", "source", "stage")));
has_kind = has_key(meta, "kind");
set(layered, merge_hash(meta, hash("stage", "normalized")));
set(with_owner, set_key(layered, "owner", rule_name));
set(renamed, rename_key(with_owner, "old_stage", "stage"));
set(public_meta, drop_keys(renamed, "debug", "span"));
set(summary_meta, pick_keys(public_meta, "kind", "source", "stage"));
public_key_csv = meta.pick_keys("kind", "source").sorted_keys().join_values(",");
flat_count = meta.copy().flat_hash().count_keys();
set(layered, meta.merge_hash(hash("kind", "fallback")));
layered_kind = layered.pick_keys("kind").sorted_values().first();
summary_count = meta.drop_keys("debug", "span").count_keys();

tree = { "a" : "A", "b" : { "y" : "B" }, "arr" : ["u", "v"] };
mapped = tree.map_leaves() {
  leaf_text = if(count(value), join_values("", value), else(value));
  return(cat(join_values("/", path), "=", leaf_text))
};
leaf_count = tree.reduce_leaves(0) {
  return(acc.add(1))
};
```

Use `has_key(...)` when the question is "does this field exist?" Use `is_defined(meta.pick_keys("kind").sorted_values().first())` or `is_defined(retv["kind"])` when the question is "is the value defined?" Those are different questions.

`set_key(...)` has two deliberate forms. As a statement with a named target, `set_key(meta, "stage", "normalized")` mutates the working hash `meta`. As a value expression, `set_key(meta, "stage", "normalized")` returns a new hash value and leaves `meta` unchanged unless you store the result with `set(meta, ...)`.

Hash receiver-dot value chains are accepted for the same pure hash helpers. The receiver is the first helper
argument, so `meta.set_key("stage", "normalized").count_keys()` maps to
`count_keys(set_key(meta, "stage", "normalized"))`. Hash-returning links can continue through more
hash helpers, and `sorted_keys()` / `sorted_values()` can continue through array receiver helpers such as
`join_values(...)`, `drop_front(...)`, and `first()`. For field reads from hash-returning receiver chains, assign
the chain result to a named hash and use `name.pick_keys(key).sorted_values().first()`. Direct bracket reads such as `retv["key"]`
are for scalar hashref payloads, not named working-hash value reads. Named mutation forms remain separate from receiver-dot pure composition:
`set_key(meta, key, value)` and `meta[key] = value` mutate the named working hash, and the hash-index assignment
form yields the updated hash snapshot in value positions. Receiver-dot `meta.set_key(key, value)` is a pure
derived value unless assigned back. A hash-yielding expression-valued block can enter the same family, for example
`{ { "b" : 2, "a" : 1 } }.sorted_keys().join_values(",")`.

Hash-tree traversal receiver blocks are the non-pure block-bearing part of the hash receiver family:

- `walk_leaves() { block }` visits leaves for side effects and returns the original hash tree.
- `map_leaves() { block }` returns a new hash tree whose leaves are the block results.
- `reduce_leaves(initial) { block }` evaluates `initial`, then folds each leaf by binding the current accumulator
  as `acc` and using the block result as the next accumulator.

A hash tree has a hash root. Nested hash values are interior nodes. Every non-hash value is a leaf, including
arrays. Traversal order is stable sorted-key depth-first order. For the tree
`{ "a" : "A", "arr" : ["u", "v"], "b" : { "y" : "B" } }`, the leaf paths are `a`, `arr`, and `b/y`.
During each callback the runtime binds scoped scalars:

| Binding | Meaning |
| --- | --- |
| `value` | current leaf value. |
| `key` | current leaf key. |
| `path` | array value containing root-to-leaf path segments. |
| `depth` | number of path segments (`count(path)`); a root leaf has depth 1. |
| `acc` | current accumulator, for `reduce_leaves` only. |

The scoped callback bindings are restored after each callback and after traversal completes. Ordinary side effects
to other working variables remain visible, so `walk_leaves()` is the side-effect traversal form. Calling any of the
three traversal methods on a non-hash receiver returns `undef` and does not execute the callback. `walk_leaves()`
and `map_leaves()` take no parenthesized arguments; `reduce_leaves(initial)` requires exactly one initial
accumulator argument. `walk_leaves()` and `map_leaves()` return hash values and can continue into later hash
receiver methods such as `.count_keys()`. `reduce_leaves(...)` returns the accumulator as a terminal value.

Array-tree traversal uses the same receiver method names on array-valued receivers. An array tree has an array root,
nested arrays as interior nodes, and scalar or hash leaves. Hash leaves are not traversed recursively. Traversal is
depth-first by zero-based index. Callback blocks get scoped `value`,
`index`, `path`, `depth`, and reduction-only `acc`. Empty arrays run no callbacks and
`reduce_leaves(initial)` returns `initial`; scalar receivers return `undef` without callbacks. `walk_leaves()` and
`map_leaves()` can feed array-family links such as `.count()`.

```text
items = ["a", ["b", "c"], { "h" : "H" }];
paths = [];

mapped = items.map_leaves() {
  return(cat(join_values("/", path), "=", value))
};

items.walk_leaves() {
  paths += join_values("/", path)
};

leaf_count = items.reduce_leaves(0) {
  return(acc.add(1))
};
```

The terse hash-index operator is the statement form written with the key next to the target:

```text
meta["stage"] = "normalized";
meta[cat("source", "_kind")] = kind;
meta[field_name] = field_value;
meta[field_name] = field_value;
```

These update the named working hash in place, exactly like `set_key(meta, key, value)`. In statement mutation
slots, bare key/RHS identifiers read scalar working variables. The expression form remains explicit:
`set_key(meta, key, value)` returns a copy instead of mutating `meta`.

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
name = coalesce(retv["name"], IMATCH, "UNKNOWN");
public_name = coalesce_nonempty(trim(name), "anonymous");
has_public_name = is_defined(public_name);
missing_kind = is_undefined(meta.pick_keys("kind").sorted_values().first());
has_items = is_nonempty(items);
no_public_meta = is_empty(pick_keys(meta, "kind", "source"));
```

Rationale:

- `coalesce(...)` keeps `0`, `""`, empty arrays, and empty hashes because they are defined.
- `coalesce_nonempty(...)` is for text fallback where blank text means "keep searching".
- `is_defined(...)` is not the same as `is_nonempty(...)`.
- `has_key(...)` is not the same as `is_defined(hash(...)[key])`.

Example:

```text
if(and(
  has_key(meta, "kind"),
  is_nonempty(meta.pick_keys("kind").sorted_values().first())
))
  return(hash("kind", meta.pick_keys("kind").sorted_values().first()));
else()
  return(hash("kind", "unknown"));
endif()
```

## Array pipelines

Array-pipeline helpers are statements or composable array-valued transformations for common token-list cleanup.

| Helper | Effect |
| --- | --- |
| `split(target, source, delimiter?)` | replace `target` with the pieces from splitting `source`. |
| `split_each(target, delimiter)` | split every current array item and flatten the result back into `target`. |
| `trim_each(target)` | trim every array item in place. |
| `filter_nonempty(target)` | remove empty string items. |
| `lowercase_each(target)` | apply the Unicode 17 full lowercase contract to every array item. |
| `uppercase_each(target)` | apply the Unicode 17 full uppercase contract to every array item. |
| `uniq(target)` | remove duplicates while preserving first-seen order. |
| `filter_match(target, /regex/)` | keep only items that match the regex. |
| `split_tagged_records(source, delimiter, tag, field...)` | build one tagged array record for each split source item. |

Worked example:

```text
Top::
 -> FieldList .push
 LX { return(copy(Top)) }

FieldList: /([A-Za-z_, ]+)/
 I {
   set(fields, []);
   raw = entry_group(0);
   split(fields, raw, /,/);
   trim_each(fields);
   filter_nonempty(fields);
   lowercase_each(fields);
   uniq(fields);
   return(hash(
     "kind", "field_list",
     "fields", copy(fields),
     "field_count", count(fields),
     "first_field", first(fields)
   ));
 }
```

Nested composition is useful when the transformation reads naturally as one expression:

```text
set(public_fields, filter_match(uniq(uppercase_each(fields)), /^[A-Z_]+$/));
lowercase_each(public_fields);
```

When `split_each(name, delimiter)`, `trim_each(name)`, `filter_nonempty(name)`, `filter_match(name, regex)`,
`lowercase_each(name)`, `uppercase_each(name)`, or `uniq(name)` appears as a standalone statement, it writes the
transformed items back to that explicit working array. In a value expression or receiver chain, the same helper
returns a transformed array value and does not mutate its input. This statement/value distinction is the reference
contract. Perl and Lua currently implement all seven statement forms; Rust, Dart, and Julia currently omit
write-back for `split_each`, `filter_match`, and `uniq`, with repair owned by `FUTURE-PARITY-BACKLOG.5`.

Receiver-dot form is equivalent when the source is a named array working variable or array-valued expression:

```text
set(public_fields, fields.uppercase_each().uniq().filter_match(/^[A-Z_]+$/));
public_csv = fields.uppercase_each().uniq().filter_match(/^[A-Z_]+$/).join_values(",");
```

Use statement style when each step deserves a readable line. Use nested style when the operation is compact and local.

Use `split_tagged_records(...)` when a comma-separated identifier list should become repeated tagged payload rows:

```text
return(split_tagged_records(
  identifier_list,
  /\s*,\s*/o,
  "?signal_declaration:",
  subtype_indication,
  signal_kind,
  expression
))
```

For `identifier_list = "a, b"`, `subtype_indication = "integer"`, `signal_kind = "register"`, and
`expression = "0"`, the exact value is:

```json
[
  ["?signal_declaration:", "a", "integer", "register", "0"],
  ["?signal_declaration:", "b", "integer", "register", "0"]
]
```

The outer array holds all records; each inner array is one record, with no extra wrapper. Source, tag, and carried
fields are evaluated once, then carried arrays or harrays are copied into every record. A scalar receiver supplies
the source, so `"a,b".split_tagged_records(",", "?item:").count()` returns `2`. This lowers to the traditional
`map { [tag, item, ...] } split ...` shape while keeping the authoring surface helper-based.

## Boolean composition

Boolean helpers make branch conditions portable and analyzable.

| Helper | Meaning |
| --- | --- |
| `and(condition, condition, ...)` | all conditions must pass. |
| `or(condition, condition, ...)` | any condition may pass. |
| `not(condition)` | invert one condition. |

These are eager value helpers: every argument is evaluated before truthiness is composed. They do not short-
circuit side effects. Use structured or inline `if`/`switch` when an unselected expression must remain unevaluated.

Current implementation status (2026-07-15): Rust and Julia execute this eager shape; Lua `.4.3.9.1` now does too
at 123/123 on both ABIs after exhaustive audit `.4.3.9.0` isolated the exact three-name gap. Dart currently returns
early after a decisive operand and gives empty `and()` true, so it is not yet the documented eager shape. Direct Perl
toolbox probes expose a separate keyword-precedence lowering defect for `return(and(...))` / `return(or(...))`.
`FUTURE-PARITY-BACKLOG.5.2` owns those evaluation/reference repairs plus truthiness and arity normalization; use
the explicit predicates above when authoring a currently portable condition at a disputed truthiness boundary.

Examples:

```text
if(and(
  has_key(meta, "kind"),
  str_eq(lowercase(trim(meta.pick_keys("kind").sorted_values().first())), "node")
))
  return(hash("kind", "node"))
endif()

if(or(
  str_eq(kind, "word"),
  str_eq(kind, "identifier"),
  matches(kind, /^name_/)
))
  return(hash("kind", "named"))
endif()

if(not(is_empty(items)))
  return(hash("kind", "items", "items", copy(items)))
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
| `else` / `else()` | open the fallback branch. |
| `endif` / `endif()` | close the flow. |

Example:

```text
if(is_undefined(meta.pick_keys("kind").sorted_values().first()))
  set(meta, set_key(meta, "kind", "unknown"))
elseif(str_eq(lowercase(trim(meta.pick_keys("kind").sorted_values().first())), "word"))
  set(meta, set_key(meta, "normalized_kind", "word"))
else
  set(meta, set_key(meta, "normalized_kind", "other"))
endif

return(copy(meta));
```

Inline composite `if(...)` and `switch(...)` are portable value-producing helpers for compact cases in
`return(...)`, assignment RHS, and fluent `.return(...)` value slots. They evaluate only the selected payload
branch. Use marker or attached-block flow when branches contain multiple statements or read better as
statement control.

```text
set(result,
  if(is_nonempty(items),
    hash("kind", "items", "items", copy(items)),
    else(undef)
  )
)
```

Use the marker form when branches contain multiple statements, nested flow, or should be visibly statement
oriented. Inline value control is the shorter portable form for single-expression branch payloads.

Attached-block form is also portable. It lowers to the same marker flow and supplies the closing
`endif` implicitly (the parenthesized `endif()` twin is also valid):

```text
if(is_nonempty(items)) {
  return(hash("kind", "items", "items", copy(items)))
} else {
  return_undef()
}
```

For attached blocks, `when(condition) { ... }` is a readable alias for the first `if` branch and
`otherwise { ... }` is a readable alias for the fallback `else` branch:

```text
when(matches(kind, /^node_/)) {
  return(hash("kind", "node", "text", kind))
} otherwise {
  return(hash("kind", "other", "text", kind))
}
```

## Inline value-control flow

Inline `if(...)` and `switch(...)` are portable value expressions when simple branch payloads need to feed
`return(...)`, an assignment RHS, or fluent `.return(...)`. They evaluate only the selected payload branch.
Use attached-block control flow when a branch needs substantial statement bodies or repeated side effects.
The short `i`/`elif` spellings are statement-marker aliases, while `when`/`otherwise` are attached-block aliases;
they are not alternate names for these inline value helpers. Some backends currently accept the aliases in the
opposite statement shape as an extension, but Rust does not; portable specs use only the documented pairing until
`FUTURE-PARITY-BACKLOG.5` normalizes acceptance.

| Helper | Meaning |
| --- | --- |
| `if(cond, then_value, branches...)` | evaluate `cond`; return `then_value` when true, otherwise choose an `elseif(...)`, `else(...)`, or plain third fallback. |
| `elseif(cond, value)` | additional inline `if` branch. |
| `else(value)` | fallback inline `if` branch. |
| `switch(value, branches...)` | evaluate `value` once and choose the first matching branch; a bare switch subject reads a working scalar. |
| `case(value, body)` | one equality case; a bare case value such as `case(foo, body)` is the literal tag `foo`, not a scalar read. |
| `default(body)` | fallback branch. |

Inline `if` example:

```text
return(if(
  is_nonempty(flag),
  cat("prefix-", flag),
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
  lowercase(trim(kind)),
  case("word", hash("kind", "word", "text", text)),
  case("space", hash("kind", "space", "text", text)),
  default(hash("kind", "unknown", "text", text))
))
```

Bare switch subjects and bare case labels intentionally mean different things:

```text
set(kind, "word")
set(other, "space")
return(switch(
  kind,
  case(word, "literal tag matched"),
  case(cat(other, ""), "dynamic expression matched"),
  default("unknown")
))
```

Here `kind` reads the scalar working variable, while `case(word, ...)` matches the literal tag
`"word"`. `case(cat(other, ""), ...)` evaluates `other` as a value expression. Prefer quoted strings such as
`case("word", ...)` when teaching fixed labels; the bare-label form is kept for parity with attached
`case(word) { ... }` labels.

Switch equality is currently portable for normalized scalar text and for null versus empty text. Do not rely on
boolean/number cross-kind or aggregate comparisons yet: Perl, Rust, and Lua make `false` match numeric zero while
Dart and Julia do not; Perl and Lua exclude arrays/harrays from scalar comparison, Rust collapses them to empty
text, and Dart/Julia retain host container spellings. Normalize those subjects explicitly before `switch` until
`FUTURE-PARITY-BACKLOG.5` fixes one typed-equality contract.

Expression-valued branch blocks are allowed in selected branches:

```text
return(if(
  true,
  { set(text, "branch"); return(text) },
  else("fallback")
))
```

Perl-reference condition truthiness treats null, false, numeric zero, `""`, and `"0"` as false. Array and harray
values are references and therefore true even when empty. Lua follows that reference boundary. Rust currently
also treats `"0"` as false but treats empty aggregates as false; Dart and Julia treat every non-empty string as
true and empty aggregates as false. Until `FUTURE-PARITY-BACKLOG.5` selects and locks one six-backend truth table,
portable conditions should use explicit predicates such as `is_empty`, `is_nonempty`, `is_defined`, and numeric
or string comparisons at those disputed boundaries.

Use attached-block `switch` for portable branch logic:

```text
switch(kind) {
  case("word") {
    return(hash("kind", "word", "text", text))
  }
  case("space") {
    return(hash("kind", "space", "text", text))
  }
  default {
    return(hash("kind", "unknown", "text", text))
  }
}
```

The attached statement form is implemented on Perl, Rust, Dart, Julia, and Lua. It uses first-match semantics and
runs `default` only when no case matched.

Marker-delimited switch is the equivalent statement-range form:

```text
switch(kind)
case(word)
  return(hash("kind", "word", "text", text))
endcase
case(space)
  return(hash("kind", "space", "text", text))
endcase
default
  return(hash("kind", "unknown", "text", text))
endswitch
```

The subject evaluates once. `endcase` is optional when the next same-depth marker already bounds the branch;
nested marker switches keep their own `endswitch` boundary. The parenthesized spellings remain valid, and all five
current backends implement both forms.
Keep every executable statement inside a `case/default` range. Perl currently executes ordinary statements before
the first branch or after `endcase()`, while Rust, Dart, Julia, and Lua skip them; backlog `.5` owns normalization.

Use `switch(...)` when the rule is classification-by-one-value. Use `if(...)` / `elseif(...)` when each branch asks a different question.

## Attached `while` flow

All five current backends accept attached-block `while` for repeated statement bodies. The condition is evaluated
before each iteration, and body statements can update the values used by the next condition:

```text
set(count, 0);
while(num_lt(count, 3)) {
  set(count, num_add(count, 1));
}
return(count);
```

`return(expr)` inside the loop returns from the surrounding action; inside an expression-valued block it remains
local to that block. The default deterministic guard is 10000 body executions. Perl, Rust, and Lua recheck the
condition after the final allowed body and succeed if it has become false; Dart and Julia currently throw at that
boundary. Avoid `next()` inside portable loop bodies too: Perl/Lua continue the inner loop, Rust treats it as a
no-op, and Dart/Julia propagate it to rule repetition. `FUTURE-PARITY-BACKLOG.5` owns both normalizations.

## Debug output helpers

`say(...)`, `print(...)`, and `print_each(...)` are statement helpers for simple diagnostic output in rule actions.

| Helper | Effect |
| --- | --- |
| `say(value, ...)` | concatenate one or more values and add one trailing newline. |
| `print(value, ...)` | concatenate one or more values without adding a newline. |
| `print_each(target, prefix, suffix?)` | emit `prefix + item + suffix` for every array item; omitted suffix is empty text. |

Examples:

```text
say("normalized kind: ", kind)
print("token=", text, " kind=", kind, "\n")
print_each(matches, "match:<<", ">>\n")
```

Use `print_each(...)` when debug output should walk an accumulated array. It is the helper-form replacement for raw Perl loops such as `print "...$_..." foreach (@matches)`.

These helpers evaluate arguments once from left to right, return no parser value, and must not add diagnostic
messages to a rule accumulator or parse-result output. Output routing is caller-owned and quiet by default in the
typed runtime design. Lua implements that boundary as
`runtime_parse(engine, input, { diagnostic_sink = function(event) ... end })`; each synchronous
`RuntimeDiagnosticOutputEvent` carries `helper_name`, `rule_label`, and exact Unicode `message` text.

Current backend routing is not yet fully aligned: Perl still lowers to host output, Rust writes direct stderr
lines and does not honor authored `print_each` prefix/suffix, Dart evaluates without emitting, and Julia routes
through trace but gives an omitted suffix a newline. Lua uses typed events and Perl-reference formatting.
`FUTURE-PARITY-BACKLOG.5.1` owns the exact five-backend normalization; portable diagnostics should therefore
supply an explicit `print_each` suffix until that leaf closes.

Use `next` when a rule edge should consume a recognized item, such as a comment, and then skip adding a value to
the current accumulator. The parenthesized `next()` spelling remains equivalent on Perl, Rust, Dart, Julia, and Lua:

```text
-> comment { next }
```

Keep public examples focused on structured return values. Use debug output helpers when the example is genuinely about tracing or demonstrating a branch.

## Worked example: normalize a child node

This example shows child capture, fallback, normalization, hash shaping, and a structured return.

```text
Node::
 I { retv = undef; set(meta, {}); }
 -> Child {
   retv = call(Child);
   set(meta, hash(
     "kind", coalesce_nonempty(trim(retv["kind"]), "node"),
     "name", coalesce_nonempty(trim(retv["name"]), "anonymous")
   ));
   set(meta, set_key(meta, "normalized_name", replace_substr(lowercase(trim(meta.pick_keys("name").sorted_values().first())), " ", "_")));
   return(copy(meta));
 }

Child: /[A-Za-z_]+/
 I { return(hash("kind", "word", "name", entry_text())) }
```

Why this reads well:

- `call(Child)` is the only child dispatch.
- `coalesce_nonempty(...)` states the fallback policy.
- `set_key(...)` states that one field is added to a copy of the object.
- `copy(...)` states that the final object is returned as a payload.

## Worked example: head/tail array result

This example shows array appends, boundary reads, array helpers, and branch predicates.

```text
Sequence::
 I { set(items, []); retv = undef; }
 -> Item {
   retv = call(Item);
   items += retv;

   if(num_gt(count(items), 1))
     return(hash(
       "kind", "sequence",
       "head", first(items),
       "rest", drop_front(items),
       "item_count", count(items)
     ));
   else()
     next();
   endif()
 }
 LX { return(hash("kind", "single", "item", first(items))) }

Item: /\s*[A-Za-z_]+/
 I { return(hash("text", trim(entry_text()))) }
```

The important choice is the append operation: each child result is appended, here with `items += retv`. The final `return(...)` uses pure array helpers to read or derive views from the accumulated array without mutating it.

## Worked example: classify with switch

This example shows value normalization and switch classification.

```text
Top::
 -> Kind .push
 LX { return(copy(Top)) }

Kind: /[A-Za-z_]+/
 I {
   raw = entry_text();
   kind = replace_substr(lowercase(trim(raw)), "-", "_");

   switch(kind) {
     case("word") { return(hash("kind", "word", "raw", raw)) }
     case("space") { return(hash("kind", "space", "raw", raw)) }
     case("node") { return(hash("kind", "node", "raw", raw)) }
     default { return(hash("kind", "unknown", "raw", raw)) }
   }
 }
```

The switch is better than a long `elseif` ladder because every branch is driven by the same normalized value.

## Practical guidance

- Prefer `return(payload)` for new structured returns.
- Prefer `copy(array(...))` and `copy(hash(...))` when returning a nested snapshot.
- Prefer `flat_array(...)` and `flat_hash(...)` when splicing into a surrounding constructor.
- Prefer `items += expr` / `push(...)` when appending; do not use whole-array assignment as a disguised append.
- Prefer `meta["field"] = expr` / `set_key(meta, "field", expr)` when updating one hash field; use `set_key(hash_expr, key, value)` when you need a copied hash value.
- Prefer `has_key(...)` for field existence and `is_defined(...)` for value definedness.
- Prefer `coalesce_nonempty(trim(...), fallback)` for human text fallback.
- Prefer numeric helpers and `num_*` comparisons for counts, indexes, depths, and lengths.
- Prefer statement-style array pipelines when each normalization step deserves a readable line.
- Prefer `switch(...)` when one value drives classification; prefer `if(...)` when each branch has different logic.
