---
id: lua-blind-target-regex-projection
title: Safe Lua blind calls validate declarations and project only actual regex dependencies
answers:
  - why did Lua reject blind rules without regex slots
  - can Lua call a pure-code blind child
  - how does Lua separate blind call refs from regex dependency refs
  - does a Lua pure-code child manufacture an entry slot
  - which Lua referenced coordinator runtime cases remain qualified
date: 2026-10-29
status: bounded48.5 repaired on installed PUC5.5 and LuaJIT; ordinary39.8.1 remains
tags: [lua, compiler, blind, dependency, regex, pure-code, validation]
evidence: "lua-referenced-intake.json.gz retains independent36-role baseline per safe host,17 valid compiler RED to22 accepts/14 exact rejects,10 portable runtime controls and3 qualified empty tails,22 fresh modules and809 assertions per host."
reverify: "bash tools/run_lua_project_data.sh puc lua/test/referenced_blind_targets_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/referenced_blind_targets_test.lua"
---

lua/src/linkedspec/spec_validator.lua check_target formerly applied a regex
count after every declared-rule lookup, including blind/bare AND. It now returns
after existence for blind ownership. Action slot selection, unknown targets and
indexed blind/bare AND errors retain existing checks and diagnostic records.

lua/src/linkedspec/compiled_spec.lua build_dependency_regex_state formerly
resolved every call ref to a pattern. Exclusively blind owners now project only
actual regex-bearing targets, keeping complete refs on the rule. Unknown refs
stay in the projection to raise; action/mixed owners stay strict with source
validation disabled. Existing copy/metatable storage semantics are unchanged.
An absent list creates no slot/map; a real empty String pattern remains a slot.

Both installed hosts independently showed5 healthy builds,17 intended-valid
compiler failures and14 intended rejects across original12/qualified12/pure8/
strict4 roles. Original normal reports17 failures63 assertions per host.
Validator-only repair accepts12 referenced roles but exposes5 pure dependency
errors. Final state accepts22 roles with14 full negative records/five healthy
full artifact-result records/four bypass-empty records unchanged.

Ten portable controls pass native/restored/plan/separate emitted execution per
host. Pure Child has0 patterns/slots, entry_slot is null; mixed calls keep Child
and Token refs but only Token/x in the regex map. Original5 emitted modules load
fresh; final22 per host have exact v2 metadata/plan. Five original healthy and12
validator-epoch modules are reused;5 previously rejected pure sources are newly
emitted. No interpreter/emitter/schema/family/policy change or regeneration of
existing valid sources is required.

Qualified blind_no_regex/marked_blind_target/markerless_blind already return
[[x],[]] on these Lua routes versus reference[[x]]. Canonical39.8.1 owns ordinary
progress/lifecycle reconciliation after20.1, before admission. No action-context
error or stale-array defect is inferred from Dart/Julia. Original parent-LX
runtime3 stays unqualified48.2.2.1. All36 compile controls remain covered; the
three qualified runtime rows have explicit normal exclusions and raw SDK/fresh
values retained. No portable coordinator parity credit.

New189/postcall274/progress234/duplicate slots112 pass809 assertions per safe
host, final focused/fresh stderr empty. Normal run.lua registration syntax loads
on both hosts; canonical selection23.4.1 remains required. No unsafe formatter,
declared5.4/full suite/isolated dependency/other backend admission claim.
