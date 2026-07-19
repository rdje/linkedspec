---
id: lua-rule-local-cursor-descriptor
title: "Lua cursor descriptor v1 is a pure projection of normalized compiled state"
answers:
  - "does Lua descriptor publish cursor contract v1"
  - "what cursor metadata does the Lua descriptor expose"
  - "does Lua descriptor metadata still contain parse_mode"
  - "what fields are in Lua resolved edge descriptors"
  - "does Lua descriptor retain bare versus explicit source form"
  - "does Lua deserialize outward descriptors"
  - "does Lua descriptor survive normalized SpecFile JSON reconstruction"
  - "does loaded Lua descriptor match direct compilation"
  - "how is Lua descriptor cursor policy derived"
  - "what tests prove Lua cursor descriptor v1"
  - "do PUC Lua and LuaJIT descriptors agree"
date: 2026-07-19
status: verified implementation and composed admission through FUTURE-PARITY-BACKLOG.9.1.7.6
tags: [lua, luajit, descriptor, compiler, cursor, rule-family, loading, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.9.1.7.3 removes root meta.parse_mode and projects meta.cursor_contract=linkedspec-rule-local-cursor-v1. Every rule derives family, cursor_policy, edge_ownership, and ordered ownership/target/regex_index/block/fluent rows from exact mode metadata and normalized compiled action/blind tables. Handler label and rule label/line/is_top/mode retain source identity; optional source_form is omitted as non-semantic because compiled state does not retain it. Direct, normalized SpecFile-JSON, and loaded compilation produce identical descriptor bytes. Exact RED is 364/776 on both ABIs and focused green is 875/875; seven focused consumers total 1,921 assertions per ABI. Package 176/177, primary 32/65x4, corpus 105/105x2, and neutral 68/5+3/44 remain staged for later owners. KM 629/4,611, mdBook/four doctrines, and canonical Phase 0 1,031/1,031 in 621 seconds pass."
evidence_update_2026_07_19_admission: "Lua admission .9.1.7.6 composes descriptor v1 with every other cursor role exactly once in one 15-role consumer on PUC Lua and LuaJIT. Focused composition passes 119/119 per ABI and governance advances to 69 files / 6 complete + 2 pending / 49 mutations."
reverify: 'puc=$(mktemp -d /private/tmp/linkedspec-lua-descriptor-puc.XXXXXX); jit=$(mktemp -d /private/tmp/linkedspec-lua-descriptor-jit.XXXXXX); trap "rm -rf $puc $jit" EXIT; bash tools/build_lua_native.sh puc "$puc" && bash tools/build_lua_native.sh luajit "$jit" && env LUA_PATH="lua/src/?.lua;lua/src/?/init.lua;;" LUA_CPATH="$puc/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME=lua lua lua/test/rule_local_cursor_descriptor_test.lua && env LUA_PATH="lua/src/?.lua;lua/src/?/init.lua;;" LUA_CPATH="$jit/?.so;;" LINKEDSPEC_LUA_TEST_RUNTIME=luajit luajit lua/test/rule_local_cursor_descriptor_test.lua && python3 tools/check_rule_local_cursor_contract.py'
---

## Fact

Lua's outward descriptor uses the shared `rule_local_cursor_v1` metadata variant. Root metadata contains
`cursor_contract = linkedspec-rule-local-cursor-v1`, retains the independent entry-rule contract and established
order/count identities, and contains no `parse_mode` field.

Each rule projects only facts already present in normalized compiled state:

- `family` is `and` or `or_default` from exact authored mode metadata;
- `cursor_policy` is derived from family as `consume` or `seek`;
- `edge_ownership` is `action`, `blind`, `none`, or defensive `mixed` from the compiled tables; and
- `resolved_edges` contains exactly `ownership`, `target`, `regex_index`, `block`, and `fluent`.

Action rows publish the resolved child regex index, including zero when the authored index was omitted. Blind rows
publish JSON null because blind dispatch selects no child regex slot. Block presence comes from compiled edge code;
fluent calls render as one normalized dot chain; absent fluents are JSON null. Bare and explicit equivalent edges
converge. Lua omits optional `source_form`: ADR `0044` makes it non-semantic and compiled normalization does not
retain it.

There is no outward descriptor decoder and no descriptor-owned cursor input. The real reconstruction route
round-trips normalized `SpecFile` JSON and recompiles; file loading invokes the same compiler. Direct, normalized,
and loaded descriptors are byte-identical, and loaded live execution spends the same family-derived policy.
Invalid reconstructed edge state retains the portable validation diagnostic before descriptor projection.

`lua/test/rule_local_cursor_descriptor_test.lua` reads both neutral JSON contracts. Its 875 assertions cover all
36 family spellings, every valid edge and exact semantic row, every portable invalid edge/set case, exact root/
rule field sets, direct rule projection, direct/normalized/loaded byte identity, and loaded AND execution. The
driver runs the same consumer with separately built PUC Lua and LuaJIT modules. Generated source remains v1 and
the high-level outer option remains staged; neither compatibility seam appears in the descriptor.

Related: [[lua-rule-local-cursor-normalization]], [[lua-rule-local-cursor-execution]],
[[lua-rule-local-cursor-preflight]], [[julia-rule-local-cursor-descriptor]],
[[dart-rule-local-cursor-descriptor]], [[outward-compiled-descriptor-four-backend-contract]], and
[[rule-local-cursor-neutral-contract]].
