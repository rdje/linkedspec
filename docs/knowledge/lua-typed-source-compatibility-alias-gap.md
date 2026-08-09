---
id: lua-typed-source-compatibility-alias-gap
title: Lua implements all seven neutral source-boundary compatibility aliases through one shared canonical seam
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
  - "are the seven Lua source boundary compatibility aliases implemented now"
date: 2026-08-07
status: implemented by FUTURE-PARITY-BACKLOG.14.2.5.0.1 on PUC Lua and LuaJIT; typed-source RED remains pending .14.2.5.0.2
tags: [lua, PUC-Lua, LuaJIT, source-location, helpers, aliases, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.14.2.5.0.1 adds one private seven-name compatibility inventory beside Lua's shared 246 current names and one exact seven-row source-to-canonical map before existing alias resolution. Every spelling re-enters its preferred interpreter branch; there is no alias-specific runtime path. The ordinary consumer passes 638 assertions independently on PUC Lua and LuaJIT across exact 92+7 resolution, unchanged inventory size, unrelated structured diagnostics, Unicode widths, reversed-span absence, anonymous-boundary mutation, named maps, and native, loaded, reconstructed, generated-plan, and emitted carriers. Language coverage independently derives Lua's pairs and binds them to neutral. Typed source remains 7/7/41 and lua_dual_abi remains pending."
evidence_history_2026_08_07: "Audit FUTURE-PARITY-BACKLOG.14.2.5.0 originally proved 92/92 canonical names and 0/7 aliases on both ABIs; each missing spelling raised RuntimeInterpreterException at runtime_execution with owner lua_runtime and the exact unsupported-helper detail. That prerequisite caused the .0.1 split before dormant typed-source RED .0.2."
evidence_signoff_2026_08_07: "Complete Lua passes byte-fresh MCP 83166 bytes, alias 638/638 and package 177/177 on both ABIs, CLI 66x2, corpus 105/105, storage 18/3, and its exact marker. Five sole-facing book pages build as 79 files/14180 KiB with separate rendered blocks. Knowledge is 788/6489 and all seven doctrines pass. Definitive canonical CI preserves capability 80/0/0 and typed source 7/7/41, proves containment and relocation, passes CLI 66x2, reports RAM 59%, and passes Phase 0 1031/1031 in 659 seconds before the exact local-CI marker."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/source_boundary_compatibility_aliases_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/source_boundary_compatibility_aliases_test.lua && perl tools/check_language_capability_coverage.pl"
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

The shared Lua implementation recognizes and executes all 92 canonical source-boundary helpers. The prerequisite
audit first proved that none of these seven authored aliases was recognized. `.14.2.5.0.1` then added a separate
seven-name compatibility inventory beside—not inside—the common 246-name inventory, plus one exact canonical-name
map. Each alias now resolves to its preferred helper before the existing interpreter dispatch. PUC Lua and LuaJIT
execute the same result from the same Lua-5.1-compatible source.

The private `match_named_map` function in `interpreter.lua` does not contradict this finding. It implements the
map-shaped result for canonical `entry_map()` and `match_map()` dispatch; it is not an authored helper name and is
not visible through ActionIR validation or canonicalization.

Lua stores the validated decoded input in one invocation context. `RuntimeMatchRegisters` and
`RuntimeRegexMatch` retain that same source value while cursor, entry/local-match, anonymous-boundary, named-mark,
and save-stack positions remain zero-based UTF-8 byte offsets. `matching.lua` validates UTF-8 boundaries and
converts to Unicode-scalar positions or one-based line/column only at helper and public result seams. Native,
loaded, effective-SpecFile reconstructed, generated-v2-plan, and emitted routes all compile into and re-enter
`LinkedSpecRuntimeEngine`.

The repair is confined to the existing name-recognition/canonicalization boundary: one separate seven-name known-
alias inventory plus one exact alias-to-preferred map, followed by the existing interpreter branches. It does not
widen `CURRENT_CALL_NAMES`, duplicate helper execution, add typed source values, or promote `lua_dual_abi`. The
next leaf can therefore freeze a dormant dual-ABI typed-source consumer against an honest callable 92+7 baseline.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.14.2.5.0` and prerequisite `.14.2.5.0.1`.
- Neutral plan: [[typed-source-location-neutral-contract-plan]].
- Runtime rollout: [[typed-source-location-runtime-rollout-plan]].
- Runtime state: [[lua-runtime-matching-state]] and [[lua-capture-cursor-runtime-audit]].
- Carrier topology: [[lua-generated-source-family-plan]] and [[lua-native-spec-pipeline]].
