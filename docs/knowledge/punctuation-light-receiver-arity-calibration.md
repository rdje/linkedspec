---
id: punctuation-light-receiver-arity-calibration
title: "A terminal bare receiver supplies zero authored arguments; arity examples must subtract the implicit receiver from function-form helper arity."
answers:
  - "why does the punctuation light contract use contains instead of drop_front"
  - "does drop_front require an authored receiver argument"
  - "how is receiver method authored arity derived from helper arity"
  - "which receiver method demonstrates missing argument rejection"
  - "does Rust reject contains with no receiver argument"
  - "why does Rust contains without a needle return zero"
  - "why does Dart contains without a needle return zero"
  - "why does Julia contains without a needle return zero"
  - "why does Lua contains without a needle return zero"
date: 2026-07-13
status: confirmed
tags: [dsl, actionir, receiver, arity, contract, perl-reference, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.16.2.0 used LinkedSpec::call_spec_handler_subst plus perl/LinkedSpec/ActionIR/MethodLowering.pm's canonical %ast_aggregate_call_arity table. Function-form drop_front is [1,2], so its implicit receiver leaves zero or one authored arguments and values.drop_front() validly drops one. Function-form contains is [2,2], so its implicit receiver leaves exactly one authored argument and values.contains() takes the established Perl unsupported-helper rejection path. FUTURE-PARITY-BACKLOG.16.3 then proved pre-existing Rust drift: validation recognizes contains but does not enforce arity, and engine.rs defaults args[1] to empty text, so both values.contains and values.contains() return numeric 0 for [a,b]. FUTURE-PARITY-BACKLOG.16.4 proves Dart's _callArrayContains also returns numeric 0 when fewer than two values arrive; .16.5 proves Julia's _call_runtime_array_contains does the same; .16.6 proves Lua's pure array helper also returns 0 when values[2] is absent. Each syntax alias correctly preserves its parenthesized twin; FUTURE-PARITY-BACKLOG.5 owns helper normalization."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $s (q{return(values.drop_front())},q{return(values.contains())}) { print LinkedSpec::call_spec_handler_subst(\"Top\",$s),qq{\\n} }' && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test punctuation_light_zero_arg_contract terminal_alias_preserves_existing_rust_method_resolution && (cd dart && dart test test/punctuation_light_zero_arg_contract_test.dart) && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/punctuation_light_zero_arg_contract_test.jl\")' && bash tools/run_lua_local.sh && bash tools/run_python_project_data.sh tools/check_punctuation_light_zero_arg_contract.py"
---

# Receiver arity calibration

Receiver methods consume the value to the left of the dot as an implicit first helper argument. Therefore the
authored receiver arity is the canonical function-form arity minus that receiver slot.

- `drop_front(array_expr[, count])` has function arity `[1,2]`, so `.drop_front()` is valid and defaults to one.
- `contains(array_expr, value)` has function arity `[2,2]`, so `.contains()` is missing one authored argument.

The punctuation-light rule remains unchanged: a final `.method` supplies zero authored arguments and must behave
exactly like `.method()`. The neutral contract uses `contains` only because it is a truthful required-argument
example on the Perl reference; it does not add or remove a helper. Rust currently substitutes empty text when the
second argument is absent, while Dart's `_callArrayContains`, Julia's `_call_runtime_array_contains`, and Lua's
pure array helper return `0` when fewer than two values arrive. Thus `.contains()` returns `0` on all four
non-reference backends for this case. Those pre-existing semantic differences are owned by
`FUTURE-PARITY-BACKLOG.5`; the punctuation-light spelling preserves it rather than silently changing the helper.

## Links

- Contract: `capability_conformance/punctuation_light_zero_arg_contract.json`
- Perl arity owner: `perl/LinkedSpec/ActionIR/MethodLowering.pm`
- Dart runtime owner: `dart/lib/src/runtime/interpreter.dart`
- Julia runtime owner: `julia/src/runtime/Interpreter.jl`
- Lua runtime owner: `lua/src/linkedspec/interpreter.lua`
- Tree: `docs/tasks/FUTURE-PARITY-BACKLOG.md`, leaf `.16.2.0`
- Related: [[punctuation-light-zero-argument-calls]]
