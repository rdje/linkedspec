# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

## 2026-08-26 — TRACE-OBSERVABILITY.5.3 — align progressive authority proof

- Reproduced the cfg-enabled private Rust progressive-authority target at 3/4: all semantic authority tests passed,
  and only its pre-admission assertion incorrectly rejected the later admitted contract command.
- Proved admission commit `5c4d4218` added one tracked contract input and one cfg-enabled contract invocation while
  leaving the separate private-authority target unrouted and its earlier assertion unchanged.
- Renamed and corrected the topology proof: it continues to forbid any private-authority route and now requires
  the separate tracked contract input and canonical command exactly once. No production, generated, runtime,
  format, rollout, public/outward, or other-backend surface changed.
- Cfg authority passes 4/4; ordinary authority and contract discovery remain 0/0 each. Focused proof passes; a
  later canonical attempt exposed a separately stale staged-admission snapshot now owned by `.5.4` for closeout.

## 2026-08-26 — TRACE-OBSERVABILITY.5.2 — restore gap-aware child trace

- Reproduced the complete Rust trace target at 9/11: only interpreted and generated gap-aware child-entry cases
  lacked the existing `child_dispatch` marker, after each test had already proved traced/untraced result equality.
- Root-caused the regression to parallel `execute_child_rule_with_entry_slot` seams added by later lossless-gap
  work without the dispatch/result instrumentation that predated them.
- Routed each executor's normal child wrapper through its entry-slot seam and moved the unchanged event pair into
  that local owner. No-slot and typed-gap calls now emit exactly one existing lifecycle under their original engine
  or generated-plan namespace; no runtime result, event schema, generated format, public surface, rollout, or other
  backend changes.
- Complete trace controls pass 11/11, source emitter 6/6, exact Rust gap admission 1/1, core trace 7/7, and gap/
  recognition/progressive/staged governance. Full documented Rust trace parity is current again.

## 2026-08-26 — TRACE-OBSERVABILITY.5.1 — align traced progressive validation

- Reproduced an exact traced-only compiler bypass: ordinary `compile(...)` rejected a residual dedicated
  `dispatch_span(...)`, while `compile_with_trace(...)` accepted the same malformed compiled program.
- Restored the existing `validate_progressive_span_dispatch_contract` call in `compile_with_events` at the same
  point in the validator sequence as ordinary compilation. No new validation semantics, trace events, runtime
  behavior, generated format, public surface, rollout, or other backend changed.
- Added an exact regression proving ordinary/traced diagnostic equality and retained the existing valid
  traced/untraced result equality. Core trace tests, ordinary dormant discovery, the cfg-enabled admitted
  progressive four-route contract, and progressive/recognition/staged governance pass.
- Focused direct-dependent proof exposed one separate stale private-authority route assertion left by the later
  Rust contract admission. Git history proves the cause; `TRACE-OBSERVABILITY.5.3` now owns its repair after `.5.2`.

## 2026-08-26 — FUTURE-PARITY-BACKLOG.14.7.4.1 — add Rust staged annotation provenance

- Added `Expr::StagedParseJobMarker` as the exclusive lowering for exact scalar-assignment
  `parse_job(text_expr, hash(literal options))`; strict static validation rejects malformed, dynamic, duplicate,
  unknown, invalid-identity/policy/target, residual-generic, and recognition-reachable declaration forms.
- Retained live entry/match/capture byte spans only long enough to materialize exact text and construct same-source
  Unicode-scalar direct or nonempty ordered-derived provenance. Literal copied/transformed text, dynamic groups,
  copied-text smuggling, reversed/out-of-range/source-mismatched spans, and empty derived provenance fail closed.
- Added one inert detached `STAGED_PARSE_JOB_MARKER` with logical `staged_parse_job_v2` data and no parser,
  registry, source snapshot, callback, scheduler, cache, path, cancellation, budget, queue, or host authority.
  Native, normalized-reconstructed, generated-plan, and independently compiled emitted logical routes agree.
- Kept current function-body v1, generated format v2, ordinary/canonical discovery, Rust rollout, capability,
  public/outward surfaces, and every other backend unchanged. The dormant consumer now reaches only the exact
  `.14.7.4.2` caller-frozen resolution/cache/result/failure authority RED.
