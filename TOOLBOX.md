# TOOLBOX.md — LinkedSpec's own diagnostic & debug toolbox (USE THIS FIRST)

> **STANDING DIRECTIVE (2026-06-22).** LinkedSpec ships a real, built-in debug surface. For **any** parse
> rejection, wrong AST shape, codegen defect, hang, or "why is this test failing / why did the engine
> return this" question, **reach for LinkedSpec's own tools FIRST and systematically** — never eyeball a
> `.spec`, never guess a root cause, never re-bless a test or offer a strategy menu before the toolbox has
> shown you the exact mechanism and source location. If the built-in tools cannot surface the **WHY** and
> **WHERE**, the next step is to **build** a tool, not to speculate.

This file is the **single, authoritative catalog of LinkedSpec's own debug tooling**. Each entry says
**WHAT** it is, **WHEN** to reach for it, **HOW** to run it (exact command), and **WHAT** the output
looks like. It is part of LinkedSpec's portable architecture set
([`DOCTRINE_ENFORCEMENT.md`](DOCTRINE_ENFORCEMENT.md), [`MEMORY_ARCHITECTURE.md`](MEMORY_ARCHITECTURE.md),
[`KNOWLEDGE_MAP.md`](KNOWLEDGE_MAP.md), the task-trees).

§1–§5 are **LinkedSpec's own tools** (the debug surface the project ships). §6 lists a few **general
supporting techniques** that complement them. (Always run with `perl -Iperl …` — see §6.5.)

## Enforcement — provable, not "trust me"

- The **reference engine is the oracle** for all variants ([[cross-variant-output-parity]]); when a test
  and the engine disagree, the engine's *measured* output is the truth — **dump it with the tools below,
  don't transcribe it** from a triage note.
- Doctrine compliance runs via [`scripts/check_doctrines.sh`](scripts/check_doctrines.sh) (the registry
  driver), invoked by the fast [`.githooks/pre-commit`](.githooks/pre-commit) boundary (E3) and
  `tools/run_ci_local.sh` (E4). ADR `0073` reserves complete canonical CI for designated leaves and the clean
  pre-push boundary; ordinary leaf commits run their task-selected focused proof.
  For staged code/spec/test/tooling changes, `TASK-ACCEPTANCE`
  ([`scripts/check_diagnosis_evidence.sh`](scripts/check_diagnosis_evidence.sh)) requires the owning
  task file to carry the checklist below with LinkedSpec-tool evidence signatures. `REPO-ROOT-PATHS`
  ([`scripts/check_repo_root_path_portability.sh`](scripts/check_repo_root_path_portability.sh)) independently
  scans tracked parent-repository text and locks all five primary-command runtime root anchors on every run.
  `README-STABILITY` ([`scripts/check_readme_stability.sh`](scripts/check_readme_stability.sh)) keeps the root
  landing page within the reviewed `README_POLICY.md` line/byte caps and unconditionally invokes
  [`scripts/check_readme_routing_pressure.pl`](scripts/check_readme_routing_pressure.pl). The data registry at
  `doctrine/readme_stability/routes.jsonl` must exactly cover 62 actual reader/author routes across 20 controlled
  surfaces; closure, existence, lifecycle controls, debt growth, staged-result agreement, and every threshold
  increase fail closed. Its in-memory mutation oracle reports 32/32 before the doctrine can pass.
  `DOCUMENT-HISTORY` ([`scripts/check_document_history.sh`](scripts/check_document_history.sh)) independently
  verifies bounded current views and hot shards, strict manifests, immutable repository-local segments, exact
  clean-Git reconstruction/slices, queryability, and rollover limits. Use `tools/read_document_history.pl`
  instead of scanning old live prose.

### The task-acceptance checklist (recommended for any code-change leaf)

Copy into the owning `docs/tasks/<TREE>.md` leaf; each box backed by the cited LinkedSpec-tool output.
The mechanical hard-gate checks staged checklist presence and evidence signatures; the cited commands remain
the reproducibility oracle run through focused validation and `tools/run_ci_local.sh`.

If the gate fires on an unexpected commit, first run `git diff --cached --name-only`. Either unstage the
unrelated governed files, stage/update the real owning task leaf, or split the work so one leaf owns one
evidence trail. A placeholder checklist is not acceptable; the gate is deliberately a staged evidence-shape
check, not proof that the cited commands were run.

```markdown
## Acceptance Checklist
- [ ] **REPRODUCE / ISSUE** — <LinkedSpec tool command + symptom (test FAIL line / got-vs-expected / hang)>
- [ ] **ROOT CAUSE (WHY + WHERE)** — <engine output (§1/§2) or generated-source dump (§2.2) naming the mechanism + file:line/rule; STALE-test (re-bless) vs REAL engine defect decided by the dumped got-value>
- [ ] **FIX** — <minimal change; .spec authoring prefers canonical DSL > raw Perl; engine = reference-frozen unless authorized (ADR 0008 pattern)>
- [ ] **ADDRESSED (verified)** — <before→after: failing-subtest count + `comm` name set-diff = exactly the intended set>
- [ ] **NO REGRESSION** — <full `perl -Iperl t/phase0_regression.t` reaches its true stop; `comm` new-failure set empty; `perl -c` clean>
- [ ] **LOCKSTEP** — <book/USER_GUIDE/CHANGES/DEV_NOTES/MEMORY/task-tree/KM updated, or N/A + reason>
```

**A box is EARNED, not ticked** — the proof is the re-run. A truncated/killed phase0 run gives a FALSE
"cleared" set: **check the reach (last `ok N`) before trusting `comm`** ([[lispish-corpus-catastrophic-backtracking]]).

---

## Quick chooser — symptom → LinkedSpec tool

