# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`
- 2026-08-30 (`FUTURE-PARITY-BACKLOG.23.2` — mdBook current-state reconciliation): Knowledge Map and indexed
  live-history retrieval preceded source archaeology for semantic introspection, rule-local cursor/bare edges,
  standalone lifecycle shorthand, logical helpers/truthiness, structured controls, root selection, and adjacent
  named-slot/gap/typed-source prose.
- Git provenance showed the stale pages were accurate at their creation boundaries but escaped later closeout
  sweeps: cursor text stopped at Perl or Perl/Rust, standalone pages stopped at `.15.1`, named slots/gaps stopped
  before Lua/public language admission, structured controls stopped at Round 2 Perl/Rust, and root constraints
  stopped before Lua topology/final admission. The descriptor page's exact former 50-mutation/no-backend sentence
  was recovered from pre-closeout history; current semantic teaching was already correct.
- Root's apparent 25/19 mismatch was not a runtime defect. README-STABILITY-POLICY.1 intentionally removed root
  README and two denials, making the live projection 24/17. The formal-grammar stale-marker denial makes current
  truth 24/18; original 25/19 evidence remains dated. A similar audit corrected logical public metadata to 19/14.
- Exact owner expansion is omission-sensitive: cursor adds two pages/three denials; standalone adds two pages,
  seven denials, and three public-text mutations; gap adds two pages/three denials/five mutations and updates the
  typed upstream mirror; semantic and logical append exact stale denials without changing 128/26 totals; typed
  public denials replace nonmatching variants while preserving 14/0/231; capability conformance adds four
  `language.current_mdbook_surface` mutations tied to five all-pass backend states.
- The first whole-book build renders the corrected headings, tables, paragraphs, examples, and navigation. The
  in-app browser control surface was unavailable, so rendered HTML was inspected directly for exact current
  markers and stale-claim absence. No production/runtime/fixture/generated-format/outward files move.
- The first doctrine run exposed that `docs/knowledge/typed-source-location-runtime-rollout-plan.md` already sat at
  65,530/65,536 bytes. Its duplicate gap-mirror note was removed and retained in the smaller canonical composition
  card; the hard pressure gate is green, but any future edit to that rollout-plan card must split or reroute it.
- Focused owners, Knowledge Map, task metadata/index, bounded histories, memory architecture, all nine doctrines,
  whitespace, final book build/render, and receipt-bound canonical local CI form the closeout proof. Parent `.23`
  closes; `.19.1.1` is the next clean roadmap-aligned implementation frontier.
- 2026-08-30 (`FUTURE-PARITY-BACKLOG.23.1` — aggregate-selector migration-contrast repair): the pre-change public
  checker passed 61 files / 25 classified references / zero current examples while the sole migration paragraph
  taught two “retired” bare forms and five identity rewrites. Count/context validation could not express meaning.
- `git show ac217f6c^:docs/linkedspec-book/src/dsl/values-containers-and-flow-helpers.md` recovers the exact seven
  intended historical forms. The rest of that commit's selector replacements are legitimate current authoring and
  remain bare; no broad revert is warranted.
- The repair bounds the one migration section by unique start/end anchors, requires its exact two-form rejected
  block and five ordered old-selector-to-bare-binding pairs, and separately rejects identity, selector-free old
  sides, selector-retaining replacements, omission, wrong replacement, and reordering through eleven mutations.
- Retired fixture spellings are assembled from split tokens inside the Python checker so the unchanged executable-
  source scanner cannot mistake negative contract data for runnable `.spec` source. The final composed proof is
  61/32/0 public, zero-positive/20-classified executable, five-backend rejection, and capability 90/0/0.
- `.23.1` changes documentation semantics and governance only. `.23.2` retains every broader current-status claim
  found by the startup review and the canonical parent-closeout boundary.
- 2026-08-30 (`FUTURE-PARITY-BACKLOG.22.2` — repository-wide current task-ID uniqueness): the `.22.1` memory
  checker deliberately treated conflicting task statuses as ambiguous and queued the broader defect. The initial
  exact census found 1,719 definition lines / 1,718 unique IDs; only `RUST-FUNCTIONAL-PARITY.7` was duplicated.
- `git log -S` narrows the event to creation commit `662b642c` and finalization commit `0e43f4ae`. Exact before/after
  inspection shows `.7` already existed as `active`; finalization inserted a second identical parent as `done`
  immediately below it instead of updating the original status.
- The repair collapses the adjacent pair into one `done` parent at the same container position. This does not erase
  history: Git remains the event store, while the task file is the one current authoritative tree.
- `scripts/check_task_tree_current_ids.pl` scans all regular nonsymbolic `docs/tasks/*.md` files and exact
  definition lines. It derives exclusions from tracked `*.index.jsonl` metadata and requires the matching
  `task_tree_part` record to carry JSON boolean `mutable: false`; suffix naming alone grants no exemption.
- This classification matters because partitioned `FUTURE-PARITY-BACKLOG` has an immutable positive-evidence
  archive that legitimately repeats historical IDs. Counting that archive as current would be wrong; excluding
  every `.history.md` by name would create a hiding place. Index-backed immutability is the narrow stable boundary.
