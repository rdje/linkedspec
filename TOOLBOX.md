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
  driver), invoked by [`.githooks/pre-commit`](.githooks/pre-commit) (E3) + `tools/run_ci_local.sh` (E4).
  For staged code/spec/test/tooling changes, `TASK-ACCEPTANCE`
  ([`scripts/check_diagnosis_evidence.sh`](scripts/check_diagnosis_evidence.sh)) requires the owning
  task file to carry the checklist below with LinkedSpec-tool evidence signatures.

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
| "Is the suite green? did my change move exactly the right tests?" | [§5.1 phase0 gate](#51-the-phase0-regression-gate-tphase0_regressiont) + [§6.1 `comm`](#61-comm-failing-set-diff-the-no-regression-proof) |
| "A parse hangs / burns CPU — which file, regex blowup?" | [§6.3 fork+SIGKILL census](#63-forksigkill-hard-timeout-census-alarm-cannot-kill-a-regex) |
| "Did I already establish this fact? (avoid archaeology)" | [§5.2 Knowledge Map grep](#52-knowledge-map-grep-before-re-deriving) |

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
  through MethodLowering. Rust also satisfies the mdBook-documented external trace capability contract as of
  `TRACE-OBSERVABILITY.4.5`. Future variants must expose the same documented controls, levels, event classes,
  sink behavior, and default-quiet behavior before claiming trace parity.
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
  `TRACE-OBSERVABILITY.4.5` closes the parity proof: Rust can claim parity for the documented external capability
  contract, while future variants must pass the mdBook checklist before making the same claim.
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
- **HOW:** `perl -Iperl tools/cross_check_spec_parsers.pl` · `perl -Iperl tools/gen_oracle_corpus.pl`.

### 4.3 `tools/run_cli_conformance.pl` — backend-neutral primary CLI byte contract
- **WHAT:** execute any backend command array against `cli_conformance/manifest.json` in isolated per-case
  workspaces, capturing stdout/stderr separately and comparing exact bytes, exit status, and expected generated
  files. `{{COMMAND}}` substitutes only the allowed executable token/host wrapper difference.
- **WHEN:** changing a primary CLI, its help/errors/trace behavior, or the shared cross-backend command contract.
- **HOW:**
  ```bash
  PERL5LIB= perl tools/run_cli_conformance.pl \
    --display-command 'perl bin/linkedspec' \
    -- perl -I{{REPO_ROOT}}/perl {{REPO_ROOT}}/bin/linkedspec
  ```
  Use `--case ID` before `--` for focused execution. The current baseline contains two exact help, 20 strict
  usage, seven success, four operational failure, and 20 canonical trace cases. Perl passes 53/53; `.1.5.1.6`
  is active for the surfaced UTF-8 process boundary before pending Rust `.1.5.2` consumes this manifest.

### 4.4 `tools/run_ci_local.sh` / `tools/ram_guard.sh`
- **WHAT:** `run_ci_local.sh` = the canonical local CI gate (doctrines + primary CLI conformance in default/POSIX
  environments + regression, E4);
  `ram_guard.sh` = a memory guard for heavy runs. **HOW:** `bash tools/run_ci_local.sh`.

### 4.5 `tools/check_unicode_case_contract.py` — pinned Unicode casing proof

- **WHAT:** verifies exact decompressed Unicode 17.0.0 source hashes, regenerates the neutral full-casing contract
  and generated backend modules into owned temporary storage, byte-compares them, validates the neutral
  schema/counts/order/scalars/digest, and independently executes expansions, combining output, supplementary
  characters, `Final_Sigma`, and no-normalization fixtures.
- **WHEN:** changing `lowercase`/`uppercase`, Unicode data, generated backend tables, or diagnosing a casing mismatch.
- **HOW:** `python3 tools/check_unicode_case_contract.py`. Regenerate deliberately with
  `python3 unicode_case/generate_unicode_case_contract.py`; ordinary verification is offline.
- **OUTPUT:** `unicode-case-contract: OK (Unicode 17.0.0; 1563 lower; 1581 upper; 158/464 property ranges; 12 fixtures)`.

### 4.6 `tools/check_scalar_numeric_contract.py` — portable scalar numeric proof

- **WHAT:** validates `linkedspec-scalar-numeric-v1` schema/policy, independently evaluates all structured cases,
  and deterministically regenerates the backend-neutral `.spec` fixture and expected result object.
- **WHEN:** changing numeric input coercion, helper arity, invalid/null behavior, comparisons, rounding, min/max,
  clamp/division fences, or signed modulo in any backend.
- **HOW:** `python3 tools/check_scalar_numeric_contract.py`.
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
- **HOW:** `python3 tools/check_callable_signature_contract.py`.
- **OUTPUT:** `callable-signature-contract: OK (3 definitions; 9 calls; 7 invalid definitions)`.
- **PERL ADAPTER:** `PERL5LIB= prove -Iperl t/variadic_user_function_contract.t` consumes the same fixture through
  the spec-owned shell, staged/outward records, generated source, eager/fresh binding, diagnostics, and execution.

### 4.9 `tools/check_semantic_introspection_contract.py` — neutral model/query oracle

- **WHAT:** validates `linkedspec-semantic-model-v1`, `linkedspec-semantic-query-v1`, and the owned backend-admission
  topology. It checks the exact schema, source bytes/spans/digests, normalized records/relations, staged payload/job/
  result topology, deterministic query evaluation, digest-locked responses, rollout/admission omissions, privacy,
  budgets, and the handle-only MCP boundary; backend-native semantics remain owned by each admitted consumer.
- **WHEN:** changing semantic-index vocabulary, ids/order, calls/shapes, staged/generated provenance, explanations,
  source policy, pages/budgets, backend rollout metadata, or future native/MCP consumers.
- **HOW:** `python3 tools/check_semantic_introspection_contract.py`.
- **OUTPUT:** `semantic introspection contract: 6 fixture groups, 20 exact queries, 81 rejected mutations, rollout 4 complete / 5 pending, admission 3 complete / 3 pending`.
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
- **DART COMPOSED ADMISSION:** `dart test test/semantic_introspection_dart_admission_test.dart` from `dart/`
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
  routes. Run it with the classifier/native-route tests for focused 1,885; complete Julia is 5,596/primary/105.
  `.3` still owns all 8 negatives plus unrelated-grammar isolation and `.4` composition. Use a writable depot
  first; never infer membership or identity from host PCRE2 examples.

---

## 5. Gates & retrieval

### 5.1 The phase0 regression gate (`t/phase0_regression.t`)
- **WHAT:** the canonical regression contract + cross-variant baseline.
- **HOW:**
  ```bash
  perl -Iperl t/phase0_regression.t > /tmp/phase0.tap 2>&1; echo "EXIT=$?"
  grep -cE '^ok [0-9]+ ' /tmp/phase0.tap                    # top-level passes
  grep -nE '^not ok [0-9]+ ' /tmp/phase0.tap                # failures (with names)
  grep -E '^(ok|not ok) [0-9]+ ' /tmp/phase0.tap | tail -1  # the REACH — trust comm only if past your targets
  ```
- **⚠️ REACH FIRST:** a subtest that `die`s aborts the run; external CPU load can SIGALRM-kill it. A
  truncated TAP makes unreached subtests look "cleared" — read the reach before trusting any count/`comm`.

### 5.2 Knowledge Map grep (before re-deriving)
- **WHAT:** `KNOWLEDGE_MAP.md` is a question-keyed index over `docs/knowledge/` fact cards.
- **WHEN:** **before** re-deriving any structural/causal fact (re-deriving an already-logged fact is
  archaeology). **HOW:** `grep -i "<question>" KNOWLEDGE_MAP.md` → follow the pointer → trust the dated
  fact or run its `reverify`. Write a new card when you establish a durable fact.

### 5.3 Doctrine / memory gates
- `bash scripts/check_doctrines.sh` (driver — runs every registered check) ·
  `bash scripts/check_memory_architecture.sh` · `bash knowledge-map/scripts/check_knowledge_map.sh` ·
  `bash scripts/check_diagnosis_evidence.sh` (staged task-acceptance evidence gate).

---

## 6. General supporting techniques (complement the LinkedSpec tools above)

These are not LinkedSpec-specific code, but they are how LinkedSpec issues get pinpointed/verified.

### 6.1 `comm` failing-set diff (the NO-REGRESSION proof)
```bash
grep -E '^not ok ' before.tap | sed -E 's/^not ok [0-9]+ - //' | sort > /tmp/b
grep -E '^not ok ' after.tap  | sed -E 's/^not ok [0-9]+ - //' | sort > /tmp/a
comm -23 /tmp/b /tmp/a   # cleared (must equal your targets)
comm -13 /tmp/b /tmp/a   # NEW failures (must be empty)
```

### 6.2 Focused `Test::More` subtest harness (load-independent)
Extract specific brace-balanced `subtest '…' => sub { … }` blocks from `t/phase0_regression.t` into
`/tmp/focused.t` (+ `use Test::More; … done_testing;`), run `perl -Iperl /tmp/focused.t`. Verifies late
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
