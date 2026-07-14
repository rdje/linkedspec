---
id: lua-capture-cursor-runtime-audit
title: Lua capture and cursor parity is six runtime mechanisms plus one documented-mark inventory gap
answers:
  - how is Lua capture cursor runtime work split
  - does Lua execute split markers
  - which Lua state already exists for capture helpers
  - are all documented mark helpers in the 239 name inventory
  - which documented current mark helpers are missing from backend inventories
  - why is capture until boundary separate from capture slices
  - does Lua execute input cursor helpers and cursor controls
  - does Lua execute capture_until_boundary
date: 2026-07-13
status: confirmed
tags: [lua, runtime, capture, marks, cursor, inventory, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.7.0 audited perl/LinkedSpec/ActionIR/Contracts.pm, Rust/Dart/Julia runtime implementations, governed fixtures, Lua state seams, and shipped markers. `.4.3.7.1` implements input/cursor controls at 115/115, `.4.3.7.2` implements all 16 anonymous capture calls at 116/116, and `.4.3.7.5` implements non-consuming earliest-boundary lookahead at 117/117 on PUC Lua and LuaJIT. Named marks and split-marker AST execution remain later leaves. The documented current mark helpers mark_entry_start/end, mark_match_start/end, mark_line, mark_col, and clear_mark are absent from all aligned 239-name backend inventories; tools/check_language_capability_coverage.pl checks inventory names against book/corpus and only reverse-checks Perl contracts that occur in the neutral corpus, so those identical omissions pass."
reverify: "bash tools/run_lua_local.sh && perl tools/check_language_capability_coverage.pl --report && rg -n 'mark_entry_start|mark_match_start|mark_line|clear_mark' lua/src/linkedspec/action_call_names.lua dart/lib/src/action/action_contracts.dart julia/src/action/ActionContracts.jl docs/linkedspec-book/src/dsl/source-boundary-helper-reference.md && rg -n '@(capture_slice|capture_from_here|move_pos|mark\\()' --glob '*.spec' specs rgx/subs/pgen"
---

# Lua Capture/Cursor Runtime Audit

`LUA-BACKEND-PARITY.4.3.7` is ordered by state and timing mechanism:

1. input/live-cursor projections plus cursor save/restore/rewinds;
2. the anonymous rule-local capture boundary;
3. governed rule-local named marks, named spans, and anonymous/named bridges;
4. placement-sensitive split/mark rule members, applied after their matched action site;
5. compiled-rule earliest-boundary lookahead; and
6. final inventory/public no-drift.

Lua stores internal positions as UTF-8 byte offsets in immutable runtime match registers. Those registers carry
the live cursor, entry/local matches, and anonymous capture start, and expose byte-to-character and line/column
conversion helpers. `.4.3.7.1` adds a parse-scoped cursor stack and executes the input/live-cursor and explicit
cursor-control families through one live/register synchronization seam; `.4.3.7.2` adds anonymous capture reads;
and `.4.3.7.5` adds compiled-rule boundary lookahead. The interpreter still has no named-mark frame and falls
through for named capture/mark helpers. `spec_parser.lua` preserves
`@capture_slice`, `@capture_from_here`, `@move_pos`, and `@mark(name)` as typed split-marker nodes, but
`compiled_spec.lua` and `interpreter.lua` do not consume those nodes. Current shipped source includes `@move_pos`
in `rgx/subs/pgen/specs/ebnf.spec`, so marker execution needs an explicit native owner.

The `.4.3.7.1` public boundary is character-based even though internal cursors remain byte offsets. `input_slice`
converts its nonnegative character start and width to UTF-8-safe byte endpoints; invalid numeric boundaries return
null and past-end spans return empty text. Cursor saves are LIFO across the parse, empty restore and absent-anchor
rewind are no-ops, and rewinds change the synchronized cursor without replacing entry/local match snapshots. A
consume-mode test proves the next regex starts from the rewound cursor.

The governed exact fixtures cover cursor/input values, explicit cursor control, anonymous captures, and a named
subset: `mark_here`, input-boundary marks, copy/existence/position, anonymous/named bridges, and stable/advancing
named spans. They do not cover seven helpers that the public source-boundary reference presents as current:
`mark_entry_start`, `mark_entry_end`, `mark_match_start`, `mark_match_end`, `mark_line`, `mark_col`, and
`clear_mark`. Those seven are real non-compatibility Perl contracts but are absent from the aligned Dart, Julia,
and Lua 239-name inventories; Rust's earlier parity audit also recorded the entry/match writers as follow-on gaps.

The existing coverage checker cannot discover that symmetric omission because its reverse direction begins with
calls present in the neutral corpus. A clean-pivot cross-backend task must therefore decide and implement the
complete documented current mark inventory before Lua `.4.3.7.3` can claim full named-mark parity. Lua must not
invent an isolated extension.

`capture_until_boundary` stays separate from ordinary capture spans: it resolves compiled regex-bearing rules,
seeks all usable candidates from the live cursor through a boundary-specific alternation cache, chooses the
earliest boundary, and leaves that boundary unconsumed. If every supplied rule is unresolved or unusable it
returns null without moving; if at least one is usable but none matches later, it captures to end-of-input.
`.4.3.7.5` executes this on both Lua ABIs independent of surrounding seek/consume mode. Zero arguments are a
neutral no-op on Rust/Dart/Julia/Lua but a generated-handler failure on Perl; `.5` owns normalization.

## Links

- Owner: [[LUA-BACKEND-PARITY]] `.4.3.7.0` audit plus `.4.3.7.1`, `.4.3.7.2`, and `.4.3.7.5` implementations.
- State taxonomy: [[spec-capture-mark-family-taxonomy]].
- Marker timing: [[split-boundary-marker-action-timing]].
- Coverage limitation: [[current-call-name-inventory-does-not-prove-runtime-semantics]].