- Ten in-memory mutations cover unique fixtures, same-file duplicates, cross-unpartitioned duplicates,
  partitioned/unpartitioned duplicates, multiple IDs, exact-line recognition, safe history-path shape, the closed
  tracked-index registry, registered-history exclusion, and unregistered-history inclusion. The current result is
  1,718/1,718 across 96 files plus one registered immutable history exclusion.
- The existing `scripts/check_task_tree_partitions.pl` remains the deeper owner for FUTURE source ranges, digests,
  lookup, immutability, and in-partition uniqueness. The new checker composes after it and supplies only the missing
  repository-wide current-definition relation; no second doctrine registry row is needed.
- No LinkedSpec parser/compiler/runtime, `.spec`, fixture, generated format, backend capability, or outward API
  changes. Durable synchronization covers task/index, Knowledge, doctrine catalog, task guide, Toolbox, roadmaps,
  architecture, bounded live memory/status, and sole-facing development/status book teaching.
- 2026-08-29 (`FUTURE-PARITY-BACKLOG.22.1` — clean handoff semantic enforcement): immediate post-push inspection
  of `b024ea3e` found that activation ancestry was exact while all three operational fields were stale: `.22` was
  still called staged, `next_action` still scheduled its commit/push, and `in_flight_uncommitted` still described
  its candidate as uncommitted. The same shape existed in the preceding `.13.1` commit.
- `COMMIT.md` already required the staged pointer to describe the intended clean post-landing state. The actual
  gap was mechanical: `scripts/check_memory_architecture.sh` enforced only line capacity, activation ancestry, and
  layer/bootstrap presence, so correct parent identity masked incorrect operational meaning.
- `tools/check_memory_handoff_state.py` parses the four required operational fields and resolves their backticked
  leaf IDs against current `docs/tasks/*.md` definitions. `latest_completed_leaf` must be complete. An idle pointer
  must have no in-flight work. A completed active leaf may not retain pre-landing wording, nonempty in-flight work,
  or a same-leaf next action that schedules staging, committing, landing, or pushing.
- Three valid fixtures preserve legitimate in-progress, completed-clean-awaiting-selection, and idle-clean states.
  Six mutations reject a completed staged description, repeated landing action, completed in-flight work, a non-
  done latest completion, idle in-flight work, and a referenced ambiguous status. The checker runs via repository-
  routed Python inside the existing memory doctrine, owns no temporary allocation, and advances only the Python
  entrypoint census from 34 to 35.
- Repository-wide status discovery deliberately tolerates unrelated duplicate definitions but marks conflicting
  statuses ambiguous; validation fails if a pointer references such an ID. This boundary was required because
  calibration exposed two current `RUST-FUNCTIONAL-PARITY.7` definitions (`active` then `done`) in one legacy
  unpartitioned task file. `.22.2` now durably owns the global definition census/repair and metadata guard rather
  than widening `.22.1` or silently classifying the contradiction away.
- 2026-08-29 (`FUTURE-PARITY-BACKLOG.22` — stable task-index closeout ownership): consumer discovery finds 15
  code/JSON owners across logical-helper, root-selection, duplicate-slot, rule-local-cursor, repeated-action,
  callable-codeblock, capability-exclusion, and semantic-introspection contracts. Together they require 12 exact
  `docs/TASK_TREE.md` marker fragments.
- The active task table is intentionally overwrite-style. Several markers already had an ad-hoc stable section,
  but no sentinel/location/census invariant existed; semantic introspection still succeeded only through later
  chronology, and repeated-action separately searched bounded `MEMORY.md` for an immutable historical handoff.
- `tools/check_task_tree_closed_capability_markers.py` makes the section explicit, rejects any registered marker in
  the mutable active surface, exact-compares discovered and declared consumers, and requires each consumer to
  retain all family markers. Its mutation proof permits a synthetic active-row rewrite without copied history and
  rejects repeated-action deletion/relocation plus an independent callable deletion.
- The repeated-action contract continues to validate next owner `FUTURE-PARITY-BACKLOG.10.1` in immutable
  `docs/tasks/FUTURE-PARITY-BACKLOG.10.0-6.md`; deleting the redundant `MEMORY.md` lookup restores layer-A memory
  to current resume state without weakening closure evidence or the JSON mutation.
- The checker runs through `tools/run_python_project_data.sh` under the existing task metadata doctrine and owns
  no temporary allocation. Tool-storage truth is therefore 34 Python entrypoints, three Python temporary owners,
  and 15 shell allocation owners.
- Focused signoff passes every affected contract family at unchanged closure counts, all nine doctrines, and an
  81-file / 15,860-KiB mdBook render whose new HTML paragraph was inspected before exact generated-output removal.
  The exact staged canonical candidate then passes as the required governance/doctrine and push boundary.
- 2026-08-29 (`FUTURE-PARITY-BACKLOG.13.1` — codegen-inspector owner repair): five independent pre-change probes
  reproduced exact `PPlugin::exec_plugin_name` failures. Raw, lifecycle block, and action-edge block paths named
  `_rewrite_action_code_with_diagnostics`; lifecycle/action-edge chains named `_render_method_call_chain`.
- Git/source correlation confirms the inspector arrived in `2984fb50`; Phase 1A `e964d9a4` removed the dead
  facade wrappers but did not update the tool. The live functions remained in `RuleIR::EmitContext` and
  `BootstrapSpec::Core`, and existing focused tests already treat those packages as explicit internal owners.
