# LUA-STARTUP-READING: Bounded Lua reading and repair ownership

## Metadata

- Tree ID: `LUA-STARTUP-READING`
- Status: `active` / approved capacity; source reading 5/51
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
- Current physical reading: 5/51 children, 6,945/71,269 fragments and 283,881/2,732,450 bytes.
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
  Status: `done`
  Activation commit: `0bf9218e359fda81ff5a4ed412ebe014546f12ee`.
  Verification tier: `focused`
  Focused checks: Exact scoped source/range identity, complete untruncated reading and Knowledge reconciliation; selected documentation contracts, resulting pressure, memory, Knowledge, both histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading documentation leaf; no source/runtime change. Later reading closeout and push retain their canonical prerequisites.
  Goal: Read and understand group 1: README.md.
  Scope: `lua/README.md` lines 1-945
  Baseline evidence: 945 fragments / 65532 bytes; ordered range SHA-256 `cd9b7c3a88e7a87a74155f4c7f14b8a3fbf260dcbb0a1ff196a03769e59c505b`.
  Dependencies: .4 capacity disposition and startup .3.6.0 commit.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: Six untruncated windows: 1-160,161-320,321-480,481-640,641-800,801-945; all 945 LF fragments /65,532 bytes. Concatenation SHA-256 ac6176bb87a5c39cc13cbad39a5c4c0a6d2450872e68b0db92993c0d06f136d0; original scope/range digest unchanged.
  Comprehension: Per-rule cursor/repetition and lifecycle ownership; immutable semantic queries versus runtime observation; strict same-process MCP; staged/native/compiled/loaded composition; copied helpers versus mutations; eager logical versus lazy controls; typed dynamic codeblocks; Unicode capture/cursor/AST coordinates; CLI versus corpus execution and exact entry precedence. Canonical reconciliation and window evidence: docs/knowledge/lua-readme-reading-and-status-drift.md.
  Findings: .2.1/.2.1.1/.2.1.2 own the obsolete 176/177 current-failure prose, bounded correction and independent verification; all remain pending behind startup prerequisites. No new runtime defect or full-gate pass is claimed.
  Verification: Lua .1.1 reads README lines 1–945 completely: 945 fragments /65,532 bytes across six exact windows. Root selection 139 and logical helpers 359 pass per ABI; neutral root 54 / logical 26 mutations pass. Reading is 1/51; .2.1 owns stale present-tense gate guidance with repair and independent-verification children. All 99 Lua files remain baseline-identical; .1.2 is next. ADR0118 capacity, startup prerequisites and all earlier repairs remain. Dated six-window replay and complete current source/range proof pass. Selected proof totals 996 assertions; Knowledge, memory, both histories, candidate pressure and rendered book pass. Preservation verifies 1,372 prior Lua/card/decision/history files, 2,429 unchanged prior task nodes, exactly three new pending repairs, all 50 earlier known-limitation headings, frozen registry/policies and exact history suffixes. Knowledge is 1,087 facts / 8,745 keys; memory is 60 lines; histories are 433/368 lines without required rollover. All normal doctrine hooks govern landing.
  Commit: `LUA-STARTUP-READING.1.1 - read Lua README prefix and own stale gate guidance`

