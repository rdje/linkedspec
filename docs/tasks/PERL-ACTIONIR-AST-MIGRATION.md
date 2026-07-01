# PERL-ACTIONIR-AST-MIGRATION — Perl text-to-AST migration

- Status: `active` (created 2026-07-01 by explicit user directive)
- Roadmap lane: `Overall roadmap — compiler architecture / variant contract`
- Owner: repo-local workflow

## Goal

Move the Perl reference backend away from ActionIR text-to-text lowering and toward the
same text-to-AST doctrine already used by the Rust expression runtime. The user-facing
`.spec` contract is variant-neutral: every backend must parse `.spec` helper/action
language text into typed AST/IR before lowering or execution. Broad regex macro rewriting
and host-language fallback are migration debt.

## Acceptance Criteria

- The doctrine is recorded in ADR `0011` and the variant-neutral mdBook.
- Perl migration is split before code into narrow leaves; no leaf may replace broad
  lowering behavior without focused probes, phase0 locks, and corpus/oracle checks where
  applicable.
- The first code slice introduces an AST parser seam behind existing behavior before any
  broad lowering path is replaced.
- Text-to-text fallback for supported helper/value surfaces is retired family by family,
  with diagnostics replacing accidental generated-host-language calls.
- The user-defined function implementation must consume this AST path rather than adding
  new textual macro expansion.

## Task Tree

- ID: `PERL-ACTIONIR-AST-MIGRATION`
  Status: `active`
  Goal: Migrate Perl ActionIR helper/action handling from text-to-text lowering to typed
    text-to-AST parsing and lowering.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`

- ID: `PERL-ACTIONIR-AST-MIGRATION.0`
  Status: `done` (2026-07-01)
  Goal: Adopt text-to-AST as the cross-variant doctrine before code.
  Acceptance: Record an ADR; update the variant-neutral mdBook; add a Knowledge Map fact;
    update live docs and frontier state. No parser/compiler/runtime code changes.
  Verification: **PASS 2026-07-01.** Wrote ADR `0011`, added Knowledge Map fact
    `text-to-ast-backend-doctrine`, updated the variant-neutral mdBook backend handoff,
    compiler pipeline, formal grammar, and architecture chapters, and synced roadmap,
    task-tree index, and live docs. Regenerated `KNOWLEDGE_MAP.md`. Checks passed:
    `bash scripts/check_memory_architecture.sh`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
    `bash scripts/check_doctrines.sh`, `mdbook build docs/linkedspec-book`, and `git diff --check`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.0 - adopt text-to-AST doctrine`

