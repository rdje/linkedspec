---
id: logical-helper-five-backend-audit
title: Logical helpers currently expose three truthiness profiles and a split Perl lowering path
answers:
  - "what are the current and or not semantics on all five LinkedSpec backends"
  - "are LinkedSpec logical helpers eager or short circuit"
  - "why are Perl logical helpers not eager"
  - "why does not false true select the second argument in Perl"
  - "is string false truthy in LinkedSpec"
  - "what do empty and or not return on each backend"
  - "do generated logical helpers match native execution"
  - "does ActionIR have a logical expression node"
  - "which task owns logical helper parity"
date: 2026-07-16
status: confirmed-gap
tags: [logical, truthiness, arity, actionir, generated-source, perl, rust, dart, julia, lua, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.5.2.0 used call_spec_handler_subst, LinkedSpec::Get, return_descriptor, emitted-source execution, source ownership reads, and matching native/generated probes. Perl condition lowering uses lazy host &&/|| but direct value/return/receiver calls remain raw and broken; Rust/Julia/Lua eagerly evaluate every argument; Dart short-circuits. The same probes establish three truthiness profiles and confirm native/generated identity on Rust, Dart, Julia, and both Lua ABIs. The canonical narrative is the mdBook Boolean composition section and backend handoff; .5.2.1-.9 own policy and rollout."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(q{Top}, q{return(and(true,false))}), qq{\n}, LinkedSpec::call_spec_handler_subst(q{Top}, q{return(if(and(false,true),\"T\",\"F\"))}), qq{\n}' && rg -n 'as_bool|_callLogicalAnd|_callLogicalOr|_callLogicalNot|_runtime_truthy|evaluate_runtime_logical|runtime_truthy' rust/linkedspec-core/src/types.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua"
---

The five implementations do not currently express one logical-helper contract:

| Backend | Evaluation | Empty `and/or/not` | Scalar `"0"` / `"false"` | Empty aggregates |
| --- | --- | --- | --- | --- |
| Perl | condition-only `and/or` are lazy host operators; direct values are broken | direct calls broken | false / true | true |
| Rust | eager, once, left-to-right | false / false / true | false / false | false |
| Dart | short-circuit `and/or`; `not` evaluates only its first argument | true / false / true | true / true | false |
| Julia | eager, once, left-to-right | false / false / true | true / true | false |
| Lua | eager, once, left-to-right | false / false / true | false / true | true |

This is three truthiness profiles, not a simple reference-versus-interpreter split. Rust uniquely treats the
ordinary nonempty string `"false"` as false; Dart and Julia use nonempty-string truth; Perl and Lua share scalar
`"0"`/empty-aggregate host-compatible boundaries.

Perl also has two mechanisms rather than an eager helper implementation. `FlowExpr.pm` lowers logical expressions
inside conditions to host `&&`, `||`, and `!`, so decisive operands skip later side effects. Direct return,
assignment, nested, and receiver forms remain raw keyword calls such as `return and(...)`, which miscompile or
return `undef`. Logical expressions remain strings inside canonical `IF`/`ASSIGN`/`RETURN` descriptor arguments;
there is no first-class logical ActionIR node. The legacy optional-scope normalizer can additionally reinterpret
the first bare value token in `not(false, true)` as a scope and lower `!(true)`.

Rust, Dart, Julia, and Lua generated execution reproduces each backend's native behavior exactly, so generated
projection is not the source of the drift. `FUTURE-PARITY-BACKLOG.5.2.1` must ratify the neutral semantics before
the dependency-ordered Perl/Rust/Dart/Julia/Lua, generated/primary, recurring-gate, and public no-drift leaves
change behavior.

Related facts: [[cross-backend-condition-truthiness-drift]], [[julia-logical-helper-execution]],
[[lua-logical-helper-execution]], [[dart-helper-action-surface-bridge]].
