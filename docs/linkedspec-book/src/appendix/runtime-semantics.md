# Runtime Semantics

> **Current implementation and accepted migration:** The executable details in
> this appendix describe shipped behavior. ADR `0044` ratifies the rule-local
> contract: OR/default families seek, AND families consume,
> parent and edge kind never override a child, and the public/global
> `parse_mode` option is removed. Perl, Rust, Dart, Julia, and dual-ABI Lua are
> composed-admitted. One recurring gate now proves all six runtime legs plus the
> selected 5x2x5 primary projection. Public no-drift is closed at 8 complete / 0 pending.
> ADR `0048` accepts per-hit action-result collection for explicit repetition and
> scalar pipe choice. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT implement it.
> The neutral contract plus ten-role Perl and byte-identical 15-role
> Rust/Dart/Julia/Lua admissions compose through one recurring gate. Public
> no-drift is closed at 8 complete / 0 pending with 54 rejected mutations.

This appendix defines LinkedSpec's runtime behavior at the precision needed for
independent reimplementation. Every backend must produce identical behavior for the
same `.spec` input. No Perl implementation knowledge is required.

> **Cursor terminology.** Throughout this appendix, *the cursor* (or *input
> position*) is the backend-neutral name for the current parse position. The Perl
> reference backend spells it `pos($input)`; a different backend uses its own
> position primitive. The behavioral contracts below are what every backend must
> reproduce, independent of that spelling.

## 1. Derived Cursor Policies

### 1.1 Seek Mode

**Default for OR-type rules** (repeated choice: `:*`, `:+`, `OR+`, bare `rule:`).

The regex is matched **ungrounded** — match anywhere in the remaining input, with the
cursor tracking position (the Perl reference backend uses `//gcp`). Each repetition
finds the next match from the current position.

**Behavioral contract:**
1. Set the match start position to the current cursor.
2. Execute the regex with ungrounded semantics (match anywhere from the current cursor).
3. On match: advance the cursor to the match end, return the match info.
4. On no match: the rule terminates (loop exits).

**Key property**: Children can match in any order. Gaps between matches are
acceptably skipped. This is an extraction-oriented mode — the parser finds what
it can, where it can.

### 1.2 Consume Mode

**Used for AND-type rules** (ordered sequence: `AND` mode and `:&`).

The regex is **`\G`-anchored** — it must match contiguously from the current
position. The match must start exactly at the current cursor.

**Behavioral contract:**
1. Anchor the regex at the current cursor.
2. Execute the regex with `\G` anchoring (match ONLY at the current position).
3. On match: advance the cursor to the match end.
4. On no match: the rule terminates (loop exits, or error).

**Key property**: Children must match in order, contiguously. No gaps allowed.
This is a structuring mode — the parser consumes input in exact sequence.

### 1.3 Cursor Policy Determination

The cursor policy for a rule is determined by:
1. The **rule mode** from the label (`:AND` → consume, `:OR` and default → seek).
2. The **handler variant** selected by the compiler.
3. AND variants use consume. OR and REP variants use seek.
4. Any internal runtime representation derives the policy from authored family;
   it cannot be caller-overridden or serialized as a second semantic authority.

## 2. Rule Execution Model

### 2.1 Non-Repeated Rules

A rule with mode `:AND` (bounded, non-repeated) or compact AND `:&`:

1. If the rule has an **I-block**: execute it once.
2. Match the child regex(es) once.
3. If the match succeeds, execute the action/blind-call code for the matched child.
4. If the rule has an **E-block**: execute it once.
5. Return the accumulated result.

### 2.2 Repeated Rules

A rule with repetition (`:*`, `:+`, `:?`, `OR`, `OR+`, `AND+`, bounded `{N,M}` forms):

1. If the rule has an **I-block**: execute it once.
2. Enter the repetition loop:
   a. If the rule has an **LS-block**: execute it before each match attempt.
   b. Match the child regex(es).
   c. On match: execute action/blind-call code for the matched child.
   d. If the rule has an **LE-block**: execute it after each successful match,
      receiving the child's return value.
   e. If the rule has an **IT-block**: execute it per iteration.
   f. Check repetition bounds: if `rep_min` matches remain and the match failed,
      this is an error. If `rep_max` matches are reached, exit the loop.
   g. **Zero-progress guard**: if a child succeeds but consumed zero characters,
      increment a zero-progress counter. If the counter reaches a threshold,
      exit the loop to prevent infinite repetition.
   h. Continue loop from (a).