- ID: `PERL-ACTIONIR-AST-MIGRATION.1`
  Status: `done` (2026-07-01)
  Goal: Inventory Perl text-to-text ActionIR lowering sites and define the AST node set.
  Acceptance: Enumerate current string-lowering entry points in `ActionIR::*` and
    `RuleIR::EmitContext`; map each supported expression/statement/control shape to an
    AST node; identify behavior-preserving order of replacement. No behavior change.
  Verification: **PASS 2026-07-01.** Inventoried the raw-string boundaries in
    `StatementSplit`, `MethodExpr`, scanner rule families, `Contracts`, `CanonicalEvents`,
    `RewritePipeline`, `MethodLowering`, and `RuleIR::EmitContext`; defined the
    Rust-aligned AST node set and replacement order; added Knowledge Map fact
    `perl-actionir-text-to-ast-inventory`; regenerated `KNOWLEDGE_MAP.md`. Checks passed:
    stale-frontier search, `bash scripts/check_memory_architecture.sh`,
    `bash knowledge-map/scripts/check_knowledge_map.sh`, `bash scripts/check_doctrines.sh`,
    `mdbook build docs/linkedspec-book`, and `git diff --check`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.1 - inventory Perl ActionIR text lowering`

- ID: `PERL-ACTIONIR-AST-MIGRATION.2`
  Status: `done` (2026-07-01)
  Goal: Introduce a Perl ActionIR AST parser seam behind existing behavior.
  Acceptance: Add focused parser modules/tests for calls, literals, variables, direct
    access, shape literals, blocks, statements, and receiver-dot chains. The seam must
    preserve existing generated behavior until consumers switch over.
  Verification: **PASS 2026-07-01.** Added `LinkedSpec::ActionIR::AST`,
    `LinkedSpec::ActionIR::AST::Parser`, and `t/actionir_ast_parser.t`; wired the focused
    parser test into `tools/run_ci_local.sh`; updated mdBook architecture/status text and
    Knowledge Map fact `perl-actionir-ast-parser-seam`; regenerated `KNOWLEDGE_MAP.md`.
    Checks passed: `perl -Iperl -c perl/LinkedSpec/ActionIR/AST.pm`,
    `perl -Iperl -c perl/LinkedSpec/ActionIR/AST/Parser.pm`,
    `perl -Iperl -c t/actionir_ast_parser.t`, `prove -Iperl t/actionir_ast_parser.t`,
    `prove -q -Iperl t/phase0_regression.t` (1002 tests),
    `bash scripts/check_memory_architecture.sh`,
    `bash knowledge-map/scripts/check_knowledge_map.sh`, `bash scripts/check_doctrines.sh`,
    `mdbook build docs/linkedspec-book`, `git diff --check`,
    `bash -n tools/run_ci_local.sh`, and `bash tools/run_ci_local.sh`.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.2 - add Perl ActionIR AST parser seam`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3`
  Status: `split` (2026-07-01)
  Goal: Replace value-expression and receiver-chain lowering with AST lowering.
  Acceptance: Value calls, helper composition, direct access, shape literals, blocks, and
    receiver-dot chains lower from typed AST nodes, not source-text rescans. Existing phase0
    and terse oracle fixtures remain green; accidental host-call leakage becomes a
    LinkedSpec diagnostic.
  Children: `.3.1`, `.3.2`, `.3.3`, `.3.4`
  Verification: **PASS 2026-07-01 (split only).** Split the broad value/receiver migration
    into focused child leaves before code, preserving the `.3` acceptance as the parent
    contract.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.3 - split AST value lowering`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.1`
  Status: `done` (2026-07-01)
  Goal: Introduce the AST value-lowering dispatcher for non-call value nodes.
  Acceptance: `_lower_method_value_expr(...)` parses with `LinkedSpec::ActionIR::AST` and
    dispatches primitive literals, bare scalar reads, direct indexed/nested access, array
    and hash shape literals, and block values from typed nodes. Existing helper-call
    behavior may remain behind an explicit compatibility bridge for this leaf, but these
    supported non-call nodes must no longer depend on fresh source-text rescans.
  Verification: **PASS 2026-07-01.** Added a `MethodLowering` AST dispatcher for
    primitive literals, scoped bare scalar reads, direct indexed/nested access with the
    legacy reserved-segment guard, array/hash shape literals, and block values. Helper
    calls and statement-level side effects remain behind explicit compatibility bridges.
    Added focused `t/actionir_ast_parser.t` coverage proving AST parser use and preserved
    generated output. Checks passed: `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`,
    `perl -Iperl -c t/actionir_ast_parser.t`, `prove -Iperl t/actionir_ast_parser.t`,
    targeted lowering probes for shapes, blocks, direct access, scalaref key paths, and
    receiver-chain compatibility, and `prove -q -Iperl t/phase0_regression.t` (1002 tests).
  Commit: `PERL-ACTIONIR-AST-MIGRATION.3.1 - lower non-call values from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.2`
  Status: `split` (2026-07-01)
  Goal: Lower helper-call value composition from AST call nodes.
  Acceptance: Supported value helper calls recursively consume AST argument nodes for
    helper composition and aggregate wrappers. Text fallback is limited to explicitly
    unsupported call families with diagnostics/telemetry, not silent host-call leakage.
  Children: `.3.2.1`, `.3.2.2`, `.3.2.3`
  Verification: **PASS 2026-07-01 (split only).** Split helper-call AST lowering by
    argument-slot risk: value-only helper families first, aggregate/symbol-slot helpers
    second, and diagnostics/host-call leakage retirement third.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.3.2 - split AST helper-call lowering`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.2.1`
  Status: `done` (2026-07-01)
  Goal: Lower value-only helper-call composition from AST call nodes.
  Acceptance: Scalar normalization, string predicate, coalesce/concat, and numeric helper
    families consume AST argument nodes recursively before invoking the existing Perl
    helper lowering. Helpers with symbol/aggregate-special slots stay on compatibility
    paths. Focused AST-call composition tests and phase0 remain green.
  Verification: **PASS 2026-07-01.** Added a `MethodLowering` AST call dispatcher for
    value-only helper families. Covered call nodes recursively materialize argument ASTs
    before entering the existing Perl helper catalog through the compatibility bridge:
    scalar normalization, string predicates/composition, coalesce/concat, scalar-argument
    numeric helpers, and explicit `num_*` comparisons. Deprecated wrapper aliases
    (`scalar(...)`/`array(...)`/`hash(...)`), aggregate-wrapper, collection, reducer,
    hash, symbol-slot, and receiver-chain helpers remain compatibility paths and are not
    the canonical destination syntax.
    Focused tests prove fake call-node source text is not reused for covered calls.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.3.2.1 - lower value-only helper calls from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.2.2`
  Status: `done` (2026-07-01)
  Goal: Lower aggregate-wrapper and collection helper calls from AST call nodes.
  Acceptance: Legacy wrapper calls `scalar`, `array`, and `hash` stay classified as
    deprecated compatibility aliases per ADR `0007`, not canonical syntax; any AST lowering
    for them must be slot-policy preserving and retirement-aware. `copy`, `array_copy`,
    `hash_copy`, flat helpers, collection reducers, and hash helpers use explicit AST slot
    policy so symbol-name slots and value-expression slots cannot drift. Existing aggregate
    wrapper quoted-name boundaries remain green.
  Verification: **PASS 2026-07-01.** Added slot-aware AST call dispatch for deprecated
    scalar/array/hash wrappers, copy helpers, flat helpers, array collection helpers,
    numeric reducers with aggregate operands, hash helpers, capture-map/group helpers, and
    hash/array terminal helpers. Covered calls reconstruct helper-call surfaces from typed
    AST node fields before entering the existing Perl helper catalog, preserving symbol
    slots such as `array(items)`/`hash(meta)`, quoted-wrapper literal boundaries, and
    value slots such as counts, keys, delimiters, and nested value-only helper payloads.
    Focused fake-source tests prove covered aggregate helper calls do not reuse call-node
    source text; `mdbook build docs/linkedspec-book`, doctrine/Knowledge Map checks, and
    `bash tools/run_ci_local.sh` remain green with phase0 1002 tests.
  Commit: `PERL-ACTIONIR-AST-MIGRATION.3.2.2 - lower aggregate helper calls from AST`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.2.3`
  Status: `pending`
  Goal: Add covered-call diagnostics and retire silent host-call leakage.
  Acceptance: Helper families covered by `.3.2.1` and `.3.2.2` no longer fall through as
    generated host-language calls when their AST form is unsupported; they emit a clear
    LinkedSpec diagnostic/telemetry path instead.
  Verification: `pending`
  Commit: `pending`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.3`
  Status: `pending`
  Goal: Replace receiver-dot value-chain normalization with AST `fluent_chain` lowering.
  Acceptance: Function-call receivers, literal receivers, direct-access receivers, shape
    receivers, and block-valued receivers lower by traversing `fluent_chain` nodes and
    synthetic AST calls, not by splitting or rebuilding source text.
  Verification: `pending`
  Commit: `pending`

