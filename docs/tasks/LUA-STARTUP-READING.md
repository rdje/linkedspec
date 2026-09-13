# LUA-STARTUP-READING: Bounded Lua reading and repair ownership

## Metadata

- Tree ID: `LUA-STARTUP-READING`
- Status: `active` / approved capacity; source reading 27/51
- Roadmap lane: `Session required reading / SESSION-STARTUP-READING.3.6`
- Created: `2026-09-12`
- Last updated: `2026-09-13`
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
- Current physical reading: 27/51 children, 36,151/71,269 fragments and 1,357,777/2,732,450 bytes.
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
  Status: `done`
  Activation commit: `4fc58d3cd6c268ac26514984bfe0a1de92d42b2e`.
  Verification tier: `focused`
  Focused checks: Exact complete reading and baseline/range reconstruction; canonical compiled-state/corpus/facade reconciliation and selected direct-dependent proof; memory, Knowledge, histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no runtime or source change. Closeout and push retain existing prerequisites.
  Goal: Read and understand group 6: compiled_spec.lua through init.lua.
  Scope: `lua/src/linkedspec/compiled_spec.lua` lines 890-1529; `lua/src/linkedspec/corpus.lua` lines 1-524; `lua/src/linkedspec/corpus_runner.lua` lines 1-102; `lua/src/linkedspec/init.lua` lines 1-234
  Baseline evidence: 1500 fragments / 58462 bytes; ordered range SHA-256 `682b3852a6e7ad6504ca42236a8b84f91d5eeb38d472836d4831100c5b661347`.
  Dependencies: .1.5 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: All four exact scopes in ten complete untruncated windows. Compiled state and both corpus modules finish; facade suffix remains .1.7-owned. Full comprehension, canonical qualification and self-contained replay: docs/knowledge/lua-compiled-corpus-facade-reading.md.
  Findings: Extend existing .2.1 and its repair/verification children to the stale corpus-card primary-scaffold sentence; preserve dated evidence and every earlier repair. No runtime defect is inferred.
  Verification: Lua .1.6 reads four exact ranges in ten windows: 1,500 fragments /58,462 bytes; cumulative 6/51, 8,445 fragments /342,343 bytes. All 99 Lua sources remain baseline-identical. Pure compiled-state controls pass 25 per installed runtime, 50 total; regex-slot59, cursor60 and signature3/9/7 checks pass. Independent census confirms 105 corpus directories and 315 UTF-8 files without Lua corpus execution. Existing .2.1 owns the stale corpus-card primary-scaffold sentence; all seven local repairs and startup .37.1 remain pending. No declared 5.4 conformance, native build or full gate is claimed. Next .1.7; startup prerequisites and ADR0118 remain. Independent all-source/range reconstruction and exact replay bytes pass. Preserve 1,378 prior source/card/decision/history files, 2,448 unchanged task nodes, all 58 Known headings and exact history suffixes/preambles/query; no new node. Knowledge1092/8779, memory60, histories256/403 and rendered book pass; normal hooks enforce resulting-tree pressure at landing.
  Commit: `LUA-STARTUP-READING.1.6 - read compiled state corpus and facade boundaries`

- ID: `LUA-STARTUP-READING.1.7`
  Status: `done`
  Activation commit: `d337ed89c1dcf50d1326097f00f648a73a556707`.
  Verification tier: `focused`
  Focused checks: Exact complete reading and baseline/range reconstruction; canonical facade/interpreter reconciliation and selected direct-dependent proof; memory, Knowledge, histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no runtime or source change. Closeout and push retain existing prerequisites.
  Goal: Read and understand group 7: init.lua through interpreter.lua.
  Scope: `lua/src/linkedspec/init.lua` lines 235-318; `lua/src/linkedspec/interpreter.lua` lines 1-1416
  Baseline evidence: 1500 fragments / 53644 bytes; ordered range SHA-256 `9617f765df2d7cbefd92c6990395f31b66134368269fd0df84395d9d08685dbe`.
  Dependencies: .1.6 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: Both scoped ranges read in ten full untruncated windows; facade completes and interpreter prefix1416 ends at inline-if validation. Exact scope, comprehension and managed native replay: docs/knowledge/lua-interpreter-prefix-reading-and-iteration-option-gap.md.
  Findings: .2.8/.2.8.1/.2.8.2 own explicit false iteration-option defaulting; matched omitted/positive/other-invalid cases isolate the existing or-default before type validation. .2.1 gains stale canonical runtime guidance; all prior source and repairs remain.
  Verification: Lua .1.7 reads two exact ranges in ten windows: 1,500 fragments /53,644 bytes; cumulative 7/51, 9,945 fragments /395,987 bytes. All 99 Lua sources remain baseline-identical. Native facade/runtime controls pass 27 per installed host, 54 total; both managed runs and cleanup are consumed. Explicit false max_iterations silently selects 10000; .2.8 owns absence-only defaulting and independent route proof. .2.1 also owns stale runtime-card mode/write/callable guidance. Write 105 and logical 26 mutations pass. All eight local repair roots and startup .37.1 remain pending; no declared PUC 5.4, full gate or corpus pass is claimed. Next .1.8; startup prerequisites and ADR0118 remain. Independent reconstruction passes 99 sources/51 groups/149 ranges and exact runtime replay bytes. Preserve 1,379 prior source/card/decision/history files, 2,447 unchanged task nodes and all 58 prior Known headings; exactly 3 pending .2.8 nodes are added. Knowledge 1093/8785, memory 60, histories 263/410 (notes warning, no rollover) and rendered book pass; normal hooks enforce resulting-tree pressure at landing.
  Commit: `LUA-STARTUP-READING.1.7 - read interpreter prefix and own iteration option validation`

- ID: `LUA-STARTUP-READING.1.8`
  Status: `done`
  Activation commit: `f80a2bde7684d31df9655273023b179e98d64e58`.
  Verification tier: `focused`
  Focused checks: Exact complete reading and baseline/range reconstruction; canonical interpreter/control/string/array reconciliation and selected direct-dependent proof; memory, Knowledge, histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no runtime or source change. Closeout and push retain existing prerequisites.
  Goal: Read and understand group 8: interpreter.lua.
  Scope: `lua/src/linkedspec/interpreter.lua` lines 1417-2916
  Baseline evidence: 1500 fragments / 52134 bytes; ordered range SHA-256 `7ddf7c6ea7587c413f14adc04d4a6c36b2d1f0ad2bea9ca73b656a3f9627b00f`.
  Dependencies: .1.7 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: All 1500 scoped fragments /52134 bytes read in nine complete windows; exact range SHA and full comprehension are recorded in docs/knowledge/lua-interpreter-helper-reading-and-false-delimiter-gap.md. Corrected fixtures distinguish valid false values from documented dynamic harray keys.
  Findings: .2.9/.2.9.1/.2.9.2 own receiver join and mutable split false-delimiter fallback. Startup .28.7/.28.7.1/.28.7.2 own the independently confirmed unchanged-baseline public-selector context/census failure; all implementation remains prerequisite-gated.
  Verification: Lua .1.8 reads interpreter1417–2916 in nine complete windows: 1,500 fragments /52,134 bytes; cumulative 8/51, 11,445 fragments /448,121 bytes. All 99 Lua sources remain baseline-identical. Corrected native helper controls pass22 per installed host, 44 total; false join/split delimiter differences gain .2.9 repair and independent proof. Named-mark7/3 and mutation-result54/12/9 checks pass. Additional public-selector checking fails on unchanged baseline inputs: 35 references against32 and one misclassified negative example; startup .28.7 owns repair/proof. All nine local repair roots and startup .37.1 remain pending; no declared PUC5.4, full gate or corpus pass is claimed. Next .1.9; startup prerequisites and ADR0118 remain. Independent source/range reconstruction and exact replay bytes pass. Preserve 1,380 prior source/card/decision/history files, 2,452 unchanged prior task nodes and all59 prior Known headings; exactly six pending repair nodes are added. Knowledge1094/8792, memory60, histories270/417 (notes warning, no rollover) and rendered book pass. Normal hooks govern landing.
  Commit: `LUA-STARTUP-READING.1.8 - read interpreter helpers and own false delimiter repair`

- ID: `LUA-STARTUP-READING.1.9`
  Status: `done`
  Activation commit: `4a3d170d335b0fa2aad17e3f9acbbc7e53805d0a`.
  Verification tier: `focused`
  Focused checks: Exact complete reading and baseline/range reconstruction; canonical callable/evaluation/mutation reconciliation and selected direct-dependent proof; memory, Knowledge, histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no runtime/source change. Closeout and push retain existing prerequisites.
  Goal: Read and understand group 9: interpreter.lua.
  Scope: `lua/src/linkedspec/interpreter.lua` lines 2917-4416
  Baseline evidence: 1500 fragments / 58443 bytes; ordered range SHA-256 `6a6df80d62f8e687d41b08451bdeb320506faff6325cf7a746f51e043074a016`.
  Dependencies: .1.8 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: All 1500 scoped fragments /58443 bytes read in nine complete windows. Exact range SHA, comprehension, canonical reconciliation and self-contained native replay are in docs/knowledge/lua-interpreter-callable-reading-and-child-false-gap.md. The eager-block loop suffix remains .1.10-owned.
  Findings: .2.10/.2.10.1/.2.10.2 own false whole-child push preservation with bounded repair and independent carrier/cache verification. Existing .2.1 extends stale explicit-callable guidance correction; all earlier source/evidence and prerequisites remain.
  Verification: Lua .1.9 reads interpreter 2917–4416 in nine complete windows: 1,500 fragments /58,443 bytes; cumulative 9/51, 12,945 fragments /506,564 bytes. All 99 Lua sources remain baseline-identical. Both installed hosts pass 449 callable assertions plus 26 valid controls, 950 total; separate false whole-child push observations gain .2.10 repair/proof. Neutral callable23 mutations and uniform11/7/6/8 checks pass. Existing .2.1 gains stale explicit-callable guidance correction. All ten local repairs and startup .37.1/.28.7 remain pending; the earlier public-selector baseline failure is still open. No declared PUC 5.4, full gate or corpus pass is claimed. Next .1.10; startup prerequisites and ADR0118 remain. Independent reconstruction passes 99 sources/51 groups/149 ranges and the exact native replay payload. Preserve 1,381 prior source/card/decision/history files, 2,456 unchanged prior task nodes and all 61 prior Known headings; exactly three pending .2.10 nodes are added. Knowledge 1095/8798, memory 60, histories 277/424 (notes warning, no rollover) and rendered book pass. The existing 10,043,366-byte search-index warning retains startup .41.9 ownership; normal doctrine hooks govern landing.
  Commit: `LUA-STARTUP-READING.1.9 - read callable dispatch and own false child push repair`

- ID: `LUA-STARTUP-READING.1.10`
  Status: `done`
  Activation commit: `7d3fb5427634cbbc5b80214149e37afbf48038b0`.
  Verification tier: `focused`
  Focused checks: Exact complete reading and baseline/range reconstruction; canonical rule/runtime/JSON reconciliation and selected direct-dependent proof; memory, Knowledge, histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no runtime/source change. Closeout and push retain existing prerequisites.
  Goal: Read and understand group 10: interpreter.lua through json.lua.
  Scope: `lua/src/linkedspec/interpreter.lua` lines 4417-5634; `lua/src/linkedspec/json.lua` lines 1-282
  Baseline evidence: 1500 fragments / 51687 bytes; ordered range SHA-256 `451384fb9c5e48d276ef26a2682c263a60745e846baf82f36ed688d7f3fc0922`.
  Dependencies: .1.9 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: All 1,500 scoped fragments /51,687 bytes read in ten complete windows. Interpreter reading finishes; the JSON suffix remains .1.11-owned. Exact scope/digests, comprehension, canonical reconciliation and native replay: docs/knowledge/lua-interpreter-json-reading-and-option-table-gap.md.
  Findings: Existing .2.8 gains separately decomposed .2.8.3/.4 for false optional-table normalization across engine/parse/execute/traced aliases. Preserve numeric-field .2.8.1/.2 and every earlier source/repair owner. No new repair root or implementation change.
  Verification: Lua .1.10 reads the interpreter suffix and JSON prefix in ten complete windows: 1,500 fragments /51,687 bytes; cumulative 10/51, 14,445 fragments /558,251 bytes. All 99 Lua sources remain baseline-identical; interpreter reading is complete. Both installed hosts pass runtime/JSON 68, cursor 108 and observation 43 assertions, 438 total. Five false option-table acceptances per host extend existing .2.8 through separate repair/proof children .2.8.3/.4. Neutral cursor 60 and root 54 mutations pass. All ten local repair roots and startup .37.1/.28.7 remain pending; the earlier public-selector baseline failure stays open. No declared PUC 5.4, full gate or corpus pass is claimed. Next .1.11; startup prerequisites and ADR0118 remain. Independent reconstruction passes all 99 sources/51 groups/149 ranges and the exact native replay payload. Preservation retains 1,382 prior source/card/decision/history files, 2,461 unchanged prior task nodes and all 62 Known headings; exactly two pending option-table repair nodes are added. Knowledge is 1096/8804, memory 60 lines, histories 284/431 (notes warning, no rollover) and rendered book passes. The existing 10,044,276-byte search-index warning retains startup .41.9 ownership; normal doctrine hooks govern landing.
  Commit: `LUA-STARTUP-READING.1.10 - finish interpreter reading and own option table validation`

- ID: `LUA-STARTUP-READING.1.11`
  Status: `done`
  Activation commit: `adb79b644aa920d7b39403f140b0010f6c210063`.
  Verification tier: `focused`
  Focused checks: Exact complete reading and baseline/range reconstruction; canonical JSON/matching/MCP reconciliation and selected direct-dependent proof; memory, Knowledge, histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no runtime/source change. Closeout and push retain existing prerequisites.
  Goal: Read and understand group 11: json.lua through mcp_contract.lua.
  Scope: `lua/src/linkedspec/json.lua` lines 283-480; `lua/src/linkedspec/matching.lua` lines 1-500; `lua/src/linkedspec/mcp_contract.lua` lines 1-6
  Baseline evidence: 704 fragments / 22026 bytes; ordered range SHA-256 `493407d9e0e434460bfe168384c2086a5cce4e67003aaea21a222c5aa28b1073`.
  Dependencies: .1.10 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: All 704 scoped fragments /22,026 bytes read in six complete windows. JSON and matching finish; only the six-line generated MCP header is read here. Exact scope/digests, comprehension and both replay payloads: docs/knowledge/lua-json-matching-reading-and-integer-encoding-gap.md.
  Findings: .2.11/.2.11.1/.2.11.2 own PUC represented-integer JSON loss with independent carrier proof; LuaJIT decode precision is qualified separately. Existing .2.8.5/.6 own false matching defaults and parent closeout waits for all six children. One initial fixture escape was corrected before the passing native runs; no source change.
  Verification: Lua .1.11 reads the JSON suffix, matching module and MCP header in six complete windows: 704 fragments /22,026 bytes; cumulative 11/51, 15,149 fragments /580,277 bytes. All 99 Lua sources remain baseline-identical; JSON and matching reading complete. Both installed hosts pass 60 focused and 112 duplicate-slot assertions, 344 total, plus three PUC integer-format comparisons. .2.11 owns exact represented-integer JSON encoding; .2.8.5/.6 own matching false defaults. Neutral duplicate-slot 59 mutations pass. All eleven local repair roots and startup .37.1/.28.7 remain pending; prior public-selector failure stays open. No declared PUC 5.4, full gate or corpus pass is claimed. Next .1.12; startup prerequisites and ADR0118 remain. Independent reconstruction passes all 99 sources/51 groups/149 ranges and both exact replay payloads. Preservation retains 1,383 prior source/card/decision/history files, 2,462 unchanged prior task nodes and all 62 prior Known headings; exactly five pending repair nodes are added. Knowledge 1097/8810, memory 60, histories 291/438 (notes warning, no rollover) and rendered book pass. The existing 10,047,337-byte search-index warning retains startup .41.9 ownership; normal doctrine hooks govern landing.
  Commit: `LUA-STARTUP-READING.1.11 - read JSON and matching and own integer encoding repair`

- ID: `LUA-STARTUP-READING.1.12`
  Status: `done`
  Activation commit: `a5304ec5804dffea9bb9f1c10c42362927069e0c`.
  Verification tier: `focused`
  Focused checks: Exact byte-range identity and complete bounded viewing, canonical MCP bundle reconciliation and focused generated-binding proof; memory, Knowledge, histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary generated-source reading evidence; no source, schema or runtime change. Closeout and push retain existing prerequisites.
  Goal: Read and understand group 12: mcp_contract.lua.
  Scope: `lua/src/linkedspec/mcp_contract.lua` bytes 261-65796
  Baseline evidence: 1 fragments / 65536 bytes; ordered range SHA-256 `a5985b6f4edc587dd10e3e963124c149cd97b4d42fe04a6e3e03f5755f86731c`.
  Dependencies: .1.11 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Continuity correction owner: This leaf corrects the stale Current physical reading aggregate (7/51 at activation despite eleven completed children) from an independent completed-node sum; preserve all historical leaf evidence and verify every current pointer.
  Physical reading: Eight complete 8192-byte windows cover bytes 261–65796 once; 65536 bytes /one LF fragment, selected-content SHA-256 02df32c7810984fba47e18c2cdb729bf65a02fd4e24564c91c5118edcc6ce174. An interrupted fourth window was reread fully before credit.
  Comprehension: Canonical frames and backend identities; semantic versus transport success; schemas, artifact digests, lowering-only policy, request limits and corpus lifecycle/input expectations. Exact window hashes, current-versus-dated counts and proof limits: docs/knowledge/lua-generated-mcp-first-byte-range-reading.md.
  Findings: No new runtime repair. Current-summary drift is corrected from an independent completed-node sum; all eleven Lua repairs and startup .37.1/.28.7 remain open.
  Verification: Lua .1.12 reads generated MCP bytes 261–65796 in eight complete windows: one fragment /65,536 bytes; cumulative 12/51, 15,150 fragments /645,813 bytes. All 99 Lua sources remain baseline-identical. The 83,166-byte generated module is byte-fresh; both installed hosts pass 116 binding assertions each, 232 total. Admission governance rejects 141 mutations. The stale tree aggregate is corrected from completed-node totals. All eleven local repair roots and startup .37.1/.28.7 remain pending; the public-selector failure stays open. No declared PUC 5.4, full server, full gate or corpus pass is claimed. Next .1.13 reads the remaining generated payload bytes; startup prerequisites and ADR0118 remain. Memory, Knowledge, histories, rendered book, preservation and normal doctrine hooks govern landing.
  Commit: `LUA-STARTUP-READING.1.12 - read generated MCP bytes and reconcile binding proof`

- ID: `LUA-STARTUP-READING.1.13`
  Status: `done`
  Activation commit: `a8834341b59d39b56b9de4fd24fa1db2e1959012`.
  Verification tier: `focused`
  Focused checks: Exact byte-range identity and complete bounded viewing, canonical bundle reconciliation, direct generated-binding checks, memory, Knowledge, histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary generated-data reading with no source or contract change; later closeout and push retain their canonical prerequisites.
  Goal: Read and understand group 13: mcp_contract.lua.
  Scope: `lua/src/linkedspec/mcp_contract.lua` bytes 65797-83164
  Baseline evidence: 1 fragments / 17368 bytes; ordered range SHA-256 `fdd776f35ec057bfc00cd19ef0a1ede2371bd55093d29f6ae51e6907685f3a5f`.
  Dependencies: .1.12 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: Three complete windows cover bytes 65797–73988,73989–82180,82181–83164; 17368 bytes /one fragment, selected-content SHA-256 d8abe2d6e689642cc64c6401bc6243142059e1dc5e7917d8f08c76d17f9e64ef. Literal and field terminator complete; final module line remains in .1.14.
  Comprehension: Complete request/response, shape/signature and tool schemas; four native/projected semantic payloads and exact artifact digest map. Canonical reconciliation, independent replay and explicit proof limits: docs/knowledge/lua-generated-mcp-payload-completion-reading.md.
  Findings: No new runtime defect; preserve eleven Lua repair roots and startup .37.1/.28.7.
  Verification: Lua .1.13 reads generated MCP bytes 65797–83164 in three complete windows: one fragment /17,368 bytes; cumulative 13/51, 15,151 fragments /663,181 bytes. All 99 Lua sources remain baseline-identical. Independent reconciliation matches the canonical bundle, seven artifact digests, three embedded artifact values, 35 frames and four payload digests. Generator comparison and neutral transport validation pass, including 76 rejected mutations. The prior leaf retains the latest 232 native binding assertions; no new native run is counted. All eleven local repair roots and startup .37.1/.28.7 remain pending; the public-selector failure stays open. Next .1.14 reads the final module line, contract runtime, server and wire prefix; startup prerequisites and ADR0118 remain. Memory, Knowledge, histories, rendered book, preservation and normal doctrine hooks govern landing.
  Commit: `LUA-STARTUP-READING.1.13 - finish generated MCP payload reading and reconciliation`