| Symptom / question | Go to |
|---|---|
| "Does this `.spec` compile? does this input parse? what does it return?" | [§1.1 `LinkedSpec::Get`](#11-linkedspecget--inline-build--run-the-ground-truth-probe) |
| "Same, for a named/shipped spec by file" | [§1.2 `get_parser`](#12-linkedspecget_parser--named-spec-resolution) |
| "What does this `return(...)` / helper lower to?" | [§1.3 `call_spec_handler_subst`](#13-linkedspeccall_spec_handler_subst--action-lowering-probe) |
| "What metadata / contracts / ActionIR nodes does a rule produce?" | [§2.1 `return_descriptor`](#21-return_descriptor--descriptormetadata-introspection) |
| "The generated handler is broken (undef / `[]`) — show me the emitted Perl" | [§2.2 `dump_parser_source`](#22-dump_parser_source--parser_source_ref--generated-source-dump) |
| "Does emitted Perl independently load and run with the same result?" | [§1.5 `emit_generated_source`](#15-linkedspecemit_generated_source--standalone-source-proof) |
| "Stop the pipeline at parse / at codegen" | [§2.3 `parse_only` / `generate_only`](#23-parse_only--generate_only--stop-the-pipeline-at-a-phase) |
| "Inspect the compiler's internal compiled-spec state" | [§2.4 `return_state`](#24-return_state--internal-compiled-spec-state) |
| "Capture the engine's error / last_error / top_rule" | [§2.5 `runtime_ctx_ref`](#25-runtime_ctx_ref--capture-runtime-context--errors) |
| "Watch the parser/compiler explain itself (enter/decision/mark)" | [§3 Trace framework](#3-the-trace-framework-linkedspecs-own-observability) |
| "Inspect what a `.spec` compiles to" | [§4.1 `inspect_spec_codegen.pl`](#41-toolsinspect_spec_codegenpl--codegen-inspection) |
| "Cross-variant / self-host parity (oracle ↔ candidate, Perl ↔ Rust)" | [§4.2 cross-check / oracle corpus](#42-toolscross_check_spec_parserspl--toolsgen_oracle_corpuspl) |
| "Did Unicode casing data/fixtures/backend tables drift?" | [§4.5 Unicode casing contract](#45-toolscheck_unicode_case_contractpy--pinned-unicode-casing-proof) |
| "Did the neutral semantic introspection schema/query answers drift?" | [§4.9 semantic introspection contract](#49-toolscheck_semantic_introspection_contractpy--neutral-modelquery-oracle) |
| "Did Perl semantic-index source normalization, projections, privacy, paging, budgets, or queries drift?" | [§4.9 Perl semantic tests](#49-toolscheck_semantic_introspection_contractpy--neutral-modelquery-oracle) |
| "Did Julia semantic-index source/outcome construction, coordinates, ceilings, privacy, or no-execution drift?" | [§4.9 Julia foundation](#49-toolscheck_semantic_introspection_contractpy--neutral-modelquery-oracle) |
| "Did the neutral/private inter-match gap contract or rooted runtime order drift?" | `bash tools/check_inter_match_gap_capture_six_runtime.sh` plus [§4.3.6 Lua targeted commands](#436-lua-targeted-commands-and-ssd-local-storage-oracle) |
| "Is the suite green? did my change move exactly the right tests?" | [§5.1 phase0 gate](#51-the-phase0-regression-gate-tphase0_regressiont) + [§6.1 `comm`](#61-comm-failing-set-diff-the-no-regression-proof) |
| "A parse hangs / burns CPU — which file, regex blowup?" | [§6.3 fork+SIGKILL census](#63-forksigkill-hard-timeout-census-alarm-cannot-kill-a-regex) |
| "Did I already establish this fact? (avoid archaeology)" | [§5.2 Knowledge Map grep](#52-knowledge-map-grep-before-re-deriving) |
| "Where is an older live-status completion or exact chronology?" | [§5.3 document-history query](#53-document-history-query-and-doctrine) |
| "Which bounded part owns a stable future-task ID?" | [§5.4 task-tree partition lookup](#54-task-tree-partition-lookup-and-metadata) |
| "Where should this workflow put temporary/package/build data, and how do I recover a run?" | [§4.4.1 project-data environment](#441-toolsproject_data_envsh--repo-filesystem-project-state) + [§4.4.2 run lifecycle](#442-toolsproject_data_runsh--per-run-scratch-lifecycle) |

---

## 1. LinkedSpec's facade probe entrypoints (the ground-truth tools)

### 1.1 `LinkedSpec::Get` — inline build + run (THE ground-truth probe)
- **WHAT:** build a parser from an inline `.spec` and run it — the canonical way to observe the engine's
  *actual* output for an exact spec+input. The single most-used debug tool.
- **WHEN:** before re-blessing any test, before believing a triage note, before claiming a behavior.
  "Dump it, don't transcribe it."
- **HOW:**
  ```bash
  perl -Iperl -MLinkedSpec -MJSON::PP -e '
    my $s = "top::  -> word .push\nLX { return(array_copy(a(top))) }\n\nword : /(\w+)/  I.return(entry_group(0))\n";
    my $p = LinkedSpec::Get(\$s);                       # build
    print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\"hello world")), "\n";'  # run
  ```
- **OUTPUT:** the parser's top-level value (`["hello","world"]`). Accepts the debug options in §2
  (`return_descriptor`, `dump_parser_source`, `top_rule`, `runtime_ctx_ref`, …).
- **Entry rule model:** a valid `.spec` needs one or more rules, not a mandatory `::`. Explicit
  `top_rule` wins; otherwise the first authored `::` wins; without a marker, the first authored rule
  wins. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT implement and admit all three branches.
  Authored `::` is default-entry identity, and after selection `::` and `:` rules have the same
  regex/mode/action feature surface ([[top-rule-is-ordinary-rule-entered-first]]). The two-rule
  no-regex wrapper above is a useful stream-parser idiom, not a validity minimum.

### 1.2 `LinkedSpec::get_parser` — named spec resolution
- **WHAT:** resolve a shipped/named spec (`specs/<name>.spec`) to a parser coderef (via `Resolver`).
- **WHEN:** debugging a shipped spec (`Lispish`, `ebnf`, `pplugin`, …) against real corpus input.
- **HOW:** `perl -Iperl -MLinkedSpec -e 'my $p = LinkedSpec::get_parser("ebnf"); ...'`

### 1.3 `LinkedSpec::call_spec_handler_subst` — action-lowering probe
- **WHAT:** returns the lowered action code for a `(rule_label, action_code)` pair (or the unchanged
  string for a RAW_PERL-fallback / retired helper).
- **WHEN:** "what does `return_array(...)` / `return_a(...)` / a helper lower to canonically?"
  ([[retired-return-helpers-canonical-rewrite]], [[actionir-return-node-retired-to-return]]).
- **HOW:**
  ```bash
  perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst("Top",
    q{return(array("semantic_annotation", hash("items", array(IMATCH_LIST))))}), "\n";'
  ```

### 1.4 `LinkedSpec::build_compiled_rule_table` — low-level compile seam
- **WHAT:** convert parsed entries into the compiled rule table (the seam beneath `Get`); accepts
  `return_state` (§2.4) and `runtime_ctx_ref` (§2.5).
- **WHEN:** isolating a compile-stage problem below the parser-build surface.

### 1.5 `LinkedSpec::emit_generated_source` — standalone source proof
- **WHAT:** compile inline `.spec` text into deterministic, independently loadable Perl source conforming to
  Perl generated-source contract v2. Plan rows stay `{label, family}`; the validator derives cursor policy from
  the exact ten-family map and rejects v1 reconstruction with a regeneration diagnostic.
- **WHEN:** distinguish “the live compiler-generated parser works” from “captured source is genuinely standalone,”
  or reproduce generated plan, identity, trace, and execution errors.
- **HOW:**
  ```bash
  perl -Iperl -MLinkedSpec -e '
    my $s = qq{Top::\n /x/ -> Done { return("ok") }\n\nDone::\n /[a-z]+/\n};
    my $src = LinkedSpec::emit_generated_source(\$s,
      source_identity => "probe.spec");
    eval "package Probe::Generated; $src; 1" or die $@;
    my $input = "xhello";
    print Probe::Generated::Execute(\$input), "\n";'
  ```
- **OUTPUT:** `ok`. Inspect `Probe::Generated::LinkedSpecGeneratedMetadata()` for contract/version/identity/plan,
  and call `ValidateGeneratedPlan(...)` to probe pre-execution rejection.

---

## 2. LinkedSpec's introspection / debug OPTIONS (knobs to `Get`/`get_parser`)

Pass these in the `Get(\$spec, KEY => VALUE, …)` / `get_parser($name, KEY => VALUE, …)` option list.

### 2.1 `return_descriptor` — descriptor/metadata introspection
- **WHAT:** returns the compiled descriptor (`{spec}{<Rule>}{meta}{action_rewriter}{…}`: canonical
  ActionIR nodes/hits, contracts, `*_count` fields, the `action_rewriter_migration` summary) instead of
  a parser.
- **WHEN:** verifying a re-bless of node/contract/count assertions; checking the all-spec ActionIR-ready
  invariant ([[phase0-all-target-actionir-ready-invariant]], ADR 0002).
- **HOW:**
  ```bash
  perl -Iperl -MLinkedSpec -MData::Dumper -e '
    my $s = qq{Top::&\n I { return_undef() }\n /a/ -> Top { return(1) }\n};
    my $d = LinkedSpec::Get(\$s, return_descriptor => 1);
    print Dumper($d->{spec}{Top}{meta}{action_rewriter}{canonical_action_ir_nodes});'   # => ['RETURN']
  ```

### 2.2 `dump_parser_source` / `parser_source_ref` — generated-source dump
- **WHAT:** capture the **emitted Perl handler source**. `dump_parser_source => 1` + `runtime_ctx_ref`
  fills `$ctx{parser_source_chunks_ref}`; `parser_source_ref => \my $src` flushes it into your scalar.
- **WHEN:** a handler returns `undef` (compile-fail) or `[]` (dropped payload) — read the *generated*
  code, not the emitter template. This pinned the AND-codegen `SCALAR(0x…)<label>` defect
  ([[and-return-edge-codegen-defect]]).
- **HOW:**
  ```bash
  perl -Iperl -MLinkedSpec -e '
    my $s = "Top::AND\n /a/\n /b/\n -> Top[0] { assign(scalar(x), 1) }\n -> Top[1] { return(1) }\n";
    my %ctx; LinkedSpec::Get(\$s, top_rule=>"Top",
                             dump_parser_source=>1, runtime_ctx_ref=>\%ctx);
    print ${$ctx{parser_source_chunks_ref}} if $ctx{parser_source_chunks_ref};'
  ```
- **READING:** a `SCALAR(0x…)Label = …`, or a `return \@Label_collect` nothing pushes to ⇒ emitter bug;
  valid Perl returning the wrong shape ⇒ a lowering/shape bug.
- **STANDALONE CHECK:** the captured text is now independently loadable and is byte-identical to
  `emit_generated_source(...)` for the same spec/options/identity. Always execute the loaded source when the claim
  under review is generated-source capability rather than diagnostic text shape.

### 2.3 `parse_only` / `generate_only` — stop the pipeline at a phase
- **WHAT:** `parse_only => 1` stops after the bootstrap-parse stage (inspect the parsed entries, no
  codegen); `generate_only => 1` stops after emitting the parser source (no callable parser returned).
- **WHEN:** isolate "is the failure in parsing the `.spec`, in codegen, or at runtime?" by bisecting the
  pipeline. (`test_expectation => 'fail'` asserts an expected parse failure.)

### 2.4 `return_state` — internal compiled-spec state
- **WHAT:** `build_compiled_rule_table(..., { return_state => 1 })` returns the explicit internal
  `compiled_spec_state` / `compiled_dependency_regex_state` (definition_order, compiled_rule_order,
  rules_by_label, redefined_rule_labels) instead of the legacy hash.
- **WHEN:** debugging compiler state, rule ordering, duplicate-label handling, dependency-regex assembly
  ([[compilerstate-internal-model]]).

### 2.5 `runtime_ctx_ref` — capture runtime context & errors
- **WHAT:** `runtime_ctx_ref => \my %ctx` populates a context hash: `last_error` (structured: `type`,
  `detail`, `top_rule`, `handler_source_label`), `spec_name`/`spec_path`, selected `top_rule`, and the
  parser-source capture.
- **WHEN:** "why did this build/parse fail, and where?" — read `$ctx{last_error}`. Pair with
  `top_rule => "..."` to reproduce a selected entry path; cursor policy comes from each authored rule family.
  The former `parse_mode` key is a removal-diagnostic probe only, never a supported debug option.

---

## 3. The Trace framework (LinkedSpec's own observability)

- **WHAT:** `LinkedSpec::Trace` emits ENTER/EXIT scopes, DECISION (branch TAKEN/SKIPPED) events, MARK
  position events (with input-pointer excerpts), and value dumps, at six ordered levels
  (`none < low < medium < high < full < debug`). Routable to stdout or a file. **The framework already exists**
  — exposing it via a CLI/docs is tracked by `TRACE-OBSERVABILITY`.
- **CONTRACT:** the trace capability contract is variant-agnostic. The Perl names below are concrete reference
  mechanics; Rust and future variants must provide equivalent documented capabilities to claim trace parity.
- **WHEN:** root-causing *what the parser/compiler did* — branch taken, decision, mark position, where a
  handler failed. Prefer trace + a minimal repro over inferring from a diff.
- **HOW (env):**
  ```bash
  LINKEDSPEC_TRACE_LEVEL=debug perl -Iperl <driver.pl>     # most verbose
  ```
- **HOW (CLI):**
  ```bash
  perl bin/linkedspec --spec-file demo.spec --input-file demo.txt \
    --trace debug --trace-file trace.log --trace-mode route --trace-reset
  ```
- **HOW (per-call):** `LinkedSpec::Get(\$s, trace_level => 'debug', trace_log_mode => 'stdout')`, or
  `LinkedSpec::configure_trace(...)`. Programmatic API: `trace_enter/trace_exit/trace_decision`,
  `log_output`, `log_dump`, `should_dump`.
- **SCOPE BEFORE DEBUG:** an environment-level `debug` trace is active during bootstrap/parser compilation and can
  emit the entire compiler path before the runtime event of interest. For a focused execution question, build the
  parser first with tracing quiet, then call `LinkedSpec::configure_trace(...)` immediately before execution, or
  use the exact dedicated probe/test. Do not route an unbounded bootstrap debug stream to the conversation.
- **Generated handler branches:** Perl generated handlers now emit debug-level
  `DECISION generated_handler_branch:<handler_kind>:<rule>:<branch>` lines for non-repetition match/miss, acode
  index dispatch, AND sequence checks, bcode child-call dispatch, child-result checks, and REP loop decisions.
  REP branch names include `loop_enter`, `iteration_result`, `miss_min_satisfied`, `max_continue`,
  `zero_progress`, and `zero_progress_min_satisfied` where the generated template has that branch.
- **RuleIR planning branches:** compile-time RuleIR planning now emits debug-level
  `DECISION rule_ir:<phase>:<rule>:<decision>` lines for collection routing, handler-variant selection,
  action-mode/execution-shape planning, split-boundary marker lowering, and mixed-action validation.
- **EmitContext bridge branches:** compile-time EmitContext now emits debug-level
  `DECISION emit_context:<phase>:<label>:<decision>` lines and matching debug scopes for ActionIR owner
  package/callback resolution, default dependency bundles, function-registry and bare-symbol-kind injection,
  compatibility scalar/aggregate fallbacks, canonical rewrite-pipeline use, and rule emit-context build boundaries.
- **ActionIR pipeline branches:** compile-time scanner/canonical/diagnostic/rewrite-pipeline owners now emit
  debug-level `DECISION actionir:<owner>:<phase>:<label>:<decision>` lines and matching debug scopes for helper
  event discovery, canonical queue/fallback decisions, unresolved helper diagnostics, RAW_PERL and unmatched-event
  fallbacks, source-span/contract skips, and implicit attached-if closure handling.
- **Compact ActionIR lowerer branches:** compile-time compact lowerers now emit debug-level
  `DECISION actionir:<owner>:<phase>:<label>:<decision>` lines for `flow_expr`, `value_expr`,
  `array_pipeline`, `declare_method`, and `control_flow` decisions. These cover expression family selection,
  direct-access/value-source choices, array-pipeline plan/op lowering, declaration/set routing, and compact
  attached/inline/marker control-flow paths.
- **MethodLowering branches:** compile-time `ActionIR::MethodLowering` now emits debug-level
  `DECISION actionir:method_lowering:<phase>:<label>:<decision>` lines and assignment scopes for helper-family
  selection, AST-vs-string fallback/bypass choices, unsupported helper exits, receiver-chain transitions,
  assignment/mutation operator routing, mutation-slot values, and return-payload fallback choices.
- **Compile/ActionIR coverage boundary:** the planned Perl reference compile/ActionIR owner namespaces are covered
  through MethodLowering. `TRACE-OBSERVABILITY.4.5` established the original Rust external trace-capability
  parity proof; corrective `.5.1` restores ordinary/traced progressive static-validation equality and `.5.2`
  restores gap-aware runtime `child_dispatch` lifecycle events. The complete Rust parity claim is current again.
  Future variants must expose the same documented controls, levels, event classes, sink behavior,
  default-quiet behavior, and validation identity before claiming trace parity.
- **Rust trace controls/events:** `TRACE-OBSERVABILITY.4.2` added the Rust shared control layer:
  `linkedspec_core::trace::{TraceConfig, TraceLevel, TraceSinkMode, TraceEmitter}` plus the `DUMP_*` constants,
  environment-derived config, stdout/route/mirror sinks, routed-file reset, and event primitives. Runtime re-exports
  it as `linkedspec_runtime::trace`; opt-in traced entrypoints now exist beside core parse/validate/compile,
  full-spec user-function parsing, staged parse jobs, `Engine::execute`, generated-plan execution, generated parser
  execution, and emitted generated module `parse_with_trace(...)`. `TRACE-OBSERVABILITY.4.3` adds Rust routed debug
  events for core parse/validation/compile/dependency-regex phases, full-spec user-function parsing, and staged
  parse-job normalize/resolve/load/compile/execute phases. `TRACE-OBSERVABILITY.4.4` adds runtime debug events under
  `rust_runtime:engine:*` for interpreted rule entry/exit, recursion cutoffs, regex match/no-match, acode/bcode
  dispatch, lifecycle blocks, statement controls, helper `call(child)`, and mark/capture helper operations, plus
  `rust_runtime:generated_plan:*` for generated family-plan dispatch and generated direct acode/bcode execution.
  `TRACE-OBSERVABILITY.4.5` closed the original parity proof. Corrective `.5.1` proves traced compilation runs the
  same progressive validator as ordinary compilation and returns the exact same malformed-program diagnostic;
  reverify with the focused `traced_compile_enforces_progressive_static_contract` test in
  `rust/linkedspec-runtime/tests/trace_controls.rs`. Corrective `.5.2` consolidates no-slot and gap-aware child entry
  through one local traced seam in each executor, restoring exactly one `child_dispatch` / result pair under the
  existing engine or generated-plan namespace; the complete target is 11/11. Future variants must pass the mdBook
  checklist before making the same claim.
- **Corrective proof closeout:** focused `TRACE-OBSERVABILITY.5.3` keeps the cfg private progressive-authority test
  a 4/4 target absent from canonical CI while requiring the separate tracked/cfg admitted contract consumer once.
  `.5.4` aligns the admitted Perl snapshot with 79 mutations and Rust `dormant_red`; 143/143 plus canonical proof
  close the corrective tree without production, rollout, registry, format, or public movement. Mandatory notes
  segment `4990` and ADR `0090` retain exact bounded-history pressure controls at 18 files / 17 manifest lines.
- **Staged-registry boundary audit:** before changing general staged AST behavior, retrieve
  [[general-staged-ast-current-boundary]] and probe the registry rather than inferring policy semantics from its
  JSON fields. The five current registries execute only the one-depth
  `actionir-body.spec` / `action_block` family. Raw `execute*_parse_jobs` carries arbitrary result/failure strings;
  function-specific dispatch/stitch validators alone make `replace_field` / `body_ast` / `fail` executable.
  `FUTURE-PARITY-BACKLOG.14.7.1` repairs wrong-top compile context: all five source backends/six runtimes now
  preserve job id/path/parser/top/payload/span/failure plus the resolved built-in identity. Reverify with the exact
  five registry paths and focused tests in the fact card before touching general `.14.7.2+` behavior.
- **Perl general-staged admitted boundary:** `FUTURE-PARITY-BACKLOG.14.7.3.1-.4` implement and privately admit
  `t/staged_ast_enrichment_perl_contract.t`. Run it directly with
  `PERL5LIB= prove -Iperl t/staged_ast_enrichment_perl_contract.t`: all 143 top-level checks pass. Use
  `call_spec_handler_subst` to
  see the one private `LinkedSpec::StagedParseJob::construct_marker` lowering and `return_descriptor` to inspect
  its exclusive `STAGED_PARSE_JOB_MARKER`, normalized literal options, and typed text plan. Live direct/derived
  probes must read detached sidecars through `LinkedSpec::StagedParseJob`, never by inspecting regex or source
  authority. Probe `LinkedSpec::StagedASTEnrichment` only with a caller-frozen neutral snapshot whose opaque
  authorities have been replaced by already-compiled callbacks; `resolve_pre_registered`, `effective_authority`,
  `job_identity`, `cache_identity`, `enrich_ast`, and `enrich_recursively` expose the private pure-selection,
  one-depth, and bounded breadth-first boundaries. Recursive callbacks receive an ephemeral second context for
  safe points and original-source position/span/diagnostic rebasing; never retain it after callback settlement.
  `LinkedSpec::StagedASTEnrichmentRuntime` is the host-only top-level seam: live and generated-v2 wrappers create a
  fresh scheduler/cache from invocation options and enrich only after the parent AST returns. The oracle proves
  native, normalized-descriptor, validated generated-plan, and independently loaded emitted equality plus distinct
  callbacks/cancellation/clocks and serialized-authority absence. Then run
  `bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py` to prove neutral+Perl+Rust
  lifecycle, Dart's exact dormant consumer, two absent later consumers, 85 mutations, and exact single Perl/Rust
  ordinary+canonical admission with zero Dart registration.
  Public authoring remains `.14.7.9`.
- **Rust general-staged admitted private boundary:** `FUTURE-PARITY-BACKLOG.14.7.4.0-.4` owns
  `rust/linkedspec-runtime/tests/staged_ast_enrichment_contract.rs` as an ordinary and canonical consumer. Run it with
  `bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test
  staged_ast_enrichment_contract`; its one top-level test covers all neutral,
  function-body-v1, diagnostic, registry-denial, native, reconstructed, generated-plan, and independently compiled
  emitted observations, including four fresh-authority production executions.
  Inspect `Expr::StagedParseJobMarker` for exclusive
  literal lowering and `rust/linkedspec-runtime/src/staged_parse_job.rs` for exact text plus typed direct/ordered-
  derived provenance. The marker is inert and detached: it owns no parser, registry, source snapshot, callback,
  scheduler, cache, path, or host authority. Canonical CI requires the exact test path once and Rust rollout is
  complete. Probe `rust/linkedspec-runtime/src/staged_ast_enrichment.rs` through `StagedAstEnrichmentSeed`,
  `FrozenStagedRegistry`,
  `staged_job_identity`, `staged_cache_identity`, `staged_current_depth_order`, `enrich_current_depth`, and
  `enrich_recursively`: the
  snapshot must already contain candidate outcomes and compiled callbacks; the resolver may not load or query.
  Exact cfg proof covers the neutral resolution/authority/cache/current-depth/result/failure cases, atomicity,
  sibling isolation, detachment, breadth-first next-depth scheduling, exact cycle/strict-decrease chains, shared
  cancellation/deadline/step/call/depth/result/diagnostic limits, expiring callback safe points, direct/ordered-
  derived rebasing, and adversarial denials. `StagedAstEnrichmentSeed::start` constructs a fresh registry/cache and
  recursive authority for every top-level native, reconstructed, generated-plan, or emitted execution; completion
  occurs only after the parent result and returns the detached neutral record. No outer cfg, cfg-only export,
  check-cfg registration, or conditional dead-code allowance remains. Dart `.14.7.5.0` now freezes the next
  boundary without changing this Rust route.
- **Dart general-staged dormant boundary:** `FUTURE-PARITY-BACKLOG.14.7.5.0-.3` own
  `dart/test_dormant/staged_ast_enrichment_contract_test.dart`. Run fatal analysis and then the exact opt-in test
  from `dart/` through `bash ../tools/run_dart_project_data.sh`. Eighteen tests must pass and the nineteenth must
  fail only with `.4`'s `LINKEDSPEC_STAGED_AST_ENRICHMENT_DART_RED` fresh-carrier/production/admission/rollout
  list. Inspect compiled JSON: exact assignment-
  form `parse_job(...)` is one `ActionStagedParseJobExpr`, while residual generic calls reject. Inspect
  `runtime/staged_parse_job.dart` for detached marker materialization and `runtime/matching.dart` for lazy zero-
  width suffix instrumentation that proves capture boundaries before `SourceAuthority` converts them to Unicode-
  scalar spans. Inspect `runtime/staged_ast_enrichment.dart` for `FrozenStagedRegistry`, canonical job/cache
  identities, complete-depth target reservation/order, fresh sibling contexts, detachment, atomic policy stitching,
  `enrichStagedRecursively`, `StagedRecursiveAuthority`, strict lineage, shared resources, expiring `safePoint`,
  and direct/ordered-derived source rebasing.
  Native/reconstructed/generated-plan/emitted routes still preserve logical marker data only. The final
  `dart/test/staged_ast_enrichment_contract_test.dart` path and both canonical references must remain absent until
  `.14.7.5.4`; that leaf next owns only fresh carrier authority, the production seam, admission, and rollout. Because every admitted
  consumer snapshots the full neutral current projection, rerun both Perl and Rust consumers whenever any later
  backend lifecycle or governed mutation count moves.
- **Env knobs:** `LINKEDSPEC_TRACE_LEVEL` (level; `LINKEDSPEC_DUMP_VERBOSITY` is the fallback),
  `LINKEDSPEC_TRACE_FILE` (route to a file), `LINKEDSPEC_TRACE_MIRROR_STDOUT`, `LINKEDSPEC_TRACE_EMOJI`,
  `LINKEDSPEC_TRACE_RESET_FILE`.
- **⚠️ GOTCHA:** setting `$LinkedSpec::Trace::DUMP_VERBOSITY` directly does **nothing** — init is gated by
  `$TRACE_INITIALIZED` and reads the env var. Use the env var or `configure_trace`.

---

## 4. Shipped `tools/` scripts

### 4.1 `tools/inspect_spec_codegen.pl` — codegen inspection
- **WHAT:** inspect the compiled codegen / handler shapes a `.spec` produces, without hand-reading the
  emitter. **WHEN:** "what does this rule compile to?". **HOW:** `perl -Iperl tools/inspect_spec_codegen.pl`
  (run with no args for usage).

### 4.2 `tools/cross_check_spec_parsers.pl` / `tools/gen_oracle_corpus.pl`
- **WHAT:** `cross_check_spec_parsers.pl` compares the oracle (bootstrap) parser vs the candidate
  (`spec.spec`-generated) parser ([[bootstrapspec-vs-spec-spec-dual-path]]); `gen_oracle_corpus.pl`
  regenerates the frozen oracle fixtures used for cross-variant parity ([[rust-perl-output-oracle]]).
- **WHEN:** self-host divergence; Perl↔Rust parity work ([[cross-variant-output-parity]]).
- **HOW:** source `tools/project_data_env.sh`, then run `perl -Iperl tools/cross_check_spec_parsers.pl` or
  `perl -Iperl tools/gen_oracle_corpus.pl`. The latter's two subprocess-capture tempfiles explicitly select the
  initialized `TMPDIR`.

### 4.3 `tools/run_cli_conformance.pl` — backend-neutral primary CLI byte contract
- **WHAT:** execute any backend command array against `cli_conformance/manifest.json` in isolated per-case
  workspaces, capturing stdout/stderr separately and comparing exact bytes, exit status, and expected generated
  files. `{{COMMAND}}` substitutes only the allowed executable token/host wrapper difference.
- **WHEN:** changing a primary CLI, its help/errors/trace behavior, or the shared cross-backend command contract.
- **HOW:**
  ```bash
  source tools/project_data_env.sh
  PERL5LIB= perl tools/run_cli_conformance.pl \
    --display-command 'perl bin/linkedspec' \
    -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec
  ```
  Use `--case ID` before `--` for focused execution. The current baseline has 66 cases and the canonical gate runs
  Perl in both default and POSIX option environments. For the complete routed five-backend matrix, use
  `bash tools/run_primary_cli_matrix.sh`; it initializes and enters managed project storage itself.

### 4.3.1 `tools/test_perl_project_data_storage.sh` — Perl SSD-local storage oracle

- **WHAT:** inventory the 24 tracked Perl temporary-allocation owners and execute default/named `File::Temp`,
  explicit trace-file, and real CLI subprocess-workspace paths inside one managed run.
- **WHEN:** changing Perl tests, trace/log destinations, the neutral CLI runner, oracle capture, primary-matrix
  routing, or project-data lifecycle.
- **HOW:** `bash tools/test_perl_project_data_storage.sh`. It self-roots, works outside the checkout, checks actual
  filesystem device identity, locks inert path-value fixtures, and requires completed CLI scratch to disappear.

### 4.3.2 `tools/run_cargo_local.sh` — targeted Cargo inside repository storage

- **WHAT:** self-root, initialize project-data roots, enter one managed run, and execute the supplied Cargo
  arguments with repository-local `CARGO_HOME`, `CARGO_TARGET_DIR`, and temporary storage.
- **WHEN:** every targeted Rust fetch/build/test/check command that bypasses the complete Rust gate.
- **HOW:** `bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-core`. A locked offline
  dependency proof is `bash tools/run_cargo_local.sh fetch --manifest-path rust/Cargo.toml --locked --offline`.

### 4.3.3 `tools/test_rust_project_data_storage.sh` — Rust SSD-local storage oracle

- **WHAT:** lock the exact 17 tracked Rust temporary owners; verify temp/Cargo/target roots share the repository
  device; require all 195 locked registry packages offline; exercise traces, generated child Cargo workspaces, and
  actual copied-binary relocation.
- **WHEN:** changing Rust temp allocation, generated-source compilation, traces, Cargo caching, target selection,
  repository discovery, or the Rust local gate.
- **HOW:** `bash tools/test_rust_project_data_storage.sh`. `tools/run_rust_local.sh` invokes the oracle after the
  complete package/build proof and reuses those expensive results.

### 4.3.4 `tools/test_dart_project_data_storage.sh` — Dart SSD-local storage oracle

- **WHAT:** lock the exact 21 maintained Dart temporary owners, including non-ignored untracked sources before
  their first commit; verify managed temp/pub/generated/trace paths share
  the repository device; require all 47 hosted lockfile packages and hashes offline; and exercise representative
  native trace, emitted-source caller, and trace-control paths.
- **WHEN:** changing Dart temporary allocation, package resolution, generated-source callers, traces, `PUB_CACHE`,
  or the Dart local gate.
- **HOW:** `bash tools/test_dart_project_data_storage.sh`. `tools/run_dart_local.sh` invokes the oracle after the
  complete package-test proof and reuses that result.

### 4.3.5 Julia targeted commands and SSD-local storage oracle

- **WHAT:** `tools/run_julia_project_data.sh` executes one Julia command with repository-derived managed temp and
  retained depot storage; `tools/test_julia_project_data_storage.sh` locks all 20 tracked temporary owners, the
  five external Manifest package trees, actual filesystem devices, offline source resolution, generated v2 source,
  trace output, cleanup, and absence of disposable machine-path usage metadata.
- **WHEN:** use the targeted wrapper for every Julia command that bypasses `tools/run_julia_local.sh`; run the oracle
  when changing Julia temp allocation, depot/package behavior, generated output, traces, or Julia gate routing.
- **HOW:** `bash tools/run_julia_project_data.sh --project=julia -e 'using LinkedSpecJulia, JSON3'` and
  `bash tools/test_julia_project_data_storage.sh`. The complete Julia gate invokes and reuses the oracle.

### 4.3.6 Lua targeted commands and SSD-local storage oracle

For inter-match-gap work, first run `bash tools/check_inter_match_gap_capture_six_runtime.sh`, then use the
targeted wrapper below for byte-identical PUC-Lua/LuaJIT parser/compiler/runtime probes. The behavior-free `.6.0`
baseline is numeric-selector success, raw-invalid named declarations/selectors/`@capture_gaps`, unsupported future
helpers, `LS` before selection, and legacy preceding-slot events after accepted action/target execution before
`LE`. Preserve that legacy timing: the frozen plan gives capture-enabled rules a separate preselection seam and
extends the existing recognition frame/token, normalized `SpecFile`, `SourceAuthority`, generated-v2 emitter, and
primary adapter. See [[inter-match-gap-lua-implementation-plan]].

- **WHAT:** `tools/run_lua_project_data.sh` builds disposable native modules and runs one PUC Lua or LuaJIT command
  under repository-derived managed scratch; `tools/test_lua_project_data_storage.sh` locks all 17 Lua-family
  allocation owners, both ABI module pairs, actual device identity, generated v2 source, trace output, hostile
  other-filesystem builder rejection, quoted-path handling, and cleanup.
- **WHEN:** use the targeted wrapper for a Lua command that bypasses `tools/run_lua_local.sh`; run the oracle when
  changing Lua temp allocation, native builds, generated-source workspaces, traces, or Lua gate routing.
- **HOW:** `bash tools/run_lua_project_data.sh puc -e 'local l = require("linkedspec"); print(l.backend_name())'`,
  `bash tools/run_lua_project_data.sh luajit lua/test/rule_local_cursor_descriptor_test.lua`, and
  `bash tools/test_lua_project_data_storage.sh`. The complete Lua gate invokes the oracle and reuses its ABI builds.

### 4.3.7 Python/tool output and SSD-local storage oracle

- **WHAT:** `tools/run_python_project_data.sh` runs one repository-relative Python checker with managed scratch and
  retained `PYTHONPYCACHEPREFIX`; `tools/test_tool_project_data_storage.sh` freezes three Python temporary owners,
  14 shell allocator owners, and 31 Python tool entrypoints while exercising Python bytecode, Unicode-generator
  scratch, Knowledge Map output, mdBook destinations, CLI workspaces, TAP, and oracle capture boundaries.
- **WHEN:** use the targeted wrapper for every maintained Python checker command; run the oracle when changing
  Python imports/tempfiles, shell allocation, Knowledge Map configuration/output, mdBook output, conformance,
  TAP, or oracle generation.
- **HOW:** `bash tools/run_python_project_data.sh tools/check_unicode_case_contract.py` and
  `bash tools/test_tool_project_data_storage.sh`. Hostile another-filesystem destinations are read only to prove
  rejection, never created; same-filesystem outputs are checked before and after writing.

### 4.3.8 `tools/test_repo_root_process_portability.sh` — recurring moved-checkout oracle

- **WHAT:** compose the structural path doctrine, a Rust copied-primary integration test, and exact named-spec
  primary execution for Perl, Dart, Julia, and Lua. The Rust test creates distinct moved and ambient repositories,
  requires the executable-adjacent sentinel result, then removes the moved marker and requires exact failure.
- **WHEN:** changing repository-root discovery, primary entrypoint anchoring, bundled named-spec resolution,
  project-data routing, or canonical CI topology.
- **HOW:** `bash tools/test_repo_root_process_portability.sh`. It self-roots, enters managed repository storage,
  chooses a same-filesystem cwd outside the checkout, uses the supported Dart/storage environments, builds Lua
  native modules below managed scratch, and requires exact output from all five runtime families. Canonical local
  CI invokes this composed boundary once; `rust/linkedspec-runtime/tests/repository_root_relocation.rs` is the Rust
  integration owner.

### 4.4 `tools/run_ci_local.sh` / `tools/ram_guard.sh`
- **WHAT:** `run_ci_local.sh` = the canonical local CI gate (doctrines + primary CLI conformance in default/POSIX
  environments + regression, E4); `verification_receipt.sh` binds a successful run to exact `HEAD` plus staged
  tree; `ram_guard.sh` = a memory guard for heavy runs. **HOW:** stage the complete canonical candidate with no
  unstaged/untracked inputs, then run `bash tools/run_ci_local.sh`. The gate self-roots, initializes repository-
  filesystem project data, and writes the receipt only after every check passes. Ordinary focused commits do not
  run this complete gate; `.githooks/pre-push` requires or runs it for exact clean `HEAD`.

### 4.4.1 `tools/project_data_env.sh` — repo-filesystem project state

- **WHAT:** a sourceable environment initializer that derives the current checkout, creates ignored disposable
  `/.linkedspec-data/scratch/` and retained `/.linkedspec-data/cache/` roots, exports temp, Cargo, Dart package/home,
  Julia, and Python bytecode storage variables, captures inherited `TMPDIR` once as runtime-only host authority,
  provides a same-filesystem output validator, and hands standard entrypoints to the managed-run wrapper.
- **WHEN:** before a direct development, generation, test, or package command can create project-owned state.
  Standard hook/doctrine/Knowledge Map/canonical/backend runners source it automatically; source it manually only
  for lower-level commands that bypass those routed boundaries.
- **HOW:** `source tools/project_data_env.sh`. Same-filesystem caller overrides are preserved; another-filesystem
  override is replaced after device validation. Use `bash tools/project_data_run.sh COMMAND [ARG ...]` for a direct
  foreground command with managed scratch. Run `bash tools/test_project_data_env.sh`,
  `bash tools/test_project_data_lifecycle.sh`, and `bash tools/test_project_data_workflow_routing.sh` for the focused
  environment, lifecycle, and routed-entrypoint outside-cwd proofs. Build the book through
  `bash tools/run_mdbook_local.sh`.
- **OUTPUT:** no normal stdout. The current shell receives `LINKEDSPEC_*` roots, `TMPDIR`/`TMP`/`TEMP`, Cargo
  home/target, Dart package-cache, Julia depot, and Python bytecode-cache exports. `LINKEDSPEC_HOST_TMPDIR` plus its
  capture marker preserve pre-routing host authority for nested containment proof only; project writers must not
  use that value. The helper refuses direct execution because exports must affect the caller shell.

### 4.4.2 `tools/project_data_run.sh` — per-run scratch lifecycle

- **WHAT:** a foreground wrapper that creates one checkout-namespaced `mktemp` run directory, redirects standard
  temporary variables into it, runs the command and descendants in a dedicated process group, retains reusable
  caches, and validates a marker-v2 ownership record before exact cleanup.
- **WHEN:** automatically at every standard hook/doctrine/Knowledge Map/canonical/backend/book boundary, or
  manually around a direct command. Success and default failure delete scratch. Set
  `LINKEDSPEC_FAILED_RUN_POLICY=retain` only when a failed run should survive for diagnosis.
- **HOW:** `bash tools/project_data_run.sh --list` reports owned leftovers; `--recover` removes only dead abandoned
  runs; `--purge-failed` explicitly removes dead retained failures. The wrapper waits for its process group to
  drain and forwards HUP/INT/TERM to that complete group. Recovery and purge refuse a live or possibly reused
  group and recheck immediately before removal. Legacy/invalid/group-mismatched markers, indeterminate `starting`
  markers, symbolic links, and other checkout namespaces are never deleted automatically.
- **PROOF:** `bash tools/test_project_data_lifecycle.sh` covers success/default-failure cleanup, cache retention,
  explicit failure retention/purge, concurrent unique runs, background-descendant drain, direct-child plus
  descendant signal forwarding, abrupt wrapper/direct-child loss, live-group recovery denial, drained-group
  recovery, marker-version/group rejection, indeterminate-start refusal, non-executable shell entrypoints, and
  checkout isolation. The durable RED-to-green record is `docs/knowledge/project-data-descendant-liveness-gap.md`.

### 4.5 `tools/check_unicode_case_contract.py` — pinned Unicode casing proof

- **WHAT:** verifies exact decompressed Unicode 17.0.0 source hashes, regenerates the neutral full-casing contract
  and generated backend modules into owned temporary storage, byte-compares them, validates the neutral
  schema/counts/order/scalars/digest, and independently executes expansions, combining output, supplementary
  characters, `Final_Sigma`, and no-normalization fixtures.
- **WHEN:** changing `lowercase`/`uppercase`, Unicode data, generated backend tables, or diagnosing a casing mismatch.
- **HOW:** `bash tools/run_python_project_data.sh tools/check_unicode_case_contract.py`. Regenerate deliberately with
  `python3 unicode_case/generate_unicode_case_contract.py`; ordinary verification is offline.
- **OUTPUT:** `unicode-case-contract: OK (Unicode 17.0.0; 1563 lower; 1581 upper; 158/464 property ranges; 12 fixtures)`.

### 4.6 `tools/check_scalar_numeric_contract.py` — portable scalar numeric proof

- **WHAT:** validates `linkedspec-scalar-numeric-v1` schema/policy, independently evaluates all structured cases,
  and deterministically regenerates the backend-neutral `.spec` fixture and expected result object.
- **WHEN:** changing numeric input coercion, helper arity, invalid/null behavior, comparisons, rounding, min/max,
  clamp/division fences, or signed modulo in any backend.
- **HOW:** `bash tools/run_python_project_data.sh tools/check_scalar_numeric_contract.py`.
- **OUTPUT:** `scalar-numeric-contract: OK (55 cases; 18 canonical helpers)`.

### 4.7 `tools/check_scalar_numeric_six_runtime.sh` — exact six-runtime numeric admission

- **WHAT:** composes the neutral checker with direct unchanged-fixture execution through Perl, Rust, Dart, Julia,
  PUC Lua, and LuaJIT.
- **WHEN:** changing a scalar numeric adapter, its dispatch seam, or the neutral fixture; use it before claiming
  cross-runtime admission rather than inferring agreement from backend-local happy paths.
- **HOW:** `bash tools/check_scalar_numeric_six_runtime.sh`.
- **OUTPUT:** `[scalar-numeric-six] all six runtimes match all 55 cases` after every focused leg and the complete
  dual-ABI Lua gate pass.

### 4.8 `tools/check_callable_signature_contract.py` — portable variadic signature proof

- **WHAT:** validates `linkedspec-callable-signature-v1`, the chosen `...rest` definition syntax, version-1 fixed
  versus version-2 variadic descriptor shapes, positional call binding/diagnostics, purpose-specific open-bound
  helpers and effective receiver arity, and the deterministic future `.spec` fixture.
- **WHEN:** changing function-definition syntax, staged function metadata, call resolution, rest-array binding,
  user-function diagnostics, descriptor projection, or fixed/variadic helper and method signatures.
- **HOW:** `bash tools/run_python_project_data.sh tools/check_callable_signature_contract.py`.
- **OUTPUT:** `callable-signature-contract: OK (3 definitions; 9 calls; 7 invalid definitions)`.
- **PERL ADAPTER:** `PERL5LIB= prove -Iperl t/variadic_user_function_contract.t` consumes the same fixture through
  the spec-owned shell, staged/outward records, generated source, eager/fresh binding, diagnostics, and execution.

### 4.9 `tools/check_semantic_introspection_contract.py` — neutral model/query oracle

- **WHAT:** validates `linkedspec-semantic-model-v1`, `linkedspec-semantic-query-v1`, the owned backend-admission
  topology. It checks the exact schema, source bytes/spans/digests, normalized records/relations, staged payload/job/
  result topology, deterministic query evaluation, digest-locked responses, rollout/admission omissions, privacy,
  budgets, the handle-only MCP boundary, and the public current-state contract; backend-native semantics remain
  owned by each admitted consumer.
- **WHEN:** changing semantic-index vocabulary, ids/order, calls/shapes, staged/generated provenance, explanations,
  source policy, pages/budgets, backend rollout metadata, or future native/MCP consumers.
- **HOW:** `bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py`.
- **OUTPUT:** `semantic introspection contract: 6 fixture groups, 20 exact queries, 128 rejected mutations, rollout 9 complete / 0 pending, admission 6 complete / 0 pending`.
- **PUBLIC NO-DRIFT:** the same independent checker requires 28 current documents, nine worked example families,
  native and MCP six-runtime recurring drivers, and the accepted-but-unscaffolded backend-companion boundary. It
  rejects omitted surfaces/markers, stale current claims, example drift, recurring-proof loss, companion-boundary
  drift, and public rollout/owner rollback.
- **PERL AUTHORITY MAP:** `.10.3.0` proves the first adapter must compose strict decoded source/canonical UTF-8
  bytes, `return_descriptor`, typed ActionIR, staged function records, `runtime_ctx_ref` failures, and generated-v2
  plan metadata. Decode byte input before probing Unicode labels; do not treat generated metadata or text trace as
  a semantic snapshot. See [[perl-semantic-introspection-authority-map]].
- **STATIC-FACT CROSS-CHECK:** the checker reads `linkedspec-rule-local-cursor-v1` and derives family/cursor,
  repetition, marker, and normalized ownership from exact rule headers plus edge records. This prevents a model
  edit and matching response-hash refresh from preserving a stale but internally consistent oracle. See
  [[semantic-introspection-static-rule-authority]].
- **GENERATED-PLAN CROSS-CHECK:** the checker reads that contract's generated-source-v2 identity and ten-family
  authority. The calls fixture's exact default header must project family `default`; illegal or coordinated wrong
  families fail independently of response hashes. See [[semantic-introspection-generated-plan-authority]].
- **SPEC-IDENTITY CROSS-CHECK:** every semantic `spec.name` derives from the caller-registered fixture logical
  name, never its snapshot id or an implicit path. See [[semantic-introspection-spec-name-authority]].
- **PERL SOURCE FOUNDATION:** `PERL5LIB= prove -Iperl t/semantic_index_perl_foundation.t` verifies the `.10.3.1`
  constructor boundary: decoded/raw strict-UTF-8 convergence, canonical byte/scalar coordinates, opaque clone-safe
  state, compiled and failed outcomes, logical-name-only identity, malformed-byte rejection, and no path option.
  It does not prove records, queries, execution observations, or backend admission. See
  [[perl-semantic-index-source-foundation]].
- **RUST SOURCE FOUNDATION:** `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_index_foundation`
  verifies the `.10.4.1` constructor boundary: copied decoded/strict-UTF-8 input, exact byte/scalar coordinates,
  source-ceiling enforcement, opaque clone-safe parsed/validated/compiled-or-failed authority, exact entry identity,
  shared generated-v2 plan input, malformed-byte/option rejection, and target-execution absence. It exposes no v1
  records/query, runtime observation, host compiler object, implicit path, or backend admission. See
  [[rust-semantic-index-source-foundation]].
- **PERL STATIC PROJECTION:** `PERL5LIB= prove -Iperl t/semantic_index_perl_static_projection.t` verifies the
  `.10.3.2.1` private static graph/diagnostic layer. It materializes internal source keys and deep-compares graph,
  Unicode privacy full/limited, failed compilation, and runtime-static records/relations with the neutral oracle;
  it also proves clone isolation and no coderef/compiled-regex/object/path leakage. Public query is covered by the
  separate evaluator test below; runtime observation and composed admission are covered by their focused tests. See
  [[perl-semantic-static-projection]].
- **PERL CALL/STAGED PROJECTION:** `PERL5LIB= prove -Iperl t/semantic_index_perl_calls_projection.t` verifies
  `.10.3.3.1.1`. It deep-compares the complete corrected calls target (22 records / 25 relations), then locks typed
  preorder, user-function resolution, bounded shape inference, staged role/direction, the shared generated-family
  owner, clone/JSON safety, host-IR/generated-source denial, multibyte function coordinates, and interleaved
  function-shell masking. Public query, runtime observation, rollout, and admission are covered separately. See
  [[perl-semantic-call-staged-projection]].
- **PERL CAPABILITIES/QUERY:** `PERL5LIB= prove -Iperl t/semantic_index_perl_query.t` verifies the public opaque-index
  surface. It matches all 19 non-runtime canonical response digests, exact
  capabilities/list/get/relations/explain behavior, request validation and portable errors, source ceilings/
  redactions/digests, after-id pages, filtered directional BFS, record/relation/depth budgets and logical costs,
  clone isolation, silence, no host/path leakage, and successful queries with compilation disabled. See
  [[perl-semantic-query-evaluator]].
- **RUST CAPABILITIES/QUERY:** `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_index_query`
  verifies the public opaque-index static surface. Its five tests match all 19 non-runtime canonical response
  digests through typed `SemanticQuery` and raw-neutral JSON, cover the exact 26 request/error boundaries, and lock
  source ceilings/redactions/digests, pages, filtered directional BFS, logical budgets/costs, explanations,
  deterministic clone/input isolation, absent runtime observations, and host/path/IR denial. See
  [[rust-semantic-query-evaluator]].
- **PERL RUNTIME OBSERVATION:** `PERL5LIB= prove -Iperl t/semantic_index_perl_runtime_observation.t` verifies
  `.10.3.5`. Its 106 assertions match the twentieth response digest across eight execution roles, preserve exact
  result/input/cursor and generated-plan behavior, reject malformed or foreign observations, and prove semantic
  capture does not perturb results, exception identity, trace, or diagnostics. See
  [[perl-semantic-runtime-observation]].
- **RUST RUNTIME OBSERVATION:** `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_index_runtime_observation`
  verifies `.10.4.5`. Its seven tests match the twentieth response digest through typed and raw-neutral queries
  across direct, loaded, reconstructed, generated-plan, source-emitter, traced/untraced, and independently compiled
  emitted-module routes. They also lock typed schema/topology rejection, immutable base/event/response isolation,
  query non-execution, exact observer panic identity, Unicode-scalar positions, trace/diagnostic neutrality, quiet
  no-sink execution, and no false completion after failed entry selection. See
  [[rust-semantic-runtime-observation]].
- **PERL COMPOSED ADMISSION:** `PERL5LIB= prove -Iperl t/semantic_introspection_perl_admission.t` verifies
  `.10.3.6`. Its 12 exact-once roles cover strict byte/text source normalization, compiled and failed snapshots,
  direct/loaded/generated/traced runtime routes, native and neutral JSON, all 20 exact query digests, query
  non-interference, privacy/page/budget/error/explain behavior, and stale host-leak denial. The checker locks the
  consumer path, ordered roles, canonical driver and registration, Perl-only rollout/admission promotion, and the
  exact current-state claims in this section.
- **RUST COMPOSED ADMISSION:** `cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test semantic_introspection_rust_admission`
  verifies `.10.4.6`. Its 12 exact-once roles compose all 20 digests across strict byte/text source normalization,
  compiled/failed/runtime snapshots, loaded and reconstructed execution, generated-plan/source-emitter direct and
  traced routes, typed/native-neutral JSON, privacy/pages/budgets/errors/explain, no-execute immutability, and host-
  leak denial. The checker locks the consumer path, ordered roles, canonical driver/registration, and Rust-only
  rollout/admission promotion with eight Rust-specific mutations.
- **DART COMPOSED ADMISSION:** `bash ../tools/run_dart_project_data.sh test test/semantic_introspection_dart_admission_test.dart` from `dart/`
  verifies `.10.5.6`. Its 12 exact-once roles compose every Dart semantic route: strict byte/text normalization,
  compiled/failed/runtime snapshots, loaded and JSON-reconstructed state, generated-plan/public-helper/standalone-
  emitted direct and traced execution, typed/native-neutral JSON, all 20 digests, privacy/pages/budgets/errors/
  explain, no-execute immutability, and host-leak denial. The checker locks its exact path, ordered roles,
  canonical driver/registration, and Dart-only rollout/admission promotion with eight Dart-specific mutations.
- **JULIA AUTHORITY / UNICODE PREFLIGHT:** `.10.6.0` finds no existing Julia semantic API. Build the future opaque
  index from staged `SpecFile`/function sidecars, `CompiledSpec`, typed action/contracts, portable diagnostics,
  generated-v2 plan, and direct runtime slot/result seams; do not use the outward descriptor, resolved loader
  path, mutable `Vector`/`Dict` identity, or trace text as semantic authority. `SourceSpan` is line-only,
  `ActionSourceSpan` is action-local scalar offset, compiled definition order omits functions, invalid Julia
  `String` values need explicit rejection, and raw numeric validation must fence `Bool <: Integer`. Before index
  construction, replace all five host-PCRE2 `\w` label patterns and validate reconstructed/programmatic labels:
  current Unicode 16 tables miss 5,175 required Unicode 17 `XID_Continue` scalars, admit 923 forbidden scalars,
  reject required `A·B`, accept forbidden `²`, and permit external-AST target bypass. See
  [[julia-semantic-introspection-authority-map]] and [[julia-unicode-rule-label-preflight]].
- **JULIA UNICODE CORE:** `.10.6.1.1` implements the behavior-free `.0` plan. Internal generated
  `julia/src/spec/UnicodeRuleLabel.jl` carries all 806 pinned endpoints, metadata, binary-search classification,
  complete validation, and a `nextind`-safe prefix scan; the independent Unicode checker regenerates and
  byte/endpoint-compares it. Julia's five label-bearing host regexes are gone. Shared header/action/blind/bare
  scanners own punctuation/remainders, malformed arrows stay raw, third-colon prefixes reject, and validation
  covers parsed/programmatic/reconstructed declarations and every target kind with `invalid_rule_label` /
  `validate_rule_labels`. Run the two focused Julia test files through `include`, then `tools/run_julia_local.sh`.
  Exact identity `.10.6.1.2` is now owned by `julia/test/unicode_rule_label_identity_routes_test.jl`: it derives
  ten unique labels from all 9 positives/2 distinct pairs and checks AST/compiled/JSON/descriptor/plan,
  reconstructed/direct/generated/emitted/loaded execution, selectors, diagnostics, trace, and inline/file primary
  routes. Negative/isolation `.10.6.1.3` is owned by
  `julia/test/unicode_rule_label_negative_isolation_test.jl`: it consumes all 8 negatives across source, both AST
  trust routes, all four label roles, selectors, loaders, primary commands, and artifact denial, then locks
  function/parameter/ActionParser/lifecycle/mark/regex/mode isolation. Run all four Unicode test files for focused
  3,831; complete Julia is 7,542/primary/105. Closeout `.10.6.1.4` reruns those committed suites, the complete Julia
  gate, 5x2x66 plus all ten manifest legs, and Unicode/semantic/capability/generated/public no-drift without adding
  code or tests. It passes canonical Rust/Dart/primary/Phase 0, closes `.10.6.1`, and hands off only to behavior-free
  source/outcome plan `.10.6.2.0`. Use a writable depot first; never infer membership, identity, or adjacent-grammar
  behavior from host PCRE2 examples.
- **JULIA SOURCE/OUTCOME PREFLIGHT:** `.10.6.2.0` freezes the behavior-free foundation boundary before code.
  Probe `parse_spec_with_staged_user_function_definitions`, `validate_spec`, `compile_spec(...;
  validate_source=false)`, `resolve_entry_rule`, and `build_generated_rule_plan` directly on the neutral graph,
  calls, privacy, failed, and runtime sources. Reject malformed Julia `String` and byte input before those owners:
  invalid strings otherwise fail inconsistently as `InvalidCharError`, `SpecParseException`, or staged parser
  failure. Do not use `SpecLoader` for identity; it retains resolved host paths. Do not use compiled-state or
  descriptor JSON as a clone: both expose live order vectors, and mutating the returned projection mutates
  `CompiledSpec`. The frozen implementation order is source-only copied UTF-8/map/ceilings `.10.6.2.1`, one staged
  compiled-or-failed outcome and generated-v2 plan `.10.6.2.2`, then composed no-path/no-target-execution signoff
  `.10.6.2.3`. Fence `Bool` before any `Integer` acceptance. See
  [[julia-semantic-introspection-authority-map]].
- **JULIA SOURCE FOUNDATION:** `.10.6.2.1` implements only copied valid `AbstractString` / strict
  `AbstractVector{UInt8}` input, the private canonical byte/scalar map, SHA-256 identity, four ceilings, typed
  errors/values, exact span/excerpt/occurrence accessors, and redacted opaque display. Run:
  `bash tools/run_julia_project_data.sh --project=julia -e
  'using LinkedSpecJulia,Test; include("julia/test/semantic_index_source_foundation_test.jl")'`. Its 135 assertions
  cover ASCII, supplementary/combining text, CRLF/EOF, duplicates, caller mutation, malformed strings/bytes,
  invalid names/selectors/ceilings/ranges/needles, mid-scalar coordinates, explicit `Bool` rejection, ceiling
  denial, detached JSON, constructor opacity, and display/privacy. Deliberately invalid grammar must still construct:
  this leaf contains no parser/compiler call. Use `source_identity`, `source_span_for_bytes`,
  `source_span_for_scalars`, `source_excerpt_for_bytes`, and `locate_exact`; do not inspect private fields or infer
  filesystem identity. Compiled outcomes remain solely `.10.6.2.2`.
- **JULIA COMPILATION FOUNDATION:** `.10.6.2.2` extends that same opaque owner after strict source construction.
  `semantic_snapshot`, `compilation_authority`, `compilation_diagnostic`, `entry_selection`, and
  `generated_plan_input` expose immutable detached state only. Construction performs exactly one staged
  user-function-aware parse, validation, `compile_spec(...; validate_source=false)`, entry resolution, and shared
  generated-v2 plan pass; it merges typed function/rule authorship privately because compiled rule order omits
  functions. Ordinary language failures become `failed_compilation` snapshots with exact native diagnostics;
  interrupt/OOM/stack-overflow remain fatal. Run both semantic-index test files together for 220 assertions. The
  production/test source scans must continue to deny `SpecLoader`, path IO, target/generated execution, runtime,
  trace, diagnostic/observation sinks, descriptor projection, records, and query. See
  [[julia-semantic-introspection-authority-map]].
- **JULIA FOUNDATION CLOSEOUT:** `.10.6.2.3` adds no production or replacement test code. Re-run the two commands
  above as one 220-assertion composition, then `bash tools/run_julia_local.sh`, the 5x2x66 primary matrix, all ten
  Unicode-manifest legs, and the Unicode/semantic/capability/generated/public no-drift checks. The committed
  composition passes Julia 7,762/primary/105 and canonical Rust 80.84s + Dart 1/1 + primary 66x2 + Phase 0
  1,031/630s. Parent `.10.6.2` is closed without records, query, runtime observation, target execution, or semantic
  promotion; `.10.6.3.0` owns the next behavior-free static-projection plan.
- **JULIA STATIC-PROJECTION PREFLIGHT:** `.10.6.3.0` freezes five private targets before projector code: graph
  12 records / 14 relations, privacy `text` 4/3, privacy `identity` 4/3, failed 6/4, and runtime-static 7/8 with
  execution/event state removed. Probe the retained source/outcome owner and typed parsed/compiled state directly;
  all 14 neutral graph/privacy/failed/runtime source references already match Julia's byte/scalar map. Normalize
  Julia `Default` away from its native repetition flag because neutral v1 treats `Default`/`And`/`Single`/`Pipe`
  as non-repeating. Do not enumerate `CompiledRule.regex_patterns`: it contains parent matchers attached to cross-
  rule edges. Scan complete authored members, retain ordinary or self-indexed structural slots, and correlate them
  to typed compiled edges/lifecycle payloads. Keep native `bare_edge_target_undefined` / `normalize_edges` on the
  foundation; projection alone emits neutral `unknown_rule_reference` / `compile` decision/explanation evidence.
  Implementation is exact graph `.10.6.3.1`, privacy/failure/runtime-static/isolation `.2`, then composition `.3`,
  without a public projection/query, execution, trace, observation, generated-format, rollout, or admission change.
  Plan signoff passes focused 220, Julia 7,762/primary/105, 5x2x66, ten Unicode legs, KM 683/5,188, book/
  doctrines, canonical Rust 78.75s + Dart 1/1 + primary 66x2 + Phase 0 1,031/632s, and exact 1.56-GB cleanup.
  Graph `.10.6.3.1` now implements that private boundary. Run
  `include("julia/test/semantic_index_static_graph_test.jl")` with the two foundation suites for 70 new / 290
  focused assertions. The test seam `_semantic_static_projection_for_testing(index)` is deliberately private and
  returns a fresh detached dictionary/array tree; public callers must not depend on it. Exact proof is 12 records,
  14 relations, seven materialized source references, two distinct Child regex slots, zero Top slots despite its
  two compiled parent matchers, and neutral non-repeating Default. Complete signoff is Julia 7,832/primary/105,
  5x2x66, ten Unicode legs, unchanged semantic ledgers, canonical Rust 78.38s + Dart 1/1 + primary 66x2 + Phase 0
  1,031/641s. Remaining-target leaf `.10.6.3.2` is now exact. Run
  `include("julia/test/semantic_index_static_remaining_test.jl")` with the three earlier suites for 99 new / 389
  focused assertions. It deep-equals privacy text 4/3, privacy identity 4/3, failed 6/4, and runtime-static 7/8;
  proves native failure preservation under projection-only neutral normalization, repeated-lifecycle occurrence
  ids/order/shapes/source, no execution/events, generic parse/entry fallback, detached copies, tuple immutability,
  plain JSON, private surface omission, and host/path/loader/emitter/executor/trace/sink/observer denial. Complete
  signoff is Julia 7,931/primary/105, 5x2x66, ten Unicode legs, unchanged semantic ledgers, canonical Rust 78.27s +
  Dart 1/1 + primary 66x2 + Phase 0 1,031/697s. Use no-change `.10.6.3.3`, not replacement projector tests, for
  five-target recomposition and parent closeout. That closeout now passes the same committed four-suite focused
  389, complete Julia 7,931/primary/105, both full matrices, unchanged no-drift ledgers, and canonical Rust 80.89s
  + Dart 1/1 + primary 66x2 + Phase 0 1,031/653s without production/test replacement. Parent `.10.6.3` is closed;
  behavior-free `.10.6.4.0` now maps calls/staging/generated authorities before projection code. Retrieve
  [[julia-semantic-call-staged-projection-plan]], then probe `_semantic_authored_definition_order`, the compiled
  function registry, `parse_action_block` plus `resolve_action_block_contracts`, compiled edge `action_ast`, staged
  body payload/job/result, and `generated_plan_input`. Expect exact 22 records / 25 relations: static base 6/6,
  typed core 18/16, and staged/generated completion +4/+9. `definition_order` is rule-only; merge exact authored
  function/rule starts. `ActionSourceSpan` is normalized-action-local scalar space; use typed outer-before-inner
  traversal plus a bounded occurrence-safe raw-source scanner, never direct offset addition. Require reparsed typed
  function body JSON to equal retained staged `body_ast`, resolve users before the three neutral helpers, infer
  shapes conservatively, deliberately normalize native sidecar fields to ADR `0050`, and select only the retained
  entry plan row. `.10.6.4.1` owns private typed core, `.2` staged/generated completion, and `.3` no-change closeout.
  Plan signoff is focused 389, Julia 7,931/primary/105, 5x2x66, ten Unicode legs, unchanged ledgers, KM 684/5,231,
  canonical Rust 77.84s + Dart 1/1 + primary 66x2 + Phase 0 1,031/625s, and exact 1.56-GB cleanup preserving 517
  Pgen artifacts. Typed core `.10.6.4.1` now lives in `julia/src/semantic/SemanticCallProjection.jl` and composes
  before `_semantic_static_canonicalize!`/freeze. Use `julia/test/semantic_index_call_core_test.jl` to probe exact
  18/16 equality, authored/Unicode source, nested occurrence identity, regex-literal isolation, signatures, shapes,
  lifecycle immutability, and public/host/no-execution fences. The source scanner is location-only and must remain
  driven by typed preorder. New 79/focused 468, Julia 8,010/primary/105, 5x2x66, ten Unicode legs, unchanged
  ledgers, canonical Rust 77.41s + Dart 1/1 + primary 66x2 + Phase 0 1,031/622s, mdBook/KM 685/5,252, and exact
  1,618,660-KiB cleanup preserving 517 Pgen artifacts pass. `.10.6.4.2` now extends only this owner. Use
  `julia/test/semantic_index_call_staged_test.jl` to probe exact full 22/25 equality, native sidecar correlation,
  generated-v2 contract/identity/order/selection rejection, detached lifecycle, and implementation/source/AST/
  execution/trace denial. The projector validates native payload and typed parse-job fields before emitting three
  neutral staged roles, then validates the retained plan and emits only its selected handler family. It does not
  rebuild the plan, emit source, or expose sidecar/body-AST values. New 62/focused 530, Julia
  8,072/primary/105, 5x2x66, ten Unicode legs, unchanged ledgers, and canonical Rust 76.95s + Dart 1/1 + primary
  66x2 + Phase 0 1,031/622s pass. No-change `.10.6.4.3` recomposes those same six suites at focused 530 and passes
  Julia 8,072/primary/105, 5x2x66, ten Unicode legs, unchanged ledgers, and canonical Rust 77.68s + Dart 1/1 +
  primary 66x2 + Phase 0 1,031/622s. Parent `.10.6.4` is closed: do not add a second call projector. Query audit
  `.10.6.5.0` is now frozen. Retrieve [[julia-semantic-query-authority-map]] before query work. The evaluator may
  consume only one fresh `_semantic_static_projection_for_testing`-equivalent materialization, never the retained
  index/compiler/source/host owners. Recheck the 19 static contract hashes with
  `tools/check_semantic_introspection_contract.py`; use admitted Perl/Rust/Dart/Julia query suites as the executable
  boundary reference; require all 26 raw-neutral errors; and test `Bool` before `Integer` in Julia. `.10.6.5.1`
  owns the private record/source kernel, `.2` traversal/pages/budgets/costs, `.3` complete public typed/raw-neutral
  exposure, and `.4` no-change closeout. Runtime events remain `.10.6.6`. See
  [[julia-semantic-static-projection-plan]]. Audit signoff is neutral 6/20/81, focused Julia 530 plus detached
  22/25/10, Julia 8,072/primary/105, primary 5x2x66, ten Unicode legs, unchanged ledgers, canonical Rust/Dart
  admission + primary 66x2 + Phase 0 1,031/655s, book/KM 687/5,277, doctrines, and exact 1,812,240-KiB cleanup
  preserving 517 Pgen artifacts.
  Private `.10.6.5.1` is now implemented; retrieve [[julia-semantic-query-kernel]] before changing it. Run
  `julia/test/semantic_index_query_kernel_test.jl` with the six earlier semantic suites to prove new 100/focused
  630, nine exact hashes, one materialization call, recursive immutability, fresh JSON clones, source privacy,
  private omission, and no forbidden authority. `_semantic_static_projection_materialize` is the production-private
  clone seam; do not pass `SemanticIndex` internals to `_semantic_query_kernel_evaluate`. Relations, cursor/page,
  At that historical boundary, budgets/cost prefixes and ten remaining hashes stayed `.2`; public typed/raw-neutral
  entry points stayed `.3`.
  Complete `.1` signoff is Julia 8,172/primary/105, primary 5x2x66, ten Unicode legs, unchanged ledgers, canonical
  Rust 80.95s + Dart 1/1 + primary 66x2 + Phase 0 1,031/662s, book/KM 688/5,287, doctrines, and exact
  1,613,088-KiB cleanup preserving 517 Pgen artifacts.
  Private traversal `.10.6.5.2` is now implemented; retrieve [[julia-semantic-query-traversal]] before changing it.
  Run `julia/test/semantic_index_query_traversal_test.jl` after the seven earlier suites for new 118/focused 748.
  `_semantic_query_page_stream` addresses the filtered primary stream and selects the page/budget minimum;
  `_semantic_query_traverse_relations` performs filter-constrained outgoing/incoming/both BFS with relation and
  visited-frontier deduplication before canonical-order projection. Relation-budget diagnostics precede depth when
  both bind; explain reserves one record unit for its decision. All 19 static hashes are exact, costs are logical,
  and the evaluator still receives one detached projection only. At that historical boundary, raw malformed
  boundaries and every public query export remained `.3`; runtime events remain `.10.6.6`. Complete signoff is
  Julia 8,290/primary/105, primary
  5x2x66, ten Unicode legs, unchanged ledgers, canonical Rust 82.53s + Dart 1/1 + primary 66x2 + Phase 0
  1,031/647s, book/KM 689/5,298, doctrines, and exact 1,613,224-KiB cleanup preserving 517 Pgen artifacts.
  Public completion `.10.6.5.3` is now implemented; retrieve [[julia-semantic-query-public-api]] before changing
  it. Run `julia/test/semantic_index_query_public_test.jl` after the eight earlier semantic suites to prove new
  315/focused 1,063, all 19 typed/raw hashes, all 26 malformed envelopes, direct `JSON3.Object` transport, clone/
  input/interleaving isolation, public exports, one detached materialization, and privacy/non-execution/host denial.
  Both public entries use the same raw validator/evaluator; do not add a parallel typed semantic kernel. Runtime
  events remain `.10.6.6`; query closeout `.10.6.5.4` was required to recompose committed proof without replacement
  code.
  Complete `.3` signoff is Julia 8,605/primary/105, primary 5x2x66, ten Unicode legs, unchanged ledgers, canonical
  Rust 79.96s + Dart 1/1 + primary 66x2 + Phase 0 1,031/634s, book/KM 690/5,307, doctrines, and exact
  1,613,820-KiB cleanup preserving 517 Pgen artifacts and Julia package/registry caches.
  Closeout `.10.6.5.4` is complete: retrieve all four query cards, then run the nine committed semantic suites in
  their package-driver environment to reproduce exact focused 1,063. Do not add a closeout-only evaluator or
  replacement suite. Complete Julia 8,605/primary/105, primary 5x2x66, ten Unicode legs, and all unchanged ledgers
  compose without runtime observation or promotion. Parent `.10.6.5` is closed; retrieve and plan runtime authority
  only in `.10.6.6.0` after the clean closeout commit. Canonical Rust 79.55s + Dart 1/1 + primary 66x2 + Phase 0
  1,031/635s, book/KM 690/5,307, doctrines, and exact 1,613,872-KiB cleanup preserving 517 Pgen artifacts pass.
  Runtime audit `.10.6.6.0` is now frozen in [[julia-semantic-runtime-observation-authority-map]]. Before changing
  Julia capture, use the canonical `runtime.spec`/`runtime.input` through direct, loaded, JSON-reconstructed,
  generated-plan, traced, and fresh emitted routes. The accepted-slot seam is immediately before
  `_accept_runtime_regex_match!`; position comes from `one_match.codeunit_end`, not the still-old context cursor.
  The final seam is immediately after `RuntimeParseResult` construction. Do not parse
  `julia_runtime:regex_slot_selected` trace text into semantic events or reuse diagnostic output. Check the optional
  sink before allocating and before hashing input; preserve callback identity through the generated broad catch;
  derive the observed index only from detached rule/edge/slot/`selects_regex` evidence. `.1` owns typed direct
  capture, `.2` derivation/twentieth digest, `.3` generated/emitted propagation, and `.4` no-change closeout.
  Typed capture `.1` is now implemented; retrieve [[julia-semantic-runtime-observation-direct-capture]]. Run
  `julia/test/semantic_index_runtime_observation_test.jl` after the nine earlier semantic suites for exact new 66/
  focused 1,129. The sink is public on runtime parse/execute, traced convenience, and validated generated-plan
  direct/traced helpers; loaded/reconstructed engines reuse those seams. Observed-index derivation is owned by
  `.2`, and emitted wrapper propagation is owned and now implemented by `.3`. Complete Julia is 8,671/primary/105
  at the `.1` boundary.
  Derivation `.10.6.6.2` is now implemented; retrieve [[julia-semantic-runtime-observation-derivation]]. Run
  `julia/test/semantic_index_runtime_projection_test.jl` after the ten earlier semantic suites for exact new 157/
  focused 1,286. `with_execution_observation` accepts only exact typed events, checks closed fields/final-result/
  input identity and detached rule-edge-slot topology, and returns a fresh observed index. The canonical typed/raw
  `runtime_events` response matches digest
  `36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887`; malformed/topology cases reject with
  `semantic_index_invalid_observation`. Source-scan proof denies parsing, compilation, execution, trace, sink,
  hashing, environment, and file IO. Complete Julia is 8,828/primary/105.
  Generated/emitted propagation `.10.6.6.3` is now implemented; retrieve
  [[julia-semantic-runtime-observation-generated-routes]]. Run
  `julia/test/semantic_index_runtime_observation_routes_test.jl` after query-kernel, capture, and derivation owners
  for exact new 51/focused 1,337. It covers public generated helpers, fresh emitted direct/traced wrappers, and an
  isolated host; locks canonical events/twentieth digest, callback identity, exit omission, result/diagnostic/trace
  equality, deterministic source, and unchanged generated-source v2/format 2. Complete Julia is 8,879/primary/105.
  No-change `.10.6.6.4` is now complete: retrieve all four runtime-observation cards, then run the complete twelve-
  suite owner order for exact focused 1,337. Parent `.10.6.6` is composition-closed without replacement code,
  format/runtime change, or ledger promotion. Exact admission `.10.6.7` runs
  `julia --project=julia --startup-file=no --history-file=no --compiled-modules=no julia/test/semantic_introspection_julia_admission_test.jl`.
  Its 12 exact-once roles compose every Julia semantic route, all 20 digests, source/query privacy and
  non-interference, fresh plus isolated emitted modules, and host-leak denial. Eight independent topology
  mutations advance only Julia to rollout 5/9 and admission 4/6.

- **LUA COMPOSED ADMISSION:** `.10.7.7` adds only
  `lua/test/semantic_introspection_lua_admission_test.lua`; it declares the established twelve ordered roles once
  in Lua-5.1-compatible source and runs unchanged through `tools/run_lua_local.sh` on PUC Lua and LuaJIT. Run it
  directly with `bash tools/run_lua_project_data.sh puc lua/test/semantic_introspection_lua_admission_test.lua`
  and substitute `luajit` for the second ABI. Its 12 exact-once roles compose every Lua semantic route on both admitted ABIs.
  Both admission rows carry the same consumer path/driver/roles object. The consumer composes strict source and
  compiled/failed/runtime snapshots; all twenty typed/raw-neutral digests; direct, loaded, reconstructed, public
  generated-plan, fresh-emitted direct/traced, isolated emitted, native traced, and generated-helper traced routes;
  privacy/pages/budgets/errors/explain; request/response isolation; query non-execution; and host/path/table/
  metatable/AST/ActionIR/observation/generated-source/pointer denial. The checker must lock both ABI statuses,
  exact shared topology, both driver invocations, Lua-only rollout, canonical registration, and nine independent
  mutations. Each ABI passes exactly 408 assertions; at the Lua admission boundary the neutral gate became
  6 groups / 20 responses / 98 mutations, rollout 6/9, and admission 6/6. Retrieve
  [[lua-semantic-introspection-admission]] before editing.

- **RECURRING SIX-RUNTIME ADMISSION:** `.10.8` adds
  `tools/check_semantic_introspection_six_runtime.sh`, one repository-routed fail-fast driver that invokes the
  exact admitted twelve-role consumers for Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT unchanged. Run it with
  `bash tools/check_semantic_introspection_six_runtime.sh`; it also runs
  `tools/run_primary_cli_matrix.sh` for `success_named_source_literal_input`,
  `failure_compile_precedes_input_load`, and `trace_failure_invoke_route_low`, then the generated-source,
  capability, and language-coverage ledgers. Canonical all-toolchain execution is opt-in through
  `LINKEDSPEC_RUN_SEMANTIC_MATRIX=1`; ordinary CI requires and syntax-checks the driver. Seven recurring
  mutations lock runtime/command/primary/support/CI/driver/rollout topology, advance only recurring, and replace
  premature-recurring with premature-MCP denial. The neutral gate is 6/20/105 at rollout 7/9 and admission 6/6.
  Direct proof passes Perl 18, Rust 1/1, Dart 1/1, Julia 416, Lua 408 per ABI, all 30 primary legs, and all three
  support ledgers. Retrieve [[semantic-introspection-recurring-gate]] before changing the topology.

- **RECURRING FIVE-BACKEND CALLABLE ADMISSION:** `.11.8.4` replaces the historical `.11.7.1` driver with
  `tools/check_callable_codeblock_five_backend.sh`, one repository-routed fail-fast driver that runs the unchanged
  neutral model followed by exact Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT focused consumers. The two Lua rows
  execute one file. Run it directly with `bash tools/check_callable_codeblock_five_backend.sh`; canonical all-toolchain
  execution is opt-in through `LINKEDSPEC_RUN_CALLABLE_CODEBLOCK_MATRIX=1`, while ordinary CI requires and
  syntax-checks the driver. The checker rejects 22 role/path/order/dual-ABI/route/canonical/exclusion/public
  mutations and removes only the satisfied callable exclusion. Capability remains 80/0/0. Retrieve
  [[callable-codeblock-five-backend-admission]] before changing this topology.

- **LUA SOURCE FOUNDATION:** `.10.7.2.1` owns strict copied source/options, portable arithmetic SHA-256, exact
  private zero-based byte/scalar boundaries, one-based scalar line/columns, four source ceilings, and opaque
  detached source/error values. Importing `linkedspec.semantic_index` remains parser-free; constructing an index
  now validates/maps/hashes first and then lazily loads the outcome owner. Run both focused suites with the same
  native adapter environment used by `tools/run_lua_local.sh`; the source suite passes 378 assertions on both PUC
  Lua and LuaJIT. Do not infer path identity or inspect weak-key state. See [[lua-semantic-source-foundation]].
- **LUA COMPILATION FOUNDATION:** `.10.7.2.2` performs exactly one staged user-function-aware parse, validation,
  `compile_spec(..., {validate_source=false})`, entry selection, and generated-v2 plan build behind that owner.
  Use `semantic_snapshot`, `compilation_authority`, `compilation_diagnostic`, `entry_selection`, and
  `generated_plan_input`; public values are protected empty handles with detached JSON/fields/rows. Native
  validation and selection diagnostics remain exact, recognized parser/compiler/plan failures use stable
  fallbacks, and unrecognized exceptions retain identity. Run
  `bash tools/run_lua_local.sh`; its registered outcome suite passes 122 assertions per ABI and proves no caller
  path, target/generated execution, runtime, trace, diagnostic sink, query, observation, descriptor, or host-state
  exposure. See [[lua-semantic-compilation-foundation]].
- **LUA FOUNDATION CLOSEOUT:** `.10.7.2.3` adds no production or replacement test owner. Starting from committed
  outcome `c8501d3a`, run `bash tools/run_lua_local.sh` and confirm the registered source then outcome suites report
  exact 378+122 on PUC Lua and LuaJIT before the remaining package proof. Then run primary 5x2x66, Unicode 5x2x1,
  Rust 5+3, Dart 17, Julia 3,831, all six no-drift ledgers, and canonical local CI. The parent closes only when
  those committed owners compose without records/query, runtime observation, target execution, format movement,
  or promotion. Retrieve the three Lua foundation cards before behavior-free static audit `.10.7.3.0`.
- **LUA STATIC-PROJECTION PREFLIGHT:** retrieve [[lua-semantic-static-projection-plan]] before projector work.
  `.10.7.3.0` freezes graph 12/14, privacy text 4/3, privacy identity 4/3, failed 6/4, and runtime-static 7/8 with
  `has_execution=false`. Use retained parsed/compiled/entry/diagnostic state, but scan complete authored lines for
  source references: `BodyElement.source` fragments and action-local ActionIR offsets are not global source
  coordinates. Exclude cross-rule parent matchers from target slots, retain self-indexed slots, correlate repeated
  lifecycle payloads by occurrence, normalize native `Default` repetition and native failure only inside the
  projector, and deny paths/metatables/AST/ActionIR/compiled regex/runtime state. `.10.7.3.1` owns only private
  graph/source/evidence; `.2` now owns the completed remaining targets/isolation plus clean canonical closeout;
  `.3` is the completed no-change committed-owner recomposition.
- **LUA STATIC GRAPH:** `bash tools/run_lua_local.sh` builds disposable native adapters, configures module paths,
  and runs `lua/test/semantic_index_static_graph_test.lua` on both PUC Lua and LuaJIT. The registered test deep-
  compares the private `.10.7.3.1` graph against the neutral oracle at exactly 12 records, 14 relations, and seven
  source references. It also locks complete-line correlation, duplicate/self/parent matcher classification,
  lifecycle occurrence identity, canonical ids/order, detached clone behavior, root-public omission, and host/
  execution dependency denial. Retrieve [[lua-semantic-static-projection-plan]] for the retained-authority and
  frozen-handle design. Do not invoke the test without the gate's `LUA_PATH`/native `LUA_CPATH` setup.
- **LUA STATIC TARGET CLOSEOUT:** `.10.7.3.2.1.2` adds no replacement implementation or test owner. Starting from
  clean implementation `3f878ad2` and process-oracle correction `e7ae984d`, run `bash tools/run_ci_local.sh` and
  require six doctrines, semantic owners, corrected containment, moved-root proof, primary 66x2, and Phase 0
  1,031/1,031. The closeout passed with Rust admission 78.09 seconds, Julia admission 27.4 seconds, and Phase 0
  637 seconds.
- **LUA STATIC PROJECTION RECOMPOSITION:** `.10.7.3.3` adds no production or replacement proof owner. Starting
  from clean `2a6f24c4`, run `bash tools/run_lua_local.sh` and require committed source/outcome/graph/remaining
  379/122/64/122 plus package `1..177` on both ABIs; then require PUC primary/corpus, primary 5x2x66, Unicode
  10/10, all six ledgers, and canonical CI. The closeout passes Rust admission 78.12 seconds, Julia 416/416 in
  27.4 seconds, reference primary 66x2, corrected containment/moved-root proof, and Phase 0 1,031/1,031 in 649
  seconds. Parent `.10.7.3` is closed; retrieve [[lua-semantic-static-projection-plan]] before behavior-free
  calls/staging/generated audit `.10.7.4.0`.
- **LUA CALLS/STAGING/GENERATED PREFLIGHT:** retrieve [[lua-semantic-call-staged-projection-plan]] before call
  projector work. `.10.7.4.0` freezes the neutral `calls_and_staging` target as static 6/6, typed core 18/16, and
  staged/generated 22/25. Use retained merged `authored_definitions`, accepted registry state, reparsed typed
  function-body ActionIR only after staged JSON equality, compiled edge ActionIR/contracts, the existing strict
  source map, and retained immutable generated-v2 plan. Staged `body_ast` is not typed authority; edge-local
  ActionIR spans cannot be added to authored member starts. Correlate typed outer-before-inner calls through a
  bounded scanner, resolve registered functions before the narrow helper table, infer shapes conservatively, and
  execute neither target nor generated code. `.10.7.4.1` implements exact typed 18/16; `.2` now validates native
  staged sidecars plus retained generated-plan identity/order/selection and completes exact 22/25/10 without an
  emitter dependency. `.3` now recomposes all six committed owners at exact focused 920 per ABI and closes parent
  `.10.7.4` without replacement code or promotion; behavior-free query audit `.10.7.5.0` follows. Run the focused
  owners through repository storage routing:

  ```bash
  for runtime in puc luajit; do
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_source_foundation_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_compilation_foundation_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_static_graph_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_static_remaining_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_call_core_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_call_staged_generated_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_query_kernel_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_runtime_observation_native_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_runtime_projection_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_runtime_observation_generated_routes_test.lua
  done
  ```

  The current baseline is source/outcome/graph/remaining/core/staged/query/native-observation/runtime-projection/
  generated-routes 382/122/64/122/136/97/571/121/269/80, or 1,964 assertions on each ABI. Retrieve
  [[lua-semantic-runtime-observation-generated-routes]] before changing generated observation propagation. Do not
  invoke native Lua tests without the wrapper's configured `LUA_PATH`, native `LUA_CPATH`, and repository-local
  managed storage.
- **LUA IMMUTABLE-QUERY PREFLIGHT:** retrieve [[lua-semantic-query-authority-map]] before query work. Behavior-free
  `.10.7.5.0` freezes exactly one fresh detached private projection per request, 19 complete static response hashes,
  26 malformed raw-neutral labels, and the public spellings
  `semantic_query_request` / `is_semantic_query_request` / `is_semantic_query_response` /
  `semantic_query_to_json` plus index `capabilities` / typed `query` / raw `query_neutral`. Raw Lua input must retain
  explicit `json.harray` / `json.array` / `json.null` identity; plain tables are ambiguous. Validate neutral
  integers as finite `number`, floor-equal, and bounded on both ABIs—never with PUC-only `math.type`. Evaluation
  receives no source/compiler/sidecar/AST/IR/regex/generated/runtime/trace/path/host authority and performs no
  parse, compile, execution, or observation. Implement private non-traversal `.1`, private traversal/limits `.2`,
  expose the complete typed/raw surface only in `.3`, and composition-close in `.4`. Reverify the frozen baseline:

  ```bash
  bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py
  for runtime in puc luajit; do
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_source_foundation_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_compilation_foundation_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_static_graph_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_static_remaining_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_call_core_test.lua
    bash tools/run_lua_project_data.sh "$runtime" lua/test/semantic_index_call_staged_generated_test.lua
  done
  ```
- **LUA RUNTIME-OBSERVATION PREFLIGHT:** retrieve [[lua-semantic-runtime-observation-authority-map]] before
  changing Lua execution or observed-index projection. The accepted-slot seam is after match and ordered identity
  but before `accept_match`; use `one:char_end()`, not the still-old `ctx.cursor_byte`. Final observation follows
  successful `RuntimeParseResult` construction. Do not parse `lua_runtime:regex_slot_selected` text or reuse
  diagnostic output. Keep `semantic_observation_sink` invocation-local, return before allocation/scalar conversion/
  SHA when absent, reuse the package-internal portable digest authority, and preserve exact arbitrary callback
  values through separate native and generated semantic carriers. Direct/loaded/reconstructed/generated-plan/
  emitted/traced PUC Lua and LuaJIT routes must remain result/cursor/trace/diagnostic equivalent. The implemented
  derivation accepts only typed events and one fresh detached static projection, validates exact static topology,
  freezes a new index, and retains `runtime_events` digest
  `36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887` without execution. Reverify through:

  ```bash
  bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py
  bash tools/run_lua_project_data.sh puc lua/test/semantic_index_runtime_projection_test.lua
  bash tools/run_lua_project_data.sh luajit lua/test/semantic_index_runtime_projection_test.lua
  bash tools/run_lua_local.sh
  ```

  The committed implementation order is direct capture `.10.7.6.1`, detached derivation `.2`, generated/emitted/
  isolated propagation `.3`, and no-change closeout `.4`; admission remains `.10.7.7`.
- **SEMANTIC SOURCE CEILING BOUNDARY:** retrieve [[semantic-source-ceiling-boundary]] before changing private
  source retention. ADR `0049` applies ceilings when query records leave the native API: the private projection
  retains complete authoritative refs, the snapshot fixes ceiling/digest policy, and the query source projector
  returns only permitted fields or rejects elevation. The neutral `privacy_limited` construction oracle therefore
  contains full private refs even though outward identity requests receive no span, excerpt, or digest.

### 4.9.1 `tools/check_typed_source_location_six_runtime.sh` — exact recurring typed-source proof

- **WHAT:** one repository-routed fail-fast composition of the neutral typed source-location checker; admitted
  Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT consumers; and generated-source, capability, and language-coverage
  support ledgers.
- **WHEN:** changing immutable source positions/spans/derived text, source-boundary helper projections or aliases,
  runtime admission topology, recurring commands, or any supporting capability ledger.
- **HOW:** run the complete all-toolchain proof directly:

  ```bash
  bash tools/check_typed_source_location_six_runtime.sh
  ```

  Canonical CI always requires and syntax-checks the driver. Use
  `LINKEDSPEC_RUN_TYPED_SOURCE_MATRIX=1 bash tools/run_ci_local.sh` to opt into the same composition from the
  canonical gate.
- **OUTPUT:** neutral governance reports 3 sources, 7 positions, 6 direct spans, 3 derived texts, 8+8+33 state
  transitions, 6 recursive observations, 4 structural cases, 92 helper projections + 7 aliases + 2 internal ids,
  33 diagnostics, 12 complete / 2 pending rollout, and 170 rejected drift mutations. The driver then reports each
  of the six ordered runtime routes and three support ledgers before its exact success marker.
- **BOUNDARY:** this is orchestration over existing internal consumers, not a new public typed-value surface. The
  combined recurring/public no-drift row remains pending for `FUTURE-PARITY-BACKLOG.14.8`. Retrieve
  [[typed-source-location-recurring-gate]] before changing the source/runtime cardinality or rollout ownership.
- **RECURSIVE-OBSERVATION PREFLIGHT:** retrieve [[recursive-source-observation-audit]] before changing recursive
  entry/match/exit state or provenance. First use `call_spec_handler_subst` to prove child-call lowering,
  `return_descriptor` to prove the child's family/cursor policy, and `dump_parser_source` plus `LinkedSpec::Get` to
  prove action-edge versus direct-call entry state. All live engines guard an active `(rule, cursor)` before child
  frame entry. Extend the existing monotonic recognition authority; never add a second invocation stack.
  Corrective leaf `.14.4.0.1` replaces the historical self-parent row with positive numeric attempted-child
  lineage and makes the checker reject self-parenting, reuse, invalid parent order, and represented cycles before
  tuple comparison. Perl `.14.4.2`, Rust `.14.4.3`, Dart `.14.4.4`, Julia `.14.4.5`, and shared Lua `.14.4.6`
  admit the exact observation surface on all six runtimes through one dedicated private node per backend, static
  policy, the existing monotonic authority, and their governed live/reconstructed/generated/emitted carriers.
  The shared Lua consumer executes once on PUC Lua and once on LuaJIT; dedicated recurrence is current.

### 4.9.1.1 `tools/check_recursive_observation_six_runtime.sh` — exact recurring observation proof

- **WHAT:** one repository-routed fail-fast composition of the neutral typed-source checker; exact Perl, Rust,
  Dart, Julia, PUC Lua, and LuaJIT recursive-observation consumers; and the generated-source, capability, and
  language-coverage ledgers.
- **WHEN:** changing observation sources, runtime route mapping or order, commands, support ledgers, storage
  routing, recurrence status, or canonical registration.
- **HOW:** run `bash tools/check_recursive_observation_six_runtime.sh`. Canonical CI always inventories,
  machine-path-audits, and syntax-checks the driver; use
  `LINKEDSPEC_RUN_RECURSIVE_OBSERVATION_MATRIX=1 bash tools/run_ci_local.sh` for its all-toolchain route.
- **OUTPUT:** Perl 7, Rust 7, Dart 7, Julia 30, PUC Lua 43, and LuaJIT 43 pass before the three support ledgers and
  exact success marker. Current neutral truth, including lossless-gap, transaction-safety, and progressive
  recurrence composition, is 12 complete / 2 pending / 170 mutations.
- **BOUNDARY:** five backend sources form six routes because one shared Lua source executes independently on both
  ABIs. Twelve regressions lock topology/storage and recurrence-only promotion; 27 more lock six public documents,
  six stale-claim denials, and ten surface guards without changing the 14-row rollout. Recursive-observation public projection/no-drift is current without moving any public or runtime surface.
  The combined program-wide `.14.8` row remains pending; no parser, runtime, facade, schema, semantic/MCP, CLI,
  README, or storage-root behavior changes. Retrieve
  [[recursive-observation-recurring-gate]] before changing this proof.

### 4.9.1.1.1 Typed transaction-composition correction

- **WHAT:** `transaction_safety` in the typed ledger is a projection of the separately owned current recognition
  authority, not a second transaction implementation. It produced 11/3/152 at its boundary; progressive
  recurrence subsequently makes current typed truth 12/2/170. Recognition remains 9/9/58 over five backend
  sources and six runtime routes.
- **WHEN:** changing typed transaction status/runtimes, transaction effect or progress language, recognition
  contract/checker/driver identity, stale Knowledge/book claims, or the progressive-dispatch transaction fence.
- **HOW:** run `bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py`, then
  `bash tools/check_recognition_transaction_six_runtime.sh`. The typed checker cross-checks upstream identity,
  rollout, topology, 9/11 effect counts, eight progress cases, public 3/26/45, and guide 1/14/18.
- **BOUNDARY:** this leaf completed only `transaction_safety`. `parser_registry_or_staged_dispatch` remains
  rejected inside uncommitted recognition. Progressive typed recurrence is now current; staged dispatch and
  combined program-wide no-drift remain pending, and no parser/runtime/facade/schema/semantic/MCP/CLI/README
  behavior changes.

### 4.9.1.1.2 `tools/check_progressive_span_dispatch_contract.py` — neutral progressive oracle

- **WHAT:** the backend-independent authority for reserved private
  `value = dispatch_span("expr-v1", "Expr", span)` syntax. It models immutable pre-registration, direct typed
  spans, rebased views, isolation/detachment, authority minima, cancellation/budgets, decreasing cycles, bounds,
  transaction rejection, diagnostics, and exact neutral-first rollout.
- **WHEN:** changing progressive syntax, parser identity/top-rule policy, span carriers, registry fields, ceilings,
  cancellation or cycle rules, portable diagnostics, neutral rollout, or canonical registration.
- **HOW:** run `bash tools/run_python_project_data.sh tools/check_progressive_span_dispatch_contract.py`.
  The independent checker is repository-routed and always registered in canonical local CI.
- **OUTPUT:** 2 immutable registry entries; 2 sources/8 views; 6 authority + 6 cancellation + 8 chain + 4
  execution cases; 9 Rust + 8 Dart + 9 Julia + 9 Lua implementation paths with zero backend guards plus 10
  outward guards; 26 diagnostics; behavioral rollout 9/9; 116 contract mutations; and public
  6-document/12-stale/10-outward/60-mutation governance.
- **BOUNDARY:** all six private runtimes are admitted, the rejected effect owns exactly current node
  `PROGRESSIVE_DISPATCH_SPAN` and no call row, and ten facade/schema/semantic/MCP/CLI/README paths deny exposure.
  Progressive behavioral governance is 9/9 complete; the exact six-runtime recurrence and public no-drift proof are current while all ten outward surfaces remain absent.
  Typed recurrence is separately current; there is no path loader, public API behavior, fallback, or staged AST stitching.

### 4.9.1.1.3 `tools/check_progressive_span_dispatch_six_runtime.sh` — exact typed recurrence proof

- **WHAT:** one repository-routed fail-fast composition of the progressive neutral checker; exact Perl,
  cfg-enabled Rust, Dart, Julia, PUC Lua, and LuaJIT consumers; and typed-source, generated-source, capability,
  and language support ledgers.
- **WHEN:** changing progressive source groups, route mapping/order, commands, support checks, project-data
  routing, typed rollout, canonical registration, or current projection claims.
- **HOW:** run `bash tools/check_progressive_span_dispatch_six_runtime.sh`. Canonical CI always requires,
  machine-path-audits, and syntax-checks the driver; use
  `LINKEDSPEC_RUN_PROGRESSIVE_SPAN_MATRIX=1 bash tools/run_ci_local.sh` for its all-toolchain route.
- **OUTPUT:** five immutable backend source groups form six runtime routes because shared Lua executes once on PUC
  Lua and once on LuaJIT. Twelve topology/storage/rollout regressions plus two stale-guide denials promote only
  typed `progressive_span_dispatch`, making typed truth 12 complete / 2 pending / 170 mutations.
- **BOUNDARY:** `.14.6.8` binds this committed driver to the corrected behavioral recurring row and closes
  progressive public no-drift at 9/9/116 plus public 6/12/10/60 governance. Staged dispatch remains `.14.7`-owned
  and combined program-wide no-drift `.14.8`-owned. No runtime, consumer, generated format, facade, schema,
  semantic/MCP, CLI, README, or public behavior moves. Retrieve
  [[progressive-span-dispatch-recurring-gate]] before changing this proof.

### 4.9.1.1.4 `tools/check_staged_ast_enrichment_contract.py` — neutral staged-enrichment oracle

- **WHAT:** the backend-independent authority for future authored `parse_job(text_expr, options)`, its inert
  `STAGED_PARSE_JOB_MARKER` plus `staged_parse_job_v2` sidecar, typed direct/derived provenance, pre-resolved
  registry/cache authority, deterministic breadth-first scheduling, result/failure policies, recursive bounds,
  detachment, diagnostics, carrier obligations, dormant backend routes, rollout, and exact downstream ownership.
- **WHEN:** changing general returned-AST enrichment syntax or metadata; parser aliases/providers/search roots;
  registry/cache keys; queue ordering; stitching/failure/cycle/resource semantics; generated carriers; diagnostics;
  staged rollout/topology; or the function-body-v1 compatibility adapter.
- **HOW:** run `bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py`. The checker
  is repository-routed, rejects reason-checked schema/behavior/topology mutations in memory, and is registered
  unconditionally in canonical local CI.
- **OUTPUT:** 4 registry entries; 8 provenance; 8 resolution/6 authority; 10 cache; 4 queue/3 isolation;
  4 result plus 3 failure policies; 10 recursive-chain and 5 detachment cases; five backend consumers over six
  runtime routes; 37 diagnostics; 9 rollout legs; 35 exact owners; and 85 mutations.
- **BOUNDARY:** neutral, Perl, and Rust are complete. Dart is `dormant_red` at its exact excluded path; Julia,
  PUC Lua, LuaJIT, recurrence, and public no-drift remain pending. Outward facade/schema/semantic/MCP/CLI/README
  tokens remain absent. The existing function-body v1 adapter and generated-source v2 format stay current and
  unchanged.

### 4.9.1.2 Lossless-gap handoff preflight

- **WHAT:** the behavior-free authority audit before activating any named-slot or automatic gap implementation.
- **WHEN:** changing `Rule[N]`, proposing `Rule[name]`, `@capture_gaps`, split-marker execution, or typed
  gap composition.
- **HOW:** retrieve [[lossless-gap-cross-tree-handoff]], then use `LinkedSpec::Get(..., return_descriptor => 1)`
  to prove current numeric target identity and current named-surface diagnostics. Run
  `bash tools/check_duplicate_regex_slot_identity_five_backend.sh` and
  `bash tools/check_typed_source_location_six_runtime.sh` before changing either authority. If a diagnostic
  Perl probe embeds a spec in `qq{...}`, escape authored marker sigils such as `\@move_pos`; otherwise host
  interpolation removes the marker and creates false runtime evidence.
- **BOUNDARY:** `INTER-MATCH-GAP-CAPTURE.1-.7` exclusively owns named-slot grammar, `@capture_gaps` lifecycle,
  compatibility, backend/carrier implementation, and public admission. `FUTURE-PARITY-BACKLOG.14.5.1` only
  composes that closed proof into typed-source `gap_composition`. Brackets are selectors—numeric is positional,
  named is stable identity—and dot remains the fluent rule-behavior namespace. The first fluent dot is mandatory;
  whitespace-only target-to-method attachment is not an alias.

### 4.9.1.3 `tools/check_inter_match_gap_capture_contract.py` — executable-neutral gap oracle

- **WHAT:** the format-1 neutral JSON authority for `linkedspec-inter-match-gap-capture-v1`. It executes exact
  Unicode/empty/child/transaction state and rejects 63 semantic/topology corruptions at rollout 9 complete + 0
  pending. Inter-match gap public no-drift is current: six documents, twelve stale-current denials, ten outward guards, and twenty-nine reason-checked mutations.
- **WHEN:** implementing `.1.3`, named regex declarations/selectors, `entry_slot()`, `@capture_gaps`, the three
  gap accessors, or any backend/runtime/recurring leg.
- **HOW:** run `bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py`, retrieve
  [[inter-match-gap-executable-contract-plan]], and read the complete frozen section in
  `docs/tasks/INTER-MATCH-GAP-CAPTURE.md`. Run
  `bash tools/check_inter_match_gap_capture_six_runtime.sh` for the ordered repository-routed governance proof;
  it executes every admitted runtime route with no skip. Rerun both prerequisite matrices from §4.9.1.2 before changing
  either dependency. For current mechanism evidence, use `return_descriptor` for
  `{family,cursor_policy,edge_ownership,uses_loop,execution_shape,resolved_edges}`, `dump_parser_source` for exact
  selection → `LS` → action/target → `LE` order, and the corrected historical live probe recorded in the task.
- **BOUNDARY:** neutral `.1`, runtime `.2-.6`, recurring `.7.1`, and public language/compatibility/no-drift `.7.2`
  are complete. Shared calls are exactly `entry_slot`, `gap_span`, `gap_text`, and `gap_kind`; the outward guards
  remain unchanged. `.7.3` owns unchanged recomposition plus the typed-source handoff. Do not widen README,
  facades, semantic/MCP, CLI, capability, or typed-source surfaces implicitly.

### 4.9.1.3.1 `tools/check_typed_gap_composition_six_runtime.sh` — typed lossless-gap composition

- **WHAT:** one repository-routed fail-fast composition of the typed-source checker, the separately owned complete
  neutral plus six-runtime gap route, recognition ownership, and generated-source/capability/language ledgers.
- **WHEN:** changing `gap_span` projection, named/positional slot provenance, the typed
  `lossless_gap_composition` row, either contract's cross-reference, repository storage routing, or canonical
  registration. Retrieve [[typed-lossless-gap-composition]] first.
- **HOW:** run `bash tools/check_typed_gap_composition_six_runtime.sh`. Canonical CI inventories, machine-path
  audits, syntax-checks, and outside-CWD routes the driver; use
  `LINKEDSPEC_RUN_TYPED_GAP_COMPOSITION_MATRIX=1 bash tools/run_ci_local.sh` for its full all-toolchain route.
- **OUTPUT:** typed governance reports 12 complete / 2 pending / 170 mutations; gap governance reports 9/0/63
  plus public 6/12/10/29; then Perl 124, Rust 1, Dart 5, Julia 319, PUC Lua 392, LuaJIT 392, recognition
  137/250/58, strict generated Rust 105/105, capability 80/0/0, and language 250/105+1/126 pass before exact
  `[typed-gap-composition] PASS: typed lossless-gap composition, all six gap runtimes, and support ledgers complete`.
- **BOUNDARY:** `gap_span` was already the detached typed same-source half-open Unicode-scalar carrier on all six
  runtimes. This route promotes only composition; it does not own or change grammar, lifecycle, implementation,
  compatibility, migration, public facade/schema/semantic/MCP/CLI/README surface, or final `.14.8` no-drift.

### 4.9.1.4 Perl gap implementation preflight

- **WHAT:** the behavior-free `.2.0` map from the audited Perl grammar/descriptor/runtime baseline to four owned
  implementation leaves. It records exact baseline absence, legacy output, generated lifecycle order, dormancy,
  effect-ledger coupling, carrier seams, and admission boundaries in
  [[inter-match-gap-perl-implementation-plan]].
- **WHEN:** implementing or reviewing `.2.1-.2.4`, especially before changing bootstrap grammar, ActionIR helper
  contracts, recognition transaction effect rows, or generated parser source.
- **HOW:** run the neutral and rooted gap checks first. Probe `return_descriptor` for numeric dependency refs and
  rule execution metadata; use `call_spec_handler_subst` for helper lowering; dump parser source to locate match
  extraction/`LS`/action/`LE`/`IT`; and use the escaped legacy marker probe for prefix/interstitial truth. Host
  Perl Unicode properties are not the slot-name oracle: generate from the pinned Unicode-17 range artifact.
- **BOUNDARY:** `.2.1` is metadata-only and keeps the exact consumer dormant; `.2.2` now attaches state to the existing
  recognition invocation guard and synchronizes four private source-read nodes; `.2.3` owns emitted/loaded parity;
  `.2.4` alone registers and promotes Perl. No second stack, `$IPOS` overload, plan-v3 change, public-helper
  admission, typed-source promotion, or outward facade/schema/CLI/README surface is permitted.

### 4.9.1.5 Rust gap implementation preflight

- **WHAT:** the behavior-free `.3.0` map from the audited Rust parser/compiler/runtime baseline to five owned
  implementation leaves. It records exact process-level absence/drift, source mechanisms, one-authority state,
  native/generated loop seams, carrier/primary roles, project-local emitted proof, and admission boundaries in
  [[inter-match-gap-rust-implementation-plan]].
- **WHEN:** implementing or reviewing `.3.1-.3.5`, especially before changing Rust regex declarations/selectors,
  compiled edge identity, recognition frames, native/generated lifecycle, descriptors, or emitted source.
- **HOW:** run the neutral and rooted gap checks first. Use the primary `--inline-spec` route to reproduce numeric,
  named, directive, and accessor behavior; inspect `parse_single_element`, `parse_action_edge_prefix`,
  `compile_rule`, both engine loops, `RuntimeContext`, and `source_emitter` only after that reproduction. Reuse the
  pinned Unicode-17 classifier, structural slot helpers, immutable input source authority, recognition invocation,
  and repository-derived Cargo/scratch wrappers.
- **BOUNDARY:** `.3.1` is authored/static/compiled metadata only; `.3.2` is native same-authority state/accessors;
  `.3.3` is reconstruction/descriptor/generated-plan parity; `.3.4` is independently compiled emitted parity;
  `.3.5` alone registers and promotes Rust. Generated plan v2, recognition 137/246/58, 122 public helpers, typed
  source 9/5/114, capability/public surfaces, recurring/public rows, and later runtimes do not move before their
  explicit owners.
- **SIGNED OFF:** focused Rust 1/1, gap 2/7/56, rooted Perl 124/five skips, book 79/14,704 KiB, Knowledge 835/7,009,
  all eight doctrines, containment/relocation, CLI 66/66 twice, RAM 57%, Phase 0 1,031/1,031 in 741 seconds, exact
  opt-in routing, and local-CI exit 0 pass. `.3.0` remains behavior-free and `.3.1` waits for clean atomic 227.

### 4.9.1.6 Dart gap implementation preflight

- **WHAT:** the behavior-free `.4.0` map from Dart's audited AST/parser/compiler/runtime baseline to five owned
  implementation leaves. It records exact raw-syntax/unknown-helper absence, current lifecycle order, one private
  recognition authority, normalized-state/generated/emitted carriers, primary proof, storage, and admission
  boundaries in [[inter-match-gap-dart-implementation-plan]].
- **WHEN:** implementing or reviewing `.4.1-.4.5`, especially before changing Dart regex declarations/selectors,
  logical spec identity, compiled edge provenance, recognition frames, native lifecycle, descriptors, generated
  execution, or emitted source.
- **HOW:** run the neutral/rooted checks and `bash tools/run_dart_project_data.sh ...`; never run a bare maintained
  Dart command. Reproduce the named/directive/accessor boundary before source inspection, then follow
  `RegexBodyElementKind`/`EdgeTarget`, `_parseSingleElement`/`_parseIndexAt`, `compileSpec`, `_executeRegexRule`,
  `_executeRegexOnce`, `_InvocationState`, normalized `SpecFile` emission, and the existing primary adapter.
- **BOUNDARY:** `.4.1` owns authored/static/compiled metadata and dormancy; `.4.2` owns private same-authority
  native state/accessors; `.4.3` owns reconstruction/descriptor/generated-plan proof; `.4.4` owns independently
  analyzed emitted proof; `.4.5` alone registers and promotes Dart. `RecognitionFrameState`, generated plan v2,
  3/6/56 rollout, public surfaces, typed composition, and later runtimes do not move before their owners.
- **SIGNED OFF:** focused Dart 123/123 and complete format 101/0, analysis, package 400/400, storage 22/47, CLI
  66x2, and corpus 105/105 pass. `.4.0` changes no Dart implementation or rollout; `.4.1` waits for atomic 233.

### 4.9.1.7 Julia gap implementation preflight

- **WHAT:** behavior-free `.5.0` maps Julia's audited AST/parser/compiler/runtime baseline to `.5.1-.5.5`. It
  records numeric-selector success; raw-invalid named/directive syntax; unknown accessor helpers; inactive legacy
  markers; `LS`-before-selection order; existing recognition/source/normalized/generated/primary authorities;
  exact repository storage; and admission boundaries in [[inter-match-gap-julia-implementation-plan]].
- **WHEN:** implementing or reviewing `.5.1-.5.5`, especially before changing Julia regex declarations/selectors,
  logical spec identity, compiled edge provenance, recognition invocation/token state, runtime lifecycle,
  descriptors, normalized reconstruction, generated-v2 execution, emitted modules, or primary routing.
- **HOW:** run the neutral/rooted checks and all Julia commands through `tools/run_julia_project_data.sh` or
  `tools/run_julia_local.sh`. Reproduce the surface/runtime/primary boundary first, then follow
  `RegexBodyElementKind`/`EdgeTarget`, `_parse_index_at`, `validate_spec`, `_compile_rule`,
  `_execute_runtime_regex_rule!`, `_execute_runtime_regex_once!`, the private recognition invocation/token,
  normalized `SpecFile` JSON, `SourceEmitter`, and the existing primary adapter. Runtime registers are UTF-8 code
  units; only the immutable input `SourceAuthority` may project scalar spans.
- **BOUNDARY:** `.5.1` owns logical source plus authored/static/compiled metadata and dormancy; `.5.2` owns private
  same-authority native state/accessors without widening `RecognitionFrameState`; `.5.3` owns normalized
  reconstruction/descriptor/generated-plan proof; `.5.4` owns independently loaded emitted proof and exact
  storage 19→20; `.5.5` alone registers/promotes Julia and closes parent `.5`. Generated format 2 and
  `{label,family}` rows, recognition 137/246/58, public helpers 122, typed source 9/5/114, outward surfaces, later
  runtimes, and recurring/public rows remain unchanged before their owners.

### 4.9.2 `tools/check_recognition_transaction_contract.py` — neutral transaction/progress oracle

- **WHAT:** independently interprets `linkedspec-recognition-transaction-v1`: four current authored forms, a linear
  token state machine with falsey-safe staged results, closed ActionIR/call base effects, recursive fixed-point
  effects, invocation-frame marks, cursor-only repetition/recursion progress, diagnostics, and rollout topology.
- **WHEN:** changing the accepted recognition-transaction design, current ActionIR node or call-contract inventory,
  any transaction-safe effect classification, token/mark/progress rule, backend owner, or canonical registration.
- **HOW:** run the repository-routed focused proof:

  ```bash
  bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py
  ```

- **OUTPUT:** 137 ActionIR rows (133 live plus four dedicated), 250 live call rows, token 8 positive / 17 negative,
  six fixed-point graphs, six mark cases, eight progress cases, fifteen diagnostics, and 58 rejected mutations;
  rollout is 9/9 complete. A separate public-sequence projection locks three book
  pages, 26 forbidden claims, and 45 mutations; the guide guard locks one document, 14 stale claims, and 18
  mutations. Admission guards remain 8 Rust, 13 Dart, 14 Julia, and 22 Lua mutations, with Lua authority 22 and
  integration 19 independently retained.
- **BOUNDARY:** this checker derives the live inventories and proves the shared target plus every runtime admission.
  Perl 51, Rust 12, Dart 10, current Julia 207, and Lua 246 per ABI are canonical; recurring and public no-drift
  are current and transaction activity `.14.3` is closed. Its exact `policy.current_boundary` prose is generated
  from the expected rollout, so a backend promotion cannot leave a separately hard-coded earlier boundary behind.
- **RECURRING:** run the five-source/six-runtime orchestration with:

  ```bash
  bash tools/check_recognition_transaction_six_runtime.sh
  ```

  It executes neutral, Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT in order, then generated-source, capability,
  and language-coverage ledgers. Canonical CI requires, path-audits, and syntax-checks the project-data-routed
  driver; `LINKEDSPEC_RUN_RECOGNITION_TRANSACTION_MATRIX=1` opts into the complete all-toolchain route. Retrieve
  [[recognition-transaction-recurring-gate]] before changing its topology or ownership.
- **RUST ADMISSION:** ordinary offline Cargo and canonical CI execute the same exact final-path target:

  ```bash
  source tools/project_data_env.sh
  cargo test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime \
    --test recognition_transaction_contract
  ```

  It passes 12/12 across authority, dedicated lowering, effect/progress policy, native, reconstructed,
  generated-plan, independently compiled emitted-source, and compatibility proof. The internal authority module
  remains documentation-hidden; admission removes dormancy without adding a separately supported public Rust API.
  Retrieve [[rust-recognition-transaction-integration]] before changing this consumer or its canonical route.

- **LUA ADMISSION:** ordinary and canonical proof execute one shared source independently on both ABIs:

  ```bash
  bash tools/run_lua_project_data.sh puc lua/test/recognition_transaction_contract_test.lua
  bash tools/run_lua_project_data.sh luajit lua/test/recognition_transaction_contract_test.lua
  ```

  Each current run passes 246 assertions. The authority and runtime adapter remain private; admission adds no facade export
  or ABI-specific implementation. Retrieve [[lua-recognition-transaction-admission]] before changing these routes.

### 4.10 MCP transport materializer and independent validator

- **WHAT:** `tools/materialize_mcp_semantic_transport_contract.py` deterministically reconstructs and digest-checks
  `linkedspec-mcp-transport-v1`; `tools/check_mcp_semantic_transport_contract.py` independently interprets its
  schema, frames, raw inputs, lifecycle/handle/policy cases, and 68 mutations without importing the materializer.
- **WHEN:** changing the modern MCP protocol, schemas, canonical frames, semantic payload projection, native server
  identity, handle/policy/error/lifecycle rules, canonical CI topology, or any future native MCP implementation.
- **HOW:** run the materializer first, then the validator:

  ```bash
  bash tools/run_python_project_data.sh tools/materialize_mcp_semantic_transport_contract.py
  bash tools/run_python_project_data.sh tools/check_mcp_semantic_transport_contract.py
  ```

- **OUTPUT:** exact materialization reports 35 frames / 10 raw / 10 lifecycle; independent validation reports the
  same inventories plus 68 rejected mutations. Canonical CI requires both tracked programs and artifacts, runs
  them unconditionally in this order, and its tool-topology test rejects omission or reversed order.
- **BOUNDARY:** neither program is an MCP server. They may not compile/load a spec, create an index, dispatch a
  native query, or rewrite the JSONL unless the materializer is explicitly invoked with `--write`.
- **PERL IMPLEMENTATION PREFLIGHT:** retrieve [[perl-native-mcp-server-plan]] before changing native MCP code.
  ADR `0057` fixes future owners `LinkedSpec::MCPServer`, generated `LinkedSpec::MCPContract`,
  `LinkedSpec::MCPContractRuntime`, and `LinkedSpec::MCPWire`. The measured reference boundary is descriptor
  `CODE` 2 / `Regexp` 5 versus exact opaque-index capability/query digests
  `a5f759dc8a5d060a36f86d35d5a86ff8b6745ef87cbe03d2c8b5a3200ddfd141` /
  `b8872b7340d2d6f4aaa409745fe0083bc744a594e09a05ed5b9786446594df0b`. Installed `JSON::PP 4.06` accepts literal
  and escape-equivalent duplicate keys, so stdio implementation must use the planned strict preflight rather than
  treating plain `decode` as conformance. Production handles require exact OS entropy and monotonic time; no weak
  fallback or runtime contract-file read is allowed. Behavior starts only in `.10.9.2.1`.
- **CURRENT ADMISSION:** retrieve [[mcp-implementation-admission-ledger]]. All five implementations and all six
  runtimes and shared rollout are complete with 141 rejected mutations. Verify the exact ledger with
  `bash tools/run_python_project_data.sh tools/check_mcp_implementation_admission.py`.
- **RECURRING MCP GATE:** retrieve [[mcp-recurring-six-runtime-plan]] and ADR `0062` before changing recurring MCP
  proof. Run `bash tools/check_mcp_six_runtime.sh` for the exact neutral-contract → transport → five-bindings →
  Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT consumers → admission-ledger → primary-no-drift composition. Canonical CI
  requires and syntax-checks it; `LINKEDSPEC_RUN_MCP_MATRIX=1` opts into execution. Do not add a central expected-
  response model, embed runtimes, or infer missing MCP comparisons from orchestration.
- **MCP PARENT STATUS:** unchanged closeout `.10.9.7.2` has recomposed that exact driver plus the independent
  canonical MCP opt-in and closed `.10.9.7` and `.10.9`. Formal MCP state remains 5/5 implementations + 6/6
  runtimes with rollout complete/141; semantic rollout remains 8/9 until public no-drift `.10.10`.

---

## 5. Gates & retrieval

Manual diagnostic captures must use repository-derived scratch. In the shell that will run §§5.1/6.1/6.2, create
one bounded workspace and let the shell remove it when the session ends:

```bash
source tools/project_data_env.sh
diagnostic_root=$(mktemp -d "${LINKEDSPEC_SCRATCH_ROOT:?project-data initializer did not set scratch}/manual-verification.XXXXXX")
trap 'rm -rf -- "$diagnostic_root"' EXIT
```

### 5.1 The phase0 regression gate (`t/phase0_regression.t`)
- **WHAT:** the canonical regression contract + cross-variant baseline.
- **HOW:**
  ```bash
  perl -Iperl t/phase0_regression.t > "$diagnostic_root/phase0.tap" 2>&1; echo "EXIT=$?"
  grep -cE '^ok [0-9]+ ' "$diagnostic_root/phase0.tap"                    # top-level passes
  grep -nE '^not ok [0-9]+ ' "$diagnostic_root/phase0.tap"                # failures (with names)
  grep -E '^(ok|not ok) [0-9]+ ' "$diagnostic_root/phase0.tap" | tail -1  # the REACH — trust comm only if past your targets
  ```
- **⚠️ REACH FIRST:** a subtest that `die`s aborts the run; external CPU load can SIGALRM-kill it. A
  truncated TAP makes unreached subtests look "cleared" — read the reach before trusting any count/`comm`.

### 5.2 Knowledge Map grep (before re-deriving)
- **WHAT:** `KNOWLEDGE_MAP.md` is a question-keyed index over `docs/knowledge/` fact cards.
- **WHEN:** **before** re-deriving any structural/causal fact (re-deriving an already-logged fact is
  archaeology). **HOW:** `grep -i "<question>" KNOWLEDGE_MAP.md` → follow the pointer → trust the dated
  fact or run its `reverify`. Write a new card when you establish a durable fact.

### 5.3 Document-history query and doctrine
- **WHAT:** `tools/read_document_history.pl` reads strict root-relative JSONL manifests and immutable segments;
  `scripts/check_document_history.sh` validates schema, identity, order, counts/digests, byte-exact Git-source
  reconstruction/slices, current-view limits, consumer decoupling, and bounded-hot-root shape. The paired
  `tools/roll_document_history.pl` warns at 80%, requires rollover at 90%, and keeps at most 50% after rollover.
- **WHEN:** use `--grep '<literal>'` before searching old live, change, or engineering chronology; `--segment NNNN`
  for bounded raw bytes; and `--all` only for exact complete reconstruction. Never infer current capability state
  from an archive. After prepending a complete change or notes record, run the matching rollover `--check` before
  staging; run `--apply` only when the check requires it.
- **HOW:** `perl tools/read_document_history.pl --surface live_status --grep 'needle'`,
  `perl tools/read_document_history.pl --surface change_history --grep 'needle'`,
  `perl tools/read_document_history.pl --surface engineering_notes --grep 'needle'`, and
  `bash scripts/check_document_history.sh`. Check current author pressure with
  `perl tools/roll_document_history.pl --surface change_history --check` and the equivalent `engineering_notes`
  surface. Initial snapshots are created deterministically with `perl tools/build_document_history.pl` from a
  named clean 40-hex source commit.

### 5.4 Task-tree partition lookup and metadata
- **WHAT:** `tools/read_task_tree.pl` resolves a stable ID through the strict task-tree JSONL index and prints its
  one bounded semantic owner. `scripts/check_task_tree_partitions.pl`, invoked by the existing metadata doctrine,
  proves clean-source coverage, current counts/digests, immutable history, unique stable IDs, bounded lookup, and
  collection/member ceilings.
- **WHEN:** retrieve an active or historical `FUTURE-PARITY-BACKLOG.*` node without scanning the task collection.
  Put new evidence in the returned mutable semantic part; never append to the bounded root or immutable history.
- **HOW:** `perl tools/read_task_tree.pl --tree FUTURE-PARITY-BACKLOG --id FUTURE-PARITY-BACKLOG.14.3.1.1`.
  After an owning-part edit, run `perl tools/update_task_tree_index.pl --tree FUTURE-PARITY-BACKLOG`, then
  `bash scripts/check_task_tree_metadata.sh`.

### 5.5 Doctrine / memory gates
- `bash scripts/check_doctrines.sh` (driver — runs every registered check) ·
  `bash scripts/check_memory_architecture.sh` · `bash knowledge-map/scripts/check_knowledge_map.sh` ·
  `bash scripts/check_document_history.sh` ·
  `bash scripts/check_diagnosis_evidence.sh` (staged task-acceptance evidence gate).
- `bash scripts/check_project_data_storage_locality.sh` directly runs the `PROJECT-DATA-STORAGE` structural
  doctrine. It scans current code/config/test/tool and command-guidance surfaces, including Knowledge `reverify:`
  lines, including list-form reverification commands, with 28 embedded reject/accept cases. It rejects off-
  repository project-storage defaults and bare maintained Dart command surfaces but preserves caller inputs, inert
  path/privacy fixtures, rejection-test reads, necessary external tool/system paths, and the exact inert Dart CLI
  usage label.
- `bash tools/test_project_data_process_locality.sh` runs the macOS relocated-process oracle. It kernel-denies
  writes outside a managed checkout view and developer-home/OS-temp data reads except one exact caller input, then
  requires real Perl/Rust/Dart/Julia/Lua/tool traces or bytecode. Kept REDs cover external writes, shared-cache
  reads, symlink escapes, incomplete probe sets, and missing/repository-device pre-routing host-temp authority;
  denied-access or `xcrun_db-` diagnostics fail the run. The oracle never calls `getconf` after project `TMPDIR`
  routing because that can report managed scratch instead of the host namespace.
- `bash tools/test_repo_root_process_portability.sh` runs the checkout-identity complement. It requires a freshly
  copied Rust primary to select its synthetic moved repository over a conflicting ambient cwd and repeats exact
  named-spec execution for Perl/Dart/Julia/Lua from a same-SSD cwd outside the checkout. All generated state remains
  beneath the managed repository-storage run.

---

## 6. General supporting techniques (complement the LinkedSpec tools above)

These are not LinkedSpec-specific code, but they are how LinkedSpec issues get pinpointed/verified.

### 6.1 `comm` failing-set diff (the NO-REGRESSION proof)
```bash
grep -E '^not ok ' before.tap | sed -E 's/^not ok [0-9]+ - //' | sort > "$diagnostic_root/before.failures"
grep -E '^not ok ' after.tap  | sed -E 's/^not ok [0-9]+ - //' | sort > "$diagnostic_root/after.failures"
comm -23 "$diagnostic_root/before.failures" "$diagnostic_root/after.failures"   # cleared = targets
comm -13 "$diagnostic_root/before.failures" "$diagnostic_root/after.failures"   # NEW = empty
```

### 6.2 Focused `Test::More` subtest harness (load-independent)
Extract specific brace-balanced `subtest '…' => sub { … }` blocks from `t/phase0_regression.t` into
`$diagnostic_root/focused.t` (+ `use Test::More; … done_testing;`), then run
`perl -Iperl "$diagnostic_root/focused.t"`. Verifies late
subtests when the full run is starved/killed/blocked behind an earlier failure.

### 6.3 fork+SIGKILL hard-timeout census (`alarm()` cannot kill a regex)
`alarm()` is a safe-signal deferred between opcodes; a single backtracking regex is one opcode, so an
`alarm` guard around `$parser->()` runs forever. Bound it by forking a child per input and
`kill('KILL')` from the parent after a wall-clock timeout — the only way to enumerate catastrophic
parses ([[lispish-corpus-catastrophic-backtracking]]):
```bash
perl -Iperl -MPOSIX -MTime::HiRes=time,sleep -e '
  use LinkedSpec; my $p = LinkedSpec::get_parser("Lispish");
  open(my $h,"<",$ARGV[0]); local $/; my $d=<$h>; close $h;
  my $pid = fork; if(!$pid){ eval { $p->(\$d) }; POSIX::_exit(0) }
  my $t=time; while(time-$t<6){ last if waitpid($pid,POSIX::WNOHANG)==$pid; sleep(0.05) }
  print( kill(0,$pid) ? do{kill("KILL",$pid);"HANG\n"} : "ok\n" );' conf/ambitiming.conf
```
A **tiny** input taking minutes ⇒ a ReDoS-style catastrophic-backtracking regex in the spec, not size.

### 6.4 `perl -c` — syntax gate
`perl -c perl/LinkedSpec.pm` · `perl -c -Iperl t/phase0_regression.t`. First and cheapest; run before every commit.

### 6.5 ⚠️ The `PERL5LIB` wrong-checkout hazard
The shell may carry `PERL5LIB=…/pgen/fx/perl` (a different, older LinkedSpec checkout), so a bare
`use LinkedSpec` loads the WRONG module. **Always run `perl -Iperl …`** (this repo's `perl/` is prepended
ahead of `PERL5LIB`); confirm with
`perl -Iperl -e 'use LinkedSpec; print $INC{"LinkedSpec.pm"},"\n"'` → must print `perl/LinkedSpec.pm`.

---

## Protocol A — a phase0 subtest fails
1. **Dump the engine's actual output** for that subtest's exact spec+input via §1.1 / §2.1 / §1.3 —
   never transcribe from the triage note.
2. **Route by the got-value:** a scalar/`1` where a tagged array was expected ⇒ **STALE** (re-bless to
   the dumped value); `undef` ⇒ handler compile-fail ⇒ **REAL codegen** (§2.2); `[]` ⇒ compiled but
   dropped payload ⇒ **REAL codegen** (§2.2).
3. **Fix** (re-bless to the *dumped* value, or engine fix iff objectively broken AND authorized), then
   **prove** with §5.1 + §6.1: cleared = exactly your set, new = empty.

## Protocol B — a parse rejects valid input / returns the wrong shape
1. Minimal-reproduce with §1.1 (confirm the ≥2-rule / no-regex-on-top idiom).
2. If `undef`/`[]`, dump the generated source (§2.2); bisect with `parse_only`/`generate_only` (§2.3).
3. Trace the suspect rule (§3) at `debug` for decision/mark events.

## Protocol C — a parse hangs / burns CPU
1. fork+SIGKILL census (§6.3) to find which input(s) blow up — **never** a plain `alarm()` guard.
2. A tiny input taking minutes ⇒ catastrophic-backtracking regex. Decide per doctrine: legacy
   non-portable corpus → retire/quarantine ([[feedback_keep-only-portable-cross-variant]]); else fix the
   regex (engine/spec, authorization per the engine-frozen doctrine).

---

*This catalog is LinkedSpec's own debug toolbox. Keep it in lockstep when a debug surface (a `Get`
option, a trace knob, a `tools/` script, a gate) is added or changed; register any new mechanizable
doctrine in `scripts/check_doctrines.sh`.*
