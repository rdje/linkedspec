# 0037 - Dynamic parser construction and execution are selectively observable

- Date: 2026-07-15
- Status: accepted direction; implementation pending
- Tags: architecture, trace, observability, compiler, runtime, parser, staged-parsing, formats, portability

## Context

The post-parity structured-text program will construct parsers dynamically from composed `.spec` graphs and use
them immediately on documents. Correct final output alone is not enough to diagnose a large grammar, staged parse
graph, cache decision, recovery path, or runtime branch. Users need to see whether the parser was constructed as
intended and exactly how it processed a document.

LinkedSpec already has a variant-neutral trace contract with ordered `none`, `low`, `medium`, `high`, `full`, and
`debug` levels, default quietness, structured events, and stdout/routed/mirrored sinks. Perl and Rust have broad
compile/runtime coverage; Dart and Julia propagate a caller-owned emitter through their native frontend,
compiler, function/staged, and runtime paths; Lua currently has runtime coverage and retains full frontend/
compiler/function/staged propagation under `LUA-BACKEND-PARITY.5.3`. The existing public contract does not yet
define rule-specific filtering, and the trace book contained one stale pre-full-pipeline Dart status section next
to its current completed status.

## Decision

1. **Observability is a format-readiness contract.** No dynamically constructed format parser is complete unless
   both construction/compilation and document execution are traceable through the normal native API.
2. **Keep one ordered level model.** Canonical levels remain `none`, `low`, `medium`, `high`, `full`, and `debug`,
   with documented aliases such as `quiet`, `med`, and `verbose`. `off` is an accepted human-facing alias for
   `none` when the future neutral control contract is implemented across every current backend; this planning
   decision does not change current CLI/API parsing.
3. **Trace parser construction end to end.** Events must cover spec resolution/loading, import graph identity,
   source parsing, validation, function and staged-job projection, staged resolve/load/compile/execute/stitch,
   contract resolution, dependency planning, cache fingerprint and hit/miss decisions, and compiled rule/plan
   identity. Failures retain their typed diagnostic classification and attributed source location.
4. **Trace runtime behavior end to end.** Events must cover top selection, rule entry/exit, regex/token decisions,
   child dispatch, control-flow branches, cursor and capture/mark transitions, AST/value emission, recovery,
   diagnostics, and final result boundaries where those mechanisms apply.
5. **Add exact selective focus.** A trace configuration may carry an ordered exact rule-label allowlist. Global
   pipeline scopes remain visible; rule-owned events are emitted only for selected labels; a selected rule's
   dispatch decisions remain visible even when the callee is filtered out. Filtering changes emission only—it
   must never skip compilation, execution, validation, recovery, or diagnostics. Multiple selected rules compose
   as a union. Unknown labels diagnose configuration before parser work begins. Later function/job selectors may
   extend the same typed selector model but are not silently implied by v1 rule filtering.
6. **Correlate what was built with what ran.** Structured events carry stable phase/topic, spec-graph/cache
   identity, rule label where applicable, source/span identity where available, nesting/correlation identity, and
   input position where relevant. Backend-native detail may accompany, but not replace, the portable fields.
7. **Bound diagnostic payloads.** High/full/debug may expose progressively richer values and dumps, but values,
   source excerpts, and collections use explicit size limits and redaction controls so tracing is safe on large or
   adversarial documents.
8. **Prove non-interference and parity.** Shared fixtures compare traced and untraced parsed/compiled state,
   runtime values/ASTs, diagnostics, and cache identity; prove exact rule filtering and deterministic event order;
   and run on Perl, Rust, Dart, Julia, Lua, and LuaJIT before the format-readiness leaf closes.

## Consequences

- `FUTURE-PARITY-BACKLOG.18.2` owns this planning decision. The executable neutral contract and cross-backend
  harness are `STRUCTURED-TEXT-FORMAT-PROGRAM.2.7`, after full current-backend parity.
- Lua's already-owned `.5.3` full-pipeline work remains part of current parity and must finish before the format
  program starts. This decision neither delays nor replaces `.5.3`.
- The prior `TRACE-OBSERVABILITY` tree remains historically complete for its accepted contract. Rule filtering,
  bounded payload policy, construction/runtime correlation, and the dynamic-format readiness proof are additive
  future requirements rather than retroactive claims.
- The stale Dart runtime-only section is removed from the mdBook; Dart's completed full-pipeline status remains
  the canonical public record.
- Default behavior remains quiet, and this planning slice changes no parser, compiler, runtime, CLI, or trace
  implementation.

## Links

- Parent format decision: ADR `0034`
- User-observable parity: ADR `0023`
- Canonical primary CLI trace: ADR `0024`
- Existing trace owner: `docs/tasks/TRACE-OBSERVABILITY.md`
- Planning owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` `.18.2`
- Execution owner: `docs/tasks/STRUCTURED-TEXT-FORMAT-PROGRAM.md` `.2.7`
