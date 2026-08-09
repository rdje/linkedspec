**What changed:** Closed the trace parity proof for the mdBook-documented external capability contract. Perl remains
the reference vocabulary, while Rust now has equivalent documented ordered levels, normal-entrypoint controls,
stdout/routed-file/mirror sinks, routed-file reset, default-quiet behavior, compile/spec-parser/runtime scope and
branch events, mark/capture/source-boundary events where implemented, and dump/log diagnostics. The common book now
records the checklist future variants must satisfy before claiming parity.

**Tests:** Added Rust unit coverage proving `TraceEmitter::log_output(...)` and `log_dump(...)` emit structured
events, and reran the Rust core trace and runtime trace-control suites plus the Perl trace suite.

**Status:** `TRACE-OBSERVABILITY` is closed. Rust can claim trace parity for the documented external behavioral
contract; future variants must pass the mdBook checklist before making the same claim.

## 2026-07-04 — TRACE-OBSERVABILITY.4.4 — add Rust runtime trace events

**Scope:** Rust interpreted runtime and generated-plan trace event emission, focused trace tests, mdBook/toolbox
status, task-tree/roadmap/live docs, and Knowledge Map.

**What changed:** Wired Rust runtime execution through the shared `linkedspec-core::trace` model without changing
the default quiet entrypoints. `Engine::execute_with_trace(...)` now emits a `rust_runtime:engine:execute` scope plus
rule entry/exit, recursion-cutoff, regex match/no-match, acode/bcode child-dispatch, lifecycle-block, statement
branch, helper `call(child)`, and mark/capture helper events. Generated-plan traced execution now emits
`rust_runtime:generated_plan:*` events for top-rule selection, generated family dispatch, direct acode/bcode rule
execution, child dispatch, regex branches, acode/bcode dispatch, and recursion cutoffs while preserving the same
result contract as untraced generated execution.

**Tests:** Extended `rust/linkedspec-runtime/tests/trace_controls.rs` with routed-debug assertions for interpreted
runtime branch/lifecycle/mark-capture events and generated-plan branch events while preserving traced/untraced output
equality.

**Status:** At `.4.4` closeout Rust still did not claim trace parity. `.4.5` has since closed the cross-variant
parity proof and reusable future-variant checklist.

## 2026-07-04 — TRACE-OBSERVABILITY.4.3 — add Rust compile/spec-parser trace events

**Scope:** Rust trace event emission for core parse/validate/compile, full-spec user-function parsing, staged
parse-job dispatch, mdBook/toolbox status, task-tree/roadmap/live docs, and Knowledge Map.

**What changed:** Wired the Rust `.4.2` trace emitter through compile-side and spec-parser owner boundaries.
`parse_spec_with_trace(...)` now emits a `rust_core:parse_spec` scope and result decision. Validation traced
entrypoints report each existing validation pass without changing pass order. `compile_with_trace(...)` reports
function/rule compilation decisions plus dependency-regex mapping scope/result details. Full-spec Rust parsing now
traces user-function-definition parser phases, function projection, stripped-rule parsing, and carries the same
caller-owned emitter into neutral `body_parse_job` dispatch. The staged parser registry traced entrypoints now
report normalize, stable queue sort, resolve, load, compile, and execute decisions per job.

**Tests:** Added routed-debug assertions to `rust/linkedspec-runtime/tests/trace_controls.rs` for core events,
full-spec user-function/staged-dispatch events, and direct staged queue phase events while preserving untraced output
equality.

**Status:** At `.4.3` closeout Rust still did not claim trace parity. Runtime interpreter/generated-plan branch
events and mark/capture events have since landed in `.4.4`; `.4.5` has since closed the parity proof.

## 2026-07-04 — TRACE-OBSERVABILITY.4.2 — add Rust trace controls

**Scope:** Rust trace controls, levels, sinks, traced entrypoints, mdBook contract updates, toolbox, task-tree/
frontier sync, live recovery docs, focused Rust tests, and Knowledge Map.

**What changed:** Added `linkedspec-core::trace` as the shared Rust trace control surface: `TraceLevel`,
`TraceConfig`, `TraceSinkMode`, `TraceEmitter`, `DUMP_*` constants, environment-derived configuration,
stdout/routed-file/mirror sinks, routed-file reset, and structured event primitives. `linkedspec-runtime` re-exports
the same module as `linkedspec_runtime::trace`.

Explicit traced entrypoints now sit beside existing default-quiet APIs for core `parse_spec`, `validate`, and
`compile`; runtime full-spec user-function parsing; staged parse jobs; `Engine::execute`; generated-plan execution;
generated parser execution; and emitted generated modules through `parse_with_trace(...)`. Existing untraced APIs
remain output-compatible. Compile/spec-parser event emission has since landed in `.4.3`; runtime branch emission
has since landed in `.4.4`; parity proof remains owned by `.4.5`.

**Evidence:** `cargo test -p linkedspec-core trace` passes the new level/config/sink primitive tests. `cargo test
-p linkedspec-runtime --test trace_controls` passes traced-entrypoint equivalence, generated-source trace entrypoint
surface checks, and routed-file setup coverage. `cargo test -p linkedspec-runtime --test source_emitter` passes
generated crate compilation/execution with the new emitted `parse_with_trace(...)` surface. `cargo fmt`, mdBook,
Knowledge Map, memory/doctrine, whitespace, and full local CI pass; local CI includes phase0 at 1021 green.

## 2026-07-04 — TRACE-OBSERVABILITY.4.1 — map Rust trace parity design

**Scope:** Rust trace parity design inventory, mdBook contract status, toolbox, task-tree/frontier sync, live
recovery docs, and Knowledge Map. No Rust code changed in this slice.

**What changed:** Mapped the variant-neutral trace contract onto Rust's actual crate boundaries and entrypoints
before implementation. `linkedspec-core` owns parser, validation, compiler, dependency-regex resolution, and shared
compiled-spec types, so shared Rust trace levels/configuration/sink/event primitives must be visible there rather
than only in `linkedspec-runtime`. The runtime crate then reuses that model for full-spec user-function parsing,
staged parser dispatch, interpreter execution, generated-plan execution, generated parser modules, lifecycle block
execution, rule dispatch, statement controls, repetition/AND/OR choices, and mark/capture helper operations.

The mdBook now explicitly says Rust is design-inventoried but not trace-parity complete. `.4.2` owns controls,
levels, and sinks; `.4.3` owns compile/spec-parser/staged-dispatch events; `.4.4` owns runtime/generated-plan branch
events; `.4.5` owns cross-variant parity proof.

**Evidence:** Targeted Rust source inventory covered `rust/README.md`, `linkedspec-core::{parser,validation,
compiler,types}`, `linkedspec-runtime::{spec_parser,engine,runtime,source_emitter}`, and public Rust harnesses. The
earlier `.3.5` trace inventory still shows no Rust trace API/control hits outside corpus fixtures. mdBook, Knowledge
Map, memory/doctrine, whitespace, and the local CI gate pass. An over-broad `cargo test` attempt failed in existing
`linkedspec-runtime` integration tests with no Rust source diff; the accepted `.4.1` gate is the repo local CI gate
for this docs/design slice.

## 2026-07-04 — TRACE-OBSERVABILITY.3.5 — close trace contract and split parity

**Scope:** mdBook trace contract wording, backend parity split, task-tree/frontier sync, live recovery docs,
toolbox, and Knowledge Map. No runtime/code behavior changed in this slice.

**What changed:** Closed the overall trace no-drift/contract leaf after the Perl reference trace suite stayed green
across CLI, generated-handler, RuleIR, EmitContext, ActionIR pipeline, compact lowerer, and MethodLowering trace
coverage. The mdBook now presents trace parity as a variant-neutral external behavior contract rather than Perl
mechanics: levels, controls, sinks, reset behavior, enter/exit events, decision/branch events, mark/capture events,
dump/log events, and default quiet behavior.

The required backend parity work is now split into `.4.*` leaves. `.4.1` owns Rust trace contract/design inventory
before Rust trace code; later leaves own Rust controls/sinks, compile-side events, runtime branch events, and parity
closeout.

**Evidence:** `perl bin/linkedspec --help` exposes trace controls; the nine-file Perl trace regression suite passes;
and `rg` over `rust/` excluding corpus fixtures finds no trace API/control surface yet, confirming the `.4.*`
parity lane is required.

## 2026-07-04 — TRACE-OBSERVABILITY.3.4.6 — close compile ActionIR trace coverage

**Scope:** Compile/ActionIR trace closeout probes, mdBook trace coverage boundaries, toolbox, task-tree/frontier
sync, live recovery docs, and Knowledge Map. No runtime/code behavior changed in this slice.

**What changed:** The compile/ActionIR coverage lane is now closed through the planned Perl reference owner
namespaces: RuleIR planning, EmitContext owner bridge/rewrite orchestration, ActionIR scanner/canonical/
diagnostic/rewrite pipeline, compact lowerers, and MethodLowering. A representative descriptor-compile probe
emits all those namespaces together while preserving the descriptor's language-agnostic ActionIR readiness.

The mdBook and toolbox now state that the remaining trace work is global no-drift/coverage closeout plus the
required Rust/future-variant parity split, not another known opaque compile/ActionIR owner.

**Evidence:** A routed debug `LinkedSpec::Get(... return_descriptor => 1, trace_level => 'debug')` probe over
return/set/receiver/control paths emitted `rule_ir`, `emit_context`, `actionir:scanner`,
`actionir:rewrite_pipeline`, `actionir:control_flow`, and `actionir:method_lowering` decisions together with
`ready=1 raw=0 unresolved=0`. Full local CI passes with phase0 at 1021 tests.

## 2026-07-04 — TRACE-OBSERVABILITY.3.4.5 — trace MethodLowering decisions

**Scope:** Perl `ActionIR::MethodLowering`, focused trace regression, mdBook trace docs, toolbox, task-tree/frontier
sync, live recovery docs, and Knowledge Map.

**What changed:** `MethodLowering` now emits debug-level
`actionir:method_lowering:<phase>:<label>:<decision>` trace decisions for its largest branch families. The trace
reports helper-family classification, AST value lowering and raw/bypass decisions, unsupported helper exits,
receiver-chain family transitions, assignment and mutation operator routing, mutation-slot value sources, return
payload fallback choices, and the scoped `_lower_assign_statement` enter/exit boundary. The trace helper path stays
lazy through `LinkedSpec::ActionIR::Trace`, so require-only MethodLowering consumers still do not load
`LinkedSpec::Trace`.

**Evidence:** Focused coverage in `t/trace_actionir_method_lowering.t` locks production owner-dispatch traces for
helper families, unsupported helpers, string/number/hash/array receiver chains, AST fluent chains, assignments,
mutations, and Trace-lazy require/lower behavior. Adjacent RuleIR/EmitContext/ActionIR trace suites and the
ActionIR AST focused suite continue to pass; full local CI passes with phase0 at 1021 tests.

## 2026-07-04 — TRACE-OBSERVABILITY.3.4.4 — trace compact ActionIR lowerers

**Scope:** Perl compact ActionIR lowerer owners outside `MethodLowering` (`FlowExpr`, `ValueExpr`,
`ArrayPipeline`, `DeclareMethod`, and `ControlFlow`), focused trace regression, variant-agnostic trace parity
contract docs, mdBook trace docs, toolbox, task-tree/frontier sync, live recovery docs, and Knowledge Map.

**What changed:** Compact lowerer owners now emit debug-level
`actionir:<owner>:<phase>:<label>:<decision>` trace decisions and matching owner scopes. The coverage reports
flow-expression branch families, value literal/direct-access/assignment-source decisions, array-pipeline plan
construction and op lowering, declaration extraction/initializer/set routing, and compact control-flow choices for
attached/inline/marker if/switch paths plus branch statement passthrough or rewrite handling. `MethodLowering.pm`
remains deliberately untouched and owned by `.3.4.5`.

The trace docs now state that documented trace capabilities are a variant-agnostic external contract. Perl-specific
APIs and internals are reference mechanics; Rust and future variants must provide equivalent user-visible trace
controls, levels, event classes, and sink behavior before claiming trace parity.

**Evidence:** Focused coverage in `t/trace_actionir_compact_lowerers.t` locks production owner-dispatch traces for
flow/value expressions, array pipelines, declarations, assignments, attached if, inline switch, and Trace-lazy
require/lower behavior. Adjacent ActionIR trace suites and the ActionIR AST focused suite continue to pass; full
local CI passes with phase0 at 1021 tests.

## 2026-07-04 — TRACE-OBSERVABILITY.3.4.3 — trace ActionIR pipeline decisions

**Scope:** Perl ActionIR scanner, scanner-core, canonical-events, diagnostics, rewrite-pipeline owners, focused
trace regression, mdBook trace docs, toolbox, task-tree/frontier sync, live recovery docs, and Knowledge Map.

**What changed:** ActionIR pipeline owners now emit debug-level
`actionir:<owner>:<phase>:<label>:<decision>` trace decisions and matching debug scopes. The new coverage reports
scanner helper-event discovery, canonical helper queue matching, registered value-drop handling, RAW_PERL fallback
creation/preservation, unmatched helper scan events, unresolved helper diagnostics, rewrite-rule construction,
canonical lowering decisions, missing source spans/contracts, and implicit attached-if closure insertion/appending.
`LinkedSpec::ActionIR::Trace` centralizes this formatting while staying lazy: requiring ActionIR owners and running
compatibility rewrites does not load `LinkedSpec::Trace` unless tracing was explicitly loaded/configured.

**Evidence:** Focused coverage in `t/trace_actionir_pipeline.t` locks canonical return lowering, raw Perl
fallbacks, unsupported helper diagnostics, attached-if implicit closure handling, and Trace-lazy require/rewrite
behavior. Adjacent RuleIR, EmitContext, and generated-handler trace suites continue to pass; full local CI passes
with phase0 at 1021 tests.

## 2026-07-04 — TRACE-OBSERVABILITY.3.4.2 — trace EmitContext owner bridge

**Scope:** Perl `RuleIR::EmitContext` owner bridge, focused trace regression, mdBook trace docs, toolbox,
task-tree/frontier sync, and Knowledge Map.

**What changed:** EmitContext now emits debug-level `emit_context:<phase>:<label>:<decision>` trace decisions and
matching debug scopes for the ActionIR owner bridge and top-level rewrite orchestration. The trace covers ActionIR
owner package resolution, callback lookup, default dependency bundle selection, current function-registry injection,
bare-symbol-kind dependency injection, `build_rule_ir_emit_context(...)` boundaries, `rewrite_action_code_for_compat(...)`
compatibility fallback paths, and `_rewrite_action_code_with_diagnostics(...)` canonical raw-Perl fallback status.
Trace helpers remain lazy unless `LinkedSpec::Trace` is already loaded/configured, and delegated owner calls still
preserve list/scalar/void context.

**Evidence:** Focused coverage in `t/trace_emit_context_bridge.t` locks scalar-slot fallback, aggregate-wrapper
fallback, canonical-pipeline use, rule emit-context orchestration, dependency injection decisions, and Trace-lazy
require/rewrite behavior. Full local CI passes with phase0 at 1021 tests.

## 2026-07-04 — TRACE-OBSERVABILITY.3.4.1 — trace RuleIR planning decisions

**Scope:** Perl RuleIR planning owner, focused trace regression, mdBook trace docs, toolbox, live recovery docs,
task-tree/frontier sync, and Knowledge Map.

**What changed:** RuleIR now emits debug-level `rule_ir:<phase>:<rule>:<decision>` trace decisions for rule-entry
collection, lifecycle routing, explicit action/blind-call edges, split-boundary `MOVE_POS`/`MARK_POS` lowering,
handler-variant selection, action-mode/execution-shape planning, and mixed-action validation. These compile-time
decisions are visible through normal `LinkedSpec::Get(..., trace_level => 'debug', ...)` descriptor compilation and
do not change generated parser behavior.

**Evidence:** Focused coverage in `t/trace_ruleir_planning.t` locks the new decision namespace, RuleIR metadata
behavior, collection routing, validation behavior, and normal descriptor compilation trace visibility.

## 2026-07-04 — TRACE-OBSERVABILITY.3.4 — split compile action trace coverage

**Scope:** Task-tree split, roadmap/frontier sync, live recovery docs, and Knowledge Map. No runtime/code behavior
changed in this slice.

**What changed:** Split the compile/ActionIR trace coverage leaf before implementation. The read-only audit showed
the parent leaf spans `RuleIR.pm`, `RuleIR/EmitContext.pm`, scanner/canonical/diagnostic/rewrite owners,
value/flow/control/declaration/array lowering owners, and the large `ActionIR::MethodLowering` owner. The new
children are `.3.4.1` RuleIR planning, `.3.4.2` EmitContext bridge, `.3.4.3` scanner/canonical/diagnostics/
rewrite, `.3.4.4` compact lowering owners, `.3.4.5` MethodLowering, and `.3.4.6` closeout.

**Evidence:** Read-only `rg` trace call-site inventory, `wc -l` owner sizing, targeted RuleIR/EmitContext reads,
and ActionIR owner inventory. The frontier at completion was `TRACE-OBSERVABILITY.3.4.1`; `.3.4.1` through
`.3.4.6` have since closed.

## 2026-07-04 — TRACE-OBSERVABILITY.3.3 — trace repetition generated paths

**Scope:** Perl REP generated handler templates, focused runtime/source trace regressions, mdBook trace docs,
toolbox, task-tree/frontier sync, live recovery docs, and Knowledge Map.

**What changed:** Repetition generated handlers now wrap their loop branch conditions with
`LinkedSpec::Trace::trace_generated_handler_branch(...)`. The Perl reference trace can now show REP loop entry,
per-iteration success/failure, min-satisfied stop decisions, max-bound continuation/cutoff decisions, `REP_ACODE`
match and acode-index dispatch, and bcode REP zero-progress cutoffs. Nested non-REP bcode helper calls inside REP
coderefs stay quiet so each REP iteration reports the owned loop decision rather than duplicating inner helper
dispatch details.

**Evidence:** Focused coverage in `t/trace_generated_rep_dispatch.t` proves runtime debug trace output for
`REP_ACODE` plus/optional/below-min paths and `REP_AND_ACODE` ordered iteration, and source-locks `REP_BCODE`,
`REP_AND_BCODE`, `REP_AND_ACODE`, and `REP_ACODE` templates for their branch names. The previous non-REP trace
test now asserts REP bodies are instrumented. Full local CI passes, including phase0 at 1021 green.

## 2026-07-04 — TRACE-OBSERVABILITY.3.2 — trace non-repetition generated dispatch

**Scope:** Perl generated handler templates, focused runtime trace regression, mdBook trace docs, toolbox,
task-tree/frontier sync, live recovery docs, and Knowledge Map.

**What changed:** Non-repetition generated handlers now wrap emitted branch conditions with
`LinkedSpec::Trace::trace_generated_handler_branch(...)`. The Perl reference trace can now show runtime regex
match/miss decisions, `LX` no-match paths, acode index choices, AND sequence index checks, bcode child-call
dispatch, and bcode child-result checks in generated handler bodies. Repetition handlers are deliberately left
untraced in this slice and remain owned by `TRACE-OBSERVABILITY.3.3`, which has since closed.

**Evidence:** Focused coverage in `t/trace_generated_nonrep_dispatch.t` builds parsers with trace disabled, resets
debug routed trace before runtime invocation, and proves `_default`, `AND_BCODE`, `OR_BCODE`, `AND_ACODE`, and
`OR_ACODE` branch decisions appear without changing parser results. At `.3.2` close, the same test inspected
generated source to prove `REP_ACODE` bodies remained uninstrumented for the next leaf; `.3.3` has since updated
that assertion to expect REP instrumentation. Full local CI passes, including phase0 at 1021 green.

## 2026-07-04 — TRACE-OBSERVABILITY.3.1 — add generated-handler trace helper seam

**Scope:** Perl trace owner, focused helper regression, mdBook trace docs, task-tree/frontier sync, live recovery
docs, and Knowledge Map.

**What changed:** Added `LinkedSpec::Trace::trace_generated_handler_branch(%args)`, an owner-level helper for
emitted handler branch decisions. The helper returns the original `taken` boolean, emits structured
`generated_handler_branch:<handler_kind>:<rule_label>:<branch>` decisions when tracing is enabled, records emitted
metadata such as `match_index`, `call`, `pos`, loop count, and repetition bounds, and evaluates lazy `details`
builders only when trace output is enabled. Detail-builder errors are captured in trace text and do not perturb the
branch result.

**Evidence:** Focused regression coverage proves trace-off quiet/lazy behavior, trace-on structured output, and
detail-builder error isolation. The mdBook documents the helper as a Perl-reference owner-level emitted-call
contract and keeps branch-template instrumentation scoped to `TRACE-OBSERVABILITY.3.2` and `.3.3`. Full local CI
passes, including phase0 at 1021 green.

## 2026-07-04 — TRACE-OBSERVABILITY.3 — split trace coverage extension

**Scope:** Task-tree split, roadmap/frontier sync, live recovery docs, and Knowledge Map. No runtime/code behavior
changed in this slice.

**What changed:** Split the broad Perl reference trace coverage extension into signoff-sized children:
`TRACE-OBSERVABILITY.3.1` for the generated-handler trace helper seam, `.3.2` for non-repetition generated
dispatch decisions, `.3.3` for repetition/min/max/zero-progress paths, `.3.4` for compile/ActionIR owner scopes,
and `.3.5` for coverage closeout plus the backend-parity split decision.

**Evidence:** The split preserves the sequence established by the `.1` audit: generated handler semantics first,
compile/ActionIR owner instrumentation after runtime branch trace semantics are concrete, and Rust trace parity
only after the Perl reference trace model is explicit. The frontier at completion was `TRACE-OBSERVABILITY.3.1`;
`.3.1` through `.3.5` have since closed and `.4.1` now owns Rust trace parity design.

## 2026-07-04 — TRACE-OBSERVABILITY.2 — add trace CLI control

**Scope:** Perl reference CLI runner, focused CLI regression, mdBook trace docs, toolbox/README discovery,
task-tree/frontier sync, live recovery docs, and Knowledge Map.

**What changed:** Added `bin/linkedspec`, a compile/run command that exposes the existing trace API through
discoverable flags: `--trace`, `--trace-file`, `--trace-mode`, `--trace-reset`, and `--trace-emoji`. The runner
supports named specs, `.spec` files, and inline source; accepts inline or file input; and prints canonical parser
JSON to stdout. Routed trace mode keeps trace output in the requested file so parser stdout stays machine-readable.

**Evidence:** `perl -c bin/linkedspec`, `perl -c -Iperl t/trace_cli.t`, `prove -v -Iperl t/trace_cli.t`, mdBook,
Knowledge Map, memory/doctrine, whitespace, and `tools/run_ci_local.sh` pass. The focused regression proves help
exposes the trace flags and `--trace high --trace-file ... --trace-mode route` writes a non-empty trace file
without polluting JSON stdout. Full local CI includes the 1021-test phase0 suite. The next frontier is
`TRACE-OBSERVABILITY.3` for Perl reference trace coverage extension.

## 2026-07-04 — TRACE-OBSERVABILITY.1 — audit trace coverage gaps

**Scope:** Trace call-site audit, task-tree coverage plan, mdBook trace API/runtime-context corrections, live
recovery docs, and Knowledge Map.

**What changed:** Completed the read-only trace coverage audit. The existing Perl reference trace framework is
usable through env vars, per-call options, and `configure_trace(...)`, and it records broad compile pipeline
scopes, parser invocation, per-rule handler wrappers, selected decisions, dumps, and mark/capture events. The audit
pins the remaining gaps: no discoverable CLI flag/entrypoint, generated handler branch/control-flow decisions are
not emitted, most ActionIR owner branches lack trace coverage, and the Rust runtime has no equivalent trace API.

**Evidence:** `rg` call-site inventory, `dump_parser_source` on a minimal parser, routed debug trace probe to
`/tmp/linkedspec_trace_audit.log`, direct facade/owner trace-state probes, Rust trace search, mdBook build, and
the memory/doctrine gates. The next frontier is `TRACE-OBSERVABILITY.2` for CLI/docs control.

## 2026-07-04 — TOP-RULE-AS-NORMAL.3.2 — lock Rust recursive top-rule values

**Scope:** Rust runtime declaration semantics, recursive top-rule/body value parity locks, oracle corpus fixtures,
task-tree closeout, mdBook/status sync, and Knowledge Map.

**What changed:** Rust now treats the first bare argument of `declare(...)` as the declaration type token
(`scalar`/`array`/`hash`) instead of evaluating it as a runtime variable. Declared working variables are scoped per
rule invocation around interpreted and generated-plan direct rule execution, while undeclared mutations remain
caller-visible. This fixes recursive `sexpr` value leakage where nested child frames mutated the parent `items`
array because `declare(array, items)` had been a no-op.

**Evidence:** Focused Rust top-rule integration passes (4 tests), the Rust oracle corpus passes 3 tests over 91
fixtures, source-emitter tests pass, runtime lib tests pass, Rust formatting check passes, and the oracle generator
syntax check passes. The corpus adds `top_rule_body_recursion_sexpr`, `top_rule_lx_recursion_nested`, and
`top_rule_lx_recursion_sequence`, closing `TOP-RULE-AS-NORMAL`.

## 2026-07-04 — RUST-PARITY.9 — finalize Rust parity documentation

**Scope:** Rust parity closeout documentation, roadmap/task-tree status, architecture snapshot, mdBook backend
handoff, live recovery docs, and next-frontier routing.

**What changed:** Closed the `RUST-PARITY` follow-on tree after the generated-source/oracle integration work.
`ROADMAP_V2.md`, `docs/TASK_TREE.md`, `docs/tasks/RUST-PARITY.md`, `ARCHITECTURE_STATE.md`, the mdBook backend
handoff, `rust/README.md`, `LIVE_ACHIEVEMENT_STATUS.md`, `DEVELOPMENT_NOTES.md`, and `MEMORY.md` now agree on the
current Rust state: the interpreter oracle is green over 88 manifest fixtures plus drift guards; generated source
directly executes every current structural family; and generated-source corpus proof remains a curated subset until
a future leaf broadens it.

**Evidence:** The closeout also clears stale PNT routing that pointed back to `RUST-PARITY.9`. With `RUST-PARITY`
closed, `TOP-RULE-AS-NORMAL.3.2` is the next owned frontier leaf because its recursive-grammar Rust blocker has
cleared.

## 2026-07-04 — RUST-PARITY.8.5 — integrate generated source with oracle corpus

**Scope:** Rust generated-source test harness, oracle/corpus integration proof, task-tree frontier docs, mdBook
backend handoff, live recovery docs, and Knowledge Map.

**What changed:** The source-emitter integration test now validates generated Rust source against the
manifest-backed oracle corpus as well as the synthetic all-family matrix. A curated manifest subset is loaded from
`rust/linkedspec-runtime/tests/corpus/manifest.json`, checked for manifest membership, parsed with the full
user-function-aware parser, verified against the normal Rust interpreter's `[expected.json]` oracle mapping, emitted
as generated Rust modules, compiled in an isolated temporary crate, and executed through generated `parse(...)`.

**Evidence:** The all-family generated-source matrix still covers every supported structural family (`Default`,
`OrAcode`, `AndSingleAcode`, `AndAcodeSeq`, `AndBcode`, `OrBcode`, `RepAcode`, `RepBcode`, `RepAndAcode`, and
`RepAndBcode`) plus zero-progress/recursion and legacy `Repetition` compatibility. The new manifest-backed subset
proves generated source on `proof_edge_array_literal`, `proof_edge_scalar_literal`, `autoexist_array_bare_arg`,
`terse_1_5_2_primitive_literals`, `terse_2_2_3_attached_if_blocks`,
`terse_4_3_2_user_function_runtime`, `tclite_command_subst`, and `portmap_bare`. This is a generated-source subset
proof, not a claim that generated source currently compiles all 88 corpus fixtures; the full 88-fixture oracle
remains the interpreter corpus gate.

## 2026-07-04 — RUST-PARITY.8.4 — emit REP generated families

**Scope:** Rust generated-source execution routing, repeated acode/bcode runtime loops, source-emitter compile/run
matrix completeness, task-tree frontier docs, mdBook backend handoff, live recovery docs, and Knowledge Map.

**What changed:** Generated-source planning now classifies repetition rules into explicit REP subfamilies:
`RepAcode`, `RepBcode`, `RepAndAcode`, and `RepAndBcode`. The generated-plan executor routes those families through
direct acode/bcode execution instead of falling back through whole-rule interpreter execution. The shared Rust
runtime now repeats blind-call OR choice and AND sequence steps with min/max bounds and a zero-progress guard, and
REP-AND acode rules count complete ordered groups instead of treating every regex slot as an independent
repetition.

**Evidence:** The source-emitter matrix now covers all non-REP and REP generated families. New generated modules
prove bounded REP acode, bounded REP bcode, bounded REP-AND acode, bounded REP-AND bcode, zero-progress
termination, and same-position recursive-call termination, all checked against interpreter output and then built/run
inside the isolated generated-source temp crate. A focused compatibility lock proves an older v1 generated plan row
with the coarse `Repetition` marker still validates and executes through direct REP specialization. Focused
formatting, source-emitter, runtime-lib, and clippy checks pass; mdBook, Knowledge Map, memory, doctrine,
whitespace, and full local CI also pass. The full gate includes 1021 phase0 regression tests. The next executable
frontier is `RUST-PARITY.8.5`: generated-source validation against the oracle/corpus contract.

## 2026-07-04 — RUST-PARITY.8.3.5 — close non-REP generated matrix

**Scope:** Rust generated-source execution routing, source-emitter compile/run matrix completeness, task-tree
frontier docs, mdBook backend handoff, live recovery docs, and Knowledge Map.

**What changed:** Generated-plan routing is now exhaustive across the generated family enum. `Default`,
`OrAcode`, `AndSingleAcode`, `AndAcodeSeq`, `AndBcode`, and `OrBcode` enter direct generated execution; only
`Repetition` remains on the fallback path owned by the REP leaf. The generated-source test matrix now asserts that
its cases cover every non-repetition generated family before REP work starts.

**Evidence:** Focused formatting, source-emitter, runtime-lib, and clippy checks pass. The source-emitter matrix
still proves the covered default, OR acode, AND acode, AND bcode, and OR bcode behaviors, and now also performs a
set-completeness check over all six non-REP `GeneratedRuleFamily` values. The next executable frontier at
completion was `RUST-PARITY.8.4`; `.8.4` is now complete and the current frontier is `RUST-PARITY.8.5`.

## 2026-07-04 — RUST-PARITY.8.3.4 — emit direct bcode execution

**Scope:** Rust generated-source execution path, Rust blind-call bcode dispatch,
source-emitter compile/run matrix, task-tree frontier docs, mdBook backend handoff, live recovery docs, and
Knowledge Map.

**What changed:** The generated-plan executor now treats `AndBcode` and `OrBcode` as direct generated families
instead of fallback families. Blind-call tail execution is shared between the interpreted and generated paths:
each child return becomes parent `retv`, attached blind-edge code and fluent calls run in order, and the parent
exit block sees the resulting `retv`. Explicit OR bcode dispatch stops after the first truthy child
return instead of continuing through later blind-call entries, and OR bcode no-match dispatch fires `LX` before the
parent `E` block.

**Evidence:** The focused generated-source matrix now proves AND bcode sequential dispatch by collecting the
ordered child returns `A` then `B`, proves OR bcode first-match behavior with an input (`a b`) that would return the
later child if dispatch did not stop after the first truthy child, and proves OR bcode no-match `LX` handling.
Focused formatting, source-emitter, runtime-lib, and clippy checks pass. The mdBook, Knowledge Map, memory,
doctrine, whitespace, and full local CI gates also pass; the full gate includes 1021 phase0 regression tests. The
frontier at completion was `RUST-PARITY.8.3.5`; `.8.3.5` and `.8.4` are now complete and the current executable
frontier is `RUST-PARITY.8.5`.

## 2026-07-04 — RUST-PARITY.8.3.3 — emit direct AND acode execution

**Scope:** Rust generated-source execution path, shared Rust AND acode sequence semantics,
source-emitter compile/run matrix, task-tree frontier docs, mdBook backend handoff, live recovery docs, and
Knowledge Map.

**What changed:** The generated-plan executor now treats `AndSingleAcode` and `AndAcodeSeq` as direct acode
families instead of fallback families. Non-repetition AND regex/acode rules now consume regex slots in ordered
index sequence before they can complete; an out-of-order or incomplete sequence returns `undef` before the rule
exit block. This shared runtime behavior keeps generated execution aligned with the interpreted Rust path while
matching the Perl HandlerIR `and_acode_seq` contract for ordered consume cases.

**Evidence:** The focused generated-source matrix now proves an AND single-acode action return and an AND
sequential-acode case that only returns from the second ordered slot (`a b` → `and-seq`), which would fail if the
executor stopped after the first regex. Focused formatting, source-emitter, runtime-lib, and clippy checks pass.
At `.8.3.3` completion, the next executable frontier was `.8.3.4`; `.8.3.4`, `.8.3.5`, and `.8.4` are now
complete and the current frontier is `RUST-PARITY.8.5`.

## 2026-07-04 — RUST-PARITY.8.3.2 — emit direct default-or acode execution

**Scope:** Rust generated-source execution path, source-emitter compile/run matrix, task-tree frontier docs,
mdBook backend handoff, live recovery docs, and Knowledge Map.

**What changed:** Generated `parse(input)` still validates the embedded `GENERATED_RULES` plan, but now enters
`Engine::execute_generated_with_plan(...)` instead of delegating through `Engine::execute(...)`. The generated-plan
executor directly handles `Default` and `OrAcode` families with the interpreter's recursion guard, match lexical
save/restore, lifecycle block execution, action-edge child-return scoping, default repetition loop, and
zero-progress guard. At `.8.3.2` completion, the later-family paths remained owned by later leaves; `.8.3.3` and
`.8.3.4` have since closed the AND acode and AND/OR bcode parts, leaving REP for `.8.4`.

**Evidence:** The focused generated-source matrix now proves a repeated default case and an OR acode action-edge
case that reads the dispatched child return, builds all generated modules in an isolated temp crate, and verifies
generated `parse(...)` output against the interpreter. The next executable frontier is `RUST-PARITY.8.3.3`: direct
AND acode generated execution.

## 2026-07-04 — RUST-PARITY.8.3.1 — emit generated family plan

**Scope:** Rust compiled-rule metadata, generated Rust-source emitter, generated-source compile/run tests, task-tree
frontier docs, mdBook backend handoff, live recovery docs, and Knowledge Map.

**What changed:** `CompiledRule` now preserves the parsed `RuleMode` so generated source can distinguish default,
OR, AND, bcode, and repetition families. The source emitter now writes a `GENERATED_RULES` table with
`GeneratedRuleFamily` rows, validates that generated plan against the embedded compiled spec, and still delegates
execution through the existing `Engine` until the direct execution leaves.

**Evidence:** The focused generated-source matrix builds generated modules for default, OR acode, AND single-acode,
AND sequential-acode, AND bcode, and OR bcode cases in one isolated temp crate and verifies generated `parse(...)`
output matches the interpreter. Focused Rust tests and clippy pass. The next executable frontier is
`RUST-PARITY.8.3.2`: direct default/OR acode generated execution.

## 2026-07-04 — RUST-PARITY.8.3 — split non-repetition emitter lane

**Scope:** Task-tree ownership, roadmap/frontier tracker, live recovery docs, and Knowledge Map. No Rust source
behavior changed.