- ID: `LUA-STARTUP-READING.1.2`
  Status: `done`
  Activation commit: `af2ca27ed4a9bea0d4141121153240ced9e2eb3b`.
  Verification tier: `focused`
  Focused checks: Complete exact reading, scoped/native/API reconciliation and identity-qualified executable diagnostics; source/range identity, memory, Knowledge, history, book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence only; no source or runtime changes. Later closeout and push retain existing prerequisites.
  Goal: Read and understand group 2: README.md through action_call_names.lua.
  Scope: `lua/README.md` lines 946-1377; `lua/bin/corpus_runner.lua` lines 1-17; `lua/bin/linkedspec-lua` lines 1-31; `lua/native/filesystem_native.c` lines 1-92; `lua/native/mcp_system.c` lines 1-85; `lua/native/regex_pcre2.c` lines 1-233; `lua/src/linkedspec/action_ast.lua` lines 1-371; `lua/src/linkedspec/action_call_names.lua` lines 1-239
  Baseline evidence: 1500 fragments / 54321 bytes; ordered range SHA-256 `edbc6d329884611882069b9d24de3a8f4eae4764b9f8f66306fab982cef67934`.
  Dependencies: .1.1 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: All eight scoped ranges read in thirteen untruncated windows; 1,500 LF fragments /54,321 bytes; frozen range digest unchanged. README and seven cumulative files finish; the call-name suffix remains .1.3-owned. Exact scope and comprehension are in docs/knowledge/lua-native-readme-and-action-ast-reading.md.
  Findings: .2.1 extends existing stale guidance ownership; .2.2 owns primary identity, .2.3 native error formatting and .2.4 the missing diagnostic operation. Startup .81.1 retains the related OS loader observation. Exact cause, measured runtime scope, public limitations and replay live in the new Knowledge card.
  Diagnostic outcomes: Original PUC exits 139 with SIGSEGV at strlen(1) through luaO_pushvfstring/luaL_error/compile_regex; both LuaJIT probes exit 0 with lost offset/provider detail; duplicate host PUC is cancelled with exit 143. All results and cleanup are consumed. Exact OS crash report copy/verify/use/delete passes with zero matching-PID old-report residue.
  Verification: Lua .1.2 reads eight exact ranges in thirteen windows: 1,500 fragments /54,321 bytes; cumulative 2/51, 2,445 fragments /119,853 bytes. All 99 Lua sources remain baseline-identical. Selector 0/20, native resolution 14/9/4 and MCP 141 pass. Exact README diagnostic failure and positive control reproduce on measured PUC 5.5.1 and LuaJIT; unsupported native error formatting loses LuaJIT detail and crashes PUC 5.5.1 with a source-attributed stack. .2.2-.2.4 own primary identity, native error safety and executable teaching; .2.1 retains stale guidance and startup .81.1 owns loader diagnosis. All probes are consumed; no declared 5.4 conformance or repair completion is claimed. Next .1.3; startup prerequisites and ADR0118 remain. Independent reconstruction passes all 99 sources/51 groups/149 ranges. Preservation retains 1,373 prior source/card/decision/history files, 2,429 unchanged task nodes, all 51 prior Known headings and exact history suffixes; exactly nine pending repair nodes are added. Knowledge is 1,088 facts/8,753 keys; memory 60 lines, histories 440/375 lines, public book and all 20 pressure surfaces pass. Normal hooks govern landing.
  Commit: `LUA-STARTUP-READING.1.2 - read native and AST sources and own confirmed Lua defects`

- ID: `LUA-STARTUP-READING.1.3`
  Status: `done`
  Activation commit: `cbb483fb4633e1cd246002f105cb81ecacb92a19`.
  Verification tier: `focused`
  Focused checks: Exact physical reading and baseline/range reconstruction; canonical contract/parser reconciliation and selected parser proof with explicit runtime identity; memory, Knowledge, histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no source or toolchain change. Closeout and push retain existing prerequisites.
  Goal: Read and understand group 3: action_call_names.lua through action_parser.lua.
  Scope: `lua/src/linkedspec/action_call_names.lua` lines 240-317; `lua/src/linkedspec/action_contracts.lua` lines 1-700; `lua/src/linkedspec/action_parser.lua` lines 1-722
  Baseline evidence: 1500 fragments / 50175 bytes; ordered range SHA-256 `ba94240ececbe936a8f99a4bdc0651f87cf7aaad1e2eb9a348fa6a2e98166f40`.
  Dependencies: .1.2 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: Three full scoped ranges in nine untruncated windows; 1,500 fragments /50,175 bytes and frozen range SHA unchanged. Call names and contracts finish; parser suffix remains .1.4-owned. Exact comprehension and self-contained proof live in docs/knowledge/lua-contract-parser-reading-and-string-boundary-gap.md.
  Findings: .2.5/.2.5.1/.2.5.2 own adjacent-string and escaped-terminator acceptance, located at incomplete first/last-delimiter recognition; positive escaping/Unicode controls pass. The slash-delimiter observation agrees with existing public syntax and creates no defect owner. Preserve all earlier repairs and dated inventory evidence.
  Verification: Lua .1.3 reads three exact ranges in nine windows: 1,500 fragments /50,175 bytes; cumulative 3/51, 3,945 fragments /170,028 bytes. All 99 Lua sources remain baseline-identical. Pure parser/contract controls pass 32 per measured runtime (PUC 5.5.1 and LuaJIT); six malformed-string acceptances per runtime have an exact cause and .2.5 repair/verification ownership. Inventory 250/105+1/126, signature 3/9/7, callable 23 mutations and punctuation 6/4/6 pass. All five Lua repair owners remain pending; no native build, declared 5.4 conformance or full component gate is claimed. Next .1.4; startup prerequisites and ADR0118 remain. Independent reconstruction passes all 99 sources/51 groups/149 ranges; the retained probe equals the executed bytes. Preservation retains 1,374 prior source/card/decision/history files, 2,441 unchanged task nodes, all 54 prior Known headings and exact history suffixes/preambles/query; exactly three pending repair nodes are added. Knowledge is 1,089 facts/8,760 keys; memory 60 lines, histories 447/382 lines and rendered book pass. Normal doctrine hooks enforce resulting-tree pressure at landing.
  Commit: `LUA-STARTUP-READING.1.3 - read action contracts and own complete string boundary repair`

