# SPEC-LANGUAGE-SELF-CONTAINMENT: Expressive `.spec` Closure and EBNF-Like Authoring Profile

## Metadata

- Tree ID: `SPEC-LANGUAGE-SELF-CONTAINMENT`
- Status: `active` / capability inventory selected from clean 30b2cc3a0
- Roadmap lane: `.spec language evolution / expressive self-containment and alternate authoring profiles`
- Created: `2026-07-30`
- Last updated: `2026-09-27`
- Owner: repo-local workflow

## Goal

Make `.spec` authoring expressively self-contained for LinkedSpec's problem domain: after source input enters the
engine, authors can describe grammar, natural recursion, cursor movement, captures, scoped state, callable
abstractions, composition, branching, iteration, transformation, and result construction without routine
backend-host escape hatches. Add an optional EBNF-like authoring profile that stays as close to familiar EBNF as
its semantics honestly allow while compiling losslessly into the same canonical LinkedSpec AST/HandlerIR/runtime
used by ordinary `.spec` syntax on every backend.

## Non-Goals

- Literal Turing-completeness as a marketing or acceptance claim.
- Arbitrary filesystem, process, network, environment, clock, randomness, package-loading, or host-FFI authority
  inside `.spec` files.
- A second runtime, second semantic model, backend-specific dialect, or EBNF-looking syntax with hidden magic.
- Replacing LinkedSpec's cursor/progressive-extraction identity with context-free grammar semantics.
- Weakening determinism, resource limits, structured diagnostics, source provenance, or five-backend lockstep.
- Implementing this long-horizon program ahead of already active backend-parity work without a clean, explicit
  scheduling decision.

## Architectural Invariants

1. **Problem-domain closure, not outside-world authority.** The language is self-contained for parsing,
   extraction, cursor/state control, transformation, and result construction. Host runtimes remain the substrate
   and input/result boundary; environmental effects require a separately governed capability design.
2. **One semantics.** Ordinary syntax and every authoring profile lower to one versioned canonical AST/HandlerIR
   contract and use the same validation, compiler, runtime, semantic-introspection, generated-source, and MCP
   projection paths.
3. **Lossless provenance.** Lowering preserves original source, profile identity, exact spans, canonical-node
   correspondence, and diagnostic remapping. Users debug what they authored, not synthetic canonical text.
4. **Honest EBNF resemblance.** A semantic-difference table explicitly separates ordinary EBNF production
   meaning from LinkedSpec seek/consume, ordered matching, cursor/state, captures, actions, and result semantics.
   LinkedSpec-only powers use visible extensions rather than overloading familiar EBNF punctuation deceptively.
5. **Five implementations, one contract.** Perl remains the reference oracle; Rust, Dart, Julia, and Lua consume
   the same neutral fixtures and contract. No backend or authoring profile advances alone.
6. **Evidence before syntax.** Real recursive/progressive formats and current shipped `.spec` constraints drive
   the capability inventory, grammar design, diagnostics, and performance envelope before frontend code lands.

## Acceptance Criteria

- A versioned neutral expressive-self-containment contract defines included language powers and forbidden ambient
  authority without claiming unrestricted computation or I/O.
- A governed capability/gap ledger proves whether normal objectives can be expressed using portable `.spec`
  grammar, recursion, cursor, capture, state, callable, control, transformation, and result primitives.
- The EBNF-like profile has a formal grammar, semantic-difference table, explicit LinkedSpec extensions, lossless
  source map, stable diagnostics, and one-way lowering into the canonical semantic model.
- Ordinary and EBNF-like forms prove canonical-node and runtime equivalence across representative recursive,
  cursor-sensitive, capture-heavy, stateful, and transformation-heavy fixtures.
- Perl, Rust, Dart, Julia, and Lua implement the same accepted contract; native, reconstructed, generated, semantic
  introspection, MCP projection, primary CLI, and mdBook claims remain aligned where applicable.
- Focused, mutation-sensitive neutral checkers and broader repository gates reject semantic forks, host escape
  dependencies, source-map loss, profile/backend drift, and misleading EBNF equivalence claims.
- Each executable leaf updates live docs/mdBook/Knowledge Map and commits through `COMMIT.md` before another leaf.

