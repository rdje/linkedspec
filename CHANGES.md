# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

## 2026-08-31 — FUTURE-PARITY-BACKLOG.19.2.2 — implement Perl map leaves mutation

- Implemented only bare `IDENTIFIER.map_leaves!() { ACTION_BLOCK }` on Perl as a dedicated
  `receiver_mutation_chain`, preserving the frozen 4 valid / 14 invalid / 5 exclusion syntax boundary and exact
  authored Unicode-scalar spans. Arbitrary bang identifiers/functions/methods remain invalid.
- Added an original-shape, root-kind traversal runtime over a detached snapshot. Copied callback `value`,
  `path`/`@path`, `depth`, and `key|index` bindings produce replacement leaves; aggregate replacements are not
  revisited. Complete success publishes one detached rebuilt root atomically and returns another detached value.
- Guarded the actual receiver scalar-slot identity during callbacks. Direct assignment, nested write/bang,
  `set`, `set_key`, `push`, array-end methods, and binding-target array pipelines reject before writing; unrelated
  bindings and distinct same-spelling shadows remain legal. Failure leaves the receiver unchanged and releases
  the guard; ordinary continuation starts after commit.
- Signoff expansion caught the documented three-argument `split(target, source, delimiter)` statement taking an
  AST unsupported-helper route inside callbacks instead of the array-pipeline owner. Statement lowering now sends
  every binding-target pipeline spelling through that owner first; exact guard/span proof covers all eight names,
  all four array-end methods, and a composed pipeline.
- Applied the director-selected pure-function carrier correction: inline explicit-target `set` proves helper-
  mediated rejection and caller-scoped `.with` proves post-commit writes. No implicit caller capture or arbitrary
  user-defined bang method was added. The corrected composition corpus retains its observations at 592 mutations.
- Added permanent fixture-driven Perl projection. Fatal-warning focused proof passes 58 tests; neutral checkers
  pass 105 write and 167 base + 592 composition mutations; Phase 0 passes all 1,032 tests in 1,016 seconds.
  Rust/Dart/Julia/Lua, generated formats, capability/public admission, facades/schemas/MCP, and CLI remain unchanged.
- The complete record required a bounded change-history rollover. Immutable segment `4987` and ADR `0098` advance
  only finite collection/manifest capacity to 26/25; unchanged aggregate and byte ceilings remain below limits.
  This infrastructure movement upgrades the leaf to receipt-bound canonical verification.

## 2026-08-31 — FUTURE-PARITY-BACKLOG.19.2.2 — record function-scope contract blocker

- Activated the Perl `map_leaves!` leaf from clean `6b960624` and confirmed two future helper carriers assume
  caller binding capture forbidden by the admitted fresh function-local contract. Exact Perl proof keeps caller
  `tree`/`audit` unchanged; existing explicit-target `set` and caller-scoped `.with` can carry the intended proof.
- Recorded the unresolved director choice across task/index, ADR, Knowledge, roadmap, architecture, Toolbox,
  continuity docs, and mdBook. No contract fixture, parser, runtime, backend, capability, or public behavior moves.

## 2026-08-31 — FUTURE-PARITY-BACKLOG.19.2.1 — implement Perl write vivification

- Unified one- and many-segment bracket assignments on the Perl reference as expression-bearing
  `assign_nested_access` nodes. Every `path_segment` retains exact authored Unicode-scalar source/span; seven
  invalid forms now throw the frozen typed `action_parse` diagnostics.
- Added `LinkedSpec::BindingRuntime::nested_write`: evaluated strings select harrays, nonnegative integers select
  arrays, absent roots/intermediates are created only from those kinds, bound null/wrong kinds are conflicts, and
  dense arrays replace or append at length but reject gaps. Structural work is isolated and returned trees detach.
- Lowering evaluates all segments left-to-right and RHS once before snapshot/validation. Invocation-local presence
  state distinguishes absent Perl lexicals from explicit null in rules and user functions; parameters begin
  present and fresh function locals reset on every call. Same-binding expression effects retain frozen ordering.
- Added a fixture-driven permanent Perl contract covering all 5 AST / 7 syntax / 11 success / 16 structural
  failure cases plus detachment, dynamic scalar-kind fidelity, evaluation failure, same-binding composition, live
  bound-null, and function-local state. Focused suites, exact 1,032-subtest Phase 0, both neutral checkers, and
  signoff governance pass.
