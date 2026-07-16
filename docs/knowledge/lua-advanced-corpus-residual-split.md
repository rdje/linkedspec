---
id: lua-advanced-corpus-residual-split
title: Lua advanced corpus moved from 50/59 to a zero-residual 59/59
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
  - do all Lua advanced corpus fixtures pass
  - what is the Lua advanced corpus zero residual boundary
  - which leaf proved Lua advanced corpus has no residual
date: 2026-07-15
status: current
tags: [lua, corpus, action-edge, receiver, harray, leading-trivia, toolbox, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.6.2.0 executed exact manifest offsets 40-98 through the production library executor with debug trace on disposable PUC Lua and LuaJIT PCRE2 adapters. Both ABIs passed the same 50/59 and exposed the same nine residuals. Canonical Perl dump_parser_source and return_descriptor probes proved four Lua mechanisms: call(child) bypassed the current action-edge cache and triggered fallback double execution; receiver .copy() dropped the evaluated harray; hash(flat_array(defs)) lacked flat-array hash-splice classification; and runtime_parse starts at byte zero rather than the Perl public wrapper's leading blank/comment boundary. LUA-BACKEND-PARITY.6.2.1 repaired current-edge call reuse plus passive terminals and raised both ABIs to 56/59; .6.2.2 preserved receiver copy values and raised them to 57/59; .6.2.3 added flat-array hash splicing and raised them to 58/59; .6.2.4 mirrored the public leading-trivia boundary and raised them to 59/59 with no successor residual. LUA-BACKEND-PARITY.6.2.5 independently revalidated the full 105-case manifest and selected exact offsets 40-98 through separately built PUC Lua and LuaJIT adapters: both report first `terse_2_2_6_2_attached_while_blocks`, last `lib_reader_cattribute`, 59 passes, zero failures, and true aggregate status."
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
`.6.2.1` now caches current-edge calls and skips passive-terminal re-search. All
six cases pass unchanged and the window is 56/59 on both ABIs; Lua's already-
implemented statement regex mutation was not a successor blocker.

The three independent compare mismatches have separate owners:

- `.6.2.2` (done): receiver-form `meta.copy()` now deep-copies the evaluated
  harray before `.flat_hash().count_keys()`;
- `.6.2.3` (done): `hash(flat_array(defs))` now splices the flattened array
  as ordered copied key/value tokens instead of using one Lua table key;
- `.6.2.4` (done): public `runtime_parse(...)` now skips the same complete
  leading blank/comment lines as the Perl public wrapper before its top handler.

No expected value is backend-local or weakened. The four repairs reach 59/59.
Independent `.6.2.5` successor measurement validates the complete manifest before
selection and confirms the exact 59-case order, 59 passes, zero failures, and true
aggregate status on both ABIs. There is no repair child; `.6.2.6` owns permanent
59/59 admission.

Related facts: [[rust-action-edge-child-return-dispatch]],
[[julia-action-edge-child-push]], [[julia-statement-regex-mutation]],
[[ds-vhistory-leading-newline-oracle-boundary]],
[[terse-hash-receiver-value-chains]], [[pplugin-pluginbridge-transition-machinery]],
[[lua-action-edge-child-call-reuse]], [[lua-receiver-copy-value-preservation]],
[[lua-flat-array-hash-splicing]].
