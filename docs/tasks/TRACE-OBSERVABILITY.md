# TRACE-OBSERVABILITY: a discoverable CLI + comprehensive "see everything" trace

## Metadata

- Tree ID: `TRACE-OBSERVABILITY`
- Status: `done`
- Roadmap lane: `Overall roadmap — engine observability / developer experience`
- Created: `2026-06-19`
- Last updated: `2026-08-26` (`.5.4` aligns staged admission proof and canonically closes corrective `.5`)
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

**The two original gaps and corrective parity/proof repair `.5` are closed:**
1. **Discoverability/CLI:** `TRACE-OBSERVABILITY.2` closed the first discoverability gap with
   `bin/linkedspec`, a command-line compile/run runner that exposes `--trace LEVEL`, `--trace-file`,
   `--trace-mode`, `--trace-reset`, and `--trace-emoji`, and with mdBook/TOOLBOX documentation.
2. **Coverage/parity:** `.3.*` closed the Perl reference generated-handler and compile/ActionIR coverage boundary,
   `.4.2` through `.4.4` added Rust controls, compile/spec-parser/staged-dispatch events, and runtime branch/
   mark/capture events, and `.4.5` proved the mdBook-documented external trace capability contract across Perl and
   Rust while recording the future-variant checklist.

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
- At the time of the `.1` audit, Rust had no analogous trace API/sink surface in `rust/linkedspec-runtime`; `rg`
  found no runtime trace implementation beyond ordinary test variables named `log`. `TRACE-OBSERVABILITY.4` now owns
  Rust/future trace parity work, and `.4.2` through `.4.4` have since added Rust controls, compile/spec-parser/
  staged-dispatch events, and runtime branch/mark/capture events.

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
   instead of pretending the current Perl-only trace surface already covers Rust. `.4.1` mapped the neutral mdBook
   contract onto Rust owner boundaries; `.4.2` added Rust trace controls, levels, sinks, and traced entrypoints;
   `.4.3` added Rust compile/spec-parser/staged-dispatch events; `.4.4` added runtime dispatch/branch/mark/capture
   events; and `.4.5` closed the cross-variant parity proof, allowing Rust to claim parity for the documented
   external trace capability contract.

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

- ID: `TRACE-OBSERVABILITY` · Status: `done` · Children: `.1`, `.2`, `.3.{1..5}`, `.4.{1..5}`
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
    and generated-rule family plan execution. `.4.2` has since added the shared Rust trace controls, levels, sinks,
    event primitives, and traced entrypoints; `.4.3` has since added parser/compiler/staged-dispatch scope and
    decision events, `.4.4` has since added interpreter/generated-plan runtime branch events, and `.4.5` has since
    proved cross-variant contract parity so Rust can claim trace parity for the documented external capability
    contract.
  Verification: Rust source inventory; `cargo test` attempted and failed only in the existing
    `linkedspec-runtime` integration test target (157 passed, 9 failed) with no Rust source diff; accepted `.4.1`
    gates were `mdbook build docs/linkedspec-book`, `bash knowledge-map/scripts/check_knowledge_map.sh`,
    `bash scripts/check_memory_architecture.sh`, `bash scripts/check_doctrines.sh`, `git diff --check`, and
    `bash tools/run_ci_local.sh`.
  Commit: `eb0b23a8` (`TRACE-OBSERVABILITY.4.1 - map Rust trace parity design`)
- ID: `TRACE-OBSERVABILITY.4.2` · Status: `done` (closed 2026-07-04)
  Goal: Rust trace controls, levels, and sinks — implement the Rust-facing configuration model and output routing
    equivalent to the documented contract. Preserve default-quiet behavior for existing `parse_spec`, `compile`,
    `Engine::execute`, and generated parser entrypoints while adding explicit traced entrypoints/config plumbing.
  Acceptance: done — `linkedspec-core::trace` now owns the shared Rust trace control layer: `TraceLevel`,
    `TraceConfig`, `TraceSinkMode`, `TraceEmitter`, `DUMP_*` constants, environment-derived configuration,
    stdout/routed-file/mirror sinks, routed-file reset, and structured event primitives. `linkedspec-runtime`
    re-exports that model and adds explicit traced entrypoints beside core parse/validate/compile, full-spec
    user-function parsing, staged parse jobs, interpreter execution, generated-plan execution, generated parser
    execution, and emitted generated module `parse_with_trace(...)`. Existing untraced APIs remain default-quiet
    and output-compatible. Compile/spec-parser/staged-dispatch event emission has since landed in `.4.3`; runtime
    branch event emission has since landed in `.4.4`.
  Verification: `cargo test -p linkedspec-core trace`; `cargo test -p linkedspec-runtime --test trace_controls`;
    `cargo test -p linkedspec-runtime --test source_emitter`; `cargo fmt`; `mdbook build docs/linkedspec-book`;
    `bash knowledge-map/scripts/check_knowledge_map.sh`; `bash scripts/check_memory_architecture.sh`;
    `bash scripts/check_doctrines.sh`; `git diff --check`; `bash tools/run_ci_local.sh`.
  Commit: `a39da150` (`TRACE-OBSERVABILITY.4.2 - add Rust trace controls`)