- Focused proof passed core 197/197, typed source 4/4, recognition transaction 12/12, current-v1/staged trace,
  neutral staged 79 mutations, and all dependent governance. It also exposed two pre-existing Rust compiler/trace
  defects; dedicated clean-pivot task-tree ownership and repair precede `.14.7.4.2`.

## 2026-08-26 — FUTURE-PARITY-BACKLOG.14.7.4.0 — freeze Rust staged-AST dormant RED

- Added exactly one repository-routed Rust consumer behind outer cfg
  `linkedspec_staged_ast_enrichment_red`; ordinary Cargo discovery compiles the target with zero active tests and
  canonical CI contains no reference to it.
- Froze the complete neutral inventory plus current function-body-v1 queue order, built-in resolution/load/
  compile/execute/cache records, `replace_field` / `body_ast` / `fail` behavior, and wrong-top diagnostic context.
- Proved the current v1 registry rejects general `expr-v1` authority at resolve. Authored `parse_job(...)` remains
  one generic `Expr::Call`, and native, normalized-reconstructed, generated-plan, and independently compiled
  emitted-source routes preserve that generic form and return null.
- Locked one exact final RED naming absent `STAGED_PARSE_JOB_MARKER` and typed `staged_parse_job_v2` provenance;
  every preceding assertion passes. No Rust production source, existing test, generated format, rollout,
  capability, public/outward path, or other backend changes.
- Advanced only Rust's consumer lifecycle from `pending_absent` to `dormant_red` and the independent checker from
  78 to 79 reason-checked mutations. Rust rollout remains pending and `.14.7.4.1` owns marker/provenance.

## 2026-08-26 — FUTURE-PARITY-BACKLOG.14.7.3.4 — admit Perl staged-AST enrichment

- Added private `LinkedSpec::StagedASTEnrichmentRuntime` and attached it to live and generated-v2 top-level
  execution. Host invocation options construct a new caller-frozen scheduler/cache for each parse and enrich only
  after the complete parent AST returns; typed staged failures stay inside the existing runtime error boundary.
- Proved native, normalized-descriptor, validated generated-plan, and independently loaded emitted-source routes
  produce equal detached AST, sidecar, diagnostic, cache, and resource results. Every route receives distinct
  snapshot aggregates, already-compiled callbacks, cancellation identities/callbacks, and clock authority.
- Proved normalized marker metadata, generated plans, and emitted source retain only logical declaration data and
  serialize no callback, compiled parser, registry snapshot, source authority, cancellation/deadline/budget state,
  mutable queue, filesystem path, or host handle. Generated-source v2 and function-body v1 remain unchanged.
- Promoted only the Perl backend consumer and Perl rollout leg. The unchanged final-path oracle is fully GREEN at
  143 top-level checks, executes once from ordinary phase-0 and once from canonical CI, while Rust/Dart/Julia/Lua,
  recurrence, public authoring, language inventory, and every outward surface remain pending or unchanged.
- Advanced the neutral checker to 78 reason-checked mutations and exact Perl admission topology. Focused direct
  dependents plus exact staged receipt-bound canonical CI accompany behavioral-parent closure.

## 2026-08-26 — FUTURE-PARITY-BACKLOG.14.7.3.3 — add Perl staged recursive authority

- Added private `enrich_recursively` over the existing caller-frozen resolution/cache/policy engine. Every complete
  depth resolves and validates before callbacks, settles in typed path/provenance/job-id order, and queues newly
  returned markers only after all producing-depth siblings settle.
- Added active lineage frames over normalized parser identity, selected top, SHA-256 of exact UTF-8 payload text,
  and full typed provenance. Exact repeats are cycles; same-parser/top recurrence requires every child segment be
  contained and total Unicode-scalar extent strictly decrease.
- Added one shared invocation authority for cancellation identity/callback, absolute deadline, remaining steps,
  total calls, maximum depth/calls, cumulative result nodes, and diagnostic bytes. Caller and entry ceilings only
  narrow; ephemeral callback contexts provide safe points and expire at settlement.
- Added original-source projection for child-local positions, spans, and nested diagnostics. Direct ranges remain
  direct; cross-segment ranges remain ordered `concatenate_in_order` provenance; oversized diagnostics become the
  exact bounded truncation sentinel.
