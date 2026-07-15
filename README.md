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
- Keep `.spec` authoring structural: small readable regexes identify leaf or entry/exit boundaries; linked rules
  own deep recursion. Progressive parsing isolates text relative to cursor anchors and composes loaded spec
  parsers during a parse; staged parsing refines selected fields after an AST level returns. ADR `0012` and the
  function-body prototype provide the current base, while complete authoring guidance and general multi-spec
  execution remain owned by `FUTURE-PARITY-BACKLOG.14.1-.14.4` rather than being overstated as fully shipped.
- Evolve `.spec` toward language-agnostic action semantics over time.
- Model scalar, array, harray/hash, and codeblock as the four portable value kinds. For callables whose signature
  accepts a final codeblock, the language direction is one canonical call behind equivalent
  `call(args) { block }` and contextual final-block spellings. ADR `0031` adopts callable literals as
  `{|args| block }`, invoked by `cb(args)`, with dynamic caller context and no lexical capture in version 1.
  `linkedspec-callable-codeblock-v1` now locks that accepted design. Perl preserves typed literal records and
  executes `cb(args)` with dynamic caller state, temporary copied/restored parameters, block-local return,
  chaining/discard, static precedence, and typed failures. ADR `0032` now declares a final contextual slot as
  `name: codeblock`, with no nested argument list because the supplied `{|params| ...}` value owns its signature.
  Perl now preserves `callback: codeblock` in function/staged metadata and normalizes attached and parenthesized
  contextual blocks for declared helpers, user functions, and receiver methods to one typed zero-argument
  `codeblock_argument`; explicit `{|params| ...}` values retain their own signatures and harrays are not promoted.
  Perl closeout `.11.3.4` is complete; the cross-backend feature is not yet current. Selector retirement is complete:
  `.12.1` removed spec-facing `array(name)` / `hash(name)` selector and mutation semantics. Inventory
  `.12.1.0` found 600 exact forms across 82 tracked specs (corrected from a boundary-less 651 count) and split neutral contract, five-backend enablement,
  source migration, hard rejection, and no-drift. `.12.1.1` now adopts the executable replacement contract;
  Perl `.12.1.2`, Rust `.12.1.3`, Dart `.12.1.4`, Julia `.12.1.5`, and Lua `.12.1.6` now execute bare typed
  mutations, results, chaining, diagnostics, and static-rule precedence. All five backends are enabled; shipped
  source migration `.12.1.7.1-.3` has removed all 600 exact selectors from the 82 tracked `.spec` files and all
  1,356 positive occurrences from embedded test/tool/backend sources. Perl `.12.1.8.1`, Rust `.12.1.8.2`, Dart
  `.12.1.8.3`, Julia `.12.1.8.4`, and Lua `.12.1.8.5` reject exact selectors before execution with the portable
  `aggregate_selector_removed` fields. Cross-variant `.12.1.8.6` locks those boundaries and zero runtime selector
  compatibility in canonical CI. `.12.1.9` admitted the root/capability/mdBook surface; follow-up `.12.1.10`
  removed 14 stale positive forms from the Rust, Dart, Julia, and Lua READMEs and expanded the recurring public
  checker to all 56 files then present; the discovered public surface is now 57 files after the structured-format
  architecture page, still with zero current examples. Current authoring uses bare typed bindings, for example
  `set(items, [])`, `push(items, value)`, and `copy(items)`. Lua numeric canonical/alias/symbol calls, number
  receivers, strict aggregate reducers, ordered copied array construction, explicit flat splicing/concatenation,
  copied selection/order/membership/uniqueness, transform/join/PCRE2 pipelines, typed mutation/child-result flow,
  and exact copied tagged-record construction pass 99/99 on both ABIs. All 34 non-callback array names and six
  numeric terminals are closed under `.4.3.4`; all 13 ordinary harray names are closed under `.4.3.5`, and the
  three tree-callback names close under parent `.4.3.6`. Audit `.4.3.6.0` splits eager
  blocks, inline and statement controls, contextual built-ins/`with`, and deterministic tree callbacks before
  behavior code. Eager blocks, lazy inline `if`/`switch`, attached/marker if and switch statements, and attached
  `while` pass through `.4.3.6.3.3`: only selected branches execute, nested marker
  boundaries and empty branches are exact, block-local return is preserved, switch subjects run once, bare case
  labels stay literal, loop conditions re-evaluate against body state, and malformed/runaway controls are typed.
  `.4.3.6.4` now adds copied final-codeblock metadata and executes attached/parenthesized helper/receiver `with`
  through one cleanup-safe uniform `value` scope. Optional values and receivers evaluate first; aggregate inputs
  and results are isolated; exact prior/absent bindings restore after success, local return, and error; compatible
  receiver chains continue; and malformed final kinds/counts stay typed. Both Lua ABIs pass 112/112. Scoped
  callback work is split at `.4.3.6.5.1.0`: reference authored-value precedence repair `.4.3.6.5.1.1` is done;
  `.4.3.6.5.1.2` adds atomic copied/restored callback frames plus sorted harray walk/map/reduce at 113/113;
  `.4.3.6.5.2` shares that dispatcher with zero-based array-root traversal, recurses only through the receiver's
  own root kind, and raises both ABIs to 114/114. No-drift/dependency handoff `.4.3.6.6` closes the parent and
  advances capture/mark/input/cursor helpers `.4.3.7`. Audit `.4.3.7.0` splits those mechanisms and finds seven
  documented current mark helpers outside every governed backend inventory; `FUTURE-PARITY-BACKLOG.17` owns the
  neutral/five-backend correction and independent gate hardening. Lua `.17.4` consumes the exact contract on PUC
  Lua and LuaJIT at 119/119; `.17.5` admits all seven at 246 shared names and independently checks all 122 public
  Perl contracts. Lua `.4.3.7.3` then executes the governed named writers, stable/advancing spans, two-mark reads,
  and anonymous/named bridges through that same store at 120/120 on PUC Lua and LuaJIT. Missing/reversed spans are
  neutral, public positions/lengths are character-based, and `capture_take()` versus `capture_take(name)` retains
  the anonymous/named overload split. Lua `.4.3.7.4` now compiles split/named-mark rule members into typed
  preceding-slot events and executes them after that slot's actions at 121/121 on PUC Lua and LuaJIT;
  exhaustive `.4.3.7.6` proves exact 62/62 call agreement across contracts/runtime/focused execution sources plus
  four placement-marker spellings and closes parent `.4.3.7`. Lua `.4.3.8` now evaluates `print`/`say`/
  `print_each` eagerly and delivers ordered Unicode-safe typed events through a per-parse caller-owned sink while
  staying quiet by default and preserving parse values; both ABIs pass 122/122. Exhaustive audit `.4.3.9.0`
  probes all 246 names: 230 reach an owner, thirteen are intentional statement/receiver-only surfaces, and the
  exact missing family is eager `and`/`or`/`not`. That repair first passed 123/123; permanent `.4.3.9.2` now drives
  all 246 admitted names through parse/compile/runtime, reports exact 233 function-form owners plus thirteen
  documented structural/receiver-only forms, focuses direct `call(rule)`, and publishes
  `runtime-helper-value-control`. Both ABIs pass 125/125, parent `.4.3` is closed, and diagnostics/trace `.4.4` is
  now split into structured runtime failures `.1`, controls/sinks `.2`, runtime events `.3`, and closeout `.4`;
  `.4.4.1` adds neutral typed diagnostics, optional spec identity, deepest-rule preservation, exact JSON, and
  unchanged success output at 126/126 on both ABIs. `.4.4.2` now adds typed ordered trace levels/config/events,
  documented environment controls, caller-owned stdout/route/mirror sinks with reset/append, and result-neutral
  direct/config-wrapper parse scopes at 128/128. `.4.4.3` adds rule/regex/dispatch/recursion/lifecycle/cursor/
  boundary/mark-capture events at 129/129. No-drift `.4.4.4` closes the scoped runtime diagnostics/trace parent.
  Planning `.5.1.0` separates staged body dispatch, fixed/variadic runtime, contextual-codeblock metadata/runtime,
  and closeout. Minimal staged dispatch `.5.1.1` now validates/stable-sorts exact jobs, resolves the governed
  `actionir-body.spec` provider/digest/cache identity, parses exact ActionIR bodies, and immutably stitches
  `body_ast`; both ABIs pass 130/130 and public status is `runtime-staged-registry`. Fixed-v1 runtime `.5.1.2` is
  active. Full frontend/compiler/function/staged propagation remains `.5.3`.
  Existing diagnostic-output drift is owned by `FUTURE-PARITY-BACKLOG.5.1`; Perl logical keyword-lowering plus
  five-backend truthiness/arity normalization is separately owned by `.5.2` before structured-format execution.
  Generated Lua preservation/execution remains `.8.1-.8.4`. ADR
  `0034` also adopts a dependency-gated post-parity program: after Perl/Rust/Dart/Julia/Lua reach full parity, 91
  cataloged Unicode structured-text rows will drive reusable `.spec` feature evolution and accurate, measured
  text-to-AST parsers. Each composed format `.spec` graph will be the sole parser source, dynamically compiled for
  immediate use on every backend; no format implementation has started. ADR `0035` additionally makes terse,
  readable, and highly expressive authoring a hard design constraint: remove redundant ceremony, preserve
  semantic signal and typed diagnostics, and prefer small orthogonal mechanisms over format-specific escapes.
  Uniform binding is the positive precedent; recursive traversal keeps informative `_leaves` names rather than
  gaining ambiguous `walk`/`map`/`reduce` aliases. ADR `0036` separately plans a post-current-parity extension:
  nested assignments may create only unambiguous missing intermediates while reads stay pure, existing wrong-kind
  values are never coerced, and arrays remain dense. Its only v1 bang-method candidate is receiver-mutating
  `map_leaves!`; that spelling is not current behavior and must land through neutral plus five-backend proof.
  ADR `0037` makes end-to-end observability a future format-parser readiness gate: correlate `.spec` graph
  resolution/staging/cache/compilation with runtime rule/branch/position/AST behavior, add exact emission-only
  rule-label filters, bound high-volume payloads, and prove traced/untraced identity across all current backends.
  Lua's current runtime trace is complete; its already-owned full native-pipeline propagation remains `.5.3`.
  ADR `0038` adds a separate optional, non-blocking acceleration horizon after a realistic dynamic format parser
  is correct and measured. Backend-native artifacts must remain fingerprinted disposable derivatives of normalized
  `.spec` state, exactly equivalent and objectively faster after build/load and break-even costs; the dynamic
  parser remains primary, oracle, and fallback, and Perl acceleration is not required.
  ADR `0033` and
  `FUTURE-PARITY-BACKLOG.16` align narrow zero-argument aliases. Neutral contract `.16.1` now locks six standalone
  markers, final-only receiver omission, exclusions, and arity delegation. Calibration `.16.2.0` corrects its
  required-argument example. Perl `.16.2.1`, Rust `.16.3`, Dart `.16.4`, Julia `.16.5`, and Lua `.16.6` now consume
  the aliases through typed AST plus exact native execution; Rust also proves serialized/emitted-source paths,
  Dart and Julia prove emitted-state reconstruction, and Lua proves serialized SpecFile state on both ABIs.
  Public/capability closeout `.16.7` now admits the current syntax at census 64/0/0 and adds one recurring
  five-backend/two-Lua-ABI proof command. Parent `.16` is complete. Rust, Dart, Julia, and Lua's pre-existing `.contains()`
  missing-argument outcomes remain a helper-semantics gap owned by `.5`, not a syntax
  exception.
  Lua generated-source preservation remains with its existing `.8.1-.8.4` emitter/admission owner.
  Parenthesis-free condition-bearing `if`/`while` headers remain excluded. General user-function final
  `callback: codeblock` declaration/execution remains `.5.1`, and explicit callable codeblock values remain future
  `.11.7`. Copied harray construction,
  runtime-kind `flat`, direct/
  receiver `flat_hash`, ordinary nested-map preservation, explicit splicing, lexical key/value views, count, and
  null-aware membership pass through `.4.3.5.2`; copied merge/set/rename/drop/pick values and receiver chains pass
  103/103 through the `.4.3.5.5` public/no-drift closeout before eager blocks and controls raise the gate to
  108/108, built-in final blocks/scoped `with` raise it to 112/112, harray callbacks to 113/113, and array-root
  callbacks to 114/114.
  Portable aliases remain `i`/`elif` for
  marker chains and `when`/`otherwise` for attached chains; broader
  Perl/Dart/Julia acceptance, scalar/aggregate truthiness, and switch scalar-equality drift are owned by
  `FUTURE-PARITY-BACKLOG.5`. Portable switch labels avoid boolean-versus-number and aggregate comparisons until
  that equality policy is normalized, and marker-switch executable statements stay inside `case/default` ranges
  because Perl executes outside-range statements while Rust/Dart/Julia/Lua skip them.
  Portable loops also avoid relying on the exact-limit recheck or `next()` inside the body until backlog `.5`
  normalizes the current Perl/Rust/Dart/Julia/Lua differences.
  Implicit child-push expression results differ between Perl's
  host count and Lua's updated accumulator, and rename-to-existing-key policy also differs; portable authoring
  avoids those value/collision boundaries until backlog `.5` normalizes them.
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
    execution, and 105-fixture corpus output parity under `DART-BACKEND-PARITY` plus the global capability gate.
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
    string/regex/split bridges, flattening, reducer terminals, and updated-value end mutations are now green.
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
    `.1.5.4.2` adds the independent canonical trace while preserving native rich trace. Current proof is 1,040
    assertions plus 105/105 and 61/61 default/POSIX. `.1.5.4.3` closes exact four-backend CLI identity with one
    recurring warmed 4x2x61 driver; exhaustive current-surface `.1.6.1` and exact descriptors `.1.6.2` are closed, and
    generated-source `.3.0` is audited/split; neutral contract and strict all-105 Rust admission are closed.
    Dart's deterministic emitter, exact ten-family direct execution, and contract-sourced eight-case admission are
    green; Dart passes at census 59/0/1. Julia scaffold `.3.4.1` is active before final exact admission.
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
- Rust mutation testing is adopted under ADR `0039`, but mutation execution will never run per commit, from
  pre-commit hooks, or in ordinary local CI. The list-only baseline is 3,333 candidates across 19 files; future
  runs are explicit on-demand or milestone/release campaigns, targeted before any resource-guarded sharded
  breadth. `RUST-MUTATION-TESTING` owns the safe manual command and pilot; no mutation score is claimed yet.
