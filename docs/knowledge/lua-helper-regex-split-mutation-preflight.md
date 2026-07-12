---
id: lua-helper-regex-split-mutation-preflight
title: Lua regex/split parity has separate value, PCRE2 flag, scalar mutation, and array mutation seams
answers:
  - how is Lua regex split mutation work divided
  - does Lua ActionIR preserve regex flags
  - why does Lua matches currently fail
  - why does Lua statement regex substitution need statement context
  - what is the invalid helper regex boundary before Lua implementation
date: 2026-07-12
status: current
tags: [lua, runtime, regex, split, mutation, PCRE2, planning, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.2.2.0 projects ActionIR JSON for matches, pure split, substr/regex_subst mutation, and explicit array-target split; patterns, flags, bare targets, and array wrappers are preserved. LinkedSpec call_spec_handler_subst probes show distinct pure and statement lowering. lua/src/linkedspec/interpreter.lua currently has no regex ActionExpr evaluation and execute_block discards every statement through ordinary value evaluation, while lua/src/linkedspec/matching.lua already owns in-process PCRE2 compilation. The mdBook documents fail-closed invalid helper patterns, although a Perl invalid literal can fail generated parser compilation before runtime."
reverify: "rg -n 'kind == \"regex\"|compile_runtime_regex_alternation|execute_block|evaluate_expr|regex_subst|split' lua/src/linkedspec/action_parser.lua lua/src/linkedspec/interpreter.lua lua/src/linkedspec/matching.lua docs/tasks/LUA-BACKEND-PARITY.md"
---

## Fact

Lua parsing is not the blocker for regex-aware helpers. `action_parser.lua` emits `ActionExpr(kind="regex")` with
separate `pattern` and `flags` fields. Calls also retain bare scalar targets, flag words, and explicit
`array(target)` wrappers.

The missing runtime mechanisms are distinct:

1. `evaluate_expr` does not turn a regex AST value into a typed helper-regex value.
2. The existing PCRE2 owner compiles rule patterns but has no helper adapter that applies `i/m/s/x`, ignores `g/o`
   where appropriate, and rejects unknown flags.
3. `execute_block` evaluates every dropped call like a value expression, so it cannot distinguish pure
   `substr(value,start,width?)` from statement `substr(target,pattern,replacement,flags)` / `regex_subst(...)`.
4. Explicit `split(array(target),source,delimiter)` must replace an aggregate store, which is separate from both
   pure split values and scalar target mutation.

`LUA-BACKEND-PARITY.4.3.2.2.1` through `.5` own those mechanisms in that order. The documented invalid helper-regex
contract is fail-closed (`matches` false, pure split empty); a Perl syntactically invalid embedded literal can fail
earlier during generated parser compilation. That pre-existing reference boundary is recorded for honest parity
reasoning and does not authorize a mid-slice Perl engine change.
