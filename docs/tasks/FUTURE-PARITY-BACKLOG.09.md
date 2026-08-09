- ID: `FUTURE-PARITY-BACKLOG.9`
  Status: `done`
  Goal: Revisit AND/OR edge defaults and top-rule ceremony as future `.spec` language design.
  Children: `.9.0`, `.9.1`
  Acceptance: The director's correction to edge defaults is durable, design work is split before implementation,
    and any later implementation keeps Perl/Rust/Dart semantics aligned instead of silently changing one backend.
  Verification: **PASS 2026-07-20.** Child `.9.0` captures the direction and `.9.1` closes the complete neutral,
    five-backend, recurring, and public AND/OR semantic rollout. No child remains active or pending.

- ID: `FUTURE-PARITY-BACKLOG.9.0`
  Status: `done`
  Goal: Capture the director's corrected AND/OR edge-default model.
  Acceptance: The task tree, index, roadmap/live docs, mdBook, resume pointer, and Knowledge Map record the future
    arc without changing parser/runtime behavior or pivoting away from the Dart frontier.
  Verification: **PASS 2026-07-09.** `git diff --check`, memory architecture, Knowledge Map generation/check,
    task-tree metadata, doctrine, and mdBook build pass. No implementation code changed.
  Commit: `FUTURE-PARITY-BACKLOG.9.0 - capture AND OR edge default correction`

- ID: `FUTURE-PARITY-BACKLOG.9.1`
  Status: `done`
  Goal: Ratify and dependency-order the corrected AND/OR edge-default and cursor contract before rollout.
  Children: `.9.1.0`, `.9.1.1`, `.9.1.2`, `.9.1.3`, `.9.1.4`, `.9.1.5`, `.9.1.6`, `.9.1.7`, `.9.1.8`,
    `.9.1.8.1`, `.9.1.9`, `.9.1.10`
  Acceptance: Specify grammar and runtime semantics for mode-sensitive bare edge lines. In AND rules (`:&`, `::&`,
    `:AND`, `::AND`, and bounded/repeated variants), a bare `entry { ... }` line should mean an explicit
    blind-call `=> entry { ... }`; in OR/default rules, a bare `entry { ... }` line should mean an explicit
    action-edge `-> entry { ... }`. Decide whether explicit `->` action-edges remain legal in AND rules, whether
    explicit `=>` blind-calls remain legal in OR rules, how this composes with `entry[k]`, fluent `.push` /
    `.return(...)` continuations, grouped/shared blocks, and diagnostics for ambiguous cases. Keep the boundary
    clear: blind-call means the parent does not preselect by the child rule's regex; the called child rule owns its
    own parser/matching semantics, and parent mode never propagates to or overrides it. Treat
    first-rule-as-top instead of `::` and optional OR pipe sugar as separate decisions under this design leaf.
    Resolve cursor ownership as part of the same rule-kind contract: audit the proposal that OR/default rules are
    intrinsically seek and AND rules are intrinsically consume, with no public/global `parse_mode` override capable
    of contradicting the rule kind. Retain an override only if the audit proves a concrete semantic objective that
    cannot be expressed by rule kind or ordinary grammar composition.
  Verification: **PASS 2026-07-20.** ADR `0044` rule-local cursor/bare-edge semantics, root selection, duplicate
    slot identity, and ADR `0048` repeated-action result shape are implemented across Perl, Rust, Dart, Julia,
    PUC Lua, and LuaJIT. Exact recurring and public no-drift gates are closed; every declared child is done.
  Commit: closed by the complete child commit series through `FUTURE-PARITY-BACKLOG.9.1.10.7`

