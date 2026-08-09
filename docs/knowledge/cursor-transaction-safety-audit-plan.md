---
id: cursor-transaction-safety-audit-plan
title: Cursor transactions require invocation frames, opaque generations, a closed effect model, and explicit progress diagnostics
answers:
  - "what is the current save_cursor restore_cursor implementation"
  - "can save_cursor and restore_cursor implement cursor transactions"
  - "are named marks invocation local during same label recursion"
  - "why do cursor transactions need invocation ids and generations"
  - "what state can a cursor transaction roll back"
  - "how will recognition only transaction effects be classified"
  - "what is the current nonprogress recursion behavior"
  - "what is the current nullable repetition behavior"
  - "who owns reversed span versus transaction diagnostics"
  - "has LinkedSpec selected checkpoint transaction syntax"
  - "what is the FUTURE PARITY BACKLOG 14.3 implementation split"
date: 2026-08-09
status: behavior-free audit frozen; implementation pending under FUTURE-PARITY-BACKLOG.14.3.1-.14.3.8
tags: [architecture, cursor, transactions, marks, invocation, progress, effects, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.3.0 retrieves ADR 0056 and uses LinkedSpec::call_spec_handler_subst, LinkedSpec::Get, runtime_ctx_ref, trace output, and return_descriptor before source inspection. save_cursor lowers to cursor_checkpoint_compatibility and restore_cursor pops one execution-context cursor_stack entry. Same-label recursive input aa returns mark_pos(shared)=2, proving the child overwrites the parent bucket. Direct no-consume recursion returns undef, emits the rule_handler_forward_progress cutoff, and leaves last_error null. OR{,3} over /x*/ returns one Z and stops without a diagnostic. Backend source confirms rule-label mark maps, execution-context cursor stacks, saved child match/capture registers, and no closed ActionIR effect taxonomy. Git blame proves the stale reversed-span parent phrase predates the .14.2.0 diagnostic-owner amendment."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(\"Top\", q{save_cursor(); restore_cursor()})' && rg -n 'marks|markBuckets|mark_buckets|cursor_stack|cursorStack|activeRuleEntries|active_rule_entries|recursion_active' perl/LinkedSpec/SpecEntry.pm rust/linkedspec-runtime/src/runtime.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua && rg -n 'Cursor transactions|transaction-safety implementation boundary|FUTURE-PARITY-BACKLOG[.]14[.]3' docs/decisions/0056-typed-source-location-and-cursor-algebra.md docs/tasks/FUTURE-PARITY-BACKLOG.md"
---

# Cursor transaction safety audit and implementation plan

## Current mechanisms are compatibility state, not transactions

`save_cursor()` and `restore_cursor()` are cursor-only LIFO compatibility controls. Perl stores the stack in
`$info->{cursor_stack}`; Rust, Dart, Julia, and Lua keep the equivalent list on one execution context. The entries
contain no source authority, rule owner, invocation identity, generation, transaction identity, or terminal state.
They cannot diagnose token escape, reuse, cross-invocation use, or cross-source restoration, and they do not
snapshot anonymous boundaries or named marks. They remain supported but separate.

Current named marks are isolated by **rule label**, not by invocation. That correctly protects a parent `Top` mark
from a differently labelled child `Child`, which is what the complete named-mark v1 fixture proves. Recursive
re-entry of `Top` uses the same `Top` bucket: on input `aa`, a child `mark_here(shared)` overwrites the parent and the
parent reads position `2`. This is current measured compatibility behavior, not an invocation-local guarantee.

Immediate entry/local-match state and the anonymous capture boundary are already saved and restored around child
calls in every native runtime. The missing unit is a real invocation frame for mark lifetime, token ownership, and
generation checks.

## Current progress protection terminates but does not diagnose portably

Perl and all native backends guard active recursion with a key derived from rule/entry identity and cursor. Re-entry
at the same key returns no match/`undef`; Perl emits a trace decision but leaves `runtime_ctx_ref->{last_error}` null.
The behavior prevents stack overflow but is not the neutral `source_location_nonprogress_direct_recursion` or
`source_location_nonprogress_mutual_recursion` diagnostic.

Current repeated matching also stops on unchanged cursor state after retaining one accepted zero-width result. The
exact `Top::OR{,3}` plus `/x*/` probe returns `["Z"]` on empty input. V1 retains zero-width success as a value when
no progress obligation exists, but repetition and recursive edges must reject it with structured context.

## Frozen v1 authority and effect boundary

Each parse execution allocates monotonic, non-reused invocation ids. Each entered rule owns an invocation frame and
generation. One opaque transaction token binds source authority, rule identity, invocation id/generation,
transaction id, and originating edge/job. It snapshots only cursor, anonymous boundary, and that invocation's
named marks. One transaction may be active per invocation. Commit or rollback is single-use and invalidates it;
nesting, escape, aggregate/function storage, caller unwind, cross-rule/source use, retry, and automatic alternative
search are rejected.

The compiler currently emits exact canonical ActionIR nodes and contract ids, but no complete effect class.
Semantic introspection has illustrative effects for only `trim`, `match_text`, and `return`; it cannot authorize the
whole current language. The neutral transaction contract must therefore define a closed, independently checked
classification and transitive call-graph rule. Pure construction/reads/control, staged return, once-only rule
recognition, and typed cursor/boundary/invocation-mark writes are the only v1 candidates. Unknown/RAW_PERL,
callable/user-function invocation, binding/aggregate/AST mutation, compatibility cursor-stack mutation, output or
authored diagnostics, exit, parser/registry/external work, and host effects fail closed. Static proof is primary;
a runtime barrier catches dynamic violations.

V1 proves cursor advance only and selects no authored decreasing-measure API. Exact transaction spelling and how a
committed staged child result becomes visible are ratified behavior-free in `.14.3.1.0`; the architecture names are
still not promised helpers. Any selected names must remain visibly distinct from `save_cursor`/`restore_cursor` and
must preserve the explicit meaning of `call(Rule)`.

## Ownership and rollout

The parent task's `reversed-span` phrase was older than the `.14.2.0` ownership amendment. The admitted
`source_location_reversed_span` diagnostic remains owned by `.14.2`; transactions reuse it when validating typed
state. `.14.3` owns mark lifetime, token validity/lifecycle, effect-before-commit, cross-rule/source restoration,
nullable repetition, and direct/mutual recursion. `.14.7` retains staged-dispatch cycles.

Neutral syntax/effects and executable conformance precede backend code. Perl, Rust, Dart, Julia, and one shared Lua
implementation are then admitted independently; the Lua consumer runs separately on PUC Lua and LuaJIT. A final
six-runtime recurring route promotes only transaction safety, and no-change `.14.3.8` closes the parent before
recursive observation `.14.4`.

Related: [[typed-source-location-cursor-algebra-direction]], [[complete-named-mark-perl-rust-parity]],
[[top-rule-recursion-forward-progress-guard]], and [[rule-local-cursor-ownership-decision]].
