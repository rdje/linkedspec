# Capture, Marks, and Source Locations

LinkedSpec has several helper families for reading parser spans and source positions.

This chapter explains the mental model before the exhaustive method list.

For the method-by-method public reference, read [Source Boundary Helper Reference](source-boundary-helper-reference.md) after this chapter.

## Accepted model: one typed source-location algebra

ADR `0056` adopts one conceptual core beneath these helper families. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT
admit that core as an internal runtime value/projection layer. This is not a new public value type or new `.spec`
syntax:

In this book, the neutral checker defines the backend-independent contract. An **admission consumer** is the exact
backend test target that executes that frozen contract through the runtime's required carriers; **admission** means
that target is also registered in ordinary discovery and canonical CI. Neutral proof alone is not backend support.

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

### Recursive source observation: current and recurring on all six runtimes

The behavior-free `.14.4.0` audit and lineage correction `.14.4.0.1` fix the portable observation boundary.
Executable neutral leaf `.14.4.1` selected the authored spelling. Perl `.14.4.2` executes it on live and
independently loaded generated-source routes; Rust `.14.4.3` executes it natively, after serialized reconstruction,
through generated-plan execution, and from independently compiled emitted source. Dart `.14.4.4`, Julia
`.14.4.5`, and shared Lua `.14.4.6` use those same four carriers through their shared engines. The one
Lua-5.1-compatible consumer executes independently on PUC Lua and LuaJIT:

```text
value = observe_recognition(observation, call(Child));
```

`observation` must be one bare rule-local harray binding, and `call(Child)` must be exactly one unevaluated,
statically named call. The expression preserves the ordinary child payload as `value`; accepted `false`, `0`,
`""`, and `undef` are not confused with recognition failure. Observation data is written separately at the
terminal boundary. Accepted and failed calls bind before returning. Aborted and progress-rejected calls finalize
the record before propagating their unchanged typed failure.

The detached harray has exactly these fields:

| Field | Meaning |
|---|---|
| `source_id` | The same caller-authorized decoded source, never a path or backend object. |
| `rule_label` | The entered rule that owns the observation. |
| `invocation_id` | A fresh, parse-local, monotonic identity. |
| `parent_invocation_id` | The nullable distinct earlier direct parent in the same source authority. |
| `entry_position` | Detached `{source_id, offset}` captured before child `I` lifecycle and local matching. |
| `selected_match` | Detached `{source_id, start, end, provenance}` for the terminal local match, or `undef`. |
| `accepted_exit` | Detached `{source_id, offset}` from which the caller resumes, or `undef`. |
| `outcome` | Exactly `accepted`, `failed`, `aborted`, or `rejected`. |
| `diagnostic` | An optional typed diagnostic associated with the terminal outcome. |

Field access uses the existing harray form, for example `observation["entry_position"]` and
`observation["accepted_exit"]`. The runtime record and every projection are recursively detached. They contain no
decoded source text, filesystem path, parser, live invocation frame, match object, source-authority object, or host
reference. This adds no custom authored value kind and no family of nine new helper names.

Action edges already carry the parent's selected local match into the child's entry-match register. A direct call
enters at the current cursor without inventing an entry match. In either case, the child derives seek or consume
from its own rule family; observing the child never lets the parent override that policy.

The neutral checker executes 33 ordered transitions. It proves action-edge and direct entry, OR/default `seek`,
AND `consume`, replacement of an earlier local candidate by the terminal selected match, zero-regex absence,
accepted-only exit, and all four outcomes. Each of the six records is detached before the next boundary; an exact
unavailable-boundary check proves there is no retained parse-wide history.

All six runtimes currently reject an already-active `(rule, cursor)` edge before pushing a child recognition
frame. The accepted observation design reserves a fresh attempted-child identity from the existing authority,
links it to the active parent, records a rejected outcome, and pushes no live frame. The original neutral
`direct_nonprogress` fixture instead made an invocation its own parent. Corrective `.14.4.0.1` replaces all textual
fixture identities with positive unique monotonic numbers; direct and mutual rejection each receive a fresh child
under an earlier active parent. The checker now rejects self-parent, reuse, invalid parent order, and cycles before
tuple comparison. Two additional static diagnostics reserve invalid-target and invalid-static-call errors. Ten
reason-checked state corruptions plus three surface/topology mutations raise typed-source governance from 57 to 70.
Runtime admissions and their exact `.14.4.7` recurring proof are complete. Recursive-observation public projection/no-drift is current: the private authored spelling and exact six-runtime proof are documented without adding a public API.

Perl owns one dedicated private `OBSERVE_RECOGNITION` ActionIR node; Rust owns one dedicated private
`ObserveRecognition` expression node; Dart and Julia each own one dedicated private
`ActionObserveRecognitionExpr`; shared Lua owns one dedicated private `observe_recognition` action node. All five
reject invalid targets and operands before execution, reuse the existing
recognition invocation stack, reserve rejected-attempt ids without a frame push, and retain no observation history.
All are binding writes and are therefore forbidden inside a recognition transaction. Rust proves the same
detached record and falsey payload across native, serialized reconstruction, generated-plan, and independently
compiled emitted-source execution while preserving UTF-8-byte registers behind typed scalar projections. Dart
proves the same carriers while preserving UTF-16 code-unit registers and converting only at the typed scalar
projection boundary. Julia likewise proves native, reconstructed, generated-plan, and independently loaded
emitted-module execution while preserving zero-based UTF-8 code-unit registers behind Unicode-scalar projection.
Shared Lua proves the same carriers independently on both ABIs while preserving zero-based UTF-8-byte registers.
Run its exact consumer with:

```bash
bash tools/run_lua_project_data.sh puc lua/test/recursive_observation_contract_test.lua
bash tools/run_lua_project_data.sh luajit lua/test/recursive_observation_contract_test.lua
```

Run the dedicated five-source/six-runtime recurring proof with:

```bash
bash tools/check_recursive_observation_six_runtime.sh
```

It executes neutral first; Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT in order; then generated-source,
capability, and language-coverage ledgers. Canonical CI exposes the same route behind
`LINKEDSPEC_RUN_RECURSIVE_OBSERVATION_MATRIX=1`. Twelve new regressions lock topology, repository-local storage,
canonical registration, and recurrence-only promotion. Twenty-seven public-contract, document, stale-claim, and
surface-guard mutations close the observation projection without changing the ledger. The recursive-observation
row remains complete, so typed-source rollout is 9 complete / 5 pending with 114 mutations. There is still no public helper, authored
`Position`/`Span` value, descriptor/generated version, result-schema field, semantic/MCP projection, CLI option,
or README behavior; the combined program-wide public-no-drift row remains pending for `.14.8`. Definitive local CI passes containment/relocation, CLI
66/66 twice, RAM 62%, Phase 0 1,031/1,031 in 723 seconds, and the complete observation matrix.

### Bounded cursor transactions do not mean general backtracking

The accepted checkpoint/try/commit/rollback model—current on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT—is one
explicit recognition attempt inside one rule invocation. Conceptually:

```text
checkpoint = snapshot(cursor, anonymous_boundary, named_marks)
candidate = recognize_once()
if candidate_is_accepted:
    commit(candidate.cursor_state)
else:
    restore(checkpoint)
```

#### What the current admitted engines do today

Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT now recognize and independently admit the four forms. Canonical CI
requires their exact 51-test, 12-test, 10-test, current 207-assertion Julia, and shared 246-assertion-per-Lua-ABI consumers.
`save_cursor()` and `restore_cursor()` remain older cursor-only LIFO compatibility
controls. They do not
save the anonymous boundary or named marks, carry an invocation/source owner, or diagnose reuse and escape. They
are not aliases for a transaction token.

Named marks are currently isolated by rule label for one parser execution. A `Top` mark and a `Child` mark with the
same name are independent. Recursive re-entry of `Top`, however, uses the same `Top` bucket; a child invocation can
overwrite its parent's same-named mark in ordinary parsing. All admitted transaction routes
temporarily install one invocation-local bucket and restore the parent bucket on exit; ordinary parsing keeps
its established bucket behavior.

Ordinary recursion and repetition retain their established process protection. A direct no-consume recursive call
is cut and returns no value; its trace explains the cutoff, but `last_error` stays empty. A bounded repeated
zero-width match retains one accepted hit and then stops. The admitted Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT
transaction scopes throw the typed repetition or recursive-cycle error for accepted non-progress.

#### What the transaction-safety audit freezes

Each transaction token belongs to one source, rule invocation, generation, and originating edge. V1 permits
one active token per invocation. Commit or rollback is terminal; nesting, escape, caller unwind, cross-rule/source
use, automatic alternatives, and retry are rejected.

The compiler must classify the complete ActionIR path before executing an uncommitted attempt. Pure reads and value
construction, bounded recognition/control, staged return, and transaction-owned cursor/boundary/mark writes are the
only possible v1 effects. User or aggregate mutation, compatibility cursor-stack mutation, output, authored
diagnostics, exit, unknown/raw code, callable/user functions, parser registry work, external calls, and host effects
fail closed. Runtime checks remain a backstop for dynamic paths.

#### Accepted authored form (current on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT)

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

The shared contract now has an executable backend-neutral authority. Its independent checker covers 133 current
ActionIR node kinds plus four dedicated transaction kinds, all 246 current call contracts, falsey token results,
recursive effect fixed points, invocation-frame marks, cursor-only progress, fifteen portable diagnostics, and 58
drift mutations:

```bash
bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py
```

That command proves the target semantics only. A runtime may claim transaction support only after its separate
behavior and admission leg lands; Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT are independently admitted.

The Perl lane now has both its private state foundation and an admitted end-to-end implementation. Four dedicated
ActionIR nodes preserve token/result/static-callee arguments; a recursive effect fixed point rejects unsafe callees
before recognition; live and independently emitted handlers use invocation-local marks, falsey-safe payload staging,
and cursor-only progress diagnostics. The final-path consumer is GREEN, including generated-source execution, and
canonical CI now requires, syntax-checks, and executes it exactly once:

```bash
PERL5LIB= prove -Iperl t/recognition_transaction_perl_contract.t
```

This is current authored behavior on Perl and completes only the Perl rollout leg.

The Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT lanes now recognize and admit the four forms as a current capability. Rust uses the same four
dedicated non-eager nodes through parsing and serialized reconstruction, enforces the neutral effect/progress
fixtures, and synchronizes live cursor, anonymous boundary, current-invocation marks, child acceptance, and staged
payload independently of payload truthiness. Native, reconstructed, generated-plan, and freshly compiled emitted-
source execution pass the ordinary 12-test contract. Canonical CI requires and executes that exact consumer once:

```bash
cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test recognition_transaction_contract
```

Rust's admission advanced only its rollout row; no later row was promoted early.

Dart has the same package-private end-to-end integration. The parser lowers the four forms to dedicated non-eager
ActionIR nodes, retains static `call(Rule)` structurally, and synchronizes live UTF-16 cursor, anonymous-boundary,
and invocation-mark state through the private authority. Recursive effect closure and cursor-only progress use the
neutral policy. Native, serialized reconstruction, generated-plan, and freshly analyzed emitted-source execution
preserve a successful `false` payload, while ordinary cursor-stack behavior remains compatible. The ordinary
10-test consumer is required and executed exactly once by canonical CI:

```bash
cd dart
bash ../tools/run_dart_project_data.sh test --reporter failures-only test/recognition_transaction_contract_test.dart
```

Only Dart's rollout row advanced in that slice; the authority remains unexported.

Julia now has an admitted private end-to-end implementation. The parser lowers
the four exact forms to dedicated non-eager nodes and retains `call(Rule)` as a static child label. One recursive
effect fixed point and cursor-only progress validator enforce the neutral fixtures; one invocation adapter binds
the existing UTF-8 code-unit cursor, anonymous boundary, and same-label mark bucket to the non-exported authority.
Native, reconstructed, generated-plan, and independently loaded emitted-module execution preserve a successful
`false` payload. The consumer was 203 assertions at Julia admission, reached 205 after checking both promoted Lua
rollout rows, and now runs 207 after freezing recurring and public-no-drift metadata; it is included by ordinary
Julia tests and executed once directly by
canonical CI; the private namespace remains unexported:

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no \
  -e 'using LinkedSpecJulia, JSON3, Test; include("julia/test/recognition_transaction_contract_test.jl")'
```

Julia's rollout row advanced alone in its admission; the later Lua slice did not rewrite that implementation.

Lua now has the same admitted private end-to-end behavior through one shared Lua-5.1-compatible implementation.
The exact consumer runs 246 assertions unchanged on PUC Lua and LuaJIT. It verifies the 187-assertion private
authority boundary, four non-eager nodes, recursive effects, cursor-only progress, and native, reconstructed,
generated-plan, and independently loaded emitted-module execution. Successful `false` remains staged until commit.
Ordinary Lua discovery and canonical CI each execute that source once per ABI:

```bash
bash tools/run_lua_project_data.sh puc lua/test/recognition_transaction_contract_test.lua
bash tools/run_lua_project_data.sh luajit lua/test/recognition_transaction_contract_test.lua
```

Both the authority and runtime adapter remain private; admission changes proof and availability, not facade shape.

The exact six-runtime recurring proof is current. Run:

```bash
bash tools/check_recognition_transaction_six_runtime.sh
```

That fail-fast, repository-routed driver validates the neutral contract first, then the exact Perl, Rust, Dart,
Julia, PUC Lua, and LuaJIT consumers in order. The two Lua routes deliberately execute one shared source on two
different ABIs. Generated-source, capability, and language-coverage ledgers run last. Canonical local CI exposes
the same all-toolchain composition behind `LINKEDSPEC_RUN_RECOGNITION_TRANSACTION_MATRIX=1`; ordinary CI still
runs its already-admitted individual consumers regardless of that opt-in.

The same checker fails closed over three public transaction pages, twenty-six forbidden claims, and forty-five sequence mutations.
This guards the milestone order alongside the neutral artifact's 58 semantic and topology mutations.

This section describes current Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT features and the complete portable transaction rollout. The neutral artifact/checker is
executable, and Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT are independently admitted.
Recognition rollout is 9/9 complete; public no-drift is current, and `.14.3` is closed without
changing transaction syntax, runtime behavior, schemas, facades, helper results, or the primary CLI.

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

The checker covers 3 decoded sources, 7 coordinate conversions, 6 direct spans, 3 derived-text cases, 8 invocation,
8 transaction, and 33 recursive-observation transitions, 6 detached observations, 4 structural cases,
33 diagnostics, and 114 mutations.
It also proves that all 92 current source-boundary helpers project onto the algebra.

This is rollout status, not authored-value status. Nine of 14 rollout legs are complete: the neutral contract,
public linked-rule structure, unchanged neutral/public recomposition, and the Perl, Rust, Dart, Julia, PUC Lua,
and LuaJIT runtime targets, plus recursive-observation recurrence. The other 5 remain pending.

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
LuaJIT under ordinary discovery and canonical CI. Internal value/helper admission remains complete on all routes.

One recurring command now composes those already-admitted consumers without adding another value model:

```bash
bash tools/check_typed_source_location_six_runtime.sh
```

It runs neutral, Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT in order, then the generated-source, capability, and
language-coverage ledgers. Canonical CI exposes the same all-toolchain proof behind
`LINKEDSPEC_RUN_TYPED_SOURCE_MATRIX=1`. Five backend consumer groups become six routes because one shared Lua
source executes independently on both ABIs. The extra 11 mutations reject topology drift, not authored behavior.

Recursive observation has a narrower recurring gate over its five exact consumer sources and the same six runtime
routes:

```bash
bash tools/check_recursive_observation_six_runtime.sh
```

It then runs the same three support ledgers. `LINKEDSPEC_RUN_RECURSIVE_OBSERVATION_MATRIX=1` selects it from
canonical CI. Twelve additional regressions make only `recursive_observation` complete, advancing the current
contract to 9 complete / 5 pending / 114 mutations before the separately governed public-projection checks.

The unchanged `.14.2.7` recomposition reruns that authority and closes the six-runtime internal value/helper
implementation slice. It does not add an authored value or promote final public no-drift.

There is still no public `Position` or `Span` authored value, public recursive-observation API, or span-native
parser dispatch. The private recursive-observation spelling and detached harray carrier are executable in the
neutral contract and admitted internally on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT. Exact transaction spelling is current on Perl, Rust,
Dart, Julia, PUC Lua, and LuaJIT. Lua's shared
private authority passes 187 assertions per ABI, and its admitted consumer passes 246 per ABI across four dedicated
nodes, recursive effect/progress policy, and all four runtime carriers after recurring/public metadata closeout. The modules remain unexported
while the consumer is ordinarily and canonically discovered once per ABI. Transaction rollout is complete at
9/9 under `.14.3.8`; the unchanged recurring authority and all six admissions remain exact. The separate typed-source combined
recurring/public-no-drift row remains pending for final program-wide closeout `FUTURE-PARITY-BACKLOG.14.8`, so
typed-source composition is 9 complete / 5 pending.

Until those later leaves land, use the current helpers documented in this chapter. Do not assume typed positions or
typed spans are authored values. The `recognition_*` operations are current across all six runtime routes, while
their exact recurring composition and public no-drift projection are both current.

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
portable `@capture_gaps` contract reconciles this matrix rather than silently inheriting Lua's
positional reinterpretation. The behavior-free neutral plan now forbids mixing an anonymous legacy marker member
with `@capture_gaps`; legacy behavior remains compatibility input, not an alias.

The active baseline leaves storage and AST shape to action code. “Automatic” describes supplying the
gap and rolling its boundary, not appending a mandatory result node.

ADR `0045` adopts **inter-match gap capture** as the formal name and **lossless segmentation** as the
broader model. `@capture_gaps` is the accepted neutral directive. Perl, Rust, and Dart now recognize and
statically validate it and privately execute native, reconstructed/generated, emitted, and primary roles.
Julia, both Lua ABIs, recurring/public completion, and public exposure remain pending.
`INTER-MATCH-GAP-CAPTURE.1.0` froze its executable-neutral plan: exact prefix/interstitial/tail and empty
spans, failure and rollback, recursion, typed source records, diagnostics, compatibility, routing, and rollout are
specified before backend work begins. `.1.1` now makes that neutral JSON artifact and independent checker
executable. Current private rollout is 4 complete + 5 pending with no outward admission.

The broader manual `capture_*` and `mark_*` APIs remain useful. They do not redefine this original
automatic repeated-action behavior.

The contract also adopts terse named regex slots so action edges need not depend on declaration order:

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
selectors remain compatibility forms. Perl, Rust, and Dart privately admit the declaration/selector syntax,
directive metadata, and native plus reconstructed/generated/emitted/primary `entry_slot()`/gap-accessor behavior.
Julia's behavior-free plan is frozen, but its parser/runtime implementation remains pending. No backend exposes
these forms as a public cross-backend contract yet.

Brackets are the selector namespace. `Document[1]` means positional compatibility, so declaration reordering
can change its target; `Document[section]` means stable identity and must survive reordering. An implementation
may resolve both to one typed slot identity, but it retains whether the source used a position or a name for
diagnostics and migration. Dot is already the fluent rule-behavior namespace, so `Document.1` and
`Document.section` are not selector aliases. The first fluent dot remains mandatory too:
`-> Document[section].method(...)` attaches behavior visibly, while
`-> Document[section] method(...)` is not an alias. This keeps receiver attachment independent of whitespace
and makes the first method structurally identical to every continuation method.

The implementation order is also explicit. `INTER-MATCH-GAP-CAPTURE.1-.7` owns named-slot syntax,
`@capture_gaps`, lifecycle and compatibility policy, six-runtime behavior, carriers, and public admission.
Typed-source composition consumes that completed contract afterward; it does not define a second gap language.

### Executable neutral contract — private Perl, Rust, and Dart runtimes admitted

The behavior-free contract now lives at `capability_conformance/inter_match_gap_capture_contract.json`, uses id
`linkedspec-inter-match-gap-capture-v1`, and is checked independently by
`tools/check_inter_match_gap_capture_contract.py`. Inter-match gap-capture recurring governance now executes the complete neutral, Perl, Rust, and Dart rows; three later runtime routes and both public rows remain pending.
The Perl reference implements authored/static metadata, private native-live behavior, and independently loaded
generated parity. Admission `.2.4` runs that complete consumer in canonical CI and in the rooted recurring route,
promotes only `perl_runtime`, and advances the checker to 56 mutations without outward public admission.
Rust `.3.5` and Dart `.4.5` add the exact primary-command role, admit their complete nine-role consumers to
ordinary and canonical execution, and run once after Perl and Rust respectively in the rooted route. Only their
private runtime rows advance. The recurring driver executes neutral, Perl, Rust, and Dart exactly once each, then
emits three ordered later-runtime skips:

```bash
bash tools/check_inter_match_gap_capture_six_runtime.sh
```

Canonical local CI always runs the neutral checker and exposes the same governance route behind
`LINKEDSPEC_RUN_INTER_MATCH_GAP_MATRIX=1`. Ordinary CI and the opt-in route execute every admitted consumer once;
the latter additionally proves neutral-first Perl-then-Rust-then-Dart ordering and three explicit later-runtime
skips.

The neutral artifact locks 8 positive and 10 negative authored fixtures, 3 source fixtures, 8 private gap fields,
16 main-machine transitions, 10 segmentation cases, 3 terminal routes, 7 transaction/recursion/return-channel
cases, 6 compatibility rows, 9 diagnostics, 9 rollout legs, and 50 semantic mutations. Recurring topology and
public-no-overclaim governance raised that base to 55; runtime admission now rejects Perl, Rust, and Dart
complete-to-pending regressions at 57 total. Ten Rust and ten Dart role/registration mutations are separate.

### Perl private live and generated implementation — exact private admission

Perl `.2.1` implements exact named declaration/selector parsing, static validation, directive metadata, and
generated dependency provenance. Ordinary `Rule[name]` selection executes the selected regex correctly. `.2.2`
adds private native-live `@capture_gaps`, `entry_slot()`, and three gap accessors through dedicated source-read
ActionIR nodes. The legacy marker behavior remains separate and still produces prefix/interstitial pairs but no
automatic tail. `.2.3` carries the same behavior through emitted and independently loaded source.

Implementation is dependency-split:

1. `.2.1` has added exact Unicode-17 named-slot parsing, static diagnostics, directive/edge metadata, generated
   dependency provenance, and a dormant final-path consumer—without live gap capture.
2. `.2.2` has attached state to the existing recognition invocation guard, added live lifecycle/accessor behavior,
   and synchronized four private source-read ActionIR nodes. It creates neither another cursor nor invocation stack.
3. `.2.3` has proven emitted and independently loaded execution while retaining generated-source plan v2.
4. `.2.4` registers and admits Perl, advancing the gap rollout and mutation boundary while later runtimes and
   public no-drift remain pending.

The `.2.3` carrier boundary is signoff-complete. `.2.4` now admits that exact consumer without adding a public
facade: its ordinary and rooted runs each pass 124 top-level tests, and project-data routing passes outside the
working directory.

Definitive `.2.4` and parent `.2` signoff also passes the rendered mdBook, Knowledge 834/6,995, all eight
doctrines, containment/relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 765 seconds, the exact
neutral-plus-Perl route with five later-runtime skips, and local-CI exit 0. Atomic 226 landed at `eceb15ac`.

### Rust private native, generated-plan, emitted, and primary execution — admitted

Rust `.3.0` froze the behavior-free implementation map from that clean boundary. Its process-level probes recorded
the prior baseline: only numeric `Rule[N]` worked, while named declarations/selectors, `@capture_gaps`,
`entry_slot()`, and the three gap accessors were absent. `.3.1` has since implemented authored/static/compiled
metadata, `.3.2` has implemented private native execution, and `.3.3` has carried that exact state through
ordinary reconstruction, descriptors, and the separate generated-plan executor. `.3.4` now proves the same
payload through independently compiled emitted Rust source.

The implementation is dependency-split before any behavior moves:

1. `.3.1` adds Unicode-17 named/anonymous declarations, typed unindexed/numeric/named selectors, exact static
   diagnostics, directive eligibility, compiled slot rows, and five-field resolved edge provenance.
2. `.3.2` attaches native gap state and detached entry-slot identity to Rust's existing recognition invocation and
   checkpoint snapshot. It adds no second cursor, token family, or invocation stack.
3. `.3.3` now proves ordinary reconstruction and descriptors, then applies the same lifecycle in the separate
   generated-plan executor. Generated plan v2 remains exactly `{label,family}`.
4. `.3.4` independently compiles emitted Rust source offline in a repository-derived scratch/target workspace
   and proves paired direct/traced execution without changing the emitter or generated plan.
5. `.3.5` composes the nine exact Rust roles, primary command, recurring/canonical registration, and Rust-only
   admission.

Leaf `.3.5` advances only `rust_runtime`, producing 3 complete / 6 pending while four later runtime routes remain
skips. The former premature-Rust mutation is now a Rust regression mutation, leaving the total at 56. Recognition
stays 137/246/58, public helpers stay 122, typed source stays 9/5/114, and facade/schema/semantic/MCP/CLI/README/
public admission remains later.

Authored/static/compiled leaf `.3.1` is now implemented from clean `4a95e02a`. Rust parses the four declaration
spacing forms, mixes named and anonymous rows in one authored order, distinguishes unindexed/numeric/named
selectors, reuses exact Unicode-17 identity, validates directive eligibility and the frozen diagnostics, and
retains source/line-aware slot/directive plus five-field edge provenance in serialized compiled state.

Private native leaf `.3.2` is now implemented from clean `95127e1d`. Rust attaches gap activation and detached
entry-slot identity to the existing recognition invocation, and adds only committed gap cursor, accepted-edge
count, and current gap to that invocation's checkpoint snapshot. Public recognition state stays exactly
cursor/boundary/marks.

For capture-enabled native rules, Rust selects and installs the local match and gap candidate before `LS`, keeps
the candidate visible through target/action/`LE`, commits the accepted child-extended cursor before `IT`, and
exposes successful tails to the existing `LX`/`EX`/`E` hooks. Unflagged rules preserve their historical
LS-before-selection order. Gap spans cross the existing source authority and therefore expose decoded Unicode-
scalar half-open offsets rather than byte offsets; nested invocations isolate state and recognition rollback
restores the same three-member gap snapshot.

Carrier leaf `.3.3` keeps serialized `CompiledSpec` as the single source of runtime truth. An ordinary JSON
round trip preserves declaration-order slot rows, nullable stable ids, directive source/line evidence, and exact
selector provenance, then executes the same native result. Descriptor rule metadata now publishes separate
`regex_slots`, `capture_gaps`, and five-field `resolved_slot_edges` values. Existing five-field semantic
`resolved_edges` and legacy `{label,idx}` dependency references stay byte-shape compatible.

The generated-plan executor reads capture activation from that reconstructed compiled payload, enters the same
recognition frame, propagates detached entry-slot identity, and uses candidate-before-`LS`, commit-after-`LE`, and
tail-before-terminal timing. The focused consumer compares native and generated-plan values and diagnostics over
Unicode and empty gaps, falsey returns, child-extended cursors, nested owners, rollback, lifecycle terminals,
failed minimums, and direct entry. `source_emitter.rs` needs no new carrier: generated source already embeds the
serialized compiled payload, while its static plan remains exact v2 `{label,family}`.

Emitted carrier leaf `.3.4` creates one repository-derived offline crate containing fifteen independently emitted
modules. Thirteen value cases execute through both `execute(...)` and `execute_with_trace(...)`: mixed list
separators, Unicode and empty gaps, falsey child values, candidate-before-`LS`, child-extended cursors, nested
owners, rollback, all terminal routes, failed minimum, direct entry, and unflagged legacy behavior. Two more
modules prove typed unavailable-context and cursor-regression failures through both roles. Every traced value
retains its emitted source identity and generated-plan trace role.

The mixed-separator module is executable confirmation of the list use case: matching `[a-z]+` over
`alpha, beta | gamma\n- delta` returns the items alongside exact gaps `""`, `", "`, `" | "`, and `"\n- "`,
plus an empty tail. The separator need not be one delimiter regex; it is preserved source text between accepted
items.

Rust runtime admission now composes those carriers with the existing primary adapter. The primary proof parses
`alpha, beta | gamma\n- delta` through an inline spec and returns exact item/gap pairs, independently confirming
that one item regex can preserve heterogeneous separators. The final consumer is ordinary, canonical, and rooted;
its runtime ledger rejects any missing, duplicate, or undeclared role across the exact nine-role contract. The
neutral checker remains behavior-free at rollout 3 complete / 6 pending and 56 semantic/governance mutations,
plus ten local Rust admission/regression mutations.

Pinned identity is important here: the installed Perl reports Unicode 13, so `.2.1` generates a private
806-range classifier from the repository's Unicode 17 ranges rather than trusting the host `XID_Continue` table.
Gap checkpoint state is indexed by existing recognition tokens on the same invocation guard; the established
cursor/boundary/marks transaction schema remains unchanged.

The four accessor nodes raise the recognition-effect census from 133 to 137 and remain private behavior. Perl
executes them on live and generated paths; Rust now executes them on native, reconstructed, generated-plan, and
independently compiled emitted paths. The 246 shared call inventory, 122 public-helper inventory, and typed-source
9-complete/5-pending/114-mutation contract do not move. Current truth is recognition 137/246/58 and gap rollout
4 complete / 5 pending / 57 mutations plus ten Rust and ten Dart admission mutations. Exact registration checks
require the admitted Rust and Dart consumers ordinarily and canonically, and once each after Perl in the rooted
route. ADR `0074` preserves every earlier semantic guard and adds the missing Dart rollout regression as mutation
57 because no `dart_runtime_premature` row ever existed to replace.

### Dart native, generated, emitted, and primary carriers — privately admitted

Dart `.4.0` established the behavior-free baseline: numeric selectors worked, named declarations/selectors and
`@capture_gaps` were raw body syntax, all four gap accessors reached `unknown_helper`, and repeated-rule `LS`
preceded selection. Dart `.4.1` implemented the authored/static/compiled layer, `.4.2` added private native gap
context and the four accessors on the same recognition authority, and `.4.3` now carries that state through
ordinary reconstruction, compatible descriptors, and generated-plan execution. `.4.4` independently analyzes
and executes emitted libraries without changing the emitter. `.4.5` proves the existing primary adapter, removes
the final consumer skip, and validates every declared role exactly once. The parser accepts named and anonymous regex
declarations in one order, preserves unindexed/numeric/named selector authorship, and carries one dedicated
rule-level directive record. This is private ordinary admission, not a public helper/facade/schema admission.

For example, this Dart source now parses, validates, and compiles its slot identities:

```text
Top::OR
 @capture_gaps
 -> Part[head] { return("named") }
 -> Part[0]    { return("numeric") }
 -> Part       { return("unindexed") }

