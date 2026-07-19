---
id: lua-rule-local-cursor-normalization
title: "Lua retains typed bare edges and exact authored family identity before cursor execution migration"
answers:
  - "does Lua parse bare rule edges"
  - "where does Lua normalize bare edge ownership"
  - "how does Lua classify compact pipe now"
  - "where are Lua cursor normalization diagnostics represented"
  - "does Lua reject indexed blind calls"
  - "what is BareEdgeBodyElementKind in Lua"
  - "how does Lua preserve omitted index versus authored zero"
  - "what tests prove Lua bare edge normalization"
  - "do PUC Lua and LuaJIT normalize cursor edges identically"
  - "which Lua leaf changes live cursor execution"
  - "does Lua generated source v1 still classify compact pipe as AND"
  - "does Lua cursor normalization advance rollout"
date: 2026-07-19
status: verified normalization; live cursor execution is verified under FUTURE-PARITY-BACKLOG.9.1.7.2
tags: [lua, luajit, dsl, cursor, bare-edge, parser, compiler, validation, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "Lua now classifies compact `|` as authored OR/default and `&` as authored AND; retains complete-line/header-rest bare targets as BareEdgeBodyElementKind with nullable authored indices; validates all six neutral edge diagnostics through SpecValidationException code/stage/fields; and lowers family-derived ownership into compiled action/blind tables. The focused neutral consumer passes 258 assertions identically on PUC Lua and LuaJIT over all 36 family rows, all 18 edge rows, all six ownership sets, AST/diagnostic JSON roundtrips, and physical-line boundaries. The package remains at only the pre-existing 176/177 shared-help mismatch per ABI, all four primary legs remain exactly 32/65, corpus remains 105/105 per ABI, and no rollout row advances. Runtime cursor spending is now implemented by .2; descriptor v1, generated-source v2, option removal, and admission remain .3-.6. Generated-source v1 deliberately retains its staged compact-Pipe AND classifier until .4."
evidence_update_2026_07_19_generated_v2: "Generated-source .9.1.7.4 now consumes this normalized Pipe identity as OR/choice under v2 and derives cursor policy from minimal family rows; the historical v1 isolation described below is closed."
reverify: "env LUA_PATH='lua/src/?.lua;lua/src/?/init.lua;;' lua lua/test/rule_local_cursor_normalization_test.lua && env LUA_PATH='lua/src/?.lua;lua/src/?/init.lua;;' luajit lua/test/rule_local_cursor_normalization_test.lua && python3 tools/check_rule_local_cursor_contract.py"
---

Lua syntax and compiled normalization now have four exact seams shared by PUC Lua and LuaJIT:

- `lua/src/linkedspec/spec_ast.lua` makes `rule_mode_is_and(...)` authored-family exact: compact `|` is
  OR/default and compact `&` is AND. `BareEdgeBodyElementKind` retains bare provenance, while
  `BareEdgeTarget.index` remains nullable so an omitted target slot stays distinct from authored `[0]` through
  AST JSON.
- `lua/src/linkedspec/spec_parser.lua` recognizes a bare plain, indexed, grouped, block, or fluent candidate only
  when it begins a complete physical body line or the rule-header rest. Lifecycle markers are recognized first,
  forward declarations do not need to be known while parsing, and explicit blind syntax retains an authored
  index for targeted validation rather than leaving its suffix as raw syntax.
- `lua/src/linkedspec/spec_validator.lua` resolves bare targets against the complete declared-label set. AND bare
  edges own blind dispatch and OR/default bare edges own action dispatch. Invalid shape or mixed ownership raises
  a JSON-projectable `SpecValidationException` with the neutral code, stage, message, and exact typed fields.
- `lua/src/linkedspec/compiled_spec.lua` lowers valid bare AND edges into the existing compiled blind table and
  valid bare OR/default edges into the existing compiled action table. Target order, indices, blocks, fluent
  calls, dependency refs, explicit ownership overrides, source text, and source form remain typed.

The six portable edge codes are `bare_edge_target_undefined`, `bare_edge_index_requires_action`,
`bare_edge_group_requires_action`, `mixed_edge_ownership`, `grouped_action_shared_block_required`, and
`blind_call_index_forbidden`. Lifecycle names retain lexical priority; an edge to a same-named rule must use
explicit `->` or `=>` syntax.

Normalization deliberately stopped at AST, validation, and compiled ownership in `.9.1.7.1`. The following `.2`
runtime slice now derives ordinary entered-rule policy from that compiled identity; descriptor state still
publishes its old global field until `.3`, generated artifacts remain v1/format 1 until `.4`, and high-level
API/CLI overrides remain until `.5`. In
particular, generated-v1 classification still maps the authored `Pipe` mode name to its legacy AND structural
family even though normal compiled metadata now records `is_and = false`. That isolation prevents this syntax
slice from silently migrating a versioned artifact.

`lua/test/rule_local_cursor_normalization_test.lua` reads the unchanged neutral contract directly and does not
load the native matcher module. Its 258 assertions therefore run quickly under both Lua ABIs while still testing
the exact AST/parser/validator/compiler owners. The complete native package and corpus remain separate real-module
proofs; their unchanged staged results show the slice did not pull runtime, descriptor, generated, or public
option work forward.

Related: [[lua-rule-local-cursor-execution]], [[lua-rule-local-cursor-preflight]], [[rule-local-cursor-and-bare-edge-contract]],
[[rule-local-cursor-neutral-contract]], [[julia-rule-local-cursor-normalization]], and
[[FUTURE-PARITY-BACKLOG]].
