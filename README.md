# LinkedSpec
LinkedSpec is a progressive extraction parser DSL for fast parser prototyping with strong support for recursion, nested constructs, and staged coarse-to-fine parsing.

This `README.md` is the **single entry point** to the project.

## Documentation Layers
- `docs/linkedspec-book/`
  - Public-facing book for the world outside the repo.
  - This is where LinkedSpec should explain what it does, how it works, and why it is designed the way it is.
- repo-root working docs
  - `USER_GUIDE.md`, `ARCHITECTURE_STATE.md`, `ROADMAP.md`, and related files remain valuable repo-native working references.
- task-tree tracking
  - `docs/TASK_TREE.md`, `docs/TASK_TREE_README.md`, and `docs/tasks/*.md` are the task-tree workflow: recursive decomposition, current frontier, PNT selection, blockers, decisions, and completion evidence for top-level tasks.
- durable memory architecture
  - `MEMORY_ARCHITECTURE.md` is the harness-agnostic standard for how agent memory survives session loss, crash, machine loss, and a switch of AI model/harness. It defines four layers — A: the bounded `MEMORY.md` resume pointer; B: the task-trees above; C: `docs/decisions/` decision records; D: git history — plus mechanical enforcement (`scripts/check_memory_architecture.sh`, `.githooks/`, and the local CI gate). Any agent, in any harness, starts from the tool-neutral bootstrap pointers (`AGENTS.md` and its mirrors `CLAUDE.md` / `.cursorrules` / `.github/copilot-instructions.md`), which route here.
  - `docs/decisions/` (layer C) holds durable cross-cutting facts/decisions as dated ADR-style records, indexed by `docs/decisions/INDEX.md`.
  - `KNOWLEDGE_MAP.md` is the composed **retrieval** layer: a machine-derived, question-keyed index over small front-mattered fact cards in `docs/knowledge/`, so a future session finds an already-logged structural/causal fact instead of re-deriving it. The standard + tooling live in the vendored `knowledge-map/` bundle (`knowledge-map/KNOWLEDGE_MAP_ARCHITECTURE.md`); the map is auto-generated and gated — never hand-edited.
- continuity docs
  - `CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`, and `COMMIT.md` are internal execution/continuity docs.
  - `MEMORY.md` is the bounded, overwrite-only **resume pointer** (memory layer A): current state and the single next action only — its history lives in git and the task-trees, not in the file.
  - They exist for crash recovery, session handoff, and implementation continuity, not as the main public narrative.

## Project Objective
- Provide a robust, trustworthy parser-prototyping platform that is intentionally different from strict EBNF-centric tooling.
- Preserve LinkedSpec strengths (recursive parsing + multi-pass extraction workflows).
- Evolve `.spec` toward language-agnostic action semantics over time.
- Model scalar, array, harray/hash, and codeblock as the four portable value kinds. For callables whose signature
  accepts a final codeblock, the language direction is one canonical call behind equivalent
  `call(args) { block }` and `call(args, { block })` spellings; current generic parity is tracked by
  `FUTURE-PARITY-BACKLOG.11`.
- Provide native in-memory LinkedSpec libraries for Perl, Rust, Dart, Julia, Lua, and later host languages. Applications
  must be able to parse, compile, and execute without a required CLI or subprocess; variant CLIs are thin adapters
  whose distinct executable names expose one identical user-facing command contract.

## Fast Ramp-Up Documentation Map
Read these in order for fastest onboarding:

1. `README.md` (this file)
   - Project objective, navigation, and key paths.
   - Then read `MEMORY_ARCHITECTURE.md` — the durable memory system (how continuity survives session/model/harness loss; **mandatory and mechanically enforced**) — and resume from `MEMORY.md`.
2. `docs/linkedspec-book/`
   - Public-facing book for LinkedSpec.
   - Start here when you want the project explained as a coherent system rather than as a working repo.
3. `ROADMAP.md`
   - Strategy, phases, priorities, and current execution direction.
4. `docs/TASK_TREE.md`
   - Task-tree workflow: active trees, current frontier, PNT selection rules.
   - Read this when resuming work to see what was in flight and pick the next leaf.
