---
id: cross-backend-attached-while-boundary-drift
title: "Attached while exact-limit and next behavior differs across backends"
answers:
  - "does a while loop succeed if it becomes false exactly at the iteration limit"
  - "what does next do inside attached while"
  - "which backends recheck while after the final allowed body"
  - "which task owns while limit and next normalization"
  - "may portable while bodies use next"
date: 2026-07-13
status: current
tags: [while, next, safety, perl, rust, dart, julia, lua, parity]
evidence: "LUA-BACKEND-PARITY.4.3.6.3.3 Perl call_spec_handler_subst shows the guard increment/check after each true condition and before the body, so a condition that becomes false after body 10000 succeeds; Rust execute_statement_while_loop has the same shape. Dart _executeAttachedWhileStatement and Julia _execute_runtime_attached_while! throw after their bounded for-loop without rechecking. Generated Perl next continues the host while; Lua now catches its next flow at the loop boundary, Rust evaluates next as undefined/no-op, and Dart/Julia rethrow action-next to rule repetition. FUTURE-PARITY-BACKLOG.5 owns normalization."
reverify: "perl -Iperl -MLinkedSpec -e 'print LinkedSpec::call_spec_handler_subst(q{Top}, q{count = 0; while(num_lt(count,3)) { count = num_add(count,1); next() }; return(count)}), qq{\\n}' && rg -n 'execute_statement_while_loop|_executeAttachedWhileStatement|_execute_runtime_attached_while|execute_attached_while' rust/linkedspec-runtime/src/engine.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua"
---

# Cross-Backend Attached While Boundary Drift

All five backends run attached while conditions lazily and expose body mutation to the next check, but two edge
semantics differ:

| Boundary | Perl | Rust | Dart | Julia | Lua |
| --- | --- | --- | --- | --- | --- |
| condition becomes false exactly after final allowed body | succeeds | succeeds | throws | throws | succeeds |
| statement `next()` inside body | continues inner loop | no-op | propagates to rule repetition | propagates to rule repetition | continues inner loop |

Portable specs should terminate comfortably before the guard and avoid `next()` inside attached while until
[[FUTURE-PARITY-BACKLOG]] `.5` selects and locks one rule. Use an explicit condition/update structure instead.

## Links

- Lua discovery/implementation: [[LUA-BACKEND-PARITY]] `.4.3.6.3.3`.
- Lua mechanism: [[lua-runtime-attached-while-controls]].
- Original Perl/Rust contract: [[terse-attached-while-split-ground-truth]].
- Normalization owner: [[FUTURE-PARITY-BACKLOG]] `.5`.
