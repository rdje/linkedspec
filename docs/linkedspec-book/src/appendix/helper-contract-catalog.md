# Helper Contract Catalog

This appendix is the **canonical behavioral reference** for every ActionIR helper.
Each entry defines the helper's contract — signature, input/output types, semantics,
edge cases — at enough precision for a Rust, Julia, or Dart backend to implement
identically. No Perl implementation knowledge is required.

## 1. Declaration Helpers

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

### `assign(name, value)`
- **Signature**: `assign(name: string, value: expr)`
- **Returns**: void
- **Behavior**: Reassigns a previously declared working variable. The variable must exist.
- **Errors**: Assigning to an undeclared variable.

## 2. Scalar Helpers

### `scalar(container, key)`
- **Signature**: `scalar(container: array|hash, key: int|string)`
- **Returns**: scalar or undef
- **Behavior**: Reads a single value from an array (by 0-based index) or hash (by string key).
- **Edge cases**: Returns `undef` if the key does not exist or container is not array/hash.

### `concat(args...)`
- **Signature**: `concat(a: scalar, b: scalar, ...)`
- **Returns**: scalar
- **Behavior**: Concatenates all arguments as strings. Undef arguments are treated as empty strings.
- **Edge cases**: Non-scalar arguments (arrays, hashes) return `undef` for the whole expression.

### `coalesce(a, b, ...)`
- **Signature**: `coalesce(values: scalar...)`
- **Returns**: scalar
- **Behavior**: Returns the first argument that is defined (not undef). Evaluates left-to-right, short-circuiting.
- **Edge cases**: Returns `undef` if all arguments are undef.

### `coalesce_nonempty(a, b, ...)`
- **Signature**: `coalesce_nonempty(values: scalar...)`
- **Returns**: scalar
- **Behavior**: Returns the first argument that is defined and not the empty string `""`. Preserves `0` and other defined values.
- **Edge cases**: Returns `undef` only if all arguments are undef or `""`.

### `is_defined(expr)`
- **Signature**: `is_defined(value: expr)`
- **Returns**: boolean
- **Behavior**: Returns true if the value is not undef. Accepts any expression type.
- **Edge cases**: Empty string, `0`, and empty arrays are defined.

### `is_undefined(expr)`
- **Signature**: `is_undefined(value: expr)`
- **Returns**: boolean
- **Behavior**: Returns true if the value is undef. Logical inverse of `is_defined`.

### `trim(s)`
- **Signature**: `trim(value: scalar)`
- **Returns**: scalar
- **Behavior**: Removes leading and trailing whitespace. Returns undef if input is undef.
- **Edge cases**: A string of only whitespace becomes `""`.

### `lowercase(s)`
- **Signature**: `lowercase(value: scalar)`
- **Returns**: scalar
- **Behavior**: Converts to lowercase. Returns undef if input is undef.

### `uppercase(s)`
- **Signature**: `uppercase(value: scalar)`
- **Returns**: scalar
- **Behavior**: Converts to uppercase. Returns undef if input is undef.

### `length(s)`
- **Signature**: `length(value: scalar|array)`
- **Returns**: int
- **Behavior**: Returns the character length of a string or the element count of an array. Returns undef for undef input.

### `matches(s, /pattern/)`
- **Signature**: `matches(value: scalar, pattern: regex)`
- **Returns**: boolean
- **Behavior**: Returns true if the value matches the regex pattern. The pattern is a literal `/regex/` — no variable interpolation.
- **Edge cases**: Returns false for undef input.

### `starts_with(s, prefix)`
- **Signature**: `starts_with(value: scalar, prefix: scalar)`
- **Returns**: boolean
- **Behavior**: Returns true if the value starts with the exact prefix string.

### `ends_with(s, suffix)`
- **Signature**: `ends_with(value: scalar, suffix: scalar)`
- **Returns**: boolean
- **Behavior**: Returns true if the value ends with the exact suffix string.

