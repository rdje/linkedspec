# MEMORY

- activation_commit: `9bd2f680500ad85f76e45656805840b282538d73` — clean .1.52 handoff before Dart .1.53.
- latest_completed_leaf: `DART-STARTUP-READING.1.53 - read typed source and Unicode consumers`; 29 tests and three neutral checks pass.
- active_work_unit: none; clean .1.53 handoff, with required-reading and repair gates still open.
- next_action: Activate `DART-STARTUP-READING.1.54` from clean HEAD; complete Unicode routes, binding/function tests and write-vivification tests through292.
  Authoring investigations remain proposed; approved format `.2.8`/`.12` remain parked.
- in_flight_uncommitted: none; .1.53 focused proof complete; no PGEN/RGX build or full CI required for this ordinary reading leaf.
- blockers: Dart .7 closes under .11/ADR0113 with the explicit one-time verification exception; Startup `.7` blocks recovery/purge; engineering-history .5 approval is implemented under containment .9 / ADR0111; prior change-history approval remains under .8 / ADR0110. Startup repairs `.7`–`.30`, `.32`–`.47`, `.49`–`.81` precede mutation setup; `.29` belongs to `.5`. Prior narrow exceptions stay approved; Dart .6 approval is implemented under containment .10 / ADR0112, with all earlier history preserved.
- current_rust_warning_debt: Repeated carriers report 1,870 pgen plus 26 rgx-core output warnings; RUST-DEPENDENCY-WARNING-ZERO.1-.7 own causal repair/pins/enforcement without suppression after Lua intake.
- current_task_index_contract: checker-owned closed-state markers live only between the stable sentinels after the
  active table; the task metadata doctrine inventories all consumers, permits arbitrary frontier-row rewrites,
  and requires every exact current task ID to be unique across partitioned and unpartitioned storage.
- current_write_vivification: `linkedspec-write-vivification-v1` is implemented on all five backends with one typed expression-segment AST,
  evaluated string/integer harray/array selection, dense atomic creation, post-evaluation snapshots, detached
  results, exact diagnostics/spans, invocation-local absent/null presence, and read exclusions at 105 rejected
  mutations. Rust, Dart, Julia, PUC Lua, and LuaJIT preserve it through supported serialized/reconstructed/
  generated/emitted carriers. Portable capability `language.nested_write_vivification` is admitted by `.19.7`;
  exact six-runtime recurrence is complete under `.19.8`, and public teaching/no-drift is closed under `.19.9`.
- current_map_leaves_mutation: `linkedspec-map-leaves-mutation-v1` is implemented on all five backends with one bang-only mutation AST,
  resolved receiver identity guard, root-kind original-shape traversal, copied frames, atomic rebind, detached
  result, post-commit continuation, exact diagnostics/exclusions, and 167 base mutations. Known gaps affect Rust final assignments
  and substitution, plus Perl callback substitution (startup .58/.59). The typed node survives supported
  reconstructed/generated/emitted carriers; admitted guard tests remain bounded to their covered routes.
  The Lua suite passes 530 assertions per ABI. Portable capability
  `language.map_leaves_receiver_mutation` is admitted by `.19.7`; exact six-runtime recurrence is complete under
  `.19.8`, and public teaching/no-drift is closed under `.19.9`.
- current_rule_entry_dispatch_invariant: selecting a rule enters its handler and starts its mode-driven execution;
  entry alone never tests that rule's own regex. An outgoing `->` match edge selects its target rule's regex. Rust now has
  both the direct-entry negative lock and a zero-regex-parent positive trace with typed `target_rule=Done`; the
  shared corpus has no controlled inert `/x/ -> Done` root; two Perl generations and complete Rust/Dart/Julia/
  PUC-Lua/LuaJIT 105-case corpus routes are green. Root selection passes its exact five-backend/six-runtime driver,
  recursive observation passes all six routes, the repository-managed Rust trace target passes 12/12, and exact
  staged canonical signoff plus both 66/66 CLI environments and Phase 0 1,032/1,032 are green.
- canonical_ci_execution: use approved host execution for `tools/run_ci_local.sh`; nested macOS containment
  requires it. See `docs/knowledge/project-data-process-locality-proof.md`.
- current_rust_launch_evidence: Newer-OS controlled diagnosis/conditional repair is pending under startup .81; see `docs/knowledge/macos-rust-first-launch-validation-latency.md`.
- current_mutation_composition_contract: `linkedspec-write-map-leaves-composition-v1` digest-binds both unchanged
  mechanisms across eight writes, six callback cases, one continuation, and 592 current composition mutations;
  Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT execute both halves through one governed recurring driver. Zero-regex
  `Top:: -> Done` lets the parent loop select and match `Done`'s regex, not an inert parent one.
- current_map_leaves_scope_resolution: option A preserves pure functions. Helper-mediated rejection uses inline
  explicit-target `set(tree, ...)`; post-commit receiver-write proof uses caller-scoped `.with()`. No implicit
  caller capture or arbitrary user-defined bang method is admitted.
- current_mutation_public_no_drift: `.19.9` closes 63 public Markdown files / 14 governed documents / eleven
  authority-bound example classes / ten stale-current denials / 50 isolated public-checker mutations. Capability
  governance independently pins the owner and exact-one CI registration through four mutations.
- current_core_state: typed source is 14/0/231; recognition 138/250/58; progressive 9/9/116 plus public
  6/12/10/60; gap 9/0/63 plus public 8/15/10/34; staged 9/9/123 plus public 6/17/10/129; capability 100/0/0;
  semantic introspection 9/0/128.
- standing_contracts: all durable paths are repo-relative; all project data stays on the repository filesystem;
  README remains bounded; ordinary leaves use focused proof and designated infrastructure/public/push boundaries
  use exact staged canonical CI; task-tree/index, Knowledge Map, mdBook, and bounded live/history move in lockstep.
- current_engineering_notes_capacity: ADR0113 admits28 files/27 manifest lines and preserves211 lines/24521 bytes under containment .11.
  Manifest is16,230 bytes; all byte/root/segment/aggregate ceilings remain unchanged. All history and actual-validator proof pass.
- current_change_history_capacity: ADR0112 at bef5dafd admits exactly 32 collection files / 31 manifest lines / 17,615 manifest bytes.
  Segment 4981-5a6450db0974 preserves 218 lines / 32,108 bytes; every other ceiling remains unchanged.
- current_ci_build_reuse: Director requires PGEN/RGX builds once after submodule updates, then reuse for LinkedSpec-only CI; startup .80.1-.4 own implementation.
  Initial/update preparation, zero dependency compilation in ordinary CI and explicit missing-artifact handling remain pending; startup prerequisites remain.
- latest_bootstrap_read: 2026-09-11 — roadmap Yes / full codebase No / physical mdBook Yes; Perl/Rust complete, formal .4 pending; Dart53/55,77528 fragments/2386603 bytes. Next .1.54; prior repairs and CI reuse remain pending.
