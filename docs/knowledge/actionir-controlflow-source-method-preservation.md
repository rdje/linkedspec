---
id: actionir-controlflow-source-method-preservation
title: "ActionIR control-flow source reconstruction must preserve source_method so current helper spellings stay current inside attached blocks."
answers:
  - "why did generated oracle fixtures for current cat return null inside attached if blocks"
  - "where must ActionIR ControlFlow preserve source_method"
  - "why can parser-normalized cat become retired concat in attached control flow"
  - "how are current helper spellings preserved when reconstructing attached control-flow source"
date: 2026-07-07
status: current
tags: [actionir, control-flow, source-method, helper-retirement, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.8.4 regenerated the Rust oracle corpus after retiring old helper spellings. Current `cat(...)` uses parser-normalized method name `concat` internally. `LinkedSpec::ActionIR::ControlFlow` reconstructed attached-block source from AST method names, so `if(true) { set(out, cat(out,\"E\")) }` could become source-spelled `concat(...)` during lowering and hit the `.8.3` retired-helper diagnostic, producing null oracle output. The fix preserves AST `source_method` for reconstructed calls and fluent chains. `t/phase0_regression.t` now locks both function-form and fluent `cat(...)` inside attached `if` blocks."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(\"Top\", q{set(out,\"\"); if(true) { set(out, cat(out,\"E\")) }; return(out)})' && prove -q -Iperl t/phase0_regression.t"
---

# ActionIR ControlFlow Source-Method Preservation

Attached control-flow lowering sometimes reconstructs nested source text from typed AST nodes before handing that text
to the existing lowering owners. That reconstruction must use the original source spelling (`source_method`) when it
exists, not only the normalized method name.

The concrete `.8.4` failure was current `cat(...)` inside an attached `if` block. The AST normalized it to the
historical implementation name `concat`; if the reconstructed source spelled `concat(...)`, helper retirement correctly
diagnosed it as old syntax. The user-authored spelling was still `cat(...)`, so the reconstruction had lost the
semantic signal needed by the retirement layer.

Keep this fact in mind for any future source-reconstruction work:

- AST method names are useful implementation keys.
- Source spellings decide compatibility/retirement behavior.
- Reconstructed source used for later lowering must preserve source spelling where the AST carries it.