- Synchronized ADR `0036`, Knowledge, task/index, bounded live docs, and the sole-facing mdBook with an explicit
  transition boundary. Rust, Dart, Julia, and Lua remain non-vivifying; `map_leaves!`, capability/public admission,
  generated formats, facades, schemas, MCP, CLI, and non-Perl behavior do not move. Perl `.19.2.2` follows.

## 2026-08-31 — FUTURE-PARITY-BACKLOG.19.1.3 — compose neutral future mutations

- Added future-only `linkedspec-write-map-leaves-composition-v1`, digest-binding the unchanged write-vivification
  and `map_leaves!` authorities by contract identity and repo-relative path. Both existing checkers consume the
  shared fixture, so no executable entrypoint, temporary allocator, or project-data census changes.
- The write checker independently validates eight composed nested writes. The receiver-mutation checker executes
  six callback compositions plus one post-commit continuation and rejects 593 scalar/container-shape composition
  mutations while retaining all 105 write and 167 map base mutations.
- Frozen callback-local vivification and non-revisited replacement, unrelated write success/failure effects across
  receiver rollback, same-receiver guard precedence before segment/RHS evaluation, distinct same-spelling shadow
  identity, detachment, and continuation-side receiver-write failure after the bang commit and guard release.
- Exact current primary-command proof returns `{"leaf":[]}` for the non-bang control on Perl, Rust, Dart, Julia,
  PUC Lua, and LuaJIT. The bang form stops before callback nested-write lowering: Perl/Rust return null (Rust
  warns); Dart/Julia/both Lua ABIs exit at the generic parser-invocation boundary.
- Synchronized ADR `0036`, Knowledge, roadmap, architecture, capability/Toolbox guidance, task/index, bounded live
  continuity, and the sole-facing mdBook. No parser, compiler, runtime, current fixture/capability, generated
  format, facade, schema, MCP, CLI, or public-current behavior is admitted; Perl `.19.2.1` follows.

## 2026-08-31 — FUTURE-PARITY-BACKLOG.19.1.2 — lock neutral map_leaves mutation

- Added future-only `linkedspec-map-leaves-mutation-v1` and an independent backend-neutral parser/state-machine
  checker. The sole v1 bang token has a dedicated `receiver_mutation_chain` AST, exact authored Unicode-scalar
  spans, one bare resolved receiver binding, and explicit function/receiver/method/continuation exclusions.
- Frozen current root-kind traversal over a detached original-shape snapshot; copied callback `value`, `path`,
  `depth`, and `key|index`; callback-result replacement and subtree non-revisit; atomic rebind; detached result;
  and commit-before-continuation ordering.
- The active receiver identity rejects direct, nested-write, nested-bang, and helper-mediated writes before the
  attempt while allowing unrelated bindings and distinct same-spelling shadows. Callback/re-entrant failures
  preserve the receiver and prior unrelated effects; guard cleanup is explicit on every exit.
- Proof covers 4 valid syntax / 14 invalid / 5 exclusions / 10 successes / 8 pre-commit failures, continuation,
  shadow, guard release, non-bang isolation, detachment, and 167 rejected mutations. A valid action-edge control
  agrees on all five backends; its one-token bang twin remains unsupported at identifier-only parser boundaries.
- Added the checker to the project-routed tool census at 37 entrypoints with unchanged three Python temporary and
  15 shell allocator owners. This storage-governance movement fires the leaf's canonical verification tier.
- Synchronized ADR `0036`, Knowledge, roadmaps, architecture, capability/Toolbox guidance, task/index, live
  continuity, and the sole-facing mdBook. No backend parser/compiler/runtime, fixture, capability, generated
  format, facade, schema, MCP, CLI, or current public behavior is admitted; composition `.19.1.3` follows.

## 2026-08-30 — FUTURE-PARITY-BACKLOG.15.3 — repair Lua next fixture ownership

- Replaced the stale Lua runtime-control source `/skip/ { next() }` with action-edge-owned
  `-> Skip { next() }` plus `Skip: /skip/`. The old bare block now correctly means lifecycle `I`; before `.15.2`
  it was inert, so the test passed without exercising `next()`.