- ID: `TRACE-OBSERVABILITY.4.3` · Status: `done` (closed 2026-07-04)
  Goal: Rust compile/spec-parser trace events — add structured compile-side scope and decision events equivalent
    to the Perl reference contract.
  Acceptance: done — Rust traced core entrypoints now emit parse, validation-pass, compile function/rule, and
    dependency-regex mapping scopes/decisions; runtime full-spec parsing traces user-function-definition parser
    phases, function projection, and stripped-rule parsing; and staged parse-job traced entrypoints report
    normalize, stable queue sort, resolve, load, compile, and execute decisions. Existing untraced and quiet
    traced outputs remain output-compatible.
  Verification: `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls`;
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-core trace`;
    `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter`; `cargo fmt`;
    mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh`.
  Commit: `7495fb21` (`TRACE-OBSERVABILITY.4.3 - add Rust compile trace events`)
- ID: `TRACE-OBSERVABILITY.4.4` · Status: `done` (closed 2026-07-04)
  Goal: Rust runtime dispatch and branch trace events — add structured runtime-handler/interpreter branch events
    equivalent to generated-handler branch tracing.
  Acceptance: done — Rust traced runtime entrypoints now report interpreted `rust_runtime:engine:*` execution scopes,
    top-rule selection, rule entry/exit, recursion cutoffs, passive-terminal and child dispatch, regex match/no-match,
    acode/bcode dispatch, AND-sequence slot decisions, lifecycle block execution/result, statement-form `if`/`switch`
    branches, lazy helper dispatch, helper `call(child)`, and mark/capture helper operations. Generated-plan traced
    execution now reports `rust_runtime:generated_plan:*` top-rule, family/direct-rule, child, recursion, regex,
    acode/bcode, and AND-sequence decisions while preserving traced/untraced output equality.
  Verification: focused Rust trace runtime tests, source-emitter tests, core trace tests, formatting, mdBook, Knowledge
    Map, memory/doctrine, whitespace, and local CI. Diagnostic full Rust runtime `integration_test` still has the
    known residual non-top-rule failures recorded in prior Rust trace design notes and is not the `.4.4` acceptance
    gate.
  Commit: `61289cc3` (`TRACE-OBSERVABILITY.4.4 - add Rust runtime trace events`)
- ID: `TRACE-OBSERVABILITY.4.5` · Status: `done` (closed 2026-07-04)
  Goal: Cross-variant trace parity closeout — run parity probes, update docs/Knowledge Map/toolbox, and define the
    reusable future-variant checklist.
  Acceptance: done — Rust can now claim parity for the mdBook-documented external trace capability contract:
    ordered levels, normal-entrypoint controls, stdout/routed-file/mirror sinks, routed-file reset/truncate,
    default-quiet behavior, structured scope events, decision/branch events, mark/capture/source-boundary events
    where implemented, and dump/log diagnostics. The claim is explicitly behavioral and does not require Rust to
    reuse Perl package names or internal event namespaces. Future variants inherit the mdBook checklist before they
    can make the same parity claim.
  Verification: Perl CLI help plus the nine-file Perl trace suite; Rust core trace tests including dump/log
    primitive coverage; Rust runtime trace controls tests; mdBook; Knowledge Map; memory/doctrine; whitespace;
    local CI.
  Commit: `pending` (`TRACE-OBSERVABILITY.4.5 - close trace parity proof`)
- ID: `TRACE-OBSERVABILITY.5` · Status: `done` (2026-08-26; corrective children `.1-.4` complete); Goal: Repair
  the Rust trace/progressive proof defects exposed by focused and canonical verification without changing untraced
  behavior, trace controls, event schemas, or other backends; Depends on: closed `.4.5` parity proof and exact clean
  discovery commit `3d509616aad854b6ce2f5ddaebc423024e865f84`.
