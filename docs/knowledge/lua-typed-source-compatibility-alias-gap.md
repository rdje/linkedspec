---
id: lua-typed-source-compatibility-alias-gap
title: Lua is missing all seven neutral source-boundary compatibility aliases before typed-source implementation
answers:
  - "does Lua execute all seven typed source location compatibility aliases"
  - "which typed source compatibility aliases are missing in Lua"
  - "does Lua capture_from_rule_start match capture_slice"
  - "does Lua capture_len_from_rule_start match capture_slice_len"
  - "does Lua capture_rest_length match capture_rest_len"
  - "does Lua capture_slice_here match start_capture_slice"
  - "does Lua capture_slice_length match capture_slice_len"
  - "does Lua entry_named_map match entry_map"
  - "does Lua match_named_map match match_map"
  - "why must Lua alias parity precede the typed source RED"
  - "where does Lua store source cursor mark and match offsets"
  - "do PUC Lua and LuaJIT share source boundary helper code"
  - "do Lua loaded generated and emitted parsers use the same helper interpreter"
date: 2026-08-07
status: exact seven-alias prerequisite measured by FUTURE-PARITY-BACKLOG.14.2.5.0; implementation pending .14.2.5.0.1
tags: [lua, PUC-Lua, LuaJIT, source-location, helpers, aliases, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.2.5.0 retrieves ADR 0056, the neutral contract/checker, Lua authority cards, exact shared source/tests/drivers, prior runtime precedents, and the sole-facing book before probing. One identical repository-routed command on PUC Lua and LuaJIT proves all 92 canonical source-boundary rows are unique, known, canonically stable, and contract-resolvable, but zero of seven aliases is known or canonicalized. Each authored alias executes through a compiled spec far enough to throw RuntimeInterpreterException at runtime_execution with owner lua_runtime, rule Top, and exact unsupported runtime helper '<name>' detail. The complete unchanged shared suite passes 177/177 per ABI. The audit therefore splits alias parity .14.2.5.0.1 before dormant dual-ABI typed RED .14.2.5.0.2 without production, test, or neutral 7/7/41 movement."
reverify: "bash tools/run_lua_project_data.sh puc -e 'local l=require(\"linkedspec\"); local j=require(\"linkedspec.json\"); local f=assert(io.open(\"capability_conformance/typed_source_location_contract.json\",\"rb\")); local c=j.decode(f:read(\"*a\")); f:close(); local n=0; for _,family in ipairs(c.helper_projection_schema.families) do for _,row in ipairs(c.helper_projections[family]) do assert(l.is_known_action_ir_call_name(row[1])); assert(l.canonical_action_helper_name(row[1])==row[1]); n=n+1 end end; local missing=0; for _,row in ipairs(c.compatibility_aliases) do assert(not l.is_known_action_ir_call_name(row[1])); assert(l.canonical_action_helper_name(row[1])==row[1]); missing=missing+1 end; assert(n==92 and missing==7)' && bash tools/run_lua_project_data.sh luajit -e 'local l=require(\"linkedspec\"); local j=require(\"linkedspec.json\"); local f=assert(io.open(\"capability_conformance/typed_source_location_contract.json\",\"rb\")); local c=j.decode(f:read(\"*a\")); f:close(); local n=0; for _,family in ipairs(c.helper_projection_schema.families) do for _,row in ipairs(c.helper_projections[family]) do assert(l.is_known_action_ir_call_name(row[1])); assert(l.canonical_action_helper_name(row[1])==row[1]); n=n+1 end end; local missing=0; for _,row in ipairs(c.compatibility_aliases) do assert(not l.is_known_action_ir_call_name(row[1])); assert(l.canonical_action_helper_name(row[1])==row[1]); missing=missing+1 end; assert(n==92 and missing==7)'"
---

# Lua source-boundary compatibility-alias gap

The neutral typed-source contract defines seven callable compatibility aliases:

- `capture_from_rule_start()` → `capture_slice()`;
- `capture_len_from_rule_start()` → `capture_slice_len()`;
- `capture_rest_length()` → `capture_rest_len()`;
- `capture_slice_here()` → `start_capture_slice()`;
- `capture_slice_length()` → `capture_slice_len()`;
- `entry_named_map()` → `entry_map()`; and
- `match_named_map()` → `match_map()`.

The shared Lua implementation recognizes and executes all 92 canonical source-boundary helpers, but it currently
recognizes none of these seven authored aliases. `action_call_names.lua` omits them from both the common 246-name
inventory and any separate compatibility inventory. `action_contracts.lua` has no corresponding canonical-name
rows. Each alias therefore remains unchanged through canonicalization, receives an `unknown_helper` contract
diagnostic, and reaches the shared interpreter's exact structured unsupported-helper failure when invoked from a
compiled spec. PUC Lua and LuaJIT produce the same result from the same Lua-5.1-compatible source.

The private `match_named_map` function in `interpreter.lua` does not contradict this finding. It implements the
map-shaped result for canonical `entry_map()` and `match_map()` dispatch; it is not an authored helper name and is
not visible through ActionIR validation or canonicalization.

Lua stores the validated decoded input in one invocation context. `RuntimeMatchRegisters` and
`RuntimeRegexMatch` retain that same source value while cursor, entry/local-match, anonymous-boundary, named-mark,
and save-stack positions remain zero-based UTF-8 byte offsets. `matching.lua` validates UTF-8 boundaries and
converts to Unicode-scalar positions or one-based line/column only at helper and public result seams. Native,
loaded, effective-SpecFile reconstructed, generated-v2-plan, and emitted routes all compile into and re-enter
`LinkedSpecRuntimeEngine`.

The narrow repair belongs at the existing name-recognition/canonicalization boundary: one separate seven-name
known-alias inventory plus one exact alias-to-preferred map, followed by the existing interpreter branches. It must
not widen `CURRENT_CALL_NAMES`, duplicate helper execution, add typed source values, or promote `lua_dual_abi`.
Only after that parity leaf lands can a dormant dual-ABI typed-source consumer honestly freeze a callable 92+7
baseline.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.14.2.5.0` and prerequisite `.14.2.5.0.1`.
- Neutral plan: [[typed-source-location-neutral-contract-plan]].
- Runtime rollout: [[typed-source-location-runtime-rollout-plan]].
- Runtime state: [[lua-runtime-matching-state]] and [[lua-capture-cursor-runtime-audit]].
- Carrier topology: [[lua-generated-source-family-plan]] and [[lua-native-spec-pipeline]].