- ID: `LUA-STARTUP-READING.1.4`
  Status: `done`
  Activation commit: `344f4503b3601bf3349af6124fe1225af0322aa4`.
  Verification tier: `focused`
  Focused checks: Exact complete reading, baseline/range reconstruction, canonical parser/bounded-authority reconciliation and selected direct-dependent proof; memory, Knowledge, histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no source/runtime change. Closeout and push retain existing prerequisites.
  Goal: Read and understand group 4: action_parser.lua through bounded_child_parse_authority.lua.
  Scope: `lua/src/linkedspec/action_parser.lua` lines 723-1627; `lua/src/linkedspec/bounded_child_parse_authority.lua` lines 1-595
  Baseline evidence: 1500 fragments / 58518 bytes; ordered range SHA-256 `b48fca781d6ab629076a66a214be4b0e1fb9b56f8142477a0e224bf0b5e3fbc4`.
  Dependencies: .1.3 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: Both scoped ranges in nine untruncated windows; 1,500 fragments /58,518 bytes and frozen range SHA unchanged. Parser completes; authority suffix remains .1.5-owned. Exact comprehension, source-qualified runtime inspection and self-contained probes are in docs/knowledge/lua-parser-authority-reading-and-member-omission.md.
  Findings: .2.6/.2.6.1/.2.6.2 own harray pair completeness; .2.7/.2.7.1/.2.7.2 own switch static diagnostic accounting. Direct retained-body resolution isolates the latter without mutation. Existing Lua runtime full-body validation distinguishes this from Dart/Julia execution defects. All earlier repairs remain pending.
  Verification: Lua .1.4 reads two exact ranges in nine windows: 1,500 fragments /58,518 bytes; cumulative 4/51, 5,445 fragments /228,546 bytes. All 99 Lua sources remain baseline-identical. Selected authority 272 plus parser 13 controls pass per measured runtime, 570 total; the facade assertion is explicitly excluded. .2.6 owns lost pairless harray members and .2.7 incomplete switch contract diagnostics; runtime switch source separately validates the complete body. Progressive 116/public 60 and write 105 mutations pass. All seven Lua repair owners remain pending; no declared 5.4 conformance, native build or full gate is claimed. Next .1.5; startup prerequisites and ADR0118 remain. Independent reconstruction passes all 99 sources/51 groups/149 ranges; both retained probe recipes equal the executed bytes. Preservation retains 1,375 prior source/card/decision/history files, 2,444 unchanged task nodes, all 55 prior Known headings and exact history suffixes/preambles/query; exactly six pending repair nodes are added. Knowledge is 1,090 facts/8,767 keys; memory 60 lines, histories 454/389 lines and rendered book pass. Normal doctrine hooks enforce resulting-tree pressure at landing.
  Commit: `LUA-STARTUP-READING.1.4 - read parser and authority and own member accounting gaps`