5. `USER_GUIDE.md`
   - How to write and use `.spec` grammars and parser workflows.
   - Includes the plain paragraph-based mental model for `.spec` file structure.
6. `ARCHITECTURE_STATE.md`
   - Live architectural reading of the current codebase shape.
   - Use this to re-enter the project with the current implementation model and main hotspots in mind.
7. `DEVELOPMENT_NOTES.md`
   - Architecture rationale and implementation decisions.
8. `CHANGES.md`
   - Technical change history, validation records, and migration slices.
9. `MEMORY.md`
   - Bounded, overwrite-only **resume pointer** (memory layer A): current commit, the active task-tree frontier leaf, the single next action, and any in-flight uncommitted work. History lives in git, not here.
10. `LIVE_ACHIEVEMENT_STATUS.md`
   - Current batch/workflow status and latest completed slice direction.
11. `COMMIT.md`
   - Commit workflow and commit hygiene conventions.

## Project File/Path Map
Top-level directories and files:

- `perl/`
  - Core implementation and runtime modules.
  - Primary native in-memory entrypoint: `perl/LinkedSpec.pm` (`LinkedSpec::Get(...)`).
  - Supporting core modules include `perl/LinkedRE.pm` and `perl/PathSearch.pm`.
- `rust/`
  - Native Rust backend workspace. `linkedspec-core` exposes `.spec` parsing/compilation and
    `linkedspec-runtime::engine::Engine` executes compiled specs directly over Rust string/result values.
  - `linkedspec-runtime/src/bin/linkedspec-rust.rs` is the Rust primary command. Its exact argument/help/loading
    boundary, direct-result execution, canonical trace, and recurring default/POSIX gate are closed.
- `specs/`
  - LinkedSpec grammar/spec definitions (`*.spec`).
- `t/`
  - Test suites.
  - Primary regression gate: `t/phase0_regression.t`.
- `tools/`
  - Project tooling and diagnostics helpers.
  - Examples: `tools/inspect_spec_codegen.pl`, `tools/run_ci_local.sh`.
- `cli_conformance/`
  - Backend-neutral primary CLI manifest, fixture inputs, and exact expected bytes. The reusable runner accepts
    arbitrary backend command arrays and executes every case in an isolated workspace.
- `capability_conformance/`
  - Machine-readable current-capability census across Perl, Rust, Dart, and Julia. It distinguishes implementation
    gaps from proof gaps, points every non-pass state at a task-tree owner, and excludes only explicitly legacy or
    future surfaces.
- `bin/`
  - Utility/command scripts.
  - `bin/linkedspec`: Perl reference compile/run CLI with discoverable trace flags.
- `dart/`
  - Native Dart backend package; `parseSpec(...)`, `compileSpec(...)`, and `LinkedSpecRuntimeEngine` are the
    primary in-process surface.
  - Current state: scoped interpreter-first milestone complete: package metadata, public library entrypoint,
    Dart-specific CLI entrypoint, manifest/corpus
    IO validation/execution, source-level AST/data types, staged parse-job sidecars, core `.spec` rule parser,
    frontend validation, spec-returned function-definition projection, typed ActionIR/helper-action AST
    parsing, ActionIR contract resolution, user-function registry, staged function-body registry dispatch,
    compiled-spec state, runtime regex/match state, rule-dispatch interpreter, staged user-function runtime
    execution, and 99-fixture corpus output parity under `DART-BACKEND-PARITY`.
