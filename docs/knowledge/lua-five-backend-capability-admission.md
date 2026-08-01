---
id: lua-five-backend-capability-admission
title: Lua is admitted all-pass across the five-backend 16-capability census
answers:
  - is Lua a fully admitted LinkedSpec backend
  - how many backends are in the current capability census
  - how many capability states pass after Lua admission
  - which leaf admits Lua to the capability census
  - what evidence supports every Lua capability row
  - is PUC Lua or LuaJIT the primary conformance runtime
  - why were the Lua backend and variadic function exclusions removed
  - does Lua generated source pass the capability census
date: 2026-07-16
status: current
tags: [lua, parity, capability-census, admission, PUC-Lua, LuaJIT, generated-source, handoff]
evidence: "LUA-BACKEND-PARITY.8.4 adds Lua to capability_conformance/manifest.json and its checker as the fifth exact backend. All 16 Lua entries are pass with direct source plus recurring test/gate references, so the census reports 80 pass, zero partial, zero gap. generated_source_contract.json likewise records Lua pass after deterministic v1/v2/v3 emission, dual-ABI isolation, ten-family execution/four rejections/portable trace, emitted variadic execution, and exact contract-ordered interpreter-first 8/105 fresh-host proof. The satisfied future.variadic_user_functions and future.lua_backend exclusions are removed; the mixed generic callable-codeblock exclusion remains narrowed to genuinely future explicit values/dynamic calls and Rust/Dart/Julia parity. PUC Lua 5.4 remains primary and LuaJIT remains a behavior-identical compatibility leg. Focused proof is 177/177 per ABI, primary 61x2, corpus 105/105, matrix 5x2x61; canonical local CI passes reference CLI 61x2 and Phase 0 1..1031 in 625 seconds."
evidence_update_2026_07_30_julia_invocation: "The admission-time exclusion text is historical. Rust and Dart have since completed construction, dynamic invocation, and contextual equivalence; Julia has completed construction plus dynamic invocation. Current residual callable work is Julia contextual equivalence and Lua explicit callable values/dynamic invocation, followed by governed cross-backend closeout."
evidence_update_2026_08_01_lua_invocation: "FUTURE-PARITY-BACKLOG.11.8.1-.2 make Lua explicit construction and arbitrary dynamic invocation current on PUC Lua and LuaJIT. The 80/0/0 capability census remains unchanged; only independently loaded emitted identity and five-backend recurring/public admission remain .11.8.3-.4."
evidence_update_2026_08_01_lua_emitted_identity: "FUTURE-PARITY-BACKLOG.11.8.3 proves native/reconstructed/generated/fresh-emitted callable identity at 449 assertions per ABI without advancing the 80/0/0 capability census. Only five-backend recurring/public admission remains .11.8.4."
reverify: "perl tools/check_capability_conformance.pl; perl tools/check_generated_source_contract.pl; bash tools/run_lua_local.sh; bash tools/run_primary_cli_matrix.sh; bash tools/run_ci_local.sh"
---

ADR `0041` deliberately kept Lua outside the executable census until native
embedding, the full language/runtime surface, structured diagnostics and
trace, named loading, exact descriptors, 105/105 interpreter corpus, 61x2
primary CLI, generated source, all ten generated families, and the accepted
8/105 generated subset were all recurring. `.8.4` performs that one allowed
all-pass expansion; it does not use partial or gap rows as a progress ledger.

`capability_conformance/manifest.json` now names exactly five backends:
Perl, Rust, Dart, Julia, and Lua. Each of its 16 rows contains a Lua `pass`
entry with existing source and recurring proof paths. The checker enforces the
exact five-backend set, evidence existence, state vocabulary, and ownership;
the result is 80/0/0.

Generated source is not inferred from native corpus success. The neutral
generated-source contract separately records Lua `pass`, owns its exact test
path, and checks deterministic emission, fresh loading, plans, family routing,
portable trace, failures, cleanup, and the exact interpreter-first subset.
Rust remains the strict 105/105 generated classifier; Dart, Julia, and Lua
prove the accepted 8/105 boundary plus every generated family.

The future ledger removes `future.variadic_user_functions` because Lua now
proves native, descriptor, emitted, and final-admission behavior, and removes
`future.lua_backend` because the backend is complete. It retains
`future.generic_final_codeblock` only as a route/admission residual: contextual
declared forms, explicit callable values, and arbitrary dynamic calls are now
current on Lua, and independently loaded emitted identity is current under `.11.8.3`, while five-backend
recurring/public admission remains `.11.8.4`. The other four backends already
own their complete callable routes.

PUC Lua 5.4 is the primary conformance runtime. LuaJIT is a secondary
compatibility leg over Lua 5.1 language behavior; it may not weaken or fork
the public contract. Both run the same 177-test package suite, while the
primary command additionally runs the exact 61-case default/POSIX contract
and the complete 105-fixture developer corpus.

Related facts: [[backend-capability-census]],
[[lua-backend-full-parity-plan]], [[lua-primary-cli-no-drift-closeout]],
[[lua-generated-source-accepted-subset]], [[generated-source-contract-v1]],
[[lua-callable-codeblock-emitted-route-identity]], [[user-observable-backend-cli-parity-contract]].