- ID: `LUA-STARTUP-READING.1.5`
  Status: `done`
  Activation commit: `88da6dccce9a8cde785535d1ebe344a028af74ab`.
  Verification tier: `focused`
  Focused checks: Exact complete reading and baseline/range reconstruction; canonical authority/compiled-state reconciliation and selected direct-dependent proof; memory, Knowledge, required chronology rollover, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence and required bounded chronology rollover; no source/runtime change. Closeout and push retain their existing prerequisites.
  Goal: Read and understand group 5: bounded_child_parse_authority.lua through compiled_spec.lua.
  Scope: `lua/src/linkedspec/bounded_child_parse_authority.lua` lines 596-1206; `lua/src/linkedspec/compiled_spec.lua` lines 1-889
  Baseline evidence: 1500 fragments / 55335 bytes; ordered range SHA-256 `ac55758901370f425dfde54ee7124efb90a4c5472ec551136883b38c61d3dfc7`.
  Dependencies: .1.4 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: Both exact scopes in nine complete untruncated windows; authority finishes and compiled-state suffix remains .1.6-owned. Scope, comprehension, canonical reconciliation and self-contained proof: docs/knowledge/lua-authority-compiled-reading-and-nested-step-gap.md.
  Findings: Existing startup .37.1 now records the Lua zero-parent-step nested callback observation and positive control; no duplicate repair root. Compiled order, copied child regex and descriptor/source snapshots pass. Preserve .2.1-.2.7 and all source prerequisites.
  Communication: Director requests factual local parser/compiler descriptions following a reported UI notice; its platform cause is not established.
  Verification: Lua .1.5 reads two exact ranges in nine windows: 1,500 fragments /55,335 bytes; cumulative 5/51, 6,945 fragments /283,881 bytes. All 99 Lua sources remain baseline-identical. Selected authority 272 plus 17 valid controls pass per installed runtime, 578 total; the facade assertion is excluded. The zero-parent-step nested callback observation joins existing startup .37.1; the one-step control and compiled snapshots pass. Progressive 116/public60 and selector 0/20 pass. All seven Lua repair roots remain pending; no declared 5.4 conformance, native build or full gate is claimed. Next .1.6; startup prerequisites and ADR0118 remain. Independent reconstruction passes 99 sources/51 groups/149 ranges and exact replay bytes. Preservation retains 1,375 prior source/card/decision/history files, 2,450 unchanged task nodes, all 57 prior Known headings and exact history reconstruction; no new repair node. Required rollover archives 211 lines/12,694 bytes from clean source into segment4978; current root249, notes396, manifest34/19343 and collection35/38 fit. One live-root terminal separator is restored explicitly in reconstruction. Knowledge1091/8773, memory60, histories, diff hygiene and book pass; normal hooks govern landing.
  Commit: `LUA-STARTUP-READING.1.5 - read authority and compiled state and record nested step gap`

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
  Children: `.2.1` owns README status; `.2.2` primary identity; `.2.3` native error safety; `.2.4` executable diagnostic teaching; `.2.5` complete quoted-literal parsing; `.2.6` harray pair completeness; `.2.7` complete switch contract diagnostics.
  Acceptance: Define concrete causal evidence, affected behavior and repair/verification children before implementing any finding; preserve startup prerequisites and all earlier owners.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.1`
  Status: `pending`
  Goal: Correct the Lua README's stale present-tense staged gate claim while preserving historical evidence.
  Evidence: Reading .1.1 finds lua/README.md lines 656-657 still saying the complete gate remains at staged 176/177. Canonical lua-root-rule-selection-preflight records superseding July 19 admission at 177/177 per ABI, and lua-callable-codeblock-emitted-route-identity records later complete 177/177 with CLI 66x2. The current 139 root and 359 logical assertions per ABI pass; no new full-gate result or runtime failure is inferred.
  Reading .1.2 extension: The generated-source section repeats the obsolete current 176/177 claim, and the scalar-coercion section still calls explicit codeblock-call syntax future despite the already documented and admitted callable implementation. Reconcile all three exact current-tense statements under the same documentation repair.
  Source: docs/knowledge/lua-readme-reading-and-status-drift.md retains exact dated bytes, locations and commands.
  Children: `.2.1.1`, `.2.1.2`
  Dependencies: Startup .3/.4/.5 and the complete Lua README reading before source-document repair.
  Acceptance: Remove the false current failure projection, distinguish historical counts from current guidance, preserve useful unique history through canonical pointers, and independently verify the resulting public wording and native command examples.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.1.1`
  Status: `pending`
  Goal: Repair the exact stale Lua README status and reconcile nearby historical rollout wording.
  Scope: lua/README.md logical/generated gate paragraphs, scalar-coercion callable-syntax sentence and directly related current-versus-historical guidance; public book and canonical evidence pointers.
  Dependencies: Parent .2.1 prerequisites; .1.2 completes the README; current evidence retrieval before claiming any contemporary suite count.
  Acceptance: Replace the obsolete 176/177 current-failure statement with accurate dated evidence or stable command guidance. Audit nearby present-tense counts against their canonical owners without treating earlier passing counts as freshly measured signoff. Preserve source examples, distinct proof scope and unique history. Run changed-document public contract checks, book render and relevant two-ABI command proof.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.1.2`
  Status: `pending`
  Goal: Independently verify and close the Lua README status correction.
  Dependencies: .2.1.1 committed cleanly.
  Acceptance: Compare the original dated statement with the corrected rendered guidance, confirm no stale failure is presented as current and no unsupported pass is substituted, preserve historical provenance and all other known limitations, verify applicable public contracts and close .2.1 only on evidence.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.2`
  Status: `pending`
  Goal: Restore the declared PUC Lua 5.4 primary proof and make runtime/header identity explicit.
  Evidence: September 12 .1.2 runtime census reports lua and pkg-config lua both 5.5.1, with LuaJIT 2.1.1788460057. The canonical lua-toolchain-package-policy declares PUC 5.4.8. The targeted wrapper selects unversioned lua and the builder independently selects pkg-config lua, with no target-version or header/runtime identity guard. No lua5.4/lua54 command, versioned pkg-config entry or installed Homebrew 5.4 tree was found in the inspected toolchain locations.
  Children: `.2.2.1`, `.2.2.2`
  Dependencies: Startup .3/.4/.5 before toolchain/gate implementation; preserve the declared 5.4 target unless a separate explicit policy decision changes it.
  Acceptance: Establish a repository-local or explicitly documented read-only 5.4 runtime/development pair, bind and validate both identities before building, reject mismatch with precise diagnostics, and rerun required conformance on 5.4 plus LuaJIT. The measured .1.2 PUC process is 5.5.1; earlier unversioned passes did not record a 5.4 runtime identity and cannot establish it. Source reading itself grants no conformance admission.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.2.1`
  Status: `pending`
  Goal: Bind the PUC command and native headers to the declared primary version.
  Scope: Lua toolchain preparation/selection and native builder identity checks, repository-local storage and stable command guidance.
  Dependencies: Parent .2.2 prerequisites; retrieve actual toolchain availability and existing policy before implementation.
  Acceptance: Select one supported 5.4 runtime/header pair with explicit repository-root-derived configuration, verify identity before compilation, and prove wrong runtime, wrong headers and mismatched selections fail before artifacts. Preserve LuaJIT selection and same-volume storage; no global install or silent policy upgrade.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.2.2`
  Status: `pending`
  Goal: Reverify primary Lua conformance and close the runtime-identity gap.
  Dependencies: .2.2.1 committed cleanly and matching primary runtime/header availability.
  Acceptance: Run the complete relevant primary and LuaJIT component proof with explicit version evidence, preserve prior 5.5.1 observations as such, update public claims accurately and satisfy canonical toolchain/admission requirements before parent closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.3`
  Status: `pending`
  Goal: Repair the located native regex error-formatting crash and lost diagnostics.
  Evidence: .1.2 raw valid-match control succeeds, then LuaJIT loses offset/provider detail for [, ( and (?<; PUC 5.5.1 crashes on [. regex_pcre2.c lines 55/62 pass unsupported %lu to luaL_error. Exact 5.5.1 formatter source leaves its numeric argument unconsumed, so the following %s reads offset 1 as a pointer. The captured stack confirms strlen(1) through luaO_pushvfstring/lua_pushvfstring/luaL_error/compile_regex. No declared 5.4 execution or crash is claimed; full cause and official references are in lua-native-readme-and-action-ast-reading.
  Children: `.2.3.1`, `.2.3.2`
  Dependencies: Startup .3/.4/.5 before repair; preserve .2.2 declared-primary identity ownership.
  Acceptance: Locate the failure with an exact native stack and valid/malformed controls; preserve meaningful offset/provider detail through supported Lua error formatting and high-level typed wrappers; prove malformed caller patterns cannot crash supported runtimes. Keep observed 5.5 behavior distinct from declared 5.4 proof.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.3.1`
  Status: `pending`
  Goal: Correct the demonstrated C error-reporting mechanism with source-attributed controls.
  Scope: lua/native/regex_pcre2.c diagnostic branches and directly affected matching/error tests; no regex semantic or global toolchain-policy change.
  Dependencies: Parent .2.3 prerequisites and completed causal diagnosis; matching runtime/header identity.
  Acceptance: Keep a failing control for the actual defective formatter/crash mechanism, preserve byte offsets and provider text for distinct invalid patterns, retain valid match/capture behavior and verify safe Lua errors through native plus public matching paths on declared PUC 5.4 and LuaJIT.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.3.2`
  Status: `pending`
  Goal: Independently verify native regex error safety and close its repair.
  Dependencies: .2.3.1 committed cleanly; .2.2 primary identity available.
  Acceptance: Reproduce the original malformed-pattern cases through raw and public entrypoints without process failure, verify exact useful diagnostics and valid controls on both supported runtimes, preserve scope-qualified 5.5 observations and run the applicable component/admission proof before closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.4`
  Status: `pending`
  Goal: Repair the Lua README diagnostic example's missing event-producing operation.
  Evidence: The exact README engine and sink block yield result child and zero events, so line 1208's typed-event assertion fails. Adding only say("diagnostic") before the child's existing return yields one RuntimeDiagnosticOutputEvent with helper_name say, rule_label Child and message diagnostic plus LF, preserving result child on measured PUC 5.5.1 and LuaJIT.
  Children: `.2.4.1`, `.2.4.2`
  Dependencies: Startup .3/.4/.5 before source-document repair; preserve runtime/version proof scope.
  Acceptance: Teach an executable self-contained diagnostic example whose source actually emits the asserted event, preserve quiet and result behavior, and independently run the exact documented sequence.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.4.1`
  Status: `pending`
  Goal: Add the missing diagnostic emission to the documented native example.
  Scope: lua/README.md native engine and diagnostic example context, corresponding book explanation and exact executable documentation proof.
  Dependencies: Parent .2.4 prerequisites.
  Acceptance: Use an explicit say/print operation in the demonstrated source or provide a complete dedicated engine. Assert exact typed event fields, stable parse value and quiet no-sink behavior; validate the exact documented bytes on both supported runtimes without mutating the runtime to satisfy an incorrect example.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.4.2`
  Status: `pending`
  Goal: Independently verify and close the diagnostic teaching repair.
  Dependencies: .2.4.1 committed cleanly and declared-primary proof available.
  Acceptance: Extract and execute the exact documented sequence, confirm its event count/type/fields and parse result, preserve the old failure as dated evidence and update the public limitation only after supported-runtime proof passes.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.5`
  Status: `pending`
  Goal: Reject malformed or incomplete quoted ActionIR values instead of silently absorbing extra source.
  Evidence: .1.3 direct parse_action_expression and contract resolution on PUC 5.5.1 and LuaJIT accept adjacent double-quoted or single-quoted literals as one string with embedded unescaped delimiters, and report ok=true. action_parser.lua lines 538-543 check only the first and last delimiter before unescaping the entire interior; no complete literal-boundary validation occurs there. An escaped final quote without a real terminator is also accepted; malformed strings survive call, array and assignment nesting. Escaped-quote positive controls retain their intended value. Exact evidence and replay: docs/knowledge/lua-contract-parser-reading-and-string-boundary-gap.md.
  Children: `.2.5.1`, `.2.5.2`
  Dependencies: Startup .3/.4/.5 before source repair; .2.2 for declared-primary conformance proof.
  Acceptance: Honor the existing one-literal grammar and escape semantics, reject trailing or unterminated source with precise source-attributed diagnostics, preserve valid single/double-quoted and regex-pattern strings, and verify direct plus nested/public supported routes without inventing implicit concatenation.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.5.1`
  Status: `pending`
  Goal: Enforce complete quoted-literal recognition at the parser boundary.
  Scope: lua/src/linkedspec/action_parser.lua literal recognition and exact focused parser/contract tests; no new DSL syntax.
  Dependencies: Parent .2.5 prerequisites.
  Acceptance: Turn exact adjacent-literal and escaped-terminator failures into regression controls; reject them in direct expressions, helper arguments, arrays and assignments. Preserve empty strings, escaped delimiters/backslashes, opposite quote characters, regex escape bytes and Unicode spans. Demonstrate valid controls and fail-closed malformed behavior on supported runtimes.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.5.2`
  Status: `pending`
  Goal: Independently verify complete string boundaries and close the parser repair.
  Dependencies: .2.5.1 committed cleanly; .2.2 primary identity available.
  Acceptance: Reexecute the frozen malformed and valid controls through direct ActionIR, compiled specification and supported reconstructed/generated routes. Verify exact diagnostics/spans, preserve current escaping and quote equivalence, update public limitations only after the selected component proof passes.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.6`
  Status: `pending`
  Goal: Reject incomplete harray literal members instead of silently losing authored content.
  Evidence: .1.4 pure parser/resolver probes on measured PUC 5.5.1 and LuaJIT accept both { key: 1, mystery_probe() } and { mystery_probe(), key: 1 } as one-entry hash_literal values with ok=true and no mystery_probe AST node or diagnostic. The lone { mystery_probe() } control retains a block and unknown_helper. action_parser.lua's brace classifier appends only comma parts containing a separator and returns a hash as soon as any pair exists, silently skipping other parts.
  Children: `.2.6.1`, `.2.6.2`
  Dependencies: Startup .3/.4/.5 before source repair; .2.2 for declared-primary conformance.
  Acceptance: Account for every authored literal member or produce a precise diagnostic; preserve empty and valid colon harrays, eager blocks, nested values, helper hash construction and retired fat-arrow guidance. Do not invent mixed block/harray syntax.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.6.1`
  Status: `pending`
  Goal: Enforce complete pair recognition in Lua brace literals.
  Scope: action_parser.lua brace classification and direct parser/contract regression controls.
  Dependencies: Parent .2.6 prerequisites.
  Acceptance: Reject leading, middle and trailing pairless items without dropping source; preserve exact offending spans and valid nested key/value expressions. Exercise malformed helper, scalar and nested members plus empty/valid harray and eager-block controls on both supported runtimes.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.6.2`
  Status: `pending`
  Goal: Independently verify harray member completeness and close its repair.
  Dependencies: .2.6.1 committed cleanly; declared-primary identity available.
  Acceptance: Repeat exact source controls through direct ActionIR and supported compiled/reconstructed/generated entrypoints, prove no semantic member is lost, preserve existing valid harray semantics and update the public limitation after component proof.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.7`
  Status: `pending`
  Goal: Make Lua switch contract diagnostics account for the complete retained authored body.
  Evidence: .1.4 retains a trailing unknown call or an earlier default body in control_switch.body, but action_contracts.lua visits only extracted cases/final default when present, returning ok=true with no unknown_helper. Directly resolving the retained body exposes that diagnostic. Parser projection and resolver selection are the exact mechanism. Runtime execute_attached_switch instead validates the entire body before evaluating its subject and rejects non-branches/duplicate defaults; this is a static diagnostic gap, not a reproduced runtime omission.
  Children: `.2.7.1`, `.2.7.2`
  Dependencies: Startup .3/.4/.5 before source repair; preserve Lua's existing complete runtime validation and separate Dart/Julia owners.
  Acceptance: Return complete source-attributed static diagnostics or explicit structural rejection without double-counting valid branches. Preserve valid attached/marker/value controls and runtime preflight-before-subject behavior; no inferred cross-backend execution change.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.7.1`
  Status: `pending`
  Goal: Reconcile switch projection with complete ActionIR contract traversal.
  Scope: action_contracts.lua control_switch traversal, necessary parser projection invariants and focused diagnostic tests.
  Dependencies: Parent .2.7 prerequisites.
  Acceptance: Preserve diagnostics for leading/interleaved/trailing non-branches and every duplicate default, including caller-constructed nodes; valid branch contracts appear once in authored order. Keep existing structural/runtime policy and exact Unicode spans.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.7.2`
  Status: `pending`
  Goal: Independently verify complete switch diagnostics and unchanged runtime validation.
  Dependencies: .2.7.1 committed cleanly; .2.2 for supported primary runtime proof.
  Acceptance: Reexecute the exact diagnostic controls, valid attached/marker/lazy cases and malformed runtime preflight controls on supported carriers. Prove invalid bodies remain rejected before subject effects, retain source diagnostics and update public claims only after verification.
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
| 1 | `LUA-STARTUP-READING.1.6` | `pending` | Read compiled-state suffix, corpus modules and facade prefix after clean .1.5; preserve all seven Lua repairs and startup .37.1. |

## Decisions

- `2026-09-12` .4.2: Explicit Granted approval closes .4.2 and admits the exact ADR0118 capacity under containment .14. The historical .4.1 proposal remains byte-exact.

- `2026-09-12` .4.1: Propose a finite 57-unit Lua envelope using observed Julia maxima and two matching history models; no control, source or standing verification changes.

- `2026-09-12`: Freeze 51 exact children under startup .3.6.0. Separate bounded ownership avoids exhausting the startup member; all aggregate controls remain active.
- `2026-09-12`: Keep the oversized generated MCP line as two independently UTF-8-decodable byte ranges; no sampling or generated-data exclusion.
- `2026-09-12`: Follow ADR0115's proportionate planning principle with a complete Lua capacity disposition under .4.1; prior concrete Julia allowances remain scoped to Julia.

## Open Questions

- .4.2 resolved: explicit Granted approval is recorded under ADR0118; no further decision is needed for this bounded admission.

## Blockers

- None for Lua .1.6 after the clean .1.5 commit. The finite ADR0118 allowance and each actual candidate remain checked; startup .80 and all later verification/repair prerequisites retain their owners.

## Verification Log

- `2026-09-12` .1.5: Lua .1.5 reads two exact ranges in nine windows: 1,500 fragments /55,335 bytes; cumulative 5/51, 6,945 fragments /283,881 bytes. All 99 Lua sources remain baseline-identical. Selected authority 272 plus 17 valid controls pass per installed runtime, 578 total; the facade assertion is excluded. The zero-parent-step nested callback observation joins existing startup .37.1; the one-step control and compiled snapshots pass. Progressive 116/public60 and selector 0/20 pass. All seven Lua repair roots remain pending; no declared 5.4 conformance, native build or full gate is claimed. Next .1.6; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.4: Lua .1.4 reads two exact ranges in nine windows: 1,500 fragments /58,518 bytes; cumulative 4/51, 5,445 fragments /228,546 bytes. All 99 Lua sources remain baseline-identical. Selected authority 272 plus parser 13 controls pass per measured runtime, 570 total; the facade assertion is explicitly excluded. .2.6 owns lost pairless harray members and .2.7 incomplete switch contract diagnostics; runtime switch source separately validates the complete body. Progressive 116/public 60 and write 105 mutations pass. All seven Lua repair owners remain pending; no declared 5.4 conformance, native build or full gate is claimed. Next .1.5; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.3: Lua .1.3 reads three exact ranges in nine windows: 1,500 fragments /50,175 bytes; cumulative 3/51, 3,945 fragments /170,028 bytes. All 99 Lua sources remain baseline-identical. Pure parser/contract controls pass 32 per measured runtime (PUC 5.5.1 and LuaJIT); six malformed-string acceptances per runtime have an exact cause and .2.5 repair/verification ownership. Inventory 250/105+1/126, signature 3/9/7, callable 23 mutations and punctuation 6/4/6 pass. All five Lua repair owners remain pending; no native build, declared 5.4 conformance or full component gate is claimed. Next .1.4; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.2: Lua .1.2 reads eight exact ranges in thirteen windows: 1,500 fragments /54,321 bytes; cumulative 2/51, 2,445 fragments /119,853 bytes. All 99 Lua sources remain baseline-identical. Selector 0/20, native resolution 14/9/4 and MCP 141 pass. Exact README diagnostic failure and positive control reproduce on measured PUC 5.5.1 and LuaJIT; unsupported native error formatting loses LuaJIT detail and crashes PUC 5.5.1 with a source-attributed stack. .2.2-.2.4 own primary identity, native error safety and executable teaching; .2.1 retains stale guidance and startup .81.1 owns loader diagnosis. All probes are consumed; no declared 5.4 conformance or repair completion is claimed. Next .1.3; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.1: Lua .1.1 reads README lines 1–945 completely: 945 fragments /65,532 bytes across six exact windows. Root selection 139 and logical helpers 359 pass per ABI; neutral root 54 / logical 26 mutations pass. Reading is 1/51; .2.1 owns stale present-tense gate guidance with repair and independent-verification children. All 99 Lua files remain baseline-identical; .1.2 is next. ADR0118 capacity, startup prerequisites and all earlier repairs remain.

- `2026-09-12` .4.2: Explicit ADR0118 approval admits exactly eleven finite Lua evidence controls and the .14-only focused/receipt exception. The complete actual-plus-57-unit reserve fits; independent and production history models agree on four rollovers per collection. Actual routing functions pass 125 threshold and 54 authorization cases. Previous source, cards, decisions, task evidence and immutable history remain exact. Lua .4/.4.2 close; source reading remains 0/51 and .1.1 follows the clean commit. Later verification and startup repair prerequisites remain unchanged.

- `2026-09-12` .4.1: Lua .4.1 proposes eleven finite evidence-limit changes for 51 reading leaves plus six support units. Exact 57-unit reserve and independent/production history models pass; each history needs four rollovers with only two slots available. The proposal preserves all source, evidence, controls and pending repairs. Explicit approval of the exact limits and containment .14-only focused/receipt exception is required before implementation; Lua .4.2 owns the decision. Source reading remains 0/51.

- `2026-09-12`: Startup .3.6.0 independently verifies the frozen range plan before landing; detailed proof is retained in its startup node and the linked Knowledge card. No Lua source comprehension or new runtime gate result is claimed.

## Commit Log

- `2026-09-12` .1.5: `LUA-STARTUP-READING.1.5 - read authority and compiled state and record nested step gap`.

- `2026-09-12` .1.4: `LUA-STARTUP-READING.1.4 - read parser and authority and own member accounting gaps`.

- `2026-09-12` .1.3: `LUA-STARTUP-READING.1.3 - read action contracts and own complete string boundary repair`.

- `2026-09-12` .1.2: `LUA-STARTUP-READING.1.2 - read native and AST sources and own confirmed Lua defects`.

- `2026-09-12` .1.1: `LUA-STARTUP-READING.1.1 - read Lua README prefix and own stale gate guidance`.

- `2026-09-12` .4.2: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.14 - admit approved Lua reading evidence capacity` closes .4/.4.2 without source-reading credit.

