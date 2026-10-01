# SPEC-LANGUAGE-SELF-CONTAINMENT: Expressive `.spec` Closure and EBNF-Like Authoring Profile

## Metadata

- Tree ID: `SPEC-LANGUAGE-SELF-CONTAINMENT`
- Status: `active` / closure definition
- Roadmap lane: `.spec language evolution / expressive self-containment and alternate authoring profiles`
- Created: `2026-07-30`
- Last updated: `2026-10-01`
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
  Status: `active` / closure definition
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
  Status: `done`
  Goal: Inventory current portable grammar/recursion/cursor/capture/state/callable/control/transformation/result
    powers and every routine host-language escape or expressiveness gap using LinkedSpec tools first.
  Children: `.1.1.1`, `.1.1.2`, `.1.1.3`, `.1.1.4`, `.1.1.5`, `.1.1.6`
  Acceptance: A source-located five-backend ledger separates implemented, partial, missing, compatibility-only,
    backend-host, and deliberately forbidden environmental authority; unassessed objectives are not missing-capability claims.
  Closeout: Nine-area inventories, three bounded objectives and finite gap classification are complete within their recorded scopes; .1.1.5 repairs the contradictory general description and recurrence before exact staged canonical parent closure. All separate repair owners and unassessed requirements remain open.

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
  Status: `done`
  Closure: Three historical bounded objectives reconciled by .1.1.3.4; exact staged canonical receipt governs this parent closeout. General language/format readiness remains open.
  Goal: Execute bounded representative grammar objectives against the inventory before selecting new primitives.
  Dependencies: `.1.1.2`
  Children: `.1.1.3.1`, `.1.1.3.2`, `.1.1.3.3`, `.1.1.3.4`
  Acceptance: Natural nesting, context-sensitive delimiter/indentation state, and lossless staged extraction have exact authored sources, positive/negative inputs, AST/span oracles and runtime/provenance evidence. Reuse existing document grammar and neutral fixtures where suitable; these are readiness probes, not whole-format conformance claims. Split each objective into its own commit before execution if needed.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1`
  Status: `done`
  Closure: Bounded child evidence reconciled by .1.1.3.1.2.3; exact staged canonical receipt governs this parent closeout.
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
  Status: `done`
  Closure: Bounded child evidence reconciled by .1.1.3.1.2.3; exact staged canonical receipt governs this parent closeout.
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
  Status: `done`
  Closure: Bounded child evidence reconciled by .1.1.3.1.2.3; exact staged canonical receipt governs this parent closeout.
  Goal: Verify supported serialized/reconstructed/generated/emitted nested-tree routes, same-engine recovery after typed rejection, readiness descriptors and prefix/gap/span mutation sensitivity.
  Dependencies: `.1.1.3.1.2.1`
  Acceptance: Split backend-sized children before implementation; retain the same authored oracles and honest carrier coverage. No blanket proof from native results.

  Children: `.1.1.3.1.2.2.1`, `.1.1.3.1.2.2.2`, `.1.1.3.1.2.2.3`, `.1.1.3.1.2.2.4`, `.1.1.3.1.2.2.5`, `.1.1.3.1.2.2.6`, `.1.1.3.1.2.2.7`

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1`
  Status: `done`
  Closure: Bounded child evidence reconciled by .1.1.3.1.2.3; exact staged canonical receipt governs this parent closeout.
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
  Allocator-registration audit: .1.1.3.1.2.2.6 traces t/nested_tree_readiness.t to this leaf's bb76f4437 commit. Its managed allocation was omitted from the separate Perl storage count; .6 owns exact registration/canonical proof without changing the verified parser behavior.
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
  Status: `done`
  Goal: Prove Lua nested-tree carrier semantics using both ABIs across native, reconstructed/generated-plan and emitted supported routes, typed rejection/recovery and prefix/gap/span mutation controls.
  Acceptance: Original grammar/cases remain unchanged; exact value kinds and Unicode spans, no partial rejection values, explicit recovery after every rejection and honest carrier/readiness coverage.
  Dependencies: `.1.1.3.1.2.2.4`

  Activation: Clean 618c0b974f77d576f7a9a983855582bdfaf2210c after Julia carrier proof; nine doctrines/post-commit pointer pass, brief0 and no pending job.
  Verification tier: `focused`
  Focused checks: Extend existing Lua v2 generated-source consumer with nesting native/reconstructed/generated/emitted routes on PUC Lua and LuaJIT; strict-document compatibility, exact child status/stdout/stderr and cleanup, storage oracle, unchanged fixture/runtime, book/Knowledge/memory/history/doctrines/diff checks.
  Canonical trigger: none for bounded carrier evidence without runtime/schema/contract/admission/storage mechanism change; parent reconciliation remains canonical.
  Scope: Five public routes per ABI, two retained engines and per-call generated entries; existing v2 test owns scratch. Use valid grammar regexes; the separately owned LUA-STARTUP-READING.2.3 malformed-regex path is outside this focused proof and no unfiltered full-gate success is claimed.
  Verification: PUC Lua and LuaJIT each pass133 generated-source assertions and all51 strict-document cases. Five routes per ABI pass40 original calls and three mutations; two retained engines prove28 recoveries per ABI. Child status/stdout/stderr/cleanup pass. Storage19/trio/volume checks complete, but legacy census emits a permission error while the script returns0; new P1 .6 owns immediate repair, and no successful legacy census is claimed.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.5 - verify Lua nesting carriers`.



- [x] **REPRODUCE / ISSUE** — Text adapters lack carrier/recovery proof. Consume the unchanged six accepts/seven rejects through typed public APIs on both ABIs; storage verification also exposes the independently owned .6 false-PASS census defect.
- [x] **ROOT CAUSE (WHY + WHERE)** — Native engines retain the parser object; source_emitter generated v2 constructs one per call, including emitted execute. Canonical JSON preserves tagged array/harray identity and scalar kinds. The storage script ignores a failing find pipeline in its if condition; .6 carries exact reproduction and repair acceptance.
- [x] **FIX** — Extend the existing v2 consumer and reuse its managed temporary owner; shared authored JSON checks, exact typed status1 rejection and mutation controls run through native/reconstructed/generated routes and fresh selected-ABI child modules.
- [x] **ADDRESSED (verified)** — Five routes per ABI pass40 original calls and three mutations. Two retained engines prove28 immediate recoveries per ABI. Four emitted modules validate metadata/plans, require actual child success and empty stderr, report exact completion and leave no owned workspace.
- [x] **NO REGRESSION** — Each ABI passes133 assertions (106 existing plus27 new) and51 document cases with27 round trips/24 recovery checks. Runtime/fixture/adapters are unchanged. Storage19/three-module ABI checks pass before the incomplete legacy census; neither an unfiltered full Lua gate nor a successful legacy census is claimed.
- [x] **LOCKSTEP** — Book, ledger, Knowledge, checkpoint, roadmaps and live/history records state exact proof and limits. P1 .6 is the immediate next slice, followed by canonical parent reconciliation; the discovery is surfaced and owned, not deferred without scheduling.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.6`
  Status: `done`
  Goal: Repair Lua storage verification so a failed legacy-residue census cannot print PASS.
  Priority: P1 verification integrity; execute immediately after .1.1.3.1.2.2.5 is committed, before canonical parent reconciliation.
  Reproduction: bash tools/test_lua_project_data_storage.sh returns0 and PASS19 while find reports Operation not permitted for an unrelated protected child of the old OS temp root; exact log is .linkedspec-data/scratch/nested-lua-storage.log.
  Root cause: The final find-to-rg pipeline is the condition of an if. An enumeration failure with no matches makes the condition false, bypassing both set-e and the residue failure body. Failed enumeration is therefore indistinguishable from a successful empty census.
  Acceptance: Enumerate only the relevant root entries without entering unrelated directories; preserve exact Lua-owned-prefix residue rejection and other-volume builder rejection. Propagate actual census failures. Prove empty/matching/error cases with repository-local controlled fixtures and real dual-ABI storage proof, preserve all existing boundaries, and use canonical infrastructure verification. No deletion or permission changes in other repositories or shared data.
  Dependencies: `.1.1.3.1.2.2.5` clean handoff.
  Verification: Controlled old missing-root census returns false success; new regression PASS30. Real Lua storage PASS19 with both native ABI trios and no census error; staged Perl storage PASS27 with exact24-plus3 audit. Syntax and diff checks pass. Exact staged canonical receipt governs landing; parent readiness reconciliation remains separate.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.6 - reject incomplete storage censuses`.


  Activation: Clean feb5a06fefe19f8744f9b178a1f930203292fec0 after Lua carrier proof; nine doctrines/post-commit pointer pass, brief0 and no job remains.
  Verification tier: `canonical`
  Focused checks: Controlled empty/residue/enumeration-error/symlink/prefix/permission-boundary cases, old conditional RED, new scanner GREEN, exact real dual-ABI storage proof and unchanged builder rejection; exact24-plus3 Perl allocator audit and staged storage proof; reviewed mutation71/selector70 public inventories and unchanged semantic controls; syntax, book, Knowledge, memory/history/doctrines/diff checks.
  Canonical trigger: Storage verification mechanism changes; stage the exact candidate and require tools/run_ci_local.sh receipt before landing.
  Direct-dependent defect owned here: Perl storage gate reproduces a24-to26 allocator failure. Exact audit from clean27a2168d preserves all24 original owners and finds only t/legacy_pathsearch_fallback.t (30b2cc3a0/startup .92) and t/nested_tree_readiness.t (bb76f4437/.1.1.3.1.2.2.1.1). The new census regression is the27th owner. Register these exact paths and update current cardinality; verify the staged manifest and real Perl storage gate before canonical admission.
  Canonical preflight defect owned here: First full gate stops at mutation public expected70/observed71. Git audit identifies exactly one new public page since clean27a2168d: docs/linkedspec-book/src/development/regression-fixtures.md, created by30b2cc3a0/startup .92. Review its complete contents and register it in both public inventories (mutation70-to71; selector69-to70), preserve classifiers/frozen authorities/semantic mutation controls, synchronize current prose, and rerun focused checks plus exact canonical CI. No prior partial gate counts as success.
  Implementation: Small read-only Perl scanner enumerates only immediate names, lstat-checks exact Lua-prefix entries without following links or entering unrelated directories, and distinguishes clear/residue/error status. Add meaningful repository-local regression controls and invoke them from the existing storage oracle before replacing its final conditional pipeline.

- [x] **REPRODUCE / ISSUE** — Old missing-root conditional returns0 after find fails, reproducing the real protected-entry false PASS. Separate Perl storage gate fails24-to26; Git creation history identifies the two omitted owners exactly.
- [x] **ROOT CAUSE (WHY + WHERE)** — tools/test_lua_project_data_storage.sh conditions find-to-rg on if, so failed enumeration and no matches take the same branch. tools/test_perl_project_data_storage.sh retained24 after two managed tests landed. Tool-backed shell/process diagnosis applies; parser probes are not relevant to these gates.
- [x] **FIX** — Read-only immediate-name scanner checks open/read/lstat/close errors, filters before metadata, never follows links, and returns0/1/2 for clear/residue/error. The storage oracle requires success and runs the new regression. Register exactly the two omitted Perl tests plus the new census test; preserve existing boundaries.
- [x] **ADDRESSED (verified)** — Thirty assertions prove exact child status/stdout/stderr across ten controls. Real Lua storage passes19 owners/two ABI trios; staged Perl storage passes27 and real trace/CLI scratch cleanup. Mutation71/14/11/10/50 and selector70/36/0/5/11 public controls pass after exact one-page registration. Exact canonical receipt is required before commit.
- [x] **NO REGRESSION** — Shell/Perl syntax and git diff --check pass; existing builder cross-volume rejection, same-device allocation and owned cleanup remain exercised. No runtime/grammar/native-builder changes or external deletion. Historical failed census remains identified as incomplete.
- [x] **LOCKSTEP** — Current storage book/counts, readiness ledger, Knowledge facts, checkpoint, live/roadmap pointers and bounded histories agree. The two creating leaves retain audit links; scripts/check_memory_architecture.sh and canonical doctrines govern landing.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.7`
  Status: `done`
  Goal: Eliminate uninitialized entry-position warnings in Perl emitted parsers while preserving existing no-entry and matched-entry values.
  Priority: P1 generated-parser diagnostic integrity; execute after the clean storage repair and before canonical nesting reconciliation.
  Activation: Clean f80b4693b86f7b5ece02fabb5510e1a4ca5dda55; canonical Phase01033/CLI66x2, all nine doctrines/post-commit pointer pass, brief0 and no job remains.
  Reproduction: Canonical generated_source_contract.t passes11 top-level tests but emits two uninitialized subtraction warnings. Isolated warning-enabled fresh source generated through emit_generated_source identifies the constructor-matrix entry_start_pos call; native values and emitted values remain exact. Logs: .linkedspec-data/scratch/lua-census-warning-matrices-probe.log and lua-census-generated-warning-diagnosis.log.
  Root cause: Public generated source line87 computes $IPOS - length($IMATCH) for entry_start_pos. The selected root has no entry match, so $IMATCH is undefined; Perl coerces length(undef) during subtraction and warns. ActionIR/Contracts.pm owns this lowering and related entry-start projections. This is independent of generic flat kind dispatch and storage verification.
  Acceptance: Review the entry helper contracts and all related lowering sites; preserve existing absent/null/empty distinctions, root/trivia offsets, Unicode spans, nested matched entries and typed source errors. Add meaningful warning-sensitive native/fresh emitted regression and RED/GREEN proof; no blanket warning suppression, expected-value workaround or public contract expansion. Reuse an existing managed test owner. Commit before parent reconciliation.
  Dependencies: `.1.1.3.1.2.2.6`
  Verification tier: `focused`
  Focused checks: Public lowering/emitted-source diagnosis, warning-sensitive entry-boundary RED/GREEN, typed source/capture/mark direct dependents, generated-source and nesting regressions, complete Phase0 for action rewriting, syntax, book/Knowledge/memory/history/doctrines/diff checks.
  Canonical trigger: none for a bounded Perl lowering correction preserving existing values and contracts; escalate if review requires a contract, schema or infrastructure change. Parent reconciliation remains canonical.
  Verification: RED6/87 new assertions (emitted absent-root warnings only); all values and matched controls pass. Initial GREEN87/87 and five focused suites218/218 pass; the final zero-string control expands the new regression to104/104 and generated12/12 pass, without uninitialized warnings. Book render, Perl/module/test syntax and storage27 pass. Final complete Phase0 passes1033/1033 in1040s.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.7 - preserve quiet entry boundaries`.

  Scope audit: Exactly seven previously unguarded sites change; guarded entry_text/entry_len, end projections, local-match handling and MethodLowering's guarded entry_text remain byte-identical. Four existing Phase0 exact-source expectations update to the new arithmetic; behavioral expected values do not change.
  Phase0 preflight correction: The first full run exposes the fourth stale expression pin, a mark_entry_start regex assertion at t/phase0_regression.t:15684. It completes1033 tests with only that one failed subtest in1059s; runtime boundary assertions pass. The corrected pattern requires explicit absent width; the failed run is retained and the final complete rerun passes.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.7` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — LinkedSpec::emit_generated_source and a warning-enabled fresh child locate the constructor root's uninitialized subtraction at generated line87. The initial new regression fails exactly six emitted no-warning assertions out of87; all native/emitted values and matched-entry controls pass.