### `contains_substr(s, needle)`
- **Signature**: `contains_substr(value: scalar, needle: scalar)`
- **Returns**: boolean
- **Behavior**: Returns true if the value contains the needle as a substring.

### `replace_substr(s, old, new)`
- **Signature**: `replace_substr(value: scalar, old: scalar, new: scalar)`
- **Returns**: scalar
- **Behavior**: Replaces all literal occurrences of `old` with `new`. Returns undef if value is undef. This is a **literal** replacement, not a regex substitution.
- **Edge cases**: If `old` is empty, returns the value unchanged.

### `rm_prefix(s, prefix)`
- **Signature**: `rm_prefix(value: scalar, prefix: scalar)`
- **Returns**: scalar
- **Behavior**: Removes the prefix from the value if present. Returns the value unchanged if the prefix does not match. Returns undef if value is undef.

### `rm_suffix(s, suffix)`
- **Signature**: `rm_suffix(value: scalar, suffix: scalar)`
- **Returns**: scalar
- **Behavior**: Removes the suffix from the value if present. Returns the value unchanged if the suffix does not match. Returns undef if value is undef.

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

### `flat_array(arr)`
- **Signature**: `flat_array(arr: array)`
- **Returns**: list (splices into parent context)
- **Behavior**: Flattens an array into list context for insertion into a parent container. Used with `hash(...)`, `array(...)`, and lifecycle accumulator returns.

### `concat_arrays(a1, a2)`
- **Signature**: `concat_arrays(a: array, b: array)`
- **Returns**: array
- **Behavior**: Returns a new array containing all elements of `a1` followed by all elements of `a2`. Neither input is mutated.

