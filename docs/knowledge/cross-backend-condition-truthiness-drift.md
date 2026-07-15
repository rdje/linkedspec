---
id: cross-backend-condition-truthiness-drift
title: Condition truthiness differs for scalar zero text and empty aggregates across backends
answers:
  - "is LinkedSpec condition truthiness identical across backends"
  - "is string zero truthy in LinkedSpec"
  - "are empty arrays truthy in LinkedSpec conditions"
  - "are empty hashes truthy in LinkedSpec conditions"
  - "which task owns cross backend truthiness normalization"
  - "why does Lua truthiness differ from Dart and Julia"
  - "why do Perl return and and return or yield undef"
date: 2026-07-13
status: confirmed-gap
tags: [truthiness, control-flow, perl, rust, dart, julia, lua, parity, FUTURE-PARITY-BACKLOG]
evidence: "LUA-BACKEND-PARITY.4.3.6.2 signoff read Perl ControlFlow lowering plus RuntimeValue::as_bool in Rust, _truthy in Dart, _runtime_truthy in Julia, and the new Lua runtime_truthy. Perl/Rust treat scalar \"0\" as false; Dart/Julia treat it as a non-empty true string. Perl treats array/hash references as true even when empty; Rust/Dart/Julia treat empty aggregates as false. Lua follows Perl pending FUTURE-PARITY-BACKLOG.5."
evidence_update_2026_07_15: "LUA-BACKEND-PARITY.4.3.9.0 finds Lua's missing and/or/not dispatcher and a distinct Perl lowering defect: call_spec_handler_subst emits return and(...) / return or(...), whose keyword precedence returns undef in direct LinkedSpec::Get probes. Rust and Julia already use eager boolean composition; Dart returns booleans but evaluates inside a short-circuiting loop. FUTURE-PARITY-BACKLOG.5.2 now owns exact evaluation/arity/truthiness and Perl reference repair after current Lua parity."
evidence_update_2026_07_15_lua_logical: "LUA-BACKEND-PARITY.4.3.9.1 now executes Lua and/or/not eagerly over its established truthiness at 123/123. Source audit corrects the earlier broad statement about Dart: Dart evaluates inside its logical loop, short-circuits decisive operands, and returns true for empty and(), while Rust/Julia/Lua use eager values with empty false. FUTURE-PARITY-BACKLOG.5.2 owns the full evaluation/empty/arity/truthiness/reference alignment."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(q{Top}, q{return(if(\"0\",\"T\",\"F\"))}), qq{\n}, LinkedSpec::call_spec_handler_subst(q{Top}, q{return(if([],\"T\",\"F\"))}), qq{\n}' && rg -n 'as_bool|bool _truthy|function _runtime_truthy|local function runtime_truthy' rust/linkedspec-core/src/types.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua"
---

The public language does not yet have one enforced six-backend condition truth table at two boundaries:

| Value | Perl reference | Rust | Dart | Julia | Lua |
| --- | --- | --- | --- | --- | --- |
| scalar `"0"` | false | false | true | true | false |
| empty array/harray | true (host references) | false | false | false | true |

Null, boolean false, numeric zero, and the empty string are false on all five implementations; nonempty ordinary
values are true. Lua follows the designated Perl behavioral oracle rather than silently selecting the later
interpreter majority. `FUTURE-PARITY-BACKLOG.5.2` now owns the keep-or-normalize decision, the public truth table,
and locks across lazy controls plus eager `and`/`or`/`not` helpers. Until that leaf lands, portable `.spec` files
should use explicit emptiness, definedness, numeric, or string predicates at the disputed boundaries.

There is also a reference-lowering defect independent of truthiness selection. Direct toolbox probes show
`return(and(...))` and `return(or(...))` lower to Perl keyword forms whose precedence returns `undef`; `not(...)`
does produce a boolean. `.5.2` must repair that reference path before treating it as an oracle for the neutral
logical-helper fixture. Lua's current-parity repair follows the already documented eager helper shape and its
existing governed runtime truthiness without claiming that normalization is complete.

Related facts: [[lua-runtime-lazy-inline-controls]], [[lua-logical-helper-execution]], [[julia-logical-helper-execution]],
[[cross-backend-scalar-numeric-drift]], [[lua-exhaustive-runtime-call-audit]].