- ID: `PERL-ACTIONIR-AST-MIGRATION.3.4`
  Status: `pending`
  Goal: Replace return-payload helper substitution with AST traversal and diagnostics.
  Acceptance: `_lower_return_payload_expr(...)` walks typed value/call/chain nodes instead
    of regex-substituting helper-looking source spans; accidental generated host-language
    calls on supported surfaces emit a LinkedSpec diagnostic.
  Verification: `pending`
  Commit: `pending`

- ID: `PERL-ACTIONIR-AST-MIGRATION.4`
  Status: `pending`
  Goal: Replace statement/control lowering with AST lowering.
  Acceptance: Assignments, appends, hash-index mutation, set_key, push helpers,
    return/return_undef, if/when/switch/while forms, and block-local returns lower from AST
    nodes. Existing behavior stays stable.
  Verification: `pending`
  Commit: `pending`

- ID: `PERL-ACTIONIR-AST-MIGRATION.5`
  Status: `pending`
  Goal: Retire supported-surface text fallback and unblock user-defined functions on AST.
  Acceptance: Supported helper/value/control surfaces no longer depend on text-to-text
    fallback; unsupported call spellings emit clear diagnostics; user-defined function
    calls are implemented through AST call nodes rather than textual macro expansion.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | `PERL-ACTIONIR-AST-MIGRATION.0` | `done` 2026-07-01 | Doctrine adoption and book alignment before code. |
