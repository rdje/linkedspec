- ID: `FUTURE-PARITY-BACKLOG.10`
  Status: `done`
  Goal: Expose deep semantic introspection through one clean backend-neutral API and thin MCP projection.
  Children: `.10.0`, `.10.1`, `.10.2`, `.10.3`, `.10.4`, `.10.5`, `.10.6`, `.10.7`, `.10.8`, `.10.9`,
    `.10.10`
  Acceptance: The direction is durable before design/code; native in-memory APIs own semantics; MCP is transport;
    every variant exposes equivalent versioned queries/results; stable ids/order/source provenance and exact
    conformance prevent backend IR or transport details from becoming the public contract.

- ID: `FUTURE-PARITY-BACKLOG.10.0`
  Status: `done`
  Goal: Capture the director's semantic-introspection API plus MCP direction without changing the active frontier.
  Acceptance: Task tree, roadmaps/live docs, mdBook, resume pointer, and Knowledge Map record the direction and its
    architectural boundary; no parser/compiler/runtime/MCP implementation changes; `.1.5.1.6` remains active.
  Verification: **PASS 2026-07-10.** Knowledge Map generation/check, memory architecture, task-tree metadata,
    doctrine, whitespace, and mdBook build pass. No implementation code or active frontier changed.
  Commit: `FUTURE-PARITY-BACKLOG.10.0 - capture semantic introspection MCP direction`

- ID: `FUTURE-PARITY-BACKLOG.10.1`
  Status: `done`
  Goal: Design the semantic introspection schema, native query API, parity gate, and MCP projection before code.
  Acceptance: Inventory reusable semantic state and user questions; define versioned, deterministic read-only
    queries/results for rule/symbol/edge/call graphs, regex and lifecycle semantics, source spans/provenance,
    inferred value/target shapes, helper/function resolution, generated-source relationships, diagnostics, and
    explain-why paths; specify stable ids, ordering, pagination/cost limits, source/privacy controls, schema
    evolution, exact cross-backend fixtures, idiomatic host APIs, CLI relationship, and a thin MCP server that owns
    no semantic behavior. Explicitly prevent backend AST/IR layouts from becoming the public contract. Split later
    implementation by semantic model, per-backend adapters, conformance, and MCP transport before code.
  Verification: **PASS 2026-07-20.** Activated task-tree-first from clean repeated-action public-closeout commit
    `f183e468` at ahead 260; `git_message_brief.txt` was zero bytes and generated book/Python/recurring artifacts
    were absent. No semantic inventory, schema, API, conformance, MCP, roadmap, or public-design edit preceded
    activation. Knowledge/TOOLBOX retrieval and a live `return_descriptor` probe inventory every current semantic
    authority; the probe proves the Perl outward projection's compiled regex/coderef values are not a portable
    JSON wire schema. ADR `0049` fixes exact model/query ids, snapshot-local ids/order, record/relation/fact and
    value/target shape vocabularies, query/result/source/span/diagnostic envelopes, page/budget/privacy/evolution,
    failed-compile and optional caller-captured runtime observations, idiomatic host APIs, unchanged primary CLI,
    two-tool handle-only MCP, six fixture groups, mutations, and `.10.2-.10.10` dependency order. The first
    canonical run correctly rejected removal of the closed repeated-action sentence from live status; restoring
    that immutable marker makes cursor 75/8+0/60, root 7+0/54, duplicate 7+0/59, and repeated action 8+0/54 all
    pass together. Knowledge Map 647/4,769, mdBook, memory, task metadata, four doctrines, whitespace, and exact
    cleanup pass. Canonical local CI exits 0 with primary 66/66 twice and Phase 0 1,031/1,031 in 657 seconds. No
    parser/compiler/runtime/descriptor/generated/CLI/trace/fixture/MCP behavior changes.
  Commit: `FUTURE-PARITY-BACKLOG.10.1 - design semantic introspection`

  #### Acceptance Checklist

  - [x] **RETRIEVE / TOOLBOX FIRST** — Follow the Knowledge Map and toolbox to every existing descriptor,
    semantic IR, source-span/provenance, call-graph, helper/function registry, generated-source relationship,
    diagnostic, trace, and public API seam before re-deriving structure.
  - [x] **INVENTORY QUESTIONS AND REUSABLE STATE** — Enumerate user questions, current neutral facts, and exact
    per-backend reusable state; classify gaps without exposing host AST/IR layouts.
  - [x] **DEFINE VERSIONED NEUTRAL SCHEMA** — Specify stable ids, deterministic ordering, query/result envelopes,
    pagination/cost limits, source/privacy controls, schema evolution, diagnostics, and explain-why evidence.
  - [x] **DEFINE NATIVE API AND THIN MCP** — Specify idiomatic in-process query APIs for every backend and one
    transport-only MCP projection with no semantic ownership or CLI-only behavior.
  - [x] **FREEZE PARITY GATE AND IMPLEMENTATION SPLIT** — Define exact cross-backend fixtures, omission-sensitive
    conformance, and dependency-ordered neutral/adapters/transport/public leaves before any behavior code.
  - [x] **PROVE / LOCKSTEP / COMMIT** — Synchronize task/index/roadmaps/architecture/live/memory, ADR/Knowledge Map,
    mdBook and guides; pass governance/book/whitespace/canonical checks, clean artifacts, and commit before code.

- ID: `FUTURE-PARITY-BACKLOG.10.2`
  Status: `done`
  Goal: Freeze the executable neutral semantic-model/query contract and omission-sensitive parity checker.
  Depends on: `.10.1`
  Acceptance: Encode ADR `0049` without backend behavior: exact model/query ids, record/relation/fact vocabularies,
    ids/order, request/response envelopes, value/target shapes, source ceilings/redactions, page/budget behavior,
    diagnostics/explanations, compilation/runtime snapshots, fixture sources, expected normalized answers, rollout
    inventory, and missing/renamed/reordered/leaked/over-budget/transport-semantics mutations. The contract and
    checker must admit no backend until all shared questions and routes are represented.
  Verification: Activated task-tree-first on 2026-07-20 from clean design commit `056d413b` at ahead 261;
    `git_message_brief.txt` was zero bytes and generated mdBook/Python/Rust/Dart artifacts were absent. No neutral
    contract, fixture, expected-answer, checker, CI, or implementation edit preceded activation. First executable
    modeling exposed one foundational design defect before contract code: ADR `0049` required staged payload/job/
    result provenance but its exact vocabulary had no staged record, so a parse job could only be falsely labeled
    as a generated artifact or hidden on an untyped relation. ADR `0050` owns the pre-implementation correction:
    explicit staged payload/job/result records plus consumes/produces direction and exact policy/status facts.
    Implementation now freezes five exact UTF-8 source bundles, six immutable compiled/failed/runtime/ceiling
    snapshots, the complete record/relation/fact/nested-shape/signature/source/query schema, 20 independently
    evaluated canonical response digests, and nine dependency-ordered rollout legs. Focused neutral proof reports
    six fixture groups / 20 exact queries / 50 rejected mutations; `mdbook build docs/linkedspec-book`, Knowledge
    Map 649/4,783, and `git diff --check` pass.
    The first canonical attempt reached and passed the new semantic-introspection checker, then the adjacent
    repeated-action public checker rejected the updated task index because its exact historical marker
    `repeated-action recurring/public no-drift is closed` had been replaced. The state was unchanged; restoring
    that marker fixed the adjacent checker. The second canonical attempt passed through the new and prior semantic
    contracts, then the final public aggregate-selector checker rejected the new mdBook page as an unreviewed 59th
    public file against its 58-file census. The new chapter contains zero current selector examples; `.10.2` owns
    advancing that omission-sensitive inventory to 59/27/0 and synchronizing its two Knowledge Map facts.
    The third canonical run passes the new neutral checker at 6/20/50, all adjacent no-drift checks including the
    59/27/0 public census, all four doctrines, primary CLI 66/66 twice, and Phase 0 1,031/1,031 in 612 seconds;
    `tools/run_ci_local.sh` exits 0. Generated Python/mdBook output is removed before commit.
  Commit: `FUTURE-PARITY-BACKLOG.10.2 - freeze semantic introspection contract`

  #### Acceptance Checklist

  - [x] **RETRIEVE / TOOLBOX FIRST** — Reuse ADR `0049`, descriptor/ActionIR/staged/generated/diagnostic/trace
    authorities, the Knowledge Map, and `TOOLBOX.md`; no backend layout was re-derived into the wire model.
  - [x] **ROOT CAUSE / SCHEMA CORRECTION** — The first staged fixture proved ADR `0049` had provenance relations
    but no honest payload/job/result record; ADR `0050` adds exact staged records, facts, target shape, and
    consumes/produces direction before v1 implementation.
  - [x] **FIX / EXECUTABLE ORACLE** — Exact fixtures/model/query cases derive capabilities/list/get/relations/
    explain responses across compiled, failed, execution, Unicode/privacy, pagination, and every budget class.
  - [x] **ADDRESSED (verified)** — `python3 tools/check_semantic_introspection_contract.py` passes six fixture
    groups and 20 SHA-256-locked responses while rejecting 50 omission/semantic/topology/privacy/rollout mutations.
  - [x] **LOCKSTEP** — ADR/index, Knowledge Map facts, capability guide, roadmaps, architecture/live/memory/task,
    checker registration, and mdBook semantic-introspection chapter describe 1 complete / 8 pending neutral
    rollout and 0 complete / 6 pending native admission without claiming an available API.
  - [x] **NO REGRESSION / COMMIT** — Stage exact scope, pass doctrines plus canonical local CI, clean generated
    output, record final proof, commit `.10.2`, clear the brief, and hand off cleanly to `.10.3`.

- ID: `FUTURE-PARITY-BACKLOG.10.3`
  Status: `done`
  Goal: Implement the Perl semantic index, native query surface, and reference conformance consumer.
  Depends on: `.10.2`
  Acceptance: Build immutable semantic facts from compiler/ActionIR/provenance/generated/diagnostic authorities;
    never serialize coderefs, compiled regex objects, or host AST layout; expose idiomatic in-process capabilities
    and queries; capture optional runtime observations without interference; pass every exact fixture, error,
    privacy, page/budget, explain, direct/generated/loaded route, omission check, and complete Perl/canonical gate.

- ID: `FUTURE-PARITY-BACKLOG.10.3.0`
  Status: `done`
  Goal: Map every Perl semantic authority and freeze a safe implementation split before behavior.
  Depends on: `.10.2`
  Acceptance: Use the Knowledge Map and LinkedSpec toolbox first to prove the exact compiler, ActionIR, function/
    staged/generated provenance, diagnostic, descriptor, trace/runtime-observation, loader/reconstruction, and
    public embedding seams that the neutral oracle requires. Record which facts can be projected directly, which
    require stable derived metadata, where immutable snapshot construction belongs, how failures and optional
    caller-captured execution observations enter, and how direct/loaded/generated routes converge. Split `.10.3`
    into dependency-ordered index, query/runtime-route, and admission children before modifying Perl behavior.
  Verification: Activated task-tree-first on 2026-07-20 from clean neutral-contract commit `a891d7af` at ahead
    262; `git_message_brief.txt` was zero bytes and generated mdBook/Python output was absent. No Perl semantic
    implementation, API, fixture, consumer, or CI edit preceded activation. Knowledge Map and TOOLBOX retrieval
    led to exact `LinkedSpec::Get(return_descriptor)`, `runtime_ctx_ref`, bootstrap, ActionIR AST,
    `call_spec_handler_subst`, and `emit_generated_source` probes on every neutral source family. They establish:
    the descriptor owns deterministic definition/rule/function order, families/cursor/repetition/entry identity,
    resolved edge/slot topology, function/staged records, and generated family inputs; the typed ActionIR parser
    produces exact nested call/binding spans and function-body AST; runtime context owns structured compile failure;
    generated v2 metadata owns contract/format/plan/entry/source identity. Rule/edge/lifecycle source coordinates,
    normalized value/target shapes and evidence remain derived semantic work. A raw-byte privacy probe failed at
    `Validation::_parse_rule_label_line`, while strict UTF-8 decoding before `Get` compiled exact code points
    `U+0054,U+00F6,U+0070`; `SpecLoader` already proves this decode boundary with `FB_CROAK`. Therefore the native
    constructor must normalize strict UTF-8 to decoded text while retaining canonical bytes for byte spans/digests.
    Failed fixture `Missing` yields structured `bare_edge_target_undefined` at `normalize_edges`, which the adapter
    must normalize to the v1 compile diagnostic. Runtime context has no event sink and generated metadata is not a
    semantic snapshot, so optional observation and generated-route proof remain explicit later children. The
    dependency split `.10.3.1-.10.3.6` assigns every gap before behavior.
  Commit: `FUTURE-PARITY-BACKLOG.10.3.0 - map Perl semantic authorities`

  #### Acceptance Checklist

  - [x] **RETRIEVE / TOOLBOX FIRST** — Follow Knowledge Map pointers and use LinkedSpec probes for every existing
    Perl semantic authority and direct/loaded/generated/runtime route before reading implementation details.
  - [x] **MAP / ROOT CAUSE** — Establish exact reusable versus missing facts, stable construction boundaries,
    failure/runtime-observation entry points, native API ownership, and forbidden host-object leakage.
  - [x] **SPLIT BEFORE BEHAVIOR** — Add dependency-ordered `.10.3.1+` children whose acceptance covers immutable
    index construction, query/privacy/budget evaluation, runtime/routes, exact conformance, and canonical admission.
  - [x] **LOCKSTEP / COMMIT** — Synchronize task/index/roadmaps/architecture/live/memory, Knowledge Map, mdBook and
    guides; pass doctrines/book/whitespace/canonical checks, clean artifacts, and commit before behavior.

- ID: `FUTURE-PARITY-BACKLOG.10.3.1`
  Status: `done`
  Goal: Add the strict source, source-map, and compilation-outcome foundation for an immutable Perl index.
  Depends on: `.10.3.0`
  Acceptance: Add `LinkedSpec::semantic_index(...)` construction ownership without query behavior. Normalize an
    in-memory decoded character scalar or strict UTF-8 byte scalar to one decoded source plus exact canonical UTF-8
    bytes; accept only a caller-registered logical name and source ceiling, never an implicit host path. Compile
    once through existing `Get`/runtime-context authorities without executing the parser. Preserve a compiled or
    failed-compilation outcome, source digest policy, and deterministic zero-based byte/one-based Unicode-scalar
    spans through a source mapper that correlates accepted source with compiler order rather than inventing grammar
    semantics. Prove graph/privacy/failed sources including malformed UTF-8, immutability, no host-object leakage,
    and unchanged `Get`/loader/CLI behavior.
  Verification: Activated task-tree-first on 2026-07-20 from clean authority-map commit `e679a3eb` at ahead 263;
    `git_message_brief.txt` was zero bytes and generated mdBook/Python output was absent. No Perl/API/test/fixture/
    consumer/CI edit preceded activation. `.10.3.0` supplies the exact decoded-source, runtime-context failure, and
    absent source-map boundary. Baseline Toolbox probes reproduced raw-byte Unicode failure versus strict-decoded
    success, exact `U+0054,U+00F6,U+0070` label code points, malformed `C3 28` rejection, descriptor compilation,
    and `bare_edge_target_undefined` at `normalize_edges`. The new focused consumer passes five top-level subtests
    covering opaque/lazy construction, exact graph spans and repeated occurrence order, raw/decoded Unicode
    convergence, immutable failed compilation, strict typed validation, and adjacent native loading/root behavior.
    Canonical signoff passes semantic 6/20/50, foundation 5, selector 59/27/0, primary 66x2, and Phase 0
    1,031/1,031 in 610 seconds before exit 0. Knowledge Map is 651/4,796; mdBook, memory, doctrines, adjacent
    contracts, whitespace, and exact cleanup pass. Neutral rollout remains 1/9 and native admission 0/6.
  Commit: `FUTURE-PARITY-BACKLOG.10.3.1 - add Perl semantic source foundation`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Use exact neutral graph/privacy/failed source probes to lock decoded-scalar,
    raw-byte, malformed-byte, compiled-outcome, and failed-outcome behavior before implementation.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Use `LinkedSpec::Get`, `runtime_ctx_ref`, bootstrap/source probes, and
    generated-source capture to locate source normalization/map ownership without guessing from `.spec` text.
  - [x] **FIX** — Add only immutable construction/source-map/outcome foundations; no semantic query, static record
    projection, call/staged projection, observer, rollout, or public admission work from `.10.3.2-.10.3.6`.
  - [x] **ADDRESSED (verified)** — Exact focused tests cover decoded/bytes/malformed UTF-8, graph/privacy/failure,
    byte/scalar spans, logical-name-only identity, clone isolation, and no host-object leakage.
  - [x] **NO REGRESSION** — Existing direct/loaded/CLI/generated behavior plus semantic 6/20/50 and complete
    canonical Phase 0 remain exact; no new failure set or early rollout/admission.
  - [x] **LOCKSTEP** — Source/API docs, book, task/index/roadmaps/architecture/live/memory/KM and commit workflow
    are synchronized, or explicitly unchanged with evidence.

- ID: `FUTURE-PARITY-BACKLOG.10.3.2`
  Status: `done`
  Goal: Project exact static rule, regex-slot, edge, lifecycle, entry, and diagnostic semantics on Perl.
  Depends on: `.10.3.1`
  Acceptance: First audit and correct any static semantic drift in the supposedly frozen neutral oracle under `.0`;
    then build canonical ids/order and normalized spec/source/rule/regex-slot/edge/lifecycle/diagnostic/decision/
    explanation records plus relations from descriptor, source map, entry selection, and runtime-context authorities
    under `.1`. Normalize internal family/cursor/unbounded representations without serializing regexes, coderefs,
    AST layout, or paths. Deep-equal the corrected graph, privacy/full+limited, and failed-compilation neutral
    snapshots; prove duplicate slots, exact source redaction inputs, failure normalization, immutable copies, and no
    behavior change outside semantic construction.
  Verification: Activated task-tree-first on 2026-07-21 from clean source-foundation commit `0558c65a` at ahead
    264. `git_message_brief.txt` was zero bytes; generated mdBook and Python-cache outputs were absent. No static
    projection, fixture-consumer, CI, or non-task documentation edit preceded activation. `.10.3.1` supplies the
    opaque compiled/failed authority and exact source-map boundary; this leaf owns only static normalized records,
    relations, diagnostics, decisions, and explanations before calls/staging/query/runtime/admission. Exact Toolbox
    reproduction then found a foundational oracle conflict before adapter code: the Unicode privacy fixture's
    neutral rule record says `and`/`contiguous`, while the live `return_descriptor` authority for that default rule
    says `or_default`/`seek`. Child `.0` owns correction and an independent drift guard before child `.1` projects
    the corrected contract. `.0` then audited every rule across all six snapshots: graph `Child`, calls `Top`/
    `Done`, failed `Top`, and privacy full/limited required correction while explicit graph/runtime family,
    repetition, entry, and all conservative value shapes were already exact. The independent rule-local guard is
    now green at 53 mutations. Child `.1` adds the private exact static projection and passes focused plus canonical
    signoff: static 5, foundation 5, semantic 6/20/53, rule-local 36/18/8+60 mutations, capability 80/0/0,
    selector 59/27/0, primary 66x2, Phase 0 1,031/1,031 in 611 seconds, and local CI exit 0. Rollout/admission stay
    1/9 and 0/6; calls/staging `.10.3.3` follows only after the clean commit.

  #### Acceptance Checklist

  - [x] **RETRIEVE / TOOLBOX FIRST** — Reuse Knowledge Map authority cards and exact descriptor/runtime-context/
    source-map probes before inspecting implementation or deriving projection behavior.
  - [x] **REPRODUCE / ORACLE** — Materialize the neutral graph, privacy full/limited, and failed-compilation
    snapshots as exact expected record/relation/source/error targets before implementation.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Map every static field, order, id, source span, diagnostic normalization,
    decision, and explanation step to descriptor/source/runtime authorities; record absent seams explicitly.
  - [x] **FIX** — Add only immutable static projection behind the opaque foundation; do not implement call/staged,
    public capabilities/query, execution observations, rollout, or admission owned by `.10.3.3-.10.3.6`.
  - [x] **ADDRESSED (verified)** — Deep-equal exact graph/privacy full+limited/failed snapshots; prove duplicate
    slot identity, source redaction inputs, normalized failures, clone isolation, deterministic ids/order, and no
    host regex/coderef/AST/path leakage.
  - [x] **NO REGRESSION** — Existing construction/direct/loaded/CLI/generated behavior, semantic 6/20/53, focused
    consumers, and complete canonical Phase 0 remain exact without advancing rollout/admission.
  - [x] **LOCKSTEP** — Source/API docs, book, task/index/roadmaps/architecture/live/memory/KM and commit workflow
    are synchronized, or explicitly unchanged with evidence.

  - ID: `FUTURE-PARITY-BACKLOG.10.3.2.0`
    Status: `done`
    Goal: Root-cause and correct static semantic drift in the neutral introspection oracle before Perl projection.
    Depends on: `.10.3.1`
    Acceptance: Cross-check every graph/privacy/failed static rule family, cursor policy, edge ownership, repetition,
      value shape, and entry fact against the rule-local contract plus exact Perl descriptor/runtime authorities.
      Correct every stale neutral fact and dependent digest, add an independent cross-contract guard with mutation
      proof so coordinated model/digest edits cannot silently reintroduce drift, and synchronize the contract docs,
      book, task tree, live docs, Knowledge Map, and canonical gate without changing any backend behavior or
      advancing rollout/admission.
    Verification: Opened task-tree-first inside `.10.3.2` while its only dirty file remained this task tree. No
      neutral model, checker, Perl, fixture, consumer, CI, or non-task documentation edit preceded this subleaf.
      Exact `LinkedSpec::Get(return_descriptor, runtime_ctx_ref)` probes established the privacy mismatch, then
      audited graph/calls/runtime/privacy descriptors and the failed runtime diagnostic. Corrected default rows are
      neutral `or`/`seek`, compiled no-edge rows are `none`, and the failed default bare edge is `action`; only the
      exposed graph-rule query digest changed. The checker now consumes `linkedspec-rule-local-cursor-v1` and three
      coordinated wrong-model plus refreshed-hash mutations. Focused proof passes semantic 6/20/53, rule-local
      36 family / 18 edge / 8 composition plus 60 mutations, foundation 5, capability 80/0/0, Knowledge Map
      652/4,805, mdBook, memory, doctrines, and whitespace. The first canonical attempt correctly caught that the
      refreshed active task-index row had displaced the repeated-action closeout marker; restoring the exact marker
      passed focused 8/10/8+0/54. The complete restart passes selector 59/27/0, primary 66x2, and Phase 0
      1,031/1,031 in 612 seconds before canonical exit 0. No parser/compiler/runtime/descriptor/generated/CLI/
      trace/API behavior, rollout, or admission changed; `.1` follows only from this clean correction commit.
    Commit: `FUTURE-PARITY-BACKLOG.10.3.2.0 - correct semantic static oracle`

    #### Acceptance Checklist

    - [x] **RETRIEVE / TOOLBOX FIRST** — Reuse the semantic authority cards, rule-local contract, and exact
      descriptor/runtime/source probes; do not infer semantics by eyeballing `.spec` text.
    - [x] **REPRODUCE / ISSUE** — Lock every affected neutral fact and the exact privacy mismatch before correction.
    - [x] **ROOT CAUSE (WHY + WHERE)** — Identify why the existing checker accepted stale source/model semantics and
      distinguish schema/digest self-consistency from independent behavioral authority.
    - [x] **FIX** — Correct only neutral static facts/digests and add an independent cross-contract guard; do not add
      Perl projection/query/runtime behavior or alter fixture execution semantics.
    - [x] **ADDRESSED (verified)** — Mutation proof rejects stale family/cursor/ownership facts even when model and
      response digests are updated together; the exact neutral checker and canonical registrations pass.
    - [x] **NO REGRESSION** — Rule-local, semantic, adjacent contract, docs, and canonical Phase 0 gates remain exact;
      rollout/admission counts do not advance.
    - [x] **LOCKSTEP** — Contract docs, book, task/index/roadmaps/architecture/live/memory/KM and commit workflow are
      synchronized, or explicitly unchanged with evidence.

  - ID: `FUTURE-PARITY-BACKLOG.10.3.2.1`
    Status: `done`
    Goal: Project exact corrected static grammar, source, entry, diagnostic, decision, and explanation semantics.
    Depends on: `.10.3.2.0`
    Acceptance: Build canonical ids/order and normalized spec/source/rule/regex-slot/edge/lifecycle/diagnostic/
      decision/explanation records plus relations from descriptor, source map, entry selection, and runtime-context
      authorities. Deep-equal corrected graph, privacy full/limited, and failed snapshots; prove duplicate slots,
      redaction inputs, failure normalization, immutable copies, deterministic order, and no host-object leakage or
      behavior change. Do not implement calls/staging/query/runtime/admission owned by later leaves.
    Verification: Activated task-tree-first from clean static-oracle correction commit `40d35201` at ahead 265.
      `git_message_brief.txt` was zero bytes, generated mdBook/Python-cache artifacts were absent, and no source,
      fixture, consumer, live-doc, or non-task-tree edit preceded activation. This leaf consumes the corrected
      `or`/`seek`/`none`/failed-`action` authority and owns only private immutable static record/relation projection;
      public capabilities/query, ActionIR calls/staging, runtime observations, rollout, and admission remain later.
      Exact Toolbox descriptor/runtime-context/source-map probes and the executable neutral model were materialized
      before implementation. `SemanticStaticProjection` now composes accepted decoded source and source refs with
      compiled descriptor, selected entry, and failed runtime diagnostic authorities into canonically escaped,
      sorted, plain-data records and relations. The first focused red exposed scalar-boolean drift against neutral
      JSON; preserving only `JSON::PP::Boolean` through the otherwise object-rejecting clone boundary fixed it. A
      second exact runtime comparison exposed a redundant self-dispatch relation; indexed self-edges now emit only
      `selects_regex`. Focused proof deep-equals graph 12/14, privacy full/limited, failed 6/4, and the runtime static
      half; five top-level projection and five foundation subtests pass with clone isolation, duplicate slots,
      canonical JSON, source redaction inputs, normalized failure evidence, and no CODE/Regexp/object/path leakage.
      Semantic 6/20/53 and rule-local 36/18/8 plus 60 mutations remain exact. Complete signoff also passes
      capability 80/0/0, aggregate-selector public 59/27/0, repeated-action 8/10/8+0/54, primary 66x2, Knowledge
      Map 653/4,812, mdBook, memory/doctrines/whitespace, Phase 0 1,031/1,031 in 611 seconds, and canonical exit 0.
      No parser execution route or public API changed; rollout/admission remain 1/9 and 0/6.
    Commit: `FUTURE-PARITY-BACKLOG.10.3.2.1 - project Perl static semantics`

    #### Acceptance Checklist

    - [x] **RETRIEVE / TOOLBOX FIRST** — Reuse the semantic authority cards, corrected neutral oracle, rule-local
      contract, and exact descriptor/runtime/source probes before deriving implementation behavior.
    - [x] **REPRODUCE / ORACLE** — Materialize exact corrected graph, privacy full/limited, and failed static targets
      before implementation, including ids/order, duplicate regex slots, source spans, diagnostics, and relations.
    - [x] **ROOT CAUSE (WHY + WHERE)** — Map each projected field to descriptor, source map, entry selection, or
      runtime-context authority and explicitly preserve every absent/unknown seam.
    - [x] **FIX** — Add only private immutable static projection behind `semantic_index`; do not add public query,
      calls/staging, runtime observations, rollout, or admission owned by `.10.3.3-.10.3.6`.
    - [x] **ADDRESSED (verified)** — Deep-equal all owned snapshots and prove clone isolation, deterministic order,
      redaction inputs, failure normalization, duplicate-slot identity, and no regex/coderef/AST/path leakage.
    - [x] **NO REGRESSION** — Foundation, semantic 6/20/53, adjacent consumers, and canonical Phase 0 remain exact;
      rollout/admission stay 1/9 and 0/6.
    - [x] **LOCKSTEP** — Source/API docs, book, task/index/roadmaps/architecture/live/memory/KM and commit workflow
      are synchronized, or explicitly unchanged with evidence.

- ID: `FUTURE-PARITY-BACKLOG.10.3.3`
  Status: `done`
  Goal: Project Perl calls, shapes, bindings, staged provenance, and generated-plan semantics.
  Depends on: `.10.3.2`
  Acceptance: Traverse typed ActionIR AST in source preorder, resolve registered functions before helper contracts,
    infer only contract-authorized value/target shapes, and project exact helper/function/binding/call records and
    evidence. Normalize outward function body payload/job/AST into ADR `0050` payload/parse-job/result records and
    preserve consumes/produces/lowered/staged direction. Reuse one shared generated-family classifier to add the
    separate v2 handler-plan artifact. Deep-equal the complete calls/staging neutral snapshot and reject host IR,
    generated implementation source, unsupported shape strengthening, and provenance collapse.
  Verification: Completed through correction leaves `.10.3.3.0`/`.10.3.3.1.0` and projector leaf
    `.10.3.3.1.1`. The corrected private projection deep-equals 22 records/25 relations and passes focused calls 6,
    foundation/static 10, semantic 6/20/57, generated/rule-local, capability 80/0/0, selector 59/27/0, repeated
    action 8/10/8+0/54, the five-backend primary matrix 5x2x66, Knowledge Map 656/4,834, mdBook, memory/doctrines/
    whitespace, canonical primary 66x2, and independently observed Phase 0 1,031/1,031 in 636 seconds. The complete
    local gate exits 0 through the same Phase 0 boundary; rollout/admission remain 1/9 and 0/6.

  #### Acceptance Checklist

  - [x] **RED / PROBE** — Materialize the complete calls/staging neutral target and use the exact toolbox probes to
    inventory descriptor, typed ActionIR, function staging registry, and generated-plan inputs in source order.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Map every call, binding, helper/function, shape, evidence, staged payload/job/
    result, and generated artifact field to one native authority; preserve unknown/absent seams without inference.
  - [x] **FIX** — Extend only the private immutable projection behind `semantic_index` with calls/shapes/bindings,
    ADR `0050` staged provenance, and separate generated-plan semantics; do not add public query or observations.
  - [x] **ADDRESSED (verified)** — Deep-equal the complete calls/staging snapshot and prove source preorder, function-
    before-helper resolution, exact authorized shapes, provenance direction, clone isolation, and host-IR/source denial.
  - [x] **NO REGRESSION** — Foundation/static, semantic 6/20/57, adjacent consumers, primary, and canonical Phase 0
    remain exact; rollout/admission stay 1/9 and 0/6.
  - [x] **LOCKSTEP** — Source/API docs, book, task/index/roadmaps/architecture/live/memory/KM and commit workflow are
    synchronized, or explicitly unchanged with evidence.

  - ID: `FUTURE-PARITY-BACKLOG.10.3.3.0`
    Status: `done`
    Goal: Correct and independently gate the calls snapshot's generated-plan family before Perl projection.
    Depends on: `.10.3.2`
    Acceptance: Treat the actual generated-source-v2 family classifier and admitted rule-local cursor generated
      family table as authority. Correct the calls snapshot only where exact `emit_generated_source` metadata,
      descriptor `selected_handler_variant`, source header, and generated-v2 vocabulary agree it is wrong. Add an
      independent checker guard so model-plus-response-hash edits cannot preserve the stale family. Do not change
      parser/compiler/runtime/generated behavior, query responses, rollout, or admission.
    Verification: Activated before non-task-tree changes from clean static projection commit `e0aeee63` at ahead
      266, brief zero, and generated artifacts absent. Exact `Get(return_descriptor)` shows calls `Top` selects
      `_default`; exact independently loaded `emit_generated_source` metadata reports both rows as `default` under
      `linkedspec-generated-source-v2` format 2; `perl/LinkedSpec/Compiler.pm::_generated_source_family_for_variant`
      maps `_default` to `default`; and the admitted rule-local contract lists `default` as a v2 seek family. The
      neutral calls snapshot instead says `and_acode`, which is absent from the ten-family v2 vocabulary (whose
      valid sequential AND spelling is `and_acode_seq`). This is neutral-oracle drift, not backend behavior.
      The neutral artifact now says `default`. The checker consumes the external v2 identity/format/family table
      and exact default entry header, and semantic proof passes 6 fixture groups / 20 unchanged exact query hashes /
      55 rejected mutations. Both the old illegal family and coordinated valid-but-wrong `or_acode` with refreshed
      hashes fail. Generated-source and rule-local authority gates plus the existing Perl static 10 tests pass.
      Complete signoff adds capability 80/0/0, selector 59/27/0, repeated action 8/10/8+0/54, primary 66x2,
      Knowledge Map 654/4,818, mdBook/memory/doctrines/whitespace, Phase 0 1,031/1,031 in 610 seconds, and canonical
      exit 0. No optional backend matrix is needed because model/checker/docs only change neutral authority.
    Commit: `FUTURE-PARITY-BACKLOG.10.3.3.0 - correct generated plan oracle`

    #### Acceptance Checklist

    - [x] **RED / PROBE** — Exact descriptor and independently loaded generated-v2 metadata reproduce `_default` →
      `default` while the neutral calls snapshot says illegal `and_acode`.
    - [x] **ROOT CAUSE (WHY + WHERE)** — The model encoded a semantic guess instead of the generated artifact's
      actual family authority; no checker cross-validated `plan_family` against the source/header/v2 family table.
    - [x] **FIX** — Correct only the calls generated artifact to `default` and add independent source/contract-
      derived checker validation plus a coordinated-wrong-model mutation.
    - [x] **ADDRESSED (verified)** — Semantic 6/20 governance rejects the new family mutations; generated-v2 and
      rule-local contracts, calls target, and any affected exact query hashes agree.
    - [x] **NO REGRESSION** — Existing Perl/static/generated/CLI behavior and canonical Phase 0 remain exact;
      rollout/admission stay 1/9 and 0/6.
    - [x] **LOCKSTEP** — Neutral contract docs, ADR/book/task/index/roadmaps/live/memory/KM and commit workflow are
      synchronized, or explicitly unchanged with evidence.

  - ID: `FUTURE-PARITY-BACKLOG.10.3.3.1`
    Status: `done`
    Goal: Project exact corrected calls, shapes, bindings, staged provenance, and generated-plan semantics on Perl.
    Depends on: `.10.3.3.0`
    Acceptance: Implement the parent `.10.3.3` projection scope against the corrected independently guarded
      calls/staging target, deep-equal all 22 records and 25 relations, and preserve private/API/admission boundaries.
    Verification: Activated before non-task-tree changes from clean correction commit `c07ba618` at ahead 267;
      `git_message_brief.txt` is zero bytes and mdBook/Python generated artifacts are absent. Parent probes already
      materialize exact descriptor, source-preorder typed ActionIR, staged function records, and independently
      loaded generated-v2 metadata; `.10.3.3.0` corrects/cross-gates the target family to `default` at 6/20/55.
      Full 22/25 RED then stops first at `spec:0.name`: native construction consistently derives
      `calls_and_staging` from caller identity `calls_and_staging.spec`, while the neutral row alone says `calls`.
      After isolating that field, RED advances to the expected missing function-first definition-order projection.
      Correction `.10.3.3.1.0` and implementation `.10.3.3.1.1` now complete the exact target. Final proof is calls
      6, foundation/static 10, semantic 6/20/57, all adjacent authority/consumer gates, primary 5x2x66, canonical
      primary 66x2, and Phase 0 1,031/1,031 in 636 seconds; public query/observations and admission remain absent.

    #### Acceptance Checklist

    - [x] **RED / PROBE** — Deep-compare current private projection with the corrected calls target and preserve the
      exact descriptor/ActionIR/staged/generated probe evidence for every missing record/relation.
    - [x] **ROOT CAUSE (WHY + WHERE)** — Map function/helper/call/binding/shape/evidence, staged payload/job/result,
      and generated artifact fields to their exact source-preorder native authorities without host-layout leakage.
    - [x] **FIX** — Extend only the private immutable projection with calls/shapes/bindings, staged provenance, and
      generated-v2 artifact facts; reuse one generated-family classifier and keep public query/observation absent.
    - [x] **ADDRESSED (verified)** — Deep-equal all 22 records and 25 relations; prove nested preorder, resolution
      precedence, authorized shape inference, staging direction, corrected `default` family, clone/JSON safety.
    - [x] **NO REGRESSION** — Foundation/static, semantic 6/20/57, adjacent consumers, primary, and canonical Phase
      0 remain exact; rollout/admission stay 1/9 and 0/6.
    - [x] **LOCKSTEP** — Source/API docs, book, task/index/roadmaps/architecture/live/memory/KM and commit workflow
      are synchronized, or explicitly unchanged with evidence.

    - ID: `FUTURE-PARITY-BACKLOG.10.3.3.1.0`
      Status: `done`
      Goal: Correct and independently gate the calls snapshot's spec identity before Perl projection.
      Depends on: `.10.3.3.0`
      Acceptance: Derive neutral `spec.name` from each source fixture's caller-registered logical-name stem, correct
        only inconsistent rows, and add a coordinated wrong-model/hash mutation. Preserve all query answers,
        parser/compiler/runtime/generated behavior, rollout, and admission.
      Verification: Activated before non-task-tree changes from clean correction commit `c07ba618` at ahead 267,
        brief zero, artifacts absent. Full RED proves actual `calls_and_staging` versus neutral `calls`; every other
        snapshot already equals its fixture logical-name stem, so the defect is isolated to one model field and a
        missing independent identity check.
        The calls spec record now says `calls_and_staging`; the checker derives every snapshot's name from the
        registered logical name and rejects direct plus coordinated old-name drift. Semantic 6/20/57 passes with
        all 20 exact hashes unchanged. Complete signoff adds Perl foundation/static 10, generated-source and
        rule-local authorities, capability 80/0/0, selector 59/27/0, repeated action 8/10/8+0/54, full five-backend
        primary 5x2x66, Knowledge Map 655/4,824, mdBook/memory/doctrines/whitespace, canonical primary 66x2, and
        Phase 0 1,031/1,031 in 618 seconds with canonical exit 0. The initially isolated primary invocation failed
        only because its fresh Julia write depot hid installed JSON3; the documented writable-plus-installed depot
        stack then completed the exact matrix, and canonical CI used the same environment successfully.

      #### Acceptance Checklist

      - [x] **RED / PROBE** — Full calls deep comparison reproduces exact `calls_and_staging` versus `calls` first.
      - [x] **ROOT CAUSE (WHY + WHERE)** — The calls model used its short snapshot id as spec name; the checker
        validated source logical identity but never derived `spec.name` from that authority.
      - [x] **FIX** — Correct only `spec:0.name` to `calls_and_staging` and independently validate every snapshot's
        spec name from its fixture logical name, including coordinated wrong-model/hash mutation proof.
      - [x] **ADDRESSED (verified)** — Semantic 6/20 governance rejects direct/coordinated identity drift and all
        20 exact query answers remain stable.
      - [x] **NO REGRESSION** — Existing Perl/static/generated/CLI behavior and canonical Phase 0 remain exact;
        rollout/admission stay 1/9 and 0/6.
      - [x] **LOCKSTEP** — Neutral docs, ADR/book/task/index/roadmaps/live/memory/KM and commit workflow are exact.

    - ID: `FUTURE-PARITY-BACKLOG.10.3.3.1.1`
      Status: `done`
      Goal: Project the fully corrected calls/shapes/bindings/staged/generated target on Perl.
      Depends on: `.10.3.3.1.0`
      Acceptance: Implement parent `.10.3.3.1` after spec-name correction and deep-equal all 22/25 rows.
      Verification: Activated task-tree-first from clean correction `7d9077c4` at ahead 268; the commit brief is
        zero bytes and mdBook/Python/Rust-incremental generated artifacts are absent. Reuse the already materialized
        22-record/25-relation target and exact descriptor/ActionIR/staged/generated authority probes; do not
        re-derive established facts outside their Knowledge Map homes.
        Fresh focused RED constructs silently and fails exact deep equality first at the missing function
        declaration/order (`actual relation order 0`, target function declaration order 2); the corrected
        `calls_and_staging` spec identity no longer differs. The remaining gap is exactly the owned function/helper/
        binding/call/staged/generated records and relations. The first exact implementation reaches 22/25 equality;
        a follow-on multibyte-prefix regression then exposes an ASCII-masked source-coordinate defect: the staged
        function descriptor reports character offsets (`source_span.start = 10`, `body_span.start = 27`) for a
        source whose prefix occupies 11 UTF-8 bytes, while the projector initially reinterprets them as bytes and
        shifts `trim(value)` to `(trim(value`. The typed descriptor/ActionIR probe fixes the authority boundary:
        descriptor shell/body spans and ActionIR-local spans are character coordinates; only final public source
        spans are converted to byte plus scalar line/column coordinates by `SemanticSourceMap`. The static source
        scan also consumes original caller text rather than the compiler's function-blanked rule source, so it must
        mask descriptor-owned function spans locally before classifying rule members; otherwise an interleaved
        top-level `fn` after a rule can be mistaken for that rule's bare edge.
        `SemanticCallProjection` now composes the exact target behind the opaque index. Focused proof passes all six
        top-level subtests: complete 22/25 equality; typed preorder/resolution/staging; all eleven handler variants
        through one shared generated owner; clone/JSON/host-layout denial; exact multibyte-prefix excerpts/columns;
        and interleaved-function masking with only the two authored rules/one Top edge. Foundation/static and the
        generated-source contract remain green; public capabilities/query and observations remain absent.
        Complete signoff adds semantic 6/20/57, generated/rule-local authority, capability 80/0/0, selector
        59/27/0, repeated action 8/10/8+0/54, five-backend primary 5x2x66, Knowledge Map 656/4,834, mdBook, memory
        architecture, doctrines, whitespace, canonical primary 66x2, and Phase 0 1,031/1,031 in 636 seconds. The
        complete canonical local gate exits 0; rollout/admission remain 1/9 and 0/6.
      Commit: `FUTURE-PARITY-BACKLOG.10.3.3.1.1 - project Perl call semantics`

      #### Acceptance Checklist

      - [x] **RETRIEVE / TOOLBOX FIRST** — Read the semantic authority/source/action/staged/generated cards and use
        exact LinkedSpec descriptors/typed probes before interpreting implementation state.
      - [x] **RED / ORACLE** — Deep-compare the current private projection with the fully corrected 22/25 target;
        preserve the first real missing field plus complete expected records/relations before production edits.
      - [x] **ROOT CAUSE (WHY + WHERE)** — Map definition order, helpers/functions/bindings/calls/shapes/evidence,
        staged payload/job/result, and generated plan to shared native authorities with exact source preorder.
      - [x] **FIX** — Extend only the private immutable projector; share the generated-family classifier and keep
        public query, runtime observation, rollout, and admission absent.
      - [x] **ADDRESSED (verified)** — Deep-equal all 22 records/25 relations; prove nested call preorder,
        function-before-helper resolution, contract-only shapes, staging direction, clone/JSON safety, and denial
        of host IR/generated implementation source.
      - [x] **NO REGRESSION** — Foundation/static, semantic 6/20/57, generated/rule-local, capability, primary, and
        canonical Phase 0 remain exact; rollout/admission stay 1/9 and 0/6.
      - [x] **LOCKSTEP** — Source/API docs, book, task/index/roadmaps/architecture/live/memory/KM and commit workflow
        are synchronized, or explicitly unchanged with evidence.

- ID: `FUTURE-PARITY-BACKLOG.10.3.4`
  Status: `done`
  Goal: Implement the immutable Perl capabilities/query evaluator with exact privacy and logical costs.
  Depends on: `.10.3.3`
  Acceptance: Expose `$index->capabilities` and `$index->query($request)` with the exact v1 request/response keys,
    ids/order, clone isolation, list/get/relations/explain behavior, after-id pages, deterministic breadth-first
    traversal, record/relation/depth budgets, source ceilings/redactions/digests, and portable invalid/unsupported/
    forbidden/budget diagnostics. Match every static neutral query response digest without compiling, executing,
    reading a path, enabling trace, or leaking mutable internal state during queries.
  Verification: Activated task-tree-first from clean calls-projection commit `b4805f23` at ahead 269;
    `git_message_brief.txt` is zero bytes and generated mdBook/Python/Rust artifacts are absent. Retrieve the exact
    neutral query, privacy, paging, budget, error, and immutable-clone authorities through the Knowledge Map before
    implementation; keep runtime observations, rollout, and admission owned by `.10.3.5-.10.3.6` absent.
    Retrieval confirms 19 of 20 canonical responses are static and owned here; only `runtime_events` requires the
    next leaf's captured observation. The neutral checker is the executable authority for structural source
    projection, canonical stream paging, filtered directional breadth-first traversal, logical cost/budget prefixes,
    explain selection, and portable response diagnostics. Focused RED constructs the graph index silently, then
    fails exactly because the opaque object has no `capabilities` or `query` method; production evaluation has not
    begun and no deeper model mismatch is masked.
    `LinkedSpec::SemanticQuery` now evaluates only a cloned private projection with no file/descriptor/source-map
    authority. The focused suite passes nine top-level groups: all 19 owned canonical response digests (only
    `runtime_events` remains `.10.3.5`), native capabilities identity, structural privacy, 26 invalid-request/error
    boundaries including strict JSON-boolean typing, deterministic paging/traversal/budgets, clone isolation,
    silence, host-layout denial, and successful querying while the compile entrypoint is replaced with a die.
    Foundation/static/calls/query pass 25 top-level groups. Complete canonical signoff passes semantic 6/20/57,
    rule-local 36/18/8 and 75 files/8+0/60, root 7+0/54, duplicate slots 7+0/59, repeated action 8/10/8+0/54,
    capability 80/0/0, aggregate selector 59/27/0, primary 66/66 in both default and POSIX environments, and
    Phase 0 1,031/1,031 in 643 seconds. Memory architecture, Knowledge Map 657/4,845, mdBook, four doctrines,
    whitespace, and the complete local CI gate pass; rollout/admission remain exactly 1/9 and 0/6.
    Commit: `FUTURE-PARITY-BACKLOG.10.3.4 - expose Perl semantic queries`

  #### Acceptance Checklist

  - [x] **RETRIEVE / TOOLBOX FIRST** — Read the canonical semantic query/privacy/cost facts and exact executable
    neutral fixtures/checker before interpreting the private Perl projection.
  - [x] **RED / ORACLE** — Lock capabilities and all static exact response digests against the current opaque index,
    including invalid/unsupported/forbidden/budget errors and clone isolation, before production edits.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Map query selection, paging/traversal, redaction/source ceilings, costs,
    budgets, explanations, and diagnostics to one immutable backend-neutral evaluator boundary.
  - [x] **FIX** — Expose only native `capabilities`/`query` on the opaque index without compilation, execution,
    path reads, trace changes, mutable aliases, runtime observations, rollout, or admission.
  - [x] **ADDRESSED (verified)** — Match all static exact responses/digests and prove deterministic order/pages,
    logical costs/budgets, privacy monotonicity, portable errors, and clone-safe repeated calls.
  - [x] **NO REGRESSION** — Private source/static/calls/staged/generated projections, semantic governance, adjacent
    consumers, primary behavior, and canonical Phase 0 remain exact; rollout/admission stay 1/9 and 0/6.
  - [x] **LOCKSTEP** — API/docs/book/task/index/roadmaps/architecture/live/memory/KM and commit workflow are exact.

- ID: `FUTURE-PARITY-BACKLOG.10.3.5`
  Status: `done`
  Goal: Add opt-in non-interfering Perl execution observations across native, loaded, and generated routes.
  Depends on: `.10.3.4`
  Acceptance: Add an invocation-local typed observation sink separate from trace and diagnostic output; emit exact
    regex-slot selections and final rule result with stable rule/slot identity and positions from shared handler
    seams. Let a caller derive a new immutable runtime snapshot from a completed observation; queries never execute.
    Prove byte/result/error/trace/diagnostic neutrality when absent or present, observer failure identity, exact
    runtime model/query answers, and equivalent direct parser, loaded spec, captured generated source, independently
    loaded generated direct/traced, and reconstructed plan roles.
  Verification: Activated task-tree-first from clean immutable-query commit `91b0c9b0` at ahead 270;
    `git_message_brief.txt` is zero bytes and no untracked/generated artifact is present. Retrieve the exact runtime
    observation oracle, trace/diagnostic separation, handler-entry/slot/result seams, and direct/loaded/generated
    route authorities through the Knowledge Map and LinkedSpec toolbox before implementation. Retrieval confirmed
    the runtime oracle's `execution:0` plus three ordered events: `Top` slots 0/1 at positions 1/2 and the final
    `Top` result at position 2, with response digest `36897041...`. The pre-edit descriptor reports `REP_ACODE`,
    resolved slot rows 0/1, and result `["A", "B"]` at position 2; an otherwise valid
    `semantic_observation_sink` option currently receives zero events. Generated-source lines 42/50 and the traced
    route prove `HandlerVariantEmitter::_slot_selection_trace` already owns exact target/index/position, while live
    `Compiler` lines 1616-1672 and generated `Execute` lines 231-322 own invocation setup, final result, and exact
    control-failure propagation. `RuntimeDiagnosticOutput` supplies the independent typed-callback/error-identity
    precedent; `SpecEntry` line 340 is the inner control-failure normalization boundary. Loaded/captured/emitted/
    independently evaluated generated direct/traced routes all reconstruct or execute those shared owners. RED
    `t/semantic_index_perl_runtime_observation.t` is syntax-clean and fails 12/55 only at the intended gap: all
    eight routes deliver zero semantic events, the native index has no observation derivation method, observer
    failures/types are not active, and trace/diagnostic coexistence has no semantic stream; all pre-existing
    result/input/cursor/generated-plan/trace/diagnostic behavior remains green inside the same lock. GREEN is
    106 assertions: all eight required routes match the exact three-event sequence and twentieth response digest,
    base/derived immutability and no-execute queries are exact, malformed/foreign observations reject, slot/final
    observer exceptions preserve identity, and trace/diagnostic streams are unchanged. Eleven adjacent semantic,
    handler, generated, diagnostic, root, and cursor suites pass 468 assertions. Canonical primary passes 66/66
    in both default and POSIX environments. Standalone Phase 0 passes 1,031/1,031 in 639 seconds; the complete local
    CI gate repeats all doctrine, semantic 6/20/57, focused/contract, primary 66x2, and Phase 0 1,031/1,031 checks,
    with the registered Phase 0 leg completing in 650 seconds and the gate exiting 0. Memory, Knowledge Map
    658/4,857, mdBook, whitespace, and lockstep checks pass. Disk-pressure cleanup removed the reproducible
    `rust/target` and `dart/.dart_tool` trees plus inactive Claude temporary sessions and four orphaned large Rust
    probe files while retaining the sole session with open files; reported free space rose from 27 GiB to 117 GiB.

  #### Acceptance Checklist

  - [x] **RETRIEVE / TOOLBOX FIRST** — Read the canonical runtime-event/query target and probe exact existing
    execution, slot-selection, final-result, trace, diagnostic, loader, and generated-route seams before code.
  - [x] **RED / ORACLE** — Lock the missing `runtime_events` response plus absent/present observer neutrality and
    route equivalence against current behavior before production edits.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Identify one invocation-local typed observation owner and the smallest
    shared runtime seams that cover exact slot selection and final result without trace coupling.
  - [x] **FIX** — Add opt-in caller-owned capture and immutable post-execution snapshot derivation without making
    queries execute or changing default parser, error, trace, diagnostic, loader, or generated behavior.
  - [x] **ADDRESSED (verified)** — Match the twentieth canonical response and all required native/loaded/generated/
    traced/reconstructed roles with stable identities, positions, ordering, and observer-failure behavior.
  - [x] **NO REGRESSION** — Static semantic responses, parser results/bytes/errors, trace/diagnostic contracts,
    generated source, primary behavior, and canonical Phase 0 remain exact; admission stays owned by `.10.3.6`.
  - [x] **LOCKSTEP** — API/docs/book/task/index/roadmaps/architecture/live/memory/KM and commit workflow are exact.

- ID: `FUTURE-PARITY-BACKLOG.10.3.6`
  Status: `done`
  Goal: Admit the Perl reference semantic surface through one omission-sensitive exact consumer and canonical gate.
  Depends on: `.10.3.5`
  Acceptance: Add one shared-contract consumer covering source normalization, every compiled/failed/runtime snapshot,
    all 20 query cases, immutable native object API plus neutral JSON, direct/loaded/generated/traced roles, privacy,
    page/budget/errors/explain, non-interference, and stale-host-leak denials. Extend the neutral checker with exact
    Perl path/role/registration/admission mutations, promote only Perl rollout/admission, run focused and complete
    Perl/canonical gates, and synchronize public API/mdBook/roadmaps/Knowledge Map before closing parent `.10.3`.
  Verification: Activated task-tree-first from clean runtime-observation commit `aad4045f` at ahead 271;
    `git_message_brief.txt` is zero bytes, the worktree is clean, and reported disk availability is 113 GiB after
    safe pressure cleanup. Retrieve the exact neutral consumer, rollout, mutation, native-path, registration,
    privacy, query, route, and public-admission authorities through the Knowledge Map and toolbox before edits.
    Compose existing source/static/calls/query/runtime owners without adding another semantic projection path.
    Retrieval confirms the checker still requires every native consumer to be null, hardcodes Perl pending,
    registers only the five separate semantic suites, and rejects 57 mutations. Prior cursor/root admission gates
    establish contract-declared exact-once roles plus checker-owned path/role/driver/rollout topology. New RED
    `t/semantic_introspection_perl_admission.t` executes 12 exact-once roles: strict source normalization, all
    compiled/failed/runtime snapshots, direct/loaded/generated/traced observation, native/neutral JSON, all 20
    canonical query digests, privacy/page/budget/errors/explain, no-execute immutability, and host-leak denial.
    The first harness run exposed two test mistakes, not product drift: `Encode::decode` consumed the raw probe
    without `LEAVE_SRC`, and pagination had been assumed incomplete against the canonical true flag. The native
    query probe proved raw/decoded Unicode answers byte-identical; after correcting the harness, RED fails exactly
    4/18 only because Perl status, consumer topology, rollout status, and canonical registration remain pending.
    GREEN registers that exact consumer without production semantic code: its 18 top-level tests pass, and the
    checker passes six fixture groups, 20 complete response digests, 65 rejected mutations, rollout 2 complete / 7
    pending, and native admission 1 complete / 5 pending. Eight new mutations independently lock Perl path, roles,
    driver, registration, native status, and rollout status; the prior early-admission mutation now targets Rust.
    Complete signoff passes all six semantic suites at 149 assertions, the broader semantic/generated/diagnostic/
    root/cursor gate at 471 assertions plus 127 supplemental cursor/trace assertions, Knowledge Map 659/4,867,
    mdBook, all four doctrines, primary 66/66 in default and POSIX environments, and canonical local CI through
    Phase 0 1,031/1,031 in 633 seconds; the gate exits 0. Generated book/cache output is removed before commit.

  #### Acceptance Checklist

  - [x] **RETRIEVE / TOOLBOX FIRST** — Read the neutral semantic contract/checker, rollout ledger, canonical
    registration, public no-drift, and all native Perl semantic authority cards before deriving the admission gate.
  - [x] **RED / ORACLE** — Add one omission-sensitive exact Perl consumer and checker mutations that fail only
    because Perl path/role/registration/admission topology and rollout promotion are still absent.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Prove the composed consumer reuses the existing constructor, static/calls/
    query/runtime projection, direct/loaded/generated/traced, privacy, page/budget/error, and no-execute seams.
  - [x] **FIX** — Register the one exact composed consumer, extend neutral validation/mutations, and promote only
    the Perl rollout/admission rows without introducing another model, query evaluator, observer, or transport.
  - [x] **ADDRESSED (verified)** — Pass all 20 exact queries, compiled/failed/runtime snapshots, native/neutral
    object answers, required roles, privacy/budgets/errors/explain, non-interference, and stale-host-leak denials.
  - [x] **NO REGRESSION** — Existing semantic/focused/adjacent contracts, primary 66x2, and canonical Phase 0 remain
    exact; Rust/Dart/Julia/Lua and MCP rollout stay pending.
  - [x] **LOCKSTEP** — Public API/book/task/index/roadmaps/ADR/live/memory/KM and commit workflow close parent
    `.10.3` with exact Perl-only rollout/admission totals.

- ID: `FUTURE-PARITY-BACKLOG.10.4`
  Status: `done`
  Goal: Implement the Rust semantic index adapter and exact native conformance.
  Children: `.10.4.0`, `.10.4.0.1`, `.10.4.0.2`, `.10.4.1`, `.10.4.2`, `.10.4.3`, `.10.4.4`, `.10.4.5`,
    `.10.4.6`
  Depends on: `.10.3`
  Acceptance: Project the same model from typed `CompiledSpec`, ActionIR, diagnostics, generated state, and optional
    execution observations through idiomatic Rust types plus neutral JSON; prove exact reference answers across
    direct, loaded, reconstructed, generated, traced/untraced, privacy, pagination/budget, and explain routes;
    reject backend IR leakage and pass the complete Rust/canonical gates.
  Verification: Children `.10.4.0-.10.4.6` map the typed owners, implement the Unicode-label prerequisite, build
    immutable source/static/call/query/runtime projections, and admit one exact 12-role composed consumer. All 20
    digests and every required native/neutral/route/privacy/budget/error/explain/non-interference boundary pass.
    Complete Rust passes core 193/runtime 147/integration 197/exact 105/full manifest/all packages/primary 66x2;
    canonical passes the tracked admission, primary 66x2, and Phase 0 1,031/1,031. Rollout/admission are exactly
    3/9 and 2/6; no backend IR, path, generated implementation source, or query-side execution escapes.

- ID: `FUTURE-PARITY-BACKLOG.10.4.0`
  Status: `done`
  Goal: Map every Rust semantic authority and freeze a dependency-ordered implementation split before behavior.
  Depends on: `.10.3`
  Acceptance: Retrieve existing Rust compiler/ActionIR/descriptor/generated/diagnostic/trace/load/runtime authority
    through the Knowledge Map and LinkedSpec toolbox before re-deriving facts. Probe exact neutral fixtures through
    current public/native seams; identify source mapping, compiled and failed snapshot, call/staged/generated,
    immutable query, optional execution-observation, and direct/loaded/reconstructed/generated/traced ownership and
    gaps. Split `.10.4` into safe dependency-ordered implementation/admission leaves before Rust behavior changes,
    preserve all current primary/corpus/generated behavior, and synchronize task/index/live/memory/KM/book evidence.
  Verification: Activated task-tree-first from clean Perl admission commit `90e5e701` at ahead 272;
    `git_message_brief.txt` is zero bytes and no generated repository artifact is present. Safe disk cleanup leaves
    103 GiB available while preserving the only remaining large temp session because it has live open files. No
    Rust implementation or semantic-publication edit precedes this authority retrieval and split. Exact native
    probes establish that graph/calls/runtime fixtures parse/validate/compile; descriptor projection survives a
    serde round trip; calls retains the staged body AST/job; the failed fixture validates as
    `bare_edge_target_undefined` but compile reports `regex_slot_identity_invalid`; runtime returns `["A","B"]`;
    and the Unicode privacy fixture fails at Rust rule-header parsing. The latter is a real contract conflict:
    accepted neutral v1 and Perl require `Töp`, while the published formal grammar and Rust parser restrict labels
    to ASCII word characters. Implementation cannot pass the exact oracle until the director selects whether Rust
    expands to Unicode word labels or the neutral oracle is revised. The audit also found `TOOLBOX.md` stale at
    57 mutations / rollout 1+8 and with pre-admission Perl prose because the checker does not currently guard its
    current-state lines; `.10.4.0.1` owns that repair before the label decision leaf.
    `rg` confirms no Rust semantic index/query/observation type or sink exists. Direct and generated engines expose
    parallel structural `regex_slot_selected` trace seams and typed rule returns, while ordinary rule/body metadata
    is line-only and staged function sidecars alone retain character spans/body AST/jobs. The temporary probe was
    removed after capture. `python3 tools/check_semantic_introspection_contract.py` passes 6 groups / 20 queries /
    65 mutations / rollout 2+7 / admission 1+5. Focused descriptor 4 and runtime diagnostic/output/loader/trace/
    source-emitter 33 pass. `CARGO_TARGET_DIR=/private/tmp/linkedspec-semantic-rust-audit-target
    bash tools/run_rust_local.sh` passes core 193, descriptor 4, normalization 5, types 8, runtime unit 138,
    integration 197, exact 105-fixture oracle/full generated manifest and all package contracts, plus primary CLI
    66/66 in default and POSIX environments. Repository `rust/target` remains absent. Knowledge Map generation
    reports 660 facts / 4,877 question keys; mdBook, memory/task/doctrine/diff checks pass. Complete canonical local
    CI repeats semantic governance 6/20/65, primary 66x2, and Phase 0 1,031/1,031 in 617 seconds with exit 0. The
    disposable 3.3 GiB Cargo target and generated book are removed before commit. The formerly live 6.5 GiB Pgen
    temp session has no remaining open file/process after the gate and is then safely removed; final disk is
    102 GiB available versus 27 GiB at cleanup start. No parser/compiler/runtime/public API, neutral response,
    rollout, or admission behavior changed.
  Commit: `FUTURE-PARITY-BACKLOG.10.4.0 - map Rust semantic authorities`

  #### Acceptance Checklist

  - [x] **RETRIEVE / TOOLBOX FIRST** — Read canonical Rust semantic/compiler/ActionIR/generated/diagnostic/trace/
    loader/runtime authority cards and use exact project probes before source archaeology.
  - [x] **BASELINE / ORACLE** — Run the neutral checker and focused current Rust seams against all five source
    bundles, 20 requests, generated/reconstructed routes, and optional-observation requirement without behavior edits.
  - [x] **ROOT CAUSE / AUTHORITY MAP** — Record which stable typed owners supply each neutral fact, source span,
    failure, provenance edge, runtime event, and route identity, and identify every missing seam precisely.
  - [x] **SPLIT BEFORE CODE** — Add dependency-ordered source/projection/query/runtime/admission children sized so
    each can be implemented, fully gated, documented, and committed independently.
  - [x] **NO REGRESSION** — Rust package/primary/corpus/generated/trace gates and canonical Phase 0 remain exact;
    semantic rollout/admission stay 2/9 and 1/6 during the audit.
  - [x] **LOCKSTEP** — Task/index/live/memory/KM/book/architecture evidence and commit workflow describe the exact
    Rust plan without claiming an API or promotion before implementation.

- ID: `FUTURE-PARITY-BACKLOG.10.4.0.1`
  Status: `done`
  Goal: Repair semantic-introspection toolbox current-state drift and mechanically prevent recurrence.
  Depends on: `.10.4.0`
  Acceptance: Update `TOOLBOX.md` from the stale 57-mutation / rollout 1+8 / pre-admission Perl description to
    exact current 65-mutation, rollout 2+7, admission 1+5, 12-role Perl ownership. Extend the existing checker so
    these high-value command/output and stage claims cannot drift silently again; add omission/wrong-value proof,
    keep all 20 response digests unchanged, synchronize docs/book/KM, and pass canonical signoff without Rust
    semantic behavior or rollout changes.
  Verification: Activated task-tree-first from clean Rust audit commit `0d9e395c` at ahead 273;
    `git_message_brief.txt` was zero bytes, generated build/book artifacts were absent, and 102 GiB was available.
    `TOOLBOX.md` now states exact 6/20/65, rollout 2+7, admission 1+5, the 106-assertion/eight-route runtime
    proof, and 12-role admission. The checker requires those claims once, forbids stale forms, and internally
    rejects an omitted claim plus 65→64 wrong value without changing the 65 contract mutations or 20 digests.
    Focused semantic proof passes 149 assertions; Knowledge Map is 660 facts / 4,879 keys; mdBook and all four
    doctrines pass. The first canonical run correctly exposed that activation had dropped the separately governed
    repeated-action closeout marker from `docs/TASK_TREE.md`; restoring that exact current marker makes its checker
    pass. The complete rerun passes primary 66x2 and Phase 0 1,031/1,031 in 611 seconds, exit 0. No Rust/product
    behavior, response, rollout, or admission change; generated book/bytecode output is removed before commit.
  Commit: `FUTURE-PARITY-BACKLOG.10.4.0.1 - guard semantic toolbox state`

  #### Acceptance Checklist

  - [x] **CURRENT STATE** — Toolbox command output and Perl runtime/admission descriptions match executable
    6/20/65, rollout 2+7, admission 1+5, 106/eight-route, and exact 12-role ownership.
  - [x] **MECHANICAL OWNERSHIP** — The existing semantic checker reads the toolbox and requires each high-value
    claim exactly once while rejecting every known stale form.
  - [x] **NEGATIVE PROOF** — Internal omission and 65→64 wrong-value probes fail the same pure claim validator
    without changing the ordered 65 semantic-contract mutations.
  - [x] **NO SEMANTIC DRIFT** — All 20 response digests, target rows, rollout rows, and Rust/product behavior are
    unchanged; six Perl suites pass 149 assertions.
  - [x] **LOCKSTEP / SIGNOFF** — Roadmaps, guide, mdBook, KM, task/live/memory records, doctrines, primary 66x2,
    and canonical Phase 0 1,031/1,031 pass; generated artifacts are removed before commit.

- ID: `FUTURE-PARITY-BACKLOG.10.4.0.2`
  Status: `done`
  Goal: Resolve and implement the Rust rule-label contract prerequisite selected by the director.
  Depends on: `.10.4.0.1`
  Acceptance: Reconcile the accepted neutral/Perl `Töp` fixture with the published ASCII-only formal grammar and
    Rust header parser before semantic construction. If Unicode labels are selected, define the exact Unicode word
    class and normalization/case policy, align every Rust label/reference scanner and validator, retain strict UTF-8,
    and add positive/negative cross-route proof. If ASCII is selected, revise the neutral fixture/model/digests and
    every already-admitted Perl proof through a separately justified contract correction. In either direction,
    prevent parser/validator/book drift, run complete Rust/canonical gates, and make no semantic admission claim.
  Verification: **PASS 2026-07-21.** Director selected the recommended Unicode expansion. Activated task-tree-first from
    clean toolbox-guard commit `c234d993` at ahead 274 with zero-byte `git_message_brief.txt`, no generated book,
    Python bytecode, or repository Rust target, and 102 GiB available. The accepted v1 `Töp` fixture/digests and
    admitted Perl behavior remain authoritative; exact Unicode class/normalization/case policy and Rust route
    inventory are the first implementation step. ADR `0051` fixes nonempty pinned Unicode 17 `XID_Continue` at
    every position, exact case-sensitive/normalization-sensitive identity, no normalization/folding, and strict
    UTF-8; it preserves the complete former ASCII class including digit/underscore starts.
    Generated contract/table and one classifier now drive Rust headers plus action/blind/bare references and a
    validator pass for external ASTs. Focused core proof covers Unicode 17 metadata, positive/negative boundaries,
    all source reference forms, invalid programmatic labels, and exact case/normalization identity; focused runtime
    proof covers selectors, descriptor/compiled/generated/emitted identities, strict loader, and trace. Dart,
    Julia, and Lua still contain host-regex label scanners; their `.10.5-.10.7` semantic admissions now explicitly
    inherit ADR `0051` rather than this Rust prerequisite falsely claiming five-backend label rollout.
    Contract regeneration/checking passes at 806 ranges, nine positive fixtures, eight negative fixtures, and two
    distinct pairs. Focused core is 5/5 and runtime is 3/3. Complete Rust passes core 193, runtime 138, integration
    197, exact 105-fixture oracle, full generated manifest, all package contracts, and primary 66x2. Knowledge Map
    is 661 facts / 4,887 keys; mdBook, memory architecture, and all four doctrines pass. Canonical local CI passes
    primary 66x2 and Phase 0 1,031/1,031 in 636 seconds, exit 0. The 2.5 GiB external Cargo target, generated book,
    comparison files, and Python cache are removed. Rollout/admission remain 2/9 and 1/6; `.10.4.1` is next only
    after this leaf's clean commit.

  - [x] **EXACT CONTRACT** — ADR `0051` pins nonempty Unicode 17.0.0 `XID_Continue` at every position, exact
    case-sensitive/normalization-sensitive scalar identity, no normalization/folding, and strict UTF-8.
  - [x] **GENERATED AUTHORITY** — Verified pinned inputs deterministically generate the 806-range neutral contract
    and one Rust classifier; byte comparison and CI ownership prevent data/code drift.
  - [x] **COMPLETE RUST SYNTAX** — Headers plus action/blind/bare references share the classifier; validation also
    rejects invalid external AST declarations/targets through a portable diagnostic.
  - [x] **ROUTE IDENTITY** — Native selectors, compiled descriptors, generated plans/source, trace, and strict file
    loading preserve precomposed/decomposed/case distinctions exactly.
  - [x] **NO FALSE PROMOTION** — Semantic rollout/admission stay 2/9 and 1/6; Dart/Julia/Lua alignment is explicitly
    inherited by `.10.5-.10.7` rather than claimed by this Rust prerequisite.
  - [x] **SIGNOFF / CLEANUP** — Focused 5+3, complete Rust, mdBook/KM/doctrines, canonical 66x2 plus Phase 0
    1,031/1,031, and generated target/book/cache cleanup pass.

- ID: `FUTURE-PARITY-BACKLOG.10.4.1`
  Status: `done`
  Goal: Add the opaque Rust semantic source-map and compiled-or-failed outcome foundation.
  Depends on: `.10.4.0.2`
  Acceptance: Construct once from decoded `&str` or strict UTF-8 bytes plus caller logical name and source ceiling;
    retain canonical bytes/scalar mapping, parsed/validated/compiled-or-failed state, stable generated-plan input,
    and clone-safe private ownership without execution, implicit path reads, public records/query, or host IR leaks.
    Prove malformed UTF-8, exact Unicode coordinates, graph/privacy/failure fixtures, immutability, and diagnostics.
  Verification: Activated task-tree-first from clean Unicode-label commit `5afa0a61` at ahead 275 with a zero-byte
    `git_message_brief.txt`, no generated book, Python cache, repository Rust target, or external Unicode Cargo
    target, and 93 GiB available. Knowledge Map/Toolbox/ADR retrieval fixed the seam before code. Focused
    `semantic_index_foundation` is 6/6: copied raw/decoded source, strict UTF-8 and options, exact multibyte
    byte/scalar coordinates, ceilings, compiled/failed fixtures, shared generated plan, and clone isolation pass.
    Complete Rust passes core 193, runtime units 138, integration 197, exact 105-fixture oracle, full generated
    manifest, all package contracts, and primary 66x2. Semantic governance is 6/20/65 at rollout 2/9 and admission
    1/6; Knowledge Map is 663 facts / 4,900 keys; mdBook, memory, four doctrines, and diff checks pass. The first
    canonical run caught the recurring task-index marker-anchor defect; the exact repeated-action marker was
    restored, focused 8/10/8+0/54 passed, and pending `.22` now owns structural repair. The complete restart passes
    primary 66x2 and Phase 0 1,031/1,031 in 607 seconds, exit 0. The redundant 1.2 GiB external target, final
    2.7 GiB repository target, 12 MiB book, and caches are removed; 93 GiB is available versus 27 GiB at cleanup
    start.

  - [x] **STRICT CONSTRUCTION** — `from_source` and `from_utf8` copy caller input, require logical identity plus
    immutable ceiling, share exact Unicode entry validation, reject malformed UTF-8/options, and read no path.
  - [x] **CANONICAL SOURCE MAP** — Private mapping owns zero-based half-open UTF-8 bytes plus one-based line and
    Unicode-scalar columns, rejects mid-scalar ranges, enforces ceilings, and hashes exact bytes only at text.
  - [x] **COMPILED OR FAILED** — Opaque state retains private parsed/validated/compiled authority or raw portable
    failure, exact entry identity, and shared generated-source-v2 plan input without invoking the target parser.
  - [x] **CLONE / HOST BOUNDARY** — Public foundation accessors return owned plain values; caller mutation cannot
    alter the index, and source/map/AST/`CompiledSpec`/generated implementation text are not exposed or serialized.
  - [x] **NO FALSE PROMOTION** — No v1 record/query/runtime observation/admission surface is claimed; rollout and
    native admission remain 2/9 and 1/6, with normalized static projection owned by `.10.4.2`.
  - [x] **SIGNOFF / CLEANUP** — Complete Rust, semantic governance, mdBook/KM/doctrines, canonical 66x2 plus
    Phase 0 1,031/1,031, and disposable Cargo/book/cache cleanup pass.

- ID: `FUTURE-PARITY-BACKLOG.10.4.2`
  Status: `done`
  Goal: Project exact Rust static graph, privacy, failure, and runtime-static semantics.
  Depends on: `.10.4.1`
  Acceptance: Compose parsed source plus typed `CompiledSpec`, root/family/cursor/slot authorities, and failed
    validation/compile evidence into clone-safe v1 static records/relations. Deep-equal graph, privacy full/limited,
    failed, and runtime-static neutral targets; normalize the Rust failure seam deliberately; expose no query yet.
  Verification: Activated task-tree-first from clean source-foundation commit `c92172b8` at ahead 276. Five
    internal exact-oracle tests deep-equal the complete graph, Unicode privacy text/identity, failed compilation,
    and runtime-static projection, then prove clone isolation and host-object/path denial; foundation remains 6/6.
    Rust formatting and library Clippy pass (the broader test Clippy command reaches an existing unrelated denied
    `3.14` approximate-constant fixture). Complete Rust passes core 193, runtime units 143, integration 197, exact
    105-fixture oracle, full generated manifest, all package contracts, and primary 66x2. Semantic governance stays
    6/20/65 at rollout 2/9 and admission 1/6; Knowledge Map is 665 facts / 4,912 keys; mdBook, memory, and four
    doctrines pass. The first canonical run reproduced `.22`'s mutable task-index marker defect through one
    capitalization change; exact repeated-action proof caught it, the checker-owned lowercase marker was restored,
    and the complete restart passes primary 66x2 plus Phase 0 1,031/1,031 in 609 seconds, exit 0. Private static
    data adds no capabilities/query/runtime observer/admission surface. Disposable Cargo/book/cache artifacts are
    removed before commit; calls/staging `.10.4.3` is the next clean-base leaf.

  #### Acceptance Checklist

  - [x] **TASK-TREE-FIRST / CLEAN BASE** — Activate only from clean `c92172b8`, preserve rollout/admission at
    2/9 and 1/6, and record any startup audit finding under a separate pending owner rather than widening this leaf.
  - [x] **STATIC AUTHORITY** — Correlate immutable authored source/parsed lines with typed compiled root, family,
    cursor, repetition, regex-slot, edge, lifecycle, code-value-shape, and ordering authority without host objects.
  - [x] **FAILED NORMALIZATION** — Preserve authored failed-rule intent and exact source evidence while deliberately
    mapping Rust `bare_edge_target_undefined` / `regex_slot_identity_invalid` seams to the v1
    `unknown_rule_reference` compile diagnostic, decision, explanation, and relations.
  - [x] **EXACT ORACLE / PRIVACY** — Deep-equal graph, Unicode privacy text/identity ceilings, failed compilation,
    and runtime fixture static-half records, relations, ids, source spans, digests, shapes, and canonical order.
  - [x] **CLONE / SCOPE BOUNDARY** — Retain only clone-safe serializable normalized data, prove returned-copy
    isolation and no AST/compiled regex/object/path leak, and expose neither capabilities/query nor execution.
  - [x] **LOCKSTEP / SIGNOFF** — Focused and complete Rust, semantic checker, mdBook/KM/doctrines, canonical CI,
    live docs, cleanup, commit/brief, and clean handoff agree before `.10.4.3`.

- ID: `FUTURE-PARITY-BACKLOG.10.4.3`
  Status: `done`
  Goal: Project exact Rust calls, bindings, staged payload/job/result, and generated provenance.
  Depends on: `.10.4.2`
  Acceptance: Compose function registry sidecars, typed ActionIR, authored-source correlation, and generated-v2
    plan identity into the corrected 22-record/25-relation calls target. Lock source-preorder calls, conservative
    shapes, resolution evidence, Unicode spans, function-shell masking, staged directions, and no AST/source leak.
  Verification: Activated task-tree-first from clean static projection commit `c1a7e413` at ahead 277. Four new
    exact regressions deep-equal all 22 records / 25 relations, lock source-preorder calls and function/helper
    resolution, staged directions, Unicode scalar-to-byte excerpts/columns, interleaved function-shell isolation,
    and host/source leak denial; all nine static tests and foundation 6 pass. Complete Rust passes core 193,
    runtime units 147, integration 197, exact 105-fixture oracle, full generated manifest, all package contracts,
    and primary 66x2. Normal library Clippy exits 0 with the existing repository warning baseline. Semantic
    governance remains 6/20/65 at rollout 2/9 and admission 1/6. Knowledge Map is 666 facts / 4,923 keys; mdBook,
    memory, four doctrines, task metadata, formatting, and whitespace pass. Canonical local CI passes primary
    66x2 plus Phase 0 1,031/1,031 in 619 seconds, exit 0. Generated 3.0 GiB Rust target, 12 MiB book, and Python
    cache are removed before commit. No capabilities/query/runtime observer/admission surface lands; `.10.4.4`
    follows only after the clean commit.

  #### Acceptance Checklist

  - [x] **TASK-TREE-FIRST / CLEAN BASE** — Activate only from clean `c1a7e413`, preserve rollout/admission at
    2/9 and 1/6, and do not expose query, runtime observation, or admission early.
  - [x] **TYPED AUTHORITY** — Compose compiled function registry/sidecars, typed ActionIR, existing helper
    contracts, immutable source mapping, and shared generated-v2 plan identity without parsing generated code.
  - [x] **SOURCE / ORDER** — Preserve source-preorder calls, Unicode byte/scalar spans, function-shell masking,
    binding ownership, payload/job/result ranges, and canonical ids/order across interleaved authored functions.
  - [x] **SHAPES / RESOLUTION** — Emit conservative argument/result/target shapes, exact helper/function resolution
    evidence, staged consumes/produces directions, and corrected 22-record/25-relation calls facts.
  - [x] **CLONE / SCOPE BOUNDARY** — Retain only clone-safe serializable normalized data; prove no typed AST,
    ActionIR object, compiled expression/regex, generated implementation source, path, or mutable alias escapes.
  - [x] **LOCKSTEP / SIGNOFF** — Exact calls oracle, foundation/static regressions, complete Rust, semantic checker,
    mdBook/KM/doctrines, canonical CI, cleanup, commit/brief, and clean handoff agree before `.10.4.4`.

- ID: `FUTURE-PARITY-BACKLOG.10.4.4`
  Status: `done`
  Goal: Expose immutable Rust semantic capabilities and query evaluation.
  Depends on: `.10.4.3`
  Acceptance: Add idiomatic native capabilities/query methods over only cloned normalized projection data; match
    all 19 static digests and exact ids/order/privacy/pages/budgets/errors/explain behavior. Prove returned-value
    isolation, query non-interference, JSON identity, and inability to compile, execute, trace, inspect IR, or read
    paths. Runtime events remain pending.

  #### Acceptance Checklist

  - [x] **TASK-TREE-FIRST / CLEAN BASE** — Activate only from clean `68e31222`, preserve rollout/admission at 2/9
    and 1/6, and keep runtime observation/admission absent.
  - [x] **IMMUTABLE NATIVE SURFACE** — Expose idiomatic capabilities/query methods over fresh clones of the retained
    normalized projection only; no AST, ActionIR, compiler object, regex, path, or generated source can escape.
  - [x] **EXACT STATIC ORACLE** — Match all 19 static response digests plus exact ids/order/source privacy,
    directional traversal, pages/cursors, budgets/costs, errors, and explain evidence.
  - [x] **CEILINGS / NON-INTERFERENCE** — Enforce the immutable construction ceiling, deny elevation, preserve
    query/input isolation, and prove queries cannot compile, execute, trace, mutate, or capture runtime events.
  - [x] **NATIVE / JSON IDENTITY** — Return clone-safe native values whose neutral JSON projection is exact and
    deterministic across repeated/interleaved queries without caller aliasing.
  - [x] **LOCKSTEP / SIGNOFF** — Focused exact query proof, complete Rust, semantic checker, mdBook/KM/doctrines,
    canonical CI, cleanup, commit/brief, and clean handoff agree before `.10.4.5`.

  Implementation evidence: `SemanticQuery` supplies typed operation/direction/page/budget/source requests;
  `SemanticIndex::capabilities`, `query`, and `query_neutral` share one evaluator over a fresh normalized-projection
  clone. Five focused tests match all 19 static digests through native and neutral paths, cover the exact 26 error
  boundaries, and lock privacy, traversal, pages/budgets/costs, explanations, clone/input isolation, deterministic
  interleaving, absent execution state, and host/path/IR denial. Complete Rust passes core 193, runtime 147,
  integration 197, exact 105/full generated manifest/all packages, and primary 66x2; the query target is
  Clippy-clean above the existing library warning baseline. Semantic 6/20/65, KM 667/4,937, mdBook, memory, and all
  four doctrines pass. Canonical CI passes primary 66x2 and Phase 0 1,031/1,031 in 631 seconds, exit 0. The
  generated 3.3 GiB Rust target, 12 MiB book, and 28 KiB Python cache are removed before commit. Runtime/admission
  and both ledgers are unchanged; `.10.4.5` follows only after the clean commit.

- ID: `FUTURE-PARITY-BACKLOG.10.4.5`
  Status: `done`
  Goal: Capture typed Rust runtime semantic observations through every execution route.
  Depends on: `.10.4.4`
  Acceptance: Add an optional invocation-local typed observation sink distinct from trace and diagnostics at the
    parallel direct/generated slot-selection and rule-result seams. Derive a new immutable post-execution index and
    match the twentieth digest across direct, loaded, reconstructed, generated, traced/untraced routes without
    changing result/cursor/trace/diagnostic behavior or permitting query-side execution.

  #### Acceptance Checklist

  - [x] **TASK-TREE-FIRST / CLEAN BASE** — Activate only from clean `1cb0c353`, preserve rollout/admission at 2/9
    and 1/6, and keep composed Rust admission owned by `.10.4.6`.
  - [x] **TYPED OBSERVATION MODEL** — Add clone-safe invocation-local slot-selection and completed rule-result
    observations with exact v1 validation, ordering, ids, values, and no trace-text or host-object dependency.
  - [x] **DIRECT / GENERATED SEAMS** — Capture the same observations at authoritative direct and generated
    slot/result seams without changing result, input/cursor, trace, diagnostic, or ordinary no-observer behavior.
  - [x] **IMMUTABLE DERIVATION / EXACT ORACLE** — Derive a new post-execution `SemanticIndex` without mutating the
    pre-execution index and match the twentieth response digest through typed and raw-neutral queries.
  - [x] **ROUTE IDENTITY / NON-INTERFERENCE** — Prove direct, loaded, reconstructed, generated, traced, and
    untraced execution routes produce identical completed observations while query remains unable to execute.
  - [x] **LOCKSTEP / SIGNOFF** — Focused observation/query proof, complete Rust, semantic checker, mdBook/KM/
    doctrines, canonical CI, cleanup, commit/brief, and clean handoff agree before `.10.4.6`.

  Implementation evidence: `RuntimeSemanticObservationSink` is a cloneable invocation-local typed callback in
  `ExecutionOptions`; direct and generated slot-selection seams emit exact authored slot identities after the
  accepted match, and option-bearing entry wrappers emit one successful final result. The result hashes exact UTF-8
  input bytes, positions are Unicode-scalar offsets, no-sink execution allocates no event/digest, failed execution
  emits no completion, and observer panics preserve caller identity. `with_execution_observation` validates the
  typed stream and static topology, then clones/canonicalizes execution/event/`observed_as` data without mutating
  the base or enabling query-side execution. Seven focused tests match the twentieth digest through typed and raw-
  neutral queries across direct, loaded, reconstructed, generated-plan, source-emitter, traced/untraced, and an
  independently compiled emitted module. Foundation 6/query 5/observation 7, complete Rust core 193/runtime 147/
  integration 197/exact 105/full manifest/all packages/primary 66x2, focused new-code Clippy, and semantic 6/20/65
  at unchanged rollout 2/9 and admission 1/6 pass. KM is 668/4,949; mdBook, memory, task metadata, all four
  doctrines, format, and diff pass. Canonical CI passes primary 66x2 and Phase 0 1,031/1,031 in 647 seconds, exit 0.
  The generated 3.2 GiB target, 12 MiB book, and Python cache are removed before commit. `.10.4.6` follows only
  after the clean commit.

- ID: `FUTURE-PARITY-BACKLOG.10.4.6`
  Status: `done`
  Goal: Admit the exact Rust semantic implementation and close the Rust parent.
  Depends on: `.10.4.5`
  Acceptance: One omission-sensitive Rust consumer owns exact source/compiled/failed/runtime/native/JSON/query/
    route roles, all 20 digests, privacy/page/budget/error/explain behavior, no-execute immutability, and host-leak
    denial. Register it in canonical CI, advance only Rust rollout/admission, pass full package/primary/corpus/
    generated/trace and canonical gates, synchronize all public docs, and close `.10.4` cleanly.
  Verification: Activated task-tree-first on 2026-07-21 from clean Rust runtime-observation commit `a79512c9` at
    ahead 280. `git_message_brief.txt` is zero bytes and generated Rust target/book/cache artifacts are absent.
    Retrieve the exact neutral checker, Perl composed-admission precedent, Rust semantic authority cards, rollout
    ledger, canonical registration, and prior omission-sensitive Rust consumer topology before implementation.
    Retrieval proves this is topology-only: all semantic owners already exist. New
    `semantic_introspection_rust_admission.rs` declares the same 12 ordered roles as Perl while covering Rust's
    loaded/reconstructed, generated-plan/source-emitter, and traced variants. The first compile found and corrected
    one harness-only enum assertion; clean RED then executes every role and all 20 digests before failing solely on
    Rust status `pending`. GREEN passes the one exact consumer in 78.93s. Foundation 6/query 5/observation 7 plus
    admission 1 pass together, and focused new-test Clippy is clean. The checker now rejects eight additional Rust
    path/role/driver/registration/status/rollout mutations, advances only Rust, and passes at 6 fixture groups / 20
    exact queries / 73 mutations / rollout 3+6 / admission 2+4. Public guide, roadmaps, ADR, mdBook, Toolbox, and
    Knowledge Map 669/4,960 describe the admitted boundary. Complete Rust passes core 193, runtime units 147,
    integration 197, exact 105/full generated manifest/all package targets, the composed admission in 79.15s, and
    primary CLI 66x2. Canonical CI independently passes the tracked admission in 80.84s, primary 66x2, and Phase 0
    1,031/1,031 in 651s, exit 0. mdBook, memory, task metadata, all four doctrines, format, JSON, KM, and diff pass;
    the reproducible 3.0 GiB Rust target, 12 MiB book, and 28 KiB cache are removed. Parent `.10.4` closes and Dart
    `.10.5` is the next clean-boundary frontier.
  Commit: `FUTURE-PARITY-BACKLOG.10.4.6 - admit Rust semantic introspection`

  #### Acceptance Checklist

  - [x] **RETRIEVE / TOOLBOX FIRST** — Read the neutral semantic contract/checker, Perl composed-admission
    precedent, Rust source/static/calls/query/runtime authorities, rollout ledger, and canonical registration.
  - [x] **RED / ORACLE** — Add one omission-sensitive Rust admission consumer plus checker mutations that fail only
    because Rust path/roles/registration/admission topology and Rust-only rollout promotion are absent.
  - [x] **ONE COMPOSED CONSUMER** — Reuse the existing Rust constructor, static/calls/query/runtime projection and
    direct/loaded/reconstructed/generated/traced seams; do not introduce another model, evaluator, or observer.
  - [x] **EXACT BEHAVIOR** — Cover compiled/failed/runtime snapshots, native and neutral JSON, all 20 digests,
    privacy, pagination, budgets, errors, explain, no-execute immutability, route identity, and host-leak denial.
  - [x] **PROMOTE / REGISTER** — Lock exact consumer path and role topology, register the test canonically, and
    advance only Rust rollout/admission while leaving Dart/Julia/Lua/MCP pending.
  - [x] **NO REGRESSION** — Pass focused admission and adjacent semantic tests, complete Rust package/primary/
    corpus/generated/trace gates, and canonical Phase 0 without changing parser or query behavior.
  - [x] **LOCKSTEP / CLOSEOUT** — Synchronize public API/book/task/index/roadmaps/live/memory/KM, close `.10.4`,
    clean reproducible artifacts, and complete the per-slice commit workflow.

- ID: `FUTURE-PARITY-BACKLOG.10.5`
  Status: `done` (2026-07-22; exact Dart semantic adapter and composed admission complete)
  Goal: Implement the Dart semantic index adapter and exact native conformance.
  Children: `.10.5.0`, `.10.5.0.1`, `.10.5.0.2`, `.10.5.1`, `.10.5.2`, `.10.5.3`, `.10.5.4`, `.10.5.5`,
    `.10.5.6`
  Depends on: `.10.4`
  Acceptance: Project the same model from Dart compiled/action/provenance/diagnostic/generated authorities through
    idiomatic Dart types plus neutral JSON; prove exact reference answers and non-interference across every shared
    route, privacy/page/budget/explain case, omission mutation, complete package/primary/corpus/generated gate, and
    canonical gate without exposing Dart AST serialization as the contract. Before the `Töp` privacy fixture can
    be admitted, align every Dart rule declaration/reference/artifact/selector route with ADR `0051`'s pinned
    Unicode 17 `XID_Continue` and exact identity contract.
  Verification: Activated task-tree-first on 2026-07-21 from clean Rust admission commit `0de66ae9` at ahead 281.
    `git_message_brief.txt` is zero bytes and reproducible target/book/cache artifacts are absent. Knowledge Map
    retrieval and ADR `0051` establish that label alignment is a prerequisite distinct from semantic projection;
    `.10.5` therefore begins with an exact Dart authority/gap audit and dependency-ordered split before behavior.
    The completed tree now owns strict source/outcome construction, exact static and calls/staged/generated
    projections, immutable typed/raw-neutral query, typed invocation-local runtime observation, immutable observed-
    index derivation, every generated/emitted/traced route, and one exact 12-role admission consumer. All 20
    digests match; eight Dart-specific topology mutations raise governance to 6/20/81, rollout 4/9, and native
    admission 3/6. Complete Dart passes format 85/0, fatal analysis, package 336/336, primary 66x2, and corpus
    105/105 without exposing AST/IR/path/host state or adding a parallel semantic implementation.

  #### Acceptance Checklist

  - [x] **TASK-TREE-FIRST / CLEAN BASE** — Activate only from clean `0de66ae9`; preserve semantic governance at
    6/20/73, rollout 3/9, and admission 2/6 until an exact composed Dart consumer passes.
  - [x] **RETRIEVE / TOOLBOX FIRST** — Read and probe the exact Dart source/validation/compiled/ActionIR/staged/
    generated/diagnostic/runtime/trace/load authorities plus ADR `0051` before source archaeology or behavior.
  - [x] **SPLIT BEFORE CODE** — Freeze bounded dependency-ordered Unicode-label, semantic construction/projection,
    query, runtime-observation, and admission children before implementing any Dart behavior.
  - [x] **UNICODE LABEL PREREQUISITE** — Apply pinned Unicode 17 `XID_Continue` exact scalar identity to every Dart
    declaration/reference/selector/artifact/diagnostic/trace/generated route without semantic promotion.
  - [x] **EXACT SEMANTIC ADAPTER** — Compose idiomatic immutable Dart source/static/call/query/runtime owners and
    one omission-sensitive consumer that matches all 20 neutral responses without AST/IR/path/host leakage.
  - [x] **LOCKSTEP / SIGNOFF** — Pass focused, complete Dart package/corpus/generated/primary and canonical gates;
    synchronize public/book/task/roadmap/live/memory/KM surfaces, cleanup, commit each child, and close cleanly.

- ID: `FUTURE-PARITY-BACKLOG.10.5.0`
  Status: `done`
  Goal: Map every Dart semantic and Unicode-label authority, then freeze a safe dependency-ordered split.
  Depends on: `.10.4.6`
  Acceptance: Retrieve the exact Dart parser/validator/compiled descriptor/ActionIR/staged/generated/loader/
    diagnostic/trace/runtime authorities through the Knowledge Map and LinkedSpec toolbox before re-deriving facts.
    Probe all five neutral semantic source bundles plus the Unicode label contract through current native routes;
    identify exact source mapping, compiled/failed/static/calls/query/runtime observation, route, and host-leak seams;
    freeze bounded prerequisite and implementation/admission children before behavior; preserve package/corpus/
    generated/primary behavior and semantic rollout/admission; synchronize task/index/live/memory/KM/book evidence.
  Verification: Activated task-tree-first from clean Rust admission `0de66ae9` at ahead 281 with a zero-byte
    commit brief and no reproducible artifacts. Knowledge Map/Toolbox retrieval preceded exact temporary Dart
    probes. Graph, calls/staging, and runtime sources parse, validate, compile, reconstruct through `SpecFile` JSON,
    and retain generated plans; runtime returns `["A","B"]`. Failed source reports
    `bare_edge_target_undefined` at `normalize_edges`; privacy source stops at the current `Töp::` header boundary.
    Current host-`\w` declarations reject every non-ASCII contract label, action/blind `Töp` targets silently
    truncate to `T`, bare `Töp` stays raw, and programmatic/deserialized invalid `Top-Rule` labels validate and
    compile. A valid externally supplied `Töp` survives compiled order, descriptor, generated plan, emitted source,
    selector, and trace exactly. Reusable staged/compiled/ActionIR/function/diagnostic/generated/runtime owners and
    missing exact source map, immutable projection/query, and typed observation seams are recorded in the durable
    authority card; bounded `.10.5.0.1-.10.5.6` children own every dependency before behavior.

    The audit also proves shared authority and evidence drift. Canonical `specs/spec.spec` still uses host `\w` for
    label productions. Its SHA-256 is `9cb540e26622741b90a97f25e46e4c27accdece43c40cc106cf30cc273f3eab1`,
    while all four `spec_spec_*` corpus inputs are one stale snapshot at
    `e0a1b63b276c2a896c577192d4b399c88f21539555835018ce8117b91a14b25f`. The stale source omits bare-edge
    productions and retains lifecycle `(\w++)`; direct Dart execution of current canonical source reaches an
    unsupported lifecycle/named-group `FormatException`. `.10.5.0.1` owns verbatim regeneration, mechanical
    byte/hash freshness, the current Dart structural bridge, and shared pinned-label closure; 105/105 is retained
    as a baseline but not cited as current self-hosted proof.

    Complete behavior-free signoff passes Dart format 63/0, fatal analysis, package 276, primary 66/66 default and
    POSIX, and corpus 105/105. Neutral semantic governance passes 6 fixture groups / 20 exact queries / 73 rejected
    mutations at rollout 3/9 and admission 2/6; Unicode proof passes version 17.0.0, 806 ranges, 9 positive, 8
    negative, and 2 distinct pairs. Knowledge Map is 670 facts / 4,975 keys; memory, task metadata, all four
    doctrines, mdBook, and whitespace pass. Canonical local CI independently passes its semantic/primary stages and
    Phase 0 1,031/1,031 in 659 seconds, exit 0. No Dart or neutral executable behavior changed.

  #### Acceptance Checklist

  - [x] **TASK-TREE-FIRST / CLEAN BASE** — Activate from clean `0de66ae9` before Dart source inspection or behavior.
  - [x] **RETRIEVE / TOOLBOX FIRST** — Read exact neutral, ADR `0051`, Dart authority cards, toolbox probes, and
    canonical/complete gate registration before source archaeology.
  - [x] **BASELINE / ORACLE** — Run the neutral checker and exact Dart probes over graph/calls/failed/runtime/privacy
    sources, typed compiled/generated/loaded/traced routes, label fixtures, primary, and package/corpus baselines.
  - [x] **ROOT CAUSE / AUTHORITY MAP** — Record each reusable typed owner and every missing mapping, observation,
    source-span, failure normalization, label, query, and route seam without treating AST JSON as the contract.
  - [x] **SPLIT BEFORE CODE** — Add bounded dependency-ordered label prerequisite, semantic foundation/projection/
    query/runtime/admission children with precise acceptance before any Dart behavior changes.
  - [x] **CORPUS FRESHNESS AUDIT** — Prove the four checked-in `spec_spec_*` inputs are byte-identical stale
    snapshots rather than current `specs/spec.spec`, record both hashes and the current Dart canonical failure,
    and assign regeneration plus freshness enforcement to `.10.5.0.1` before counting self-hosted corpus proof.
  - [x] **NO REGRESSION / LOCKSTEP** — Preserve semantic 6/20/73 at 3/9 + 2/6, pass complete/canonical baselines,
    sync public/book/task/index/live/memory/KM, cleanup, and commit the behavior-free audit cleanly.

- ID: `FUTURE-PARITY-BACKLOG.10.5.0.1`
  Status: `done` (2026-07-22)
  Goal: Reconcile the first-authoritative self-hosted grammar with ADR `0051` before claiming another backend.
  Children: `.10.5.0.1.0`, `.10.5.0.1.1`, `.10.5.0.1.2`
  Depends on: `.10.5.0`
  Acceptance: Replace `specs/spec.spec`'s host-`\w` rule-label authority with a deterministic repository-pinned
    Unicode 17 `XID_Continue` route that preserves exact scalar identity and remains executable across the admitted
    runtime set. Extend the neutral generator/checker and self-hosted corpus proof so declarations plus action,
    blind, and bare references cannot truncate, normalize, inherit host Unicode versions, or drift from the formal
    grammar. Regenerate every checked-in `spec_spec_*` `input.spec` from the current canonical source, require
    byte/hash freshness mechanically, and update Dart's structural PCRE bridge so the actual current lifecycle and
    bare-edge grammar executes rather than accepting a stale snapshot. Do not advance Dart or semantic rollout/
    admission.
  Verification: Children `.0-.2` generate and independently reconstruct one exact 806-range Unicode 17 class,
    consume it at all 12 canonical declaration/reference sites, execute current lifecycle/bare syntax on Dart,
    freshness-lock all four self-hosted corpus inputs, repair sparse Perl AND traversal, and reject physical-line
    label-prefix truncation. Current canonical SHA-256 is
    `ce409f572887d102543d995e197666df668e47963f572a3a376622249e57fa7c`. Exact current-grammar proof passes all
    9 positive / 8 negative / 2 distinct fixtures plus header/action/blind no-prefix and newline cases on the
    Perl/Rust/Dart/Julia/Lua default+POSIX matrix. Complete corpus, backend, mdBook, Knowledge Map 672/4,998,
    doctrine, and canonical gates pass; semantic governance remains 6/20/73 at rollout 3/9 and admission 2/6.

  #### Acceptance Checklist

  - [x] **TASK-TREE-FIRST / CLEAN BASE** — Activate only after clean `.10.5.0`; keep semantic 6/20/73, rollout
    3/9, and admission 2/6 unchanged.
  - [x] **FIRST AUTHORITY** — Resolve the exact ADR `0012`/`0051` contract for `specs/spec.spec` without making a
    bootstrap parser, host `\w`, locale, or toolchain Unicode table the lasting language owner.
  - [x] **DETERMINISTIC CONTRACT DATA** — Reuse the verified Unicode 17 source/ranges and generate or validate the
    self-hosted representation byte-for-byte; reject version, omission, range, and normalization drift.
  - [x] **ALL LABEL PRODUCTIONS** — Cover rule headers plus action-block/fluent/bare, blind-block/fluent/bare, and
    bare-edge group/index forms while leaving lifecycle/function/helper/mark identifiers under their own grammar.
  - [x] **CANONICAL CORPUS FRESHNESS** — Regenerate all four `spec_spec_*` fixtures through
    `tools/gen_oracle_corpus.pl`, require their `input.spec` bytes/hash to equal current `specs/spec.spec`, and make
    stale copies fail before any backend can count them as current self-hosted grammar evidence.
  - [x] **CURRENT DART STRUCTURAL BRIDGE** — Admit the canonical lifecycle alternation and bare-edge productions in
    Dart's structural PCRE recognizer, then prove the current source itself executes; 105/105 over stale copies is
    explicitly not acceptance evidence.
  - [x] **CROSS-RUNTIME PROOF** — Execute positive, negative, distinct, and no-prefix-truncation cases through the
    self-hosted grammar on every currently admitted runtime route required by the neutral grammar owner.
  - [x] **NO FALSE PROMOTION / SIGNOFF** — Synchronize formal/public/KM/task state and pass complete affected/
    canonical gates without claiming Dart label or semantic admission.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.0.1.0`
    Status: `done`
    Goal: Generate and independently guard one portable pinned self-hosted rule-label regex class.
    Depends on: `.10.5.0`
    Acceptance: Extend the verified Unicode 17 generator with one deterministic UTF-8 literal-range regex-class
      artifact derived from the same 806 ranges. Independently reconstruct and byte-check it in the neutral
      checker, prove every positive/negative/distinct fixture and delimiter safety, and register the artifact in
      canonical CI. Do not yet change `specs/spec.spec`, runtime behavior, corpus fixtures, or semantic ledgers.
    Verification: Activated task-tree-first from clean audit `0110ea40` at ahead 282. Missing-artifact RED failed
      before generation. The shared generator now writes a 5-line / 5,991-byte UTF-8 artifact carrying exact
      contract id, Unicode 17.0.0, source-data SHA-256
      `d1b00bda47306e61ee20a7f63db783f98b15d8d15b876c7506bc4b79ecebc0bb`, and one literal class encoding all
      806 maximally merged ranges. Its independent checker reconstructs metadata and class bytes from the neutral
      JSON rows, rejects unsafe delimiter membership, compiles the result, accepts all 9 positive labels plus 2
      distinct pairs, and rejects all 8 negative labels. Deliberate `17.0.0` to `17.0.1` metadata drift fails the
      byte check; restored generation passes. Canonical CI requires the tracked artifact and passes the four
      doctrines, semantic 6/20/73, Unicode 806/9/8/2, Rust admission, primary 66/66 twice, and Phase 0
      1,031/1,031, exit 0. Its first run exposed only the known `.22` mutable task-index marker coupling; restoring
      the exact unchanged repeated-action marker made its focused 8/0/54 check and the corrected full run green.
      Knowledge Map is 670 facts / 4,977 keys; mdBook, memory/task metadata, whitespace, and artifact cleanup pass.
      `specs/spec.spec`, all corpus inputs, runtime behavior, and semantic ledgers remain unchanged.

    #### Acceptance Checklist

    - [x] **TASK-TREE-FIRST / CLEAN BASE** — Activate from clean audit `0110ea40` before generator/checker changes.
    - [x] **RED / INDEPENDENT ORACLE** — Make the checker require the missing generated artifact and independently
      derive its exact literal range class from neutral contract rows rather than trusting generator output alone.
    - [x] **GENERATED AUTHORITY** — Emit one metadata-bearing UTF-8 class whose scalar endpoints exactly encode all
      806 maximally merged ranges and contain no regex/delimiter characters requiring host-specific escaping.
    - [x] **FIXTURE / DRIFT PROOF** — Compile the class independently, accept every positive/distinct label, reject
      complete negative labels, and reject version/hash/range/class/artifact omission or byte drift.
    - [x] **NO BEHAVIOR / SIGNOFF** — Keep canonical grammar/corpus/runtime and semantic 6/20/73 at 3/9 + 2/6
      unchanged; pass generator/checker, governance, docs/KM/book where affected, cleanup, and commit cleanly.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.0.1.1`
    Status: `done`
    Goal: Consume the pinned class in canonical grammar and execute its current structural forms on Dart.
    Depends on: `.10.5.0.1.0`
    Acceptance: Replace only rule declaration/reference `\w` sites in `specs/spec.spec` with the generated exact
      class while preserving function/helper/lifecycle/fluent/mark grammars. Extend Dart regex compilation and
      bounded structural recognizers for the generated label atom, explicit lifecycle alternation, and bare-edge
      block/fluent families. Prove direct execution of current canonical source and exact group/capture behavior;
      do not regenerate corpus or claim Dart label/semantic admission yet.
    Verification: Activated task-tree-first from clean generated-class commit `f356a2dd` at ahead 283 with a
      zero-byte commit brief and no reproducible artifacts. Focused RED proves zero canonical generated-class sites,
      Dart's supplementary literal class fails without Unicode mode, and current lifecycle `blkLB` reaches
      `FormatException: Invalid group`. Canonical `specs/spec.spec` now embeds the generated atom exactly 12 times:
      one header, two action-block targets, two bare-block targets, and one each in the remaining action/blind/bare
      productions. The independent checker locks those per-production counts; a deliberate `action_bare` fallback
      to `\w` fails and restored GREEN passes Unicode 806/9/8/2.

      Dart derives each structural label atom from its authored pattern, automatically enables Unicode mode for
      supplementary literals, accepts both current explicit and intentionally stale lifecycle prefixes, and adds
      bounded physical-line bare block/fluent matchers. Direct current-source proof executes all ten productions
      with ASCII, digit-start, underscore, precomposed/decomposed Latin, Greek, CJK, middle-dot, and supplementary
      labels while preserving exact target/index captures. Focused matching/interpreter/corpus/current-source tests
      pass 93; fatal analysis is clean; complete Dart passes format 64/0, package 279, primary 66/66 twice, and the
      unchanged corpus 105/105; Perl directly compiles current source. Current canonical SHA-256 is
      `43cddeaea03cfaddce941ca87f66185de1abf81e281e86c29156fbad16f6d2ce`; all four corpus copies deliberately remain
      `e0a1b63b...` for `.2`. Knowledge Map is 670 facts / 4,981 keys; mdBook, memory/task metadata, four doctrines,
      and whitespace pass. Canonical CI passes semantic 6/20/73, Rust admission, primary 66x2, and Phase 0
      1,031/1,031, exit 0. Corpus inputs, Dart's hardcoded label parser/validator, and semantic ledgers are unchanged.

    #### Acceptance Checklist

    - [x] **TASK-TREE-FIRST / CLEAN BASE** — Activate from clean `.10.5.0.1.0` before grammar or Dart changes.
    - [x] **EXACT PRODUCTION INVENTORY / RED** — Identify every rule-label declaration/reference site and make
      focused tests fail for current canonical direct execution plus Unicode self-hosted declaration/references.
    - [x] **CANONICAL GRAMMAR CONSUMER** — Replace only rule-label atoms with the generated exact class while
      preserving lifecycle, function, helper, fluent, mark, capture, and named-group grammars and indices.
    - [x] **DART STRUCTURAL BRIDGE** — Enable Unicode regex mode when supplementary literals require it and extend
      only the bounded structural recognizers needed by current explicit lifecycle and bare-edge forms.
    - [x] **DIRECT CURRENT-SOURCE PROOF** — Compile and execute current `specs/spec.spec` directly on Dart with
      exact declaration/reference/capture/group behavior; do not count stale corpus snapshots as acceptance.
    - [x] **NO REGENERATION / SIGNOFF** — Leave all four corpus inputs for `.10.5.0.1.2`, preserve semantic
      6/20/73 at 3/9 + 2/6, pass affected/canonical gates, synchronize docs/KM/task state, cleanup, and commit.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.0.1.2`
    Status: `done` (2026-07-22)
    Goal: Regenerate, freshness-lock, and compose the current self-hosted corpus proof across admitted runtimes.
    Depends on: `.10.5.0.1.1`
    Children: `.10.5.0.1.2.0`, `.10.5.0.1.2.1`
    Acceptance: Regenerate all four `spec_spec_*` inputs and expected outputs through the oracle generator, add a
      mechanical canonical byte/hash freshness check, and execute positive/negative/distinct/no-truncation grammar
      cases plus the refreshed fixtures across required Perl/Rust/Dart/Julia/Lua routes. Pass complete affected and
      canonical gates, synchronize public/durable state, close parent `.10.5.0.1`, and preserve semantic ledgers.
    Verification: Activated task-tree-first from clean shared-grammar commit `15c97761` at ahead 284. `.2.0`
      freshness-locks all four `spec_spec_*` inputs and repairs the sparse Perl AND regression exposed by atomic
      regeneration. `.2.1` resolves the remaining toolbox-proven prefix truncation: headers are physical-line
      anchored with an extra-colon guard, and bare action/blind references own complete CRLF/LF-aware lines. One
      omission-sensitive current-grammar manifest covers every neutral label fixture and all three no-prefix
      surfaces on the exact 5x2 matrix. The first Rust leg exposed absent `entry_group(N)` returning empty string;
      Rust now returns `Undef`/JSON null like its existing `match_group` seam and the other runtimes. Canonical
      source and all four inputs share SHA-256 `ce409f57...`; Rust/Dart/Julia/Lua corpus routes pass 105/105,
      complete Rust and dual-ABI Lua gates pass, and canonical CI passes Phase 0 1,031 plus stable 5x2x66 and
      focused 5x2x1, exit 0. Knowledge Map is 672/4,998; book/doctrines/diff/cleanup pass.

    #### Acceptance Checklist

    - [x] **TASK-TREE-FIRST / CLEAN BASE** — Activate from clean `.10.5.0.1.1` before corpus or checker changes.
    - [x] **ORACLE / FRESHNESS RED** — Retrieve the exact generator and five-runtime corpus owners, prove all four
      inputs stale, and make canonical checking reject their old bytes before regeneration.
    - [x] **VERBATIM REGENERATION** — Regenerate all four `spec_spec_*` fixtures through `tools/gen_oracle_corpus.pl`
      and require every input byte/SHA to equal current canonical `specs/spec.spec`.
    - [x] **CROSS-RUNTIME LABEL PROOF** — Execute positive, negative, distinct, and no-prefix-truncation declaration/
      reference cases through the shared self-hosted grammar on required Perl/Rust/Dart/Julia/Lua routes.
    - [x] **CURRENT CORPUS PROOF** — Run refreshed `spec_spec_*` cases and complete affected corpus gates without
      weakening structural, capture, lifecycle, generated, or primary behavior.
    - [x] **LOCKSTEP / CLOSE PARENT** — Preserve semantic 6/20/73 at 3/9 + 2/6, synchronize public/book/KM/task/
      roadmap/live/memory state, pass canonical CI, cleanup, close `.10.5.0.1`, and commit cleanly.

    - ID: `FUTURE-PARITY-BACKLOG.10.5.0.1.2.0`
      Status: `done` (2026-07-22)
      Goal: Freshness-lock the self-hosted corpus and repair the Perl sparse-AND regression exposed by regeneration.
      Depends on: `.10.5.0.1.1`
      Acceptance: Require all four self-hosted corpus inputs to equal the canonical grammar byte-for-byte, preserve
        duplicate-slot identity while consuming non-action structural gaps in ordered Perl rules, restore both
        governed capture outputs through live and generated routes, regenerate the atomic 105-case oracle without
        unrelated output drift, pass focused/corpus/canonical gates, synchronize durable state, and commit cleanly.
      Verification: Task-tree split before the blocking Perl fix. `LinkedSpec::Get`, `return_descriptor`, emitted
        source, and routed high trace prove `Value:AND` retains regex slots `A`, `xxB`, `C` and action edges `0`, `2`,
        but `and_acode_seq` loops over two action dependencies and tries required `C` at cursor 1 immediately after
        `A`; both governed capture fixtures return null. Atomic oracle regeneration changed only those two expected
        outputs plus the intended four self-hosted input copies, so the nulls are a live regression, not stale data.
        The repaired live/emitted handlers traverse all three structural slots and dispatch only authored actions;
        a repeated-AND one-action case independently locks generated slot-map completeness. A second 105-case
        regeneration restores both governed outputs and leaves only the intended four inputs changed, each exact
        canonical SHA-256 `43cddeae...`. Sparse 3, duplicate-slot 12, Unicode 806/9/8/2, Rust/Dart/Julia/Lua
        105/105, and dual-ABI Lua 177 pass. Knowledge Map 671/4,990, mdBook, four doctrines, and whitespace pass;
        canonical CI passes Rust semantic admission 79.65s, primary 66x2, and Phase 0 1,031/1,031 in 648s, exit 0.

      #### Acceptance Checklist

      - [x] **REPRODUCE / ISSUE** — Generator diff plus `LinkedSpec::Get` returns null for both governed capture
        fixtures; descriptor/emitted source/high trace show three structural slots but a two-iteration action loop.
      - [x] **ROOT CAUSE (WHY + WHERE)** — `perl/LinkedSpec/HandlerVariantEmitter.pm` drives consuming AND execution
        from compact action dependency count/indices, skipping the un-actioned middle regex after the cursor-policy
        migration; sparse action slots were absent from the duplicate-slot admission matrix.
      - [x] **FIX** — Preserve exact compiled slot identity while executing every ordered structural slot and only
        dispatching code on authored action slots; do not revert family-derived consume semantics.
      - [x] **ADDRESSED (verified)** — Live/emitted capture fixtures recover exact governed JSON, duplicate-slot
        roles stay exact, and complete regeneration leaves no changed expected output outside intended fixtures.
      - [x] **NO REGRESSION** — Focused Perl, oracle corpus, affected backend corpus routes, and canonical CI pass.
      - [x] **LOCKSTEP** — Book/live docs, Knowledge Map, task/memory state, cleanup, and commit are complete.

    - ID: `FUTURE-PARITY-BACKLOG.10.5.0.1.2.1`
      Status: `done` (2026-07-22)
      Goal: Reject Unicode-label prefix truncation and compose the five-runtime current-grammar closeout.
      Depends on: `.10.5.0.1.2.0`
      Acceptance: Add exact physical-line boundaries for self-hosted rule headers and bare action/blind references,
        execute all positive/negative/distinct/no-prefix-truncation contract cases through current `specs/spec.spec`
        on Perl/Rust/Dart/Julia/Lua, pass refreshed four-fixture and complete corpus routes, close `.10.5.0.1.2` and
        `.10.5.0.1`, synchronize all durable/public state, and commit cleanly.
      Verification: Activated task-tree-first from clean `fef93b5a` at ahead 285. Direct `LinkedSpec::Get` RED
        showed invalid headers producing suffix `Rule` nodes and invalid bare action/blind references producing
        prefix `Top` nodes; newline remained a valid two-token separator. Canonical grammar now anchors the three
        affected patterns to physical lines without changing same-line rule bodies or Unicode label identity. The
        independent checker locks grammar topology, exact canonical/corpus bytes, manifest fixture coverage, matrix
        routing, CI registration, and the Rust absent-capture repair. Focused Perl and exact 5x2x1 pass; Rust,
        Dart, Julia, and Lua corpus routes pass 105/105; Dart current-source tests pass 3; complete Rust passes
        runtime 148, integration 197, generated-source/semantic suites and primary 66x2; dual-ABI Lua passes 177
        plus primary 66x2. Canonical CI passes all four doctrines, Unicode 806/9/8/2, semantic 6/20/73, Rust
        admission, primary 66x2, Phase 0 1,031, stable 5x2x66, and focused 5x2x1, exit 0. Knowledge Map 672/4,998,
        mdBook, whitespace, and generated-artifact cleanup pass.

      #### Acceptance Checklist

      - [x] **TOOLBOX RED / ROOT CAUSE** — Execute canonical grammar through LinkedSpec's probes and preserve exact
        failing AST evidence for header suffix scans and bare-reference prefix acceptance before changing grammar.
      - [x] **PHYSICAL TOKEN BOUNDARIES** — Anchor headers and bare action/blind references to their source lines,
        reject extra-colon and trailing invalid suffixes, and preserve CRLF/LF plus valid newline token splitting.
      - [x] **OMISSION-SENSITIVE FIVE-RUNTIME PROOF** — Execute every positive/negative/distinct fixture and all
        three no-prefix surfaces through current canonical grammar on five backends under both option environments.
      - [x] **RUST ABSENCE PARITY** — Return `Undef`/JSON null for an absent compacted `entry_group` index and lock
        both absent and present cases without changing capture compaction.
      - [x] **CORPUS / SIGNOFF / PARENT CLOSE** — Keep four canonical corpus inputs fresh, pass complete affected
        and canonical gates, synchronize all durable/public layers, clean artifacts, and close `.2` plus `.1`.

- ID: `FUTURE-PARITY-BACKLOG.10.5.0.2`
  Status: `done` (2026-07-22)
  Goal: Implement exact pinned Unicode rule-label identity across every Dart route.
  Depends on: `.10.5.0.1`
  Acceptance: Generate one Dart Unicode 17 `XID_Continue` classifier from the neutral contract and consume it for
    declarations plus action/blind/bare references. Validate parsed and externally constructed AST labels; preserve
    exact case/normalization-sensitive identity through selectors, compiled maps, descriptors, generated plans/
    emitted source, diagnostics, traces, strict loaders, and primary routes. Reject invalid labels and partial
    prefixes deterministically without broadening function/helper/lifecycle/fluent/mark identifiers or promoting
    semantic introspection.
  Verification: Children `.0-.4` generate and independently lock the exact 806-range Dart classifier/scanner,
    route every native and external-AST declaration/action/blind/bare label, preserve all 9 positive labels and 2
    distinct pairs across every compiled/generated/reconstructed/emitted/selector/diagnostic/trace/loader/command
    identity route, and reject all 8 negatives without broadening adjacent identifier grammars. Final composed
    signoff passes Dart format on 69 files with no change, fatal analysis, package 296, primary 66x2, corpus
    105/105, Unicode 806/9/8/2, semantic 6/20/73, generated-source 10-family/80-0-0, all four doctrines, canonical
    Rust admission 1/1 in 77.74 seconds, canonical primary 66x2, and Phase 0 1,031/1,031 in 622 seconds. Semantic
    rollout/admission remain exactly 3/9 and 2/6; no production behavior changes in composed closeout `.4`.

  #### Acceptance Checklist

  - [x] **GENERATED CLASSIFIER** — Extend deterministic generation/checking with one Dart range table, binary-search
    scalar classifier, complete-label validator, and longest-valid-prefix scanner; never consult host `RegExp \w`.
  - [x] **PARSE / VALIDATE ALL ROUTES** — Use the scanner for header/action/blind/bare syntax and the validator for
    declarations and every target from parsed, deserialized, or programmatic ASTs; prohibit silent prefix parsing.
  - [x] **EXACT IDENTITY** — Preserve all positive labels plus precomposed/decomposed/case distinctions through
    validation, compilation, descriptor, generated plan/source/reconstruction, explicit selector, diagnostics,
    trace, loaded source, and primary command routes.
  - [x] **NEGATIVE / GRAMMAR ISOLATION** — Reject every negative fixture at a stable parser/validation boundary and
    prove unrelated function/helper/lifecycle/fluent/mark identifier grammars are unchanged.
  - [x] **NO FALSE PROMOTION / SIGNOFF** — Complete Dart, Unicode/semantic checker, canonical, mdBook/KM/docs, and
    cleanup pass while semantic rollout/admission remain 3/9 and 2/6.

  Children:

  - ID: `FUTURE-PARITY-BACKLOG.10.5.0.2.0`
    Status: `done` (2026-07-22)
    Goal: Generate and independently lock the Dart Unicode 17 rule-label classifier and scanner primitives.
    Depends on: `.10.5.0.1`
    Acceptance: Extend the existing pinned-data generator with one deterministic Dart artifact containing the exact
      806 maximally merged ranges, binary-search scalar classification, complete-label validation, and a
      code-point-safe longest-valid-prefix scanner. Add focused fixture/boundary tests and independent regeneration/
      topology checks without routing the parser or changing any identifier grammar yet.
    Verification: Activated task-tree-first from clean `d17c1edf`. Deterministic regeneration emits a formatter-
      stable Dart file; the independent checker byte-compares it, extracts all 806 endpoint pairs, and locks binary
      search, rune iteration, and supplementary-width accumulation. Three focused tests pass every range endpoint,
      neutral 9/8/2 fixture, invalid scalar boundary, and prefix/remainder case. Complete Dart passes format, fatal
      analysis, package 282, primary 66x2, and corpus 105/105. Knowledge Map 672/5,000, mdBook, memory/task
      metadata, four doctrines, and whitespace pass. Canonical CI passes semantic 6/20/73, Rust admission 76.93s,
      primary 66x2, and Phase 0 1,031/1,031 in 620s, exit 0; no parser/validator file changed.

    #### Acceptance Checklist

    - [x] **GENERATE EXACTLY** — Emit one deterministic internal Dart artifact from the existing pinned neutral
      ranges without adding a host Unicode/property dependency or changing the neutral contract.
    - [x] **CLASSIFY / VALIDATE / SCAN** — Provide binary-search scalar membership, nonempty complete-label
      validation, and longest-valid-prefix scanning with exact one/two UTF-16 code-unit accounting.
    - [x] **INDEPENDENT PROOF** — Regenerate into temporary storage, separately compare all 806 endpoints and
      algorithm markers, and test every range boundary plus all positive/negative/distinct fixtures.
    - [x] **NO EARLY CONSUMPTION** — Keep `spec_parser.dart` and `spec_validator.dart` unchanged; parsing,
      external-AST validation, and unrelated identifier grammars remain owned by `.10.5.0.2.1`.
    - [x] **SIGNOFF / LOCKSTEP** — Pass canonical CI, synchronize task/live/roadmap/memory/book/Knowledge Map,
      clean generated artifacts, and commit before activating `.10.5.0.2.1`.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.0.2.1`
    Status: `done` (2026-07-22)
    Goal: Route Dart rule headers and action/blind/bare targets through the generated scanner and validator.
    Depends on: `.10.5.0.2.0`
    Acceptance: Replace host-`\\w` rule-label parsing at all declaration/reference sites, reject partial prefixes,
      and validate labels plus targets from parsed, deserialized, and programmatic ASTs at stable parser/validation
      boundaries without changing unrelated identifier grammars.
    Verification: Generated scanner drives header discovery/body termination plus action/blind/bare targets; one
      complete-label validator covers declarations and all target AST variants. Focused native/classifier/parser/
      validator/self-hosted proof passes 33/33 and the dedicated route suite passes 5/5 including exact positive/
      distinct identity, invalid suffix non-truncation, and reconstructed/programmatic failures. Complete Dart
      passes format, fatal analysis, package 287, primary 66x2, and corpus 105/105. Unicode 806/9/8/2, semantic
      6/20/73, Knowledge Map 672/5,000, mdBook, memory/task metadata, four doctrines, and whitespace pass.
      Canonical CI passes Rust admission in 86.93 seconds, primary 66x2, and Phase 0 1,031/1,031 in 627 seconds.

    #### Acceptance Checklist

    - [x] **ONE GENERATED SCANNER** — Route rule-header parsing/body termination plus action, blind, and bare target
      parsing through `takeRuleLabelPrefix`; remove every former host-`\\w` rule-label regex.
    - [x] **WHOLE-TOKEN FAILURE** — Require legal edge continuations and retain malformed edge-looking syntax as
      raw input so invalid Unicode-label suffixes cannot silently become valid prefix targets.
    - [x] **EXTERNAL AST TRUST BOUNDARY** — Validate every declaration and action/blind/bare target from parsed,
      JSON-reconstructed, and programmatic ASTs with one stable portable `invalid_rule_label` diagnostic.
    - [x] **FOCUSED / COMPLETE DART** — Lock exact positive/distinct identities, declaration/edge forms, invalid
      suffixes, every target role, and reconstructed/programmatic rejection; pass complete Dart and corpus gates.
    - [x] **SIGNOFF / HANDOFF** — Synchronize checker, roadmap/live docs, mdBook, Knowledge Map, memory, canonical
      gate, and generated cleanup; commit from a clean boundary before activating downstream route leaf `.2`.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.0.2.2`
    Status: `done` (2026-07-22)
    Goal: Prove exact Dart Unicode rule-label identity across every downstream route.
    Depends on: `.10.5.0.2.1`
    Acceptance: Preserve every positive and distinct label through compiled maps, descriptors, generated plans,
      emitted/reconstructed source, explicit selectors, diagnostics, traces, strict loaders, and primary commands.
    Verification: Contract-driven proof covers all 9 positive labels and 2 distinct pairs through parsed/compiled
      order and maps, JSON/descriptors, generated plans, AST and emitted-payload reconstruction, direct native and
      generated execution, one isolated analyzed emitted caller package, strict loading, inline/file primary
      commands, exact selector diagnostics, and native/generated traces. Focused suite passes 4/4; eight adjacent
      emitter/selector/loader/CLI/trace suites pass 46/46. Complete Dart passes format, fatal analysis, package 291,
      primary 66x2, and corpus 105/105. Production code is unchanged because every downstream route already
      transports exact immutable strings without normalization or folding. Knowledge Map 672/5,002, mdBook,
      memory/task metadata, all four doctrines, and whitespace pass. Canonical CI passes Rust semantic admission
      1/1 in 76.73 seconds, primary 66x2, and Phase 0 1,031/1,031 in 623 seconds, exit 0.

    #### Acceptance Checklist

    - [x] **NEUTRAL FIXTURE BREADTH** — Drive all nine positive labels and both distinct pairs directly from the
      neutral contract; retain exact spelling, scalar sequence, case, and normalization form.
    - [x] **COMPILED / GENERATED IDENTITY** — Prove parsed order, compiled order/maps, JSON, descriptors, generated
      plans, AST reconstruction, and direct generated execution preserve every exact label.
    - [x] **EMITTED PACKAGE IDENTITY** — Extract and reconstruct the strict emitted payload, then analyze and run an
      isolated caller package that selects every label and returns matching metadata, plan, and values.
    - [x] **ROUTED IDENTITY** — Prove strict file loading, inline/file primary commands, explicit native/generated
      selectors, portable diagnostics, and native/generated traces retain exact Unicode identities.
    - [x] **SIGNOFF / HANDOFF** — Pass complete Dart and canonical gates, synchronize public/durable docs and the
      Knowledge Map, clean generated artifacts, and commit before activating negative/isolation leaf `.2.3`.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.0.2.3`
    Status: `done` (2026-07-22)
    Goal: Lock Dart negative-label rejection and unrelated identifier-grammar isolation.
    Depends on: `.10.5.0.2.2`
    Acceptance: Cover every neutral negative fixture and no-prefix surface with deterministic failures, while proving
      function/helper/lifecycle/fluent/mark grammars retain their existing accepted and rejected spellings.
    Verification: All 8 negative fixtures fail every declaration/action/blind/bare role from both programmatic and
      JSON-reconstructed ASTs with exact portable diagnostics. Source declarations and all edge forms cannot
      truncate; `$Top` no-prefix surfaces remain non-edges, primary compilation fails exactly for every invalid
      declaration, colon remains declaration punctuation, and newline remains a two-token boundary. Direct
      isolation proof preserves function/parameter, ActionIR helper/fluent, exact lifecycle, and named-mark
      grammars. Focused suite passes 5/5; ten adjacent suites pass 64/64. Complete Dart passes format, fatal
      analysis, package 296, primary 66x2, and corpus 105/105. Unicode 806/9/8/2, semantic 6/20/73, KM 672/5,004,
      mdBook/four doctrines/diff, canonical Rust admission 1/1 in 77.14 seconds, primary 66x2, and Phase 0
      1,031/1,031 in 623 seconds pass. Production code is unchanged; semantic rollout/admission remain 3/9 and 2/6.

    #### Acceptance Checklist

    - [x] **EVERY NEUTRAL NEGATIVE** — Drive all eight negative fixtures through every declaration and
      action/blind/bare target role from both programmatic and JSON-reconstructed ASTs with the exact portable
      `invalid_rule_label` diagnostic.
    - [x] **SOURCE TOKEN BOUNDARIES** — Prove declaration/action/blind/bare spellings do not truncate to valid
      prefixes or suffixes; retain colon as declaration punctuation and newline as a real two-token separator.
    - [x] **NO-PREFIX / PRIMARY** — Lock header, action, blind, and bare `$Top` no-prefix surfaces and exact primary
      compilation failure for every negative declaration.
    - [x] **UNRELATED GRAMMAR ISOLATION** — Preserve existing accepted/rejected function/parameter, helper,
      lifecycle, fluent-method, and named-mark identifier spellings without importing rule-label membership.
    - [x] **SIGNOFF / HANDOFF** — Pass complete Dart and canonical gates, synchronize public/durable docs and the
      Knowledge Map, clean generated artifacts, and commit before activating composed signoff leaf `.2.4`.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.0.2.4`
    Status: `done` (2026-07-22)
    Goal: Compose Dart Unicode-label signoff and close the prerequisite parent without semantic promotion.
    Depends on: `.10.5.0.2.3`
    Acceptance: Pass complete Dart, Unicode and semantic checkers, primary/corpus/generated/canonical gates, update
      public and durable docs plus cleanup evidence, keep semantic rollout/admission at 3/9 and 2/6, and close `.2`.
    Verification: Composed complete Dart passes format on 69 files with no change, fatal analysis, package 296,
      primary 66x2, and corpus 105/105. Unicode-label 806/9/8/2, semantic-introspection 6/20/73 at unchanged rollout
      3/9 and admission 2/6, generated-source v1/10 families/80-0-0, all four doctrines, and Knowledge Map
      672/5,006 pass.
      Canonical independently passes Rust semantic admission 1/1 in 77.74 seconds, primary 66x2, and Phase 0
      1,031/1,031 in 622 seconds. Parent `.10.5.0.2` closes without production or semantic-ledger change.

    #### Acceptance Checklist

    - [x] **COMPLETE DART** — Re-run Dart format, fatal analysis, all package tests, primary 66x2, and corpus
      105/105 over the composed generated classifier, native routes, identity routes, and negative/isolation proof.
    - [x] **CONTRACT COMPOSITION** — Pass the Unicode-label and semantic-introspection checkers with exact
      806/9/8/2 and 6/20/73 evidence, plus required tracked-file and generated-source topology.
    - [x] **CANONICAL SIGNOFF** — Pass all doctrines and canonical local CI, including Rust semantic admission,
      primary 66x2, and Phase 0 1,031/1,031.
    - [x] **NO FALSE PROMOTION** — Keep semantic rollout/admission at 3/9 and 2/6; do not claim Julia, PUC Lua,
      LuaJIT, recurring, MCP, or public semantic admission from the Dart label prerequisite.
    - [x] **PARENT CLOSEOUT / HANDOFF** — Close `.10.5.0.2`, synchronize roadmap/live docs/mdBook/Knowledge Map,
      clean generated artifacts, and commit before activating semantic source-map leaf `.10.5.1`.

- ID: `FUTURE-PARITY-BACKLOG.10.5.1`
  Status: `done` (2026-07-22)
  Goal: Add the opaque Dart semantic source-map and compiled-or-failed outcome foundation.
  Depends on: `.10.5.0.2`
  Acceptance: Construct once from copied decoded `String` or strict UTF-8 bytes plus caller logical name and source
    ceiling; retain canonical bytes/scalar mapping, staged parsed/validated/compiled-or-failed state, entry
    identity, and shared generated-plan input without execution, implicit path reads, records/query, or host-state
    exposure. Prove malformed UTF-8, Unicode coordinates, graph/privacy/failure fixtures, clone isolation, and
    exact existing diagnostics.
  Children: `.10.5.1.0`, `.10.5.1.1`, `.10.5.1.2`, `.10.5.1.3`

  #### Acceptance Checklist

  - [x] **STRICT COPIED INPUT** — Accept copied decoded `String` or strict UTF-8 bytes plus required logical name,
    source-detail ceiling, and optional exact entry label; reject malformed bytes/options before language parsing.
  - [x] **PRIVATE SOURCE MAP** — Retain canonical bytes and exact zero-based half-open byte / one-based line and
    Unicode-scalar-column spans, ordered lookup, excerpts, digest policy, and mid-scalar boundary rejection.
  - [x] **OPAQUE COMPILED / FAILED AUTHORITY** — Parse, validate, compile, select entry, and retain shared
    generated-plan input once without execution; preserve language failure as clone-safe portable diagnostic state.
  - [x] **CEILING / CLONE / NONINTERFERENCE** — Enforce `none`/`identity`/`span`/`text` disclosure, return fresh
    clone-safe values, deny host paths/AST/IR/compiler objects, and prove caller/source/result mutation isolation.
  - [x] **COMPOSED FOUNDATION SIGNOFF** — Cover graph/privacy/failure plus constructor errors, pass complete Dart,
    semantic checker, canonical, docs/KM/cleanup, and close `.10.5.1` before activating static projection `.10.5.2`.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.1.0`
    Status: `done` (2026-07-22)
    Goal: Freeze the exact Dart source/outcome foundation contract and split implementation by native authority.
    Depends on: `.10.5.0.2.4`
    Acceptance: Retrieve the neutral contract plus admitted Perl/Rust precedents and exact Dart parser/validator/
      compiler/loader/generated-plan/diagnostic authorities; freeze public/private boundaries, tests, dependency
      order, and `.1-.3` children before behavior code.
    Verification: The neutral source/privacy contract and ADR `0049`, admitted Perl/Rust source foundations, and
      exact Dart seams agree on one opaque native owner. Dart must construct from copied text or strict bytes and a
      caller logical name, use `parseSpecWithStagedUserFunctionDefinitions`, `validateSpec` /
      `SpecPortableDiagnostic`, `compileSpec`, `CompiledSpec.resolveEntryRule`, and `buildGeneratedRulePlan`, and
      retain failures as outcomes without invoking `LinkedSpecRuntimeEngine`. `LoadedSpec` is explicitly excluded
      because it binds decoded source to a resolved host path. Implementation is dependency-split into strict
      input/private mapping `.1`, staged compiled-or-failed authority `.2`, and composed omission-safe closeout
      `.3`; no production behavior, semantic record/query surface, runtime observation, or governance ledger moves.
      Semantic checker remains 6/20/73 at rollout 3/9 and admission 2/6. Memory architecture at its 60-line cap,
      all four doctrines, Knowledge Map 672/5,007, mdBook, and diff hygiene pass; the generated 12 MiB book is
      removed before commit.

    #### Acceptance Checklist

    - [x] **RETRIEVE FIRST** — Read the Dart authority card, neutral model, ADR boundary, and complete admitted
      Perl/Rust source-map/outcome precedents before inspecting implementation seams.
    - [x] **BOUNDARY** — Keep one opaque native owner with no path constructor, execution, semantic records/query,
      runtime observation, AST/IR serialization, or descriptor wire-model dependency.
    - [x] **SPLIT** — Separate strict copied input/source mapping `.1`, staged compiled-or-failed authority `.2`,
      and composed omission-safe proof/parent close `.3` in dependency order.
    - [x] **LOCKSTEP / HANDOFF** — Synchronize task index/live memory/change notes, pass doctrines/KM/diff, clean
      artifacts, and commit before activating implementation child `.10.5.1.1`.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.1.1`
    Status: `done` (2026-07-22)
    Goal: Implement strict copied Dart semantic input policy and the private Unicode source map.
    Depends on: `.10.5.1.0`
    Acceptance: Add idiomatic immutable options/errors and one private canonical byte/scalar map for decoded text or
      strict bytes; enforce logical-name/entry-label/source-ceiling policy and exact identity/span/excerpt/lookup
      disclosure without parsing, execution, path reads, AST/IR exposure, or semantic records.
    Verification: `SemanticIndex.fromSource` / `fromUtf8` now copy strict scalar text or validated bytes and export
      immutable typed options, errors, source identity, and spans around one private canonical byte/scalar map.
      Six focused tests lock standard empty/`abc` SHA-256 vectors plus the 128-byte graph digest, decoded/byte
      convergence, supplementary and CRLF positions, four duplicate `/a/` occurrences, both mid-scalar boundary
      failures, range/needle errors, all four ceilings, detached immutable values, caller mutation, invalid bytes/
      UTF-8/UTF-16/options, exact Unicode selector validation, debug redaction, and source-only non-parsing.
      A first adjacent run correctly failed four isolated emitted-caller roles because a proposed direct `crypto`
      dependency was unavailable in their deliberately fresh offline caches. The production package remains
      dependency-free; package-internal SHA-256 restores all 39 adjacent tests. Complete Dart passes format 72/0,
      fatal analysis, package 302, primary 66x2, and corpus 105/105. Semantic 6/20/73 at rollout 3/9 and admission
      2/6, Unicode 806/9/8/2, generated-source 10 families/80-0-0, and Knowledge Map 673/5,013 pass. Canonical CI
      passes Rust semantic admission 1/1 in 76.39 seconds, primary 66x2, and Phase 0 1,031/1,031 in 622 seconds.

    #### Acceptance Checklist

    - [x] **TYPED SOURCE POLICY** — Export immutable Dart options, source-detail enum, typed errors, source identity,
      and span values with required caller logical name, typed ceiling, and optional exact Unicode entry label.
    - [x] **STRICT COPIED INPUT** — Copy decoded Unicode scalar text or validated 0..255 bytes, reject unpaired UTF-16
      and malformed UTF-8 before language work, retain canonical strict bytes, and compute exact SHA-256 identity.
    - [x] **PRIVATE UNICODE MAP** — Map zero-based half-open UTF-8 bytes and Unicode-scalar ranges to one-based
      line/scalar columns; support exact excerpts and ordered duplicate lookup while rejecting mid-scalar bounds.
    - [x] **CEILING / ISOLATION** — Apply `none`/`identity`/`span`/`text` before values leave, return immutable plain
      values, copy caller bytes, redact debug identity, and expose no path, source buffer, parser, AST, compiler,
      descriptor, query, runtime, trace, or diagnostic-sink authority.
    - [x] **OFFLINE CALLER INTEGRITY** — Keep the production Dart package dependency-free and prove isolated emitted
      callers can resolve it from a fresh offline package cache while exact SHA-256 source identities remain locked.
    - [x] **SIGNOFF / HANDOFF** — Pass focused/adjacent/complete Dart plus semantic/canonical/doctrine/docs/KM/diff
      gates, clean generated artifacts, and commit before activating compiled-or-failed child `.10.5.1.2`.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.1.2`
    Status: `done` (2026-07-22)
    Goal: Add opaque staged compiled-or-failed Dart authority and generated-plan input.
    Depends on: `.10.5.1.1`
    Acceptance: Construct once through existing parse/validate/compile/entry-selection owners, retain clone-safe
      snapshot/source/authority/diagnostic/entry/plan foundation values, preserve language failures as outcomes,
      and execute no target parser, action, lifecycle, trace, diagnostic sink, or runtime observer.
    Verification: `SemanticIndex` now invokes `parseSpecWithStagedUserFunctionDefinitions` once, `validateSpec`
      once, and `compileSpec(..., validateSource: false)` once, then resolves the caller selector/default through
      `CompiledSpec.resolveEntryRule` and retains an immutable copy of `buildGeneratedRulePlan`. Public plain
      foundation values expose snapshot state, presence-only private authority, detached diagnostics, entry
      identity, and the generated-v2 contract/format/ordered label-family plan without exposing `SpecFile`,
      `CompiledSpec`, ActionIR, source buffers, paths, descriptors, records, queries, or runtime objects. Native
      portable diagnostics remain exact: `failed.spec` retains `bare_edge_target_undefined` / `normalize_edges`
      with Dart fields `rule_label` and `target`; later static projection owns backend-neutral normalization.
      Parse, non-portable validation, compile, and unknown-entry failures become deterministic failed-compilation
      outcomes while constructor policy/decode failures still throw `SemanticIndexError`. One topology assertion
      locks the single pipeline calls and forbids loader, target runtime, trace/diagnostic/observation sinks,
      generated emission/execution, and path IO. Focused source+outcome proof passes 12/12; 13 adjacent suites pass
      71/71. Complete Dart passes format 73/0, fatal analysis, package 308, primary 66x2, and corpus 105/105.
      Semantic 6/20/73 at rollout 3/9 and admission 2/6, Unicode 806/9/8/2, and generated-source 10 families/80-0-0
      pass. Canonical CI passes Rust semantic admission 1/1 in 77.24 seconds, primary 66x2, and Phase 0
      1,031/1,031 in 632 seconds, exit 0.

    #### Acceptance Checklist

    - [x] **RETRIEVE / PIPELINE AUTHORITY** — Re-read the Dart semantic authority card and exact staged parser,
      validator/portable diagnostic, compiler, entry selector, and generated-plan owners before behavior changes.
    - [x] **OPAQUE OUTCOME API** — Add immutable success/failure status plus clone-safe snapshot, authority,
      diagnostic, selected-entry, and generated-plan identity values without exporting AST/IR/compiler objects.
    - [x] **CONSTRUCT ONCE / EXACT FAILURE** — Parse, validate, and compile once during construction; preserve
      existing staged parse, validation, compile, and entry-selection failures as deterministic typed outcomes.
    - [x] **ENTRY / PLAN FOUNDATION** — Resolve the caller selector or existing default exactly and retain one
      shared generated-v2 plan input without generating source or executing the target spec.
    - [x] **NONEXECUTION / ISOLATION** — Prove no target parser, action, lifecycle, trace, diagnostic sink, runtime
      observer, path read, source disclosure, record projection, or query is invoked; returned values are detached.
    - [x] **SIGNOFF / HANDOFF** — Pass focused/adjacent/complete Dart plus semantic/canonical/doctrine/docs/KM/diff
      gates, clean generated artifacts, and commit before activating composed closeout child `.10.5.1.3`.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.1.3`
    Status: `done` (2026-07-22)
    Goal: Compose exact Dart semantic foundation proof and close `.10.5.1`.
    Depends on: `.10.5.1.2`
    Acceptance: Prove graph/privacy/failure, decoded/byte convergence, malformed UTF-8/options, Unicode and duplicate
      occurrence coordinates, source ceilings, entry selection, clone/caller mutation isolation, host-state denial,
      complete Dart/canonical no-regression, public/durable sync, cleanup, and clean parent close before `.10.5.2`.
    Children: `.10.5.1.3.0`
    Verification: The two foundation suites compose graph/privacy/failure, decoded/byte convergence, strict input
      and option failures, supplementary/CRLF coordinates, four duplicate lookups, all source ceilings, exact
      default/explicit/missing entries, detached immutable outputs, caller-byte mutation, native diagnostics, and
      the shared generated-v2 plan in 12/12 tests. A negative topology scan denies path IO, environment/time/random
      capture, target/generated execution, runtime/trace/diagnostic/observation sinks, records, and query. The
      complete Dart gate passes format over 73 files with no changes, fatal analysis, package 308, primary 66x2,
      and corpus 105/105. Unicode is 806/9/8/2; semantic governance is 6/20/73 at unchanged rollout 3/9 and native
      admission 2/6; generated source remains v1 / ten families / 80-0-0. Scanner repair child `.1.3.0` closes the
      pre-staging untracked-file blind spot and public aggregate-selector admission passes 59/27/0. Canonical CI
      passes Rust semantic admission 1/1 in 79.59 seconds, primary 66x2, and Phase 0 1,031/1,031 in 642 seconds.
      The Knowledge Map is 673/5,021; mdBook, doctrines, diff hygiene, and generated cleanup pass. Parent `.10.5.1`
      closes without semantic promotion or another production change; static projection `.10.5.2` is next.

    #### Acceptance Checklist

    - [x] **COMPOSE EXISTING PROOF** — Drive the source-map and compilation-foundation suites together across
      graph/privacy/failure, decoded/byte convergence, Unicode coordinates, duplicate lookup, source ceilings,
      exact entry selection, constructor failures, and language-failure outcomes without adding new authority.
    - [x] **CLONE / CALLER ISOLATION** — Confirm copied input plus fresh immutable/detached source, snapshot,
      authority, diagnostic, entry, and plan values cannot be mutated into retained state.
    - [x] **HOST-STATE DENIAL** — Mechanically deny implicit path IO, environment/time/random capture, target or
      generated execution, trace/diagnostic/observation sinks, AST/IR/compiler exposure, records, and query.
    - [x] **COMPLETE DART / NEUTRAL** — Pass format/fatal analysis, all Dart package tests, primary 66x2, corpus
      105/105, Unicode 806/9/8/2, semantic 6/20/73, and generated-source ten-family/80-0-0 proof.
    - [x] **CANONICAL / PUBLIC LOCKSTEP** — Pass canonical local CI, all doctrines, Knowledge Map, mdBook, and diff
      hygiene while keeping semantic rollout 3/9 and native admission 2/6.
    - [x] **PARENT CLOSE / CLEAN HANDOFF** — Close `.10.5.1`, synchronize roadmap/live memory/change notes, clean
      generated artifacts, and commit before activating static projection `.10.5.2`.

    - ID: `FUTURE-PARITY-BACKLOG.10.5.1.3.0`
      Status: `done` (2026-07-22)
      Goal: Close the aggregate-selector scan's pre-staging blind spot and migrate the semantic compile-failure
        fixture to canonical invalid-source authority.
      Depends on: `.10.5.1.2`
      Finding: The `.10.5.1.2` compile-failure test embedded retired `array(identifier)` source. Its pre-staging
        canonical run passed because `tools/check_executable_aggregate_selector_sources.py` enumerated only
        `git ls-files`, which excludes a new untracked test. The first post-commit canonical closeout correctly
        rejected the now-tracked line. This is a scanner-discovery defect as well as a fixture defect.
      Acceptance: Enumerate tracked plus nonignored untracked files, self-prove that an untracked executable-source
        positive is discovered, source the compile-failure case from the canonical neutral invalid fixture instead
        of duplicating retired syntax, and pass the focused Dart test plus aggregate-selector/public gates before
        resuming parent `.10.5.1.3`.
      Verification: `tools/check_executable_aggregate_selector_sources.py` now enumerates
        `git ls-files --cached --others --exclude-standard`, creates one unique nonignored untracked Dart source,
        proves that the candidate scan discovers and rejects it, and removes it in `finally`. The semantic
        compile-failure test loads `array_read` from `capability_conformance/uniform_binding_contract.json` rather
        than embedding retired executable source. Focused semantic compilation passes 6/6. The source scan reports
        zero positives / 19 classified occurrences plus the passing discovery self-test; composed retirement is
        five backends / six invalid selectors / eight retained classes / zero runtime compatibility; public
        admission is 59 files / 27 classified / zero current examples. Knowledge Map is 673/5,020. Canonical CI
        passes Rust semantic admission 1/1 in 79.59 seconds, primary 66x2, and Phase 0 1,031/1,031 in 642 seconds.
        Production behavior and semantic rollout/admission remain unchanged.

      #### Acceptance Checklist

      - [x] **DISCOVERY FIX** — Scan `git ls-files --cached --others --exclude-standard` so a new untracked source
        cannot bypass the executable aggregate-selector gate before staging.
      - [x] **SELF-PROOF** — Exercise one temporary nonignored untracked source and require the scanner to discover
        and reject it while guaranteeing cleanup.
      - [x] **CANONICAL FIXTURE** — Load the compiler-failure selector from
        `capability_conformance/uniform_binding_contract.json`; do not embed a second executable retired spelling.
      - [x] **FOCUSED REGRESSION** — Pass the semantic compilation suite, executable-source scanner, aggregate-
        selector retirement checker, and public surface checker with exact zero-positive evidence.
      - [x] **DURABLE HANDOFF** — Record the discovery rule in the Knowledge Map and task verification, then return
        to `.10.5.1.3` without promoting semantic rollout/admission or changing production behavior.

- ID: `FUTURE-PARITY-BACKLOG.10.5.2`
  Status: `done` (2026-07-22)
  Goal: Project exact Dart static graph, privacy, failure, and runtime-static semantics.
  Depends on: `.10.5.1`
  Acceptance: Correlate immutable source evidence with typed `CompiledSpec` entry/family/cursor/repetition/slot/
    edge/lifecycle authority and normalize the existing failed-spec diagnostic deliberately. Retain clone-safe
    plain v1 data that deep-equals graph, both privacy ceilings, failed, and runtime-static targets without exposing
    query, AST JSON, descriptor layout, compiled regexes, host paths, or execution.
  Children: `.10.5.2.0`, `.10.5.2.1`, `.10.5.2.2`, `.10.5.2.3`

  #### Acceptance Checklist

  - [x] **RETRIEVE / SPLIT FIRST** — Re-read the neutral static targets, ADR boundary, admitted Perl/Rust static
    projections, and exact private Dart source/compiler authorities; split the work before production if one leaf
    cannot remain omission-safe. The dependency-ordered `.10.5.2.0-.3` children now own audit, compiled graph,
    remaining exact targets, and composed closeout respectively.
  - [x] **NORMALIZED STATIC MODEL** — Add detached immutable v1 records/relations/shapes/evidence for entry, rule
    family/cursor/repetition, authored slots, action/blind/bare edges, lifecycle, source identity/spans, and the
    deliberate backend-neutral failed-spec diagnostic.
  - [x] **EXACT FIVE TARGETS** — Deep-equal graph, privacy text, privacy identity, failed, and runtime-static neutral
    targets with stable ids/order/absence semantics and no descriptor or AST/IR serialization dependency.
  - [x] **PRIVACY / ISOLATION** — Apply construction-time source ceilings before projection, return fresh clone-safe
    plain values, and prove caller/result mutation cannot alter retained source/compiler authority.
  - [x] **NONEXECUTION / LAYERING** — Expose no query yet and invoke no target/generated execution, path IO,
    environment/time/random capture, trace, diagnostic sink, or runtime semantic observer.
  - [x] **SIGNOFF / HANDOFF** — Pass focused and complete Dart, semantic/Unicode/generated/public/canonical gates,
    synchronize roadmap/live docs/mdBook/Knowledge Map, clean artifacts, and commit before `.10.5.3`.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.2.0`
    Status: `done` (2026-07-22)
    Goal: Freeze the exact Dart static-projection authority map and omission-safe implementation split.
    Depends on: `.10.5.1`
    Acceptance: Reconcile all five neutral construction targets with ADR `0049`, the admitted Perl/Rust private
      projections, and Dart's accepted source, parsed, compiled, entry, plan, and portable-diagnostic authorities.
      Record exact normalization, source-correlation, privacy, canonical-order, and forbidden-input boundaries;
      create bounded dependency-ordered implementation/closeout children; change no production behavior,
      semantic rollout, backend admission, query, trace, or runtime surface.
    Verification: Five exact construction variants are reconciled: graph, privacy at text, privacy at identity,
      failed compilation, and runtime-static. Parsed `SpecFile` owns authored order/member intent; typed
      `CompiledSpec` owns compiled order, mode, structural slot, resolved edge, action-shape, and lifecycle facts;
      selected-entry identity owns the effective root; accepted source plus its UTF-8/scalar map owns ranges; and
      native `SpecPortableDiagnostic` owns failure input. The projection must correlate grouped body lines without
      serializing AST/descriptor JSON and deliberately normalize `bare_edge_target_undefined` / `normalize_edges`
      only at the static layer. Implementation is split into compiled graph `.1`, privacy/failure/runtime-static
      plus isolation `.2`, and composed closeout `.3`. Foundation 12/12, semantic 6/20/73 at unchanged rollout 3/9
      and admission 2/6, Knowledge Map 673/5,025, mdBook, all four doctrines, memory architecture, and diff hygiene
      pass. No production behavior, query, trace/runtime, rollout, or admission changes.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.2.1`
    Status: `done` (2026-07-22)
    Goal: Project the exact Dart compiled static graph through detached v1 data.
    Depends on: `.10.5.2.0`
    Acceptance: Add private immutable source references, records, relations, closed shapes, stable UTF-8 ids, and
      canonical ordering from accepted source plus typed parsed/compiled/entry authorities. Deep-equal the graph
      target including entry evidence, duplicate authored regex slots, indexed edges, lifecycle, spans, shapes,
      and source identity without descriptor/AST serialization, query, execution, trace, paths, or host state.
    Verification: `SemanticIndex` now retains a private immutable compiled static projection built from accepted
      source, the UTF-16-to-scalar-to-UTF-8 map, typed parsed/compiled authorities, and selected-entry identity.
      Exact graph proof deep-equals the neutral snapshot after source-reference materialization, including stable
      UTF-8 ids, canonical record/relation order, duplicate slots, indexed edges, lifecycle occurrence shapes,
      entry decision/explanation, exact spans/excerpts/digest, and detached mutation safety. The package-internal
      oracle seam is omitted from the public umbrella; topology denies AST/descriptor serialization, generated
      emission/execution, target runtime, trace, diagnostics, and semantic observation. Focused proof passes 3/3;
      complete Dart passes format over 75 files with zero changes, fatal analysis, package 311, primary 66x2, and
      corpus 105/105. Unicode remains 806/9/8/2; semantic governance remains 6/20/73 at rollout 3/9 and admission
      2/6; generated source remains v1 / ten families / 80-0-0; selector admission remains 59/27/0 with untracked
      self-proof. Canonical CI passes Rust semantic admission 1/1 in 80.34 seconds, primary 66x2, and Phase 0
      1,031/1,031 in 631 seconds. Knowledge Map is 673/5,027. No query, runtime observation, rollout, or admission
      is exposed or promoted.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.2.2`
    Status: `done` (2026-07-22)
    Goal: Complete Dart privacy, failed-compilation, runtime-static, and isolation projection parity.
    Depends on: `.10.5.2.1`
    Acceptance: Deep-equal privacy at text and identity construction ceilings, deliberately normalize Dart's
      `bare_edge_target_undefined` / `normalize_edges` failure to the neutral diagnostic/decision/explanation, and
      deep-equal the runtime fixture with execution/event records absent. Prove fresh clone-safe plain results,
      construction-ceiling integrity, stable absence semantics, and denial of AST/IR, descriptor, regex object,
      generated implementation, path, executor, trace, diagnostic-sink, and runtime-observer leakage.
    Verification: The private projector now handles failed snapshots as well as successful compiled snapshots.
      Privacy at `text` and `identity` deep-equals both neutral targets; the foundation retains Dart's exact native
      `bare_edge_target_undefined` / `normalize_edges` diagnostic while the projection alone emits
      `unknown_rule_reference` / `compile` with neutral ids, fields, source, decision, and explanation. The runtime
      fixture deep-equals its static half with `has_execution: false` and no execution/event records or relations.
      Fresh detached JSON/plain-value proof denies caller mutation, public export, host objects, AST/ActionIR,
      descriptor/regex state, generated execution, paths, environment/time/random, trace, diagnostic sinks, and
      runtime observers; repeated lifecycle occurrences remain distinct. Focused exact proof passes 6/6; complete
      Dart passes format over 75 files with zero changes, fatal analysis, package 314, primary 66x2, and corpus
      105/105. Unicode remains 806/9/8/2; semantic governance remains 6/20/73 at rollout 3/9 and admission 2/6;
      generated source remains v1 / ten families / 80-0-0; selector admission remains 59/27/0 with untracked
      self-proof. Canonical CI passes Rust semantic admission 1/1 in 79.42 seconds, primary 66x2, and Phase 0
      1,031/1,031 in 670 seconds. Knowledge Map is 673/5,031. No public query, runtime observation, rollout, or
      admission changes.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.2.3`
    Status: `done` (2026-07-22)
    Goal: Compose static-projection signoff and close the Dart static parent.
    Depends on: `.10.5.2.2`
    Acceptance: Re-run the exact five-target/isolation proof plus complete Dart package, primary/corpus/generated,
      semantic/Unicode/public/canonical gates; synchronize roadmap/live docs/mdBook/Knowledge Map, clean generated
      artifacts, and close `.10.5.2` without promoting rollout/admission or exposing query/runtime behavior.
    Verification: The six-test static suite composes all five exact construction targets plus lifecycle-occurrence
      isolation on the final repair bytes. Complete Dart remains format 75/0, fatal analysis, package 314, primary
      66x2, and corpus 105/105. Semantic governance remains 6/20/73 at rollout 3/9 and native admission 2/6;
      Unicode remains 806/9/8/2; generated source remains v1/10/80-0-0. Public proof passes concurrency 3/3,
      executable 0/19, retirement 5/6/8/0, capability 80/0/0, and surface 59/27/0. Canonical CI on the exact final
      code passes Rust semantic admission 1/1 in 77.49 seconds, primary 66x2, and Phase 0 1,031/1,031 in 620
      seconds. The book, roadmaps, live docs, task/index, Knowledge Map, doctrines, memory, diff, and artifact
      cleanup agree at 674 facts / 5,037 question keys. No public Dart query, execution/observation, rollout, or
      admission surface changes.
    Children: `.10.5.2.3.0`

    - ID: `FUTURE-PARITY-BACKLOG.10.5.2.3.0`
      Status: `done` (2026-07-22)
      Goal: Make the untracked aggregate-selector discovery self-test safe under concurrent repository gates.
      Depends on: `.10.5.2.2`
      Acceptance: Reproduce and root-cause the scanner/retirement/public-wrapper plus Dart-formatter race; hold a
        repository-local cross-process lock across probe creation, discovery, removal, and the final candidate
        scan; keep the positive probe outside the Dart package so formatting cannot enumerate a disappearing file;
        add an enforced concurrent-invocation proof; guarantee cleanup; pass the exact parallel reproduction,
        selector/public governance, complete Dart, canonical CI, and durable Knowledge Map/book/live-doc sync before
        returning to `.10.5.2.3`. Do not weaken tracked/untracked discovery or selector rejection.
      Verification: Exact parallel closeout reproduced the race: direct, retirement, and public scanner processes
        created unique positive probes under `dart/test` while Dart formatting enumerated that directory; one scan
        rejected another's probe and the formatter opened a path after its owner removed it. The scanner now holds
        one `flock` transaction across probe creation/discovery/rejection/removal and the final candidate scan. Its
        probe moved to the repository root, still visible to cached+nonignored-untracked inventory but outside Dart
        package traversal. Public admission enforces three staggered concurrent scanner processes and zero leftover
        root/legacy probes; no filename is exempted. The exact former four-way topology passes. Complete Dart passes
        format 75/0, fatal analysis, package 314, primary 66x2, and corpus 105/105. Semantic remains 6/20/73 at 3/9
        and 2/6; Unicode is 806/9/8/2; generated source is v1/10/80-0-0; selector/public proof is concurrency 3/3,
        executable 0/19, retirement 5/6/8/0, and public 59/27/0. Canonical CI passes Rust semantic admission 1/1 in
        77.49 seconds, primary 66x2, and Phase 0 1,031/1,031 in 620 seconds. Knowledge Map is 674/5,036. No
        semantic behavior or rollout changes.

- ID: `FUTURE-PARITY-BACKLOG.10.5.3`
  Status: `done` (2026-07-22)
  Goal: Project exact Dart calls, bindings, staged payload/job/result, and generated provenance.
  Depends on: `.10.5.2`
  Acceptance: Compose `UserFunctionRegistry`, typed ActionIR resolution, authored-source correlation, normalized
    function sidecars, and generated-v2 plan identity into the exact 22-record / 25-relation calls target. Lock
    source-preorder calls, conservative shapes, resolution evidence, Unicode spans, staged directions, function-
    shell masking, and denial of AST/ActionIR/generated-source/path leakage; expose no query yet.
  Children: `.10.5.3.0`, `.10.5.3.1`, `.10.5.3.2`, `.10.5.3.3`

  #### Acceptance Checklist

  - [x] **RETRIEVE / SPLIT FIRST** — Compare the neutral 22/25 target and admitted Perl/Rust projections with the
    exact Dart registry, staged sidecars, ActionIR/contracts, static projection, source map, and generated plan;
    split authority/core/completion/closeout before production changes.
  - [x] **TYPED CALL GRAPH** — Project functions, helpers, bindings, source-preorder nested calls, exact resolution
    evidence, conservative shapes, and call-driven rule/edge shapes from typed Dart owners plus authored source.
  - [x] **STAGED / GENERATED PROVENANCE** — Add distinct payload/parse-job/result records and exact relation
    directions plus generated-v2 selected-plan identity without retaining body AST or implementation source.
  - [x] **EXACT 22 / 25 / ISOLATION** — Deep-equal the complete neutral calls target with Unicode/interleaving,
    detached clone, public-omission, and AST/ActionIR/generated-source/path/execution/trace denial proof.
  - [x] **SIGNOFF / HANDOFF** — Pass focused and complete Dart, semantic/Unicode/generated/public/canonical gates,
    synchronize durable surfaces, clean artifacts, and close before query leaf `.10.5.4`.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.3.0`
    Status: `done` (2026-07-22)
    Goal: Freeze the exact Dart calls/staging/generated authority map and omission-safe implementation split.
    Depends on: `.10.5.2`
    Acceptance: Probe the neutral calls fixture through current Dart staged parse, validation, compilation,
      function registry, typed ActionIR/contracts, entry selection, and generated plan; reconcile it with the
      admitted Perl/Rust projectors; record exact ordering/span/normalization/leakage constraints; split bounded
      implementation and closeout children; change no production/query/runtime/rollout/admission behavior.
    Verification: The neutral target is exactly 22 records / 25 relations. Dart retains registry function order,
      exact shell/body source, body payload/job/result sidecars, typed edge ActionIR/contracts, selected entry, and
      generated-v2 plan rows. Native `CompiledSpec.definitionOrder` contains rules only, while registry
      `FunctionDefinition.sourceSpan` / `bodySpan` are line-only; exact authored definition order and shell source
      must therefore locate the exact shell occurrence containing the staged body payload's decoded-scalar span.
      Staged `body_ast` deep-equals a typed `parseActionBlock(bodySource)` result, and compiled edge
      `actionPayload.actionAst` plus contracts retain typed nested calls and resolution. Those ActionIR spans are
      local to normalized body/code text, so the projector must correlate occurrence-safe typed preorder back to
      the complete authored shell/edge range instead of adding local offsets to physical source. Function registry
      resolution precedes helper fallback; shape inference remains bounded to typed literals, current bindings,
      registered returns, and the three governed fixture helpers. The selected generated row is `Top/default` from
      the already-retained v2 plan; no emission is needed. Implementation is split into core typed calls `.1`,
      staged/generated exact completion `.2`, and composed closeout `.3`. The diagnostic probe was removed; no
      production, query, execution, trace, rollout, or admission behavior changed. Focused Dart authority proof
      passes 31/31 across action contracts, function shell, staged registry, source/outcome foundation, and static
      projection. Semantic remains 6/20/73 at rollout 3/9 and admission 2/6; Unicode is 806/9/8/2; generated source
      is v1/10/80-0-0; public selector proof is concurrency 3/3, executable 0/19, retirement 5/6/8/0, capability
      80/0/0, and surface 59/27/0. Knowledge Map is 674/5,042; mdBook, memory architecture, all four doctrines,
      task metadata, diff hygiene, and generated-artifact cleanup pass.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.3.1`
    Status: `done` (2026-07-22)
    Goal: Project Dart functions, helpers, bindings, typed calls, resolution evidence, and exact source shapes.
    Depends on: `.10.5.3.0`
    Acceptance: Extend the private static projection from `UserFunctionRegistry`, typed function/edge ActionIR,
      contract resolution, and immutable source correlation. Merge functions/rules in authored order; emit outer-
      before-inner calls, bindings, reads/writes, user/helper resolution, decisions/explanations, conservative
      return/value shapes, and call-driven edge/rule shapes. Prove exact neutral core subsets, Unicode spans,
      duplicate/interleaved shell occurrence safety, and no public/query/execution/trace/host leakage.
    Verification: The private Dart projector now composes `UserFunctionRegistry`, typed function-body and compiled-
      edge ActionIR, resolved contracts, the immutable source map, and existing static ids into the exact neutral
      18-record / 16-relation non-staged core. Rules and functions merge by authored byte position even though
      `CompiledSpec.definitionOrder` omits function shells. Function and helper declarations, bindings, reads,
      writes, outer-before-inner calls, user/helper resolution evidence, decisions/explanations, conservative
      return/value shapes, and call-driven edge/rule shapes all deep-equal the neutral subset. Occurrence-safe
      source correlation keeps interleaved function shells out of rule scans and maps `trim("é")` to exact UTF-8
      byte and Unicode-scalar evidence. The staged body AST is reparsed and exact-compared only as an internal
      consistency check; no AST/ActionIR, descriptor, compiled regex, path, executor, trace, sink, or observer
      crosses the detached plain-data seam, and the test-only extension remains absent from the public umbrella.
      Focused exact proof passes 3/3; complete Dart passes format 77/0, fatal analysis, package 317, primary 66x2,
      and corpus 105/105. Semantic governance remains 6/20/73 at rollout 3/9 and native admission 2/6; Unicode is
      806/9/8/2; generated source is v1/10/80-0-0; public proof is concurrency 3/3, executable 0/19, retirement
      5/6/8/0, capability 80/0/0, and surface 59/27/0. Canonical CI passes Rust semantic admission 1/1 in 77.26
      seconds, primary 66x2, and Phase 0 1,031/1,031 in 627 seconds. The known mutable-marker coupling removed
      repeated-action closeout and handoff anchors in prior docs; this slice restored both true facts under existing
      repair owner `.22` and the exact governance checker passes. Knowledge Map is 674 facts / 5,048 question keys.
      No public query, execution/observation, trace, staged/generated record, rollout, or admission surface changes.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.3.2`
    Status: `done` (2026-07-22)
    Goal: Complete Dart staged and generated provenance with exact 22-record / 25-relation parity.
    Depends on: `.10.5.3.1`
    Acceptance: Add distinct function body payload/parse-job/result records with exact contains/consumes/produces/
      lowered-from/staged-by directions and selected generated-v2 handler-plan provenance. Deep-equal the complete
      calls target, prove fresh detached clones plus AST/ActionIR/body/generated-source/path denial, and retain no
      query or runtime observation surface.
    Verification: The private Dart projector now completes the neutral calls target at exactly 22 records / 25
      relations. Each registered function's existing staged sidecars are policy-checked and projected as three
      distinct plain-data `staged_artifact` records: decoded body payload, native ActionIR parse job, and successful
      ActionIR result. Exact `contains`, `consumes`, `produces`, `staged_by`, and `lowered_from` directions preserve
      payload/job/result identity without returning body source, payload internals, the typed body AST, or generated
      implementation source. The already-retained generated-v2 plan is contract/source/order-checked against the
      compiled authority; only the selected entry's handler-plan identity becomes a separate
      `generated_artifact` linked by `generated_as`, and no emitter or target runtime is invoked. The complete calls
      fixture now deep-equals the neutral oracle without filtering. Focused staged/generated and isolation proof
      passes 4/4; combined calls/static/foundation proof passes 16/16. Complete Dart passes format 77/0, fatal
      analysis, package 318, primary 66x2, and corpus 105/105. Semantic governance remains 6/20/73 at rollout 3/9
      and native admission 2/6; Unicode is 806/9/8/2; generated source is v1/10/80-0-0; public proof is concurrency
      3/3, executable 0/19, retirement 5/6/8/0, capability 80/0/0, and surface 59/27/0. Canonical CI passes Rust
      semantic admission 1/1 in 80.50 seconds, primary 66x2, and Phase 0 1,031/1,031 in 638 seconds. No public
      query, runtime observation, trace, path, execution, rollout, or admission surface changes.
      Knowledge Map is 674 facts / 5,052 question keys.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.3.3`
    Status: `done` (2026-07-22)
    Goal: Compose calls/staging/generated signoff and close the Dart calls parent.
    Depends on: `.10.5.3.2`
    Acceptance: Re-run exact calls plus all-static/foundation proof, complete Dart package/primary/corpus,
      semantic/Unicode/generated/public/canonical gates, durable synchronization and artifact cleanup; close
      `.10.5.3` without promoting rollout/admission or exposing query/runtime behavior.
    Verification: No production or test code changes. One 22-test composed suite jointly passes exact calls,
      distinct staged/generated provenance, Unicode/interleaved isolation, all five static targets, repeated-
      lifecycle occurrence safety, strict decoded/byte source mapping, deterministic compilation failures, staged
      construction without target execution, detached clones, and public omission. Complete Dart passes format
      77/0, fatal analysis, package 318, primary 66x2, and corpus 105/105. Semantic governance remains 6/20/73 at
      rollout 3/9 and native admission 2/6; Unicode is 806/9/8/2; generated source is v1/10/80-0-0; public proof is
      concurrency 3/3, executable 0/19, retirement 5/6/8/0, capability 80/0/0, and surface 59/27/0. Canonical CI
      passes Rust semantic admission 1/1 in 77.64 seconds, primary 66x2, and Phase 0 1,031/1,031 in 624 seconds.
      mdBook, memory architecture, Knowledge Map, all four doctrines, task metadata, diff hygiene, and generated-
      artifact cleanup pass. Parent `.10.5.3` is closed with no public query, runtime observation, execution, trace,
      path, rollout, or admission change. Knowledge Map is 674 facts / 5,053 question keys.

- ID: `FUTURE-PARITY-BACKLOG.10.5.4`
  Status: `done` (2026-07-22)
  Goal: Expose immutable Dart semantic capabilities and query evaluation.
  Depends on: `.10.5.3`
  Acceptance: Add idiomatic typed capabilities/query plus raw-neutral validation over fresh clones of normalized
    projection data only. Match all 19 static digests and exact ids/order/source privacy, pages/cursors, directional
    traversal, budgets/costs, errors, and explanations; prove clone isolation, deterministic JSON identity, and no
    compiler/executor/trace/path/IR access. Runtime records remain absent.
  Children: `.10.5.4.0`, `.10.5.4.1`, `.10.5.4.2`, `.10.5.4.3`, `.10.5.4.4`

  #### Acceptance Checklist

  - [x] **RETRIEVE / SPLIT FIRST** — Reconcile the neutral 19 static cases and 26 malformed-request boundaries,
    admitted Perl/Rust evaluators, and Dart's detached private projection; freeze a dependency-ordered split before
    production or public-surface changes.
  - [x] **TYPED RECORD KERNEL** — Add immutable Dart request/response values and a package-private projection-only
    kernel for capabilities, list, get, explain, source projection, and structural redaction.
  - [x] **TRAVERSAL / LIMITS** — Add exact directional breadth-first relations, canonical after-id pages, logical
    budgets/costs, deterministic prefixes, and all successful static response digests.
  - [x] **PUBLIC TYPED / RAW-NEUTRAL** — Expose `capabilities`, typed `query`, and raw-neutral validation through
    one evaluator; match all 19 static digests and all 26 portable invalid-request boundaries through fresh clones.
  - [x] **SIGNOFF / HANDOFF** — Compose complete Dart/query/public/canonical proof, synchronize durable surfaces,
    clean artifacts, and close `.10.5.4` before runtime-observation leaf `.10.5.5`.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.4.0`
    Status: `done` (2026-07-22)
    Goal: Freeze the exact Dart semantic-query authority map and omission-safe implementation split.
    Depends on: `.10.5.3`
    Acceptance: Reconcile all 19 non-runtime query digests, 26 raw-neutral validation boundaries, the admitted
      Perl/Rust evaluators, and Dart's normalized static projection. Record exact API, cloning, privacy, ordering,
      traversal, paging, budgeting, error, explanation, and forbidden-authority boundaries; create bounded
      dependency-ordered implementation/closeout children; change no production behavior, public semantic API,
      runtime observation, rollout, or admission state.
    Verification: Dart's immutable `_SemanticStaticProjection` already contains the only allowed query authority:
      one snapshot, source-reference table, canonically ordered records, and canonically ordered relations. The
      evaluator must receive a fresh detached plain-data clone and cannot receive source text, parser/compiler
      objects, staged sidecars, AST/ActionIR, compiled regexes, generated implementation, executor, trace, path, or
      host state. Typed requests/responses and the raw-neutral seam must enter one evaluator; runtime events remain
      absent until `.10.5.5`. Implementation is split into typed record/source kernel `.1`, relation traversal and
      logical limits `.2`, public typed/raw-neutral completion `.3`, and composed closeout `.4`. The unchanged
      neutral checker passes 6 groups / 20 queries / 73 mutations at rollout 3/9 and admission 2/6; the four Dart
      source/outcome/static/calls suites pass 22/22. No production/test code or public behavior changed.
      Knowledge Map is 675 facts / 5,062 question keys.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.4.1`
    Status: `done` (2026-07-22)
    Goal: Add the immutable Dart semantic-query value model and package-private record/source kernel.
    Depends on: `.10.5.4.0`
    Acceptance: Define idiomatic immutable typed operation, direction, page, budget, source, record, relation,
      diagnostic, cost, and response values with exact neutral JSON. Evaluate capabilities/list/get/explain over a
      fresh detached projection clone; apply exact source identity/span/text/digest ceilings and structural
      redactions; prove the covered canonical digests, owned-clone isolation, deterministic interleaving, and no
      compiler/executor/trace/path/IR access. Keep the incomplete query seam out of the public umbrella.
    Verification: New `semantic_query.dart` defines immutable typed operation/direction/page/budget/source/request,
      source-reference/record/relation/diagnostic/page-state/cost/response values with exact detached neutral JSON.
      The package-internal kernel receives only `_staticProjection.detachedJson()` and implements capabilities,
      list, get, explain, source none/identity/span/text/digest projection, structural pattern/message/summary
      redaction, ceiling rejection, unknown-subject/not-explainable diagnostics, exact costs, and fresh owned
      values. Nine owned static cases match their full canonical SHA-256 response digests: capabilities, graph
      list/get/explain, calls symbols/shapes, failed diagnostic, privacy none/text+digest, and lowered-ceiling
      rejection. Focused proof passes 4/4; composed source/outcome/static/calls/query proof passes 26/26. The
      incomplete relation branch is an explicit internal `.10.5.4.2` fence, and the public umbrella exports no
      query type or method. Complete Dart passes format 79/0, fatal analysis, package 322, primary 66x2, and corpus
      105/105. Semantic remains 6/20/73 at rollout 3/9 and admission 2/6; Unicode is 806/9/8/2; generated source is
      v1/10/80-0-0; public proof is concurrency 3/3, executable 0/19, retirement 5/6/8/0, capability 80/0/0, and
      surface 59/27/0. Canonical CI passes Rust semantic admission 1/1 in 76.58 seconds, primary 66x2, and Phase 0
      1,031/1,031 in 632 seconds. No runtime record, raw-neutral validation, public API, rollout, or admission change.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.4.2`
    Status: `done` (2026-07-22)
    Goal: Complete Dart relation traversal, pagination, budgets, costs, and successful static query parity.
    Depends on: `.10.5.4.1`
    Acceptance: Add relation-kind-filtered outgoing/incoming/both breadth-first traversal, canonical relation-id
      deduplication/order, after-id paging, depth/record/relation limits, deterministic budget prefixes and costs.
      Match every successful non-runtime query digest through the typed package-private kernel, including reverse,
      staged/generated, page-boundary, record/relation/depth-budget, privacy, and explanation cases.
    Verification: The detached evaluator now performs relation-kind-filtered outgoing/incoming/both breadth-first
      traversal by canonical projection order, deduplicates relation ids, advances through unvisited record
      frontiers, and reports the maximum returned layer. One shared primary-stream pager implements exact after-id,
      limit, continuation, completion, and invalid-cursor behavior across capabilities/list/get/relations/explain.
      Record/relation/depth budgets return deterministic prefixes, exact logical costs, and portable warnings.
      All 16 successful non-runtime response SHA-256 digests match exactly, including reverse dispatch, staged
      consumes/produces, generated provenance, after-id/page boundary, record/relation budget prefixes, depth zero,
      privacy, and explanation. An independent both-direction depth-one proof locks incoming/outgoing canonical
      order, 0/4/1 cost, and max-depth warning. Focused proof passes 5/5; composed source/outcome/static/calls/query
      proof passes 27/27. Complete Dart passes format 79/0, fatal analysis, package 323, primary 66x2, and corpus
      105/105. Semantic remains 6/20/73 at rollout 3/9 and admission 2/6; Unicode is 806/9/8/2; generated source is
      v1/10/80-0-0; public proof is concurrency 3/3, executable 0/19, retirement 5/6/8/0, capability 80/0/0, and
      surface 59/27/0. Canonical CI passes Rust semantic admission 1/1 in 78.42 seconds, primary 66x2, and Phase 0
      1,031/1,031 in 625 seconds. Public/raw-neutral query, runtime observation, rollout, and admission stay absent.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.4.3`
    Status: `done` (2026-07-22)
    Goal: Expose one exact public Dart typed and raw-neutral semantic-query evaluator.
    Depends on: `.10.5.4.2`
    Acceptance: Add public `SemanticIndex.capabilities`, typed `query`, and raw-neutral `queryNeutral` seams over
      the same projection-only evaluator. Validate exact object keys/types/order/duplicates, operation
      combinations, kinds, directions, pages, budgets, source policies/ceilings, subjects, cursors, unsupported
      contracts, and numeric-boolean fences. Match all 19 static response digests through typed and neutral paths,
      all 26 portable invalid boundaries, fresh response/request isolation, deterministic JSON identity, and
      recursive host/path/AST/IR/execution/trace denial. Do not add runtime records or ledger promotion.
    Verification: `SemanticIndex.capabilities`, typed `query(SemanticQuery)`, and raw-neutral
      `queryNeutral(Object?)` are exported with every immutable request/response protocol type. Both paths enter
      one detached-projection-only validator/evaluator. Typed and raw-neutral requests match all 19 static response
      SHA-256 digests; all 26 portable malformed-request boundaries return exact codes, reasons, empty primary
      streams, and rejected input cursor values without retaining or mutating caller input. Capabilities and query
      responses are fresh clone-safe values; directional traversal, source ceilings/privacy, deterministic
      interleaving, recursive host denial, and public-export ownership are exact. Focused proof passes 6/6 and
      composed source/outcome/static/calls/query proof passes 28/28. Complete Dart passes format 79/0, fatal
      analysis, package 324, primary 66x2, and corpus 105/105. Semantic remains 6/20/73 at rollout 3/9 and native
      admission 2/6; Unicode is 806/9/8/2; generated source is v1/10/80-0-0; public proof is concurrency 3/3,
      executable 0/19, retirement 5/6/8/0, capability 80/0/0, and surface 59/27/0. Canonical CI passes Rust semantic
      admission 1/1 in 77.92 seconds, primary 66x2, and Phase 0 1,031/1,031 in 627 seconds. Runtime observation,
      rollout, and admission remain unchanged. Knowledge Map is 678 facts / 5,083 question keys.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.4.4`
    Status: `done` (2026-07-22)
    Goal: Compose semantic-query signoff and close the Dart query parent.
    Depends on: `.10.5.4.3`
    Acceptance: Re-run exact 19-query/26-boundary proof plus source/static/calls composition, complete Dart
      package/primary/corpus/generated, semantic/Unicode/public/canonical gates, durable synchronization, and
      artifact cleanup; close `.10.5.4` without runtime observation, rollout, or admission promotion.
    Verification: No production or test code changes. The committed public-query code passes the explicit 28-test
      source/outcome/static/calls/query composition, including all 19 static digests, all 26 malformed-request
      boundaries, source/call/staging/generated provenance, deterministic failure normalization, clone isolation,
      and forbidden-authority denial. Complete Dart remains format 79/0, fatal analysis, package 324, primary 66x2,
      and corpus 105/105. Semantic remains 6/20/73 at rollout 3/9 and native admission 2/6; Unicode is 806/9/8/2;
      generated source is v1/10/80-0-0; public proof is concurrency 3/3, executable 0/19, retirement 5/6/8/0,
      capability 80/0/0, and surface 59/27/0. Canonical CI on committed code passes Rust semantic admission 1/1 in
      77.48 seconds, primary 66x2, and Phase 0 1,031/1,031 in 656 seconds. mdBook, memory architecture, Knowledge
      Map, all four doctrines, task metadata, diff hygiene, and generated-artifact cleanup pass. Parent `.10.5.4`
      closes without runtime observation, rollout, or admission promotion. Knowledge Map remains 678 facts / 5,083
      question keys.

- ID: `FUTURE-PARITY-BACKLOG.10.5.5`
  Status: `done` (2026-07-22)
  Goal: Capture typed Dart runtime semantic observations through every execution route.
  Depends on: `.10.5.4`
  Children: `.10.5.5.0`, `.10.5.5.1`, `.10.5.5.2`, `.10.5.5.3`, `.10.5.5.4`
  Acceptance: Add an optional invocation-local typed sink, separate from trace and diagnostic output, at the
    authoritative post-match regex-slot and successful final-result seams. Derive a new immutable observed index
    and match the twentieth digest across direct, loaded, reconstructed, generated/source-emitter, and traced/
    untraced routes without changing results/cursors/traces/diagnostics or permitting query-side execution.

  #### Acceptance Checklist

  - [x] **RETRIEVE / SPLIT FIRST** — Reconcile ADR `0049`, admitted Perl/Rust observation owners, Dart runtime,
    loader, generated-plan/source-emitter, trace/diagnostic, immutable-index, and exact runtime-oracle seams before
    behavior changes; freeze the dependency-ordered `.0-.4` split.
  - [x] **TYPED LIVE CAPTURE** — Add one public immutable event vocabulary and optional invocation-local sink to
    direct, loaded, and reconstructed execution at the exact post-match slot and successful final-result seams.
  - [x] **IMMUTABLE DERIVATION** — Validate caller-retained event topology against static records/relations and
    derive a separate immutable observed `SemanticIndex` matching the twentieth exact digest.
  - [x] **GENERATED / TRACED ROUTES** — Thread the same sink through generated-plan, emitted-source, and traced/
    untraced adapters while preserving caller exception identity and every pre-existing result/trace/diagnostic.
  - [x] **SIGNOFF / HANDOFF** — Compose complete runtime-observation proof, synchronize durable surfaces, clean
    artifacts, and close `.10.5.5` before admission leaf `.10.5.6`.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.5.0`
    Status: `done` (2026-07-22)
    Goal: Freeze the exact Dart runtime-observation authority map and omission-safe implementation split.
    Depends on: `.10.5.4`
    Acceptance: Reconcile the exact twentieth neutral response, admitted Perl/Rust event and derivation contracts,
      Dart's live/loaded/reconstructed/generated/emitted/traced execution topology, authoritative slot/result
      seams, observer-failure propagation, and immutable projection boundary. Record forbidden trace/diagnostic/
      query/compiler/host authority; create bounded dependency-ordered implementation and closeout children; change
      no production behavior, test behavior, public API, rollout, or admission state.
    Verification: Dart currently has no semantic observation sink. `_traceRegexSlotSelected` is already called
      after one regex match and structural slot identity are accepted but before match effects, and exposes the
      executing rule plus every selected target rule/index; the successful public `_parse` wrapper constructs the
      final `RuntimeParseResult` with the exact Unicode-scalar cursor and selected entry label. These are the only
      authoritative capture seams. `LoadedCompiledSpec.createEngine()` and reconstructed `CompiledSpec` reuse that
      engine. Generated-plan and emitted-source functions reuse it too, but their outer adapters translate generic
      thrown objects into `GeneratedSourceException`; observer failures therefore require an explicit identity-
      preserving passthrough wrapper analogous to diagnostic-output failures. The sink must remain invocation-
      local and absent-by-default so no event allocation or input hashing occurs without a caller. The derived
      index must validate events against detached static rule/slot/selects-regex evidence, derive value shapes only
      from static projection data, add one execution, ordered events, and `observed_as` relations to a new snapshot,
      and leave the base index static. Work is ordered as typed live capture `.1`, immutable derivation/twentieth
      digest `.2`, generated/emitted/traced topology `.3`, and composed closeout `.4`. No production or test code,
      public API, trace, diagnostic, query, rollout, or admission behavior changed. The unchanged composed Dart
      semantic suite passes 28/28; the neutral checker remains 6 groups / 20 responses / 73 rejected mutations at
      rollout 3/9 and admission 2/6. mdBook, memory architecture, Knowledge Map 679/5,095, all four doctrines, task
      metadata, required marker checks, and diff hygiene pass.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.5.1`
    Status: `done` (2026-07-22)
    Goal: Add typed Dart runtime semantic events and direct-engine capture.
    Depends on: `.10.5.5.0`
    Acceptance: Export an immutable closed event-kind/event/sink API carrying contract id, executing rule, optional
      target rule/index, Unicode-scalar position, and result-only input identity/status. Thread the optional sink
      through parse/execute and trace convenience routes plus generated-plan engine entry, emit exact slot events
      only after accepted structural selection and one successful final entry result, preserve caller exception
      identity, and prove absent-sink zero capture across direct, loaded, and reconstructed execution without
      changing results, cursors, traces, diagnostics, or failures.
    Verification: `runtime/semantic_observation.dart` exports the exact v1 contract id, closed typed slot/result
      kinds, immutable event value with detached JSON/equality, and invocation-local callback type. One runtime
      context field is threaded through `parse`, `execute`, their trace convenience forms, and the validated
      generated-plan engine entry. `_recordRegexSlotSelected` emits only after match/ordered-slot acceptance and
      before match effects, using the matched end converted to a Unicode-scalar offset; the public wrapper emits
      `rule_result` only after successful `RuntimeParseResult` construction. Explicit null guards occur before
      event construction and final input hashing. Callback failures are privately wrapped only long enough to
      restore the original object/stack after trace-scope closure. Focused proof passes 5/5: canonical `ab\n`
      yields `Top[0]@1`, `Top[1]@2`, and successful `Top@2` with input identity `a63d8014...`; direct, loaded,
      reconstructed, parse/execute, traced convenience, and generated-plan engine routes agree; a multibyte probe
      proves scalar positions; immediate exit omits the final result; result/cursor/trace/diagnostic values are
      unchanged. Adjacent runtime/diagnostic/native-trace/source-emitter plus observation proof passes 81/81 and
      static semantic composition remains 28/28. Complete Dart passes format 81/0, fatal analysis, package 329,
      primary 66x2, and corpus 105/105. No public generated/source-emitter sink or observed-index derivation lands
      early; `.10.5.5.2` owns immutable derivation and `.3` owns generated/emitted public propagation. Semantic
      rollout/admission remains 3/9 and 2/6. Canonical proof passes Rust semantic admission 1/1 in 79.08 seconds,
      primary 66x2, and Phase 0 1,031/1,031 in 623 seconds.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.5.2`
    Status: `done` (2026-07-22)
    Goal: Derive an immutable Dart semantic runtime snapshot from typed observations.
    Depends on: `.10.5.5.1`
    Acceptance: Add `SemanticIndex.withExecutionObservation(...)` with exact contract/topology validation. Require
      one final successful result event last; map selected entry/rules/slots through static records and
      `selects_regex`; derive shapes only from static evidence; add canonical execution/event records and
      `observed_as` relations to a new immutable snapshot; keep the base static; match the twentieth response digest
      through typed and raw-neutral queries; reject empty, malformed, duplicate-final, foreign, reordered, and
      already-observed inputs with exact portable errors and no host/result-value authority.
    Verification: Public `SemanticIndex.withExecutionObservation(...)` now delegates to a private runtime-
      projection part that receives typed immutable events plus the already-detached static projection only. It
      requires a compiled snapshot with no execution, validates contract and event field combinations including
      Dart-only negative position/index values, requires exactly one final succeeded entry result with a stable
      SHA-256 input identity, resolves every selecting rule/target slot through `selects_regex`, and derives result/
      event shapes solely from static rule and edge facts. The returned index clones/canonicalizes projection data,
      sets only its own `has_execution`, and adds `execution:0`, three ordered event records, and three
      `observed_as` relations with exact slot/rule evidence; the base remains static and later caller list/response
      mutation cannot alter either snapshot. Focused proof passes 4/4 across typed/raw identity, exact relation
      evidence, empty/malformed/duplicate-final/foreign/reordered/already-observed/failed-index rejection, and an
      existing-but-unselected slot. The canonical `runtime_events` response matches twentieth digest
      `36897041...`. Full semantic composition passes 37/37; complete Dart passes format 83/0, fatal analysis,
      package 333, primary 66x2, and corpus 105/105. Neutral governance remains 6/20/73 at rollout 3/9 and native
      admission 2/6. Canonical CI passes Rust semantic admission 1/1 in 76.84 seconds, primary 66x2, and Phase 0
      1,031/1,031 in 620 seconds. Knowledge Map remains 679 facts / 5,095 question keys; mdBook, memory architecture,
      task metadata, all four doctrines, diff hygiene, and generated-artifact cleanup pass. Generated/emitted public
      route propagation remains solely `.10.5.5.3`.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.5.3`
    Status: `done` (2026-07-22)
    Goal: Preserve exact Dart runtime observations through every generated and traced route.
    Depends on: `.10.5.5.2`
    Acceptance: Add the optional sink to generated-plan and emitted-source public functions, traced and untraced,
      while preserving observer exception object/stack identity through generated error translation. Prove exact
      event equality, twentieth digest, result/cursor/trace/diagnostic equality, failure omission of final-result
      events, and no-sink behavior across direct, loaded, reconstructed, generated-plan, emitted-source, and trace
      routes without changing generated-source contract/version or semantic rollout/admission ledgers.
    Verification: `executeGeneratedParserV2(...)` and `executeGeneratedParserWithTraceV2(...)` now accept the same
      optional `RuntimeSemanticObservationSink` as the engine and forward it through a null-preserving private
      adapter. A dedicated `_GeneratedSemanticObservationSinkFailure` catches only caller callback failures and
      restores their exact object and stack before the source-emitter's generic execution-error normalization;
      diagnostic and semantic channels remain independent. Fresh emitted libraries expose the same optional named
      parameter on public `execute(...)` and `executeWithTrace(...)`, while generated-source contract
      `linkedspec-generated-source-v2` and format 2 remain unchanged. Focused route proof passes 2/2 and adjacent
      emitter/diagnostic/runtime proof passes 24/24: direct and traced generated helpers plus isolated real emitted
      libraries deliver the exact three typed events, match twentieth digest `36897041...`, preserve result and
      diagnostics, produce byte-identical routed traces with or without observation, retain exact caller error/
      stack identity, and omit the final result after immediate exit status 7. Full semantic composition passes
      39/39. Complete Dart passes format 84/0, fatal analysis, package 335, primary 66x2, and corpus 105/105.
      Neutral governance remains 6/20/73 at rollout 3/9 and admission 2/6; generated-source identity is unchanged.
      Canonical CI passes Rust semantic admission 1/1 in 76.72 seconds, primary 66x2, and Phase 0 1,031/1,031 in
      623 seconds. Knowledge Map remains 679 facts / 5,095 question keys; mdBook, memory/task/live docs, all four
      doctrines, diff hygiene, and generated-artifact cleanup pass.

  - ID: `FUTURE-PARITY-BACKLOG.10.5.5.4`
    Status: `done` (2026-07-22)
    Goal: Compose Dart runtime-observation signoff and close the parent.
    Depends on: `.10.5.5.3`
    Acceptance: Re-run exact static plus runtime query proof, malformed-observation boundaries, all execution-route
      topology and non-interference checks, complete Dart package/primary/corpus/generated, semantic/Unicode/public/
      canonical gates, durable synchronization, and artifact cleanup; close `.10.5.5` without rollout or native
      admission promotion, leaving `.10.5.6` as the only Dart semantic admission owner.
    Verification: No production or test code changes. Committed runtime-observation code passes the complete 39/39
      semantic composition and adjacent 24/24 emitter/diagnostic/runtime proof, covering all 20 exact digests,
      static/runtime query identity, malformed observation boundaries, direct/loaded/reconstructed/generated-plan/
      public generated/emitted/traced topology, caller failure identity, immediate-exit omission, and result/trace/
      diagnostic non-interference. Complete Dart remains format 84/0, fatal analysis, package 335, primary 66x2,
      and corpus 105/105. Semantic remains 6/20/73 at rollout 3/9 and native admission 2/6; Unicode is 806/9/8/2;
      generated source is v1/10/80-0-0; public proof is concurrency 3/3, executable 0/19, retirement 5/6/8/0,
      capability 80/0/0, and surface 59/27/0. Canonical CI passes Rust semantic admission 1/1 in 77.24 seconds,
      primary 66x2, and Phase 0 1,031/1,031 in 621 seconds. Knowledge Map remains 679 facts / 5,095 question keys;
      mdBook, memory architecture, all four doctrines, task metadata, diff hygiene, and generated-artifact cleanup
      pass. Parent `.10.5.5` closes without production or semantic-ledger change; `.10.5.6` is the sole active
      admission owner.

- ID: `FUTURE-PARITY-BACKLOG.10.5.6`
  Status: `done` (2026-07-22; exact composed Dart admission and parent closeout)
  Goal: Admit the exact Dart semantic implementation and close the Dart parent.
  Depends on: `.10.5.5`
  Acceptance: Add one omission-sensitive Dart consumer covering source/compiled/failed/runtime snapshots, native/
    neutral JSON, all 20 exact query digests, direct/loaded/reconstructed/generated/emitted/traced routes, privacy,
    pages, budgets, errors, explain, no-execute immutability, and stale-host denial. Register it canonically, add
    omission mutations, advance only Dart rollout/admission, pass complete package/primary/corpus/generated and
    canonical gates, synchronize public state, and close `.10.5` cleanly.
  Verification: Added `dart/test/semantic_introspection_dart_admission_test.dart`, one ordered 12-role exact-once
    consumer over strict bytes/text, compiled/failed/runtime snapshots, loaded and JSON-reconstructed state,
    generated-plan/public-helper/standalone-emitted direct and traced execution, typed/native-neutral JSON, all 20
    response digests, privacy/pages/budgets/errors/explain, query non-execution and immutability, and host/path/IR
    denial. The pre-promotion consumer failed only on Dart's pending neutral status; after promotion it passes 1/1.
    Canonical CI now requires and runs it. Eight independent Dart topology mutations raise the checker from 73 to
    81 rejected mutations, rollout from 3/9 to 4/9, and native admission from 2/6 to 3/6; the early-admission fence
    moves to Julia. Complete Dart passes format 85/0, fatal analysis, package 336/336, primary 66x2, and corpus
    105/105. Public guide, mdBook, both roadmaps, task/index, memory, Knowledge Map 680/5,105, and live notes agree;
    canonical CI passes Rust admission 1/1 in 83.16 seconds, Dart admission 1/1, primary 66x2, Phase 0
    1,031/1,031 in 650 seconds, and the complete gate in 1,716.72 seconds. Parent `.10.5` closes with no semantic
    production-code change.

- ID: `FUTURE-PARITY-BACKLOG.10.6`
  Status: `done` (2026-07-25; exact Julia semantic adapter and ordered native admission closed)
  Goal: Implement the Julia semantic index adapter and exact native conformance.
  Children: `.10.6.0`, `.10.6.1`, `.10.6.2`, `.10.6.3`, `.10.6.4`, `.10.6.5`, `.10.6.6`, `.10.6.7`
  Depends on: `.10.5`
  Acceptance: Project the same model from Julia compiled/action/provenance/diagnostic/generated authorities through
    idiomatic Julia types plus neutral JSON; prove exact reference answers and non-interference across every shared
    route, privacy/page/budget/explain case, omission mutation, full package/primary/corpus/generated gate, and
    canonical gate without exposing Julia dictionaries or type layout as semantic schema. Before the `Töp` privacy
    fixture can be admitted, align every Julia rule declaration/reference/artifact/selector route with ADR `0051`'s
    pinned Unicode 17 `XID_Continue` and exact identity contract.
  Verification: Leaves `.0-.7` align Julia rule labels to pinned Unicode 17, construct one strict opaque semantic
    source/outcome, project exact static/call/staged/generated facts, expose immutable typed/raw-neutral query,
    capture and derive typed runtime observations across every route, and admit the result through one ordered
    twelve-role consumer. Final proof is 416/416 admission, 1,753 semantic, complete Julia 9,295/primary/105,
    primary 5x2x66 plus ten Unicode legs, semantic 6/20/89 at 5/9 + 4/6, every unchanged no-drift ledger, canonical
    Rust 78.60s + Dart 1/1 + Julia 416/416 in 27.6s + reference primary 66x2 + Phase 0 1,031/636s, mdBook/KM
    695/5,358, doctrines, diff hygiene, and exact 1,632,888-KiB safe cleanup. No second semantic implementation,
    generated-format change, or Lua/recurring/MCP/public promotion is introduced.

- ID: `FUTURE-PARITY-BACKLOG.10.6.0`
  Status: `done` (2026-07-22; behavior-free Julia semantic/Unicode authority map and dependency split)
  Goal: Map Julia semantic and Unicode-label authorities, prove the exact pre-implementation boundary, and split
    the adapter into omission-safe dependency-ordered leaves before behavior code.
  Depends on: `.10.5.6`
  Acceptance: Retrieve the canonical semantic-model, rule-label, Julia architecture, generated-source, loader,
    trace, diagnostic, primary, and verification facts through the Knowledge Map and Toolbox before source audit;
    inventory strict source/compiled/failure/static/call/provenance/query/runtime/generated/emitted/trace owners and
    gaps with exact probes; measure every Julia rule declaration/reference/artifact/selector route against ADR
    `0051`; record host-object/privacy/non-interference risks; create complete dependency-ordered implementation,
    composition, and admission children; synchronize task/index/memory/roadmap/mdBook/Knowledge Map as warranted;
    change no Julia production/test behavior, neutral fixture, semantic ledger, or rollout/admission status.
  Verification: Exact native/contract probes establish that Julia has rich typed parse/compile/action/staged/
    diagnostic/generated authorities but no semantic API, complete source map, or typed observation sink. Ordinary
    source spans are line-only, action spans are scalar-local, compiled definition order omits function shells,
    loaded state carries resolved host paths, generated execution translates generic callback failures, and public
    immutable structs can retain mutable collections. A separate Unicode preflight proves current PCRE2 `\w`
    membership is not ADR `0051`: host Unicode 16 tables miss 5,175 required scalars, admit 923 forbidden scalars,
    reject required `A·B`, accept forbidden `²`, truncate `Top:::` to `Top`, and permit programmatic/reconstructed
    action/blind/bare target labels to bypass validation into compiled/descriptor/generated/emitted artifacts.
    Two Knowledge Map cards record the exact boundary. Work is split into Unicode prerequisite `.1`, opaque source/
    outcome `.2`, static projection `.3`, calls/staging/generated `.4`, query `.5`, runtime observation `.6`, and
    exact admission `.7`; no Julia behavior or neutral governance state changes in this audit. The unchanged
    complete Julia gate passes 3,711 package assertions, primary conformance, and corpus 105/105. Semantic
    governance remains 6/20/81 at rollout 4/9 and admission 3/6; Unicode is 806/9/8/2; Knowledge Map is
    682 facts / 5,138 keys; mdBook, memory architecture, all four doctrines, task metadata, and diff hygiene pass.
    The first canonical run correctly rejected removal of the exact repeated-action live-status marker during
    condensation; restoring the unchanged checker-owned 8/0/54 sentence makes the focused checker pass and the
    complete canonical rerun pass Rust semantic admission 1/1 in 80.05 seconds, Dart admission 1/1, primary 66x2,
    and Phase 0 1,031/1,031 in 653 seconds. Generated mdBook/Rust cache artifacts are removed before commit.
  Commit: `FUTURE-PARITY-BACKLOG.10.6.0 - map Julia semantic authorities`

- ID: `FUTURE-PARITY-BACKLOG.10.6.1`
  Status: `done` (2026-07-22; composed Julia Unicode prerequisite closed without semantic promotion)
  Goal: Align every Julia rule-label route with pinned Unicode 17 `XID_Continue` before semantic construction.
  Children: `.10.6.1.0`, `.10.6.1.1`, `.10.6.1.2`, `.10.6.1.3`, `.10.6.1.4`
  Depends on: `.10.6.0`
  Acceptance: Generate one Julia classifier/scanner from the neutral 806 ranges; replace host `\w` membership at
    every declaration/reference parser and validator route; preserve exact case/normalization-sensitive identity
    through artifacts, selectors, diagnostics, trace, loader, and primary routes; reject all invalid/prefix and
    external-AST bypass cases without widening unrelated identifier grammars; close complete Julia/canonical proof
    without semantic rollout or admission promotion.

  #### Acceptance Checklist

  - [x] **FREEZE BEFORE CODE** — Reproduce the exact host-table census and parser/external-AST bypasses, then fix
    the generated artifact, parser/validator ownership, route suites, isolation suites, and gate order in `.0`.
  - [x] **GENERATE / ROUTE** — Emit one deterministic internal Julia classifier/scanner from the existing neutral
    ranges and consume it at all five parser sites plus the authoritative declaration/target validator boundary.
  - [x] **EXACT IDENTITY** — Prove all nine positive fixtures and both distinct pairs through every parsed,
    compiled, reconstructed, generated, emitted, selector, diagnostic, trace, loader, and primary route.
  - [x] **NEGATIVE / ISOLATION** — Reject all eight negatives without prefix recovery or external-AST bypass and
    prove function/parameter/helper/action/lifecycle/split/conditional/fluent/mark/regex grammars are unchanged.
  - [x] **COMPOSE / NO PROMOTION** — Pass complete Julia and canonical gates, close `.10.6.1`, and keep semantic
    governance exactly 6/20/81 at rollout 4/9 and native admission 3/6 before handing off to `.10.6.2`.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.1.0`
    Status: `done` (2026-07-22)
    Goal: Freeze the generated Julia Unicode classifier/scanner contract and route/isolation proof split.
    Depends on: `.10.6.0`
    Acceptance: Reproduce the 5,175-missing/923-extra host census and all parser/validator/artifact bypasses; map
      generator outputs, all five parser patterns, validator declaration/target owners, reconstructed AST routes,
      positive/distinct/negative fixtures, downstream identities, primary/canonical commands, and exact `.1-.4`
      dependency order before production behavior changes.
    Verification: Activated task-tree-first from clean audit commit `7bdb181f` at ahead 17. With the writable
      Julia depot stacked before the installed depot, an exhaustive valid-scalar rerun reproduces exactly 5,175
      pinned Unicode 17 `XID_Continue` false negatives and 923 false positives from host PCRE2 `^\w+$`; the first
      missing scalars are U+00B7/U+0387/U+088F/U+0903 and the first extras are U+00B2/U+00B3/U+00B9/U+00BC. The
      neutral positive matrix remains 8/9: only `A·B` fails. Forbidden `²` still compiles and `Top:::` still
      parses as `Top`. Programmatic and JSON-reconstructed `Top-Rule` plus `A·B` declarations and action/blind/bare
      targets all pass validation, compilation, descriptor, generated-plan, and emitted-source construction,
      confirming the exact trust routes that `.1` must close.

      The frozen generator target is `julia/src/spec/UnicodeRuleLabel.jl`, emitted by existing pinned-data owner
      `unicode_case/generate_unicode_rule_label_contract.py` through a new `--julia-output` without changing the
      neutral contract, Unicode version, ranges, fixtures, or original task-owner metadata. It contains exact
      contract/version/hash/range-count constants, the 806 maximally merged endpoint pairs, integer/scalar binary
      search, nonempty complete-label validation, and a longest-prefix result whose indices use Julia string
      iteration/`nextind` rather than byte arithmetic or host properties. `tools/check_unicode_rule_label_contract.py`
      must independently regenerate/byte-compare/extract all endpoints and lock algorithm plus integration markers;
      `LinkedSpecJulia.jl` includes the internal artifact before `Parser.jl` and exports no new public API.

      Parser work in `.1` replaces only `_HEADER_PATTERN`, `_BODY_HEADER_PATTERN`, `_ACTION_PATTERN`,
      `_BLIND_PATTERN`, and `_BARE_EDGE_PATTERN`. One scalar-safe scanner family owns header fields/body termination,
      action/blind/bare target lists, optional indices, delimiter/remainder validity, third-colon rejection, and raw
      preservation for malformed arrow lines. It deliberately leaves regex, lifecycle, split/mark, conditional,
      fluent, bounded-mode, function-shell, and ActionParser identifier patterns untouched. Validator work inserts
      `_check_rule_labels` immediately after the at-least-one-rule check in traced and untraced paths and covers
      every `RuleHeader`, `ActionEdgeBodyElementKind`, `BlindEdgeBodyElementKind`, and
      `BareEdgeBodyElementKind` target with portable `invalid_rule_label` / `validate_rule_labels` diagnostics.

      Proof is dependency-locked: `.1` owns generated classifier plus parser/validator routes in
      `unicode_rule_label_classifier_test.jl` and `unicode_rule_label_routes_test.jl`; `.2` owns the ten unique
      identities represented by 9 positives/2 distinct pairs across AST, compiled JSON/order/maps, descriptor,
      plan, reconstruction, direct/generated execution, independently emitted host, selector, diagnostic, trace,
      strict loader, and inline/file primary routes; `.3` owns 8 negatives x 4 roles x programmatic/reconstructed
      trust paths, whole-token/no-prefix/newline/primary rejection, and all adjacent identifier isolation; `.4`
      owns committed-code composition, durable sync, cleanup, and no-promotion closeout. `runtests.jl`, the Unicode
      checker, and `run_ci_local.sh` acquire omission-sensitive registrations. Focused Julia includes, complete
      `tools/run_julia_local.sh`, primary 66x2, Unicode/semantic/generated/public checkers, mdBook/doctrines, and
      `tools/run_ci_local.sh` are the exact gate order. No production, generated artifact, test, fixture, contract,
      semantic response, rollout, or admission behavior changes in `.0`.

      Final proof passes the Unicode checker at 806 ranges / 9 positives / 8 negatives / 2 distinct pairs,
      semantic governance at 6 fixture groups / 20 query digests / 81 rejected mutations with rollout 4/9 and
      admission 3/6, Knowledge Map at 682 facts / 5,142 question keys, mdBook, memory architecture, all four
      doctrines, and diff hygiene. Canonical local CI passes Rust semantic admission 1/1 in 77.35 seconds, Dart
      admission 1/1, primary 66x2, and Phase 0 1,031/1,031 in 641 wallclock seconds. The rendered mdBook, Rust
      debug dependency/incremental output, and Python bytecode cache are then removed exactly, reclaiming about
      1.14 GB without touching tracked source or `rgx/pgen-issues/artifacts`.

    #### Acceptance Checklist

    - [x] **REPRODUCE EXACTLY** — Exhaustive scalar and source probes reproduce 5,175 missing / 923 extra,
      positive 8/9, `²` acceptance, `Top:::` truncation, and declaration/action/blind/bare external-AST bypasses.
    - [x] **GENERATOR / CLASSIFIER** — Freeze the one new generator output, constants, 806 endpoint table,
      binary-search membership, complete validator, scalar-safe prefix scan, independent regeneration, and include.
    - [x] **PARSER / VALIDATOR** — Name all five replaced label patterns, scanner helpers/token boundaries, raw
      malformed-arrow preservation, validator placement, four AST roles, and exact portable diagnostic ownership.
    - [x] **ROUTES / ISOLATION** — Assign exact 9/8/2 fixture matrices, reconstructed/programmatic trust paths,
      every downstream identity route, and unrelated grammar assertions to `.1-.3` without overlap.
    - [x] **GATES / NO BEHAVIOR** — Freeze focused/complete/primary/contract/book/doctrine/canonical order and `.4`
      closeout while retaining semantic 6/20/81, rollout 4/9, and admission 3/6; `.0` changes documentation only.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.1.1`
    Status: `done` (2026-07-22; activated task-tree-first from clean `dfcc1ca7`)
    Goal: Generate and route one pinned Julia rule-label classifier/scanner through parser and validation seams.
    Depends on: `.10.6.1.0`
    Acceptance: Extend deterministic Unicode generation/checking with an exact 806-range Julia artifact; replace
      header/body/action/blind/bare host word scans with complete-token scanning; validate parsed, programmatic, and
      reconstructed declarations plus action/blind/bare targets; reject prefix truncation and malformed input while
      preserving existing non-label syntax and diagnostics outside the owned boundary.
    Verification: Existing generator now emits internal `julia/src/spec/UnicodeRuleLabel.jl` from the unchanged
      neutral JSON through `--julia-output`: exact contract/version/hash/range-count metadata, 806 endpoint pairs,
      half-open binary search, complete-label validation, and a `nextind`-safe longest-prefix result. The module
      includes it before `Parser.jl` without exporting a new public name. The independent checker regenerates and
      byte-compares the artifact, independently extracts every endpoint, rejects stale host-regex sites, and locks
      classifier/parser/validator/test/CI topology.

      Julia's five label-bearing `\w` patterns are removed. Header and body-boundary parsing share complete
      label/colon/mode fields with explicit third-colon rejection. Action, blind, and bare scanners consume pinned
      labels at valid string boundaries, retain existing group/index spellings, and accept only established
      remainders; malformed arrows remain `RawBodyElementKind` so validation reports syntax instead of silently
      losing a partial edge. `_check_rule_labels` runs immediately after nonempty-spec validation in traced and
      untraced paths and checks declarations plus action/blind/bare targets with exact `invalid_rule_label` /
      `validate_rule_labels` diagnostics before duplicate/structure/target checks.

      Focused classifier/native-route proof passes 1,755 assertions: all 1,612 range endpoints plus out-of-range
      scalars, 9/8/2 fixtures, supplementary-safe prefix/remainder identity, declarations and all edge forms,
      malformed suffix/raw preservation, third-colon rejection, and programmatic/JSON-reconstructed four-role
      validation. Complete Julia passes 5,466 package assertions, primary process conformance, and corpus 105/105.
      Unicode 806/9/8/2, semantic 6/20/81 at 4/9 + 3/6, generated/capability 80/0/0, public 59/27/0, the full
      five-backend 5x2x66 primary matrix, and the Unicode manifest on all ten legs pass. Staged canonical local CI
      passes all four doctrines, Rust semantic admission 1/1 in 79.93 seconds, Dart admission 1/1, primary 66/66
      under default and POSIX, and Phase 0 1,031/1,031 in 663 seconds. The mdBook builds, the Knowledge Map is exact
      at 682 facts / 5,144 question keys, and generated book/Rust/Python caches are removed after signoff without
      touching `rgx/pgen-issues/artifacts`. `.2-.4` retain downstream identity, exhaustive negative/isolation, and
      composed closeout, so this leaf does not promote semantic governance.

    #### Acceptance Checklist

    - [x] **DETERMINISTIC ARTIFACT** — Generate exact metadata and 806 ranges; independently regenerate,
      byte-compare, endpoint-extract, and require the internal pre-parser include without adding a public export.
    - [x] **COMPLETE PARSING** — Replace exactly five host-word routes with scalar-safe header/action/blind/bare
      scanners, preserve existing index/remainder syntax, reject third-colon/prefix truncation, and retain raw arrows.
    - [x] **AUTHORITATIVE VALIDATION** — Check parsed/programmatic/reconstructed declarations and action/blind/bare
      targets before structural resolution with one exact portable diagnostic in traced and untraced paths.
    - [x] **FOCUSED / COMPLETE** — Pass 1,755 focused assertions, complete Julia 5,466/primary/105, Unicode,
      semantic/generated/public checks, 5x2x66, and the self-hosted Unicode manifest without adjacent drift.
    - [x] **CANONICAL / CLEAN COMMIT** — Pass staged canonical CI, synchronize final proof, remove generated caches,
      and commit cleanly before activating exact downstream identity `.10.6.1.2`.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.1.2`
    Status: `done` (2026-07-22; exact downstream identity proved from clean `732eb1e1`)
    Goal: Prove exact positive and distinct Julia label identity through every downstream route.
    Depends on: `.10.6.1.1`
    Acceptance: Run all nine positive labels and both distinct pairs through source/AST, compiled state, descriptor,
      generated plan, reconstructed JSON, emitted source, explicit/default selectors, diagnostics, trace, strict
      loading, library APIs, and primary commands; prove exact scalar identity without normalization, folding, or
      host-path leakage.
    Verification plan: Add one omission-sensitive `unicode_rule_label_identity_routes_test.jl` registered by the
      package driver, Unicode checker, and canonical tracked-input gate. Derive ten unique scalar sequences from
      the unchanged 9-positive/2-distinct neutral matrices and generate one rule per sequence whose value is its
      exact label. Prove authored AST order; compiled definition/rule order and maps; compiled JSON; descriptor
      metadata/spec keys; generated-plan rows; AST JSON reconstruction; direct runtime and in-process generated
      execution; case/normalization pair non-aliasing; deterministic emitted payload reconstruction; and a fresh
      independently loaded emitted module that validates its plan and executes every explicit selector.

      Strict path loading must retain source text and compiled order, execute every selector, and keep logical
      labels independent from the resolved host path. Primary proof runs every label through inline source and the
      supplementary label through a UTF-8 file. Native and generated traces must retain requested/effective labels,
      parse-scope `top_rule`, and Unicode source identity. Missing Unicode selectors must preserve exact native and
      generated portable diagnostic fields. This leaf changes tests/checker/CI/docs only unless a measured route
      loses identity; it does not own negative/isolation proof, grammar widening, production repair, or promotion.
    Verification: The new test derives ten unique labels in deterministic neutral order from all nine positives and
      both distinct pairs. Its compiled/artifact set passes 63 assertions over parsed rule order, definition and
      compiled order, rule maps, compiled JSON, descriptor keys/metadata, generated plan, JSON-reconstructed AST,
      default plus every explicit native/generated execution, and independent case/normalization pair lookup.
      Emitted proof passes 6 assertions after decoding/recompiling the deterministic hex payload and running a fresh
      offline module that validates its plan and executes all ten selectors with exact Unicode logical identity.

      Strict loading and primary proof pass 47 assertions: exact UTF-8 source and order, no resolved path in compiled
      JSON or descriptor, every loaded selector, every inline CLI selector, and one supplementary file CLI route.
      Selector/diagnostic/trace proof passes 14 assertions: normalization-sensitive explicit selection, exact native
      decision and parse-scope text, exact missing-Unicode native/generated diagnostic JSON, and generated routed
      trace retention of requested/effective/top-rule/logical-source identity. Focused total is 130 new assertions;
      classifier/native-route/identity composition is 1,885. The independent checker passes Unicode 806/9/8/2 and
      now requires the test, its package registration, route markers, and canonical tracked-file registration. No
      production, neutral contract, generated format, public API, path policy, or semantic ledger changes. Complete
      Julia passes 5,596 package assertions, primary process conformance, and corpus 105/105. The complete primary
      matrix passes all 5 backends x 2 environments x 66 cases and the self-hosted Unicode manifest passes all ten
      legs. Independent no-drift remains Unicode 806/9/8/2, semantic 6/20/81 at rollout 4/9 and admission 3/6,
      capability 80/0/0, and generated source v1/10/80-0-0.

    #### Acceptance Checklist

    - [x] **NEUTRAL MATRIX / AST** — Consume all nine positives and both distinct pairs as ten unique labels;
      preserve exact authored AST order and prove case/normalization pairs never alias.
    - [x] **COMPILED / GENERATED ARTIFACTS** — Preserve exact order, keys, metadata, JSON, descriptor, reconstructed
      AST, generated-plan rows, and in-process direct/generated execution for every label.
    - [x] **EMITTED / LOADED / PRIMARY** — Reconstruct the deterministic emitted payload, execute a fresh emitted
      module for every selector, retain strict loaded source/order/path privacy, and pass inline plus UTF-8 file CLI.
    - [x] **SELECTOR / DIAGNOSTIC / TRACE** — Preserve exact Unicode selected/missing identities in native and
      generated selectors, portable diagnostics, trace events/text, parse scope, and logical source identity.
    - [x] **RECURRING / COMPLETE / CLEAN COMMIT** — Register omission-sensitive proof; pass focused Julia,
      Unicode/semantic/public checks, complete Julia/matrix/canonical gates as warranted, synchronize durable docs,
      remove generated caches, and commit cleanly before activating negative/isolation `.10.6.1.3`.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.1.3`
    Status: `done` (2026-07-22; exhaustive Julia negative/isolation proof from clean `1ee7c0e6`)
    Goal: Close Julia invalid-label and unrelated-identifier isolation.
    Depends on: `.10.6.1.2`
    Acceptance: Reject all eight negative fixtures at source/no-prefix, parsed, programmatic, reconstructed, action,
      blind, bare, artifact, selector, loader, and primary boundaries; prove the classifier does not widen/narrow
      function, parameter, helper, lifecycle, fluent, mark, regex, or action-language identifiers.
    Verification plan: Add one omission-sensitive `unicode_rule_label_negative_isolation_test.jl` registered by the
      Julia package driver, Unicode checker, and canonical tracked-input gate. Consume all eight unchanged negative
      fixtures directly. For declaration/action/blind/bare AST roles, validate both programmatic and JSON-
      reconstructed specimens against exact `invalid_rule_label` portable fields before compilation, descriptor,
      generated-plan, or emitted-source artifacts can be built. Drive every negative label as an explicit native
      and generated selector against a valid compiled spec and require exact missing-entry identity without
      truncation, folding, normalization, or fallback.

      Source proof must reject invalid declaration headers as complete physical tokens, retain invalid arrow/bare
      lines as raw syntax instead of recovering prefixes or suffixes, treat embedded newline only as a physical
      boundary, and exercise no-prefix `$Top`. Strict loading and primary commands must fail deterministically for
      every invalid declaration without path/host leakage or stdout. Isolation must prove the generated rule-label
      classifier does not change the current ASCII function/parameter boundary, ActionParser helper/variable/fluent
      identifiers, lifecycle markers, named-mark arguments, regex contents, bounded-mode tokens, or adjacent action
      syntax. Strict loader proof may retain its existing typed resolved-path attribution internally, but compiled/
      generated artifacts must never exist and the primary projection must expose no path or host detail. This leaf
      changes tests/checker/CI/docs only unless a measured route violates the frozen boundary; it
      does not own production repair, positive identity, neutral contract changes, semantic promotion, or composed
      closeout `.10.6.1.4`.
    Verification: The new test consumes all eight neutral negative fixtures without copying their labels. Its
      external-trust/artifact set passes 1,609 assertions: declaration/action/blind/bare roles from programmatic and
      JSON-reconstructed ASTs each return the exact portable `invalid_rule_label` diagnostic before validation,
      compilation, descriptor, generated-plan, or emitted-source construction can succeed. Source/no-prefix/newline
      proof passes 131 assertions over complete invalid headers, raw action/blind/bare lines, trimmed empty targets,
      the historical `Top:` physical-header interpretation, `$Top` suffix denial, and the valid `Top\nRule`
      two-token split.

      Selector/loader/primary proof passes 136 assertions. Native and generated explicit selection retain each
      invalid scalar sequence in exact missing-entry fields without fallback; strict file loading reports its typed
      parse stage/code/request/resolved path while detail stays path-free; inline and file primary commands return
      only the portable compilation heading with empty stdout. Unrelated-grammar isolation passes 70 assertions:
      function/parameter ASCII validation, ActionParser's existing ASCII-first host-word helper/variable/fluent
      boundary, assignments, lifecycle markers, action and split named marks, arbitrary regex contents, and bounded
      modes remain independently exact. No production repair is required. The new suite totals 1,946 assertions;
      classifier/native-route/identity/negative composition is 3,831. Complete Julia passes 7,542 package
      assertions, primary process conformance, and corpus 105/105; the Unicode checker remains 806/9/8/2. Full
      primary proof passes 5 backends x 2 environments x 66 cases plus every Unicode-manifest leg at 1/1.
      Semantic/capability/generated/public no-drift stays 6/20/81 at 4/9 + 3/6, 80/0/0, v1/10/80-0-0, and
      59/27/0. Knowledge Map 682/5,150, mdBook, memory, task metadata, all four doctrines, and diff hygiene pass.
      The staged canonical gate passes Rust admission 1/1 in 79.56 seconds, Dart admission 1/1, primary 66/66 in
      both environments, and Phase 0 1,031/1,031 in 645 seconds. Exact cleanup removes the regenerated 12-MB book,
      826-MB Rust deps, 727-MB incremental state, and 28-KB Python cache—about 1.57 GB—while preserving Pgen.

    #### Acceptance Checklist

    - [x] **NEGATIVE MATRIX / AST TRUST** — Consume all eight negatives across declaration/action/blind/bare
      programmatic and reconstructed roles with exact portable failure before artifact construction.
    - [x] **SOURCE / NO-PREFIX / NEWLINE** — Reject complete invalid headers, preserve invalid edge/bare raw syntax,
      deny suffix recovery, and prove newline is only a physical token boundary.
    - [x] **SELECTOR / LOADER / PRIMARY** — Preserve each exact invalid scalar sequence in native/generated
      selector failures, loader-owned path attribution, and path-redacted deterministic primary failures.
    - [x] **UNRELATED GRAMMAR ISOLATION** — Lock function, parameter, helper/variable/fluent, lifecycle, mark,
      regex, bounded-mode, and action-language identifier behavior independently from rule labels.
    - [x] **RECURRING / COMPLETE / CLEAN COMMIT** — Register omission-sensitive proof; pass focused/complete Julia,
      Unicode/semantic/public/matrix/canonical gates as warranted, synchronize durable docs, clean generated caches,
      and commit before activating closeout `.10.6.1.4`.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.1.4`
    Status: `done` (2026-07-22; no-change composed signoff from clean `0ce5505f`)
    Goal: Compose complete Julia Unicode-label signoff without semantic promotion.
    Depends on: `.10.6.1.3`
    Acceptance: Re-run generated artifact, focused identity/isolation, complete Julia package/primary/corpus,
      Unicode/semantic/generated/public/canonical gates, durable synchronization, and cleanup; close `.10.6.1`
      while keeping Julia semantic rollout/admission pending and handing off only to `.10.6.2`.
    Verification plan: Make no production, test, fixture, neutral-contract, API, generated-format, or semantic-ledger
      change. Re-run the independent Unicode generator/checker; compose classifier endpoints/fixtures, all five
      native parser routes, exact positive/distinct identity, exhaustive negative rejection, and adjacent-grammar
      isolation through all four committed Julia Unicode suites. Re-run complete Julia package/primary/corpus,
      five-backend default/POSIX primary and Unicode-manifest matrices, and Unicode/semantic/capability/generated/
      public no-drift checks. Stage only closeout documentation before the canonical local gate so tracked-input and
      doctrine enforcement see the final committed test topology. Synchronize parent/child status, roadmaps, book,
      Toolbox, Knowledge Map, live docs, and bounded memory; remove only regenerated caches, commit cleanly, then
      hand off to behavior-free Julia semantic source/outcome planning `.10.6.2.0`.
    Verification: The independent generated checker passes all 806 ranges, 9 positives, 8 negatives, and 2 exact-
      distinct pairs. The four committed Julia suites compose exactly 3,831 assertions: 1,619 range endpoints,
      23 fixtures, 32 prefix/scalar boundaries, 81 native parser/validator routes, 130 positive/distinct downstream
      identities, and 1,946 exhaustive negative/isolation assertions. Complete Julia passes 7,542 package
      assertions, primary process conformance, and corpus 105/105. The primary matrix passes 5 backends x 2
      environments x 66 cases; the self-hosted Unicode manifest passes all ten legs at 1/1.

      No-drift remains exact: Unicode 806/9/8/2; semantic 6 groups / 20 queries / 81 mutations at rollout 4/9 and
      native admission 3/6; capability 80/0/0; generated source v1 / 10 families / 80-0-0; public aggregate-selector
      surface 59 files / 27 classified history / 0 current examples. No production, test, fixture, neutral contract,
      public API, generated format, or semantic ledger changes in this closeout. Knowledge Map 682/5,151, mdBook,
      memory, task metadata, all four doctrines, and diff hygiene pass. The staged canonical gate passes Rust
      semantic admission 1/1 in 78.46 seconds, Dart admission 1/1, primary 66/66 in both environments, and Phase 0
      1,031/1,031 in 630 seconds. Exact cleanup removes the regenerated 12-MB book, 826-MB Rust deps, 727-MB
      incremental state, and 28-KB Python cache—about 1.57 GB—while preserving Pgen.

    #### Acceptance Checklist

    - [x] **GENERATED / FOCUSED COMPOSITION** — Regenerate/compare all 806 ranges and pass classifier/routes/
      identity/negative-isolation composition from the committed four-suite topology.
    - [x] **COMPLETE JULIA / MATRICES** — Pass complete Julia package/primary/105 plus 5x2x66 and all ten Unicode-
      manifest legs without production repair.
    - [x] **NO-DRIFT / NO PROMOTION** — Keep Unicode 806/9/8/2, semantic 6/20/81 at 4/9 + 3/6, capability 80/0/0,
      generated v1/10/80-0-0, public 59/27/0, and all production/API/format/ledger state unchanged.
    - [x] **CANONICAL / DURABLE CLOSEOUT** — Pass canonical Rust/Dart/primary/Phase 0, synchronize every durable
      layer, close `.10.6.1`, clean generated caches, commit, and make `.10.6.2.0` the sole next eligible leaf.

- ID: `FUTURE-PARITY-BACKLOG.10.6.2`
  Status: `done` (2026-07-22; opaque Julia source/outcome foundation composition-closed)
  Goal: Add the opaque Julia semantic source map and compiled-or-failed foundation.
  Children: `.10.6.2.0`, `.10.6.2.1`, `.10.6.2.2`, `.10.6.2.3`
  Depends on: `.10.6.1`
  Acceptance: Construct once from copied valid `String` or strict UTF-8 bytes plus caller logical name, source
    ceiling, and optional exact entry; retain canonical bytes/scalar mapping, staged parsed/validated/compiled-or-
    failed authority, merged rule/function authored order, selected entry, and generated-v2 plan without execution,
    paths, records/query, or host-object exposure.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.2.0`
    Status: `done` (2026-07-22; behavior-free Julia source/outcome contract and split frozen)
    Goal: Freeze the Julia source/outcome API boundary and implementation split.
    Depends on: `.10.6.1.4`
    Acceptance: Reconcile the neutral source/privacy contract and admitted backend precedents with Julia parser,
      staged shell, validator, compiler, selector, loader, diagnostic, and generated-plan owners; fix public/private
      types, malformed text/byte policy, no-path/no-execution topology, and exact `.1-.3` dependency order.
    Verification: Retrieved the canonical neutral source/outcome and admitted Perl/Rust/Dart authority records
      from the Knowledge Map and ADRs before inspecting Julia. Used LinkedSpec's Toolbox probes first to measure exact
      valid/invalid `String` and byte ingestion, staged function/rule ordering, validation/compile/selection failures,
      loader path ownership, generated-plan construction, descriptor leakage, mutation aliasing, `Bool <: Integer`
      option hazards, and no-execution boundaries. Valid copied graph text parses at 128 bytes/scalars; direct byte
      vectors have no parser method. Four malformed `String` byte sequences are all `isvalid == false` but fail
      inconsistently as `InvalidCharError`, `SpecParseException`, or staged
      `UserFunctionDefinitionParserException`, proving strict rejection must precede language parsing. Calls staging
      retains function `normalize` before rules `Top`/`Done`, but `CompiledSpec.definition_order` contains only the
      rules. Failed source preserves `bare_edge_target_undefined` / `normalize_edges` with `rule_label=Top` and
      `target=Missing`; missing selection preserves `entry_rule_not_found` / `select_entry_rule`. Generated plan is
      exact v2 rows `Top/default`, `Done/default`. `LoadedSpec` stores the exact resolved host path. Most importantly,
      mutating `to_json(compiled)["definition_order"]` or descriptor `meta.compiled_rule_order` mutates the live
      `CompiledSpec` vectors: neither projection is a safe foundation value. A target body that throws if run still
      parses, validates, compiles, selects, and plans successfully, proving this pipeline does not execute target
      action/lifecycle code. Julia also confirms `Bool <: Integer` but `Bool !<: Int`.

      Freeze the native surface as `semantic_index(source, options)` plus keyword convenience over copied valid
      `AbstractString` or `AbstractVector{UInt8}` input; `SemanticIndexOptions`, `SemanticSourceDetail`,
      `SemanticIndexError`, `SemanticSourceIdentity`, and `SemanticSourceSpan`; source identity/span/excerpt/exact-
      lookup accessors; and later detached `SemanticSnapshot`, `SemanticCompilationAuthority`,
      `SemanticCompilationDiagnostic`, `SemanticEntrySelection`, and `SemanticGeneratedPlanInput` accessors. The
      four ceilings are `none`, `identity`, `span`, and `text`; identity is caller logical name only, digest is over
      canonical bytes and available only at `text`, coordinates are zero-based half-open UTF-8 bytes plus one-based
      line/Unicode-scalar columns, and Boolean numeric impostors receive typed rejection. The opaque owner retains
      source/map, staged `SpecFile`, compiled state, merged function/rule authored order, entry, and plan privately;
      public results are immutable or recursively detached, debug output is identity-redacted, and no descriptor,
      AST/IR, path, source buffer, or compiler object crosses the API.

      `.10.6.2.1` owns only strict copied input, SHA-256 identity, exact map/ceilings/options/accessors, and source-
      only proof. `.10.6.2.2` then runs staged parse, validation, compile-without-duplicate-validation, entry selection,
      merged authored order, and generated-v2 planning once, rethrows fatal process exceptions, retains all other
      language failures as detached outcomes, and invokes no caller target parser/action/lifecycle/trace/diagnostic/
      observation route. Existing trusted staged frontend parsing remains compiler infrastructure; there is no
      caller source path constructor or `SpecLoader` identity. `.10.6.2.3` owns composed omission-safe signoff and
      parent closure. No new ADR is needed: this exact host projection consumes ADRs `0049`-`0051` without changing
      their neutral decisions.

      This leaf changes documentation/task/Knowledge Map material only. It implements no source map, compile
      snapshot, public query, runtime observation, fixture response, semantic rollout/admission, MCP, or Unicode
      behavior. Complete Julia remains 7,542 package assertions plus primary and corpus 105/105; Unicode remains
      806/9/8/2, semantic governance 6/20/81 at rollout 4/9 and admission 3/6, capability 80/0/0, generated source
      v1/10/80-0-0, and public surface 59/27/0. Knowledge Map 682/5,161, mdBook, memory architecture, all four
      doctrines, and diff hygiene pass. Canonical local CI passes Rust semantic admission 1/1 in 78.27 seconds,
      Dart admission 1/1, primary 66/66 under default and POSIX, and Phase 0 1,031/1,031 in 629 seconds. Cleanup
      removes the regenerated 12-MB book, 826-MB Rust dependency output, 441-MB incremental output, and 28-KB
      Python cache—about 1.28 GB—while preserving `rgx/pgen-issues/artifacts`. Strict copied input/source-map
      implementation `.10.6.2.1` remains blocked until this clean commit.
    Commit: `FUTURE-PARITY-BACKLOG.10.6.2.0 - freeze Julia semantic foundation`

    #### Acceptance Checklist

    - [x] **RETRIEVE / PRECEDENTS** — Read canonical neutral source/privacy/outcome records plus admitted Perl/Rust/
      Dart owners and exact Julia audit facts before probing or designing.
    - [x] **MEASURE JULIA AUTHORITIES** — Use Toolbox-first source/runtime probes to lock text/byte, ordering,
      failure, path, mutation, numeric-option, generated-plan, and no-execution boundaries.
    - [x] **FREEZE API / PRIVACY / SPLIT** — Record exact public/private types, ceilings, logical identity, error and
      outcome topology, and dependency-ordered `.1-.3` implementation/closeout ownership before code.
    - [x] **NO-DRIFT / DURABLE COMMIT** — Change no behavior or ledger; pass baseline/no-drift/canonical gates,
      synchronize every durable layer, clean caches, and commit before `.10.6.2.1`.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.2.1`
    Status: `done` (2026-07-22; strict copied Julia source map implemented and fully verified)
    Goal: Implement strict copied Julia semantic input policy and a private canonical byte/scalar source map.
    Depends on: `.10.6.2.0`
    Acceptance: Export idiomatic options/errors/source value types; reject invalid Julia strings, malformed bytes,
      Boolean numeric impostors, invalid options, and invalid selectors before language parsing; enforce all source
      ceilings and exact spans/excerpts/digests/lookup with detached values and no implicit path authority.
    Verification plan: Add `julia/src/semantic/SemanticIndex.jl` behind the frozen `semantic_index` surface and
      `julia/test/semantic_index_source_foundation_test.jl`. Keep construction source-only in this leaf: copy
      `String`/`SubString` and byte-vector callers, validate `isvalid` before any character iteration, use the SHA
      stdlib over canonical UTF-8 bytes, build one private boundary table, and expose only ceiling-checked detached
      source values. Prove ASCII, multibyte/supplementary/combining, CRLF, EOF, duplicate occurrence, mid-scalar,
      malformed `String`/bytes, caller mutation, invalid logical name/selector/ceiling/ranges/needles, explicit Bool
      rejection, identity-redacted display, no parser invocation, and no path/source/map leakage.
    Verification: `julia/src/semantic/SemanticIndex.jl` is included before the parser and contains no parser or
      compiler reference. It copies valid `AbstractString` or strict `AbstractVector{UInt8}` input, validates and
      copies logical identity plus the optional Unicode-17 selector, builds private tuple byte/line/scalar-column
      boundaries, and computes SHA-256 over canonical bytes. The public opaque owner, four detail ceilings, typed
      options/errors/identity/span values, detached JSON, redacted display, and exact byte/scalar span, excerpt, and
      ordered occurrence accessors expose no path, source buffer, map, parser/compiler object, record, query, or
      execution route.

      The new focused suite passes 135 assertions across exact ASCII/Unicode/CRLF/supplementary/combining/EOF and
      duplicate coordinates; decoded/byte/subview copying; exact digest; all four ceilings; malformed Julia text
      and four malformed UTF-8 byte shapes; invalid names/selectors/ceiling types; invalid, noninteger, overflowing,
      Boolean, and mid-scalar ranges; invalid needles; constructor/property/display privacy; and detached output
      mutation. Deliberately invalid grammar constructs successfully, proving the source owner does not invoke the
      language parser. Complete Julia passes 7,677 package assertions, primary process conformance, and corpus
      105/105. The primary matrix passes 5 backends x 2 environments x 66 cases and the self-hosted Unicode manifest
      passes all ten 1/1 legs. The first full-matrix attempt used an empty Julia depot and stopped at warmup before
      cases; rerunning with the documented writable-plus-existing depot stack resolved that environmental setup
      without code change. Pkg's manifest writer records project hash
      `7f888597c389b695114f2f74c96c786fd06e5168`, and `Pkg.is_manifest_current("julia")` is true.

      No-drift remains exact: Unicode 806/9/8/2; semantic 6 groups / 20 queries / 81 mutations at rollout 4/9 and
      native admission 3/6; capability 80/0/0; generated source v1 / 10 families / 80-0-0; public aggregate-selector
      surface 59 files / 27 classified history / 0 current examples. The public checker initially rejected two test
      assertions because its intentional aggregate-selector scanner read bare `hash(identifier)` as retired syntax;
      spelling those Julia equality checks as `Base.hash(..., UInt(0))` removed the lexical collision while keeping
      135 assertions and production behavior unchanged. Knowledge Map 682/5,166, mdBook, memory, task metadata, all
      four doctrines, and diff hygiene pass. Canonical local CI passes Rust semantic admission 1/1 in 78.39 seconds,
      Dart admission 1/1, primary 66/66 in both environments, and Phase 0 1,031/1,031 in 630 seconds. Exact cleanup
      removes the regenerated 12-MB book, 826-MB Rust deps, 595-MB incremental state, 130-MB temporary Julia compiled
      cache, and 28-KB Python cache—about 1.56 GB—while preserving `rgx/pgen-issues/artifacts`.
    Commit: `FUTURE-PARITY-BACKLOG.10.6.2.1 - add Julia semantic source map`

    #### Acceptance Checklist

    - [x] **REPRODUCE / ISSUE** — Use the frozen Toolbox/KM boundary plus malformed-input, privacy, coordinate, and
      deliberately invalid-grammar probes to reproduce Julia's missing strict source authority before implementation.
    - [x] **ROOT CAUSE (WHY + WHERE)** — `julia/src/semantic/SemanticIndex.jl` is the new pre-parser owner because
      Julia strings may be invalid, no canonical byte/scalar map existed, and descriptor/compiled JSON aliases live
      state; the file ordering and source scan prove no parser/compiler coupling.
    - [x] **FIX** — Add copied strict text/bytes, immutable canonical mapping, SHA-256, four ceilings, opaque typed
      values/errors, detached projections, exact accessors, and explicit Boolean/range fences behind `semantic_index`.
    - [x] **ADDRESSED (verified)** — Pass all 135 focused assertions and prove the public scanner's lexical
      `hash(identifier)` collision is removed with explicit `Base.hash`, without changing the tested API behavior.
    - [x] **NO REGRESSION** — Pass Julia 7,677/primary/105, 5x2x66, all ten Unicode-manifest legs, and exact Unicode,
      semantic, capability, generated-source, and public no-drift ledgers without semantic promotion.
    - [x] **LOCKSTEP** — Synchronize package manifest, Knowledge Map, roadmap/task/live docs, Julia README, Toolbox,
      mdBook, memory, doctrines, canonical CI, and exact safe artifact cleanup before the clean commit.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.2.2`
    Status: `done` (2026-07-22; staged compiled-or-failed Julia outcome implemented and fully verified)
    Goal: Retain opaque staged compiled-or-failed Julia authority and exact generated-plan input.
    Depends on: `.10.6.2.1`
    Acceptance: Parse staged function shells, validate, compile, merge authored function/rule order, select entry,
      and retain generated-v2 plan once; preserve native failures as deterministic outcome state, invoke no target
      parser/action/lifecycle/trace/diagnostic/observer, and expose no AST/IR/compiler/descriptor/path object.
    Verification plan: Add `julia/test/semantic_index_compilation_foundation_test.jl`; extend the same opaque owner
      with exactly one staged parse, validation, `compile_spec(...; validate_source=false)`, selection, and shared
      plan pass. Preserve exact portable diagnostics and typed fallbacks as failed-compilation values, merge function
      and rule definitions by authored source position, detach every outward value, and mechanically deny descriptor/
      JSON aliases, loader/path IO, target/generated execution, trace and diagnostic sinks, runtime observation,
      static records, and query. Rethrow only `InterruptException`, `OutOfMemoryError`, and `StackOverflowError`.
    Verification: `julia/src/semantic/SemanticCompilationOutcome.jl` extends the same opaque owner after strict
      source construction. It performs exactly one staged user-function-aware parse, validation, compile with
      duplicate validation disabled, entry resolution, and shared generated-v2 plan pass. Typed `SpecFile`,
      `CompiledSpec`, and merged function/rule authored order remain private. Public snapshot, authority,
      diagnostic, entry, plan-row, plan-input, and JSON values are immutable or freshly detached. Ordinary language
      failures retain deterministic failed-compilation state; only interrupt, memory exhaustion, and stack overflow
      rethrow. Source topology proves there is no loader/path, target/generated execution, runtime, trace,
      diagnostic/observation sink, descriptor, record, or query coupling.

      The new suite passes 85 assertions: graph snapshot/authority/entry/plan identity, equality/hash/JSON and
      mutation detachment; source-ceiling denial; explicit/marker/default entry bases; exact calls authored order
      `normalize`, `Top`, `Done`; native failed diagnostic; parse/validation/selector and compile/plan fallbacks;
      fatal classification; text/byte convergence; runtime-static no-execution; plain public JSON; forbidden host
      keys; and one-call/omission source shape. Focused source/outcome composition is 220. Complete Julia passes
      7,762 package assertions, primary process conformance, and corpus 105/105. The stable primary matrix passes
      5 backends x 2 environments x 66 cases and all ten self-hosted Unicode-manifest legs pass 1/1. One discarded
      matrix attempt had two Julia POSIX silence failures because a package docstring was edited while the matrix
      was live, triggering precompile banners on stderr; the exact root cause was reproduced, the final tree was
      warmed, and the complete stable rerun passed without semantic or trace drift.

      No-drift remains exact: Unicode 806/9/8/2; semantic 6 groups / 20 queries / 81 mutations at rollout 4/9 and
      native admission 3/6; capability 80/0/0; generated source v1 / 10 families / 80-0-0; public aggregate-selector
      surface 59 files / 27 classified history / 0 current examples. Knowledge Map 682/5,172, mdBook, memory, task
      metadata, all four doctrines, and diff hygiene pass. Canonical local CI passes Rust semantic admission 1/1 in
      82.82 seconds, Dart admission 1/1, primary 66/66 twice, and Phase 0 1,031/1,031 in 643 seconds. Exact cleanup
      removes the regenerated 12-MB book, 826-MB Rust deps, 595-MB incremental state, 130-MB temporary Julia
      compiled cache, and 28-KB Python cache—about 1.56 GB—while preserving all 517 Pgen issue artifacts.
    Commit: `FUTURE-PARITY-BACKLOG.10.6.2.2 - add Julia semantic outcomes`

    #### Acceptance Checklist

    - [x] **REPRODUCE / ISSUE** — Use neutral graph/calls/privacy/failed/runtime fixtures and the frozen Julia
      authority probes to reproduce the absence of a compiled-or-failed semantic outcome after source ownership.
    - [x] **ROOT CAUSE (WHY + WHERE)** — Prove complete authored order spans typed function and rule owners while
      compiled/descriptor JSON aliases live state, so a new detached adapter must own the outcome after strict input.
    - [x] **FIX** — Retain one staged parse/validate/compile/select/plan result privately and expose only immutable
      snapshot, authority, diagnostic, entry, and generated-plan values with deterministic fatal/failure policy.
    - [x] **ADDRESSED (verified)** — Pass all 85 new and 220 composed assertions, including exact native failures,
      authored order, ceiling/privacy, caller detachment, fatal classification, and omission-safe source topology.
    - [x] **NO REGRESSION** — Pass Julia 7,762/primary/105, stable 5x2x66, ten Unicode legs, exact no-drift ledgers,
      and canonical Rust/Dart/primary/Phase 0 without semantic promotion or generated-format change.
    - [x] **LOCKSTEP** — Synchronize Knowledge Map, roadmap/task/live docs, Julia README, Toolbox, mdBook, memory,
      doctrines, canonical proof, and exact safe cleanup before the clean commit.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.2.3`
    Status: `done` (2026-07-22; committed source/outcome composition and parent closure verified)
    Goal: Compose exact Julia source/outcome foundation signoff.
    Depends on: `.10.6.2.2`
    Acceptance: Prove graph/privacy/failure/runtime construction, text/byte convergence, malformed boundaries,
      Unicode/CRLF/duplicate coordinates, ceilings, selectors, clone/caller isolation, no-execution/host denial,
      complete Julia/canonical gates, and clean `.10.6.2` closure without records/query or promotion.
    Verification plan: Run both focused suites as one committed-code composition, all adjacent Julia source/loader/
      compiler/selector/generated/public tests, complete Julia/primary/corpus, Unicode/semantic/capability/generated/
      public no-drift, mdBook/Knowledge Map/doctrines/diff hygiene, and canonical local CI. Clean only verified
      generated book/Rust/Python caches, close `.10.6.2`, and hand off to static planning `.10.6.3.0` from a clean
      commit without another production change.
    Verification: From clean outcome commit `7c480c45`, the two committed source/outcome suites compose at 135/135
      plus 85/85 (220 total). Complete Julia passes 7,762 package assertions, primary process conformance, and
      corpus 105/105. All adjacent source, loader, compiler, selector, generated, public, diagnostic, trace, parser,
      validator, and runtime suites therefore execute with the exact committed foundation rather than a replacement
      closeout test. The stable primary matrix passes 5 backends x 2 environments x 66 cases, and the dedicated
      self-hosted Unicode manifest passes all ten backend/environment legs at 1/1.

      No-drift remains exact: Unicode 806/9/8/2; semantic 6 groups / 20 queries / 81 mutations at rollout 4/9 and
      native admission 3/6; capability 80/0/0; generated source v1 / 10 families / 80-0-0; public aggregate-selector
      surface 59 files / 27 classified history / 0 current examples. No production, test, fixture, neutral contract,
      public API, generated format, or semantic ledger changes in this closeout. Canonical local CI passes all four
      doctrines, Rust semantic admission 1/1 in 80.84 seconds, Dart admission 1/1, primary 66/66 under default and
      POSIX, and Phase 0 1,031/1,031 in 630 seconds. The committed source/outcome owner remains opaque, detached,
      path-free, record/query-free, and target-execution-free; `.10.6.2` is closed and `.10.6.3.0` is the sole next
      eligible Julia semantic leaf after this clean commit. Knowledge Map 682/5,174 and mdBook pass. Exact cleanup
      removes the regenerated 12-MB book, 826-MB Rust dependencies, 595-MB incremental state, 130-MB temporary
      Julia compiled cache, and Python bytecode—about 1.56 GB—while preserving all 517 Pgen issue artifacts.
    Commit: `FUTURE-PARITY-BACKLOG.10.6.2.3 - close Julia semantic foundation`

    #### Acceptance Checklist

    - [x] **REPRODUCE / ISSUE** — Recompose the committed 135 source and 85 outcome assertions plus all adjacent
      Julia owners, proving the parent needed one no-replacement-test signoff rather than another behavior change.
    - [x] **ROOT CAUSE (WHY + WHERE)** — Verify source mapping and compiled-or-failed outcome are separately sound
      but parent closure depends on their coexistence with complete Julia and every shared governance route.
    - [x] **FIX** — Add no production or test code; run the committed composition, complete backend, full primary,
      Unicode-manifest, no-drift, doctrine, mdBook, Knowledge Map, canonical, and cleanup topology.
    - [x] **ADDRESSED (verified)** — Pass focused 220, Julia 7,762/primary/105, stable 5x2x66, and all ten Unicode
      legs while retaining exact detached graph/privacy/failure/runtime-static foundation behavior.
    - [x] **NO REGRESSION** — Keep Unicode 806/9/8/2, semantic 6/20/81 at 4/9 + 3/6, capability 80/0/0,
      generated v1/10/80-0-0, public 59/27/0, and canonical Rust/Dart/primary/Phase 0 exact without promotion.
    - [x] **LOCKSTEP** — Synchronize parent/leaf status, roadmaps, live docs, Julia guide, Toolbox, mdBook,
      Knowledge Map, memory, doctrines, exact safe cleanup, and the clean handoff to `.10.6.3.0`.

- ID: `FUTURE-PARITY-BACKLOG.10.6.3`
  Status: `done` (2026-07-22; all five private static targets composition-closed through `.3.3` without promotion)
  Goal: Project exact private Julia static semantic graph, privacy, failure, and runtime-static state.
  Children: `.10.6.3.0`, `.10.6.3.1`, `.10.6.3.2`, `.10.6.3.3`
  Depends on: `.10.6.2`
  Acceptance: Compose detached compiled/source/diagnostic authorities into the exact neutral spec/rule/regex/edge/
    lifecycle/decision/explanation records and relations for graph, both privacy ceilings, normalized failure, and
    runtime-static absence, without public query or runtime observation.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.3.0`
    Status: `done` (2026-07-22; exact static authority/target/proof split frozen and verified from clean `121d7998`)
    Goal: Freeze Julia static projection authorities, target counts, normalization, and proof split.
    Depends on: `.10.6.2.3`
    Acceptance: Map every neutral static field/relation/evidence id to compiled/source/diagnostic authority, record
      native-to-neutral failure normalization, privacy/clone/host fences, exact five construction targets, and the
      dependency order for graph core `.1`, remaining targets `.2`, and closeout `.3` before behavior code.
    Verification plan: Retrieve the canonical neutral static targets and admitted Perl/Rust/Dart authority maps
      through the Knowledge Map before probing Julia. Use Toolbox-first source/descriptor/compiler diagnostics to
      map every v1 record, relation, source reference, evidence id, ordering rule, privacy ceiling, and failure
      normalization onto the committed opaque Julia source/outcome owner. Freeze exact graph-core `.1`, remaining-
      target/isolation `.2`, and no-promotion closeout `.3` ownership without production, test, fixture, API,
      generated-format, query, runtime-observation, or semantic-ledger change; then run baseline/no-drift/canonical
      documentation gates and commit before implementation.
    Audit evidence: Knowledge retrieval covers ADR `0049`, the neutral contract/static-rule authority, all three
      admitted backend authority maps, and their private static projectors before Julia probing. The exact target
      inventory is graph 12 records / 14 relations, Unicode privacy `text` 4/3, the same privacy fixture at
      `identity` 4/3, failed compilation 6/4, and runtime-static 7/8 after removing one execution, three events,
      every relation touching them, and resetting `has_execution=false`.

      The committed opaque Julia foundation already owns every required input without another parser pass. Copied
      source, caller logical identity, SHA-256, and `_SemanticSourceMap` own source records/references. Parsed
      `SpecFile`/`RuleHeader`/grouped `BodyElement` occurrences own authored order, complete member spelling,
      explicit target indices, entry markers, and lifecycle occurrence order. Typed `CompiledSpec`/`CompiledRule`
      own compiled order, accepted mode, structural slots, resolved edges, payload presence, Action AST return
      shapes, and lifecycle payload identity. Detached entry selection owns root/basis. Native
      `SemanticCompilationDiagnostic` owns failure input. A direct cross-check reproduces all 14 neutral source
      references exactly through the current Julia map, including UTF-8 bytes, Unicode-scalar columns, excerpts,
      and digests.

      Two native-to-neutral rules are explicit rather than inferred. Julia's `Default` mode reports native
      repetition with `rep_min=0`, but neutral v1 treats `Default`, `And`, `Single`, and `Pipe` as non-repeating
      with null bounds. Also, compiled regex vectors include parent matchers attached to cross-rule action edges:
      graph Top compiles two `a` patterns, but only Child's two structural slots become records. Self-indexed
      runtime matchers remain Top slots. Projection must therefore group elements by authored line, scan the full
      trimmed member/multiline block, retain ordinary or self-indexed structural slots, and correlate them to typed
      compiled owners; it cannot enumerate compiled patterns or serialize short element fragments directly.

      Graph relations are exact `declares`, `contains`, `dispatches_to`, `selects_regex`, and two `explained_by`
      entry relations whose evidence is `rule:Top`. Runtime-static retains two self `selects_regex` relations but
      no redundant self `dispatches_to`. Failed validation occurs before the foundation authored-definition tuple
      is populated, so its spec/rule order comes from parsed rules. The foundation keeps
      `bare_edge_target_undefined` / `normalize_edges`, `rule_label=Top`, `target=Missing`; projection alone maps
      it to `unknown_rule_reference` / `compile`, neutral ids/message/fields, dependency decision, one explanation,
      `diagnoses`, and `explained_by` with `diagnostic:compile:0` evidence.

      Stable ids use uppercase percent-escaped UTF-8 bytes; records and relations use the closed neutral kind ranks.
      Private storage is recursively immutable and every oracle/query copy fresh and detached. No public projection
      accessor is added: a later query leaf alone applies requested source detail beneath the immutable construction
      ceiling. `SpecFile`, `CompiledSpec`, AST/ActionIR, regex objects, descriptors, generated implementation, path,
      executor, trace, diagnostic sink, and runtime observer state are forbidden. Implementation remains graph/
      source/evidence `.1`, privacy/failure/runtime-static plus clone/repeated-lifecycle/host denial `.2`, then
      committed composition `.3`. No behavior or semantic ledger changes in this plan.

    Verification: **PASS 2026-07-22.** Direct Julia authority probes freeze all five exact targets and reproduce
      all 14 neutral source references. Committed source 135 plus outcome 85 pass together at focused 220; complete
      Julia passes 7,762 package assertions, primary process, and corpus 105/105. The full primary matrix passes
      5 backends x 2 environments x 66 cases, and the Unicode manifest passes all ten 1/1 legs. Unicode remains
      806/9/8/2; semantic governance remains 6/20/81 at rollout 4/9 and native admission 3/6; capability/generated/
      public remain 80/0/0, v1/10/80-0-0, and 59/27/0. Knowledge Map 683/5,188, mdBook build, memory, all four
      doctrines, and diff hygiene pass. Canonical local CI passes Rust semantic admission 1/1 in 78.75 seconds,
      Dart admission 1/1, primary 66/66 twice, and Phase 0 1,031/1,031 in 632 seconds. Exact safe cleanup removes
      the 12-MB book, 826-MB Rust dependencies, 596-MB incremental state, 130-MB Julia compiled cache, and Python
      bytecode—about 1.56 GB—while preserving all 517 Pgen issue artifacts. No production, test, fixture, public
      API, format, query, trace, observation, rollout, or admission behavior changes.
    Commit: `FUTURE-PARITY-BACKLOG.10.6.3.0 - freeze Julia static projection`

    #### Acceptance Checklist

    - [x] **RETRIEVE / TOOLBOX FIRST** — Read the neutral and admitted static authority cards/ADR/projectors before
      running Julia source/outcome, parsed, compiled, entry, diagnostic, and source-reference probes.
    - [x] **EXACT TARGETS** — Freeze graph 12/14, privacy text 4/3, privacy identity 4/3, failed 6/4, and runtime-
      static 7/8 with exact snapshot, record/relation, source, order, and absence semantics.
    - [x] **ROOT CAUSE / NORMALIZATION** — Record the native Default-versus-neutral repetition mismatch, compiled
      parent-matcher slot overcount trap, full-member source correlation, and deliberate failed-diagnostic mapping.
    - [x] **PRIVACY / ISOLATION** — Freeze construction ceilings, detached immutable copies, and host/path/AST/IR/
      descriptor/generated/executor/trace/sink/observer denial without exposing projection/query.
    - [x] **DEPENDENCY SPLIT** — Assign exact graph `.1`, remaining targets/isolation `.2`, and composed no-promotion
      closeout `.3` before production or test changes.
    - [x] **SIGNOFF / LOCKSTEP** — Pass unchanged Julia/semantic/no-drift/canonical documentation gates, synchronize
      roadmaps/live docs/mdBook/Knowledge Map/memory, clean safe artifacts, and commit before `.10.6.3.1` activation.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.3.1`
    Status: `done` (2026-07-22; exact private graph/source/evidence projection verified from clean `99795ddf`)
    Goal: Implement the private Julia compiled graph/source/evidence projection.
    Depends on: `.10.6.3.0`
    Acceptance: Materialize exact graph records/relations in canonical order from compiled rule/family/cursor/
      repetition/slot/edge/lifecycle plus correlated source authorities; deep-equal the neutral graph target while
      exposing no public query, host object, mutable owner state, path, generated source, or execution authority.
    Implementation: `SemanticIndex` now retains one recursively immutable private `_SemanticStaticProjection`
      built from its existing copied source/map, single staged compilation outcome, selected-entry snapshot, and
      typed parsed/compiled owners. The graph projector scans complete authored members, including balanced
      multiline blocks, then correlates ordinary/self-indexed regex slots, typed action/blind edges, lifecycle
      payloads, entry decisions, explanations, and exact source evidence. It normalizes Default/And/Single/Pipe
      as neutral non-repetition, excludes cross-rule parent matchers from structural slot rows, percent-escapes
      strict UTF-8 ids with uppercase hex, and canonicalizes all record/relation ordering. No second parse,
      target execution, path read, descriptor/compiled JSON clone, public accessor, query, trace, runtime
      observation, generated-format change, rollout movement, or native admission is introduced. A private
      underscore-only test seam returns a fresh detached plain-data copy; production storage remains tuple-backed
      and recursively immutable.
    Verification: **PASS 2026-07-22.** New omission-sensitive proof passes 70 assertions and deep-equals the full
      neutral graph after source materialization: exactly 12 records, 14 relations, seven correlated source
      references, two Child slots, two Top edges, one lifecycle, and exact entry decision/explanations. It proves
      the compiled Top parent-matcher overcount is excluded, Child duplicates remain distinct, neutral default
      repetition is false, every span/excerpt/digest is exact, detached mutations cannot alias retained state,
      internal tuples reject mutation, and no public accessor/export or forbidden host owner leaks. Focused source/
      outcome/graph composition is 290; complete Julia is 7,832 package assertions plus primary process and corpus
      105/105. The full primary matrix passes 5x2x66 and all ten Unicode-manifest legs pass 1/1. Unicode remains
      806/9/8/2; semantic remains 6/20/81 at rollout 4/9 and admission 3/6; capability/generated/public remain
      80/0/0, v1/10/80-0-0, and 59/27/0. Canonical CI passes four doctrines, Rust admission 1/1 in 78.38 seconds,
      Dart admission 1/1, primary 66/66 twice, and Phase 0 1,031/1,031 in 641 seconds. mdBook, Knowledge Map
      683/5,196, memory/task metadata, diff hygiene, and exact 1.56-GB cleanup preserve all 517 Pgen artifacts.
    Commit: `FUTURE-PARITY-BACKLOG.10.6.3.1 - add Julia static graph`

    #### Acceptance Checklist

    - [x] **EXACT PRIVATE GRAPH** — Retain canonical 12-record/14-relation graph data behind the opaque index with
      stable ids, snapshots, records, relations, decisions, explanations, and evidence.
    - [x] **AUTHORITY CORRELATION** — Compose copied source/map, parsed complete members, typed compiled owners,
      selected entry, and source evidence without another parse or descriptor/compiled JSON authority.
    - [x] **NORMALIZATION / ROOT CAUSE** — Exclude cross-rule parent matchers, retain duplicate/self-indexed slots,
      and normalize Default/And/Single/Pipe repetition exactly as neutral v1 requires.
    - [x] **IMMUTABILITY / PRIVACY** — Keep retained data recursively immutable and private; return only fresh
      detached test copies and expose no path, host AST/IR/compiler/regex, generated source, query, or execution.
    - [x] **EXACT ORACLE / NO REGRESSION** — Deep-equal graph 12/14 with seven exact source references; pass new
      70, focused 290, Julia 7,832/primary/105, 5x2x66, ten Unicode legs, and unchanged governance ledgers.
    - [x] **LOCKSTEP / COMMIT** — Synchronize task/live/roadmap/book/Knowledge Map/memory, pass canonical CI and
      doctrines, clean only safe generated artifacts, preserve 517 Pgen artifacts, and commit before `.3.2`.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.3.2`
    Status: `done` (2026-07-22; exact remaining static targets/isolation verified from clean `197538f7`)
    Goal: Complete Julia privacy, normalized failure, runtime-static absence, and isolation targets.
    Depends on: `.10.6.3.1`
    Acceptance: Deep-equal full/limited privacy, failed compilation, and runtime-static targets; enforce source
      ceilings before projection leaves, preserve native failure foundation while normalizing neutral evidence, and
      prove recursive deep-copy/immutability plus host/path/AST/IR/compiler/execution denial.
    Implementation: The compiled projector already honored both construction ceilings and runtime-static omission;
      this leaf locks those exact targets and adds the missing failed-compilation projector. Failed construction
      recovers authored rule order and header evidence from the retained parsed owner, preserves the native
      `bare_edge_target_undefined` / `normalize_edges` diagnostic on the foundation, and privately maps only the
      semantic projection to portable `unknown_rule_reference` / `compile`, rule ids, dependency decision,
      explanation, `diagnoses`, `explained_by`, and exact target-member evidence. Other parse, validation, compile,
      selection, and generated-plan failures retain their native detached diagnostic through a generic three-record
      or parsed-rule fallback. No public accessor, query, trace, runtime observation, target execution, path read,
      generated-format change, rollout movement, or native admission is introduced.

      Exact proof deep-equals privacy `text` 4/3, privacy `identity` 4/3, failed 6/4, and runtime-static 7/8. It
      confirms source ceilings and digest availability, Unicode byte/scalar evidence, native-versus-neutral failure
      separation, execution/event/`observed_as` absence, two self-indexed runtime slots without redundant self
      dispatch, two repeated lifecycle occurrences with distinct ids/order/value shapes/source, fresh detached
      copies, tuple-backed retained immutability, plain JSON values, host-path denial, parse/missing-entry fallback,
      private-test-seam omission, and forbidden loader/emitter/executor/trace/sink/observer/environment/time/random
      dependencies.
    Verification: **PASS 2026-07-22.** New remaining-target/isolation proof passes 99 assertions; committed source
      135 + outcome 85 + graph 70 + remaining 99 compose at focused 389. Complete Julia passes 7,931 package
      assertions, primary process conformance, and corpus 105/105. The full primary matrix passes 5x2x66 and all ten
      Unicode-manifest legs pass 1/1. Unicode remains 806/9/8/2; semantic remains 6/20/81 at rollout 4/9 and native
      admission 3/6; capability/generated/public remain 80/0/0, v1/10/80-0-0, and 59/27/0. Canonical local CI
      passes all four doctrines, Rust semantic admission 1/1 in 78.27 seconds, Dart admission 1/1, primary 66/66
      twice, and Phase 0 1,031/1,031 in 697 seconds. mdBook, memory/task metadata, Knowledge Map 683/5,207, diff hygiene, and
      exact safe cleanup of the 12-MB book, 824-MB Rust dependencies, 590-MB incremental state, 131-MB Julia cache,
      and Python bytecode pass while preserving all 517 Pgen artifacts.
    Commit: `FUTURE-PARITY-BACKLOG.10.6.3.2 - complete Julia static targets`

    #### Acceptance Checklist

    - [x] **EXACT REMAINING TARGETS** — Deep-equal privacy text 4/3, privacy identity 4/3, failed 6/4, and runtime-
      static 7/8 with exact snapshots, records, relations, source evidence, order, and omission semantics.
    - [x] **FAILURE NORMALIZATION** — Preserve Julia's native diagnostic foundation while privately projecting the
      portable unknown-rule diagnostic, decision, explanation, relations, evidence, and parsed-rule fallback.
    - [x] **NO EXECUTION / LIFECYCLE IDENTITY** — Prove runtime-static has no execution/event/observed state and
      repeated lifecycle occurrences retain distinct ids, order, value shapes, sources, and containment.
    - [x] **IMMUTABILITY / HOST DENIAL** — Prove fresh detached JSON copies, tuple-backed retained storage, ceiling
      enforcement, private seam omission, and no path/AST/IR/compiler/loader/generated/executor/trace/sink/observer
      or nondeterministic host authority.
    - [x] **NO REGRESSION / NO PROMOTION** — Pass new 99, focused 389, Julia 7,931/primary/105, 5x2x66, ten Unicode
      legs, and unchanged Unicode/semantic/capability/generated/public ledgers without API or format movement.
    - [x] **LOCKSTEP / COMMIT** — Synchronize task/live/roadmap/book/Knowledge Map/memory, pass canonical CI and all
      doctrines, remove only safe generated artifacts, preserve 517 Pgen artifacts, and commit before `.3.3`.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.3.3`
    Status: `done` (2026-07-22; verified no-change composition candidate from clean `.3.2` commit `556e5ae2`)
    Goal: Compose and close exact Julia private static projection.
    Depends on: `.10.6.3.2`
    Acceptance: Re-run all five targets and topology/isolation proof with complete Julia/neutral/canonical/docs/KM/
      cleanup gates; close `.10.6.3` without public query, runtime observation, or ledger promotion.
    Verification plan: Re-run the four committed source/outcome/graph/remaining suites together and prove exact
      graph 12/14/7, privacy 4/3 + 4/3, failed 6/4, runtime-static 7/8, lifecycle/clone/fallback/host isolation,
      and public omission without replacement production or test code. Then run complete Julia package/primary/105,
      five-backend primary and Unicode matrices, every no-drift ledger, canonical local CI, mdBook, Knowledge Map,
      memory/task/doctrines/diff, and exact safe cleanup. Close parent `.10.6.3`, record `.10.6.4.0` as the next
      dependency-eligible behavior-free calls/staging plan, and commit before activation.
    Implementation: No production, test, fixture, contract, API, or generated-format file changes. The closeout
      deliberately recomposes the four committed source/outcome/graph/remaining suites and their complete gates
      rather than creating a second projector or replacement proof topology.
    Verification: PASS. The four committed suites compose at focused 389 and reconfirm graph 12/14/7, privacy
      text 4/3, privacy identity 4/3, failed 6/4, runtime-static 7/8, occurrence identity, detached/immutable copies,
      fallback, public omission, and host denial. Complete Julia passes 7,931 package assertions, primary process
      conformance, and corpus 105/105; the primary matrix passes 5 backends x 2 environments x 66 cases and all
      ten Unicode-manifest legs pass. Unicode stays 806/9/8/2; semantic stays 6/20/81 at rollout 4/9 and admission
      3/6; capability/generated/public stay 80/0/0, v1/10/80-0-0, and 59/27/0. Canonical local CI passes Rust
      semantic admission in 80.89 seconds, Dart 1/1, primary 66x2, and Phase 0 1,031/1,031 in 653 seconds.
      mdBook, Knowledge Map 683/5,210, memory/task/doctrines/diff hygiene, and exact 1.56-GB safe cleanup preserving
      517 Pgen artifacts complete the proof; no query, runtime observation, rollout, or admission is promoted.
    Commit: `FUTURE-PARITY-BACKLOG.10.6.3.3 - close Julia static projection`

    #### Acceptance Checklist

    - [x] **COMMITTED RECOMPOSITION** — Run the exact four committed Julia semantic suites together at focused 389;
      do not add replacement projector code or tests in this closeout.
    - [x] **ALL FIVE TARGETS** — Reconfirm graph 12/14/7, privacy 4/3 + 4/3, failed 6/4, runtime-static 7/8, exact
      source ceilings/evidence/order, projection-only failure normalization, and observation-free construction.
    - [x] **ISOLATION / PUBLIC FENCE** — Reconfirm lifecycle occurrence identity, detached copies, tuple immutability,
      generic failure fallback, private seam omission, and host/path/AST/IR/compiler/execution denial.
    - [x] **NO REGRESSION / NO PROMOTION** — Pass complete Julia/105/primary, both five-backend matrices, and all
      Unicode/semantic/capability/generated/public no-drift ledgers without API, format, rollout, or admission change.
    - [x] **LOCKSTEP / PARENT CLOSURE** — Pass canonical/docs/KM/memory/doctrines/diff/cleanup, close `.10.6.3`,
      hand off `.10.6.4.0`, commit, clear the brief, and verify a clean tree before activation.

- ID: `FUTURE-PARITY-BACKLOG.10.6.4`
  Status: `done` (2026-07-23; exact private typed core `.1`, staged/generated completion `.2`, and committed-proof
    composition closeout `.3` pass through the verified closeout candidate from clean `cc229cc5`)
  Goal: Project exact Julia functions, helpers, calls, bindings, staged provenance, and generated plan.
  Children: `.10.6.4.0`, `.10.6.4.1`, `.10.6.4.2`, `.10.6.4.3`
  Depends on: `.10.6.3`
  Acceptance: Merge separate staged function shells with rules into authored order, correlate local action spans to
    canonical source, resolve user/helper calls and bindings, derive conservative shapes, distinguish staged
    payload/job/result, and project selected generated-v2 provenance at exact 22-record/25-relation parity.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.4.0`
    Status: `done` (2026-07-22; behavior-free exact 22/25 authority/split plan verified from clean `4a580295`)
    Goal: Freeze Julia calls/staging/generated authorities and exact dependency split.
    Depends on: `.10.6.3.3`
    Acceptance: Map typed function registry/action AST/contracts, staged source spans/payload/jobs/results, compiled
      rule-only order, source correlation, call resolution/shape policy, generated plan, host/privacy fences, exact
      22/25 target, and core `.1` / completion `.2` / closeout `.3` before production changes.
    Verification plan: Retrieve the neutral calls/staging/generated target, ADR `0050`, and admitted Perl/Rust/Dart
      authority maps through the Knowledge Map before Julia probing. Use Toolbox-first typed/source/descriptor/plan
      probes to map authored function/rule order, registry definitions, parameter/rest bindings, nested user/helper
      calls, contracts and conservative shapes, action-local to canonical source correlation, staged payload/job/
      result identities, selected generated-v2 plan provenance, ordering, privacy ceilings, and host-denial fences.
      Freeze the exact 22-record/25-relation target plus `.1` core, `.2` completion, and `.3` no-change closeout
      ownership without production, test, fixture, API, query, runtime-observation, generated-format, or semantic-
      ledger change. Then run the committed focused static foundation, complete Julia/primary/105, both five-backend
      matrices, all no-drift ledgers, canonical local CI, mdBook, Knowledge Map, memory/task/doctrines/diff, exact
      safe cleanup, and commit before `.10.6.4.1` activation.

    #### Acceptance Checklist

    - [x] **RETRIEVE FIRST** — Retrieved neutral, ADR, and admitted Perl/Rust/Dart calls/staging/generated authorities
      from durable cards before Julia probes; record any newly established Julia structural facts as cards.
    - [x] **JULIA AUTHORITY MAP** — Proved exact authored order, typed definitions/calls/contracts, local/global source
      correlation, staged sidecars, generated plan, resolution/shape policy, and privacy/host boundaries.
    - [x] **EXACT TARGET / SPLIT** — Froze all 22 records / 25 relations, canonical ids/order/evidence, omissions,
      and dependency-complete `.1` typed core / `.2` staged-generated completion / `.3` composition ownership.
    - [x] **NO BEHAVIOR / NO PROMOTION** — Changed no production/test/fixture/API/query/format/observation/ledger state;
      pass focused Julia foundation, complete Julia/105/primary, both matrices, and every no-drift checker.
    - [x] **LOCKSTEP / COMMIT** — Synchronized task/live/roadmap/book/Toolbox/Knowledge Map/memory, passed canonical CI
      and all doctrines, remove only safe generated artifacts, preserve 517 Pgen artifacts, and commit before `.1`.

    #### Authority Audit Evidence (2026-07-22)

    Retrieval followed the Knowledge Map before any fresh Julia derivation:

    - neutral `calls` snapshot and fixture `calls_and_staging` from
      `capability_conformance/semantic_introspection_model.json`;
    - ADR `0050` plus the staged-artifact and generated-plan authority cards; and
    - admitted Perl, Rust, and Dart calls/staging/generated projections, including their source-correlation traps,
      typed-resolution order, conservative shape policy, staged normalization, and generated-plan selection.

    The exact neutral target is compiled, `text`-ceiling, and observation-free at 22 records / 25 relations. Record
    kinds total spec 1, source 1, rule 2, regex slot 1, edge 1, function 1, helper 3, binding 1, call 4, staged
    artifact 3, generated artifact 1, decision 1, and explanation step 2. The already-committed Julia static
    projection contributes 6/6. Filtering only staged and generated artifacts plus their nine relations yields the
    exact typed core at 18/16. Completion adds payload/job/result plus the selected handler plan and exactly three
    function-containment, five staging-chain, and one `generated_as` relation.

    Direct Toolbox probes establish these Julia-native owners and normalizations:

    - `_semantic_authored_definition_order` reports `normalize`, `Top`, `Done`, while both
      `CompiledSpec.definition_order` and `compiled_rule_order` intentionally contain only `Top`, `Done`; merged
      exact source starts are therefore authoritative for top-level semantic definition order.
    - The accepted registry definition owns name `normalize`, parameter `value`, arity 1, exact shell source, body
      source, staged payload/job/result maps, and a line-only `SourceSpan`. Its job owns global decoded-scalar body
      range 21..42. `parse_action_block(body_source)` yields typed `ActionBlock`; its JSON exactly equals retained
      `body_ast`, and `resolve_action_block_contracts` resolves `return`/control and `trim`/string successfully.
      The retained `body_ast` map is an integrity input, not typed or outward semantic authority.
    - The compiled Top edge owns typed assignment, outer `normalize`, nested `match_text`, and `return` nodes.
      Contract resolution classifies set, user function, entry-match helper, and control helper. Exact registered
      user functions resolve before the governed helper fallback.
    - `ActionSourceSpan` counts Unicode scalars local to normalized action text. Compiled edge normalization removes
      indentation, so local offsets cannot be added to raw edge starts. Exact source requires typed outer-before-
      inner traversal plus occurrence-safe balanced scanning inside the bounded authored shell or edge.
    - All nine distinct neutral source ranges reproduce exactly from Julia's retained source map: function 0..43,
      trim 29..40, Top 45..50, edge 52..122, normalize 78..101, match 88..100, return 105..119, Done 124..129,
      and Done regex 131..134. Binding and normalize-call keys deliberately share the normalize range.
    - An interleaved Unicode probe retains authored `Top`, `normalize`, `Done` order, exact function/edge source,
      no false function rule member, global function-body scalar range 100..119, byte range 100..120, columns
      22..41, typed staged equality, and exact local `trim("é")` span. Thus byte width and Unicode-scalar columns
      diverge safely without changing identity.
    - Function-surface `return` is syntax and only its argument `trim` becomes a call record. Edge `return` is a
      helper. Deterministic traversal is authored definitions, statements, then outer call before nested arguments;
      record order is global while ids are local to each owner.
    - Exact neutral helper authority is deliberately narrow: `trim`, `match_text`, and `return` only, with governed
      signatures/effects/return shapes. Conservative fixed-point shapes use typed literals, current bindings,
      registered function returns, and this table; unsupported meaning remains `unknown`. Fixed-arity v1 definitions
      derive signatures from params/arity; native variadic `CallableSignature` maps positional/rest/min/max without
      inventing a bounded maximum.
    - Native staged fields are `function_definition` / `function_body`, `functions/0/body_source`,
      `actionir-body.spec`, `action_block`, `replace_field/body_ast`, and `fail`. ADR `0050` deliberately normalizes
      them to payload/action-source/string, job/action-program/unknown, result/action-program/unknown, parent
      `function:normalize`, parser `linkedspec-action-v1`, top `FunctionBody`, result `typed_action_program`, failure
      `compile_diagnostic`, and succeeded only after typed equality plus contract proof. No source, maps, JSON AST,
      or ActionIR leaves the owner.
    - Retained `SemanticGeneratedPlanInput` is contract `linkedspec-generated-source-v2`, format 2, caller logical
      identity, and ordered `Top/default`, `Done/default` rows. Projection validates all rows against compiled order
      and selects the unique entry row; it neither invents `and_acode` nor invokes source emission or execution.

    The implementation split is frozen as follows:

    - `.10.6.4.1` owns production `julia/src/semantic/SemanticCallProjection.jl`, private integration before the
      existing static freeze, typed functions/helpers/calls/bindings, exact 18/16 equality, merged authored order,
      occurrence-safe Unicode source evidence, user-before-helper resolution, fixed-point shapes, variadic-signature
      normalization, clone/immutability, host denial, and focused `semantic_index_call_core_test.jl`.
    - `.10.6.4.2` extends the same production owner with three normalized staged artifacts and selected generated
      plan, exact 22/25 equality/directions, typed-staging integrity, implementation/source/AST privacy, no execution,
      and focused `semantic_index_call_staged_generated_test.jl`.
    - `.10.6.4.3` adds no production or replacement test owner. It recomposes the committed source, outcome,
      static, core-call, and staged/generated suites under complete gates and closes parent `.10.6.4` without
      public record/query access, runtime observation, generated-format change, rollout, or native admission.

    Durable structural conclusions live in `docs/knowledge/julia-semantic-call-staged-projection-plan.md` and the
    extended Julia authority map. No fishy runtime result or new scope was found; the target is additive over the
    closed private static surface and needs no trace-derived fact.

    #### Verification Result (2026-07-22)

    PASS from clean base `4a580295`. The four committed semantic source/outcome/static suites pass together at
    focused 389. Complete Julia remains 7,931 package assertions, primary process conformance, and corpus 105/105.
    The full primary matrix passes 5 backends x 2 environments x 66 cases; the dedicated self-hosted Unicode
    manifest passes all ten legs at 1/1. Unicode remains 806 ranges / 9 positives / 8 negatives / 2 distinct pairs;
    semantic governance remains 6 groups / 20 queries / 81 mutations at rollout 4/9 and admission 3/6;
    capability/generated/public remain 80/0/0, v1/10/80-0-0, and 59/27/0.

    Canonical local CI passes all four doctrines, Rust semantic admission 1/1 in 77.84 seconds, Dart admission 1/1,
    reference primary 66/66 twice, and Phase 0 1,031/1,031 in 625 seconds. The canonical `mdbook build` passes;
    Knowledge Map is synchronized at 684 facts / 5,231 question keys. Memory/task metadata, required markers, and
    diff hygiene pass. Exact safe cleanup removes the 12-MB generated book, 826-MB Rust dependency outputs,
    596-MB Rust incremental state, 131-MB temporary Julia compiled cache, and Python bytecode—about 1.56 GB—while
    preserving all 517 Pgen issue artifacts. No production/test/fixture/API/query/format/trace/observation/ledger
    behavior changes. Commit subject: `FUTURE-PARITY-BACKLOG.10.6.4.0 - freeze Julia call projection`.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.4.1`
    Status: `done` (2026-07-22; exact private 18/16 implementation committed cleanly at `9ec3f034`)
    Goal: Implement typed Julia function/helper/call/binding core projection.
    Depends on: `.10.6.4.0`
    Acceptance: Project authored function/rule order, definitions, parameters/rest bindings, nested calls, exact
      user-before-helper resolution, local-to-global Unicode source evidence, and conservative input/result shapes;
      deep-equal the non-staged neutral subset with no staged/generated/runtime or host-IR leakage.
    Verification plan: Add the private production owner `julia/src/semantic/SemanticCallProjection.jl` and compose
      it before the existing static projection freeze. Use only accepted registry definitions, reparsed typed
      function-body Action AST checked against retained staged JSON, compiled edge Action AST, resolved contracts,
      and copied source evidence. Add focused `julia/test/semantic_index_call_core_test.jl` proving exact 18/16
      equality, merged authored order, outer-before-inner calls, user-before-helper resolution, conservative shape
      fixed point, fixed/rest signatures, occurrence-safe Unicode source correlation, immutable/detached lifecycle,
      no staged/generated roles, private/public/host denial, and no target execution. Then run the committed four
      semantic suites plus the new suite, complete Julia/primary/105, both five-backend matrices, all governance
      ledgers, canonical local CI, mdBook/Knowledge Map/doctrines/diff, exact safe cleanup, and commit before `.2`.

    #### Acceptance Checklist

    - [x] **TYPED PRIVATE OWNER** — Project accepted definitions, parameters/rest bindings, typed function/edge
      Action AST, resolved contracts, decisions, explanations, helpers, calls, and bindings without another spec
      parse, target execution, trace dependency, or public accessor.
    - [x] **EXACT 18/16 CORE** — Deep-equal the neutral non-staged subset at exactly 18 records / 16 relations with
      deterministic ids/order/evidence and explicit omission of all staged/generated records and relations.
    - [x] **SOURCE / UNICODE** — Merge exact authored function/rule positions and map normalized local scalar spans
      through bounded occurrence-safe raw-source correlation, including interleaved multibyte and duplicate-call
      evidence without byte/scalar or member-identity drift.
    - [x] **RESOLUTION / SHAPES / ISOLATION** — Prove user-before-helper resolution, exact governed helpers,
      conservative fixed-point shapes and signatures, clone/immutability, lifecycle identity, host denial, and no
      compiler ActionIR/registry/source-map leakage.
    - [x] **LOCKSTEP / COMMIT** — Pass focused and complete Julia, both matrices, all no-drift ledgers, canonical CI,
      mdBook/KM/memory/task/doctrines/diff and safe cleanup; synchronize durable layers and commit before `.2`.

    #### Verification Result (2026-07-22)

    PASS from clean plan commit `3ee4b908`. New private production owner
    `julia/src/semantic/SemanticCallProjection.jl` composes before static canonicalization/freeze and deep-equals
    the exact non-staged neutral target at 18 records / 16 relations / 10 source references. Accepted typed
    function/edge Action AST owns meaning; reparsed function payload equals retained staged JSON and all contracts
    resolve. Exact authored definition order, outer-before-inner local/global call order, user-before-helper
    resolution, fixed/rest signatures, conservative function/binding/edge/rule shapes, decision/explanations, and
    source evidence are exact. The bounded raw-source correlator skips quoted strings and regex literals, including
    a regression where `/trim(fake())/i` precedes the real `trim(value)` occurrence. Staged/generated roles remain
    absent. Retained values are tuple-backed; copies are detached/plain; public/path/AST/IR/compiler/runtime/trace/
    sink/observer/environment/time/random and target-execution surfaces remain denied.

    The new suite passes 79 assertions and the five semantic suites pass 468. Complete Julia passes 8,010 package
    assertions, primary process conformance, and corpus 105/105. The full primary matrix passes 5 backends x 2
    environments x 66 cases; all ten Unicode-manifest legs pass 1/1. Unchanged ledgers pass at Unicode 806/9/8/2,
    semantic 6/20/81 with rollout 4/9 and admission 3/6, capability 80/0/0, generated v1/10/80-0-0, and public
    59/27/0. Canonical local CI passes all four doctrines, Rust semantic admission 1/1 in 77.41 seconds, Dart 1/1,
    reference primary 66/66 twice, and Phase 0 1,031/1,031 in 622 seconds. mdBook, Knowledge Map, memory/task
    metadata, markers, and diff hygiene pass at KM 685/5,252. Exact safe cleanup removes 1,618,660 KiB while
    preserving all 517 Pgen artifacts. No public query, runtime observation, generated format, semantic rollout,
    or native admission changes. Commit subject:
    `FUTURE-PARITY-BACKLOG.10.6.4.1 - add Julia typed call core`.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.4.2`
    Status: `done` (2026-07-22; complete exact private 22/25 committed cleanly at `cc229cc5`)
    Goal: Complete Julia staged payload/job/result and generated-plan semantic provenance.
    Depends on: `.10.6.4.1`
    Acceptance: Add distinct staged artifact records/relations from typed sidecars and one selected generated-v2
      plan artifact; deep-equal all 22 records/25 relations while excluding body AST, generated implementation text,
      paths, execution, trace, diagnostics, and mutable compiler state.
    Verification plan: Extend the one private `SemanticCallProjection.jl` owner after its typed core and before the
      existing canonicalize/freeze boundary. Validate each accepted function's typed payload/job fields against its
      definition/body authority and emit the neutral payload/parse-job/result records plus exact contains,
      consumes, produces, lowered-from, and staged-by directions. Validate the retained generated-v2 plan's
      contract, format, caller logical identity, complete compiled label order, and unique selected entry row;
      project only its neutral handler family without invoking an emitter or retaining implementation text. Add a
      focused exact 22/25 test over the committed 18/16 core, sidecar normalization, source provenance,
      selected-row rejection, lifecycle detachment, privacy/host/no-execution fences, and then run complete
      Julia/matrices/Unicode/governance/canonical/docs/KM/cleanup before `.3`.

    #### Acceptance Checklist

    - [x] **DISTINCT STAGED ROLES** — Validate typed native function payload/job/result authority and emit separate
      neutral payload, parse-job, and result records with exact facts, owner/source, order, and status.
    - [x] **DIRECTED PROVENANCE** — Add the three function contains relations and exact consumes, produces,
      lowered-from, and staged-by directions without collapsing roles or leaking payload/job/body-AST values.
    - [x] **SELECTED GENERATED PLAN** — Validate retained generated-v2 contract/format/logical identity/full rule
      order and project the unique selected entry family as one handler-plan artifact plus `generated_as`.
    - [x] **EXACT 22/25 / ISOLATION** — Deep-equal all 22 records / 25 relations with detached immutable plain data,
      family/sidecar rejection coverage, and no path, host IR, generated source, target execution, trace, or sink.
    - [x] **LOCKSTEP / COMMIT** — Pass focused/complete Julia, both primary matrices, ten Unicode legs, all no-drift
      ledgers, canonical CI, mdBook/KM/memory/task/doctrines/diff, exact safe cleanup, and commit before `.3`.

    #### Verification Result (2026-07-22)

    PASS from clean typed-core commit `9ec3f034`. The existing private `SemanticCallProjection.jl` owner now
    validates native function payload and typed parse-job fields against the accepted definition, exact body/span,
    fixed or variadic signature, parser/top-rule intent, stitch/failure policy, and retained body result before
    emitting distinct neutral payload, parse-job, and result records. Their three contains relations plus exact
    consumes, produces, two lowered-from, and staged-by directions preserve provenance without exposing native
    payload/job/body-AST or typed ActionIR values.

    The same owner validates the retained generated-v2 contract, format, caller logical identity, complete compiled
    label order, and unique selected entry row. It emits only one neutral handler-plan record with the retained
    `default` family and one `generated_as` relation; it never calls the plan builder, emitter, generated loader/
    executor, runtime, trace, diagnostic sink, or observer. Corrupt payload/job state and plan contract/identity/
    order/selection fail through typed semantic correlation errors. Complete projection equality is exact at 22
    records / 25 relations / 10 source references with detached plain copies, tuple-backed retention, private
    surface omission, and host/path/no-execution fences.

    The new staged/generated suite passes 62 assertions and all six semantic suites pass 530. Complete Julia passes
    8,072 package assertions, primary process conformance, and corpus 105/105. Full primary passes 5 backends x 2
    environments x 66; all ten Unicode-manifest legs pass. Unchanged ledgers pass at Unicode 806/9/8/2, semantic
    6/20/81 with rollout 4/9 and admission 3/6, capability 80/0/0, generated v1/10/80-0-0, and public 59/27/0.
    Canonical local CI passes all four doctrines, Rust semantic admission 1/1 in 76.95 seconds, Dart 1/1, reference
    primary 66/66 twice, and Phase 0 1,031/1,031 in 622 seconds. Canonical mdBook, Knowledge Map 686/5,265,
    memory/task metadata, markers, and diff hygiene pass. Exact safe cleanup removes 1,504,508 KiB while preserving
    all 517 Pgen artifacts. No public query, runtime observation, generated format, semantic rollout, or native
    admission changes. Commit subject:
    `FUTURE-PARITY-BACKLOG.10.6.4.2 - complete Julia call provenance`.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.4.3`
    Status: `done` (2026-07-23; complete verified no-change closeout candidate from clean `cc229cc5`)
    Goal: Compose and close exact Julia calls/staging/generated projection.
    Depends on: `.10.6.4.2`
    Acceptance: Re-run exact target, Unicode/interleaved-function/source-evidence, resolution/shape, isolation,
      complete Julia/canonical/docs/KM/cleanup proof; close `.10.6.4` without public query or promotion.
    Verification plan: Change no production, test, fixture, contract, public API, or generated format. Recompose the
      six committed Julia semantic source/outcome/static/core/staged suites as one exact 530-assertion topology;
      reconfirm the complete 22/25/10 calls target, Unicode/duplicate/regex-safe source correlation, resolution/
      signatures/shapes, staged sidecar and selected-plan rejection, recursive immutability, detached/plain copies,
      private omission, and host/path/no-execution fences. Then run complete Julia/primary/105, both five-backend
      primary matrices, all ten Unicode legs, every no-drift ledger, canonical local CI, mdBook, Knowledge Map,
      memory/task/doctrines/diff, exact safe cleanup, close parent `.10.6.4`, and commit before `.10.6.5.0`.

    #### Acceptance Checklist

    - [x] **COMMITTED RECOMPOSITION** — Run the six committed Julia semantic suites together at exact focused 530;
      do not add replacement projection code or tests in this closeout.
    - [x] **EXACT COMPLETE TARGET** — Reconfirm all 22 records / 25 relations / 10 source references, staged and
      generated ids/facts/directions, authored order/source, resolution, signatures, shapes, and decisions.
    - [x] **ISOLATION / PUBLIC FENCE** — Reconfirm sidecar/plan corruption rejection, recursive freeze, detached
      plain copies, private API omission, and path/AST/IR/compiler/emitter/executor/trace/sink/observer denial.
    - [x] **NO REGRESSION / NO PROMOTION** — Pass complete Julia/primary/105, both matrices, ten Unicode legs, and
      all Unicode/semantic/capability/generated/public ledgers without API, format, rollout, or admission change.
    - [x] **LOCKSTEP / PARENT CLOSURE** — Pass canonical/docs/KM/memory/task/doctrines/diff/cleanup, close `.10.6.4`,
      hand off query audit `.10.6.5.0`, commit, clear the brief, and verify clean before activation.

    #### Verification Result (2026-07-23)

    PASS from clean staged/generated implementation commit `cc229cc5`. The six already-committed Julia semantic
    suites compose at exact focused 530 without a replacement projector, test, fixture, contract, public API, or
    generated-format change. The composition reconfirms exact 22 records / 25 relations / 10 source references;
    Unicode/interleaved authored order and source correlation; nested/duplicate/regex-safe call identity;
    user-before-helper resolution, fixed/rest signatures, conservative shapes, and binding/decision directions;
    all staged payload/job/result and selected-plan provenance; sidecar/plan rejection; recursive freeze, detached
    plain copies, private omission, and host/path/AST/IR/emitter/executor/trace/sink/observer denial.

    Complete Julia passes 8,072 package assertions, primary process conformance, and corpus 105/105. The complete
    five-backend primary matrix passes 5 x 2 x 66 and all ten Unicode-manifest legs pass. Governance remains exact
    at Unicode 806/9/8/2, semantic 6/20/81 with rollout 4/9 and native admission 3/6, capability 80/0/0, generated
    v1/10/80-0-0, and public 59/27/0. Canonical local CI passes every doctrine and portable contract, Rust semantic
    admission 1/1 in 77.68 seconds, Dart admission 1/1, reference primary 66/66 twice, and Phase 0 1,031/1,031 in
    622 seconds. mdBook, Knowledge Map 686/5,265, memory/task metadata, markers, diff hygiene, and exact
    1,504,516-KiB safe generated-artifact cleanup pass while preserving all 517 Pgen issue artifacts. Parent
    `.10.6.4` is composition-closed without public query, runtime observation, generated-format, rollout, or
    native-admission movement. Query
    authority audit `.10.6.5.0` is the next dependency-eligible leaf after the closeout commit is clean.

- ID: `FUTURE-PARITY-BACKLOG.10.6.5`
  Status: `done` (2026-07-23; immutable static query composition closed by fully verified `.4` from clean public
    commit `1b303cef`)
  Goal: Expose immutable typed and raw-neutral Julia semantic capabilities/query.
  Children: `.10.6.5.0`, `.10.6.5.1`, `.10.6.5.2`, `.10.6.5.3`, `.10.6.5.4`
  Depends on: `.10.6.4`
  Acceptance: Evaluate capabilities/list/get/relations/explain over detached projection only; match all 19 static
    digests and 26 validation boundaries with exact source ceilings, pages, filtered traversal, logical budgets/
    costs, portable errors, deep immutability, and no parsing/compilation/execution/host inspection during query.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.5.0`
    Status: `done` (2026-07-23; fully verified commit candidate from clean calls/staging/generated closeout
      `61aa48bb`)
    Goal: Freeze Julia query types, detached authority, validator boundaries, and implementation split.
    Depends on: `.10.6.4.3`
    Acceptance: Reconcile all 20 requests/19 static digests, 26 malformed boundaries including `Bool <: Integer`,
      source/privacy/page/budget/cost/explain rules, no-execution topology, typed/raw JSON shape, and `.1-.4` order.
    Verification plan: Change no production, test, fixture, contract, public API, generated format, observation,
      rollout, or admission behavior. Retrieve ADRs `0049`/`0050`, the executable neutral oracle and canonical
      responses, admitted Perl/Rust/Dart query implementations, the current Julia authority map, and all reusable
      detached private projection seams before probing. Inventory all 20 requests, 19 non-runtime digests, 26
      malformed boundaries, capabilities, typed/raw-neutral vocabulary, source ceilings/redactions/digest rules,
      canonical ordering, pages/cursors, directional filtered breadth-first traversal, budgets/costs/truncation,
      errors, and explanations. Prove the evaluator can receive only a fresh detached clone of the retained static
      projection and cannot receive source text above ceiling, parser/compiler/staged sidecar/AST/IR/regex/
      generated implementation/executor/trace/path/host state. Probe Julia-specific recursive mutability and exact
      `Bool <: Integer` rejection requirements. Freeze dependency order as private record/source kernel `.1`,
      relation traversal/limits `.2`, public typed/raw-neutral completion `.3`, and no-change closeout `.4`. Then
      run committed focused 530, complete Julia/primary/105, both five-backend primary matrices, all ten Unicode
      legs, every no-drift ledger, canonical CI, mdBook, Knowledge Map, memory/task/doctrines/diff, exact safe
      cleanup, and commit before `.10.6.5.1` activation.

    #### Acceptance Checklist

    - [x] **RETRIEVE FIRST / EXACT ORACLE** — Reuse the neutral/admitted query authorities and enumerate all
      20 requests, 19 static digests, 26 malformed boundaries, capabilities, and exact typed/raw-neutral shapes.
    - [x] **DETACHED JULIA AUTHORITY** — Prove one fresh clone of the retained private projection is sufficient;
      source-above-ceiling, parser/compiler/sidecar/AST/IR/regex/generated/executor/trace/path/host state is denied.
    - [x] **POLICY / VALIDATION** — Freeze source privacy, canonical order/pages/cursors, filtered traversal,
      budgets/costs/truncation, errors/explanations, recursive detachment, and explicit Boolean-as-numeric rejection.
    - [x] **DEPENDENCY SPLIT / NO BEHAVIOR** — Freeze `.1` record/source kernel, `.2` traversal/limits, `.3` public
      typed/raw-neutral completion, and `.4` closeout without production/test/fixture/API/format/ledger change.
    - [x] **LOCKSTEP / COMMIT** — Pass focused/complete Julia, both primary matrices, ten Unicode legs, all no-drift
      ledgers, canonical CI, mdBook/KM/memory/task/doctrines/diff, exact safe cleanup, and commit before `.1`.

    #### Authority Audit Evidence (2026-07-23)

    Retrieval followed `KNOWLEDGE_MAP.md` before fresh probing: ADRs `0049`/`0050`, the neutral contract and model,
    all three admitted Perl/Rust/Dart evaluator cards and implementations, and Julia's closed source/outcome/static/
    calls authority cards and owners. `tools/check_semantic_introspection_contract.py` passes at 6 fixture groups,
    20 exact queries, 81 rejected mutations, rollout 4 complete / 5 pending, and admission 3 complete / 3 pending.
    The admitted focused query suites also pass independently: Perl 9 tests, Rust 5/5, and Dart 6/6. The oracle and
    all existing consumers therefore agree before any Julia query production change.

    The 20 exact cases are `capabilities`, `graph_list_rules`, `graph_duplicate_regex_text`,
    `graph_reverse_dispatch`, `graph_explain_entry`, `calls_symbols_and_shapes`, `staged_chain`,
    `generated_provenance`, `failed_diagnostic`, `runtime_events`, `privacy_none`, `privacy_text_and_digest`,
    `pagination_after_id`, `page_boundary`, `budget_prefix`, `relation_budget_prefix`, `relation_depth_zero`,
    `source_ceiling_forbidden`, `unsupported_contract`, and `invalid_operation_combination`. Only
    `runtime_events` consumes post-execution authority; its digest `36897041...5887` remains `.10.6.6`. The other
    19 static digest prefixes, in that same order with `runtime_events` omitted, are `a5f759dc`, `b8872b73`,
    `b64f1640`, `efc996d0`, `86d93288`, `b3e3e0d0`, `862d6f30`, `aaba2d3d`, `b2afd23b`, `906711bc`,
    `651908fa`, `f705e7fa`, `cf350f73`, `d41ec0a1`, `32d109f9`, `cacc627c`, `12eddbc7`, `e6d797f3`, and
    `3010ac5f`; implementation tests must compare the complete contract hashes, not these display prefixes.

    Exact raw-neutral rejection labels are `request_not_object`, `unsupported_contract`, `request_fields`,
    `page_fields`, `budget_fields`, `source_fields`, `operation`, `subjects_type`, `subjects_duplicate`,
    `record_kind`, `relation_kind`, `record_kind_order`, `relation_kind_order`, `direction`, `after_id`,
    `page_limit`, `max_records`, `max_relations`, `max_depth`, `source_policy`, `numeric_boolean`,
    `digest_requires_text`, `operation_combination`, `unknown_subject`, `after_id_not_in_primary_stream`, and
    `not_explainable`. Julia must test `Bool` before `Integer` for every numeric field because `true isa Integer`,
    and must require an actual `Bool` for `include_content_digest`; the malformed seam cannot be represented only
    by typed constructors.

    The closed Julia `_SemanticStaticProjection` is the only query authority. It retains a typed
    `SemanticSnapshot` plus recursively tuple-backed source references, records, and relations. Its private test
    seam returns a fresh plain `Dict`/`Vector` tree; direct probing reports 22 records / 25 relations / 10 source
    references for the calls target, mutating one returned nested record does not affect the next materialization,
    and the retained projection stays `_SemanticStaticProjection`. Normal public names contain no
    `SemanticQuery`, `semantic_query`, or `semantic_capabilities` yet. The evaluator may receive exactly one new
    detached materialization per call; it may not receive retained decoded source/map, source above the immutable
    construction ceiling, parsed/compiled/staged sidecars, AST/ActionIR, compiled regex, generated implementation,
    loader/emitter/executor, runtime observation, trace/diagnostic sink, path, environment, clock, randomness, or
    another host object. Query-time source projection may only redact this already-authorized clone.

    The exact public vocabulary is frozen to `SemanticQueryOperation`, `SemanticQueryDirection`,
    `SemanticQueryPage`, `SemanticQueryBudget`, `SemanticQuerySource`, `SemanticQuery`,
    `SemanticQuerySourceReference`, `SemanticQueryRecord`, `SemanticQueryRelation`, `SemanticQueryDiagnostic`,
    `SemanticQueryPageState`, `SemanticQueryCost`, and `SemanticQueryResponse`. It reuses `SemanticSourceDetail`,
    `SemanticSourceSpan`, and `SemanticSnapshot`. Request filters and response collections are copied tuples;
    variable-shape facts/fields are recursively immutable tuple-backed values and `to_json` always returns fresh
    `Dict`/`Vector` trees. Public functions appear together only after completion:
    `semantic_capabilities(index)`, `semantic_query(index, request::SemanticQuery)`, and
    `semantic_query_neutral(index, request)`. The explicit neutral name is Julia's transport-facing malformed-shape
    seam; both request paths enter the same projection-only evaluator and return the same typed response envelope.
    Operation enum values are `SemanticQueryCapabilitiesOperation`, `SemanticQueryListOperation`,
    `SemanticQueryGetOperation`, `SemanticQueryRelationsOperation`, and `SemanticQueryExplainOperation`;
    direction values are `SemanticQueryOutgoingDirection`, `SemanticQueryIncomingDirection`, and
    `SemanticQueryBothDirection`. Their wire names remain the lowercase neutral spellings.

    The frozen wire policy is model `linkedspec-semantic-model-v1`, query `linkedspec-semantic-query-v1`, exact
    nine-field request/response envelopes, operations capabilities/list/get/relations/explain, directions
    outgoing/incoming/both, source none/identity/span/text, page default/max 100/1,000, record/relation/depth budget
    defaults 1,000/2,000/4 and maxima 10,000/20,000/8. Digest requires text; an above-ceiling request fails without
    downgrade. Records and relations retain canonical order. Relations use filter-constrained directional breadth-
    first traversal, relation-id then frontier-record-id deduplication, canonical result order, last returned primary
    id cursors, and deterministic prefixes. Costs count emitted primary records, emitted primary/explanation
    relations, and deepest emitted relation frontier; cursor lookup is free. Exhausted record/relation/depth budget
    returns `complete=false` plus `semantic_query_budget_exceeded`; contract, source-ceiling, and structural failures
    use the other three frozen diagnostics. Explain returns the decision before steps and only `explained_by`.

    The implementation order is omission-safe:

    1. `.10.6.5.1` adds module-private immutable protocol values plus capabilities/list/get/explain and exact
       source/redaction helpers over one detached projection clone; it exports no partial query API.
    2. `.10.6.5.2` adds filtered directional traversal, canonical pages/cursors, budgets, logical costs, deterministic
       prefixes, and all 19 static hashes while the evaluator remains private.
    3. `.10.6.5.3` exports the complete typed/raw-neutral API together, locks all 26 malformed boundaries and clone/
       non-interference/host-denial properties, and changes no runtime-observation state.
    4. `.10.6.5.4` adds no replacement owner; it recomposes committed proof and closes parent `.10.6.5`.

    This leaf changes no production, test, fixture, contract, public API, generated format, trace, runtime
    observation, rollout, admission, or exact ledger. Durable conclusions live in
    `docs/knowledge/julia-semantic-query-authority-map.md` and the extended Julia authority map. No fishy or
    foundationally surprising result was found: the query layer is a constrained read-only view over the already-
    closed detached static surface.

    #### Verification Result (2026-07-23)

    PASS. The executable neutral checker remains exact at 6 fixture groups / 20 responses / 81 rejected mutations,
    rollout 4/9, and native admission 3/6; admitted focused query consumers pass at Perl 9, Rust 5/5, and Dart 6/6.
    The six committed Julia semantic suites pass together at focused 530, and the direct audit probe confirms the
    sole detached private authority at exact 22 records / 25 relations / 10 source references with fresh nested
    mutation isolation and no public query symbols.

    Complete Julia passes 8,072 package assertions, primary process conformance, and corpus 105/105. The complete
    five-backend primary matrix passes 5 x 2 x 66 and all ten Unicode-manifest legs pass. Governance remains exact
    at Unicode 806/9/8/2, semantic 6/20/81 with rollout 4/9 and native admission 3/6, capability 80/0/0, generated
    v1/10/80-0-0, and public 59/27/0. Canonical local CI passes every doctrine and portable contract, Rust semantic
    admission 1/1, Dart admission 1/1, reference primary 66/66 twice, and Phase 0 1,031/1,031 in 655 seconds.
    mdBook, Knowledge Map 687/5,277, memory/task metadata, all four doctrines, marker/diff hygiene, and exact
    1,812,240-KiB safe generated-artifact cleanup pass while preserving all 517 Pgen issue artifacts.

    No production, test, fixture, contract, public API, generated-format, runtime-observation, rollout, or admission
    behavior changes. The exact authority, policy, validation surface, and omission-safe `.1-.4` implementation
    order are frozen before code; private record/source kernel `.10.6.5.1` is next only after this commit is clean.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.5.1`
    Status: `done` (2026-07-23; fully verified commit candidate from clean authority-plan commit `58c67035`)
    Goal: Implement private immutable Julia record/source query kernel.
    Depends on: `.10.6.5.0`
    Acceptance: Add closed typed request/response/error value vocabulary plus private capabilities/list/get/explain
      and source ceiling/redaction/digest logic over fresh detached projection clones; match the owned static digests
      without exporting a partial public evaluator.
    Verification plan: Retrieve the committed Julia query-authority card and exact admitted evaluator seams before
      code. Inventory the neutral typed envelope, serialization order, capabilities constants, source ceiling/detail/
      digest policy, list/get/explain filtering and canonical primary order, default page/cost envelopes for this
      non-traversal kernel, success/error response construction, and the subset of static requests whose behavior
      is fully owned without relation traversal. Add module-private immutable Julia values and one private evaluator
      over exactly one fresh detached static projection materialization; do not export query symbols, accept raw
      malformed requests, implement cursor/non-default paging/budget truncation/relations/BFS, or reach source/compiler/
      runtime/host state. Add focused positive/negative/clone/privacy/no-execution tests and exact owned neutral
      hashes. Then run the committed semantic foundation/static/calls suites plus the new kernel suite, complete
      Julia/primary/105, both five-backend primary matrices, ten Unicode legs, every no-drift ledger, canonical CI,
      mdBook, Knowledge Map, memory/task/doctrines/diff, exact safe cleanup, and commit before `.10.6.5.2` activation.

    #### Acceptance Checklist

    - [x] **RETRIEVE / SUBSET** — Reuse the exact neutral/admitted evaluator contracts and assign the nine
      capabilities/list/get/explain/source-ceiling requests fully owned before paging/budgets/traversal; freeze hashes.
    - [x] **PRIVATE IMMUTABLE VALUES** — Add tuple-backed, recursively frozen request/response/source/record/
      diagnostic/page/cost values and fresh neutral serialization without exporting a partial query API.
    - [x] **DETACHED KERNEL / SOURCE** — Evaluate over exactly one fresh static-projection materialization with
      exact source ceiling/redaction/digest rules and no retained source/compiler/runtime/host authority.
    - [x] **CAPABILITIES / LIST / GET / EXPLAIN** — Implement exact canonical filtering, default page/cost responses,
      diagnostics, and decision-first explanation for the nine owned cases; leave cursor/limits/budgets/relations to `.2`.
    - [x] **FOCUSED PROOF** — Lock exact hashes, recursive detachment, mutation isolation, private omission,
      malformed/internal guardrails, and no parse/compile/execute/trace/sink/path access.
    - [x] **LOCKSTEP / COMMIT** — Pass focused/complete Julia, both primary matrices, ten Unicode legs, all no-drift
      ledgers, canonical CI, mdBook/KM/memory/task/doctrines/diff, exact safe cleanup, and commit before `.2`.

    #### Implementation Evidence (2026-07-23)

    `julia/src/semantic/SemanticQuery.jl` now defines the complete frozen query vocabulary and serialization shape
    from `.0`, but exports none of it. `SemanticQueryOperation` has the five exact values and
    `SemanticQueryDirection` has outgoing/incoming/both; request collections and response streams are tuples, while
    variable-shape objects/arrays use distinct private tuple-backed wrappers so even empty object versus empty array
    remains lossless. Equality/hash implementations are structural, and every `to_json` recursively creates fresh
    `Dict`/`Vector` trees. Keyword page/budget constructors explicitly reject `Bool` before `Integer`; direct typed
    construction cannot use Boolean values through the concrete `Int` positions.

    The static owner now exposes `_semantic_static_projection_materialize` as its production-private fresh clone
    seam; the pre-existing test oracle delegates to it unchanged. `_semantic_query_kernel` calls that materializer
    exactly once and supplies only its detached snapshot/source-reference/record/relation plain data to the private
    evaluator. The evaluator never reads retained source/map/outcome, parser/compiler/staged sidecars, AST/IR,
    regex, generated implementation, loader/emitter/executor, observation, trace/sink, path, environment, time,
    randomness, or another host object.

    Nine static requests are exact at this boundary: `capabilities` (`a5f759dc...`), `graph_list_rules`
    (`b8872b73...`), `graph_duplicate_regex_text` (`b64f1640...`), `graph_explain_entry` (`86d93288...`),
    `calls_symbols_and_shapes` (`b3e3e0d0...`), `failed_diagnostic` (`b2afd23b...`), `privacy_none`
    (`906711bc...`), `privacy_text_and_digest` (`651908fa...`), and `source_ceiling_forbidden`
    (`12eddbc7...`). The private evaluator preserves canonical record order, decision-before-steps plus only
    `explained_by`, exact default page/cost envelopes, monotonic structural redaction, text-only digest disclosure,
    and exact source-ceiling diagnostic fields. Cursor/non-default page, record/relation/depth budgets, relation BFS,
    and the remaining ten static hashes throw an internal ownership error and remain `.10.6.5.2`; raw-neutral
    malformed validation and all public exports remain `.10.6.5.3`.

    New focused proof passes 100 checks: nine full SHA-256 response digests, exact ids/status/page/diagnostics,
    source privacy/redaction/digest/ceiling, recursively immutable retained values, independently mutable fresh JSON
    trees, retained projection type, omission of every planned public name, deferred-boundary rejection, typed
    Boolean/numeric rejection, exactly one materializer call, and forbidden-authority source scans. The seven-suite
    semantic composition passes 630. Complete Julia passes 8,172 package assertions, primary process conformance,
    and corpus 105/105; full primary 5 x 2 x 66 and all ten Unicode-manifest legs pass. Governance remains exact at
    Unicode 806/9/8/2, semantic 6/20/81 at rollout 4/9 and admission 3/6, capability 80/0/0, generated
    v1/10/80-0-0, and public 59/27/0. Canonical CI, mdBook, Knowledge Map 688/5,287, all four doctrines, and exact
    1,613,088-KiB cleanup preserving 517 Pgen artifacts also pass.

    #### Verification Result (2026-07-23)

    PASS. The new private kernel suite passes 100 assertions and all seven Julia semantic suites compose at 630.
    The nine owned SHA-256 response digests, record/relation/diagnostic ids, page/cost envelopes, source redaction/
    digest/ceiling policy, recursive retained immutability, fresh serialization trees, private omission, one-clone
    authority, deferred-boundary rejection, explicit Boolean/numeric fence, and forbidden-host scan are exact.

    Complete Julia passes 8,172 package assertions, primary process conformance, and corpus 105/105. Full primary
    passes 5 backends x 2 environments x 66 cases and all ten Unicode-manifest legs pass. Governance remains exact
    at Unicode 806/9/8/2, semantic 6/20/81 with rollout 4/9 and native admission 3/6, capability 80/0/0, generated
    v1/10/80-0-0, and public 59/27/0. Canonical local CI passes all four doctrines and portable contracts, Rust
    semantic admission 1/1 in 80.95 seconds, Dart admission 1/1, reference primary 66/66 twice, and Phase 0
    1,031/1,031 in 662 seconds. mdBook, Knowledge Map 688/5,287, bounded memory, task metadata, marker/diff hygiene,
    and exact 1,613,088-KiB safe cleanup pass while preserving all 517 Pgen issue artifacts and Julia package/
    registry caches.

    Julia therefore has a complete private immutable non-traversal query kernel at nine exact static hashes. No
    planned query name is exported; relation traversal, paging, budgets, logical costs, incomplete prefixes, and
    ten remaining static hashes stay `.10.6.5.2`, while raw-neutral validation and public typed/raw entry points
    stay `.10.6.5.3`. `.10.6.5.2` may activate only after this commit is clean.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.5.2`
    Status: `done candidate` (2026-07-23; fully verified from clean private-kernel commit `b70e37fc`)
    Goal: Add exact Julia relation traversal, pagination, budgets, and logical costs.
    Depends on: `.10.6.5.1`
    Acceptance: Implement deterministic filtered directional breadth-first traversal, canonical after-id pages,
      record/relation/depth ceilings, deterministic truncation/prefixes, and exact cost accounting; match all
      successful static digests without touching compiler/runtime authority.
    Verification plan: Retrieve the committed Julia query authority/kernel cards and executable neutral evaluator
      before code. Inventory the ten static hashes not owned by `.1`, exact after-id primary ordering, directional
      filter-constrained BFS, relation/frontier deduplication, record/relation/depth budget precedence, deterministic
      incomplete prefixes, next-cursor behavior, logical record/relation/depth costs, and invalid typed ownership
      boundaries that remain public/raw `.3`. Extend only the existing private evaluator over its single detached
      projection clone; export nothing and do not widen source/compiler/runtime/trace/path/host authority. Add exact
      focused success/truncation/order/filter/direction/cursor/budget/cost/clone/non-execution proof so all 19 static
      hashes match. Then run all committed semantic suites, complete Julia/primary/105, both five-backend primary
      matrices, ten Unicode legs, every no-drift ledger, canonical CI, mdBook/KM/memory/task/doctrines/diff, exact
      safe cleanup, and commit before public completion `.10.6.5.3`.

    #### Acceptance Checklist

    - [x] **RETRIEVE / FREEZE** — Reuse the neutral/admitted traversal algorithms and assign the remaining ten
      static requests, exact primary orders, pages, budgets, costs, diagnostics, and typed `.3` boundaries.
    - [x] **PAGING / COSTS** — Implement canonical after-id pages and logical cost accounting for list/get/explain
      and relation responses without host resource counters or secondary authority.
    - [x] **RELATION BFS** — Implement exact outgoing/incoming/both filter-constrained breadth-first traversal with
      relation-id and frontier-record-id deduplication plus canonical output order.
    - [x] **BUDGET PREFIXES** — Enforce record/relation/depth ceilings with exact precedence, deterministic incomplete
      prefixes, next cursor, and portable budget diagnostics.
    - [x] **NINETEEN-HASH PROOF** — Match all 19 non-runtime response hashes and lock order/filter/direction/page/
      budget/cost/clone/privacy/private/no-execution behavior while retaining `.3` raw/public ownership.
    - [x] **LOCKSTEP / COMMIT** — Pass focused/complete Julia, both primary matrices, ten Unicode legs, all no-drift
      ledgers, canonical CI, mdBook/KM/memory/task/doctrines/diff, exact safe cleanup, and commit before `.3`.

    #### Implementation Evidence (2026-07-23)

    The existing private evaluator now pages every primary stream through one `_semantic_query_page_stream` owner.
    After-id lookup occurs only within the filtered record/relation/explanation-step stream; page limit and the
    applicable logical budget select the deterministic prefix, `next_after_id` names the last returned primary
    item only when incomplete, and an unknown cursor returns the exact portable error. Capabilities/list/get count
    returned records, relations count returned relations plus the deepest returned BFS layer, and explain reserves
    one record budget unit for the decision before paging its steps and deriving only selected `explained_by` rows.

    `_semantic_query_traverse_relations` performs filter-constrained outgoing/incoming/both breadth-first traversal
    over the already-canonical detached relation stream. It deduplicates relation ids across layers, removes visited
    frontier record ids before the next layer, then projects selected relations back in canonical source order.
    A remaining matching layer beyond `max_depth` produces the deterministic `max_depth` prefix; relation budget
    takes diagnostic precedence over depth when both constrain a request. Record and relation budget prefixes keep
    `ok=true`, force `complete=false`, and carry the exact warning fields/costs without consulting host resources.

    Private typed validation now returns exact unsupported-contract and invalid-operation-combination envelopes,
    while the 26 raw container/scalar/field/rank boundaries remain exclusively `.10.6.5.3`. Unknown relation/get
    subjects, invalid primary cursors, capability filters, digest-without-text, and source ceilings also return
    portable immutable responses. Public query names remain absent and `_semantic_query_kernel` still materializes
    exactly one detached projection before evaluation.

    New `semantic_index_query_traversal_test.jl` passes 118 assertions. It locks the remaining ten full SHA-256
    response hashes, recomposes all 19 non-runtime hashes, exact canonical relations/directions/depth, pages/cursors,
    record/relation/depth budget prefixes, typed diagnostic fields, decision-reserved explain budgets, recursively
    immutable relations, fresh JSON mutation isolation, and private omission. The earlier kernel suite remains
    100; all eight Julia semantic suites pass 748.

    #### Verification Result (2026-07-23)

    PASS. The new traversal suite passes 118 and all eight Julia semantic suites compose at 748. All 19 static
    SHA-256 responses, outgoing/incoming/both directions, canonical filtered order, relation/frontier deduplication,
    after-id and page-boundary behavior, record/relation/depth budget prefixes and precedence, logical costs,
    exact typed errors, recursive immutability, fresh JSON isolation, one detached materialization, private omission,
    and no source/compiler/runtime/trace/path/host authority are exact. Complete Julia passes 8,290 package
    assertions, primary process conformance, and corpus 105/105.

    Full primary passes 5 backends x 2 environments x 66 cases and all ten Unicode-manifest legs pass 1/1.
    Governance remains exact at Unicode 806/9/8/2, semantic 6/20/81 with rollout 4/9 and native admission 3/6,
    capability 80/0/0, generated v1/10/80-0-0, and public 59/27/0. Canonical local CI passes all four doctrines and
    portable contracts, Rust semantic admission 1/1 in 82.53 seconds, Dart admission 1/1, reference primary 66/66
    twice, and Phase 0 1,031/1,031 in 647 seconds. mdBook, Knowledge Map 689/5,298, bounded memory, task metadata,
    marker/diff hygiene, and exact 1,613,224-KiB safe cleanup pass while preserving all 517 Pgen issue artifacts and
    Julia package/registry caches.

    Julia therefore has one complete private static query evaluator at all 19 non-runtime hashes. Planned query
    names remain unexported; raw-neutral validation, all 26 malformed boundaries, and public typed/raw entry points
    stay `.10.6.5.3`. Runtime events stay `.10.6.6`. `.10.6.5.3` may activate only after this commit is clean.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.5.3`
    Status: `done` (2026-07-23; fully verified public typed/raw static query completion)
    Goal: Export Julia semantic construction, capabilities, typed query, and raw-neutral query completion.
    Depends on: `.10.6.5.2`
    Acceptance: Expose one idiomatic opaque index API and one raw-neutral validator/evaluator path; match all 19
      static digests and all malformed boundaries, recursively detach outputs, reject booleans as numerics, and
      deny path/source-above-ceiling/AST/IR/compiler/runtime/callback authority.
    Verification plan: Retrieve the committed Julia query authority, kernel, and traversal cards plus the exact
      neutral malformed-request inventory and admitted Perl/Rust/Dart public seams before code. Export the complete
      immutable query vocabulary, canonical capabilities helper, typed evaluator entry, and raw-neutral validator
      together; route both request paths through the existing one-detached-projection kernel without a second
      evaluator or new authority. Validate exact object keys, required fields, containers, scalar/enumeration
      values, duplicate filters/subjects, cursor shape, numeric ranks/ranges, Boolean-versus-Integer separation,
      digest/detail policy, and operation combinations into portable response envelopes. Add focused proof for all
      19 typed/raw digests, all 26 malformed boundaries, clone/input/interleaving isolation, privacy/source ceilings,
      public exports, construction/query non-execution, and forbidden source/compiler/AST/IR/generated/runtime/
      trace/path/callback authority. Then run all semantic suites, complete Julia/primary/105, both five-backend
      primary matrices, ten Unicode legs, every no-drift ledger, canonical CI, mdBook/KM/memory/task/doctrines/
      diff, exact safe cleanup, and commit before no-change closeout `.10.6.5.4`.

    #### Acceptance Checklist

    - [x] **RETRIEVE / FREEZE** — Inventory the exact 26 malformed neutral requests, public names/types, admitted
      backend behavior, and forbidden authorities before implementation.
    - [x] **ONE PUBLIC SURFACE** — Export immutable query values plus capabilities, typed query, and raw-neutral
      query together while retaining one evaluator and one detached projection per request.
    - [x] **RAW VALIDATION** — Convert every malformed container/key/scalar/enum/rank/range/duplicate/combination
      boundary to the exact portable response, explicitly rejecting `Bool` before Julia `Integer`.
    - [x] **EXACT PARITY** — Match all 19 static response hashes through typed and raw-neutral paths and all 26
      malformed responses through raw-neutral input.
    - [x] **ISOLATION / DENIAL** — Lock recursive response/input detachment, deterministic interleaving, privacy,
      source ceilings, construction/query non-execution, and host/path/compiler/AST/IR/runtime/trace/callback denial.
    - [x] **LOCKSTEP / COMMIT** — Pass focused/complete Julia, both primary matrices, ten Unicode legs, all no-drift
      ledgers, canonical CI, mdBook/KM/memory/task/doctrines/diff, exact safe cleanup, and commit before `.4`.

    Completion evidence: `LinkedSpecJulia` exports the full frozen immutable query vocabulary plus
    `semantic_capabilities`, typed `semantic_query`, and raw-neutral `semantic_query_neutral`; both paths share one
    validator/evaluator and exactly one detached projection per request. The new public suite passes 315 assertions
    across all 19 typed/raw response hashes, all 26 malformed boundaries, direct `JSON3.Object` transport, clone/
    input/interleaving isolation, public exports, callback non-invocation, construction/query non-execution, one
    materialization source seam, and source/compiler/parser/AST/IR/generated/runtime/trace/environment/time/random
    denial. All nine Julia semantic suites compose at 1,063; complete Julia is 8,605/primary/105. Full primary is
    5 backends x 2 environments x 66 cases, and all ten Unicode legs pass. Governance remains exact at Unicode
    806/9/8/2, semantic 6/20/81 with rollout 4/9 and admission 3/6, capability 80/0/0, generated v1/10/80-0-0, and
    public 59/27/0. Canonical CI passes all four doctrines/contracts, Rust semantic admission in 79.96 seconds,
    Dart admission 1/1, primary 66x2, and Phase 0 1,031/1,031 in 634 seconds. mdBook, Knowledge Map 690/5,307,
    bounded memory, task metadata, marker/diff hygiene, and exact 1,613,820-KiB safe cleanup pass while preserving
    Julia package/registry caches and all 517 Pgen artifacts. Runtime events remain `.10.6.6`; no semantic ledger
    is promoted. `.10.6.5.4` may activate only after this commit is clean.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.5.4`
    Status: `done` (2026-07-23; fully verified commit candidate from clean public-query commit `1b303cef`)
    Goal: Compose and close Julia immutable semantic query.
    Depends on: `.10.6.5.3`
    Acceptance: Re-run foundation/static/calls/query composition, exact digests/errors/pages/budgets/explain,
      mutation/immutability/no-execute proof, complete Julia/canonical/docs/KM/cleanup; close `.10.6.5` without
      runtime observations or ledger promotion.
    Verification plan: Retrieve the committed Julia query authority/kernel/traversal/public cards and inspect the
      clean `.1-.3` topology before any non-task edit. Add no replacement production or test owner. Recompose all
      nine committed semantic suites at exact focused 1,063, rerun complete Julia/primary/105, the full five-backend
      primary matrix in both environments, all ten Unicode legs, every no-drift ledger, and canonical local CI.
      Reconfirm 19 typed/raw hashes, 26 malformed boundaries, one detached materialization seam, clone/privacy/
      no-execution/host denial, package exports, and absence of runtime observation or ledger movement. Then sync
      task/live/roadmap/mdBook/Knowledge Map/memory, build the book, enforce all doctrines, clean only measured safe
      artifacts while preserving Julia package/registry caches and 517 Pgen artifacts, and commit before `.10.6.6.0`.

    #### Acceptance Checklist

    - [x] **RETRIEVE / RECOMPOSE** — Read the four committed query fact cards and recompose all nine semantic suites
      at exact 1,063 without production or replacement-test changes.
    - [x] **COMPLETE JULIA** — Pass complete Julia package tests, primary process conformance, and corpus 105/105.
    - [x] **PORTABLE MATRICES** — Pass full primary 5x2x66, all ten Unicode legs, and every exact no-drift ledger.
    - [x] **AUTHORITY / OMISSION** — Reconfirm 19 typed/raw hashes, 26 boundaries, one detached materialization,
      exports, clone/privacy/non-execution/host denial, and no runtime-observation or ledger movement.
    - [x] **CANONICAL / LOCKSTEP** — Pass canonical CI, mdBook/KM/memory/task/four doctrines/diff, exact safe
      cleanup, close parent `.10.6.5`, and commit before runtime-observation planning `.10.6.6.0`.

    Completion evidence: The four committed query cards and clean `.1-.3` topology were retrieved before any
    non-task edit. The nine committed semantic suites recompose at exact 135 + 85 + 70 + 99 + 79 + 62 + 100 +
    118 + 315 = 1,063. A first standalone include passed source 135 and outcome 85 before the harness alone lacked
    the package driver's `REPO_ROOT`; supplying that driver binding yielded the exact unchanged composition and
    required no repository edit. Complete Julia passes 8,605 package assertions, primary process conformance, and
    corpus 105/105. Full primary passes five backends x two environments x 66 cases; all ten Unicode legs pass 1/1.
    All 19 typed/raw hashes, 26 malformed boundaries, one detached materialization, exports, clone/input/
    interleaving isolation, privacy/source ceilings, and construction/query non-execution plus callback/host denial
    remain exact. Governance remains Unicode 806/9/8/2, semantic 6/20/81 at rollout 4/9 and admission 3/6,
    capability 80/0/0, generated v1/10/80-0-0, and public 59/27/0. Canonical CI passes every doctrine/contract,
    Rust semantic admission in 79.55 seconds, Dart 1/1, reference primary 66x2, and Phase 0 1,031/1,031 in 635
    seconds. mdBook, Knowledge Map 690/5,307, bounded memory, task/marker/diff hygiene, and exact 1,613,872-KiB
    safe cleanup pass while preserving all 517 Pgen evidence artifacts and Julia package/registry caches. No
    production code, test, fixture, contract, public API, generated format, runtime observation, rollout, or native
    admission changes. Parent `.10.6.5` is closed; `.10.6.6.0` waits for the clean closeout commit.

- ID: `FUTURE-PARITY-BACKLOG.10.6.6`
  Status: `done` (2026-07-23; capture `.1`, derivation `.2`, propagation `.3`, and no-change closeout `.4` complete)
  Goal: Capture typed Julia runtime semantic observations through every execution route.
  Children: `.10.6.6.0`, `.10.6.6.1`, `.10.6.6.2`, `.10.6.6.3`, `.10.6.6.4`
  Depends on: `.10.6.5`
  Acceptance: Add a separate optional invocation-local typed sink at accepted-slot and successful final-result
    seams; derive a new immutable observed index matching the twentieth digest; propagate direct/loaded/
    reconstructed/generated/emitted/traced routes with exact callback identity and result/trace/diagnostic
    non-interference; keep query execution-free and no-sink work minimal.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.6.0`
    Status: `done` (2026-07-23; complete verified behavior-free plan from clean query closeout `5ad8a165`)
    Goal: Freeze Julia runtime-observation seams, topology, exception policy, and implementation split.
    Depends on: `.10.6.5.4`
    Acceptance: Map exact slot/result seams, all live/generated route adapters, existing trace/diagnostic channels,
      generated broad-catch behavior, neutral event/derivation target, no-sink requirements, forbidden authorities,
      and `.1-.4` dependency order before behavior changes.
    Verification plan: Change no production code, tests, fixtures, contract, API, format, runtime behavior,
      rollout, or admission. Retrieve ADRs `0049`/`0050`, the Julia authority/static/query cards, the neutral
      twentieth runtime response, and admitted Perl/Rust/Dart runtime-observation authorities before source
      archaeology. Use the LinkedSpec toolbox and exact source/runtime probes to map every Julia direct, loaded,
      reconstructed, generated-plan, source-emitted, and traced entry; accepted regex-slot and successful final-
      result seams; scalar/code-unit/input identity; callback exception propagation; trace/diagnostic separation;
      generated broad-catch translation; no-sink work; and forbidden compiler/query/host authority. Freeze the
      typed immutable event/sink API, detached observation-to-snapshot derivation, validation/topology/shape/
      failure policy, and omission-safe `.1` direct capture / `.2` derivation / `.3` generated-emitted propagation /
      `.4` no-change closeout order. Then pass focused current Julia semantic/runtime probes, complete Julia,
      primary 5x2x66, all ten Unicode legs, every no-drift ledger, canonical CI, mdBook/KM/memory/task/doctrines/
      diff, measured safe cleanup, and commit before `.10.6.6.1` activation.

    #### Acceptance Checklist

    - [x] **RETRIEVE / MODEL** — Retrieve canonical Julia and admitted runtime-observation authorities plus the
      twentieth neutral response before re-deriving source/runtime facts.
    - [x] **ROUTES / SEAMS** — Map every direct/loaded/reconstructed/generated/emitted/traced adapter, accepted-slot
      and successful-result seam, input/position identity, broad-catch boundary, and trace/diagnostic separation.
    - [x] **POLICY / SPLIT** — Freeze immutable event/sink vocabulary, no-sink cost, callback exception identity,
      detached derivation/topology/shape/failure policy, forbidden authority, and `.1-.4` dependency order.
    - [x] **NO BEHAVIOR / PROOF** — Prove current runtime/query behavior and governance remain exact with no
      production/test/fixture/contract/API/format/runtime/rollout/admission change.
    - [x] **LOCKSTEP / COMMIT** — Pass complete matrices/canonical/book/KM/memory/task/doctrines/diff, exact safe
      cleanup, and commit the behavior-free plan before direct-capture implementation `.10.6.6.1`.

    Completion evidence: canonical neutral, Perl, Rust, Dart, and Julia authorities were retrieved before source
    proof. Julia has no typed semantic observation sink; the existing string trace slot mark is operational trace,
    not semantic authority, and there is no final-result trace topic. Direct high-trace proof returns `Any["A",
    "B"]`, scalar cursor 2, and exactly two slot marks. Direct, loaded, JSON-reconstructed, generated-plan,
    generated-plan traced, fresh emitted, and emitted-traced probes all converge on the same result and two-slot
    topology. The accepted-slot seam is after match and ordered identity but before effects; because the context
    cursor is still old, scalar position comes from `one_match.codeunit_end`. The final seam follows successful
    `RuntimeParseResult` construction. The optional invocation-local typed sink is guarded before event allocation
    and input hashing; semantic callback failures require exact identity pass-through around generated broad-error
    translation. Detached derivation validates rule/edge/slot/`selects_regex` topology, derives shape only from
    static facts, leaves the base immutable/static, and targets the exact twentieth digest
    `36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887` for canonical `ab\n` input identity
    `input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece` at positions 1, 2, and 2.

    The nine committed Julia semantic suites pass exact 135+85+70+99+79+62+100+118+315=1,063; complete Julia
    remains 8,605/primary/105. Primary 5x2x66, all ten Unicode legs, Unicode 806/9/8/2, semantic 6/20/81 at rollout
    4/9 and admission 3/6, capability 80/0/0, generated v1/10/80-0-0, language coverage 246/105+1/122, and public
    59/27/0 all pass unchanged. Canonical CI passes four doctrines, Rust semantic admission 1/1 in 78.71 seconds,
    Dart 1/1, reference primary 66x2, and Phase 0 1,031/1,031 in 679 seconds. mdBook, Knowledge Map 691/5,321,
    bounded memory, task/marker/diff hygiene pass. Exact 1,597,636-KiB cleanup removes only Rust dependencies/
    incremental state, Julia compiled/log caches, rendered book, and Python bytecode while preserving Julia
    package/registry caches and all 517 Pgen artifacts. No production code, test, fixture, contract, API, format,
    runtime behavior, rollout, or native admission changes. `.10.6.6.1` waits for this plan's clean commit.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.6.1`
    Status: `done` (2026-07-23; complete and verified from clean plan commit `c590c435`)
    Goal: Add typed Julia runtime semantic events and direct capture.
    Depends on: `.10.6.6.0`
    Acceptance: Export immutable closed slot/result event plus sink types; thread an optional invocation-local sink
      through direct, loaded, reconstructed, traced, and generated-plan engine entry; emit accepted slot events and
      one successful final result only, with scalar positions/input identity and exact caller exception identity.
    Verification plan: Implement only the public immutable event-kind/event/sink vocabulary and the shared native
      engine capture owned by this leaf. Thread an optional invocation-local sink through `runtime_parse`,
      `runtime_execute`, traced convenience, loaded/reconstructed engines, and the existing validated generated-plan
      runtime seam without deriving an observed index or changing emitted-source wrappers. Emit slot events after
      ordered identity proof and before effects from the matched end; emit one final success last after result
      construction; perform no event allocation or input hashing without a sink. Preserve exact callback exception
      identity and all result/cursor/trace/diagnostic/failure behavior. Add focused direct/loaded/reconstructed/
      traced/generated-plan-engine tests for field closure, Unicode scalar positions, event order, final omission on
      failure, absent-sink work, callback identity, and non-interference. Then run complete Julia, primary 5x2x66,
      ten Unicode legs, no-drift ledgers, canonical CI, mdBook/KM/memory/task/doctrines/diff, measured safe cleanup,
      and commit before derivation `.10.6.6.2`.

    #### Acceptance Checklist

    - [x] **TYPED API** — Export one immutable closed contract/event-kind/event/sink vocabulary with exact nullable
      field combinations and no host result values.
    - [x] **CAPTURE** — Emit accepted-slot events from matched-end scalar positions and exactly one successful final
      result last, with exact entry/input identity and no final event on thrown execution.
    - [x] **ROUTES** — Preserve the same sink through direct, execute, traced convenience, loaded, reconstructed,
      and validated generated-plan engine paths without entering `.3` emitted-wrapper ownership.
    - [x] **OMISSION / IDENTITY** — Prove absent sink allocates/hashes nothing, callback failures escape as the exact
      caller object, and results/cursors/traces/diagnostics/native failures remain byte/value identical.
    - [x] **LOCKSTEP / COMMIT** — Pass focused/complete/matrix/no-drift/canonical/book/KM/memory/task/doctrines/diff,
      exact safe cleanup, and commit before immutable observed-index derivation `.10.6.6.2`.

    Completion evidence: `LinkedSpecJulia` exports the immutable
    `linkedspec-semantic-execution-observation-v1` contract, closed regex-slot/rule-result enum, exact eight-field
    event, callback alias, stable non-mutable kind naming, and detached JSON projection. `runtime_parse`,
    `runtime_execute`, both traced conveniences, and validated generated-plan direct/traced helpers accept the
    invocation-local sink; loaded and normalized JSON-reconstructed engines reuse those seams. Accepted slots emit
    after ordered identity and before effects from the matched end converted to Unicode scalars. One normal result
    emits final success after `RuntimeParseResult` construction with exact UTF-8 input SHA-256. Exit/failure omits
    final success, and host result values never enter events.

    The new 66-assertion suite locks exact fields/JSON/order, direct/execute/traced/loaded/reconstructed/generated-
    plan routes, canonical positions 1/2/2 and input identity, multibyte `é🙂` positions/hash, result/cursor/trace/
    diagnostic equality, zero warmed allocation at both absent-sink helpers, exact caller exception identity, and
    final omission. All ten semantic suites compose at 1,129; complete Julia passes 8,671 package assertions plus
    primary process conformance and corpus 105/105. Primary 5x2x66 and all ten Unicode-manifest legs pass. Unicode
    806/9/8/2, semantic 6/20/81 at rollout 4/9 and admission 3/6, capability 80/0/0, generated
    v1/10/80-0-0, language 246/105+1/122, and public 59/27/0 remain exact. The public scan initially classified an
    unqualified test-only `hash(...)` as a retired selector spelling; qualifying Julia's `Base.hash` restored exact
    59/27/0 without product change.

    Canonical CI passes all four doctrines, Rust semantic admission 1/1 in 82.37 seconds, Dart 1/1, reference
    primary 66x2, and Phase 0 1,031/1,031 in 662 seconds. mdBook, Knowledge Map 692/5,330, bounded memory,
    task/marker/diff hygiene pass. Exact 1,892,380-KiB cleanup removes only generated Rust dependencies/incremental
    state, rendered book, Python bytecode, and the dedicated Julia compiled/log cache while preserving Julia
    package/registry caches and all 517 Pgen artifacts. Fresh emitted wrapper propagation and generated public
    signatures remain `.10.6.6.3`; strict event/topology validation, immutable observed-index derivation, and the
    twentieth digest remain `.10.6.6.2`. No generated-source v2/format 2 or semantic-ledger state changes.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.6.2`
    Status: `done` (2026-07-23; complete and fully verified from clean typed-capture commit `efd0474c`)
    Goal: Derive an immutable Julia semantic runtime snapshot from typed observations.
    Depends on: `.10.6.6.1`
    Acceptance: Validate event contracts/topology solely against detached static records/relations, require one
      final success, derive shapes from static facts, create canonical execution/event/`observed_as` records in a
      new snapshot, keep the base static, and match the twentieth typed/raw-neutral response digest.
    Verification plan: Add one public `with_execution_observation` derivation over an opaque base `SemanticIndex`
      and caller-retained `RuntimeSemanticObservationEvent` sequence. Reject a base that already has execution,
      non-events, foreign contracts, invalid nullable-field combinations, negative positions/indices, empty/
      reordered/duplicate-final sequences, wrong entry/input identity, and executing-rule/target/index selections
      unsupported by the base edge plus `selects_regex` topology. Consume only a fresh recursively immutable static
      projection; derive slot source/value shape from its selected edge and final source/result shape from its entry
      rule, never from host results/compiler/runtime/trace/diagnostic/path state. Clone the base into a new snapshot,
      add canonical `execution:0`, ordered event records, and `observed_as` relations, set `has_execution=true`, and
      prove base/derived/caller-event/query-response isolation. Match the exact twentieth typed and raw-neutral
      `runtime_events` digest, then run all eleven semantic suites, complete Julia/primary/corpus, primary 5x2x66,
      ten Unicode legs, no-drift ledgers, canonical CI, mdBook/KM/memory/task/doctrines/diff, measured safe cleanup,
      and commit before emitted/generated public propagation `.10.6.6.3`.

    #### Acceptance Checklist

    - [x] **STRICT INPUT** — Accept only the opaque static base and exact typed v1 events; validate closed field
      topology, nonnegative scalars, one successful final event last, selected entry, and stable input identity.
    - [x] **STATIC TOPOLOGY** — Map every slot only through detached executing-rule edge plus `selects_regex`
      evidence and derive all source/value/result shapes from existing immutable static records.
    - [x] **IMMUTABLE DERIVATION** — Return a fresh snapshot with canonical execution/event/`observed_as` records
      and `has_execution=true`; keep the base, caller events, and later query responses mutually isolated.
    - [x] **TWENTIETH DIGEST / NO EXECUTION** — Match typed/raw-neutral `runtime_events` digest
      `36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887` without compiling, executing, tracing,
      installing a sink, hashing new input, reading paths/host state, or changing rollout/admission.
    - [x] **LOCKSTEP / COMMIT** — Pass focused/complete/matrix/no-drift/canonical/book/KM/memory/task/doctrines/diff,
      exact safe cleanup, and commit before emitted/generated public propagation `.10.6.6.3`.

    Completion evidence: `LinkedSpecJulia` exports `with_execution_observation`, which accepts only an opaque
    compiled static base plus an exact vector of typed v1 events. It rejects 24 malformed/foreign/reordered/
    duplicate-final field sequences, failed/already-observed bases, wrong final entry, missing static slots, and an
    executing rule without the selected slot relation through the portable `execution_observation` /
    `semantic_index_invalid_observation` boundary. Slot source/shape derive from retained slot/edge facts and final
    source/shape from the selected entry rule; the implementation has no parser/compiler/runtime/trace/sink/hash/
    environment/file authority.

    A fresh recursively frozen projection adds canonical `execution:0`, three ordered event records, and exact
    `observed_as` relations/evidence while the base remains static. Caller event-vector and serialized-response
    mutation cannot change either index. Typed/raw-neutral `runtime_events` match exact twentieth digest
    `36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`. New proof passes 157 assertions; all
    eleven semantic suites compose at 1,286. Complete Julia passes 8,828 package assertions, primary process
    conformance, and corpus 105/105. Primary 5x2x66 and all ten Unicode-manifest legs pass. Governance remains
    Unicode 806/9/8/2, semantic 6/20/81 at rollout 4/9 and admission 3/6, capability 80/0/0, generated
    v1/10/80-0-0, language 246/105+1/122, and public 59/27/0.

    Canonical CI passes all four doctrines/contracts, Rust semantic admission 1/1 in 81.49 seconds, Dart 1/1,
    reference primary 66x2, and Phase 0 1,031/1,031 in 648 seconds. mdBook, Knowledge Map 693/5,341, bounded
    memory, task/marker/diff hygiene pass. Exact 1,738,560-KiB cleanup removes only generated Rust dependency/
    incremental outputs, rendered book, Python bytecode, and dedicated Julia compiled/log caches while preserving
    Julia package/registry caches and all 517 Pgen artifacts. Emitted/generated public propagation remains `.3`;
    no generated format, semantic rollout, or native-admission state changes.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.6.3`
    Status: `done` (2026-07-23; complete and fully verified from clean derivation commit `a5bdd0e6`)
    Goal: Preserve exact Julia observations through generated, emitted, and traced public routes.
    Depends on: `.10.6.6.2`
    Acceptance: Thread the sink through public generated helpers and fresh emitted modules, direct and traced; add
      semantic-specific callback passthrough before broad generated error translation; prove exact events/digest,
      result/cursor/trace/diagnostic equality, failure omission, and unchanged generated-source v2/format 2.
    Verification plan: Retrieve the Julia capture/derivation/authority cards and existing generated-source-v2
      ownership before source work. Audit the validated generated-plan helper signatures, emitter template, fresh
      emitted module metadata/functions, broad generated execution catches, trace/diagnostic callback wrappers,
      and isolated-host test harness. Extend only the generated/emitted public adapters needed to accept and forward
      the existing `RuntimeSemanticObservationSink`; keep event creation and observed-index derivation in their
      committed shared owners. Preserve exact semantic callback exception identity through any generated broad
      catch without reclassifying parser/trace/diagnostic failures. Add omission-sensitive fresh-emitted direct/
      traced and public-helper proof for canonical events/twentieth digest, result/cursor/trace/diagnostic equality,
      exit/failure final-event omission, no-sink output/source stability, isolated execution, and generated-source
      v2/format 2. Then run all twelve semantic suites, complete Julia/primary/corpus, primary 5x2x66, ten Unicode
      legs, no-drift ledgers, canonical CI, mdBook/KM/memory/task/doctrines/diff, measured safe cleanup, and commit
      before no-change composition `.10.6.6.4`.

    #### Acceptance Checklist

    - [x] **RETRIEVE / AUDIT** — Retrieve committed capture/derivation/generated authorities and map every public
      helper/emitted direct/traced signature plus broad callback translation before behavior changes.
    - [x] **PUBLIC PROPAGATION** — Thread the existing optional typed sink through generated helpers and fresh
      emitted module direct/traced entry points without duplicating capture or derivation owners.
    - [x] **IDENTITY / NON-INTERFERENCE** — Preserve exact caller callback failure identity and prove results,
      cursors, trace, diagnostics, exits, failures, and absent-sink behavior remain exact.
    - [x] **EVENTS / DIGEST / FORMAT** — Match canonical events and twentieth typed/raw digest through every new
      route while keeping generated-source contract v2 / format 2 and isolated-host execution stable.
    - [x] **LOCKSTEP / COMMIT** — Pass focused/complete/matrix/no-drift/canonical/book/KM/memory/task/doctrines/diff,
      exact safe cleanup, and commit before no-change composition closeout `.10.6.6.4`.

    Implementation evidence: the validated generated-plan helpers already accept the sink and preserve semantic
    callback identity, so only emitted module `execute` / `execute_with_trace` signatures and forwarding required
    production change. Event allocation/capture and `with_execution_observation` remain in their committed owners.
    The new 51-assertion route suite covers public helpers, a freshly included module, and an isolated Julia host;
    direct/traced routes preserve canonical events/twentieth digest, exact callback object identity, exit final-
    result omission, result/diagnostic/trace equality, deterministic source, and v2/format 2 metadata with the
    unchanged `{label, family}` plan. The first focused attempt exposed only Julia world-age in the dynamic-module
    test harness; `Base.invokelatest` at those freshly included calls corrected the harness without product change.
    New 51/focused 1,337 and complete Julia 8,879/primary/105 pass.

    Full primary passes 5x2x66 and all ten Unicode-manifest legs pass 1/1. Governance remains exact at Unicode
    806/9/8/2, semantic 6/20/81 with rollout 4/9 and admission 3/6, capability 80/0/0, generated
    v1/10/80-0-0, language 246/105+1/122, and public 59/27/0. Canonical CI passes all four doctrines/contracts,
    Rust semantic admission 1/1 in 79.78 seconds, Dart 1/1, reference primary 66x2, and Phase 0 1,031/1,031 in 637
    seconds. mdBook, Knowledge Map 694/5,348, bounded memory, task/marker/diff hygiene pass. Exact
    1,749,080-KiB cleanup removes only generated Rust dependency/incremental outputs, rendered book, Python
    bytecode, and dedicated Julia compiled/log caches while preserving Julia package/registry caches and all 517
    Pgen artifacts. No generated format, semantic rollout, or native-admission state changes; no-change composition
    `.10.6.6.4` waits for this leaf's clean commit.

  - ID: `FUTURE-PARITY-BACKLOG.10.6.6.4`
    Status: `done` (2026-07-23; no-change composition verified from clean propagation commit `bea0afe0`)
    Goal: Compose Julia runtime-observation signoff and close the parent.
    Depends on: `.10.6.6.3`
    Acceptance: Re-run static/runtime query, malformed observation, every route/non-interference/callback identity,
      complete Julia/neutral/canonical/docs/KM/cleanup proof; close `.10.6.6` without rollout/admission promotion.
    Verification plan: Change no production code, replacement test, fixture, contract, public API, generated
      format, runtime behavior, semantic rollout, or native admission. Retrieve the four committed Julia runtime-
      observation fact cards and clean `.1-.3` topology before proof. Recompose all twelve committed Julia semantic
      suites in owner order, including static/query validation, typed capture, malformed/topology derivation, public
      generated helpers, fresh emitted direct/traced wrappers, isolated host, callback identity, exit omission,
      exact twentieth digest, and result/diagnostic/trace non-interference. Then rerun complete Julia/primary/corpus,
      primary 5x2x66, all ten Unicode legs, every no-drift ledger, canonical CI, mdBook/KM/memory/task/doctrines/
      diff, and measured safe cleanup. Close `.10.6.6` only if the committed owners compose unchanged; keep Julia
      rollout 4/9 and native admission 3/6 until exact admission `.10.6.7`.

    #### Acceptance Checklist

    - [x] **RETRIEVE / COMPOSE** — Retrieve committed capture/derivation/generated-route authorities and recompose
      all twelve owner suites without replacement behavior or a closeout-only semantic implementation.
    - [x] **EXACT RUNTIME ANSWER** — Reconfirm canonical events, strict malformed/topology rejection, immutable
      observed projection, twentieth typed/raw digest, callback identity, exit omission, and non-interference.
    - [x] **ROUTES / FORMAT / OMISSION** — Reconfirm direct/loaded/reconstructed/generated-plan/public-helper/
      fresh-emitted/traced/isolated routes, absent-sink behavior, and unchanged generated-source v2/format 2.
    - [x] **NO PROMOTION** — Keep semantic rollout 4/9 and native admission 3/6; `.10.6.7` remains the sole Julia
      composed-admission owner.
    - [x] **LOCKSTEP / COMMIT** — Pass focused/complete/matrix/no-drift/canonical/book/KM/memory/task/doctrines/diff,
      exact safe cleanup, close parent `.10.6.6`, and commit before exact Julia admission `.10.6.7`.

    Completion evidence: The four committed authority/capture/derivation/generated-route facts and clean `.1-.3`
    topology were retrieved before proof. All twelve committed Julia semantic suites compose unchanged at exact
    `135+85+70+99+79+62+100+118+315+66+157+51=1,337`; complete Julia remains 8,879 package assertions plus
    primary process conformance and corpus 105/105. Primary passes 5x2x66 and all ten Unicode-manifest legs pass
    1/1. Governance remains Unicode 17.0.0 at 1563/1581/158/464/12 and 806/9/8/2, semantic 6/20/81 at rollout
    4/9 and admission 3/6, capability 80/0/0, generated v1/10/80-0-0, language 246/105+1/122, and public
    59/27/0. Canonical CI passes four doctrines, Rust semantic admission 1/1 in 77.95 seconds, Dart 1/1, reference
    primary 66x2, and Phase 0 1,031/1,031 in 627 seconds. mdBook, Knowledge Map 694/5,348, bounded memory,
    task/marker/doctrine/diff hygiene, and exact 1,736,920-KiB safe cleanup pass while preserving Julia
    package/registry caches and all 517 Pgen artifacts. No production code, replacement test, fixture, contract,
    API, generated format, runtime behavior, rollout, or admission changes. Parent `.10.6.6` is closed;
    `.10.6.7` stays pending awaiting director instruction.

- ID: `FUTURE-PARITY-BACKLOG.10.6.7`
  Status: `done` (2026-07-25; exact ordered Julia consumer admitted and parent closed)
  Goal: Admit the exact Julia semantic implementation and close `.10.6`.
  Depends on: `.10.6.6`
  Acceptance: Add one omission-sensitive ordered 12-role Julia consumer over strict text/bytes, compiled/failed/
    runtime snapshots, direct/loaded/reconstructed/generated-plan/public-helper/standalone-emitted direct/traced
    routes, typed/native-neutral JSON, all 20 digests, privacy/pages/budgets/errors/explain, no-execute immutability,
    and stale host/path/IR denial. Register it canonically, add independent Julia topology mutations, advance only
    Julia rollout/admission, pass complete Julia/primary/corpus/generated/canonical gates, synchronize all public
    state, and close `.10.6` cleanly before Lua `.10.7`.
  Verification plan: Add one additive `julia/test/semantic_introspection_julia_admission_test.jl` consumer that
    composes the already-committed source, compilation, static, call, query, observation, generated-plan, public-
    helper, fresh-emitted, and isolated-host owners without adding a second semantic implementation. Require the
    same ordered twelve roles as Perl/Rust/Dart exactly once. Exercise direct, loaded, JSON-reconstructed,
    generated-plan, public generated-helper, freshly included emitted direct/traced, standalone isolated emitted,
    and native traced routes against the exact event sequence and twentieth digest. Match all twenty typed and
    neutral response digests, mutate detached request/response values without authority changes, verify privacy/
    paging/budget/error/explanation outcomes, scan the query owner for forbidden execution/compile/trace/path
    authority, and deny host paths, Julia type names, AST/ActionIR, observation types, generated implementation
    source, object displays, and pointer-like leakage in portable JSON. Register the file in `julia/test/runtests.jl`,
    `tools/run_ci_local.sh`, the contract's canonical file inventory, and the neutral checker. Promote only the
    Julia admission and `julia_parity` rollout rows. Add eight Julia-specific topology mutations matching the
    admitted Dart boundary, then pass focused admission, all twelve semantic suites plus admission, complete Julia
    package/primary/corpus, neutral/capability/generated/language/public ledgers, canonical CI, mdBook/Knowledge
    Map/memory/task/doctrines/diff, and safe artifact cleanup before closing `.10.6.7` and parent `.10.6`.

  #### Acceptance Checklist

  - [x] **RETRIEVE / PRECONDITION** — Retrieve the committed Julia semantic facts and all three admitted consumer
    topologies; confirm clean `48b7d96d`, exact 20 digests, 81 mutations, rollout 4/9, and admission 3/6.
  - [x] **ORDERED CONSUMER** — One Julia file declares and executes the exact twelve roles once, with no alternate
    semantic model/query/runtime owner.
  - [x] **SNAPSHOTS / QUERIES** — Strict text/bytes, compiled/failed/runtime snapshots, typed/raw-neutral identity,
    all twenty hashes, privacy/pages/budgets/errors/explain, immutability, and no-execution behavior are exact.
  - [x] **RUNTIME ROUTES** — Direct, loaded, reconstructed, generated-plan, public-helper, freshly emitted direct/
    traced, standalone isolated emitted, and native traced routes preserve results, events, and the twentieth hash.
  - [x] **HOST DENIAL** — Portable answers and the detached evaluator expose no host path, Julia type/layout,
    source AST/ActionIR, runtime observation object, generated implementation source, trace, or pointer identity.
  - [x] **TOPOLOGY / PROMOTION** — Canonical registration and eight independent Julia omission mutations pass;
    only Julia rollout/admission advances, leaving Lua, recurring, MCP, and public rows pending.
  - [x] **LOCKSTEP / CLOSE** — Complete focused/backend/matrix/ledger/canonical/docs/KM/doctrine/diff/cleanup proof
    passes; synchronize public state, close `.10.6.7` and `.10.6`, and commit cleanly before Lua `.10.7`.

  Planning evidence: From clean `48b7d96d`, startup review covered both roadmaps, the code/import and active Julia
  semantic owner chain, all 46 mdBook pages, ADRs `0049`/`0050`/`0051`, Knowledge Map authorities, `TOOLBOX.md`,
  all three admitted consumers, the neutral checker/contract, Julia registration, and the exact pending leaf.
  The behavior-free activation passes memory architecture, all four doctrine checks, Knowledge Map derivation,
  mdBook build, diff hygiene, and the neutral semantic checker at 6 groups / 20 responses / 81 mutations /
  rollout 4/9 / admission 3/6. Implementation remains the next action after this planning commit.

  Completion evidence: Planning commit `20c5b2bb` is the clean task-tree boundary. The additive
  `julia/test/semantic_introspection_julia_admission_test.jl` consumer declares and executes the exact twelve roles
  once while reusing only committed semantic owners. It covers every required snapshot, query, privacy/budget/
  paging/error/explain/non-interference/host-denial boundary and every direct/loaded/reconstructed/generated/
  emitted/traced/isolated runtime route. Focused admission passes 416/416; all thirteen Julia semantic suites pass
  1,753; complete Julia passes 9,295 package assertions plus primary process conformance and corpus 105/105. The
  neutral checker rejects 89 mutations and advances only Julia to rollout 5/9 and native admission 4/6. Primary
  passes 5x2x66 and all ten Unicode legs pass 1/1. Unicode 1563/1581/158/464/12 and 806/9/8/2, capability
  80/0/0, generated v1/10/80-0-0, language 246/105+1/122, public 59/27/0, Knowledge Map 695/5,358, and mdBook
  all pass. Canonical CI passes all four doctrines/contracts, Rust admission 1/1 in 78.60s, Dart 1/1, Julia
  416/416 in 27.6s, reference primary 66x2, and Phase 0 1,031/1,031 in 636s. Its first run correctly caught a
  compressed-memory omission of the closed repeated-action `FUTURE-PARITY-BACKLOG.10.1` handoff marker; exact
  restoration passes the focused 8/10/8+0/54 checker and the complete restart. Exact 1,632,888-KiB cleanup removes
  only generated Rust deps/incrementals, rendered book, Python bytecode, Dart tool state, and the task Julia depot.
  `.10.6.7` and parent `.10.6` close; PUC Lua/LuaJIT `.10.7` is the next task-tree-first PNT slice.

<!-- Source ranges and their immutable migration digest are recorded in docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl. -->
