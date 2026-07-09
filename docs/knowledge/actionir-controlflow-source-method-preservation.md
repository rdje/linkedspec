---
id: actionir-controlflow-source-method-preservation
title: "ActionIR control-flow source reconstruction must preserve authored current helper names inside attached blocks."
answers:
  - "why did generated oracle fixtures for current cat return null inside attached if blocks"
  - "where must ActionIR ControlFlow preserve source_method"
  - "how are current helper spellings preserved when reconstructing attached control-flow source"
date: 2026-07-09
status: current
tags: [actionir, control-flow, source-method, helper-retirement, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.8.4 found that attached-block source reconstruction can change user-authored helper spelling if it ignores AST `source_method`. NONCURRENT-HELPER-CODE-PURGE.2.1 later removed the current-helper normalization route, so current `cat(...)`/`set(...)`/`push(...)` spelling now stays current through parsing, reconstruction, contracts, and lowering. `t/phase0_regression.t` locks function-form and fluent `cat(...)` inside attached `if` blocks, and phase0 passes `1..1028`."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(\"Top\", q{set(out,\"\"); if(true) { set(out, cat(out,\"E\")) }; return(out)})' && prove -q -Iperl t/phase0_regression.t"
---

# ActionIR ControlFlow Source-Method Preservation

Attached control-flow lowering sometimes reconstructs nested source text from typed AST nodes before handing that text
to the existing lowering owners. That reconstruction must use the original source spelling (`source_method`) when it
exists, not only an implementation key.

The concrete invariant is current helper preservation. If a user writes `cat(...)`, `set(...)`, or a fluent current
helper inside an attached block, the reconstructed source sent to later lowering owners must keep that authored current
spelling.

Keep this fact in mind for any future source-reconstruction work:

- AST method names can be useful implementation keys.
- Source spellings decide the current helper contract.
- Reconstructed source used for later lowering must preserve source spelling where the AST carries it.
