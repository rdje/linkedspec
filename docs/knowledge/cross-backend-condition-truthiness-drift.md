---
id: cross-backend-condition-truthiness-drift
title: Condition truthiness still differs across backends after Perl adopts typed truth
answers:
  - "is LinkedSpec condition truthiness identical across backends"
  - "is string zero truthy in LinkedSpec"
  - "are empty arrays truthy in LinkedSpec conditions"
  - "are empty hashes truthy in LinkedSpec conditions"
  - "which task owns cross backend truthiness normalization"
  - "why does Lua truthiness differ from Dart and Julia"
  - "why do Perl return and and return or yield undef"
  - "is string false truthy in LinkedSpec"
date: 2026-07-13
status: rollout-in-progress
tags: [truthiness, control-flow, perl, rust, dart, julia, lua, parity, FUTURE-PARITY-BACKLOG]
evidence: "LUA-BACKEND-PARITY.4.3.6.2 signoff read Perl ControlFlow lowering plus RuntimeValue::as_bool in Rust, _truthy in Dart, _runtime_truthy in Julia, and the new Lua runtime_truthy. Perl/Rust treat scalar \"0\" as false; Dart/Julia treat it as a non-empty true string. Perl treats array/hash references as true even when empty; Rust/Dart/Julia treat empty aggregates as false. Lua follows Perl pending FUTURE-PARITY-BACKLOG.5."
evidence_update_2026_07_15: "LUA-BACKEND-PARITY.4.3.9.0 finds Lua's missing and/or/not dispatcher and a distinct Perl lowering defect: call_spec_handler_subst emits return and(...) / return or(...), whose keyword precedence returns undef in direct LinkedSpec::Get probes. Rust and Julia already use eager boolean composition; Dart returns booleans but evaluates inside a short-circuiting loop. FUTURE-PARITY-BACKLOG.5.2 now owns exact evaluation/arity/truthiness and Perl reference repair after current Lua parity."
evidence_update_2026_07_15_lua_logical: "LUA-BACKEND-PARITY.4.3.9.1 now executes Lua and/or/not eagerly over its established truthiness at 123/123. Source audit corrects the earlier broad statement about Dart: Dart evaluates inside its logical loop, short-circuits decisive operands, and returns true for empty and(), while Rust/Julia/Lua use eager values with empty false. FUTURE-PARITY-BACKLOG.5.2 owns the full evaluation/empty/arity/truthiness/reference alignment."
evidence_update_2026_07_16_logical_audit: "FUTURE-PARITY-BACKLOG.5.2.0 establishes three truthiness profiles: Perl/Lua make scalar \"0\" false and empty aggregates true; Dart/Julia make every nonempty string true and empty aggregates false; Rust makes both \"0\" and \"false\" false and empty aggregates false. Perl conditions lower and/or lazily through host operators while direct logical values remain raw/broken, so earlier eager-Perl wording was inaccurate. See logical-helper-five-backend-audit."
evidence_update_2026_07_16_perl_logical: "FUTURE-PARITY-BACKLOG.5.2.2 moves Perl conditions and logical values to LinkedSpec::RuntimeLogical. Perl now follows ADR 0043: string \"0\" and \"false\" are true, empty aggregates are false, numeric zero is false, and controls stay lazy over the same seam. Rust/Dart/Julia/Lua remain pending, so cross-backend drift persists at 1/7 rollout."
reverify: "prove -Iperl t/logical_helper_perl_contract.t && rg -n 'as_bool|bool _truthy|function _runtime_truthy|local function runtime_truthy' rust/linkedspec-core/src/types.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua"
---

The public language does not yet have one enforced five-backend condition truth table at three boundaries:

| Value | Perl reference | Rust | Dart | Julia | Lua |
| --- | --- | --- | --- | --- | --- |
| scalar `"0"` | true | false | true | true | false |
| scalar `"false"` | true | false | true | true | true |
| empty array/harray | false | false | false | false | true |

Null, boolean false, numeric zero, and the empty string are false on all five implementations; nonempty ordinary
values are true. Lua follows the designated Perl behavioral oracle rather than silently selecting the later
interpreter majority. `FUTURE-PARITY-BACKLOG.5.2` now owns the keep-or-normalize decision, the public truth table,
and locks across lazy controls plus eager `and`/`or`/`not` helpers. Until that leaf lands, portable `.spec` files
should use explicit emptiness, definedness, numeric, or string predicates at the disputed boundaries.

The `.5.2.0` audit also found a reference-lowering defect independent of truthiness selection: direct logical
values were raw Perl keyword calls, conditions used host `&&`/`||`, and optional-scope stripping could reinterpret
`not(false, true)`. Perl `.5.2.2` repairs that path with typed ActionIR, pre-effect arity, eager operands, booleans,
and one condition/helper truth seam. The remaining table differences are now explicitly owned by `.5.2.3-.6`.

Related facts: [[logical-helper-five-backend-audit]], [[lua-runtime-lazy-inline-controls]],
[[lua-logical-helper-execution]], [[julia-logical-helper-execution]],
[[cross-backend-scalar-numeric-drift]], [[lua-exhaustive-runtime-call-audit]].
