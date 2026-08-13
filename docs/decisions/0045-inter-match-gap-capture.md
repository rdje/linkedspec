# 0045 - Inter-match gap capture preserves action-edge target ownership

- Date: 2026-07-17
- Status: accepted direction; implementation dependency-gated
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