- [x] **ROOT CAUSE (WHY + WHERE)** — WHY: a selected root has a valid entry cursor but absent match text; length(undef) is coerced by subtraction and warns. WHERE: seven unguarded entry-start lowerings in perl/LinkedSpec/ActionIR/Contracts.pm; public emitted source and Carp attribution identify the exact mechanism.
- [x] **FIX** — Normalize absent text only for width arithmetic with defined-or empty string. Preserve guarded null text/length, typed projection calls, end positions, capture kinds and local-match semantics. Extend the existing managed test owner; no warning suppression or generated-format change.
- [x] **ADDRESSED (verified)** — Final104 assertions cover six fixtures, repeated native and fresh-process emitted calls, root/trivia/Unicode/empty/zero-text cases, exact values and empty warning lists. Five focused files pass218 top-level tests; final generated12 passes and storage remains27 owners.
- [x] **NO REGRESSION** — Full Phase0 first run completes1033 with one stale source-pattern pin; its runtime assertions pass. Four source-expression expectations are aligned. Final full rerun PASS1033/1033 in1040s; module/test syntax, six-example book render, unchanged frozen contracts/fixtures and git diff --check pass.
- [x] **LOCKSTEP** — The source-boundary book teaches six worked contexts and regeneration requirements without a new cross-backend absence claim. Task/live/roadmap pointers, bounded history, Knowledge fact/checkpoint and memory identify this repair before canonical nesting reconciliation; scripts/check_memory_architecture.sh and final doctrines govern landing.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.3`
  Status: `done`
  Goal: Reconcile nested-tree readiness evidence, authoring costs and limitations, and close its parents through canonical milestone proof.
  Dependencies: `.1.1.3.1.2.2`
  Acceptance: Source-located native/carrier/mutation ledger and book agree; canonical receipt governs closure before context-dependent objective .1.1.3.2.
  Activation: Clean b044542bc47894f69954fcbdda451ed2548c3bb3; all carrier children and discovered storage/entry-warning repairs committed, brief empty and no pending jobs.
  Scope: Reconcile existing bounded proof, authored strictness costs and route-specific limits; close nesting parents only after exact staged canonical success. No format admission or runtime change.
  Verification tier: `canonical`
  Focused checks: Original fixture and committed evidence audit; source-located route/readiness/mutation/recovery matrix; book render, Knowledge synchronization, bounded history, memory, diagnosis, cadence and all doctrines.
  Canonical trigger: Milestone and parent closeout requires tools/run_ci_local.sh on the exact staged candidate.
  Documentation defect: The current frontier still names the completed Rust leaf active, and the native fact status still says carrier proof pending. This leaf owns reconciliation of these reproducible stale summaries and remaining backend follow-up sentences; chronology remains dated evidence.
  Result: Six-runtime native6/7/12 remains distinct from typed carriers. Perl/Rust/Dart/Julia/PUC/LuaJIT respectively prove2/6/6/5/5/5 routes,2/4/4/2/2/2 retained parsers and28/56/56/28/28/28 recovery transitions. Each route executes40 original calls and three mutants. Existing proof, source hashes and48 retained logs reconcile; .6 explains the sole superseded source hash.
  Authoring assessment: The unchanged33-line/five-rule/eight-edge grammar composes recursion/state/typed ASTs directly but requires explicit prefix/gap/end/missing-close guards. Typed status1 gives no reason-specific diagnostics. No new primitive selected; context/lossless probes precede .1.1.4 gap selection.
  Verification: Source/log audit and book validation precede exact staged tools/run_ci_local.sh; the receipt is mandatory for landing. Checkpoint: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.3-verification.json.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.3 - reconcile bounded nesting readiness`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Completed backend checkpoints conflict with the stale current Rust frontier, outdated carrier-readiness fact status and ROADMAP_V2 lead. The nesting parent also lacks a consolidated authoring-cost assessment.
- [x] **ROOT CAUSE (WHY + WHERE)** — Backend-sized leaves recorded local proof and chronological additions but left older current summaries in docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md, roadmap lead and Knowledge cards. No new parser defect is inferred; carrier source/log hashes and the .6 storage supersession explain the current evidence.
- [x] **FIX** — Reconcile the precise route/recovery/readiness matrix, all four strictness guard locations and scope limits; correct current summaries and close only bounded nesting parents under this canonical milestone.
- [x] **ADDRESSED (verified)** — Audited original grammar/cases, all37 carrier/repair source-hash references and48 retained logs. The only historical source difference is the subsequently repaired Lua storage gate; its .6 hash matches. Existing .7 proof reruns Perl nesting after the last runtime change.
- [x] **NO REGRESSION** — No runtime, test oracle, generated schema or dependency change. Book and focused evidence checks pass before staging; exact staged canonical proof is required by the landing hook. Optional unfiltered backend gates and known separate defects are not claimed closed.
- [x] **LOCKSTEP** — Ledger, book, roadmap leads/current rows, Knowledge, task frontier, MEMORY, live status and bounded histories agree. Next is context-dependent objective .1.1.3.2; the broad format campaign remains gated.


- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2`
  Status: `done`
  Goal: Probe context-dependent matching with nested opening/closing names or indentation state using ordinary .spec, exact rejection and restoration controls.
  Dependencies: `.1.1.3.1`
  Acceptance: Source-located, bounded native/carrier evidence establishes whether existing explicit state and comparisons express the objective clearly; record and schedule any minimal reusable gap without claiming XML/YAML support.
  Activation: Clean8ea0c1107889b02e68eeb874970ecdbb4bb41ab2 after canonical nesting reconciliation; all nine hooks and post-commit pointer pass, brief0 and no pending jobs.
  Scope: A tag-like grammar with ASCII names, literal Unicode text, explicit str_ne closing-name comparison and rule-local state. Typed statuses distinguish invalid syntax, name mismatch and missing close. No XML, attributes, entities, indentation or resource-safety claim.
  Children: `.1.1.3.2.1`, `.1.1.3.2.2`, `.1.1.3.2.3`, `.1.1.3.2.4`, `.1.1.3.2.5`, `.1.1.3.2.6`, `.1.1.3.2.7`

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.1`
  Status: `done`
  Goal: Author the independent context-name grammar/oracles and verify Perl native/fresh emitted scope restoration, exact trees/spans, typed rejection/recovery and targeted mutations.
  Activation: Clean8ea0c1107889b02e68eeb874970ecdbb4bb41ab2; existing nesting fixtures and temporary owner remain intact.
  Scope: New bounded fixture under tests/language-readiness/context-names, extended t/nested_tree_readiness.t using its existing managed workspace, and book/evidence/current-doc synchronization. No runtime or dependency change planned; diagnose and own any defect before repair.
  Verification tier: `focused`
  Focused checks: LinkedSpec::Get and return_descriptor probes; exact independent native/fresh emitted oracles, status/reuse checks and comparison/state/span mutants; existing nesting and typed-source/callable/generation direct dependents; syntax, book, Knowledge, memory, bounded histories, doctrines and diff hygiene.
  Canonical trigger: None for a bounded fixture/test proof of existing Perl semantics; escalate for runtime contract or infrastructure movement. Parent .1.1.3.2.7 owns canonical reconciliation.
  Acceptance: Case-sensitive matching names, same/different nested names and siblings restore parent state; all rejects carry the intended status with no result and immediate valid reuse. Original nesting expectations unchanged; authoring costs and untested backend boundaries explicit.
  Verification: Public Get initially matches10 accepts/17 rejections; independent three-level control extends final authority to11/17. Both native/fresh emitted routes execute90 original calls,34 immediate recoveries and three mutants. Final suite410/410 in25s; four direct-dependent files89/89, syntax and existing storage27 pass. Book and standard gates govern landing; exact checkpoint: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.1-verification.json.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.1 - verify scoped closing-name comparison`.
  Preflight: The evidence-shape gate rejects placeholder spellings anywhere in checked acceptance lines. A completed .1.1.3.1.2.3 issue description used that spelling to describe its obsolete carrier status; rephrase it accurately as outdated carrier-readiness without changing the historical evidence or gate.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Context-dependent matching was unassessed. Public LinkedSpec::Get on the independently authored grammar/cases returns the exact trees and three rejection classes; return_descriptor reports five ready rules with no compatibility/raw blocker.
- [x] **ROOT CAUSE (WHY + WHERE)** — grammar.spec Element entry saves entry_group(0); its closing edge compares match_group(0) with name via str_ne. call_spec_handler_subst shows lexical captured-text versus saved-binding comparison and typed termination. Exact native/emitted nested/sibling/three-level results demonstrate scoped restoration; no engine defect is inferred.
- [x] **FIX** — Add the37-line bounded grammar,11 accepted/17 rejected independent oracles, and existing-harness context variants. Reuse the managed temporary owner and fresh runner; preserve original nesting fixtures and expectations. This is composition proof, with no production repair or new primitive.
- [x] **ADDRESSED (verified)** — Both routes pass90 original executions,34 immediate rejection recoveries and comparison/state/span mutants. Actual emitted child exit, metadata/identity/plan and exact counts pass. Initial406 tests expand to410 after an independently authored three-level control; no old expected value changes.
- [x] **NO REGRESSION** — All192 original nesting/entry assertions remain within410 passing tests; generated-source/typed-source/variadic direct dependents pass89 across four files. Syntax and real storage27 pass. Complete canonical/Phase0 is reserved for the parent milestone because no action rewriter, runtime contract or infrastructure changed.
- [x] **LOCKSTEP** — The book teaches lexical capture comparison, worked ASTs, three statuses and explicit XML/resource exclusions. Context ledger, Knowledge/checkpoint, task frontier, roadmaps, MEMORY, live status and bounded histories route next work to all-runtime native .1.1.3.2.2. Standard doctrines and diff checks govern commit.


- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.2`
  Status: `done`
  Goal: Verify the unchanged context-name grammar and independent oracles through all six documented public native text adapters, preserving exact status-projection limits.
  Dependencies: `.1.1.3.2.1`
  Acceptance: Exact typed AST/spans and each authored rejection status; repeat accepted inputs and preserve original fixture bytes. No same-engine post-rejection claim from exit-on-error adapters.
  Activation: Clean8b11f40705b31e9c83037602e67758c81a676bd7; all nine hooks and post-commit pointer pass, brief0 and no pending jobs.
  Scope: Extend the existing public-native verifier with a fixed context-names fixture choice and per-case authored exit statuses. Reuse published integration APIs and prepared local stores; preserve nested-tree default behavior and both original fixture pairs. No runtime, adapter, dependency or resource policy changes.
  Verification tier: `focused`
  Focused checks: All six context-name native runs against11/17 independent oracles and22 repeated accepts; all six default nesting runs as verifier compatibility proof; exact source/product before-after hashes, option/syntax controls, book, Knowledge, memory, histories, doctrines and diff hygiene.
  Canonical trigger: None for bounded public-native evidence using existing interfaces; parent .1.1.3.2.7 owns canonical closeout. Escalate if an actual contract/infrastructure change becomes necessary.
  Verification: PASS all12 real adapter runs: unchanged context11/17/22 and default nesting6/7/12 on Perl/Rust/Dart/Julia/PUC/LuaJIT. Exact JSON kinds/spans and grammar statuses1/2/3; no result on rejection. Rust retains Display-only projection. Protected source/product hashes still match; both fixture pairs are byte-identical to activation HEAD. Syntax/help/invalid-choice controls pass. Book and standard gates govern landing.
  Evidence: docs/language-readiness/context-names.md and docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.2-verification.json preserve route limits, exact reports, published preparation and hashes.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.2 - verify native closing-name parity`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Only Perl context-name carrier evidence existed. The published load-and-compile adapters now execute the unchanged authored source against all11 positive/17 negative cases and22 repeated accepts per runtime. LinkedSpec::Get proof remains separately recorded by .1.
- [x] **ROOT CAUSE (WHY + WHERE)** — WHY: adapter process failure policy is independent of grammar exit status; hardcoded status1 would reject the new status2/3 oracles. WHERE: verify_native.py rejection loop and the published examples/integration text consumers. All adapters choose process1; Rust projects Display while the others retain typed JSON. This is a verifier extension, not an engine repair.
- [x] **FIX** — Add two fixed fixture choices with nested-tree unchanged as default; select the exact inventory and read per-case status with legacy default1. Preserve before/after hashing, typed JSON-value comparison, zero output on rejection and documented local runtime preparation.
- [x] **ADDRESSED (verified)** — All six context11/17/22 runs PASS with exact status and empty result channels on rejection. All six original default6/7/12 runs also PASS. Real subprocess success, protected source/product hashes, syntax, help and invalid-choice exit2 are verified; both source/oracle pairs match activation HEAD.
- [x] **NO REGRESSION** — Default compatibility is exercised on every runtime; runtime, adapters, fixtures, dependency pins and prepared-store policy are unchanged. Positive accepted-input reuse is established, while exit-on-error adapters carry no rejection-recovery or typed Rust error claim. Focused tier is appropriate; canonical context closeout remains owned by .7.
- [x] **LOCKSTEP** — Book commands/proof boundary, current context ledger, Perl/native Knowledge cards, checkpoint, roadmaps, task frontier, MEMORY, live status and bounded histories agree. Next is Rust carrier .1.1.3.2.3; broader format admission remains gated.


- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.3`
  Status: `done`
  Goal: Verify Rust context-name reconstructed/generated/v2/emitted routes, exact typed rejection/recovery and grammar mutations.
  Dependencies: `.1.1.3.2.2`
  Acceptance: Use unchanged shared oracles and distinguish retained-engine restoration from per-call isolation; require fresh child exit success and exact completion.
  Activation: Cleanc4e1534da918ace02cc03aba28c021e581df54f0; all-six native context/default proof committed, all nine hooks/post-pointer pass, brief0 and no pending jobs.
  Scope: Extend existing Rust readiness consumer and emitted-crate harness; add a shared context checker using typed Result values/statuses. Reuse repository-local scratch/target/dependencies and unchanged context/nesting fixtures. No runtime, schema, lockfile or storage policy change planned.
  Verification tier: `focused`
  Focused checks: Six context routes with90 original calls/three mutants each and136 retained-engine recovery transitions; original Rust nesting carrier tests; fresh child actual success/four executed modules per fixture; leading-trivia and strict-document dependents; changed-file formatting, book, Knowledge, memory, histories, doctrines and diff hygiene.
  Canonical trigger: None for bounded test/carrier proof of existing semantics; .1.1.3.2.7 owns canonical reconciliation. Split and escalate if production contract or infrastructure repair is required.
  Owned test defect (immediate priority): The first four-test Rust run fails one emitted test with AlreadyExists at LocalCrate::new while its parallel peer passes. PID plus SystemTime nanoseconds is not a unique name within one process; adding the second emitted fixture makes the existing test helper race observable. Repair within this leaf with a process-local atomic sequence, retain exclusive create_dir and rerun both children concurrently. No shared storage policy or production change.

  Verification: Final combined Rust run exits0: readiness4, leading-trivia3 and strict-document1; both fresh emitted children exit0 and execute exactly four tests. Six context routes each pass90 calls/three mutants; four retained routes total136 recovery transitions. Original nesting routes remain40/three mutants. Changed-file formatting passes; fixtures, old checker and root lockfile are unchanged.
  Evidence: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.3-verification.json and docs/knowledge/context-names-rust-carrier-readiness.md distinguish the initial allocation failure from final GREEN.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.3 - verify Rust closing-name carriers`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Rust context carriers lacked typed authored-status proof. The first combined four-test run also reproduces AlreadyExists in one emitted child allocator while its parallel peer succeeds.
- [x] **ROOT CAUSE (WHY + WHERE)** — The public six-route harness can share independent oracles but needs Result values/statuses rather than null-like rejection. LocalCrate::new used only PID and clock time, allowing same-process thread collisions.
- [x] **FIX** — Add exact typed context checks and comparison/state/span variants to the existing carrier and fresh emitted harness; add an atomic allocation sequence while retaining exclusive directory creation and local roots.
- [x] **ADDRESSED (verified)** — Final readiness4 tests pass, with two real children each executing four checks and exiting0. Every context route verifies90 original calls and three mutants; four retained engines verify136 immediate recoveries. No result counts as rejection unless its public typed Exit status matches.
- [x] **NO REGRESSION** — Original nesting40-call/three-mutant routes pass unchanged; leading-trivia3 and strict-document1 pass. Original fixture pairs, old Rust checker and root lockfile remain byte-exact. Changed-file format and book checks pass; ordinary landing doctrines apply.
- [x] **LOCKSTEP** — Context ledger, public book, Knowledge, checkpoint, task frontier, roadmap leads, MEMORY and live/bounded histories agree. Dart .1.1.3.2.4 follows; canonical context parent .7 and format admission remain separate.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.4`
  Status: `done`
  Goal: Verify Dart context-name reconstructed/generated/v2/emitted routes, exact typed rejection/recovery and grammar mutations.
  Dependencies: `.1.1.3.2.3`
  Acceptance: Same authored oracles, explicit retained/per-call distinction and strict fresh emitted-package validation; keep known SDK issues separately owned.

  Activation: Clean2cf465ae780013af4153e4129b31ad9db227b7d1 after Rust carrier commit; all nine doctrines/post-pointer pass, brief0 and clean tree.
  Scope: Parameterize the existing Dart fixture/carrier harness and shared strict checker for context inventory, authored status and mutations; preserve nesting defaults and both original fixture pairs. Reuse the existing managed emitted package and stores. No production, lockfile, generated format or storage-policy change.
  Verification tier: `focused`
  Focused checks: Six context routes with90 calls/three mutations each and136 retained recoveries; original nesting routes; actual offline preparation/fatal analysis/fresh emitted execution and exact reports; emitter/document dependents; changed-file analysis/format, book, Knowledge, memory, histories, doctrines and diff hygiene.
  Canonical trigger: None for bounded test/carrier proof; parent .1.1.3.2.7 owns canonical reconciliation. Known whole-package SDK deprecations remain separately owned by DART-STARTUP-READING.2.25.

  Verification: PASS62 combined tests (four readiness plus58 emitter/document), including both real emitted packages with successful offline preparation/fatal analysis/execution and exact reports. Context90 calls/three mutants on six routes;136 retained recoveries. Original nesting40-call/default controls remain GREEN. Main-test fatal analysis and two-file formatting pass.
  Analysis scope: Initial direct analysis of the shared helper outside a package cannot resolve its package import. The same copied helper passes fatal analysis in both fresh emitted packages; main-test analysis passes in its own package. No diagnostic suppression or production repair. Exact checkpoint: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.4-verification.json.
  History containment: Required CHANGES rollover at427 lines/59130 bytes archives177 clean-HEAD lines/35913 bytes as4969; reconstruction and all prior manifest rows remain exact. Current249 lines/23216 bytes after removing one live EOF blank separator for diff hygiene; reconstruction explicitly restores that separator. Immutable bytes and budgets unchanged.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.4 - verify Dart closing-name carriers`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Dart public-native context proof lacked reconstructed/generated/fresh emitted typed status and rejection-recovery evidence. Existing readiness harness carried only the original nesting fixture.
- [x] **ROOT CAUSE (WHY + WHERE)** — dart/test/nested_tree_readiness_test.dart and its shared strict checker hardcoded nesting inventory, status1, recovery case and span. Existing public engines already compose the context grammar; no production defect is observed.
- [x] **FIX** — Parameterize authored fixture settings while preserving nesting defaults; add comparison/state/span context variants and exact authored statuses. Reuse managed emitted packages, strict metadata/plan checks and actual child completion.
- [x] **ADDRESSED (verified)** — All62 combined tests pass. Each of six context routes executes90 calls and three mutants; four retained engines prove136 immediate recoveries. Both emitted packages pass offline setup, fatal analysis and execution with exact four-module reports.
- [x] **NO REGRESSION** — Original nesting and58 emitter/document checks pass. Both grammar/oracle pairs and root lockfile stay exact; two-file format and package-context analysis pass. Helper analysis is verified in both real emitted packages; known whole-package SDK issues stay separately owned.
- [x] **LOCKSTEP** — Book, context ledger, Knowledge, checkpoint, roadmap, task frontier, MEMORY, live status and bounded histories agree. Julia .1.1.3.2.5 follows; canonical parent .7 and broad format admission remain separate.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.5`
  Status: `done`
  Goal: Verify Julia context-name reconstructed/v2/emitted routes and context/recovery mutations using existing managed emitter storage.
  Dependencies: `.1.1.3.2.4`
  Acceptance: Exact JSON kinds/spans/statuses; retained/per-call distinction; latest-world fresh child binding access, exact report and real exit success.

  Activation: Clean8e2ac09679ddd0a4a361fdfc1e42e72c66bd700d after Dart carrier commit; all nine doctrines/post-pointer pass, brief0 and clean tree.
  Scope: Extend the existing Julia emitter readiness harness and shared strict checker with explicit context fixture settings/statuses/mutations. Retain latest-world binding access and managed private-depot child. Preserve original fixtures, runtime, manifests and generated format.
  Verification tier: `focused`
  Focused checks: Five context routes with90 calls/three mutations each and68 recoveries on two retained engines; original nesting and full existing emitter/document files; real emitted child exit success/exact report/cleanup; storage inventory, book, Knowledge, memory, histories, doctrines and diff hygiene.
  Canonical trigger: None for bounded fixture/carrier tests; parent .1.1.3.2.7 owns exact staged canonical reconciliation. Escalate any production or infrastructure contract movement separately.

  Verification: PASS253 assertions: context30, original nesting30, existing emitter65 and strict-document128. Five context routes each execute90 calls/three mutants; two retained engines prove68 immediate recoveries. Both fresh hosts require actual success/exact report and verified cleanup. Storage remains22 owners/five package trees; fixtures and manifests are byte-exact.
  Evidence: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.5-verification.json; context ledger and Julia Knowledge card record retained/per-call limits and latest-world loading.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.5 - verify Julia closing-name carriers`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Julia public-native context proof lacked reconstructed/generated/fresh emitted exact status and recovery evidence; the existing emitter readiness harness covered only nesting.
- [x] **ROOT CAUSE (WHY + WHERE)** — julia/test/source_emitter_test.jl and its shared checker hardcoded the nesting inventory, status1, recovery case and span. Existing public APIs already compose the context grammar; no production defect is observed.
- [x] **FIX** — Add explicit context fixture options and comparison/state/span variants, preserving nesting defaults, exact typed errors and the established managed latest-world emitted host.
- [x] **ADDRESSED (verified)** — All253 assertions pass, including30 context controls. Five routes each verify90 original calls/three mutations; two retained engines verify68 recoveries. Both real emitted hosts pass strict reports/status and cleanup assertions.
- [x] **NO REGRESSION** — Original nesting30, existing emitter65 and strict-document128 pass. Both fixture pairs and Julia manifests stay byte-exact; storage passes22 owners/five package trees. No private generated-family API, runtime or format change.
- [x] **LOCKSTEP** — Book, context ledger, Knowledge, checkpoint, task frontier, roadmaps, MEMORY and bounded live/history records agree. Lua .1.1.3.2.6 follows; canonical parent .7 remains separate.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.6`
  Status: `done`
  Goal: Verify context-name carriers independently under PUC Lua and LuaJIT with exact typed statuses and state restoration.
  Dependencies: `.1.1.3.2.5`
  Acceptance: Exact original and mutant checks on native/reconstructed/v2/emitted routes; existing managed owner, real child status/empty stderr/exact report and cleanup. No malformed-regex-path claim.

  Activation: Clean2a5b9c859d725c2cc6ece83c50d16ab69cc36766 after Julia carrier commit; all nine doctrines/post-pointer pass, brief0 and clean tree.
  Scope: Extend the existing dual-ABI generated-v2 readiness harness and strict shared checker using explicit context options and unchanged fixtures. Reuse the managed workspace and selected-ABI fresh child, preserving actual status/empty-stderr/exact report/cleanup. No production or malformed-regex-path change.
  Verification tier: `focused`
  Focused checks: Five context routes per ABI, each90 calls/three mutants with68 recoveries on two retained engines; original v2/nesting and strict-document proof under PUC Lua and LuaJIT; real storage19 census, book, Knowledge, memory, histories, doctrines and diff hygiene.
  Canonical trigger: None for bounded test/carrier proof. Parent .1.1.3.2.7 owns canonical closeout; known malformed-regex .2.3 remains outside this slice.

  Verification: Both final ABI runs PASS160 v2 assertions plus51 document cases/27 round trips/24 recoveries. Five context routes per ABI each execute90 calls/three mutants; two retained engines prove68 recoveries. Both fixture children require actual success, empty stderr, exact report and cleanup. Real storage19/trio/30 census controls passes; both fixture pairs remain exact.
  Evidence: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.6-verification.json and the context ledger/dual-ABI Knowledge card preserve route and gate limits.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.6 - verify Lua closing-name carriers`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.6` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Both Lua public-native context proofs lacked reconstructed/generated/fresh emitted typed rejection and recovery evidence. Existing v2 readiness coverage selected only nesting.
