---
id: lua-unknown-runtime-helper-diagnostic-gap
title: Lua ordinary unknown-helper fallback retains text and rule but omits a diagnostic code
answers:
  - "does Lua ordinary unknown helper include a diagnostic code"
  - "why is Lua minimum error preservation qualified"
  - "who owns Lua unknown helper diagnostic parity"
date: 2026-10-29
status: P2 owned39.4.8 after bounded features before full admission
tags: [lua, luajit, diagnostic, unknown-helper, minimum, qualification]
evidence: "Lua39.4.3 actual12-source baseline real_error on both installed hosts retains unsupported runtime helper text, Atom rule/runtime phase, no code; initial unqualified peer oracle and corrected preservation proof retained in lua-minimum-intake.json.gz."
reverify: "Use retained Lua minimum real_error source/probe on puc and luajit; diagnose actual public output before adopting any peer code oracle."
---

Both installed hosts' ordinary unknown_minimum_probe() in Atom fail closed with
RuntimeInterpreterException and diagnostic rule Atom/runtime_execution, but code
is absent. interpreter.lua ordinary fallback calls fail with helper_name only;
wrapping preserves the message/rule/phase and cannot invent a code. Initial Dart
unknown_helper oracle is unqualified for Lua, not an owned minimum regression.
The minimum slice preserves actual error text/rule/phase and exact before-after
identity. Initial fixture/log/receipt remain retained, no invalid product RED.

P2 TYPE-REFERENCE-BOOK.1.2.23.3.39.4.8 owns public authority reconciliation and
typed repair, plus exact native/restored/generated/fresh and callable controls
after bounded feature coverage and before admission/push. The separate callable-
codeblock unknown-helper branch already supplies unknown_helper; this contrasts
with the ordinary fallback. One ordinary case does not establish a full route
population or a completed repair. No global error catch.