- Run `perl tools/check_capability_conformance.pl` to validate the current 16-capability/four-backend census,
  evidence paths, and future ownership. The live census is 64 pass, zero partial, and zero gap states. Generated
  source reached the earlier 60/0/0 milestone under `.3`; punctuation-light admission `.16.7` adds the current
  four passing states. Lua remains outside this full-backend census until its dedicated parity tree completes.
- Run `perl tools/check_generated_source_contract.pl` to validate generated-source contract v1: idiomatic host APIs
  and backend-native source text behind identical emission/load/execution/trace/error/identity roles, ten generated
  families, four plan-rejection cases, one direct neutral fixture, an eight-case generated subset, and the 105-case
  primary interpreter oracle.
- Run `bash tools/check_punctuation_light_five_backend.sh` when all five backend toolchains are installed to prove
  the admitted zero-argument aliases and exclusions across Perl/Rust/Dart/Julia plus both Lua ABIs. The same leg is
  available from local CI with `LINKEDSPEC_RUN_PUNCTUATION_MATRIX=1`.
- Run `python3 tools/check_complete_named_mark_contract.py` to validate the exact seven-helper named-mark contract,
  its Unicode/rule-local fixture, and mutation sensitivity. Perl and Rust consume the unchanged fixture through
  live plus generated execution; Dart and Julia consume it through native/generated/CLI routes; and Lua consumes
  it through native plus serialized `SpecFile` reconstruction on PUC Lua and LuaJIT. The seven names are admitted
  into the aligned 246-name shared inventories. The coverage gate combines the 105-case corpus with this exact
  fixture and independently reverse-checks all 122 public Perl contracts while locking nine explicit exclusions.