## Task Tree

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT`
  Status: `active` / capability inventory selected from clean 30b2cc3a0
  Goal: Deliver expressive problem-domain closure plus an optional lossless EBNF-like authoring profile on one
    portable semantic core.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.0`
  Status: `done`
  Goal: Ratify and durably route the director-approved architecture without changing language/runtime behavior.
  Acceptance: Record the problem-domain boundary, one-semantics/profile architecture, lossless-source requirement,
    five-backend obligations, detailed executable decomposition, roadmap/task/live/KM/book alignment, and explicit
    scheduling handoff; run documentation/doctrine gates and commit cleanly.
  Verification: Knowledge Map 762/6,186; mdBook 79 files / 13,884 KiB before exact cleanup; memory, whitespace,
    all seven doctrines, and canonical CI through both CLI environments plus Phase 0 1,031/1,031 in 641 seconds.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.0 - ratify expressive spec self-containment`

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1`
  Status: `active`
  Goal: Specify the neutral expressive-self-containment contract and capability vocabulary.
  Children: `.1.1`, `.1.2`, `.1.3`, `.1.4`
  Dependencies: `.0`

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1`
  Status: `active`
  Goal: Inventory current portable grammar/recursion/cursor/capture/state/callable/control/transformation/result
    powers and every routine host-language escape or expressiveness gap using LinkedSpec tools first.
  Children: `.1.1.1`, `.1.1.2`, `.1.1.3`, `.1.1.4`, `.1.1.5`, `.1.1.6`
  Acceptance: A source-located five-backend ledger separates implemented, partial, missing, compatibility-only,
    backend-host, and deliberately forbidden environmental authority; unassessed objectives are not missing-capability claims.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.1`
  Status: `done`
  Goal: Inventory the grammar, recursion, cursor and capture foundations against campaign needs using existing canonical contracts and bounded fresh tools.
  Activation: Clean 30b2cc3a0d4ecca2a207d46b658287fd6bbb4c7a; .92 committed with all nine doctrines, empty brief, no background job. September27 director steering selects ordinary .spec expressiveness before the broad structured-format campaign; optional alternate syntax remains later.
  Scope: A source-located five-backend evidence ledger, current contract/checker observations, known defect owners, and representative follow-up probes. No runtime, neutral contract, capability admission or format support changes.
  Acceptance: Distinguish contract/admission from fresh runtime proof; cover rule entry/matching, recursion/progress, cursor transactions, source spans and gaps. Keep untested objectives unassessed and schedule their probes. Explain the maturity gate in the book without claiming EBNF equivalence or campaign activation.
  Verification tier: `focused`
  Focused checks: Existing capability/language and relevant neutral grammar/cursor/capture checkers; ledger source-path and exact evidence review; mdBook; memory; history pressure; Knowledge map; all doctrines; git diff --check.
  Canonical trigger: none for an ordinary evidence inventory and scheduling clarification; public semantic contract movement, admission or infrastructure changes require a separate canonical leaf.
  Verification: PASS seven existing neutral/structural checks: capability20/100/0/0; language250/105+1/126; root7/0/54; cursor8/0/60; recognition138/250/58; typed14/0/231; gaps9/0/63. Independent ledger review verifies34 source paths, exact consumer bindings, all referenced completed rollout metadata and the actual stale manifest description. Book rendering and git diff --check pass. Runtime and full-format execution are not claimed; standard memory/history/Knowledge/doctrines govern landing.
  Evidence: docs/language-readiness/grammar-cursor-capture.md is the durable ledger with exact commands and limits. The seven scratch logs below are optional retained transcripts; re-execution does not require them.
  Log: .linkedspec-data/scratch/selfcontain111-capability.log SHA256 6ba5a51e91a3bc49d627b0c4b2c56798b94b899f8755cdf97b9dfd3b4197171b
  Log: .linkedspec-data/scratch/selfcontain111-inter_match_gap_capture.log SHA256 9479cae2bb2b5c57d5f5faf06d182ca4cfa5716d3e9b972341a71ee1e4cdf305
  Log: .linkedspec-data/scratch/selfcontain111-language.log SHA256 d55efe19068d9c2ea9533bb26dbe0469e46e2041881ddd035b547fd3997f44aa
  Log: .linkedspec-data/scratch/selfcontain111-recognition_transaction.log SHA256 21c6046da646342ac46653c4d6d70901b1d0915944a14373fc5976508e3a7688
  Log: .linkedspec-data/scratch/selfcontain111-root_rule_selection.log SHA256 876b2f31e254845ad6c742c1eb5a0694cfdb4714b801136458ac699a9219e792
  Log: .linkedspec-data/scratch/selfcontain111-rule_local_cursor.log SHA256 2ab722ead46c46d940c62b8a5266be5103c5d06f5beef264564a464ab460364d
  Log: .linkedspec-data/scratch/selfcontain111-typed_source_location.log SHA256 1e7b9e4f5674c8c3400e9b7dc8b3d007adb9c08b06a5092cf1346e899495c087
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.1 - inventory grammar readiness foundations`


- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.2`
  Status: `done`
  Goal: Extend the same ledger through scoped state, callable composition, control, transformation and typed result construction, separating host compatibility and approved missing features from defects.
  Dependencies: `.1.1.1`
  Activation: Clean e9c2eb2ad1c6aa799e50c879c0549a9ccd1f36e3, empty brief, nine doctrines passed; no runtime jobs remain.
  Verification tier: `focused`
  Focused checks: Existing uniform-binding, callable-signature/codeblock, logical, scalar-numeric, nested-write and map-leaves neutral tools; source-located consumer/ownership review; book render; memory; Knowledge synchronization; bounded history; all doctrines; git diff --check.
  Canonical trigger: none for a bounded evidence inventory with no runtime, public semantic contract, admission or infrastructure changes.
  Verification: PASS seven unchanged neutral tools: uniform11/7/6/8; signature3/9/7; callable7/11/9/7/4/8/23; logical17/10/3/8/0/26; scalar55/18; writes105 mutations; map-leaves167+592 mutations. Independent review verifies44 source paths, exact logical consumer matrix, mutation admission/source bindings and shared Lua anchors. Book rendering and diff hygiene pass. No runtime or format support claim is added.
  Evidence: docs/language-readiness/state-control-results.md records exact commands, sources, scoping distinctions and pending repair owners. The original immutable mutation contracts retain their status strings; later admission remains external and unchanged.
  Log: .linkedspec-data/scratch/selfcontain112-callable_codeblock.log SHA256 00374dc3966f70d83b0b8bc16056172b0c1a557829a7b73c2d347d32d5d863de
  Log: .linkedspec-data/scratch/selfcontain112-callable_signature.log SHA256 8c05680272db8b7098ece2f93dbc91f936b42cd51fd1330d8e82547b17af884d
  Log: .linkedspec-data/scratch/selfcontain112-logical_helper.log SHA256 2e1ef3f00c07cebb68df6c7fceb219ef3d34debb7c4c670b58461e2129a30b46
  Log: .linkedspec-data/scratch/selfcontain112-map_leaves_mutation.log SHA256 4609559c068ef9eb36d69f63912cd78cd7171d5874aefbacd203c23aacc28874
  Log: .linkedspec-data/scratch/selfcontain112-scalar_numeric.log SHA256 f13ce5475bccd481fb611d852fb630cc4f68ae8d1cba1f90420935904120583c
  Log: .linkedspec-data/scratch/selfcontain112-uniform_binding.log SHA256 5dceaadbc3ebd719926b545d2fa448e92b4c4296bed06870b4c38e41880193d8
  Log: .linkedspec-data/scratch/selfcontain112-write_vivification.log SHA256 16d2aa43e47e05faa40c4ece1d82cf55dc2df1e554a5bb98ee40c999c1a4b447
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.2 - inventory state and computation readiness`
  Acceptance: Each of these five dimensions has current canonical owners, five-backend evidence boundaries, source-located limitations and an executable follow-up where objective composition remains unassessed.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3`
  Status: `active`
  Goal: Execute bounded representative grammar objectives against the inventory before selecting new primitives.
  Dependencies: `.1.1.2`
  Children: `.1.1.3.1`, `.1.1.3.2`, `.1.1.3.3`, `.1.1.3.4`
  Acceptance: Natural nesting, context-sensitive delimiter/indentation state, and lossless staged extraction have exact authored sources, positive/negative inputs, AST/span oracles and runtime/provenance evidence. Reuse existing document grammar and neutral fixtures where suitable; these are readiness probes, not whole-format conformance claims. Split each objective into its own commit before execution if needed.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1`
  Status: `active`
  Goal: Prove a bounded ordinary .spec nested-tree grammar with exact Unicode source spans, recursive state, complete recognition and typed rejection.
  Activation: Clean 57d8b702200ed62107f447c0b8e05b7b19fe577f after .1.1.2, all nine doctrines passed and brief empty. Retrieved strict-document design, public grammar chapter and source-boundary reference before authoring.
  Children: `.1.1.3.1.1`, `.1.1.3.1.2`
  Acceptance: Exact authored spans and strict rejection across the supported routes; no broad campaign readiness claim. The first trial found a Perl constructor defect; repair it in a bounded child before completing the runtime trial.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.1`
  Status: `done`
  Goal: Repair Perl hash-constructor nested shape values without losing bare binding reads when a sibling helper is lowered.
  Priority: P1; blocks the source-aware nesting trial, repair now before .1.1.3.1.2.
  Activation: Same clean 57d8b702200ed62107f447c0b8e05b7b19fe577f; the uncommitted trial decomposes within its existing tree before any runtime edit.
  Reproduce: Assign start = entry_start_pos(), then return(hash("span", [start, cursor_pos()])); public call_spec_handler_subst emits [start, do {...}] and Get returns literal "start". Direct return([start, cursor_pos()]) and the equivalent harray literal correctly read $start. The original six positive / seven negative trial oracles remain unchanged.
  Impact: Silent incorrect nested result values and host syntax failure for nested harray literals in valid .spec hash constructors; this is an implementation defect, not a missing grammar primitive.
  Root cause: MethodLowering.pm lower_ast_aggregate_call_node sends shape arguments through ast_expr_source_node, which keeps ordinary variables in DSL spelling but recursively lowers calls to host Perl. The legacy hash bridge cannot reparse that mixed shape; its raw-expression fallback leaves bare variables unchanged. Direct shape and multi-value array constructors instead consume typed value AST nodes.
  Scope: Bounded Perl lowering repair, exact native/fresh emitted constructor regression and the original nesting fixture; no neutral contract, carrier schema, dependency or format admission change. Keep actual aggregate selectors and flat hash-pair compatibility intact.
  Verification tier: `focused`
  Focused checks: RED/GREEN constructor and nesting results, native/fresh generated reuse and mutation controls; generated-source, uniform-binding, variadic-function, AST and lowering-trace direct dependents; Perl syntax and complete Phase0; book, Knowledge, memory, bounded history, all doctrines and diff hygiene.
  Canonical trigger: none for this backend-local correction to existing value semantics; escalate if public contract, generated format or cross-backend semantics must change.
  Acceptance: Authored numeric/string/null/false/container values, nested helper results and recursive starts are exact; no oracle workaround or host escape hatch. Commit repair before broadening the trial.
  Diagnostic evidence: .linkedspec-data/scratch/selfcontain1131-probe.log and selfcontain1131-lowering.log; original source controls distinguish shape lowering from helper construction.
  Verification: RED old-module preload fails 28/96 new assertions; final candidate passes constructor 96, focused six suites 120 top-level tests, span consumers 18 and complete Phase0 1033/1033 in 1043 seconds. Exact book snippet and rendered grammar/oracle, all nine doctrines, memory and bounded history pass. Commands and SHA256 logs: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.1-verification.json.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.1 - preserve nested hash values`

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Public `LinkedSpec::Get` and `call_spec_handler_subst` in the recorded probe show list span starts as the string "start", versus the unchanged authored numeric oracle; direct-shape controls read the binding correctly. Native and `emit_generated_source` old-module regression fails 28/96 assertions in the one new constructor subtest.
- [x] **ROOT CAUSE (WHY + WHERE)** — WHY: `ast_expr_source_node` reconstructs a mixed DSL/host shape, and the hash compatibility bridge cannot reparse it. WHERE: `perl/LinkedSpec/ActionIR/MethodLowering.pm`, `lower_ast_aggregate_call_node` and its legacy hash bridge; public lowering and fresh generated source expose the bareword and leaked colon syntax. This is a real engine defect; no expected value is re-blessed.
- [x] **FIX** — Construct hash pairs from typed value AST nodes directly, preserving key normalization and explicit flat-list compatibility. Nested helpers, bound values and emitted harrays no longer cross a DSL reparse boundary. Scope is the director-authorized defect repair within the selected readiness objective.
- [x] **ADDRESSED (verified)** — `prove -v -Iperl t/generated_source_contract.t` passes the new 96-assertion subtest; the old-module preload fails it. `comm -23` clears exactly `hash constructor shapes preserve values beside nested helpers`; `comm -13` is empty. Native and fresh emitted engines execute each original input sequence twice; fake-source AST checks preserve typed fields.
- [x] **NO REGRESSION** — `prove -v -Iperl t/phase0_regression.t` reaches its true `1..1033` stop and PASS in 1043 seconds, with an empty failure-name set. Six focused suites pass 120 top-level tests; source-span consumers pass 18. `perl -c perl/LinkedSpec.pm` and `perl -c -Iperl t/phase0_regression.t` pass. Exact commands/log hashes are in this leaf's verification checkpoint.
- [x] **LOCKSTEP** — Book reference/example/status, CHANGES, DEVELOPMENT_NOTES, MEMORY, live status, roadmaps, task tree and Knowledge Map reflect this repair. Exact rendered grammar/AST and executable book snippet pass. USER_GUIDE is unchanged because the relevant constructor explanation is owned by the book. History limits and `git diff --check` pass; final staged doctrines govern landing.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2`
  Status: `active`
  Goal: Complete nested-tree readiness proof across supported public native/carrier routes after the Perl repair.
  Dependencies: `.1.1.3.1.1`, `.1.1.6`
  Acceptance: Exact positive/negative values and Unicode spans, prefix/gap/span mutation sensitivity, same-engine reuse and ActionIR readiness; record exact routes and limitations without arbitrary resource or whole-format claims.
  Children: `.1.1.3.1.2.1`, `.1.1.3.1.2.2`, `.1.1.3.1.2.3`

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.1`
  Status: `done`
  Goal: Run the unchanged nested-tree grammar and independent six-positive/seven-negative oracles through all six public native text consumers.
  Activation: Clean fa8b0e8af019b3ded4c17f423a122f9b1decfa9b after generic flat repair; all nine hooks and post-commit pointer pass, brief0, no pending job.
  Scope: Bounded public-loader readiness observations and a repeatable repository-local verifier. Reuse documented integration adapters, prepared local stores and supported builds. Do not alter grammar, oracle or dependency pins to obtain a pass. Only the next child owns carrier/typed-recovery/mutation proof.
  Verification tier: `focused`
  Focused checks: All six runtime adapter executions against exact authored values/spans and rejection outcomes; repeated accepted inputs through one engine; unchanged grammar/oracle/adapters; book render; Knowledge, memory, bounded history, doctrines and diff hygiene.
  Canonical trigger: none for a bounded readiness probe without runtime, neutral contract, admission or infrastructure change; parent closeout remains canonical.
  Acceptance: Preserve original input/expected bytes. Report exact native routes and whether each error is typed or Display-only. Any failure gets tool-first minimized diagnosis and an owned repair before wider readiness claims.
  Verification: PASS all six public native adapters:6 accepts,7 rejects,12 exact same-engine accepted parses each. Original grammar/oracle/adapters unchanged; JSON kinds and Unicode scalar spans exact. Published locked offline Rust build passes. Ledger and checkpoint retain typed/Display and recovery limitations.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.1 - verify native nesting readiness`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Existing Perl `LinkedSpec::Get`/fresh emitted proof covers the nesting fixture, but a cross-backend claim requires running the same authored oracle through public loaders. This leaf fills that evidence gap without changing runtime behavior.
