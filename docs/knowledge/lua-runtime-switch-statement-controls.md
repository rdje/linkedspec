---
id: lua-runtime-switch-statement-controls
title: "Lua executes attached and marker switch statements through indexed ranges"
answers:
  - "does Lua execute attached switch case default statements"
  - "does Lua execute marker switch case default endcase endswitch statements"
  - "does Lua evaluate a switch subject once"
  - "how does Lua bound nested marker switches"
  - "what diagnostic does Lua use for malformed switch controls"
  - "what does LUA-BACKEND-PARITY.4.3.6.3.2 implement"
date: 2026-07-13
status: current
tags: [lua, runtime, actionir, control-flow, switch, diagnostics, parity]
evidence: "LUA-BACKEND-PARITY.4.3.6.3.2 adds attached switch validation and marker switch range selection to lua/src/linkedspec/interpreter.lua. Inline, attached, and marker forms share literal-label evaluation and scalar equality. lua/test/run.lua locks one-time subjects, first case/default, skipped fatal candidates/bodies, nested marker boundaries, optional endcase, empty branches, local return, null/boolean/aggregate comparison, and thirteen malformed/orphaned structures. PUC Lua and LuaJIT pass 107/107."
reverify: "bash tools/run_lua_local.sh && bash knowledge-map/scripts/check_knowledge_map.sh"
---

# Lua Runtime Switch-Statement Controls

Lua validates a complete switch structure before spending the subject. Attached switch reads typed branch bodies;
marker switch scans sibling statements to the matching same-depth `endswitch()`, with optional `endcase()` and
nested-switch depth. It then evaluates the subject once and executes only the first matching case range or one
default range through the shared indexed statement executor.

Bare case identifiers are literal labels. Inline, attached, and marker forms share the same scalar comparison;
see [[cross-backend-switch-scalar-comparison-drift]] for the unsettled cross-backend boundary.

Lua skips ordinary marker-switch statements outside every case/default range, matching Rust, Dart, and Julia but
not Perl. Portable placement and normalization ownership are recorded in
[[marker-switch-outside-branch-statement-drift]].

Malformed structure raises a runtime interpreter error with:

- `code = "malformed_statement_control"`
- `control_keyword`
- `reason`
- `action_kind`
- `rule_label`

## Links

- Owner: [[LUA-BACKEND-PARITY]] `.4.3.6.3.2`.
- Next statement-control leaf: [[LUA-BACKEND-PARITY]] `.4.3.6.3.3`.