- ID: `FUTURE-PARITY-BACKLOG.9.1.0`
  Status: `done`
  Goal: Audit cursor-semantic ownership and every current `parse_mode` override path before choosing compatibility.
  Acceptance: Use the Knowledge Map and LinkedSpec toolbox first; trace Perl/Rust/Dart/Julia/Lua parser construction,
    descriptors/generated plans, primary CLI fixtures, nested rule dispatch, top-rule behavior, tests, and public
    documentation. Distinguish rule-local AND/OR matching semantics from caller-selected entry policy and historical
    plumbing. Inventory every default, explicit seek/consume use, contradictory combination, and compatibility
    dependency. Produce a concrete objective test for retaining any public override; if none exists, recommend that
    OR/default rules intrinsically seek and AND rules intrinsically consume and specify the migration/diagnostic
    boundary without changing runtime behavior in this audit leaf.
  Checklist:
  - [x] **RETRIEVE / TOOLBOX FIRST** — Check the Knowledge Map and use the Perl descriptor, lowering, generated-
    source, and live-execution probes before reading implementation seams or classifying behavior.
  - [x] **FIVE-BACKEND INVENTORY** — Trace public APIs, primary commands, parser/engine construction, compiled
    state, rule dispatch, loaded-spec factories, generated roles, descriptors, tests, and current documentation
    across Perl, Rust, Dart, Julia, and Lua.
  - [x] **EXACT DEFAULT / EXPLICIT PROBE** — Prove the same one-regex `Top::AND` and leading-junk input under
    omitted, explicit-seek, and explicit-consume policy on all five backends; root-cause the default disagreement
    and identify the missing shared-matrix case.
  - [x] **OBJECTIVE TEST** — Prove that AND+seek is ordered-landmark extraction and OR+consume is anchored choice,
    while distinguishing those real low-level algorithms from a caller-global switch that mutates all nested rules.
  - [x] **RECOMMEND / MIGRATE** — Recommend intrinsic OR/default seek and AND consume, retain low-level matcher
    primitives, remove public/global override rather than ignore it, replace global descriptor metadata with
    derived per-rule facts, and enumerate the API/CLI/generated/test/documentation migration surface.
  - [x] **LOCKSTEP / NO BEHAVIOR CHANGE** — Record the audit, parity defect, recommendation, and one unresolved
    blind-call child-ownership decision in the task tree, roadmaps, live docs, mdBook, guides, architecture, and
    Knowledge Map without changing parser/compiler/runtime/descriptor/generated/CLI/fixture/capability behavior.
  Verification: **PASS 2026-07-16.** Exact five-backend probes show default `Top::AND` over `prefix x` returns
    `"hit"` on Perl/Dart/Julia/Lua and null on Rust; explicit seek returns `"hit"` and explicit consume returns null
    on all five. Perl toolbox evidence and five-backend source tracing identify global mode ownership versus Rust's
    derived per-rule mode plus execution override. Cross-combination probes establish the legitimate matcher
    algorithms but no objective for a caller-global grammar rewrite. Governance, Knowledge Map, mdBook, and
    whitespace checks pass; no runtime behavior changes.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.0 - audit cursor semantic ownership`

- ID: `FUTURE-PARITY-BACKLOG.9.1.1`
  Status: `done`
  Goal: Ratify the corrected AND/OR edge and cursor-semantics contract before implementation.
  Dependencies: `.9.1.0`
  Children: `.9.1.1.0`, `.9.1.1.1`, `.9.1.1.2`
  Acceptance: Convert the measured audit into one backend-neutral grammar/runtime decision covering bare and
    explicit edges, indexed/grouped/fluent forms, nested calls, intrinsic cursor behavior, public API/CLI migration,
    descriptor/generated metadata, invalid legacy combinations, and cross-backend conformance. Keep implementation
    in a separately split follow-on leaf and return to `.5.2.3` after the design commitment is cleanly committed.
  Verification: Cursor/edge design is complete: `.9.1.1.0` fixes nested child ownership and `.9.1.1.1` adopts
    ADR `0044` plus the exact implementation split. Director clarification on 2026-07-18 resolves the separately
    parked entry-selection question; `.9.1.1.2` owns and completes its neutral decision, five-backend rollout,
    recurring proof, and public no-drift. Closure inventory on 2026-07-20 found this parent still marked active
    after every child and nested child was done; `.9.1.10.7` corrects that stale status under executable closure.
  Commit: `.9.1.1.0` and `.9.1.1.1` commit rows below

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.0`
  Status: `done`
  Goal: Capture the director's rule-local child cursor-ownership decision before a fresh-session handoff.
  Acceptance: Record that a parent OR/AND mode never propagates to or overrides any child OR/AND mode. An OR child
    retains intrinsic seek behavior when called from an AND parent; an AND child retains intrinsic consume behavior
    when called from an OR parent. The rule holds across blind calls, action-edge dispatch, explicit `call(...)`,
    and recursion. Preserve the audit recommendation that callers cannot override rule semantics; leave exact
    edge grammar, migration, implementation split, and runtime behavior to `.9.1.1.1` and its follow-ons. Align the
    task tree, roadmap, live docs, mdBook status, bounded memory, and Knowledge Map; change no behavior code.
  Verification: **PASS 2026-07-17.** Director confirmation is recorded in one durable fact and every current-
    frontier document. Knowledge Map generation/check, memory architecture, task metadata, doctrine, mdBook,
    and whitespace checks pass. No parser/compiler/runtime/generated/descriptor/CLI/test/capability behavior changes.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.0 - capture rule-local cursor ownership`

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.1`
  Status: `done`
  Goal: Ratify the complete backend-neutral AND/OR edge, cursor, and migration contract before implementation.
  Dependencies: `.9.1.1.0`
  Acceptance: Turn the accepted rule-local ownership principle and `.9.1.0` audit into the exact grammar/runtime/
    descriptor/API/CLI/generated/conformance decision required by parent `.9.1.1`; split implementation into
    separate dependency-ordered leaves, then return to `.5.2.3` only after a clean decision commit.
  Verification: **PASS 2026-07-17.** ADR `0044` fixes intrinsic family policy, child ownership, line-level bare
    normalization, explicit cross-family legality, indexed/grouped/fluent/reserved/mixed boundaries, structural
    cross-combination recipes, targeted API/CLI removal, derived descriptor facts, generated-source v2 family
    derivation, portable diagnostics, and complete conformance scope. Eight dependency-ordered implementation
    leaves are pending. Knowledge Map, memory architecture, task metadata, doctrines, mdBook, and whitespace pass;
    no parser/compiler/runtime/descriptor/generated/CLI/fixture/test/capability behavior changed.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.1 - ratify rule-local cursor and bare edges`

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2`
  Status: `done`
  Goal: Ratify and implement deterministic root-rule selection without requiring a `::` marker.
  Dependencies: `.9.1.5.5`
  Children: `.9.1.1.2.0`, `.9.1.1.2.1`, `.9.1.1.2.2`, `.9.1.1.2.3`, `.9.1.1.2.4`, `.9.1.1.2.5`,
    `.9.1.1.2.6`
  Acceptance: Apply one backend-neutral precedence: an explicit entry selector, including CLI
    `--top-rule NAME`, has highest priority and may select any declared rule; without an explicit selector, the
    first authored `Rule::` in definition order is the default; when no rule uses `::`, the first authored
    ordinary `Rule:` is the default. A spec with zero rules remains invalid, an unknown explicit name remains an
    error, authored `is_top` metadata remains source identity rather than dynamic selection state, and every
    compiler, validator, runtime, loaded/generated route, strict-unused check, descriptor, trace, CLI, neutral
    fixture, backend, and mdBook statement must agree.
  Verification: **PASS 2026-07-19.** Neutral decision `.0`, composed Perl/Rust/Dart/Julia/dual-ABI Lua `.1-.5`,
    and final recurring/public no-drift `.6` are complete. The exact six-runtime plus 5x2x6 recurring gate passes;
    governance is 7 complete / 0 pending with 54 rejected mutations, 25 required current documents, and 19 stale-
    claim guards. Canonical CI passes primary 65/65x2 and Phase 0 1,031/1,031 in 642 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.6 - close root selection parity`

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.0`
  Status: `done`
  Goal: Ratify the exact root-selection precedence and make it executable as a neutral contract before behavior.
  Dependencies: `.9.1.1.2`
  Acceptance: Update/supersede ADR `0010` as needed; inventory all five backends plus reference validation and
    explicit-selector seams; define marker, first-rule fallback, explicit override, multiple-marker definition
    order, empty-spec, unknown-selector, strict-unused, descriptor/generated/trace, and CLI outcomes; add a strict
    neutral fixture/checker with mutations; split or confirm the implementation leaves; change no runtime behavior.
  Verification: **PASS 2026-07-18.** ADR `0046` supersedes only ADR `0010`'s
    selection/marker-required boundary. Exact audit: Perl requires a marker yet defaults to parsed row zero;
    Rust requires/defaults to the first marker and exposes explicit selection only on value/primary routes;
    Dart/Julia/Lua require a marker while their runtime/generated helpers already implement marker-then-first
    fallback. The shared CLI already proves an explicit ordinary rule beats two markers. Strict-unused remains
    defined-minus-authored-references with no selection/marker reference or exemption. The executable contract
    locks 8 selections, 3 failures, 3 strict cases, 8 execution routes, 5 inventory rows, 7 rollout legs, and 24
    mutations at 1 complete / 6 pending. JSON, Python compile, checker, Knowledge Map 594/4,238, memory/task/all
    four doctrines, mdBook build, and whitespace pass; no backend behavior file changed. Canonical CI repeats the
    neutral checker, Perl cursor admission 288, reference primary 63/63 in default and POSIX environments, and
    Phase 0 1,031/1,031 in 642 seconds before exit 0.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.0 - ratify root rule selection`

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.1`
  Status: `done`
  Goal: Implement root-selection precedence on the Perl reference.
  Dependencies: `.9.1.1.2.0`
  Children: `.9.1.1.2.1.0`, `.9.1.1.2.1.1`, `.9.1.1.2.1.2`, `.9.1.1.2.1.3`
  Acceptance: Make validation, compilation, `Get`/`get_parser`, generated source, trace/diagnostics, strict checks,
    and the primary command consume the neutral contract; add focused and Phase 0 proof without compatibility
    guessing or changing ordinary rule execution.
  Verification: **PASS 2026-07-18.** Leaves `.0-.3` map, implement, converge, and admit one exact Perl reference.
    Markerless validation, ordered explicit/first-marker/first-rule resolution, immutable authored identity,
    descriptor/generated metadata, loaded/reconstructed/generated direct/traced/Get execution, structured
    diagnostics, runtime/request trace, strict-unused no-drift, and primary bytes all consume the neutral contract.
    The topology-checked core/routes pair passes 12 tests; focused root/generated/CLI proof passes 5 files / 27
    tests; the shared primary manifest passes 65/65 twice. Root governance rejects 24 mutations at 2 complete / 5
    pending. Knowledge Map is 598/4,277; book, memory, task, all four doctrines, syntax, whitespace, and cleanup
    pass. Canonical CI repeats root core 7, routes 5, cursor admission 288, primary 65x2, and Phase 0 1,031/1,031 in
    611 seconds before exit 0. No non-Perl rollout row or runtime implementation changed.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.3 - admit Perl root selection`

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.0`
  Status: `done`
  Goal: Map the exact Perl root-selection seams and freeze a dependency-safe implementation/admission plan.
  Dependencies: `.9.1.1.2.1`
  Acceptance: Use LinkedSpec probes plus source/test retrieval to inventory envelope/paragraph validation, parsed
    order and marker retention, requested/default selection, runtime context, `Get`/`get_parser`, descriptor,
    generated source, trace/diagnostics, strict-unused, primary CLI, and shared conformance; record exact current
    failures and split `.1-.3` without changing behavior.
  Verification: **PASS 2026-07-18.** Read-only TOOLBOX probes plus exact owner/test retrieval map every required
    seam without editing executable behavior. Envelope validation accepts the first rule shape but separately
    rejects markerless sources; comment-only/zero-rule input fails first. Bootstrap preserves definition order and
    emits `ELABEL` for ordinary headers plus `ELABEL_INITIAL` for every marker. RuleIR temporarily retains each
    marker, but SpecEntry omits authored `is_top` from rule metadata; Compiler finally overwrites discovered marker
    state with explicit `top_rule` or parsed row zero. Descriptor order is exact but `is_top` is absent. Generated
    v2 keeps label/family rows and hardcodes that compiler-selected label for direct/traced execution. `get_parser`
    forwards the same options, and the primary request trace already distinguishes a requested label from
    `<default>`. Unknown explicit selection compiles and fails only at invocation with
    `resolve_top_rule_handler`, not the target portable code/stage. Direct strict validation remains
    defined-minus-authored-edge references and rejects an unreferenced marked Top; `Get(strict_syntax => 1)` does
    not forward strict mode, so root work will preserve the validator contract without inventing a compiler API.
    The dependency order is frozen as `.1.1` core/metadata, `.1.2` loaded/generated/trace/diagnostics, and `.1.3`
    composed/reference-first CLI admission. Knowledge card and mdBook record the complete causal map. Focused
    existing primary cases pass 2/2 in default and POSIX environments; generated-source proof passes 6/6. Root
    checker passes 8/3/3/5 at 1/6 with 24 mutations; Knowledge Map passes 595 facts / 4,248 keys; memory/task/four
    doctrines/mdBook/whitespace pass. Canonical CI repeats cursor admission 288, reference primary 63/63 twice,
    and Phase 0 1,031/1,031 in 632 seconds before exit 0.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.0 - map Perl root selection`

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.1`
  Status: `done`
  Goal: Implement Perl validation, ordered default selection, and authored marker identity.
  Dependencies: `.9.1.1.2.1.0`
  Acceptance: Accept one-or-more-rule markerless sources, reject zero rules before selection, preserve first marker
    and definition order, make explicit selection win, reject unknown selectors before user code, preserve strict-
    unused graph semantics, and project authored `is_top` without changing ordinary rule execution.
  Verification: **PASS 2026-07-18.** `LinkedSpec::EntryRuleSelection` now owns one ordered
    explicit/first-marker/first-rule resolver. Perl accepts one-or-more-rule markerless sources, reports zero rules
    as `no_rules_defined` / `validate_spec`, and records unknown explicit labels as `entry_rule_not_found` /
    `select_entry_rule` before handler lookup while preserving compile-before-input primary ordering. RuleIR and
    the descriptor retain exact order plus immutable normalized `is_top`; root metadata publishes
    `linkedspec-root-rule-selection-v1`. Explicit execution does not rewrite authored marker identity. Direct
    strict-unused remains authored-edge graph analysis and `Get(strict_syntax => 1)` remains unwired. The focused
    consumer passes all 8 neutral selections, 3 failures, native marked/markerless/explicit execution, descriptor,
    zero/unknown diagnostics, and strict boundaries; validation fuzz and native loading pass. The first canonical
    run correctly exposed an obsolete native-loading fixture whose single markerless rule had become valid; it now
    uses a duplicate rule to retain its intended validation-stage assertion. Root governance remains 8/3/3/5 at
    1/6 with 24 mutations; Knowledge Map is 596/4,258; memory/task/four doctrines, mdBook, and whitespace pass.
    Canonical CI passes cursor admission 288, primary 63/63 twice, and Phase 0 1,031/1,031 in 609 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.1 - implement Perl root resolution`

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.2`
  Status: `done`
  Goal: Align Perl loaded/generated execution plus trace and diagnostics with the effective entry rule.
  Dependencies: `.9.1.1.2.1.1`
  Acceptance: Make `Get`, `get_parser`, returned parsers, generated-source direct/traced/get roles, runtime context,
    structured failure attribution, and request-versus-effective trace identity consume the same resolver without
    serializing an explicit selector as authored marker state.
  Verification: **PASS 2026-07-18.** Generated Perl v2 source retains its unchanged minimal ordered
    `{label,family}` plan and separately embeds ordered authored `{label,is_top}` entry rows. Metadata publishes
    `linkedspec-root-rule-selection-v1` plus those immutable rows. Generated `Execute`, `ExecuteWithTrace`, and
    `Get` resolve every invocation through `EntryRuleSelection`; invocation-local `top_rule` overrides configured
    emission selection, then defaulting uses first marker / first rule. Unknown selection fails before user code as
    structured `generated_source_error` with `entry_rule_not_found` / `select_entry_rule`, requested rule, and
    source identity. Successful selection drives execution family, error attribution, and the new
    `generated_entry_selection` label/family/basis/status trace before existing enter/family/exit roles. Loaded
    `get_parser` and portable `SpecLoader` share the same resolver/runtime-context identity. The focused route and
    seven adjacent suites pass 8 files / 49 tests; standalone and canonical Phase 0 each pass 1,031/1,031, with the
    canonical run completing in 610 seconds. Root governance remains 8/3/3/5 at 1/6 plus 24 mutations; generated
    governance is 80/0/0; Knowledge Map is 597/4,269; mdBook, memory/task/four doctrines, syntax, whitespace, and
    cleanup pass. Canonical CI also passes the new 5-test route consumer, generated-source 6, cursor admission 288,
    and reference primary 63/63 twice. Shared CLI/public admission and rollout promotion remain `.1.3` only.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.2 - converge Perl root execution`

  #### Acceptance checklist

  - [x] **REPRODUCE / ISSUE** — `LinkedSpec::Get` plus `emit_generated_source`/isolated-package execution over an
    earlier ordinary rule, two markers, explicit ordinary/later/missing selectors proves native default/explicit
    values and runtime `top_rule` are correct, while generated `Execute` ignores invocation `top_rule`, silently
    runs the emitted label for an unknown selector, and lets an emission-time selector remain authoritative.
  - [x] **ROOT CAUSE (WHY + WHERE)** — `dump_parser_source` and `Compiler::_generated_source_postamble` show one
    compiler-selected `$top_rule_literal`/family hardcoded into generated `Execute`, `ExecuteWithTrace`, and `Get`;
    the v2 plan contains only `{label,family}`, so independently loaded source lacks ordered authored `is_top`
    identity and cannot run `EntryRuleSelection` at invocation.
  - [x] **FIX** — Preserve ordered authored entry rows beside the unchanged v2 family plan, resolve configured or
    invocation-local `top_rule` through the shared resolver, and use the effective label/family for execution,
    trace, and structured selection/execution failures.
  - [x] **ADDRESSED (verified)** — Lock live, loaded, generated direct/traced/Get, markerless, explicit, configured,
    unknown, runtime-context, trace, source-identity, and diagnostic outcomes in one focused Perl route suite.
  - [x] **NO REGRESSION** — Focused generated/loading/trace suites and full `PERL5LIB=` Phase 0 reach their true
    stops with no new failure names; touched modules compile and canonical CI passes.
  - [x] **LOCKSTEP** — Update generated API/book text, task/live docs, Knowledge Map, recurring CI, governance,
    cleanup, and memory before the clean commit; leave rollout promotion and shared CLI admission to `.1.3`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.3`
  Status: `done`
  Goal: Admit the complete Perl root-selection contract and reference primary bytes.
  Dependencies: `.9.1.1.2.1.2`
  Acceptance: Add one topology-checked Perl consumer for all neutral routes and failures; migrate shared CLI cases
    reference-first for marker/markerless/default/explicit/unknown behavior; advance only the Perl rollout row;
    update live docs/mdBook and correct the stale marker-required entry-model sentence in `TOOLBOX.md`; pass
    focused, 65x2 primary, Phase 0, and canonical signoff; close parent `.1`.
  Verification: **PASS 2026-07-18.** The shared manifest adds exact first-marker and markerless-default cases
    beside explicit ordinary, unknown-selector, default request-trace, and escaped explicit trace boundaries. Perl
    passes all 65 exact cases with `POSIXLY_CORRECT` unset and set. The independent checker now requires the
    neutral selection/failure/strict core consumer, loaded/SpecLoader/generated/metadata/configured-failure/trace
    routes consumer, canonical registration, and exact CLI/trace topology; it rejects all 24 mutations and advances
    only `perl_reference`, reaching 2 complete / 5 pending. Focused root/generated/CLI proof passes 5 files / 27
    tests; Knowledge Map is 598/4,277; capability/docs/toolbox/book/live/memory/task/doctrine/whitespace/cleanup
    lockstep passes. Canonical CI passes root core 7, routes 5, cursor admission 288, primary 65x2, and Phase 0
    1,031/1,031 in 611 seconds, then exits 0. Parent `.1` closes; Rust `.2` is next only after the clean commit.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.1.3 - admit Perl root selection`

  #### Acceptance checklist

  - [x] **REPRODUCE / ISSUE** — Knowledge Map plus canonical runner prove the existing explicit/unknown/default-
    request/failure-trace cases 4/4 in both default and POSIX environments. Exact candidate primary probes return
    `"marked"` for earlier ordinary + two markers and `"first"` for markerless two-rule source. Yet the shared
    manifest has only explicit/unknown root cases, the root checker topology requires only the explicit case, the
    rollout stays 1/6, and `TOOLBOX.md` still says a `.spec` requires `::`.
  - [x] **ROOT CAUSE (WHY + WHERE)** — No remaining Perl engine/adapter defect: `bin/linkedspec` forwards
    `top_rule`, delegates omission to the compiled resolver, preserves request trace, and normalizes unknown
    invocation failure correctly. Drift is admission-only: `cli_conformance/manifest.json` lacks first-marker and
    markerless-default bytes; `tools/check_root_rule_selection_contract.py` does not topology-check those cases or
    the complete core/routes consumers; capability rollout/public text remain deliberately pending/stale.
  - [x] **FIX** — Compose one topology-checked Perl admission consumer plus reference-first shared CLI cases for
    marker, markerless, default, explicit, and unknown selection; correct only the owned public/toolbox drift and
    advance only the Perl rollout row.
  - [x] **ADDRESSED (verified)** — Prove every neutral Perl route/failure and exact primary stdout/stderr/exit/
    request-trace byte case through recurring focused and canonical gates, then close parent `.1`.
  - [x] **NO REGRESSION** — Focused Perl/root/generated/CLI suites, primary 65x2, Phase 0, neutral
    checkers, mdBook, and canonical CI pass with no backend rollout change beyond Perl.
  - [x] **LOCKSTEP** — Update capability inventory/rollout, `TOOLBOX.md`, mdBook, Knowledge Map, task/live docs,
    recurring CI, cleanup, and memory before the clean commit; leave Rust and later backend leaves pending.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.2`
  Status: `done`
  Goal: Implement root-selection precedence on Rust.
  Dependencies: `.9.1.1.2.1`
  Children: `.9.1.1.2.2.0`, `.9.1.1.2.2.1`, `.9.1.1.2.2.2`, `.9.1.1.2.2.3`
  Acceptance: Align parser/validation, core/runtime, loaded/serialized/generated execution, descriptor/trace,
    strict checks, and primary CLI with the unchanged neutral contract and Perl reference bytes.
  Verification: **PASS 2026-07-18.** Preflight, core, composed routes, and one topology-checked 15-role admission
    consumer pass 29 drift mutations and exact primary 65x2. Complete Rust-local and canonical proof pass;
    public/mdBook/capability/live/Knowledge Map records agree at 3 complete / 4 pending, and cleanup is complete.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.3 - admit Rust root selection`

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.0`
  Status: `done`
  Goal: Map every Rust root-selection seam and freeze a dependency-safe implementation/admission plan.
  Dependencies: `.9.1.1.2.2`
  Acceptance: Use Knowledge Map, LinkedSpec contract/toolbox probes, exact source/test retrieval, and focused
    command execution to inventory parser/validation order and marker retention; requested/default selection;
    native runtime, loaded/serialized/reconstructed and generated/emitted routes; descriptors; traces/diagnostics;
    strict-unused; primary CLI/shared bytes; recurring gates; and current failure boundaries. Split `.2.1-.3`
    without changing Rust behavior.
  Verification: **PASS 2026-07-18.** Exact source retrieval plus focused existing tests map parser/validation,
    native, loaded, serialized/reconstructed, descriptor, generated/emitted, diagnostics, trace, strict, CLI, and
    recurring-gate seams without changing Rust behavior. Shared primary proof is exactly 64/65 with
    `POSIXLY_CORRECT` unset and set: explicit ordinary selection, first-marker default, unknown failure, request
    trace, and every unrelated case pass; markerless fallback alone fails at validation with compile exit 1.
    Validation 18, descriptor 4, types 8, native explicit entry 1, diagnostics 5, loader 5, trace 10, and generated
    contract 1+1 pass. Root checker 8/3/3/5 with 24 mutations, Knowledge Map 599/4,291, mdBook, memory/task, all
    four doctrines, and whitespace pass. Canonical CI passes root core 7, routes 5, cursor admission 288, primary
    65x2, and Phase 0 1,031/1,031 in 627 seconds. The durable Knowledge Map card freezes `.2.1-.3` order and
    excludes staged parse-job `top_rule` identity from this contract. Post-verification cleanup removes 15,136
    Cargo artifacts / 3.3 GiB, the 11 MiB generated mdBook tree, and Python bytecode cache.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.0 - map Rust root selection`

  #### Acceptance checklist

  - [x] **RETRIEVE / PRECEDENT** — Read the neutral root contract, ADR `0046`, Perl admission facts, Rust
    cursor/generated/descriptor/CLI facts, toolbox, and exact current Rust owners/tests before probing or planning.
    Parser/compiler already preserve ordered authored markers; the staged parser registry's `top_rule` is separate
    parse-job grammar identity and is explicitly excluded.
  - [x] **REPRODUCE / ISSUE** — Prove current explicit, first-marker, multiple-marker, markerless, unknown, strict,
    descriptor, loaded/reconstructed/generated/emitted, trace, and primary boundaries with the narrowest real
    commands; record exact values, errors, stages, and shared-manifest case count. Full default and POSIX runners
    each pass 64/65: only markerless fails with empty stdout, compile exit 1, and
    `linkedspec: parser compilation failed`; all other primary/trace bytes pass.
  - [x] **ROOT CAUSE / INVENTORY** — Trace every divergence to its parser/validator/compiler/runtime/adapter owner;
    distinguish already-correct mechanisms from unreachable fallbacks, missing authored identity, or route drift.
    `check_top_rule_exists` blocks markerless/zero-rule source; AST/compiled `top_rule()` are marker-only; direct
    `ExecutionOptions` explicit selection is correct but its diagnostic stage/code are old; generated/emitted APIs
    have no selector. Ordered serde and descriptor identity are already correct.
  - [x] **SAFE SPLIT** — Confirm or refine `.2.1` core identity/resolution, `.2.2` composed execution/metadata/trace,
    and `.2.3` reference-byte admission so each later change is bounded and leaves canonical Perl green.
    `.2.1` owns marker-optional validation, one resolver, native selection/diagnostics, and contract identity;
    `.2.2` owns loaded/serde/generated/emitted/descriptor/trace convergence; `.2.3` owns topology and 65-case
    rollout admission.
  - [x] **NO BEHAVIOR CHANGE** — Keep this preflight read-only for Rust/parser/runtime/fixture behavior; run focused
    baselines plus governance, book, continuity, and canonical signoff proportionate to an inventory slice.
    No Rust source, test, fixture, capability, or runtime behavior changes in this leaf.
  - [x] **LOCKSTEP / COMMIT** — Write durable Knowledge Map evidence, update task/live/development/book status,
    clean artifacts, and commit `.2.0` before activating Rust implementation `.2.1`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.1`
  Status: `done`
  Goal: Implement Rust marker-optional validation, ordered selection, and immutable authored entry identity.
  Dependencies: `.9.1.1.2.2.0`
  Acceptance: Replace marker-required validation with one-or-more-rule validation; preserve definition order plus
    every authored marker; introduce one compiled-state resolver for explicit, first-marker, and first-rule
    precedence; route normal native default/explicit entry through it; reject zero rules before selection and
    unknown selectors before user code with exact portable diagnostics; preserve strict-unused semantics; and
    publish root contract identity without changing ordinary rule execution.
  Verification: **PASS 2026-07-18.** One compiled-state resolver
    consumes all eight neutral selection rows and three failure rows; the focused Rust consumer also locks all
    three strict rows, native legacy/value default+explicit behavior, markerless/zero-rule validation, portable
    diagnostics, descriptor identity, and immutable marker bits. Core 193+4+5+8, runtime 137, integration 197,
    diagnostics 5, loader 5, trace 10, and root 6 pass. The full Rust-local gate passes the 105-case Perl oracle,
    generated-source classifier, all adjacent contract suites, and primary 65/65 in both option environments.
    Strict Clippy passes for both changed packages after exempting only 28 pre-existing findings in untouched
    hunks exposed by Rust 1.95; no slice-owned warning remains. Root governance remains 2 complete / 5 pending.
    Knowledge Map is 600/4,301; mdBook, memory/task metadata, four doctrines, and whitespace pass. Canonical CI
    passes root core 7/routes 5, cursor admission 288, reference primary 65x2, and Phase 0 1,031/1,031 in 633s.
    Its first run caught and the rerun proves a generic public-checker wording collision without weakening either
    capability gate. Generated/emitted route convergence remains exclusively `.2.2`; no rollout row advances.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.1 - implement Rust root resolution`

  #### Acceptance checklist

  - [x] **VALIDATION / ORDER** — Accept one-or-more-rule markerless sources, preserve empty/comment-only parsing as
    an envelope for exact `no_rules_defined` / `validate_spec`, and keep non-rule garbage a parse error.
  - [x] **ONE RESOLVER** — Add `CompiledSpec::resolve_entry_rule` with explicit selector > first authored marker >
    first authored rule precedence, zero-rule-before-selector failure, and no mutation of definition order or
    `is_top`.
  - [x] **NATIVE EXECUTION** — Route legacy/default and value/explicit execution through the resolver and make
    entry-sensitive accumulator/return behavior follow the resolved effective rule rather than authored marker
    identity.
  - [x] **DIAGNOSTICS / STRICT** — Reject unknown explicit identity before user code with
    `entry_rule_not_found` / `select_entry_rule` and requested `entry_rule`; retain compatibility text and
    authored-edge-only strict-unused behavior.
  - [x] **DESCRIPTOR / CONTRACT** — Publish `entry_rule_contract = linkedspec-root-rule-selection-v1`, preserve
    definition order and per-rule boolean `is_top`, and update the partial Rust inventory without promoting
    generated routes or rollout.
  - [x] **FOCUSED / RUST LOCAL** — Pass formatting, neutral/root, core, runtime, integration, adjacent contracts,
    oracle, generated classifier, strict-new-code Clippy, and exact primary 65x2.
  - [x] **LOCKSTEP / CANONICAL / COMMIT** — Synchronize live/task/book/Knowledge Map state, pass canonical CI,
    clean generated artifacts, commit `.2.1`, clear the brief, and only then activate `.2.2`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.2`
  Status: `done`
  Goal: Align Rust loaded, serialized, reconstructed, generated/emitted, descriptor, trace, and diagnostic routes.
  Dependencies: `.9.1.1.2.2.1`
  Acceptance: Prove loaded and ordinary serialized/reconstructed state reuse the core resolver; add
    compatibility-preserving generated/emitted invocation selectors across direct, diagnostic, compatibility, and
    traced roles; keep configured selection separate from source identity; attribute trace and failures to the
    effective rule; retain descriptor order/per-rule `is_top`; and reject stale generated formats at their existing
    contract boundary.
  Verification: **PASS 2026-07-18.** Loaded/serde and all generated/emitted role families pass exact diagnostic,
    trace, descriptor, and stale-format boundaries. Routes 6, emitter 6 with a fresh standalone crate, focused
    adjacent suites, classifier 105, complete Rust-local proof, and primary 65x2 pass without rollout promotion.
    Canonical CI passes four doctrines, logical-helper 26 mutations, root consumers 7+5, cursor 288, primary 65x2,
    and Phase 0 1,031/1,031 in 627 seconds. The first canonical run exposed a latent checker-owned logical-helper
    marker stored in mutable frontier text; stable canonical storage plus a Knowledge Map card repairs that
    durability defect without logical behavior change. KM is 602/4,320. Cleanup removes 16,558 Cargo files,
    reducing `rust/target` from 2.9 GiB to 99 MiB, plus the generated 11 MiB book and Python cache.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.2 - converge Rust root routes`

  #### Acceptance checklist

  - [x] **RETRIEVAL / ROUTE MAP** — Re-read the Rust root-selection core/preflight facts and retrieve the exact
    loaded, serialized, reconstructed, generated/emitted, descriptor, trace, diagnostic, and stale-format owners
    before changing behavior.
  - [x] **LOADED / SERIALIZED** — Prove direct, loaded, serde round-trip, and reconstructed compiled state preserve
    authored order/`is_top` while reusing the single core resolver for default and explicit selection.
  - [x] **GENERATED / EMITTED API** — Add a compatibility-preserving per-invocation selector to every generated
    direct, diagnostic, compatibility, and traced role; default selection must use first marker then first rule,
    and explicit selection must win without mutating embedded authored identity.
  - [x] **DIAGNOSTIC / TRACE IDENTITY** — Return the portable zero/unknown codes and stages before user code,
    attribute runtime failures and trace entry to the effective selected rule, and keep configured selector state
    separate from descriptor/source `is_top` identity.
  - [x] **FORMAT / DESCRIPTOR** — Preserve the existing generated-format rejection boundary, deterministic source,
    definition order, per-rule `is_top`, and `entry_rule_contract` across direct, loaded, reconstructed, and
    generated descriptor projections.
  - [x] **FOCUSED / RUST LOCAL** — Pass neutral route consumers, generated-source execution/classifier/emitter,
    loader/serde/descriptor/diagnostic/trace suites, formatting, strict-new-code Clippy, full Rust-local proof, and
    exact primary 65x2 without advancing rollout admission.
  - [x] **CANONICAL DRIFT REPAIR** — Root-cause the latent logical-helper marker failure exposed by this slice's
    generated-source diff: the checker-owned completion marker had lived in a mutable current-frontier cell and
    was erased by later PNT updates. Move it to a stable canonical-marker section, card the rule, and re-pass the
    focused logical checker without changing logical-helper behavior or rollout.
  - [x] **LOCKSTEP / CANONICAL / COMMIT** — Synchronize task/live/book/Knowledge Map/capability state, pass root
    governance and canonical CI, clean safe artifacts, commit `.2.2`, clear the brief, and only then activate
    topology/admission leaf `.2.3`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.3`
  Status: `done`
  Goal: Admit composed Rust root selection against the 65-case shared primary reference.
  Dependencies: `.9.1.1.2.2.2`
  Acceptance: Add one topology-checked Rust admission consumer across all neutral routes/failures; pass exact
    shared marker/markerless/default/explicit/unknown/request-trace bytes with and without `POSIXLY_CORRECT`;
    advance only the Rust rollout row; synchronize public/book/capability/live docs; and close parent `.2` after
    complete focused, Rust-local, governance, and canonical signoff.
  Verification: **PASS 2026-07-18.** One contract-declared 15-role consumer
    executes every neutral/native/loaded/reconstructed/generated/emitted/descriptor/diagnostic/trace/primary role
    exactly once. Root governance is 3 complete / 4 pending with 29 mutations. Focused admission/core/routes/
    emitter pass 1+6+6+6; complete Rust-local passes core 193+4+5+8, runtime 137, oracle 105/215.90s, classifier
    105/249.47s, integration 197, admission 1/16.89s, emitter 6/49.64s, and primary 65x2. Canonical CI passes all
    four doctrines, root governance, Perl root consumers 7+5, cursor 288, reference primary 65x2, and Phase 0
    1,031/1,031 in 627 seconds. Public/book/capability/live records agree; Knowledge Map is 603/4,328. Cleanup
    removes 10,626 Cargo files, reducing `rust/target` from 2.4 GiB to 99 MiB, plus generated book/cache/logs.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.2.3 - admit Rust root selection`

  #### Acceptance checklist

  - [x] **RETRIEVE / BASELINE** — Read the composed Rust route fact, Perl admission precedent, neutral contract,
    checker topology, exact primary cases/runner, canonical registration, capability rollout, and public status
    owners before changing admission state.
  - [x] **ONE ADMISSION CONSUMER** — Add one omission-sensitive Rust consumer that composes every neutral
    selection, failure, strict, native, loaded/serde, generated/emitted, descriptor, trace, and diagnostic role
    exactly once without duplicating their semantic owners.
  - [x] **TOPOLOGY / MUTATION PROOF** — Extend the neutral inventory/checker with the exact Rust consumer path,
    role markers, canonical registration, shared primary case identities, and deterministic omission mutations.
  - [x] **PRIMARY REFERENCE** — Pass all 65 shared primary cases against `linkedspec-rust` with
    `POSIXLY_CORRECT` unset and set, including first-marker, markerless-first-rule, explicit override, unknown
    selector, and request-trace bytes.
  - [x] **ROLLOUT / PUBLIC LOCKSTEP** — Advance only `rust` to complete, close Rust parent `.2`, and align
    capability docs, mdBook, Knowledge Map, task/live/change/development/memory records without claiming later
    backend or final public admission.
  - [x] **FOCUSED / RUST LOCAL** — Pass the composed consumer, constituent root suites, generated governance,
    root mutation checker, complete Rust-local gate, formatting, and whitespace.
  - [x] **CANONICAL / COMMIT** — Pass canonical CI, safely clean generated artifacts, commit `.2.3`, clear the
    brief, prove the tree clean, and only then activate Dart root-selection leaf `.3` task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.3`
  Status: `done`
  Goal: Implement root-selection precedence on Dart.
  Dependencies: `.9.1.1.2.2`
  Children: `.9.1.1.2.3.0`, `.9.1.1.2.3.1`, `.9.1.1.2.3.2`, `.9.1.1.2.3.3`
  Acceptance: Remove the validator contradiction that makes the existing runtime/source first-rule fallback
    unreachable; align loaded/normalized/generated/descriptor/trace/strict/CLI routes and prove explicit
    `--top-rule` wins over an authored marker.
  Verification: **PASS 2026-07-18.** Leaves `.0-.3` map, implement, converge, and admit Dart. One exact ordered
    15-role consumer, 34-mutation governance, package 270, primary 65x2, corpus 105, 4/7 public/book/KM lockstep,
    and canonical Phase 0 1,031/1,031 in 656 seconds pass without generated/API behavior drift.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.3.3 - admit Dart root selection`

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.3.0`
  Status: `done`
  Goal: Map every Dart root-selection seam and freeze a dependency-safe implementation/admission plan.
  Dependencies: `.9.1.1.2.3`
  Acceptance: Use the Knowledge Map, neutral contract, LinkedSpec toolbox, exact source/test retrieval, and focused
    real commands to inventory parser/validation order and authored-marker retention; requested/default selection;
    native, loaded/normalized/reconstructed, generated/emitted, descriptor, trace, diagnostic, strict, primary,
    shared-reference, and recurring-gate boundaries. Record exact already-correct versus divergent mechanisms and
    split `.1-.3` without changing Dart behavior.
  Verification: **PASS 2026-07-18.** Exact primary is 64/65 twice, with markerless alone failing compile
    validation. Direct API probes isolate `_checkTopRuleExists`, loaded/emitted revalidation, old zero/unknown
    stages, and absent descriptor contract while proving existing native/normalized/generated fallback and
    explicit override. Focused owners pass 97; complete Dart passes format, analysis, package 260, and corpus 105.
    Root governance stays 3/4 with 29 mutations; mdBook and KM 604/4,336 pass. Canonical CI passes all four
    doctrines, Perl root consumers 7+5, cursor 288, reference primary 65x2, and Phase 0 1,031/1,031 in 655 seconds.
    Safe cleanup removes generated book/cache without changing Dart source/test/fixture/contract/capability state.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.3.0 - map Dart root selection`

  #### Acceptance checklist

  - [x] **RETRIEVE / PRECEDENT** — Read ADR `0046`, neutral/Perl/Rust admission facts, current Dart root facts,
    toolbox, exact Dart owners/tests, capability inventory, shared primary cases, and gate registration.
  - [x] **REPRODUCE / ISSUE** — Prove explicit ordinary, first marker, multiple marker, markerless, unknown, zero,
    strict, descriptor, loaded/normalized/generated/emitted, trace, and primary boundaries with the narrowest real
    commands; record exact values, diagnostics, stages, bytes, and default/POSIX shared-manifest count.
  - [x] **ROOT CAUSE / INVENTORY** — Trace every divergence to its validation/compiler/runtime/adapter owner and
    distinguish unreachable existing fallback from missing identity, selector, structured failure, or route logic.
  - [x] **SAFE SPLIT** — Confirm or refine `.1` core/descriptor, `.2` composed routes, and `.3` topology/reference
    admission so each implementation leaf is signoff-sized and leaves admitted Perl/Rust behavior unchanged.
  - [x] **NO BEHAVIOR CHANGE** — Keep `.0` read-only for Dart source/test/fixture/capability behavior; run focused
    baselines plus governance/book/continuity/canonical proof proportionate to an inventory slice.
  - [x] **LOCKSTEP / COMMIT** — Card durable findings, synchronize task/live/development/memory records, clean safe
    artifacts, commit `.0`, clear the brief, and only then activate Dart core `.1`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.3.1`
  Status: `done`
  Goal: Implement Dart marker-optional validation, ordered native selection, portable failures, and descriptor identity.
  Dependencies: `.9.1.1.2.3.0`
  Acceptance: Accept one-or-more-rule markerless sources; preserve ordered authored markers; centralize explicit >
    first marker > first rule selection for ordinary native/default execution; reject zero/unknown selection at the
    neutral stages; retain authored-edge-only strict behavior; and publish immutable descriptor identity.
  Verification: focused 107; package 266; analyzer/format; corpus 105; primary 65x2; root 29; mdBook; KM 605/4,348;
    canonical Perl root 7+5, cursor 288, reference primary 65x2, Phase 0 1,031/1,031; cleanup all pass
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.3.1 - implement Dart root resolution`

  #### Acceptance checklist

  - [x] **RETRIEVE / BASELINE** — Re-read the preflight fact, neutral selection/failure/strict rows, exact Dart
    validator/compiler/runtime/descriptor owners, and admitted Perl/Rust precedents before changing behavior.
  - [x] **VALIDATION / ORDER** — Accept one-or-more-rule markerless sources, reject zero rules with portable
    `no_rules_defined` / `validate_spec`, preserve duplicate/source failure precedence, definition order, and every
    authored `is_top` bit.
  - [x] **ONE RESOLVER / NATIVE** — Add one compiled-state resolver for explicit selector > first authored marker
    > first authored rule, route ordinary native default/explicit execution through it, and reject unknown exact
    selectors before user code with `entry_rule_not_found` / `select_entry_rule` / requested `entry_rule`.
  - [x] **STRICT / DESCRIPTOR** — Keep selected/marked rules outside the authored reference graph; pass all three
    neutral strict rows; publish `entry_rule_contract = linkedspec-root-rule-selection-v1`, ordered definitions,
    and immutable per-rule `is_top` without dynamic selected identity.
  - [x] **FOCUSED / DART LOCAL** — Pass one neutral-consuming Dart core test plus validator/runtime/compiled/
    descriptor/primary focused suites, complete package/corpus, format/analyze, and exact primary 65x2 without
    advancing Dart rollout or claiming generated/emitted route admission.
  - [x] **LOCKSTEP / CANONICAL / COMMIT** — Update partial capability/public/book/KM/task/live state, pass root
    governance and canonical CI, safely clean artifacts, commit `.1`, clear the brief, and only then activate `.2`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.3.2`
  Status: `done`
  Goal: Align Dart loaded, normalized/reconstructed, generated/emitted, trace, and diagnostic root-selection routes.
  Dependencies: `.9.1.1.2.3.1`
  Acceptance: Make every composed route reuse the ordered resolver with invocation-local explicit selection;
    preserve generated contract and descriptor identity; attribute trace/failures to the effective rule; and keep
    stale-format rejection at its existing contract boundary.
  Verification: focused route/owners 86+14; Dart format 59/0, analyzer, package 269, primary 65x2, corpus 105;
    root 29; KM 606/4,360; mdBook; all four doctrines; canonical Perl root 7+5, cursor 288, reference primary
    65x2, Phase 0 1,031/1,031 in 628 seconds; safe cleanup all pass
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.3.2 - converge Dart root routes`

  #### Acceptance checklist

  - [x] **RETRIEVE / ROUTE MAP** — Re-read Dart preflight/core facts, neutral projections, admitted Perl/Rust route
    precedent, and exact loader/normalized/generated/emitted/trace/diagnostic owners and tests before behavior edits.
  - [x] **LOADED / RECONSTRUCTED** — Prove file-loaded and normalized-JSON reconstructed state preserves ordered
    authored markers and reuses the compiled resolver for default marker, markerless fallback, and invocation-local
    explicit selection without descriptor mutation.
  - [x] **GENERATED / EMITTED** — Prove generated direct/traced and fresh emitted-source direct/traced execution
    applies the same precedence without changing generated-source v2/format 2 identity or its minimal family plan;
    preserve existing default API signatures and add only necessary option-bearing siblings.
  - [x] **TRACE / DIAGNOSTIC / ORDER** — Attribute runtime trace and execution failures to the effective selected
    rule/basis, retain requested selector identity where required, return portable zero/unknown fields, and keep
    generated contract/plan rejection ahead of entry selection.
  - [x] **FOCUSED / DART LOCAL** — Add one route-focused Dart consumer; pass loader/normalized/emitter/trace/
    diagnostic owners, generated governance, complete package/corpus, format/analyze, and primary 65x2 without
    advancing Dart rollout or adding topology admission.
  - [x] **LOCKSTEP / CANONICAL / COMMIT** — Card durable route facts, synchronize partial public/book/capability/
    task/live/memory state, pass root governance and canonical CI, safely clean artifacts, commit `.2`, clear the
    brief, prove clean, and only then activate Dart admission `.3`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.3.3`
  Status: `done`
  Goal: Admit composed Dart root selection against the shared primary reference.
  Dependencies: `.9.1.1.2.3.2`
  Acceptance: Add one omission-sensitive topology consumer across every neutral and real Dart projection; lock
    driver/case registration and mutations; pass exact shared marker/markerless/default/explicit/unknown/trace
    bytes in both option environments; advance only Dart; synchronize public/book/KM/live records; and close the
    Dart parent after complete focused, Dart-local, governance, and canonical signoff.
  Verification: **PASS 2026-07-18.** Focused admission/core/routes/emitter 1+14; Dart format 60/0, analyzer,
    package 270, primary 65x2, corpus 105; root governance 34; mdBook; KM 607/4,371; all four doctrines; canonical
    Perl root 7+5, cursor 288, reference primary 65x2, and Phase 0 1,031/1,031 in 656 seconds all pass.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.3.3 - admit Dart root selection`

  #### Acceptance checklist

  - [x] **RETRIEVE / ADMISSION MAP** — Re-read the neutral contract, Perl/Rust admission precedent, Dart
    preflight/core/routes facts, exact route consumer, shared primary case bytes, checker topology/mutations, and
    canonical/backend driver seams before editing the contract or tests.
  - [x] **ONE EXACT CONSUMER** — Add one Dart admission consumer whose contract-declared role map executes every
    neutral selection/failure/strict and real native/loaded/reconstructed/generated/emitted/descriptor/diagnostic/
    runtime-trace/primary/request-trace projection exactly once, rejecting missing, duplicate, or invented roles.
  - [x] **GOVERNED TOPOLOGY** — Declare the Dart consumer path, canonical/backend drivers, exact roles, and shared
    primary case ids in the neutral artifact; make root governance require their registration and reject omission,
    path, case, driver, and rollout mutations without weakening the existing 29.
  - [x] **REFERENCE / DART ADMISSION** — Pass focused admission/core/routes/emitter proof, complete Dart format/
    analyzer/package/corpus, and exact shared 65-case default/POSIX bytes; advance only the Dart rollout row from
    pending to complete after every required projection is executable and omission-sensitive.
  - [x] **PUBLIC / PARENT CLOSEOUT** — Synchronize capability/public/mdBook/KM/task/live/memory state at the honest
    4/7 boundary, close Dart parent `.9.1.1.2.3`, and leave Julia `.4`, Lua `.5`, and final no-drift `.6` pending.
  - [x] **CANONICAL / CLEAN / COMMIT** — Pass root governance and canonical CI, safely clean generated artifacts,
    commit `.3`, clear the brief, prove clean, and only then activate Julia root-selection `.4` task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.4`
  Status: `done`
  Goal: Implement root-selection precedence on Julia.
  Dependencies: `.9.1.1.2.3`
  Children: `.9.1.1.2.4.0`, `.9.1.1.2.4.1`, `.9.1.1.2.4.2`, `.9.1.1.2.4.3`
  Acceptance: Align parser/validation, runtime, reconstructed/generated routes, descriptors/traces, strict checks,
    and primary CLI with the unchanged neutral contract and reference bytes.
  Verification: `PASS 2026-07-18; preflight .0, core/descriptor .1, routes .2, cursor dependency .9.1.6, and exact admission .3 pass; Julia is admitted at root 5/7+39 with package 3,428, primary 65x2, corpus 105, and canonical Phase 0 1,031 in 616 seconds`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.4.3 - admit Julia root selection`

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.4.0`
  Status: `done`
  Goal: Map every Julia root-selection seam and freeze a dependency-safe implementation/admission plan.
  Dependencies: `.9.1.1.2.4`
  Acceptance: Retrieve the neutral/admitted precedents and Julia knowledge before source inspection; use exact
    parser/validator/runtime/descriptor/generated/emitted/trace/diagnostic/strict/primary/gate probes to classify
    marker, markerless, explicit, unknown, zero, reconstruction, and reference-byte behavior; split core, composed
    routes, and topology admission without changing Julia behavior or advancing rollout.
  Verification: **PASS 2026-07-18.** Exact Julia shared primary is 31/65 in both default and POSIX environments:
    one markerless root failure, 22 cursor-owned help/usage failures, and 11 cursor-owned request-trace failures.
    Direct API probes map native, loaded, normalized, generated, emitted, descriptor, diagnostic, trace, strict,
    zero, and unknown seams. `Pkg.test()` exposes the known cursor help mismatch at 56/57 in primary arguments;
    standalone corpus is 105/105. Root governance stays 4/7 with 34 mutations; KM is 609/4,390; mdBook, memory,
    task metadata, all four doctrines, cursor governance, and whitespace pass. Canonical CI passes Perl root 7+5,
    cursor admission 288, reference primary 65x2, and Phase 0 1,031/1,031 in 641 seconds. No Julia source, test,
    fixture, contract, capability, runtime, or rollout behavior changes. Both roadmaps are repaired from stale 1/7
    to 4/7, and final no-drift `.6` owns mechanical recurrence. Cleanup removes generated book/cache/temp-log
    artifacts while retaining immediate-next-task Julia compiled state and the clean Rust target baseline.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.4.0 - map Julia root selection`

  #### Acceptance checklist

  - [x] **RETRIEVE / PRECEDENT** — Read ADR `0046`, the neutral contract/checker, admitted Perl/Rust/Dart facts
    and consumers, Julia architecture/runtime/CLI facts, toolbox, backend gate, and shared primary owners before
    re-deriving behavior or inspecting implementation details.
  - [x] **REPRODUCE / ISSUE** — Run the narrowest exact real probes for explicit ordinary override, first/multiple
    markers, markerless fallback, zero/unknown failures, strict-unused, descriptor identity, loaded/normalized/
    generated/emitted, trace, and default/POSIX primary behavior; record exact values, fields, bytes, and counts.
  - [x] **ROOT CAUSE / INVENTORY** — Trace every divergent or already-correct projection to its parser, validator,
    compiler, runtime, adapter, source emitter, descriptor, trace, diagnostic, strict, and gate owner without
    guessing from `.spec` text.
  - [x] **SAFE SPLIT** — Confirm or refine `.1` core/descriptor, `.2` composed routes, and `.3` topology/reference
    admission so each later behavior slice has one semantic owner and no premature rollout claim.
  - [x] **NO BEHAVIOR CHANGE** — Keep `.0` read-only for Julia source/test/fixture/capability behavior and run
    focused plus complete Julia/reference/governance proof proportionate to the audit.
  - [x] **LOCKSTEP / COMMIT** — Card the durable seam map, synchronize task/live/development/memory/book status,
    clean safe artifacts, commit `.0`, clear the brief, and only then activate Julia core `.1` task-tree-first.

  Exact pre-implementation finding: normal Julia validation rejects markerless source through
  `_check_top_rule_exists`, but bypass-compiled native and generated-direct state already resolves explicit
  selector > first authored marker > first authored rule. Loaded, normalized, and emitted paths re-enter
  validation. Zero/unknown diagnostics use legacy `top_rule_selection`/`rule_lookup`; generated execution wraps
  unknown selection; descriptor metadata lacks `entry_rule_contract` and retains cursor `parse_mode`; high trace
  names the effective rule while low trace has no selection-basis event. Shared primary passes 31/65 in both
  environments: one markerless root failure, 22 cursor-owned help/usage failures, and 11 cursor-owned request-trace
  failures. Therefore `.4.3` depends on cursor `.9.1.6`, and `.9.1.6` depends on root routes `.4.2`.

  The audit also found `ROADMAP.md` and `ROADMAP_V2.md` frozen at the neutral 1/7 state because root governance
  does not require either projection. `.4.0` repairs current prose; final no-drift `.6` now owns mechanical
  inclusion in the recurring checker.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.4.1`
  Status: `done`
  Goal: Implement Julia marker-optional validation, ordered native selection, portable failures, and descriptor identity.
  Dependencies: `.9.1.1.2.4.0`
  Acceptance: Accept one-or-more-rule markerless sources; centralize explicit > first marker > first rule selection
    before user code; preserve authored markers and strict-reference semantics; publish the root contract and
    portable zero/unknown failures; pass native plus root-owned primary proof while preserving the exact
    cursor-owned baseline failure set; do not claim composed route or topology admission.
  Verification: **PASS 2026-07-18.** Neutral core 79/79, loader 82/82, root governance 4/7 plus 34 mutations,
    exact shared primary 32/65 in default and POSIX environments, package progression through the frozen
    cursor-owned 56/57 help boundary, and corpus 105/105 pass. KM is 611/4,408; memory/task/all four doctrines,
    mdBook, and whitespace pass. Canonical CI passes Perl root 7+5, cursor admission 288, reference primary 65x2,
    and Phase 0 1,031/1,031 in 619 seconds. Generated book/Python-cache cleanup passes; composed routes and rollout
    are unchanged.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.4.1 - implement Julia root resolution`

  #### Acceptance checklist

  - [x] **RETRIEVE / CORE OWNER** — Re-read the Julia preflight card, neutral selection/failure/strict rows,
    admitted Perl/Rust/Dart core precedents, current parser/validator/compiler/runtime/descriptor owners, and
    focused gate seams before editing behavior.
  - [x] **PARSER / ENVELOPE VALIDATION** — Preserve empty/comment-only source as a zero-rule envelope; reject
    malformed non-rule text in parsing; make validation require one-or-more rules rather than an authored marker.
  - [x] **ONE ORDERED RESOLVER** — Add one compiled-state resolver that checks zero structure first, then exact
    explicit selector, first authored marker, and first authored rule; route native default/explicit execution
    through it before runtime context or user code.
  - [x] **PORTABLE FAILURES** — Return exact `no_rules_defined` / `validate_spec` and `entry_rule_not_found` /
    `select_entry_rule` identities with requested selector attribution; preserve unrelated runtime diagnostics.
  - [x] **STRICT / DESCRIPTOR IDENTITY** — Keep strict-unused authored-edge-only; publish
    `entry_rule_contract=linkedspec-root-rule-selection-v1`; preserve definition order and immutable per-rule
    `is_top`; do not absorb cursor descriptor migration.
  - [x] **FOCUSED / CURRENT JULIA PROOF** — Add one neutral-consuming core suite; pass parser/validator/runtime/
    descriptor owners, marker/markerless/explicit/zero/unknown/strict cases, corpus 105, root governance, and exact
    shared primary 32/65 twice with only the frozen 33 cursor failures remaining.
  - [x] **LOCKSTEP / CANONICAL / COMMIT** — Synchronize capability/task/live/book/KM/current docs without route or
    rollout promotion; pass memory/task/doctrines/mdBook/whitespace and canonical CI; clean safe artifacts, commit
    `.1`, clear the brief, prove clean, and only then activate composed routes `.2` task-tree-first.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.4.2`
  Status: `done`
  Goal: Align Julia loaded, normalized/reconstructed, generated/emitted, trace, and diagnostic root-selection routes.
  Dependencies: `.9.1.1.2.4.1`
  Acceptance: Make every composed route reuse the ordered resolver with invocation-local selection; preserve
    generated/descriptor identity and validation order; attribute trace/failures to effective selection; pass
    focused and complete Julia library/corpus/root-case proof without advancing rollout or absorbing cursor work.
  Verification: **PASS 2026-07-18.** Focused routes 57/57, core 79/79, loader 82/82, emitter 59/59,
    package progression through the unchanged cursor-owned 56/57 help boundary, exact shared primary 32/65 in
    default and POSIX environments, corpus 105/105, and root governance 4/7 plus 34 mutations pass. KM is
    612/4,421; public/book/live synchronization, mdBook, memory/task/all four doctrines, Knowledge Map, and
    whitespace pass. Canonical CI reaches and passes every pre-Phase-0 stage; the retained exact Phase-0 rerun is
    1,031/1,031 in 611 seconds. Generated book/Python-cache cleanup passes while reusable backend build state and
    durable issue logs remain. Rollout is unchanged; the clean commit returns to Dart admission `.9.1.5.6`, whose
    parent closeout is the remaining dependency before cursor `.9.1.6`.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.4.2 - converge Julia root routes`

  #### Acceptance checklist

  - [x] **RETRIEVE / ROUTE OWNERS** — Re-read the Julia root preflight/core facts, neutral route expectations,
    admitted Perl/Rust/Dart route precedents, toolbox probes, loader/normalizer/emitter/generated/trace owners, and
    exact current failures before changing composed behavior.
  - [x] **ONE RESOLVER / INVOCATION LOCALITY** — Make loaded, normalized/reconstructed, generated-plan, and
    independently emitted/direct execution spend the compiled-state resolver without persisting an effective or
    explicit selector into authored state.
  - [x] **FAILURE / VALIDATION ORDER** — Preserve portable zero/unknown identities and requested-selector fields
    through loader/generated/emitted wrappers; reject stale contracts before execution and keep child lookup
    diagnostics separate.
  - [x] **TRACE / DIAGNOSTIC ATTRIBUTION** — Attribute runtime diagnostics and low trace to requested/effective
    entry selection and basis without changing unrelated trace events or absorbing cursor `parse_mode` removal.
  - [x] **IDENTITY / ROUTE PROOF** — Preserve descriptor definition order, authored `is_top`, generated identity,
    and source metadata across every route; add one focused route suite that proves real native/loaded/normalized/
    generated/emitted/trace/diagnostic projections.
  - [x] **COMPLETE JULIA BOUNDARY** — Pass focused routes plus complete Julia library/corpus/root-primary proof at
    the honest 32/65x2 cursor boundary; keep root governance at 4/7 and do not create the final admission consumer.
  - [x] **LOCKSTEP / CANONICAL / COMMIT** — Synchronize task/live/current docs, mdBook, and Knowledge Map; pass
    memory/task/doctrines/mdBook/whitespace and canonical CI; clean safe artifacts, commit `.2`, clear the brief,
    prove clean, and only then return to Dart admission `.9.1.5.6`; activate cursor `.9.1.6` only after Dart closes.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.4.3`
  Status: `done`
  Goal: Admit composed Julia root selection against the shared primary reference.
  Dependencies: `.9.1.1.2.4.2`, `.9.1.6`
  Acceptance: Add one exact omission-sensitive topology consumer over all neutral and real Julia projections; lock
    drivers, cases, and mutations; pass exact shared 65x2 bytes; advance only Julia; synchronize public/book/KM/
    live records; close parent `.4`; and leave Lua `.5` plus final no-drift `.6` pending.
  Verification: Activated task-tree-first on 2026-07-18 only after Julia cursor parent `.9.1.6` closed at clean
    commit `e6b71530`, `git_message_brief.txt` was zero bytes, generated book/cache artifacts were absent, and the
    tree was clean at ahead 229. Exact neutral, Rust/Dart admission, Julia root core/routes, current cursor
    admission, shared primary, checker/driver, rollout, inventory, mutation, and public-status retrieval must
    precede the one composed consumer and Julia-only promotion. Retrieval is complete. One exact consumer now
    passes 137 focused assertions; the registered Julia driver passes package 3,428, shared primary 65x2, and
    corpus 105; root governance passes at 5 complete / 2 pending with 39 mutations. Public/book/KM lockstep is
    synchronized at KM 622/4,524. Canonical CI passes all four doctrines, root 7+5, cursor 288, primary 65x2,
    and Phase 0 1,031/1,031 in 616 seconds. mdBook/JSON/whitespace pass; generated 11 MiB book and 28 KiB Python
    cache are removed. Parent `.4` is closed; the prepared clean commit is the only boundary before Lua `.5`.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.4.3 - admit Julia root selection`

  #### Acceptance Checklist

  - [x] **RETRIEVE / ADMISSION MAP** — Re-read ADR `0046`, the neutral root contract/checker, exact Rust/Dart
    admission precedents, Julia root core/routes and cursor-admission facts, shared primary case bytes, complete
    Julia/canonical drivers, rollout inventory, and mutation families before changing contract or tests.
  - [x] **ONE EXACT CONSUMER** — Add one omission-sensitive contract-declared Julia consumer whose exact roles run
    once in neutral order over selection/failure/strict plus native, loaded/normalized, generated/emitted,
    descriptor, diagnostic, trace, primary, and request-trace projections without duplicating semantic owners.
  - [x] **TOPOLOGY / JULIA-ONLY PROMOTION** — Lock the consumer path, role markers/order, complete package driver,
    canonical tracked input/optional registration, exact shared case ids, rollout row, inventory, and effective
    omission mutations; advance only Julia from pending to complete.
  - [x] **PROVE COMPOSITION / NO REGRESSION** — Pass focused admission and all constituent root suites, complete
    Julia package/process/65x2/corpus proof, root checker with every mutation rejected, adjacent cursor/generated/
    logical/capability governance, and canonical local CI without executable semantic or shared-fixture drift.
  - [x] **LOCKSTEP / CLOSEOUT** — Synchronize task/index/roadmaps/architecture/live/memory, capability/public and
    mdBook status, Knowledge Map, changes/notes, and cleanup; close parent `.4` and commit before activating Lua
    root-selection parent `.5`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.5`
  Status: `done`
  Goal: Implement root-selection precedence on Lua.
  Dependencies: `.9.1.1.2.4`
  Children: `.9.1.1.2.5.0`, `.9.1.1.2.5.1`, `.9.1.1.2.5.2`, `.9.1.1.2.5.3`
  Acceptance: Align parser/validation, PUC Lua/LuaJIT runtime and generated routes, descriptors/traces, strict
    checks, and primary CLI with the unchanged neutral contract and reference bytes.
  Verification: `PASS 2026-07-19. Behavior-free .5.0, core .5.1, routes .5.2, cursor dependency .9.1.7, and
    exact shared-source dual-ABI admission .5.3 are complete. Final admission is 139/139x2, package 177/177x2,
    primary 65/65x4, corpus 105/105x2, root governance 6/1/44, KM 633/4,653, and canonical Phase 0 1,031/1,031
    in 641 seconds. Parent .5 closes without a second resolver; only final public no-drift .6 remains.`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.5.3 - admit Lua root selection`

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.5.0`
  Status: `done`
  Goal: Map every PUC Lua/LuaJIT root-selection seam and freeze a dependency-safe implementation/admission plan.
  Dependencies: `.9.1.1.2.5`
  Acceptance: Retrieve the neutral/admitted precedents and Lua knowledge before source inspection; use exact
    toolbox and real dual-ABI probes to classify parser/validation, native, loaded/reconstructed, generated/
    emitted, descriptor, trace, diagnostic, strict, primary, driver, and governance seams; measure the unchanged
    shared manifest boundary in default/POSIX environments; split core, composed routes, cursor dependency, and
    topology admission without changing Lua behavior or advancing rollout.
  Verification: Activated task-tree-first on 2026-07-18 only after Julia root parent `.4` committed cleanly at
    `b7b55161`, `git_message_brief.txt` was zero bytes, generated book/Python-cache artifacts were absent, and the
    tree was clean at ahead 230. Full precedent/Lua/toolbox/driver/primary/governance retrieval and real disposable
    native-module probes establish identical PUC Lua/LuaJIT behavior: explicit ordinary and later-marker selectors
    win; default selects the first marker; bypassed markerless native/reconstructed/generated-direct/traced paths
    select the first rule; validation blocks markerless and zero-rule sources; loaded and emitted markerless paths
    re-enter that validator; unknown selection remains `rule_lookup`; zero-rule bypass remains legacy; descriptor
    metadata preserves ordered authored `is_top` but lacks the root contract; trace records only the effective
    `top_rule`; strict authored-edge results are otherwise exact. Empty/comment-only source currently fails in the
    parser while non-rule garbage correctly remains a parse failure. The complete shared process boundary is the
    same 31/65 in all four PUC/LuaJIT default/POSIX legs: one root-owned markerless failure, 22 cursor-owned help/
    usage failures, and 11 cursor-owned request-trace failures. Each ABI has 176 passing package groups plus the
    one expected cursor help failure and executes corpus 105/105. The safe order is `.5.1` core, `.5.2` routes,
    cursor `.9.1.7` depending on `.5.2`, then `.5.3` admission depending on both; authored selection fixtures use
    distinct entry-`I` returns, while fixed shared request-trace source bytes remain unchanged. No Lua source,
    test, fixture, neutral contract, capability row, or rollout status changes in `.5.0`. Root 5/7+39, cursor
    5+3/44, KM 623/4,533, mdBook, four doctrines, and canonical local CI pass; canonical closes with root 7+5,
    cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 609 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.5.0 - map Lua root selection`

  #### Acceptance Checklist

  - [x] **RETRIEVE / PRECEDENT** — Read ADR `0046`, the neutral contract/checker, admitted Perl/Rust/Dart/Julia
    facts and consumers, Lua architecture/runtime/CLI/generated facts, Toolbox, backend gate, and shared primary
    owners before re-deriving behavior or inspecting implementation details.
  - [x] **REPRODUCE / DUAL-ABI ISSUE** — Run the narrowest exact PUC Lua and LuaJIT probes for explicit ordinary
    override, first/multiple markers, markerless fallback, zero/unknown failures, strict-unused, descriptor,
    loaded/reconstructed/generated/emitted, trace, and default/POSIX primary behavior; record exact values and bytes.
  - [x] **ROOT CAUSE / INVENTORY** — Trace every divergent or already-correct projection to its parser, validator,
    compiler, runtime, adapter, source emitter, descriptor, trace, diagnostic, strict, and gate owner without
    guessing from `.spec` text.
  - [x] **SAFE SPLIT / CURSOR ORDER** — Confirm or refine `.1` core/descriptor, `.2` composed routes, `.3` topology
    admission, and the exact dependency direction with Lua cursor `.9.1.7` so neither shared-primary migration is
    absorbed or run out of order.
  - [x] **NO BEHAVIOR CHANGE** — Keep `.0` read-only for Lua source/test/fixture/capability behavior and run focused
    plus complete dual-ABI/reference/governance proof proportionate to the audit.
  - [x] **LOCKSTEP / COMMIT** — Card the durable seam map, synchronize task/live/development/memory/book status,
    clean safe artifacts, commit `.0`, clear the brief, and only then activate the first implementation leaf.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.5.1`
  Status: `done`
  Goal: Implement Lua marker-optional validation, ordered native selection, portable failures, and descriptor identity.
  Dependencies: `.9.1.1.2.5.0`
  Acceptance: Preserve empty/comment-only source as an empty `SpecFile` while retaining non-rule preamble errors;
    replace marker-required validation with typed one-or-more-rule `no_rules_defined` / `validate_spec`; add one
    compiled-state resolver and public basis/error projection; select explicit > first marker > first rule before
    runtime context or user code; return typed `entry_rule_not_found` / `select_entry_rule`; publish immutable
    descriptor `entry_rule_contract`; retain authored order/`is_top` and strict authored-edge-only behavior; prove
    both ABIs and improve only the root-owned shared-primary markerless case from 31/65 to 32/65.
  Verification: Activated task-tree-first on 2026-07-18 only after preflight `.5.0` committed cleanly at
    `c8324dce`, `git_message_brief.txt` was zero bytes, generated book/Python-cache artifacts were absent, and the
    branch was clean at ahead 231. A RED focused consumer first proved `resolve_entry_rule` was absent. Lua now
    preserves empty/comment-only parser envelopes, validates one-or-more-rule source, and uses one compiled-state
    resolver for explicit > first marker > first rule before runtime context/user code. Typed zero/unknown
    failures, immutable descriptor root identity, and authored-edge-only strict semantics pass on PUC Lua and
    LuaJIT. Hand-authored result fixtures use entry lifecycle `I`; fixed request-trace bytes retain `E`. Focused
    root 99, diagnostic 119, logical 359, package 176/177 with only the cursor-help mismatch, corpus 105/105, and
    all four default/POSIX primary legs at exactly 32/65 pass per ABI. Root governance stays 5/7+39; KM is
    624/4,546; mdBook, JSON, shell, whitespace, and all four doctrines pass. Canonical local CI exits 0 after root
    consumers 7+5, cursor admission 288, reference primary 65x2, and Phase 0 1,031/1,031 in 613 seconds. Generated
    book, 28 KiB-class Python cache, and two 104 KiB disposable native trees are removed. Routes/admission do not
    advance; `.5.2` follows only after the clean `.5.1` commit.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.5.1 - implement Lua root selection core`

  #### Acceptance Checklist

  - [x] **PARSER / VALIDATION OWNERSHIP** — Preserve empty/comment-only source as an empty `SpecFile`, keep
    malformed non-rule input at the parser boundary, and replace marker-required validation with typed
    one-or-more-rule `no_rules_defined` / `validate_spec` behavior on both ABIs.
  - [x] **ONE ORDERED RESOLVER** — Add one compiled-state selection owner with explicit `--top-rule` > first
    authored `Rule::` > first authored ordinary `Rule:` precedence and public requested/effective/basis identity.
  - [x] **PRE-EFFECT PORTABLE FAILURES** — Select before runtime context or user code; make unknown explicit roots
    fail as typed `entry_rule_not_found` / `select_entry_rule`; prove zero/unknown failure identity and no effects.
  - [x] **DESCRIPTOR / STRICT NO-DRIFT** — Publish immutable `entry_rule_contract`, preserve authored order and
    `is_top`, and prove strict-unused reachability still counts only authored call edges rather than entry choice.
  - [x] **DUAL-ABI / PRIMARY BOUNDARY** — Prove focused PUC Lua and LuaJIT behavior and improve only
    `success_markerless_first_authored_rule`, moving every default/POSIX leg from 31/65 to exactly 32/65 while the
    33 cursor-owned mismatches remain exact.
  - [x] **LOCKSTEP / COMMIT** — Synchronize tests, neutral-facing projections where owned, live docs, roadmap,
    Knowledge Map, and mdBook; pass focused plus canonical gates; clean safe artifacts; commit `.5.1`; clear the
    brief; and only then activate composed routes `.5.2`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.5.2`
  Status: `done`
  Goal: Align Lua loaded, reconstructed, generated/emitted, trace, and diagnostic root-selection routes.
  Dependencies: `.9.1.1.2.5.1`
  Acceptance: Prove loaded source and normalized AST reconstruction preserve order/markers and reuse the resolver;
    preserve typed loader zero-rule identity; make generated-v1 direct/traced and emitted direct/traced reuse the
    same invocation-local selector without changing the minimal plan or v1/format-1 identity; specialize only zero/
    unknown generated failures; keep plan validation before selection; add low requested/effective/basis success and
    requested/none/stage/code failure trace; prove both ABIs and leave the 33 cursor-owned primary mismatches exact.
  Verification: Activated task-tree-first on 2026-07-18 only after core `.5.1` committed cleanly at `5a8d3fcf`,
    `git_message_brief.txt` was zero bytes, generated book/Python-cache/disposable native artifacts were absent,
    and the branch was clean at ahead 232. Route ownership was retrieved before behavior edits. A RED focused
    consumer exposed 27 planned failures: loader zero-rule code/detail, absent success/failure selection trace, and
    generic generated zero/unknown wrappers; loaded/reconstructed execution, artifact identity, and plan-first
    ordering were already green. The implementation now makes all loaded/normalized/generated-v1/emitted direct/
    traced routes reuse the core resolver, specializes only portable zero/unknown adapter failures, and emits the
    low selection decision before context/parse scope. Focused route proof is 101/101 on PUC Lua and LuaJIT;
    diagnostic is 119/119, package remains 176/177 with only the cursor-help mismatch, all four primary legs remain
    exactly 32/65 with the same 33 cursor-owned residuals, and corpus is 105/105 per ABI. Root governance remains
    5/7+39; KM is 625/4,561; mdBook, syntax, shell, whitespace, memory, Knowledge Map, task metadata, and all four
    doctrines pass. Canonical local CI exits 0 after root consumers 7+5, cursor admission 288, reference primary
    65x2, and Phase 0 1,031/1,031 in 643 seconds. Generated book, Python cache, and both disposable native trees
    are removed. Rollout remains 5/7; cursor `.9.1.7` follows only after the clean `.5.2` commit.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.5.2 - align Lua root selection routes`

  #### Acceptance Checklist

  - [x] **RETRIEVE / ROUTE OWNERS** — Re-read the Lua preflight/core cards, admitted Julia/Dart route precedents,
    generated-v1 and loader/runtime/trace owners, Toolbox, exact neutral contract, and current tests before edits.
  - [x] **LOADED / RECONSTRUCTED REUSE** — Prove source loading and normalized AST reconstruction preserve authored
    order/markers and reach the core resolver without a second selection algorithm or descriptor mutation.
  - [x] **GENERATED / EMITTED REUSE** — Make generated-v1 direct/traced and freshly emitted direct/traced calls use
    one invocation-local selector while retaining contract v1, format 1, and the minimal label/family plan.
  - [x] **FAILURE ORDER / PROJECTION** — Preserve loader zero-rule identity, specialize only zero/unknown generated
    selection failures, and keep generated contract/plan validation before selection.
  - [x] **TRACE IDENTITY** — Add low requested/effective/basis success decisions and requested/none/stage/code
    failure decisions with direct/traced identity and no caller-owned emitter leakage.
  - [x] **DUAL-ABI / LOCKSTEP / COMMIT** — Prove focused and complete PUC Lua/LuaJIT route behavior, retain exact
    32/65x4 primary and 33 cursor-owned residuals, synchronize live/public/book/KM records, pass canonical gates,
    clean safe artifacts, commit `.5.2`, and clear the brief before cursor `.9.1.7` activation.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.5.3`
  Status: `done`
  Goal: Admit composed dual-ABI Lua root selection against the shared primary reference.
  Dependencies: `.9.1.1.2.5.2`, `.9.1.7`
  Acceptance: Add one exact omission-sensitive topology consumer over all neutral and real Lua projections; lock
    the same ordered 15 roles as admitted peers, use distinct entry-`I` returns for authored selection evidence,
    retain fixed shared request-trace source bytes, run the consumer on PUC Lua and LuaJIT, lock both-ABI driver
    reachability, six cases, canonical registration, and omission mutations; pass exact PUC shared 65x2 bytes plus
    dual-ABI focused primary roles; advance only Lua; synchronize public/book/KM/live records; close parent `.5`;
    and leave final no-drift `.6` pending.
  Verification: `PASS 2026-07-19. Activated task-tree-first only after Lua cursor admission `.9.1.7.6`
    landed at clean commit `7dd70a2d` with an empty brief and no generated book/cache/native build artifacts.
    Knowledge Map retrieval covered ADR `0046`, all admitted 15-role precedents, Lua core/routes/cursor consumers,
    the six exact primary cases, PUC/LuaJIT and canonical drivers, rollout, inventory, and mutation ownership.
    Before the Lua admission object existed, the new consumer failed exactly 3/3 topology assertions on each ABI.
    One shared-source exact 15-role consumer now passes 139/139 on each ABI; complete PUC Lua and LuaJIT package
    execution passes 177/177 each; primary passes 65/65 in all four ABI/default-POSIX legs; corpus passes 105/105
    per ABI; and root governance advances only Lua to 6 complete / 1 pending with 44 rejected mutations. Generated,
    logical, capability, cursor, JSON, syntax, shell, whitespace, memory, Knowledge Map, task metadata, and all four
    doctrine gates pass. KM is 633/4,653 and mdBook builds. Canonical local CI passes root 7+5, cursor 288,
    primary 65/65x2, and Phase 0 1,031/1,031 in 641 seconds. Cleanup removes the 11 MiB book, Python cache,
    147 MiB Julia compiled cache, and four closed LinkedSpec logs while preserving depot content, tracked `rgx`
    evidence, and unrelated temp files.`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.5.3 - admit Lua root selection`

  #### Acceptance Checklist

  - [x] **RETRIEVE / REPRODUCE** — Follow the Knowledge Map to ADR `0046`, the neutral checker, all admitted
    15-role consumers, Lua core/routes/cursor facts and focused consumers, exact six primary cases, both ABI
    drivers, canonical registration, rollout, inventory, and mutations before implementation or governance edits.
  - [x] **ADD ONE DUAL-ABI CONSUMER** — Add one omission-sensitive Lua consumer whose exact 15 declared roles run
    once in neutral order on PUC Lua and LuaJIT, using entry-`I` authored-selection evidence while retaining fixed
    shared request-trace bytes.
  - [x] **REGISTER / ADVANCE LUA ONLY** — Lock consumer path, role order/markers, complete dual-ABI driver,
    canonical optional registration, exact six primary case ids, inventory, rollout row, and effective mutations;
    promote only Lua from pending to complete.
  - [x] **PROVE COMPOSITION / NO REGRESSION** — Pass focused admission and all constituent root/cursor suites,
    complete dual-ABI package/process/65x4/corpus proof, root checker with every mutation rejected, adjacent
    cursor/generated/logical/capability governance, and canonical local CI without shared-fixture byte drift.
  - [x] **LOCKSTEP / CLOSEOUT** — Synchronize task/index/roadmaps/architecture/live/memory, capability/public and
    mdBook status, Knowledge Map, changes/notes, and cleanup; close parent `.5`, commit `.5.3`, clear the brief,
    and only then activate final root no-drift `.9.1.1.2.6`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.1.2.6`
  Status: `done`
  Goal: Admit and close root-selection parity with public no-drift.
  Dependencies: `.9.1.1.2.5`
  Acceptance: Require all five backend consumers and canonical registration; update the normative mdBook, public
    guides/examples/help, both roadmap projections, status/capability/Knowledge Map records, and recurring
    scanners; make both roadmaps required current-state checker inputs; pass exact focused, primary, corpus,
    governance, book, and canonical gates before closing `.9.1.1.2`.
  Verification: **PASS 2026-07-19.** Activated task-tree-first only after clean Lua admission `c8583edf`.
    The independent root checker progressed through exact missing-schema, missing-registration, and missing-public-
    marker failures to 8 selection / 3 failure / 3 strict cases, five backends, 7+0 rollout, 25 required documents,
    19 stale-claim guards, and 54 rejected mutations. The recurring driver passes Perl 7+5, exact Rust/Dart/Julia
    admissions, Lua 139/139 on PUC Lua and LuaJIT, the selected five-command/default-POSIX 5x2x6 matrix, and all
    generated/capability/language-coverage ledgers. Canonical no-drift exposed and repaired the shared current
    primary label from 63 to 65 in logical/diagnostic governance and added the two root scanner paths to the cursor
    inventory at 71 files without changing cursor rollout or mutations. Knowledge Map 634/4,662, mdBook, memory,
    whitespace, JSON/shell, and all four doctrines pass. Canonical CI passes primary 65/65x2 and Phase 0
    1,031/1,031 in 642 seconds. Safe cleanup removes only reproducible generated outputs and retains tracked issue
    evidence.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.1.2.6 - close root selection parity`

  #### Acceptance Checklist

  - [x] **RETRIEVE / FREEZE FINAL SURFACE** — Follow the Knowledge Map to ADR `0046`, the rollout-roadmap gap,
    all five admitted backend consumers, existing recurring/public contract precedents, canonical optional-gate
    registration, primary-case projection, mdBook/public surfaces, and the exact stale current claims before edits.
  - [x] **ADD ONE RECURRING FIVE-BACKEND GATE** — Declare and implement one composed driver over Perl, Rust,
    Dart, Julia, PUC Lua, and LuaJIT admission consumers, the exact six shared primary cases in both option
    environments, and the generated/capability/coverage support ledgers without adding a semantic execution path.
  - [x] **MAKE PUBLIC STATE EXECUTABLE** — Add an omission-sensitive public contract with required markers and
    forbidden stale current claims; require both roadmap projections, the mdBook, public/API/backend guides,
    status/capability/task records, and Knowledge Map facts from the root checker.
  - [x] **REGISTER / CLOSE ROLLOUT** — Register the all-toolchain driver behind one canonical local-CI switch,
    require every tracked input on ordinary CI, advance only final recurring/public admission to 7 complete / 0
    pending, and reject representative recurring, public, roadmap, registration, and rollout mutations.
  - [x] **PROVE / LOCKSTEP / CLOSEOUT** — Pass focused root governance, all six runtime legs, the 5x2 selected
    primary projection, corpus and support ledgers, mdBook/doctrines, canonical local CI, and safe artifact cleanup;
    synchronize task/index/roadmaps/architecture/live/memory/changes/notes/book/KM, close parent `.9.1.1.2`, commit
    `.6`, clear the brief, and verify a clean handoff before selecting another task-tree.

- ID: `FUTURE-PARITY-BACKLOG.9.1.2`
  Status: `done`
  Goal: Make ADR `0044` an executable backend-neutral cursor/edge/migration contract before behavior rollout.
  Dependencies: `.9.1.1.1`
  Acceptance: Add one versioned neutral schema, deterministic positive/negative fixtures, independent checker, and
    representative mutations for every family spelling; bare/explicit/block/fluent/index/group resolution;
    parent/child composition; public-option and CLI retirement; descriptor facts; generated-v2 family derivation;
    portable diagnostics; and both structural replacements for the retired cross-combinations. Inventory and
    dependency-order every tracked `parse_mode` caller without changing backend behavior or claiming admission.
  Checklist:
  - [x] **RETRIEVE / PRECEDENT** — Read ADR `0044`, the three cursor/edge Knowledge Map facts, existing neutral
    contract/checker conventions, generated-source v1 authority, and capability/CLI registration seams before
    deriving schema or migration facts.
  - [x] **EXACT MIGRATION INVENTORY** — Enumerate every tracked public API, engine/compiler/runtime, descriptor,
    generated/emitted/reconstructed, primary/corpus adapter, fixture, test, and documentation `parse_mode` caller;
    classify removal owner and dependency order without changing backend behavior.
  - [x] **EXECUTABLE NEUTRAL CONTRACT** — Add one versioned strict schema and deterministic fixtures covering all
    family spellings, bare/explicit/block/fluent/index/group resolution, mixed ownership, reserved/undefined names,
    parent/child call composition, two structural cross-combination recipes, option/CLI retirement, descriptors,
    generated-v2 family derivation/version rejection, and portable diagnostics.
  - [x] **INDEPENDENT CHECKER / MUTATIONS** — Derive expected fixture observations independently of backend code;
    reject representative semantic, topology, inventory, diagnostic, descriptor, generated, and rollout mutations;
    register the checker as a tracked canonical-CI input without claiming any backend admission.
  - [x] **NO BEHAVIOR REGRESSION** — Prove contract/checker syntax and deterministic mutation rejection plus
    capability/generated/coverage no-drift, governance, Knowledge Map, mdBook, whitespace, and canonical local CI
    proportionate to a contract-only slice. Do not change parser/compiler/runtime/CLI behavior or run mutations.
  - [x] **LOCKSTEP / COMMIT** — Align task/index, roadmaps/status, contract/capability docs, mdBook, Knowledge Map,
    changes/notes/live, and bounded memory; activate Perl `.9.1.3` only after `.9.1.2` verifies and commits cleanly.
  Verification: **PASS 2026-07-17.** The independent checker passes 36 exact family spellings, 18 edge cases,
    six post-normalization ownership sets, eight parent/child mechanisms, two structural replacements, exact
    API/CLI retirement, descriptor/generated-v2 rules, eight diagnostics, and a 91-file dependency-ordered
    migration inventory at 1 complete / 7 pending while rejecting 27 mutations. Capability and current
    generated-source v1 remain 80/0/0; exhaustive language coverage remains 246/105+1/122. Python/shell/JSON,
    Knowledge Map, memory architecture, task metadata, doctrines, mdBook, and whitespace pass. Canonical local
    CI passes reference CLI 63x2 and Phase 0 `1..1031` in 634 seconds. No backend behavior or implementation
    mutation campaign changed.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.2 - adopt rule-local cursor contract`