3. After loop exit:
   a. If the rule has an **EX-block**: execute it.
   b. If the rule has an **LX-block**: execute it (loop-exit finalization).
   c. If the rule has an **E-block**: execute it (final return).
4. Return the accumulated result.

### 2.3 Repetition Bounds

| Mode | `rep_min` | `rep_max` | Meaning |
|---|---|---|---|
| `:*` | 0 | unbounded | Zero or more |
| `:+` | 1 | unbounded | One or more |
| `:?` | 0 | 1 | Zero or one |
| `{N}` | N | N | Exactly N |
| `{N,M}` | N | M | N to M |
| `{N,}` | N | unbounded | N or more |
| `{,M}` | 0 | M | Up to M |

Unbounded is represented as a large sentinel value (≥ 10⁹). Implementations should
use an explicit "unbounded" representation.

### 2.4 Explicit repeated-action result channel

For action-edge handlers in `:*`, `:+`, `:?`, `:OR`, `:OR+`, and bounded
`:OR{...}`, an explicit edge `return(value)` produces the successful iteration's
value. The handler completes the successful-iteration path, appends one typed
value to the ordered rule collection, and continues while its bound and progress
permit. It does not treat the edge return as an immediate whole-rule exit.

The collection is flat only at the iteration boundary: a returned array remains
one nested element, and an explicit null remains one null element. Zero allowed
hits return `[]`; failure below `rep_min` retains the reference null/failure
result. `:OR` has `rep_min = 1` and generated family `rep_acode` (or `rep_bcode`
for blind calls). `:|` is non-repeating and returns its selected action value
directly.

Lifecycle `return(...)` retains whole-rule authority. A backend must distinguish
the return's action-edge context from `I`/`LS`/`LE`/`LX`/`IT`/`EX`/`E` rather
than changing the meaning of every return event.

This is the accepted ADR `0048` contract and current Perl/Rust/Dart/Julia/Lua behavior.
Every newer backend proves the same channel split in native and generated execution
while retaining generated-source v2. Dart, Julia, and Lua capture the value at the
action-edge boundary, which allows implicit child dispatch to complete before
lifecycle control resumes. Neutral and all five backends are complete, and the recurring gate composes their
exact consumers plus a five-command/default-POSIX projection. Repeated-action recurring/public no-drift is closed at 8 complete / 0 pending
with 54 rejected mutations.

## 3. Lifecycle Execution Order

The lifecycle markers execute in this **fixed order** for each rule:

```
I  →  [LS → match → LE → IT] × N  →  EX → LX → E
```

### 3.1 I (Initialization)
- Runs **once** when the rule handler is first entered.
- Used for declaring working variables, setting up state.
- Executes before any child is attempted.

### 3.2 LS (Loop Start)
- Runs **before each repetition** in repeated rules.
- Not executed for non-repeated rules.
- Used for per-iteration setup.

### 3.3 LE (Loop End)
- Runs **after each successful child match** in repeated rules.
- Receives the child's return value via the `retv` variable.
- Used for collecting child results into accumulator arrays.

### 3.4 IT (Iteration)
- Runs **per iteration** in repeated rules (REP variants).
- Used for per-iteration collection logic in REP handlers.

### 3.5 EX (Extended Exit)
- Runs **after the repetition loop terminates** in repeated rules.
- Used for loop-exhaustion fallback logic.

### 3.6 LX (Loop Exit)
- Runs **after loop termination** in repeated rules.
- **Important**: LX fires after the loop completes. Using LX in `AND+` rules
  can trigger loop re-entry — prefer `E` for exit logic unless loop re-entry
  is intentional.

### 3.7 E (Exit)
- Runs **once** when the rule handler completes (after all children, after loop termination).
- Used for final return value assembly.
- The canonical place to return the rule's result.

## 4. Explicit Cursor Controls

### 4.1 Cursor Stack and Anchor Rewinds

LinkedSpec exposes explicit cursor controls, not systemic backtracking:

1. `save_cursor()` pushes the live cursor onto an explicit cursor stack.
2. `restore_cursor()` pops the stack and restores the live cursor to that saved
   position. Empty stack is a no-op.
3. `rewind_match_start()` rewinds the live cursor to the start of the current
   local match.
