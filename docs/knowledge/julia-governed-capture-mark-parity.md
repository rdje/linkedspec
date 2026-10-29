---
id: julia-governed-capture-mark-parity
title: Julia executes governed capture and the complete named-mark contract exactly
answers:
  - "does Julia pass the exhaustive anonymous capture fixture"
  - "does Julia pass the exhaustive named mark fixture"
  - "does Julia implement mark entry start and mark match end"
  - "does Julia implement mark line mark col and clear mark"
  - "are Julia complete named mark names in the shared 246 name inventory"
  - "how does Julia store LinkedSpec marks"
  - "are Julia capture positions and lengths character based"
  - "does Julia preserve bare mark names symbolically"
  - "does Julia AND blind-call return ordered child values implicitly"
date: 2026-07-10
status: bounded Julia47.4 named take repair focused-verified; safe Lua/writer49/selection/full admission separate
tags: [julia, capture, marks, blind-call, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.4.3 plus FUTURE-PARITY-BACKLOG.17.3; exact governed, implicit-result, rule-local-mark, multibyte-projection, and complete seven-helper locks in julia/test/runtests.jl and julia/test/complete_named_mark_contract_test.jl; tools/run_julia_local.sh plus the shared CLI runner pass 1,414 package assertions, 61x2 CLI, and 105/105 corpus."
reverify: "bash tools/run_julia_local.sh"
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

The seven names now live in `_SUPPORTED_ACTION_IR_CALL_NAMES`, while
`COMPLETE_NAMED_MARK_ACTION_IR_CALL_NAMES` remains an exact focused-family view. Lua `.17.4` consumes the
unchanged contract on both ABIs; `.17.5` admits all seven at 246 shared names and independently reverse-checks all
122 public Perl contracts so another symmetric omission fails.

The real fixture wrapper also proves implicit blind-call collection: a non-repeated `AND` blind-call parent with no
explicit return surfaces its ordered successful child values. An independent two-child regression locks that
contract separately from the capture family.

## September 11 — complete named-mark consumer read

Julia .1.34 reads all94 lines of the complete named-mark consumer. Its13 assertions
pass exact seven-name inventory, native, generated-plan, emitted-state JSON
reconstruction and inline primary-command results. This file does not independently
load an emitted module; that stronger role belongs to separate consumers. Exact
reading and replay: [[julia-contract-consumer-reading]].

## Julia repair47.4 (2026-10-29)

Named nullable endpoint guards already work. One-argument capture_take previously
dispatches anonymously; it now shares the existing named helper's name/typed span/
valid-only mark update paths. Zero-argument anonymous and available endpoints/
writers remain unchanged, no new state/frame/schema/helper/domain policy.
Independent15-source SDK/restored/plan/separate-process8healthy7RED ->15pass;
ordinary84pass21fail ->105pass. Named105/anonymous112/named Number-function-scope155/
complete marks13 pass385 assertions with depwarn=error. Source/normalized/compiled/
plan/emitted/full metadata and8 healthy complete outcomes/traces exact. Same15 old
modules reuse updated runtime/precompile image; no source regeneration. Actual
post-edit precompile/cache notices are strictly qualified/retained, no warning/
error suppression or empty-stderr claim. Current project/depot, no isolation.
Packet julia-named-capture-endpoint-intake.json.gz retains closure, normal runtests
registration verified; exact selection23.4.1 remains. Safe Lua47.5/49/48/45 and full
admission remain separate. Earlier anonymous/Number observations remain historical.

See [[julia-named-capture-take-origin-repair]] for current cause and recovery.
