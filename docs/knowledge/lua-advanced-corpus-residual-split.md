---
id: lua-advanced-corpus-residual-split
title: Lua advanced corpus starts at 50/59 with four measured runtime mechanisms
answers:
  - how many Lua advanced corpus fixtures pass before repair
  - which Lua offsets 40 through 98 fail
  - why do Lua HLink EBNF and SimEnv execute child rules twice
  - does Lua call child reuse the current action edge result
  - why does Lua meta copy flat hash count return zero
  - does Lua receiver copy preserve its receiver
  - why does Lua pplugin empty return a table address key
  - does flat array splice into Lua hash construction
  - why does Lua ds vhistory return the object name
  - where are Lua advanced corpus residuals routed
date: 2026-07-15
status: current
tags: [lua, corpus, action-edge, receiver, harray, leading-trivia, toolbox, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.6.2.0 executes exact manifest offsets 40-98 through the production library executor with debug trace on disposable PUC Lua and LuaJIT PCRE2 adapters. Both ABIs pass the same 50/59 and expose the same nine residuals. Canonical Perl dump_parser_source and return_descriptor probes prove four current Lua mechanisms: call(child) bypasses the current action-edge cache and triggers fallback double execution; receiver .copy() drops the evaluated harray; hash(flat_array(defs)) fails to splice flat_array tokens; and runtime_parse starts at byte zero rather than the Perl public wrapper's leading blank/comment boundary. Repairs are split under .6.2.1-.4; .6.2.5 remeasures successor residuals before .6.2.6 permanent admission."
reverify: "bash tools/run_lua_local.sh && rg -n 'dispatch_edge_child|elseif name == \"call\"|HASH_SPLICE_HELPERS|kind == \"fluent_chain\"|runtime_parse' lua/src/linkedspec/interpreter.lua"
---

The exact zero-based manifest window at offsets 40-98 contains 59 advanced
helper, function, recursion, and shipped-spec fixtures. Before its repair
children, PUC Lua and LuaJIT agree at 50/59. The nine residuals are:

- compare: `terse_2_3_5_2_hash_receiver_value_chains`;
- execute: `hlink_curly_brace`, `hlink_bracket_body`, and
  `hlink_mixed_bracket_brace`;
- compare: `ebnf_expression_rules` and `ebnf_logging_annotation`;
- execute: `simenv_multiline_value`;
- compare: `ds_vhistory_version_entry` and `pplugin_empty`.

Production debug trace shows all three HLink cases, both EBNF cases, and SimEnv
entering the selected action-edge child twice. Lua's generic `call(child)` path
executes the rule directly and does not mark the current edge child as
dispatched; `accept_match(...)` therefore performs its fallback dispatch.
Canonical generated Perl invokes that selected child only once. Repair leaf
`.6.2.1` owns cached action-edge call reuse and must remeasure the window because
statement mutation may become the next visible EBNF/SimEnv layer.

The three independent compare mismatches have separate owners:

- `.6.2.2`: receiver-form `meta.copy()` currently calls zero-argument `copy`
  and loses the evaluated harray before `.flat_hash().count_keys()`;
- `.6.2.3`: `hash(flat_array(defs))` treats the flattened array as one Lua
  table key because `flat_array` is absent from hash-splice classification;
- `.6.2.4`: public `runtime_parse(...)` starts history at byte zero, whereas
  the Perl public wrapper skips leading blank/comment lines before its top
  handler.

No expected value is backend-local or weakened. Successor measurement `.6.2.5`
must classify any residual with the Knowledge Map and LinkedSpec toolbox before
more behavior changes; `.6.2.6` alone owns permanent 59/59 admission.

Related facts: [[rust-action-edge-child-return-dispatch]],
[[julia-action-edge-child-push]], [[julia-statement-regex-mutation]],
[[ds-vhistory-leading-newline-oracle-boundary]],
[[terse-hash-receiver-value-chains]], [[pplugin-pluginbridge-transition-machinery]].
