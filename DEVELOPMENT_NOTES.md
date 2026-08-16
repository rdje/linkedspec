# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`

- 2026-08-16 (`INTER-MATCH-GAP-CAPTURE.6.5` — exact shared Lua admission): activation base is clean atomic 250
  at `798aeeee`; advancing the contract to 7/2/60 before its checker produces the intended count-drift RED.
- Compose authorities; do not add another path. The ninth role invokes unchanged `linkedspec.run_primary_cli`
  with a four-item heterogeneous-separator source and compares exact items plus prefix/interstitial gap text.
- Treat the neutral nine-role array as executable order. Require exact equality, unique map coverage, once-only
  completion, and final-set equality; one shared source must pass unchanged on PUC Lua and LuaJIT.
- Register the permanent consumer exactly once in `lua/test/run.lua`, explicitly once per ABI in canonical CI,
  and once each in rooted PUC-Lua/LuaJIT order. Checker mutations lock identity, role map, primary use, every
  registration and multiplicity, rooted order, later public ownership, and facade absence.
- Only the two Lua runtime rows move: append `puc_lua_runtime_regression` and `luajit_runtime_regression`, yielding
  7 complete / 2 pending / 60 semantic mutations and sixteen Lua admission mutations. Recurring/public rows and
  outward surfaces remain `.7`-owned.
- Focused proof is explicit 392 assertions per ABI (178 metadata + 33 native + 46 carrier + 105 emitted + 30
  admission), ordinary Lua 178 per ABI, primary 66x2, corpus 105, storage 19/three modules, and rooted neutral /
  Perl 124 / Rust 1 / Dart 5 / Julia 319 / PUC Lua 392 / LuaJIT 392. This admission/parent closeout requires the
  exact staged canonical receipt before atomic 251 lands.

- 2026-08-16 (`INTER-MATCH-GAP-CAPTURE.6.4` — shared Lua independently emitted proof): activation base is clean
  atomic 249 at `b7708cde`; adding the permanent workspace owner before updating the oracle yields the exact
  planned RED at 18→19.
- Do not add an emitted execution engine. `emit_lua_source_v2` already embeds normalized `SpecFile` JSON and
  reconstructs the shared compiler/interpreter; emit ten value and two typed-error modules unchanged, then load
  each module independently in a fresh child for the selected ABI.
- Compare emitted direct/traced results against native authority, including exact plans and generated trace/source
  identity. The value matrix spans Unicode/empty gaps, falsey values, child cursors, nesting, rollback, lifecycle,
  tails, minimum failure, direct entry, and legacy behavior; typed cases preserve unavailable/regression details.
- Trace files belong to the emitted workspace. Consume their bytes inside the fresh child before recursive cleanup,
  return those bytes in the child JSON envelope, and compare them in the parent only after the workspace is gone.
- Route module, runner, manifest, stdout/stderr, and traces below repository-managed `TMPDIR`. Register only the
  permanent consumer as owner 19; the three PUC-Lua/LuaJIT native modules and every cleanup guard remain exact.
- Focused proof is explicit 362 assertions per ABI (178 metadata + 33 native + 46 carrier + 105 emitted), complete
  Lua 177 per ABI, root 106, cursor 912, primary 66x2, corpus 105, storage 19/three modules, rooted dormancy, and
  unchanged recognition/duplicate/typed/generated ledgers. Primary admission and rollout remain `.6.5`-owned.

- 2026-08-16 (`INTER-MATCH-GAP-CAPTURE.6.3` — shared Lua normalized/descriptor/generated carrier): activation base
  is clean atomic 248 at `4e625a9f`; the explicit carrier RED passes reconstruction and stops at missing descriptor
  `regex_slots` before production movement.
- Keep the carrier singular. `SpecFile` normalized JSON already retains source, slot, selector, directive, action,
  and lifecycle metadata; reconstruct and compile it normally. Generated-v2 execution must spend that same
  compiled interpreter/recognition state, never copy gap state into plan rows or create an executor fork.
