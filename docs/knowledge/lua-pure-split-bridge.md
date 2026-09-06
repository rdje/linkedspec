---
id: lua-pure-split-bridge
title: Lua pure split returns copied typed arrays for literal, regex, Unicode, and receiver forms
answers:
  - does Lua support pure split helper
  - does Lua split preserve trailing empty fields
  - does Lua split empty delimiter by Unicode characters
  - does Lua split support regex flags
  - how does Lua regex split handle zero width
  - does Lua string receiver split mutate its source
date: 2026-07-12
status: current
tags: [lua, runtime, split, regex, Unicode, receiver, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.2.2.2 adds split_unicode_characters, split_literal, and split_regex in lua/src/linkedspec/interpreter.lua and admits split through function/string-receiver pure evaluation. lua/test/run.lua proves literal leading/trailing empties, PCRE2 delimiters and flags, UTF-8 scalar empty-delimiter splitting, zero-width progress, receiver typing/non-mutation, fail-closed invalid boundaries, and separate substr/replace_substr behavior. PUC Lua and LuaJIT pass 74/74."
reverify: "bash tools/run_lua_local.sh"
---

## Fact

Lua pure `split(value, delimiter)` returns a fresh typed array and never mutates its source. A scalar delimiter is
literal and preserves leading/trailing empty fields. An empty literal delimiter walks strict UTF-8 scalars rather
than bytes. A regex delimiter reuses the helper PCRE2/flag adapter; unknown flags, invalid patterns, and non-text
inputs produce an empty typed array.

Regex split keeps separate segment and search cursors. A zero-width delimiter advances the search cursor by one
decoded Unicode scalar while retaining the segment boundary, matching lookahead-style splits without looping or
dropping text. String receiver `.split(...)` returns the same typed array. Downstream array methods are deliberately
owned by active `.4.3.4`; statement scalar regex mutation is closed under `.4.3.2.2.3`.

The September 6 empty-source comparison in [[tagged-record-evaluation-and-split-drift]] returns one empty
item on PUC Lua and no items on Perl. `SESSION-STARTUP-READING.33` owns review and repair; the original
split admission is not proof that this edge agrees across runtimes.
