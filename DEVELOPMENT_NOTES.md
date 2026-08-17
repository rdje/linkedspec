# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`

- 2026-08-17 (`FUTURE-PARITY-BACKLOG.14.6.3.3` — Rust progressive admission): exact clean activation is carrier
  atomic 266 `eecacead`; this leaf changes canonical trust/governance only.
- The consumer retains file-level `cfg(linkedspec_progressive_span_dispatch_red)`. Canonical CI supplies that cfg
  on one exact Cargo command; the ordinary target therefore continues to prove zero-test dormancy without a
  second test identity or unconditional discovery route.
- `tools/run_ci_local.sh` now requires the exact tracked test path, emits one exact Rust admission marker, and runs
  one cfg-enabled `--test progressive_span_dispatch_contract` command immediately after the neutral checker and
  admitted Perl consumer.
- The neutral checker binds the tracked requirement, marker, invocation, cfg, nine carrier files, Rust rollout
  path, and unchanged pending/outward boundaries. Four added mutations cover discovery, marker, invocation, and
  Rust rollout regression, raising governance from 91 to 95.
- The Rust consumer changes only contract/admission snapshots and its canonical-route assertion; its fixture,
  authority setup, exact static failures, staged-registry denial, serialization checks, and four carrier
  executions stay unchanged. The cfg-enabled focused test passes 1/1 in 141.85 seconds; ordinary discovery is 0/0.
- The admitted Perl consumer advances only its shared neutral snapshots and Rust path assertion, passing 126/126.
  No Perl behavior, ActionIR node, recognition count, generated format, or rollout identity moves.
- The resulting boundary is neutral + Perl + Rust 3/9 complete, with Dart/Julia/Lua, recurring, typed progressive,
  and public no-drift pending; public calls/facades/schemas/semantic/MCP/CLI/README stay guarded.
- Focused direct dependents, mdBook, Knowledge Map, bounded histories, task/index, memory, all nine doctrines, and
  the exact staged receipt-bound canonical local gate pass before landing atomic 267.

- 2026-08-17 (`FUTURE-PARITY-BACKLOG.14.6.3.2` — dormant Rust progressive carriers): exact clean activation is
  private-authority atomic 265 `58d39fe5`; `.3.3` remains the sole admission/rollout owner.
- `Expr::ProgressiveDispatchSpan` is an exclusive statement node, not a helper call. Its serialized fields are only
  `target`, `parser_id`, `top_rule`, and `span`; direct parser/top literals and the bare span operand are normalized
  before construction. The compiler rejects any generic `dispatch_span` that escapes that statement topology.
- Progressive parse errors join the existing fail-closed ActionIR prefixes so malformed reserved syntax cannot be
  downgraded to an omitted lifecycle block. The exact five static operand diagnostics stay aligned with Perl.
- Recognition compiler facts now propagate `parser_registry_or_staged_dispatch` through static rule/function call
  graphs and reject a `recognize_once` target that can reach progressive dispatch. `RecognitionRuntime` separately
  reports any live token, protecting reconstructed/precompiled inputs that bypass compilation.
- `ProgressiveInvocation` owns a cloned immutable registry rather than borrowing it. This permits an opaque
  `ProgressiveExecutionSeed` to hold the host recipe and create one fresh invocation at each Engine execution.
  `RuntimeContext` clones share its mutex-backed invocation, so budget, total calls, and cancellation never fork.
- `ExecutionOptions::with_bounded_child_parse_authority` is doc-hidden host plumbing. Native and generated-value
  contexts install the seed before entering the rule. Node evaluation reads the bare direct-span value, checks live
  transaction state, delegates to the authority, converts detached JSON back to the runtime value, and binds target.
- Generated-v2 requires no format change: the existing compiled-spec JSON carrier serializes the new logical node,
  and emitted modules already expose `execute_with_options`. The independent Cargo fixture supplies host authority
  in its main module, while the emitted parser source contains no callback or mutable/live authority.
- The neutral checker removes Rust from pending-backend denial and instead locks nine private carrier paths plus
  exact consumer/cfg/canonical absence. Counts are now 3 pending groups/11 paths, 9 Rust carrier paths, 10 outward
  guards, 26 diagnostics, 2/9 rollout, and 91 mutations. Rust rollout intentionally remains pending.