- Keep descriptor meanings separate. Add only detached `meta.regex_slots`, nullable `meta.capture_gaps`, and
  five-field `meta.resolved_slot_edges`; leave legacy action-edge projections, `meta.resolved_edges`, and
  `{label,idx}` dependency refs byte/shape compatible. Reproject on every call so consumer mutation cannot alias
  compiled state.
- Once regex-slot provenance enters descriptors, loaded and inline descriptors intentionally differ in logical
  `source_id`. Dependent equality tests must assert that distinction, normalize only a detached source field for
  structural comparison, and never erase provenance from production descriptors or replace it with a host path.
- No generated production change is needed: format 2, `linkedspec-generated-source-v2`, and ordered
  `{label,family}` rows already validate and dispatch through the shared runtime. Direct/traced generated failures
  wrap the same typed native details with exact generated stage/code/source identity.
- Focused proof is explicit 257 assertions per ABI, complete Lua 177 per ABI, root routes 106, cursor descriptors
  912, primary 66x2, corpus 105, storage 18/three modules, neutral/rooted dormancy, and unchanged cross-runtime
  ledgers. Emitted/storage, primary admission, rollout, and outward surfaces remain `.6.4-.6.5`-owned.
- Required rollover publishes immutable segment 4994. The doctrine correctly rejects the old 13-file/12-manifest-
  row ceiling; ADR `0077` advances only those finite controls to 14/13 and requires exact canonical proof.

- 2026-08-16 (`INTER-MATCH-GAP-CAPTURE.6.2` — shared Lua private native execution): activation base is clean
  atomic 247 at `a94c81ed`; one recognition/interpreter implementation serves PUC Lua and LuaJIT.
- Extend `recognition_transaction_runtime.lua` rather than the detached recognition state. Invocation frames own
  capture activation, entry-slot identity, committed gap cursor, accepted count, phase, and current candidate or
  tail; existing checkpoints copy and restore those mutable members alongside the unchanged cursor/boundary/marks
  token. Nested frames hide parent candidates and naturally restore them on return.
- Preserve the old event clock. Only capture-enabled repeated/default rules preselect through the existing
  alternation authority before `LS`; action, selected child, and `LE` see the live candidate; post-child cursor is
  committed before `IT`; successful terminal tails exist before `LX`, `EX`, or `E`. Legacy rule-slot events still
  execute after action/target and before `LE`.
- Keep the accessors private. `entry_slot`, `gap_span`, `gap_text`, and `gap_kind` are recognized by ordinary call
  dispatch but remain outside `CURRENT_CALL_NAMES`, so the governed shared inventory stays exactly 246 and the
  facade remains unchanged. Exact zero arity and typed context/cursor failures share one runtime authority.
- Do not spend new top-level locals in `interpreter.lua` casually. PUC Lua's chunk compilation rejected the first
  implementation at its local-variable ceiling; moving the new semantic-slot and candidate-preparation helpers
  onto the internal module table restored Lua-5.1 compatibility without exporting them through `linkedspec`.
- Focused proof is explicit 211 assertions per ABI, including 33 native cases, plus complete Lua 177 per ABI,
  primary 66, corpus 105, storage 18/three modules, neutral/rooted dormancy, and recognition 137/246/58. Normalized
  reconstruction, descriptors, generated/emitted proof, primary admission, rollout, and outward surfaces remain
  `.6.3-.6.5`-owned.

- 2026-08-16 (`INTER-MATCH-GAP-CAPTURE.6.1` — shared Lua authored/static/compiled metadata): activation base is
  clean atomic 246 at `5089a360`; one implementation is consumed by PUC Lua and LuaJIT.
- Keep source provenance logical and path-opaque. `SpecFile.source_id` defaults to `inline`, crosses direct and
  both staged parser paths, survives normalized/effective-emitted reconstruction, retains a relative caller path,
  and reduces absolute requests to basenames. Never persist the resolved host path as DSL provenance.
- Parse selector authorship before resolution. `EdgeTarget`/`BareEdgeTarget` retain `selector_kind` and
  `authored_selector`; validation resolves named targets against one mixed named/anonymous authored sequence;
  compilation records target rule, resolved child index, and nullable stable slot name without widening legacy
  dependency refs.
