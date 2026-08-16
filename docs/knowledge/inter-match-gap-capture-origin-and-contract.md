---
id: inter-match-gap-capture-origin-and-contract
title: Historical super split is automatic inter-match gap capture on externally targeted action edges
answers:
  - "what did super split originally mean"
  - "is super split related to blind calls"
  - "how does move_pos capture text between action edge matches"
  - "which rule owns regexes referenced by an action edge"
  - "does a regex immediately before an action edge trigger its code block"
  - "how do Document[0] Document[1] and Document[2] action edges select regexes"
  - "does a target rule keep its lifecycle code during gap capture"
  - "what is the accepted future replacement name for super split"
  - "what does capture_gaps mean and is it implemented"
  - "does legacy gap capture include prefix and tail text"
  - "what is the accepted direction for avoiding numeric regex slot indexes"
  - "what is the ratified named regex declaration syntax"
  - "are spaces around equals significant in name equals regex declarations"
  - "is name equals regex implemented yet"
  - "does move_pos currently mean the same thing on every backend"
date: 2026-08-16
status: verified historical fact; all six private runtime routes admitted; recurring/public completion pending
tags: [capture, segmentation, super-split, move-pos, or-rule, action-edge, source-span, perl, portability]
evidence: "Imported baseline cf25bd37 perl/LinkedSpec.pm Split-Like/MOVE_POS/spec_gdata/REP_ACODE and specs/ebnf.spec; documentation drift 8588b07b and 300e6950; current RuleIR relabel/reidx projection; 2026-07-17 live Top::OR to Document[0..2] probe; five-backend marker-scope code audit. INTER-MATCH-GAP-CAPTURE.2-.6 privately admit Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT through exact native/carrier/emitted/primary roles. INTER-MATCH-GAP-CAPTURE.7.1 makes recurring proof current at 8/1/61; public no-drift remains pending for .7.2. ADR 0045."
reverify: "git show cf25bd37:perl/LinkedSpec.pm | rg -n -C 8 'Split-Like Code|MOVE_POS|spec_gdata|REP_ACODE'"
---

# Historical super split and the accepted contract

“Super split” originally names automatic **inter-match gap capture** in a repeated OR/default rule
whose alternatives are action edges. It is not a blind-call mode.

## Target ownership

An action edge names the rule and zero-based regex slot that supply its match. `-> Document` is the
default slot, while `-> Document[1]` and `-> Document[2]` select later slots. `Document` declares those
regexes and retains its own lifecycle/action code. The enclosing rule owns repeated selection and gap
orchestration.

A regex line immediately before `-> Document { ... }` does not trigger that edge. Later examples used
that visually misleading shape, but both the imported baseline and current RuleIR store the action
target as `relabel` plus `reidx` and assemble the enclosing matcher from the referenced target slots.

## Baseline Perl algorithm

The imported Perl baseline performs this sequence in its repeated action handler:

1. initialize `$IPOS` from the rule-entry cursor;
2. select the next action alternative using the target rule/slot regex table;
3. set `$LMATCH` and `$LSPOS` for the selected match;
4. make the exact text from `$IPOS` to the match's left edge available through `$CAPTURE`;
5. execute the selected action, including an optional `call(Target)` that runs target lifecycle code;
6. run the `@move_pos` local-end lowering, `$IPOS = pos $$STRING`, so a successful target call that
   advanced beyond its entry match also advances the next gap boundary;
7. repeat.

The active baseline did not force one AST/result shape. A commented line experimented with automatic
array emission, while active actions chose whether to store raw `$CAPTURE`, trim and conditionally
store it, or combine it with the target lifecycle result.

A current live probe with `Top::OR @move_pos`, three edges to `Document[0..2]`, and lifecycle code in
`Document` returned exact `[gap, lifecycle_result]` pairs. It exposed the prefix before the first
match and the gaps between matches. It did not automatically expose the final tail because there was
no next match.

## Accepted future direction

ADR `0045` reserves **inter-match gap capture** as the formal concept, **lossless segmentation** as the broader
model, and `@capture_gaps` as the neutral directive. Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT are privately
admitted across their native/generated/emitted/primary roles. The executable contract fixes prefix, tail, empty-span,
failure/backtracking, recursion, typed-span, diagnostics, and compatibility policy.

The new representation may replace implicit `$IPOS` arithmetic with invocation-local typed span
state, but it must preserve external target-rule ownership, target lifecycle behavior, and automatic
post-action rolling. The generalized manual capture/mark helpers are related source-boundary tools;
they do not redefine the historical feature.

Current marker-member execution is not portable. Perl's anonymous spellings retain the original
rule-level rolling behavior, Lua/LuaJIT later attach them to preceding regex slots, and Rust/Dart/Julia
do not execute parsed marker members in their native runtime paths. This does not alter the accepted
`@capture_gaps` meaning; it makes legacy reconciliation an explicit contract task. See
[[split-marker-cross-backend-semantics]] for the exact matrix.

The director also accepts stable named regex-slot identity as the direction for replacing positional-
only coupling. Numeric/unindexed forms remain compatible. The admitted runtimes declare `header=/.../` inside the
target rule and select it as `Document[header]`; horizontal whitespace around `=` is insignificant. Perl, Rust,
and Dart expose that syntax through their admitted private routes. Julia and shared Lua also implement and
privately admit the syntax, native `entry_slot()`, normalized reconstruction, compatible descriptors, generated-v2
execution, emitted proof, and primary parity. Recurring and portable/public support remain pending.

The selector namespace is deliberately bracket-only: `Document[1]` is positional compatibility and
`Document[header]` is stable identity. They may lower to the same typed slot target, but source provenance is
retained because declaration reordering changes the numeric form and not the named form. `Document.1` and
`Document.header` are not aliases; dot already owns fluent rule behavior. Behavior-free
`FUTURE-PARITY-BACKLOG.14.5.0` freezes the clean handoff to `INTER-MATCH-GAP-CAPTURE.1-.7`, the sole
syntax/lifecycle/compatibility/backend admission owner. Typed-source composition resumes only afterward in
`.14.5.1`.

## Links

- Decision: `docs/decisions/0045-inter-match-gap-capture.md`
- Task owner: `docs/tasks/INTER-MATCH-GAP-CAPTURE.md`
- Edge syntax: `docs/knowledge/spec-edge-syntax-contract.md`
- Current marker divergence: [[split-marker-cross-backend-semantics]]
- Cross-tree handoff and selector namespaces: [[lossless-gap-cross-tree-handoff]]
- Recurring/public closeout plan and stale-guard finding: [[inter-match-gap-recurring-public-closeout-plan]]
