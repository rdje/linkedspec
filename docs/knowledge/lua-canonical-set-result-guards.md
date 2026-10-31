---
id: lua-canonical-set-result-guards
title: Safe Lua canonical set results use existing actual-kind source guards
answers:
  - "which Lua owner guards canonical set result methods"
  - "does Lua canonical set already support direct bracket reads"
  - "does Lua selected set Bool already skip incompatible operands"
  - "does Lua canonical set composition add interpreter chunk locals"
date: 2026-10-31
status: installed PUC5.5.1/LuaJIT59.5 targeted-checked; full admission separate
tags: [lua, set, assignment, selection, fluent, guards]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.3.59.5; set-result-lua-intake.json.gz retains actual producers/inputs/same61 checks53PASS8RED to61PASS and push65/loadfile/version per host;53 includes two compile scaffolds."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/set_result_composition_test.lua"
  - "bash tools/run_lua_project_data.sh luajit lua/test/set_result_composition_test.lua"
---

Atd45808592 direct Array/selected String Hash consumers retain values/evaluate
KV. Selected Bool/full12/direct reads/order/functions/with/codeblock/errors and
alias provenance already work. receiver_mutation.is_canonical_set_result_source
admits canonical exact two positional args/plain target/source_method/recognized
RHS to existing fluent/computed actual-kind guards. Bare/numeric RHS already valid;
assignment alias '=' stays excluded. Function attaches to existing namespace, no
interpreter chunk locals. Setter/default/push/copy/function/arity/parser/schema
and remaining interpreter exact; runner gains three-line block.

Same61 checks53PASS/8RED to61PASS per installed PUC5.5.1/LuaJIT2.1.1788460057.
Original53 includes two passing compile scaffolds in failing groups. Eleven
values/error/eight public source shapes retain native/restoredSpec/plan/fresh
module in one process; nine healthy values/all errors/shapes exact. Nearest
push65/loadfile/version pass per host, focused stderr empty. Initial activation
clean-tree assertion rejected prepared normal before activation writes; exact
guarded resume, no runtime execution or RED credit. Rebuild runtime/apps;
owned free-source selection21 next, no declared5.4/unsafe runner/formatter/
isolated package/peer wider default-domain/full admission claim.
