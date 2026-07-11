---
id: julia-governed-capture-mark-parity
title: Julia executes the governed anonymous and named capture/mark fixtures exactly
answers:
  - "does Julia pass the exhaustive anonymous capture fixture"
  - "does Julia pass the exhaustive named mark fixture"
  - "how does Julia store LinkedSpec marks"
  - "are Julia capture positions and lengths character based"
  - "does Julia preserve bare mark names symbolically"
  - "does Julia AND blind-call return ordered child values implicitly"
date: 2026-07-10
status: current
tags: [julia, capture, marks, blind-call, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.3; exact governed, implicit-result, rule-local-mark, and multibyte projection locks in julia/test/runtests.jl; tools/run_julia_local.sh passes 1,028 package assertions, primary CLI conformance, and 99/99 corpus."
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

The real fixture wrapper also proves implicit blind-call collection: a non-repeated `AND` blind-call parent with no
explicit return surfaces its ordered successful child values. An independent two-child regression locks that
contract separately from the capture family.
