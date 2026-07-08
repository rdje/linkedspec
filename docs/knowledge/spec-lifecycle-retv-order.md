---
id: spec-lifecycle-retv-order
title: "Lifecycle markers execute in fixed order and child returns flow through retv; explicit return is the portable rule value channel"
answers:
  - "what is the lifecycle execution order"
  - "how does retv work in lifecycle blocks"
  - "when does LE see a child return value"
  - "where should a rule final return be assembled"
  - "how do I document lifecycle order and retv"
date: 2026-07-08
status: confirmed
tags: [spec-language, lifecycle, retv, runtime-semantics, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.7 promotes the durable lifecycle/retv retrieval point from runtime-semantics.md section 3 and action-and-lifecycle-placement.md. The existing terse-lifecycle-value-drop-return-channel card records the explicit-return caveat; rust-retv-propagation records Rust runtime parity details."
---

# Spec Lifecycle / `retv` Order

**Confirmed 2026-07-08 (`SPEC-LANG-REFERENCE.7`).** Lifecycle markers have a
fixed execution order:

```text
I -> [LS -> match -> LE -> IT] * N -> EX -> LX -> E
```

Practical contract:

- `I` runs once when the rule handler is entered.
- `LS` runs before each repeated match attempt.
- `LE` runs after each successful child match and can read that child return via
  `retv`.
- `IT` runs per completed repetition iteration.
- `EX` and `LX` run after repetition exits.
- `E` runs once at rule completion and is the usual finalization point.

`retv` is the "latest child return" channel used by parent actions and lifecycle
blocks. After an action edge or blind-call child dispatch, attached code can
read the child result through `retv`; explicit `call(child)` can also assign or
return the child result directly.

Lifecycle blocks are statement blocks. A final helper call or assignment is not
a portable implicit return. Use explicit `return(expr)` when a lifecycle or
action block should produce the surrounding rule value.

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] (leaf `.7`)
- Book contract: `docs/linkedspec-book/src/appendix/runtime-semantics.md`
- Related: [[terse-lifecycle-value-drop-return-channel]], [[rust-retv-propagation]]
