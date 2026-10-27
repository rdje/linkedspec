---
id: lua-runtime-tagged-record-construction
title: Lua split-tagged-record construction reuses governed split semantics
answers:
  - "does Lua support split_tagged_records"
  - "what shape does Lua split_tagged_records return"
  - "does Lua split_tagged_records evaluate carried fields once"
  - "does Lua split_tagged_records copy carried arrays"
  - "does Lua split_tagged_records accept regex delimiters and receivers"
date: 2026-10-27
status: bounded producer/receiver targeted-checked on safe PUC5.5.1/LuaJIT; declared5.4/full admission open
tags: [lua, runtime, arrays, split, tagged-records, receivers, copy, LUA-BACKEND-PARITY]
evidence: "Historical LUA-BACKEND-PARITY.4.3.4.5 adds the copied tagged producer and records July PUC5.4/LuaJIT99/99. TYPE22.5 now repairs prior-String result guards and min-two-RHS preflight; five strict native/plan/fresh groups plus direct scalar String pass safe PUC5.5.1/LuaJIT. Historical5.4 proof is not current declared-host admission."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/tagged_record_receivers_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/tagged_record_receivers_test.lua"
---

Lua evaluates every `split_tagged_records(source, delimiter, tag, fields...)` argument once. It sends the source
and delimiter through the same pure split evaluator used by `split`, so literal delimiters preserve empty items
and regex delimiters use the governed PCRE2 dialect and flags.

Each split item produces one fresh typed array shaped exactly as `[tag, item, fields...]`. There is no additional
wrapper inside an individual record; the outer result array exists because one source may yield multiple records.
The tag uses the portable scalar-to-text boundary, and every carried field is copied into every record. A later
mutation of a carried array therefore cannot change records already returned.

The direct call returns an array value and scalar receiver form injects the source, so the result composes with
Array methods and selected scalar/carried-container continuations. TYPE22.5 keeps text input distinct from
Array output-family membership, including after trim; minimum delimiter/tag
receiver shape rejects before source/operand effects. Free calls with fewer than three total values retain their empty typed Array
result; other input handling follows the existing pure splitter. Tree callbacks are a different mechanism and remain owned by `LUA-BACKEND-PARITY.4.3.6`.

Related facts: [[lua-pure-split-bridge]], [[lua-runtime-array-transform-pipelines]],
[[lua-runtime-array-construction]], [[scalar-to-text-coercion-cross-backend-gap]].

September 6 fresh PUC controls confirm once-only fields, but expose Perl divergence and an empty-source
pure-split difference. [[tagged-record-evaluation-and-split-drift]] owns the paired evidence and links the
contract-review/repair tasks; this Lua-specific record does not establish all-runtime parity.

October27 verification uses only the safe named tagged-record and scalar String fixtures on PUC5.5.1/LuaJIT,
including source/runner loadfile without execution. The July full-run99/99 observation remains historical;
LUA-STARTUP-READING.2.2/.2.3 own declared5.4 restoration and unsafe native-pattern blocker. No full runner,
malformed native regex or portable split-domain admission is implied by this bounded receiver repair.
