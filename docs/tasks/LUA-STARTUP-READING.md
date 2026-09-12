# LUA-STARTUP-READING: Bounded Lua reading and repair ownership

## Metadata

- Tree ID: `LUA-STARTUP-READING`
- Status: `active` / approved capacity; source reading 0/51
- Roadmap lane: `Session required reading / SESSION-STARTUP-READING.3.6`
- Created: `2026-09-12`
- Last updated: `2026-09-12`
- Owner: repo-local workflow
- Decomposition owner: `SESSION-STARTUP-READING.3.6.0`

## Goal

Read every Lua baseline byte and current delta in bounded committed slices.
Preserve comprehension, exact coverage and actionable repair ownership. Startup
.3.6 retains the prerequisite role; reading does not establish defect remediation.

## Non-Goals

- Enumeration, hashes and consumer execution grant no unread-source credit.
- Source repairs remain behind startup .3/.4/.5; existing findings retain their owners.
- No capacity increase, archive rewrite, source change or parked-feature activation.
- ADR0117 closes Julia reading only; no Lua milestone exception is inferred.

## Acceptance Criteria

- Cover every baseline/current entry, mode/blob and byte exactly once.
- Bound each reading child to 1500 fragments / 65536 bytes; use smaller untruncated viewing windows.
- Record comprehension, Knowledge reconciliation, findings and focused proof per child.
- Preserve generated tables and both-ABI test sources without sampling.
- Measure each resulting candidate and obtain any required capacity disposition under .4.
- Keep the book, roadmaps and all current frontier pointers aligned.
- Independently audit source identity, committed child evidence and activations before .3 closes reading.
- Keep all repair nodes open until their own acceptance criteria and verification pass.

## Exact Baseline And Range Plan

- Source baseline: `baeb984e36a94a15951cd23d4c52def5064cdaca`.
- Planning activation: `9824c097148235268964acbdf47984d9933753a8`.
- All 99 paths / 71,268 physical lines / 2,732,450 bytes remain baseline-identical.
- The 51 groups contain 149 exact ranges, including two byte windows for one oversized MCP line.
- Per-window fragments total 71,269; splitting one physical line adds one fragment without duplicating bytes.
- Inventory SHA-256: `6906b93bb89cf5c03764ad0cd0d934f107f0e6d6c9a85f9529d22fcccbbde304`.
- Ordered range SHA-256: `81c58b8319def28af518fb134a3787513fe746f0f0f73bcacb0e20b9ede1c9d6`.
- Child-summary SHA-256: `f56ecac262800bd3cc1e6bba0cc25bfe22f095c3dfee41f1c6595d4200145290`.
- Coordinates are one-based inclusive LF physical lines or absolute file bytes; both byte windows decode as UTF-8.
- Current physical reading: 0/51 children, 0/71,269 fragments and 0/2,732,450 bytes.
- Exact independent replay and capacity evidence: `docs/knowledge/lua-startup-reading-coverage.md`.

## Task Tree

- ID: `LUA-STARTUP-READING`
  Status: `active`
  Goal: Complete bounded Lua reading and preserve every finding's repair ownership.
  Children: `.1`, `.2`, `.3`, `.4`

