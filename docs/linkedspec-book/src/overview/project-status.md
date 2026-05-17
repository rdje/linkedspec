# Project Status

LinkedSpec is an actively evolving system. The current direction is not “freeze everything exactly as it once was.” The direction is to preserve the strengths that make LinkedSpec useful while modernizing the runtime, compiler, diagnostics, and documentation.

## Completed phases

Phases 1–5 of the modernization roadmap are done:

- **Phase 1**: Thin facade + owner dispatch — `LinkedSpec.pm` is a 286-line lazy facade; 18 modules use uniform `OwnerDispatch`.
- **Phase 2**: DSL frontend hardening — rule-label parsing, inside-block rejection, extra-colon rejection, fluent-continuation recognition, `strict_syntax` mode, construct-recognition alignment with bootstrap grammar.
- **Phase 3**: Execution semantics — seek/consume parse modes documented; BACKTRACK/IBACKTRACK defined as local cursor-rewind, not systemic backtracking; forward-moving non-backtracking model stated.
- **Phase 4**: Capture/mark API — 163 contracts across 6 families verified, compat aliases documented, mark-helper reference complete.
- **Phase 5**: Runtime diagnostics — structured last_error is the single diagnostics channel; handler compile warnings routed through trace instead of stderr; eval minimized to one handler compilation; trace bridging from compile scopes into runtime handler scopes.

## Active work

- **Phase 6**: Documentation and adoption — the book you are reading. This phase is expanding project documentation so every user-facing surface, architecture decision, and workflow is clearly explained.

## Planned

- **Phase 7**: Self-hosted `spec.spec` grammar — LinkedSpec parsing its own `.spec` language through the DSL itself, closing the self-hosting loop.

## Backbone items

Three backbone items track major structural modernization:

1. Final descriptor naming and projection cleanup (done)
2. Blind-call / repeated-sequence eval elimination (done)
3. ActionIR `call` / `group` / `call_emitter` lowering modernization (active)

## What this means for readers

- Some older historical names appear in repo history and older notes. The active code path uses the current vocabulary.
- The current public and architectural explanations in this book prefer the active surfaces, not the oldest historical vocabulary.
- For the most current implementation status, the repo's `ROADMAP_V2.md` and `ARCHITECTURE_STATE.md` remain the fastest-changing references. This book absorbs that understanding over time in a more stable, explanatory form.

The project is healthy, actively maintained, and moving in a clear direction. Each phase leaves the codebase in a more explainable, more trustworthy state than it found it.
