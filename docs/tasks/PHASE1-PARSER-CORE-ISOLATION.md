# PHASE1-PARSER-CORE-ISOLATION: Phase 1 Parser-Core Isolation Cleanup

## Metadata

- Tree ID: `PHASE1-PARSER-CORE-ISOLATION`
- Status: `done`
- Roadmap lane: `Phase 1`
- Created: `2026-05-17`
- Last updated: `2026-05-18`
- Active frontier: `none` (tree complete)
- Owner: repo-local workflow

## Goal

Finish the last parser-core isolation cleanup around remaining compile-path compatibility seams. Phase 1 is `mostly done` per ROADMAP_V2.md — the bulk of the OwnerDispatch consolidation and dependency-surface reduction is complete. The remaining work is removing thin compatibility wrappers and forwarding shims that survive from the pre-consolidation era.

## Non-Goals

- Changing the public API output format (legacy descriptor hash projection is an intentional adapter between internal state and public API, not a cleanup relic).
- Removing the `compatibility_surface` diagnostic infrastructure — that remains as an observation tool for migration metrics.
- Retiring compatibility aliases from the DSL helper surface (that's under METHOD-LIKE-DSL-MIGRATION).
- PLUGIN-ACTION-MIGRATION (retired track).

## Acceptance Criteria

- ActionRewriter.pm forwarding shim is evaluated for removal or inlined.
- `rewrite_action_code_for_compat` in EmitContext.pm is either removed or its fallback is verified to be covered by the canonical pipeline.
- Any remaining "backward-compatible" wrappers in the compile path are either removed or explicitly documented as intentional public API adapters.
- Full regression gate passes (1010+ PASS).
- Live docs and roadmap status updated.

## Task Tree

- ID: `PHASE1-PARSER-CORE-ISOLATION`
  Status: `active`
  Goal: `Remove the last compile-path compatibility seams: ActionRewriter.pm forwarding shim and rewrite_action_code_for_compat fallback.`
  Children: `PHASE1-PARSER-CORE-ISOLATION.1`, `PHASE1-PARSER-CORE-ISOLATION.2`, `PHASE1-PARSER-CORE-ISOLATION.3`

- ID: `PHASE1-PARSER-CORE-ISOLATION.1`
  Status: `done`
  Goal: `Survey and inventory remaining compile-path compatibility seams — confirm the survey findings and identify any additional seams not captured.`
  Acceptance: `Inventory includes: ActionRewriter.pm forwarding shim (118 lines, 59 generated forwarders + call_spec_handler_subst), rewrite_action_code_for_compat in EmitContext.pm (line 485, s/h/a fallback), output format conversions in Compiler.pm/CompilerState.pm (assessed as intentional API adapters, not cleanup targets), dual-path input normalizers in CompilerState.pm (assessed as intentional). Test references to compat paths identified.`
  Verification: `2026-05-17: Full inventory complete. 4 seams identified: (1) ActionRewriter.pm — 118 lines, 59 generated forwarders all delegating to EmitContext via _delegate_emit_context_call, 1 explicit call_spec_handler_subst. Zero non-test external callers. Public facade LinkedSpec.pm line 186 has own call_spec_handler_subst going directly to EmitContext via OwnerDispatch — bypassing ActionRewriter entirely. Tests (phase0_regression.t) verify ActionRewriter is lazily loaded, excluded from compile pipeline, owner callbacks trapped. Verdict: REMOVABLE. (2) rewrite_action_code_for_compat — EmitContext.pm lines 485-504, wraps _rewrite_action_code_with_diagnostics with s/h/a fallback via _lower_method_value_expr. Called from LinkedSpec.pm line 188 and ActionRewriter.pm line 114. Verdict: NEEDS EVALUATION (.3). (3) Output format conversions — compiled_spec_state_to_legacy_spec, compiled_descriptor_state_to_legacy_descriptor, normalize_compiled_spec_input, normalize_compiled_dependency_regex_output. Intentional adapters between internal state objects and public API legacy flat-hash format. Verdict: KEEP. (4) PluginBridge legacy functions — _load_legacy_plugin_runtime, _exec_legacy_plugin, _get_legacy_plugin. Runtime plugin dispatch, not compile path. Verdict: OUT OF SCOPE. No additional seams found beyond original survey.`
  Commit: `pending`

- ID: `PHASE1-PARSER-CORE-ISOLATION.2`
  Status: `done`
  Goal: `Evaluate and remove/simplify ActionRewriter.pm forwarding shim — if no external callers depend on it, delete the 118-line file; otherwise, document why it must stay.`
  Acceptance: `ActionRewriter.pm is either deleted or explicitly retained with rationale. If deleted, all test references are updated. If retained, the file has a comment explaining why it cannot yet be removed.`
  Verification: `2026-05-18: ActionRewriter.pm (118 lines, 59 generated forwarders + call_spec_handler_subst) DELETED. Zero non-test callers confirmed. All 451 test references updated (217 LinkedSpec::ActionRewriter:: → LinkedSpec::RuleIR::EmitContext::, 13 call_spec_handler_subst → rewrite_action_code_for_compat, 6 ActionRewriter-specific subtests removed). 1004 PASS.`
  Commit: `pending`

- ID: `PHASE1-PARSER-CORE-ISOLATION.3`
  Status: `done`
  Goal: `Evaluate rewrite_action_code_for_compat fallback in EmitContext.pm — verify the canonical pipeline covers its behavior, then remove or inline.`
  Acceptance: `rewrite_action_code_for_compat is either removed (if canonical pipeline covers its s/h/a fallback) or its residual need is explicitly documented. Full regression gate passes.`
  Verification: `2026-05-18: Evaluated. Fallback retained with documentation. The canonical pipeline handles s()/a()/h() correctly inside recognized contracts (e.g. return(s(foo))). The fallback only triggers for bare s/a/h with no contract wrapper — malformed standalone value accessors. No shipped .spec hits this path, no test exercises it. Fallback is a 20-line defensive compatibility measure. Comment added to EmitContext.pm explaining the residual need. 1004 PASS.`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE1-PARSER-CORE-ISOLATION.1` | `done` | Inventory complete — 4 seams, ActionRewriter.pm REMOVABLE, rewrite_action_code_for_compat needs evaluation. |
| 2 | `PHASE1-PARSER-CORE-ISOLATION.2` | `done` | ActionRewriter.pm DELETED (118 lines). 451 test references updated. 1004 PASS. |
| 3 | `PHASE1-PARSER-CORE-ISOLATION.3` | `done` | rewrite_action_code_for_compat evaluated — fallback retained with documentation. Residual defensive compatibility for bare s/a/h. |

## Background

### What's already done (Phase 1 / 1A)

Phase 1A close-out verified that LinkedSpec.pm is a 286-line thin facade; 18 extracted modules use uniform OwnerDispatch; no monolith-era patterns remain. The OwnerDispatch consolidation eliminated dead wrapper functions across Runtime, Compiler, BootstrapSpec, SpecEntry, RuleIR::EmitContext, ActionIR::Scanner, and all compile/support-owner packages. The façade/parser-factory, dep-map-only ActionIR, runtime/bootstrap/scanner/emit-context, single-use helper-owner, one-shot orchestration-wrapper, Resolver trace-wrapper, Scanner owner-wrapper, and compile/support-owner package/callback-loader OwnerDispatch wrappers are all gone.

### What remains (Phase 1)

From the 2026-05-17 survey:

1. **ActionRewriter.pm** (118 lines): A pure forwarding shim with 59 generated method forwarders that all delegate to `_delegate_emit_context_call`. The only explicit function, `call_spec_handler_subst`, delegates to `rewrite_action_code_for_compat`. No rewriting logic lives here — it's a thin veneer over EmitContext.

2. **`rewrite_action_code_for_compat`** (EmitContext.pm line 485): The last live compatibility rewrite in the compile pipeline. It wraps the canonical `_rewrite_action_code_with_diagnostics` with one extra heuristic: if a bare `s(...)`, `a(...)`, or `h(...)` expression was unchanged by the canonical pipeline, it attempts a `_lower_method_value_expr` fallback.

3. **Output format conversions** (Compiler.pm / CompilerState.pm): `compiled_spec_state_to_legacy_spec`, `compiled_descriptor_state_to_legacy_descriptor`, and the dual-path normalizers `normalize_compiled_spec_input` / `normalize_compiled_dependency_regex_output`. These are intentional adapters between internal state objects and the public API's legacy flat-hash format — not cleanup targets for this tree.

4. **PluginBridge legacy functions**: `_load_legacy_plugin_runtime`, `_exec_legacy_plugin`, `_get_legacy_plugin` — these are runtime plugin dispatch, not compile path. Out of scope for Phase 1 parser-core isolation.

## Decisions

- `2026-05-17`: Created task tree. Phase 1 is `mostly done` in ROADMAP_V2.md with a 1-line TODO. Survey found 2 concrete cleanup targets (ActionRewriter.pm shim, rewrite_action_code_for_compat fallback) and 2 intentional adapters (output conversions, dual-path normalizers) that should stay.

## Open Questions

- Does `_lower_method_value_expr` in MethodLowering.pm already cover the s/h/a bare-expression case that `rewrite_action_code_for_compat` handles? (Leaf .3 will determine.)
- Are there any external callers of `LinkedSpec::ActionRewriter` outside the test suite? (Leaf .2 will determine.)

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-05-17` | `PHASE1-PARSER-CORE-ISOLATION.1` | 4 seams inventoried. ActionRewriter.pm: 118 lines, 59 forwarders, 0 non-test callers → REMOVABLE. rewrite_action_code_for_compat: s/h/a fallback → NEEDS EVALUATION (.3). Output conversions: intentional adapters → KEEP. PluginBridge: runtime, out of scope. No additional seams. | Pass — inventory complete. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `2026-05-18` | `PHASE1-PARSER-CORE-ISOLATION.2` | ActionRewriter.pm deleted (118 lines, 59 forwarders). 451 test references updated. 6 ActionRewriter-specific subtests removed. 217 function calls updated. 13 call_spec_handler_subst → rewrite_action_code_for_compat. 10 broken require_avoids assertions fixed. 1004 PASS. | Pass — ActionRewriter.pm removed. |
| `2026-05-18` | `PHASE1-PARSER-CORE-ISOLATION.3` | Evaluated rewrite_action_code_for_compat fallback. Fallback retained with documentation — canonical pipeline handles s/a/h inside contracts; bare standalone s/a/h is malformed but the 20-line fallback is a defensive safety net. No shipped .spec hits this path. 1004 PASS. | Pass — evaluation complete. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `PHASE1-PARSER-CORE-ISOLATION.1` | `627ba5f` | Compile-path compatibility seam inventory. |
| `PHASE1-PARSER-CORE-ISOLATION.2` | `4f8e0b6` | ActionRewriter.pm deleted, 451 test references updated. |
| `PHASE1-PARSER-CORE-ISOLATION.3` | `c45f597` | rewrite_action_code_for_compat evaluated, fallback documented. |

## Changelog

- `2026-05-18`: Completed PHASE1-PARSER-CORE-ISOLATION.3 — evaluated rewrite_action_code_for_compat fallback. Fallback retained with documentation in EmitContext.pm. Canonical pipeline handles s/a/h inside contracts; the fallback is a defensive safety net for bare standalone s/a/h (malformed, never hit by shipped specs). PHASE1-PARSER-CORE-ISOLATION tree COMPLETE (3 leaves). 1004 PASS.
- `2026-05-18`: Completed PHASE1-PARSER-CORE-ISOLATION.2 — removed ActionRewriter.pm forwarding shim (118 lines, 59 generated forwarders + call_spec_handler_subst). 451 test references updated, 6 ActionRewriter-specific subtests removed, 10 broken assertions fixed. Full suite: 1004 PASS. Active PNT frontier: PHASE1-PARSER-CORE-ISOLATION.3.
- `2026-05-17`: Completed PHASE1-PARSER-CORE-ISOLATION.1 — full compile-path compatibility seam inventory. 4 seams identified: ActionRewriter.pm (REMOVABLE), rewrite_action_code_for_compat (NEEDS EVALUATION), output format conversions (KEEP), PluginBridge (OUT OF SCOPE). Frontier → .2.
- `2026-05-17`: Created task tree for Phase 1 parser-core isolation cleanup (was `mostly done` in ROADMAP_V2.md without task-tree ownership). 3 leaves defined: inventory, ActionRewriter.pm removal, rewrite_action_code_for_compat evaluation.
