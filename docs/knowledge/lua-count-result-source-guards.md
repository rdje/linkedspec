---
id: lua-count-result-source-guards
title: Installed Lua Count guards preserve source policy and mutation restrictions
answers:
  - "how does Lua guard Count consumers before operands and with bodies"
  - "does Lua Count guarding add interpreter chunk locals"
  - "why does Lua Count preserve the separate loop-index mutation gate"
  - "which Lua hosts were checked for Count source guards"
  - "why does Lua initial Boolean Count return zero but copied Booleans reject"
date: 2026-11-05
status: bounded installed-host73.5 and Boolean-source73.6.5 focused-checked; full admission remains open
tags: [lua, count, guards, source, copy, null, composition]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.73.5; docs/checkpoints/count-guard-lua-2026-11-05/ retains independent host baselines, frozen source/domain/observed errors, emitted module inputs, final/direct compatibility and actual versions."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/count_source_fallback_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/count_source_fallback_test.lua"
  - "bash tools/run_lua_project_data.sh puc lua/test/count_result_guard_composition_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/count_result_guard_composition_test.lua"
  - "On each host, use the supported wrapper with lua/test/count_length_receivers_test.lua and lua/test/copied_null_index_composition_test.lua; no unsafe full runner, formatter or declared5.4 inference."
---

`typed_source.receiver_mutation.is_ordinary_count_result_chain` admits canonical
positional free-one Count sources and zero-extra receiver prefixes, excluding
traversal and non-with trailing blocks. It uses the existing namespace, adding no
interpreter chunk locals. Common fluent kind guards reject incompatible consumers
before operands and later `with` bodies. Legitimate null still enters `with`;
numeric zero and explicit Array bridges remain valid.

Only initial receiver Count without a prior result owner skips the common guard.
Already-produced Count numbers retain their Array-kind guard. Scalar-result state
and its guard remain intact, as does the separate loop-index mutation target gate.
Count's producer/domain and copied-null policy are unchanged.

PUC Lua5.5.1 and LuaJIT2.1.1788460057 independently reproduce guard REDs and pass
final native/restored/plan/fresh module controls. Their actual source18, six-zero/
one-null domain and observed error fields agree before selecting shared fences.
Initial null AST/domain expectations are separately qualified bootstrap only.
Selected Count/length/copied-null index and loadfile checks pass with empty final
and compatibility stderr. Three runner lines register the new normal.

Emitted sources and public ASTs are captured before module loading. Modules share
a host process/runtime; transient native module bodies and full transitive input
closure remain23.4.2-owned. Declared5.4, independent package isolation, registration
and full23.4 admission remain open. Rebuild Lua applications/runtime for the fix;
mandatory P1 Count/copy/source assessment73.6.0 is next before unrelated selection.

Boolean-source repair73.6.5 reuses that same initial-source exception at the
separate scalar guard. Initial false/true sources, including function parameters,
now reach Number0. Copied/produced Booleans and later Array consumers still reject
before operands/bodies; scalar assignments and loop-index mutation rights stay.
Both installed hosts independently reproduce four failing groups and pass all25
shared groups/four routes afterward, plus nearest Count/length/copied-null index.
Actual direct inputs and pre-load module/AST bodies are retained under
`docs/checkpoints/count-source-lua-2026-11-05/`; readonly review validates their
archives and unchanged observations. The existing custody/isolation/registration/
declared5.4/full-admission qualifications remain. All concrete Count P1s are
focused-checked; P2 compiler73.7 then P3 Dart formatting73.8 follow.
