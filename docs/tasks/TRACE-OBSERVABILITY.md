# TRACE-OBSERVABILITY: a discoverable CLI + comprehensive "see everything" trace

## Metadata

- Tree ID: `TRACE-OBSERVABILITY`
- Status: `active`
- Roadmap lane: `Overall roadmap — engine observability / developer experience`
- Created: `2026-06-19`
- Last updated: `2026-07-04` (`.4.1` Rust trace parity design inventory)
- Owner: repo-local workflow

## Goal (user directive, 2026-06-19)

Make LinkedSpec's execution **fully observable** from the command line:
1. **A discoverable CLI control** for the trace API ("introduce a CLI control to this API").
2. **Comprehensive trace** — "ideally a well-implemented trace shall be able to see everything":
   which functions are **entered/exited**, which **if/switch/case branch** is taken, decisions,
   values, parse positions — across the compile pipeline AND the generated runtime parser.
3. **Cross-variant trace parity** — documented trace capabilities are a variant-agnostic external contract.
   Perl, Rust, and future variants may expose different language-specific APIs, but no variant may claim trace
   parity unless its user-visible trace controls, levels, event classes, and sink behavior match the book contract.

This also directly enables root-causing (e.g. `PHASE0-BACKHALF-TRIAGE`).

## Current state of the trace (assessed 2026-06-19)

The framework **already exists** in `perl/LinkedSpec/Trace.pm` (public surface re-exported from
`LinkedSpec.pm`): `configure_trace`, `trace_enter`/`trace_exit` (function/scope enter-exit),
`trace_decision` (branch/decision: `DECISION <name> => TAKEN`), `log_output`, `log_dump`,
`should_dump`; UVM-style levels `none(0)/low(100)/medium(200)/high(300)/full(400)/debug(500)`;
indent nesting; mark-excerpt rendering; sink routing (stdout | route-to-file | mirror).

**It works** — `LINKEDSPEC_TRACE_LEVEL=debug perl -Iperl <driver>` emits large ENTER/DECISION/dump
traces for tiny specs (a 2026-07-04 probe with routed debug trace wrote 40,199 lines). Existing env
controls (Trace.pm ~236–261, gated by `$TRACE_INITIALIZED`): `LINKEDSPEC_TRACE_LEVEL`,
`LINKEDSPEC_DUMP_VERBOSITY`, `LINKEDSPEC_TRACE_FILE`, `LINKEDSPEC_TRACE_MIRROR_STDOUT`,
`LINKEDSPEC_TRACE_EMOJI`, `LINKEDSPEC_TRACE_RESET_FILE`. (Setting `$DUMP_VERBOSITY` directly does
NOT reliably work through the lazy-loaded `LinkedSpec` facade before first Trace load — use env vars,
per-call trace options, or `configure_trace`.)