- [x] **ROOT CAUSE (WHY + WHERE)** — WHY: neutral feature inventories do not establish composed grammar correctness across implementations. WHERE: the six public text adapters under `examples/integration/` expose compile-once/native execution and their documented error projections; `tests/language-readiness/nested-tree/verify_native.py` now checks the exact fixture through them.
- [x] **FIX** — Add a bounded repeatable native verifier with exact JSON-kind/span comparison, forward/reverse accepted execution, exact rejected outcomes and unchanged source/product hashes. The grammar and all original expectations remain intact.
- [x] **ADDRESSED (verified)** — All six runtime invocations PASS: six accepted cases, seven rejected cases and twelve accepted parses per engine. No rejected value is emitted. The ledger and checkpoint identify each public route, command and protected source/product hash.
- [x] **NO REGRESSION** — Published locked offline Rust integration build succeeds; all six existing adapters execute unmodified. `git diff --exit-code HEAD -- tests/language-readiness/nested-tree/grammar.spec tests/language-readiness/nested-tree/cases.json examples/integration` passes. No runtime changes require Phase0 in this evidence-only leaf; book, memory/history/Knowledge, doctrines and diff hygiene govern landing.
- [x] **LOCKSTEP** — The book's bounded grammar section reports exact six-runtime native coverage and honest carrier/recovery limits, with repeatable commands. CHANGES, DEVELOPMENT_NOTES, MEMORY, live status, roadmaps, task frontier, ledger and Knowledge Map route remaining work to .1.1.3.1.2.2. No standard-format support or broad campaign admission is claimed.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2`
  Status: `active`
  Goal: Verify supported serialized/reconstructed/generated/emitted nested-tree routes, same-engine recovery after typed rejection, readiness descriptors and prefix/gap/span mutation sensitivity.
  Dependencies: `.1.1.3.1.2.1`
  Acceptance: Split backend-sized children before implementation; retain the same authored oracles and honest carrier coverage. No blanket proof from native results.

  Children: `.1.1.3.1.2.2.1`, `.1.1.3.1.2.2.2`, `.1.1.3.1.2.2.3`, `.1.1.3.1.2.2.4`, `.1.1.3.1.2.2.5`

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1`
  Status: `active`
  Goal: Prove Perl nested-tree carrier semantics using native Get and fresh emitted subprocess, typed rejection/recovery and prefix/gap/span mutation controls.
  Acceptance: Original grammar/cases remain unchanged; exact value kinds and Unicode spans, no partial rejection values, explicit recovery after every rejection and honest carrier/readiness coverage.
  Activation: Clean425153473d7a795c6a61ca5c1e2d4602cd1fc851; native proof committed, all nine hooks and post-commit pointer pass, brief0 and no pending job.
  Scope: One new Perl regression consumes the shared fixture, public descriptor, native Get and fresh emitted subprocess. Three controlled grammar mutations demonstrate rejection/span sensitivity; do not change runtime semantics or original oracles.
  Children: `.1.1.3.1.2.2.1.1`
  Verification owner: The repair child carries this slice's sole tier/check/trigger declarations; final parent closure remains the canonical reconciliation milestone.
  Finding: Tool-backed prefix mutation reveals emitted public-entry drift. Its child owns immediate repair; all remaining parent proof is retained and closes only after that repair passes.
  Verification: All planned Perl evidence is verified and committed through child .1.1.3.1.2.2.1.1; canonical parent reconciliation is owned by .1.1.3.1.2.3 after the remaining backend children.
  Commit: Proof and repair land together in `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1 - align emitted public entry`; final parent closure belongs to canonical reconciliation.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1`
  Status: `done`
  Goal: Restore the existing Perl public-entry leading blank/comment skip in fresh emitted Execute before completing carrier proof.
  Priority: P1 now; blocks honest native/emitted mutation parity.
  Activation: Same clean425153473d7a795c6a61ca5c1e2d4602cd1fc851 as the uncommitted parent probe; decompose in the same tree before any runtime edit.
  Reproduce: New nested_tree_readiness.t fails only prefix emitted mutation108/120. Public minimal Top I.return(cursor_pos()) returns6 natively versus0 emitted for #skip followed by LF and (a), and1 versus0 for leading LF; ordinary (a) gives0 on both. Exact observations: .linkedspec-data/scratch/nested-perl-entry-probe.log.
  Root cause: Runtime.pm run_get wraps native parser entry with position reset and leading complete blank/hash-comment-line skipping. Compiler.pm generated source postamble Execute line318 resets pos0 but never invokes that skip. Generated-source public Execute therefore bypasses the native public boundary; direct descriptor handlers are intentionally a different internal boundary.
  Impact: A valid emitted parser can observe different entry cursor/source spans and acceptance from native Get. The original strict nesting grammar masks the difference because its prefix guard plus catch-all reject both paths; the guard-removal mutation exposes it. No RGX/PGEN defect or grammar workaround.
  Scope: Share the existing safe scalar-ref public-entry preparation between native wrapper and emitted Execute, preserve invalid-input ownership and absolute source positions, and lock LF/comments/EOF/Unicode/non-skipped CRLF and child behavior. No helper syntax, v2 schema or neutral contract change.
  Related book defect owned here: runtime-semantics.md section10.3 conflates .spec source validation with runtime input, claiming nonblank text and an initial rule declaration are always required. The unchanged empty nesting case and new empty/ordinary/comment-only entry controls prove that false; correct this directly alongside the entry API documentation. No runtime validation policy is relaxed.
  Verification tier: `focused`
  Focused checks: Exact old-source RED/new-source GREEN; native/fresh emitted entry controls plus original nesting, typed recovery and three mutations; generated-source, strict-document, typed-source, runtime-owner/input-boundary direct dependents; required syntax and complete Phase0; book, Knowledge, memory/history, doctrines and diff hygiene.
  Canonical trigger: none for correcting this backend carrier to the existing admitted public-entry semantics without schema or contract movement; parent milestone remains canonical.
  Acceptance: One source-owned public entry rule, no duplicated child skipping, unchanged original oracle and input content, exact error boundaries. Commit repair before remaining carrier branches.
  Focused evidence: New regression passes192 top-level tests; five suites pass274 in97s. Baseline fails15/192 (one prefix mutation plus seven entry controls repeated twice). Public minimal probe now agrees6/6,1/1,0/0. Complete Phase0 later passes1033/1033 in1026s.
  Knowledge: docs/knowledge/perl-emitted-public-entry-trivia.md records exact mechanism, routes, source boundaries and related book correction.
  Gate transcript: .linkedspec-data/scratch/nested-entry-phase0.log is the complete-run target; only a true1..1033 and PASS closes it. Final focused log is nested-entry-focused.log; authoritative retained-owner RED is nested-entry-final-red-forced.log. Naive preload nested-entry-final-red.log selected current Compiler and is explicitly not RED evidence.
  Landing correction: The first pre-commit attempt rejected duplicate tier declarations on the newly decomposed parent and repair child. Remove the parent's leaf declarations and retain the child as the sole verification owner; no source/test change or bypass.
  Verification: Forced clean-owner RED15/192; candidate new regression192, focused274, full Phase01033/1033 in1026s. Original fixture unchanged; five ready rules,40 original native/emitted executions each,14 typed recoveries each, three mutants,14 entry controls repeated twice and two child controls. Book and standard gates pass; exact checkpoint: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1-verification.json.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1 - align emitted public entry`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Public `LinkedSpec::Get` versus `emit_generated_source` cursor probes show6/0 for #skip plus LF and1/0 for leading LF. The nesting prefix mutation exposes the same divergence. The pre-edit run and exact clean-owner preload both fail15/192 assertions; the naive preload that selected current Compiler is excluded.
- [x] **ROOT CAUSE (WHY + WHERE)** — WHY: native Runtime applies public leading-trivia preparation but emitted Execute only resets0. WHERE: `perl/LinkedSpec/Runtime.pm` run_get wrapper and `perl/LinkedSpec/Compiler.pm` generated postamble; public source emission shows the missing step. Direct child/descriptor handlers intentionally bypass public preparation. The original grammar's two rejection guards had masked the difference.
- [x] **FIX** — Extract the existing scalar-ref-safe preparation into Runtime, call it from native wrapper and freshly emitted Execute, and load that owner in emitted source. Preserve full input, absolute Unicode positions, child entry, guard ownership and v2 schema. Correct the nearby book confusion between .spec compilation and ordinary parser input.
- [x] **ADDRESSED (verified)** — New regression192 passes natively and through an independently loaded emitted process: five-rule readiness,40 original executions per route,14 immediate typed status1 recoveries, exact result kinds/spans, prefix/gap/span mutants,14 entry controls repeated twice and two child controls. Baseline/current failure-name comparison removes all15 failures and adds none.
- [x] **NO REGRESSION** — Five focused suites pass274; complete `prove -v -Iperl t/phase0_regression.t` reaches true `1..1033` and PASS in1026s. Required syntax passes; unchanged original grammar/cases and source/log hashes are recorded. Existing uninitialized-subtraction warnings have a matching pre-repair baseline and are not new failures.
- [x] **LOCKSTEP** — Public API examples, pipeline/appendix explanations, bounded nesting coverage, Knowledge Map, task tree, ledger, CHANGES, DEVELOPMENT_NOTES, MEMORY, live status and roadmaps agree. Exact book rendering, history limits, memory and diff hygiene pass; final staged doctrines govern landing. Parent milestone closure remains separate from this bounded repair.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.2`
  Status: `done`
  Goal: Prove Rust nested-tree carrier semantics using native, reconstructed and generated supported routes, typed rejection/recovery and prefix/gap/span mutation controls.
  Acceptance: Original grammar/cases remain unchanged; exact value kinds and Unicode spans, no partial rejection values, explicit recovery after every rejection and honest carrier/readiness coverage.
  Dependencies: `.1.1.3.1.2.2.1.1` (verified Perl proof; parent status closes at canonical reconciliation).

  Activation: Clean bb76f4437b36216cdd2a609ec70b8570ffaa12d8 after verified Perl repair; all nine hooks/post-commit pointer pass, brief0 and no pending job.
  Verification tier: `focused`
  Focused checks: New Rust native/reconstructed/generated-plan/emitted nesting regression; strict-document and leading-trivia consumers; published locked offline Cargo preparation, actual emitted-child exit status and counts, unchanged grammar/cases; book, Knowledge, memory/history, doctrines and diff hygiene.
  Canonical trigger: none for a bounded backend regression without runtime, schema, contract or admission change; parent closure remains canonical.
  Scope: Reuse typed public parser/compiler/engine and generated-source APIs. Keep native/reconstructed retained-engine recovery distinct from APIs that construct an engine per call. Fresh emitted module must compile/run in repository-local storage with a relative dependency path and real child-status checking; do not reuse known .71/.77/.78 test-harness defects.
  Verification: Two new Rust tests pass; emitted child exit0/four tests. Six routes each execute40 original cases plus three mutations; four retained-engine routes prove56 typed rejection recoveries. Leading-trivia3 and strict-document1 pass; rustfmt and unchanged fixture checks pass.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.2 - verify Rust nesting carriers`.


- [x] **REPRODUCE / ISSUE** — Native text-adapter proof lacks typed errors, retained-engine rejection recovery and carrier equivalence; the unchanged six accepts/seven rejects are the independent oracle.
- [x] **ROOT CAUSE (WHY + WHERE)** — This is an evidence gap: the public adapter exits on rejection. Typed Engine, serialized v2 and emitted-module APIs expose the missing routes without runtime changes.
- [x] **FIX** — Add a shared value/kind/span oracle and separate retained-engine versus per-call routes; compile four fresh emitted modules in owned local storage with relative dependencies and actual child-status checks.
- [x] **ADDRESSED (verified)** — All six routes pass40 original calls and three prefix/gap/span mutants each. Four retained-engine routes pass14 immediate recoveries each; other routes prove independent subsequent calls only. Generated plans validate; emitted metadata identifies v2 and exact source.
- [x] **NO REGRESSION** — New Rust tests2/2, child4/4, leading-input3/3 and strict-document1/1 pass offline. Runtime, lockfile, original grammar/cases and public adapters are unchanged. Rustfmt and diff hygiene pass.
- [x] **LOCKSTEP** — Book, native ledger, dedicated Knowledge fact, checkpoint, live pointers, roadmaps and change/engineering notes state exact coverage and remaining Dart/Julia/Lua work; no format admission or parent closure.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.3`
  Status: `done`
  Goal: Prove Dart nested-tree carrier semantics using native, reconstructed and independently emitted supported routes, typed rejection/recovery and prefix/gap/span mutation controls.
  Acceptance: Original grammar/cases remain unchanged; exact value kinds and Unicode spans, no partial rejection values, explicit recovery after every rejection and honest carrier/readiness coverage.
  Dependencies: `.1.1.3.1.2.2.2`

  Activation: Clean 1a5296777bb4a6e390bebfc010f9fc41db13cce0 after Rust carrier proof; nine doctrines/post-commit pointer pass, brief0 and no job remains.
  Verification tier: `focused`
  Focused checks: New Dart native/reconstructed/generated-plan/emitted nesting regression, strict-document and source-emitter direct dependents, strict changed-file/child analysis plus package-wide diagnostic census, exact child status/report, unchanged fixtures, book, Knowledge, memory/history, doctrines and diff hygiene.
  Canonical trigger: none for bounded backend evidence without runtime/schema/contract/admission change; parent closure remains canonical.
  Scope: Typed public parser/compiler/engine and generated APIs; distinguish four retained-engine routes from per-call v2/emitted entry functions. Child uses an owned repository-local package with relative dependency and offline preparation.
  Verification: New tests 2/2 and existing emitter/document tests 58/58 pass. Six routes each execute 40 original calls and three mutations; four retained-engine routes prove 56 recoveries. Child offline preparation, strict analysis and run exit0 with exact four-module report. Changed-file strict analysis/format pass; whole-package analysis retains only the two known .2.25 deprecations.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.3 - verify Dart nesting carriers`.


- [x] **REPRODUCE / ISSUE** — The native text adapter stops at rejection and does not prove carriers or recovery. Consume the unchanged six accepts/seven rejects through typed public Dart APIs.
- [x] **ROOT CAUSE (WHY + WHERE)** — Missing evidence belongs to the public execution boundary: Engine retains state across calls; executeGeneratedParserV2 and emitted execute construct an engine per call. SpecFile JSON reconstruction is distinct from compiled-state serialization.
- [x] **FIX** — Add explicit recursive JSON-kind/value/span checks, typed status1 exits and recovery pairs; independent emitted package loads four source variants with relative dependencies and checked process statuses.
- [x] **ADDRESSED (verified)** — All six routes pass 40 original calls and three grammar mutations; four retained-engine routes prove 14 recovery transitions each. Plans validate; emitted metadata/source identity and four-module completion report are exact.
- [x] **NO REGRESSION** — New2/existing58 tests pass; new-file and child fatal analysis pass, formatter changes0. Package analyzer exit2 reproduces only existing matching.dart:732/1203 deprecated_implement warnings owned by DART-STARTUP-READING.2.25; runtime/lock/oracles/adapters are unchanged. No complete component-gate success is claimed.
- [x] **LOCKSTEP** — Book, ledger, Knowledge, checkpoint, roadmaps and live/history records name exact carrier coverage and analyzer limitation; Julia/Lua and canonical parent closure remain separately owned.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.4`
  Status: `done`
  Goal: Prove Julia nested-tree carrier semantics using native, reconstructed/generated-plan and emitted supported routes, typed rejection/recovery and prefix/gap/span mutation controls.
  Acceptance: Original grammar/cases remain unchanged; exact value kinds and Unicode spans, no partial rejection values, explicit recovery after every rejection and honest carrier/readiness coverage.
  Dependencies: `.1.1.3.1.2.2.3`

  Activation: Clean e0173014f71d49a13c4f82daf6926965360fa3c2 after Dart carrier proof; nine doctrines and post-commit pointer pass, brief0 and no pending job.
  Verification tier: `focused`
  Focused checks: Extend existing Julia source-emitter tests with nesting carriers/mutations, unchanged strict-document compatibility, exact child status/report and storage oracle; unchanged fixture/manifest, book, Knowledge, memory/history, doctrines and diff hygiene.
  Canonical trigger: none for bounded backend evidence without runtime/schema/contract/admission or storage mechanism changes; parent closure remains canonical.
  Scope: Public native and SpecFile-reconstructed retained engines, public generated entry for both compiled forms and fresh emitted host: five routes. Only two routes retain an engine. Reuse the existing emitter test owner and offline private-depot host helper; do not use private generated-family runtime keywords.
  Harness issue resolved: First new suite29/30 errored on a successful child report polluted by world-age warnings. Full warning capture locates new-module binding access; use invokelatest for binding lookup as well as invocation. Final child report is exact, with no warning stripping.
  Verification: PASS 30 new nesting assertions,65 existing emitter and128 strict-document assertions (223 total); exact child exit/report, five routes with40 original calls/three mutations each,28 retained-engine recovery transitions. Storage22 owners/five package trees passes; original fixtures/runtime/manifests unchanged.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.4 - verify Julia nesting carriers`.


- [x] **REPRODUCE / ISSUE** — Public native text-adapter proof omits retained-engine rejection recovery and generated carriers. The first new host29/30 also exposes Julia world-age warnings before its otherwise successful JSON report.
- [x] **ROOT CAUSE (WHY + WHERE)** — Generated v2 entry reconstructs an engine per call; public runtime_parse retains an engine. In the new child runner, direct getfield reads bindings created by Base.include from an older function world; wrapping only later calls in invokelatest is insufficient. Full captured warnings identify each access.
- [x] **FIX** — Extend the existing emitter test owner with native/reconstructed/v2/emitted cases and shared exact JSON-kind/span oracles. Resolve new-module bindings through invokelatest, matching the established emitter host pattern; preserve actual child status and exact report checks.
- [x] **ADDRESSED (verified)** — Five routes each pass40 original calls and three mutations; two retained-engine routes prove14 recoveries each. RuntimeExitNow status1 is mandatory; null success cannot pass rejection. Four emitted modules validate v2 metadata/plans and execute in a fresh offline child with exact report and recursive cleanup.
- [x] **NO REGRESSION** — New30/existing emitter65/strict-document128 assertions pass. Storage oracle retains22 owners/five locked package trees. Runtime, manifests, original grammar/cases and adapters are unchanged; no private generated-family keyword or full component-gate claim.
- [x] **LOCKSTEP** — Book, native ledger, Knowledge fact, checkpoint, task/live pointers, roadmaps and technical history report five routes and28 retained-engine recoveries; Lua and canonical reconciliation remain separate.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.5`
  Status: `pending`
  Goal: Prove Lua nested-tree carrier semantics using both ABIs across native, reconstructed/generated-plan and emitted supported routes, typed rejection/recovery and prefix/gap/span mutation controls.
  Acceptance: Original grammar/cases remain unchanged; exact value kinds and Unicode spans, no partial rejection values, explicit recovery after every rejection and honest carrier/readiness coverage.
  Dependencies: `.1.1.3.1.2.2.4`

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.3`
  Status: `pending`
  Goal: Reconcile nested-tree readiness evidence, authoring costs and limitations, and close its parents through canonical milestone proof.
  Dependencies: `.1.1.3.1.2.2`
  Acceptance: Source-located native/carrier/mutation ledger and book agree; canonical receipt governs closure before context-dependent objective .1.1.3.2.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2`
  Status: `pending`
  Goal: Probe context-dependent matching with nested opening/closing names or indentation state using ordinary .spec, exact rejection and restoration controls.
  Dependencies: `.1.1.3.1`
  Acceptance: Source-located, bounded native/carrier evidence establishes whether existing explicit state and comparisons express the objective clearly; record and schedule any minimal reusable gap without claiming XML/YAML support.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3`
  Status: `pending`
  Goal: Probe lossless segmentation and bounded child parsing with exact source provenance and caller-authorized dispatch.
  Dependencies: `.1.1.3.2`
  Acceptance: Every original scalar belongs to a tested segment; child bounds and composed spans are exact; no host parsing escape or ambient loading is introduced. Keep private carrier and public authoring boundaries explicit.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.4`
  Status: `pending`
  Goal: Reconcile the three bounded objective results and authoring costs for gap selection under `.1.1.4`.
  Dependencies: `.1.1.3.1`, `.1.1.3.2`, `.1.1.3.3`
  Acceptance: Preserve exact runtime/carrier coverage, limitations, mutations and repair owners; require fresh proof before promoting any objective and keep whole-format campaign readiness pending.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.4`
  Status: `pending`
  Goal: Reconcile the finite inventory and representative evidence into an owned gap list for `.1.2` and `.1.4`.
  Dependencies: `.1.1.3`
  Acceptance: Every observed gap is implemented, partial, missing, compatibility-only, backend-host or deliberately forbidden; untested objectives remain separately unassessed. New capability proposals identify reusable semantics and portable proof, and existing defects retain their original repair owners and priority. Do not imply an exhaustive proof of every possible grammar.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.5`
  Status: `pending`
  Goal: Repair the stale general capability description of removed global parse-mode controls and guard recurrence.
  Priority: P2; after representative inventory reconciliation `.1.1.4`, before `.1.2` uses that manifest as closure authority. Coordinate startup `.41.2` without duplicating its broad guide repair.
  Reproduce: Run perl tools/check_capability_conformance.pl (passes 20/100/0/0), then compare manifest capability runtime.top_rule_and_parse_mode_controls.contract with rule_local_cursor_contract.json policy.global_override. The former says native execution accepts seek/consume parse-mode controls; the latter removes public overrides, and the public rule-mode guide documents targeted rejection.
  Root cause: tools/check_capability_conformance.pl validate_manifest requires a nonempty contract string for general rows (line797 at activation), while exact text checks at line606 apply only to the two mutation capabilities. No current semantic assertion binds this general row to the rule-local-cursor authority.
  Impact: Inventory readers can infer a removed option is supported from a green census. No runtime regression is asserted.
  Acceptance: Preserve stable capability identity where required, reconcile its description to explicit entry selection and intrinsic family cursor policy, and add a reason-sensitive regression that rejects the stale claim. Verify dependent capability/generated-source consumers and public teaching; use canonical tier for checker/contract admission movement.
  Verification: .1.1.1 freshly passes the capability checker and the specific cursor checker against the contradictory unchanged source. Exact source/read-only reproduction is retained in docs/language-readiness/grammar-cursor-capture.md.
  Commit: pending.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.6`
  Status: `done`
  Goal: Repair generic flat(meta) constructor splicing for a scalar-held harray in Perl; coordinate broad typed aggregate owner SESSION-STARTUP-READING.17.
  Priority: P1 next; the director explicitly requests immediate repair after the current constructor commit, before remaining nesting proof. The grammar does not splice flattened values, but the defect is now the selected next slice.
  Reproduce: Top assigns meta = {"existing":1}; value = 7; return(hash(flat(meta), "added", value)) returns null, whereas changing only flat to flat_hash returns {"existing":1,"added":7} through public Get.
  Impact: Documented generic flat composition fails for a typed binding; explicit flat_hash is the bounded current control, not a fix.
  Diagnosis: Public call_spec_handler_subst reports unsupported hash for generic flat. MethodLowering lower_flat_list_value_expr's generic flat path recognizes legacy aggregate containers/value shapes but lacks the scalar-held harray branch present in flat_hash. Capture baseline, neutral semantics and all affected argument contexts before repair; do not infer all flattening routes from this one case.
  Evidence: .linkedspec-data/scratch/selfcontain11311-flat.log; discovered while expanding .1.1.3.1.1 regression. That repair's flattening compatibility control explicitly uses flat_hash.
  Acceptance: Source-located RED/GREEN native/fresh emitted proof with exact result kinds and affected scalar-held array/harray contexts; preserve task .17's broader obligation.

  Activation: Clean 0b0cccf52781a03c5d7a1418212a42d180e03697 after constructor .1.1.3.1.1; all nine staged doctrines and post-commit pointer pass, brief empty. Director-selected immediate repair.
  Scope: Perl generic flat on scalar-held and computed array/harray values in existing constructor contexts, including direct reads, parameter/local state and empty-container controls. The public preflight confirms these share static-only generic flattening selection; preserve legacy accumulator and explicit-helper compatibility. No unrelated helper contract change.
  Verification tier: `focused`
  Focused checks: Public Get/substitution RED/GREEN against explicit helper controls; exact native/fresh emitted result kinds, reuse, ordinary nested-value and snapshot controls; generated-source, uniform-binding, variadic, AST and lowering-trace suites; Perl syntax and complete Phase0; exact book example/rendering, Knowledge, history, memory, doctrines and diff hygiene.
  Canonical trigger: none for a backend-local correction to existing scalar-held container semantics; escalate for neutral contract, generated-format or cross-backend semantic movement.
  Expanded diagnosis: Public Get/substitution in .linkedspec-data/scratch/selfcontain116-probe.log confirms typed hash/array/empty bindings, copied containers and nested reads fail (unsupported hash, unresolved host flat/copy call, or leaked DSL indexing). Literal-container and explicit flat_array/flat_hash controls pass. Generic selection statically recognizes container shapes but cannot dispatch on runtime container values; use the typed argument AST and one runtime kind check without reparsing lowered host source.
  Compatibility finding: Public substitution of [flat(IMATCH_LIST)] and [flat(LMATCH_LIST)] leaks host barewords, whereas flat_array reads the actual arrays. The clean 0b0cccf52 module produces byte-identical failing observations (cmp of selfcontain116-legacy.log and selfcontain116-legacy-baseline.log). Generic static inference classifies these as arrays but the scalar source reader deliberately excludes reserved engine locals. Own their matching capture-array/harray compatibility repair here via the existing explicit helpers; do not teach private names as new .spec syntax.
  Gate lifecycle: The first Phase0 run was stopped after this additional compatibility finding so the final source can receive one complete run. selfcontain116-phase0.log is incomplete and is not proof; final gate uses selfcontain116-phase0-final.log.
  Fixture correction: The added public-capture test initially read entry_groups/entry_named_map in the regex-free parent's edge action. Public Get controls without flat prove parent entry values are []/{} while the matched child's I action has ["a","b"] and its named map (selfcontain116-entry-control.log). Move that test action into the matched child, retaining its exact original capture oracle; this was test placement, not another engine defect.
  Focused evidence: Final six-suite run selfcontain116-focused-final-v2.log passes120 top-level tests and164 assertions in the expanded constructor/flat subtest. Clean-module preload selfcontain116-final-red-v2.log fails31/164, exclusively that subtest. Required syntax, exact rendered shared example/output and all nine doctrines pass. The final complete Phase0 result below supersedes this pending-run observation.
  Verification: Old-module preload fails 31/164 assertions, only the expanded constructor/flat subtest. Candidate passes all164; six focused suites120, syntax and complete Phase01033/1033 in 1040s. Shared LF/CRLF book source and exact rendered output pass. Commands and hashes: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.6-verification.json.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.6 - flatten bound container values`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Public `LinkedSpec::Get` and `call_spec_handler_subst` show generic flat(meta) failing while flat_hash(meta) succeeds. Bound arrays, copies and nested reads leak host calls/indexing. Clean-module preload fails 31/164 regression assertions; all failures belong to the expanded constructor/flat subtest.
