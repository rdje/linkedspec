# SPEC-LANGUAGE-SELF-CONTAINMENT: Expressive `.spec` Closure and EBNF-Like Authoring Profile

## Metadata

- Tree ID: `SPEC-LANGUAGE-SELF-CONTAINMENT`
- Status: `active` / closure definition
- Roadmap lane: `.spec language evolution / expressive self-containment and alternate authoring profiles`
- Created: `2026-07-30`
- Last updated: `2026-10-03`
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
  Status: `done`
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
  Status: `done`
  Goal: Freeze the grammar/cursor/capture/state/callable/control/transformation/result closure boundary on the existing semantic core.
  Dependencies: `.1.2.1`
  Acceptance: One versioned neutral authority describes included/excluded operations, distinct scopes, recognition versus user-state effects, typed results and host-boundary inputs. Bind existing authority identities/proof owners, preserve compatibility exclusions and partial status, and add mutation-sensitive structural validation. Use canonical tier for contract/checker movement; no runtime semantics or profile-only mechanism.
  Activation: Clean5785e4990bf1b8aa45a105e262475d128dbcecc7 on October1; .1.2.1 committed, post-commit pointer and all nine doctrines pass, brief0 and clean Git state.
  Owned paths / scope: capability_conformance/language_closure_contract.json and tools/check_language_closure_contract.py freeze operation/scope/reference structure. Register the checker once in canonical CI, advance the independently counted Python entrypoint census38-to39, and align the book, Knowledge and live documents. Existing sixteen authority bytes/admission remain unchanged. Determinism/resource/failure policy remains .1.2.3-owned; this is structural governance, not authored-objective execution.
  Verification tier: `canonical`
  Focused checks: Closed schema/relationships, exact source-bound semantic anchors/proof owners, reason-sensitive destructive mutations and unrelated-error control; unchanged original authority/objective audit, direct-dependent contracts, Python storage census, rendered book, histories, Knowledge, memory, doctrines and diff hygiene.
  Canonical trigger: New versioned neutral contract, independent checker and exact-once canonical registration; stage the complete candidate before receipt-bound local CI.
  Direct-dependent finding (owned here): The unchanged historical objective audit rejects tools/run_ci_local.sh after the exact new checker registration. Reproduction: run tests/language-readiness/verify_objectives.py on this candidate; failure is current executable evidence drift: tools/run_ci_local.sh. Impact: legitimate governance additions cannot be distinguished from changed historical runtime inputs. Extend only this source's audit with the exact owner-bound insertion normalization; it must reconstruct the historical hash, report governance evolution separately and reject removed original work, extra edits and unrelated-error substitution. Preserve every checkpoint, runtime input and original falsifier.
  Preparation correction: The first local structural invocation rejected an incorrectly spelled ADR0064 path before mutation proof. Resolve the indexed canonical filename and correct both authority and independent schema; no missing source or semantic ambiguity remains.
  Verification: Structure16/66/7/8 rejects432 reason-sensitive mutations/four controls; producing and supplemental/coordination owners resolve. Signature3/9/7, binding11/7/6/8, codeblock23 mutations, diagnostics8/0/20, cursor79/8/0/60 and independently counted tool-storage39-entrypoint proof pass. Historical objective audit preserves24 checkpoints/257 historical references/149 latest source identities/134 logs and reports only owner-bound CI insertion evolution, with three new governance controls. Original sixteen authority bytes remain unchanged. Rendered book, Knowledge, history/memory/doctrines/diff and exact staged canonical acceptance govern landing; no new runtime objective is admitted.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.2 - freeze language closure structure`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.2` Acceptance Checklist

- [x] **OWNERSHIP / BOUNDARY** — Clean5785e499 activation; existing matrix/Knowledge/authorities determine scope before artifact/checker creation. One versioned operation/scope/reference definition preserves preferred portable versus compatibility/caller boundaries without new runtime/profile semantics.
- [x] **SCOPES / RESULTS / EFFECTS** — Seven authored categories and eight scopes distinguish fresh functions, dynamic blocks, recognition-only restoration, post-expression nested writes, root-kind receiver publication and child authority. Typed match/payload/diagnostic channels stay distinct; private handles grant no authority.
- [x] **REFERENCES / PARTIALS** — Sixteen exact authority identities and66 selected semantic digests bind reviewed anchors, producing owners and dated ledgers. Preserve historical mutation rollout strings, actual admission owners, repair prerequisites, source-detail coordination and unassessed objective/format/frontend limits.
- [x] **INDEPENDENT GOVERNANCE** — Closed schema and exact relationships reject432 reason-sensitive mutations/four controls, including unrelated-error substitution and selected-source drift. Canonical CI registers one invocation and both tracked inputs; independently counted Python entrypoints become39 without a new allocator.
- [x] **EVIDENCE EVOLUTION / LOCKSTEP** — Historical audit reconstructs original CI bytes through exact owner-bound insertions and rejects three governance falsifiers; every original checkpoint/runtime/log/corpus check remains. Focused contracts/storage and book proof pass. Knowledge, roadmaps/frontier, bounded histories/live/resume and receipt-bound canonical acceptance govern atomic landing. Resource/failure freeze is next.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.3`
  Status: `done`
  Goal: Freeze explicit determinism, progress/resource, failure and ambient non-authority policies without inventing guarantees.
  Dependencies: `.1.2.2`
  Acceptance: State observed versus target limits, regex-substrate responsibilities, typed failure/publication effects and caller authorization. Existing resource repairs retain owners and precede dependent guarantees; invalid/adversarial cases and unassessed performance have explicit proof needs. Do not assign unsupported global limits or equate design exclusions with a security sandbox. Use canonical tier for normative movement.
  Activation: Clean e4f9dcb8d6ee825119863d076d5a32be42ab9ef6 on October2; .1.2.2 committed with exact canonical receipt, all nine hooks and post-commit pointer pass, brief0 and clean Git state.
  Owned scope: Extend the existing language_closure_contract.json and independent checker with explicit deterministic inputs/order, scoped progress/resources, failure publication and ambient non-authority. Review public LinkedSpec probes and dated canonical facts before interpretation; preserve sixteen original authorities and their runtime admission. Align the runtime appendix, structured-format chapter, Toolbox, Knowledge, matrix/finite ledger, roadmap/task/frontier and bounded continuity. No new backend semantics, limits, performance guarantee or sandbox claim.
  Policy-reference plan: docs/language-readiness/closure-policy-boundaries.md will be the readable dated boundary review, with a Knowledge fact card pointing to it. Expand selected semantic anchors for inherited cancellation/cycle/budget/failure/loading policies while preserving all original66 digests and source bytes. Policy proof obligations are structural review requirements, not executed runtime cases or a new public admission.
  Verification tier: `canonical`
  Focused checks: Reason-sensitive policy mutations and adversarial proof obligations; current public ordinary-progress probe, inherited source policies and unchanged original objective/authority evidence; directly affected guards, rendered book, Knowledge, histories, memory, doctrines and diff hygiene.
  Canonical trigger: Normative determinism/resource/failure/ambient policy movement and checker expansion; stage the complete candidate before exact receipt-bound local CI.
  Finding (owned here): ROADMAP.md's expressive self-containment row still schedules .1.2.2 despite its current-status paragraph and committed artifact describing that freeze as complete. Reproduce by comparing the row with .1.2.2's committed task and authority. Impact: roadmap readers can select a completed slice. Repair the row and verify every current self-containment roadmap/frontier statement against the new next action.
  Public-prose finding (bounded repair here; broader coordination remains startup41.2): Runtime appendix9 claims a configurable100–1000 threshold across all repetition;10 says all errors produce structured payloads. Those generalizations exceed the scoped authorities and public channels. October2 LinkedSpec::Get scalar-reference probe of Top:: I { return(call(Top)) } returns null, emits rule_handler_forward_progress:Top and leaves last_error null, reproducing the dated ordinary cutoff. Recognition/observation progress, sink failures and typed native/compatibility adapters have different owners. Correct this chapter's statements from the verified source distinctions; do not close the broader41.2 review or create unsupported thresholds.
  Ordering review (existing ownership retained): Knowledge lookup for sorted_values establishes sorted-key correspondence, rather than an independent value sort. The dated Dart supplementary-character mismatch is already owned by DART-STARTUP-READING.2.13.1-.3 with .3/.4/.5 prerequisites. Correct appendix11's ambiguous alphabetic claim and include these owners in the policy/finite ledger; do not infer callback-order failures, reclassify serializer proof or waive runtime repair.
  Metadata repair (owned here): A validator-only status-removal control accepted a missing original definition_owner while checking the new policy_owner and referenced authorities. Impact: the structural producing-owner claim was incomplete. Require both stage owners to resolve and retain exact-path destructive controls for each; no runtime semantics or admission changes.
  Verification: PASS16 original authority bytes/66 prior bindings preserved;24 inherited-policy additions yield90 anchors and632 reason-sensitive mutations/four controls. Public ordinary cutoff returns null/null last_error with separate trace; two sorted-view examples preserve key/value correspondence. Direct typed231, recognition58, progressive116/public60, staged123/public129, write105, leaf167/composition592 and diagnostic20 guards pass. Historical objective audit retains24 checkpoints/257 refs/149 latest identities/134 logs and only prior .1.2.2 CI evolution. Tool storage39,15 rendered claims on two pages, Knowledge/history/memory/diff and exact staged canonical acceptance govern landing. No new runtime objective, universal resource limit, timing/security guarantee or repair closure.
  Preparation correction: The first owner-removal mutation expected the resource-list path for shared37.2, but its earlier dedicated detail-owner obligation correctly rejected first. Make that exact earlier route the explicit test target; unrelated-error substitution remains rejected.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.3 - freeze scoped closure policies`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.3` Acceptance Checklist

- [x] **OWNERSHIP / TOOLS FIRST** — Clean e4f9dcb8 activation and scoped roadmap/book/Knowledge/source review precede edits. LinkedSpec::Get confirms ordinary recursion and sorted-view examples; preserve dates, exact observed channels and other backend limits.
- [x] **DETERMINISM / PROGRESS** — Explicit program/source/state/authority and operational inputs, governed order and active-scope progress stay distinct. One-shot zero-width, ordinary cutoff and child-versus-parent progress do not imply unrestricted termination or universal diagnostics.
- [x] **RESOURCES / AUTHORITY** — Preserve inherited intersections/minima, cancellation/deadline/shared accounting and source-detail promise. Computed metadata differs from actual enforcement. Existing resource/detail/lexical owners and prerequisites remain; select no new global number, regex preemption, timing/performance or sandbox guarantee.
- [x] **FAILURE / PUBLICATION** — Recognition, expression effects, receiver publication, post-commit continuation, progressive fail-only, staged policies and sink/exit/public adapter channels remain separate. Correct bounded public overclaims without closing startup41.2 or unrelated repairs.
- [x] **INDEPENDENT GOVERNANCE / LOCKSTEP** — Preserve16 original sources/66 digests, bind24 more anchors and reject632 reason-sensitive mutations/four controls including both missing stage owners. Original audit/guards, storage and rendered book pass; align roadmap/frontier, Knowledge and bounded live/resume/history. Exact staged canonical acceptance governs atomic landing; .1.2.4 is next.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.4`
  Status: `done`
  Goal: Reconcile and close the closure-definition parent before neutral composed objectives.
  Dependencies: `.1.2.3`
  Acceptance: Independently check matrix/authority/validator and book alignment, preserved original contracts, exact partial/unassessed routing and no runtime/admission overclaim. Exact staged canonical acceptance closes .1.2; .1.3 must be split before fixture/checker implementation.
  Activation: Clean4b16791ad67aee14b7ae53ef426957a9c074beac on October2; scoped policy committed, all nine hooks/post-pointer and promoted canonical receipt pass, brief0 and Git clean.
  Owned scope / plan: Independently reconcile matrix rows, definition/source anchors, static validator registers, exact producing/repair ownership and rendered public claims. Add an on-demand evidence audit under tests/language-readiness/verify_closure_definition.py and a revision-bound definition-reconciliation checkpoint under docs/checkpoints/; choose exact report schema before creation. Freeze reconciliation metadata in the existing authority/checker and align book, Knowledge, roadmaps/frontier, bounded continuity and a pending .1.3 decomposition before implementation. Preserve all sixteen authority bytes, original66 bindings and90-anchor policy meanings; no new runtime/objective/admission or resource/security guarantee.
  Verification tier: `canonical`
  Focused checks: Independent source/register/matrix/reference/owner and rendered-book reconciliation with reason-sensitive destructive controls; original objective audit and unchanged core authorities; direct closure guard, storage census as affected, Knowledge/history/memory/doctrines and diff hygiene.
  Canonical trigger: Closure-definition parent closeout and normative reconciliation metadata; stage the complete candidate before exact receipt-bound local CI.
  Checkpoint plan: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.4-verification.json uses format1 with activation/structure/policy baseline commits, unchanged source hashes, original/additional anchor counts, matrix/register dimensions, preserved external task-file hashes, owner/reference counts, book source/render hashes and reason-sensitive control results. It is dated focused evidence, not a current runtime execution receipt; canonical acceptance is recorded in the commit body. The audit permits only exact reconciliation_owner and stage metadata evolution from the committed policy baseline.
  Current-summary defect (owned here): finite-gap-list.md repeats the same .1.2.4 next action and retains an obsolete Next before completed .1.2.2. Reproduce by reading its final selection paragraph. Consolidate it to the completed definition and precise pending .1.3.1 selection; no new feature or repair closure.
  Closeout: Parent .1.2 closes only through exact staged canonical acceptance. Independent reconciliation allows exactly one new producing-owner field and the pending-to-complete stage value; all policy meanings and runtime admission remain byte/semantic-exact. Decompose .1.3 selection, neutral fixture/checker, five backend lanes (six runtime routes) and parent reconciliation before implementation.
  Verification: Independent audit PASS16 authority bytes/66 original plus24 added anchors,7 operations/8 scopes,112 external task files,44 resolved owners/8 references and19 rendered claims across two pages. Eight targeted corruptions and unrelated-error substitution reject for exact reasons. Production guard636 mutations/four controls passes; original objective evidence,39-entrypoint storage and bounded book/Knowledge/history/memory/doctrine checks govern landing. Canonical acceptance/result is retained in the commit body; no fresh runtime objective, policy meaning or repair status change.
  Evidence: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.4-verification.json; tests/language-readiness/verify_closure_definition.py; docs/knowledge/language-closure-definition-reconciliation.md.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.4 - reconcile language closure definition`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.4` Acceptance Checklist