- ID: `TRACE-OBSERVABILITY.5.1` · Status: `done` (`focused-signoff-complete` 2026-08-26; task-tree-first from exact clean
  `3d509616aad854b6ce2f5ddaebc423024e865f84`; no push); Goal: Make traced Rust compilation enforce the same
  already-current progressive static validator as ordinary compilation.
  Acceptance: reproduce one malformed dedicated `dispatch_span` program that ordinary `compile(...)` rejects but
  `compile_with_trace(...)` accepts; prove `compile_with_events` omitted only
  `validate_progressive_span_dispatch_contract` while retaining recursive-observation, staged-parse, and compiled-
  regex validators; add the missing validation call in the identical relative order used by ordinary compile; add
  a regression proving traced/untraced rejection code equality and retain valid trace output/result equality; change
  no syntax, runtime, marker/provenance, generated format, trace namespace/event shape, public/outward surface,
  other backend, rollout, or canonical topology; synchronize task, Knowledge, trace docs/book, live docs, memory,
  and roadmaps.
  Verification tier: `focused` — one missing call in an existing private traced compiler path plus focused
  regression and durable truth; no admission, rollout, format, public, infrastructure, storage, finite-capacity,
  milestone, or canonical-topology boundary moves.
  Focused checks: exact ordinary-vs-traced RED before repair and equality GREEN after; valid compile trace control;
  core library; progressive dormant/contract direct dependents; exact private-authority failure plus admission-
  history root cause under `.5.3`; progressive/recognition/staged governance;
  Knowledge, rendered mdBook, bounded histories, memory, all nine doctrines, exact no-runtime/no-format/no-public/
  no-other-backend diff, and `git diff --check`.
  Canonical trigger: `none` — escalate only if repair unexpectedly changes a designated boundary.
  Checklist: [x] clean activation/task ownership [x] Knowledge/trace/progressive authority retrieval [x] exact RED
  [x] one-call repair [x] regression/equality proof [x] direct-dependent/no-drift proof [x] durable synchronization
  [x] focused signoff [x] atomic commit/brief/clean handoff.
  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE** — exact malformed progressive program rejects through ordinary compile and is accepted
    only through traced compile at clean activation HEAD.
  - [x] **ROOT CAUSE (WHY + WHERE)** — `rust/linkedspec-core/src/compiler.rs::compile_with_events` source and call-
    path probes prove the progressive validator omission and no alternative validation owner.
  - [x] **FIX** — call the existing validator in traced compilation at the same position as ordinary compilation;
    add no replacement semantics.
  - [x] **ADDRESSED (verified)** — focused regression proves exact ordinary/traced diagnostic equality while the
    valid traced compile event/result contract remains GREEN.
  - [x] **NO REGRESSION** — core, trace, admitted/dormant progressive direct dependents, governance, doctrines, and
    no-drift guards pass; the separately stale 3/4 private-authority proof is history-rooted and owned by `.5.3`.
  - [x] **LOCKSTEP** — task, Knowledge, architecture/Toolbox, roadmaps, live docs, memory, and mdBook no longer claim
    traced validation parity without executable proof.
  Activation evidence: exact clean `git status --short --untracked-files=all` at
  `3d509616aad854b6ce2f5ddaebc423024e865f84`; zero-byte brief; no rendered book; no background job. Focused staged
  verification already established the baseline source asymmetry against parent `e37a8b77`; this leaf must reproduce
  it independently at the current clean HEAD before repair.
  Completion evidence: exact pre-fix regression accepted traced compilation and rejected ordinary compilation;
  after the one-call repair the same test passes with exact diagnostic equality, and the valid quiet trace control
  remains GREEN. Core trace 7/7, ordinary dormant progressive discovery 0/0, admitted cfg consumer 1/1 across four
  routes, and progressive/recognition/staged governance pass. The cfg private-authority target is intentionally
  recorded 3/4 here: Git proves its sole route-snapshot failure began when `5c4d4218` admitted the separate contract
  consumer; `.5.3` owns the repair. Knowledge, rendered/inspected mdBook, bounded histories, memory, doctrines,
  formatting, whitespace, and exact scope guards pass. Commit subject is
  `TRACE-OBSERVABILITY.5.1 - align traced progressive validation`; no push.