- ID: `FUTURE-PARITY-BACKLOG.9.1.3`
  Status: `done`
  Goal: Make the Perl reference consume the neutral rule-local cursor and bare-edge contract.
  Children: `.9.1.3.0`, `.9.1.3.1`, `.9.1.3.2`, `.9.1.3.3`, `.9.1.3.4`, `.9.1.3.5`, `.9.1.3.6`
  Dependencies: `.9.1.2`
  Acceptance: Normalize bare edges before RuleIR validation; derive handler cursor policy from authored family;
    remove public/global override paths; project the v1 cursor descriptor; emit/validate generated-source v2;
    migrate reference specs/tests; preserve low-level matcher primitives; and prove live, descriptor, emitted,
    generated, loaded-spec, trace, diagnostic, and primary-command roles without mixed-ownership ambiguity.
  Verification: **PASS 2026-07-17.** Children `.0-.6` normalize all bare/explicit edges, derive and spend
    intrinsic rule policy through live/loaded/descriptor/emitted/generated/trace paths, remove global API/CLI
    ownership, preserve 63x2 reference bytes, and compose 14 required roles plus all eight portable diagnostics.
    The exact inventory is 72, checker rollout is 2/6 with 29 rejected mutations, capability/current generated
    truth stays 80/0/0, focused composition passes 410 assertions, standalone Phase 0 passes 1,031/1,031 in 641
    seconds, and canonical CI passes the 288-test admission consumer, CLI 63x2, and Phase 0 1,031/1,031 in 642
    seconds. Rust remains unchanged and dependency-gated until this closeout commits cleanly.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.3.6 - admit Perl cursor projection`

- ID: `FUTURE-PARITY-BACKLOG.9.1.3.0`
  Status: `done`
  Goal: Audit the exact Perl mechanism and make the breaking CLI/API rollout order gate-safe before behavior code.
  Dependencies: `.9.1.2`
  Acceptance: Use the Knowledge Map and LinkedSpec toolbox first; map all 14 contract-owned Perl files to exact
    parser/compiler/runtime/descriptor/emitter/CLI/test roles; measure every canonical CLI case affected by
    reference option/help/trace removal; resolve the apparent `.9.1.3` versus `.9.1.8` shared-fixture ownership
    conflict without a hidden compatibility path or knowingly red main gate; and refine later child acceptance,
    dependencies, contract inventory, and durable causal knowledge before implementation.
  Checklist:
  - [x] **KNOWLEDGE MAP / TOOLBOX FIRST** — Read the four cursor/edge authority cards and ADR `0044`; use
    `run_bootstrap_parse`, `return_descriptor`, generated-source inspection, and canonical-CI registration before
    reading the owning source seams.
  - [x] **EXACT PERL MAP** — Map all 14 originally assigned token files: `bin/linkedspec` owns primary option/help/
    trace; Compiler/CompilerState/SpecEntry/HandlerVariantEmitter own option preparation, descriptor, global
    propagation, HandlerIR, and LinkedRE emission; the nine tests own diagnostic, generated, logical, Phase 0,
    scalar, trace, and Unicode live/emitted roles.
  - [x] **NON-TOKEN BEHAVIOR OWNERS** — Record BootstrapSpec/Core + `specs/spec.spec` + Validation as syntax owners,
    RuleIR as normalization/validation owner, and Compiler + GeneratedSource + public facade as generated-v2
    owners; do not mistake the token inventory for a complete code-change inventory.
  - [x] **BARE-EDGE ROOT CAUSE** — Prove bare `Child` is currently dropped and bare fluent/block forms become
    arbitrary `ChildCODE`; require typed complete-line candidates plus declared-rule resolution before RuleIR
    validation, with reserved forms preserved.
  - [x] **CLI GATE ROOT CAUSE** — Enumerate exactly 35 affected mandatory cases (2 help / 20 usage / 2 success /
    11 trace) and prove canonical CI runs all 63 twice.
  - [x] **GATE-SAFE OWNERSHIP** — Move the ten shared manifest/help/usage/trace token files to `.9.1.3.5`; retain
    `cli_conformance/README.md` and final symmetric admission under `.9.1.8`; keep 91 paths owned exactly once.
  - [x] **VERIFY / LOCKSTEP / COMMIT** — Checker/JSON, reference CLI 63x2, KM/governance, mdBook, whitespace, task/
    roadmap/book/live/memory/fact-card lockstep; commit before activating `.9.1.3.1`.
  Verification: **PASS 2026-07-17.** Knowledge Map and Toolbox-first probes map the exact 14 original Perl token
    files plus non-token syntax/RuleIR/generated owners; bootstrap output proves bare `Child` is absent and bare
    fluent/block forms are `ChildCODE`. Static manifest/fixture traversal partitions exactly 35 mandatory cases as
    2 help / 20 usage / 2 success / 11 trace, while canonical CI registration proves all 63 run twice. Ten shared
    files move to `.9.1.3.5`; `.9.1.8` retains shared docs/final symmetry; the contract checker remains 36 family /
    18 edge / 8 parent-child / 91 files / 1 complete and 7 pending / 27 mutations. JSON, Knowledge Map 580/4075,
    memory architecture, task metadata, doctrines, mdBook, whitespace, and reference CLI 63/63 default plus 63/63
    POSIX pass. No parser/compiler/runtime/descriptor/generated/CLI/fixture behavior changed.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.3.0 - audit Perl cursor rollout boundaries`

- ID: `FUTURE-PARITY-BACKLOG.9.1.3.1`
  Status: `done`
  Goal: Normalize Perl authored families and bare rule edges into one validated rule-local semantic form.
  Dependencies: `.9.1.3.0`
  Acceptance: Derive cursor policy from every authored family spelling; normalize bare identifiers at the
    line-level boundary; preserve explicit/indexed/grouped/fluent/block/reserved forms; and emit the exact portable
    normalization/ownership diagnostics before handler emission, with focused positive/negative source proof.
  Checklist:
  - [x] **BOOTSTRAP TYPES** — Retain complete-line bare plain/index/group/block/fluent candidates while keeping
    `I`/`LS`/`LE`/`LX`/`E`/`EX`/`IT` lifecycle syntax ahead of bare-rule resolution.
  - [x] **DECLARATION NORMALIZATION** — Supply the complete declaration set to every SpecEntry compile, resolve
    forward references before planning, and lower bare edges to family-derived action/blind ownership.
  - [x] **FAMILY POLICY** — Project `seek` for default/OR/repetition spellings and `consume` for every AND spelling
    into normalized rule metadata without spending that policy in live matcher execution yet.
  - [x] **PORTABLE DIAGNOSTICS** — Preserve exact code/stage/field payloads for undefined/indexed/grouped bare
    edges, explicit blind indexing, missing grouped action blocks, and mixed post-normalization ownership.
  - [x] **SOURCE / SELF-HOSTED PARITY** — Keep validation and `specs/spec.spec` aligned with the hardcoded bootstrap
    surface, including reserved lifecycle precedence and typed bare-edge examples.
  - [x] **FOCUSED PROOF** — Exercise all 36 family spellings, 18 edge cases, and six ownership sets through source
    parsing/compilation with exact normalized metadata or structured failure assertions.
  - [x] **VERIFY / LOCKSTEP / COMMIT** — Run focused and regression gates, synchronize Knowledge Map/live docs/book,
    clean generated artifacts, and commit before activating `.9.1.3.2`.
  Verification: **PASS 2026-07-17.** The 272-assertion source contract covers all 36 authored family spellings,
    18 edge-resolution cases, six ownership sets, reserved and explicit precedence, multiline/line-boundary
    behavior, exact portable code/stage/fields, and the deliberate unchanged live global-seek boundary. RuleIR
    trace 5/5 and validation fuzz 5/5 pass. The neutral checker remains 36/18/8/91 at 1 complete / 7 pending and
    rejects 27 mutations. Six Perl modules compile; Knowledge Map is 580 facts / 4077 question keys; memory/task/
    doctrine governance, mdBook, and whitespace pass. Canonical local CI passes capability 80/0/0, generated v1,
    logical 8/0, diagnostic 8/0, coverage 246/105+1/122, reference CLI 63/63 default plus 63/63 POSIX, and Phase 0
    `1..1031` in 641 seconds. The canonical preflight also found and repaired the pre-existing root task-index
    logical-parent marker mismatch. No HandlerIR/LinkedRE, public option, generated-source, CLI, or fixture cursor
    behavior changed; `.9.1.3.2` remains the clean-boundary next leaf.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.3.1 - normalize Perl rule edges`

- ID: `FUTURE-PARITY-BACKLOG.9.1.3.2`
  Status: `done`
  Goal: Make Perl live execution spend per-rule cursor policy across every parent/child entry mechanism.
  Dependencies: `.9.1.3.1`
  Acceptance: Derive handler seek/consume behavior from the normalized rule family, never caller or parent state;
    remove public/global override ownership at the gate-safe boundary fixed by `.0`; preserve low-level seek and
    consume matcher primitives; and prove top-level, blind/action/explicit-call/recursion, loaded-spec, trace, and
    structural replacement behavior without cross-rule propagation.
  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE** — The 37-assertion initial focused contract failed exactly 17 live assertions when
    parent/child family policy contradicted the legacy caller option; the first full Phase 0 run then isolated two
    authored AND fixtures at subtests 477 and 949 that depended on seek skipping unowned regex slots.
  - [x] **ROOT CAUSE (WHY + WHERE)** — `return_descriptor`, emitted-source inspection, and routed debug trace prove
    `Compiler::build_dependency_regex_map` contains only edge-owned regex indices, while `LinkedRE::or` now spends
    the rule's `cursor_policy`. The marker fixture additionally proved identical dependency alternatives select
    the first Perl alternation index; that separate latent risk is durably owned by `.9.1.8.1`.
  - [x] **FIX** — Normal live Compiler→SpecEntry→HandlerIR construction uses normalized per-rule `cursor_policy`;
    generated-source/descriptor v1 builds a separate legacy artifact handler until `.3-.4`; trace entry records
    policy. The two Phase 0 fixtures now explicitly own every consumed slot, and the marker fixture uses distinct
    delimiter-sensitive word anchors so dependency indices remain unambiguous.
  - [x] **ADDRESSED (verified)** — Focused live proof moves 17 failures to zero and passes 38 assertions across all
    eight neutral parent/child rows, both structural replacements, top/loaded/trace roles, and the preserved v1
    boundary; normalization remains 272/272. The exact Phase 0 failure set `{477,949}` becomes empty. The exact
    91-file migration inventory swaps the now-token-free emitter for the new token-bearing live contract without
    changing ownership order or the 1/7 rollout ledger.
  - [x] **NO REGRESSION** — Three touched Perl modules compile; focused rule-local 310/310 and adjacent logical,
    diagnostic, generated-source, scalar, Unicode, and trace suites pass. Full `PERL5LIB=` Phase 0 reaches its true
    `1..1031` stop with 1,031/1,031 PASS in 638 seconds.
  - [x] **LOCKSTEP** — Task/roadmap/architecture/live/change/development/memory, mdBook, Knowledge Map facts, and the
    `.9.1.8.1` latent-risk owner are synchronized; canonical CI, doctrine, memory, task, book, and cleanup proof are
    recorded before commit, and `.9.1.3.3` remains unactivated until the repository is clean.
  Verification: **PASS 2026-07-17.** Perl live and loaded parsers now spend intrinsic AND=`consume` and
    OR/default=`seek` independently at every top, blind/action, explicit-call, and recursive entry. Routed trace
    records each rule-owned policy. The accepted legacy API option no longer owns normal live execution, while
    descriptor/generated-source v1 output remains byte-compatible for `.9.1.3.3-.4`. Focused live 38/38,
    normalization 272/272, adjacent contracts, three-module syntax, and Phase 0 1,031/1,031 pass. Two seek-dependent
    historical fixtures were structurally migrated after exact descriptor/source/trace proof; the 91-file inventory
    remains exact through a one-for-one emitter/live-test swap. No matcher primitive, descriptor root, generated
    contract, CLI, shared fixture, or rollout-ledger boundary moved prematurely. Canonical local CI passes all
    doctrines, capability 80/0/0, neutral cursor 36/18/8/91 at 1/7 plus 27 mutations, generated v1, logical and
    diagnostic 8/0, coverage 246/105+1/122, reference CLI 63/63 twice, and Phase 0 1,031/1,031 in 629 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.3.2 - execute Perl rule-local cursors`

- ID: `FUTURE-PARITY-BACKLOG.9.1.3.3`
  Status: `done`
  Goal: Project the Perl v1 rule-local cursor descriptor and resolved-edge facts exactly.
  Dependencies: `.9.1.3.2`
  Acceptance: Add contract identity and family-derived `cursor_policy` per rule; remove global/per-rule
    `parse_mode`; expose normalized resolved-edge ownership/target/index/block/fluent facts without making source
    provenance semantic; and prove deterministic live versus descriptor agreement and exact failure shapes.
  Checklist:
  - [x] **KNOWLEDGE MAP / TOOLBOX BASELINE** — Retrieve the current outward-descriptor, CompilerState, RuleIR,
    runtime-context, and generated-v1 boundaries before changing descriptor schema; use `return_descriptor` and
    exact JSON/source probes rather than inferring from implementation text.
  - [x] **V1 IDENTITY / ROOT RETIREMENT** — Add `linkedspec-rule-local-cursor-v1`, remove root and per-rule legacy
    `parse_mode`, and retain only authored-family-derived cursor facts without advancing generated-source v1.
  - [x] **RESOLVED EDGE PROJECTION** — Emit deterministic per-rule normalized edge rows with ownership, target,
    optional regex index, block/fluent facts, and explicitly non-semantic source provenance.
  - [x] **LIVE / DESCRIPTOR AGREEMENT** — Prove every family and parent/child mechanism agrees between normalized
    descriptor policy and live execution, including default-family, explicit exceptions, and loaded source.
  - [x] **FAILURE / VERSION BOUNDARY** — Preserve exact portable normalization failures and prove descriptor v1 is
    current while standalone generated source remains v1/legacy until `.9.1.3.4`.
  - [x] **REGRESSION / LOCKSTEP / COMMIT** — Run focused and canonical gates; synchronize task/roadmap/live/memory,
    Knowledge Map and mdBook; clean generated artifacts; commit before activating generated-source v2 `.9.1.3.4`.
  Verification: **PASS 2026-07-17.** Focused descriptor/normalization/live suites pass 383 assertions. Toolbox JSON
    proves exact root, rule, resolved-edge, and generated-v1 identities. Neutral checker passes 36/18/8/90 at 1/7
    plus 27 mutations; callable schema, generated v1, capability 80/0/0, logical/diagnostic 8/0, and coverage
    246/105+1/122 remain exact. The first complete Phase 0 run exposed only two stale descriptor expectations: the
    retired root field and an explicit plan count that had not advanced with its new assertion. After those
    contract-test corrections, standalone Phase 0 passes 1,031/1,031 in 662 seconds. Canonical local CI passes all
    doctrines, focused registered contracts, reference CLI 63/63 twice, and Phase 0 1,031/1,031 in 634 seconds.
    Knowledge Map, memory/task governance, mdBook, whitespace, and safe generated-artifact cleanup pass. Generated
    source remains v1, rollout remains 1/7 until `.9.1.3.6`, and `.9.1.3.4` stays unactivated until the clean commit.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.3.3 - project Perl cursor descriptors`

- ID: `FUTURE-PARITY-BACKLOG.9.1.3.4`
  Status: `done`
  Goal: Emit and validate Perl generated-source v2 from family facts without a serialized cursor override.
  Dependencies: `.9.1.3.3`
  Acceptance: Advance the generated contract/version; retain exact ten-family plans; derive five seek and five
    consume handler families; reject v1 reconstruction at the v2 boundary with the portable mismatch diagnostic;
    require regeneration from `.spec`; and prove fresh emission, load, direct/traced execution, and source identity.
  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE** — `LinkedSpec::emit_generated_source` plus `return_descriptor` on one `Top::AND`
    probe reports descriptor `cursor_policy=consume`, but v1 seek/consume emissions have different SHA-256 values
    and the seek artifact contains `LinkedRE::or(..., $info)` without the contiguous `consume` argument. The
    pre-change `PERL5LIB= prove -Iperl t/generated_source_contract.t` baseline passes.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Generated-source dump and source inspection locate the split at
    `Compiler::run_get_pipeline`, which passes `use_rule_local_cursor => 0` for `generate_only`, and
    `SpecEntry::compile_spec_entry`, which emits a second `legacy_artifact_cursor_policy` handler. Normal live and
    descriptor handlers already consume the rule-family policy; only captured v1 source retains caller ownership.
  - [x] **TRACKED BASELINE-INTEGRITY REPAIR** — The first neutral-checker run found clean HEAD `ccf4cad7` already
    missing the listed action/lifecycle chapter token. `git log -S'parse_mode'` proves that inter-match decision
    commit removed the last token after `.9.1.3.3` without updating the executable inventory. This leaf owns the
    required reconciliation beside its own token-free `SpecEntry.pm`; Knowledge Map/live docs preserve the cause.
  - [x] **FIX** — Advance Perl emission/validation to generated-source v2, make family→policy derivation executable,
    remove the separate legacy artifact handler, and reject v1 reconstruction with exact portable fields.
  - [x] **ADDRESSED (verified)** — Prove exact ten-family/five-seek/five-consume mapping, option-independent source,
    fresh load, direct/traced values, identity, v1 mismatch, and mandatory `.spec` regeneration.
  - [x] **NO REGRESSION** — Run focused source/cursor suites, syntax, neutral/capability contracts, Phase 0, and the
    canonical local gate with true-stop evidence.
  - [x] **LOCKSTEP** — Synchronize task/roadmap/live/memory, mdBook, Knowledge Map, migration inventory, and cleanup;
    commit this slice before activating `.9.1.3.5`.
  Verification: **PASS 2026-07-17.** Focused generated/cursor/trace proof passes 400 assertions; adjacent logical,
    diagnostic, scalar, and Unicode suites pass 92; touched Perl modules compile. The neutral checker passes
    36/18/8/87 at 1/7 plus 27 mutations; shared generated-source v1 and capability ledgers remain 80/0/0; mdBook,
    Knowledge Map, whitespace, memory architecture, and doctrines pass. The first complete Phase-0 run exposed
    one stale generated-source expectation still assigning default-family policy to the legacy option; after that
    exact contract-test correction, standalone Phase 0 passes 1,031/1,031. Canonical local CI passes all registered
    contracts, reference CLI 63/63 twice, and Phase 0 1,031/1,031 in 619 seconds. Fresh v2 emission/load/direct/trace,
    option-independent bytes, all ten families, v1 caller inference, source identity, and existing drift failures
    are exact. Safe cleanup removes the generated 10 MB mdBook output and Python bytecode cache.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.3.4 - emit Perl generated-source v2`

- ID: `FUTURE-PARITY-BACKLOG.9.1.3.5`
  Status: `done`
  Goal: Migrate the Perl primary command and reference fixtures at the gate-safe ownership boundary fixed by `.0`.
  Dependencies: `.9.1.3.4`
  Acceptance: Remove the reference CLI flag/help/trace field with exact exit-2 diagnostic, migrate every Perl-owned
    test caller plus the exact reassigned shared manifest, help, usage, and seven trace byte files, preserve exact
    output bytes outside the retired field, and keep canonical reference CLI green without compatibility aliases
    or skipped cases.
  Acceptance Checklist:
  - [x] **REPRODUCE / INVENTORY** — Reverify the clean 63x2 reference CLI, exact 35 affected cases and ten shared
    fixture owners, every Perl/API/test token owner, current accepted-and-ignored option seam, and trace bytes.
  - [x] **ROOT CAUSE / BOUNDARY** — Locate API option preparation, primary exact argument parsing/help, canonical
    trace projection, manifest/fixture byte ownership, and every Perl-owned caller before mutation.
  - [x] **FIX** — Reject API/emitter `parse_mode` at `prepare_options` with exact portable fields, reject CLI
    `--parse-mode` at usage exit 2 with exact stderr, and remove help/trace projection without an alias or bypass.
  - [x] **MIGRATE / PRESERVE** — Migrate every owned Perl test/caller plus the exact shared manifest/help/usage/seven
    trace files; preserve all result/error/trace bytes outside the retired field and all 63 registered cases.
  - [x] **NO REGRESSION** — Run focused API/CLI/trace/cursor/generated suites, exact default/POSIX 63x2, Phase 0,
    neutral/capability contracts, and canonical local CI with true-stop evidence.
  - [x] **LOCKSTEP** — Synchronize task/roadmap/live/memory, public mdBook, Knowledge Map, executable inventory, and
    cleanup; commit this slice before activating composed Perl admission `.9.1.3.6`.
  Verification: **PASS 2026-07-17.** Baseline reference CLI passed 63/63 twice and the audit assigned exactly 35
    affected cases plus ten shared byte owners. API/Get/get-parser/emitter removal rejects at `prepare_options`
    before invalid-source parsing with exact portable fields and retained generated-source identity; focused
    Perl API/cursor/generated/trace/scalar/logical/diagnostic/Unicode proof passes 191 assertions, and the repaired
    descriptor contract passes 31. The shared reference target passes 63/63 in default and POSIX environments;
    standalone Phase 0 passes 1,031/1,031 in 606 seconds. Neutral cursor passes 36/18/8/72 at 1/7 plus 27
    mutations; generated-source/capability remain 80/0/0; Knowledge Map passes 584 facts / 4,121 question keys;
    mdBook, JSON, syntax, whitespace, memory, task metadata, doctrines, and cleanup pass. The first canonical run
    correctly stopped when a descriptor test dynamically constructed the retired key but asserted a literal
    removal code, making that test a newly unowned token path; the assertion now consumes the neutral contract
    value and the exact inventory remains 72. Canonical rerun passes every registered contract, reference CLI
    63/63 twice, and Phase 0 1,031/1,031 in 634 seconds with exit 0.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.3.5 - remove Perl cursor overrides`

- ID: `FUTURE-PARITY-BACKLOG.9.1.3.6`
  Status: `done`
  Goal: Admit and close the complete Perl reference projection of the neutral contract.
  Dependencies: `.9.1.3.5`
  Acceptance: One omission-sensitive Perl consumer composes live, descriptor, emitted, generated, loaded-spec,
    trace, diagnostic, recursive/mixed-parent, default-family, structural-replacement, and primary-command roles;
    advance only `perl_reference` to complete; synchronize roadmap/book/KM/live docs; run canonical gates; close
    parent `.9.1.3`; and hand off Rust `.9.1.4` only after a clean commit.
  Acceptance Checklist:
  - [x] **RETRIEVE / BASELINE** — Read ADR `0044`, the neutral contract/rollout/Perl boundary Knowledge Map cards,
    executable checker, all `.9.1.3.1-.5` consumers, and canonical registration; reverify the exact 1/7, 72-file,
    63x2, descriptor-v1, generated-v2, live/loaded/trace, and diagnostic baseline before edits.
  - [x] **OMISSION-SENSITIVE COMPOSITION** — Add one contract-driven Perl admission consumer that requires every
    declared Perl projection: live, descriptor, emitted source, generated direct/traced, loaded `.spec`, default
    and AND families, recursion/mixed parents, structural replacements, portable diagnostics, and primary CLI.
  - [x] **ADVANCE ONLY PERL** — Promote only `perl_reference` from pending to complete after the composed consumer
    passes; keep Rust/Dart/Julia/Lua/generated/gate legs pending and preserve exact 72-file migration ownership.
  - [x] **NO REGRESSION / TRUE STOP** — Run focused composed and constituent Perl suites, neutral checker with all
    mutations, shared generated/capability contracts, reference CLI 63x2, Phase 0, and canonical local CI with
    true-stop evidence; do not run an implementation mutation campaign.
  - [x] **LOCKSTEP / CLOSE PARENT** — Synchronize task/index/roadmap/live/memory, changes/notes, mdBook, Knowledge
    Map, contract documentation, and cleanup; close `.9.1.3`, activate Rust `.9.1.4` only after the clean commit,
    and clear/verify the commit brief.
  Verification: **PASS 2026-07-17.** Clean baseline passes four constituent suites at 394 assertions, the checker
    at 1/7 with 27 mutations, and the already-current 63x2 reference matrix. The extended consumer passes 288
    tests across all 14 contract-declared roles exactly once and observes all eight diagnostic codes; focused
    composition with execution/descriptor/generated suites passes 410 assertions. The independent checker
    requires every role marker plus canonical registration, rejects 29 mutations, retains exactly 72 migration
    files, and advances only `perl_reference` to reach 2 complete / 6 pending. Generated-source/capability remain
    80/0/0; reference CLI passes 63/63 in default and POSIX environments. One manual POSIX probe used a deliberately
    different display label and therefore failed only 22 substituted help/usage bytes; the corrected canonical
    label passes 63/63 and canonical CI independently repeats that result. Standalone Phase 0 passes 1,031/1,031
    in 641 seconds. Knowledge Map is 584 facts / 4,126 question keys; JSON, Python/Perl/shell syntax, mdBook,
    memory/task/doctrine/whitespace/cleanup pass. Canonical local CI runs the new 288-test consumer, passes CLI
    63x2 and Phase 0 1,031/1,031 in 642 seconds, and exits 0. No runtime or implementation mutation campaign.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.3.6 - admit Perl cursor projection`