- [x] **ROOT CAUSE (WHY + WHERE)** — lua/test/rule_local_cursor_generated_source_test.lua and its shared checker hardcoded nesting inventory, status1, recovery control and span. Existing public runtime APIs already express the context grammar; no production defect is observed.
- [x] **FIX** — Add explicit fixture options and comparison/state/span mutations while retaining nesting defaults, typed errors, strict JSON kinds and the existing managed selected-ABI fresh child.
- [x] **ADDRESSED (verified)** — Both final ABI runs pass160 v2 assertions; every one of five context routes runs90 original calls and three mutants. Two retained engines per ABI prove68 immediate recoveries; both fixture children pass status/stderr/report/cleanup checks.
- [x] **NO REGRESSION** — Original nesting proof and51 document cases/27 round trips/24 recoveries pass per ABI. Both source/oracle pairs stay byte-exact. Real storage19/trio/30 census controls passes; no production or malformed-regex-path change.
- [x] **LOCKSTEP** — Book, context ledger, Knowledge, checkpoint, task frontier, roadmaps, MEMORY and bounded live/history records agree. Canonical context reconciliation .1.1.3.2.7 follows before lossless extraction; no broad format admission.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.7`
  Status: `done`
  Goal: Reconcile context-dependent grammar evidence, rejection diagnostics and authoring costs through canonical parent closeout.
  Dependencies: `.1.1.3.2.1`, `.1.1.3.2.2`, `.1.1.3.2.3`, `.1.1.3.2.4`, `.1.1.3.2.5`, `.1.1.3.2.6`
  Acceptance: Preserve exact runtime/carrier/mutation scope and canonical receipt; close only bounded context matching before lossless objective .1.1.3.3. No format campaign admission.

  Activation: Cleanc20c123dd0573b1d831a0b4910a67091fa5572f2 after all-six carrier proof; all nine doctrines/post-pointer pass, brief0 and clean tree.
  Scope: Reconcile all six context checkpoints and exact fixture/source/log hashes, native versus typed carrier limits, guard/diagnostic authoring costs and current documentation. Close only bounded context parent .1.1.3.2; lossless .1.1.3.3 follows. No runtime, fixture or generated-contract change.
  Verification tier: `canonical`
  Focused checks: Audit original source/oracles, all context source-hash references and retained logs; reconcile route/recovery/mutation table and prior harness repair; book, Knowledge, memory, histories, doctrines and diff hygiene.
  Canonical trigger: Milestone and bounded parent closeout requires tools/run_ci_local.sh on the exact staged candidate; landing receipt and commit body preserve actual result.

  Result: Six public-native11/17/22 trials remain distinct from typed carriers. Perl/Rust/Dart/Julia/PUC/LuaJIT prove2/6/6/5/5/5 routes,2/4/4/2/2/2 retained parsers and68/136/136/68/68/68 immediate recoveries. Every route runs90 original calls/three mutants against28 authored cases; all40 source references and39 logs match.
  Authoring assessment: Existing capture values, lexical comparison and recursive local state compose this bounded grammar. Prefix/gap/final-cursor/missing-close guards remain explicit; richer diagnostic messages/spans, in-document recovery and resource safety are not established. No comparison/state primitive selected; lossless .1.1.3.3 precedes .1.1.4 gap selection.
  Verification: Audit and book checks pass before staging; exact tools/run_ci_local.sh receipt is mandatory for landing and actual result/log hash belong in the commit body. Checkpoint: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.7-verification.json.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.7 - reconcile bounded context-name readiness`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.7` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Six completed backend checkpoints need one bounded route/recovery/authoring assessment and canonical parent closeout. Current summaries still describe the backend sequence rather than the completed matrix.
- [x] **ROOT CAUSE (WHY + WHERE)** — Backend leaves preserve precise local evidence but do not close the context objective. The public native exit-on-error adapters, retained typed engines and per-call generated entries have different proof boundaries and must stay distinct.
- [x] **FIX** — Reconcile the exact six-runtime matrix, authored case counts, three mutation controls, explicit guard costs and unassessed diagnostic/resource limits; close only bounded context parent .1.1.3.2 under this canonical milestone.
- [x] **ADDRESSED (verified)** — All40 source-hash references across20 files and39 retained logs match their six checkpoints. Original fixtures stay exact; Rust allocation repair and Dart package-context analysis remain explicit. Every typed route proves90 calls/three mutants with recovery only on retained parsers.
- [x] **NO REGRESSION** — No runtime, fixture, test, generated-schema or dependency change. Book and focused evidence checks precede exact staged canonical CI; landing requires its receipt. Known optional full-backend gate issues are not claimed closed.
- [x] **LOCKSTEP** — Ledger, public book, Knowledge, checkpoint, roadmaps, task frontier, MEMORY and bounded live/history records agree. Lossless segmentation/child parsing .1.1.3.3 follows; no XML, indentation or format-campaign admission.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3`
  Status: `done`
  Goal: Probe lossless segmentation and bounded child parsing with exact source provenance and caller-authorized dispatch.
  Dependencies: `.1.1.3.2`
  Children: `.1.1.3.3.1`, `.1.1.3.3.2`, `.1.1.3.3.3`, `.1.1.3.3.4`, `.1.1.3.3.5`
  Acceptance: Every original scalar belongs to a tested segment; child bounds and composed spans are exact; no host parsing escape or ambient loading is introduced. Keep private carrier and public authoring boundaries explicit.

  Closeout: Bounded child evidence reconciled under .1.1.3.3.5; exact staged canonical receipt is required for this parent closure. All separate defect owners remain open.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.1`
  Status: `done`
  Goal: Resolve the public/private authority boundary and define independently checkable lossless composition slices.
  Activation: Clean ca197a38c269cfeb89341505db83e395ebf6f308; no modified/untracked files, hooks active, context milestone committed. September27 cleanup is current.
  Verification tier: `focused`
  Focused checks: Existing typed-source, inter-match-gap, progressive-span and staged-AST neutral checkers; exact authority/consumer path audit; mdBook rendering; Knowledge/memory/history checks; all doctrines; git diff --check.
  Canonical trigger: none for an ordinary evidence/plan slice; no capability, runtime, contract, generated format, gate or infrastructure change. Parent closeout remains canonical under .3.5.
  Acceptance: Bind the public gap and exact parse_job assignment authorities, distinguish private dispatch_span, identify existing defect owners and select a finite corpus with explicit reconstruction, child-language, provenance and authority oracles. Do not infer runtime composition proof from neutral checks.
  Verification: Four existing neutral checkers pass: typed14/0/231; gaps9/0/63 plus34 public; progressive9/9/116 plus60 public; staged9 rollout legs/123 plus129 public. Contract-derived consumer path and ledger-reference audit and rendered scope assertions pass; checkpoint docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.1-verification.json records exact identities and logs. Standard memory/Knowledge/history/doctrines govern landing. No new runtime composition is claimed.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.1 - scope lossless child readiness proof`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.2`
  Status: `done`
  Goal: Prove public lossless segment authoring through Perl native and freshly emitted execution.
  Dependencies: `.1.1.3.3.1`
  Activation: Clean cdae1d2; authority plan committed with all nine doctrines and the activation-pointer hook passing, empty brief and no pending job.
  Verification tier: `focused`
  Focused checks: LinkedSpec::Get and return_descriptor probe of the exact new grammar; existing t/nested_tree_readiness.t extended through native/fresh emitted sequences and mutation controls; direct-dependent gap/generated-entry suites; exact book include/output render; neutral gap and staged checkers; Knowledge/memory/history and all doctrines; git diff --check.
  Canonical trigger: none for bounded authored fixture and regression proof; any production/contract/infrastructure defect receives a separately owned slice, and .3.5 remains canonical.
  Acceptance: Commit a portable grammar and independently authored exact cases covering empty/no-match input, prefix/interstitial/tail, adjacent matches, Unicode scalars, CRLF and malformed candidate text retained as gaps. Assert ordered spans cover every input scalar exactly once and reconstruct exact input; preserve empty gaps and selected slot identity. Exercise output/spans and grammar mutants, repeat retained-parser calls, and execute the same source in the book. This is segmentation, not strict whole-document validation.
  Owned documentation defect: The published Current lossless-segmentation example uses List::OR with LX. Exact extracted-source Get returns null for empty input and [null,null] for αalpha, betaω. A default List:: twin returns the claimed segments. dump_parser_source shows rep_acode installing the EX tail and returning its collector rather than executing LX (retained generated.pl lines81-93); language readiness metadata alone still says both rules are ready. This leaf repairs the mode spelling and locks the exact published fence on native/fresh emitted routes. No engine semantic change.
  Diagnostic hygiene: The initial debug-level bootstrap trace completed and was removed only after its byte count/hash and generated-handler cause were retained. Its command exited25 and is not successful test evidence. docs/ARTIFACT_CLEANUP.md records this exact owned removal.
  Verification: PASS readiness537, direct-dependent gap/generated137, syntax, neutral gap9/0/63+34 and staged9/123+129. Exact rendered include/fence and independent Python slicing agree with all13 cases/39 segments. Four extraction mutants and the old published mode fail the original oracle with exact wrong outputs on both native/fresh emitted routes. Checkpoint docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.2-verification.json binds sources and logs; standard gates govern landing.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.2 - verify lossless Perl segmentation`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — LinkedSpec::Get on the original extraction draft returns null/collectors despite two all-ready rules. Exact published fence reproduces the same OR/LX failure; the default-loop twin returns the independently expected segments.
- [x] **ROOT CAUSE (WHY + WHERE)** — dump_parser_source selects rep_acode for explicit OR; its successful-miss branch installs EX and returns the collector. The grammar's LX is the wrong terminal owner. The public-entry prefix is an independently documented boundary, not input deletion or a new engine defect.
- [x] **FIX** — Use default Segments::/List:: with LX. Commit thirteen exact extraction cases, explicit initial-prefix retention, native/fresh emitted proof and exact published-fence recurrence. No production/runtime or dependency edits.
- [x] **ADDRESSED (verified)** — Exact source/expected comparisons, independent scalar slicing and reconstruction, repeated calls and returned-gap detachment pass. Four extraction mutations and the original published-mode regression produce their specific wrong outputs and fail the unchanged oracle on both routes.
- [x] **NO REGRESSION** — Existing nesting/context/entry scenarios remain unchanged in the complete focused readiness consumer; direct-dependent gap/generated-source consumers pass137. Perl syntax and neutral gap/staged checks pass. This authored test/documentation slice uses ADR0073 focused proof; it does not claim a new full Phase0 or six-runtime execution.
- [x] **LOCKSTEP** — Canonical fixture, lossless ledger, book include/example correction, Knowledge, checkpoints, roadmap/current pointers, cleanup and bounded history carry the same scope. Staged children and other backend routes remain separately owned future work under .3.3/.3.4.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.3`
  Status: `done`
  Goal: Compose public parse_job markers with the lossless parent and an actual precompiled child .spec in Perl.
  Dependencies: `.1.1.3.3.2`
  Activation: Clean 81ee666f6e03422338d0b002bebe6e6bed94787c; segmentation leaf committed, all nine doctrines and pointer hook pass, brief empty and no outstanding job.
  Verification tier: `focused`
  Focused checks: LinkedSpec::Get/return_descriptor and emitted source for parent/actual child; original thirteen-case segmentation oracle after enrichment; exact child requests and local/global spans, no-seed and authority denials, typed child rejection/recovery and bounded-call controls; native/fresh emitted parents and children; staged/gap/readiness direct dependents, exact book source/render, Knowledge/memory/history/doctrines and git diff --check.
  Canonical trigger: none for a bounded composition fixture and consumer. Any implementation/authority-contract defect receives a separately owned repair; final .3.5 remains canonical.
  Acceptance: The host supplies only precompiled authority and bounded request plumbing; child .spec owns recognition and result construction. Prove exact selected child text, Unicode local/global provenance, parent reconstruction after enrichment, child rejection and recovery, missing/unapproved authority, and no implicit loading. Cover native and independently emitted parent/child routes. Determine whether any known staged/progressive defect is on the selected path before claiming bounds; split necessary repairs under their existing owners. Source-bound parse_job operands remain exactly the admitted forms, with no invented gap_text/Span public operand.
  Verification: Readiness252 and direct-dependent817 PASS; neutral staged123/129 PASS; both rendered grammar includes equal tested source; syntax, Knowledge/memory/history and registered doctrines govern landing. Exact inputs/logs are bound in docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.3-verification.json.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.3 - verify actual Perl child composition`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — The segmentation-only Get result preserves text but supplies no real child recognition. Native Get and fresh emitted parent/child runs now consume the original thirteen-case oracle twice and compare exact child requests/results; three controlled grammar mutations establish independent failing boundaries.