- ID: `TRACE-OBSERVABILITY.5.2` · Status: `done` (`focused-signoff-complete` 2026-08-26; task-tree-first from exact clean
  `915cd1a7c9b3d11676e77dfde1c005ba0566334f`; no push); Goal: Restore required `child_dispatch` lifecycle events on
  interpreted and generated-plan gap-aware child-entry routes before later proof repair and parent closeout.
  Acceptance: reproduce the existing interpreted and generated trace-control failures while their paired untraced
  results remain correct; use trace/runtime owner probes to prove action-edge gap-aware child entry bypasses the
  normal `execute_child_rule` dispatch-event seam through `execute_child_rule_with_entry_slot`; repair the shared
  seam so both routes emit one balanced dispatch/result lifecycle with the same rule/slot/result vocabulary as
  ordinary child dispatch; preserve gap/cursor/capture/result behavior, event ordering outside the missing pair,
  default quietness, trace controls/sinks, generated format, public/outward surfaces, other backends, rollout, and
  canonical topology; synchronize task, Knowledge, trace docs/book, live docs, memory, architecture, and roadmaps.
  Verification tier: `focused` — bounded shared Rust runtime trace-event repair plus exact interpreted/generated
  regressions; no admission, rollout, format, public, infrastructure, storage, finite-capacity, milestone, or
  canonical-topology boundary moves.
  Focused checks: exact two-test RED/GREEN; complete `trace_controls`; source-emitter trace dependent; core trace;
  lossless-gap and staged/progressive direct dependents; recognition/progressive/staged governance; Knowledge,
  rendered mdBook, bounded histories, memory, all nine doctrines, exact no-result/no-format/no-public/no-other-
  backend diff, and `git diff --check`.
  Canonical trigger: `none` — escalate only if the shared repair changes event schema, generated format, runtime
  results, admission/rollout, public/outward behavior, or another designated boundary.
  Checklist: [x] clean activation/task ownership [x] Knowledge/runtime/toolbox retrieval [x] exact two-route RED
  [x] shared-seam root cause [x] balanced event repair [x] interpreted/generated GREEN [x] direct-dependent/no-
  drift proof [x] durable synchronization [x] focused signoff [x] atomic commit/brief/clean handoff.
  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE** — exact interpreted and generated gap-aware tests fail only because the expected
    `child_dispatch` event is absent; paired untraced values/cursors remain correct.
  - [x] **ROOT CAUSE (WHY + WHERE)** — `RuntimeContext` and generated-plan call-path probes prove both action-edge
    routes enter `execute_child_rule_with_entry_slot`, which omits the normal dispatch/result event pair.
  - [x] **FIX** — emit one balanced child-dispatch lifecycle at the shared gap-aware seam using the existing event
    namespace/detail vocabulary; do not duplicate events on the normal child path.
  - [x] **ADDRESSED (verified)** — both exact regressions and complete trace controls pass with unchanged paired
    untraced results and expected event order.
  - [x] **NO REGRESSION** — source-emitter/core trace, gap/staged/progressive dependents, governance, doctrines, and
    exact no-format/no-public/no-other-backend guards pass.
  - [x] **LOCKSTEP** — task, Knowledge, architecture/Toolbox, roadmaps, live docs, memory, and mdBook describe the
    restored gap-aware events and retain `.5.3` as the next corrective leaf.
  Activation evidence: exact clean `git status --short --untracked-files=all` at
  `915cd1a7c9b3d11676e77dfde1c005ba0566334f`; zero-byte brief; no rendered book; no background job. The prior
  staged-marker verification and current source inventory identify the two failing trace tests, but this leaf must
  independently reproduce both at the clean activation commit before changing runtime code.
  Completion evidence: clean pre-fix `trace_controls` is 9/11 with only the interpreted/generated tests failing on
  absent `child_dispatch`; both already assert traced/untraced result equality first. Git proves native gap commit
  `5c4e9d50` and generated gap commit `9e6ade98` added parallel entry-slot seams after trace commit `61289cc3`
  without its event pair. Normal child wrappers now delegate to the entry-slot seam in each executor, and that one
  local owner emits the unchanged dispatch/result lifecycle for `None` and typed gap slots. Complete trace controls
  are 11/11, generated source is 6/6, exact Rust gap admission is 1/1, core trace is 7/7, and gap/recognition/
  progressive/staged governance passes. Knowledge, rendered/inspected mdBook, bounded histories, memory, all nine
  doctrines, formatting, whitespace, and exact no-result/no-format/no-public/no-other-backend guards pass. Commit
  subject is `TRACE-OBSERVABILITY.5.2 - restore gap-aware child trace`; no push.
