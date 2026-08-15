# 0045 - Inter-match gap capture preserves action-edge target ownership

- Date: 2026-07-17
- Status: accepted; executable-neutral plus private Perl and Rust admission current; later runtimes/public admission pending
- Tags: architecture, grammar, capture, segmentation, or-rule, action-edge, source-span, portability, parity

## Context

LinkedSpec's imported Perl baseline already contained a `# Split-Like Code` parser entry for
`@move_pos`. In a repeated action handler it initialized `$IPOS` at rule entry, exposed the text
from `$IPOS` to the next selected match's left edge through `$CAPTURE`, ran that match's action,
and then updated `$IPOS` from `pos $$STRING` through local-end code. This made each action see the
otherwise unmatched source text before its selected match and rolled the boundary automatically
afterward.

The match alternatives did not come from regexes placed immediately before the action edges.
Each `-> Target[index]` stored `Target` and `index`; `spec_gdata` copied that regex slot from the
target rule into the enclosing rule's combined matcher. The baseline `grammar_file::` rule already
used this external-target shape extensively, and `logging_annotation` combined target rules such as
`quoted_string` and `comma` with a self-targeted closing slot. Target rules retained their own
lifecycle and action code.

Later documentation drift obscured that model in two stages. A 2026-03-19 guide introduced examples
that placed a regex immediately before `-> Rule { ... }`, visually implying an adjacency trigger,
and described `@move_pos` mainly as a manually placed split cursor. A later commit associated “super
split” with blind-call orchestration. Neither description captures the director's original concept.
The current Perl IR/runtime still resolves action edges to the named target rule and slot, and a live
three-slot probe confirms exact prefix/interstitial gap capture plus target lifecycle results.

A final backend audit also found that later marker-parity documentation had overreached. Perl lowers
anonymous `@capture_slice`, `@capture_from_here`, and `@move_pos` to unconditional rule-level local-end
code, while its separate `@mark(name)` form is guarded by the preceding regex index. Lua/LuaJIT later
implemented all four as preceding-slot events. Rust drops the parsed marker while compiling native
state; Dart and Julia retain source body elements but their native runtimes do not consume them. That
divergence is existing behavior and is not repaired by this decision-only slice.

## Decision

### 1. Fix the concept and vocabulary

The historical nickname “super split” means **inter-match gap capture**: lossless access to source
text between the boundary left by one successful action-edge match and the left edge of the next
successful match in a repeated OR/default action rule. It is unrelated to blind calls.

**Lossless segmentation** is the broader architectural model. `@capture_gaps` is the accepted future
name for the backend-neutral rule directive. It is not current syntax yet.
`@move_pos`, `@capture_from_here`, and `@capture_slice` remain accepted compatibility spellings, but
their execution is currently backend-divergent. The executable contract must define an explicit
migration from actual behavior rather than assuming the later parity claim was true.

### 2. Preserve target-rule ownership

Regexes remain declared by the rule that owns them. The enclosing repeated OR/default rule selects
those regex slots with action edges. Unindexed `-> Document` selects the default slot under the
existing action-edge contract; `-> Document[1]` and `-> Document[2]` select later zero-based slots.
The target rule remains a real parser with its own lifecycle/action code.

The conceptual shape is:

```text
Document:
 /HEADER[^\n]*/
 /SECTION[^\n]*/
 /FOOTER[^\n]*/
 I {
   return(hash("text", entry_text()))
 }

Top::OR
 I { declare(array, segments) }
 @capture_gaps
 -> Document[0] { ... }
 -> Document[1] { ... }
 -> Document[2] { ... }
 LX { return(copy(segments)) }
```

This is illustrative future syntax: the executable contract still owns the neutral gap accessor and
result shape. An adjacent regex is never the trigger or qualifier for the following action edge.
Inline regex/action paragraph forms may remain valid for their independently documented uses, but
they must not be used to explain this feature.

### 3. Preserve automatic rolling semantics

The new model must be expressed as per-invocation state, not as public Perl cursor arithmetic:

```text
gap_cursor = rule_entry_boundary
for each successful selected action edge:
    gap = source_span(gap_cursor, selected_match.start)
    run the edge action with gap and selected-match context
    gap_cursor = accepted_parser_cursor_after_action
```

The state belongs to one rule invocation and must be isolated across recursion and nested calls. The
gap is exact source text: whitespace, line breaks, Unicode text, and empty spans are not silently
trimmed or discarded. A backend may represent it lazily as a typed source span and materialize text
on demand.

The post-action cursor matters. If the action merely accepts the selected regex, it is normally that
match's end. If the action calls the target rule and its lifecycle consumes farther, the boundary is
the accepted cursor after that work. The executable contract must specify commit/rollback behavior
for failed actions, backtracking, explicit cursor mutation, and nested calls before implementation.