- ID: `FUTURE-PARITY-BACKLOG.9.1.4`
  Status: `done`
  Goal: Align Rust parsed/compiled/serialized/native/generated/primary behavior with ADR `0044`.
  Children: `.9.1.4.0` (preflight/split), `.9.1.4.1` (local-gate hardening), `.9.1.4.2` (family/edge
    normalization), `.9.1.4.3` (live/reconstructed execution), `.9.1.4.4` (descriptor v1), `.9.1.4.5`
    (generated-source v2), `.9.1.4.6` (option/CLI migration), `.9.1.4.7` (composed admission/closeout)
  Dependencies: `.9.1.3`
  Acceptance: Remove `ExecutionOptions` and runtime-context global override ownership plus the blind-call consume
    special case; normalize bare edges into typed AST; derive rule/plan cursor facts from family; consume the v2
    descriptor/generated contracts and portable failures; migrate fixtures/callers; and prove direct, reconstructed,
    emitted/generated, trace, recursion, loaded-state, and rebuilt primary-command projections.
  Verification: **PASS 2026-07-18.** Children `.0-.7` harden the focused gate, normalize all 36 authored family
    spellings and bare/explicit edges into typed ownership, derive intrinsic policy through live/loaded/ordinary
    reconstruction, project descriptor v1, emit/reconstruct generated-source v2, remove global API/CLI/trace
    ownership, preserve the exact 63x2 primary contract, and compose 15 required Rust roles plus every portable
    diagnostic/removal outcome. The governed inventory is 68, checker rollout is 3/5 with 34 rejected mutations,
    complete Rust proof passes, and canonical CI passes Perl admission 288, reference primary 63x2, and Phase 0
    1,031/1,031 in 612 seconds before exiting 0. Dart remains unchanged and dependency-gated until this closeout
    commits cleanly.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.4.7 - admit Rust rule-local cursor contract`

- ID: `FUTURE-PARITY-BACKLOG.9.1.4.0`
  Status: `done`
  Goal: Audit and split the Rust rule-local cursor rollout into gate-safe mechanism leaves before behavior code.
  Dependencies: `.9.1.3`
  Acceptance: Use the Knowledge Map and LinkedSpec/Rust probes first; map every Rust-owned token and non-token
    parser/compiler/runtime/descriptor/serialized/emitter/primary/test seam; measure current family, bare-edge,
    parent/child, option/CLI, v1/v2, and shared-fixture behavior; identify the exact canonical and Rust-local gates;
    and replace the broad parent with dependency-ordered safe children without changing executable behavior.
  Acceptance Checklist:
  - [x] **RETRIEVE / TOOLBOX FIRST** — Read ADR `0044`, neutral/Perl/Rust generated/descriptor/CLI Knowledge Map
    authorities, `TOOLBOX.md`, the neutral checker/inventory, and current Rust local-gate commands before probing.
  - [x] **EXACT RUST SURFACE MAP** — Account for all eight token-owned Rust files plus non-token grammar/AST,
    serialization, emitter, generated-plan/source, corpus/primary adapters, fixtures, tests, and documentation seams.
  - [x] **REPRODUCE CURRENT BOUNDARIES** — Prove default/AND cursor behavior, all four mixed parent/child mechanisms,
    bare-edge handling, explicit-edge exceptions, dynamic/typed option and CLI behavior, descriptor shape,
    generated/serialized contract versions, and current shared 63-case impact with exact source locations.
  - [x] **SAFE IMPLEMENTATION SPLIT** — Add dependency-ordered child leaves for syntax/typed normalization, live and
    reconstructed execution, descriptor/generated-v2 projection, option/CLI/fixture migration, composed Rust
    admission, and any separately necessary gate/no-drift boundary found by evidence.
  - [x] **NO REGRESSION / LOCKSTEP** — Change no Rust or shared executable behavior; run focused Rust baseline,
    neutral checker, reference CLI, governance/KM/mdBook/whitespace checks, update task/index/roadmap/live/memory,
    and commit the preflight before activating the first behavior child.
  Verification: **PASS 2026-07-17.** The audit accounts for all eight token-owned Rust files and the non-token
    AST/parser/validation/error, loader/parser adapters, source emitter, generated classifier, runtime/trace,
    fixture, test, gate, and public-document seams. Toolbox-first probes prove current default seek and AND
    consume, global option override, compact `|` misclassification, silently ignored complete-line bare edges,
    missing indexed/grouped bare-edge rejection, and eight parent/child mechanism results. Compiled rules and
    descriptors serialize mutable `parse_mode`; generated source remains v1/format 1 and its blind-family branch
    recognizes only explicit OR. The full runtime-package baseline passes, including 137 unit tests, 197
    integrations, the 105-case generated classifier, and all emitted/contract suites. The omitted core package
    independently passes 188 unit + 3 descriptor + 8 type tests. Rust primary reaches 51/63 in both default and
    POSIX environments with exactly one retired-flag and eleven trace-field failures; Perl reference remains
    63/63 twice. The neutral checker passes 36/18/8/14/72 at 2/6 and rejects 29 mutations. No Rust/shared
    executable behavior changes. The audit discovers that `tools/run_rust_local.sh` does not run the core
    package's own tests despite central parser/compiler ownership; `.9.1.4.1` repairs that gate before semantic
    work, and the durable Knowledge Map card records the current topology. Knowledge Map passes at 584 facts /
    4,129 question keys; mdBook, memory, task, doctrine, cursor, whitespace, and syntax checks pass. Canonical
    local CI repeats the 288-test Perl admission consumer and 63x2 reference CLI, passes Phase 0 1,031/1,031 in
    640 seconds, and exits 0.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.4.0 - audit Rust cursor rollout boundaries`

- ID: `FUTURE-PARITY-BACKLOG.9.1.4.1`
  Status: `done`
  Goal: Make the focused Rust gate cover the core package before cursor behavior changes.
  Dependencies: `.9.1.4.0`
  Acceptance: `tools/run_rust_local.sh` must run the complete `linkedspec-core` package, including its parser,
    compiler, validation, descriptor, serialization, and integration tests, before the runtime package; update
    operational docs/KM and prove that the gate still reaches only the already-measured 12 primary migration
    failures, without changing parser/compiler/runtime behavior.
  Acceptance Checklist:
  - [x] **RETRIEVE / REPRODUCE** — Re-read the preflight evidence and gate source; independently prove the omitted
    core package is green and that the current script reaches runtime/CLI without executing core tests.
  - [x] **HARDEN TOPOLOGY** — Run the complete `linkedspec-core` package immediately after formatting and before
    the complete runtime package, using the same manifest and configurable Cargo command without test filters.
  - [x] **PROVE ORDER / STAGED RED** — Pass shell syntax plus independent core tests; run the actual focused gate
    far enough to observe core and runtime success before exactly the known 12/63 default CLI migration failures;
    separately preserve the measured POSIX 12/63 result from `.0` without compatibility skips.
  - [x] **LOCKSTEP / NO BEHAVIOR CHANGE** — Update task/index/roadmap/live/memory, Rust operational README/mdBook,
    and Knowledge Map from omitted to covered; run cursor/governance/mdBook/canonical gates; change no Rust
    parser/compiler/runtime code; commit before activating normalization `.9.1.4.2`.
  Verification: **PASS 2026-07-17.** `bash -n` passes. Actual `bash tools/run_rust_local.sh` logs formatting,
    then the newly mandatory core package, then runtime: core passes 188 unit, three descriptor, eight type, and
    doc tests; runtime passes all 137 unit, 105-fixture oracle, seven diagnostic, 105-case generated classifier,
    197 integration, emitted-source, trace, loader, Unicode, binding, variadic, and doc-test suites. Only after
    both packages pass does the script build the primary command and reach the exact preflight boundary: default
    CLI passes 51/63 and fails only the retired option plus eleven trace projections. The script correctly stops
    there; `.0` independently proved POSIX has the identical 51/63 result. Neutral cursor stays 36/18/8/14/72 at
    2/6 plus 29 mutations. No Rust parser/compiler/runtime source or behavior changes. Operational README, Rust
    README, mdBook, Knowledge Map, roadmap/task/live/memory, and canonical governance are synchronized.
    The first canonical attempt correctly stopped at the public logical-helper checker because the task-index row
    replacement dropped its required exact `.5.2` closure marker. Restoring that governed sentence alongside the
    new cursor frontier made the focused checker green. The complete canonical rerun passes the 288-test composed
    Perl consumer, reference CLI 63/63 in both option environments, and Phase 0 1,031/1,031 in 646 seconds, then
    exits 0.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.4.1 - run Rust core tests in local gate`

- ID: `FUTURE-PARITY-BACKLOG.9.1.4.2`
  Status: `done`
  Goal: Normalize Rust rule families and bare edges into exact typed ownership before runtime policy changes.
  Dependencies: `.9.1.4.1`
  Acceptance: Correct compact/default/OR versus AND family classification; retain complete-line and header-rest
    bare plain/indexed/grouped/block/fluent candidates as typed AST; lower family-derived action/blind ownership;
    preserve explicit cross-family exceptions; reject mixed, undefined, invalid-index, and missing-shared-block
    forms with the neutral portable diagnostics; and prove parser/compiler/validation source locations and no
    silent `Raw` loss without changing cursor execution yet.
  Acceptance Checklist:
  - [x] **RETRIEVE / REPRODUCE** — Follow Knowledge Map, ADR `0044`, neutral contract, toolbox probes, and the
    `.9.1.4.0` preflight to exact Rust AST/parser/compiler/validation source locations; reproduce compact-family,
    bare-edge `Raw` loss, cross-family override, and diagnostic boundaries before editing executable code.
  - [x] **NORMALIZE FAMILY / TYPED EDGES** — Classify default/OR/compact-OR versus AND/compact-AND correctly and
    retain complete-line plus header-rest bare plain/indexed/grouped/block/fluent candidates as typed AST, with
    family-derived action/blind ownership and explicit cross-family exceptions.
  - [x] **VALIDATE EXACTLY** — Reject mixed edge modes, undefined targets, invalid indices, and missing shared
    edge blocks through the neutral portable diagnostic identities, with no silently ignored `Raw` candidate.
  - [x] **PROVE REPRESENTATION / FREEZE EXECUTION** — Add focused parser/compiler/validation tests for every
    governed family and bare-edge shape, prove typed compiled ownership/serialization source locations, and show
    live cursor execution remains at the staged pre-`.3` behavior boundary.
  - [x] **LOCKSTEP / SIGNOFF** — Synchronize task/index/roadmap/live/memory, Knowledge Map, mdBook, and operational
    docs; run focused core/runtime and neutral/governance/canonical gates; commit before activating execution
    leaf `.9.1.4.3`.
  Verification: **PASS 2026-07-18.** Knowledge Map routes to ADR `0044`, the 36-family/18-edge neutral
    contract, parent/child ownership, and the Perl reference normalization seam before source inspection. Exact
    Rust CLI probes reproduce `null` for complete-line bare, header-rest bare, undefined bare, AND bare-index,
    and compact-`|` leading-junk inputs. Source pins the losses to parser `Raw` fallback, blind-index suffix
    discard, missing grouped/shared-block checks, `is_and()` conflating `|` with AND, compiler ignoring `Raw`,
    and the later-leaf blind-call consume special case. No executable edit preceded this evidence. Implementation
    now keeps authored `is_and()` exact and isolates old runtime/artifact consumers behind the explicitly temporary
    `uses_legacy_and_interpretation()` seam. `BareEdge` retains complete-line/header-rest targets, optional index,
    shared block, and fluent facts through whole-spec validation; valid AND ownership lowers to bcode and valid
    OR/default ownership to acode, while explicit cross-family edges retain their written ownership. A sorted,
    serializable `PortableDiagnostic` carries every neutral code/stage/field.

    Contract-driven core proof passes all five tests over 36 family rows, 18 edge rows, six rule-edge ownership
    sets, complete-line/header-rest/multiline scope, exact diagnostics, compiled dispatch tables, and JSON
    roundtrip. Three runtime boundary tests pass: embedding execution reaches the typed AND blind table as
    `[["hit"]]` but default/header-rest action entry and compact-OR leading-junk remain staged as `[]`; the primary
    command projects the same split as `["hit"]` versus `null`. The full core and runtime packages pass, including
    137 runtime unit, 105-fixture oracle/classifier, 197 integration, and all adjacent suites. Production-library
    Clippy exits 0 with only the established baseline warnings; all-target Clippy reaches the already-tracked
    test-only `approx_constant` denial. The neutral checker returns 36/18/8/14/72 at 2/6 plus 29 mutations;
    lockstep documentation and canonical signoff pass as recorded below.

    An initial actual-gate attempt exhausted its final 1.1 GiB during generated host compilation after core,
    runtime unit, named-mark, oracle, and diagnostic proof had passed. Safe cleanup removed only reproducible
    target/book/temp/log artifacts and preserved tracked RGX evidence plus the pre-existing dirty nested pgen tree.
    On resume, the focused classifier passes all 105 cases through read/parse/validate/compile/interpreter/emission/
    host compile/run in 247.75 seconds. The complete `tools/run_rust_local.sh` then passes formatting; core 189 unit,
    three descriptor, five normalization, and eight type tests; runtime 137 unit, named-mark, 105-fixture oracle
    (219.46 seconds), seven diagnostic, generated classifier 105/105 (256.48 seconds), 197 integration, and every
    adjacent suite. It builds the primary command and stops only at the exact staged default 51/63 boundary: the
    retired-option diagnostic plus eleven request-trace `parse_mode=seek` projections. `.9.1.4.0` independently
    pins POSIX to the same 51/63. The neutral checker passes 36/18/8/14/72 at 2/6 and rejects 29 mutations;
    Knowledge Map reaches 585 facts/4,138 keys; memory architecture, task metadata, all four doctrines, mdBook,
    and whitespace pass. Canonical local CI repeats the 288-test composed Perl consumer, reference CLI 63/63 in
    both option environments, and Phase 0 1,031/1,031 in 646 seconds, then exits 0.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.4.2 - normalize Rust rule edges`

- ID: `FUTURE-PARITY-BACKLOG.9.1.4.3`
  Status: `done`
  Goal: Make Rust live, loaded, serialized, and reconstructed execution spend each rule's family-derived policy.
  Dependencies: `.9.1.4.2`
  Acceptance: Remove the blind-call consume special case and mutable compiled-rule policy field; derive AND
    consume and OR/default seek independently for each entered rule across action, blind, direct call, recursion,
    loaded compiled state, JSON roundtrip, and trace; preserve low-level seek/consume matcher algorithms and the
    staged public override until `.9.1.4.6`; prove all eight parent/child mechanisms and structural replacements.
  Acceptance Checklist:
  - [x] **RETRIEVE / REPRODUCE** — Follow the Knowledge Map, ADR `0044`, neutral contract, toolbox probes, `.0`
    preflight, and `.2` normalization card to exact live/loaded/serialized/trace policy seams; reproduce the
    blind-call special case, mutable compiled policy, and all eight mixed parent/child baselines before editing.
  - [x] **SPEND RULE-LOCAL POLICY** — Derive seek/consume from each entered rule's authored family across action,
    blind, direct, recursive, loaded, and compiled-JSON-roundtrip execution; remove parent/global propagation and
    the blind-call consume special case while preserving the low-level seek/consume matcher algorithms.
  - [x] **PRESERVE STAGED SURFACES** — Keep descriptor v1, generated-source v1, and public option/CLI projection
    unchanged for `.4-.6`; retain only an explicit bounded adapter where a later leaf still owns migration.
  - [x] **PROVE COMPOSITION** — Cover all eight neutral parent/child mechanisms, both structural replacements,
    top-level family rows, direct/trace identity, recursion, loaded state, and JSON roundtrip with focused tests.
  - [x] **LOCKSTEP / SIGNOFF** — Synchronize task/index/roadmap/live/memory, Knowledge Map, mdBook, and operational
    docs; run focused Rust plus neutral/governance/canonical gates; commit before descriptor leaf `.9.1.4.4`.
  Verification: **PASS 2026-07-18.** Knowledge Map retrieval reaches ADR `0044`, the neutral 36-family/
    eight-parent-child/two-structural contract, Rust normalization, original ownership audit, and direct-value seam
    before source inspection. Pre-edit probes reproduce authored AND and wrongly compact-`|` consume on leading
    junk, global-option propagation into both AND/default, correct ordered landmarks, wrong compact-OR anchored
    choice, and routed trace proof; no executable edit preceded the evidence.

    `CompiledRule` no longer stores an independently mutable cursor field. `cursor_policy()` derives exact AND
    consume versus default/OR seek, and normal `Engine::execute_rule` spends it on every entry. Exact
    `mode.is_and()` now owns blind orchestration and implicit sequence projection, removing the bcode consume
    special case from normal execution. Ordinary JSON omits the field and derives after reconstruction; loaded,
    action, blind, direct-call, and recursive paths converge through the same engine. Descriptor/generated-source
    v1 retain only `legacy_artifact_parse_mode()` plus a private 17-field v1 wire serializer for `.4-.5`; the
    still-present public option cannot override live behavior and remains removal debt for `.6`.

    Focused proof passes runtime execution 6/6 over all 36 family rows, eight parent/child mechanisms, two
    structural cases, live/JSON, loaded/trace, recursion, and staged artifacts; runtime normalization 3/3; core
    normalization 5/5; types 8/8; descriptor 3/3; source emitter 5/5; core library 189/189; runtime library 137/137;
    formatting; and production-library Clippy. The complete focused gate passes core 189/3/5/8; runtime 137,
    named marks, the 105-fixture oracle in 216.25 seconds, seven diagnostics, generated classifier 105/105 in
    243.60 seconds, 197 integrations, and every adjacent suite. It then reaches exactly the governed default
    primary boundary: 51/63 pass, with only option retirement plus eleven request-trace projections assigned to
    `.6`. The neutral checker passes 36/18/8/14/74 at 2/6 and rejects 29 mutations. Knowledge Map reaches 586
    facts/4,151 keys; memory architecture, task metadata, all four doctrines, mdBook, JSON, formatting, and
    whitespace pass. Canonical local CI repeats the 288-test composed Perl consumer, reference CLI 63/63 in both
    environments, and Phase 0 1,031/1,031 in 612 seconds, then exits 0. Descriptor `.9.1.4.4` follows only after
    this verified leaf commits cleanly.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.4.3 - derive Rust rule-local cursor policy`

- ID: `FUTURE-PARITY-BACKLOG.9.1.4.4`
  Status: `done`
  Goal: Project Rust's rule-local cursor descriptor v1 from normalized compiled semantics.
  Dependencies: `.9.1.4.3`
  Acceptance: Emit the neutral descriptor identity, remove root/rule global `parse_mode`, publish authored family,
    derived `cursor_policy`, and ordered resolved-edge ownership facts, prove direct and compiled-JSON-roundtrip
    identity plus live agreement, and keep generated-source v1 independently staged.
  Acceptance Checklist:
  - [x] **RETRIEVE / REPRODUCE** — Follow the Knowledge Map, ADR `0044`, neutral descriptor contract, Perl
    reference projection, Rust normalization/execution cards, and toolbox probes to the exact descriptor builder,
    schema, consumer, and roundtrip seams; record direct and reconstructed pre-edit output before executable edits.
  - [x] **PROJECT NEUTRAL V1** — Emit the exact neutral descriptor identity, remove root/rule `parse_mode`, and
    publish each rule's authored family plus derived `cursor_policy` without independently mutable policy state.
  - [x] **RESOLVE ORDERED EDGES** — Publish normalized ordered action/blind resolved-edge ownership, including
    plain/indexed/grouped/shared-block/fluent and explicit cross-family cases, with exact portable facts.
  - [x] **PROVE IDENTITY / LIVE AGREEMENT** — Prove direct descriptor and compiled-JSON-roundtrip byte identity,
    family/policy/edge coverage, and agreement between descriptor facts and normal live rule entry while generated
    source v1 remains independently staged for `.9.1.4.5`.
  - [x] **LOCKSTEP / SIGNOFF** — Synchronize task/index/roadmap/live/memory, Knowledge Map, mdBook, and operational
    docs; run focused Rust plus neutral/governance/canonical gates; commit before generated-source leaf `.9.1.4.5`.
  Verification: Focused implementation proof passes. Knowledge Map/ADR/neutral/Perl retrieval and the isolated
    pre-edit probe identified exact source locations and reproduced direct/reconstructed identity alongside root
    and rule global fields, absent cursor identity/family/resolved rows, and the wrong consume description for a
    default blind parent. The disposable probe build was deleted immediately after evidence capture.

    `CompiledDescriptorMeta` now emits `linkedspec-rule-local-cursor-v1` without a global field. Every rule emits
    normalized `family`, `cursor_policy`, aggregate `edge_ownership`, exact authored-mode facts, and ordered
    semantic `resolved_edges`. Action rows use the selected child regex index; blind rows use null; block and
    fluent facts come from compiled state. Optional non-semantic bare/explicit provenance is deliberately omitted
    rather than guessed after normalization. Generated-source v1 remains unchanged and exclusively owns the
    bounded compatibility adapter until `.5`.

    Contract-driven descriptor proof passes 4/4 across all 36 family spellings, every valid neutral edge case,
    exact metadata variants/semantic fields/order, and direct/ordinary compiled-JSON identity. Runtime execution
    passes 6/6 with descriptor/live agreement for all 36 families and loaded parent/child projection. Full core
    passes 189 unit + 4 descriptor + 5 normalization + 8 type tests; runtime library passes 137; formatting and
    production-library Clippy pass. Complete `tools/run_rust_local.sh` passes the 105-fixture oracle in 206.35
    seconds, seven diagnostics, generated classifier 105/105 in 235.29 seconds, 197 integrations, and every
    adjacent suite, then reaches only the exact governed `.6` CLI boundary at 51/63. Token-free `descriptor.rs`
    retires from the inventory, and the neutral checker passes 36/18/8/14/73 at 2/6 plus 29 mutations. Knowledge
    Map passes at 586 facts/4,155 keys; memory architecture, task metadata, all four doctrines, mdBook, JSON,
    formatting, whitespace, and cleanup pass. Canonical local CI repeats the 288-test composed Perl consumer,
    reference CLI 63/63 in default and POSIX environments, and Phase 0 1,031/1,031 in 610 seconds, then exits 0.
    Generated-source `.9.1.4.5` follows only after this verified leaf commits cleanly.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.4.4 - project Rust cursor descriptor v1`

- ID: `FUTURE-PARITY-BACKLOG.9.1.4.5`
  Status: `done`
  Goal: Emit and reconstruct Rust generated-source v2 from the minimal family plan.
  Dependencies: `.9.1.4.4`
  Acceptance: Identify v2/format 2, retain only ordered label/family rows, derive cursor policy from all ten
    families with no serialized cursor field, reject v1 reconstruction with exact expected/actual contract and
    regeneration guidance, and prove deterministic emission, fresh compile/load, direct/traced execution, all
    families, source identity, corpus subset, and the exhaustive 105-case generated classifier.
  Acceptance Checklist:
  - [x] **RETRIEVE / REPRODUCE** — Follow the Knowledge Map, ADR `0044`, neutral generated-v2 contract, Perl v2
    reference, Rust generated-v1 architecture, and toolbox source dump to the exact emitter/reconstructor/trace/
    test seams; capture deterministic pre-edit v1 metadata/plan/reconstruction behavior before executable edits.
  - [x] **EMIT MINIMAL V2 PLAN** — Identify new artifacts as generated-source v2 / format 2 and serialize only
    deterministic ordered rule labels plus authored families, with no cursor policy or global mode field.
  - [x] **DERIVE / RECONSTRUCT / REJECT V1** — Derive seek/consume from all ten emitted families during fresh
    reconstruction, preserve direct and traced behavior/source identity, and reject v1 with exact expected/actual
    metadata plus `.spec` regeneration guidance rather than inferring caller/global policy.
  - [x] **PROVE ARTIFACT BREADTH** — Prove deterministic emission, fresh host compile/load, direct/trace execution,
    all families, the governed corpus subset, and the exhaustive 105-case generated classifier without weakening
    existing semantic/diagnostic/source locks.
  - [x] **LOCKSTEP / SIGNOFF** — Synchronize task/index/roadmap/live/memory, Knowledge Map, mdBook, and operational
    docs; run focused Rust plus neutral/governance/canonical gates; commit before public-removal leaf `.9.1.4.6`.
  Verification: Retrieval and pre-edit v1 probes are complete. Focused v2 testing caught a classifier seam before
    signoff: core `RuleMode::is_repetition()` intentionally includes unsuffixed `Default` because live execution
    loops, while the generated-v2 family contract reserves the `default` row and uses `rep_*` only for explicit
    repetition suffixes. The emitter now keeps those predicates distinct. Core passes 189/4/5/8; runtime 137;
    oracle 105 in 205.58 seconds; diagnostics 7; the exhaustive generated classifier passes 105/105 in 234.84
    seconds; integrations 197; source emitter 5 in 37.16 seconds; rule-local execution 6 in 59.37 seconds; every
    adjacent suite, formatting, and production-library Clippy pass. The focused driver reaches only the exact
    staged `.6` primary boundary at 51/63. Canonical signoff caught and repaired stale recurring logical-helper
    v1 role names; its checker passes all 26 mutations. Neutral cursor passes 36/18/8/14/71 at 2/6 plus 29
    mutations; Knowledge Map passes at 587/4,165; memory/task/four-doctrine/mdBook/JSON/whitespace checks pass.
    Canonical CI passes Perl cursor 288, reference CLI 63/63 twice, and Phase 0 1,031/1,031 in 609 seconds, then
    exits 0. Clean commit remains the sole boundary before `.9.1.4.6` activation.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.4.5 - emit Rust generated-source v2`
  Commit: `727cccc3`

- ID: `FUTURE-PARITY-BACKLOG.9.1.4.6`
  Status: `done`
  Goal: Remove Rust global cursor overrides and migrate the shared primary-command projection.
  Dependencies: `.9.1.4.5`
  Acceptance: Remove `ExecutionOptions::with_parse_mode`, runtime-context override/effective-mode ownership, the
    primary `--parse-mode` flag/help/request-trace field, and every non-removal caller; return the exact targeted
    usage exit 2; migrate the shared 63-case fixture bytes owned by the Perl reference; and pass Rust 63/63 in
    default and POSIX environments with unchanged non-retired output/trace bytes.
  Acceptance Checklist:
  - [x] **RETRIEVE / REPRODUCE** — Follow the Knowledge Map, ADR `0044`, neutral cursor contract, Perl removal
    reference, Rust option/runtime/primary/trace seams, and shared 63-case authorities; reproduce the exact 51/63
    default and POSIX baseline before executable edits.
  - [x] **REMOVE LIBRARY OVERRIDE** — Remove `ExecutionOptions::with_parse_mode`, runtime-context override and
    effective-mode ownership, and every non-removal caller without changing family-derived normal execution.
  - [x] **REMOVE PRIMARY SURFACE** — Remove `--parse-mode` parsing/help/request-trace projection, reject the retired
    spelling with the exact targeted usage exit 2, and preserve every unrelated help/output/trace byte.
  - [x] **MIGRATE EXACT 63x2 PROJECTION** — Consume the reference-owned shared fixture bytes, keep structural
    default-seek and AND-consume successes, and pass all 63 Rust cases in default and POSIX option environments.
  - [x] **REPAIR STALE PUBLIC GENERATED MARKER** — Root-cause the logical-helper public no-drift gate's obsolete
    Rust generated-v1 marker exposed by mdBook/backend documentation lockstep, migrate both neutral and checker
    authorities to the already-current generated-v2 API, and retain omission-mutation proof.
  - [x] **LOCKSTEP / SIGNOFF** — Reconcile the exact migration inventory, task/index/roadmap/live/memory, Knowledge
    Map, mdBook, and operational docs; run focused Rust plus neutral/governance/canonical gates; commit before
    composed-admission leaf `.9.1.4.7`.
  Verification: Knowledge Map cards for Rust rule-local execution/primary CLI and Perl removal, ADR `0044`, the
    neutral option/CLI/inventory contract, exact reference implementation, and focused-gate command were retrieved
    before executable inspection. Both default and `POSIXLY_CORRECT=1` Rust runs reproduce exactly 51/63: only
    `usage_removed_parse_mode` plus 11 canonical trace cases retaining `parse_mode=seek` fail. After removal,
    rule-local execution passes 6/6 in 59.31 seconds, primary adapter units pass 6/6, and the exact Rust primary
    projection passes 63/63 in default and POSIX environments. Complete runtime passes 137 units, oracle 3 in
    205.39 seconds, diagnostics 7, classifier 105/105 in 235.07 seconds, integrations 197, source emitter 5 in
    37.10 seconds, execution 6 in 59.57 seconds, and every adjacent suite; core passes 189/4/5/8, formatting and
    production-library Clippy pass, and the neutral checker passes 36/18/8/14/68 at 2/6 plus 29 mutations. Three
    obsolete mdBook option-teaching pages become token-free while `rust/README.md` becomes the explicit retired-
    flag owner. The full focused gate exits 0: core passes 189/4/5/8, runtime 137, oracle 3 in 205.44 seconds,
    diagnostics 7, classifier 105/105 in 235.42 seconds, integrations 197 in 75.12 seconds, rule-local execution 6
    in 59.52 seconds, source emitter 5 in 37.18 seconds, every adjacent suite, and exact primary 63/63 twice.
    The logical-helper checker's stale v1 public marker is migrated to the already-current v2 API and all 26 drift
    mutations still reject. Canonical local CI exits 0 with the composed Perl cursor consumer at 288 tests,
    reference CLI 63/63 in default and POSIX environments, and Phase 0 `1..1031` in 611 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.4.6 - remove Rust global cursor overrides`
  Commit: `2bba1e91`

- ID: `FUTURE-PARITY-BACKLOG.9.1.4.7`
  Status: `done`
  Goal: Admit and close the complete Rust projection of the neutral rule-local cursor contract.
  Dependencies: `.9.1.4.6`
  Acceptance: Add one omission-sensitive contract-driven consumer spanning native, loaded, serialized,
    descriptor, emitted/generated, trace, diagnostics, recursion/mixed parents, structural replacement, and
    primary roles; register it canonically; advance only `rust_parity` in the rollout ledger; run focused/core/
    runtime/63x2/canonical gates; synchronize public/live/KM docs; close `.9.1.4`; and hand off Dart only after a
    clean commit.
  Acceptance Checklist:
  - [x] **RETRIEVE / REPRODUCE** — Follow the Knowledge Map to ADR `0044`, the neutral contract/checker and Perl
    composed-admission reference, then reproduce the current 2/6 ledger, 68-file inventory, exact Rust constituent
    tests, and all canonical registration seams before executable edits.
  - [x] **DEFINE RUST COMPOSED TOPOLOGY** — Extend the neutral authority with one exact omission-sensitive Rust
    admission surface spanning native, loaded, ordinary serialized, descriptor, emitted/generated direct/trace,
    diagnostics, mixed/recursive, structural replacement, and primary roles without duplicating constituent tests.
  - [x] **IMPLEMENT ONE CONSUMER** — Add one contract-driven Rust consumer that composes every required role and
    all portable diagnostic/removal outcomes from unchanged neutral fixtures, with exact source/trace/result
    identity and deterministic omission detection.
  - [x] **REGISTER / ADVANCE ONLY RUST** — Register the composed consumer in canonical CI, advance only
    `rust_parity` from pending to complete, preserve every later leg, and make both missing registration and any
    omitted role fail the neutral checker.
  - [x] **LOCKSTEP / CLOSEOUT** — Pass constituent, composed, complete focused Rust, 63x2, neutral mutation,
    governance, mdBook, and canonical gates; synchronize task/index/roadmap/live/memory/KM docs; close `.9.1.4`;
    commit cleanly before activating Dart `.9.1.5`.
  Verification: Task-tree activation follows clean commit `2bba1e91`. Knowledge Map cards for the neutral
    contract, Perl rollout boundary, and Rust execution were followed to ADR `0044`, the complete neutral JSON and
    checker, the complete 463-line Perl composed consumer, and the canonical/default-plus-optional-Rust gate seams
    before executable edits. Pre-edit proof is exact: the neutral checker reports 36 family spellings, 18 edge
    cases, eight parent/child cases, 14 Perl roles, 68 migration files, 2 complete / 6 pending, and 29 rejected
    mutations; Rust core normalization passes 5/5, descriptors 4/4, runtime cursor execution 6/6, generated-source
    projection 5/5, and the unchanged primary command passes 63/63 in both default and POSIX environments.
    The neutral authority now declares one 15-role Rust consumer plus canonical/default-to-optional-Rust driver
    topology. Its one composed test passes all native default/AND, ordinary serialized, loaded, descriptor-v1,
    emitted-v2, generated direct/trace, mixed/recursive, two structural, static removal, primary, and eight-code
    portable diagnostic/removal roles exactly once. The independent checker accepts 3 complete / 5 pending with
    only `rust_parity` advanced, retains the exact 68-file inventory, and rejects 34 drift mutations.
    The complete Rust gate exits 0 with core 189/4/5/8, runtime 137, oracle 3/205.40s, diagnostics 7, exhaustive
    classifier 105/105 in 234.99s, integrations 197/75.60s, composed admission 1/23.79s, rule-local execution
    6/59.58s, source emitter 5/36.90s, every adjacent suite, and primary 63/63 in default and POSIX environments.
    Formatting and advisory Clippy for the new consumer are clean. Memory architecture, the Knowledge Map, all
    four doctrines, shell/JSON checks, mdBook, and whitespace pass. Canonical CI accepts the staged consumer,
    repeats Perl admission 288 and reference primary 63/63 in both environments, passes Phase 0 1,031/1,031 in
    612 seconds, and exits 0. Clean commit `288da21a` closes parent `.9.1.4` before Dart.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.4.7 - admit Rust rule-local cursor contract`

- ID: `FUTURE-PARITY-BACKLOG.9.1.5`
  Status: `done`
  Goal: Align Dart native/reconstructed/generated/primary behavior with ADR `0044`.
  Children: `.9.1.5.0` (preflight/split), `.9.1.5.1` (family/edge normalization), `.9.1.5.2`
    (live/loaded/reconstructed execution), `.9.1.5.3` (descriptor v1), `.9.1.5.4` (generated-source v2),
    `.9.1.5.5` (option/CLI migration), `.9.1.5.6` (composed admission/closeout)
  Dependencies: `.9.1.4`
  Acceptance: Replace engine-wide seek ownership with family-derived rule policy; normalize the full bare-edge
    surface; remove legacy public and command options with exact diagnostics; consume descriptor/generated v2;
    migrate fixtures/callers; and prove native, normalized emitted, reconstructed plan, trace, recursion, loaded-
    spec, and primary-command parity against the unchanged neutral contract.
  Verification: Children `.0-.5` complete the dependency-ordered preflight, typed normalization, rule-local
    execution, descriptor v1, generated-source v2, and public option/CLI removal. Composed admission `.6` adds one
    exact 15-role Dart consumer, locks the complete backend/canonical driver topology, advances only Dart to reach
    4 complete / 4 pending, and closes this parent without changing the already-signed-off mechanisms.
  Commit: closed by `FUTURE-PARITY-BACKLOG.9.1.5.6 - admit Dart rule-local cursor contract`

- ID: `FUTURE-PARITY-BACKLOG.9.1.5.0`
  Status: `done`
  Goal: Audit and split the Dart rule-local cursor rollout into gate-safe mechanism leaves before behavior code.
  Dependencies: `.9.1.4`
  Acceptance: Use the Knowledge Map and toolbox authorities first; map every governed Dart token and non-token
    parser/compiler/runtime/descriptor/normalized-state/emitter/loader/corpus/primary/test seam; measure current
    family, bare-edge, parent/child, option/CLI, descriptor/generated version, trace, and shared-fixture behavior;
    and replace the broad parent with dependency-ordered children without changing executable behavior.
  Acceptance Checklist:
  - [x] **RETRIEVE / TOOLBOX FIRST** — Read ADR `0044`, the neutral contract/checker, admitted Perl/Rust references,
    Dart architecture/CLI/generated/descriptor Knowledge Map authorities, `TOOLBOX.md`, and the complete Dart and
    canonical gate seams before source inspection or probing.
  - [x] **EXACT DART SURFACE MAP** — Account for all eleven governed Dart inventory paths plus non-token AST,
    parser, validation, compiled dispatch, normalized-state reconstruction, source emission, loader, corpus,
    primary, trace, generated-host, test, and documentation seams.
  - [x] **REPRODUCE CURRENT BOUNDARIES** — Prove all 36 authored family spellings, bare/explicit edge ownership,
    global parent/child propagation, public option/CLI and trace behavior, descriptor/generated versions, focused
    package state, both exact primary environments, and all 105 corpus fixtures without behavior changes.
  - [x] **SAFE IMPLEMENTATION SPLIT** — Add dependency-ordered children for typed family/edge normalization,
    live/loaded/reconstructed execution, descriptor v1, generated-source v2, option/CLI migration, and composed
    admission. No gate-hardening child is needed because `tools/run_dart_local.sh` already runs the complete
    package, exact primary projection twice, and full corpus.
  - [x] **NO REGRESSION / LOCKSTEP** — Change no Dart/shared executable behavior; synchronize task/index/roadmap/
    live/memory, Knowledge Map, mdBook, changes/notes, run neutral plus governance/book checks, and commit before
    activating normalization `.9.1.5.1`.
  Verification: Retrieval followed the durable neutral, Dart architecture, compiled-state, generated-source, native
    resolution, runtime matching/backtrack, and primary CLI cards to ADR `0044`, the neutral checker/contract, the
    admitted Perl/Rust implementations, current Dart source/tests, and both local/canonical drivers. The checker
    passes 36 family spellings, 18 edges, eight parent/child cases, 14 Perl roles, 15 Rust roles, 68 governed files,
    3 complete / 5 pending, and 34 rejected mutations. The exact Dart probe shows only compact `|` is misclassified
    as AND (`Pipe`, `isAnd=true`, generated `and_single_acode`); compact `&` and the other 34 spellings retain their
    expected family. Complete-line bare declared-rule edges remain raw and fail with generic `unrecognized body
    syntax`; explicit AND action and OR blind exceptions compile correctly. `LinkedSpecRuntimeEngine.parseMode`
    controls every entered rule, so seek/consume selected at the parent also propagates through mixed and recursive
    children. Root descriptor metadata still emits `parse_mode: seek` and no per-rule cursor policy/resolved semantic
    edges. Emitted artifacts remain `linkedspec-generated-source-v1` / format 1 with minimal label/family rows, no
    v2 mismatch diagnostic, and the same compact-pipe classifier drift.

    The authoritative Dart driver passes formatting and strict analysis, then reaches 244 package-test passes plus
    one expected shared-help failure because the reference-owned fixture already removed `--parse-mode`; it stops
    there by design. The focused non-primary parser/validator/compiler/runtime/loader/generated suite passes
    104/104, and independent full-corpus execution passes 105/105. The exact shared primary projection is 30/63
    in both default and POSIX environments: 22 help/usage cases retain the option or old validation (including the
    removed-flag case), and eleven trace cases retain `parse_mode=seek`; every other case passes byte-exactly. This
    is an inherited staged migration boundary, not a regression from `.0`. No executable source, fixture, shared
    contract, or generated artifact changes in this leaf. The derived Knowledge Map passes at 588 facts / 4,178
    question keys. Memory architecture, task metadata, all four doctrine checks, neutral mutation proof, mdBook,
    whitespace, temporary-probe cleanup, and the 40-line resume-pointer cap pass. The clean commit is the only
    remaining boundary before `.9.1.5.1` activation.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.5.0 - audit and split Dart cursor rollout`