- [x] **ROOT CAUSE (WHY + WHERE)** — LinkedSpec::Get return_descriptor for Item records one STAGED_PARSE_JOB_MARKER with portable ActionIR and no raw/unresolved dependency. The child Number/Digits rules own recognition and AST construction; caller authority alone invokes that parser and rebases its returned local span. Parent source-bound group selection excludes neighboring delimiters.
- [x] **FIX** — Add portable parent/child fixtures and four strict accepted/fifteen rejected child controls; compare native/native, both mixed pairs and fresh emitted/emitted without a loaded compiler. Preserve exact original segment records after annotation and pin local/global spans, sidecars, authority denials, inert no-seed behavior, bounded call accounting, rejection recovery and detachment.
- [x] **ADDRESSED (verified)** — Readiness252 PASS includes three falsification controls per pair: overly broad child acceptance of00, wrong local/rebased span and delimiter-inclusive request. Four carrier observations match completely. Child failure executes12 then00, never7, publishes no partial AST and recovers on8. Missing identity/top/steps execute zero callbacks; one-call exhaustion executes one.
- [x] **NO REGRESSION** — All original nesting/context/entry/segmentation controls and staged/gap/generated-source direct dependents PASS817; neutral staged check PASS123 contract/129 public mutations; Perl syntax clean. No production runtime or authority contract changes; ADR0073 focused scope does not claim new whole-backend or full Phase0 execution.
- [x] **LOCKSTEP** — Actual tested grammars are exact rendered book includes. Canonical lossless ledger, Knowledge, checkpoint, task/frontier, roadmaps, bounded live/history and MEMORY agree. Other backend carriers and canonical reconciliation remain separately owned under .3.4/.3.5; existing startup resource/stitch owners stay open.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4`
  Status: `done`
  Goal: Extend the unchanged lossless and child-composition corpus to every required native and supported carrier route.
  Dependencies: `.1.1.3.3.3`
  Children: `.1.1.3.3.4.1`, `.1.1.3.3.4.2`, `.1.1.3.3.4.3`, `.1.1.3.3.4.4`
  Acceptance: Split into backend-sized leaves before implementation. Run Rust, Dart, Julia, PUC Lua and LuaJIT against the original authored oracle; distinguish native, reconstructed, generated and independently emitted carriers, retained recovery and per-call isolation. Preserve authority-negative and provenance mutation controls; do not convert a private dispatch carrier into public API evidence.

  Closeout: Bounded child evidence reconciled under .1.1.3.3.5; exact staged canonical receipt is required for this parent closure. All separate defect owners remain open.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.1`
  Status: `done`
  Goal: Prove exact lossless segmentation and actual staged child composition through Rust native and supported carriers.
  Dependencies: `.1.1.3.3.3`
  Activation: Clean e31c24c7f3c807a640337534c7019fb75908d216; all nine doctrines and post-commit pointer pass, brief empty, no outstanding job.
  Verification tier: `focused`
  Focused checks: Rust readiness public parser/compiler validation, native/reconstructed/generated/serialized/fresh emitted parent and actual child; unchanged segment/child corpora and recognition/provenance/bounds mutants; authority denials and selected budgets, exact error codes, recovery versus per-call isolation; direct-dependent staged/gap consumers, neutral staged contract, exact book/render, storage allocation regression, Knowledge/memory/history/doctrines and git diff --check.
  Canonical trigger: none for bounded authored fixtures and consumer extensions reusing existing storage owners. Any runtime/contract/storage defect is split before repair; .3.5 remains the canonical milestone.
  Acceptance: Retain independent scalar slicing/classification/reconstruction. Actual precompiled .spec owns child recognition and ASTs; caller only supplies authority and span projection. Cover six supported matched parent/child carriers, repeat original cases, preserve local/global provenance and original item text, and distinguish retained recovery from rebuilt per-call isolation. Use explicit step/call controls without claiming arbitrary recursion or MAX-counter safety. Existing startup .73/.74/.75/.78 remain owned; small direct-span children avoid conflicting destinations, returned markers and extreme arithmetic. No submodule internals or dependency changes.
  Verification: Focused2 outer/3 emitted PASS; combined readiness6 + gap1 + staged1 PASS, including both prior four-test emitted children; Rust storage PASS17 owners and relocation; neutral staged123/129, exact book/render, unchanged original .spec/JSON, formatting and whitespace pass. Memory/history/Knowledge and registered doctrine checks govern landing. Exact source/log hashes: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.1-verification.json.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.1 - verify Rust lossless child carriers`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Perl Get/emitted proof did not establish Rust lossless/actual-child carriers. Rust public parse_spec_with_user_functions, validate and compile now run unchanged .spec/JSON sources through native/reconstructed/generated/serialized/fresh emitted routes; seven controlled mutations falsify independent boundaries.
- [x] **ROOT CAUSE (WHY + WHERE)** — Existing portable authored actions and staged seeds already compose this bounded objective. The parent preserves entry/loop text and declares source-bound groups; the actual Number/Digits .spec constructs child ASTs. Shared rust_checks.rs projects only authorized spans in host glue and independently checks original records, scalar slices and callback requests. No runtime defect was found on these selected routes.
- [x] **FIX** — Extend the existing readiness harness with six matched pairs and seven mutations; reuse its atomic LocalCrate allocator and target cache. Four pairs retain engines, while serialized and fresh emitted entries create per-call engines. Ten independently compiled modules execute three required child tests.
- [x] **ADDRESSED (verified)** — Focused2 outer/3 emitted PASS. Each route repeats13 segmentation and enriched cases twice, child4/15 and all seven mutants. Exact authority codes, typed child status1, local/rebased spans, inert markers, detachment and selected budgets pass. Five in-process pairs compare complete successful results; fresh emitted uses the same independent oracle.
- [x] **NO REGRESSION** — Combined readiness6/gap1/staged1 PASS includes unchanged nesting/context and concurrent emitted jobs; Rust storage PASS17 owners/relocation; neutral staged123/129 and exact book source PASS. Original source/case files match activation HEAD. No production, dependency, generated-format or authority change; focused evidence does not claim canonical/full-backend execution.
- [x] **LOCKSTEP** — Shared test sources, ledger, book carrier/reuse table, Knowledge, checkpoint, task/frontier, roadmaps, MEMORY and bounded live/history agree. Dart, Julia and shared Lua retain explicit children. Startup .73/.74/.75/.78 obligations remain open; small direct plain-child controls do not close them.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.2`
  Status: `done`
  Goal: Prove the same lossless and actual-child corpus through Dart native and supported reconstructed/generated/emitted carriers.
  Dependencies: `.1.1.3.3.4.1`
  Activation: Clean a05b336a33ce5643376ea3020ee93880c82b3943; Rust leaf and all nine doctrines committed, brief empty, no outstanding job.
  Verification tier: `focused`
  Focused checks: Public Dart parser/compiler validation; six matched native/SpecFile reconstructed/generated/v2/fresh emitted parent-child carriers, unchanged original13 and child4/15 corpora, seven mutants, source slices/provenance, exact failure codes, selected budgets and retained/per-call distinction; detached outcome sink records; direct-dependent readiness/staged/gap/emitter tests; fatal main/fresh-package analysis, storage, neutral staged, exact book/render, Knowledge/memory/history/doctrines and git diff --check.
  Canonical trigger: none for bounded fixture consumers reusing existing allocation. Split any required runtime/storage/contract repair before changing it; .3.5 remains canonical.
  Existing obligations: DART-STARTUP-READING.2.17 diagnostic byte containment, .2.18 extreme call arithmetic and .2.19 malformed provenance types are read and remain open. Authored direct groups/plain child ASTs/small counters do not establish those adversarial boundaries; whole-package SDK gate .2.25 remains separate.
  Acceptance: Preserve the authored oracle, recognition/provenance/bounds mutants, exact denials and retained/per-call distinction. Review Dart staged provenance/resource defect cards before activation, use strict package analysis and existing storage owners, and split necessary repairs.

  Verification: Focused2/selected88 PASS; fatal main/fresh-package analysis and exact ten-module completion PASS; storage25 owners/47 packages PASS; neutral staged123/129 and rendered original source/reuse limits PASS. Original .spec/JSON and production/dependency state stay unchanged. Checkpoint: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.2-verification.json; registered doctrines govern landing.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.2 - verify Dart lossless child carriers`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Perl Get/Rust proof did not establish Dart actual-child composition. Public parseSpecWithStagedUserFunctionDefinitions, validateSpec, compileSpec and fresh emitted modules now execute the unchanged thirteen-case segmentation/enrichment and child4/15 oracles across six matched pairs.
- [x] **ROOT CAUSE (WHY + WHERE)** — The existing portable DSL and staged authority already support this bounded grammar. Dart returns an AST and exposes a separate detached outcome through StagedAstEnrichmentSeed.outcomeSink. Shared dart_checks.dart verifies both, while the actual Number/Digits child owns recognition/AST construction and host glue only supplies authority and rebaseSpan.
- [x] **FIX** — Add shared six-pair checks, seven falsification controls, exact staged codes/typed exits, source slices and local/global spans, authority denials, selected budgets, no-seed markers and result/outcome mutation controls. Reuse the existing allocator through one same-file function; analyze unchanged checker/producer copies and ten emitted modules in valid package context.
- [x] **ADDRESSED (verified)** — Focused2 and selected88 PASS; five in-process pairs agree on complete successful outcomes. The fresh package resolves offline, passes fatal analysis and returns the exact ten-module/13-case/child4/15/seven-mutation report. Four pairs retain engines and two use per-call engines; rejected parses expose no completed outcome.
- [x] **NO REGRESSION** — Prior nesting/context, staged/gap, emitter and document tests PASS in selected88; fatal main-test analysis and storage25 owners/47 packages PASS; neutral123/129, original source/case equality, exact rendered book and whitespace PASS. No production/generated-format/authority or dependency change; whole-package SDK obligations stay separate.
- [x] **LOCKSTEP** — Ledger, book, Knowledge, checkpoint, task/frontier, roadmaps, bounded live/history and MEMORY preserve exact scope. Julia/shared Lua remain owned; Dart .2.17/.2.18/.2.19/.2.25 remain open. No general resource or standard-format admission is claimed.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.3`
  Status: `done`
  Goal: Prove the same lossless and actual-child corpus through Julia native and supported reconstructed/generated/emitted carriers.
  Dependencies: `.1.1.3.3.4.2`
  Activation: Clean 624aa1995d52426a69d7debfdaa2afd6ae578d5f; Dart leaf and nine doctrines committed, brief empty, no outstanding job.
  Verification tier: `focused`
  Focused checks: Julia public parser/compiler validation and five supported matched native/reconstructed/generated/emitted parent-child routes; unchanged original13 and child4/15, seven mutants, scalar slicing/provenance, exact typed staged failures, selected budgets and retained/per-call distinction; actual returned-object mutation plus deliberately aliased control; emitter/readiness/staged/gap/document dependents, existing storage owner/cleanup, neutral staged, book source/render, Knowledge/memory/history/doctrines and git diff --check.
  Canonical trigger: none for bounded authored test consumers reusing current allocation and host launcher. Any runtime/storage/contract repair is split before change; .3.5 remains canonical.
  Existing obligations: JULIA-STARTUP-READING.2.13 registry patterns, .2.14 diagnostic byte containment and .2.26 general staged result-isolation assertion repair are read and stay open. This fixture uses valid ordinary identities, direct spans, plain child ASTs and small counters; its direct-result proof does not repair the existing consumer.
  Acceptance: Preserve exact oracles, mutants, authority denials and retained/per-call distinction. Review Julia staged registry/diagnostic/result-isolation cards, verify fresh emitted hosts, and split any repair dependencies.

  Verification: PASS source-emitter194 (new69, existing125); staged491/gap319/document128 (938); storage22 owners/five locked package trees; neutral staged123/129; exact rendered source and Julia claims. Original grammars/cases/manifests unchanged.
  Evidence: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.3-verification.json and docs/knowledge/julia-lossless-child-carrier-readiness.md.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.3 - verify Julia lossless child carriers`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.3` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Existing Julia readiness consumers cover nesting/context but no composed gap/actual-child grammar. Public parse_spec_with_staged_user_function_definitions, validate_spec, compile_spec and generated v2 entries now consume the unchanged sources.