“Automatic capture” means the current gap is supplied by the rule mechanism and the boundary rolls
after the action. It does not require the engine to append a particular AST node or array entry. The
baseline contained a commented auto-push experiment, while the active implementation left storage
and transformation to `$CAPTURE`, `capture_if`, `CAPTURE_IF`, or user action code. Any future forced
emission surface would be a separate decision, not an implicit part of `@capture_gaps`.

### 4. Replace positional-only coupling with stable named slot identity

The director accepts stable named regex slots as the future direction for avoiding magic numbers.
Unindexed and numeric action targets remain compatibility forms, but the compiler must be able to
resolve a named selector to a typed `{target_rule, target_slot_id}` reference whose meaning survives
declaration reordering. Matcher results carry that identity directly; adjacency, regex text, and
alternation outcome are never identity-recovery mechanisms.

The ratified future source spelling is a rule-paragraph binding plus a bracket selector:

```text
Document:
 header  = /HEADER[^\n]*/
 section = /SECTION[^\n]*/
 footer  = /FOOTER[^\n]*/

Top::OR
 @capture_gaps
 -> Document[header]  { ... }
 -> Document[section] { ... }
 -> Document[footer]  { ... }
```

At rule-paragraph level and outside a code block, same-line `IDENT HSPACE* = HSPACE* REGEX` declares a
rule-local named regex slot rather than a mutable variable. Horizontal whitespace around `=` is
insignificant: `header=/.../`, `header= /.../`, `header =/.../`, and `header = /.../` are equivalent.
The syntax is ratified for the future contract but is not implemented. The executable contract must
still settle name uniqueness/reservation, anonymous/named mixing, descriptor projection,
numeric/name equivalence, lifecycle accessors, diagnostics, and migration.

### 5. Reconcile the existing marker divergence explicitly

The migration baseline is:

| Backend | Current anonymous marker behavior |
| --- | --- |
| Perl | One marker enables unconditional rule-level post-action rolling. |
| Lua / LuaJIT | Each marker is attached to the preceding regex slot and fires only for that slot. |
| Rust | Marker is parsed, then dropped from native compiled state. |
| Dart / Julia | Marker is parsed and preserved as source body data, but not executed natively. |

This decision does not choose one of those current implementations as the neutral contract by
accident. `@capture_gaps` owns the historical automatic rule-level concept. The executable contract
must separately decide whether Lua's positional marker behavior keeps a distinct surface, migrates to
explicit helper calls, or remains as a documented compatibility mode. Explicit helpers are not part
of this divergence.

### 6. Specify boundary and failure policy before implementation

The neutral contract must fix, with executable fixtures:

- whether entry-to-first-match prefix is always exposed, optional, or separately named;
- whether and how the final match-to-end-of-input tail is exposed when no next match exists;
- exact empty-gap behavior;
- when boundary state commits if action code fails, rejects, backtracks, recurses, or mutates cursor;
- action ordering and the interaction with target-rule lifecycle results;
- typed span offsets and optional line/column projection;
- diagnostics for invalid directive placement or unsupported edge ownership;
- legacy alias behavior and migration;
- named regex-slot declaration/selection, stable typed identity, and numeric/name equivalence;
- native, generated, reconstructed, and primary parity across all five backends.

The historical Perl behavior is evidence, not permission to leave these policies implicit. The live
reference currently exposes entry-to-first-match and interstitial gaps, advances after every
successful action, and does not automatically expose the unmatched tail after the final match.

### 7. Keep implementation behind the cursor rollout

This decision changes no parser, compiler, runtime, descriptor, generated source, CLI, fixture, or
capability behavior. The executable contract and backend rollout remain dependency-gated behind
completion of `FUTURE-PARITY-BACKLOG.9.1`, so the active rule-local cursor migration is not mixed
with a new capture contract.

## Implementation order

`INTER-MATCH-GAP-CAPTURE.1` defines the neutral schema, semantics, fixtures, diagnostics, and legacy
migration. `.2` implements the Perl reference without overloading `$IPOS` for the new typed surface;
`.3-.6` implement Rust, Dart, Julia, and Lua/LuaJIT; `.7` closes generated/primary parity, migration,
and public no-drift. No implementation leaf activates until the rule-local cursor program is closed
and this program is selected at a clean task-tree boundary.

## 2026-08-13 executable-neutral plan amendment

Behavior-free audit `INTER-MATCH-GAP-CAPTURE.1.0` closes the questions deliberately left to the executable
contract while moving no current syntax, descriptor, helper, runtime, rollout, or public claim.

The neutral authority will be `capability_conformance/inter_match_gap_capture_contract.json`, format 1,
contract id `linkedspec-inter-match-gap-capture-v1`, with independent checker
`tools/check_inter_match_gap_capture_contract.py`. It has nine ordered rollout legs: neutral, Perl, Rust, Dart,
Julia, PUC Lua, LuaJIT, recurring proof, and public no-drift. Neutral `.1.1` promotes only the first. Governance
`.1.2` fixes repository-rooted storage, exact consumer routes, the opt-in canonical driver, and no-overclaim
guards without promoting runtime behavior. `.1.3` recomposes the unchanged authority before Perl `.2`.