- Run `perl tools/check_native_spec_resolution_contract.pl` to validate the versioned file-oriented native API
  schema: portable names, exact paths, declared-order roots, regular-file selection, strict UTF-8, pipeline stages,
  and structured errors. `prove -Iperl t/native_spec_resolution.t` consumes the same fixture through Perl's public
  portable facade; Rust, Dart, and Julia package tests do likewise. Exact `.1.6.4` admission is closed.
- Run `python3 tools/check_scalar_numeric_contract.py` to validate the versioned strict scalar numeric helper
  contract: finite decimal inputs, exact/variadic arities, invalid-to-null behavior, numeric comparison truth,
  half-away rounding, clamp/division fences, and signed integer modulo. Perl, Rust, Dart, Julia, PUC Lua, and
  LuaJIT consume all 55 cases through strict numeric adapters. Run `bash tools/check_scalar_numeric_six_runtime.sh`
  for the composed exact six-runtime admission proof.
- Run `python3 tools/check_callable_signature_contract.py` to validate the adopted variadic callable contract:
  version-1 fixed functions remain exact; version-2 `fn name(fixed, ...rest) { ... }` signatures bind extras as a
  fresh typed array, accept zero extras, reject keyword/overload/host-splat behavior, and retain purpose-specific
  fixed versus open-bound helper/method arities. Perl consumes the unchanged fixture through
  `prove -Iperl t/variadic_user_function_contract.t`; Rust consumes it through
  `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test variadic_user_function_contract`.
  Dart consumes it through `dart test test/variadic_user_function_contract_test.dart`; Julia consumes it through
  the 55 assertions in `julia/test/variadic_user_function_contract_test.jl`. Lua native parity is routed to
  `LUA-BACKEND-PARITY.5.1`, descriptor admission to `.5.3`, and generated preservation/execution to `.8.1-.4`.