| — | `PERL-ACTIONIR-AST-MIGRATION.1` | `done` 2026-07-01 | Perl text-to-text lowering inventory, AST node set, and replacement order locked before implementation. |
| — | `PERL-ACTIONIR-AST-MIGRATION.2` | `done` 2026-07-01 | Additive `ActionIR::AST` parser seam and focused parser tests landed without switching lowering consumers. |
| — | `PERL-ACTIONIR-AST-MIGRATION.3` | `split` 2026-07-01 | Parent contract for value-expression and receiver-chain AST lowering. |
| — | `PERL-ACTIONIR-AST-MIGRATION.3.1` | `done` 2026-07-01 | Non-call value nodes now lower from AST. |
| — | `PERL-ACTIONIR-AST-MIGRATION.3.2` | `split` 2026-07-01 | Parent contract for AST helper-call value composition. |
| — | `PERL-ACTIONIR-AST-MIGRATION.3.2.1` | `done` 2026-07-01 | Value-only helper-call composition now lowers from AST call nodes. |
| — | `PERL-ACTIONIR-AST-MIGRATION.3.2.2` | `done` 2026-07-01 | Aggregate-wrapper and collection/hash helper calls now lower from AST call nodes with slot-preserving compatibility. |
| 1 | `PERL-ACTIONIR-AST-MIGRATION.3.2.3` | `pending` | Add covered-call diagnostics and retire silent host-call leakage. |
| 2 | `PERL-ACTIONIR-AST-MIGRATION.3.3` | `pending` | Replace receiver-dot value-chain normalization with AST `fluent_chain` lowering. |
| 3 | `PERL-ACTIONIR-AST-MIGRATION.3.4` | `pending` | Replace return-payload helper substitution with AST traversal and diagnostics. |

## PERL-ACTIONIR-AST-MIGRATION.3.2 Split

AST helper calls need slot-aware migration. Some helper arguments are ordinary value
expressions and can be recursively lowered before invoking the existing helper catalog.
Other slots carry symbols, aggregate wrapper boundaries, regex delimiters, tags, or field
names where premature value lowering would change semantics. `.3.2` is therefore split:

- `.3.2.1`: value-only helper families, including scalar normalization, string
  predicates, coalesce/concat, and numeric helpers;
- `.3.2.2`: legacy aggregate wrappers and collection/hash helpers with explicit
  retirement-aware symbol/value slot policy;