- ID: `FUTURE-PARITY-BACKLOG.9.1.5.1`
  Status: `done`
  Goal: Normalize Dart rule families and bare edges into exact typed ownership before runtime policy changes.
  Dependencies: `.9.1.5.0`
  Acceptance: Correct compact/default/OR versus AND family classification; retain complete-line and header-rest
    bare plain/indexed/grouped/block/fluent candidates as typed AST; lower family-derived action/blind ownership;
    preserve explicit cross-family exceptions; reject mixed, undefined, invalid-index, and missing-shared-block
    forms with neutral portable diagnostics; and prove parser/compiler/validation locations without changing live
    cursor execution yet.
  Acceptance Checklist:
  - [x] **RETRIEVE / REPRODUCE** — Follow the preflight Knowledge card, ADR `0044`, neutral edge/family/diagnostic
    rows, and admitted Perl/Rust normalization references to the exact Dart AST/parser/validator/compiler/test
    seams; reproduce compact-pipe, raw bare-edge, explicit exception, and diagnostic baselines before editing.
  - [x] **NORMALIZE FAMILY / TYPED EDGES** — Classify all default/OR/compact-OR versus AND/compact-AND forms
    exactly and retain complete-line plus header-rest bare plain/indexed/grouped/block/fluent candidates as typed
    AST with family-derived action/blind ownership and explicit cross-family exceptions.
  - [x] **VALIDATE EXACTLY** — Resolve against the complete declared-rule set and reject mixed ownership,
    undefined targets, blind/bare invalid indices, AND bare groups, and grouped actions without shared blocks via
    stable neutral code/stage/field diagnostics rather than generic raw-syntax messages.
  - [x] **PROVE REPRESENTATION / FREEZE EXECUTION** — Add contract-driven parser/compiler/validation tests for all
    36 family spellings, 18 edge cases, and six ownership sets; prove typed compiled tables and normalized JSON
    source locations while locking live cursor execution at the staged pre-`.2` global-policy boundary.
  - [x] **LOCKSTEP / SIGNOFF** — Synchronize task/index/roadmap/live/memory, Knowledge Map, mdBook, changes/notes;
    pass focused Dart, prove the complete driver reaches only the exact staged shared-CLI boundary, and pass
    neutral/governance/canonical proof; commit before execution leaf `.9.1.5.2`.
  Verification: Activated only after clean preflight commit `b700c11a`. Retrieval followed the preflight and
    neutral Knowledge cards to ADR `0044`, all 36 family / 18 edge / six ownership-set rows, admitted Rust
    `BareEdge`/`PortableDiagnostic` normalization, and exact Dart AST/parser/validator/compiler/runtime/v1 seams.
    `RuleMode.isAnd` now excludes compact `|`; `BareEdgeBodyElementKind` plus nullable `BareEdgeTarget.index`
    retains complete-line/header-rest plain, block, fluent, grouped, forward, and indexed candidates through AST
    JSON. Explicit blind indices are retained instead of suffix-discarded. Validation resolves against the full
    declared-label set, derives bare ownership from parent family, and returns sorted `SpecPortableDiagnostic`
    code/stage/field payloads for all six neutral normalization/validation failures. The compiler lowers OR/default
    bare targets to action dispatch and AND bare targets to blind dispatch while retaining explicit exceptions.
    A named `usesLegacyAndInterpretation` adapter keeps compact-pipe runtime behavior staged for `.2`, and the
    explicit v1 classifier remains staged for `.4`; neither global cursor execution nor artifact version changes.

    The contract-driven five-test suite passes all 36 family rows, 18 edge rows, six ownership sets, AST/diagnostic
    JSON roundtrips, complete-line/header-rest/multiline boundaries, typed compiled tables, and staging assertions.
    Strict analysis passes; existing parser/validator/compiler tests pass 26/26; the focused eight-suite set passes
    109/109; corpus execution remains 105/105. The actual complete driver passes formatting/analysis and reaches
    249 package passes plus only the already-owned shared-help assertion. Exact primary remains 30/63 in default
    and POSIX environments with the same 22 help/usage plus eleven trace migration failures. The neutral checker
    retains 68 governed files and rejects all 34 mutations; the new proof deliberately remains token-free rather
    than expanding inventory with a redundant global-option spelling. The Knowledge Map passes at 589 facts /
    4,188 question keys; memory, task metadata, all four doctrines, mdBook, and whitespace pass. Canonical CI
    repeats the 288-test Perl cursor admission consumer and reference primary 63/63 in both environments, passes
    Phase 0 1,031/1,031 in 610 seconds, and exits 0.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.5.1 - normalize Dart rule edges`

- ID: `FUTURE-PARITY-BACKLOG.9.1.5.2`
  Status: `done`
  Goal: Make Dart live, loaded, normalized, and reconstructed execution spend each entered rule's derived policy.
  Dependencies: `.9.1.5.1`
  Acceptance: Derive seek/consume independently from every entered rule family across action, blind, direct,
    recursion, loaded compiled state, normalized JSON reconstruction, and trace; remove parent/global propagation
    from execution while preserving low-level matcher primitives and staged public/descriptor/generated surfaces;
    prove all eight parent/child mechanisms and both structural replacements.
  Acceptance Checklist:
  - [x] **RETRIEVE / REPRODUCE** — Follow the neutral contract, Dart preflight/normalization/runtime Knowledge
    cards, ADR `0044`, and toolbox paths to the exact live/global policy seams; reproduce all eight current
    parent/child propagation cases and both structural replacements before editing.
  - [x] **DERIVE POLICY PER ENTRY** — Remove caller/global policy authority from normal runtime matching and derive
    seek/consume from each entered compiled rule family across action, blind, direct call, recursion, and trace,
    while retaining only the low-level seek/consume matcher algorithms.
  - [x] **PRESERVE LOADED / RECONSTRUCTED IDENTITY** — Make in-memory, file-loaded, and normalized `SpecFile`-JSON
    reconstructed state spend identical family-derived policy without storing or accepting a second mutable
    cursor field.
  - [x] **PROVE ALL COMPOSITIONS** — Consume all eight neutral parent/child mechanisms plus ordered-landmark and
    anchored-choice structural replacements through contract-driven runtime tests, including recursive and trace
    evidence that the child owns its entered policy.
  - [x] **FREEZE LATER LEAVES / NO REGRESSION** — Leave descriptor root metadata for `.3`, generated v1 for `.4`,
    public options/CLI/shared fixtures for `.5`, and rollout admission for `.6`; keep the exact staged full-driver
    boundary, primary 30/63x2, corpus 105/105, and neutral 68-file/34-mutation state unless this leaf's owned
    runtime evidence requires a contract-governed inventory update.
  - [x] **LOCKSTEP / SIGNOFF** — Synchronize task/index/roadmap/live/memory, Knowledge Map, mdBook, changes/notes;
    pass focused and complete Dart proof plus neutral/governance/canonical signoff; commit before descriptor leaf
    `.9.1.5.3`.
  Verification: Activated task-tree-first only after clean normalization commit `fc31fc12`. Knowledge Map,
    ADR, neutral-contract, admitted Rust/Perl fixture, and exact Dart runtime/compiler/generated/load seams were
    retrieved before diagnosis. A disposable pre-edit engine probe consumes all eight parent/child cases and both
    structural replacements: global seek yields `hit`/`done`, ordered landmarks, and the wrongly unanchored
    choice, while global consume yields `null` for every case. This proves the prior engine option propagated
    across entered rules and structural composition. The probe was removed.

    Normal `_executeRule` now derives one immutable entry policy: exact AND consumes/sequences and OR/default
    seeks/chooses. Regex alternation/specific-slot matching and trace receive that policy explicitly; action,
    blind, direct-call, and recursive child entry derives again. The compiled legacy predicate is removed.
    Live, loaded, and normalized `SpecFile`-JSON routes agree over all 36 family rows, all eight parent/child
    mechanisms, and both structural replacements. Generated v1 alone retains its engine-global/compact-pipe
    compatibility adapter for `.4`; descriptor and public surfaces remain unchanged for `.3`/`.5`.

    Strict analysis passes. The affected five-suite set passes 82/82 and the broader eleven-suite set passes
    142/142; corpus remains 105/105. The complete package reaches 253 passes plus only the staged shared-help
    failure, and primary remains exact 30/63 in default and POSIX environments. The neutral checker retains
    68 governed files, rollout 3/5, and all 34 mutations. The Knowledge Map passes at 590 facts / 4,197 question
    keys; memory architecture, task metadata, all four doctrines, mdBook, and whitespace pass. Canonical CI
    repeats the 288-test Perl cursor admission consumer and reference primary 63/63 in both environments, passes
    Phase 0 1,031/1,031 in 629 seconds, and exits 0.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.5.2 - derive Dart rule-local cursor execution`

- ID: `FUTURE-PARITY-BACKLOG.9.1.5.3`
  Status: `done`
  Goal: Project Dart cursor descriptor v1 from normalized compiled rule state.
  Dependencies: `.9.1.5.2`
  Acceptance: Remove root global-mode metadata; identify the neutral descriptor contract; project each rule's
    authored family, derived cursor policy, ordered resolved semantic edges, and exact source identity; validate
    reconstructed descriptor state and portable failures; and preserve native/loaded execution identity.
  Acceptance Checklist:
  - [x] **RETRIEVE / REPRODUCE** — Follow the Knowledge Map to ADR `0044`, the neutral descriptor contract, admitted
    Perl/Rust descriptor projections, and Dart descriptor/load/reconstruction seams; reproduce the exact current
    root-global/per-rule descriptor drift before editing.
  - [x] **PROJECT NORMALIZED FACTS** — Remove descriptor root global-mode metadata and project contract identity,
    authored family, derived cursor policy, ordered resolved action/blind edges, block/fluent ownership, and exact
    source identity from normalized compiled state without adding mutable cursor storage.
  - [x] **VALIDATE RECONSTRUCTION / FAILURES** — Prove direct and reconstructed descriptors are identical, malformed
    reconstructed state fails through the portable contract, and native/loaded execution remains unchanged.
  - [x] **FREEZE LATER LEAVES / NO REGRESSION** — Leave generated-source v1 for `.4`, public/global options and
    shared primary migration for `.5`, and composed rollout admission for `.6`; preserve the exact staged Dart,
    corpus, primary, neutral-inventory, and mutation boundaries.
  - [x] **LOCKSTEP / SIGNOFF** — Synchronize task/index/roadmap/live/memory, Knowledge Map, mdBook, changes/notes;
    pass focused/complete Dart plus neutral/governance/canonical proof; commit before generated-source `.9.1.5.4`.
  Verification: Activated task-tree-first only after clean execution commit `7dea1f6b`. Knowledge Map retrieval
    followed ADR `0044`, the neutral cursor and outward descriptor contracts, the admitted Perl/Rust descriptor
    projections, and Dart's compiled/load/normalized-state seams. A disposable pre-edit Dart probe reproduced the
    exact drift: root metadata hard-coded global `seek`, while `Top::AND` exposed label/line/top/mode only and no
    family, derived policy, ownership, or resolved rows. The probe was removed before implementation.

    Root metadata now identifies `linkedspec-rule-local-cursor-v1` and has no global cursor field. Every rule
    derives family/policy from exact compiled mode metadata, aggregate ownership from normalized action/blind
    tables, and ordered semantic rows with exactly ownership/target/regex-index/block/fluent. Action rows use the
    resolved child slot and blind rows use null. Handler label plus rule label/line/top/mode preserve exact source
    identity; optional bare/explicit provenance is omitted because compiled state does not retain it and the
    neutral contract marks it non-semantic. Dart remains descriptor-output-only: normalized `SpecFile` JSON is the
    legitimate reconstruction boundary, so no descriptor decoder or mutable cursor state is introduced.

    The new four-test consumer passes all 36 family rows, every valid edge row, exact outward/root/semantic fields,
    direct/normalized-JSON identity, file-loaded identity, unchanged loaded AND execution, and every reconstructed
    portable invalid-edge failure. Adjacent descriptor/normalization/execution suites pass 18/18 and strict
    analysis passes. The complete package reaches 257 passes plus only the staged shared-help failure; corpus is
    105/105 and primary remains exact 30/63 in default and POSIX environments. The compiler becomes token-free
    while the new forbidden-field test becomes governed, so the neutral inventory swaps one path and remains 68
    files at rollout 3/5 with all 34 mutations. The Knowledge Map passes at 591 facts / 4,207 question keys;
    memory architecture, task metadata, all four doctrines, mdBook, and whitespace pass. Canonical CI repeats the
    288-test Perl cursor admission consumer and reference primary 63/63 in both environments, passes Phase 0
    1,031/1,031 in 624 seconds, and exits 0.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.5.3 - project Dart cursor descriptor v1`

- ID: `FUTURE-PARITY-BACKLOG.9.1.5.4`
  Status: `done`
  Goal: Emit and reconstruct Dart generated-source v2 from the minimal family plan.
  Dependencies: `.9.1.5.3`
  Acceptance: Identify v2/format 2, retain only ordered label/family rows, derive policy from all ten families with
    no serialized cursor field, reject v1 reconstruction with exact expected/actual contract and regeneration
    guidance, and prove deterministic emission, fresh host compile/load, direct/traced execution, all families,
    source identity, corpus subset, and exhaustive classifier breadth.
  Acceptance Checklist:
  - [x] **RETRIEVE / REPRODUCE** — Follow the Knowledge Map to ADR `0044`, neutral generated-source v2, admitted
    Perl/Rust implementations, and exact Dart emitter/loader/runtime seams; reproduce v1 format and execution drift
    before implementation edits.
  - [x] **EMIT MINIMAL V2 PLAN** — Identify contract v2/format 2, serialize only ordered label/family rows, derive
    policy and structure from all ten generated families, and remove serialized/global cursor ownership.
  - [x] **RECONSTRUCT / REJECT EXACTLY** — Reconstruct v2 through a fresh host process, reject v1 with exact
    expected/actual portable contract plus regeneration guidance, and preserve exact source identity.
  - [x] **COMPOSE EXECUTION PROOF** — Prove deterministic bytes, direct/traced execution, every family, nested
    composition, exhaustive classifier breadth, and a representative corpus subset across emitted/fresh-loaded
    code.
  - [x] **FREEZE LATER LEAVES / SIGNOFF** — Leave public/global option and shared primary migration for `.5` and
    composed admission for `.6`; synchronize task/index/roadmap/live/memory, Knowledge Map, mdBook, changes/notes,
    and pass focused/complete Dart plus neutral/governance/canonical signoff before commit.
  Verification: Activated task-tree-first only after clean descriptor commit `39338616`. Knowledge Map retrieval
    followed ADR `0044`, the shared v1 semantic ledger, the admitted Perl/Rust v2 designs, and exact Dart emitter,
    generated-plan, normalized-state, runtime, host-isolation, diagnostic, and recurring-checker seams. After the
    toolbox check found no Dart-specific generated-source dump, a disposable Dart probe reproduced the exact
    pre-edit boundary: `linkedspec-generated-source-v1` / format 1, `Top=and_single_acode`, no v2 identity, and
    generated-v1 AND returning `hit` for `prefix x` where normal rule-local execution returned null. The probe was
    removed before implementation.

    Dart now emits `linkedspec-generated-source-v2` / format 2. The deterministic plan remains exactly ordered
    `label`/`family` rows with no cursor field. `GeneratedRuleFamily.cursorPolicy` derives seek for default, OR,
    and repetition families and consume for all five AND families; structural acode/bcode and choice/sequence
    execution derive from the same validated family at each entered rule. Compact `Pipe` classifies as `or_acode`.
    Public versioned entrypoints advance to v2 while the unversioned emitter remains the current adapter. Emitted
    modules validate the contract before touching their lazy Base64 normalized-state payload. An isolated host with
    a deliberately corrupt payload proves v1 fails first at `validate_generated_plan` with exact expected/actual
    contracts and `.spec` regeneration guidance, while current v2 proceeds to the separate compile/load failure.

    All ten families, all 36 authored classifier spellings, eight parent/child mechanisms, two structural
    replacements, direct/traced values, source identity, deterministic bytes, accepted 8/105 subset, and adjacent
    diagnostic/logical/named-mark/variadic/punctuation/uniform-binding generated roles use v2. Strict analysis
    passes; the affected nine-suite proof is 76/76; complete package proof reaches 257 passes plus only the staged
    shared-help failure; corpus is 105/105; primary remains the exact expected 30/63 in default and POSIX pending
    `.5`. The generated-source v1 semantic ledger passes with Dart's current v2 role, neutral cursor stays 68
    governed files / 3-of-5 / 34 mutations, and the logical recurring checker passes 8/0 plus 26 mutations. The
    Knowledge Map passes at 592 facts / 4,215 question keys; memory architecture, task metadata, all four doctrines,
    mdBook, formatting, strict analysis, and whitespace pass. Canonical CI repeats Perl cursor admission 288,
    reference primary 63/63 in both environments, passes Phase 0 1,031/1,031 in 641 seconds, and exits 0. Public/
    CLI global option migration and composed admission remain untouched for `.5-.6`.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.5.4 - emit Dart generated-source v2`

- ID: `FUTURE-PARITY-BACKLOG.9.1.5.5`
  Status: `done`
  Goal: Remove Dart global cursor overrides and migrate the shared primary-command projection.
  Dependencies: `.9.1.5.4`
  Acceptance: Remove engine-constructor, loader, corpus, parser-adapter, and every other caller-owned global
    override option; preserve only contract-permitted low-level matcher primitives; remove the primary
    `--parse-mode` flag/help/request-trace field; return the exact targeted retired-option usage failure; migrate
    every non-removal caller/test; and pass the exact shared 63 cases in default and POSIX environments with
    unchanged unrelated output and trace bytes.
  Acceptance Checklist:
  - [x] **RETRIEVE / AUDIT** — Follow the Knowledge Map to ADR `0044`, Dart preflight/runtime/descriptor/generated/
    primary facts, and the admitted Rust removal design; classify every Dart token as caller-owned, rule-derived,
    historical/diagnostic, or permitted low-level matcher state before editing behavior.
  - [x] **REMOVE PUBLIC/GLOBAL OVERRIDES** — Delete engine-constructor, loaded-engine, corpus, staged-parser, and
    internal runtime-context global policy parameters without deleting the low-level seek/consume matcher.
  - [x] **MIGRATE PRIMARY COMMAND** — Remove the help/execution/request-trace field, retain top-rule selection,
    and reject exact `--parse-mode` spellings at usage exit 2 with the neutral migration message.
  - [x] **PROVE STATIC AND EXECUTABLE BOUNDARIES** — Add focused source-removal and retired-flag proof; pass the
    affected suite, complete package, exact shared primary 63x2, corpus 105/105, and the updated neutral inventory
    with every mutation effective.
  - [x] **CAPTURE ROOT-SELECTION DECISION WITHOUT DIVERGENCE** — Record the director's exact explicit-selector >
    authored-`::` > first-ordinary-`:` precedence under dedicated subtree `.9.1.1.2`; preserve current behavior in
    this Dart-only cursor slice because four backend validators and current doctrine still require `::`.
  - [x] **LOCKSTEP / SIGNOFF** — Synchronize task/index/roadmap/live/memory, Knowledge Map, public Dart docs,
    mdBook, changes/notes, and pass governance plus canonical local CI before commit; leave composed admission
    exclusively to `.9.1.5.6`.
  Verification: Activated task-tree-first only after generated-source v2 commit `79c51a21`, a zero-byte brief,
    clean tracked/untracked boundary, and safe generated-artifact cleanup. Knowledge Map retrieval precedes option,
    loader, corpus, parser-adapter, primary CLI, trace, test, and recurring-gate inspection. The exact audit found
    one caller-owned field in `LinkedSpecRuntimeEngine` and `_RuntimeExecutionContext`, optional overrides in
    `LoadedCompiledSpec.createEngine(...)` and `executeCorpusFixtures(...)`, one staged-parser fixed override, and
    primary help/options/execution/request-trace ownership. `LinkedSpecParseMode` plus matcher arguments and
    rule-local/generated policy derivation are contract-permitted low-level/internal uses.

    The caller-owned seams are removed. Primary `--parse-mode` returns exact targeted guidance before ordinary
    value parsing; help and medium request trace omit the field; `--top-rule` remains. A focused source-boundary
    test proves engine/loader/corpus/parser removal and explicitly retains both matcher algorithms. Strict analysis
    passes and eight affected suites pass 120/120. The authoritative Dart driver passes format, strict analysis,
    all 260 package tests, exact primary 63/63 in default and POSIX environments, and corpus 105/105. Generated-
    source and logical recurring checkers remain green. Neutral inventory removes four token-free option-owner
    paths, adds the source-removal test plus public Dart guidance, contracts 68 -> 66 files, remains 3/5 pending
    composed Dart admission, and rejects all 34 mutations. During signoff, the director resolved the separately
    parked first-rule-as-top design:
    explicit `--top-rule` wins over an authored `Rule::`; absent an explicit selector, the first authored `::`
    wins; absent any `::`, the first ordinary `:` wins. Retrieval exposed a cross-backend implementation gap:
    Dart's runtime/source wrapper already contains the latter fallback, but Dart/Rust/Julia/Lua validators reject
    no-marker specs and current doctrine still requires the marker. Subtree `.9.1.1.2` owns neutral ratification,
    all five backends, and public no-drift; this leaf deliberately makes no one-backend semantic change.

    Knowledge Map passes at 594 facts / 4,235 question keys. Memory architecture, task metadata, all four doctrines,
    formatting, strict analysis, mdBook, generated-source, logical-helper, neutral mutation, JSON, and whitespace
    checks pass. Canonical local CI accepts the 66-file contract, repeats composed Perl admission at 288 tests,
    passes reference primary 63/63 in both environments, completes Phase 0 at 1,031/1,031 in 627 seconds, and exits
    0. The clean commit is the sole remaining boundary before root-selection decision leaf `.9.1.1.2.0` may
    activate; Dart composed admission `.9.1.5.6` remains intact behind that director-prioritized pivot.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.5.5 - remove Dart global cursor overrides`

- ID: `FUTURE-PARITY-BACKLOG.9.1.5.6`
  Status: `done`
  Goal: Admit and close the complete Dart projection of the neutral rule-local cursor contract.
  Dependencies: `.9.1.5.5`
  Acceptance: Add one omission-sensitive contract-driven Dart consumer spanning native, loaded, normalized,
    descriptor, emitted/generated, trace, diagnostics, recursion/mixed parents, structural replacement, and
    primary roles; register it canonically; advance only `dart_backend`; pass complete Dart/65x2/canonical proof;
    synchronize public/live/KM docs; close `.9.1.5`; and hand off Julia only after a clean commit.
  Acceptance Checklist:
  - [x] **RETRIEVE / REPRODUCE** — Follow the Knowledge Map to ADR `0044`, the neutral contract/checker, Perl and
    Rust composed-admission precedents, and every committed Dart normalization/execution/descriptor/generated/
    option/primary fact; reproduce the exact constituent and 3/5 rollout boundary before executable edits.
  - [x] **DEFINE DART COMPOSED TOPOLOGY** — Extend the neutral authority with one exact omission-sensitive Dart
    admission surface spanning native, loaded, normalized, descriptor, emitted/generated direct/trace,
    diagnostics, mixed/recursive parents, structural replacement, static removal, and primary roles without
    cloning the constituent semantic suites.
  - [x] **IMPLEMENT ONE CONSUMER** — Add one contract-driven Dart consumer that executes every required role and
    portable diagnostic/removal outcome exactly once from unchanged neutral fixtures, preserving exact source,
    descriptor, trace, result, and generated-v2 identity.
  - [x] **REGISTER / ADVANCE ONLY DART** — Register the consumer in the complete Dart and canonical gates, advance
    only `dart_backend` from pending to complete, preserve Julia/Lua/final legs, and make missing registration or
    any omitted/duplicated role fail the neutral checker and mutation suite.
  - [x] **LOCKSTEP / CLOSEOUT** — Pass constituent, composed, complete Dart, 65x2, corpus, neutral mutation,
    governance, mdBook, and canonical gates; synchronize task/index/roadmap/live/memory/KM docs; close `.9.1.5`;
    commit cleanly before activating Julia `.9.1.6`.
  Verification: Activation followed clean root-route commit `42c98dfe`, zero-byte brief,
    and clean tree at ahead 221. Dart mechanism/removal leaf `.9.1.5.5` is durably committed at `82999046`; its
    director-prioritized root-selection pivot has now returned after Julia root routes satisfied `.9.1.6`'s other
    dependency. Exact task dependencies prove this Dart admission must close parent `.9.1.5` before Julia cursor
    `.9.1.6` may activate. Retrieval reproduced the pre-edit 36 family / 18 edge / 8 parent-child / 14 Perl /
    15 Rust / 66-file / 3-complete / 5-pending / 34-mutation boundary. The neutral authority now declares 15
    exact Dart roles and locks the consumer, complete Dart test command, canonical tracked input, and optional
    backend registration. Five new mutations cover every new topology/rollout seam.

    `dart/test/rule_local_cursor_contract_test.dart` maps every declared role once and runs native default/AND,
    normalized JSON, loaded spec, descriptor v1, emitted/generated v2 direct/trace, mixed parent-child, recursion,
    both structural replacements, static option removal, primary retirement, and all eight portable diagnostic
    codes. Focused analyze and admission pass. The complete registered Dart driver passes format over 61 files,
    strict analysis, all 271 package tests, exact shared primary 65/65 in default and POSIX environments, and
    corpus 105/105. Neutral governance now reports 67 owned migration files, 4 complete / 4 pending, and all 39
    mutations rejected. Only Dart advances; Julia, Lua, recurring, and public no-drift remain pending. Knowledge
    Map passes at 613 facts / 4,432 question keys; memory/task/all four doctrines, JSON, shell, whitespace, and
    mdBook pass. Canonical local CI repeats Perl root consumers 7+5, Perl cursor admission 288, reference primary
    65/65 in both environments, and Phase 0 1,031/1,031 in 613 seconds before exit 0. Cleanup removes the ignored
    11 MB generated mdBook plus 28 KB Python bytecode cache. The clean commit remains the closeout boundary.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.5.6 - admit Dart rule-local cursor contract`

- ID: `FUTURE-PARITY-BACKLOG.9.1.6`
  Status: `done`
  Goal: Align Julia native/reconstructed/generated/primary behavior with ADR `0044`.
  Children: `.9.1.6.0` (preflight/split), `.9.1.6.1` (family/edge normalization), `.9.1.6.2`
    (live/loaded/reconstructed execution), `.9.1.6.3` (descriptor v1), `.9.1.6.4` (generated-source v2),
    `.9.1.6.5` (option/CLI migration), `.9.1.6.6` (composed admission/closeout)
  Dependencies: `.9.1.5`, `.9.1.1.2.4.2`
  Acceptance: Replace engine-wide seek ownership with family-derived rule policy; normalize the full bare-edge
    surface; remove legacy public and command options with exact diagnostics; consume descriptor/generated v2;
    migrate fixtures/callers; and prove native, emitted-state, reconstructed plan, trace, recursion, loaded-spec,
    and primary-command parity against the unchanged neutral contract.
  Verification: Activated task-tree-first only after Dart cursor parent `.9.1.5` closed at clean commit
    `7aa9c578`, Julia root routes `.9.1.1.2.4.2` were already committed at `42c98dfe`, the brief was zero bytes,
    and tracked/untracked state was clean at ahead 222. Child `.0` owns read-only retrieval, exact current-boundary
    reproduction, and the dependency-safe implementation split before any Julia cursor behavior edit. Child `.1`
    is committed at `ac7010ee` with exact family/bare-edge/diagnostic/compiled normalization. Runtime leaf `.2`
    is committed at `290cb731`; descriptor `.3`, generated v2 `.4`, public removal `.5`, and composed admission
    `.6` are complete. The parent closes with one exact 15-role Julia consumer, package 3,291, primary 65x2,
    corpus 105, and neutral governance 67/5+3/44. Root admission `.9.1.1.2.4.3` follows only after the clean `.6`
    commit.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.6.6 - admit Julia rule-local cursor contract`

- ID: `FUTURE-PARITY-BACKLOG.9.1.6.0`
  Status: `done`
  Goal: Map the exact Julia rule-local cursor boundary and freeze a gate-safe implementation split.
  Dependencies: `.9.1.5`, `.9.1.1.2.4.2`
  Acceptance: Use the Knowledge Map and LinkedSpec toolbox first; retrieve ADR `0044`, neutral/Perl/Rust/Dart
    admission authorities, current Julia parser/compiler/runtime/loader/normalized/emitter/descriptor/primary/
    trace/corpus seams, and local/canonical gates; reproduce family, edge, parent-child, option, descriptor,
    generated, focused/package, 65x2 primary, corpus, and neutral governance boundaries without behavior changes;
    then freeze dependency-ordered implementation leaves that keep main green.
  Acceptance Checklist:
  - [x] **RETRIEVE / TOOLBOX FIRST** — Follow Knowledge Map authorities to ADR `0044`, the neutral contract/checker,
    admitted backend precedents, Julia architecture/current root-route facts, `TOOLBOX.md`, and complete drivers
    before inspecting or probing implementation seams.
  - [x] **EXACT JULIA SURFACE MAP** — Account for every governed Julia inventory path plus non-token AST, parser,
    validation, compiled state, runtime dispatch, normalized reconstruction, source emission, loader, corpus,
    primary, trace, descriptor, test, and public-document seam.
  - [x] **REPRODUCE CURRENT BOUNDARIES** — Prove all 36 family spellings, bare/explicit ownership, parent-child
    propagation, public option/CLI/request trace, descriptor/generated versions, focused/package state, exact
    shared 65-case default/POSIX boundary, all 105 corpus fixtures, and neutral governance without behavior edits.
  - [x] **FREEZE SAFE IMPLEMENTATION SPLIT** — Confirm or refine `.1-.6` ownership for typed normalization,
    live/loaded/reconstructed execution, descriptor v1, generated-source v2, option/CLI migration, and composed
    admission; explicitly order any shared-fixture changes so canonical main stays green.
  - [x] **NO REGRESSION / LOCKSTEP** — Change no Julia/shared executable behavior; synchronize task/index/roadmap/
    live/memory, Knowledge Map, mdBook, changes/notes, run neutral plus governance/book/canonical checks, clean
    safe generated artifacts, and commit before activating `.9.1.6.1`.
  Verification: **PASS 2026-07-18.** Clean Dart admission `7aa9c578`, committed Julia root routes
    `42c98dfe`, zero-byte brief, clean tracked/untracked state, and ahead 222 prove both dependencies and the pivot
    boundary. Knowledge Map/ADR/toolbox/driver retrieval preceded source inspection. All 36 headers parse, but
    family classification is only 34/36 because `RuleMode("Pipe")` incorrectly makes compact `|` AND; all 36
    engines store global seek, agreeing intrinsically only with 22 seek families. The 18 edge rows parse as three
    action, three blind, one lifecycle, and eleven raw; only five of thirteen expected-success rows compile, none
    of seven edge/edge-set diagnostic cases has its portable code, and `=> Child[0]` is silently accepted. Exact
    admitted parent/child sources agree 5/8, with OR-to-AND blind/action/call false positives; structural agreement
    is 1/2 because anchored choice also false-positively seeks. Descriptor metadata retains `parse_mode=seek` and
    lacks cursor v1/per-rule policy. Normalized and loaded engines default seek; high-level engine/loader overrides
    remain accepted. Generated source is v1/format 1 and generated AND accepts leading junk. Package execution
    reaches the one frozen 56/57 help mismatch. Shared primary is exactly 32/65 under default and POSIX: 22 help/
    usage plus 11 request-trace failures. Standalone corpus is 105/105; neutral governance is 67 files, 4 complete
    / 4 pending, and 39 mutations. The refined split isolates v1 generated semantics during `.2`, bumps/rejects in
    `.4`, and changes only Julia consumers—not the already-current shared CLI manifest—during `.5`. No Julia or
    shared executable, contract, capability, fixture, rollout, or public semantic behavior changes in `.0`.
    Focused cursor/root governance, Knowledge Map 614/4,445, memory architecture, all four doctrines, JSON,
    whitespace, and mdBook pass. Canonical CI repeats Perl root 7+5, cursor admission 288, primary 65/65 in both
    option environments, and Phase 0 1,031/1,031 in 613 seconds. Cleanup removes the ignored 11 MB generated book
    and 28 KB Python bytecode cache while retaining the reusable 138 MB Julia depot for immediate `.1` work.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.6.0 - map Julia cursor rollout`

- ID: `FUTURE-PARITY-BACKLOG.9.1.6.1`
  Status: `done`
  Goal: Normalize Julia authored families and mode-sensitive bare-edge ownership with portable diagnostics.
  Dependencies: `.9.1.6.0`
  Acceptance: In `Ast.jl`, `Parser.jl`, `Validator.jl`, and compiled-state projection, consume all 36 neutral
    family rows (including correcting compact `|` from AND to OR/default), all 18 edge rows, and all six ownership
    sets. Normalize complete bare line members only after declared labels are known; preserve lifecycle precedence,
    forward targets, blocks/fluents, explicit overrides, and non-semantic source provenance; reject undefined/
    index/group/mixed/blind-index/group-block cases with exact portable stage/code/fields. Add one contract-driven
    focused normalization suite and preserve a deliberately bounded runtime/artifact compatibility seam for `.2-.4`.
  Verification: **PASS 2026-07-18.** Activated task-tree-first only after behavior-free preflight `.9.1.6.0`
    landed at clean commit `ee8efbfc`, `git_message_brief.txt` was zero bytes, generated book/cache artifacts were
    absent, and the tree was clean at ahead 223. `Pipe` is no longer AND; all 36 family rows expose exact immutable
    family/policy through parsed and compiled state. Complete-line/header-rest bare plain/index/group/block/fluent
    members retain typed source provenance and nullable authored indices; lifecycle precedence and forward labels
    remain exact. Whole-spec validation emits all six governed edge diagnostic code/stage/field sets, and valid
    bare ownership lowers into existing compiled blind/action tables. One neutral JSON-driven suite passes 353/353
    over 36 families, 18 edge rows, six ownership sets, physical-line bounds, compiled lowering, and AST/diagnostic
    roundtrips. A nested complete package sweep passes 2,215 assertions with only the exact pre-existing one help
    mismatch; ordinary package execution remains 56/57 at that boundary. Shared Julia primary remains exactly
    32/65 in default and POSIX, corpus remains 105/105, neutral governance remains 67 files / 4 complete + 4 pending
    / 39 mutations, root governance remains 4/7 plus 34 mutations, and rollout does not advance. Knowledge Map is
    615 facts / 4,455 question keys. Memory/four doctrines/JSON/whitespace/mdBook pass. Canonical CI repeats Perl
    root 7+5, cursor admission 288, primary 65/65 twice, and Phase 0 1,031/1,031 in 614 seconds. Cleanup removes the
    generated 11 MB mdBook and Python bytecode while retaining the 142 MB reusable Julia depot for `.2`.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.6.1 - normalize Julia cursor families and edges`

- ID: `FUTURE-PARITY-BACKLOG.9.1.6.2`
  Status: `done`
  Goal: Derive Julia normal live, loaded, normalized, recursive, and traced execution from every entered rule.
  Dependencies: `.9.1.6.1`
  Acceptance: In normal native, loaded-default, and normalized execution, derive cursor plus sequence/choice once
    from each entered compiled rule; remove parent propagation across blind/action/call/recursion; attribute rule
    family/policy in trace; and pass all eight parent-child plus two structural rows. Preserve low-level matcher
    primitives. Keep only explicit, test-locked transitional overrides for outer CLI/corpus callers and generated
    v1 so their old bytes/semantics cannot silently drift before `.4-.5`; default public routes must already be
    intrinsic. Add a focused live/loaded/normalized/recursive/trace suite and keep root-route proof green.
  Verification: **PASS 2026-07-18.** Activated task-tree-first only after normalization `.9.1.6.1` landed at clean
    commit `ac7010ee`, with zero brief and no generated artifacts. `_execute_runtime_rule!` now derives one family/
    cursor/sequence-choice policy for every normal entry; blind/action/direct-call/recursive children rederive.
    No-option live, loaded-default, normalized JSON, and traced routes are intrinsic, while explicit outer callers
    and generated v1 retain separate compatibility seams. The unchanged neutral contract drives 104/104 focused
    assertions over all 36 family rows, all eight parent-child rows, both structural replacements, loaded/recursive/
    trace behavior, and v1 isolation. Generated proof is 60/60, complete package is 2,320 pass plus only the frozen
    help mismatch, corpus is 105/105, and shared primary remains exactly 32/65 twice with the identical 33 later-
    owned failures. Cursor governance remains 67 files / 4 complete + 4 pending / 39 mutations; root remains 4/7
    plus 34. Knowledge Map is 616/4,466; mdBook, memory, doctrines, and whitespace pass. Canonical CI passes Perl
    root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 611 seconds. Descriptor v1, generated v2, option
    retirement, shared fixtures, admission, and rollout remain untouched for `.3-.6`.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.6.2 - execute Julia rule-local cursors`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Contract-driven `runtime_parse(...)` probes recorded by
    `julia-rule-local-cursor-preflight` reproduced 5/8 mixed parent-child and 1/2 structural agreement under
    engine-global seek; `rg -n "engine\\.parse_mode" julia/src/runtime/Interpreter.jl` located both spending sites.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Tool-backed source location `julia/src/runtime/Interpreter.jl:981` and
    `:1035` at the pre-fix boundary showed ordinary and indexed matching reading one engine field; every child
    re-entered the same engine, so parent/global policy propagated. Generated-source v1 shared that interpreter
    without a versioned compatibility owner.
  - [x] **FIX** — Derive `_RuntimeRuleExecutionPolicy` once at each rule entry, pass it explicitly to regex/blind
    execution, make no-option live/loaded routes intrinsic, and isolate generated v1 behind its private legacy
    engine/family interpretation without changing low-level matchers or later descriptor/public owners.
  - [x] **ADDRESSED (verified)** — Focused Julia execution is PASS 104/104 across 36 families, 8/8 parent-child,
    2/2 structural, loaded, normalized, recursive, and trace roles; generated source is PASS 60/60 and corpus is
    PASS 105/105. The shared primary failure set remains exactly the intended 33 cases in both environments.
  - [x] **NO REGRESSION** — Complete Julia package is 2,320 PASS plus only the exact frozen help mismatch;
    `bash tools/run_ci_local.sh` exits 0 with reference root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031;
    `git diff --check` is clean.
  - [x] **LOCKSTEP** — `CHANGES.md`, `DEVELOPMENT_NOTES.md`, both roadmaps, architecture/live/memory/task docs,
    mdBook, and fact card `julia-rule-local-cursor-execution` are synchronized; `mdbook build`,
    `knowledge-map/scripts/check_knowledge_map.sh`, and `scripts/check_doctrines.sh` pass.

