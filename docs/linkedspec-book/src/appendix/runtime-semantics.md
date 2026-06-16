# Runtime Semantics

This appendix defines LinkedSpec's runtime behavior at the precision needed for
independent reimplementation. Every backend must produce identical behavior for the
same `.spec` input. No Perl implementation knowledge is required.

> **Cursor terminology.** Throughout this appendix, *the cursor* (or *input
> position*) is the backend-neutral name for the current parse position. The Perl
> reference backend spells it `pos($input)`; a different backend uses its own
> position primitive. The behavioral contracts below are what every backend must
> reproduce, independent of that spelling.

## 1. Parse Modes

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

**Used for AND-type rules** (ordered sequence: `AND` mode, `:&`, `:|`).

The regex is **`\G`-anchored** — it must match contiguously from the current
position. The match must start exactly at the current cursor.

**Behavioral contract:**
1. Anchor the regex at the current cursor.
2. Execute the regex with `\G` anchoring (match ONLY at the current position).
3. On match: advance the cursor to the match end.
4. On no match: the rule terminates (loop exits, or error).

**Key property**: Children must match in order, contiguously. No gaps allowed.
This is a structuring mode — the parser consumes input in exact sequence.

### 1.3 Parse Mode Determination

The parse mode for a rule is determined by:
1. The **rule mode** from the label (`:AND` → consume, `:OR` and default → seek).
2. The **handler variant** selected by the compiler.
3. AND variants use consume. OR and REP variants use seek.
4. The `parse_mode` field in the HandlerIR node documents the resolved mode.

## 2. Rule Execution Model

### 2.1 Non-Repeated Rules

A rule with mode `:AND` (bounded, non-repeated) or with a single-match mode
(`:&`, `:?`):

1. If the rule has an **I-block**: execute it once.
2. Match the child regex(es) once.
3. If the match succeeds, execute the action/blind-call code for the matched child.
4. If the rule has an **E-block**: execute it once.
5. Return the accumulated result.

### 2.2 Repeated Rules

A rule with repetition (`:*`, `:+`, `OR+`, `AND+`, bounded `{N,M}` forms):

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

## 4. BACKTRACK and IBACKTRACK

### 4.1 Local Cursor Rewind

`BACKTRACK` (case-sensitive) and `IBACKTRACK` (case-insensitive) perform a
**local cursor rewind**, not systemic backtracking:

1. Save the current cursor (input position).
2. Execute the child or code block.
3. If the child fails (no match) or a condition is unmet:
   - Restore the cursor to the saved position.
   - Continue as if the attempt never happened (the input cursor is unchanged).
4. If the child succeeds:
   - The position advance from the successful match is kept.

**What BACKTRACK is NOT:**
- It does NOT maintain a search tree of alternative parse paths.
- It does NOT unwind partial rule matches beyond the single local attempt.
- It does NOT restore accumulator state, variable declarations, or side effects
  from the failed attempt — only the input cursor position.
- LinkedSpec has **no systemic backtracking** across the parse tree.

### 4.2 Interaction with Parse Mode

After a BACKTRACK rewind, the next match attempt uses the **rule's declared parse
mode** (seek or consume) from the restored position. BACKTRACK does not change
the parse mode.

## 5. Accumulator Convention

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
LX {return(array_copy(array(Foo)))}
```

The `I`/`LS`/`LE`/`E`/`EX`/`IT`/`LX` lifecycle blocks are **top-level rule-paragraph
members — siblings of the `->`/`=>` edges**, not nested inside an edge's `{ … }` (an edge
block holds only that edge's action code).

### 5.3 Explicit Accumulation

`push_value(target, value)` targets a named accumulator explicitly. This is the
preferred form — clearer, more portable:

```text
Foo::
 I {declare(array, results)}
 -> Bar {push_value(array(results), call(Bar))}
E {return(array_copy(array(results)))}
```

### 5.4 Return Value

The rule's return value is whatever the **E-block** returns (or the last lifecycle
block to execute). A rule must return a value identifiable by the parent. The
canonical form is `return(array_copy(array(accumulator)))`.

## 6. Edge Dispatch

### 6.1 Action Edges (`->`)

An action edge `-> Child` with a code block executes the code block after the
child matches. The action code:
- Receives the child's match info.
- Can declare variables, read captures.
- Can return a value via lifecycle blocks (`LE`, `E`).

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
   Edge 0 must match for edge 1 to be attempted (contiguous consume).
2. **OR mode**: edges are tried in any order. The first match wins. On the
   next repetition, all edges are retried.

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
After the match, `$pos` identifies which child matched.

**For non-Perl backends**, this pattern must be mapped to the host language's
regex or pattern-matching capabilities. The contract is:
1. Match any of N alternatives against the input from the current position.
2. Identify **which** alternative matched (index 0..N-1).
3. Return the match info for the matched alternative.

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
- `summary`: human-readable error description
- `detail`: structured detail (what, where, why)
- `handler_source_label`: which handler generated the error (the Perl reference backend spells this `LinkedSpec::generated_handler:<rule_label>`)
- `spec_name` / `spec_path`: which `.spec` file
- `top_rule`: the top-level entry point

### 10.2 Non-Throwing Errors

LinkedSpec uses structured error returns (`last_error` channel) rather than
throwing exceptions for most failure paths. The caller checks for a defined
error payload to determine success/failure.

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