- [x] **ROOT CAUSE (WHY + WHERE)** — WHY: bounded grammar composition and returned-object isolation require independent behavioral proof. WHERE: the source-emitter consumer and new shared lossless checker/carrier producer; no runtime defect is inferred from missing coverage. Existing staged-consumer copy-mutation debt stays separately owned.
- [x] **FIX** — Add five matched routes, exact scalar preservation/provenance/selected accounting and typed failures; retain two pairs, distinguish three per-call entries, and challenge actual returned objects plus a deliberately aliased pair. Reuse the existing allocation owner and latest-world fresh host.
- [x] **ADDRESSED (verified)** — New69 assertions and full emitter194 pass. Four in-process pairs agree on26 complete enriched records; the fresh host validates ten modules and exact13/4/15/seven-mutant/alias report, process success and scratch absence. Each pair preserves original segmentation, strict child recognition, selected authority denials and failure recovery or per-call isolation.
- [x] **NO REGRESSION** — Existing emitter/nesting/context125, staged491/gap319/document128, storage22/five locked packages and neutral123/129 pass. Original source/oracle/manifest bytes remain exact; no production, generated format or dependency change.
- [x] **LOCKSTEP** — Book and exact included sources, ledger, Knowledge, checkpoint, task/frontier, roadmaps, bounded live/history and MEMORY agree. Shared Lua .3.4.4 follows; canonical .3.5 alone closes the parent. Julia .2.13/.2.14/.2.26 remain open.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.4`
  Status: `done`
  Goal: Prove the same lossless and actual-child corpus through shared Lua carriers on PUC Lua and LuaJIT.
  Dependencies: `.1.1.3.3.4.3`
  Acceptance: Run both ABIs with exact original oracles, mutants, authority controls, provenance and supported fresh carriers. Review current shared staged resource/provenance cards and keep both runtime rows explicit. Parent .3.4 closes only during canonical reconciliation .3.5.

  Activation: Clean d903f0719823c001144ec346cd32a10fc292f7c6 after Julia proof; nine doctrines and post-commit pointer pass, brief0 and no outstanding job.
  Verification tier: `focused`
  Focused checks: Shared Lua five matched public native/reconstructed/generated/emitted routes on each ABI, unchanged original13 and child4/15, seven mutants, exact scalar/provenance/selected accounting/authority controls, actual-returned isolation plus aliased control; existing v2/nesting/context/staged/gap/document tests, real storage, neutral staged and exact book source; Knowledge/memory/history/doctrines and diff checks.
  Canonical trigger: none for bounded consumer-only proof reusing the existing allocation owner; canonical .3.5 owns parent closure. Split runtime, infrastructure or public-contract repairs before change.
  Existing obligations: Lua .2.25 malformed snapshot arrays, .2.26 diagnostic bytes, .2.27 marker cycles/null, .2.28 private capture bounds, .2.29 malformed provenance and .2.8.15/.16 seeded-counter defaulting remain open. Plain child values, dense valid snapshots/direct spans and small counters avoid those adversarial boundaries. Installed-PUC baseline .2.2 and guidance .2.1 remain separate.
  Verification: PASS222 v2 assertions (new62/existing160) per ABI; staged890/gap392/document51 cases/27 round trips/24 recoveries per ABI. Storage19 owners/three dual-ABI modules/30 census controls; neutral123/129 and exact rendered source/scope pass. No runtime/fixture/native/dependency change.
  Evidence: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.4-verification.json and docs/knowledge/lua-lossless-child-carrier-readiness.md.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.4 - verify dual-ABI Lua lossless child carriers`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Shared Lua v2 readiness lacked the actual lossless/child objective. Public parse_spec_with_staged_user_function_definitions, validate_spec, compile_spec and generated v2 consume unchanged grammars on both ABIs.
- [x] **ROOT CAUSE (WHY + WHERE)** — WHY: gap preservation, actual child execution and result isolation need composed evidence beyond separate contract consumers. WHERE: the existing v2 consumer and new shared lossless checker/producer. No runtime repair is inferred; earlier staged boundary defects remain separately owned.
- [x] **FIX** — Add five matched routes per ABI, independent UTF-8 scalar slicing, exact authored records and source rebasing, typed failures, selected denials/accounting and seven mutants. Mutate actual returned objects and reject a deliberately aliased pair; reuse existing workspace ownership.
- [x] **ADDRESSED (verified)** — Both hosts pass222 including new62. Four in-process pairs agree on26 complete enriched records; all five execute original/enriched13 twice and child4/15. Fresh selected-ABI children validate ten modules and exact completion, successful status, empty stderr and cleanup. Two retained pairs remain distinct from three per-call routes.
- [x] **NO REGRESSION** — Existing160 v2/nesting/context, staged890/gap392 and document51/27/24 pass per ABI. Real storage19/three modules/30 census controls and neutral123/129 pass. Shared grammar/oracle bytes, production/native modules and dependency configuration stay unchanged; unfiltered Lua baseline is not claimed.
- [x] **LOCKSTEP** — Book, exact source includes, ledger, Knowledge, checkpoint, task/frontier, roadmaps, bounded live/history and MEMORY agree. Canonical .3.5 follows; all listed Lua array/resource/marker/provenance and baseline obligations remain open.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5`
  Status: `done`
  Goal: Reconcile bounded lossless/child readiness, authoring costs, known limits and exact canonical milestone evidence.
  Dependencies: `.1.1.3.3.4`
  Acceptance: Audit source/checkpoint identities and route-level results, align ledger/Knowledge/book/roadmaps/frontier, retain open defect owners and unassessed objectives, and run exact staged canonical CI before closing .1.1.3.3. No format-campaign admission or public/private API expansion.

  Activation: Clean f10c0ce96666f4adf867f329cdf75dd793c003b2; all backend children committed, nine doctrines/post-pointer pass, brief0 and no outstanding job.
  Verification tier: `canonical`
  Focused checks: Audit all seven checkpoint source/log identities against producing commits and current sources, independent original oracles and exact route/reuse/mutation ledger; book render/source assertions, Knowledge/memory/history/doctrines and diff hygiene.
  Canonical trigger: Milestone and parent closeout require tools/run_ci_local.sh on the exact fully staged candidate, with a receipt required for landing.
  Scope: Close bounded lossless/actual-child .3 and backend parent .3.4 only through canonical acceptance; preserve authored costs, runtime-specific limits and all separate defect owners. No runtime, fixture or public contract change.
  Verification: Seven checkpoint blobs/180 historical source references/132 unique current paths and47 retained logs pass. Only successive book revisions differ, with producing blobs exact. Independent13-case/39-segment reconstruction and three evidence-corruption/two path controls pass; exact book proof and standard gates precede staged canonical CI. Its receipt is mandatory for landing; actual result belongs to the commit body.
  Authoring assessment: No new primitive selected. The21-line segment grammar,27-line parent and21-line child require explicit skipped-prefix retention, correct loop/LX mode, child entry/end guards and caller-frozen compiled registry/span projection. Neither ambient loading nor copied/gap/arbitrary-span operands are admitted.
  Evidence: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5-verification.json; lossless ledger and reconciliation Knowledge card.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5 - reconcile bounded lossless child readiness`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Backend-sized proofs exist but current task/roadmap rows still name completed child work as future. The parent lacks one exact route/reuse/authoring-cost ledger; canonical closeout remains required.
- [x] **ROOT CAUSE (WHY + WHERE)** — WHY: chronological backend evidence was recorded separately while early current-summary rows remained. WHERE: roadmap lane rows, task index and Knowledge statuses. Public Get/parse_spec/compile_spec/runtime carrier producers and their frozen checkpoints establish bounded grammar behavior, not universal language completeness.
- [x] **FIX** — Reconcile31 matched pairs across six runtimes, retained/per-call distinctions, original source/oracle identities, seven mutation roles, explicit authored guards and every existing defect owner. Correct current summaries while preserving historical evidence; add a read-only reproducible source/log audit.
- [x] **ADDRESSED (verified)** — All180 historical references/132 current source paths and47 retained logs verify against seven producing commits. Only explained book evolution differs. Independent scalar slicing verifies13 cases/39 segments and child4/15 inventory. Controlled corrupt checkpoint/source/log inputs and outside paths reject; exact book blocks and published matrix render.
- [x] **NO REGRESSION** — No runtime, original fixture, dependency or generated-format change. Complete backend-focused proofs remain source-exact; canonical CI is required on this exact staged candidate before parent closure can land. Optional unfiltered gates and known separate defects are not claimed closed.
- [x] **LOCKSTEP** — Ledger, book, current Knowledge statuses/new fact, checkpoint/audit producer, task/frontier, roadmaps, MEMORY and bounded live/history agree. Three-objective .1.1.3.4 follows before finite gap selection; standard formats, alternate syntax and general resource safety remain gated.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.4`
  Status: `done`
  Goal: Reconcile the three bounded objective results and authoring costs for gap selection under `.1.1.4`.
  Dependencies: `.1.1.3.1`, `.1.1.3.2`, `.1.1.3.3`
  Activation: Clean 7c8a240be8f444e314ad415fa9e963045fdd91ec; artifact review is current, brief empty and no uncommitted input. Supplied policy hashes match the existing September11 comparison; startup .5/.29 still own adoption.
  Verification tier: `canonical`
  Focused checks: Historical checkpoint/source/log audit for all three objectives, independent authored-oracle spans and corpus enumeration, corrupted evidence controls, exact book table/source assertions and rendering; Knowledge/memory/history/doctrines and diff hygiene.
  Canonical trigger: Close representative-objective parent .1.1.3 after exact staged tools/run_ci_local.sh acceptance. No new objective or whole-format admission.
  Acceptance: Preserve exact runtime/carrier coverage, limitations, mutations and repair owners; require fresh proof before promoting any objective and keep whole-format campaign readiness pending.
  Scope: Current evidence integrity over historical six-runtime executions; no new objective promotion, runtime, fixture, public API or capability movement. Close only representative parent .1.1.3 through the mandatory exact staged receipt.
  Verification: Tracked audit PASS24 producing checkpoints/257 historical source references/149 latest inputs/134 retained logs. Independent corpus enumeration and scalar slicing verify nesting6/7, context11/17, segment13/39 and child4/15; four corrupted inputs, two outside paths and summary recovery inflation reject. Latest executable evidence is exact; only current book evolution differs. Exact rendered source/table review and standard gates pass before canonical CI; actual canonical result is retained in the commit body.
  Authoring assessment: Existing primitives compose all three bounded objectives; no missing primitive selected. Explicit strictness/prefix guards, AST/span constructors, limited diagnostics, loop/LX selection and frozen caller authority remain costs. Indentation, richer errors, resource safety, performance and whole standards remain unassessed. Existing startup/backend defects retain their original scheduled owners.
  Evidence: docs/language-readiness/objective-reconciliation.md; docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.4-verification.json; tests/language-readiness/verify_objectives.py.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.4 - reconcile three bounded language objectives`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Existing three milestones have separate source-located proof; current rows still schedule reconciliation before gap selection. The tracked audit command freshly enumerates their checkpoint/source/log evidence without executing a new runtime objective.
