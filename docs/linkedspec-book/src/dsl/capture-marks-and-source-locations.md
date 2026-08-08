# Capture, Marks, and Source Locations

LinkedSpec has several helper families for reading parser spans and source positions.

This chapter explains the mental model before the exhaustive method list.

For the method-by-method public reference, read [Source Boundary Helper Reference](source-boundary-helper-reference.md) after this chapter.

## Accepted model: one typed source-location algebra

ADR `0056` adopts one conceptual core beneath these helper families. Perl, Rust, and Dart admit that core as an
internal runtime value/projection layer. Julia implements the same layer, but its exact consumer remains outside
ordinary test discovery until the separate admission leaf. This is not a new public value type or new `.spec`
syntax:

- a source identity names caller-authorized decoded input, not a path;
- a position is a zero-based Unicode-scalar offset in that source;
- a span is a same-source half-open interval `[start, end)` with exact provenance; and
- derived text retains the ordered spans that contributed to it.

Line/column and UTF-8 byte locations are derived evidence. Backends may use byte indexes internally, but public
portable position identity remains Unicode-scalar based. Text can be materialized from a span when needed; the span
does not need to copy the text or retain a regex, parser, stack frame, or backend object.

The current families below remain useful. On Perl, `cursor_*`, `entry_*`, `match_*`, `mark_*`, `capture_*`, and
`input_*` project positions, spans, text, or measurements from the same internal core instead of defining unrelated
coordinate systems. Their authored results and mutation behavior have not changed.

Rust retains its UTF-8-byte runtime registers and converts only at the internal typed boundary. Its ordinary and
canonical four-test consumer proves the same immutable values and all 92+7 projections across native,
reconstructed, and generated-plan execution.

Dart retains UTF-16 code-unit runtime registers while all 92 helpers and seven compatibility aliases now construct,
validate, derive, and materialize through one immutable input authority. The explicit four-test consumer proves
native, reconstructed, generated-plan, and freshly emitted execution under ordinary discovery and canonical CI.

Julia retains zero-based UTF-8 code-unit runtime registers while its same 92 helpers and seven aliases now use one
immutable input authority at the typed boundary. Its explicit consumer passes immutable values plus native,
reconstructed, and generated-plan helper execution, but remains dormant and unregistered. PUC Lua and LuaJIT
still need their own implementation and admission leaves.

### Bounded cursor transactions do not mean general backtracking

The accepted future checkpoint/try/commit/rollback model is one explicit recognition attempt inside one rule
invocation. Conceptually:

```text
checkpoint = snapshot(cursor, anonymous_boundary, named_marks)
candidate = recognize_once()
if candidate_is_accepted:
    commit(candidate.cursor_state)
else:
    restore(checkpoint)
```

Only cursor/source-boundary state participates. A rollback cannot undo variables, AST mutation, diagnostic or
output events, parser-registry work, external calls, or host effects. An uncommitted path must therefore remain
recognition-only; effectful action/lifecycle work occurs after commit. The engine does not search for alternatives,
unwind callers, or retry automatically. Repetition, recursion, and staged queues must still prove forward progress
or another well-founded decreasing measure.

Recursive rules may eventually expose immutable entry, selected-match, and accepted-exit positions plus bounded
parent/child provenance. Those observations do not change rule ownership: each child begins at the caller's current
position and derives seek/consume from its own authored family.

Progressive and staged parsing can then pass a span directly to another explicitly registered parser. The child
receives the exact text slice while its diagnostics map back to the original source. A span grants no implicit file
read, parser lookup, compilation, execution, or policy elevation. Lossless `@capture_gaps` segmentation will use the
same span representation, but ADR `0045` and the separate inter-match-gap task remain the sole owners of its syntax,
prefix/tail policy, lifecycle behavior, and compatibility migration.

The first executable neutral artifact now exists as
`capability_conformance/typed_source_location_contract.json`. It fixes the coordinate, span, provenance,
invocation, bounded-transaction, recursive-observation, structural, diagnostic, and rollout model described above.

Validate it from the repository root with:

```bash
bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py
```

The checker covers 3 decoded sources, 7 coordinate conversions, 6 direct spans, 3 derived-text cases, 8 invocation
and 8 transaction transitions, 6 recursive observations, 4 structural cases, 31 diagnostics, and 40 mutations.
It also proves that all 92 current source-boundary helpers project onto the algebra.

This is rollout status, not authored-value status. Six of 14 rollout legs are complete: the neutral contract,
public linked-rule structure, unchanged neutral/public recomposition, and the Perl, Rust, and Dart runtime
admissions. The other 8 remain pending.

