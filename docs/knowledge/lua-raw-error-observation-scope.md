---
id: lua-raw-error-observation-scope
title: Selected Lua raw error fields differ from published and generated projections
answers:
  - "which Lua result guard observers retain full published error JSON"
  - "what does the Lua raw error observation regression cover"
  - "how do Lua native fields differ from generated error envelopes"
  - "where is the Lua omitted native field RED GREEN proof"
  - "does Lua field observation include metatables or table identity"
date: 2026-11-13
status: focused installed-host field coverage; current discovery and full admission remain separate
tags: [lua, errors, diagnostics, fields, guards, custody]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.4.28; docs/checkpoints/lua-raw-error-observation-2026-11-13/REVIEW.md. Source-bound old/current128 route records/eight cases/two hosts;2896 controls/384 named native misses; each normal128PASS, legacyRED1/rawGREEN0, historical recovery0-ten controls."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/lua-raw-error-observation-2026-11-13/review.py"
  - "bash tools/run_lua_project_data.sh puc lua/test/raw_error_observation_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/raw_error_observation_test.lua"
---

`interpreter.to_json(RuntimeInterpreterException)` publishes message/diagnostic.
`fail` stores supplied native fields, and `with_runtime_diagnostic` copies them
when attaching a diagnostic. Binding failures additionally expose identifier and
expected/actual kind. Registered-function arity failures expose outer stage/helper/
rule/handler metadata; the selected errors have no numeric expected/actual fields.

Plan and fresh emitted routes instead expose `GeneratedSourceError` envelopes.
`generated_source_execution_failed` stores display text as detail plus its own
stage/code/summary/source identity/rule/handler/type. Those envelopes do not carry
the inner native binding table. Each route must be observed on its own contract.

The complete selected activation population is eight tracked result-guard normals
that explicitly construct the supporting user-function grammar parser, recovered
from all204 activation Lua files. Three use identical published-JSON-plus-flags
helpers. Five older inline observers retain text and named flags only. None is an
injective observation of all native fields. No older observation or custody claim
receives credit from the new companion. This is not a census of every Lua test.

Eight authored cases cover binding and fixed/minimum function arity, including
child attribution, across both recorded hosts/four routes/old-current SDKs.
Independent analysis validates128 records and2896 actual change/remove/add controls.
The prior helper misses384 named native mutations;128 separate added unknown-field
controls are also invisible. Each host's new normal has128 passing checks. The same
field oracle gives legacy1 specifically on expected_kind and raw0 on binding and
function attribution. First historical recovery rejects ten effective corruptions;
the separate source/field analysis rejects eight evidence/four Git membership,
body or mode controls. Actual artifact inputs and opaque native bodies precede use.

The test-only observer captures acyclic string/number-keyed tables and finite
values. It does not capture table identity, metatable implementation or every
possible error. Fresh modules share a process. Complete native/cache/toolchain/OS
and wider module-source closure remain4.2/SESSION5; preparation-origin limitations
are explicit in CUSTODY.md. The new standalone normal awaits current discovery4.1
registration before publication. No SDK behavior or public serializer is changed.

Related: [[lua-runtime-structured-diagnostics]], [[lua-callable-pipeline-result-guards]],
[[lua-callable-array-transform-result-guards]], [[lua-callable-key-count-preservation]].
