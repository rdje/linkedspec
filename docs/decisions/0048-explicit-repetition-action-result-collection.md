# 0048 - Explicit repetition action returns are per-hit collection values

- Date: 2026-07-20
- Status: accepted; backend rollout pending
- Tags: architecture, grammar, repetition, or-rule, action-edge, lifecycle, result-shape, descriptor, generated-source, trace, parity

## Context

The duplicate-regex-slot rollout exposed a result-shape disagreement that was independent of slot identity. With
an action edge such as `{ return("A") }`, Perl returns one array element per accepted hit from explicit repetition
forms, while Rust, Dart, Julia, and Lua return the first scalar and stop the rule. `Rule::|` returns one scalar on
all five backends.

Toolbox and primary-adapter probes expanded the disagreement beyond bare `OR`. Perl returns `["A","B"]` for
two accepted hits under `OR`, `OR+`, bounded `OR`, `+`, and `*`, and `["A"]` for `?`; the four newer backends
return only `"A"`. Perl's generated `REP_ACODE` handler rewrites an action-edge return into the current iteration
value, completes the successful iteration, pushes that value into the rule collection, and continues within the
bound. Its `OR_ACODE` pipe handler returns directly.

Source audit found two independent causes in every newer backend:

1. the AST comments and public language reference call bare `OR` repeated choice, but `is_repetition` and
   `rep_min` exclude it, so native execution and generated-source v2 classify it with pipe as `or_acode`;
2. the modes that already enter repetition propagate an action-edge return through the same whole-rule return
   channel used by lifecycle blocks, so their first successful hit exits the rule.

The unadorned historical default handler is not part of this decision. Its current cross-backend action-return
shape is scalar and its broader handler semantics are not silently redefined by an explicit-repetition repair.

## Decision

### 1. Explicit repetition forms collect action-edge returns

The action-edge forms `*`, `+`, `?`, `OR`, `OR+`, and `OR{...}` use repeated-action collection semantics. An
explicit `return(value)` or fluent `.return(value)` in the selected action edge produces that successful
iteration's value. It does not terminate the surrounding repeated rule.

The rule's default result is a flat ordered collection with exactly one element for each successful iteration
that produces an explicit action return. Values retain their type and nesting: a returned array occupies one
outer element rather than being flattened, and an explicit undefined/null value remains one null element. Choice
priority, target/slot identity, captures, cursor movement, and authored iteration order are unchanged.

`Rule::|` remains non-repeating single choice. Its selected action-edge return is the direct scalar value, not a
one-element collection. Duplicate patterns still choose the first authored equal-start slot under ADR `0047`.

### 2. Bare `OR` is genuine repetition

`Rule:OR` has minimum one and no DSL-level maximum, equivalent in repetition bounds to `Rule:OR+` and
`Rule:OR{1,}`. This applies to action-edge and blind-call orchestration. Its AST/compiled metadata must report
repetition with `rep_min = 1`; native execution must continue after successful progress; and generated-source v2
must classify action and blind forms as `rep_acode` and `rep_bcode`, respectively.

Compact and bounded forms keep their existing bounds: `*` is zero-or-more, `+` is one-or-more, `?` is zero-or-one,
and `OR{N,M}` counts accepted hits. Zero permitted hits return an empty collection. Failure below the minimum
retains the reference undefined/null result. Existing forward-progress protection still terminates a successful
zero-width iteration.

### 3. Lifecycle returns retain whole-rule authority

This decision changes only action-edge return interpretation inside explicit repeated-action handlers. A return
from `I`, `LS`, `LE`, `LX`, `IT`, `EX`, or `E` remains a whole-rule return and may deliberately replace or end the
default collection result according to the existing lifecycle contract. Implementations must retain the source
context of a return rather than globally converting every return event into an iteration value.

The successful-hit lifecycle order and action-block control flow otherwise remain unchanged. In particular, a
backend repair must not skip the success lifecycle merely because the selected action produced an iteration
value, and it must not reinterpret child, helper, or lifecycle returns as extra collection elements.

### 4. Existing outward contracts are corrected, not widened

Descriptors use their existing mode/family/repetition/bound fields. Bare `OR` must project repeated choice with
minimum one; pipe must project non-repetition. No new mutable result-shape option or descriptor override is added.

Native trace must make every accepted hit observable through the existing rule/slot/iteration events, and direct
versus traced execution must return identical values. The neutral contract counts selected-hit events so a
first-hit early exit cannot masquerade as collection parity.

Generated artifacts remain `linkedspec-generated-source-v2` / format 2 with the existing ordered
`{label,family}` plan. The plan already has distinct `or_*` and `rep_*` families, and embedded compiled state
already owns action/lifecycle context, so no field or format bump is required. A stale newer-backend v2 artifact
whose bare `OR` row says `or_acode` or `or_bcode` fails exact family-plan validation and must be regenerated from
its `.spec`; existing explicit-repetition rows consume the corrected runtime semantics. This is a behavior repair,
not permission to accept an old family row under a new meaning.

### 5. One neutral artifact governs rollout

The executable contract created by `FUTURE-PARITY-BACKLOG.9.1.10.1` is authoritative. It covers every explicit
repetition spelling, pipe control, distinct and duplicate slots, block and fluent return forms, scalar/null/nested
values, zero and below-min cases, lifecycle overrides, a blind-choice classification control, descriptors,
generated plans, selected-slot trace, loaded/reconstructed/generated/emitted routes, primary commands, corpus,
both Lua ABIs, exact rollout inventory, and omission-sensitive mutations.

Rollout proceeds in dependency order: neutral plus Perl reference, Rust, Dart, Julia, PUC Lua and LuaJIT, one
recurring six-runtime admission, then public no-drift. No backend may claim parity from a primary-only fixture.

## Consequences

- Authors can use explicit repeated choice to collect one typed action result per accepted hit.
- Authors use pipe when they want exactly one selected scalar action result.
- Bare `OR` finally matches its existing public documentation and Perl descriptor/handler semantics.
- Backend runtimes must distinguish action-edge iteration results from lifecycle whole-rule returns.
- Existing bounds, forward progress, cursor ownership, regex-slot identity, and generated-source-v2 plan shape
  remain stable.
- Old newer-backend bare-`OR` generated artifacts fail safely at plan validation rather than silently retaining
  single-choice behavior.
- The unadorned default handler remains outside this scoped decision.

## Links

- Task owner: `docs/tasks/FUTURE-PARITY-BACKLOG.md` (`FUTURE-PARITY-BACKLOG.9.1.10-.9.1.10.7`)
- Existing gap: `docs/knowledge/explicit-or-action-result-shape-parity-gap.md`
- Rule-mode map: `docs/knowledge/spec-rule-mode-semantics-map.md`
- Existing collection shape: `docs/knowledge/blind-call-collection-shape.md`
- Cursor and family authority: ADR `0044`
- Duplicate slot identity: ADR `0047`