- Run `python3 tools/check_callable_codeblock_contract.py` to validate the adopted future callable-codeblock
  contract: exact `{|fixed, ...rest| body }` parsing, harray/eager-block disambiguation, deferred typed AST data,
  dynamic caller context, copied/restored params, results, precedence, diagnostics, contextual final blocks, and
  deterministic fixture source/results. Perl literal construction/preservation, dynamic variable invocation, and
  metadata-governed attached/parenthesized helper/user-function/receiver normalization pass the contract-focused
  suite; final-only `name: codeblock` and its no-drift closeout are current on Perl. Cross-backend parity remains
  future-owned after the prioritized `.12.1` selector retirement.
- Run `python3 tools/check_uniform_binding_contract.py` to validate the adopted future selector-free binding
  contract: one observable scalar/array/harray/codeblock value per identifier, bare typed reads and mutations,
  post-assignment `set` results, static-rule `push` precedence, pure versus mutable `split`, typed wrong-kind and
  removed-selector diagnostics, exact migration spellings, and constructor classification. The checker covers 11
  migrations, seven execution cases, six invalid selectors, eight retained constructors, and deterministic future
  fixture source/results. Perl, Rust, Dart, Julia, and Lua execute the replacement contract; every tracked `.spec`
  file and executable embedded source is now selector-free. Run
  `python3 tools/check_uniform_binding_mutation_result_surface.py` to lock the current array-end result rule:
  push/pop end methods return independent updated arrays, pop discards the removed element, and compatible
  continuations consume the update.
