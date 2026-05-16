# PHASE5-RUNTIME-DIAGNOSTICS: Phase 5 Runtime and Diagnostics Modernization

## Metadata

- Tree ID: `PHASE5-RUNTIME-DIAGNOSTICS`
- Status: `active`
- Roadmap lane: `Phase 5`
- Created: `2026-05-16`
- Last updated: `2026-05-16`
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
  Children: `PHASE5-RUNTIME-DIAGNOSTICS.1`

- ID: `PHASE5-RUNTIME-DIAGNOSTICS.1`
  Status: `pending`
  Goal: `Inventory current diagnostics/runtime surface: map each structured payload family (compiler_pipeline, parser_factory, runtime_owner, runtime_handler, runtime_parser), eval-elimination status, and trace bridging coverage.`
  Acceptance: `Task file lists each diagnostics stage, its structured-payload coverage, remaining raw-die or stderr-leak paths, and names the next close-out leaf.`
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PHASE5-RUNTIME-DIAGNOSTICS.1` | `pending` | Need a diagnostics-surface audit before declaring Phase 5 done. |

## Decisions

- `2026-05-16`: Created task tree. Extensive structured-diagnostics, eager handler compilation, and runtime-context centralization already landed.

## Open Questions

- Are there remaining eval paths or stderr leaks? (Answer pending inventory.)

## Blockers

- None.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| — | — | — | — |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- | --- |
| — | — | — | — |

## Changelog

- `2026-05-16`: Created task tree from template.