Perl now uses an internal decoded-source authority plus immutable position/span values beneath every governed
helper projection. Exact Unicode execution is admitted on live and independently emitted/loaded generated routes.
Helpers still return their documented text, numbers, collections, booleans, absence values, and statement results;
mark and cursor storage remains scalar-compatible.

Rust admits the same internal algebra beneath its governed helpers. Existing strings, numbers, collections,
absence values, statement results, and UTF-8-byte mark/cursor registers remain unchanged.

Dart implements the same internal projection boundary while preserving strings, numbers, collections, booleans,
absence values, statement results, mutation timing, and UTF-16 code-unit mark/cursor registers. Its four-test
consumer is admitted under ordinary discovery and canonical CI, so the neutral rollout is 6 complete / 8 pending.

Julia implements that boundary while preserving the same external result kinds, mutation timing, and its native
zero-based UTF-8 code-unit registers. Its exact consumer and 92+7 detached catalogs remain pre-admission, so the
neutral rollout correctly stays 6 complete / 8 pending.

There is still no public `Position` or `Span` authored value, checkpoint syntax, transaction behavior, recursive
observation API, or Julia/PUC-Lua/LuaJIT runtime admission. Those remain owned by later leaves.

Until those later leaves land, use the current helpers documented in this chapter. Do not assume typed positions,
typed spans, or cursor transactions are available as authored values.

## Five anchor families

Most source-boundary helpers belong to one of these families:

- `capture_*`
- `mark_*`
- `cursor_*`
- `entry_*`
- `match_*`

They are intentionally different.

## `capture_*`: the anonymous moving boundary

The anonymous capture boundary is the lightweight “current segment starts here” mechanism.

Use it when one rolling boundary is enough.

Example:

```text
Top::
 -> Body .push
 LX { return(copy(Top)) }

Body: /BEGIN/ /END/
 -> Body[1] { return(hash("body", trim(capture_slice()))) }
```

With seek-mode matching, input `BEGIN body END` returns `[{"body":"body"}]`.

The important distinction:

- `capture_slice()` reads from the anonymous boundary without moving it
- `capture_take()` reads from the anonymous boundary and advances it

That makes `capture_take()` useful for segmented parsing:

```text
part = capture_take();
```

Read it as:

```text
read the current segment, then roll the segment start forward
```

## Historical “super split”: automatic inter-match gaps

The historical nickname “super split” refers to one specific use of the anonymous boundary:
automatic inter-match gap capture in a repeated OR/default rule with action edges. It is unrelated to
blind calls.

Keep regex ownership and action ownership separate:

```text
Document:
 /HEADER[^\n]*/
 /SECTION[^\n]*/
 /FOOTER[^\n]*/
 I {
   return(hash("text", entry_text()))
 }

Top::OR
 @move_pos
 -> Document[0] { ... }
 -> Document[1] { ... }
 -> Document[2] { ... }
```

`Document` declares the three regex slots and retains its lifecycle/code. `Top` owns repeated action
selection and refers to those slots explicitly. A regex line immediately before `-> Document` would
not trigger that edge; action matching resolves from the written target rule and index.

On the Perl reference, the legacy directive initializes a rule-invocation boundary, makes the exact
text before each selected match available to that action, then advances the boundary after the action.
The target action may call `Document` and combine the gap with its lifecycle result. Current reference
behavior includes entry-to-first-match prefix text and interstitial gaps; it does not automatically
deliver a final unmatched tail after the last selected match.

That marker-member behavior is not currently portable. Lua/LuaJIT later attach the anonymous marker
to the preceding regex slot, while Rust, Dart, and Julia parse marker syntax without executing it in
their native runtime paths. Explicit capture/mark helper calls are a separate governed surface. The
future `@capture_gaps` contract must reconcile this matrix rather than silently inheriting Lua's
positional reinterpretation.

The active baseline leaves storage and AST shape to action code. “Automatic” describes supplying the
gap and rolling its boundary, not appending a mandatory result node.

ADR `0045` adopts **inter-match gap capture** as the formal name and **lossless segmentation** as the
broader model. `@capture_gaps` is the accepted future neutral directive, but it is not implemented.
Its executable contract must decide prefix/tail, empty spans, failure and backtracking, recursion,
typed source spans, diagnostics, and compatibility before backend work begins.

The broader manual `capture_*` and `mark_*` APIs remain useful. They do not redefine this original
automatic repeated-action behavior.

The future contract also adopts terse named regex slots so action edges need not depend on declaration
order:

```text
Document:
 header=/HEADER[^\n]*/
 section = /SECTION[^\n]*/
 footer= /FOOTER[^\n]*/
 I {
   return(hash("kind", entry_slot(), "text", entry_text()))
 }

Top::OR
 @capture_gaps
 -> Document[header]  { ... }
 -> Document[section] { ... }
 -> Document[footer]  { ... }
```

