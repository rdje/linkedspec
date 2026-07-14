---
id: lua-complete-named-mark-parity
title: Lua executes the complete seven-helper named-mark contract on both ABIs
answers:
  - does Lua implement mark entry start and mark match end
  - does Lua implement mark line mark col and clear mark
  - how does Lua store named marks
  - are Lua named mark positions character based
  - are bare Lua mark names symbolic
  - are Lua named marks isolated between parent and child rules
  - why are Lua complete named mark names staged outside the shared 239 name inventory
date: 2026-07-14
status: current
tags: [lua, capture, marks, unicode, inventory, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.17.4 adds one parse-scoped rule-label/name/UTF-8-byte-offset store and exact staged seven-name set. lua/test/run.lua proves the unchanged linkedspec-complete-named-mark-v1 value through native and serialized SpecFile reconstruction. tools/run_lua_local.sh passes 119/119 on PUC Lua and LuaJIT plus syntax, CLI scaffold, and 105 manifest checks."
reverify: "python3 tools/check_complete_named_mark_contract.py && bash tools/run_lua_local.sh && perl tools/check_language_capability_coverage.pl --report"
---

# Lua Complete Named-Mark Parity

`FUTURE-PARITY-BACKLOG.17.4` makes Lua consume the unchanged
`capability_conformance/complete_named_mark_contract.json` fixture. Execution context owns one parse-scoped
`rule label -> mark name -> UTF-8 byte offset` store. The four entry/local writers reuse the existing immutable
match snapshots; `mark_pos`, `mark_line`, and `mark_col` convert only their public results to Unicode character
units; `clear_mark` removes only the current rule bucket's name. Bare identifiers such as `shared` remain symbolic
mark names rather than variable lookups. The already-inventoried `mark_input_end`, `mark_pos`, and `mark_exists`
calls are implemented as fixture bridges through this same state, not as a separate testing mechanism.

The input `é\nAβ\nZ` makes byte and character offsets differ. A child writes its own `shared` checkpoint without
replacing the parent's position 6, proving rule-label isolation. Native execution and reconstruction from public
serialized `SpecFile` state return the exact same value on PUC Lua and LuaJIT.

The exact seven names participate in known-call and capture/mark contract resolution through a staged set that is
disjoint from the legacy shared 239-name inventory. This preserves honest cross-backend equality until `.17.5`
admits all seven once and adds an independent public-current omission guard. Lua `.4.3.7.3` must extend this same
store and dispatcher for the remaining governed named spans and anonymous/named bridges.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.17.4`.
- Originating gap: [[complete-current-mark-inventory-gap]].
- Lua family audit: [[lua-capture-cursor-runtime-audit]].
- Exact Perl/Rust contract: [[complete-named-mark-perl-rust-parity]].