- ID: `LUA-STARTUP-READING.1.14`
  Status: `done`
  Activation commit: `722674ef9d199876153832f3db258bd39ef7ac88`.
  Verification tier: `focused`
  Focused checks: Exact scoped reading/baseline identity, canonical MCP runtime/server/wire reconciliation and relevant component proof; DBINP proposal-only ownership, memory, Knowledge, histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary reading and parked discussion intake; no source, callable contract, transport or implementation activation. Later closeout and push retain their canonical prerequisites.
  Goal: Read and understand group 14: mcp_contract.lua through mcp_wire.lua.
  Scope: `lua/src/linkedspec/mcp_contract.lua` lines 8-8; `lua/src/linkedspec/mcp_contract_runtime.lua` lines 1-413; `lua/src/linkedspec/mcp_server.lua` lines 1-854; `lua/src/linkedspec/mcp_wire.lua` lines 1-232
  Baseline evidence: 1500 fragments / 53162 bytes; ordered range SHA-256 `d157ca1471a6078386594be0911d4d5e2d56fe29ead9d692ecf0053fec58ed67`.
  Dependencies: .1.13 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  DBINP intake owner: Capture the director’s named function-argument discussion and subsequent approval as parked PARSER-AUTHORING-APIS.4 with bounded design follow-ups and explicit compatibility/default decisions. Preserve the active reading frontier; this is no syntax adoption or implementation authorization.
  Physical reading: Twelve untruncated windows cover all four scopes exactly; 1500 fragments /53162 bytes. Runtime/server and generated module complete; wire 1–232 partial. Exact window coordinates and per-range hashes: docs/knowledge/lua-mcp-runtime-server-reading-and-validation-gaps.md.
  Comprehension: Generated schema validation/copies, immutable constructor/registry state, native semantic dispatch and explicit policy projection, prepared response cancellation, and wire string/number/container scanning.
  Findings: New pending .2.8.7/.8 own two false MCP option-table constructors; .2.11 gains measured direct/synthetic semantic copy loss with unchanged request-ID bounds. PARSER-AUTHORING-APIS.4 captures approved parked named-call direction and four unactivated children; all other repairs remain open.
  Verification: Lua .1.14 reads the generated module ending, contract runtime, decoded server and wire prefix in twelve complete windows: 1,500 fragments /53,162 bytes; cumulative 14/51, 16,651 fragments /716,343 bytes. All 99 Lua sources remain baseline-identical; 21 files are fully read. Both installed hosts pass 216 decoded, 247 stdio and 33 valid boundary controls each, 992 assertions total. MCP constructor false defaults extend .2.8.7/.8; measured integer-copy loss extends .2.11 without widening request IDs. Admission141 and callable3/9/7 checks pass. Named-argument direction is approved and parked under PARSER-AUTHORING-APIS.4 with four unactivated design/planning children. All eleven Lua repair roots and startup .37.1/.28.7 remain pending; next .1.15 under unchanged startup and ADR0118 prerequisites. Memory, Knowledge, histories, rendered book, preservation and normal doctrine hooks govern landing.
  Commit: `LUA-STARTUP-READING.1.14 - read MCP runtime and preserve repair and named-call ownership`

- ID: `LUA-STARTUP-READING.1.15`
  Status: `done`
  Activation commit: `400e3db4418e04fe6514f2c34a083648244acaf5`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading/baseline identity, wire/CLI/recognition Knowledge reconciliation and focused component proof; memory, Knowledge, histories including any required safe rollover, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no runtime or contract change. Later closeout and push retain their canonical prerequisites.
  Goal: Read and understand group 15: mcp_wire.lua through recognition_transaction_runtime.lua.
  Scope: `lua/src/linkedspec/mcp_wire.lua` lines 233-511; `lua/src/linkedspec/primary_cli.lua` lines 1-381; `lua/src/linkedspec/recognition_transaction.lua` lines 1-699; `lua/src/linkedspec/recognition_transaction_runtime.lua` lines 1-141
  Baseline evidence: 1500 fragments / 51908 bytes; ordered range SHA-256 `8473f4c5be44a6cded592f0ab42146a777df62fd365b703324c8df741a8fce93`.
  Dependencies: .1.14 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  History ownership: This leaf owns the expected engineering-notes rollover after its new record: preserve the clean activation suffix, exact prior archive bytes and manifest rows, stay within ADR0118 and verify reconstruction before committing.
  Reading checkpoint: All four scopes consumed in eleven complete windows: wire 233–382,383–511; CLI 1–150,151–300,301–381; transaction 1–150,151–300,301–450,451–600,601–699; adapter 1–141. Reading is complete; exact reconciliation and executed replay are in docs/knowledge/lua-wire-cli-recognition-reading-and-finite-state-gap.md.
  Verification: Lua .1.15 completes wire, primary CLI and recognition transaction reading and reads the runtime adapter prefix in eleven complete windows: 1,500 fragments /51,908 bytes; cumulative 15/51, 18,151 fragments /768,251 bytes. All 99 Lua sources remain baseline-identical; 24 files are fully read. Both installed hosts pass 246 recognition assertions and 30 valid boundary controls each, 552 assertions total; default-environment CLI conformance separately passes 66 cases per host. Nine private non-finite observations per host gain .2.12 repair/proof ownership; stale transaction integration commentary extends .2.1. Neutral recognition validation passes 138 ActionIR rows, 250 calls and 58 mutations with existing governance checks. All twelve Lua repair roots and startup .37.1/.28.7 remain pending. Named-argument direction remains approved and parked under PARSER-AUTHORING-APIS.4. Next .1.16 reads the adapter suffix, scoped binding, scalar numeric, compilation outcome and semantic index prefix under unchanged startup and ADR0118 prerequisites. Required engineering-notes rollover and independent preservation are recorded in the fact card; memory, Knowledge, history pressure, rendered book and normal hooks govern landing.
  Commit: `LUA-STARTUP-READING.1.15 - read wire CLI and transactions and own finite state repair`

- ID: `LUA-STARTUP-READING.1.16`
  Status: `done`
  Activation commit: `1c74ad498b0e1448d43739e4c7cabf496a646ea9`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading/baseline identity; recognition adapter, scalar and semantic Knowledge reconciliation and focused component proof; memory, Knowledge, histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no runtime or contract change. Later closeout and push retain their canonical prerequisites.
  Goal: Read and understand group 16: recognition_transaction_runtime.lua through semantic_index.lua.
  Scope: `lua/src/linkedspec/recognition_transaction_runtime.lua` lines 142-501; `lua/src/linkedspec/runtime_scoped_binding.lua` lines 1-102; `lua/src/linkedspec/scalar_numeric.lua` lines 1-192; `lua/src/linkedspec/semantic_compilation_outcome.lua` lines 1-253; `lua/src/linkedspec/semantic_index.lua` lines 1-593
  Baseline evidence: 1500 fragments / 46858 bytes; ordered range SHA-256 `96a35519ffd3e49916b79e25a81b9e376cc3090aee62bc5a63293d947ad7a0d3`.
  Dependencies: .1.15 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Reading checkpoint: All five scopes consumed in twelve untruncated windows: adapter 142–291,292–441,442–501; scoped binding 1–102; scalar 1–150,151–192; outcome 1–150,151–253; semantic index 1–150,151–300,301–450,451–593. Reading and focused proof are complete; exact evidence and replay are in docs/knowledge/lua-recognition-numeric-semantic-reading-and-copy-gaps.md.
  Verification: Lua .1.16 completes recognition adapter, scoped binding, scalar numeric and compilation outcome reading and reads the semantic index prefix in twelve complete windows: 1,500 fragments /46,858 bytes; cumulative 16/51, 19,651 fragments /815,109 bytes. All 99 Lua sources remain baseline-identical; 28 files are fully read. Both installed hosts pass source382, outcome122, scoped26 and boundary10 assertions each, 1,080 total. Nine native/reconstructed numeric cases per host and nine fresh Perl Get/lowering cases locate PUC arithmetic overflow under .2.13; isolated diagnostic null-to-object copies gain .2.14 repair/proof. Neutral numeric55/18 and semantic6/20/128 checks pass without fresh six-runtime admission. All fourteen Lua repair roots and startup .37.1/.28.7 remain pending. Named arguments remain approved and parked under PARSER-AUTHORING-APIS.4. Next .1.17 reads the semantic index suffix, observation, query and runtime projection prefix under unchanged startup and ADR0118 prerequisites. Independent preservation, memory, Knowledge, both histories, rendered book and normal hooks govern landing.
  Commit: `LUA-STARTUP-READING.1.16 - read numeric and semantic modules and own value preservation repairs`

- ID: `LUA-STARTUP-READING.1.17`
  Status: `done`
  Activation commit: `dce95cec24f66a2badf0746edf1b701f78ae15f8`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading/baseline identity; semantic index/observation/query Knowledge reconciliation and selected native/neutral consumers; memory, Knowledge, both histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no runtime or contract change. Later closeout and push retain their canonical prerequisites.
  Goal: Read and understand group 17: semantic_index.lua through semantic_runtime_projection.lua.
  Scope: `lua/src/linkedspec/semantic_index.lua` lines 594-753; `lua/src/linkedspec/semantic_observation.lua` lines 1-119; `lua/src/linkedspec/semantic_query.lua` lines 1-1142; `lua/src/linkedspec/semantic_runtime_projection.lua` lines 1-79
  Baseline evidence: 1500 fragments / 53106 bytes; ordered range SHA-256 `5148785e3cf31a218ea26f11df0d3e783be1e4524eb8c8138fa0c4e01fd31ef5`.
  Dependencies: .1.16 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Reading checkpoint: All four scopes consumed in twelve untruncated windows: index594–743,744–753; observation1–119; query1–150,151–300,301–450,451–600,601–750,751–900,901–1050,1051–1142; runtime projection1–79. Reading and causal reconciliation are complete; exact passed and failed proof is in docs/knowledge/lua-semantic-query-observation-reading-and-evidence-gaps.md.
  Verification: Lua .1.17 completes semantic index, observation and query reading and reads the runtime projection prefix in twelve complete windows: 1,500 fragments /53,106 bytes; cumulative17/51,21,151 fragments /868,215 bytes. All99 Lua sources remain baseline-identical;31 files are fully read. Query571 and projection269 pass per host; LuaJIT observation121/generated80 pass. Installed PUC observation120/121 and generated79/80 retain two nil-error failures, root-caused to documented5.5 host coercion under existing .2.2. Fourteen two-host query responses match; twelve agree fully with neutral and two false-to-null evidence differences gain .2.15 ownership. Six shared budget cases gain bounded Lua repair/proof under startup .82.3.1. Neutral6/20/128 passes; no supported dual-host or full-gate pass is claimed. All fifteen Lua roots and startup .37.1/.28.7/.82 remain pending. Named arguments stay approved and parked. Next .1.18 reads the runtime projection suffix and static projection prefix under unchanged startup and ADR0118 prerequisites. Independent preservation, memory, Knowledge, both histories, rendered book and normal hooks govern this reading/evidence commit; the two PUC test failures are not waived or closed.
  Commit: `LUA-STARTUP-READING.1.17 - read semantic queries and preserve budget and host failure ownership`

- ID: `LUA-STARTUP-READING.1.18`
  Status: `done`
  Activation commit: `cdf15066d507d5bced806dbee5139aeab203e270`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading/baseline identity; runtime/static projection Knowledge reconciliation and selected native/neutral consumers; memory, Knowledge, both histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no runtime or contract change. Later closeout and push retain canonical prerequisites.
  Goal: Read and understand group 18: semantic_runtime_projection.lua through semantic_static_projection.lua.
  Scope: `lua/src/linkedspec/semantic_runtime_projection.lua` lines 80-289; `lua/src/linkedspec/semantic_static_projection.lua` lines 1-1290
  Baseline evidence: 1500 fragments / 50709 bytes; ordered range SHA-256 `996883ed5d7c8cbbf051fb6672c848c2bd7836f49d44713495cea70f80a89844`.
  Dependencies: .1.17 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Reading checkpoint: All two ranges consumed in six untruncated windows: runtime projection80–289; static projection1–150,151–450,451–750,751–1050,1051–1290. Reading and causal reconciliation are complete; exact source/runtime observations and proof are in docs/knowledge/lua-semantic-projector-reading-and-source-ownership-gaps.md.
  Verification: Lua .1.18 reads the runtime projector suffix and static prefix in six complete windows: 1,500 fragments /50,709 bytes; cumulative 18/51, 22,651 fragments /918,924 bytes. All 99 Lua sources remain baseline-identical; 32 files are fully read. Four selected suites pass 591 assertions per installed host, 1,182 total. Ten complete two-host semantic observations locate mixed-slot and regex-call source failures under .2.16/.2.17 and grouped-selector recurrence under shared startup .70. Sixteen native/reconstructed matcher rows per host plus eight reference Get executions locate explicit child-match divergence under .2.18; the initial ten reference cases retain nine agreements and one mismatch. Neutral 6/20/128 passes; prior PUC observation failures remain .2.2-owned. All eighteen Lua repair roots remain open. Next .1.19 reads the static projector suffix, SHA module and emitter prefix; approved named arguments and all startup/ADR0118 prerequisites remain unchanged. Exact preservation, memory, Knowledge, both histories, rendered book and normal hooks govern this reading/evidence commit.
  Commit: `LUA-STARTUP-READING.1.18 - read semantic projectors and own source and matcher repairs`

- ID: `LUA-STARTUP-READING.1.19`
  Status: `done`
  Activation commit: `1d569ea18c7256d6d0b4493e57373a84df86879d`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading/baseline identity; static projection, SHA and emitter Knowledge reconciliation and selected native/neutral consumers; memory, Knowledge, both histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no runtime or contract change. Later closeout and push retain canonical prerequisites.
  Goal: Read and understand group 19: semantic_static_projection.lua through source_emitter.lua.
  Scope: `lua/src/linkedspec/semantic_static_projection.lua` lines 1291-2438; `lua/src/linkedspec/sha256.lua` lines 1-187; `lua/src/linkedspec/source_emitter.lua` lines 1-165
  Baseline evidence: 1500 fragments / 52334 bytes; ordered range SHA-256 `69bb5c76b2bc703c39db1e27a4083c1f5658e33583d6abc9177d81ce668cda0c`.
  Dependencies: .1.18 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Reading checkpoint: Three ranges consumed in six untruncated windows: static1291–1590,1591–1890,1891–2190,2191–2438; SHA1–187; emitter1–165. Reading and causal reconciliation are complete; exact observations and proof are in docs/knowledge/lua-static-completion-sha-emitter-reading-and-conditional-gaps.md.
  Verification: Lua .1.19 completes static projection and SHA reading and reads the emitter prefix in six complete windows: 1,500 fragments /52,334 bytes; cumulative 19/51, 24,151 fragments /971,258 bytes. All 99 Lua sources remain baseline-identical; 34 files are fully read. Source382, staged97 and remaining122 assertions pass per installed host, 1,202 total. Nine complete two-host observations and 18 query schemas retain the shared .22 call gate and .67.2 RHS-source omissions; Lua .2.19 owns conditional entry coverage and its impact/implementation/proof children. Missing-rule and slot-range controls retain distinct diagnostics. Neutral 6/20/128 and generated-source contract checks pass as qualified governance, not fresh runtime admission. All nineteen Lua repair roots and prior PUC observation failures remain open. Next .1.20 reads emitter, source-location and source-runtime ranges plus the spec AST prefix; named arguments and startup/ADR0118 prerequisites remain unchanged. Exact preservation, memory, Knowledge, both histories, rendered book and normal hooks govern this reading/evidence commit.
  Commit: `LUA-STARTUP-READING.1.19 - complete static and SHA reading and own conditional entry repair`

- ID: `LUA-STARTUP-READING.1.20`
  Status: `done`
  Activation commit: `028d4158ee753c7a678df2470ba0e07feb0dc730`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading/baseline identity; emitter/source-location/spec AST Knowledge reconciliation and selected native/neutral consumers; memory, Knowledge, both histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no runtime or contract change. Later closeout and push retain canonical prerequisites.
  Goal: Read and understand group 20: source_emitter.lua through spec_ast.lua.
  Scope: `lua/src/linkedspec/source_emitter.lua` lines 166-789; `lua/src/linkedspec/source_location.lua` lines 1-436; `lua/src/linkedspec/source_location_runtime.lua` lines 1-325; `lua/src/linkedspec/spec_ast.lua` lines 1-115
  Baseline evidence: 1500 fragments / 54002 bytes; ordered range SHA-256 `3dba5254dfc4c319bfccce1ea072eb313f8e4099934ee5717343d0b79ba60114`.
  Dependencies: .1.19 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: Four ranges consumed in eight untruncated windows: emitter166–365,366–565,566–789; source location1–220,221–436; runtime1–170,171–325; spec AST1–115. All 1,500 fragments /54,002 bytes are consumed; exact scope and comprehension live in docs/knowledge/lua-emitter-source-location-reading-and-boundary-gaps.md.
  Comprehension: Generated v2 contract/plan validation and effective-spec emission, private callback carriers, typed Unicode source snapshots/positions/spans/provenance, compatibility nil adapters and strict AST primitive/dense-list boundaries.
  Findings: Existing .2.8 and .2.13 gain generated-options and typed-clipping children; new .2.20/.2.21 own explicit contract values and serializable rejected-coordinate errors. Shared startup .60.2 retains large floating-count policy. All repair nodes remain pending behind startup prerequisites.
  Verification: Lua .1.20 completes emitter and typed-source reading and reads the spec AST prefix in eight complete windows: 1,500 fragments /54,002 bytes; cumulative 20/51, 25,651 fragments /1,025,260 bytes. All 99 Lua sources remain baseline-identical; 37 files are fully read. Typed240 and generated106 assertions pass per installed host, 692 total. The 112 complete observations and six fresh Perl facade/lowering/source controls locate generated false defaults, rejected-coordinate diagnostic serialization and PUC typed-slice overflow. Lua .2.8.9/.10 and .2.13.3/.4 extend existing owners; .2.20/.2.21 add contract and diagnostic repair/proof; shared .60.2 retains floating-count policy. Neutral typed14/0/231 and generated-source governance pass without fresh six-runtime admission. All twenty-one Lua repair roots and prior PUC observation failures remain open. Next .1.21 reads the spec AST suffix and loader prefix; named arguments and startup/ADR0118 prerequisites remain unchanged. Exact preservation, memory, Knowledge, both histories, rendered book and normal hooks govern this reading/evidence commit.
  Commit: `LUA-STARTUP-READING.1.20 - read emitter and typed sources and own boundary repairs`