- `.3.2.3`: diagnostics for covered helper-call AST forms that would otherwise leak as
  generated host-language calls.

## PERL-ACTIONIR-AST-MIGRATION.3.1 AST Value Dispatcher

`MethodLowering::_lower_method_value_expr(...)` now parses value input with
`LinkedSpec::ActionIR::AST` before the legacy text cascade. The dispatcher consumes these
typed node families directly:

- primitive literal nodes (`number`, `string`, `boolean`, `regex`, `undef`);
- scoped bare scalar reads in already-supported value slots;
- `indexed_var` and `nested_access`, while preserving the legacy rule that reserved
  path atoms such as `true` and `CAPTURE` leave the whole direct-access expression
  untouched;
- `array_literal` and `hash_literal`;
- `block_value` final values and block-local return payloads.

Nested unsupported helper calls inside AST-lowered shapes and blocks still pass through an
explicit compatibility bridge. Value-only helper-call composition is now covered by
`.3.2.1`; aggregate/symbol-slot helper calls, receiver-dot `fluent_chain` lowering,
statement/control lowering, and remaining return-payload helper substitution are the next
migration children.

## PERL-ACTIONIR-AST-MIGRATION.3.2.1 Value-Only Helper Calls

`MethodLowering::_lower_method_value_expr(...)` now dispatches supported AST `call`
nodes for value-only helper families. The dispatcher canonicalizes numeric word aliases,
recursively lowers argument AST nodes, preserves existing bare-variable behavior in
helper-call slots, and then enters the existing Perl helper catalog through the explicit
compatibility bridge with already-lowered argument expressions.

Covered families are scalar normalization, string predicate/composition helpers,
`concat`, `coalesce`, `coalesce_nonempty`, scalar-argument numeric helpers, and explicit
`num_*` comparisons. Aggregate-wrapper, collection, reducer, and hash helpers are now
covered by `.3.2.2`; receiver-chain helpers remain compatibility paths for `.3.3`.

## PERL-ACTIONIR-AST-MIGRATION.3.2.2 Aggregate/Collection Helper Calls

`MethodLowering::_lower_method_value_expr(...)` now dispatches slot-sensitive aggregate
helper families from AST `call` nodes before the legacy text cascade. The dispatcher
normalizes deprecated wrapper aliases (`s`/`a`/`h`, `scalar`/`array`/`hash`) and numeric
word aliases, rebuilds covered helper-call surfaces from typed AST argument nodes, and
then reuses the existing Perl helper catalog through the compatibility bridge.

Covered families include scalar/array/hash wrappers, `array_copy`, `hash_copy`, `copy`,
`flat`/`flat_array`/`flat_hash`, array collection helpers (`count`, `first`, `last`,
`take`, `take_last`, `drop_front`, `drop_back`, `slice`, `concat_arrays`, `split`,
`split_tagged_records`, `sorted`, `reversed`, `contains`, `index_of`, `join_values`,
array pipeline value helpers), aggregate numeric reducers (`num_sum`, `num_avg`,
`num_median`, `num_range`, unary aggregate `num_min`/`num_max`), and hash helpers
(`merge_hash`, value-form `set_key`, `rename_key`, `drop_keys`, `pick_keys`,
`count_keys`, `sorted_keys`, `sorted_values`, `has_key`, entry/match map helpers).

The compatibility policy is still explicit: wrapper calls remain deprecated aliases
per ADR `0007`, not canonical syntax. Slot reconstruction preserves bare symbol tokens
for aggregate/source slots and quoted wrapper payloads as literals, so `array(items)`
continues to read `@items` while `array("items")` constructs a literal payload.
Receiver-dot `fluent_chain` lowering remains queued for `.3.3`; diagnostics for covered
calls that cannot lower cleanly remain queued for `.3.2.3`.

## PERL-ACTIONIR-AST-MIGRATION.3 Split