**The two gaps (= this tree's work):**
1. **Discoverability/CLI:** `TRACE-OBSERVABILITY.2` now closes the first discoverability gap with
   `bin/linkedspec`, a command-line compile/run runner that exposes `--trace LEVEL`, `--trace-file`,
   `--trace-mode`, `--trace-reset`, and `--trace-emoji`, and with mdBook/TOOLBOX documentation.
2. **Coverage:** generated runtime parser branch tracing is now concrete for the Perl reference non-repetition
   and repetition handler templates, but compile/ActionIR owner coverage is still not exhaustive. "See everything"
   wants function enter/exit + every if/switch/case branch across the compile pipeline and generated runtime parser.

## Coverage Audit (`TRACE-OBSERVABILITY.1`, 2026-07-04)

The existing trace call-site map is concentrated in the Perl reference backend:

- `perl/LinkedSpec/Trace.pm`: owns verbosity parsing, sink routing, ENTER/EXIT/DECISION/MARK rendering,
  dump output, and env/per-call configuration.
- `perl/LinkedSpec.pm`: exposes facade wrappers for `configure_trace`, `trace_enter`, `trace_exit`,
  `trace_decision`, `log_output`, `log_dump`, and `should_dump`. It does **not** expose a facade wrapper for
  `trace_mark_event`; that is an owner-level `LinkedSpec::Trace` function reached by generated/runtime internals.
- `perl/LinkedSpec/Compiler.pm`: traces the broad `LinkedSpec::Get` compile pipeline, parser invocation,
  top-rule resolution/input validation/invocation decisions, `build_compiled_rule_table`, and
  `build_dependency_regex_map`.
- `perl/LinkedSpec/ParserFactory.pm`, `perl/LinkedSpec/Resolver.pm`, and `perl/LinkedSpec/Validation.pm`:
  trace named-spec lookup, resolver fallbacks, and validation failures/warnings.
- `perl/LinkedSpec/SpecEntry.pm`: traces per-rule compile entry/exit, handler source dumps, runtime
  `LinkedSpec::rule_handler:<label>` entry/exit, handler compile/eval failures, and the no-consume recursion cut.
- `perl/LinkedSpec/RuleIR.pm` and ActionIR mark contracts: emit mark/capture trace calls into generated handler
  code for supported mark operations.

The important gaps are now pinned:

- At the time of this `.1` audit there was no discoverable `bin/` entrypoint or
  `--trace`/`--trace-file` CLI surface. `TRACE-OBSERVABILITY.2` has since closed that discoverability gap.
- Most ActionIR/lowering owner functions have no ENTER/EXIT scopes and their `if`/`switch`/case decisions are not
  traced; the current pipeline trace sees stage boundaries and a few validation decisions, not every branch.
- At the time of the `.1` audit, `perl/LinkedSpec/HandlerVariantEmitter.pm` emitted untraced runtime branches
  (`while`, `foreach`, `if`/`elsif`, `unless`, repetition min/max and zero-progress branches, acode index dispatch,
  bcode call dispatch, and no-match/LX/EX paths). `.3.2` and `.3.3` have since wired the Perl reference
  non-repetition and repetition generated templates through `trace_generated_handler_branch(...)`.
- Generated in-body trace now covers match/dispatch/repetition control flow for the current Perl reference
  templates; RuleIR planning decisions, the EmitContext owner bridge/rewrite orchestration layer,
  scanner/canonical/diagnostic/rewrite-pipeline internals, compact ActionIR lowerers, and
  `ActionIR::MethodLowering` helper-family/assignment/mutation/receiver-chain/unsupported-form decisions are now
  traced. `.3.4.6` closed the compile/ActionIR coverage boundary with a representative descriptor-compile probe.
  `.3.5` closed global no-drift checks and split the backend parity lane.
- Rust currently has no analogous trace API/sink surface in `rust/linkedspec-runtime`; `rg` finds no runtime trace
  implementation beyond ordinary test variables named `log`. `TRACE-OBSERVABILITY.4` now owns Rust/future trace
  parity work before any Rust trace code changes.

Coverage plan:

1. `.2`: done — add a discoverable CLI/control surface and document the exact env/per-call/API controls. Correct
   docs say `configure_trace`, per-call options, env vars, and `bin/linkedspec` flags are the reliable controls;
   lazy facade package-variable mutation is compatibility state, not the preferred control path.
2. `.3`: extend Perl reference coverage in small sub-leaves: helper seam, non-repetition generated handler
   dispatch tracing, repetition generated handler tracing, and compile/ActionIR owner decisions through
   MethodLowering are now in place. `.3.4.6` closed the compile/ActionIR coverage boundary with a normal
   descriptor-compile trace probe.
3. `.3.5`: done — no-drift trace probes passed across CLI, generated-handler, RuleIR, EmitContext, ActionIR
   pipeline, compact-lowerer, and MethodLowering trace suites; the mdBook now presents the external trace contract
   as a variant-neutral checklist rather than Perl mechanics.
4. `.4`: required backend-parity lane — define and implement the Rust and future-variant equivalent trace model
   instead of pretending the current Perl-only trace surface already covers Rust. `.4.1` has now mapped the
   neutral mdBook contract onto Rust owner boundaries; `.4.2` is the first Rust implementation leaf.

## Non-Goals

- Re-implementing the trace framework (it exists; extend + expose it).
- Tracing into `noncore/` (out of scope; core only).

## Acceptance Criteria

- A discoverable CLI front-end drives trace (level + file/mirror) and is documented in the mdBook.
- Trace coverage reaches "see everything": function enter/exit + branch (if/switch/case) decisions
  across the compile pipeline and the generated runtime parser, gated by verbosity.
- The mdBook states trace capability parity as a variant-agnostic external contract; backend-specific internals
  are examples or implementation notes only.
- Regression-locked; no change to default (untraced) behavior/output.

## Task Tree (scaffold — refine on pickup)

- ID: `TRACE-OBSERVABILITY` · Status: `active` · Children: `.1`, `.2`, `.3.{1..5}`, `.4.{1..5}`
- ID: `TRACE-OBSERVABILITY.1` · Status: `done` (closed 2026-07-04)
  Goal: Coverage audit — map what is already instrumented (trace_enter/exit/decision sites) across
    the compile pipeline + runtime parser, and enumerate the gaps to "see everything" (which funcs
    lack enter/exit, which branches lack `trace_decision`, runtime-handler branch tracing).
  Acceptance: done — gap inventory + coverage plan recorded above. Read-only.
  Verification: `rg` call-site inventory, emitted handler source probe, routed debug trace probe, Rust trace search,
    mdBook/API drift probes.
  Commit: `9085a026` (`TRACE-OBSERVABILITY.1 - audit trace coverage gaps`)
- ID: `TRACE-OBSERVABILITY.2` · Status: `done` (closed 2026-07-04)
  Goal: Discoverable CLI control — expose the existing env/`configure_trace` control via a `bin/`
    entrypoint and/or a `--trace LEVEL` / `--trace-file` flag; document the env vars + the CLI in the
    mdBook. (Smallest, highest-DX win — do first if a quick gate is wanted.)
  Acceptance: done — `bin/linkedspec` compiles/runs inline, file, or named specs; prints canonical JSON; exposes
    `--trace`, `--trace-file`, `--trace-mode`, `--trace-reset`, and `--trace-emoji`; and the mdBook plus
    `TOOLBOX.md` document the control path.
  Verification: `perl -c bin/linkedspec`; `perl -c -Iperl t/trace_cli.t`; `prove -v -Iperl t/trace_cli.t`;
    `mdbook build docs/linkedspec-book`; `bash knowledge-map/scripts/check_knowledge_map.sh`;
    `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `git diff --check`;
    `bash tools/run_ci_local.sh`.
  Commit: `30981c44` (`TRACE-OBSERVABILITY.2 - add trace CLI control`)
- ID: `TRACE-OBSERVABILITY.3` · Status: `split` (closed 2026-07-04)
  Goal: Extend instrumentation toward "see everything" (function enter/exit + if/switch/case branch
    decisions), compile pipeline first, then the generated runtime parser (emit trace into handlers).
  Acceptance: done — split into executable children below so coverage work can land in signoff-sized slices.
  Verification: task-tree split review; no runtime/code behavior change.
  Commit: `8e371460` (`TRACE-OBSERVABILITY.3 - split trace coverage extension`)
- ID: `TRACE-OBSERVABILITY.3.1` · Status: `done` (closed 2026-07-04)
  Goal: Generated-handler trace helper contract — add the smallest reusable Perl runtime helper seam for emitted
    handler branch decisions, prove trace-off behavior stays quiet/cheap, and document the emitted-call contract.
  Acceptance: done — `LinkedSpec::Trace::trace_generated_handler_branch(%args)` returns the original branch
    boolean, emits structured `generated_handler_branch:<kind>:<rule>:<branch>` decisions when enabled, evaluates
    lazy details only when trace output is enabled, and captures detail-builder errors without perturbing branch
    behavior. mdBook documents the owner-level emitted-call contract and keeps template instrumentation scoped to
    later leaves.
  Verification: `perl -c -Iperl perl/LinkedSpec/Trace.pm`; `perl -c -Iperl t/trace_generated_handler_branch.t`;
    `prove -v -Iperl t/trace_generated_handler_branch.t`; mdBook; Knowledge Map; memory/doctrine; whitespace;
    `bash tools/run_ci_local.sh`.
  Commit: `95b84fab` (`TRACE-OBSERVABILITY.3.1 - add generated-handler trace helper seam`)
- ID: `TRACE-OBSERVABILITY.3.2` · Status: `done` (closed 2026-07-04)
  Goal: Instrument non-repetition generated handler dispatch paths: match/no-match, acode index dispatch, bcode
    child-call dispatch, and `LX`/`EX` outcomes.
  Acceptance: done — `_default`, `AND_BCODE`, `OR_BCODE`, `AND_ACODE`, `AND_SINGLE_ACODE`, and `OR_ACODE`
    templates route their non-repetition branch conditions through `trace_generated_handler_branch`; debug trace
    reports `match`, `no_match_lx`, `acode_index_<n>`, `required_index_0`, `required_sequence_index`,
    `bcode_call_<Rule>`, `bcode_child_result`, and `bcode_no_child_match` decisions. Repetition templates remain
    deliberately uninstrumented until `.3.3`, which has since closed.
  Verification: `perl -c -Iperl perl/LinkedSpec/HandlerVariantEmitter.pm`;
    `perl -c -Iperl t/trace_generated_nonrep_dispatch.t`;
    `prove -v -Iperl t/trace_generated_nonrep_dispatch.t`; mdBook; Knowledge Map; memory/doctrine; whitespace;
    `tools/run_ci_local.sh`.
  Commit: `08e7a885` (`TRACE-OBSERVABILITY.3.2 - trace non-repetition generated dispatch`)
- ID: `TRACE-OBSERVABILITY.3.3` · Status: `done` (closed 2026-07-04)
  Goal: Instrument repetition generated handler paths: min/max bounds, loop entry/exit, zero-progress cutoff, and
    per-iteration success/failure decisions.
  Acceptance: done — `REP_BCODE`, `REP_AND_BCODE`, `REP_AND_ACODE`, and `REP_ACODE` templates route their REP
    loop branch conditions through `trace_generated_handler_branch`; debug trace reports `loop_enter`,
    `iteration_result`, `miss_min_satisfied`, `max_continue`, and, for bcode REP families, `zero_progress` and
    `zero_progress_min_satisfied`. `REP_ACODE` also reports `match` and `acode_index_<n>`. Nested non-REP bcode
    helper branch calls remain disabled inside REP coderefs so REP traces stay loop-owned.
  Verification: `perl -c -Iperl perl/LinkedSpec/HandlerVariantEmitter.pm`;
    `perl -c -Iperl t/trace_generated_rep_dispatch.t`;
    `prove -v -Iperl t/trace_generated_rep_dispatch.t`;
    `prove -v -Iperl t/trace_generated_nonrep_dispatch.t`; mdBook; Knowledge Map; memory/doctrine; whitespace;
    `tools/run_ci_local.sh`.
  Commit: `a225db82` (`TRACE-OBSERVABILITY.3.3 - trace repetition generated paths`)
- ID: `TRACE-OBSERVABILITY.3.4` · Status: `split` (closed 2026-07-04)
  Goal: Add missing Perl compile/ActionIR owner ENTER/EXIT scopes and branch decisions for the lowering paths that
    select helper families, control-flow branches, and fallback/diagnostic outcomes.
  Acceptance: done — read-only scope audit showed this leaf spans `RuleIR.pm`, `RuleIR/EmitContext.pm`, the
    scanner/canonical/diagnostic/rewrite owners, value/flow/control/declaration/array lowering owners, and the
    large `MethodLowering.pm` owner. Split before code into executable children below.
  Verification: `rg` trace call-site inventory; `wc -l` owner sizing; targeted reads of `RuleIR.pm` and
    `RuleIR/EmitContext.pm`; ActionIR owner inventory.
  Commit: `f488d0ed` (`TRACE-OBSERVABILITY.3.4 - split compile action trace coverage`)
- ID: `TRACE-OBSERVABILITY.3.4.1` · Status: `done` (closed 2026-07-04)
  Goal: Instrument RuleIR planning decisions: handler-variant selection, execution-shape/action-mode metadata,
    lifecycle-entry routing in `_collect_rule_ir`, mark/move handling, and mixed-action validation decisions.
  Acceptance: done — debug trace now reports `rule_ir:<phase>:<rule>:<decision>` decisions for RuleIR collection
    routing, explicit ACODE/BCODE collection, per-regex lifecycle routing, `MOVE_POS`/`MARK_POS` LECODE lowering,
    handler-variant selection, action-mode/execution-shape planning, and mixed-action validation.
  Verification: `perl -c -Iperl perl/LinkedSpec/RuleIR.pm`; `perl -c -Iperl t/trace_ruleir_planning.t`;
    `prove -v -Iperl t/trace_ruleir_planning.t`; mdBook; Knowledge Map; memory/doctrine; whitespace;
    `tools/run_ci_local.sh`.
  Commit: `b36a9386` (`TRACE-OBSERVABILITY.3.4.1 - trace RuleIR planning decisions`)
- ID: `TRACE-OBSERVABILITY.3.4.2` · Status: `done` (closed 2026-07-04)
  Goal: Instrument the EmitContext owner bridge and rewrite orchestration boundaries: ActionIR owner package/callback
    resolution, default dependency bundle selection, current registry/bare-kind injection, and top-level
    rewrite-action-code entry/exit/fallback decisions.
  Acceptance: done — debug trace now reports `emit_context:<phase>:<label>:<decision>` decisions and matching
    debug scopes for ActionIR owner package resolution, callback lookup, default dependency bundle selection,
    function-registry injection, bare-symbol-kind injection, compatibility scalar/aggregate fallback paths,
    canonical rewrite-pipeline use, canonical raw-Perl fallback status, and rule emit-context build boundaries.
  Verification: `perl -c -Iperl perl/LinkedSpec/RuleIR/EmitContext.pm`;
    `perl -c -Iperl t/trace_emit_context_bridge.t`; `prove -v -Iperl t/trace_emit_context_bridge.t`;
    `prove -v -Iperl t/trace_ruleir_planning.t t/trace_emit_context_bridge.t`; `mdbook build docs/linkedspec-book`;
    `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_memory_architecture.sh`;
    `bash scripts/check_doctrines.sh`; `git diff --check`; `git diff --cached --check`;
    `bash tools/run_ci_local.sh`.
  Commit: `c8cbd663` (`TRACE-OBSERVABILITY.3.4.2 - trace EmitContext owner bridge`)
- ID: `TRACE-OBSERVABILITY.3.4.3` · Status: `done` (closed 2026-07-04)
  Goal: Instrument scanner/canonical/diagnostic/rewrite-pipeline owners for helper-event discovery, canonical
    event queue/fallback decisions, unresolved-helper diagnostics, RAW_PERL/unmatched-event fallbacks, and implicit
    flow closure handling.
  Acceptance: done — debug trace now reports `actionir:<owner>:<phase>:<label>:<decision>` decisions and matching
    debug scopes for scanner/scanner-core helper-event discovery, canonical helper queue/fallback decisions,
    registered value-drop recognition, unmatched helper scan events, diagnostic unresolved/unsupported helper
    handoffs, rewrite-rule construction, canonical lowering decisions, source-span/contract skips, RAW_PERL
    fallback preservation, and implicit attached-if closure insertion/appending.
  Verification: `perl -c -Iperl perl/LinkedSpec/ActionIR/Trace.pm`;
    `perl -c -Iperl perl/LinkedSpec/ActionIR/Scanner.pm`;
    `perl -c -Iperl perl/LinkedSpec/ActionIR/ScannerCore.pm`;
    `perl -c -Iperl perl/LinkedSpec/ActionIR/CanonicalEvents.pm`;
    `perl -c -Iperl perl/LinkedSpec/ActionIR/Diagnostics.pm`;
    `perl -c -Iperl perl/LinkedSpec/ActionIR/RewritePipeline.pm`;
    `perl -c -Iperl t/trace_actionir_pipeline.t`; `prove -v -Iperl t/trace_actionir_pipeline.t`;
    adjacent RuleIR/EmitContext/generated-handler trace suites; mdBook; Knowledge Map; memory/doctrine;
    whitespace; `bash tools/run_ci_local.sh`.
  Commit: `8a29c712` (`TRACE-OBSERVABILITY.3.4.3 - trace ActionIR pipeline decisions`)
- ID: `TRACE-OBSERVABILITY.3.4.4` · Status: `done` (closed 2026-07-04)
  Goal: Instrument the compact ActionIR lowering owners outside MethodLowering: value/flow/control/declaration/
    array-pipeline branch decisions and owner ENTER/EXIT scopes.
  Acceptance: done — debug trace now reports `actionir:<owner>:<phase>:<label>:<decision>` decisions and matching
    debug scopes for `flow_expr`, `value_expr`, `array_pipeline`, `declare_method`, and `control_flow` compact
    owners. Covered decisions include flow-expression families, primitive/direct/value-source lowering,
    array-pipeline plan/op lowering, declaration initializer/set routing, and compact attached/inline/marker
    if/switch control-flow choices. `MethodLowering.pm` remains deferred to `.3.4.5`.
  Verification: `perl -c -Iperl perl/LinkedSpec/ActionIR/FlowExpr.pm`;
    `perl -c -Iperl perl/LinkedSpec/ActionIR/ValueExpr.pm`;
    `perl -c -Iperl perl/LinkedSpec/ActionIR/ArrayPipeline.pm`;
    `perl -c -Iperl perl/LinkedSpec/ActionIR/DeclareMethod.pm`;
    `perl -c -Iperl perl/LinkedSpec/ActionIR/ControlFlow.pm`;
    `perl -c -Iperl t/trace_actionir_compact_lowerers.t`;
    `prove -v -Iperl t/trace_actionir_compact_lowerers.t`;
    adjacent RuleIR/EmitContext/ActionIR pipeline trace suites; `prove -v -Iperl t/actionir_ast_parser.t
    t/trace_actionir_compact_lowerers.t`; mdBook; Knowledge Map; memory/doctrine; whitespace;
    `bash tools/run_ci_local.sh`.
  Commit: `276c333e` (`TRACE-OBSERVABILITY.3.4.4 - trace compact ActionIR lowerers`)
- ID: `TRACE-OBSERVABILITY.3.4.5` · Status: `done` (closed 2026-07-04)
  Goal: Instrument `ActionIR::MethodLowering` in its own leaf because it is the largest branch owner: helper-family
    selection, assignment/mutation paths, receiver-chain family transitions, AST-vs-string fallback decisions, and
    unsupported-form exits.
  Acceptance: done — debug trace now reports `actionir:method_lowering:<phase>:<label>:<decision>` decisions and
    matching assignment scopes for helper-family selection, AST value lowering, AST/raw fallback bypasses,
    unsupported helper exits, receiver-chain family transitions, assignment/mutation operators, mutation-slot
    values, and return-payload fallback choices. The hooks stay lazy through `ActionIR::Trace`.
  Verification: `perl -c -Iperl perl/LinkedSpec/ActionIR/MethodLowering.pm`;
    `perl -c -Iperl t/trace_actionir_method_lowering.t`; `prove -v -Iperl t/trace_actionir_method_lowering.t`;
    adjacent RuleIR/EmitContext/ActionIR trace suites; `prove -v -Iperl t/actionir_ast_parser.t
    t/trace_actionir_method_lowering.t`; mdBook; Knowledge Map; memory/doctrine; whitespace;
    `bash tools/run_ci_local.sh`.
  Commit: `cfe2d9d1` (`TRACE-OBSERVABILITY.3.4.5 - trace MethodLowering decisions`)
- ID: `TRACE-OBSERVABILITY.3.4.6` · Status: `done` (closed 2026-07-04)
  Goal: Compile/ActionIR coverage closeout — run trace probes across representative lowering paths, update mdBook/
    TOOLBOX/Knowledge Map coverage boundaries, and decide whether `.3.5` can focus only on global closeout/backend
    parity split.
  Acceptance: done — a representative descriptor compile with debug routed trace emits `rule_ir:`,
    `emit_context:`, `actionir:scanner`, `actionir:rewrite_pipeline`, `actionir:control_flow`, and
    `actionir:method_lowering` decisions together while preserving ActionIR readiness (`ready=1 raw=0 unresolved=0`).
    The planned compile/ActionIR Perl reference owner namespaces are now covered through MethodLowering; `.3.5`
    has since closed overall trace no-drift/examples and split the Rust/future-variant parity lane.
  Verification: representative `LinkedSpec::Get(... return_descriptor => 1, trace_level => 'debug',
    trace_log_mode => 'route')` probe; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh`.
  Commit: `8fa7243a` (`TRACE-OBSERVABILITY.3.4.6 - close compile ActionIR trace coverage`)
- ID: `TRACE-OBSERVABILITY.3.5` · Status: `done` (closed 2026-07-04)
  Goal: Coverage closeout — update mdBook examples/coverage boundaries, run no-drift trace probes, and decide
    how the required Rust/future-variant trace parity split follows from the external trace contract.
  Acceptance: done — the mdBook now names the external trace contract as variant-neutral behavior: ordered levels,
    normal-entrypoint controls, stdout/routed-file/mirror sinks, reset behavior, enter/exit scopes, decision/branch
    events, mark/capture events where applicable, dump/log events, and unchanged default output. Perl reference
    trace suites pass, and Rust source inventory still has no trace API/control hits outside corpus fixture text.
    The backend parity lane is split below before Rust trace code changes.
  Verification: `perl bin/linkedspec --help`; `rg -n 'LINKEDSPEC_TRACE|trace_level|trace_log|--trace|\bTrace\b|\btrace\b'
    rust --glob '!**/tests/corpus/**'` (no hits); `prove -v -Iperl t/trace_cli.t
    t/trace_generated_handler_branch.t t/trace_generated_nonrep_dispatch.t t/trace_generated_rep_dispatch.t
    t/trace_ruleir_planning.t t/trace_emit_context_bridge.t t/trace_actionir_pipeline.t
    t/trace_actionir_compact_lowerers.t t/trace_actionir_method_lowering.t`.
  Commit: `c623d6ec` (`TRACE-OBSERVABILITY.3.5 - close trace contract and split parity`)
- ID: `TRACE-OBSERVABILITY.4` · Status: `split` (created 2026-07-04)
  Goal: Cross-variant trace parity — make Rust and future variants honor the mdBook-documented trace capability
    contract before claiming trace parity.
  Acceptance: split before code into signoff-sized children: `.4.1` Rust contract/design inventory, `.4.2` Rust
    controls/levels/sinks, `.4.3` Rust compile/spec-parser trace events, `.4.4` Rust runtime dispatch/branch trace
    events, and `.4.5` cross-variant closeout/docs/gates.
  Verification: inherited from `.3.5` no-drift probes and Rust trace inventory.
  Commit: `c623d6ec` (`TRACE-OBSERVABILITY.3.5 - close trace contract and split parity`)
- ID: `TRACE-OBSERVABILITY.4.1` · Status: `done` (closed 2026-07-04)
  Goal: Rust trace contract/design inventory — map the neutral mdBook trace contract onto Rust entrypoints,
    runtime/compiler ownership boundaries, and tests before writing Rust trace code.
  Acceptance: done — inventory mapped the contract onto Rust's current public surfaces:
    `linkedspec-core` owns `parse_spec`, `validate`, `compile`, dependency-regex resolution, and shared
    `CompiledSpec`/`CompiledRule` types; `linkedspec-runtime` owns `parse_spec_with_user_functions`, staged
    parser registry dispatch, `Engine::execute`, `Engine::execute_generated_with_plan`,
    `source_emitter::execute_generated_parser`, runtime context/match/mark state, interpreter branch execution,
    and generated-rule family plan execution. Rust currently has no trace API/control implementation, so `.4.2`
    must add shared Rust trace levels/config/sink routing first, `.4.3` must add parser/compiler/staged-dispatch
    scope and decision events, `.4.4` must add interpreter/generated-plan runtime branch events, and `.4.5` must
    prove cross-variant contract parity before Rust claims trace parity.
  Verification: Rust source inventory; `cargo test` attempted and failed only in the existing
    `linkedspec-runtime` integration test target (157 passed, 9 failed) with no Rust source diff; accepted `.4.1`
    gates were `mdbook build docs/linkedspec-book`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
    `bash scripts/check_memory_architecture.sh`, `bash scripts/check_doctrines.sh`, `git diff --check`, and
    `bash tools/run_ci_local.sh`.
  Commit: `pending`
- ID: `TRACE-OBSERVABILITY.4.2` · Status: `active`
  Goal: Rust trace controls, levels, and sinks — implement the Rust-facing configuration model and output routing
    equivalent to the documented contract. Preserve default-quiet behavior for existing `parse_spec`, `compile`,
    `Engine::execute`, and generated parser entrypoints while adding explicit traced entrypoints/config plumbing.
  Verification: `pending`
  Commit: `pending`
- ID: `TRACE-OBSERVABILITY.4.3` · Status: `pending`
  Goal: Rust compile/spec-parser trace events — add structured compile-side scope and decision events equivalent
    to the Perl reference contract.
  Verification: `pending`
  Commit: `pending`
- ID: `TRACE-OBSERVABILITY.4.4` · Status: `pending`
  Goal: Rust runtime dispatch and branch trace events — add structured runtime-handler/interpreter branch events
    equivalent to generated-handler branch tracing.
  Verification: `pending`
  Commit: `pending`
- ID: `TRACE-OBSERVABILITY.4.5` · Status: `pending`
  Goal: Cross-variant trace parity closeout — run parity probes, update docs/Knowledge Map/toolbox, and define the
    reusable future-variant checklist.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `.4.2` | `active` | Add Rust controls, levels, and sinks after the design inventory. |
| 2 | `.4.3` | `pending` | Add Rust compile/spec-parser trace events. |
| 3 | `.4.4` | `pending` | Add Rust runtime dispatch/branch trace events. |
| 4 | `.4.5` | `pending` | Close cross-variant trace parity docs/gates. |

## Decisions

- `2026-06-19`: Owns the user's trace directives (CLI control + comprehensive "see everything" trace).
  The framework already exists (Trace.pm: enter/exit/decision/levels/sinks; env-var control works) —
  the work is (a) make it discoverable (CLI + docs) and (b) extend coverage. Sequence `.2` (CLI/docs)
  early for a quick win; `.1`/`.3` for the coverage push.
- `2026-07-04`: CLI form is `bin/linkedspec`, a small Perl reference runner that maps CLI trace flags directly
  to the existing trace option keys and keeps routed trace output separate from canonical JSON stdout.
- `2026-07-04`: `.3` is split before code. Generated handler helper/seam work comes first, generated non-REP and
  REP branches are separate leaves, compile/ActionIR owner scopes follow, and backend parity waits until Perl
  reference semantics are concrete.
- `2026-07-04`: `.3.1` adds only the helper contract. It deliberately does not instrument non-repetition or
  repetition templates; `.3.2` and `.3.3` own those emitted call-site changes.
- `2026-07-04`: `.3.2` instruments only non-repetition generated handler dispatch. Repetition wrappers disable
  nested non-REP branch calls inside REP coderef bodies, and `REP_ACODE` source remains plain until `.3.3` owns the
  min/max/zero-progress trace design. `.3.3` has since closed that design.
- `2026-07-04`: `.3.3` instruments REP loop decisions at the REP template boundary. Nested non-REP bcode helper
  branch calls remain disabled inside REP coderefs so traces report loop-level REP decisions instead of duplicating
  inner dispatch details on every iteration.
- `2026-07-04`: `.3.4` is split before code. RuleIR planning, EmitContext owner bridge, scanner/canonical/
  diagnostics/rewrite pipeline, compact lowering owners, MethodLowering, and closeout are separate leaves because
  the ActionIR owner surface is too large for one signoff slice.
- `2026-07-04`: `.3.4.1` instruments RuleIR planning decisions with `rule_ir:<phase>:<rule>:<decision>` debug
  events. `.3.4.2` has since closed the EmitContext owner-bridge visibility layer.
- `2026-07-04`: `.3.4.2` instruments EmitContext owner-bridge and rewrite orchestration decisions with
  `emit_context:<phase>:<label>:<decision>` debug events. Scanner/canonical/diagnostic/rewrite-pipeline internals
  have since closed under `.3.4.3`.
- `2026-07-04`: `.3.4.3` instruments scanner, scanner-core, canonical-events, diagnostics, and rewrite-pipeline
  owner internals with `actionir:<owner>:<phase>:<label>:<decision>` debug events. Scanner trace records
  event-producing matches rather than every no-match probe because diagnostics replay every rewrite contract.
  Compact lowering owners have since closed under `.3.4.4`; `ActionIR::MethodLowering` remains owned by `.3.4.5`.
- `2026-07-04`: `.3.4.4` instruments compact lowerer owners with `actionir:<owner>:<phase>:<label>:<decision>`
  debug events. Covered owners are `flow_expr`, `value_expr`, `array_pipeline`, `declare_method`, and
  `control_flow`; `method_lowering` remains explicitly deferred to `.3.4.5`.
- `2026-07-04`: `.3.4.5` instruments `ActionIR::MethodLowering` with the same
  `actionir:method_lowering:<phase>:<label>:<decision>` debug namespace. Covered paths include helper-family
  classification, AST-vs-string fallback/bypass decisions, unsupported helper exits, receiver-chain transitions,
  assignment/mutation operators, mutation-slot values, return-payload fallback choices, and the scoped
  `_lower_assign_statement` enter/exit boundary.
- `2026-07-04`: `.3.4.6` closes the compile/ActionIR coverage boundary. The representative descriptor-compile
  trace probe emitted RuleIR, EmitContext, scanner/rewrite, compact control-flow, and MethodLowering decisions
  together with `ready=1 raw=0 unresolved=0`; `.3.5` can focus on global trace closeout and the backend parity
  split instead of another compile/ActionIR owner.
- `2026-07-04`: User clarified that trace capabilities documented in the mdBook are the external contract every
  variant must honor to claim trace parity. Concrete function names and internals may differ by backend, but
  user-visible trace controls, levels, event classes, and sink behavior must be equivalent across Perl, Rust, and
  future variants.
- `2026-07-04`: `.3.5` closes overall Perl reference trace no-drift and converts the required backend parity work
  into `.4.*` leaves. The common mdBook trace contract is neutral: Perl namespaces are reference vocabulary, while
  Rust/future variants must provide equivalent controls, levels, event classes, sink behavior, and default quiet
  behavior in their own idiom.
- `2026-07-04`: `.4.1` maps the Rust trace parity design before code. Because `linkedspec-core` owns parser,
  validation, compiler, dependency-map, and compiled-type surfaces, shared Rust trace level/config/event primitives
  must be visible from `linkedspec-core` rather than living only in `linkedspec-runtime`. Runtime execution,
  generated-plan execution, staged parser dispatch, and generated-source parser entrypoints reuse that same model.
  Existing quiet APIs stay the compatibility default; `.4.2` adds explicit traced configuration and sink routing
  before `.4.3`/`.4.4` emit compile/runtime events.

## Open Questions

- Rust trace controls/levels/sinks: implement the shared Rust configuration and output routing model without
  changing default quiet parse/compile/execute behavior.
- Required backend parity: Rust and future variants must implement equivalent trace capabilities before claiming trace
  parity; the current Perl-only surface is reference progress, not parity closeout.
- Auto-instrumentation (`Devel::*`/aspect style) is not the preferred first path: generated template instrumentation
  and owner-level trace wrappers are more portable and reviewable.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-06-19` | (scaffold) | assessed existing Trace.pm + ran `LINKEDSPEC_TRACE_LEVEL=debug` | framework exists + works; gaps = discoverability + coverage |
| `2026-07-04` | `.1` | `rg` trace call-site inventory; `dump_parser_source` probe; routed debug trace probe to `/tmp/linkedspec_trace_audit.log`; direct facade/owner state probes; Rust trace search | PASS — audit recorded; generated handler control flow is not exhaustively traced; CLI/docs and coverage gaps are explicit |
| `2026-07-04` | `.2` | `perl -c bin/linkedspec`; `perl -c -Iperl t/trace_cli.t`; `prove -v -Iperl t/trace_cli.t`; mdBook; Knowledge Map; memory/doctrine; whitespace; `tools/run_ci_local.sh` | PASS — CLI help exposes trace flags; routed trace file is non-empty; stdout remains canonical parser JSON; full local CI passes with phase0 1021 green |
| `2026-07-04` | `.3` | task-tree split review; `bash scripts/check_memory_architecture.sh`; `bash scripts/check_doctrines.sh`; `bash knowledge-map/scripts/check_knowledge_map.sh`; `git diff --check` | PASS — coverage extension split before code |
| `2026-07-04` | `.3.1` | `perl -c -Iperl perl/LinkedSpec/Trace.pm`; `perl -c -Iperl t/trace_generated_handler_branch.t`; `prove -v -Iperl t/trace_generated_handler_branch.t`; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh` | PASS — helper contract added before generated template instrumentation; full local CI passed with phase0 1021 green |
| `2026-07-04` | `.3.2` | `perl -c -Iperl perl/LinkedSpec/HandlerVariantEmitter.pm`; `perl -c -Iperl t/trace_generated_nonrep_dispatch.t`; `prove -v -Iperl t/trace_generated_nonrep_dispatch.t`; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh` | PASS — non-repetition generated handler branch decisions traced; repetition source was deferred until `.3.3` |
| `2026-07-04` | `.3.3` | `perl -c -Iperl perl/LinkedSpec/HandlerVariantEmitter.pm`; `perl -c -Iperl t/trace_generated_rep_dispatch.t`; `prove -v -Iperl t/trace_generated_rep_dispatch.t`; `prove -v -Iperl t/trace_generated_nonrep_dispatch.t`; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh` | PASS — repetition generated handler loop decisions traced; full local CI passed with phase0 1021 green |
| `2026-07-04` | `.3.4` | `rg` trace call-site inventory; `wc -l` owner sizing; targeted RuleIR/EmitContext/ActionIR owner reads; memory/doctrine/Knowledge Map/whitespace gates | PASS — compile/ActionIR coverage split before code |
| `2026-07-04` | `.3.4.1` | `perl -c -Iperl perl/LinkedSpec/RuleIR.pm`; `perl -c -Iperl t/trace_ruleir_planning.t`; `prove -v -Iperl t/trace_ruleir_planning.t`; mdBook; Knowledge Map; memory/doctrine/whitespace; `bash tools/run_ci_local.sh` | PASS — RuleIR planning decisions traced through direct probes and normal descriptor compilation |
| `2026-07-04` | `.3.4.2` | `perl -c -Iperl perl/LinkedSpec/RuleIR/EmitContext.pm`; `perl -c -Iperl t/trace_emit_context_bridge.t`; `prove -v -Iperl t/trace_emit_context_bridge.t`; `prove -v -Iperl t/trace_ruleir_planning.t t/trace_emit_context_bridge.t`; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh` | PASS — EmitContext bridge and rewrite orchestration decisions traced through direct probes and Trace-lazy subprocess coverage; full local CI passed with phase0 1021 green |
| `2026-07-04` | `.3.4.3` | `perl -c -Iperl perl/LinkedSpec/ActionIR/Trace.pm`; `perl -c -Iperl perl/LinkedSpec/ActionIR/{Scanner.pm,ScannerCore.pm,CanonicalEvents.pm,Diagnostics.pm,RewritePipeline.pm}`; `perl -c -Iperl t/trace_actionir_pipeline.t`; `prove -v -Iperl t/trace_actionir_pipeline.t`; `prove -v -Iperl t/trace_ruleir_planning.t t/trace_emit_context_bridge.t t/trace_actionir_pipeline.t`; `prove -v -Iperl t/trace_generated_handler_branch.t t/trace_generated_nonrep_dispatch.t t/trace_generated_rep_dispatch.t`; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh` | PASS — ActionIR pipeline decisions traced through scanner/canonical/diagnostic/rewrite probes, attached-if closure handling, and Trace-lazy subprocess coverage; full local CI passed with phase0 1021 green |
| `2026-07-04` | `.3.4.4` | `perl -c -Iperl perl/LinkedSpec/ActionIR/{FlowExpr.pm,ValueExpr.pm,ArrayPipeline.pm,DeclareMethod.pm,ControlFlow.pm}`; `perl -c -Iperl t/trace_actionir_compact_lowerers.t`; `prove -v -Iperl t/trace_actionir_compact_lowerers.t`; `prove -v -Iperl t/trace_ruleir_planning.t t/trace_emit_context_bridge.t t/trace_actionir_pipeline.t t/trace_actionir_compact_lowerers.t`; `prove -v -Iperl t/actionir_ast_parser.t t/trace_actionir_compact_lowerers.t`; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh` | PASS — compact lowerer decisions traced through production owner dispatch and Trace-lazy subprocess coverage; full local CI passed with phase0 1021 green |
| `2026-07-04` | `.3.4.5` | `perl -c -Iperl perl/LinkedSpec/ActionIR/MethodLowering.pm`; `perl -c -Iperl t/trace_actionir_method_lowering.t`; `prove -v -Iperl t/trace_actionir_method_lowering.t`; `prove -v -Iperl t/trace_ruleir_planning.t t/trace_emit_context_bridge.t t/trace_actionir_pipeline.t t/trace_actionir_compact_lowerers.t t/trace_actionir_method_lowering.t`; `prove -v -Iperl t/actionir_ast_parser.t t/trace_actionir_method_lowering.t`; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh` | PASS — MethodLowering decisions traced through production owner dispatch and Trace-lazy subprocess coverage; full local CI passed with phase0 1021 green |
| `2026-07-04` | `.3.4.6` | representative debug routed descriptor-compile probe across return/set/receiver/control paths; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh` | PASS — normal compile path emits `rule_ir`, `emit_context`, `actionir:scanner`, `actionir:rewrite_pipeline`, `actionir:control_flow`, and `actionir:method_lowering` decisions together; full local CI passed with phase0 1021 green |
| `2026-07-04` | `.3.5` | `perl bin/linkedspec --help`; `rg -n 'LINKEDSPEC_TRACE|trace_level|trace_log|--trace|\bTrace\b|\btrace\b' rust --glob '!**/tests/corpus/**'`; `prove -v -Iperl t/trace_cli.t t/trace_generated_handler_branch.t t/trace_generated_nonrep_dispatch.t t/trace_generated_rep_dispatch.t t/trace_ruleir_planning.t t/trace_emit_context_bridge.t t/trace_actionir_pipeline.t t/trace_actionir_compact_lowerers.t t/trace_actionir_method_lowering.t` | PASS — CLI contract remains discoverable, Perl reference trace suite passes, and Rust still has no trace API/control hits outside corpus fixtures; backend parity is split into `.4.*` before code |
| `2026-07-04` | `.4.1` | Rust source inventory: `rust/README.md`; `linkedspec-core::{parser,validation,compiler,types}`; `linkedspec-runtime::{spec_parser,engine,runtime,source_emitter}`; public Rust test harnesses; `mdbook build docs/linkedspec-book`; Knowledge Map; memory/doctrine; `git diff --check`; `bash tools/run_ci_local.sh` | PASS — Rust trace parity has an owner map before code; shared trace primitives must be core-visible; runtime/generated/staged entrypoints must preserve default quiet behavior and route through explicit traced configuration in later leaves. Note: an over-broad `cargo test` attempt failed in existing `linkedspec-runtime` integration tests (157 passed, 9 failed) with no Rust source diff, so it is recorded but not used as this docs/design leaf's acceptance gate. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| (creation) | (with the triage WIP commit) | Scaffold owning the trace directives. |
| `.1` | `9085a026` (`TRACE-OBSERVABILITY.1 - audit trace coverage gaps`) | Coverage audit and plan; no runtime/code behavior change. |
| `.2` | `30981c44` (`TRACE-OBSERVABILITY.2 - add trace CLI control`) | CLI/docs control; no trace coverage expansion yet. |
| `.3` | `8e371460` (`TRACE-OBSERVABILITY.3 - split trace coverage extension`) | Split Perl reference coverage extension into executable child leaves; no runtime/code behavior change. |
| `.3.1` | `95b84fab` (`TRACE-OBSERVABILITY.3.1 - add generated-handler trace helper seam`) | Helper contract for emitted generated handler branch decisions; no template call-site wiring yet. |
| `.3.2` | `08e7a885` (`TRACE-OBSERVABILITY.3.2 - trace non-repetition generated dispatch`) | Non-repetition generated handler template call-site wiring. |
| `.3.3` | `a225db82` (`TRACE-OBSERVABILITY.3.3 - trace repetition generated paths`) | Repetition generated handler template loop/min/max/zero-progress branch call-site wiring. |
| `.3.4` | `f488d0ed` (`TRACE-OBSERVABILITY.3.4 - split compile action trace coverage`) | Split compile/ActionIR trace coverage into signoff-sized sub-leaves; no runtime/code behavior change. |
| `.3.4.1` | `b36a9386` (`TRACE-OBSERVABILITY.3.4.1 - trace RuleIR planning decisions`) | RuleIR planning decision trace call-site wiring. |
| `.3.4.2` | `c8cbd663` (`TRACE-OBSERVABILITY.3.4.2 - trace EmitContext owner bridge`) | EmitContext owner-bridge and rewrite orchestration trace call-site wiring. |
| `.3.4.3` | `8a29c712` (`TRACE-OBSERVABILITY.3.4.3 - trace ActionIR pipeline decisions`) | Scanner/canonical/diagnostic/rewrite-pipeline ActionIR trace call-site wiring. |
| `.3.4.4` | `276c333e` (`TRACE-OBSERVABILITY.3.4.4 - trace compact ActionIR lowerers`) | Compact lowerer ActionIR trace call-site wiring outside `MethodLowering`. |
| `.3.4.5` | `cfe2d9d1` (`TRACE-OBSERVABILITY.3.4.5 - trace MethodLowering decisions`) | MethodLowering ActionIR trace call-site wiring. |
| `.3.4.6` | `8fa7243a` (`TRACE-OBSERVABILITY.3.4.6 - close compile ActionIR trace coverage`) | Compile/ActionIR coverage closeout probe/docs. |
| `.3.5` | `c623d6ec` (`TRACE-OBSERVABILITY.3.5 - close trace contract and split parity`) | Variant-neutral trace contract closeout and `.4.*` backend parity split. |
| `.4.1` | `pending` (`TRACE-OBSERVABILITY.4.1 - map Rust trace parity design`) | Rust owner-boundary and entrypoint inventory before trace code. |

## Changelog

- `2026-06-19`: Created to own the user's trace directives (discoverable CLI control + comprehensive
  "see everything" trace). Recorded the existing Trace.pm framework + env-var control + the two gaps
  (discoverability, coverage).
- `2026-07-04`: Closed `.1` read-only coverage audit. Current trace is useful but not exhaustive: pipeline
  boundaries, parser/rule handler wrappers, selected decisions, dumps, and mark/capture events are traced; generated
  handler branch/control-flow decisions and most ActionIR owner branches are not. `.2` is now the PNT frontier.
- `2026-07-04`: Closed `.2` CLI/docs control. `bin/linkedspec` now exposes the existing trace API from the command
  line while routed trace output keeps parser JSON stdout stable. `.3` is now the PNT frontier for Perl reference
  coverage extension.
- `2026-07-04`: Split `.3` before implementation into helper-seam, non-repetition generated dispatch, repetition
  generated dispatch, compile/ActionIR owner-scope, and coverage-closeout leaves. `.3.1` is now the PNT frontier.
- `2026-07-04`: Closed `.3.1` helper seam. `LinkedSpec::Trace::trace_generated_handler_branch(%args)` is the
  owner-level contract for emitted branch decisions; `.3.2` is now the PNT frontier for non-repetition template
  call sites.
- `2026-07-04`: Closed `.3.2` non-repetition generated dispatch. Debug trace now reports non-REP generated
  match/miss, acode index, AND sequence, bcode call/result, and `LX` no-match decisions; `.3.3` is now the PNT
  frontier for repetition templates.
- `2026-07-04`: Closed `.3.3` repetition generated paths. Debug trace now reports REP loop entry,
  per-iteration success/failure, min-satisfied stop decisions, max-bound continuation/cutoff, `REP_ACODE`
  match/acode-index dispatch, and bcode REP zero-progress cutoffs. `.3.4` is now the PNT frontier for
  compile/ActionIR owner scopes and branch decisions.
- `2026-07-04`: Split `.3.4` before code after read-only owner sizing showed the compile/ActionIR surface is too
  broad for one signoff slice. `.3.4.1` became the PNT frontier for RuleIR planning trace decisions and has since
  closed.
- `2026-07-04`: Closed `.3.4.1` RuleIR planning trace. Debug trace now reports RuleIR collection routing,
  handler-variant selection, action-mode/execution-shape planning, split-boundary marker lowering, and mixed-action
  validation decisions. `.3.4.2` became the PNT frontier and has since closed.
- `2026-07-04`: Closed `.3.4.2` EmitContext owner-bridge trace. Debug trace now reports ActionIR owner package/
  callback/dependency bridge decisions, function-registry and bare-symbol-kind injection, rewrite compatibility
  fallback paths, canonical rewrite-pipeline use, and rule emit-context build scopes. `.3.4.3` is now the PNT
  frontier for scanner/canonical/diagnostic/rewrite-pipeline trace decisions.
- `2026-07-04`: Closed `.3.4.3` ActionIR pipeline trace. Debug trace now reports scanner helper-event discovery,
  canonical helper queue/fallback decisions, diagnostic unresolved/unsupported helper handoffs, rewrite-rule and
  canonical-lowering decisions, RAW_PERL/unmatched-event fallbacks, and implicit attached-if closure handling.
  `.3.4.4` is now the PNT frontier for compact lowering owner trace coverage outside `MethodLowering`.
- `2026-07-04`: Closed `.3.4.4` compact ActionIR lowerer trace. Debug trace now reports flow/value expression,
  array-pipeline, declaration, assignment, and compact control-flow branch decisions outside `MethodLowering`.
  The book and task tree also now state the trace capability contract as variant-agnostic; `.3.4.5` is now the PNT
  frontier for `ActionIR::MethodLowering` trace coverage.
- `2026-07-04`: Closed `.3.4.5` MethodLowering trace. Debug trace now reports helper-family, AST lowering/fallback,
  receiver-chain, assignment/mutation, mutation-slot, unsupported-helper, return-payload, and assignment-scope
  decisions for `ActionIR::MethodLowering`. `.3.4.6` is now the PNT frontier for compile/ActionIR coverage
  closeout probes/docs.
- `2026-07-04`: Closed `.3.4.6` compile/ActionIR coverage closeout. A normal descriptor compile now demonstrates
  the planned compile/ActionIR trace namespaces together through MethodLowering while preserving ActionIR readiness.
  `.3.5` is now the PNT frontier for overall trace closeout and backend parity split.
- `2026-07-04`: Closed `.3.5` trace contract/no-drift closeout. The mdBook now presents the external trace
  contract as variant-neutral behavior, the Perl reference trace suite remains green, Rust trace inventory still
  has no API/control hits outside corpus fixtures, and `.4.1` is now the PNT frontier for Rust trace parity design.
- `2026-07-04`: Closed `.4.1` Rust trace parity design inventory. The Rust trace contract now maps onto
  core-visible shared trace primitives, compile/spec-parser/staged-dispatch owner events, runtime/generated-plan
  branch events, and default-quiet compatibility. `.4.2` is now the PNT frontier for Rust trace controls, levels,
  and sinks.