Named slot declarations reuse pinned Unicode 17.0.0 `XID_Continue` identity exactly, including case and
normalization sensitivity; all-ASCII-digit names are reserved for positional selectors. Named and anonymous
declarations may mix in one authored order and names are unique per owning rule. `Rule`, `Rule[N]`, and
`Rule[name]` are the only selectors. Every resolved edge retains selector kind, authored selector, target rule,
zero-based regex index, and nullable stable slot id. A numeric and named selector can resolve the same named slot,
but only named provenance remains identity-stable across declaration reordering. Direct target invocation has no
edge-slot context; future `entry_slot()` projects an edge entry as one detached ordinary harray rather than a new
value kind.

`@capture_gaps` is one placement-insensitive rule-level directive for a seek-based looping OR/default rule with
statically resolved action ownership. It is invalid on AND/consume, blind, mixed, or adjacency-owned shapes and
cannot coexist with anonymous legacy marker members. The legacy `@capture_slice`, `@capture_from_here`, and
`@move_pos` behaviors are preserved as compatibility behavior rather than redefined as aliases. Named marks and
explicit capture helpers remain independent. There is no automatic-emission directive: gap capture supplies
context and never forces AST/result mutation.

One invocation-local state starts at the rule-entry Unicode-scalar position. After a selected match and before
enclosing `LS`, it exposes the exact half-open prefix/interstitial span through future `gap_span()`, `gap_text()`,
and `gap_kind()` context. The candidate remains visible through the edge, target call, and enclosing `LE`; only an
accepted edge commits the post-`LE` cursor as the next boundary, then clears before `IT`. Falsey action payloads do
not turn a successful match into failure. Rejection, rollback, or unwind discards the candidate and boundary
advance. Nested/recursive entries reuse the existing monotonic invocation authority but own isolated gap state.

Return-channel ownership does not change. ADR `0048` repeated action-edge returns remain per-hit values and run
the successful-iteration finalization path. An unadorned default-loop action return remains a direct whole-rule
return: it clears the active candidate on unwind without committing a boundary or synthesizing a tail. Lifecycle
returns likewise retain whole-rule authority and their returned value exactly.

On successful loop termination, the same context exposes the final half-open span from committed boundary to
input end as kind `tail` before `LX` on a default scan-loop miss, `EX` on satisfied repetition exhaustion, or `E`
after maximum-count completion. A failed minimum has no tail; a successful zero-match/zero-min invocation sees the
whole input extent. Prefix, interstitial, tail, and empty gaps are all first-class. Tail observation neither
consumes input nor appends output. All gap spans use the existing immutable same-source typed-span algebra and
join the owning invocation's cursor/boundary/mark transaction snapshot; rollback never gains authority over user
variables, AST, output, external calls, or other effects.

The neutral checker will execute spacing, Unicode-name, mixed-declaration, selector equivalence/reorder,
duplicate-regex identity, eligibility, exact Unicode/empty prefix-interstitial-tail, target-extended cursor,
falsey acceptance, maximum/miss termination, failed commit, and recursive-isolation cases. It will reject invalid
or duplicate names, unknown/out-of-range/malformed selectors, duplicate/ineligible directives, legacy conflicts,
unavailable gap context, lifecycle reorder, transaction leakage, storage/route drift, premature rollout, and
public overclaim. Existing source/range/cursor/progress diagnostic codes remain authoritative; nine new exact
syntax/context diagnostic records cover only the genuinely new boundaries.

## 2026-08-13 executable-neutral artifact amendment

`INTER-MATCH-GAP-CAPTURE.1.1` now makes the behavior-free authority executable. The format-1 JSON artifact and
independent checker exist at the ratified root-relative paths. Checker-first RED failed exactly because the
artifact was absent; after the artifact was added, the checker executed the Unicode, empty-boundary,
child-extended, falsey-acceptance, rollback, and nested-isolation model and rejected all 50 frozen in-memory
semantic corruptions for their expected reasons.

The rollout is exactly 1 complete + 8 pending: only `neutral_contract` is complete. The named declaration,
`Rule[name]`, `entry_slot()`, `@capture_gaps`, and `gap_*` surfaces are still not accepted by any parser or runtime.
No compiler, descriptor, generated carrier, helper, facade, schema, semantic/MCP, CLI, README, capability, or
typed-source behavior moved. `.1.2` still owns canonical routing, storage/topology governance, and public
no-overclaim; `.1.3` still owns neutral recomposition before Perl implementation.

## 2026-08-13 recurring-governance amendment