- The first receipt-bound gate exposed the admitted Perl consumer's stale frozen view of that neutral metadata.
  Updating its status, availability, Rust-carrier count, guard counts, and mutation count restores 125/125 while
  leaving every Perl execution assertion and the neutral rollout rows unchanged.

- 2026-08-17 (`FUTURE-PARITY-BACKLOG.14.6.3.1` — private Rust progressive authority): exact clean activation is
  dormant-RED atomic 264 `511865bc`; the leaf adds authority/core plus one dormant focused consumer only.
- `bounded_child_parse_authority.rs` deliberately depends on the existing `SourceAuthority`, not Engine or ActionIR.
  `#[doc(hidden)] pub mod` matches the private integration-test seam already used by recognition transactions;
  no facade, descriptor, schema, generated-v2 format, CLI, README, or shared helper inventory moves.
- Registry construction validates and owns logical ids, content fingerprints, allowed top rules, capabilities,
  and ceilings once. `register` and `load` are typed denials. Entries contain compiled callbacks, never paths,
  providers, loaders, compilers, mutable registries, source text, or invocation state.
- Each invocation creates one typed source authority from caller-owned decoded snapshots and carries the sole
  source identity, cancellation-token identity, monotonic deadline, remaining steps, active chain, depth bound,
  and total-call bound. A child token must be the same `Arc` authority; it cannot merely copy a token spelling.
- Dispatch validates exact dynamic literal/string and four-field span inputs before lookup. Effective capabilities
  and policies intersect; source-detail and numeric ceilings take minima; cost is charged before the child; both
  pre- and post-child cancellation/deadline safe points run; nested calls share budget and call count.
- `ProgressiveSourceView` exposes bounded decoded text and maps local scalar boundaries, typed positions/spans,
  and diagnostic offsets to the original source. Every clone shares one invalidation bit and becomes unusable as
  soon as its callback returns, errors, or panics.
- Child output crosses only owned `serde_json::Value`. Recursive detachment enforces the effective node ceiling
  and rejects field names that look like live authority, handle, parser, registry, transaction, cancellation,
  path, source-text, or host state. JSON `false` is valid; JSON `null`, callback errors, and panics are failures.
- The outer-cfg authority target exercises the complete neutral matrix and all 26 required-context diagnostics,
  then proves nested decreasing dispatch, global rebasing, shared 20→15 budget and two calls, view expiry, seed
  mutation isolation, and ordinary/canonical absence. `.3.2` remains the sole carrier owner.
- The initial parallel Cargo check was diagnosed at a repository-local build lock with memory-stalled compiler
  children; exact duplicate waiters were stopped and the proof reran successfully with `--jobs 1`. macOS
  `sample` necessarily wrote one 958-byte OS diagnostic to `/tmp`; its exact file was immediately deleted and
  `test ! -e` proved no residue, so no off-volume project data remains.
- Final focused proof is authority 4/4, ordinary authority/final-path discovery 0/0, package check and format,
  staged registry 1/1, exact dormant RED at only `PROGRESSIVE_DISPATCH_SPAN`, progressive 2/9/86, typed
  11/3/152, recognition 138/250/58, generated strict Rust 105/105, capability 80/0/0, and language 250/126.

- 2026-08-17 (`FUTURE-PARITY-BACKLOG.14.6.3.0` — Rust progressive dormant RED): exact clean activation is Perl
  admission atomic 263 `78bc66e1`; this slice changes only one outer-cfg test plus durable plan/status surfaces.
- The real Rust parser accepts the reserved source but lowers it as `Expr::Call { name: "dispatch_span" }` under
  an ordinary scalar assignment. JSON reconstruction and emitted source preserve that same generic shape.
- Native, reconstructed, generated-plan, and separately compiled emitted execution all reach the generic
  unknown-helper fallback and return `null`. That consistency is carrier plumbing, not progressive behavior.
- The sole RED assertion requires serialized kind `progressive_dispatch_span` and names the neutral node
  `PROGRESSIVE_DISPATCH_SPAN`; every preceding registry/inventory/shape/execution assertion passes.
