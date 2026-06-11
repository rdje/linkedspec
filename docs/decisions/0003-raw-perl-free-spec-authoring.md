# 0003 — `.spec` authoring is permanently raw-Perl-free; raw Perl is migration debt

- Date: 2026-06-04
- Status: accepted
- Tags: dsl, policy

## Context

`.spec` action code historically allowed raw Perl. The project's policy (a Core Policy
Contract in `ROADMAP_V2.md`) is that backend-neutral, method-like DSL authoring is the
permanent surface, and raw Perl inside `.spec` is obsolete compatibility debt to be
flagged and migrated — not an acceptable long-term authoring style.

## Decision

- `.spec` authoring targets canonical, backend-neutral method-like helpers (the
  ActionIR helper families: declare/assign, scalar, numeric, array, hash, control-flow,
  capture/mark, etc.) with unlimited nested composition.
- Remaining raw-Perl occurrences are surfaced loudly (compatibility-surface telemetry)
  and migrated to canonical equivalents. "Ready" must not hide Perl-shaped syntax.
- Compatibility aliases: short-term tier (`array_values`, `flatten`, `tail`, `drop_last`)
  retired 2026-06-12 (COMPAT-ALIAS-RETIREMENT.1). Medium-term tier (`return_a`, `return_m`,
  `return_ma`, `return_imatch`/`return_im`) retirement in progress.
- Documentation is a product contract: the mdBook + `USER_GUIDE.md` teach the canonical
  surface with worked examples and stay in sync with the code (see `0001` zero-drift).

## Consequences

- This is the "why" behind the `0002` all-target ActionIR-ready invariant: zero
  compatibility-surface rules is the measurable expression of this policy.
- New helpers follow a disciplined functional-expression style (clear signatures,
  parser-oriented semantics, no scope creep into lambdas/closures/currying).

## Links

- Policy: `ROADMAP_V2.md` (Core Policy Contracts, Lifecycle-Wide Structured DSL
  Contract), `ARCHITECTURE_STATE.md`.
- Related trees: `docs/tasks/METHOD-LIKE-DSL-MIGRATION.md`,
  `docs/tasks/BACKBONE-ACTION-IR-LOWERING.md`.
- Invariant: `docs/decisions/0002-all-target-actionir-ready-invariant.md`.