- [x] **OWNERSHIP / BASELINES** — Clean4b16791 activation precedes every change. Original structure and policy commits pin16 source bytes,66 original bindings and24 additions; exact metadata normalization preserves all normative meanings.
- [x] **INDEPENDENT RECONCILIATION** — Human matrix rows, literal static registers and normalized policy-schema syntax reconcile without importing/evaluating the production validator. Canonical digests, source identities and all declared owners/references agree.
- [x] **PARTIAL / UNASSESSED ROUTING** — Preserve112 external task-file identities, including repair statuses/prerequisites. Source-detail interpretation, resource/lexical/mutation/recognition defects and parked named arguments retain their owners. Listing mechanisms does not promote objectives or waive repairs.
- [x] **PUBLIC PROOF / CONTROLS** — Nineteen rendered claims across two pages preserve scoped progress/failure/authority limits. Eight targeted corruptions require exact rejection; unrelated-error substitution cannot count. The checkpoint is dated structural evidence, not fresh grammar execution.
- [x] **NO REGRESSION / CLOSEOUT** — Guard636/four controls, original objective audit and direct storage/book checks pass. Exact staged canonical acceptance is mandatory for parent .1.2 closure; runtime admission/whole-format/frontend/resource/security claims stay unchanged.
- [x] **LOCKSTEP / NEXT OWNERS** — Book, Knowledge, roadmap/frontier, finite ledger and bounded live/resume/history agree. Split .1.3 into eight pending leaves before implementation; .1.3.1 selects independent bounded objectives/oracles/prerequisites next.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3`
  Status: `active`
  Goal: Build neutral fixtures and a mutation-sensitive checker for representative self-contained objectives.
  Acceptance: Fixtures cover natural recursion, cursor algebra, interval/boundary capture, nested state, callable
    composition, branching/iteration, structural transformation, and typed result construction; mutations prove
    every claimed semantic dimension matters.
  Dependencies: `.1.2`
  Children: `.1.3.1`, `.1.3.2`, `.1.3.3`, `.1.3.4`, `.1.3.5`, `.1.3.6`, `.1.3.7`, `.1.3.8`
  Inventory input: Preserve the original three probes; select bounded diagnostic and callable/control/transform objectives with independent negative/effect/kind oracles. Record indentation/quotes/comments requirement scope before proposing syntax, and require affected repair owners before dependent promotion. Split selection, neutral fixture/checker and recurrence work before implementation.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.1`
  Status: `done`
  Goal: Select bounded composed objectives and freeze their requirements, independent oracles, supported public producers and affected repair prerequisites before fixture implementation.
  Dependencies: `.1.2`
  Acceptance: Reuse the original nesting/context/lossless evidence without changing its corpora. Select diagnostic and callable/control/transform cases by exact value-kind, order, effect, failure/publication and negative expectations; map all eight parent dimensions to existing or new evidence. Record indentation/quotes/comments requirements and unassessed limits without adding syntax. If a selected claim crosses a known repair, schedule its existing prerequisites before that promotion; successful workarounds cannot close defects.
  Activation: Clean2a8c368159a6c9b927bc6cd7fc524fe0de7319a6 on October2; closure parent committed with canonical receipt, all nine hooks/post-pointer PASS, brief0 and Git clean.
  Owned scope / plan: docs/language-readiness/composed-objective-selection.md will define bounded requirements/case/oracle/mutation selection, exact source contracts/public producers and prerequisite routing before .1.3.2 fixture/checker creation. Review dated Knowledge/inventories and public book/contracts first; use ignored public Perl pilots only to assess authoring feasibility, without new backend/whole-format promotion. Align book, Knowledge, roadmap/frontier and bounded continuity; preserve original corpora and every repair owner. No runtime/authority/CI change belongs to this selection leaf.
  Verification tier: `focused`
  Focused checks: Exact selection-to-parent-dimension/authority/repair-owner review and explicit independent positive/negative/effect/kind/failure oracles; original objective audit, selected existing neutral guards, public feasibility probes if needed, rendered book, Knowledge/history/memory/doctrines and diff hygiene.
  Canonical trigger: none for bounded requirement/oracle selection with unchanged semantics, fixtures, admission and CI; .1.3.2 owns subsequent normative neutral fixture/checker movement and .1.3.8 owns composed parent closeout.
  Feasibility finding (owned investigation here): Public LinkedSpec::Get pipeline pilot compiles a bound {|text| push(seen,text); return(decorate(text,prefix)) } callback inside map_leaves!, then fails with CodeblockRuntime::Error code unknown_helper/name push. Exact source/log live under .linkedspec-data/scratch/selfcontain131/pipeline.spec and pipeline-pilot.log. The pilot's JSON reporter also cannot serialize the blessed last_error; repair only its ignored projection before diagnosis. Check canonical helper/context authority, descriptor/lowering and existing owners before classifying a supported-operation defect or intended boundary. Preserve this case and schedule any required repair before dependent promotion; no runtime fix is authorized by this selection-only leaf.
  Diagnosis / scheduling: Five minimal public Get/descriptor controls establish direct push->[x], direct registered decorate(x,!)->!x and ordinary callback cat/assignment->[!x,before:x], versus callback push and callback registered-function unknown_helper failures. Every source has language_agnostic_action_ir_ready=1 and raw/fallback/unresolved counts0; that compiler readiness does not prove callable-body execution coverage. CodeblockRuntime::_eval_call lines116–191 dispatches a small literal helper list then bound-codeblock lookup, with no push or registered-function path. Existing startup87.2/.3 own related matches/numeric cases in this same dispatcher; keep those owners and independent acceptance. New .1.3.3.0 owns these exact selected push/function repairs before Perl execution, with native/emitted, scope/identity/arity/once-only and no-fallback controls. No missing parsing primitive is inferred.
  Evidence plan: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.1-selection.json uses format1/activation/review-date, retained original-objective identities, selected diagnostic/pipeline requirements, independent expected-oracle descriptions, public pilot source/log hashes and normalized actual records, source-located repair ownership and claim limits. New fixture/checker paths are selected by .1.3.2 before creation. The initial pipeline capture prototype remains pipeline-initial.spec; current pipeline.spec uses outgoing match_text and explicit prefix/end/fallback guards. Descriptor flags are syntax/lowering evidence, never substituted for execution.
  Completion: Sixteen cases (diagnostic9/normalization7), eight parent dimensions, independent value/kind/event/failure/alias oracles and sixteen mutation roles are selected. docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.1-selection.json embeds exact pilot sources and normalized observations/hashes;23 original source identities remain exact. Seven isolated controls distinguish five successes from two callback dispatch gaps; six D pilots pass, while pipeline execution remains blocked by P1 .1.3.3.0. No runtime, authority, fixture, CI or admission change.
  Verification: Focused original-objective audit, closure636/four controls, callable23, diagnostic20, nested-write105 and leaf167/composition592 guards PASS; source/rendered book, selection/source/owner/provenance checks, Knowledge/history/memory/doctrines and diff hygiene govern commit.
  Continuity: Next .1.3.2 selects exact fixture/checker paths before creation; runtime lanes follow required repair. Commit follows COMMIT.md with brief cleared and clean tree before activation.

  Gate correction: First doctrine run rejected17 recent LIVE rows. ADR0066 requires an overwrite-oriented maximum16-row current view; trimmed the oldest redundant row, preserving its committed task/checkpoint/change/Git evidence and immutable migration history. No history schema/archive/pressure exception introduced. Corrected document-history and all nine doctrines PASS before landing.


- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.2`
  Status: `done`
  Goal: Implement selected neutral fixtures, independent expected observations and a reason-sensitive mutation checker from .1.3.1's approved bounded selection.
  Dependencies: `.1.3.1`
  Acceptance: Version input/oracle identities, prove each claimed semantic dimension through positive/negative/effect/kind controls and unrelated-error rejection, and preserve original probes. Select exact owned paths before creation. This leaf establishes neutral governance, not runtime execution or whole-format admission; normative fixture/checker movement requires canonical proof.
  Activation: Clean70e15013cb5278a7a9c785f75290d5f7fc7a575d on October2; selection committed, all nine hooks/post-pointer PASS, brief0 and Git clean.
  Owned paths / plan: capability_conformance/composed_objective_contract.json (linkedspec-composed-objectives-v1); tests/language-readiness/composed/diagnostic.spec, normalization.spec and diagnostic-invalid-arity.spec; tools/check_composed_objective_contract.py. Freeze sixteen selected cases, independently built expectations, source identities, original foundation bindings and sixteen mutation roles. A test-only normalized observation separates native failure evidence from portable value/event/exit/identity/detachment predicates; it is not a new runtime error/API schema. Checker evaluates no DSL.
  Integration scope: Exact recurring checker/input registrations in tools/run_ci_local.sh; owner-bound normalization and falsifiers in tests/language-readiness/verify_objectives.py preserve original historical CI bytes and all runtime/corpus inputs. New tool-entrypoint inventory count/required-route proof in tools/test_tool_project_data_storage.sh; Toolbox and capability-conformance navigation; book/Knowledge/roadmap/frontier/checkpoint/bounded continuity. Select any additional necessary path here before editing it. No runtime/closure authority semantics/admission changes; P1 .1.3.3.0 and every existing repair remain prerequisites.
  Verification tier: `canonical`
  Focused checks: Independent16-case shape/event/value-kind/failure models, exact source/case/owner/foundation register, reason-sensitive structural/observation mutations and unrelated-error rejection; native pilot source identity only, no new execution claim. Original objective audit including narrow new CI controls, selected closure/callable/diagnostic/write/leaf guards, new tool storage inventory/route, rendered book, Knowledge/history/memory/doctrines and diff hygiene.
  Canonical trigger: Normative neutral oracle/checker and recurring CI/tool-storage integration; require exact fully staged candidate canonical receipt before landing.

  Additional selected documentation paths: docs/language-readiness/composed-objective-governance.md, docs/knowledge/composed-objective-neutral-governance.md and docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.2-verification.json. Record private observer semantics and exact neutral falsifiers without runtime execution claims; current selection/gap/direction fact cards and roadmap/frontier/live docs move in lockstep.

  Additional storage-card owner: docs/knowledge/tool-project-data-ssd-storage.md; update its current Python-only census39-to40, preserving historical/routing counts, and correct its repository-relative bytecode path notation.

  Completion candidate: linkedspec-composed-objectives-v1 freezes16 cases/three exact sources/eight dimensions,23 original probe identities and16 semantic mutation requirements. Independent explicit fixture values and ASCII/shape/event checker preserve kinds/order/effects/quiet/exit/caller failure/arity and actual-object detachment obligations. The private report retains native failure/phase without creating a global runtime API/schema. No DSL execution/admission, original authority or runtime source change.
  Focused result: Checker rejects140 structural,16 observation and44 private-producer falsifiers plus two unrelated-error/two JSON controls. Explicitly synthetic private CLI report passes shape validation only. Original audit preserves24 checkpoints/257 historical refs/149 latest inputs/134 logs and rejects6 CI evolution corruptions; two new anchored insertions then two earlier ones reconstruct historical bytes exactly. Managed storage40 passes with new checker under hostile external roots; closure636, callable23 and diagnostic20 guards pass. Source/authority/selection identity, rendered book, Knowledge/history/memory/diff proof and exact staged canonical acceptance govern landing.
  Canonical plan: Fully stage completed sources, normative artifact/checker, narrow CI/storage/history-audit integration, book/Knowledge/continuity and verification checkpoint; run tools/run_ci_local.sh via approved host execution. No tracked edits during/after a successful gate before commit; canonical result/receipt/log digest belong in the producing commit body. Parent .1.3 and all execution lanes remain pending.
  Continuity: Next P1 .1.3.3.0 fixes public callback push/registered-function routes before .1.3.3.1 execution. Existing startup87.2/.3 and every other repair/prerequisite remain exact. Commit per COMMIT.md; clear brief0 and verify Git clean before activation.

## Acceptance checklist — SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.2

- [x] **REQUIREMENTS / SOURCE IDENTITY** — Sixteen selected cases/eight dimensions and three exact sources bind the committed selection;23 original source identities and16 original authorities/90 anchors stay exact. Indentation/quotes/comments/whole formats and broader limits remain unassessed.
- [x] **INDEPENDENT ORACLES / KINDS** — Explicit fixture expectations match a separate ASCII/shape/event model without importing/evaluating DSL implementation; typed false, arrays/harrays/null, quiet effects and separate failure/publication channels remain distinct.
- [x] **FALSIFIER REASONS / PROOF LIMITS** — 140 structural/16 observation/44 private-report falsifiers plus two unrelated-error/two JSON controls pass. Synthetic reports and altered projections prove neutral boundaries, not semantic execution; native classification/identity/actual-object detachment and healthy-baseline semantic variants remain producer-owned.
- [x] **RECURRING TOPOLOGY / STORAGE** — One CI checker/five tracked inputs; exact owner-bound CI normalization plus6 controls preserves historical bytes. New checker runs through managed Python storage;40 tools, three Python temporary owners and15 shell allocator owners remain governed.
- [x] **LOCKSTEP / SIGNOFF BOUNDARY** — Book, Knowledge, Toolbox, authority navigation, roadmap/frontier, checkpoint and bounded continuity agree. Focused proof precedes exact staged canonical admission; its receipt/result lives in the producing commit body. Next P1 repair precedes any dependent execution promotion.

  Documentation correction owned here: ROADMAP_V2.md still names .1.3.1 because the prior selection sync omitted the second roadmap. Reproduce by comparing its feature header/self-containment row to ROADMAP.md and docs/TASK_TREE.md. Align the header/row now and include three-header equality/current-frontier proof in this checkpoint; no roadmap direction changes.


- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3`
  Status: `pending`
  Goal: Execute the selected compositions through Perl's public native and independently loaded emitted producers.
  Dependencies: `.1.3.2`
  Children: `.1.3.3.0`, `.1.3.3.1`
  Acceptance: Independent observations match every selected oracle on both producers, including ordered diagnostics and failure/effect/value-kind controls. Bind exact sources/logs and repair prerequisites; minimize any failure through Toolbox public probes and route the repair before dependent promotion.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0`
  Status: `active`
  Priority: P1 — blocks the selected callable/control/transform objective on Perl.
  Goal: Repair selected admitted push and registered-user-function composition inside Perl deferred codeblocks before executing the objective.
  Dependencies: `.1.3.2`; exact .1.3.1 public controls and callable/binding/function/mutation authorities. Coordinate shared dispatcher work with existing SESSION-STARTUP-READING.87.2/.87.3 without replacing their separate cases or prerequisites.
  Reproduce: .linkedspec-data/scratch/selfcontain131/callable-controls.pl; direct push and registered-function controls succeed, but callback_push and callback_function return null with CodeblockRuntime::Error unknown_helper/name push or decorate. The real pipeline fails at push before its later calls. All descriptors report ready1/raw0/fallback0/unresolved0.
  Root cause: perl/LinkedSpec/CodeblockRuntime.pm _eval_call handles a narrow helper list and otherwise tries a bound-codeblock slot; the selected mutation and static registered-function routes are absent. Compiler recognition is not runtime composition proof.
  Acceptance: Preserve actual caller binding identity for push, eager once-only arguments, copied/restored temporary parameters, live caller nonparameters, registered-function fresh-local semantics, helper/function/bound-codeblock precedence, active recursion diagnostics and receiver guards. Prove direct/callback native and independently emitted controls plus selected neutral observations, including genuinely unknown calls and typed errors. No host fallback, captured lexical environment or new primitive/syntax; broaden tier before any contract/interface movement.
  Children: `.1.3.3.0.1`, `.1.3.3.0.2`, `.1.3.3.0.4`, `.1.3.3.0.5`, `.1.3.3.0.6`, `.1.3.3.0.7`, `.1.3.3.0.3`
  Current prerequisites: Original push/function routes, literal segmentation and explicit normalization/artifact recovery are complete. Deferred conditional .0.5 (existing startup87.2 first, then attached/marker/value slices), residual event-order/readiness .0.6 and nested raw-expression readiness .0.7 remain before dispatcher closure. Preserve original reproduced failures as historical evidence rather than calling them current.
  Scope boundary: Existing startup19 assignment guards, startup32 caller-local function shadowing, startup35 boolean literals and startup87.2/.3 matches/numeric helper dispatch retain separate ownership and acceptance. Partial dispatch repairs do not close them or admit the full neutral pipeline. The plain eight-field codeblock record and all normative authorities stay unchanged.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.1`
  Status: `done`
  Priority: P1 — first bounded dispatcher repair.
  Goal: Execute existing bare-binding push inside deferred codeblocks with copy-on-write publication, real receiver identity and separate temporary parameter slots.
  Dependencies: `.1.3.2`; existing uniform-binding, callable and map-leaves authorities; original public .1.3.1 failure controls.
  Owned paths: perl/LinkedSpec/CodeblockRuntime.pm; perl/LinkedSpec/ActionIR/MethodLowering.pm; new t/codeblock_push_composition_perl.t; docs/knowledge/perl-codeblock-push-composition.md; docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.1-verification.json; this tree; existing composition-gap Knowledge card; docs/linkedspec-book/src/architecture/structured-format-program.md; bounded continuity/roadmap/frontier/Knowledge index. Select additional affected paths before editing them.
  Selected integration paths: tools/run_ci_local.sh requires and runs the new regression exactly once; tests/language-readiness/verify_objectives.py records the exact owner-bound CI evolution and three new destructive controls. docs/language-readiness/composed-objective-governance.md and its current Knowledge card receive only the resulting CI-audit/current-frontier updates; immutable .1.3.1/.1.3.2 evidence remains untouched.
  Storage correction paths: tools/test_perl_project_data_storage.sh registers the new twenty-eighth allocator with exact membership; docs/knowledge/perl-project-data-ssd-storage.md and TOOLBOX.md synchronize the current census and fix the card's leading-slash project-cache reference. The original audit pins this storage script, so tests/language-readiness/verify_objectives.py must normalize only its four exact owned inventory replacements, recover all historical bytes and reject six storage drifts separately from nine CI drifts.
  Design boundary: Supply caller rule dispatch explicitly at generated invocation sites, outside the plain codeblock record. Preserve static-rule precedence for ambiguous two-identifier push. Forward the same invocation context through nested codeblocks. Parameter bindings use invocation-local scalar identities and restore caller reference mappings on success/failure; nonparameter references remain actual caller slots. Reuse BindingRuntime push_value and assert_receiver_writable rather than duplicate mutation semantics. Registered pure functions remain the next child.
  Acceptance: Native and fresh independently loaded emitted carriers cover selected push success, absent/null targets, once-only argument effects, post-argument target snapshots, detached prior results, wrong-kind/unknown calls, rule precedence, nested parameter restoration and alias-sensitive active receiver rejection. A same-named temporary parameter must remain writable without touching the active caller receiver. Retain raw0/fallback0/unresolved0 where supported; preserve existing callable/binding/mutation suites and exact original authorities. The full normalization source must remain honestly blocked at its next unrepaired dispatch.
  Verification tier: `canonical`
  Focused checks: New native/emitted push matrix; existing callable-codeblock, uniform-binding and map-leaves Perl contracts; neutral composed/closure/callable/binding/mutation checkers; historical objective audit; mdBook/rendered claims, Knowledge Map, history pressure, memory and diff hygiene.
  Canonical trigger: Private runtime invocation-context and public generated-handler emission movement; stage the complete candidate before exact receipt-bound local CI.
  Harness repair: First fresh emitted run failed while serializing nested typed errors because the new observer incorrectly expected a blessed generated wrapper. GeneratedSource::new_error returns a plain generated_source_error harray with typed detail. Repair the observer to retain outer source/stage/code and unwrap only that declared carrier; preserve original typed details and actual native identity controls. This was a test-observer defect, not a DSL execution failure.
  Book observer repair: A first ad-hoc do-file loader treated the emitted file's false trailing value as a load failure; use the established eval(package/source/1) loader and assert both independently executed values. The corrected native/fresh emitted book example passes; no engine repair was needed.
  Canonical attempt: First exact-candidate CI exited1 at Perl storage: new File::Temp owner t/codeblock_push_composition_perl.t raises census27->28. All preceding checks, including new147 and old callable/binding/mutation suites, passed. Register the exact owner and current census, preserve the original storage-script hash through reason-sensitive owner-bound evolution, run focused storage/audit proof and restart canonical CI on the complete corrected candidate. The same check also exposed stale Toolbox24 and a leading-slash card path; both are owned corrections here. No failed gate counts as canonical proof.

  Completion: Seventeen source cases on native Get and fresh emitted Execute pass147 top-level tests with23 nested actual-reference/exception/receiver assertions. Existing callable/binding/map suites pass30; neutral140/16/44, closure636/four controls, callable23, uniform-binding and map167/composition592 governance pass. Original audit preserves24 checkpoints/257 references/149 inputs/134 logs with nine CI and six storage controls; explicit Perl allocation membership/census28 passes, preserving all historical27-owner bytes through four exact replacements. Original seven controls give six successes and only callback_function failure; exact normalization now fails at unknown_helper/decorate with ready1/raw0/fallback0/unresolved0, no result/events. Frozen authority/fixture/checkpoint review, executed book example on two routes and seven rendered claims pass. Checkpoint stores exact source/log hashes and independent observations; no full neutral execution/admission follows.
  Canonical plan: Fully stage the complete clean candidate and run approved-host tools/run_ci_local.sh; record actual exit, CLI/RAM/Phase0 and candidate/log identities in the commit/receipt, without post-gate tracked edits. Commit per COMMIT.md, clear brief0 and verify clean HEAD before .1.3.3.0.2 activation.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2`
  Status: `done`
  Goal: Bridge registered pure-function calls from deferred bodies through the existing compiler function lowering, with fresh local state and unchanged static precedence.
  Dependencies: `.1.3.3.0.1`; exact function/variadic/contextual-codeblock contracts; startup32 remains a separate known limitation before dependent claims.
  Acceptance: Declare the compiled registry/context interface and exact owned paths before implementation. Reuse central function-body lowering; do not create a partial second function evaluator or store closures/environments in codeblock records. Cover once-only ordered caller arguments, signatures/rest/final-codeblock forms, fresh locals, nested calls, genuine unknown calls, recursion and native/emitted equivalence. Preserve startup19/32/35/87 ownership and report any newly implicated prerequisite.
  Children: `.1.3.3.0.2.0`, `.1.3.3.0.2.1`
  New P1 prerequisite: Public Get controls reveal that an externally supplied callback invoked by a pure function reads unrelated rule-caller slots. The generated invoke includes callback/cb/secret references inherited from the caller inventory. Direct function reads are fresh and a declared function-local secret controls correctly. Repair .0.2.0 before constructing the registered-function bridge; this is distinct from startup32 argument-local shadowing.

  Reconciled by .0.2.1.2: Committed children and exact retained source/capture boundaries, original seven native/fresh controls,750 tracked tests, twelve source/result corruptions, guarded archive audit and neutral governance establish bounded completion. Exact staged canonical receipt is required before landing this parent closeout. Original infix failure and independent .0.5/.0.6/.0.7/startup/full-execution owners remain unchanged.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0`
  Status: `done`
  Priority: P1 — implicit caller capture violates the admitted pure-function scope contract.
  Goal: Give function-invoked codeblocks the function's fresh working frame, excluding unrelated rule-caller references and retaining working slots across callbacks within that invocation.
  Children: `.1.3.3.0.2.0.0`, `.1.3.3.0.2.0.1`, `.1.3.3.0.2.0.2`
  Reproduce: fn apply(callback: codeblock) { return(callback()) }; Top sets secret=outer and passes cb={|| return(secret)}. Current Get returns outer with ready1/raw0/fallback0/unresolved0 and no context error; pure-function scope requires null. A function-local secret=local returns local, and a direct fn inspect(){return(secret)} returns null.
  Root cause: _user_function_deps_with_call shallow-copies caller bare_symbol_names; _codeblock_runtime_binding_expr retains that inventory before adding function-local names. The builder is byte-identical to committed activation c02129217, so this mechanism predates the push repair.
  Impact / scheduling: Caller data can cross the pure-function boundary despite a plain noncapturing codeblock record. Fix now as a prerequisite of .0.2.1; retain startup19/32/35/87 as separate owners. No lexical capture or authority expansion is approved.
  Acceptance: Native/fresh emitted read/write, explicit-local and parameter controls; callback-created slots persist within one fresh function invocation and reset between invocations; nested calls and copied codeblock parameter restoration remain correct; rule-invoked callbacks retain live caller bindings. Minimize all additional failures with Toolbox before expanding the repair.

  Closeout: Diagnosis .0.2.0.0 and focused repair .0.2.0.1 retain exact evidence; .0.2.0.2 independently reconciles committed proof and binds this prerequisite closure to exact staged canonical acceptance. Registered-function bridge .0.2.1 remains pending; startup32/19/35/87 and whole neutral execution are separate.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.0`
  Status: `done`
  Goal: Freeze the newly established pure-function callback capture diagnosis and bounded repair plan without runtime changes.
  Owned paths: This tree; new docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.0-diagnosis.json; new docs/knowledge/perl-function-codeblock-caller-scope-leak.md; docs/linkedspec-book/src/architecture/structured-format-program.md; bounded continuity/roadmap/frontier and derived Knowledge Map. No code, tests, contracts or CI changes.
  Verification tier: `focused`
  Focused checks: Reverify three exact public Get controls and source binding inventory; independent fresh emitted controls; immutable source/authority review; mdBook/rendered claim, Knowledge Map, history pressure, memory and diff hygiene.
  Canonical trigger: none for bounded diagnosis/documentation with unchanged runtime, authorities, admission and CI.
  Acceptance: Exact sources, actual/expected values, compiler metadata, producer/source hashes and generated mechanism survive in the checkpoint. Schedule and own the P1 fix, preserve all distinct defects, commit cleanly and activate .0.2.0.1 next.

  Verification: Three exact public Get/fresh emitted controls agree outer/local/null with no errors and ready1/raw0/fallback0/unresolved0. Both root-cause helpers match pre-push c021 bytes; eleven runtime/fixture/authority/checkpoint inputs remain HEAD-exact. Focused mdBook/rendered claims, Knowledge/history/memory/doctrines/diff proof governs landing. Checkpoint records source/artifact/producer hashes; no runtime change.
  Next: Activate .0.2.0.1 from clean diagnosis HEAD and inspect write/persistence/nested scope controls before selecting the repair.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.1`
  Status: `done`
  Goal: Repair the established function callback scope leak with a fresh invocation-local working frame and native/fresh emitted regression controls.
  Dependencies: `.1.3.3.0.2.0.0`; admitted pure-function, callable, binding and parameter scopes.
  Acceptance: Select exact implementation/test paths and verification tier before edits. Exclude caller slots, preserve actual function-local/parameter identities and callback slot persistence, reset between function invocations, retain rule callbacks and all original seventeen push controls. Reject alias/snapshot shortcuts and accidental closure storage; inspect any newly implicated prerequisite before proceeding.

  Owned paths: perl/LinkedSpec/ActionIR/MethodLowering.pm; append scope controls to existing t/codeblock_push_composition_perl.t (no new allocator/CI registration); new docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.1-verification.json; scope Knowledge card and current book section; task/roadmap/frontier/continuity/derived Knowledge. Keep runtime invoke, eight-field record, public schemas/authorities/fixtures and CI unchanged unless new evidence requires a separate owner.
  Verification tier: `focused`
  Focused checks: Toolbox RED/GREEN native/fresh emitted scope read/write/local/parameter/persistence/reset/nested/with/private-name controls; actual frame/reference identity and original seventeen push cases; callable, variadic function, binding and map-mutation direct dependents; Perl syntax and Phase0 for MethodLowering; rendered book, unchanged-input audit, Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for internal generated handler lexical/binding repair with unchanged format-v2, public contracts, admission, CI, hooks and storage. Escalate before landing if evidence expands those surfaces.
  Design selection: Reuse generated function do-blocks and local declarations. Build one fresh binding map after argument/parameter installation, containing only actual function scalar locals/parameters. Runtime-created slots persist in that map. Body invocation sites reuse it; with temporarily shadows/restores its value entry. Select compiler frame names avoiding function-local/parameter names and replace inherited frame metadata for nested functions. Toolbox must establish any callable-candidate leakage before deciding its repair.
  Additional exact scope reproduction: fn inspect(){return(cb())} with a rule cb={||return("outer-callable")} currently returns outer-callable, ready1/raw0/fallback0/unresolved0. Public dump proves invoke($cb,...{"cb"=>\$cb}) without a function-local declaration. _codeblock_variable_call_candidate also consults inherited caller bare_symbol_kind. Repair callable eligibility using the function's own scalar/parameter inventory; unbound names keep existing unresolved-helper diagnostics. Probe: .linkedspec-data/scratch/selfcontain1330201/callable-preflight.log. This is the same function-scope boundary, distinct from startup32.
  Verification:33 exact native/fresh emitted sources pass279 top-level tests;23 original push,17 native actual-frame and four callable-diagnostic nested assertions, plus fresh-child real frame/working-slot identities and deliberately aliased rejection. Four direct-dependent suites pass96. Phase0 passes1033/1033 in1134 seconds. Original17 case rows and57 authorities/fixtures/checkpoints/runtime/CI/storage stay exact; seven rendered claims and two exact native/emitted book examples agree. Baseline preload gives18 failures/278 before the child identity addition; final baseline rejects actual emitted frame identity (expected incomplete RED exit2), while the final GREEN completes279. Initial include-path-only baseline selected current code and is not RED proof. Scope checkpoint retains actual sources/artifacts/producers/logs and limits.
  Workflow: An early prospective MEMORY check correctly rejected the still-active leaf; mark complete only after required Phase0, then rerun before committing. Knowledge/history/book/syntax/original objective audit/neutral governance/memory/diff and all doctrine hooks govern focused landing. Closeout .0.2.0.2 remains pending canonical; no premature parent closure or broader execution claim.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.2`
  Status: `done`
  Goal: Independently close the callback scope prerequisite on its committed repair with exact canonical acceptance before the function bridge.
  Dependencies: `.1.3.3.0.2.0.0`, `.1.3.3.0.2.0.1`
  Owned paths: This tree; a bounded closeout checkpoint; current Knowledge/book/roadmap/frontier and continuity. Keep repaired code, tests, records, authorities and CI unchanged.
  Verification tier: `canonical`
  Focused checks: Committed diagnosis/repair source/log/hash reconciliation; native/fresh emitted scope and actual-frame controls; original authorities and direct dependents; book/Knowledge/history/memory/doctrines/diff; exact staged canonical receipt.
  Canonical trigger: designated parent closeout of the P1 pure-function scope prerequisite.
  Acceptance: Independently reconcile the repaired boundary and all limitations; run complete CI for the staged candidate, commit per COMMIT, clear brief and verify clean HEAD. Close .0.2.0 only after canonical acceptance; then activate bridge .0.2.1.
  Activation: Clean f07d827f7477e8a8a630ca12003d62761568a9b9, completed279/96/1033 focused repair, brief0 and no tracked/untracked work. Reconcile the committed checkpoint and current source/log hashes rather than re-deriving the diagnosed mechanism. Explicitly own new docs/knowledge/task-verification-single-owner.md plus a bounded clarification in docs/linkedspec-book/src/development/local-ci-and-regression.md for the exact-one changed field owner caught during repair; no checker/policy change.
  Reconciliation: Committed repair checkpoint hashes match f07d827f7; all producer/log identities remain exact.35 paired observations preserve native/emitted values and optional errors,33 regression sources/279 tests,23 push/17 native actual-frame/four diagnostic checks plus emitted actual frame/alias proof,96 dependents and prior Phase0 1033/1134s. Original authorities/runtime/CI/storage and startup32/decorate limitations remain exact. An initial reviewer assumed a success error key; compare omitted optional error as null instead. No runtime/test/authority change.
  Canonical plan: Stage the complete candidate with no unstaged/non-ignored inputs, run approved-host tools/run_ci_local.sh to .linkedspec-data/scratch/selfcontain1330202/canonical.log, and record actual candidate/log identities, exit/CLI/RAM/Phase0 in the commit and promoted receipt without tracked post-gate edits. Canonical acceptance governs proposed parent closure; if the gate fails, retain ownership and repair before landing. Next .0.2.1 activates only from clean committed closeout HEAD.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1`
  Status: `done`
  Goal: Implement the compiler-owned registered-function bridge after the function callback scope prerequisite closes.
  Dependencies: `.1.3.3.0.2.0`
  Acceptance: Reuse central function-body lowering with exact signatures, final-codeblock normalization, argument order, fresh locals, nested calls and recursion diagnostics. Declare any interface movement and broaden proof before edits; preserve the eight-field record and distinct startup32 limitation. Parent .0.2 closes only after full bounded native/emitted acceptance.
  Children: `.1.3.3.0.2.1.0`, `.1.3.3.0.2.1.1`, `.1.3.3.0.2.1.4`, `.1.3.3.0.2.1.3`, `.1.3.3.0.2.1.2`
  Slice boundary: Contract/probe .0 freezes the explicit generated invocation interface before implementation .1 changes it; canonical reconciliation .2 alone closes this bridge and parent .0.2. No partial second function evaluator or closures in codeblock records.

  Reconciled by .0.2.1.2: Committed children and exact retained source/capture boundaries, original seven native/fresh controls,750 tracked tests, twelve source/result corruptions, guarded archive audit and neutral governance establish bounded completion. Exact staged canonical receipt is required before landing this parent closeout. Original infix failure and independent .0.5/.0.6/.0.7/startup/full-execution owners remain unchanged.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.0`
  Status: `done`
  Goal: Establish the compiler-owned bridge interface, exact code/test paths and native/fresh emitted failure controls before changing runtime behavior.
  Activation: Clean 2516cf72798212e1686cbddec94018a317276035; promoted canonical receipt matches HEAD, commit brief is empty and no required job remains.
  Owned paths: This task tree; new docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.0-contract.json; new docs/knowledge/perl-deferred-function-bridge-design.md; existing architecture book structured-format-program.md; task index, roadmaps, bounded continuity and derived Knowledge. Ignored diagnostic producers/output stay under .linkedspec-data/scratch/selfcontain1330210. No production, test, authority, generated-format, CI or storage change.
  Verification tier: `focused`
  Focused checks: Toolbox Get/return_descriptor/parser_source_ref and fresh emitted controls for fixed/rest/final-codeblock calls, ordered arguments, pure scope, nested functions, precedence, arity/keyword/recursion/unknown failures; central lowering/context source review; unchanged authorities/source inputs, rendered book, Knowledge/history/memory/doctrines/diff.
  Canonical trigger: none for bounded interface planning and diagnostics with unchanged runtime. Implementation .1 must activate its own canonical declarations before private context/emission changes.
  Acceptance: Bind exact sources, native/emitted values/errors/metadata and generated mechanism to the clean base; describe a bridge that reuses the central function lowerer and common callable metadata, preserves the eight-field record and distinct startup32 limitation, and schedules all required regression/recursion controls before code edits.

  Verification: All24 public Get/descriptor/dumped-source probes and corrected fresh emitted execution agree on values and typed errors. Fixed/rest/final/direct ordered controls succeed; deferred calls fail by registered name, same-named slot incorrectly returns slot, unknown/keyword/static-recursion/startup32 controls retain exact behavior. Twelve reviewed production/test/authority/checkpoint inputs remain base-exact. Source captures require dump_parser_source; generated Execute uses the existing scalar-reference function API. No runtime/test/authority change. Checkpoint and Knowledge bind the selected table/central-lowering plan; actual recursion and slot guards remain implementation acceptance. The maintained Current Frontier still listed completed .1.2.4 as pending and omitted the current .1.3 chain; this leaf owns its verified status/next-row reconciliation against existing task nodes and committed evidence.

  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.0 - specify deferred function bridge`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — LinkedSpec::Get and fresh emitted Execute agree on24 exact sources; deferred decorate/collect/apply/join/outer calls fail at registered dispatch and same-named decorate invokes the wrong slot.
- [x] **ROOT CAUSE (WHY + WHERE)** — Toolbox parser_source_ref with dump_parser_source shows central generated function do-blocks for direct calls and a plain typed deferred call plus rule-only invocation context. MethodLowering::_codeblock_runtime_invocation_expr and CodeblockRuntime::_eval_call have no registered-function bridge.
- [x] **FIX** — Select a compiler-owned registered_functions invocation table and private evaluated-argument mode through the existing central lowerer. Implementation .1 and canonical reconciliation .2 own the repair; no runtime change in this diagnostic leaf.
- [x] **ADDRESSED (verified)** — The checkpoint binds all24 paired value/error/metadata observations and producer/artifact identities, including direct fixed/rest/final forms, ordered effects, precedence, unknown/type/keyword/static-recursion/startup32 controls. Corrected fresh Execute and source capture are rerun.
- [x] **NO REGRESSION** — Twelve production/test/authority/checkpoint files are activation-base exact; unused unsupported function and startup32 controls retain their current observations. Focused rendered book/Knowledge/history/memory/doctrines/diff checks govern landing; no changed behavior or Phase0 rerun is claimed.
- [x] **LOCKSTEP** — Owned tree/children, resume pointer, roadmap/frontier, current status/history, Knowledge, checkpoint and public book preserve the selected bridge plan and its implementation owner.