- The repair keeps `LinkedSpec` initialization but directly loads/calls only those two owners. It does not restore
  a facade wrapper, expose an unrelated public API, duplicate parsing/lowering, or alter generated runtime code.
- The recurring smoke inspects all five raw/block/chain variants in one child invocation and also source-locks the
  two owner calls. Focused syntax, smoke, ActionIR parser, and trace-pipeline tests pass.
- The first exact staged canonical attempt reached public aggregate-selector admission and correctly rejected its
  stale 60-file cardinality after the new inspector chapter became file 61. The checker and its three canonical
  Knowledge owners now lock 61/25/0 without weakening discovery, classification, or selector retirement.
- The composed executable scanner simultaneously reported 20 classified occurrences rather than the durable
  19-count prose. `git blame` plus `git show c8501d3a` locate the delta: `.10.7.2.2` added one intentionally rejected
  Lua semantic-index compilation-failure fixture and its exact scanner classification on 2026-07-26. Current
  Knowledge now says zero positive / 20 classified while retaining 19 as the accurate July 12 historical result.
- 2026-08-29 (`FUTURE-PARITY-BACKLOG.15.2` — complete standalone lifecycle parity): Dart, Julia, and Lua parser
  branches now lower bare blocks into their existing ordered lifecycle-`I` node shape instead of `PlainBlock`.
  Exact source includes the marker only when authored; code continues to use the explicit parser's normalized
  interior, so ActionIR AST/spans match while provenance remains distinguishable.
- Each remaining validator uses quote-aware brace depth over authored outer source, with an interior-code fallback
  for programmatic/older nodes whose source is empty or descriptive. This preserves compatibility while exposing
  missing closes that the prior interior-only representation hid.
- Dart's six tests, Julia's 103 assertions, and the shared Lua consumer's 109 assertions on each ABI cover all
  neutral placements, nested/quoted provenance, four duplicate combinations, ownership, malformed twins,
  serialized reconstruction, generated plan/emitted source, and readable/inert legacy plain carriers.
- `specs/spec.spec` gains `standalone_lifecycle_block` plus a complete-line lifecycle production before the generic
  bare-edge route. This fixes the audited self-hosted `I { ... }` misclassification and proves all seven reserved
  markers with a 25-test permanent grammar consumer.
- The first canonical attempt correctly rejected four stale `spec_spec_*` corpus snapshots at the pinned Unicode
  grammar-freshness boundary. Updating only their exact canonical grammar bytes makes all five copies identical at
  SHA-256 `03cfb50459984806c806e9ec3f2b072add897c207a2cb93fd267d640a5808004`; the freshness checker passes.
- The corrected canonical attempt reached fresh Rust dependency compilation, where every active `rustc` process
  received simultaneous signal 15 without a crate diagnostic. Process census found no survivor and the gate has no
  internal timeout at that command; the exact staged candidate retries from the repository-local warmed cache.
- Canonical retries exposed the same Dart/Julia precedence regression in existing recursive-observation negative
  fixtures: preserving every suffix after lifecycle `I` turned a same-line `Child::AND /x/` header-shaped tail into
  a raw body node, masking the expected typed observation target/operand diagnostic. Both frontends now preserve a
  lifecycle remainder only when their existing rule-header scanner does not recognize it; the standalone malformed
  twins and exact recursive-observation consumers retain their original diagnostic boundaries. Shared Lua was
  audited too: its affected observation fixtures place child headers at real line boundaries, where the existing
  collector stops before body parsing, so no corresponding slice-induced change is required. Focused Dart fatal-
  warning analysis also removed one unused import from the new contract test before exact restaging.
- One project-routed recurring driver composes the neutral 11-mutation checker, Perl 7 subtests, self-hosted 25,
  Rust 8, Dart 6, Julia 103, PUC Lua 109, LuaJIT 109, and generated/capability/language ledgers. It passes at
  capability 90/0/0 and language coverage 250/105+1/126.
- Canonical attempt five reaches the tool project-data oracle after all changed-surface and broad language checks
  pass. Its frozen Python-entrypoint census correctly reports the new repository-routed neutral checker as a 33rd
  entrypoint. The checker owns no temporary allocator; advancing that exact census to 33 exposes the companion
  five-backend driver's managed `mktemp` workspace as the 15th shell owner. The driver creates and removes that
  workspace beneath validated repository-local `TMPDIR` and is enrolled in the governed workflow-routing oracle;
  the three Python temporary owners stay unchanged, and focused storage proof passes before the next exact staged
  canonical retry.
- Canonical attempt six passes the repaired tool-storage oracle at the former failure point, then the outer Codex
  sandbox denies the process-locality oracle's required nested macOS `sandbox-exec` with status 71 before any
  representative driver runs. The existing [[project-data-process-locality-proof]] classifies this exact harness
  boundary: authoritative signoff is an unchanged permission-authorized canonical rerun, not a source workaround.