4. `rewind_entry_start()` rewinds the live cursor to the start of the
   initial/entry match for the current context. This is the same initial-match
   context exposed to the `I` lifecycle.
5. `capture_until_boundary(rule[, ...])` seeks from the live cursor for the
   earliest match of any named boundary rule, captures the text before that
   match, and leaves the cursor at the boundary start without consuming the
   boundary. If valid boundary rules exist but no boundary is found, it captures
   to end-of-input and moves the cursor there. If no requested boundary can be
   resolved, it returns `undef` and leaves the cursor unchanged.
6. These operations change only the live input cursor. Match records, accumulators,
   variables, and other side effects are not rolled back.

**What these helpers are NOT:**
- It does NOT maintain a search tree of alternative parse paths.
- It does NOT unwind partial rule matches beyond the single local attempt.
- It does NOT restore accumulator state, variable declarations, or side effects
  from the failed attempt — only the input cursor position.
- LinkedSpec has **no systemic backtracking** across the parse tree.

### 4.2 Interaction with Parse Mode

After either explicit restore or anchor rewind, the next match attempt uses the
**rule's declared parse mode** (seek or consume) from the restored position.
These helpers do not change the parse mode.

The zero-width/lookahead boundary primitive is separate: it detects that a
structural token would match at a boundary without consuming that token, so a
rule can capture up to the boundary and leave the cursor ready for the normal
rule path.

## 5. Accumulator and Output Shape

### 5.1 Rule Accumulator

Each rule has an implicit accumulator array: the rule's working array variable.
For a rule named `Foo`, the accumulator is conventionally `$Foo` (or `@Foo`).
Lifecycle blocks collect child results into this accumulator.

### 5.2 `push(Child)` Convention

`push(Child)` without explicit target appends to the current rule's implicit
accumulator. This is the `push_child_call_builtin` convention — the target is
the rule's own accumulator array.

```text
Foo::
 -> Bar {push(Bar)}    # push(Child) appends Bar's result to the implicit accumulator @Foo
LX {return(copy(Foo))}
```

The `I`/`LS`/`LE`/`E`/`EX`/`IT`/`LX` lifecycle blocks are **top-level rule-paragraph
members — siblings of the `->`/`=>` edges**, not nested inside an edge's `{ … }` (an edge
block holds only that edge's action code).

Lifecycle blocks are statement blocks. They run their statements in lifecycle order and discard
ordinary statement values; a final `set(...)`, helper call, or value expression is not an implicit
rule return. Use a top-level `return(expr)` statement when a lifecycle block must write the
surrounding rule return channel. This is separate from expression-valued blocks (§5.3), where
`return(expr)` is block-local and yields only that value block's result.

### 5.3 Explicit Accumulation

`push(target, value)` targets a named accumulator explicitly. The terse
spelling `push(target, value)` is equivalent when the value position is
unambiguous:

```text
Foo::
 I { results = [] }
 -> Bar {push(results, retv)}
E {return(copy(results))}
```

```text
Foo::
 -> Bar {results += retv}
E {return(copy(results))}
```

All-bare `push(A, B)` keeps the child-call meaning: `A` is a child rule and `B`
is the target accumulator. To append a working-variable value, write
`items += value` or `push(results, value)`.
Bare scalar reads are currently supported in return and assignment-like source slots such as
`return(value)`, `set(out, value)`, and `out = value`, in mutation slots such as
`items += value`, and in direct-access path atoms such as `payload["children"][index]`.
Use the bare name when the source should visibly read a working scalar.

Assignment also has a value form. `name = "ok"` and `=(name, "ok")` store the scalar and evaluate to the stored
value, so they can appear inside `return(...)`, helper arguments, expression-valued blocks, user-function bodies,
and compatible scalar receiver chains such as `=(raw, " text ").trim()`. Direct shape RHS assignments participate
in the same value contract as typed value binding: `items = [value]`, `set(items, [value])`, and
`=(items, [value])` bind an array value to `items` and evaluate to that stored array value; `meta = { key : value }`
binds a hash value and evaluates to that stored hash value. `set(items, ...)` and `set(meta, ...)` bind the same
observable typed values as bare assignment. Mutation assignments also have expression
values: `items += value` appends to the named array and evaluates to the updated array snapshot. On Perl,
`meta[key] = value` updates the typed root selected by the evaluated string/nonnegative-integer key and yields the
updated root snapshot; remaining backends retain their earlier named-hash interpretation until admission.

