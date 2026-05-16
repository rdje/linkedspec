# PHASE5-RUNTIME-DIAGNOSTICS: Phase 5 Runtime and Diagnostics Modernization

## Metadata

- Tree ID: `PHASE5-RUNTIME-DIAGNOSTICS`
- Status: `active`
- Roadmap lane: `Phase 5`
- Created: `2026-05-16`
- Last updated: `2026-05-17`
- Owner: repo-local workflow

## Goal

Complete runtime modernization: predictable performance, consistent structured diagnostics, reduced dynamic-eval fragility, and clear debug tracing.

## Non-Goals

- New DSL features (Phases 2-4).
- Self-hosted grammar (Phase 7).
- Capture/mark API (Phase 4).

## Acceptance Criteria

- Structured `runtime_ctx->{last_error}` is the single diagnostics channel.
- Generated handler string-eval is minimized (eager compile, cached coderef, no per-invocation eval).
- No stderr leakage from handler compile failures.
- Debug trace output bridges cleanly from compile-time scopes into runtime handler scopes.
- Phase 5 exit criteria met per `ROADMAP.md`.

## Task Tree

- ID: `PHASE5-RUNTIME-DIAGNOSTICS`
  Status: `active`
  Goal: `Complete runtime and diagnostics modernization.`
  Children: `PHASE5-RUNTIME-DIAGNOSTICS.1`, `PHASE5-RUNTIME-DIAGNOSTICS.2`

- ID: `PHASE5-RUNTIME-DIAGNOSTICS.1`
  Status: `completed`
  Goal: `Inventory current diagnostics/runtime surface: map each structured payload family (compiler_pipeline, parser_factory, runtime_owner, runtime_handler, runtime_parser), eval-elimination status, and trace bridging coverage.`
  Acceptance: `Task file lists each diagnostics stage, its structured-payload coverage, remaining raw-die or stderr-leak paths, and names the next close-out leaf.`
  Verification: `2026-05-17: Full inventory complete (see below). Audited RuntimeContext.pm, Runtime.pm, Compiler.pm, ParserFactory.pm, SpecEntry.pm, LinkedRE.pm, BootstrapSpec/Core.pm. 5 structured error families across 30+ call sites. 1 remaining stderr leak found (SpecEntry.pm line 740: warn $compile_warning on successful handler compilation). Created 1 follow-on leaf (.2).`
  Commit: `pending`

- ID: `PHASE5-RUNTIME-DIAGNOSTICS.2`
  Status: `pending`
  Goal: `Fix SpecEntry.pm line 740 stderr leak: route handler compile warnings through _trace_log_output instead of warn.`
  Acceptance: `Successful handler compilations with warnings no longer emit to stderr. Compile warnings are captured in the trace output at DUMP_NONE level. Handler compile failures continue to route through the structured last_error channel with warnings included in the detail.`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 2 | `PHASE5-RUNTIME-DIAGNOSTICS.2` | `pending` | Fix stderr leak: handler compile warnings via warn. |

## PHASE5-RUNTIME-DIAGNOSTICS.1 Inventory (2026-05-17)

### Structured Diagnostics Surface

All diagnostics route through `LinkedSpec::RuntimeContext` (384 lines, 38 subs) via a shared `set_runtime_ctx_last_error` family. Five payload families cover 30+ call sites:

**`compiler_pipeline` family** — Compiler.pm (20 call sites):
| Stage | Purpose |
| --- | --- |
| `prepare_pipeline` | Callback/runtime-owner prep failure before validation |
| `validate_spec_content` | DSL syntax validation failure |
| `validate_dsl_syntax` | Deeper DSL validation failure (inside-block rule, extra colon, etc.) |
| `bootstrap_parse` | Bootstrap grammar parse failure |
| `build_compiled_rule_table` | Rule-table construction failure |
| `build_final_descriptor` | Final descriptor assembly failure |
| `validate_dependency_regex_references` | Dependency/reference validation failure |

**`parser_factory` family** — ParserFactory.pm (6 call sites):
| Stage | Purpose |
| --- | --- |
| `prepare_parser_factory` | Callback/trace prep failure |
| `validate_spec_name` | Spec name validation failure |
| `resolve_spec_path` | Spec file path resolution failure |
| `load_spec_content` | Spec file load failure |
| `compile_spec` | Parser-factory compile delegation failure |

**`runtime_owner` family** — Runtime.pm (2 call sites):
| Stage | Purpose |
| --- | --- |
| `run_get_pipeline` | Runtime → Compiler delegation failure or malformed return |

**`runtime_handler` family** — SpecEntry.pm (2 call sites):
| Stage | Purpose |
| --- | --- |
| `rule_handler_compile` | Generated handler string-eval failure (on first invocation) |
| `rule_handler_eval` | Handler execution failure at runtime |

**`runtime_parser` family** — Compiler.pm (3 call sites):
| Stage | Purpose |
| --- | --- |
| `resolve_top_rule_handler` | Top rule or handler coderef resolution failure |
| `invoke_top_rule:<top_rule>` | Parser invocation scope |

All families carry `owner_stage`, `summary`, `detail`, `rule_label` (where applicable), `handler_source_label`, `handler_variant`, and `spec_name`/`spec_path`/`top_rule` metadata when known. The `set_runtime_ctx_last_error_unless_present` variant preserves deeper payloads when already set.

### Eval Elimination Status

