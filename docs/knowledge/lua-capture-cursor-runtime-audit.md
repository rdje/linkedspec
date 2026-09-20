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
date: 2026-09-21
status: confirmed
tags: [lua, runtime, capture, marks, cursor, inventory, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.7.0 audited perl/LinkedSpec/ActionIR/Contracts.pm, Rust/Dart/Julia runtime implementations, governed fixtures, Lua state seams, and shipped markers. `.4.3.7.1` implements input/cursor controls at 115/115, `.4.3.7.2` implements all 16 anonymous capture calls at 116/116, and `.4.3.7.5` implements non-consuming earliest-boundary lookahead at 117/117 on PUC Lua and LuaJIT. Named marks and split-marker AST execution remain later leaves. The documented current mark helpers mark_entry_start/end, mark_match_start/end, mark_line, mark_col, and clear_mark are absent from all aligned 239-name backend inventories; tools/check_language_capability_coverage.pl checks inventory names against book/corpus and only reverse-checks Perl contracts that occur in the neutral corpus, so those identical omissions pass."
evidence_update_2026_07_15: "FUTURE-PARITY-BACKLOG.17.4 adds Lua's parse-scoped rule-label/name/byte-offset mark store and exact seven-call family view at 119/119. FUTURE-PARITY-BACKLOG.17.5 admits the calls at 246 shared names and independently checks all 122 public Perl contracts. LUA-BACKEND-PARITY.4.3.7.3 extends that store across governed named writers/spans/bridges at 120/120. LUA-BACKEND-PARITY.4.3.7.4 compiles and executes preferred/compatibility split markers plus named marks through typed post-action slot events at 121/121 on PUC Lua and LuaJIT; .4.3.7.6 is the remaining closeout."
evidence_update_2026_07_15_closeout: "LUA-BACKEND-PARITY.4.3.7.6 derives 62 unique current capture/mark/input/cursor/control calls from Lua contracts and finds the same 62 in interpreter dispatch plus focused execution sources, with zero missing or extra. Preferred @capture_slice, compatibility @capture_from_here/@move_pos, and @mark(name) remain four separately proved placement spellings. The dual-ABI suite passes 121/121; coverage is 246 names over 105+1 sources with 0/122 public-contract omissions. Parent .4.3.7 is closed; generated Lua preservation/execution remains .8.1-.8.4 and diagnostic helpers .4.3.8 become active."
evidence_update_2026_09_21: "Integration .8.6 isolates the inline marker fixture and passes the existing selected timing/Unicode/reconstruction/error test on both retained ABIs. The July counts are historical; no full-suite, target-version or runtime repair admission is claimed. Use lua-rule-slot-marker-execution for the current selected recheck."
reverify: "Historical full-suite recipe (not rerun by .8.6): bash tools/run_lua_local.sh && bash tools/run_python_project_data.sh tools/check_complete_named_mark_contract.py && perl tools/check_language_capability_coverage.pl --report && bash tools/run_python_project_data.sh tools/check_public_aggregate_selector_surface.py && rg -n 'CAPTURE_MARK_HELPERS|INPUT_HELPERS|RUNTIME_HELPERS|INPUT_CURSOR_HELPERS|CURSOR_CONTROL_HELPERS|ANONYMOUS_CAPTURE_HELPERS|NAMED_MARK_HELPERS|capture_until_boundary' lua/src/linkedspec/action_contracts.lua lua/src/linkedspec/interpreter.lua"
---

# Lua Capture/Cursor Runtime Audit

`LUA-BACKEND-PARITY.4.3.7` is ordered by state and timing mechanism:

1. input/live-cursor projections plus cursor save/restore/rewinds;
2. the anonymous rule-local capture boundary;
3. governed rule-local named marks, named spans, and anonymous/named bridges;
4. placement-sensitive split/mark rule members, applied after their matched action site;
5. compiled-rule earliest-boundary lookahead; and
6. final inventory/public no-drift (closed at 62 calls plus four marker spellings).

Lua stores internal positions as UTF-8 byte offsets in immutable runtime match registers. Those registers carry
the live cursor, entry/local matches, and anonymous capture start, and expose byte-to-character and line/column
conversion helpers. `.4.3.7.1` adds a parse-scoped cursor stack and executes the input/live-cursor and explicit
cursor-control families through one live/register synchronization seam; `.4.3.7.2` adds anonymous capture reads;
and `.4.3.7.5` adds compiled-rule boundary lookahead. `FUTURE-PARITY-BACKLOG.17.4` then adds one parse-scoped
rule-label/name/byte-offset mark store and executes the exact seven complete-mark helpers at 119/119 on PUC Lua
and LuaJIT. `.4.3.7.3` extends that store across governed named writers, stable/advancing spans, two-mark spans,
and anonymous/named bridges at 120/120. `.4.3.7.4` compiles `@capture_slice`, `@capture_from_here`, `@move_pos`,
and `@mark(name)` into typed preceding-slot events and executes them after slot action/child dispatch and before
`LE` through those same stores at the historical July15 count of121/121. Integration `.8.6` replaces the
former dependency-owned marker fixture with a locally authored two-regex inline rule; its selected test passes
on both retained ABIs with dependency-file access denied. The recipe and dated limits are in
[[lua-rule-slot-marker-execution]]. `.4.3.7.6` closes the parent after deriving 62 unique current call names and
matching all 62 across contract classification, interpreter dispatch, and focused execution sources. There are no
missing or extra names, and the four marker spellings remain separately timing-tested.

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

The former coverage checker could not discover that symmetric omission because its reverse direction began with
calls present in the neutral corpus. `FUTURE-PARITY-BACKLOG.17.1-.17.4` implements the exact seven-helper contract
on all five backends; `.17.5` admits all seven into the shared 246-name inventory, adds the exact fixture to
governed occurrence sources, and independently checks all 122 public Perl contracts. `.4.3.7.3` closes full-
family named-mark parity without changing the admitted inventory. Placement-sensitive split/mark rule-member
execution closes in `.4.3.7.4`; exhaustive inventory/public no-drift `.4.3.7.6` closes the parent at 121/121 on
both Lua ABIs. The next native helper owner is diagnostic output `.4.3.8`; generated-state preservation and
execution remain explicitly future under `.8.1-.8.4`.

`capture_until_boundary` stays separate from ordinary capture spans: it resolves compiled regex-bearing rules,
seeks all usable candidates from the live cursor through a boundary-specific alternation cache, chooses the
earliest boundary, and leaves that boundary unconsumed. If every supplied rule is unresolved or unusable it
returns null without moving; if at least one is usable but none matches later, it captures to end-of-input.
`.4.3.7.5` executes this on PUC Lua and LuaJIT independent of surrounding seek/consume mode. Zero arguments are a
neutral no-op on Rust/Dart/Julia/Lua but a generated-handler failure on Perl; `.5` owns normalization.

## Links

- Owner: [[LUA-BACKEND-PARITY]] `.4.3.7.0` audit plus `.4.3.7.1-.5`; complete seven-helper Lua
  execution is [[lua-complete-named-mark-parity]] and full named-span execution is
  [[lua-governed-named-span-parity]]. Rule-member execution is [[lua-rule-slot-marker-execution]].
- State taxonomy: [[spec-capture-mark-family-taxonomy]].
- Marker timing: [[split-boundary-marker-action-timing]].
- Coverage limitation: [[current-call-name-inventory-does-not-prove-runtime-semantics]].