- ID: `TRACE-OBSERVABILITY.5.3` · Status: `done` (`focused-signoff-complete` 2026-08-26; task-tree-first from exact clean
  `e9d28f69f6c0357eccf2237952eca1b5debdfcbe`; no push; discovered by `.5.1` focused direct-dependent proof);
  Goal: Repair the stale private progressive-authority route assertion left behind when
  `FUTURE-PARITY-BACKLOG.14.6.3.3` intentionally admitted the exact Rust contract consumer to canonical CI.
  Evidence: the cfg-enabled authority test passes its three semantic tests but
  `private_authority_has_no_ordinary_or_canonical_route` rejects the now-required
  `--test progressive_span_dispatch_contract` route; `git show 5c4d4218` proves that admission added the exact
  tracked-file requirement and invocation without advancing the authority test's earlier snapshot. Preserve the
  private authority target's own dormant status while updating its distinction between the private authority and
  admitted contract consumers.
  Acceptance: reproduce the cfg-enabled target at 3/4 with only the stale route-snapshot test failing; prove Git
  admission commit `5c4d4218` intentionally added one exact tracked contract file and cfg-enabled canonical
  consumer without routing the private authority target; update the proof to require the admitted contract route
  exactly once while continuing to forbid the private authority route; retain the three private semantic tests,
  ordinary dormant discovery, admitted contract execution, neutral topology, production/generated/public/outward
  behavior, all backends, and every rollout value; synchronize task, Knowledge, trace/progressive docs/book, live
  docs, memory, architecture, and both roadmaps. Parent/tree closeout is deferred to `.5.4`.
  Verification tier: `focused` — this leaf changes one private topology assertion and no production, admission,
  rollout, format, public, infrastructure, storage, finite-capacity, milestone, or canonical-topology boundary.
  Focused checks: exact cfg authority RED 3/4 then GREEN 4/4; ordinary authority/contract 0/0 each; progressive/
  recognition/staged/gap governance; exact route cardinality/history; Knowledge, rendered mdBook, bounded histories,
  memory, all nine doctrines, no-production/no-format/no-public/no-other-backend diff, and `git diff --check`.
  Canonical trigger: `none` — `.5.4` owns the separately exposed proof repair and parent/tree canonical closeout.
  Checklist: [x] clean activation/task ownership [x] Knowledge/progressive/CI authority retrieval [x] exact 3/4 RED
  [x] admission-history root cause [x] exact route-proof repair [x] dormant/admitted GREEN [x] no-drift proof
  [x] durable synchronization [x] focused signoff [x] atomic commit/brief/clean handoff.
  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE** — cfg private authority is 3/4 and fails only because its pre-admission test forbids
    the now-required admitted contract route.
  - [x] **ROOT CAUSE (WHY + WHERE)** — exact Git/source probes prove `5c4d4218` added the contract file/command once,
    did not route the private authority target, and left the earlier assertion unchanged.
  - [x] **FIX** — distinguish the two consumers: forbid `progressive_span_dispatch_authority`, require the tracked
    `progressive_span_dispatch_contract.rs` and its cfg-enabled `--test progressive_span_dispatch_contract` route
    exactly once, and retain neutral contract presence.
  - [x] **ADDRESSED (verified)** — cfg authority 4/4, ordinary authority/contract 0/0 each, and exact route cardinality
    are GREEN.
  - [x] **NO REGRESSION** — progressive/recognition/staged/gap governance, doctrines, and scope guards pass without
    production/generated/public/rollout/other-backend movement; the attempted canonical gate exposed `.5.4` only.
  - [x] **LOCKSTEP** — task/root index, Knowledge, architecture/Toolbox, roadmaps, live docs, memory, and mdBook retain
    corrective `.5` as active and route the separately stale staged-admission snapshot to `.5.4`.
  Activation evidence: exact clean `git status --short --untracked-files=all` at
  `e9d28f69f6c0357eccf2237952eca1b5debdfcbe`; zero-byte brief; no rendered book; no background job. `.5.1` recorded
  the prior 3/4 failure and admission history, but this leaf must reproduce it independently at the clean activation
  commit before changing the proof.
  Completion evidence: exact pre-fix cfg execution is 3/4 with only the stale pre-admission route assertion failing;
  Git proves `5c4d4218` added one tracked contract input and one cfg-enabled contract command without touching or
  routing the authority test. The renamed proof continues to forbid the authority target and now requires each
  admitted contract route marker exactly once. Cfg authority is 4/4; ordinary authority/contract discovery is 0/0
  each; progressive, recognition, staged, and gap governance pass. Knowledge, rendered/inspected mdBook, bounded
  histories, memory, all nine doctrines, formatting, whitespace, and exact scope guards pass. A staged canonical
  attempt stopped at 141/143 in the separately stale Perl staged-admission snapshot: neutral truth is already 79
  and the Rust consumer is already `dormant_red`, while that proof still expects 78 / `pending_absent`. `.5.4` owns
  that repair and canonical closeout. Commit subject is `TRACE-OBSERVABILITY.5.3 - align progressive authority proof`;
  no push.