- Reuse the generated Unicode-17 rule-label scanner for slot names. Reject all-ASCII digits as the numeric
  selector namespace, reject invalid XID strings and duplicates with first-line evidence, and preserve exact
  case/normalization identity.
- Keep `@capture_gaps` out of `rule_slot_events`. Its dedicated AST kind is placement-insensitive; validation owns
  duplicate/conflict/eligibility evidence. Named `@mark(...)` stays independent, while anonymous legacy markers
  conflict. Existing split/mark events keep post-action/pre-`LE` timing.
- Separate compiled and descriptor evolution. Compiled JSON owns `regex_slots`, nullable `capture_gaps`, and
  five-field selector provenance now; descriptor action edges deliberately call the legacy projector until `.6.3`
  adds separate detached fields. Generated format 2 and `{label,family}` rows do not change.
- A dormant test must not become a new temporary owner. The first fixture used routed scratch correctly but moved
  the exact storage census 18→19 before `.6.4`; replacing it with read-only loading of a tracked spec proves
  relative/absolute identity while retaining 18 owners and reserving the planned owner transition.
- Focused proof is explicit 178 assertions per ABI, complete Lua 177 per ABI plus primary 66/corpus 105/storage
  18/three modules, rooted neutral/Perl/Rust/Dart/Julia plus two Lua skips, and unchanged recognition,
  duplicate-slot, typed-source, and generated-source ledgers. Live state/accessors remain `.6.2`.

- 2026-08-16 (`INTER-MATCH-GAP-CAPTURE.6.0` — shared Lua behavior-free plan): activation base is clean atomic 245
  at `a6ff2614`; complete PUC-Lua/LuaJIT baseline is 177 package tests per ABI, primary 66, corpus 105, and exact
  storage 18 owners / three dual-ABI native modules.
- Do not implement `@capture_gaps` as `rule_slot_events`. Those existing events belong to the preceding regex and
  run after accepted action/target execution before `LE`; retiming them would change legacy behavior and still
  would not expose the candidate during `LS`. Add a dedicated rule directive and capture-only preselection seam.
- Extend `recognition_transaction_runtime.lua` rather than adding state. The existing invocation frame owns
  activation, source/invocation/entry identity, committed gap cursor, accepted count, and current gap; the existing
  token snapshot restores mutable gap members. Detached cursor/boundary/marks state stays exact.
- Keep normalized `SpecFile` JSON as the only reconstruction/emission carrier. Add defaulted logical `source_id`,
  preserve caller-logical loaded identity, project runtime UTF-8 byte offsets only through immutable input
  `SourceAuthority`, and preserve format-2 `{label,family}` generated plans.
- Keep descriptor meanings separate: add fresh detached `regex_slots`, `capture_gaps`, and five-field
  `resolved_slot_edges`; do not widen legacy `resolved_edges` or `{label,idx}` dependency references.
- Emitted proof uses unchanged `emit_lua_source_v2`, ten value/two typed-error modules, and fresh PUC-Lua/LuaJIT
  children below repository-routed `TMPDIR`; this advances only the exact temporary-owner oracle 18→19.
- Final `.6.5` executes the same nine-role consumer once per ABI in ordinary/canonical/rooted routes. Only the two
  Lua rows advance 5/4/58→7/2/60; ten dormancy mutations become sixteen admission mutations. Public/outward state
  remains owned by `.7`.

- 2026-08-16 (`INTER-MATCH-GAP-CAPTURE.5.5` — Julia primary and exact private admission): activation base is
  clean atomic 244 at `0a961043`; checker-first proof rejects the prior 57-mutation boundary before admission.
- Admission composes existing authorities. Keep `run_cli`, normalized `SpecFile`, descriptor projection,
  generated-v2 execution, emitted-source loading, recognition invocation/token state, and portable diagnostics;
  do not add a command, option, format field, plan field, or parallel runtime path.
- Treat the neutral consumer role array as executable order. Require exact equality with the nine expected roles,
  unique declarations, exact map identity, once-only completion, and final set equality; invoke the map only by
  iterating the declared array.
- The heterogeneous-separator primary fixture is the compact user contract: `[a-z]+` recognizes only the four
  items, while capture state independently returns empty prefix, comma-space, pipe-space, and newline-bullet
  gaps. This locks recognition and source preservation as separate concerns.