- ID: `LUA-STARTUP-READING.1.21`
  Status: `done`
  Activation commit: `31ebbc2e414e035414845551b045c7002bf5df29`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading/baseline identity; spec AST/loader Knowledge reconciliation and selected reconstruction/resolution consumers; memory, Knowledge, both histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no runtime, generated-format or contract change. Later closeout and push retain canonical prerequisites.
  Goal: Read and understand group 21: spec_ast.lua through spec_loader.lua.
  Scope: `lua/src/linkedspec/spec_ast.lua` lines 116-1183; `lua/src/linkedspec/spec_loader.lua` lines 1-432
  Baseline evidence: 1500 fragments / 54561 bytes; ordered range SHA-256 `e4df52ef54026c29fb3b399c526d674d5b4c3201edbd796791d8cd7cda4be111`.
  Dependencies: .1.20 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: All eight windows consumed without truncation: AST116–315,316–515,516–715,716–915,916–1115,1116–1183; loader1–216,217–432. The two ranges total 1,500 fragments /54,561 bytes. Exact scope, comprehension and replay live in docs/knowledge/lua-spec-ast-loader-reading-and-validation-gaps.md.
  Comprehension: Primitive/node/list construction, callable and staged metadata, all body projections, typed JSON reconstruction and optional normalization; deterministic named/path resolution, strict source loading, request/source trace and exact pipeline error mapping.
  Findings: New .2.22/.2.23 own native false-field defaults and complete typed JSON validation; .2.1 gains stale guidance locations. Startup .7 retains the known child-group warning and its unresolved original PGID; subsequent control and empty listing do not close repair.
  Verification: Lua .1.21 completes spec AST reading and reads the loader prefix in eight complete windows: 1,500 fragments /54,561 bytes; cumulative 21/51, 27,151 fragments /1,079,821 bytes. All 99 Lua sources remain baseline-identical; 38 files are fully read. Descriptor912 and root-route106 assertions pass per installed host, 2,036 total. The 208 complete observations locate native false-field defaults and typed JSON array/payload validation gaps under new .2.22/.2.23 repair/proof owners; .2.1 retains stale guidance. Startup .7 records the known process-group warning with independent matching-group and empty read-only census controls, without claiming the original group was established. Neutral resolution14/9/4 and cursor8/0/60 pass as governance. All twenty-three Lua repair roots and prior PUC observation failures remain open. Next .1.22 reads the loader suffix, spec parser and validator prefix; named arguments and startup/ADR0118 prerequisites remain unchanged. Exact preservation, memory, Knowledge, both histories, rendered book and normal hooks govern this reading/evidence commit.
  Commit: `LUA-STARTUP-READING.1.21 - read AST and loader and own validation boundaries`

- ID: `LUA-STARTUP-READING.1.22`
  Status: `done`
  Activation commit: `65bd10925c633f1cee80ab25f03f7afa94d8daf6`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading/baseline identity; loader/parser/validator Knowledge reconciliation and selected parser/validation consumers; memory, Knowledge, both histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no parser, runtime or contract change. Later closeout and push retain canonical prerequisites.
  Goal: Read and understand group 22: spec_loader.lua through spec_validator.lua.
  Scope: `lua/src/linkedspec/spec_loader.lua` lines 433-539; `lua/src/linkedspec/spec_parser.lua` lines 1-1250; `lua/src/linkedspec/spec_validator.lua` lines 1-143
  Baseline evidence: 1500 fragments / 44459 bytes; ordered range SHA-256 `f110fc4919916a4df56b309d98b4b2be58b619c30100ddb99bcf4887022198c3`.
  Dependencies: .1.21 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Physical reading: All eight windows consumed without truncation: loader433–539; parser1–200,201–400,401–600,601–800,801–1000,1001–1250; validator1–143. The three ranges total 1,500 fragments /44,459 bytes. Exact scope, comprehension and replay live in docs/knowledge/lua-spec-parser-validator-reading-and-lexical-gaps.md.
  Comprehension: Loaded parse/validate/compile composition and copied derived identity; Unicode headers/modes, literal scanners, grouped selectors, body/inline collection, lifecycle shorthand/attached controls and fluent fallback; typed validator errors, runtime reservations and label checks. Supplemental diagnostic validator514–565 reading grants no advance group23 credit.
  Findings: .2.24 decomposes EOF, fluent, regex collection, regex validation and multiline quote repair plus independent proof; .2.8.11/.12 own parser/loaded options. Shared .54.3 and stale guidance .2.1 retain exact extensions. Valid compact literal/space controls and typed matches rejection remain intact.
  Verification: Lua .1.22 completes loader and spec parser reading and reads the validator prefix in eight complete windows: 1,500 fragments /44,459 bytes; cumulative 22/51, 28,651 fragments /1,124,280 bytes. All 99 Lua sources remain baseline-identical; 40 files are fully read. Root99 and standalone109 assertions pass per installed host, 416 total. The 88 complete observations locate unfinished edge blocks, argument-erasing fluents, distinct outer/validator regex handling and multiline quote-state loss under .2.24 with six bounded repair/proof children. Parser/loaded-engine false options extend .2.8.11/.12; .2.1 retains stale guidance and shared .54.3 now includes Lua regex recurrence. Neutral root7/0/54 and standalone14 mutations pass as governance. All twenty-four Lua repair roots and earlier failures remain open. Next .1.23 reads the validator suffix and staged AST enrichment prefix; named arguments and startup/ADR0118 prerequisites remain unchanged. Exact preservation, memory, Knowledge, both histories, rendered book and normal hooks govern this reading/evidence commit.
  Commit: `LUA-STARTUP-READING.1.22 - read source parser and own lexical completeness repairs`

- ID: `LUA-STARTUP-READING.1.23`
  Status: `done`
  Activation commit: `4e2cbd9a2f33b276718a5b7b8186f6a7df894852`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading/baseline identity; validator/staged enrichment Knowledge reconciliation and selected validation/provenance consumers; memory, Knowledge, both histories, rendered book and normal doctrines.
  Canonical trigger: Ordinary source-reading evidence; no validator, staged runtime or contract change. Later closeout and push retain canonical prerequisites.
  Goal: Read and understand group 23: spec_validator.lua through staged_ast_enrichment.lua.
  Scope: `lua/src/linkedspec/spec_validator.lua` lines 144-865; `lua/src/linkedspec/staged_ast_enrichment.lua` lines 1-778
  Baseline evidence: 1500 fragments / 54480 bytes; ordered range SHA-256 `56ec303aa8c4a6d47f54d40eef4a977642127eb0da7cfc4d74b4e03b23dccccb`.
  Dependencies: .1.22 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Comprehension: Exact validator ordering, selector/gap eligibility, function/edge validation and traced strict checks; opaque staged registry snapshots, pure resolution, narrowing authority, finite plain copies and job/cache identities through typed-order prefix. See docs/knowledge/lua-validator-staged-prefix-reading-and-array-gaps.md.
  Verification: Lua .1.23 completes the validator and reads the staged AST enrichment prefix in eight complete windows: 1,500 fragments /54,480 bytes; cumulative 23/51, 30,151 fragments /1,178,760 bytes. All 99 Lua sources remain baseline-identical; 41 files are fully read. Staged890 and gap392 assertions pass per installed host, 2,564 total. The 52 exact observations confirm false validator options and staged tagged-array member omission through private job identity and parent detachment, with zero callbacks and preserved caller inputs. .2.8.13/.14 own validator options; .2.25 owns complete staged shape validation and independent proof; .2.1 retains dated/current guidance reconciliation. Neutral staged123/public129 and gap63/public34 mutations pass as governance. All twenty-five Lua repair roots and earlier failures remain open. Next .1.24 completes staged enrichment and reads capture provenance and the parse-job prefix; named arguments and startup/ADR0118 prerequisites remain unchanged.
  Preservation: Independent replay preserves 1398 earlier files and 2528 of 2533 old task nodes; exactly five owned old nodes change and five pending repair nodes are added. All 81 prior Known headings remain, with one addition; both history suffixes and parked authoring tree are exact. Coverage reconstructs all 99 Lua sources and 23 completed groups. Memory 60, both history budgets and book render pass; search index 10097626 bytes retains known warning ownership under startup .41.9. Normal hooks remain required for landing.
  Commit: `LUA-STARTUP-READING.1.23 - read validator and staged prefix and own array validation`

- ID: `LUA-STARTUP-READING.1.24`
  Status: `done`
  Activation commit: `8469d5ba11c56cc91e0d86b9b586feb68502f9ca`.
  Verification tier: `focused`
  Focused checks: Exact bounded source/baseline identity; staged recursive/marker Knowledge reconciliation, selected provenance/resource consumers and bounded diagnostics; memory, Knowledge, both histories, book and normal doctrines.
  Canonical trigger: Ordinary reading and repair intake; no staged runtime, provenance or contract change. Later closeout and push retain canonical prerequisites.
  Goal: Read and understand group 24: staged_ast_enrichment.lua through staged_parse_job.lua.
  Scope: `lua/src/linkedspec/staged_ast_enrichment.lua` lines 779-2187; `lua/src/linkedspec/staged_capture_provenance.lua` lines 1-42; `lua/src/linkedspec/staged_parse_job.lua` lines 1-49
  Baseline evidence: 1500 fragments / 56196 bytes; ordered range SHA-256 `38f96a914d93193a8d3ebc02f24a4d806a12e36450859cc822bcec446daf5b82`.
  Dependencies: .1.23 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Comprehension: Full-depth target preparation/stitching, finite ordinary and atomic marker detachment, typed provenance rebasing, shared recursive counters/diagnostics, fresh execution seeds, separate one-depth dispatch and weak-key capture storage. Exact evidence and bounded replay: docs/knowledge/lua-staged-completion-reading-and-boundary-gaps.md.
  Verification: Lua .1.24 completes staged enrichment and capture provenance and reads the parse-job prefix in nine complete windows: 1,500 fragments /56,196 bytes; cumulative 24/51, 31,651 fragments /1,234,956 bytes. All 99 Lua sources remain baseline-identical; 43 files are fully read. Existing staged consumers pass 890 assertions per installed host, 1,780 total. The 102 boundary observations measure retained diagnostic overruns, bounded marker cycle/null handling, private capture admission and seeded defaults; the sparse-seed host difference remains explicit. New .2.26/.2.27/.2.28 own bounded repair/proof, .2.8.15/.16 own seeded-call defaults and .2.25 retains copy-before-validation scope. Shared Dart .2.17.1 records independent Lua diagnostic confirmation. Neutral staged123/public129 and typed231 mutations pass as governance. All twenty-eight Lua repair roots and earlier failures remain open. Next .1.25 reads declarations, the narrow registry, tracing and Unicode prefix; named arguments and startup/ADR0118 prerequisites remain unchanged.
  Preservation: Independent replay preserves 1399 previous files and 2532 of 2538 prior task nodes; exactly six owned old nodes change and 14 pending repair nodes are added. All 82 prior Known headings remain, with three additions; both history suffixes and parked authoring tree are exact. Coverage reconstructs all 99 Lua sources and 24 completed groups. Memory 60, both history budgets and book render pass; large search-index warning remains startup .41.9-owned. Normal hooks remain required for landing.
  Commit: `LUA-STARTUP-READING.1.24 - finish staged reading and own diagnostic and provenance repairs`

- ID: `LUA-STARTUP-READING.1.25`
  Status: `done`
  Activation commit: `813b2aad2bda623b4e08f3e48d27f9216a47701e`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading/baseline identity; declaration, narrow registry, tracing and generated Unicode Knowledge reconciliation; selected declaration/trace consumers and bounded diagnostics; memory, Knowledge, both histories, book and normal doctrines.
  Canonical trigger: Ordinary reading and repair intake; no declaration, trace, registry or generated-data change. Later closeout and push retain canonical prerequisites.
  Goal: Read and understand group 25: staged_parse_job.lua through unicode_case_mapping.lua.
  Scope: `lua/src/linkedspec/staged_parse_job.lua` lines 50-264; `lua/src/linkedspec/staged_parser_registry.lua` lines 1-567; `lua/src/linkedspec/trace.lua` lines 1-500; `lua/src/linkedspec/trace_support.lua` lines 1-49; `lua/src/linkedspec/unicode_case_mapping.lua` lines 1-169
  Baseline evidence: 1500 fragments / 51794 bytes; ordered range SHA-256 `33b109f98ff932383f2a394953080da8776680afaea6b634f5d6a3d75ca80d81`.
  Dependencies: .1.24 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: Lua .1.25 completes parse-job declarations, the narrow registry and tracing, and reads the Unicode prefix in nine complete windows: 1,500 fragments /51,794 bytes; cumulative 25/51, 33,151 fragments /1,286,750 bytes. All 99 Lua sources remain baseline-identical; 47 files are fully read. Five selected trace/registry tests pass 134 assertions per installed host, 268 total. The 164 complete observations confirm provenance type/segment admission, false options, trace error replacement and formatter cleanup gaps. New .2.29/.2.30 own provenance and trace repairs; .2.8.17-.20 own registry/trace admission and .2.1 retains guidance reconciliation. Dart .2.19 records independent Lua confirmation without new Dart execution. Neutral staged123/public129, typed231 and Unicode17/12 fixtures pass as governance. All thirty Lua repair roots and earlier failures remain open. Next .1.26 reads Unicode lines 170-1669; named arguments and startup/ADR0118 prerequisites remain unchanged. Exact evidence: docs/knowledge/lua-declaration-trace-reading-and-validation-gaps.md.
  Commit: `LUA-STARTUP-READING.1.25 - read declarations and trace and own validation repairs`.

- ID: `LUA-STARTUP-READING.1.26`
  Status: `done`
  Activation commit: `67a97d3d32beb8b83fa1864e45102966699d7836`.
  Verification tier: `focused`
  Focused checks: Complete bounded generated-table reading, exact baseline/range identity and Unicode Knowledge reconciliation; scoped mapping evidence plus preserved prior generation/contract proof; memory, Knowledge, both histories, book and normal doctrines.
  Canonical trigger: Ordinary generated-source reading only; no source, generated format, Unicode version or contract change. Later closeout and push retain canonical prerequisites.
  Goal: Read and understand group 26: unicode_case_mapping.lua.
  Scope: `lua/src/linkedspec/unicode_case_mapping.lua` lines 170-1669
  Baseline evidence: 1500 fragments / 35080 bytes; ordered range SHA-256 `899f29584aa57d08bbafabeb7e7840e98be6710a2beb66c418dcd09fa4274439`.
  Dependencies: .1.25 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: Lua .1.26 reads all Unicode mapping lines 170-1669 in seven complete windows: 1,500 fragments /35,080 bytes; cumulative 26/51, 34,651 fragments /1,321,830 bytes. All 99 Lua sources remain baseline-identical; 47 files are fully read. Every scoped mapping matches the neutral contract: 1,398 lower and 99 upper entries. Both installed hosts pass all 2,994 direct mapping observations and 198 existing Unicode fixture assertions. Twelve generation/proof inputs remain identical to .1.25, preserving its successful regeneration without recounting that run. No new defect is found in this range; all thirty Lua repair roots and earlier failures remain open. Next .1.27 reads Unicode lines 1670-3169; named arguments and startup/ADR0118 prerequisites remain unchanged. Exact evidence: docs/knowledge/lua-unicode-lower-completion-reading.md.
  Commit: `LUA-STARTUP-READING.1.26 - complete lower-case table reading and verify scoped mappings`.

- ID: `LUA-STARTUP-READING.1.27`
  Status: `done`
  Activation commit: `2e7046a44d0f6cafdc5bfeccc31f76c72b6ab122`.
  Verification tier: `focused`
  Focused checks: Complete bounded generated-table reading, exact baseline/range identity and Unicode Knowledge reconciliation; every scoped mapping and property range checked against neutral data, relevant native casing proof; memory, Knowledge, both histories, book and normal doctrines.
  Canonical trigger: Ordinary generated-source reading; no source, Unicode version, generated format or contract change. Later closeout and push retain canonical prerequisites.
  Goal: Read and understand group 27: unicode_case_mapping.lua.
  Scope: `lua/src/linkedspec/unicode_case_mapping.lua` lines 1670-3169
  Baseline evidence: 1500 fragments / 35947 bytes; ordered range SHA-256 `29933fa8d627a20c344cab6e3c6a3f21827fd84ed2d8056f0b22161e21d64018`.
  Dependencies: .1.26 committed with clean handoff.
  Acceptance: Read every scoped byte without truncation; record comprehension, Knowledge and repair reconciliation, focused proof and a clean per-leaf commit.
  Verification: Lua .1.27 reads all Unicode mapping lines 1670-3169 in six complete windows: 1,500 fragments /35,947 bytes; cumulative 27/51, 36,151 fragments /1,357,777 bytes. All 99 Lua sources remain baseline-identical; 47 files are fully read. Every remaining uppercase entry and all fifteen Cased prefix ranges match the neutral contract. Both installed hosts pass 2,964 complete scoped uppercase observations, including 100 expansions. Prior .1.26 proof of 198 fixture assertions and .1.25 generation proof remain source-identical and are not recounted. No new defect is found in this range; all thirty repair roots and earlier failures remain open. Next .1.28 reads the casing suffix and rule-label prefix; named arguments and startup/ADR0118 prerequisites remain unchanged. Exact evidence: docs/knowledge/lua-unicode-upper-completion-reading.md.
  Commit: `LUA-STARTUP-READING.1.27 - complete uppercase table reading and verify scoped mappings`.

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
  Children: `.2.1` owns README status; `.2.2` primary identity; `.2.3` native error safety; `.2.4` executable diagnostic teaching; `.2.5` complete quoted-literal parsing; `.2.6` harray pair completeness; `.2.7` complete switch contract diagnostics; `.2.8` iteration/options/matching-cursor validation; `.2.9` false delimiter preservation; `.2.10` whole child-result false preservation; `.2.11` exact representable integer JSON encoding; `.2.12` finite private recognition coordinates and progress; `.2.13` scalar/reducer and typed-slice integer overflow; `.2.14` semantic diagnostic null preservation; `.2.15` rejected semantic query false evidence; `.2.16` mixed structural-slot correlation; `.2.17` regex-aware call source correlation; `.2.18` explicit child-slot runtime match ownership; `.2.19` conditional entry-explanation coverage; `.2.20` explicit generated-contract validation; `.2.21` finite typed-source diagnostic coordinates; `.2.22` native AST false-field defaults; `.2.23` typed JSON array and payload validation; `.2.24` complete outer parser delimiters and lexical state; `.2.25` complete staged typed-array copying; `.2.26` retained staged diagnostic bytes; `.2.27` marker detachment cycle/null handling; `.2.28` private capture-range admission; `.2.29` original provenance and complete segments; `.2.30` trace error precedence and cleanup.
  Reading .1.25 owners: `.2.29` owns original provenance types and complete derived segment membership; `.2.30` owns trace failure precedence and scope cleanup.
  Acceptance: Define concrete causal evidence, affected behavior and repair/verification children before implementing any finding; preserve startup prerequisites and all earlier owners.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.1`
  Status: `pending`
  Goal: Correct stale present-tense Lua README, canonical guidance and stale source comments while preserving historical evidence.
  Evidence: Reading .1.1 finds lua/README.md lines 656-657 still saying the complete gate remains at staged 176/177. Canonical lua-root-rule-selection-preflight records superseding July 19 admission at 177/177 per ABI, and lua-callable-codeblock-emitted-route-identity records later complete 177/177 with CLI 66x2. The current 139 root and 359 logical assertions per ABI pass; no new full-gate result or runtime failure is inferred.
  Reading .1.2 extension: The generated-source section repeats the obsolete current 176/177 claim, and the scalar-coercion section still calls explicit codeblock-call syntax future despite the already documented and admitted callable implementation. Reconcile all three exact current-tense statements under the same documentation repair.
  Reading .1.6 extension: docs/knowledge/lua-corpus-manifest-io.md still calls the primary parser a scaffold failure despite later .7.1-.7.3 admission and current facade status/exports. Correct that exact current-tense sentence with preserved dated corpus evidence under the same documentation repair; source and canonical reconciliation are in docs/knowledge/lua-compiled-corpus-facade-reading.md.
  Reading .1.7 extension: lua-runtime-rule-interpreter still describes global seek/consume engine options; lua-runtime-core-value-capture-helpers still describes no intermediate creation and future explicit callable values. Current option rejection, nested-write creation and codeblock-kind probes plus their admitted canonical owners supersede those sentences. Include these exact runtime-card corrections without deleting historical proof.
  Reading .1.9 extension: lua-runtime-builtin-final-codeblocks-with and lua-runtime-eager-block-values retain future explicit-callable prose despite the current common executor and emitted-identity admission. Include these exact current-guidance corrections; keep the original dated implementation evidence intact.
  Reading .1.15 extension: recognition_transaction.lua header lines 3–4 still describes future runtime consumption despite the integrated adapter and current 246-assertion admitted consumer on both hosts. Correct or explicitly date this source comment under the existing guidance repair; preserve the private facade boundary and historical integration evidence.
  Reading .1.17 extension: semantic_index.lua header line3 still calls generated observation propagation a later owner; lua-semantic-query-public-api retains present-tense pending-generated/observation wording despite its current-complete metadata and implemented generated-route consumer. Correct or explicitly date these exact claims under the existing guidance repair, preserving original stage-specific counts and chronology.
  Reading .1.21 extension: lua-frontend-ast-json-contract and lua-frontend-validation still label dated 60/60 evidence as the current full gate; lua-native-spec-resolution ends with descriptors/full trace active despite later closeout; lua-rule-local-cursor-descriptor retains generated-v1 and staged outer-option body guidance superseded by the current v2/removed-option owners. Correct or explicitly date these precise claims, retaining all historic counts and current supported-PUC limitations.
  Reading .1.22 extension: lua-core-spec-parser still labels its historical 60/60 local gate current; date or correct that sentence with the other frontend cards, retaining original source/corpus milestones and the supported-PUC limitation.
  Source: docs/knowledge/lua-readme-reading-and-status-drift.md retains exact dated bytes, locations and commands.
  Children: `.2.1.1`, `.2.1.2`
  Dependencies: Startup .3/.4/.5 and the complete Lua README reading before source-document repair.
  Reading .1.23 extension: Retrieved staged marker/current-depth/admission/recomposition cards retain dated 888-assertion evidence and some present-tense 888 totals; the unchanged admitted source freshly passes 890 on each installed host. Preserve historical evidence while reconciling current prose after startup gates. Current-depth copy guarantees also require the qualified .2.25 malformed-host-array limitation.
  Reading .1.25 extension: lua-staged-function-body-registry still calls public parse_job and recursive queues future; lua-staged-function-execution-split retains pending descriptors/generated/callable wording despite later admitted owners. Reconcile these dated/current boundaries. Qualify trace control silence against explicit file-reset semantics and full-pipeline original-error/balanced-scope claims against the newly measured .2.30 limitations; retain original healthy-writer test evidence.
  Acceptance: Remove the false current failure projection, distinguish historical counts from current guidance, preserve useful unique history through canonical pointers, and independently verify the resulting public wording and native command examples.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.1.1`
  Status: `pending`
  Goal: Repair the exact stale Lua README status and reconcile nearby historical rollout wording.
  Scope: lua/README.md logical/generated gate paragraphs, scalar-coercion callable-syntax sentence and docs/knowledge/lua-corpus-manifest-io.md primary-scaffold sentence; stale global-engine-mode, nested-write and callable-current prose in docs/knowledge/lua-runtime-rule-interpreter.md and docs/knowledge/lua-runtime-core-value-capture-helpers.md; explicit-callable future prose in docs/knowledge/lua-runtime-builtin-final-codeblocks-with.md and docs/knowledge/lua-runtime-eager-block-values.md; the stale future-integration header in lua/src/linkedspec/recognition_transaction.lua; generated-observation future wording in lua/src/linkedspec/semantic_index.lua and docs/knowledge/lua-semantic-query-public-api.md; directly related current-versus-historical guidance; public book and canonical evidence pointers.
  Dependencies: Parent .2.1 prerequisites; .1.2 completes the README; current evidence retrieval before claiming any contemporary suite count.
  Acceptance: Replace the obsolete 176/177 current-failure statement with accurate dated evidence or stable command guidance. Audit nearby present-tense counts against their canonical owners without treating earlier passing counts as freshly measured signoff. Preserve source examples, distinct proof scope and unique history. Run changed-document public contract checks, book render and relevant two-ABI command proof.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.1.2`
  Status: `pending`
  Goal: Independently verify and close the Lua README status correction.
  Dependencies: .2.1.1 committed cleanly.
  Acceptance: Compare the original dated statement with the corrected rendered and canonical corpus/runtime guidance, confirm no stale failure is presented as current and no unsupported pass is substituted, preserve historical provenance and all other known limitations, verify applicable public contracts and close .2.1 only on evidence.
  Reading .1.9 acceptance: Check both older callback cards against the common dynamic executor and independently loaded emitted proof; retain their original dates and measured counts.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.2`
  Status: `pending`
  Goal: Restore the declared PUC Lua 5.4 primary proof and make runtime/header identity explicit.
  Evidence: September 12 .1.2 runtime census reports lua and pkg-config lua both 5.5.1, with LuaJIT 2.1.1788460057. The canonical lua-toolchain-package-policy declares PUC 5.4.8. The targeted wrapper selects unversioned lua and the builder independently selects pkg-config lua, with no target-version or header/runtime identity guard. No lua5.4/lua54 command, versioned pkg-config entry or installed Homebrew 5.4 tree was found in the inspected toolchain locations.
  Children: `.2.2.1`, `.2.2.2`
  Dependencies: Startup .3/.4/.5 before toolchain/gate implementation; preserve the declared 5.4 target unless a separate explicit policy decision changes it.
  Acceptance: Establish a repository-local or explicitly documented read-only 5.4 runtime/development pair, bind and validate both identities before building, reject mismatch with precise diagnostics, and rerun required conformance on 5.4 plus LuaJIT. The measured .1.2 PUC process is 5.5.1; earlier unversioned passes did not record a 5.4 runtime identity and cannot establish it. Source reading itself grants no conformance admission.
  Reading .1.17 extension: Installed PUC5.5 fails one native and one generated semantic-observation assertion because error(nil,0) becomes the string <no error object>; LuaJIT passes both. A bare pcall/error probe without importing LinkedSpec reproduces the difference, while false/string/table identity controls agree. Official Lua5.5 manual section2.3 and ldebug.c luaG_errormsg document/implement this host change. Keep the declared5.4 target and restore matching runtime/header proof; do not rewrite the 5.4 nil-error expectations or translate that legitimate string back into nil.
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
  Reading .1.17 acceptance: Re-run both complete semantic native-observation121 and generated-observation80 consumers on the restored declared5.4 host and LuaJIT, with exact nil/false/string/table error identity controls. Retain the two measured installed5.5 failures as host-incompatibility evidence; an unrelated passing consumer does not close them.
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