`INTER-MATCH-GAP-CAPTURE.1.2` makes the neutral authority canonically recurring without admitting a runtime.
`tools/check_inter_match_gap_capture_six_runtime.sh` derives the repository root from its own location, enters the
existing project-data run boundary, executes the neutral checker exactly once, then emits explicit ordered skips
for the pending Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT consumers. Canonical local CI always executes the
neutral checker and exposes that ordered governance route only under `LINKEDSPEC_RUN_INTER_MATCH_GAP_MATRIX=1`.

The contract now fixes repository-derived same-volume storage, neutral-plus-six route order, all six runtime rows
remaining pending, and five exact current-document markers plus ten outward facade/schema/CLI/README guards. The
checker rejects `rollout_sequence`, `runtime_rows_pending`, `storage_paths`, `route_order`, and
`public_no_overclaim` corruptions, advancing neutral governance from 50 to 55 mutations. Rollout remains exactly
1 complete + 8 pending: the `recurring` and `public_no_drift` rows are still owned by `.7`, because a current route
definition is not proof of admitted six-runtime behavior.

This amendment changes no grammar, parser, compiler, runtime, descriptor, generated carrier, helper, facade,
schema, semantic/MCP, CLI, README, capability, or typed-source behavior. Named declarations, named selectors,
`entry_slot()`, `@capture_gaps`, and the three `gap_*` accessors remain planned and unimplemented.

## 2026-08-13 neutral-closeout amendment

`INTER-MATCH-GAP-CAPTURE.1.3` independently recomposes the committed `.1.1-.1.2` authority before runtime work.
The format-1 artifact still passes 8 positive + 10 negative fixtures, 3 sources, 16 transitions, 10 segmentation
cases, 9 diagnostics, rollout 1 complete + 8 pending, and all 55 reason-checked mutations. The rooted driver still
executes neutral exactly once and reports the six absent Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT consumers as
ordered skips. Independent JSON, marker, outward-surface, and missing-consumer checks agree.

The activation-commit diff proves the contract, checker, driver, canonical/storage routes, all backend code, ten
outward API/schema/CLI/README surfaces, and README bytes are unchanged from `0490522b`. Storage/outside-CWD,
duplicate-slot 59, and typed-source 9/5/114 proofs pass. Therefore parent `.1` closes only the neutral-program
phase; it admits no grammar, parser, compiler, runtime, descriptor, generated carrier, helper, facade, schema,
semantic/MCP, CLI, README, capability, typed-source, recurring, or public behavior. Perl reference implementation
remains exclusively owned by `.2`.

## 2026-08-13 Perl implementation-plan amendment

`INTER-MATCH-GAP-CAPTURE.2.0` completes the behavior-free Perl audit from clean `db299789` and dependency-splits
implementation into `.2.1-.2.4`. Toolbox descriptors prove current numeric slot resolution and eligible execution
metadata; direct compilation proves named declarations/selectors, `@capture_gaps`, and all four accessors remain
absent. A generated-source probe fixes the actual selection → match extraction → `LS` → action/target → legacy
`LECODE` → authored `LE` → `IT` order. The corrected live legacy probe returns prefix/interstitial pairs and no
tail. These are implementation constraints, not new semantics.

`.2.1` owns grammar and metadata only. `specs/spec.spec` is the permanent language description and changes first;
the hardcoded `BootstrapSpec::Core` change is the necessary reference-parser bridge and must remain byte-level
behavioral peers with self-hosted proof. Parsed declarations create one authored `regex_slots` sequence, and
resolved action dependencies carry the frozen five provenance fields through live descriptor metadata and
generated `dependency_slot_map` rows. Generated-source plan v2 does not widen. Exact slot identity comes from a
generated private Perl classifier derived from the repository's pinned Unicode 17 `XID_Continue` ranges; host
Perl's Unicode 13 property tables are explicitly non-authoritative.

The exact Perl consumer is introduced dormant with metadata/live/generated phase selection. Ten checker-local
mutations protect the staged consumer and prevent canonical, recurring, or facade admission; they are deliberately
separate from the neutral artifact's 55 mutations and 1-complete/8-pending rollout.

`.2.2` owns the live state. `InterMatchGapRuntime` attaches the three-member state to the existing
`RecognitionTransactionRuntime::InvocationGuard`; it creates neither another stack nor another cursor. Candidate
installation is after selected-match extraction and before enclosing `LS`; accepted commit is after authored
`LE` and before `IT`; successful tails are installed before default `LX`, satisfied-repeat `EX`, and maximum
`E`. Target entry metadata is private, parent-guard-checked, and target-rule-checked. `entry_slot()` therefore
returns a detached record only inside the selected action-edge target; direct entry remains `undef`, and child
invocations hide parent gap context.

