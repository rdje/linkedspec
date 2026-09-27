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
  Status: `pending`
  Goal: Complete nested-tree readiness proof across supported public native/carrier routes after the Perl repair.
  Dependencies: `.1.1.3.1.1`
  Acceptance: Exact positive/negative values and Unicode spans, prefix/gap/span mutation sensitivity, same-engine reuse and ActionIR readiness; record exact routes and limitations without arbitrary resource or whole-format claims.

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
  Status: `pending`
  Goal: Repair generic flat(meta) constructor splicing for a scalar-held harray in Perl; coordinate broad typed aggregate owner SESSION-STARTUP-READING.17.
  Priority: P1 next; the director explicitly requests immediate repair after the current constructor commit, before remaining nesting proof. The grammar does not splice flattened values, but the defect is now the selected next slice.
  Reproduce: Top assigns meta = {"existing":1}; value = 7; return(hash(flat(meta), "added", value)) returns null, whereas changing only flat to flat_hash returns {"existing":1,"added":7} through public Get.
  Impact: Documented generic flat composition fails for a typed binding; explicit flat_hash is the bounded current control, not a fix.
  Diagnosis: Public call_spec_handler_subst reports unsupported hash for generic flat. MethodLowering lower_flat_list_value_expr's generic flat path recognizes legacy aggregate containers/value shapes but lacks the scalar-held harray branch present in flat_hash. Capture baseline, neutral semantics and all affected argument contexts before repair; do not infer all flattening routes from this one case.
  Evidence: .linkedspec-data/scratch/selfcontain11311-flat.log; discovered while expanding .1.1.3.1.1 regression. That repair's flattening compatibility control explicitly uses flat_hash.
  Acceptance: Source-located RED/GREEN native/fresh emitted proof with exact result kinds and affected scalar-held array/harray contexts; preserve task .17's broader obligation.

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
| 5 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.6` | `pending` | Director-selected immediate generic flat typed-binding repair, after clean constructor commit. |
| 6 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2` | `pending` | Resume remaining nesting routes and mutations after .1.1.6. |

## Decisions

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

- `2026-09-27`: `.1.1.3.1.1` repairs constructor value lowering exposed by the first grammar objective; `.1.1.6` owns separate generic flat composition. Remaining nesting routes and mutations follow from clean commit.

- `2026-09-27`: `.1.1.2` completes the state/callable/control/transformation/result evidence inventory. Known defects and intentionally absent features remain distinct; bounded grammar objectives `.1.1.3` follow.

- `2026-09-27`: Clean feature return activates `.1.1`, splits five bounded children and completes the first grammar/cursor/capture inventory. The campaign remains gated on language readiness and parity; `.1.1.5` owns confirmed stale general capability prose.

- `2026-07-30`: Created the task tree first from clean Rust closeout commit `4aebf906`; no other file changed
  before ownership existed.
- `2026-07-30`: ADR `0064`, the detailed program, Knowledge Map, roadmaps/live architecture, and mdBook align; full
  signoff passes without behavior change. `.0` is done and `.1+` remains unscheduled behind callable parity.
