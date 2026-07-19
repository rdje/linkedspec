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
  - "does Lua generated source v1 use intrinsic cursor policy"
  - "why does Lua keep generated v1 compatibility behavior"
  - "does Lua still accept an explicit global parse mode"
  - "what tests prove Lua rule local cursor execution"
  - "do PUC Lua and LuaJIT execute rule local cursor identically"
date: 2026-07-19
status: verified normal execution and descriptor v1; generated-v2, option removal, and admission remain staged
tags: [lua, luajit, runtime, cursor, rule-family, trace, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.7.2 derives family/cursor/sequence-choice once at every ordinary execute_rule entry. Live, loaded-default, normalized SpecFile JSON, recursive, and traced routes pass 110 neutral assertions per ABI over all 36 families, eight parent-child mechanisms, and two structural replacements after identical 44/110 RED failures. Six focused consumers pass 1,046 assertions per ABI. Generated v1 retains historical seek plus its validated legacy handler-family interpretation, and explicit outer policy remains accepted until their .4/.5 owners. Package is 176/177 per ABI with only staged help, primary remains 32/65x4, corpus is 105/105x2, and neutral governance is 68 files / 5 complete + 3 pending / 44 mutations after registering the new execution consumer."
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

Two staged compatibility seams remain deliberate. An explicitly supplied outer `parse_mode` still overrides
ordinary rule cursor policy until `.9.1.7.5` removes that high-level surface. Generated-source v1 derives
sequence/choice and dispatch from its validated legacy handler-family row and defaults to historical seek until
`.9.1.7.4`; this keeps compact Pipe as generated-v1 AND/sequence even though ordinary compiled Pipe is now
OR/choice. At runtime closeout, descriptor v1, generated-source v2, public removal, and exact dual-ABI admission
remained `.3-.6`, so that slice did not advance neutral rollout. Descriptor `.3` is now complete as a pure
projection; generated v2, public removal, and exact dual-ABI admission remain `.4-.6`.

`lua/test/rule_local_cursor_execution_test.lua` reads the unchanged neutral JSON contract. It covers all 36
family spellings on live and normalized routes, all eight parent-child mechanisms, both structural replacements,
loaded execution, recursion, trace attribution, explicit outer compatibility, generated-v1 historical seek, and
generated-v1 compact-Pipe family isolation. The registered driver executes the same consumer under separately
built PUC Lua and LuaJIT native modules.

Related: [[lua-rule-local-cursor-normalization]], [[lua-rule-local-cursor-descriptor]], [[lua-rule-local-cursor-preflight]],
[[rule-local-cursor-and-bare-edge-contract]], [[rule-local-cursor-neutral-contract]],
[[julia-rule-local-cursor-execution]], [[dart-rule-local-cursor-execution]], and
[[rust-rule-local-cursor-execution]].