- ID: `LUA-STARTUP-READING.2.8`
  Status: `pending`
  Goal: Reject explicitly invalid iteration and staged seeded-call counts, optional runtime/matching/MCP/generated/parser/loaded-engine/validator tables and matching cursors before applying absent-value defaults.
  Evidence: Reading .1.7 executes the real native facade on PUC 5.5.1 and LuaJIT. max_iterations=false creates an engine with 10000; omitted options also use 10000, positive 1/2 are retained, and true/0/-1/1.5/string "2" reject. interpreter.lua line 144 uses options.max_iterations or 10000 before the type/range check, so false is replaced before validation. This is an option-validation defect; no long-running parser failure is inferred.
  Children: `.2.8.1`, `.2.8.2` own the iteration field; `.2.8.3`, `.2.8.4` own public runtime optional-table boundaries; `.2.8.5`, `.2.8.6` own matching defaults; `.2.8.7`, `.2.8.8` own MCP constructor options; `.2.8.9`, `.2.8.10` own generated execution/failure options; `.2.8.11`, `.2.8.12` own parser and loaded-engine options; `.2.8.13`, `.2.8.14` own validator options; `.2.8.15`, `.2.8.16` own staged seeded-call admission; `.2.8.17`, `.2.8.18` own narrow registry options; `.2.8.19`, `.2.8.20` own trace table/field admission.
  Dependencies: Startup .3/.4/.5; preserve the declared PUC target and existing toolchain repair .2.2.
  Reading .1.10 extension: Native engine/parse/execute/traced-parse/traced-execute all accept false options while nil/empty tables pass and true/zero/string reject typed table errors. Three options or {} owners replace false before validation; the execution aliases inherit that behavior. Keep this additional surface decomposed under .2.8.3/.4, independently from the numeric field.
  Reading .1.11 extension: Matching seek/consume/required-slot, register cursor construction and cursor setter accept false as zero; false register options become defaults. Other invalid cursors/options reject typed errors, and false capture_start_byte correctly rejects. Keep matching normalization isolated in new .2.8.5/.6; retain existing clamping and capture clearing semantics.
  Reading .1.14 extension: deployment_policy(false) and registration_options(false) accept protected default objects on both installed hosts; nil/empty tables pass, other invalid table values and explicitly false named fields reject. mcp_server.lua 142/180 use options or {} before plain-table validation. Existing serve_stdio and register_index have explicit nil-only option handling and remain compatibility controls; do not infer a policy elevation or wire parsing failure.
  Reading .1.20 extension: Five direct/traced/emitted/failure-constructor operations accept false options after defaulting; nil/empty tables pass and true/zero/text reject. source_emitter.lua 250/494 normalize before validation. Thirty observations per installed host retain existing successful values and diagnostics. Exact replay: docs/knowledge/lua-emitter-source-location-reading-and-boundary-gaps.md.
  Reading .1.22 extension: parse_spec and loaded-engine function/method forms accept false options; absent/empty pass, true/zero/text reject established typed errors. spec_parser.lua1182 and spec_loader.lua489/507 use or defaults before validation. Eighteen complete observations per host retain parsed rule count and loaded result7.
  Reading .1.23 extension: validate_spec accepts false options as an empty table on both installed hosts; absent/empty succeed and true/zero/text reject the typed validation error. spec_validator.lua823 replaces false before the table check. Six complete observations per host; .2.8.13/.14 own this direct facade boundary.
  Reading .1.24 extension: recursive_authority uses config.total_calls or 0 at line1462; false becomes zero while true/fraction/text reject the total_calls diagnostic. Absent/zero/one controls retain 0/0/1. The actual saturated-call dispatcher correctly rejects before increment at line1779; this defect concerns constructor admission only.
  Reading .1.25 extension: Five narrow registry entrypoints accept false options through staged_parser_registry.lua37; trace config/emitter accept false tables through trace.lua157/352. Config level/sink fields and enabled/with helpers replace false with none/stdout at147/149, while direct parsers and environment false correctly reject. Fifty-one complete observations per installed host retain valid booleans reset_file=false and emoji=false. Children `.2.8.17/.18` own registry options and `.2.8.19/.20` own trace admission; no file reset occurs in the boundary probe.
  Acceptance: Default only when the field or optional table is absent, retain positive integer behavior, reject explicitly invalid supplied values with the established typed error, and preserve source identity and successful parser behavior. Decompose any additional affected option surfaces before expanding scope.
  Verification: `pending`; .1.7 retains the exact native comparison in docs/knowledge/lua-interpreter-prefix-reading-and-iteration-option-gap.md.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.1`
  Status: `pending`
  Goal: Make runtime-engine iteration defaulting depend on absence and validate every supplied value.
  Scope: The existing max_iterations default/validation in lua/src/linkedspec/interpreter.lua; focused API regression and current public guidance.
  Dependencies: Parent .2.8 prerequisites.
  Acceptance: Show false-default RED and typed-rejection GREEN with omitted/positive controls; retain invalid true/zero/negative/fraction/string handling, declared supported-runtime coverage and full interpreter syntax checks. Do not change the default or repetition/while semantics.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.2`
  Status: `pending`
  Goal: Independently verify explicit iteration-option validation through supported engine construction routes.
  Dependencies: .2.8.1 committed cleanly.
  Acceptance: Compare direct and loaded-engine option forwarding using independent valid/invalid tables on the supported PUC runtime and LuaJIT; preserve default/positive settings, typed errors and parse results. Confirm any generated route's option contract before including it and close .2.8 only with evidence.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.3`
  Status: `pending`
  Goal: Validate supplied public runtime option tables before applying omitted-table defaults.
  Dependencies: Parent .2.8 startup and declared-runtime prerequisites; preserve separately owned iteration-field work .2.8.1/.2.
  Scope: runtime_engine, runtime_parse and runtime_parse_with_trace options normalization in lua/src/linkedspec/interpreter.lua, plus their execute aliases and focused public API guidance.
  Acceptance: Default nil only and reject supplied false with the existing typed table error; preserve nil/empty/valid tables, true/number/string rejection, removed cursor-option diagnostics, caller-table preservation and disabled/active trace semantics. Show the five direct entry-point cases RED/GREEN without changing parse output or iteration behavior.
  Verification: `pending`; exact five-route comparison is in docs/knowledge/lua-interpreter-json-reading-and-option-table-gap.md.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.4`
  Status: `pending`
  Goal: Independently verify nil-only runtime option-table defaults across supported public callers.
  Dependencies: .2.8.3 committed cleanly.
  Acceptance: Exercise engine/parse/execute/traced entry points and applicable loaded/generated adapters with independent absent/false/invalid/valid option tables on supported PUC and LuaJIT. Assert unchanged typed diagnostics, input/caller-table preservation and successful result identity. Close parent .2.8 only after all eight children and public/Knowledge evidence agree.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.5`
  Status: `pending`
  Goal: Validate supplied matching cursors and register option tables before defaulting.
  Dependencies: Parent .2.8 startup/identity prerequisites; preserve the separate numeric-field and public-runtime table repairs.
  Scope: seek_match, consume_match, match_runtime_regex_slot and runtime_match_registers defaults in lua/src/linkedspec/matching.lua, inherited runtime/alternation aliases and with_cursor_byte.
  Acceptance: Default only nil; reject false using existing typed offset/table errors. Preserve omitted/zero/valid numeric cursors, negative/end clamping, Unicode boundary rejection, independent seek/consume policy, explicit null capture clearing, child/local register identity and caller inputs. Show all six observed false routes RED/GREEN without exercising the separately broken native invalid-pattern formatter.
  Verification: `pending`; exact matching controls are in docs/knowledge/lua-json-matching-reading-and-integer-encoding-gap.md.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.6`
  Status: `pending`
  Goal: Independently verify matching optional-value validation and unchanged register/cursor semantics.
  Dependencies: .2.8.5 committed cleanly.
  Acceptance: Cover direct functions and methods, required-slot and choice paths, register construction/update/child entry, omitted/false/other invalid options and UTF-8 boundaries on supported PUC and LuaJIT. Preserve matched/no-match/zero-width distinctions, typed failures and all prior runtime defaults. Close the matching children before parent .2.8 admission.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.7`
  Status: `pending`
  Goal: Reject explicitly false MCP deployment-policy and registration constructor option tables.
  Dependencies: Startup .3/.4/.5; retain .2.2 supported-PUC prerequisites and the other .2.8 surfaces.
  Acceptance: Replace false-erasing defaults at mcp_server.lua 142/180 with absent-only handling, retaining established plain-table diagnostics, immutable object identities, valid field values and nil/empty defaults. Preserve correct false-field rejection and register_index/serve_stdio option validation. Inspect the separate package-private test dependency defaults as a documented scope census; decompose additional required changes before expanding this repair.
  Verification: `pending`; .1.14 records two constructor observations and 33 valid controls per installed host.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.8`
  Status: `pending`
  Goal: Independently verify MCP option-table validation and unchanged decoded/stdio behavior.
  Dependencies: .2.8.7 committed cleanly.
  Acceptance: Exercise root facade and module constructors with absent, false, other invalid and valid option tables on supported PUC and LuaJIT; distinguish invalid whole tables from false fields. Retain registry/stdio typed option boundaries, caller data and existing policy/capability behavior. Run relevant decoded/stdio consumers and synchronize public/Knowledge evidence before closing these children and parent .2.8.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.9`
  Status: `pending`
  Goal: Preserve explicitly false delimiters in receiver join and mutable split as their pure function equivalents do.
  Evidence: Reading .1.8 runs both native hosts: join_values(false,["a","b"]) gives a0b while ["a","b"].join_values(false) gives ab; split("a0b",false) gives["a","b"] while split(parts,"a0b",false) stores["a","0","b"]. Matching true/0/string/empty controls agree. Interpreter1930-1931 and2260-2261 use an and/or empty-string fallback that replaces an evaluated false argument before shared scalar conversion. Canonical function/receiver and pure/mutable policies require the same delimiter semantics.
  Children: `.2.9.1`, `.2.9.2`
  Dependencies: Startup .3/.4/.5 and existing declared-runtime repair .2.2 for supported PUC proof.
  Acceptance: Default only for an absent delimiter expression, preserve false through scalar conversion, evaluate explicit delimiter expressions once and retain current pure/mutable/receiver result and copy behavior. Keep invalid iteration-option repair .2.8 separate because false is valid here.
  Verification: `pending`; exact native replay and paired controls are owned by docs/knowledge/lua-interpreter-helper-reading-and-false-delimiter-gap.md.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.9.1`
  Status: `pending`
  Goal: Correct the two delimiter expression fallbacks without changing helper semantics.
  Scope: evaluate_array_values receiver join and evaluate_mutable_split in lua/src/linkedspec/interpreter.lua; focused function/receiver and pure/mutable tests plus user guidance.
  Dependencies: Parent .2.9 prerequisites.
  Acceptance: Show both false cases RED/GREEN on supported hosts; retain omitted/true/zero/string/empty delimiters, exact source/target values and detached results. Preserve single evaluation for a computed false delimiter and run interpreter syntax checks without adding top-level locals unnecessarily.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.9.2`
  Status: `pending`
  Goal: Independently verify false delimiter parity across supported Lua carriers.
  Dependencies: .2.9.1 committed cleanly.
  Acceptance: Use independently chosen literal and computed-false delimiters through native, reconstructed and applicable generated/emitted carriers on supported PUC and LuaJIT. Verify function/receiver equality, pure/mutable equality, exact once-only effects and unchanged source/target copy semantics; close only after public guidance and required proof agree.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.10`
  Status: `pending`
  Goal: Preserve a false whole child result in implicit and explicit child-rule push forms.
  Evidence: Reading .1.9 confirms push(Child) and push(Child,items) append null when Child returns false on both installed hosts. Direct call, ordinary push(items,call(Child)) and indexed child false values preserve false; true/zero/empty-string/array/harray/null whole results agree. Interpreter 3245 uses child_index == nil and child.value or read_index(...), so a legitimate false whole result incorrectly enters scalar indexing and becomes null at read_index 620-630.
  Children: `.2.10.1`, `.2.10.2`
  Dependencies: Startup .3/.4/.5 and declared PUC identity .2.2 for supported-host proof.
  Acceptance: Branch on index presence independently from child value, preserving whole false/null and indexed behavior, cached edge dispatch, once-only child execution and detached accumulator results. Keep delimiter .2.9 and iteration-option .2.8 repairs distinct.
  Verification: `pending`; exact native replay and controls are in docs/knowledge/lua-interpreter-callable-reading-and-child-false-gap.md.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.10.1`
  Status: `pending`
  Goal: Correct whole-result child push selection with explicit optional-index handling.
  Dependencies: Parent .2.10 prerequisites.
  Acceptance: Show implicit and explicit false child forms RED/GREEN with matched indexed/nonfalse/null cases. Retain static compiled-rule precedence, target-kind diagnostics and exact output-copy behavior; document the repaired values and relevant scope without changing the separate mutation-result contract.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.10.2`
  Status: `pending`
  Goal: Independently verify child-push false preservation through supported Lua carriers and cached action edges.
  Dependencies: .2.10.1 committed cleanly.
  Acceptance: Exercise native/reconstructed/generated/emitted routes, implicit/explicit whole and indexed forms, false/null/aggregate values, repeated same-edge requests and unrelated direct calls. Assert once-only child effects, cached retv, detached accumulators and accurate public guidance on supported PUC and LuaJIT; retain all startup/identity prerequisites.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.11`
  Status: `pending`
  Goal: Preserve exactly represented PUC Lua integers when JSON encoding selects a decimal representation.
  Evidence: Reading .1.11 confirms PUC5.5.1 decodes 9007199254740993 and signed near-limit integer examples exactly, but json.encode changes them through string.format("%.0f",value). Integer-format controls preserve the original decimal while the floating projection equals the erroneous encoded result. LuaJIT already rounds these inputs at decode; its encode/decode retains that represented number, so this is not a new LuaJIT encoder-loss claim.
  Children: `.2.11.1`, `.2.11.2`
  Dependencies: Startup .3/.4/.5 and .2.2 for declared supported PUC proof.
  Reading .1.14 extension: On PUC5.5.1, runtime.clone_data(9007199254740993) and tool_success_response over a schema-admitted synthetic record.order produce 9007199254740992; text and structured payload agree on the changed number, while caller data remains intact. clone_data roundtrips through json.encode/decode (mcp_contract_runtime.lua 17–23; response use 341–342). LuaJIT already represents the rounded input and its clone preserves it. This is a measured data-copy carrier of the existing encoder defect, not a claim that a native semantic query produced that record order or that request ID bounds changed.
  Acceptance: Preserve the host's already exact integer values without promising arbitrary-precision parsing or inventing recoverable LuaJIT bits. Retain finite floating-point behavior, negative-zero policy, deterministic JSON, Lua5.1-compatible source and exact typed container/Unicode/error semantics.
  Verification: `pending`; exact native and pure-JSON projection recipes are in docs/knowledge/lua-json-matching-reading-and-integer-encoding-gap.md.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.11.1`
  Status: `pending`
  Goal: Encode a represented integer without first rounding it through floating formatting.
  Scope: Number formatting in lua/src/linkedspec/json.lua and focused codec/value-carrier regression with accurate public limits.
  Dependencies: Parent .2.11 prerequisites.
  Acceptance: Show positive/negative values beyond2^53 and supported integer limits RED/GREEN; retain small integers, representable integral floats, fractional/exponent values, nonfinite rejection and zero normalization. Keep the LuaJIT fallback loadable and behaviorally unchanged for its represented values.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.11.2`
  Status: `pending`
  Goal: Independently verify integer JSON roundtrip preservation through affected public and stored carriers.
  Dependencies: .2.11.1 committed cleanly.
  Acceptance: Compare exact decimal strings and integer identity independently on supported PUC; qualify LuaJIT representation limits. Exercise nested arrays/harrays and applicable AST/result/generated or MCP projections using a documented domain census; preserve canonical ordering and never claim arbitrary precision. Reconcile book/Knowledge limits and close only after required proof passes.
  Additional carrier evidence: Include .1.14’s direct clone and schema-admitted synthetic semantic response in the domain census; retain independent source-value versus encoded/structured comparisons and the unchanged ±9007199254740991 request-ID domain. Do not replace source identity with two equally rounded projections.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.12`
  Status: `pending`
  Goal: Reject non-finite values at private recognition coordinate and progress validation boundaries.
  Evidence: Reading .1.15 observes positive/negative infinity accepted for frame cursor, boundary and initial mark offsets on both installed hosts; all six resulting snapshots fail JSON encoding. write_mark accepts both infinities and validate_progress accepts an infinite end as forward progress. recognition_transaction.lua is_integer (63–65) checks value==math.floor(value), which is true for infinities. Thirty valid controls per host preserve finite zero/positive/negative integers and reject false/true/string/fraction/NaN frame values. These are private-module observations; no ordinary .spec path or parser nontermination is established.
  Children: `.2.12.1`, `.2.12.2`
  Dependencies: Startup .3/.4/.5 and existing .2.2 supported-PUC proof requirements.
  Acceptance: Preserve private transaction identity, finite coordinate semantics, detached snapshots, rollback/unwind, false payloads and neutral diagnostics while rejecting non-finite coordinate/progress inputs before state or progress acceptance. Do not silently replace an invalid infinite operand with an advancing default. Census applicable private callers and supported carriers before claiming public reachability or broad parity.
  Verification: `pending`; .1.15 records exact finite/non-finite controls and current admitted consumer results.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.12.1`
  Status: `pending`
  Goal: Repair finite-number validation for private frame coordinates, marks and progress operands.
  Dependencies: Parent .2.12 prerequisites and current private-call domain census.
  Acceptance: Reject both infinities in frame_state cursor/boundary/marks, write_mark and each progress operand before mutation or acceptance. Retain omitted boundary behavior, finite negative/zero/positive integer storage already accepted by the private model, and established invalid-type errors. Preserve finite one-shot zero-width and required forward-progress behavior. Audit adapter-produced values and decompose any newly required contract or public behavior change before expanding this repair.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.12.2`
  Status: `pending`
  Goal: Independently verify private finite validation, serializable snapshots and unchanged recognition execution.
  Dependencies: .2.12.1 committed cleanly.
  Acceptance: Cover both signs of infinity and NaN versus valid coordinates, all constructor/setter fields, both progress operands, caller/state atomicity and actual snapshot encoding on supported PUC and LuaJIT. Preserve token lifecycle, rollback/unwind, marks, false payloads and native/reconstructed/generated/emitted consumer behavior. Record a source-to-public domain census; update book/Knowledge and close only after required proof without unmeasured parser-loop or reachability claims.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.13`
  Status: `pending`
  Goal: Prevent silent PUC integer overflow in scalar numeric helpers, reducers and typed input slicing.
  Evidence: Reading .1.16 observes native and SpecFile-reconstructed num_add(max-int,1) and num_sum([max-int,1]) return min-int; num_abs(min-int) remains negative; num_mul(2^62,4) returns zero; num_sub(min-int,1) returns max-int. Installed LuaJIT retains floating magnitudes/signs for those inputs instead of the PUC wraparound. Direct 1e20, adding zero to 1e20, small addition and invalid division controls behave as expected. Existing JSON integer repair .2.11 separately owns max-int decimal serialization.
  Children: `.2.13.1`, `.2.13.2` own scalar/reducer policy; `.2.13.3`, `.2.13.4` own bounded typed-source clipping.
  Dependencies: Startup .3/.4/.5 and .2.2 declared-PUC proof; preserve ADR0029 and existing startup .20/.55, Dart .2.12 and Julia .2.9 numeric owners.
  Reading .1.20 extension: On xabc, native/reconstructed input_slice(start,9223372036854775807) returns null for start1/3/4 on installed PUC, while LuaJIT and fresh Perl Get return abc/c/empty. source_location_runtime.lua 316 adds start+width before clipping, so PUC wraps to a negative endpoint and the compatibility adapter returns nil. Start0, small width and finite floating controls distinguish this from JSON .2.11. Shared startup .60.2 separately retains Perl floating-count fallback differences; coordinate Dart .2.14 and Julia .2.9 without merging their distinct causes.
  Acceptance: Root-cause each observed native arithmetic operation, independently compare the reference engine, preserve finite sign/magnitude within the agreed numeric contract and reject invalid/non-finite operations. Census subtraction, multiplication, absolute value, reducers, modulo and rounding before closing; fixture parity does not prove all magnitude boundaries. No arbitrary-precision policy or text-spelling change is inferred.
  Verification: `pending`; .1.16 records initial native/reconstructed observations and focused neutral proof.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.13.1`
  Status: `pending`
  Goal: Repair host integer overflow through one coherent scalar/reducer numeric policy.
  Dependencies: Parent .2.13 prerequisites and independent reference/domain evidence.
  Acceptance: Preserve valid results and typed invalid-to-null behavior across scalar and reducer callers, prevent wrapping into the wrong sign or zero, and handle intermediate overflow before finite-result normalization. Preserve LuaJIT representation limits separately from PUC integer operations; do not silently discard representable finite magnitude or widen numeric-string syntax.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.13.2`
  Status: `pending`
  Goal: Independently verify numeric magnitude boundaries and supported carriers.
  Dependencies: .2.13.1 committed cleanly.
  Acceptance: Compare independently derived boundary expectations and reference Get output with both supported Lua hosts, native/reconstructed/generated/emitted routes, scalar aliases/receivers and reducers. Cover positive/negative overflow, ordinary controls, invalid/non-finite results and source-value versus JSON-output distinctions; update book/Knowledge and close only after required proof.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.14`
  Status: `pending`
  Goal: Preserve typed JSON null through semantic compilation diagnostic copies.
  Evidence: Reading .1.16 isolates a recognized synthetic validation diagnostic with scalar and nested null/false fields. The outcome copier turns null into an empty harray; independently injecting the original typed fields into an otherwise valid failed outcome shows the semantic index copier repeats the loss in fields and to_json. Caller fields and false controls remain intact. The generic copy helpers in semantic_compilation_outcome.lua and semantic_index.lua branch on table kind without preserving json.null first. This is a synthetic diagnostic carrier observation, not evidence that an ordinary spec emits these fields.
  Children: `.2.14.1`, `.2.14.2`
  Dependencies: Startup .3/.4/.5 and .2.2 supported-PUC proof; retain .2.11 integer serialization as a separate mechanism.
  Acceptance: Preserve typed null, boolean values and array/harray identity recursively through both diagnostic copy boundaries, maintain detachment and existing cycle/nonportable rejection, and census actual diagnostic producers before stronger public-reachability claims. Keep unknown-error identity and compiled/failed outcome selection unchanged.
  Verification: `pending`; .1.16 owns isolated reproduction, valid controls and both-host proof.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.14.1`
  Status: `pending`
  Goal: Repair both semantic diagnostic copy helpers without changing portable data meaning.
  Dependencies: Parent .2.14 prerequisites and typed-field domain census.
  Acceptance: Handle json.null before generic table copying, preserve recursive array/harray/null/false structure and caller isolation, and retain deterministic fields and recognized-versus-unrecognized error behavior. Split any newly required public schema or nonportable-domain change before broadening scope.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.14.2`
  Status: `pending`
  Goal: Independently verify semantic diagnostic field identity and public projections.
  Dependencies: .2.14.1 committed cleanly.
  Acceptance: Isolate the outcome and index copying seams on both supported hosts; verify scalar/nested null and false, empty arrays versus harrays, detached fields/to_json and unchanged typed failures. Census native producers, recompose applicable semantic/MCP carriers and update book/Knowledge before closing, with synthetic and ordinary-source evidence kept distinct.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.15`
  Status: `pending`
  Goal: Preserve a rejected raw semantic query's false evidence exactly.
  Evidence: Reading .1.17 public query_neutral returns requested=null for contract=false and page.after_id=null for after_id=false on both installed hosts. Neutral responses retain false; changing only that one expected field to null makes each complete Lua response equal the neutral one. True, zero, typed null and nested [false,null] controls retain their values. semantic_query.lua neutral_evidence uses ok and copied or json.null, losing a successfully copied scalar false. Rejection and zero-cost envelopes remain correct.
  Children: `.2.15.1`, `.2.15.2`
  Dependencies: Startup .3/.4/.5 and .2.2 supported-PUC proof; keep .2.14 diagnostic null-to-object copying and startup .82 budgets separately owned.
  Acceptance: Preserve valid copied false evidence independently of copy success, retain sanitization of nonportable or cyclic values, and keep invalid requests rejected with exact deterministic diagnostics and zero costs. Verify complete response equality, recursive detachment and all callers before closing.
  Verification: `pending`; .1.17 matches all fourteen two-host responses, twelve complete neutral agreements and two isolated false-to-null differences.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.15.1`
  Status: `pending`
  Goal: Correct the query evidence success/value distinction.
  Dependencies: Parent .2.15 prerequisites and caller census.
  Acceptance: Preserve false for rejected contract and cursor evidence using explicit copy-success branching; retain true, zero, null and nested controls, safe fallback on invalid host/cyclic evidence and existing request-validation ordering. No query operation or budget policy change belongs here.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.15.2`
  Status: `pending`
  Goal: Independently verify rejected-request evidence and applicable transport projections.
  Dependencies: .2.15.1 committed cleanly.
  Acceptance: Compare full corrected responses to independent neutral expectations on supported PUC and LuaJIT; cover both callers, false versus null, nested values, mutation isolation and sanitized unsupported inputs. Recompose selected query/MCP consumers, update book/Knowledge and close only after required proof.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.16`
  Status: `pending`
  Goal: Correlate mixed structural regex slots against their actual compiled owners.
  Evidence: Reading .1.18 compiles and executes parent-first and slot-first Top members to a on both installed hosts. Parent-first compiled patterns [a,b] nevertheless fail public semantic construction with semantic_static_correlation_failed, identity Top, slot0; slot-first [b,a] succeeds with exact /b/ source. project_regex_slots filters authored parent matchers and then compares the retained list to the unfiltered compiled prefix.
  Children: `.2.16.1`, `.2.16.2`
  Dependencies: Startup .3/.4/.5 and .2.2 supported-PUC proof; coordinate Julia .2.16 without merging backend implementation ownership.
  Acceptance: Preserve typed slot identity and authored occurrence, independent of interleaved parent matchers; retain duplicate and self-indexed slots, exact source references, runtime observations and selector diagnostics.
  Verification: `pending` repair; .1.18 records both exact two-host counterexamples and controls.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.16.1`
  Status: `pending`
  Goal: Repair the filtered-authored versus unfiltered-compiled regex-slot join.
  Dependencies: Parent .2.16 prerequisites and explicit typed ownership/index census.
  Acceptance: Establish independent RED/GREEN expectations for parent-first, slot-first, interleaved, duplicate and self-indexed members; correlate retained slots to actual accepted owners without weakening mismatch diagnostics or changing compiled parser behavior.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.16.2`
  Status: `pending`
  Goal: Independently verify mixed-slot semantic construction and dependent carriers.
  Dependencies: .2.16.1 committed cleanly.
  Acceptance: Compare complete typed/raw query records, relations, slot identities and UTF-8 source spans on supported PUC and LuaJIT; cover native/reconstructed/generated observations and applicable MCP routes, preserve compiler/runtime evidence, update book/Knowledge and close only on required proof.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.17`
  Status: `pending`
  Goal: Prevent regex matcher text from becoming an action call or binding's semantic source.
  Evidence: Reading .1.18 runs plain, grouped, noncapturing and whitespace-prefixed trim(x) matchers with an action assigning trim(" x "). All four execute x and query successfully on both hosts. The latter three call/binding records cite trim(x) inside the matcher, while typed RHS and independent authored byte ranges identify trim(" x "). regex_start rejects slash followed by an opening parenthesis or whitespace; scan_call_sites then indexes matcher calls and take_call_site consumes the wrong matching name.
  Children: `.2.17.1`, `.2.17.2`
  Dependencies: Startup .3/.4/.5 and .2.2 supported-PUC proof; keep shared grouped edges .70 and Julia .2.15 distinct.
  Acceptance: Correlate typed calls and RHS bindings to their exact authored action occurrences, preserving nested call order, valid regex syntax, comments, strings and Unicode source ceilings without executing target code during construction.
  Verification: `pending` repair; .1.18 independently verifies all four complete two-host query responses and typed/RHS byte evidence.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.17.1`
  Status: `pending`
  Goal: Repair lexical boundaries used by semantic action-call source matching.
  Dependencies: Parent .2.17 prerequisites and typed/source occurrence census.
  Acceptance: Freeze exact failing and control source spans independently; handle grouped, noncapturing and whitespace-prefixed regexes plus nested calls, quoted/comment decoys and repeated helper names. Preserve source ownership rather than skipping an arbitrary first call or weakening correlation failures.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.17.2`
  Status: `pending`
  Goal: Independently verify corrected call and binding source ranges across public carriers.
  Dependencies: .2.17.1 committed cleanly.
  Acceptance: Compare exact excerpts and byte/scalar spans to typed and authored evidence on supported PUC and LuaJIT; retain complete response topology, no-execution and privacy controls, recompose applicable reconstructed/generated/MCP proof, and update book/Knowledge before closing.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.18`
  Status: `pending`
  Goal: Restore explicit child-slot match ownership when an action edge follows a same-line parent regex.
  Evidence: Reading .1.18 reference Get returns null for /-> Child/ -> Child[1] on input -> Child, while Lua returns that parent text. The reference descriptor retains authored parent regex but dependency matcher b for Child[1]; generated handler uses that dependency map. Lua compiled_spec.lua records has_parent_regex and bypasses child-pattern resolution, while matching.lua compiles the retained parent pattern. This conflicts with the locked spec-edge-syntax-contract; descriptor identity alone does not establish runtime parity.
  Children: `.2.18.1`, `.2.18.2`
  Dependencies: Startup .3/.4/.5 and .2.2 supported-PUC proof; coordinate .2.16 semantic slots and shared .70 selectors without merging their distinct causes.
  Acceptance: Preserve the written target/index as match authority for explicit action edges, with positive direct/self-target controls and exact native/generated observation identities. Keep the reference contract and root-cause every affected carrier before claiming parity.
  Verification: `pending` repair; bounded paired input and native/reconstructed/reference controls belong to .1.18 evidence.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.18.1`
  Status: `pending`
  Goal: Repair same-line action matcher selection from explicit target-slot authority.
  Dependencies: Parent .2.18 prerequisites and compiler/runtime/descriptor ownership census.
  Acceptance: Freeze independent reference RED/GREEN cases with differing parent and child patterns, multiple explicit targets/indices, target-only and self-target controls. Reconcile effective runtime patterns and ordered slot identities without deleting authored regex evidence or silently changing grouped/bare/blind contracts; split any additional backend repair before editing.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.18.2`
  Status: `pending`
  Goal: Independently verify action match ownership across supported Lua carriers.
  Dependencies: .2.18.1 committed cleanly.
  Acceptance: Compare actual values, selected slot identity, cursor/gap behavior and diagnostics to fresh reference execution on supported PUC and LuaJIT. Recompose native/reconstructed/generated/emitted/primary and semantic-observation carriers, census other backends, keep source projection repairs separate, and update book/Knowledge before closing.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.19`
  Status: `pending`
  Goal: Make Lua entry-explanation coverage independent of unrelated function and rule counts.
  Evidence: Reading .1.19 on both installed hosts retains selected entry Top and normal execution for single-rule, two-rule and two-rule-plus-unused-function sources. Only the function-free two-rule query returns an entry decision and two explanation steps; the others return semantic_query_invalid/not_explainable. semantic_static_projection.lua conditionally calls add_entry_explanation only when parsed.functions is empty and compiled rule count exceeds one.
  Children: `.2.19.1` coordinated expectations/impact; `.2.19.2` implementation; `.2.19.3` independent proof.
  Dependencies: Startup .3/.4/.5 and .2.2 supported-PUC proof; coordinate Julia .2.17.1 and shared startup .22 without merging their separate omissions.
  Acceptance: Explicitly resolve entry-evidence coverage and frozen-model/hash implications, then retain truthful selection basis, selected rule and deterministic explanation records across the agreed supported cases. No current limitation is silently ratified or fixture silently refreshed.
  Verification: `pending` repair; .1.19 retains three exact entry controls within nine complete two-host observations.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.19.1`
  Status: `pending`
  Goal: Bound entry-explanation expectations and shared frozen-model impact before source repair.
  Dependencies: Parent .2.19 prerequisites; retrieve Julia .2.17.1's coverage decision and current neutral authorities.
  Acceptance: Enumerate single/multiple rules, unused/used functions, explicit selector, first marker and first authored rule; independently define expected decision/source/step topology and affected models, hashes, queries and carriers. Preserve existing evidence and coordinate one coherent contract disposition before implementation.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.19.2`
  Status: `pending`
  Goal: Implement the agreed Lua entry-explanation coverage without incidental registry gates.
  Dependencies: .2.19.1 committed cleanly and any shared expectation prerequisite completed.
  Acceptance: Produce the agreed deterministic evidence from retained entry/source authority; preserve compile-failure behavior, source ceilings and canonical ordering. Keep helper-only call projection under startup .22 separate and split any broader contract migration before editing.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.19.3`
  Status: `pending`
  Goal: Independently verify entry explanation and supported semantic carriers.
  Dependencies: .2.19.2 committed cleanly.
  Acceptance: Compare full list/explain responses and typed/raw parity across agreed entry cases on supported PUC and LuaJIT; verify privacy/no-execution and applicable MCP/reconstructed/generated carriers, update book/Knowledge and satisfy required canonical closeout before closing.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.9`
  Status: `pending`
  Goal: Reject explicitly false generated execution and execution-failure option tables.
  Dependencies: Startup .3/.4/.5; parent .2.8 and supported-PUC .2.2 prerequisites.
  Acceptance: Use absent-only normalization at source_emitter.lua 250/494; preserve established typed errors, nil/empty defaults, valid option fields, direct/traced/emitted parser values and callback-error identity. Census generated aliases before closure; decompose additional surfaces before expansion.
  Verification: .1.20 records thirty complete option observations per installed host; source remains unchanged.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.10`
  Status: `pending`
  Goal: Independently verify generated option validation across supported execution routes.
  Dependencies: .2.8.9 committed cleanly.
  Acceptance: Exercise omitted/empty/false/other-invalid and valid options on declared PUC and LuaJIT through direct/traced APIs, freshly emitted modules and failure construction. Retain callbacks, source identity, plan validation and distinct contract-field repair .2.20; synchronize book/Knowledge before closing.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.13.3`
  Status: `pending`
  Goal: Clip typed input-slice widths before potentially overflowing endpoint arithmetic.
  Dependencies: Startup .3/.4/.5; parent .2.13, supported-PUC .2.2 and shared count policy .60.2.
  Acceptance: Bound nonnegative width to remaining source length before addition, preserving Unicode scalar positions, empty/end spans and established invalid-input handling. Independently verify max-integer behavior; do not copy Perl floating substr fallback or widen numeric-string acceptance. Coordinate Dart .2.14 and Julia count handling.
  Verification: .1.20 retains twelve native/reconstructed rows per host and six fresh Perl facade/lowering/source controls.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.13.4`
  Status: `pending`
  Goal: Independently verify typed input-slice boundaries and carriers.
  Dependencies: .2.13.3 committed cleanly.
  Acceptance: Cover zero/interior/end/outside starts, zero/small/max-integer and agreed floating widths, Unicode input and invalid values on declared PUC/LuaJIT through native/reconstructed/generated/emitted routes. Compare independent scalar expectations and reference behavior, preserving separately owned count-policy discrepancies and book/Knowledge limits.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.20`
  Status: `pending`
  Goal: Validate explicitly supplied generated-source contract values before applying omission defaults.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2.
  Acceptance: Repair and independently verify only the plan-validator optional contract boundary under .2.20.1/.2.20.2; preserve strict emitted literal validation, generated format and valid absent/current contract behavior.
  Verification: .1.20: validate_generated_rule_plan_v2 accepts false as current because source_emitter.lua 409 uses actual_contract or current; true/zero reject type, invalid string rejects mismatch. Six complete observations per host; no stale emitted literal acceptance is claimed.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.20.1`
  Status: `pending`
  Goal: Use absence-only handling for the generated plan contract parameter.
  Dependencies: Parent .2.20 prerequisites.
  Acceptance: Preserve validate_generated_source_contract_v2 string and mismatch diagnostics, validate explicit false as an invalid value, and keep omitted/current values successful. Census callers without changing emitted v2 contract/version or unrelated options.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.20.2`
  Status: `pending`
  Goal: Independently verify generated contract value validation and emitted compatibility.
  Dependencies: .2.20.1 committed cleanly.
  Acceptance: Check absent/current/false/true/number/invalid-string parameters, valid plans and malformed plans on supported hosts. Execute newly emitted valid modules and preserve direct strict literal rejection; update book/Knowledge and run relevant generated consumers.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.21`
  Status: `pending`
  Goal: Keep rejected non-finite source coordinates out of typed diagnostic records.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; coordinate private recognition repair .2.12.
  Acceptance: Bound private position integer validation and verify it under .2.21.1/.2.21.2; preserve valid positions, finite range errors and compatibility nil behavior. No public Position/Span API or new diagnostic schema is admitted.
  Verification: .1.20: scalar/byte constructors reject both infinities but floor-based integer acceptance lets them reach position_offset in SourceLocationException; to_json succeeds but json.encode fails. Eight complete observations per host retain finite end/outside controls; no infinite Position, ordinary-spec or MCP reachability is demonstrated.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.21.1`
  Status: `pending`
  Goal: Reject non-finite typed-source coordinate inputs before constructing coordinate-bearing errors.
  Dependencies: Parent .2.21 prerequisites.
  Acceptance: Census scalar/byte positions, spans and related integer predicates; use finite integer validation without changing in-range Unicode semantics or finite out-of-range typed errors. Keep invalid compatibility calls returning nil; decompose any additional affected context fields before repair.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.21.2`
  Status: `pending`
  Goal: Independently verify typed-source coordinate rejection and serializable diagnostics.
  Dependencies: .2.21.1 committed cleanly.
  Acceptance: Exercise finite boundaries, both infinities, NaN, non-integer and wrong-type inputs through scalar/byte/private adapter routes on declared PUC and LuaJIT. Validate exact finite typed errors and JSON conversion; establish reachability before broader claims, retain core/projection consumers and synchronize book/Knowledge.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.22`
  Status: `pending`
  Goal: Reject explicitly false source-AST fields before applying constructor defaults.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2.
  Acceptance: Bound six observed field surfaces under .2.22.1/.2.22.2; align native validation with established reconstruction types without changing valid defaults, selector semantics, source identity, generated formats or named-argument plans.
  Verification: .1.21: EdgeTarget/BareEdgeTarget selector_kind, action/blind/bare fluent_chain and SpecFile.functions accept false as their default in native constructors; equivalent JSON reconstruction rejects it. Seventy-two complete observations per host retain absent/valid and other type controls. Exact replay: docs/knowledge/lua-spec-ast-loader-reading-and-validation-gaps.md.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.22.1`
  Status: `pending`
  Goal: Use nil-only defaulting for source-AST selector and optional list fields.
  Dependencies: Parent .2.22 prerequisites.
  Acceptance: Correct both selector_kind defaults and three fluent-chain plus functions defaults. Preserve the distinction between optional fields and supplied false; retain dense list copying, existing type messages, valid absent/current values and reconstruction behavior. Census adjacent constructor defaults before closure.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.22.2`
  Status: `pending`
  Goal: Independently verify native/reconstructed AST field validation.
  Dependencies: .2.22.1 committed cleanly.
  Acceptance: Cover omission, false, other wrong types and valid values on declared PUC/LuaJIT for all six fields; compare exact typed projections and diagnostics. Preserve parsed/reconstructed/loaded/generated behavior through existing consumers and update book/Knowledge before closing.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.23`
  Status: `pending`
  Goal: Validate complete typed JSON shapes and finite payloads before AST copying or reconstruction.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; preserve .2.11 integer encoding and .2.21 coordinate-error scope.
  Acceptance: Own dense-array repair .2.23.1, finite-payload repair .2.23.2 and independent proof .2.23.3. Inputs are deliberately altered host typed tables or non-finite host numbers; no valid serialized JSON, ordinary-spec data loss or runtime execution consequence is demonstrated.
  Verification: .1.21: clone_json copies only the length-selected array prefix and returns numbers unchecked; both function payload fields lose extra/hole members or retain infinity until encoding fails. from_json list helpers use ipairs and discard malformed rules-array tails while native construction rejects them. Exact two-host observations retain false/nested null and cyclic rejection controls.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.23.1`
  Status: `pending`
  Goal: Reject malformed typed-array membership before payload copying and JSON list decoding.
  Dependencies: Parent .2.23 prerequisites.
  Acceptance: Validate dense one-based integer keys before clone_json array traversal and both JSON string/object list decoders. Reject holes/extra keys without dropping evidence or mutating callers; preserve valid arrays, order, JSON identity, shared acyclic values and existing cycle rejection.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.23.2`
  Status: `pending`
  Goal: Reject non-finite numeric AST payload values before retaining or projecting them.
  Dependencies: Parent .2.23 prerequisites.
  Acceptance: Bound finite validation in clone_json for FunctionDefinition.body_payload/body_ast and nested typed JSON values, including direct and from_json callers. Preserve representable finite values and scalar false; keep numeric encoding .2.11 and source-coordinate .2.21 repairs distinct. Census adjacent scalar metadata separately before widening scope.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.23.3`
  Status: `pending`
  Goal: Independently verify complete AST payload/list validation and supported carriers.
  Dependencies: .2.23.1/.2.23.2 committed cleanly.
  Acceptance: Exercise native/from_json/serialization boundaries for both payload fields and string/object list consumers with valid dense, sparse, extra-key, cyclic, shared, finite and non-finite inputs on supported hosts. Retain existing optional outer-null normalization and nested null/false values; establish any broader reachability before claims. Preserve descriptor/root/load/generated consumers and synchronize book/Knowledge.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.11`
  Status: `pending`
  Goal: Reject explicitly false parser and loaded-engine option tables.
  Dependencies: Startup .3/.4/.5 and parent .2.8/.2.2 prerequisites.
  Acceptance: Use absent-only option normalization in parse_spec and both loaded engine wrappers; preserve source_id validation, trace identity, loaded-derived spec_name/spec_path and caller option copies. Retain valid omitted/empty and field values, typed parse/loader errors and successful parser behavior.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.12`
  Status: `pending`
  Goal: Independently verify parser and loaded-engine defaulting boundaries.
  Dependencies: .2.8.11 committed cleanly.
  Acceptance: Exercise nil/empty/false/other invalid and valid options on supported PUC/LuaJIT through root facade and loaded method/function routes, with named/path requests and unchanged derived identity. Preserve direct parser/root/loaded/trace consumers and synchronize book/Knowledge.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.24`
  Status: `pending`
  Goal: Preserve complete source delimiters and lexical state through outer parsing and validation.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; shared startup .52/.54, Dart .2.7/.2.2 and Julia .2.20/.2.21 remain distinct owners.
  Acceptance: Decompose EOF blocks .2.24.1, incomplete fluents .2.24.2, outer regex .2.24.3, downstream regex validation .2.24.4, multiline quoted text .2.24.5 and independent carrier proof .2.24.6. Preserve valid compact quotes/spaces, explicit/shorthand EOF rejection, root semantics and typed regex operand policy.
  Verification: .1.22: 26 complete parser/compiler/runtime observations per host isolate three accepted unfinished edge blocks, five argument-erasing unfinished fluent routes, two outer regex truncations, one separate compact regex balance rejection and two multiline quote failures. Source and positive controls live in docs/knowledge/lua-spec-parser-validator-reading-and-lexical-gaps.md.
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.24.1`
  Status: `pending`
  Goal: Reject unclosed outer edge blocks before normalized code loses the opening delimiter.
  Dependencies: Parent .2.24 prerequisites.
  Acceptance: At EOF retain or diagnose incomplete consume_block state for action, blind and bare edges; do not return an apparently complete block with erased delimiter evidence. Preserve closed forms and current explicit/shorthand lifecycle unmatched-open errors; cover same-line/multiline and attached handlers with exact source location.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.24.2`
  Status: `pending`
  Goal: Reject incomplete fluent arguments without replacing them with an empty call.
  Dependencies: Parent .2.24 prerequisites.
  Acceptance: Remove parse_fluent_chain failed-extraction success with empty args/remainder; retain invalid source or issue the established typed error before compile/execution. Cover action/blind/bare/body fluents and lifecycle fallback plus continuation lines; preserve balanced quoted/regex parentheses and whitespace handling.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.24.3`
  Status: `pending`
  Goal: Track regex literals while collecting outer source blocks.
  Dependencies: Parent .2.24 prerequisites; coordinate shared startup .54.3.
  Acceptance: Keep braces inside regex literals from closing or nesting a containing handler, preserving escaping, supported flags, authored source and remainders. Cover plain/grouped regexes and all owning block routes without bypassing downstream validation or native regex checks.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.24.4`
  Status: `pending`
  Goal: Make lifecycle balance validation use correct regex lexical boundaries.
  Dependencies: Parent .2.24 prerequisites; .2.24.3 remains a separate prerequisite for braced-source parity.
  Acceptance: Correct quote-only brace_depth_delta so a complete compact regex expression does not report unmatched braces; retain genuine missing/extra outer delimiter rejection and all established lifecycle source choices. Cover quiet/traced compilation and coordinate the shared regex recurrence owner.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.24.5`
  Status: `pending`
  Goal: Carry quoted-string state across physical lines during block collection.
  Dependencies: Parent .2.24 prerequisites.
  Acceptance: Preserve multiline string quotes/escapes and exact newline content instead of resetting scan_quoted state per line. Keep a brace inside the following quoted line as data, recognize the real closing block, and preserve remainder/source line attribution. Retain compact multiline controls and ensure no extra closing brace reaches raw_perl ActionIR.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.24.6`
  Status: `pending`
  Goal: Independently verify outer lexical integrity and supported routes.
  Dependencies: .2.24.1-.2.24.5 committed cleanly.
  Acceptance: Use independent source/AST/diagnostic/value expectations for positive and malformed twins across native/reconstructed/loaded/generated/emitted paths on supported hosts. Verify full source retention and exact line spans, no execution for rejected forms, and genuine EOF errors; preserve the non-regex matches=false control. Update book/Knowledge and shared .54.3 before closing.
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

- ID: `LUA-STARTUP-READING.2.8.13`
  Status: `pending`
  Goal: Validate explicitly supplied validator options before applying absent defaults.
  Dependencies: Parent .2.8 startup and supported-PUC prerequisites.
  Acceptance: Change the validate_spec option default to absent-only; reject false with the existing typed table error and preserve strict_syntax/trace validation, successful nil/table behavior and no caller mutation.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.14`
  Status: `pending`
  Goal: Independently verify validator option admission and dependent compilation.
  Dependencies: .2.8.13 committed cleanly.
  Acceptance: Exercise absent/table/false/true/zero/text inputs through the public validator on supported hosts, retain strict and trace cases, and verify affected parser/compiled/load/generated consumers without changing their unrelated option boundaries. Synchronize book and Knowledge.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.25`
  Status: `pending`
  Goal: Reject malformed staged typed arrays before copying, detaching or computing logical identities.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; coordinate AST copy repair .2.23 without merging its finite-number defect.
  Evidence: .1.23 executes private job_identity and enrich_current_depth with host-created json.array({"nodes"}) plus an extra false member or sparse index3=false. Both hosts silently retain only the dense prefix; job digests equal the clean prefix and parent ASTs lose the added members without callbacks. Caller inputs retain their members. Plain malformed arrays, non-finite/cycle controls and cache capability extra keys correctly reject. staged_ast_enrichment.lua94 returns tagged array kind before dense_array; copy_plain133 and detach_plain1214 traverse only the selected length. No valid JSON, ordinary authored-spec or production carrier defect is demonstrated.
  Reading .1.24 extension: execution_seed at line2072 copies its snapshot before freeze_registry validation. Extra false aliases members reject in direct freezing but are omitted and accepted by seed construction on both hosts. A sparse tail is omitted/accepted on PUC and rejected on LuaJIT because their length-selected copy horizons differ. Keep shared dense classification as the repair owner; neither factory executes in this probe.
  Children: `.2.25.1`, `.2.25.2`.
  Acceptance: Preserve complete dense array membership or reject before normalization; do not silently discard supplied host data. Keep valid values, ordering, finite/cycle checks, host callback isolation and neutral identities unchanged. Exact replay: docs/knowledge/lua-validator-staged-prefix-reading-and-array-gaps.md.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.25.1`
  Status: `pending`
  Goal: Validate full tagged-array membership in staged plain-data classification.
  Dependencies: Parent .2.25 prerequisites.
  Acceptance: Require dense one-based integer keys for tagged arrays before copy_plain and detach_plain traverse them; preserve valid empty/dense arrays, harray identity, scalar false/null, finite values, shared acyclic data and cycle rejection. Census affected logical identity, snapshot and detachment consumers with bounded evidence before broadening implementation.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.25.2`
  Status: `pending`
  Goal: Independently verify staged shape admission and supported carriers.
  Dependencies: .2.25.1 committed cleanly.
  Acceptance: Verify extra string/non-integer keys, holes, nested values, valid empties and complete dense arrays on supported hosts. Exercise job identity, parent and child detachment plus affected snapshot/marker boundaries; measure caller preservation and callback counts. Retain exact neutral digest/cache cases and source/native/reconstructed/generated/emitted consumers; do not infer authored reachability from synthetic host inputs. Update book/Knowledge only after the repair is verified.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.15`
  Status: `pending`
  Goal: Validate explicit staged initial-call counts before absent-value defaulting.
  Dependencies: Parent .2.8 startup and supported-PUC prerequisites.
  Acceptance: Default total_calls only when absent; reject false and all invalid supplied counts using the existing staged snapshot error. Preserve exact zero/positive seeds, guarded dispatch admission and counters across recursive depths.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.16`
  Status: `pending`
  Goal: Independently verify staged call-seed admission and exhaustion boundaries.
  Dependencies: .2.8.15 committed cleanly.
  Acceptance: Exercise absent/zero/positive/false/non-integer/type/range cases through private constructor and execution-seed carriers. Retain ordinary and maximum-exact-integer exhausted/non-exhausted callback counts; synchronize Knowledge and book after supported-host proof.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.26`
  Status: `pending`
  Goal: Make retained Lua staged diagnostics obey the shared byte-ceiling contract.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; coordinate shared accounting DART-STARTUP-READING.2.17.1 and Julia .2.14.
  Evidence: .1.24 independently measures seven private recursive cases: allowance 1 retains 187 bytes; allowance 64 retains 188 for one failure and 375 across two, including a second sentinel with maximum_bytes 0. Zero rejects; 256/4096 controls fit. bounded_diagnostic at lines1790-1806 measures but does not recheck its fallback, then clamps remaining bytes at zero. Existing staged consumers pass 890 per host. Ordinary and maximum-exact exhausted-call controls correctly reject; no Lua call-overflow defect or production-carrier recurrence is inferred.
  Children: `.2.26.1`, `.2.26.2`, `.2.26.3`.
  Acceptance: Enforce retained-byte limits under the shared accounting decision; preserve deterministic diagnostics, parent settlement and authority narrowing. Exact evidence: docs/knowledge/lua-staged-completion-reading-and-boundary-gaps.md.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.26.1`
  Status: `pending`
  Goal: Reconcile Lua diagnostic accounting with the shared truncation decision.
  Dependencies: Shared DART-STARTUP-READING.2.17.1 and startup prerequisites.
  Acceptance: Map the adopted unit and too-small/exhausted behavior to Lua sentinel fields, stage-chain growth, sidecar copies and diagnostic-node settlement. Preserve the measured failure as historical evidence; do not silently exempt fallback bytes or change other backends here.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.26.2`
  Status: `pending`
  Goal: Enforce the adopted retained diagnostic limit in Lua recursive settlement.
  Dependencies: .2.26.1 committed cleanly.
  Acceptance: Check the final retained representation and cumulative remainder before publication; handle tiny positive allowances and later exhausted siblings according to the shared contract. Preserve failure policies, source context and valid diagnostics without resetting authority.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.26.3`
  Status: `pending`
  Goal: Independently verify Lua diagnostic bytes across supported staged carriers.
  Dependencies: .2.26.2 committed cleanly and supported-PUC proof available.
  Acceptance: Measure compact UTF-8 bytes under all failure policies, nesting/stage chains and cumulative exhaustion; include cases where even the fallback cannot fit. Verify native/reconstructed/generated/emitted and recurring consumers, retain guarded maximum-call controls and update book/Knowledge after proof.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.27`
  Status: `pending`
  Goal: Preserve finite acyclic plain-data semantics in marker-specific detachment.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; preserve staged atomic-marker node accounting and .2.25 array membership repair.
  Evidence: .1.24 calls private detach_plain on tiny host tables under a 10000-instruction diagnostic guard. Ordinary cycles reject and ordinary null survives. Root/nested cycles inside marker-shaped values reach the guard; reject_live_keys at lines1187-1203 recurses without an active-set check before guarded copy_plain. A marker extension containing json.null rejects as non-plain because null is a tagged table, while false and valid markers pass. Large acyclic marker contents remain one atomic node, as the existing staged design specifies; no node-count defect is inferred.
  Children: `.2.27.1`, `.2.27.2`, `.2.27.3`.
  Acceptance: Reject cycles deterministically before recursive traversal grows and preserve legitimate null values. Keep live-value/key rejection, detached copies and atomic marker counting; establish reachability separately before claims about authored or production carriers.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.27.1`
  Status: `pending`
  Goal: Add cycle-aware marker traversal with deterministic detachment rejection.
  Dependencies: Parent .2.27 prerequisites.
  Acceptance: Track only the active recursion path in marker live-key validation; reject root and nested cycles without unbounded traversal, preserve shared acyclic values and existing source-attributed failure reasons. Retain controlled instruction bounds for negative diagnostic tests.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.27.2`
  Status: `pending`
  Goal: Preserve JSON null in marker-specific plain-data validation.
  Dependencies: .2.27.1 committed cleanly.
  Acceptance: Recognize the established json.null sentinel before treating tables as containers; preserve nested null/false and ordinary marker fields while retaining non-plain/live/function rejection and atomic counting.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.27.3`
  Status: `pending`
  Goal: Independently verify marker detachment and affected parent/child carriers.
  Dependencies: .2.27.1/.2.27.2 committed cleanly.
  Acceptance: Verify ordinary and marker cycles, shared values, nested null/false, non-finite/live values and array membership; measure bounded completion, callback counts and caller preservation. Exercise affected parent/child and reconstructed/generated/emitted paths without treating arbitrary host marker shapes as valid authored declarations. Update book/Knowledge after supported-host proof.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.28`
  Status: `pending`
  Goal: Establish and enforce complete private capture-range storage admission.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; preserve native PCRE capture pairing and typed-source final validation.
  Evidence: .1.24 private record accepts negative, reversed, fractional and non-finite numeric endpoints and drops extra/sparse range-list members through ipairs; byte_span accepts infinity as an absent index. Valid copied ranges remain detached from caller edits; text/false endpoint and ordinary invalid-index controls reject. Numeric-only predicates at staged_capture_provenance.lua lines16/33 omit finite/range checks. Native producer call sites supply PCRE ranges, and staged_parse_job translates retrieved endpoints through typed source authority; no ordinary parser or materialized-source consequence is demonstrated.
  Children: `.2.28.1`, `.2.28.2`, `.2.28.3`.
  Acceptance: Confirm producer/consumer invariants, reject malformed private storage without losing range members, and preserve valid compact capture order and repeated-equal capture identity. Exact evidence: docs/knowledge/lua-staged-completion-reading-and-boundary-gaps.md.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.28.1`
  Status: `pending`
  Goal: Census capture-range producers and define the private admission invariant.
  Dependencies: Parent .2.28 prerequisites.
  Acceptance: Trace record/copy/byte_span inputs from native and reconstructed matching, document required finite non-negative integral ordered endpoints and dense pairing, and distinguish source-length/UTF-8 authority checks that remain downstream. Establish any supported malformed-host route before expanding public claims.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.28.2`
  Status: `pending`
  Goal: Validate complete private range lists, endpoints and indexes before storage.
  Dependencies: .2.28.1 committed cleanly.
  Acceptance: Enforce the admitted invariant before copying; reject holes/extra members and invalid endpoint/index values without mutation. Preserve empty compact capture sets, copied ranges and downstream typed-source ownership instead of inventing source bounds in this module.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.28.3`
  Status: `pending`
  Goal: Independently verify capture provenance admission and materialization.
  Dependencies: .2.28.2 committed cleanly.
  Acceptance: Cover malformed list/type/finite/order/index boundaries, caller-copy isolation, repeated equal and absent captures, UTF-8 boundaries and staged provenance materialization through supported carriers. Verify no public capture-range fields appear and update book/Knowledge after proof.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.17`
  Status: `pending`
  Goal: Validate optional tables at the five narrow staged-registry entrypoints.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; reading .1.25.
  Acceptance: Use nil-only defaults before typed validation; preserve valid empty options, sorting, body ASTs, immutable stitching and traced behavior.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.18`
  Status: `pending`
  Goal: Verify registry option admission through each exposed alias.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; reading .1.25. .2.8.17 implementation.
  Acceptance: Extend focused controls for omitted/empty/false/true/zero/text options, typed errors and actual successful body dispatch; preserve direct-dependent carriers and update public guidance.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.19`
  Status: `pending`
  Goal: Validate original trace options and level/sink field types before defaults.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; reading .1.25.
  Acceptance: Reject explicitly false table/level/sink values using existing errors. Keep absent defaults, supported numeric thresholds, typed controls and valid false reset_file/emoji fields. Validate before preparing files; preserve explicitly requested quiet reset.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.8.20`
  Status: `pending`
  Goal: Verify trace admission and caller-owned sink compatibility.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; reading .1.25. .2.8.19 implementation.
  Acceptance: Cover config/emitter constructors, enabled/with aliases and direct parser/environment controls. Verify rejected options cause no file preparation, valid quiet reset remains intentional, and valid emitters retain result identity and ordered events.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.29`
  Status: `pending`
  Goal: Validate original staged provenance fields and complete derived segment membership.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; reading .1.25. Coordinate Dart .2.19 and Lua .2.25 density conventions without merging separate copy owners.
  Evidence: The private validator accepts eight malformed type cases rejected by the neutral materialize_provenance evaluator, with eleven agreeing controls. typed_direct_span at65-79 substitutes diagnostic placeholder strings before checking original types. Caller-owned source <runtime> can therefore be selected by malformed source_id. Four tagged/plain extra/sparse segment arrays lose supplied false members through ipairs at141 before typed derived construction. These are local host-record observations, not authored production-carrier or external source access proof.
  Children: `.2.29.1`, `.2.29.2`, `.2.29.3`.
  Acceptance: Reject malformed original field types and malformed host segment arrays before materialization; preserve typed errors and explicitly supplied literal placeholder strings. Exact replay: docs/knowledge/lua-declaration-trace-reading-and-validation-gaps.md.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.29.1`
  Status: `pending`
  Goal: Separate diagnostic labels from original provenance field validation.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; reading .1.25. .2.29 evidence and Dart .2.19.
  Acceptance: Reject non-string source_id/provenance before creating positions and spans; preserve diagnostic fallback labels, all valid string names and direct/derived typed attribution.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.29.2`
  Status: `pending`
  Goal: Validate complete derived segment array shape before copying.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; reading .1.25. .2.29 evidence and .2.25 density conventions.
  Acceptance: Reject sparse, extra-key or otherwise malformed host arrays before ipairs can erase members; retain ordered nonempty dense segments and exact Unicode scalar extents.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.29.3`
  Status: `pending`
  Goal: Close provenance repair with neutral and actual-carrier proof.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; reading .1.25. .2.29.1/.2 completed.
  Acceptance: Extend independent malformed/valid controls, preserve literal placeholder names, exercise relevant declaration and returned-marker carriers, qualify host-only reachability, update book and run designated closeout proof.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.30`
  Status: `pending`
  Goal: Preserve primary trace failures and close scopes on formatter rejection.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; reading .1.25. Keep existing healthy-writer behavior and caller-owned sink semantics.
  Evidence: trace_support.run calls exit_trace_scope unprotected after operation failure at23, so an exit writer failure replaces the primary value. A real validate_spec error becomes the caller writer token. A formatter returning false raises at36 without closing its scope; the next log retains an extra indent. Quiet/healthy error identity, success value7 and a throwing formatter with a healthy writer are correct. Eight complete observations per installed host use in-memory sinks only.
  Children: `.2.30.1`, `.2.30.2`, `.2.30.3`.
  Acceptance: Define and implement deterministic primary-versus-sink failure precedence and balanced scope cleanup. Preserve typed primary error identity and expose secondary trace failures through a deliberate supported channel if needed. Exact replay: docs/knowledge/lua-declaration-trace-reading-and-validation-gaps.md.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.30.1`
  Status: `pending`
  Goal: Preserve an existing operation or formatter error across trace-exit failure.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; reading .1.25. .2.30 evidence.
  Acceptance: Choose explicit error precedence consistent with original typed-error preservation, protect cleanup, and retain observable secondary failure information when required by the selected contract. Prove actual validate_spec preserves its original typed failure with a failing writer.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.30.2`
  Status: `pending`
  Goal: Close trace scopes before rejecting invalid computed success details.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; reading .1.25. .2.30 evidence.
  Acceptance: Ensure all post-operation formatter failure/type branches restore scope state exactly once, including nested scopes; preserve error text and healthy success rendering.
  Verification: `pending`
  Commit: `pending`

