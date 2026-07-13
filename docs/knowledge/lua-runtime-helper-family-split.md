---
id: lua-runtime-helper-family-split
title: Lua runtime helper parity is split into nine ordered implementation and no-drift owners
answers:
  - how is Lua runtime helper work split
  - what comes after the Lua rule interpreter
  - which Lua task owns scalar and string helpers
  - which Lua task owns numeric helpers
  - which Lua task owns arrays and harrays
  - which Lua task owns codeblocks controls and trailing blocks
  - which Lua task owns capture marks input and cursor helpers
  - which Lua task owns diagnostic output helpers
  - how will Lua prove all 239 helpers execute
date: 2026-07-11
status: current
tags: [lua, runtime, helpers, values, controls, planning, LUA-BACKEND-PARITY]
evidence: "LUA-BACKEND-PARITY.4.3.0 converts the broad helper leaf into .4.3.1-.4.3.9 with explicit dependencies and acceptance: core four-kind stores/access/entry-match, scalar/string, numeric, array, harray, codeblock/control/callback, capture/mark/input/cursor, diagnostic output, and exhaustive no-drift. String `.4.3.2` and numeric `.4.3.3` are closed; array family `.4.3.4` is active."
evidence_update_2026_07_13_harray_closeout: "Array family .4.3.4 is closed at 99/99. LUA-BACKEND-PARITY.4.3.5.5 closes all 13 ordinary harray names at 103/103 after construction/splicing .1, deterministic views .2, copied transforms/receivers .3, and named mutation .4. Codeblock/control/tree-callback parent .4.3.6 is active."
reverify: "bash scripts/check_task_tree_metadata.sh && bash scripts/check_doctrines.sh"
---

## Fact

Lua helper/value execution is not one implementation slice. The active ordered
owners under `docs/tasks/LUA-BACKEND-PARITY.md` are:

1. `.4.3.1`: scalar/array/harray/codeblock/null value identity, local stores,
   structural access/assignment, snapshots, and entry/match reads;
2. `.4.3.2`: scalar/string, recursively split into `.4.3.2.1` pure values/
   comparisons/receivers and `.4.3.2.2` regex/split/statement mutation;
3. `.4.3.3`: numeric helpers, aliases, symbol callees, reducers, and receivers;
4. `.4.3.4`: array construction, transforms, mutation, bridges, child push, and
   numeric terminals;
5. `.4.3.5`: harray/hash construction, views, transforms, mutation, and receivers;
6. `.4.3.6`: codeblock values, structured controls, generic final-codeblock
   equivalence, scoped `with`, and array/harray tree callbacks;
7. `.4.3.7`: capture slices, named marks, input views, and explicit cursor state;
8. `.4.3.8`: parse-result-neutral diagnostic output over a caller-owned event seam;
9. `.4.3.9`: exhaustive 239-name execution/API/book/status no-drift.

The regex/split/mutation child `.4.3.2.2` is itself ordered as `.1` helper regex values and `matches`, `.2` pure
split/receiver bridging, `.3` scalar regex substitution, `.4` explicit array split replacement, and `.5` corpus/
public no-drift. This keeps PCRE2 policy, value typing, scalar mutation, and aggregate mutation in separate commits.

The array family is closed. Harray parent `.4.3.5` is now split into `.0` audit, `.1` construction/splicing,
`.2` deterministic views, `.3` copied transforms/receivers, `.4` named mutation, and `.5` no-drift.

Each leaf may split again before code. The ordering follows runtime mechanism
dependencies, not catalog size, and keeps recognized call-name admission
separate from executable parity.

Related facts: [[lua-runtime-rule-interpreter]], [[lua-actionir-contract-resolver]],
[[lua-actionir-ast-parser]], [[spec-lifecycle-retv-order]],
[[generic-trailing-codeblock-argument-correction]].
