---
id: cross-backend-condition-truthiness-drift
title: Native condition truthiness is aligned; projection and public closeout remain
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
evidence_update_2026_07_17_rust_logical: "FUTURE-PARITY-BACKLOG.5.2.3 moves Rust conditions and logical values to the exact ADR 0043 policy through RuntimeValue::as_bool. String \"0\" and \"false\" are true, empty aggregates and numeric zero are false, empty logical calls diagnose before effects, and controls remain lazy over the same seam. Dart/Julia/Lua plus projection/gate/public legs remain pending at 2/6 rollout."
evidence_update_2026_07_17_dart_logical: "FUTURE-PARITY-BACKLOG.5.2.4 makes runtimeLogicalTruth the exact Dart helper/control boundary. Dart retains its already-correct nonempty-string/empty-aggregate rows, makes helpers eager, rejects empty and extra logical arities before effects, and proves native plus generated/emitted/primary roles. Julia/Lua plus projection/gate/public legs remain pending at 3/5 rollout."
evidence_update_2026_07_17_julia_logical: "FUTURE-PARITY-BACKLOG.5.2.5 retains Julia's already-correct _runtime_truthy rows and eager helper evaluation while adding exact arity before effects. Native, normalized, generated-plan, emitted, and primary roles agree. Lua plus projection/gate/public legs remain pending at 4/4 rollout."
evidence_update_2026_07_17_lua_logical: "FUTURE-PARITY-BACKLOG.5.2.6 makes Lua runtime_truthy the exact helper/control boundary: string zero is true, empty aggregates are false, logical arity rejects before effects, and controls remain lazy. Native, reconstructed, generated-plan, emitted, and primary roles agree on both ABIs. All five native backends are aligned at 5/3 rollout; generated/primary, recurring, and public closeout remain."
reverify: "prove -Iperl t/logical_helper_perl_contract.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test logical_helper_contract && (cd dart && dart test test/logical_helper_contract_test.dart) && bash tools/run_lua_local.sh && rg -n 'as_bool|runtimeLogicalTruth|function _runtime_truthy|local function runtime_truthy' rust/linkedspec-core/src/types.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua"
---

All five native backends now enforce one condition truth table at the formerly disputed boundaries:

| Value | Perl reference | Rust | Dart | Julia | Lua |
| --- | --- | --- | --- | --- | --- |
| scalar `"0"` | true | true | true | true | true |
| scalar `"false"` | true | true | true | true | true |
| empty array/harray | false | false | false | false | false |

Null, boolean false, numeric zero, and the empty string are false on all five implementations; nonempty ordinary
values are true. Perl, Rust, Dart, Julia, and Lua consume the ADR `0043` target across lazy controls plus eager
`and`/`or`/`not` helpers. `FUTURE-PARITY-BACKLOG.5.2.7-.9` retain generated/primary projection, recurring proof,
and public no-drift; they do not own a known remaining native truth-table difference.

The `.5.2.0` audit also found a reference-lowering defect independent of truthiness selection: direct logical
values were raw Perl keyword calls, conditions used host `&&`/`||`, and optional-scope stripping could reinterpret
`not(false, true)`. Perl `.5.2.2` repairs that path with typed ActionIR, pre-effect arity, eager operands, booleans,
and one condition/helper truth seam. Rust `.5.2.3`, Dart `.5.2.4`, and Julia `.5.2.5` apply the same policy through
their typed runtime seams. Lua `.5.2.6` closes the final native table and helper-arity difference through
`runtime_truthy` on both ABIs.

Related facts: [[logical-helper-five-backend-audit]], [[lua-runtime-lazy-inline-controls]],
[[lua-logical-helper-execution]], [[julia-logical-helper-execution]],
[[cross-backend-scalar-numeric-drift]], [[lua-exhaustive-runtime-call-audit]],
[[rust-logical-helper-neutral-runtime]], [[dart-logical-helper-neutral-runtime]].