At this .0 diagnostic boundary, bridge implementation is pending. No complete neutral execution, other-backend proof or admission follows.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.1`
  Status: `done`
  Goal: Implement and verify the explicit registered-function bridge using the interface selected by .0.
  Dependencies: `.1.3.3.0.2.1.0`
  Activation: Clean 4a3f33a3e38d38b2ac17bf3cfe9a1dd92231096b;24-probe contract committed, nine doctrines/post-pointer pass, brief0 and no required job remains.
  Owned paths: perl/LinkedSpec/ActionIR/MethodLowering.pm; perl/LinkedSpec/CodeblockRuntime.pm; extend existing t/codeblock_push_composition_perl.t without another allocator or CI registration; new docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.1-verification.json and docs/knowledge/perl-deferred-function-bridge.md; current bridge design/gap Knowledge and architecture book; task/roadmap/frontier/continuity and derived Knowledge. CallableContract, public schemas/fixtures, generated-format-v2, CI/storage remain unchanged; declare any additional required owner before edits.
  Verification tier: `canonical`
  Focused checks: Toolbox/native/fresh emitted RED/GREEN registered fixed/rest/final-block/signature/order/precedence/fresh-local/nested/unknown/type/keyword/recursion/private-name cases; actual frame/rest/parameter/exception controls and all original33 sources/279 tests; callable/variadic/binding/map dependents, exact original authority/normalization controls and unchanged governance; syntax/book/Knowledge/history/memory/doctrines/diff.
  Canonical trigger: Explicit invocation context table and generated callable-body emission movement; stage the complete candidate and require exact receipt-bound local CI, including full Phase0, before landing.
  Interface: Use the .0 selected registered_functions table with normalized signatures/common final-block metadata and central compiled handlers or explicit lowering diagnostics. Already-evaluated argument-array mode is private to one function entry and cleared for nested static calls. Active function/codeblock state crosses compiled/interpreted boundaries and unwinds on failure; eight-field plain records carry no closure or environment. Select recursion identity mechanics through actual clone/distinct-callback controls.
  Additional owned path: perl/LinkedSpec/BindingRuntime.pm _clone_value must preserve opaque callable origins when deep-copying a codeblock. Existing generated copy is shallow and retains body_ast identity; BindingRuntime publication deep-copies it. Add actual callback-through-copy/aggregate tests before claiming recursion safety. This is private metadata only, with no record/environment/public schema change; canonical proof and binding/map dependents apply.
  Newly implicated prerequisite: A public Get/dumped-source control with finishBlock={|x,y| return(x)} emits the literal unreconstructed and fails Perl compilation with Transliteration pattern not terminated. Direct AST::parse_action_expr returns a valid two-parameter codeblock_literal, while the left,right twin executes. Preserve the source/dump/error and assign P1 .0.2.1.3 diagnosis/repair before bridge closeout; do not infer the intermediate scanner cause without Toolbox proof.
  Observer correction: Initial implementation replay reused the .0 scratch output root. Preserve its producers/logs and regenerate the dated artifacts with exact preloaded 4a3f33a3e MethodLowering/CodeblockRuntime modules; all24 observation/source/artifact hashes match the committed .0 checkpoint again. Implementation producers now use their own .1 root.

  Planned proof: Native/fresh emitted fixed/rest/contextual/explicit/bound callback forms, argument effects/order, fresh scopes/actual slot identity, nested calls and function/codeblock recursion controls, unknown/arity/keyword/type failures; existing callable/variadic/binding/map/Phase0 and exact staged canonical CI before landing.
  Acceptance: Declare exact implementation paths and canonical fields from clean .0 HEAD. Reuse central function body lowering and common signature/contextual-block metadata. Preserve static callers, all existing push/scope cases, codeblock record bytes, startup32 and separate unrelated prerequisites; split any newly implicated defect before claiming closure.

  Verification:71 exact source rows/605 top-level tests PASS, preserving original33 rows byte-exact; six direct-dependent suites123 PASS. Correct old three-module/PERL5OPT baseline completes605 tests with88 failures.24 native actual bridge assertions plus existing23 push/17 scope/four diagnostic checks retain true references and alias falsifiers; fresh emitted child independently checks rest identity, operand effects/handler entries, actual exception identity and restored context.71 paired values/errors and50 stdout comparisons from rows without runtime errors agree; failure framework stdout is not treated as DSL-event equality. All seven original controls now succeed. Exact original normalization still fails undefined count with unlowered infix condition/increments; P1 .0.4 owns diagnosis/repair. Minimal x,y AST is valid but native/fresh emitted compilation fails; left,right returns ok; P1 .0.2.1.3 owns reconstruction before closeout. Public authorities/CallableContract/EmitContext/CI/storage stay activation-exact. Checkpoint and Knowledge bind source/artifact/log identities, corrected baseline selection and restored dated .0 artifacts.
  Canonical plan: Stage the complete candidate with no unstaged/non-ignored inputs; run approved-host tools/run_ci_local.sh to .linkedspec-data/scratch/selfcontain1330211/canonical.log. Its exact candidate/exit/CLI/RAM/Phase0/log identities belong to the ignored commit brief and promoted receipt, with no tracked post-gate edit. Failure remains this leaf's ownership until repaired. Next durability reconciliation .0.2.1.4 activates only from the committed clean handoff, followed by valid-literal diagnosis .3.0.
  Canonical first attempt: exit1 at TASK-ACCEPTANCE before runtime/Phase0. The unchanged checker scans all historical checked-label lines and rejects the literal pending in the earlier .0 LOCKSTEP qualification. Existing Knowledge task-acceptance-evidence-gate-boundary already documents this boundary. Move only that dated open-scope sentence to its following paragraph, preserving historical meaning/status; stage and directly verify the evidence-shape gate before exact canonical retry. Preserve initial candidate/log identity in this leaf checkpoint; no checker/runtime change.
  Durability correction / additional owned paths: The requested read-only claim-verification source review identifies replay producers recorded only by ignored path/hash. Preserve exact observe/child/original-control/literal/book/baseline-bootstrap sources inside the tracked .1 checkpoint with a safe reconstruction recipe; own a bounded development-book explanation in local-ci-and-regression.md and current bridge Knowledge. The tracked regression already holds all71 source oracles and605 tests. Attempt2 is deliberately terminated143 before completion so this corrected candidate receives a fresh exact canonical receipt; passed intermediate consumers are partial evidence only. Prior checkpoint producer recovery/policy adoption is scheduled under P1 .0.2.1.4 after this leaf lands; no purge may discard their retained sources. No runtime/test/checker/CI/storage change in this evidence correction.
  Canonical attempt3: exit1 at README-STABILITY before runtime/Phase0; the recovery addition makes existing local-ci-and-regression.md 2075 lines against2048. Preserve the exact full recipe in the already-owned bridge architecture chapter (ample existing budget), leaving a short development navigation link. Re-run rendered source/recipe identity and unconditional routing-pressure checks before exact retry; no cap, registry or checker change.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.1 - bridge deferred registered functions`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Committed .0 controls retain missing registered dispatch and wrong slot precedence; corrected preloaded three-module baseline fails88 of605 completed tests.
- [x] **ROOT CAUSE (WHY + WHERE)** — LinkedSpec::Get/return_descriptor/dump_parser_source show the rule-only invocation context and narrow runtime dispatcher lacked compiled registered entries; MethodLowering owns central signatures/body/frame semantics.
- [x] **FIX** — Emit private signature/contract/compiled-body table using central runtime argument mode; dispatch once in order, validate before operands, localize mixed recursion and preserve opaque origins across callback copies/publication.
- [x] **ADDRESSED (verified)** —71 native/fresh sources,24 actual native bridge checks, independent emitted identity/effect/error/state observations, genuine unknown/type/keyword/recursion controls and deliberate aliases bind bounded behavior.
- [x] **NO REGRESSION** — Original33 rows remain byte-exact;123 direct dependents and seven original controls pass; startup32 and unchanged authorities remain exact. Exact staged canonical CI supplies full Phase0 and broader acceptance before landing.
- [x] **LOCKSTEP** — Checkpoint, Knowledge, book, roadmap/frontier and bounded continuity agree on bounded bridge completion and separate P1 literal/loop prerequisites. No complete neutral execution, semantic-mutant or other-backend admission claim follows.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.2`
  Status: `done`
  Goal: Independently reconcile the committed bridge and original controls, then close .0.2.1 and .0.2 under canonical proof.
  Dependencies: `.1.3.3.0.2.1.1`, committed `.1.3.3.0.2.1.4.0`/`.1.3.3.0.2.1.4.1`, `.1.3.3.0.2.1.3`, `.1.3.3.0.4`; normalization must satisfy the existing oracle and artifact recovery .0.4.2 must close before this canonical reconciliation. This leaf also reconciles parent .4, so parent status is not its own prerequisite.
  Planned proof: Exact committed source/checkpoint/log reconciliation, original seven controls and authorized normalization-calls successor on both public producers, unchanged authorities and remaining repair owners, rendered book and exact staged canonical CI. Preserve original normalization.spec and its historical infix failure; do not require that unsupported source to become healthy.
  Acceptance: Close only after native/fresh emitted results and ordered effects agree with the existing oracles and the actual recursion/slot guards are exercised. Full neutral sixteen-case execution stays owned by .1.3.3.1.

  Activation: Clean0075a5b163cd9690d4ad70b1c8ea1da796088ab5; artifact recovery canonical/ten commit hooks/post-pointer/promoted receipt PASS, brief0 and no required jobs. Relevant bridge/parent prerequisites, original source/control checkpoints and producer recovery, normalization governance and selected artifact recovery reviewed. No production/dependency/schema or historical capture edits.
  Owned paths / plan: New .0.2.1.2 read-only public native/fresh probe, reviewer and verification capture under docs/checkpoints; new claim under docs/claims. Freeze the newly completed .4.1 audit/.4.2.0/.4.2.1 live durability legs at actual0075 without changing input hashes/results; retain the earlier normalization leg's0f15 revision. Current task/parent closure, index/roadmap/live continuity, relevant bridge/normalization/recovery Knowledge and governing/book teaching move together. Scratch .linkedspec-data/scratch/bridge-reconciliation. Preserve original sources/checkpoints/authorities and actual .0.5/.0.6/.0.7/startup owners; no historical writer replay in current checkout. Declare additional paths here before editing.
  Verification tier: `canonical`
  Focused checks: Exact committed source/authority/checkpoint/producer recovery reconciliation; original seven controls and authorized normalization successor on native/public dump/fresh emitted routes; actual registered-call recursion/slot/identity/effect/error guards through unchanged tracked regressions; source-bound control corruption and honest historical/original-failure boundary; artifact read-denied audit, rendered book/Knowledge/history/memory/doctrines/diff.
  Canonical trigger: Independent milestone/parent closeout requires exact fully staged canonical receipt; no new runtime/authority/CI behavior is planned.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.2.json`
  Acceptance boundary: Reconcile only .0.2.1/.0.2 and their literal/durability/normalization prerequisites from committed evidence plus selected fresh proof. Full neutral sixteen-case/semantic-mutant execution, dispatcher and independent .0.5/.0.6/.0.7/startup defects remain separate.

  Reviewer correction: The first read-only attempt rejected the intentionally corrected composed authority against its older bridge hash. Exclude only that governed source-correction input from the older-byte comparison; separately require the exact authorized loop and unchanged current neutral oracles. Do not refresh the old capture. Final reviewer also checks nonempty public dumped source and exact original emitted identities. No repository defect or runtime waiver follows from that instrument assumption.

  Verification: PASS seven original native/fresh controls with byte-exact original emitted sources;750 completed tests across eight unchanged suites (bridge605, six direct dependents124, normalization21). Fourteen original bridge/checkpoint/authority inputs and26 historical producer/Git bodies remain exact. Twelve source/result/event-order/quiet/rejection corruptions reject. The literal regression's extra signature assertion explains current dependent124 versus dated123; no historical measurement is refreshed. Independent guarded artifact audit134 inputs/24 checkpoints/257 references/149 current inputs and22 recovery/15 CI/six storage/three Phase0 controls PASS with healthy0 original reads/0 tracked writes. Neutral152/16/44 and rendered book PASS. Claim captures all nine new log byte streams and121 tracked byte inputs. No production/test/fixture/authority/CI/dependency edits.
  Pre-canonical disclosure correction: Eight doctrines pass; claim verification rejects an unsupported durability result key and producer-input role label in the new strict record. Remove only that prose field and use the existing producer role; all121 inputs and actual measurements remain unchanged. Verification cadence also requires the not-yet-produced exact canonical receipt, so it is earned through the canonical driver rather than bypassed.
  Canonical plan: Fully stage the complete candidate, then approved-host tools/run_ci_local.sh writes .linkedspec-data/scratch/bridge-reconciliation-canonical.log. Exact candidate/log/exit/CLI/RAM/Phase0 identities belong to the ignored commit brief and promoted receipt, without tracked post-gate edits. The required gate remains this leaf's ownership until completion; no next activation while dirty. Next eligible leaf .0.5.0 diagnoses deferred attached control from committed clean HEAD.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.2 - reconcile committed function bridge prerequisites`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.2` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Original Get/descriptor/dump/fresh observations and retained historical checkpoints identify the bounded registered-call, literal and normalization prerequisites.
