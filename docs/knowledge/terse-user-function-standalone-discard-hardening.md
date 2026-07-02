---
id: terse-user-function-standalone-discard-hardening
title: SPEC-FORMAT-TERSE.4.2.3 Perl user-function standalone discard and hardening
answers:
  - "do standalone user function calls execute"
  - "do registered standalone user functions lower as VALUE_DROP"
  - "what does SPEC-FORMAT-TERSE.4.2.3 own"
  - "do recursive user functions diagnose"
  - "what happens to parser-state helpers inside user functions"
  - "do nested user function calls pass parameter values"
  - "do unknown standalone calls remain raw"
date: 2026-07-01
status: current
tags: [spec-format-terse, user-functions, actionir, value-drop, perl-reference]
evidence: "SPEC-FORMAT-TERSE.4.2.3 extends RuleIR::EmitContext registry threading to ActionIR::CanonicalEvents, where registered standalone call/fluent-chain statements are classified as canonical VALUE_DROP events before raw fallback. Contracts routes VALUE_DROP through MethodLowering so the function value is computed and discarded. MethodLowering also fixes nested user-function parameter arguments so wrap(value)->identity(value) passes $value. Phase0 subtest user_function_standalone_discard_and_hardening locks registered standalone calls/chains with zero raw/unresolved helpers, unregistered standalone calls as raw compatibility debt, direct/mutual recursion diagnostics, parser-state helper bodies, host-code-shaped bodies, and nested fn syntax diagnostics. Phase0 passes with 1007 tests."
reverify: "prove -Iperl t/phase0_regression.t && rg -n 'registered_user_function_value_drop|user_function_standalone_discard_and_hardening|VALUE_DROP' perl/LinkedSpec/ActionIR/CanonicalEvents.pm perl/LinkedSpec/ActionIR/Contracts.pm perl/LinkedSpec/ActionIR/MethodLowering.pm t/phase0_regression.t"
---

`SPEC-FORMAT-TERSE.4.2.3` closes the Perl reference `.4.2` user-function slice.

Registered standalone calls such as `normalize(" x ")` and registered standalone
receiver chains such as `normalize(" X ").lowercase()` now enter the canonical ActionIR
pipeline as `VALUE_DROP` events. The event classifier checks the compiled function
registry before raw fallback, so only known user functions use this path. The existing
value-drop lowerer computes the function result through `MethodLowering` and discards
it.

Unregistered standalone call-shaped statements such as `user_fn("x")` remain raw
compatibility debt. That boundary keeps host-shaped statements from being swept into
the user-function path merely because they parse as a call expression.

The leaf also locks hardening diagnostics. Direct recursion, mutual recursion,
parser-state helpers inside function bodies, host-code-shaped function bodies, and
nested `fn` syntax inside function bodies all produce deterministic unresolved-helper
metadata with zero raw fallback. Nested registered user-function calls now pass
function-local parameter values correctly, so a wrapper such as `wrap(value)` can call
`identity(value)` without lowering the bare parameter token as a string.
