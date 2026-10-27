---
id: lua-callable-codeblock-emitted-route-identity
title: Lua callable codeblocks retain one typed state and executor across emitted routes
answers:
  - "does Lua execute callable codeblocks from emitted source"
  - "does a fresh Lua generated module preserve codeblock literals"
  - "how are Lua codeblocks serialized into generated source"
  - "does Lua generated source create host closures for codeblocks"
  - "do Lua native reconstructed generated and emitted callable routes agree"
  - "can Lua with receive an explicit or bound codeblock value"
  - "when does Lua resolve a final callback relative to scoped value"
  - "why are nested Lua with callbacks not codeblock recursion"
  - "does Lua detect recursion when a bound callback is passed through with"
  - "can opaque Lua callback values escape recursion tracking"
  - "why does an anonymous Lua callback lose unknown helper diagnostics"
  - "how are Lua emitted callable temporary files stored and cleaned"
  - "how many Lua temporary allocation owners exist"
date: 2026-10-27
status: bounded opaque identity and anonymous errors repaired TYPE31.6.4.1; broader admission separate
tags: [lua, luajit, callable, codeblock, generated-source, serialization, storage, FUTURE-PARITY-BACKLOG]
evidence: "Historical2026-08-01 FUTURE-PARITY-BACKLOG.11.8.3 proves the unchanged typed callable record and runtime detail through native compilation, canonical effective-SpecFile JSON reconstruction, generated-plan execution, and independently loaded emitted modules on PUC Lua and LuaJIT. One executor handles bound and built-in final callbacks; anonymous callbacks omit helper-name recursion tracking, while callbacks passed by variable retain that binding identity and dynamic direct/mutual/helper-mediated recursion remains ordered. The focused consumer passes 449 assertions per ABI, complete Lua passes 177 TAP groups per ABI with CLI 66x2 and corpus 105/105, and the storage oracle registers the consumer as exact Lua owner 17. Neutral+20, signatures 3/9/7, capability 80/0/0, Knowledge Map 779/6,322, mdBook 79/14,048 KiB, all doctrines, and canonical Phase 0 1,031/1,031 in 809 seconds plus the four-backend callable matrix complete signoff."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/callback_identity_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/callback_identity_test.lua && bash tools/run_lua_project_data.sh puc lua/test/with_hash_results_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/with_hash_results_test.lua"
---

# Lua Callable-Codeblock Emitted Route Identity

Lua generated source retains one canonical, strict-UTF-8 effective `SpecFile` as lowercase ASCII hex. A fresh
module decodes that payload, reconstructs the typed AST through `spec_ast.from_json`, compiles it normally, builds
the existing generated plan, and enters the ordinary interpreter. Callable literals therefore remain the same
eight-field data records across native, reconstructed, generated-plan, and independently loaded emitted routes.
The emitter contains no Lua closure body, host function value, callable-specific codec, or generated-only executor.

Built-in final-codeblock dispatch now validates a callback value rather than requiring authored `block_value`
syntax. Authored contextual blocks remain zero-positional callable data; explicit or bound literals receive the
helper/receiver/tree scoped value according to their signature. Callback expressions resolve before the helper
installs its scoped `value`, so even a callback stored in the caller binding named `value` remains callable and the
binding restores afterward.

All callback bodies enter `callable_codeblock.execute_values`. Ordinary `cb(args)` dispatch tracks the bound name
in `active_codeblocks`, preserving exact direct and mutual recursion rejection. Built-in final callbacks do not
claim the helper name as callable identity: two nested anonymous `with` callbacks are distinct values, not a
`with -> with` recursion cycle. When the callback expression is a variable, that binding name remains the
recursion identity through helper dispatch, so re-entering `callback` reports `callback -> callback` exactly.

The focused consumer writes exact emitted bytes only below managed repository-derived `TMPDIR`, launches a fresh
PUC Lua or LuaJIT child, projects typed generated wrapper errors plus exact inner runtime detail, corrupts one
payload to prove compile/load rejection, and removes every workspace after normal and injected-failure paths. The
Lua storage oracle freezes that file as temporary owner 17 and continues to prove repository-device identity and
zero residue.

Related facts: [[lua-callable-codeblock-dynamic-invocation]], [[lua-callable-codeblock-literal-state]],
[[lua-generated-source-emitter-core]], [[lua-generated-source-fresh-process-isolation]],
[[project-data-ssd-storage-locality]], [[callable-codeblock-four-backend-recurring-gate]].

## Historical October27 intake before the bounded repair

TYPE31.6.4.0 independently preserves named helper/receiver/direct cycle rejection,
contextual/explicit nesting and caller callback named value on available PUC5.5.1/
LuaJIT2.1.1788460057. It also confirms opaque coalesce(cb,cb) callback reentry
escapes tracking and returns the finite fallback after four entries on native/
SpecFile-restored/plan/fresh routes. Anonymous with body missing() reports general
runtime_execution instead of callable unknown_helper. execute_values tracks only
nonfalse variable-name recursion_identity and omits anonymous frames; evaluate_call
uses that same activity to select callable error routing.

P1 TYPE31.6.4.1 owns both defects immediately before the Perl label/snapshot repairs
and unrelated selection/parent31 admission. Preserve all invocation activity,
existing named fences and inert callback identity without adding helper labels to
recursion keys, environments or serialized fields. Exact producer/channels and the
intentional finite oracle RED: callback-identity-remaining-intake.json.gz. Initial
plain-table row serialization failure is probe setup, corrected using json.harray;
it is not a runtime defect. Earlier broad recorded counts remain historical and do
not cover these newly distinguished values. No new full runner/declared5.4/trace/
context admission is claimed.

## Current bounded repair — TYPE31.6.4.1

All private invocation frames now retain diagnostic name, optional bound name and
an owned inert action_ast.to_json callback projection. Preserve the current bound-
name fence and compare only callback projections to recognize an opaque existing
value. Every invocation remains active for unknown-helper routing and is removed
after the existing protected scoped-frame call on success/failure. Matched callback
identity supplies ordered cycle closure and handler-source label; incoming helper
role remains available in its existing helper field. General runtime equality,
argument order, source body caches, eight literal fields and environments do not move.
The comparison lives on the existing callable_codeblock table, avoiding persistent
chunk-local pressure.

The focused PUC target independently reproduces opaque/anonymous and bound-cycle
source-label failures before production. Candidate174 assertions per available
PUC5.5.1/LuaJIT2.1.1788460057 and ordinary with five sources/three routes per host
pass. They check native/restored typed fields, plan/fresh inner error identity,
distinct contextual/explicit/tree nesting, caller callback named value and true
helper/receiver/opaque/direct/mutual cycles. Six shared scoped-binding failure
assertions restore scalar/Array/Hash/binding identity and retain unrelated effects;
private interpreter frame state is not directly inspected by this target. Normal
runner registers it; source loads confirm both interpreter/runner syntax. Exact
producer/channels: callback-identity-lua-intake.json.gz; the prior intake packet
retains both-host independent raw outcomes. No full runner/declared5.4/isolated-
process emitted/trace or complete alias/context admission is claimed. Perl cycle
labels .4.2 and callback snapshots .4.3 follow before unrelated selection/admission.