- ID: `LUA-STARTUP-READING.1`
  Status: `active`
  Goal: Read and understand all 51 exact groups in numeric order.
  Dependencies: Startup .3.6.0 committed; .4 capacity disposition; clean activation for every child.
  Children: `.1.1-.1.51`
  Acceptance: Every child records complete physical coverage, comprehension, Knowledge reconciliation, actionable findings and focused proof before committing.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.1`
  Status: `pending`
  Goal: Read and understand group 1: README.md.
  Scope: `lua/README.md` lines 1-945
  Baseline evidence: 945 fragments / 65532 bytes; ordered range SHA-256 `cd9b7c3a88e7a87a74155f4c7f14b8a3fbf260dcbb0a1ff196a03769e59c505b`.
  Dependencies: .4 capacity disposition and startup .3.6.0 commit.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.2`
  Status: `pending`
  Goal: Read and understand group 2: README.md through action_call_names.lua.
  Scope: `lua/README.md` lines 946-1377; `lua/bin/corpus_runner.lua` lines 1-17; `lua/bin/linkedspec-lua` lines 1-31; `lua/native/filesystem_native.c` lines 1-92; `lua/native/mcp_system.c` lines 1-85; `lua/native/regex_pcre2.c` lines 1-233; `lua/src/linkedspec/action_ast.lua` lines 1-371; `lua/src/linkedspec/action_call_names.lua` lines 1-239
  Baseline evidence: 1500 fragments / 54321 bytes; ordered range SHA-256 `edbc6d329884611882069b9d24de3a8f4eae4764b9f8f66306fab982cef67934`.
  Dependencies: .1.1 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.3`
  Status: `pending`
  Goal: Read and understand group 3: action_call_names.lua through action_parser.lua.
  Scope: `lua/src/linkedspec/action_call_names.lua` lines 240-317; `lua/src/linkedspec/action_contracts.lua` lines 1-700; `lua/src/linkedspec/action_parser.lua` lines 1-722
  Baseline evidence: 1500 fragments / 50175 bytes; ordered range SHA-256 `ba94240ececbe936a8f99a4bdc0651f87cf7aaad1e2eb9a348fa6a2e98166f40`.
  Dependencies: .1.2 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.4`
  Status: `pending`
  Goal: Read and understand group 4: action_parser.lua through bounded_child_parse_authority.lua.
  Scope: `lua/src/linkedspec/action_parser.lua` lines 723-1627; `lua/src/linkedspec/bounded_child_parse_authority.lua` lines 1-595
  Baseline evidence: 1500 fragments / 58518 bytes; ordered range SHA-256 `b48fca781d6ab629076a66a214be4b0e1fb9b56f8142477a0e224bf0b5e3fbc4`.
  Dependencies: .1.3 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.5`
  Status: `pending`
  Goal: Read and understand group 5: bounded_child_parse_authority.lua through compiled_spec.lua.
  Scope: `lua/src/linkedspec/bounded_child_parse_authority.lua` lines 596-1206; `lua/src/linkedspec/compiled_spec.lua` lines 1-889
  Baseline evidence: 1500 fragments / 55335 bytes; ordered range SHA-256 `ac55758901370f425dfde54ee7124efb90a4c5472ec551136883b38c61d3dfc7`.
  Dependencies: .1.4 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.6`
  Status: `pending`
  Goal: Read and understand group 6: compiled_spec.lua through init.lua.
  Scope: `lua/src/linkedspec/compiled_spec.lua` lines 890-1529; `lua/src/linkedspec/corpus.lua` lines 1-524; `lua/src/linkedspec/corpus_runner.lua` lines 1-102; `lua/src/linkedspec/init.lua` lines 1-234
  Baseline evidence: 1500 fragments / 58462 bytes; ordered range SHA-256 `682b3852a6e7ad6504ca42236a8b84f91d5eeb38d472836d4831100c5b661347`.
  Dependencies: .1.5 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.7`
  Status: `pending`
  Goal: Read and understand group 7: init.lua through interpreter.lua.
  Scope: `lua/src/linkedspec/init.lua` lines 235-318; `lua/src/linkedspec/interpreter.lua` lines 1-1416
  Baseline evidence: 1500 fragments / 53644 bytes; ordered range SHA-256 `9617f765df2d7cbefd92c6990395f31b66134368269fd0df84395d9d08685dbe`.
  Dependencies: .1.6 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.8`
  Status: `pending`
  Goal: Read and understand group 8: interpreter.lua.
  Scope: `lua/src/linkedspec/interpreter.lua` lines 1417-2916
  Baseline evidence: 1500 fragments / 52134 bytes; ordered range SHA-256 `7ddf7c6ea7587c413f14adc04d4a6c36b2d1f0ad2bea9ca73b656a3f9627b00f`.
  Dependencies: .1.7 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.9`
  Status: `pending`
  Goal: Read and understand group 9: interpreter.lua.
  Scope: `lua/src/linkedspec/interpreter.lua` lines 2917-4416
  Baseline evidence: 1500 fragments / 58443 bytes; ordered range SHA-256 `6a6df80d62f8e687d41b08451bdeb320506faff6325cf7a746f51e043074a016`.
  Dependencies: .1.8 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.10`
  Status: `pending`
  Goal: Read and understand group 10: interpreter.lua through json.lua.
  Scope: `lua/src/linkedspec/interpreter.lua` lines 4417-5634; `lua/src/linkedspec/json.lua` lines 1-282
  Baseline evidence: 1500 fragments / 51687 bytes; ordered range SHA-256 `451384fb9c5e48d276ef26a2682c263a60745e846baf82f36ed688d7f3fc0922`.
  Dependencies: .1.9 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.11`
  Status: `pending`
  Goal: Read and understand group 11: json.lua through mcp_contract.lua.
  Scope: `lua/src/linkedspec/json.lua` lines 283-480; `lua/src/linkedspec/matching.lua` lines 1-500; `lua/src/linkedspec/mcp_contract.lua` lines 1-6
  Baseline evidence: 704 fragments / 22026 bytes; ordered range SHA-256 `493407d9e0e434460bfe168384c2086a5cce4e67003aaea21a222c5aa28b1073`.
  Dependencies: .1.10 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.12`
  Status: `pending`
  Goal: Read and understand group 12: mcp_contract.lua.
  Scope: `lua/src/linkedspec/mcp_contract.lua` bytes 261-65796
  Baseline evidence: 1 fragments / 65536 bytes; ordered range SHA-256 `a5985b6f4edc587dd10e3e963124c149cd97b4d42fe04a6e3e03f5755f86731c`.
  Dependencies: .1.11 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.13`
  Status: `pending`
  Goal: Read and understand group 13: mcp_contract.lua.
  Scope: `lua/src/linkedspec/mcp_contract.lua` bytes 65797-83164
  Baseline evidence: 1 fragments / 17368 bytes; ordered range SHA-256 `fdd776f35ec057bfc00cd19ef0a1ede2371bd55093d29f6ae51e6907685f3a5f`.
  Dependencies: .1.12 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.14`
  Status: `pending`
  Goal: Read and understand group 14: mcp_contract.lua through mcp_wire.lua.
  Scope: `lua/src/linkedspec/mcp_contract.lua` lines 8-8; `lua/src/linkedspec/mcp_contract_runtime.lua` lines 1-413; `lua/src/linkedspec/mcp_server.lua` lines 1-854; `lua/src/linkedspec/mcp_wire.lua` lines 1-232
  Baseline evidence: 1500 fragments / 53162 bytes; ordered range SHA-256 `d157ca1471a6078386594be0911d4d5e2d56fe29ead9d692ecf0053fec58ed67`.
  Dependencies: .1.13 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.15`
  Status: `pending`
  Goal: Read and understand group 15: mcp_wire.lua through recognition_transaction_runtime.lua.
  Scope: `lua/src/linkedspec/mcp_wire.lua` lines 233-511; `lua/src/linkedspec/primary_cli.lua` lines 1-381; `lua/src/linkedspec/recognition_transaction.lua` lines 1-699; `lua/src/linkedspec/recognition_transaction_runtime.lua` lines 1-141
  Baseline evidence: 1500 fragments / 51908 bytes; ordered range SHA-256 `8473f4c5be44a6cded592f0ab42146a777df62fd365b703324c8df741a8fce93`.
  Dependencies: .1.14 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.16`
  Status: `pending`
  Goal: Read and understand group 16: recognition_transaction_runtime.lua through semantic_index.lua.
  Scope: `lua/src/linkedspec/recognition_transaction_runtime.lua` lines 142-501; `lua/src/linkedspec/runtime_scoped_binding.lua` lines 1-102; `lua/src/linkedspec/scalar_numeric.lua` lines 1-192; `lua/src/linkedspec/semantic_compilation_outcome.lua` lines 1-253; `lua/src/linkedspec/semantic_index.lua` lines 1-593
  Baseline evidence: 1500 fragments / 46858 bytes; ordered range SHA-256 `96a35519ffd3e49916b79e25a81b9e376cc3090aee62bc5a63293d947ad7a0d3`.
  Dependencies: .1.15 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.17`
  Status: `pending`
  Goal: Read and understand group 17: semantic_index.lua through semantic_runtime_projection.lua.
  Scope: `lua/src/linkedspec/semantic_index.lua` lines 594-753; `lua/src/linkedspec/semantic_observation.lua` lines 1-119; `lua/src/linkedspec/semantic_query.lua` lines 1-1142; `lua/src/linkedspec/semantic_runtime_projection.lua` lines 1-79
  Baseline evidence: 1500 fragments / 53106 bytes; ordered range SHA-256 `5148785e3cf31a218ea26f11df0d3e783be1e4524eb8c8138fa0c4e01fd31ef5`.
  Dependencies: .1.16 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.18`
  Status: `pending`
  Goal: Read and understand group 18: semantic_runtime_projection.lua through semantic_static_projection.lua.
  Scope: `lua/src/linkedspec/semantic_runtime_projection.lua` lines 80-289; `lua/src/linkedspec/semantic_static_projection.lua` lines 1-1290
  Baseline evidence: 1500 fragments / 50709 bytes; ordered range SHA-256 `996883ed5d7c8cbbf051fb6672c848c2bd7836f49d44713495cea70f80a89844`.
  Dependencies: .1.17 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.19`
  Status: `pending`
  Goal: Read and understand group 19: semantic_static_projection.lua through source_emitter.lua.
  Scope: `lua/src/linkedspec/semantic_static_projection.lua` lines 1291-2438; `lua/src/linkedspec/sha256.lua` lines 1-187; `lua/src/linkedspec/source_emitter.lua` lines 1-165
  Baseline evidence: 1500 fragments / 52334 bytes; ordered range SHA-256 `69bb5c76b2bc703c39db1e27a4083c1f5658e33583d6abc9177d81ce668cda0c`.
  Dependencies: .1.18 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.20`
  Status: `pending`
  Goal: Read and understand group 20: source_emitter.lua through spec_ast.lua.
  Scope: `lua/src/linkedspec/source_emitter.lua` lines 166-789; `lua/src/linkedspec/source_location.lua` lines 1-436; `lua/src/linkedspec/source_location_runtime.lua` lines 1-325; `lua/src/linkedspec/spec_ast.lua` lines 1-115
  Baseline evidence: 1500 fragments / 54002 bytes; ordered range SHA-256 `3dba5254dfc4c319bfccce1ea072eb313f8e4099934ee5717343d0b79ba60114`.
  Dependencies: .1.19 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.21`
  Status: `pending`
  Goal: Read and understand group 21: spec_ast.lua through spec_loader.lua.
  Scope: `lua/src/linkedspec/spec_ast.lua` lines 116-1183; `lua/src/linkedspec/spec_loader.lua` lines 1-432
  Baseline evidence: 1500 fragments / 54561 bytes; ordered range SHA-256 `e4df52ef54026c29fb3b399c526d674d5b4c3201edbd796791d8cd7cda4be111`.
  Dependencies: .1.20 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.22`
  Status: `pending`
  Goal: Read and understand group 22: spec_loader.lua through spec_validator.lua.
  Scope: `lua/src/linkedspec/spec_loader.lua` lines 433-539; `lua/src/linkedspec/spec_parser.lua` lines 1-1250; `lua/src/linkedspec/spec_validator.lua` lines 1-143
  Baseline evidence: 1500 fragments / 44459 bytes; ordered range SHA-256 `f110fc4919916a4df56b309d98b4b2be58b619c30100ddb99bcf4887022198c3`.
  Dependencies: .1.21 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.23`
  Status: `pending`
  Goal: Read and understand group 23: spec_validator.lua through staged_ast_enrichment.lua.
  Scope: `lua/src/linkedspec/spec_validator.lua` lines 144-865; `lua/src/linkedspec/staged_ast_enrichment.lua` lines 1-778
  Baseline evidence: 1500 fragments / 54480 bytes; ordered range SHA-256 `56ec303aa8c4a6d47f54d40eef4a977642127eb0da7cfc4d74b4e03b23dccccb`.
  Dependencies: .1.22 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.24`
  Status: `pending`
  Goal: Read and understand group 24: staged_ast_enrichment.lua through staged_parse_job.lua.
  Scope: `lua/src/linkedspec/staged_ast_enrichment.lua` lines 779-2187; `lua/src/linkedspec/staged_capture_provenance.lua` lines 1-42; `lua/src/linkedspec/staged_parse_job.lua` lines 1-49
  Baseline evidence: 1500 fragments / 56196 bytes; ordered range SHA-256 `38f96a914d93193a8d3ebc02f24a4d806a12e36450859cc822bcec446daf5b82`.
  Dependencies: .1.23 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.25`
  Status: `pending`
  Goal: Read and understand group 25: staged_parse_job.lua through unicode_case_mapping.lua.
  Scope: `lua/src/linkedspec/staged_parse_job.lua` lines 50-264; `lua/src/linkedspec/staged_parser_registry.lua` lines 1-567; `lua/src/linkedspec/trace.lua` lines 1-500; `lua/src/linkedspec/trace_support.lua` lines 1-49; `lua/src/linkedspec/unicode_case_mapping.lua` lines 1-169
  Baseline evidence: 1500 fragments / 51794 bytes; ordered range SHA-256 `33b109f98ff932383f2a394953080da8776680afaea6b634f5d6a3d75ca80d81`.
  Dependencies: .1.24 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.26`
  Status: `pending`
  Goal: Read and understand group 26: unicode_case_mapping.lua.
  Scope: `lua/src/linkedspec/unicode_case_mapping.lua` lines 170-1669
  Baseline evidence: 1500 fragments / 35080 bytes; ordered range SHA-256 `899f29584aa57d08bbafabeb7e7840e98be6710a2beb66c418dcd09fa4274439`.
  Dependencies: .1.25 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.27`
  Status: `pending`
  Goal: Read and understand group 27: unicode_case_mapping.lua.
  Scope: `lua/src/linkedspec/unicode_case_mapping.lua` lines 1670-3169
  Baseline evidence: 1500 fragments / 35947 bytes; ordered range SHA-256 `29933fa8d627a20c344cab6e3c6a3f21827fd84ed2d8056f0b22161e21d64018`.
  Dependencies: .1.26 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.28`
  Status: `pending`
  Goal: Read and understand group 28: unicode_case_mapping.lua through unicode_rule_label.lua.
  Scope: `lua/src/linkedspec/unicode_case_mapping.lua` lines 3170-3846; `lua/src/linkedspec/unicode_rule_label.lua` lines 1-823
  Baseline evidence: 1500 fragments / 34274 bytes; ordered range SHA-256 `360d869362c55c7aebe072514dfa83394f735829b293831bfd946cbb7c1edd93`.
  Dependencies: .1.27 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.29`
  Status: `pending`
  Goal: Read and understand group 29: unicode_rule_label.lua through user_function_registry.lua.
  Scope: `lua/src/linkedspec/unicode_rule_label.lua` lines 824-920; `lua/src/linkedspec/user_function_definition_parser.lua` lines 1-235; `lua/src/linkedspec/user_function_definition_shell.lua` lines 1-801; `lua/src/linkedspec/user_function_registry.lua` lines 1-367
  Baseline evidence: 1500 fragments / 50431 bytes; ordered range SHA-256 `fac1b1db4576a3c34b6d471313bf0cfa74770a5aa63795210e589fc69fa3e85f`.
  Dependencies: .1.28 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.30`
  Status: `pending`
  Goal: Read and understand group 30: user_function_registry.lua through diagnostic_output_contract_test.lua.
  Scope: `lua/src/linkedspec/user_function_registry.lua` lines 368-539; `lua/test/body_fluent_whole_token_test.lua` lines 1-137; `lua/test/callable_codeblock_literal_contract_test.lua` lines 1-950; `lua/test/diagnostic_output_contract_test.lua` lines 1-241
  Baseline evidence: 1500 fragments / 60799 bytes; ordered range SHA-256 `f3f1e9a54ed0dbb2b52b171dcc5bf01141ae86b6deb0121f91d40d7eac08f093`.
  Dependencies: .1.29 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.31`
  Status: `pending`
  Goal: Read and understand group 31: diagnostic_output_contract_test.lua through inter_match_gap_capture_contract_test.lua.
  Scope: `lua/test/diagnostic_output_contract_test.lua` lines 242-327; `lua/test/duplicate_regex_slot_identity_contract_test.lua` lines 1-467; `lua/test/inter_match_gap_capture_contract_test.lua` lines 1-947
  Baseline evidence: 1500 fragments / 54442 bytes; ordered range SHA-256 `3289093b514031c30ff31b742148da9b5276d643fab27c77daccdc0693d101fc`.
  Dependencies: .1.30 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.32`
  Status: `pending`
  Goal: Read and understand group 32: inter_match_gap_capture_contract_test.lua through mcp_contract_lua_binding_test.lua.
  Scope: `lua/test/inter_match_gap_capture_contract_test.lua` lines 948-1462; `lua/test/logical_helper_contract_test.lua` lines 1-280; `lua/test/map_leaves_mutation_contract_test.lua` lines 1-696; `lua/test/mcp_contract_lua_binding_test.lua` lines 1-9
  Baseline evidence: 1500 fragments / 61938 bytes; ordered range SHA-256 `1448f96de3281ed9707eeffa0a30b74e21193179ae801ce6cc9dbaddb0d718e5`.
  Dependencies: .1.31 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.33`
  Status: `pending`
  Goal: Read and understand group 33: mcp_contract_lua_binding_test.lua through mcp_server_lua_stdio_test.lua.
  Scope: `lua/test/mcp_contract_lua_binding_test.lua` lines 10-169; `lua/test/mcp_server_lua_admission_test.lua` lines 1-663; `lua/test/mcp_server_lua_dispatch_test.lua` lines 1-484; `lua/test/mcp_server_lua_stdio_test.lua` lines 1-193
  Baseline evidence: 1500 fragments / 63081 bytes; ordered range SHA-256 `0138435828188c9efec0c835dc99756023ac610d54217bca56ee05e8d53e7412`.
  Dependencies: .1.32 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.34`
  Status: `pending`
  Goal: Read and understand group 34: mcp_server_lua_stdio_test.lua through recursive_observation_contract_test.lua.
  Scope: `lua/test/mcp_server_lua_stdio_test.lua` lines 194-468; `lua/test/progressive_span_dispatch_contract_test.lua` lines 1-464; `lua/test/project_data_storage_test.lua` lines 1-48; `lua/test/recognition_transaction_contract_test.lua` lines 1-571; `lua/test/recursive_observation_contract_test.lua` lines 1-142
  Baseline evidence: 1500 fragments / 59616 bytes; ordered range SHA-256 `4aaa093775ad1c374ee3383eaa7fed860790bcab924804476f630f69ebb549ee`.
  Dependencies: .1.33 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.35`
  Status: `pending`
  Goal: Read and understand group 35: recursive_observation_contract_test.lua through root_rule_selection_core_test.lua.
  Scope: `lua/test/recursive_observation_contract_test.lua` lines 143-454; `lua/test/repeated_action_result_contract_test.lua` lines 1-416; `lua/test/root_rule_selection_admission_test.lua` lines 1-568; `lua/test/root_rule_selection_core_test.lua` lines 1-204
  Baseline evidence: 1500 fragments / 55021 bytes; ordered range SHA-256 `eba36de062d16494d3302a19f1c53aa03481e8a55d287ef9c69b52f704cc47e8`.
  Dependencies: .1.34 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.36`
  Status: `pending`
  Goal: Read and understand group 36: root_rule_selection_core_test.lua through rule_local_cursor_execution_test.lua.
  Scope: `lua/test/root_rule_selection_core_test.lua` lines 205-278; `lua/test/root_rule_selection_routes_test.lua` lines 1-353; `lua/test/rule_local_cursor_contract_test.lua` lines 1-486; `lua/test/rule_local_cursor_descriptor_test.lua` lines 1-260; `lua/test/rule_local_cursor_execution_test.lua` lines 1-327
  Baseline evidence: 1500 fragments / 55300 bytes; ordered range SHA-256 `c19db68ddab9476cd7c6ef7f976ead22388e5a89daceeadc37bc4ffcb20ff763`.
  Dependencies: .1.35 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.37`
  Status: `pending`
  Goal: Read and understand group 37: rule_local_cursor_execution_test.lua through run.lua.
  Scope: `lua/test/rule_local_cursor_execution_test.lua` lines 328-424; `lua/test/rule_local_cursor_generated_source_test.lua` lines 1-439; `lua/test/rule_local_cursor_normalization_test.lua` lines 1-225; `lua/test/rule_local_cursor_option_removal_test.lua` lines 1-276; `lua/test/run.lua` lines 1-463
  Baseline evidence: 1500 fragments / 59736 bytes; ordered range SHA-256 `5201d5604cd714055186fb76ae7c3b8f32576b3e0b6c08bcc96d8bed25c87a60`.
  Dependencies: .1.36 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.38`
  Status: `pending`
  Goal: Read and understand group 38: run.lua.
  Scope: `lua/test/run.lua` lines 464-1955
  Baseline evidence: 1492 fragments / 65483 bytes; ordered range SHA-256 `53217793de0f5e01e545e422435ded9aa1f395fd8c3cda097625283c92b324c7`.
  Dependencies: .1.37 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.39`
  Status: `pending`
  Goal: Read and understand group 39: run.lua.
  Scope: `lua/test/run.lua` lines 1956-3352
  Baseline evidence: 1397 fragments / 65503 bytes; ordered range SHA-256 `dd857ba1f7f956526551f9f512ea5be0248837876dc7d4e14b62dd3a9da5c673`.
  Dependencies: .1.38 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.40`
  Status: `pending`
  Goal: Read and understand group 40: run.lua.
  Scope: `lua/test/run.lua` lines 3353-4852
  Baseline evidence: 1500 fragments / 62438 bytes; ordered range SHA-256 `7599b9e3b36b156da6f8c21ae9290f705e848ea6ead86e10fc88017b8ac7142d`.
  Dependencies: .1.39 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.41`
  Status: `pending`
  Goal: Read and understand group 41: run.lua.
  Scope: `lua/test/run.lua` lines 4853-6352
  Baseline evidence: 1500 fragments / 64241 bytes; ordered range SHA-256 `b334de83df1b27f93651825d32d96be8962d8a49f5a5c2209c6b1633cc07de20`.
  Dependencies: .1.40 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.42`
  Status: `pending`
  Goal: Read and understand group 42: run.lua.
  Scope: `lua/test/run.lua` lines 6353-7852
  Baseline evidence: 1500 fragments / 61135 bytes; ordered range SHA-256 `109237226136012ab79b71665b6ea225a776eb20b151e1a549c26f9e6c06267f`.
  Dependencies: .1.41 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.43`
  Status: `pending`
  Goal: Read and understand group 43: run.lua.
  Scope: `lua/test/run.lua` lines 7853-9352
  Baseline evidence: 1500 fragments / 52604 bytes; ordered range SHA-256 `f8161e6ed1d028a6c066977ad29db3091cadc1002ad05c7831a71a7deb03a703`.
  Dependencies: .1.42 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.44`
  Status: `pending`
  Goal: Read and understand group 44: run.lua through semantic_index_query_kernel_test.lua.
  Scope: `lua/test/run.lua` lines 9353-9517; `lua/test/semantic_index_call_core_test.lua` lines 1-414; `lua/test/semantic_index_call_staged_generated_test.lua` lines 1-392; `lua/test/semantic_index_compilation_foundation_test.lua` lines 1-375; `lua/test/semantic_index_query_kernel_test.lua` lines 1-154
  Baseline evidence: 1500 fragments / 58471 bytes; ordered range SHA-256 `ccdcfd70b869e38fc3f3ddf8a7511e76855abf5dcff2e05876fade1c099397de`.
  Dependencies: .1.43 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.45`
  Status: `pending`
  Goal: Read and understand group 45: semantic_index_query_kernel_test.lua through semantic_index_runtime_observation_native_test.lua.
  Scope: `lua/test/semantic_index_query_kernel_test.lua` lines 155-861; `lua/test/semantic_index_runtime_observation_generated_routes_test.lua` lines 1-536; `lua/test/semantic_index_runtime_observation_native_test.lua` lines 1-257
  Baseline evidence: 1500 fragments / 59366 bytes; ordered range SHA-256 `368dfb410954a394d22b374c7803e8bd27a15448f42e2d759121efcaf8bfdf5d`.
  Dependencies: .1.44 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.46`
  Status: `pending`
  Goal: Read and understand group 46: semantic_index_runtime_observation_native_test.lua through semantic_index_static_remaining_test.lua.
  Scope: `lua/test/semantic_index_runtime_observation_native_test.lua` lines 258-548; `lua/test/semantic_index_runtime_projection_test.lua` lines 1-472; `lua/test/semantic_index_source_foundation_test.lua` lines 1-438; `lua/test/semantic_index_static_graph_test.lua` lines 1-226; `lua/test/semantic_index_static_remaining_test.lua` lines 1-73
  Baseline evidence: 1500 fragments / 62032 bytes; ordered range SHA-256 `d9b9711ece56ff8f978153b81464f3d1701cd3a84adf8609e692e46bead50002`.
  Dependencies: .1.45 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.47`
  Status: `pending`
  Goal: Read and understand group 47: semantic_index_static_remaining_test.lua through staged_ast_enrichment_contract_test.lua.
  Scope: `lua/test/semantic_index_static_remaining_test.lua` lines 74-337; `lua/test/semantic_introspection_lua_admission_test.lua` lines 1-659; `lua/test/source_boundary_compatibility_aliases_test.lua` lines 1-337; `lua/test/staged_ast_enrichment_contract_test.lua` lines 1-240
  Baseline evidence: 1500 fragments / 58749 bytes; ordered range SHA-256 `ebf2c096652b76b88e286946976aeb3e61f90a1be006d0ef23d48225f3dbdecd`.
  Dependencies: .1.46 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.48`
  Status: `pending`
  Goal: Read and understand group 48: staged_ast_enrichment_contract_test.lua.
  Scope: `lua/test/staged_ast_enrichment_contract_test.lua` lines 241-1740
  Baseline evidence: 1500 fragments / 62275 bytes; ordered range SHA-256 `e246f1a148b9bc27c539469ffa83a8afa48b7f782caa2934e908bc528c6b03c8`.
  Dependencies: .1.47 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.49`
  Status: `pending`
  Goal: Read and understand group 49: staged_ast_enrichment_contract_test.lua through unicode_rule_label_identity_routes_test.lua.
  Scope: `lua/test/staged_ast_enrichment_contract_test.lua` lines 1741-2094; `lua/test/standalone_lifecycle_block_contract_test.lua` lines 1-228; `lua/test/typed_source_location_contract_test.lua` lines 1-435; `lua/test/unicode_rule_label_classifier_test.lua` lines 1-98; `lua/test/unicode_rule_label_identity_routes_test.lua` lines 1-385
  Baseline evidence: 1500 fragments / 57785 bytes; ordered range SHA-256 `625df2d24b896f1788c4dffc59193536acfece01368b90ff8a8cf670bf854b7d`.
  Dependencies: .1.48 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.50`
  Status: `pending`
  Goal: Read and understand group 50: unicode_rule_label_identity_routes_test.lua through write_vivification_contract_test.lua.
  Scope: `lua/test/unicode_rule_label_identity_routes_test.lua` lines 386-474; `lua/test/unicode_rule_label_negative_isolation_test.lua` lines 1-746; `lua/test/unicode_rule_label_routes_test.lua` lines 1-266; `lua/test/write_vivification_contract_test.lua` lines 1-399
  Baseline evidence: 1500 fragments / 61835 bytes; ordered range SHA-256 `9ab4482b49acb20b3434666f2d1cd8001bd7bbb0054e6335ac93178a49d93421`.
  Dependencies: .1.49 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.1.51`
  Status: `pending`
  Goal: Read and understand group 51: write_vivification_contract_test.lua through progressive_span_dispatch_authority_test.lua.
  Scope: `lua/test/write_vivification_contract_test.lua` lines 400-542; `lua/test_dormant/progressive_span_dispatch_authority_test.lua` lines 1-586
  Baseline evidence: 729 fragments / 28118 bytes; ordered range SHA-256 `e94181f3ffd688eed7f1cbf12b1bca08b3b412ecbcfa110fb12fcf6b8439a8f2`.
  Dependencies: .1.50 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2`
  Status: `pending`
  Goal: Own every newly confirmed Lua defect or coverage gap without losing existing shared repair ownership.
  Acceptance: Define concrete causal evidence, affected behavior and repair/verification children before implementing any finding; preserve startup prerequisites and all earlier owners.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.3`
  Status: `pending`
  Goal: Independently close Lua reading and route the remaining supporting-code lanes.
  Dependencies: All .1 reading children committed and every finding repair-owned.
  Acceptance: Audit exact coverage/current deltas, comprehension, unique commits and first-parent activations. Preserve all repairs and satisfy canonical milestone proof or a newly explicit scoped exception before closing .1/startup .3.6.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.4`
  Status: `done`
  Goal: Resolve coherent Lua reading evidence capacity before activating source-reading children.
  Children: `.4.1`, `.4.2`
  Acceptance: Preserve readable unique evidence and existing controls; measure the complete activity, record any exact proposal and authority, and verify an approved implementation before source reading needs that allowance.
  Verification: Explicit ADR0118 approval admits exactly eleven finite Lua evidence controls and the .14-only focused/receipt exception. The complete actual-plus-57-unit reserve fits; independent and production history models agree on four rollovers per collection. Actual routing functions pass 125 threshold and 54 authorization cases. Previous source, cards, decisions, task evidence and immutable history remain exact. Lua .4/.4.2 close; source reading remains 0/51 and .1.1 follows the clean commit. Later verification and startup repair prerequisites remain unchanged.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.14 - admit approved Lua reading evidence capacity` (Lua capacity container)

- ID: `LUA-STARTUP-READING.4.1`
  Status: `done`
  Goal: Prepare a concrete activity-sized Lua evidence-capacity disposition from the frozen 51-child plan.
  Activation commit: `7f97cb630e7f5a64915df8febdab078b9d5be38e`.
  Dependencies: Startup .3.6.0 committed with clean handoff.
  Acceptance: Reverify the actual candidate and comparable Julia reading growth; project Knowledge/task/map/decision/history counts, lines, bytes and rollovers across all 51 children plus bounded support work. Evaluate lossless alternatives, identify exact necessary controls and verification sequencing, and record a reviewable proposal before any implementation. Existing Julia-only allowances do not authorize Lua increases or exceptions.
  Verification tier: `focused`
  Focused checks: Frozen Lua scope and Julia growth replay; independent and production-function history models; exact current-plus-reserve metrics; previous source/task/card/decision/history/control preservation; Knowledge, memory, both histories, rendered book and normal doctrines.
  Canonical trigger: `none` — a documentation-only capacity proposal. Implementation changes infrastructure and needs canonical proof or a new explicit exception; no registry or guard change belongs here.
  Verification: Lua .4.1 proposes eleven finite evidence-limit changes for 51 reading leaves plus six support units. Exact 57-unit reserve and independent/production history models pass; each history needs four rollovers with only two slots available. The proposal preserves all source, evidence, controls and pending repairs. Explicit approval of the exact limits and containment .14-only focused/receipt exception is required before implementation; Lua .4.2 owns the decision. Source reading remains 0/51. Source/range and 52-commit growth replays remain exact. Both actual-function history legs match all 57 modeled records and four rollover boundaries; maximal manifest rows are 576 / 612 bytes. Preservation passes 2426 prior task nodes and 2206 source/card/decision/history/control files, exact history suffixes/question rows, five current decision pointers and all 27 rendered limitations. Eleven proposed scalars match exact objects while the registry remains unchanged. Knowledge generation (1085 facts / 8735 keys), explicit memory, both history checks, book build and diff check pass. All current controls and complete current-plus-57-unit proposed reserves pass; normal doctrine hooks govern landing.
  Commit: `LUA-STARTUP-READING.4.1 - propose finite Lua evidence capacity and verification boundary`

- ID: `LUA-STARTUP-READING.4.2`
  Status: `done`
  Goal: Record the director's explicit disposition of the committed Lua capacity and verification proposal.
  Dependencies: .4.1 committed and a new explicit director decision; previous Julia approvals do not extend.
  Acceptance: Resolve the exact eleven controls and containment .14-only before-reading focused/canonical-receipt exception in Capacity proposal .4.1. If approved, record this disposition and a new accepted indexed ADR in the separately owned .14 implementation commit; no separate decision-only commit is required. If denied, preserve all evidence and identify another governed capacity/verification route. No source reading, control change or dependency build is authorized by this pending node.
  Verification: The director explicitly answered Granted on 2026-09-12 to all eleven proposed controls and the .14-only focused/canonical-receipt exception including before-reading execution. ADR0118 records acceptance in the .14 admission commit; all .4.1 proposal evidence remains exact. Explicit ADR0118 approval admits exactly eleven finite Lua evidence controls and the .14-only focused/receipt exception. The complete actual-plus-57-unit reserve fits; independent and production history models agree on four rollovers per collection. Actual routing functions pass 125 threshold and 54 authorization cases. Previous source, cards, decisions, task evidence and immutable history remain exact. Lua .4/.4.2 close; source reading remains 0/51 and .1.1 follows the clean commit. Later verification and startup repair prerequisites remain unchanged.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.14 - admit approved Lua reading evidence capacity` (approved disposition recorded with admission)

