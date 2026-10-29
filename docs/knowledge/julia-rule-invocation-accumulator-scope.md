---
id: julia-rule-invocation-accumulator-scope
title: Julia conventional arrays are fresh per invocation while ordinary and cross-rule scope authority remains qualified
answers:
  - why did repeated Julia direct rule calls reuse their first result
  - how does Julia reset conventional rule arrays per invocation
  - does Julia restore scalar Array Hash caller bindings after rule exit
  - why do Julia coordinators retain an extra empty result after scope repair
  - does Perl share an undeclared child working variable with its caller
  - which task owns Julia and Perl undeclared variable scope differences
date: 2026-10-29
status: bounded48.4.2 repaired; canonical39.8.1 and48.4.2.1 before admission
tags: [julia, invocation, scope, binding, accumulator, progress, perl]
evidence: "julia-rule-accumulator-intake.json.gz retains original3 source epochs/same3 modules,4 post-change binding controls/current public reference/emitted local declarations and909 focused assertions."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error julia/test/rule_invocation_accumulators_test.jl"
---

`julia/src/runtime/Interpreter.jl` `_execute_runtime_rule!` previously opened an
empty snapshot map per invocation. Explicit initializer/reset writes entered
that map, but an implicit conventional same-name array was reused. Original3
controls independently showed two duplicate results `[[x],[x]]` and one healthy
explicit reset `[[x],[]]` on native/restored/plan/fresh.

Accepted rule entry now records its own name through the existing full-kind
snapshot owner, removes scalar/hash representations, creates an empty Array and
binds a fresh identity. Existing finally restores the copied caller values and
binding ID. Explicit resets still retain the first snapshot; other working
variables retain existing policy. No object-reference identity claim follows
from copied values. No matcher/compiler/emitter/schema/family or phase change.

Direct_twice is one portable observed RED-to-GREEN control. Explicit reset is
fully unchanged. Same3 original modules/source/metadata are reused. Implicit
coordinator changes to `[[x],[]]`, proving a fresh final empty array but differing
from reference `[[x]]`. That is a qualified compatibility result, not a portable
implicit RED-to-GREEN claim. The3 qualified referenced coordinators show the same
tail;36 artifact/diagnostic records and33 other runtime records remain exact.
Canonical39.8.1 now includes this actual Julia evidence alongside Dart after20.1,
before admission. Julia ordinary_blind source/ORDINARY expectation is identical
to Dart; progress normal still preserves it. No cutoff experiment was performed.

Four additional post-change controls qualify caller scalar/Array/Hash restore
on all4 Julia routes against current Perl native/emitted results. The fourth
source exposes separate undeclared variable lifetime behavior:

```text
Top::
 I { out=[]; seen=call(Middle); return(array(seen,out)); }
Middle:
 I { push(out,"C"); return(copy(out)); }
```

Julia returns `[["C"],["C"]]` at0; current Perl returns `[["C"],[]]` at0.
Public emitted Perl has separate `my $out` declarations in Top/Middle and a
Middle-local `BindingRuntime::push_value` call. Julia's context stores are shared
unless explicit scope/reset records a binding; its established July fact and
compatibility preserve undeclared child writes. P1 canonical48.4.2.1 owns exact
scope authority and per-backend repairs after20.1, before admission. No inferred
peer defect or portable sharing credit. The fixture records reference expected
and explicit Julia compatibility/owner; the ordinary test preserves both bounds.

The initial Hash control used bare `key` with a literal-key expectation. Existing
shape-literal authority defines that as a scalar read; quoting the key corrected
the instrument. Initial fixture/reference are retained without product RED credit.
Reference raw fixture expectation for the sharing control precedes qualification;
the reader matches exact source/input to the final fixture's reference value.

New56/referenced180/push104/postcall274/progress234/uniform61 pass909 assertions;
fresh/focused stderr is empty. Original oracle baseline6failed18passed; scope-only
oracle3failed21passed preserves the remaining implicit difference before explicit
compatibility qualification. No before/after or portable shared-variable parity
claim for the4 new controls, no full package/gate/admission claim. Normal selection
23.4.1, parent-LX48.2.2.1 and other canonical prerequisites remain separate.