- File-level `cfg(linkedspec_progressive_span_dispatch_red)` makes ordinary Cargo execute zero tests. The target
  name is absent from `tools/run_ci_local.sh`, so only an explicit `RUSTFLAGS=--cfg ...` invocation activates RED.
- The independent emitted fixture lives under repository-derived `rust/target/test-workspaces` and shares the
  repository-local Cargo target, preserving same-volume project-data ownership and automatic teardown.
- `.14.6.3.1` owns immutable authority/core only, `.3.2` owns the dedicated node/four carriers, and `.3.3` owns
  CI routing plus Rust-only rollout. No later boundary is smuggled into the dormant proof.
- Focused truth remains progressive 2/9/86, typed 11/3/152, recognition 138/250/58, with no generated-format,
  dependency, production, other-backend, outward, storage, path, or doctrine movement.

- 2026-08-17 (`FUTURE-PARITY-BACKLOG.14.6.2.3` — private Perl progressive admission): exact clean activation is
  carrier atomic 262 `075cb7b8`; only the unchanged final-path consumer, Perl rollout row, and direct projections move.
- Canonical CI now requires and syntax-checks `t/progressive_span_dispatch_perl_contract.t`, emits one exact route
  marker, and runs `PERL5LIB= prove -Iperl t/progressive_span_dispatch_perl_contract.t` exactly once.
- Removing the Perl absence guard advances progressive truth from 1/9 to 2/9 while retaining Rust/Dart/Julia/Lua
  absence as four groups/14 paths. Typed progressive, recurrence, public no-drift, and ten outward guards do not move.
- Recognition's scanner must compose both `ActionIR/Contracts.pm` and the separately owned progressive contract
  module. `PROGRESSIVE_DISPATCH_SPAN` raises live nodes 133→134 and total rows 137→138 under rejected
  `parser_registry_or_staged_dispatch`; calls remain 250 and mutations remain 58.
- The first canonical attempt proved admitted consumers are mutable-neutral-metadata dependents: Rust failed only
  its 133-node snapshot while 11 behavior tests passed. Exhaustive review advances Rust, Dart, Julia, and shared
  Lua snapshots together to 134 current / 138 total before rerunning the exact gate.
- Do not remove `dispatch_span` from language coverage merely because Perl is admitted. The shared 250-name
  inventory asserts equal Dart/Julia/Lua helper support, whereas Perl progressive syntax is a dedicated intrinsic;
  the exact non-public classification remains until shared-backend recurrence proves reclassification safe.
- Recognition capability-guide governance globally forbids the historical phrase `neutral + Perl 2/9 complete`.
  Progressive prose initially collided with it despite describing a different contract; the exact progressive
  wording is now `2/9 complete (neutral and Perl)`, preserving the older stale-claim detector without weakening it.
- Change-history pressure crossed its 90% line threshold; the canonical rollover tool archives 244 clean-HEAD
  lines as immutable change segment 4993 and leaves the new admission record in the bounded hot shard.
- That exact segment exceeds only `change_history` file-count 19→20 and manifest-line 18→19 controls. ADR `0082`
  owns those finite increments; aggregate 55,000-line/4,194,304-byte and every member/root ceiling stay fixed.
- Focused proof is 193 authority/carrier/transaction assertions, 6 generated assertions, progressive 2/9/86,
  typed 11/3/152, recognition 138/250/58, generated strict Rust 105/105, capability 80/0/0, language 250/126,
  Knowledge 847/7,169, and a clean mdBook render; admission requires exact staged canonical receipt proof.

- 2026-08-17 (`FUTURE-PARITY-BACKLOG.14.6.2.2` — private Perl progressive carriers): clean activation is authority
  atomic 261 `e185b352`; the neutral contract, generated-v2 format, staged registry, CI routing, and rollout stay fixed.
- `LinkedSpec::ActionIR::ProgressiveSpanDispatch` owns the exact whole assignment and sets exclusive statement
  ownership so canonicalization drops lower-priority helper events for the same raw statement. The resulting node
  is exactly `PROGRESSIVE_DISPATCH_SPAN`, never a progressive node plus generic `ASSIGN` duplicate.
