---
id: rule-local-cursor-ownership-decision
title: "Every rule owns its cursor semantics; parent modes never propagate to children"
answers:
  - "does an AND parent force an OR child to consume"
  - "does an OR parent force an AND child to seek"
  - "does parent rule mode propagate to child rules"
  - "who owns cursor semantics across blind calls"
  - "what did the director decide about child parse modes"
date: 2026-08-09
status: implemented and recurring/public admitted at 8 complete / 0 pending; transaction-frame extension pending under .14.3
tags: [dsl, runtime, cursor, parse-mode, and-rule, or-rule, blind-call, composition, FUTURE-PARITY-BACKLOG]
evidence: "Director confirmation on 2026-07-17: the mode of a parent OR/AND rule shall not propagate to or override child OR/AND modes. ADR 0044 and FUTURE-PARITY-BACKLOG.9.1.1-.9.1.9 implemented and admitted the rule-local cursor contract on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT. The recurring/public ledger is 74 files / 8 complete + 0 pending / 60 mutations. FUTURE-PARITY-BACKLOG.14.3.0 confirms this intrinsic rule-policy decision remains unchanged while future transaction tokens and same-label recursive marks gain invocation identity."
reverify: "rg -n 'FUTURE-PARITY-BACKLOG\\.9\\.1\\.1|parent.*never.*propagat|child.*intrinsic.*mode|rule-local cursor' docs/tasks/FUTURE-PARITY-BACKLOG.md README.md ROADMAP.md ROADMAP_V2.md ARCHITECTURE_STATE.md docs/knowledge/rule-local-cursor-ownership-decision.md docs/linkedspec-book/src"
---

Each authored rule owns its own cursor discipline:

- OR/default-family rules are intrinsically seek.
- AND-family rules are intrinsically consume.
- A parent's rule family controls the parent's composition and local matching;
  it never changes the cursor semantics of a child rule.
- An OR child called by an AND parent remains seek.
- An AND child called by an OR parent remains consume.

This ownership boundary applies whenever one rule invokes another, including
blind calls, action-edge dispatch, explicit `call(...)`, and recursion. The same
child rule therefore means the same thing in every call context.

Contiguous child entry is not inferred from the parent's AND mode. If a future
real grammar requires a distinct strict-entry operation, it needs an explicit
language construct with its own design and tests rather than contextual mode
propagation.

The decision also reinforces the audit conclusion that callers cannot override
rule semantics globally. ADR `0044` / `FUTURE-PARITY-BACKLOG.9.1.1-.9.1.9`
owns the ratified bare/explicit edge grammar, API/CLI migration, descriptor
shape, generated-source v2, diagnostics, conformance, and completed six-runtime
admission. The recurring/public ledger is 74 files / 8 complete + 0 pending /
60 mutations.

`FUTURE-PARITY-BACKLOG.14.3` does not reopen intrinsic seek/consume ownership.
It adds invocation identity for bounded transaction tokens and same-label
recursive mark frames, which is a separate state-lifetime axis.

Related: [[and-or-cursor-ownership-audit]],
[[and-or-edge-default-correction]], and [[FUTURE-PARITY-BACKLOG]].