- [x] **ROOT CAUSE (WHY + WHERE)** — Committed MethodLowering/CodeblockRuntime/BindingRuntime source identities preserve central compiled dispatch, fresh frames and opaque recursion origins; StatementSplit repair and explicit call-form successor retain separate causal records.
- [x] **FIX** — Reconcile committed children and parents through a new read-only public probe/reviewer; freeze selected recovery claims at actual0075 while retaining normalization0f15 and every old measurement/input identity.
- [x] **ADDRESSED (verified)** — Seven original paired controls,750 completed tracked tests,26 exact recovered source bodies and twelve intended reviewer REDs pass; actual runtime recursion/slot/identity/effect/exception/alias guards stay exercised.
- [x] **NO REGRESSION** — Original sources/checkpoints/authorities remain exact; neutral governance and guarded artifact audit pass. Exact staged canonical CI supplies required Phase0/broader acceptance before parent landing.
- [x] **LOCKSTEP** — Claim/capture, book/Knowledge/task/index/roadmaps and bounded continuity agree on bounded parent closure; independent dispatcher/control/order/readiness/startup/full-execution owners retain scope.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4`
  Status: `done`
  Priority: P1 — retain recoverable instruments before any scratch cleanup or bridge closeout.
  Goal: Reconcile prior callable checkpoints' replay-producer durability and finish the requested claim-policy source/adoption review under explicit ownership.
  Dependencies: clean .0.2.1.1 handoff; no pivot while bridge implementation is dirty.
  Reproduce: Scope repair .0.2.0.1 producer_sources records ignored path/hash entries; current .0.2.1.1 initially did the same and now preserves exact source bodies. Enumerate each selected published replay claim, its tracked test/oracle and actual retained instrument before classifying a leg3 gap. Missing source bodies are not automatically proof that every claim is unreproducible.
  Scope: First inspect the existing .0.2.0.0/.1 and .0.2.1.0 checkpoints, actual retained producer programs and Git source boundaries. Retain/reconstruct exact historical producers where needed, validate their hashes and safe recovery, preserve original evidence and no-drift. Complete the director-requested read-only claim policy review and select a separate owning adoption/audit tree if project-wide work exceeds this bounded callable reconciliation.
  Acceptance: Every selected replay claim has a recoverable tracked instrument or a named, scheduled durability repair with exact source boundary. Adopt applicable claim-verification rules explicitly and own any broader constants/untracked-producer sweep before claiming policy completion. Declare focused/canonical tier and exact paths only at clean activation. Valid-literal and normalization repairs retain separate owners.
  Children: `.1.3.3.0.2.1.4.0`, `.1.3.3.0.2.1.4.1`; preservation lands before policy adoption so neither becomes an oversized slice.
  Reconciliation: Both children preserve sources and adopt bounded working rules; wider audit remains open. Parent reconciliation is retained for the canonical bridge closeout .0.2.1.2 after literal/normalization prerequisites, not inferred from one child commit.

  Reconciled by .0.2.1.2: Committed children and exact retained source/capture boundaries, original seven native/fresh controls,750 tracked tests, twelve source/result corruptions, guarded archive audit and neutral governance establish bounded completion. Exact staged canonical receipt is required before landing this parent closeout. Original infix failure and independent .0.5/.0.6/.0.7/startup/full-execution owners remain unchanged.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.0`
  Status: `done`
  Goal: Preserve exact historical callable replay instruments and their required data without rewriting the original checkpoints.
  Activation: Clean f9c683543c1e56f87c861d52a2b162d63781042a; bridge canonical exit0, both CLI66/66, Phase01033/1162s, promoted receipt, brief0 and clean Git confirmed.
  Owned paths: New docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.0-recovery.json, one recovery Knowledge card and the structured-format-program architecture chapter; task/index/roadmap/bounded continuity and derived Knowledge. Retained producers, inputs and review logs use .linkedspec-data/scratch/selfcontain13302140; original historical files remain exact.
  Verification tier: `focused`
  Focused checks: Enumerate selected producer/input dependencies and original checkpoint/hash/Git boundaries; exact source recovery with corrupt-hash/escaping-path/no-write controls; classify tracked regression oracles separately from standalone observers; unchanged original checkpoints/runtime/authorities; rendered book, Knowledge/history/memory/doctrines/diff.
  Canonical trigger: none; bounded immutable evidence recovery and public explanation only. Policy/gate adoption is a separate child with its own declaration at clean activation.
  Acceptance: Recover every selected instrument and required input, bind original capture revisions and logs, prove safe byte-exact reconstruction, and disclose any unavailable or unverified dependency. Do not substitute current71 cases for historical33 cases or relabel historical execution as newly reverified. Archive the recovery instrument itself; preserve all original observations and repair owners.

  Verification: PASS;15 byte-exact recovered inputs, three immutable original checkpoint identities, nine prior-recorded instrument/Git inputs and six rejected zero-file-write controls. Literal dependencies derive from actual consumer reads and match original row-level sources/oracles. Current/runtime/historical checkpoints and authorities stay exact; no historical runtime re-execution or policy adoption completion. Archived capture/recovery/review sources make this proof reproducible. Rendered book/Knowledge/history/memory/doctrines/diff govern focused landing.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.0 - preserve historical callable instruments`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Prior checkpoints store ignored instrument paths/hashes while their regression oracles remain Git-tracked.
- [x] **ROOT CAUSE (WHY + WHERE)** — Exact checkpoint membership and consumer reads locate seven standalone programs and two literal inputs; hash-only records identify bytes without retaining them.
- [x] **FIX** — Preserve15 source/Git inputs, captured boundaries and archived capture/recovery/review instruments in a separate checkpoint; recover into an owned mirror.
- [x] **ADDRESSED (verified)** —15 recovered byte identities, three original checkpoints, nine prior-recorded instrument/Git inputs, six rejected zero-file-write controls and the verbatim book bootstrap bind source recovery.
- [x] **NO REGRESSION** — Runtime/tests/authorities and all three original checkpoints stay byte-exact; original captured execution remains historical. Standard rendered book, Knowledge/history/memory/doctrine and diff checks govern focused landing.
- [x] **LOCKSTEP** — Recovery checkpoint/card/book, child frontier and bounded continuity distinguish source recovery from runtime proof and retain explicit policy/adoption audit ownership.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1`
  Status: `done`
  Activation: Clean 0ec53b59c3afbe675c0c0b487a1ca10d5e6a55f7, empty brief, no required background job; README/bootstrap/continuity/current leaf and supplied policy recovered.
  Owned paths: DOCTRINE_ENFORCEMENT.md publishing contract, COMMIT.md review template, ADR0126, scripts/check_claim_verification.sh, tools/check_claim_verification.py, tools/check_task_verification_fields.pl owner API, tools/test_tool_project_data_storage.sh and tools/test_project_data_workflow_routing.sh integration, doctrine/cadence registration, docs/claims record, Knowledge/book and bounded continuity. No runtime/dependency/historical checkpoint edits.
  Verification tier: `canonical`
  Focused checks: Actual claim record schema/source/producer controls, staged owner and stale-input RED/GREEN, unchanged default verification-tier API, doctrine/cadence controls, rendered book, Knowledge/history/memory/diff.
  Canonical trigger: New publishing doctrine/checker and registration/cadence infrastructure require exact staged local CI.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1.json`
  Goal: Finish the supplied claim-policy adoption review and adopt its applicable publishing contract with explicit local enforcement and audit ownership.
  Dependencies: clean `.1.3.3.0.2.1.4.0` handoff.
  Planned proof: Supplied policy identity/comparison, local three-leg publishing contract and review template, deterministic fail-closed enforcement and genuine RED controls, unchanged older evidence, rendered teaching and exact staged canonical proof if doctrine/hook/gate owners change.
  Acceptance: Re-derive/falsify/durability are explicit local working rules; applicable mechanization has a named checker and registry route. Existing SESSION-STARTUP-READING.5 retains broader constants/untracked-producer/control and alignment audit ownership, and .29 retains its path repair. Neither that audit nor whole-project policy completion is claimed by a bounded adoption slice. Reconcile .4 only after both children are committed.

  Verification: PASS embedded three positive/sixteen rejected schema/input controls and actual staged six positive/eight rejected controls with exact rejection reasons, restored positives, default tier/owner API and real-index preservation. Canonical receipt binds the exact staged candidate; whole-project adoption/audit and old runtime replay are not claimed.
  Infrastructure integration repair: Canonical attempt1 exits1 at tools/test_tool_project_data_storage.sh's exact Python temporary-owner inventory after all preceding reported checks pass. New test_claim_verification_staged.py is the fourth allocator and new checker/test make42 entrypoints; register them, route the new shell checker, require verified managed scratch and prove its allocation/cleanup plus hostile/symlink rejection before attempt2. Partial attempt1 is not canonical proof.
  Log: .linkedspec-data/scratch/claim-adoption-canonical.log — retained failed attempt1; resumed exact candidate uses claim-adoption-canonical-2.log.
  Instrument repair: Initial alternate-index no-measurement positive failed on the task input hash. Controlled owner mutations now refresh only the fixture task hash and assert exact failure reasons, so declaration tests reach their intended check rather than an unrelated stale-input guard.
  Evidence: docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1.json names the three legs, exact scope and watched artifact inputs; tracked checker and alternate-index test retain the actual instruments.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1 - enforce three-leg claim publishing`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Supplied policy identity matches the September review; selected observer durability repair is committed but a local publishing contract/checker was absent.
- [x] **ROOT CAUSE (WHY + WHERE)** — Hash-only ignored producers do not retain source; repeated aggregate/checklist passes cannot establish independence or semantics. Existing TASK-ACCEPTANCE checks evidence shape without executing Markdown commands.
- [x] **FIX** — ADR0126 adopts explicit local working rules, COMMIT review template and strict claim records; the registered checker validates declared legs and tracked regular blob identities without running recorded commands.
- [x] **ADDRESSED (verified)** — Actual known-bad schema/source inputs and alternate staged-index mutations reject; restored controls and default owner/tier API pass. Exact staged canonical infrastructure proof governs landing.
- [x] **NO REGRESSION** — Runtime, callable authorities and older checkpoints retain their exact bytes. Existing selected verification tiers, history/memory/Knowledge and rendered book remain governed; broader audit stays open under startup5/29.
- [x] **LOCKSTEP** — Doctrine/registry/cadence, policy/review, source-bound record, book/Knowledge/task/roadmap and bounded continuity name the same partial adoption boundary.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3`
  Status: `done`
  Priority: P1 — admitted valid callback literal produces raw invalid generated source.
  Goal: Diagnose and repair the x,y literal reconstruction failure before registered-function bridge closeout.
  Dependencies: clean implementation .0.2.1.1 handoff; no pivot while its runtime work is dirty.
  Reproduce: Public Get of Top:: I { finishBlock={|x,y| return(x) }; return(finishBlock("ok","unused")) }; compare AST::parse_action_expr('{|x,y| return(x) }') and the left,right twin. Exact minimal sources/AST/native and independently loaded fresh emitted errors are bound in .0.2.1.1 verification and retained under .linkedspec-data/scratch/selfcontain1330211/literal-prereq.json, literal-fresh.json and literal-xy/left-right artifacts. Intermediate scanner cause remains diagnosis work; earlier composed distinct-record outputs are not the minimal authority.
  Impact: A valid fixed signature falls through to raw literal text and fails generated Perl compilation. No supported callback claim may waive it.
  Children: `.1.3.3.0.2.1.3.0`, `.1.3.3.0.2.1.3.1`
  Acceptance: Use Get/descriptor/substitution/source dump to find the exact intermediate mechanism, bind native/fresh emitted baseline, fix its owning compiler path with RED/GREEN and focused direct dependents, and keep all original bridge/scope/push records and authorities exact. Declare paths/tier before edits; canonical context/format/infrastructure movement requires broadened proof.

  Closure: .3.0 source-located diagnosis and .3.1 bounded lexical repair are committed through focused/required Phase0 acceptance. Attached-control .0.5 and residual metadata .0.6 remain separate prerequisites; normalization .0.4 is the next eligible leaf before canonical bridge reconciliation.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.0`
  Status: `done`
  Goal: Freeze the minimal valid-literal compiler failure and precise source-located cause before repair.
  Activation: Clean e63a20c635ea74981e7476107750fbb1410a1be0; brief0, exact canonical HEAD receipt and no required background job. README/bootstrap/memory, literal contract/bridge Knowledge, roadmap and public chapter recovered; cause remains unproven.
  Owned paths: This tree; tracked diagnosis/fresh-process producers and capture under docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.0*; new matching docs/claims record and causal Knowledge card; existing literal/bridge Knowledge and structured-format-program book; task index/roadmaps/bounded continuity/derived Knowledge. Freeze the already committed .4.1 claim record as historical e63 with unchanged hashes/results and explicit adoption-candidate scope. Scratch stays under .linkedspec-data/scratch/selfcontain13302130. No production/test/authority/interface/CI/storage edits in this diagnosis.
  Verification tier: `focused`
  Focused checks: Public Get/descriptor/substitution/source dump, standalone and parsed-entry AST comparisons, native and fresh emitted controls, precise owning-source review and distinguishing negative control; unchanged production/authority identities; existing callable/AST direct dependents; book/Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for source-located diagnosis without runtime or infrastructure movement; repair .3.1 selects its actual tier and paths before edits.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.0.json`
  Acceptance: Exact x,y/left,right source pairs, metadata, typed AST and native/fresh emitted failure are durable; no intermediate cause is guessed. Select the bounded owning compiler repair and its tier before code changes.

  Verification: Eight exact native/fresh controls confirm splitter host-quote entry at final y/rest-y/q, malformed whole-action raw RHS and raw generated text; renamed/reordered twins pass. Scoped exact x,y-closer intervention returns ok on both routes, restoration fails again. Two fabricated observation controls reject;91 production/authority inputs remain e63-exact. Tracked probe/fresh/review programs, full capture and watched claims retain all declared inputs. Focused direct dependents and documentation/doctrines govern landing.
  Prelanding correction: The history checker rejected an insertion accidentally anchored to an inline ## token in the CHANGES preamble. Rebuild from exact HEAD bytes and anchor the new record to a start-of-line heading; preserve the complete preamble and all old records.
  Root cause: StatementSplit::Mode::maybe_enter_pipe_quote operator-suffix recognition consumes the callable signature closer; Core then suppresses brace/semicolon processing. AST::Parser::parse_action_block receives one merged assignment, whose RHS becomes raw_perl. Descriptor readiness does not establish compilation.
  Repair selection: .3.1 owns StatementSplit/Core.pm lexical signature state, existing phase0 splitter and callable/AST tests, direct dependents and book/Knowledge/checkpoint/claims/continuity. Ordinary focused compiler correction preserves all public schemas/records/invocation context; full Phase0 is required by COMMIT for the rewriter, and canonical broadening remains required if scope moves. Protect explicit signature delimiters before host quote recognition, preserve host pipe forms/nested/body ownership/malformed diagnostics. No production code changes in .3.0.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.0 - diagnose callable signature pipe splitting`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Exact accepted x,y source fails native handler compilation and independent emitted loading; original source/AST/metadata/dumps/errors retained.