`PERL-ACTIONIR-AST-MIGRATION.3` is intentionally a parent contract, not a single
implementation leaf. The migration touches four different lowering mechanisms with
different risk profiles:

- non-call value nodes in `_lower_method_value_expr(...)`;
- helper-call value composition and aggregate-wrapper call arguments;
- receiver-dot value chains;
- return-payload helper substitution and host-call leakage diagnostics.

Each child must keep existing generated behavior green while removing one text-rescan
surface from the supported ActionIR language. User-defined functions remain blocked behind
the completed `.3` children, because function calls must enter as AST `Call` nodes and may
act as receiver-chain receivers.

## PERL-ACTIONIR-AST-MIGRATION.2 Parser Seam

The first code slice is additive and read-only with respect to production lowering:

- Added `LinkedSpec::ActionIR::AST` as the public internal facade for the parser seam.
  It lazy-loads `LinkedSpec::ActionIR::AST::Parser` through `OwnerDispatch`.
- Added `LinkedSpec::ActionIR::AST::Parser` to parse helper/action text into typed hash
  nodes with `kind`, `source`, and `source_span` fields.
- The parser covers `action_block`, `action_stmt`, `call`, `fluent_chain`, `variable`,
  `indexed_var`, `nested_access`, `array_literal`, `hash_literal`, `block_value`,
  `string`, `number`, `boolean`, `regex`, `undef`, `assign_scalar`,
  `assign_array_append`, `assign_hash_index`, and temporary `raw_perl` fallback nodes.
- `ActionStmt` carries `drops_value => 1`, preserving the contract that a standalone
  helper or future user-function call silently drops its value.
- The parser reuses the existing `StatementSplit` and `MethodExpr` seams, then applies an
  AST-only newline refinement for receiver-chain statements. This does not change
  `StatementSplit` or `RewritePipeline` behavior.
- Added focused test coverage in `t/actionir_ast_parser.t` for calls, literals,
  variables, direct access, shapes, block values, assignments, receiver chains with call,
  number, and block receivers, and a guard that current ActionIR lowering remains
  authoritative.

`RewritePipeline`, `MethodLowering`, and `RuleIR::EmitContext` still use the existing
text-lowering path after this leaf. That is intentional: `.3` switches value-expression
and receiver-chain consumers over under behavior locks.

## PERL-ACTIONIR-AST-MIGRATION.1 Inventory

### Current Text Boundaries

- `LinkedSpec::ActionIR::StatementSplit` and `StatementSplit::Core` own the raw
  action-statement splitter. They scan character-by-character, track delimiter and quote
  state, call `MethodExpr::_parse_method_function_expr(...)` for complete method-looking
  statements, and return raw statement strings.
- `LinkedSpec::ActionIR::MethodExpr` owns the smallest current parse seam. It recognizes
  `method(arg1, arg2, ...)`, normalizes short aliases such as `s`/`a`/`h`/`cat`/`set`, and
  splits top-level CSV arguments while preserving nested delimiters and quotes. Its output
  is still raw text, not AST nodes.
- `LinkedSpec::ActionIR::Scanner`, `ScannerCore`, and the scanner rule families inspect
  raw action text with regex/call-shape probes and emit contract-hit event hashes. These
  events are telemetry and canonicalization inputs, not a typed action AST.
- `LinkedSpec::ActionIR::Contracts` still contains many `lower => sub { ... }` callbacks
  that rewrite helper families by source text. Canonical IR-only contracts exist, but the
  compatibility contract catalog still encodes broad text-to-text lowering behavior.
- `LinkedSpec::ActionIR::CanonicalEvents` builds helper events from split raw statements
  and emits `RAW_PERL` fallback events for unrecognized statements. That fallback is
  migration debt for supported helper/value/control surfaces.