- `julia/`
  - Native Julia backend package; `parse_spec(...)`, `compile_spec(...)`, `runtime_parse(...)`, and
    `runtime_execute(...)` are the primary in-process surface.
  - Current state: package/corpus scaffold, source frontend, typed ActionIR and contracts, user-function registry,
    compiled-spec state, and runtime seek/consume regex matching with capture/offset projection, cursor state,
    entry/local match registers, and zero-progress detection. First compiled-rule dispatch now executes rule modes,
    lifecycle flow, action/blind children, `retv`, explicit returns, and recursion/progress guards. Core
    scalar/array/hash stores, typed snapshots, structural assignments/access, checked nested writes, and
    entry/local capture maps/positions are implemented. Current string/scalar and numeric helpers, aliases/symbol
    callees, invalid-input boundaries, and compatible receiver chains are implemented too. Copied array pipelines,
    string/regex/split bridges, flattening, reducer terminals, and statement-only end mutations are now green.
    Copied hash views/transforms, explicit hash splicing, direct assignment, and statement-only named set-key
    mutation are now green. Expression-valued blocks, attached/marker/inline controls, helper/receiver with-blocks,
    and scoped hash/array tree callbacks are now green too. Helper/value no-drift is closed. Explicit cursor
    save/restore, entry/local rewinds, character-based cursor/input helpers, and non-consuming boundary capture
    are green. Runtime diagnostics plus ordered trace levels, environment/config controls, structured events,
    stdout/route/mirror sinks, and output-preserving traced entrypoints are green. Rule/regex/dispatch/lifecycle/
    recursion/cursor/boundary instrumentation is green, and `.4.5.4` closes diagnostics/trace no-drift. The minimal
    staged function-body registry resolves the built-in ActionIR-body provider, executes jobs in stable order, and
    stitches `body_ast`. Registered exact-arity functions now execute before helper fallback with eager caller
    arguments, fresh typed local stores, receiver continuation, standalone result drop, and recursion diagnostics.
    Neutral staged function payload/job/AST and descriptor metadata shapes are locked through the same executable
    compiled state. Controlled library corpus execution now composes manifest validation, parse/compile/runtime,
    one-level wrapped structural comparison, optional trace capture, structured diagnostics, and all-fixture
    failure reporting. The full suite passes with 715 assertions and status `runtime-controlled-corpus`. `.6.2.0`
    splits the 99-fixture rollout into bounded selection/reporting plus starter, middle, shipped-spec, and
    spec-defined function-shell batches. `.6.2.1` adds ordered named/offset/limit selection plus bounded runner
    PASS/FAIL reporting. `.6.2.2` proves starter fixtures 0–39 green at 40/40 without a production correction;
    `.6.2.3` proves the surrounding middle non-function windows green at 25/25 while routing three top-level
    function fixtures. Full tests pass with 757 assertions and status `runtime-corpus-middle`. `.6.2.4.0` measures
    shipped-spec/parser-smoke fixtures 68–98 at 10/31 and splits the failure families. `.6.2.4.1` adds anonymous
    capture-boundary execution and closes three hlink cases. `.6.2.4.2.1` adds eager logical helpers, closes three
    portmap cases plus tablegrep. `.6.2.4.2.3` normalizes helper regex flags and closes portmap constant.
    `.6.2.4.2.2` adds trace-routed, parse-result-neutral diagnostic output and advances simenv/history past
    unsupported `print`. `.6.2.4.3` scopes explicit aggregate resets per recursive rule invocation and closes all
    three recursive top-rule cases. Full tests pass with 785 assertions, status is
    `runtime-corpus-recursive-rule-scope` at that boundary. `.6.2.4.4` adds all four action-edge child-push forms,
    closes the four spec.spec smokes, and routes EBNF quote mutation. Full tests pass with 793 assertions, status is
    `runtime-corpus-action-edge-child-push` at that boundary. `.6.2.4.5.1` adds terminating `exit_now(...)` with
    explicit numeric status, default status `1`, and structured runtime attribution. Full tests pass with 801
    assertions and status `runtime-corpus-exit-now` at that boundary. `.6.2.4.5.2` adds statement regex mutation,
    closes both EBNF, both lib_reader, and simenv fixtures, and preserves pure numeric slicing. Full tests pass with
    808 assertions at that boundary. `.6.2.4.5.3` mirrors public-parser leading blank/comment skipping and closes
    history without weakening indexed reads. `.6.2.4.6` now permanently locks the complete shipped window at
    31/31 exact outputs. `.6.2.5` then executes `specs/user_function_definition.spec` over top-level `fn` source,
    feeds its neutral nodes through the existing staged body parser, and closes all three routed fixtures without
    a raw Julia scanner. `.6.3` now locks the complete manifest as one ordered 99/99 exact-output gate and enables
    unbounded CLI execution. Full tests pass with 840 assertions and status is `runtime-corpus-full`. `.6.4` adds
    focused optional-SDK verification and `.7.1` closes public usage/status/limitation docs. `.7.2` defers
    generated Julia source to the future split source-emitter lane. `.7.3.0` then proves the implemented CLIs are
    not interface-equivalent (Perl parser CLI, Dart/Julia corpus/status CLIs, no Rust binary) and splits repair.
    `.7.3.1` ratifies ADR `0023`: complete user-observable capability identity plus one exact primary CLI contract.
    `.7.3.2.0` splits Julia alignment into trace, arguments/IO, execution/JSON, error/routing, and conformance;
    `.7.3.2.1` now propagates the existing emitter through compile/parser/function-shell/staged phases with 868
    assertions and 99/99 green. `.7.3.2.2` locks exact arguments, subcommand/positional rejection, deterministic
    named resolution, and source/input loading. `.7.3.2.3` now executes rule/function requests through the native
    pipeline and emits direct recursively key-sorted JSON. `.7.3.2.4` now locks phase-ordered failure stderr,
    exit 1/2, and stdout/route/mirror/file/reset/emoji behavior. `.7.3.2.5` adds nine direct process families and
    advances the precise local status to `runtime-corpus-primary-cli` at 1,017 assertions plus 99/99. `.7.3.3`
    closes outer no-drift, but the Julia tree remains active/delegated—not complete—through global CLI identity,
    capability census, and generated-source owners `.1.5`/`.1.6`/`.3`. `.1.5.1.0` now splits the neutral fixture/
    Perl reference work after direct probes found implicit option aliases, ignored positionals, environment-driven
    parsing, and failure trace on stdout. `.1.5.1.1` now adds the reusable byte-exact harness/help baseline;
    `.1.5.1.5` now closes canonical trace at 53/53 exact cases with local-gate integration. Its signoff exposed a
    pre-existing UTF-8 argv/JSON mojibake boundary; `.1.5.1.6` closes that repair. Perl/Rust/Dart now pass 61/61.
    Julia `.1.5.4.1` renders exact help, validates strict UTF-8 file bytes, and emits phase-only primary errors.
    `.1.5.4.2` adds the independent canonical trace while preserving native rich trace. Current proof is 1,023
    assertions plus 99/99 and 61/61 default/POSIX. `.1.5.4.3` closes exact four-backend CLI identity with one
    recurring warmed 4x2x61 driver; capability census `.1.6` is active and generated-source parity remains `.3`.