Nested value-path assignment mutates scalar-held array/hash payloads through direct access syntax:
`payload["items"][0]["name"] = value`. On Perl and Rust, each evaluated string/nonnegative-integer segment selects an
harray/array. The first selector may create an absent root, and the next selector may create a missing
intermediate. Bound null and other wrong kinds are not coerced; arrays replace or append exactly at length and
reject gaps. Segments evaluate once left-to-right, then the RHS once, before isolated structural validation.
Success commits and yields a detached updated root. Invalid selectors, kind conflicts, and gaps throw typed
diagnostic objects and commit no partial path; already completed expression effects retain ordinary semantics.
Reads never create state. Dart, Julia, and Lua retain the prior existing-intermediate/null-result boundary
until the remaining implementation and public-admission leaves complete.

Array end mutations are also statement-level operations on a named working array:
`items.push_back(value)` appends, `items.push_front(value)` prepends, `items.pop_back()`
removes the last element, and `items.pop_front()` removes the first element. The receiver
may be bare (`items`) or explicitly typed (`items`). Push values use
the same mutation-slot expression rules as `items += value`, so a bare value reads the
scalar working variable (`$value` on the Perl reference). The pop methods discard the
removed value; value-returning forms such as `return(items.pop_back())` are not part of
this statement-level contract.

A non-empty brace payload without a top-level hash-pair delimiter can also be used as a value
block in value-consuming sites. The block runs its statements and yields the final
expression unless a `return(expr)` statement is reached earlier. That `return(expr)`
exits only the expression-valued block, skips later statements in that block, and
yields `expr` as the block value; it does not set the surrounding rule's return
channel. Empty `{}` and top-level hash-pair `{ key : value }` forms remain hash
shape literals on every current native backend. Ordinary assignment does not defer the block:
`callback = { return("later") }` stores `"later"`. Contextual trailing blocks and explicit
`{|params| ...}` callable values are separate codeblock paths.

Julia constructs explicit `{|params| ...}` values as the same inert eight-field typed state used by the portable
contract, including fixed/final-rest signatures and containing Unicode-character spans. Construction, copying,
serialization, generated reconstruction, and semantic inspection do not execute or capture the body. Julia now
invokes a bound value through `cb(args)` after static callables, with copied/restored parameter bindings, live
nonparameter caller stores, local return/results, typed failures, and ordered recursion rejection. Julia also
preserves exact final-only callable metadata and normalizes only signature-governed attached/parenthesized final
blocks through the same executor.

Lua follows the same rule on PUC Lua and LuaJIT. One typed record crosses native compilation, canonical effective-
`SpecFile` reconstruction, generated-plan execution, and independently loaded emitted modules. Built-in final
callbacks resolve before scoped `value` and enter the ordinary dynamic executor as contextual, explicit, or bound
values. Only ordinary bound names participate in recursion tracking, so nested anonymous built-in callbacks are
not a helper-name cycle.

On Perl, Rust, Dart, Julia, and Lua, callable metadata may declare one final codeblock parameter. At those governed call sites,
`call(args) { statements }` and `call(args, { statements })` defer the immediate block as the same
zero-positional `codeblock_argument`; the body reads the current dynamic context when invoked. In every ordinary
argument position, `{ statements }` remains an eager block value. An explicit `{|params| statements }` always
keeps its authored signature, and a keyed `{ key : value }` always remains an harray rather than being promoted by
position. A typed final slot rejects a non-codeblock value as `final_argument_not_codeblock`.

```text
return({ set(name, "ok"); name })          # "ok"
set(out, { set(name, "ok"); return(name) })
```

When an expression-valued block is the receiver of a receiver-dot value chain, the
block evaluates first and its yielded value becomes the receiver for the existing
helper family. For example, `{ [3, 1, 2] }.sorted().join_values(",")` evaluates the
block to an array, then applies the ordinary array receiver-chain contract; `{ " a-b " }.trim().split("-").count()`
does the same through string helpers and the explicit `split` array bridge.

Named harray mutation through `set_key(meta, "stage", "normalized")` remains explicit. On Perl,
`meta["stage"] = "normalized"` has the same observable field update but runs through typed-path assignment;
`meta[0] = value` instead selects an array. An absent target is created from the selector, while bound null/wrong
kinds and array gaps are typed failures. In mutation slots, bare selector/RHS identifiers read scalar working
variables. When `meta[key] = value` is used as an expression, it yields the detached updated root snapshot.