- ID: `TRACE-OBSERVABILITY.5.4` · Status: `done` (`canonical-signoff-complete` 2026-08-26; task-tree-first from exact clean
  `0411758f061a444d8d5f64cc7c5d3e5816937c35`; no push); Goal: Align the Perl staged-AST admission consumer's immutable inventory
  snapshot with the already-landed Rust staged marker state, then canonically close corrective `.5` and this tree.
  Evidence: exact staged canonical execution of `t/staged_ast_enrichment_perl_contract.t` passes 141/143 and fails
  only because it expects 78 neutral mutations instead of the current 79 and Rust `pending_absent` instead of the
  current `dormant_red`; Git proves `.14.7.4.0` commit `e37a8b77` owns both neutral truth advances.
  Acceptance: from clean `.5.3`, prove the exact Git origin and current inventory values; change only those two
  stale expected values; retain all 143 Perl assertions, production behavior, rollout, registries, generated
  formats, public/outward surfaces, and other backends; run focused staged governance plus exact staged receipt-bound
  `bash tools/run_ci_local.sh`; synchronize task, Knowledge if a new durable fact is established, roadmaps,
  architecture/Toolbox, mdBook, live docs, and memory; perform any mechanically required bounded-history rotation
  and finite-capacity authorization; commit atomically and clear the brief.
  Verification tier: `canonical` — this leaf repairs a canonical admission proof and performs parent/tree closeout.
  Focused checks: exact Git-origin diff; 141/143 RED then 143/143 GREEN; neutral staged governance; live-status
  sixteen-row rotation; engineering-notes rollover segment `4990`; exact eighteen-file/seventeen-manifest-line
  measurement plus ADR `0090` route authorization; Knowledge, mdBook, histories, memory, doctrines, scope, whitespace.
  Canonical trigger: `admission proof + parent/tree closeout` — exact staged candidate must pass canonical local CI.
  Checklist: [x] exact clean activation [x] Knowledge retrieval [x] Git-origin proof [x] 141/143 reproduce
  [x] two-value snapshot repair [x] 143/143 focused GREEN [x] staged governance/no-drift [x] bounded-history controls
  [x] durable synchronization
  [x] exact staged canonical GREEN/receipt [x] atomic commit/brief/clean handoff.
  Activation evidence: exact clean `git status --short --untracked-files=all` at
  `0411758f061a444d8d5f64cc7c5d3e5816937c35`; zero-byte brief; no rendered book; no background job. Knowledge Map
  routes the staged carrier/admission fact to `docs/knowledge/perl-staged-ast-enrichment-carriers-admission.md`.
  Completion evidence: Git `-S` and exact `e37a8b77` diff prove Rust dormant-RED `.14.7.4.0` advanced neutral
  mutations 78→79 and Rust consumer `pending_absent`→`dormant_red` without updating the already-admitted Perl
  snapshot. The two expected values now match that immutable neutral truth; exact Perl execution is 143/143 and
  staged governance reports 79 mutations, five consumers/six routes, 37 diagnostics, nine rollout legs, and 35
  owners. Knowledge, rendered/inspected mdBook, bounded histories, memory, all nine doctrines, exact no-production/
  no-registry/no-format/no-rollout/no-public/no-other-backend guards, whitespace, mandatory engineering-notes
  rollover segment `4990`, and the staged receipt-bound canonical local gate pass. Commit subject is
  `TRACE-OBSERVABILITY.5.4 - align staged admission proof`; no push.
  Corrective parent `.5` and this tree close; staged Rust `.14.7.4.2` resumes from the clean handoff.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| — | _(empty)_ | `done` | Corrective `.5.1-.4` are complete; resume staged Rust `.14.7.4.2` after the clean `.5.4` landing. |

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
  Existing quiet APIs stay the compatibility default; `.4.2` has added explicit traced configuration and sink
  routing before `.4.3`/`.4.4` emit compile/runtime events.
- `2026-07-04`: `.4.3` adds Rust compile/spec-parser/staged-dispatch events using the shared `.4.2` emitter. Core
  traced entrypoints now report parse, validation-pass, compile rule/function, and dependency-regex decisions; the
  full-spec parser traces user-function-definition parsing and function projection; staged parse jobs trace
  normalize/queue/resolve/load/compile/execute phases. Runtime interpreter/generated-plan branch and mark/capture
  events remain `.4.4`.
- `2026-07-04`: `.4.4` adds Rust runtime branch events using the shared `.4.2` emitter and `.4.3` event style. The
  interpreted runtime records events in `RuntimeContext` only for traced entrypoints, then replays them through the
  caller-owned sink after execution. Generated-plan execution records equivalent plan/dispatch branches. Default quiet
  entrypoints remain output-compatible; `.4.5` has since proved cross-variant external trace parity.
- `2026-07-04`: `.4.5` closes the trace parity proof. Rust may claim parity for the mdBook-documented external
  capability contract because it now has equivalent controls, ordered levels, sink routing/reset, default-quiet
  behavior, compile/spec-parser/runtime scope and branch events, mark/capture/source-boundary events where
  implemented, and dump/log primitives. Future variants must pass the mdBook checklist before claiming parity.
- `2026-08-26`: corrective `.5.1` proves tracing had become a validation bypass only for residual progressive
  dispatch because `compile_with_events` omitted one existing validator call. Restore that call, not replacement
  semantics. The original full-parity claim stays reopened until `.5.2` restores gap-aware child-dispatch events;
  the unrelated stale private-authority admission snapshot is independently owned by `.5.3`.
- `2026-08-26`: corrective `.5.2` preserves the established event schema and consolidates each executor's normal
  child wrapper through its entry-slot seam. The seam emits one existing dispatch/result pair regardless of whether
  a gap slot is absent or present; no normal-path duplication, new namespace, or runtime-result change is needed.
- `2026-08-26`: corrective `.5.3` distinguishes the dormant private authority proof from the separately admitted
  contract consumer. It requires the tracked input and cfg command once while continuing to forbid any authority
  route. A canonical attempt then exposed a separately stale staged-admission snapshot, so `.5.3` lands focused and
  `.5.4` owns the proof repair plus parent/tree closeout.
- `2026-08-26`: corrective `.5.4` changes only the already-admitted Perl consumer's frozen neutral snapshot. Git
  assigns 79 mutations and Rust `dormant_red` to `.14.7.4.0` commit `e37a8b77`; 143/143 plus canonical proof close
  the corrective parent/tree without staged runtime or rollout movement.