- ID: `FUTURE-PARITY-BACKLOG.9.1.6.3`
  Status: `done`
  Goal: Project Julia cursor descriptor v1 from normalized compiled state.
  Dependencies: `.9.1.6.2`
  Acceptance: Replace descriptor-wide `meta.parse_mode` with exact cursor-v1 identity and per-rule derived
    family/policy/ownership/ordered resolved-edge facts; expose no independent cursor override; preserve authored
    root-selection identity and direct/loaded/normalized byte agreement; add a contract-driven descriptor suite.
  Verification: **PASS 2026-07-18.** Activation was task-tree-first only after runtime `.9.1.6.2` landed at clean
    commit `290cb731`, the brief was zero bytes,
    generated book/cache artifacts were absent, and `main` was ahead 225. Knowledge Map retrieval covered ADR
    `0044`, both neutral JSON contracts, Julia descriptor/root/normalization/runtime facts, and Perl/Rust/Dart
    descriptor precedents before source inspection. The pre-edit projection reproduced root `meta.parse_mode=seek`,
    no cursor contract, and no per-rule family/policy/ownership/resolved-edge facts at
    `julia/src/compiler/CompiledSpec.jl:652-730`.

    Root metadata now publishes `linkedspec-rule-local-cursor-v1` with no global mode. Each rule derives family and
    policy from `CompiledRuleModeMetadata`, computes ownership from normalized action/blind tables, and projects
    exact ordered ownership/target/child-index/block/fluent rows. No compiled/runtime field or decoder is added;
    source form is omitted as non-semantic. The new neutral suite passes 809/809 over all 36 families, every valid
    edge, every portable invalid edge/set case, exact root/rule/row fields, direct/normalized/loaded descriptor byte
    identity, and loaded live execution. Complete Julia passes 3,129 plus only the exact frozen help mismatch;
    corpus is 105/105 and shared primary is exactly 32/65 under default and POSIX with the identical later-owned
    22 help/usage plus 11 request-trace failures. Cursor governance remains 67 files / 4 complete + 4 pending / 39
    mutations by replacing the now-token-free compiler path with the descriptor no-drift test; root remains 4/7
    plus 34 mutations. Callable/root contracts, JSON, and whitespace pass. Generated v1, options, shared semantic
    fixtures, capabilities, admission, and rollout remain untouched for `.4-.6`. Knowledge Map passes at 617 facts
    / 4,476 question keys; memory architecture, all four doctrines, mdBook, JSON, whitespace, and cleanup pass.
    Canonical local CI repeats Perl root 7+5, cursor admission 288, reference primary 65/65 in both environments,
    and Phase 0 1,031/1,031 in 622 seconds before exit 0. Cleanup removes the ignored 11 MB generated mdBook and
    28 KB Python cache while retaining the 142 MB reusable Julia depot for immediate `.4` work. The clean commit
    remains the only boundary before generated-source v2 `.4` may activate.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.6.3 - project Julia cursor descriptor v1`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Contract/predecessor-driven descriptor probes and
    `rg -n "to_descriptor_json|parse_mode|cursor_contract|resolved_edges" julia/src/compiler/CompiledSpec.jl`
    reproduced root `meta.parse_mode=seek`, missing cursor-v1 identity, and missing per-rule normalized cursor/edge
    facts before the fix.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Tool-backed source locations
    `julia/src/compiler/CompiledSpec.jl:652-730` showed one outward projection hard-coding descriptor-global seek
    even though `.1` already stored exact family and normalized action/blind tables; the descriptor was stale
    projection logic, not missing compiler/runtime state.
  - [x] **FIX** — Replace the root field with the cursor-v1 contract id and project per-rule family, derived policy,
    aggregate ownership, and exact semantic action/blind rows without adding mutable state, a decoder, or optional
    source provenance.
  - [x] **ADDRESSED (verified)** — The neutral JSON-driven Julia descriptor suite is PASS 809/809 across 36
    families, every valid edge, every portable invalid edge/set case, exact field sets, byte-identical direct/
    normalized/loaded routes, and loaded AND execution.
  - [x] **NO REGRESSION** — Complete Julia is 3,129 PASS plus only the exact frozen help mismatch; corpus is
    105/105; shared primary remains exactly 32/65 twice; cursor governance is 67/4+4/39, root governance is
    4/7+34, and callable/root/JSON/whitespace checks pass.
  - [x] **LOCKSTEP** — The migration inventory swaps the now-token-free compiler path for the descriptor no-drift
    test; Changes/Notes, roadmaps, architecture/live/memory/task docs, mdBook, and Julia/cross-backend descriptor
    Knowledge Map facts describe cursor v1 while generated/public/admission remain `.4-.6`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.6.4`
  Status: `done`
  Goal: Advance Julia generated source to v2 with family-derived cursor and structural execution.
  Dependencies: `.9.1.6.3`
  Acceptance: Emit exact v2 identity/format from minimal ordered label/family rows, validate the five seek/five
    consume mapping, reject v1 at the v2 boundary before reconstruction with exact portable identity, and prove
    direct/traced/fresh-loaded execution without a serialized cursor override. Remove the `.2` v1 semantic
    isolation only when v2 owns execution; keep old standalone v1 artifacts classified legacy/regenerate-only.
  Verification: Activated task-tree-first on 2026-07-18 only after descriptor `.9.1.6.3` landed at clean commit
    `3caeb097`, `git_message_brief.txt` was zero bytes, the tree was clean at ahead 226, and generated book/cache
    artifacts were absent. Knowledge Map retrieval identifies the existing Julia v1 scaffold/family plan plus the
    admitted Perl/Rust/Dart v2 precedents. Exact probes reproduced v1/format 1, eager payload reconstruction,
    post-reconstruction plan validation, the private forced-seek engine, and compact-pipe generated AND drift.
    Current implementation emits v2/format 2, validates contract before payload decode, derives the governed
    five-seek/five-consume map from minimal label/family rows, classifies compact pipe as OR, deletes the private
    v1 engine, and migrates all current generated consumers. Focused source-emitter proof is 65/65; complete Julia
    is 3,133 pass plus the exact frozen help mismatch; cursor execution is 104/104; corpus is 105/105; primary is
    32/65 in default and POSIX; generated/cursor/logical/root governance passes at 80/0/0, 67/4+4/39, 8/0, and
    4/7+34. Knowledge Map is 618 facts / 4,489 keys; mdBook, memory, four doctrines, JSON, and whitespace pass;
    canonical root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 643 seconds pass. Generated 11 MiB
    mdBook output and 28 KiB Python cache are removed. Public options, shared fixtures, capability state, admission,
    and rollout remain unchanged; only the prepared clean commit precedes `.9.1.6.5`.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.6.4 - emit Julia generated-source v2`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Use the governed neutral contract and LinkedSpec source/runtime probes to record
    the exact current v1 identity/format, serialized plan, reconstruction order, direct/trace/load routes, and
    private v1 compatibility owner before editing.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Identify the single emission/reconstruction seams that still encode v1
    meaning and explain why intrinsic live cursor behavior cannot safely flow into an unversioned old artifact.
  - [x] **FIX** — Emit v2/format 2 from minimal ordered label/family rows, derive all five seek and five consume
    families after validation, reject v1 before reconstruction with exact expected/actual/regeneration identity,
    and retire the private v1 adapter only from newly emitted v2 execution.
  - [x] **ADDRESSED (verified)** — Prove deterministic bytes plus direct, traced, source-identity, and fresh-loaded
    execution for all families and root routes, including exact old-v1 legacy/regenerate-only rejection.
  - [x] **NO REGRESSION** — Pass focused/complete Julia, corpus, exact staged primary boundary, neutral governance,
    adjacent generated/logical/root suites, and the canonical local gate without option/admission/rollout drift.
  - [x] **LOCKSTEP** — Synchronize source/test contract ownership, task/live/memory/roadmap/architecture records,
    Knowledge Map facts, and mdBook; clean safe generated artifacts and commit before activating `.9.1.6.5`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.6.5`
  Status: `done`
  Goal: Remove Julia caller-global cursor options and migrate the exact 65-case primary projection.
  Dependencies: `.9.1.6.4`
  Acceptance: Remove engine state and high-level engine/loader/corpus/public overrides while retaining only
    low-level matcher primitives. A received legacy API option must fail before input/user code with exact
    `prepare_options/parse_mode_override_removed`; it may not be accepted and ignored. Recognize the retired CLI
    flag only for its exact targeted usage exit/message, omit it from help and request trace, migrate Julia package/
    process callers plus `tools/check_julia_primary_cli.sh`, update the neutral migration inventory, and pass the
    unchanged already-reference-owned shared manifest 65x2 plus corpus 105.
  Verification: Activated task-tree-first on 2026-07-18 only after generated-source v2 `.9.1.6.4` landed at
    clean commit `20a37cd2`, `git_message_brief.txt` was zero bytes, tracked/untracked state was clean at ahead 227,
    and generated mdBook/Python-cache artifacts were absent. Knowledge Map/ADR/admitted-removal retrieval and exact
    Julia token/runtime reproduction preceded implementation. Static audit now leaves only the targeted rejection,
    authored-family parser, diagnostic/trace naming, and low-level matcher tokens; loader/corpus are token-free.
    Focused removal passes 53/53; complete `tools/run_julia_local.sh` passes 3,187 package assertions, ten real
    process families, and corpus 105/105; unchanged shared primary passes 65/65 with `POSIXLY_CORRECT` unset and
    set. Neutral cursor governance is 66 files / 4 complete + 4 pending / 39 mutations; generated 80/0/0, logical
    8/0, root 4/7+34, capability 80/0/0, KM 619/4,498, mdBook, doctrines, task metadata, memory, JSON, and whitespace
    gates pass. The director-identified two-rule `--top-rule` fixture now uses entry lifecycle `I`, not incidental
    exit `E`; rationale is durable in `DEVELOPMENT_NOTES.md`. Canonical local CI exits 0 after all registered
    doctrines/contracts, root 7+5, cursor 288, primary 65/65 in both environments, and Phase 0 1,031/1,031 in
    637 seconds. The generated 11 MiB mdBook output and 28 KiB Python cache are removed; composed admission `.6`
    stays excluded until the clean per-leaf commit.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.6.5 - remove Julia global cursor overrides`

  #### Acceptance Checklist

  - [x] **RETRIEVE / AUDIT** — Follow the Knowledge Map to ADR `0044`, Julia runtime/descriptor/generated/primary
    facts, and admitted Perl/Rust/Dart removal designs; classify every Julia parse-mode token as caller-owned,
    rule-derived, historical/diagnostic, or permitted low-level matcher state before editing behavior.
  - [x] **REMOVE PUBLIC/GLOBAL OVERRIDES** — Delete engine state plus engine-constructor, loaded-engine, corpus,
    staged-parser, and every other caller-owned global option while retaining the contract-permitted low-level
    seek/consume matcher primitives and intrinsic per-entered-rule/generated-v2 derivation.
  - [x] **MIGRATE PRIMARY COMMAND** — Remove the help/execution/request-trace field, retain `--top-rule`, and reject
    exact retired `--parse-mode` spellings at usage exit 2 with the neutral targeted migration message before
    input loading or user code.
  - [x] **PROVE STATIC AND EXECUTABLE BOUNDARIES** — Add focused source-removal and retired-flag proof; pass affected
    suites, complete package, exact unchanged shared primary 65x2, corpus 105, and updated neutral inventory with
    every mutation effective.
  - [x] **NO REGRESSION / SCOPE** — Preserve generated-source v2, cursor descriptor v1, root precedence/routes,
    low-level matching, capability state, and rollout; leave the exact 15-role consumer and Julia promotion to `.6`.
  - [x] **LOCKSTEP / SIGNOFF** — Synchronize source/tests, task/index/roadmap/live/memory, Knowledge Map, Julia/public
    docs, mdBook, changes/notes, and pass governance plus canonical local CI; clean safe artifacts and commit before
    activating `.9.1.6.6`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.6.6`
  Status: `done`
  Goal: Admit and close the complete Julia projection of the neutral rule-local cursor contract.
  Dependencies: `.9.1.6.5`
  Acceptance: Add one omission-sensitive contract-declared 15-role Julia consumer mirroring Dart's normalized
    topology over native default/AND, normalized, loaded, descriptor v1, emitted/generated v2 direct/trace, mixed,
    recursive, both structural replacements, static option removal, primary, and all diagnostics. Lock the
    consumer, complete Julia driver, canonical tracked input/optional registration, roles, and mutations; advance
    only Julia; pass complete Julia/65x2/corpus/neutral/canonical proof; synchronize live/public/KM docs; close
    `.9.1.6`; and hand off root admission `.9.1.1.2.4.3` only after a clean commit.
  Verification: Activated task-tree-first on 2026-07-18 only after public-option removal `.9.1.6.5` landed at
    clean commit `ecc03c59`, `git_message_brief.txt` was zero bytes, tracked/untracked state was clean at ahead 228,
    and generated mdBook/Python-cache artifacts were absent. Exact neutral, Dart-admission, Julia constituent,
    checker-topology, canonical-driver, rollout, and mutation retrieval precedes implementation. Retrieval confirms
    no behavior repair: one Julia 15-role consumer plus package/canonical topology, inventory 66 -> 67, rollout
    4+4 -> 5+3, and five omission mutations 39 -> 44 are the exact slice. The new contract-declared consumer passes
    104/104 directly. The complete Julia driver passes 3,291 assertions, ten real-process families, and corpus
    105/105; shared primary passes 65/65 in default and POSIX environments. The stacked-depot proof exposed and
    repaired two gate owners that created the whole path list rather than its first writable entry; corrected
    offline proof passes and the malformed regenerable directory is absent. Cursor/generated/logical/root/
    capability governance, JSON, shell, Knowledge Map 621/4,512, mdBook, whitespace, memory, and all four doctrines
    pass. Canonical local CI exits 0 after root 7+5, Perl cursor admission 288, reference primary 65x2, and Phase 0
    1,031/1,031 in 641 seconds. Only Julia advances; no executable semantic or shared-fixture byte changes exist.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.6.6 - admit Julia rule-local cursor contract`

  #### Acceptance Checklist

  - [x] **RETRIEVE / AUDIT** — Follow the Knowledge Map to ADR `0044`, the neutral contract/checker, exact Dart
    15-role admission precedent, all Julia `.1-.5` constituent owners, current driver/canonical registration,
    rollout/inventory state, and mutation families before editing executable behavior or governance.
  - [x] **ADD ONE COMPOSED CONSUMER** — Add one omission-sensitive Julia consumer whose exact 15 declared roles run
    once in contract order over native default/AND, normalized, loaded, descriptor v1, emitted/generated v2
    direct/trace, mixed, recursive, both structural replacements, static removal, primary, and eight diagnostics.
  - [x] **REGISTER / ADVANCE JULIA ONLY** — Lock the consumer path/markers/order, complete Julia driver, canonical
    tracked input/optional registration, governed migration inventory, and effective topology/rollout mutations;
    promote only Julia while Lua and composed/public closeout remain pending.
  - [x] **PROVE COMPOSITION / NO REGRESSION** — Pass the focused consumer and all constituent suites, complete Julia
    package/process/65x2/corpus proof, neutral checker with every mutation rejected, adjacent generated/logical/root/
    capability governance, and canonical local CI without changing executable semantics or shared fixture bytes.
  - [x] **LOCKSTEP / CLOSEOUT** — Synchronize task/index/roadmaps/architecture/live/memory, Knowledge Map, Julia and
    public mdBook status, changes/notes, and cleanup; close `.9.1.6` and commit before activating root admission
    `.9.1.1.2.4.3`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.7`
  Status: `done`
  Goal: Align Lua and LuaJIT native/reconstructed/generated/primary behavior with ADR `0044`.
  Children: `.9.1.7.0` (preflight/split), `.9.1.7.1` (family/edge normalization), `.9.1.7.2`
    (live/loaded/reconstructed execution), `.9.1.7.3` (descriptor v1), `.9.1.7.4` (generated-source v2),
    `.9.1.7.5` (option/CLI migration), `.9.1.7.6` (dual-ABI composed admission/closeout)
  Dependencies: `.9.1.6`, `.9.1.1.2.5.2`
  Acceptance: Replace engine-wide seek ownership with family-derived rule policy; normalize the full bare-edge
    surface; remove legacy public and command options with exact diagnostics; consume descriptor/generated v2;
    migrate fixtures/callers; and prove native, reconstructed/emitted plan, trace, recursion, loaded-spec, and
    primary-command parity on both PUC Lua and LuaJIT against the unchanged neutral contract.
  Verification: Activated task-tree-first on 2026-07-19 only after Julia cursor `.9.1.6` and Lua root routes
    `.9.1.1.2.5.2` were complete, route leaf `.5.2` landed at clean commit `c3bdca44`,
    `git_message_brief.txt` was zero bytes, generated book/cache/native artifacts were absent, and the branch was
    clean at ahead 233. Child `.0` completed exact dual-ABI boundary reproduction and the dependency-safe `.1-.6`
    split at clean commit `47a1d166`; `.1` completed at clean commit `67909eb6`; `.2` completed at clean commit
    `d4b910e8`; descriptor `.3` completed at clean commit `79422858`; generated-source v2 `.4` completed at clean
    commit `d472c136`; option removal `.5` completed at clean commit `e96d389e`; admission `.6` adds the exact
    shared-source 15-role consumer and passes 119/119 per ABI, package 177/177x2, primary 65/65x4, corpus
    105/105x2, governance 69/6+2/49, KM 632/4,642, mdBook/four doctrines, and canonical Phase 0 1,031/1,031 in
    647 seconds. Only the clean `.6` commit boundary remains before root admission activates.`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.7.6 - admit Lua rule-local cursor contract`

- ID: `FUTURE-PARITY-BACKLOG.9.1.7.0`
  Status: `done`
  Goal: Map the exact PUC Lua/LuaJIT rule-local cursor boundary and freeze a gate-safe implementation split.
  Dependencies: `.9.1.6`, `.9.1.1.2.5.2`
  Acceptance: Use the Knowledge Map and LinkedSpec toolbox first; retrieve ADR `0044`, neutral and admitted
    Perl/Rust/Dart/Julia authorities, current Lua parser/compiler/runtime/loader/normalized/emitter/descriptor/
    primary/trace/corpus seams, both-ABI drivers, and local/canonical gates; reproduce family, edge, parent-child,
    option, descriptor, generated, focused/package, 65-case primary, corpus, and governance boundaries without
    behavior changes; then freeze dependency-ordered implementation leaves that keep main green.
  Verification: `complete 2026-07-19; PUC Lua and LuaJIT agree exactly: family parse/classification/runtime
    36/36, 34/36, and 22/36; valid edge/ownership compilation 5/13 and 2/4; portable invalid diagnostics 0/7;
    parent-child 4/8; structural 1/2; descriptor global seek; generated v1/format 1; package 176/177; primary
    32/65 in all four ABI/environment legs; corpus 105/105 per ABI; governance 67 files / 5 complete + 3 pending /
    44 rejected mutations. No Lua/shared executable behavior or fixture changed.`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.7.0 - map Lua cursor rollout`

  #### Acceptance Checklist

  - [x] **RETRIEVE / TOOLBOX FIRST** — Follow the Knowledge Map to ADR `0044`, the neutral contract/checker,
    admitted backend precedents, Lua architecture/root-route/generated/CLI facts, `TOOLBOX.md`, and complete
    dual-ABI drivers before inspecting or probing implementation seams.
  - [x] **EXACT LUA SURFACE MAP** — Account for every governed Lua inventory path plus non-token AST, parser,
    validation, compiled state, runtime dispatch, normalized reconstruction, source emission, loader, corpus,
    primary, trace, descriptor, test, native-module, and public-document seam on both ABIs.
  - [x] **REPRODUCE CURRENT BOUNDARIES** — Prove all 36 family spellings, all 18 edge rows and six ownership sets,
    eight parent-child mechanisms, two structural replacements, public option/CLI/request trace, descriptor/
    generated versions, focused/package state, exact default/POSIX PUC Lua/LuaJIT primary boundary, all 105 corpus
    fixtures, and neutral governance without behavior edits.
  - [x] **FREEZE SAFE IMPLEMENTATION SPLIT** — Confirm or refine `.1-.6` ownership for typed normalization,
    live/loaded/reconstructed execution, descriptor v1, generated-source v2, option/CLI migration, and exact
    dual-ABI composed admission; isolate compatibility seams and shared-fixture order so canonical main stays green.
  - [x] **NO REGRESSION / LOCKSTEP** — Change no Lua/shared executable behavior; synchronize task/index/roadmaps/
    live/memory, Knowledge Map, mdBook, changes/notes, run focused governance/book/canonical checks, clean safe
    generated artifacts, commit `.0`, clear the brief, and only then activate `.9.1.7.1`.

  #### Completion Evidence

  - Contract-driven public-API probes run with separately built PUC Lua and LuaJIT PCRE2/filesystem modules return
    identical results. All 36 headers parse; compact `|` is the only family-classification drift (34/36); the
    engine-wide default seek makes only the 22 seek rows intrinsically correct. Normalized-AST and loaded routes
    preserve that default and both accept a global consume override. Rule trace reports authored mode and cursor,
    but no derived cursor policy.
  - Only the two explicit action rows, two explicit blind rows (including the reserved-label target), and lifecycle
    row make the expected-success edge boundary (5/13); only the two all-explicit ownership sets pass (2/4).
    Bare members remain raw syntax. All five invalid edge rows and both invalid ownership-set rows lack the neutral
    diagnostic codes. The indexed blind suffix is retained as raw syntax rather than being silently discarded.
  - Every mixed-family case returns a defined value under global seek, so exact parent-child agreement is 4/8;
    this differs from Julia's historical 5/8 preflight because Lua's OR-to-AND recursive case is also a false
    positive. Structural replacement agreement is 1/2: ordered landmarks work, anchored AND children seek.
  - Descriptor metadata retains `meta.parse_mode = "seek"` with no cursor contract or rule policy. Generated
    source retains `linkedspec-generated-source-v1` / format 1, classifies compact pipe as `and_single_acode`, and
    accepts leading junk in an AND plan. Engine `parse_mode` is effective; unknown camel `parseMode` is accepted
    and ignored. Loader and corpus propagate the snake-case option; primary help and medium-or-higher request
    trace still expose it.
  - Package proof is 176/177 per ABI with only the expected help assertion. Shared primary is exactly 32/65 for
    PUC Lua default/POSIX and LuaJIT default/POSIX, with the same 22 help/usage plus 11 request-trace residuals.
    Corpus execution is 105/105 per ABI. Neutral governance passes at 67 migration files, 5 complete / 3 pending,
    and all 44 drift mutations rejected. Knowledge Map is 626 facts / 4,575 question keys; mdBook and all four
    doctrines pass. Canonical local CI closes with root consumers 7+5, cursor admission 288, reference primary
    65x2, and Phase 0 1,031/1,031 in 631 seconds. The `.1-.6` dependency order is confirmed unchanged.

- ID: `FUTURE-PARITY-BACKLOG.9.1.7.1`
  Status: `done`
  Goal: Normalize Lua authored families and mode-sensitive bare-edge ownership with portable diagnostics.
  Dependencies: `.9.1.7.0`
  Acceptance: Consume all 36 neutral family rows, all 18 edge rows, and all six ownership sets in Lua AST/parser/
    validation/compiled state. Correct compact `|` if required; normalize complete-line and header-rest bare
    plain/indexed/grouped/block/fluent members only after labels are known; preserve lifecycle precedence, forward
    targets, explicit overrides, and provenance; reject every governed invalid edge/set with exact portable fields.
  Verification: `activated task-tree-first from clean preflight commit 47a1d166 at ahead 234; exact contract
    RED is identical at 44/166 failures on PUC Lua and LuaJIT; implementation passes 258/258 assertions per ABI
    over 36 family rows, 18 edge rows, six ownership sets, portable diagnostics, AST JSON, and compiled lowering;
    all five focused consumers pass 936 assertions per ABI; package remains 176/177 with only the staged help
    mismatch, primary remains 32/65x4, and corpus remains 105/105x2; cursor governance is 67/5+3/44, KM is
    627/4,587, mdBook/all four doctrines pass, and canonical local CI closes with root 7+5, cursor 288, reference
    primary 65x2, and Phase 0 1,031/1,031 in 632 seconds; generated book, Python cache, and two 104 KiB native
    trees removed`
  Commit: `67909eb6` — `FUTURE-PARITY-BACKLOG.9.1.7.1 - normalize Lua cursor edges`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Use contract-driven Lua probes on PUC Lua and LuaJIT to record every family,
    edge, ownership, and diagnostic mismatch before editing.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Use parsed/compiled/tool trace output to locate family classification,
    bare-member retention/normalization, validation, and lowering owners with exact source locations.
  - [x] **FIX** — Add one typed normalization path and portable diagnostic projection without changing live cursor
    spending, descriptor/generated versions, public options, shared fixtures, or rollout.
  - [x] **ADDRESSED (verified)** — Pass the exact neutral 36/18/6 rows and all invalid mutations identically on
    both ABIs with compiled ownership and roundtrip identity.
  - [x] **NO REGRESSION** — Pass complete dual-ABI package/corpus/primary/governance/canonical proof and clean
    generated artifacts.
  - [x] **LOCKSTEP** — Synchronize durable docs/KM/book, commit `.1`, and only then activate runtime `.2`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.7.2`
  Status: `done`
  Goal: Derive Lua normal live, loaded, normalized, recursive, and traced execution from every entered rule.
  Dependencies: `.9.1.7.1`
  Acceptance: Derive seek/consume and sequence/choice once from each entered compiled rule across action, blind,
    direct call, recursion, loaded source, normalized reconstruction, and trace; remove parent/global propagation
    from normal execution while preserving low-level matcher primitives. Prove all eight parent-child mechanisms
    and both structural replacements; retain only explicit test-locked compatibility seams for generated v1 and
    outer callers until `.4-.5`; keep root-selection routes exact.
  Verification: `activated task-tree-first on 2026-07-19 from clean normalization commit 67909eb6 at ahead 235;
    git_message_brief.txt is zero bytes and generated book/cache/native normalization artifacts are absent; exact
    PUC Lua/LuaJIT RED is 44/110 failures in the new contract-driven execution proof; source/trace inspection
    locates defaulted engine state at interpreter.lua:126, matching spends at :3542/:3596, entered-rule/child
    reuse at :3646, and generated-v1 family isolation at source_emitter.lua:255-280 plus interpreter.lua:3692-3717;
    implementation derives one normal policy at each execute_rule entry, passes 110/110 per ABI over all 36
    families, 8/8 parent-child mechanisms, 2/2 structural replacements, live/loaded/normalized/recursive/trace,
    and explicit generated-v1/outer isolation; six focused consumers pass 1,046 assertions per ABI; complete
    package remains 176/177 per ABI with only staged help, primary remains exactly 32/65 in all four default/POSIX
    ABI legs, and corpus is 105/105 per ABI; cursor governance is 68 files / 5 complete + 3 pending / 44 rejected
    mutations; KM is 628/4,600; mdBook, syntax, shell, whitespace, memory, KM, task metadata, and all four doctrines
    pass; canonical local CI exits 0 after root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 624
    seconds; generated 11 MiB book, Python cache, and two 104 KiB native trees removed`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.10 - decide repeated action results`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Use the neutral contract through exact dual-ABI runtime probes to record family,
    parent-child, structural, loaded/normalized, recursive, and trace drift.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Trace every policy application site and parent/global propagation seam to exact
    runtime/compiler locations, including generated-v1 interaction.
  - [x] **FIX** — Derive immutable execution policy at each rule entry and make every child rederive independently,
    without weakening low-level seek/consume APIs or changing later artifact/public owners.
  - [x] **ADDRESSED (verified)** — Pass all 36 families, 8/8 parent-child, 2/2 structural, native/loaded/normalized/
    recursive/trace roles, root routes, and explicit generated-v1 isolation on PUC Lua and LuaJIT.
  - [x] **NO REGRESSION** — Pass complete dual-ABI and canonical gates while preserving the exact staged package,
    primary, corpus, governance, descriptor, generated-v1, public-option, root-route, and rollout boundaries.
  - [x] **LOCKSTEP** — Synchronize durable docs/KM/book, clean artifacts, commit `.2`, and only then activate
    descriptor `.3`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.7.3`
  Status: `done` (prepared for commit)
  Goal: Project Lua cursor descriptor v1 from normalized compiled rule state.
  Dependencies: `.9.1.7.2`
  Acceptance: Remove descriptor-global `parse_mode`; publish `linkedspec-rule-local-cursor-v1`; project each rule's
    authored family, derived policy, ownership, ordered resolved semantic edges, and permitted source provenance;
    expose no independent cursor override; preserve root-selection identity and direct/loaded/normalized descriptor
    byte agreement with live execution.
  Verification: `activated task-tree-first on 2026-07-19 only after runtime commit d4b910e8 landed cleanly at
    ahead 236; admitted authority retrieval proves normalized compiled facts are sufficient and no descriptor
    decoder exists; exact PUC Lua/LuaJIT RED is 364/776 failures and green is 875/875 assertions per ABI; seven
    focused consumers total 1,921 per ABI, package remains 176/177x2 only at staged help, primary remains 32/65x4,
    corpus remains 105/105x2, and governance is 68/5+3/44; KM is 629 facts / 4,611 keys; mdBook, memory/KM checks,
    and all doctrines pass; canonical local CI exits 0 after root 7+5, cursor 288, primary 65x2, and Phase 0
    1,031/1,031 in 621 seconds; generated book, Python cache, rust/target, dart/.dart_tool, and the temporary native
    RED tree are safely removed, while referenced durable reproduction logs are retained`
  Commit: `79422858` — `FUTURE-PARITY-BACKLOG.9.1.7.3 - project Lua cursor descriptor v1`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Dump current direct/loaded/normalized descriptor JSON and compare it with the
    neutral contract and admitted backend projections.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Locate stale descriptor-global projection and every decoder/consumer seam,
    proving whether normalized compiled facts are already sufficient.
  - [x] **FIX** — Project exact cursor-v1 root/rule/edge fields from normalized semantics without adding mutable
    policy state or disturbing root-selection metadata.
  - [x] **ADDRESSED (verified)** — Pass exact field sets, all family/edge rows, portable failures, byte-identical
    direct/loaded/normalized routes, and live agreement on both ABIs.
  - [x] **NO REGRESSION / LOCKSTEP** — Pass dual-ABI package/corpus/primary/governance/canonical gates, synchronize
    docs/KM/book, clean artifacts, commit `.3`, and only then activate generated v2 `.4`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.7.4`
  Status: `done`
  Goal: Advance Lua generated source to v2 with family-derived cursor and structural execution.
  Dependencies: `.9.1.7.3`
  Acceptance: Emit `linkedspec-generated-source-v2` / format 2 from minimal ordered `{label, family}` rows; derive
    exact five-seek/five-consume policy without a serialized cursor field; reject v1 before payload reconstruction
    with portable expected/actual/regeneration identity; prove deterministic emission, direct/traced/fresh-process
    execution, all families, structural rows, source identity, corpus subset/classifier breadth, and both ABIs.
  Verification: `activated task-tree-first on 2026-07-19 only after descriptor commit 79422858 landed cleanly at
    ahead 237; git_message_brief.txt is zero bytes; rust/target, dart/.dart_tool, generated book, Python cache, and
    temporary native trees are absent; ADR 0044, neutral v2 contract, admitted Perl/Rust/Dart/Julia mechanisms,
    Lua v1 fact cards, source/emitter/runtime/export/consumer owners, and shared checker were retrieved before code;
    the dedicated PUC Lua/LuaJIT RED is identical at 44 failures of 106 assertions, isolated to v2 identity/API,
    five consume-family outcomes, compact-pipe OR/choice, anchored choice, and contract-before-corrupt-payload v1
    rejection while the minimal label/family plan and seek-family paths already pass; implementation is now green
    at 106/106 on both ABIs: new artifacts identify v2/format 2, derive the exact five-seek/five-consume split,
    classify compact Pipe as OR, reject stale v1 before corrupt payload reconstruction with portable expected/
    actual/regeneration fields, and run deterministically through direct/traced/fresh hosts; eight focused consumers
    total 2,027 assertions per ABI, package remains 176/177x2 only at staged help, every primary ABI/environment leg
    remains exactly 32/65, corpus remains 105/105x2, and governance advances only to 69/5+3/44; KM is 630 facts /
    4,622 keys; mdBook, memory/KM, JSON, whitespace, and all four doctrines pass; canonical local CI exits 0 after
    root 7+5, cursor 288, primary 65x2, and Phase 0 1,031/1,031 in 644 seconds; generated 11 MiB book, Python cache,
    and every temporary native tree are removed, while referenced durable reproduction logs are retained`
  Commit: `pending`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Dump current Lua generated source/plan and run exact v1, compact-pipe, AND-leading-
    junk, direct/traced, and fresh-process probes on both ABIs.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Locate emitter identity, plan validation/reconstruction ordering, runtime
    compatibility overrides, and all generated consumer seams with exact source locations.
  - [x] **FIX** — Move new artifacts to v2/format 2, validate contract before payload reconstruction, derive policy
    only from minimal family rows, and remove the v1 compatibility seam once v2 owns execution.
  - [x] **ADDRESSED (verified)** — Pass exact family mapping, v1 rejection, deterministic bytes, direct/traced/
    fresh-process execution, corpus subset and exhaustive classifier evidence on PUC Lua and LuaJIT.
  - [x] **NO REGRESSION / LOCKSTEP** — Migrate affected consumers, pass complete dual-ABI/canonical gates,
    synchronize docs/KM/book, clean artifacts, commit `.4`, and only then activate option removal `.5`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.7.5`
  Status: `done`
  Goal: Remove Lua global cursor overrides and migrate the shared primary-command projection.
  Dependencies: `.9.1.7.4`
  Acceptance: Remove engine/runtime/loader/corpus/emitter/generated and other high-level caller-owned `parse_mode`
    options while preserving contract-permitted low-level matcher primitives; reject legacy dynamic keys before
    input/user code with `parse_mode_override_removed` / `prepare_options`; remove primary `--parse-mode` help and
    request-trace state while retaining targeted usage exit 2; migrate all non-removal callers and pass the exact
    shared 65 cases under default/POSIX on PUC Lua and LuaJIT without unrelated byte drift.
  Verification: `activated task-tree-first on 2026-07-19 only after generated-source-v2 commit d472c136 landed
    cleanly at ahead 238 with a zero-byte brief and no generated artifacts. ADR/Knowledge Map/neutral/admitted-
    backend retrieval accounts for every Lua owner and permitted matcher seam. Pre-edit PUC Lua and LuaJIT each
    fail exactly 75/96 focused assertions; the unchanged shared primary contract fails the same exact 33/65 cases
    under all four ABI/default-POSIX legs. Green proof is 96/96 focused and package 177/177 on each ABI, primary
    65/65 in all four legs, corpus 105/105 per ABI, and neutral governance 68 files / 5 complete + 3 pending / 44
    mutations. KM is 631 facts / 4,632 keys. mdBook build, memory/task/KM/JSON/whitespace, and all four doctrines
    pass. Canonical local CI exits 0 after root consumers 7+5, cursor admission 288, reference primary 65/65 in
    default and POSIX environments, and Phase 0 1,031/1,031 in 646 seconds. Cleanup removes the regenerated 11 MiB
    book and Python cache; no Rust, Dart, or temporary native build tree exists, while cited durable logs remain.
    Admission .6 was not activated before this commit boundary.`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.7.5 - remove Lua global cursor overrides`

  #### Acceptance Checklist

  - [x] **REPRODUCE / ISSUE** — Inventory and probe every public option/engine/loader/corpus/emitter/generated/CLI/
    trace owner and exact 33-case dual-ABI primary residual set before editing.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Distinguish high-level global authority from permitted low-level matcher
    primitives and locate all request parsing/validation/effect-order seams.
  - [x] **FIX** — Delete or reject every high-level override, preserve targeted migration diagnostics, remove help/
    request-trace exposure, and migrate only legitimate internal/tests/spec callers.
  - [x] **ADDRESSED (verified)** — Pass exact API removal-before-effect cases and all four 65/65 default/POSIX ABI
    primary legs with unchanged non-retired bytes.
  - [x] **NO REGRESSION / LOCKSTEP** — Pass complete dual-ABI package/process/corpus/governance/canonical gates,
    synchronize docs/KM/book, clean artifacts, commit `.5`, and only then activate admission `.6`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.7.6`
  Status: `done`
  Goal: Admit and close the complete dual-ABI Lua projection of the neutral rule-local cursor contract.
  Dependencies: `.9.1.7.5`
  Acceptance: Add one omission-sensitive contract-driven Lua consumer spanning the exact 15 native, normalized,
    loaded, descriptor, emitted/generated, trace, diagnostic, recursion/mixed-parent, structural-replacement,
    static-removal, and primary roles; run it on PUC Lua and LuaJIT; lock driver/canonical registration and
    mutations; advance only `lua_dual_abi` from pending to complete; pass full dual-ABI/65x4/corpus/canonical proof;
    synchronize public/live/KM/book records; close `.9.1.7`; and hand off root admission `.9.1.1.2.5.3` only after
    a clean commit.
  Verification: `Activated task-tree-first from clean e96d389e at ahead 239. Retrieval confirms one shared-source
    15-role consumer and topology/governance changes only; no semantic repair is needed. Exact pre-contract RED is
    3/3 failures on PUC Lua and LuaJIT. Green is 119/119 per ABI. The complete dual-ABI driver passes package
    177/177 per ABI, primary 65/65 in all four ABI/default-POSIX legs, and corpus 105/105 per ABI. Neutral
    governance is 69 files / 6 complete + 2 pending / 49 rejected mutations, and adjacent root/generated/logical/
    capability plus memory/doctrine gates pass. Knowledge Map is 632 facts / 4,642 keys; mdBook and all four
    doctrines pass. Canonical local CI exits 0 after root consumers 7+5, cursor admission 288, reference primary
    65/65 in default and POSIX environments, and Phase 0 1,031/1,031 in 647 seconds. Safe cleanup removes the
    generated 11 MiB book and Python cache while preserving durable tracked issue logs. The commit is prepared;
    root admission remains untouched until its clean boundary.`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.7.6 - admit Lua rule-local cursor contract`

  #### Acceptance Checklist

  - [x] **RETRIEVE / REPRODUCE** — Follow the Knowledge Map to ADR `0044`, neutral checker, all admitted 15-role
    consumers, every committed Lua `.1-.5` owner, current dual-ABI driver/canonical registration, rollout,
    inventory, and mutation families before behavior or governance edits.
  - [x] **ADD ONE DUAL-ABI CONSUMER** — Run every contract-declared role exactly once in order on PUC Lua and
    LuaJIT, with explicit assertions against skipping, duplication, stale v1, or ABI asymmetry.
  - [x] **REGISTER / ADVANCE LUA ONLY** — Lock consumer path/markers/order, complete Lua driver, canonical opt-in,
    migration inventory, exact primary cases, and mutations; promote only `lua_dual_abi`.
  - [x] **PROVE COMPOSITION / NO REGRESSION** — Pass the focused consumer and all constituent suites, complete
    dual-ABI package/process/65x4/corpus proof, neutral checker with every mutation rejected, adjacent root/
    generated/logical/capability governance, and canonical local CI without shared fixture byte drift.
  - [x] **LOCKSTEP / CLOSEOUT** — Synchronize task/index/roadmaps/architecture/live/memory, Knowledge Map, Lua and
    public mdBook status, changes/notes, and cleanup; close `.9.1.7`, commit `.6`, clear the brief, and only then
    activate root topology admission `.9.1.1.2.5.3`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.8`
  Status: `done`
  Goal: Admit the complete rule-local cursor contract symmetrically across five backends and every generated role.
  Dependencies: `.9.1.7`
  Acceptance: One recurring topology-aware driver composes the neutral checker, five native consumers, all
    reconstructed/emitted/generated roles, both Lua ABIs, exact default-AND/default-OR and mixed-parent fixtures,
    descriptor/generated-v2 validators, targeted legacy-option failures, and the primary command matrix. It must
    independently fail on missing, skipped, stale-v1, or asymmetric legs and preserve existing capability truth.
    The shared manifest/help/usage/trace target is established reference-first in `.9.1.3.5`; this leaf owns its
    final five-backend symmetry, recurring admission, and `cli_conformance/README.md` current-state projection.
  Verification: `Activated task-tree-first on 2026-07-19 only after root-selection closeout `.9.1.1.2.6` landed
    at clean commit `6693ffb4`, the branch was clean at ahead 242, `git_message_brief.txt` was zero bytes, no
    background job remained, and generated Rust/Dart/Julia/native/book/Python artifacts were absent. Exact
    neutral/admitted-consumer/generated/descriptor/removal/primary/driver/governance retrieval preceded all
    recurring edits. RED progressed exactly from unknown recurring schema, to missing driver, to missing canonical
    registration. The final driver passes neutral 36/18/8 and 14+15+15+15+15 roles; Perl 288; Rust/Dart exact
    admissions; Julia 104; PUC Lua 119; LuaJIT 119; selected primary 5x2x5; generated/capability 80/0/0; and
    coverage 246/105+1/122. Governance is 72 files / 7 complete + 1 pending / 56 mutations and only recurring
    admission advances. Separate identical dependency-regex identity `.9.1.8.1` remains dependency-gated.
    Memory, task/index, roadmaps, architecture, changes/notes, Knowledge Map, and five mdBook chapters are
    synchronized. Focused governance, KM 635/4,670, memory, all four doctrines, and mdBook pass; canonical local
    CI passes primary 65/65x2 and Phase 0 1,031/1,031 in 631 seconds. Safe cleanup leaves no Rust, Dart, Julia,
    mdBook, Python, or temporary harness output and preserves tracked regression evidence.`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.8 - admit recurring cursor parity`

  #### Acceptance Checklist

  - [x] **RETRIEVE / FREEZE COMPOSED SURFACE** — Follow the Knowledge Map to ADR `0044`, the neutral cursor
    contract, all five admitted consumers, generated-v2/descriptor/removal validators, primary cases, existing
    recurring-driver precedents, canonical registration, and exact current rollout/inventory/mutations.
  - [x] **REPRODUCE / DEFINE THE GAP** — Run the neutral checker and constituent consumers, inventory every
    required native/reconstructed/emitted/generated/descriptor/removal/mixed/structural/primary leg, and capture
    an exact omission-sensitive RED before changing recurring governance.
  - [x] **ADD ONE RECURRING FIVE-BACKEND GATE** — Compose Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT consumers,
    all required generated-v2/descriptor/removal validators, exact default-AND/default-OR and mixed-parent cases,
    and the shared primary projection without adding a semantic execution path.
  - [x] **REGISTER / ADVANCE ONLY RECURRING ADMISSION** — Lock driver commands, consumer topology, case identities,
    canonical tracked input and opt-in switch, inventory, and representative missing/skipped/stale/asymmetric
    mutations; advance only `recurring_five_backend_gate` from pending to complete.
  - [x] **PROVE / LOCKSTEP / COMMIT** — Pass the recurring gate, focused/primary/corpus/support governance,
    mdBook/memory/task/Knowledge Map/doctrines, canonical local CI, and safe artifact cleanup; synchronize
    task/index/roadmaps/architecture/live/memory/changes/notes/book/KM, commit `.9.1.8`, clear the brief, and prove
    a clean handoff before activating `.9.1.8.1` or public no-drift `.9.1.9`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.8.1`
  Status: `done`
  Goal: Decide and repair indexed dependency identity when one rule owns textually identical regex alternatives.
  Dependencies: `.9.1.8`
  Children: `.9.1.8.1.0`, `.9.1.8.1.1`, `.9.1.8.1.2`, `.9.1.8.1.3`, `.9.1.8.1.4`, `.9.1.8.1.5`,
    `.9.1.8.1.6`, `.9.1.8.1.7`
  Acceptance: Reproduce the Perl `LinkedRE::oredRE` leftmost-alternative index alias with the toolbox; inventory
    whether native/generated roles in all five backends preserve slot identity for identical patterns; ratify the
    language-level expectation; implement the narrow compiler/runtime representation or emit a portable rejection;
    and lock repeated identical slots, actions, marks, generated plans, traces, and non-identical behavior without
    relying on author-written regex distinctions.
  Verification: `Audit `.0` landed at `4902f218`; neutral `.1` at `93ee7935`; Perl `.2` at `568d3825`; Rust
    `.3` at `cad15db3`; Dart `.4` at `0e2807c2`; Julia `.5` at `01f2e574`; and dual-ABI Lua `.6` at `9211c9a8`.
    Final recurring/public `.7` composes the exact 12/15/15/15/15x2 role admissions, selected 5x2x1 primary
    proof, three support ledgers, 22 current public documents, 12 stale-current denials, and 59 mutations. The
    seven-leg rollout is closed at 7 complete / 0 pending without a new semantic path.`
  Commit: `pending`