**What changed:** The non-repetition generated Rust-source leaf is now split before implementation. The split
records that `.8.3` still bundled separate mechanisms: carrying enough rule-mode/family metadata through
`CompiledRule`, emitting an explicit generated family plan, direct default/OR acode execution, direct AND acode
execution, direct AND/OR bcode execution, and the final non-REP matrix closeout.

**Evidence:** Read the active task/KM/code context and verified the split with doctrine/memory/KM gates. The next
executable frontier is `RUST-PARITY.8.3.1`: rule-mode/family metadata plus generated non-REP family-plan emission.

## 2026-07-04 — RUST-PARITY.8.2 — add Rust source emitter scaffold

**Scope:** Rust runtime crate API, generated-source compile/run proof, Rust README, mdBook backend handoff, task
tree/frontier docs, live recovery docs, and Knowledge Map.

**What changed:** `linkedspec-runtime` now exports `source_emitter::emit_rust_source(&CompiledSpec)`. The emitted
module embeds a serialized `CompiledSpec`, exposes a `LINKEDSPEC_GENERATED_SOURCE_FORMAT` marker, and provides a
`parse(input)` function that constructs the existing `Engine` and delegates execution through the interpreter.
This proves the generated-source API and build harness without changing the interpreter path.

**Evidence:** Added a focused `source_emitter` integration test that parses/validates/compiles a simple
non-recursive `.spec`, confirms the interpreter output, emits Rust source, builds it in an isolated temporary
crate, and executes the generated `parse("hello world")` path. Direct non-REP handler-family source emission is
now the `.8.3` frontier.

## 2026-07-04 — RUST-PARITY.8.1 — split Rust source emitter lane

**Scope:** Task-tree ownership, roadmap/frontier tracker, mdBook backend handoff, live recovery docs, and
Knowledge Map. No parser/runtime source behavior changed.

**What changed:** The broad code-generation emitter leaf is now split before implementation. `RUST-PARITY.8`
records that Perl HandlerIR has 10 structural variant kinds and Perl/JSON emitters, while Rust currently
interprets a native `CompiledSpec`/`CompiledRule` contract with parsed lifecycle `CodeBlock`s and action/blind
dispatch tables. The next implementation leaf is `.8.2`: add a minimal generated Rust-source emitter scaffold and
compile/run harness.

**Evidence:** Read the canonical HandlerIR fact card, `perl/LinkedSpec/HandlerVariantEmitter.pm`, Rust
`CompiledSpec`/runtime structures, `rust/README.md`, and mdBook backend handoff. The split creates child leaves
for scaffold/harness, non-repetition families, repetition families, and all-variant/oracle integration.

## 2026-07-04 — RUST-PARITY.7.4 — finalize oracle corpus manifest guard

**Scope:** Perl-oracle fixture generator, checked-in corpus manifest, Rust oracle runner drift guard, corpus
README, mdBook backend handoff, task-tree/live docs, and Knowledge Map.

**What changed:** The output oracle now has an explicit intended fixture set. `tools/gen_oracle_corpus.pl` rejects
duplicate case names and writes `rust/linkedspec-runtime/tests/corpus/manifest.json` with `format`,
`generated_by`, `case_count`, and ordered `cases`. The Rust oracle runner loads that manifest, validates its shape,
rejects missing manifest fixture directories, rejects stale extra fixture directories, and executes fixtures in
manifest order.

**Evidence:** `perl -c -Iperl tools/gen_oracle_corpus.pl`, oracle regeneration, `cargo fmt --manifest-path
rust/Cargo.toml --all`, and Rust `corpus_oracle` pass. The corpus oracle now runs **3 tests**: two focused
manifest-drift guards plus the 88-fixture Perl-reference comparison.

## 2026-07-04 — RUST-PARITY.7.3.6 — land legacy shipped-spec safety smokes

**Scope:** Perl-oracle fixture generation, checked-in Rust oracle corpus, remaining shipped-spec audit evidence,
task-tree/live docs, mdBook corpus status, and Knowledge Map.

**What changed:** The RTL/plugin/legacy shipped-spec candidates were audited under the hardened oracle timeout
model. Seven JSON-safe, Rust-green smokes were promoted:
`regdef_nested_register_fields`, `tablegrep_simple_term`, `simenv_multiline_value`, `vhdl_library_use`,
`ds_vhistory_version_entry`, `pplugin_empty`, and `tkgui_empty`. Richer candidates were kept out of the corpus
with explicit evidence rather than broadening `.7.3`: `pplugin` subdefs return Perl coderefs, `tkgui` body returns
depend on raw Perl pair-return action code, `sdce` capture segmentation diverges, recursive `tablegrep` groups
over-report in Rust, `simenv` single-line values lose verbatim payloads, VHDL port clauses collapse to null,
`ds_vhistory` branch entries classify as version entries, and the placeholder `verilog` spec returns Perl `0`
versus Rust's empty accumulator.

**Evidence:** Temporary Rust candidate probes were removed after measuring the matrix. `perl -c -Iperl
tools/gen_oracle_corpus.pl` passes, oracle regeneration now produces **88 fixtures**, Rust `corpus_oracle` passes
over all 88, and `parse_all_shipped_specs` still parses all 21 shipped specs successfully with only known
non-target action-code warnings. The full local CI gate passes, including phase0 **1021** tests.

## 2026-07-04 — RUST-PARITY.7.3.5 — close null-output and spec smoke triage

**Scope:** Rust `.spec` parser code-block scanning, focused parser regression coverage, Perl-oracle fixture
generation, checked-in Rust oracle corpus, mdBook corpus status, task-tree/live docs, and Knowledge Map.

**What changed:** The `.7.2` null-output candidates were separated from real parity gaps. Perl reference probes
show `BNF`, `DT`, `ifelse`, and `operators_try` representative inputs return `null` because those specs are
diagnostic/debug-print experiments rather than semantic-AST producers; Rust returning an empty accumulator for
those inputs is not a useful oracle fixture boundary. One real Rust parser issue did surface: `operators_try`
debug `I` blocks contained `{` / `}` inside quoted strings, and Rust's code-block brace scanner counted those
string literals as block delimiters, truncating the block and emitting action-parser warnings. The scanner now
ignores braces inside single- and double-quoted strings, including backslash escapes.

**Evidence:** Added focused parser locks for quoted braces in lifecycle blocks and for the real
`operators_try` debug strings. Added four `spec.spec` oracle fixtures:
`spec_spec_minimal_rule`, `spec_spec_action_edge`, `spec_spec_user_function_definition`, and
`spec_spec_comment_skip`. Oracle regeneration now produces **81 fixtures**, Rust `corpus_oracle` passes over all
81, and `parse_all_shipped_specs` passes with the `operators_try` quoted-brace warnings gone. Remaining
`parse_all_shipped_specs` warnings are pre-existing action-code warnings in other shipped specs.

## 2026-07-04 — RUST-PARITY.7.3.4.3 — land action-edge child aggregation parity

**Scope:** Rust runtime action-edge dispatch, regex syntax normalization, focused regression coverage, oracle
generator/corpus fixtures, task-tree/live docs, and Knowledge Map. No public `.spec` syntax changed; the mdBook
helper/action-edge surface was already documented and is verified by build.

**What changed:** Rust action-edge blocks and fluent chains now reuse the already matched edge child return for
`call(child)`, `push(child)`, `push(child,target)`, and child-index push forms instead of re-searching input after
the parent edge match. Passive terminal children such as skip/comment/comma token rules do not re-execute because
the parent edge regex already consumed them, matching the generated Perl handler shape. The runtime also keeps
scalar assignment separate from remembered aggregate slots for non-shape RHS values, and helper-context
array/hash-consuming arguments prefer the aggregate store when a bare working-variable name collides with a scalar
slot. The Rust regex adapter now normalizes Perl's `{,N}` counted quantifier spelling to `{0,N}`.

**Evidence:** Added seven focused `.7.3.4.3` integration locks covering action-edge block `call(child)`, scoped
fluent `push(child,target)`, child-index statement push, shipped `portmap` concatenation, shipped `ebnf` rule
payloads, shipped `ebnf` logging annotations, and the `ebnf` `grammar_rule` header regex. Added
`portmap_concatenation`, `ebnf_expression_rules`, and `ebnf_logging_annotation` to `tools/gen_oracle_corpus.pl`;
oracle regeneration now produces **77 fixtures**, Rust `corpus_oracle` passes over all 77, and full local CI
passes with phase0 **1021** tests.

## 2026-07-04 — SPEC-FORMAT-TERSE.7.4 — close type-method no-drift sweep

**Scope:** Roadmap/task-tree index, `SPEC-FORMAT-TERSE` task ledger, mdBook helper catalog, Knowledge Map facts,
and live recovery docs. No Perl/Rust behavior change.

**What changed:** Closed the type-method audit/backfill lane after `.7.3`. Current-facing summaries now agree that
string/scalar, array/list, hash, and number are the supported receiver families; array numeric reducers are
terminal array/list receiver methods, not scalar number receiver links; and mutation/lifecycle/control/
child-dispatch/parser-state/declaration/compatibility helpers remain explicit unless a future leaf defines
type-correct receiver semantics.

**Evidence:** Focused drift scans covered stale `.7` frontier text, 73/74 fixture wording, receiver-family
summaries, numeric reducer statements, tests, corpus, mdBook, and Knowledge Map facts. `mdbook build
docs/linkedspec-book`, Knowledge Map regeneration/check, memory/doctrine checks, and `git diff --check` pass.

## 2026-07-04 — SPEC-FORMAT-TERSE.7.3 — backfill array numeric reducer receiver methods

**Scope:** Perl ActionIR receiver lowering, Rust runtime receiver dispatch, Rust integration tests, oracle corpus,
mdBook helper/reference pages, task-tree/live docs, and Knowledge Map.

**What changed:** Added terminal array/list receiver methods for numeric aggregate reducers: `sum`, `avg`,
`median`, `range`, `min`, and `max`. Perl lowers them through the existing aggregate helper family, including
array-returning receiver links such as `sorted().take(...)` and pure internal array-pipeline links such as
`uniq()`. Rust accepts the same receiver methods, treats array terminal methods as chain-ending, and now supports
the documented single-array `num_min(array_expr)` / `num_max(array_expr)` plus `min(array_expr)` / `max(array_expr)`
forms. Hash receiver methods from `.7.1` already cover the useful pure hash surface; mutating and ambiguous
helpers remain explicit statement/function forms.

**Evidence:** Perl phase0 passes with **1021** tests. Focused Rust `terse_7_3` tests pass. The oracle generator
now emits **74** fixtures including `terse_7_3_array_numeric_reducer_receiver_methods`, and Rust `corpus_oracle`
passes all 74. `mdbook build docs/linkedspec-book` and `cargo fmt --manifest-path rust/Cargo.toml --all --check`
pass.

## 2026-07-04 — SPEC-FORMAT-TERSE.7.2 — verify string method surface

**Scope:** String/scalar receiver-method verification, task-tree/live docs, roadmap, and Knowledge Map. No parser,
runtime, mdBook behavior, or shipped `.spec` implementation changed.

**What changed:** Closed the string/scalar method backfill leaf as already satisfied. The useful pure string
receiver set from `.7.1` is already supported on Perl and Rust: `trim`, `lowercase`, `uppercase`,
`replace_substr`, `rm_prefix`, `rm_suffix`, `substr`, `concat`/`cat`, `coalesce_nonempty`, `split` as the array
bridge, and terminal `length`, `starts_with`, `ends_with`, `contains_substr`, and `matches`. Statement regex
substitution through `substr(:target, pattern, replacement, flags)` remains an explicit mutation boundary, not a
pure receiver method.

**Evidence:** A focused Perl probe returns `["BCD", "BCD", 2]` for receiver `substr`, helper `substr`, and the
string-to-array split bridge, with descriptor metadata `ready=1`, `fallback=0`, `raw=0`, and `unresolved=0`.
Focused Rust `terse_2_3_5_3` tests pass. Existing mdBook pages already document method/helper equivalence.

## 2026-07-04 — SPEC-FORMAT-TERSE.7.1 — inventory type method surface

**Scope:** Task-tree inventory, roadmap/live docs, mdBook helper catalog, and Knowledge Map. No parser, runtime,
or shipped `.spec` behavior changed.

**What changed:** Recorded the supported receiver/value families before any method backfill: string/scalar,
array/list, hash, and number have existing receiver method tables; booleans and flow-result values are terminal
today; expression-valued blocks and user-function returns dispatch by yielded runtime type. The audit records that
string `substr()` is already a receiver method on the current Perl/Rust surface. It also marks mutation,
lifecycle/control, child-dispatch, capture/entry/match/input/mark, declaration, and compatibility helpers as
function/statement/lifecycle-only unless a future leaf defines safe receiver semantics.

**Evidence:** Focused classifier scans confirm the Perl and Rust receiver tables. The mdBook helper catalog states
the audited boundary, Knowledge Map regenerates/checks, Rust `corpus_oracle` passes all **73** fixtures, mdBook
builds, memory architecture and doctrine gates pass, and full local CI passes.

## 2026-07-04 — SPEC-FORMAT-TERSE.6.4 — lock declare compatibility policy

**Scope:** Declaration-helper compatibility policy, ADR, mdBook reference/status pages, Knowledge Map, task-tree
status, roadmap tracker, and live continuity docs. No parser, runtime, or shipped `.spec` implementation changed.

**What changed:** ADR `0018` records the post-migration policy: `declare(...)` and declaration aliases remain
accepted legacy compatibility for existing specs, but they are excluded from new shipped specs, public examples,
and current corpus examples. Future removal or diagnostic hardening must be owned by a separate focused
task-tree leaf that updates Perl, Rust, oracle fixtures, mdBook, and Knowledge Map together. The mdBook
declaration reference, helper catalog, and project status now state that boundary.

**Evidence:** Shipped-spec declaration scans remain clean. Current-facing docs scans classify residual
`declare(...)` hits as legacy/reference/status material. mdBook builds, Knowledge Map regenerates/checks, memory
architecture and doctrine gates pass, Rust `corpus_oracle` passes all **73** fixtures, phase0 remains **1020**
green, and full local CI passes.

## 2026-07-04 — SPEC-FORMAT-TERSE.6.3 — sweep docs and corpus declare examples

**Scope:** Public mdBook examples/reference pages, root checked-in corpus, generated Rust oracle corpus,
oracle generator, Knowledge Map, task-tree status, roadmap tracker, and live continuity docs.

**What changed:** Current-facing docs and corpus examples now teach terse working-variable
initialization/mutation (`name = value`, `items = []`, `meta = { ... }`, `items += value`, `meta[key] = value`,
`push(...)`, `copy(...)`, and `cat(...)`) instead of active `declare(...)` or older helper names. Root
`tests/corpus` specs scan clean. Rust oracle generator/fixtures use canonical helpers where old spellings were
incidental; residual old spellings are isolated compatibility locks (`autoexist_*_declare`,
`autoexist_array_bare_arg`, `terse_1_2_3_2_array_copy_bare_read`, `terse_1_2_3_2_hash_copy_bare_read`, and the
hash receiver-method fixture) or explicit legacy/reference documentation. Added a Knowledge Map card for the
`merge_hash(copy(hash(base)), overlay)` boundary.

**Evidence:** Focused doc/corpus scans pass. Root corpus probes preserve existing outputs for `simple_grammar`,
`tablegrep`, and `lispish`. `perl -Iperl tools/gen_oracle_corpus.pl` regenerates **73 fixtures** with no
`expected.json` drift. Rust `corpus_oracle` passes all 73 fixtures. `mdbook build docs/linkedspec-book` passes.
Phase0 passes with **1020** tests, and full local CI passes.

## 2026-07-04 — SPEC-FORMAT-TERSE.6.2.4 — verify shipped-spec terse surface

**Scope:** Shipped-spec compile/inventory verification, phase0, oracle regeneration, Rust corpus oracle, mdBook
build/scan, task-tree status, roadmap tracker, and live continuity docs. No source code or shipped `.spec` file
changed.

**What changed:** Closed the final shipped-spec terse-surface verification leaf. The shipped `specs/*.spec` set is
clean for retired `scalar(...)` / `assign(...)`, active `declare(...)` / `.declare(...)`, and old helper spellings
before the broader docs/corpus sweep. The checked-in corpus and public book still contain `declare(...)` and older
helper references in legacy/reference material; that inventory is now explicitly carried into `SPEC-FORMAT-TERSE.6.3`.

**Evidence:** All 21 shipped specs descriptor-compile from this checkout with `perl -Iperl`. Phase0 passes with
**1020** tests. `tools/gen_oracle_corpus.pl` regenerates **73** fixtures with no tracked corpus diff, and Rust
`corpus_oracle` passes all 73. `mdbook build docs/linkedspec-book` passes, and the book has no `scalar(...)` /
`assign(...)` hits. Full local CI (`bash tools/run_ci_local.sh`) passes.

## 2026-07-04 — SPEC-FORMAT-TERSE.6.2.3.2 — retire scalar and assign spec helpers

**Scope:** Perl ActionIR lowering/autodeclare/type-memory seams, Rust runtime expression/target evaluation,
shipped specs, checked-in spec corpora, phase0/source expectations, focused Rust tests, mdBook/live docs, task
tree, roadmap, and Knowledge Map.

**What changed:** Removed `scalar(...)` and `assign(...)` from the current authored `.spec` surface. Scalar working
variable reads now use `:name`; assignment uses `LHS = RHS` or `set(...)`. Bare identifiers remember their inferred
kind after initialization, so `items = [value]` makes later `items` / `copy(items)` array-valued, `meta = { key =>
value }` makes later `meta` / `copy(meta)` hash-valued, and non-shape assignment remains scalar-valued. Backend
Perl built-ins such as `scalar(@...)` are intentionally outside this retirement boundary.

**Evidence:** Active authored specs and checked-in corpus specs scan clean for `scalar(` and `assign(`. The mdBook
source scan is clean. `prove -q -Iperl t/phase0_regression.t` passes with **1020** tests, and
`prove -q -Iperl t/actionir_ast_parser.t` passes. Focused Rust checks pass for scalar-slot shorthand parsing,
scalar-slot runtime behavior, and remembered bare identifier kind after initialization.

## 2026-07-03 — SPEC-FORMAT-TERSE.6.2.3.1 — add scalar slot shorthand

**Scope:** Perl ActionIR lowering/autodeclare, Rust expression parsing/runtime evaluation, focused Perl/Rust
regression coverage, oracle corpus fixture, mdBook reference pages, task-tree/live docs, and Knowledge Map.

**What changed:** Added `:name` as the terse scalar-slot spelling. In value positions it reads scalar working
variable `name`, replacing the former long helper spelling. In assignment-like target positions,
`set(:payload, [value])` preserves the explicit scalar payload boundary, storing the whole direct-shape payload in
scalar `payload`; bare `set(payload, [value])` still infers aggregate array assignment. The former long scalar
helper has since been retired by `SPEC-FORMAT-TERSE.6.2.3.2`.

**Evidence:** Perl lowering probes cover `return(:name)`, `set(:payload, [value])`, direct `[:value]`, and
constructor payloads with `:value`. Phase0 now passes with **1019** tests. Rust core/runtime focused tests
cover parsing/evaluation of `:name`, and the Perl-derived oracle corpus includes
`terse_6_2_3_1_scalar_slot_shorthand`; regeneration now produces **73 fixtures**, and Rust `corpus_oracle` passes
over all 73. mdBook pages now document `:name` as the preferred scalar-slot spelling.

## 2026-07-03 — RUST-PARITY.7.3.4.2 — land portmap scalar helper parity

**Scope:** Rust runtime helper execution, regex-dispatch alternation isolation, focused integration coverage,
oracle generator/corpus fixtures, mdBook `portmap` documentation, task-tree tracking, live docs, and Knowledge Map.

**What changed:** Closed the representative `portmap` scalar-classification divergence. Rust validation/runtime now
recognize `or`, `and`, and `not`; `array(flat_array(...))`, `array(flat(...))`, and `array(flat_hash(...))` splice
their list-context payloads into the surrounding constructor while non-flattening helpers such as
`array_copy(...)` remain nested. The regex alternation dispatcher now wraps each rule regex in a non-capturing
branch before joining alternatives, so a rule's own top-level `|` no longer masquerades as a sibling action-edge
dispatch branch; this fixes the `portmap` constant branch (`0x1f`) that previously routed through the
`concatenation` edge and produced `null`.

**Evidence:** Added focused `.7.3.4.2` integration locks for list-context splicing, boolean helper truthiness, and
real `specs/portmap.spec` scalar outputs for `foo`, `bar[3]`, `baz[7:0]`, and `0x1f`. Added a regex-engine unit
test for internal top-level alternation ownership. Added `portmap_bare`, `portmap_bit`, `portmap_slice`, and
`portmap_constant` to `tools/gen_oracle_corpus.pl`; regeneration now produces **72 fixtures**, and Rust
`corpus_oracle` passes over all 72. Clippy, mdBook, Knowledge Map, memory architecture, doctrine, and whitespace
gates pass.

## 2026-07-03 — RUST-PARITY.7.3.4.4 — land lib_reader action-helper parity

**Scope:** Rust runtime helper execution, focused integration coverage, oracle generator/corpus fixtures, mdBook
corpus/helper documentation, task-tree tracking, live docs, and Knowledge Map.

**What changed:** Closed the representative `lib_reader` sattribute/cattribute divergence after the
parser/compiler header-rest fix. A focused edge-only child-regex regression showed dependency-resolved action-edge
dispatch already seeds child entry captures correctly. The remaining blocker was Rust runtime execution of the
statement-form helpers used by the shipped spec: `substr(scalar(target), pattern, replacement, flags)` /
`regex_subst(...)` now mutates the scalar target with regex replacement (`g` global; inline `i/m/s/x`; `o` no-op),
and `split(array(target), scalar(source), delimiter)` now replaces the target array. The pure value
`substr(value, start, length?)` and `split(value, delimiter)` paths remain separate.

**Evidence:** Added focused `.7.3.4.4` integration locks for edge-only child captures, scalar regex substitution
mutation, array split mutation, and real `specs/lib_reader.spec` sattribute/cattribute execution. Added
`lib_reader_sattribute` and `lib_reader_cattribute` to `tools/gen_oracle_corpus.pl`; regeneration now produces
**68 fixtures**, and Rust `corpus_oracle` passes over all 68.

## 2026-07-03 — SPEC-FORMAT-TERSE.6.2.2 — migrate shipped-spec helper spellings

**Scope:** 16 shipped `.spec` files plus stale phase0 source expectations, task-tree tracking, live docs, and the
mdBook project-status note. No runtime helper alias behavior was removed.

**What changed:** Migrated active shipped-spec uses of old helper spellings to the canonical terse surface:
`assign(...)` -> `set(...)`, `push_value(...)` -> `push(...)`, `array_copy(...)`/`hash_copy(...)` -> `copy(...)`,
and `concat(...)` -> `cat(...)` where the terse spelling was already shipped. `push(...)` targets that could
otherwise collide with all-bare child-call syntax keep explicit `array(...)` receivers. `portmap.spec` also drops
redundant standalone separators after `if(...)`, `elseif(...)`, and `else()` flow markers.

**Evidence:** `rg -n '\b(assign|push_value|array_copy|hash_copy|concat)\s*\(' specs` is clean, and
`rg -n '^\s*(?:if|elseif)\(.*\);\s*$|^\s*else\(\);\s*$' specs/portmap.spec` is clean. Registered descriptor
compilation passes for all 21 shipped specs. `prove -q -Iperl t/phase0_regression.t` passes with **1018** tests,
and Rust `corpus_oracle` passes over **66 fixtures**. The next frontier is `SPEC-FORMAT-TERSE.6.2.3` for
typed-wrapper/direct-shape cleanup.

## 2026-07-03 — SPEC-FORMAT-TERSE.6.2.1 — remove declare from shipped specs

**Scope:** 13 shipped `.spec` files plus stale phase0 expectations and the task/live tracking docs. No runtime
`declare(...)` implementation support was expanded.

**What changed:** Removed active `declare(...)` and fluent `.declare(...)` use from `BNF`, `ds_vhistory`, `ebnf`,
`hlink_substitution`, `lib_reader`, `Lispish`, `portmap`, `pplugin`, `sdce`, `simenv`, `spec`, `tablegrep`, and
`vhdl`. The replacements use the landed terse surface: scalar assignments, explicit `undef` resets, array reset
shape literals, and structured lifecycle blocks where an old fluent declaration chain needed ordered follow-up
statements.

**Evidence:** `rg -n 'declare\(|\.declare\(' specs` is clean. Focused descriptor compilation passes for all
edited shipped specs, `prove -q -Iperl t/phase0_regression.t` passes with **1018** tests, Rust `corpus_oracle`
passes over **66 fixtures**, `mdbook build docs/linkedspec-book` passes, and the full local CI gate passes. The
next frontier is `SPEC-FORMAT-TERSE.6.2.2` for old helper spelling cleanup; the broader user directive to
audit/backfill useful type methods, including string `substr()`, is tracked as future `SPEC-FORMAT-TERSE.7.1`
backlog before implementation.

## 2026-07-03 — SPEC-FORMAT-TERSE.6.1 — own declare retirement migration

**Scope:** Terse-format task tree, task-tree index, roadmap/live docs, mdBook guidance, memory pointer, and
Knowledge Map. No `.spec` file changed in this ownership slice.

**What changed:** The user directive that `declare(...)` shall not be used in spec files is now owned under the
existing `SPEC-FORMAT-TERSE` tree. This implements the already-ratified ADR `0007` gradual migration promise:
auto-existing variables, assignment operators, direct shape literals, and type-implying positions are the
replacement path, not expanded runtime `declare` support.

**Evidence:** Inventory found 70 active `declare(...)` hits across 13 shipped specs under `specs/`. The next
frontier is `SPEC-FORMAT-TERSE.6.2`, which migrates shipped specs before any broader docs/corpus sweep or
post-migration compatibility decision.

## 2026-07-03 — RUST-PARITY.7.3.4.1 — fix header-rest action-edge parsing

**Scope:** Rust parser/compiler/runtime regression coverage, mdBook grammar/action-edge wording, task tree/index,
roadmap pointer, live docs, memory pointer, and Knowledge Map.

**What changed:** Rust now preserves compact header-rest body syntax instead of swallowing it as an invalid rule
mode suffix. This fixes regex-less top rules such as `lib_file:: -> group .push` and compact spellings such as
`Top::->Child.push`. The action-edge and blind-call recognizers now match the authoritative `specs/spec.spec`
grammar: spaces/tabs after `->` and `=>` are optional, not required.

**Evidence:** Parser tests lock spaced and compact header-rest action edges plus compact blind-call edges; a compiler
test proves `Wrapper::->child.push` emits the dependency-resolved child regex and fluent `.push` action dispatch;
and a runtime regression proves compact header-rest `->item.push` dispatch produces the expected child result. A
real `lib_reader` compiled-rule dump now includes the top `group` dispatch. Representative `lib_reader`
sattribute/cattribute probes no longer collapse to `[[]]`, but still expose null capture fields, so the remaining
runtime capture-propagation blocker is split to `RUST-PARITY.7.3.4.4`.

**Checks:** `cargo fmt` for `linkedspec-core` and `linkedspec-runtime`; focused core parser/compiler tests
(`action_edge`, `parse_blind_edge`); focused runtime compact-arrow regression; Rust `corpus_oracle`; mdBook build;
Knowledge Map check; memory-architecture check; doctrine registry; `git diff --check`; full local CI gate.

## 2026-07-03 — RUST-PARITY.7.3.4 — triage structural oracle mismatches

**Scope:** Task-tree/index, roadmap pointer, live docs, memory pointer, and Knowledge Map. No Rust parser/runtime
code and no oracle corpus fixtures changed.

**What changed:** Reproduced the `.7.2` structural divergences for `portmap`, `lib_reader`, and `ebnf`, then split
the implementation work into narrower owners before any code change. The next frontier is `RUST-PARITY.7.3.4.1`
for Rust parser/compiler handling of header-rest action edges on regex-less top rules.

**Evidence:** Perl reference probes (`perl -Iperl`, `LinkedSpec::get_parser`, `JSON::PP`) produced JSON-safe
reference values for representative inputs. A temporary Rust probe using the same parse/validate/compile/execute
path as `corpus_oracle` reproduced the mismatches: `portmap` scalar cases have wrong nesting/tagging and the bit
case warns `unknown helper 'or'`; `portmap` concatenation returns `[["?multi:",[]]]`; `lib_reader` sattribute and
cattribute inputs collapse to `[[]]` because Rust drops `lib_file:: -> group .push` from the compiled top rule;
and `ebnf` expression/logging inputs duplicate rule headers while dropping token payloads despite compiled fluent
chains being present.

**Checks:** Read-only/temporary reproduction only. The commit gates below verify the documentation/memory state and
the existing 66-fixture oracle remains green.

## 2026-07-03 — RUST-PARITY.7.3.7 — hard-timeout parser construction too

**Scope:** Oracle generator timeout boundary, corpus README, task-tree/index, roadmap pointer, live docs, and
Knowledge Map. No corpus fixture expected values changed.

**What changed:** `tools/gen_oracle_corpus.pl` now builds the Perl reference parser and runs the parse inside the
same forked child that the parent guards with `ORACLE_TIMEOUT` and `SIGKILL`. Previously the parser was built in
the parent and only `$parser->(...)` was hard-timeout protected.

**Evidence:** A user-directed shipped-spec/input census reproduced a live timeout on `BNF` under a 5s build+parse
child wrapper. Focused probes showed `LinkedSpec::get_parser("BNF")` takes about 6.4s while parsing empty input
after construction is about 0.03s; `LINKEDSPEC_TRACE_LEVEL=debug` trace reached successful parser generation.
That pins the issue to the oracle guard boundary, not a parser execution hang or BNF regex rewrite.

**Checks:** `perl -c -Iperl tools/gen_oracle_corpus.pl` PASS; forced `ORACLE_TIMEOUT=0` reports `hard kill during
parser build/parse`; normal regeneration writes **66** fixtures byte-identically; Rust `corpus_oracle` PASS;
Knowledge Map, memory architecture, doctrine, and whitespace gates PASS; full local CI PASS with phase0 **1018**
tests.

## 2026-07-03 — RUST-PARITY.7.3.3.3 — defer hlink scalar-ref fixtures

**Scope:** Task-tree/index, roadmap pointer, live docs, and Knowledge Map. No generator, corpus, Rust parser, or
Rust runtime code changed.

**What changed:** Closed the scalar-ref representation decision for bracket/mixed `hlink_substitution` fixtures
by deferring them to a dedicated follow-up owner (`RUST-PARITY.7.3.3.4`). The current corpus remains at **66**
fixtures, including the JSON-safe `{abc}` hlink curly fixture; `[abc]` and `foo[bar]{baz}` stay out of the JSON
oracle.

**Evidence:** Direct Perl probing shows `[abc]` returns a scalar reference and mixed `foo[bar]{baz}` returns an
array containing a scalar reference; `JSON::PP` fails with `cannot encode reference to scalar`. Rust audit/probe
shows the gap is broader than JSON: `RuntimeValue` has no scalar-ref representation, and the shipped hlink
scalar-ref action payload fails Rust action parsing before `[abc]` falls through to unmatched-closing-bracket
`exit_now(2)`.

**Checks:** Temporary Rust probe removed; `git diff -- rust/linkedspec-runtime/tests/integration_test.rs` empty.
Knowledge Map, memory architecture, doctrine, and whitespace gates PASS; Rust `corpus_oracle` PASS; full local CI
PASS with phase0 **1018** tests.

## 2026-07-03 — RUST-PARITY.7.3.3.2 — add hlink curly oracle fixture

**Scope:** Oracle generator case list, one generated corpus fixture, corpus README, mdBook backend handoff,
task-tree/index, live docs, roadmap pointer, and Knowledge Map. No Rust runtime/parser behavior changed.

**What changed:** Added the JSON-safe `hlink_substitution` curly-brace delimiter case `hlink_curly_brace`
(`{abc}`) to `tools/gen_oracle_corpus.pl` and regenerated the language-neutral oracle corpus. The new fixture
stores `{abc}` as input and `["{abc}"]` as the Perl reference value.

**Evidence:** Direct `perl -Iperl -MJSON::PP -MLinkedSpec` probing encoded `{abc}` as canonical JSON
`["{abc}"]`; generator syntax passed; normal regeneration wrote **66** fixtures; Rust `corpus_oracle` passed over
the 66-fixture corpus. Bracket/mixed scalar-reference hlink cases remain untouched and owned by `.7.3.3.3`.

**Checks:** mdBook build PASS; Knowledge Map, memory architecture, doctrine, and whitespace gates PASS; full local
CI PASS with phase0 **1018** tests.

## 2026-07-03 — RUST-PARITY.7.3.3.1 — split hlink delimiter fixtures

**Scope:** Task-tree/index, live docs, roadmap pointer, and Knowledge Map. No generator, corpus, parser, or runtime
code changed.

**What changed:** Split the remaining `hlink_substitution` delimiter fixture work after read-only probing showed
two separate paths: `{abc}` is a JSON-safe curly-brace fixture candidate, while `[abc]` and mixed
`foo[bar]{baz}` return Perl scalar references that the current JSON oracle cannot encode.

**Evidence:** Existing phase0 locks expect `[abc]` to return `[\'abc']`; direct `JSON::PP` probing fails with
`cannot encode reference to scalar`. The scalar-ref representation decision is now owned by `.7.3.3.3`; the next
frontier `.7.3.3.2` can add the JSON-safe `{abc}` fixture without broadening scope.

## 2026-07-03 — RUST-PARITY.7.3.2 — harden oracle timeout guard

**Scope:** Oracle generator timeout enforcement, corpus README, task tree/index, roadmap companion, live docs,
memory pointer, and Knowledge Map. No corpus fixture expected values changed.

**What changed:** Replaced the generator's per-parse `alarm()` guard with a real process-level hard timeout:
`tools/gen_oracle_corpus.pl` now forks a child for each parser run, has the child serialize the Perl reference
result to JSON, and has the parent enforce `ORACLE_TIMEOUT` with wall-clock wait plus `SIGKILL`. This matches
`TOOLBOX.md`: `alarm()` cannot interrupt catastrophic regex backtracking inside one Perl opcode.

**Evidence:** The historic `RTLUtils` timeout is not live in the current core tree (`perl/RTLUtils.pm`,
`perl/FSMGen.pm`, and `perl/VHDL/ConstantEval.pm` are absent; the remaining current-core hits are retirement
comments/docs). A fork+SIGKILL wrapper around the pre-change current generator completed all 65 fixtures in
about 11.3s, proving no live corpus hang. After the change, `perl -c -Iperl tools/gen_oracle_corpus.pl` passes,
normal regeneration writes all **65** fixtures byte-identically, and `ORACLE_TIMEOUT=0 perl -Iperl
tools/gen_oracle_corpus.pl` proves the hard-kill path.

**Checks:** Rust `corpus_oracle` PASS over the 65-fixture corpus; Knowledge Map, memory, doctrine, and whitespace
gates PASS; full local CI PASS with phase0 **1018** tests.

## 2026-07-03 — RUST-PARITY.7.3.1 — split batch-2 oracle lanes and timeout owner

**Scope:** Task-tree/index, roadmap companion, live docs, memory pointer, and Knowledge Map. No parser, runtime,
oracle generator, corpus fixture, or mdBook user-facing behavior changed.