- Advanced the same unrouted consumer to 141 GREEN top-level checks and one expected `.14.7.3.4` RED for native,
  reconstructed, generated-plan, and emitted fresh-authority carriers, ordinary/canonical admission, and Perl
  rollout. Function-body v1, neutral lifecycle/rollout, generated format, public/outward surfaces, and other
  backends remain unchanged.
- Focused Perl and neutral direct-dependent checks pass; Knowledge, rendered mdBook, continuity, doctrine, and
  exact no-carrier/no-admission/no-rollout proof accompany the atomic commit without a canonical trigger.

## 2026-08-26 — FUTURE-PARITY-BACKLOG.14.7.3.2 — add Perl staged current-depth authority

- Added private `LinkedSpec::StagedASTEnrichment` over caller-prepared immutable candidate outcomes and logical
  entries whose opaque execution authority is already a compiled callback. Runtime registry mutation, implicit
  loading, and filesystem/provider/import/environment/network/compiler authority remain impossible.
- Implemented pure alias/declaring-relative/ordered-root/ordered-provider selection with exact missing,
  ambiguity, collision, top, version, capability, policy, source-detail, and cache-component diagnostics. Default
  top selection now precedes the canonical v2 job digest.
- Added the neutral immutable cache identity and isolated current-depth execution. The cache retains only locked
  execution plans; every job runs on fresh cursor/mark/capture/variable inputs, and child results or failures are
  never replayed from cache.
- Implemented `replace_marker`, `replace_field`, `sibling_field`, `append_child`, `fail`, `keep_text`, and
  `diagnostic_node` over an unpublished AST copy with detached node-bounded results and exact marker/target errors.
- Advanced the same unrouted consumer to 133 GREEN top-level checks and one expected `.14.7.3.3` RED for
  breadth-first recurrence, decreasing-chain/cancellation/resource bounds, and source-rebased diagnostics.
  Function-body v1, recursive scanning, carriers, discovery, rollout, generated format, public inventory, outward
  surfaces, and other backends remain unchanged.
- Focused Perl and neutral direct-dependent checks pass at their exact prior counts; Knowledge, rendered mdBook,
  continuity, doctrine, and exact no-scope-expansion proof accompany the atomic commit without a canonical trigger.

## 2026-08-26 — FUTURE-PARITY-BACKLOG.14.7.3.1 — add Perl staged annotation provenance

- Added one private exclusive `STAGED_PARSE_JOB_MARKER` contract for exact assignment-form
  `parse_job(text_expr, literal_options)` annotations. Non-assignment calls remain unresolved; malformed/dynamic
  options and invalid parser/top/result/failure/target identities reject before authored execution.
- Added an opaque inert marker with a detached `staged_parse_job_v2` declaration sidecar. It carries normalized
  literal options, exact materialized text, and typed direct or ordered-derived provenance, but no source/match/
  parser/registry/path/callback/scheduler authority.
- Preserved private regex match/capture offsets long enough to construct Unicode-scalar spans through the existing
  `LinkedSpec::SourceLocation` algebra. Reversed/out-of-range, empty-derived, transformed/literal copied text,
  copied-text smuggling, and dynamic capture indices fail closed.
- Classified the declaration as a forbidden staged-dispatch effect inside uncommitted recognition, kept the
  current function-body-v1 adapter unchanged, and retained `parse_job` outside the public language inventory.
- Advanced the same dormant final-path consumer from 60 GREEN/missing-marker to 120 GREEN and one expected RED for
  `.14.7.3.2`'s missing pre-registered resolution/cache/result/failure authority. Ordinary/canonical discovery,
  recursive queues, reconstructed/generated/emitted carriers, rollout, format, capability, and outward surfaces
  remain unchanged.
- Focused ActionIR, typed-source, semantic, progressive, recognition, generated-source, capability, language,
  neutral staged, Knowledge, rendered-book, continuity, doctrine, and exact no-drift proof pass; no canonical
  trigger is crossed.

## 2026-08-25 — FUTURE-PARITY-BACKLOG.14.7.3.0 — freeze Perl staged-AST dormant RED

- Added the exact final-path Perl general staged-AST consumer with 60 GREEN assertions and one intentional RED at
  the first missing dedicated `STAGED_PARSE_JOB_MARKER` boundary.