- Static policy decodes the first two operands as normalized literals, requires one bare span binding, and reports
  the portable identity/top/span diagnostics before any parser carrier exists. Malformed lowering is inert until
  the policy rejects the rule table.
- `LinkedSpec::ProgressiveSpanDispatchRuntime` accepts an exact host options record, starts one fresh core invocation
  over the current copied input, and stores it only in a localized private descriptor slot. Generated source keeps
  parser id/top rule/span/origin data but never embeds callbacks, registry/source/cancellation handles, or budgets.
- Live wrapper, `with_invocation` reconstructed descriptor, generated plan validation/execute, and a second fresh
  emitted package return the same detached result. Missing options preserve `progressive_registry_missing`.
- Recognition effect propagation rejects progressive children below `recognize_once`; the runtime authority also
  reports whether any invocation frame has a live token so core dispatch can fail defensively.
- Focused ActionIR proof found trace tests still asserting raw host truth text from before ADR `0043`. Their expected
  code/decision names now match the already-current typed eager `RuntimeLogical` implementation; no runtime change.
- Full language coverage initially treated private `dispatch_span` as public because its dedicated contract enters
  the independent Perl registry. The exact fifteenth non-public classification now holds language coverage at
  250 current / 105+1 occurrences / 126 public until `.2.3` removes the admission barrier.
- Capability conformance independently found its completed `.24.2` phrase missing from `docs/TASK_TREE.md`.
  Root cause matches the existing stable-marker fact: the only copy had lived in a mutable frontier summary. Both
  required closed-state phrases now live in the stable canonical marker section; capability returns 80/0/0 with
  24 governance and six public mutations, without capability or manifest movement.
- Phase 0's Compiler-laziness subtest found `ProgressiveSpanDispatchRuntime` statically importing
  `RecognitionTransactionRuntime`, which itself imports `LinkedRE`. The progressive runtime now resolves only the
  `transaction_active` callback on the dispatch path through `OwnerDispatch`; requiring the runtime or Compiler
  remains LinkedRE-lazy, while executed dispatch still receives the same defensive transaction visibility.
- Required rollover archived the oldest clean engineering-note suffix as immutable segment 4993. The resulting
  15-file collection / 14-line manifest remains at 23,142/27,000 lines and 2,481,129/3,145,728 bytes, but exceeded
  the prior finite count controls. ADR `0081` raises only max files 14→15 and manifest lines 13→14; every aggregate,
  per-member byte/line, owner, lifecycle, verifier, and storage authority remains unchanged. Because this and the
  language inventory classification move executable governance, ADR `0073` escalates `.2.2` to canonical proof.
- The pre-fix Phase 0 run passed 1,030/1,031 and failed only Compiler require-time LinkedRE laziness. After lazy
  transaction-runtime resolution, the complete rerun passes 1,031/1,031 in 769 seconds; receipt-bound canonical
  CI then validates the exact staged final candidate.
- The final consumer is 125/125 but deliberately unrouted. `.2.3` must independently admit it and promote only Perl.

- 2026-08-17 (`FUTURE-PARITY-BACKLOG.14.6.2.1` — private Perl progressive authority): clean activation is dormant-
  RED atomic 260 `191465f4`; this leaf deliberately does not touch ActionIR, wrappers, generated source, or rollout.
- `LinkedSpec::ProgressiveSpanDispatch` owns registry/invocation/view state behind opaque scalar objects. Registry
  input is validated, deep-copied, recursively locked, and keyed only by normalized logical identity. Runtime
  `register` and `load` always fail with their exact portable typed diagnostics.
- A fresh invocation copies decoded source text and owns the caller's cancellation token/check, absolute deadline,
  remaining step budget, maximum depth/calls, total calls, and active chain. Nested dispatch reuses that authority;
  repeated parser/top/source identity must be contained and strictly smaller.
- A callback-scoped `SourceView` exposes only bounded decoded text and rebases local positions, spans, and
  diagnostics to the original source's Unicode-scalar coordinates. It is invalid after callback return/failure.
- Callbacks receive no parent parser state. Undefined results become typed child failure; false remains valid;
  aggregates deep-copy; cycles, references, and live-looking authority keys fail detachment.
