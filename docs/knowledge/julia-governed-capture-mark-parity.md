---
id: julia-governed-capture-mark-parity
title: Julia executes governed capture and the complete named-mark contract exactly
answers:
  - "does Julia pass the exhaustive anonymous capture fixture"
  - "does Julia pass the exhaustive named mark fixture"
  - "does Julia implement mark entry start and mark match end"
  - "does Julia implement mark line mark col and clear mark"
  - "why are Julia complete named mark names staged outside the shared 239 name inventory"
  - "how does Julia store LinkedSpec marks"
  - "are Julia capture positions and lengths character based"
  - "does Julia preserve bare mark names symbolically"
  - "does Julia AND blind-call return ordered child values implicitly"
date: 2026-07-10
status: current
tags: [julia, capture, marks, blind-call, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.3 plus FUTURE-PARITY-BACKLOG.17.3; exact governed, implicit-result, rule-local-mark, multibyte-projection, and complete seven-helper locks in julia/test/runtests.jl and julia/test/complete_named_mark_contract_test.jl; tools/run_julia_local.sh plus the shared CLI runner pass 1,414 package assertions, 61x2 CLI, and 105/105 corpus."
reverify: "LINKEDSPEC_JULIA_CMD=/opt/homebrew/bin/julia bash tools/run_julia_local.sh"
---

# Julia Governed Capture / Mark Parity

`FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.3` closes Julia execution of the governed anonymous and named capture sources.
The runtime stores capture anchors and rule-local named marks as Julia string code-unit offsets, the unit required
for safe slicing, while public positions and captured lengths are projected in Unicode characters. Advancing
helpers update an anchor only after validating the requested span.

Bare mark arguments such as `mark_here(origin)` are symbolic names read from the typed argument, not scalar value
lookups. The runtime covers stable and advancing anonymous reads, anonymous-to-named bridging and reset, current
and input-boundary marks, mark copy/existence/position, stable and advancing named reads, and two-mark reads.

`FUTURE-PARITY-BACKLOG.17.3` adds the four entry/local edge writers, `mark_line`, `mark_col`, and `clear_mark` over
that same rule-local code-unit store. Missing positions and locations remain `undef`; line and column projections
are 1-based Unicode-character locations. Native execution, generated-plan execution, emitted-state
reconstruction, and the primary CLI return the exact neutral parent/child fixture.

The seven names live in `COMPLETE_NAMED_MARK_ACTION_IR_CALL_NAMES` and participate in Julia's known-call boundary,
but remain disjoint from the legacy shared 239-name set. This is deliberate rollout staging: Lua `.17.4` now
consumes the unchanged contract on both ABIs; `.17.5` admits all seven into the shared inventory and hardens the
checker against another symmetric omission.

The real fixture wrapper also proves implicit blind-call collection: a non-repeated `AND` blind-call parent with no
explicit return surfaces its ordered successful child values. An independent two-child regression locks that
contract separately from the capture family.
