---
id: lua-runtime-tagged-record-construction
title: Lua split-tagged-record construction reuses governed split semantics
answers:
  - "does Lua support split_tagged_records"
  - "what shape does Lua split_tagged_records return"
  - "does Lua split_tagged_records evaluate carried fields once"
  - "does Lua split_tagged_records copy carried arrays"
  - "does Lua split_tagged_records accept regex delimiters and receivers"
date: 2026-07-12
status: current
tags: [lua, runtime, arrays, split, tagged-records, receivers, copy, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.4.5 adds split_tagged_records to the pure-array dispatcher in lua/src/linkedspec/interpreter.lua. The focused lua/test/run.lua case locks literal and PCRE2 delimiters, empty split items, direct and receiver composition, exact [tag,item,fields...] shapes, one-time source/carried-field side effects, copied nested fields, invalid input, and missing arity. PUC Lua 5.4 and LuaJIT pass 99/99 through tools/run_lua_local.sh."
reverify: "bash tools/run_lua_local.sh && rg -n 'split_tagged_records|runtime split tagged records' lua/src/linkedspec/interpreter.lua lua/test/run.lua"
---

Lua evaluates every `split_tagged_records(source, delimiter, tag, fields...)` argument once. It sends the source
and delimiter through the same pure split evaluator used by `split`, so literal delimiters preserve empty items
and regex delimiters use the governed PCRE2 dialect and flags.

Each split item produces one fresh typed array shaped exactly as `[tag, item, fields...]`. There is no additional
wrapper inside an individual record; the outer result array exists because one source may yield multiple records.
The tag uses the portable scalar-to-text boundary, and every carried field is copied into every record. A later
mutation of a carried array therefore cannot change records already returned.

The direct call returns an array value and scalar receiver form injects the source, so the result composes with
array terminals such as `.count()`. Fewer than three total values or a non-text source returns an empty typed
array. Tree callbacks are a different mechanism and remain owned by `LUA-BACKEND-PARITY.4.3.6`.

Related facts: [[lua-pure-split-bridge]], [[lua-runtime-array-transform-pipelines]],
[[lua-runtime-array-construction]], [[scalar-to-text-coercion-cross-backend-gap]].

September 6 fresh PUC controls confirm once-only fields, but expose Perl divergence and an empty-source
pure-split difference. [[tagged-record-evaluation-and-split-drift]] owns the paired evidence and links the
contract-review/repair tasks; this Lua-specific record does not establish all-runtime parity.
