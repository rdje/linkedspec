---
id: if-statement-alias-shape-portability
title: "Portable if-statement aliases use i/elif markers and attached when/otherwise"
answers:
  - "which if statement aliases are portable"
  - "can i and elif own attached blocks"
  - "can when and otherwise be marker statements"
  - "why does Lua reject an if alias shape that Perl accepts"
  - "which backends accept extra if alias shapes"
date: 2026-07-13
status: current
tags: [actionir, control-flow, aliases, perl, rust, dart, julia, lua, parity]
evidence: "LUA-BACKEND-PARITY.4.3.6.3.1 Perl call_spec_handler_subst probes lower i/elif and when/otherwise in both attached and marker shapes. Dart/Julia ActionParser control nodes likewise admit all four authored aliases in both shapes. Rust CodeBlock parsing admits attached when/otherwise, while its marker engine admits i/elif; it does not admit the opposite pairings. Lua locks that portable intersection at 106/106 and reports other pairings as malformed_statement_control. FUTURE-PARITY-BACKLOG.5 owns normalization."
reverify: "perl -Iperl -MLinkedSpec -e 'for my $s (q{i(true) { return(1) }}, q{when(true); return(1); otherwise(); return(0); endif()}) { print LinkedSpec::call_spec_handler_subst(q{Top}, $s), qq{\\n} }' && bash tools/run_lua_local.sh"
---

# Portable If-Statement Alias Shapes

Portable `.spec` authoring uses this matrix:

| Statement shape | First branch | Later condition | Fallback |
| --- | --- | --- | --- |
| marker-delimited | `if` or `i` | `elseif` or `elif` | `else()` |
| attached blocks | `if` or `when` | `elseif` | `else` or `otherwise` |

The aliases are structural statement syntax, not inline value-helper aliases. Use canonical inline
`if`/`elseif`/`else` for value controls.

Perl, Dart, and Julia currently accept some opposite-pairing extensions, but Rust does not. Lua follows the
portable intersection and returns a structured `malformed_statement_control` error for an extra pairing.
`FUTURE-PARITY-BACKLOG.5` must either align rejection or formally enlarge the cross-backend language.

## Links

- Lua implementation owner: [[LUA-BACKEND-PARITY]] `.4.3.6.3.1`.
- Normalization owner: [[FUTURE-PARITY-BACKLOG]] `.5`.
- Attached alias origin: [[terse-when-otherwise-alias-seams]].