- ID: `LUA-STARTUP-READING.2.30.3`
  Status: `pending`
  Goal: Verify trace cleanup and failure precedence independently.
  Dependencies: Startup .3/.4/.5 and supported-PUC .2.2; reading .1.25. .2.30.1/.2 completed.
  Acceptance: Cover quiet/healthy/failing writers, nested scopes, operation errors, formatter errors and invalid formatter values. Verify original identities, event/line order, subsequent indentation and relevant public pipeline callers; update qualified book claims and run required closeout proof.
  Verification: `pending`
  Commit: `pending`

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
| 1 | `LUA-STARTUP-READING.1.28` | `pending` | Read the casing suffix 3170-3846 and rule-label prefix 1-823 after clean .1.27; preserve every repair owner, prior failure and parked named arguments. |

## Decisions

- `2026-09-12` .4.2: Explicit Granted approval closes .4.2 and admits the exact ADR0118 capacity under containment .14. The historical .4.1 proposal remains byte-exact.

- `2026-09-12` .4.1: Propose a finite 57-unit Lua envelope using observed Julia maxima and two matching history models; no control, source or standing verification changes.

- `2026-09-12`: Freeze 51 exact children under startup .3.6.0. Separate bounded ownership avoids exhausting the startup member; all aggregate controls remain active.
- `2026-09-12`: Keep the oversized generated MCP line as two independently UTF-8-decodable byte ranges; no sampling or generated-data exclusion.
- `2026-09-12`: Follow ADR0115's proportionate planning principle with a complete Lua capacity disposition under .4.1; prior concrete Julia allowances remain scoped to Julia.