- Run `perl tools/check_language_capability_coverage.pl --report` for the current Dart/Julia ActionIR call-name
  inventory against the mdBook and neutral corpus. The strict form intentionally remains red until `.1.6.1.2`;
  `.1.6.1.1` repaired universal Perl newline splitting and `.1.6.1.2.1` repaired the narrower generated terminator
  after newline `endswitch()`. A diagnostic 105-case run then passed 100/105 on each non-reference backend and
  split pure, position, marker-control, and capture/mark repairs under `.1.6.1.2.2`. Those repairs and final
  admission are closed: the corrected shared inventory now contains 246 current names, every name is present in
  the mdBook and one of 105 corpus fixtures plus the exact named-mark fixture, all 122 public Perl contracts are
  independently reverse-checked, and all four corpus backends pass the expanded 105-case corpus exactly. Exact
  descriptor identity, typed Rust projection, and one shared canonical
  outer function-record contract are closed under `.1.6.2`. Typed Rust diagnostic errors, source/top/child
  attribution, compatibility adapters, and final recurring admission are closed under `.1.6.3`. Native named/file
  resolution `.1.6.4` is audited and split; `.1.6.4.1` fixes its deterministic ordered-root contract, while Rust,
  Dart, and Julia native APIs `.1.6.4.2-.4` pass; Perl direct proof and final admission `.1.6.4.5` close the parent.
  Dart full-pipeline trace `.1.6.5` and non-codegen closeout `.1.6.6` are closed; generated-source `.3.0` has
  audited/split the boundary; `.3.1.0` then corrected the Perl source-capture assumption and neutral executable
  contract `.3.1` and Rust breadth `.3.2` are closed: strict recurring generated proof passes 105/105 and Rust
  promoted at census 58/0/2. Dart `.3.3.1-.3` now pass deterministic emission, exact family execution, and the
  accepted eight-case proof; Dart promotes and the live census is 59/0/1. Julia `.3.4.1` is active.
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
  the unchanged 61-case suite under both environments. Exact CLI lane `.1.5` and governed 246-name/105+1-fixture
  surface `.1.6.1`, exact outward descriptors `.1.6.2`, and structured diagnostics `.1.6.3` are closed; complete
  documented named-mark inventory remains explicitly owned by `.17`; native resolution
  native resolution `.1.6.4`, Dart full-pipeline trace `.1.6.5`, and non-codegen `.1.6.6` are closed; only
  generated-source `.3` remains in the current capability census; `.3.1` fixes the shared executable contract
  before Rust `.3.2`, Dart `.3.3`, Julia `.3.4`, and exact admission `.3.5`.
- Deep semantic introspection plus MCP is parked under `FUTURE-PARITY-BACKLOG.10.1`: native backend APIs own one
  versioned semantic model, while MCP remains a thin transport rather than a backend-specific source of truth.
- Run `bash tools/run_dart_local.sh` from the repo root for the focused Dart backend gate: format, analyze, full
  Dart tests, CLI help, and the 105-fixture corpus execution.
- Run `bash tools/run_rust_local.sh` from the repo root for Rust formatting, the full runtime package, and both
  61-case primary-command environments.
- Run `bash tools/run_julia_local.sh` from the repo root for the focused Julia backend gate: package tests, CLI
  checks, and the 105-fixture corpus execution. Override the executable/depot with `LINKEDSPEC_JULIA_CMD` and
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