**What changed:** Split the broad `RUST-PARITY.7.3` shipped-spec oracle batch into narrower leaves before code,
and made the timeout/hang question the immediate owned frontier. `.7.3.2` now owns trace-first timeout/hang
investigation with LinkedSpec's toolbox; `.7.3.3` tries remaining `hlink_substitution` delimiter/link-path
fixtures; `.7.3.4` triages the recorded `portmap` / `lib_reader` / `ebnf` structural mismatches; `.7.3.5`
triages the recorded `BNF` / `DT` / `ifelse` / `operators_try` / `spec.spec` null-output or action-parser-warning
candidates; and `.7.3.6` audits RTL/plugin legacy specs after the timeout concern is resolved or retired.

**Evidence:** The audit read the active `RUST-PARITY` task tree, current oracle generator, corpus README, corpus
runner, and Knowledge Map oracle card. The generator already has the hard `alarm(...)` guard; the committed corpus
is green at 65 fixtures; `.7.2` already recorded the concrete divergences that justify splitting instead of
bundling broad fixture work. The timeout leaf records the project toolbox requirement: use the fork+SIGKILL
hard-timeout census for true hangs because `alarm()` cannot interrupt a catastrophic regex opcode, then use
`LINKEDSPEC_TRACE_LEVEL=debug`, per-call trace options, and parser-source dumps against a live reproducer.

**Checks:** `knowledge-map/scripts/check_knowledge_map.sh`; `scripts/check_memory_architecture.sh`;
`scripts/check_doctrines.sh`; and `git diff --check` all passed.

## 2026-07-03 — STAGED-LINKED-PARSING.5.6 — prove function-body staged prototype

**Scope:** Focused Perl/Rust end-to-end tests, mdBook staged parsing overview/example text, task tree/index,
roadmaps, live docs, memory pointer, and Knowledge Map evidence. Production parser behavior is unchanged from
`.5.5`; this slice locks the proof.

**What changed:** Added a Perl phase0 proof that builds a multi-function descriptor, verifies source-order
function registry shape, normalized `body_payload` / `body_parse_job` provenance, deterministic body job ids,
`actionir-body.spec` / `action_block` identity, `replace_field` into `body_ast`, stitched `action_block` body
ASTs, stable runtime output, and source-provenance diagnostics for an unsupported body parser.

**Rust parity:** Added a matching Rust integration proof over raw `specs/user_function_definition.spec` AST
output, normalized `SpecFile.functions`, compiled `CompiledUserFunction` records, runtime execution, and dispatch
diagnostics. The expected Rust runtime shape remains the normal top-rule result collection containing the returned
payload.

**Docs:** The book now shows the current proof sample and clarifies that shipped parsers implement only the narrow
`body_parse_job` path. General public `parse_job(...)` authoring, provider/import search roots, multiple staged
parser families, recursive queues, and cycle diagnostics remain future leaves.

**Checks:** standalone Perl `LinkedSpec::Get`/registry proof; `perl -c -Iperl
t/phase0_regression.t`; `perl -c -Iperl perl/LinkedSpec/StagedParserRegistry.pm`; `cargo fmt --manifest-path
rust/linkedspec-runtime/Cargo.toml`; focused Rust
`function_body_staged_prototype_end_to_end_shape_and_runtime`,
`staged_parser_registry_dispatches_function_body_jobs`, and `spec_defined_user_function_parser`;
direct phase0 TAP run with **1018 green**; `mdbook build docs/linkedspec-book`; Knowledge Map, memory,
doctrine, and whitespace gates; and full local CI (`bash tools/run_ci_local.sh`) all passed.

## 2026-07-03 — STAGED-LINKED-PARSING.5.5 — dispatch function-body parse jobs

**Scope:** New Perl/Rust staged parser registry adapters, user-function body parsing path, Rust parsed/compiled
function state, focused Perl/Rust registry tests, mdBook staged parsing/descriptor/backend notes, task tree,
roadmap companion, live docs, and Knowledge Map.

**What changed:** Function-body `body_parse_job` records now execute through a minimal staged parser registry.
The first provider supports the neutral `actionir-body.spec` / `action_block` identity: `resolve` maps it to a
built-in provider identity, `load` records the adapter contract digest, `compile` creates a cache-keyed parser
adapter, and `execute` parses the exact body text into an `action_block` AST.

**Backend handling:** Perl now routes user-function body AST construction through
`LinkedSpec::StagedParserRegistry`; Rust adds `linkedspec-runtime::staged_parser_registry` and stores the
stitched `body_ast` on parsed and compiled function records. Existing user-function execution remains stable:
Perl lowering and Rust runtime execution still consume the compiled ActionIR body, now backed by the dispatched
body AST path.

**Tests:** Perl phase0 adds a focused staged-registry subtest for stable queue order, phase sequence, cache-key
fields, returned `action_block` shape, and resolve diagnostics. Rust integration tests lock the same registry
contract and assert that `parse_spec_with_user_functions` preserves stitched `body_ast` through compile.

**Checks:** Perl syntax checks for the new registry, user-function registry, and phase0 file; Rust format for both
crates; focused Rust runtime staged-registry and spec-defined user-function parser tests; focused Rust core
`user_function` tests; `prove -v -Iperl t/phase0_regression.t`; `mdbook build docs/linkedspec-book`;
Knowledge Map, memory, doctrine, and whitespace gates; and `bash tools/run_ci_local.sh` passed. Phase0 ended
with **1017 green**.

## 2026-07-03 — STAGED-LINKED-PARSING.5.4 — add function-body parse-job sidecar

**Scope:** `specs/user_function_definition.spec`, Perl user-function registry normalization, Rust parsed/compiled
function records, focused Perl/Rust AST-shape tests, mdBook staged parsing/descriptor/backend notes, task tree,
roadmap companion, live docs, and Knowledge Map. Runtime user-function behavior is unchanged.

**What changed:** Function-definition AST nodes now carry a neutral `body_parse_job` sidecar next to the existing
`body_payload` text island. The sidecar records `kind = parse_job`, deterministic job id, parent AST path,
`parser_spec_id = actionir-body.spec`, `top_rule = action_block`, `result_policy = replace_field`,
`result_field = body_ast`, `failure_policy = fail`, exact body text, source span, and diagnostic owner.

**Backend handling:** The Perl registry and Rust runtime adapter validate the spec-returned sidecar, normalize the
pending source-order parent path and job id once function ordinal is known, and preserve the sidecar through
descriptor / parsed / compiled function state. This leaf intentionally does not add staged parser registry or
dispatch execution; existing function execution still uses the current parsed ActionIR body AST.

**Tests:** Perl phase0 now asserts both raw spec AST and descriptor-normalized `body_parse_job` shape. Rust
integration tests assert raw `specs/user_function_definition.spec` output, normalized parsed `SpecFile.functions`,
and compiled-function sidecar preservation.

**Checks:** `perl -c perl/LinkedSpec.pm`; `perl -c -Iperl t/phase0_regression.t`; direct
`specs/user_function_definition.spec` AST probe; Perl descriptor `body_parse_job` probe; `cargo fmt` for both Rust
crates; focused Rust runtime `spec_defined_user_function_parser_*`; focused Rust core `user_function`; and
`prove -v -Iperl t/phase0_regression.t` all passed. Phase0 ended with **1016 green**.

## 2026-07-02 — STAGED-LINKED-PARSING.5.3.2 — retire Rust raw user-function definition parser

**Scope:** Rust core parser/compiler/runtime, the Rust spec-defined user-function parser adapter, focused Rust
AST-shape tests, runtime helper parity needed by `specs/user_function_definition.spec`, mdBook/backend notes,
task-tree frontier, roadmap/live docs, and Knowledge Map. The shared
`specs/user_function_definition.spec` contract is unchanged.

**What changed:** Rust no longer parses `fn name(params) { body }` shells with a competing raw parser in
`linkedspec-core::parser`. Rule-only parsing now leaves `SpecFile.functions` empty; the runtime-level
`spec_parser` module loads `specs/user_function_definition.spec`, executes it through the Rust engine, validates
the returned neutral `function_definition` / `function_definition_error` AST, strips exact source spans, and
attaches the resulting definitions before validation and compile.

**Runtime support:** The Rust engine now supports the spec surface needed by that parser: PCRE-style named
captures and leading inline flag toggles survive composed RGX alternations, regex-literal delimiters work in
`split` and `split_each`, bare `entry_named(name)` / `match_named(name)` resolve capture keys, multiline compact
lifecycle chains such as `I.return({ ... })` collect their full argument, child-rule capture slices start at the
entry end, and self-recursive close/finalizer edges execute their block without seeking a later close.

**Tests:** Focused Rust tests execute `specs/user_function_definition.spec` against concrete input strings and
assert the returned AST shape, spans, params, body text, body payload, and malformed-definition diagnostics. The
suite covers compact, spaced-param, multiline, nested-brace, string-brace, regex-brace, direct-shape, and malformed
forms, plus minimal regressions for edge-only child `I.return(...).push(...)`, regex-delimiter split, and
inline-flag branch identity.

**Checks:** `cargo fmt`; focused Rust runtime/core tests for the spec-defined UDF parser and touched helper
surfaces; shipped-spec parse/compile; Rust corpus oracle; `mdbook build docs/linkedspec-book`; Knowledge Map,
memory-architecture, doctrine, and whitespace gates; and `bash tools/run_ci_local.sh` all passed. The local CI
gate ended with phase0 **1016 green**.

## 2026-07-02 — STAGED-LINKED-PARSING.5.3.1 — consume spec-defined function AST in Perl

**Scope:** `specs/user_function_definition.spec`, the Perl user-function registry bridge, focused AST-shape
tests, mdBook descriptor/backend notes, task-tree frontier, roadmap/live docs, and Knowledge Map. Runtime
user-function execution is unchanged.

**What changed:** Added `specs/user_function_definition.spec` as the executable grammar owner for top-level
`fn name(params) { body }` definition shells. The spec returns source-ordered `function_definition` AST nodes
with parsed params, arity, exact source/body text, half-open source/body spans, source-slice provenance, and a
neutral `body_payload` record with `node_kind = function_definition` and `payload_kind = function_body`. The final
spec uses a linked opener/closer body shell plus body-island rules for nested braces, quoted strings, comments,
and regex literals; the earlier monolithic-body regex draft was retired before commit.

**Spec surface:** The new parser spec uses direct shape literals and receiver/bare-variable forms; it does not
use `declare(...)`, `array(...)`, `scalar(...)`, `hash(...)`, or `scalaref(...)`. Direct shape literals are
already supported on both Perl and Rust under `SPEC-FORMAT-TERSE.1.2.3.5.1` through `.1.2.3.5.4`.

**Perl bridge:** `LinkedSpec::UserFunctionRegistry` now loads the spec parser, executes it over the incoming
`.spec` source, validates the returned AST shape, post-annotates the pending source-order parent path, parses the
existing function body ActionIR, and strips definitions from the bootstrap source. The removed scanner functions
are no longer a second Perl grammar owner.

**Variant status:** The uncommitted Rust raw-parser payload expansion was removed from this slice. Existing Rust
user-function parsing remains pre-existing bridge debt; the next owned frontier is to retire remaining
host-language user-function definition parsers in favor of the same spec-owned AST contract.

**Tests:** Added direct AST-shape coverage for `specs/user_function_definition.spec` across zero-arg,
whitespace-param, multi-param, multiline, nested-brace, string-brace, regex-brace, direct-shape, assignment,
hash-index, adjacent-nested-brace, malformed, and unbalanced-body variations. Existing descriptor tests now assert
the spec-returned payload shape and malformed-function AST diagnostic path.

**Next:** `STAGED-LINKED-PARSING.5.3.2` retires the remaining host-language user-function definition parser
bridges, starting with Rust, so user-defined functions are parsed only by the spec-defined parser contract.

**Checks:** Perl syntax, generated-handler debug dump, direct spec-parser AST probe, focused descriptor payload
probe, mdBook build, Knowledge Map regeneration/check, memory architecture, doctrine registry, `git diff --check`,
and full local CI pass in the commit workflow.

## 2026-07-02 — STAGED-LINKED-PARSING.5.2 — audit function definition AST shape

**Scope:** Read-only architecture audit, ADR, mdBook/backend notes, task-tree frontier, roadmap/live docs, and
Knowledge Map; no runtime code change.

**What changed:** Audited the function-body staged-prototype seams before implementation. The focused probes show
that a direct top regex rule cannot read its own captures through `entry_group(...)`; focused function-definition
AST tests must use a tiny wrapper top rule that dispatches into a normal `function_definition` rule and returns
the accumulated nodes from `LX`.

**Findings:** The current numbered-capture `specs/spec.spec` function rule mis-shapes zero-argument functions
because optional captures are compacted, and it does not protect regex literals containing braces. Perl and Rust
bridges also differ on provenance storage: Perl preserves exact inner body text plus byte spans, while Rust trims
`body_source` and records line spans.

**Contract:** Added ADR `0017`, defining the neutral target `function_definition` AST shape: `type`, `name`,
`params`, `arity`, `source_text`, `source_span`, exact inner `body_source`, `body_span`, `body_parse_job`, and
stitched `body_ast` after dispatch. The variation matrix includes zero/one/many params, whitespace, nesting,
quoted braces, escaped quotes, regex-brace bodies, adjacency, malformed definitions, duplicates, collisions, and
reserved names.

**Next:** `STAGED-LINKED-PARSING.5.3` preserves source provenance for function-body payload parse jobs.

**Checks:** mdBook build, Knowledge Map regeneration/check, memory architecture, doctrine registry,
`git diff --check`, and full local CI pass in the commit workflow.

## 2026-07-02 — STAGED-LINKED-PARSING.5.1 — select staged prototype payload family

**Scope:** Task-tree split, ADR, mdBook staged parsing/backend text, roadmap/live docs, and Knowledge Map; no
runtime code change.

**What changed:** Split the broad first-prototype leaf into executable leaves `.5.1` through `.5.6`. The first
prototype payload family is user-defined function body text: `specs/spec.spec` already extracts a bounded body
payload, and current Perl/Rust user-function bridges provide behavior to preserve while the staged path replaces
bridge debt.

**Neutrality:** Added ADR `0016`, making language neutrality a hard requirement for every staged parsing artifact.
Syntax, AST metadata, source provenance, parse-job scheduling, registry/cache identity, diagnostics, fixtures, and
mdBook wording must be `.spec`/AST contracts. Backend mechanics are adapters and evidence, not semantics.

**Next:** `STAGED-LINKED-PARSING.5.2` audits the function-body seams before code: current extraction, source spans,
temporary bridges, diagnostics, tests, the predicted returned `function_definition` AST shape, a large
function-definition variation matrix for the spec rule that returns that AST, the dedicated small spec/top rule
used for focused AST-shape tests, and the minimal next-stage spec/top-rule shape.

**Checks:** mdBook build, Knowledge Map regeneration/check, memory architecture, doctrine registry,
`git diff --check`, and full local CI pass in the commit workflow.

## 2026-07-02 — STAGED-LINKED-PARSING.4 — specify staged parser registry dispatch

**Scope:** Architecture decision, mdBook staged parsing/backend text, task-tree frontier, roadmap/live docs, and
Knowledge Map.

**What changed:** Added ADR `0015`, specifying the design-only staged parser registry and dispatch queue before
implementation. The registry exposes neutral `resolve`, `load`, `compile`, and `execute` operations.

**Contract:** Parse-job resolution is deterministic: parent import aliases/composed identities, declaring-spec
relative paths, configured search roots, then explicit registry providers. Cache keys include normalized spec
identity, content digest, import/include graph fingerprint, selected top rule, `.spec` language version,
helper/action contract version, staged parsing contract version, and backend capability set.

**Dispatch:** The scheduler completes the current stage, collects jobs in parent-AST-path/source-span/job-id order,
executes and stitches results in that stable order, and enqueues newly emitted jobs at the next stage depth.
Active-chain cycles repeat normalized spec identity, top rule, payload digest, and source span.

**Checks:** mdBook build, Knowledge Map regeneration/check, memory architecture, doctrine registry,
`git diff --check`, and full local CI pass in the commit workflow.

## 2026-07-02 — STAGED-LINKED-PARSING.3 — specify staged parse-job annotations

**Scope:** Architecture decision, mdBook staged parsing/backend text, task-tree frontier, roadmap/live docs, and
Knowledge Map.

**What changed:** Added ADR `0014`, specifying the design-only staged parse-job annotation contract before
implementation. The reserved future authoring marker is `parse_job(text_expr, options)`, which produces a marker
value in the stage-N AST plus neutral sidecar metadata.

**Contract:** Parse-job metadata includes deterministic job id, parent AST path, node kind, payload kind, exact
text, source span/provenance, parser spec identity, optional top rule, result policy, and failure policy. Result
policies are `replace_marker`, `replace_field`, `sibling_field`, and `append_child`; failure policies are `fail`,
`keep_text`, and `diagnostic_node`.

**Neutrality:** The marker and sidecar schema are implementation-language neutral across Perl5, Raku, Rust, Julia,
Lua, Dart, Zig, Go, or future backends. Current shipped parsers do not yet accept or execute `parse_job(...)`.

**Checks:** mdBook build, Knowledge Map regeneration/check, memory architecture, doctrine registry,
`git diff --check`, and full local CI pass in the commit workflow.

## 2026-07-02 — STAGED-LINKED-PARSING.2 — specify spec import composition contract

**Scope:** Architecture decision, mdBook backend/rationale text, task-tree frontier, roadmap/live docs, and
Knowledge Map.

**What changed:** Added ADR `0013`, specifying spec-file import/composition before implementation. The reserved
future syntax is file-scope `import "path.spec" as alias` for qualified grammar reuse and
`include "path.spec"` for structured unqualified composition.

**Contract:** Imports/includes compose grammar material only. They are not staged parse jobs and do not parse
runtime text payloads. Resolution must be deterministic; duplicate aliases, duplicate included rule names,
ambiguous unqualified references, missing specs, and import cycles are hard diagnostics with source provenance.
Descriptor fingerprints include normalized spec identities and content digests for composed dependencies.

**Neutrality:** The directive graph is implementation-language neutral across Perl5, Raku, Rust, Julia, Lua,
Dart, Zig, Go, or future backends. Current shipped parsers do not yet accept the directives; this slice reserves
the syntax and semantics before code.

**Checks:** mdBook build, Knowledge Map regeneration/check, memory architecture, doctrine registry,
`git diff --check`, and full local CI pass in the commit workflow.

## 2026-07-02 — STAGED-LINKED-PARSING.1 — adopt staged linked parsing doctrine

**Scope:** Architecture doctrine, task-tree ownership, mdBook pipeline/backend explanation, roadmap/live docs, and
Knowledge Map.

**What changed:** Added ADR `0012`, making staged linked parsing a first-class LinkedSpec architecture. A stage-N
`.spec` may parse the structure that has reliable anchors, emit AST nodes carrying source-provenance text islands,
and route those payloads to one or more later `.spec` parsers through deterministic parse jobs.

**Contract:** Staged parse dispatch is separate from spec imports/composition. Imports compose grammar material;
parse jobs refine runtime payload text extracted by an earlier parser. Parse jobs must carry parser identity,
optional top rule, payload/source span, parent AST path, result insertion policy, and failure/diagnostic policy.

**Neutrality:** The staged parse graph is implementation-language neutral across Perl5, Raku, Rust, Julia, Lua,
Dart, Zig, Go, or future backends. The contract is `.spec`, AST payloads, parse jobs, descriptors, diagnostics,
and deterministic parser entry semantics, not a host-language parser trick.

**Checks:** mdBook build, Knowledge Map regeneration/check, memory architecture, doctrine registry,
`git diff --check`, and full local CI pass in the commit workflow.

## 2026-07-02 — RUST-PARITY.7.2 — expand shipped-spec oracle batch

**Scope:** Rust parser header-rest parsing, Rust regex/capture helper projection, focused Rust tests, oracle
generator/corpus fixtures, task-tree/live docs, and Knowledge Map.

**What changed:** Rust rule-header rest content now uses the same body-element parser as ordinary body lines.
That keeps compact header-line lifecycle chains and multiline header-rest lifecycle blocks executable and prevents
their continuation lines from being collected a second time as ordinary body lines.

**Capture parity:** Rust `entry_group(N)` / `match_group(N)` now match the documented Perl contract: the helper
list is captures-only, 0-based over participating captures, and compacted by dropping non-participating optional
captures while retaining participating empty-string captures. `entry_text()` and `match_text()` now read whole-match
text from stored spans rather than relying on group index 0.

**Corpus:** Added two clean shipped-spec oracle fixtures for `hlink_substitution` raw-string paths:
`hlink_raw_string` and `hlink_raw_escaped_brackets`. Oracle regeneration now produces **65 fixtures** and the Rust
fixture runner passes over all 65. Broader attempted candidates (`portmap`, `lib_reader`, `ebnf`, `BNF`, `DT`,
`ifelse`, `operators_try`, and selected `spec.spec` smokes) still diverge structurally and are deferred with
evidence in the task tree.

**Docs:** The mdBook backend handoff appendix now reports the 65-fixture corpus and names the new
`hlink_substitution` raw-string cases. No helper-contract page edit was needed: the helper catalog and regex
chapter already document the captures-only, 0-based, compacted capture contract. This slice brings Rust back into
that documented behavior.

**Checks:** Focused Rust parser/runtime checks, oracle generator syntax/regeneration, Rust corpus oracle, mdBook
build, Knowledge Map regeneration/check, memory architecture, doctrine registry, `git diff --check`, and full local
CI passed in the commit workflow.

## 2026-07-02 — SCALAREF-RETIREMENT.5 — close scalaref retirement tree

**Scope:** Final drift sweep for legacy `scalaref(...)` references across root corpus fixtures, current-facing
roadmap/architecture/task-tree prose, Knowledge Map cards, live docs, and task-tree/index status.

**What changed:** Root language-neutral corpus fixtures for Lispish and tablegrep now use direct nested access
(`retv["content"]`, `retv["type"]`) instead of legacy `scalaref(...)`. Current-facing roadmap, architecture,
method-like DSL, Rust parity, and Knowledge Map wording now labels historical `scalaref` support as retired rather
than active. `SCALAREF-RETIREMENT` is closed and moved to the completed task-tree index.

**Checks:** Active `scalaref(` / `.scalaref(` scans now show only the intentional negative regression locks; the
root Lispish/tablegrep corpus specs compile through `LinkedSpec::Get`; `tools/run_ci_local.sh` passes with phase0
1015 green; Knowledge Map regeneration/check, mdBook, memory architecture, doctrine registry, and `git diff --check`
pass in the commit workflow.

## 2026-07-02 — SCALAREF-RETIREMENT.4 — remove scalaref implementation support

**Scope:** Perl ActionIR value/method/flow lowering, Perl EmitContext owner bridge, Rust expression parser,
Rust validation/runtime dispatch, focused Perl/Rust regression locks, public architecture wording, and Knowledge
Map/live-doc synchronization.

**What changed:** `scalaref(...)` is no longer a supported helper on Perl or Rust. Perl removed the
function-form lowering path, the receiver-dot hash-chain terminal, and helper-whitelist recognition. The remaining
direct-access internals were renamed to `_split_nested_access_path_segments(...)` and
`_lower_nested_access_segment_expr(...)` so they describe the surviving `foo["key"][idx]` surface rather than the
retired helper. Rust removed the scoped `ScalarRefPath` AST/parser hook, validation support, runtime evaluator,
and `call_helper("scalaref", ...)` arm.

**Behavior:** Migrated positive examples continue to use direct nested access or `scalar(hash(name), key)`.
Function-form `scalaref(...)` now follows the existing unsupported/unknown-helper policy: Perl emits the
unsupported-helper diagnostic sentinel in focused lowering, while Rust evaluation returns `undef`/JSON `null`.
Receiver-dot `.scalaref(...)` is no longer a supported hash receiver method.

**Checks:** Perl syntax checks for the touched ActionIR/EmitContext modules and `t/phase0_regression.t`; focused
Rust parser/runtime checks for direct access and `SCALAREF-RETIREMENT.3`/`.4`; implementation and public-surface
`scalaref` scans; full phase0; Rust corpus oracle; mdBook build; Knowledge Map regeneration/check; memory
architecture; doctrine registry; `git diff --check`.

## 2026-07-02 — SCALAREF-RETIREMENT.3 — migrate scalaref live surface

**Scope:** Shipped specs, checked-in Rust oracle fixtures, public/user guides, focused tests, and the minimum
Perl/Rust support needed for the replacement forms. Implementation recognition for `scalaref(...)` remains until
the removal leaf `.4`.

**What changed:** The live shipped surface no longer uses `scalaref(...)` or receiver-dot `.scalaref(...)`.
`specs/Lispish.spec`, `specs/ds_vhistory.spec`, `specs/pplugin.spec`, and `specs/tablegrep.spec` now use direct
nested access such as `retv["content"]`, `retv[0]`, and `cur_object[1]`. The Rust oracle generator and checked-in
fixtures were regenerated with the same direct-access spelling, while expected JSON stayed stable.

**Runtime/lowering support:** Perl flow-expression lowering now recognizes direct nested access inside presence,
emptiness, and composite flow expressions, so `is_defined(retv["content"])` lowers to the same dereference shape as
other direct-access value contexts. Rust `scalar(hash_expr, key)` now reads from hash runtime values, which supports
the named-hash-temp replacement for receiver-dot field reads.

**Docs:** User guides, mdBook helper references, corpus docs, and emitted-Perl reference examples now teach direct
nested access or `scalar(hash(name), key)` for working-hash field reads. Direct bracket reads are documented as
scalar hashref payload reads, not named working-hash value reads.

**Checks:** `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`; `perl -c tools/gen_oracle_corpus.pl`;
`perl tools/gen_oracle_corpus.pl`; focused Rust tests for `scalaref_retirement_3`,
`terse_2_3_5_2_hash_receiver_value_chains_run`, and
`terse_2_3_4_1_hash_consumers_accept_bare_hash_arg`; `cargo test -q --manifest-path rust/Cargo.toml -p
linkedspec-runtime --test corpus_oracle`; `perl -c -Iperl t/phase0_regression.t`; `prove -q -Iperl
t/phase0_regression.t` (1015 PASS); `mdbook build docs/linkedspec-book`; `cargo fmt --manifest-path
rust/linkedspec-runtime/Cargo.toml --check`; active `scalaref(` / `.scalaref(` scans; `git diff --check`.

## 2026-07-02 — SCALAREF-RETIREMENT.2 — inventory scalaref retirement contract

**Scope:** Inventory and replacement-contract documentation for `scalaref(...)` retirement. No parser, compiler,
runtime, shipped-spec, oracle, mdBook, or user-guide behavior changed in this slice.

**What changed:** `docs/tasks/SCALAREF-RETIREMENT.md` now records the complete retirement inventory. Live uses are
classified across shipped specs, checked-in oracle fixtures, Perl/Rust implementation support, tests/tools, public
docs, user guides, historical task-tree records, and Knowledge Map cards. The current shipped specs contain 16
function-form `scalaref(...)` calls; public mdBook/user-guide examples contain 332 function-form references; and
receiver-dot `.scalaref(...)` appears in hash receiver-chain examples/tests.

**Replacement contract:** Function-form `scalaref(base, {key})` migrates to direct nested access
`base["key"]`; `[0]` segments stay `[0]`; mixed paths such as `{children}[0]{name}` become
`["children"][0]["name"]`. Receiver-dot `.scalaref(key)` is in retirement scope too: named working hashes use
`scalar(hash(meta), key)`, while expression receivers must first assign to a named working-hash temporary before
reading that key. Direct bracket reads are for scalar hashref payloads such as `retv["key"]`, not working-hash
value reads.

**Boundary:** This is still pre-removal work. The next leaf, `SCALAREF-RETIREMENT.3`, performs the actual shipped
spec/test/oracle/public-doc migration. Implementation support stays intact until `.4`.

**Checks:** `rg` inventory, Perl `call_spec_handler_subst` direct-access probes, focused Rust direct-access
parser/runtime tests, Knowledge Map regeneration/check, memory architecture, doctrine registry, and
`git diff --check` passed.

## 2026-07-02 — SCALAREF-RETIREMENT.1 — own scalaref retirement track

**Scope:** Task-tree ownership, task-tree index, roadmap/live docs, memory, and Knowledge Map. No parser,
compiler, runtime, shipped-spec, oracle, or mdBook behavior changed in this ownership slice.

**What changed:** The 2026-07-02 user directive that `scalaref(...)` shall be retired and removed is now owned by
`docs/tasks/SCALAREF-RETIREMENT.md`. The tree splits the work into inventory/replacement design, shipped
spec/test/doc migration, Perl/Rust removal, and final drift cleanup, so no behavior change happens before the live
uses and replacement contract are proven.

**Boundary:** `RUST-PARITY.7.5.2` remains a parity fix for the current shipped Lispish surface. The restored
legacy `scalaref(retv, {content})` support is removal-bound, but removal must proceed under
`SCALAREF-RETIREMENT.2+` after a complete inventory. The mdBook is intentionally unchanged here because the
codebase behavior is unchanged; the migration/removal leaves will update user-facing docs when the public contract
changes.

**Checks:** Knowledge Map regeneration/check, memory architecture, doctrine registry, mdBook build, and
`git diff --check` passed.

## 2026-07-02 — RUST-PARITY.7.5.2 — land Lispish scalaref parity

**Scope:** Rust expression parser, Rust runtime, focused parser/runtime locks, oracle generator/corpus,
task-tree/live docs, mdBook backend handoff, and Knowledge Map.

**What changed:** Rust now parses the legacy `scalaref(base, path)` path surface needed by Lispish, scoped to
`scalaref`'s second positional argument so general brace expressions and hash literals keep their existing
behavior. Runtime `scalaref` walks mixed hash-key and array-index path segments; bare legacy path atoms such as
`{content}` are literal field names, while explicit scalar/helper expressions still evaluate.

**Runtime parity fixes:** Child rule returns are now contained when used through parent dispatch/call paths, so a
child `return(...)` feeds the parent-visible return value without leaking the child's accumulator pushes into the
parent output. Action-edge blocks that explicitly call their child avoid duplicate pre-dispatch, matching the
generated Perl pattern used by Lispish. Explicit aggregate-wrapper assignment now replaces the array/hash working
store, so forms such as `assign(array(word), array())` clear the working array instead of falling back to scalar
assignment.

**Corpus:** The `lispish_x_y` shipped-spec fixture is active again. Oracle regeneration now produces **63
fixtures**, and the Rust corpus oracle passes over the expanded corpus.

**Compatibility boundary:** This is a parity slice for the existing shipped surface, not a language-design rewrite.
`scalaref(...)` and the Perl-shaped hash literal spelling are legacy compatibility surfaces restored here only so
Rust matches shipped Lispish behavior. They are slated for retirement/removal under a separate task-tree-owned
parser/lowering/spec/docs migration.

**Checks:** Focused Rust parser/runtime checks, `retv_5_1` regression checks, Perl oracle generator syntax and
regeneration, Rust corpus oracle, mdBook build, Knowledge Map regenerate/check, memory architecture, doctrine
registry, `git diff --check`, and full local CI passed.

## 2026-07-02 — RUST-PARITY.7.5.3 — reconcile action-edge fluent closure

**Scope:** Rust parity task-tree reconciliation, corpus README drift fix, roadmap/live status repair, and
Knowledge Map. No parser/compiler/runtime code changed.

**What changed:** The stale `RUST-PARITY.7.5.3` frontier is now marked done from committed implementation
evidence. Action-edge fluent continuations were implemented under `SPEC-FORMAT-TERSE.2.3.3.1` and
`.2.3.3.3.2`, while the separate `tclite` default-mode repetition gap closed under `.2.3.3.3.3.1`. The two
shipped `tclite` oracle fixtures are active and green in the current corpus.

**Boundary:** This does not close the independent Lispish gap. `RUST-PARITY.7.5.2` remains the next frontier for
`scalaref(retv, {content})`; `.7.2` and `.7.3` remain blocked until `.7.5.2` is resolved.

**Checks:** Rust corpus oracle, mdBook build, Knowledge Map regenerate/check, memory architecture, doctrine
registry, `git diff --check`, and full local CI passed. The corpus oracle now passes over the current **62
fixtures**.

## 2026-07-02 — SPEC-FORMAT-TERSE.3.3.4 — close assignment expression docs

**Scope:** Parent assignment-expression closure fixture, Rust runtime lock, oracle corpus, mdBook public example
cleanup, task-tree/status drift repair, live recovery docs, and Knowledge Map.

**What changed:** The `.3.3` assignment-expression family is now closed across scalar assignment values, direct
RHS shape aggregate assignment values, `items += value`, `meta[key] = value`, `=(target,value)`, canonical
`set(...)`, user-function body assignment, receiver-chain terminals, and retained legacy `assign(...)`
compatibility. Public book examples now prefer `set(...)` or operator assignment; `assign(...)` remains documented
as a legacy alias with current value semantics.

**Compatibility boundary:** Existing `assign(...)` specs remain supported. The docs no longer promote it as new
syntax. No new concrete `SPEC-FORMAT-TERSE` PNT-eligible implementation leaf remains after this closure; future
backend leaves stay deferred or blocked by explicit roadmap decisions.

**Checks:** Focused Perl phase0 closure lock, focused Rust runtime closure test, oracle generation, Rust corpus
oracle, mdBook build, Knowledge Map regenerate/check, memory architecture, doctrine registry, `git diff --check`,
and full local CI passed. Local CI includes phase0 passing with **1015 tests** and the corpus oracle passing over
**62 fixtures**.

## 2026-07-02 — SPEC-FORMAT-TERSE.3.3.3 — implement mutation assignment values

**Scope:** Perl ActionIR mutation assignment expression lowering and auto-declarations, Rust parser/runtime
expression evaluation, phase0 locks, Rust parser/runtime tests, oracle corpus, mdBook, task tree, live recovery
docs, and Knowledge Map.

**What changed:** Array append and hash-index mutation operators are now value expressions on Perl and Rust.
`items += value` mutates the named working array and yields the updated array snapshot. `meta[key] = value`
mutates the named working hash and yields the updated hash snapshot. Both forms compose in `return(...)`, helper
arguments, expression-valued blocks, and compatible receiver chains such as `(items += value).count()` and
`(meta[key] = value).count_keys()`.

**Compatibility boundary:** Statement behavior is preserved. This does not make array end-mutation methods
value-returning; `items.push_back(...)` / `pop_back()` remain statement-level mutation methods. The remaining
assignment-expression closure work was `.3.3.4`, which later landed legacy `assign(...)` example cleanup and final
contract-drift closure.

**Checks:** Perl syntax checks, focused `t/actionir_ast_parser.t`, focused Rust parser/runtime tests, oracle
generation, Rust corpus oracle, full phase0, mdBook build, Knowledge Map regenerate/check, memory architecture,
doctrine registry, `git diff --check`, and full local CI passed. Local CI includes phase0 passing with **1014
tests** and the corpus oracle passing over **61 fixtures**.

## 2026-07-02 — SPEC-FORMAT-TERSE.3.3.2 — implement aggregate assignment values

**Scope:** Perl ActionIR aggregate assignment expression lowering and auto-declarations, Rust runtime assignment
evaluation, phase0 locks, Rust parser/runtime tests, oracle corpus, mdBook, task tree, live recovery docs, and
Knowledge Map.

**What changed:** Direct RHS shape assignments are now value expressions on Perl and Rust. Bare targets infer array
or hash kind from the RHS and yield the assigned aggregate value: `items = [value]`, `set(items, [value])`,
`=(items, [value])`, `meta = { key => value }`, and matching `array(...)` / `hash(...)` targets compose in
`return(...)`, helper arguments, blocks, and receiver chains.

**Compatibility boundary:** Explicit `scalar(payload)` still stores the whole shape payload in a scalar and yields
that payload. Statement behavior is preserved. Array append values and hash-index mutation values later landed in
`.3.3.3`.