- The permission-authorized canonical attempt seven passes six-family process containment, relocated execution,
  both 66-case CLI matrices, and every earlier gate, then Phase 0 reports one failure in 1,032 tests. Its bootstrap
  function-ownership guard raw-scanned serialized payload text and mistook `return(value)` inside the newly correct
  lifecycle `ICODE` node for a function-definition payload. The repair recursively checks only structural array
  tags and hash identity fields, keeping exact function-node identities forbidden without rejecting lifecycle code.
- Public teaching now states the shorthand is current on all five backends. Legacy plain AST and compiled payload
  carriers remain readable and inert; their removal or execution is still a separate versioned migration.
- The required `.15.2` change record crossed the bounded hot-shard threshold. Mechanical rollover archived exact
  lines 235-450 as immutable change-history segment `4988` (216 lines / 19,833 bytes, SHA-256 prefix
  `4251613b7181`) from activation source `93213575`, leaving `CHANGES.md` at 251/512 lines and 21,972/65,536
  bytes before final whitespace normalization. The resulting collection is 25 files / 47,264 lines / 3,390,743
  bytes with a 24-line manifest. ADR `0096` advances only file capacity 24→25 and manifest-line capacity 23→24;
  every root, byte, per-segment, aggregate, owner, lifecycle, verifier, routing, and storage control remains fixed.
- 2026-08-29 (`FUTURE-PARITY-BACKLOG.15.1` — Perl/Rust standalone lifecycle implementation): one neutral contract
  fixes semantic normalization to `I`, authored source/opening line, interior ActionIR spans, OR/AND and zero/one/
  two-regex positions, a valid same-line successor, all four duplicate mixtures, ownership, malformed twins,
  generated paths, and inert legacy plain data.
- Perl's supported-member check admits `{`; a new bootstrap descriptor precedes only the generic brace sentinel
  and reuses the same nested/string-aware scanner as explicit lifecycle blocks. Both forms emit `ICODE`, with an
  optional third provenance record deliberately ignored by existing RuleIR's stable two-field semantic reader.
- Explicit Perl lifecycle entries now carry the same source metadata, beginning at the marker rather than line
  indentation. Existing RuleIR joins repeated entry chunks in authored order, so no handler/runtime ABI changes.
- Validation tracks a lifecycle item's cross-line delimiter depth and rejects only an unmistakably unsupported
  remainder after its balanced close. Recognized same-line successors remain valid. Missing and stray closes keep
  the established `validate_dsl_syntax` summaries, stage, rule, and opening line for explicit/bare twins.
- Rust's block consumer now returns normalized interior, exact outer source, and remainder. Standalone source
  blocks become `CodeBlock(I)` immediately; explicit lifecycle source is no longer synthesized. Outer source
  balance exposes the previously hidden missing-close defect while quote-aware scanning ignores literal braces.
- Programmatic and older serialized lifecycle nodes may have an empty or descriptive `source`. Final review caught
  that using exact source unconditionally would stop validating their interior braces; the validator now selects
  exact outer source only for authored block-shaped source and otherwise retains the prior interior-code check.
- The first Rust remainder fix made every historical `Raw` carrier fatal and broke validation of the shipped user-
  function-definition grammar. The corrected scope retains/rejects `Raw` only after same-line lifecycle `I`,
  preserving unrelated compatibility data. The neutral malformed fixture uses `???`, not ambiguous bare-edge text.
- Rust compilation appends `I` statements into the one existing preamble `Option`; this preserves serialized ABI
  and each separately parsed interior span while repairing explicit and mixed last-slot-wins behavior.
- Focused proof passes Perl 324/324, Rust parser 32/32, and the Rust neutral consumer 8/8 across native,
  serialized, emitted/generated, source/provenance, ownership, duplicate, malformed, and legacy-inert routes.
- `.15.1` changes no Dart/Julia/Lua, self-hosted grammar, capability/public admission, generated-source format,
  dependency, storage, or outward API. `.15.2` retains those remaining rollout and final no-drift responsibilities.
- 2026-08-29 (`FUTURE-PARITY-BACKLOG.15.0` — standalone lifecycle-block contract): tool-first audit disproves
  the book's former current-tense shorthand claim. Perl validation rejects the bare item as unsupported; the
  bootstrap brace scanner balances it only to an integer sentinel. Rust parses `PlainBlock` then compiles nothing;
  Dart/Julia/Lua compile only `plain_action_payloads`, which their lifecycle runtimes never execute.
- Direct Perl, Julia, PUC Lua, and LuaJIT probes establish the explicit twin: two `I` blocks execute left-to-right
  and return `first-second`. Rust instead stores lifecycle roles in singular options and overwrites an earlier
  explicit `I`; `.15.1` owns that existing defect together with Perl/Rust shorthand behavior.
- Direct self-hosted output reveals a separate grammar projection defect: `specs/spec.spec` lacks a standalone
  production and its generic bare-edge block can classify reserved line-start `I { ... }` as an edge to target
  `I`. Production compilation still uses the hardcoded bootstrap, where lifecycle precedence is correct. `.15.2`
  owns the self-hosted correction with remaining-backend rollout.
- ADR `0094` therefore selects parse-time normalization to the existing lifecycle `I` semantic shape at the exact
  authored position. Preserve actual source/opening line and explicit-twin interior spans/diagnostics; do not
  fabricate marker provenance, add a phase, or route source through plain payloads. Empty balanced blocks are
  valid; malformed blocks follow the explicit twin except for the inevitable absent-marker column difference.
