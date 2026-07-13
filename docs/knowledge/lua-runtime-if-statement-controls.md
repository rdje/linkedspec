---
id: lua-runtime-if-statement-controls
title: "Lua executes attached and marker if statements through one indexed range executor"
answers:
  - "does Lua execute attached if elseif else statements"
  - "does Lua execute marker if elseif else endif statements"
  - "how does Lua select statement if branches"
  - "does Lua support nested marker if chains"
  - "what diagnostic does Lua use for orphaned if controls"
  - "what does LUA-BACKEND-PARITY.4.3.6.3.1 implement"
date: 2026-07-13
status: current
tags: [lua, runtime, actionir, control-flow, diagnostics, parity]
evidence: "LUA-BACKEND-PARITY.4.3.6.3.1 adds execute_statement_at/execute_statement_range, attached-chain selection, and nesting-aware marker-chain selection to lua/src/linkedspec/interpreter.lua. One lua/test/run.lua case covers selected-only execution, fatal skipped paths, portable aliases, empty branches, nested markers, action and block-local return, and malformed/orphaned controls. PUC Lua and LuaJIT pass 106/106."
reverify: "bash tools/run_lua_local.sh && bash knowledge-map/scripts/check_knowledge_map.sh"
---

# Lua Runtime If-Statement Controls

Lua block execution is index-based rather than a plain statement iterator. At an attached `if`, it consumes the
consecutive attached branches and executes the first truthful body. At a marker `if`, it validates and scans to
the matching same-depth `endif`, preserving nested marker chains, then executes only the selected statement range.

The same executor serves ordinary action/lifecycle blocks and expression-valued blocks. A selected `return(...)`
therefore exits the surrounding action block normally, while the expression-block boundary catches it as a local
block result.

Malformed structure raises a runtime interpreter error with:

- `code = "malformed_statement_control"`
- `control_keyword`
- `reason`
- `action_kind`
- `rule_label`

Portable aliases are `i/elif` for marker chains and `when/otherwise` for attached chains. See
[[if-statement-alias-shape-portability]] for the broader backend drift.

## Links

- Owner: [[LUA-BACKEND-PARITY]] `.4.3.6.3.1`.
- Next statement-control leaf: [[LUA-BACKEND-PARITY]] `.4.3.6.3.2`.
