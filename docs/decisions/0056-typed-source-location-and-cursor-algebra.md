# ADR 0056: Typed source-location algebra governs cursor, spans, and parser composition

- Date: 2026-07-29
- Status: accepted; neutral/public contract and six-runtime internal value/projection implementation complete;
  transactions through final public no-drift remain under `FUTURE-PARITY-BACKLOG.14.3-.8`
- Tags: architecture, cursor, source-location, spans, capture, recursion, parser-composition, diagnostics, portability

## Context

LinkedSpec's distinctive authoring model combines connected recursive rules, an explicitly controlled cursor, and
text extraction from remembered source boundaries. Phase 4 documented more than one hundred capture/mark/position
helpers across anonymous capture boundaries, named marks, cursor, input, entry-match, and local-match families.
That surface is expressive, but growing it by adding another helper for every pair of anchors would multiply names
without adding a clearer model.

Several accepted decisions already constrain the right abstraction:

- ADR `0044` makes each rule family the immutable authority for seek/consume cursor policy; a child receives the
  caller's current cursor and then derives its own policy.
- ADR `0012` makes source-provenance text islands and deterministic progressive/staged parser composition core
  architecture, while ADRs `0014`/`0015` require exact parse-job provenance and neutral dispatch.
- ADR `0045` makes invocation-local typed spans the intended basis of lossless inter-match segmentation while
  preserving target-rule and lifecycle ownership.
- Phase 3 deliberately defines LinkedSpec as forward-moving and non-backtracking. `BACKTRACK`/`IBACKTRACK` are
  explicit local cursor rewinds, not a hidden search tree or systemic rollback mechanism.

The director approved a unified direction on 2026-07-29: immutable positions/spans with provenance; recursive
entry/match/exit exposure; bounded checkpoint/try/commit/rollback; span-native progressive parsing; lossless named-
slot segmentation; and static safety diagnostics. The design must add that power without contradicting the
forward-moving model, exposing backend objects, duplicating inter-match-gap ownership, or choosing convenience
syntax before an executable neutral contract exists.

## Decision

### 1. Adopt one minimal typed source-location algebra

The neutral semantic model has three immutable concepts:

1. A **source identity** names caller-authorized decoded input, not a filesystem path or backend object.
2. A **position** is a source identity plus a zero-based Unicode-scalar offset in `[0, input_length]`.
3. A **span** is a same-source half-open pair `[start, end)` plus provenance. `start <= end`; empty spans are valid.

Line/column and UTF-8 byte coordinates are derived evidence, not competing mutable authorities. Public portable
positions use Unicode-scalar offsets. Backends may retain byte indexes internally for efficient slicing, but exact
conversion must be validated against the decoded source and cannot change span identity.

Direct spans carry one source interval. Derived text carries an ordered provenance sequence of source spans plus an
explicit derived-text policy; concatenation may not silently pretend to be one contiguous source interval. Text is
materialized from a span on demand. A span never embeds copied text, a regex/match object, parser state, a path, or
a host-language reference.

### 2. Keep cursor state invocation-local and expose immutable values

The live cursor, anonymous capture boundary, and named-mark table remain mutable implementation state owned by one
rule invocation. Their public/DSL projections are immutable positions or spans. Marks cannot be read outside their
source, invocation, or valid scope generation; recursive and nested calls receive only the current position and
cannot mutate the caller's saved marks or boundary by alias.

Existing `capture_*`, `mark_*`, `cursor_*`, `entry_*`, `match_*`, and `input_*` helpers remain the compatibility and
convenience surface. Their exact results must be expressible as projections over this algebra. The target is a
smaller conceptual core, not a second flat helper catalogue. Future convenience syntax requires its own executable
contract and cannot fork position/span semantics.

### 3. Cursor transactions are explicit, bounded, and not systemic backtracking

A future checkpoint/try/commit/rollback scope is one explicit attempt over a snapshot of the current invocation's
cursor, anonymous boundary, and named marks:

- **checkpoint** creates an opaque invocation-local scope token;
- **try** evaluates a bounded recognition path once;
- **commit** accepts that path's cursor/source-boundary state and invalidates the token;
- **rollback** restores only that snapshot and invalidates the token.

The engine does not discover alternatives, maintain a search tree, unwind callers, or retry automatically. The
transaction cannot cross its owning rule invocation or source identity. It does not roll back user variables, AST
mutation, diagnostic/output events, external calls, parser-registry effects, or host state. Therefore an uncommitted
transactional path must be recognition-only; an effectful operation before commit is rejected unless a later,
separately accepted contract introduces a complete journal for that effect family. Ordinary action/lifecycle work
runs only after the recognition state commits.