- Registration is multiplicity-sensitive. Include once in `julia/test/runtests.jl`, execute once explicitly in
  canonical CI, and execute once after Dart in the rooted route. Preserve exact PUC-Lua and LuaJIT skips.
- Only Julia rollout authority moves. Append solely `julia_runtime_regression` as mutation 58 and replace the ten
  dormancy mutations with consumer/ledger/ordinary/primary/canonical/recurring/later-skip/facade admission
  guards. Rust and Dart admission mutation identities remain intact.
- Focused signoff passes explicit and ordinary 105+33+46+105+30, complete Julia/primary/storage 20/5/corpus 105,
  rooted neutral/Perl/Rust/Dart/Julia plus two Lua skips, all exact dependent ledgers, book 79/14,884, Knowledge
  838/7,076, histories, and doctrines. Exact staged canonical CI remains the receipt-bound admission proof.
- Two stale storage sentences were corrected from historical 17/18 counts to the already-measured 20-owner
  authority; the oracle itself and storage ownership did not change in this leaf.

- 2026-08-16 (`INTER-MATCH-GAP-CAPTURE.5.4` — Julia independently emitted gap proof): activation base is clean
  atomic 243 at `1f531a5f`; registering the first `mktempdir()` in the dormant consumer deliberately produces the
  exact storage-owner RED at 19→20 before the sorted inventory advances.
- Reuse `emit_julia_source_v2` unchanged. One caller-owned offline host is enough for twelve independent modules
  when each generated parser is included into a distinct fresh `Module`; use `Base.invokelatest` across that
  world-age boundary for plan, direct, and traced functions.
- Native authority is computed before emission from the same compiled spec. The child process receives normalized
  expected values/plans, asserts both emitted routes internally, and returns JSON so the parent independently
  checks direct, traced, plan, trace identity, and typed generated-error projections.
- The emitted matrix is ten value modules—Unicode/falsey entry, empty spans, child cursor, nested isolation,
  rollback, lifecycle order, no-match tail, failed minimum, direct entry, legacy—and two typed-error modules for
  unavailable context and cursor regression. Every module has a unique logical generated source identity.
- Layer the host-private writable depot before the already-routed retained repository/system stack; keep
  `JULIA_PKG_OFFLINE=true` and `--compiled-modules=no`. Modules, runner, manifest, depot, and traces all live below
  the single routed `mktempdir()` owner and disappear in a `finally` cleanup.
- Focused signoff is 105 metadata + 33 native + 46 carrier + 105 emitted, complete Julia/primary/storage 20/5/
  corpus 105, neutral/rooted 4/5/57, duplicate-slot 7/0/59, recognition 137/246/58, typed-source 9/5/114,
  generated/capability/language ledgers, book 79/14,880, Knowledge 838/7,076, bounded histories, and nine doctrines.
  Admission `.5.5` remains canonical; this leaf changes no emitter, plan, primary, rollout, or outward surface.

- 2026-08-16 (`INTER-MATCH-GAP-CAPTURE.5.3` — Julia normalized/descriptor/generated carrier): activation base is
  clean atomic 242 at `73484302`; the explicit carrier group passed reconstruction then reached exact missing
  descriptor keys `regex_slots`, `capture_gaps`, and `resolved_slot_edges` before production projection existed.
- Reconstruct only from `to_json(SpecFile)` through `from_json`, then compile normally. Do not introduce a second
  serialized runtime carrier or copy gap metadata into the static generated plan.
- Descriptor meanings stay separated. `regex_slots`, nullable `capture_gaps`, and five-field
  `resolved_slot_edges` are fresh detached authored/resolved provenance; legacy `resolved_edges` remains the
  execution-semantic row and dependency references remain `{label,idx}`.
- Logical source provenance is observable descriptor data. Inline parsing truthfully yields `inline`; loaded
  requests yield their caller-logical basename. Direct-dependent equality tests may rewrite only the expected
  source ids, never erase that distinction or normalize all descriptors to host paths.