- `.github/workflows/`
  - GitHub Actions automation.
  - Primary CI workflow: `.github/workflows/ci.yml`.
  - Hosted GitHub Actions CI is currently disabled to preserve account Actions minutes.
- `plugin/`, `conf/`, `tablescript/`, `ebnf/`
  - Corpus and real-project inputs used in regression/integration flows.

Top-level project docs:
- `README.md`
- `MEMORY_ARCHITECTURE.md`
- `docs/linkedspec-book/`
- `ROADMAP.md`
- `USER_GUIDE.md`
- `ARCHITECTURE_STATE.md`
- `DEVELOPMENT_NOTES.md`
- `CHANGES.md`
- `MEMORY.md`
- `LIVE_ACHIEVEMENT_STATUS.md`
- `COMMIT.md`
- `docs/decisions/` (durable decision records, layer C)
- `KNOWLEDGE_MAP.md` (derived retrieval index) + `docs/knowledge/` (fact cards) + `knowledge-map/` (the bundle/standard + tooling)
- `DOCTRINE_ENFORCEMENT.md` (the doctrine-enforcement standard — 4th portable architecture) + `scripts/check_doctrines.sh` (the registry driver that runs every `scripts/check_*.sh`)
- `TOOLBOX.md` — LinkedSpec's own diagnostic/debug toolbox (the probes, the `LINKEDSPEC_TRACE_LEVEL` trace framework, the `tools/` scripts, the gates); reach for it FIRST when diagnosing
- `AGENTS.md` + mirrors (`CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`) — tool-neutral agent bootstrap pointers

## Local CI
- Run `bash tools/run_ci_local.sh` from the repo root to execute the canonical regression gate.
- Run `perl tools/check_capability_conformance.pl` to validate the current 15-capability backend census, evidence
  paths, and gap ownership. The current audit records 47 pass, five partial-proof, and eight gap backend states;
  `.1.6.1` through `.1.6.5` own non-codegen work, while generated source remains top-level `.3`.