## Open Questions

- Required backend parity: the original Perl/Rust proof closed at `.4.5`; corrective `.5.1-.2` restore later-
  discovered validation and gap-aware event regressions, and `.5.3-.4` repair proof drift only. Rust renewal and
  corrective closeout are current; future variants must satisfy the mdBook checklist before claiming trace parity.
- Auto-instrumentation (`Devel::*`/aspect style) remains not the preferred first path: generated template instrumentation
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
| `2026-07-04` | `.4.2` | `cargo test -p linkedspec-core trace`; `cargo test -p linkedspec-runtime --test trace_controls`; `cargo test -p linkedspec-runtime --test source_emitter`; `cargo fmt`; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh` | PASS — Rust trace levels/config/sink primitives, traced entrypoints, and emitted generated parser modules pass focused coverage; full local CI passed with phase0 1021 green |
| `2026-07-04` | `.4.3` | `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls`; `cargo test --manifest-path rust/Cargo.toml -p linkedspec-core trace`; `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter`; `cargo fmt`; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh` | PASS — Rust compile/spec-parser/staged-dispatch events now emit through routed debug traces while traced/untraced outputs remain equal; runtime branch events were deferred to `.4.4` and have since closed |
| `2026-07-04` | `.4.4` | `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls`; `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test source_emitter`; `cargo test --manifest-path rust/Cargo.toml -p linkedspec-core trace`; `cargo fmt`; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh` | PASS — Rust interpreted runtime and generated-plan runtime traces now emit rule/plan scopes, branch decisions, lifecycle events, helper dispatch, and mark/capture events while traced/untraced outputs remain equal. Diagnostic full Rust runtime `integration_test` still hits the known residual 9 failures and is not this leaf's acceptance gate. |
| `2026-07-04` | `.4.5` | `perl bin/linkedspec --help`; `prove -v -Iperl t/trace_cli.t t/trace_generated_handler_branch.t t/trace_generated_nonrep_dispatch.t t/trace_generated_rep_dispatch.t t/trace_ruleir_planning.t t/trace_emit_context_bridge.t t/trace_actionir_pipeline.t t/trace_actionir_compact_lowerers.t t/trace_actionir_method_lowering.t`; `cargo test --manifest-path rust/Cargo.toml -p linkedspec-core trace`; `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test trace_controls`; `cargo fmt`; mdBook; Knowledge Map; memory/doctrine; whitespace; `bash tools/run_ci_local.sh` | PASS — Perl reference and Rust trace suites prove the documented external trace capability contract; full local CI passed with phase0 1021 green. Rust can claim trace parity for that contract, and future variants inherit the mdBook checklist. |
| `2026-08-26` | `.5.1` | exact ordinary/traced RED then equality GREEN; valid quiet trace control; core trace 7/7; progressive ordinary 0/0 + cfg contract 1/1; private authority 3/4 root-cause probe; progressive/recognition/staged governance; fmt; Knowledge; rendered mdBook; histories; memory/doctrines; scope/whitespace | PASS — one existing validator call restores traced progressive static-validation equality without valid-result, event-schema, runtime, format, rollout, public, or other-backend movement. The separately stale private-authority route snapshot is owned by `.5.3`. |
| `2026-08-26` | `.5.2` | exact complete trace target RED 9/11 then GREEN 11/11; source emitter 6/6; Rust gap admission 1/1; core trace 7/7; gap/recognition/progressive/staged governance; fmt; Knowledge; rendered mdBook; histories; memory/doctrines; scope/whitespace | PASS — normal and typed-gap child entry share one traced local seam per executor and emit one existing dispatch/result pair with unchanged results, event schema, format, rollout, public surface, and other backends. |
| `2026-08-26` | `.5.3` | exact cfg authority RED 3/4 then GREEN 4/4; ordinary authority/contract 0/0 each; exact Git/route cardinality; progressive/recognition/staged/gap governance; fmt; Knowledge; rendered mdBook; histories; memory/doctrines; scope/whitespace | PASS focused — private authority remains unrouted and the admitted contract input/command remain exact. A later canonical attempt stopped at 141/143 on the separately stale staged-admission snapshot now owned by `.5.4`. |
| `2026-08-26` | `.5.4` | exact 141/143 RED then 143/143 GREEN; Git-origin proof; neutral staged governance 79 mutations/five consumers/six routes; Knowledge; rendered mdBook; histories; memory/doctrines; exact no-drift; staged receipt-bound `bash tools/run_ci_local.sh` | PASS canonical — two immutable Perl expectations now reflect Rust dormant-RED truth from `e37a8b77`; corrective `.5`/tree close without production, registry, format, rollout, public, or other-backend movement. |

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
| `.4.1` | `eb0b23a8` (`TRACE-OBSERVABILITY.4.1 - map Rust trace parity design`) | Rust owner-boundary and entrypoint inventory before trace code. |
| `.4.2` | `a39da150` (`TRACE-OBSERVABILITY.4.2 - add Rust trace controls`) | Rust shared trace controls, levels, sinks, event primitives, and traced entrypoints. |
| `.4.3` | `7495fb21` (`TRACE-OBSERVABILITY.4.3 - add Rust compile trace events`) | Rust compile/spec-parser/staged-dispatch trace event wiring. |
| `.4.4` | `61289cc3` (`TRACE-OBSERVABILITY.4.4 - add Rust runtime trace events`) | Rust interpreted runtime and generated-plan branch/lifecycle/mark-capture trace event wiring. |
| `.4.5` | pending (`TRACE-OBSERVABILITY.4.5 - close trace parity proof`) | Cross-variant trace parity proof, Rust parity claim for the documented external capability contract, and future-variant checklist. |
| `.5.1` | pending (`TRACE-OBSERVABILITY.5.1 - align traced progressive validation`) | Existing-validator repair plus exact ordinary/traced diagnostic-equality regression; `.5.2` remains the active corrective frontier. |
| `.5.2` | pending (`TRACE-OBSERVABILITY.5.2 - restore gap-aware child trace`) | Interpreted/generated entry-slot seams now retain the existing child-dispatch lifecycle; `.5.3` is next. |
| `.5.3` | pending (`TRACE-OBSERVABILITY.5.3 - align progressive authority proof`) | Exact dormant-authority/admitted-contract topology proof; `.5.4` owns canonical closeout. |
| `.5.4` | pending (`TRACE-OBSERVABILITY.5.4 - align staged admission proof`) | Two-value staged-admission snapshot repair and corrective parent/tree canonical closeout. |

## Changelog

- `2026-06-19`: Created to own the user's trace directives (discoverable CLI control + comprehensive
  "see everything" trace). Recorded the existing Trace.pm framework + env-var control + the two gaps
  (discoverability, coverage).
- `2026-08-26`: Reopened corrective `.5`; `.5.1` restores traced progressive validation, `.5.2` owns gap-aware
  child-dispatch events, and `.5.3` owns the stale private-authority admission-route assertion.
- `2026-08-26`: Closed `.5.2`; both Rust runtime executors emit exactly one existing child dispatch/result pair
  for normal and gap-aware entry, trace controls are 11/11, and `.5.3` is the sole corrective frontier.
- `2026-08-26`: Closed focused `.5.3`; the private authority proof distinguishes its own dormancy from the exact
  admitted contract route. Canonical verification exposed the separate `.5.4` staged-admission snapshot blocker,
  which must close before staged Rust `.14.7.4.2` resumes.
- `2026-08-26`: Closed `.5.4`, corrective `.5`, and this tree; the admitted Perl proof now freezes 79 mutations and
  Rust `dormant_red`, passes 143/143 plus canonical signoff, and returns the clean frontier to staged Rust `.14.7.4.2`.
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
  branch events, and default-quiet compatibility. `.4.2` has since added Rust trace controls, levels, sinks, and
  traced entrypoints, `.4.3` has since added compile/spec-parser/staged-dispatch events, and `.4.4` has since added
  runtime branch/mark/capture events.
- `2026-07-04`: Closed `.4.2` Rust trace controls, levels, and sinks. `linkedspec-core::trace` now exposes the
  Rust control layer, `linkedspec-runtime::trace` re-exports it, and opt-in traced entrypoints exist beside core
  parse/validate/compile, runtime/full-spec/staged execution, generated-plan execution, generated parser execution,
  and emitted generated modules. `.4.3` has since closed compile/spec-parser/staged-dispatch events.
- `2026-07-04`: Closed `.4.3` Rust compile/spec-parser/staged-dispatch events. Routed debug traces now report core
  parse/validation/compile/dependency-regex owner decisions, full-spec user-function parser phases, and staged
  parse-job normalize/queue/resolve/load/compile/execute phases. `.4.4` has since closed runtime
  dispatch/branch/mark/capture events.
- `2026-07-04`: Closed `.4.4` Rust runtime trace events. Routed debug traces now report interpreted runtime
  rule scopes, recursion cutoffs, regex/acode/bcode/child dispatch decisions, lifecycle blocks, statement-form
  branch controls, helper `call(child)`, mark/capture helper operations, and generated-plan runtime dispatch events.
  `.4.5` is now the PNT frontier for cross-variant trace parity proof and the future-variant checklist.
- `2026-07-04`: Closed `.4.5` cross-variant trace parity proof. Perl reference CLI/help and trace suites, Rust
  core trace primitive tests, and Rust runtime trace controls tests prove the mdBook-documented external trace
  capability contract across Perl and Rust. Rust can now claim trace parity for that behavioral contract. The trace
  tree is done; future variants must pass the mdBook checklist before claiming parity.