- ID: `FUTURE-PARITY-BACKLOG.9.1.8.1.0`
  Status: `done`
  Goal: Reproduce, inventory, and mechanism-split identical dependency-regex slot identity before behavior changes.
  Dependencies: `.9.1.8`
  Acceptance: Use `LinkedSpec::Get`, `return_descriptor`, emitted-source capture, routed debug trace, and exact
    native/generated probes to freeze duplicate-slot behavior for ordered AND and choice/OR roles across Perl,
    Rust, Dart, Julia, PUC Lua, and LuaJIT. Distinguish language ambiguity from a lost known sequence identity;
    locate every compiler/runtime/generated/descriptor seam; define focused fixtures, diagnostics, migration
    inventory, and per-backend child boundaries without changing parser/compiler/runtime behavior.
  Verification: `Activated with parent `.9.1.8.1` from clean `a1911ec6`; Knowledge Map fact
    `perl-identical-dependency-regex-index-aliasing`, Toolbox, ADR `0044`, and ADR `0045` were retrieved before
    reproduction. Exact non-repeated native/generated evidence is Perl+Rust null versus Dart+Julia+PUC Lua+
    LuaJIT ordered-ok; every choice role selects the first authored duplicate. Repeated Perl live/emitted is null,
    repeated PUC Lua/LuaJIT native/generated returns two ordered pairs, and non-identical Perl live/emitted remains
    exact. Descriptor/compiled/generated payload identity survives; only Perl/Rust combined-alternation execution
    aliases the later required slot. No behavior edit occurred. Focused governance, Knowledge Map 636/4,678,
    mdBook, all four doctrines, canonical primary 65/65x2, and Phase 0 1,031/1,031 in 619 seconds pass; exact
    generated-output cleanup completes signoff.`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.8.1.0 - audit duplicate regex slot identity`

  #### Acceptance Checklist

  - [x] **RETRIEVE / REPRODUCE** — Routed Perl debug trace reproduces later slot 3 as match index 1 and marks
    `required_sequence_index` skipped; `return_descriptor` retains indices 0..4 and emitted handler source shows
    the combined match followed by expected-index comparison.
  - [x] **INVENTORY ALL ROLES** — Temporary exact native/generated probes measured ordered AND and choice/OR on
    Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; reconstructed compiled payloads, descriptors, emitted source, and
    minimal generated plans retain both slots. Repeated and non-identical controls isolate the same boundary.
  - [x] **ROOT CAUSE / SEMANTIC BOUNDARY** — `LinkedRE::oredRE` and Rust `CompiledAlternation` return the first
    matching duplicate from a combined alternation, then ordered handlers reject it against their already-known
    later slot. Dart/Julia/Lua match that known slot directly. Choice remains genuine first-authored ambiguity.
  - [x] **SPLIT / FREEZE** — Card `duplicate-regex-slot-identity-cross-backend-audit` freezes exact fixtures,
    expected-slot versus choice semantics, ADR/contract/checker/test/driver migration paths, source seams, no-plan-
    bump boundary, children `.1-.7`, and ADR `0045` stable-slot alignment before implementation.
  - [x] **LOCKSTEP / COMMIT** — Synchronize task/index/roadmaps/architecture/live/memory/changes/notes/book/KM,
    pass focused governance plus canonical CI, clean artifacts, commit `.0`, and only then activate `.1`.

  #### Completion Evidence

  - The durable five-slot Perl probe preserves dependency and action indices in its descriptor and emitted source,
    but routed debug trace reports `match_index=1` where ordered execution requires `expected_index=3`; the handler
    follows its existing `LX`/undefined path. This locates the failure after compilation and before action dispatch.
  - The minimal two-slot `Top::AND` fixture over `aa` returns null on Perl live/standalone-emitted and Rust native/
    generated execution. Dart, Julia, PUC Lua, and LuaJIT native/generated execution returns `ordered-ok`. The
    corresponding duplicate `OR` fixture returns the first authored result on all six runtime legs.
  - `Top::AND{2}` with two `/a/` slots over `aaaa` returns null in Perl live/emitted execution. PUC Lua and LuaJIT
    native/generated execution returns `[["a","a"],["a","a"]]`; all three preserving backend sources reuse
    their expected-slot loops for repetition. The non-identical `/a/`, `/b/` Perl control over `abab` still returns
    `[["a","b"],["a","b"]]` live/emitted, proving ordinary order and repetition are not generally broken.
  - Perl `LinkedRE.pm:48-52`, `Compiler.pm:654-725`, and `HandlerVariantEmitter.pm:833-914,1335-1429` form one
    aliasing chain. Rust repeats it in generated-plan `engine.rs:803-933` and ordinary `engine.rs:2665-2777`, over
    `helpers.rs:52-150`. Dart `interpreter.dart:938-1073`, Julia `Interpreter.jl:1024-1155`, and Lua
    `interpreter.lua:3565-3635` instead test one required pattern and reindex the resulting match.
  - The proposed `.1` decision is intentionally not pre-ratified here: ordered execution should preserve its known
    structural slot, choice should retain first-authored priority, duplicate text should remain legal, and identity
    must never be recovered from text/adjacency. Exact neutral governance will make that language decision in ADR
    `0047`; `.2-.6` then repair/lock backends and `.7` owns recurring/public admission.
  - Disk-pressure cleanup is operationally complete: exact inactive pgen build/test logs and one log-only battery
    directory had no process or open handle and were removed from `/private/tmp`, raising free space from 25 GiB to
    64 GiB. Final LinkedSpec book/Python/temp generated output was removed after proof and tracked `rgx` evidence
    is preserved.
  - Focused Knowledge Map, memory, task metadata, mdBook, whitespace, and four-doctrine checks pass. The canonical
    local gate passes primary CLI 65/65 in both default and POSIX environments and Phase 0 1,031/1,031 in 619
    seconds; optional backend matrices remain independently owned by the already-captured exact audit probes.

- ID: `FUTURE-PARITY-BACKLOG.9.1.8.1.1`
  Status: `done`
  Goal: Ratify and executable-lock portable duplicate regex-slot identity before backend repair.
  Dependencies: `.9.1.8.1.0`
  Acceptance: Adopt the ordered-versus-choice language rule, descriptor/generated identity, typed diagnostics,
    exact neutral fixtures, rollout ledger, migration inventory, and omission-sensitive mutations without changing
    backend behavior; reconcile ADR `0044` with ADR `0045` named-slot direction.
  Verification: `Activated task-tree-first from clean audit commit `4902f218` at ahead 244. The tree and untracked
    state were clean, `git_message_brief.txt` was zero bytes, generated Rust/Dart/Python/mdBook/temp output was
    absent, free disk was 64 GiB, and no background job remained. Retrieve audit card, ADR `0044`, ADR `0045`,
    and neutral contract precedents before ratification. ADR `0047`, executable
    `linkedspec-duplicate-regex-slot-identity-v1`, its independent checker, five fixtures, two diagnostics, six
    runtime rows, exact migration, 1-complete/6-pending rollout, 23 mutations, and unconditional canonical
    registration are focused-green; no backend execution edit exists. Knowledge Map 637/4,685, mdBook, all four
    doctrines, canonical primary 65/65x2, and Phase 0 1,031/1,031 in 635 seconds pass; exact cleanup completes
    signoff.`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.8.1.1 - adopt duplicate regex slot identity contract`

  #### Acceptance Checklist

  - [x] **RETRIEVE / BOUND** — Read the `.0` audit card, ADR `0044`, ADR `0045`, ADR `0046`, neutral checker
    precedents, contract registry, and canonical-CI seams before authoring the decision or executable artifact.
  - [x] **RATIFY PORTABLE IDENTITY** — Adopt duplicate-text legality, typed target-rule/slot identity, required-
    slot ordered matching, earliest/first-authored choice priority, repeated reset, and no text/adjacency recovery.
  - [x] **LOCK EXECUTABLE CONTRACT** — Add exact ordered/choice/repeated/cross-target/control fixtures, descriptor/
    generated/trace/diagnostic obligations, five-backend inventory, `.1-.7` rollout, and independent model proof.
  - [x] **REJECT DRIFT / REGISTER** — Reject representative semantic/schema/fixture/diagnostic/artifact/inventory/
    rollout/CI mutations and run the neutral checker unconditionally from canonical local CI.
  - [x] **LOCKSTEP / COMMIT** — Synchronize ADR index, task/index, roadmaps, architecture, live/memory, changes/
    notes, capability README, mdBook, and Knowledge Map; pass focused/canonical proof, clean, commit `.1`, and
    activate Perl `.2` only from the clean boundary.

  #### Completion Evidence

  - ADR `0047` reconciles ADR `0044`'s known sequence position with ADR `0045`'s stable structural identity:
    duplicate text remains legal; numeric and future named selectors resolve to one target-rule/slot identity;
    regex text, adjacency, capture text, and alternation branch guesses never recover identity.
  - Ordered execution matches only its required slot and reports that identity; repeated AND resets to the first
    required slot per accepted iteration. Choice evaluates all eligible slots, prefers earliest start, and breaks
    ties by lowest authored order. This ratifies target semantics without changing current backend behavior.
  - The neutral artifact contains five exact source/input/result fixtures: same-rule ordered duplicates, duplicate
    choice, repeated duplicates, repeated non-duplicate control, and cross-target duplicates. An independent regex
    model reproduces every expected identity.
  - Two portable invariants lock invalid compiled identity and ordered matcher identity loss. Descriptor and trace
    fields retain typed identity; generated-source remains v2/format 2 because embedded/reconstructed compiled
    payloads already retain every slot.
  - Six runtime inventory rows accurately leave Perl/Rust at drift and Dart/Julia/PUC-Lua/LuaJIT at behavior-
    matching but unadmitted. Exact `.2-.7` paths and rollout are frozen at 1 complete + 6 pending.
  - `python3 tools/check_duplicate_regex_slot_identity_contract.py` passes five fixtures, two diagnostics, six
    runtime rows, 1+6 rollout, and 23 semantic/fixture/diagnostic/artifact/inventory/rollout/CI mutations. JSON,
    Python, shell, and whitespace checks pass; canonical CI now tracks and runs the neutral checker unconditionally.
  - The first canonical attempt stopped before the new checker because the frontier summary rewrite had removed
    root public-contract marker `final five-backend recurring/public no-drift`. The existing root checker identified
    the exact cross-contract drift; the marker is restored without changing the duplicate-slot frontier.
  - Final signoff passes Knowledge Map 637 facts / 4,685 question keys, mdBook, memory/task metadata, whitespace,
    all four doctrines, canonical primary CLI 65/65 in default and POSIX environments, and Phase 0 1,031/1,031 in
    635 seconds. Exact generated book/Python/cache/temp cleanup follows proof.

- ID: `FUTURE-PARITY-BACKLOG.9.1.8.1.2`
  Status: `done`
  Goal: Implement and admit the Perl reference duplicate-slot identity contract.
  Dependencies: `.9.1.8.1.1`
  Acceptance: Repair the narrow compiler/matcher/handler seam or emit the ratified typed rejection; lock live,
    loaded, descriptor, emitted/generated-v2, trace, recursive, indexed, and non-identical behavior.
  Verification: `Activated task-tree-first from clean neutral-contract commit `93ee7935` at ahead 245. The tree
    and untracked state were clean, `git_message_brief.txt` was zero bytes, generated Rust/Dart/Python/mdBook/temp
    output was absent, free disk was 61 GiB, and no background job remained. Retrieve ADR `0047`, the executable
    contract/checker, audit mechanisms, and Perl toolbox seams before changing matcher/handler behavior. Exact
    toolbox RED reproduced the later duplicate alias while descriptors retained both rows. Focused GREEN
    passes all five neutral fixtures, the 12-role Perl consumer, generated-source/cursor/trace regression suites,
    and neutral governance at 2 complete + 5 pending / 26 mutations. Knowledge Map 638/4,693, mdBook, memory,
    task metadata, whitespace, JSON/shell, all four doctrines, canonical primary CLI 65/65x2, and Phase 0
    1,031/1,031 in 615 seconds pass. Exact generated mdBook/Python-cache cleanup completes proof.`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.8.1.2 - implement Perl duplicate regex slot identity`

  #### Acceptance Checklist

  - [x] **RETRIEVE / REPRODUCE RED** — Use the neutral fixture plus `LinkedSpec::Get`, descriptor/emitted source,
    and trace/toolbox evidence to reproduce exact live/generated ordered failure and green choice/control behavior.
  - [x] **REPAIR REQUIRED-SLOT EXECUTION** — Preserve the known target-rule/regex-index identity through ordinary
    and repeated Perl ordered handlers without regex-text recovery or choice-priority changes.
  - [x] **PROJECT / DIAGNOSE** — Publish the contract identity in descriptors, preserve generated-v2 plan shape,
    emit exact slot-selection trace/invariants where applicable, and retain portable invalid-identity diagnostics.
  - [x] **ADMIT PERL REFERENCE** — Add one exact contract consumer over live, loaded, descriptor, emitted/generated,
    trace, repeated, cross-target, non-identical, choice, and diagnostic roles; advance only Perl rollout.
  - [x] **LOCKSTEP / COMMIT** — Update contract/checker inventory, task/index/roadmaps/architecture/live/memory,
    changes/notes/book/KM; pass focused/canonical proof and cleanup; commit `.2`; activate Rust `.3` only cleanly.

  #### Completion Evidence

  - `LinkedRE::match_slot` tests only the already-required compiled regex under the rule-local seek/consume policy,
    snapshots whole/positional/named captures inside Perl's successful dynamic match scope, and returns the exact
    selection role, target rule, and regex index. Ordered handlers assert that identity before dispatch.
  - Live descriptors retain full `dependency_refs`; generated-source v2 embeds a compiled `dependency_slot_map`
    execution payload while the public generated format and minimal `{label,family}` plan rows remain unchanged.
    Cross-target AND variant selection now counts dependency rows, eliminating its metadata/emitter family drift.
  - Portable trace serializes `regex_slot_selected` identity. Stable `regex_slot_identity_invalid` and
    `ordered_regex_slot_identity_lost` failures cover malformed compiled rows and matcher/handler identity loss.
  - `t/duplicate_regex_slot_identity_perl_contract.t` passes 12 exact roles spanning all five neutral fixtures,
    live/loaded/generated execution, descriptor/emitted source, native/generated trace, ordinary/repeated/control/
    cross-target/choice behavior, capture snapshots, and both diagnostic routes.
  - Governance reports five fixtures, two diagnostics, six runtime rows, 2 complete + 5 pending rollout legs,
    and 26 rejected mutations. Only Perl advances; Rust `.3` remains the next repair owner.
  - Final signoff passes Knowledge Map 638 facts / 4,693 question keys, mdBook, memory/task metadata, whitespace,
    JSON/shell, all four doctrines, canonical primary CLI 65/65 in default and POSIX environments, and Phase 0
    1,031/1,031 in 615 seconds. The consumed 11 MiB mdBook build and 28 KiB Python cache are removed exactly;
    tracked evidence is preserved and no background verification remains.

- ID: `FUTURE-PARITY-BACKLOG.9.1.8.1.3`
  Status: `done`
  Goal: Implement and admit Rust duplicate-slot identity parity.
  Dependencies: `.9.1.8.1.2`
  Acceptance: Match the ratified Perl reference through native, reconstructed, generated-plan/source, trace,
    primary, and corpus roles without source-text identity recovery.
  Verification: **PASS 2026-07-20.** Activated task-tree-first from clean Perl-admission commit `568d3825` at
    ahead 246. The exact primary-interface toolbox probe returned null for `ordered_same_rule_duplicate` while
    compilation succeeded, isolating the combined-alternation/expected-index chain in ordinary `Engine` and
    `GeneratedPlanExecutor`. Both loops now match known sequence slots through retained individual regexes while
    combined choice remains unchanged. All five fixtures return exact values. The 15-role admission covers native,
    loaded, reconstructed, descriptor, emitted/generated, trace, primary, capture, and diagnostic routes.
    Complete Rust-local proof passes core 193+4+5+8, runtime 138, oracle 105, generated classifier 105,
    integrations 197, all adjacent suites, and primary 65x2. The neutral checker passes 3 complete + 4 pending /
    31 mutations. Strict Clippy adds no finding in a changed hunk. Knowledge Map 639/4,702, mdBook, memory, all
    four doctrines, formatting, JSON/shell, and whitespace pass. Canonical CI passes root 7+5, cursor 288,
    reference primary 65x2, and Phase 0 1,031/1,031 in 619 seconds after its first run correctly caught and the
    slice repaired a split exact root-selection public marker. Exact cleanup removes the initial 3.0 GiB and final
    1.5 GiB isolated Rust targets, rendered book, Python cache, and consumed logs; free space closes at 63 GiB.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.8.1.3 - implement Rust duplicate regex slot identity`

  #### Acceptance Checklist

  - [x] **RETRIEVE / REPRODUCE RED** — Retrieve ADR `0047`, all duplicate-slot Knowledge Map facts, the neutral
    contract/checker, Rust cursor admission, and `TOOLBOX.md`; the exact Rust primary probe returns null for the
    neutral ordered duplicate while compile/validation succeed.
  - [x] **ROOT CAUSE (WHY + WHERE)** — `rust/linkedspec-runtime/src/engine.rs` ordinary and generated-plan loops
    both call combined `CompiledAlternation`, obtain branch zero for identical patterns, then reject it against
    the already-required later `expected_and_idx`; compiled/action/descriptor rows remain distinct.
  - [x] **REPAIR NATIVE / GENERATED** — Match only the required compiled slot in both ordered loops, preserve
    combined earliest/first-authored choice, assert returned identity, and keep captures/cursor/repetition exact.
  - [x] **PROJECT / DIAGNOSE** — Publish descriptor contract identity, exact native/generated selection trace, and
    stable compiled-slot plus ordered-identity diagnostics without widening generated-source v2 plan rows.
  - [x] **ADMIT RUST / NO REGRESSION** — Add one exact neutral consumer over native, reconstructed, loaded,
    descriptor, emitted/generated-plan/source, trace, primary, corpus, repeated/control/cross-target/choice, and
    diagnostics; pass focused, complete Rust, canonical, lockstep, and cleanup proof.
  - [x] **LOCKSTEP / COMMIT** — Update contract/checker inventory, task/index/roadmaps/architecture/live/memory,
    changes/notes/book/KM; commit `.3`, clear the brief, and activate Dart `.4` only from a clean boundary.

- ID: `FUTURE-PARITY-BACKLOG.9.1.8.1.4`
  Status: `done`
  Goal: Implement and admit Dart duplicate-slot identity parity.
  Dependencies: `.9.1.8.1.3`
  Acceptance: Match the ratified reference through native, normalized emitted, reconstructed, generated-plan/
    source, trace, primary, and corpus roles with portable failures and stable slot identity.
  Verification: **PASS 2026-07-20.** Activated task-tree-first from clean Rust-admission commit `cad15db3` at ahead 247. Root status
    is clean, `git_message_brief.txt` is zero bytes, task-named Rust/book/cache/log artifacts are absent, free disk
    is 63 GiB, and no background job remains. Retrieve ADR `0047`, the duplicate-slot Knowledge Map cards,
    neutral contract/checker, Dart cursor/generated-source precedents, and Toolbox routes before changing Dart.
    Exact baseline probes returned every neutral result while source audit located the one-pattern compile+reindex
    approximation. `matchAlternative` now retains the authored index directly; compiled identity validation,
    descriptor/emitted/trace projection, generated-v2 reconstruction, both diagnostics, and one exact 15-role
    consumer pass. Governance is 4 complete + 3 pending / 36 mutations. The complete Dart-local gate passes
    format, fatal analyzer, 272 tests, primary 65x2, and corpus 105/105. Knowledge Map 640/4,711, mdBook, memory,
    all four doctrines, JSON/Python/shell/whitespace, canonical root 7+5, cursor 288, reference primary 65x2, and
    Phase 0 1,031/1,031 in 616 seconds pass. Exact post-proof generated-output cleanup and commit preparation
    complete signoff.`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.8.1.4 - implement Dart duplicate regex slot identity`

  #### Acceptance Checklist

  - [x] **RETRIEVE / REPRODUCE BASELINE** — Retrieve ADR `0047`, neutral/Dart Knowledge Map and generated/cursor
    precedents, then prove all five native fixtures already return exact values before implementation.
  - [x] **PRESERVE REQUIRED IDENTITY DIRECTLY** — Replace one-pattern matching plus index rewriting with an
    explicit required authored-alternative matcher while retaining complete-alternation choice priority.
  - [x] **PROJECT / VALIDATE / DIAGNOSE** — Validate compiled structural slots across native and artifact trust
    boundaries; publish descriptor/emitted identity, native/generated trace, and both portable invariants.
  - [x] **ADMIT DART / NO REGRESSION** — Run one exact 15-role consumer over every fixture and native, loaded,
    reconstructed, descriptor, emitted/generated, trace, primary, and diagnostic route; pass the complete Dart
    package, 65x2 primary, and 105-case corpus gate.
  - [x] **LOCKSTEP / COMMIT** — Update governance/task/roadmaps/live/memory/changes/notes/book/KM, pass canonical
    proof and cleanup, commit `.4`, clear the brief, and activate Julia `.5` only from a clean boundary.

  #### Completion Evidence

  - `RuntimeRegexAlternation.matchAlternative` addresses one existing authored alternative and constructs the
    match with its original index. AND and repeated-AND use it; full-alternation OR/default choice retains
    earliest-start and first-authored priority. Whole and capture-group values remain unchanged.
  - Compiled action rows map parent alternatives to `{target_rule, regex_index}`, so cross-target ordered trace
    reports `First#0`, then `Second#0`. One shared validator protects compiler, runtime, descriptor, source-emitter,
    and generated-plan boundaries without recovering identity from regex text.
  - Dart descriptors and emitted v2 source publish `linkedspec-duplicate-regex-slot-identity-v1`; normalized
    `SpecFile` JSON reconstructs compiled identities while public plans remain exactly `{label, family}`.
    `regex_slot_selected` covers ordered and choice selection. Both portable diagnostics retain exact fields.
  - `dart/test/duplicate_regex_slot_identity_contract_test.dart` executes each of 15 declared roles once over all
    five fixtures, native/loaded/reconstructed, descriptor/emitted/generated, native/generated trace, primary,
    and invalid-state routes. Governance advances only Dart to 4 complete + 3 pending / 36 mutations.
  - Complete Dart-local proof passes format, fatal analyzer, 272 tests, 65/65 primary cases in both default and
    POSIX environments, and 105/105 corpus fixtures. Final lockstep passes Knowledge Map 640 facts / 4,711 keys,
    mdBook, all four doctrines, canonical primary 65x2, and Phase 0 1,031/1,031 in 616 seconds.

- ID: `FUTURE-PARITY-BACKLOG.9.1.8.1.5`
  Status: `done`
  Goal: Implement and admit Julia duplicate-slot identity parity.
  Dependencies: `.9.1.8.1.4`
  Acceptance: Match the ratified reference through native, normalized emitted, reconstructed, generated-plan/
    source, trace, primary, and corpus roles with portable failures and stable slot identity.
  Verification: **PASS 2026-07-20.** Activated task-tree-first from clean Dart-admission commit `0e2807c2` at ahead 248. Julia now
    matches the existing authored alternative directly, maps parent alternatives to target/child identity,
    validates compiled state at compile/runtime/emitter/generated-plan boundaries, publishes descriptor/emitted
    contract identity, and traces ordered/choice selection. One module-isolated exact 15-role consumer passes 121
    assertions; the complete Julia driver passes package 3,549, primary 65x2, and corpus 105/105. Governance is
    5 complete + 2 pending / 41 mutations. The first canonical run identifies and resolves the new test's
    required cursor-inventory classification, advancing that ledger only to 73 files / 7+1 / 56. KM 641/4,720,
    mdBook, all four doctrines, JSON/Python/shell/whitespace, canonical root 7+5, cursor 288, reference primary
    65x2, and Phase 0 1,031/1,031 in 623 seconds pass. The hardened target/child-index validator rerun retains
    complete Julia package 3,549 / primary 65x2 / corpus 105. Cleanup removes both consumed Julia depots and all
    regenerated book/Python caches; free space is 63 GiB.`
  Commit: `FUTURE-PARITY-BACKLOG.9.1.8.1.5 - implement Julia duplicate regex slot identity`

  #### Acceptance Checklist

  - [x] **RETRIEVE / REPRODUCE BASELINE** — Retrieve ADR `0047`, neutral/Julia Knowledge Map and generated/cursor
    precedents, then prove all five native fixtures already return exact values before implementation.
  - [x] **PRESERVE REQUIRED IDENTITY DIRECTLY** — Replace singleton matching plus index rewriting with an explicit
    authored-alternative matcher while retaining complete-alternation choice priority.
  - [x] **PROJECT / VALIDATE / DIAGNOSE** — Validate structural slots across native and artifact trust boundaries;
    publish descriptor/emitted identity, native/generated trace, and both portable invariants.
  - [x] **ADMIT JULIA / NO REGRESSION** — Run one module-isolated exact 15-role consumer over every fixture and
    route; pass the complete Julia package, primary 65x2, and 105-case corpus gate.
  - [x] **LOCKSTEP / COMMIT** — Align duplicate-slot and cursor governance, task/roadmaps/live/memory/changes/notes/
    book/KM, pass canonical proof and cleanup, commit `.5`, clear the brief, and activate Lua `.6` only from a
    clean boundary.
  Implementation evidence:
  - `match_runtime_regex_slot` selects an existing `RuntimeRegexAlternative` and returns its authored index;
    ordered/repeated execution no longer compiles a singleton then calls `reindex_runtime_regex_match`. Full
    `runtime_match` remains the earliest-start/first-authored choice owner.
  - Compiled action edges translate parent indices to `{target_rule, child_regex_index}` for the ordered invariant
    and `julia_runtime:regex_slot_selected`, including cross-target `First#0,Second#0` projection.
  - `validate_compiled_regex_slot_identities` protects compile, runtime-engine, emitter, and generated-plan trust
    boundaries. Portable spec/runtime/generated failures preserve the contract's exact target/index fields.
  - Julia descriptors and emitted v2 modules publish `linkedspec-duplicate-regex-slot-identity-v1`; normalized
    `SpecFile` JSON remains the generated payload and plans remain exactly `{label, family}`.
  - `julia/test/duplicate_regex_slot_identity_contract_test.jl` executes each of 15 declared roles once in an
    isolated module. Focused 121, complete package 3,549, primary 65x2, and corpus 105 pass without method
    overwrite warnings.
  - The cursor migration checker inventories the new test because it intentionally names `parse_mode`. Adding it
    to the existing Julia cursor-owner group moves only that cross-contract inventory from 72 to 73 files.

- ID: `FUTURE-PARITY-BACKLOG.9.1.8.1.6`
  Status: `done`
  Goal: Implement and admit dual-ABI Lua duplicate-slot identity parity.
  Dependencies: `.9.1.8.1.5`
  Acceptance: Run one shared-source exact consumer on PUC Lua and LuaJIT across native, normalized, reconstructed,
    generated-v2, trace, primary, and corpus roles with identical stable slot identity.
  Verification: **PASS 2026-07-20.** Activated task-tree-first from clean Julia-admission commit
    `01f2e574` at ahead 249. ADR `0047`, duplicate-slot/Lua Knowledge Map facts, neutral checker, prior dual-ABI
    admission topology, and Toolbox routes were retrieved before implementation. Baseline values were exact but
    ordered matching compiled a singleton and reindexed branch zero. Lua now selects the existing authored slot,
    maps and validates target/child identity at every trust boundary, and publishes descriptor/emitted/trace
    identity plus both portable diagnostics. One shared 15-role consumer passes 112 assertions on PUC Lua and
    LuaJIT. The complete Lua driver passes package 177x2, primary 65x2, and corpus 105/105. Duplicate governance
    is 6 complete + 1 pending / 46 mutations; cursor governance remains 73 files / 7+1 / 56. KM 643/4,735,
    mdBook, all four doctrines, JSON/Python/Lua/shell/whitespace, canonical root 7+5, cursor 288, reference primary
    65x2, and Phase 0 1,031/1,031 in 653 seconds pass. Exact cleanup removes the consumed 11 MiB book and 28 KiB
    Python cache after the complete Lua driver removed both native trees; no task artifact remains.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.8.1.6 - implement dual ABI Lua duplicate regex slot identity`

  #### Acceptance Checklist

  - [x] **RETRIEVE / REPRODUCE BASELINE** — Retrieve ADR `0047`, neutral/Lua Knowledge Map and generated/cursor
    precedents, then prove all five native fixtures already return exact values before implementation.
  - [x] **PRESERVE REQUIRED IDENTITY DIRECTLY** — Replace singleton matching plus index rewriting with an explicit
    existing authored-alternative matcher while retaining complete-alternation choice priority.
  - [x] **PROJECT / VALIDATE / DIAGNOSE** — Validate structural slots across native and artifact trust boundaries;
    publish descriptor/emitted identity, native/generated trace, and both portable invariants.
  - [x] **ADMIT BOTH LUA ABIS / NO REGRESSION** — Run one byte-identical 15-role consumer on PUC Lua and LuaJIT;
    pass complete package 177x2, primary 65x2, and 105-case corpus proof.
  - [x] **LOCKSTEP / COMMIT** — Align governance/task/roadmaps/live/memory/changes/notes/README/book/KM, pass
    canonical proof and exact cleanup, commit `.6`, clear the brief, and activate recurring/public `.7` only from
    a clean boundary.

  #### Implementation Evidence

  - `match_runtime_regex_slot` addresses an existing alternative in the rule-owned compiled alternation and
    returns its authored index. Ordered/repeated execution no longer builds a singleton and reindexes branch zero;
    full `runtime_match` remains the earliest-start/first-authored choice owner.
  - Compiled action edges translate parent indexes to `{target_rule, child_regex_index}` for the ordered invariant
    and `lua_runtime:regex_slot_selected`, including cross-target `First#0,Second#0` projection.
  - `validate_compiled_regex_slot_identities` protects compile, runtime-engine, source-emitter, and generated-plan
    boundaries. Portable spec/runtime/generated failures retain the contract's exact target/index fields.
  - Lua descriptors and emitted v2 modules publish `linkedspec-duplicate-regex-slot-identity-v1`; normalized
    `SpecFile` JSON remains the generated payload and public plans remain exactly `{label, family}`.
  - `lua/test/duplicate_regex_slot_identity_contract_test.lua` executes each of 15 declared roles once from the
    same source on both ABIs. It passes 112 assertions per ABI; complete Lua proof passes package 177x2, primary
    65x2, and corpus 105/105. Governance advances only Lua to 6 complete + 1 pending / 46 mutations.
  - Lua's interpreter chunk is at the Lua 5.1 200-local ceiling. The implementation avoids new chunk locals by
    using the existing module namespace; a Knowledge Map card preserves this maintenance constraint.

