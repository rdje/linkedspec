---
id: lua-generated-source-v2-rule-local-cursor
title: "Lua generated-source v2 derives rule-local cursor policy from its minimal family plan"
answers:
  - "does Lua emit linkedspec generated source v2"
  - "what is the current Lua generated source format"
  - "does generated Lua serialize cursor policy"
  - "which generated Lua families seek and consume"
  - "how does generated Lua classify compact pipe"
  - "how does Lua reject generated source v1"
  - "does Lua validate generated contract before payload reconstruction"
  - "what expected and actual contract fields does Lua return"
  - "must old generated Lua modules be regenerated"
  - "which Lua generated v1 APIs were removed"
  - "how is Lua generated source v2 tested on PUC Lua and LuaJIT"
date: 2026-07-19
status: verified generated-source v2 and composed-admitted across both Lua ABIs
tags: [lua, luajit, generated-source, cursor, contract-v2, family-plan, fresh-process]
evidence: "FUTURE-PARITY-BACKLOG.9.1.7.4 advances source_emitter.lua and public exports to linkedspec-generated-source-v2/format 2, retains only label/family plan rows, derives exact family policy through interpreter.generated_family_execution_policy, maps compact Pipe to OR, and validates the literal contract marker before effective-spec payload decoding. A dedicated contract-driven test is identical at 44/106 RED on PUC Lua and LuaJIT and passes 106/106 after implementation over all ten families, two structural rows, deterministic direct/traced/fresh loading, corrupt payload, and stale-v1 expected/actual/regeneration rejection. Eight focused consumers total 2027 assertions per ABI; package remains 176/177 only at staged help, every primary ABI/environment leg remains 32/65, corpus remains 105/105, and neutral governance advances only to 69 files at 5 complete + 3 pending with 44 rejected mutations."
evidence_update_2026_07_19_admission: "Public option removal closes the last generated-call override seam. Admission .9.1.7.6 composes emitted v2 plus generated direct/trace exactly once on PUC Lua and LuaJIT, passing 119/119 per ABI and advancing governance to 69/6+2/49."
reverify: "bash tools/run_lua_local.sh; perl tools/check_generated_source_contract.pl; bash tools/run_python_project_data.sh tools/check_rule_local_cursor_contract.py; rg -n 'linkedspec-generated-source-v2|validate_generated_source_contract_v2|generated_family_execution_policy|emit_lua_source_v2' lua/src/linkedspec lua/test/rule_local_cursor_generated_source_test.lua"
---

## Fact

New Lua artifacts identify `linkedspec-generated-source-v2` / format 2. Their ordered plan remains exactly
`{label, family}`; neither `cursor_policy` nor `parse_mode` is serialized. At every generated rule entry, the
validated family derives:

- seek plus choice for `default`, `or_acode`, `or_bcode`, `rep_acode`, and `rep_bcode`;
- consume plus sequence for `and_single_acode`, `and_acode_seq`, `and_bcode`, `rep_and_acode`, and
  `rep_and_bcode`.

Compact Pipe is classified as the corresponding OR action/blind family. This is an explicit v2 correction of the
versioned v1 compatibility behavior; ordinary normalized execution and generated execution now agree without
changing the minimal plan.

An emitted module decodes its small source identity and plan labels, then calls
`validate_generated_source_contract_v2(...)` before decoding or compiling the embedded effective-spec payload.
A stale v1 marker therefore fails with stage `validate_generated_plan`, code
`generated_source_contract_version_mismatch`, exact `expected_contract` / `actual_contract`, source identity, and
guidance to regenerate from the originating `.spec`. A corrupt v2 payload reaches the separate
`generated_source_compile_failed` boundary. The public v1 validator, direct/traced executors, and emitter are no
longer exported; `emit_lua_source(...)` delegates to `emit_lua_source_v2(...)`.

The permanent dual-ABI consumer proves all ten family policies, minimal fields, native/generated agreement,
compact-Pipe choice, ordered-landmark and anchored-choice replacements, deterministic bytes, direct and traced
loading, fresh-process success, corrupt-v2 classification, and stale-v1-before-corrupt-payload ordering. The
existing contract-sourced interpreter-first 8/105 emitted-module proof remains registered in both ABI legs.

Related: [[lua-generated-source-family-plan]], [[lua-generated-source-emitter-core]],
[[lua-generated-source-fresh-process-isolation]], [[lua-generated-source-accepted-subset]],
[[lua-rule-local-cursor-execution]], and [[rule-local-cursor-neutral-contract]].