**Checks:** Perl syntax checks, focused `t/actionir_ast_parser.t`, generated-source declaration probes, focused Rust
parser/runtime tests, oracle generation, Rust corpus oracle, full phase0, mdBook build, Knowledge Map
regenerate/check, memory architecture, doctrine registry, `git diff --check`, and full local CI passed. Local CI
includes phase0 passing with **1013 tests** and the corpus oracle passing over **60 fixtures**.

## 2026-07-02 — SPEC-FORMAT-TERSE.3.3.1 — implement scalar assignment values

**Scope:** Perl ActionIR method-call parsing/lowering, Rust expression parsing/runtime dispatch, phase0 locks,
Rust parser/runtime tests, oracle corpus, mdBook, task tree, live recovery docs, and Knowledge Map.

**What changed:** Scalar non-shape assignment is now an expression value on Perl and Rust. `name = value`,
`=(name,value)`, scalar `set(name,value)`, and scalar `assign(name,value)` store the scalar and yield the stored
value in return payloads, helper arguments, expression-valued blocks, user-function bodies, and compatible
scalar receiver chains such as `=(raw, " hi ").trim()`.

**Compatibility boundary:** Statement behavior is preserved. Direct RHS shape assignment expression values later
landed in `.3.3.2`; array append values and hash-index mutation values later landed in `.3.3.3`. Perl aggregate-call
lowering keeps nested wrapper calls such as `count(array(items))` source-shaped while allowing direct
multi-argument `array(name, other)` scalar payload reads.

**Checks:** Perl syntax checks, focused `t/actionir_ast_parser.t`, focused Perl runtime/source probes, focused
Rust parser/runtime tests, oracle generation, Rust corpus oracle, phase0, mdBook build, Knowledge Map
regenerate/check, memory architecture, doctrine registry, `git diff --check`, and full local CI passed. Local CI
includes phase0 passing with **1012 tests** and the corpus oracle passing over **59 fixtures**.

## 2026-07-02 — SPEC-FORMAT-TERSE.3.3 — split expression-valued assignment

**Scope:** Task tree, mdBook assignment wording, live recovery docs, and Knowledge Map. No parser/compiler/runtime
code changed.

**What changed:** The expression-valued assignment contract is now split before implementation. `target = value`
remains the canonical destination spelling, `=(target,value)` is the planned ordinary operator-call equivalent,
and legacy `assign(target,value)` stays migration debt rather than new-example syntax.

**Compatibility boundary:** Current shipped behavior is unchanged and remains statement-level for scalar
assignment, array append, and hash-index assignment. TOOLBOX probes confirm `name = "ok"; return(name)` runs
today while `return(name = "ok")`, `return(=(name,"ok"))`, `return(set(name,"ok"))`, and assignment nested in a
helper argument do not yet produce expression values. The implementation frontier is `.3.3.1` for scalar
assignment expression values and scalar `=(target,value)` equivalence.

**Checks:** TOOLBOX assignment probes, Rust source/test audit, mdBook build, Knowledge Map regenerate/check,
memory architecture, doctrine registry, `git diff --check`, and full local CI passed.

## 2026-07-02 — SPEC-FORMAT-TERSE.3.2.3.4 — implement comparison symbol callees

**Scope:** Perl ActionIR method-call parsing/lowering, Rust expression parsing/runtime dispatch, phase0 locks,
Rust parser/runtime tests, oracle corpus, mdBook, task tree, live recovery docs, and Knowledge Map.

**What changed:** Comparison symbol callees are now ordinary `callee(args)` forms over the numeric comparison
helper family. `==(a,b)`, `!=(a,b)`, `>(a,b)`, `>=(a,b)`, `<(a,b)`, and `<=(a,b)` dispatch through
`num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, and `num_le` on Perl and Rust.

**Compatibility boundary:** Slash regex handling from `.3.2.2` remains intact, arithmetic slash calls still map
to `num_div`, lexical string comparisons still use `str_*`, and `=(target,value)` remains deferred to
`SPEC-FORMAT-TERSE.3.3`. The `=>` blind-call edge operator is unchanged.

**Checks:** Perl syntax checks, focused Perl lowering/runtime/source probes, focused Rust parser/runtime tests,
oracle generation, Rust corpus oracle, phase0, mdBook build, Knowledge Map regenerate/check, memory
architecture, doctrine registry, `git diff --check`, and full local CI passed. Local CI includes phase0 passing
with **1011 tests** and the corpus oracle passing over **58 fixtures**.

## 2026-07-02 — SPEC-FORMAT-TERSE.3.2.3.3 — flip comparison word aliases

**Scope:** Perl ActionIR comparison lowering, Rust helper validation/runtime dispatch, shipped `.spec`
lexical-comparison migrations, phase0 locks, Rust integration test, oracle corpus, mdBook, task tree, live
recovery docs, and Knowledge Map.

**What changed:** Ordinary value-call comparison words `eq`, `ne`, `gt`, `ge`, `lt`, and `le` now map to the
numeric `num_eq`, `num_ne`, `num_gt`, `num_ge`, `num_lt`, and `num_le` helpers on Perl and Rust. Explicit
`num_*` helpers and number receiver terminals remain accepted numeric comparisons.

**Compatibility boundary:** Lexical string comparisons now use the explicit `str_eq`, `str_ne`, `str_gt`,
`str_ge`, `str_lt`, and `str_le` bridge shipped by `.3.2.3.2`; repo-owned specs and tests that depended on
bare string comparison words were migrated to `str_*`. Comparison symbol callees remain unimplemented until
`.3.2.3.4`.

**Checks:** Perl syntax checks, focused Perl lowering/runtime/source probes, focused Rust runtime comparison-word
test, oracle generation, Rust corpus oracle, phase0, mdBook build, Knowledge Map regenerate/check, memory
architecture, doctrine registry, `git diff --check`, and full local CI passed. Local CI includes phase0 passing
with **1010 tests** and the corpus oracle passing over **57 fixtures**.

## 2026-07-02 — SPEC-FORMAT-TERSE.3.2.3.2 — implement string comparison helpers

**Scope:** Perl ActionIR flow/value lowering, Rust helper validation/runtime dispatch, phase0 locks, Rust
integration test, oracle corpus, mdBook, task tree, live recovery docs, and Knowledge Map.

**What changed:** `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le` are now shipped explicit
lexical string comparison helpers on Perl and Rust. They compose in value and flow predicates, lower without raw
helper residue, and return boolean-like values matching the existing bare string comparison semantics.

**Compatibility boundary:** Bare `eq(...)`, `ne(...)`, `gt(...)`, `ge(...)`, `lt(...)`, and `le(...)` remain
runnable string-comparison compatibility aliases for now. The next owned leaf, `.3.2.3.3`, may flip ordinary
comparison word calls to numeric `num_*` aliases because new lexical string examples can now use `str_*`.
Comparison symbol callees remain unimplemented until `.3.2.3.4`.

**Checks:** Perl syntax checks, focused Rust runtime string-helper test, oracle generation, Rust corpus oracle,
phase0, mdBook build, Knowledge Map regenerate/check, memory architecture, doctrine registry, `git diff
--check`, and full local CI passed. Local CI includes phase0 passing with **1009 tests** and the corpus oracle
passing over **56 fixtures**.

## 2026-07-02 — SPEC-FORMAT-TERSE.3.2.3.1 — lock string comparison bridge

**Scope:** Task tree, roadmap/status docs, mdBook comparison-helper wording, Knowledge Map, and live recovery
docs. No parser/compiler/runtime code changed.

**What changed:** The explicit string-comparison bridge contract is now locked before implementation. The
accepted names are `str_eq`, `str_ne`, `str_gt`, `str_ge`, `str_lt`, and `str_le`; they preserve today's
lexical string comparison semantics and are not numeric helpers, receiver-dot links, or symbol callees.

**Compatibility boundary:** Current shipped behavior remains unchanged. Bare `eq(...)`, `ne(...)`, `gt(...)`,
`ge(...)`, `lt(...)`, and `le(...)` remain the runnable string helpers until `.3.2.3.2` implements `str_*`.
The book names the accepted bridge but warns that `str_*` is not shipped syntax yet. Bare comparison words
cannot flip to numeric aliases until the bridge implementation exists and repo-owned string examples/tests are
migrated or compatibility-covered.

**Checks:** `perl -Iperl -c perl/LinkedSpec/ActionIR/FlowExpr.pm`, Knowledge Map regenerate/check, memory
architecture, doctrine registry, mdBook build, `git diff --check`, and full local CI passed. Local CI included
phase0 passing with **1008 tests**.

## 2026-07-02 — SPEC-FORMAT-TERSE.3.2.3 — split comparison call surface

**Scope:** Task tree, roadmap/status docs, mdBook comparison-helper notes, Knowledge Map, and live recovery docs.
No parser/compiler/runtime code changed.

**What changed:** The comparison operator-call migration is now split before implementation. The future
canonical numeric surface is ordinary `callee(args)` calls with word and symbol spellings: `eq`/`==`,
`ne`/`!=`, `gt`/`>`, `ge`/`>=`, `lt`/`<`, and `le`/`<=`, all mapping to the existing `num_*` comparison family.

**Compatibility boundary:** Current shipped behavior remains unchanged. Bare `eq(...)`, `ne(...)`, `gt(...)`,
`ge(...)`, `lt(...)`, and `le(...)` remain string comparisons until the explicit string bridge lands. The split
frontier is `.3.2.3.1` string bridge contract, `.3.2.3.2` string helper implementation, `.3.2.3.3` numeric
word aliases, and `.3.2.3.4` comparison symbol callees.

**Checks:** Knowledge Map regenerate/check, memory architecture, doctrine registry, mdBook build, `git diff
--check`, and full local CI passed. Local CI included phase0 passing with **1008 tests**.

## 2026-07-02 — SPEC-FORMAT-TERSE.3.2.2 — implement arithmetic symbol callees

**Scope:** Perl ActionIR method-expression parsing/lowering, slash-call disambiguation, Rust expression parsing and
runtime helper dispatch, phase0 locks, oracle corpus, mdBook, live docs, and Knowledge Map.

**What changed:** Arithmetic symbol callees are now ordinary `callee(args)` forms. `+(a,b)`, `-(a,b)`,
`*(a,b)`, `/(a,b)`, and `%(a,b)` dispatch through `num_add`, `num_sub`, `num_mul`, `num_div`, and `num_mod`
on both Perl and Rust. Nested calls such as `+(2, *(3,4))` compose through the existing numeric helper family.

**Slash boundary:** The slash symbol callee is recognized only when `/` is followed by a balanced parenthesized
argument list and a call boundary. The scanner skips quoted strings and escaped characters, and does not treat
`}` as a call boundary, so regex literals such as `/(\))/` and `/(?<!\\)}/` remain regexes.

**Checks:** Perl syntax checks, focused Perl lowering/runtime/source probes, full phase0 (1008 tests), Rust core
parser tests, the focused Rust `.3.2.2` runtime test, oracle generation, Rust corpus oracle, mdBook build,
memory/Knowledge Map/doctrine/diff checks, and full local CI passed. A broader full runtime integration run also
showed the new `.3.2.2` test passing, but still has unrelated stale short-wrapper alias tests from the earlier
`s/a/h` retirement baseline.

## 2026-07-02 — SPEC-FORMAT-TERSE.4.4 — finalize function surface ledger

**Scope:** mdBook function syntax/architecture chapters, task-tree frontier, live docs, and Knowledge Map.

**What changed:** The portable user-function MVP is now documented as closed after Perl/Rust parity. The accepted
surface is top-level `fn name(args) { ... }`, explicit parentheses for every arity including `fn name() { ... }`,
braced value-oriented bodies, exact arity, fresh function-local variable stores, final-expression or
`return(expr)` results, value-call composition, compatible receiver-chain continuation, and standalone result
discard.

**Deferred ledger:** Alternate spellings (`function ... endfunction`, `fn ... endfn`), optional zero-arg
parentheses, brace-less bodies, caller-state/parser-state/persistent side-effect functions, recursive user
functions, closures, lambdas, currying/partial application, and namespace/module features are explicitly
deferred until a future owning task-tree leaf and contract adopt them.

**Checks:** mdBook build, memory architecture, Knowledge Map regenerate/check, doctrine registry, `git diff
--check`, and full local CI passed. No parser/compiler/runtime code changed.

## 2026-07-02 — SPEC-FORMAT-TERSE.4.3.2 — execute Rust user functions

**Scope:** Rust runtime engine/context, focused Rust integration tests, oracle corpus generator/fixture, mdBook,
live docs, and Knowledge Map.

**What changed:** Rust registered user-function calls now execute as ordinary value calls. `Engine` resolves a
registered callee before the normal helper fallback, checks exact arity, evaluates arguments eagerly in the
caller context, binds parameters into fresh function-local scalar/array/hash variable stores, evaluates the
compiled `CodeBlock` body, and returns either a final expression or `return(expr)` payload.

**Composability and hardening:** Returned arrays, hashes, strings, and numbers can continue through compatible
receiver-dot value chains. Standalone registered calls execute through the same path and discard their returned
value. Function-local stores are restored after return, so params and local working variables do not leak into
the caller. Direct and mutual recursion now report deterministic unsupported-recursion diagnostics instead of recursing.

**Oracle hygiene:** The oracle generator now also uses canonical `array(...)`/`hash(...)` spellings in the older
short-wrapper-retirement cases, so a full corpus regeneration no longer rewrites unrelated fixtures.

**Checks:** `cargo fmt --all`, focused Rust runtime `terse_4_3_2`, `perl -Iperl tools/gen_oracle_corpus.pl`,
`cargo test -p linkedspec-runtime --test corpus_oracle`, `cargo test -p linkedspec-runtime --lib`, and
`cargo test -p linkedspec-core` passed. The oracle corpus now has **54 fixtures**, including
`terse_4_3_2_user_function_runtime`. The remaining memory, Knowledge Map, doctrine, mdBook, diff, and local CI
checks passed before commit.

## 2026-07-02 — SPEC-FORMAT-TERSE.4.3.1 — add Rust user function registry

**Scope:** Rust core AST/parser/compiler/validation/type model, focused Rust tests, mdBook, live docs, and
Knowledge Map.

**What changed:** Rust `.spec` parsing now extracts top-level `fn name(args) { ... }` definitions before or
between rule paragraphs into `SpecFile.functions`. Each `FunctionDefinition` records ordered params, exact arity,
original source, body source, and source/body spans. Rule parsing is preserved, and top-level function
definitions no longer get swallowed into raw rule body text.

**Compiled model and diagnostics:** Rust validation now rejects duplicate user functions, rule-label collisions,
built-in helper/control-name collisions including the landed numeric word aliases, lifecycle/runtime/function-keyword
collisions, invalid params, duplicate params, and reserved params before runtime. Compilation projects validated definitions into
`CompiledSpec.functions` as `CompiledUserFunction` records with parsed `CodeBlock` bodies and source metadata;
invalid function body code reports a compile-stage diagnostic.

**Boundary:** This is registry parity only. Rust user-function call execution, exact-arity runtime resolution,
receiver-chain continuation, standalone-result discard, and oracle fixtures remain owned by
`SPEC-FORMAT-TERSE.4.3.2`.

**Checks:** `cargo fmt --all --check`, `cargo test -p linkedspec-core`, `cargo test -p linkedspec-runtime --lib`,
`cargo test -p linkedspec-runtime --test corpus_oracle`, `mdbook build docs/linkedspec-book`, memory
architecture, Knowledge Map, doctrine registry, `git diff --check`, and `bash tools/run_ci_local.sh` passed.

## 2026-07-01 — SPEC-FORMAT-TERSE.4.2.3 — harden Perl user function discard

**Scope:** Perl ActionIR canonical event classification, value-drop lowering, user-function argument lowering,
phase0 hardening locks, mdBook, live docs, and Knowledge Map.

**What changed:** Registered standalone user-function calls and receiver chains now lower as canonical
`VALUE_DROP` events. The canonical event builder uses the compiled function registry to recognize only registered
function expressions, then the existing value-drop lowerer computes the function result and discards it with no
raw Perl fallback. Unregistered standalone calls remain explicit raw compatibility debt.

**Hardening:** Nested user-function calls now pass function-local parameter values, not bare parameter names.
Direct recursion, mutual recursion, parser-state helpers in function bodies, host-code-shaped function bodies, and
nested function syntax inside function bodies are phase0-locked as deterministic unresolved-helper diagnostics
with zero raw fallback.

**Checks:** Perl syntax checks passed for `CanonicalEvents.pm`, `Contracts.pm`, `MethodLowering.pm`,
`RuleIR/EmitContext.pm`, and `t/phase0_regression.t`. TOOLBOX descriptor/runtime probes passed for the standalone
discard and diagnostic boundaries. `prove -Iperl t/actionir_ast_parser.t` passed with **20 tests**,
`prove -Iperl t/phase0_regression.t` passed with **1007 tests**, `mdbook build docs/linkedspec-book` passed, and
memory architecture, Knowledge Map, doctrine registry, `git diff --check`, and `bash tools/run_ci_local.sh`
passed.

## 2026-07-01 — SPEC-FORMAT-TERSE.4.2.2 — execute Perl user function value calls

**Scope:** Perl compiler registry threading, RuleIR emit context dependencies, ActionIR MethodLowering,
phase0 execution locks, mdBook, live docs, and Knowledge Map.

**What changed:** Registered exact-arity user-function calls now execute on the Perl reference in value
positions. The compiler threads the extracted function registry into each rule's ActionIR lowering pass, and
MethodLowering resolves registered callees before unknown-helper fallback. Generated calls evaluate arguments
eagerly in the caller context, bind positional parameters in a fresh function-local scope, evaluate the function
body AST as a value-producing `do { ... }` expression, and return either a final expression or a function-local
`return(expr)` payload.

**Composability:** Phase0 now locks calls in `return(...)`, assignment RHS, array append RHS, hash mutation
value, helper arguments, final-expression bodies, non-final function-local `return(expr)`, compatible
receiver-dot chains from returned values, and local/caller shadowing. Wrong-arity registered calls remain
unresolved-helper diagnostics with zero raw fallback.

**Boundary:** Standalone user-function call result discard, recursion rejection, hard purity diagnostics,
unsupported function-body side-effect diagnostics, and Rust parity remain follow-on leaves (`.4.2.3` and `.4.3`).

## 2026-07-01 — SPEC-FORMAT-TERSE.4.2.1 — add Perl user function registry

**Scope:** `specs/spec.spec`, Perl compiler/compiled-state descriptors, new
`LinkedSpec::UserFunctionRegistry`, phase0 descriptor diagnostics, mdBook, live docs, and Knowledge Map.

**What changed:** Landed the first Perl reference implementation seam for user-defined functions. The
self-hosted grammar now has an active `function_definition` part for top-level `fn name(args) { body }`, while
the Perl reference uses a temporary pre-bootstrap registry bridge until the self-hosted function part can be the
primary parse source. The bridge extracts top-level function definitions, strips them from the source passed to
ordinary rule validation/bootstrap while preserving line numbers, parses function bodies through the ActionIR AST
block parser, and attaches the registry to compiled state and public descriptors.

**Descriptor shape:** Public descriptors now carry `functions => { name => definition }` plus
`meta.function_order` and `meta.function_count`. Each definition records `name`, ordered `params`, `arity`,
`source_span`, `body_span`, `body_source`, and `body_ast`. The registry rejects duplicate functions, invalid or
duplicate parameters, reserved runtime/lifecycle/function symbols, built-in helper/control-name collisions, and
rule-label collisions before runtime.

**Boundary:** This leaf does **not** execute user-function calls. Registered calls in value positions still use
the unresolved-helper diagnostic path and keep `language_agnostic_action_ir_ready` false until `.4.2.2` adds the
value-call evaluator. Standalone call discard and purity hardening remain `.4.2.3`.

**Checks:** Perl syntax checks passed for the new registry, compiler state, compiler pipeline, and phase0 test
file. Focused descriptor probes passed for successful registry projection and duplicate/built-in/rule/parameter
diagnostics. `specs/spec.spec` still compiles with `language_agnostic_ready_ratio == 1.0000`.
`prove -Iperl t/actionir_ast_parser.t` passed with **20 tests**. `mdbook build docs/linkedspec-book`,
memory architecture, Knowledge Map, doctrine registry, `git diff --check`, and `bash tools/run_ci_local.sh`
passed; the full local CI gate included phase0 **1005 tests**.

## 2026-07-01 — SPEC-FORMAT-TERSE.4.1 — lock user function contract

**Scope:** Task tree, roadmap/index, live docs, mdBook status, Knowledge Map, and focused TOOLBOX/source
inventory. No parser/compiler/runtime code changed.

**What changed:** Locked the exact user-defined function MVP before implementation. The accepted surface is
top-level `fn name(args) { ... }` with exact arity, eager argument evaluation, fresh function-local
parameter/work-variable scope, pure value/block bodies, final-expression or `return(expr)` result, receiver-chain
composition from returned values, and silent discard for standalone call statements. The MVP excludes implicit
caller capture, recursion, closures, lambdas, currying, host-code escape, parser-state helpers, and side-effect
helpers.

**Inventory result:** `specs/spec.spec` remains the permanent grammar owner but has no active
`function_definition` rule yet. The bootstrap parser has no first-class `fn` node support. Perl ActionIR already
parses `user_fn(...)` and `user_fn(...).trim()` as typed call/fluent-chain nodes; value slots now diagnose those
unknown calls through unresolved-helper metadata, while standalone unknown calls remain raw until the registry
owns discard semantics. Rust already parses call/fluent expression shapes, but unknown callees fall through
`Engine::call_helper` to warning+`undef`, so Rust needs a registry path before helper fallback.

**Split:** `.4.2` is now a Perl reference container split into function-definition grammar/registry (`.4.2.1`),
value-call execution (`.4.2.2`), and standalone-discard/purity hardening (`.4.2.3`). `.4.3` is split into Rust
registry parity (`.4.3.1`) and runtime/oracle parity (`.4.3.2`). Frontier becomes `.4.2.1`.

**Checks:** Focused TOOLBOX probes, source/book inventory, Knowledge Map regenerate/check, memory architecture,
doctrine registry, `mdbook build docs/linkedspec-book`, `git diff --check`, and `bash tools/run_ci_local.sh`
passed. The full local CI gate included phase0 **1004 tests**.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.5.4 — lock fn grammar ownership

**Scope:** `specs/spec.spec`, phase0 self-hosting regression locks, task tree, live docs, mdBook status, and
Knowledge Map.

**What changed:** Locked the user-function definition ownership boundary before `SPEC-FORMAT-TERSE.4.1` starts.
`specs/spec.spec` now documents that permanent `fn name(args) { ... }` grammar belongs to the self-hosted grammar,
not to a lasting hardcoded bootstrap parser extension.

**Proof lock:** Phase0 now asserts that `BootstrapSpec.pm` and `BootstrapSpec/Core.pm` have no
`fn name(...)` grammar support or named function-definition node support. The bootstrap scanner may still return
generic paragraph structure for `fn`-shaped text, but the result does not contain a structured function-definition
node or function payload.

**Checks:** `perl -Iperl -c t/phase0_regression.t`, direct bootstrap parse probe, targeted source `rg`, and
`prove -Iperl t/phase0_regression.t` passed with phase0 **1004 tests**. `mdbook build docs/linkedspec-book`,
memory architecture, Knowledge Map, doctrine registry, `git diff --check`, and `bash tools/run_ci_local.sh`
passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.5.3.2 — diagnose unknown AST calls in value positions

**Scope:** Perl ActionIR `MethodLowering`, focused AST parser tests, task tree, live docs, mdBook status, and
Knowledge Map.

**What changed:** Unknown typed `call` / `fluent_chain` nodes in value-return positions now emit the existing
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` diagnostic sentinel instead of leaking as generated host-language
calls. This closes the concrete handoff risk from `.5.1`: `return(user_fn("x"))` and
`return(user_fn("x").trim())` no longer compile to host `user_fn(...)` calls and descriptor metadata reports the
unresolved helper.

**Compatibility boundary:** Standalone unknown function-shaped statements such as `user_fn("x")` still remain
raw until the function registry owns standalone result discard. Existing DSL and compatibility helper names are
explicitly fenced as known so unsupported value-chain surfaces such as `return(items.push_back("a"))`, retired
return helpers, declaration aliases, source-boundary helpers, and internal trace calls do not get misclassified as
future user functions.

**Checks:** Syntax checks passed for `MethodLowering`, scanner pipeline rules, contracts, and
`t/actionir_ast_parser.t`. Focused probes covered return-position unknown calls, supported `call(...)` and
`input_text()` payloads, flow helper composition, declaration aliases, and unsupported array mutation value
chains. `prove -Iperl t/actionir_ast_parser.t` passed with **20 subtests**. `prove -Iperl t/phase0_regression.t`
passed with phase0 **1003 tests**. `mdbook build docs/linkedspec-book`, memory architecture, Knowledge Map,
doctrine registry, `git diff --check`, and `bash tools/run_ci_local.sh` passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.5.3.1 — retire short wrapper aliases

**Scope:** Perl ActionIR lowering, scanner/contract metadata, shipped specs/corpus fixtures, phase0 locks,
Rust core/runtime parity paths, root guides, mdBook, task tree, live docs, and Knowledge Map.

**What changed:** Retired `s(...)`, `a(...)`, and `h(...)` as canonical wrapper spellings. Repo-owned specs,
fixtures, tests, and docs now use `scalar(...)`, `array(...)`, and `hash(...)`. Perl lowering no longer
normalizes the short names into long wrappers; retired short calls now become
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:*` diagnostics and keep `raw_perl_dependency_count == 0`.

**Backend/docs sync:** Rust core parser examples and runtime helper dispatch now use canonical wrapper names
only. The mdBook and root guides teach canonical wrappers and list the short spellings only as retired aliases.

**Checks:** Residual shorthand scan over repo-owned specs/corpora was clean. Syntax checks passed for touched
ActionIR modules and tests. `prove -Iperl t/actionir_ast_parser.t` passed. `prove -Iperl t/phase0_regression.t`
passed with phase0 **1003 tests**. `cargo test --manifest-path rust/Cargo.toml -p linkedspec-core --lib` passed
with **140 tests**. `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --lib` passed with **117
tests**. `mdbook build docs/linkedspec-book`, memory architecture, Knowledge Map, doctrine registry,
`git diff --check`, and `bash tools/run_ci_local.sh` passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.5.3 — split short alias retirement

**Scope:** Task tree, live continuity docs, roadmap/index status, and Knowledge Map. No parser/compiler/runtime
code changed.

**What changed:** Captured the user decision that `s(...)`, `a(...)`, and `h(...)` are retirement targets too.
The former `.5.3` user-function handoff leaf is now split so shorthand wrapper alias retirement runs first as
`.5.3.1`, followed by user-function AST call handoff as `.5.3.2`.

**Read-only discovery:** `rg` found active shorthand use in shipped specs, phase0 regression locks, mdBook
examples, task-tree history, and Knowledge Map facts. This confirms the retirement needs an owned migration
slice rather than an untracked cleanup.

**Checks:** Memory architecture, Knowledge Map, doctrine registry, and `git diff --check` passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.5.2 — lower dropped value statements

**Scope:** Perl ActionIR lowering, scanner/canonical metadata, focused AST parser tests, task tree, live docs,
mdBook status, and Knowledge Map.

**What changed:** Supported standalone value statements that already parse into typed ActionIR AST value nodes now
lower as discarded values through a new `VALUE_DROP` contract. Examples such as `trim(" x ")`, `concat("a","b")`,
and `" x ".trim()` no longer remain raw host-call text; they lower through the existing value-expression
dispatcher and then discard the result with `undef`.

**Compatibility boundary:** Malformed covered standalone helpers still become
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:*` diagnostics with zero raw fallback. `call_spec_handler_subst` continues
to preserve bare `s(...)`, `a(...)`, and `h(...)` compatibility value expressions as expressions, not dropped
statements. Unknown user-function-shaped standalone calls/chains remain raw and are left to `.5.3`.

**Checks:** Syntax checks passed for touched ActionIR modules, `perl/LinkedSpec.pm`, and
`t/actionir_ast_parser.t`. The focused AST suite passed with **20 subtests**. `prove -q -Iperl
t/phase0_regression.t` passed with phase0 **1002 tests**. `mdbook build docs/linkedspec-book`, memory
architecture, Knowledge Map, doctrine registry, `git diff --check`, and `bash tools/run_ci_local.sh` all passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.5.1 — audit fallback boundary

**Scope:** Perl ActionIR migration audit, task tree, live docs, mdBook status, and Knowledge Map. No
parser/compiler/runtime code changed.

**What changed:** Classified the remaining fallback boundary after the Perl ActionIR value, statement, block,
and structured-control AST migrations. The audit used `call_spec_handler_subst`, descriptor metadata, AST parser
probes, and code reads before code.

**Findings:** Malformed AST-covered helpers already emit unresolved-helper metadata without raw fallback.
Retired helpers and non-DSL host-shaped statements remain explicit compatibility debt. Narrow return payload
compatibility remains fenced. All-bare `push(A,B)` remains the existing child-call ambiguity contract.
At `.5.1`, unknown typed calls/chains such as `return(user_fn("x"))` and
`return(user_fn("x").trim())` were the user-function handoff risk because they lowered as generated host calls
and reported ready; `.5.3.2` has since resolved value-position cases through user-function diagnostics. Targeted
`rg` found no current `fn <name>(...) { ... }` grammar in bootstrap or
`specs/spec.spec`; `.5.4` still owns the permanent grammar/proof lock.

**Checks:** TOOLBOX probes and code reads completed. `mdbook build docs/linkedspec-book`, memory architecture,
Knowledge Map, doctrine registry, `git diff --check`, and `bash tools/run_ci_local.sh` all passed; the local CI
gate included the focused ActionIR AST parser suite and phase0 **1002 tests**.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.5 — split fallback retirement and function handoff

**Scope:** Perl ActionIR migration task tree, live continuity docs, and split planning. No parser/compiler/runtime
code changed.

**What changed:** Split the broad fallback-retirement/function-handoff parent into focused children:
`.5.1` fallback-boundary audit, `.5.2` AST-covered supported-surface fallback leakage retirement, `.5.3`
user-function AST call handoff, and `.5.4` `specs/spec.spec` function grammar plus bootstrap-parser retirement
lock.

**Reason:** The remaining migration work combines compatibility fallback classification, diagnostics policy, and
the user-function handoff. Splitting keeps the next code slices narrow and preserves the doctrine that lasting
`fn <name>(...) { ... }` grammar belongs in `specs/spec.spec`, not the bootstrap parser.

**Checks:** `mdbook build docs/linkedspec-book`, memory/doctrine/Knowledge Map gates, and `git diff --check`
passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.4.4.4 — lower while controls from AST

**Scope:** Perl ActionIR control-flow lowering, focused AST parser/lowering tests, task-tree/roadmap/live docs,
mdBook architecture status, and Knowledge Map.

**What changed:** `LinkedSpec::ActionIR::ControlFlow` now parses attached `while(cond) { ... }` statements
through the ActionIR AST parser before entering the existing while lowerer. The bridge materializes trusted loop
conditions and attached body statements from typed `control_while` fields instead of reusing original statement
text or AST `source` strings.

**Compatibility boundary:** Generated Perl loop shape, condition re-evaluation, attached-body lowering, and the
deterministic 10000-iteration safety guard remain unchanged. Bodyless `while(...)` marker nodes remain parser
shape only because the current DSL has no `endwhile` product syntax.

**Tests:** Syntax checks passed for `ActionIR::ControlFlow` and the focused parser test. `prove -v -Iperl
t/actionir_ast_parser.t` passed with 19 focused subtests, including fake-source locks for attached while
condition/body lowering and guard preservation. `perl -c perl/LinkedSpec.pm`,
`perl -c -Iperl t/phase0_regression.t`, and `prove -q -Iperl t/phase0_regression.t` passed; phase0 covered
1002 tests. `mdbook build docs/linkedspec-book`, memory/doctrine/Knowledge Map gates, `git diff --check`, and
`bash tools/run_ci_local.sh` also passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.4.4.3 — lower switch-family controls from AST

**Scope:** Perl ActionIR control-flow lowering, focused AST parser/lowering tests, task-tree/roadmap/live docs,
mdBook architecture status, and Knowledge Map.

**What changed:** `LinkedSpec::ActionIR::ControlFlow` now parses `switch`, `case`, `default`, `endcase`, and
`endswitch` statements through the ActionIR AST parser before entering the existing switch stack lowerers. The
bridge materializes trusted switch source expressions, case match values, attached case/default bodies, parsed
switch branch lists, and end markers from typed AST fields instead of reusing original statement text or AST
`source` strings.

**Compatibility boundary:** The generated Perl switch shape and existing switch-value single evaluation,
case-order, `default` once-only, attached-switch body, and marker `endcase`/`endswitch` behavior remain
unchanged. `while` structured-control lowering remains queued for `.4.4.4`.

**Tests:** Syntax checks passed for `ActionIR::ControlFlow` and the focused parser test. `prove -v -Iperl
t/actionir_ast_parser.t` passed with 18 focused subtests, including fake-source locks for attached
switch/case/default and marker switch/case/endcase/default/endswitch. `perl -c perl/LinkedSpec.pm`,
`perl -c -Iperl t/phase0_regression.t`, and `prove -q -Iperl t/phase0_regression.t` passed; phase0 covered
1002 tests. `mdbook build docs/linkedspec-book`, memory/doctrine/Knowledge Map gates, `git diff --check`, and
`bash tools/run_ci_local.sh` also passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.4.4.2 — lower if-family controls from AST

**Scope:** Perl ActionIR control-flow lowering, focused AST parser/lowering tests, task-tree/roadmap/live docs,
mdBook architecture status, and Knowledge Map.

**What changed:** `LinkedSpec::ActionIR::ControlFlow` now parses `if`/`i`/`when`, `elseif`/`elif`,
`else`/`otherwise`, and `endif` statements through the ActionIR AST parser before entering the existing branch
lowering engine. The bridge materializes trusted control statements from typed condition and body nodes instead
of reusing original statement text or AST `source` strings.

**Compatibility boundary:** The generated Perl branch shape and existing attached-block, marker-style,
implicit-close, and when/otherwise alias behavior remain unchanged. `switch`/`case`/`default` and `while`
structured-control lowering remain queued for `.4.4.3` and `.4.4.4`.

**Tests:** Syntax checks passed for `ActionIR::ControlFlow` and the focused parser test. `prove -v -Iperl
t/actionir_ast_parser.t` passed with 17 focused subtests, including fake-source locks for attached
if/elseif/else, when/otherwise, and marker if/elseif/else/endif. `perl -c perl/LinkedSpec.pm`,
`perl -c -Iperl t/phase0_regression.t`, and `prove -q -Iperl t/phase0_regression.t` passed; phase0 covered
1002 tests. `mdbook build docs/linkedspec-book`, memory/doctrine/Knowledge Map gates, `git diff --check`, and
`bash tools/run_ci_local.sh` also passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.4.4.1 — parse structured control nodes into AST

**Scope:** Perl ActionIR AST parser, focused parser tests, task-tree/roadmap/live docs, mdBook architecture
status, and Knowledge Map. Production lowering remains unchanged in this leaf.

**What changed:** `LinkedSpec::ActionIR::AST::Parser` now parses attached-block and marker structured-control
forms into typed control nodes: `control_if`, `control_else`, `control_endif`, `control_while`,
`control_switch`, `control_case`, `control_default`, `control_endcase`, and `control_endswitch`. The nodes
carry parsed condition/source/match expressions, canonical/source keywords, attached body blocks, body source
spans, and parsed switch case/default branches where applicable.

