# INTER-MATCH-GAP-CAPTURE: Lossless Inter-Match Segmentation

## Metadata

- Tree ID: `INTER-MATCH-GAP-CAPTURE`
- Status: `proposed` / direction ratified; implementation dependency-gated
- Roadmap lane: `.spec language evolution / lossless segmentation and source preservation`
- Created: `2026-07-17`
- Last updated: `2026-07-17`
- Owner: repo-local workflow

## Goal

Recover, ratify, and eventually modernize LinkedSpec's historical “super split” mechanism as
inter-match gap capture for repeated OR/default regex rules with action edges. Preserve the
source text between successive matches without coupling the feature to blind-call parser
orchestration or to raw Perl cursor arithmetic.

## Non-Goals

- Do not treat blind calls as part of the “super split” contract.
- Do not change parser/compiler/runtime behavior in the decision-capture leaf.
- Do not start backend rollout before the current rule-local cursor program is complete.
- Do not silently change the existing `@move_pos`, `@capture_from_here`, or `@capture_slice`
  compatibility behavior before a neutral migration contract exists.

## Acceptance Criteria

- The historical Perl algorithm and later documentation drift are recorded accurately.
- The current five-backend marker-scope drift is recorded accurately: Perl's anonymous marker is
  rule-level, Lua's is preceding-slot-local, and Rust/Dart/Julia do not execute the parsed marker in
  their native runtime paths.
- Examples keep regex declarations in their owning target rule and reference those slots from the
  enclosing repeated OR/default rule as `-> Rule` or `-> Rule[index]`; an adjacent regex is never
  presented as the trigger for the following action edge.
- The target rule is demonstrated as a real parser with its own lifecycle/action code, not as a
  passive regex catalog; the enclosing rule owns only repeated edge selection and gap orchestration.
- A durable decision fixes the formal concept, accepted future public name, state model, and rollout boundary.
- Public and continuity documentation no longer associates “super split” with blind calls.
- A future executable contract specifies prefix/interstitial/tail policy, typed spans, action context,
  compatibility aliases, diagnostics, and cross-backend parity before implementation.
- Each completed leaf is committed through `COMMIT.md`.

## Task Tree

