# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

## 2026-08-27 — FUTURE-PARITY-BACKLOG.14.7.5.4 — admit Dart staged enrichment carriers

- Added opaque host-only `StagedAstEnrichmentSeed` and one-use state. Every top-level execution constructs a fresh
  frozen registry/cache and recursive authority, completes the parent parse, checks live recognition-transaction
  state, and only then enriches the returned AST inside the existing structured runtime-error boundary.
- Routed the same optional seed through native, `SpecFile`-JSON reconstructed, validated generated-plan, and
  generated-source-v2 execution without serializing concrete callbacks, compiled parsers, registry/source
  authority, cancellation/deadline/budget state, mutable cache/queue, paths, or host handles.
- Moved the stable consumer from `dart/test_dormant/` to `dart/test/`. Its four routes each execute twice through
  one seed and prove equal detached AST/sidecar/diagnostic/cache/resource records, fresh callbacks/cancellation/
  clocks, one miss/zero hits per run, mutation isolation, and logical generated/emitted authority absence.
- The final consumer passes 19/19, fatal analysis and 102 direct dependents pass, and ordinary Dart is 435/435.
  Canonical CI requires/logs/invokes the exact consumer once. Neutral governance rejects 90 mutations and promotes
  only Dart; function-body v1, generated-source v2, public/outward behavior, and later backends do not move.
- The exact staged candidate passes receipt-bound canonical CI, including all nine doctrines, both 66/66 primary-
  CLI option environments, and phase 0 at 1,032/1,032; the Dart backend parent closes with Julia `.14.7.6.0` next.

## 2026-08-27 — FUTURE-PARITY-BACKLOG.14.7.5.3 — add Dart staged recursive authority

- Preserved `enrichStagedCurrentDepth` and added private `enrichStagedRecursively` over the same caller-frozen
  registry/cache. Returned markers queue only after their producing depth settles; every next depth is completely
  resolved, authority-checked, target-validated, and typed path/provenance/job sorted before callbacks.
- Added exact resolved-parser/top/payload-digest/full-provenance lineage, exact-cycle and strict-containment/decrease
  guards, non-resetting cancellation/deadline/step/call/depth/result/diagnostic resources, expiring callback safe
  points, and direct/ordered-derived original-source position/span/diagnostic projection.
- Corrected a latent complete-depth preflight defect found during review: duplicate non-append targets, mixed
  append/replace targets, and replacement targets containing another queued marker now reject before callback one;
  multiple deterministic appends to one list remain valid.
- The same dormant consumer advances from `+12 -1` to `+18 -1`; only `.14.7.5.4` fresh carriers, production seam,
  ordinary/canonical admission, and Dart rollout remain RED. Fatal analysis, 102 direct dependents, and all 416
  ordinary Dart tests pass. V1, marker bytes/four logical routes, neutral 85 mutations, discovery, formats,
  public/outward truth, and other backends do not move.

## 2026-08-26 — FUTURE-PARITY-BACKLOG.14.7.5.2 — add Dart staged current-depth authority

- Added private `staged_ast_enrichment.dart`. `FrozenStagedRegistry` deeply owns caller-completed alias/relative/
  ordered-root/provider outcomes and binds every logical authority name one-for-one to an already-compiled opaque
  callback; runtime loading, compilation, provider query, filesystem access, and registry mutation are absent.
- Added pure resolution, default-top-before-v2 job identity, exact eight-field normalized cache identity, and an
  invocation-local plan-only cache. Entry versions/capabilities/policies/source detail/resource ceilings only
  narrow caller authority; child results and failures always execute and never poison the cache.
- Added complete current-depth preflight and typed path/provenance/job ordering, fresh sibling cursor/mark/capture/
  variable contexts, finite acyclic node-bounded detachment, unpublished-copy atomicity, all four result policies,
  all three failure policies, and exact target/live/cycle/overflow denials. Returned markers remain inert.
- The same dormant consumer advances from `+7 -1` to `+12 -1`; only `.14.7.5.3` breadth-first recurrence,
  decreasing-chain/cycle/shared-resource authority, safe points, and source-rebased diagnostics remain RED. Fatal
  analysis, 102 direct dependents, and ordinary Dart 416/416 pass. V1, marker bytes/four logical routes, neutral 85
  mutations, discovery/canonical topology, rollout, generated format, public/outward truth, and other backends do
  not move.

## 2026-08-26 — FUTURE-PARITY-BACKLOG.14.7.5.1 — implement Dart staged marker provenance

- Replaced only exact scalar assignment-form `parse_job(text_expr, literal_hash_options)` with a dedicated private
  ActionIR node. Required/optional options, identities, policies, targets, capabilities, assignment-only placement,
  residual calls, and recognition-reachable effects now reject statically under the neutral diagnostic family.
- Added an inert detached `STAGED_PARSE_JOB_MARKER` / `staged_parse_job_v2` declaration. Direct and recursively
  flattened `cat(...)` plans materialize exact text from typed Unicode-scalar source provenance and serialize no
  source authority, match, parser, registry, callback, scheduler, cache, path, or host handle.
- Dart's text-only capture registers now retain only private group identity plus regex option bits. The staged path
  lazily instruments the original regex with zero-width suffix probes, requires the exact original whole match,
  verifies the resulting substring against the live capture register, then converts proven UTF-16 boundaries
  through `SourceAuthority`; ordinary matching incurs no recovery search.