- The repaired fixture consumes `skip`, advances the enclosing rule iteration, and returns `keep` at cursor 8.
  Complete `lua/test/run.lua` passes 178/178 on PUC Lua and LuaJIT. The neutral standalone contract remains
  9 placements / 4 duplicate forms / 6 owners / 3 malformed twins / 6 routes / 14 mutations, and its shared Lua
  consumer passes 109 assertions on each ABI.
- No parser, compiler, runtime, neutral/public contract, generated format, capability, facade/schema/MCP, CLI, or
  mdBook behavior changes. The standalone lifecycle Knowledge owner now records the former false-positive cause.
- The mandatory engineering-notes record triggers content-addressed segment `4987`. ADR `0097` raises only finite
  collection capacity 20→21 files and manifest capacity 19→20 lines; all byte, root, segment, aggregate, owner,
  lifecycle, verifier, storage, and path controls remain unchanged.
- Canonical attempt one catches the committed `.19.1.1` write-vivification checker as Python tool entrypoint 36
  while the exact storage census still expected 35. The checker already uses the repository-routed wrapper and
  allocates no temporary workspace; the census and canonical Knowledge owner advance to 36 with the unchanged
  three Python temporary owners and 15 shell allocator owners.

## 2026-08-30 — FUTURE-PARITY-BACKLOG.19.1.1 — lock neutral write vivification

- Added future-only `linkedspec-write-vivification-v1` and an independent checker. One
  `assign_nested_access` AST now owns one/many expression-valued segments; five exact AST cases include authored
  Unicode-scalar spans, while seven syntax failures carry exact typed parser diagnostics.
- Frozen evaluated string/integer harray/array selection, absent-root/intermediate creation, bound-null and wrong-
  kind conflicts, dense replace/append/no-gap arrays, left-to-right segments then RHS, unchanged expression
  failures, post-evaluation same-binding snapshots, isolated commit, detached values, and pure reads.
- Proof covers 11 successes, 16 structural failures, three expression failures, three read exclusions, detachment,
  and 105 rejected mutations. Exact Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT probes preserve current non-vivification;
  no parser, compiler, runtime, capability, generated-format, facade, schema, CLI, or public-current state moved.
- Focused Lua proof exposed a stale `/skip/ { next() }` test that became lifecycle `I` under admitted `.15.2`.
  The correct runtime semantics remain unchanged; queued `.15.3` owns an action-edge fixture repair on both ABIs.
- Synchronized ADR `0036`, Knowledge, roadmaps, architecture, task/index, Toolbox, capability guidance, live
  continuity, and the sole-facing mdBook. `.19.1.2` remains the next mutation-contract leaf after `.15.3`.

## 2026-08-30 — FUTURE-PARITY-BACKLOG.23.2 — reconcile mdBook current status

- Reconciled current mdBook guidance with already-admitted executable contracts: semantic introspection 9/9/128
  and six runtimes; cursor/bare-edge 8/0; standalone lifecycle shorthand across five backends/six routes; logical
  helpers 8/0; all-five-backend attached/inline controls; root selection 7/0; and current named-slot/gap behavior.
- Preserved dated rollout evidence while removing present-tense Perl-only, pending-backend, dormant-Lua, required-
  root-marker, 50-mutation/no-backend, and pre-`.14.8` statements. Root governance now accurately reflects README
  routing at 24 documents / 18 denials rather than the dated 25/19 closeout boundary.
- Extended the narrow owners: cursor is 30 documents / 28 denials / 60 mutations; standalone lifecycle is
  15 / 7 / 14; logical helper is 19 / 14 / 26; root is 24 / 18 / 54; inter-match gap is 8 / 15 / 10 / 34; typed
  source remains 14/0/231; and capability conformance adds four structured-control projection mutations.
- Updated the typed gap mirror, roadmaps, architecture, task/index, Knowledge cards/map, live memory/status, and
  sole-facing book. Complete focused contracts, exact stale census, rendered-book review, all doctrines, and exact
  staged canonical CI pass without parser, compiler, runtime, fixture, generated-format, capability-state, facade,
  schema, semantic/MCP, CLI, or public API movement.

## 2026-08-30 — FUTURE-PARITY-BACKLOG.23.1 — restore selector migration contrasts

- Audited commit `ac217f6c` and the complete current public surface. Its broad selector migration correctly updated
  current examples but also collapsed seven deliberately historical examples in one mdBook migration section: two
  rejected source forms and five ordered old-to-new mappings.