Recognition checkpoint composition stores the three frozen gap snapshot members on that same guard under the
existing token identity. Commit discards the snapshot and rollback restores it. `RecognitionTransaction.pm`'s
cursor/boundary/marks authority schema remains unchanged. The four accessor nodes are private `source_read`
ActionIR nodes. Consequently the closed recognition-effect census must advance from 133 to 137 rows while its
246 canonical calls, 58 mutations, and 9/9 rollout remain unchanged. The four names are explicitly non-public in
language coverage, preserving the 122 public-helper census, and they do not enter the typed-source 92+7 helper
algebra before final composition.

`.2.3` owns emitted/loaded parity and typed-error propagation without a plan-v2 change. `.2.4` removes dormancy,
executes the same full assertion set once canonically and once through the rooted driver, promotes only
`perl_runtime`, and advances the neutral checker from 55 to 56 with a premature-Rust corruption. All outward
facade/schema/semantic/MCP/CLI/README guards, later runtime rows, recurring/public rows, capability admission, and
typed `gap_composition` stay pending.

Definitive `.2.0` signoff preserves gap 1/8/55, recognition 133/246/58, public helpers 122, and typed source
9/5/114. The rendered 79-file / 14,652-KiB book, Knowledge 833/6,984, all eight doctrines, containment,
all-five-anchor relocation, CLI 66/66 twice, RAM 66%, Phase 0 1,031/1,031 in 745 seconds, the exact opt-in pending
route, and final local-CI exit 0 all pass without implementation movement.

## 2026-08-13 Perl authored-metadata amendment

`INTER-MATCH-GAP-CAPTURE.2.1` implements the authored and static half of the Perl plan from clean `8f826923`.
The permanent `specs/spec.spec` grammar and the hardcoded reference bridge now recognize spacing-insensitive
`name=/regex/`, `Rule[name]`, and the rule-level `@capture_gaps` directive. Anonymous regex AST rows keep their
old shape. Named declarations and selectors use a generated private Perl classifier derived from the same pinned
Unicode 17.0.0 `XID_Continue` table as rule labels; every scalar position uses that class, identity is exact, and
ASCII digit-only names remain reserved for positional selectors.

Perl RuleIR now retains one ordered `regex_slots` catalog and projects resolved action selection separately as
five-field `resolved_slot_edges`: `selector_kind`, `authored_selector`, `target_rule`, `regex_index`, and nullable
`target_slot_id`. Dependency references and generated `dependency_slot_map` rows retain that provenance whenever
the selected destination has stable named identity, including self-target local-slot expansion. The legacy
`resolved_edges` and anonymous dependency shapes remain compatible; generated-source plan v2 does not widen.

Static validation reports exact typed declaration, selector, directive-eligibility, duplicate-directive, and
legacy-marker-conflict diagnostics with source identity and authored line context. An eligible directive produces
descriptor metadata only. No gap invocation state, lifecycle placement, transaction snapshot, accessor lowering,
tail handling, or generated/loaded gap execution exists in this amendment: `entry_slot()` and `gap_*` remain
unsupported, and `.2.2-.2.4` retain those owners.

The final-path Perl consumer exists in dormant metadata/live/generated modes. Metadata and ordinary named-slot
selection are green; live and independently loaded gap modes fail deliberately until their owning leaves. Ten
independent dormancy mutations prevent premature canonical, recurring, or facade admission. Therefore neutral
rollout stays 1 complete + 8 pending with 55 semantic/governance mutations; recognition remains 133/246/58,
public helper coverage remains 122, typed source remains 9/5/114, and all outward schema/MCP/CLI/README surfaces
remain unchanged.

## 2026-08-13 Perl native-live amendment

`INTER-MATCH-GAP-CAPTURE.2.2` implements the already-ratified live half from clean `912fc5ed`. Private
`InterMatchGapRuntime` attaches candidate state to the active recognition invocation guard and uses that guard's
monotonic identity and token ownership. It adds neither another invocation stack nor another cursor, and `$IPOS`
retains its compatibility capture-boundary meaning.

Matcher selection installs exact prefix/interstitial state before `LS`; accepted completion commits the
post-`LE` cursor and clears before `IT`; successful default/repetition/max terminals install tail before
`LX`/`EX`/`E`. Child-extended cursors, falsey payloads, empty spans, direct/nested entry, recursion isolation,
unwind, and legacy markers retain their frozen ownership. Existing recognition checkpoints detach three gap
members and restore them together on rollback. Four private source-read ActionIR nodes advance the derived
recognition census to 137/246/58 while language coverage remains 122 public helpers.

The dormant consumer's default metadata mode passes 110 assertions and its private live mode passes all nine
behavior groups. This amendment does not import the private runtime into independently loaded source, register the
consumer, promote `perl_runtime`, change gap 1/8/55, or widen any facade/schema/semantic/MCP/CLI/README/typed-source
surface. Those boundaries remain `.2.3`, `.2.4`, and final cross-backend closeout.

