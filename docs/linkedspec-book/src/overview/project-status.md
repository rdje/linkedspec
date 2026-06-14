# Project Status

LinkedSpec is an actively evolving system. The current direction is not “freeze everything exactly as it once was.” The direction is to preserve the strengths that make LinkedSpec useful while modernizing the runtime, compiler, diagnostics, and documentation.

## Completed phases

Phases 0–7 of the modernization roadmap are done:

- **Phase 0**: Regression safety net — `t/phase0_regression.t` covers all 20 shipped specs with a green baseline; every `.spec` compiles at `language_agnostic_ready_ratio == 1.0000` (zero compatibility-surface rules).
- **Phase 1**: Thin facade + owner dispatch — `LinkedSpec.pm` is a 258-line lazy facade; 27 modules use uniform `OwnerDispatch`; the former `ActionRewriter.pm` forwarding shim was deleted (118 lines).
- **Phase 1A**: Thin-façade modularization — `LinkedSpec.pm` delegated into focused owner modules (`Trace`, `Validation`, `Resolver`, `Runtime`, `Compiler`, `BootstrapSpec`, `SpecEntry`, `RuleIR`, `EmitContext`); the shared `OwnerDispatch` seam replaced per-owner lazy-loading wrappers.
- **Phase 2**: DSL frontend hardening — rule-label parsing, inside-block rejection, extra-colon rejection, fluent-continuation recognition, `strict_syntax` mode, construct-recognition alignment with bootstrap grammar.
- **Phase 3**: Execution semantics — seek/consume parse modes documented; BACKTRACK/IBACKTRACK defined as local cursor-rewind, not systemic backtracking; forward-moving non-backtracking model stated.
- **Phase 4**: Capture/mark API — 163 contracts across 6 families verified, compat aliases documented, mark-helper reference complete.
- **Phase 5**: Runtime diagnostics — structured last_error is the single diagnostics channel; handler compile warnings routed through trace instead of stderr; eval minimized to one handler compilation; trace bridging from compile scopes into runtime handler scopes.
- **Phase 6**: Documentation and adoption — the book you are reading. All identified documentation gaps closed (LinkedRE, Validation, public API, cross-linking, overviews, ActionIR lowering, per-spec walkthroughs).
- **Phase 7**: Self-hosted `spec.spec` grammar — LinkedSpec parses its own `.spec` language through the DSL itself. `spec.spec` compiles at `language_agnostic_ready_ratio == 1.0000` with regression coverage; it is the required change surface for `.spec` language evolution.

The Method-like DSL migration track is also complete: all 20 shipped specs at zero compatibility-surface rules, 100+ helpers across 10 families regression-locked, compat alias retirement finished (8 aliases removed), and fluent/block equivalence verified.

## Backbone items

Three backbone items tracked major structural modernization — all done:

1. Declarative bootstrap grammar registry replacing positional bootstrap coupling (done)
2. Staged `spec_entry()` compiler pipeline around RuleIR and explicit planning/validation phases (done)
3. Structured ActionIR/rewrite/lowering pipeline replacing ad hoc helper regex-chain rewriting (done)

## Ongoing

- **Documentation and book sync** — the book is kept aligned with the codebase as features land and surfaces evolve.
- **Lifecycle-family audit** — verified complete (2026-06-14). All 7 lifecycle markers (`I`, `LS`, `LE`, `E`, `EX`, `IT`, `LX`) have full semicolon-light structured authoring coverage. No lifecycle-specific semantic gaps found.

## What this means for readers

- Some older historical names appear in repo history and older notes. The active code path uses the current vocabulary.
- The current public and architectural explanations in this book prefer the active surfaces, not the oldest historical vocabulary.
- For the most current implementation status, the repo's `ROADMAP_V2.md` and `ARCHITECTURE_STATE.md` remain the fastest-changing references. This book absorbs that understanding over time in a more stable, explanatory form.

The project is healthy, actively maintained, and moving in a clear direction. Each phase leaves the codebase in a more explainable, more trustworthy state than it found it.