Every progress-sensitive repetition, recursive edge, or staged queue transition must prove cursor advance or an
explicit well-founded decreasing measure. Zero-width success remains representable, but it cannot silently satisfy
a progress obligation. This preserves LinkedSpec's forward-moving extraction model while making local speculative
recognition explicit and safe.

### 4. Recursive calls expose boundaries and provenance without changing ownership

Each entered rule may expose immutable entry, selected-match, and accepted-exit positions/spans plus a stable
parent/child provenance relation. Absence is explicit when a rule has no selected regex or does not return normally.
The observation is read-only: the parent supplies its current position, the child re-derives seek/consume from its
own family under ADR `0044`, and the caller resumes from the child's accepted exit position.

Recursive provenance uses snapshot-local invocation identities and bounded parent links; it does not retain live
stack frames or expose backend addresses. Non-progressing direct or mutual recursion is a portable diagnostic, not
a backend stack overflow or an implicit rollback opportunity.

### 5. Progressive and staged parsing consume spans natively

When extracted text is contiguous source text, progressive/staged parser dispatch receives a span plus its source
authority rather than an anonymous copied string. The child parser sees the exact slice as its input while every
diagnostic can map through the span to original source coordinates. Derived text uses the ordered provenance form
from section 1. Parse-job ids, cache keys, cycle checks, cancellation, result/failure policy, and deterministic queue
order remain governed by ADRs `0014`/`0015`.

Passing a span grants no implicit path read, parser resolution, compilation, execution, source-detail elevation, or
policy elevation. The caller must already possess the source and an explicitly registered parser identity; normal
registry/capability ceilings still apply. Span-native dispatch is an authority-preserving data path, not a loader.

### 6. Lossless segmentation composes the existing gap owner

Stable named regex slots identify matches without positional magic. `@capture_gaps` remains owned exclusively by
ADR `0045` and `docs/tasks/INTER-MATCH-GAP-CAPTURE.md`; this program does not invent competing syntax or lifecycle
semantics. Its prefix, interstitial gaps, selected matches, and optional tail become exact spans over this algebra.
The enclosing repeated rule owns segmentation; target rules retain regex slots, intrinsic cursor policy, and
lifecycle behavior.

`FUTURE-PARITY-BACKLOG.14.5` may compose the committed gap contract and admit its typed projections, but changes to
gap syntax, prefix/tail/failure policy, legacy markers, or named-slot migration remain in the separate gap tree.

### 7. Safety failures are portable and statically detectable where possible

The neutral contract must assign exact diagnostics and mutation fixtures for at least:

- source mismatch, out-of-range position, reversed span, and invalid derived provenance;
- unknown, stale, cross-invocation, or invalidated mark/transaction token;
- transaction nesting/escape, double commit/rollback, effect before commit, and cross-rule/source restore;
- cursor regression outside an explicit valid transaction or compatibility rewind;
- nullable repetition, non-progressing direct/mutual recursion, and staged-dispatch cycles;
- unavailable recursive entry/match/exit boundary;
- ambiguous or stale positional regex-slot reference where a stable named identity is required; and
- span-native parser invocation that exceeds source, parser-registry, capability, or policy authority.

Compile-time analysis should reject structural facts it can prove. Runtime guards remain mandatory for dynamic
paths. Diagnostics carry rule/invocation role, source identity, relevant positions/spans, transaction/progress
phase, and the originating edge/job without leaking source text above the active source-detail ceiling.

### 8. Contract and rollout precede syntax or behavior

No source spelling is selected by this decision. `Position`, `Span`, and transaction verbs are architectural names,
not promised helper identifiers. `FUTURE-PARITY-BACKLOG.14.1` must first define the versioned neutral schema,
fixtures, coordinate/provenance conversions, state machine, diagnostics, mutations, and current-helper projection.
Later leaves implement and admit Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT independently, then recompose recurring
and public no-drift proof. Generated/emitted/reconstructed/descriptor/trace/semantic projections change only in
explicitly owned descendant leaves if the neutral contract proves they need a new version.

### 9. Freeze the runtime value and compatibility-projection boundary

`FUTURE-PARITY-BACKLOG.14.2.0` fixes the implementation boundary before any backend behavior moves.

Each runtime has one source authority that owns the mapping from an opaque, caller-authorized source identity to
the immutable decoded input. The value graph does not own that text:

- a position is only source identity plus a zero-based Unicode-scalar offset;
- a direct span is only source identity, scalar start/end offsets, and one provenance label; and
- derived text is policy `concatenate_in_order` plus an immutable ordered sequence of direct spans.

The source authority is the sole owner of bounds/source/order validation, one-based line/column and UTF-8 byte
derivation, direct slicing, and explicit derived-text materialization. Positions and spans never embed copied
text, paths, match objects, mutable parser state, or host-language references. This separation prevents a value
from becoming ambient read authority and lets several immutable values share one decoded source safely.

Backends retain their proven internal indexing units: Perl decoded-string registers use scalar offsets; Rust and
Lua use UTF-8 byte offsets; Dart and Julia use host code-unit offsets. Exact conversion occurs at the typed-value
boundary. Replacing every live cursor register with scalar offsets would add churn without improving the portable
contract; exposing those host units would violate it.

The current 92 canonical source-boundary helpers and seven callable aliases project through this algebra but keep
their existing external values and mutation behavior. Text helpers still return text, length/offset helpers return
numbers, location helpers return one-based line/column, capture-group helpers retain their current collection and
absence shapes, and cursor controls retain their statement/compatibility results. Anonymous-boundary and mark
writes create positions internally without changing rule-local scope or update timing. `save_cursor` and
`restore_cursor` remain compatibility controls; they do not pre-admit the transaction state machine in section 3.

Only four diagnostics are owned by the immutable-value slice: `source_location_source_mismatch`,
`source_location_position_out_of_range`, `source_location_reversed_span`, and
`source_location_invalid_derived_provenance`. Mark lifetime, transaction, recursion/progress, gap, and span-dispatch
diagnostics remain owned by `.14.3-.7`; implementation must not claim them early.

The native value modules are backend runtime-support surfaces used by engine code and exact conformance tests.
They do not select authored DSL spellings or promise top-level facade methods named `Position` or `Span`. Input
source identity is also distinct from the existing generated-spec artifact identity used by generated/emitted
trace families. Descriptor schemas, generated-family identity, semantic/MCP responses, parse-result shapes, and
span-native parser dispatch remain unchanged in `.14.2` unless a separately owned descendant first proves that a
version change is required.

Implementation is ordered Perl, Rust, Dart, Julia, then shared Lua on PUC Lua and LuaJIT. Every backend first lands
an exact failing neutral consumer, then its immutable core, then compatibility projections, and only then a
composed admission that binds the consumer and promotes that backend's live rollout row. Native and unchanged
loaded generated/serialized/emitted plans converge on the same interpreter routes; admission is not inferred from
one execution carrier. A final repository-routed recurring driver composes all six runtimes before `.14.2`
closeout, while `.14.8` retains final program-wide examples, tooling, and no-drift ownership.

## Consequences

- Cursor control, capture, recursion, segmentation, and parser composition share one precise model instead of
  accumulating pairwise helper semantics.
- Immutable spans make exact text extraction cheap, provenance-preserving, and safe to pass between parser stages.
- Explicit cursor transactions add controlled local speculation without converting LinkedSpec into a packrat,
  PEG backtracking, GLL, or general search-tree parser and without pretending arbitrary side effects can roll back.
- Progress becomes a portable contract rather than a backend timeout/stack-overflow convention.
- Current helper APIs and rule-local cursor semantics remain valid; migration can be gradual and mechanically
  checked.
- Lossless gap capture gains the common typed representation it anticipated while retaining its separate owner.
- This decision changes no grammar, helper, parser/compiler/runtime, descriptor, generated format, semantic/MCP
  response, primary CLI, rollout, admission, or current public feature-completeness claim.
- The `.14.2.0` planning amendment changes no behavior itself; its exact backend module/test seams and rollout
  correction are durable in the owning task-tree and Knowledge card.

## Links

- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.14.0.1`, follow-ons `.14.1-.8`)
- Structural/progressive/staged base: ADR `0012`
- Parse-job and registry contracts: ADRs `0014`, `0015`
- Rule-local cursor ownership: ADR `0044`
- Lossless inter-match segmentation: ADR `0045` and `docs/tasks/INTER-MATCH-GAP-CAPTURE.md`
- Current capture/mark taxonomy: `docs/knowledge/spec-capture-mark-family-taxonomy.md`
- Forward-moving execution record: `docs/tasks/PHASE3-EXECUTION-SEMANTICS.md`
