# Formal `.spec` Grammar

This appendix defines the `.spec` file syntax with enough precision for an independent
implementation in any language (Rust, Julia, Dart, etc.). It does **not** describe how
the Perl backend parses — it describes **what** constitutes valid `.spec` syntax and
**what** each construct means.

Every shipped LinkedSpec backend must accept exactly the language defined here.
Backends must parse that language into typed AST/IR before lowering or execution;
textual helper rewrites directly into host-language source are legacy implementation
debt, not part of the contract.

## 1. File and Paragraph Model

A `.spec` file is a sequence of top-level **function definitions** and **rule paragraphs**,
not a line-oriented grammar. A rule paragraph starts with a **rule header** and continues
until the next rule header or end of file after top-level function definitions have been
removed for the current bootstrap bridge. Everything between two rule headers belongs to
the first rule's paragraph.

Rule headers are recognized **only at top level**: a line matching a rule-label
pattern inside an open `{ }` block is block content, not a new rule.
Function definitions are also recognized only at top level.

```text
Top::
 /a/ -> Next {
 return(array("?Top:", array_copy(array(Top))))
 }

Next::
 /b/ { return(array("?Next:", array_copy(array(Next)))) }
```

Here `return(...)` is block content inside `Top`, and `Next::` starts a new paragraph.

### 1.1 Leading Whitespace, Comments, and Blank Lines

Before the first rule paragraph, a `.spec` file may contain:
- Blank lines (zero or more)
- Comment lines starting with `#` (zero or more)

After the first rule paragraph, blank lines and comment lines between paragraphs
are **not** part of any rule.

### 1.2 Top-Level Function Definitions

Top-level user-function definitions use this syntax:

```text
fn name(param1, param2) {
 action statements or value expressions
}

fn no_args() {
 return("ok")
}
```

The first implementation accepts explicit parentheses for every arity, including zero
arity. Parameter names are comma-separated identifiers. A definition's body is parsed as
an ActionIR action block, so it uses the same helper/value/block DSL described in §7.

Function definitions are file-level declarations. They are not rule paragraphs, not rule
labels, and not valid inside action/lifecycle blocks. They may appear at top level before
or between ordinary rule paragraphs; the current Perl reference strips them before the
hardcoded bootstrap parser sees the rule source, while preserving line numbers for
diagnostics.

As of `SPEC-FORMAT-TERSE.4.2.3`, the Perl reference validates and records functions in the
descriptor registry and executes registered exact-arity calls in value positions and
standalone discard statements. A call such as `return(normalize(" x "))` evaluates the
argument first, binds it to the function's parameter in a fresh function-local scope, and
returns the body result. A standalone `normalize(" x ")` computes that value and discards it
through the canonical `VALUE_DROP` path. Calls can feed helper arguments and compatible
receiver-dot chains. Recursive and unsupported function-body forms are fenced as
diagnostics with zero raw fallback on the Perl reference, and Rust directly diagnoses
recursive user-function calls. Rust now parses, validates, compiles, and executes the
same MVP function surface, including value calls, compatible receiver chains, standalone
discard, and fresh function-local scope.

The registry rejects:

- duplicate function names
- invalid or duplicate parameters
- reserved runtime/lifecycle/function symbols
- names that collide with built-in helper/control names, including numeric word aliases such as `add`
- names that collide with rule labels

The finalized MVP function surface is deliberately narrow. The only accepted definition
spelling is top-level `fn name(args) { ... }`, with explicit parentheses for every
arity and a braced body. Zero-argument functions therefore use `fn name() { ... }`;
`fn name { ... }` is not part of the language. Function bodies are value-oriented:
they may use the supported helper/value/block DSL and function-local working variables,
then return the final expression or an explicit `return(expr)` payload.

The following are deferred extension topics, not accepted syntax or semantics:

- alternate definition spellings such as `function name(args) ... endfunction` or
  `fn name(args) ... endfn`
- optional zero-argument parentheses
- brace-less or single-expression body forms
- functions whose observable purpose is caller-state, parser-state, or persistent
  side-effect mutation rather than a returned value
- direct or mutual recursive user functions
- closures, lambdas, currying, partial application, or implicit caller-scope capture
- future namespace/module features for functions

## 2. Rule Header

A rule header is a single token at the start of a line (after optional leading
whitespace on that line):

```
rule_label  :  [mode]  [rest-of-line]
rule_label  :: [mode]  [rest-of-line]
```

### 2.1 Rule Labels

A rule label is one or more word characters: `[A-Za-z0-9_]+`.