- `LinkedSpec::ActionIR::RewritePipeline` is the decisive source-text replacement
  boundary: `_lower_action_code_from_canonical_ir(...)` matches each canonical event's raw
  statement back into the original source with `index(...)` or a flexible whitespace regex,
  then `substr(...)`-replaces that source span with the lowered Perl string.
- `LinkedSpec::ActionIR::MethodLowering` is the largest recursive text parser/lowerer. It
  repeatedly calls `_lower_method_value_expr(...)`, rewrites return payload helper calls
  with regex substitution, splits receiver-dot chains from raw text, normalizes receiver
  chains by constructing helper-call text, and lowers assignment/mutation statements from
  raw method strings.
- `LinkedSpec::RuleIR::EmitContext` is the bridge that applies ActionIR rewriting to
  action/lifecycle code, exposes wrappers for the parser/lowerer helpers, builds rewrite
  metadata, and still discovers automatic working-variable declarations by scanning raw
  pre-lowered code.
- `LinkedSpec::SpecEntry` and `LinkedSpec::Compiler` still emit/eval generated Perl
  handler source. This is outside the first migration boundary: the immediate doctrine
  violation is helper/action text lowering before source emission, not the existence of a
  Perl code-emission backend.

### Rust-Aligned Perl AST Node Set

The Perl parser seam should model the Rust expression/runtime shape instead of inventing a
separate tree:

- `ActionBlock { statements, source_span }` and `ActionStmt { expr, source_span }`.
  Standalone expression statements evaluate and silently drop their value.
- `Call { name, args, source_span }` for helper calls and later user-defined functions.
  Name resolution may classify a `Call` later, but syntax should not become textual macro
  expansion.
- `FluentChain` / `ReceiverChain { receiver, calls }`, where the receiver is any
  expression, including another function call or a block value.
- Value nodes: `Variable`, typed variable reads for scalar/array/hash wrappers,
  `IndexedVar`, `NestedAccess` with explicit access segments, `ArrayLiteral`,
  `HashLiteral`, `BlockValue`, `StringLiteral`, `NumberLiteral`, `BooleanLiteral`,
  `RegexLiteral`, and `Undef`.
- Mutation/assignment nodes aligned with existing Rust variants and Perl helper families:
  `AssignScalar`, `AssignArrayAppend`, `AssignHashIndex`, `SetKey`, `Push`, and
  `ArrayEndMutation`.
- Statement/control nodes: `Declare`, `Return`, `ReturnUndef`, `If`, `While`, `Switch`,
  `Case`, `Default`, `Say`, `Print`, `PrintEach`, `ExitNow`, and `Next`.
- `RawPerl { source, reason }` remains only as a temporary migration boundary for legacy
  compatibility telemetry. New supported surfaces must not add dependencies on it.

All nodes need source spans for diagnostics and parity with today's raw-event telemetry.
Spans replace fragile raw-statement source replacement; they do not disappear.

### Behavior-Preserving Replacement Order

1. `PERL-ACTIONIR-AST-MIGRATION.2`: introduce `ActionIR::AST` parser modules and focused
   parser tests behind existing behavior. Reuse or port the proven delimiter/quote logic
   from `StatementSplit::Core` and `MethodExpr`; run the parser in parallel for
   diagnostics/parity while `RewritePipeline` remains authoritative.
2. `PERL-ACTIONIR-AST-MIGRATION.3`: switch value-expression and receiver-chain lowering
   first. Replace `_lower_method_value_expr(...)`, `_lower_return_payload_expr(...)`, and
   receiver-dot text normalization with AST lowering that still emits Perl source strings.
3. `PERL-ACTIONIR-AST-MIGRATION.4`: switch statement/control lowering after the value
   seam is stable: assignments, array/hash mutations, declarations, returns, if/when,
   switch/case/default, while, block-local return, print/say, exit, and next.