## Capacity proposal .4.1

This is a proposed boundary, not an accepted ADR or an implemented allowance.
The director decision must explicitly cover all eleven scalars and the .14-only
focused/canonical-receipt exception before full codebase reading. Normal hooks
and all later repair, milestone and final-push requirements remain unchanged.

Finite envelope: 51 source-reading children plus proposal, capacity admission,
independent capacity review, independent reading audit, reading closeout and one
contingency. Models, reserve arithmetic, alternatives and exact source/history
identity live in `docs/knowledge/lua-reading-evidence-capacity-proposal.md`.
Use the full resulting-candidate-plus-reserve check at implementation, retaining
all member limits and each actual leaf's checks. No unique evidence is discarded.

### change_history

- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":36,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":38,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
- Stable responsibility: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3`.
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":19919,"max_lines":35}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":21071,"max_lines":37}},"members":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["CHANGES.md","docs/history/changes/*.md","docs/history/changes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

### engineering_notes

- Previous routed limits: `{"max_bytes_per_file":524288,"max_files":32,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":27000}`
- New routed limits: `{"max_bytes_per_file":524288,"max_files":34,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":28000}`
- Stable responsibility: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3`.
- Previous routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":18678,"max_lines":31}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`
- New routed contract: `{"authority":"docs/decisions/0069-bounded-change-and-notes-history.md","control":"bounded_collection","lifecycle":"partitioned","member_limits":{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":19902,"max_lines":33}},"members":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"owner":"LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3","route_targets":["DEVELOPMENT_NOTES.md","docs/history/development-notes/*.md","docs/history/development-notes/manifest.jsonl"],"state":"current","transition_owners":null,"verifier":"document_history"}`

### knowledge_cards

- Previous routed limits: `{"max_bytes_per_file":65536,"max_files":1152,"max_lines_per_file":512,"max_total_bytes":6291456,"max_total_lines":79000}`
- New routed limits: `{"max_bytes_per_file":65536,"max_files":1152,"max_lines_per_file":512,"max_total_bytes":7340032,"max_total_lines":93000}`
- Stable responsibility: `docs/knowledge/`.

### task_evidence

- Previous routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":9437184,"max_total_lines":88000}`
- New routed limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":10485760,"max_total_lines":92000}`
- Stable responsibility: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.2`.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `LUA-STARTUP-READING.1.1` | `pending` | Read the first exact Lua README range after clean ADR0118 capacity admission. |

## Decisions

- `2026-09-12` .4.2: Explicit Granted approval closes .4.2 and admits the exact ADR0118 capacity under containment .14. The historical .4.1 proposal remains byte-exact.

- `2026-09-12` .4.1: Propose a finite 57-unit Lua envelope using observed Julia maxima and two matching history models; no control, source or standing verification changes.

- `2026-09-12`: Freeze 51 exact children under startup .3.6.0. Separate bounded ownership avoids exhausting the startup member; all aggregate controls remain active.
- `2026-09-12`: Keep the oversized generated MCP line as two independently UTF-8-decodable byte ranges; no sampling or generated-data exclusion.
- `2026-09-12`: Follow ADR0115's proportionate planning principle with a complete Lua capacity disposition under .4.1; prior concrete Julia allowances remain scoped to Julia.

## Open Questions

- .4.2 resolved: explicit Granted approval is recorded under ADR0118; no further decision is needed for this bounded admission.

## Blockers

- None for Lua .1.1 after clean admission. The finite ADR0118 allowance and each actual candidate remain checked; startup .80 and all later verification/repair prerequisites retain their owners.

## Verification Log

- `2026-09-12` .4.2: Explicit ADR0118 approval admits exactly eleven finite Lua evidence controls and the .14-only focused/receipt exception. The complete actual-plus-57-unit reserve fits; independent and production history models agree on four rollovers per collection. Actual routing functions pass 125 threshold and 54 authorization cases. Previous source, cards, decisions, task evidence and immutable history remain exact. Lua .4/.4.2 close; source reading remains 0/51 and .1.1 follows the clean commit. Later verification and startup repair prerequisites remain unchanged.

- `2026-09-12` .4.1: Lua .4.1 proposes eleven finite evidence-limit changes for 51 reading leaves plus six support units. Exact 57-unit reserve and independent/production history models pass; each history needs four rollovers with only two slots available. The proposal preserves all source, evidence, controls and pending repairs. Explicit approval of the exact limits and containment .14-only focused/receipt exception is required before implementation; Lua .4.2 owns the decision. Source reading remains 0/51.

- `2026-09-12`: Startup .3.6.0 independently verifies the frozen range plan before landing; detailed proof is retained in its startup node and the linked Knowledge card. No Lua source comprehension or new runtime gate result is claimed.

## Commit Log

- `2026-09-12` .4.2: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.14 - admit approved Lua reading evidence capacity` closes .4/.4.2 without source-reading credit.

- `2026-09-12` .4.1: `LUA-STARTUP-READING.4.1 - propose finite Lua evidence capacity and verification boundary`.

- `SESSION-STARTUP-READING.3.6.0 - freeze exact Lua reading ownership and capacity intake` owns creation of this plan.

## Changelog

- `2026-09-12` .4.2: Resolve approved capacity and route the first exact Lua reading child after clean admission.

- `2026-09-12` .4.1: Complete the coherent Lua capacity proposal; retain 0/51 reading and all existing repairs while explicit disposition is pending.

- `2026-09-12`: Create exact bounded Lua reading, repair, closeout and capacity ownership under startup .3.6.0.