- [x] **ROOT CAUSE (WHY + WHERE)** — WHY: generic flattening infers kind from source shape instead of the runtime value, and reparsing an emitted argument loses typed DSL structure. WHERE: `perl/LinkedSpec/ActionIR/MethodLowering.pm`, `lower_flat_list_value_expr` and `lower_ast_aggregate_call_node`. Private capture names additionally require their existing aggregate storage rather than scalar reads. Public lowering and baseline controls locate both mechanisms.
- [x] **FIX** — Lower supported bound/computed arguments from their typed AST, evaluate once, and splice runtime array elements or harray pairs. Hash constructors reuse that path. Known legacy aggregate and private capture slots use existing compatibility helpers; explicit helpers remain unchanged.
- [x] **ADDRESSED (verified)** — Native Get and independently loaded emitted parsers pass all164 assertions, including repeated execution, typed members, function scope, empty containers, capture values, a side-effect counter and mutation independence. Baseline/current failure-name comparison removes exactly the constructor/flat subtest and introduces none. Fake-source AST controls prove the typed argument is consumed.
- [x] **NO REGRESSION** — Six focused suites pass120 top-level tests; complete `prove -v -Iperl t/phase0_regression.t` reaches `1..1033` and PASS in 1040s with no failing names. Both required Perl syntax checks pass. The interrupted earlier Phase0 run is explicitly excluded from evidence.
- [x] **LOCKSTEP** — The shared executable book example passes natively and freshly emitted with LF/CRLF; rendered source/output match. Book reference/status, CHANGES, DEVELOPMENT_NOTES, MEMORY, live status, roadmaps, task tree and Knowledge Map describe the repair. USER_GUIDE's canonical book delegation remains unchanged. Bounded history, memory, doctrines and diff hygiene govern landing.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2`
  Status: `pending`
  Goal: Define the problem-domain closure boundary, determinism/resource model, state/scoping rules, and explicit
    environmental non-authority.
  Acceptance: Normative contracts answer what a `.spec` may compute, observe, mutate, return, and never access,
    including recursion/iteration limits, failure behavior, and host-boundary inputs/results.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3`
  Status: `pending`
  Goal: Build neutral fixtures and a mutation-sensitive checker for representative self-contained objectives.
  Acceptance: Fixtures cover natural recursion, cursor algebra, interval/boundary capture, nested state, callable
    composition, branching/iteration, structural transformation, and typed result construction; mutations prove
    every claimed semantic dimension matters.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.4`
  Status: `pending`
  Goal: Close the contract/gap audit and split only evidence-backed missing primitives into separately ordered
    implementation leaves before any behavior change.
  Acceptance: Every gap has one owner, portable semantics, test oracle, backend order, compatibility policy, and
    documentation obligation; speculative general-purpose features remain excluded.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.2`
  Status: `pending`
  Goal: Formalize the single canonical syntax-independent semantic model and lowering contract.
  Children: `.2.1`, `.2.2`, `.2.3`
  Dependencies: `.1`

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.2.1`
  Status: `pending`
  Goal: Version canonical AST/HandlerIR nodes for grammar, cursor, capture, state, callable, control, transform, and
    result semantics with no source-profile or backend execution authority.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.2.2`
  Status: `pending`
  Goal: Define lossless authored-source provenance, profile identity, node correspondence, and diagnostic remapping
    through validation, compilation, serialization, generated source, semantic introspection, and MCP projection.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.2.3`
  Status: `pending`
  Goal: Govern one normalizer/validator/runtime path and reject semantic forks or profile-specific execution.
  Acceptance: Independent checkers reject duplicate semantic owners, backend/profile-only nodes, lossy source
    maps, noncanonical generated state, and diagnostics that point only at lowered synthetic text.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.3`
  Status: `pending`
  Goal: Close evidence-backed expressive gaps on ordinary `.spec` syntax before using an alternate profile to hide
    missing core semantics.
  Dependencies: `.1.4`, `.2`
  Acceptance: Each missing primitive is implemented Perl-first then Rust/Dart/Julia/Lua in lockstep, with neutral
    fixtures, generated/semantic/MCP projections where applicable, docs, and full gates; no host escape is added.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.4`
  Status: `pending`
  Goal: Specify the optional EBNF-like authoring profile as a transparent frontend to the canonical model.
  Children: `.4.1`, `.4.2`, `.4.3`, `.4.4`
  Dependencies: `.2`, sufficient `.3` closure for representative fixtures

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.4.1`
  Status: `pending`
  Goal: Publish the semantic-difference table between EBNF and LinkedSpec.
  Acceptance: Production choice/sequence/repetition/grouping/optionality/terminal/nonterminal semantics are
    compared explicitly with ordered search, seek/consume, recursion, cursor ownership, captures, state/actions,
    failure/backtracking, and result construction; every non-EBNF power remains visibly spelled.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.4.2`
  Status: `pending`
  Goal: Define the profile grammar and minimal explicit LinkedSpec extensions.
  Acceptance: Familiar EBNF notation is retained where semantics truly agree; cursor/capture/state/action/result
    constructs are composable, unambiguous, round-trippable, and never disguised as standard EBNF.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.4.3`
  Status: `pending`
  Goal: Define deterministic lowering, canonical equivalence, formatting, and source-map/diagnostic contracts.
  Acceptance: Equivalent ordinary/profile fixtures yield the same canonical semantic digest and runtime result;
    authored spans/messages survive invalid syntax, invalid semantics, recursion, and generated reconstruction.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.4.4`
  Status: `pending`
  Goal: Prove the proposed profile against at least three real recursive/progressive formats before implementation.
  Acceptance: Trials include nested recursion, deliberate cursor repositioning, nontrivial capture intervals, and
    typed transformation; awkward or misleading notation triggers redesign, not hidden compiler magic.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.5`
  Status: `pending`
  Goal: Implement the accepted EBNF-like frontend and lossless lowering in backend lockstep.
  Children: `.5.1`, `.5.2`, `.5.3`, `.5.4`, `.5.5`, `.5.6`
  Dependencies: `.4`

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.5.1`
  Status: `pending`
  Goal: Land the neutral profile contract, fixtures, semantic-digest oracle, source-map schema, and mutation checker.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.5.2`
  Status: `pending`
  Goal: Implement and admit the Perl reference frontend/lowering without a second evaluator.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.5.3`
  Status: `pending`
  Goal: Implement and admit Rust frontend/lowering parity.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.5.4`
  Status: `pending`
  Goal: Implement and admit Dart frontend/lowering parity.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.5.5`
  Status: `pending`
  Goal: Implement and admit Julia frontend/lowering parity.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.5.6`
  Status: `pending`
  Goal: Implement and admit Lua parity on PUC Lua and LuaJIT.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.6`
  Status: `pending`
  Goal: Close five-backend no-drift, public documentation, migration tooling, realistic examples, and operational
    signoff for expressive self-containment and the optional profile.
  Dependencies: `.3`, `.5`
  Acceptance: Ordinary syntax remains canonical and supported; profile adoption is optional and mechanically
    translatable; all backends/ABIs, generated roles, semantic/MCP projection, primary CLI, Knowledge Map, mdBook,
    doctrines, storage/relocation, and canonical gates agree; remaining gaps/risks are explicitly owned.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.0` Acceptance Checklist

- [x] **CLEAN OWNERSHIP / RETRIEVAL FIRST** — Start from clean Rust-parent closeout `4aebf906`, create this task
  file before any other change, and retrieve the Knowledge Map plus ADRs `0006`, `0007`, `0035`, and `0056`.
- [x] **PRECISE SELF-CONTAINMENT BOUNDARY** — Define portable problem-domain closure across grammar, recursion,
  cursor/capture/state, callables, control, transformation, and results while rejecting unrestricted-computation
  marketing, routine host escape hatches, and implicit filesystem/process/network/environment/FFI authority.
- [x] **ONE-SEMANTICS EBNF-LIKE PROFILE** — Accept the alternate syntax only as an optional honest frontend with
  explicit semantic differences/extensions, one canonical AST/HandlerIR/runtime, lossless authored-source maps,
  author-facing diagnostics, and five-backend lockstep.
- [x] **DETAILED DURABLE DECOMPOSITION** — Split capability inventory, neutral contract/mutations, canonical model,
  evidence-backed core-gap closure, realistic profile trials, Perl/Rust/Dart/Julia/Lua rollout, and no-drift into
  separately verifiable leaves without scheduling implementation ahead of current callable parity.
- [x] **SIGNOFF / DOCS / COMMIT / CLEAN HANDOFF** — Align ADR/index/fact/task/roadmaps/live/architecture/mdBook,
  regenerate/check the Knowledge Map, render and exactly clean the book, pass memory/whitespace/doctrine and
  warranted canonical gates, commit `.0`, clear the brief, prove clean, and only then activate Dart `.11.5.1`.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.0` | `done` | ADR `0064`, the complete decomposition, public/continuity alignment, and full documentation/canonical signoff durably route the direction without behavior change. |
