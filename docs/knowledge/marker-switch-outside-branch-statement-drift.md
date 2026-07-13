---
id: marker-switch-outside-branch-statement-drift
title: "Marker-switch statements outside case/default branches differ across backends"
answers:
  - "what happens to a statement before the first marker switch case"
  - "what happens after endcase before endswitch"
  - "may portable specs put statements outside marker switch branches"
  - "why does Perl execute a marker switch statement that other backends skip"
  - "which task owns marker switch outside branch semantics"
date: 2026-07-13
status: current
tags: [switch, markers, control-flow, perl, rust, dart, julia, lua, parity]
evidence: "During LUA-BACKEND-PARITY.4.3.6.3.2, call_spec_handler_subst probes showed Perl lowering ordinary statements before the first case and after explicit endcase outside any conditional branch, so they execute whenever the containing action is active. Rust StatementSwitchFrame starts current_active=false and restores it only inside a matching case/default; Dart/Julia nesting-aware range selectors and Lua's new indexed selector execute only a selected branch range. A Lua fatal-skip lock passes at 107/107. FUTURE-PARITY-BACKLOG.5 owns normalization."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(q{Top}, q{switch(\"x\"); set(out, \"before\"); case(x); set(out, \"hit\"); endcase(); set(out, \"after\"); endswitch()}), qq{\\n}' && bash tools/run_lua_local.sh"
---

# Marker-Switch Outside-Branch Statement Drift

Marker switch has an unsettled placement boundary:

- Perl executes ordinary statements before the first `case/default` and after an explicit `endcase()` as
  unconditional statements inside the surrounding action.
- Rust, Dart, Julia, and Lua execute only a selected case/default range, so those outside statements are skipped.

This is not the same as a skipped later case body; the statement is structurally outside every branch. Portable
specs must keep every executable statement between a `case/default` marker and its boundary. Do not use an outer
marker-switch region as an unconditional statement carrier.

[[FUTURE-PARITY-BACKLOG]] `.5` must choose one rule and lock it across all backends, preferably explicit rejection
or an explicit documented execution model rather than preserving silent host-dependent behavior.

## Links

- Discovery: [[LUA-BACKEND-PARITY]] `.4.3.6.3.2`.
- Normalization owner: [[FUTURE-PARITY-BACKLOG]] `.5`.
- Lua mechanism: [[lua-runtime-switch-statement-controls]].