### `push(arr, child)`
- **Signature**: `push(target: array, child: expr)`
- **Returns**: void
- **Behavior**: Appends `child` to the named accumulator array. The target must be a declared array variable (typically the rule's implicit accumulator, named after the rule label).
- **Convention**: `push(Child)` without explicit target appends to the current rule's implicit accumulator — this is the `push_child_call_builtin` convention. Use `push_value(target, value)` for explicit targeting.

### `push(arr, child, index)`
- **Signature**: `push(target: array, child: expr, index: int)`
- **Returns**: void
- **Behavior**: Appends `child` at a specific position. Index disambiguation: if the second argument is an integer, it is treated as an index, not a target name.
- **Edge cases**: The disambiguation relies on `\d+` (integer) matching before `\w+` (target name). `push(arr, child, 0)` means index 0; `push(arr, child, "name")` means target "name".

### `push_value(arr, value)`
- **Signature**: `push_value(target: array, value: expr)`
- **Returns**: void
- **Behavior**: Appends a value to the named accumulator. The preferred explicit form over convention-based `push(Child)`.
- **Edge cases**: Value can be any expression type. Undef values are appended as-is (use `push_nonempty` to skip).

### `push_nonempty(arr, value)`
- **Signature**: `push_nonempty(target: array, value: expr)`
- **Returns**: void
- **Behavior**: Appends the value only if it is defined and non-empty. Skips undef and empty strings.

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

### `sorted_keys(hash)`
- **Signature**: `sorted_keys(h: hash)`
- **Returns**: array
- **Behavior**: Returns the hash's keys as an array, sorted alphabetically. Deterministic — does not depend on host-language hash iteration order.

### `sorted_values(hash)`
- **Signature**: `sorted_values(h: hash)`
- **Returns**: array
- **Behavior**: Returns the hash's values as an array, sorted by their corresponding keys alphabetically. Deterministic.

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
- **Behavior**: Constructs a hash from flat key/value pairs. Arguments are interpreted as alternating keys and values. Accepts `flat_array(...)` and `flat_hash(...)` for list-context insertion.
- **Edge cases**: Duplicate keys: last value wins. Odd number of arguments: the last key gets `undef` value.

### `flat_hash(h)`
- **Signature**: `flat_hash(h: hash)`
- **Returns**: list (splices into parent context)
- **Behavior**: Flattens a hash into alternating key/value list context for insertion into `hash(...)` or `array(...)`.

### `hash_copy(h)`
- **Signature**: `hash_copy(h: hash)`
- **Returns**: hash
- **Behavior**: Shallow copy. The new hash has the same keys and values but is a distinct container.

### `merge_hash(h1, h2)`
- **Signature**: `merge_hash(base: hash, overlay: hash)`
- **Returns**: hash
- **Behavior**: Merges `h2` into `h1`. Keys in `h2` override keys in `h1`. Neither input is mutated — returns a new hash.

### `set_key(h, key, value)`
- **Signature**: `set_key(h: hash, key: string, value: expr)`
- **Returns**: hash
- **Behavior**: Returns a new hash with the key set to the value. Does not mutate the input.

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

### `num_add(a, b)`
- **Signature**: `num_add(a: numeric, b: numeric)`
- **Returns**: numeric
- **Behavior**: Adds two numbers. Returns `undef` if either operand is non-numeric.

### `num_sub(a, b)`
- **Signature**: `num_sub(a: numeric, b: numeric)`
- **Returns**: numeric
- **Behavior**: Subtracts `b` from `a`.

### `num_mul(a, b)`
- **Signature**: `num_mul(a: numeric, b: numeric)`
- **Returns**: numeric
- **Behavior**: Multiplies two numbers.

### `num_div(a, b)`
- **Signature**: `num_div(a: numeric, b: numeric)`
- **Returns**: numeric
- **Behavior**: Divides `a` by `b`. Returns `undef` on divide-by-zero.

### `num_mod(a, b)`
- **Signature**: `num_mod(a: numeric, b: numeric)`
- **Returns**: int
- **Behavior**: Modulo operation. Returns `undef` for divide-by-zero or non-integer operands.

### `num_abs(x)`
- **Signature**: `num_abs(x: numeric)`
- **Returns**: numeric
- **Behavior**: Absolute value.

### `num_floor(x)`
- **Signature**: `num_floor(x: numeric)`
- **Returns**: int
- **Behavior**: Floor — largest integer ≤ x.

### `num_ceil(x)`
- **Signature**: `num_ceil(x: numeric)`
- **Returns**: int
- **Behavior**: Ceiling — smallest integer ≥ x.

### `num_round(x)`
- **Signature**: `num_round(x: numeric)`
- **Returns**: int
- **Behavior**: Rounds to nearest integer (half-up).

### `num_min(a, b)` / `num_min(arr)`
- **Signature**: `num_min(a: numeric, b: numeric)` or `num_min(arr: array)`
- **Returns**: numeric
- **Behavior**: Two-argument form: returns the smaller of two numbers. Array form: returns the minimum element. Returns `undef` for empty array, non-array, or non-numeric elements.

### `num_max(a, b)` / `num_max(arr)`
- **Signature**: `num_max(a: numeric, b: numeric)` or `num_max(arr: array)`
- **Returns**: numeric
- **Behavior**: Two-argument form: returns the larger. Array form: returns the maximum element.

### `num_clamp(x, lo, hi)`
- **Signature**: `num_clamp(x: numeric, lo: numeric, hi: numeric)`
- **Returns**: numeric
- **Behavior**: Clamps `x` to the `[lo, hi]` range. Returns `undef` if bounds are inverted (`lo > hi`).

### `num_sum(arr)`
- **Signature**: `num_sum(arr: array)`
- **Returns**: numeric
- **Behavior**: Sum of array elements. Returns `0` for empty array. Returns `undef` for non-array or non-numeric element sources.

### `num_avg(arr)`
- **Signature**: `num_avg(arr: array)`
- **Returns**: numeric
- **Behavior**: Arithmetic mean of array elements. Returns `undef` for empty array, non-array, or non-numeric elements.

### `num_median(arr)`
- **Signature**: `num_median(arr: array)`
- **Returns**: numeric
- **Behavior**: Median of array elements after numeric sort. For even-length arrays, returns the average of the two middle elements. Returns `undef` for empty array, non-array, or non-numeric elements.

### `num_range(arr)`
- **Signature**: `num_range(arr: array)`
- **Returns**: numeric
- **Behavior**: `max - min` of array elements. Returns `undef` for empty array, non-array, or non-numeric elements.

## 6. Control Flow Helpers

### `if(cond, then, elseif(cond2, then2), else(default))`
- **Signature**: Inline composite form. All branches are evaluated expressions.
- **Returns**: value of the selected branch.
- **Behavior**: Evaluates conditions left-to-right. First true condition's branch is returned. If none match, the `else` branch is returned. If no else and no match, returns undef.

### `if(cond) { ... } elseif(cond2) { ... } else { ... } endif()`
- **Signature**: Attached-block form.
- **Returns**: no return value (side effects from block execution).
- **Behavior**: Each branch is a code block. Conditions evaluated left-to-right. First true condition's block executes. `else` block runs if no condition matches. `endif()` terminates.
- **Sugar**: `else` (bare), `endif` (bare), and `else()` / `endif()` are equivalent.
- **Mixed carriers**: Branches can mix attached-block (`{ ... }`) and lighter plain-marker bodies.

### `switch(expr) { case(val) { ... } default { ... } } endswitch()`
- **Signature**: Outer block switch.
- **Returns**: no return value (side effects from block execution).
- **Behavior**: Evaluates `expr` once. Compares to each `case(val)`. First matching case's block executes. `default` runs if no match.
- **Sugar**: `endswitch`, `default`, `endcase` accept bare-keyword forms.

### `case(val) { ... }`, `case(val, { ... })`
- **Signature**: Inline switch branch.
- **Returns**: branch body value.
- **Behavior**: Embedded in inline-composite `switch(expr, case(...), ...)` or attached-block `switch`.

### `default { ... }`, `default({ ... })`
- **Signature**: Default switch branch.
- **Returns**: branch body value (inline) or void (block).

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
- **Returns**: the value (from the lifecycle block).
- **Behavior**: Canonical return from a lifecycle block. Returns the value to the parent rule's accumulator.
- **Edge cases**: `return(array(...))` returns an array value. `return(scalar(...))` returns a scalar.

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
All helpers support **unlimited nested composition**. Example:
```
count(drop_front(sorted_keys(merge_hash(hash_copy(base), overlay))))
```
Any helper that accepts an array can receive the output of any array-returning helper. Any helper that accepts a scalar can receive the output of any scalar-returning helper.

### Fluent / Block Equivalence
Every helper can be used in both structured-block form (`I { declare(...) }`) and fluent-chain form (`.declare(...)`). Both forms lower to identical ActionIR and produce identical behavior. This equivalence is regression-locked across all 10 families on all 7 lifecycle markers.

### Undef Propagation
Most helpers propagate `undef` from their inputs to their outputs. Explicit `coalesce(...)` is the canonical way to provide a default. No helper silently converts `undef` to `0` or `""` unless documented otherwise.

### No Mutation Guarantee
Helpers that return arrays or hashes (`array_copy`, `hash_copy`, `merge_hash`, `set_key`, `rename_key`, `drop_keys`, `pick_keys`, `sorted_keys`, `sorted_values`, `drop_front`, `drop_back`, `take`, `take_last`, `slice`, `sorted`, `reversed`, `concat_arrays`, `filter_nonempty`, `filter_match`, `uniq`, `split`, `split_each`, `trim_each`, `lowercase_each`, `uppercase_each`) do **not** mutate their inputs. They return new containers.

### Compatibility Aliases (Retired)
The following are retired and must not be used in new `.spec` authoring. Backends may implement them for compatibility with legacy specs but should treat them as deprecated:

| Retired | Use Instead |
|---|---|
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