| 2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.1` | `done` | Four capability areas mapped to current contracts and five-backend evidence; seven neutral/structural checks pass. |
| 3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.2` | `done` | Other five areas mapped; seven neutral tools and 44 path/consumer checks pass. |
| 4 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.1` | `done` | Typed constructor values and native/fresh emitted spans verified; complete Phase0 1033/1033. |
| 5 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.6` | `done` | Generic flat bound/computed values, capture compatibility, native/emitted164 and complete Phase01033 verified. |
| 6 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.1` | `done` | Exact native public-loader6/7/12 on six runtimes; carrier/mutation .1.1.3.1.2.2 follows. |
| 7 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1` | `done` | Emitted-entry repair and Perl carriers verified192/focused274/Phase01033; Rust is next. |
| 8 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.2` | `active` | Rust carriers, typed recovery and mutations from clean bb76f4437. |

## Decisions

- `2026-09-27`: The director confirms that container kind belongs to the value internally, not its binding name. Generic flat dispatch uses the evaluated runtime value; name-based legacy storage routing is compatibility plumbing only. The .1.1.6 native/emitted matrix covers bindings, parameters, nested reads and computed containers.

- `2026-09-27`: The director asks why generic flat was deferred and selects its immediate repair. Finish the verified constructor commit, then activate `.1.1.6` before remaining nesting proof.

- `2026-09-27`: The director returns to feature implementation and names mature .spec parsing power as the north star, with the structured-format campaign as the long-term destination. Activate the bounded .1.1 inventory after verified clean .92. Language readiness and backend parity gate the campaign; optional EBNF-like syntax is not the immediate objective. Older callable-first scheduling below records its historical decision.

- `2026-07-30`: The director approved expressive problem-domain self-containment: `.spec` authors should not feel
  limited when expressing LinkedSpec objectives, but this does not grant arbitrary outside-world interaction.
- `2026-07-30`: The director approved an EBNF-like alternative syntax in principle. It is accepted only as an
  optional, lossless authoring profile over the full LinkedSpec model—not literal EBNF, hidden magic, or a second
  semantics engine.
- `2026-07-30`: One versioned canonical AST/HandlerIR/runtime remains authoritative; all five backends implement
  one contract, and exact source mapping keeps profile diagnostics in authored coordinates.
- `2026-07-30`: Current callable-codeblock backend parity remains the immediate implementation program after this
  behavior-free routing leaf unless the director explicitly reprioritizes from a clean boundary.

## Open Questions

- Which three realistic formats best stress recursion, cursor repositioning, capture intervals, state, and
  transformation for `.4.4`? This is evidence collection, not a blocker for `.0`.
- Whether the profile eventually uses a header, extension, or explicit parser option is deliberately deferred to
  `.4.2`; selecting spelling during direction capture would be premature.

## Blockers

- None for `.0`.
- None for `.1.1`. The September27 clean prioritization supersedes the earlier callable-first schedule. Format implementation and the optional frontend remain gated by their own prerequisites.

## Verification Log

September27 `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1`: baseline RED15/192; new regression192, focused274, Phase01033 and exact entry/child/mutation/recovery proof pass. Perl carrier evidence is complete; remaining backends precede canonical parent closure.

September27 `.1.1.3.1.2.1`: native public-loader6/7/12 passes on all six runtimes; unchanged authored source/oracles, exact JSON kinds/spans and protected hashes verified. See its checkpoint and nested-tree-native ledger.

September27 `.1.1.6`: baseline RED31/164; candidate native/emitted164, focused120, Phase01033 and exact rendered LF/CRLF example pass. Its checkpoint preserves commands, source/log hashes and excluded interrupted evidence.

September27 `.1.1.3.1.1`: old-module RED 28/96; candidate constructor96, focused120, span18, Phase01033; exact book and nine doctrines pass. Source/test/diagnostic hashes are in its checkpoint. No broad campaign admission.

September27 `.1.1.2`: seven unchanged neutral tools, 44 source-path/consumer checks and book rendering pass; no runtime or contract movement. Standard memory/history/Knowledge and pre-commit doctrines govern landing.

September27 `.1.1.1`: seven neutral/structural checks, 34 ledger source-path/consumer checks and rendered book pass; no runtime/format-support promotion. Normal doctrine gates run at landing.

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-07-30` | `.0` | ADR/KM retrieval; KM 762/6,186; mdBook 79/13,884; memory; whitespace; seven doctrines; canonical CLI 66x2 + Phase 0 1,031/1,031 in 641s | `pass` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.0` | `SPEC-LANGUAGE-SELF-CONTAINMENT.0 - ratify expressive spec self-containment` | Direction capture only; no parser/runtime behavior. |

## Changelog

- `2026-09-27`: Perl carrier mutation proof exposes and repairs emitted public-entry drift in .1.1.3.1.2.2.1.1. All original grammar/oracles remain exact; next is Rust carrier proof.

- `2026-09-27`: `.1.1.6` fixes generic flat immediately as requested, including baseline-confirmed private capture compatibility. Remaining nesting route proof resumes from its clean commit.

- `2026-09-27`: `.1.1.3.1.1` repairs constructor value lowering exposed by the first grammar objective; `.1.1.6` owns separate generic flat composition. Remaining nesting routes and mutations follow from clean commit.

- `2026-09-27`: `.1.1.2` completes the state/callable/control/transformation/result evidence inventory. Known defects and intentionally absent features remain distinct; bounded grammar objectives `.1.1.3` follow.

- `2026-09-27`: Clean feature return activates `.1.1`, splits five bounded children and completes the first grammar/cursor/capture inventory. The campaign remains gated on language readiness and parity; `.1.1.5` owns confirmed stale general capability prose.

- `2026-07-30`: Created the task tree first from clean Rust closeout commit `4aebf906`; no other file changed
  before ownership existed.
- `2026-07-30`: ADR `0064`, the detailed program, Knowledge Map, roadmaps/live architecture, and mdBook align; full
  signoff passes without behavior change. `.0` is done and `.1+` remains unscheduled behind callable parity.
