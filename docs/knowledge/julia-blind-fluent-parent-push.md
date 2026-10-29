---
id: julia-blind-fluent-parent-push
title: Julia blind fluent push calls the enclosing rule through typed push dispatch
answers:
  - why did Julia blind push require an action-edge child context
  - does Julia blind push append its previous child result
  - how does Julia preserve typed blind parent push values and explicit targets
  - do Julia blind parent push modules need regeneration
  - why do Julia referenced coordinators duplicate their arrays after push repair
date: 2026-10-29
status: bounded48.4.1 and48.4.2 repaired; canonical progress/lifetime before admission
tags: [julia, blind, fluent, push, parent-call, runtime, typed, invocation]
evidence: "julia-blind-parent-push-intake.json.gz retains13 sources2healthy11actualRED to13 pass4routes using same13 modules, exact metadata and853 selected assertions."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error julia/test/blind_parent_push_test.jl"
---

Blind fluent `.push` invokes the enclosing parent after the preceding child;
it does not append the prior child's value. The frozen public source with
child value X and parent initializer returning TAIL yields `["TAIL"]` in pipe
mode and `[["TAIL"]]` in default repeated mode. Parent0/false/null/Array values
retain their kinds; an Array stays nested. `.push(out)` names the destination.

In `julia/src/runtime/Interpreter.jl`, blind optional payloads have no current
action edge. Ordinary zero-argument push therefore raised an action-context
error; a single explicit target could silently return null. Independent13
shared controls found2 healthy and11 failing sources:9 actual context errors
and2 wrong explicit-target values. Normal RED had33 failed26 passed assertions;
fresh baseline modules independently reproduced these values/errors.

The repair threads a private nullable enclosing entry index from rule dispatch
through one-shot/repeated blind payloads. Only fluent-only top-level push uses
that index: normal `_evaluate_runtime_call!` retains user-function precedence
and arity, then builtin `_call_runtime_push!` prepends a typed parent variable.
Its existing rule-call branch performs mutation guards, target/result-index
selection, inherited entry dispatch and typed append. No fake action edge,
new persistent frame or prior-child append path is introduced. Attached/free/
action/callback execution retains existing owners. Nonzero-selector and shadowed
user-push runtime controls were not executed; the implementation threads and
resolves them, without claiming dedicated runtime proof.

All13 sources pass native/JSON-restored/plan/fresh, with the same13 baseline
modules and exact source/normalized/compiled/plan/emitted/full v2 metadata.
Two healthy observations are fully unchanged. New104/referenced180/postcall274/
recognition progress234/uniform bindings61 pass853 selected assertions; final
focused/fresh stderr is empty. No compiler/emitter/fixture/schema/family or
ordinary count/minimum/IT/progress/LX policy change; existing modules reuse the
updated runtime without regeneration.

All36 earlier source/artifact/diagnostic rows remain exact and33 runtime rows
are unchanged. Qualified `blind_no_regex`, `marked_blind_target`, `markerless_blind`
now return[[x],[x]] at1 instead of raising the repaired context error. Reference
expects[[x]]. Existing invocation entry creates a snapshot map but does not
reset an implicit same-name array; explicit resets already scope correctly.
P1 `TYPE-REFERENCE-BOOK.1.2.23.3.48.4.2` immediately owns an independent3-source
direct/implicit/explicit-reset baseline and repair. Three runtime qualifications
remain explicit. Do not infer a progress policy or other backend failure from
this array leak; canonical39.8.1/lifecycle/selection/admission remain separate.

## Invocation follow-up48.4.2

Conventional same-name arrays are now fresh at invocation entry. Direct twice
is repaired; qualified3 coordinators now[[x],[]] and remain under ordinary
progress authority39.8.1. Separate undeclared-variable scope control exposes
Perl child-local versus Julia shared state under canonical48.4.2.1. No broader
portable runtime parity follows. See [[julia-rule-invocation-accumulator-scope]].