- **Handler compilation eval** (SpecEntry.pm line 738): ONE remaining `eval $handler_source`. This is the minimum — Perl requires eval to compile generated code at runtime. Already inside a `$SIG{__WARN__}` trap and a structured `$compile_error` path. Compiled handler is cached by rule label and variant; re-used on subsequent invocations with no re-eval.
- **Handler execution eval** (SpecEntry.pm line 780): `eval { $compiled_handler->(...) }` — catches runtime handler exceptions for structured diagnostics. Not a string eval, just an exception trap.
- **BootstrapSpec::Core.pm**: Zero eval statements (the bootstrap grammar is pure regex matching, no code generation eval).
- **LinkedRE.pm**: `use re 'eval'` pragma only (needed for `(?{...})` regex features). No string eval.
- **RTLUtils.pm**: `use re 'eval'` pragma only. No string eval.
- **Blind-call / repeated-sequence helpers**: Now emit plain nested anonymous subs instead of `eval`-wrapped string fragments (confirmed per ROADMAP_V2.md changelog).

### Trace Bridging Status

Compile-time and runtime trace scopes bridge cleanly:
- `LinkedSpec::parser_invoke:<top_rule>` → `resolve_top_rule_handler` → `invoke_top_rule:<top_rule>` → `LinkedSpec::rule_handler:<label>`
- `rule_handler_compile:<label>` / `rule_handler_eval:<label>` trace decisions
- Returned parser coderefs emit trace enter (DUMP_HIGH) and exit with return shape metadata

### Stderr Leak Audit

**One remaining leak** — SpecEntry.pm line 740:
```perl
warn $compile_warning if ref($compiled_handler) eq 'CODE' && length($compile_warning);
```
Handler compile warnings on **successful** compilation go to stderr via `warn`. On **failed** compilation, warnings are included in `$compile_error` and properly routed through `runtime_ctx->{last_error}` (stage `rule_handler_compile`). The leak only affects the success path — warnings like "use of uninitialized value" in generated handler code. → **PHASE5-RUNTIME-DIAGNOSTICS.2**

**Verified clean**:
- No direct `print STDERR` anywhere in the LinkedSpec namespace.
- No `warn` outside of SpecEntry.pm line 740.
- All `die` calls in Compiler.pm, ParserFactory.pm, RuntimeContext.pm, Runtime.pm are inside `eval {}` blocks and caught by structured error handling.

### Remaining raw-die Exposure

All raw `die` calls in the Compiler/ParserFactory/Runtime pipeline are inside `eval {}` blocks with the exception caught and routed to `set_runtime_ctx_last_error_for_owner`. No raw dies escape to the public API surface. The `_require_dep` validators in Compiler.pm (7) and ParserFactory.pm (8) are executed inside `eval {}` blocks in `run_get_pipeline()` and `run_get_parser()`.

### Handler Caching

Handlers are compiled eagerly (not lazily on first invocation) via `_build_runtime_handler` in SpecEntry.pm. The compiled coderef is stored in the handler table keyed by `handler_variant` or `_default`. `_resolve_handler_coderef` selects the appropriate handler for each rule. Compilation happens once per handler variant; all subsequent invocations use the cached coderef with no string eval.

### Phase 5 Exit Criteria Status

Per ROADMAP_V2.md Phase 5 acceptance:
- Structured `runtime_ctx->{last_error}` is the single diagnostics channel: **MOSTLY** (1 stderr leak on handler compile warnings)
- Generated handler string-eval minimized: **DONE** (single eval, cached coderef)
- No stderr leakage from handler compile failures: **DONE** (failures routed through structured channel)
- Debug trace bridges compile→runtime: **DONE** (parser_invoke → rule_handler scope chain)
- Phase 5 exit criteria met per ROADMAP.md: **PENDING** (fix .2 stderr leak)

## Decisions

- `2026-05-17`: Completed PHASE5-RUNTIME-DIAGNOSTICS.1 inventory. 5 structured error families verified across 30+ call sites. Single stderr leak found (SpecEntry.pm line 740: warn on handler compile warnings). Created .2 fix leaf.
- `2026-05-16`: Created task tree. Extensive structured-diagnostics, eager handler compilation, and runtime-context centralization already landed.

## Open Questions

- ~~Are there remaining eval paths or stderr leaks?~~ Resolved: 1 stderr leak found (SpecEntry.pm line 740 — handler compile warnings on success path). Eval surface is minimal: 1 handler compilation eval, 1 handler execution eval trap, zero in BootstrapSpec.

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-05-17` | `PHASE5-RUNTIME-DIAGNOSTICS.1` | Audited all 5 structured error families across RuntimeContext.pm, Runtime.pm, Compiler.pm, ParserFactory.pm, SpecEntry.pm. Verified eval surface (1 handler compile eval, 1 execution eval trap, zero in BootstrapSpec). Checked stderr leakage (1 leak found). Verified trace bridging (parser_invoke → rule_handler scope chain). Verified handler caching (eager compile, coderef reuse). | Pass — 1 minor stderr leak found (SpecEntry.pm:740). Created .2 fix leaf. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `PHASE5-RUNTIME-DIAGNOSTICS.1` | `pending` | — |

## Changelog

- `2026-05-17`: Completed PHASE5-RUNTIME-DIAGNOSTICS.1 inventory. 5 structured error families, 30+ call sites. Single stderr leak (SpecEntry.pm:740). Created .2 fix leaf.
- `2026-05-16`: Created task tree from template.