- ID: `INTER-MATCH-GAP-CAPTURE`
  Status: `proposed` / direction ratified; implementation dependency-gated
  Goal: Recover and modernize lossless inter-match gap capture without semantic drift.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`

- ID: `INTER-MATCH-GAP-CAPTURE.0`
  Status: `done`
  Goal: Recover the historical mechanism and ratify the director-approved design direction.
  Acceptance: Git history and live Perl source prove the repeated-OR/action-edge boundary algorithm;
    the blind-call association is removed; ADR, Knowledge Map, mdBook, task, roadmap, and live docs
    preserve the agreed meaning, the discovered backend drift, and the dependency boundary; no
    runtime behavior changes.
  Verification: Historical source/diff audit, current descriptor/live Perl probes, Knowledge Map,
    mdBook, memory architecture, doctrine enforcement, and whitespace checks pass.
  Commit: `INTER-MATCH-GAP-CAPTURE.0 - ratify inter-match gap capture`

- ID: `INTER-MATCH-GAP-CAPTURE.1`
  Status: `pending` / dependency-gated
  Goal: Define an executable backend-neutral `@capture_gaps` and typed gap-span contract.
  Acceptance: The contract fixes prefix/interstitial/tail policy, empty-gap preservation, offsets,
    action ordering, tail handling, state commit, recursion scope, compatibility, diagnostics, and
    conformance fixtures before runtime changes. It also fixes named regex-slot declaration/selection
    syntax and typed target-slot identity before matcher or edge changes. Legacy-marker migration
    starts from the explicit backend matrix recorded in `.0`, not from the later parity claim.
  Verification: `pending`
  Commit: `pending`

- ID: `INTER-MATCH-GAP-CAPTURE.2`
  Status: `pending`
  Goal: Implement the neutral contract on the Perl reference without overloading `$IPOS`.
  Acceptance: Per-invocation gap state and typed action context replace implicit arithmetic for the new
    surface while legacy spellings retain their governed compatibility behavior.
  Verification: `pending`
  Commit: `pending`

- ID: `INTER-MATCH-GAP-CAPTURE.3`
  Status: `pending`
  Goal: Implement exact Rust native/generated/primary parity.
  Acceptance: Rust passes the neutral gap corpus and every admitted execution role.
  Verification: `pending`
  Commit: `pending`

- ID: `INTER-MATCH-GAP-CAPTURE.4`
  Status: `pending`
  Goal: Implement exact Dart native/reconstructed/generated/primary parity.
  Acceptance: Dart passes the neutral gap corpus and every admitted execution role.
  Verification: `pending`
  Commit: `pending`

- ID: `INTER-MATCH-GAP-CAPTURE.5`
  Status: `pending`
  Goal: Implement exact Julia native/generated/primary parity.
  Acceptance: Julia passes the neutral gap corpus and every admitted execution role.
  Verification: `pending`
  Commit: `pending`

- ID: `INTER-MATCH-GAP-CAPTURE.6`
  Status: `pending`
  Goal: Implement exact Lua/LuaJIT native/reconstructed/generated/primary parity.
  Acceptance: Both Lua ABIs pass the neutral gap corpus and every admitted execution role.
  Verification: `pending`
  Commit: `pending`

- ID: `INTER-MATCH-GAP-CAPTURE.7`
  Status: `pending`
  Goal: Close cross-backend admission, migration, public documentation, and compatibility policy.
  Acceptance: Five backends and all generated/primary roles agree; aliases are retained or retired only
    through the ratified migration policy; the mdBook fully teaches lossless segmentation with examples.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `INTER-MATCH-GAP-CAPTURE.0` | `done` | History, runtime truth, terminology, ownership, future name, and named-slot syntax are durably ratified without behavior change. |
| 2 | `INTER-MATCH-GAP-CAPTURE.1` | `pending` / dependency-gated | Activate only after the current rule-local cursor rollout completes and the director selects this program. |

## Decisions

- `2026-07-17`: “Super split” is historical shorthand for inter-match gap capture in repeated
  OR/default regex rules with action edges; it is unrelated to blind calls.
- `2026-07-17`: Use **inter-match gap capture** as the formal concept, **lossless segmentation** as
  the broader architectural model, and `@capture_gaps` as the accepted future public directive.
- `2026-07-17`: The modern design uses per-rule-invocation gap state and typed spans/action context;
  `$IPOS` remains legacy compatibility machinery rather than the new neutral contract.
- `2026-07-17`: Regex slots remain owned by their declared rule. The enclosing repeated OR/default
  rule observes successful action edges such as `-> Document`, `-> Document[1]`, and
  `-> Document[2]`; a regex written immediately before an edge is not that edge's trigger.
- `2026-07-17`: A target such as `Document` retains its own lifecycle/code. Gap capture does not
  flatten child-rule behavior into the enclosing OR rule or turn child declarations into regex-only
  tables.
- `2026-07-17`: The director accepts stable named regex slots as the direction for avoiding positional
  magic numbers. Numeric/unindexed selectors remain compatibility forms.
- `2026-07-17`: The director ratifies same-line `name=/regex/` as the future named-slot declaration and
  `Document[name]` as its selector. Horizontal whitespace around `=` is insignificant, so
  `name=/regex/`, `name= /regex/`, `name =/regex/`, and `name = /regex/` are equivalent.
- `2026-07-17`: A closeout audit found current anonymous-marker scope is not portable. Perl lowers all
  three anonymous spellings to unconditional rule-level `LECODE`; Lua attaches them to the preceding
  regex slot; Rust drops the parsed marker during compilation; Dart and Julia preserve it only in
  compiled body/source state and do not consume it in native runtime execution. No backend behavior is
  changed in `.0`; `.1` owns the migration decision and executable reconciliation.

## Open Questions

- The executable contract must still ratify exact prefix/interstitial/tail defaults and whether a
  separate automatic-emission surface such as `@emit_gaps` is justified.
- The compatibility policy must decide whether the later Lua preceding-slot behavior remains a
  separate marker surface, migrates to explicit helper calls, or is retained behind a distinct name;
  it must not silently redefine historical rule-level rolling.

## Current Legacy-Marker Execution Audit

| Backend | Parsed surface | Native execution today |
| --- | --- | --- |
| Perl | `@capture_slice`, `@capture_from_here`, `@move_pos`, `@mark(name)` | Anonymous spellings lower to unconditional rule-level `LECODE` and roll after every successful action; `@mark(name)` is separately guarded by the preceding regex index. |
| Rust | Same four forms retained in the AST | `CompiledRule` has no marker/body-event field and the compiler drops `SplitMarker`; the native runtime cannot execute it. |
| Dart | Same four forms retained in AST and compiled `bodyElements` | The compiler creates no event and the native interpreter never reads `bodyElements`; no marker execution. |
| Julia | Same four forms retained in AST and compiled `body_elements` | The compiler creates no event and the native interpreter never reads `body_elements`; no marker execution. |
| Lua / LuaJIT | Same four forms | Compiler creates preceding-regex `rule_slot_events`; runtime executes them post-action/pre-`LE`. This is a later positional reinterpretation, not Perl's anonymous rule-level behavior. |

This matrix distinguishes marker members from explicit action helpers such as
`start_capture_slice()` and `mark_here(name)`, whose separately governed contracts are not changed by
this finding.

## Ratified Named Regex-Slot Syntax

- Stable named regex-slot identity is accepted. The ratified terse syntax binds a rule-local
  slot as `header = /.../` and selects it as `Document[header]`. At rule-paragraph level and outside
  code blocks, same-line `IDENT HSPACE* = HSPACE* REGEX` is a regex-slot declaration, not mutable
  assignment. Horizontal spacing around `=` is non-semantic.
- Compile every action target to a typed `{target_rule, target_slot_id}` reference and carry that exact
  identity through matcher results. Never recover slot identity from adjacency, regex text, or which
  alternation happened to match; this also addresses the existing identical-regex identity hazard
  tracked by `FUTURE-PARITY-BACKLOG.9.1.8.1`.
- Consider a neutral `entry_slot()` / `entry_variant()` lifecycle accessor so a multi-regex target rule
  can distinguish the slot that entered it without pattern inspection or backend-specific state.

## Blockers

- Implementation leaves `.1-.7` are dependency-gated behind completion of the active
  `FUTURE-PARITY-BACKLOG.9.1` rule-local cursor rollout.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-17` | `INTER-MATCH-GAP-CAPTURE.0` | Baseline `cf25bd37` source/spec audit; drift commits `8588b07b`/`300e6950`; current descriptor `Document[0..2]`; live three-gap/lifecycle probe; five-backend marker-scope code audit; `knowledge-map/scripts/check_knowledge_map.sh`; `mdbook build docs/linkedspec-book`; `scripts/check_memory_architecture.sh`; `scripts/check_doctrines.sh`; `git diff --check` | Pass: current code preserves external target-slot ownership and automatic prefix/interstitial rolling; legacy marker divergence is explicit; derived map 583 facts / 4,106 keys; all documentation/governance gates green. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `INTER-MATCH-GAP-CAPTURE.0` | `INTER-MATCH-GAP-CAPTURE.0 - ratify inter-match gap capture` | Historical recovery and design ratification only; no runtime change. |

## Changelog

- `2026-07-17`: Created the task tree before recording the ratified decision or correcting documentation.
- `2026-07-17`: Completed `.0`: recovered the faithful Perl behavior, corrected blind-call/adjacency drift,
  accepted `@capture_gaps`, and ratified spacing-insensitive `name=/regex/` plus `Rule[name]` as future syntax.
