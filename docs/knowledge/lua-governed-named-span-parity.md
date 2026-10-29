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
status: bounded49.0-.5 local writer work focused-verified on recorded routes/hosts; selection/declared hosts/full admission separate
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

## Safe Lua compatibility47.5 (2026-10-29)

Installed PUC5.5 and LuaJIT2.1.1788460057 independently pass all15 on native/restored/
plan/separate-process emitted routes. Existing explicit named take dispatch/name
evaluation/nullable local-match byte endpoint/valid-only typed span and mark update
already preserve named/anonymous origins and failed takes; no runtime repair.
Named105/anonymous112/named Number-function-scope219 pass436 checks per host,
empty stderr/syntax loads. Wrong root empty-text oracle fails3 values/102pass per
host, actual fixture unchanged; no product RED claim. Exact source/normalized/
compiled/plan/emitted/full metadata/results/traces retained, runtime/emitter/fixture
match activation HEAD, no regeneration. New normal/run.lua registration verified;
selection23.4.1/declared5.4/unsafe formatter/phase/full admission remain separate.
Packet lua-named-capture-endpoint-intake.json.gz retains closure. Bounded47.0-.5
targeted-checked; writer49/referenced-blind48/Phase0 owner45 precede wider features.

See [[lua-named-capture-endpoint-origin-compatibility]] for independent current proof. Earlier broad observations remain historical.

## Safe Lua compatibility49.5 (2026-10-29)

Installed PUC5.5/LuaJIT2.1.1788460057 independently pass all15 native/restored/plan/
separate emitted cases. Existing name evaluation then nullable local_match guard
before validated write_mark already preserves fresh/seeded/name-effect targets
and real empty/zero/Unicode/local-live cursor behavior. No runtime edit. Writer105/
named endpoint105/named Number-function-scope219 pass429 checks per host, empty
healthy stderr/syntax loads. Wrong first-mark oracle3fail102pass per host, actual
fixture/runtime unchanged, no product RED. Full source/normalized/compiled/plan/
emitted/metadata/results/debug traces retained, runtime/emitter/fixture match HEAD,
no regeneration. Packet lua-writer-endpoint-intake.json.gz retains closure. Normal
run.lua registration verified; exact selection23.4.1/declared5.4/unsafe formatter/
phase/full admission remain separate. Bounded49.0-.5 focused work complete on
recorded routes/hosts; parent admission open,48/45 precede wider features/push.

See [[lua-local-match-writer-presence-compatibility]] for independent current proof; earlier observations remain historical.