## Open Questions

- .4.2 resolved: explicit Granted approval is recorded under ADR0118; no further decision is needed for this bounded admission.

## Blockers

- None for bounded Lua .1.28 reading after clean .1.27. Installed5.5 native/generated nil-error tests remain failed under .2.2; declared5.4 proof remains pending. The baseline public-selector failure is tracked under startup .28.7 and is not a passing gate. The finite ADR0118 allowance and each actual candidate remain checked; startup .80 and all later verification/repair prerequisites retain their owners.

## Verification Log

- `2026-09-13` .1.27: Lua .1.27 reads all Unicode mapping lines 1670-3169 in six complete windows: 1,500 fragments /35,947 bytes; cumulative 27/51, 36,151 fragments /1,357,777 bytes. All 99 Lua sources remain baseline-identical; 47 files are fully read. Every remaining uppercase entry and all fifteen Cased prefix ranges match the neutral contract. Both installed hosts pass 2,964 complete scoped uppercase observations, including 100 expansions. Prior .1.26 proof of 198 fixture assertions and .1.25 generation proof remain source-identical and are not recounted. No new defect is found in this range; all thirty repair roots and earlier failures remain open. Next .1.28 reads the casing suffix and rule-label prefix; named arguments and startup/ADR0118 prerequisites remain unchanged.

