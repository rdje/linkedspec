# PHASE1-PARSER-CORE-ISOLATION: Phase 1 Parser-Core Isolation Cleanup

## Metadata

- Tree ID: `PHASE1-PARSER-CORE-ISOLATION`
- Status: `active`
- Roadmap lane: `Phase 1`
- Created: `2026-05-17`
- Last updated: `2026-05-17`
- Active frontier: `PHASE1-PARSER-CORE-ISOLATION.1`
- Owner: repo-local workflow

## Goal

Finish the last parser-core isolation cleanup around remaining compile-path compatibility seams. Phase 1 is `mostly done` per ROADMAP_V2.md — the bulk of the OwnerDispatch consolidation and dependency-surface reduction is complete. The remaining work is removing thin compatibility wrappers and forwarding shims that survive from the pre-consolidation era.

## Non-Goals

- Changing the public API output format (legacy descriptor hash projection is an intentional adapter between internal state and public API, not a cleanup relic).
- Removing the `compatibility_surface` diagnostic infrastructure — that remains as an observation tool for migration metrics.
- Retiring compatibility aliases from the DSL helper surface (that's under METHOD-LIKE-DSL-MIGRATION).
- PLUGIN-ACTION-MIGRATION (separate proposed track).

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
  Status: `pending`
  Goal: `Survey and inventory remaining compile-path compatibility seams — confirm the survey findings and identify any additional seams not captured.`
  Acceptance: `Inventory includes: ActionRewriter.pm forwarding shim (118 lines, 59 generated forwarders + call_spec_handler_subst), rewrite_action_code_for_compat in EmitContext.pm (line 485, s/h/a fallback), output format conversions in Compiler.pm/CompilerState.pm (assessed as intentional API adapters, not cleanup targets), dual-path input normalizers in CompilerState.pm (assessed as intentional). Test references to compat paths identified.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE1-PARSER-CORE-ISOLATION.2`
  Status: `pending`
  Goal: `Evaluate and remove/simplify ActionRewriter.pm forwarding shim — if no external callers depend on it, delete the 118-line file; otherwise, document why it must stay.`
  Acceptance: `ActionRewriter.pm is either deleted or explicitly retained with rationale. If deleted, all test references are updated. If retained, the file has a comment explaining why it cannot yet be removed.`
  Verification: `pending`
  Commit: `pending`

- ID: `PHASE1-PARSER-CORE-ISOLATION.3`
  Status: `pending`
  Goal: `Evaluate rewrite_action_code_for_compat fallback in EmitContext.pm — verify the canonical pipeline covers its behavior, then remove or inline.`
  Acceptance: `rewrite_action_code_for_compat is either removed (if canonical pipeline covers its s/h/a fallback) or its residual need is explicitly documented. Full regression gate passes.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE1-PARSER-CORE-ISOLATION.1` | `pending` | Inventory — confirm survey findings and identify test references. |
| 2 | `PHASE1-PARSER-CORE-ISOLATION.2` | `pending` | ActionRewriter.pm — depende on inventory (.1) for test reference list. |
| 3 | `PHASE1-PARSER-CORE-ISOLATION.3` | `pending` | rewrite_action_code_for_compat — depends on .2 completion before behavioral removal. |

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
| `pending` | `pending` | `pending` | `pending` |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| `pending` | `pending` | `pending` |

## Changelog

- `2026-05-17`: Created task tree for Phase 1 parser-core isolation cleanup (was `mostly done` in ROADMAP_V2.md without task-tree ownership). 3 leaves defined: inventory, ActionRewriter.pm removal, rewrite_action_code_for_compat evaluation.
