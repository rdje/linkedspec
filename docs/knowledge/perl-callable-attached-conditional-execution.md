---
id: perl-callable-attached-conditional-execution
title: Perl callable attached branches execute typed bodies and preserve local return boundaries
answers:
  - "how does Perl execute attached if inside callable bodies"
  - "does a conditional branch return exit a Perl callback"
  - "does an eager block return inside a Perl callback escape the callback"
  - "what result does a final attached conditional statement yield in a Perl callback"
  - "which tasks own unsupported Perl callable return() and return_undef()"
  - "why did a malformed attached else tail become raw_perl in the Perl AST"
  - "which task repairs unsupported control_while in a deferred Perl callback"
date: 2026-10-03
status: attached executor verified; marker/value/null-return forms separately owned
tags: [perl, callable, actionir, control, return, scope]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1 source-complete RED/GREEN observations, native CLI comparison, focused regression and actual replay capture."
reverify: "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.5.1-review.py"
---

`CodeblockRuntime::_execute_sequence` reads typed action statements. Attached `control_if`
with first-branch role consumes consecutive typed elseif/else bodies. Conditions evaluate once
through `RuntimeLogical::truthy` until selection; unselected conditions/bodies never execute.
The sequence's private value/return flag propagates explicit return through nested conditional
bodies. `_execute_body` consumes that flag at callable or eager-expression block boundaries.
An attached control without return yields null, even if its selected body's final expression
has a value. A later ordinary expression can supply the callable's implicit result.

Public native/fresh observations retain the exact original matches source, branch/alias/nested
sources, ten truthiness values, actual branch effects and copied fixed/rest parameter restoration.
The shared public-invoke observer compares original x references and the same thrown error,
with a deliberately distinct equal-value reference control. Direct public typed invocation also
checks original fixed/rest binding references, the caller rest-array identity and a distinct
equal-value rest-array control. Source-poisoned public AST invocation
proves branch execution uses typed conditions/bodies rather than reparsing recorded source fields.
The documented PUC Lua CLI independently agrees on final conditional null and eager local return
for three exact selected sources; this is a bounded comparison, not backend admission.

Marker controls remain `.5.2`, lazy value if/else `.5.3`, null-return forms `.5.4`,
and the observed deferred while failure `.5.5`. The exact loop_excluded source loads on both
routes but fails unsupported_codeblock_actionir/control_while even for a false condition.
`Top:: I { cb={|| return() }; return(cb()) }` reports invalid_codeblock_return/expected exactly1;
`return_undef()` reports unknown_helper. Both native/fresh routes retain these exact failures.
`return(undef)` works under the existing one-argument path. Loops, attached statement-function
bodies, raw metadata ordering/readiness, dispatcher/full16 and other-backend repair remain separate.
Attached i/elif are Perl extensions; portable attached aliases are when/otherwise.

Only CodeblockRuntime production changes. The eight-field record, signature, public context,
compiler/fixtures/authorities and dependency pins remain activation-exact. The earlier matches
claim is frozen at5174958 with its hashes/results unchanged before this runtime edit.

Malformed-group test diagnosis: unseparated `else {...} else {...}` and `else {...} elseif(...) {...}`
tails are grouped into one unsupported raw_perl expression by the public AST parser, rather than
three typed branch statements. The exact producer/AST and failing test version remain tracked.
Explicit semicolon-separated variants create typed sibling branches and are rejected before
selected-body effects by invalid_codeblock_control. Orphan and marker-mixed groups retain typed
unsupported diagnostics. This is a test-source correction; no raw AST is reparsed or executed,
and raw-expression/readiness claims remain with .0.7.