- `2026-09-13` .1.26: Lua .1.26 reads all Unicode mapping lines 170-1669 in seven complete windows: 1,500 fragments /35,080 bytes; cumulative 26/51, 34,651 fragments /1,321,830 bytes. All 99 Lua sources remain baseline-identical; 47 files are fully read. Every scoped mapping matches the neutral contract: 1,398 lower and 99 upper entries. Both installed hosts pass all 2,994 direct mapping observations and 198 existing Unicode fixture assertions. Twelve generation/proof inputs remain identical to .1.25, preserving its successful regeneration without recounting that run. No new defect is found in this range; all thirty Lua repair roots and earlier failures remain open. Next .1.27 reads Unicode lines 1670-3169; named arguments and startup/ADR0118 prerequisites remain unchanged.

- `2026-09-13` .1.25: Lua .1.25 completes parse-job declarations, the narrow registry and tracing, and reads the Unicode prefix in nine complete windows: 1,500 fragments /51,794 bytes; cumulative 25/51, 33,151 fragments /1,286,750 bytes. All 99 Lua sources remain baseline-identical; 47 files are fully read. Five selected trace/registry tests pass 134 assertions per installed host, 268 total. The 164 complete observations confirm provenance type/segment admission, false options, trace error replacement and formatter cleanup gaps. New .2.29/.2.30 own provenance and trace repairs; .2.8.17-.20 own registry/trace admission and .2.1 retains guidance reconciliation. Dart .2.19 records independent Lua confirmation without new Dart execution. Neutral staged123/public129, typed231 and Unicode17/12 fixtures pass as governance. All thirty Lua repair roots and earlier failures remain open. Next .1.26 reads Unicode lines 170-1669; named arguments and startup/ADR0118 prerequisites remain unchanged.

- `2026-09-13` .1.24: Lua .1.24 completes staged enrichment and capture provenance and reads the parse-job prefix in nine complete windows: 1,500 fragments /56,196 bytes; cumulative 24/51, 31,651 fragments /1,234,956 bytes. All 99 Lua sources remain baseline-identical; 43 files are fully read. Existing staged consumers pass 890 assertions per installed host, 1,780 total. The 102 boundary observations measure retained diagnostic overruns, bounded marker cycle/null handling, private capture admission and seeded defaults; the sparse-seed host difference remains explicit. New .2.26/.2.27/.2.28 own bounded repair/proof, .2.8.15/.16 own seeded-call defaults and .2.25 retains copy-before-validation scope. Shared Dart .2.17.1 records independent Lua diagnostic confirmation. Neutral staged123/public129 and typed231 mutations pass as governance. All twenty-eight Lua repair roots and earlier failures remain open. Next .1.25 reads declarations, the narrow registry, tracing and Unicode prefix; named arguments and startup/ADR0118 prerequisites remain unchanged.

- `2026-09-13` .1.23: Lua .1.23 completes the validator and reads the staged AST enrichment prefix in eight complete windows: 1,500 fragments /54,480 bytes; cumulative 23/51, 30,151 fragments /1,178,760 bytes. All 99 Lua sources remain baseline-identical; 41 files are fully read. Staged890 and gap392 assertions pass per installed host, 2,564 total. The 52 exact observations confirm false validator options and staged tagged-array member omission through private job identity and parent detachment, with zero callbacks and preserved caller inputs. .2.8.13/.14 own validator options; .2.25 owns complete staged shape validation and independent proof; .2.1 retains dated/current guidance reconciliation. Neutral staged123/public129 and gap63/public34 mutations pass as governance. All twenty-five Lua repair roots and earlier failures remain open. Next .1.24 completes staged enrichment and reads capture provenance and the parse-job prefix; named arguments and startup/ADR0118 prerequisites remain unchanged.

- `2026-09-13` .1.22: Lua .1.22 completes loader and spec parser reading and reads the validator prefix in eight complete windows: 1,500 fragments /44,459 bytes; cumulative 22/51, 28,651 fragments /1,124,280 bytes. All 99 Lua sources remain baseline-identical; 40 files are fully read. Root99 and standalone109 assertions pass per installed host, 416 total. The 88 complete observations locate unfinished edge blocks, argument-erasing fluents, distinct outer/validator regex handling and multiline quote-state loss under .2.24 with six bounded repair/proof children. Parser/loaded-engine false options extend .2.8.11/.12; .2.1 retains stale guidance and shared .54.3 now includes Lua regex recurrence. Neutral root7/0/54 and standalone14 mutations pass as governance. All twenty-four Lua repair roots and earlier failures remain open. Next .1.23 reads the validator suffix and staged AST enrichment prefix; named arguments and startup/ADR0118 prerequisites remain unchanged.

- `2026-09-13` .1.21: Lua .1.21 completes spec AST reading and reads the loader prefix in eight complete windows: 1,500 fragments /54,561 bytes; cumulative 21/51, 27,151 fragments /1,079,821 bytes. All 99 Lua sources remain baseline-identical; 38 files are fully read. Descriptor912 and root-route106 assertions pass per installed host, 2,036 total. The 208 complete observations locate native false-field defaults and typed JSON array/payload validation gaps under new .2.22/.2.23 repair/proof owners; .2.1 retains stale guidance. Startup .7 records the known process-group warning with independent matching-group and empty read-only census controls, without claiming the original group was established. Neutral resolution14/9/4 and cursor8/0/60 pass as governance. All twenty-three Lua repair roots and prior PUC observation failures remain open. Next .1.22 reads the loader suffix, spec parser and validator prefix; named arguments and startup/ADR0118 prerequisites remain unchanged.

- `2026-09-13` .1.20: Lua .1.20 completes emitter and typed-source reading and reads the spec AST prefix in eight complete windows: 1,500 fragments /54,002 bytes; cumulative 20/51, 25,651 fragments /1,025,260 bytes. All 99 Lua sources remain baseline-identical; 37 files are fully read. Typed240 and generated106 assertions pass per installed host, 692 total. The 112 complete observations and six fresh Perl facade/lowering/source controls locate generated false defaults, rejected-coordinate diagnostic serialization and PUC typed-slice overflow. Lua .2.8.9/.10 and .2.13.3/.4 extend existing owners; .2.20/.2.21 add contract and diagnostic repair/proof; shared .60.2 retains floating-count policy. Neutral typed14/0/231 and generated-source governance pass without fresh six-runtime admission. All twenty-one Lua repair roots and prior PUC observation failures remain open. Next .1.21 reads the spec AST suffix and loader prefix; named arguments and startup/ADR0118 prerequisites remain unchanged.

- `2026-09-13` .1.19: Lua .1.19 completes static projection and SHA reading and reads the emitter prefix in six complete windows: 1,500 fragments /52,334 bytes; cumulative 19/51, 24,151 fragments /971,258 bytes. All 99 Lua sources remain baseline-identical; 34 files are fully read. Source382, staged97 and remaining122 assertions pass per installed host, 1,202 total. Nine complete two-host observations and 18 query schemas retain the shared .22 call gate and .67.2 RHS-source omissions; Lua .2.19 owns conditional entry coverage and its impact/implementation/proof children. Missing-rule and slot-range controls retain distinct diagnostics. Neutral 6/20/128 and generated-source contract checks pass as qualified governance, not fresh runtime admission. All nineteen Lua repair roots and prior PUC observation failures remain open. Next .1.20 reads emitter, source-location and source-runtime ranges plus the spec AST prefix; named arguments and startup/ADR0118 prerequisites remain unchanged.

- `2026-09-13` .1.18: Lua .1.18 reads the runtime projector suffix and static prefix in six complete windows: 1,500 fragments /50,709 bytes; cumulative 18/51, 22,651 fragments /918,924 bytes. All 99 Lua sources remain baseline-identical; 32 files are fully read. Four selected suites pass 591 assertions per installed host, 1,182 total. Ten complete two-host semantic observations locate mixed-slot and regex-call source failures under .2.16/.2.17 and grouped-selector recurrence under shared startup .70. Sixteen native/reconstructed matcher rows per host plus eight reference Get executions locate explicit child-match divergence under .2.18; the initial ten reference cases retain nine agreements and one mismatch. Neutral 6/20/128 passes; prior PUC observation failures remain .2.2-owned. All eighteen Lua repair roots remain open. Next .1.19 reads the static projector suffix, SHA module and emitter prefix; approved named arguments and all startup/ADR0118 prerequisites remain unchanged.

- `2026-09-13` .1.17: Lua .1.17 completes semantic index, observation and query reading and reads the runtime projection prefix in twelve complete windows: 1,500 fragments /53,106 bytes; cumulative17/51,21,151 fragments /868,215 bytes. All99 Lua sources remain baseline-identical;31 files are fully read. Query571 and projection269 pass per host; LuaJIT observation121/generated80 pass. Installed PUC observation120/121 and generated79/80 retain two nil-error failures, root-caused to documented5.5 host coercion under existing .2.2. Fourteen two-host query responses match; twelve agree fully with neutral and two false-to-null evidence differences gain .2.15 ownership. Six shared budget cases gain bounded Lua repair/proof under startup .82.3.1. Neutral6/20/128 passes; no supported dual-host or full-gate pass is claimed. All fifteen Lua roots and startup .37.1/.28.7/.82 remain pending. Named arguments stay approved and parked. Next .1.18 reads the runtime projection suffix and static projection prefix under unchanged startup and ADR0118 prerequisites.

- `2026-09-12` .1.16: Lua .1.16 completes recognition adapter, scoped binding, scalar numeric and compilation outcome reading and reads the semantic index prefix in twelve complete windows: 1,500 fragments /46,858 bytes; cumulative 16/51, 19,651 fragments /815,109 bytes. All 99 Lua sources remain baseline-identical; 28 files are fully read. Both installed hosts pass source382, outcome122, scoped26 and boundary10 assertions each, 1,080 total. Nine native/reconstructed numeric cases per host and nine fresh Perl Get/lowering cases locate PUC arithmetic overflow under .2.13; isolated diagnostic null-to-object copies gain .2.14 repair/proof. Neutral numeric55/18 and semantic6/20/128 checks pass without fresh six-runtime admission. All fourteen Lua repair roots and startup .37.1/.28.7 remain pending. Named arguments remain approved and parked under PARSER-AUTHORING-APIS.4. Next .1.17 reads the semantic index suffix, observation, query and runtime projection prefix under unchanged startup and ADR0118 prerequisites.

