# 0002 — Every shipped `.spec` compiles ActionIR-ready (ratio == 1.0000, zero compatibility-surface rules)

- Date: 2026-06-04
- Status: accepted
- Tags: parser, invariant, phase0

## Context

LinkedSpec's long-term direction is backend-neutral, raw-Perl-free `.spec` authoring
(see `0003`). A phase-0 guard added 2026-05-11 locks the current all-target
ActionIR-ready state so future DSL-migration work cannot silently regress it. This is a
durable invariant a future agent must not break without an explicit, recorded decision.

## Decision

Every discovered target `.spec` file in the corpus must compile to descriptor metadata
with:

- `language_agnostic_ready_ratio == 1.0000`,
- zero language-agnostic **blocked** rules, and
- zero **compatibility-surface** rules.

This is enforced by the canonical regression gate `t/phase0_regression.t` (run via
`tools/run_ci_local.sh`). All 19+ shipped `specs/*.spec` files currently satisfy it.

## Consequences

- New DSL features and spec migrations must preserve the invariant; a spec that
  introduces a compatibility-surface rule fails phase0 and must be migrated to canonical
  method-like helpers before landing.
- Adding a new shipped `.spec` automatically subjects it to the guard.
- Changing the invariant itself requires a new decision record superseding this one.

## Links

- Gate: `t/phase0_regression.t`, `tools/run_ci_local.sh`.
- Context: `ARCHITECTURE_STATE.md` (Strategic Judgments), `ROADMAP_V2.md` (Core Policy
  Contracts), `docs/tasks/METHOD-LIKE-DSL-MIGRATION.md`.