- Focused proof executes every neutral behavior/diagnostic case plus nested, mutation, expiry, rebase, cyclic, and
  detach adversaries. The final-path consumer remains intentionally 83/1 RED and unrouted until `.2.2-.3`.

- 2026-08-17 (`FUTURE-PARITY-BACKLOG.14.6.2.0` — dormant Perl progressive RED): clean activation is neutral
  atomic 259 `a0a33c32`; the final-path consumer is deliberately absent from all ordinary/canonical routes.
- The exact authored assignment reaches a descriptor. Current metadata has `ASSIGN`/`RETURN`, unresolved
  `dispatch_span`, no raw Perl dependency, no `PROGRESSIVE_DISPATCH_SPAN`, and language-agnostic readiness false.
- Generated-v2 retains the same one-marker/one-sentinel lowering and independently loads to a null result. The
  existing `StagedParserRegistry` rejects `expr-v1` at resolve, so progressive execution must not widen that
  copied-text function-body job adapter or inherit its legacy span shape.
- Use the existing second parser argument—the invocation-options hash—as the private host attachment seam. Both
  live and emitted wrappers already receive it immediately above descriptor execution. Enter a fresh progressive
  authority there; generated artifacts retain logical metadata only and never serialize registry/parser/source/
  cancellation/transaction handles. `.1` owns authority/core, `.2` carriers, and `.3` registration/promotion.
- Exact RED is 83 pass / 1 fail at the dedicated node. Production behavior, generated contract v2, all rollout
  rows, outward surfaces, and CI topology remain unchanged, so ADR `0073` keeps this leaf focused.

- 2026-08-17 (`FUTURE-PARITY-BACKLOG.14.6.1` — executable neutral progressive span dispatch): clean activation
  is corrective atomic 258 `27f9c87f`. Checker-first RED is exact `progressive span-dispatch contract is missing`.
- Reserve only private `value = dispatch_span("expr-v1", "Expr", span)`. The first two operands are normalized
  static literals naming one immutable pre-registered compiled parser and allowed top rule; the third is one bare
  local exact `{source_id,start,end,provenance}` direct span. The dedicated result is detached and failure-only.
- A bounded view uses local child registers but globally rebased typed positions, spans, and diagnostics. Effective
  capabilities/policy modes intersect; source-detail and numeric ceilings take minima; cancellation token,
  absolute deadline, and remaining budget propagate without reset or extension.
- Preserve all parent cursor, boundary, marks, variables, transactions, captures, and invocation state. Dispatch
  never establishes parent progress. Repeated parser/top/source identity must use a contained strictly smaller
  global span, and total depth/calls are bounded across changing identities.
- The neutral checker independently executes 2 registry entries, 2 sources/8 views, 6 authority, 6 cancellation,
  8 chain, and 4 execution cases; locks 26 diagnostics and 1/9 rollout; and rejects 86 corruptions.
- Current-boundary validation is executable rather than prose: typed `progressive_span_dispatch` stays pending;
  `parser_registry_or_staged_dispatch` remains rejected with empty current ActionIR/call rows; 17 implementation
  paths across five backend groups omit `dispatch_span` and `PROGRESSIVE_DISPATCH_SPAN`; and the Perl Toolbox
  probe retains `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER`. Ten outward facade/schema/semantic/MCP/CLI/README
  paths additionally reject private spelling, node, or rollout-token exposure.
- Canonical CI requires and runs both tracked artifact and checker. Its direct tool-storage dependent now freezes
  3 Python temporary owners / 14 shell allocators / 31 Python entrypoints. No backend, typed rollout, facade,
  descriptor, schema, semantic/MCP, CLI, README, loader, or staged-AST behavior moves; backend `.2-.6` must
  replace its own pending guard only through exact split RED, authority/core, carrier integration, and admission.

- 2026-08-17 (`FUTURE-PARITY-BACKLOG.14.6.0.1` — typed transaction-composition correction): clean activation is
  audit atomic 257 `1a6e0b1f`. Checker-first RED is exact `transaction-safety composition contract is missing`.
