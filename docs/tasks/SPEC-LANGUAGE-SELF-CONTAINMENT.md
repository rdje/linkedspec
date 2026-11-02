# SPEC-LANGUAGE-SELF-CONTAINMENT: Expressive `.spec` Closure and EBNF-Like Authoring Profile

## Metadata

- Tree ID: `SPEC-LANGUAGE-SELF-CONTAINMENT`
- Status: `active` / closure definition
- Roadmap lane: `.spec language evolution / expressive self-containment and alternate authoring profiles`
- Created: `2026-07-30`
- Last updated: `2026-11-01`
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
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.0 - ratify expressive spec self-containment`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.0`.

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
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.1`
  Status: `done`
  Goal: Inventory the grammar, recursion, cursor and capture foundations against campaign needs using existing canonical contracts and bounded fresh tools.
  Acceptance: Distinguish contract/admission from fresh runtime proof; cover rule entry/matching, recursion/progress, cursor transactions, source spans and gaps. Keep untested objectives unassessed and schedule their probes. Explain the maturity gate in the book without claiming EBNF equivalence or campaign activation.
  Verification tier: `focused`
  Focused checks: Existing capability/language and relevant neutral grammar/cursor/capture checkers; ledger source-path and exact evidence review; mdBook; memory; history pressure; Knowledge map; all doctrines; git diff --check.
  Canonical trigger: none for an ordinary evidence inventory and scheduling clarification; public semantic contract movement, admission or infrastructure changes require a separate canonical leaf.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.1 - inventory grammar readiness foundations`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.2`
  Status: `done`
  Goal: Extend the same ledger through scoped state, callable composition, control, transformation and typed result construction, separating host compatibility and approved missing features from defects.
  Dependencies: `.1.1.1`
  Verification tier: `focused`
  Focused checks: Existing uniform-binding, callable-signature/codeblock, logical, scalar-numeric, nested-write and map-leaves neutral tools; source-located consumer/ownership review; book render; memory; Knowledge synchronization; bounded history; all doctrines; git diff --check.
  Canonical trigger: none for a bounded evidence inventory with no runtime, public semantic contract, admission or infrastructure changes.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.2 - inventory state and computation readiness`
  Acceptance: Each of these five dimensions has current canonical owners, five-backend evidence boundaries, source-located limitations and an executable follow-up where objective composition remains unassessed.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3`
  Status: `done`
  Goal: Execute bounded representative grammar objectives against the inventory before selecting new primitives.
  Dependencies: `.1.1.2`
  Children: `.1.1.3.1`, `.1.1.3.2`, `.1.1.3.3`, `.1.1.3.4`
  Acceptance: Natural nesting, context-sensitive delimiter/indentation state, and lossless staged extraction have exact authored sources, positive/negative inputs, AST/span oracles and runtime/provenance evidence. Reuse existing document grammar and neutral fixtures where suitable; these are readiness probes, not whole-format conformance claims. Split each objective into its own commit before execution if needed.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1`
  Status: `done`
  Goal: Prove a bounded ordinary .spec nested-tree grammar with exact Unicode source spans, recursive state, complete recognition and typed rejection.
  Children: `.1.1.3.1.1`, `.1.1.3.1.2`
  Acceptance: Exact authored spans and strict rejection across the supported routes; no broad campaign readiness claim. The first trial found a Perl constructor defect; repair it in a bounded child before completing the runtime trial.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.1`
  Status: `done`
  Goal: Repair Perl hash-constructor nested shape values without losing bare binding reads when a sibling helper is lowered.
  Verification tier: `focused`
  Focused checks: RED/GREEN constructor and nesting results, native/fresh generated reuse and mutation controls; generated-source, uniform-binding, variadic-function, AST and lowering-trace direct dependents; Perl syntax and complete Phase0; book, Knowledge, memory, bounded history, all doctrines and diff hygiene.
  Canonical trigger: none for this backend-local correction to existing value semantics; escalate if public contract, generated format or cross-backend semantics must change.
  Acceptance: Authored numeric/string/null/false/container values, nested helper results and recursive starts are exact; no oracle workaround or host escape hatch. Commit repair before broadening the trial.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.1 - preserve nested hash values`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2`
  Status: `done`
  Goal: Complete nested-tree readiness proof across supported public native/carrier routes after the Perl repair.
  Dependencies: `.1.1.3.1.1`, `.1.1.6`
  Acceptance: Exact positive/negative values and Unicode spans, prefix/gap/span mutation sensitivity, same-engine reuse and ActionIR readiness; record exact routes and limitations without arbitrary resource or whole-format claims.
  Children: `.1.1.3.1.2.1`, `.1.1.3.1.2.2`, `.1.1.3.1.2.3`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.1`
  Status: `done`
  Goal: Run the unchanged nested-tree grammar and independent six-positive/seven-negative oracles through all six public native text consumers.
  Verification tier: `focused`
  Focused checks: All six runtime adapter executions against exact authored values/spans and rejection outcomes; repeated accepted inputs through one engine; unchanged grammar/oracle/adapters; book render; Knowledge, memory, bounded history, doctrines and diff hygiene.
  Canonical trigger: none for a bounded readiness probe without runtime, neutral contract, admission or infrastructure change; parent closeout remains canonical.
  Acceptance: Preserve original input/expected bytes. Report exact native routes and whether each error is typed or Display-only. Any failure gets tool-first minimized diagnosis and an owned repair before wider readiness claims.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.1 - verify native nesting readiness`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2`
  Status: `done`
  Goal: Verify supported serialized/reconstructed/generated/emitted nested-tree routes, same-engine recovery after typed rejection, readiness descriptors and prefix/gap/span mutation sensitivity.
  Dependencies: `.1.1.3.1.2.1`
  Acceptance: Split backend-sized children before implementation; retain the same authored oracles and honest carrier coverage. No blanket proof from native results.
  Children: `.1.1.3.1.2.2.1`, `.1.1.3.1.2.2.2`, `.1.1.3.1.2.2.3`, `.1.1.3.1.2.2.4`, `.1.1.3.1.2.2.5`, `.1.1.3.1.2.2.6`, `.1.1.3.1.2.2.7`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1`
  Status: `done`
  Goal: Prove Perl nested-tree carrier semantics using native Get and fresh emitted subprocess, typed rejection/recovery and prefix/gap/span mutation controls.
  Acceptance: Original grammar/cases remain unchanged; exact value kinds and Unicode spans, no partial rejection values, explicit recovery after every rejection and honest carrier/readiness coverage.
  Children: `.1.1.3.1.2.2.1.1`
  Commit: Proof and repair land together in `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1 - align emitted public entry`; final parent closure belongs to canonical reconciliation.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1`
  Status: `done`
  Goal: Restore the existing Perl public-entry leading blank/comment skip in fresh emitted Execute before completing carrier proof.
  Verification tier: `focused`
  Focused checks: Exact old-source RED/new-source GREEN; native/fresh emitted entry controls plus original nesting, typed recovery and three mutations; generated-source, strict-document, typed-source, runtime-owner/input-boundary direct dependents; required syntax and complete Phase0; book, Knowledge, memory/history, doctrines and diff hygiene.
  Canonical trigger: none for correcting this backend carrier to the existing admitted public-entry semantics without schema or contract movement; parent milestone remains canonical.
  Acceptance: One source-owned public entry rule, no duplicated child skipping, unchanged original oracle and input content, exact error boundaries. Commit repair before remaining carrier branches.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1 - align emitted public entry`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.2`
  Status: `done`
  Goal: Prove Rust nested-tree carrier semantics using native, reconstructed and generated supported routes, typed rejection/recovery and prefix/gap/span mutation controls.
  Acceptance: Original grammar/cases remain unchanged; exact value kinds and Unicode spans, no partial rejection values, explicit recovery after every rejection and honest carrier/readiness coverage.
  Dependencies: `.1.1.3.1.2.2.1.1` (verified Perl proof; parent status closes at canonical reconciliation).
  Verification tier: `focused`
  Focused checks: New Rust native/reconstructed/generated-plan/emitted nesting regression; strict-document and leading-trivia consumers; published locked offline Cargo preparation, actual emitted-child exit status and counts, unchanged grammar/cases; book, Knowledge, memory/history, doctrines and diff hygiene.
  Canonical trigger: none for a bounded backend regression without runtime, schema, contract or admission change; parent closure remains canonical.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.2 - verify Rust nesting carriers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.3`
  Status: `done`
  Goal: Prove Dart nested-tree carrier semantics using native, reconstructed and independently emitted supported routes, typed rejection/recovery and prefix/gap/span mutation controls.
  Acceptance: Original grammar/cases remain unchanged; exact value kinds and Unicode spans, no partial rejection values, explicit recovery after every rejection and honest carrier/readiness coverage.
  Dependencies: `.1.1.3.1.2.2.2`
  Verification tier: `focused`
  Focused checks: New Dart native/reconstructed/generated-plan/emitted nesting regression, strict-document and source-emitter direct dependents, strict changed-file/child analysis plus package-wide diagnostic census, exact child status/report, unchanged fixtures, book, Knowledge, memory/history, doctrines and diff hygiene.
  Canonical trigger: none for bounded backend evidence without runtime/schema/contract/admission change; parent closure remains canonical.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.3 - verify Dart nesting carriers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.4`
  Status: `done`
  Goal: Prove Julia nested-tree carrier semantics using native, reconstructed/generated-plan and emitted supported routes, typed rejection/recovery and prefix/gap/span mutation controls.
  Acceptance: Original grammar/cases remain unchanged; exact value kinds and Unicode spans, no partial rejection values, explicit recovery after every rejection and honest carrier/readiness coverage.
  Dependencies: `.1.1.3.1.2.2.3`
  Verification tier: `focused`
  Focused checks: Extend existing Julia source-emitter tests with nesting carriers/mutations, unchanged strict-document compatibility, exact child status/report and storage oracle; unchanged fixture/manifest, book, Knowledge, memory/history, doctrines and diff hygiene.
  Canonical trigger: none for bounded backend evidence without runtime/schema/contract/admission or storage mechanism changes; parent closure remains canonical.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.4 - verify Julia nesting carriers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.5`
  Status: `done`
  Goal: Prove Lua nested-tree carrier semantics using both ABIs across native, reconstructed/generated-plan and emitted supported routes, typed rejection/recovery and prefix/gap/span mutation controls.
  Acceptance: Original grammar/cases remain unchanged; exact value kinds and Unicode spans, no partial rejection values, explicit recovery after every rejection and honest carrier/readiness coverage.
  Dependencies: `.1.1.3.1.2.2.4`
  Verification tier: `focused`
  Focused checks: Extend existing Lua v2 generated-source consumer with nesting native/reconstructed/generated/emitted routes on PUC Lua and LuaJIT; strict-document compatibility, exact child status/stdout/stderr and cleanup, storage oracle, unchanged fixture/runtime, book/Knowledge/memory/history/doctrines/diff checks.
  Canonical trigger: none for bounded carrier evidence without runtime/schema/contract/admission/storage mechanism change; parent reconciliation remains canonical.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.5 - verify Lua nesting carriers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.5`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.6`
  Status: `done`
  Goal: Repair Lua storage verification so a failed legacy-residue census cannot print PASS.
  Acceptance: Enumerate only the relevant root entries without entering unrelated directories; preserve exact Lua-owned-prefix residue rejection and other-volume builder rejection. Propagate actual census failures. Prove empty/matching/error cases with repository-local controlled fixtures and real dual-ABI storage proof, preserve all existing boundaries, and use canonical infrastructure verification. No deletion or permission changes in other repositories or shared data.
  Dependencies: `.1.1.3.1.2.2.5` clean handoff.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.6 - reject incomplete storage censuses`.
  Verification tier: `canonical`
  Focused checks: Controlled empty/residue/enumeration-error/symlink/prefix/permission-boundary cases, old conditional RED, new scanner GREEN, exact real dual-ABI storage proof and unchanged builder rejection; exact24-plus3 Perl allocator audit and staged storage proof; reviewed mutation71/selector70 public inventories and unchanged semantic controls; syntax, book, Knowledge, memory/history/doctrines/diff checks.
  Canonical trigger: Storage verification mechanism changes; stage the exact candidate and require tools/run_ci_local.sh receipt before landing.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.6`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.7`
  Status: `done`
  Goal: Eliminate uninitialized entry-position warnings in Perl emitted parsers while preserving existing no-entry and matched-entry values.
  Acceptance: Review the entry helper contracts and all related lowering sites; preserve existing absent/null/empty distinctions, root/trivia offsets, Unicode spans, nested matched entries and typed source errors. Add meaningful warning-sensitive native/fresh emitted regression and RED/GREEN proof; no blanket warning suppression, expected-value workaround or public contract expansion. Reuse an existing managed test owner. Commit before parent reconciliation.
  Dependencies: `.1.1.3.1.2.2.6`
  Verification tier: `focused`
  Focused checks: Public lowering/emitted-source diagnosis, warning-sensitive entry-boundary RED/GREEN, typed source/capture/mark direct dependents, generated-source and nesting regressions, complete Phase0 for action rewriting, syntax, book/Knowledge/memory/history/doctrines/diff checks.
  Canonical trigger: none for a bounded Perl lowering correction preserving existing values and contracts; escalate if review requires a contract, schema or infrastructure change. Parent reconciliation remains canonical.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.7 - preserve quiet entry boundaries`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.7`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.3`
  Status: `done`
  Goal: Reconcile nested-tree readiness evidence, authoring costs and limitations, and close its parents through canonical milestone proof.
  Dependencies: `.1.1.3.1.2.2`
  Acceptance: Source-located native/carrier/mutation ledger and book agree; canonical receipt governs closure before context-dependent objective .1.1.3.2.
  Verification tier: `canonical`
  Focused checks: Original fixture and committed evidence audit; source-located route/readiness/mutation/recovery matrix; book render, Knowledge synchronization, bounded history, memory, diagnosis, cadence and all doctrines.
  Canonical trigger: Milestone and parent closeout requires tools/run_ci_local.sh on the exact staged candidate.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.3 - reconcile bounded nesting readiness`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2`
  Status: `done`
  Goal: Probe context-dependent matching with nested opening/closing names or indentation state using ordinary .spec, exact rejection and restoration controls.
  Dependencies: `.1.1.3.1`
  Acceptance: Source-located, bounded native/carrier evidence establishes whether existing explicit state and comparisons express the objective clearly; record and schedule any minimal reusable gap without claiming XML/YAML support.
  Children: `.1.1.3.2.1`, `.1.1.3.2.2`, `.1.1.3.2.3`, `.1.1.3.2.4`, `.1.1.3.2.5`, `.1.1.3.2.6`, `.1.1.3.2.7`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.1`
  Status: `done`
  Goal: Author the independent context-name grammar/oracles and verify Perl native/fresh emitted scope restoration, exact trees/spans, typed rejection/recovery and targeted mutations.
  Verification tier: `focused`
  Focused checks: LinkedSpec::Get and return_descriptor probes; exact independent native/fresh emitted oracles, status/reuse checks and comparison/state/span mutants; existing nesting and typed-source/callable/generation direct dependents; syntax, book, Knowledge, memory, bounded histories, doctrines and diff hygiene.
  Canonical trigger: None for a bounded fixture/test proof of existing Perl semantics; escalate for runtime contract or infrastructure movement. Parent .1.1.3.2.7 owns canonical reconciliation.
  Acceptance: Case-sensitive matching names, same/different nested names and siblings restore parent state; all rejects carry the intended status with no result and immediate valid reuse. Original nesting expectations unchanged; authoring costs and untested backend boundaries explicit.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.1 - verify scoped closing-name comparison`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.2`
  Status: `done`
  Goal: Verify the unchanged context-name grammar and independent oracles through all six documented public native text adapters, preserving exact status-projection limits.
  Dependencies: `.1.1.3.2.1`
  Acceptance: Exact typed AST/spans and each authored rejection status; repeat accepted inputs and preserve original fixture bytes. No same-engine post-rejection claim from exit-on-error adapters.
  Verification tier: `focused`
  Focused checks: All six context-name native runs against11/17 independent oracles and22 repeated accepts; all six default nesting runs as verifier compatibility proof; exact source/product before-after hashes, option/syntax controls, book, Knowledge, memory, histories, doctrines and diff hygiene.
  Canonical trigger: None for bounded public-native evidence using existing interfaces; parent .1.1.3.2.7 owns canonical closeout. Escalate if an actual contract/infrastructure change becomes necessary.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.2 - verify native closing-name parity`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.3`
  Status: `done`
  Goal: Verify Rust context-name reconstructed/generated/v2/emitted routes, exact typed rejection/recovery and grammar mutations.
  Dependencies: `.1.1.3.2.2`
  Acceptance: Use unchanged shared oracles and distinguish retained-engine restoration from per-call isolation; require fresh child exit success and exact completion.
  Verification tier: `focused`
  Focused checks: Six context routes with90 original calls/three mutants each and136 retained-engine recovery transitions; original Rust nesting carrier tests; fresh child actual success/four executed modules per fixture; leading-trivia and strict-document dependents; changed-file formatting, book, Knowledge, memory, histories, doctrines and diff hygiene.
  Canonical trigger: None for bounded test/carrier proof of existing semantics; .1.1.3.2.7 owns canonical reconciliation. Split and escalate if production contract or infrastructure repair is required.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.3 - verify Rust closing-name carriers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.4`
  Status: `done`
  Goal: Verify Dart context-name reconstructed/generated/v2/emitted routes, exact typed rejection/recovery and grammar mutations.
  Dependencies: `.1.1.3.2.3`
  Acceptance: Same authored oracles, explicit retained/per-call distinction and strict fresh emitted-package validation; keep known SDK issues separately owned.
  Verification tier: `focused`
  Focused checks: Six context routes with90 calls/three mutations each and136 retained recoveries; original nesting routes; actual offline preparation/fatal analysis/fresh emitted execution and exact reports; emitter/document dependents; changed-file analysis/format, book, Knowledge, memory, histories, doctrines and diff hygiene.
  Canonical trigger: None for bounded test/carrier proof; parent .1.1.3.2.7 owns canonical reconciliation. Known whole-package SDK deprecations remain separately owned by DART-STARTUP-READING.2.25.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.4 - verify Dart closing-name carriers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.5`
  Status: `done`
  Goal: Verify Julia context-name reconstructed/v2/emitted routes and context/recovery mutations using existing managed emitter storage.
  Dependencies: `.1.1.3.2.4`
  Acceptance: Exact JSON kinds/spans/statuses; retained/per-call distinction; latest-world fresh child binding access, exact report and real exit success.
  Verification tier: `focused`
  Focused checks: Five context routes with90 calls/three mutations each and68 recoveries on two retained engines; original nesting and full existing emitter/document files; real emitted child exit success/exact report/cleanup; storage inventory, book, Knowledge, memory, histories, doctrines and diff hygiene.
  Canonical trigger: None for bounded fixture/carrier tests; parent .1.1.3.2.7 owns exact staged canonical reconciliation. Escalate any production or infrastructure contract movement separately.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.5 - verify Julia closing-name carriers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.5`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.6`
  Status: `done`
  Goal: Verify context-name carriers independently under PUC Lua and LuaJIT with exact typed statuses and state restoration.
  Dependencies: `.1.1.3.2.5`
  Acceptance: Exact original and mutant checks on native/reconstructed/v2/emitted routes; existing managed owner, real child status/empty stderr/exact report and cleanup. No malformed-regex-path claim.
  Verification tier: `focused`
  Focused checks: Five context routes per ABI, each90 calls/three mutants with68 recoveries on two retained engines; original v2/nesting and strict-document proof under PUC Lua and LuaJIT; real storage19 census, book, Knowledge, memory, histories, doctrines and diff hygiene.
  Canonical trigger: None for bounded test/carrier proof. Parent .1.1.3.2.7 owns canonical closeout; known malformed-regex .2.3 remains outside this slice.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.6 - verify Lua closing-name carriers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.6`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.7`
  Status: `done`
  Goal: Reconcile context-dependent grammar evidence, rejection diagnostics and authoring costs through canonical parent closeout.
  Dependencies: `.1.1.3.2.1`, `.1.1.3.2.2`, `.1.1.3.2.3`, `.1.1.3.2.4`, `.1.1.3.2.5`, `.1.1.3.2.6`
  Acceptance: Preserve exact runtime/carrier/mutation scope and canonical receipt; close only bounded context matching before lossless objective .1.1.3.3. No format campaign admission.
  Verification tier: `canonical`
  Focused checks: Audit original source/oracles, all context source-hash references and retained logs; reconcile route/recovery/mutation table and prior harness repair; book, Knowledge, memory, histories, doctrines and diff hygiene.
  Canonical trigger: Milestone and bounded parent closeout requires tools/run_ci_local.sh on the exact staged candidate; landing receipt and commit body preserve actual result.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.7 - reconcile bounded context-name readiness`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.2.7`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3`
  Status: `done`
  Goal: Probe lossless segmentation and bounded child parsing with exact source provenance and caller-authorized dispatch.
  Dependencies: `.1.1.3.2`
  Children: `.1.1.3.3.1`, `.1.1.3.3.2`, `.1.1.3.3.3`, `.1.1.3.3.4`, `.1.1.3.3.5`
  Acceptance: Every original scalar belongs to a tested segment; child bounds and composed spans are exact; no host parsing escape or ambient loading is introduced. Keep private carrier and public authoring boundaries explicit.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.1`
  Status: `done`
  Goal: Resolve the public/private authority boundary and define independently checkable lossless composition slices.
  Verification tier: `focused`
  Focused checks: Existing typed-source, inter-match-gap, progressive-span and staged-AST neutral checkers; exact authority/consumer path audit; mdBook rendering; Knowledge/memory/history checks; all doctrines; git diff --check.
  Canonical trigger: none for an ordinary evidence/plan slice; no capability, runtime, contract, generated format, gate or infrastructure change. Parent closeout remains canonical under .3.5.
  Acceptance: Bind the public gap and exact parse_job assignment authorities, distinguish private dispatch_span, identify existing defect owners and select a finite corpus with explicit reconstruction, child-language, provenance and authority oracles. Do not infer runtime composition proof from neutral checks.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.1 - scope lossless child readiness proof`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.2`
  Status: `done`
  Goal: Prove public lossless segment authoring through Perl native and freshly emitted execution.
  Dependencies: `.1.1.3.3.1`
  Verification tier: `focused`
  Focused checks: LinkedSpec::Get and return_descriptor probe of the exact new grammar; existing t/nested_tree_readiness.t extended through native/fresh emitted sequences and mutation controls; direct-dependent gap/generated-entry suites; exact book include/output render; neutral gap and staged checkers; Knowledge/memory/history and all doctrines; git diff --check.
  Canonical trigger: none for bounded authored fixture and regression proof; any production/contract/infrastructure defect receives a separately owned slice, and .3.5 remains canonical.
  Acceptance: Commit a portable grammar and independently authored exact cases covering empty/no-match input, prefix/interstitial/tail, adjacent matches, Unicode scalars, CRLF and malformed candidate text retained as gaps. Assert ordered spans cover every input scalar exactly once and reconstruct exact input; preserve empty gaps and selected slot identity. Exercise output/spans and grammar mutants, repeat retained-parser calls, and execute the same source in the book. This is segmentation, not strict whole-document validation.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.2 - verify lossless Perl segmentation`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.3`
  Status: `done`
  Goal: Compose public parse_job markers with the lossless parent and an actual precompiled child .spec in Perl.
  Dependencies: `.1.1.3.3.2`
  Verification tier: `focused`
  Focused checks: LinkedSpec::Get/return_descriptor and emitted source for parent/actual child; original thirteen-case segmentation oracle after enrichment; exact child requests and local/global spans, no-seed and authority denials, typed child rejection/recovery and bounded-call controls; native/fresh emitted parents and children; staged/gap/readiness direct dependents, exact book source/render, Knowledge/memory/history/doctrines and git diff --check.
  Canonical trigger: none for a bounded composition fixture and consumer. Any implementation/authority-contract defect receives a separately owned repair; final .3.5 remains canonical.
  Acceptance: The host supplies only precompiled authority and bounded request plumbing; child .spec owns recognition and result construction. Prove exact selected child text, Unicode local/global provenance, parent reconstruction after enrichment, child rejection and recovery, missing/unapproved authority, and no implicit loading. Cover native and independently emitted parent/child routes. Determine whether any known staged/progressive defect is on the selected path before claiming bounds; split necessary repairs under their existing owners. Source-bound parse_job operands remain exactly the admitted forms, with no invented gap_text/Span public operand.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.3 - verify actual Perl child composition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4`
  Status: `done`
  Goal: Extend the unchanged lossless and child-composition corpus to every required native and supported carrier route.
  Dependencies: `.1.1.3.3.3`
  Children: `.1.1.3.3.4.1`, `.1.1.3.3.4.2`, `.1.1.3.3.4.3`, `.1.1.3.3.4.4`
  Acceptance: Split into backend-sized leaves before implementation. Run Rust, Dart, Julia, PUC Lua and LuaJIT against the original authored oracle; distinguish native, reconstructed, generated and independently emitted carriers, retained recovery and per-call isolation. Preserve authority-negative and provenance mutation controls; do not convert a private dispatch carrier into public API evidence.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.1`
  Status: `done`
  Goal: Prove exact lossless segmentation and actual staged child composition through Rust native and supported carriers.
  Dependencies: `.1.1.3.3.3`
  Verification tier: `focused`
  Focused checks: Rust readiness public parser/compiler validation, native/reconstructed/generated/serialized/fresh emitted parent and actual child; unchanged segment/child corpora and recognition/provenance/bounds mutants; authority denials and selected budgets, exact error codes, recovery versus per-call isolation; direct-dependent staged/gap consumers, neutral staged contract, exact book/render, storage allocation regression, Knowledge/memory/history/doctrines and git diff --check.
  Canonical trigger: none for bounded authored fixtures and consumer extensions reusing existing storage owners. Any runtime/contract/storage defect is split before repair; .3.5 remains the canonical milestone.
  Acceptance: Retain independent scalar slicing/classification/reconstruction. Actual precompiled .spec owns child recognition and ASTs; caller only supplies authority and span projection. Cover six supported matched parent/child carriers, repeat original cases, preserve local/global provenance and original item text, and distinguish retained recovery from rebuilt per-call isolation. Use explicit step/call controls without claiming arbitrary recursion or MAX-counter safety. Existing startup .73/.74/.75/.78 remain owned; small direct-span children avoid conflicting destinations, returned markers and extreme arithmetic. No submodule internals or dependency changes.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.1 - verify Rust lossless child carriers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.2`
  Status: `done`
  Goal: Prove the same lossless and actual-child corpus through Dart native and supported reconstructed/generated/emitted carriers.
  Dependencies: `.1.1.3.3.4.1`
  Verification tier: `focused`
  Focused checks: Public Dart parser/compiler validation; six matched native/SpecFile reconstructed/generated/v2/fresh emitted parent-child carriers, unchanged original13 and child4/15 corpora, seven mutants, source slices/provenance, exact failure codes, selected budgets and retained/per-call distinction; detached outcome sink records; direct-dependent readiness/staged/gap/emitter tests; fatal main/fresh-package analysis, storage, neutral staged, exact book/render, Knowledge/memory/history/doctrines and git diff --check.
  Canonical trigger: none for bounded fixture consumers reusing existing allocation. Split any required runtime/storage/contract repair before changing it; .3.5 remains canonical.
  Acceptance: Preserve the authored oracle, recognition/provenance/bounds mutants, exact denials and retained/per-call distinction. Review Dart staged provenance/resource defect cards before activation, use strict package analysis and existing storage owners, and split necessary repairs.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.2 - verify Dart lossless child carriers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.3`
  Status: `done`
  Goal: Prove the same lossless and actual-child corpus through Julia native and supported reconstructed/generated/emitted carriers.
  Dependencies: `.1.1.3.3.4.2`
  Verification tier: `focused`
  Focused checks: Julia public parser/compiler validation and five supported matched native/reconstructed/generated/emitted parent-child routes; unchanged original13 and child4/15, seven mutants, scalar slicing/provenance, exact typed staged failures, selected budgets and retained/per-call distinction; actual returned-object mutation plus deliberately aliased control; emitter/readiness/staged/gap/document dependents, existing storage owner/cleanup, neutral staged, book source/render, Knowledge/memory/history/doctrines and git diff --check.
  Canonical trigger: none for bounded authored test consumers reusing current allocation and host launcher. Any runtime/storage/contract repair is split before change; .3.5 remains canonical.
  Acceptance: Preserve exact oracles, mutants, authority denials and retained/per-call distinction. Review Julia staged registry/diagnostic/result-isolation cards, verify fresh emitted hosts, and split any repair dependencies.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.3 - verify Julia lossless child carriers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.4`
  Status: `done`
  Goal: Prove the same lossless and actual-child corpus through shared Lua carriers on PUC Lua and LuaJIT.
  Dependencies: `.1.1.3.3.4.3`
  Acceptance: Run both ABIs with exact original oracles, mutants, authority controls, provenance and supported fresh carriers. Review current shared staged resource/provenance cards and keep both runtime rows explicit. Parent .3.4 closes only during canonical reconciliation .3.5.
  Verification tier: `focused`
  Focused checks: Shared Lua five matched public native/reconstructed/generated/emitted routes on each ABI, unchanged original13 and child4/15, seven mutants, exact scalar/provenance/selected accounting/authority controls, actual-returned isolation plus aliased control; existing v2/nesting/context/staged/gap/document tests, real storage, neutral staged and exact book source; Knowledge/memory/history/doctrines and diff checks.
  Canonical trigger: none for bounded consumer-only proof reusing the existing allocation owner; canonical .3.5 owns parent closure. Split runtime, infrastructure or public-contract repairs before change.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.4 - verify dual-ABI Lua lossless child carriers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.4.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5`
  Status: `done`
  Goal: Reconcile bounded lossless/child readiness, authoring costs, known limits and exact canonical milestone evidence.
  Dependencies: `.1.1.3.3.4`
  Acceptance: Audit source/checkpoint identities and route-level results, align ledger/Knowledge/book/roadmaps/frontier, retain open defect owners and unassessed objectives, and run exact staged canonical CI before closing .1.1.3.3. No format-campaign admission or public/private API expansion.
  Verification tier: `canonical`
  Focused checks: Audit all seven checkpoint source/log identities against producing commits and current sources, independent original oracles and exact route/reuse/mutation ledger; book render/source assertions, Knowledge/memory/history/doctrines and diff hygiene.
  Canonical trigger: Milestone and parent closeout require tools/run_ci_local.sh on the exact fully staged candidate, with a receipt required for landing.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5 - reconcile bounded lossless child readiness`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.3.5`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.4`
  Status: `done`
  Goal: Reconcile the three bounded objective results and authoring costs for gap selection under `.1.1.4`.
  Dependencies: `.1.1.3.1`, `.1.1.3.2`, `.1.1.3.3`
  Verification tier: `canonical`
  Focused checks: Historical checkpoint/source/log audit for all three objectives, independent authored-oracle spans and corpus enumeration, corrupted evidence controls, exact book table/source assertions and rendering; Knowledge/memory/history/doctrines and diff hygiene.
  Canonical trigger: Close representative-objective parent .1.1.3 after exact staged tools/run_ci_local.sh acceptance. No new objective or whole-format admission.
  Acceptance: Preserve exact runtime/carrier coverage, limitations, mutations and repair owners; require fresh proof before promoting any objective and keep whole-format campaign readiness pending.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.4 - reconcile three bounded language objectives`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.4`
  Status: `done`
  Goal: Reconcile the finite inventory and representative evidence into an owned gap list for `.1.2` and `.1.4`.
  Dependencies: `.1.1.3`
  Verification tier: `focused`
  Focused checks: Existing three-objective source/log/oracle audit; exact nine-area authority and repair-owner review, finite-list link/owner checks and rendered book review; Knowledge/memory/history/doctrines and git diff --check.
  Canonical trigger: none for a bounded classification and scheduling ledger preserving existing contracts and admission; .1.1.5 retains canonical manifest/checker repair and inventory-parent closeout.
  Acceptance: Every observed gap is implemented, partial, missing, compatibility-only, backend-host or deliberately forbidden; untested objectives remain separately unassessed. New capability proposals identify reusable semantics and portable proof, and existing defects retain their original repair owners and priority. Do not imply an exhaustive proof of every possible grammar.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.4 - classify finite language readiness gaps`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.5`
  Status: `done`
  Goal: Repair the stale general capability description of removed global parse-mode controls and guard recurrence.
  Dependencies: `.1.1.4`
  Verification tier: `canonical`
  Focused checks: Existing capability checker/specific cursor/root authorities reproduce the stale description; old-checker RED/new-checker reason-sensitive mutations, unchanged census/IDs/states, generated-source/language and root/cursor direct dependents, public book render, source identity; Knowledge/memory/history/doctrines and diff hygiene.
  Canonical trigger: Capability/checker governance repair and inventory-parent .1.1 closeout require exact fully staged tools/run_ci_local.sh acceptance before landing.
  Acceptance: Preserve stable capability identity where required, reconcile its description to explicit entry selection and intrinsic family cursor policy, and add a reason-sensitive regression that rejects the stale claim. Verify dependent capability/generated-source consumers and public teaching; use canonical tier for checker/contract admission movement.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.5 - guard entry and cursor capability description`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.5`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.6`
  Status: `done`
  Goal: Repair generic flat(meta) constructor splicing for a scalar-held harray in Perl; coordinate broad typed aggregate owner SESSION-STARTUP-READING.17.
  Acceptance: Source-located RED/GREEN native/fresh emitted proof with exact result kinds and affected scalar-held array/harray contexts; preserve task .17's broader obligation.
  Verification tier: `focused`
  Focused checks: Public Get/substitution RED/GREEN against explicit helper controls; exact native/fresh emitted result kinds, reuse, ordinary nested-value and snapshot controls; generated-source, uniform-binding, variadic, AST and lowering-trace suites; Perl syntax and complete Phase0; exact book example/rendering, Knowledge, history, memory, doctrines and diff hygiene.
  Canonical trigger: none for a backend-local correction to existing scalar-held container semantics; escalate for neutral contract, generated-format or cross-backend semantic movement.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.6 - flatten bound container values`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.6`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2`
  Status: `done`
  Goal: Define the problem-domain closure boundary, determinism/resource model, state/scoping rules, and explicit
    environmental non-authority.
  Acceptance: Normative contracts answer what a `.spec` may compute, observe, mutate, return, and never access,
    including recursion/iteration limits, failure behavior, and host-boundary inputs/results.
  Dependencies: `.1.1`
  Children: `.1.2.1`, `.1.2.2`, `.1.2.3`, `.1.2.4`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.1`
  Status: `done`
  Goal: Design a source-located closure contract matrix and bounded freeze plan before editing normative authority.
  Dependencies: `.1.1`
  Acceptance: Retrieve exact existing authorities for compute/observe/mutate/return/non-authority, callable/rule state and progress/resource/failure boundaries. Separate normative target, current admitted behavior, known partial repairs and unassessed requirements. Identify deterministic input/output and host responsibilities; do not infer universal safety or silently choose new numerical limits. Own any genuine contract ambiguity before freeze.
  Verification tier: `focused`
  Focused checks: Exact authority identities/pointers and repair-owner metadata; unchanged executable authorities and original objective audit; directly affected public/neutral guards, rendered book, Knowledge, memory, bounded histories, doctrines and diff hygiene.
  Canonical trigger: none for a bounded design leaf; .1.2.2/.1.2.3 own normative artifacts/checkers and .1.2.4 owns canonical parent closeout.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.1 - design language closure matrix`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.2`
  Status: `done`
  Goal: Freeze the grammar/cursor/capture/state/callable/control/transformation/result closure boundary on the existing semantic core.
  Dependencies: `.1.2.1`
  Acceptance: One versioned neutral authority describes included/excluded operations, distinct scopes, recognition versus user-state effects, typed results and host-boundary inputs. Bind existing authority identities/proof owners, preserve compatibility exclusions and partial status, and add mutation-sensitive structural validation. Use canonical tier for contract/checker movement; no runtime semantics or profile-only mechanism.
  Verification tier: `canonical`
  Focused checks: Closed schema/relationships, exact source-bound semantic anchors/proof owners, reason-sensitive destructive mutations and unrelated-error control; unchanged original authority/objective audit, direct-dependent contracts, Python storage census, rendered book, histories, Knowledge, memory, doctrines and diff hygiene.
  Canonical trigger: New versioned neutral contract, independent checker and exact-once canonical registration; stage the complete candidate before receipt-bound local CI.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.2 - freeze language closure structure`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.3`
  Status: `done`
  Goal: Freeze explicit determinism, progress/resource, failure and ambient non-authority policies without inventing guarantees.
  Dependencies: `.1.2.2`
  Acceptance: State observed versus target limits, regex-substrate responsibilities, typed failure/publication effects and caller authorization. Existing resource repairs retain owners and precede dependent guarantees; invalid/adversarial cases and unassessed performance have explicit proof needs. Do not assign unsupported global limits or equate design exclusions with a security sandbox. Use canonical tier for normative movement.
  Verification tier: `canonical`
  Focused checks: Reason-sensitive policy mutations and adversarial proof obligations; current public ordinary-progress probe, inherited source policies and unchanged original objective/authority evidence; directly affected guards, rendered book, Knowledge, histories, memory, doctrines and diff hygiene.
  Canonical trigger: Normative determinism/resource/failure/ambient policy movement and checker expansion; stage the complete candidate before exact receipt-bound local CI.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.3 - freeze scoped closure policies`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.4`
  Status: `done`
  Goal: Reconcile and close the closure-definition parent before neutral composed objectives.
  Dependencies: `.1.2.3`
  Acceptance: Independently check matrix/authority/validator and book alignment, preserved original contracts, exact partial/unassessed routing and no runtime/admission overclaim. Exact staged canonical acceptance closes .1.2; .1.3 must be split before fixture/checker implementation.
  Verification tier: `canonical`
  Focused checks: Independent source/register/matrix/reference/owner and rendered-book reconciliation with reason-sensitive destructive controls; original objective audit and unchanged core authorities; direct closure guard, storage census as affected, Knowledge/history/memory/doctrines and diff hygiene.
  Canonical trigger: Closure-definition parent closeout and normative reconciliation metadata; stage the complete candidate before exact receipt-bound local CI.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.4 - reconcile language closure definition`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.2.4`.

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
  Verification tier: `focused`
  Focused checks: Exact selection-to-parent-dimension/authority/repair-owner review and explicit independent positive/negative/effect/kind/failure oracles; original objective audit, selected existing neutral guards, public feasibility probes if needed, rendered book, Knowledge/history/memory/doctrines and diff hygiene.
  Canonical trigger: none for bounded requirement/oracle selection with unchanged semantics, fixtures, admission and CI; .1.3.2 owns subsequent normative neutral fixture/checker movement and .1.3.8 owns composed parent closeout.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.2`
  Status: `done`
  Goal: Implement selected neutral fixtures, independent expected observations and a reason-sensitive mutation checker from .1.3.1's approved bounded selection.
  Dependencies: `.1.3.1`
  Acceptance: Version input/oracle identities, prove each claimed semantic dimension through positive/negative/effect/kind controls and unrelated-error rejection, and preserve original probes. Select exact owned paths before creation. This leaf establishes neutral governance, not runtime execution or whole-format admission; normative fixture/checker movement requires canonical proof.
  Verification tier: `canonical`
  Focused checks: Independent16-case shape/event/value-kind/failure models, exact source/case/owner/foundation register, reason-sensitive structural/observation mutations and unrelated-error rejection; native pilot source identity only, no new execution claim. Original objective audit including narrow new CI controls, selected closure/callable/diagnostic/write/leaf guards, new tool storage inventory/route, rendered book, Knowledge/history/memory/doctrines and diff hygiene.
  Canonical trigger: Normative neutral oracle/checker and recurring CI/tool-storage integration; require exact fully staged candidate canonical receipt before landing.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.2`.

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
  Goal: Execute existing bare-binding push inside deferred codeblocks with copy-on-write publication, real receiver identity and separate temporary parameter slots.
  Dependencies: `.1.3.2`; existing uniform-binding, callable and map-leaves authorities; original public .1.3.1 failure controls.
  Acceptance: Native and fresh independently loaded emitted carriers cover selected push success, absent/null targets, once-only argument effects, post-argument target snapshots, detached prior results, wrong-kind/unknown calls, rule precedence, nested parameter restoration and alias-sensitive active receiver rejection. A same-named temporary parameter must remain writable without touching the active caller receiver. Retain raw0/fallback0/unresolved0 where supported; preserve existing callable/binding/mutation suites and exact original authorities. The full normalization source must remain honestly blocked at its next unrepaired dispatch.
  Verification tier: `canonical`
  Focused checks: New native/emitted push matrix; existing callable-codeblock, uniform-binding and map-leaves Perl contracts; neutral composed/closure/callable/binding/mutation checkers; historical objective audit; mdBook/rendered claims, Knowledge Map, history pressure, memory and diff hygiene.
  Canonical trigger: Private runtime invocation-context and public generated-handler emission movement; stage the complete candidate before exact receipt-bound local CI.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2`
  Status: `done`
  Goal: Bridge registered pure-function calls from deferred bodies through the existing compiler function lowering, with fresh local state and unchanged static precedence.
  Dependencies: `.1.3.3.0.1`; exact function/variadic/contextual-codeblock contracts; startup32 remains a separate known limitation before dependent claims.
  Acceptance: Declare the compiled registry/context interface and exact owned paths before implementation. Reuse central function-body lowering; do not create a partial second function evaluator or store closures/environments in codeblock records. Cover once-only ordered caller arguments, signatures/rest/final-codeblock forms, fresh locals, nested calls, genuine unknown calls, recursion and native/emitted equivalence. Preserve startup19/32/35/87 ownership and report any newly implicated prerequisite.
  Children: `.1.3.3.0.2.0`, `.1.3.3.0.2.1`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0`
  Status: `done`
  Goal: Give function-invoked codeblocks the function's fresh working frame, excluding unrelated rule-caller references and retaining working slots across callbacks within that invocation.
  Children: `.1.3.3.0.2.0.0`, `.1.3.3.0.2.0.1`, `.1.3.3.0.2.0.2`
  Acceptance: Native/fresh emitted read/write, explicit-local and parameter controls; callback-created slots persist within one fresh function invocation and reset between invocations; nested calls and copied codeblock parameter restoration remain correct; rule-invoked callbacks retain live caller bindings. Minimize all additional failures with Toolbox before expanding the repair.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.0`
  Status: `done`
  Goal: Freeze the newly established pure-function callback capture diagnosis and bounded repair plan without runtime changes.
  Verification tier: `focused`
  Focused checks: Reverify three exact public Get controls and source binding inventory; independent fresh emitted controls; immutable source/authority review; mdBook/rendered claim, Knowledge Map, history pressure, memory and diff hygiene.
  Canonical trigger: none for bounded diagnosis/documentation with unchanged runtime, authorities, admission and CI.
  Acceptance: Exact sources, actual/expected values, compiler metadata, producer/source hashes and generated mechanism survive in the checkpoint. Schedule and own the P1 fix, preserve all distinct defects, commit cleanly and activate .0.2.0.1 next.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.1`
  Status: `done`
  Goal: Repair the established function callback scope leak with a fresh invocation-local working frame and native/fresh emitted regression controls.
  Dependencies: `.1.3.3.0.2.0.0`; admitted pure-function, callable, binding and parameter scopes.
  Acceptance: Select exact implementation/test paths and verification tier before edits. Exclude caller slots, preserve actual function-local/parameter identities and callback slot persistence, reset between function invocations, retain rule callbacks and all original seventeen push controls. Reject alias/snapshot shortcuts and accidental closure storage; inspect any newly implicated prerequisite before proceeding.
  Verification tier: `focused`
  Focused checks: Toolbox RED/GREEN native/fresh emitted scope read/write/local/parameter/persistence/reset/nested/with/private-name controls; actual frame/reference identity and original seventeen push cases; callable, variadic function, binding and map-mutation direct dependents; Perl syntax and Phase0 for MethodLowering; rendered book, unchanged-input audit, Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for internal generated handler lexical/binding repair with unchanged format-v2, public contracts, admission, CI, hooks and storage. Escalate before landing if evidence expands those surfaces.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.2`
  Status: `done`
  Goal: Independently close the callback scope prerequisite on its committed repair with exact canonical acceptance before the function bridge.
  Dependencies: `.1.3.3.0.2.0.0`, `.1.3.3.0.2.0.1`
  Verification tier: `canonical`
  Focused checks: Committed diagnosis/repair source/log/hash reconciliation; native/fresh emitted scope and actual-frame controls; original authorities and direct dependents; book/Knowledge/history/memory/doctrines/diff; exact staged canonical receipt.
  Canonical trigger: designated parent closeout of the P1 pure-function scope prerequisite.
  Acceptance: Independently reconcile the repaired boundary and all limitations; run complete CI for the staged candidate, commit per COMMIT, clear brief and verify clean HEAD. Close .0.2.0 only after canonical acceptance; then activate bridge .0.2.1.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.0.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1`
  Status: `done`
  Goal: Implement the compiler-owned registered-function bridge after the function callback scope prerequisite closes.
  Dependencies: `.1.3.3.0.2.0`
  Acceptance: Reuse central function-body lowering with exact signatures, final-codeblock normalization, argument order, fresh locals, nested calls and recursion diagnostics. Declare any interface movement and broaden proof before edits; preserve the eight-field record and distinct startup32 limitation. Parent .0.2 closes only after full bounded native/emitted acceptance.
  Children: `.1.3.3.0.2.1.0`, `.1.3.3.0.2.1.1`, `.1.3.3.0.2.1.4`, `.1.3.3.0.2.1.3`, `.1.3.3.0.2.1.2`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.0`
  Status: `done`
  Goal: Establish the compiler-owned bridge interface, exact code/test paths and native/fresh emitted failure controls before changing runtime behavior.
  Verification tier: `focused`
  Focused checks: Toolbox Get/return_descriptor/parser_source_ref and fresh emitted controls for fixed/rest/final-codeblock calls, ordered arguments, pure scope, nested functions, precedence, arity/keyword/recursion/unknown failures; central lowering/context source review; unchanged authorities/source inputs, rendered book, Knowledge/history/memory/doctrines/diff.
  Canonical trigger: none for bounded interface planning and diagnostics with unchanged runtime. Implementation .1 must activate its own canonical declarations before private context/emission changes.
  Acceptance: Bind exact sources, native/emitted values/errors/metadata and generated mechanism to the clean base; describe a bridge that reuses the central function lowerer and common callable metadata, preserves the eight-field record and distinct startup32 limitation, and schedules all required regression/recursion controls before code edits.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.0 - specify deferred function bridge`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.1`
  Status: `done`
  Goal: Implement and verify the explicit registered-function bridge using the interface selected by .0.
  Dependencies: `.1.3.3.0.2.1.0`
  Verification tier: `canonical`
  Focused checks: Toolbox/native/fresh emitted RED/GREEN registered fixed/rest/final-block/signature/order/precedence/fresh-local/nested/unknown/type/keyword/recursion/private-name cases; actual frame/rest/parameter/exception controls and all original33 sources/279 tests; callable/variadic/binding/map dependents, exact original authority/normalization controls and unchanged governance; syntax/book/Knowledge/history/memory/doctrines/diff.
  Canonical trigger: Explicit invocation context table and generated callable-body emission movement; stage the complete candidate and require exact receipt-bound local CI, including full Phase0, before landing.
  Acceptance: Declare exact implementation paths and canonical fields from clean .0 HEAD. Reuse central function body lowering and common signature/contextual-block metadata. Preserve static callers, all existing push/scope cases, codeblock record bytes, startup32 and separate unrelated prerequisites; split any newly implicated defect before claiming closure.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.1 - bridge deferred registered functions`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.2`
  Status: `done`
  Goal: Independently reconcile the committed bridge and original controls, then close .0.2.1 and .0.2 under canonical proof.
  Dependencies: `.1.3.3.0.2.1.1`, committed `.1.3.3.0.2.1.4.0`/`.1.3.3.0.2.1.4.1`, `.1.3.3.0.2.1.3`, `.1.3.3.0.4`; normalization must satisfy the existing oracle and artifact recovery .0.4.2 must close before this canonical reconciliation. This leaf also reconciles parent .4, so parent status is not its own prerequisite.
  Acceptance: Close only after native/fresh emitted results and ordered effects agree with the existing oracles and the actual recursion/slot guards are exercised. Full neutral sixteen-case execution stays owned by .1.3.3.1.
  Verification tier: `canonical`
  Focused checks: Exact committed source/authority/checkpoint/producer recovery reconciliation; original seven controls and authorized normalization successor on native/public dump/fresh emitted routes; actual registered-call recursion/slot/identity/effect/error guards through unchanged tracked regressions; source-bound control corruption and honest historical/original-failure boundary; artifact read-denied audit, rendered book/Knowledge/history/memory/doctrines/diff.
  Canonical trigger: Independent milestone/parent closeout requires exact fully staged canonical receipt; no new runtime/authority/CI behavior is planned.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.2.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.2 - reconcile committed function bridge prerequisites`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4`
  Status: `done`
  Goal: Reconcile prior callable checkpoints' replay-producer durability and finish the requested claim-policy source/adoption review under explicit ownership.
  Dependencies: clean .0.2.1.1 handoff; no pivot while bridge implementation is dirty.
  Acceptance: Every selected replay claim has a recoverable tracked instrument or a named, scheduled durability repair with exact source boundary. Adopt applicable claim-verification rules explicitly and own any broader constants/untracked-producer sweep before claiming policy completion. Declare focused/canonical tier and exact paths only at clean activation. Valid-literal and normalization repairs retain separate owners.
  Children: `.1.3.3.0.2.1.4.0`, `.1.3.3.0.2.1.4.1`; preservation lands before policy adoption so neither becomes an oversized slice.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.0`
  Status: `done`
  Goal: Preserve exact historical callable replay instruments and their required data without rewriting the original checkpoints.
  Verification tier: `focused`
  Focused checks: Enumerate selected producer/input dependencies and original checkpoint/hash/Git boundaries; exact source recovery with corrupt-hash/escaping-path/no-write controls; classify tracked regression oracles separately from standalone observers; unchanged original checkpoints/runtime/authorities; rendered book, Knowledge/history/memory/doctrines/diff.
  Canonical trigger: none; bounded immutable evidence recovery and public explanation only. Policy/gate adoption is a separate child with its own declaration at clean activation.
  Acceptance: Recover every selected instrument and required input, bind original capture revisions and logs, prove safe byte-exact reconstruction, and disclose any unavailable or unverified dependency. Do not substitute current71 cases for historical33 cases or relabel historical execution as newly reverified. Archive the recovery instrument itself; preserve all original observations and repair owners.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.0 - preserve historical callable instruments`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1`
  Status: `done`
  Verification tier: `canonical`
  Focused checks: Actual claim record schema/source/producer controls, staged owner and stale-input RED/GREEN, unchanged default verification-tier API, doctrine/cadence controls, rendered book, Knowledge/history/memory/diff.
  Canonical trigger: New publishing doctrine/checker and registration/cadence infrastructure require exact staged local CI.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1.json`
  Goal: Finish the supplied claim-policy adoption review and adopt its applicable publishing contract with explicit local enforcement and audit ownership.
  Dependencies: clean `.1.3.3.0.2.1.4.0` handoff.
  Acceptance: Re-derive/falsify/durability are explicit local working rules; applicable mechanization has a named checker and registry route. Existing SESSION-STARTUP-READING.5 retains broader constants/untracked-producer/control and alignment audit ownership, and .29 retains its path repair. Neither that audit nor whole-project policy completion is claimed by a bounded adoption slice. Reconcile .4 only after both children are committed.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1 - enforce three-leg claim publishing`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.4.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3`
  Status: `done`
  Goal: Diagnose and repair the x,y literal reconstruction failure before registered-function bridge closeout.
  Dependencies: clean implementation .0.2.1.1 handoff; no pivot while its runtime work is dirty.
  Children: `.1.3.3.0.2.1.3.0`, `.1.3.3.0.2.1.3.1`
  Acceptance: Use Get/descriptor/substitution/source dump to find the exact intermediate mechanism, bind native/fresh emitted baseline, fix its owning compiler path with RED/GREEN and focused direct dependents, and keep all original bridge/scope/push records and authorities exact. Declare paths/tier before edits; canonical context/format/infrastructure movement requires broadened proof.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.0`
  Status: `done`
  Goal: Freeze the minimal valid-literal compiler failure and precise source-located cause before repair.
  Verification tier: `focused`
  Focused checks: Public Get/descriptor/substitution/source dump, standalone and parsed-entry AST comparisons, native and fresh emitted controls, precise owning-source review and distinguishing negative control; unchanged production/authority identities; existing callable/AST direct dependents; book/Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for source-located diagnosis without runtime or infrastructure movement; repair .3.1 selects its actual tier and paths before edits.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.0.json`
  Acceptance: Exact x,y/left,right source pairs, metadata, typed AST and native/fresh emitted failure are durable; no intermediate cause is guessed. Select the bounded owning compiler repair and its tier before code changes.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.0 - diagnose callable signature pipe splitting`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1`
  Status: `done`
  Goal: Repair and verify the diagnosed literal reconstruction path before bridge reconciliation.
  Dependencies: `.1.3.3.0.2.1.3.0`
  Verification tier: `focused`
  Focused checks: Actual pre-fix RED/new tests, repaired and restored-baseline public native/fresh controls; operator-named fixed/rest/zero/nested/string/body signature and host pipe-quote boundaries; original bridge regression and callable/variadic/binding/map/AST/trace direct dependents; Perl syntax and full phase0_regression per COMMIT; unchanged authorities; book/Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for bounded lexical scanner correction without schema/context/generated-format or infrastructure movement; broaden before landing if scope moves. Later bridge reconciliation and final push require canonical proof.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1.json`
  Acceptance: Matched native/fresh emitted RED/GREEN, original callable/bridge and compiler dependents, no raw fallback or record/schema drift, accurate book/Knowledge/checkpoint/continuity, and warranted canonical proof close this P1 prerequisite.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1 - protect callable signature pipe ownership`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.2.1.3.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4`
  Status: `done`
  Goal: Resolve the selected normalization loop/source-contract mismatch before dispatcher closeout and neutral runtime execution.
  Dependencies: clean registered bridge/literal prerequisite handoff; no pivot while .0.2.1.1 is dirty.
  Children: `.1.3.3.0.4.0`, `.1.3.3.0.4.1`, `.1.3.3.0.4.2`
  Acceptance: Minimize with Get/descriptor/substitution/dumped source and compare canonical arithmetic/while contracts and source selection. Choose an owning compiler correction or explicit fixture/authority correction with historical preservation, then prove healthy original/authorized successor observations and exact no-drift before parent closeout. Startup87 numeric codeblock dispatch remains separate.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0`
  Status: `done`
  Goal: Diagnose the normalization loop mismatch against the current admitted DSL and frozen source selection.
  Verification tier: `focused`
  Focused checks: Public Get/descriptor/substitution/dumped source and independent fresh emitted original/minimal/helper/word/symbol controls; canonical call grammar and exact source/authority preservation; source-bound observations and distinguishing falsifiers; direct neutral governance, rendered book, Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for source-preserving diagnosis; .4.1 must select canonical if normative fixture/authority changes, with original bytes retained.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0.json`
  Acceptance: Exact public native/fresh emitted controls and generated condition/body mechanism establish the cause and normative boundary, preserve original bytes, and select a safe repair tier/paths without guessing or waiving the failure.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0 - diagnose normalization call grammar mismatch`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1`
  Status: `done`
  Goal: Bind and verify the diagnosed call-form successor and narrow historical-audit correction.
  Dependencies: `.1.3.3.0.4.0`
  Verification tier: `canonical`
  Focused checks: Source-bound original RED/successor GREEN and seven normalization native/fresh cases with independent typed values/events/exit/quietness and actual returned-object detachment plus deliberate aliases; exact one-loop original/successor and unchanged sixteen oracles/foundation; neutral structural/source-correction/report falsifiers and reason-sensitive audit CI/Phase0 controls; direct diagnostic/callable/bridge/binding/mutation dependents; syntax/book/Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: Normative source-binding/checker and recurring CI/audit movement; fully stage the exact candidate and require receipt-bound tools/run_ci_local.sh before landing.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1.json`
  Acceptance: Source-bound RED/GREEN and direct dependents, original historical evidence, complete normalization values/ordered diagnostics/continuation, honest metadata and appropriate canonical acceptance resolve the P1 owner before .0.3.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1 - bind call-form normalization successor`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2`
  Status: `done`
  Goal: Retain and verify the closed134-log input population for fresh-checkout historical audit recovery.
  Dependencies: clean .0.4.1 source/disclosure handoff; no pivot with a dirty candidate.
  Acceptance: The selected artifact-input leg has verified tracked recovery or an exact narrower named residual blocker; do not convert a hash-only record into an archival claim. Bridge .0.2.1.2 waits for this bounded repair.
  Children: `.1.3.3.0.4.2.0`, `.1.3.3.0.4.2.1`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0`
  Status: `done`
  Goal: Inventory the exact historical artifact population, assess selected existing coverage and choose a bounded recovery format before implementation.
  Verification tier: `focused`
  Focused checks: Independent population reconstruction from the three historical milestones versus the current audit; each regular relative same-volume input's exact old hash/bytes; selected existing coverage census and actual distinguishing corruption/membership/path controls; source-bound capture and explicit durability disclosure; book/Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for read-only census/format planning; archive/restoration and recurring infrastructure implementation .4.2.1 require exact canonical proof.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0.json`
  Acceptance: Exact measured membership/sizes/hashes and bounded coverage findings survive through a tracked producer/capture; recovery format and next implementation paths/proof are explicit. Missing byte-recovery durability remains disclosed under .4.2.1; census is not a repair/admission claim.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0 - census historical audit artifact inputs`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1`
  Status: `done`
  Goal: Retain the exact selected observation bytes and prove safe isolated restoration plus historical audit re-derivation.
  Dependencies: `.1.3.3.0.4.2.0`
  Acceptance: Exact selected bytes are recoverable from tracked inputs in an isolated managed destination and the complete audit passes without reading original local logs. Close .4.2 only with source-bound recovery/controls and exact canonical receipt; broader startup5/29 remains separate.
  Verification tier: `canonical`
  Focused checks: Exact independent134 membership/bytes/hashes; deterministic capture; complete archive validation and exclusive isolated restoration; actual altered ZIP/missing member/hash/size/path/symlink/overwrite controls with intended reasons; full historical audit plus its actual falsifiers under original-log-read and tracked-write denial; original-source/capture preservation and explicit selected claim supersession; book/Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: Archive/storage and recurring CI infrastructure plus .4.2 parent closeout require fully staged exact candidate receipt before commit.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1 - recover historical audit artifact inputs`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.4.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.3`
  Status: `pending`
  Goal: Independently reconcile the two repaired dispatcher routes against the original minimal controls and selected normalization objective before parent closeout.
  Dependencies: `.1.3.3.0.1`, `.1.3.3.0.2`, `.1.3.3.0.4`, `.1.3.3.0.5`, `.1.3.3.0.6`, `.1.3.3.0.7`
  Acceptance: Bind exact code, sources, native/emitted observations and focused controls; retain all unrelated repair prerequisites. Close .1.3.3.0 only after the selected pipeline runs correctly without raw host fallback, and then activate .1.3.3.1 for complete neutral-case and semantic-mutant execution.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5`
  Status: `done`
  Goal: Diagnose and repair attached control execution in deferred Perl bodies before dispatcher closeout.
  Dependencies: clean literal .0.2.1.3 and normalization .0.4 handoffs.
  Children: `.1.3.3.0.5.0`, `.1.3.3.0.5.1`, `.1.3.3.0.5.2`, `.1.3.3.0.5.3`, `.1.3.3.0.5.4`, `.1.3.3.0.5.5`, `.1.3.3.0.5.6`
  Acceptance: Use public toolbox controls and canonical control/return contracts; select compiler/runtime ownership and tier; retain exact historical failure, implement distinguishing RED/GREEN with branch laziness and local returns, cover direct dependents and appropriate canonical acceptance without schema drift.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0`
  Status: `done`
  Goal: Freeze the exact deferred attached-control failure, normative semantics and bounded repair ownership before runtime edits.
  Acceptance: Matched native/fresh typed failure and positive equivalent controls locate the unsupported AST boundary; contract/source/return/scope review selects safe repair paths and verification tier without assuming all control families behave alike.
  Verification tier: `focused`
  Focused checks: Source-bound public native/fresh attached-if failure and positive equivalent/early-return/scope/parameter controls; typed AST/control-family/return/loop contracts and exact compiler/runtime source location; actual distinguishing effects and observation corruption; direct callable-literal/AST/bridge/normalization regressions; original source/authority preservation and rendered book/Knowledge/history/memory/doctrines/diff.
  Canonical trigger: none for source-preserving diagnosis; .0.5.1 declares its repair tier after actual interface/contract extent is known.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0 - diagnose deferred conditional execution`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1`
  Status: `done`
  Goal: Implement and verify the diagnosed deferred-control correction before dispatcher closure.
  Dependencies: `.1.3.3.0.5.0`, committed `SESSION-STARTUP-READING.87.2` matches/regex prerequisite
  Acceptance: Actual branch/operand/body effects, return propagation, caller/parameter restoration and native/fresh RED/GREEN plus direct dependents establish the bounded repair; preserve other open controls, accurate public teaching and warranted canonical proof.
  Verification tier: `focused`
  Focused checks: Exact original attached-if RED/GREEN and true/false/elseif/else/alias/nested branch/return/once-only/lazy effect cases; governed truthiness and invocation-local return across conditional bodies, eager-block return boundary, original caller/parameter/error identities and deliberate equal-value control. Typed AST source-poisoning, native/independent fresh emitted parity, matched exact before-runtime replay, preserved marker/value exclusions and genuine unsupported diagnostics; new regression plus current matches/literal/logical/variadic/binding/bridge/normalization/AST direct dependents; syntax, unchanged sources/authorities, rendered exact book examples, Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for private typed evaluator correction with existing control/return contract and unchanged record/context/schema; broaden before landing if actual semantics/interface extent moves. Later conditional-parent/dispatcher and push boundaries require canonical proof. This runtime evaluator is not the action rewriter.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1 - execute attached callable conditionals` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.2`
  Status: `done`
  Goal: Repair or independently verify deferred marker if/elseif/else/endif after attached-control repair, without enlarging .5.1 beyond a safe slice.
  Dependencies: committed `.1.3.3.0.5.0`, `.1.3.3.0.5.1`; matching helper prerequisite `SESSION-STARTUP-READING.87.2`.
  Acceptance: Reverify after .5.1, own the remaining implementation if needed, and prove matching nested marker groups, branch laziness, returns, actual caller/parameter/error restoration and native/fresh parity. Malformed/orphan controls retain precise diagnostics. Preserve attached controls, authorities and all other owners; declare paths/tier before edits and commit independently.
  Verification tier: `focused`
  Focused checks: Existing exact marker failure on native/fresh and activation-exact baseline; selected true/false/elseif/else/aliases/nested marker/attached combinations, governed truthiness, once-only/lazy effects and conditional local/eager return boundaries. Precise reachable malformed/orphan/mixed typed controls, poisoned recorded AST source, actual x/rest/caller/error identities and equal-value controls. New marker regression plus current attached/matches/literal/logical/variadic/binding/bridge/normalization/AST dependents; syntax, unchanged byte boundaries, current exact rendered examples, Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for private evaluator correction under the existing marker/return contract with unchanged public carriers; broaden before landing if observed extent moves. Later control parent/dispatcher and clean push boundaries require canonical proof; this evaluator is not the action rewriter.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.2.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.2 - execute marker callable conditionals` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3`
  Status: `done`
  Goal: Repair or independently verify deferred value-form if/else after statement-family repairs through the existing conditional contract.
  Dependencies: committed `.1.3.3.0.5.0`, `.1.3.3.0.5.1`, `.1.3.3.0.5.2`; matching helper prerequisite `SESSION-STARTUP-READING.87.2`.
  Acceptance: Reverify remaining failure after earlier repairs, reuse governed conditional/truthiness rules, and prove exact values, once-only/lazy condition and branch effects, nested function/callback routes, returns and restoration. Preserve eager logical-helper semantics and genuinely unsupported-call diagnostics. No silent function-body extension or new record/schema field; declare bounded paths/tier and commit independently.
  Verification tier: `focused`
  Focused checks: Exact original value-if native/fresh failure and current-base baseline; canonical if/elseif/else arities and branch order, selected exact values, once-only/lazy effects, nested value/marker/attached/eager/user-function routes and helper precedence. Actual x/rest/error identities/equal-value controls and source-poisoned typed AST where applicable. New value regression plus current marker/attached/matches/literal/logical/variadic/binding/bridge/normalization/AST direct dependents; syntax, exact unchanged boundaries, rendered executed examples, Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for private lazy evaluator under existing value-control/return contracts and unchanged public carriers; broaden before landing if actual extent changes. Parent/dispatcher and clean push boundaries require canonical proof. This evaluator is not the action rewriter.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3 - execute lazy callable value conditionals` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.4`
  Status: `done`
  Goal: Repair zero-argument return and return_undef through the existing local-return contract after conditional families.
  Dependencies: committed `.1.3.3.0.5.1`, `.1.3.3.0.5.2`, `.1.3.3.0.5.3`.
  Acceptance: Use canonical return contract and public controls to prove null result plus skipped continuation, nested conditional propagation, eager-block local boundary, helper precedence, arity-before-effects, original scope/error identity and native/fresh parity. Preserve other controls and existing contracts/record/schema; declare paths/tier before edits and commit independently.
  Verification tier: `focused`
  Focused checks: Exact empty-return/return_undef native/fresh baseline and public canonical arity/AST/return contract. Null result with skipped continuation; selected/unselected/nested marker/attached/value/eager/callback/function routes and local boundaries; helper precedence, arity-before-effects, actual x/rest slots-array/error identities and equal-value controls, source poison. New null-return regression plus current value/marker/attached/matches/literal/logical/variadic/binding/bridge/normalization/AST direct dependents, syntax/unchanged boundaries, executed rendered examples, exact retained bytes/controls, Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for bounded private sequence-return correction under existing return contract with unchanged public carriers; broaden before implementation if actual scope moves. Parent/dispatcher/final clean push canonical; no full gate per ordinary slice.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.4.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.4 - execute local null returns` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.5`
  Status: `done`
  Goal: Diagnose and repair governed while execution in callable bodies after conditional/null-return families.
  Dependencies: committed `.1.3.3.0.5.1` through `.1.3.3.0.5.4`; this owns runtime loop execution separately from `.0.7` raw readiness telemetry.
  Acceptance: First diagnose through public AST/Get/descriptor/substitution/native/fresh and canonical while/truthiness/return contracts. Declare bounded paths/tier before repair; prove false/nonempty loops, once-per-iteration conditions, body effects, nested local/eager return boundaries and original parameter/error identities with meaningful RED/GREEN/direct dependents. Split other loop-control helpers if their extent requires it; preserve marker/value/function/readiness owners and public carriers. Commit independently before the control parent closes.
  Verification tier: `focused`
  Focused checks: Original false-loop RED/native/fresh, public AST/Get/descriptor/substitution and guarded direct/native contract controls. Zero/multiple iterations, condition once per check and final false check, lazy body, caller-visible mutation, nested attached/marker/value/eager local false/null returns, actual x/rest slots-array/error identity/equal-value controls, source poison. Exact10000-body success/final-check/exhaustion timing, effects before guard and typed opening span/original error. New while suite plus all current981 direct dependents; syntax/unchanged boundaries/rendered executed examples, Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for private typed attached-while executor under existing truthiness/local-return/10000-guard contracts and unchanged public carriers. Broaden before repair if actual scope moves; parent/dispatcher/final clean push canonical. No new resource limit, compiler/helper/record admission or other-backend promotion.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.5.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.5 - execute guarded callable while` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.5`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.6`
  Status: `done`
  Goal: Reconcile the bounded deferred-control parent after all independently committed executor repairs.
  Dependencies: committed `.1.3.3.0.5.0` through `.1.3.3.0.5.5` and startup87.2.
  Acceptance: Read current source-bound successor reviews/tests and exact historical boundaries; preserve independent numeric/literal/function/metadata/full16 owners. Close only the bounded control parent with current focused compatibility proof and receipt-bound canonical acceptance of the exact staged candidate. Commit before residual-order diagnosis .0.6.0.
  Verification tier: `canonical`
  Focused checks: Read-only exact250-input current while compatibility boundary and retained14-suite1014-test proof, matched RED/GREEN/guard/value/identity evidence and producer/capture identity; distinguishing corrupted input/result/guard/scope/source controls. Render parent-summary/book teaching and verify exact example preservation; Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: Bounded control parent closeout under ADR0073; fully staged candidate and successful exact receipt required before landing. No dispatcher/full16/metadata/readiness or other-backend closure.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.6.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.6 - reconcile deferred control parent` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.6`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6`
  Status: `done`
  Goal: Diagnose and repair residual canonical helper-event ordering/overlap before dispatcher closeout.
  Dependencies: clean literal .0.2.1.3, normalization .0.4 and deferred-control .0.5 handoffs.
  Children: `.1.3.3.0.6.0`, `.1.3.3.0.6.1`
  Acceptance: Source-bound controlled public observations and canonical order/provenance contracts select explicit deterministic occurrence/provenance ownership that preserves top-level source order, not a cosmetic sorted snapshot. Preserve exact prior records; verify overlapping/repeated helper spans, readiness and unchanged public execution, direct dependents and warranted canonical boundary.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0`
  Status: `done`
  Goal: Freeze residual event permutation/readiness effects and normative ordering/overlap before compiler edits.
  Acceptance: Controlled process/hash-order observations locate exact queue producer/consumer source and distinguish harmless metadata permutation from classification/execution drift; select bounded paths/tier and retain evidence without normalizing it away.
  Verification tier: `focused`
  Focused checks: Controlled public descriptor/substitution under fixed PERL_HASH_SEED/PERL_PERTURB_KEYS across exact nested/body originals and independently selected repeated/overlap/nested/raw/string controls. Retain raw sequence/source spans, typed AST, generated bytes and native/fresh results/error/readiness consumers; distinguish permutation from classification/output effects. Read canonical contracts/tool-proven source owner only after observations; independent distinguishing data/source/order/consumer controls, direct affected metadata/AST/public suites, current input/capture identities and rendered teaching. Knowledge/history/memory/all doctrines/diff.
  Canonical trigger: none for read-only diagnosis and retained public evidence under unchanged production/contracts/carriers. .6.1 canonical if compiler/public-format ownership changes; no admission/parent/push here.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0 - diagnose residual event provenance` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1`
  Status: `done`
  Goal: Repair and verify the diagnosed residual-event ordering/overlap mechanism.
  Dependencies: `.1.3.3.0.6.0`
  Acceptance: Actual controlled RED/GREEN source/duplicate/overlap and order/readiness/public execution checks plus direct dependents establish deterministic canonical behavior; full warranted acceptance precedes .0.3.
  Verification tier: `canonical`
  Focused checks: Adversarial A/B/A residual occurrences with equal raw but distinguishing arguments/contract priority, matched top-level removal and exclusive raw-key ownership, blank queue entries/fallback/count/public schema/input immutability. Exact source-bound baseline/current public descriptors, AST/substitution/dump/emitted/native/fresh/readiness under seeds0/1/2; retain raw arrays and require deterministic current order without normalizing snapshots. Source-identical compatibility controls and genuine corrupted data/queue order/consumer inputs must reject. New regression plus trace/metadata/AST/generated-source/callable and recursive/transaction/progressive/staged metadata direct dependents; syntax/book/Knowledge/history/memory/diff/all doctrines.
  Canonical trigger: Changes canonical compiler event-array order consumed by lowering/readiness policies. Fully stage the complete verified candidate, then exact staged tools/run_ci_local.sh receipt required before landing. Phase0 includes the permanent queue regression without changing CI scripts or neutral historical CI authorities.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1 - preserve residual event occurrences` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7`
  Status: `pending`
  Priority: P1 — unsupported nested expressions are falsely reported raw-free and language-agnostic ready.
  Goal: Diagnose and repair nested raw-expression portability telemetry without admitting infix grammar or hiding legacy source. Comments also need distinct source-data classification under .7.3.
  Dependencies: clean normalization .0.4, deferred-control .0.5 and residual-order .0.6 handoffs; must close before .0.3.
  Reproduce: .4.0 public sources i=2; i=i+1; return(i) and i=2; if(i < 1) { return("yes") }; return("no") have raw_perl/unsupported_expression AST children, preserve host barewords, and return1/yes on native/fresh routes while reporting ready1/raw0/fallback0/unresolved0. The frozen while source similarly leaves count as a host call and fails. ADR0003 requires remaining raw source to be surfaced rather than hidden by ready.
  Source boundary: AST/Parser.pm::_parse_expr_without_chain ends at unsupported_expression. The .7.0 actual assignment trace reaches FlowExpr passthrough_no_call then ValueExpr flow_composite_value, not its conditional final source_passthrough branch. CanonicalEvents.pm counts unmatched top-level statements, while EmitContext.pm::_build_action_rewriter_meta derives raw/ready from those counts. .7.0 freezes source-occurrence policy and .7.1 owns verified reporting repair.
  Impact: Descriptor portability claims can conceal raw host dependencies and semantically misleading results. This is separate from hash-order overlap .0.6 and from correcting the selected fixture .0.4.
  Children: `.1.3.3.0.7.0`, `.1.3.3.0.7.1`, `.1.3.3.0.7.2`, `.1.3.3.0.7.3`, `.1.3.3.0.7.4`
  Acceptance: Exact nested condition/assignment/call/control and canonical positives distinguish true raw dependencies from authored string/comment payloads. Preserve host-source evidence, report deterministic blockers/provenance and verify shipped-spec readiness/direct dependents with warranted canonical signoff.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0`
  Status: `done`
  Goal: Freeze the nested raw-expression readiness mechanism, policy, source locations and bounded repair ownership.
  Acceptance: Public source-bound AST/descriptor/lowering controls locate missed nested dependencies and consumer effects; select safe compiler paths/tier without expanding grammar or conflating hash-order repair.
  Verification tier: `focused`
  Focused checks: Exact source-bound current public AST/descriptor/lowering/native/fresh and trace controls, independent raw-node/source/readiness expectations and reason-sensitive corrupted observation controls; unchanged AST parser/metadata/generated-source/trace direct dependents, rendered source-identical book examples, full producer/input claim identities, Knowledge/history/memory/diff and all doctrines.
  Canonical trigger: none for source-bound diagnosis with unchanged compiler/runtime/authority/CI. .7.1 owns subsequent readiness contract movement and warranted exact staged canonical signoff.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0 - diagnose nested raw readiness` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1`
  Status: `done`
  Goal: Repair and verify diagnosed nested raw-expression readiness reporting.
  Dependencies: `.1.3.3.0.7.0`
  Acceptance: Actual false-ready RED/GREEN, nested/quoted canonical controls, deterministic source blockers, shipped-spec readiness and direct dependents pass before dispatcher closeout.
  Verification tier: `canonical`
  Focused checks: Actual public readiness RED/GREEN on diagnosed nested raw and canonical/data/visible-raw controls; source-unit spans/alias/repeated/containing-raw provenance, caller/lifecycle/deferred/function and shipped-spec census; exact lowering/runtime source identities, independent fresh and original failures, direct AST/metadata/generated-source/control/trace consumers and reason-sensitive evidence corruptions; book/Knowledge/history/memory/diff/all doctrines.
  Canonical trigger: Public raw dependency count/readiness/blocker telemetry changes require exact staged tools/run_ci_local.sh receipt before landing. No grammar, canonical event schema, runtime or helper authority expansion.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1 - report raw expression source dependencies` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2`
  Status: `active`
  Priority: P1 — quoted data is falsely reported as executable helper/control activity.
  Goal: Diagnose and repair quoted-payload helper metadata without altering authored literal values or hiding real raw dependencies.
  Dependencies: `.1.3.3.0.6.1`, `.1.3.3.0.7.1`; required before dispatcher `.1.3.3.0.3`.
  Children: `.1.3.3.0.7.2.0`, `.1.3.3.0.7.2.1`, `.1.3.3.0.7.2.2`, `.1.3.3.0.7.2.3`
  Reproduce: `.6.0` case quoted, Top:: I { return("return(inner); if(true)") }, returns the exact literal natively and from fresh emitted source under seeds0/1/2, yet records residual IF if(true), unresolved_helper_count3 and ready0. Complete source-bound observations remain in `.6.0-observations.json`.
  Impact: Ordinary literal data creates false portability blockers and control metadata; healthy execution does not validate that descriptor classification.
  Acceptance: Use Toolbox trace/AST/descriptor to locate quote masking across helper discovery, canonical events and unresolved diagnostics; preserve source/value bytes, prove quoted/escaped/nested/comment negatives and genuine unquoted helper/raw positives. Declare paths/tier before implementation; actual RED/GREEN plus direct consumer checks and warranted canonical signoff close this leaf. No literal grammar expansion or hidden blocker removal.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.0`
  Status: `done`
  Goal: Split quoted-data diagnosis, bounded repair and closeout before implementation; reconcile the committed reporting handoff.
  Verification tier: `focused`
  Focused checks: Read existing quoted-data/primitive-rewrite facts and published raw-source/event/source-unit contracts; verify the clean commit/receipt/brief handoff, exact task IDs/frontier and historical claim identities, render the book, and run memory/Knowledge/history/diff/all-doctrine checks.
  Canonical trigger: none for scheduling and documentation with unchanged compiler/runtime/public semantics; .7.2.2 and .7.2.3 require warranted exact canonical acceptance.
  Claim verification: none: This slice publishes no new experiment or measurement; it routes existing committed proof and pending work.
  Acceptance: A single next diagnostic leaf, bounded repair and closeout successors, explicit evidence/tier boundaries, current task-index/live/book pointers and historical .7.1 claim remain consistent; selected focused checks pass before this planning leaf commits.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.0 - plan quoted-data repair`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1`
  Status: `done`
  Goal: Diagnose executable-source ownership across quoted helper discovery, canonical events, lowering and unresolved diagnostics.
  Dependencies: `.1.3.3.0.7.2.0`
  Verification tier: `focused`
  Focused checks: Current public AST/substitution/descriptor/generated-source/dump/runtime/error probes and a fresh emitted Perl process for each exact case under seeds0/1/2, perturb2; focused lowering trace under seed0; unchanged parser/helper/statement/canonical/raw-provenance consumers selected from their actual inventory; syntax, reviewer corruption controls, rendered book, memory/Knowledge/claim/history/diff and all doctrines. Diagnostic conclusions select later repair; no production/gate change or backend admission.
  Canonical trigger: none for this evidence-only diagnosis; implementation/closeout retain their designated canonical requirement.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1.json`
  Acceptance: Declare source-bound producers/captures and focused tier before use. Reproduce current public quoted-data errors through Toolbox AST/descriptor/substitution/trace and independent fresh emitted Perl, recover older .18 evidence, preserve actual channels/source/error identity, and distinguish accepted lexical negatives from genuine helpers/raw operands. Independent source/occurrence/value expectations and executed evidence falsifiers select bounded repair paths without changing production or claiming new syntax/backend admission. Commit the complete diagnosis before implementing .7.2.2.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1 - diagnose quoted action source ownership`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2`
  Status: `active`
  Goal: Repair the diagnosed quoted-data ownership defects while preserving authored values and genuine dependencies.
  Dependencies: `.1.3.3.0.7.2.1`
  Children: `.1.3.3.0.7.2.2.0`, `.1.3.3.0.7.2.2.1`
  Bounded repair decision: Source-bound diagnosis identifies two independently reviewable mechanisms. First exclude authored literal occurrences from helper discovery and source replacement, then reconcile unresolved patterns and true compiler-generated unsupported-helper provenance. Preserve current public event fields/contract precedence/occurrence order, exact accepted literal values and raw operand spans; no whole-action quote masking that changes argument sources or hides sentinels. Complete and commit each child before independent parent acceptance .7.2.3.
  Acceptance: Select and declare exact production/test/interface paths from committed diagnosis; split further if independent mechanisms exceed a safe slice. Actual permanent RED/GREEN and source-bound direct/fresh compatibility prove lexical ownership, occurrence order, literal bytes and genuine helper/raw detection. Preserve separate comment and older broad carrier owners. Public event/readiness or infrastructure changes require exact staged canonical proof; synchronize book/Knowledge/live docs and commit every implemented leaf.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0`
  Status: `active`
  Goal: Preserve executable occurrence identity through helper scanning and residual source replacement.
  Dependencies: `.1.3.3.0.7.2.1`
  Children: `.1.3.3.0.7.2.2.0.0`, `.1.3.3.0.7.2.2.0.1`, `.1.3.3.0.7.2.2.0.2`, `.1.3.3.0.7.2.2.0.3`, `.1.3.3.0.7.2.2.0.4`
  Safe-slice split: The proposed three-owner filter cannot infer exact matches from raw event spelling alone. Before production edits, .0 preserves the actual complete RED fixture and falsifies candidate raw-key mappers through public probes. .1 owns producer source provenance and its private interface, .2 executable source membership, .3 exact residual replacement and .4 recurring registration/canonical composition. Declare exact producer families and recursive source frames from the .0 inventory before each implementation activation; no masked argument parsing or public event-field expansion.
  Candidate owners: MethodExpr lexical/slash ownership, ScannerCore family dispatch, RewritePipeline source-span selection and their affected direct scanner/canonical consumers; declare exact paths/tier/producers before changing them.
  Activation: Cleanea45d933d6af8776bb4205514f423e3b7627af0d; all ten diagnosis hooks/post-pointer PASS, brief0, no background job. Relevant roadmap/decision/lexical/helper/descriptor/source-unit contracts, affected public probe paths, unchanged consumer suites and book sections reviewed. The quote-before-real occurrence gap is explicitly unmeasured until the supplementary Toolbox probes execute.
  Owned paths: perl/LinkedSpec/ActionIR/MethodExpr.pm, ScannerCore.pm and RewritePipeline.pm; t/actionir_quoted_source_ownership.t; the exact recurring tracked/syntax/execution registrations in tools/run_ci_local.sh and their historical validation consumer if its anchored source oracle requires reconciliation. This task/index/resume/live/roadmap/change/notes/book/Knowledge and docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.json; freeze .7.2.1 claim/fact at actualea45d933d before changing bound inputs. Checkpoint prefix docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0- owns before-MethodExpr.pm, before-ScannerCore.pm, before-RewritePipeline.pm, cases.json, probe.pl, fresh.pl, capture.py, before.json, after.json, occurrence-probe.pl, occurrence-before.json, tests.py, tests-before.json, tests-after.json, review.py, verification.json, trace.pl, trace-before.json, trace-after.json, book.py, book.json, claim.py and explicitly retained initial failed instruments/captures. Producers declare exact corpus/seed/baseline modes before execution; scratch is .linkedspec-data/scratch/quoted-executable-ownership. Original captures remain immutable; no recovery/purge.
  Parent proof obligations: Before any repair, source-identical public occurrence twins in both orders and permanent focused RED; frozen-owner/current public AST/substitution/descriptor/dump/native/fresh source-value/error controls with actual streams, independent occurrence/literal/raw/legacy/slash oracles, reached traces and executed evidence falsifiers. Unchanged direct scanner/AST/canonical/raw/span/trace/generated/matches consumers, actual book rendering/examples, syntax, historical CI-registration source controls, memory/Knowledge/claims/history/diff and all doctrines.
  Parent canonical boundary: Public literal/event behavior and recurring CI registration change; exact staged tools/run_ci_local.sh receipt is required before commit.
  Source-ownership boundary: Reuse the published existing helper-pattern/slash-call and quote/host-quote/comment contracts. Match executable start positions while retaining complete original argument/literal bytes; do not feed masked operands into parsing/lowering. Equal raw text cannot identify an occurrence. Source replacement must avoid a quoted twin preceding an actual helper, including strings created by lowering. Preserve opaque scanner/delegation returns and caller error state. Any further lexer/method precedence or grammar issue must be independently owned and split before widening this slice.
  Before-change public occurrence proof: occurrence-probe.pl calls both published call_spec_handler_subst and its diagnostic owner on four exact supplementary sources, requiring identical output. Quoted-before-real and real-before-quoted each produce two set_value events for one real occurrence; the intervening quoted twin produces three for two real occurrences, and actual substitution changes each literal. Regex /if(true)/ contributes a false IF and original-source fallback. cases-initial.json preserves an initial expected1 typo for matches("ifXtrue", /if(true)/); before runtime measurement correct only that independent expected value to0 because grouping does not match the inserted X. Every executed source/action/input/manual-helper byte remains unchanged; occurrence-before.json is untouched.
  Actual permanent RED: tests-before.json retains the frozen three-owner command and complete thirteen-group TAP plan; eleven groups fail, two genuine unsupported/raw and opaque/caller-error guards pass. No fatal/truncated plan is accepted as RED. New supported surfaces are excluded by ADR0011; lexical membership repairs existing scanner/typed-lowering seams only. Additional exact governance owner: tests/language-readiness/verify_objectives.py; preserve its before bytes and current historical hash while allowing only three anchored new-test registrations, with actual omitted/duplicate/disabled/extra-edit rejections.
  Acceptance: Actual RED/GREEN protects both quote forms, escapes, Unicode/CRLF, nested/deferred literals, quoted/real identical helper twins in both orders and repeated distinct occurrences. Reproduce the quote-before-real replacement ambiguity before choosing its repair. Close the actually failing nested_data/regex_data native/fresh host-call paths to their independently authored literal/matches values, preserving original failures as RED. Preserve original arguments/spans, contract precedence, genuine control/raw/legacy helpers and supported slash patterns; source comments retain their separate AST/fallback repair. Update recurring focused tests and book/Knowledge/live docs, then exact staged canonical verification and commit. This child must honestly preserve the still-open marker diagnostic boundary rather than claim all quoted readiness fixed.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.0`
  Status: `done`
  Goal: Freeze complete quoted-source RED and prove why raw spelling alone cannot identify executable scan occurrences.
  Dependencies: `.1.3.3.0.7.2.1`
  Verification tier: `focused`
  Focused checks: Source-bound public AST/facade substitution/diagnostic probes; actually executed candidate-mapper false-drop/order controls, complete thirteen-group RED replay with two guards green, exact source/test/producer identities and scanner-family inventory, read-only reviewer corruptions, unchanged occurrence/AST/scanner consumers, actual book render, memory/Knowledge/claim/history/diff and all doctrines.
  Canonical trigger: None; evidence and safe ownership decomposition only, without production/test-registration/public contract movement. Implementation admission .4 retains exact canonical proof.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.0.json`
  Acceptance: Preserve original before TAP/fixture and capture bytes, disclose expected RED rather than declare runtime acceptance, record source-bound distinguishing observations and exact producer ownership, then commit a clean handoff to producer provenance .1.
  Commit: This leaf lands the bounded additional diagnosis; Git is the commit identity authority. Next producer provenance .1 activates only after the clean handoff.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1`
  Status: `done`
  Goal: Preserve scanner match provenance through a private source-bound interface.
  Dependencies: `.1.3.3.0.7.2.2.0.0`
  Acceptance: Select exact producer families from the committed inventory and split if needed. Capture actual regex offsets before nested parsing overwrites match globals; translate recursive/substatement frames explicitly. Preserve original raw/args bytes, family precedence, occurrence order, opaque delegation and caller error state; no public event schema changes. Verify affected scanner/control/recognized-pattern consumers and commit before membership changes.
  Children: `.1.3.3.0.7.2.2.0.1.0`, `.1.3.3.0.7.2.2.0.1.1`, `.1.3.3.0.7.2.2.0.1.2`, `.1.3.3.0.7.2.2.0.1.3`, `.1.3.3.0.7.2.2.0.1.4`, `.1.3.3.0.7.2.2.0.1.5`, `.1.3.3.0.7.2.2.0.1.6`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0`
  Status: `done`
  Goal: Record exact source positions privately for return_general, set_value and if_flow without changing public helper events.
  Dependencies: `.1.3.3.0.7.2.2.0.0`
  Verification tier: `focused`
  Focused checks: Actual complete private-provenance RED/GREEN; source-identical original/public versus private event equality and independently authored offsets, original raw/argument bytes, both counterexamples, quotes/Unicode/CRLF/regex/flow bodies, genuine and opaque/empty/delegated error/reentrant guards. Source-bound before/after public substitution/diagnostic identity; unchanged AST/order/trace/raw/span/generated/matches consumers and full Phase0; reviewer evidence corruptions, actual book render/examples, syntax, memory/Knowledge/claim/history/diff and all doctrines.
  Canonical trigger: None; internal source sidecar only, with public events/arguments/lowering/CI unchanged. Membership/replacement public behavior and recurring registration require their designated canonical acceptance later.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0.json`
  Acceptance: Actual before/after provenance oracles distinguish quoted position8 from genuine return23 and quoted set6/real23/39 without altering stream order or losing events. Unicode spans use scalar coordinates; opaque events retain identity and nesting restores recorder state. Current quote defects and marker/comments remain unchanged and explicitly owned. Complete focused verification and per-slice commit before the next producer family.
  Commit: This bounded private channel lands independently; Git is the commit identity authority. Activate PrimitiveBasicRules .1 only after clean handoff and historical claim freeze.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1`
  Status: `done`
  Goal: Complete PrimitiveBasicRules source provenance.
  Dependencies: `.1.3.3.0.7.2.2.0.1.0`
  Children: `.1.3.3.0.7.2.2.0.1.1.0`, `.1.3.3.0.7.2.2.0.1.1.1`, `.1.3.3.0.7.2.2.0.1.1.2`, `.1.3.3.0.7.2.2.0.1.1.3`
  Acceptance: Select exact regex and statement frames, preserve all raw/args and current five callback dependencies; verify actual source/occurrence/direct consumer oracles before commit.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0`
  Status: `done`
  Goal: Retain exact private match provenance for the nine PrimitiveBasicRules regex contracts.
  Dependencies: `.1.3.3.0.7.2.2.0.1.0`
  Verification tier: `focused`
  Focused checks: Source-bound unchanged public Scanner and Toolbox substitution/descriptor/dump/emission before/after; independent scalar positions for nine contracts and repeated quoted/real occurrences, Unicode/CRLF and original arguments; permanent complete frozen-owner RED/GREEN; previous private-channel and direct scanner/AST/order/trace/raw/generated/gap consumers, full Phase0, read-only evidence corruptions, actual book render, syntax, memory/Knowledge/claim/history/diff and all doctrines.
  Canonical trigger: None; private telemetry only with public event/lowering/contract/dependency/CI behavior unchanged. Public membership/replacement/registration acceptance remains separately canonical.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0.json`
  Acceptance: Capture original full-source regex coordinates before recording; original event objects/raw/args and family ordering remain exact. Cover assign_call_my, assign_call, push_child_call_indexed_builtin, push_child_call_builtin, return_call and entry_slot/gap_span/gap_text/gap_kind. Record quoted syntactic matches without filtering. Preserve initial failures and artifacts; no recovery/purge. Commit before statement-frame implementation.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0 - retain basic regex match provenance`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1`
  Status: `done`
  Goal: Preserve exact source frames for the eleven basic statement contracts.
  Dependencies: `.1.3.3.0.7.2.2.0.1.1.3`
  Acceptance: Use Toolbox split/public scanner probes first; independently test comments, quotes, repeated identical statements, attached boundaries, whitespace and Unicode/CRLF. Select producer-side framing without raw-key source search or five-callback expansion; explicitly own any non-contiguous original-source representation before implementation. Split further if needed.
  Children: `.1.3.3.0.7.2.2.0.1.1.1.0-.3`; diagnosis, private frame capture and eleven producer hooks are complete; .3 independently accepts their composition with an exact staged canonical landing condition. Only this statement family closes.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0`
  Status: `done`
  Goal: Diagnose the exact eleven basic statement producers and canonical splitter transformation before selecting source-frame representation.
  Verification tier: `focused`
  Focused checks: Actual default-dependency splitter/public Scanner/private provenance and Toolbox substitution/descriptor/dump probes; independently authored source positions, comment/quote/repetition/attached/whitespace/Unicode/CRLF distinctions and reason-sensitive evidence corruptions. Source/instrument retention and completed channels, selected unchanged direct consumers, syntax/book/claim/memory/Knowledge/history/diff and all doctrines.
  Canonical trigger: None; source-backed diagnosis and producer documentation only. Parent/family acceptance and future executable membership remain separate.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0.json`
  Acceptance: Recover each actual event identity and splitter-produced text; distinguish contiguous trimmed source from any genuinely non-contiguous transformation using independent original-source oracles, not raw-key source search. Preserve original event/argument/dependency interfaces. Define exact implementation children only after Toolbox output and source location establish the mechanism; explicitly own non-contiguous representation if observed.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0 - diagnose basic statement source frames`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.1`
  Status: `done`
  Goal: Capture private contiguous statement frames at canonical splitter boundaries without changing its returned strings or callback signatures.
  Dependencies: `.1.1.1.0`
  Verification tier: `focused`
  Focused checks: Same authored original scalar intervals, exact returned array/string and five-callback preservation, nested/private invocation isolation, opaque/custom callback guard; actual RED/GREEN, complete direct-consumer/Phase0 channels, syntax/book and all doctrine/claim/Knowledge/history checks.
  Canonical trigger: None; private frame capture only; statement-family acceptance .3 is canonical.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.1.json`
  Acceptance: Observe existing callback exactly once; record frames from original state boundaries before trimming, with exact source-slice validation. Match returned array identity and occurrence index, never equal raw text. Preserve callback side effects, errors, nesting and unknown callback behavior; no fabricated origins or global retained state.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.1 - retain private splitter source frames`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2`
  Status: `done`
  Goal: Connect all eleven basic statement event producers to the private splitter frames while preserving original event/argument objects and ordering.
  Dependencies: `.1.1.1.1`
  Verification tier: `focused`
  Focused checks: Eleven repeated-contract RED/GREEN groups plus callback/identity/nesting guards; all22 diagnosis cases with independent scalar/event identity oracle; fixed-source before/after full public compiler objects/substitution/diagnostics/dumps, complete direct consumers and Phase0, syntax/book/all doctrine/claim/Knowledge/history checks.
  Canonical trigger: None; private producer hooks; .3 gates family closeout.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2.json`
  Acceptance: Capture the exact frame at emission, before any nested scan. Keep existing regexes, trim/split call counts, five dependency signatures, public raw/args and order unchanged. Custom/opaque returns never gain invented origins; executable membership remains later.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2 - retain basic statement source origins`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.3`
  Status: `done`
  Goal: Independently accept the eleven-contract statement frame/producer composition and close only this family parent.
  Dependencies: `.1.1.1.2`
  Verification tier: `canonical`
  Focused checks: Complete fixed-input independent composition including nested/opaque/custom callback boundaries, public identity and event/source occurrence matching, actual falsifier RED controls and source closure; source-bound diagnostic replay/frame checks and observed original-context RED; complete direct consumers, book and doctrines.
  Canonical trigger: Parent/family closeout; exact staged canonical proof required before landing.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.3.json`
  Acceptance: All eleven selected producers have exact source origins where the canonical splitter publishes validated frames; preserve unchanged callback/public behavior and explicit unknown-callback limits. Do not close sibling twenty-contract composition or membership/replacement.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.3 - accept statement source family`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2`
  Status: `done`
  Goal: Independently compose all twenty PrimitiveBasicRules provenance contracts.
  Dependencies: `.1.3.3.0.7.2.2.0.1.1.1`
  Children: `.1.3.3.0.7.2.2.0.1.1.2.0`, `.1.3.3.0.7.2.2.0.1.1.2.1`
  Acceptance: Exact source/argument/occurrence public identities, all selected regex and statement frames, original private-channel guards and affected consumers pass before closing the family parent. No executable membership or public schema admission.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2.0`
  Status: `done`
  Goal: Establish the independent mixed twenty-contract BasicRules composition proof.
  Dependencies: `.1.3.3.0.7.2.2.0.1.1.1.3`
  Verification tier: `focused`
  Focused checks: Immutable regular Git inputs plus explicit authored probe overlays; twenty mixed public/private contract scans and original argument/occurrence/reference identities under three seeds; actual callback sequence equality, complete source-frame oracle and full Toolbox channels; four permanent private provenance guards and direct scanner/AST/order/raw consumers; reason-specific observed RED controls; actual book render, memory/Knowledge/claims/history/diff and all doctrines.
  Canonical trigger: None; bounded evidence preparation only. .1.1.2.1 owns the canonical family/parent closeout after this clean committed proof.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2.0.json`
  Acceptance: Literal input construction authors scalar spans and exact original arguments independently of scanned events/raw-text lookup. Mixed repeated and quoted regex matches, interleaved statement kinds, ignored comments and Unicode/CRLF retain each contract's original ordered events and private source identity. Capture actual producer/all supplied inputs/full channels and distinguishing controls without widening readiness or executable membership.
  Commit: Git is the accepted slice identity authority. Activate .1.1.2.1 only from the clean committed mixed-proof boundary.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2.1`
  Status: `done`
  Goal: Independently recur and canonically accept the twenty-contract BasicRules family.
  Dependencies: `.1.3.3.0.7.2.2.0.1.1.2.0`
  Verification tier: `canonical`
  Focused checks: Fresh exact immutable regular Git census with no overlays; actual committed mixed twenty-contract Toolbox probe/three seeds, original event/argument/occurrence identities and exact prior full-channel recurrence; eight complete original guards/direct consumers and three foreign-source probes; reason-specific independent RED controls; complete book render and prior claim freeze, memory/Knowledge/claim/history/diff and all doctrines.
  Canonical trigger: Twenty-contract family and BasicRules parent closeout; stage the complete candidate and require the exact canonical CI receipt before landing.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2.1.json`
  Acceptance: Close .1.1.2 and .1.1 only after the full mixed twenty-contract proof and canonical gate pass at the exact landing boundary. Remaining producer families, membership/replacement, marker/comment repairs and broader audits stay separately owned.
  Commit: Git is the accepted family identity authority; .1.1.2 and BasicRules .1.1 close through this canonical leaf only. Activate remaining PrimitivePipelineRules .1.2 after clean handoff.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3`
  Status: `done`
  Goal: Repair the selected consumer/render proof's transitive input closure and distinguishing falsification before further basic provenance work.
  Dependencies: `.1.3.3.0.7.2.2.0.1.1.0`
  Acceptance: Preserve all original outputs and initial publisher/claim identities. Establish the actual selected input graph using source-backed instrumentation and independent census; capture/freeze actual bytes or use an exact immutable Git boundary, execute reason-checked missing/changed-input and incomplete/failure TAP controls, and re-measure where original input identities cannot be recovered. Reconcile exact producer/document bytes and publication order without a self-hash or after-run live-doc drift. Split before implementation if necessary. All new broader results have complete three-leg claims or explicit scheduled gaps; this bounded repair does not close startup .5's historical project-wide audit.
  Children: `.1.3.3.0.7.2.2.0.1.1.3.0`, `.1.3.3.0.7.2.2.0.1.1.3.1`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.0`
  Status: `done`
  Goal: Prepare and independently verify a recoverable selected consumer/render input capsule and stable measurement producer.
  Dependencies: `.1.3.3.0.7.2.2.0.1.1.0`
  Verification tier: `focused`
  Focused checks: Git-derived input preparation plus independent capsule/source-reader census; observed missing/changed transitive input, changed directory population, unsafe archive path and altered source-owner rejection. Stable run/TAP reviewer controls use retained original passing observations without relabeling their boundary; syntax, book render with full book input capture, memory/Knowledge/claim/history/diff and all doctrines. Full unchanged consumer remeasurement belongs to .3.1 after this clean preparation landing.
  Canonical trigger: None; retained diagnostic proof instruments and explanatory development documentation only, without registered gate/public DSL/infrastructure changes.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.0.json`
  Acceptance: Recover all capsule paths exactly at the declared immutable Git boundary, derive directory membership independently and reject reason-checked missing/changed inputs. Retain the actual instrument and selected read-site evidence. The prepared runner never consumes live continuity bytes, writes only same-volume generated state, verifies all fixed inputs before and after and preserves complete channels incrementally. Do not claim thirteen-suite acceptance before .3.1 executes it.
  Commit: Bounded preparation only; .3.1 activates from the clean handoff and executes the full selected matrix. No new full-suite/DSL admission.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.1`
  Status: `done`
  Goal: Re-measure and independently accept the selected unchanged consumer/render proof at retained fixed input boundaries.
  Dependencies: `.1.3.3.0.7.2.2.0.1.1.3.0`
  Acceptance: Execute the exact thirteen selected suites and render original source-identical examples from the recoverable capsule; require actual complete TAP plans and clean finite exit channels. Independently gate all artifact contents and directory memberships, actual producer bytes and original source owners. Observe missing/changed transitive-input and incomplete/failing TAP RED controls. Preserve/supersede the earlier broader observation with explicit original/current boundaries and no after-run document hash refresh. Close .3 only after committed verified remeasurement; then resume statement framing .1.1.1.
  Verification tier: `canonical`
  Focused checks: Actual complete13-suite fixed-capsule run, source-identical book examples and supplied-input contents/modes/membership before/after every operation; independent exact suite/plan/reach/source/instrument identities, observed missing/changed-input and incomplete/failing-TAP controls. Original broader observation preservation and explicit supersession, complete fresh public book input capture/render, syntax, memory/Knowledge/claim/history/diff and all doctrines.
  Canonical trigger: Bounded P1 proof-repair parent closeout; exact staged tools/run_ci_local.sh receipt is required after the completed fixed-input remeasurement and documentation candidate are staged. No production/public DSL or registered gate movement.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.1 - accept source-bound consumer composition`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2`
  Status: `done`
  Goal: Complete remaining PrimitivePipelineRules source provenance.
  Dependencies: `.1.3.3.0.7.2.2.0.1.1`
  Children: `.1.3.3.0.7.2.2.0.1.2.0`, `.1.3.3.0.7.2.2.0.1.2.1`, `.1.3.3.0.7.2.2.0.1.2.2`, `.1.3.3.0.7.2.2.0.1.2.3`
  Acceptance: Keep literal receivers and structured statement/array plans; explicitly translate complete statement frames and do not feed masked operands into parsing.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0`
  Status: `done`
  Goal: Retain an independent source/argument diagnosis for the nineteen pipeline contracts before their remaining hooks.
  Dependencies: `.1.3.3.0.7.2.2.0.1.1.2.1`
  Verification tier: `focused`
  Focused checks: Immutable regular Git inputs plus explicit authored source/probe overlays; all nineteen public/private scanner contracts and original arguments/statement frames/Toolbox outputs under three seeds; distinguish the already instrumented set_value from actual absent remaining origins; exact receiver/pipeline-plan inputs, structured assignment and literal value-drop branches; independent source/argument oracles and observed RED evidence corruptions; affected unchanged consumers, complete book render, memory/Knowledge/claim/history/diff and all doctrines.
  Canonical trigger: None; bounded diagnosis/ownership split only. .1.2.3 owns canonical family closeout after source recording implementation.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0.json`
  Acceptance: Capture actual original source/arguments and missing private positions before changes. Literal construction defines exact scalar event/statement intervals without searching equal text. Preserve original callback plan inputs and compiler channels, including quoted syntax and repeated forms. Any surprising result gets a source-backed tool diagnosis and owned repair before acceptance; no production or public admission.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0 - diagnose pipeline source contracts`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1`
  Status: `done`
  Goal: Complete ten remaining pipeline regex hooks and the separately diagnosed split-source metadata repair.
  Dependencies: `.1.3.3.0.7.2.2.0.1.2.0`
  Children: `.1.3.3.0.7.2.2.0.1.2.1.0`, `.1.3.3.0.7.2.2.0.1.2.1.1`
  Acceptance: Both children verified and committed before statement implementation. Hook-only proof preserves original args; metadata repair declares its precise public diagnostic contract and compatibility limits.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.0`
  Status: `done`
  Goal: Record exact full-input source coordinates for the ten remaining pipeline regex producers.
  Dependencies: `.1.3.3.0.7.2.2.0.1.2.0`
  Acceptance: Original raw/args, callback effects and order remain exact. No masked receiver/operand parsing or public event fields. The diagnosed null split-source argument stays unchanged until .1.2.1.1.
  Verification tier: `focused`
  Focused checks: Actual original-owner RED and current GREEN on the same new regex regression; immutable parent regular inputs plus exact new fixture/original owner and candidate owner overlays; nineteen-contract before/after Toolbox channels, authored original args/frames, all eleven regex origins/event/argument identity and default callback inputs/results under three seeds. Seven direct consumers plus full Phase0, independent input/TAP/source corruptions, actual complete book capture/render, claim/Knowledge/memory/history/diff and all doctrines.
  Canonical trigger: None for private sidecar-only hooks preserving public raw/arguments/schema/default callbacks; separate metadata contract repair .1.2.1.1 and family canonical .1.2.3 own their broader boundaries.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.0.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.0 - retain pipeline regex source origins`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.1`
  Status: `done`
  Goal: Repair split_array's null source metadata at the public planner/scanner boundary.
  Dependencies: `.1.3.3.0.7.2.2.0.1.2.1.0`
  Acceptance: Resolve the producer/consumer contract explicitly and verify every maintained consumer; retain .1.2.0's original null observation, update public teaching and ownership. No unrelated DSL admission.
  Verification tier: `canonical`
  Focused checks: Same original-owner metadata RED/current GREEN; independent literal bare/literal/compound source cases, default plan and supplied legacy/canonical precedence values, source origin/reference/callback and exact lowering compatibility. Immutable regular Git boundaries plus exact fixture/producer overlays; original19-contract probe and all regex guards/direct consumers/full Phase0 where warranted, complete source-bound channels/input/TAP and distinguishing corruption controls; full book capture/render, exact historical selector original/current/composed guard with closed inputs and distinguishing controls, retained first canonical failure, memory/Knowledge/claim/history/diff and all doctrines.
  Canonical trigger: Public helper/canonical descriptor args.source value correction; stage complete verified candidate and require exact staged tools/run_ci_local.sh receipt before landing; the directly dependent gate correction also requires canonical tier. .1.2.3 remains separately canonical family closeout.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.1 - repair split source metadata`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.1.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.2`
  Status: `done`
  Goal: Bind exact original statement frames to the eight pipeline statement contracts and all original constructor branches.
  Dependencies: `.1.3.3.0.7.2.2.0.1.2.1.1`
  Acceptance: Reuse canonical frames only for exact original raw/source authority; preserve literal receivers and nested paths. Unknown/transformed/foreign callback results retain events without invented origins.
  Verification tier: `focused`
  Focused checks: Same original-owner RED/current GREEN statement fixture; literal original scalar intervals/occurrence order and both constructor branches, original event/argument identities; all five default callback signatures/results/counts, foreign/copied/transformed callback authority, nested collectors/errors/empty/rejected results. Original nineteen-contract full compiler recurrence with current split metadata expectation, immutable regular parent inputs/exact authored overlays, complete channels/byte/mode/population/TAP guards and distinguishing evidence RED controls; direct suites/full Phase0, book render, memory/Knowledge/claim/history/diff and all doctrines.
  Canonical trigger: None for private sidecar hooks preserving public events/arguments/default callbacks/lowering. Separate .1.2.3 owns full pipeline canonical family closeout; escalate this leaf if focused proof exposes cross-cutting uncertainty.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.2.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.2 - retain pipeline statement source origins`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.3`
  Status: `done`
  Goal: Independently compose and canonically accept all nineteen PrimitivePipelineRules provenance contracts.
  Dependencies: `.1.3.3.0.7.2.2.0.1.2.2`
  Acceptance: Close the pipeline family only after complete source-bound proof and canonical receipt. Flow/legacy/staged producers, executable membership/comments/replacement and broader audits remain separately owned.
  Verification tier: `canonical`
  Focused checks: Complete regular committed Git inputs with no overlays; all nineteen literal source/argument/interval/private returned/constructor/argument identities and five callback effects under three seeds, exact prior complete compiler recurrence, foreign-source and actual equal-valued copied-return controls. Fourteen unchanged direct suites, complete channels/content/mode/membership/TAP guards and distinguishing evidence corruptions; complete book inputs/render, prior claim freeze, memory/Knowledge/claim/history/diff and all doctrines.
  Canonical trigger: Pipeline family parent closeout; stage completed reviewable candidate and require exact tools/run_ci_local.sh receipt before landing/closing .1.2. Remaining producer/semantic and global audit owners stay separate.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.3.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.3 - accept pipeline source family`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3`
  Status: `done`
  Goal: Complete remaining FlowRules source provenance and recursive frames.
  Dependencies: `.1.3.3.0.7.2.2.0.1.2`
  Acceptance: Translate case/default block and inline-switch argument frames explicitly; preserve composite traversal rather than global lexical sorting.
  Children: `.1.3.3.0.7.2.2.0.1.3.0` diagnosis; implementation children are derived from its exact producer/recursive-frame inventory before production edits; final canonical family acceptance remains required.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.0`
  Status: `done`
  Goal: Diagnose all original FlowRules producer and recursive argument/source-frame contracts at an immutable input boundary, then own safe implementation slices.
  Dependencies: `.1.3.3.0.7.2.2.0.1.2.3`
  Verification tier: `focused`
  Focused checks: Actual public/private Flow scanner/Toolbox probes, independent literal original source/argument/interval/callback/recursive traversal oracle, current existing if_flow origins and original source authority; immutable regular Git plus exact authored probe/oracle overlays, complete command/channel/content/mode/population guards and distinguishing corruption controls. Affected unchanged source-frame/AST/order/flow consumers, complete book inputs/render, prior claim freeze, memory/Knowledge/claim/history/diff and all doctrines.
  Canonical trigger: None for bounded diagnosis and owned safe-slice planning preserving code/fixtures/public contracts. Separate final family closeout will require immutable recurrence and exact canonical receipt; escalate if diagnosis exposes cross-cutting uncertainty.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.0.json`
  Acceptance: Retain original observations and inspect exact mechanism/source locations with LinkedSpec tools. Every encountered defect gets reproduction/impact/repair ownership. Define precise producer and recursive-frame children only from observed original contracts; do not invent coordinates from equal raw text or globally sort composite traversal.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.0 - diagnose recursive Flow source frames`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.1`
  Status: `done`
  Goal: Record direct Flow regex and next statement source occurrences while preserving original events, arguments and callback behavior.
  Dependencies: `.1.3.3.0.7.2.2.0.1.3.0`
  Acceptance: Snapshot original match coordinates before callback parsing for thirteen direct regex producers including unchanged if_flow; bind next via existing statement-frame authority. Unicode/CRLF/repetition, aliases/bare markers, custom callbacks/nested restoration/error state, public compiler channels and rejected/empty scans are independently verified. Case/default recursive paths remain owned by .1.3.2.
  Verification tier: `focused`
  Focused checks: Retain original regression RED and corrected GREEN; independent literal raw/args/scalar intervals and actual returned/constructor/argument references for all14 direct contracts, aliases/bare markers, Unicode/CRLF/repetitions; default callbacks/full public compiler channels identical before/after and across three seeds. Existing statement-frame authority handles ignored/copied/transformed/foreign/error/nested/empty boundaries. Immutable complete regular Git plus exact authored overlays and one declared Flow owner delta; source/AST/order/trace consumers and Phase0, distinguishing evidence controls, complete book input/render, historical freeze, storage/memory/Knowledge/claim/history/both diff checks/all doctrines.
  Canonical trigger: None for private direct producer hooks preserving source recognition/public contracts. Complete Flow closeout .1.3.3 requires fresh immutable recurrence and exact canonical receipt; escalate for cross-cutting uncertainty or infrastructure/public changes.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.1 - retain direct Flow source origins`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2`
  Status: `done`
  Goal: Translate original recursive case/default block and inline argument source occurrences without changing composite order.
  Dependencies: `.1.3.3.0.7.2.2.0.1.3.1`
  Children: `.1.3.2.0` diagnose private MethodExpr/CSV occurrence authority and exact default/custom callback contracts; implementation leaf ownership follows that diagnosis; `.1.3.2.1` owns recursive Flow consumption after a verified bridge exists.
  Acceptance: Original full action source plus exact block/trimmed argument occurrence frames, never equal-text lookup. Preserve marker depth-first traversal followed by inline traversal, ordinary return identities/callback effects and source authority denial for transformed/copied/foreign callbacks. Direct MethodExpr consumers and whole Flow/source compatibility remain green.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0`
  Status: `done`
  Goal: Diagnose and specify invocation-local MethodExpr argument occurrence authority through original public parser/CSV callback probes.
  Dependencies: `.1.3.3.0.7.2.2.0.1.3.1`
  Acceptance: Retain actual callback source/argument identity, leading/trailing whitespace, dropped empty CSV slots, slash-pattern masks, repeated equal arguments, Unicode/CRLF, copied/transformed/foreign/opaque results, nested and exceptional invocations. Derive a bounded bridge leaf before production changes; no global cache or coordinate search.
  Verification tier: `focused`
  Focused checks: Immutable clean-activation regular Git population plus exact authored overlays; original parser/CSV input/result/reference/callback observations across three hash seeds, literal cumulative Unicode scalar boundaries for trim/empty slots/repeated twins/slash context and receiver calls. Exact copied/changed/foreign/opaque/nested/error callback behavior and caller error state are observed without granting hypothetical authority. Toolbox substitution/descriptor/parser dump and direct parser/AST/Flow/frame/order/trace consumers; independent distinguishing RED controls, complete book input/render, strict claim/live input identities, history/memory/Knowledge/diff and all commit doctrines.
  Canonical trigger: No production/public/infrastructure change in this bounded original-contract diagnosis. Bridge implementation follows its own verified leaf; Flow whole-family closeout .1.3.3 requires exact canonical CI.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0 - diagnose MethodExpr argument authority`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0.1`
  Status: `done`
  Goal: Publish invocation-local original CSV and parsed argument occurrence frames without changing ordinary parser results or callback contracts.
  Dependencies: `.1.3.3.0.7.2.2.0.1.3.2.0`
  Acceptance: Record canonical CSV flush boundaries and retained argument indices; translate original expression trim and payload bases before callbacks. Select exact returned canonical arrays/parser hashes plus original source authority, preserve per-entry changed-value denials, reject copied/foreign/opaque authority without altering returns. Nested collectors restore outer state; original exceptions/caller $@/receiver/helper-pattern context stay intact. No public fields/new callback/global cache/raw search. Retain independent literal RED/GREEN, all original diagnosis channels, direct MethodExpr/AST/Flow consumers and book teaching before commit.
  Verification tier: `focused`
  Focused checks: Independent literal RED/GREEN for all ten original cases23 intervals; actual returned CSV array/parser hash/args identity, per-entry changed frames, copied/foreign/opaque/rejected/empty/custom trim authority denials, nested invocation/exception/caller $@/receiver context. Same immutable complete regular Git and exact runtime overlays plus one MethodExpr owner delta; full original diagnosis parser/CSV/Flow/compiler channels identical before/after under three seeds. Direct AST/Flow/frame/order/trace/helper consumers and Phase0; reason-specific evidence controls, complete book input/render, actual strict claims and history/memory/Knowledge/path/storage/diff/all doctrines.
  Canonical trigger: Bounded private producer sidecars preserve ordinary APIs/recognition and callbacks; complete Flow .1.3.3 remains canonical. Escalate if focused proof exposes cross-cutting uncertainty or a public/infrastructure change.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0.1 - retain original method argument frames`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.1`
  Status: `done`
  Goal: Consume verified original block/argument frames in recursive case/default producers.
  Dependencies: `.1.3.3.0.7.2.2.0.1.3.2.0.1`.
  Acceptance: Independent original full-source scalar intervals distinguish direct and inline repeated twins, recursive attached blocks and nested inline expressions. Preserve exact event/argument references, normalization callbacks, marker-first/inline-second traversal, public compiler channels and unknown/transformed callback authority denial. No lexical sort, membership repair or new DSL admission.
  Verification tier: `focused`
  Focused checks: Independent original literal full-action scalar frames/event args/traversal and actual returned/constructor/args references for case/default attached recursion, inline/nested/repeated/quoted/empty-slot/Unicode/CRLF fixtures. Unknown/copied/changed/foreign/opaque parser and transformed trims retain ordinary behavior without borrowed argument authority; nested/exception/caller state/callback counts stay exact. Immutable complete regular Git plus exact runtime overlays and one Flow owner delta, unchanged original public/private callbacks/compiler channels under three seeds; affected AST/Flow/source/order/trace/helper consumers and Phase0. Distinguishing evidence RED controls, complete book inputs/render, strict claim/history/memory/Knowledge/path/storage/diff/all doctrines.
  Canonical trigger: Private recursive source telemetry preserving recognizers/public schema; fresh complete Flow .1.3.3 requires exact canonical CI. Escalate for changed public behavior or cross-cutting uncertainty.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.1 - retain recursive Flow source origins`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.3`
  Status: `done`
  Goal: Accept the complete original Flow provenance family after direct and recursive repairs.
  Dependencies: `.1.3.3.0.7.2.2.0.1.3.1` and `.1.3.3.0.7.2.2.0.1.3.2`
  Acceptance: Fresh immutable all-contract recurrence with independent source/argument/interval/traversal and actual returned-reference oracles, full callback/compiler channels, focused consumer compatibility, complete book inputs/render and exact staged canonical CI receipt before parent closure.
  Verification tier: `canonical`
  Focused checks: Fresh immutable activation regular Git inputs/no runtime overlays; all sixteen contracts with independent original source/args/scalar/traversal and actual event/constructor/args references, full prior guarded compiler/callback recurrence under three seeds; exact MethodExpr argument frames and original custom authority fixtures. Selected direct/recursive/argument/AST/frame/order/trace/raw/pipeline consumers. Rejection controls for omitted events/frames/references/input/commands/channels and bad authority outcomes; complete book input/render, claim/freeze/live identities, history/memory/Knowledge/diff and all doctrines. Final exact staged canonical CI receipt before family closure.
  Canonical trigger: Whole Flow family acceptance/parent closeout; exact staged tools/run_ci_local.sh is mandatory, with no claim of complete canonical proof until actual receipt matches candidate.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.3.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.3 - accept Flow source family`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4`
  Status: `done`
  Goal: Complete remaining LegacyRules source provenance.
  Dependencies: `.1.3.3.0.7.2.2.0.1.3`
  Acceptance: Split the large measured producer inventory into safe coherent families before any implementation; preserve legacy ownership and accepted slash patterns.
  Children: `.1.4.0` original inventory and safe family partition; implementation children follow only its actual source/argument/callback observations. Final whole Legacy family acceptance remains canonical.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0`
  Status: `done`
  Goal: Diagnose the complete original LegacyRules dispatcher/producer population and partition safe source-provenance families before implementation.
  Dependencies: `.1.3.3.0.7.2.2.0.1.3.3`
  Verification tier: `canonical`
  Focused checks: Actual LinkedSpec public/private scanner and Toolbox original full arguments/coordinate/callback/compiler observations; complete immutable regular Git plus exact authored overlays, full command/channel/content/mode/population guards and independent literal source/argument/scalar oracles. Complete dispatcher inventory and safe coherent partition coverage; unchanged affected AST/source/frame/order/legacy consumers; distinguishing evidence RED controls, complete book input/render, strict claim/freeze/current identities, memory/Knowledge/history/diff/all doctrines.
  Canonical trigger: Explicitly granted three-scalar engineering-note capacity prerequisite is owned within this leaf; newly accepted indexed ADR0127, governed rollover and exact staged receipt-bound canonical CI are mandatory before landing. Runtime diagnosis remains production-exact; no dirty task-tree pivot.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0 - diagnose Legacy source families`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1`
  Status: `done`
  Goal: Verify the public quoted boundary-label contract, reproduce exact comma/escape tokenization failure, and repair it before Legacy boundary provenance hooks.
  Dependencies: `.1.4.0` original diagnosis and safe partition.
  Acceptance: Independent literal quoted/word/empty/escaped/mixed arguments and original full source intervals; retain actual public scanner/substitution/descriptor/parser source before repair, RED/GREEN fixture, unchanged current boundary/capture/AST consumers and book. Preserve matching/labels/callbacks except the diagnosed quoted delimiter split; no new label syntax admission without existing contract evidence.
  Verification tier: `focused`
  Focused checks: Actual Toolbox Get/scanner/substitution/descriptor/parser-source baseline and repaired observations for independent literal quoted, bare, empty, escaped, mixed, repeated and Unicode/CRLF cases; meaningful original RED/repaired GREEN; existing boundary, typed source, AST/source/order/capture consumers and required Phase0; full input/channel guards and distinguishing evidence RED; book render, prior input freeze, memory/Knowledge/claims/history/doctrines/diff.
  Canonical trigger: none; bounded correction to existing accepted quoted arguments, with no new label-definition syntax, callback/dispatch/public-schema/CI/storage/dependency admission. Whole Legacy .1.4.7 remains canonical milestone; canonical proof is required before push.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1 - preserve quoted boundary label atoms`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1`
  Status: `done`
  Goal: Repair the independently reproduced nested escaped-comma helper failure after atomic label tokenization lands cleanly.
  Dependencies: `.1.4.0.1` clean commit; use its actual public descriptor/dump/runtime and scoped trace evidence.
  Acceptance: Toolbox exact source-span-missing mechanism; literal unknown-escape plus quote/backslash/bare/Unicode/repeated nested contexts; independently retained RED/GREEN and immutable before/after inputs; fix original source/rewritten occurrence ownership without broad equal-text guessing or new grammar; selected nested/canonical/source consumers/Phase0, recurring Phase0 public quoted-label and unknown-escape regression (the current new focused fixture is not individually invoked by canonical CI), book/Knowledge/claim and per-leaf commit before .1.4.2. Decide bounded implementation only after scoped diagnosis.
  Verification tier: `focused`
  Focused checks: Original actual Toolbox public assignment/return/hash/block/standalone/repeated Unicode-CRLF boundary observations and typed AST fake-source/label-slot controls; literal grammar/escape/leading-zero/keyword/bare-label expectations; original RED/repaired GREEN, exact unaffected scanner/substitution and source serializer/decoder reconstruction. Existing AST/helper-source/source-frame/order/nested/typed consumers and Phase0 with recurring new public cases; all current quoted runtime assertions enabled. Full input/channel/exit/TAP guards, distinguishing evidence controls, book/render/claims/Knowledge/memory/history/doctrines/diff.
  Canonical trigger: none; restore existing recognized helper behavior through existing typed value lowering without new grammar, node schema/capability/backend/callback/CI/storage/dependency admission. Canonical remains required at family .1.4.7 and before push.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1 - preserve nested boundary call spelling`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1.1`
  Status: `done`
  Goal: Resolve rollover/whitespace compatibility without losing immutable source bytes or weakening Git checks.
  Dependencies: `.1.4.6`; complete before Legacy family `.1.4.7` closeout.
  Acceptance: Toolbox existing history read/roll tools first; retain original RED and supported change/note boundaries, complete source/suffix/manifest rows and pending/orphan recovery; final live roots pass ordinary whitespace checks without weakening immutable byte guarantees or collection bounds. Declare exact owning paths/claim and canonical tier before infrastructure edits. No history-part edits, capacity increases or gate bypass.
  Verification tier: `canonical`
  Focused checks: Original actual rollover EOF RED and repaired whitespace GREEN for both change/note boundaries; independently reconstruct complete clean source and exact selected suffix/prior rows, preserve removed terminal separators through bound Git source identities. Exercise exact orphan/pending rerun recovery and corrupt/missing/symbolic target rejection through public commands, plus immutable record rewrite/uncommitted pressure/no-op controls. Meaningful ongoing regression gates actual producer; book render, strict claim/Knowledge/memory/history/doctrines/diff.
  Canonical trigger: Workflow/history infrastructure and registered gate integration; stage exact complete candidate then run tools/run_ci_local.sh for receipt-bound canonical acceptance before normal landing.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1.1.json`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.1`
  Status: `done`
  Goal: Retain original source origins for eight call/return/push dispatcher contracts.
  Dependencies: `.1.4.0` clean diagnosis.
  Acceptance: Preserve existing return_general hook/helper-pattern view, original push literal exclusions and recognize_once/observe_recognition call exclusions; exact before/after public args/callback/compiler channels, original scalar bounds/reference identities, RED/GREEN and focused consumers. No new compatibility syntax admission.
  Verification tier: `focused`
  Focused checks: Actual original producer RED and hooked GREEN from immutable clean Git inputs plus explicit fixture/probe overlays; all112 Legacy contracts under seeds0/1/42, exact original events/args/default callbacks and public substitution/descriptor/parser-source channels. Independent literal Unicode/CRLF/repeated bounds, constructor/returned/args references and exclusion/empty controls. Existing source/frame/AST/order/nested/trace consumers and required Phase0; retained channel/input/TAP/source corruption controls; complete book render, memory/Knowledge/claims/history/all doctrines/diff.
  Canonical trigger: none; private hooks preserve dispatch, syntax, callbacks/public schemas and existing CI/dependency/storage mechanisms. Complete Legacy family .1.4.7 remains the designated canonical acceptance boundary.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.1 - retain Legacy call source origins`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.2`
  Status: `done`
  Goal: Retain original source origins for26 anonymous capture dispatcher contracts.
  Dependencies: `.1.4.1`; quoted boundary `.1.4.0.1` verified; nested unknown-escape `.1.4.0.1.1` repaired before boundary hook.
  Acceptance: Original capture macro/zero-argument/boundary occurrences and aliases retain matching, exact args/constructor/returned references and full public compiler channels. Snapshot own coordinates before callbacks/argument parsing, preserve original quoted syntactic population and all unaffected contracts; no raw-text lookup.
  Verification tier: `focused`
  Focused checks: Full current112-contract/115-case recurrence under three seeds, independent original scalar intervals/raw/args and actual returned/constructor/argument identities, complete unchanged callback/substitution/diagnostic/parser-source channels. Original RED/repaired GREEN of expanded helper-source fixture, existing AST/statement/order/nested/trace/typed/quoted/nested-boundary consumers and Phase0. Exact source inverse reconstruction outside26 hooks, full manifests/channel/exit/TAP guards and distinguishing RED; rendered book/freeze/claims/Knowledge/memory/history/diff/all doctrines.
  Canonical trigger: none; private producer source sidecars preserve all original grammar/callback/public/compiler behavior without API/backend/CI/storage/dependency admission. Canonical remains required for scheduled rollover infrastructure .1.4.0.1.1.1, family .1.4.7 and push.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.2.json`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.3`
  Status: `done`
  Goal: Retain original source origins for17 named capture dispatcher contracts.
  Dependencies: `.1.4.2`.
  Acceptance: Exact one-mark/two-mark and take/read alias occurrences preserve original mark argument order, source scalar intervals/repeated Unicode/CRLF twins/actual event and argument objects, full public compiler/callback channels and focused capture consumers.
  Verification tier: `focused`
  Focused checks: All112 contracts/115 cases under three seeds, independent original literal mark argument order/raw/Unicode-CRLF repeated scalar intervals and actual returned/constructor/argument identities; full unchanged public callbacks/compiler channels. Expanded helper-source original RED/repaired GREEN; existing ten source/AST/order/nested/trace/typed/boundary/Phase0 consumers plus complete_named_mark_contract live/generated consumer. Whole-file source inverse restricted to17 hooks; complete manifests/stream/exit/ordered TAP guards and observed RED controls; rendered book/freeze/claims/Knowledge/memory/history/diff/all doctrines.
  Canonical trigger: none; bounded private source sidecars preserve original grammar/public runtime/compiler behavior; family .1.4.7, scheduled rollover infrastructure and push still require canonical.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.3.json`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.4`
  Status: `done`
  Goal: Retain original source origins for14 mark-control dispatcher contracts.
  Dependencies: `.1.4.3`.
  Acceptance: Preserve original mark_copy target/source order and mark creation/query/reset raw/args/reference/source contracts; unchanged callback and public compiler behavior, literal RED/GREEN source fixture and focused named-mark consumers.
  Verification tier: `focused`
  Focused checks: All112 contracts/115 cases/three seeds, original literal target/source and symbolic mark arguments, repeated Unicode-CRLF scalar intervals and actual event/constructor/args identities; full unchanged public callback/compiler channels. Expanded original RED/repaired GREEN source fixture; eleven current source/AST/order/nested/trace/typed/boundary/named live-generated/Phase0 consumers; entire original source inverse restricted to14 hooks; complete input/channel/exit/ordered TAP guards and independent RED controls, including reversed mark-copy args and stable-ID family selection. Rendered book/freeze/claims/Knowledge/memory/history/diff/all doctrines.
  Canonical trigger: none; private source sidecars preserve original public/runtime/grammar behavior. Family .1.4.7, scheduled rollover infrastructure and push still require canonical.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.4.json`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.5`
  Status: `done`
  Goal: Retain original source origins for15 cursor/input dispatcher contracts.
  Dependencies: `.1.4.4`.
  Acceptance: Zero-argument cursor/input/control producers and balanced input_slice expression preserve original recognizers/args/raw, exact repeated source intervals/actual objects and public compiler channels; source-location/cursor consumers and original slash/quote contexts stay unchanged.
  Verification tier: `focused`
  Focused checks: All112 contracts/115 cases/three seeds, original empty arguments and balanced input_slice raw expression, repeated Unicode-CRLF scalar intervals and actual event/constructor/argument identities; all public callback/compiler channels unchanged. Original RED/repaired GREEN helper-source fixture and eleven boundary/typed/source/AST/order/nested/trace/named/Phase0 suites; whole-file inverse restricted to15 hooks; strict complete Git/overlay/producer/stream/exit/ordered TAP guards and actual reason-specific corruption RED. Rendered book/freeze/claim/Knowledge/memory/bounded histories/diff and all normal doctrines.
  Canonical trigger: none; private origins preserve original public/runtime/grammar behavior. Full-family .1.4.7, scheduled rollover infrastructure and push remain canonical.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.5.json`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.5`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.6`
  Status: `done`
  Goal: Retain original source origins for32 entry/match dispatcher contracts.
  Dependencies: `.1.4.5`.
  Acceptance: Preserve original zero-argument/index/name/alias producers and their raw/args/actual references/scalar occurrence bounds, original event ordering/public compiler channels and focused entry/match/source projections.
  Verification tier: `focused`
  Focused checks: All112 contracts/115 cases/three seeds, original index-string/name/empty args and alias raw spelling, independent repeated Unicode-CRLF scalar bounds and actual event/constructor/args references; complete original public compiler/callback channels. Expanded original RED/repaired GREEN and twelve source/boundary/typed/AST/order/nested/trace/named/generated-entry/Phase0 suites; whole-file inverse restricted to32 hooks. Strict Git/overlay/producer/stream/exit/ordered TAP guards and effective reason-specific corruptions including index/name/alias/regex/snapshot changes. Book/claim/freeze/Knowledge/memory/histories/diff and all doctrines.
  Canonical trigger: none; private origins preserve public/runtime/grammar behavior. Scheduled rollover infrastructure .1.4.0.1.1.1 and fresh complete-family .1.4.7 require canonical before parent closure; push remains canonical.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.6.json`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.6`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.7`
  Status: `done`
  Goal: Independently accept the complete Legacy source family.
  Dependencies: `.1.4.6`, `.1.4.0.1`, `.1.4.0.1.1` and rollover repair `.1.4.0.1.1.1`.
  Acceptance: Fresh immutable all112-contract recurrence from committed producers, original independent literal scalar/args/reference/callback/compiler oracles and precise separately verified boundary correction; complete changed-surface/direct consumers/book/claims/live docs and exact staged canonical receipt before parent closure.
  Verification tier: `canonical`
  Focused checks: Fresh complete regular committed Git input superset without overlays; original115-case/112-contract independent literal source/args/scalar oracle and actual reference identity, complete callback/compiler channels under three seeds, all twelve direct consumers with exact ordered positive TAP and nested-failure rejection. Effective evidence RED controls; complete book render/capsule, historical hash freeze, current claims/Knowledge/memory/bounded histories/diff/all doctrines.
  Canonical trigger: Complete Legacy-family milestone and parent closeout; exact staged canonical receipt required before landing, then normal hooks, brief0 and clean handoff before staged/progressive/recognition diagnosis.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.7.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.7 - accept complete Legacy source family`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.7`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5`
  Status: `done`
  Goal: Complete staged/progressive/recognition source provenance.
  Dependencies: `.1.3.3.0.7.2.2.0.1.4`
  Children: `.1.5.0`, `.1.5.1`, `.1.5.2`, `.1.5.3`, `.1.5.4`; diagnosis preserves the original seven-contract partition before production edits.
  Acceptance: Use published LinkedSpec contracts and exact option/token/transaction sources; only this repository is writable and RGX/PGEN stay black boxes.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0`
  Status: `done`
  Goal: Diagnose and partition the staged/progressive/recognition source producers before implementation.
  Verification tier: `focused`
  Focused checks: Exact committed input/source census; actual private scanner and public Get/return_descriptor/call_spec_handler_subst/dump_parser_source observations under selected deterministic seeds; original source/argument/reference/callback oracle and effective reason-specific evidence controls; unchanged direct consumers; book render, claim/Knowledge/memory/history/doctrines/diff hygiene.
  Canonical trigger: none for bounded evidence and task partition without production, contract, format, admission or infrastructure change; complete family acceptance remains a separate canonical child.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0.json`
  Acceptance: Preserve exact originals and observed producer mechanisms, identify every remaining syntactic origin gap, and schedule safe independently verifiable implementation children. Limits and rejected/interrupted evidence remain explicit. Commit the diagnosis before selecting an implementation child.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0 - diagnose dedicated source producers`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.1`
  Status: `done`
  Goal: Retain original staged annotation statement origins.
  Dependencies: `.1.5.0`
  Verification tier: `focused`
  Focused checks: Original staged recurring fixture RED/GREEN; immutable before/after dedicated oracle under seeds0/1/42 with exact callbacks/compiler channels; actual event/argument identities and copied/foreign/transformed/nested/error controls; nine direct consumer suites plus required Phase01035; effective evidence RED, full book render, claim/Knowledge/memory/history/doctrines and diff hygiene.
  Canonical trigger: none for one private producer source-origin hook with no public contract, format, admission or infrastructure movement; dedicated family acceptance .1.5.4 remains canonical.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.1.json`
  Acceptance: Observe RED on the unchanged original dedicated oracle; privately acquire canonical original statement frames only during recording, capture the same returned event/argument objects and decline transformed/copied/foreign source. Preserve valid direct/derived text plans, literal normalized options, invalid-event validation, exclusive ownership, callback order and all complete public Toolbox channels under the original seeds. Run changed-surface/direct consumers and required action-rewriter Phase0; freeze prior live claims before mutable publication changes; commit before progressive .1.5.2.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.1 - retain staged annotation statement origins`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.2`
  Status: `done`
  Goal: Retain original progressive annotation statement origins.
  Dependencies: `.1.5.1`
  Verification tier: `focused`
  Focused checks: Original progressive recurring fixture RED/GREEN while all staged groups remain exact; immutable before/after seven-contract channels under seeds0/1/42, actual references/callbacks and unsupported/nested/error coordinates; preceding ten suites including required Phase01035 plus the nine-group progressive authority consumer; progressive component contract gate in actual tracked Git context; effective evidence RED, full rendered book and claim/Knowledge/memory/history/doctrines/diff hygiene.
  Canonical trigger: none for one private source-origin producer hook; dedicated-family acceptance .1.5.4 remains the canonical boundary.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.2.json`
  Acceptance: Original RED/GREEN distinguishes repeated annotations and actual statement intervals/returned references; preserve original parser/top/span operands, invalid/dynamic/arity events, callback order, exclusive assignment ownership and complete Toolbox channels. Decline unsupported callback coordinates, re-run original diagnosis and changed-surface/direct consumers plus required Phase0, then commit before recognition .1.5.3.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.2 - retain progressive annotation statement origins`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.3`
  Status: `done`
  Goal: Retain original recognition and recursive-observation statement origins.
  Dependencies: `.1.5.2`
  Acceptance: Original RED/GREEN covers checkpoint/attempt/commit/rollback/observation and exact repeated scalar intervals. Preserve token/result/unevaluated callee and malformed observation arity/operand fields, returned event/argument objects, public callback sequence and generic-call/assignment exclusions. Canonical frames authorize only unchanged original raw; custom callbacks gain no invented source. Re-run complete original diagnosis and direct consumers plus required Phase0, preserve all separate defect owners, commit before canonical .1.5.4.
  Verification tier: `focused`
  Focused checks: Original recognition/observation recurring fixture RED/GREEN; all seven dedicated contracts and complete prior staged/progressive channels under original seeds0/1/42; actual constructor/argument references, callbacks, copied/foreign/transformed/fatal/nested cases; direct recognition/observation/authority/generated consumers and source-frame/order/AST consumers plus required Phase0 and syntax; actual-root recognition component gate; independent effective evidence controls, full rendered book and claim/Knowledge/memory/history/doctrines/diff hygiene.
  Canonical trigger: none for private recognition-family source-origin hooks; dedicated acceptance .1.5.4 remains canonical.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.3.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.3 - retain recognition annotation statement origins`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.4`
  Status: `done`
  Goal: Independently accept complete dedicated annotation source provenance.
  Dependencies: `.1.5.3`
  Acceptance: Fresh immutable committed producer recurrence without overlays; all seven original contracts/cases/events/statement intervals, actual references and complete callback/Toolbox channels under the original seeds. Independently effective evidence controls, all changed-surface/direct consumers, full rendered book and source-bound claims/Knowledge/continuity; exact staged canonical receipt and normal commit hooks before closing .1.5. All-producer composition .1.6, executable membership/replacement and separate runtime defects remain owned.
  Verification tier: `canonical`
  Focused checks: Fresh immutable regular committed Git inputs with no overlays; all original seven-contract22-case42-event63-frame42-origin channels under seeds0/1/42, full preceding channel equality and actual references/callbacks; twelve unchanged direct consumers excluding Phase0 in this capture, whose mandatory execution/syntax is covered by exact staged canonical CI; effective independent original-evidence RED; full rendered book and source-bound claim/Knowledge/memory/history/doctrine/diff proof.
  Canonical trigger: Dedicated annotation-family milestone/parent closeout .1.5; exact staged tools/run_ci_local.sh receipt plus normal hooks required before landing.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.4.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.4 - accept complete dedicated source family`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6`
  Status: `done`
  Goal: Independently compose all producer provenance.
  Dependencies: `.1.3.3.0.7.2.2.0.1.5`
  Acceptance: Verify every selected producer/source frame, public-event equality, opaque/error/order invariants and source-bound recurrence before closing this private parent.
  Children: `.1.3.3.0.7.2.2.0.1.6.0`, `.1.3.3.0.7.2.2.0.1.6.1`
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.0`
  Status: `done`
  Goal: Compose the accepted original producer populations and verify real cross-family recording isolation.
  Dependencies: `.1.5.4`
  Verification tier: `focused`
  Focused checks: Complete immutable regular committed input census with exact authored probe/oracle overlays only; unchanged accepted family probes and independent original event/argument/scalar oracles under three seeds, complete previous channel equality at declared boundaries, actual seven-family dispatch order and original references/callbacks. Real nested cross-family scans, opaque/empty/exception/caller-error and occurrence/order isolation; effective reason-specific observed RED controls, complete direct-consumer TAP and source/byte/mode/member/channel guards. Full book input/render/control proof, original-hash historical freeze, claim/Knowledge/memory/history/diff and all doctrines.
  Canonical trigger: None for bounded private evidence/teaching without production or public-contract changes; .1.6.1 independently owns immutable recurrence, exact canonical acceptance and parent closeout. Escalate here if focused proof exposes cross-cutting uncertainty.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.0.json`
  Acceptance: Retain all original family oracles and historical observations. Establish selected contract/family and per-seed counts from actual complete channels, preserving original aggregation rather than guessing totals. Cross-family instrumentation must observe real producers and returned objects, with independent literal intervals; no inferred raw pairing, global lexical sort, fabricated provenance or arbitrary callback/admission claim. Every actual mismatch is diagnosed with LinkedSpec tools and owned before proceeding. .0.1 stays active until .1.6.1 lands.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.0 - compose all scanner source producers` (identity from Git after landing).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.1`
  Status: `done`
  Goal: Independently accept immutable all-producer composition and close private provenance.
  Dependencies: `.1.6.0`
  Acceptance: Close only .1.6 and private provenance .0.1 after the independently reviewed committed recurrence and canonical receipt land. Executable quoted/comment membership .0.2, precise replacement .0.3, recurring registration .0.4 and separately owned runtime/diagnostic defects retain their owners.
  Verification tier: `canonical`
  Focused checks: Fresh complete regular committed Git population without overlays; unchanged original probes and corrected committed nested probe under seeds0/1/42, independent literal event/argument/scalar/reference/order/error oracles and exact complete previous channels. Full ordered29-suite TAP, guarded command/input/object/content/mode/member/channel population, reason-specific effective RED, original151-hash historical freeze and complete public-book input/render/control proof. Claim/Knowledge/memory/history/diff and all ten doctrines.
  Canonical trigger: Immutable all-producer acceptance and private provenance parent closeout; exact staged tools/run_ci_local.sh receipt, required Phase0 and normal hooks must pass before landing .1.6.1 and closing .1.6/.0.1.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.1 - accept all producer source provenance` (derive identity from Git after landing).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2`
  Status: `done`
  Goal: Exclude authored quoted/pattern data using exact producer occurrence provenance.
  Dependencies: `.1.3.3.0.7.2.2.0.1`
  Children: `.1.3.3.0.7.2.2.0.2.0`, `.1.3.3.0.7.2.2.0.2.1`, `.1.3.3.0.7.2.2.0.2.2`
  Acceptance: Reuse existing quote/host-quote/helper-pattern/slash-call contracts, retain original arguments, genuine literal receivers and true dependencies; no globally masked parsing or inferred raw-key pairing. Replay exact quoted/repeated/order guards and direct consumers before committing.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0`
  Status: `done`
  Goal: Implement private executable source membership without changing compiler discovery.
  Dependencies: `.1.3.3.0.7.2.2.0.1`
  Verification tier: `focused`
  Focused checks: Actual original private scans distinguish quoted/interleaved occurrences before selector implementation; unchanged independently authored scalar/event/reference/argument oracles and complete TAP RED/GREEN. Exercise quoted openers used by genuine literal receivers, escapes/Unicode/CRLF, existing host quotes and helper patterns/numeric slash calls, comments as separately owned compatibility, exact family occurrence order, missing/foreign provenance, empty/opaque returns and caller errors. Run unchanged selected source/AST/canonical/regex/direct consumers, source-bound independent evidence controls, actual book render, claim/Knowledge/memory/history/diff and all doctrines.
  Canonical trigger: None for this bounded unused private selector; public compiler collector changes belong to .2.1 and independent canonical acceptance .2.2. Escalate if focused proof finds cross-cutting uncertainty.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0.json`
  Acceptance: Select only from actual event-reference-bound original intervals, without searching equal raw strings, globally sorting, parsing masked arguments or adding public event fields. Preserve untouched event/argument/origin objects and opaque/empty identity. Existing quote-value/readiness/replacement/marker/comment defects stay open until their actual repair leaves land. Commit this private unit before activating compiler integration.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0 - select private executable source occurrences` (derive identity from Git after landing).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1`
  Status: `done`
  Goal: Connect private membership to compiler helper collection while retaining original dependencies and source authority.
  Dependencies: `.1.3.3.0.7.2.2.0.2.0`
  Verification tier: `focused`
  Focused checks: Original public Get/descriptor/substitution/dumped and fresh emitted probes; independently authored compiler selection regression against before and after owners, original event/argument/reference/order/source authority and dependency/caller-error guards. Unchanged private provenance, AST, canonical, regex, source-frame, trace, raw-readiness and Phase0 direct consumers; retained complete command channels and input identities; distinguishing before-owner RED. Render changed mdBook; claim/Knowledge/memory/history/diff and all doctrines.
  Canonical trigger: None for bounded compiler membership integration; independent immutable membership acceptance and parent closeout .2.2 require exact canonical proof. Escalate if focused evidence exposes cross-cutting uncertainty.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1.json`
  Acceptance: Reproduce original public quote/mapping guards, use real producer origins, preserve original argument/reference/order/error channels and legitimate literal receivers; prove actual native/fresh improvement and retain still-open replacement/diagnostic/comment boundaries. Declare exact affected compiler owners and verification tier before changes.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1 - connect compiler source membership` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2`
  Status: `done`
  Goal: Independently accept committed executable membership through exact canonical proof.
  Dependencies: `.1.3.3.0.7.2.2.0.2.1`
  Acceptance: Fresh immutable membership recurrence, original literal/occurrence/slash/receiver/raw/control oracles and direct consumers, effective evidence/publication controls and source retention, exact staged canonical receipt and normal hooks before closing membership .0.2. Selected replacement .0.3 and recurring parent acceptance .0.4 remain separate.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.0`
  Status: `done`
  Goal: Retain bounded immutable membership recurrence, exact historical-auditor repair and the newly exposed callable regression without closing membership.
  Verification tier: `focused`
  Focused checks: Retained complete immutable70-command compiler/public/direct-consumer measurement and original RED/evidence controls; exact historical source inverse and five denials/isolated recovery; complete failed canonical streams and staged candidate patches; public ToolBox/native/fresh/AST/substitution/source-range callable diagnosis and effective observation controls. Book render, claim/memory/Knowledge/history/diff and normal doctrines/hooks.
  Canonical trigger: None for this bounded proof checkpoint and evidence-auditor correction; no parent/admission closure or successful canonical measurement is claimed. Known compiler signature regression is owned by .0.2.2.1 and corrected committed acceptance by .0.2.2.2 before any membership closure.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.0.json`
  Acceptance: Preserve all original completed measurements and actual rejected instruments, publish the observed compatibility defect honestly, retain the exact whole-file historical inverse and reject unrelated changes. Leave membership parent and independent acceptance active; commit this finished checkpoint before corrective production work.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.0 - retain bounded membership proof` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.1`
  Status: `done`
  Goal: Preserve callable signature pipe precedence in private compiler source membership.
  Dependencies: `.1.3.3.0.7.2.2.0.2.2.0`
  Acceptance: Original x,y is typed correctly but the membership range from the signature closer consumes the return tail; native/fresh return undef with undefined cb. Preserve exact unquoted callable signature delimiters ahead of generic host-quote suffix recognition while respecting genuine host-quote openers. Verify fixed/rest y/tr/s/q/qq/qx/qr/m, zero/nested/quoted headers, genuine host quotes, unchanged typed errors and literal receivers. Preserve original source/AST/signature/values and real producer origins, retain before RED and new GREEN, direct consumers and appropriate complete Phase0, then commit. Parent acceptance stays open.
  Verification tier: `focused`
  Focused checks: Author actual operator/header/host-quote/body/source/reference regression before code changes; retain complete immutable original-owner RED/current-owner GREEN with exact declared source/test overlays and input guards. Original isolated callable before channels and independently fresh emitted after values; unchanged callable/AST/private/source-frame/regex/raw/trace/generated consumers and complete Phase0. Preserve old318-input claim hashes, effective component/evidence/history/render controls; syntax/book/Knowledge/memory/history/diff and normal doctrines/hooks.
  Canonical trigger: None for the exact private lexical precedence correction; no grammar/backend/public schema/parent closure. Fresh committed .0.2.2.2 requires exact canonical acceptance before membership closes. Escalate further cross-cutting uncertainty before landing.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.1 - preserve callable signature membership` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2`
  Status: `done`
  Goal: Independently accept corrected committed compiler membership through exact canonical proof.
  Dependencies: `.1.3.3.0.7.2.2.0.2.2.1`
  Acceptance: Fresh immutable committed inputs without production overlays; original membership/literal/public-channel/value/source authority plus callable signature regression and unchanged direct consumers. Effective evidence controls, source retention, teaching and exact staged canonical receipt/normal hooks close .0.2.2 and membership .0.2 only. Precise replacement .0.3, recurring .0.4, diagnostic origin .7.2.2.1 and comments .7.3 remain separate.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.0`
  Status: `done`
  Goal: Retain bounded corrected membership recurrence and own the grouped-pattern defect.
  Dependencies: `.1.3.3.0.7.2.2.0.2.2.1`
  Verification tier: `focused`
  Focused checks: Complete immutable73-command compiler40/original22-public/callable3/direct16-suite proof and retained original RED/effective controls; actual grouped primitive/return-family diagnostics with complete committed inputs and separately declared observer programs, source/real origin/native/fresh channels and distinguishing controls. Exact202-hash historical freeze, full book render/claim/Knowledge/memory/history/diff and normal hooks.
  Canonical trigger: None for this bounded proof checkpoint and diagnosis; no production or parent/admission closure. Grouped-pattern correction .1 and fresh committed canonical .2 remain mandatory before membership closes.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.0.json`
  Acceptance: Preserve completed original bounded recurrence without promoting successful values to full membership acceptance. Record exact new defect/reproduction/impact/repair owner and original instrument retention, commit the bounded proof, then activate repair .1 from clean HEAD.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.0 - retain grouped-pattern membership diagnosis` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1`
  Status: `done`
  Goal: Preserve grouped helper-pattern roles in compiler membership inside callable signatures.
  Dependencies: `.1.3.3.0.7.2.2.0.2.2.2.0`
  Acceptance: Author grouped dot/comma and genuine/numeric/host/indexed/body/nested/operator/fixed/rest controls before production; retain original source-bound RED and exact GREEN, original public/native/fresh/metadata/channel authority, all unchanged direct consumers/full Phase0, book/claims/Knowledge and normal hooks. Parent remains open for .2.
  Verification tier: `focused`
  Focused checks: Authored grouped dot/comma/operator/fixed/rest/zero/nested/body/host/numeric/indexed controls precede production; immutable original RED/corrected GREEN under seeds0/1/42, actual primitive origins/references/arguments/order and caller errors. Six original public grouped sources retain source/AST/native/fresh/error channels while correcting only false membership/counters. Default helper-query and unchanged consumer populations, full Phase0, exact historical hash freeze, book/claim/Knowledge/memory/history/diff and normal hooks.
  Canonical trigger: None for this bounded compiler-specific repair. Fresh committed canonical .0.2.2.2.2 remains mandatory before membership parents close; no public schema or grammar admission.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1 - preserve callable grouped-pattern membership` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.2`
  Status: `done`
  Goal: Independently accept committed membership including callable grouped patterns.
  Dependencies: `.1.3.3.0.7.2.2.0.2.2.2.1`
  Acceptance: Fresh immutable corrected committed inputs without production overlays; original membership/signature/grouped-pattern/source/argument/reference/value/error/metadata oracles and unchanged complete consumers. Effective evidence/retention/render controls and exact staged canonical receipt/normal hooks before closing this acceptance parent, .0.2.2 and membership .0.2 only. Replacement .0.3, recurring .0.4, diagnostic origin .7.2.2.1 and comments .7.3 remain separate.
  Verification tier: `canonical`
  Focused checks: Fresh exact committed compiler/public/callable/grouped/default-query/consumer populations under seeds0/1/42 without overlays; original source/AST/event/origin/argument/reference/value/error/metadata oracles, historical RED and effective evidence/history/render controls. All22 consumers/full Phase0; claim/Knowledge/memory/history/diff and normal hooks.
  Canonical trigger: Membership parent closeout requires exact staged receipt-bound tools/run_ci_local.sh after complete independent committed acceptance. No closure on a failed candidate.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.2.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.2 - accept committed compiler membership` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3`
  Status: `active`
  Goal: Replace only the selected executable residual occurrence, preserving quoted twins and literal bytes.
  Dependencies: `.1.3.3.0.7.2.2.0.2`
  Acceptance: Verify original and rewritten source frames, mixed identical occurrences in both orders, interleaved calls, nested/deferred values and native/fresh host-call repair. Preserve genuine raw spans and existing family ordering, then commit.

  Children: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.2`
  Safe-slice split: First retain current Toolbox source/AST/substitution/descriptor/dump/native/fresh observations and independent identical-occurrence oracles; select the exact original/rewritten frame owners from reached traces. Repair only that measured scope in .1; .2 independently recurs committed behavior and requires exact canonical receipt before parent closure. Do not infer spans from equal raw text or change contract-family precedence. Diagnostic origin, comments and recurring registration keep their existing owners.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0`
  Status: `done`
  Goal: Diagnose the selected residual occurrence in original and rewritten source frames.
  Dependencies: `.1.3.3.0.7.2.2.0.2`
  Verification tier: `focused`
  Focused checks: Actual public Toolbox observations and reached source-location traces; independent literal/occurrence/frame/order/native/fresh/error oracles, exact committed producer/input identities, complete diagnostic RED with healthy guards, effective reason-specific evidence controls; unchanged AST/canonical/source-membership consumers, actual book render, claims/Knowledge/memory/history/diff and all normal doctrines.
  Canonical trigger: None; diagnosis and safe ownership decomposition only. Repair and committed acceptance remain separately owned; no behavior or public contract admission here.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0.json`
  Acceptance: Retain exact original source and all observed failures without claiming runtime repair. Distinguish selected real origins from actual replacement locations in both orders, repeated and interleaved twins, nested/deferred and rewritten data; preserve arguments/references, genuine raw spans, family order and successful guards. Select a safe .1 scope from observed mechanisms and commit.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0 - retain exact replacement diagnosis` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1`
  Status: `active`
  Goal: Repair only the measured selected-occurrence replacement boundary.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0`
  Acceptance: Author source-identical RED/GREEN before production changes; preserve original/rewritten literal bytes, real origin/reference identity, genuine raw spans, arguments, family order and native/fresh/error contracts. Split further before widening ownership; focused verification and normal hooks precede .2.

  Children: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1`
  Safe-slice split: Private origin handoff through actual compiler event copies first, then exact original-to-rewritten interval mapping and insertion ownership. The before diagnostic corpus remains immutable; preserve callbacks, public schemas, family and consumed/exclusive order. No quoted rescanning or inferred equal-raw span may grant authority.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2`
  Status: `done`
  Goal: Admit one engineering-note rollover and its finite decision-store prerequisite before selected replacement repair.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0`, `REPO-HYGIENE.12`
  Verification tier: `canonical`
  Focused checks: Independently reconstruct exact original root/manifest/archives and prior decisions; verify five scalars only, retained rejected candidate and all actual guard inputs; run current composed evidence controls, actual decision thresholds/authority denials, history/claims/Knowledge/memory/diff and normal doctrines.
  Canonical trigger: Documentation-storage/routing infrastructure; exact staged canonical receipt and normal hooks are required before private handoff.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2.json`
  Acceptance: Admit one archive, one manifest row and one indexed accepted decision under five measured finite controls. Preserve all other fields, budgets, original history and accepted decision bytes; retain the original unadmitted candidate and errors without refreshing them. Exact canonical proof precedes clean P1 accepted-state guard work.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2 - retain finite replacement-note history` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3`
  Status: `done`
  Goal: Close the observed accepted-state admission gap in the routing guard.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2`
  Acceptance: Retain actual full composed-path and independent status/index/marker RED before changing the smallest reached owner. Preserve accepted-record behavior, exact object matching and all independent pressure boundaries; repair current fixtures without rewriting historical evidence. Freeze bound prior claims mode/revision only, update Knowledge/continuity, run source-bound mutation proof and exact staged canonical CI. Split before widening if another gate already owns accepted-state rejection.
  Verification tier: `canonical`
  Focused checks: Actual source-bound authorization and full resulting-tree admission before/after; accepted/proposed/missing/duplicate status, exact index/old/new markers and independent pressure oracles; source inverse controls, historical hash preservation, syntax, book render, Knowledge/memory/history/diff and normal doctrines.
  Canonical trigger: README/routing doctrine implementation; exact staged canonical receipt and normal hooks precede private occurrence handoff.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3 - require accepted README routing decisions` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0`
  Status: `done`
  Goal: Preserve private original occurrence authority through compiler collection/canonical copies.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3`
  Acceptance: Candidate owners: new perl/LinkedSpec/ActionIR/SourceOrigins.pm, Scanner.pm, Diagnostics.pm, CanonicalEvents.pm, CanonicalEvents/Core.pm and RewritePipeline.pm. Select exact invocation-local capture/copy and actual splitter-frame seams before editing; author source/ref/args/raw/fallback/foreign/malformed/delegation/error/reentrant controls. Keep replacement behavior unchanged here; verify original diagnostics/source/value/error channels and unchanged consumers, then focused commit.
  Verification tier: `focused`
  Focused checks: Authored actual scanner/copy/frame/reference/context/error/reentrant RED/GREEN, source-identical before/after public native/fresh/diagnostic corpus, effective production inverse controls and independent input recovery; six unchanged consumers, required Phase0/syntax, doctrines, memory/Knowledge/history/diff and book render.
  Canonical trigger: none; independent replacement admission remains .0.3.2 after mapped repair .1.1.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0 - preserve private original occurrence authority` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1`
  Status: `active`
  Goal: Replace selected original intervals in the current rewritten frame.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0`
  Acceptance: Candidate owner: RewritePipeline.pm and its private original interval/edit translation seam. Author source-identical quoted/generated/interleaved/duplicate/nested/raw/implicit-newline/closure RED/GREEN before changing searches or insertions. Preserve literals, real spans, args/references, family ordering and native/fresh/errors; resolve every observed defect in a safely bounded slice. Focused repair precedes independently committed canonical replacement .0.3.2.

  Activation: Clean6feff5d40; focused private handoff, normal ten-doctrine hooks, post-commit first-parent pointer and empty brief verified. All127 private-handoff inputs match current and exact owning Git bytes; prior claim changes mode/revision only before any bound file mutation.
  Original scope: RewritePipeline interval translation; unchanged SourceOrigins. Parent-prefixed source/proof and book/continuity; preserve public fields, family order, callbacks/refs/args/errors and dependency/CI ownership.
  History scope: Clean CHANGES58564; new diagnosis summary stays within418 bytes/below58982. Detail belongs to exact proof; no prior shortening or cap change.

  Instrument correction: Initial authored population accidentally reused .0.3.0 original inputs rather than its corrected same-facade probe/accepted two-argument cat source. Initial before/after producers, supplied graphs and complete channels remain exact; deferred early guard and invalid one-argument values are not execution acceptance. This leaf repeats the already established corrections and their LF variant under corrected-* files, while preserving all other source/value/interval oracles. Fresh immutable6fe corrected before and exact one-owner corrected after govern replacement acceptance; no production widening.

  Safety split: Blanket overlap consumption breaks accepted nested/raw residual continuation. Candidate cannot land. Child .0 retains diagnosis/restores6fe; .1 establishes producer-bound authority, .2 integrates mapping; .0.3.2 independently admits it. This exceeds the one-owner safe slice; no upstream/access blocker or oracle relaxation.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.0`
  Status: `done`
  Goal: Retain the rejected mapped-interval candidate and diagnose nested residual continuation before a safe repair.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0`
  Acceptance: Recover four complete regular supplied graphs and preserve both initial instrument mistakes and corrected same-facade/two-argument sources. Distinguish the candidate's bounded quote success from actual nested capture continuation RED. Use actual Toolbox substitution/mapped-source trace/descriptor/native/fresh error with candidate source location; retain completed Phase0 diagnostic channel honestly and disclose its evolving-root input limit. Book must describe current production, not the rejected candidate as a shipped fix. Own the producer-bound repair .1 at P1; no parent closure.
  Verification tier: `focused`
  Focused checks: Independent complete candidate graph/channel/reference/value/character-identity recovery and effective source/evidence controls; guarded nested residual Toolbox RED versus unchanged owning Git source; unchanged six suites/private handoff recurrence; current-production syntax, book render and effective publication controls; normal memory/Knowledge/history/doctrine/diff checks.
  Canonical trigger: none; rejected candidate is retained input only, not installed production. Independent repaired public-boundary admission remains .0.3.2.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.0.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.0 - reject unsafe interval candidate` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1`
  Status: `active`
  Priority: P1 — nested accepted capture/mark helpers must survive containing typed rewrites before occurrence replacement can land.
  Goal: Establish exact producer-bound source authority for executable residual helpers retained by a containing rewrite.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.0`
  Reproduce: Candidate lowering of if(is_nonempty(trim(capture_slice()))); push(items, trim(capture_slice())); endif() rewrites all three outer statements, then maps both selected capture_slice intervals to missing. Generated source retains both calls; actual native/fresh execution fails with Undefined subroutine and metadata unresolved2. Actual source-bound .0 proof retains original event IDs/coordinates, outer edit history, generated code and errors. Clean6fe retains the accepted full Phase0 behavior.
  Acceptance: Select exact private producer seam using existing AST/source/frame and contract authorities before any write. Preserve public event shapes, callback raw arguments/reference/context/error effects and canonical family order. Distinguish genuine copied executable subexpressions from generated or authored literals, duplicate same-interval residuals, repeated equal nested calls, renamed/transformed/foreign/opaque outputs and nested invocations. No unrestricted generated raw search, equal-text occurrence pairing, global source sort or blanket overlap waiver. Prove an independent origin oracle with actual original RED/corrected GREEN, meaningful source inverses, full required Phase0 and unchanged consumers. Declare bounded affected owners/tier before implementation and update book/claims.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0`
  Status: `done`
  Goal: Admit exactly the finite change-history rollover capacity needed for producer-bound repair.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.0`
  Acceptance: Change reserve47 files/46 rows is consumed; new hot shard58959 approaches58982. Follow indexed ADR0128 autonomous-PNT precedent without claiming a new explicit director grant: admit only one necessary archive/row, actual manifest bytes and one indexed ADR/actual decision-store budget. Preserve every prior byte/control. Select exact clean suffix; exact staged canonical infrastructure proof/hooks are mandatory. Partition the task tree if further detail crosses pressure limits; preserve stable IDs/history.
  Verification tier: `canonical`
  Focused checks: Independent clean Git suffix/manifest/archive/decision reconstruction, exact finite registry diff, actual rollover RED/GREEN, actual routing threshold/accepted-authority controls; memory/Knowledge/doctrines/history/diff.
  Canonical trigger: finite storage/routing infrastructure admission; exact staged tools/run_ci_local.sh receipt and normal hooks required.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0 - admit one residual-repair history rollover` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1`
  Status: `done`
  Goal: Select explicit producer-bound nested and raw residual continuation from actual lowering authorities.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0`
  Acceptance: Trace actual typed capture/mark/entry and raw retained-output producers. Declare bounded owners/independent continuation oracle before writes. Distinguish literals, repeated/consumed events and opaque callbacks; preserve original candidate proof. No guessed offsets/raw-text authority.
  Verification tier: `focused`
  Focused checks: Source-bound Toolbox substitution/AST/descriptor/dump/native/fresh probes on capture, named-mark, entry, repeated/literal and raw compatibility inputs; actual contract/dependency/parser emission traces, source-origin references and exact private argument frames. Preserve callback arguments/context/error effects and trace observer transparency; establish an independent authored-origin/continuation oracle and effective authority/evidence controls. Review unchanged public limitation, preserve intersecting prior claims by mode/revision only, and run memory/Knowledge/history/claims/diff/normal doctrines.
  Canonical trigger: None for unchanged-production diagnosis/design. Production repair and independent canonical acceptance remain later leaves.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1.json`
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1 - select residual producer authority` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2`
  Status: `active`
  Goal: Repair the selected producer-bound residual authority without changing family order or callback contracts.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1`
  Acceptance: Actual source-bound RED/GREEN and effective source inverses preserve nested/raw helpers, literal twins, exact original origins, repeated events and opaque dependencies. Full guarded Phase0 reaches1035/1035 and unchanged consumers pass before focused landing. Keep integrated mapping and independently committed canonical admission separate.

  Children: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.2`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.3`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.4`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.5`
  Plan: docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-plan.json; split typed emission integration further by actual family before writes if it grows beyond a safe slice.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0`
  Status: `done`
  Goal: Private emission protocol and callback/invocation identity, with independent adversarial fixtures; no replacement behavior change.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1`
  Acceptance: Follow the exact selected protocol and limits in docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-plan.json. Never infer output authority from equal text. Commit this bounded slice before activating the next.
  Children: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0`; `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1`; `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.2`.
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0`
  Status: `done`
  Goal: Recover the interrupted foundation draft and stop at a clean, committed handoff checkpoint without admitting unverified production.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1`
  Verification tier: `focused`
  Focused checks: Exact original dirty-delta and untracked-byte reconstruction against immutable activation Git; independent corruption RED controls; historical-claim mode/revision-only preservation and all original bindings; byte-exact production restoration; memory/Knowledge/history/claim/doctrine/diff checks.
  Canonical trigger: None for recovery-only checkpoint; no runtime, public contract, infrastructure or admission movement. No push requested.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0.json`
  Acceptance: Preserve every surviving changed file before restoring production. Keep the incomplete foundation and all six repair-slice obligations open; give the next agent exact restoration/proof instructions. User requests recovery followed by stopping at the ensuing handoff-ready checkpoint.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0 - recover interrupted emission draft` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1`
  Status: `done`
  Goal: Resume and prove the recovered private emission foundation, satisfying every original .2.0 obligation before integration.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0`
  Verification tier: `focused`
  Focused checks: Restore the exact draft under this leaf, then author independent fragment/callback/invocation/Unicode/CRLF/literal/duplicate/opaque/nested/error oracles, original RED/corrected GREEN and effective source inverses. Preserve public callback shapes/context/errors and family order; run unchanged direct consumers and normal doctrines. Full guarded Phase0 remains required at final private acceptance .2.5.
  Canonical trigger: None unless actual scope changes mechanical/public owners; mapped replacement and independent canonical admission retain separate ownership.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1.json`
  Acceptance: Follow the selected six-slice plan and recovery handoff. The saved draft supplies a starting point only; no tests or accepted packets were recovered. Commit the verified foundation before activating .2.1.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1 - verify private emission foundation` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.2`
  Status: `done`
  Goal: Reconcile older recovery/producer-selection Knowledge statuses with the now verified standalone foundation.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1`
  Acceptance: Preserve original dated diagnosis/recovery evidence, identify the historical reverify boundary, link current foundation authority, and keep actual integration/Phase0/mapping obligations open. No code, test, proof-input, policy, public API or measurement change.
  Verification tier: `focused`
  Focused checks: Review the two source cards against committed foundation acceptance and original historical boundaries; regenerate/gate Knowledge Map; memory/task metadata/claim/history/diff and normal hooks. Existing public teaching remains accurate.
  Canonical trigger: none; bounded correction of existing fact status only.
  Claim verification: none: This slice corrects retrieval/status of already accepted evidence and publishes no new measurement.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.2 - reconcile foundation knowledge status` (Git owns identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1`
  Status: `active`
  Goal: Actual argument/node input frames and private copy/consumption authority; preserve callback objects and effects.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0`
  Planned tier: `focused`
  Planned focused proof: Actual producer/callback identity and independently authored occurrence/fragment oracles, effective source inverses and direct consumers; source-bound complete Phase0 at final private acceptance. Preserve public shapes, callback arguments/context/errors, family order and historical evidence; memory/Knowledge/history/claim/diff/normal doctrines.
  Planned canonical boundary: None for private implementation slices; integrated mapping and independent canonical replacement admission remain separately owned. Reclassify before writes if mechanical/public owners change.
  Planned claim record: none: Planning only; activation must declare the actual measured implementation record before publishing results.
  Acceptance: Follow the exact selected protocol and limits in docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-plan.json. Never infer output authority from equal text. Commit this bounded slice before activating the next.

  Safety split: Existing actual MethodExpr return frames, AST construction identity, original-frame rebasing and opaque dependency invocation boundaries are distinct authorities. Establish their exact protocol in .0 before production writes; implement bounded .1-.3 and accept composition in .4 before typed emission integration.
  Children: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.1`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0`
  Status: `done`
  Goal: Select exact input authority and nested dependency capture boundaries from actual parser/CSV/node/factory observations before production edits.
  Verification tier: `focused`
  Focused checks: Actual Toolbox call_spec_handler_subst and AST/MethodExpr construction/returned-reference observations against independently authored Unicode/CRLF/repeated/literal/empty-slot spans; callback context/effects/nested/errors and opaque dependency boundary controls. Source-bound complete captures and exact evidence RED controls; verify all production owners unchanged. Existing public standalone/open-integration teaching remains accurate; memory/Knowledge/history/claim/diff/normal hooks.
  Canonical trigger: none; bounded unchanged-production diagnosis/design. Actual source integration and later complete Phase0/mapping/canonical admission remain separately owned.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0.json`
  Acceptance: Choose exact actual producer and invocation ownership for input frames and construction nodes, including foreign/copied/changed/opaque and equal-output nested dependencies. Avoid raw-text offset reconstruction and public provenance fields. Commit the source-bound selected protocol before implementation .1.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0 - select private input capture boundaries` (Git records identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.1`
  Status: `done`
  Goal: Actual AST construction sidecars and returned-node identity, preserving all public nodes and parser behavior.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0`
  Verification tier: `focused`
  Focused checks: Actual object/callback/invocation identities and independent original occurrence/fragment controls; unchanged direct consumers, public shapes/context/errors/family order; normal focused doctrine/claim/Knowledge/history checks.
  Canonical trigger: None for private bounded implementation; complete private Phase0 and independent mapped/public admission remain separately owned.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.1.json`
  Acceptance: Follow the committed .0 source-bound selection and preserve the original six-slice obligations; split further before writes if an actual owner set grows beyond a safe slice.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.1 - retain actual AST constructions` (Git records identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2`
  Status: `active`
  Goal: Actual MethodExpr argument objects and original-frame copy/consumption authority; preserve opaque dependency outputs and callback effects.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.1`
  Planned tier: `focused`
  Planned focused proof: Actual object/callback/invocation identities and independent original occurrence/fragment controls; unchanged direct consumers, public shapes/context/errors/family order; normal focused doctrine/claim/Knowledge/history checks.
  Planned canonical boundary: None for private bounded implementation; complete private Phase0 and independent mapped/public admission remain separately owned.
  Planned claim record: none: Planning only; actual implementation declares its own measured claim before results.
  Acceptance: Follow the committed .0 source-bound selection and preserve the original six-slice obligations; split further before writes if an actual owner set grows beyond a safe slice.

  Safety split: Native parser-input occurrence frames, actual MethodExpr capture/effects and compiler-event SourceOrigins joining are separate authorities. Implement .0-.2 and independently accept .3 before factory capture. The newly observed whitespace-only public AST span defect is P1 .4, next after .0, before .1. Native frames remain descriptive until the actual event/callback/invocation join; unsupported parser split paths decline conservatively.
  Children: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.2`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.5`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6`, `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.7`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0`
  Status: `done`
  Goal: Retain actual parser-relative root and CSV-child frames without using compatibility raw-piece searches.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.1`
  Verification tier: `focused`
  Focused checks: Actual LinkedSpec AST parse callbacks/Toolbox facade and original MethodExpr CSV returns, independent authored input intervals and wrong-public-search intervention; supplied-tree original RED/GREEN and semantic source inverses; unchanged constructor/direct consumers, full actual channels/source/input binding and evidence REDs; syntax/mdBook/memory/Knowledge/history/claim/diff/normal hooks.
  Canonical trigger: none; private bounded descriptive parser frames, no original-event grant, current public behavior or admission change. Complete private Phase0 and canonical mapping remain separate.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0.json`
  Acceptance: Original trims, actual CSV flush frames, retained argument occurrence indices, independent Unicode/CRLF/repeated/empty-slot spans, deliberately wrong public _find_piece_offset controls; actual identities and public AST/callback/effect/nested restoration unchanged. Ordinary call/array CSV routes are eligible; unsupported split routes conservatively decline. No original-event authority.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0 - retain native AST input frames` (Git records identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1`
  Status: `done`
  Goal: Retain actual MethodExpr input captures and original frame identities while preserving callback effects and existing bridge contracts.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4`
  Verification tier: `focused`
  Focused checks: Actual source/identity/effect boundaries and independent per-character occurrence oracle; direct dependents; exact producer/input bindings and normal focused workflow.
  Canonical trigger: none for private bounded implementation; full Phase0 and independent canonical admission remain open.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1.json`
  Acceptance: Use actual original producer returns and frames; preserve existing legacy wrapper semantics and all ordinary callback results/context/references/aliases/effects/errors. Do not infer input identity from a copied descriptive frame. Choose the minimal owning seam before production writes.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1 - retain actual MethodExpr input captures` (Git records identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.2`
  Status: `done`
  Goal: Join actual parser/argument captures to selected compiler events and original copy/consume authority.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.7`
  Verification tier: `focused`
  Focused checks: Actual source/identity/effect boundaries and independent per-character occurrence oracle; direct dependents; exact producer/input bindings and normal focused workflow.
  Canonical trigger: none for private bounded implementation; full Phase0 and independent canonical admission remain open.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.2.json`
  Acceptance: Bind actual capture/callback/event/returned node or argument-array occurrence to current SourceOrigins and private input scopes. No detached packet, copied/changed/foreign identity or equal text selects original frames. Rebase explicit original offsets and preserve builder text; unsupported inputs become generated or decline consumption.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.2 - join native inputs to original event grants` (Git records identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.2`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3`
  Status: `done`
  Goal: Independently accept parser/MethodExpr/original-event input composition before factory/dependency registration.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.2`
  Verification tier: `focused`
  Focused checks: Independently authored actual scanner/canonical event, nested AST/MethodExpr/CSV frame and per-character output/consumption ledgers; native-versus-joined context/aliases/effects/returns/fatal/opaque release; complete supplied direct consumers, coherent semantic source faults, reason-sensitive evidence controls, complete book render and normal focused workflow.
  Canonical trigger: none for private bounded implementation; full Phase0 and independent canonical admission remain open.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3.json`
  Acceptance: Verify actual population and source provenance at each frame/identity join, aliases/context/effects/opaque/nested exceptions, copied/equal/foreign inputs and independent character/occurrence/copy/consume oracles. Keep original six-slice producer/Phase0/mapping/canonical obligations open.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3 - accept composed original input grants` (Git records identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4`
  Status: `done`
  Goal: Repair the observed inverted public AST interval for whitespace-only expressions before input joining proceeds.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0`
  Verification tier: `focused`
  Focused checks: Independent Unicode/CRLF/whitespace trims and nonzero bases; actual public AST and private native frames; baseline observed RED and exact correction/source inverse; direct consumers, public book and ordinary focused doctrine checks. Preserve all nonempty parser behavior and callback/error/context contracts.
  Canonical trigger: none for an ordinary invariant bug fix within the existing AST shape; escalate before writes if a public/generated contract or mechanical owner changes. Complete Phase0/mapped/canonical acceptance remains open.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4.json`
  Acceptance: Empty/whitespace-only nodes have an ordered zero-width interval after original leading whitespace at the requested base; nonempty intervals remain exact. Close with actual RED/GREEN and distinguishing inverse; do not merely log or defer this defect.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4 - order empty AST source intervals` (Git records identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.5`
  Status: `done`
  Goal: Audit and qualify earlier supplemental private consumer captures, then retain a complete supplied recurrence before original-event joining.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1`
  Verification tier: `focused`
  Focused checks: Independently authored reader edges, exact supplied artifact population/content, actual full channels, distinguishing missing/changed artifact controls and original claim preservation; focused doctrines/book/history.
  Canonical trigger: None for bounded evidence correction; complete Phase0 and independent mapped/canonical admission remain open.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.5.json`
  Acceptance: Prior broad observations are accurately qualified; actual supplied recurrence includes every selected artifact input and distinguishes omissions. Original evidence is recoverable, and future agents find this corrected input contract without archaeology.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.5 - qualify private consumer artifact boundaries` (Git records identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.5`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6`
  Status: `done`
  Goal: Admit a finite, measured engineering-notes aggregate capacity extension before further implementation.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.5`
  Verification tier: `canonical`
  Focused checks: Exact resulting-tree pressure census, unchanged immutable history identities, distinguishing capacity denial, README/Knowledge/history/doctrines and full exact staged canonical CI.
  Canonical trigger: Mechanical routing/size-policy infrastructure and finite capacity admission.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6.json`
  Acceptance: A precise finite increase has an indexed decision under current full-PNT engineering authority, actual bounded admission evidence, preserved history, and exact staged canonical receipt. No unlimited reserve or reused director grant.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6 - admit finite engineering notes aggregate` (Git records identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.7`
  Status: `done`
  Goal: Reject one-shot capacity publisher replay before writes and remove its duplicate current publication entries.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6`
  Verification tier: `focused`
  Focused checks: Original Git-bound publisher product RED; corrected successful first publication and reason-sensitive replay/partial-state denials with exact whole-fixture no-write oracle; historical input identity and claim preservation; syntax, normal doctrines, history and diff.
  Canonical trigger: None for this private checkpoint writer and current clerical correction. Mechanical capacity admission already has an exact committed canonical receipt; event and mapped admission remain separate.
  Claim verification: `docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.7.json`
  Acceptance: Only an unpublished uniquely active .6 node may publish. Completed, duplicate-status or partly published state must reject before any write; first publication still produces one result pair and one recent row. Preserve the actual original source and every original artifact input at the clean capacity commit. Remove only the duplicate current copies.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.7 - reject private capacity publisher replay` (Git records identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.7`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3`
  Status: `active`
  Goal: Known producer/dependency invocation ownership at actual factory seams; preserve ordinary custom callbacks and nested error behavior.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3`
  Planned tier: `focused`
  Planned focused proof: Actual object/callback/invocation identities and independent original occurrence/fragment controls; unchanged direct consumers, public shapes/context/errors/family order; normal focused doctrine/claim/Knowledge/history checks.
  Planned canonical boundary: None for private bounded implementation; complete private Phase0 and independent mapped/public admission remain separately owned.
  Planned claim record: none: Planning only; actual implementation declares its own measured claim before results.
  Acceptance: Follow the committed .0 source-bound selection and preserve the original six-slice obligations; split further before writes if an actual owner set grows beyond a safe slice.

  Children: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3.0`; linked implementation root `PERL-PRIVATE-FACTORY-CAPTURE` in `docs/tasks/PERL-PRIVATE-FACTORY-CAPTURE.md`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3.0`
  Status: `done`
  Goal: Route the selected actual factory/dependency capture protocol into bounded implementation owners before production writes.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3`
  Verification tier: `focused`
  Focused checks: Review selected canonical protocol/current private callback and factory interfaces; task/plan/continuity and unchanged public book alignment; memory, Knowledge, bounded histories, claim/diff and all normal doctrines. No redundant runtime remeasurement.
  Canonical trigger: none for planning/routing only under existing bounded task collection rules; no schema, mechanical consumer, capacity or parent admission change.
  Claim verification: none: This slice routes the already verified protocol into bounded owners and publishes no new runtime or quantitative measurement.
  Acceptance: Preserve all existing stable task IDs and six-slice obligations, actual callback references and public shapes. Select invocation-local built-in registration and separate capture at injected dependency seams without names/equal text granting authority. Record first implementation leaf, owner sequence, native context/alias/effect/error and opaque-delegation proof requirements, and return to existing independent composition/full-private/mapped/canonical owners.
  Commit: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3.0 - split factory capture implementation owners` (Git records identity).
  Narrative: exact predecessor via `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --id SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3.0`.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.4`
  Status: `pending`
  Goal: Independent composed input/identity acceptance before typed value emission integration.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.6`
  Planned tier: `focused`
  Planned focused proof: Actual object/callback/invocation identities and independent original occurrence/fragment controls; unchanged direct consumers, public shapes/context/errors/family order; normal focused doctrine/claim/Knowledge/history checks.
  Planned canonical boundary: None for private bounded implementation; complete private Phase0 and independent mapped/public admission remain separately owned.
  Planned claim record: none: Planning only; actual implementation declares its own measured claim before results.
  Acceptance: Follow the committed .0 source-bound selection and preserve the original six-slice obligations; split further before writes if an actual owner set grows beyond a safe slice.


- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.2`
  Status: `pending`
  Goal: Typed value-emission builders; split further by actual family before writes if the affected branch set grows beyond a safe slice.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1`
  Planned tier: `focused`
  Planned focused proof: Actual producer/callback identity and independently authored occurrence/fragment oracles, effective source inverses and direct consumers; source-bound complete Phase0 at final private acceptance. Preserve public shapes, callback arguments/context/errors, family order and historical evidence; memory/Knowledge/history/claim/diff/normal doctrines.
  Planned canonical boundary: None for private implementation slices; integrated mapping and independent canonical replacement admission remain separately owned. Reclassify before writes if mechanical/public owners change.
  Planned claim record: none: Planning only; activation must declare the actual measured implementation record before publishing results.
  Acceptance: Follow the exact selected protocol and limits in docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-plan.json. Never infer output authority from equal text. Commit this bounded slice before activating the next.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.3`
  Status: `pending`
  Goal: Structured control/statement and legacy raw-return emission builders at actual concatenation/substitution seams.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.2`
  Planned tier: `focused`
  Planned focused proof: Actual producer/callback identity and independently authored occurrence/fragment oracles, effective source inverses and direct consumers; source-bound complete Phase0 at final private acceptance. Preserve public shapes, callback arguments/context/errors, family order and historical evidence; memory/Knowledge/history/claim/diff/normal doctrines.
  Planned canonical boundary: None for private implementation slices; integrated mapping and independent canonical replacement admission remain separately owned. Reclassify before writes if mechanical/public owners change.
  Planned claim record: none: Planning only; activation must declare the actual measured implementation record before publishing results.
  Acceptance: Follow the exact selected protocol and limits in docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-plan.json. Never infer output authority from equal text. Commit this bounded slice before activating the next.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.4`
  Status: `pending`
  Goal: Compose actual emitted fragments with independent occurrence/callback/nested/literal oracles and meaningful source inverses.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.3`
  Planned tier: `focused`
  Planned focused proof: Actual producer/callback identity and independently authored occurrence/fragment oracles, effective source inverses and direct consumers; source-bound complete Phase0 at final private acceptance. Preserve public shapes, callback arguments/context/errors, family order and historical evidence; memory/Knowledge/history/claim/diff/normal doctrines.
  Planned canonical boundary: None for private implementation slices; integrated mapping and independent canonical replacement admission remain separately owned. Reclassify before writes if mechanical/public owners change.
  Planned claim record: none: Planning only; activation must declare the actual measured implementation record before publishing results.
  Acceptance: Follow the exact selected protocol and limits in docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-plan.json. Never infer output authority from equal text. Commit this bounded slice before activating the next.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.5`
  Status: `pending`
  Goal: Complete guarded Phase0/direct-consumer acceptance for the committed private producer repair; integrated replacement and independent canonical admission stay separate.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.4`
  Planned tier: `focused`
  Planned focused proof: Actual producer/callback identity and independently authored occurrence/fragment oracles, effective source inverses and direct consumers; source-bound complete Phase0 at final private acceptance. Preserve public shapes, callback arguments/context/errors, family order and historical evidence; memory/Knowledge/history/claim/diff/normal doctrines.
  Planned canonical boundary: None for private implementation slices; integrated mapping and independent canonical replacement admission remain separately owned. Reclassify before writes if mechanical/public owners change.
  Planned claim record: none: Planning only; activation must declare the actual measured implementation record before publishing results.
  Acceptance: Follow the exact selected protocol and limits in docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1-plan.json. Never infer output authority from equal text. Commit this bounded slice before activating the next.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.2`
  Status: `pending`
  Goal: Integrate original interval replacement after producer-bound residual continuation and verify the full accepted action surface.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1`
  Acceptance: Reuse original retained quote/interval/native/fresh sources and candidate inverses without historical refresh. Preserve both literal payloads and executable nested continuation; source-bound complete Phase0 is mandatory before focused landing. Keep .0.3.2 independent canonical admission, recurring .0.4, diagnostic origin and comments open.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.2`
  Status: `pending`
  Goal: Independently accept the committed replacement repair.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1`
  Acceptance: Recur complete retained original/corrected oracles and unchanged consumers from committed inputs, with effective evidence/history/render controls. Exact staged canonical receipt and normal hooks precede closure of replacement .0.3 only; recurring .0.4, diagnostics and comments remain open.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.4`
  Status: `pending`
  Goal: Admit recurring executable source-ownership proof and independently compose this repair.
  Dependencies: `.1.3.3.0.7.2.2.0.3`
  Acceptance: Install the preserved diagnostic fixture as a green recurring test, register exact tracked/syntax/execution CI slots and reconcile only their source-bound historical consumer. Preserve before bytes and execute omitted/duplicate/disabled/extra-edit rejections; complete native/fresh compatibility, public book, unchanged consumers and exact staged canonical acceptance. Close executable parent .0 only; diagnostic origin .7.2.2.1 remains next.

  Dependency correction: The already committed Phase0 compiler-mock inverse is verified by .0.2.2.0 because it blocks canonical membership acceptance. This leaf still owns only its later recurring-registration historical reconciliation.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.1`
  Status: `pending`
  Goal: Report unresolved executable helpers and compiler-owned unsupported markers without diagnosing authored string data.
  Dependencies: `.1.3.3.0.7.2.2.0`
  Candidate owners: Diagnostics unresolved-pattern scanning, RewritePipeline diagnostic handoff, MethodLowering unsupported/retired-form marker producers and exact affected owner/descriptor consumers; select source-bound private provenance before changing public metadata.
  Acceptance: Actual RED/GREEN distinguishes authored marker strings, quoted diagnostic-looking code, genuine malformed substr/count/nested/retired/user helper forms, repeated unsupported occurrences and mixed literal/real twins. Keep real blocker counts/reasons/statements and readiness/raw distinction, caller error state, opaque delegation, direct/fresh source/value/error/effect behavior and source occurrence order. No blanket quote masking of lowered sentinels, arbitrary host-call admission or event-schema expansion. Re-run exact quote value/occurrence/diagnostic oracles, synchronize recurring proof/book/Knowledge/live claims and commit only after warranted exact canonical acceptance; parent .7.2.3 independently closes the complete bounded quote scope.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.3`
  Status: `pending`
  Goal: Independently recompose quoted-data acceptance and close the bounded parent before source-comment repair.
  Dependencies: `.1.3.3.0.7.2.2`
  Acceptance: Re-run the committed source/occurrence/value/error oracles and direct consumer obligations, reconcile any bounded older .18 prerequisites without claiming its broad closure, verify teaching/claims and exact canonical public-boundary proof, close only .7.2, and commit a clean handoff to .7.3.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.3`
  Status: `pending`
  Priority: P1 — accepted source comments are classified as executable raw Perl.
  Goal: Diagnose and repair source-comment AST/readiness classification while preserving actual raw expressions, source spans and authored data.
  Dependencies: `.1.3.3.0.7.2`; required before dispatcher `.1.3.3.0.3` and parent `.0.7` closure.
  Reproduce: .7.0 comment_data, Top:: I { # i=i+1; i < 1 followed by newline return("ok") }, returns ok natively and from independent fresh emitted source in all three measured seeds. Public parse_action_block retains raw_perl source # i=i+1; i < 1/reason unsupported_expression, and metadata reports ready0/raw dependency1/fallback1. Exact source/streams/AST/spans are retained in .7.0-observations.json and trace.json.
  Impact: Comment data falsely blocks portability classification. This differs from .7.2's typed-string AST with phantom helper/control events. Deferred/function/comment variants are unassessed, not admitted or reclassified from one ordinary-action case.
  Acceptance: Toolbox AST/descriptor/lowering/trace and published lexical contracts establish actual comment scope before implementation. Actual source-bound RED/GREEN proves comment/data/helper masking without hiding real raw dependencies; verify source bytes/spans, inline/nested/deferred routes where already accepted, quoted hash characters, escaped payloads and genuine raw/helper controls. Declare paths/tier and direct consumers; warranted canonical signoff precedes parent closeout. No new comment syntax or blanket raw-node waiver.

- ID: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.4`
  Status: `pending`
  Priority: P2 — reconcile pre-existing generated position-marker fallback before readiness closeout.
  Goal: Establish and repair or explicitly reconcile canonical portability classification of semantic MOVE_POS-generated lifecycle code.
  Dependencies: `.1.3.3.0.7.3`; required before parent `.0.7` and dispatcher `.1.3.3.0.3` closeout.
  Reproduce: .7.1 span-cases.json sources move_pos/capture_slice/capture_from_here preserve a semantic MOVE_POS Bootstrap token and typed capture-boundary LECODE (Phase0 bootstrap_split_boundary_aliases_build_split_boundary_lecode). Exact activation/current public descriptors report RAW_PERL fallback1/raw1/ready0 for that generated host chunk, while named mark reports fallback0/raw0/ready1. Twelve native/fresh pairs retain source/value/event behavior. Current .7.1 deliberately preserves old canonical fallback meaning; no classification waiver is selected there.
  Impact: Rule-level readiness may report a host dependency originating in a semantic compiler marker rather than authored host source. Whether this is a canonical lowering gap or the documented limit of action-rewriter readiness must be resolved against its published authority, not inferred from healthy execution.
  Acceptance: Read canonical readiness/marker authorities via Knowledge Map, trace actual token-to-event mechanism with Toolbox and compare generated/authored twins. Declare bounded paths/tier and independent classification oracle; fix any confirmed defect with RED/GREEN and preserve all actual cursor/mark/capture behavior, or document the precise legitimate partial scope with contract evidence. No blanket generated-code/event waiver. Record claims, book and live closure; canonical public-boundary proof precedes parent closeout.

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
| 42 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1` | `done` | 47 matched sources,849 focused tests; actual x/rest and typed attached/local returns verified. |
| 42.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.2` | `done` | 48 matched sources,900 tests; marker grouping/nested returns and identities verified. |
| 42.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.3` | `done` | 44 matched sources,947 tests; lazy values/original identities and lossless TAP verified. |
| 42.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.4` | `done` | 32 matched sources,981 tests; null exits/local boundaries and original identities verified. |
| 42.4 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.5` | `done` | 30 matched sources,1014 tests; guarded typed loops/local returns/original identities verified. |
| 42.5 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.6` | `done` | Exact committed input/evidence reconciliation; canonical receipt governs bounded parent closeout. |
| 43 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.0` | `done` | Nine sources/27 native-fresh, six originals,15 traces/34 tests and ten controls; repair selected. |
| 43.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.6.1` | `done` | Pending scan occurrences repaired;325-input/424-test proof and exact canonical landing condition. |
| 43.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.0` | `done` | 16 sources/48 pairs,16 traces/42 tests and twelve controls; source-occurrence repair boundary frozen. |
| 43.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.1` | `done` | Canonically accepted363c79109; focused proof/447-input claim remain historical at that revision. |
| 43.4.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2` | `active` | Evidence-selected bounded lexical ownership repair after committed diagnosis. |
| 43.4.2.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0` | `active` | Executable occurrence repair, including quoted literal corruption and typed nested host-call failures. |
| 43.4.2.0.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.0` | `done` | Two raw-key mapper failures and complete expected RED; production unchanged. |
| 43.4.2.0.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1` | `done` | Producer source provenance and explicit recursive frames. |
| 43.4.2.0.1.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.0` | `done` | Private three-contract spans;18 public identities/39 origins/13 GREEN groups/1199 unchanged tests. |
| 43.4.2.0.1.1.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0` | `done` | Nine regex contracts;27 public identities/81 spans, complete RED/GREEN and unchanged consumers. |
| 43.4.2.0.1.1.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3` | `done` | Source-bound1337 consumer groups at explicit two-capsule boundaries; statement frames next. |
| 43.4.2.0.1.1.3.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.0` | `done` | 738 exact inputs, 25 smoke groups, two rendered examples and18 controls; full remeasurement next. |
| 43.4.2.0.1.1.3.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.3.1` | `done` | 1337 groups, retained initial RED/four-input repair,22 controls and final book proof; canonical receipt gates landing. |
| 43.4.2.0.1.1.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1` | `done` | Private frames/eleven producers independently accepted; twenty-contract composition follows. |
| 43.4.2.0.1.1.1.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0` | `done` | 66 Toolbox cases/59 spans and37 events per run;52 consumer groups/33 controls/three rendered examples. |
| 43.4.2.0.1.1.1.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.1` | `done` | Private frames:28 GREEN/177 spans/66 identical compiler pairs,1148 consumer groups and26 controls. |
| 43.4.2.0.1.1.1.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.2` | `done` | Eleven producer hooks:29 GREEN/111 origins/66 identical pairs,1148 guarded consumer groups; canonical .3 next. |
| 43.4.2.0.1.1.1.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.3` | `done` | Immutable3864 inputs,80 GREEN groups/66 compiler recurrences/111 origins; exact canonical receipt gates closeout. |
| 43.4.2.0.1.1.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.2` | `done` | Independent twenty-contract BasicRules family canonically accepted under .1.1.2.1. |
| 43.4.2.0.1.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2` | `done` | All19 private source contracts independently verified; exact canonical receipt gates .1.2.3 parent acceptance. |
| 43.4.2.0.1.2.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.2` | `done` | Eight statement contracts/ten constructors;1801 GREEN,207 origins and corrected returned-reference proof. |
| 43.4.2.0.1.2.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.2.3` | `done` | Immutable4050/no overlays;207 origins/135 frames/803 groups, canonical receipt gates landing. |
| 43.4.2.0.1.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3` | `done` | All16 Flow source contracts independently accepted through exact canonical .1.3.3 landing. |
| 43.4.2.0.1.3.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.0` | `done` | Original Flow source/argument/traversal diagnosis; direct and recursive repairs owned. |
| 43.4.2.0.1.3.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.1` | `done` | Fourteen direct Flow source contracts verified; recursive arguments remain owned. |
| 43.4.2.0.1.3.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2` | `done` | Original argument authority, private bridge and recursive case/default consumers verified. |
| 43.4.2.0.1.3.2.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0` | `done` | Original MethodExpr/CSV authority diagnosis verified; bridge and recursive consumers committed. |
| 43.4.2.0.1.3.2.0.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.0.1` | `done` | Private argument frames verified;138 original occurrences/RED10-GREEN15. |
| 43.4.2.0.1.3.2.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.2.1` | `done` | Recursive Flow verified;147 origins/RED6-GREEN7/1180 groups. |
| 43.4.2.0.1.3.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.3.3` | `done` | Immutable4233/no overlays;16 contracts/837 groups; canonical receipt gates acceptance. |
| 43.4.2.0.1.4 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4` | `done` | Complete Legacy-family acceptance committed at3482a5d22 with exact canonical receipt and all ten doctrines. |
| 43.4.2.0.1.4.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0` | `done` | Original112-contract diagnosis/115 cases/103 groups/123 RED; Granted finite note admission; exact canonical landing. |
| 43.4.2.0.1.4.0.1.1.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1.1` | `done` | EOF/recovery/report paths; RED12-GREEN41/153 RED; exact canonical retry before family. |
| 43.4.2.0.1.4.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.1` | `done` | Seven hooks/eight contracts; final RED9/GREEN23,2→18 origins,1147 consumers/140 RED and byte-exact original source reconstruction. |
| 43.4.2.0.1.4.0.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1` | `done` | Atomic quote decoding; RED9/GREEN18/1169 groups/36 RED; nested unknown-escape P1 child is next. |
| 43.4.2.0.1.4.0.1.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.0.1.1` | `done` | Checked lexical calls; RED11/GREEN28/1198 groups/39 RED; anonymous origins next, quoted membership owned. |
| 43.4.2.0.1.4.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.2` | `done` | Anonymous26 hooks; RED27/GREEN50/1225 groups/159 RED,18→71 origins; named capture next. |
| 43.4.2.0.1.4.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.3` | `done` | Named17 hooks;71→105 origins/RED17-GREEN67/1245 groups/152 RED; initial wrapper warning retained, mark controls next. |
| 43.4.2.0.1.4.4 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.4` | `done` | Mark14 hooks;105→133 origins/RED14-GREEN81/1259 groups/148 RED; cursor/input next. |
| 43.4.2.0.1.4.5 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.5` | `done` | Cursor/input15;133→163 origins/RED15-GREEN96/1274 groups/149 RED; entry/match next. |
| 43.4.2.0.1.4.6 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.6` | `done` | Entry/match32;163→227 origins/RED32-GREEN128/1318 groups/168 RED; rollover next. |
| 43.4.2.0.1.4.7 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.7` | `done` | Fresh complete Legacy-family immutable recurrence; exact canonical landing gates closure. |
| 43.4.2.0.1.5.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.0` | `done` | Original7-contract/22-case/42-event/63-frame diagnosis,544 groups/108 RED and safe three-family partition. |
| 43.4.2.0.1.5.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.1` | `done` | OriginalRED5/GREEN138; eight staged origins/1589 consumer groups/130 RED with complete original channels. |
| 43.4.2.0.1.5.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.2` | `done` | OriginalRED5/GREEN148;16 combined origins/1608 groups/153 RED and exact actual-root mode repair. |
| 43.4.2.0.1.5.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.3` | `done` | OriginalRED18/GREEN191;42 dedicated origins/1671 groups/200 RED; canonical acceptance next. |
| 43.4.2.0.1.5.4 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.5.4` | `done` | Fresh immutable complete dedicated-family recurrence and exact canonical acceptance before parent closure. |
| 43.4.2.0.1.6 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6` | `done` | Complete independent producer composition source provenance before membership. |
| 43.4.2.0.1.6.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.0` | `done` | Original174 IDs/436 origins,49 representative pairs/seven fatal routes/1440 groups verified; canonical .1.6.1 next. |
| 43.4.2.0.1.6.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.6.1` | `done` | Independently accept immutable all-producer recurrence and private parent through canonical CI. |
| 43.4.2.0.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2` | `done` | Complete committed membership verified; exact canonical receipt gates landing. |
| 43.4.2.0.2.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.0` | `done` | Private selector with original intervals, arguments and receiver/slash guards. |
| 43.4.2.0.2.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.1` | `done` | Compiler39/originalRED38; five native/fresh repairs and1462 direct groups; numeric newline compatibility preserved. |
| 43.4.2.0.2.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2` | `done` | Complete committed membership verified; exact canonical receipt gates landing. |
| 43.4.2.0.2.2.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.0` | `done` | Immutable proof/historical inverse/callable RED retained. |
| 43.4.2.0.2.2.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.1` | `done` | Exact callable signature precedence; original RED/corrected GREEN and unchanged consumers. |
| 43.4.2.0.2.2.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2` | `done` | Complete committed membership verified; exact canonical receipt gates landing. |
| 43.4.2.0.2.2.2.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.0` | `done` | Immutable recurrence and grouped-pattern cause retained; repair next. |
| 43.4.2.0.2.2.2.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.1` | `done` | Compiler grouped roles repaired; original114 RED/corrected789 GREEN and unchanged default/public/consumers. |
| 43.4.2.0.2.2.2.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.2.2.2.2` | `done` | Complete committed membership verified; exact canonical receipt gates landing. |
| 43.4.2.0.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3` | `active` | Diagnose exact selected-occurrence replacement first. |
| 43.4.2.0.3.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0` | `done` | Original/rewritten diagnosis verified; repair remains open. |
| 43.4.2.0.3.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1` | `active` | Finite history prerequisite, then private handoff and mapped repair. |
| 43.4.2.0.3.1.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2` | `done` | Five finite controls independently verified; original unadmitted candidate retained. |
| 43.4.2.0.3.1.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3` | `done` | Unique accepted Status across five authority paths; full Git-tree proof and independent recovery. |
| 43.4.2.0.3.1.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.0` | `done` | Invocation-local origin/copy/frame RED/GREEN; replacement unchanged. |
| 43.4.2.0.3.1.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1` | `active` | Rejected candidate; producer-bound residual continuation precedes integrated repair. |
| 43.4.2.0.3.1.1.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.0` | `done` | Rejected candidate retained; guarded nested residual RED and production restored6fe. |
| 43.4.2.0.3.1.1.1.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.0` | `done` | One exact finite archive/manifest/decision admission; canonical receipt gates landing. |
| 43.4.2.0.3.1.1.1.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.1` | `done` | Actual typed/raw producer protocol selected; six private repair slices remain. |
| 43.4.2.0.3.1.1.1.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2` | `active` | After selection: repair residual authority and full guarded Phase0. |
| 43.4.2.0.3.1.1.1.2.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0` | `done` | Recovery and standalone foundation verified; actual integration remains separate. |
| 43.4.2.0.3.1.1.1.2.0.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.0` | `done` | Exact crash draft retained; production restored; stop at clean handoff. |
| 43.4.2.0.3.1.1.1.2.0.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.1` | `done` | Verified private foundation62/16; producer integration remains .2.1. |
| 43.4.2.0.3.1.1.1.2.0.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.0.2` | `done` | Historical recovery/selection cards now link current standalone foundation authority. |
| 43.4.2.0.3.1.1.1.2.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1` | `active` | Actual argument/node input authority and built-in callback registration. |
| 43.4.2.0.3.1.1.1.2.1.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0` | `done` | Four/eight input proof; actual opaque nested capture constraint and selected protocol. |
| 43.4.2.0.3.1.1.1.2.1.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.1` | `done` | Standalone construction77/15; lifetime RED/GREEN; original-frame joining next. |
| 43.4.2.0.3.1.1.1.2.1.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2` | `active` | Actual MethodExpr argument/frame authority. |
| 43.4.2.0.3.1.1.1.2.1.2.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.0` | `done` | Native63/11, actual frames/consumers; P1 public trim repair next. |
| 43.4.2.0.3.1.1.1.2.1.2.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.1` | `done` | Actual input107/13, fourteen supplied consumers; P1 prior evidence audit next. |
| 43.4.2.0.3.1.1.1.2.1.2.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.2` | `done` | Actual185/17; consumers15/134; lifetime RED1/GREEN; independent input acceptance next. |
| 43.4.2.0.3.1.1.1.2.1.2.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.3` | `done` | Independent140/10, consumers16/135, evidence4/book57/2; factory ownership next. |
| 43.4.2.0.3.1.1.1.2.1.2.4 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.4` | `done` | Public empty spans65/4; original18 RED, twelve consumers verified. |
| 43.4.2.0.3.1.1.1.2.1.2.5 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.5` | `done` | Three historical gaps qualified; complete133-file/fourteen-suite/book57 recurrence. |
| 43.4.2.0.3.1.1.1.2.1.2.6 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.6` | `done` | Three scalars;220 preserved files; production12/16 and evidence3; canonical receipt governs landing. |
| 43.4.2.0.3.1.1.1.2.1.2.7 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.2.7` | `done` | Original replay RED; first publication and eight no-write refusals; historical254. |
| 43.4.2.0.3.1.1.1.2.1.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3` | `active` | Linked bounded PERL-PRIVATE-FACTORY-CAPTURE owners; no factory admission yet. |
| 43.4.2.0.3.1.1.1.2.1.3.0 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3.0` | `done` | Bounded owner plan; P1 roadmap projection correction next, then framework. |
| 43.4.2.0.3.1.1.1.2.1.4 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.4` | `pending` | Independent private input composition acceptance. |
| 43.4.2.0.3.1.1.1.2.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.2` | `pending` | Typed value emission at actual construction seams. |
| 43.4.2.0.3.1.1.1.2.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.3` | `pending` | Statement/control/raw emission construction. |
| 43.4.2.0.3.1.1.1.2.4 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.4` | `pending` | Independent composed fragment/occurrence mapping proof. |
| 43.4.2.0.3.1.1.1.2.5 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.5` | `pending` | Complete guarded Phase0/direct-consumer private acceptance. |
| 43.4.2.0.3.2 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.2` | `pending` | Committed recurrence and canonical replacement acceptance. |
| 43.4.2.0.4 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.4` | `pending` | Recurring test registration and exact canonical composition. |
| 43.4.2.1 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.1` | `pending` | Unresolved executable helpers and compiler-marker provenance; preserve genuine blockers. |
| 43.4.3 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.3` | `pending` | Independent quoted-data closeout before comments .7.3. |
| 43.5 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.3` | `pending` | Source-comment AST/raw false blocker; required before dispatcher and .7 closure. |
| 43.6 | `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.4` | `pending` | P2 generated position-marker canonical fallback reconciliation before readiness closeout. |

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

## Historical narrative

Exact predecessor: `python3 tools/read_task_narrative.py --tree SPEC-LANGUAGE-SELF-CONTAINMENT --all`.