- Recognition applies only when `{` begins a rule item. Action/blind/resolved bare-edge suffix blocks, function
  bodies, contextual callable blocks, callable literals, nested control/value/hash blocks, and quoted braces keep
  their established owners. OR/AND and zero/one/two-regex placement is unchanged; mixed explicit/shorthand `I`
  blocks preserve authored order and Perl's established placement-sensitive lowering.
- Existing Rust/Dart/Julia/Lua plain AST variants and Dart/Julia/Lua plain payload fields remain readable but inert
  compatibility data. New source parsers stop emitting them; execution or removal needs a separately versioned
  migration. [[standalone-lifecycle-block-audit]] is the retrieval point.
- This leaf changes only contract, correction of premature documentation, downstream ownership, and bounded
  continuity. `.15.1` implements Perl/Rust; `.15.2` implements Dart/Julia/Lua, both ABIs, self-hosted grammar,
  generated/public projections, and final no-drift.
- 2026-08-28 (`FUTURE-PARITY-BACKLOG.14.8` — complete authoring model): final closeout is orchestration and
  governance only. `tools/check_typed_authoring_model_six_runtime.sh` calls the six existing recurring drivers in
  fixed order; it is not a replacement behavior oracle.
- The exact contract remains 14 rows and promotes only `recurring_public_no_drift`, reaching 14/0/231. Program-
  wide public proof is 8 current documents / 8 stale denials / 6 authoring-safety denials / 10 outward guards.
- Stale internal ids `capture_take_slice` / `capture_take_slice_len` cannot surface as authored calls; canonical
  helpers remain `capture_take()` / `capture_take_len()`. `save_cursor()` / `restore_cursor()` remain cursor-only
  compatibility controls and cannot roll back marks/boundaries or non-recognition effects.
- Canonical CI inventories, path-audits, syntax-checks, and project-data-routes the composed driver; exact full
  execution is opt-in through `LINKEDSPEC_RUN_TYPED_AUTHORING_MODEL_MATRIX=1`.
- The first canonical traversal root-caused one lockstep defect before runtime execution: staged public governance
  still required the sole-facing book's pre-closeout “`.14.8` pending” marker. Its required literal now names
  aggregate 14/0/231; the existing marker-deletion mutation continues to prove that current projection.
- No parser/compiler/runtime/value/helper/carrier/format/outward/capability/CLI/storage behavior moves. ADR,
  Knowledge, roadmaps, architecture, capability/Toolbox, mdBook, live continuity, task/index, and memory move in
  lockstep.
- 2026-08-28 (`FUTURE-PARITY-BACKLOG.14.7.10` — final staged recomposition): the closeout adds no umbrella
  oracle. It reruns the existing repository-routed six-runtime driver and support ledgers, then changes only
  durable current projections and parent/frontier state.
- Focused proof remains exact at neutral/public 9/9/123 plus 129, Perl 143, Rust 1 in 389.37 seconds, Dart 19,
  Julia 491, Lua 890 per ABI, typed 13/1/189, generated/capability 85/0/0, and language 250/105+1/126.
- The sole factual current-projection drift was ADR `0088`'s live 128 count. Canonical public admission added
  mutation 129 for classified non-generic reverse-scan subtraction and refreshed the dated closeout note, but
  not the earlier live inventory. Historical evidence remains untouched.
- [[general-staged-ast-enrichment-recomposition]] is the retrieval point. Exact base-relative review proves no
  runtime, consumer, fixture, executable governance, topology, format, manifest, dependency, storage, doctrine,
  public, or unrelated outward change.
- Parent `.14.7` closes after receipt-bound canonical proof; `.14.8` remains the only owner of combined typed
  `recurring_public_no_drift` and full-authoring-model final no-drift.
- 2026-08-28 (`FUTURE-PARITY-BACKLOG.14.7.9` — portable staged authoring): public admission does not add a new
  runtime path. All six routes already implemented the exact dedicated assignment annotation; the slice makes
  that boundary explicit, executable, documented, and mutation-closed.
- The public grammar is one complete scalar assignment. Source text is direct `entry_text()` / `match_text()` or
  a literal-index group, or a nonempty `cat(...)` over those forms. Options are statically validated literals.
- The authority boundary is unchanged: authored syntax constructs an inert marker and sidecar; only after the
  parent AST returns may the scheduler select from the caller's immutable already-compiled snapshot. Parser text
  or identity never grants path, URI, provider, callback, compilation, registry mutation, or ambient authority.
- Public governance is deliberately separate from the 123 neutral mutations: six documents, 17 forbidden stale
  claims, ten outward paths, all 37 diagnostic codes, and 129 reason-checked mutations can fail independently.
- `parse_job` remains outside the 250-name ordinary generic helper inventory. This prevents a generic-call parser
  or helper registry from accidentally becoming public authority for residual, nested, dynamic, or callback use.
- Canonical CI exposed an implicit self-hosted lockstep owner: four `spec_spec_*` inputs are byte-for-byte
  `specs/spec.spec`, and the Unicode rule-label contract pins that equality. The required declaration therefore
  moves as an identical comment snapshot in all five paths; this is fixture governance, not fixture behavior.