- The typed contract now cross-checks recognition contract/checker/driver identity, closed 9-allowed/11-rejected
  effects including uncommitted `parser_registry_or_staged_dispatch`, eight cursor-progress fixtures, five source
  groups/six runtime routes, 9/9/58 rollout, public 3/26/45, and capability-guide 1/14/18.
- Promote only pre-owned `transaction_safety` with exact Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT coverage. New static
  and in-memory document mutations make typed governance 11/3/152 and prevent obsolete two-runtime, pending-
  implementation, 10/4/126, or unstable observation-aggregate claims from returning.
- Existing recognition recurrence passes Perl 51, Rust 12, Dart, Julia 207, PUC Lua 246, LuaJIT 246, generated
  strict Rust 105/105, capability 80/0/0, and language 250/105+1/126. Book proof is 79 files / 15,004 KiB with
  inspected current HTML and removed output; no behavior, outward surface, CI topology, or storage owner changes.

- 2026-08-17 (`FUTURE-PARITY-BACKLOG.14.6.0` — progressive span-dispatch audit): clean activation is atomic 256
  `8880d1b6`. Committed staged registry blobs are Perl `09e5008e`, Rust `b9033595`, Dart `8eb8b7e1`, Julia
  `c6c7b10f`, and Lua `b128a9f8`; each implements only `actionir-body.spec` / `action_block`.
- ADR `0080` keeps loading outside recognition. Native loader APIs may resolve/read/compile before execution, but an active
  parser receives only an immutable logical registry entry for an already compiled parser. A typed span grants
  no filesystem, resolution, registry mutation, compilation, capability, policy, or source-detail authority.
- Use one bounded source view: child registers are slice-local; typed positions/spans and diagnostics add the
  parent span base and retain original source identity. Preserve parent cursor/boundary/marks/variables/
  transactions/captures; return one detached child payload through ordinary action binding.
- Effective grants intersect, ceilings take the stricter minimum, and cancellation/deadline/budget cannot reset or
  expand. Repeated identity/top/source dispatch must strictly shrink the span; bound depth/calls across all ids.
  Classify dispatch as rejected `parser_registry_or_staged_dispatch` inside uncommitted recognition attempts.
- Before syntax/behavior, `.0.1` corrects typed transaction truth: recognition is 9/9 but typed row owner `.14.3`
  remained pending. Then neutral `.1`, backends `.2-.6`, recurrence `.7`, and public no-drift `.8` proceed.
- Focused audit signoff changes no production source or public surface. Exact Perl lowering/resolve probes, Rust
  staged registry 1/1, Dart 5/5, typed/transaction/capability/language ledgers, book, Knowledge, bounded histories,
  task metadata, memory, README, and all nine doctrines pass; project-data managed-run residue is zero.

- 2026-08-17 (`FUTURE-PARITY-BACKLOG.14.5.1` — typed lossless-gap composition): clean activation is atomic 255
  `5b9c343a`. Knowledge/ADR/Toolbox and both executable contracts prove `gap_span` already supplies the detached
  typed same-source half-open Unicode-scalar carrier on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT.
- Preserve ownership. `INTER-MATCH-GAP-CAPTURE.1-.7` remains sole owner of named-slot and directive syntax,
  lifecycle, state, backend implementation, compatibility, migration, and public admission. This leaf owns only
  typed cross-contract binding, recurrence, rollout, and durable projection teaching.
- Checker-first RED is exact `ContractError: lossless-gap composition contract is missing`. GREEN binds upstream
  gap 9/0/63 plus public 6/12/10/29; adds twelve reasoned corruptions; promotes only
  `lossless_gap_composition`; and makes typed truth 10/4/126 while final combined `.14.8` stays pending.
- Rooted `tools/check_typed_gap_composition_six_runtime.sh` enters project-data storage, validates typed truth,
  runs the complete gap neutral/Perl-124/Rust-1/Dart-5/Julia-319/PUC-Lua-392/LuaJIT-392 route, then recognition
  137/250/58, generated-source strict Rust 105/105, capability 80/0/0, and language 250/105+1/126. Its canonical
  switch is `LINKEDSPEC_RUN_TYPED_GAP_COMPOSITION_MATRIX=1`; default CI still inventories/audits/syntax-checks it.