- Locked the unchanged function-body-v1 adapter through direct resolve/load/compile/execute proof, exact compile-
  diagnostic context, descriptor-side `body_ast` stitching, and explicit no-v1-to-v2 upgrade.
- Advanced only the predeclared Perl consumer lifecycle from `pending_absent` to `dormant_red`; the neutral schema,
  72 mutations, Perl rollout, ordinary/canonical discovery, generated format, production behavior, and public
  `parse_job(...)` availability remain unchanged.
- Froze the Perl child order: annotation/provenance `.1`, resolution/cache/policies `.2`, recursive scheduling/
  bounds/diagnostics `.3`, and fresh carriers plus admission `.4` all retain this same final-path consumer.
- Applied the mandatory complete-record rollover into immutable segment `4991` and restored the hot root to
  249/512 lines. ADR `0089` advances only finite change-history collection/manifest controls from 21/20 to 22/21;
  every byte, per-file, aggregate, owner, lifecycle, verifier, and storage control remains unchanged.

## 2026-08-25 — FUTURE-PARITY-BACKLOG.14.7.2 — add neutral staged-AST enrichment authority

- Added `linkedspec-staged-ast-enrichment-v1`, the checker-first executable neutral contract for authored
  `parse_job(text_expr, options)` and its inert marker/sidecar boundary without enabling backend behavior.
- Froze typed direct/derived provenance, caller-completed deterministic resolution, immutable registry/cache
  authority, breadth-first recursive queues, four result policies, three failure policies, strict bounds,
  detachment, diagnostics, carriers, dormant routes, rollout, compatibility, and 35 exact downstream owners.
- Added an independent repository-routed checker that executes the contract and rejects 72 reason-checked
  schema, semantic, authority, isolation, topology, public-boundary, and ownership mutations.
- Registered the checker unconditionally in canonical local CI while keeping all five backend consumer sources
  dormant, all nine rollout legs pending, and facade/schema/semantic/MCP/CLI/README surfaces absent.
- Recorded ADR `0088`, a Knowledge Map fact card, updated staged-architecture decisions, and synchronized the
  roadmaps, architecture, capability guidance, Toolbox, sole-facing mdBook, task/frontier, and continuity truth.
- Focused contract/direct-dependent proof, rendered book, 60-file aggregate-selector public admission, and the
  32-entrypoint project-data census pass together with Knowledge, bounded histories, all nine doctrines, exact
  staged diff, and receipt-bound canonical local CI before the atomic commit.

## 2026-08-25 — FUTURE-PARITY-BACKLOG.14.7.1 — preserve staged compile diagnostic context

- Added exact wrong-top compile assertions across Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT for the original
  job id/path/parser/top/payload/span/failure context plus the resolved built-in identity.
- Passed the normalized job through Perl/Rust/Dart compile instead of synthesizing placeholders; retained
  Julia/shared-Lua job propagation and added their missing `payload_kind` diagnostic field.
- Preserved the one-depth `actionir-body.spec` / `action_block` success, resolution, execution, stitching, policy,
  cache, generated-format, capability, rollout, and public/outward boundaries.
- Backend proof passes Perl 1,031/1,031; Rust 1/1; Dart 6/6; Julia staged 39/39 within its complete suite; and
  PUC Lua/LuaJIT 178/178 each. Semantic 6/20/128 plus six admissions and 5x2x3 CLI, typed 12/2/170,
  progressive 9/9/116, generated/capability 80/0/0, and language 250/126 remain GREEN.
- Synchronized ADR/current architecture, two Knowledge cards, roadmaps, Toolbox, sole-facing mdBook, task/index,
  bounded histories, memory/live status, and focused verification. Canonical CI is not triggered.

## 2026-08-25 — FUTURE-PARITY-BACKLOG.14.7.0 — audit general staged AST boundary

- Used descriptor/runtime/registry probes and exact five-backend source/test comparison to prove the current
  one-depth `body_parse_job` / `actionir-body.spec` / `action_block` path on six runtime routes.
- Distinguished raw registry metadata transport from executable semantics: only the function-specific integration
  implements and enforces `replace_field` / `body_ast` / `fail`; alternate policy names remain future behavior.