- [x] **ROOT CAUSE (WHY + WHERE)** — WHY: chronological objective ledgers lack a combined comparison of strict recognition, lossless extraction and authoring costs. WHERE: current task/roadmap/book summaries. Earlier public LinkedSpec::Get/parse_spec/compile_spec/runtime carrier mechanisms remain owned by their producing checkpoints.
- [x] **FIX** — Add one comparison and read-only audit, preserve exact carrier/recovery/mutation limits and original repair ownership, synchronize current book/roadmap/Knowledge/frontier, select finite gap review next.
- [x] **ADDRESSED (verified)** — PASS24 checkpoint blobs/257 historical source references/149 latest inputs/134 logs; independent scalar slicing and source-exact oracles. Deliberately corrupted checkpoint/source/log/oracle inputs and inflated summary recoveries reject; current book change is identified separately.
- [x] **NO REGRESSION** — Original runtime and fixture bytes stay exact. Book rendering and git diff --check pass; exact staged bash tools/run_ci_local.sh receipt is required before parent closure lands. Historical six-runtime proof is not relabeled as fresh execution or optional complete backend gates.
- [x] **LOCKSTEP** — Comparison, book, Knowledge card, checkpoint, task/index, roadmaps, bounded live/history and MEMORY agree. .1.1.4 follows; .1.1.5 and startup .5/.29 retain documentation/policy repair obligations. No standard format or alternate syntax is admitted.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.4`
  Status: `done`
  Goal: Reconcile the finite inventory and representative evidence into an owned gap list for `.1.2` and `.1.4`.
  Dependencies: `.1.1.3`
  Activation: Clean f84d794fb18475cb78d5fbd4aec3e37e57514b88; representative parent committed with exact canonical receipt, brief0 and no outstanding job.
  Verification tier: `focused`
  Focused checks: Existing three-objective source/log/oracle audit; exact nine-area authority and repair-owner review, finite-list link/owner checks and rendered book review; Knowledge/memory/history/doctrines and git diff --check.
  Canonical trigger: none for a bounded classification and scheduling ledger preserving existing contracts and admission; .1.1.5 retains canonical manifest/checker repair and inventory-parent closeout.
  Acceptance: Every observed gap is implemented, partial, missing, compatibility-only, backend-host or deliberately forbidden; untested objectives remain separately unassessed. New capability proposals identify reusable semantics and portable proof, and existing defects retain their original repair owners and priority. Do not imply an exhaustive proof of every possible grammar.
  Selection: docs/language-readiness/finite-gap-list.md classifies nine dimensions, existing repair obligations, compatibility/host/non-authority boundaries and six requirement/cost groups. No missing parsing primitive selected; named arguments stay parked. .1.2/.1.3/.1.4 own explicit next uses; affected repairs precede dependent promotion.
  Verification: PASS objective audit24 checkpoints/257 historical source references/149 latest inputs/134 logs and original falsification controls; nine unique areas/twelve JSON authorities/thirty pending repair owners plus proposed parked named arguments; all local ledger links and four rendered-book assertions. Book build, Knowledge1220/9632, memory and both history budgets pass. Registered doctrines and diff hygiene govern landing; no fresh backend execution, runtime or contract movement.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.4 - classify finite language readiness gaps`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.4` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Two dated inventories and three objective ledgers require one current classified selection before closure definition; existing source/log audit remains the proof boundary.
- [x] **ROOT CAUSE (WHY + WHERE)** — Separate inventories mix contract admission, known narrower defects and then-unassessed composition. The combined comparison proves finite objectives but cannot infer absent primitives or universal resources.
- [x] **FIX** — Add the finite gap list with nine areas, original repair routing, compatibility/host/forbidden boundaries, authoring costs and separately scheduled unassessed requirements. Correct the old hygiene index's current next-state wording.
- [x] **ADDRESSED (verified)** — Review exact authority paths and current repair metadata, verify original evidence with the existing audit, and inspect the rendered finite-selection table. No runtime proof is newly promoted.
- [x] **NO REGRESSION** — No executable or admitted contract changes; original audit controls, book rendering, history pressure, Knowledge, memory, all doctrines and diff hygiene must pass before landing.
- [x] **LOCKSTEP** — Ledger, Knowledge, book, task/frontier, roadmaps and bounded live/history agree; .1.1.5 follows before .1.2. Existing priorities/dependencies and parked features remain intact.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.5`
  Status: `done`
  Goal: Repair the stale general capability description of removed global parse-mode controls and guard recurrence.
  Priority: P2; after representative inventory reconciliation `.1.1.4`, before `.1.2` uses that manifest as closure authority. Coordinate startup `.41.2` without duplicating its broad guide repair.
  Dependencies: `.1.1.4`
  Activation: Clean 9a07b6375b0053063c54e48023741f294436242c; finite classification committed with all nine doctrines, post-commit pointer pass, brief0 and no outstanding job.
  Verification tier: `canonical`
  Focused checks: Existing capability checker/specific cursor/root authorities reproduce the stale description; old-checker RED/new-checker reason-sensitive mutations, unchanged census/IDs/states, generated-source/language and root/cursor direct dependents, public book render, source identity; Knowledge/memory/history/doctrines and diff hygiene.
  Canonical trigger: Capability/checker governance repair and inventory-parent .1.1 closeout require exact fully staged tools/run_ci_local.sh acceptance before landing.
  Additional defect owned here: Initial specific cursor check rejects the newly documented architecture page as unowned migration input. The .1.1.4 book paragraph newly matches the existing parse-mode census; its semantics are correct but its inventory registration was omitted. Register the reviewed page and any new checker token-bearing input, preserve exact census/public count projections and require the existing inventory-omission mutation before closing this leaf. Evidence: .linkedspec-data/scratch/selfcontain115/cursor-before.log.
  Direct-dependent mirror: First doctrine run rejects the stable closed-capability marker's old77-file verifier after the public marker moves to79. Update the existing tools/check_task_tree_closed_capability_markers.py mirror in lockstep, preserving sentinel placement and all marker mutations; docs/knowledge/task-index-marker-anchor-hazard.md already identifies this dependency. The failed run is not signoff.
  Reproduce: Run perl tools/check_capability_conformance.pl (passes 20/100/0/0), then compare manifest capability runtime.top_rule_and_parse_mode_controls.contract with rule_local_cursor_contract.json policy.global_override. The former says native execution accepts seek/consume parse-mode controls; the latter removes public overrides, and the public rule-mode guide documents targeted rejection.
  Root cause: tools/check_capability_conformance.pl validate_manifest requires a nonempty contract string for general rows (line797 at activation), while exact text checks at line606 apply only to the two mutation capabilities. No current semantic assertion binds this general row to the rule-local-cursor authority.
  Impact: Inventory readers can infer a removed option is supported from a green census. No runtime regression is asserted.
  Acceptance: Preserve stable capability identity where required, reconcile its description to explicit entry selection and intrinsic family cursor policy, and add a reason-sensitive regression that rejects the stale claim. Verify dependent capability/generated-source consumers and public teaching; use canonical tier for checker/contract admission movement.
  Closeout: This is the final pending child of .1.1; close the inventory parent only with exact staged canonical acceptance, preserving the finite gap list and all separate repair owners.
  Verification: Initial checker passes the old contradiction; new checker against old prose rejects with exact contract-authority reason. The mutation routine fails at the historical claim under the old validator; the new checker rejects all fifteen mutations, and an unrelated-error control also falsifies the reason assertion. Census IDs/statuses/backend references unchanged100/0/0; cursor79/8/0/60, root7/0/54, generated-source and language250/105+1/126 pass; four direct-dependent Perl suites312 PASS. Two removed registrations reject for exact inventory reasons; complete cursor JSON delta preserves semantics/rollout. Book/evidence/doctrine gates and exact staged canonical receipt govern landing; actual CI result is recorded in the commit body.
  Evidence: docs/knowledge/entry-cursor-capability-description-repair.md; docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.5-verification.json.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.5 - guard entry and cursor capability description`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.5` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Existing capability and root checks pass the stale description; the specific cursor check catches the newly unowned architecture page. Retained RED logs contain exact contract and inventory errors. Applying the new mutation routine to the old validator accepts the historical claim and fails the regression.
- [x] **ROOT CAUSE (WHY + WHERE)** — General validate_manifest formerly required only nonempty prose, while rule_local_cursor_contract.json removes overrides. The new .1.1.4 book prose matches the existing token census but was not registered; the new checker introduces another token-bearing input.
- [x] **FIX** — Preserve stable ID and all states/references; correct prose/sources and bind selected root/cursor invariants. Fifteen reason-sensitive mutations plus unrelated-error falsification recur. Register exactly two paths in existing groups and update ten current census mirrors; retain historical counts and broad startup .41.2 ownership.
- [x] **ADDRESSED (verified)** — Old validator RED/new checker GREEN; original stale prose rejects for the exact intended reason. Capability100/0/0, root7/0/54, cursor79/8/0/60 and two independent inventory omissions pass; canonical receipt is required for parent closure.
- [x] **NO REGRESSION** — Direct dependents312, generated-source/language and three-objective evidence integrity pass. Exact manifest/cursor JSON deltas preserve runtime semantics, authority fixtures, rollout and backend references. Book, Knowledge, memory/history/doctrines/diff and staged canonical acceptance govern landing.
- [x] **LOCKSTEP** — Public entry/cursor teaching, current79-file mirrors, repair fact, checkpoint, task/frontier, roadmaps and bounded live/history agree. Inventory .1.1 closes only through canonical receipt; bounded closure-design .1.2.1 follows. Separate defects, policy adoption and wider format/profile requirements stay open.

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
  Status: `active`
  Goal: Define the problem-domain closure boundary, determinism/resource model, state/scoping rules, and explicit
    environmental non-authority.
  Acceptance: Normative contracts answer what a `.spec` may compute, observe, mutate, return, and never access,
    including recursion/iteration limits, failure behavior, and host-boundary inputs/results.
  Dependencies: `.1.1`
  Children: `.1.2.1`, `.1.2.2`, `.1.2.3`, `.1.2.4`
  Inventory input: docs/language-readiness/finite-gap-list.md. Separate admitted/current behavior from target closure; retain recognition-only rollback, distinct callable scopes, intrinsic cursor policy, staged operand authority and unresolved resource limits. Split contract work into bounded leaves before editing normative authority.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.1`
  Status: `done`
  Goal: Design a source-located closure contract matrix and bounded freeze plan before editing normative authority.
  Dependencies: `.1.1`
  Acceptance: Retrieve exact existing authorities for compute/observe/mutate/return/non-authority, callable/rule state and progress/resource/failure boundaries. Separate normative target, current admitted behavior, known partial repairs and unassessed requirements. Identify deterministic input/output and host responsibilities; do not infer universal safety or silently choose new numerical limits. Own any genuine contract ambiguity before freeze.
  Activation: Clean6052760272a37702698745c866220679e7e13646 on October1; inventory .1.1.5 is committed, canonical receipt/post-commit pointer pass, brief0 and no pending job.
  Scope: Documentation-only matrix and freeze plan, existing-authority/reference review, current Knowledge/decision-header status reconciliation and book/continuity alignment. No normative JSON, runtime, admission or numerical-limit change.
  Verification tier: `focused`
  Focused checks: Exact authority identities/pointers and repair-owner metadata; unchanged executable authorities and original objective audit; directly affected public/neutral guards, rendered book, Knowledge, memory, bounded histories, doctrines and diff hygiene.
  Canonical trigger: none for a bounded design leaf; .1.2.2/.1.2.3 own normative artifacts/checkers and .1.2.4 owns canonical parent closeout.

  Finding (owned and repaired here): The direction card still called the completed first nesting/constructor work active; the general-recursion card still named the closed .14.3 admission as pending. Reproduce by comparing those prior current-status paragraphs with the source task metadata and605276027. Impact: a resuming reader could mistake dated guard evidence for today's diagnostic scope. Preserve original dated probes and bind current recognition/observation to their separate authorities.
  Finding (owned and repaired here): ADR0042's header/index still said backend rollout pending, although its current neutral contract/checker records8 complete/0 pending. Impact: authoritative status retrieval contradicted current admission. Route current rollout to the existing executable neutral contract; preserve every decision clause, date, fixture and admission state.
  Verification: PASS16 exact authority identities/66 semantic anchors, unchanged authority bytes, four supplemental plus two coordination owners pending, and .14.3/.14.4 done; original objective audit and six direct public/neutral guards; book five rows/four claims. Final Knowledge/memory/history/doctrine/diff proof governs landing. No new runtime or numerical-policy proof.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.1 - design language closure matrix`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.1` Acceptance Checklist

- [x] **SOURCE / OWNERSHIP** — Clean605276027 activation; retrieve ADR0064/0056/0080/0088/0042, inventories, exact JSON policies and Knowledge before composing the matrix. Indexed task status resolves current owners without modifying other trees.
- [x] **BOUNDARY / PLAN** — Sixteen authorities answer compute/recognize/observe/mutate/return/diagnose/authority and eight distinct scopes. Target/current/partial/unassessed, publication effects and compatibility/host exclusions remain explicit. Four later stages separate normative freezes, independent closeout and new objectives.
- [x] **PARTIAL / AMBIGUITY** — Retain finite-ledger repairs and their prerequisites; add existing19/21/35/39 dependencies. Resource/source-detail and general progress/error review remain37.2/.1.2.3/41.2-owned. Select no new numbers, security guarantee, extension or backend promotion.
- [x] **STATUS RECONCILIATION** — Correct stale directional progress and closed-admission references without relabeling historical ordinary-guard probes as fresh runtime proof.
- [x] **PROOF / LOCKSTEP** — Exact register/owner review, original audit, six affected guards and rendered book pass. Align Knowledge, roadmaps/frontier, bounded histories/live/resume; ordinary documentation gates and atomic commit complete the handoff.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.2`
  Status: `pending`
  Goal: Freeze the grammar/cursor/capture/state/callable/control/transformation/result closure boundary on the existing semantic core.
  Dependencies: `.1.2.1`
  Acceptance: One versioned neutral authority describes included/excluded operations, distinct scopes, recognition versus user-state effects, typed results and host-boundary inputs. Bind existing authority identities/proof owners, preserve compatibility exclusions and partial status, and add mutation-sensitive structural validation. Use canonical tier for contract/checker movement; no runtime semantics or profile-only mechanism.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.3`
  Status: `pending`
  Goal: Freeze explicit determinism, progress/resource, failure and ambient non-authority policies without inventing guarantees.
  Dependencies: `.1.2.2`
  Acceptance: State observed versus target limits, regex-substrate responsibilities, typed failure/publication effects and caller authorization. Existing resource repairs retain owners and precede dependent guarantees; invalid/adversarial cases and unassessed performance have explicit proof needs. Do not assign unsupported global limits or equate design exclusions with a security sandbox. Use canonical tier for normative movement.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.4`
  Status: `pending`
  Goal: Reconcile and close the closure-definition parent before neutral composed objectives.
  Dependencies: `.1.2.3`
  Acceptance: Independently check matrix/authority/validator and book alignment, preserved original contracts, exact partial/unassessed routing and no runtime/admission overclaim. Exact staged canonical acceptance closes .1.2; .1.3 must be split before fixture/checker implementation.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3`
  Status: `pending`
  Goal: Build neutral fixtures and a mutation-sensitive checker for representative self-contained objectives.
  Acceptance: Fixtures cover natural recursion, cursor algebra, interval/boundary capture, nested state, callable
    composition, branching/iteration, structural transformation, and typed result construction; mutations prove
    every claimed semantic dimension matters.
  Dependencies: `.1.2`
  Inventory input: Preserve the original three probes; select bounded diagnostic and callable/control/transform objectives with independent negative/effect/kind oracles. Record indentation/quotes/comments requirement scope before proposing syntax, and require affected repair owners before dependent promotion. Split selection, neutral fixture/checker and recurrence work before implementation.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.4`
  Status: `pending`
  Goal: Close the contract/gap audit and split only evidence-backed missing primitives into separately ordered
    implementation leaves before any behavior change.
  Acceptance: Every gap has one owner, portable semantics, test oracle, backend order, compatibility policy, and
    documentation obligation; speculative general-purpose features remain excluded.
  Dependencies: `.1.3`
  Inventory input: No new missing parsing primitive is selected by the current finite probes. An agreed minimized failing objective and reusable semantics are required before creating .3 implementation leaves; costs, existing defects and unassessed requirements are not interchangeable.

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
| 6 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.1` | `done` | Exact native public-loader6/7/12 on six runtimes; separate carrier proof follows in the completed rows below. |
| 7 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1` | `done` | Perl native/emitted carrier, recovery and mutation proof plus public-entry repair. |
| 8 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.2` | `done` | Six Rust carrier routes and56 retained-engine recovery transitions. |
| 9 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.3` | `done` | Six Dart routes and56 retained-engine recovery transitions. |
| 10 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.4` | `done` | Five Julia routes and28 retained-engine recovery transitions. |
| 11 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.5` | `done` | Five routes and28 retained-engine recoveries per Lua ABI. |
| 12 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.6` | `done` | Storage error handling/inventory correction and exact canonical proof. |
| 13 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.7` | `done` | Quiet absent-entry boundaries;104 focused assertions and Phase01033. |
| 14 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.3` | `done` | Bounded nesting evidence/authoring limits reconciled; exact canonical receipt governs closeout. |
| 15 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.1` | `done` | Perl native/fresh emitted context-name proof:11/17 cases,90 calls and34 recoveries per route. |
| 16 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.2` | `done` | Context11/17/22 and original-default6/7/12 pass all six native routes. |
| 17 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.4` | `done` | Exact historical evidence and authoring-cost comparison close the bounded parent through canonical acceptance. |
| 18 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.4` | `done` | Nine areas classified; original repairs, authoring costs and unassessed requirements retain explicit next actions. |
| 19 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.5` | `done` | Stable row corrected; fifteen reason-sensitive mutations and79-file cursor inventory precede exact canonical parent closeout. |
| 20 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.1` | `done` | Source-located16/66 matrix, scopes/effects and bounded freeze plan preserve partial/unassessed requirements. |
| 21 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.2` | `pending` | Freeze operation/scope/reference structure with independent mutation-sensitive governance. |

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