- Run `perl tools/check_language_capability_coverage.pl --report` for the current Dart/Julia ActionIR call-name
  inventory against the mdBook and neutral corpus. The strict form intentionally remains red until `.1.6.1.2`;
  `.1.6.1.1` repaired universal Perl newline splitting and `.1.6.1.2.1` repaired the narrower generated terminator
  after newline `endswitch()`. A diagnostic 105-case run then passed 100/105 on each non-reference backend and
  split pure, position, marker-control, and capture/mark repairs under active `.1.6.1.2.2`; the mandatory corpus
  remains at its green 99-case boundary until final admission. Rust, Dart, and Julia pure-value and
  empty-local-match and marker-control children are closed; active `.2.2.4.1` completes Rust capture/mark semantics.
- Run the current backend-neutral primary CLI fixture baseline with `PERL5LIB= perl
  tools/run_cli_conformance.pl --display-command 'perl bin/linkedspec' -- perl -I{{REPO_ROOT}}/perl
  {{REPO_ROOT}}/bin/linkedspec`. The manifest locks two help, 20 usage, seven baseline success, four baseline
  failure, 20 canonical trace, and eight strict UTF-8 behavior cases. Perl passes all 61 current cases. ADR `0025`
  defines Unicode scalar text encoded as strict preserved UTF-8—not Unicode as synonymous with UTF-8. `.1.5.1.6.2`
  now decodes Perl argv/files strictly, preserves BOM/code points/newlines, rejects invalid files by phase, and
  emits recursive canonical JSON once; `.6.3` closes Perl as the 61-case reference. Rust `.1.5.2.1` adds
  `linkedspec-rust`, `.1.5.2.2` adds reusable entry/mode/direct-result execution, and `.1.5.2.3` adds the exact
  canonical trace projection. `.1.5.2.4` closes Rust at 61/61 in default/POSIX environments and adds
  `tools/run_rust_local.sh`; Dart and Julia are also 61/61 default/POSIX. Run
  `bash tools/run_primary_cli_matrix.sh` for one command that builds/prepares/warms all four backends and proves
  the unchanged 61-case suite under both environments. Exact CLI lane `.1.5` is closed; capability census `.1.6`
  is active.
- Deep semantic introspection plus MCP is parked under `FUTURE-PARITY-BACKLOG.10.1`: native backend APIs own one
  versioned semantic model, while MCP remains a thin transport rather than a backend-specific source of truth.
- Run `bash tools/run_dart_local.sh` from the repo root for the focused Dart backend gate: format, analyze, full
  Dart tests, CLI help, and the 99-fixture corpus execution.
- Run `bash tools/run_rust_local.sh` from the repo root for Rust formatting, the full runtime package, and both
  61-case primary-command environments.
- Run `bash tools/run_julia_local.sh` from the repo root for the focused Julia backend gate: package tests, CLI
  checks, and the 99-fixture corpus execution. Override the executable/depot with `LINKEDSPEC_JULIA_CMD` and
  `LINKEDSPEC_JULIA_DEPOT_PATH` when needed.
- The canonical local gate stays core-only by default so it does not depend on Rust, Dart, or Julia toolchains. To
  opt into backend checks, set `LINKEDSPEC_RUN_RUST=1`, `LINKEDSPEC_RUN_DART=1`, and/or `LINKEDSPEC_RUN_JULIA=1` before
  `bash tools/run_ci_local.sh`. Set `LINKEDSPEC_RUN_CLI_MATRIX=1` to run the complete warmed four-backend primary
  CLI matrix from that gate.
- `.github/workflows/ci.yml` remains tracked and delegates to that shared script, but hosted automatic GitHub Actions runs are disabled until intentionally re-enabled.

## Maintenance Policy for README
- `README.md` must remain the single project entry point.
- Update `README.md` whenever project objective, onboarding flow, key doc links, or key path layout changes.
- `README.md` does **not** need to be updated on every commit—only when such updates are needed.
- Keep `ARCHITECTURE_STATE.md` in the doc map when it remains the live architecture snapshot for future sessions.

## Git Version-Control Status
- `README.md` is intended to remain git-tracked at all times.

Read SESSION_BOOTSTRAP.md and start from there.