Signoff passes all eight doctrines, repository containment and relocation, CLI 66/66 twice, RAM 76%, Phase 0
1,031/1,031 in 756 seconds, and the exact opt-in neutral-plus-six-pending route. The unchanged authorized run
resolved only the outer harness's nested-`sandbox-exec` denial and exited 0 at the local-CI pass marker.

## 2026-08-13 Perl generated-carrier amendment

`INTER-MATCH-GAP-CAPTURE.2.3` carries the unchanged private Perl contract through emitted and independently
loaded generated source from clean `34d02e0c`. Emitted source imports `InterMatchGapRuntime`, retains the existing
five-field named dependency-slot provenance, and leaves generated-plan v2 as ordered `{label,family}` rows.
Generated `Execute` establishes the same zero input boundary as ordinary `Get`; this preserves historical
`@move_pos`/`capture_slice()` behavior without turning the legacy marker into a gap alias or adding a cursor.

Generated descriptor `spec` entries are code references, unlike live rule hashes. The private runtime therefore
uses `dependency_slot_map` as its generated selection authority and consults live `regex_slots` metadata only
when a live hash entry actually exists. Named selectors retain their stable id; unindexed compatibility rows keep
their nullable id rather than dereferencing a handler as metadata.

`Execute` and `ExecuteWithTrace` rethrow anything classified by `InterMatchGapRuntime::is_error`, preserving both
private unavailable-context errors and gap-owned typed source cursor-regression errors instead of wrapping them as
generic generated failures. The generated consumer now passes five groups / 138 internal assertions against live
execution over exact Unicode/empty values, detached spans and slot provenance, falsey results, child-extended and
terminal lifecycle, recursion, rollback, diagnostics, direct entry, and legacy rolling.

This amendment does not register the dormant consumer, promote `perl_runtime`, change gap 1/8/55 plus ten
dormancy locks, change recognition 137/246/58, change 122 public helpers or typed source 9/5/114, or widen any
facade/schema/semantic/MCP/CLI/README surface. Those admission boundaries remain `.2.4` and final cross-backend
closeout.

Definitive signoff passes the rendered mdBook, Knowledge Map 834/6,995, all eight doctrines, containment and
all-five-anchor relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 773 seconds, the exact opt-in
neutral-plus-six-pending route, and local-CI exit 0. The preceding unchanged sandboxed run stopped only at the
outer harness's nested-`sandbox-exec` status 71; the permission-authorized run resolved that boundary.

## 2026-08-13 Perl runtime-admission amendment

`INTER-MATCH-GAP-CAPTURE.2.4` admits the already-complete private Perl path from clean atomic 225 at `45460329`.
The final consumer defaults to all metadata, live, and independently loaded generated phases and passes 124
top-level tests. Canonical CI runs it exactly once; the repository-rooted recurring driver runs the neutral
checker and then the same consumer exactly once before five ordered later-runtime skips.

Only `perl_runtime` becomes complete, owned by `.2.4`. The rollout is 2 complete / 7 pending. The former
Perl-pending mutation becomes a complete-to-pending regression and a premature-Rust mutation advances exact
semantic/topology governance from 55 to 56. The ten checker-local dormancy mutations are removed because their
staging boundary no longer exists; exact admission registration replaces them.

Rust, Dart, Julia, PUC Lua, LuaJIT, recurring, public no-drift, capability admission, and typed
`gap_composition` remain pending. Public status markers may state private Perl admission, but the same ten
facade/schema/semantic/MCP/CLI/README surfaces remain forbidden from exposing the feature. Recognition
137/246/58, public helpers 122, typed source 9/5/114, and generated plan v2 do not move.

Definitive 2026-08-14 signoff passes the rendered mdBook, Knowledge Map 834/6,995, all eight doctrines,
six-family repository containment, all-five-anchor relocation, CLI 66/66 in both option environments, RAM 57%,
Phase 0 1,031/1,031 in 765 seconds, the exact opt-in neutral-plus-Perl route with five later-runtime skips, and
local-CI exit 0. Parent `.2` therefore closes for intended atomic 226 without later-runtime or public promotion;
Rust `.3` becomes the next eligible implementation leaf only after that landing is clean.

## 2026-08-14 Rust implementation-plan amendment

`INTER-MATCH-GAP-CAPTURE.3.0` begins task-tree-first from clean atomic-226 commit `eceb15ac` and freezes the Rust
implementation before behavior changes. Exact primary-process probes prove numeric `Rule[N]` already works, while
`name=/regex/` is retained only as raw text, `Rule[name]` falls back to slot zero with an unconsumed suffix,
`@capture_gaps` is ignored, and all four private accessors reach generic unknown-helper behavior. Targeted source
inspection locates those results in the digit-only parser/AST, numeric-only compiled edges, missing directive/slot
metadata, and absent runtime frame fields.