- The corrected canonical retry then exposed a raw-text coverage false positive: the ordinary-helper reverse scan
  saw `parse_job(` inside those comments despite the same checker classifying `parse_job` as a dedicated form.
  The scan now subtracts the exact classified non-generic set, and mutation 129 removes that guard to lock the fix.
- Capability exclusion freshness closes in the same slice: `future.general_parse_job_authoring` is removed when
  satisfied, leaving one legacy exclusion and 17 capability rows / 85 pass states under 19 current mutations.
- Typed source gains only two current-public projection guards, moving 13/1/187 to 13/1/189. The one pending row
  is still the combined `recurring_public_no_drift` owner under `.14.8`, so staged public closeout does not consume
  program-wide closure early.
- Snapshot-only consumer edits are required current projections, not behavior changes: status, rollout row nine,
  and applicable authored-availability strings move; assertions, production/runtime carriers, fixtures, formats,
  v1 behavior, and unrelated outward surfaces do not.
- [[portable-parse-job-public-authoring]] is the retrieval point. Exact focused proof passes all six staged routes
  and every direct-dependent contract; this public boundary still requires staged receipt-bound canonical CI
  before its atomic commit and handoff to `.14.7.10`.
- 2026-08-28 (`FUTURE-PARITY-BACKLOG.14.7.8` — staged enrichment recurring proof): exact clean activation is
  shared-Lua recomposition commit `84396911`; scope owns only recurring proof topology, neutral/typed/capability
  governance, aggregate consumer snapshots, and synchronized current projections.
- Five immutable backend source groups produce six ordered routes because the shared Lua consumer executes once
  on PUC Lua and once on LuaJIT. The recurring driver runs neutral, Perl, Rust, Dart, Julia, both Lua ABIs, then
  typed/generated/capability/language ledgers in one fail-fast repository-routed command.
- Completing neutral `recurring` requires its fixed-contract consumers to advance status, two recurrence counts,
  mutation total, rollout row eight, and applicable availability text. No behavioral case, fixture, parser,
  compiler, runtime, carrier, generated-format, function-body-v1, public, or outward assertion changes.
- During activation the agent mistakenly strengthened concise “immutable source groups” into byte-identical
  consumers. The first Perl run exposed that overconstraint; the task and Knowledge record now preserve the
  intended behavioral immutability while permitting the progressive-precedent aggregate snapshot updates.
- Seventeen exact topology/status/storage/rollout mutations move neutral governance 106→123. The same 17 guarded
  mutations promote only typed `staged_dispatch`, moving typed governance 12/2/170→13/1/187.
- `language.private_staged_ast_enrichment` is the corresponding current all-pass capability row. It contributes
  five backend cells, moving generated/capability census truth from 80/0/0 to 85/0/0 while the public
  `parse_job` future exclusion remains exact.
- Focused proof passes the complete driver: Perl 143, Rust 1 fresh emitted carrier, Dart 19, Julia 491, and Lua
  890 per ABI; progressive, recognition, semantic, function-v1, generated, capability, language, routing,
  README/memory/Knowledge, rendered book, and nine doctrines also pass.
- [[staged-ast-enrichment-recurring-gate]] is the retrieval point. `.14.7.9` alone owns public authoring and
  staged public no-drift; `.14.8` retains combined program-wide typed public no-drift.
- This is a canonical milestone because executable CI topology and cross-backend recurring truth move together.
  The exact staged candidate must clear receipt-bound canonical CI before its atomic commit.
- 2026-08-28 (`FUTURE-PARITY-BACKLOG.14.7.7.5` — independent Lua staged recomposition): exact clean activation
  is dual-ABI admission commit `97bfbac6`; the leaf owns only closure/current projections and no executable file.
- One shared source remains the sole Lua behavior oracle: 888/888 per ABI explicitly and once per ABI through the
  complete ordinary route. Canonical topology retains one tracked path and one exact invocation per host.
- The consumer itself is the recomposition proof: four carrier routes remain equal and detached, every run gets
  fresh callback/registry/cache/resource authority, and logical generated/emitted artifacts contain none of it.
- Admitted peers remain Perl 143/143, Rust 1/1 in 268.47 seconds, Dart 19/19, and Julia 491/491. Neutral governance
  remains five source consumers/six runtime routes/106 mutations; every direct-dependent ledger is unchanged.
- Exact base-relative comparison is the negative contract for this leaf. Production, tests, fixtures, executable
  checkers/contracts, discovery topology, formats, public/outward surfaces, dependencies/toolchains/storage/
  doctrines, and other backend behavior have no diff.
- [[lua-staged-ast-enrichment-recomposition]] is the durable retrieval point. Current Knowledge/ADR/roadmap/book
  prose now distinguishes complete private recomposition from still-pending recurrence and public authoring.
- Parent `.14.7.7` closes unchanged. `.14.7.8` next owns one recurring five-source/six-runtime driver and only its
  typed staged row; `.9` retains public `parse_job(...)`, and `.10` retains final whole-program recomposition.
- This designated parent closeout is canonical-tier. The exact staged documentation-only candidate and all nine
  doctrines pass receipt-bound proof before the atomic commit.
- 2026-08-27 (`FUTURE-PARITY-BACKLOG.14.7.7.4` — Lua staged carrier admission): exact clean activation is
  recursive-carrier commit `0f33564b`; scope owns lifecycle/projection/topology only and changes no production.