- ID: `FUTURE-PARITY-BACKLOG.9.1.8.1.7`
  Status: `done`
  Goal: Close duplicate-slot identity with recurring five-backend and public no-drift admission.
  Dependencies: `.9.1.8.1.6`
  Acceptance: Compose every admitted runtime/generated role, exact primary/corpus cases, public guidance, capability
    truth, migration/stale guards, and independent mutations; close `.9.1.8.1` only with clean canonical proof.
  Verification: **PASS 2026-07-20.** Activated task-tree-first from clean Lua commit `9211c9a8`. The contract, exact
    recurring driver, CI switch, corrected genuine single-choice `::|` fixture, 22 public documents, 12 stale-
    current denials, two Knowledge Map cards, and 59-mutation campaign are complete. Exact recurring proof passes:
    Perl 12 roles; Rust/Dart/Julia 15 roles; PUC Lua/LuaJIT 112 assertions each; primary 5x2x1; generated-source
    10/1/8+105; capability 80/0/0; language coverage 246/105+1/122. A first run exposed only an empty Julia depot
    default; the repaired driver prepends a disposable writable depot to Julia's installed stack. The selected
    primary helper now creates only its first writable depot entry, preventing a colon-literal artifact. Canonical
    local CI passes root 7+5, cursor 288, duplicate Perl 12, primary 65x2, and Phase 0 1,031/1,031 in 640 seconds.
    KM 645/4,745, mdBook, all four doctrines, syntax, whitespace, and exact generated-artifact cleanup pass. The
    duplicate contract/checker name the parse-mode mdBook chapter and are classified under cursor public owner
    `.9.1.9`, advancing only that inventory from 73 to 75 files at unchanged 7+1/56.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.8.1.7 - close duplicate slot recurring public no drift` (`92394bb7`)

  #### Acceptance Checklist

  - [x] **RETRIEVE / FREEZE THE COMPLETE SURFACE** — Follow the Knowledge Map to ADR `0047`, the neutral checker,
    all five backend consumers and both Lua ABIs, emitted/generated/descriptor/trace/diagnostic roles, exact
    primary/corpus support ledgers, recurring-driver precedents, public documents, and canonical registration.
  - [x] **ADD ONE OMISSION-SENSITIVE RECURRING GATE** — Compose every declared backend consumer and generated role,
    both Lua ABIs, exact selected primary and corpus/support proof, and the neutral model without adding a semantic
    execution path.
  - [x] **CLOSE PUBLIC / CAPABILITY NO-DRIFT** — Make current guidance, backend/API companions, mdBook, capability
    truth, Knowledge Map, migration inventory, and stale-claim guards state the complete contract exactly.
  - [x] **ADVANCE ONLY FINAL ROLLOUT / CLOSE PARENT** — Reject missing, skipped, stale, asymmetric, public, support,
    driver, registration, rollout, and parent-status mutations; complete only recurring/public `.7` and close
    `.9.1.8.1` after every constituent remains admitted.
  - [x] **PROVE / LOCKSTEP / COMMIT** — Pass the recurring gate, focused and canonical proof, mdBook/KM/doctrines,
    exact cleanup, and whitespace; synchronize task/index/roadmaps/live/memory/changes/notes and commit `.7` before
    selecting any later leaf.

- ID: `FUTURE-PARITY-BACKLOG.9.1.9`
  Status: `done`
  Goal: Close cursor/edge rollout with public no-drift, migration guidance, and exact parent status.
  Dependencies: `.9.1.8.1`
  Acceptance: README, guides, mdBook, API/backend companions, examples, help, architecture, Knowledge Map,
    capability/status ledgers, and recurring scanners describe only the current implemented rule-local contract;
    stale current `parse_mode` guidance and v1 generated admission fail mechanically while explicit historical
    evidence remains classified. Close the cursor rollout at 8/0 while keeping `.9.1`/`.9` active for pending
    explicit repeated-OR result-shape child `.9.1.10`.
  Verification: Activated task-tree-first on 2026-07-20 from clean duplicate-slot closeout commit `92394bb7`;
    no public, checker, capability, status, or parent-closeout edit preceded this activation. Exact parent review
    found `.9.1.10` correctly nested under AND/OR semantics, so this leaf corrects its stale parent-closeout
    sentence rather than falsely completing a parent with a pending child. The executable public contract now
    locks 29 documents and 26 stale-current denials; the cursor checker reports 75 migration files / 8 complete +
    0 pending / 60 mutations. Focused cursor/root/duplicate checkers, Python syntax, the complete recurring cursor
    driver, Knowledge Map generation, mdBook, memory architecture, all four doctrines, and whitespace pass. A
    first clean-cache recurring run exposed a Julia harness default that discarded installed package sources; the
    repaired driver prepends its writable depot to Julia's actual `Base.DEPOT_PATH` and passes every runtime and
    support leg. Final lockstep passes KM 646/4,751, mdBook, memory, four doctrines, syntax, whitespace, primary
    65/65 in default and POSIX environments, and Phase 0 1,031/1,031; canonical local CI exits 0. Exact cleanup
    removes 1.8 GiB of reproducible Rust output plus regenerated Dart, mdBook, and Python caches without touching
    source-bearing or uncertain external data.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.9 - close cursor public no drift` (`4ceec12d`)

  #### Acceptance Checklist

  - [x] **RETRIEVE / INVENTORY CURRENT PUBLIC SURFACE** — Follow the Knowledge Map to ADR `0044`, the recurring
    cursor admission, exact migration inventory, public guides, backend/API companions, status ledgers, and
    historical classifications before changing public claims.
  - [x] **CLOSE PUBLIC NO-DRIFT** — Require every current public surface to state intrinsic rule-local cursor and
    bare-edge semantics exactly; reject stale global `parse_mode`, removed CLI/API override, and generated-v1
    claims while retaining explicitly classified history.
  - [x] **KEEP PARENT STATUS EXACT** — Advance only cursor public admission to 8/0 after all neutral, backend,
    recurring, public, capability, roadmap, task, and Knowledge Map projections agree; keep `.9.1` and `.9`
    active while child `.9.1.10` remains pending.
  - [x] **PROVE / LOCKSTEP / COMMIT** — Pass focused public/migration mutations, recurring runtime proof where
    warranted, capability/coverage ledgers, mdBook/KM/doctrines, canonical CI, exact artifact cleanup, and
    whitespace; synchronize live docs and commit `.9.1.9` before selecting `.9.1.10` or another leaf.

- ID: `FUTURE-PARITY-BACKLOG.9.1.10`
  Status: `done`
  Goal: Decide and align explicit repeated-OR action-edge result shape across all five backends.
  Children: `.9.1.10.1`, `.9.1.10.2`, `.9.1.10.3`, `.9.1.10.4`, `.9.1.10.5`, `.9.1.10.6`, `.9.1.10.7`
  Dependencies: `.9.1.9`
  Acceptance: Reproduce every repeated action-choice spelling (`*`, `+`, `?`, `OR`, `OR+`, and bounded `OR`) plus
    single-choice `Rule::|` with duplicate and distinct action-edge patterns across native, loaded, reconstructed,
    generated, traced, primary, and corpus routes. Decide whether repeated choice returns the Perl reference's
    per-hit collection or a single direct action value; preserve `::|` as non-repeating single choice; distinguish
    action-edge iteration results from lifecycle whole-rule returns; and split neutral, backend, recurring, and
    public work before behavior code.
  Verification: Activated task-tree-first on 2026-07-20 from clean cursor public-no-drift commit `4ceec12d` at
    ahead 252; no audit, decision, public, or behavior edit preceded activation. Exact Perl live, loaded,
    generated, and generated-traced toolbox probes return `["A","B"]` for `::OR`, `::OR+`, bounded `::OR`,
    and `::+`, `["A"]` for `::?`, and scalar `"A"` for `::|`; generated trace records two selected slots for
    the two-hit repetitions and one for pipe. The same distinct-pattern source through all five primary adapters
    proves Perl collection versus Rust/Dart/Julia/Lua first-scalar drift for every repeated spelling, while pipe
    agrees. Source audit isolates two defects shared by all four newer implementations: their AST documentation
    calls bare `OR` repeated choice but `is_repetition`/`rep_min` excludes it and generated v2 classifies it as
    `or_acode`; independently, their repeated execution paths propagate an action-edge return as an immediate
    whole-rule return. Perl `REP_ACODE` instead rewrites only action-edge return into the iteration value, runs the
    remaining successful-iteration path, collects once per hit, and leaves lifecycle returns authoritative.
    ADR `0048` accepts the Perl/reference collection rule, keeps generated-source v2 with corrected family rows,
    and splits all behavior/public work below before code. The decision slice changes documentation/governance
    only. Knowledge Map generation/check passes at 646 facts / 4,755 question keys; memory architecture passes at
    56/60 lines; task metadata and all four doctrines pass; mdBook builds; whitespace is clean; regenerated book,
    Dart, and disposable probe artifacts are removed before commit.
  Commit: closed by the complete child commit series through `FUTURE-PARITY-BACKLOG.9.1.10.7`

  #### Acceptance Checklist

  - [x] **RETRIEVE / TOOLBOX FIRST** — Follow the Knowledge Map to the existing gap, rule-mode, collection-shape,
    HandlerIR, generated-source, and cursor records; use `return_descriptor`, generated source, handler
    substitution, and routed trace before reading implementation branches.
  - [x] **REPRODUCE / ISOLATE** — Prove the exact Perl route shape and five-primary drift for distinct/duplicate
    choice, then source-audit native/generated classification and return propagation in all four newer backends.
  - [x] **DECIDE WITHOUT BEHAVIOR** — Ratify per-hit collection for repeated action choice, scalar pipe, lifecycle
    whole-rule authority, stable bounds/slot/cursor semantics, descriptor projection, and unchanged generated-v2
    format; record the two independent root causes durably.
  - [x] **SPLIT BEFORE CODE** — Create neutral/reference, Rust, Dart, Julia, dual-ABI Lua, recurring, and public
    leaves with exact route and signoff obligations before any parser/compiler/runtime behavior edit.
  - [x] **COMPLETE CHILDREN / CLOSE PARENTS** — Land `.1-.7` in dependency order, then close `.9.1.1`, `.9.1.10`,
    `.9.1`, and `.9` only after every runtime, generated, primary, corpus, descriptor, trace, and public projection
    agrees. The extra `.9.1.1` parent was found by exact closure inventory after all of its children were done.

- ID: `FUTURE-PARITY-BACKLOG.9.1.10.1`
  Status: `done`
  Goal: Make repeated-choice action results an executable neutral contract and admit the Perl reference.
  Dependencies: `.9.1.10` decision/split commit
  Acceptance: Add one backend-neutral contract/checker with exact `*`, `+`, `?`, `OR`, `OR+`, bounded-OR, and
    `|` fixtures; distinct and duplicate slots; block/fluent returns; scalar/null/nested values; zero/below-min/
    bounded results; lifecycle overrides; blind-choice classification control; descriptors; generated family;
    selected-slot trace; loaded/generated/primary/corpus roles; exact Perl consumer; rollout inventory; and
    omission-sensitive mutations. No non-Perl runtime behavior changes.
  Verification: Activated task-tree-first on 2026-07-20 from clean decision commit `34ad7548` at ahead 253;
    no neutral schema, checker, fixture, Perl consumer, gate, capability, or behavior edit preceded activation.
    `linkedspec-explicit-repetition-action-result-v1` now locks 8 exact mode cases, 10 special cases, independent
    result/cursor/selected-slot evaluation, descriptors, generated-source v2, trace, routes, a checked-in corpus
    bundle, six runtime mechanism rows, and 2 complete + 6 pending rollout. The checker rejects 25 independent
    drift mutations. One Perl consumer passes 10 composed roles spanning neutral/live/special/loaded/descriptor/
    emitted/generated-direct/generated-trace/primary/corpus. Canonical CI requires and runs both unconditionally;
    no parser, compiler, runtime, descriptor, or generated-source behavior changes. Adjacent cursor verification
    exposed that decision commit `34ad7548` had wrapped the stable `75 migration files / 8 complete + 0 pending /
    60 mutations` marker across lines in `LIVE_ACHIEVEMENT_STATUS.md` and replaced the task-index sentence that
    names `.9.1.10` as the remaining AND/OR frontier. This leaf restores both exact historical no-drift markers
    while updating their current context. Focused adjacent contract checks pass at duplicate 7+0/59, cursor
    75/8+0/60, and root 7+0/54; Knowledge Map is 646 facts / 4,757 question keys; memory is 56/60 lines; task
    metadata, all four doctrines, mdBook, and whitespace pass. Canonical local CI exits 0 after the new checker,
    all 10 Perl roles, primary CLI 65/65 in default and POSIX environments, and Phase 0 1,031/1,031 in 614 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.10.1 - admit repeated action result contract`

  #### Acceptance Checklist

  - [x] **SCHEMA / MODEL** — Lock exact explicit-repetition modes, pipe control, per-hit typed collection,
    lifecycle authority, bounds/progress, descriptor facts, generated-v2 family rows, trace observations, route
    roles, current six-runtime mechanism inventory, rollout ownership, and the unadorned-default exclusion.
  - [x] **FIXTURES / PERL ROUTES** — Execute distinct and duplicate block returns, fluent return, nested/null values,
    zero/below-min bounds, E/LE lifecycle overrides, blind OR, and scalar pipe through live, loaded, descriptor,
    emitted/generated direct/traced, primary, and checked-in corpus-bundle routes on Perl.
  - [x] **CHECKER / MUTATIONS** — Validate exact schema/source/result/model/route/rollout topology, require only the
    admitted Perl consumer while declaring future paths, and reject omission plus semantic/family/lifecycle/
    generated/trace/consumer/rollout mutations independently.
  - [x] **REGISTER / NO BEHAVIOR** — Add the neutral checker and Perl consumer unconditionally to canonical CI,
    preserve all parser/compiler/runtime behavior, and leave Rust/Dart/Julia/Lua plus recurring/public pending.
  - [x] **PROVE / LOCKSTEP / COMMIT** — Pass checker mutations, Perl syntax/admission, existing adjacent contracts,
    mdBook/KM/memory/doctrines, canonical gate where warranted, whitespace, and exact cleanup; synchronize
    task/roadmaps/live/changes/notes and commit `.1` before activating Rust `.2`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.10.2`
  Status: `done`
  Goal: Align Rust repeated-choice classification and action-result collection.
  Dependencies: `.9.1.10.1`
  Acceptance: Make authored `RuleMode::Or` repetition with minimum one and generated `rep_acode`; collect one
    action-edge return value per successful repeated-choice hit without converting lifecycle returns into
    iteration values; preserve bounds, progress, slot identity, cursor policy, pipe scalar choice, diagnostics,
    and generated-source v2; prove native, loaded, reconstructed, generated direct/traced, emitted, descriptor,
    primary, and corpus roles through one neutral consumer plus the complete Rust gate.
  Verification: Activated task-tree-first on 2026-07-20 from clean neutral/reference commit `00ee7085` at ahead
    254; no Rust AST, runtime, descriptor, generated-source, fixture, driver, or documentation edit preceded
    activation. The omission-sensitive neutral consumer and 26-mutation checker were added before behavior;
    focused red execution independently proved authored bare `OR` reported `is_repetition = false` and repeated
    action execution returned first-hit scalar `"A"` instead of `["A", "B"]`. Rust now reports bare `OR` as
    minimum-one repetition, classifies action/blind forms as `rep_acode`/`rep_bcode`, and collects one typed
    action-block or fluent return per accepted hit in native and generated execution. Pipe, default, AND,
    blind-result, lifecycle, bounds, zero-progress, cursor, slot identity, and generated-source-v2 boundaries are
    preserved. The exact 15-role consumer, 26-mutation checker, core 193 plus auxiliaries, adjacent emitted-source
    matrix, complete runtime package, Rust primary 65x2, and canonical Perl primary 65x2 plus Phase 0 1,031 in
    632 seconds pass. Broad-suite expectations now preserve a returned array as one
    explicit-star iteration element, through both cursor-contract nested bare-OR recursion routes, and across the
    cursor execution matrix's explicit repetition families without changing its cursor assertions. Exact cleanup
    removes the initial 2.6-GiB target and final 1.7-GiB incremental-disabled rebuild.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.10.2 - admit Rust repeated action results`

  #### Acceptance Checklist

  - [x] **RETRIEVE / INVENTORY RUST SEAMS** — Follow the Knowledge Map and neutral contract to the exact Rust
    authored-mode metadata, compiler/runtime action-result flow, descriptor, emitted/generated-v2, loaded/
    reconstructed, trace, primary, corpus, and driver seams before editing behavior.
  - [x] **RED / NEUTRAL CONSUMER** — Add one omission-sensitive contract consumer that proves all eight modes,
    ten special cases where representable, and the required native/composed/artifact/trace/primary/corpus routes;
    demonstrate the current bare-OR family and first-return failures before repair.
  - [x] **CLASSIFY BARE OR AS REPETITION** — Make authored Rust `Or` minimum-one repetition and generated
    `rep_acode`/`rep_bcode` without widening generated-source v2 or changing scalar pipe.
  - [x] **COLLECT ACTION ITERATION VALUES** — Preserve action-edge return context through each accepted repeated
    hit, collect one typed value per hit, and retain lifecycle return as immediate whole-rule authority with exact
    bounds, zero progress, cursor, and slot identity.
  - [x] **COMPOSE / ADMIT ONLY RUST** — Prove native, loaded, reconstructed, descriptor, emitted/generated direct
    and traced, primary, corpus, and diagnostics through the complete Rust gate; advance only Rust to complete and
    leave Dart/Julia/Lua/recurring/public pending.
  - [x] **PROVE / LOCKSTEP / COMMIT** — Pass neutral and adjacent checkers, focused and complete Rust gates,
    mdBook/KM/memory/doctrines, canonical CI where warranted, whitespace, and exact artifact cleanup; synchronize
    task/roadmap/live/changes/notes and commit `.2` before activating Dart `.3`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.10.3`
  Status: `done`
  Goal: Align Dart repeated-choice classification and action-result collection.
  Dependencies: `.9.1.10.2`
  Acceptance: Apply the accepted contract through Dart AST metadata, runtime return flow, descriptor,
    generated-v2 classification/execution, emitted source, loading/reconstruction, trace, primary, and corpus;
    preserve lifecycle authority, bounds, progress, slot/cursor semantics, and pipe scalar choice; add one exact
    neutral admission consumer and pass format, analyzer, package, primary, and corpus gates.
  Verification: Activated task-tree-first on 2026-07-20 from clean Rust admission commit `293b10ea` at ahead
    255. No Dart AST, runtime, descriptor, generated-source, fixture, driver, or documentation edit preceded
    activation. The exact 15-role consumer and 27-mutation pending checker landed before behavior; focused red
    independently proved bare `OR` reported `isRepetition = false` and two accepted action hits returned scalar
    `"A"` instead of `["A", "B"]`. Dart now gives bare `Or` minimum one, classifies action/blind forms as
    `rep_acode`/`rep_bcode`, and collects typed action-block/fluent returns at the action-edge boundary so implicit
    child dispatch still completes while `LE` and all other lifecycle returns retain immediate whole-rule
    authority. Default, AND, blind-result, pipe, bounds, zero-progress, cursor, slot identity, and generated-v2
    shape are preserved. The checker passes at 4 complete / 4 pending with 29 mutations. Adjacent source-family,
    nested recursion, and 36-family cursor expectations are aligned without changing their cursor assertions.
    The complete Dart gate passes format, analyzer, 276 tests, primary 65x2, and corpus 105/105; canonical CI
    passes Perl primary 65x2 and Phase 0 1,031/1,031 in 635 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.10.3 - admit Dart repeated action results`

  #### Acceptance Checklist

  - [x] **RETRIEVE / INVENTORY DART SEAMS** — Follow the Knowledge Map and neutral contract to the exact Dart
    authored-mode metadata, compiler/runtime action-result flow, descriptor, emitted/generated-v2, loaded/
    reconstructed, trace, primary, corpus, and driver seams before editing behavior.
  - [x] **RED / NEUTRAL CONSUMER** — Add one omission-sensitive contract consumer that proves all eight modes,
    ten special cases where representable, and the required native/composed/artifact/trace/primary/corpus routes;
    demonstrate the current bare-OR family and first-return failures before repair.
  - [x] **CLASSIFY BARE OR AS REPETITION** — Make authored Dart `or` minimum-one repetition and generated
    `rep_acode`/`rep_bcode` without widening generated-source v2 or changing scalar pipe.
  - [x] **COLLECT ACTION ITERATION VALUES** — Preserve action-edge return context through each accepted repeated
    hit, collect one typed value per hit, and retain lifecycle return as immediate whole-rule authority with exact
    bounds, zero progress, cursor, and slot identity.
  - [x] **COMPOSE / ADMIT ONLY DART** — Prove native, loaded, reconstructed, descriptor, emitted/generated direct
    and traced, primary, corpus, and diagnostics through the complete Dart gate; advance only Dart to complete and
    leave Julia/Lua/recurring/public pending.
  - [x] **PROVE / LOCKSTEP / COMMIT** — Pass neutral and adjacent checkers, focused and complete Dart gates,
    mdBook/KM/memory/doctrines, canonical CI where warranted, whitespace, and exact artifact cleanup; synchronize
    task/roadmap/live/changes/notes and commit `.3` before activating Julia `.4`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.10.4`
  Status: `done`
  Goal: Align Julia repeated-choice classification and action-result collection.
  Dependencies: `.9.1.10.3`
  Acceptance: Apply the accepted contract through Julia AST metadata, runtime return flow, descriptor,
    generated-v2 classification/execution, emitted source, loading/reconstruction, trace, primary, and corpus;
    preserve lifecycle authority, bounds, progress, slot/cursor semantics, and pipe scalar choice; add one exact
    neutral admission consumer and pass package, primary, corpus, and fresh emitted-host gates.
  Verification: Activated task-tree-first on 2026-07-20 from clean Dart admission commit `128ead52` at ahead
    256. No Julia AST, runtime, descriptor, generated-source, fixture, driver, or documentation edit preceded
    activation. The exact 15-role consumer and pending-state checker landed before behavior; focused red proved
    authored bare `OR` reported `is_repetition = false`, `rep_min = nothing`, emitted family `or_acode`, and
    returned first-hit scalar `"A"` with one selected slot. Julia now gives bare `Or` minimum one, classifies
    action/blind forms as `rep_acode`/`rep_bcode`, and collects typed action-block or fluent values at the
    action-edge boundary for `*`, `+`, `?`, `OR`, `OR+`, and bounded `OR`. Implicit child dispatch continues after
    capture; later lifecycle returns retain immediate whole-rule authority. Default, AND, blind-result, pipe,
    bounds, zero-progress, cursor, slot identity, and generated-source-v2 shape are preserved. The checker passes
    at 5 complete / 3 pending with 32 mutations. Adjacent generated-family controls use `::|`, nested recursion
    preserves the inner collection as one outer value, and the 36-family cursor matrix distinguishes scalar,
    optional, and repeated results without changing cursor assertions. Focused proof passes 162/162; the complete
    Julia package passes 3,711 tests, primary passes 65x2, corpus passes 105/105, and the fresh isolated emitted
    host proves direct/traced execution plus stale-family rejection. Canonical local CI exits 0 after Perl primary
    65x2 and Phase 0 1,031/1,031 in 638 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.10.4 - admit Julia repeated action results`

  #### Acceptance Checklist

  - [x] **RETRIEVE / INVENTORY JULIA SEAMS** — Follow the Knowledge Map, toolbox, neutral contract, and admitted
    Rust/Dart precedents to the exact Julia authored-mode metadata, compiler/runtime action-result flow,
    descriptor, emitted/generated-v2, loaded/reconstructed, trace, primary, corpus, and driver seams before
    editing behavior.
  - [x] **RED / NEUTRAL CONSUMER** — Add one omission-sensitive contract consumer that proves all eight modes,
    ten special cases where representable, and the required native/composed/artifact/trace/primary/corpus routes;
    demonstrate the current bare-OR family and first-return failures before repair.
  - [x] **CLASSIFY BARE OR AS REPETITION** — Make authored Julia `or` minimum-one repetition and generated
    `rep_acode`/`rep_bcode` without widening generated-source v2 or changing scalar pipe.
  - [x] **COLLECT ACTION ITERATION VALUES** — Preserve action-edge return context through each accepted repeated
    hit, collect one typed value per hit, and retain lifecycle return as immediate whole-rule authority with exact
    bounds, zero progress, cursor, and slot identity.
  - [x] **COMPOSE / ADMIT ONLY JULIA** — Prove native, loaded, reconstructed, descriptor, emitted/generated direct
    and traced, primary, corpus, and diagnostics through the complete Julia gate; advance only Julia to complete
    and leave Lua/recurring/public pending.
  - [x] **PROVE / LOCKSTEP / COMMIT** — Pass neutral and adjacent checkers, focused and complete Julia gates,
    mdBook/KM/memory/doctrines, canonical CI where warranted, whitespace, and exact artifact cleanup; synchronize
    task/roadmap/live/changes/notes and commit `.4` before activating Lua `.5`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.10.5`
  Status: `done`
  Goal: Align PUC Lua and LuaJIT repeated-choice classification and action-result collection.
  Dependencies: `.9.1.10.4`
  Acceptance: One byte-identical Lua consumer applies the accepted contract through AST metadata, runtime return
    flow, descriptor, generated-v2 classification/execution, emitted source, loading/reconstruction, trace,
    primary, and corpus on both ABIs; preserve lifecycle authority, bounds, progress, slot/cursor semantics, pipe
    scalar choice, Lua 5.1 compatibility, and the interpreter chunk-local ceiling; pass both complete ABI gates.
  Verification: Activated task-tree-first on 2026-07-20 from clean Julia admission commit `1c61c2ba` at ahead
    257. No Lua AST, runtime, descriptor, generated-source, fixture, driver, or public-documentation edit preceded
    activation. One byte-identical 15-role consumer and the pending-state checker reproduced both defects before
    behavior repair: focused PUC Lua failed 64 of 174 assertions because bare `Or` lacked repetition metadata,
    emitted `or_acode`, returned first-hit scalars, and stopped after one selected slot. Lua now gives bare `Or`
    minimum one, emits `rep_acode`/`rep_bcode`, and captures copied scalar/null/container action-block or fluent
    returns at the accepted action-edge boundary for `*`, `+`, `?`, `OR`, `OR+`, and bounded `OR`. Implicit child
    dispatch continues; lifecycle returns remain immediate whole-rule authority. Default, AND, blind-result,
    pipe, bounds, zero progress, cursor, slot identity, Lua 5.1 compatibility, chunk-local structure, and
    generated-source-v2 shape remain unchanged. Adjacent generated-family controls now use `:|`, nested cursor
    recursion preserves `[["done"]]`, and the 36-family cursor matrix distinguishes scalar default/pipe,
    one-hit optional, and two-hit explicit repetition without changing its seek/consume assertions. The checker
    passes 8 modes / 10 specials / 6 complete + 2 pending / 35 mutations. The exact consumer passes 175/175 on
    each ABI. The authoritative Lua gate passes every focused suite, 177 package tests per ABI, primary 65x2,
    and corpus 105/105. Knowledge Map regeneration/check passes at 646 facts / 4,760 question keys; memory is
    58/60 lines; task metadata, all four doctrines, mdBook, cross-contract cursor/root/duplicate governance, and
    whitespace pass. Canonical local CI exits 0 after the repeated-result checker and Perl consumer, primary
    65x2, and Phase 0 1,031/1,031 in 654 seconds.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.10.5 - admit Lua repeated action results`

  #### Acceptance Checklist

  - [x] **RETRIEVE / INVENTORY LUA SEAMS** — Follow the Knowledge Map, toolbox, neutral contract, and admitted
    Rust/Dart/Julia precedents to the exact Lua authored-mode metadata, compiler/runtime action-result flow,
    descriptor, emitted/generated-v2, loaded/reconstructed, trace, primary, corpus, and driver seams before
    editing behavior.
  - [x] **RED / NEUTRAL CONSUMER** — Add one byte-identical omission-sensitive contract consumer that proves all
    eight modes, ten special cases where representable, and the required native/composed/artifact/trace/primary/
    corpus routes on PUC Lua and LuaJIT; demonstrate the current bare-OR family and first-return failures before
    repair.
  - [x] **CLASSIFY BARE OR AS REPETITION** — Make authored Lua `Or` minimum-one repetition and generated
    `rep_acode`/`rep_bcode` without widening generated-source v2 or changing scalar pipe.
  - [x] **COLLECT ACTION ITERATION VALUES** — Capture action-block and fluent returns at the action-edge boundary,
    collect one copied typed value per accepted hit, continue implicit child dispatch, and retain lifecycle return
    as immediate whole-rule authority with exact bounds, zero progress, cursor, and slot identity.
  - [x] **COMPOSE / ADMIT ONLY LUA** — Prove native, loaded, reconstructed, descriptor, emitted/generated direct
    and traced, primary, corpus, and diagnostics through both complete ABI gates; advance only dual-ABI Lua to
    complete and leave recurring/public pending.
  - [x] **PROVE / LOCKSTEP / COMMIT** — Pass neutral and adjacent checkers, focused and complete Lua gates,
    mdBook/KM/memory/doctrines, canonical CI where warranted, whitespace, and exact artifact cleanup; synchronize
    task/roadmap/live/changes/notes and commit `.5` before activating recurring `.6`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.10.6`
  Status: `done`
  Goal: Compose recurring six-runtime repeated-choice result parity without another semantic path.
  Dependencies: `.9.1.10.5`
  Acceptance: One omission-sensitive recurring driver composes the neutral checker, Perl/Rust/Dart/Julia/Lua
    consumers, both Lua ABIs, selected five-command default/POSIX primary cases, corpus/generated/descriptor/trace
    support ledgers, exact rollout, mutation inventory, and canonical registration; advance only recurring
    admission after every constituent passes.
  Verification: Activated task-tree-first on 2026-07-20 from clean dual-ABI Lua admission commit `843d40ce` at
    ahead 258; the brief was zero bytes and generated book/Python/native-probe artifacts were absent. No recurring
    driver, checker topology, canonical registration, support-ledger, or documentation edit preceded activation.
    Precedent retrieval found a real canonical topology omission left by `.5`: `tools/run_ci_local.sh` and the
    neutral checker's required-CI list tracked the Julia repeated-result consumer twice but did not track the
    shared Lua consumer. The `.6` RED contract required the missing Lua edge and the absent recurring driver,
    failing exactly on the latter before implementation. One new executable driver now composes the neutral
    checker; exact Perl 10-role, Rust/Dart/Julia 15-role, and shared PUC-Lua/LuaJIT 15-role consumers; the
    contract-projected `success_explicit_repeated_action_results` case over five commands in default and POSIX
    environments; and generated-source/capability/language-coverage ledgers. Canonical CI now tracks the Lua
    source and driver exactly once and exposes the all-toolchain proof behind
    `LINKEDSPEC_RUN_REPEATED_ACTION_RESULT_MATRIX=1`. Governance advances only recurring to 7 complete + 1
    pending and rejects 44 mutations. The disposable recurring proof passes checker 8 modes / 10 specials /
    7+1/44, Perl 10, Rust 3 tests including exact roles, Dart 3 tests, Julia 162 assertions, Lua 175x2, selected
    primary 5x2x1, generated source 80/0/0, capability 80/0/0, and coverage 246/105+1/122; its temporary
    Rust/Lua/Julia build root is removed on exit. Public no-drift remains `.7`.
    Knowledge Map regeneration/check passes at 646 facts / 4,763 question keys; mdBook renders, memory remains
    within its 55-line cap, all four doctrines and every adjacent contract pass, and whitespace is clean.
    Canonical local CI exits 0 after reference primary 66/66 in both environments and Phase 0 1,031/1,031 in
    641 seconds (complete gate 1,505.50 seconds).
  Commit: `FUTURE-PARITY-BACKLOG.9.1.10.6 - compose repeated action result proof`

  #### Acceptance Checklist

  - [x] **RETRIEVE / INVENTORY RECURRING PRECEDENTS** — Follow the Knowledge Map and admitted root/cursor/
    duplicate/logical drivers to the exact omission-sensitive composition, selected-primary, support-ledger,
    canonical-registration, and rollout seams before editing.
  - [x] **ADD ONE RECURRING DRIVER** — Compose the neutral checker; Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT
    consumers; and no independent semantic evaluator or duplicate behavior path.
  - [x] **LOCK SELECTED PRIMARY / SUPPORT PROOF** — Run the governed repeated-action primary case across five
    commands and default/POSIX environments, then require exact corpus/generated/descriptor/trace support ledgers.
  - [x] **OMISSION-SENSITIVE GOVERNANCE** — Require each runtime/ABI/primary/support constituent exactly once,
    reject missing, duplicate, reordered, gated, or premature-rollout mutations, and advance only recurring.
  - [x] **REGISTER / COMPOSE CANONICALLY** — Add the recurring gate to canonical CI using the repository's
    explicit optional multi-toolchain convention while keeping the core-only default independent of SDKs.
  - [x] **PROVE / LOCKSTEP / COMMIT** — Pass every constituent and exact checker mutation, focused and complete
    backend gates where warranted, mdBook/KM/memory/doctrines/canonical CI, whitespace, and exact cleanup;
    synchronize task/roadmap/live/changes/notes and commit `.6` before activating public closeout `.7`.

- ID: `FUTURE-PARITY-BACKLOG.9.1.10.7`
  Status: `done`
  Goal: Close repeated-choice result parity with public no-drift and exact semantic-parent status.
  Dependencies: `.9.1.10.6`
  Acceptance: README, guides, mdBook, API/backend companions, examples, architecture, capability/status ledgers,
    ADR/Knowledge Map, and recurring scanners describe only the implemented per-hit collection/scalar-pipe rule;
    reject stale current first-scalar and bare-OR-nonrepetition claims; close `.9.1.1`, `.9.1.10`, `.9.1`, and `.9`
    only when no child remains, then pass canonical CI, cleanup, memory/doctrines, and commit workflow.
  Verification: Activated task-tree-first on 2026-07-20 from clean recurring-proof commit `9b0c8007` at ahead
    259; `git_message_brief.txt` was zero bytes and generated book/Python/recurring-driver artifacts were absent.
    No public-contract topology, public document, ADR, parent status, or closure edit preceded activation. The
    public contract was defined before synchronization and failed RED on the first missing guide marker. It now
    requires 25 current documents, denies 12 stale claims, locks exact `.9.1.1`/`.9.1.10`/`.9.1`/`.9` closure and
    `.10.1` handoff, advances public only, and rejects 54 mutations at 8 complete + 0 pending. Exact closure
    inventory found `.9.1.1` stale-active after every child completed; adjacent cursor governance then caught the
    new contract's incidental retired-option token inside a referenced mdBook filename, whose decoded path remains
    exact without expanding the closed 75-file inventory. The recurring driver passes Perl 10 roles, Rust/Dart/
    Julia exact admissions, Lua 175x2, primary 5x2x1, and all three support ledgers. Canonical local CI exits 0
    with reference primary 66x2, Phase 0 1,031/1,031 in 645 seconds, and the enabled recurring driver. Knowledge
    Map 646/4,763, mdBook, memory, task metadata, all four doctrines, adjacent contracts, JSON/Python, whitespace,
    and exact generated cleanup pass. No parser/compiler/runtime/descriptor/generated/CLI/fixture behavior changes.
  Commit: `FUTURE-PARITY-BACKLOG.9.1.10.7 - close repeated action result parity`

  #### Acceptance Checklist

  - [x] **RETRIEVE / INVENTORY PUBLIC PRECEDENTS** — Follow the Knowledge Map and closed cursor/root/duplicate
    public-contract checkers to the exact required-document, forbidden-current-claim, closure, and mutation seams.
  - [x] **DEFINE PUBLIC NO-DRIFT FIRST** — Add an omission-sensitive public contract before broad synchronization;
    require every current public/API/backend/mdBook/roadmap/status/ADR/KM surface and exact stale-claim denials.
  - [x] **SYNC EVERY PUBLIC PROJECTION** — Align README, guides, API/backend companions, architecture/status,
    capability/CLI guidance, ADR/index, Knowledge Map, and mdBook examples with only the implemented collection/
    scalar-pipe rule, recurring driver, 66-case manifest, and closed rollout.
  - [x] **LOCK EXACT CLOSURE** — Advance public only after recurring proof passes; close `.9.1.1`, `.9.1.10`, `.9.1`,
    and `.9` only if their complete child inventories permit it, and point the frontier to the next roadmap-aligned
    leaf.
  - [x] **REJECT OMISSION / STALE CLAIMS** — Reject missing documents/markers, stale first-scalar or bare-OR
    non-repetition claims, pending-backend/recurring/public claims, premature parent closure, and next-owner drift.
  - [x] **PROVE / LOCKSTEP / COMMIT** — Pass the closed checker, recurring driver, mdBook/KM/memory/doctrines,
    canonical CI, whitespace, exact cleanup, and commit workflow; hand off clean before any next pivot.

<!-- Source ranges and their immutable migration digest are recorded in docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl. -->