October1 `.1.2.1`: Register16 identities/66 anchors and unchanged authorities; six pending repair/coordination owners and closed recognition/observation status; original objective audit and six affected guards; book five scope rows/four claims. The draft CHANGES insertion matched an inline ## mention; the history check rejected its preamble. Correct to the actual section heading, preserve original bytes and recheck347/512 lines/34768/65536 bytes. Documentation-only design; ordinary gates govern landing.

October1 `.1.1.5`: Historical prose/old validator RED, fifteen mutations plus unrelated-error assertion GREEN; exact unchanged manifest identity/states/references and cursor semantics/rollout. Cursor79/8/0/60 and two registration-omission controls, root7/0/54, generated-source/language and direct-dependent Perl312 pass. Exact staged canonical receipt governs inventory-parent closure; actual CI outcome belongs in the commit body.

October1 `.1.1.4`: Finite nine-area classification preserves exact authority/repair owners and schedules six cost/requirement groups without selecting a new primitive. Existing objective audit and ordinary documentation gates govern landing; historical runtime execution is not relabeled as fresh proof.

October1 `.1.1.3.4`: Three-objective audit verifies24 producing checkpoints/257 source references/149 latest inputs/134 logs; original scalar oracles and current table match. Four corrupt inputs/two outside paths/inflated recovery row reject. Current book evolution remains separate from executable identity. Exact staged canonical receipt governs bounded parent closure; actual result belongs to the commit body.

September28 `.1.1.3.3.5`: Reconcile seven checkpoint blobs/180 source references/132 paths/47 logs, exact historical book supersessions, independent13/39 reconstruction and corruption/path controls. Public matrix and full source includes render. Exact staged canonical receipt governs parent closure; actual result is recorded in the commit body.

September28 `.1.1.3.3.4.4`: Both Lua ABIs pass222 v2/new62, staged890/gap392 and document51/27/24. Five routes preserve original13/child4/15/seven mutants; actual-result/alias controls and fresh ten-module process status/stderr/report/cleanup pass. Storage19/3/30, neutral123/129 and exact book pass.

September28 `.1.1.3.3.4.3`: Julia emitter194/new69, staged/gap/document938, storage22/5, neutral123/129 and exact book PASS. Five routes preserve original13/child4/15/seven mutants; direct returned-object mutation and a deliberately aliased pair establish bounded isolation.

September28 `.1.1.3.3.4.2`: Dart focused2/selected88, fatal main/fresh analysis, storage25 owners/47 packages, neutral123/129 and exact book PASS. Four retained/two per-call pairs preserve original13 and child4/15 with seven mutants, exact staged codes and detached AST/outcome assertions.

September27 `.1.1.3.3.4.1`: Rust focused2 outer/3 emitted and combined readiness6/gap1/staged1 PASS; unchanged oracles, seven mutants, storage17/relocation, neutral123/129 and exact book PASS. Four retained pairs and two per-call pairs stay distinct; no production repair or broader resource claim.

September27 `.1.1.3.3.3`: four parent/child carrier pairs, strict child cases and three mutants pass252; direct-dependent817, neutral staged123/129 and exact rendered source pass. Actual child recognition stays in .spec; selected call/step bounds do not close recursive or conflicting-target defects.

September27 `.1.1.3.3.2`: native/fresh emitted readiness537, direct-dependent137, neutral gap/staged, exact book source and independent13-case/39-segment scalar reconstruction pass. Published OR/LX defect is corrected and permanently reproduced by an exact old-mode mutant. Child composition remains next.

September27 `.1.1.3.3.1`: Lossless child authority review selects public gap capture and exact staged parse_job assignment, keeps private dispatch_span separate, and defines segmentation, real-child composition, backend carrier and canonical closeout slices. Four existing neutral checkers, 83 contract/checker/consumer paths, eight ledger references and rendered scope assertions pass. No new runtime composition is claimed; .1.1.3.3.2 is next.

September27 `.1.1.3.2.2`: all12 context/default native runs PASS; source/product hashes remain exact and both fixture pairs match activation HEAD. Typed JSON statuses are verified except Rust Display; adapters terminate at rejection. Rust carriers follow.

September27 `.1.1.3.2.1`: public capture/comparison/descriptor probe passes; final native/fresh emitted suite410, direct dependents89 and unchanged storage27 pass. Eleven accepted/seventeen rejected cases,90 calls/34 recoveries per route and three mutants establish bounded Perl context-name composition.

September27 `.1.1.3.1.2.3`: reconcile all six native/carrier records,37 source hashes and48 retained logs; correct current summary drift, preserve historical limits and require exact staged canonical receipt for nesting parent closure.

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

- `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.1 - design language closure matrix` — source-located design and current status reconciliation; no normative/runtime/admission movement.

- `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.5 - guard entry and cursor capability description` — canonical inventory-parent closeout; preserved runtime semantics and existing repair obligations.

- `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.4 - classify finite language readiness gaps` — Current classification and next actions preserve existing contracts, repair priorities, parked named arguments and unassessed scope.

- `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.4 - reconcile three bounded language objectives` — canonical representative-parent closeout; no new runtime/format admission.

- `.1.1.3.3.5`: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5 - reconcile bounded lossless child readiness`.

- `.1.1.3.3.4.4`: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.4 - verify dual-ABI Lua lossless child carriers`.

- `.1.1.3.3.4.3`: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.3 - verify Julia lossless child carriers`.

- `.1.1.3.3.4.2`: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.2 - verify Dart lossless child carriers`.

- `.1.1.3.3.4.1`: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.1 - verify Rust lossless child carriers`.

- `.1.1.3.3.3`: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.3 - verify actual Perl child composition`.

- `.1.1.3.3.2`: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.2 - verify lossless Perl segmentation`.

- `.1.1.3.3.1`: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.1 - scope lossless child readiness proof`.

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.0` | `SPEC-LANGUAGE-SELF-CONTAINMENT.0 - ratify expressive spec self-containment` | Direction capture only; no parser/runtime behavior. |

## Changelog

- `2026-10-01`: `.1.2.1` designs the16-authority closure matrix, distinct scope/effect/publication and caller boundaries, four bounded follow-on stages and retained partial/unassessed obligations. Correct stale Knowledge progress/admission pointers; next .1.2.2 is canonical normative structure.

- `2026-10-01`: `.1.1.5` repairs stale capability prose/guard and two missing cursor inventory registrations introduced by current documentation/checker work. Canonical acceptance closes finite inventory .1.1; split .1.2 into four bounded contract-design/freeze/closeout leaves.

- `2026-10-01`: `.1.1.4` classifies the finite evidence and schedules closure/objective/audit next uses. `.1.1.5` is the final inventory child and remains canonical; all external repair owners stay open.

- `2026-10-01`: Reconcile three bounded objectives and authoring costs; exact historical evidence audit and canonical acceptance precede finite gap selection `.1.1.4`.

- `2026-09-28`: Reconcile bounded lossless/actual-child proof under exact canonical acceptance; three-objective .1.1.3.4 follows.

- `2026-09-28`: Complete five shared Lua lossless/actual-child routes per ABI; canonical .3.5 reconciliation follows.

- `2026-09-28`: Complete five Julia lossless/actual-child routes and actual-result isolation; shared Lua .3.4.4 follows.

- `2026-09-28`: Complete six matched Dart lossless/actual-child carriers with strict package-context analysis; Julia .3.4.3 follows.

- `2026-09-27`: Split .3.4 into Rust/Dart/Julia/shared Lua leaves and complete six matched Rust lossless/actual-child carriers; Dart .3.4.2 follows.

- `2026-09-27`: Complete actual Perl child composition under .3.3; backend-sized equivalent proof .3.4 follows.

- `2026-09-27`: Complete Perl lossless segmentation and published default-loop correction under .3.2; child composition .3.3 follows.

- `2026-09-27`: Split lossless child objective into authority, segmentation, Perl composition, backend proof and canonical reconciliation; completed authority leaf .3.1.

- `2026-09-27`: Perl carrier mutation proof exposes and repairs emitted public-entry drift in .1.1.3.1.2.2.1.1. All original grammar/oracles remain exact; next is Rust carrier proof.

- `2026-09-27`: `.1.1.6` fixes generic flat immediately as requested, including baseline-confirmed private capture compatibility. Remaining nesting route proof resumes from its clean commit.

- `2026-09-27`: `.1.1.3.1.1` repairs constructor value lowering exposed by the first grammar objective; `.1.1.6` owns separate generic flat composition. Remaining nesting routes and mutations follow from clean commit.

- `2026-09-27`: `.1.1.2` completes the state/callable/control/transformation/result evidence inventory. Known defects and intentionally absent features remain distinct; bounded grammar objectives `.1.1.3` follow.

- `2026-09-27`: Clean feature return activates `.1.1`, splits five bounded children and completes the first grammar/cursor/capture inventory. The campaign remains gated on language readiness and parity; `.1.1.5` owns confirmed stale general capability prose.

- `2026-07-30`: Created the task tree first from clean Rust closeout commit `4aebf906`; no other file changed
  before ownership existed.
- `2026-07-30`: ADR `0064`, the detailed program, Knowledge Map, roadmaps/live architecture, and mdBook align; full
  signoff passes without behavior change. `.0` is done and `.1+` remains unscheduled behind callable parity.
