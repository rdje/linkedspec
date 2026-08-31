# CHANGES

This stable path is the bounded current change hot shard. Exact accepted history through atomic 178/300 is
immutable and repository-local; new accepted slices are prepended here as complete `## ` records.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/changes/manifest.jsonl`](docs/history/changes/manifest.jsonl)
- Read all archived history: `perl tools/read_document_history.pl --surface change_history --all`
- Search archived history: `perl tools/read_document_history.pl --surface change_history --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface change_history --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface change_history --apply`

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

## 2026-08-29 — FUTURE-PARITY-BACKLOG.15.1 — implement Perl/Rust standalone lifecycle blocks

- Added neutral contract `linkedspec-standalone-lifecycle-block-v1` for OR/AND, zero/one/two-regex and same-line
  placement, exact source/opening-line provenance, ActionIR span equality, all explicit/bare duplicate mixtures,
  brace ownership, malformed twins, generated carriers, and inert legacy plain data.
- Perl validation now admits rule-item-leading `{ ... }`; the bootstrap uses its existing nested/string-aware brace
  scanner to emit `ICODE` with semantic marker `I`, actual `bare`/`explicit` provenance, source, and opening line.
  RuleIR/runtime ABI and placement-sensitive lowering remain unchanged.
- Rust source parsing now emits lifecycle `CodeBlock(I)` directly instead of `PlainBlock`, retains exact outer
  block source so missing closes remain visible, and preserves only a same-line unsupported lifecycle remainder
  for typed rejection. Unrelated legacy `Raw` carriers retain their existing compatibility behavior.
- Rust compilation now appends repeated `I` statements into the existing preamble option. This fixes the audited
  last-`I`-wins defect without changing `CompiledSpec` shape or the spans parsed inside each authored block.
- Perl and Rust execute explicit/explicit, explicit/bare, bare/explicit, and bare/bare fixtures in authored order
  as `first-second`; Perl standalone generated source and Rust native/serialized/emitted/generated paths agree.
- Locked action, blind, resolved bare-edge, function, contextual callable, nested, and quoted-brace ownership.
  Missing close, stray close, and unmistakably unsupported `???` remainder reject as explicit/bare twins; valid
  same-line body successors remain accepted.
- Focused Perl proof passes 324 tests across ActionIR, generated source, rule-local cursor, and the new contract.
  Rust passes 32 parser unit tests plus all eight new contract tests; formatting and whitespace checks are clean.
- Updated ADR `0094`, [[standalone-lifecycle-block-audit]], roadmaps, architecture, task/index, bounded continuity,
  and the sole-facing mdBook to say Perl/Rust are current while Dart/Julia/Lua/self-hosted/public `.15.2` remains.

## 2026-08-29 — FUTURE-PARITY-BACKLOG.15.0 — ratify standalone lifecycle-block normalization

- Audited the Perl reference, Rust, Dart, Julia, shared Lua on PUC Lua/LuaJIT, and the self-hosted grammar before
  behavior code. Perl rejects a rule-item-leading `{ ... }`; Rust drops its parsed `PlainBlock`; Dart/Julia/Lua
  keep only inert plain payload metadata. Two explicit `I` blocks execute in authored order except for an existing
  Rust compiler last-slot-wins defect.
- Accepted ADR `0094`: a bare rule-item block will normalize during source parsing directly to lifecycle `I` at
  the same position, preserve actual source/opening-line provenance and explicit-twin ActionIR spans/diagnostics,
  add no runtime phase, and leave attached edge, function/callable, nested, and quoted braces with their owners.
- Kept legacy programmatic/serialized plain nodes inert during rollout. `.15.1` exclusively owns Perl/Rust plus
  Rust duplicate-order repair; `.15.2` owns Dart/Julia/Lua, both Lua ABIs, self-hosted reserved-label precedence,
  generated/public teaching, and final no-drift.
- Corrected the mdBook's premature current-tense claim: authors must write `I { ... }` until implementation lands.
  Added [[standalone-lifecycle-block-audit]] and synchronized roadmaps, architecture, Toolbox, task/index, and
  bounded continuity without changing parser/compiler/runtime/test/fixture/generated-format or public behavior.

## 2026-08-28 — FUTURE-PARITY-BACKLOG.14.8 — close typed authoring-model public no-drift

- Completed only the existing `recurring_public_no_drift` row, preserving the accepted 14-row ledger and moving
  typed governance from 13/1/189 to 14/0/231.
- Added one repository-routed composed driver over the six existing typed-source, recognition-transaction,
  recursive-observation, typed-gap, progressive-span, and staged-AST recurring authorities. Each remains its
  lane's sole behavior/runtime oracle.
- Locked eight current projections, eight stale-current denials, six helper/cursor safety denials, and ten outward
  guards. Internal `capture_take_slice*` ids remain non-authored; compatibility cursor controls remain non-
  transactional.
- Added canonical opt-in `LINKEDSPEC_RUN_TYPED_AUTHORING_MODEL_MATRIX=1` and synchronized ADR `0056`, Knowledge,
  both roadmaps, architecture, Toolbox, capability guidance, bounded continuity, and the sole-facing mdBook.
- Canonical doctrine/contract traversal exposed the staged-public checker's one pre-closeout book marker. Updated
  only that required current-projection literal to 14/0/231; its 129 mutations and behavior authority stay exact.
- Parser/compiler/runtime/value/helper/carrier/generated-format/facade/schema/semantic/MCP/capability/CLI/storage
  behavior and the root README remain unchanged.

## 2026-08-28 — FUTURE-PARITY-BACKLOG.14.7.10 — close general staged AST recomposition

- Independently reran the committed staged authority unchanged: neutral/public 9/9/123 plus 6/17/10/129,
  Perl 143, Rust 1 with a fresh emitted carrier, Dart 19, Julia 491, Lua 890 per ABI, typed 13/1/189,
  generated/capability 85/0/0, and language 250/105+1/126 all pass.
- Audited every current ADR/Knowledge/roadmap/architecture/Toolbox/capability/book/live projection. ADR `0088`'s
  live inventory alone retained 128 public mutations after public-admission canonical CI added mutation 129; its
  dated closeout evidence and executable checker were already exact. Corrected the live count without rewriting
  historical evidence.
- Added [[general-staged-ast-enrichment-recomposition]] and synchronized current projections, parent/frontier,
  bounded continuity, and the sole-facing mdBook. Parent `.14.7` is closed; `.14.8` retains the single combined
  typed public-no-drift row.
- Exact comparison from public-admission commit `692cd896` proves no production, consumer test, fixture,
  executable governance, CI topology, generated format, capability manifest, dependency/toolchain,
  storage/doctrine, public behavior, or unrelated outward owner moves.

## 2026-08-28 — FUTURE-PARITY-BACKLOG.14.7.9 — admit portable parse_job authoring

- Made only exact scalar assignment-form `target = parse_job(source_bound_text, hash(literal options))` public
  through the already-admitted dedicated `STAGED_PARSE_JOB_MARKER` / `staged_parse_job_v2` carrier and
  caller-frozen already-compiled authority.
- Declared the dedicated extension in `specs/spec.spec` while keeping `parse_job` outside the 250-name ordinary
  generic-helper inventory. Residual, nested, dynamic, callback, path/URI, provider, compilation, and registry-
  mutation interpretations remain fail-closed.
- Mirrored that comment-only declaration into the four existing exact canonical `spec_spec_*` corpus copies after
  canonical CI correctly rejected the first stale hash; corpus behavior and every other fixture byte remain
  unchanged.
- Added executable public governance over six documents, 17 stale-claim denials, ten unrelated outward paths, all
  37 portable diagnostic codes, and 129 reason-checked mutations; neutral governance remains 123 mutations and
  staged rollout becomes 9/9.
- Corrected the language inventory's raw-corpus reverse scan after canonical CI proved that the four required
  comment mirrors made it misread `parse_job(` as an ordinary helper call. Explicitly classified dedicated,
  internal, legacy, and compatibility forms are now excluded from that ordinary-generic reverse inventory, and
  the staged mutation oracle independently deletes the exclusion guard.
- Renamed the capability to current `language.staged_ast_enrichment`, retained 17 rows / 85 pass states, and
  removed the satisfied `future.general_parse_job_authoring` exclusion. Only the legacy Perl plugin exclusion
  remains; capability governance is 19 mutations plus six public mutations.
- Advanced typed projection governance from 187 to 189 mutations while preserving 13 complete / one pending;
  `.14.8` still owns the single combined typed public-no-drift row.
- Updated the five staged consumers only in aggregate status/rollout/availability snapshots. Every behavioral
  assertion and parser/compiler/runtime/carrier byte, function-body v1, generated format, unrelated facade/schema/
  semantic/MCP/CLI/root-README surface, dependency/toolchain, and storage/doctrine owner remains unchanged.
- Added [[portable-parse-job-public-authoring]] and synchronized ADR `0088`, Knowledge, roadmaps, architecture,
  Toolbox, capability guidance, bounded continuity, task/index, memory, and the sole-facing mdBook with syntax,
  options, policies, diagnostics, and authority examples.
- Focused proof passes the exact six-runtime driver: Perl 143, Rust 1 in 339.15 seconds, Dart 19, Julia 491, and
  Lua 890 per ABI; typed 13/1/189, progressive 9/9/116 plus public 60, recognition 138/250/58, semantic 6/20/128,
  generated/capability 85/0/0, language coverage, routing, README/memory, Knowledge 909/7,733, and mdBook pass.

## 2026-08-28 — FUTURE-PARITY-BACKLOG.14.7.8 — bind staged enrichment recurring proof

- Added `tools/check_staged_ast_enrichment_six_runtime.sh`, one repository-routed fail-fast composition of the
  neutral oracle, Perl, Rust, Dart, Julia, PUC Lua, LuaJIT, typed source, generated source, capability, language,
  and exact function-body-v1 compatibility proof.
- Registered the driver in project-data routing and behind the sole explicit canonical opt-in
  `LINKEDSPEC_RUN_STAGED_AST_ENRICHMENT_MATRIX=1`; tracked-path, syntax, path, switch, and invocation topology is
  reason-checked.
- Completed only the neutral `recurring` rollout row and bound five immutable backend source groups to six ordered
  routes. Seventeen topology/status/storage/rollout mutations advance neutral governance from 106 to 123.
- Updated the five consumers only in lockstep aggregate governance snapshots. Behavioral assertions, fixtures,
  parser/compiler/runtime code, function-body v1, generated format, public authoring/inventory, and outward
  surfaces do not move.
- Promoted only typed `staged_dispatch`, advancing typed governance from 12/2/170 to 13/1/187, and added the
  corresponding all-pass `language.private_staged_ast_enrichment` capability row, advancing 80 to 85 pass cells.
- The exact driver passes Perl 143/143, Rust 1/1 with a fresh emitted carrier, Dart 19/19, Julia 491/491, and Lua
  890/890 per ABI. Progressive 9/9/116, recognition 138/250/58, semantic 6/20/128, generated 85/0/0, capability
  85/0/0, language coverage, outside-CWD routing, README pressure, memory, Knowledge, mdBook, and all nine
  doctrines pass.
- Added [[staged-ast-enrichment-recurring-gate]] and synchronized roadmaps, architecture, Toolbox, capability
  guidance, typed facts, task/index, bounded continuity, and the sole-facing mdBook. Public `parse_job(...)`
  authoring remains owned by `.14.7.9`; combined typed public no-drift remains owned by `.14.8`.
- Exact staged receipt-bound canonical CI passes before the atomic commit and clean handoff to `.14.7.9`.

## 2026-08-28 — FUTURE-PARITY-BACKLOG.14.7.7.5 — close shared Lua staged enrichment

- Independently reran the unchanged shared staged carrier at 888/888 on PUC Lua and 888/888 on LuaJIT from exact
  clean admission commit `97bfbac6`.
- Reproved complete ordinary Lua at 178/178 per ABI, both 66/66 CLI environments, the 105-case corpus, and
  repository-local 19-owner/three-native-module storage with exactly one staged-consumer execution per host.
- Reproved native, reconstructed, generated-plan, and independently loaded emitted equality, fresh authority,
  detached results, and generated/emitted authority absence. Exact topology remains one tracked canonical path,
  one route per ABI, two ordinary references total, and no inline duplicate.
- Reran admitted Perl 143/143, Rust 1/1 with its emitted carrier in 268.47 seconds, Dart 19/19, and Julia 491/491.
  Neutral staged governance remains five source consumers/six routes/106 mutations.
- Kept typed 12/2/170, recognition 138/250/58, progressive 9/9/116 plus public 60, semantic 6/20/128,
  generated/capability 80/0/0, language 250/105+1/126, and public aggregate-selector no-drift exact.
- Added [[lua-staged-ast-enrichment-recomposition]] and synchronized current admission/neutral/lockstep facts,
  ADR `0088`, roadmaps, architecture, Toolbox, task/index, bounded continuity, and the sole-facing mdBook.
- Closed parent `.14.7.7` unchanged and handed the frontier to recurring proof `.14.7.8`. Exact base-relative
  guards prove no production, test, fixture, executable contract/checker, ordinary/canonical topology, generated
  format, public/outward, dependency/toolchain/storage/doctrine, or other-backend behavior byte moved.
- Knowledge regeneration, mdBook rendering/removal, bounded-history checks, all nine doctrines, and exact staged
  receipt-bound canonical CI pass for the documentation-only closeout.

## 2026-08-27 — FUTURE-PARITY-BACKLOG.14.7.7.4 — admit Lua staged enrichment carriers

- Preserved every Lua production/carrier byte and all 888 behavioral assertions in the one shared Lua-5.1-
  compatible consumer.
- Registered that stable path exactly once through ordinary PUC Lua and exactly once through ordinary LuaJIT;
  the inline TAP suite omits it, preventing duplicate discovery.
- Added one canonical tracked-path requirement plus one exact repository-routed marker/invocation per ABI.
- Promoted only the shared Lua backend lifecycle and rollout rows six/seven. Eight exact topology mutations raise
  neutral governance from 98 to 106; recurrence and public rows remain pending.
- Updated admitted Perl/Rust/Dart/Julia current snapshots without changing their behavior. Focused proof passes
  Perl 143/143, Rust 1/1 in 323.52 seconds, Dart 19/19, Julia 491/491, and Lua 888/888 per ABI.
- Complete ordinary Lua passes 178/178 on both ABIs and visibly executes the staged consumer once per host. Typed,
  recognition, progressive, semantic, generated, capability, and language direct-dependent ledgers remain exact.
- Added [[lua-staged-ast-enrichment-carriers-admission]] and synchronized ADR `0088`, neutral/current/admitted
  facts, roadmaps, architecture, Toolbox, task/index, bounded continuity, and the sole-facing mdBook.
- Knowledge regenerates at 906 facts / 7,707 keys. The book renders 80 files / 15,728 KiB with the admitted
  topology, and generated output is removed. Production, function-body v1, generated-source v2, capability,
  public/outward behavior, other backends, dependencies/toolchains/storage/doctrines, and later recurrence do not
  move.
- The exact fully staged candidate clears receipt-bound canonical CI and its nine-doctrine pre-commit validation.

## 2026-08-27 — FUTURE-PARITY-BACKLOG.14.7.7.3 — implement Lua staged recursive carriers

- Preserved the private one-depth API and added a separate Lua-5.1-compatible breadth-first scheduler that
  prepares complete depths and queues only markers found in successful detached child results at their exact
  replace/field/sibling/append destinations.
- Added exact parser/top/payload-digest/full-provenance active frames, exact-cycle denial, and same-parser/top
  recurrence only under segment containment plus strictly smaller total Unicode-scalar extent.
- Added one non-resetting invocation authority for cancellation, caller clock/absolute deadline, steps, seeded
  calls, depth/call maxima, cumulative atomic-marker result nodes, and canonical UTF-8 diagnostic bytes. Fresh
  callback contexts expose safe points and direct/ordered-derived source projection, then expire after settlement.
- Added an opaque host-only execution seed after complete parent execution. Native, `SpecFile`-JSON reconstructed,
  validated generated-plan, and independently loaded emitted routes build fresh callback/registry/cache/resource/
  queue state per run while preserving no-seed behavior and primary staged exceptions.
- Advanced the stable dormant consumer to 888/888 independently on PUC Lua and LuaJIT. Four routes execute twice
  with eight equal detached results, fresh authority observations, one miss/no hits/one call per execution,
  parent-failure and transaction boundaries, cumulative resource adversaries, rebasing, and authority absence.
- Kept the consumer absent from ordinary and canonical discovery. Neutral governance remains 98 mutations; both
  Lua rollout rows, function-body v1, generated-source-v2 format, public/outward behavior, other backends, and
  later recurrence remain unchanged for `.14.7.7.4+`.
- Added [[lua-staged-ast-enrichment-recursive-carriers]] and synchronized ADR `0088`, roadmaps, architecture,
  Toolbox, task/index, bounded live records, memory, and the sole-facing mdBook.
- Complete ordinary Lua passes 178/178 suites per ABI plus 105/105 corpus, both CLI environments, and the 19-
  owner/three-native-module storage proof. Neutral staged and all admitted backend projections pass; typed,
  recognition, progressive, semantic, generated, capability, language, and public-boundary ledgers remain exact.
- Knowledge regenerates at 905 facts / 7,699 keys and the book renders 80 files / 15,724 KiB. Bounded histories,
  README/memory/task invariants, nine doctrines, exact scope guards/diff, and receipt-bound canonical CI pass.

## 2026-08-27 — FUTURE-PARITY-BACKLOG.14.7.7.2 — implement Lua staged current-depth authority

- Added separate private Lua-5.1-compatible `staged_ast_enrichment.lua`. Its opaque frozen registry deeply owns
  caller-completed alias/declaring-relative/ordered-root/provider outcomes and an exact already-compiled callback
  set; post-AST resolution performs no discovery, loading, provider query, compilation, path, network, environment,
  or registry-mutation work.
- Implemented selected/default-top-before-v2 job identity, exact eight-field immutable-plan caching, complete-
  depth marker/target preparation before callback one, typed path/provenance/job ordering, and fresh sibling
  cursor/mark/capture/variable contexts.
- Added detached unpublished-copy stitching for `replace_marker`, `replace_field`, `sibling_field`, and ordered
  shared `append_child`, plus `fail`, `keep_text`, and `diagnostic_node`. Cross-plan conflicts, stale or wrong-kind
  targets, callback throws, cycles, nonfinite/live results, and marker-shaped authority smuggling fail closed.
- Advanced the shared dormant consumer on PUC Lua and LuaJIT to 597 GREEN assertions and one identical
  `.14.7.7.3` breadth-first recurrence/bounds/rebasing/fresh-carrier RED. Returned valid markers remain inert.
- Complete ordinary Lua passes 178/178 suites on both ABIs. Neutral governance remains 98 mutations; Perl passes
  143/143, Rust 1/1 in 358.59 seconds, Dart 19/19, Julia 491/491, and all typed/recognition/progressive/semantic/
  generated/capability/language ledgers retain their exact snapshots.
- The mandatory complete-record rollover adds one content-addressed change segment. ADR `0093` authorizes only
  the exact resulting 23→24-file and 22→23-manifest-line capacity step; all byte, aggregate, per-member, owner,
  lifecycle, verifier, route, and storage controls remain unchanged.
- Synchronized task/index, ADR, Knowledge, roadmaps, architecture, Toolbox, live records, memory, and the sole-
  facing mdBook while preserving recursion/carriers, discovery, rollout, function-body v1, generated format,
public/outward behavior, and other backends.