- `2026-09-12` .1.15: Lua .1.15 completes wire, primary CLI and recognition transaction reading and reads the runtime adapter prefix in eleven complete windows: 1,500 fragments /51,908 bytes; cumulative 15/51, 18,151 fragments /768,251 bytes. All 99 Lua sources remain baseline-identical; 24 files are fully read. Both installed hosts pass 246 recognition assertions and 30 valid boundary controls each, 552 assertions total; default-environment CLI conformance separately passes 66 cases per host. Nine private non-finite observations per host gain .2.12 repair/proof ownership; stale transaction integration commentary extends .2.1. Neutral recognition validation passes 138 ActionIR rows, 250 calls and 58 mutations with existing governance checks. All twelve Lua repair roots and startup .37.1/.28.7 remain pending. Named-argument direction remains approved and parked under PARSER-AUTHORING-APIS.4. Next .1.16 reads the adapter suffix, scoped binding, scalar numeric, compilation outcome and semantic index prefix under unchanged startup and ADR0118 prerequisites.

- `2026-09-12` .1.14: Lua .1.14 reads the generated module ending, contract runtime, decoded server and wire prefix in twelve complete windows: 1,500 fragments /53,162 bytes; cumulative 14/51, 16,651 fragments /716,343 bytes. All 99 Lua sources remain baseline-identical; 21 files are fully read. Both installed hosts pass 216 decoded, 247 stdio and 33 valid boundary controls each, 992 assertions total. MCP constructor false defaults extend .2.8.7/.8; measured integer-copy loss extends .2.11 without widening request IDs. Admission141 and callable3/9/7 checks pass. Named-argument direction is approved and parked under PARSER-AUTHORING-APIS.4 with four unactivated design/planning children. All eleven Lua repair roots and startup .37.1/.28.7 remain pending; next .1.15 under unchanged startup and ADR0118 prerequisites.

- `2026-09-12` .1.13: Lua .1.13 reads generated MCP bytes 65797–83164 in three complete windows: one fragment /17,368 bytes; cumulative 13/51, 15,151 fragments /663,181 bytes. All 99 Lua sources remain baseline-identical. Independent reconciliation matches the canonical bundle, seven artifact digests, three embedded artifact values, 35 frames and four payload digests. Generator comparison and neutral transport validation pass, including 76 rejected mutations. The prior leaf retains the latest 232 native binding assertions; no new native run is counted. All eleven local repair roots and startup .37.1/.28.7 remain pending; the public-selector failure stays open. Next .1.14 reads the final module line, contract runtime, server and wire prefix; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.12: Lua .1.12 reads generated MCP bytes 261–65796 in eight complete windows: one fragment /65,536 bytes; cumulative 12/51, 15,150 fragments /645,813 bytes. All 99 Lua sources remain baseline-identical. The 83,166-byte generated module is byte-fresh; both installed hosts pass 116 binding assertions each, 232 total. Admission governance rejects 141 mutations. The stale tree aggregate is corrected from completed-node totals. All eleven local repair roots and startup .37.1/.28.7 remain pending; the public-selector failure stays open. No declared PUC 5.4, full server, full gate or corpus pass is claimed. Next .1.13 reads the remaining generated payload bytes; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.11: Lua .1.11 reads the JSON suffix, matching module and MCP header in six complete windows: 704 fragments /22,026 bytes; cumulative 11/51, 15,149 fragments /580,277 bytes. All 99 Lua sources remain baseline-identical; JSON and matching reading complete. Both installed hosts pass 60 focused and 112 duplicate-slot assertions, 344 total, plus three PUC integer-format comparisons. .2.11 owns exact represented-integer JSON encoding; .2.8.5/.6 own matching false defaults. Neutral duplicate-slot 59 mutations pass. All eleven local repair roots and startup .37.1/.28.7 remain pending; prior public-selector failure stays open. No declared PUC 5.4, full gate or corpus pass is claimed. Next .1.12; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.10: Lua .1.10 reads the interpreter suffix and JSON prefix in ten complete windows: 1,500 fragments /51,687 bytes; cumulative 10/51, 14,445 fragments /558,251 bytes. All 99 Lua sources remain baseline-identical; interpreter reading is complete. Both installed hosts pass runtime/JSON 68, cursor 108 and observation 43 assertions, 438 total. Five false option-table acceptances per host extend existing .2.8 through separate repair/proof children .2.8.3/.4. Neutral cursor 60 and root 54 mutations pass. All ten local repair roots and startup .37.1/.28.7 remain pending; the earlier public-selector baseline failure stays open. No declared PUC 5.4, full gate or corpus pass is claimed. Next .1.11; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.9: Lua .1.9 reads interpreter 2917–4416 in nine complete windows: 1,500 fragments /58,443 bytes; cumulative 9/51, 12,945 fragments /506,564 bytes. All 99 Lua sources remain baseline-identical. Both installed hosts pass 449 callable assertions plus 26 valid controls, 950 total; separate false whole-child push observations gain .2.10 repair/proof. Neutral callable23 mutations and uniform11/7/6/8 checks pass. Existing .2.1 gains stale explicit-callable guidance correction. All ten local repairs and startup .37.1/.28.7 remain pending; the earlier public-selector baseline failure is still open. No declared PUC 5.4, full gate or corpus pass is claimed. Next .1.10; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.8: Lua .1.8 reads interpreter1417–2916 in nine complete windows: 1,500 fragments /52,134 bytes; cumulative 8/51, 11,445 fragments /448,121 bytes. All 99 Lua sources remain baseline-identical. Corrected native helper controls pass22 per installed host, 44 total; false join/split delimiter differences gain .2.9 repair and independent proof. Named-mark7/3 and mutation-result54/12/9 checks pass. Additional public-selector checking fails on unchanged baseline inputs: 35 references against32 and one misclassified negative example; startup .28.7 owns repair/proof. All nine local repair roots and startup .37.1 remain pending; no declared PUC5.4, full gate or corpus pass is claimed. Next .1.9; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.7: Lua .1.7 reads two exact ranges in ten windows: 1,500 fragments /53,644 bytes; cumulative 7/51, 9,945 fragments /395,987 bytes. All 99 Lua sources remain baseline-identical. Native facade/runtime controls pass 27 per installed host, 54 total; both managed runs and cleanup are consumed. Explicit false max_iterations silently selects 10000; .2.8 owns absence-only defaulting and independent route proof. .2.1 also owns stale runtime-card mode/write/callable guidance. Write 105 and logical 26 mutations pass. All eight local repair roots and startup .37.1 remain pending; no declared PUC 5.4, full gate or corpus pass is claimed. Next .1.8; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.6: Lua .1.6 reads four exact ranges in ten windows: 1,500 fragments /58,462 bytes; cumulative 6/51, 8,445 fragments /342,343 bytes. All 99 Lua sources remain baseline-identical. Pure compiled-state controls pass 25 per installed runtime, 50 total; regex-slot59, cursor60 and signature3/9/7 checks pass. Independent census confirms 105 corpus directories and 315 UTF-8 files without Lua corpus execution. Existing .2.1 owns the stale corpus-card primary-scaffold sentence; all seven local repairs and startup .37.1 remain pending. No declared 5.4 conformance, native build or full gate is claimed. Next .1.7; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.5: Lua .1.5 reads two exact ranges in nine windows: 1,500 fragments /55,335 bytes; cumulative 5/51, 6,945 fragments /283,881 bytes. All 99 Lua sources remain baseline-identical. Selected authority 272 plus 17 valid controls pass per installed runtime, 578 total; the facade assertion is excluded. The zero-parent-step nested callback observation joins existing startup .37.1; the one-step control and compiled snapshots pass. Progressive 116/public60 and selector 0/20 pass. All seven Lua repair roots remain pending; no declared 5.4 conformance, native build or full gate is claimed. Next .1.6; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.4: Lua .1.4 reads two exact ranges in nine windows: 1,500 fragments /58,518 bytes; cumulative 4/51, 5,445 fragments /228,546 bytes. All 99 Lua sources remain baseline-identical. Selected authority 272 plus parser 13 controls pass per measured runtime, 570 total; the facade assertion is explicitly excluded. .2.6 owns lost pairless harray members and .2.7 incomplete switch contract diagnostics; runtime switch source separately validates the complete body. Progressive 116/public 60 and write 105 mutations pass. All seven Lua repair owners remain pending; no declared 5.4 conformance, native build or full gate is claimed. Next .1.5; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.3: Lua .1.3 reads three exact ranges in nine windows: 1,500 fragments /50,175 bytes; cumulative 3/51, 3,945 fragments /170,028 bytes. All 99 Lua sources remain baseline-identical. Pure parser/contract controls pass 32 per measured runtime (PUC 5.5.1 and LuaJIT); six malformed-string acceptances per runtime have an exact cause and .2.5 repair/verification ownership. Inventory 250/105+1/126, signature 3/9/7, callable 23 mutations and punctuation 6/4/6 pass. All five Lua repair owners remain pending; no native build, declared 5.4 conformance or full component gate is claimed. Next .1.4; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.2: Lua .1.2 reads eight exact ranges in thirteen windows: 1,500 fragments /54,321 bytes; cumulative 2/51, 2,445 fragments /119,853 bytes. All 99 Lua sources remain baseline-identical. Selector 0/20, native resolution 14/9/4 and MCP 141 pass. Exact README diagnostic failure and positive control reproduce on measured PUC 5.5.1 and LuaJIT; unsupported native error formatting loses LuaJIT detail and crashes PUC 5.5.1 with a source-attributed stack. .2.2-.2.4 own primary identity, native error safety and executable teaching; .2.1 retains stale guidance and startup .81.1 owns loader diagnosis. All probes are consumed; no declared 5.4 conformance or repair completion is claimed. Next .1.3; startup prerequisites and ADR0118 remain.

- `2026-09-12` .1.1: Lua .1.1 reads README lines 1–945 completely: 945 fragments /65,532 bytes across six exact windows. Root selection 139 and logical helpers 359 pass per ABI; neutral root 54 / logical 26 mutations pass. Reading is 1/51; .2.1 owns stale present-tense gate guidance with repair and independent-verification children. All 99 Lua files remain baseline-identical; .1.2 is next. ADR0118 capacity, startup prerequisites and all earlier repairs remain.

- `2026-09-12` .4.2: Explicit ADR0118 approval admits exactly eleven finite Lua evidence controls and the .14-only focused/receipt exception. The complete actual-plus-57-unit reserve fits; independent and production history models agree on four rollovers per collection. Actual routing functions pass 125 threshold and 54 authorization cases. Previous source, cards, decisions, task evidence and immutable history remain exact. Lua .4/.4.2 close; source reading remains 0/51 and .1.1 follows the clean commit. Later verification and startup repair prerequisites remain unchanged.

- `2026-09-12` .4.1: Lua .4.1 proposes eleven finite evidence-limit changes for 51 reading leaves plus six support units. Exact 57-unit reserve and independent/production history models pass; each history needs four rollovers with only two slots available. The proposal preserves all source, evidence, controls and pending repairs. Explicit approval of the exact limits and containment .14-only focused/receipt exception is required before implementation; Lua .4.2 owns the decision. Source reading remains 0/51.

- `2026-09-12`: Startup .3.6.0 independently verifies the frozen range plan before landing; detailed proof is retained in its startup node and the linked Knowledge card. No Lua source comprehension or new runtime gate result is claimed.

## Commit Log

- `2026-09-13` .1.27: `LUA-STARTUP-READING.1.27 - complete uppercase table reading and verify scoped mappings`; activation 2e7046a44; next .1.28 after clean proof and empty brief.

- `2026-09-13` .1.26: `LUA-STARTUP-READING.1.26 - complete lower-case table reading and verify scoped mappings`; activation 67a97d3d3; next .1.27 after clean proof and empty brief.

- `2026-09-13` .1.25: `LUA-STARTUP-READING.1.25 - read declarations and trace and own validation repairs`; activation 813b2aad2; next .1.26 after clean proof and empty brief.

- `2026-09-13`: `LUA-STARTUP-READING.1.24 - finish staged reading and own diagnostic and provenance repairs` closes exact reading child 24 from clean 8469d5ba1.

- `2026-09-13`: `LUA-STARTUP-READING.1.23 - read validator and staged prefix and own array validation` closes exact reading child 23 from clean 4e2cbd9a2.

- `2026-09-13` .1.22: `LUA-STARTUP-READING.1.22 - read source parser and own lexical completeness repairs` closes reading child 22 from clean 65bd10925.

- `2026-09-13` .1.21: `LUA-STARTUP-READING.1.21 - read AST and loader and own validation boundaries` closes reading child21 from clean 31ebbc2e4.

- `2026-09-13` .1.20: `LUA-STARTUP-READING.1.20 - read emitter and typed sources and own boundary repairs` closes the twentieth reading child from clean 028d4158e.

- `2026-09-13` .1.19: `LUA-STARTUP-READING.1.19 - complete static and SHA reading and own conditional entry repair` closes the nineteenth reading child from clean 1d569ea18.

- `2026-09-13` .1.18: `LUA-STARTUP-READING.1.18 - read semantic projectors and own source and matcher repairs` closes the eighteenth reading child from clean cdf15066d.

- `2026-09-13` .1.17: `LUA-STARTUP-READING.1.17 - read semantic queries and preserve budget and host failure ownership` closes the seventeenth reading child from clean dce95cec2.

- `2026-09-12` .1.16: `LUA-STARTUP-READING.1.16 - read numeric and semantic modules and own value preservation repairs` closes the sixteenth reading child from clean 1c74ad498.

- `2026-09-12`: `LUA-STARTUP-READING.1.15 - read wire CLI and transactions and own finite state repair` closes the fifteenth reading child from clean 400e3db44.

- `2026-09-12` .1.14: `LUA-STARTUP-READING.1.14 - read MCP runtime and preserve repair and named-call ownership`.

- `2026-09-12` .1.13: `LUA-STARTUP-READING.1.13 - finish generated MCP payload reading and reconciliation`.

- `2026-09-12` .1.12: `LUA-STARTUP-READING.1.12 - read generated MCP bytes and reconcile binding proof`.

- `2026-09-12` .1.11: `LUA-STARTUP-READING.1.11 - read JSON and matching and own integer encoding repair`.

- `2026-09-12` .1.10: `LUA-STARTUP-READING.1.10 - finish interpreter reading and own option table validation`.

- `2026-09-12` .1.9: `LUA-STARTUP-READING.1.9 - read callable dispatch and own false child push repair`.

- `2026-09-12` .1.8: LUA-STARTUP-READING.1.8 - read interpreter helpers and own false delimiter repair

- `2026-09-12` .1.7: `LUA-STARTUP-READING.1.7 - read interpreter prefix and own iteration option validation`.

- `2026-09-12` .1.6: `LUA-STARTUP-READING.1.6 - read compiled state corpus and facade boundaries`.

- `2026-09-12` .1.5: `LUA-STARTUP-READING.1.5 - read authority and compiled state and record nested step gap`.

- `2026-09-12` .1.4: `LUA-STARTUP-READING.1.4 - read parser and authority and own member accounting gaps`.

- `2026-09-12` .1.3: `LUA-STARTUP-READING.1.3 - read action contracts and own complete string boundary repair`.

- `2026-09-12` .1.2: `LUA-STARTUP-READING.1.2 - read native and AST sources and own confirmed Lua defects`.

- `2026-09-12` .1.1: `LUA-STARTUP-READING.1.1 - read Lua README prefix and own stale gate guidance`.

- `2026-09-12` .4.2: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.14 - admit approved Lua reading evidence capacity` closes .4/.4.2 without source-reading credit.

- `2026-09-12` .4.1: `LUA-STARTUP-READING.4.1 - propose finite Lua evidence capacity and verification boundary`.

- `SESSION-STARTUP-READING.3.6.0 - freeze exact Lua reading ownership and capacity intake` owns creation of this plan.

## Changelog

- `2026-09-13` .1.27: Complete every uppercase mapping and fifteen Cased ranges; verify every scoped entry and preserve all prior repair and historical evidence.

- `2026-09-13` .1.26: Complete all lower-case mapping reading and first 99 upper-case entries; verify every scoped mapping and preserve all earlier repair and historical evidence.

- `2026-09-13` .1.25: Complete declaration/registry/trace reading and Unicode prefix; own original provenance validation and trace cleanup, extend option/guidance owners, and preserve all prior evidence.

- `2026-09-13` .1.24: Complete staged enrichment/capture reading; own diagnostic, marker and capture admission repairs and preserve shared evidence. Reading is 24/51; next .1.25.

- `2026-09-13` .1.23: Read validator/staged prefix; own staged shape and validator-option repair/proof; source reading is 23/51; next .1.24.

- `2026-09-13`: .1.22 completes loader/spec parser reading and reads the validator prefix; .2.24 owns lexical completeness, .2.8 options, .2.1 guidance and shared .54.3 regex recurrence. Reading is 22/51; next .1.23.

- `2026-09-13`: .1.21 completes AST reading and reads the loader prefix; .2.22/.2.23 own bounded validation repairs, .2.1 stale guidance and startup .7 the known process warning. Reading is 21/51; next .1.22.

- `2026-09-13`: .1.20 completes emitter/typed-source reading, reads the AST prefix and owns generated/default, rejected-coordinate and typed-slice repairs. Reading is 20/51; next .1.21.

- `2026-09-13`: .1.19 completes static and SHA reading, reads the emitter prefix, extends shared call/binding omissions and owns conditional entry coverage under .2.19. Reading is 19/51; next .1.20.

- `2026-09-13`: .1.18 completes runtime projection reading and reads the static prefix; .2.16/.2.17/.2.18 own mixed slots, call source and runtime match ownership, with grouped recurrence under startup .70. Reading is 18/51; next .1.19.

- `2026-09-13`: .1.17 completes index/observation/query reading, owns rejected false evidence, extends shared budget and primary-host repair evidence, and preserves both PUC nil-error failures. Reading is17/51; next .1.18.

- `2026-09-12`: .1.16 completes four modules and reads the semantic index prefix; .2.13 owns numeric overflow and .2.14 diagnostic null preservation. Reading is 16/51; next .1.17.

- `2026-09-12`: .1.15 completes wire/CLI/transaction reading and reads the runtime prefix; .2.12 owns finite private state/progress and .2.1 the stale integration comment. Reading is 15/51; next .1.16.

- `2026-09-12` .1.14: Read MCP runtime/server boundaries, extend existing option/integer repairs and durably capture approved parked named arguments; advance .1.15 without a product pivot.

- `2026-09-12` .1.13: Finish reading the generated MCP literal and reconcile its neutral artifacts independently; preserve prior evidence and advance to .1.14.

- `2026-09-12` .1.12: Read the first generated MCP byte range, reconcile fresh binding proof and correct the stale current aggregate; preserve prior evidence and advance to .1.13.

- `2026-09-12` .1.11: Finish JSON/matching reading and read the generated MCP header; own integer encoding and matching validation repairs, preserve earlier evidence and advance to .1.12.

- `2026-09-12` .1.10: Finish interpreter reading and read JSON prefix; decompose option-table repair under existing .2.8, preserve prior evidence and advance to .1.11.

- `2026-09-12` .1.9: Read group nine; own false whole-child push repair and extend stale callable guidance correction; preserve prior evidence and advance to .1.10.

- `2026-09-12` .1.8: Read group eight; own false delimiter repair and baseline public-check repair, preserve source/evidence and advance to .1.9.

- `2026-09-12` .1.7: Complete facade and interpreter prefix reading; own explicit iteration-option validation with two children, extend stale canonical guidance ownership and advance .1.8.

- `2026-09-12` .1.6: Complete compiled state and corpus reading, read facade prefix, extend existing documentation repair, preserve source/evidence and advance .1.7.

- `2026-09-12` .1.5: Complete authority reading and compiled-state prefix; extend existing .37.1 with measured Lua budget evidence, preserve all prior repairs and advance .1.6.

- `2026-09-12` .1.4: Complete parser reading and read authority prefix; own harray and static-switch accounting repairs, preserve all earlier evidence and advance .1.5.

- `2026-09-12` .1.3: Read contracts and parser prefix; own exact complete-string recognition repair; preserve all prior source/evidence and advance .1.4.

- `2026-09-12` .1.2: Read exact README/native/AST ranges; own three confirmed defects, extend stale guidance ownership, root-cause the native crash and advance .1.3 without source changes.

- `2026-09-12` .1.1: Read the first exact Lua group, own stale README gate guidance and advance .1.2 without source changes.

- `2026-09-12` .4.2: Resolve approved capacity and route the first exact Lua reading child after clean admission.

- `2026-09-12` .4.1: Complete the coherent Lua capacity proposal; retain 0/51 reading and all existing repairs while explicit disposition is pending.

- `2026-09-12`: Create exact bounded Lua reading, repair, closeout and capacity ownership under startup .3.6.0.