- **Single colon** (`rule_name:`): a **body rule** — may appear anywhere in the file.
- **Double colon** (`rule_name::`): a **top rule** — the parser entry point. At least
  one top rule must exist. A `.spec` file may define multiple top rules.

The double colon is purely an **entry marker**: it designates the rule a backend enters
first. A top rule is otherwise an **ordinary rule** — it may carry a regex, take any rule
mode (§2.2), and be recursive (§5.4), exactly like a body rule. The common "no regex on
the top rule, dispatch to body rules that carry the regex" two-rule shape is recommended
**idiom**, not a constraint a backend enforces.

### 2.2 Rule Modes

The mode suffix, if present, immediately follows the colon(s) with no space:

| Mode | Meaning | Typical placement |
|---|---|---|
| *(no suffix)* | Repeated choice (default). Equivalent to `:OR+`. Handled by `:*`. | Any rule (top or body) |
| `:AND` | Ordered sequence. Each child regex matched in order. | Body rule (idiom) |
| `:OR` | Repeated choice across alternatives. | Body rule (idiom) |
| `:&` | Ordered sequence (equivalent to `:AND`). | Body rule (idiom) |
| `:\|` | Single choice — one successful alternative wins (`:OR{1}`). | Body rule (idiom) |
| `:+` | One-or-more repeated choice (`:OR{1,}`). Equivalent to `:*` bounded. | Body rule (idiom) |
| `:*` | Zero-or-more repeated choice (`:OR{0,}`). | Body rule (idiom) |
| `:?` | Zero-or-one choice (`:OR{0,1}`). | Body rule (idiom) |
| `:OR+` | Unbounded repeated choice (one or more). | Body rule (idiom) |
| `:AND+` | Unbounded repeated ordered sequence (one or more). | Body rule (idiom) |
| `:AND{N}` | Ordered sequence repeated exactly N times. | Body rule (idiom) |
| `:AND{N,M}` | Ordered sequence repeated N to M times. | Body rule (idiom) |
| `:AND{N,}` | Ordered sequence repeated N or more times. | Body rule (idiom) |
| `:AND{,M}` | Ordered sequence repeated up to M times. | Body rule (idiom) |
| `:OR{N}` | Repeated choice exactly N times. | Body rule (idiom) |
| `:OR{N,M}` | Repeated choice N to M times. | Body rule (idiom) |
| `:OR{N,}` | Repeated choice N or more times. | Body rule (idiom) |
| `:OR{,M}` | Repeated choice up to M times. | Body rule (idiom) |

Where `N` and `M` are non-negative integers.

The **Typical placement** column records the recommended **idiom**, not a backend
restriction. Because a top (`::`) rule is an ordinary rule that is merely entered first
(§2.1), a mode suffix may appear after either colon form — `Top::AND`, `Stream::OR+`,
and `Pair::&` are all valid. Body-rule placement is the convention; the engine does not
reject a mode on a top rule.

**Semantics**:
- **AND modes** match child regexes sequentially, in order, exactly once per repetition.
- **OR modes** try each alternative independently on each repetition; the first match
  wins. On the next repetition, all alternatives are retried from the new position.
- **Bounded repetition** loops the specified number of times. The loop terminates when
  the bound is reached or when a child fails to match (for `{N,}` and `{N,M}` forms).
- **Zero-progress guard**: repeated modes refuse to loop infinitely when a child
  succeeds but consumes zero input. The parser detects zero-progress and terminates
  the loop to prevent a hang.

### 2.3 Rest-of-Line After Header