`.3.1` owns authored syntax, exact static diagnostics, Unicode-17 slot identity, selector/directive AST, compiled
slot rows, five-field resolved provenance, serde-compatible defaults, and dormant final-consumer staging. `.3.2`
owns native live state: the existing recognition invocation frame and checkpoint snapshot gain the private gap
members and entry-slot identity; no second cursor, transaction token family, or invocation stack is permitted.
Candidate state becomes visible before capture-enabled `LS`, persists through action/target/`LE`, commits before
`IT`, and successful terminal tails appear before `LX`/`EX`/`E`. Unflagged lifecycle order does not move.

`.3.3` owns ordinary reconstruction, descriptor projection, and parity in the separate
`GeneratedPlanExecutor`. `source_emitter.rs` continues to embed serialized `CompiledSpec`; generated plan v2 stays
exactly `{label,family}`. `.3.4` owns independently compiled emitted-source direct/traced proof under a
repository-derived scratch/target workspace, never OS temp or home storage. `.3.5` owns primary proof, exact
nine-role composition, canonical/recurring registration, Rust-only rollout promotion, mutation replacement, and
parent closeout.

Rust admission will move only `rust_runtime`, producing 3 complete + 6 pending and an ordered
neutral/Perl/Rust route followed by four later-runtime skips. The existing `rust_runtime_premature` mutation becomes
`rust_runtime_regression`; total mutations remain 56. The recognition contract already contains the four private
gap reads as `source_read`, so 137 rows / 246 calls / 58 mutations, 122 public helpers, typed source 9/5/114,
capability admission, generated plan v2, public facade/schema/semantic/MCP/CLI/README surfaces, recurring/public
rows, and later runtimes remain unchanged or pending.

Definitive `.3.0` signoff preserves that boundary. Focused Rust 1/1, rendered mdBook 79/14,704 KiB, Knowledge
835/7,009, all eight doctrines, containment/relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 741
seconds, exact neutral-plus-Perl/five-skip routing, and local-CI exit 0 pass. The unchanged authorized run follows
the outer harness's expected nested-`sandbox-exec` status 71. `.3.1` may activate only after intended atomic 227,
brief-clear, and clean-tree proof.

## 2026-08-14 Rust authored-metadata amendment

`INTER-MATCH-GAP-CAPTURE.3.1` activates from clean atomic-227 commit `4a95e02a` and implements the already-ratified
Rust authored/static boundary. Named and anonymous regex declarations share authored order; named identity uses
the pinned Unicode-17 rule-label classifier with ASCII digit-only names reserved for positional selectors;
unindexed, numeric, and named action targets retain exact authored provenance; and `@capture_gaps` is a dedicated
rule-level directive rather than a legacy marker alias. Validation emits the frozen source/line-aware diagnostic
records and admits only looping seek-based OR/default action-owner rules. Compilation resolves named identity
before dependency expansion and retains slot rows, directive evidence, and five-field selector provenance.

This amendment does not activate gap state or an accessor. Descriptor projection, generated plan v2, native and
generated execution loops, emitted source, primary commands, and public surfaces remain unchanged. The final Rust
consumer is staged at its permanent path under an explicit ignored-until-`.3.5` owner. Ten checker-local mutations
make that ignored state and canonical/recurring/facade absence executable governance while leaving the neutral
artifact, rollout 2 complete / 7 pending, and 56 semantic mutations unchanged.

## 2026-08-14 Rust private-native amendment

`INTER-MATCH-GAP-CAPTURE.3.2` activates from clean atomic-228 commit `95127e1d` and implements only the ratified
private native boundary. The existing recognition invocation remains the sole stack and transaction-token
authority. Its private frame carries gap activation, immutable source/invocation identity, detached entry-slot
identity, and exactly three checkpointed mutable members: committed gap cursor, accepted-edge count, and current
gap. Public cursor/boundary/marks records remain unchanged.

Capture-enabled native rules select and install their local match plus candidate before `LS`, retain it through
target/action/`LE`, commit the accepted child-extended cursor before `IT`, and expose successful tail context to
the existing `LX`/`EX`/`E` hooks. Unflagged LS-before-selection order and return authority remain unchanged.
Authored gap projection passes internal byte boundaries through the existing source authority to yield detached
Unicode-scalar spans and exact text/kind; child entry identity is accepted only from the active owning candidate.
Nested invocations isolate their state, and recognition rollback restores the same three-member snapshot.

This amendment does not change descriptor projection, ordinary reconstruction, the separate generated-plan
executor, emitted source, primary commands, recurring/canonical registration, or any public surface. The final
consumer remains ignored until `.3.5`, rollout remains 2 complete / 7 pending / 56 mutations, and `.3.3-.3.5`
retain reconstructed/generated, emitted, and primary/admission ownership.

