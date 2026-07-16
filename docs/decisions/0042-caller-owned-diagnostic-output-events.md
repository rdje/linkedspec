# 0042 - Diagnostic output uses caller-owned typed events with a quiet default

- Date: 2026-07-16
- Status: accepted; backend rollout pending
- Tags: architecture, diagnostics, helpers, embedding, generated-source, cli, portability, cross-variant-parity

## Context

`print`, `say`, and `print_each` are portable `.spec` helpers, but the five current engines inherited four
different mechanisms. Perl lowers to host output and reevaluates `print_each` decoration inside its loop; Rust
writes directly to stderr; Dart evaluates and discards; Julia folds messages into native trace; Lua exposes a
per-parse typed callback. These differences also affect arity, event grouping, Unicode, sink failure, and
interaction with `exit_now`.

ADR `0022` makes in-memory embedding primary. ADR `0023` requires user-observable parity. ADR `0024` deliberately
keeps the deterministic primary-command phase trace separate from rich native events, and ADR `0028` defines the
portable scalar-to-text spellings without deciding how a diagnostic helper treats non-scalar fragments.

## Decision

1. **One executable contract is authoritative.** `capability_conformance/diagnostic_output_contract.json` is the
   backend-neutral `linkedspec-diagnostic-output-v1` semantic fixture. It is adopted before any backend is admitted
   against it.
2. **Arity is exact and precedes evaluation.** `print` and `say` accept one or more positional arguments.
   `print_each` accepts exactly two or three positional arguments: array target, prefix, and optional suffix. An
   arity failure uses `helper_arity_mismatch` fields and evaluates no argument.
3. **Valid calls evaluate eagerly once.** Every authored argument is evaluated exactly once from left to right
   before message formation or sink delivery. `print_each` therefore evaluates target, prefix, and optional suffix
   once per call, not once per item.
4. **Diagnostic fragments have an explicit typed rendering.** Strings are unchanged; booleans are `1`/`0`; finite
   numbers use ADR `0028`'s shortest stable decimal text; and null, array, harray, and codeblock values render as an
   empty fragment. This empty-fragment rule is diagnostic-specific: it does not change `cat`, where a non-text
   fragment makes the complete result null. Non-finite numbers remain outside the portable source contract.
5. **Grouping and text are exact.** `print` delivers one event containing the concatenated fragments. `say`
   delivers one event with exactly one trailing `\n`. `print_each` requires an array value, emits one event per item
   in array order, and forms each message as `prefix + item + suffix`; the omitted suffix is empty. An empty array
   or wrong-kind target emits no event after the call's arguments have been evaluated.
6. **Events are typed, parse-scoped, and structural-result-neutral.** The native event type is
   `RuntimeDiagnosticOutputEvent` with exactly `helper_name`, current `rule_label`, and Unicode `message` data.
   Each helper expression returns null. Events never enter the rule accumulator, direct parse value, or parse
   output.
7. **Delivery belongs to the caller.** Native execution accepts an optional sink per parser invocation. With no
   sink, execution is quiet but evaluation and structural results are unchanged. With a sink, callbacks are
   synchronous and ordered. A caller exception/failure propagates unchanged, aborts the current parse immediately,
   and prevents later items or statements from executing. No backend-global sink or implicit host stdout/stderr
   route is part of the contract.
8. **Termination remains immediate.** A diagnostic event before `exit_now(status)` is delivered; `exit_now` then
   propagates its typed status immediately, and no later helper argument or event is evaluated. Diagnostic helpers
   do not turn `exit_now` into host-process output or host `exit` coupling.
9. **Generated APIs propagate the native capability.** Every available generated execution entrypoint accepts an
   equivalent per-invocation sink and preserves the same result, event, failure, and termination semantics. Host
   callback types and option names may remain idiomatic under ADR `0022`.
10. **The primary CLI stays quiet and phase-only.** Primary commands install no rich diagnostic sink. Successful
    diagnostic-helper execution therefore writes only the canonical parse JSON plus newline and no stderr.
    Explicit primary trace remains exactly ADR `0024`'s phase protocol; rich diagnostic events never enter it and
    no diagnostic-output-specific CLI option is added.

## Consequences

- The Lua event design is useful prior art, but the neutral fixture—not Lua source—is the cross-backend authority.
- Perl, Rust, Dart, and Julia must replace host output, stderr, discard, and trace coupling with a parse-scoped
  event seam. Lua must prove exact fixture admission and repair only measured residuals.
- Callback failure is deliberately observable native behavior and cannot be swallowed into a null parser value or
  rewritten as a backend-specific parser diagnostic.
- Programs that need durable output choose and own their sink. Portable `.spec` execution itself remains quiet,
  deterministic, Unicode-preserving, and structurally pure with respect to diagnostic messages.

## Links

- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.5.1.1-.9`)
- Exact fixture: `capability_conformance/diagnostic_output_contract.json`
- Native embedding and parity: ADR `0022`, ADR `0023`
- Separate primary trace: ADR `0024`; strict primary UTF-8: ADR `0025`
- Scalar text spellings: ADR `0028`
- Audit fact: `docs/knowledge/cross-backend-diagnostic-output-drift.md`
