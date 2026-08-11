# Capture, Marks, and Source Locations

LinkedSpec has several helper families for reading parser spans and source positions.

This chapter explains the mental model before the exhaustive method list.

For the method-by-method public reference, read [Source Boundary Helper Reference](source-boundary-helper-reference.md) after this chapter.

## Accepted model: one typed source-location algebra

ADR `0056` adopts one conceptual core beneath these helper families. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT
admit that core as an internal runtime value/projection layer. This is not a new public value type or new `.spec`
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
reconstructed, and generated-plan helper execution under ordinary discovery and canonical CI.

PUC Lua and LuaJIT recognize all 92 canonical source-boundary helpers plus the same seven compatibility aliases.
One shared private immutable authority now sits beneath those helper branches. Each parse input gets one authority;
typed positions and spans validate/materialize the existing byte-register state without replacing it. Core proof
passes 133/133 and projection proof passes 240/240 on each ABI across native, reconstructed, and generated-plan
execution. Alias proof also retains loaded and independently emitted routes. Runtime admission is complete through
one ordinary and one canonical execution per ABI.

Run the admitted consumer from the repository root with either ABI:

```bash
bash tools/run_lua_project_data.sh puc lua/test/typed_source_location_contract_test.lua
bash tools/run_lua_project_data.sh luajit lua/test/typed_source_location_contract_test.lua
```

### Bounded cursor transactions do not mean general backtracking

The accepted checkpoint/try/commit/rollback model—current on Perl and Rust, future on later runtimes—is one explicit
recognition attempt inside one rule invocation. Conceptually:

```text
checkpoint = snapshot(cursor, anonymous_boundary, named_marks)
candidate = recognize_once()
if candidate_is_accepted:
    commit(candidate.cursor_state)
else:
    restore(checkpoint)
```

#### What the current admitted engines do today

Perl and Rust now recognize and independently admit the four forms as current capabilities. Perl's exact 51-test
consumer and Rust's exact 12-test consumer are required and executed by canonical CI. Dart, Julia, PUC Lua, and
LuaJIT do not yet admit the forms. `save_cursor()` and `restore_cursor()` remain older cursor-only LIFO
compatibility controls. They do not
save the anonymous boundary or named marks, carry an invocation/source owner, or diagnose reuse and escape. They
are not aliases for a transaction token.

Named marks are currently isolated by rule label for one parser execution. A `Top` mark and a `Child` mark with the
same name are independent. Recursive re-entry of `Top`, however, uses the same `Top` bucket; a child invocation can
overwrite its parent's same-named mark in ordinary parsing. The admitted Perl and Rust transaction routes temporarily
installs one invocation-local bucket and restores the parent bucket on exit; ordinary non-transaction parsing keeps
its established bucket behavior.

Ordinary recursion and repetition retain their established process protection. A direct no-consume recursive call
is cut and returns no value; its trace explains the cutoff, but `last_error` stays empty. A bounded repeated
zero-width match retains one accepted hit and then stops. The admitted Perl and Rust transaction scopes throw the
typed repetition or recursive-cycle error for accepted non-progress; later runtimes do not yet implement that route.

#### What the transaction-safety audit freezes

Each transaction token belongs to one source, rule invocation, generation, and originating edge. V1 permits
one active token per invocation. Commit or rollback is terminal; nesting, escape, caller unwind, cross-rule/source
use, automatic alternatives, and retry are rejected.

The compiler must classify the complete ActionIR path before executing an uncommitted attempt. Pure reads and value
construction, bounded recognition/control, staged return, and transaction-owned cursor/boundary/mark writes are the
only possible v1 effects. User or aggregate mutation, compatibility cursor-stack mutation, output, authored
diagnostics, exit, unknown/raw code, callable/user functions, parser registry work, external calls, and host effects
fail closed. Runtime checks remain a backstop for dynamic paths.

#### Accepted authored form (current on Perl)

Behavior-free `FUTURE-PARITY-BACKLOG.14.3.1.0` ratifies this exact shape:

```text
tx = recognition_checkpoint();
if (recognize_once(tx, call(Child))) {
    child = recognition_commit(tx);
} else {
    recognition_rollback(tx);
}
```

`recognition_checkpoint()` creates one opaque, rule-invocation-local linear token. `recognize_once` is a special
form whose second operand is exactly a statically named `call(Rule)`. The call is not evaluated before the
checkpoint; it runs once inside the transaction and keeps the familiar explicit child-dispatch spelling.

The return from `recognize_once` is a strict match boolean, not the child payload. The payload stays staged in the
token until `recognition_commit`, so a successful child result of `false`, `0`, an empty string, or `undef` remains
distinguishable from no match. Commit invalidates the token before exposing the payload. Rollback is statement-only;
it restores the cursor, anonymous boundary, and current invocation's named marks and discards the payload. Either a
matched or unmatched attempt may be rolled back explicitly.

The token cannot be copied, compared, returned, put in an array or harray, passed to a function/codeblock, retried,
or used by another invocation or source. Every path performs one attempt and one commit or rollback before ordinary
effects. The four forms are dedicated ActionIR nodes, not ordinary helpers, host exception syntax, or aliases for
the compatibility cursor stack. Consequently they are not added to the aligned 246-name ordinary helper-call
inventory; exhaustive coverage classifies the four exact intrinsic names separately while still requiring all 122
ordinary public Perl calls in every backend inventory.

The closed recognition-safe effect set is pure value work, immutable source reads, bounded `if`/`switch` control,
statically named rule recognition, transaction state, matcher-owned cursor advance, anonymous-boundary writes,
current-invocation mark writes, and staged return. Binding or aggregate/AST mutation, cursor stack/rewind controls,
output, authored diagnostics, exit/unbounded control, user or callable functions/codeblocks, registry/staged work,
external/host work, raw code, and unknown nodes fail closed. Rule calls are classified transitively, and the
runtime checks the same boundary before performing an effect.

The shared contract now has an executable backend-neutral authority. Its independent checker covers 128 current
ActionIR node kinds plus four dedicated transaction kinds, all 246 current call contracts, falsey token results,
recursive effect fixed points, invocation-frame marks, cursor-only progress, fifteen portable diagnostics, and 41
drift mutations:

```bash
bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py
```

That command proves the target semantics only. A backend may claim transaction support only after its separate
behavior and admission leg lands; Perl and Rust are now independently admitted.

The Perl lane now has both its private state foundation and an admitted end-to-end implementation. Four dedicated
ActionIR nodes preserve token/result/static-callee arguments; a recursive effect fixed point rejects unsafe callees
before recognition; live and independently emitted handlers use invocation-local marks, falsey-safe payload staging,
and cursor-only progress diagnostics. The final-path consumer is GREEN, including generated-source execution, and
canonical CI now requires, syntax-checks, and executes it exactly once:

```bash
PERL5LIB= prove -Iperl t/recognition_transaction_perl_contract.t
```

This is current authored behavior on Perl and completes only the Perl rollout leg.

The Perl and Rust lanes now recognize and admit the four forms as a current capability. Rust uses the same four
dedicated non-eager nodes through parsing and serialized reconstruction, enforces the neutral effect/progress
fixtures, and synchronizes live cursor, anonymous boundary, current-invocation marks, child acceptance, and staged
payload independently of payload truthiness. Native, reconstructed, generated-plan, and freshly compiled emitted-
source execution pass the ordinary 12-test contract. Canonical CI requires and executes that exact consumer once:

```bash
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test recognition_transaction_contract
```

Only Rust's rollout row advances; no later runtime, recurring, or public-no-drift row is promoted.

Dart now has a package-private transaction state authority behind the dormant consumer. Its default six-test mode
proves opaque monotonic generations, invocation-local marks, detached UTF-16-register snapshots, falsey-safe
payload staging, and restore-before-invalidate misuse, unwind, and discard handling. Strict analysis includes the
consumer, but ordinary discovery and canonical CI still omit it. The explicit integration RED mode stops at the
missing dedicated nodes, recursive effect/cursor-progress policy, native dispatch, and emitted dispatch. This
private foundation is implementation evidence, not current authored Dart support, so rollout remains 3/9.