- Restored exact `array(items)` / `hash(meta)` rejected examples and the five selector-to-bare-binding contrasts;
  all retired forms remain confined to explicit migration context and executable `.spec` inputs stay selector-free.
- Extended `tools/check_public_aggregate_selector_surface.py` with a unique bounded migration section, exact
  rejected-example block, five ordered non-identity pairs, selector-bearing old/selector-free new validation, and
  eleven in-memory omission, collapse, replacement, and reorder mutations.
- The composed authority passes at 61 public files / 32 classified historical references / zero current examples,
  zero executable positives / 20 classified implementation sites, five backend rejection routes, and capability
  90/0/0. No parser, compiler, runtime, fixture, generated format, capability row, or public API changes.

## 2026-08-30 — FUTURE-PARITY-BACKLOG.22.2 — enforce unique current task IDs

- Added `scripts/check_task_tree_current_ids.pl`, which inventories every exact current task definition across
  partitioned and unpartitioned `docs/tasks/*.md` storage. Only paths owned as immutable parts by tracked task-tree
  indexes are excluded; an arbitrary history filename remains current.
- Checker-first proof reproduced the sole conflict at `docs/tasks/RUST-FUNCTIONAL-PARITY.md:182/187`. Git assigns
  it to finalization commit `0e43f4ae`, which inserted a second completed `.7` parent instead of updating the
  original active parent.
- Collapsed the adjacent `.7` pair into one authoritative `done` definition at the same container position. Git
  retains the original event; no genuine historical task evidence was rewritten.
- Composed the new census through `TASK-TREE-METADATA`. Ten mutations cover same-file, cross-unpartitioned,
  partitioned/unpartitioned, multiple-duplicate, exact-line, safe-path, closed-index-registry, registered-history,
  and unregistered-history boundaries. Current proof is 1,718 definitions / 1,718 unique IDs across 96 files, with
  one registered immutable history file excluded; partition proof remains 596 stable IDs.
- Synchronized doctrine architecture, task workflow, Toolbox, Knowledge Map, roadmaps, current architecture,
  bounded continuity, task/index, and the sole-facing mdBook. Focused proof, all nine doctrines, rendered-book
  inspection, and exact staged canonical CI pass without product, fixture, format, capability, or public API change.

## 2026-08-29 — FUTURE-PARITY-BACKLOG.22.1 — enforce clean resume-pointer handoffs

- Reproduced a committed-state contradiction at pushed commit `b024ea3e`: `MEMORY.md` had the correct activation
  parent but still called completed `.22` staged/uncommitted and scheduled its commit/push again. The preceding
  `.13.1` commit retained the same defect class.
- Added `tools/check_memory_handoff_state.py` to resolve current `latest_completed_leaf` and `active_work_unit`
  task-tree statuses, reject completed/idle in-flight contradictions, and reject future landing actions for a
  completed active leaf.
- Added three valid active/completed/idle handoff fixtures and six destructive mutations; composed them through
  the existing `MEMORY-ARCH` doctrine and canonical gate required-file census.
- Updated the memory architecture, commit workflow, task-tree guide, doctrine catalog, Toolbox, roadmaps, live
  pointer/status, Knowledge Map, and sole-facing mdBook. The tool-storage census advances from 34 to 35 Python
  entrypoints with temporary ownership unchanged at three Python and 15 shell allocators.
- Checker calibration exposed conflicting current definitions of `RUST-FUNCTIONAL-PARITY.7` outside partitioned-
  tree uniqueness coverage. That separate metadata defect is queued under `.22.2`; this leaf only rejects an
  ambiguous status when a handoff pointer actually references it.
- Focused proof, all nine doctrines, an inspected/removed 15,864-KiB mdBook render, and exact staged canonical CI
  pass; the resulting clean pushed handoff names `.22.2` without retaining `.22.1` landing work.

## 2026-08-29 — FUTURE-PARITY-BACKLOG.22 — govern stable task-index closeout markers

- Added one registry-backed task-index guard covering 8 closed-capability families, 12 exact markers, and all 15
  discovered code/contract consumers. Every marker must remain inside one sentinel-delimited stable section and
  outside the mutable active-tree surface.
- Added four built-in mutations: arbitrary `FUTURE-PARITY-BACKLOG` frontier-row replacement remains valid, while
  repeated-action deletion, repeated-action relocation into the active row, and callable-marker deletion fail.