- The neutral contract is now `all_private_backends_complete_recurring_and_public_pending`. Lua becomes complete,
  rollout rows six/seven become complete, and eight independent rollout/ordinary/canonical guards produce 106
  mutations. Recurring and public rows remain pending.
- `tools/run_lua_local.sh` invokes the same stable consumer once with `$LUA_CMD` and once with `$LUAJIT_CMD`.
  `lua/test/run.lua` omits it. Canonical CI requires the path once and logs/invokes one repository-routed command
  per ABI, so there is no duplicated behavioral owner.
- The consumer remains 888/888 per ABI. Complete ordinary Lua passes 178/178 per host and 105/105 corpus;
  admitted Perl 143/143, Rust 1/1 in 323.52 seconds, Dart 19/19, and Julia 491/491 agree on the current projection.
- Typed 12/2/170, recognition 138/250/58, progressive 9/9/116 plus public 60, semantic 6/20/128,
  generated/capability 80/0/0, and language 250/105+1/126 remain exact.
- [[lua-staged-ast-enrichment-carriers-admission]] is the topology retrieval point. Knowledge is 906 facts /
  7,707 keys; the sole-facing book renders 80 files / 15,728 KiB and generated output is removed.
- Base-relative guards keep Lua production/private authority, function-body v1, generated format, other-backend
  production, public/outward surfaces, dependencies/toolchains/storage/doctrines, and `.14.7.8+` unchanged.
- The leaf is a mandatory canonical boundary because ordinary/canonical topology and executable lifecycle/rollout
  truth move together. The exact staged candidate and nine-doctrine pre-commit validation pass; `.14.7.7.5`
  retains independent admitted-route recomposition and final parent closure.
- 2026-08-27 (`FUTURE-PARITY-BACKLOG.14.7.7.3` — Lua staged recursive carriers): exact clean activation is
  current-depth commit `9a2778aa`; scope owns only private breadth-first recurrence, shared bounds, source
  projection, four fresh post-parent carriers, the stable consumer's dormant GREEN, and synchronized truth.
- `enrich_recursively` preserves `enrich_current_depth`. It prepares/reserves a complete depth before callbacks,
  collects only markers in successful detached child results, and rebases their paths through the exact stitch
  destination. This avoids reactivating old inert markers and preserves producer lineage.
- Active frames bind normalized resolved parser, selected top, exact-text SHA-256, and full typed provenance.
  Exact repeats cycle; same-parser/top recurrence requires every child segment to be contained in an active segment
  and total Unicode-scalar extent to shrink.
- Cancellation identity/probe, clock/deadline, steps, seeded calls, depth/calls, result nodes, and diagnostic bytes
  are invocation-wide. Marker-shaped results count atomically after deep live-key validation. Callback contexts
  expose safe points and source projection only while active, then expire on return or throw.
- Direct and ordered-derived local positions, spans, and nested diagnostics map to original source. Cross-segment
  spans stay `concatenate_in_order`; invalid local ranges fail closed and byte overflow produces the governed
  truncation record.
- `StagedAstEnrichmentSeed` validates copied logical registry/options but invokes its host factory only after the
  parent result completes. Every native, reconstructed, generated-plan, or emitted execution gets a new callback
  set, registry/cache, cancellation/clock authority, lineage, budgets, and queue; none is serialized.
- The stable consumer passes 888/888 per ABI with four routes twice, no-seed compatibility, parent-failure no-start,
  live-transaction denial/state expiry, exact staged-error identity, cross-result detachment, fresh authority, and
  serialized-authority absence. It remains outside ordinary/canonical discovery; `.4` retains admission/rollout.
- [[lua-staged-ast-enrichment-recursive-carriers]] is the canonical retrieval point. Neutral 98 mutations,
  function-body v1, generated format, public/outward behavior, other backends, and later recurrence stay fixed.
- Focused proof passes ordinary Lua 178/178 per ABI and 105/105 corpus; staged Perl 143/143, Rust 1/1 in 320.17
  seconds, Dart 19/19, and Julia 491/491; all typed/recognition/progressive/semantic/generated/capability/language/
  public ledgers; Knowledge 905/7,699; mdBook 80 files/15,724 KiB; bounded histories; and exact scope guards.
- The exact staged candidate also clears memory/task/README invariants, all nine doctrines, `git diff --check`,
  and receipt-bound canonical CI before the atomic `.3` commit; `.4` remains the sole admission/rollout owner.
- 2026-08-27 (`FUTURE-PARITY-BACKLOG.14.7.7.2` — Lua staged current-depth authority): exact clean activation is
  marker/provenance commit `43b33922`; the leaf owns only a separate private frozen registry/cache, one complete
  current-depth scheduler, detached result/failure policies, the next `.3` RED, and its mandatory change-history
  rollover/capacity step.
- `staged_ast_enrichment.lua` is Lua-5.1-compatible and private. The caller supplies completed candidate outcomes
  plus the exact compiled callback map before authored execution; resolution is pure and has no loader, provider,
  compiler, filesystem, network, environment, import, or mutation authority.