- The unchanged dormant path now reports seven GREEN groups and one intentional `.2` authority RED. Fatal analysis,
  132 direct dependents, ordinary Dart 416/416, neutral 85-mutation governance, and four logical routes pass.
  Function-body v1, result/failure execution, recurrence, discovery/canonical topology, rollout, generated format,
  public/outward surfaces, and other backends remain unchanged.

## 2026-08-26 — FUTURE-PARITY-BACKLOG.14.7.5.0 — freeze Dart staged-AST dormant RED

- Added one exact `dart/test_dormant/` consumer and no production behavior. Fatal analysis passes; four tests lock
  neutral/v1 truth, current generic ActionIR structure, native/reconstructed/generated-plan rejection, and
  independently analyzed/executed emitted-source rejection.
- Froze the fifth and only failure at missing `STAGED_PARSE_JOB_MARKER` / `staged_parse_job_v2`. Current
  assignment-form `parse_job` remains a generic `ActionCallExpr` and all execution routes preserve the structured
  `unknown_helper` rejection.
- Advanced only Dart's neutral lifecycle to `dormant_red` and mutation governance to 85. Canonical proof found and
  corrected the admitted Perl/Rust consumers' three stale pre-Dart projection values; they remain behaviorally
  GREEN at 143/143 and 1/1. The final consumer path, ordinary/canonical registration, Dart rollout, production,
  generated format, public/outward behavior, and later backends remain unchanged; `.14.7.5.1` owns marker/provenance.
- Mandatory complete-record rollover publishes immutable change-history segment `4990`; the synchronized current
  root is 243/512 lines. ADR `0091` advances only finite collection/manifest-line capacity from 22/21 to 23/22;
  all byte, per-file, aggregate, owner, lifecycle, verifier, and repository-storage controls remain unchanged.

## 2026-08-26 — FUTURE-PARITY-BACKLOG.14.7.4.4 — admit Rust staged enrichment carriers

- Added one host-only invocation seed that constructs a fresh immutable registry/cache and recursive authority per
  top-level execution, then enriches only after the complete parent result.
- Attached the seed to native, reconstructed, validated generated-plan, and independently compiled emitted routes.
  Their detached records agree while callbacks, cancellation, clocks, caches, and result mutation remain isolated;
  logical generated/emitted data contains no live authority.
- Removed the obsolete outer test cfg, cfg-only exports, manifest check-cfg registration, and conditional dead-code
  allowance. The exact consumer is required once in ordinary/canonical topology, neutral governance is 84
  mutations, only Rust rollout advances, and public/generated-format/later-backend behavior remains unchanged.

## 2026-08-26 — FUTURE-PARITY-BACKLOG.14.7.4.3 — add Rust staged recursive authority

- Added a private breadth-first recursive entrypoint over the existing caller-frozen registry. Every complete depth
  resolves and validates before callbacks; successful returned markers enter only the next typed-sorted depth.
- Added exact parser/top/exact-UTF-8-digest/full-provenance cycle identity, strict same-parser/top provenance
  containment and scalar-extent decrease, and one invocation-wide cancellation/deadline/step/call/depth/result-
  node/diagnostic-byte authority with expiring callback safe points.
- Added direct and ordered-derived child position/span/diagnostic rebasing. Cross-segment ranges retain
  `concatenate_in_order`; oversized portable diagnostics become the governed truncation sentinel.
- Kept ordinary discovery at zero tests, the exact Rust test path absent from canonical CI, neutral governance at
  79 mutations with Rust `dormant_red`, and v1/v2 formats, carriers, rollout, public/outward behavior unchanged.
  The sole RED now names `.14.7.4.4` carriers, production seam, admission, and rollout.

## 2026-08-26 — FUTURE-PARITY-BACKLOG.14.7.4.2 — add Rust staged current-depth authority

- Added one private Rust general-v2 authority over caller-frozen resolution outcomes and already-compiled opaque
  callbacks. Pure alias/relative/ordered-root/provider selection, authority narrowing, selected-top-before-job-id,
  and run-local plan-only cache behavior add no loader, provider query, path, environment, or registry mutation.
- Added complete current-depth preparation, typed path/provenance/job ordering, fresh sibling contexts, detached
  node-bounded results, atomic publication, all four result policies, all three failure policies, and exact stale/
  missing/collision/wrong-kind/live-result denials. Newly returned markers remain inert and unrescanned.
- Kept the same outer-cfg dormant consumer, ordinary discovery at zero tests, canonical references at zero,
  function-body v1/generated format v2, 79-mutation governance, Rust rollout, and public/outward behavior unchanged.
  Its sole RED now names `.14.7.4.3` recurrence, bounds, and original-source diagnostic rebasing.

## 2026-08-26 — TRACE-OBSERVABILITY.5.4 — align staged admission proof

- Reproduced the exact admitted Perl staged-AST consumer at 141/143: only its frozen neutral mutation count and
  backend-consumer lifecycle list lagged current contract truth.
- Proved Rust dormant-RED commit `e37a8b77` advanced mutations 78→79 and Rust `pending_absent`→`dormant_red` while
  leaving the already-admitted Perl consumer snapshot unchanged.
- Updated exactly those two expected values. Perl passes 143/143; neutral staged governance reports 79 mutations,
  five consumers/six routes, 37 diagnostics, nine rollout legs, and 35 owners.
- No production, registry, generated format, rollout, public/outward, or other-backend behavior changes. Exact
  receipt-bound canonical proof closes corrective `.5` and the trace tree.
- The mandatory engineering-notes pressure rollover archives exact prior records as immutable segment `4990`;
  ADR `0090` advances only finite collection/manifest capacity to 18 files / 17 lines, and the current shard is
  242/512 lines.

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