The same checker fails closed over three public transaction pages, eleven forbidden claims, and twenty-five sequence mutations.
This guards the milestone order alongside the neutral artifact's 42 semantic mutations.

This section describes current Perl and Rust features and an accepted future portable contract. The neutral artifact/checker is
executable, and Perl and Rust are admitted; Dart, Julia, PUC Lua, and LuaJIT must each be admitted independently
before the form becomes portable behavior. Recognition rollout is now 3/9 complete; recurring composition and
final public no-drift remain separate later legs.

Only cursor/source-boundary state participates. A rollback cannot undo variables, AST mutation, diagnostic or
output events, parser-registry work, external calls, or host effects. An uncommitted path must therefore remain
recognition-only; effectful action/lifecycle work occurs after commit. The engine does not search for alternatives,
unwind callers, or retry automatically. V1 repetition and recursive edges must prove cursor advance; it exposes no
authored alternate decreasing-measure API. Later staged-queue progress remains separately owned by `.14.7`.

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
and 8 transaction transitions, 6 recursive observations, 4 structural cases, 31 diagnostics, and 53 mutations.
It also proves that all 92 current source-boundary helpers project onto the algebra.

This is rollout status, not authored-value status. Eight of 14 rollout legs are complete: the neutral contract,
public linked-rule structure, unchanged neutral/public recomposition, and the Perl, Rust, Dart, Julia, PUC Lua,
and LuaJIT runtime targets. The other 6 remain pending.

Perl now uses an internal decoded-source authority plus immutable position/span values beneath every governed
helper projection. Exact Unicode execution is admitted on live and independently emitted/loaded generated routes.
Helpers still return their documented text, numbers, collections, booleans, absence values, and statement results;
mark and cursor storage remains scalar-compatible.

Rust admits the same internal algebra beneath its governed helpers. Existing strings, numbers, collections,
absence values, statement results, and UTF-8-byte mark/cursor registers remain unchanged.

Dart implements the same internal projection boundary while preserving strings, numbers, collections, booleans,
absence values, statement results, mutation timing, and UTF-16 code-unit mark/cursor registers. Its four-test
consumer is admitted under ordinary discovery and canonical CI.

Julia implements that boundary while preserving the same external result kinds, mutation timing, and its native
zero-based UTF-8 code-unit registers. Its exact consumer and 92+7 detached catalogs are admitted under ordinary
discovery and canonical CI.

Lua implements the same internal boundary beneath exact detached 92+7 catalogs while preserving zero-based UTF-8
byte registers, values, and mutation timing. The same 240-assertion source runs exactly once on PUC Lua and once on
LuaJIT under ordinary discovery and canonical CI. The neutral rollout is therefore 8 complete / 6 pending.

One recurring command now composes those already-admitted consumers without adding another value model:

```bash
bash tools/check_typed_source_location_six_runtime.sh
```

It runs neutral, Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT in order, then the generated-source, capability, and
language-coverage ledgers. Canonical CI exposes the same all-toolchain proof behind
`LINKEDSPEC_RUN_TYPED_SOURCE_MATRIX=1`. Five backend consumer groups become six routes because one shared Lua
source executes independently on both ABIs. The extra 11 mutations reject topology drift, not authored behavior.

The unchanged `.14.2.7` recomposition reruns that authority and closes the six-runtime internal value/helper
implementation slice. It does not add an authored value or advance the 8-complete/6-pending public rollout.

There is still no public `Position` or `Span` authored value, recursive observation API, or span-native parser
dispatch. Exact transaction spelling is current on Perl and Rust but unavailable on later runtimes until their own
admission leaves. The combined recurring/public
no-drift rollout row remains pending for final closeout `FUTURE-PARITY-BACKLOG.14.8`, so recurring composition does
not change the current 8 complete / 6 pending ledger.

Until those later leaves land, use the current helpers documented in this chapter. Do not assume typed positions or
typed spans are authored values, or that the admitted Perl/Rust `recognition_*` operations are portable to every
runtime.

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
