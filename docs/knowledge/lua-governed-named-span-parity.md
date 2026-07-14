---
id: lua-governed-named-span-parity
title: Lua executes governed named writers spans and anonymous bridges through one rule-local store
answers:
  - does Lua execute the exhaustive governed named capture fixture
  - does Lua implement capture from named marks
  - does Lua implement capture take with a named mark
  - how does Lua distinguish capture take anonymous and named overloads
  - does Lua implement mark copy and mark here
  - does Lua bridge anonymous capture boundaries to named marks
  - do invalid or reversed Lua named spans move marks
  - are Lua named capture positions and lengths Unicode characters
date: 2026-07-15
status: current
tags: [lua, capture, marks, bridges, unicode, parity, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.7.3 extends lua/src/linkedspec/interpreter.lua over the FUTURE-PARITY-BACKLOG.17.4 parse-scoped rule-label/name/UTF-8-byte-offset store. lua/test/run.lua executes capability_capture_named_surface.spec unchanged through native and serialized SpecFile reconstruction and adds a multibyte bridge/edge/arity proof. tools/run_lua_local.sh passes 120/120 on PUC Lua and LuaJIT plus syntax, CLI scaffold, and 105 manifest checks."
reverify: "bash tools/run_lua_local.sh && perl tools/check_language_capability_coverage.pl --report"
---

# Lua Governed Named-Span Parity

`LUA-BACKEND-PARITY.4.3.7.3` routes every governed named writer, reader, stable/advancing span, two-mark span, and
anonymous/named bridge through the one parse-scoped `rule label -> mark name -> UTF-8 byte offset` store created by
`FUTURE-PARITY-BACKLOG.17.4`. Bare identifiers remain symbolic mark names. `mark_copy(target, source)` copies the
source offset or deletes the target when the source is absent; `mark_capture_slice(name)` and
`start_capture_slice_from(name)` bridge the named and anonymous boundary models without another frame.

All text and length reads validate their byte endpoints before slicing. Missing, invalid, or reversed spans
return null without mutation. Advancing current-edge forms read to the current local-match left edge and then move
the mark to the live cursor; cursor forms move it to the cursor; rest forms move it to input end; two-mark forms
move the start mark to the stored end mark. Public positions and widths convert to Unicode character units only
at the DSL boundary.

Dispatch preserves the intentional overload: `capture_take()` is the anonymous zero-argument helper, while
`capture_take(name)` is the named-mark form. The unchanged exhaustive governed fixture returns the same exact
value through native execution and reconstruction from public serialized `SpecFile` state. A supplemental input
containing `é` and `🙂` locks bridges, deletion, stable reads, valid-only mutation, missing/reversed no-ops, void
writers, and exact one-/two-argument diagnostics on PUC Lua and LuaJIT.

## Links

- Owner: [[LUA-BACKEND-PARITY]] `.4.3.7.3`.
- Store foundation: [[lua-complete-named-mark-parity]].
- Family taxonomy: [[spec-capture-mark-family-taxonomy]].
- Audit and next timing mechanism: [[lua-capture-cursor-runtime-audit]].