Part:
 head = /H/
 /S/
 foot=/F/
```

The `Part` slot rows are `(0, head)`, `(1, null)`, and `(2, foot)`. All three edges retain five distinct resolved
fields: selector kind, authored selector, target rule, resolved numeric index, and nullable target slot id. Thus
`Part[head]` remains attached to `head` if another identical regex is inserted before it, while `Part[0]` remains
positional. Descriptor metadata now exposes this provenance separately as `regex_slots`, `capture_gaps`, and
`resolved_slot_edges`; existing dependency refs and `resolved_edges` stay legacy-shaped.

Slot names use the same generated, pinned Unicode 17.0.0 `XID_Continue` classifier as rule labels. Identity is
exact and normalization-sensitive; a name made only of ASCII digits is rejected so `[123]` remains unambiguously
numeric. Dart reports the neutral source-aware static diagnostics for invalid/duplicate declarations,
unknown/out-of-range/malformed selectors, duplicate directives, ineligible ownership/modes, and anonymous legacy
marker conflicts. Named `@mark(...)` remains independent.

`SpecFile` now carries a logical `source_id`, defaulting to `inline` for old constructors and JSON. Ordinary,
staged, and loaded parsing preserve that identity into diagnostics and compiled slot/directive/edge records. The
loaded path uses the caller's logical request rather than persisting a resolved host path. This keeps fixtures and
serialized state relocatable.

The implementation is assigned before code:

1. `.4.1` now provides Unicode-17 named/anonymous slot identity, typed selector provenance, logical spec source
   identity, directive/static diagnostics, compiled metadata, and a mechanically dormant final consumer.
2. `.4.2` now attaches private gap state to Dart's existing recognition invocation and token snapshot. It adds
   no second stack and does not widen observed `RecognitionFrameState`, which remains cursor/boundary/marks.
3. `.4.3` now proves normalized `SpecFile` reconstruction, compatible descriptor additions, and generated-plan
   execution through the same engine. Static plan v2 remains exactly `{label,family}`.
4. `.4.4` now independently analyzes and executes emitted Dart libraries from one repository-routed caller
   workspace with its own project-local package cache.
5. `.4.5` now proves the existing primary adapter, requires all nine roles exactly once, registers the consumer
   ordinarily, canonically, and after Rust in the rooted route, and promotes only Dart.

Dart's implementation uses immutable decoded input in `SourceAuthority` and the one existing private recognition
transaction/invocation authority. Runtime gap spans use source id `input`; UTF-16 code-unit registers are
projected through that authority to Unicode-scalar offsets. Static diagnostics use the separate logical spec
source identity introduced by `.4.1`. Generated source continues embedding normalized spec state rather than
copying gap metadata into the static plan.

For example, explicitly executing the skipped native consumer over `αHω` with a capture-enabled edge targeting
`H` yields a prefix pair `['prefix', 'α']` and a terminal pair `['tail', 'ω']`. On input `αHβ\nS🙂Fω`, named
`header`, `section`, and `footer` edges expose scalar spans `[0,1)`, `[2,4)`, and `[5,6)` for the three gaps, then
the tail `[7,8)`. The emoji occupies two UTF-16 code units internally but one exposed source scalar. Empty gaps
remain observable, and falsey action values such as `0` still count as accepted matches.

The private lifecycle is exact. Dart selects and installs a candidate before capture-enabled `LS`, keeps it live
through the edge, child call, and `LE`, commits the accepted child-extended cursor before `IT`, and installs a
successful tail for existing `LX`/`EX`/`E` hooks. Unflagged rules retain their historical `LS`-before-selection
order. A nested capture owner hides the parent candidate only for the nested invocation; returning restores the
parent view. Recognition rollback restores the same committed cursor, accepted count, and current candidate.
Unavailable reads and cursor regression report the private typed `gap_capture_context_unavailable` and
`source_location_cursor_regression` diagnostics.

Normalized `SpecFile` JSON is the sole Dart carrier. A JSON round trip preserves source-aware slot/directive/edge
metadata, recompiles, and executes the same prefix/tail result. Descriptor rule metadata returns fresh detached
slot, directive, and five-field selector rows. Direct and traced generated-plan routes return the same Unicode gap
values and preserve the exact typed unavailable-context and cursor-regression failures through the generated
error envelope. No gap field is added to the v2 plan.

The emitted proof creates one managed offline caller package beneath the routed temporary root. It writes ten
independent value modules and two typed-error modules produced by `emitDartSourceV2`, resolves with a private
`PUB_CACHE`, runs strict analysis, then executes every module through both direct and traced APIs. The value set
covers mixed separators, Unicode and empty spans, falsey child values, lifecycle order, child-extended cursors,
detached named entry slots, nested owners, recognition rollback, terminal tails, failed minimum, direct entry,
and unflagged legacy behavior. The error modules preserve exact unavailable-context and cursor-regression detail.
Every trace retains its emitted source identity, and cleanup removes the caller, cache, modules, and traces. The
Dart storage oracle now accounts for 23 exact `Directory.systemTemp` owners and 47 locked packages.

The final Dart consumer at `dart/test/inter_match_gap_capture_contract_test.dart` now runs five ordinary groups.
Its last group executes `native_execution`, `ordinary_reconstruction`, `descriptor`, `generated_plan`,
`emitted_source`, `target_lifecycle`, `recursion_and_rollback`, `portable_diagnostics`, and `primary_command` in
the contract-declared order, once each. The primary case parses the same heterogeneous separator input through
the existing private command adapter. Ten reason-checked admission mutations reject consumer/ledger drift,
missing or duplicate ordinary/canonical/recurring registration, premature later-runtime execution, and facade
exposure. Rollout is 4 complete / 5 pending / 57 mutations, and generated plan v2 remains exactly
`{label,family}`.

### Julia behavior-free implementation plan — runtime still pending

Julia `.5.0` confirms the current boundary before code: numeric selectors compile; named declarations/selectors
and `@capture_gaps` are raw invalid body syntax; `entry_slot()` and the three gap accessors fail as structured
unknown helpers; legacy `@move_pos` has no compiled/native effect; and repeated execution runs enclosing `LS`
before candidate selection. The existing primary adapter rejects the complete future syntax at compilation.

Five dependency-ordered leaves are frozen. `.5.1` owns logical spec identity, authored/static/compiled slot and
selector provenance, directive diagnostics, and a mechanically dormant permanent consumer. `.5.2` extends only
the existing private recognition invocation/token authority; detached `RecognitionFrameState` remains exactly
cursor/boundary/marks. Capture-enabled rules alone preselect before `LS`, and the immutable input
`SourceAuthority` projects Julia's UTF-8 code-unit registers to detached scalar spans. `.5.3` uses normalized
`SpecFile` JSON as the sole carrier, adds separate compatible descriptor projections, and retains generated
format 2 with exact `{label,family}` plan rows. `.5.4` independently loads ten value and two typed-error emitted
modules from one repository-routed host, advancing only the exact Julia temporary-workspace inventory from 19 to
20. `.5.5` alone reuses the primary adapter, admits nine roles exactly once, and advances Julia to 5/4/58.

This planning leaf changes no Julia behavior, rollout, generated format, descriptor/reference legacy shape,
facade/schema/semantic/MCP/capability/CLI/README surface, dependency, or toolchain. The exact implementation map is
recorded in ADR `0045` and `docs/knowledge/inter-match-gap-julia-implementation-plan.md`.

Named slot rules are exact:

- A name uses the same pinned Unicode 17.0.0 `XID_Continue` scalar class as a rule label. Identity is exact,
  case-sensitive, and normalization-sensitive.
- An all-ASCII-digit name is invalid because bracket digits remain the positional selector namespace.
- Named and anonymous declarations may mix. They share one zero-based declaration order, and a name is unique
  within its owning rule.
- `Rule`, `Rule[N]`, and `Rule[name]` are the only selectors. The compiled edge retains the authored selector kind,
  authored selector, target rule, resolved index, and nullable stable slot id.

This makes heterogeneous lists a natural use case. The referenced regex slot recognizes each item while the
enclosing seek loop preserves whatever appeared between accepted items. For input
`alpha, beta | gamma\n- delta`, an item regex can match `alpha`, `beta`, `gamma`, and `delta`; the corresponding
interstitial `gap_text()` values are `", "`, `" | "`, and `"\n- "`. The parser can therefore retain exact commas,
bars, bullets, whitespace, or mixed separators for reconstruction, or normalize them later. The gap mechanism
does not accept arbitrary items: each next item still has to match its declared target slot, and only an accepted
edge commits the candidate.

For example, this is current Perl authored/static syntax:

```text
Document:
 heading = /HEADER[^\n]*/
 /COMMENT[^\n]*/
 section = /SECTION[^\n]*/