- Found and task-owned one current parity defect: wrong-top compile diagnostics keep real job context in
  Julia/shared Lua but substitute placeholders in Perl/Rust/Dart. Corrective `.14.7.1` precedes feature work.
- Froze 37 stable children for diagnostic repair, one executable neutral contract, five backend parents with
  per-slice RED/authority/policy/queue/carrier admissions, recurrence, public authoring, and recomposition. The
  authoritative task census is 594 under unchanged partition pressure controls.
- Added dated ADR current notes and synchronized Knowledge, capability guidance, roadmaps, architecture, Toolbox,
  sole-facing mdBook, task/frontier, bounded continuity, memory, and live status. No product/test/fixture/contract/
  format/CI/outward behavior changed.
- Focused registry proofs plus capability 80/0/0, generated 80/0/0, language 250/126, semantic 6/20/128, typed
  12/2/170, progressive 9/9/116, Knowledge, rendered book, histories, task/index, README/memory, and all nine
  doctrines pass. Canonical CI is not triggered for this behavior-free ordinary audit.

## 2026-08-25 — FUTURE-PARITY-BACKLOG.14.6.8 — close progressive public no-drift

- Root-caused a governance mismatch left by `.14.6.7`: its completed five-source/six-runtime driver promoted the
  typed recurring row, but the independently defined progressive behavioral `recurring` row still said pending.
  No product behavior was missing; the exact defect and prevention rule now have a Knowledge Map fact card.
- Corrected that row to its committed driver and promoted only `public_no_drift`, closing progressive governance
  at 9/9/116. The neutral checker now governs six current documents, 12 stale claims, 10 outward paths, and 60
  reason-checked omission/injection mutations while requiring the private-intrinsic/no-public-API boundary.
- Updated only the five immutable consumer groups' status/count/rollout snapshots. Their fixtures, behavioral
  assertions, runtime sources, carriers, generated format, typed 12/2/170 contract, and six-runtime route remain
  unchanged.
- Synchronized ADR `0080`, Knowledge, capability guidance, roadmaps, architecture, Toolbox, task/frontier,
  continuity, and the sole-facing mdBook. Root README, facade/schema/semantic/MCP/CLI surfaces, staged `.14.7`,
  and combined `.14.8` do not move.
- Focused no-drift proof, the exact six-runtime driver, rendered mdBook, Knowledge, bounded histories, all nine
  doctrines, exact staged diff, and receipt-bound canonical CI pass. Parent `.14.6` closes; staged `.14.7` is next.

## 2026-08-25 — FUTURE-PARITY-BACKLOG.14.6.7 — bind progressive recurring proof

- Added `tools/check_progressive_span_dispatch_six_runtime.sh`, one repository-routed fail-fast composition of
  neutral, Perl 129, cfg-enabled Rust 1/1, Dart 7, Julia 62, PUC Lua 178, LuaJIT 178, then typed-source,
  generated-source, capability, and language support ledgers.
- Bound five immutable backend consumer source groups to six ordered runtime routes because one shared Lua source
  executes independently on both ABIs. Canonical CI always requires, machine-path-audits, and syntax-checks the
  driver; `LINKEDSPEC_RUN_PROGRESSIVE_SPAN_MATRIX=1` opts into its exact all-toolchain execution.
- Promoted only typed `progressive_span_dispatch`, advancing typed governance from 11/3/152 to 12/2/170 through
  twelve topology/storage/rollout mutations plus two stale-guide denials. Progressive behavioral governance
  remains 7/9/112; staged dispatch, progressive public no-drift, and combined final no-drift retain their owners.
- Corrected the progressive neutral current-boundary assertion from typed-pending to typed-complete over all six
  runtimes without changing its fixtures, behavioral rollout, carrier inventories, diagnostics, or 112 mutations.
- Root-caused the capability guide's stale 2/9/pending paragraph to Perl admission commit `78bc66e1`; later
  runtime admissions omitted that current projection. The exact stale claims are now mutation-locked and the
  Knowledge Map records the defect while dated evidence remains unchanged.
- Git proves no runtime, consumer, generated-format, facade/schema/semantic/MCP/CLI/README outward, or public
  behavior movement. Focused matrix, rendered mdBook, Knowledge, bounded histories, nine doctrines, exact staged
  diff, and receipt-bound canonical CI pass; progressive public no-drift `.14.6.8` is next.