- [x] **ROOT CAUSE (WHY + WHERE)** — Actual pipe mode entry at y/rest-y/q merges the following statement; source-located Core/Mode and whole-action raw RHS establish the mechanism.
- [x] **FIX** — Select lexical signature protection in .3.1; scoped diagnostic bypass plus restoration establishes the causal boundary without shipping a partial fix.
- [x] **ADDRESSED (verified)** — Eight paired controls, two observed review REDs and91 unchanged production/authority inputs are retained with actual tracked instruments.
- [x] **NO REGRESSION** — Production/runtime/authorities stay exact; existing callable/AST direct dependents and focused documentation/doctrines govern this diagnosis only.
- [x] **LOCKSTEP** — Causal card/book/checkpoint/claim, task/roadmaps/frontier and bounded continuity share the diagnosis/repair boundary; prior claim capture is explicitly historical e63.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1`
  Status: `done`
  Goal: Repair and verify the diagnosed literal reconstruction path before bridge reconciliation.
  Dependencies: `.1.3.3.0.2.1.3.0`
  Activation: Clean 67af62f7aa6dff39b6c3fd64b15fb5139f691a0a; completed source-located diagnosis, brief0 and no required job. Exact Core/Mode/AST/rewriter and existing phase0/callable tests reviewed; no normative ambiguity or authority gap.
  Owned paths: perl/LinkedSpec/ActionIR/StatementSplit/Core.pm only for production; existing t/phase0_regression.t and t/callable_codeblock_literal_contract.t; new tracked .3.1 public probe/fresh/review/capture and claim record; causal/literal/bridge Knowledge and architecture book; task index/roadmaps/frontier/bounded continuity/derived Knowledge. Freeze the completed .3.0 claim at actual 67af62f7a with unchanged hashes/results. Scratch under .linkedspec-data/scratch/selfcontain13302131. Public callable/signature/descriptor contracts, eight-field records, invocation context, authorities, dependency pins and CI/storage remain unchanged; add any necessary owner before edits.
  Verification tier: `focused`
  Focused checks: Actual pre-fix RED/new tests, repaired and restored-baseline public native/fresh controls; operator-named fixed/rest/zero/nested/string/body signature and host pipe-quote boundaries; original bridge regression and callable/variadic/binding/map/AST/trace direct dependents; Perl syntax and full phase0_regression per COMMIT; unchanged authorities; book/Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for bounded lexical scanner correction without schema/context/generated-format or infrastructure movement; broaden before landing if scope moves. Later bridge reconciliation and final push require canonical proof.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1.json`
  Acceptance: Matched native/fresh emitted RED/GREEN, original callable/bridge and compiler dependents, no raw fallback or record/schema drift, accurate book/Knowledge/checkpoint/continuity, and warranted canonical proof close this P1 prerequisite.
  Discovered defect: After signature protection, the unchanged body-regex probe reaches a typed unsupported_codeblock_actionir/control_if in CodeblockRuntime::_eval_expr. This separate attached-control-body gap is P1-owned by .0.5 below before dispatcher closeout, not waived as a healthy pipe result or semantic mutant. The initial green observer exits25 because JSON encoding does not preserve that blessed typed error; .3.1 owns observer correction and final matched producer reruns, retaining the original source/failure.
  Additional owned observation: Re-applied native/fresh values, typed errors and generated bytes agree, but nested/body descriptor unmatched-helper event order changes. CanonicalEvents.pm appends residual helper_event_queue entries using unsorted keys at line249. .3.1 owns the tracked order observer and exact controlled hash-seed evidence; separate .0.6 owns normative source-order/overlap diagnosis and repair before dispatcher closeout. Preserve each observed order; do not sort the captured evidence or claim whole-record byte identity.
  Prelanding corrections: First Phase0 fails the existing fixed eight-test plan after28 added splitter assertions; stop its identified owned wrapper with TERM, retain the partial143 log as non-proof, replace the fixed plan with done_testing and rerun full Phase0. Review initially assumed a single baseline merged statement and invariant nested body_ast; actual broken nested source has three fragments and its inner body_ast is corrected by this same splitter. Compare unchanged literal signature/source/spans/fields and retain all actual intermediate AST/metadata boundaries instead.
  Final quote audit: The working guard ran before active backtick consumption. A quoted {| opener consequently left the new signature flag set and merged a following valid x,y callback with its return. Tracked quotes.pl records the actual two-part RED versus three-part independent oracle. Move the guard after existing single-entry/backtick-consumption calls, preserving their relative order, add the regression and retain the intermediate Core source. The intermediate Phase0 attempt2 is stopped143 before changing code, not counted as proof; final attempt3 and all public/direct-dependent/book controls rerun on the exact corrected Core.
  Staged documentation correction: The acceptance shape gate rejects pending in a completed checklist even when it describes other owners. Name .0.4/.0.5/.0.6 explicitly instead. The first doctrine run also observes the resulting staged/worktree mismatch; restage the corrected task and rerun the complete gate through pre-commit without changing runtime proof inputs.

  Verification: PASS; seven final direct-dependent suites729 tests, full Phase0 attempt3 1033 tests/1231s and syntax. Twenty unchanged native/fresh sources retain19 healthy pairs and the exact .0.5 typed failure; restored old Core reproduces compile failures, final re-application preserves values/errors/generated bytes/splits/record fields. Three corruption controls reject, quoted-opener RED/GREEN and three verbatim book pairs pass, nine controlled order/readiness observations retain .0.6 ownership;91 production/authority inputs other than Core remain activation-exact. First/second Phase0 attempts are interrupted143/non-proof. Rendered book/Knowledge/history/memory/staged doctrines govern landing; full canonical CI is reserved for the designated bridge/final boundary.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1 - protect callable signature pipe ownership`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — New callable RED fails48/48 internal assertions and one of11 top-level tests; exact pre-fix and restored-Core public sources fail native/fresh compilation.
- [x] **ROOT CAUSE (WHY + WHERE)** — Whole-action splitter treats an operator-named final signature parameter as host quote syntax; the new delimiter flag must also respect every active quote owner.
- [x] **FIX** — Core protects exact unquoted opener/closer after existing active quote consumption; Mode/public schemas/records/context are unchanged. Dynamic splitter plan retains all37 assertions including the actual backtick regression.
- [x] **ADDRESSED (verified)** — Nineteen final native/fresh healthy pairs, exact old-Core restoration/re-application, typed-error retention, three actual corruptions and verbatim book execution retain tracked instruments and recoverable capture groups.
- [x] **NO REGRESSION** — Seven suites729 and required full Phase01033/1231s pass;91 other production/authority inputs remain base-exact. Actual attached-control/order gaps are owned .0.5/.0.6, not waived or counted healthy.
- [x] **LOCKSTEP** — Public book/causal cards, watched claims/checkpoint, task/roadmap/frontier and bounded continuity retain matching corrected behavior; separate .0.4/.0.5/.0.6 own the remaining prerequisites.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4`
  Status: `done`
  Priority: P1 — the frozen normalization objective fails after repaired callback function dispatch.
  Goal: Resolve the selected normalization loop/source-contract mismatch before dispatcher closeout and neutral runtime execution.
  Dependencies: clean registered bridge/literal prerequisite handoff; no pivot while .0.2.1.1 is dirty.
  Reproduce: Original tests/language-readiness/composed/normalization.spec on input ab-cd now reaches Undefined subroutine count in both native and fresh emitted execution. Generated output retains truthy(i < count(pieces)), $visited = visited + 1 and $i = i + 1. Metadata remains ready1/raw0/fallback0/unresolved0. Exact72-observation producer/artifacts (71 regression plus normalization) are .linkedspec-data/scratch/selfcontain1330211/observations-final.json and original_normalization.pl.
  Root boundary: These expressions remain unlowered; cause and normative status of infix source versus admitted num_lt/num_add helpers need .0 diagnosis. The current attached-while fact explicitly proves the helper-spelled form. Do not label an unverified syntax extension as an admitted compiler defect, silently change frozen sources, or count this plain native/fresh runtime failure as a semantic mutant.
  Children: `.1.3.3.0.4.0`, `.1.3.3.0.4.1`, `.1.3.3.0.4.2`
  Acceptance: Minimize with Get/descriptor/substitution/dumped source and compare canonical arithmetic/while contracts and source selection. Choose an owning compiler correction or explicit fixture/authority correction with historical preservation, then prove healthy original/authorized successor observations and exact no-drift before parent closeout. Startup87 numeric codeblock dispatch remains separate.

  Reconciled by .0.2.1.2: Committed children and exact retained source/capture boundaries, original seven native/fresh controls,750 tracked tests, twelve source/result corruptions, guarded archive audit and neutral governance establish bounded completion. Exact staged canonical receipt is required before landing this parent closeout. Original infix failure and independent .0.5/.0.6/.0.7/startup/full-execution owners remain unchanged.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0`
  Status: `done`
  Goal: Diagnose the normalization loop mismatch against the current admitted DSL and frozen source selection.
  Activation: Clean 446fb65fadca2e1bd31fec93bb9de779eb2134d1 on October2; literal repair committed, all ten doctrines/post-pointer pass, brief0 and no required jobs. Roadmap, source selection/governance, arithmetic call and attached-while Knowledge/public manual reviewed; infix normative status is the specific unresolved question.
  Owned paths / plan: New tracked .4.0 public probe/fresh/review/capture under docs/checkpoints and claim record under docs/claims; source-preserving arithmetic/normalization Knowledge and architecture book; current task/index/roadmaps/bounded continuity and derived Knowledge. Freeze .3.1's actual capture at 446fb65fadca2e1bd31fec93bb9de779eb2134d1 without changing hashes/results. Scratch stays .linkedspec-data/scratch/selfcontain133040. No production, fixture, authority, CI/storage, dependency or schema edits in diagnosis; .4.1 owns a selected correction after evidence.
  Verification tier: `focused`
  Focused checks: Public Get/descriptor/substitution/dumped source and independent fresh emitted original/minimal/helper/word/symbol controls; canonical call grammar and exact source/authority preservation; source-bound observations and distinguishing falsifiers; direct neutral governance, rendered book, Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for source-preserving diagnosis; .4.1 must select canonical if normative fixture/authority changes, with original bytes retained.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0.json`
  Acceptance: Exact public native/fresh emitted controls and generated condition/body mechanism establish the cause and normative boundary, preserve original bytes, and select a safe repair tier/paths without guessing or waiving the failure.
  Observer corrections: The first probe passes a statement sequence to parse_action_expr and exits25 with nested_write_root_not_addressable; preserve its source/log and use parse_action_block. Review also incorrectly assumes every host-behavior control is warning-free: actual fresh infix increment/condition report numeric bareword warnings; retain/assert those warnings instead of altering the captures. Seven admitted-form controls are quiet; native failure traces are separate from DSL events.
  Owned audit defect / next repair: The unchanged historical verify_objectives.py rejects current executable evidence drift: t/phase0_regression.t after the .3.1 signature regression. Exact current historical-input census has only that unapproved executable delta plus the two already admitted CI/Perl-storage evolutions. Impact: a legitimate new regression blocks historical reconciliation. Schedule P1 .4.1's planned audit integration to reconstruct the exact original Phase0 bytes by reversing only the .3.1 addition/plan change, with owner/source identities and missing/changed/unrelated-delta falsifiers. This failed audit is retained as a scoped remaining owner, not reported PASS or used to rewrite old evidence.

  Completion: Eleven matched native/fresh controls retain seven admitted-form successes, two host-count failures and two infix host behaviors with actual fresh warnings. AST/raw/lowering locations and public call grammar select an explicit call-form successor; the one-loop pilot yields the independent nested value. Three actual observation corruptions reject;102 production/governing inputs remain activation-exact. Neutral140/16/44 and rendered book pass. Historical audit rejects only the newly unadmitted Phase0 test delta besides already-owned CI/storage evolution; .4.1 owns that narrow correction. No fixture, authority, production or admission changes.
  Documentation defect corrected here: The bridge chapter still described x,y compilation failure after .3.1 and earlier push failure as current. Qualify the dated push boundary, link repaired signatures and replace stale prerequisites with current source/control/metadata owners; rendered source checks reject the stale literal sentence.
  Prelanding portability correction: First hook run passes nine doctrines and rejects the audit traceback's runtime checkout identity. Retain its raw scratch log/digest and explicitly project only the three repository-root prefixes out of tracked traceback locations; preserve every other byte, error and owner. Regenerate/stage the reviewed artifact and claim, then rerun all doctrines without changing runtime captures.
  Verification: Public eleven-pair review and three RED corruptions PASS; neutral governance PASS; rendered book and verbatim loop pair PASS. Required remaining audit repair is retained explicitly under .4.1 rather than counted successful. Knowledge/history/memory/diff and all doctrines govern this focused diagnosis commit.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0 - diagnose normalization call grammar mismatch`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — LinkedSpec::Get native and fresh emitted original/minimal infix loops fail host count; direct count succeeds.
- [x] **ROOT CAUSE (WHY + WHERE)** — Public block AST contains raw_perl children; dump_parser_source/call_spec_handler_subst retain barewords at Parser.pm:289 and ValueExpr.pm:653. The numeric manual defines call grammar.
- [x] **FIX** — Select canonical .4.1 successor source/binding with exact one-loop correction and unchanged oracles; separate .0.7 owns false-ready telemetry. The historical test-audit mismatch has its explicit .4.1 repair.
- [x] **ADDRESSED (verified)** — Eleven paired controls, independent values, three actual corruption REDs and exact source/producer captures establish diagnosis and bounded repair ownership.
- [x] **NO REGRESSION** —102 production/governing inputs stay base-exact; neutral140/16/44 and rendered book PASS. No runtime, fixture or authority changes belong to diagnosis.
- [x] **LOCKSTEP** — Book, source-bound card/capture/claim, task/frontier/roadmaps and bounded continuity share the successor, telemetry and historical-audit owners.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1`
  Status: `done`
  Goal: Bind and verify the diagnosed call-form successor and narrow historical-audit correction.
  Dependencies: `.1.3.3.0.4.0`
  Activation: Clean 03e2bb9a7f48abbe58771f624cb6aba3a068fd35; diagnosis committed, all ten doctrines/post-pointer pass, brief0 and no required jobs. Exact fixture/oracle/checker/CI/audit seams, public call grammar, diagnostic invocation options and typed exits reviewed. Production remains outside this correction.
  Owned paths / plan: New tests/language-readiness/composed/normalization-calls.spec; capability_conformance/composed_objective_contract.json and tools/check_composed_objective_contract.py for explicit source-correction provenance/bindings; exact tools/run_ci_local.sh registration and tests/language-readiness/verify_objectives.py CI/Phase0 evolution. Add t/composed_normalization_perl.t plus tracked .4.1 fresh-process observer/review/capture under docs/checkpoints and claim record under docs/claims. Native/fresh transport uses pipes, avoiding new temporary allocator ownership. Preserve original normalization.spec and every earlier selection/checkpoint/corpus/oracle. Align governance/selection current note, source-bound/neutral Knowledge and architecture book, task/index/roadmaps/bounded continuity/derived Knowledge; freeze .4.0 capture at actual03e2bb9a7 without refreshing results/hashes. Scratch stays .linkedspec-data/scratch/selfcontain133041; no production, public schema, dependency or admission edits.
  Verification tier: `canonical`
  Focused checks: Source-bound original RED/successor GREEN and seven normalization native/fresh cases with independent typed values/events/exit/quietness and actual returned-object detachment plus deliberate aliases; exact one-loop original/successor and unchanged sixteen oracles/foundation; neutral structural/source-correction/report falsifiers and reason-sensitive audit CI/Phase0 controls; direct diagnostic/callable/bridge/binding/mutation dependents; syntax/book/Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: Normative source-binding/checker and recurring CI/audit movement; fully stage the exact candidate and require receipt-bound tools/run_ci_local.sh before landing.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1.json`
  Selected repair: Canonical fixture/source-binding correction, not infix syntax extension. Preserve normalization.spec and the original selection/checkpoints byte-exact; add normalization-calls.spec with only the diagnosed loop replaced by num_lt/num_add calls. Bind explicit old/new identities and .4.1 ownership in composed objective governance/checker, preserve all sixteen case oracles, dimensions, mutation roles and original foundation inputs. Exact recurring registration/audit evolution, seven normalization native/fresh cases and actual detachment/event/failure controls require canonical acceptance. Select all implementation paths at clean activation; .0.7 independently owns false-ready raw-expression telemetry.
  Additional owned P1 audit correction: Reconcile the exact .3.1 Phase0 signature-regression delta in tests/language-readiness/verify_objectives.py without refreshing historical hashes. Original milestone source bytes and all old corpora remain exact; reject missing/weakened regression and unrelated current edits independently of the new successor registration.
  Audit control correction: The first repaired audit reaches falsification and rejects an old no-op mutator: new successor registrations split the older composed-input block, so removing that complete historical block changes zero current bytes. Read-only targeted measurement records zero matches/unchanged/accepted, while direct call/new-input mutations change actual bytes and reject with their registration reason. Remove one actual composed-artifact registration instead; require every governance mutation to change bytes before it can count. Retain the failed log/diagnosis and rerun complete audit controls; no old source hash or falsifier role is discarded.
  Acceptance: Source-bound RED/GREEN and direct dependents, original historical evidence, complete normalization values/ordered diagnostics/continuation, honest metadata and appropriate canonical acceptance resolve the P1 owner before .0.3.

  Completion: Exact one-loop successor and closed source-correction provenance preserve original bytes and all sixteen authority oracles;92 production/governing inputs remain activation-exact. Seven native/fresh normalization pairs pass21 top-level tests and eight actual-object/alias controls. Four actual observation corruptions reject. Neutral152/16/44, objective audit24/257/149/134 with12 CI/six storage/three Phase0 byte-changing mutations, five direct suites652 and rendered full source/example pass. Tracked .4.1 verification/review/claim bind actual producers and historical .4.0 RED. Exact staged canonical receipt and commit body supply the landing result; P1 artifact recovery .0.4.2 follows; bridge .0.2.1.2 reconciles parent .4 and its bridge parents after that bounded repair. No production, infix syntax, schema, dependency or admission changes.
  Verification: Source-bound review/four RED corruptions, selected public regression, neutral/historical audit, direct dependents, syntax and rendered book PASS. Knowledge/history/memory/all doctrines/diff plus exact staged canonical gate govern this designated boundary.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1 - bind call-form normalization successor`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Historical source-bound native/fresh .4.0 original retains host count failure; the unchanged oracle selects a one-loop successor.
- [x] **ROOT CAUSE (WHY + WHERE)** — Public block AST/raw lowering and numeric helper reference establish unsupported infix; calls use the admitted grammar, preserving separate raw-readiness .0.7.
- [x] **FIX** — Exactly one loop changes in normalization-calls.spec; closed original/successor provenance and exact checker/CI/audit evolution retain all16 oracles and historical inputs.
- [x] **ADDRESSED (verified)** — Seven native/fresh cases, typed values/events/exits/quietness, eight actual-object alias controls and four corrupted-observation REDs pass source-bound review.
- [x] **NO REGRESSION** —92 production/governing inputs remain exact; five dependent suites652, neutral152/16/44 and audit24/257/149/134 plus12/6/3 mutations PASS. Exact staged canonical receipt governs landing.
- [x] **LOCKSTEP** — Full rendered source/example, governance/selection/cards, task/frontier/roadmaps and bounded continuity bind the explicit successor and independent remaining owners.

  Additional owned instrument: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1-mode-proof.py denies actual legacy-log reads and tracked capture writes to distinguish normalization-only review from the full snapshot writer.
  Owned claim-coverage correction: Canonical attempt1 completes successfully, but author review identifies an overbroad checked durability leg for the separate historical audit. Its134 retained logs total84,613,241 bytes; selected24 checkpoints total214,367 bytes and the new capture preserves audit hashes, not raw input recovery. Concrete .linkedspec-data/scratch/context-lua-storage.log is501 bytes, has no Git path history, and its actual TAP timing line is absent from selected checkpoints; no tracked archive path is present in those proof surfaces. This does not classify every earlier proof as unreproducible. Separate the complete seven-case normalization proof from the historical-audit measurement, disclose the latter leg3 gap under new P1 .0.4.2, and provide a source-bound normalization-only review that does not consume legacy logs. Preserve all actual results/hashes. Refresh capture/claims/docs and stage/run a new exact canonical candidate; attempt1 receipt cannot cover changed disclosure.

  Canonical attempt1: PASS exact candidate3ab3be6865ab7490f53d3bd156c5ee83e1e109a07e1b080bb515d9e75d275ed2 at activation03e2bb9a7; all ten doctrines, both66/66 CLI environments and Phase01033/1268s pass. This validates that earlier candidate only. Author review then separates the complete normalization claim from the historical artifact-input gap; changed capture/disclosure requires a new exact receipt before landing. Actual attempt2 result belongs to commit body/receipt.
  Coverage signoff: Read-only normalization-only mode passes seven paired cases, eight actual-object controls, four observation REDs,16 unchanged oracles and92 unchanged production/governing inputs without reading legacy logs or writing tracked captures. The historical audit measurement retains its actual24/257/149/134 and12/6/3 results, with leg3 explicitly gap-owned by scheduled .0.4.2; no blanket earlier-proof recovery claim is made.

  Canonical attempt2: PASS exact candidate097a51b0e967dd0639d5ec121245b3eaa88d185a571b1982dad52bdf84e989e3 at activation03e2bb9a7; all ten doctrines, both66/66 CLI environments and Phase01033/1266s pass. Log SHA256900b80a73f287aa94fa55891e5ab1e8fa5d8441da470b0b349f4b00c60efc2f3. This validates that frozen candidate only; the following replay correction requires a new exact receipt.
  Owned fresh-replay defect: The mode-proof snapshot-denial control reads the ignored normalization-correction-objective-audit-3.log before it reaches its legacy-log denial. The normalization replay intentionally omits the legacy audit producer, so a fresh checkout lacks that intermediate report. An actual read-denial probe reproduces FileNotFoundError at that exact path while leaving all original artifacts and tracked files intact. The complete report data already lives in the tracked .4.1 verification capture. Preserve the failing mode-proof source byte-exact as .4.1-mode-proof-before.py, recover only the report data in memory from that capture, and add .4.1-mode-replay-proof.py with original RED/repaired GREEN under actual report-read denial. Both controls retain legacy-log/read and tracked-write guards. Extend the source-bound reviewer/capture/claim and fact card with these owned inputs/results before canonical attempt3; do not land the replay defect or relabel the separate134-log recovery gap.
  Replay instrumentation correction: The first updated reviewer validates mode-replay-proof.log before reaching the guarded legacy read, creating a circular requirement for that proof's own output. Actual first runs fail on an absent/empty replay report and do not count as proof. Move snapshot-only replay-report validation after the first legacy-input read; the mode-denial producer then terminates at its intended guard before that later output is needed. Retain the failed scratch logs as diagnostic chronology; final actual original-RED/repaired-GREEN execution supplies acceptance.
  Replay signoff: Original mode-proof SHA2569d186b46847aa51ec6e4cc031528f67faad3786dd9ce7b8c5fbfd56e6b20d94b is retained byte-exact. Actual report-read denial gives original RED and repaired GREEN; repaired proof makes zero original-report reads, obtains snapshot metadata only from the tracked capture and preserves both legacy-read and tracked-write guards. The reviewer consumes the replay result only after the guarded legacy boundary, eliminating circular output dependence. Updated source-bound records and exact canonical attempt3 govern landing;134-log recovery remains separate under .0.4.2.
  Snapshot evaluation-order correction: The first capture refresh references the moved replay report in an earlier summary expression and fails NameError before writing a capture. Compute that count after report validation, then rerun both guarded controls and the full snapshot writer. Failed refreshes are diagnostic chronology, not accepted evidence.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2`
  Status: `done`
  Priority: P1 — close the disclosed historical audit artifact-input recovery gap before bridge parent signoff.
  Goal: Retain and verify the closed134-log input population for fresh-checkout historical audit recovery.
  Dependencies: clean .0.4.1 source/disclosure handoff; no pivot with a dirty candidate.
  Original reproduce / impact: verify_objectives.py reads134 ignored local logs and compares exact historical SHA256 values. The new .4.1 audit report records hashes without establishing input recovery; context-lua-storage.log is a concrete501-byte Git-untracked timing-bearing input absent as literal log bytes from the selected checkpoint population. Fresh re-derivation needs those original artifact bytes or verified recovery, separately from the fully retained normalization runtime proof.
  Planned scope: Census selected input identities and existing archival coverage before classifying gaps; retain only the exact required opaque observation bytes through a bounded repository-volume format and tracked producer/manifest. All operational paths stay relative, every restored input must match its old hash, and historical sources/results remain unchanged. Do not execute historical writers or use observed trace paths as filesystem locations. Design a safe restore into a declared managed destination with no traversal/symlink escape or ambiguous overwrite; recover then rerun the actual audit and distinguishing controls. Broader source/claim audit remains startup5/29.
  Planned proof: Exact134 membership/bytes/hashes, actual isolated recovery and byte corruption/path/overwrite controls, complete unchanged historical audit and source-bound claim correction. Storage/artifact infrastructure and parent admission use receipt-bound canonical tier at activation. If inventory exceeds one safe artifact slice, split capture/recovery/signoff before implementation.
  Acceptance: The selected artifact-input leg has verified tracked recovery or an exact narrower named residual blocker; do not convert a hash-only record into an archival claim. Bridge .0.2.1.2 waits for this bounded repair.
  Children: `.1.3.3.0.4.2.0`, `.1.3.3.0.4.2.1`
  Slice decision: Separate the source-bound closed-population/coverage census and bounded format plan from archive/restoration implementation. The selected raw population is approximately84.6MB; preserve originals and exact old identities throughout. Census does not claim archival recovery or close the parent.

  Completion: .4.2.0 census and .4.2.1 exact closed archive/isolated recovery/read-denied audit satisfy the selected134-log recovery obligation. Canonical .4.2.1 landing closes this parent only; original measurements and broader claim/bridge/dispatcher/format owners remain separate.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0`
  Status: `done`
  Goal: Inventory the exact historical artifact population, assess selected existing coverage and choose a bounded recovery format before implementation.
  Activation: Clean0f15e194febbe0e6099fba5ae5f9bca8a1b1d7be; normalization source/replay correction committed, all ten hooks/post-pointer pass, brief0, no required jobs. Relevant roadmap, audit reader, claim owner rules, recovery card and storage/task capacity policy reviewed. Archive/decoder implementation remains .4.2.1.
  Owned paths / plan: New read-only .4.2.0 census producer/verification capture under docs/checkpoints and claim record under docs/claims; scoped recovery plan under docs/language-readiness; recovery Knowledge/card and relevant architecture-book teaching; current task/index/roadmaps/bounded continuity/derived Knowledge. Preserve all existing raw logs, producing checkpoints and source hashes. Freeze .4.1's checked normalization leg at actual0f15e194f without refreshing any measurements; its separate artifact gap stays open under parent .4.2. Scratch stays .linkedspec-data/scratch/objective-artifact-census. No production, fixture, CI/storage/hook, dependency or schema changes.
  Verification tier: `focused`
  Focused checks: Independent population reconstruction from the three historical milestones versus the current audit; each regular relative same-volume input's exact old hash/bytes; selected existing coverage census and actual distinguishing corruption/membership/path controls; source-bound capture and explicit durability disclosure; book/Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for read-only census/format planning; archive/restoration and recurring infrastructure implementation .4.2.1 require exact canonical proof.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0.json`
  Acceptance: Exact measured membership/sizes/hashes and bounded coverage findings survive through a tracked producer/capture; recovery format and next implementation paths/proof are explicit. Missing byte-recovery durability remains disclosed under .4.2.1; census is not a repair/admission claim.

  Completion: Independent48/39/47 milestone populations equal the committed audited134-member map. All original regular same-volume hashes match; raw84,613,241 bytes, independent zlib1.2.12 level9 lengths3,394,928 bytes. Selected24 checkpoints/214,367 bytes contain zero complete-log identities among whole/UTF-8-string/joined-array candidates; no archive-extension member in the three selected surfaces. Other encodings/surfaces remain unassessed. Actual-byte corruption, two actual population changes and three outside paths reject. Source-bound producer/capture and explicit ZIP/manifest/restoration/replay plan retained; no archive or byte recovery claimed. .4.1 normalization claim frozen at actual0f15 without changed measurements.
  Verification: Read-only census and reason-sensitive controls PASS; book/Knowledge/history/memory/ten doctrines and diff govern focused landing.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0 - census historical audit artifact inputs`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1`
  Status: `done`
  Goal: Retain the exact selected observation bytes and prove safe isolated restoration plus historical audit re-derivation.
  Dependencies: `.1.3.3.0.4.2.0`
  Planned scope: Implement the reviewed bounded opaque-byte archive/manifest and read-only validator/restorer; all operational paths relative and managed on the repository volume. Exact original hash population, no traversal/symlink escape or overwrite, independent corruption/absence controls and actual original-input-read denial must distinguish recovery. Rerun the historical audit on restored inputs; retain original raw files and historical writers/results. Correct only the explicitly superseded selected durability legs after verified recovery, preserving their prior measurements. Recurring registration/owned CI evolution and canonical parent signoff remain in this leaf.
  Acceptance: Exact selected bytes are recoverable from tracked inputs in an isolated managed destination and the complete audit passes without reading original local logs. Close .4.2 only with source-bound recovery/controls and exact canonical receipt; broader startup5/29 remains separate.

  Activation: Clean0ed526576788327eaf60c4c9ad34a19c57d22da6; census hooks/post-pointer PASS, brief0 and no required jobs. Read-only plan/Knowledge, actual audit reader/falsifiers, ZIP format bounds, claim supersession and CI ownership reviewed before implementation. Original134 logs and milestone/census captures remain intact.
  Owned paths / plan: tests/language-readiness/artifacts/objective-audit-inputs.zip and objective-audit-inputs.json; tests/language-readiness/recover_objective_audit_inputs.py; .4.2.1 archive producer/recovery proof/verification capture under docs/checkpoints; exact archive/input/recurring proof registration in tools/run_ci_local.sh and reason-sensitive newest-first reversal in tests/language-readiness/verify_objectives.py. Update Toolbox, scoped recovery plan/governance/book/Knowledge, selected .4.1/.4.2.0 durability legs and new .4.2.1 claim; task/index/roadmaps/bounded continuity/derived map. Add necessary paths here before editing. No production, DSL fixture/oracle, schema, hook, dependency or historical capture mutation. Scratch .linkedspec-data/scratch/objective-artifact-recovery; fixed owned results remain retained.
  Verification tier: `canonical`
  Focused checks: Exact independent134 membership/bytes/hashes; deterministic capture; complete archive validation and exclusive isolated restoration; actual altered ZIP/missing member/hash/size/path/symlink/overwrite controls with intended reasons; full historical audit plus its actual falsifiers under original-log-read and tracked-write denial; original-source/capture preservation and explicit selected claim supersession; book/Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: Archive/storage and recurring CI infrastructure plus .4.2 parent closeout require fully staged exact candidate receipt before commit.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1.json`
  Acceptance boundary: Verified archive and isolated outputs match all original hashes. Actual audit consumes restored bytes with zero original-log reads and no tracked writes. Preserve old results; only selected durability legs are superseded explicitly. Canonical receipt closes artifact parent, not bridge/dispatcher/full D/P/backend admission.

  Owned navigation defect: Toolbox still advertised the original140 structural proof/40 tools despite the current152 checker and later storage adoption. Reproduce by comparing its composed section with current neutral proof and owned CI additions. Repair its bounded counters/source-succession description and add exact artifact navigation in this leaf; no checker/runtime semantics change.
  Completion: Closed ZIP3,406,206 bytes SHA2564f48d1dacd2de861a2b9ebdcb361b30a8d0084cc88700edf39801cee1df1a715; independent134 members/84,613,241 bytes restore exactly. Fixed metadata/in-memory regeneration is byte-exact from the restored reader under original-read/tracked-write denial.22 reason-sensitive actual archive/manifest/destination/guard/absence/summary controls pass; full historical audit24/257/149/134 and four input/two path/15 CI/six storage/three Phase0 controls pass. Deliberate denial probes are separate; healthy replay attempts0/0. One recurring call/thirteen inputs normalize newest-first and preserve prior CI bytes. Original raw files, milestones, census and .4.1 capture remain intact. Only two selected durability legs explicitly superseded; their rederive/falsify results remain exact. New source-bound claim retains184 inputs including instrument/capture. No parent bridge/dispatcher/full D/P/backend/format admission.
  Verification: Read-only validator, actual public CLI restore, original-input deterministic check, isolated regenerated archive/proof and all original source/claim preservation PASS. Book/Knowledge/history/memory/doctrines/diff and exact staged canonical receipt govern landing; gate results/fingerprint/log digest are recorded in the producing commit body without editing its admitted candidate.
  Author-review correction: Final book synchronization changed one watched document after the initial recovery capture. The direct source-binding check and claim gate reject that stale input before canonical launch. Rerun the complete guarded recovery/audit producer against final source bytes and rebuild only the new/superseded durability input lists from its actual result; never patch the recorded book hash without replay or alter prior historical measurements. Retain the rejected scratch capture/log as diagnostic chronology.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1 - recover historical audit artifact inputs`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1` Acceptance Checklist

- [x] **INDEPENDENT INPUTS** — Original48/39/47 maps and census bind all134 original hashes/byte counts; no old capture or raw file is changed.
- [x] **REAL RECOVERY / DENIAL** — Actual isolated outputs, regenerated ZIP and absent restored input distinguish byte recovery from original fallback. Deliberate actual read/write probes exercise guards; healthy full replay attempts0/0.
- [x] **SAFE FORMAT / STORAGE** — Closed opaque archive/manifest, bounded expansion, new exclusive destination and actual corrupt/member/path/symlink/overwrite controls preserve repository-volume locality.
- [x] **HISTORICAL AUTHORITY** — Original24/257/149/134 audit and reason-sensitive15/6/3 governance mutations preserve prior hashes/results; explicit selected durability supersession keeps broader owners separate.
- [x] **RECURRING / PUBLIC / LANDING** — One recurring proof/thirteen inputs, source-bound184-input claim/capture, book/Knowledge/live alignment; exact staged canonical receipt governs atomic parent closeout.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.3`
  Status: `pending`
  Goal: Independently reconcile the two repaired dispatcher routes against the original minimal controls and selected normalization objective before parent closeout.
  Dependencies: `.1.3.3.0.1`, `.1.3.3.0.2`, `.1.3.3.0.4`, `.1.3.3.0.5`, `.1.3.3.0.6`, `.1.3.3.0.7`
  Acceptance: Bind exact code, sources, native/emitted observations and focused controls; retain all unrelated repair prerequisites. Close .1.3.3.0 only after the selected pipeline runs correctly without raw host fallback, and then activate .1.3.3.1 for complete neutral-case and semantic-mutant execution.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5`
  Status: `pending`
  Priority: P1 — accepted attached control AST is unsupported inside a deferred callable body.
  Goal: Diagnose and repair attached control execution in deferred Perl bodies before dispatcher closeout.
  Dependencies: clean literal .0.2.1.3 and normalization .0.4 handoffs.
  Reproduce: Top:: I { cb={|x,y| if(matches(x, /ok/)) { return(x) }; return("miss") }; return(cb("ok","unused")) } after the signature repair. Public native execution reports a typed unsupported_codeblock_actionir with kind control_if; CodeblockRuntime::_eval_expr falls through to that diagnostic because it has no control_if arm. Final .3.1 probe/capture must retain source-bound native/fresh evidence. Normative control/helper and body-return semantics need .5.0 diagnosis before changing this separate runtime.
  Impact: The recognized attached conditional cannot execute inside a deferred body. This is separate from signature segmentation and cannot be counted as a healthy control or mutation.
  Children: `.1.3.3.0.5.0`, `.1.3.3.0.5.1`, `.1.3.3.0.5.2`, `.1.3.3.0.5.3`
  Acceptance: Use public toolbox controls and canonical control/return contracts; select compiler/runtime ownership and tier; retain exact historical failure, implement distinguishing RED/GREEN with branch laziness and local returns, cover direct dependents and appropriate canonical acceptance without schema drift.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0`
  Status: `done`
  Goal: Freeze the exact deferred attached-control failure, normative semantics and bounded repair ownership before runtime edits.
  Acceptance: Matched native/fresh typed failure and positive equivalent controls locate the unsupported AST boundary; contract/source/return/scope review selects safe repair paths and verification tier without assuming all control families behave alike.

  Activation: Clean e07f80f74c8c80b426c4b846a1293139848229db; bridge parent closeout canonical exit0/CLI66 twice/Phase01033 in1063s, ten hooks/post-pointer/promoted receipt PASS, brief0 and no required jobs. Bounded bridge/literal/source/durability parents are closed. Existing deferred-control Knowledge, callable block-local return/context/parameter contracts, AST if-family lowering and public helper teaching reviewed; current control family extent remains diagnosis work. Artifact cleanup is not yet due (latest October2 15:55UTC).
  Owned paths / plan: New .0.5.0 public probe, fresh child, read-only reviewer and complete observation capture under docs/checkpoints; new claim under docs/claims. Relevant deferred-control Knowledge and public architecture/helper teaching, task/frontier/index/roadmaps and bounded continuity move together. Scratch .linkedspec-data/scratch/deferred-control-diagnosis. Production, tests, fixtures/authorities, CI/storage/dependencies and original captures stay exact. Public Get/descriptor/substitution/dump and AST probes precede implementation inspection; declare additional paths before edits. No historical writer replay.
  Verification tier: `focused`
  Focused checks: Source-bound public native/fresh attached-if failure and positive equivalent/early-return/scope/parameter controls; typed AST/control-family/return/loop contracts and exact compiler/runtime source location; actual distinguishing effects and observation corruption; direct callable-literal/AST/bridge/normalization regressions; original source/authority preservation and rendered book/Knowledge/history/memory/doctrines/diff.
  Canonical trigger: none for source-preserving diagnosis; .0.5.1 declares its repair tier after actual interface/contract extent is known.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0.json`
  Replay comparison correction: The first actual replay rejects whole native failure stdout equality. Recursive field comparison proves only wall-clock prefixes on SpecEntry trace_decision lines differ; values, typed carriers, actual identities/effects and all emitted bytes agree. Existing bridge Knowledge already distinguishes framework failure traces from DSL effects. Preserve both raw streams and project only anchored datetime prefixes for replay equality; no metadata sorting, source-hash refresh or DSL-effect suppression. The first attempted review remains failed diagnostic chronology.
  Additional owned capture: .0.5.0-observations.json retains complete final public source/AST/metadata/dumped/emitted/value/error/runtime-identity data; the smaller verification capture references its tracked byte identity and retains focused logs. .5.2/.5.3 explicitly own observed marker/value-if residuals; no finding is left unscheduled.
  Limits: This leaf freezes observed control coverage and selects repair ownership. It does not change runtime behavior, assume every control family is equivalent, close .0.5/.0.6/.0.7/dispatcher/full16 execution, or refresh earlier proofs.
  Additional owned diagnostics: Preserve the first probe source/observation as .0.5.0-probe-before.pl and .0.5.0-observation-before.json; its when source misses one brace, and function probes need explicit LF source separation before their unexpected null result is classified. Final proof keeps these corrections distinct from compiler defects. Actual public invoke observations may inspect existing caller binding/error identities without changing production.
  Dependency reconciliation: Corrected LF-separated attached-statement function bodies remain unsupported under the existing value-oriented function MVP; their deterministic unresolved/bridge body diagnostics are not healthy equivalents. Admitted return(if(...)) function and bridged variants succeed. Direct deferred matches literal reproduces the already-owned regex/helper failure in SESSION-STARTUP-READING.87.2, whose indexed leaf owns both literal/string operands. Finish this diagnosis and clean commit, then schedule .87.2 before .0.5.1 so the original matches-based attached-if source can become healthy. .0.5 still owns branch/return semantics; no duplicate helper owner or function feature extension. Add .0.5.0-observe.pm as a shared read-only public-invoke observer, preserving actual binding/effect/error identities and deliberate equal-value reference control.

  Verification: PASS; actual current public replay matches retained semantic/source/generated observations after only anchored failure-trace timestamp projection. Twenty native/fresh pairs and four ASTs retain five healthy comparisons, ten control_if failures, three other typed failures and two unsupported function bodies. Actual original-slot restoration, equal-value distinct-reference rejection, exact thrown-object identity and before-only effects pass both routes. Ten actual observation corruptions reject; four unchanged suites pass660 tests (11 literal,23 AST,605 bridge,21 normalization). Complete original observations, actual replay core, all four TAP streams and source hashes survive in tracked captures. Production/tests/authorities remain e07f-exact; focused book/Knowledge/history/memory/all-doctrine checks govern landing.
  Current-summary correction: TASK_TREE index row still names historical artifact recovery and schedules the already completed bridge reconciliation despite its updated leading paragraph. This diagnosis owns correction of that exact row plus current book/roadmap summaries to the twenty-source diagnosis and startup87.2 prerequisite; existing past evidence is unchanged.
  Instrument correction: The successful review's actual replay command field reused the final suite command variable. Preserve a distinct replay_command, rerun the public replay and all focused suites, and retain the corrected capture before claim publication. Actual command/result attribution is part of this leaf's proof.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0 - diagnose deferred conditional execution`.

### `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0` Acceptance Checklist

- [x] **REPRODUCE / ISSUE** — Exact original and nine conditional variants load native/fresh, then retain unsupported_codeblock_actionir/control_if; complete sources/generated bytes/carriers survive.
- [x] **ROOT CAUSE (WHY + WHERE)** — Public AST/substitution/dumps distinguish recognized control nodes from missing CodeblockRuntime::_eval_expr dispatch and top-level-only _execute_body returns; no literal or function-MVP expansion is assumed.
- [x] **FIX** — Select existing startup87.2 matches/regex prerequisite before attached .5.1; independently schedule marker .5.2 and value .5.3 with exact reproductions/impact and lazy branch/return/restoration acceptance.
- [x] **ADDRESSED (verified)** — Twenty paired observations, four ASTs, actual caller-slot/error/effect identities and equal-value reference control are retained; ten distinguishing corrupted observations reject through the same reviewer.
- [x] **NO REGRESSION** — Four unchanged suites660 tests pass; production/tests/authorities stay activation-exact. Diagnosis claims no runtime repair, other-backend admission or full-sixteen execution.
- [x] **LOCKSTEP** — Tracked public producers/captures/claim, causal Knowledge, rendered book, task/roadmap/current index and bounded live/resume/history align; next startup87.2 activates only after this clean commit.


- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1`
  Status: `pending`
  Goal: Implement and verify the diagnosed deferred-control correction before dispatcher closure.
  Dependencies: `.1.3.3.0.5.0`, committed `SESSION-STARTUP-READING.87.2` matches/regex prerequisite
  Acceptance: Actual branch/operand/body effects, return propagation, caller/parameter restoration and native/fresh RED/GREEN plus direct dependents establish the bounded repair; preserve other open controls, accurate public teaching and warranted canonical proof.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.2`
  Status: `pending`
  Priority: P1 — an existing marker conditional is parsed but cannot execute in a deferred body.
  Goal: Repair or independently verify deferred marker if/elseif/else/endif after attached-control repair, without enlarging .5.1 beyond a safe slice.
  Dependencies: committed `.1.3.3.0.5.0`, `.1.3.3.0.5.1`; matching helper prerequisite `SESSION-STARTUP-READING.87.2`.
  Reproduce: Top:: I { cb={|| if(true); return("hit"); else(); return("miss"); endif() }; return(cb()) }. Public native/fresh currently fail unsupported_codeblock_actionir/control_if; typed body statements separately contain control_if/control_else/control_endif.
  Impact: Published marker branching cannot compose through the callable runtime. Current .5.0 freezes the exact source/typed failure; .5.1 may intentionally cover only attached branch bodies.
  Acceptance: Reverify after .5.1, own the remaining implementation if needed, and prove matching nested marker groups, branch laziness, returns, actual caller/parameter/error restoration and native/fresh parity. Malformed/orphan controls retain precise diagnostics. Preserve attached controls, authorities and all other owners; declare paths/tier before edits and commit independently.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3`
  Status: `pending`
  Priority: P1 — an existing value conditional eagerly reaches an unsupported branch marker in a deferred body.
  Goal: Repair or independently verify deferred value-form if/else after statement-family repairs through the existing conditional contract.
  Dependencies: committed `.1.3.3.0.5.0`, `.1.3.3.0.5.1`, `.1.3.3.0.5.2`; matching helper prerequisite `SESSION-STARTUP-READING.87.2`.
  Reproduce: Top:: I { cb={|| return(if(true,"hit",else("miss"))) }; return(cb()) }. Both public routes fail unknown_helper/else; the admitted value-oriented function containing return(if(matches(x,/ok/),x,else("miss"))) succeeds directly and through the registered deferred bridge.
  Impact: Value conditional composition bypasses existing lazy branch semantics in the narrow deferred evaluator. _eval_call evaluates generic operands before it has an if/branch family dispatcher.
  Acceptance: Reverify remaining failure after earlier repairs, reuse governed conditional/truthiness rules, and prove exact values, once-only/lazy condition and branch effects, nested function/callback routes, returns and restoration. Preserve eager logical-helper semantics and genuinely unsupported-call diagnostics. No silent function-body extension or new record/schema field; declare bounded paths/tier and commit independently.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6`
  Status: `pending`
  Priority: P1 — residual helper metadata order is nondeterministic and can affect readiness classification.
  Goal: Diagnose and repair residual canonical helper-event ordering/overlap before dispatcher closeout.
  Dependencies: clean literal .0.2.1.3, normalization .0.4 and deferred-control .0.5 handoffs.
  Reproduce: .3.1 green/re-applied nested and body-regex sources retain identical generated code and outcomes but descriptor canonical_action_ir_events residual entries change order. CanonicalEvents::_build_canonical_action_ir_events appends unmatched events via unsorted keys %helper_event_queue. The tracked .3.1-order.pl observer records public descriptor/substitution under controlled PERL_HASH_SEED/PERL_PERTURB_KEYS; retain precise scope and classify actual overlap effects in .6.0.
  Impact: A nominal canonical event sequence is process-order dependent. Observed pre-fix body metadata can differ in readiness/unresolved classification; current healthy runtime outcomes are not proof that arbitrary overlap is harmless.
  Children: `.1.3.3.0.6.0`, `.1.3.3.0.6.1`
  Acceptance: Source-bound controlled public observations and canonical order/provenance contracts select deterministic source-order ownership, not a cosmetic sorted snapshot. Preserve exact prior records; verify overlapping/repeated helper spans, readiness and unchanged public execution, direct dependents and warranted canonical boundary.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0`
  Status: `pending`
  Goal: Freeze residual event permutation/readiness effects and normative ordering/overlap before compiler edits.
  Acceptance: Controlled process/hash-order observations locate exact queue producer/consumer source and distinguish harmless metadata permutation from classification/execution drift; select bounded paths/tier and retain evidence without normalizing it away.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1`
  Status: `pending`
  Goal: Repair and verify the diagnosed residual-event ordering/overlap mechanism.
  Dependencies: `.1.3.3.0.6.0`
  Acceptance: Actual controlled RED/GREEN source/duplicate/overlap and order/readiness/public execution checks plus direct dependents establish deterministic canonical behavior; full warranted acceptance precedes .0.3.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7`
  Status: `pending`
  Priority: P1 — unsupported nested expressions are falsely reported raw-free and language-agnostic ready.
  Goal: Diagnose and repair nested raw-expression portability telemetry without admitting infix grammar or hiding legacy source.
  Dependencies: clean normalization .0.4, deferred-control .0.5 and residual-order .0.6 handoffs; must close before .0.3.
  Reproduce: .4.0 public sources i=2; i=i+1; return(i) and i=2; if(i < 1) { return("yes") }; return("no") have raw_perl/unsupported_expression AST children, preserve host barewords, and return1/yes on native/fresh routes while reporting ready1/raw0/fallback0/unresolved0. The frozen while source similarly leaves count as a host call and fails. ADR0003 requires remaining raw source to be surfaced rather than hidden by ready.
  Source boundary: AST/Parser.pm::_parse_expr_without_chain ends at unsupported_expression; ValueExpr.pm::_lower_assignment_source_expr returns source_passthrough. CanonicalEvents.pm lines175–234 counts unmatched top-level statements, while EmitContext.pm::_build_action_rewriter_meta lines1630–1640 derives raw/ready from those counts. Exact nested traversal, canonical coverage and downstream compatibility effects need .7.0 diagnosis; no repair is guessed here.
  Impact: Descriptor portability claims can conceal raw host dependencies and semantically misleading results. This is separate from hash-order overlap .0.6 and from correcting the selected fixture .0.4.
  Children: `.1.3.3.0.7.0`, `.1.3.3.0.7.1`
  Acceptance: Exact nested condition/assignment/call/control and canonical positives distinguish true raw dependencies from authored string/comment payloads. Preserve host-source evidence, report deterministic blockers/provenance and verify shipped-spec readiness/direct dependents with warranted canonical signoff.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0`
  Status: `pending`
  Goal: Freeze the nested raw-expression readiness mechanism, policy, source locations and bounded repair ownership.
  Acceptance: Public source-bound AST/descriptor/lowering controls locate missed nested dependencies and consumer effects; select safe compiler paths/tier without expanding grammar or conflating hash-order repair.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1`
  Status: `pending`
  Goal: Repair and verify diagnosed nested raw-expression readiness reporting.
  Dependencies: `.1.3.3.0.7.0`
  Acceptance: Actual false-ready RED/GREEN, nested/quoted canonical controls, deterministic source blockers, shipped-spec readiness and direct dependents pass before dispatcher closeout.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.1`
  Status: `pending`
  Goal: Execute the unchanged selected neutral compositions through both public Perl producers after the owned repair.
  Dependencies: `.1.3.3.0`
  Acceptance: Match every selected independent order/effect/kind/failure oracle, preserve source/input identity and original probes, retain actual-object detachment falsifiers where claimed, record exact native/emitted carrier evidence and authoring costs, and close parent .1.3.3 only after complete focused acceptance.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.4`
  Status: `pending`
  Goal: Execute the same unchanged neutral compositions on supported Rust native/reconstructed/generated/emitted carriers.
  Dependencies: `.1.3.3`
  Acceptance: Declare actual carrier counts before execution, use independent callers where available, preserve native versus compatibility error channels and compare all observations to the same oracle. Existing final-assignment/substitution/resource repairs block affected claims; no inferred carrier equivalence.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.5`
  Status: `pending`
  Goal: Execute the same unchanged neutral compositions on supported Dart native/reconstructed/generated/emitted carriers.
  Dependencies: `.1.3.4`
  Acceptance: Exact independent observations and value kinds match selected oracles. Mixed-control, Unicode-order, resource and detachment owners/prerequisites remain mandatory for affected promotion. Report actual carriers and failure/recovery evidence without treating a workaround as repair.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.6`
  Status: `pending`
  Goal: Execute the unchanged neutral compositions on supported Julia native and emitted carriers.
  Dependencies: `.1.3.5`
  Acceptance: Match independent order/effect/kind/failure oracles and test actual returned-object detachment where claimed. Preserve registry/diagnostic and test-defect ownership; source-exact producers/logs distinguish historical evidence from fresh execution.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.7`
  Status: `pending`
  Goal: Execute the unchanged neutral compositions on supported PUC Lua and LuaJIT native and emitted carriers.
  Dependencies: `.1.3.6`
  Acceptance: Both ABIs independently match the same oracles and actual-object detachment controls. Preserve array/cycle/capture/provenance/resource owners and prerequisites; no ABI substitution or host-baseline promotion.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.8`
  Status: `pending`
  Goal: Reconcile selected six-runtime evidence, authoring costs, mutations, prerequisites and public claims before closing .1.3.
  Dependencies: `.1.3.3`, `.1.3.4`, `.1.3.5`, `.1.3.6`, `.1.3.7`
  Acceptance: Independently audit versioned fixtures/checkpoints/logs and actual carrier coverage, preserve original three probes and all partial/unassessed owners, align book/Knowledge/roadmap/frontier, and close the parent only through exact staged canonical proof. .1.4 then selects only evidence-backed minimized primitive gaps; no standard-format or frontend admission follows automatically.

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
| 21 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.2` | `done` | Versioned16/66/7/8 structure,432 reason-sensitive mutations/four controls and exact historical CI evolution. |
| 22 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.3` | `done` | Scoped policies bind90 anchors/632 mutations, preserve partial owners and qualify ordinary progress/public errors without global guarantees. |
| 23 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.4` | `done` | Committed closure reconciliation; exact16/90/636 authority remains unchanged. |
| 24 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.1` | `done` | Original composition sources/minimal controls and owned dispatch repair. |
| 25 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.2` | `done` | Neutral16 cases/three sources and140/16/44 governance. |
| 26 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.1` | `done` | Selected push dispatch17 sources/147 tests and actual receiver/parameter identity. |
| 27 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.0` | `done` | Tool-backed pure-function callback scope diagnosis. |
| 28 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.1` | `done` | Scope repair33 sources/279 tests with actual frame proof. |
| 29 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.2` | `done` | Committed scope reconciliation and promoted canonical receipt2516cf727. |
| 30 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.0` | `done` | 24 native/fresh emitted probes and compiler-owned bridge interface plan. |
| 31 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.1` | `done` | Registered bridge71 native/fresh sources/605 tests with actual identity/effect/error controls and canonical landing. |
| 32 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.0` | `done` | Three original observer groups and15 inputs preserved; source recovery only, no historical runtime rerun. |
| 33 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1` | `done` | Three-leg working rules and watched-source doctrine adopted; broader startup5/29 audit remains open. |
| 34 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.0` | `done` | Host quote mode consumes the signature closer; exact intervention/restoration and eight paired controls locate .3.1 repair. |
| 35 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1` | `done` | Exact quote-aware signature protection;19 healthy paired controls,729 dependents and required Phase01033/1231s; new .0.5/.0.6 remain owned. |
| 36 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.2` | `done` | Canonical committed bridge reconciliation closes .0.2.1/.0.2 after literal repair. |
| 37 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0` | `done` | Eleven public pairs locate unsupported infix; select canonical call-form successor and retain raw-readiness .0.7/audit owners. |
| 38 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1` | `done` | Exact one-loop successor, seven paired cases and narrow historical audit verified; canonical receipt governs landing. |
| 38.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0` | `done` | Exact134-input census and closed archive/restoration plan; recovery remains open. |
| 38.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1` | `done` | Exact134-input recovery/read-denied audit and canonical artifact parent signoff; bridge reconciliation next. |
| 39 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.3` | `pending` | Original minimal/normalization controls and independent dispatcher closeout. |
| 40 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.1` | `pending` | Complete neutral-case and actual semantic-mutant execution after dispatcher prerequisite. |
| 41 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0` | `done` | Twenty-source/four-AST diagnosis and660 focused tests; actual scope/error/effect proof retained. |
| 42 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1` | `pending` | Existing startup87.2 matches/regex prerequisite is next; attached branch/local-return repair follows its clean commit. |
| 42.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.2` | `pending` | Independently verify/repair deferred marker conditional groups after attached repair. |
| 42.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3` | `pending` | Independently verify/repair deferred lazy value-if dispatch after statement families. |
| 43 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0` | `pending` | Diagnose hash-order-dependent residual canonical events and readiness/overlap. |
| 44 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1` | `pending` | Repair canonical residual ordering with exact source/provenance controls. |
| 45 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0` | `pending` | Diagnose missed nested raw-expression portability dependencies after prior handoffs. |
| 46 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1` | `pending` | Repair deterministic raw-expression blockers before dispatcher closeout. |

## Decisions

- `2026-10-02`: Split durability .4 into source recovery .4.0 and explicit policy adoption/audit routing .4.1. Preserve original snapshots and distinguish recoverable instruments from newly executed runtime proof.

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

October2 `.1.2.3`: original16 sources/66 digests plus24 policy anchors remain exact;632 reason-sensitive mutations/four controls, public ordinary progress and two sorted-view oracles pass. Typed/recognition/progressive/staged/write/leaf/diagnostic guards and original objective audit pass; tool-storage39 and15 rendered claims on two pages pass. Knowledge/history/memory/doctrine/diff and exact staged canonical receipt govern policy landing; actual canonical outcome belongs in the commit body. No runtime admission or resource/security overclaim.

October1 `.1.2.2`: Structure16/66/7/8,432 reason-sensitive mutations/four controls and five directly dependent guards pass; original objective audit24/257/149/134 preserves historical runtime inputs while exact reviewed CI evolution gets three negative controls. Tool storage independently counts39 Python entrypoints, retaining three Python temporary owners and15 shell allocators. Book/Knowledge/history/memory/doctrines/diff and exact staged canonical acceptance govern landing; no runtime objective or backend promotion.

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

- `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1 - enforce three-leg claim publishing` — ADR0126 local rules/review and registered disclosure/source-identity check; wider audit remains open.

- `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.3 - freeze scoped closure policies` — scoped determinism/progress/resources/failure/ambient authority, source bindings, owner-sensitive mutations and canonical landing.

- `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.2 - freeze language closure structure` — versioned operation/scope authority, independent source/governance mutations, owned audit evolution and canonical landing.

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

- 2026-10-02: `.0.2.1.4.1` adopts the local publishing working contract and watched-source doctrine; selected source preservation remains historical and startup5/29 owns broader audit completion.

- `2026-10-02`: `.1.2.3` freezes scoped policies at16/90 with632 reason-sensitive mutations/four controls; preserve all original66 anchors, existing repair/prerequisite and proof limits. Public progress/error/key-order teaching and stale roadmap rows are corrected. Independent canonical .1.2.4 reconciliation is next.

- `2026-10-01`: `.1.2.2` freezes versioned16-authority/66-anchor operation/scope structure with432 reason-sensitive mutations/four controls, exact CI registration and historical audit reconstruction. Next .1.2.3 owns resource/failure/ambient policy; no runtime admission changes.

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
