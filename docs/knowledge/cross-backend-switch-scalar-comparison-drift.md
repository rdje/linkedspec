---
id: cross-backend-switch-scalar-comparison-drift
title: "Switch boolean/number and aggregate scalar comparison differs across backends"
answers:
  - "does switch false match numeric zero on every backend"
  - "does switch array match empty text"
  - "how does switch compare null booleans arrays and hashes"
  - "which task owns switch equality normalization"
  - "why should portable specs normalize a switch subject"
date: 2026-07-13
status: current
tags: [switch, equality, scalar, aggregate, perl, rust, dart, julia, lua, parity]
evidence: "LUA-BACKEND-PARITY.4.3.6.3.2 direct Perl attached/marker probes establish undef versus empty = match, false versus 0 = match, true versus 1 = match, and array/hash versus empty = miss. Lua locks that behavior at 107/107. Rust RuntimeValue::to_str renders null/aggregates as empty and booleans as 0/1; Dart _stringValue and Julia _runtime_string retain textual booleans and host container spellings. All make null match empty, but boolean/number and aggregate comparisons drift. FUTURE-PARITY-BACKLOG.5 owns normalization."
reverify: "bash tools/run_lua_local.sh && rg -n 'fn to_str|_stringValue|_runtime_string|switch_values_equal' rust/linkedspec-runtime/src dart/lib/src julia/src lua/src/linkedspec/interpreter.lua"
---

# Cross-Backend Switch Scalar Comparison Drift

Current switch comparison is not one typed five-backend contract:

| Boundary | Perl | Rust | Dart | Julia | Lua |
| --- | --- | --- | --- | --- | --- |
| null versus empty text | match | match | match | match | match |
| false versus numeric zero | match | match | no match | no match | match |
| array/harray versus empty text | no match | match | no match | no match | no match |

Perl and Lua exclude aggregate values from scalar switch comparison. Rust currently stringifies arrays/hashes as
empty text. Dart and Julia preserve host boolean/container spellings, so their `false` is distinct from numeric
zero and their aggregates are distinct from empty text.

Until [[FUTURE-PARITY-BACKLOG]] `.5` adopts and locks explicit typed equality, portable specs should normalize a
switch subject to an agreed scalar text/number representation and avoid aggregate case values. The same policy
must govern inline, attached, and marker switch together.

## Links

- Discovery/first Lua lock: [[LUA-BACKEND-PARITY]] `.4.3.6.3.2`.
- Normalization owner: [[FUTURE-PARITY-BACKLOG]] `.5`.
- Lua statement mechanism: [[lua-runtime-switch-statement-controls]].