- Mandatory engineering-notes rollover publishes immutable segment `4991`. ADR `0087` increases only exact finite
  collection/manifest-line capacity from 16/15 to 17/16; every root, segment, aggregate, byte, owner, lifecycle,
  verifier, and repository-storage control remains unchanged.

## 2026-08-25 — FUTURE-PARITY-BACKLOG.14.6.6.4 — close shared Lua progressive dispatch

- Activated task-tree-first from exact clean Lua-admission commit `e5c66c4`; changed no production, test, fixture,
  executable contract, generated format, CI topology, rollout, typed recurrence, or outward surface.
- Independently reran the committed shared carrier at 178/178 and separate dormant authority at 273/273 on PUC
  Lua and LuaJIT. Native, normalized-JSON reconstructed, generated-plan, and independently loaded emitted-module
  routes remain equal; serialized/emitted state carries no live authority.
- Complete ordinary Lua, Perl 129/129, cfg-enabled Rust 1/1, Dart 7/7, Julia 62/62, progressive 7/9/112, typed
  11/3/152, recognition 138/250/58, generated/capability 80/0/0, and language 250/126 pass unchanged.
- The current-projection audit corrects stale Lua-pending prose in predecessor admission/closeout Knowledge cards
  while preserving dated evidence. ADR `0080`, roadmaps, task/frontier, bounded continuity, and the sole-facing
  mdBook now agree that all six private runtime rows are independently recomposed.
- Exact staged receipt-bound canonical CI closes shared Lua parent `.14.6.6` at unchanged rollout 7/9/112 and
  hands off typed recurring five-source/six-runtime proof `.14.6.7`.

## 2026-08-25 — FUTURE-PARITY-BACKLOG.14.6.6.3 — admit private Lua progressive dispatch

- Activated task-tree-first from exact clean Lua-carrier commit `4f6173d0`; moved the same 178-assertion
  Lua-5.1-compatible consumer from `lua/test_dormant/` to `lua/test/` with only header, neutral snapshot, and
  discovery assertions changed.
- `tools/run_lua_local.sh` executes that shared source exactly once on PUC Lua and once on LuaJIT. Canonical CI
  requires the tracked path once, then registers and invokes one exact repository-routed route per ABI.
- Neutral governance promotes only PUC Lua and LuaJIT: rollout advances from 5/9/106 to 7/9/112 with 9 Rust,
  8 Dart, 9 Julia, and 9 Lua carrier paths, zero backend guards, 10 outward guards, and 26 diagnostics.
- The carrier remains 178/178 and the separate dormant authority remains 273/273 on both ABIs. Complete ordinary
  Lua, admitted Perl/Rust/Dart/Julia consumers, and progressive/typed/recognition/generated/capability/language
  direct dependents pass.
- Production, private authority, generated-v2 format, typed recurrence, public inventory, facade/schema/MCP/CLI/
  README, and outward surfaces do not move. Exact staged receipt-bound canonical CI admits the topology;
  independent recomposition `.14.6.6.4` is next.

## 2026-08-25 — FUTURE-PARITY-BACKLOG.14.6.6.2 — implement dormant Lua progressive carriers

- Activated task-tree-first from exact clean Lua-authority commit `6cbf8fdf`; the reserved literal-id/literal-top/
  bare-span assignment now lowers to one exclusive `progressive_dispatch_span` node on both Lua ABIs.
- Malformed operands and residual generic calls reject before execution. Compile-time rule/function effect closure
  rejects recognition-reachable dispatch, and live-token unwind restores recognition state without masking the
  primary `progressive_transaction_forbidden` diagnostic.
- `ProgressiveExecutionSeed` owns a copied decoded-source recipe and starts fresh execution state per parse.
  Native, normalized-JSON reconstructed, generated-plan, and independently loaded emitted-module routes return
  the same detached result at unchanged parent cursor on PUC Lua and LuaJIT.
- The shared dormant carrier consumer is GREEN at 178/178 per ABI; the separate authority stays 273/273. Complete
  ordinary Lua remains 178/178 per ABI, CLI 66/66 in both environments, corpus 105, and storage 19/3.