4. `PERL-ACTIONIR-AST-MIGRATION.5`: retire supported-surface `RAW_PERL` fallback and
   unresolved-helper source-text behavior family by family, replacing accidental host-call
   leakage with LinkedSpec diagnostics and enabling user-defined functions through AST
   `Call` nodes.

Automatic working-variable discovery should move from regex scanning to AST traversal as
soon as the parser seam can cover the relevant action/lifecycle blocks.

## Decisions

- `2026-07-01`: The user explicitly rejected Perl source-text lowering as too fragile and
  adopted the Rust-style text-to-AST path as the cross-variant doctrine. Perl must migrate
  carefully; future Julia/Dart backends, and Lua if later adopted, must start from
  text-to-AST rather than text-to-text lowering.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.3.2.2` | Added slot-aware AST aggregate-call dispatcher; focused fake-source AST tests for wrappers, copy, reducers, collection, and hash helpers; targeted public lowering probes; mdBook/doctrine/KM checks; local CI with phase0 1002 tests | Aggregate-wrapper and collection/hash helper calls now consume AST call nodes before helper lowering while preserving deprecated wrapper compatibility, symbol slots, and quoted-name boundaries. Frontier moves to `.3.2.3`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.3.2.1` | Added AST call dispatcher for value-only helper families; focused fake-source AST call tests; targeted public lowering probes for string, numeric, regex predicate, and coalesce/concat composition | Value-only helper-call composition now consumes AST call nodes before helper lowering; aggregate/symbol-slot helper families were left to `.3.2.2`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.3.2` | Split AST helper-call lowering into `.3.2.1` value-only helpers, `.3.2.2` aggregate/symbol-slot helpers, and `.3.2.3` diagnostics/host-call leakage retirement | Helper-call AST migration is owned by slot-risk-specific children before code. Frontier moves to `.3.2.1`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.3.1` | Added `MethodLowering` AST dispatcher for non-call value nodes; focused AST parser/lowering test; targeted lowering probes; phase0 1002 tests | Perl non-call value expressions now lower from AST nodes for literals, scoped bare scalar reads, direct access, shapes, and block values. Helper-call composition, receiver chains, statement/control lowering, and return-payload substitution remain queued. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.3` | Split broad `.3` into `.3.1` non-call value dispatcher, `.3.2` AST helper-call composition, `.3.3` AST receiver chains, and `.3.4` AST return-payload traversal/diagnostics | Value/receiver migration is now owned by narrow children before code. Frontier moves to `.3.1`. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.2` | Added `ActionIR::AST` / `AST::Parser`; focused parser tests; local CI test wiring; KM fact `perl-actionir-ast-parser-seam` + regenerated map; mdBook backend/pipeline/owner-tree status; syntax/focused/phase0/local-CI/diff/memory/doctrine/KM checks | Additive Perl AST parser seam exists behind current lowering behavior. Parser covers calls, literals, variables, direct access, shapes, block values, statements, assignments, and receiver chains; `.3` is the next consumer migration leaf. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.1` | Perl ActionIR text-lowering inventory; Rust-aligned AST node set; replacement order; KM fact `perl-actionir-text-to-ast-inventory` + regenerated map; roadmap/task-tree/live-doc sync; stale-frontier, memory/doctrine/KM/diff checks; mdBook build | Perl text-to-text lowering boundaries are mapped before code. Parser seam `.2` is the next frontier; no parser/compiler/runtime code changed. |
| `2026-07-01` | `PERL-ACTIONIR-AST-MIGRATION.0` | ADR `0011`; KM fact `text-to-ast-backend-doctrine` + regenerated map; mdBook backend-handoff/pipeline/formal/architecture updates; roadmap/task-tree/live-doc sync; memory/doctrine/KM/diff checks; mdBook build | Text-to-AST adopted as a cross-variant doctrine before code. Perl ActionIR text-to-text lowering is now migration debt; future backends must parse helper/action text into typed AST/IR before lowering/execution. No parser/compiler/runtime code changed. |
