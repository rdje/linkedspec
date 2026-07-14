---
id: lua-runtime-anonymous-capture-helpers
title: Lua anonymous capture helpers share one byte-safe rolling rule-local boundary
answers:
  - does Lua execute the anonymous capture helper family
  - how does Lua store the anonymous capture boundary
  - are Lua capture positions and lengths bytes or Unicode characters
  - what endpoint does capture_slice use
  - what endpoint does capture_slice_until_cursor use
  - what endpoint does capture_rest use
  - when do capture_take helpers advance the anonymous boundary
  - what happens when an anonymous capture span is invalid
  - what does start_capture_slice return
  - why does Perl start_capture_slice differ from the public contract
date: 2026-07-13
status: current
tags: [lua, runtime, capture, Unicode, helper-contract, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.7.2 routes all 16 current anonymous capture calls through lua/src/linkedspec/interpreter.lua and the immutable register capture_start_byte. lua/test/run.lua locks every stable/advancing form, Unicode text/locations/lengths, valid-only mutation, value continuation, void setter behavior, and exact arity on PUC Lua and LuaJIT."
reverify: "bash tools/run_lua_local.sh"
---

## Fact

Lua keeps the anonymous capture boundary as a zero-based UTF-8 byte offset in
`RuntimeMatchRegisters.capture_start_byte`. Public positions and widths are
Unicode character counts; line and column values are 1-based. Rule entry derives
a fresh register frame, and rule exit restores the caller's registers, so the
rolling boundary is rule-local.

All 16 current calls use one interpreter dispatcher. `capture_slice*` and
`capture_take*` end at the current local match's left edge;
`*_until_cursor*` ends at the live cursor; `*_rest*` ends at input end. Stable
forms leave the boundary untouched. Successful `capture_take*` and
`capture_take_until_cursor*` reads move it to the live cursor; successful
`capture_take_rest*` reads move it to input end. Missing, reversed, or out-of-range
spans return `undef` and do not mutate the boundary.

`start_capture_slice()` moves the boundary to the live cursor and returns
`undef`/void. That is the public helper-catalog contract and the behavior of
Rust, Dart, Julia, and Lua. Current Perl lowering incidentally exposes its host
assignment expression's position result; `FUTURE-PARITY-BACKLOG.5` owns removing
that leak and adding a five-backend lock. The mdBook source-boundary table must
describe the language-level void result, not the Perl implementation accident.

Returned capture text and numeric metadata are ordinary values, so expressions
such as `capture_slice().uppercase()` and `capture_slice_len().add(1)` compose
through their type-appropriate receiver families. The capture helpers themselves
remain explicit function calls rather than receiver methods.

Related facts: [[spec-capture-mark-family-taxonomy]],
[[rust-anonymous-capture-slice-family]],
[[julia-anonymous-capture-boundary-helpers]],
[[dart-governed-capture-mark-parity]], [[lua-runtime-matching-state]].