- Neutral governance now records 9 dormant Lua carrier paths and zero backend guards at unchanged rollout
  5/9/106. Perl 128/128, Dart 7/7, Julia 62/62, and the cfg-enabled Rust direct consumer agree.
- Serialized/emitted artifacts omit callbacks, registry entries, fingerprints, decoded input snapshots,
  cancellation, and mutable execution state. Generated-v2 format, ordinary/canonical discovery, rollout, typed
  recurrence, package facade, README, and outward surfaces remain unchanged; dual-ABI admission `.3` is next.

## 2026-08-25 — FUTURE-PARITY-BACKLOG.14.6.6.1 — implement shared Lua progressive authority

- Activated task-tree-first from exact clean Lua-RED commit `84178bd8`; added one direct Lua-5.1-compatible
  `bounded_child_parse_authority` module and one dormant consumer, with no package-facade or carrier registration.
- Module-private opaque state owns immutable already-compiled entries, copied-source fresh invocations, typed
  globally rebased callback views, narrowing capabilities/policies/ceilings, shared cancellation/deadline/steps,
  decreasing-span/depth/call limits, callback/request expiry, and deeply detached node-bounded child results.
- The same consumer passes 273/273 on PUC Lua and LuaJIT across all neutral rows and 26 diagnostic contexts plus
  nesting, rebasing, expiry, isolation, cycle/nonfinite/live-field/node bounds, and UTF-8 truncation adversaries.
  The separate final-path consumer remains exactly 85-pass/one-RED per ABI; all five carriers stay absent.
- Complete Lua remains 178/178 per ABI, CLI 66/66 in both environments, corpus 105, and storage 19/3. Progressive
  5/9/106, typed 11/3/152, recognition 138/250/58, generated/capability 80/0/0, and language 250/126 pass.
- Task/index, ADR `0080`, Knowledge, sole-facing mdBook, bounded histories, README/memory, and nine doctrines are
  synchronized without generated-format, discovery, rollout, typed-recurring, or outward movement. Carriers `.2` next.

## 2026-08-25 — FUTURE-PARITY-BACKLOG.14.6.6.0 — freeze shared Lua progressive dispatch RED

- Activated task-tree-first from exact clean Julia-closeout commit `e25791e`; split Lua `.14.6.6` into RED,
  private authority, dormant carriers, admission, and recomposition leaves before adding one shared dormant test.
- The Lua-5.1-compatible consumer runs unchanged on PUC Lua and LuaJIT. Each host passes 85 of 86 assertions and
  fails only the intentional missing-exclusive-node assertion; the test is absent from ordinary and canonical
  discovery and no production, generated-format, public, rollout, or CI behavior moves.
- The proof locks the separate staged-registry rejection, one generic authored `dispatch_span` call, and equal
  typed unsupported-helper outcomes through native, normalized-JSON reconstructed, generated-plan, and
  independently loaded emitted-module routes. Complete Lua and all progressive direct dependents pass unchanged.
- Synchronization found the roadmap's compact current summary still projected pre-admission Julia 4/9/103 truth
  despite correct lead prose. Root cause is an ungated manually repeated current projection; both roadmaps are
  corrected and a causal Knowledge card makes this exact retrieval/gating seam durable.
- The sole-facing mdBook, ADR `0080`, Knowledge, task/index, bounded histories, README/memory, and nine doctrines
  are synchronized. Private shared Lua authority `.14.6.6.1` is next.

## 2026-08-25 — FUTURE-PARITY-BACKLOG.14.6.5.4 — close Julia progressive dispatch

- Activated task-tree-first from exact clean Julia-admission commit `7823f6fc`; changed no production, test,
  fixture, executable contract, generated format, CI topology, rollout, typed recurrence, or outward surface.
- Independently reran the committed Julia carrier at 62/62 and separate dormant authority at 210/210. Native,
  reconstructed, generated-plan, and independently included emitted-module routes remain equal; serialized and
  emitted state carries no callback, registry, fingerprint, source snapshot, cancellation, or mutable authority.
- Complete ordinary Julia, Perl 128/128, Dart 7/7, cfg-enabled Rust 1/1, progressive 5/9/106, typed 11/3/152,
  recognition 138/250/58, generated/capability 80/0/0, and language 250/126 all pass unchanged.