### 5.4 Return Value

Outside explicit repeated-action handlers, the rule's portable return value is
whatever an explicit `return(...)` in an action or lifecycle block yields. In
the explicit repetition families listed in §2.4, an action-edge return is one
iteration value and the default rule result is the ordered collection of those
values. Lifecycle returns remain whole-rule returns in every family.

Lifecycle blocks are statement blocks: a final `set(...)`, helper call, or value
expression is not a portable implicit return. A rule that should surface an
accumulator should say so directly, for example `return(copy(accumulator))`.

### 5.5 What a Parser Returns (Top-Level Output)

A compiled `.spec` parser, invoked on input, returns **the value the top rule
produces** — exactly what the top rule's terminating lifecycle block (`E` / `LX`) or
`return(...)` yields. There is no extra envelope around it: the output type is whatever
the rule returns (a scalar, an array, or a hash), structurally unchanged. A backend that
implements this contract must hand back that same value.

The following are **verified** input→output pairs (the Perl reference is the behavioral
oracle):

```text
Top::
 -> Done {
   retv = call(Done);
   return("scalar-ok");
 }

Done: /x[a-z]+/
 I { return(entry_text()) }
```
Input `xhello` → output `"scalar-ok"` — a bare scalar.

```text
Top::
 -> Done {
   retv = call(Done);
   return(array("?proof:", "ok"));
 }

Done: /x[a-z]+/
 I { return(entry_text()) }
```
Input `xhello` → output `["?proof:", "ok"]` — an array.