- No grammar/parser/compiler/runtime/carrier/facade/descriptor/schema/semantic/MCP/CLI/README or storage-owner
  change occurs. Book/Knowledge/live synchronization, outside-CWD routing, and nine doctrines pass. The
  receipt-bound canonical gate passes containment/relocation, CLI 66/66 twice, RAM 51%, Phase 0 1,031/1,031 in
  729 seconds, and the complete opt-in route; `.14.5` closes and `.14.6` is next.

- 2026-08-16 (`INTER-MATCH-GAP-CAPTURE.7.3` — independent no-change closeout): clean activation is public atomic
  254 `bb0c3768`. Retrieve and record hashes for the neutral/checker, five distinct six-runtime consumers,
  routing/storage, language/recognition/public contracts, compatibility, book, ADR/Knowledge, and both trees.
- Keep the no-change oracle base-relative. Every executable contract, grammar/parser/compiler/runtime/emitter/
  primary implementation, facade/schema/README surface, and admitted compatibility authority stays identical to
  `bb0c3768`; the permitted diff is task/roadmap/architecture/book status, Knowledge, live continuity, and handoff.
- Independent proof passes gap 9/0/63 plus public 6/12/10/29; rooted Perl 124, Rust 1, Dart 5, Julia 319, and Lua
  392 per ABI; language 250/105+1/126; recognition 137/250/58; capability 80/0/0; generated strict Rust 105/105;
  typed source 9/5/114; semantic 9/0/128; MCP 35/10/10/76; selected primary CLI 5x2x3; and storage locality
  1,914 files / 466,397 lines / 28 classifier cases plus outside-CWD/tool-writer routes.
- The mdBook renders 79 files / 14,956 KiB, and the exact generated directory is removed after inspection.
  `FUTURE-PARITY-BACKLOG.14.5.1` is only marked dependency-satisfied, never activated while this tree is dirty;
  it may promote only typed-source `gap_composition` after canonical receipt/commit/brief/clean proof.

- 2026-08-16 (`INTER-MATCH-GAP-CAPTURE.7.2` — public language/no-drift admission): activation base is clean
  recurring atomic 253 `d8ed944c`. Adding the four names to shared backend inventories before reclassification
  produced exact language RED `classified non-public Perl names admitted ... entry_slot, gap_kind, gap_span,
  gap_text`; replacing the marker-only artifact before checker support produced exact `required sections drifted`.
- Remove only those four entries from the independent non-public Perl classification. Load the final gap public
  contract and append its executable example to governed occurrence source, preserving the reported
  250 current / 105 corpus + 1 exact named-mark / 126 independently derived public Perl boundary.
- Keep runtime behavior singular and unchanged. Dart adds one `inter_match_gap` family classification; Julia and
  Lua delete their private-known bypasses because the current inventories are now sole name authority. Parser,
  compiler, runtime, emitter, primary, generated-plan, and outward facade/schema code do not move.
- Recognition changes only canonical call projection: add the four names to `source_read` and pin hash
  `7ea6cc4adae1559b722ff68dbd4c97816d03cf0d0590349b2af776859e85ae3f`. ActionIR rows remain 137 and semantic
  mutations remain 58.
- The final gap public contract is exact, not marker-only: six required markers, twelve forbidden stale claims,
  ten unchanged outward path/token guards, and 29 reason-checked mutations composed as 1 structural + 6 omission
  + 12 stale-injection + 10 outward-injection cases. Neutral mutations append only two ids for 9/0/63.
- Public language does not mean outward facade exposure. The same ten paths still reject directive, accessor,
  named-selector, and named-declaration tokens; README remains untouched and typed-source `gap_composition`
  remains `.14.5.1`-owned after independent `.7.3` closeout.