**Compatibility boundary:** Inline value-form `if(cond, then, else)` and
`switch(value, case(...), default(...))` still parse as generic `call` nodes. This keeps the existing inline
value-control lowering path untouched while later `.4.4` children migrate statement-level control lowering.

**Tests:** Syntax checks passed for `AST::Parser` and the focused parser test. Focused locks cover attached
forms, bare and parenthesized marker controls, and inline value-helper boundaries. `prove -v -Iperl
t/actionir_ast_parser.t` passed with 16 focused subtests. `perl -c perl/LinkedSpec.pm`,
`perl -c -Iperl t/phase0_regression.t`, and direct `perl -Iperl t/phase0_regression.t` passed; phase0 covered
1002 tests. `mdbook build docs/linkedspec-book`, memory/doctrine/Knowledge Map gates, `git diff --check`, and
`bash tools/run_ci_local.sh` also passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.4.4 — split structured-control AST lowering

**Scope:** Task-tree split, roadmap/task index, and live continuity docs. No parser/compiler/runtime code
changed.

**What changed:** Split structured control-flow AST lowering into focused children before code: `.4.4.1`
control-flow AST parser nodes and node-shape locks, `.4.4.2` `if`/`when`/`otherwise` lowering from AST,
`.4.4.3` `switch`/`case`/`default` lowering from AST, and `.4.4.4` `while` lowering from AST with existing
iteration-safety behavior preserved.

**Reason:** Structured control lowering combines parser support for attached blocks and marker forms, branch
body lowering, switch state, and while safety. Splitting keeps each executable leaf narrow and testable.

**Checks:** Memory/doctrine/Knowledge Map gates and `git diff --check` passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.4.3 — lower block values from AST statements

**Scope:** Perl ActionIR block-value lowering, focused AST parser/lowering tests, mdBook architecture text,
Knowledge Map, task tree, and live docs.

**What changed:** `MethodLowering` now routes parsed `block_value` nodes into the AST value path before the
legacy block splitter. Inside AST block values, non-final side-effect statements lower from typed
`action_stmt.expr` nodes, block-local `return(...)` payloads lower from typed call arguments, and final block
expressions lower from typed statement expressions.

**Compatibility boundary:** Legacy text splitting remains as fallback for compatibility payloads the AST path
cannot materialize. Existing guarded early-return output, final-return behavior, hash-shape precedence, and
source-slot scalar reads stay stable.

**Tests:** Added focused fake-source coverage for expression-valued blocks with side effects, block-local
early return, post-return guarded side effects, and final expressions. Syntax checks passed;
`prove -q -Iperl t/actionir_ast_parser.t` passed with 15 focused subtests; `prove -q -Iperl
t/phase0_regression.t` passed with 1002 tests. `mdbook build docs/linkedspec-book`,
memory/doctrine/Knowledge Map gates, `git diff --check`, and `bash tools/run_ci_local.sh` also passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.4.2 — lower statement calls from AST

**Scope:** Perl ActionIR statement lowering, focused AST parser/lowering tests, scanner diagnostics,
mdBook architecture text, Knowledge Map, task tree, and live docs.

**What changed:** `MethodLowering` now consumes AST `call` nodes for statement-form `return`,
`return_undef`, `set_key`, `push`, `push_value`, and `push_nonempty`, and AST `fluent_chain` nodes for array
end-mutation statements. `DeclareMethod` uses the same typed AST bridge for top-level `set`/`assign`.

**Compatibility boundary:** Typed statements materialize supported call arguments from AST fields, then enter
the existing statement helper catalog so symbol slots, raw `push_value` value slots, mutation scalar reads,
return payload lowering, and narrow raw compatibility fallback stay byte-compatible.

**Tests:** Added focused fake-source coverage for `set`, `set_key`, `push_value`, `push`, `push_nonempty`,
`return`, `return_undef`, and `items.push_back(...)`, plus a sentinel lock for unsupported
`push_nonempty(...)`. Syntax checks and `prove -v -Iperl t/actionir_ast_parser.t` passed; `prove -q -Iperl
t/phase0_regression.t` passed with 1002 tests. `mdbook build docs/linkedspec-book`,
memory/doctrine/Knowledge Map gates, `git diff --check`, and `bash tools/run_ci_local.sh` also passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.4.1 — lower statement operators from AST

**Scope:** Perl ActionIR method/statement lowering, focused AST parser/lowering tests, mdBook architecture text,
Knowledge Map, task tree, and live docs.

**What changed:** `MethodLowering` now consumes AST `assign_scalar`, `assign_array_append`, and
`assign_hash_index` nodes before the legacy statement-regex paths. The new path reconstructs trusted
helper/action expression text from typed AST fields, then enters the existing assignment/mutation policies so
output stays byte-compatible.

**Compatibility boundary:** Existing scalar assignment target-kind inference, array append mutation value-slot
reads, hash key/value lowering, direct shape-literal assignment, and source-slot scalar reads stay unchanged.
Helper-call statements, block-value side effects, and structured control flow remain queued for later `.4`
children.

**Tests:** Added focused fake-source coverage proving `name = [poison]`, `items += poison`, and
`meta[poison_key] = { poison_key => poison_value }` lower from typed AST target/key/value fields rather than
original source text or poisoned AST `source` fields. Syntax checks and `prove -v -Iperl t/actionir_ast_parser.t`
passed; `prove -q -Iperl t/phase0_regression.t` also passed with 1002 tests. `mdbook build
docs/linkedspec-book`, memory/doctrine/Knowledge Map gates, `git diff --check`, and `bash
tools/run_ci_local.sh` also passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.4 — split AST statement lowering

**Scope:** Task-tree split, roadmap/task index, live continuity docs. No parser/compiler/runtime code changed.

**What changed:** Split the broad statement/control AST migration parent into focused child leaves before code:
`.4.1` assignment/mutation operator statement nodes, `.4.2` helper-call statements and returns, `.4.3`
block-value side-effect traversal and block-local returns, and `.4.4` structured control-flow forms.

**Reason:** Statement/control lowering mixes already-parsed operator nodes, helper-call statements with
slot-sensitive argument policies, block-local return behavior, and control forms that may require new typed AST
nodes. Splitting keeps the next executable leaf narrow and testable.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.3.4 — lower return payloads from AST

**Scope:** Perl ActionIR method/return lowering, focused AST parser/lowering tests, mdBook architecture text,
Knowledge Map, task tree, and live docs.

**What changed:** `MethodLowering::_lower_return_payload_expr(...)` now parses generalized return payloads
through `LinkedSpec::ActionIR::AST` and accepts AST-lowered typed payloads before the legacy helper-substitution
loop. Direct shapes, nested helper calls, direct/nested access, block values, receiver chains, primitive
literals, and bare scalar reads now share the same typed value traversal used by `_lower_method_value_expr(...)`.

**Compatibility boundary:** Raw fallback remains only for untyped compatibility payloads, including shipped
surfaces such as `\(my $capt = capture_slice())`. AST `variable` payloads deliberately continue through the
scalar source-slot read path, so `return(count)` lowers to `return $count` rather than leaking a raw identifier.
Unsupported covered helper chains inside return payloads keep the existing unresolved-helper sentinel instead of
turning into generated host calls.

**Tests:** Added focused fake-source coverage for typed return payloads, unsupported covered chain diagnostics,
bare variable return payloads, and the raw compatibility fallback. Syntax checks,
`prove -v -Iperl t/actionir_ast_parser.t`, `prove -q -Iperl t/phase0_regression.t`, `mdbook build
docs/linkedspec-book`, memory/doctrine/Knowledge Map gates, `git diff --check`, and
`bash tools/run_ci_local.sh` passed; phase0 covered 1002 tests.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.3.3 — lower receiver chains from AST

**Scope:** Perl ActionIR method/value lowering, focused AST parser/lowering tests, mdBook architecture text,
Knowledge Map, and live docs.

**What changed:** `MethodLowering::_lower_method_value_expr(...)` now dispatches AST `fluent_chain` nodes for
receiver-dot value chains before the legacy receiver-dot text normalizers. The dispatcher traverses typed
receiver/call/argument nodes for array, hash, string, and number receiver families, then reuses the existing
Perl helper catalog through the compatibility bridge so generated output stays stable.

**Compatibility boundary:** The AST path preserves the existing receiver-family contracts: bare scalar/hash
receiver wrapping, block-valued receivers, array pipeline helper names, string/hash bridges into array
terminals, `join_values` delimiter-first mapping, numeric method arity checks, and numeric terminal
continuation behavior. Old receiver-dot text normalizers remain only as fallback for expressions the AST parser
cannot own yet.

**Tests:** Added focused fake-source coverage proving number chains, string-to-array chains, block-array
receivers, hash-to-array chains, invalid numeric terminal continuations, and unsupported covered chain helpers
consume AST node fields instead of poisoned source text. Syntax checks, `prove -v -Iperl t/actionir_ast_parser.t`,
and targeted public lowering probes passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.3.2.3 — diagnose unsupported AST helper calls

**Scope:** Perl ActionIR method/value lowering, unresolved-helper diagnostics, focused AST parser/lowering
tests, mdBook architecture text, Knowledge Map, and live docs.

**What changed:** Helper families already covered by the `.3.2.1` and `.3.2.2` AST call dispatchers no longer
fall through as generated Perl host calls when the specific AST form cannot be lowered. `MethodLowering` now
emits a harmless `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` sentinel expression for known covered helper
calls that fail arity or AST argument materialization, while unknown calls stay reserved for future
user-function handling.

**Diagnostics:** `ActionIR::Diagnostics::_find_unresolved_action_helpers(...)` now scans the sentinel into the
existing unresolved-helper metadata. Descriptors report `unresolved_helper_count`, `unresolved_helpers`, and a
not-language-agnostic-ready rule without incrementing `raw_perl_dependency_count`. This retires the silent
host-call leakage path for malformed covered helper calls.

**Tests:** Added focused coverage for malformed value-only helpers, malformed aggregate helpers, nested
malformed helpers inside a valid covered helper, and descriptor telemetry. Syntax checks,
`prove -v -Iperl t/actionir_ast_parser.t`, targeted public lowering probes, and
`prove -q -Iperl t/phase0_regression.t` passed; phase0 covered 1002 tests. `mdbook build
docs/linkedspec-book`, memory/doctrine/Knowledge Map gates, `git diff --check`, and
`bash tools/run_ci_local.sh` also passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.3.2.2 — lower aggregate helper calls from AST

**Scope:** Perl ActionIR method/value lowering, focused AST parser/lowering tests, mdBook architecture text,
Knowledge Map, and live docs.

**What changed:** `MethodLowering::_lower_method_value_expr(...)` now dispatches aggregate-wrapper,
collection, reducer, and hash helper families from AST `call` nodes before the legacy text cascade. Covered
calls reconstruct helper surfaces from typed AST argument nodes, normalize aliases (`s`/`a`/`h`, numeric word
aliases), and reuse the existing Perl helper catalog through the explicit compatibility bridge.

**Compatibility boundary:** Deprecated wrappers (`scalar(...)`, `array(...)`, `hash(...)`) remain accepted
compatibility aliases per ADR 0007, not canonical destination syntax. The AST dispatcher preserves aggregate
symbol slots and quoted-wrapper literal boundaries, so `array(items)` keeps reading `@items` while
`array("items")` stays a literal constructor payload. Covered-call diagnostics landed in `.3.2.3`; receiver-dot
chains are now covered by `.3.3`.

**Tests:** Added focused fake-source AST tests for wrappers, copy helpers, reducers, collection helpers, and hash
helpers. Syntax checks, `prove -Iperl t/actionir_ast_parser.t`, targeted public lowering probes,
`mdbook build docs/linkedspec-book`, and `bash tools/run_ci_local.sh` passed; phase0 covered 1002 tests.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.3.2.1 — lower value-only helper calls from AST

**Scope:** Perl ActionIR method/value lowering, focused AST parser/lowering tests, mdBook architecture text,
Knowledge Map, and live docs.

**What changed:** `MethodLowering::_lower_method_value_expr(...)` now dispatches supported AST `call` nodes
for value-only helper families. The dispatcher recursively lowers argument AST nodes, preserves existing
bare-variable behavior in helper-call slots, canonicalizes numeric word aliases, and then reuses the existing
Perl helper catalog through the explicit compatibility bridge.

**Compatibility boundary:** At this `.3.2.1` leaf, deprecated wrapper aliases such as
`scalar(...)`/`array(...)`/`hash(...)`, aggregate-wrapper, collection, reducer, hash, symbol-slot, and
receiver-chain helpers stayed on explicit compatibility paths for `.3.2.2`/`.3.3`; those wrappers are not the
canonical destination syntax. This leaf did not change public helper output.

**Tests:** Added focused fake-source AST call tests proving covered helper calls do not reuse call-node source
text. Syntax checks, `prove -Iperl t/actionir_ast_parser.t`, and targeted public lowering probes passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.3.2 — split AST helper-call lowering

**Scope:** Task-tree split, roadmap/live continuity docs, and current frontier update. No parser/compiler/runtime
code changed.

**What changed:** Converted `.3.2` into a parent contract with three child leaves: `.3.2.1` value-only helper
families, `.3.2.2` aggregate wrappers plus collection/hash helpers with explicit symbol/value slot policy, and
`.3.2.3` diagnostics for covered helper-call AST forms that would otherwise leak as generated host-language
calls.

**Reason:** Helper calls mix ordinary value-expression arguments with symbol, aggregate, delimiter, tag, and
path slots. Splitting by argument-slot risk keeps the AST call migration behavior-preserving.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.3.1 — lower non-call values from AST

**Scope:** Perl ActionIR method/value lowering, focused AST parser/lowering tests, mdBook architecture text,
Knowledge Map, and live docs.

**What changed:** `LinkedSpec::ActionIR::MethodLowering::_lower_method_value_expr(...)` now parses through
`LinkedSpec::ActionIR::AST` before the legacy text cascade and dispatches non-call value nodes directly:
primitive literals, scoped bare scalar reads, direct indexed/nested access, array/hash shape literals, and
block values.

**Compatibility boundary:** Helper-call value composition and receiver-dot chains remain on the existing
compatibility path for later `.3` children. Nested helper calls inside AST-lowered shapes/blocks use an explicit
compatibility bridge. The direct-access lowering preserves legacy reserved-segment behavior, so `true` and
engine locals such as `CAPTURE` do not get rewritten as path indexes.

**Tests:** Added focused test coverage proving AST parser use for non-call value lowering while preserving the
existing generated Perl output. `prove -Iperl t/actionir_ast_parser.t` and
`prove -q -Iperl t/phase0_regression.t` (1002 tests) passed.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.3 — split AST value lowering

**Scope:** Task-tree split, roadmap/live continuity docs, and current frontier update. No parser/compiler/runtime
code changed.

**What changed:** Converted broad `.3` into a parent contract with four child leaves: `.3.1` non-call value AST
dispatcher, `.3.2` AST helper-call composition, `.3.3` AST receiver-dot value chains, and `.3.4` AST
return-payload traversal plus diagnostics.

**Reason:** Value expressions, helper composition, receiver chains, and return-payload helper substitution are
different lowering mechanisms. Splitting them before code keeps the Perl text-to-AST migration signoff-sized
and keeps user-defined functions blocked until calls are carried by typed AST nodes.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.2 — add Perl ActionIR AST parser seam

**Scope:** Perl ActionIR parser modules, focused parser tests, mdBook architecture/status text, Knowledge Map,
and live docs. Existing ActionIR lowering behavior remains unchanged.

**What changed:** Added `LinkedSpec::ActionIR::AST` and `LinkedSpec::ActionIR::AST::Parser` as an additive
typed parser seam behind the current `RewritePipeline`. The parser returns structured hash nodes with `kind`,
`source`, and `source_span` fields and covers action blocks/statements, calls, receiver chains, variables,
indexed and nested direct access, shape literals, block values, primitive literals, scalar/array/hash
assignment nodes, and temporary `raw_perl` fallback nodes.

**Semantics:** `ActionStmt` records `drops_value => 1`, so standalone expression statements, including future
user-function calls, silently discard their value. Function calls can be the receiver of a `fluent_chain`.

**Tests:** Added `t/actionir_ast_parser.t` covering the parser seam and guarding that current ActionIR lowering
remains authoritative until `.3` switches value/receiver consumers to AST.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.1 — inventory Perl ActionIR text lowering

**Scope:** Task-tree inventory, roadmap/live continuity docs, Knowledge Map fact card, and migration order.
No parser/compiler/runtime code changed.

**What changed:** The current Perl text-to-text ActionIR path is now mapped before implementation. The raw
boundaries are `StatementSplit`/`StatementSplit::Core`, `MethodExpr`, scanner rule families, contract
lowering callbacks, canonical `RAW_PERL` fallback, source-span replacement in `RewritePipeline`,
recursive method/value/receiver lowering in `MethodLowering`, and the `RuleIR::EmitContext` bridge.

**AST model:** The Perl parser seam will align with Rust's typed expression model: `ActionBlock`,
`ActionStmt`, `Call`, `FluentChain`/`ReceiverChain`, typed value/literal/access nodes, assignment and mutation
nodes, and control/printing/return nodes with source spans. A standalone function or helper call is an
expression statement whose value is silently dropped.

**Migration order:** `.2` introduces the parser seam behind existing behavior; `.3` moves value-expression and
receiver-chain lowering to AST; `.4` moves statements/control; `.5` retires supported-surface raw fallback and
unblocks user-defined functions on AST calls.

## 2026-07-01 — PERL-ACTIONIR-AST-MIGRATION.0 — adopt text-to-AST doctrine

**Scope:** ADR, task-tree ownership, mdBook, Knowledge Map, and live docs. No parser/compiler/runtime code
changed.

**What changed:** Text-to-AST is now an accepted cross-variant doctrine. Every backend must parse helper/action
language into typed AST/IR before lowering, interpretation, or code emission. Text-to-text lowering is legacy
migration debt, not an acceptable architecture for new supported surfaces.

**Perl impact:** The Perl reference backend must migrate away from ActionIR source-text lowering in careful
slices. The first executable leaves inventory the current lowering sites, introduce an AST parser seam behind
existing behavior, then replace value/receiver and statement/control lowering families under regression locks.

**Book impact:** The variant-neutral mdBook now states the AST requirement in the backend handoff, compiler
pipeline, formal grammar, and architecture chapters. User-defined functions must consume this AST path rather
than adding textual macro expansion.

## 2026-07-01 — SPEC-FORMAT-TERSE.4 — own user-defined function surface

**Scope:** Task-tree ownership, roadmap/live continuity docs, and active-frontier redirection. No
parser/compiler/runtime code changed.

**What changed:** User-defined `.spec` functions are now an active Round 4 surface under
`SPEC-FORMAT-TERSE.4`. The MVP is intentionally narrow: top-level `fn name(args) { ... }`, explicit
parentheses for every arity, explicit positional parameters, pure value/block bodies, and no recursion,
closures, lambdas, currying, or implicit caller-state capture in the first implementation.

**Contract:** A user-function call is an ordinary value expression. It may feed helper arguments,
assignments, returns, array/hash mutations, and receiver-dot value chains by the value it yields. A
standalone function call silently drops its return value.

**Validation:** Docs-only ownership split; `scripts/check_memory_architecture.sh`,
`knowledge-map/scripts/check_knowledge_map.sh`, `scripts/check_doctrines.sh`, `git diff --check`, and a
targeted stale-frontier search all passed.

## 2026-07-01 — SPEC-FORMAT-TERSE.3.2.1 — implement numeric word aliases

**Scope:** Perl ActionIR value lowering, Rust runtime helper dispatch, oracle corpus, focused Perl/Rust locks,
mdBook helper/formal docs, task-tree/live docs, and Knowledge Map update.

**What changed:** Non-comparison function-form numeric aliases now map to the existing `num_*` helper family on
Perl and Rust: `add`, `sub`, `mul`, `div`, `mod`, `abs`, `floor`, `ceil`, `round`, `min`, `max`, `clamp`,
`sum`, `avg`, `median`, and `range`. Existing `num_*` spellings remain accepted.

**Boundary:** The leaf deliberately does not add arithmetic symbol callees such as `+(a,b)`, and it does not
change bare comparison words. `gt(10, 2)` remains the existing string comparison helper; numeric comparisons
remain `num_gt(...)` or receiver-dot terminals such as `score.gt(3)`.

**Validation:** Perl syntax checks passed; focused lowering/runtime probes passed; the full phase0 suite passed
with 1002 subtests; the Rust focused integration test passed; oracle generation produced 53 fixtures; Rust
`corpus_oracle` passed over all 53 fixtures; `mdbook build docs/linkedspec-book` passed.

## 2026-07-01 — SPEC-FORMAT-TERSE.3.2 — split arithmetic call surface

**Scope:** Task-tree ownership, roadmap/live continuity docs, and Knowledge Map fact card. No
parser/compiler/runtime code changed.

**What changed:** Round 3 arithmetic/comparison function spellings are no longer treated as one implementation
leaf. The task tree now splits the surface into numeric word aliases (`.3.2.1`), arithmetic symbol callees
(`.3.2.2`), and comparison spelling policy (`.3.2.3`). The call-shape decision is locked to one
`callee(args)` grammar; the `(op a, b)` Lisp-prefix surface is not added.

**Why:** Current ground truth shows `num_*` helpers are the existing numeric helper family, while bare
`add(...)`/`sum(...)` do not lower as numeric helpers. Symbol callees such as `+(...)` need explicit parser and
lowering support on both variants, and raw Perl fallback can misinterpret `+(2,3)`. Bare `eq`/`ne`/`gt`/`ge`/
`lt`/`le` are already documented and lowered as string comparisons, so numeric comparison word aliases require
an explicit compatibility decision before code.

**Validation:** Knowledge Map retrieval, TOOLBOX probes, source reads of the Perl/Rust call parsers and helper
dispatchers, and mdBook comparison-helper audit established the split. Memory architecture, doctrine,
Knowledge Map, and diff checks passed.

## 2026-07-01 — SPEC-FORMAT-TERSE.3.1 — lock edge syntax contract

**Scope:** Task-tree status, mdBook edge-syntax wording, Knowledge Map fact card, and live continuity docs. No
parser/compiler/runtime code changed.

**What changed:** Round 3 edge syntax is now a locked contract: `->` remains the action-edge surface, `=>`
remains the blind-call surface, and grouped action-edge targets remain syntactic factoring only when one shared
code block is present (`-> RuleA | RuleB { ... }`). The block-less grouped form `-> RuleA | RuleB` stays
invalid.

**Docs:** The action/lifecycle placement chapter and formal grammar appendix now explicitly state that grouped
targets require a shared block. A new Knowledge Map fact points to the existing regression locks and the
validator diagnostic so future sessions do not re-derive this from parser internals.

**Validation:** Focused `perl -Iperl` validation/bootstrap probes confirmed grouped shared-block acceptance,
two-target `ACODE` expansion, and block-less grouped-target rejection with the current diagnostic. Existing
phase0 locks already cover two-target parse expansion, shared-block validation acceptance, missing-block
rejection, and three-target grouping. Full phase0 passed (`prove -q -Iperl t/phase0_regression.t`, 1001
tests), and `bash tools/run_ci_local.sh` passed.

## 2026-07-01 — SPEC-FORMAT-TERSE.5.0 — own future variant parity inventory

**Scope:** Task-tree ownership, roadmap/live continuity docs, mdBook backend-handoff status, and Knowledge Map
backend fact correction. No parser/compiler/runtime code changed.

**What changed:** Future backend parity is now a concrete task-tree-owned surface before any non-Rust variant
code. The implemented backend inventory is explicit: Perl remains the reference implementation and Rust is the
implemented interpreter variant under `rust/`. Julia and Dart remained accepted future targets from ADR `0006`
and Phase 8 at this slice, but required dedicated backend implementation task trees before code. Lua was not
yet adopted by the then-current ADR/book/codebase set; ADR `0021` now supersedes that blocker and schedules Lua
after Dart and Julia under `FUTURE-PARITY-BACKLOG`.

**Docs:** The stale Knowledge Map backend fact that still said LinkedSpec was "currently Perl 5 only" was
updated to the post-Phase-9 inventory. The backend handoff chapter now reflects the current 52-fixture Rust
oracle corpus state after `SPEC-FORMAT-TERSE.2.3.5.5`. The active frontier now returns to
`SPEC-FORMAT-TERSE.3.1` (edge syntax confirmation).

**Validation:** Full bootstrap/roadmap/mdBook/codebase read completed before edits; `rg` inventory found no
tracked Julia/Dart/Lua implementation paths outside the unrelated nested `rgx` checkout. Memory architecture,
doctrine, Knowledge Map, `git diff --check`, and `mdbook build docs/linkedspec-book` passed in the commit
workflow.

## 2026-07-01 — SPEC-FORMAT-TERSE.2.3.5.5 — implement block-valued receiver chains

**Scope:** Perl ActionIR receiver-chain lowering, Rust expression parser, focused Perl/Rust locks, oracle
corpus, mdBook, Knowledge Map, roadmap/task-tree/live docs.

**What changed:** Expression-valued blocks can now be receivers for the existing compatible receiver-dot value
families. Blocks yielding arrays, strings, hashes, or numbers feed the same array/string/hash/number helper
chains that `.2.3.5.1` through `.2.3.5.4` own. Locked examples include
`{ [3, 1, 2] }.sorted().join_values(",")`, `{ return(["x", "y"]); ["bad"] }.join_values("|")`,
`{ set(raw, " a-b "); raw }.trim().split("-").count()`,
`{ { "b" => 2, "a" => 1 } }.sorted_keys().join_values(",")`, and `{ 3.5 }.floor().add(2)`.

**Boundary:** The block adds no special block-only receiver semantics. `return(expr)` inside the block remains
block-local and yields the receiver value. Perl statically recognizes array-yielding block exits only for the
array helper recognizer; hash/string/number families continue through their existing value lowering. Rust now
parses fluent chains after block/hash/array primaries and reuses the existing fluent-chain runtime evaluator.

**Validation:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`; `perl -Iperl -c
t/phase0_regression.t`; `perl -Iperl -c tools/gen_oracle_corpus.pl`; focused Perl lowering/runtime probes;
focused Rust parser/runtime tests PASS; `perl -Iperl tools/gen_oracle_corpus.pl` generated **52 fixtures**;
Rust `corpus_oracle` PASS over 52 fixtures; full phase0 PASS with **1001 tests**; `mdbook build
docs/linkedspec-book` PASS; Knowledge Map, memory-architecture, doctrine, and `git diff --check` gates PASS;
`bash tools/run_ci_local.sh` PASS.

## 2026-07-01 — SPEC-FORMAT-TERSE.2.3.5.6 — lock aggregate wrapper quoting boundaries

**Scope:** Perl ActionIR aggregate-wrapper/value lowering, Rust boundary locks, oracle corpus, mdBook,
Knowledge Map, roadmap/task-tree/live docs.

**What changed:** Aggregate typed wrappers now have a locked quoting boundary. A wrapper with exactly one bare
name token remains an explicit typed working-variable read (`array(foo)` / `a(foo)` -> `@foo`,
`hash(bar)` / `h(bar)` -> `%bar`). Quoted wrapper arguments stay literal constructor payloads, not aliases and
not runtime scalar-indirect lookups. Direct shape literals (`[...]`, `{...}`, `[]`, `{}`) are the preferred
terse array/hash constructor surface in the mdBook.

**Boundary:** No `foo.array()` postfix typed-view adapter was added. `array("foo")` / `array('foo')` do not
read `@foo`; quoted hash constructor keys remain fixed payload keys under the existing constructor rules.
Primitive literals and inappropriate engine locals are not claimed as aggregate variable names.

**Validation:** Perl syntax checks for `MethodLowering.pm`, `ValueExpr.pm`, `t/phase0_regression.t`, and
`tools/gen_oracle_corpus.pl`; focused lowering/runtime/source probes; full phase0 PASS with **1000 tests**;
focused Rust `.2.3.5.6` tests PASS; oracle regeneration produced **51 fixtures**; Rust `corpus_oracle` PASS
over 51 fixtures; `mdbook build docs/linkedspec-book` PASS.

## 2026-07-01 — SPEC-FORMAT-TERSE.2.3.5.4 — implement number receiver value chains

**Scope:** Perl ActionIR receiver-chain lowering, Rust fluent-chain numeric parsing/runtime evaluation, focused
Perl/Rust locks, oracle corpus, mdBook, Knowledge Map, roadmap/task-tree/live docs.

**What changed:** Number receiver-dot value chains are now portable on Perl and Rust. Numeric receivers feed the
existing `num_*` helper family as the first argument, so chains such as
`score.abs().ceil().add(2, 3).mul(2).sub(1).div(2).clamp(0, 20).max(5).min(12)`,
`5.mod(2)`, `3.5.floor().add(1)`, and `3.5.round()` are locked. Perl now treats decimal dots as numeric
literal syntax instead of receiver separators and lowers value-form numeric comparisons. Rust parses fluent
chains after numeric literals and evaluates the same receiver family.

**Boundary:** Numeric comparisons (`eq`, `ne`, `gt`, `ge`, `lt`, `le`) are terminal; invalid later receiver
continuations return `undef` / JSON `null`. Numeric array reducers remain explicit array-consuming helpers with
no scalar-to-array receiver bridge. `declare(...)` and other statement/lifecycle methods are not terse receiver
methods.

**Validation:** `rustfmt` on touched Rust files; `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`;
`perl -Iperl -c t/phase0_regression.t`; `perl -Iperl -c tools/gen_oracle_corpus.pl`; focused
lowering/runtime/source probes; focused Rust parser/runtime tests PASS; `perl -Iperl tools/gen_oracle_corpus.pl`
generated 50 fixtures; Rust `corpus_oracle` PASS over 50 fixtures; full phase0 PASS with **999 tests**.

## 2026-07-01 — SPEC-FORMAT-TERSE.2.3.5.3 — implement string receiver value chains

**Scope:** Perl ActionIR receiver-chain lowering, Rust fluent-chain parser/runtime evaluation, focused
Perl/Rust locks, oracle corpus, mdBook, Knowledge Map, roadmap/task-tree/live docs.

**What changed:** String/scalar receiver-dot value chains are now portable on Perl and Rust. String-returning
helpers compose from scalar and string-literal receivers (`raw.trim().lowercase().replace_substr("-", "_")`,
`"abcdef".substr(1, 3).uppercase()`), and `split(delim)` explicitly bridges into the array receiver-chain
family (`raw.trim().split("-").trim_each().lowercase_each().join_values("|")`). Value-form `split(...)` and
`substr(...)` now lower as portable helper payloads.

**Boundary:** Scalar terminals (`length`, `starts_with`, `ends_with`, `contains_substr`, `matches`) end the
string chain. Invalid post-terminal continuations return `undef` / JSON `null` instead of leaving raw
receiver-dot host residue. Block-valued receiver chaining is now task-tree owned as
`SPEC-FORMAT-TERSE.2.3.5.5` after the number-family leaf.

**Validation:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`; `perl -Iperl -c
t/phase0_regression.t`; `perl -Iperl -c tools/gen_oracle_corpus.pl`; focused lowering/runtime/source probes;
`prove -q -Iperl t/phase0_regression.t` PASS (998 tests); focused Rust parser/runtime tests PASS; `perl -Iperl
tools/gen_oracle_corpus.pl` generated 49 fixtures; Rust `corpus_oracle` PASS over 49 fixtures.

## 2026-07-01 — SPEC-FORMAT-TERSE.2.3.5.2 — implement hash receiver value chains

**Scope:** Perl ActionIR receiver-chain lowering, Rust fluent-chain runtime evaluation, Rust hash-helper
parity cleanup, focused Perl/Rust locks, oracle corpus, mdBook, Knowledge Map, roadmap/task-tree/live docs.

**What changed:** Hash receiver-dot value chains are now portable on Perl and Rust. Hash-returning helpers
compose from hash receivers (`meta.set_key(...).count_keys()`, `hash(meta).rename_key(...).drop_keys(...)`),
and `sorted_keys()` / `sorted_values()` bridge into the already-landed array receiver-chain family
(`meta.sorted_keys().join_values(",")`). Receiver-dot `scalaref(key)` reads one field from the current hash
value. Bare hash receivers are normalized as hash snapshots so helper optional-scope parsing cannot drop the
receiver.

**Boundary:** Statement-level `set_key(meta, key, value)` and `meta[key] = value` keep mutating the named
working hash. Receiver-dot `meta.set_key(key, value)` is pure value composition and does not mutate unless the
result is assigned back. Bare receiver `.copy()` remains array-family/array-first; hash receiver snapshots use
`hash_copy()` or explicit `hash(...).hash_copy()`.