- Exact descriptor key-set consumers must advance with compatible additive projections. Complete Julia proof
  caught the stale cursor descriptor inventory, which now requires and value-checks all three fields across every
  rule family. Root-route and cursor-route loaded comparisons preserve every other byte/value unchanged.
- Generated-v2 direct/traced entrypoints already spend `CompiledSpec` plus the ordinary runtime. Keep format 2 and
  ordered `{label,family}` rows unchanged; prove values, lifecycle, nesting, recursion, rollback, typed failure detail, and
  generated source identity at the wrapper boundary.
- Focused signoff is explicit 105 metadata + 33 native + 46 carrier, complete Julia package, the 917-assertion
  cursor descriptor dependent, primary/storage 19/5, neutral/rooted 4/5/57, duplicate-slot 7/0/59, recognition
  137/246/58, typed-source 9/5/114, rendered book 79/14,880, Knowledge 838/7,075, bounded histories, and all nine doctrines.
  Emitted proof and admission remain `.5.4-.5.5`, so canonical CI is not triggered.

- 2026-08-15 (`INTER-MATCH-GAP-CAPTURE.5.2` — Julia private native gap execution): activation base is clean
  atomic 241 at `3a620ec0`; the explicit native group first reaches exact unsupported helper `gap_kind`.
- Put gap state on `_InvocationState` and its existing transaction snapshot. Capture activation, input/invocation
  identity, entry slot, committed cursor/count/current context, rollback, and nesting belong there; observed
  `RecognitionFrameState` remains the exact detached cursor/boundary/marks projection.
- Only flagged rules may preselect before `LS`. Candidate visibility spans action, child entry, and `LE`; commit
  uses the child-extended post-`LE` cursor before `IT`. Successful minimum installs a terminal tail before the
  existing `LX`/`EX`/`E` routes. Failed minimum and whole-rule unwind commit neither match nor synthetic tail.
- Entry identity is a detached five-field record. Runtime registers remain zero-based UTF-8 code units, and the
  existing immutable input `SourceAuthority` is the only bridge to detached Unicode-scalar spans and exact text.
- `entry_slot`, `gap_span`, `gap_text`, and `gap_kind` are resolver-private zero-argument runtime calls. Do not put
  them in `_SUPPORTED_ACTION_IR_CALL_NAMES`: the duplicate-slot matrix caught that widening because Dart/Julia
  supported inventories stopped agreeing. The separate `inter_match_gap` family preserves exact inventory 246.
- Exact diagnostics remain structured runtime envelopes: unavailable context uses stage `access_gap_context` and
  code `gap_capture_context_unavailable`; cursor regression uses stage `advance_gap_context` and code
  `source_location_cursor_regression`. All four helpers reject nonzero arity before runtime access.
- Focused signoff is explicit 105 metadata + 33 native, complete Julia package/primary/storage 19/5/corpus,
  neutral/rooted 4/5/57, duplicate-slot 7/0/59, recognition 137/246/58, typed-source 9/5/114, rendered book
  79/14,872, Knowledge 838/7,072, bounded histories, and all nine doctrines. Reconstruction/generated/emitted/primary admission,
  rollout, and outward surfaces remain `.5.3-.5.5`-owned, so canonical CI is not triggered.

- 2026-08-15 (`INTER-MATCH-GAP-CAPTURE.5.1` — Julia authored/static/compiled metadata): activation base is clean
  atomic 240 at `12a14ed0`. The permanent consumer is explicit-only; the neutral checker mutation-locks its
  identity, metadata role, contract source, parse/validate/compile seams, diagnostic token, discovery/rooted
  absence, and facade absence.
- Keep authored selector identity separate from resolved execution identity. `EdgeTarget` owns
  `selector_kind`/`authored_selector`; compilation resolves exact target index and nullable slot name once.
  Compiled JSON owns the new rows, while descriptor serialization deliberately calls the legacy edge projector.
- Named regex declarations reuse the generated pinned Unicode-17 rule-label classifier. Anonymous and named rows
  share one zero-based order; ASCII-digit-only names remain reserved for numeric brackets, and duplicate regex
  text never substitutes for stable slot identity.
