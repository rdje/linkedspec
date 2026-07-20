---
id: lua-duplicate-regex-slot-identity-admission
title: "PUC Lua and LuaJIT match required authored regex slots directly through one shared implementation"
answers:
  - "is Lua duplicate regex slot identity implemented"
  - "is LuaJIT duplicate regex slot identity implemented"
  - "how does Lua match a required duplicate regex slot"
  - "does Lua still reindex a singleton regex match"
  - "where does Lua validate compiled regex slot identity"
  - "how does generated Lua preserve duplicate regex slots"
  - "what trace event reports Lua regex slot identity"
  - "what proves dual ABI Lua duplicate regex slot parity"
date: 2026-07-20
status: current and dual-ABI composed-admitted through FUTURE-PARITY-BACKLOG.9.1.8.1.6
tags: [lua, luajit, regex, slot-identity, and, or, repetition, descriptor, generated-source, diagnostics, parity, FUTURE-PARITY-BACKLOG]
evidence: "Lua match_runtime_regex_slot selects an existing RuntimeRegexAlternative from the full compiled alternation and returns its authored zero-based index without singleton compilation or reindexing. Ordered and repeated execution use that route; OR/default choice retains full-alternation earliest-start/first-authored selection. Compiled action edges map parent indexes to {target_rule,child_regex_index}. validate_compiled_regex_slot_identities protects compile, engine, emitter, and generated-plan boundaries. Descriptors and emitted v2 modules publish linkedspec-duplicate-regex-slot-identity-v1 while normalized SpecFile JSON and exact {label,family} plans remain unchanged. lua_runtime:regex_slot_selected and stable spec/runtime/generated diagnostics project portable identity. One shared 15-role consumer passes 112 assertions on both PUC Lua and LuaJIT; the complete Lua driver passes 177 package tests per ABI, primary 65x2, and corpus 105/105. Governance is 6 complete + 1 pending with 46 rejected mutations."
evidence_update_2026_07_20_recurring_closeout: "Lua's recorded 6+1/46 count is its historical admission boundary. FUTURE-PARITY-BACKLOG.9.1.8.1.7 subsequently composes both Lua ABIs with Perl, Rust, Dart, and Julia; current duplicate-slot governance is 7 complete / 0 pending with 59 rejected mutations."
reverify: "bash tools/run_lua_local.sh && python3 tools/check_duplicate_regex_slot_identity_contract.py"
---

Lua's required-slot path and choice path now use one compiled alternation but
different operations. `match_runtime_regex_slot` addresses the already-known
authored alternative directly under the rule's seek/consume policy. The
returned match therefore carries that alternative's original index. The
ordinary full-alternation matcher remains the owner of genuine choice and its
earliest-start, first-authored tie break.

Compiled action edges translate a parent alternative index into portable target
rule plus child regex index. This makes a cross-target parent sequence of zero
then one trace as `First#0`, `Second#0`. The same mapping feeds the ordered
invariant and `lua_runtime:regex_slot_selected`. Repeated AND restarts the
required sequence for every iteration.

`validate_compiled_regex_slot_identities` checks the executed child index, its
agreement with the target reference, the target's authored regex bound, and the
parent dispatch bound. It runs after compilation and before runtime-engine,
emitter, and generated-plan trust boundaries. Invalid identity uses
`regex_slot_identity_invalid` / `validate_compiled_rule`; ordered identity loss
uses `ordered_regex_slot_identity_lost` / `execute_rule`.

Generated Lua remains contract v2/format 2. It embeds canonical normalized
`SpecFile` JSON as ASCII hexadecimal, reconstructs typed compiled state through
the ordinary compiler, and keeps every public plan row exactly `{label,
family}`. The same shared test source executes all 15 declared roles on PUC Lua
and LuaJIT, including loaded/reconstructed, descriptor, emitted/generated,
native/generated trace, primary, and diagnostic boundaries.

Related: [[duplicate-regex-slot-identity-contract]],
[[duplicate-regex-slot-identity-cross-backend-audit]],
[[lua-runtime-matching-state]], [[lua-runtime-rule-interpreter]],
[[lua-generated-source-v2-rule-local-cursor]], and
[[FUTURE-PARITY-BACKLOG]].