- Focused GREEN is gap 9/0/63 plus public 6/12/10/29, language 250/105+1/126, recognition 137/250/58, Dart 26,
  Julia recognition 207 + named marks 13 + gap 319, Lua aliases 638 + recognition 246 + gap 392 per ABI, Rust
  gap 1 + recognition 12, and rooted neutral/Perl-124/Rust-1/Dart-5/Julia-319/PUC-Lua-392/LuaJIT-392. The routed
  mdBook renders 78 files / 14,956 KiB; exact protected-surface diff, adjacent ledgers, Knowledge, histories,
  task/memory checks, and all nine doctrines pass before canonical staging. Canonical CI passes CLI 66/66 twice,
  RAM 59%, Phase 0 1,031/1,031 in 735 seconds, the exact gap matrix, and receipt generation for candidate
  `1440c0b88243e94a1c685bff7fd129c971236144bd79b14eda48dba81120cc1d`.

- 2026-08-16 (`INTER-MATCH-GAP-CAPTURE.7.1` — recurring admission): clean activation is atomic 252
  `be240c14`. Applying the planned artifact transition before checker changes yielded exact fail-first
  `expected counts drifted`.
- The neutral artifact/checker now own 8 complete / 1 pending / 61 semantic mutations. Only `recurring` changes
  pending→complete, its exact owner becomes `.7.1`, and `recurring_regression` is the sole new semantic mutation.
- The driver still derives its repository root, enters project-data storage, runs the neutral checker once, then
  executes Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT once in fixed order. Only its success sentence changes:
  recurring is current and public no-drift remains pending.
- The earlier Lua guard named `lua_later_recurring_skip` is reclassified as `lua_recurring_current`; the sixteen-
  mutation Lua admission cardinality and its separate public-pending guard remain exact.
- Five current status markers move coherently to recurring-current/public-pending. Marker-only stale-claim denial
  remains intentionally `.7.2`-owned, as do public call inventories, compatibility teaching, and final 9/0/63.
- Focused proof passes the checker, complete rooted matrix, language 246/122, recognition 137/246/58,
  generated/capability 80/0/0, typed source 9/5/114, semantic 9/9/128, MCP complete/141, project-data routing,
  tool-storage containment, and rendered mdBook. Canonical receipt-bound proof is mandatory for landing.

- 2026-08-16 (`INTER-MATCH-GAP-CAPTURE.7.0` — recurring/public closeout audit): activation base is clean atomic
  251 at `c33f6664`; neutral 7/2/60 and rooted neutral/Perl-124/Rust-1/Dart-5/Julia-319/PUC-Lua-392/LuaJIT-392
  pass without changing an executable authority.
- ADR `0079`: do not conflate recurrence with public language admission. `.7.1` promotes only recurring and adds one
  regression (8/1/61). `.7.2` promotes the already-implemented four gap calls into current shared language
  inventories, moving calls 246→250 and public Perl 122→126; recognition nodes stay 137 while call effects move
  246→250. Public closeout reaches gap 9/0/63 with an exact 6/12/10/29 document/stale/guard/mutation suite.
- Preserve compatibility by meaning: `@capture_slice`, `@capture_from_here`, and `@move_pos` remain retained
  divergent behavior, never `@capture_gaps` aliases; named marks and explicit helpers remain independent; no
  `@emit_gaps` or forced result emission is admitted.
- Marker-only no-overclaim guarding missed contradictory surrounding prose after Lua admission. Correct the stale
  two-Lua-skip and 3/6 current claims now, then make `.7.2` reject twelve exact stale claims in memory so one
  correct marker cannot hide another contradiction.
- `.7.3` is no-change recomposition and hands only typed-source `gap_composition` to `.14.5.1`. README, outward
  facades/schemas, semantic/MCP, CLI, capability census, generated format, storage, and typed-source rollout do
  not move in this activity's planning slice.
- The required CHANGES rollover advances only reviewed finite capacity through ADR `0078`: collection files
  18→19 and manifest lines 17→18; use the official content-addressed tool and preserve every other ceiling.
- Signoff is neutral 7/2/60, rooted all-six-runtime execution, language 246/122, recognition 137/246/58,
  generated/capability 80/0/0, typed source 9/5/114, semantic 6/20/128, MCP complete/141, rendered book, Knowledge
  840/7,102, and all nine doctrines. The canonical precursor passes CLI 66x2, RAM 56%, Phase 0 1,031/1,031 in
  752 seconds and the exact gap matrix; rerun receipt-bound after writing the final signoff record.

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
