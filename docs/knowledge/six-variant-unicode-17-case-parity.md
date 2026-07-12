---
id: six-variant-unicode-17-case-parity
title: All six LinkedSpec runtime variants share Unicode 17 casing
answers:
  - do all LinkedSpec variants lowercase Unicode identically
  - do all LinkedSpec variants uppercase Unicode identically
  - where is Lua Unicode casing implemented
  - does Lua use string lower upper for LinkedSpec casing
date: 2026-07-12
status: current
tags: [unicode, casing, lua, parity, generation]
evidence: "LUA-BACKEND-PARITY.4.3.2.1.2.4 generates lua/src/linkedspec/unicode_case_mapping.lua. Twelve neutral fixtures pass direct/helper/receiver/array paths on PUC Lua and LuaJIT (71/71 each), completing the already-green Perl/Rust/Dart/Julia generated-table rollout."
reverify: "python3 tools/check_unicode_case_contract.py && bash tools/run_lua_local.sh"
---

## Fact

Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT execute one Unicode 17.0.0 full Default Case Conversion contract.
Lua uses generated maps and contextual properties plus strict UTF-8 scalar decoding/encoding, never byte-oriented
`string.lower` or `string.upper`. The 12 common fixtures cover expansions, combining output, supplementary scalars,
Final Sigma context, and no normalization.

Related facts: [[unicode-17-case-contract-data]], [[perl-rust-unicode-17-case-mapping]],
[[dart-julia-unicode-17-case-mapping]].