**Validation:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`; `perl -Iperl -c
t/phase0_regression.t`; hash-chain TOOLBOX probes; focused Rust parser/runtime tests PASS; `perl -Iperl
tools/gen_oracle_corpus.pl` generated 48 fixtures; Rust `corpus_oracle` PASS over 48 fixtures.

## 2026-07-01 — SPEC-FORMAT-TERSE.2.3.5.1 — implement array receiver value chains

**Scope:** Perl ActionIR receiver-chain lowering, Rust fluent-chain runtime evaluation, focused Perl/Rust
locks, oracle corpus, mdBook, Knowledge Map, roadmap/task-tree/live docs.

**What changed:** Array receiver-dot value chains are now portable on Perl and Rust. Compatible array-returning
helpers feed the next array helper (`items.sorted().drop_front(2).first()`), pipeline-style array links return
chainable arrays in receiver form (`items.uniq().join_values(",")`, `items.filter_match(/^a$/).count()`), and
terminal helpers return their documented scalar, number, string, or boolean values. Receiver-dot
`join_values` preserves the canonical delimiter-first helper contract, so `items.join_values("|")` maps to
`join_values("|", items)`.

**Boundary:** Public function-style array-pipeline lowering keeps its legacy statement-oriented source shape;
the new pure array value path is scoped to receiver-dot chains. `split(value, delim)` is not an array receiver
link because its receiver is scalar/string input. `.1.6` end mutations (`push_back`, `push_front`, `pop_back`,
`pop_front`) remain statement-only and return `undef` without mutating when used as value expressions.

**Validation:** `perl -Iperl -c perl/LinkedSpec/ActionIR/MethodLowering.pm`; `perl -Iperl -c
t/phase0_regression.t`; receiver-chain TOOLBOX probes; `prove -q -Iperl t/phase0_regression.t` PASS (996
tests); focused Rust parser/runtime tests PASS; `perl -Iperl tools/gen_oracle_corpus.pl` generated 47
fixtures; Rust `corpus_oracle` PASS over 47 fixtures.

## 2026-07-01 — SPEC-FORMAT-TERSE.2.3.5 — split return-type method chaining

**Scope:** Task-tree split, mdBook contract corrections, Knowledge Map, roadmap tracker, and live continuity
docs. No parser/runtime behavior changed.

**What changed:** Return-type method chaining is now specified before implementation. Receiver-dot value chains
will be implemented by return family (array, hash, string, number) with explicit Perl/Rust parity locks and
oracle fixtures. The first executable child is `SPEC-FORMAT-TERSE.2.3.5.1` for array receiver-dot value
chains.

**Boundary:** Existing `.1.6` receiver-dot array end mutations stay statement-only:
`items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`, and `items.pop_front()` mutate the
named working array and pop methods discard the removed value. Value-position/chained receiver forms such as
`return(items.pop_back())`, `set(out, items.push_back("a"))`, and
`items.push_back("a").push_back("b")` remain outside the current runtime contract until their child leaf
defines return semantics.

**Docs:** Corrected stale mdBook wording that still described inline composite `if(...)` / `switch(...)` as
Rust-only value forms. Those helpers are now documented as portable lazy value helpers in `return(...)`,
assignment RHS, and fluent `.return(...)` slots.

**Validation:** TOOLBOX lowering/runtime probes captured the current receiver-chain boundary; Knowledge Map
regeneration PASS; `bash scripts/check_memory_architecture.sh` PASS; `bash scripts/check_doctrines.sh` PASS;
`bash knowledge-map/scripts/check_knowledge_map.sh` PASS; `git diff --check` PASS; `mdbook build
docs/linkedspec-book` PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.3.4.2 — implement Perl inline value controls

**Scope:** Perl ActionIR value lowering, flow-expression boolean lowering, scanner/rewrite support, auto-working-variable
discovery, phase0 regression coverage, generated oracle corpus fixtures, mdBook, Knowledge Map, roadmap
tracker, task tree, and live continuity docs.

**What changed:** Inline-composite `if(...)` and `switch(...)` now lower as value-producing expressions on the
Perl reference in supported value positions: `return(...)`, assignment RHS, and fluent `.return(...)`.
`if(...)` assigns only the selected branch payload into a scoped `do { ... }` value and supports
`elseif(...)`, `else(...)`, and the Rust-compatible plain third-argument fallback. `switch(...)` evaluates its
source once, compares `case(...)` values in order, returns the first matching branch payload, and uses
`default(...)` when no case matched. Inline branch payloads compose with nested helpers and expression-valued
blocks, and branch-local scalar reads now participate in auto-working-variable declaration.

**Boundary:** The asserted contract is the selected payload value. Legacy/action-edge return arrays may still
contain ordinary string tags for compatibility, but `.2.3.4.2` does not require a specific `?...:` tag spelling.
Receiver-dot value-returning/chained methods remain `SPEC-FORMAT-TERSE.2.3.5`.

**Validation:** Perl syntax checks PASS for the changed ActionIR modules and oracle generator; focused probes
PASS for direct return, assignment RHS, nested predicates, block-valued branches, and fluent `.return(...)`;
`prove -q -Iperl t/phase0_regression.t` PASS with **995 tests**; `perl -Iperl tools/gen_oracle_corpus.pl`
regenerated **46 fixtures**; Rust `corpus_oracle` PASS over all 46 fixtures including
`terse_2_3_4_2_inline_if_value_control` and `terse_2_3_4_2_inline_switch_value_control`.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.3.4.1 — implement Rust bare aggregate helper args

**Scope:** Rust runtime helper evaluation, focused Rust parity locks, generated oracle corpus fixtures, mdBook
contract wording, task tree, Knowledge Map, roadmap tracker, and live continuity docs.

**What changed:** Rust now promotes a bare working-variable name to a typed aggregate snapshot only in helper
argument slots whose callee contract already implies a hash or array. This closes the audited
`merge_hash(hash_copy(base), overlay)` parity gap and the matching array-helper surface without changing global
`Expr::Variable` behavior, which still reads scalar state. The promotion is shared by hash/object helper
positions such as `merge_hash(...)`, `set_key(hash_expr, ...)`, `rename_key(...)`, `drop_keys(...)`,
`pick_keys(...)`, `sorted_keys(...)`, `sorted_values(...)`, `count_keys(...)`, `has_key(...)`, `scalaref(...)`,
and `flat_hash(...)`, plus array helper positions such as `sorted(...)`, `reversed(...)`, `first(...)`,
`last(...)`, `take(...)`, `drop_front(...)`, `contains(...)`, `index_of(...)`, `num_sum(...)`, and
`flat_array(...)`.

**Validation:** Focused Rust runtime locks for `terse_2_3_4_1` PASS; `perl -Iperl tools/gen_oracle_corpus.pl`
regenerated 44 fixtures; Rust `corpus_oracle` PASS over 44 fixtures including
`terse_2_3_4_1_bare_hash_helper_arg_composition` and
`terse_2_3_4_1_bare_array_helper_arg_composition`.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.3.4 — split full composability boundaries

**Scope:** Full composability audit, task-tree split, oracle corpus fixture, mdBook contract wording, Knowledge
Map, roadmap tracker, and live continuity docs. No runtime behavior changed.

**What changed:** The audit separated the currently portable pure value-helper composition subset from two
unsupported "function anywhere" sites. A new oracle fixture,
`terse_2_3_4_deep_pure_helper_composition`, locks the supported nested form
`count(drop_front(sorted_keys(merge_hash(hash_copy(base), hash(overlay)))))`; the Rust corpus now has 42
fixtures and passes. The book now says pure value helpers compose at arbitrary depth, but statement forms,
receiver-dot mutation methods, and inline value-control forms are not all value expressions.

**Split:** `SPEC-FORMAT-TERSE.2.3.4.1` owns Rust helper-context aggregate bare reads after the diagnostic
`merge_hash(hash_copy(base), overlay)` fixture returned Perl `2` but Rust `1`. `SPEC-FORMAT-TERSE.2.3.4.2`
owns Perl inline-composite value-control lowering after generated-source probes showed `return(if(...))` and
`return(switch(...))` do not reliably return selected branch values. Receiver-dot value-returning/chained
methods remain `SPEC-FORMAT-TERSE.2.3.5`.

**Validation:** Perl TOOLBOX lowering/runtime/generated-source probes complete; diagnostic Rust corpus run
exposed the bare-hash argument mismatch; final oracle generator regeneration PASS; final Rust `corpus_oracle`
PASS over 42 fixtures. Full gates are recorded in the commit workflow.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.3.3.3.3.1 — implement Rust tclite default repetition

**Scope:** Rust default-mode repetition metadata, Rust lifecycle preamble return behavior, shipped `tclite`
oracle fixture re-enable, task tree, roadmap tracker, mdBook backend status, Knowledge Map, and live
continuity docs.

**What changed:** Rust now treats bare default rules as zero-min repeated-choice rules (`rep_min = Some(0)`,
unbounded max), matching the Perl reference model used by shipped recursive specs. Rust rule invocation also
honors an `I`/preamble `return(expr)` immediately after executing the preamble: the returned value exits that
child invocation before the child re-matches its entry regex, which is the Perl dispatch behavior used by
edge-only `tclite` children such as `I.return([])` and quote/bracket close rules. The stale Rust lifecycle
expectations that assumed `I.return(...)` continued into matching and `E` were corrected to the Perl output.
Capture-helper and lifecycle-order integration tests that intentionally exercise one seek match now spell
`OR{1,1}` explicitly instead of depending on the old bare-default single-pass assumption.

**Oracle:** `tools/gen_oracle_corpus.pl` now restores `tclite_command_subst` (`[]`) and
`tclite_double_quote` (`""`) as active shipped-spec fixtures. The regenerated Rust oracle corpus has 41
fixtures and the two `tclite` cases now pass with the tagged Perl-reference `tcl_script` values.

**Boundary:** This leaf implements the default-mode repetition and I-block early-return behavior required for
the two minimal `tclite` fixtures. It does not silently claim broader lifecycle-control cleanup for every
marker or every possible multiple-return statement shape; any remaining lifecycle-return parity issue must be
owned by a later leaf if found.

**Validation:** focused Rust core default-mode compile lock PASS; focused Rust runtime default-mode/action-edge
lock PASS; focused lifecycle expectation locks PASS; oracle generator syntax/regeneration PASS; Rust
`corpus_oracle` PASS over 41 fixtures. Full memory/doctrine/KM/mdBook/local gates are recorded in the commit
workflow.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.3.3.3.3 — split Rust tclite repetition parity

**Scope:** Rust `tclite` oracle retry after fluent parity, task-tree split, oracle generator/test comments,
Knowledge Map, roadmap tracker, mdBook backend-corpus status, and live continuity docs. No runtime behavior
changed in this slice.

**What changed:** After compact lifecycle/body receiver chains and action-edge explicit/flow fluent chains
landed, the deferred `tclite` oracle cases were retried instead of inferred. The Perl reference returns
`["?tcl_script:",[["?command_subst:",[]]]]` for `[]` and
`["?tcl_script:",[["?double_quote:",[]]]]` for `""`. Temporarily adding those cases to the Rust oracle corpus
made only those two fixtures fail; both actual Rust outputs were `[]`.

**Boundary:** At this split point the failing fixtures were not committed to the green corpus. The remaining
implementation work was owned by `SPEC-FORMAT-TERSE.2.3.3.3.3.1`, which later re-enabled
`tclite_command_subst` and `tclite_double_quote` after Rust default-mode recursive repetition parity landed.

**Validation:** The diagnostic corpus retry exposed the two failures with all other 39 fixtures passing. The
final committed state restores the green corpus; oracle generator syntax/regeneration, Rust corpus oracle,
mdBook, Knowledge Map, memory/doctrine/diff, and local CI validation are recorded in the commit workflow.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.3.3.3.2 — implement Rust action-edge fluent flow chains

**Scope:** Rust action-edge fluent continuation parsing, compilation, and runtime execution for explicit
target pushes and statement-control chains, plus task tree, roadmap tracker, mdBook, Knowledge Map, and live
continuity docs.

**What changed:** Rust now keeps multiline dotted continuations after `-> child` attached to that action edge
and executes the accepted explicit/flow subset. `.push(target)` and `.push(child,target)` dispatch the child,
capture its rule return, suppress child accumulator leakage, and append the return value to the named target
array. Fluent statement controls such as `.if(...).push(...).else().return_undef().endif()` gate later calls
with the same control-stack model used by structured blocks, while branch-local helpers such as `.say(...)`
run through normal helper evaluation.

**Boundary:** This closes the remaining fluent blocker before retrying `tclite`; the next leaf,
`.2.3.3.3.3`, owns the oracle re-enable/default-mode repetition audit. It does not broaden lifecycle compact
chain semantics, which already landed in `.2.3.3.3.1`.

**Validation:** Focused Rust core action-edge flow-chain locks PASS; focused Rust runtime `terse_2_3_3_3_2`
PASS; existing no-arg action-edge fluent regression PASS. Full Rust core/runtime, mdBook, Knowledge Map,
memory/doctrine/diff, and local CI gates are recorded in the commit workflow.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.3.3.3.1 — implement Rust compact lifecycle fluent chains

**Scope:** Rust body parser normalization for compact lifecycle-marker receiver chains, parser/compiler/runtime
locks, mdBook wording, Knowledge Map fact sources, task tree, roadmap tracker, and live continuity docs.

**What changed:** Rust now accepts compact lifecycle/body receiver chains such as `I.return(...)`,
`E.return(...)`, and `I.declare(...).set(...).return(...)` by normalizing them to existing lifecycle
`CodeBlock` statement strings before compilation. The compiler therefore reuses the normal lifecycle slots, and
the runtime executes the existing statement-block model instead of adding a new standalone `FluentChain`
execution path.

**Boundary:** This slice deliberately does not broaden action-edge explicit/flow fluent semantics. Forms such as
`.push(child,target)` and `.if(...).push(child,target).else().return_undef().endif()` remain owned by
`.2.3.3.3.2`; the `tclite` oracle/default-mode repetition audit remains behind that follow-on work.

**Validation:** Focused Rust core `lifecycle_compact` PASS; focused Rust runtime `terse_2_3_3_3_1` PASS; full
Rust core package PASS; full Rust runtime package PASS; mdBook build PASS; oracle generator syntax PASS;
Knowledge Map regenerate/check PASS; rustfmt ran on touched Rust files. Memory/doctrine/diff checks and full
local CI PASS in commit workflow.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.3.3.3 — split remaining Rust fluent continuations

**Scope:** Task tree, task-tree index, roadmap tracker, Knowledge Map, development notes, and live continuity
docs. No engine, parser, runtime, oracle fixture, or mdBook behavior changed in this split slice.

**What changed:** The remaining Rust fluent parity work is now split into concrete children. `.2.3.3.3.1`
owns compact lifecycle/body receiver chains such as `I.return(...)` and `I.declare(...).return(...)`, where Rust
currently parses a lifecycle marker plus standalone `FluentChain` and the compiler drops the fluent chain.
`.2.3.3.3.2` owns action-edge explicit/flow chains such as `.push(child,target)` and
`.if(...).push(...).else().return_undef().endif()`, because action-edge metadata exists but the runtime only
executes the no-arg `.push` / `.return(expr)` / `.return_undef` subset. `.2.3.3.3.3` owns the deferred
`tclite` oracle re-enable/default-mode repetition audit after those fluent surfaces land.

**Validation:** KM retrieval PASS; Perl reference probes and shipped-spec/code search completed; Rust
parser/compiler/runtime code-read completed; focused Rust `.2.3.3.2` regression test PASS; Knowledge Map
regenerate/check PASS; memory/doctrine checks PASS; `git diff --check` PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.3.3.2 — implement Rust attached fluent block payloads

**Scope:** Rust body parser support for action-edge and lifecycle attached fluent `.when(cond) { ... }`
payloads, focused runtime locks, mdBook wording, Knowledge Map, task tree, roadmap tracker, and live
continuity docs.

**What changed:** Rust now recognizes receiver-fluent `.when(cond) { ... }` block payloads after `-> Target`
action edges and lifecycle markers such as `I`. The parser normalizes those chains to existing attached
`when/otherwise` statement blocks, so the already-landed Rust block interpreter executes the selected branch.
Both dotted `.otherwise { ... }` and no-dot `otherwise { ... }` fallback tails are accepted on action-edge and
lifecycle surfaces.

**Implementation detail:** Multiline tails such as `}.otherwise {` preserve their fallback payload. The parser
tracks the physical line that owns a block remainder before consuming the next attached block, avoiding the
payload-line skip that would otherwise occur after the first multiline branch advances the body cursor.

**Boundary:** Compact lifecycle/body fluent continuations such as `I.return(...)` and any remaining dropped
standalone `FluentChain` paths remain owned by `.2.3.3.3`; the `tclite` oracle also still has the known
default-mode repetition blocker.

**Validation:** Focused Rust core `attached_fluent` PASS; focused Rust runtime `terse_2_3_3_2` PASS; full Rust
core package PASS; full Rust runtime package PASS; mdBook build PASS; Knowledge Map regenerate/check PASS;
memory/doctrine/diff checks PASS; full local CI PASS (`Files=1, Tests=994`).

## 2026-06-30 — SPEC-FORMAT-TERSE.2.3.3.1 — implement Rust action-edge fluent continuations

**Scope:** Rust parser/compiler/runtime action-edge fluent metadata and execution, focused Rust locks, mdBook
wording, Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** Rust now preserves fluent chains after `->` action edges through `ActionEdge` and compiled
`AcodeEntry` metadata. Runtime dispatch executes the accepted Perl-reference no-arg continuation surface:
`.push` dispatches the matched child and appends its return value to the current rule accumulator, while
`.return(expr)` and `.return_undef` return through the current rule/action channel without forcing a recursive
close-edge child dispatch. Child return events are suppressed from the shared engine accumulator during
action-edge `.push`, matching the parent-visible action-edge return channel instead of leaking child events.

**Oracle triage:** The `tclite` fixtures remain deferred. This slice removed the action-edge fluent blocker, but
the shipped spec still depends on compact lifecycle/body fluent forms such as `I.return(...)` and on the
separate default-mode repetition parity gap. Those are owned by the follow-on `.2.3.3.x` leaves rather than
folded into this action-edge slice.

**Validation:** Focused Rust core `fluent_chain` PASS; focused Rust runtime `terse_2_3_3_1` PASS; full Rust
core package PASS; full Rust runtime package PASS; mdBook build PASS; Knowledge Map, memory, doctrine, and
diff checks PASS; full local CI PASS (`Files=1, Tests=994`).

## 2026-06-30 — SPEC-FORMAT-TERSE.2.3.2 — lock lifecycle value drop return channel

**Scope:** Perl phase0 lifecycle semantics locks, Rust focused runtime locks, mdBook lifecycle/value-block
wording, Knowledge Map, task tree, roadmap tracker, and live continuity docs. No parser lowering behavior was
changed.

**What changed:** Lifecycle blocks are now documented and regression-locked as statement blocks. Ordinary final
statement values are discarded; only top-level `return(expr)` writes the surrounding rule/action return
channel. Expression-valued block `return(expr)` remains block-local and is locked separately.

**Validation:** Perl syntax check PASS; phase0 PASS (`Files=1, Tests=994`); focused Rust runtime
`terse_2_3_2` PASS; mdBook build PASS; Knowledge Map check PASS; memory/doctrine/diff checks PASS; full
local CI PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.3.1 — lock Perl fluent when otherwise blocks

**Scope:** Perl bootstrap method-chain parsing, phase0 regression locks, mdBook wording, Knowledge Map, task
tree, roadmap tracker, and live continuity docs. Rust parity remains split to `.2.3.3`.

**What changed:** Perl reference fluent attached control-flow chains now preserve fallback tails after a fluent
`.when(cond) { ... }` head. Both dotted `.otherwise { ... }` and no-dot `otherwise { ... }` continuations are
accepted on action-edge and lifecycle surfaces.

**Implementation:** `BootstrapSpec::Core` now accepts an optional leading dot before attached fluent tail
clauses, recognizes `when` as an attached fluent-if head, and recognizes `otherwise` as an attached fallback
tail. `ActionIR::ControlFlow` already lowers the resulting attached fallback as canonical `else`, so the fix
stays in the bootstrap parser.

**Validation:** Perl syntax checks PASS; phase0 PASS (`Files=1, Tests=993`); mdBook build PASS; Knowledge Map
regenerate/check PASS; memory/doctrine/diff checks PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.3 — split fluent lifecycle composability surface

**Scope:** Task tree, global task-tree index, roadmap tracker, live continuity docs, mdBook wording, and
Knowledge Map fact sources. No Perl, Rust, or oracle fixture behavior changed in this ownership slice.

**Ground truth:** Perl reference already accepts exact action and lifecycle fluent block chains such as
`.when(cond) { ... }.otherwise { ... }` with no raw fallback or unresolved helper residue. Rust attached
statement blocks are portable, but Rust does not yet have expression fluent attached-block payloads and still
has action-edge fluent continuation parity tracked by `RUST-PARITY.7.5.3`. Lifecycle block syntax exists, but
final-expression value dropping and explicit `return(expr)` rule-channel behavior need a focused lock.
Receiver-dot array end methods remain statement-only; value-returning/chained method calls are a later surface.

**Split:** `.2.3` is now a container. `.2.3.1` owns the Perl fluent block-chain contract lock; `.2.3.2` owns
lifecycle value-drop/return-channel semantics; `.2.3.3` owns Rust fluent block-chain/action-edge parity;
`.2.3.4` owns full composability audit and follow-on split; `.2.3.5` owns return-type method chaining design
and first implementation split.

**Validation:** KM retrieval PASS; TOOLBOX descriptor/runtime probes completed; Perl/Rust code-read completed;
focused Rust parser spot checks PASS where applicable; mdBook build PASS; Knowledge Map regenerate/check PASS;
memory/doctrine/diff checks PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.2.6.2 — implement Rust attached while safety

**Scope:** Rust lifecycle-code parser/runtime, numeric comparison helper parity required by the documented
counter-loop pattern, Rust integration locks, Perl-oracle corpus fixture, mdBook/KM/task-tree/live docs.

**What changed:** Rust now accepts attached-block `while(cond) { ... }` as portable DSL control flow. The
parser claims one-argument attached `while(...) { ... }` statements and stores the parsed body as a lazy block.
The runtime re-evaluates the condition before each iteration, executes body statements while true, supports
nested attached `if`/`switch` blocks in loop bodies, and preserves block-local `return(expr)` inside
expression-valued blocks.

**Safety:** Rust mirrors the Perl reference guard: a loop that remains true after 10000 iterations returns the
diagnostic `LinkedSpec while iteration safety limit exceeded after 10000 iterations` instead of hanging.

**Oracle:** The corpus regenerated to **39 fixtures** with `terse_2_2_6_2_attached_while_blocks`; Rust corpus
oracle PASS.

**Validation:** Focused Rust parser `attached_while` PASS; focused Rust runtime `terse_2_2_6_2` PASS; full
Rust core package PASS; full Rust runtime package PASS; Rust corpus oracle PASS; oracle generator
syntax/regeneration PASS; mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS
(`Files=1, Tests=992`).

## 2026-06-30 — SPEC-FORMAT-TERSE.2.2.6.1 — implement Perl attached while safety

**Scope:** Perl ActionIR control-flow lowering, scanner/contract metadata, canonical diagnostics, phase0
regression locks, mdBook status wording, Knowledge Map, task tree, and live continuity docs. Rust attached
`while` parity remains `.2.2.6.2`.

**What changed:** The Perl reference now accepts attached-block `while(cond) { ... }` as DSL control flow
without raw fallback or unresolved helper residue. The condition is evaluated before each iteration, body
statements run while it stays true, and `return(expr)` inside the loop returns from the surrounding rule/action.

**Safety:** Lowering emits a deterministic per-loop iteration guard. A non-terminating DSL loop trips
`LinkedSpec while iteration safety limit exceeded after 10000 iterations` and returns control to the parser
instead of hanging.

**Validation:** Perl syntax checks PASS; TOOLBOX lowering/descriptor/runtime/source probes PASS; phase0 PASS
(`Files=1, Tests=992`); mdBook build PASS; Knowledge Map regenerate/check PASS; memory/doctrine/diff checks
PASS; full local CI PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.2.6 — split while loop surface

**Scope:** Task tree, task index, roadmap tracker, live continuity docs, development notes, mdBook status
wording, and Knowledge Map fact sources. No Perl, Rust, or oracle fixture behavior changed in this ownership
slice.

**Ground truth:** Attached-block `while(cond) { ... }` is not portable yet. Perl currently lowers
`while(false) { return("bad") }` as raw host code (`ready=0 raw=1 fallback=1 unresolved=0`), and Rust has no
attached statement-loop parser/runtime.

**Split:** `.2.2.6` is now a container. `.2.2.6.1` owns the Perl reference loop/safety contract:
ActionIR-owned lowering, condition re-evaluation before each iteration, body execution while true, and a
deterministic iteration guard for non-terminating loops. `.2.2.6.2` owns Rust parity after that Perl contract
is locked.

**Validation:** KM retrieval PASS; TOOLBOX lowering/descriptor probes completed; Perl/Rust code-read
completed; mdBook build PASS; Knowledge Map regenerate/check PASS; memory/doctrine/diff checks PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.2.5.2 — implement Rust attached switch blocks

**Scope:** Rust lifecycle-code parser/runtime, Rust integration locks, Perl-oracle corpus fixture, mdBook
control-flow documentation, Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** Rust now accepts portable attached-block `switch/case/default` statement bodies:
`switch(expr) { case(v) { ... } case(w) { ... } default { ... } }`.

**Implementation:** `CodeBlock::parse` recognizes one-argument attached `switch(...) { ... }` blocks before
ordinary statement parsing, requires `case(value) { ... }` / `default { ... }` branch bodies inside the outer
block, and normalizes the result to `switch` / `case` / `default` / `endswitch` statement controls. The runtime
now carries a statement-switch stack beside the existing statement-if stack in both lifecycle block execution
and expression-valued block evaluation. Branch matching is first-match with default fallback, inactive branches
do not evaluate side effects, and multi-argument lazy value-form `switch(expr, case(...), default(...))` remains
unchanged.

**Validation:** Perl syntax checks PASS; phase0 PASS (`Files=1, Tests=991`); focused Rust parser
`attached_switch` PASS; focused Rust runtime `terse_2_2_5_2` PASS; lazy value-form `cond_switch` PASS; Perl
oracle corpus regenerated to **38 fixtures** with `terse_2_2_5_2_attached_switch_blocks`; Rust corpus oracle
PASS; mdBook build PASS; Knowledge Map regenerate/check PASS; memory/doctrine/diff checks PASS; full local CI
PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.2.5.1 — implement Perl attached switch separator lock

**Scope:** Perl ActionIR statement splitting, phase0 regression locks, mdBook control-flow wording,
Knowledge Map, task tree, roadmap tracker, and live continuity docs. Rust attached-switch parity remains
`.2.2.5.2`.

**What changed:** Compact attached-block `switch/case/default` now lowers through the Perl reference without
host-shaped branch residue: `switch(expr) { case(v) { ... } case(w) { ... } default { ... } }`.

**Implementation:** `StatementSplit::Core` now recognizes complete attached `case(...) { ... }` and
`default { ... }` branch bodies and splits them before a following same-line `case(...) {` or `default {`
continuation. The existing attached-switch lowerers then emit the canonical guarded branch sequence with no raw
fallback or unresolved helper residue. A same-line ordinary statement after the final attached switch still
requires `;`.

**Validation:** Perl syntax checks PASS; TOOLBOX descriptor/lowering/runtime/source probes PASS; phase0 PASS
(`Files=1, Tests=991`); mdBook build PASS; Knowledge Map regenerate/check PASS; memory/doctrine/diff checks
PASS; full local CI PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.2.5 — split attached switch surface

**Scope:** Task tree, Knowledge Map fact sources, roadmap tracker, and live continuity docs. No Perl behavior,
Rust behavior, oracle fixture, or mdBook behavior changed in this ownership slice.

**Ground truth:** Attached `switch/case/default` is not one safe implementation leaf. Perl already has
attached-switch lowering machinery and a one-case/default form can run, but adjacent branch blocks without an
explicit separator can leave unresolved `case(...) { ... }` residue or host-like `default { ... }` labels in
generated source. Rust currently has lazy value-form `switch(expr, case(...), default(...))` runtime support,
but `CodeBlock::parse` only recognizes attached statement blocks for `if`/`when`, not attached switch branches.

**Split:** `.2.2.5` is now a container. `.2.2.5.1` owns the Perl reference separator/source lock for
attached `switch/case/default`; `.2.2.5.2` owns Rust parser/runtime parity after the Perl contract is locked.

**Validation:** KM retrieval PASS; TOOLBOX descriptor/lowering/runtime probes completed; Perl/Rust code-read
completed; focused Rust value-form switch tests PASS with existing warning baseline; memory/doctrine/diff
checks PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.2.4 — implement when otherwise aliases

**Scope:** Perl ActionIR control-flow recognition/lowering, Rust lifecycle-code parser, Rust runtime tests,
Perl-oracle corpus fixture, mdBook control-flow documentation, Knowledge Map, task tree, roadmap tracker, and
live continuity docs.

**What changed:** `when(cond) { ... } otherwise { ... }` is now the portable attached-block alias form for
`if(cond) { ... } else { ... }`.

**Implementation:** Perl recognizes `when`/`otherwise` at the existing statement-splitting,
scanner/contract, and `ControlFlow` seams, normalizing to canonical `if`/`else` instead of leaking host Perl
`when`. Rust `CodeBlock::parse` accepts attached `when` starts and `otherwise` fallback branches, then emits
the existing `if` / `else` / `endif` statement-control sequence. The Rust branch runtime is unchanged.

**Compatibility:** Marker-form `if(cond); ... else(); ... endif()`, attached `if/elseif/else`, and
inline-composite lazy `if(...)` behavior are unchanged.

**Validation:** Perl syntax checks PASS; TOOLBOX lowering/descriptor/runtime/generated-source probe PASS;
focused Rust core `when_otherwise` test PASS; focused Rust runtime `terse_2_2_4` test PASS; Rust oracle
corpus PASS; oracle corpus regenerated to **37 fixtures** with `terse_2_2_4_when_otherwise_aliases`;
phase0 PASS (`Files=1, Tests=991`); mdBook build PASS; Knowledge Map check PASS; memory/doctrine/diff
checks PASS; full local CI PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.2.4 — own when otherwise aliases

**Scope:** Task tree, Knowledge Map fact source, roadmap tracker, and live continuity docs. No Perl behavior,
Rust behavior, oracle fixture, or mdBook behavior changed in this ownership slice.

**Ground truth:** The current Perl reference does not implement `when/otherwise` as DSL control flow.
`when(true) { return("yes") } otherwise { return("no") }` remains raw, descriptor metadata reports
`ready=0 raw=1 unresolved=2`, generated source keeps the host `when(...)` statement and emits Perl's
experimental-`when` warning, and the runtime probe returns `"no"` despite the true condition.

**Owned implementation boundary:** `.2.2.4` should normalize `when(cond) { ... }` to the already-portable
attached `if(cond) { ... }` form, and `otherwise { ... }` to attached `else { ... }`. Perl work belongs in the
existing statement splitter, scanner/contract, and `ControlFlow` dispatch seams. Rust should normalize the
attached parser output to existing `if`/`else`/`endif` statements, so no new runtime branch engine is needed.

**Validation:** KM retrieval completed; TOOLBOX lowering/descriptor/runtime/generated-source probes completed;
Perl/Rust code-read completed; Knowledge Map regenerate/check PASS; memory/doctrine/diff checks PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.2.3 — implement Rust attached if blocks

**Scope:** Rust lifecycle-code parser, Rust runtime integration tests, Perl-oracle corpus fixture, mdBook
control-flow documentation, Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** Rust now accepts portable attached-block `if/elseif/else` statement chains:
`if(cond) { ... } elseif(cond2) { ... } else { ... }`.

**Implementation:** `CodeBlock::parse` recognizes attached branch chains before ordinary statement-expression
parsing and normalizes them to the existing marker-control sequence (`if`, branch statements, `elseif`, branch
statements, `else`, branch statements, `endif`). Runtime branch gating reuses
`Engine::handle_statement_if_control`; no second branch runtime was added.

**Compatibility:** Existing marker-form `if(cond); ... elseif(cond2); else(); ... endif()` and inline-composite
lazy `if(...)` behavior is unchanged. The normal separator contract still applies after an attached chain: a
following same-line statement needs a semicolon after the final `}`.

**Validation:** Focused Rust core parser `attached_if` tests PASS; focused Rust runtime `terse_2_2_3` tests
PASS; oracle corpus regenerated to **36 fixtures** with `terse_2_2_3_attached_if_blocks`; corpus oracle PASS.
mdBook and Knowledge Map updated.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.2.3 — own Rust attached if blocks

**Scope:** Task tree, Knowledge Map fact source, roadmap tracker, and live continuity docs. No Rust code,
oracle fixture, mdBook behavior, or Perl behavior changed in this ownership slice.

**Ground truth:** Rust `CodeBlock::parse` currently parses semicolon/newline-separated expressions and
expression-valued blocks, but has no attached statement-block form for `if(...) { ... } elseif(...) { ... }
else { ... }`. Runtime already gates marker-form branches through `Engine::handle_statement_if_control` in
both lifecycle blocks and expression-valued block evaluation.

**Owned implementation boundary:** `.2.2.3` should parse the accepted Perl `.2.2.2` attached branch syntax
into the existing statement-control model and reuse current branch gating, while preserving marker-form and
inline-composite `if` behavior.

**Validation:** Rust code-read completed; focused Rust parser smoke PASS (`parse_lifecycle_block_content`,
with known nested `rgx` warning noise); Knowledge Map regenerate/check PASS; memory/doctrine/diff checks PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.2.2 — implement Perl attached if blocks

**Scope:** Perl ActionIR statement splitting, phase0 regression coverage, mdBook control-flow wording,
Knowledge Map, task tree, roadmap tracker, and live continuity docs. Rust parity remains `.2.2.3`.

**What changed:** Compact attached-block `if/elseif/else` now lowers through ActionIR on the Perl reference:
`if(cond) { ... } elseif(cond2) { ... } else { ... }` no longer stays a raw Perl fallback statement.

**Implementation:** `StatementSplit::Core` now splits a complete attached `if`/`elseif` branch body before a
same-line attached `elseif(...) { ... }` or bare `else { ... }` continuation. Existing marker-form
`if(cond); ... elseif(cond2); ... else(); ... endif()` and inline-composite `if(...)` behavior is unchanged.

**Validation:** Perl syntax checks PASS; TOOLBOX lowering/metadata/runtime probes PASS; phase0 PASS
(`t/phase0_regression.t`, **991 tests**); mdBook build PASS; Knowledge Map regenerate/check PASS;
memory/doctrine/diff checks PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.2.2 — own Perl attached if blocks

**Scope:** Task tree, Knowledge Map fact source, roadmap tracker, and live continuity docs. No engine,
fixture, mdBook behavior, Rust behavior, or Perl runtime behavior changed in this ownership slice.

**Ground truth:** TOOLBOX probes show newline-separated attached branches already lower through ActionIR with
zero raw fallback, but compact same-line branch continuations still fall back to raw Perl:
`if(cond) { ... } elseif(cond2) { ... } else { ... }`.

**Owned implementation boundary:** `.2.2.2` owns the Perl statement-splitting seam only. The scanner and
`ControlFlow.pm` already recognize individual attached `if`/`elseif`/`else` branch statements, and the rewrite
pipeline already keeps implicit attached-if closures open across `elseif`/`else` continuations. The remaining
implementation is to split a complete attached branch before a same-line `elseif`/`else` continuation while
preserving marker-form `if(...); ... endif()` and inline-composite `if(...)`.

**Validation:** TOOLBOX lowering/metadata probes completed; Perl code-read completed; Knowledge Map
regenerate/check PASS; memory/doctrine/diff checks PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.2.1 — split control-flow keyword surface

**Scope:** Task tree, Knowledge Map, mdBook control-flow documentation, roadmap tracker, and live continuity
docs. No engine behavior changed.

**What changed:** Round 2 control-flow keyword work is now split before implementation. Current portable
support is statement-marker `if(cond); ... elseif(cond); else(); ... endif()` plus inline-composite lazy
`if`/`switch`. Attached-block `if`, `when`/`otherwise`, statement-level `switch` blocks, and `while` are
separate implementation leaves.

**Ground truth:** TOOLBOX lowering/runtime/metadata probes show Perl attached `if(...) { ... } else { ... }`
still falls back to raw Perl, `when`/`otherwise` is host Perl behavior rather than a DSL contract, and
`while(...) { ... }` is raw. Rust code-read shows marker-form `if` gating and inline-composite `if`/`switch`
support, but no attached statement-block parser/runtime for the new keyword surface.

**Documentation:** The mdBook now distinguishes the current portable control-flow contract from Round 2
attached-block work and removes statement-switch examples that are not yet portable.

**Validation:** TOOLBOX probes/code-read completed; focused Rust parser check PASS; mdBook build PASS;
Knowledge Map regenerate/check PASS; memory/doctrine checks PASS; `git diff --check` PASS.

## 2026-06-30 — SPEC-FORMAT-TERSE.2.1.4 — expression-valued block early return

**Scope:** Perl ActionIR value-block lowering, Rust runtime block-value evaluation, Perl/Rust regression
coverage, Perl-oracle corpus fixture, mdBook, Knowledge Map, task tree, roadmap tracker, and live continuity
docs.

**What changed:** Expression-valued blocks now support true block-local early `return(expr)` on both the Perl
reference and Rust backend. A non-empty brace payload without a top-level `=>` remains a block value; `{}` and
`{ key => value }` still remain hash literals. When block evaluation reaches `return(expr)`, the block yields
`expr`, skips later statements inside that block, and does not set or leak the surrounding rule return channel.

**Implementation:** Perl lowering now emits a guarded scalar `do { ... }` wrapper only for blocks that contain
a non-final `return(expr)`, preserving the existing byte-stable output for final-expression and final-return
core cases. Rust `eval_block_value()` now evaluates an active `return(expr)` statement before final-expression
handling and returns its payload from the block.

**Validation:** Perl syntax checks PASS; TOOLBOX lowering/runtime probes PASS; focused Rust `.2.1.4` runtime
locks PASS; oracle corpus regenerated to **35 fixtures** and Rust corpus oracle PASS; phase0 PASS
(`t/phase0_regression.t`, **991 tests**); mdBook build PASS; Knowledge Map regenerate/check PASS;
memory/doctrine/diff checks PASS; full local CI PASS.

## 2026-06-29 — SPEC-FORMAT-TERSE.2.1.3 — Rust expression-valued block parity

**Scope:** Rust parser/runtime, Rust parser/runtime tests, Perl-oracle corpus fixture, mdBook, Knowledge Map,
task tree, roadmap tracker, and live continuity docs. Perl reference behavior is unchanged.

**What changed:** Rust now matches the Perl-reference core expression-valued block contract. `Expr::BlockValue`
represents non-empty brace payloads without a top-level `=>`; `{}` and keyed `{ key => value }` still parse as
hash literals. `Engine::eval_expr()` evaluates block values by running side-effect statements in order and
returning the final expression; a final `return(expr)` is treated as block-local.

**Boundary:** True mid-block early return is still out of scope and remains `.2.1.4`; non-final
`return(expr)` inside a Rust block value is rejected rather than leaking into the rule return channel.

**Gate hygiene:** Full Rust package verification surfaced two stale historical locks and they now match the
current contracts: Rust no-parenthesis helper spelling is rejected under mandatory call parentheses plus
same-line separator enforcement, and the old `.1.2.3.5.3` scalar-held shape-RHS boundary is now validated as
the live `.1.2.3.5.4` aggregate target-kind behavior.

**Validation:** focused Rust core parser locks PASS; focused Rust runtime `.2.1.3` locks PASS; oracle corpus
regenerated to **34 fixtures**; Rust corpus oracle PASS; full Rust core package PASS; full Rust runtime package
PASS; mdBook build PASS; Knowledge Map regenerate/check PASS; memory/doctrine/diff checks PASS; full local CI
PASS (`tools/run_ci_local.sh`, phase0 **991** tests).

## 2026-06-29 — SPEC-FORMAT-TERSE.2.1.3 — own Rust expression-valued block parity

**Scope:** Task tree, roadmap tracker, live continuity docs, and Knowledge Map. No Rust engine, oracle,
fixture, mdBook behavior, or Perl behavior changed in this ownership slice.

**Ground truth:** Rust currently has statement-only `CodeBlock` parsing and `Expr::ArrayLiteral` /
`Expr::HashLiteral` value expressions, but no block-value `Expr` variant. `parse_expr()` routes `{` directly
to `parse_hash_literal()`, so `{}` and `{ key => value }` work as hash literals while
`{ set(x,"a"); x }` is rejected because the hash parser requires `=>`. `Engine::execute_block()` executes
statements and returns `()`, and `Engine::eval_expr()` has no block-value arm.

**Owned implementation boundary:** `.2.1.3` will add Rust parser/runtime parity for the accepted Perl-reference
core: non-empty brace payloads without a top-level `=>` become expression-valued blocks, `{}` / keyed hash
literals keep precedence, final expression and final `return(expr)` yield the block value, and full mid-block
early-return remains `.2.1.4`.

**Validation:** Rust code-read completed; mdBook build PASS; Knowledge Map regenerate/check PASS;
memory/doctrine/diff checks PASS.

## 2026-06-29 — SPEC-FORMAT-TERSE.2.1.2 — Perl expression-valued blocks

**Scope:** Perl ActionIR value lowering, Perl auto-working-variable collection, phase0 regression coverage,
mdBook, Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** The Perl reference now accepts the core expression-valued block subset. In value-consuming
sites, a non-empty brace payload without a top-level `=>` lowers to a Perl `do { ... }` value block. The block
returns its final expression, or a final `return(expr)` payload treated as block-local for this core subset.

**Boundaries:** `{}` and `{ key => value }` remain hash shape literals and continue to take precedence over
block values. Full block-local early return, such as `return({ return("a"); "b" })`, stays split to
`.2.1.4`. Rust parity is not part of this slice and remains `.2.1.3`.

**Validation:** Perl syntax checks PASS; TOOLBOX lowering/runtime probes PASS; phase0 PASS
(`t/phase0_regression.t`, 991 tests); mdBook build PASS; Knowledge Map regenerate/check PASS;
memory/doctrine/diff checks PASS; full local CI PASS.

## 2026-06-29 — SPEC-FORMAT-TERSE.2.1.1 — expression-valued block split

**Scope:** Task tree, roadmap tracker, live continuity docs, and Knowledge Map. No engine, oracle, fixture, or
mdBook behavior changed in this slice.

**Ground truth:** `{}` and `{ key => value }` are already hash shape literals on Perl/Rust. Non-empty brace
payloads without a top-level `=>` are not expression-valued blocks today: Perl lowers
`return({ set(x,"a"); x })` into invalid generated Perl shaped like `return { $x = "a"; x }`, and
`set(out, { ... })` wrongly follows aggregate hash-target inference. Rust has statement `CodeBlock` parsing and
hash/array literal value expressions, but no block-expression AST or runtime evaluator.

**Split:** `.2.1.2` owns the Perl reference core: non-empty non-hash `{ ... }` value payloads in value-consuming
slots, preserving `{}` / `{ key => value }` as hash literals. `.2.1.3` owns Rust parity. `.2.1.4` remains for
full block-local early-return semantics if final-only `return(expr)` is insufficient.

**Validation:** KM retrieval completed; TOOLBOX lowering/runtime/source probes completed; Perl/Rust code-read
completed; Knowledge Map/memory/doctrine/diff checks are the relevant gates for this docs/KM split slice.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.6 — array end-mutation methods

**Scope:** Perl ActionIR lowering/scanning/declaration inference, Rust runtime statement execution, Perl phase0
locks, Rust parser/runtime locks, Perl-oracle corpus fixture, mdBook, Knowledge Map, task tree, roadmap
tracker, and live continuity docs.

**What changed:** The four Round 1 array end-mutation methods are recognized as statement-level mutations on
named working arrays: `items.push_back(value)`, `items.push_front(value)`, `items.pop_back()`, and
`items.pop_front()`. Perl lowers them to `push @items, ...`, `unshift @items, ...`, `pop @items`, and
`shift @items` and reports canonical `ARRAY_MUTATE` ActionIR with no raw fallback. Rust executes the same
receiver-dot statements in `Engine::execute_block()` before generic fluent evaluation.

**Receiver/value rules:** The receiver may be a bare array working variable (`items`) or an explicit
`array(items)` / `a(items)` receiver. Push values use the same mutation-slot expression rules as
`items += value`, so a bare push value reads a scalar working variable. Pop methods discard the removed value.

**Boundary:** These methods are statement-only in this slice. Value-returning forms such as
`return(items.pop_back())` are not part of the accepted contract.

**Validation:** Perl syntax checks PASS; TOOLBOX lowering/runtime/source probes PASS; focused Rust parser and
runtime `.1.6` locks PASS; oracle corpus regenerated to 33 fixtures and corpus oracle PASS; phase0 PASS
(`t/phase0_regression.t`, 990 tests). Existing Cargo warning volume is from the nested `rgx` baseline.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.2.3.5.4 — Rust RHS shape target-kind inference

**Scope:** Rust runtime assignment/helper dispatch, Rust integration locks, Perl-oracle corpus fixtures, mdBook,
Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** Rust now matches the accepted Perl RHS shape target-kind contract. A direct array shape RHS on
a bare assignment target assigns the array working variable (`items = [value]`, `set(items, [])`,
`assign(items, [value])`), and a direct hash shape RHS assigns the hash working variable (`meta = { key =>
value }`, `set(meta, {})`, `assign(meta, { key => value })`). Explicit typed aggregate targets work as the same
target kind (`set(array(items), [value])`, `set(hash(meta), { key => value })`).

**Boundary:** Explicit scalar targets remain the scalar payload boundary. `set(scalar(payload), [value])`
stores the whole array payload in scalar `payload`; it does not initialize array working variable `payload`.
Non-shape RHS values keep the settled scalar assignment rule.

**Validation:** focused Rust runtime `.1.2.3.5.4` locks PASS; oracle corpus regenerated to 32 fixtures and
corpus oracle PASS. Existing warning volume is from the `rgx/subs/pgen` baseline.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.2.3.5.3 — Rust shape-literal value parity

**Scope:** Rust expression AST/parser, Rust runtime evaluation, Rust integration locks, Perl-oracle corpus
fixtures, mdBook, Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** Rust now parses and evaluates the accepted direct shape-literal value-expression contract:
`[]`, `[value, cat("a", "b"), true, []]`, `{ key => value }`, and nested combinations. Array elements, hash
keys, and hash values evaluate through the existing Rust expression path, so primitive literals stay typed,
helpers compose, direct access remains distinct, nested shapes recurse, and bare names read scalar working
variables via `Expr::Variable` / `ctx.get_scalar(name)`. Hash-literal keys use the same `to_str()` key
coercion as `hash(...)`, so `{ key => value }` is dynamic while `{ "fixed" => value }` is fixed.

**Boundary:** This leaf intentionally does not implement Rust RHS target-kind inference. `name = [value]`
still parses as `AssignScalar` and stores the array payload in scalar `name`; `array(name)` remains a separate
working array until `.1.2.3.5.4` mirrors the Perl target-kind contract.

**Validation:** focused Rust parser locks PASS; focused Rust runtime `.1.2.3.5.3` locks PASS; oracle corpus
regenerated to 30 fixtures and corpus oracle PASS. The broad Cargo formatter was not adopted as a gate because
the repository has pre-existing unformatted Rust files outside this slice; unintended rustfmt churn was
reverted.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.2.3.5.2 — Perl RHS shape target-kind inference

**Scope:** Perl ActionIR assignment lowering, declaration initializer shape lowering, auto-working-variable
collection, phase0 regression coverage, mdBook, Knowledge Map, task tree, roadmap tracker, and live continuity
docs.

**What changed:** Direct `[]` / `{}` RHS shape literals now infer aggregate working-variable targets when the
assignment target is bare. `name = []` and `set(name, [value])` assign array working variable `@name`; `name =
{}` and `assign(name, { key => value })` assign hash working variable `%name`. Non-shape RHS values keep the
settled scalar assignment rule (`name = value` reads `$value` and assigns `$name`). Explicit wrappers remain the
boundary: `set(scalar(name), [value])` stores the whole array payload in `$name`, while `set(array(name),
[value])` and `set(hash(name), { key => value })` stay explicit aggregate assignment.

**Adjacent fix:** Typed array/hash declaration initializers that use direct shape literals now lower shape
members through the same DSL value rules as `.1.2.3.5.1`. `declare(array, items=[value, cat("a","b")])`
initializes `@items` with `$value` and the `cat(...)` result; `declare(hash, meta={ key => value, "fixed" =>
[value] })` initializes `%meta` with dynamic `$key`, `$value`, and a nested array payload.

**Boundary:** This is Perl-reference target-kind inference only. Rust still lacks shape-literal value parsing
and target-kind parity; `.1.2.3.5.3` and `.1.2.3.5.4` own those follow-ons. Direct-access brackets,
hash-index assignment brackets, control-flow/block braces, helper-call parsing, primitive literals, and
all-bare child-call routing remain protected.

**Validation:** Perl syntax checks PASS; TOOLBOX lowering/runtime/source probes PASS; phase0 PASS
(`t/phase0_regression.t`, 989 tests); mdBook/KM/memory/doctrine/diff checks PASS; full local CI PASS.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.2.3.5.1 — Perl shape-literal value expressions

**Scope:** Perl ActionIR value lowering, auto-working-variable collection, phase0 regression coverage, mdBook,
Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** The Perl reference now treats direct `[]` / `{}` forms as DSL shape-literal value
expressions instead of raw Perl passthrough. Empty literals still lower to `[]` / `{}`; non-empty literals lower
their direct elements, keys, and values through accepted DSL value-expression rules. This makes `[value]`,
`{ key => value }`, nested shape literals, primitive literals, direct access, and recognized helper calls
compose with the settled scalar bare-read contract. Bare hash-literal keys are dynamic scalar reads, so fixed
field names must be quoted: `{ "kind" => value }`.

**Boundary at this leaf:** `.1.2.3.5.1` did not implement RHS target-kind inference; `.1.2.3.5.2` later
accepted aggregate target inference for direct RHS shapes. Direct-access brackets, hash-index assignment
brackets, future control-flow/block braces, helper-call parsing, primitive literals, and all-bare child-call
routing remain protected. Rust parity for direct shape literals is still tracked by `.1.2.3.5.3`.

**Validation:** Perl syntax checks PASS; TOOLBOX lowering/runtime/source probes PASS; phase0 PASS
(`t/phase0_regression.t`, 988 tests, including the new 19-assertion lock); mdBook updated.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.2.3.5 — RHS-shape/type-inference split

**Scope:** task tree, task-tree index, roadmap/live continuity docs, and Knowledge Map. No engine, fixture, or
mdBook behavior change.

**Ground truth:** At split time, Perl already passed empty `[]` and `{}` through as raw arrayref/hashref value expressions in
scalar/value slots: `return([])`, `name = []`, `items += []`, `set(out,{})`, and `meta[key] = {}` lower to
valid Perl. That does not mean RHS target-kind inference exists: `name = []` assigns scalar `$name`, while
`items += ...` mutates a distinct `@items`; likewise `$meta` and `%meta` are separate slots. Non-empty shapes
such as `[value]` and `{ key => value }` passed through raw Perl at split time, so bare identifiers became Perl
barewords/strings instead of the settled scalar working-variable reads before `.1.2.3.5.1`. Rust does not parse
`[` or `{` as a value-expression starter yet.

**Split:** `.1.2.3.5` is now a completed split container. The new frontier is `.1.2.3.5.1` Perl
shape-literal value expressions, followed by `.1.2.3.5.2` Perl RHS target-kind inference, `.1.2.3.5.3` Rust
shape-literal parity, and `.1.2.3.5.4` Rust target-inference parity.

**Validation:** KM/TOOLBOX/source/runtime/code-read probes completed; Knowledge Map, memory/doctrine, and diff
checks are run for the slice. Phase0/Rust runtime/local CI are N/A unless the final gate is run, because this
slice changes only docs/tree/KM continuity surfaces.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.2.3.4 — Rust scalar bare-read parity

**Scope:** Rust parser scalar bare-read reservations, Rust integration locks, Perl-oracle corpus fixtures,
task tree, roadmap/live continuity docs, and Knowledge Map.

**What changed:** Rust now accepts the scalar bare-read contract already landed on the Perl reference:
source-slot reads (`return(value)`, `set(out, value)`, `name = value`), mutation key/RHS reads
(`items += value`, `set_key(meta, key, value)`, `meta[key] = value`), and direct-access bare path atoms
(`foo["a"][idx]`). Runtime evaluation already treated `Expr::Variable` as a scalar working-variable read via
`ctx.get_scalar(name)`, so the implementation removes obsolete parser reservations and locks the behavior.

**Boundary:** this does not add RHS-shape `[]`/`{}` inference, expression-valued blocks, generic helper-argument
broadening, or any change to the all-bare `push(A,B)` child-call convention. The remaining Channel 2
RHS-shape/type-inference work is now tracked as `SPEC-FORMAT-TERSE.1.2.3.5`.

**Validation:** focused Rust parser tests PASS; focused Rust runtime `.1.2.3.4` tests PASS; oracle corpus
regenerated to 28 fixtures and corpus oracle PASS; mdBook build PASS; Knowledge Map, memory/doctrine/diff
checks PASS; full local CI PASS.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.2.3.3.3 — direct-access bare path atoms

**Scope:** Perl ActionIR direct nested-access value lowering, auto-working-variable collector, phase0 regression
coverage, mdBook, Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** Perl now treats a non-reserved bare atom inside a direct-access bracket path as a scalar
working-variable array index. `foo["a"][z]` lowers identically to `foo["a"][scalar(z)]` as
`$foo->{"a"}->[$z]`, and the collector auto-supplies one per-invocation `my $z` for accepted direct-access
source/mutation value slots.

**Boundary:** quoted path segments remain hash keys, and numeric/helper path segments remain array indexes.
Primitive literals and engine locals such as `true` and `CAPTURE` are not claimed as scalar path variables.
`scalaref(...)` keeps its historical path semantics; write `[scalar(z)]` there when a path index should read a
working scalar. RHS-shape `[]`/`{}` inference is still later, and all-bare `push(A,B)` remains child-call
syntax.

**Validation:** Perl syntax checks PASS; TOOLBOX lowering probes PASS; phase0 PASS
(`t/phase0_regression.t`, 987 tests, including the new 18-assertion lock); mdBook build PASS; Knowledge Map,
memory/doctrine/diff checks PASS; full local CI PASS.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.2.3.3.2 — scalar mutation-slot bare reads

**Scope:** Perl ActionIR mutation-slot lowering, scanner contracts, auto-working-variable collector,
phase0 regression coverage, mdBook, Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** Perl now treats non-reserved bare identifiers as scalar working-variable reads in the scoped
mutation slots owned by this leaf: array append RHS (`items += VALUE`), statement-level named-hash mutation
key/RHS (`set_key(meta, KEY, VALUE)`), and hash-index operator key/RHS (`meta[KEY] = VALUE`). Each newly sigiled
read gets one per-invocation `my $NAME` unless already declared/wrapped.

**Boundary:** target inference is unchanged (`items` still auto-exists as `@items`; `meta` still auto-exists as
`%meta`). Primitive literals remain exact, reserved engine locals such as `CAPTURE` are not claimed, direct
access bare path atoms such as `foo["a"][z]` remain deferred, and all-bare `push(A,B)` / `push(items,value)`
remain child-call syntax rather than append syntax.

**Validation:** Perl syntax checks PASS; TOOLBOX lowering probes PASS; phase0 PASS
(`t/phase0_regression.t`, 986 tests, including the new 29-assertion lock); mdBook build PASS; Knowledge Map,
memory/doctrine/diff checks PASS; full local CI PASS.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.2.3.3.1 — scalar source-slot bare reads

**Scope:** Perl ActionIR return/source lowering, auto-working-variable collector, phase0 regression coverage,
mdBook, Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** Perl now treats bare identifiers as scalar working-variable reads in the scoped source slots
owned by this leaf: `return(NAME)`, `set(out, NAME)` / `assign(out, NAME)`, and scalar operator `out = NAME`.
Each newly sigiled read gets one per-invocation `my $NAME` unless it is already declared/wrapped. Primitive
literals remain exact (`true`/`false`/`undef` are not variables), while prefix identifiers such as `trueword`
and `undefine` are ordinary scalar reads in these source slots.

**Boundary at this leaf:** this did not broaden generic helper arguments, array append RHS, hash mutation
key/RHS slots, direct-access bare path atoms, or all-bare child-call syntax. The mutation key/RHS subset was
advanced by `.1.2.3.3.2`; direct path atoms remain separate.

**Validation:** Perl syntax checks PASS; TOOLBOX lowering probes PASS; generated-source/runtime no-leak probe
PASS; phase0 PASS (`t/phase0_regression.t`, 985 tests, including the new 24-assertion lock); mdBook build PASS;
Knowledge Map, memory/doctrine/diff checks PASS; full local CI PASS.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.2.3.3 — split scalar bare reads by lowering seam

**Scope:** task tree, task-tree index, roadmap/live continuity docs, Knowledge Map card + generated map. No
engine, test fixture, or mdBook behavior change.

**Ground truth:** Perl scalar bare-read work is not one implementation seam. Return and assignment-like source
slots still emit raw barewords (`return(count)` -> `return count`, `set(out,count)` -> `$out = count`,
`name = value` -> `$name = value`). Mutation slots are mixed: `set_key(meta,key,"v")` already lowers the bare
key as `$key`, but bare values stay raw; array append and hash-index operator forms reject bare RHS/key tokens
before lowering. Direct access has its own guard: `foo["a"][z]` remains raw while `foo["a"][scalar(z)]` lowers.
The all-bare child-call form `push(A,B)` still lowers as child-call syntax and must stay protected.

**Split:** `.1.2.3.3` is now an active container. Its first children are `.1.2.3.3.1` (return/assignment source
slots), `.1.2.3.3.2` (mutation key/RHS scalar slots), and `.1.2.3.3.3` (direct-access bare path atoms).
RHS-shape `[]`/`{}` syntax remains later.

**Validation:** TOOLBOX lowering probes PASS; Knowledge Map regenerate/check PASS; memory/doctrine checks PASS;
`git diff --check` PASS. Phase0/Rust runtime/local CI are N/A to this docs/tree/KM split slice because no
behavior changed.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.2.3.2 — Rust aggregate bare value-read parity

**Scope:** Rust runtime aggregate-copy target resolution, Rust integration locks, Perl-oracle corpus fixtures,
Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** Rust now resolves aggregate bare value-read snapshot forms the same way the Perl reference does.
`array_copy(NAME)` and array-first `copy(NAME)` read array working variable `NAME`; `hash_copy(NAME)` reads hash
working variable `NAME`; `copy(hash(NAME))` remains the explicit wrapped hash-copy path. The change is confined
to the aggregate resolver call sites for `array_copy`, `hash_copy`, and `copy`; it does not change generic
`Expr::Variable` evaluation, parser grammar, scalar bare reads, bare hash-index key/RHS reads, or bare
direct-access path atoms.

**Validation:** focused Rust integration locks PASS for bare array snapshot, bare hash snapshot, array-first
`copy(NAME)`, wrapped hash copy, and per-execute isolation; focused Rust parser rejection for bare direct-access
segments PASS; oracle corpus regenerated to 25 fixtures and corpus oracle PASS; full Rust runtime suite PASS
(116 unit tests, 25 oracle fixtures, 54 integration tests, doc-tests); clippy EXIT 0 with the existing warning
baseline; phase0, mdBook, Knowledge Map, memory/doctrine/diff checks, and full local CI PASS.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.2.3.1 — auto-exist aggregate bare value reads

**Scope:** Perl ActionIR auto-working-variable collector, phase0 regression coverage, mdBook helper/declaration
wording, Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** aggregate bare value reads that already lowered to sigiled Perl aggregate variables now get the
same per-invocation lexical protection as earlier auto-existence surfaces. The collector records
`array_copy(NAME)` and array-first `copy(NAME)` as `my @NAME`, and `hash_copy(NAME)` as `my %NAME`, using the same
literal masking, reserved-name guard, and dedup path as wrapped/declared/mutation forms.

**Boundary:** this is not the scalar Channel 2 leaf. `return(NAME)`, scalar RHS/key reads such as
`items += value` / `meta[key] = value`, and bare direct-access atoms such as `[z]` remain deferred. Rust parity for
the aggregate read forms is the next child, `.1.2.3.2`.

**Validation:** Perl syntax checks PASS; focused generated-source/runtime/no-leak probe PASS for
`array_copy(items)`, `hash_copy(meta)`, and `copy(items)`; full phase0 PASS (`t/phase0_regression.t`, 984 tests,
including the new 17-assertion subtest); mdBook build PASS; Knowledge Map regenerate/check PASS;
memory/doctrine/diff checks PASS; full local CI PASS.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.2.3 — split Channel 2 value reads by aggregate/scalar surfaces

**Scope:** task tree, task-tree index, roadmap/live continuity docs, Knowledge Map card + generated map. No
engine, test fixture, or mdBook behavior change.

**Ground truth:** Channel 2 is not one implementation seam. Perl aggregate bare value reads already lower to
sigiled variables: `array_copy(items)` -> `[@items]`, `hash_copy(meta)` -> `{%meta}`, and `copy(items)` ->
`[@items]`; generated source shows those forms do not get `my @items` / `my %meta`, so they still carry the
same non-strict package-global hazard as earlier auto-existence work. Rust deliberately keeps bare aggregate
value reads out of aggregate-copy resolvers. Scalar-like value reads remain separate: Perl still emits
bareword/raw forms for `return(count)`, `set(out,count)`, `items += value`, `meta[key] = value`, and
`foo["a"][z]`, while Rust already evaluates `Expr::Variable` as a scalar read.

**Split:** `.1.2.3` is now an active container. First children are `.1.2.3.1` (Perl aggregate bare value-read
auto-existence) and `.1.2.3.2` (Rust parity for that aggregate surface), followed by `.1.2.3.3` (Perl scalar
bare value reads) and `.1.2.3.4` (Rust parity for scalar reads). RHS-shape `[]`/`{}` syntax remains later.

**Validation:** TOOLBOX lowering/source probes PASS; Knowledge Map regenerate/check PASS; memory/doctrine
checks PASS; `git diff --check` PASS. Phase0/Rust runtime/local CI are N/A to this docs/tree/KM split slice
because no behavior changed.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.5.5.2 — merge bare direct access into Channel 2

**Scope:** task tree, task-tree index, roadmap/live continuity docs, Knowledge Map card + generated map. No
engine, test fixture, or mdBook behavior change.

**Ground truth:** after explicit direct access landed, TOOLBOX reverify still shows the same Channel 2
boundary: `return(foo["a"][9]["b"][scalar(z)])` lowers to `$foo->{"a"}->[9]->{"b"}->[$z]`, but
`return(foo["a"][9]["b"][z])` remains raw and `return(z)` remains a bareword. Rust keeps a focused parser lock
that rejects bare direct-access segments as Channel 2-reserved.

**Decision:** `.1.5.5.2` is superseded/merged into new `.1.2.3`. Bare direct-access path atoms must be defined
with the global value-position bare-word-read model, together with bare RHS/key expressions and RHS-shape/type
inference, instead of as a direct-access-local exception.

**Validation:** TOOLBOX reverify PASS; focused Rust parser rejection lock PASS; Knowledge Map
regenerate/check PASS; memory/doctrine checks PASS; `git diff --check` PASS. Phase0/Rust runtime/local CI are
N/A to this docs/tree/KM coordination slice because no behavior changed.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.5.5.1 — implement direct nested access explicit segments

**Scope:** Perl ActionIR value lowering, Rust action-code expression parser/runtime, Perl/Rust/oracle tests,
mdBook, Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** direct mixed nested access now works when every path segment is explicit. Perl lowers
`foo["a"][9]["b"][scalar(z)]` to the same dereference chain as the settled `scalaref(...)` form:
`$foo->{"a"}->[9]->{"b"}->[$z]`. Quoted string segments are hash keys; numeric and helper/value-expression
segments are array indexes. Single-quoted string segments are hash keys too.

**Rust parity:** Rust core gained `AccessSegment` and `Expr::NestedAccess`; mixed or multi-segment direct
paths parse as nested access, while a single non-key `name[index]` remains the legacy indexed-variable form.
The runtime walks the scalar-held base payload through hash-key and array-index segments.

**Boundary:** bare path atoms such as `[z]` remain out of scope and are still owned by `.1.5.5.2` / Channel 2
value-position reads. `scalaref(base,path)` remains accepted; direct access is a new explicit form, not a
retirement of the helper.

**Validation:** Perl syntax checks PASS; focused Rust parser/runtime tests PASS; oracle corpus regenerated
with 21 fixtures and Rust corpus oracle PASS; full phase0, Rust runtime suite, mdBook, Knowledge Map,
memory/doctrine, diff, and local CI gates are recorded in the task tree close-out.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.5.5 — split direct access by Channel 2 boundary

**Scope:** task tree, task-tree index, Knowledge Map card + generated map, roadmap/live continuity docs. No
engine, test fixture, or mdBook behavior change.

**Ground truth:** direct bracket access is not yet a valid lowered value expression. TOOLBOX probes show
`return(foo["a"][9]["b"][scalar(z)])` passes through as invalid Perl-shaped
`return foo["a"][9]["b"][$z]`, and a generated-source/runtime probe confirms handler compilation fails near
`][`. The existing explicit helper remains the working path:
`return(scalaref(foo,{"a"}[9]{"b"}[scalar(z)]))` lowers to `$foo->{"a"}->[9]->{"b"}->[$z]`.

**Split:** `.1.5.5.1` owns direct nested access with explicit path segments such as
`foo["a"][9]["b"][scalar(z)]`. `.1.5.5.2` owns the bare path-segment / Channel 2 coordination required for the
full brainstorm spelling `foo["a"][9]["b"][z]`.

**Validation:** Knowledge Map regenerate/check PASS; memory/doctrine checks PASS; `git diff --check` PASS.
Phase0/Rust/local CI are N/A to this docs/tree/KM split slice because no behavior changed.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.5.4 — lock statement separator contract

**Scope:** Perl ActionIR statement splitting/lowering, Bootstrap fluent attached-control normalization, Rust
parser/runtime locks, oracle corpus, mdBook, Knowledge Map, task tree, roadmap tracker, and live continuity
docs.

**What changed:** newlines are now the implicit separator between top-level canonical DSL statements. Perl
lowering inserts a generated Perl terminator when two canonical statements were separated by a newline rather
than an author semicolon, so `set(name,"a")` followed by `return(scalar(name))` compiles and runs correctly.
Semicolons remain accepted and are still required when multiple statements share one physical line.

**Boundary:** plain same-line whitespace is not a statement separator. Same-line adjacent helpers such as
`set(name,"a") return(scalar(name))` stay raw/non-canonical blockers, matching the Rust parser's same-line
rejection. Semicolons inside nested expressions or literal payloads remain protected. Fluent attached-control
tails such as `Top.if(...) { ... } elseif(...) { ... } else { ... }` are normalized internally with newline
boundaries so the user-facing attached-control surface stays supported without weakening same-line adjacency
rules for ordinary helper statements.

**Validation:** `env PERL5LIB= prove -q -Iperl t/phase0_regression.t` PASS (`1..982`); oracle corpus
regenerated with 20 fixtures including `terse_1_5_4_newline_statements`; focused Rust parser/runtime `.1.5.4`
tests PASS; Rust corpus oracle PASS over 20 fixtures; full Rust runtime suite PASS; `mdbook build
docs/linkedspec-book` PASS; Knowledge Map/memory/doctrine checks PASS; `git diff --check` PASS; `bash
tools/run_ci_local.sh` PASS.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.5.3 — lock call spacing and mandatory parentheses

**Scope:** Perl phase0 locks, Rust parser/runtime locks, oracle corpus, mdBook, Knowledge Map, task tree,
roadmap tracker, and live continuity docs. No production lowerer change was needed: this leaf freezes already
supported call-spacing behavior and the no-parentheses boundary.

**What changed:** helper calls keep the uniform `callee(args)` grammar. Optional whitespace before the opening
parenthesis is accepted at supported statement and value-expression sites, including `return (value)`,
`set (name, value)`, nested helpers such as `cat ("a","b")` and `scalar (name)`, array-append RHS calls, and
hash-index key/RHS calls.

**Boundary:** the leaf deliberately does not introduce no-parenthesis helper calls. Forms such as
`set name,"v"`, `return scalar name`, and `return(cat "a","b")` remain outside the helper-call surface. This
keeps call recognition distinct from the later statement-separator and Channel 2 bare-value-read work.

**Validation:** `env PERL5LIB= prove -q -Iperl t/phase0_regression.t` PASS (`1..981`); oracle corpus
regenerated with 19 fixtures; focused Rust parser/runtime `.1.5.3` tests PASS; Rust corpus oracle PASS over 19
fixtures; broader gates recorded in the task tree close-out.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.5.2 — implement primitive literal parity

**Scope:** Perl ActionIR literal lowering/scanners/legacy push disambiguation, Rust statement-form flow
gating, phase0/Rust/oracle locks, mdBook, Knowledge Map, task tree, roadmap tracker, and live continuity docs.

**What changed:** primitive literals are now explicit typed value expressions across the terse surface:
quoted strings, numbers, `undef`, `true`, and `false` work in return payloads, assignments, appends,
hash-index keys/values, and flow predicates. Perl now lowers `true`/`false` to `JSON::PP` boolean values
instead of bareword strings, with exact matching so `trueword` and `undefine` remain identifiers. Scanner and
legacy child-call guards now agree that `push(items,false)` is a value append, not `push(rule,target)`.

**Rust parity:** Rust already had typed primitive value expressions, but statement-form
`if(false); ... else(); ... endif()` previously did not gate lifecycle statements. The runtime now keeps a
statement-form conditional stack for one-arg `if`/`elseif` and zero-arg `else`/`endif`; multi-arg
`if(cond,then,else)` remains the existing lazy value helper.

**Boundary:** no Channel 2 bare value-position reads, no direct nested access, no call-spacing broadening, and
no statement-separator change landed here. A pre-existing Rust nested-hash-constructor flattening limitation is
not part of this leaf; the parity fixture returns `[flag, items, hash]` to keep the proof scoped.

**Validation:** `env PERL5LIB= prove -q -Iperl t/phase0_regression.t` PASS (`1..980`);
`perl -Iperl tools/gen_oracle_corpus.pl` regenerated 18 fixtures; focused Rust `.1.5.2` tests PASS; Rust
corpus oracle PASS over 18 fixtures; broader gates recorded in the task tree close-out.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.5 — split literals/access/call/separator surface

**Scope:** task tree, task-tree index, ROADMAP_V2, Knowledge Map card + generated map, and live continuity
docs. No engine, test fixture, or mdBook behavior change.

**Ground truth:** `.1.5` crosses independent seams. Perl currently lowers/runs string, numeric, and `undef`
literal returns, but `true` and `false` execute as the strings `"true"` and `"false"`; Rust already parses
them as typed booleans. Optional whitespace before call parentheses works at real helper/value sites such as
`return (x)`, `set (name,x)`, `cat ("a","b")`, and `scalar (name)`, but still needs focused locks. The
statement splitter recognizes adjacent top-level DSL statements, yet Perl lowering emits invalid generated
Perl when newline-separated lowered statements lack `;`; Rust currently accepts broader whitespace-separated
statements. Direct any-depth `foo["a"][9]['b'][z]` is not lowered on Perl, and Rust only has single
array-index `IndexedVar`, so direct mixed access must coordinate with Channel 2 value-position bare-word reads.

**Outcome:** `.1.5` is now an active container. `.1.5.1` closes the audit/split, and the current frontier is
`.1.5.2` primitive literal parity, followed by call-spacing locks, separator semantics, and direct nested
access.

**Validation:** KM retrieval first; TOOLBOX `call_spec_handler_subst`, `LinkedSpec::Get`, and
`StatementSplit` probes; Perl/Rust code-read; focused Rust parser tests (`parse_` and `hash_index`) pass
with existing rgx/pgen warning noise. `knowledge-map/scripts/check_knowledge_map.sh`,
`scripts/check_memory_architecture.sh`, `scripts/check_doctrines.sh`, and `git diff --check` all pass.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.3.4.3 — implement hash-index assignment operator name[key] = value

**Scope:** Perl ActionIR contract/scanner/lowering/autodeclaration, Rust expression parser/runtime execution,
phase0 locks, Rust parser/runtime tests, oracle corpus, mdBook, Knowledge Map, task tree, roadmap tracker, and
live docs.

**What changed:** top-level `name[key] = value` is now the terse hash-index assignment operator for explicit
key and value expressions. It lowers and runs identically to the settled statement mutation form
`set_key(name, key, value)`. Perl emits direct `$name{key} = value` mutation and auto-supplies one `my %name`
preamble for a bare hash target; Rust parses it as statement-only `AssignHashIndex` and mutates the per-parse
hash map with the evaluated string key.

**Boundary:** this leaf deliberately preserves the Channel 2 boundary. `meta["stage"] = "v"`,
`meta[cat("s","tage")] = cat("v","!")`, and `meta[scalar(key)] = scalar(value)` work; bare key or RHS forms
such as `meta[key] = "v"` and `meta["stage"] = value` remain reserved until bare value-position reads land.
Nested hash-index assignment is statement-only, and value-form `set_key(hash_expr, key, value)` remains pure.

**Validation:** TOOLBOX lowerings prove the accepted operator shapes lower like `set_key(...)` while bare
key/RHS boundaries remain unchanged; phase0 PASS (`1..979`); oracle corpus regenerated with 16 fixtures;
focused Rust core/runtime tests PASS; full Rust runtime suite PASS (116 unit + corpus-oracle harness + 45
integration tests); mdBook, Knowledge Map, memory-architecture, doctrine, `git diff --check`, and
`tools/run_ci_local.sh` gates pass.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.3.4.2 — implement array append operator items += value

**Scope:** Perl ActionIR contract/scanner/lowering/autodeclaration, Rust expression parser/runtime execution,
phase0 locks, Rust parser/runtime tests, oracle corpus, mdBook, Knowledge Map, task tree, roadmap tracker, and
live docs.

**What changed:** top-level `items += value` is now the terse array append operator for explicit value
expressions. It lowers and runs identically to the settled explicit append forms `push(items, value)` /
`push_value(items, value)`. Perl emits the same direct `push @items, ...` and auto-supplies one `my @items`
preamble for a bare array target; Rust parses it as a statement-only `AssignArrayAppend` and appends the
evaluated RHS into the per-parse array map.

**Boundary:** this leaf deliberately preserves the `.1.3.2` and Channel 2 boundaries. `items += scalar(value)`
works; `items += value` is still reserved because bare value-position working-variable reads are not landed.
Child-call `push(A,B)`, increment-like `items ++`, scalar `name = value`, and hash-index `name[key] = value`
remain separate semantics.

**Validation:** TOOLBOX lowerings prove `items += "a"`, `items += cat(...)`, and `items += scalar(label)` lower
like the explicit append forms while `items += value` remains unchanged; descriptor/source/runtime probes show
`PUSH,RETURN`, fallback count 0, one array declaration, and stable parser output. `prove -q -Iperl
t/phase0_regression.t` PASS (`1..978`); oracle corpus regenerated with 15 fixtures; focused Rust core/runtime
tests PASS; Rust corpus oracle PASS over 15 fixtures; full Rust runtime suite PASS (116 unit + corpus-oracle
harness + 43 integration tests); mdBook, Knowledge Map, memory-architecture, doctrine, and local CI gates
recorded in the close-out.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.3.4.1 — implement scalar assignment operator name = value

**Scope:** Perl ActionIR contract/scanner/lowering/autodeclaration, Rust expression parser/runtime execution,
phase0 locks, Rust parser/runtime tests, oracle corpus, mdBook, Knowledge Map, task tree, roadmap tracker, and
live docs.

**What changed:** top-level `name = value` is now the terse scalar assignment operator. It lowers and runs
identically to `set(name, value)` / `assign(name, value)`. Perl emits the same scalar assignment and
auto-supplies one `my $name` preamble for a bare target; Rust parses it as a statement-only `AssignScalar` and
stores the evaluated RHS in the per-parse scalar map.

**Boundary:** this leaf intentionally does not claim equality (`name == value`), array append (`items += value`),
hash-index assignment (`name[key] = value`), helper keyword args (`helper(name=value)`), nested assignments, or
Channel 2 bare value-position reads.

**Validation:** TOOLBOX lowerings prove `name = cat(...)` is byte-identical to `set(name, cat(...))` while the
out-of-scope operator shapes remain unchanged; descriptor/source/runtime probes show `ASSIGN,RETURN`, fallback
count 0, one scalar declaration, and stable parser output. `prove -q -Iperl t/phase0_regression.t` PASS
(`1..977`); oracle corpus regenerated with 14 fixtures; focused Rust core/runtime tests PASS; full Rust runtime
suite PASS (116 unit + corpus-oracle harness + 41 integration tests); mdBook, Knowledge Map, memory-architecture,
doctrine, and local CI gates pass.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.3.4 — split operator syntax family into scalar, array, and hash leaves

**Scope:** task tree, task-tree index, ROADMAP_V2, Knowledge Map card + generated map, and live continuity
docs. No engine, test, fixture, or mdBook behavior change.

**Ground truth:** the three operator spellings are still new syntax. `call_spec_handler_subst` leaves
`name = "ok"`, `items += "a"`, and `name["k"] = "v"` unchanged, while the settled function forms
`set(name,"ok")`, `push(items,"a")`, and `set_key(name,"k","v")` lower correctly. A descriptor probe over all
three operators reports three `RAW_PERL` fallback events and three language-agnostic blocker statements. Rust
currently parses lifecycle code as `Stmt { expr }` only; there are no assignment, append, or hash-set statement
variants in the AST/runtime execution path.

**Tree update:** `.1.3.4` is now a container. `.1.3.4.1` owns scalar `name = value` first, `.1.3.4.2` owns
array `items += value`, and `.1.3.4.3` owns hash `name[key] = value`. The next frontier is `.1.3.4.1`.

**Validation:** KM retrieval and TOOLBOX probes recorded in the task tree; `scripts/check_doctrines.sh` and
`scripts/check_memory_architecture.sh` pass. Full phase0/cargo/mdBook gates are not applicable to this
docs-only split beyond the doctrine/KM checks.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.3.3 — implement set_key(name,key,value) hash mutation statement

**Scope:** Perl ActionIR contract/scanner/lowering/autodeclaration, Rust runtime statement execution, phase0
locks, Rust integration tests, oracle corpus, mdBook, Knowledge Map, task tree, ROADMAP_V2, and live docs.

**What changed:** top-level `set_key(name, key, value)` is now the terse named-hash mutation statement. It
mutates the working hash named by the first argument and auto-exists a bare target as `%name` on the Perl
reference. Nested/value-form `set_key(hash_expr, key, value)` remains the existing pure copy-valued helper; it
returns a new hash value and does not mutate the source hash unless the caller stores it back.

**Implementation:** Perl adds a `set_key_statement` ASSIGN contract, scanner event, and lowering path that emits
direct `$name{key} = value` mutation for statement-level calls, plus bare-target `%name` collection in
`RuleIR::EmitContext`. Rust executes top-level `set_key(...)` in `Engine::execute_block()` before normal
expression evaluation, using `RuntimeContext::set_hash_entry`, while leaving `Engine::call_helper("set_key")`
as the pure value helper.

**Validation:** TOOLBOX lowerings distinguish mutation from pure value form; descriptor/source/runtime probes
prove ASSIGN recognition, one `my %meta` declaration, same-parser stability, and non-mutating nested pure
behavior. `prove -q -Iperl t/phase0_regression.t` PASS (`1..976`); focused Rust `terse_1_3_3` tests PASS;
corpus oracle PASS over 13 fixtures; `mdbook build docs/linkedspec-book` EXIT 0; Knowledge Map,
memory-architecture, doctrine checks, and `bash tools/run_ci_local.sh` EXIT 0.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.3.2 — recognize push(target,value) explicit append while preserving child-call push

**Scope:** Perl reference ActionIR recognition/lowering, Perl phase0 locks, Rust oracle + integration locks,
mdBook, task tree, Knowledge Map card + generated map, live docs. No Rust engine change: Rust already had the
`"push_value" | "push"` runtime alias, and this slice locks it against the Perl reference contract.

**What changed:** `push(target, value)` is now the terse explicit-value append spelling when the value
expression is unambiguous/non-all-bare. It lowers identically to `push_value(target, value)` for values such as
string literals, `scalar(value)`, helper expressions like `cat(...)`, wrapped targets/values, and `call(Child)`.
All-bare forms keep the existing child-call convention: `push(A, B)` still means "call child rule `A` and append
into accumulator `B`". To append a working-variable value, use `push(items, scalar(value))` or
`push_value(items, scalar(value))` until Channel 2 bare value-position reads land.

**Implementation:** Perl `ActionIR/Contracts.pm`, `Scanner/PrimitivePipelineRules.pm`, and
`ActionIR/MethodLowering.pm` accept `push` through the `push_value` statement path only for the unambiguous
two-arg shape. `RuleIR/EmitContext.pm` uses a balanced parser-backed scan for `push(...)` target auto-decls so
nested comma values such as `cat("a","b")` still declare exactly one `my @items`.

**Validation:** TOOLBOX lowerings prove explicit append vs child-call precedence; descriptor/runtime
probe returns `["a","b"]` with zero fallback/unresolved; source dump for nested/comma value has one `my @items`;
`prove -q -Iperl t/phase0_regression.t` PASS (`1..975`); focused Rust test
`terse_1_3_2_push_alias_matches_push_value` PASS; corpus oracle PASS over 12 fixtures; `mdbook build
docs/linkedspec-book` EXIT 0; `knowledge-map/scripts/check_knowledge_map.sh` OK; `scripts/check_memory_architecture.sh`
OK; `bash tools/run_ci_local.sh` EXIT 0 (`phase0` 975, local CI gate passed).

## 2026-06-29 — SPEC-FORMAT-TERSE.1.3 — split mutation surface by mechanism; record push/operator ground truth

**Scope:** task tree, task-tree index, Knowledge Map fact card + generated map, live docs. No engine, test,
fixture, or mdBook behavior change.

**Ground truth:** `.1.3` cannot be one signoff implementation slice:
- `set(name, "ok")` is already satisfied by `.1.4`: it lowers byte-identically to `assign(name, "ok")` and runs.
- `push_value(items, "a")` lowers/runs today, but requested `push(items, "a")` passes through Perl as raw
  `push(items, "a")`, fails handler compilation, and collides with the existing child-call convention
  `push(Rule[, target[, index]])`.
- `set_key(name, "k", "v")` works in Perl as a pure hash-valued expression in return/source paths, but not as
  a standalone mutation statement; Rust only changes a hash when arg0 already evaluates to a hash.
- `name = "ok"`, `items += "a"`, and `name["k"] = "v"` pass through as invalid/raw Perl; Rust's `CodeBlock`
  AST has no assignment or plus-equals statement form.

**Tree update:** `.1.3` is now a container. `.1.3.1` scalar function-form audit is done by prior `.1.4`
evidence; `.1.3.2` is next (array function spelling disambiguation before code); `.1.3.3` owns hash mutation
semantics; `.1.3.4` owns operator syntax. KM card `terse-mutation-surface-ground-truth` added.

## 2026-06-29 — SPEC-FORMAT-TERSE.1.4.2 — Rust recognize terse helper renames (engine + oracle + integration locks)

**Scope:** Rust runtime engine (`rust/linkedspec-runtime/src/engine.rs`), Rust integration tests, oracle corpus
generator + 2 generated fixtures, task tree/live docs/KM card. No Perl engine or mdBook behavior change.

**What changed:** `Engine::call_helper()` now recognizes the helper-renames that `.1.4.1` made canonical on
the Perl reference:
- `set` dispatches through the existing `assign` arm.
- `cat` dispatches through the existing `concat` arm.
- `copy` has its own unified array/hash value-copy arm: materialized arrays and hashes clone directly; wrapped
  array targets use `resolve_array_target(..., false)`; wrapped hash targets use the new `resolve_hash_target`.
- `hash`/`h` with one bare variable now returns the named runtime hash, so `copy(h(m))` and `hash_copy(h(m))`
  converge. Bare value-position reads remain deferred to Channel 2.

**Validation:** added oracle fixtures `terse_1_4_2_set_cat_copy_array` and
`terse_1_4_2_copy_hash_symbol_empty`, plus 3 Rust integration tests for `set`+`cat`+`copy(array)`, hash target
and hash value copy, and per-parse bare `set` target semantics. `perl -c tools/gen_oracle_corpus.pl` OK;
oracle regeneration OK; focused `terse_1_4_2` tests PASS; corpus oracle PASS over 11 fixtures; full Rust
runtime suite PASS (116 unit + 36 integration + corpus-oracle harness); `cargo clippy` EXIT 0 with only the
existing 13-warning baseline; `perl -Iperl t/phase0_regression.t` PASS (`1..975`); `bash tools/run_ci_local.sh`
EXIT 0.

**Docs:** no mdBook change: `.1.4.1` already documented the variant-neutral helper contract; this slice makes
Rust conform. Task-tree/live docs/KM updated. `.1.4` container is now done; next frontier is `.1.3`.

## 2026-06-24 — SPEC-FORMAT-TERSE.1.4.1 — Perl recognize terse renames set/cat/copy lowering identically to assign/concat/array_copy+hash_copy (engine + book + 4 phase0 locks)

**Scope:** Perl reference engine (8 modules under `perl/LinkedSpec/`), `t/phase0_regression.t` (+4 subtests),
3 mdBook pages, task tree, KM card. The terse helper renames ratified in ADR 0007 become recognized on the
Perl reference: `set`≡`assign`, `cat`≡`concat`, and a unified `copy`≡`array_copy`/`hash_copy`. New names are
canonical; old names stay deprecated (not-yet-retired) aliases that lower **byte-identically**.

**What changed (recognized the aliases at EVERY site each canonical name is recognized, not just the headline
seam — driven by `call_spec_handler_subst` probes that exposed composed-position divergences):**
- `ActionIR/MethodExpr.pm` — `_normalize_method_name` now maps `cat`→`concat` and `set`→`assign` (parse-time
  alias seam, alongside `s`/`a`/`h`).
- `ActionIR/Contracts.pm` — the `assign_value` statement contract's recognition extended
  `\bassign\s*\(`→`\b(?:assign|set)\s*\(` (raw text runs before name normalization).
- `ActionIR/Scanner/PrimitivePipelineRules.pm` — `_scan_contract_assign_value` IR-event scanner extended the
  same way, so `set` produces the same `ASSIGN` canonical ActionIR node as `assign`.
- `RuleIR/EmitContext.pm` — the `.1.2.1` bare-arg auto-`my` collector now also scans `set`, so a bare
  `set(name, …)` target auto-exists as a per-invocation `my $name` exactly like `assign`.
- `ActionIR/MethodLowering.pm` — a dedicated `copy` dispatch in `_lower_method_value_expr` resolves
  array-vs-hash by the wrapped symbol kind (array first → `[@x]`, else hash → `{%x}`); `copy`/`cat` added to
  the return-payload guard + rewriter helper lists; the four `looks_like_{array,hash}_value_expr` recognizers
  resolve `copy(X)`'s kind (array-first) so `copy` stays first-class in numeric-reducer / `coalesce` type
  inference.
- `ActionIR/DeclareMethod.pm` — `copy` accepted in the array (136) and hash (163) declare/assign-initializer
  recognizers (target type disambiguates; lowers to the same `(@x)` / `(%x)` list-init forms).
- `ActionIR/FlowExpr.pm` — `cat`/`copy` added to the value-expr prefix list (assignment-source path) and the
  two flow `looks_like` recognizers resolve `copy`'s kind.
- `BootstrapSpec/Core.pm` — `cat` added to the general-return-payload gate.

**Validation:** `call_spec_handler_subst` byte-equal for the 4 headline forms AND 11 composed forms
(scalar/array/hash assignment source, push value, nested return payload, `num_sum`/`num_avg`/`coalesce` over
`copy`); `return_descriptor` shows `set`==`assign` ASSIGN node; a real terse spec (`set`+`cat`+`copy`) runs
end-to-end **byte-identical** to its canonical twin (`["a!","b!","c!"]`, stable on re-run); generated source for
**all 20 shipped specs byte-identical (0 diff)** baseline-vs-mine (every alias add is guarded by the new
spelling, which no shipped spec uses); `perl -c` clean on all 8 modules; **+4 phase0 subtests / 31 assertions**
(`spec_format_terse_1_4_1_*`) → **phase0 971→975 green**; `bash tools/run_ci_local.sh` **EXIT 0** ("Result:
PASS", 975); ratio 1.0000; `mdbook build` EXIT 0; doctrine driver (MEMORY-ARCH + KNOWLEDGE-MAP) EXIT 0.

**Book:** `appendix/helper-contract-catalog.md` (per-helper Terse-spelling lines + a new "Terse Helper Renames"
subsection), `dsl/value-container-flow-helper-reference.md`, `dsl/declaration-helper-reference.md`.

**Frontier → `.1.4.2`** (Rust lockstep parity, ADR 0006). KM card `terse-helper-rename-lowering-sites` updated
(`.1.4.1` landed; full site list; reverify now proves parity).

## 2026-06-24 — SPEC-FORMAT-TERSE.1.4 — split into .1.4.1 (Perl reference) + .1.4.2 (Rust parity); record helper-rename lowering-site ground truth + KM card

**Scope:** task tree (`docs/tasks/SPEC-FORMAT-TERSE.md`), task-tree index (`docs/TASK_TREE.md`), KM fact card
(`docs/knowledge/terse-helper-rename-lowering-sites.md` + regenerated `KNOWLEDGE_MAP.md`), live docs. **No
engine or book change** — this is a tree-split slice that owns the design + frontier only.

**Why split.** PNT (user-directed loop, fresh session) picked `.1.4` (helper renames `assign`→`set`,
`concat`→`cat`, `array_copy`/`hash_copy`→`copy`) and, per the splitting rule, split it after a TOOLBOX-first
`call_spec_handler_subst` ground-truth pass. The change spans **two variants with separable ownership** (Perl
`ActionIR/*` + `t/phase0_regression.t` + book vs Rust `engine.rs` + oracle corpus + cargo tests — COMMIT.md
forbids bundling), a lockstep ADR 0006 obligation — mirroring `.1.1`→`.1.1.1`/`.1.1.2` and
`.1.2`→`.1.2.1`/`.1.2.2`. `.1.4` → container; children `.1.4.1` (Perl) + `.1.4.2` (Rust parity).

**Ground truth (own probes, dump-don't-guess; `perl -Iperl` → `perl/LinkedSpec.pm`).** All three terse
spellings are currently UNRECOGNIZED: `set(scalar(x),1)`→`set(scalar(x), 1)` (vs `assign`→`$x = 1`),
`cat("a","b")`→`cat("a","b")` (vs `concat`→the concat do-block), `copy(a(items))`→`copy([items])` partial /
`copy(h(m))`→`copy(h(m))` (vs `array_copy`→`[@items]` / `hash_copy`→`{%m}`). **Three implementation shapes:**
(i) `cat`→`concat` is a pure rename → `_normalize_method_name` (`ActionIR/MethodExpr.pm:19-26`, pre-lowering);
(ii) `set`→`assign` is STATEMENT-level (`ActionIR/Contracts.pm:1749/1753` `\bassign\s*\(` + `DeclareMethod` +
`MethodLowering._lower_assign_statement`) — NOT reached by `_normalize_method_name`, so `.1.4.1` extends the
statement-level recognition; (iii) `copy` is NOT a pure rename — it unifies `array_copy`/`hash_copy`, needing a
dedicated dispatch in `MethodLowering._lower_method_value_expr` resolving array-then-hash symbol kind
(`[@name]` else `{%name}`). **Rust:** all four canonical helpers live in one `Engine::call_helper()` match
(`rust/linkedspec-runtime/src/engine.rs`: `assign`@711, `array_copy`@735, `concat`@820, `hash_copy`@1833;
aliases = pipe arms); `.1.4.2` pipes `set`/`cat` and adds a separate value-type-dispatching `"copy"` arm.

**Direction (ADR 0007).** New terse names become canonical, old names stay deprecated aliases that lower
identically (retirement is a later explicit leaf); both spellings must lower byte-identically and the 20
shipped specs (old names) must stay byte-identical.

**Validation.** `scripts/check_doctrines.sh` (MEMORY-ARCH + KNOWLEDGE-MAP) EXIT 0; KM map regenerated (49
facts, 309 question keys). No engine/book change ⇒ phase0 N/A to the split slice (baseline 971 green; cargo
252 green). Frontier → `.1.4.1`.

## 2026-06-24 — SPEC-FORMAT-TERSE.1.2.2 — Rust lockstep parity for arg-position bare working-variable auto-existence (engine + oracle + 4 integration locks)

**Scope:** Rust engine (`rust/linkedspec-runtime/src/engine.rs`), oracle generator
(`tools/gen_oracle_corpus.pl` +2 cases, regenerated corpus), Rust integration tests
(`rust/linkedspec-runtime/tests/integration_test.rs`, +4), task tree, KM card, live docs. The lockstep-parity
follow-on to `.1.2.1` (ADR 0006). **Perl untouched; no book change** (variant-agnostic — `.1.2.1` already
taught the contract, Rust now conforms).

**It REQUIRED a Rust engine change (unlike `.1.1.2`).** TOOLBOX-first throwaway Rust integration probe
(parse→validate→compile→execute, dump-don't-guess): although the interpreter's per-parse `RuntimeContext`
HashMaps auto-vivify (the `.1.1.2` finding), a **bare** arg-position target was not reaching the working var.
`resolve_scalar_target` / `resolve_array_target` only extracted the name from a WRAPPED `scalar(VAR)`/`array(VAR)`
Call; a bare `Expr::Variable` fell through to `val.to_str()` (the evaluated value → `""`). Probe BEFORE: bare
`assign(v,"ok")`→`[null]`, bare `push_value(items,..)`→`[[]]` (vs wrapped `["ok"]`/`[["a","b"]]`) — a real
divergence from the Perl `.1.2.1` reference.

**Fix.** Both resolvers now also accept a bare `Expr::Variable` target and return its name (mirroring the Perl
`^(\w+)$` fallback in `ValueExpr::_extract_*_symbol_name`); the per-parse HashMap then auto-vivifies it (no
`declare`; fresh ctx per `execute` ⇒ no leak). Scoped to the Channel-1 target positions via an `allow_bare`
flag: `true` for `push_value`/`push_nonempty`, `false` for the value-position reads `array_copy`/`hash_copy`
(bare value-position reads are Channel 2, deliberately not this leaf). Probe AFTER: bare == wrapped
(`["ok"]`, `[["a","b"]]` = the Perl reference wrapped one level).

**Verification.** 2 oracle corpus fixtures `autoexist_{scalar,array}_bare_arg` (regenerated via
`tools/gen_oracle_corpus.pl`; the existing 7 fixtures byte-identical; `corpus_oracle` checks Rust == the Perl
reference value) + 4 `terse_1_2_2_*` integration tests (scalar/array/push_nonempty value anchors,
bare==wrapped==declare convergence, per-parse no-leak via same-engine re-run). **cargo test 248→252 green**;
all 9 oracle fixtures PASS; `cargo clippy` zero-new (engine.rs 11 = baseline — the added `if allow_bare` nest
was flattened to a tuple `if let`; the new test file adds 0); `perl -c tools/gen_oracle_corpus.pl` OK;
**phase0 971 green** (Perl untouched), `bash tools/run_ci_local.sh` **EXIT 0**.

**Outcome.** Channel 1 (arg-position bare working-variable auto-existence) is now complete on BOTH variants;
`.1.2.1` is landed against the universal contract (ADR 0006/0007). `.1.2` stays `active` — Channel 2
(`.1.2.3`+: value-position bare-word reads + RHS-shape) is pending, added once `.1.5` literal syntax is
designed. The recursive/REP idiom stays deferred to `RUST-PARITY`. Frontier → `.1.4` (helper renames). KM card
[[terse-bare-working-vars-engine-gaps]] updated (Rust parity + the engine-change contrast with `.1.1.2`).

## 2026-06-24 — SPEC-FORMAT-TERSE.1.2.1 — Perl arg-position bare working-variable auto-existence (Channel 1; engine + book + 3 phase0 locks)

**Scope:** engine (`perl/LinkedSpec/RuleIR/EmitContext.pm`), tests (`t/phase0_regression.t`, +3 subtests),
book (`docs/linkedspec-book/src/dsl/declaration-helper-reference.md`,
`docs/linkedspec-book/src/appendix/helper-contract-catalog.md`,
`docs/linkedspec-book/src/dsl/value-container-flow-helper-reference.md`), task tree, KM card, live docs.
First implementation child of the `.1.2` split (Channel 1, Perl reference). Wrappers/`declare` stay optional
aliases (gradual, ADR 0007).

**What changed.** Extended the `.1.1.1` rule-level auto-`my` collector
`RuleIR::EmitContext::_collect_auto_working_var_decls` with a second collection pass (refactored the per-ref
add into a shared `$record` closure that handles reserved-literal exclusion + sigil+name dedup). Alongside
the WRAPPED typed-wrapper refs (`scalar/array/hash(NAME)` + `s/a/h`), it now also scans the literal-masked
RAW blocks for a **bare** (un-wrapped) working variable in a type-implying *first-arg* helper position and
records it with the **position-implied** sigil:
- `assign(NAME, …)` → `my $NAME` (scalar — `_lower_assign_statement` extracts the scalar symbol first, so a
  bare assign target always lowers to `$NAME`),
- `push_value(NAME, …)` / `push_nonempty(NAME, …)` → `my @NAME` (array).

The `\s*,` after the bare name means a WRAPPED target (`scalar(x)`/`array(x)`, whose name is followed by
`(`) is NOT matched by the bare pattern — it stays on the wrapped path; both dedup (by sigil+name, vs the
`@<label>` accumulator and any same-sigil `my` already in the lowered code) to exactly one `my`.

**Ground truth (TOOLBOX-first, dump-don't-guess).** `dump_parser_source` probes (scratchpad
`probe_terse_1_2_1.pl`, isolated bare forms with no wrapper anywhere; `perl -Iperl` confirmed it loads
`perl/LinkedSpec.pm` over the stale `PERL5LIB`): before, bare `assign(count,…)`→`$count = …` and
`push_value(items,…)`→`push @items` with NO preamble `my` (leaky package global; non-strict handlers);
after, each emits the `my` once in the preamble before `while(1)`. The `assign(pair, set_key(hash(pair),…))`
case now correctly declares BOTH `my %pair` (from the wrapped `hash(pair)`) AND `my $pair` (the bare assign
target — a separate scalar holding the hashref, previously leaky).

**Verification.** Generated source for all 20 shipped specs, mine-vs-stashed, diffed = **0 diff** (the corpus
has no un-wrapped arg-position targets — cleaner than `.1.1.1`'s 19/20). `perl -c` clean on `EmitContext.pm`
+ `LinkedSpec.pm` + the test. **+3 phase0 subtests / 17 assertions** (`spec_format_terse_1_2_1_*`: bare
scalar+array+push_nonempty auto-exist with the `my` in the preamble before `while(1)`; the sigil follows the
lowering — no `my @count`; only the target (not the value helper) is declared; deferred `.push(target)`
boundary; dedup vs wrapped/declare = single `my`; integrated per-invocation no-leak run-twice). **phase0
968→971 green**; `bash tools/run_ci_local.sh` **EXIT 0** ("[ci] local CI gate passed", 971); ratio 1.0000
(phase0 all-target guard); `mdbook build` EXIT 0.

**Book (3 pages).** Taught wrapper-optional-in-a-type-implying-argument-position (with `assign`/`push_value`
equivalence pairs) and corrected the now-outdated "inferring the kind from an argument position is a later
step" note in `declaration-helper-reference.md`; extended the auto-existence notes + the
`assign`/`push_value`/`push_nonempty` contract entries in `helper-contract-catalog.md` §1 and the containers
note in `value-container-flow-helper-reference.md`. Variant-agnostic (no Perl/sigil internals).

**Scope (signoff): Channel 1 = unambiguous first-arg value-helper positions only.** The child-append
`push(Rule[, target])` / fluent `.push(target)` target is DEFERRED (its first arg is a *rule name* —
ambiguous), and a bare HASH target has no clean arg-position trigger (`assign`'s target lowers scalar-first;
`set_key(name,…)` is a value-position read) — both are Channel 2 (value-position bare-word reads + RHS-shape),
not this leaf. KM card [[terse-bare-working-vars-engine-gaps]] updated (Channel 1 closed). Frontier →
`.1.2.2` (Rust lockstep parity).

## 2026-06-24 — SPEC-FORMAT-TERSE.1.2 — split into .1.2.1 (Perl, Channel 1) + .1.2.2 (Rust parity); record bare-working-var ground truth + KM card

**Scope:** task tree (`docs/tasks/SPEC-FORMAT-TERSE.md`) + new KM fact card
(`docs/knowledge/terse-bare-working-vars-engine-gaps.md`, map regenerated) + live docs (`MEMORY.md`,
`CHANGES.md`, `DEVELOPMENT_NOTES.md`, `LIVE_ACHIEVEMENT_STATUS.md`). **DOCS/TREE/KM only — no engine,
spec, test, or book change.** The honest first outcome of PNT-picking `.1.2` (remove container wrappers +
type inference): the leaf is too broad for one signoff slice, so it is split after a TOOLBOX-first
ground-truth pass (mirroring the `.1.1`→`.1.1.1`/`.1.1.2` split).

**Ground truth (TOOLBOX-first, dump-don't-guess).** `dump_parser_source` probes via `perl -Iperl
-MLinkedSpec` (`generate_only` + `runtime_ctx_ref`; scratchpad `probe_terse_1_2.pl` + isolated
one-liners; confirmed `perl -Iperl` loads `perl/LinkedSpec.pm` over the stale `PERL5LIB=.../pgen/fx/perl`).
A **bare** (un-wrapped) working variable has three behaviors, splitting into two inference channels:
- **Channel 1 — arg position:** a bare name already lowers to the correctly-sigil'd variable
  (`assign(count, v)` → `$count = v` via ValueExpr `_extract_scalar_symbol_name`'s `^(\w+)$` fallback,
  `ValueExpr.pm:59`; `push_value(items,..)` / `-> w.push(items)` → `push @items, ..`) **but gets no
  auto-`my`** — the `.1.1.1` collector regex (`EmitContext.pm:810`) matches only WRAPPED
  `scalar/array/hash(NAME)`, so a bare var used only in arg positions is a **leaky package global** (the
  exact `.1.1.1` hazard, still open for bare forms).
- **Channel 2 — value position:** a bare word is **not** recognized as a variable read —
  `return(count)` → bareword `return count ;` (not `$count`). Making bare words read as variables needs
  var/call/literal disambiguation + RHS-shape inference (`[]`→array, `{}`→hash), which couples with `.1.5`
  literal syntax.
- **Wrapped refs already auto-exist** (the `.1.1.1` result: `scalar(count)`→`my $count;`,
  `array(items)`→`my @items;`).

**Split.** `.1.2` → container; added `.1.2.1` (Perl, Channel 1: arg-position bare working-var
auto-existence — the self-contained, lowest-risk first slice that directly extends the `.1.1.1` collector
and closes the leaky-global gap) + `.1.2.2` (Rust lockstep parity, ADR 0006). Channel 2 leaves
(`.1.2.3`+) are **not** pre-published — added once `.1.2.1` lands and `.1.5` is designed (no vague
placeholders). Wrappers stay accepted aliases during migration (gradual, ADR 0007); the shipped corpus
uses them pervasively (declare 87 / assign 103 / scalar 133 / array 134 / hash 36), so they must keep
compiling byte-identically. Frontier → `.1.2.1`.

**Verification:** `dump_parser_source` ground-truth probes (above); `perl -c` clean on the `.1.2` landing
modules (`ValueExpr.pm`, `MethodLowering.pm`, `EmitContext.pm`); `scripts/check_memory_architecture.sh`,
`scripts/check_doctrines.sh`, and the KM gate all EXIT 0 (KM card added + map regenerated). No engine/book
change, so the phase0 regression gate is N/A to this split slice (phase0 stays 968, untouched).

## 2026-06-24 — SPEC-FORMAT-TERSE.1.1.2 — Rust lockstep parity for auto-existing working variables (oracle + integration locks; NO engine change)

**Scope:** Rust variant test/oracle surface (`tools/gen_oracle_corpus.pl` + 5 generated `autoexist_*`
corpus fixtures, `rust/linkedspec-runtime/tests/integration_test.rs`) + task tree + KM card + live docs.
The lockstep-parity follow-on to `.1.1.1` (ADR `0006`: a Perl-reference change is landed against the
universal contract only once every backend reproduces it). **No engine code changed** in either variant.

**Assessment (blocked-vs-doable, per the leaf): DOABLE — no engine change needed.** TOOLBOX-first ground
truth (throwaway Rust integration probe + `perl -Iperl` `LinkedSpec::Get` probe on the same minimal
grammars; read `rust/linkedspec-runtime/src/{runtime,engine}.rs`, dump-don't-guess): the Rust variant is
an **interpreter** (no codegen/`eval`), so working variables live in per-parse `RuntimeContext` HashMaps
(`scalars`/`arrays`/`hashes`) that **auto-vivify** on write (`set_scalar` = `insert`, `push_value` =
`entry().or_default().push`, `set_hash_entry` = `entry().or_default`) and read as `Undef`/empty when
absent. So a `.spec` working variable referenced via `scalar(NAME)`/`array(NAME)`/`hash(NAME)`
**already auto-exists** with no `declare(...)`, and `Engine::execute` builds a **fresh `RuntimeContext`
per call** so a value never leaks across parses (the Rust analogue of Perl's per-invocation `my`). The
Perl `.1.1.1` change was a *codegen* fix (non-strict generated handlers would turn an undeclared bare var
into a leaky package global) — a hazard the Rust interpreter does not have. So parity holds by
architecture; the leaf lands as lockstep regression tests + docs. `declare(...)` stays meaningful for its
`=init` seed form (`declare_scalar_with`).

**Cross-variant proof** (divergence-free edge-action form = the `.7.1` oracle proof class; recursive/REP
forms are blocked by the separate `RUST-PARITY` recursive-grammar/REP-lifecycle gap, verified returning
`[null]`/`[[]]`): scalar no-declare Perl `"ok"`/Rust `["ok"]`; array no-declare Perl `["a","b"]`/Rust
`[["a","b"]]`; declare twins identical; `array(undef)` Perl `[null]`/Rust `[[null]]` — Rust == Perl
reference wrapped one level (the documented Perl↔Rust output-shape rule).

**Locked:**
- 5 oracle corpus fixtures `autoexist_{scalar,array}_{no_declare,declare}` + `autoexist_undef_literal`
  added to `tools/gen_oracle_corpus.pl` and regenerated (existing 2 fixtures byte-identical); the
  `corpus_oracle.rs` runner checks each against the Perl reference value — all **7 fixtures PASS**.
- 4 `terse_1_1_2_*` integration tests in `rust/linkedspec-runtime/tests/integration_test.rs`: scalar +
  array value anchors, declare/no-declare convergence, and per-parse no-leak (same engine re-run yields
  the identical value, not an accumulation).

**Verification:** `cargo test` **244→248 green** (integration 25→29; oracle still 1 test, now guarding 7
fixtures); `cargo clippy -p linkedspec-core -p linkedspec-runtime --tests` zero-new source/test warnings
(engine.rs 11 = baseline; the new test files add 0); `perl -c tools/gen_oracle_corpus.pl` OK; `mdbook
build` EXIT 0 (no book change — variant-agnostic, `.1.1.1` already taught the contract; Rust now
conforms); `bash tools/run_ci_local.sh` **EXIT 0** (phase0 **968 green**, Perl untouched). KM card
`docs/knowledge/rust-working-vars-auto-vivify.md` (map regenerated, 47 facts). `.1.1` container done;
frontier → `.1.2`.

## 2026-06-24 — SPEC-FORMAT-TERSE.1.1.1 — Perl auto-existing working variables (ENGINE + BOOK + 3 phase0 locks)

**Scope:** Perl reference engine (`perl/LinkedSpec/RuleIR/EmitContext.pm`,
`perl/LinkedSpec/SpecEntry.pm`) + 3 new `t/phase0_regression.t` locks + 3 mdBook pages + task tree +
KM card + live docs. First terse-format (ADR `0007`) **implementation** leaf. Rust lockstep parity is
the follow-on `.1.1.2`.

**What changed (the feature).** A `.spec` working variable referenced through a typed wrapper —
`scalar(NAME)`/`array(NAME)`/`hash(NAME)` or the `s()`/`a()`/`h()` aliases — no longer needs a prior
`declare(...)`. The engine now auto-supplies one `my $NAME`/`@NAME`/`%NAME` in the handler preamble, so
the variable is a **per-invocation lexical** instead of a **leaky package global** (generated handlers