- Validate slot declarations before generic raw syntax, selectors before directive eligibility, and flagged
  directive eligibility before generic mixed-edge rejection. Unflagged legacy diagnostics retain their prior
  route; flagged rules receive exact ownership/mode evidence, and named `@mark(...)` remains independent.
- `SpecFile.source_id` is logical provenance, never resolved host authority. Preserve it through every parser/
  stitching copy. Relative loaded requests retain caller spelling; absolute requests reduce to basename. The
  complete Julia suite caught the first implementation leaking scratch paths into `to_json(compiled)`.
- Do not claim emitted workspace ownership early. The dormant metadata consumer proves loaded parsing by invoking
  the production `_parse_loaded_spec` boundary over an in-memory `LoadedSpec`, so storage remains exactly 19
  owners / 5 packages; `.5.4` still exclusively owns 19→20.
- The implementation changes no recognition invocation, runtime matcher/interpreter, accessor dispatch,
  descriptor metadata, generated plan, emitter API, primary command, rollout, dependency, or facade. `.5.2-.5.5`
  retain those boundaries in dependency order.
- The mdBook audit repaired two stale Dart metadata-only sentences left after `.4.5`; current teaching now clearly
  distinguishes admitted Perl/Rust/Dart behavior from dormant Julia metadata.
- Focused signoff is explicit metadata 105, direct dependents 624, full Julia package plus primary/storage 19/5/
  corpus 105, rooted neutral/Perl/Rust/Dart with three skips, duplicate-slot 7/0/59, recognition 137/246/58,
  typed-source 9/5/114, book 79/14,868, Knowledge 838/7,071, bounded histories, and all nine doctrines. ADR `0076`
  authorizes only the required 18th change-history member / 17th manifest row; aggregate ceilings do not move.

- 2026-08-15 (`INTER-MATCH-GAP-CAPTURE.5.0` — behavior-free Julia gap plan): activation is clean atomic 239
  `43ed1c8f`; the only pre-audit edit was the owning task-tree leaf, and no production/test behavior moves.
- Process probes are decisive: numeric `Item[1]` parses/compiles; `name=/a/`, `Item[name]`, and `@capture_gaps`
  remain raw invalid body syntax. `entry_slot`, `gap_span`, `gap_text`, and `gap_kind` parse as action calls and
  fail through the existing structured unknown-helper envelope. Legacy `@move_pos` parses as a split marker but
  is ignored by compilation/runtime. The primary adapter rejects the complete future source at compilation.
- A repeated-OR trace runs enclosing `LS` before candidate selection. Preserve that order for unflagged rules;
  capture-enabled rules alone preselect/install before `LS`, retain through target/`LE`, commit accepted post-`LE`
  cursor before `IT`, and install successful tails before existing `LX`/`EX`/`E`.
- Extend the existing private recognition invocation/token; do not widen detached `RecognitionFrameState` or add
  a parallel cursor/stack. Token rollback owns mutable gap cursor/count/current state. Runtime registers remain
  zero-based UTF-8 code units and cross the current immutable input `SourceAuthority` only at scalar projection.
- `.5.1` owns logical source, Unicode-17 declarations, selector/directive/static/compiled provenance, diagnostics,
  and a permanent dormant consumer. `.5.2` owns native state/accessors. `.5.3` owns normalized reconstruction,
  compatible descriptor additions, and unchanged-v2 generated execution. `.5.4` owns one repository-routed
  emitted host with ten value/two typed-error modules and exact storage 19→20. `.5.5` alone owns primary,
  nine-role admission, Julia 5/4/58 promotion, registration, and parent closeout.
- Focused baseline is duplicate slot 121, cursor 104, recognition 207, typed source 127, and source emitter 65 =
  624 assertions, plus existing primary process conformance and storage 19 owners / 5 packages. Gap remains
  neutral/Perl/Rust/Dart plus three skips at 4/5/57; outward and generated-format surfaces remain unchanged.
- README pressure correctly rejected the first 663-line ADR projection against its 640-line cap. Compress the
  adjacent Dart/Julia planning amendments into decision-sized pointers to their canonical Knowledge/task owners;
  ADR `0045` returns to exact 640 lines and all nine doctrines pass without losing implementation detail.