Top::OR
 @capture_gaps
 -> Document[heading] { ... }
 -> Document[1]       { ... }
 -> Document[section] { ... }
```

The two named edges retain stable identity if declarations are reordered. `Document[1]` deliberately remains
positional. A numeric edge may resolve a named declaration, but that does not turn the numeric source spelling into
stable named provenance.

Private live/generated `entry_slot()` returns `undef` for a direct rule invocation. For an action-edge entry it
returns a detached ordinary harray with `target_rule`, `regex_index`, `slot_id`, `selector_kind`, and
`authored_selector`. It exposes identity, not a regex object or matcher authority.

`@capture_gaps` is valid only on a looping, seek-based OR/default rule with statically resolved action edges. It is
invalid on AND/consume, blind-call, mixed-ownership, or adjacency-owned shapes. Target rules still own their
regexes and lifecycle. The enclosing rule owns only repeated choice and gap state.

One activated invocation owns an independent committed gap cursor. The live/generated event order is:

| Boundary | Private live/generated gap behavior |
| --- | --- |
| Rule entry | Initialize the committed gap cursor at the Unicode-scalar entry position. |
| After selection, before enclosing `LS` | Create `[gap_cursor, selected_match.start)` as `prefix` or `interstitial`. |
| `LS` → edge/target → `LE` | Keep that read-only candidate visible to gap accessors. |
| Accepted post-`LE` | Commit the accepted cursor, clear current gap, then run `IT`. |
| Failed/rejected/rolled-back edge | Discard candidate and boundary advance. |
| Successful default-loop miss | Expose `[gap_cursor, input_end)` as `tail` to `LX`. |
| Satisfied repetition miss / maximum | Expose the same tail to `EX` / `E`. |

The private live/generated accessors are deliberately small:

- `gap_span()` → detached `{source_id, start, end, provenance}` with `provenance = "gap"`;
- `gap_text()` → exact decoded text materialized from that span;
- `gap_kind()` → `prefix`, `interstitial`, or `tail`.

Empty prefix, interstitial, and tail spans are observable; none are trimmed or suppressed. A successful
zero-match/zero-min rule sees the whole input as tail. A failed minimum sees no tail. Tail access never consumes
input and no gap is appended to an AST or result automatically.

Accepted match presence—not action-payload truthiness—commits an edge. A child that advances beyond its selected
entry match moves the next committed boundary to its accepted post-`LE` cursor. Rollback restores gap state along
with the owning invocation's cursor/boundary/marks, but cannot undo variables, AST mutations, diagnostics, output,
external calls, or host effects. Nested and recursive calls share the existing monotonic invocation authority and
receive isolated gap state rather than a second stack or an aliased parent cursor.

The directive does not redefine return channels. In repeated action rules, an edge return stays a per-hit value
and the successful iteration still finalizes its gap. In an unadorned default scan loop, an edge return remains a
direct whole-rule return: the candidate clears during unwind, no new boundary commits, and no tail is invented.
Lifecycle returns remain whole-rule returns and preserve their payload.

The current metadata/native-live/generated fixtures cover all four `=` spacing forms, Unicode names, mixed declarations,
named reorder, duplicate-regex identity, prefix/interstitial/tail, every empty position, child-extended exit,
falsey success, zero-match and maximum termination, failed commit, and recursive isolation. Negative fixtures
cover invalid or duplicate names, unknown/out-of-range/malformed selectors, duplicate/ineligible directives,
anonymous-marker conflict, unavailable gap context, lifecycle reorder, transaction leakage, storage/routing
drift, and premature public claims.

Emitted Perl source imports the private runtime and keeps the same named dependency-slot provenance without
widening the generated v2 plan beyond ordered `{label,family}` rows. Generated `Execute` establishes the same
zero input boundary as ordinary `Get`; unindexed rows use the generated dependency map without assuming live rule
metadata; and both generated entrypoints preserve private context and gap-owned cursor diagnostics as their
original typed errors. Five independently loaded groups / 138 internal assertions compare canonical values,
cursors, lifecycle, recursion, rollback, diagnostics, direct entry, and legacy rolling against live execution.

The rollout has nine ordered legs: neutral, Perl, Rust, Dart, Julia, PUC Lua, LuaJIT, recurring proof, and public
no-drift. Runtime consumers will cover native/live execution, reconstructed state, descriptors, generated plans
and independently loaded emitted source, target lifecycle, recursion/rollback, diagnostics, and primary commands.
Until public closeout, README, facades, semantic/MCP schemas, CLI, capability status, and typed-source
`lossless_gap_composition` remain unchanged.

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
