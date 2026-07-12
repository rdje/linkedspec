---
id: scalar-to-text-coercion-cross-backend-gap
title: Scalar-to-text helper coercion is identical across LinkedSpec variants
answers:
  - does cat convert booleans identically on all LinkedSpec backends
  - does cat accept null arrays hashes identically on all variants
  - how does cat stringify 1.0 across backends
  - what task closed scalar string coercion parity
  - is concat still an alias for cat
date: 2026-07-12
status: current
tags: [scalar, string, coercion, cat, perl, rust, dart, julia, lua, parity]
evidence: "LUA-BACKEND-PARITY.4.3.2.1.3 adds capability_conformance/scalar_text_contract.json and executes its portable spec fixture on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT. Strings remain unchanged; booleans spell 1/0; finite numbers use stable decimal text with -0.0 -> 0 and 1.0 -> 1; any null, array, or harray fragment makes cat return null. Codeblock is normatively non-text, while portable explicit final-codeblock call syntax remains separately owned by FUTURE-PARITY-BACKLOG.11.1 rather than being faked here. Perl generated lowering, Rust RuntimeValue::to_scalar_text, Dart _scalarString, Julia _runtime_scalar_string, and Lua scalar_string implement the same boundary. Retired concat remains rejected."
reverify: "PERL5LIB= prove -Iperl t/scalar_text_contract.t && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime lua_backend_parity_4_3_2_1_3_scalar_text_contract && cd dart && dart test test/scalar_text_contract_test.dart && cd .. && bash tools/run_lua_local.sh"
---

## Fact

`cat` now has one portable scalar-to-text contract:

- strings are unchanged;
- booleans become `1` and `0`;
- finite numbers use stable decimal text, including `-0.0` as `0`, integral-looking `1.0` as `1`, and `1.25`
  as `1.25`;
- null, array, harray, and codeblock values are not scalar text, so any such argument makes the whole result null.

The executable neutral fixture covers every currently portable source value on Perl, Rust, Dart, Julia, PUC Lua,
and LuaJIT. The codeblock row fixes the semantic value-kind rule without claiming that explicit final-codeblock
call syntax is already portable. ADR 0031 settles `{|args| body }` and dynamic-context design; neutral contract
`.11.2` and backend rollout still own behavior.

`cat` is the current helper name. The old `concat` spelling remains retired and is not an alias.
