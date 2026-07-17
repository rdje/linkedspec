---
id: split-boundary-marker-action-timing
title: "Split-boundary marker timing is backend-specific; Lua uses post-action slot events while Perl anonymous markers are rule-level"
answers:
  - "why did @capture_slice include the opener or move too late"
  - "how should docs demonstrate @capture_slice with @mark"
  - "when are split-boundary markers visible to action code"
  - "why should marker examples read from a later slot"
  - "what is the verified capture mark marker timing shape"
date: 2026-07-08
status: corrected 2026-07-17; backend-specific
tags: [spec-language, mdbook, helpers, capture-mark, markers, SPEC-LANG-REFERENCE]
evidence: "SPEC-LANG-REFERENCE.6 proved post-action visibility but overgeneralized scope. INTER-MATCH-GAP-CAPTURE.0 re-audited lowering: Perl anonymous markers become unconditional rule-level LECODE, Perl @mark(name) is preceding-index guarded, and Lua uses typed preceding-slot events. Rust/Dart/Julia do not execute marker members in native runtime paths."
evidence_update_2026_07_15_lua: "LUA-BACKEND-PARITY.4.3.7.4 implements the same post-action visibility but a different preceding-slot scope: typed events execute after action/child dispatch and before LE through the existing anonymous/named stores. A multibyte native/reconstructed test proves same-slot invisibility and later-slot visibility at 121/121 on PUC Lua and LuaJIT."
---

# Split-Boundary Marker Action Timing

**Corrected 2026-07-17 (`INTER-MATCH-GAP-CAPTURE.0`).** The earlier probe correctly
established post-action visibility but incorrectly promoted Lua's slot scope to a portable contract.
Current marker-member behavior differs by backend:

- Perl's anonymous `@capture_slice` / `@capture_from_here` / `@move_pos` forms are rule-level and roll
  after every successful action once enabled; Perl `@mark(name)` is guarded by its preceding slot.
- Lua/LuaJIT attach both anonymous and named forms to the preceding slot and execute them post-action.
- Rust, Dart, and Julia parse the surface but do not execute marker members in native runtime paths.

The following shape specifically demonstrates Lua's current positional behavior; it is not a
portable marker-member example:

```text
Top::AND
 => MarkerBody

MarkerBody:AND
 /foo\(/
 @capture_slice
 @mark(body_start)
 /[A-Za-z]+/
 /\)/
 -> MarkerBody[0] {
   opened = 1;
 }
 -> MarkerBody[2] {
   mark_match_start(close_start);
   return(hash(
     "anonymous", capture_slice(),
     "named", capture_from(body_start),
     "between", capture_between(body_start, close_start),
     "body_start", mark_pos(body_start),
     "close_start", mark_pos(close_start)
   ))
 }
```

With `parse_mode => "seek"`, input `foo(alpha)` returns:

```json
[{"anonymous":"alpha","between":"alpha","body_start":4,"close_start":9,"named":"alpha"}]
```

For portable, explicit timing inside an action or lifecycle block, prefer helper-call forms such as
`start_capture_slice()` and `mark_here(name)` while the marker-member contract is reconciled.

Lua now encodes the timing directly in compiled state. See [[lua-rule-slot-marker-execution]] for the typed event,
serialization, Unicode, shipped-source, and malformed-marker proof.

See [[split-marker-cross-backend-semantics]] for the exact current backend matrix and the migration owner.

## Links

- Task tree: [[SPEC-LANG-REFERENCE]] (leaf `.6`)
- Public placement page: `docs/linkedspec-book/src/dsl/action-and-lifecycle-placement.md`
- Public helper reference: `docs/linkedspec-book/src/dsl/source-boundary-helper-reference.md`