```text
Top::
 -> Pair {
   retv = call(Pair);
   return(retv);
 }

Pair: /(\w+)=(\w+)/
 I {
   return(array("?pair:", entry_group(0), entry_group(1)));
 }
```
Input `key=val` → output `["?pair:", "key", "val"]` — here the author chose an array
holding an (optional, §5.6) leading tag plus the two captures (`entry_group(0)` is the
first capture group when `Pair` is entered; see [Regex in `.spec`](../user-model/regex-in-spec.md#capture-groups)).
The top rule returns the dispatched `Pair` result directly, so that value becomes the
parser's top-level output (§5.7).

### 5.6 The Output Shape Is the Author's Choice

A rule may return **any structure the grammar author finds convenient** — a bare scalar,
a flat array, a nested array, a hash, or any composition of these. LinkedSpec imposes
**no output schema**: the parser hands back whatever the rule builds (§5.5 already shows
scalar and array results). How you shape your AST is entirely up to you.

**One optional convention** appears in parts of the shipped corpus — the **tagged array**:
the first element is a string tag of the form `"?<rule>:"` naming the producing rule, with
the payload after it.

```text
Top::
 -> object {
   retv = call(object);
   return(retv);
 }

object: /(?i)object:\s+(\S+)/
 I { return(array("?object:", flat_array(entry_groups()))) }
```
Input `object: foo` produces `["?object:", "foo"]`; a tag-only form is used when a
node carries no payload:

```text
Top::
 -> manifest {
   retv = call(manifest);
   return(retv);
 }

manifest: /(?is)manifest:\s+.+?\n\n/
 I { return(array("?manifest:")) }
```
Input `manifest: body\n\n` → `["?manifest:"]`.

This convention is **purely optional** — an older self-describing-AST style some specs
adopt so a consumer can identify each node by its leading tag. **Nothing in the engine
requires, privileges, or even recognizes it**: the `"?...:"` tag is just an ordinary
string, the convention lives only in the *spelling*, and a backend needs no tag-specific
machinery — it simply builds whatever array, hash, or scalar the spec asks for. You are
free to use a different convention, or none at all. (Specs that happen to use the tagged
style include `ds_vhistory.spec`, `portmap.spec`, `vhdl.spec`, and `regdef.spec`;
`array(...)` is the array constructor, and `flat_array(...)` splices
an array-valued expression such as `entry_groups()` into the array.)

### 5.7 `return(...)` versus the accumulator

Two distinct mechanisms produce a rule's data; do not conflate them:

- The **implicit accumulator** (§5.1–§5.3) is the rule's working array; `push(Child)` /
  `push(target, value)` append to it across repetitions.
- **`return(expr)`** normally sets the rule's **return value** — the value the
  parent sees for that rule. In an explicit repeated-choice action edge, it
  instead supplies one per-hit iteration value to the rule's default collection
  (§2.4). Lifecycle returns retain the whole-rule channel.

A child rule's `return(...)` becomes that child's value for the parent to consume
**explicitly** (for example `push(results, call(Child))`); it is **not**
auto-appended to the parent's accumulator. A common top-level pattern uses both — collect
children into the accumulator, then return a snapshot of it:

```text
... return(array("?ds_vhistory:", copy(vhistory))) ...
```

(from `ds_vhistory.spec`), where `copy(vhistory)` snapshots the rule's
`vhistory` accumulator; the `"?ds_vhistory:"` tag here is just the optional convention
from §5.6 — the author could return the snapshot in any shape.

### 5.8 Backend Output Reconciliation (the one-level wrap)

The **canonical, backend-neutral output is the reference value** — what the Perl
reference returns (the §5.5 examples). A backend whose run loop returns the top rule's
*accumulator array* rather than its bare return value will produce that reference value
**wrapped one level**. For instance the Rust runtime's `execute(...)` returns the
accumulator as an array, so the scalar case `"scalar-ok"` comes back as `["scalar-ok"]`
and the array case `["?proof:", "ok"]` as `[["?proof:", "ok"]]`.

The cross-variant oracle stores the **reference value** as the fixture and compares a
wrapping backend against `[reference]`, so the one-level wrap is a known, reconciled
relationship — not a divergence. A new backend should either return the reference value
directly or document its wrap so the oracle comparison stays exact. See
`docs/knowledge/rust-perl-output-oracle.md` and the [Backend Handoff](backend-handoff.md)
chapter.

## 6. Edge Dispatch

### 6.1 Action Edges (`->`)

An action edge `-> Child` with a code block executes the code block after the
child matches. The action code:
- Receives the child's match info.
- Can declare variables, read captures.
- Can return a value via explicit `return(...)` in the action or lifecycle path.

The action edge **selector index** determines which regex slot of the target
rule is matched: `-> rule` means index `[0]`. `-> rule[N]` selects slot `N`.

### 6.2 Blind-Call Edges (`=>`)

A blind-call edge `=> Child` delegates entirely to the child rule — no action
code block on the edge. The child's own lifecycle blocks handle the result.
Blind-call dispatch follows the **child rule's label mode**: `:AND` children
dispatch sequentially, bare `:` children dispatch as repeated choice.

### 6.3 Edge Dispatch Order

For rules with multiple edges:
1. **AND mode**: edges are dispatched sequentially in declaration order.
   Edge 0 must match for edge 1 to be attempted (contiguous consume). Each step
   matches its already-required target-rule/regex-index slot directly, so equal
   regex text cannot alias a later step to an earlier slot.
2. **OR mode**: all eligible edges participate in choice. Earliest match start
   wins, and an equal-start tie selects the lowest authored order. On the next
   repetition, all edges are eligible again.

Duplicate regex text is legal. Structural slot identity is currently
`{target_rule, regex_index}` and must survive descriptors, loaded/reconstructed
state, generated-source execution, and trace. Ordered invariant loss reports
`ordered_regex_slot_identity_lost`; an invalid compiled reference reports
`regex_slot_identity_invalid`.

### 6.4 Mixed Edge Rejection

A rule with both `->` (action) and `=>` (blind-call) edges is **invalid**.
The compiler rejects this as a `MIXED_ACTIONS` error.

## 7. Handler Variant Selection

The compiler selects a handler variant based on:

| Rule mode | Edge type | Single/Multiple | Variant |
|---|---|---|---|
| Default / OR | Action (acode) | Multiple | `default` |
| Default / OR | Action | Single | `or_acode` |
| Default / OR | Blind-call (bcode) | Any | `or_bcode` |
| AND | Blind-call | Any | `and_bcode` |
| AND | Action | Single | `and_single_acode` |
| AND | Action | Multiple | `and_acode_seq` |
| Repetition + OR | Blind-call | — | `rep_bcode` |
| Repetition + OR | Action | — | `rep_acode` |
| Repetition + AND | Blind-call | — | `rep_and_bcode` |
| Repetition + AND | Action | — | `rep_and_acode` |

Repetition variants embed a nested handler (inner loop) for per-iteration dispatch,
wrapped in a bounds-checking outer loop.

## 8. Regex Dispatch

The Perl reference backend (`LinkedRE::or`) uses position-tracking regex alternation
to identify which child matched. Each child regex is compiled into a combined alternation:

```
/(?{$pos=0}) child0_re | (?{$pos=1}) child1_re | ... /gcp
```

The `(?{$pos=N})` embedded code sets a position variable when a branch matches.
After the match, `$pos` identifies which branch the regex engine selected.

**For non-Perl backends**, this pattern must be mapped to the host language's
regex or pattern-matching capabilities. For choice-oriented rules, the current
cross-backend behavior is:

1. Match any of N alternatives against the input from the current position.
2. Identify **which** alternative matched (index 0..N-1).
3. Return the match info for the matched alternative.
4. If identical alternatives tie at the same position, select the first authored
   alternative.

ADR `0047` makes ordered identity normative: the executor already knows which
sequence slot is required next, so it matches only that structural target-rule/
regex-index slot and reports that identity. A repeated AND resets to its first
required slot for every accepted iteration. Perl, Rust, Dart, Julia, PUC Lua,
and LuaJIT now exhibit this behavior for ordinary and repeated AND execution.

For example, every implementation accepts both structural slots below and
returns `"ordered-ok"` even though their pattern text is identical:

```text
Top::AND
 /a/ -> Top[0] { set(seen, "first") }
 /a/ -> Top[1] { return("ordered-ok") }
```

The corresponding `OR` rule deterministically chooses slot 0 on every backend.
Duplicate text remains legal. Choice still evaluates every eligible slot and
breaks equal-start ties toward the first authored slot. Numeric selectors and
the Perl-staged ADR `0045` named selectors resolve to the same structural identity;
pattern text, adjacency, capture text, and alternation guesses never recover
identity. Portable backend and public admission of named selectors remains future work.

Perl and Rust originally exposed the same ordered-only defect: a combined
alternation reported the earlier duplicate branch, after which the handler
rejected it against its already-known later sequence index. Perl now passes a
compiled required row to `LinkedRE::match_slot`. Rust retains individually
compiled regexes beside `CompiledAlternation` and calls `consume_slot_match` or
`seek_slot_match` from both ordinary and generated-plan ordered loops. Their
combined matchers remain the choice owner, so earliest-start and source-order
priority are unchanged. Both implementations preserve whole, positional, and
named captures when matching a required slot.

Dart `.4` replaces its earlier behavior-preserving implementation detail—
compile one required pattern, then rewrite the host match index—with
`RuntimeRegexAlternation.matchAlternative`. The direct matcher retains the
authored alternative index in the match itself. Ordered and repeated execution
use it; choice continues to use the complete alternation. Target-rule/index
identity is derived from compiled action edges for descriptor, invariant, and
trace projection, including cross-target `First#0`, `Second#0` sequences.

Julia `.5` makes the same invariant explicit through
`match_runtime_regex_slot`. The matcher receives the full compiled
`RuntimeRegexAlternation`, selects one existing authored alternative, and
returns that alternative's original index. Ordered and repeated-AND execution
use this direct route; OR/default choice continues to evaluate the full
alternation. Compiled action edges translate parent alternative indices into
target-rule/child-index identity, so cross-target trace remains
`First#0`, `Second#0`.

Julia validates those typed action-edge references after compile and at runtime,
emission, and generated-plan boundaries. Descriptors and emitted modules publish
the slot-contract identity; emitted v2 source still reconstructs canonical
normalized `SpecFile` JSON and keeps plan rows exactly `{label, family}`.
`julia_runtime:regex_slot_selected` supplies ordered/choice trace identity, and
portable spec/runtime/generated errors preserve invalid target/index fields.

Lua `.6` removes the last behavior-preserving singleton/reindex route. Both PUC
Lua and LuaJIT call `match_runtime_regex_slot` with the complete compiled
alternation and the required authored index. The matcher invokes only that
existing alternative under the rule's cursor policy and returns its original
index. Full-alternation choice remains unchanged. Compiled action edges map the
parent index to target rule/child index for the ordered invariant and
`lua_runtime:regex_slot_selected`, including `First#0`, `Second#0` cross-target
sequences.

Lua validates compiled slot identity after compilation and before runtime-engine,
emitter, and generated-plan trust boundaries. Descriptor and emitted-module
metadata publish the neutral contract id. Emitted source remains v2/format 2,
retains normalized `SpecFile` JSON plus exact `{label, family}` plans, and exposes
portable invalid-slot and ordered-invariant diagnostics. One shared 15-role
consumer runs unchanged on PUC Lua and LuaJIT.

The executable neutral contract is
`linkedspec-duplicate-regex-slot-identity-v1`. It does not bump generated-source
v2 because reconstructed compiled state already retains slot identity. Perl,
Rust, Dart, Julia, PUC Lua, and LuaJIT are admitted through `.2-.6`;
recurring/public no-drift is closed by `.7` at 7 complete / 0 pending. The exact
composition proof is `tools/check_duplicate_regex_slot_identity_five_backend.sh`.

## 9. Zero-Progress Guard

Repeated rules must detect and prevent infinite loops when a child matches but
consumes zero characters:

1. Track consecutive zero-progress matches.
2. After a configurable threshold (implementation-defined, typically 100–1000),
   exit the repetition loop.
3. This prevents hangs on rules like `:*` where the regex can match an empty string.

This guard applies to all repetition modes (`:*`, `:+`, `OR+`, `AND+`, bounded forms).

## 10. Error Handling

### 10.1 Structured Error Payloads

All errors produce structured payloads with:
- `type`: diagnostic family, such as runtime parser or handler failure
- `stage`: the operation that failed
- `owner_stage`: the backend owner/stage attribution when available
- `summary`: human-readable error description
- `detail`: structured detail (what, where, why)
- `handler_source_label`: which handler generated the error (the Perl reference backend spells this `LinkedSpec::generated_handler:<rule_label>`)
- `spec_name` / `spec_path`: which `.spec` file
- `top_rule`: the top-level entry point
- `rule_label`: the failing rule when known

### 10.2 Non-Throwing Errors

LinkedSpec uses structured error returns (`last_error` channel) rather than
throwing exceptions for most failure paths. The caller checks for a defined
error payload to determine success/failure.

Perl exposes that channel as `runtime_ctx->{last_error}`. Dart currently exposes
the same neutral fields as `RuntimeDiagnostic` on
`RuntimeInterpreterException.diagnostic`; successful Dart parse output is
unchanged when no runtime error occurs.

Julia exposes the same neutral fields through exported `RuntimeDiagnostic` on
`RuntimeInterpreterException.diagnostic`. Optional engine `spec_name` /
`spec_path` identity and top/rule/handler attribution are attached only on
failure; successful `RuntimeParseResult` output remains unchanged.

Lua exposes a typed `RuntimeDiagnostic` on the native
`RuntimeInterpreterException.diagnostic` table field. Callers provide optional
`spec_name` / `spec_path` in `runtime_engine(...)`; rule wrappers preserve the
deepest child or lookup payload across parent unwind. The Lua-specific handler
label is `lua_runtime:rule:<label>`, and deterministic projection is available
through `linkedspec.interpreter.to_json(...)`. Top-rule selection, strict
runtime-input validation, rule lookup, and ordinary execution have distinct
stages. Successful `RuntimeParseResult` values and textual error messages are
unchanged.

Lua native tracing is orthogonal to diagnostic payloads. Callers may inject a
typed emitter with `runtime_parse(engine, input, { trace = emitter })` or use
`runtime_parse_with_trace(engine, input, config, options)`. Ordered levels,
structured enter/exit/decision/mark/dump/log events, environment-derived
immutable configs, stdout/routed-file/mirror sinks, reset/append, and optional
emoji are implemented in `linkedspec.trace`. Disabled or absent tracing is a
no-op. `.4.4.2` introduced balanced `lua_runtime:parse` scopes; `.4.4.3` adds
balanced rule scopes, regex match/no-match, action/blind dispatch, recursion
cutoff, lifecycle, cursor, source-boundary, and governed mark/capture events
while preserving exact parse-result JSON.

### 10.3 Input Validation

Before parsing, the input is validated:
- Must be a defined scalar reference.
- Must contain at least one character of non-comment/non-blank content.
- The first real line must be a valid rule start.

## 11. Determinism Guarantees

1. **No random number generation** in the parser runtime.
2. **Deterministic dispatch**: AND-mode rules dispatch in declaration order.
3. **Deterministic hash operations**: `sorted_keys`, `sorted_values` sort
   alphabetically — not dependent on host-language hash iteration order.
4. **First-match-wins**: OR-mode rules use the first matching alternative;
   with identical input and identical regex ordering, the outcome is deterministic.
