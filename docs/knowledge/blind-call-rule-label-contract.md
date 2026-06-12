---
id: blind-call-rule-label-contract
title: Blind-call (=> child) is driven by the rule label, not the edge kind alone; :AND is the preferred sequential spelling
answers:
  - "how does blind-call work in linkedspec"
  - "what is the difference between => child and -> child"
  - "does bare rule: with => child mean ordered sequence"
  - "what rule label should I use for blind-call"
date: 2026-06-12
status: current
tags: [dsl, blind-call, rule-modes, frontend]
evidence: "ROADMAP_V2.md Deferred Future Note: 'blind-call should remain mode-driven by the rule label'; specs/spec.spec uses explicit rule labels for blind-call"
reverify: "grep -n 'blind.call.*mode.driven' ROADMAP_V2.md"
---

Blind-call (`=> child_rule`) dispatches to a child rule whose return value is consumed as
the current rule's match, rather than triggering an action edge (`->`). The critical contract:

- **The rule label drives the mode**, not the edge kind alone. `rule: :AND` with `=> child`
  means ordered sequence. Bare `rule:` with `=> child` must not silently make it mean
  ordered sequence just because the body is parser-step oriented.
- **`:AND` is the preferred sequential spelling** for blind-call.
- **Repeated-choice blind-call** (`rule:`, `:OR`, `:OR+`, `:+`, `:OR{...}`) is locked to
  the label-driven repeated-choice family — including the historical bare `rule:` shorthand.
- **Repeated blind-call loops guard against zero-progress** child success, so
  lower-bound-zero child rules do not send repeated parents into infinite loops.

The `ROADMAP_V2.md` Deferred Future Note calls this out explicitly as a contract to preserve.

Related: [[scanner-rule-family-architecture]], [[spec-spec-self-hosted-grammar]].