## 2026-08-14 Rust reconstructed/generated carrier amendment

`INTER-MATCH-GAP-CAPTURE.3.3` activates from clean atomic-229 commit `5c4e9d50` and carries the already-current
compiled/native contract through ordinary reconstruction, descriptors, and the separate generated-plan executor.
Serialized `CompiledSpec` remains the only carrier. Ordinary JSON reconstruction preserves declaration-order slot
rows, nullable stable ids, directive source/line evidence, and selector provenance, then executes the same native
gap result.

Descriptor compatibility is additive and separated by meaning. Rule metadata gains `regex_slots`,
`capture_gaps`, and five-field `resolved_slot_edges`; the established semantic `resolved_edges` remains exactly
`ownership,target,regex_index,block,fluent`, and legacy dependency references remain `{label,idx}`. This prevents
selector provenance from silently widening an older outward record while exposing exact detached compiled values.

`GeneratedPlanExecutor` now reads directive activation from the same compiled payload, enters the existing
recognition invocation with active action-edge slot identity, and mirrors native candidate-before-`LS`,
commit-after-`LE`, and tail-before-`LX`/`EX`/`E` timing. It adds no cursor, invocation stack, or transaction token.
Generated source already embeds serialized compiled state, so `source_emitter.rs` and generated-source contract v2
do not change; its static plan remains exact ordered `{label,family}` rows.

This amendment does not independently compile emitted source, execute a primary command, register the ignored
consumer, promote `rust_runtime`, or widen a facade/schema/semantic/MCP/CLI/README surface. Rollout remains
2 complete / 7 pending / 56 mutations plus ten checker-local Rust dormancy mutations; recognition remains
137/246/58, public helpers 122, and typed source 9/5/114. `.3.4-.3.5` retain emitted proof and admission.

## 2026-08-15 Rust emitted/primary/admission amendment

`INTER-MATCH-GAP-CAPTURE.3.4-.3.5` complete the private Rust carrier and admission from clean atomic-230/231
boundaries `9e6ade98` and `c3326f6d`. Fifteen independently compiled direct/traced modules prove that the
unchanged v2 emitter reconstructs the serialized `CompiledSpec` and preserves values, lifecycle, recursion,
rollback, diagnostics, direct entry, and unflagged behavior on repository-volume storage.

The final primary role uses the existing Rust primary adapter—not a new CLI surface—to parse
`alpha, beta | gamma\n- delta`. One repeated item regex returns `alpha`, `beta`, `gamma`, and `delta` while
retaining exact gaps `""`, `", "`, `" | "`, and `"\n- "`. This proves the intended list-shaped use directly:
item recognition is independent from heterogeneous separator preservation, and every accepted item still passes
through the declared regex slot and normal commit/rollback lifecycle.

The ordinary consumer validates the contract-declared nine-role identity/order and records each role exactly
once. Canonical CI registers it once; the repository-rooted recurring driver runs neutral, Perl, and Rust before
four ordered later-runtime skips. Only `rust_runtime` advances, so governance is 3 complete / 6 pending / 56
semantic mutations plus ten Rust admission/regression mutations. The old premature-Rust mutation becomes a Rust
complete-to-pending regression. Generated plan v2, recognition 137/246/58, public helpers 122, typed source
9/5/114, capability admission, runtime facade, semantic/MCP schemas, CLI/README surfaces, Dart/Julia/Lua routes,
and recurring/public rollout rows do not move.

## Consequences

- The director's original concept and target-rule ownership are durable and cannot be reassigned to
  blind calls or regex/edge adjacency.
- Existing Perl behavior remains the compatibility reference while the future public contract becomes
  backend-neutral and recursion-safe.
- The existing Lua positional reinterpretation and the three non-executing native paths are now
  explicit migration inputs rather than being mislabeled as parity.
- Target rules keep their lifecycle behavior; the enclosing OR/default rule owns repeated selection
  and gap orchestration only.
- Named target slots can replace positional magic numbers without removing numeric compatibility.
- Prefix and tail behavior cannot drift accidentally because they must be ratified through executable
  fixtures before implementation.
- The broader manual capture/mark API remains useful but no longer defines the meaning of historical
  “super split.”

## Links

- Task owner: `docs/tasks/INTER-MATCH-GAP-CAPTURE.md`
- Historical baseline: commit `cf25bd37` (`perl/LinkedSpec.pm`, `specs/ebnf.spec`)
- First misleading inline examples: commit `8588b07b` (`USER_GUIDE_RuleModesAndSplit.md`)
- Blind-call terminology drift: commit `300e6950` (`USER_GUIDE_RuleModesAndSplit.md`)
- Existing edge contract: `docs/knowledge/spec-edge-syntax-contract.md`
- Current marker matrix: `docs/knowledge/split-marker-cross-backend-semantics.md`
- Current cursor decision: ADR `0044`
