---
id: lua-rule-local-cursor-execution
title: "Lua normal execution derives cursor and composition policy at every entered rule"
answers:
  - "does Lua use rule local cursor policy"
  - "where does Lua derive seek versus consume"
  - "does a Lua parent propagate cursor policy to a child"
  - "does Lua AND consume and OR seek"
  - "does loaded Lua execution use rule local cursor policy"
  - "does normalized Lua SpecFile JSON use rule local cursor policy"
  - "how does Lua trace entered rule cursor policy"
  - "does Lua generated source v2 use intrinsic cursor policy"
  - "when was Lua generated v1 compatibility behavior removed"
  - "does Lua still accept an explicit global parse mode"
  - "what tests prove Lua rule local cursor execution"
  - "do PUC Lua and LuaJIT execute rule local cursor identically"
date: 2026-07-19
status: verified and composed-admitted across both Lua ABIs
tags: [lua, luajit, runtime, cursor, rule-family, trace, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.7.2 derives family/cursor/sequence-choice once at every ordinary execute_rule entry. Live, loaded-default, normalized SpecFile JSON, recursive, and traced routes pass 110 neutral assertions per ABI over all 36 families, eight parent-child mechanisms, and two structural replacements after identical 44/110 RED failures. Six focused consumers pass 1,046 assertions per ABI. Generated v1 retains historical seek plus its validated legacy handler-family interpretation, and explicit outer policy remains accepted until their .4/.5 owners. Package is 176/177 per ABI with only staged help, primary remains 32/65x4, corpus is 105/105x2, and neutral governance is 68 files / 5 complete + 3 pending / 44 mutations after registering the new execution consumer."
evidence_update_2026_07_19_admission: "Generated v2 and public option removal close the staged seams. Admission .9.1.7.6 composes normal execution exactly once in one 15-role consumer on PUC Lua and LuaJIT; focused composition passes 119/119 per ABI and governance is 69/6+2/49."
reverify: 'puc=$(mktemp -d /private/tmp/linkedspec-lua-cursor-puc.XXXXXX); jit=$(mktemp -d /private/tmp/linkedspec-lua-cursor-jit.XXXXXX); trap "rm -rf $puc $jit" EXIT; bash tools/build_lua_native.sh puc "$puc" && bash tools/build_lua_native.sh luajit "$jit" && env LUA_PATH="lua/src/?.lua;lua/src/?/init.lua;;" LUA_CPATH="$puc/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME=lua lua lua/test/rule_local_cursor_execution_test.lua && env LUA_PATH="lua/src/?.lua;lua/src/?/init.lua;;" LUA_CPATH="$jit/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME=luajit luajit lua/test/rule_local_cursor_execution_test.lua && python3 tools/check_rule_local_cursor_contract.py'
---

## Fact

Normal Lua rule execution has one high-level authority: the family of the rule currently being entered.
`execute_rule(...)` derives one execution-policy table before lifecycle or matching work:

- exact AND family maps to consume plus ordered sequence;
- default/OR family maps to seek plus choice;
- every blind, action, direct-call, and recursive child receives the current cursor but derives again from its own
  compiled rule.

The derived policy is passed explicitly into specific-slot, alternation, regex, and blind execution. Low-level
seek/consume matcher APIs remain unchanged. An engine with no explicit `parse_mode` is intrinsic; loaded source and
ordinary normalized `SpecFile` JSON enter the same owner. Rule trace entries identify `family=and|or_default` and
`cursor_policy=consume|seek`, while regex decisions identify the policy that actually performed the match.

The former staged compatibility seams are now closed. An explicitly supplied outer `parse_mode` or `parseMode`
fails with the portable removal diagnostic. Generated-source v1 historically derived sequence/choice and dispatch
while defaulting to seek; `.9.1.7.4` replaced that versioned seam.
Generated-source v2 derives policy and structural dispatch from the validated family row, treats compact Pipe as
OR/choice, and carries no cursor field. Descriptor `.3`, generated v2 `.4`, public removal `.5`, and exact
dual-ABI admission `.6` are complete.

`lua/test/rule_local_cursor_execution_test.lua` reads the unchanged neutral JSON contract. It covers all 36
family spellings on live and normalized routes, all eight parent-child mechanisms, both structural replacements,
loaded execution, recursion, trace attribution, and generated-v2 policy agreement.
The registered driver executes the same consumer under separately built PUC Lua and LuaJIT native modules.

Related: [[lua-generated-source-v2-rule-local-cursor]], [[lua-rule-local-cursor-normalization]], [[lua-rule-local-cursor-descriptor]], [[lua-rule-local-cursor-preflight]],
[[rule-local-cursor-and-bare-edge-contract]], [[rule-local-cursor-neutral-contract]],
[[julia-rule-local-cursor-execution]], [[dart-rule-local-cursor-execution]], and
[[rust-rule-local-cursor-execution]].
