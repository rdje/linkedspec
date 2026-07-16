---
id: and-or-edge-default-correction
title: Future design correction: AND rules should default bare entries to blind-calls; OR rules should default bare entries to action-edges
answers:
  - "should AND rules default to blind-calls"
  - "should OR rules default to action-edges"
  - "what does bare entry mean in an AND rule"
  - "what does bare entry mean in an OR rule"
  - "what owns the AND OR edge default correction"
  - "is first rule as top parked for future design"
  - "should OR rules intrinsically seek"
  - "should AND rules intrinsically consume"
  - "should parse_mode remain a public global override"
date: 2026-07-09
status: proposed
tags: [dsl, grammar, edges, blind-call, action-edge, and-rule, or-rule, FUTURE-PARITY-BACKLOG]
evidence: "Director clarification on 2026-07-09 supersedes the earlier brainstorm that action-edge markers might be optional in AND rules. The corrected future design direction is mode-sensitive: AND rules (`:&`, `::&`, `:AND`, `::AND`, and variants) should default bare entries such as `entry { ... }` to blind-call sequence semantics equivalent to `=> entry { ... }`; OR/default rules should default bare entries to action-edge regex-dispatch semantics equivalent to `-> entry { ... }`. Explicit `=>` remains the blind-call marker and explicit `-> entry[k]` remains action-edge dispatch through regex slot k. The design is parked under FUTURE-PARITY-BACKLOG.9.1 before any parser/runtime change."
reverify: "rg -n 'FUTURE-PARITY-BACKLOG\\.9|AND rules should default|OR/default rules should default|blind-call sequence' docs/tasks/FUTURE-PARITY-BACKLOG.md docs/TASK_TREE.md ROADMAP.md ROADMAP_V2.md docs/knowledge/and-or-edge-default-correction.md"
---

This is a future language-semantics correction, not current implementation
behavior.

The intended design direction is now:

- In AND rules, a bare body entry such as `entry { ... }` should mean a blind-call
  sequence entry, equivalent to `=> entry { ... }`.
- In OR/default rules, a bare body entry such as `entry { ... }` should mean an
  action-edge, equivalent to `-> entry { ... }`.
- Explicit `=>` still means blind-call.
- Explicit `-> entry[k]` still means action-edge dispatch using regex slot `k`
  from `entry`, with `entry` equivalent to `entry[0]`.
- `.push` / `.return(...)` continuations keep their existing child-return
  interpretation after the selected child is called.

Design caution: blind-call should mean the parent does not preselect by the
child rule's regex. A normal child call still runs the child rule's own parser
semantics unless the future design deliberately defines a separate bypass.

Related design questions are parked with the same leaf: whether action-edges
should remain legal but explicit in AND rules, whether blind-calls should remain
legal but explicit in OR rules, whether the first rule can replace `::` as the
top marker, and whether OR-rule pipe sugar is worth adding despite possible
confusion with grouped action-edge targets.

The 2026-07-16 cursor-ownership audit extends this direction: a caller-global
`parse_mode` rewrites every nested rule and has already produced uncovered
default-AND parity drift. The audit recommends intrinsic OR/default seek and AND
consume behavior with no public/global override, while retaining low-level
seek/consume matcher primitives. The design decision still must settle whether
an AND blind call imposes contiguous entry on an OR child or the called child
keeps its own intrinsic mode.

Related task: [[FUTURE-PARITY-BACKLOG]] leaf `.9.1`; audit:
[[and-or-cursor-ownership-audit]].