- Default top selection precedes canonical v2 job identity. Plan-cache keys cover normalized parser, content/import
  digests, selected top, spec/helper/staged versions, and sorted effective capabilities; only immutable callback
  plans persist, never child results, failures, contexts, or partial AST state.
- One complete marker depth resolves every job and reserves every target before callback one. Typed path/
  provenance/job ordering is dual-ABI exact, siblings receive fresh runtime tables, cross-plan conflicts reject,
  and multiple shared appends remain deterministic.
- All four result and three failure policies operate on an unpublished parent copy after finite acyclic node-
  bounded detachment. Live keys, marker-shaped authority smuggling, cycles, nonfinite values, stale targets, and
  callback throws fail closed; valid returned markers remain inert until `.3`'s separate recursive scheduler.
- The consumer reports 597 GREEN/one exact `.3` recurrence/bounds/rebasing/fresh-carrier RED on PUC Lua and LuaJIT.
  Complete ordinary dual-ABI Lua, neutral 98, admitted Perl/Rust/Dart/Julia, and every direct ledger pass.
- The required change record crosses the exact 23-file/22-line history controls. One immutable segment and ADR
  `0093` own only the reviewed 24-file/23-line step; this upgrades the leaf to receipt-bound canonical proof.
- [[lua-staged-ast-enrichment-current-depth-authority]] is the retrieval point; function-body v1, recursion/
  carriers, discovery, rollout, formats, public/outward behavior, and other backends remain unchanged.
- 2026-08-27 (`FUTURE-PARITY-BACKLOG.14.7.7.1` — Lua staged marker/provenance): exact clean activation is the
  shared dormant-boundary commit `a7293bac`; scope owns only the private logical annotation, strict static closure,
  native-range-backed typed provenance, inert detached marker, and transition to one `.2` RED.
- `action_parser.lua` recognizes only bare scalar assignment with exact `parse_job(text_expr, hash(...))` shape.
  It normalizes literal options/capabilities and direct/flattened-derived text plans; every escaped generic form
  and recognition-reachable declaration rejects before execution.
- PCRE2's ovector now supplies a private compact capture-range array aligned one-to-one with participating capture
  text. An unexported weak-key side table owns it; match objects, `matching.lua`'s outward module, and JSON expose
  no field or accessor. This distinguishes repeated equal captures
  and preserves Unicode source positions without searching strings or replaying regexes.
- Private `staged_parse_job.lua` converts live whole/capture UTF-8 byte ranges through the existing source
  authority and returns detached plain marker data. It owns no resolver, registry, cache, callback, scheduler,
  recurrence, stitching, filesystem, provider, cancellation, or host authority; `.14.7.7.2-.3` retain those seams.
- Native, reconstructed, generated-plan, and independently loaded emitted routes agree on both ABIs. The shared
  consumer is 392 GREEN/one identical `.2` authority RED; complete ordinary dual-ABI Lua and all focused neutral/
  admitted/direct-dependent checks pass without discovery, rollout, format, v1, public, or other-backend drift.
- The durable fact card [[lua-staged-ast-enrichment-marker-provenance]] prevents future provenance archaeology;
  Knowledge is 902 facts/7,665 keys and the sole-facing book renders 80 files / 15,680 KiB.
- 2026-08-27 (`FUTURE-PARITY-BACKLOG.14.7.7.0` — shared Lua staged dormant RED): exact clean activation is the
  Julia-admission commit `199f585f`; scope owns only one stable shared consumer, the Lua lifecycle/checker
  mutation, current-v1 compatibility evidence, one exact general-v2 RED, and synchronized boundary truth.
- One Lua-5.1-compatible source runs unchanged through the project-data wrapper on PUC Lua and LuaJIT. Each run
  passes 153 assertions, then intentionally fails one exact assertion with
  `LINKEDSPEC_STAGED_AST_ENRICHMENT_LUA_RED: missing dedicated marker and typed provenance`.
- The GREEN boundary proves current function-body-v1 job normalization, deterministic resolve/load/compile/
  execute/cache records, `replace_field` / `body_ast` / `fail` stitching, and wrong-top diagnostic context. The
  general authored assignment still lowers generically to `assign_scalar` calling helper `parse_job`; helper
  contracts report one unknown helper, and neither the AST nor reconstructed/generated observations contain a
  `STAGED_PARSE_JOB_MARKER`, `staged_parse_job_v2` sidecar, or typed provenance.
- Native and `SpecFile`-JSON reconstructed execution therefore fail at the same unknown-helper runtime boundary;
  validated generated-plan and independently loaded emitted-module routes fail equivalently and contain no
  callback, registry, cache, scheduler, cancellation, source-snapshot, or host authority.
- The neutral checker now requires the exact stable Lua file while proving it absent from `lua/test/run.lua`,
  `tools/run_lua_local.sh`, and canonical CI. Only shared Lua lifecycle plus one mutation moves: governance is
  98, both ABI rollout legs remain pending, and Lua production/generated/public/outward behavior does not move.
- The new Lua boundary fact plus refreshed neutral and admitted-backend facts prevent future archaeology. ADR
  `0088`, roadmaps, architecture, Toolbox, task/index, capability guidance, bounded continuity, memory, and the
  sole-facing mdBook agree that `.14.7.7.1` alone owns the dedicated private marker and typed provenance.