Any text on the same line after the rule label + colon(s) + optional mode is the
**header rest**. The header rest may carry:
- A regex cluster (the rule's first regex anchor)
- Body elements on the same line (compact style)

Same-line body elements are semantically equivalent to body elements on subsequent
lines — the paragraph model is unchanged.

## 3. Rule Body Elements

After the rule header, the rule paragraph contains zero or more **body elements**.
Body elements may span multiple lines. The following body element types exist:

### 3.1 Regex Clusters

```
/pattern/flags
```

A regex literal delimited by `/`. The pattern body may contain escaped forward
slashes (`\/`). Flags are expressed **inline**, inside the pattern, using modifier
groups such as `(?i)`, `(?m)`, `(?s)`, or scoped forms like `(?s:…)` — the `.spec`
layer adds no flag system of its own beyond what the host regex engine supports.

**Semantics**: A regex cluster anchors the parser at a specific input position.
In `consume` mode (`\G`-anchored), the regex must match contiguously from the
current position. In `seek` mode (ungrounded `//gcp`), the regex may match
anywhere. The mode is determined by the rule mode and runtime parse mode.

Multiple regex clusters in a row form an ordered sequence for AND-mode rules
or a set of alternatives for OR-mode rules. When clusters are combined as
alternatives, the engine records **which** alternative matched (0-based) and uses
that to drive dispatch.

**Capture groups**: A `(...)` group is a **numbered** capture; a `(?<name>...)`
group is a **named** capture. Action code reads them with `entry_group(N)` /
`match_group(N)` (numbered) and `entry_named(name)` / `match_named(name)` (named).
Numbered groups are **0-based over the captured groups** — index `0` is the *first*
capture group, not the whole match (the whole match is `entry_text()` /
`match_text()`) — and the numbered list is **compacted**, so a group that did not
participate in the match is dropped and shifts the indices after it. Named groups
are keyed by name and are not affected by compaction. The
[Regex in `.spec`](../user-model/regex-in-spec.md) chapter gives the full mental
model with worked examples, and states the regex feature set a backend must support.

### 3.2 Action Edges

```
-> TargetRule       (shorthand for -> TargetRule[0])
-> TargetRule[N]    (selects regex slot N of TargetRule)
```

An action edge binds the current rule to a child rule via an **action code block**.
After the regex cluster(s) match, the parser transfers to `TargetRule` and executes
its associated action code.

- **Target indexing**: `-> rule` means entry slot `[0]`. `-> rule[N]` selects a
  later regex slot of the same rule (used for same-rule recursive entry).
- **Grouped targets**: `-> RuleA | RuleB { ... }` binds one shared action code
  block to multiple target rules.
- **Grouped-target boundary**: the shared block is mandatory. `-> RuleA | RuleB`
  without `{ ... }` is invalid; use separate action edges when there is no shared
  block to factor.

### 3.3 Blind-Call Edges

```
=> ChildRule
```

A blind-call edge delegates to `ChildRule` **without** an action code block. The
child rule's own action code runs. This is used for parser orchestration where the
parent rule controls dispatch but does not transform the child's result.

Blind-call behavior follows the **rule label mode**, not the edge alone. Explicit
`:AND` on the child rule is required for sequential blind-call dispatch. A bare
`rule:` label with blind-call edges still behaves as repeated choice.

### 3.4 Code Blocks (Action / Lifecycle)

```
{ code }
```

A `{ }` block contains **action code** or **lifecycle code**. The block's context
determines how the code is interpreted:

- **After an action edge** (`-> rule { ... }`): the block is the **action code** for
  that edge. It runs after the child rule completes. The block can declare variables,
  read captures, transform results, and return values.

- **After a blind-call edge** (`=> rule { ... }`): deprecated but accepted as
  compatibility syntax. Prefer lifecycle blocks for blind-call rules.

- **As a standalone block**: the block is **lifecycle code** for the rule itself (or
  for a blind-call rule body). Lifecycle blocks use lifecycle markers to control
  execution order (see §4).

Blocks nest: `{ ... { ... } ... }`. Opening brackets `{`, `(`, `[` inside a block
must be balanced by their closing counterparts. A rule paragraph with an unclosed
block at end of file is invalid.

### 3.5 Split Markers

```
@capture_slice
@capture_from_here       (compatibility alias for @capture_slice)
@move_pos                (compatibility alias for @capture_slice)
@mark(name)
```

Split markers control anonymous and named capture boundaries during parsing:
- `@capture_slice`: moves the anonymous capture-start cursor to the current position.
- `@mark(name)`: stores the current absolute position under a named mark for later
  retrieval via `capture_from(name)`, `capture_between(...)`, etc.

### 3.6 Lifecycle Markers

```
I
LS
LE
E
EX
IT
LX
```

Lifecycle markers define **when** code blocks execute relative to the rule's
children:

| Marker | Meaning |
|---|---|
| `I` | Initialization — runs before any child is attempted. |
| `LS` | Loop start — runs before each repetition of a repeated rule. |
| `LE` | Loop end — runs after each child match in a repeated rule. |
| `E` | Exit — runs after all children complete successfully. |
| `EX` | Exit (extended) — runs after E, can observe the final result. |
| `IT` | Iteration — per-child iteration context. |
| `LX` | Loop exit — runs after a repeated rule's loop terminates. |

Lifecycle markers are **semicolon-light structured authoring**: a marker followed by
`{ code }` is a lifecycle block. Portable branch control includes statement markers,
attached-block `if` forms, attached `switch`, attached `while`, and inline-composite `if`/`switch` value
expressions in supported value positions.
Within structured blocks, newlines separate top-level helper statements implicitly.
Semicolons remain accepted and are required when multiple top-level helper statements
share one physical line. Plain same-line whitespace is not a statement separator, and
semicolons inside nested expressions or literal payloads remain protected.
Lifecycle blocks are not expression-valued blocks: ordinary final statement values are
discarded, and only an explicit top-level `return(expr)` writes the rule return channel.

In value positions, a non-empty `{ ... }` payload without a top-level `=>` is an
expression-valued block on the Perl reference and Rust backend. It returns the final
expression unless a `return(expr)` statement is reached earlier; that `return(expr)`
exits only the expression-valued block, skips later statements in that block, and
yields `expr` as the block value. Empty `{}` and top-level-fat-arrow `{ key => value }`
forms remain hash literals. Because the block is a value expression, it may also be the
receiver of a compatible receiver-dot chain, such as `{ [3, 1, 2] }.sorted().join_values(",")`
or `{ " a-b " }.trim().split("-").count()`.

### 3.7 Fluent Chains

```
.method1(arg).method2(arg2).method3()
```

A fluent chain on an action edge or inside a lifecycle block uses dot-method syntax.
Each method is a helper from the ActionIR helper families (§7). For ordinary helper statements,
compact lifecycle-marker receiver chains and structured block forms are equivalent. Cross-backend
portability is guaranteed for structured marker/attached-block forms, receiver-fluent
`when/otherwise` block chains on action-edge and lifecycle-marker surfaces, action-edge
`.push` / `.return(expr)` / `.return_undef()` continuations, explicit action-edge
`.push(target)` / `.push(child,target)` child-return appends, statement-control fluent chains that
gate those calls, and compact lifecycle-marker chains such as `I.return(expr)` or
`I.declare(...).return(...)`.

Zero-arg fluent control-flow markers accept bare-keyword form:
```
.else   .endif   .default   .endcase   .endswitch
```

These are equivalent to their parenthesized forms `.else()`, `.endif()`, etc.

### 3.8 Conditional Markers

```
-? word
```

A conditional marker is a hyphen-question prefix followed by a word. It carries
metadata about optional or conditional dispatch — recognized structurally but its
semantics are determined by the consuming rule.

### 3.9 Word-Based Body Code

```
word(args...) { ... }
method(args...)
```

A word followed by parenthesized arguments and optionally a code block. This
covers helper calls, declarations, control flow, and raw compatibility code.
See §7 for the canonical helper families.

## 4. Lifecycle Execution Model

For a rule with children (edges), execution follows a fixed lifecycle order:

1. **I** — initialization block runs once.
2. For each repetition (repeated rules only):
   a. **LS** — loop-start block runs.
   b. Child regexes are matched.
   c. Action or blind-call code runs for matched children.
   d. **LE** — loop-end block runs (receives child result).
3. **IT** — per-child iteration context runs.
4. **E** — exit block runs.
5. **EX** — extended exit block runs.
6. **LX** — loop-exit block runs (repeated rules only, after loop termination).

For non-repeated rules, LS, LE, and LX are skipped.

## 5. Parse Modes

### 5.1 Seek Mode

The default parse mode for OR-type rules. The regex is matched ungrounded (`//gcp` —
match anywhere in the remaining input). Each repetition finds the next match position.
Use `seek` when children may appear in any order or at variable positions.

### 5.2 Consume Mode

Used for AND-type rules and explicit `consume` directives. The regex is `\G`-anchored —
it must match contiguously from the current position. Use `consume` for ordered
sequences where input must be consumed in exact order.

### 5.3 BACKTRACK and IBACKTRACK

`BACKTRACK` performs a **local cursor rewind**: if a child match fails or a condition
is unmet, the parser rewinds the input position (the cursor) to where it was before the
attempt. This is a local rewind — not systemic backtracking. LinkedSpec does not
maintain a search tree, unwind partial rule matches, or restore alternative-choice
state.

`IBACKTRACK` is the case-insensitive variant.

### 5.4 Recursion and Forward-Progress Termination

A rule may recurse: an action edge (`-> rule` / `-> rule[N]`) or a `call(rule)`
expression (§7.10) may re-enter the same rule, directly or through a cycle of rules.
Recursion may re-enter the **top rule** as well — the top rule is an ordinary rule
(§2.1), so a single recursive document can be parsed by a recursive top rule directly.

The one requirement is **forward progress (consume before you recurse)**: every
recursive cycle must consume input before it recurses. Idiomatic recursion does this
naturally — a parenthesis rule matches `(`, recurses, then matches `)`, so each level
advances the cursor.

A backend **must** guarantee termination of a non-progressing cycle: if a rule is
re-entered at an input position already active on its own recursion stack (no input was
consumed since that entry), the re-entry is **cut** — it yields `undef` — so the parser
terminates instead of recursing without bound. This is a hard requirement, not an
optimization: a backend that recurses natively without this guard can exhaust its call
stack on a no-consume cycle. The cut fires **only** on genuine non-progress, so
legitimate consume-before-recurse recursion (which advances the position before each
re-entry) is never affected.

A recursive rule used **as the top rule** is still an ordinary accumulating rule, so it
needs a loop-exit (`LX`) block to surface its accumulator at end of input, exactly like
any accumulating top rule. Without the `LX` it returns `undef` at end of input (the
missing-`LX` authoring case), not a partial result.

## 6. Comments

```
# comment text
```

A `#` at the beginning of a line (after optional whitespace) starts a comment.
Comments are not part of any rule paragraph. Comments inside rule paragraphs
(after the header line) are not supported.

## 7. Helper DSL Families

Inside `{ }` code blocks and on fluent chains, `.spec` authoring uses a
backend-neutral method-like helper DSL. This section catalogs the canonical
families. For the full behavioral contract per helper, see the
[Helper Contract Catalog](helper-contract-catalog.md).

Primitive value literals are accepted anywhere an explicit value expression is
accepted:

```text
"text" / 'text'   — string
42 / -1 / 3.14    — number
true / false      — typed boolean
undef             — undefined/null
```

`true` and `false` are boolean values, not strings. Literal recognition is exact:
`trueword`, `false_alarm`, and `undefine` are identifiers, not literals. In supported
scalar read slots such as `return(trueword)` and `items += trueword`, those identifiers
are working-variable reads.

Helper calls use the uniform `callee(args)` shape. Whitespace between the callee
name and the opening parenthesis is accepted (`set (name, value)` is the same call
as `set(name, value)`), but the parentheses are still mandatory; no-parenthesis
spellings such as `set name, value` or `return scalar name` are not helper calls.

Direct nested access is a value-expression form:

```text
direct_access : name direct_segment+
direct_segment : '[' quoted_string ']'
               | '[' bare_identifier ']'
               | '[' explicit_index_expr ']'
```

The base `name` is a working scalar that holds a structured array/hash payload.
Quoted string segments (`["field"]` or `['field']`) are hash-key reads. Numeric
segments and helper/value expressions (`[0]`, `[scalar(i)]`, `[add(1, 2)]`) are
array-index reads. Non-reserved bare path atoms such as `[i]` are also scalar
array-index reads, equivalent to `[scalar(i)]`. Primitive literals and engine
locals are not claimed as bare path atoms.

### 7.1 Declaration Helpers
```
declare(scalar, name)      — declare a scalar working variable
declare(array, name)       — declare an array working variable
declare(hash, name)        — declare a hash working variable
declare(scalar, name=value) — declare with initializer
assign(name, value)         — reassign a working variable
return(name)                — read and return a scalar working variable
```

### 7.2 Scalar Helpers
```
base["key"][0]                 — direct nested access into scalar-held payloads
scalar(container, key)          — read a scalar entry from an array or hash
concat(args...)                 — concatenate strings
coalesce(a, b, ...)             — first defined non-null value
coalesce_nonempty(a, b, ...)    — first defined non-empty value
is_defined(expr)                — true if expr is not undef
is_undefined(expr)              — true if expr is undef
trim(s)                         — remove leading/trailing whitespace
lowercase(s)                    — lowercase
uppercase(s)                    — uppercase
length(s)                       — string/array length
matches(s, /pattern/)           — regex match predicate
starts_with(s, prefix)          — prefix check
ends_with(s, suffix)            — suffix check
contains_substr(s, needle)      — substring check
replace_substr(s, old, new)     — literal string replacement
rm_prefix(s, prefix)            — remove prefix
rm_suffix(s, suffix)            — remove suffix
substr(s, start, len?)          — substring from zero-based start
string_expr.trim().lowercase()
                        — receiver-dot string value chain over compatible pure scalar helpers
string_expr.split(delim).trim_each().join_values(delim)
                        — explicit string-to-array receiver-chain bridge
```

### 7.3 Array Helpers
```
array(name)            — read array working variable name when name is bare
array(e1, e2, ...)     — construct an array; prefer [...] for terse literals
array_copy(arr)        — shallow copy
array_values(arr)      — retired alias of array_copy (do not use; see Helper Contract Catalog §Compatibility-Aliases)
flat_array(arr)        — flatten into list context for insertion
concat_arrays(a1, a2)  — concatenate arrays
push(arr, child)        — append child to accumulator
push(arr, child, index) — append child at index
push_value(arr, value)  — append value to accumulator
push_nonempty(arr, val) — append if non-empty
target.push_back(value) — append value to named working array (statement)
target.push_front(value) — prepend value to named working array (statement)
target.pop_back()       — remove last item from named working array (statement)
target.pop_front()      — remove first item from named working array (statement)
count(arr)              — number of elements
first(arr)              — first element
last(arr)               — last element
take(arr, n)            — first n elements (default 1)
take_last(arr, n)       — last n elements (default 1)
drop_front(arr, n)      — all but first n (default 1; alias: tail)
drop_back(arr, n)       — all but last n (default 1; alias: drop_last)
slice(arr, start, n)    — subarray from start, n elements
sorted(arr)             — sorted ascending
reversed(arr)           — reversed order
arr.sorted().first()    — receiver-dot array value chain over compatible pure array helpers
{ [3, 1, 2] }.sorted().join_values(delim)
                        — expression-valued block yielding an array as a receiver
sorted_keys(hash)       — keys sorted by name, as array
sorted_values(hash)     — values sorted by key name, as array
hash_expr.set_key(k, v).sorted_keys().join_values(delim)
                        — receiver-dot hash value chain over compatible pure hash/array helpers
contains(arr, needle)   — array membership test
index_of(arr, needle)   — first index of needle
is_empty(arr)           — true if array/hash is empty
is_nonempty(arr)        — true if array/hash has elements
join_values(delim, arr) — join array elements with delimiter
split(s, delim)         — split string into array
split_each(arr, delim)  — split each element
trim_each(arr)          — trim each element
filter_nonempty(arr)    — remove empty elements
filter_match(arr, /re/) — keep elements matching regex
uniq(arr)               — remove duplicates
lowercase_each(arr)     — lowercase each element
uppercase_each(arr)     — uppercase each element
print_each(arr)         — debug output each element
```

### 7.4 Hash Helpers
```
hash(name)              — read hash working variable name when name is bare
hash(k1, v1, k2, v2)    — construct a hash from flat key/value pairs
flat_hash(h)             — flatten hash into list context
hash_copy(h)             — shallow copy
merge_hash(h1, h2)       — merge h2 into h1 (returns new hash)
set_key(h, key, val)     — set key to value (returns new hash)
rename_key(h, old, new)  — rename key (returns new hash)
drop_keys(h, k1, k2...)  — remove keys (returns new hash)
pick_keys(h, k1, k2...)  — keep only named keys (returns new hash)
has_key(h, key)          — key presence test
count_keys(h)            — number of keys
```

### 7.5 Numeric Helpers
```
num_add(a, b)            — addition
num_sub(a, b)            — subtraction
num_mul(a, b)            — multiplication
num_div(a, b)            — division (undef on divide-by-zero)
num_mod(a, b)            — modulo (undef on divide-by-zero or non-integer)
num_abs(x)               — absolute value
num_floor(x)             — floor
num_ceil(x)              — ceiling
num_round(x)             — round to nearest integer
num_min(a, b)            — minimum (also reducer: num_min(arr))
num_max(a, b)            — maximum (also reducer: num_max(arr))
num_clamp(x, lo, hi)     — clamp to [lo, hi] range
num_sum(arr)             — sum of array elements
num_avg(arr)             — average of array elements
num_median(arr)          — median of array elements
num_range(arr)           — max - min of array elements

abs(x), floor(x), ceil(x), round(x)      — aliases for the matching num_* helpers
add(a, b), sub(a, b), mul(a, b)          — aliases for num_add/num_sub/num_mul
div(a, b), mod(a, b), clamp(x, lo, hi)   — aliases for num_div/num_mod/num_clamp
min(...), max(...), sum(arr)             — aliases for num_min/num_max/num_sum
avg(arr), median(arr), range(arr)        — aliases for num_avg/num_median/num_range
+(a, b), -(a, b), *(a, b)                — aliases for num_add/num_sub/num_mul
/(a, b), %(a, b)                         — aliases for num_div/num_mod
eq(a, b), ne(a, b), gt(a, b)             — aliases for num_eq/num_ne/num_gt
ge(a, b), lt(a, b), le(a, b)             — aliases for num_ge/num_lt/num_le

number_expr.abs().ceil().add(n).mul(n)  — receiver-dot number helper chain
number_expr.gt(n)                       — terminal receiver-dot numeric comparison
```

The terse function aliases above are ordinary calls, not infix operators, so
they do not introduce precedence. Write nested calls such as `+(*(a, b), c)` when
you need grouping. Comparison word aliases are numeric calls over the matching
`num_*` helpers. Comparison symbols such as `>(a, b)`, `>=(a, b)`, and
`==(a, b)` are still deferred. The task-tree-owned comparison migration has
added the explicit string-comparison bridge names `str_eq`, `str_ne`, `str_gt`,
`str_ge`, `str_lt`, and `str_le`; use those shipped names for lexical string
comparisons.

### 7.6 Control Flow Helpers
```
if(cond, then, elseif(cond2, then2), else(default))    — portable lazy value form
if(cond); ... elseif(cond2); ... else(); ... endif()
if(cond) { ... } elseif(cond2) { ... } else { ... }
when(cond) { ... } otherwise { ... }
switch(expr, case(val, body), default(body))           — portable lazy value form
case(val, body)
default(body)
exit_now(status)         — exit parser immediately
next()                   — skip to next repetition (consume/recognize without append)
return(value)            — return value (canonical form)
return_undef()           — return undef
return(array(...))       — return array
```

### 7.7 Capture/Mark Helpers
```
capture_slice()                    — text from anonymous start cursor to current position
capture_slice_len()                — length of capture_slice
capture_until_cursor_from(name)    — text from named mark to current cursor
capture_rest_from(name)            — text from named mark to end of input
capture_between(start, end)        — text between two named marks
capture_from(name)                 — text from named mark to current position
capture_take_len_from(name)        — take length from named mark
start_capture_slice()              — move anonymous capture-start cursor to current pos
mark_input_start(name)             — mark absolute input-start boundary
mark_input_end(name)               — mark absolute input-end boundary
mark_copy(name)                    — copy a named mark
```

### 7.8 Entry/Match Helpers
```
entry_text()          — full text of the current match entry
entry_group(index)     — capture group by index
entry_groups()         — all capture groups as flat array
entry_named(name)      — named capture group
entry_has(name)        — does named group exist
entry_map()            — named groups as hash (alias: entry_named_map)
entry_len()            — length of matched text
entry_start_pos()      — absolute start position
entry_end_pos()        — absolute end position
entry_end_line()       — line number of end position
entry_end_col()        — column of end position
match_text()           — full text of local match
match_group(index)      — local match capture group
match_groups()          — all local match groups
match_named(name)       — local named capture
match_has(name)         — does local named group exist
match_map()             — local named groups as hash
match_len()             — length of local match
match_start_pos()       — local match start position
match_end_pos()         — local match end position
```

### 7.9 Input Helpers
```
input_text()            — entire current input
input_slice(start, len) — substring of current input
input_len()             — length of current input
input_end_line()        — line number of input end
input_end_col()         — column of input end
```

### 7.10 Call Expression
```
call(child_rule)         — call a child rule directly from action code
```

## 8. Authoring Styles

`.spec` files support two equivalent authoring styles:

The lifecycle blocks (`I`/`LS`/`LE`/`E`/`EX`/`IT`/`LX`) are top-level rule-paragraph
members — siblings of the `->`/`=>` edges, never nested inside an edge's `{ … }`. The
two styles below differ only in how the **edge's own action code** is written.

### 8.1 Structured Block Form
```
Top::
 I { declare(array, results) }
 -> Child {
   push_value(array(results), call(Child))
 }
 LX { return(array_copy(array(results))) }
```

### 8.2 Fluent Chain Form
```
Top::
 I { declare(array, results) }
 -> Child .push_value(array(results), call(Child))
 LX { return(array_copy(array(results))) }
```

Both forms lower to identical ActionIR and produce identical parser behavior.
The choice is stylistic.
In either form, structured block bodies use the same statement separator rule: newline
between top-level helper statements is enough, while multiple helper statements on one
physical line require semicolons.

## 9. Attached-Block Control Flow

Within lifecycle blocks, portable branch control includes attached-block `if`, marker statements, and inline
composite expressions. Marker-style `if` is implemented on the Perl reference and Rust backend:

```
I {
 if(matches(scalar(value), /^yes$/));
 assign(scalar(result), "confirmed");
 elseif(matches(scalar(value), /^no$/));
 assign(scalar(result), "rejected");
 else();
 assign(scalar(result), "unknown");
 endif()
}
```

Inline-composite `if(...)` and `switch(...)` are portable value expressions in supported value positions:

```
E {
 return(if(is_nonempty(scalar(type)),
   "typed",
   else("missing")
 ))
}
```

```
E {
 return(switch(scalar(type),
   case("regex", "regular expression"),
   case("edge", "edge"),
   default("other")
 ))
}
```

Round 2 is extending this surface. Perl and Rust now accept attached-block
`if(...) { ... } elseif(...) { ... } else { ... }`, including compact same-line continuations;
attached-block `when(...) { ... } otherwise { ... }` as aliases for `if(...) { ... } else { ... }`;
and attached-block `switch(...) { case(...) { ... } default { ... } }` with first-match/default semantics.
Rust normalizes attached branch forms where that matches its statement-control runtime. Perl and Rust now
accept attached `while(...) { ... }` with condition re-evaluation and a deterministic 10000-iteration
loop-safety guard.
Inline value-form `if(...)` and `switch(...)` are portable on Perl and Rust in supported value-consuming slots:
`return(...)`, assignment RHS, and fluent `.return(...)`.
Zero-argument markers that are already implemented, such as `else`/`endif`,
accept bare-keyword form in addition to parenthesized form.

## 10. Constraints and Validation

A valid `.spec` file must satisfy:

1. At least one top rule (`::`) exists.
2. Every rule label is unique. Duplicate labels are rejected.
3. Every function name is unique and must not collide with any rule label or built-in helper/control name, including numeric word aliases such as `add`.
4. Function parameters must be unique valid identifiers and must not use reserved runtime/lifecycle/function symbols.
5. Rule and function definitions must not appear inside open `{ }` blocks.
6. Every `{ }` block opened inside a rule paragraph or function body must be closed before end of file.
7. Every `->` edge target must reference an existing rule.
8. Every regex cluster must be a compilable regex literal.
9. Rule mode suffixes must use exact supported spellings (§2.2).
10. Stray preamble text before the first rule paragraph or top-level function definition (after blank/comment lines) is
   rejected.
11. Action edges and blind-call edges must not be mixed in a single rule (mixed-edge
   detection). A rule with both `->` and `=>` edges is invalid.

## 11. Compatibility Surface

The following are **legacy compatibility constructs** recognized for migration
tracking but not recommended for new `.spec` authoring:

- Raw Perl expressions and ad hoc operators outside the documented helper/operator slots
- `return_a`, `return_m`, `return_ma`, `return_imatch`/`return_im` (retired)
- `s(...)`, `a(...)`, `h(...)` — use `scalar(...)`, `array(...)`, `hash(...)`
- `array_values(...)` — use `array_copy(...)`
- `flatten(...)` — use `flat(...)`
- `tail(...)` — use `drop_front(...)`
- `drop_last(...)` — use `drop_back(...)`
- `capture_slice_here()` — use `start_capture_slice()`
- `capture_from_rule_start()` — use `capture_slice()`
- `capture_slice_length()` — use `capture_slice_len()`
- Bare `return`, bare `next`, bare `exit` — use `return_undef()`, `next()`, `exit_now(1)`

All 20 shipped `.spec` files compile with zero compatibility-surface rules.
New `.spec` files must maintain this invariant.

## 12. Complete Example

```text
# A complete .spec file showing all major constructs
DemoParser::
 I  { declare(array, results) }
 LS { declare(scalar, retv) }
 /pattern1/ -> Child { assign(scalar(retv), call(Child)) }
 LE { if(is_defined(scalar(retv))); push_value(array(results), scalar(retv)); endif() }
 E  { return(array("?result:", array_copy(array(results)))) }

Child::
 /hello[ \t]+(\w+)/
 I { declare(scalar, name=entry_group(0)) }
 E { return(scalar(name)) }

SecondChild:OR+
 /(?:\w+)/
 E { return(array("?words:", array_copy(array(SecondChild)))) }

ThirdChild:AND
 /first/ -> A
 /second/ -> B
```

This grammar:
- `DemoParser::` is a top rule with one action edge to `Child` plus lifecycle blocks.
- `Child:` is a body rule with a single regex + lifecycle blocks.
- `SecondChild:OR+` is a repeated-choice rule.
- `ThirdChild:AND` is an ordered-sequence rule with two edges.
