# DEVELOPMENT NOTES

This stable path is the bounded current engineering-notes hot shard. Exact prior notes through atomic 178/300 are
immutable and repository-local; new dated records are prepended here and remain complete rollover units.

- Current limit: 512 lines / 65,536 bytes; warn at 80%, roll at 90%, and retain at most 50% after rollover.
- History manifest: [`docs/history/development-notes/manifest.jsonl`](docs/history/development-notes/manifest.jsonl)
- Read all archived notes: `perl tools/read_document_history.pl --surface engineering_notes --all`
- Search archived notes: `perl tools/read_document_history.pl --surface engineering_notes --grep '<literal>'`
- Check rollover pressure: `perl tools/roll_document_history.pl --surface engineering_notes --check`
- Apply required rollover: `perl tools/roll_document_history.pl --surface engineering_notes --apply`
- 2026-08-30 (`FUTURE-PARITY-BACKLOG.15.3` — stale Lua `next()` fixture repair): `.19.1.1` boundary proof made
  `lua/test/run.lua` fail only test 115 on PUC Lua. The fixture's `/skip/ { next() }` now correctly parses as two
  rule items: a regex plus a bare lifecycle-`I` block. Entry lifecycle throws `next` before iteration, yielding
  matched/null at cursor zero; before `.15.2` the inert bare block made the test pass without exercising control.
- Direct replacement proof uses `-> Skip { next() }` plus `Skip: /skip/`, assigning the block to the action edge.
  It returns `keep` at cursor 8. Complete 178-test PUC Lua and LuaJIT harnesses pass, as do the neutral 14-mutation
  standalone contract and 109-assertion admission on each ABI. No production, contract, or public behavior moves.
- Exact canonical attempt one passes through the Perl project-data oracle, then the tool-storage census reports
  36 Python entrypoints against its exact expected 35. The delta is committed `.19.1.1`
  `tools/check_write_vivification_contract.py`: it already runs through the repository-routed wrapper, uses no
  Python temporary allocator, and changes no shell allocator ownership. The repaired census is therefore 36/3/15.
- 2026-08-30 (`FUTURE-PARITY-BACKLOG.19.1.1` — future nested-write contract): ADR/Knowledge retrieval and
  `LinkedSpec::call_spec_handler_subst` preceded implementation. Perl proves quoted segments currently lower as
  keys while every computed segment lowers through integer-index coercion; Rust/Dart/Julia/Lua retain the same
  authored key/index split. Evaluated dynamic strings therefore require the future unified segment model.
- Contract review caught two draft inconsistencies before claims landed: declared AST `source`/`expression` fields
  were absent from fixtures, and syntax diagnostics had codes but no exact spans. The final checker requires the
  complete nested expression nodes, assignment source, typed parser diagnostics, and non-ASCII scalar offsets.
- Segments evaluate once left-to-right, then RHS once. The structural operation snapshots afterward, so completed
  same-binding expression effects compose on success and survive later structural failure; only partial path
  building is atomic/isolated. Bound null is present, arrays remain dense, and all aggregate values detach.
- Exact current proof stays non-vivifying: Perl direct toolbox projection/runtime, Rust 3/3, Dart 1/1, Julia 1/1,
  and direct nested-write scenarios on both Lua ABIs pass without backend source changes.
- The monolithic PUC harness separately fails only its old `/skip/ { next() }` fixture. AST/runtime probes show the
  now-ratified bare block executes as entry lifecycle `I` at cursor zero; before `.15.2` it was inert, so the test
  never exercised `next()`. Queued `.15.3` owns a valid action-edge rewrite and both complete ABI harnesses.
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