Horizontal whitespace around `=` is insignificant. Same-line `name=/regex/` at rule-paragraph level
declares a stable rule-local slot rather than assigning a variable. Existing unindexed and numeric
selectors remain compatibility forms. This named-slot syntax, `@capture_gaps`, and the illustrative
`entry_slot()` accessor are not implemented; the exact lifecycle accessor remains unsettled.

## `mark_*`: named checkpoints

Marks are named checkpoints.

Use them when you need to remember more than one boundary or revisit a boundary later.

Example:

```text
mark_here(body_start);
body = capture_from(body_start);
```

Named marks are better than anonymous capture state when the rule needs durable labels such as:

- `body_start`
- `header_start`
- `value_end`

Bridge helpers connect the two worlds:

```text
mark_capture_slice(saved_start);
start_capture_slice_from(saved_start);
```

Read those as:

- store the anonymous boundary into a named mark
- restore the anonymous boundary from that named mark

## `cursor_*`: the live parser cursor

The cursor is the live current parser position.

Use cursor helpers when you want to know where the parser is now:

```text
where = cursor_pos();
line = cursor_line();
col = cursor_col();
```

Tail helpers read from the cursor to end-of-input:

```text
rest = cursor_rest();
width = cursor_rest_len();
```

## `entry_*`: the immediate match that entered the rule/action

Entry helpers read the immediate match that brought the action into this context.

Examples:

```text
token = entry_text();
name = entry_group(0);
line = entry_line();
col = entry_col();
```

Use `entry_*` when the action wants the match associated with rule entry or handoff.

## `match_*`: the current local active match

Match helpers read the current local match.

Examples:

```text
text = match_text();
line = match_line();
end_col = match_end_col();
```

Use `match_*` when the action wants the local match currently being processed, not the broader entry match.

## When `entry_*` and `match_*` diverge

For a simple single-regex rule, the match that *entered* the rule and the rule's *local* match are the same span, so `entry_*` and `match_*` agree — use whichever reads best.

They **diverge** when a rule's action runs against a local match that is not the match that dispatched into it. Consider a top dispatcher that enters an ordered child through the first slot (`name`) and returns from a later local slot (`Alpha`):

```text
Top::
 -> Name .push
 LX { return(copy(Top)) }

Name:AND
 /(?<head>name)/
 /\s*=\s*/
 /(?<value>[A-Za-z_]+)/
 -> Name[1] {
   eq = match_text();
 }
 -> Name[2] {
   return(hash(
     "entry_text", entry_text(),
     "entry_name", entry_named(head),
     "local_text", match_text(),
     "local_name", match_named(value),
     "separator", trim(eq)
   ))
 }
```

Over the input `name=Alpha`, this returns `[{"entry_name":"name","entry_text":"name","local_name":"Alpha","local_text":"Alpha","separator":"="}]`. The two families read **different** spans:

- `entry_text()` and `entry_named(head)` read the match that **entered** `Name` — the first slot, `name`.
- `match_text()` and `match_named(value)` read `Name`'s **current local match** — the final slot, `Alpha`.

The split applies to every reader in both families: `entry_group(0)` reads the entering match's capture (here `name`), while `match_group(0)` reads the local match's capture (here `Alpha`).

Choose by what you need: `entry_*` for the context that brought the action here, `match_*` for the token the action is processing right now.

## Whole-input helpers

Whole-input helpers are absolute. They do not mean cursor, entry, or local match.

Examples:

```text
source = input_text();
length = input_len();
end_pos = input_end_pos();
end_line = input_end_line();
end_col = input_end_col();
```

These are useful for diagnostics and source metadata when the rule needs to reference the full input.

## Position, line, and column

The naming is deliberate:

- `*_pos()` returns an absolute position
- `*_line()` returns a human-readable line
- `*_col()` returns a human-readable column

Use position helpers for machine logic. Use line/column helpers for diagnostics and messages that humans will read.

## Choosing the right helper

Use this quick rule:

- Need one rolling segment boundary? Use `capture_*`.
- Need a durable named checkpoint? Use `mark_*`.
- Need the live parser position? Use `cursor_*`.
- Need the match that entered this context? Use `entry_*`.
- Need the current local match? Use `match_*`.
- Need whole-source information? Use `input_*`.

That split avoids most confusion.

## Deeper reference

For the full capture/mark contract catalog with exact helper signatures, emitted-Perl shapes, and compatibility aliases, see `USER_GUIDE_ActionIR_Contracts.md` in the repo root. The capture/mark section there covers every helper in the family with its lowering contract.