- Composed the guard through the existing `TASK-TREE-METADATA` doctrine and synchronized its registry,
  enforcement architecture, task-tree guide, Toolbox, roadmaps, Knowledge Map, and sole-facing mdBook teaching.
- Removed repeated-action's historical `FUTURE-PARITY-BACKLOG.10.1` assertion from overwrite-only `MEMORY.md`;
  the checker still validates that handoff in its immutable task-tree owner.
- Advanced the project-data oracle only from 33 to 34 Python tool entrypoints; temporary ownership remains three
  Python allocators and 15 shell allocators.
- Focused dependent proof, an inspected 81-file mdBook render, all nine doctrines, and the exact staged canonical
  boundary pass; the reproducible book output is removed before commit.

## 2026-08-29 — FUTURE-PARITY-BACKLOG.13.1 — restore the codegen inspector

- Reproduced the raw/lifecycle/action inspector failure: stale private calls on the thin `LinkedSpec` facade fell
  through plugin AUTOLOAD as unknown `_rewrite_action_code_with_diagnostics` or `_render_method_call_chain` names.
- Routed fluent-chain rendering directly through `LinkedSpec::BootstrapSpec::Core` and lowering/diagnostics through
  `LinkedSpec::RuleIR::EmitContext`, matching current ownership without widening the public facade.
- Added `t/inspect_spec_codegen.t` and canonical registration. The smoke locks explicit owner source calls and runs
  raw helper, lifecycle block/chain, and action-edge block/chain inputs, requiring generated Perl, canonical IR,
  zero raw fallback, zero unresolved helpers, and no plugin dispatch.
- Updated Toolbox, roadmap/live/Knowledge continuity, and the mdBook with repeatable inspection examples.
- The exact staged canonical gate admitted the new mdBook page into the governed aggregate-selector public census;
  its exact inventory is now 61 files with the same 25 classified historical references and zero current examples.
  The composed executable scan also reconciles its durable census to zero positives / 20 classified occurrences;
  the added occurrence is the already-governed Lua semantic compilation-failure fixture from commit `c8501d3a`.

## 2026-08-29 — FUTURE-PARITY-BACKLOG.15.2 — close standalone lifecycle-block parity

- Dart, Julia, and shared Lua now parse a rule-item-leading `{ ... }` directly as lifecycle `I`, preserving actual
  authored source/opening line and explicit-twin ActionIR semantics. PUC Lua and LuaJIT prove the shared route.
- Validation now retains exact outer block source for quote-aware balance checks and rejects explicit/bare missing
  closes, unmatched closes, and unmistakable same-line remainder at the same backend boundary. Dart and Julia
  preserve only genuinely unsupported lifecycle suffixes, so a recognized compact rule-header tail cannot mask an
  earlier typed action diagnostic.
- Added Dart 6-test, Julia 103-assertion, and Lua 109-assertion-per-ABI neutral consumers covering nine placements,
  provenance, all four duplicate forms, earlier brace owners, malformed twins, reconstructed/generated carriers,
  and inert legacy plain nodes/payloads.
- Added the permanent self-hosted standalone production plus complete-line lifecycle precedence in canonical
  `specs/spec.spec` and its four exact corpus mirrors. All seven reserved markers remain lifecycle nodes;
  explicit/bare `I` projections are semantically equal while retaining source-form provenance.
- Added `tools/check_standalone_lifecycle_block_five_backend.sh`, its 11-mutation neutral checker, canonical CI
  registration, and the all-pass `language.standalone_lifecycle_block` capability row. The census is now 90/0/0;
  the project-data and routing oracles freeze 33 Python tool entrypoints and the routed driver as shell owner 15.
- The mandatory complete-record rollover adds content-addressed change segment `4988`; ADR `0096` advances only
  finite collection capacity 24→25 files and manifest capacity 23→24 lines, retaining every byte and aggregate cap.
- Updated ADR `0094`, Knowledge, roadmaps, architecture, public/backend guides, capability guidance, the sole-facing
  mdBook, task/index, and bounded continuity. Parent `.15` is closed.
- Narrowed the Phase 0 bootstrap function-ownership guard to structural node identities, so lifecycle `ICODE`
  source may contain ordinary identifiers without weakening the ban on bootstrap-owned function-definition nodes.