- Independent review found stale current Julia-pending prose in the earlier Perl/Rust/Dart admission cards. The
  executable neutral checker governs runtime/contract/outward paths, while Knowledge Map enforcement proves
  derived-index freshness rather than semantic agreement across predecessor cards. Their bounded current
  projections are corrected and a causal fact card is added without rewriting dated historical evidence.
- ADR `0080`, Knowledge, sole-facing mdBook, bounded histories, task/index, README/memory, nine doctrines, exact
  staged diff, and receipt-bound canonical CI close Julia parent `.14.6.5`. Shared Lua `.14.6.6` is next.

## 2026-08-24 — FUTURE-PARITY-BACKLOG.14.6.5.3 — admit private Julia progressive dispatch

- Activated task-tree-first from exact clean Julia-carrier commit `35a2b56c`; moved the same Git blob from
  `julia/test_dormant` to `julia/test`, changing only its admission-owned header, neutral snapshot, and discovery
  assertions while preserving all seven groups and 62 assertions.
- Ordinary `Pkg.test()` includes the carrier exactly once. Canonical CI requires its tracked path, logs one exact
  Julia admission marker, and invokes the same repository-routed consumer once; no dormant carrier duplicate
  remains, while the separate 210-assertion authority consumer stays dormant and directly runnable.
- Promoted only Julia's neutral current-boundary and rollout truth. Governance is 5/9/106 with 9 Rust + 8 Dart +
  9 Julia carrier paths, one Lua guard/5 paths, ten outward guards, and 26 diagnostics; typed progressive,
  recurrence, public inventory, facades, schemas, MCP, CLI, README, and outward surfaces remain pending/closed.
- The exact Julia carrier 62/62, dormant authority 210/210, complete ordinary Julia package, Perl 128/128, Dart
  7/7, cfg-enabled Rust consumer, progressive 5/9/106, typed 11/3/152, recognition 138/250/58, generated and
  capability 80/0/0, and language 250/126 pass. Julia production and generated-format sources are unchanged.
- Knowledge, sole-facing mdBook, bounded histories, task/index, README/memory, nine doctrines, exact staged diff,
  and receipt-bound canonical CI provide final admission proof. Behavioral Julia work closes; independent
  topology/continuity recomposition `.14.6.5.4` remains next.

## 2026-08-24 — FUTURE-PARITY-BACKLOG.14.6.5.2 — implement dormant Julia progressive carriers

- Activated from exact clean `bb34a85e` and replaced only the reserved literal-id/literal-top/bare-span assignment
  with one exclusive logical-only node; malformed operands, residual generic calls, and recognition-reachable
  effect graphs reject statically, with reconstructed compiled input validated again by the engine.
- An opaque host seed starts fresh invocation state per top-level run. Native, `SpecFile`-JSON reconstructed,
  generated-plan, and independently included emitted-module routes return the same detached result without parent-
  cursor movement; generated data contains no callback, registry, fingerprint, source snapshot, cancellation, or
  mutable authority.
- Live recognition defense lets the existing authority restore/invalidate unfinished tokens, while invocation
  teardown preserves an already-propagating progressive denial instead of replacing it with a terminal diagnostic.
- Dormant carrier and authority consumers pass 62/62 and 210/210; complete ordinary Julia and all direct dependent
  checks pass. Governance tracks 9 dormant Julia carriers plus one Lua guard/5 paths at unchanged rollout 4/9/103.
  Ordinary/canonical admission, generated format, typed recurrence, public, and outward surfaces stay fixed.
- Mandatory pressure rollover archives 226 complete clean-HEAD lines as immutable change segment `4992`, leaving
  the hot shard below 50%. The doctrine gate rejects prior finite 20-file/19-manifest-line capacity; ADR `0086`
  raises only those controls to 21/20, retains every other limit, and requires receipt-bound canonical signoff.
- Canonical attempt one passes all doctrines and catches Perl's stale pre-Julia neutral inventory after the checker
  passes; Perl, Rust, and Dart admitted snapshots now all record 9 dormant Julia carriers plus one Lua guard/5 paths.
- Corrected lockstep consumers pass Perl 127/127, Dart 7/7, and cfg-enabled Rust 1/1, including independent emitted-
  module compilation; the exact staged candidate then clears receipt-bound canonical CI without admitting Julia.