- `2026-09-12` .4.1: `LUA-STARTUP-READING.4.1 - propose finite Lua evidence capacity and verification boundary`.

- `SESSION-STARTUP-READING.3.6.0 - freeze exact Lua reading ownership and capacity intake` owns creation of this plan.

## Changelog

- `2026-09-12` .1.5: Complete authority reading and compiled-state prefix; extend existing .37.1 with measured Lua budget evidence, preserve all prior repairs and advance .1.6.

- `2026-09-12` .1.4: Complete parser reading and read authority prefix; own harray and static-switch accounting repairs, preserve all earlier evidence and advance .1.5.

- `2026-09-12` .1.3: Read contracts and parser prefix; own exact complete-string recognition repair; preserve all prior source/evidence and advance .1.4.

- `2026-09-12` .1.2: Read exact README/native/AST ranges; own three confirmed defects, extend stale guidance ownership, root-cause the native crash and advance .1.3 without source changes.

- `2026-09-12` .1.1: Read the first exact Lua group, own stale README gate guidance and advance .1.2 without source changes.

- `2026-09-12` .4.2: Resolve approved capacity and route the first exact Lua reading child after clean admission.

- `2026-09-12` .4.1: Complete the coherent Lua capacity proposal; retain 0/51 reading and all existing repairs while explicit disposition is pending.

- `2026-09-12`: Create exact bounded Lua reading, repair, closeout and capacity ownership under startup .3.6.0.
