# CONFORMANCE-SOURCE-READING: Neutral contracts, regression tests and Unicode sources

## Metadata

- Tree ID: `CONFORMANCE-SOURCE-READING`
- Status: `active` / exact decomposition; physical reading 78/143
- Roadmap lane: `Session required reading / SESSION-STARTUP-READING.3.8`
- Created: `2026-09-13`
- Last updated: `2026-09-21`
- Owner: repo-local workflow
- Decomposition owner: `SESSION-STARTUP-READING.3.8.0`

## Goal

Read and understand the complete current conformance/test/Unicode source lane.
Keep source comprehension, actual runtime proof and defect repair status distinct.

## Scope and acceptance

- Baseline: `baeb984e36a94a15951cd23d4c52def5064cdaca`; clean planning activation `9833430954c3999769045abbcaa4d20389a7af4c`.
- Exact ordered selectors: `capability_conformance/`, `cli_conformance/`, `t/`, `tests/`, `unicode_case/`.
- At the September 13 decomposition, all 160 baseline/current modes, blobs and paths match;5,422,313 stored bytes decode to8,257,059 UTF-8 bytes,167,604 LF delimiters and167,606 line fragments. No empty or binary decoded input.
- Decode precisely the four tracked `.gz` inputs under `unicode_case/upstream/17.0.0/`; Scope coordinates for them refer to decompressed UTF-8 text. Their complete compressed Git identity and decoded hashes are verified by the canonical coverage recipe.
- All143 reading groups/302 inclusive ranges cover the lane exactly once; each group is at most1500 fragments and65536 bytes. Smaller complete output windows are mandatory, including byte windows for a long logical line when needed.
- Counts, enumeration, decompression, generated-data equality and earlier test execution are not physical reading credit. Existing dated comprehension/proof may be reconciled through Knowledge without claiming a new runtime run.
- Keep every generated fixture and Unicode input in scope. Historical corpus fixtures here remain current test inputs; the earlier conf/TableScript retirement does not silently remove them.
- Retrieve Knowledge before interpreting source and use LinkedSpec Toolbox probes before diagnosing behavior. Give every confirmed issue an owning repair leaf with concrete acceptance and reproduction.
- Ordinary reading uses focused changed-surface/direct-dependent checks. Infrastructure, admission, parent closeout and push retain COMMIT.md/ADR0073; ADR0120 covers only the already completed correction and supporting closeout.
- Source repairs retain remaining startup reading/book/policy prerequisites. Reuse compatible RGX/PGEN products; reading requires no compilation of unchanged dependencies.
- Commit each verified child and synchronize the task frontier, memory, roadmaps, Knowledge and relevant book understanding. Preserve original Scope/digests, prior task evidence and immutable history.
- Measure each resulting task/Knowledge/history collection against its existing registry ceilings. This plan changes no capacity limit and grants no unlimited growth allowance.
- Canonical inventory and exact range replay: `docs/knowledge/conformance-source-reading-coverage.md`.

## Task Tree

- ID: `CONFORMANCE-SOURCE-READING`
  Status: `active`
  Goal: Complete conformance/test/Unicode source reading and preserve every repair obligation.
  Children: `.1`, `.2`, `.3`, `.4`

- ID: `CONFORMANCE-SOURCE-READING.1`
  Status: `active`
  Goal: Physically read and comprehend all143 bounded source groups, reconciling current deltas and existing Knowledge.
  Children: `.1.1-.1.143`
  Dependencies: Startup .3.8.0 decomposition committed clean; clean activation and commit per reading child.
  Acceptance: Exact once-only source coverage, comprehension, owned findings, focused proof and durable clean handoff for every child. A hash or successful test alone is not reading credit.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.1`
  Status: `done`
  Activation commit: `d3cfa5973beed85de5ae58dc81798262cafe18ad`.
  Verification tier: `focused`
  Focused checks: Complete untruncated exact770-line guide prefix and baseline identity; canonical capability/contract/status facts and owned claim gaps; focused direct-consumer checks, prior evidence preservation, memory, Knowledge, histories, book and normal doctrine hooks.
  Canonical trigger: Ordinary source-reading/comprehension leaf; no source/public-contract/registry change or parent closeout. Preserve later verification and repair prerequisites.
  Goal: Read and understand conformance/test/Unicode group 1.
  Scope: `capability_conformance/README.md` lines 1-770
  Baseline evidence: 770 fragments / 65485 decoded bytes; ordered range SHA-256 `33fdc07fa05ee9ed692d82225187f11f1ead806289d86b44f247da2f5b13ca4d`.
  Dependencies: Startup .3.8.0 decomposition committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 770 fragments / 65485 bytes; ordered window SHA-256 `82c1b7aca6d2fd95e45a51c2b93fb7a50e3c19f1b2b42c77f90cfa8457e7f180`.
  Comprehension: Separates capability/exclusion census, frozen mutation authorities, recurring proof and public claims; MCP transport/bindings/admission and semantic snapshots/query outcomes have distinct owners. Typed sources, recognition, observation, gaps, bounded dispatch and staged jobs preserve private authority/public exclusions. Root selection, duplicate identity, repetition results, scalar/logical rules and variadic signatures retain separate neutral contracts. The callable-codeblock section begins at the final line; its suffix remains .1.2-owned.
  Verification: All11 complete source windows read through line770; full-source SHA-2569a0836a3b314bf3edfbf48cd1882027de739bad094edbadfee4086db5d8948f3 and scope SHA-25615e215a231e1fbe97483ee8a318a5934b8ea8336483b4166bebc891590e821df remain baseline-identical. Exact guide-claim probe confirms seven stale phrases behind passing capability20/100/19, callable23, signature3/9/7, cursor74/60, repetition54, logical19/14/26 and root7/54 structural/neutral checks. Startup .41.6/.41.7 own precise repair/recurrence; no source/runtime repair or fresh matrix. Comprehension and exact source/checker cause live in conformance-capability-guide-reading; range/window/source/preservation, memory, Knowledge, histories, book and normal doctrine proof govern landing.
  Candidate proof: Preserve2487 prior files byte-exact, historical recipe blocks,2770/2776 prior task nodes and all94 book limitation headings. Six intended reading/intake/current-owner nodes change, no new ID; all other repair nodes remain exact. Complete143-group/302-range audit and recorded11-window reconstruction PASS. Memory60; histories445/46488 and375/45358 lines/bytes; rendered book and git diff --check PASS. Normal doctrine hooks govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.1 - read capability guide prefix and own stale current claims`

- ID: `CONFORMANCE-SOURCE-READING.1.2`
  Status: `done`
  Activation commit: `724185e83987bcd7597dae3840efd23af352859f`.
  Verification tier: `focused`
  Focused checks: Complete baseline-identical source windows; callable, signature, named-mark and diagnostic contract comprehension with canonical Knowledge reconciliation; relevant neutral checks, source/evidence preservation, memory, histories, book and normal doctrines.
  Canonical trigger: Ordinary bounded reading leaf; no contract, runtime or infrastructure change and no parent closeout. Later repairs retain startup prerequisites.
  Goal: Read and understand conformance/test/Unicode group 2.
  Scope: `capability_conformance/README.md` lines 771-897; `capability_conformance/callable_codeblock_contract.json` lines 1-237; `capability_conformance/callable_signature_contract.json` lines 1-125; `capability_conformance/complete_named_mark_contract.json` lines 1-51; `capability_conformance/diagnostic_output_contract.json` lines 1-268
  Baseline evidence: 808 fragments / 65502 decoded bytes; ordered range SHA-256 `57a805392c2ad3942b7e69818bd3389acd38f5fdf6d73c225f2d094b14377cc4`.
  Dependencies: .1.1 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 12 complete windows / 808 fragments / 65502 bytes; ordered window SHA-256 `8b603c04dc5238991a0d757017dc1efd3d45cad79fc0d2b7f7507caade736f45`.
  Comprehension: Callable literals are inert eight-field data without captured environments; invocation uses caller-time stores with copied/restored fixed/rest parameters, block-local return and static precedence. Final-only callback declarations govern contextual blocks. Signature v1 preserves fixed exact arity and variadic v2 descriptors with fresh unflattened rest arrays; named arguments stay a separately approved parked proposal. Named marks use symbolic names and character locations isolated by rule label, not recursive invocation. Diagnostic arity precedes eager arguments; typed synchronous sink events stay outside results/trace, with quiet absence and immediate failure/exit propagation. Full rollout suffix remains .1.3-owned.
  Verification: exact12-window/source and143-group/302-range audits, suffix/current-metadata assertions, fresh named-mark7-helper/3-mutation and diagnostic3-helper/11-render/6-scenario/20-mutation checks; prior unchanged callable/signature evidence retained without a fresh runtime claim. Source/task/history preservation, memory, Knowledge, both histories, rendered book, git diff --check and normal doctrine hooks govern this focused reading leaf. Guide EOF confirms existing stale current census wording; .41.7 owns the exact suffix and recurrence. Four files are now complete and diagnostic reading stops at268; source identity checks do not grant unread suffix credit.
  Candidate proof: Exact twelve-window reconstruction and all143-group/302-range ownership PASS. Preserve2486 prior files, all prior recipes,2772/2776 task nodes and all94 book limitation headings; only four intended reading/current-owner nodes change and no task ID is added. Memory60; histories 451/47932, 381/46567 lines/bytes. Normal doctrines govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.2 - complete guide and read callable mark and diagnostic contracts`

- ID: `CONFORMANCE-SOURCE-READING.1.3`
  Status: `done`
  Activation commit: `51c7ea8fe89e4f96b5927ec02bc5b629d33d8986`.
  Verification tier: `focused`
  Focused checks: Complete exact baseline-identical windows; diagnostic suffix, duplicate-slot identity, capability fixtures, generated-source roles and gap-prefix comprehension; relevant neutral proof, evidence preservation, memory, histories, book and normal doctrines.
  Canonical trigger: Ordinary bounded reading leaf; no source, public-contract or infrastructure change and no parent closeout. Later repair and canonical prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 3.
  Scope: `capability_conformance/diagnostic_output_contract.json` lines 269-273; `capability_conformance/duplicate_regex_slot_identity_contract.json` lines 1-280; `capability_conformance/fixtures/capability_capture_anonymous_surface.spec` lines 1-51; `capability_conformance/fixtures/capability_capture_named_surface.spec` lines 1-61; `capability_conformance/fixtures/capability_control_marker_surface.spec` lines 1-26; `capability_conformance/fixtures/capability_cursor_control_surface.spec` lines 1-24; `capability_conformance/fixtures/capability_position_helper_surface.spec` lines 1-41; `capability_conformance/fixtures/capability_pure_helper_surface.spec` lines 1-38; `capability_conformance/generated_source/fixtures/default_action_result_trace_identity/expected.json` lines 1-1; `capability_conformance/generated_source/fixtures/default_action_result_trace_identity/input.spec` lines 1-5; `capability_conformance/generated_source/fixtures/default_action_result_trace_identity/input.txt` lines 1-1; `capability_conformance/generated_source_contract.json` lines 1-162; `capability_conformance/inter_match_gap_capture_contract.json` lines 1-805
  Baseline evidence: 1500 fragments / 52668 decoded bytes; ordered range SHA-256 `b50f26b02c97ce5b04829dc991161454d9cf979b990caae89fa249ed3ecb2f08`.
  Dependencies: .1.2 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 19 complete windows / 1500 fragments / 52668 bytes; ordered window SHA-256 `80286e7145eaf93781f463140168b0dea04b2e61a235991a90395b8d15448b96`.
  Comprehension: Ordered matching tests the required target-rule/index identity; choice uses earliest start then authored order, and repetitions reset the required sequence. Six capability fixtures exercise anonymous/named capture, control markers, cursor save/restore, position and value helpers without claiming complete semantics from name coverage. Generated v1 is a semantic portability baseline with ten plan families, stable errors and interpreter-first independent load/execute roles; current format v2 identity is a separate contract. Gap identifiers preserve exact Unicode/XID identity; selected-edge provenance, candidate visibility, accepted-exit commit, terminal tails and per-invocation suspension/rollback are explicit. Falsey payloads still accept matches, and rollback excludes user/output/host effects. Gap mutation-list and later sections remain .1.4-owned.
  Verification: complete 19-window source reconstruction and all 143-group/302-range identities; duplicate-slot neutral 5 fixtures/2 diagnostics/6 runtimes/7 complete/21 documents/11 denials/59 mutations, generated-source 10 families/1 behavior case and declared 8/105 plus Rust 105/105 roles, language 250 calls/105 corpus plus named-mark fixture/126 public contracts, and gap 8+10 fixtures/3 sources/16 transitions/10 segmentations/9 diagnostics/9 complete/63 semantic and 34 public mutations. These are fresh structural/neutral checks, not rebuilt or executed backend matrices. Preservation, memory, Knowledge, histories, rendered book, git diff --check and normal doctrines govern landing. Canonical duplicate-slot/generated-source/gap admission cards reconcile dated milestones with current contracts. No new runtime defect is inferred and no existing repair node changes. Diagnostic reading reaches EOF; gap reading ends at805.
  Candidate proof: Recorded19-window, all143-group/302-range and cumulative3-group/3078-fragment/183655-byte/16-complete-file audits PASS. Preserve2487 prior files, prior recipes,2774/2776 task nodes and all94 book limitation headings; only this reading node and startup .3.8 change. Memory60; histories457/49603 and387/48072 lines/bytes; rendered book and git diff --check PASS. Normal doctrines govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.3 - read slot identity fixtures generated roles and gap prefix`

- ID: `CONFORMANCE-SOURCE-READING.1.4`
  Status: `done`
  Activation commit: `baaebc8ef62baf84447767c2b361458c3ac57d9e`.
  Verification tier: `focused`
  Focused checks: Exact baseline-identical gap/logical/capability/map-prefix windows, canonical Knowledge reconciliation and relevant neutral checks; preserved source/task/history, bounded history rollover if required, memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf and prescribed documentation rollover only; no runtime, contract or infrastructure change and no parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 4.
  Scope: `capability_conformance/inter_match_gap_capture_contract.json` lines 806-1213; `capability_conformance/logical_helper_contract.json` lines 1-303; `capability_conformance/manifest.json` lines 1-278; `capability_conformance/map_leaves_mutation_contract.json` lines 1-33
  Baseline evidence: 1022 fragments / 65375 decoded bytes; ordered range SHA-256 `5be3f9bc37cea2f28b36f750b93cf0b640df9cdb2187bc8078d9d25598a0b62d`.
  Dependencies: .1.3 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 13 complete windows / 1022 fragments / 65375 bytes; ordered window SHA-256 `da9916088f3eeedc594e7bbafea749360f96060a919268f230a42643158739c1`.
  Comprehension: Gap completion locks exact neutral-plus-six-runtime route order, carrier roles, four source-read calls, legacy divergence, eight public documents/fifteen denials and ten outward guards. Logical helpers validate arity before eager ordered arguments, return typed booleans and keep codeblocks inert; lazy controls remain distinct. Capability schema v2 separates twenty independently referenced backend rows from the sole legacy exclusion and its disposition/retention fields. Frozen map-leaves prefix specifies bare receiver identity, root-kind original-shape traversal, detached callbacks/results, receiver guard, atomic commit and post-commit continuation; later admission does not rewrite its original future-neutral status. Map syntax suffix and cases remain .1.5-owned.
  Verification: exact 13-window/source and 143-group/302-range audits; fresh logical 17/10/3, 19 documents/14 denials/26 mutations; capability 20/100, one exclusion, 19 exclusion/16 admission/17 recurring/4 mutation-public/6 public/4 language mutations; map-leaves 4 valid/14 invalid/5 exclusions/10 successes/8 failures, 6 callback plus1 continuation compositions and167+592 mutations. Prior gap structural proof remains unchanged-source dated evidence. Preserve source/task/history, verify required complete-record rollover, memory, Knowledge, both histories, rendered book, git diff --check and normal doctrines. No dependency build or fresh backend matrix. No new runtime defect is inferred; startup .58/.59 and all earlier repairs remain open. Full gap/logical/manifest sources and exact map1-33 prefix are read; no unread map suffix credit.
  Rollover proof: Required463-line CHANGES candidate becomes247 lines/32290 bytes. Exact clean activation CHANGES242-457 is segment4976-6d1dd54d605a,216 lines/18973 bytes, SHA-2566d1dd54d605a5363a60cfc39d7918f91cd6d3934f8df6e3d57c00f14c1d0d026. All34 older manifest records remain byte-exact; current collection37 files/36 manifest lines/20495 bytes fits unchanged limits. Hot-root plus archive reconstruction is identical at3613557 bytes/SHA-2569c8ea4a6eee5f1e5b5a23383a5ee1103a2236cd2a9b40dfdad610f6a0b0a5e98. The first archive-only comparison was invalid because read_document_history --all intentionally excludes the hot root (reader lines30-35); source inspection and combined reconstruction resolve it without a product change. General guidance is recorded in bounded-change-notes-history-contract.
  Candidate proof: Recorded13-window, all143-group/302-range and cumulative4-group/4100-fragment/249030-byte/19-complete-file audits PASS. Preserve2486 prior files, all prior recipe blocks,2774/2776 nodes and all94 book limitation headings; only this reading leaf/startup .3.8 change. Memory60, histories247/32290 and393/49578 lines/bytes, rendered book PASS. Plain git diff --check reports only the exact retained CHANGES247 record-separator blank at EOF; strict checking of every other path plus command-scoped core.whitespace=-blank-at-eof for CHANGES alone passes. No global setting, attribute or hook changes; byte-exact chronology is preserved. Normal doctrines govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.4 - read gap logical and capability authorities with frozen mutation prefix`

- ID: `CONFORMANCE-SOURCE-READING.1.5`
  Status: `done`
  Activation commit: `24d3b9347d30254d4e3e2bc1a7b1df238aa3cad5`.
  Verification tier: `focused`
  Focused checks: Complete baseline-identical map-leaves/MCP admission/frame-prefix windows with lossless long-line presentation; reconcile canonical facts and relevant neutral evidence, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded reading leaf; no source, public-contract or infrastructure change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 5.
  Scope: `capability_conformance/map_leaves_mutation_contract.json` lines 34-461; `capability_conformance/mcp_implementation_admission.json` lines 1-250; `capability_conformance/mcp_semantic_transport/canonical_frames.jsonl` lines 1-12
  Baseline evidence: 690 fragments / 65516 decoded bytes; ordered range SHA-256 `10df429dd735f3791c7272b059b52cbf97b77fdc2ea97335fc23b39429df526d`.
  Dependencies: .1.4 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 690 fragments / 65516 bytes; ordered window SHA-256 `ae5793857ec10b86ff7d0b4a4a661b92f25ab04cccd47dfbafab966aa0d68cc2`.
  Long-line evidence: [{"path":"capability_conformance/mcp_semantic_transport/canonical_frames.jsonl","line":8,"bytes":14687,"sha256":"2d319315848ce9dfa0b3128e07a899340c83f456982c18b6a2033acb4935145f","chunks":[{"start":0,"end":6500,"bytes":6500,"sha256":"4587ea9b2d4451234a5e3de7db6517fdb41fbf8aa1114752f6a22fbd844fcf98"},{"start":6500,"end":13000,"bytes":6500,"sha256":"f66a73941fd1158905effb8d26bc6cf5566d83f362ca033fca358e450e90804c"},{"start":13000,"end":14687,"bytes":1687,"sha256":"b0ae7acde0d9fbacfbce650d2cc4fbfa7f89c7d3ebf32d978e36d98f200d5736"}]}]
  Presentation: Eleven source windows use thirteen complete presentations. Canonical frame8 is read in UTF-8 byte intervals[0,6500),[6500,13000),[13000,14687); every chunk is fully consumed and their concatenation is the exact source line. No source fragment is omitted or counted twice.
  Comprehension: The completed mutation contract fixes exact typed AST/diagnostic spans, original-root-kind traversal, copied callback frames, unrelated effects, callback rollback, shadow identity, guard release, detached boundaries and continuation after commit. Known guard/substitution repairs remain separate. MCP admission binds one transport digest, five production implementations and six runtime consumers to twelve ordered roles, with all-twenty native/MCP identity recurrence and independent primary-CLI proof. Read canonical frames cover discovery identities, two tool schemas, capabilities and rule-list request/results; inner canonical semantic JSON equals structured payload while envelopes carry runtime identity. Remaining frames and transport source inputs stay .1.6-owned.
  Verification: exact11-window and long-line three-chunk reconstruction, all143-group/302-range source ownership and cumulative reading; fresh MCP materializer35/10/10, independent validator76 and implementation/admission5/5+6/6 complete/141 proof. Map-leaves167+592 remains the unchanged-source .1.4 neutral run. No native/server execution, dependency build or fresh matrix is claimed. Source/task/history preservation, memory, Knowledge, both history checks, rendered book, git diff --check and normal doctrines govern focused landing. Canonical MCP transport and mutation-composition facts reconcile earlier pending milestones with current admission. No new runtime defect or repaired path is inferred.
  Candidate proof: Recorded11-window/three-chunk, all143-group/302-range and cumulative5-group/4790-fragment/314546-byte/21-complete-file audits PASS. Preserve2489 prior files, all prior recipe blocks,2774/2776 nodes and all94 book limitation headings; only this leaf/startup .3.8 change. Memory60, histories253/33836 and399/50893 lines/bytes, rendered book and plain git diff --check PASS. An initial history check used the read-only query command with an unsupported --check option; corrected to both COMMIT-mandated roll_document_history --check invocations, which pass. Normal doctrines govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.5 - read mutation and MCP admission with complete transport chunks`

- ID: `CONFORMANCE-SOURCE-READING.1.6`
  Status: `done`
  Activation commit: `cc278a5c692aa7da1004d51a1d7a7bcc19c3dade`.
  Verification tier: `focused`
  Focused checks: Read complete baseline-identical transport frames and inputs; reconcile canonical transport facts and unchanged-source focused proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 6.
  Scope: `capability_conformance/mcp_semantic_transport/canonical_frames.jsonl` lines 13-35; `capability_conformance/mcp_semantic_transport/corpus.json` lines 1-471; `capability_conformance/mcp_semantic_transport/schema.json` lines 1-664; `capability_conformance/mcp_semantic_transport/semantic_payloads.json` lines 1-291; `capability_conformance/mcp_semantic_transport/validator_cases.json` lines 1-51
  Baseline evidence: 1500 fragments / 63045 decoded bytes; ordered range SHA-256 `87a78c4a97a46dd8fa85dc223a0c839ef1e0f4cf89a96c0cf0c3c4580032b0d1`.
  Dependencies: .1.5 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 12 complete windows / 1500 fragments / 63045 bytes; ordered window SHA-256 `36f25017690a1060b94e9637e503b1919294cca65fb4edada0145b866bd13eb1`.
  Comprehension: Complete frames/corpus distinguish JSON-RPC rejection, tool errors and semantic ok:false results; four unavailable-handle states have identical external errors and no native dispatch. Four policy cases distinguish native identity, restricted projection and pre-dispatch denial. Ten raw cases and ten lifecycle cases cover their declared separate boundaries, without closing the known Rust combined EOF/size defect. Schema admits the corrected 72 fact keys and bounded query-contract strings, fixes two tool definitions and ordered envelopes, and keeps extensible client metadata separate from closed argument/result shapes. Three native semantic payloads plus one lowering-only capability projection retain exact canonical text/structured values. Validator definitions continue beyond line51 under .1.7.
  Verification: exact 12-window, all 143-group/302-range and cumulative reading audits; unchanged-source .1.5 MCP materialization35/10/10, transport76 and admission5/5+6/6 complete/141 evidence. No fresh native/server execution, matrix, dependency compilation or defect repair is claimed. Preserve source/task/history, check memory, Knowledge, both bounded histories, rendered book and git diff --check; normal doctrine hooks govern focused landing. Canonical MCP transport, Perl decoded-server and all-twenty correction cards reconcile these read sources; existing startup .36/.65 repairs and .5 historical ADR qualification remain open. No new defect is established.
  Candidate proof: Recorded12-window, all143-group/302-range and cumulative6-group/6290-fragment/377591-byte/25-complete-file audits PASS. Preserve2489 prior files, all prior recipe blocks,2774/2776 nodes and all94 book limitation headings; only this leaf/startup .3.8 change. Memory60, histories259/35178 and405/52077 lines/bytes, rendered book and git diff --check PASS. The unchanged-source preservation includes .1.5 transport materializer/validator/admission tools and their inputs; dated passing evidence is reused without a redundant runtime run. Normal doctrines govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.6 - complete transport corpus schema and semantic payload reading`

- ID: `CONFORMANCE-SOURCE-READING.1.7`
  Status: `done`
  Activation commit: `421f22390a01faf444454f54951816be099f576c`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical validator and contract windows; reconcile Knowledge and relevant neutral proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 7.
  Scope: `capability_conformance/mcp_semantic_transport/validator_cases.json` lines 52-343; `capability_conformance/mcp_semantic_transport_contract.json` lines 1-230; `capability_conformance/native_spec_resolution_contract.json` lines 1-311; `capability_conformance/outward_descriptor_contract.json` lines 1-127; `capability_conformance/progressive_span_dispatch_contract.json` lines 1-540
  Baseline evidence: 1500 fragments / 60106 decoded bytes; ordered range SHA-256 `a9c824478084ba0d345cc6f750a131554c686936a48531859ba614196ec78343`.
  Dependencies: .1.6 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 12 complete windows / 1500 fragments / 60106 bytes; ordered window SHA-256 `16e2f33dfee846d4d30edb88eb6644974a9877f819f338b1e1b5f3252e88385c`.
  Comprehension: Validator completion binds 28 accepted/seven rejected frames and all76 reason-classified mutations; the complete manifest fixes artifact digests, policy-component presence, canonical semantic text and lifecycle boundaries. Native resolution distinguishes exact paths from ordered nonrecursive named roots, selects the first regular file, and preserves strict UTF-8 including BOM/normalization/newlines. Outward metadata retains explicit historical/current cursor variants and fixed-v1, variadic-v2 and final-codeblock-v3 records. Progressive prefix fixes host-precompiled logical registry entries, direct same-source scalar spans, global rebasing, isolated parent state, detached results, intersected grants and stricter ceilings. Six authority cases and the cancellation prefix remain separate from known combined runtime gaps; token-replacement expectation and all later cases remain .1.8-owned.
  Verification: complete12-window/source, all143-group/302-range and cumulative reading audits; fresh native resolution14/9/4 and progressive9/9/116 plus public6/12/10/60 neutral proof. MCP35/10/10/76 and admission complete/141 remain dated unchanged-source .1.5 evidence; callable/signature evidence remains dated .1.1 proof. Preserve source/task/history and prior recipes; memory, Knowledge, both history checks, rendered book, git diff --check and normal doctrines govern focused landing. No native matrix, dependency build or runtime repair is claimed.
  Candidate proof: Recorded12-window, all143-group/302-range and cumulative7-group/7790-fragment/437697-byte/29-complete-file audits PASS. Preserve2488 prior files, prior recipe blocks,2774/2776 nodes and all94 book limitation headings; only this leaf/startup .3.8 change. Memory60, CHANGES265/36669 and notes411/53651 lines/bytes, rendered book and git diff --check PASS. Notes are at the advisory pressure threshold; no rollover is yet required and all collection limits remain unchanged. Native14/9/4 and progressive9/9/116/public6/12/10/60 results are fully consumed. Normal doctrines govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.7 - read resolution descriptor and progressive dispatch contracts`

- ID: `CONFORMANCE-SOURCE-READING.1.8`
  Status: `done`
  Activation commit: `708ecbff2b1741c666f4399986270f002b8a6162`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical progressive, punctuation, recognition and repetition windows; reconcile Knowledge and neutral proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 8.
  Scope: `capability_conformance/progressive_span_dispatch_contract.json` lines 541-1540; `capability_conformance/punctuation_light_zero_arg_contract.json` lines 1-67; `capability_conformance/recognition_transaction_contract.json` lines 1-271; `capability_conformance/repeated_action_result/explicit_or_distinct.expected.json` lines 1-1; `capability_conformance/repeated_action_result/explicit_or_distinct.input` lines 1-1; `capability_conformance/repeated_action_result/explicit_or_distinct.spec` lines 1-3; `capability_conformance/repeated_action_result_contract.json` lines 1-157
  Baseline evidence: 1500 fragments / 65525 decoded bytes; ordered range SHA-256 `685f1722e7c38726e6185295ae4d6b0cdf92d6e7eacd8735366b8dd514156397`.
  Dependencies: .1.7 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 15 complete windows / 1500 fragments / 65525 bytes; ordered window SHA-256 `5da3b2bc51d930ebca9102215b021fdde1add529083d16f943dfd18f13d56763`.
  Comprehension: Progressive completion enforces decreasing same-identity spans, independent depth/call limits, detached falsey-safe results and no parent progress; exact carrier, diagnostic, rollout and outward guards retain private scope. Punctuation aliases normalize only six standalone markers and terminal zero-argument receivers, preserving ordinary identifiers and parenthesized argument/block forms. Recognition separates strict match presence from false/zero/empty/null payloads, one attempt/terminal, invocation-owned marks, recursive effect closure and actual cursor progress. Its 138 node/250 call effects reject progressive dispatch. Explicit repetition collects one value per hit, preserves nested arrays/nulls and lifecycle whole-rule returns, and has its own accept-once-then-stop zero-width rule; that is not the recognition transaction progress rule. Repetition line157 ends inside bounded-up-to-two metadata; .1.9 owns the suffix.
  Verification: complete15-window/source, all143-group/302-range and cumulative reading audits; fresh punctuation6 standalone/4 receiver/6 invalid and recognition138/250/58, public3/26/45, guide1/14/18 plus backend admission guards. Progressive9/9/116/public6/12/10/60, repetition8/10/8-complete/54 and generated-source proof remain dated unchanged-source evidence from .1.7, .1.1 and .1.3 respectively. Preserve source/task/history and prior recipes; memory, Knowledge, both history checks, rendered book, git diff --check and normal doctrines govern focused landing. No native matrix, dependency build or runtime repair is claimed.
  Candidate proof: Recorded15-window, all143-group/302-range and cumulative8-group/9290-fragment/503222-byte/35-complete-file audits PASS. Preserve2488 prior files, prior recipe blocks,2774/2776 nodes and all94 book limitation headings; only this leaf/startup .3.8 change. Memory60, CHANGES271/38207 and notes417/55321 lines/bytes, rendered book and git diff --check PASS. Notes remain advisory-only with no required rollover. After the final book edit, fresh progressive9/9/116/public6/12/10/60 and recognition138/250/58/public3/26/45 plus all existing admission guards PASS; this direct public-projection recheck does not execute native runtimes. All results consumed; normal doctrines govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.8 - read progressive recognition and repetition boundaries`

- ID: `CONFORMANCE-SOURCE-READING.1.9`
  Status: `done`
  Activation commit: `445764d606459a8ff43ecb4c985b0a189593d3b3`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical repetition, root-selection and cursor windows; reconcile Knowledge and neutral proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 9.
  Scope: `capability_conformance/repeated_action_result_contract.json` lines 158-847; `capability_conformance/root_rule_selection_contract.json` lines 1-595; `capability_conformance/rule_local_cursor_contract.json` lines 1-160
  Baseline evidence: 1445 fragments / 65519 decoded bytes; ordered range SHA-256 `135c54aa02b37554375ab204571cd6504dd495568402b442c3bed9e8babc32fa`.
  Dependencies: .1.8 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1445 fragments / 65519 bytes; ordered window SHA-256 `efb42fa254acbed3659f9cf617be4be0ec7209de9bd814574dface3d87bd7a38`.
  Comprehension: Repeated-result completion preserves first-authored duplicate-slot choice per hit, nested arrays and null elements, zero/below-minimum results, lifecycle whole-rule overrides, exact generated-v2 family validation and selected-slot trace identity. Its Perl ten-role and peer fifteen-role admissions remain distinct from the single selected primary case. Root selection runs after structural validation and before user code, uses explicit/first-marker/first-rule precedence, and never changes authored is_top or strict-unused graph edges. Six runtime routes and the 24-document/18-denial public inventory preserve that state. Cursor prefix derives seek/consume from each child family, normalizes bare ownership after forward resolution, rejects mixed ownership and global overrides, and fixes generated-v2 families without serialized cursor policy. Rust admission roles continue beyond line160 under .1.10.
  Verification: complete11-window/source, all143-group/302-range and cumulative reading audits; fresh repetition8 modes/10 special/8 complete/54 mutations, root8 selections/3 failures/3 strict/7 complete/24 public/18 denials/54 mutations, cursor36 families/18 edges/8 parent-child/74 files/8 complete/30 public/28 denials/60 mutations. Preserve source/task/history and all prior recipes; memory, Knowledge, both history checks, rendered book, git diff --check and normal doctrines govern focused landing. No native matrix, dependency build or runtime repair is claimed.
  Candidate proof: Recorded11-window, all143-group/302-range and cumulative9-group/10735-fragment/568741-byte/37-complete-file audits PASS. Preserve2489 prior files, prior recipe blocks,2774/2776 nodes and all94 book limitation headings; only this leaf/startup .3.8 change. Memory60, CHANGES277/39652 and notes423/56903 lines/bytes, rendered book and git diff --check PASS. Notes remain advisory-only with no required rollover. Final book/projection edits pass fresh repetition8/10/8/54, root8/3/3/7/24-public/18-denials/54 and cursor36/18/8/74-files/8-complete/30-public/28-denials/60 checks. All results consumed; normal doctrines govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.9 - read repetition root selection and cursor ownership`

- ID: `CONFORMANCE-SOURCE-READING.1.10`
  Status: `done`
  Activation commit: `d4ea5c63d7d87b7b113c9ebac846b58ab700654f`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical cursor, scalar and semantic windows; reconcile Knowledge and neutral proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 10.
  Scope: `capability_conformance/rule_local_cursor_contract.json` lines 161-390; `capability_conformance/scalar_numeric_contract.json` lines 1-134; `capability_conformance/scalar_text_contract.json` lines 1-36; `capability_conformance/semantic_introspection/calls_and_staging.spec` lines 1-10; `capability_conformance/semantic_introspection/failed.spec` lines 1-2; `capability_conformance/semantic_introspection/graph.spec` lines 1-8; `capability_conformance/semantic_introspection/privacy.spec` lines 1-2; `capability_conformance/semantic_introspection/runtime.input` lines 1-1; `capability_conformance/semantic_introspection/runtime.spec` lines 1-3; `capability_conformance/semantic_introspection_contract.json` lines 1-363
  Baseline evidence: 789 fragments / 65489 decoded bytes; ordered range SHA-256 `cddda076aaee26145267ab1dbe015f1dcfc87420d1a0b3dac5ee11c5ed338308`.
  Dependencies: .1.9 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 18 complete windows / 789 fragments / 65489 bytes; ordered window SHA-256 `33e7fe4473accc2d379f3358192b9bcbf5b402ea2579579dba59409d715bcddd`.
  Comprehension: Cursor suffix completes Perl14/peer15 consumer roles, six routes, the 74-file migration inventory and eight complete rollout rows; dated pending marker strings retain historical meaning. Numeric helpers reject booleans and invalid values, enforce helper-specific arity, round halfway away from zero and use floor modulo; scalar-text instead spells booleans as 1/0 and normalizes finite numeric text. The fixed fixtures do not close Unicode-digit, unary-cat or large-number obligations. Six semantic inputs cover calls, duplicate regex identity, failed compilation, Unicode source identity and observed repetition. Semantic schema separates records, relations, shapes and signatures; canonical IDs escape strict UTF-8 bytes. Query paging uses the last primary ID, budget exhaustion returns a deterministic incomplete prefix, and source ceilings apply before native responses. All twenty exact query cases and Perl/Rust admission roles are read; Dart consumer fields continue under .1.11. The frozen scalar-text codeblock milestone is historical, not a reversal of current callable admission.
  Verification: complete 18-window/source, all 143-group/302-range and cumulative reading audits; fresh scalar-numeric 55 cases/18 helpers, Perl scalar-text 7 tests and semantic neutral checker. Preserve source/task/history and all prior recipes; memory, Knowledge, both history checks, rendered book, git diff --check and normal doctrines govern focused landing. No native matrix, dependency build or runtime repair is claimed.
  Capture recovery: Source windows14/15 were re-presented in full after a truncated tool response; only then credited. The scalar proof command was rerun to repository-local logs because its first result handle was not retained; the rerun exit and complete results were consumed.
  Candidate proof: All 18 recorded windows reconstruct exactly; all160 baseline files/143 groups/302 ranges remain identical. Cumulative10/143,11524 fragments/634230 bytes,46 complete files. Preservation compares2489 files byte-for-byte,2774/2776 nodes unchanged and all94 book limitation headings retained. Numeric55/18, Perl text7 and semantic6 groups/20 queries/128 mutations/9 complete rollout/6 complete admission pass; semantic proof repeated after the governed book edit. Memory60 lines, rendered book paragraph and plain git diff --check pass. History checks: CHANGES283 lines/40836 bytes OK; notes429/58534 WARN only, below rollover. Existing search-index warning remains owned by startup41.9. Normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.10 - read scalar contracts and semantic query prefix`

- ID: `CONFORMANCE-SOURCE-READING.1.11`
  Status: `done`
  Activation commit: `388f09aec9b7fe4c71362bae29a3f9b39b78259b`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical semantic windows; reconcile Knowledge and existing neutral proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 11.
  Scope: `capability_conformance/semantic_introspection_contract.json` lines 364-716; `capability_conformance/semantic_introspection_model.json` lines 1-201
  Baseline evidence: 554 fragments / 65425 decoded bytes; ordered range SHA-256 `ee919b4d20cab4af9531868f266b574053ceeaa3171c285db6567437f5e4ff1c`.
  Dependencies: .1.10 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 12 complete windows / 554 fragments / 65425 bytes; ordered window SHA-256 `f8479f2c2450ae6d7bcf5d7250c581a58363b088530564e8814c553f20bd2be4`.
  Comprehension: The semantic contract finishes all six admitted twelve-role consumers, the selected three-case/five-command/two-environment primary projection, 28 public surfaces, nine worked example families, 9/9 rollout and 128 mutations. These records retain their existing admission evidence rather than claiming a new native run. The model graph keeps authored duplicate slots and indexed relations distinct, with lifecycle array shape and first-marker explanations. The calls model separates function-body payload, parse job and result from generated-source-v2 handler plans; helper resolution, binding reads/writes and directed provenance remain explicit. Failed compilation retains authored identity but no compiled rule order or selected entry. Runtime events describe caller-captured slot selections and final result; queries do not run the parser. Unicode names use escaped UTF-8 IDs while byte spans differ from scalar columns. Model line201 starts the identity-limited source reference; its remaining fields and records belong to .1.12.
  Verification: reconstruct all 12 source windows and all 143 groups/302 ranges; verify cumulative reading, source/task/history preservation and prior Knowledge recipes. Recheck the semantic neutral contract after final governed documentation changes. Memory, Knowledge, both history checks, rendered book, git diff --check and normal doctrines govern focused landing. Any required engineering-history rollover preserves an exact clean-HEAD suffix under unchanged controls. No native matrix, dependency build or runtime repair is claimed.
  History rollover: Engineering notes435 lines/60214 bytes required the existing --apply workflow; root177/31917, exact clean388f09ae lines172-429 archived as258 lines/28297 bytes in segment4975-47ec3018dc4a. All30 older manifest records and targets remain exact; collection33 files/32 manifest lines/19290 bytes fits unchanged limits. Combined current-plus-archive reconstruction equals prior2868764 bytes; immutable recipe is CONFORMANCE_NOTES_HISTORY_ROLLOVER in bounded-change-notes-history-contract.
  Candidate proof: All12 windows reconstruct exactly; all160 baseline inputs/143 groups/302 ranges remain identical. Cumulative11/143,12078 fragments/699655 bytes,47 complete files. Preservation compares2486 files byte-for-byte,2774/2776 nodes unchanged, three cards retain prior recipes and all94 book limitation headings remain. Semantic6 groups/20 queries/128 mutations/9 complete rollout/6 complete admission passes after the governed edits. Memory60 lines and rendered book paragraph pass. History checks: CHANGES289 lines/42183 bytes; notes177/31917 after exact rollover. Notes collection includes the root:33 files/27121 lines/2889734 bytes, with32 manifest lines/19290 bytes, within unchanged caps. Plain diff check flags only the preserved notes177 record-separator blank at EOF; strict check of every other file and command-local blank-at-eof adjustment for DEVELOPMENT_NOTES.md preserve all historical bytes. No Git config, attributes or hooks change; normal doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.11 - read semantic rollout and model identities`

- ID: `CONFORMANCE-SOURCE-READING.1.12`
  Status: `done`
  Activation commit: `abdfb235ff8cc15829af187d4dd26b9972b684e6`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 12.
  Scope: `capability_conformance/semantic_introspection_model.json` lines 202-217; `capability_conformance/staged_ast_enrichment_contract.json` lines 1-996
  Baseline evidence: 1012 fragments / 65472 decoded bytes; ordered range SHA-256 `20ce86d11ec6bdd19057b8d37a8dd36ccd32f79cfa079026cd826bdf4f7f9c1a`.
  Dependencies: .1.11 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1012 fragments / 65472 bytes; ordered window SHA-256 `eb7cf1b80d4f38641e07e6f1f22a4b00caed402e48927f1d79dc604a09ee0f7c`.
  Comprehension: The semantic identity-limited suffix retains the same internal source/model records while query policy limits the returned detail. Staged parse_job constructs one inert dedicated marker and sidecar; scheduling follows the completed parent AST and uses only caller-frozen already-compiled entries. Direct Unicode-scalar spans and ordered derived spans materialize exact text; selected top rule enters job identity before hashing. Alias/relative collision and same-priority ambiguity are hard errors. Cache identity includes content, imports, versions, selected top and sorted capabilities. Complete-depth ordering compares path indices numerically, uses provenance/job-ID ties and queues returned jobs at the next depth. Siblings receive fresh runtime state but share decreasing budgets and fixed cancellation/deadline authority. Four result policies and three failure policies preserve exact text where appropriate; plain-data detachment, cycle/decrease and resource checks remain explicit. Five consumer sources/six routes, four carriers, 37 diagnostic shapes and nine completed rollout rows are read. Narrow function-body v1 remains separate. Ownership rows stop at Julia dormant-red; .1.13 owns the suffix and public contract.
  Verification: reconstruct all 11 source windows and all 143 groups/302 ranges; verify cumulative reading, source/task/history preservation and prior Knowledge recipes. Run focused staged neutral/public proof and semantic proof for the changed governed book surface. Memory, Knowledge, both history checks, rendered book, git diff --check and normal doctrines govern focused landing. No native matrix, dependency build, runtime repair or unrelated outward admission is claimed.
  Candidate proof: All11 windows reconstruct exactly; all160 baseline inputs/143 groups/302 ranges remain identical. Cumulative12/143,13090 fragments/765127 bytes,48 complete files. Preservation compares2490 files byte-for-byte,2774/2776 nodes unchanged, all prior Knowledge recipes and94 book limitation headings retained. Staged neutral proof passes4 entries/8 provenance/8 resolution/6 authority/10 cache/4 queue/3 isolation/4 result/3 failure/10 chain/5 detachment/5 consumers/6 routes/37 diagnostics/9 rollout/35 owners/123 mutations; public6 documents/17 denials/10 outward guards/129 mutations. Semantic6 groups/20 queries/128 mutations/9 rollout/6 admissions passes after the governed book edit. Memory60 lines, rendered book and plain git diff --check pass. History checks: CHANGES295 lines/43480 bytes and notes183/33741, both OK. Existing book search-index warning remains startup41.9-owned; normal doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.12 - read staged enrichment scheduling and policy boundaries`

- ID: `CONFORMANCE-SOURCE-READING.1.13`
  Status: `done`
  Activation commit: `a7b6ba42d639c970420fd14bf9ac03823e4b2571`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Closeout assembly repair: The first scratch closeout matched the live-status insertion instead of the book insertion and omitted five live owners. Before any commit or gate, the exact12 generated file changes were restored from clean a7b6ba42; this active leaf and completed reading evidence remain owned here. The selector now starts at the book owner, and the rebuilt candidate must update all17 expected files before preservation and focused proof.
  Goal: Read and understand conformance/test/Unicode group 13.
  Scope: `capability_conformance/staged_ast_enrichment_contract.json` lines 997-1136; `capability_conformance/standalone_lifecycle_block_contract.json` lines 1-249; `capability_conformance/typed_source_location_contract.json` lines 1-452
  Baseline evidence: 841 fragments / 65510 decoded bytes; ordered range SHA-256 `6f5ec2d872aecad8afdfe7fba6ac2c9996f67e0c121078103c767084cffdeaf6`.
  Dependencies: .1.12 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 841 fragments / 65510 bytes; ordered window SHA-256 `cbdf78b226b23bffb9e1c9dd35aca264bd1c0c81025fb6d4bf23f218df1caf15`.
  Comprehension: The staged suffix completes ownership and 123 neutral mutation IDs; its separate public checker projection remains independently governed. Standalone balanced rule-item blocks normalize to lifecycle I at the same position, preserving source/opening lines and explicit-twin ActionIR. Duplicate mixtures append in authored order; action/blind/bare edges, callable/function bodies and nested braces retain earlier ownership. Legacy plain nodes stay readable and inert. Existing Rust/Dart/Julia consumer reading limits emitted-source claims; malformed comparison strength also differs by consumer. Typed source positions use same-source Unicode-scalar offsets, with derived byte/line/column evidence; empty spans are valid and derived text retains ordered provenance. Invocation marks stay local, accepted children advance the parent cursor, and transaction tokens invalidate after one terminal action. Recursive observations use a separate detached nine-field harray, monotone IDs and no parse-wide history; ordinary child payloads retain their values. The complete92-helper/7-alias/2-internal-ID map and33 diagnostics are read, along with four recurring topologies. Typed line452 starts the combined public rollout assertion; .1.14 owns its suffix.
  Verification: reconstruct all 11 source windows and all 143 groups/302 ranges; verify cumulative reading, source/task/history preservation and prior Knowledge recipes. Run focused standalone-lifecycle/typed checks and staged/semantic proof for the changed governed book surface. Memory, Knowledge, both history checks, rendered book, git diff --check and normal doctrines govern focused landing. Existing emitted-source inspection limits, lexical repairs and runtime defects remain; no native matrix or dependency build is claimed.
  Candidate proof: Rebuilt candidate contains exactly17 expected owners; the scratch writer now asserts the owner set before writing. All11 source windows reconstruct exactly and all160 baseline inputs/143 groups/302 ranges remain unchanged. Cumulative13/143,13931 fragments/830637 bytes,50 complete files. Preservation compares2489 files byte-for-byte,2774/2776 nodes unchanged, two cards retain all prior recipes and94 book limitation headings remain. Lifecycle9 placements/4 duplicates/6 ownership/3 malformed/15 public/7 denials/14 mutations, typed3 sources/7 positions/6 spans/3 derived/8+8+33 transitions/6 observations/92+7+2 helpers/33 diagnostics/14 complete/231 mutations, staged123+129 and semantic20 queries/128 mutations all pass after final governed edits. Memory60 lines, actual rendered book and plain git diff --check pass. History checks: CHANGES301 lines/44821 bytes and notes189/35625, both OK. Existing book search-index warning remains startup41.9-owned; all normal doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.13 - read lifecycle normalization and typed source boundaries`

- ID: `CONFORMANCE-SOURCE-READING.1.14`
  Status: `done`
  Activation commit: `6bc8f569ce36642381b3cd25451ac059e1c43113`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 14.
  Scope: `capability_conformance/typed_source_location_contract.json` lines 453-814; `capability_conformance/unicode_case_contract.json` lines 1-1138
  Baseline evidence: 1500 fragments / 33332 decoded bytes; ordered range SHA-256 `5e55d60ae1deea255552eb6fc86dc89cc255313c2f76adc93e7eeca1532d1b0c`.
  Dependencies: .1.13 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 6 complete windows / 1500 fragments / 33332 bytes; ordered window SHA-256 `d52695463a085cbca3ee58975d570a8e0fed4227e1b64528963dbbac9d8d7c15`.
  Comprehension: Typed suffix completes recursive-observation public assertions, transaction and lossless-gap composition, the six-driver program-wide composition, forbidden current claims and all14 rollout rows. Each upstream contract retains its own syntax, runtime and public authority; internal capture_take_slice identifiers are not aliases and cursor restore does not roll back arbitrary effects. Unicode metadata pins all four existing gzip input identities, logical data digest and exact inventories. Lowercase prefix includes ASCII and Latin mappings, identity entries, dotted-I expansion to0069+0307, titlecase/lowercase convergence and non-adjacent mappings. Typed coordinates remain Unicode-scalar values. This source prefix does not read the remaining lower/upper/property/context/fixture arrays; line1138 ends at the01EE-to01EF value before its closing delimiters, owned next by .1.15. Offline regeneration verifies complete generated bytes but grants no physical-reading credit for those later ranges.
  Verification: reconstruct all six source windows and all 143 groups/302 ranges; verify cumulative reading, source/task/history preservation and prior Knowledge recipes. Run the offline Unicode regeneration/byte-equality/fixture checker and focused typed/lifecycle/staged/semantic checks for the changed governed book surface. Memory, Knowledge, both history checks, rendered book, git diff --check and normal doctrines govern focused landing. No native matrix, dependency build, Unicode update, normalization change or runtime repair is claimed.
  Candidate proof: Exactly17 owned files pass the pre-write guard; all six windows reconstruct exactly and all160 baseline inputs/143 groups/302 ranges remain unchanged. Cumulative14/143,15431 fragments/863969 bytes,51 complete files. Preservation compares2489 files byte-for-byte,2774/2776 nodes unchanged, two cards retain prior evidence/recipes and94 book limitation headings remain. The exact old host-probe command is retained verbatim. Unicode17.0.0 regeneration/byte-equality and12 fixtures pass with1563 lower/1581 upper/158 Cased/464 Case_Ignorable ranges. Final governed-book checks pass typed14/0/231, lifecycle9/4/6/3/public15/7/14, staged123+129 and semantic20/128. Memory60 lines, actual rendered book and plain git diff --check pass. History checks: CHANGES307 lines/46148 bytes and notes195/37289, both OK. Existing search-index warning remains startup41.9-owned; normal doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.14 - read typed closeout and Unicode case prefix`

- ID: `CONFORMANCE-SOURCE-READING.1.15`
  Status: `done`
  Activation commit: `704e261b9032d121e6ffa2d7402c648ac5e2f2ab`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 15.
  Scope: `capability_conformance/unicode_case_contract.json` lines 1139-2638
  Baseline evidence: 1500 fragments / 14500 decoded bytes; ordered range SHA-256 `84f88e75f0b8cca02f4f43134f6a3b7771231539ff88198725049d1ced86e9e1`.
  Dependencies: .1.14 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 3 complete windows / 1500 fragments / 14500 bytes; ordered window SHA-256 `3a95f86671c03196955ea22c629892bdf53e812a67bbaa7e288ffda6571f4762`.
  Comprehension: The range closes the prior01EE mapping and reads Latin extensions, Greek and Cyrillic lowercase entries through the0522-to0523 value. Examples include titlecase01F1/01F2 converging on01F3, non-adjacent023A-to2C65 and023E-to2C66, Greek03F4-to03B8 and03FD-to037B, ordinary03A3-to03C3, and Cyrillic04C0-to04CF. The default Sigma mapping does not override the separately specified Final_Sigma context. Identity rows such as01F0 and0390 preserve exact scalar sequences without normalization. The last entry closing delimiters and all later mappings remain .1.16-owned. No new casing behavior or universal native proof is inferred.
  Verification: Retain the unchanged Unicode17 generation/byte-equality/12-fixture proof from CONFORMANCE-SOURCE-READING.1.14 at704e261b; canonical Knowledge separates that proof from historical native admissions. Fresh checks reconstruct the three reading windows, all143 groups/302 ranges, cumulative coverage, source/task/history and prior recipe preservation, actual rendered book, memory and document pressure. Ordinary commit doctrines remain required. No redundant backend build, native matrix, source change or runtime repair is claimed.
  Candidate proof: Fresh reading replay and 160-input/143-group/302-range inventory pass; cumulative15/16931 fragments/878469 bytes/51 complete files. Preservation verifies2490 byte-exact files,2774 unchanged prior nodes,94 book limitation headings and all prior recipes. Memory passes at60 lines; change-history313 lines/47363 bytes and engineering-notes201 lines/38558 bytes remain below rollover. Rendered-book coverage passes; build log records successful HTML output and the already-owned large search-index warning. The previous parallel check output was truncated; fresh logged preservation, inventory, memory, cumulative and history checks completed with exit0 and were consumed. Unchanged .1.14 Unicode generation proof is retained; normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.15 - read Unicode Latin Greek and Cyrillic lowercase mappings`

- ID: `CONFORMANCE-SOURCE-READING.1.16`
  Status: `done`
  Activation commit: `d7daa22753c1a6065d26bcfaeefdb776aaabd5f8`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 16.
  Scope: `capability_conformance/unicode_case_contract.json` lines 2639-4138
  Baseline evidence: 1500 fragments / 14500 decoded bytes; ordered range SHA-256 `2a4b9375c72ac8a810bdabe84850311c7fd96cf27ef1f67b75b9a963c1a7f683`.
  Dependencies: .1.15 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 3 complete windows / 1500 fragments / 14500 bytes; ordered window SHA-256 `679062c725c2a99c850e5851adc2587f4ad11264ee326f1b4501aa731cc32a28`.
  Comprehension: The range closes the prior 0522 entry, finishes Cyrillic pairs through 052E-to-052F, reads Armenian 0531-to-0561 through 0556-to-0586 and the identity 0587 row, and then reads two distinct Georgian families: 10A0-to-2D00 through the sparse 10C7/10CD entries, and 1C90-to-10D0 through 1CBF-to-10FF. Cherokee 13A0-to-AB70 through 13EF-to-ABBF differs from the final 13F0-to-13F8 through 13F5-to-13FD group. Cyrillic 1C89-to-1C8A and Latin additional pairs follow. Exact mappings and omitted code points remain explicit, with no inferred universal offset or normalization. Line 4138 ends at the 1E3E-to-1E3F value; its closing delimiters and later mappings remain .1.17-owned.
  Verification: Retain the unchanged Unicode 17 generation, byte-equality and 12-fixture proof from CONFORMANCE-SOURCE-READING.1.14 at 704e261b. Fresh window replay, complete range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this ordinary reading leaf. Native admission evidence remains separately scoped; normal commit doctrines remain required.
  Routine artifact review: Same-volume read-only census at 2026-09-13T13:32:08Z found 1957 .log/.bin files totaling3150250302 bytes: rust/target757 files/3026026115 bytes, project-local scratch1174/39240235, and other project-local logs/cache26/84983952 bytes. No deletions. Reusable build products, verification logs and uncertain scratch remain retained under repo-generated-artifact-cleanup-boundary and startup .7; rgx, .git, symlinks and other volumes were excluded. This is a dated observation, not proof that candidates are disposable.
  Candidate proof: All three complete windows replay exactly. The unchanged 160-input/143-group/302-range inventory and cumulative16/18431 fragments/892969 bytes/51 complete files pass. Preservation verifies2490 exact files,2774 prior task nodes,all prior recipes and94 book limitation headings. Memory passes at60 lines; rendered-book coverage passes with the existing large search-index warning. History checks pass at319 lines/48419 bytes for changes and207 lines/39745 bytes for notes; diff whitespace is clean. Daily artifact census is consumed and retained without deletion. Normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.16 - read Armenian Georgian and Cherokee lowercase mappings`

- ID: `CONFORMANCE-SOURCE-READING.1.17`
  Status: `done`
  Activation commit: `e2ef71ff62406dcc82b35840e3b1d8ebc71a22fe`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 17.
  Scope: `capability_conformance/unicode_case_contract.json` lines 4139-5638
  Baseline evidence: 1500 fragments / 14500 decoded bytes; ordered range SHA-256 `7ad11f24545aaf2ee3ba1d33f29ff9531d8b1624e93e1acc74f89b5baf3d05a5`.
  Dependencies: .1.16 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 3 complete windows / 1500 fragments / 14500 bytes; ordered window SHA-256 `d29dafdc6acb01413c0a56b41534efec9ff8f519db268b8b0b40bb758d527d1e`.
  Comprehension: The range closes the prior 1E3E entry and continues Latin additional pairs through 1EFE-to-1EFF, retaining identity rows 1E96 through 1E9A and the non-adjacent 1E9E-to-00DF mapping. Greek extended rows preserve scalar results, sparse groups and lower identity entries: for example 1F88-to-1F80, 1FBC-to-1FB3, 1FCC-to-1FC3, 1FEC-to-1FE5 and 1FFC-to-1FF3. Exact table casing preserves these precomposed results without implying normalization, reversibility or the unread uppercase expansion behavior. Letterlike mappings include 2126-to-03C9, 212A-to-006B, 212B-to-00E5 and 2132-to-214E. Line 5638 ends at the 2160-to-2170 value; its closing delimiters and later mappings remain .1.18-owned.
  Verification: Retain the unchanged Unicode 17 generation, byte-equality and 12-fixture proof from CONFORMANCE-SOURCE-READING.1.14 at 704e261b. Fresh window replay, complete range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this ordinary reading leaf. Native admission evidence remains separately scoped; normal commit doctrines remain required.
  Candidate proof: Three complete windows replay exactly; full160-input/143-group/302-range inventory and cumulative17/19931 fragments/907469 bytes/51 complete files pass. Preservation verifies2490 exact files,2774 prior nodes,94 book limitation headings and all prior recipes. Memory passes at60 lines; actual rendered coverage and examples pass with the already-owned large search-index warning. Both history checks pass: changes325 lines/49501 bytes, notes213 lines/40960 bytes. Whitespace is clean; unchanged .1.14 Unicode generation proof is retained. Normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.17 - read Latin and Greek extended lowercase mappings`

- ID: `CONFORMANCE-SOURCE-READING.1.18`
  Status: `done`
  Activation commit: `90067fbfea184b29a1f5c936a5fc99df9b8d7419`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 18.
  Scope: `capability_conformance/unicode_case_contract.json` lines 5639-7138
  Baseline evidence: 1500 fragments / 14500 decoded bytes; ordered range SHA-256 `44c866b4499f10805ebccd70d094fa2c8f23baa623925827baccb887dc40fcaf`.
  Dependencies: .1.17 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 3 complete windows / 1500 fragments / 14500 bytes; ordered window SHA-256 `5dabed0b70ae515a7de3a120313ae6141d76df6eed666bb952989d6832961920`.
  Comprehension: The range closes the prior 2160 entry, completes numeral pairs 2161-to-2171 through 216F-to-217F plus 2183-to-2184, and preserves circled letters 24B6-to-24D0 through 24CF-to-24E9. Glagolitic 2C00-to-2C30 through 2C2F-to-2C5F precedes Latin mappings with non-adjacent results such as 2C62-to-026B, 2C63-to-1D7D and 2C7F-to-0240. Coptic pairs include sparse 2CEB/2CED/2CF2 rows; Cyrillic extended rows retain the gap after A66C and continue A680 through A69A. Latin extended reading includes A77D-to-1D79 and A78D-to-0265 among adjacent pairs. Circled and numeral results preserve their encoded forms; casing does not imply compatibility normalization. Line 7138 ends at the A79E-to-A79F value, whose closing delimiters and subsequent mappings remain .1.19-owned.
  Verification: Retain the unchanged Unicode 17 generation, byte-equality and 12-fixture proof from CONFORMANCE-SOURCE-READING.1.14 at 704e261b. Fresh window replay, complete range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this ordinary reading leaf. Native admission evidence remains separately scoped; normal commit doctrines remain required.
  Candidate proof: Three complete windows replay exactly; full160-input/143-group/302-range inventory and cumulative18/21431 fragments/921969 bytes/51 complete files pass. Preservation verifies2490 exact files,2774 prior nodes,94 book limitation headings and all prior recipes. Memory passes at60 lines; actual rendered coverage and circled-letter example pass with the already-owned large search-index warning. Both history checks pass: changes331 lines/50553 bytes, notes219 lines/42244 bytes. Whitespace is clean; unchanged .1.14 Unicode generation proof is retained. Normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.18 - read numeral circled and extended lowercase mappings`

- ID: `CONFORMANCE-SOURCE-READING.1.19`
  Status: `done`
  Activation commit: `bc85702ad289269970310852645ddfce35c9eecd`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 19.
  Scope: `capability_conformance/unicode_case_contract.json` lines 7139-8638
  Baseline evidence: 1500 fragments / 14848 decoded bytes; ordered range SHA-256 `2cbf40f146175f7b2ab44db632e7281fb13212e18bb824fe758ec395549d9be3`.
  Dependencies: .1.18 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 3 complete windows / 1500 fragments / 14848 bytes; ordered window SHA-256 `9fb502c030116e9846621b59fee7a01c963d0033145bbd2569b38949cf5ade7c`.
  Comprehension: The range closes the prior A79E entry and reads Latin extended mappings including A7AA-to-0266, A7B3-to-AB53, A7C4-to-A794, A7CB-to-0264 and A7DC-to-019B. Ligatures FB00 through FB06 and FB13 through FB17 retain lower identity rows. Fullwidth FF21-to-FF41 through FF3A-to-FF5A preserves width. Supplementary scalar families include 10400-to-10428 through 10427-to-1044F, 104B0-to-104D8 through 104D3-to-104FB, sparse 10570-to-10597 through 10595-to-105BC, and 10C80-to-10CC0 through 10CB2-to-10CF2. The explicit holes in the 105xx family remain authoritative. The next 10D50-to-10D70 family is read through the 10D5B-to-10D7B value at line 8638; its closing delimiters and later mappings remain .1.20-owned. Five-digit hexadecimal values denote supplementary scalars, not surrogate halves; no new native execution or width/ligature normalization is inferred.
  Verification: Retain the unchanged Unicode 17 generation, byte-equality and 12-fixture proof from CONFORMANCE-SOURCE-READING.1.14 at 704e261b. Fresh window replay, complete range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this ordinary reading leaf. Native admission evidence remains separately scoped; normal commit doctrines remain required.
  Candidate proof: Three complete windows replay exactly; full160-input/143-group/302-range inventory and cumulative19/22931 fragments/936817 bytes/51 complete files pass. Preservation verifies2490 exact files,2774 prior nodes,94 book limitation headings and all prior recipes. Memory passes at60 lines; actual rendered coverage and fullwidth example pass with the already-owned large search-index warning. Both history checks pass: changes337 lines/51597 bytes, notes225 lines/43630 bytes. Whitespace is clean; unchanged .1.14 Unicode generation proof is retained. Normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.19 - read fullwidth and supplementary lowercase mappings`

- ID: `CONFORMANCE-SOURCE-READING.1.20`
  Status: `done`
  Activation commit: `978ed9f903dee68026a35ce5885035dc9bc0541d`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 20.
  Scope: `capability_conformance/unicode_case_contract.json` lines 8639-10138
  Baseline evidence: 1500 fragments / 14781 decoded bytes; ordered range SHA-256 `6beeca8dab15540cef3744801644a02a1dc5bbfea2e7bf7f438b5f74cb19f8f4`.
  Dependencies: .1.19 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Continuity scope: Keep the Unicode coverage card bounded by replacing appended .1.15-.1.19 checkpoints with one current checkpoint. Preserve all preceding text and fenced recipes, record the exact prior Git snapshot and suffix digest, and retain every prior task node byte-for-byte. Current checkpoint is at most24 lines and future updates overwrite it. Registry capacities and native evidence remain unchanged.
  Reading evidence: 3 complete windows / 1500 fragments / 14781 bytes; ordered window SHA-256 `2109cc0d33a6577448233e5e9cb8190eed54e9882d00f155d30dcf21773ee157`.
  Comprehension: The range closes the prior 10D5B entry, finishes 10D5C-to-10D7C through 10D65-to-10D85, and reads supplementary families 118A0-to-118C0 through 118BF-to-118DF, 16E40-to-16E60 through 16E5F-to-16E7F, 16EA0-to-16EBB through 16EB8-to-16ED3, and 1E900-to-1E922 through 1E921-to-1E943. The lowercase array closes at line 9439; upper_mappings opens at 9440. Upper ASCII and Latin rows include non-adjacent 00B5-to-039C and 00FF-to-0178, expansion 00DF-to-0053+0053, identity 0130, dotless 0131-to-0049 and ordered expansion 0149-to-02BC+004E. This confirms that uppercase results cannot be obtained by simply reversing lowercase pairs. Line 10138 closes the 016F-to-016E entry; .1.21 owns subsequent entries. The uppercase suffix, properties, context rules, fixtures and decoded upstream files remain unread and task-owned.
  Verification: Retain the unchanged Unicode 17 generation, byte-equality and 12-fixture proof from CONFORMANCE-SOURCE-READING.1.14 at 704e261b. Fresh window replay, complete range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this ordinary reading leaf. Native admission evidence remains separately scoped; normal commit doctrines remain required.
  Card containment: Previous checkpoint suffix is 49 lines/2740 bytes, SHA-256 `ce75b4f8a206cb6ad0062b75ccfe2a4930ba33e9497a2a755a223bf1bc487bb3`, recoverable exactly from 978ed9f903dee68026a35ce5885035dc9bc0541d:docs/knowledge/conformance-source-reading-coverage.md starting at the .1.15 heading. Card shrinks from448 to416 lines, with one17-line current checkpoint capped at24. Preceding bytes except current status and all fenced recipes remain exact; all prior task nodes retain their full reading evidence. Future checkpoints overwrite this section; registry limits are unchanged.
  Candidate proof: Three complete windows replay exactly; full160-input/143-group/302-range inventory and cumulative20/24431 fragments/951598 bytes/51 complete files pass. Preservation verifies2490 exact files,2774 prior nodes,94 book limitation headings and all prior recipes. Independent card proof verifies exact49-line/2740-byte historical suffix recovery,448-to416 lines and current checkpoint17/24. Memory passes at60 lines; actual rendered coverage and uppercase expansion example pass with the already-owned large search-index warning. History checks report changes WARN at343 lines/52752 bytes, below required rollover, and notes OK at231 lines/44974 bytes. Whitespace is clean; unchanged .1.14 Unicode generation proof is retained. Normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.20 - complete lowercase array and read uppercase prefix`

- ID: `CONFORMANCE-SOURCE-READING.1.21`
  Status: `done`
  Activation commit: `93e5b62c4b6df38fb2812db47a52e05d20a91f7e`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 21.
  Scope: `capability_conformance/unicode_case_contract.json` lines 10139-11638
  Baseline evidence: 1500 fragments / 14528 decoded bytes; ordered range SHA-256 `871a0b608f735bef80fb454cf49b81ae74b346acae999893fa357ec5ec7c1d3c`.
  Dependencies: .1.20 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 3 complete windows / 1500 fragments / 14528 bytes; ordered window SHA-256 `021a019871b77cd33d52fa7f4f42cc19be462c9032d23d4ca3d5164c5d236a95`.
  Comprehension: The range starts with 0171-to-0170 and reads extended Latin uppercase pairs and non-adjacent targets, including 017F-to-0053, 019B-to-A7DC, 023F-to-2C7E and 0264-to-A7CB. Titlecase/lowercase 01C5/01C6 converge on 01C4, with analogous 01C8/01C9, 01CB/01CC and 01F2/01F3 groups. Expansion 01F0-to-004A+030C preserves order. Greek includes combining 0345-to-0399, 0390-to-0399+0308+0301 and 03B0-to-03A5+0308+0301; ordinary and final lowercase Sigma 03C3/03C2 both map to 03A3. Variant Greek forms retain exact non-adjacent results. Cyrillic reading runs 0430-to-0410 through 044F-to-042F and 0450-to-0400 through 045F-to-040F. Line 11638 opens the next array entry without its scalar key; .1.22 owns that continuation. These ordered full-case sequences do not imply normalization, invertibility or any new native admission.
  Verification: Retain the unchanged Unicode 17 generation, byte-equality and 12-fixture proof from CONFORMANCE-SOURCE-READING.1.14 at 704e261b. Fresh window replay, complete range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this ordinary reading leaf. Native admission evidence remains separately scoped; normal commit doctrines remain required.
  Candidate proof: Three complete windows replay exactly; full160-input/143-group/302-range inventory and cumulative21/25931 fragments/966126 bytes/51 complete files pass. Preservation verifies2490 exact files,2774 prior nodes,94 book limitation headings and all prior recipes. The single current Unicode checkpoint preserves preceding text and the historical retrieval footer within24 lines. Memory passes at60 lines; actual rendered coverage and Greek expansion example pass with the already-owned large search-index warning. History checks report changes WARN at349 lines/53826 bytes, below required rollover, and notes OK at237 lines/46327 bytes. Whitespace is clean; unchanged .1.14 Unicode generation proof is retained. Normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.21 - read Latin Greek and Cyrillic uppercase mappings`

- ID: `CONFORMANCE-SOURCE-READING.1.22`
  Status: `done`
  Activation commit: `5a2d859875a8f2993a1de630aacdf5374e15f53d`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 22.
  Scope: `capability_conformance/unicode_case_contract.json` lines 11639-13138
  Baseline evidence: 1500 fragments / 14510 decoded bytes; ordered range SHA-256 `1fe548621bf1779fe904e936b562cd512035806236c440e96006fa9ab1afac3d`.
  Dependencies: .1.21 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 3 complete windows / 1500 fragments / 14510 bytes; ordered window SHA-256 `410d6b9992183d7f59d9c4586749112535e38b75bb1677cc76b89d5edef341a0`.
  Comprehension: The range supplies the scalar key 0461 for the entry opened by .1.21, then reads Cyrillic rows through 052F-to-052E, including the non-adjacent 04CF-to-04C0 mapping. Armenian 0561-to-0531 through 0586-to-0556 is followed by ordered expansion 0587-to-0535+0552; the lower identity row does not imply an uppercase identity. Georgian 10D0-to-1C90 through 10FF-to-1CBF retains the sparse 10FA-to-10FD transition. Short Cherokee rows 13F8-to-13F0 through 13FD-to-13F5 precede Cyrillic variants 1C80 through 1C8A, including shared 1C84/1C85-to-0422 and non-adjacent 1C88-to-A64A. Latin non-adjacent 1D79-to-A77D, 1D7D-to-2C63 and 1D8E-to-A7C6 precede additional pairs through the fully closed 1E5B-to-1E5A entry at line 13138. Later uppercase entries remain .1.23-owned; no normalization, reversibility or new native proof is inferred.
  Verification: Retain the unchanged Unicode 17 generation, byte-equality and 12-fixture proof from CONFORMANCE-SOURCE-READING.1.14 at 704e261b. Fresh window replay, complete range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this ordinary reading leaf. Native admission evidence remains separately scoped; normal commit doctrines remain required.
  Candidate proof: Three complete windows replay exactly; full160-input/143-group/302-range inventory and cumulative22/27431 fragments/980636 bytes/51 complete files pass. Preservation verifies2490 exact files,2774 prior nodes,94 book limitation headings and all prior recipes. The single current Unicode checkpoint preserves preceding text and the historical retrieval footer within24 lines. Memory passes at60 lines; actual rendered coverage and Armenian expansion example pass with the already-owned large search-index warning. History checks report changes WARN at355 lines/54916 bytes, below required rollover, and notes OK at243 lines/47691 bytes. Whitespace is clean; unchanged .1.14 Unicode generation proof is retained. Normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.22 - read Cyrillic Armenian and Georgian uppercase mappings`

- ID: `CONFORMANCE-SOURCE-READING.1.23`
  Status: `done`
  Activation commit: `f1c84738402881b281a897f33eb001c8c0111b3f`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 23.
  Scope: `capability_conformance/unicode_case_contract.json` lines 13139-14638
  Baseline evidence: 1500 fragments / 15108 decoded bytes; ordered range SHA-256 `2715613a708624c2b9a4025d923915536a1856fbb4be08b98570748d73c68517`.
  Dependencies: .1.22 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 3 complete windows / 1500 fragments / 15108 bytes; ordered window SHA-256 `e2b714554edc304cbce1495adb3d94e6414fcdac67b6dca10c84637cec566a8c`.
  Comprehension: The range starts with 1E5D-to-1E5C, reads Latin additional pairs and expansions 1E96-to-0048+0331, 1E97-to-0054+0308, 1E98-to-0057+030A, 1E99-to-0059+030A and 1E9A-to-0041+02BE, plus non-adjacent 1E9B-to-1E60. Greek extended rows retain single precomposed results alongside ordered expansions such as 1F52-to-03A5+0313+0300 and 1F56-to-03A5+0313+0342. Lowercase/titlecase families 1F80/1F88, 1F90/1F98 and 1FA0/1FA8 converge on the same uppercase sequences ending in 0399. Further examples include 1FB7-to-0391+0342+0399, 1FD7-to-0399+0308+0342 and 1FF7-to-03A9+0342+0399. Exact scalar order is part of the full mapping, not an inferred normalization pass. Letterlike 214E-to-2132 and the fully closed numeral 2170-to-2160 entry end the range at line 14638. All subsequent entries remain .1.24-owned; no new native admission or runtime repair is claimed.
  Verification: Retain the unchanged Unicode 17 generation, byte-equality and 12-fixture proof from CONFORMANCE-SOURCE-READING.1.14 at 704e261b. Fresh window replay, complete range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this ordinary reading leaf. Native admission evidence remains separately scoped; normal commit doctrines remain required.
  Candidate proof: Three complete windows replay exactly; full160-input/143-group/302-range inventory and cumulative23/28931 fragments/995744 bytes/51 complete files pass. Preservation verifies2490 exact files,2774 prior nodes,94 book limitation headings and all prior recipes. The single current Unicode checkpoint preserves preceding text and the historical retrieval footer within24 lines. Memory passes at60 lines; actual rendered coverage and ordered Greek expansion example pass with the already-owned large search-index warning. History checks report changes WARN at361 lines/56024 bytes, below required rollover, and notes OK at249 lines/49081 bytes. Whitespace is clean; unchanged .1.14 Unicode generation proof is retained. Normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.23 - read Latin and Greek full uppercase expansions`

- ID: `CONFORMANCE-SOURCE-READING.1.24`
  Status: `done`
  Activation commit: `a4c9bd63e5127bff0b92d49dfd4bfdad15b04ebd`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 24.
  Scope: `capability_conformance/unicode_case_contract.json` lines 14639-16138
  Baseline evidence: 1500 fragments / 14500 decoded bytes; ordered range SHA-256 `26faa08194e1e3baf3ebe01eb0716ee4b3aac00bd6609c84cdc7cd76398956b8`.
  Dependencies: .1.23 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 3 complete windows / 1500 fragments / 14500 bytes; ordered window SHA-256 `da0f981a438d7c7498c1dd08b17bb18559b1a199f681901afc7661b15829ed56`.
  Comprehension: The range begins at 2171-to-2161, completes numeral pairs through 217F-to-216F plus 2184-to-2183, and reads circled 24D0-to-24B6 through 24E9-to-24CF. Glagolitic 2C30-to-2C00 through 2C5F-to-2C2F precedes Latin rows including non-adjacent 2C65-to-023A and 2C66-to-023E. Coptic pairs preserve sparse 2CEC-to-2CEB, 2CEE-to-2CED and 2CF3-to-2CF2 entries. Georgian 2D00-to-10A0 through 2D25-to-10C5 plus 2D27-to-10C7 and 2D2D-to-10CD retains its own uppercase family and holes. Cyrillic extended A641 through A69B and Latin extended A723 through the fully closed A74F-to-A74E entry follow; line 16138 closes that entry. Encoded numeral and circled forms remain intact under casing. Later uppercase mappings remain .1.25-owned, with no normalization or native admission claim.
  Verification: Retain the unchanged Unicode 17 generation, byte-equality and 12-fixture proof from CONFORMANCE-SOURCE-READING.1.14 at 704e261b. Fresh window replay, complete range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this ordinary reading leaf. Native admission evidence remains separately scoped; normal commit doctrines remain required.
  Candidate proof: Three complete windows replay exactly; full160-input/143-group/302-range inventory and cumulative24/30431 fragments/1010244 bytes/51 complete files pass. Preservation verifies2490 exact files,2774 prior nodes,94 book limitation headings and all prior recipes. The single current Unicode checkpoint preserves preceding text and the historical retrieval footer within24 lines. Memory passes at60 lines; actual rendered coverage and sparse Georgian examples pass with the already-owned large search-index warning. History checks report changes WARN at367 lines/57114 bytes, below required rollover, and notes OK at255 lines/50372 bytes. Whitespace is clean; unchanged .1.14 Unicode generation proof is retained. Normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.24 - read numeral circled and extended uppercase mappings`

- ID: `CONFORMANCE-SOURCE-READING.1.25`
  Status: `done`
  Activation commit: `66c75ec5c83c00880cfaed4bb7ca4921b003a1a6`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 25.
  Scope: `capability_conformance/unicode_case_contract.json` lines 16139-17638
  Baseline evidence: 1500 fragments / 14739 decoded bytes; ordered range SHA-256 `4e8f093eada059c9b5c6771609668311eeb7ccd8186f2b1d3a3c4d9e04fe7443`.
  Dependencies: .1.24 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 3 complete windows / 1500 fragments / 14739 bytes; ordered window SHA-256 `f65676f526dc1c78430fcc1bcc5b5612a2f702728976df6379c0c9123b12ba86`.
  Comprehension: The range starts at A751-to-A750, reads further Latin pairs including non-adjacent A794-to-A7C4 and AB53-to-A7B3, and completes Cherokee AB70-to-13A0 through ABBF-to-13EF. Latin ligatures expand as FB00-to-0046+0046, FB01-to-0046+0049, FB02-to-0046+004C, FB03-to-0046+0046+0049, FB04-to-0046+0046+004C, with FB05/FB06 both mapping to 0053+0054. Armenian FB13 through FB17 retain their respective ordered two-scalar results. Fullwidth FF41-to-FF21 through FF5A-to-FF3A preserves width. Supplementary 10428-to-10400 through 1044F-to-10427 is followed by the 104D8-to-104B0 family, read through the 104F8-to-104D0 value at line 17638. Its closing delimiters and all later mappings remain .1.26-owned. Full casing can expand ligatures while preserving other encoded forms; it does not imply blanket compatibility normalization or new native admission.
  Verification: Retain the unchanged Unicode 17 generation, byte-equality and 12-fixture proof from CONFORMANCE-SOURCE-READING.1.14 at 704e261b. Fresh window replay, complete range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this ordinary reading leaf. Native admission evidence remains separately scoped; normal commit doctrines remain required.
  Candidate proof: Three complete windows replay exactly; full160-input/143-group/302-range inventory and cumulative25/31931 fragments/1024983 bytes/51 complete files pass. Preservation verifies2490 exact files,2774 prior nodes,94 book limitation headings and all prior recipes. The single current Unicode checkpoint preserves preceding text and the historical retrieval footer within24 lines. Memory passes at60 lines; actual rendered coverage and ligature expansion examples pass with the already-owned large search-index warning. History checks report changes WARN at373 lines/58217 bytes, below required rollover, and notes OK at261 lines/51747 bytes. Whitespace is clean; unchanged .1.14 Unicode generation proof is retained. Normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.25 - read Cherokee ligature and supplementary uppercase mappings`

- ID: `CONFORMANCE-SOURCE-READING.1.26`
  Status: `done`
  Activation commit: `38c45c2883d9932f38ec4a511130c1f5bd94de1b`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 26.
  Scope: `capability_conformance/unicode_case_contract.json` lines 17639-19138
  Baseline evidence: 1500 fragments / 14999 decoded bytes; ordered range SHA-256 `60079fbb3044976bc23788a9f8c61b6236978340a87ead8d398d297a680f0419`.
  Dependencies: .1.25 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  History closeout scope: Apply only a mechanically required change-history rollover from exact clean-HEAD suffix records. Preserve all earlier archive bytes and manifest records, verify complete hot-root plus archive reconstruction, and retain unchanged registry limits. This required continuity work belongs to this reading leaf; no source or canonical boundary is introduced.
  Reading evidence: 3 complete windows / 1500 fragments / 14999 bytes; ordered window SHA-256 `30c7169b7455215b3e93442b8ec866e502d52311d744013d8c20f0a0f38e8cf5`.
  Comprehension: The range closes the prior 104F8 entry, finishes 104F9-to-104D1 through 104FB-to-104D3, and reads sparse 10597-to-10570 through 105BC-to-10595. Supplementary families 10CC0-to-10C80 through 10CF2-to-10CB2, 10D70-to-10D50 through 10D85-to-10D65, 118C0-to-118A0 through 118DF-to-118BF, 16E60-to-16E40 through 16E7F-to-16E5F, 16EBB-to-16EA0 through 16ED3-to-16EB8 and 1E922-to-1E900 through 1E943-to-1E921 retain exact scalar values and holes. The uppercase array closes at line 19045; cased_ranges opens at 19046. Reading includes the first 23 range pairs, from ASCII 0041-005A and 0061-007A through 03A3-03F5, including singleton 00AA/00B5/00BA/0345 entries. Property classification remains distinct from case-conversion sequences. Line 19138 closes the 03A3-03F5 range; later Cased/Case_Ignorable ranges, context rules, fixtures and upstream inputs remain task-owned. Completing these mapping arrays grants no new runtime or native admission.
  Verification: Retain the unchanged Unicode 17 generation, byte-equality and 12-fixture proof from CONFORMANCE-SOURCE-READING.1.14 at 704e261b. Fresh window replay, complete range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this ordinary reading leaf. Native admission evidence remains separately scoped; normal commit doctrines remain required. Required change-history rollover proof verifies the exact prior source suffix, all older archive and manifest records, and complete hot-root plus archive reconstruction without raising limits.
  History evidence: Required candidate379 lines/59584 bytes becomes156 lines/31451 bytes. New docs/history/changes/segment-4975-3da9552f81c9.md is exactly clean38c45c2883d9932f38ec4a511130c1f5bd94de1b CHANGES151-373:223 lines/28133 bytes; source blob5283852d3718ed3600ca9f4bb39f78f4b66f5d3e; SHA-256 `3da9552f81c93de15c4add8d42685f2880d29a0361026a7f29cdb677faaa54a0`. All35 older manifest records and targets remain exact. Collection38 files/49979 lines/3661922 bytes and manifest37 lines/21071 bytes meet unchanged limits. Actual archive-reader output plus current root, minus only the new leaf entry, reconstructs prior3639484 bytes exactly, SHA-256 `cdd90e7085fe008777fbfe64259b8a0c0b8ee40b80467cce842026473b8c9a6a`. Current whitespace check passes without exceptions. The bounded history card retains a replayable immutable source/segment proof.
  Candidate proof: All three complete windows replay exactly. The 160-input/143-group/302-range inventory and cumulative 26 groups / 33,431 fragments / 1,039,982 bytes / 51 complete files pass. Preservation verifies 2,488 exact files, 2,774 prior task nodes, 94 book limitation headings and every prior recipe. Exact rollover source/segment proof and full history reconstruction pass, retaining all 35 older records within unchanged collection limits. The current checkpoint remains bounded with its preceding text and historical footer preserved. Memory passes at 60 lines; rendered-book coverage and property classification examples pass with the already-owned large search-index warning. History checks report changes OK at 156 lines / 31,451 bytes and notes WARN at 267 lines / 53,421 bytes, below required rollover. Whitespace is clean without exceptions. Unchanged .1.14 Unicode generation proof is retained; normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.26 - complete case mapping arrays and begin property ranges`

- ID: `CONFORMANCE-SOURCE-READING.1.27`
  Status: `done`
  Activation commit: `0660046fb9b9afdc2f6e8266c404139f261763b8`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 27.
  Scope: `capability_conformance/unicode_case_contract.json` lines 19139-20638
  Baseline evidence: 1500 fragments / 15135 decoded bytes; ordered range SHA-256 `ee8c604e1d052100655a1374f5512223f967ae6dd1033dbd684e946dc0340f65`.
  Dependencies: .1.26 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Knowledge scope: Add direct overlap/context questions to the existing Lua property-audit card so its already-established Cased/Case_Ignorable overlap fact is discoverable. Preserve its entire dated narrative, native evidence and reproduction recipe exactly; no new native execution or defect claim is required.
  Reading evidence: 3 complete windows / 1500 fragments / 15135 bytes; ordered window SHA-256 `62b0d78fd9dfd8d79b667c923038c2166421acad1d9e29a04784a761e90cd9e1`.
  Comprehension: The range reads the remaining 135 Cased intervals from 03F7-0481 through 1F170-1F189, completing all 158 entries at line 19679. Exact holes, singleton entries and supplementary mathematical/letterlike ranges remain explicit. Case_Ignorable opens at 19680 and includes punctuation 0027/002E/003A, combining and modifier ranges, script-specific marks, format controls, and later ranges through the 239th complete pair A825-A826. Line 20638 gives the next lower endpoint A82C; its upper endpoint and closure remain .1.28-owned. Cased and Case_Ignorable are not disjoint: 2071 and 207F occur in both, as does 0345 through the broader ignorable interval. Knowledge retrieval resolves the existing Lua .1.28 audit, which already documents skipping overlapping ignorable scalars before testing surrounding Cased context and retains its dated property-boundary/native results. The initial card output truncated part of its embedded recipe; a complete bounded follow-up supplied those bytes, with no new source-reading credit or execution claimed. Current work adds direct retrieval questions only; later ranges, context-rule and fixture source remain unread.
  Verification: Retain the unchanged Unicode 17 generation, byte-equality and 12-fixture proof from CONFORMANCE-SOURCE-READING.1.14 at 704e261b. Fresh window replay, complete range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this ordinary reading leaf. Native admission evidence remains separately scoped; normal commit doctrines remain required.
  Candidate proof: All three complete windows replay exactly. The 160-input/143-group/302-range inventory and cumulative 27 groups / 34,931 fragments / 1,055,117 bytes / 51 complete files pass. Scoped data assertions verify all 158 Cased ranges, the exact first 239 complete ignorable pairs, crossing lower endpoint A82C, and overlap examples 0345/2071/207F within read data. Preservation verifies 2,490 exact files, 2,774 prior task nodes, 94 book limitation headings and every prior recipe. The Lua card differs only by its two new retrieval questions; dated native evidence remains exact. The current checkpoint is bounded. Memory passes at 60 lines; rendered coverage and overlap example pass with the already-owned large search-index warning. History checks report changes OK at 162 lines / 32,666 bytes and notes WARN at 273 lines / 55,119 bytes, below required rollover. Whitespace is clean; unchanged generation and dated context proof are retained. Normal commit doctrines remain required.
  Commit: `CONFORMANCE-SOURCE-READING.1.27 - complete Cased ranges and read Case Ignorable prefix`

- ID: `CONFORMANCE-SOURCE-READING.1.28`
  Status: `done`
  Activation commit: `7f0d7ffd3b40c0fed3f24088750e69f32615e30f`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 28.
  Scope: `capability_conformance/unicode_case_contract.json` lines 20639-21621; `capability_conformance/unicode_rule_label_contract.json` lines 1-517
  Baseline evidence: 1500 fragments / 17109 decoded bytes; ordered range SHA-256 `20287f9706225c05dbb4d480ca10ab9c37e0ca0cdc032340616073f1ddb68ed8`.
  Dependencies: .1.27 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 3 complete windows / 1500 fragments / 17109 bytes; ordered window SHA-256 `1037e3515d1483911ffebcdb419a90369abc6d0ef6abf2ce8f82ad51bc6186ef`.
  Comprehension: The casing suffix closes A82C, continues through supplementary marks, modifiers and format characters, and ends Case_Ignorable at E0100-E01EF. Together with earlier leaves all 158 Cased and 464 Case_Ignorable ranges are read. The separate Final_Sigma context record maps 03A3 to 03C2; 12 fixtures distinguish expansion, supplementary pairs, cased context before/after ignorable scalars and no implicit normalization. The rule-label policy uses one or more XID_Continue scalars, including the first position, with exact case-sensitive scalar identity, no normalization or case mapping and strict UTF-8 at the boundary. Metadata pins Unicode17.0.0, upstream hashes and 806 ranges/9 positive/8 negative/2 distinct fixtures. The physically read prefix contains 119 complete ranges through 0B85-0B8A plus the next lower endpoint 0B8E; its remaining bytes are .1.29-owned. Existing unicode-rule-label-contract and Lua property-reading cards already own the semantics; this reading adds no native admission or broader identifier policy.
  Verification: Fresh managed tools/check_unicode_rule_label_contract.py passes offline regeneration and byte comparison at Unicode17.0.0, 806 ranges, 9 positive, 8 negative and 2 distinct pairs. Retain unchanged casing generation/12-fixture proof from .1.14 at 704e261b. Fresh window replay, full range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this focused leaf. Native proofs remain separately scoped; normal commit doctrines remain required.
  Candidate proof: All three source windows were consumed completely; the initially lost casing output received no credit and both windows were re-presented separately before marking read. Window replay and all160 baseline inputs/143 groups/302 ranges pass; independent cumulative coverage is28 groups/36431 fragments/1072226 bytes/52 complete files, with only rule-label data partial. Preservation passes2491 byte-exact files,2774 unchanged prior nodes, all94 book limitation headings and the bounded checkpoint/footer. Fresh offline label regeneration806/9/8/2, rendered book, memory60 and plain diff checks pass. CHANGES168lines/33839bytes is OK; notes279lines/56775bytes is WARN without required rollover. Known book-index warning remains startup41.9-owned. No new native run, full CI, dependency build or push.
  Commit: `CONFORMANCE-SOURCE-READING.1.28 - complete casing contract and read rule-label policy`

- ID: `CONFORMANCE-SOURCE-READING.1.29`
  Status: `done`
  Activation commit: `ddbdbbc9a442d48ea150224d4ae45bfa1303b6cb`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 29.
  Scope: `capability_conformance/unicode_rule_label_contract.json` lines 518-2017
  Baseline evidence: 1500 fragments / 15123 decoded bytes; ordered range SHA-256 `f993abf7d64e771d8d6462592c0853d61a40d719557d03fbf97de8a2e445b4ba`.
  Dependencies: .1.28 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 3 complete windows / 1500 fragments / 15123 bytes; ordered window SHA-256 `d518b14ad913408a7545acfbf884068052fbb5015941cd3e027244f36dcdefff`.
  Comprehension: The first window closes the crossing 0B8E-0B90 interval and continues through Indic, Southeast Asian, Tibetan, Georgian, Ethiopic and other ranges. Membership retains exact sparse gaps and singleton entries. Later rows include join controls200C-200D, letterlike symbols, CJK3400-4DBF and4E00-A48C, HangulAC00-D7A3 and extension ranges, compatibility ideographs, Latin/Armenian ligatures, fullwidth forms and supplementary scripts. These are membership intervals under the already-read exact-scalar/no-normalization policy, not conversion mappings or a blanket script/block acceptance rule. Reading completes494 of806 intervals through10A38-10A3A, then consumes only the next lower endpoint10A3F at2017. Its upper endpoint/closure and later data remain .1.30-owned. Existing unicode-rule-label-contract owns policy and generated authority; unchanged .1.28 neutral proof does not add native runtime admission.
  Verification: Retain the unchanged managed offline rule-label regeneration/byte-comparison proof from CONFORMANCE-SOURCE-READING.1.28 at ddbdbbc9a: Unicode17.0.0,806 ranges,9 positive,8 negative and2 distinct fixtures. Fresh complete-window replay, full source/range inventory, cumulative coverage, source/task/history preservation, rendered book, memory and bounded-history checks govern this ordinary reading leaf. Native evidence stays separately scoped; normal commit doctrines remain required.
  Candidate proof: All three windows consumed completely; replay passes1500 fragments/15123 bytes. Full160-input/143-group/302-range inventory remains baseline-identical. Independent cumulative coverage is29 groups/37931 fragments/1087349 bytes/52 complete files, with only rule-label data partial. The read prefix independently contains494 complete intervals through10A38-10A3A and crossing lower endpoint10A3F. Preservation passes2491 exact files,2774 unchanged prior nodes, all94 book limitations and the bounded Knowledge checkpoint/footer. Rendered book, memory60 and plain diff checks pass; CHANGES174lines/34929bytes OK, notes285lines/58296bytes WARN without required rollover. Unchanged .1.28 label generation proof retained; known book-index warning remains startup41.9-owned. No native run, full CI, dependency build or push.
  Commit: `CONFORMANCE-SOURCE-READING.1.29 - read rule-label ranges through supplementary scripts`

- ID: `CONFORMANCE-SOURCE-READING.1.30`
  Status: `done`
  Activation commit: `1fe980f972a650b77e7f1e55e18da67e4f12a8f5`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 30.
  Scope: `capability_conformance/unicode_rule_label_contract.json` lines 2018-3349; `capability_conformance/uniform_binding_contract.json` lines 1-168
  Baseline evidence: 1500 fragments / 23627 decoded bytes; ordered range SHA-256 `d8b23804652a86775f9841bb1b8a6fd2466fdc04ff0a4c207d965d4a0d6da69c`.
  Dependencies: .1.29 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 5 complete windows / 1500 fragments / 23627 bytes; ordered window SHA-256 `ad4ba08e8617b356293703d969129f29fe12b70e2398482309be72dca062f586`.
  Comprehension: Rule-label reading closes the crossing 10A3F singleton, all remaining supplementary and CJK extension intervals, and the final E0100-E01EF range. All 806 ranges are now read. Nine positive fixtures include digit/underscore starts, precomposed/decomposed spellings, middle dot and supplementary scalars; eight negative whole labels and two case/normalization identity pairs complete the file. The binding prefix defines one observable typed value per ASCII identifier. set returns its post-assignment value; mutable operations yield the updated target unless their callable contract says otherwise. Absent aggregate targets may create the required empty kind; incompatible existing values fail. Static rule names retain push precedence. Exact one-bare-name array/hash calls are retired even when constructor-intended; quoted, computed, empty and multi-argument forms remain. All seven execution cases, six invalid selectors, eight valid constructors and the fixture steps through line168 are read; final fixture expectations/closures remain .1.31-owned. Canonical neutral guidance has stale future rollout wording; new .2.1 owns repair without rewriting dated native evidence.
  Verification: Fresh managed tools/check_uniform_binding_contract.py passes 11 migrations, 7 executions, 6 invalid selectors and 8 constructors, including deterministic full fixture validation without granting reading credit beyond168. Retain unchanged offline rule-label generation/byte-comparison proof from .1.28 at ddbdbbc9a. Fresh window replay, complete inventory, cumulative coverage, source/task/history preservation, rendered book, memory and bounded-history checks govern this focused reading leaf. Normal doctrines remain required; no new native or admission result.
  History preservation: Required engineering-notes rollover moves only clean 1fe980f97 lines133-285,153 lines/27728 bytes, into segment4974-99c831091c2b. Source blob50c39acf5a76bebe6d2d6f3f1d84a98a88c05021 and SHA99c831091c2b5cd4287db01a1668be24f4e01426bedb6001b43b969fb7684abb match. All31 older manifest records/targets and the prior card body remain exact. Actual reader plus current root, minus only this leaf record, reconstruct2896823 prior bytes, SHA9b69ee7450e96fad466c2ee0c68a54d52818eb0214df84c15db6681f6347ac74. Collection34files/27236lines/2918591bytes and manifest33lines/19902bytes stay within unchanged limits, reaching file/manifest caps. Durable replay: CONFORMANCE_BINDING_NOTES_ROLLOVER in bounded-change-notes-history-contract.
  Candidate proof: Five complete windows pass replay at1500 fragments/23627 bytes; all160 baseline inputs/143 groups/302 ranges remain exact. Independent cumulative reading is30 groups/39431 fragments/1110976 bytes/53 complete files, with only uniform-binding data partial. Preservation passes2489 byte-exact prior files,2773 unchanged prior nodes, all94 book limitations, old card recipes and the bounded checkpoint/footer; only this leaf, startup3.8 and finding parent2 change, with exactly three pending repair nodes added. Task metadata passes2779 unique current IDs,37 partition and10 ID self-tests. Neutral binding11/7/6/8, rendered book, memory60, both final history checks and plain diff checks pass. Final CHANGES180lines/36219bytes and notes138lines/32434bytes are OK. New conformance-uniform-binding-reading records the guidance discrepancy; historical cards remain exact. Known book-index warning remains startup41.9-owned. No native run, full CI, dependency build or push.
  Commit-gate correction: The first pre-commit attempt passed eight doctrines but rejected active_memory at8876/8192 bytes because the generated next action duplicated .1.31's25-path scope. No commit landed. Replace only MEMORY's next-action value with a stable-ID/task-tree pointer and concise scope summary; every exact range remains in .1.31 and the other frontier records. Memory is60 lines/7516 bytes; no cap or checker changes. Fresh staged memory and README routing/stability checks pass, including32 mutation classes. The normal commit gate must pass on the corrected candidate.
  Commit: `CONFORMANCE-SOURCE-READING.1.30 - complete rule-label data and read uniform-binding contract`

- ID: `CONFORMANCE-SOURCE-READING.1.31`
  Status: `done`
  Activation commit: `74ecae96ebe59e4d40856ea62ee6ba2f73eea4ff`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 31.
  Scope: `capability_conformance/uniform_binding_contract.json` lines 169-179; `capability_conformance/write_map_leaves_composition_contract.json` lines 1-279; `capability_conformance/write_vivification_contract.json` lines 1-551; `cli_conformance/README.md` lines 1-136; `cli_conformance/cases/failure/stderr.txt` lines 1-1; `cli_conformance/cases/help/stdout.txt` lines 1-50; `cli_conformance/cases/success/input.txt` lines 1-1; `cli_conformance/cases/success/nested.spec` lines 1-5; `cli_conformance/cases/trace/appended_low.txt` lines 1-7; `cli_conformance/cases/trace/debug_emoji_stdout.txt` lines 1-12; `cli_conformance/cases/trace/failure_input_low.txt` lines 1-4; `cli_conformance/cases/trace/failure_invoke_escaped_medium.txt` lines 1-7; `cli_conformance/cases/trace/failure_invoke_low.txt` lines 1-6; `cli_conformance/cases/trace/failure_low.txt` lines 1-2; `cli_conformance/cases/trace/full.txt` lines 1-10; `cli_conformance/cases/trace/full_stdout.txt` lines 1-11; `cli_conformance/cases/trace/high_stdout.txt` lines 1-10; `cli_conformance/cases/trace/high_utf8_stdout.txt` lines 1-10; `cli_conformance/cases/trace/low.txt` lines 1-6; `cli_conformance/cases/trace/low_emoji.txt` lines 1-6; `cli_conformance/cases/trace/low_stdout.txt` lines 1-7; `cli_conformance/cases/trace/medium_stdout.txt` lines 1-8; `cli_conformance/cases/trace/stale.txt` lines 1-1; `cli_conformance/cases/usage/stderr.txt` lines 1-52; `cli_conformance/manifest.json` lines 1-33
  Baseline evidence: 1226 fragments / 65536 decoded bytes; ordered range SHA-256 `46bcea6e2c386c833619c7de753c78fac9d9d74b90b549cad7fde095626a6908`.
  Dependencies: .1.30 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 32 complete windows / 1226 fragments / 65536 bytes; ordered window SHA-256 `5367bdcaef3b98df9a837828a03650bbfc4f9eb853daadbf1e26883543e47912`.
  Comprehension: Uniform-binding EOF fixes the final fixture output: ordered items b/a, split parts a/b, meta count2 and sorted first a. Write/map composition reads all six callbacks and one continuation: detached replacement is not revisited; unrelated writes survive later failure; receiver identity blocks nested writes before segment/RHS evaluation; distinct shadow bindings remain independent; continuation failure preserves the earlier receiver commit. Nested writes evaluate segments left to right then RHS before typed selector/structural validation, snapshot the resulting binding, build on an isolated copy, keep arrays dense, distinguish absent from bound null and preserve completed expression effects on structural failure. Every syntax, success, structural/evaluation failure, read exclusion and detachment fixture is read. Frozen future-neutral strings are intentionally retained by later admission and public owners. The CLI guide specifies strict schema/placeholders and raw byte comparison; help/errors and trace templates fix phase order, routing, escaping, emoji and UTF-8 byte counts. Manifest1-33 includes help/help_short and opens the next case; later cases remain .1.32-owned. Existing canonical facts own these mechanisms; new .2.2 tracks only the standalone example missing managed-storage setup. Targeted runner lines1-42/342-346 diagnose that documentation dependency without advancing tools-source reading.
  Verification: Fresh managed write checker passes 5 valid/7 invalid syntax,11 success,16 structural and3 evaluation failures,3 read exclusions,8 composed writes and105 rejected mutations. Map checker passes4 valid/14 invalid syntax,5 exclusions,10 success,8 pre-commit failures,6 callback/1 continuation compositions and167+592 rejected mutations. Managed Perl help/help_short passes2/2. Retain unchanged uniform-binding proof from .1.30 at74ecae96e. Complete-window replay, inventory, cumulative coverage, preservation, book, memory and history checks govern this focused leaf; no full matrix or new cross-backend admission is claimed.
  Candidate proof: All32 inventoried source windows consumed completely; replay confirms1226 fragments/65536 bytes. All160 baseline inputs/143 groups/302 ranges remain exact. Independent cumulative reading is31 groups/40657 fragments/1176512 bytes/77 complete files, with only CLI manifest partial. Preservation passes2493 exact prior files,2776 unchanged prior nodes, all94 book limitation headings and every prior Knowledge recipe/footer. Only this leaf, startup3.8 and finding parent2 change; exactly .2.2/.2.2.1/.2.2.2 are new. The single bounded checkpoint heading changes from Unicode to Conformance without losing prior text or exceeding24 lines. Fresh neutral write105 and map167+592 mutation rejection, Perl help2/2, rendered book and memory60lines/7380bytes pass. CHANGES186lines/37595bytes and notes144lines/34612bytes are OK; plain diff check passes. Known book-index warning remains startup41.9-owned. No unmanaged allocation, full matrix, canonical CI, dependency build or push.
  Commit: `CONFORMANCE-SOURCE-READING.1.31 - read write composition and CLI fixture contracts`

- ID: `CONFORMANCE-SOURCE-READING.1.32`
  Status: `done`
  Activation commit: `62f79df1aa84da1c7c1c5dea01c78a73508c305c`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 32.
  Scope: `cli_conformance/manifest.json` lines 34-1150; `t/actionir_ast_parser.t` lines 1-383
  Baseline evidence: 1500 fragments / 55235 decoded bytes; ordered range SHA-256 `a18d6759757376a16e4e9227fe577ddbfb412e5e907e4b4f4ec1cac9264a2b7f`.
  Dependencies: .1.31 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 9 complete windows / 1500 fragments / 55235 bytes; ordered window SHA-256 `38fc8af2d363b6192d0414340bbac1e00064287e82f4deca51193b487845378a`.
  Comprehension: The manifest suffix completes exact usage rejection/order, source/input choices, root selection, eager logical effects, repeated action results, strict UTF-8 and BOM/newline preservation, compile-before-input failure phases, trace routing/mirroring/append/reset, aliases/numeric thresholds and escaped user fields. All66 cases are read. The parser-test prefix covers typed calls, literal/regex fields, variable and indexed/nested reads, shape literals, retired fat-arrow hashes, block values, trailing blocks with later fluent calls, assignments and control nodes. Read paths retain their key/index classification while bracket assignments use expression-bearing path_segment nodes. Inline value if/switch stay generic calls; statement controls use typed nodes. The if-lowering test substitutes AST fields whose source strings deliberately disagree, checks attached/alias/marker output, and rejects reuse of original or AST source text through383. Remaining assertions/closures and later tests are .1.33-owned. The whole target execution grants no physical-reading credit beyond383; existing canonical AST and CLI facts already own these mechanisms.
  Verification: Fresh managed Perl primary CLI passes all66 cases with POSIXLY_CORRECT unset and all66 with POSIXLY_CORRECT=1. The complete managed t/actionir_ast_parser.t target passes23 top-level tests. This is Perl evidence, not a new five-backend matrix or source-reading credit past383. Fresh complete-window replay, full baseline inventory, cumulative coverage, source/task/history preservation, rendered book, memory and document-pressure checks govern this focused leaf; normal commit doctrines remain required.
  Candidate proof: All9 source windows consumed completely; replay passes1500 fragments/55235 bytes. Full160-input/143-group/302-range inventory remains baseline-identical. Independent cumulative reading is32 groups/42157 fragments/1231747 bytes/78 complete files, with only ActionIR AST tests partial. Fresh managed Perl CLI default66/66 and POSIX66/66 both finish exit0; complete AST target passes23 top-level tests, with no reading credit beyond383. Preservation passes2493 exact prior files,2780 unchanged prior nodes, all94 book limitations and prior Knowledge recipes/footer. The canonical CLI card preserves its entire prior76-line body and adds dated scoped proof. Rendered book, memory60lines/7389bytes and plain diff checks pass; CHANGES192lines/38839bytes and notes150lines/36403bytes are OK. Known book-index warning remains startup41.9-owned. No new repair, full cross-backend matrix, canonical CI, dependency build or push.
  Commit: `CONFORMANCE-SOURCE-READING.1.32 - complete CLI manifest and read ActionIR parser tests`

- ID: `CONFORMANCE-SOURCE-READING.1.33`
  Status: `done`
  Activation commit: `3d633f3b650aec95a283d36cc494cae076d41c6c`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 33.
  Scope: `t/actionir_ast_parser.t` lines 384-1419; `t/callable_codeblock_literal_contract.t` lines 1-345
  Baseline evidence: 1381 fragments / 65521 decoded bytes; ordered range SHA-256 `d599d85b6f3034b709e12a21de4e3eb5101ce70e14e0292f5b4a24674656b478`.
  Dependencies: .1.32 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1381 fragments / 65521 bytes; ordered window SHA-256 `2111becc93e8b13b4bd1dca7181969f9e3d41f06af081f4fe3d4e66ac37e7335`.
  Comprehension: The AST suffix completes switch/while, assignment, helper, fluent, return-payload and block-value lowering controls. Deliberately inconsistent source fields test use of typed data; some fixtures inject older internal assign_hash_index or aggregate-wrapper shapes rather than asserting their authored-syntax validity. Value helpers preserve authored argument arity before optional-scope fallback. Covered malformed helpers produce readiness diagnostics, while unresolved standalone calls and narrow raw return compatibility retain their separately reported roles. Most lowering assertions inspect generated text and descriptors; they do not independently execute every emitted fragment. Callable1-345 reads eight-field inert literal records with exact signature/body/spans, canonical UTF-8 JSON-to-hex reconstruction, no captured environment, user-function transport, dynamic caller fixture execution and generated code loaded into a package in the same process. Helpers and registered functions precede variable calls. Fixed-arity, current keyword rejection, non-callable values and recursion retain typed failures; direct failing-body invocation restores a shadowed parameter. Later literal-test source remains .1.34-owned. Existing dynamic boolean loss under startup35 and receiver guard gap under startup19 remain separately owned; named-argument work stays parked.
  Verification: Fresh managed t/callable_codeblock_literal_contract.t passes10 top-level tests. Fresh neutral checker passes7 literals,11 calls,9 invalid literals,7 invalid calls,4 invalid declarations,8 contextual forms and23 governance mutations. Retain unchanged AST target23 proof from .1.32 at3d633f3b6. Whole-test execution grants no reading credit beyond345. Fresh window replay, baseline inventory, cumulative coverage, preservation, rendered book, memory and history checks govern this focused leaf; no new canonical or cross-backend admission.
  Candidate proof: All11 windows consumed completely; replay confirms1381 fragments/65521 bytes. All160 baseline inputs/143 groups/302 ranges remain exact. Independent cumulative coverage is33 groups/43538 fragments/1297268 bytes/79 complete files, with only callable literal tests partial. Fresh managed callable target10 and neutral7/11/9/7/4/8 plus23 governance mutations pass; unchanged AST23 proof retained from .1.32. Preservation passes2493 exact prior files,2780 unchanged prior nodes, all94 book limitation headings and all prior Knowledge recipes/footer; the literal card keeps its exact prior46-line body. Rendered book, memory60lines/7403bytes and plain diff checks pass. CHANGES198lines/40169bytes and notes156lines/38438bytes are OK. Known book-index warning remains startup41.9-owned; startup19/35 and other repairs remain unchanged. No full matrix, canonical CI, dependency build or push.
  Commit: `CONFORMANCE-SOURCE-READING.1.33 - complete AST lowering tests and read callable literal coverage`

- ID: `CONFORMANCE-SOURCE-READING.1.34`
  Status: `done`
  Activation commit: `d10305097eb502c0fe29309ec230437396e26d82`.
  Verification tier: `focused`
  Focused checks: Read exact baseline-identical scoped windows; reconcile canonical Knowledge and proportionate proof, preserve source/task/history, and verify memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no source or public-contract change, admission or parent closeout. Later prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 34.
  Scope: `t/callable_codeblock_literal_contract.t` lines 346-565; `t/cli_conformance_runner.t` lines 1-287; `t/complete_named_mark_contract.t` lines 1-79; `t/diagnostic_output_perl_contract.t` lines 1-461; `t/duplicate_regex_slot_identity_perl_contract.t` lines 1-300; `t/generated_source_contract.t` lines 1-153
  Baseline evidence: 1500 fragments / 56255 decoded bytes; ordered range SHA-256 `d7c3d32b96d69703881506fb7bf1454a585e47b91fb044b29570dd0fd23e180d`.
  Dependencies: .1.33 committed with clean handoff.
  Discussion continuity: The director asks how ARCHOGEN could embed Lispish through the Rust backend. This leaf owns a bounded read-only integration note in docs/knowledge/archogen-rust-lispish-integration.md, using existing native-loading, Lispish and dependency-build authorities. Record checkout/bootstrap prerequisites, direct-value API and historical tree/full-input limits; no ARCHOGEN implementation, dependency build, fresh consumer admission or task pivot is authorized by the question.
  Director follow-up: Own the requested integration documentation for every backend in docs/tasks/BACKEND-INTEGRATION-GUIDES.md, with matching task index, roadmaps, Knowledge and book intake pointers. This leaf records the approved work and exact future acceptance; startup prerequisites and the current reading frontier remain. Guide implementation is authorized once those prerequisites and clean activation are satisfied; no additional approval is needed for ordinary documentation work.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1500 fragments / 56255 bytes; ordered window SHA-256 `db04deab6c0365f8bc454e2695d410324a120104a232c213346f2b23ad16aef3`.
  Comprehension: Callable suffix tests preserve final-codeblock version3 carriers and contextual normalization, execute helper/receiver/user-function forms, and distinguish malformed headers from body colons and actual harray argument kinds. CLI runner tests cover real help, schema-before-launch, exact placeholders/artifacts, binary hex inputs, six rejected source shapes and first-byte mismatch. Named marks cover symbolic lowerings and an exact Unicode Top/Child fixture, not same-label recursion. Diagnostic fixtures replace E with an action edge plus Done and append x; ordered eager events, quiet defaults, exception identity, typed exit and arity-before-effects are checked on this adapted source. Generated roles load through eval into separate packages in the same process. Duplicate slots retain required structural identity, choice priority, repeated resets, loaded/descriptor/generated/trace routes and two diagnostics in twelve roles. Generated-source1-153 reads five seek/five consume policies and removed-option precedence, then opens the next family fixture. The director-requested BACKEND-INTEGRATION-GUIDES tree owns common setup plus five native guides and consumer examples, first-time dependency preparation versus reuse, packaging/errors and independent final verification; activate after this clean commit, then resume .1.35. Startup reading is temporarily deferred only for this expressly requested documentation activity.
  Verification: Fresh managed prove passes five targets and43 top-level tests: CLI runner, complete named marks, diagnostic output, duplicate slots and generated source. Neutral proof passes named marks7 helpers/3 mutations, diagnostics3 helpers/11 render cases/6 scenarios/20 mutations, and duplicate slots5 fixtures/2 diagnostics/59 mutations. Unchanged callable10 and neutral23-mutation proof from .1.33 are retained; whole-target execution gives no suffix reading credit. Fresh exact-window/inventory/cumulative/preservation, memory/history and rendered-book checks govern focused landing. ARCHOGEN guidance is source/documentation review only; no consumer build, dependency build, canonical gate or backend admission is claimed.
  Candidate proof: Eleven complete windows replay exactly; the160-input/143-group/302-range plan and cumulative34/45038 fragments/1353523 bytes/84 complete files pass. Preservation verifies2494 exact prior files,2780 unchanged prior nodes,19 newly pending integration nodes,94 book limitation headings and all earlier recipes. Memory passes at60 lines; the rendered book and exact temporary-pivot/return pointers agree. Both history checks are OK: changes204 lines/41621 bytes, notes162/40726. The known large book search-index warning remains startup41.9-owned. Five focused Perl targets pass43 tests; three neutral contracts and plain whitespace pass. All hooks and the post-commit pointer check remain required before clean activation of BACKEND-INTEGRATION-GUIDES.0.
  Commit: `CONFORMANCE-SOURCE-READING.1.34 - read Perl conformance consumers and schedule integration guides`

- ID: `CONFORMANCE-SOURCE-READING.1.35`
  Status: `done`
  Activation commit: `87b35665e1a8e0de1f03a27e31dbd4d34d8e2d94`.
  Verification tier: `focused`
  Focused checks: Read every baseline-identical scoped byte in complete bounded windows; reconcile generated-source, inspector and gap-consumer Knowledge, retain exact unchanged canonical proof where applicable, and verify coverage, source/task/history preservation, memory, book and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf after the clean integration push; no runtime, dependency, public-contract, gate or parent-closeout change. Remaining startup prerequisites stay open.
  Goal: Read and understand conformance/test/Unicode group 35.
  Audit correction: Own the stale baseline-equals-current coverage recipe exposed by the 113-byte cumulative mismatch. Integration commits 42490a9d9 and fbb135d63 change only twelve existing lines in rule_local_cursor_contract.json: ten current census markers, one count and one path list. Preserve original group hashes and reading totals; verify the exact approved file identity separately, reject every other source/mode/path delta, and qualify dated Knowledge statements. No runtime repair or new reading credit is implied by this reconciliation.
  Scope: `t/generated_source_contract.t` lines 154-506; `t/inspect_spec_codegen.t` lines 1-121; `t/inter_match_gap_capture_perl_contract.t` lines 1-1026
  Baseline evidence: 1500 fragments / 51804 decoded bytes; ordered range SHA-256 `9811fc24e1ee0addc55fb94051e23da5ed0edc9ceffee39f36a655f6f8b88bee`.
  Dependencies: .1.34 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 10 complete windows / 1500 fragments / 51804 bytes; ordered window SHA-256 `1164b42887bab92a4ea03d85fcaf4a9dc0c6913fc7607fe21a0d66cb0a424992`.
  Comprehension: Generated-source tests classify all ten family plans, compare deterministic/public/legacy emission and exact metadata, validate version/plan errors, execute seek/consume and indexed slash-bearing alternatives, and observe generated trace roles. Emitted packages load by eval in the same process. The inspector locks explicit compiler/bootstrap owners and five snippet forms with zero fallback/unresolved counts. Gap metadata tests verify named/numeric provenance, exact Unicode identity, duplicate-text reordering and ten compile diagnostics; live fixtures cover Unicode/empty gaps, child-extended commit cursors, nested distinct owners, rollback, LX/EX/E tails, typed context/IT/regression failures and legacy compatibility. Generated reading reaches the nested/rollback parity call at 1026. Returned-span mutation is checked by a subsequent invocation, and distinct nested labels are not proof of same-rule recursive isolation. Later generated failure coverage remains .1.36-owned.
  Verification: Retained exact integration commit 87b35665e proof passes generated-source (6), inspector (2) and gap (124) tests (132 total), with unchanged source identities. The old uniform-identity audit fails on the approved integration delta; its corrected recipe passes all 160 inputs/143 groups/302 ranges and six rejected snapshot mutations. No new runtime execution, native build, full CI or push is claimed for this focused reading leaf.
  Candidate proof: Exact coverage and .1.10/.1.35 window replay pass; six unexpected snapshot mutations are rejected. Preservation verifies 2,842 other files / 50,525,462 bytes, 500 earlier task nodes, 53 other book files and all 1,039 book headings, prior chronology, original dependency edits and pins. Public mutation (69 files / 50 mutations) and selector (68 files / 11 contrast mutations) checks pass. Knowledge has 1,151 facts / 9,205 keys; memory, both history-pressure checks, mdBook rendering and diff hygiene pass. The normal nine-doctrine commit hook remains mandatory; no new canonical run is required.
  Commit: `CONFORMANCE-SOURCE-READING.1.35 - read generated and gap consumers and reconcile source delta`

- ID: `CONFORMANCE-SOURCE-READING.1.36`
  Status: `done`
  Activation commit: `bd4ffa4cad99e5fb7dd0a7fe2cb77f9c7c5f0f6a`.
  Verification tier: `focused`
  Focused checks: Complete bounded physical source reading; verify exact baseline ranges, reconcile canonical Knowledge and retained unchanged test proof, then validate documentation, memory, book, histories, preservation and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no runtime, dependency, public-contract, infrastructure or parent-closeout change. Existing repair prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 36.
  Finding owner: `.2.3` owns the confirmed TestHelpers literal include-path defect; three bounded process controls isolate join/split argument loss. No production source is changed during required reading.
  Diagnostic scope: Check the exported TestHelpers subprocess helper with literal include paths containing spaces using a bounded repository-local fixture. Distinguish its callable behavior from the separate Phase-0 local helper; if confirmed, create a prerequisite-gated repair owner before continuing.
  Scope: `t/inter_match_gap_capture_perl_contract.t` lines 1027-1154; `t/lib/TestHelpers.pm` lines 1-137; `t/logical_helper_perl_contract.t` lines 1-285; `t/map_leaves_mutation_perl_contract.t` lines 1-374; `t/mcp_contract_perl_binding.t` lines 1-125; `t/mcp_server_perl_admission.t` lines 1-451
  Baseline evidence: 1500 fragments / 58957 decoded bytes; ordered range SHA-256 `5acc1fa20e3243969fc5a7d065139ece45aa08d6ff1f2d80cecd2cc91247147e`.
  Dependencies: .1.35 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1500 fragments / 58957 bytes; ordered window SHA-256 `071b58880845a0a7108956fb5110d4cc52fb015640fdb95b9e4d286d3e472f1f`.
  Comprehension: Gap suffix preserves typed live/generated/trace diagnostics, direct-entry absence and legacy rolling compatibility. Logical tests adapt neutral E fixtures to a Done edge, check typed truthiness/real booleans, eager evaluation and arity-before-effects across live and same-process emitted roles, plus primary CLI and typed lowering. Mutation tests check projected AST fields, original-shape traversal, receiver guards, rollback/unrelated effects, alias detachment, shadow identities and post-commit continuation; their final emitted-source assertions inspect text rather than execute that source. MCP binding checks generated freshness, all 35 canonical frames, schema and clone boundaries, with static I/O exclusions. Admission reading covers inventory, canonical dispatch, native capabilities/all 19 query identities, raw cases and lifecycle through the I/O cleanup prefix; later assertions remain .1.37-owned. Existing mixed-error ordering and callback-substitution defects remain open.
  Verification: Fresh managed logical/map-leaves tests pass 16 top-level tests. Exact unchanged integration proof retains gap (124) and admission (13), plus the binding target within the earlier three-target MCP group (23 tests). Three bounded helper controls confirm the literal include-path defect and its mechanism; .2.3 owns implementation and independent verification after required prerequisites. No production repair, dependency build, new canonical CI or push is claimed.
  Candidate proof: Exact coverage and eleven-window replay pass. Preservation verifies 2,844 other files / 50,534,011 bytes, 499 earlier task nodes, 53 other book files and all 1,039 book headings; original histories, coverage recipes, dependency pins and developer edits remain exact. Three new pending repair nodes own .2.3. The published helper reproduction, memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Knowledge remains at 1,151 facts / 9,207 keys; the normal nine-doctrine commit hook governs landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.36 - read Perl contracts and own helper path repair`

- ID: `CONFORMANCE-SOURCE-READING.1.37`
  Status: `done`
  Activation commit: `22e0b2d46b2e926508575915f3577b791cdd2c4f`.
  Verification tier: `focused`
  Focused checks: Complete bounded physical source reading; verify exact baseline ranges, reconcile canonical Knowledge and retained unchanged test proof, then validate documentation, memory, book, histories, preservation and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no runtime, dependency, public-contract, infrastructure or parent-closeout change. Existing repair prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 37.
  Finding owner: `.2.4` owns the stale Phase0 header count (989 versus retained 1031 subtests / 1032 total tests); preserve full source-reading prerequisites and executable assertions.
  Scope: `t/mcp_server_perl_admission.t` lines 452-656; `t/mcp_server_perl_dispatch.t` lines 1-403; `t/mcp_server_perl_stdio.t` lines 1-472; `t/native_spec_resolution.t` lines 1-222; `t/noncurrent_helper_metadata.t` lines 1-68; `t/oracle_root_target_regex_semantics.t` lines 1-87; `t/phase0_regression.t` lines 1-43
  Baseline evidence: 1500 fragments / 63613 decoded bytes; ordered range SHA-256 `9d2fc07302eebc1f1dcc1294523f599be987d9834a59648e1c92f958cd06a42c`.
  Dependencies: .1.36 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 14 complete windows / 1500 fragments / 63613 bytes; ordered window SHA-256 `98d4de26a6f747975c45fe91277d218c6947936925d1ae233586706bef952d64`.
  Comprehension: MCP admission closes all twelve ordered roles with policy call counts, indistinguishable response values, cancellation boundaries, fixed I/O diagnostics, cleanup and static API/source exclusions. Decoded tests distinguish omitted/partial overlays from explicit lower ceilings; stdio tests preserve lexical numeric IDs, exact UTF-8 byte limits, duplicate/depth/line handling, canonical LF framing, final EOF frames and continuation after rejected input. These use in-memory handles and bounded fixtures, not process-launch or timing/peak-memory measurements. Native resolution consumes all 14 name, 9 resolution and 4 text cases, models non_regular as a directory, and checks compiled identity and typed errors. Retired-helper tests inspect metadata; oracle tests inspect source shapes and counts without executing the corpus. Phase0 prefix contains its imports and a stale 989 header count; .2.4 owns correction against the retained 1032 plan.
  Verification: Fresh managed metadata/oracle checks pass 9 top-level tests. Unchanged integration commit 87b35665e retains native-loader (5), MCP binding/dispatch/stdio (23), admission (13) and Phase0 1032 proof. Full-target execution grants no reading credit to the unread Phase0 body. Header correction .2.4 is pending after prerequisites; helper repair .2.3 and existing runtime repairs remain open. No dependency build, new canonical run or push is claimed.
  Candidate proof: Exact coverage and fourteen-window replay pass. Preservation verifies 2,843 other files / 50,531,501 bytes, 502 earlier task nodes, 53 other book files and all 1,039 book headings; prior histories, coverage recipes, dependency pins and original edits remain exact. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Knowledge remains at 1,151 facts / 9,209 keys; normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.37 - read MCP and loader tests and own header correction`

- ID: `CONFORMANCE-SOURCE-READING.1.38`
  Status: `done`
  Activation commit: `a1c65b959c09dc169c86f9cc192e4f1af152695f`.
  Verification tier: `focused`
  Focused checks: Complete bounded physical source reading; verify exact baseline ranges, reconcile canonical Knowledge and retained unchanged test proof, then validate documentation, memory, book, histories, preservation and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no runtime, dependency, public-contract, infrastructure or parent-closeout change. Existing repair prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 38.
  Scope: `t/phase0_regression.t` lines 44-1110
  Baseline evidence: 1067 fragments / 65529 decoded bytes; ordered range SHA-256 `681152e5cc921275d5cbca78f1f4becc67874dd7f772792c660a6eae479cfd21`.
  Dependencies: .1.37 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1067 fragments / 65529 bytes; ordered window SHA-256 `f57116fee0db80f49969546da5cd033988e06b55191fc88358b7c6d6d334fd3e`.
  Comprehension: Shipped-spec tests distinguish parser construction and ActionIR readiness from execution; tclite additionally checks bracket/empty-quote ASTs and legacy Lispish lookup checks module-relative discovery without PathSearch. Require/operation snippets assert lazy module markers and preserved return/diagnostic values across facade, compile owners, bootstrap, trace/dumper, scanner, split and canonical-event boundaries. The statement splitter receives explicit dependencies and checks eight exact string partitions rather than parser acceptance. Plugin tests distinguish registered callbacks from substituted legacy dispatch and preserve arguments/return values. The crossing facade test substitutes owner functions and reads nine successful delegation/error-state pairs through line 1110; it does not prove owner implementations. Its remaining assertions and the Phase0 local subprocess helper body retain later reading ownership.
  Verification: Exact unchanged canonical commit 87b35665e supplies PASS for all 38 fully read subtests (ordinals 2–39). The crossing facade error-state test remains partial; its suffix is .1.39-owned. The complete 1032-test gate remains retained historical proof, not new execution or reading credit. No new defect, runtime repair, dependency build, full CI or push is claimed; all existing repairs retain their prerequisites.
  Candidate proof: Exact coverage and eleven-window replay pass. Preservation verifies 2,844 other files / 50,534,386 bytes, 504 earlier task nodes, 53 other book files and all 1,039 book headings; prior histories, coverage recipes, dependency pins and original edits remain exact. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Knowledge remains at 1,151 facts / 9,210 keys; normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.38 - read Phase0 lazy-loading and plugin contracts`

- ID: `CONFORMANCE-SOURCE-READING.1.39`
  Status: `done`
  Activation commit: `fc5fad04fc6ff981d74dbf022992baa819dbda7b`.
  Verification tier: `focused`
  Focused checks: Complete bounded physical source reading; verify exact baseline ranges, reconcile canonical Knowledge and retained unchanged test proof, then validate documentation, memory, book, histories, preservation and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no runtime, dependency, public-contract, infrastructure or parent-closeout change. Existing repair prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 39.
  Scope: `t/phase0_regression.t` lines 1111-1526
  Baseline evidence: 416 fragments / 64842 decoded bytes; ordered range SHA-256 `9e3895f7b13337a4a6b6f5241dacda61678065fde2cc2724367ae1bc2295036c`.
  Dependencies: .1.38 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 416 fragments / 64842 bytes; ordered window SHA-256 `637b617933d223c8317d6c27901ead86ed5835131a0fc2201b1422db311bae5f`.
  Comprehension: The two final facade pairs complete eleven successful delegated-return/error-state pairs with substituted owners. The 298-assertion shared-owner test reads 28 LinkedSpec source files and checks imports, shared dispatch/dependency builders, trace wrappers, registries and retired-wrapper exclusions with text patterns. Eight three-assertion inline-validation tests likewise check source availability, removed helper names and expected callback-validation text. These are structural checks, not execution of each matched branch or whole-DSL acceptance. The ParserFactory test is read through two of its three assertions at line 1526; its suffix and the local subprocess helper body remain unread.
  Knowledge correction: This leaf owns correcting the OwnerDispatch card's inconsistent five-primitives introduction; its existing seven-item list is preserved exactly, with a dated reconciliation note. No API or implementation changes.
  Verification: Unchanged canonical commit 87b35665e retains PASS for ten completed subtests, ordinals 40–49 with 344 assertions: the crossing facade test, shared-owner structural checks and eight inline-validation checks. All 28 inspected source targets remain byte-identical. ParserFactory validation crosses into .1.40. Historical whole-gate proof remains 1032 top-level tests; no new runtime execution, dependency build, full CI or push is claimed. All runtime repairs retain their prerequisites.
  Candidate proof: Exact coverage and eleven-window replay pass. Preservation verifies 2,843 other files / 50,532,273 bytes, 504 earlier task nodes, 53 other book files and all 1,039 book headings; prior histories, coverage recipes, dependency pins and original edits remain exact. The OwnerDispatch card preserves its seven listed entries. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Knowledge remains at 1,151 facts / 9,211 keys; normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.39 - read Perl owner dispatch structural contracts`

- ID: `CONFORMANCE-SOURCE-READING.1.40`
  Status: `done`
  Activation commit: `cea5e399bbc59d500fa71485b60057ba8f13da60`.
  Verification tier: `focused`
  Focused checks: Complete bounded physical source reading; verify exact baseline ranges, reconcile canonical Knowledge and retained unchanged test proof, then validate documentation, memory, book, histories, preservation and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no runtime, dependency, public-contract, infrastructure or parent-closeout change. Existing repair prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 40.
  Scope: `t/phase0_regression.t` lines 1527-2566
  Baseline evidence: 1040 fragments / 65471 decoded bytes; ordered range SHA-256 `d5a9d405495fac023b401318c972eb0442e1db38717695e859a6046cd2dab759`.
  Dependencies: .1.39 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1040 fragments / 65471 bytes; ordered window SHA-256 `3afe1dca0df301909510c1f6c86f4f5c27613121cd041c866262d2fd9acd3f44`.
  Comprehension: Eight source-shape validation tests finish, including the crossing ParserFactory test. Actual OwnerDispatch calls resolve synthetic callbacks, preserve requested map entries and delegated list context, and assemble mixed callback/value bundles. Twelve EmitContext owner-map tests substitute each owner and map builder to check package selection, returned markers, local entrypoints and successful caller error-state preservation. Other wrapper tests cover Trace, Data::Dumper, LinkedRE, runtime/bootstrap, SpecEntry, compiler, plugins and injected ParserFactory orchestration. They verify wrappers with controlled collaborators, not the replaced implementations; already-loaded package fixtures do not prove first-time disk loading. The next 24-assertion ActionIR dependency-builder test has only imports and synthetic callback setup read through line 2566; none of its assertions has been read yet.
  Verification: Unchanged canonical commit 87b35665e retains PASS for thirty completed subtests, ordinals 50–79 with 181 assertions. Phase0 and LinkedSpec-owned Perl sources remain unchanged. The ActionIR dependency-builder test is partial in fixture setup; .1.41 owns its assertions. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.
  Candidate proof: Exact coverage and eleven-window replay pass. Preservation verifies 2,844 other files / 50,534,644 bytes, 504 earlier task nodes, 53 other book files and all 1,039 book headings; prior histories, coverage recipes, dependency pins and original edits remain exact. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Knowledge remains at 1,151 facts / 9,212 keys; normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.40 - read Perl wrapper and dependency-map contracts`

- ID: `CONFORMANCE-SOURCE-READING.1.41`
  Status: `done`
  Activation commit: `8eff213401d198e710464f7d87d40ac1e8e45be0`.
  Verification tier: `focused`
  Focused checks: Complete bounded physical source reading; verify exact baseline ranges, reconcile canonical Knowledge and retained unchanged test proof, then validate documentation, memory, book, histories, preservation and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no runtime, dependency, public-contract, infrastructure or parent-closeout change. Existing repair prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 41.
  Scope: `t/phase0_regression.t` lines 2567-3739
  Baseline evidence: 1173 fragments / 65484 decoded bytes; ordered range SHA-256 `2ae790e06398a17ba62a899d756c0a307f10d824187fb81288980b2beae8ee92`.
  Dependencies: .1.40 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1173 fragments / 65484 bytes; ordered window SHA-256 `e3f5aa84a083b491167df80df3b8e73afb6c8c14b89e69c206f02aba094241a4`.
  Comprehension: The crossing dependency-builder test checks defined callback results and preserved caller error state for twelve owners, not exact equality of every payload. Plugin probes cover registration/clear counts, registry-first dispatch, invalid-name rejection before fallback and controlled callback forwarding. Synthetic legacy fixtures cover ordered roots/files, duplicate override precedence, malformed/missing-file diagnostics and explicit reader source shapes. These retain the existing Perl compatibility boundary. Real Lispish probes compile and execute from changed working directories while retired facade/dependency paths are trapped; they assert CODE/ARRAY shapes, option normalization and trace markers rather than full AST equality. Spec-name/path cases distinguish invalid scalar/reference values, missing slash/backslash spellings, directories and OS devnull while checking diagnostics and absence of PathSearch. Backslash spelling does not establish Windows-platform execution; local subprocess/capture helper bodies remain later-read owners. The crossing missing-dot-spec test has only three of six assertions read through line 3739.
  Verification: Unchanged canonical commit 87b35665e retains PASS for 42 completed subtests, ordinals 80–121 with 282 assertions. Phase0, own Perl sources and Lispish.spec remain unchanged. The missing-dot-spec-name test is partial after three of six assertions; .1.42 owns the suffix. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.
  Candidate proof: Exact coverage and eleven-window replay pass. Preservation verifies 2,844 other files / 50,534,644 bytes, 504 earlier task nodes, 53 other book files and all 1,039 book headings; prior histories, coverage recipes, dependency pins and original edits remain exact. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Knowledge remains at 1,151 facts / 9,213 keys; normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.41 - read Perl plugin compatibility and spec lookup tests`

- ID: `CONFORMANCE-SOURCE-READING.1.42`
  Status: `done`
  Activation commit: `83f86d57c1a55ca6adb792c55e6098ca7e947736`.
  Verification tier: `focused`
  Focused checks: Complete bounded physical source reading; verify exact baseline ranges, reconcile canonical Knowledge and retained unchanged test proof, then validate documentation, memory, book, histories, preservation and normal doctrines.
  Canonical trigger: Ordinary bounded source-reading leaf; no runtime, dependency, public-contract, infrastructure or parent-closeout change. Existing repair prerequisites remain.
  Goal: Read and understand conformance/test/Unicode group 42.
  Scope: `t/phase0_regression.t` lines 3740-5136
  Baseline evidence: 1397 fragments / 65472 decoded bytes; ordered range SHA-256 `0dd54bbb3ae2b2e42b7ebdbbe61510dea667586119055340b8940a8b1c0c1c43`.
  Dependencies: .1.41 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1397 fragments / 65472 bytes; ordered window SHA-256 `a8d3e208ff956277f6f6e0ca38e9e3beab59d8c3c22b83c97132d8845352e4af`.
  Comprehension: PathSearch tests separate require/runtime failures, explicit-path bypass, malformed fallback targets and controlled or actual fallback success. Host permission-based open failure, malformed spec validation, inner handler syntax/LinkedRE errors and parser input-shape failure have distinct outcomes; local helper bodies remain later-read owners. Descriptor assertions cover action/blind-call family selection, loop flags and repetition bounds, including the 10**9 open sentinel. Separate runtime cases check bounded OR, explicit aliases, blind choice/repetition, optional empty results and zero-progress parent failure. Invalid bounded-label checks establish parse failure, not nonempty diagnostics. Bootstrap selectors preserve unindexed/numeric-zero provenance and slots through three; runtime zero-index comparisons check equality without separately requiring defined results. Grouped action targets expand shared code and build a wrapper without proving child execution. The crossing AND+ versus bounded-AND test has two build assertions read, followed by its first invocation; eight result/remaining assertions are unread.
  Verification: Unchanged canonical commit 87b35665e retains PASS for 41 completed subtests, ordinals 122–162 with 353 assertions. Phase0, own Perl sources and Lispish.spec remain unchanged. The AND+ comparison is partial after both parser-build assertions and the first invocation; .1.43 owns its result assertions. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.
  Candidate proof: Exact coverage and eleven-window replay pass. Preservation verifies 2,844 other files / 50,534,644 bytes, 504 earlier task nodes, 53 other book files and all 1,039 book headings; prior histories, coverage recipes, dependency pins and original edits remain exact. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Knowledge remains at 1,151 facts / 9,214 keys; normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.42 - read Perl resolution errors and rule-family contracts`

- ID: `CONFORMANCE-SOURCE-READING.1.43`
  Status: `done`
  Activation commit: `6c5dc205a8822b744476c5eb65bbb3b2a0697ddc`.
  Verification tier: `focused`
  Focused checks: Complete bounded source reading, exact baseline/window and retained canonical proof; reconcile Knowledge, preserve unrelated source/history/task evidence, memory, both history checks, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation only; no runtime, dependency, public-contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 43.
  Scope: `t/phase0_regression.t` lines 5137-6636
  Baseline evidence: 1500 fragments / 64877 decoded bytes; ordered range SHA-256 `944f19375169eb35a0aa51939a66270a2f319c261ec2aca28544168ba7b3e4ef`.
  Dependencies: .1.42 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1500 fragments / 64877 bytes; ordered window SHA-256 `8749a8dc08b927f83439d0e9056e12252e8206c7243c342095145adc4d72a28d`.
  Comprehension: AND+ and open bounded AND collect the same nested sequence results and reject empty input; bounded AND descriptors preserve action/blind family and exact bounds, while runtime cases separately check lower and upper limits. Interleaved and same-line paragraph tests compare bootstrap payloads and descriptor fields without executing their parsers. Validation distinguishes malformed labels, preambles, split markers, paragraph/header content, closers, regex tokens, mixed edges, selectors, fluent suffixes, grouped targets and missing targets. Hash rockets and edge-like strings inside action code remain lexical validation controls, not portable DSL admission. Blind fluent/block equivalence compares normalized BCODE only. Open-block rule-label rejection includes parser-build coverage and nested blocks; permissive non-label contents are validation-only fixtures. The extra-colon and nested-mode loops assert stderr only for their final case. EOF-unclosed-block reading stops inside its heredoc before validation or assertions.
  Verification: Unchanged canonical commit 87b35665e retains PASS for 54 completed subtests, ordinals 163–216 with 311 assertions. Phase0, own Perl sources and Lispish.spec remain unchanged. The unclosed-multiline-block test is partial at its spec heredoc; .1.44 owns its invocation and all four assertions. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.
  Candidate proof: Exact 160-input/143-group/302-range audit and eleven-window replay pass. Preservation verifies 2,843 other files / 50,531,292 bytes, 504 earlier task nodes, 53 other book files and all 1,039 book headings; history, original scopes, recipes and parent Gitlink remain exact. Preservation was rerun successfully after the concurrent public checker finished and no untracked fixture remained. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations), intrinsic cursor (76 migration files / 60 mutations) and diff checks pass. Knowledge remains at 1,151 facts / 9,215 keys; normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.43 - read bounded AND and paragraph validation contracts`

- ID: `CONFORMANCE-SOURCE-READING.1.44`
  Status: `done`
  Activation commit: `cc3a8591f05600517d7d26f05aa2f669ce5fbe07`.
  Verification tier: `focused`
  Focused checks: Complete bounded source reading, exact baseline/window and retained canonical proof; reconcile Knowledge, preserve unrelated source/history/task evidence, memory, both history checks, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation only; no runtime, dependency, public-contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 44.
  Scope: `t/phase0_regression.t` lines 6637-7826
  Baseline evidence: 1190 fragments / 65521 decoded bytes; ordered range SHA-256 `33c4d12568f0ba14dad46d9ef28b7487fbe92dc765902e2cadb86d3d28acd150`.
  Dependencies: .1.43 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1190 fragments / 65521 bytes; ordered window SHA-256 `1482c40e24c0dc3b8c8985c7a8bd3a70ae78c9f2085dbd86f727dafff9d3039a`.
  Comprehension: Validation completes EOF-block rejection and contrasts lax/strict undefined or unused rules. Fluent/lifecycle/index/group controls and both passes over the shipped-spec glob test validation acceptance only; zero-argument-flow cases use blocks despite the broader test name. Split aliases and named marks check bootstrap tokens, exact typed LECODE, emit-context lowering and regex slots without runtime capture execution. Dependency metadata preserves authored order. Compiler tests distinguish injected/default callbacks, explicit compiled-state shape, exceptions, invalid callback/container/entry/tuple contracts and shared context preparation. Facade controls check bypassed legacy wrappers, scalar execution and odd-option fallback to an empty hash. RuntimeContext checks preserve hash/scalar-slot identity, capture-array identity/reset/flush, spec/top identity, source-label fallback and existing structured errors. Synthetic path strings do not perform file I/O. Owner-default-error reading ends after five of six assertions; its final identity assertion remains unread.
  Verification: Unchanged canonical commit 87b35665e retains PASS for 37 completed subtests, ordinals 217–253 with 295 assertions. Phase0, own Perl sources and all shipped specs remain unchanged. TAP replay checks every assertion number, including four valid description-free ok lines. The owner-default-error test is partial after five assertions and its final fallback call; .1.45 owns the sixth assertion. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.
  Candidate proof: Exact 160-input/143-group/302-range audit and eleven-window replay pass. Preservation verifies 2,844 other files / 50,534,669 bytes, 504 earlier task nodes, 53 other book files and all 1,039 book headings; history, scopes, recipes and parent Gitlink remain exact. Five current sibling-index pointers are refreshed from stale .1.35 to the actual next .1.45 without changing repair status. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Change-history is above its 80% warning but below its 90% required-rollover boundary. Knowledge remains at 1,151 facts / 9,216 keys; normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.44 - read validation compiler and runtime-context contracts`

- ID: `CONFORMANCE-SOURCE-READING.1.45`
  Status: `done`
  Activation commit: `f4a9ea2965b7b0cfb218e921439014bf8a87d0f3`.
  Verification tier: `focused`
  Focused checks: Complete bounded source reading, exact baseline/window and retained canonical proof; reconcile Knowledge, preserve unrelated source/history/task evidence, memory, both history checks, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation only; no runtime, dependency, public-contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 45.
  Scope: `t/phase0_regression.t` lines 7827-8871
  Baseline evidence: 1045 fragments / 65409 decoded bytes; ordered range SHA-256 `97cf45f625d1e54cf5b43fdc91f19b8818e3c4c4dae41086065156c6db60dba2`.
  Dependencies: .1.44 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1045 fragments / 65409 bytes; ordered window SHA-256 `57fa586148e84cf02124246fd1ea0621df41394f0111f36e7fa069638e3ac60c`.
  Comprehension: RuntimeContext controls distinguish read-side defaults, identity-only clearing, inline run_get preparation, option preservation, pipeline capture reset, build-table preparation and file-parser preparation. Direct hashes and populated scalar slots retain caller fields; unhooked calls return undef, and malformed slots are rejected. SpecEntry setter and retired-facade traps check selected ownership paths and compiled descriptors. Injected bootstrap/source-capture controls and repeat-helper regex assertions inspect emitted source rather than independently loading it. Compiler failures distinguish setup contracts, validator false returns, validator exceptions, bootstrap exceptions, malformed success results, generated dependency indexes and nested descriptor validation. Error attribution retains specific summaries/detail, owner stage, owning rule or requested-top fallback and empty inline spec identity. The next compile-entry exception case stops after type assertion four; eight later diagnostic assertions remain unread.
  Verification: Unchanged canonical commit 87b35665e retains PASS for 26 completed subtests, ordinals 254–279 with 289 assertions. Phase0, own Perl sources and shipped specs remain unchanged; TAP replay verifies every sequential assertion number. The compile-entry exception test is partial after four of twelve assertions; .1.46 owns the remaining eight. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.
  Candidate proof: Exact 160-input/143-group/302-range audit and eleven-window replay pass. Preservation verifies 2,844 other files / 50,534,669 bytes, 504 earlier task nodes, 53 other book files and all 1,039 book headings; history, scopes, recipes and parent Gitlink remain exact. All six current reading-index rows agree on next .1.46. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Both hot histories are above their 80% warning but below required rollover. Knowledge remains at 1,151 facts / 9,217 keys; normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.45 - read context preparation and compiler failure attribution`

- ID: `CONFORMANCE-SOURCE-READING.1.46`
  Status: `done`
  Activation commit: `38997866e1735b63e01a5cbf86286af14f7a4d4f`.
  Verification tier: `focused`
  Focused checks: Complete bounded source reading, exact baseline/window and retained canonical proof; reconcile Knowledge, preserve unrelated source/history/task evidence, memory, both history checks, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation only; no runtime, dependency, public-contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 46.
  Scope: `t/phase0_regression.t` lines 8872-9844
  Baseline evidence: 973 fragments / 65483 decoded bytes; ordered range SHA-256 `8292afe74aabb6ce967f52d6b6aea097a9398d4d3aac710c9f67f992d423d6ca`.
  Dependencies: .1.45 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 973 fragments / 65483 bytes; ordered window SHA-256 `84b8930f933767a2b8b7a091aa173d1b18171640995e77a1813f700a1ce6124d`.
  Comprehension: Compiler controls complete compile-entry diagnostics, reject empty compile tuples and malformed dependency shapes, and attribute default dependency assembly failures to the active rule. CompilerState tests distinguish explicit versioned owner states, ordered dependency rows, outward descriptor projection and removed internal aliases/wrappers. Thirteen wrapped owner calls and nine retired-wrapper absence checks establish bounded delegation and descriptor construction; they do not invoke every generated handler. Compiled descriptor validation bypasses the legacy dependency-map entrypoint and success clears stale compiler errors. ParserFactory tests separate resolution, setup, name validation, file loading and compile fallback failures, preserving specific resolver summaries/detail and requested rule/spec identity. Selected RuntimeContext ownership checks inspect source text while Compiler forwarding is callback-observed. Mock /tmp-shaped paths are inert; the real unreadable-file fixture uses managed File::Temp. The non-coderef callback case is partial inside dependency setup; its assertions remain unread.
  Verification: Unchanged canonical commit 87b35665e retains PASS for 30 completed subtests, ordinals 280–309 with 274 assertions. Phase0, own Perl sources and shipped specs remain unchanged; TAP replay verifies every sequential assertion number. The non-coderef compile callback test stops inside setup before its callback and assertions; .1.47 owns the unread suffix. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.
  Candidate proof: Exact 160-input/143-group/302-range audit and eleven-window replay pass. Preservation verifies 2,844 other files / 50,534,669 bytes, 504 earlier task nodes, 53 other book files and all 1,039 book headings; history, scopes, recipes and parent Gitlink remain exact. All six current reading-index rows agree on next .1.47. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories measure changes 257 lines / 55,031 bytes and notes 225 / 54,890, above warning but below required rollover. Knowledge remains at 1,151 facts / 9,218 keys; normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.46 - read compiler-state composition and parser-factory error contracts`

- ID: `CONFORMANCE-SOURCE-READING.1.47`
  Status: `done`
  Activation commit: `3e04685337ba04a9944f69be619fc1b8c88738b8`.
  Verification tier: `focused`
  Focused checks: Complete bounded source reading, exact baseline/window and retained canonical proof; reconcile Knowledge, preserve unrelated source/history/task evidence, memory, both history checks, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation only; no runtime, dependency, public-contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 47.
  Scope: `t/phase0_regression.t` lines 9845-10823
  Baseline evidence: 979 fragments / 65510 decoded bytes; ordered range SHA-256 `d22df0a79db9e7b831352da4b823609578d2eefb18350f2dfb385770c8a98ef7`.
  Dependencies: .1.46 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 979 fragments / 65510 bytes; ordered window SHA-256 `b46257ef9b64fa75fb31c9e49bc403bc3d5c96e59c69f3e6b13d44b040baa1a4`.
  Comprehension: ParserFactory and public get_parser controls reject malformed default parser, descriptor and single parse/generate-only results with mode-specific detail. Callback-written deeper owner errors survive exceptions and undef returns. Public temporary-file controls distinguish Runtime fallback diagnostics from ParserFactory rejection of malformed Runtime results. Runtime forwards context while leaving default parse/entry callbacks to Compiler; direct hashes and populated scalar slots retain identity and caller fields, reset stale errors and replace source captures for identical repeated input. Inline failure clears stale file identity; single parse-only and generate-only successes intentionally return undef with a clear failure channel and different top-rule state. Injected compiler exceptions and invalid results acquire runtime_owner attribution unless a deeper compiler error exists. These single-mode controls do not cover combined-flag precedence or invoke the constructed handlers. The missing-file public control also checks emitted diagnostic text. Reused-context resolution failure remains partial after eight assertions.
  Verification: Unchanged canonical commit 87b35665e retains PASS for 28 completed subtests, ordinals 310–337 with 280 assertions. Phase0, own Perl sources and shipped specs remain unchanged; TAP replay verifies every sequential assertion number. The reused-context resolution-failure test stops after eight of nine assertions; .1.48 owns its final assertion. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.
  Candidate proof: Exact 160-input/143-group/302-range audit and eleven-window replay pass. Preservation verifies 2,844 other files / 50,534,669 bytes, 504 earlier task nodes, 53 other book files and all 1,039 book headings; history, scopes, recipes and parent Gitlink remain exact. All six current reading-index rows agree on next .1.48. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories measure changes 261 lines / 55,967 bytes and notes 229 / 56,377, above warning but below required rollover. Knowledge remains at 1,151 facts / 9,219 keys; normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.47 - read mode-result validation and runtime-context reuse contracts`

- ID: `CONFORMANCE-SOURCE-READING.1.48`
  Status: `done`
  Activation commit: `0a8c217a19276c9416f302dd9d90a7716ed63e29`.
  Verification tier: `focused`
  Focused checks: Complete bounded source reading, exact baseline/window and retained canonical proof; reconcile Knowledge, preserve unrelated source/history/task evidence, memory, both history checks, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation only; no runtime, dependency, public-contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 48.
  Scope: `t/phase0_regression.t` lines 10824-11855
  Baseline evidence: 1032 fragments / 65524 decoded bytes; ordered range SHA-256 `f1fd2107d5d3c0f983821b84deffb49bc48f347b073ea56d794f4bd18e5d3686`.
  Dependencies: .1.47 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1032 fragments / 65524 bytes; ordered window SHA-256 `d84f1017d31b0bd33fb239a44e9da6beebddfb6e5ea680e820ef93ff495cd896`.
  Comprehension: Public get_parser controls preserve scalar-slot identity and caller fields while refreshing requested spec/top identity, clearing stale source chunks in place and dropping the stale emitter before failed resolution. Real load, validation and injected setup/compile failures preserve specific summaries, source identity, owner stage and requested-top labels through the facades. Invoked generated handlers trap forced LinkedRE failures as runtime_handler errors with inner eval text; a subsequent successful inline invocation clears the error. Injected raw handlers instead throw through the runtime_parser boundary, which records top-rule/variant identity and rethrows; invalid ARRAY input records validate_input_ref with the targeted message. A BEGIN counter proves one source compilation during one handler construction and reuse across two calls. Invalid generated syntax yields a wrapper, suppresses construction warnings and publishes compile detail only when invoked. These direct invocation controls do not establish independently emitted-module behavior. The final compiler success-cleanup control has only its parser-construction assertion read; invocation and seven assertions remain.
  Verification: Unchanged canonical commit 87b35665e retains PASS for 27 completed subtests, ordinals 338–364 with 313 assertions. Phase0, own Perl sources and shipped specs remain unchanged; TAP replay verifies every sequential assertion number. The compiler success-cleanup test stops after its first of eight assertions; .1.49 owns the seven remaining assertions and invocation. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.
  Candidate proof: Exact 160-input/143-group/302-range audit and eleven-window replay pass. Preservation verifies 2,844 other files / 50,534,669 bytes, 504 earlier task nodes, 53 other book files and all 1,039 book headings; history, scopes, recipes and parent Gitlink remain exact. All six current reading-index rows agree on next .1.49. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories measure changes 265 lines / 56,930 bytes and notes 233 / 57,948, above warning but below required rollover. Knowledge remains at 1,151 facts / 9,220 keys; normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.48 - read public diagnostic propagation and handler lifecycle contracts`

- ID: `CONFORMANCE-SOURCE-READING.1.49`
  Status: `done`
  Activation commit: `7a166581c022029c461ebb78d95971f4a6666bb2`.
  Verification tier: `focused`
  Focused checks: Complete bounded source reading, exact baseline/window and retained canonical proof; reconcile Knowledge, preserve unrelated source/history/task evidence, memory, both history checks, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation only; no runtime, dependency, public-contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 49.
  Scope: `t/phase0_regression.t` lines 11856-12849
  Baseline evidence: 994 fragments / 65520 decoded bytes; ordered range SHA-256 `935b7c9398809a4c668d89e6f3a6dcdf32bdf6e1d982d761ecffdf1cf6c9305d`.
  Dependencies: .1.48 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 994 fragments / 65520 bytes; ordered window SHA-256 `d73aae559d4b4280080e5d3df87d2300a07cc2f30f85439045cde24f95689a60`.
  Comprehension: Compiler controls finish success cleanup, then distinguish absent top label, handler and descriptor entry at invocation; artificial setter suppression or validation bypass isolates the relevant boundary. Default dependency-map construction receives explicit compiled state; direct state validation and ordered migration metadata precede outward projection. The projection trap observes validation entry, not an independent validation-completion timestamp. Removed facade/dependency-builder traps preserve selected EmitContext outputs, canonical RETURN classification and duplicate unresolved counts. Nine lowering examples check generated strings without executing those strings. ScannerCore binds five symbols exactly once for one return-bare scan. Cold subprocesses check require-only and on-demand owner loading. The MethodExpr Deps marker is emitted before parsing despite a post-parse assertion label; a controlled fixture load survives all seven assertions while explicit before/after probes detect it. The production module is absent and normal parsing leaves Deps unloaded. New .2.5 owns test repair after prerequisites. Diagnostics lazy-load reading stops inside its child heredoc before assertions.
  Verification: Unchanged canonical commit 87b35665e retains PASS for 29 completed subtests, ordinals 365–393 with 202 assertions; sequential TAP numbers and unchanged Phase0/own Perl/spec identities are verified. Fresh TOOLBOX6.2 extraction passes the MethodExpr test with all7 assertions both unchanged and with an inert post-parse Deps fixture load; independent cold probes observe 0/0 versus 0/1. Repair .2.5 owns the wrong-time observation. The Diagnostics lazy-load heredoc remains partial before its assertions; .1.50 owns the suffix. Targeted helper inspection at48608–48631 grants no reading credit outside this scope. Historical whole-gate proof remains 1032 top-level tests; no new full gate, runtime repair, dependency build or push is claimed.
  Candidate proof: Exact 160-input/143-group/302-range audit and eleven-window replay pass. Preservation verifies 2,844 other files / 50,534,669 bytes, 504 earlier task nodes, 53 other book files and all 1,039 book headings; new pending repair .2.5 and its finding section in the existing consumer fact card are admitted. Historical scopes, recipes and parent Gitlink remain exact. Fresh reproduction from the committed-form fact recipe confirms original/injected tests both pass7 assertions and independent 00/01 before/after states. All six current reading-index rows agree on next .1.50. Memory, both history checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories remain below required rollover. Knowledge is 1,151 facts / 9,224 keys. The first commit hook rejected a new 1,153rd Knowledge collection file against the unchanged 1,152-file cap. Its complete finding body, replay recipe and three question keys were merged into the existing consumer card; no fact or scope is dropped and no control increases. Normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.49 - read compiler owner paths and diagnose lazy-load test blind spot`

- ID: `CONFORMANCE-SOURCE-READING.1.50`
  Status: `done`
  Activation commit: `d70f77f4d1abf7c4a1297731ee014a369940303c`.
  Verification tier: `focused`
  Focused checks: Complete source reading, exact baseline/window and retained canonical proof, fresh TOOLBOX6.2 load observations; reconcile Knowledge, preserve unrelated source/history/task evidence, memory, both history checks, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation only; no runtime, dependency, public-contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 50.
  Scope: `t/phase0_regression.t` lines 12850-13631
  Baseline evidence: 782 fragments / 65470 decoded bytes; ordered range SHA-256 `7e2fe3f81d5eb0a39d7995310a1985e283f54bf7967d3cbcaa2d378f841c3676`.
  Dependencies: .1.49 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 782 fragments / 65470 bytes; ordered window SHA-256 `519c197576d4307f13e2b7fa04bbf2d6b053a89aa3ef03d698cd9c570849a4c8`.
  Comprehension: Cold subprocesses distinguish Diagnostics, Scanner, StatementSplit, Contracts, RewritePipeline and six lowering owners from their EmitContext bridge. Payload checks validate selected arrays, contract callbacks, rewrite strings and stack mutation; they do not execute the emitted strings. Six assertion descriptions incorrectly attribute an explicit setup load of EmitContext to the helper; exact child probes isolate 0/1/1 bridge state versus 0/1 owner state, with .2.6 owning correction. The MethodExpr-prefetch trap covers the named legacy seam only. Ten synthetic callback packages are required by default dependency builders; one representative callback per package is executed across forty assertions. The partial 90-assertion pipeline test compares 73 completed generated-text results for call/push, anonymous and named capture, boundary movement, mark copying, input/entry/local-match reads and compatibility aliases. Typed SourceLocation runtime calls and trace arguments are textual expectations, not standalone generated execution or recursive mark-isolation proof. Current invocation ownership stays with RecognitionTransaction; the older seven-helper named-mark fixture is different-label evidence. Reading stops after the opening is( for assertion74.
  Verification: Unchanged canonical commit 87b35665e retains PASS for thirteen completed subtests, ordinals 394–406 with 118 assertions; sequential TAP numbers and unchanged Phase0/own Perl/spec identities are verified. Fresh TOOLBOX6.2 extraction passes six lazy-load subtests with 42 assertions; exact child probes show EmitContext 0/1/1 before require/after require/after helper while each ActionIR owner goes 0/1. New .2.6 owns inaccurate EmitContext assertion descriptions. The helper-substitution test has 73 of 90 assertions read, followed by the opening of assertion 74; .1.51 owns the suffix. Historical whole-gate proof remains 1032 top-level tests; no fresh full gate, runtime repair, dependency build or push is claimed.
  Candidate proof: Exact 160-input/143-group/302-range audit and eleven-window replay pass. Preservation verifies 2,844 other files / 50,534,669 bytes, 505 prior task nodes, 53 other book files and 1,039 book headings; .2.5 and its complete recipe remain byte-exact, with only new pending repair .2.6 added. The durable six-test recipe replays all42 assertions and independent bridge 0/1/1 versus owner 0/1 states. All historical recipes and original scopes, parent Gitlink and exact two roadmap substitutions are preserved. Memory, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories are changes273 lines/58671 bytes and notes241/58910, below required rollover; concise new records route full evidence to the canonical task/card. Knowledge remains 1,151 facts / 9,226 keys and unchanged collection limits. Normal nine-doctrine hooks govern landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.50 - read ActionIR lazy-loading and capture lowering tests`

- ID: `CONFORMANCE-SOURCE-READING.1.51`
  Status: `done`
  Activation commit: `ec10be6b06934ba87c8c41b1f1f8d079714564a7`.
  Verification tier: `focused`
  Focused checks: Complete bounded source reading, exact baseline/window and retained canonical proof, fresh Toolbox lowering and four isolated mark-copy controls; Knowledge, preservation, memory, both history checks, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation only; no runtime, dependency, public-contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 51.
  Scope: `t/phase0_regression.t` lines 13632-14984
  Baseline evidence: 1353 fragments / 65519 decoded bytes; ordered range SHA-256 `cfcddcd8f858ea6f0ddf8f0a3c1ddb2a0dae70684781aef6972b8c4843dc20c7`.
  Dependencies: .1.50 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1353 fragments / 65519 bytes; ordered window SHA-256 `8b0f53760e7cc18be9d701d37d8d7f0c56a1a7a0c93727d97ef64ea4a3f69563`.
  Comprehension: Typed lowering text versus executing Get parsers; named marks isolate distinct parent/child labels here, not recursive same-label invocations. Whole-input/entry/local-match/live-cursor views remain distinct. Non-cursor captures end at current match start; until_cursor reaches current cursor; rest reaches input end. Take variants advance stored anonymous/named boundaries; two-mark takes move only start mark to supplied end. Split fixture yields alpha,beta,gamma or widths5,4; bridge restores prior anonymous boundary. Missing marks yield undef; exhausted tail yields empty string/zero. Whole-input line/column is one-based. Boundary helper leaves next Annotation and terminal END unconsumed; next Annotation is parsed by outer loop, END stays in rest. Source-shape checks establish referenced typed projection, not complete runtime negative coverage. The mark_copy missing-source fixture never seeds its target; fresh no-op controls establish a test gap under .2.7, not a production deletion defect.
  Verification: Unchanged canonical commit ec10be6b retains PASS for forty completed subtests, ordinals 407–446 with 266 assertions; sequential TAP numbers and unchanged Phase0/own Perl/spec identities are verified. Fresh four-case mark_copy diagnosis confirms original4/4 and deletion-no-op original4/4 both pass, while a seeded-zero pristine control passes4/4 and its deletion-no-op twin fails exactly assertion2 with target0 instead of undef. New .2.7 owns fixture repair; production clears the seeded target correctly. The final capture_slice_col test has its first assertion read and the second opened through the expected array; .1.52 owns the suffix. Retained whole-gate proof is1032 top-level tests, not fresh execution for this reading leaf. No runtime repair, dependency build, new full gate or push is claimed.
  Candidate proof: Exact 160-input/143-group/302-range audit and eleven-window replay pass. Preservation verifies 2,848 other files / 50,641,987 bytes, 509 prior task nodes, 53 other book files and all 1,039 headings; historical ranges, recipes, histories and parent Gitlink remain exact. The maintained four-case recipe reproduces the expected PASS/PASS/PASS/rejected outcomes in isolated processes. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories are changes168 lines/31170 bytes and notes164/31647, below rollover. Knowledge is 1,152 facts / 9,238 keys. Normal nine-doctrine hooks govern landing; no new canonical run is required by this focused leaf.
  Commit: `CONFORMANCE-SOURCE-READING.1.51 - read capture boundaries and diagnose mark-copy clearing test gap`

- ID: `CONFORMANCE-SOURCE-READING.1.52`
  Status: `done`
  Activation commit: `b71ea10aea6b498925d0c16d5cb84c159d8b228f`.
  Verification tier: `focused`
  Focused checks: Complete source reading, exact baseline/window and retained canonical proof, fresh Toolbox numeric-lowering compilation controls; Knowledge, preservation, memory, both history checks, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation only; no runtime, dependency, public-contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 52.
  Scope: `t/phase0_regression.t` lines 14985-16061
  Baseline evidence: 1077 fragments / 65180 decoded bytes; ordered range SHA-256 `852040242decbd55b0baa1f102069209f4fc087a79ce760ead45cf170ceb6906`.
  Dependencies: .1.51 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1077 fragments / 65180 bytes; ordered window SHA-256 `0cd7ac0599e5f1aaa474cb501b73cd912672f6a43f5401f814707576d3b10737`.
  Comprehension: Capture-boundary column/position suffix and runtime current-match/entry helpers distinguish stable immediate entry foo( at0..4 from local bar at4..7 and closing match at7..8. Group index0 is the first captured group; absent positional/named groups are undef, presence is1/0, outer list/map snapshots preserve earlier captures after the local slot changes. Start line/column aliases keep left-edge meaning; end projections use exclusive right-edge positions, including newline transitions. Explicit top_rule wins over the first authored marker. Named entry/match marks snapshot0/4/7 while later cursor reaches8; mark_here advances a checkpoint. clear_mark and mark_exists observe real pre-existing marks and before/after presence, including flow branches. Setup descriptor checks ASSIGN with zero raw fallback/unresolved helpers. The partial79-assertion method-contract test compares textual lowering for trim/coalesce, arithmetic reducers and Numeric::evaluate dispatch, string prefix/suffix and drop_front; these comparisons do not execute generated code. One num_min fixture has an extra authored and expected closing parenthesis; exact lowering fails compilation while the balanced twin compiles and returns2. New .2.8 owns that positive-fixture repair.
  Verification: Unchanged canonical commit ec10be6b retains PASS for 27 completed subtests, ordinals 447–473 with 129 assertions; sequential TAP numbers and unchanged Phase0/own Perl/spec identities are verified. Fresh Toolbox lowering reproduces the num_min fixture expectation but independent compilation rejects its extra closing parenthesis; removing that one authored character compiles and returns 2 for raw_name=abcd, limit=2. New .2.8 owns positive-fixture repair. The 79-assertion method-contract test has 41 complete assertions read and only the actual argument of assertion42; .1.53 owns the suffix. Retained whole-gate proof remains1032 top-level tests, separate from fresh focused diagnosis. No production repair, dependency build, new canonical run or push is claimed.
  Candidate proof: Exact 160-input/143-group/302-range audit and eleven-window replay pass. Preservation verifies 2,848 other files / 50,641,987 bytes, 510 prior task nodes, 53 other book files and all 1,039 headings; historical ranges, recipes, histories and parent Gitlink remain exact. The maintained numeric-fixture recipe independently reproduces original syntax failure and balanced value2. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories are changes172 lines/31736 bytes and notes168/32092, below rollover. Knowledge is1,153 facts/9,243 keys. Normal nine-doctrine hooks govern landing; no new canonical run is required by this focused leaf.
  Commit: `CONFORMANCE-SOURCE-READING.1.52 - read entry and match helpers and diagnose invalid numeric fixture`

- ID: `CONFORMANCE-SOURCE-READING.1.53`
  Status: `done`
  Activation commit: `0e7552f9f01f79b263d0fd3b111e73a3d562d7e4`.
  Verification tier: `focused`
  Focused checks: Complete source reading, exact baseline/window and retained canonical proof, fresh Toolbox push-label controls; Knowledge, preservation, memory, both history checks, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation only; no runtime, dependency, public-contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 53.
  Scope: `t/phase0_regression.t` lines 16062-16879
  Baseline evidence: 818 fragments / 65478 decoded bytes; ordered range SHA-256 `fc27e709b2e0b8fedb8f69039e4b3a9beee175ac7f2ab8ae091a04dfedd8278e`.
  Dependencies: .1.52 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 818 fragments / 65478 bytes; ordered window SHA-256 `81bcf143f79f0bceb1342b47b28ffae9f64dec588fbb8daa76da2a9ad35d14c8`.
  Comprehension: Method-contract suffix compares generated strings for drop_front, take, slice, take_last, drop_back, projected first/last, hash merges, call assignment and regex substitution; count normalization and empty/non-array branches are textual expectations, not executed numeric-domain coverage. The79-assertion test ends with descriptor RETURN/ASSIGN/REGEX_SUBST metadata and retains the .2.8 malformed num_min fixture. Push text checks distinguish current binding append from static child handler precedence for two bare tokens, plus scoped/indexed child forms. Executed controls append a/b, push the whole child payload as one element, and guard a capture append with is_nonempty; source dump proves one scalar-held items declaration. Two wrapped-target labels are inaccurate for bare-target inputs, confirmed by exact lowering and owned by .2.9. Array assignment/copy and nested returns preserve selected scalar-held/legacy accumulator paths, mixed numeric/string indexing, legacy tagged return and return_undef. Fluent/block comparisons check metadata equivalence; selected ICODE, ACODE and LXCODE equality is explicit, but no generalized runtime/generated-module equivalence follows. Collection pipelines compose inside nested arrays/hashes and IF/ELIF/ELSE/ENDIF or SWITCH/CASE/DEFAULT/ENDSWITCH nodes. Lifecycle switch/case remains partial after11 assertions.
  Verification: Unchanged canonical commit ec10be6b retains PASS for 13 completed subtests, ordinals 474–486 with 224 assertions; sequential TAP numbers and unchanged Phase0/own Perl/spec identities are verified. Fresh Toolbox extraction confirms exactly two wrapped-target descriptions actually exercise bare items bindings; .2.9 owns correction while preserving the two-bare-token static-handler precedence. The lifecycle switch/case equivalence test has11 completed assertions and the final compound assertion read only through its DEFAULT predicate; .1.54 owns its suffix. Retained whole-gate proof remains1032 top-level tests, separate from fresh focused diagnosis. The malformed num_min fixture remains .2.8-owned; no runtime repair, dependency build, new canonical run or push is claimed.
  Candidate proof: Exact 160-input/143-group/302-range audit and eleven-window replay pass. Preservation verifies 2,849 other files / 50,645,496 bytes, 511 prior task nodes, 53 other book files and all 1,039 headings; historical ranges, recipes, histories and parent Gitlink remain exact. The maintained two-label recipe reproduces current bare-binding lowering and handler-first fallback. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories are changes176 lines/32238 bytes and notes172/32527, below rollover. Knowledge is1,153 facts/9,245 keys. Normal nine-doctrine hooks govern landing; no new canonical run is required by this focused leaf.
  Commit: `CONFORMANCE-SOURCE-READING.1.53 - read collection and branch lowering contracts`

- ID: `CONFORMANCE-SOURCE-READING.1.54`
  Status: `done`
  Activation commit: `c7585a9604820c3c015ebc4ddcb2eafa5259fa7d`.
  Verification tier: `focused`
  Focused checks: Complete source reading, exact baseline/window and retained canonical direct/nested TAP proof; Knowledge, preservation, memory, both history checks, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation only; no runtime, dependency, public-contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 54.
  Scope: `t/phase0_regression.t` lines 16880-18057
  Baseline evidence: 1178 fragments / 65522 decoded bytes; ordered range SHA-256 `f002e310ba21be1c3e18ddd52ff977d482292dcc9bf5150b6803b76517aa4f06`.
  Dependencies: .1.53 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1178 fragments / 65522 bytes; ordered window SHA-256 `dfbb974fc119147c1fa1ef5035b4098fd8430e1190a99a873d6e51382ff77abb`.
  Comprehension: Multi-step action-edge and LX fluent/structured if/switch pairs compare exact ACODE/LXCODE, canonical node coverage, readiness and zero fallback/raw-dependency/unresolved counts; helpers ASSIGN/PUSH/SAY remain represented. Inline switch list, parenthesized structured branch, and attached case/default forms preserve code output; attached switch hit maps contain RETURN2 on action edges versus RETURN3 for LX because the separate authored action return is counted too. Inline if versus marker form filters marker-only ENDIF before comparing node coverage. Inline/list/structured/attached if twins retain action/LX code equality and node presence. Two complete lifecycle loops cover I,LS,LE,E,EX,IT, each six nested subtests/eight assertions per tag, comparing its code field plus canonical nodes/hits. Fluent outer action attached-if compares metadata/node/hit/readiness but has no exact ACODE assertion. None of these read fixtures executes its target parser or proves generated-module/runtime equivalence. Final seven-tag loop adds LX and is read only through its two descriptor-build assertions and first metadata assignment. No new defect established; existing branch runtime and test repair owners remain open.
  Verification: Unchanged canonical commit ec10be6b retains PASS for 20 completed subtests, ordinals 487–506 with 227 direct assertions, including12 nested subtest results. Those12 nested plans independently pass96 inner assertions (six lifecycle tags/eight assertions in each of two loops); every TAP sequence and unchanged Phase0/own Perl/spec identity is verified. The next seven-tag lifecycle loop has fixtures and two descriptor-build assertions read per iteration, stopping at its first metadata assignment; .1.55 owns the remaining six assertions per tag. No new defect, runtime execution, repair, dependency build, canonical run or push is claimed. Whole-gate1032 proof remains retained, and all existing repair prerequisites remain.
  Candidate proof: Exact 160-input/143-group/302-range audit and eleven-window replay pass. Preservation verifies 2,849 other files / 50,645,496 bytes, 512 prior task nodes, 53 other book files and all 1,039 headings; all earlier repairs, historical ranges, recipes, histories and parent Gitlink remain exact. Direct and nested retained TAP plans reconcile independently. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories are changes180 lines/32729 bytes and notes176/32992, below rollover. Knowledge is1,153 facts/9,246 keys. Normal nine-doctrine hooks govern landing; no new canonical run is required by this focused leaf.
  Commit: `CONFORMANCE-SOURCE-READING.1.54 - read structured branch and lifecycle equivalence coverage`

- ID: `CONFORMANCE-SOURCE-READING.1.55`
  Status: `done`
  Activation commit: `bbb20ca7c9efad0005f4d5e3d49c1a398c1aa376`.
  Verification tier: `focused`
  Focused checks: Complete source reading, exact baseline/window and retained canonical direct/nested TAP proof; Knowledge, preservation, memory, both history checks, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation only; no runtime, dependency, public-contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 55.
  Scope: `t/phase0_regression.t` lines 18058-19557
  Baseline evidence: 1500 fragments / 63518 decoded bytes; ordered range SHA-256 `1790d16fffc4de8547c8c257f769911a5df93d965b512a195799268f50d9b948`.
  Dependencies: .1.54 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 10 complete windows / 1500 fragments / 63518 bytes; ordered window SHA-256 `0f2a18bc08cda6675d7eb1014ca0f86d1b7ab4751e5fabf8b998980ea9faf881`.
  Comprehension: The seven-tag fluent outer attached-if suffix and mixed attached/marker branch twins compare descriptor construction, fallback, node/hit equality and readiness; they do not assert code-field equality even though the loop binds code_key. Nested marker switch inside if and if/elseif, nested inline switch inside those forms, and multi-case x/y/default switches in both if and else are compared between parenthesized branch blocks and attached branches. Action fixtures compare ACODE; the corresponding seven lifecycle tags compare their specific code field, canonical nodes/hits, fallback and readiness. Marker switch expected nodes include ENDSWITCH; inline-composite switch expected nodes do not require that marker-only node. Return_undef-only branch payloads and unbound branch selectors belong to descriptor fixtures, not executed branch-outcome coverage. Final completed action pair compares two-case switch bodies in if, elseif and else with independent selector names mode/mode2/kind; following lifecycle case list remains partial. No new defect or target runtime execution is established; existing branch/runtime and .2.5–.2.9 repair owners remain.
  Verification: Unchanged canonical commit ec10be6b retains PASS for16 completed subtests, ordinals507–522 with151 direct assertions, including56 nested subtest results. Eight seven-tag lifecycle loops separately verify448 inner assertions, with exact tag order, sequential TAP numbers and plans. Phase0/own Perl/spec identities remain unchanged. The next lifecycle test is read only through the I/LS/LE/E prefix of its cases list; .1.56 owns the remaining list, plan, fixtures and assertions. No new defect, target runtime execution, repair, dependency build, canonical run or push is claimed. Whole-gate1032 proof remains retained, and all existing repair prerequisites remain.
  Candidate proof: Exact 160-input/143-group/302-range audit and ten-window replay pass. Preservation verifies 2,849 other files / 50,645,496 bytes, 512 prior task nodes, 53 other book files and all 1,039 headings; all earlier repairs, historical ranges, recipes, histories and parent Gitlink remain exact. Direct and nested retained TAP plans reconcile independently. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories are changes184 lines/33221 bytes and notes180/33473, below rollover. Knowledge is1,153 facts/9,247 keys. Normal nine-doctrine hooks govern landing; no new canonical run is required by this focused leaf.
  Commit: `CONFORMANCE-SOURCE-READING.1.55 - read mixed branches and nested switch equivalence`

- ID: `CONFORMANCE-SOURCE-READING.1.56`
  Status: `done`
  Activation commit: `e258190c84fa85aa819c4e4eb13e353ec63d585f`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof; fresh Toolbox descriptor, changed-payload and capture controls; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and test-observation diagnosis; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 56.
  Scope: `t/phase0_regression.t` lines 19558-21057
  Baseline evidence: 1500 fragments / 64289 decoded bytes; ordered range SHA-256 `1ef2959331e2e7b7ffdfb0b0ee3da905223bf608e022bad0b756e60646982c18`.
  Dependencies: .1.55 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 10 complete windows / 1500 fragments / 64289 bytes; ordered window SHA-256 `212809d8081a3124d296fa3477c4a77a790ef50ce94329103c5f75a4ccbc8ce1`.
  Comprehension: Nested if/elseif marker and inline switches compare structured and attached forms. Three six-tag loops cover fluent inline switch, if branch blocks and switch branch blocks; a seven-tag loop checks attached switch hit maps. Five additional seven-tag nested-flow loops assert descriptor slots are undef and verify metadata for marker if/switch, composite if, inline switch and if/elseif bodies. Their rule-wide RETURN counts include the separate action-edge return; SWITCH hit counts are canonical metadata, not a literal count of authored switch calls. Action flat-list fixtures compose flat_hash/pick_keys and flat_array/sorted_keys but do not execute their target branches; the LX counterpart stops after assertion8. Fresh public-output probes establish that uppercase code-slot equality compares absent fields, and a changed payload still passes all48 inner assertions despite different captured generated returns. New .2.10 owns real code/behavior observation; .2.11 owns source-capture recipes that scalar-dereference an ARRAY. Prior generated-code equivalence wording is superseded; meaningful descriptor metadata and historical passes remain. No production runtime defect or repair is claimed.
  Verification: Unchanged canonical commit ec10be6b retains PASS for 18 completed subtests, ordinals 523–540 with 148 direct assertions, including 74 nested results. Eleven lifecycle loops separately verify 557 inner assertions, with exact tag order, TAP numbering and plans. Fresh original and changed-payload probes each pass all 48 inner assertions while twelve descriptors lack uppercase code slots; captured generated returns distinguish the payloads. Public source capture confirms ARRAY chunks and working explicit scalar capture. New .2.10 and .2.11 own both defects; prior slot-equality claims are superseded. The LX flat-list test is partial after eight of twelve assertions; .1.57 owns its suffix. No production runtime defect, source repair, dependency build, new canonical run or push is claimed.
  Candidate proof: Exact 160-input/143-group/302-range audit and ten-window replay pass. Preservation verifies 2,849 other files / 50,645,496 bytes, 512 prior task nodes, 53 other book files and all 1,039 headings; exactly two new repair nodes and one fact card are added. Historical ranges, recipes, histories and parent Gitlink remain exact. The maintained reproduction independently passes pristine and changed-payload controls, each48 inner assertions; I/LS/LE generated values differ while this handler omits E/EX/IT bodies. Source-capture shape controls pass. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories are changes188 lines/33765 bytes and notes184/34059, below rollover. Knowledge is1,154 facts/9,253 keys. Normal nine-doctrine hooks govern landing; this focused leaf requires no new canonical run.
  Commit: `CONFORMANCE-SOURCE-READING.1.56 - read switch coverage and own vacuous code comparisons`

- ID: `CONFORMANCE-SOURCE-READING.1.57`
  Status: `done`
  Activation commit: `1983e2fc4343ef45e70d5ece5ed12f39d9c6e028`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 57.
  Scope: `t/phase0_regression.t` lines 21058-22258
  Baseline evidence: 1201 fragments / 65530 decoded bytes; ordered range SHA-256 `f6bd4ff7b48da261c1d399dc421744880009011be4b3f3b4e6b692061e965445`.
  Dependencies: .1.56 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1201 fragments / 65530 bytes; ordered window SHA-256 `52807d4d6bde6106e84ccdb9edaf0b565589a4457e5959109722e984b50e87cb`.
  Comprehension: Completes LX flat-list metadata, then reads action/LX copy snapshots, if/elseif and switch snapshot branches, optional semicolons, and structured/fluent bare else/endif/default/endcase/endswitch markers. Two seven-tag loops each contain paired if/switch subtests; a five-tag optional-semicolon loop covers LS/LE/E/EX/IT and compares explicit expected hit maps without a code-slot assertion. Three more seven-tag loops cover marker-switch attached branches, outer attached switch blocks and plain marker branches inside those blocks. ENDCASE is explicitly present twice in the bare-switch fixture; optional-semicolon fixtures omit it, so hit maps remain fixture-specific. Snapshot fixtures do not execute targets or prove copy isolation. Uppercase ACODE/LXCODE/code_key comparisons retain existing .2.10 observation-gap ownership; they are not generated-code equivalence proof. Metadata, node presence, hit maps, fallback and readiness are the actual observations. The final fluent outer-switch test has ten completed assertions and begins its eleventh ok; .1.58 owns the suffix. No new defect or runtime execution is established; .2.5–.2.11 and all prior repair prerequisites remain.
  Verification: Unchanged canonical commit ec10be6b retains PASS for 18 completed subtests, ordinals 541–558 with 195 direct assertions, including 59 nested results. Six lifecycle loops separately verify 472 inner assertions with exact tag order, TAP numbering and plans. The last fluent outer-switch test is partial after ten of eleven assertions; .1.58 owns its final ok expression. Existing .2.10 owns uppercase code-slot comparisons; those assertions are not generated-code equivalence proof. Snapshot descriptors do not establish runtime copy isolation. No new defect, runtime execution, source repair, dependency build, canonical run or push is claimed; all prerequisites remain.
  Candidate proof: Exact 160-input/143-group/302-range audit and eleven-window replay pass. Preservation verifies 2,850 other files / 50,654,378 bytes, 514 prior task nodes, 53 other book files and all 1,039 headings; the .2.10/.2.11 reproduction, all prior repairs, historical ranges, recipes, histories and parent Gitlink remain exact. Direct and nested retained TAP plans reconcile independently. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories are changes192 lines/34295 bytes and notes188/34630, below rollover. Knowledge is1,154 facts/9,254 keys. Normal nine-doctrine hooks govern landing; no new canonical run is required by this focused leaf.
  Commit: `CONFORMANCE-SOURCE-READING.1.57 - read snapshot and bare-marker descriptor coverage`

- ID: `CONFORMANCE-SOURCE-READING.1.58`
  Status: `done`
  Activation commit: `cebbd8466f06a89fd9fbb091c9b710a69000ea76`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 58.
  Scope: `t/phase0_regression.t` lines 22259-23758
  Baseline evidence: 1500 fragments / 62624 decoded bytes; ordered range SHA-256 `043f210793270c411dde8ae43deff76225538fd32effa094c0de5887c9f67705`.
  Dependencies: .1.57 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 10 complete windows / 1500 fragments / 62624 bytes; ordered window SHA-256 `617330f9895feb45a764ca6838fc3682994e771eac5a675bab8c3c71517ffbe6`.
  Comprehension: Completes fluent outer-switch readiness, then reads a seven-tag fluent outer-switch metadata loop with no code-slot equality. Mixed attached/plain branch fixtures compare all-attached, structured and fluent forms, retaining existing .2.10 limits on uppercase-slot assertions. Five marker-switch nested-flow families cover marker if, marker switch, composite if, inline switch and composite if/elseif; action and lifecycle tests pin metadata, unresolved lists, fallback and explicit undef code-slot shape. Marker outer plus nested marker switch expects two SWITCH/two ENDSWITCH hits; marker outer plus two nested inline switches expects three SWITCH/one ENDSWITCH, so representation-specific hit maps are distinct from the earlier inline-outer metadata. Lifecycle RETURN totals include the separate action edge. A deeper inline-outer fixture nests if/elseif and independent mode/mode2/kind/kind2 switches, comparing structured versus attached if forms; its labels explicitly claim current slot shape, not generated code. No target parser executes. The next marker-outer counterpart stops inside its first fixture. No new defect or repair; code-slot gap .2.10, capture recipes .2.11 and earlier repairs retain prerequisites.
  Verification: Unchanged canonical commit ec10be6b retains PASS for 18 completed subtests, ordinals 559–576 with 160 direct assertions, including 63 nested results. Nine seven-tag loops separately verify 476 inner assertions with exact tag order, TAP numbering and plans. The next marker-outer nested if/elseif inline-switch test is partial inside its first fixture; .1.59 owns the suffix. Current-slot-shape checks are distinguished from absent-slot equivalence claims, which remain .2.10-owned. No new defect, target runtime execution, repair, dependency build, canonical run or push is claimed; all prerequisites remain.
  Candidate proof: Exact 160-input/143-group/302-range audit and ten-window replay pass. Preservation verifies 2,850 other files / 50,654,378 bytes, 514 prior task nodes, 53 other book files and all 1,039 headings; the .2.10/.2.11 reproduction, prior repairs, historical ranges, recipes, histories and parent Gitlink remain exact. An additional whole-roadmap normalization check proves all non-checkpoint prose is byte-preserved. Direct and nested retained TAP plans reconcile independently. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories are changes196 lines/34830 bytes and notes192/35134, below rollover. Knowledge is1,154 facts/9,255 keys. Normal nine-doctrine hooks govern landing; no new canonical run is required by this focused leaf.
  Commit: `CONFORMANCE-SOURCE-READING.1.58 - read mixed switch and nested marker metadata`

- ID: `CONFORMANCE-SOURCE-READING.1.59`
  Status: `done`
  Activation commit: `67f38c76cddd9074f1697687e1c99c2dad9581cb`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 59.
  Scope: `t/phase0_regression.t` lines 23759-25258
  Baseline evidence: 1500 fragments / 55331 decoded bytes; ordered range SHA-256 `7d72c94dee04a686c444c25f061c9aa75dfaefcc8e5854f2cc2b8f5bdcb2513d`.
  Dependencies: .1.58 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 9 complete windows / 1500 fragments / 55331 bytes; ordered window SHA-256 `8820745511b704f049a371d28568870836a228096b590b1193370fa18000a75f`.
  Comprehension: Reads nested if/elseif switches inside outer case/default branches, comparing parenthesized structured if bodies with attached if/elseif/else bodies. Completed pairs cover marker outer with inline inner switches, inline outer with marker inner switches, marker outer with marker inner switches, and inline outer with multi-case marker switches; the marker-outer multi-case action pair also completes. Independent mode/mode2/kind/kind2 selectors and two-case alternatives x/y, a/b, m/n, p/q remain unbound descriptor inputs with return_undef payloads. Thirteen-assertion action tests and nine-assertion-per-tag lifecycle tests compare descriptor builds, current uppercase slot shape, fallback, unresolved counts, node/hit equality, readiness and control-node presence. ENDSWITCH is expected when a marker surface appears. These checks explicitly claim slot shape and do not establish generated-code or executed branch equivalence. Four complete seven-tag loops are read; the next seven-tag marker-outer multi-case loop remains inside its first fixture. No new defect or runtime execution; existing .2.10 equivalence gap, .2.11 capture recipes and all earlier repairs retain prerequisites.
  Verification: Unchanged canonical commit ec10be6b retains PASS for nine completed subtests, ordinals 577–585 with 93 direct assertions, including 28 nested results. Four seven-tag lifecycle loops separately verify 252 inner assertions, each nine assertions per tag, with exact TAP numbering and plans. The following marker-outer multi-case lifecycle loop has its plan read but is partial inside the first fixture; .1.60 owns its suffix. Explicit slot-shape and metadata checks do not establish code or target execution equivalence. No new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.
  Candidate proof: Exact 160-input/143-group/302-range audit and nine-window replay pass. Preservation verifies 2,850 other files / 50,654,378 bytes, 514 prior task nodes, 53 other book files and all 1,039 headings; all prior repair evidence, historical ranges, recipes, histories and parent Gitlink remain exact. Whole-roadmap normalization preserves all non-checkpoint prose. Direct and nested retained TAP plans reconcile independently. Memory, both history-pressure checks, mdBook, public mutation (69 files / 50 mutations), public selector (68 files / 11 contrast mutations) and diff checks pass. Hot histories are changes200 lines/35367 bytes and notes196/35674, below rollover. Knowledge is1,154 facts/9,256 keys. Normal nine-doctrine hooks govern landing; no new canonical run is required by this focused leaf.
  Commit: `CONFORMANCE-SOURCE-READING.1.59 - read deep switch nesting and descriptor slot shape`

- ID: `CONFORMANCE-SOURCE-READING.1.60`
  Status: `done`
  Activation commit: `b196e4175296b251b4d311453cd3c4206df8b436`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 60.
  Scope: `t/phase0_regression.t` lines 25259-26758
  Baseline evidence: 1500 fragments / 55852 decoded bytes; ordered range SHA-256 `0b1b9ef599543e4e054aa5eb7c9f33c5cef7f36686c6d6272acce4fe67f8c2e7`.
  Dependencies: .1.59 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 9 complete windows / 1500 fragments / 55852 bytes; ordered window SHA-256 `a72b414e4aba4d0b75d5895dc4bb7520ff47518e158903ab2d3d1882064ffb91`.
  Comprehension: Completes the marker-outer composite if/elseif multi-case marker-switch lifecycle pair, then reads inline and marker outer switches containing composite if/elseif with multi-case inline switches. Structured and attached if forms compare descriptor builds, slot shape, zero fallback/unresolved counts, node/hit equality, readiness and expected control nodes; selectors remain unbound descriptor inputs and return_undef payloads do not prove branch execution. Reads inline/marker outer and inner multi-case switch combinations without intervening if. These metadata-only fixtures explicitly expect absent uppercase slots, CASE 5, DEFAULT 3, RETURN 6 for action or 7 for lifecycle, SWITCH 1 for inline outer or 3 for marker outer, and ENDSWITCH 0/1/2/3 by surface. Completes six seven-tag lifecycle loops: three with nine assertions per tag and three with seven. The final marker/marker lifecycle counterpart remains partial. No new defect or runtime execution; .2.10 code-equivalence observation limits, .2.11 capture recipes and all earlier repairs retain prerequisites.
  Verification: Unchanged canonical commit ec10be6b retains PASS for twelve completed subtests, ordinals 586–597 with 108 direct assertions, including 42 nested results. Six seven-tag lifecycle loops separately verify 336 inner assertions: three loops with nine assertions per tag and three with seven, with exact TAP numbering and plans. The following marker/marker multi-case lifecycle loop has its plan read but is partial inside the first fixture; .1.61 owns its suffix. Explicit slot-shape and metadata checks do not establish code or target execution equivalence. No new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.
  Candidate proof: Exact nine-window and 143-group/302-range audits PASS. Preserve 2,850 other files / 50,654,378 bytes, 514 prior task nodes, all 53 other book files and 1,039 headings, historical recipes/ranges and all noncheckpoint roadmap text. Memory60; histories204/35894 and200/36208 lines/bytes; Knowledge1154/9257, rendered book, direct public mutation69/50 and selector68/11 checks, git diff --check PASS. Normal doctrines govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.60 - read multi-case switch composition and metadata coverage`

- ID: `CONFORMANCE-SOURCE-READING.1.61`
  Status: `done`
  Activation commit: `618e60c861e2231dbccd375040d04b346150fc85`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 61.
  Scope: `t/phase0_regression.t` lines 26759-28258
  Baseline evidence: 1500 fragments / 60428 decoded bytes; ordered range SHA-256 `d63bc78bbc069074064e1eb2fb5fc845d90c690c719efb8dd8ef1c49d18a0e85`.
  Dependencies: .1.60 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 10 complete windows / 1500 fragments / 60428 bytes; ordered window SHA-256 `2c976b6b4b826194edf2787f6fc80ba2b2b7e692c21740b5f43795c6ceba63f5`.
  Comprehension: Completes the previous marker/marker multi-case lifecycle metadata loop. Reads structured-argument versus attached inline-switch branch bodies containing multi-case marker switches, composite if/elseif, composite if/elseif with deeper alternating marker flow, and directly nested marker if/switch controls. Reads plain versus attached marker-switch branches with composite if/elseif. Action pairs use thirteen assertions and lifecycle pairs nine per I/LS/LE/E/EX/IT/LX tag; metadata compares fallback, raw dependencies, unresolved helpers, node/hit equality, readiness and control-node presence. The code-output-labelled assertions compare uppercase descriptor slots and stay under existing .2.10 inventory, not emitted-code or target execution proof. Deep marker fixtures use independent kind1..kind5 and level1..level4 selectors with A..E alternatives and undef payloads. The next marker-outer composite-if deep-marker action pair is partial after five assertions; both fixtures are read. No independently reproduced new defect or runtime execution; .2.10/.2.11 and all earlier repairs retain prerequisites.
  Verification: Unchanged canonical commit ec10be6b retains PASS for eleven completed subtests, ordinals 598–608 with 107 direct assertions, including 42 nested results. Six seven-tag lifecycle loops separately verify 364 inner assertions: one loop with seven assertions per tag and five with nine, with exact TAP numbering and plans. The following deep-marker action pair has both fixtures and five of thirteen assertions read; .1.62 owns its suffix. Code-output-labelled slot comparisons remain in existing .2.10 inventory and do not establish emitted-code or target execution equivalence. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.
  Candidate proof: Exact ten-window and 143-group/302-range audits PASS. Preserve 2,850 other files / 50,654,378 bytes, 514 prior task nodes, all 53 other book files and 1,039 headings, historical recipes/ranges and all noncheckpoint roadmap text. Memory60; histories208/36457 and204/36786 lines/bytes; Knowledge1154/9258, rendered book, direct public mutation69/50 and selector68/11 checks, git diff --check PASS. Normal doctrines govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.61 - read structured switch branch comparisons and preserve observation limits`

- ID: `CONFORMANCE-SOURCE-READING.1.62`
  Status: `done`
  Activation commit: `335267bf1968712ad5a1f7f60af361be597e4c04`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 62.
  Scope: `t/phase0_regression.t` lines 28259-29758
  Baseline evidence: 1500 fragments / 60456 decoded bytes; ordered range SHA-256 `68339aadd8a590c268607deb3bf3b4adea0e958ea7ac4507ccf71b0bbced1048`.
  Dependencies: .1.61 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 10 complete windows / 1500 fragments / 60456 bytes; ordered window SHA-256 `b606ad20c57aada668dd3790b00eecd8df6f00237325af1a7718a8662c05f99d`.
  Comprehension: Completes marker-outer composite-if deep-marker comparisons and reads structured/list versus attached inline-switch branches and plain versus attached marker-switch branches containing composite if/elseif with multi-case marker switches. Marker outer branches also carry three alternating marker if/switch levels. Same-family comparisons include canonical node/hit equality, fallback/unresolved/readiness and action raw-dependency checks. Cross-family inline versus marker outer switches share attached branch blocks with deep marker nesting or nested multi-case marker switches; these compare node coverage and have no hit-map equality assertion, using twelve action assertions or eight per lifecycle tag rather than thirteen/nine. All output-labelled comparisons remain uppercase descriptor-slot observations under .2.10; no branch execution or emitted-code equality is established. Four nine-assertion and one eight-assertion seven-tag loops complete. The final cross-family lifecycle declaration is partial after its first two case entries. No independently reproduced new defect or runtime execution; .2.10/.2.11 and all earlier repairs retain prerequisites.
  Verification: Unchanged canonical commit ec10be6b retains PASS for eleven completed subtests, ordinals 609–619 with 111 direct assertions, including 35 nested results. Five seven-tag lifecycle loops separately verify 308 inner assertions: four loops with nine assertions per tag and one with eight, with exact TAP numbering and plans. The next outer-family multi-case lifecycle declaration has only its I and LS entries read; .1.63 owns its suffix. Cross-family node coverage does not claim equal hit counts. Code-output-labelled slot comparisons remain in existing .2.10 inventory and do not establish emitted-code or target execution equivalence. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.
  Candidate proof: Exact ten-window and 143-group/302-range audits PASS. Preserve 2,850 other files / 50,654,378 bytes, 514 prior task nodes, all 53 other book files and 1,039 headings, historical recipes/ranges and all noncheckpoint roadmap text. Memory60; histories212/37015 and208/37334 lines/bytes; Knowledge1154/9259, rendered book, direct public mutation69/50 and selector68/11 checks, git diff --check PASS. Normal doctrines govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.62 - read switch outer-family comparisons and exact metadata limits`

- ID: `CONFORMANCE-SOURCE-READING.1.63`
  Status: `done`
  Activation commit: `04d32b09356ede3be91337334a6431e1d745568f`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 63.
  Scope: `t/phase0_regression.t` lines 29759-31258
  Baseline evidence: 1500 fragments / 52166 decoded bytes; ordered range SHA-256 `9c6f31e671585a8f3ea8dbffd67bb2d7afef67fb63912cc57d7f146ad3c30967`.
  Dependencies: .1.62 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 9 complete windows / 1500 fragments / 52166 bytes; ordered window SHA-256 `0cadf02b6261aa31c991d3633f7a8f54d3be2cb18e830ab57632a8da02d29bd8`.
  Comprehension: Completes the outer-family attached-branch nested multi-case marker-switch lifecycle comparison, whose eight assertions include node-list equality. Subsequent inline versus marker outer switch pairs contain nested multi-case inline switches, composite if/elseif, composite if/elseif with deep marker nesting, and composite if/elseif with multi-case marker or inline switches. These eleven-assertion action and seven-assertion lifecycle pairs compare builds, uppercase output-labelled slots, fallback and readiness/unresolved conditions, with action raw-dependency checks; their final assertion checks selected marker-descriptor control nodes without comparing complete node lists or hit maps. Thus selected-node presence is distinct from the carried node-equality check, metadata parity and execution parity. Five seven-tag loops complete: one eight-assertion loop and four seven-assertion loops. Independent selectors and undef payloads remain descriptor inputs; code-output-labelled slot observations stay .2.10-owned. The final seven-tag loop is partial inside its first fixture. No independently reproduced new defect or runtime execution; .2.10/.2.11 and all earlier repairs retain prerequisites.
  Verification: Unchanged canonical commit ec10be6b retains PASS for ten completed subtests, ordinals 620–629 with 90 direct assertions, including 35 nested results. Five seven-tag lifecycle loops separately verify 252 inner assertions: one loop with eight assertions per tag and four with seven, with exact TAP numbering and plans. The following composite-if multi-case inline-switch lifecycle loop is partial inside its first fixture; .1.64 owns its suffix. Selected marker-node presence is not equality of node lists or hit maps. Code-output-labelled slot comparisons remain in existing .2.10 inventory and do not establish emitted-code or target execution equivalence. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.
  Candidate proof: Exact nine-window and 143-group/302-range audits PASS. Preserve 2,850 other files / 50,654,378 bytes, 514 prior task nodes, all 53 other book files and 1,039 headings, historical recipes/ranges and all noncheckpoint roadmap text. Memory60; histories216/37549 and212/37871 lines/bytes; Knowledge1154/9260, rendered book, direct public mutation69/50 and selector68/11 checks, git diff --check PASS. Normal doctrines govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.63 - read outer-family selected-node checks and comparison limits`

- ID: `CONFORMANCE-SOURCE-READING.1.64`
  Status: `done`
  Activation commit: `55cb6fdf9545e2764956303f12b9de7ae140e91a`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 64.
  Scope: `t/phase0_regression.t` lines 31259-32758
  Baseline evidence: 1500 fragments / 54211 decoded bytes; ordered range SHA-256 `55d15ae7d6a7c37ce5678f5b1fd42fa9463d2539c6c1f7efa08d5db9fda56b3e`.
  Dependencies: .1.63 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 9 complete windows / 1500 fragments / 54211 bytes; ordered window SHA-256 `c37e9c1631c4bbf54e5fa1eb9af15a2b8914e9fbb8c941937902c704e6ad8963`.
  Comprehension: Completes the seven-assertion cross-family lifecycle loop, retaining selected marker-node presence rather than node/hit equality. Same-family plain/attached marker branches containing multi-case marker switches and structured/list/attached inline or marker branches containing composite if/elseif multi-case inline switches use thirteen action or nine lifecycle assertions, including node/hit equality; uppercase output-labelled slot comparisons stay .2.10-owned. Standalone three-level mutually nested marker if/switch tests use seven action or six lifecycle assertions: builds, fallback, readiness/unresolved conditions, at-least-three IF/SWITCH/CASE/DEFAULT helper hits and expected control nodes. Marker outer attached branches containing mutual nesting use seven assertions for both action and lifecycle; lifecycle adds explicit undef slot shape while action checks raw dependencies. These are descriptor metadata observations, not branch execution. Six seven-tag loops complete with per-tag plans 7,9,9,9,6,7. The following composite-if deep-marker action test is partial in its first fixture. No independently reproduced new defect or runtime execution; .2.10/.2.11 and all earlier repairs retain prerequisites.
  Verification: Unchanged canonical commit ec10be6b retains PASS for eleven completed subtests, ordinals 630–640 with 95 direct assertions, including 42 nested results. Six seven-tag lifecycle loops separately verify 329 inner assertions with per-tag plans 7,9,9,9,6,7 and exact TAP numbering. The next composite-if deep-marker action test is partial in its first fixture; .1.65 owns its suffix. Minimum helper-hit and node-presence assertions establish bounded descriptor metadata coverage. Code-output-labelled slot comparisons remain in existing .2.10 inventory and do not establish emitted-code or target execution equivalence. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.
  Candidate proof: Exact nine-window and 143-group/302-range audits PASS. Preserve 2,850 other files / 50,654,378 bytes, 514 prior task nodes, all 53 other book files and 1,039 headings, historical recipes/ranges and all noncheckpoint roadmap text. Memory60; histories220/38095 and216/38439 lines/bytes; Knowledge1154/9261, rendered book, direct public mutation69/50 and selector68/11 checks, git diff --check PASS. Normal doctrines govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.64 - read mutual marker nesting and bounded helper coverage`

- ID: `CONFORMANCE-SOURCE-READING.1.65`
  Status: `done`
  Activation commit: `e0123d86e06b217b1e74afa59c47c78803a65713`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 65.
  Scope: `t/phase0_regression.t` lines 32759-33715
  Baseline evidence: 957 fragments / 65498 decoded bytes; ordered range SHA-256 `02117d7574f9a1c24d7cd383c22a319447676bf7a77dd87368f8d16d22bc3274`.
  Dependencies: .1.64 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 957 fragments / 65498 bytes; ordered window SHA-256 `3086a7521b7042366071ae5a8e16d12033568731a8b5d5a28bf2bbc24d27a8e0`.
  Comprehension: Completes deep mutual marker if-branch comparisons, then reads fluent/structured snapshot branches and join_values, projected keys/values, first/last, length, composed container reads, drop_front, take and slice descriptors. The helper comparisons have twelve assertions: builds, uppercase-slot equality, fallback, raw dependencies, unresolved helpers, node-list equality, readiness and required nodes. Existing .2.10 owns absent-slot observations; node presence does not establish runtime helper semantics, copy isolation, or hit-map equality. Repeated ASSIGN predicates still claim presence only. Lifecycle slice-array comparison is partial after its tenth assertion; .1.66 owns readiness and final node check.
  Verification: Unchanged canonical commit ec10be6b retains PASS for nineteen completed subtests, ordinals 641–659 with 222 direct assertions, including seven nested results. The seven-tag lifecycle loop separately verifies 63 inner assertions with nine assertions per tag and exact TAP numbering. Seventeen complete fluent/structured helper comparisons have twelve assertions each. Their uppercase-slot equality remains .2.10-owned; metadata node presence and node-list equality do not establish runtime helper semantics, copy isolation or hit-map equality. The lifecycle slice-array test is partial after assertion ten; .1.66 owns readiness and final node checks. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.
  Candidate proof: Exact inventory and .1.65 window replay PASS; cumulative 65/143 independently totals 83,210 fragments / 3,299,611 baseline bytes. Retained TAP identity/numbering PASS. Preservation PASS for 2,850 other files, 514 prior nodes and all 1,039 book headings. Knowledge 1,154 facts / 9,262 keys; memory 60 lines; history bounds, mdBook build, mutation public surface (50 mutations), aggregate selector (11 contrasts / capability 100 matches) and diff whitespace PASS. Normal commit doctrines are the final boundary.
  Commit: `CONFORMANCE-SOURCE-READING.1.65 - read fluent container helper comparisons and observation limits`

- ID: `CONFORMANCE-SOURCE-READING.1.66`
  Status: `done`
  Activation commit: `4c25d22ac4ce0bd9376302d38852cc3a884e22c5`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 66.
  Scope: `t/phase0_regression.t` lines 33716-34545
  Baseline evidence: 830 fragments / 65423 decoded bytes; ordered range SHA-256 `6cb1c5c9962a88b5160eaf2ac09cb56d3de4c47d0ad116eb50c7978af9ec9db2`.
  Dependencies: .1.65 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 830 fragments / 65423 bytes; ordered window SHA-256 `c8fbb8436dda0ca3c4c2e13fb09209cb1a87ac3e54995f521ad690153ddf6b00`.
  Comprehension: Completes the lifecycle slice-array readiness/node checks, then reads action/LX fluent-structured pairs for take_last, starts_with/ends_with, contains_substr, replace_substr, rm_prefix/rm_suffix, cat, matches, num_add/num_sub and num_mul/num_div. Action min/max is complete; lifecycle min/max ends after its first descriptor-build assertion. Every completed subtest uses twelve descriptor assertions; replace_substr also requires IF/ELSE nodes. Repeated ASSIGN terms assert presence only. No helper-result or hit-map equality is checked; .2.10 retains meaningful code-observation repair ownership. No new runtime defect is established.
  Verification: Unchanged canonical commit ec10be6b retains PASS for twenty completed subtests, ordinals 660–679 with 240 direct assertions, twelve per subtest and no nested plans. Exact TAP numbering and source identity are verified. Action/LX pairs cover take_last, scalar boundaries and transforms, substring operations, concatenation, regex predicates, arithmetic and product/division; the action min/max comparison is complete. Existing .2.10 owns meaningful code observation; descriptor-node comparisons do not establish helper results or hit-map equality. The lifecycle min/max test is partial after its first build assertion; .1.67 owns the remaining eleven assertions. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.
  Candidate proof: Exact inventory and .1.66 window replay PASS; cumulative 66/143 independently totals 84,040 fragments / 3,365,034 baseline bytes. Retained TAP identity/numbering PASS. Preservation PASS for 2,850 other files, 514 prior nodes and all 1,039 book headings. Knowledge 1,154 facts / 9,263 keys; memory 60 lines; history bounds, mdBook build, mutation public surface (50 mutations), aggregate selector (11 contrasts / capability 100 matches) and diff whitespace PASS. Normal commit doctrines are the final boundary.
  Commit: `CONFORMANCE-SOURCE-READING.1.66 - read scalar and numeric descriptor comparisons`

- ID: `CONFORMANCE-SOURCE-READING.1.67`
  Status: `done`
  Activation commit: `b193bfa9d9615d5fdb2299caf04dd54d55e2e366`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 67.
  Scope: `t/phase0_regression.t` lines 34546-35429
  Baseline evidence: 884 fragments / 65500 decoded bytes; ordered range SHA-256 `ee0342959ecfbfb9c39a7587cf966140a5a97437980a38a35f168011be428850`.
  Dependencies: .1.66 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 884 fragments / 65500 bytes; ordered window SHA-256 `bb1fc116fa44e396ffb67f08fc017e0f2445fde3899c086284da032f9ceb07ed`.
  Comprehension: Completes lifecycle min/max, then action/LX modulo, clamp, drop_back and combined drop_front/drop_back comparisons. Join-values and flat-list payloads each cover action/LX if/elseif and switch branches. Direct call-value pairs plus action if/elseif capture Leaf into retv and return hash/array payloads. All completed plans use twelve descriptor assertions; node requirements distinguish IF/ELIF, SWITCH/CASE/DEFAULT and ASSIGN/CALL/RETURN. Existing .2.10 owns meaningful code observation; these checks do not execute helper values, branch choices or Leaf call results. The action switch call-value test has eleven assertions complete but its final node predicate is partial after CALL; .1.68 owns the suffix.
  Verification: Unchanged canonical commit ec10be6b retains PASS for twenty completed subtests, ordinals 680–699 with 240 direct assertions, twelve per subtest and no nested plans. Exact TAP numbering and source identity are verified. Modulo/clamp and drop helpers precede action/LX join-values and flat-list branches, direct call capture and action if/elseif call capture. Existing .2.10 owns meaningful code observation; descriptor checks do not establish helper values, executed branch choices or Leaf call results. The action switch call-value test has eleven complete assertions and a partial final node predicate after CALL; .1.68 owns its suffix. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.
  Candidate proof: Exact inventory and .1.67 window replay PASS; cumulative 67/143 independently totals 84,924 fragments / 3,430,534 baseline bytes. Retained TAP identity/numbering PASS. Preservation PASS for 2,850 other files, 514 prior nodes and all 1,039 book headings. Knowledge 1,154 facts / 9,264 keys; memory 60 lines; history bounds, mdBook build, mutation public surface (50 mutations), aggregate selector (11 contrasts / capability 100 matches) and diff whitespace PASS. Normal commit doctrines are the final boundary.
  Commit: `CONFORMANCE-SOURCE-READING.1.67 - read payload branches and captured-call descriptor comparisons`

- ID: `CONFORMANCE-SOURCE-READING.1.68`
  Status: `done`
  Activation commit: `c69ece0e62701d44d64f101c97305ee59323d820`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 68.
  Scope: `t/phase0_regression.t` lines 35430-36290
  Baseline evidence: 861 fragments / 65511 decoded bytes; ordered range SHA-256 `d9b5680c28c98724837615ea8b3b918129645c7170e1a4f0f434a213ccf5f38e`.
  Dependencies: .1.67 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 861 fragments / 65511 bytes; ordered window SHA-256 `01426c078629e81653e48b56bc551044f7f812cbf5fa75dce094c2a97194a1e7`.
  Comprehension: Completes action switch and LX call branches, then nested accessor, array normalization and case/filter descriptor pairs. Coalesce/coalesce_nonempty, definedness and aggregate emptiness have both direct lowering checks and action/LX descriptor pairs. Direct expectations distinguish first-defined from defined-nonempty fallback, scalar/array/hash emptiness and RuntimeLogical truthy flow wrappers. Scalar trim/lowercase/uppercase expectations use SourceLocation spans and UnicodeCaseMapping. These seventeen direct textual assertions are meaningful lowering observations but do not execute the resulting target code. Descriptor uppercase-slot comparisons remain .2.10-owned. The next action scalar-normalization descriptor test is partial after its fluent fixture; .1.69 owns the structured fixture and assertions.
  Verification: Unchanged canonical commit ec10be6b retains PASS for twenty-two completed subtests, ordinals 700–721 with 221 direct assertions and no nested plans. Seventeen descriptor comparisons contribute 204 assertions; five direct-lowering plans of 2,3,4,5,3 contribute seventeen textual assertions. Exact TAP numbering and source identity are verified. Lowering observations distinguish fallback, definedness, aggregate emptiness and scalar normalization; they do not execute generated target code. Descriptor uppercase-slot comparisons remain .2.10-owned. The next action scalar-normalization comparison is partial after its fluent fixture; .1.69 owns the structured fixture and assertions. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.
  Candidate proof: Exact inventory and .1.68 window replay PASS; cumulative 68/143 independently totals 85,785 fragments / 3,496,045 baseline bytes. Retained TAP identity/numbering PASS. Preservation PASS for 2,850 other files, 514 prior nodes and all 1,039 book headings. Knowledge 1,154 facts / 9,265 keys; memory 60 lines; history bounds, mdBook build, mutation public surface (50 mutations), aggregate selector (11 contrasts / capability 100 matches) and diff whitespace PASS. Normal commit doctrines are the final boundary.
  Commit: `CONFORMANCE-SOURCE-READING.1.68 - read fallback lowering and normalization metadata`

- ID: `CONFORMANCE-SOURCE-READING.1.69`
  Status: `done`
  Activation commit: `e057c033665bf16f05ac7d9cd2963be0761a36ea`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 69.
  Scope: `t/phase0_regression.t` lines 36291-36947
  Baseline evidence: 657 fragments / 65437 decoded bytes; ordered range SHA-256 `1a359611867e9800e2915010b594ad8093c30ae4f37025d02c22f0a5bd1cacef`.
  Dependencies: .1.68 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 657 fragments / 65437 bytes; ordered window SHA-256 `69327ea77a1e57cca29663241de96f0d256a4301a3ac06781867c8b6e43a1ec7`.
  Comprehension: Completes action/LX scalar normalization and count descriptors, then exact lowering for count, contains, matches, contains_substr, replace_substr, rm_prefix/rm_suffix, cat, value-layer emptiness, index_of and count_keys. Text expectations distinguish undefined needles, literal replacement with trailing-field preservation, empty/nonmatching boundary identity, cat JSON booleans/negative-zero normalization and other-reference rejection, first-match index with undef absence, and scalar reducers versus guarded aggregate expressions. Suffix fixture composes replacement/normalization and has no explicit coalesce input. These are textual lowering observations, not evaluated runtime results. Nine complete descriptor comparisons retain .2.10 code-slot limits. Lifecycle count_keys stops after both descriptor-build assertions; .1.70 owns its remaining ten assertions.
  Verification: Unchanged canonical commit ec10be6b retains PASS for nineteen completed subtests, ordinals 722–740 with 150 direct assertions and no nested plans. Nine descriptor comparisons contribute 108 assertions; ten direct-lowering plans (nine of four and one of six) contribute 42 textual assertions. Exact TAP numbering and source identity are verified. Membership, literal replacement, boundary removal, concatenation, emptiness, index and reducer expectations observe lowering text, not evaluated target results. Descriptor uppercase-slot comparisons remain .2.10-owned. Lifecycle count_keys is partial after its two descriptor-build assertions; .1.70 owns the remaining ten. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.
  Candidate proof: Exact inventory and .1.69 window replay PASS; cumulative 69/143 independently totals 86,442 fragments / 3,561,482 baseline bytes. Retained TAP identity/numbering PASS. Preservation PASS for 2,850 other files, 514 prior nodes and all 1,039 book headings. Knowledge 1,154 facts / 9,266 keys; memory 60 lines; history bounds, mdBook build, mutation public surface (50 mutations), aggregate selector (11 contrasts / capability 100 matches) and diff whitespace PASS. Normal commit doctrines are the final boundary.
  Commit: `CONFORMANCE-SOURCE-READING.1.69 - read scalar membership and reducer lowering checks`

- ID: `CONFORMANCE-SOURCE-READING.1.70`
  Status: `done`
  Activation commit: `ff9a9b83c71980597ff307bff29057885955b219`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained direct/nested TAP proof and canonical observation-gap reconciliation; Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no runtime, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 70.
  Scope: `t/phase0_regression.t` lines 36948-37744
  Baseline evidence: 797 fragments / 65524 decoded bytes; ordered range SHA-256 `5ac87a150611aa5dcb3f2d3748045d97d1264793f3696bfe51a3265a7f0e6cfa`.
  Dependencies: .1.69 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 797 fragments / 65524 bytes; ordered window SHA-256 `4fb287cc34d0db219abf17c32d98bf8a374eeea673663960ca7ddc882f7d6611`.
  Comprehension: Completes lifecycle count_keys, then has_key, merge_hash, copy/hash snapshot, set_key, rename_key, drop_keys and pick_keys direct lowering plus action/LX descriptor comparisons. Seven four-assertion direct plans use exact expressions and anchored patterns; bare copy observes one runtime-typed scalar binding, while composed known hash copy checks a shallow hash snapshot expression. Hash key transforms form local copies or projections; rename only moves existing keys and pick only includes existing requested keys. Tests do not execute copy isolation, collision outcomes or mutation behavior. Fourteen completed descriptor pairs retain .2.10 uppercase-slot limits. Lifecycle pick_keys is partial after ten assertions at the opening of readiness; .1.71 owns the final two.
  Verification: Unchanged canonical commit ec10be6b retains PASS for twenty-one completed subtests, ordinals 741–761 with 196 direct assertions and no nested plans. Fourteen descriptor comparisons contribute 168 assertions; seven four-assertion direct-lowering plans contribute 28 textual checks. Exact TAP numbering and source identity are verified. Hash lookup, merge, snapshot and key-transform expectations inspect expressions and patterns; they do not execute copy isolation, collision outcomes or mutation behavior. Descriptor uppercase-slot comparisons remain .2.10-owned. Lifecycle pick_keys is partial after ten assertions at the opening of readiness; .1.71 owns the final two. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.
  Candidate proof: Exact inventory and .1.70 window replay PASS; cumulative 70/143 independently totals 87,239 fragments / 3,627,006 baseline bytes. Retained TAP identity/numbering PASS. Preservation PASS for 2,850 other files, 514 prior nodes and all 1,039 book headings. Knowledge 1,154 facts / 9,267 keys; memory 60 lines; history bounds, mdBook build, mutation public surface (50 mutations), aggregate selector (11 contrasts / capability 100 matches) and diff whitespace PASS. Normal commit doctrines are the final boundary.
  Commit: `CONFORMANCE-SOURCE-READING.1.70 - read hash transformations and snapshot lowering checks`

- ID: `CONFORMANCE-SOURCE-READING.1.71`
  Status: `done`
  Activation commit: `a9b874f7b704ca9fa7446944d7767077eb256afb`.
  Verification tier: `focused`
  Focused checks: Complete reading and exact coverage/window replay; retained TAP and four fresh exact subtests/public assignment controls; durable recipe replay, Knowledge, preservation, memory, histories, book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and diagnosis; no tracked runtime/test, dependency, public contract, infrastructure or parent-closeout change.
  Goal: Read and understand conformance/test/Unicode group 71.
  Scope: `t/phase0_regression.t` lines 37745-38503
  Baseline evidence: 759 fragments / 65504 decoded bytes; ordered range SHA-256 `23ace6853a715825816ce55d79c7b975ce9fadef04e2c80d2073308c7c26b438`.
  Dependencies: .1.70 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 759 fragments / 65504 bytes; ordered window SHA-256 `59d454151dbf825b3c0242fd66d004452f8a6c21093d9cca573fdba96c46dce7`.
  Comprehension: Completes lifecycle pick_keys, then reads sorted_keys, sorted_values, concat_arrays, lexical sorted, reversed, num_sum and num_avg direct lowering and action/LX descriptor comparisons. Sorted values follow sorted keys; concatenation guards nested ARRAY values and constructs one array; sorting compares defined terms as strings with undef mapped to empty text. Numeric sum/average text validates every term, with sum identity zero and empty average undef. Seven four-assertion textual plans and fourteen twelve-assertion descriptor plans complete. Lifecycle num_avg is partial after assertion four; .1.72 owns the suffix. Fresh exact four-subtest proof passes 16 assertions; four public assignment executions return expected ARRAY references. Their list-context-flattening labels are stale and repair-owned by .2.12; actual inner list construction remains distinct. Existing .2.10 uppercase-slot limits remain.
  Verification: Unchanged canonical commit ec10be6b retains PASS for twenty-one completed subtests, ordinals 762–782 with 196 direct assertions and no nested plans: fourteen descriptor plans contribute 168 and seven direct-lowering plans contribute 28. Exact TAP numbering/source identity are verified. Four freshly extracted subtests pass 16 assertions; four public assignment executions return expected ARRAY references. Their list-context-flattening descriptions are stale; .2.12 owns correction after prerequisites, with exact reproduction in phase0-array-assignment-description-drift. Inner list construction remains valid; descriptor uppercase-slot limits remain .2.10-owned. Lifecycle num_avg is partial after assertion four. No tracked test repair, dependency build, canonical run or push; .2.5–.2.12 and earlier repairs remain.
  Candidate proof: Exact 160-file/143-group/302-range audit and eleven-window reconstruction PASS; cumulative71 groups independently sum to87,998fragments/3,692,510baseline bytes. Both new tracked recipes replay PASS. Preserve2,850other files/50,654,378bytes,514prior task nodes,53other book files/all1,039headings, prior recipes/histories and gitlink; add only repair .2.12. Memory60; Knowledge1,155facts/9,272keys; histories248/41,634 and244/42,535lines/bytes; book/direct public checks and diff check PASS. Normal doctrine hooks govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.71 - read array ordering and own assignment description drift`

- ID: `CONFORMANCE-SOURCE-READING.1.72`
  Status: `done`
  Activation commit: `fa907be6e446f19ed0bcde060e2814c0f562b467`.
  Verification tier: `focused`
  Focused checks: Complete source/window/coverage and retained TAP checks; reconcile actual source/runtime observations with canonical Knowledge limits; preservation, memory, histories, rendered book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no source/public-contract/dependency/infrastructure change or parent closeout.
  Goal: Read and understand conformance/test/Unicode group 72.
  Scope: `t/phase0_regression.t` lines 38504-39354
  Baseline evidence: 851 fragments / 65534 decoded bytes; ordered range SHA-256 `79d7822ef3324308df225adc573dd141b794f0800065d8887448e0cf67c744bd`.
  Dependencies: .1.71 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 851 fragments / 65534 bytes; ordered window SHA-256 `3a7f14ed253714738cfc2014066b4b868b00667ab0c90726df1c48cc538a6f06`.
  Comprehension: Completes lifecycle num_avg; reads numeric median, range and unary-array min/max lowering plus action/LX descriptor pairs. Median sorts validated numeric terms and averages the middle pair for even length; range tracks extrema; empty/non-numeric inputs yield undef in the inspected expressions. Flat-array/hash lowering expands bare and guarded composed sources, while typed split/trim/filter/case/uniq helpers operate on one binding and preserve inner-to-outer composition. Tagged-record construction maps split fields into tagged arrays. Fluent/attached conditionals include exact lowering, source capture, metadata and actual parser-result assertions. Four otherwise cases cover action/lifecycle and dotted/bare forms. Lifecycle source locks positively observe I/LS/LE/LX under AND and E/EX/IT under collection mode; three runtime cases distinguish discarded final expression, surrounding-rule return and block-local return. These bounded observations do not close known broader lifecycle drift or .2.10 descriptor-slot gaps. The next switch test is partial before its first expected pattern; .1.73 owns its suffix.
  Verification: Unchanged canonical commit ec10be6b retains PASS for seventeen completed subtests, ordinals 783–799 with 235 direct assertions and no nested plans. Seven descriptor plans contribute 84 assertions; three numeric text plans contribute 14; flat-list/string/tagged-record plans contribute 48; three conditional/lifecycle plans contribute 89, including nine parser-result assertions and seven positive marker source checks. Exact TAP numbering and source identity are verified. Meaningful bounded source/runtime observations remain distinct from .2.10 uppercase-slot equality and startup .27 lifecycle drift. Switch coverage is partial before its first expected pattern; .1.73 owns the suffix. No new defect, fresh target execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.12 and all prerequisites remain.
  Candidate proof: Exact 160-file/143-group/302-range audit and eleven-window reconstruction PASS; independently summed 72 groups total 88,849 fragments / 3,758,044 baseline bytes. Preserve 2,851 other files / 50,660,630 bytes, 515 prior task nodes, 53 other book files and all 1,039 headings, prior recipes/history and gitlink. Memory 60; Knowledge 1,155 facts / 9,273 keys; histories 252/42,196 and 248/43,318 lines/bytes. Rendered book, direct public checks and diff check PASS; normal doctrine hooks govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.72 - read reducers and meaningful lifecycle source and result locks`

- ID: `CONFORMANCE-SOURCE-READING.1.73`
  Status: `done`
  Activation commit: `1e74f9842d42e1c7d2a3ba06df5c613555970e1c`.
  Verification tier: `focused`
  Focused checks: Complete source/window/coverage and retained TAP checks; reconcile actual source/runtime observations with canonical Knowledge limits; preservation, memory, histories, rendered book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no source/public-contract/dependency/infrastructure change or parent closeout.
  Goal: Read and understand conformance/test/Unicode group 73.
  Scope: `t/phase0_regression.t` lines 39355-40442
  Baseline evidence: 1088 fragments / 65436 decoded bytes; ordered range SHA-256 `315ca951694090af2512c351d52c1e263ecf846bbe3f507805fd02a5ef9fe919`.
  Dependencies: .1.72 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1088 fragments / 65436 bytes; ordered window SHA-256 `67008351310e458e80937388d3cc69050216d09547fd38070cc9e80cd583192f`.
  Comprehension: Completes switch marker/inline/attached lowering, optional endcase, first-match/default parser results and same-line separator controls. Attached while checks false-entry skip, condition mutation to 3 and a 10,000-iteration guard observed as failed match plus diagnostic. Reads helper-event counts, fluent/structured and optional-semicolon action/lifecycle comparisons; five remaining-tag nested tests compare metadata/hit maps, with unused code-key entries rather than code equality. Canonical helper events, raw fallback payloads, unresolved labels, blocker lists, readiness and compatibility migration summaries are separately observed. Supported legacy call wrappers and bare return/exit remain compatibility forms; exit_now uses typed diagnostic termination and next/next() share direct lowering. Six uppercase-slot assertions remain .2.10-owned; readiness metadata does not establish cross-backend execution. Prefix-newline linecount is partial after descriptor build and metadata extraction; .1.74 owns the suffix.
  Verification: Unchanged canonical commit ec10be6b retains PASS for twenty-eight completed subtests, ordinals 800–827 with 291 direct plan entries including five nested-subtest results; those five nested plans contain 40 further assertions. Exact TAP numbering and source identity are verified. Switch cases execute first/later/default selection; while cases execute false-entry skip, condition mutation and a nonterminating-loop guard returning a failed match with diagnostic. Six uppercase-slot assertions retain .2.10 limits; the five-tag semicolonless loop checks metadata and hits without reading its code-key variables. Compatibility/readiness summaries remain distinct from runtime portability. Prefix-newline linecount is partial after descriptor build; .1.74 owns the suffix. No new defect, fresh target execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.12 and all prerequisites remain.
  Candidate proof: Exact 160-file/143-group/302-range audit and eleven-window reconstruction PASS; independently summed 73 groups total 89,937 fragments / 3,823,480 baseline bytes. Preserve 2,851 other files / 50,660,630 bytes, 515 prior task nodes, 53 other book files and all 1,039 headings, prior recipes/history and gitlink. Memory 60; Knowledge 1,155 facts / 9,274 keys; histories 256/42,778 and 252/44,030 lines/bytes. Rendered book, direct public checks and diff check PASS; normal doctrine hooks govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.73 - read switch safety and compatibility migration observations`

- ID: `CONFORMANCE-SOURCE-READING.1.74`
  Status: `done`
  Activation commit: `8bb0fd15c3faa502370dec8cff9d30bdf9121d1f`.
  Verification tier: `focused`
  Focused checks: Complete source/window/coverage and retained TAP checks; reconcile source-projection and legacy classification observations with canonical Knowledge; preservation, memory, histories, rendered book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no source/public-contract/dependency/infrastructure change or parent closeout.
  Goal: Read and understand conformance/test/Unicode group 74.
  Scope: `t/phase0_regression.t` lines 40443-41195
  Baseline evidence: 753 fragments / 65404 decoded bytes; ordered range SHA-256 `d48cb6243066d0ed51cbdbc924791a016905e344777495e753a3ee284defd3f4`.
  Dependencies: .1.73 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 753 fragments / 65404 bytes; ordered window SHA-256 `2bb4a08a7e319a21ab3cfdfcd732a88e1045c54ae0a07d25fc4bc4db88c717ce`.
  Comprehension: Completes legacy prefix-newline classification, then cursor/entry/match line and column projections, explicit start edges, cursor tails, anonymous capture widths/tails/take operations, named marks and boundary bridges, whole-input reads and advancing through-cursor/two-mark helpers. Metadata checks pair canonical nodes/readiness with lowering substrings for typed SourceLocation runtime calls and trace operations. Direct capture_slice_len has an exact anonymous-boundary expression; other presence checks do not independently prove all endpoint arithmetic or executed boundary advancement. Later legacy capture print, declarations, position tracking, regex substitution, lexical/destructuring assignment and foreach printing preserve their original text while avoiding raw fallback. print_each uses the parse-scoped diagnostic seam with zero compatibility events. No parser-result assertions or uppercase descriptor-code comparisons occur among these completed tests. The split/trim/filter compatibility test remains partial after descriptor build and metadata extraction; .1.75 owns its suffix.
  Verification: Unchanged canonical commit ec10be6b retains PASS for twenty-nine completed subtests, ordinals 828–856 with 323 direct assertions and no nested plans. Exact TAP numbering and source identity are verified. Typed source-location runtime-call substrings, trace operations, canonical nodes and readiness are observed; these checks do not execute endpoint arithmetic or mark advancement. Direct capture_slice_len has an exact anonymous-boundary expression. Legacy print/declaration/position/regex/assignment forms preserve authored text; print_each uses typed diagnostic output. No parser-result assertions or uppercase descriptor-code comparisons occur in these completed tests. Split/trim/filter remains partial after descriptor build; .1.75 owns the suffix. No new defect, fresh target execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.12 and all prerequisites remain.
  Execution observation: Documentation preparation emitted child setpgid (77478 to 77478): Operation not permitted, then exited 0. Resulting edits are independently checked; the original final PGID was not captured. This matches the known project-data-liveness-permission-denial recurrence owned by SESSION-STARTUP-READING.7. No group-establishment, new-cause or lifecycle-safety claim; recovery/purge remain prohibited.
  Candidate proof: Exact 160-file/143-group/302-range audit and eleven-window reconstruction PASS; independently summed 74 groups total 90,690 fragments / 3,888,884 baseline bytes. Preserve 2,851 other files / 50,660,630 bytes, 515 prior task nodes, 53 other book files and all 1,039 headings, prior recipes/history and gitlink. Memory 60; Knowledge 1,155 facts / 9,275 keys; histories 260/43,318 and 258/45,035 lines/bytes. Rendered book, direct public checks and diff check PASS; normal doctrine hooks govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.74 - read source boundary projections and legacy classification checks`

- ID: `CONFORMANCE-SOURCE-READING.1.75`
  Status: `done`
  Activation commit: `90235115cc8bd2950ed603abe0c020a0fe22c526`.
  Verification tier: `focused`
  Focused checks: Complete source/window/coverage and retained TAP checks; reconcile grammar readiness and quote-boundary observations with canonical Knowledge; preservation, memory, histories, rendered book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no source/public-contract/dependency/infrastructure change or parent closeout.
  Goal: Read and understand conformance/test/Unicode group 75.
  Scope: `t/phase0_regression.t` lines 41196-42087
  Baseline evidence: 892 fragments / 65464 decoded bytes; ordered range SHA-256 `a42abbcf06fb96fe881ee0f242527538ae9e53e0c423bbf4533f721ff2645978`.
  Dependencies: .1.74 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 892 fragments / 65464 bytes; ordered window SHA-256 `0fd9f0f9d1f4d1539f116ce5aeaa7290432c1c7c3c0115ce1d88086f81689311`.
  Comprehension: Split/trim/filter, next and ref-field assignments retain compatibility text with canonical metadata. Nested semicolons stay inside quoted or balanced payloads; line comments, backticks and slash/angle/pipe quote forms retain one RAW_PERL statement plus CALL. Backticks are authored text, not executed. EBNF, ds_vhistory, regdef, tablegrep and VHDL migration tests inspect helper nodes, raw/unresolved/compatibility counts, source spelling and summary readiness. Regdef additionally constructs and executes a parser and checks the exact CTRL/ENABLE/MODE AST. Descriptor readiness and source patterns do not establish arbitrary EBNF acceptance or cross-backend runtime parity. VHDL declaration, process/subprogram and return-shape checks report zero blocked rules; source checks preserve cursor/capture/entry-group helper spellings. Concurrent signal assignment source inspection is partial after its positive entry-group reorder assertion; .1.76 owns the remaining negative assertion and subsequent tests. No new repair is established.
  Verification: Unchanged canonical commit ec10be6b retains PASS for thirty-six completed subtests, ordinals 857–892 with 470 direct assertions and no nested plans. Exact TAP numbering and source identity are verified. Quote-aware statement boundaries preserve nested and quoted semicolons. EBNF, ds_vhistory, regdef, tablegrep and VHDL checks primarily observe descriptor metadata and helper source spelling; regdef also executes a parser and checks an exact AST. Readiness metadata is not arbitrary grammar acceptance or cross-backend runtime proof. The concurrent VHDL assignment source test remains partial after its positive reorder assertion; .1.76 owns the suffix. No new defect, fresh target execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.12 and all prerequisites remain.
  Candidate proof: Exact 160-file/143-group/302-range audit and eleven-window reconstruction PASS; independently summed 75 groups total 91,582 fragments / 3,954,348 baseline bytes. Preserve 2,851 other files / 50,660,630 bytes, 515 prior task nodes, 53 other book files and all 1,039 headings, prior recipes/history and gitlink. Memory 60; Knowledge 1,155 facts / 9,276 keys; histories 264/43,849 and 262/45,737 lines/bytes. Rendered book, direct public checks and diff check PASS; normal doctrine hooks govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.75 - read quote boundaries and shipped grammar migration checks`

- ID: `CONFORMANCE-SOURCE-READING.1.76`
  Status: `done`
  Activation commit: `cadf2cc0d4fcf988c13ac69e8929e2a0bdad56c2`.
  Verification tier: `focused`
  Focused checks: Complete source/window/coverage and retained TAP checks; reconcile observation boundaries with canonical Knowledge; preservation, memory, histories, rendered book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no source/public-contract/dependency/infrastructure change or parent closeout.
  Goal: Read and understand conformance/test/Unicode group 76.
  Scope: `t/phase0_regression.t` lines 42088-42887
  Baseline evidence: 800 fragments / 65456 decoded bytes; ordered range SHA-256 `f7a4521038b590b5c26699bfeffe4a7e5f2a0c2aec8840bc80d881864bca9bac`.
  Dependencies: .1.75 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 800 fragments / 65456 bytes; ordered window SHA-256 `4cf7775ac2ba5691da7e40961a1fffa66cb8f9db6837120d880949270205683c`.
  Comprehension: Completes VHDL concurrent-assignment source denial, then port/declaration/payload/lowercase source checks. Simenv, ifelse, BNF, operators_try, DT, hlink_substitution, lib_reader, sdce, ebnf, portmap and pplugin checks distinguish helper metadata and source spelling from runtime results. Ifelse checks undef output and quiet stdout without a sink; this alone cannot prove all control-flow branches ran. Hlink checks three exact delimiter ASTs; lib_reader checks grouped attribute output, clear last_error and optional top_rule stability; EBNF checks normalized logging_annotation plus PUSH/CAPTURE_SLICE_START and absent CAPTURE_IF; portmap checks seven classifications including zero bit index and concatenation. Pplugin checks exact parsed body text, then deliberately normalizes it into legacy Perl coderefs and checks values 3 and ok, without extending portability. Tkgui descriptor coverage is partial after the three-rule metadata loop; .1.77 owns canonical-node and summary assertions. No new repair is established.
  Verification: Unchanged canonical commit ec10be6b retains PASS for 33 completed subtests, ordinals 893–925 with 650 direct assertions and no nested plans. Exact TAP numbering and source identity are verified. VHDL source migrations and shipped-spec readiness remain bounded metadata/source checks. Runtime smokes cover ifelse undef/quiet stdout, three hlink ASTs, lib_reader grouped attributes, EBNF logging annotations and seven portmap classifications. Pplugin preserves body text before its legacy Perl adapter creates and executes coderefs. Tkgui is partial after its three-rule metadata loop; .1.77 owns node/summary assertions. No new defect, fresh target execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.12 and all prerequisites remain.
  Candidate proof: Exact 160-file/143-group/302-range audit and eleven-window reconstruction PASS; independently summed 76 groups total 92,382 fragments / 4,019,804 baseline bytes. Preserve 2,851 other files / 50,660,630 bytes, 515 prior task nodes, 53 other book files and all 1,039 headings, prior recipes/history and gitlink. Memory 60; Knowledge 1,155 facts / 9,277 keys; histories 268/44,373 and 266/46,513 lines/bytes. Rendered book, direct public checks and diff check PASS; normal doctrine hooks govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.76 - read shipped grammar runtime smokes and adapter boundaries`

- ID: `CONFORMANCE-SOURCE-READING.1.77`
  Status: `done`
  Activation commit: `c57bd928ef7fe1bd385b80a1e029ca3960ae3532`.
  Verification tier: `focused`
  Focused checks: Complete source/window/coverage and retained TAP checks; reconcile observation boundaries with canonical Knowledge; preservation, memory, histories, rendered book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no source/public-contract/dependency/infrastructure change or parent closeout.
  Goal: Read and understand conformance/test/Unicode group 77.
  Scope: `t/phase0_regression.t` lines 42888-43916
  Baseline evidence: 1029 fragments / 65477 decoded bytes; ordered range SHA-256 `b47206ff5e1b9e509629d9ecae475aebd9c311dc324d423db88e6948e6ce68a7`.
  Dependencies: .1.76 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1029 fragments / 65477 bytes; ordered window SHA-256 `8e331eed03bfb3e6fd8e61d9b3dc8908326dabcadd7d88ce8b1e36d4c805a25c`.
  Comprehension: Completes tkgui metadata then exact AST/quiet-output smoke. Simenv and Lispish tests retain helper/source migration checks; simenv also checks nested assignment AST, quiet output and cursor before the final newline. Lispish checks its historical nested AST; VHDL checks selected tags and EBNF top rule names, not full output/strict document acceptance. Three core corpus datasets exclude retired noncore plugins. Trace tests observe owner/decision scopes, mark positions with caret excerpts and exact capture AST, plus nonempty file routing. Five ACODE/LXCODE/CODE comparisons remain in the .2.10 inventory, while the lifecycle emptiness test compares metadata only. Default seek and AND consume subprocesses test actual input outcomes. Descriptor cursor checks and removed parse_mode structured errors are separate. A newly reproduced negative-only source-observation gap is owned by .2.13: original assertions pass with empty captured source. The Markdown path scan remains partial after leak-array initialization; .1.78 owns its scan/assertions.
  Verification: Unchanged canonical commit ec10be6b retains PASS for 35 completed subtests, ordinals 926–960 with 479 direct assertions and no nested plans. Exact TAP numbering and source identity are verified. Tkgui and simenv check exact ASTs and quiet output; Lispish checks its historical AST, while VHDL/EBNF smoke checks cover selected tags/names. Trace checks include scopes, mark positions/caret excerpts, exact capture output and nonempty file routing. Five uppercase-slot comparisons retain .2.10 limits. Default seek and AND consume execute input controls; parse_mode rejection checks structured prepare-options diagnostics. The Markdown path scan is partial after leak-array initialization; .1.78 owns its suffix. Fresh diagnosis confirms .2.13 without closing a repair; no production change, dependency build, canonical run or push is claimed; .2.5–.2.13 and all prerequisites remain.
  Candidate proof: Exact 160-file/143-group/302-range audit and eleven-window reconstruction PASS; independently summed 77 groups total 93,411 fragments / 4,085,281 baseline bytes. Fresh .2.13 controls: original 12/12 pristine and empty observations PASS; guarded 13/13 pristine PASS, empty/unrelated observations fail only added assertion12 as expected; tracked five-case recipe replay PASS. Preserve 2,851 other files / 50,660,630 bytes, 515 prior task nodes, 53 other book files and all 1,039 headings, prior recipes/history and gitlink; only new .2.13 is added. Memory 60; Knowledge 1,156 facts / 9,282 keys; histories 272/44,935 and 270/47,348 lines/bytes. Rendered book, direct public checks and diff check PASS; normal doctrine hooks govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.77 - read trace and cursor tests and own missing source observation`

- ID: `CONFORMANCE-SOURCE-READING.1.78`
  Status: `done`
  Activation commit: `2defd6def6f2fab08ac62e5b2f119186dc26cb9a`.
  Verification tier: `focused`
  Focused checks: Complete source/window/coverage and retained TAP checks; reconcile observation boundaries with canonical Knowledge; preservation, memory, histories, rendered book, direct public checks and normal doctrines.
  Canonical trigger: Ordinary bounded reading and fact reconciliation; no source/public-contract/dependency/infrastructure change or parent closeout.
  Goal: Read and understand conformance/test/Unicode group 78.
  Scope: `t/phase0_regression.t` lines 43917-45063
  Baseline evidence: 1147 fragments / 65472 decoded bytes; ordered range SHA-256 `8e7281c18857a910da9a21947835cb4102bdb3c9f1931bc5516468d7d8ea4130`.
  Dependencies: .1.77 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Reading evidence: 11 complete windows / 1147 fragments / 65472 bytes; ordered window SHA-256 `5ad019d2a261916fd5179bd2fc9ec14efb9946c205d1841bd9d0d9c8420ac52f`.
  Comprehension: Completes the selected Markdown path scan; its discovery helper covers eleven named top-level files and book Markdown, not all tracked Markdown. Self-hosting smokes bound termination and defined results; function grammar ownership stays in spec.spec. User-function AST tests check thirteen definitions, source spans, pending/normalized payload paths, provenance, staged job identities, body ASTs, diagnostics and exact execution values. Narrow function-body-v1 dispatch remains distinct from general-v2 staging. PluginBridge assertion only preserves its compatibility label. Fork-bounded recursion tests separate termination, body recursion and LX sequence results; match_group versus entry_text checks top-rule match ownership. Auto-variable tests use genuine generated declaration counts and same-parser repeated calls, but old wrapper/channel wording and the fluent legacy-array-sigil denial drift from current scalar-held storage. Public capture and declaration-removal mutation confirm new .2.14 observation/description repair ownership. The bare-mutation repeated-invocation test has only its opening declaration read; .1.79 owns its body.
  Verification: Unchanged canonical commit ec10be6b retains PASS for 22 completed subtests, ordinals 961–982 with 392 direct assertions and no nested plans. Exact TAP numbering and source identity are verified. The selected Markdown scan covers 65 current files, not all tracked Markdown. Self-hosting smokes check bounded completion/defined results; function-body tests check exact AST metadata, spans, jobs, diagnostics and runtime values. Recursion checks distinguish termination, LX sequence results and entry/local match ownership. Genuine declaration-count and repeated-call checks coexist with stale wrapper/channel labels. Public capture plus declaration-removal controls establish .2.14; the next bare-mutation test has only its declaration read. Fresh diagnosis confirms .2.14 without closing a repair; no production change, dependency build, canonical run or push is claimed; .2.5–.2.14 and all prerequisites remain.
  Candidate proof: Exact 160-file/143-group/302-range audit and eleven-window reconstruction PASS; independently summed 78 groups total 94,558 fragments / 4,150,753 baseline bytes. Fresh selected Markdown scan passes65. Fresh .2.14 controls: original6/6 pristine and declaration-removed observations PASS; guarded7/7 pristine PASS and removal fails only added assertion7 as expected; tracked four-case recipe replay PASS. Preserve 2,852 other files / 50,667,648 bytes, 516 prior task nodes, 53 other book files and all 1,039 headings, prior recipes/history and gitlink; only new .2.14 is added. Memory60; Knowledge1,157 facts /9,287 keys; histories276/45,505 and274/48,393 lines/bytes. Rendered book, direct public checks and diff check PASS; normal doctrine hooks govern focused landing.
  Commit: `CONFORMANCE-SOURCE-READING.1.78 - read function staging and own working variable observation drift`

- ID: `CONFORMANCE-SOURCE-READING.1.79`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 79.
  Scope: `t/phase0_regression.t` lines 45064-46191
  Baseline evidence: 1128 fragments / 65516 decoded bytes; ordered range SHA-256 `09f266622584ba8da284fdc9c9d293f178093b42c798d55088e538d9afb16b57`.
  Dependencies: .1.78 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.80`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 80.
  Scope: `t/phase0_regression.t` lines 46192-47307
  Baseline evidence: 1116 fragments / 65486 decoded bytes; ordered range SHA-256 `f35ebcadb1b16ea4d67e8d763d0d3971ef53bb2ddf53ae46e53bc791b9246303`.
  Dependencies: .1.79 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.81`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 81.
  Scope: `t/phase0_regression.t` lines 47308-48409
  Baseline evidence: 1102 fragments / 65521 decoded bytes; ordered range SHA-256 `d30bd742fc9bd9d1bb52166579c7a7ef9990bc03c330c285c1faa56d4a3a406f`.
  Dependencies: .1.80 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.82`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 82.
  Scope: `t/phase0_regression.t` lines 48410-48675; `t/phase0_validation_fuzz.t` lines 1-450; `t/progressive_span_dispatch_perl_authority.t` lines 1-431; `t/progressive_span_dispatch_perl_contract.t` lines 1-353
  Baseline evidence: 1500 fragments / 51902 decoded bytes; ordered range SHA-256 `b256551d9615b13f84aa3fdcb475e0769153347e7d818f3f7118e61267a34f5c`.
  Dependencies: .1.81 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.83`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 83.
  Scope: `t/progressive_span_dispatch_perl_contract.t` lines 354-654; `t/punctuation_light_zero_arg_contract.t` lines 1-170; `t/recognition_transaction_perl_authority.t` lines 1-480; `t/recognition_transaction_perl_contract.t` lines 1-549
  Baseline evidence: 1500 fragments / 50515 decoded bytes; ordered range SHA-256 `a1ecdb37fced357637daffc1a0f0410808385c1f9b9e587f31f43553f9cc4b89`.
  Dependencies: .1.82 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.84`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 84.
  Scope: `t/recognition_transaction_perl_contract.t` lines 550-643; `t/recursive_observation_perl_contract.t` lines 1-548; `t/repeated_action_result_perl_contract.t` lines 1-258; `t/root_rule_selection_perl_core.t` lines 1-241; `t/root_rule_selection_perl_routes.t` lines 1-359
  Baseline evidence: 1500 fragments / 54362 decoded bytes; ordered range SHA-256 `e0dd496e8d1e78edb7cfaca2e214efd507107d80ed0c11623e8f6d10eb213167`.
  Dependencies: .1.83 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.85`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 85.
  Scope: `t/root_rule_selection_perl_routes.t` lines 360-419; `t/rule_local_cursor_perl_contract.t` lines 1-463; `t/rule_local_cursor_perl_descriptor.t` lines 1-250; `t/rule_local_cursor_perl_execution.t` lines 1-329; `t/scalar_numeric_contract.t` lines 1-50; `t/scalar_text_contract.t` lines 1-42; `t/semantic_index_perl_calls_projection.t` lines 1-241; `t/semantic_index_perl_foundation.t` lines 1-65
  Baseline evidence: 1500 fragments / 52593 decoded bytes; ordered range SHA-256 `9d4eab6873ee8b3859083ca65c84aee463158a959eb5c69c786a6947e5dffeda`.
  Dependencies: .1.84 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.86`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 86.
  Scope: `t/semantic_index_perl_foundation.t` lines 66-271; `t/semantic_index_perl_query.t` lines 1-220; `t/semantic_index_perl_runtime_observation.t` lines 1-428; `t/semantic_index_perl_static_projection.t` lines 1-155; `t/semantic_introspection_perl_admission.t` lines 1-346; `t/sparse_and_action_slots_perl_regression.t` lines 1-141; `t/staged_ast_enrichment_perl_contract.t` lines 1-4
  Baseline evidence: 1500 fragments / 61968 decoded bytes; ordered range SHA-256 `02eefe331e71a1c3c4f24b32f2069d85ac06be593cdbc799dd2be123e578c5b7`.
  Dependencies: .1.85 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.87`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 87.
  Scope: `t/staged_ast_enrichment_perl_contract.t` lines 5-1504
  Baseline evidence: 1500 fragments / 54923 decoded bytes; ordered range SHA-256 `47ee89082e5c348b1bbd01c463192459de3abaa9f378609b58df70059c75ac1b`.
  Dependencies: .1.86 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.88`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 88.
  Scope: `t/staged_ast_enrichment_perl_contract.t` lines 1505-2108; `t/standalone_lifecycle_block_perl_contract.t` lines 1-232; `t/standalone_lifecycle_block_self_hosted_contract.t` lines 1-74; `t/trace_actionir_compact_lowerers.t` lines 1-179; `t/trace_actionir_method_lowering.t` lines 1-212; `t/trace_actionir_pipeline.t` lines 1-152; `t/trace_cli.t` lines 1-47
  Baseline evidence: 1500 fragments / 57180 decoded bytes; ordered range SHA-256 `9f90a2d6c294841423ab95265cc01eea6f885a857ef1c92f3797d23bd8479f5f`.
  Dependencies: .1.87 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.89`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 89.
  Scope: `t/trace_cli.t` lines 48-121; `t/trace_emit_context_bridge.t` lines 1-168; `t/trace_generated_handler_branch.t` lines 1-130; `t/trace_generated_nonrep_dispatch.t` lines 1-201; `t/trace_generated_rep_dispatch.t` lines 1-212; `t/trace_ruleir_planning.t` lines 1-189; `t/typed_source_location_perl_contract.t` lines 1-300; `t/typed_source_location_values.t` lines 1-226
  Baseline evidence: 1500 fragments / 53547 decoded bytes; ordered range SHA-256 `6fc01b96ce3b190a90d9efb836babc11683052aac5171bb21b6a803803e7f982`.
  Dependencies: .1.88 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.90`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 90.
  Scope: `t/typed_source_location_values.t` lines 227-302; `t/unicode_case_mapping.t` lines 1-88; `t/uniform_binding_contract.t` lines 1-392; `t/variadic_user_function_contract.t` lines 1-174; `t/write_vivification_perl_contract.t` lines 1-462; `tests/corpus/README.md` lines 1-89; `tests/corpus/lispish/README.md` lines 1-25; `tests/corpus/lispish/expected.json` lines 1-10; `tests/corpus/lispish/input.spec` lines 1-86; `tests/corpus/lispish/input.txt` lines 1-1; `tests/corpus/simple_grammar/README.md` lines 1-29; `tests/corpus/simple_grammar/expected.json` lines 1-12; `tests/corpus/simple_grammar/input.spec` lines 1-9; `tests/corpus/simple_grammar/input.txt` lines 1-1; `tests/corpus/tablegrep/README.md` lines 1-25; `tests/corpus/tablegrep/expected.json` lines 1-10; `tests/corpus/tablegrep/input.spec` lines 1-11
  Baseline evidence: 1500 fragments / 51721 decoded bytes; ordered range SHA-256 `2308e8fc56a5180caff900c06b6aa0c5e6069230ae91fcbcd2a5e019a3312eb4`.
  Dependencies: .1.89 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.91`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 91.
  Scope: `tests/corpus/tablegrep/input.spec` lines 12-86; `tests/corpus/tablegrep/input.txt` lines 1-4; `unicode_case/README.md` lines 1-89; `unicode_case/generate_unicode_case_contract.py` lines 1-826; `unicode_case/generate_unicode_rule_label_contract.py` lines 1-506
  Baseline evidence: 1500 fragments / 55158 decoded bytes; ordered range SHA-256 `e148e1eb81030624bb0c612a5a20ea5bee8ae7544f27eeb7e94079733e9a0e40`.
  Dependencies: .1.90 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.92`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 92.
  Scope: `unicode_case/generate_unicode_rule_label_contract.py` lines 507-676; `unicode_case/self_hosted_cli/manifest.json` lines 1-27; `unicode_case/unicode_rule_label_regex_class.txt` lines 1-5; `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 1-678
  Baseline evidence: 880 fragments / 65488 decoded bytes; ordered range SHA-256 `4abcb1df54005e4a262bf52454e064b3787d06a8aac64df2806ee5478e7cf229`.
  Dependencies: .1.91 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.93`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 93.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 679-1456
  Baseline evidence: 778 fragments / 65443 decoded bytes; ordered range SHA-256 `b816ee5f40412f7d1925dceac725dd1c43d3cc8478dd74719c928f479edf25d4`.
  Dependencies: .1.92 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.94`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 94.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 1457-2307
  Baseline evidence: 851 fragments / 65503 decoded bytes; ordered range SHA-256 `d9130507eca0998c2745c6042f6ae658dd4fc778f377df1fd3003e9078e3c955`.
  Dependencies: .1.93 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.95`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 95.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 2308-3121
  Baseline evidence: 814 fragments / 65520 decoded bytes; ordered range SHA-256 `5f220cae515fd2e101b76b40377bbe32c628745eb80c4f1d2a236e30772507b5`.
  Dependencies: .1.94 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.96`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 96.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 3122-3872
  Baseline evidence: 751 fragments / 65503 decoded bytes; ordered range SHA-256 `20d135d50dfcb1c7693905665de52071401bc51dd3572ea8be299e9aef2a84c6`.
  Dependencies: .1.95 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.97`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 97.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 3873-4601
  Baseline evidence: 729 fragments / 65528 decoded bytes; ordered range SHA-256 `0aebc2a888551dedafac2096ea9e4a9ae5c8e92840fda07bd00b1d4ad41e1bb4`.
  Dependencies: .1.96 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.98`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 98.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 4602-5332
  Baseline evidence: 731 fragments / 65512 decoded bytes; ordered range SHA-256 `2890f4557ce18bde544030299e10448983bc10a7275a169e2c673a9a78978cc2`.
  Dependencies: .1.97 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.99`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 99.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 5333-6060
  Baseline evidence: 728 fragments / 65522 decoded bytes; ordered range SHA-256 `218777d89dea22252c04175cd8397010660ff61d7e341f9d89f0e198c1a84a72`.
  Dependencies: .1.98 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.100`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 100.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 6061-6825
  Baseline evidence: 765 fragments / 65514 decoded bytes; ordered range SHA-256 `c5c78a8d93ed658f61db357d3da447ee018bb0428969ae0d6b37558f3727309b`.
  Dependencies: .1.99 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.101`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 101.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 6826-7626
  Baseline evidence: 801 fragments / 65468 decoded bytes; ordered range SHA-256 `82b1cb86234f4aae193e7f6b371a69acb94a6bac52973f4f1e6b6fb6702d77fc`.
  Dependencies: .1.100 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.102`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 102.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 7627-8407
  Baseline evidence: 781 fragments / 65525 decoded bytes; ordered range SHA-256 `8e35752399ecc38d0581ccfcc35808d3ead3717e6d6fbdc74b0dadb7430140c4`.
  Dependencies: .1.101 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.103`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 103.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 8408-9200
  Baseline evidence: 793 fragments / 65511 decoded bytes; ordered range SHA-256 `e80ad61492b0d8f893d477208112ae03e5c01b15d97791dec3c9045d5300acc1`.
  Dependencies: .1.102 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.104`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 104.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 9201-9990
  Baseline evidence: 790 fragments / 65497 decoded bytes; ordered range SHA-256 `7098f9fb08a6be47026bf9dab11c1b9f5ad3f3eb265e2bf646fcb788ccf619e9`.
  Dependencies: .1.103 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.105`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 105.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 9991-10775
  Baseline evidence: 785 fragments / 65484 decoded bytes; ordered range SHA-256 `b9a44fd20a69e4296e50b9ad9bc8790734bbb0bfd5591bede0ef0e367ea2071d`.
  Dependencies: .1.104 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.106`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 106.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 10776-11576
  Baseline evidence: 801 fragments / 65486 decoded bytes; ordered range SHA-256 `90ce729b5dbbf83ae066a17845cc7c8c3911b80294bef28493a898f444d4fe3c`.
  Dependencies: .1.105 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.107`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 107.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 11577-12361
  Baseline evidence: 785 fragments / 65502 decoded bytes; ordered range SHA-256 `d9254a7ea3fd88ac4a030512e33cbd0029a72864d4fc603aa3e54965ad41043c`.
  Dependencies: .1.106 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.108`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 108.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 12362-13167
  Baseline evidence: 806 fragments / 65494 decoded bytes; ordered range SHA-256 `5a79e888e430a476d09b25c85be754ba1a32be140854d90833d92d4d115ee8a7`.
  Dependencies: .1.107 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.109`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 109.
  Scope: `unicode_case/upstream/17.0.0/DerivedCoreProperties.txt.gz` decoded lines 13168-13601; `unicode_case/upstream/17.0.0/LICENSE.txt.gz` decoded lines 1-39; `unicode_case/upstream/17.0.0/SpecialCasing.txt.gz` decoded lines 1-285; `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 1-209
  Baseline evidence: 967 fragments / 65495 decoded bytes; ordered range SHA-256 `8c17dd20561a8ecdb6bbfd79b0c4ae30c338cf0e9592ff33badd0a6ba5af3e03`.
  Dependencies: .1.108 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.110`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 110.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 210-1051
  Baseline evidence: 842 fragments / 65533 decoded bytes; ordered range SHA-256 `df8f0bd7a956ed5c12aa73b9692c7ffb3216a2f14c00f6b932390da35eadfd22`.
  Dependencies: .1.109 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.111`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 111.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 1052-2127
  Baseline evidence: 1076 fragments / 65485 decoded bytes; ordered range SHA-256 `414784e75975ac7cc5da5b9cc276a96673d8395585963bdf055105f0d54a8cc3`.
  Dependencies: .1.110 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.112`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 112.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 2128-3475
  Baseline evidence: 1348 fragments / 65472 decoded bytes; ordered range SHA-256 `5a60306d960a7e2c9732de38549258c9b720c99ef4cb2261282898c0e2a4034a`.
  Dependencies: .1.111 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.113`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 113.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 3476-4790
  Baseline evidence: 1315 fragments / 65497 decoded bytes; ordered range SHA-256 `fc2a3d6a1eece92c02d12283548673e236f4ed2ee6712bc1a662b9d4301351e5`.
  Dependencies: .1.112 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.114`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 114.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 4791-6144
  Baseline evidence: 1354 fragments / 65496 decoded bytes; ordered range SHA-256 `4c299bfa5a91a0192d3f8b6ed6acaf9176c0f39a22ed66bde3d59aa5fdd0197b`.
  Dependencies: .1.113 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.115`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 115.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 6145-7211
  Baseline evidence: 1067 fragments / 65531 decoded bytes; ordered range SHA-256 `83b38daebeff741e166a177300f2acd89d8aafeda82888f831405cb2ce7dbb4e`.
  Dependencies: .1.114 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.116`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 116.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 7212-8295
  Baseline evidence: 1084 fragments / 65529 decoded bytes; ordered range SHA-256 `7d389bab34899c4206c85578cd4f121a31bffa14097fed41c2788e74ade5af72`.
  Dependencies: .1.115 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.117`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 117.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 8296-9350
  Baseline evidence: 1055 fragments / 65502 decoded bytes; ordered range SHA-256 `1a8d19378a2c4c871aa4ec72380e95e6d2ee58d560b59207ebf24130a765d56d`.
  Dependencies: .1.116 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.118`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 118.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 9351-10534
  Baseline evidence: 1184 fragments / 65529 decoded bytes; ordered range SHA-256 `65f077afe099b48e66905f0b32514ab70642973267812410c1c3a8c6f2f5aea4`.
  Dependencies: .1.117 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.119`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 119.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 10535-11752
  Baseline evidence: 1218 fragments / 65523 decoded bytes; ordered range SHA-256 `f5be0a9eac8f9b7508d2564fcb3f04c6925bc1acc75f538fe74d334e5acb2c55`.
  Dependencies: .1.118 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.120`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 120.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 11753-12957
  Baseline evidence: 1205 fragments / 65512 decoded bytes; ordered range SHA-256 `71ea8e48b61e6845d731bba66a744ab9953421f3a65bcc86c66441d9f40af9b7`.
  Dependencies: .1.119 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.121`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 121.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 12958-14408
  Baseline evidence: 1451 fragments / 65530 decoded bytes; ordered range SHA-256 `5d978b6836785cb053c33386495013811309cb1079eaadf8142c04cf2a4bbcd5`.
  Dependencies: .1.120 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.122`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 122.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 14409-15668
  Baseline evidence: 1260 fragments / 65528 decoded bytes; ordered range SHA-256 `5d26bbb7be0fce099b2221c768a1508f643746eddd31ee4d4aa2c6ecfe8008fd`.
  Dependencies: .1.121 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.123`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 123.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 15669-16489
  Baseline evidence: 821 fragments / 65497 decoded bytes; ordered range SHA-256 `44b9ac33bd5b7ef70bc40032e17488136b5ef94cbfeafd6c7b37b85e135e8efb`.
  Dependencies: .1.122 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.124`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 124.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 16490-17483
  Baseline evidence: 994 fragments / 65535 decoded bytes; ordered range SHA-256 `cb729804da3070af2e969dbaaf57c1fcf816f2c6d8f525daa135b68e58ad69db`.
  Dependencies: .1.123 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.125`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 125.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 17484-18830
  Baseline evidence: 1347 fragments / 65531 decoded bytes; ordered range SHA-256 `4aa7a0038d29bd509942f2ca58a82339b759021b89db342b55819e58c198d902`.
  Dependencies: .1.124 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.126`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 126.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 18831-20102
  Baseline evidence: 1272 fragments / 65501 decoded bytes; ordered range SHA-256 `e85940aff06fd68888199e3ad119c8973ae3e09f854fb0f8b413150286acd38b`.
  Dependencies: .1.125 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.127`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 127.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 20103-21498
  Baseline evidence: 1396 fragments / 65525 decoded bytes; ordered range SHA-256 `f32745bbda6b880bc6f63a2ce6665c4467e7b1d84f9009b8fad2651789cda1af`.
  Dependencies: .1.126 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.128`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 128.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 21499-22808
  Baseline evidence: 1310 fragments / 65522 decoded bytes; ordered range SHA-256 `6b99038c94093fe763178c64f60e5722f0fea522dd91e08e799f1df52c564a82`.
  Dependencies: .1.127 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.129`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 129.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 22809-24074
  Baseline evidence: 1266 fragments / 65533 decoded bytes; ordered range SHA-256 `6c4b532840e73c2c99e7412a7f9d1afe2e69da3d74b679be25c0e5da87947584`.
  Dependencies: .1.128 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.130`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 130.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 24075-25378
  Baseline evidence: 1304 fragments / 65536 decoded bytes; ordered range SHA-256 `615f8b7604adba41f2afde0742ae3af93a796e672889736047008814fa7f04fb`.
  Dependencies: .1.129 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.131`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 131.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 25379-26688
  Baseline evidence: 1310 fragments / 65500 decoded bytes; ordered range SHA-256 `793f20e95a090071fc19c41b9602081fbcaa13541cfe98149bd71b0cedade0f8`.
  Dependencies: .1.130 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.132`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 132.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 26689-27998
  Baseline evidence: 1310 fragments / 65500 decoded bytes; ordered range SHA-256 `ea8a98c93da15a0fc3eb8bc82b5d63a8fc9d21dad868632e6042a8997e3b4727`.
  Dependencies: .1.131 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.133`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 133.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 27999-29301
  Baseline evidence: 1303 fragments / 65521 decoded bytes; ordered range SHA-256 `9b5984b402719b8b3814b6080459c6c5a882a3afd5e8f95dda4ddaaf21d6dbea`.
  Dependencies: .1.132 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.134`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 134.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 29302-30635
  Baseline evidence: 1334 fragments / 65507 decoded bytes; ordered range SHA-256 `79fd0b9379544a4ec4f69f65f2570be5875bf945c36bf6c441bec59f7a9b794a`.
  Dependencies: .1.133 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.135`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 135.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 30636-31927
  Baseline evidence: 1292 fragments / 65523 decoded bytes; ordered range SHA-256 `1b9461711a873115e9173fad28642dc8ab3b61a5305285ab8e69dd13937c19bc`.
  Dependencies: .1.134 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.136`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 136.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 31928-33277
  Baseline evidence: 1350 fragments / 65489 decoded bytes; ordered range SHA-256 `3664c6cd8169a77960327fd6396512d3926dc57b87897c18db0f322d43c76219`.
  Dependencies: .1.135 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.137`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 137.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 33278-34395
  Baseline evidence: 1118 fragments / 65479 decoded bytes; ordered range SHA-256 `b10ab2139fd80adc4f142ebbfc41dadd159f25df1cd97fcf7960744f280db125`.
  Dependencies: .1.136 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.138`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 138.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 34396-35317
  Baseline evidence: 922 fragments / 65489 decoded bytes; ordered range SHA-256 `bdc0180ab179e450d4ebca53d7b4030b2d03ce9f1af1f0c84218e3287f481081`.
  Dependencies: .1.137 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.139`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 139.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 35318-36357
  Baseline evidence: 1040 fragments / 65527 decoded bytes; ordered range SHA-256 `819a469a2a992dee7b1f8e15821b73cebe4881e8e6bd62d406f044dddefd0141`.
  Dependencies: .1.138 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.140`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 140.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 36358-37498
  Baseline evidence: 1141 fragments / 65509 decoded bytes; ordered range SHA-256 `0c17d4d60c8900896f20f084263ff9dc74b0733aa7cbecc12862529d53146dae`.
  Dependencies: .1.139 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.141`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 141.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 37499-38898
  Baseline evidence: 1400 fragments / 65477 decoded bytes; ordered range SHA-256 `7a21e1990dedb7f2a8fcc3f67ec72a6ff4b7654441406275de9db3f2e4c2b0fc`.
  Dependencies: .1.140 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.142`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 142.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 38899-40095
  Baseline evidence: 1197 fragments / 65516 decoded bytes; ordered range SHA-256 `f49d0b05c79ead8f3955b8de12317cb5ebd323ee087f003063a6b58134438fbd`.
  Dependencies: .1.141 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.143`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 143.
  Scope: `unicode_case/upstream/17.0.0/UnicodeData.txt.gz` decoded lines 40096-40575
  Baseline evidence: 480 fragments / 25035 decoded bytes; ordered range SHA-256 `313f719d8127e838499885a1709891878cbcdaad411bb44f404aaa0bb41ee68d`.
  Dependencies: .1.142 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2`
  Status: `active`
  Goal: Own concrete defects discovered during source comprehension, with implementation and verification acceptance for each.
  Dependencies: Diagnose with the Toolbox; preserve existing repair owners and remaining startup prerequisites.
  Acceptance: Route each confirmed defect to its current owner or create a precise pending repair leaf before continuing. Do not invent a defect from an unexecuted fixture or silently close it through reading.
  Verification: .1.1 confirms current capability-guide census/governance and generic-callable status drift behind passing structural checkers. Existing startup .41.7 owns count/workflow guidance; .41.6 owns the callable-current paragraph and claim recurrence. No duplicate repair leaf or runtime defect is invented. Exact evidence: conformance-capability-guide-reading.
  Reading continuation: .1.2 adds guide803-804 current-seventeenth and896-897 current80 claims to .41.7. Exact current diagnostic public metadata is15 documents/9 denials; its Knowledge card preserves the older dated16-document milestone and adds current evidence. No new runtime defect or duplicate repair root.
  Reading .1.30 extension: New .2.1 owns the exact stale neutral uniform-binding rollout guidance; its implementation and independent closeout remain prerequisite-gated. No runtime defect follows from the unchanged neutral cases.
  Reading .1.31 extension: .2.2 owns the CLI guide standalone command missing its required managed-storage setup, with implementation and independent verification children. Frozen future-neutral mutation strings remain intentionally preserved under their admitted canonical authorities and are not new runtime defects.
  Reading .1.36 extension: .2.3 owns the confirmed exported test-helper include-path split; plain and literal-argument controls isolate the mechanism. Repair remains prerequisite-gated, with no inferred Phase0 failure.
  Reading .1.37 extension: .2.4 owns the stale literal Phase0 header count; retained unchanged canonical output establishes 1031 subtests and the 1032-test plan. No runtime failure or new gate is inferred.
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.1`
  Status: `pending`
  Goal: Reconcile stale neutral uniform-binding guidance with already-admitted selector rejection while preserving dated proof.
  Evidence: .1.30 reads docs/knowledge/uniform-binding-neutral-contract.md, whose current-status body still calls exact selectors future-invalid and says Rust/Dart/Julia/Lua rejection follows. The same dated Rust and Lua compile-rejection cards record completed .12.1.8.2/.5 implementations and scoped proof; the neutral checker freshly passes 11 migrations, 7 executions, 6 invalid selectors and 8 constructors. This is stale rollout guidance, not a newly established runtime defect.
  Scope: docs/knowledge/uniform-binding-neutral-contract.md current-versus-historical selector wording and directly related public guidance. Existing backend-specific limitations and repair owners remain separate.
  Children: `.2.1.1`, `.2.1.2`
  Dependencies: Required startup reading/book/policy prerequisites before the guidance repair; preserve original dated native counts and later supported-runtime limitations.
  Acceptance: Date or replace the stale rollout pointers using each backend's canonical admitted owner; preserve exact policy, historical proof and qualified runtime limitations. Independently verify rendered wording and durable retrieval before closing.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.1.1`
  Status: `pending`
  Goal: Repair the exact stale neutral selector rollout wording.
  Dependencies: Parent prerequisites; retrieve all five backend compile-rejection owners before current-scope claims.
  Acceptance: Keep historical evidence intact, distinguish current compile-time rejection from old rollout order, update relevant book guidance, run neutral contract and changed-document checks, then commit.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.1.2`
  Status: `pending`
  Goal: Independently verify and close the neutral guidance correction.
  Dependencies: `.2.1.1` committed with clean handoff.
  Acceptance: Compare old and rendered new wording against canonical owners; verify no historical counts or unsupported native pass is substituted, retain all other repairs, and close only this documentation obligation.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.2`
  Status: `pending`
  Goal: Make the standalone CLI fixture guide command establish required project-data storage.
  Evidence: .1.31 reads cli_conformance/README.md lines7-13, which gives a direct Perl runner command without the initializer or managed wrapper. Canonical perl-project-data-ssd-storage requires one of those for direct low-level commands; neutral-cli-fixture-runner already shows the initializer. Targeted runner inspection at1-42 and342-346 confirms File::Temp with TMPDIR=>1 and no initializer at its entry. The example relies on an already-prepared shell. No unmanaged allocation was executed or claimed.
  Scope: The standalone reference command in cli_conformance/README.md and a meaningful command/storage regression check; preserve runner behavior and all exact fixture bytes.
  Children: `.2.2.1`, `.2.2.2`
  Dependencies: Required startup reading/book/policy prerequisites before guidance repair; tools source reading remains independently owned by startup3.9.
  Acceptance: Document the managed root-derived command or explicit initializer, verify the actual case workspace stays on the repository filesystem from a fresh launch environment, and preserve exact CLI results without RGX/PGEN rebuilds.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.2.1`
  Status: `pending`
  Goal: Correct the standalone CLI example's managed-storage setup and verify its execution.
  Dependencies: Parent prerequisites.
  Acceptance: Update the guide and applicable public pointer, use the existing project-data wrapper/initializer, run focused byte-exact CLI and actual workspace-locality checks, and commit before independent closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.2.2`
  Status: `pending`
  Goal: Independently verify and close the CLI example storage correction.
  Dependencies: `.2.2.1` committed with clean handoff.
  Acceptance: Exercise the documented command in a fresh environment while keeping all generated data repository-local, verify actual child workspace locality and exact outputs, and preserve historical storage evidence and other repairs.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.3`
  Status: `pending`
  Goal: Preserve literal include paths in the exported Perl test subprocess helper.
  Evidence: Reading .1.36 executes t::lib::TestHelpers::run_perl_snippet_in_subprocess with identical fixture modules in plain and space-containing repository-local include directories. Plain path returns status 0 / output ok; space path returns status 2 / no stdout and attempts to open script "space". Passing the same space path as one literal -I argument succeeds. TestHelpers.pm lines 105/117 join and whitespace-split @INC, changing argument boundaries. Phase0 defines a separate local helper; no Phase0 failure or complete-checkout relocation failure is claimed by this probe.
  Scope: The exported helper's include-argument construction and meaningful direct regression controls; preserve normal snippet values, output/error capture and repository-local temporary data.
  Children: `.2.3.1`, `.2.3.2`
  Dependencies: Required startup reading/book/policy prerequisites. No dependency implementation or pin is in scope.
  Acceptance: Preserve each include path as one argument, demonstrate RED/GREEN with spaces and plain controls, verify the supported include-entry policy without stringifying non-path hooks, and independently close the bounded helper repair. Any separate process-lifecycle issue needs its own evidence and owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.3.1`
  Status: `pending`
  Goal: Repair literal include-argument construction in the exported test helper.
  Dependencies: Parent prerequisites.
  Acceptance: Use direct argument-list construction, specify the handling of non-path @INC entries, preserve normal output/error/status behavior and managed storage, add exact plain/space-path controls, update applicable documentation and commit before independent closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.3.2`
  Status: `pending`
  Goal: Independently verify and close the exported helper include-path repair.
  Dependencies: `.2.3.1` committed with clean handoff.
  Acceptance: Reproduce documented path controls in a fresh managed process, verify literal argument boundaries and project-volume temporary files, identify actual import consumers, and preserve the separate Phase0 helper's evidence boundary.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.4`
  Status: `pending`
  Goal: Remove the stale literal Phase0 header count after complete source reading.
  Evidence: .1.37 reads t/phase0_regression.t line3 claiming 989 subtests. The unchanged-source canonical run at 87b35665e has 1031 top-level subtest headers, 1032 passing top-level assertions and exact plan 1..1032. The header is a stale navigation comment, not a failing runtime or a new canonical execution.
  Scope: The Phase0 header's current test-count claim; preserve every executable assertion and distinguish approximate navigation from authoritative runtime counts.
  Dependencies: Required source/book/policy reading, including the remaining Phase0 body.
  Acceptance: Replace the drifting literal with a stable description or a mechanically checked authoritative count; preserve executable bytes, run focused syntax/header verification and applicable preservation checks, update Knowledge/book continuity and commit. Do not edit assertions to match the old comment.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.5`
  Status: `pending`
  Goal: Make the MethodExpr lazy-load test observe Deps state after the operation it claims to verify.
  Evidence: .1.49 reads the exact Phase0 test: __DEPS_STILL_UNLOADED__ is printed before _parse_method_function_expr, yet assertion four claims the parse keeps Deps unloaded. TOOLBOX6.2 extraction passes all7 assertions both unchanged and with an inert project-local Deps fixture explicitly required after the parse. Independent cold probes observe before/after 0/0 normally and 0/1 with that fixture. The production Deps module is absent; the first direct require attempt therefore failed and is not a runtime regression. Canonical fact: docs/knowledge/conformance-perl-consumer-reading.md#methodexpr-post-parse-deps-observation-gap.
  Scope: The Phase0 MethodExpr subprocess observation and a meaningful post-operation forced-load rejection control; keep the current correct lazy-loading behavior and separate pre/post assertions.
  Dependencies: Required source/book/policy reading, including the remaining Phase0 body, before tracked test repair.
  Acceptance: Add an explicit post-parse Deps observation, preserve independent initial-load and parsed-result checks, show the isolated post-parse fixture-load mutation fails the intended assertion, remove the fixture from normal execution, pass focused pristine controls and direct-dependent checks, update book/Knowledge continuity and commit. Do not infer production loading from an injected fixture or reuse a pre-call marker as post-call evidence.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.6`
  Status: `pending`
  Goal: Correct six lazy-load assertion descriptions that attribute setup's EmitContext load to the later helper call.
  Evidence: .1.50 TOOLBOX6.2 extracts the FlowExpr, ArrayPipeline, ValueExpr, ControlFlow, MethodLowering and DeclareMethod cold subprocess tests. All six pass their seven assertions. Instrumented exact child snippets observe EmitContext absent before require, present immediately after require and present after the helper (0/1/1); each actual ActionIR owner changes from absent to present across the helper. The post-helper EmitContext assertion checks continued presence, not on-demand loading. Exact recipe: docs/knowledge/conformance-perl-consumer-reading.md#emitcontext-load-description-mismatch.
  Scope: Those six Phase0 assertion descriptions and focused evidence that retains independent ActionIR owner pre/post observations; do not change correct runtime loading to satisfy an inaccurate label.
  Dependencies: Required source/book/policy reading, including remaining Phase0 source, before tracked test edits.
  Acceptance: Describe the EmitContext assertion as continued availability after explicit setup loading, preserve each owner's actual lazy-load checks and payload assertions, pass all six focused tests with before/after observations, update durable Knowledge/book status and commit. Keep this description defect separate from .2.5's missing post-operation observation.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.7`
  Status: `pending`
  Goal: Make the mark_copy missing-source regression prove that an existing target is cleared.
  Evidence: .1.51 reads named_mark_mark_copy_advances_or_clears_explicit_boundary, whose after_end target is never initialized. Toolbox lowering identifies Runtime::mark_delete as the missing-source branch. Four isolated exact-block controls show original4/4 PASS and deletion-no-op original4/4 PASS with one intercepted deletion; seeding and observing target offset0 preserves pristine4/4 PASS but the same no-op fails precisely assertion2, retaining0 instead of undef. Production clears the seeded target correctly; this is a test observation gap. Canonical reproduction: docs/knowledge/conformance-perl-consumer-reading.md#mark-copy-missing-source-clearing-observation-gap.
  Scope: This Phase0 fixture's pre-existing target observation and isolated deletion-no-op rejection control; preserve successful copying and missing-source return checks.
  Dependencies: Required source/book/policy reading, including the remaining Phase0 body, before tracked test repair.
  Acceptance: Seed a zero-valued target, independently observe its pre-state and cleared post-state, retain positive-copy checks, show deletion-no-op fails the intended assertion and pristine production passes in fresh processes without a leaked override, run focused direct-dependent checks, update Knowledge/book continuity and commit. A scratch control is diagnosis, not completed repair.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.8`
  Status: `pending`
  Goal: Correct the positive num_min lowering fixture that currently blesses invalid generated Perl.
  Evidence: .1.52 reads the floor_value assignment in emit_context_lowers_method_contracts_for_capture_and_structured_return_values at Phase0 lines15950–15954. The input set(...num_min(...)) has an extra closing parenthesis and the expected generated string retains it. Fresh Toolbox call_spec_handler_subst output equals that expectation but fails independent compilation near }); removing exactly the extra authored parenthesis produces valid lowered code and returns2 for raw_name=abcd, limit=2. Canonical reproduction: docs/knowledge/phase0-num-min-lowering-fixture.md.
  Scope: This malformed positive assignment fixture, its expected lowering and meaningful compilation/execution control. Preserve genuine malformed-input diagnostics and raw-host compatibility boundaries; no production repair is inferred from this fixture typo.
  Dependencies: Required source/book/policy reading, including the remaining Phase0 body, before tracked test repair.
  Acceptance: Correct the authored and expected parentheses, prove the original positive fixture cannot compile, independently compile and execute the corrected assignment with representative values, retain text-shape intent and surrounding numeric contracts, run focused pristine/rejection and direct-dependent checks, update Knowledge/book continuity and commit. If a public malformed-input behavior requires repair, reproduce it separately and assign its exact scope.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.9`
  Status: `pending`
  Goal: Correct two push assertion descriptions that still claim wrapped target coverage.
  Evidence: .1.53 reads emit_context_lowers_push_method_contract. Its second and third assertions call push(items, array(tag, name)) and push(items, retv), yet describe wrapped targets. Fresh Toolbox extraction finds exactly two such descriptions; lowering uses bare scalar-held items. The two-bare-token form retains static rule-handler precedence plus binding fallback; the nested array is a value constructor, not a target wrapper. Retained canonical ec10be6b passes this subtest's19 assertions.
  Scope: Those two misleading descriptions; preserve current bare-binding behavior and separate static child-call precedence.
  Dependencies: Required source/book/policy reading, including the remaining Phase0 body, before tracked test edits.
  Acceptance: Describe each actual input accurately, retain its assertion and correct lowering, keep removed selectors rejected, run the focused subtest and exact text/lowering comparison, update Knowledge/book continuity and commit. Do not reintroduce a retired wrapper to satisfy stale prose.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.10`
  Status: `pending`
  Goal: Replace vacuous Phase0 code-slot equivalence assertions with observations of actual lowering or execution.
  Evidence: .1.56 Toolbox probe of the exact remaining-lifecycle inline-switch test passes all six nested eight-assertion plans, while all twelve descriptors have only dependency_refs/handler/meta/re keys at spec.Top and lack every asserted uppercase code slot. Equality therefore compares undef with undef. Canonical diagnosis and mutation reproduction: docs/knowledge/phase0-code-slot-equivalence-observation-gap.md.
  Scope: Audit the Phase0 action/lifecycle code-slot comparisons as one bounded inventory, then implement owned slices with an explicit observed nonempty code representation or independent branch execution. Reconcile earlier reading claims that treated absent-slot equality as generated-code proof.
  Dependencies: Required source/book/policy reading, including the remaining Phase0 body, before tracked test edits. Current .1.56 owns diagnosis and current-claim correction only.
  Acceptance: Preserve meaningful descriptor/metadata checks; prove the compared representation exists and contains the intended action; reject a changed branch payload that currently escapes; preserve pristine positives and lifecycle coverage in handler shapes that actually emit each hook; retain existing startup .27.1 ownership of mode/finalization reconciliation; synchronize Knowledge and the book. Split the inventory into bounded child repairs if necessary, and close only after independent negative-control verification.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.11`
  Status: `pending`
  Goal: Correct source-capture recipes that dereference an array of chunks as a scalar.
  Evidence: .1.56 follows TOOLBOX.md section2.2 and reproduces Not a SCALAR reference. RuntimeContext.pm ensure_runtime_ctx_parser_source_chunks_ref stores an ARRAY; flush_runtime_ctx_parser_source joins those chunks and writes a caller-provided parser_source_ref SCALAR. A valid public Get control confirms ARRAY storage and nonempty explicit scalar capture. The same stale scalar dereference appears in top-rule-is-ordinary-rule-entered-first's reverify recipe.
  Scope: TOOLBOX.md source-capture example and matching maintained recipes; inventory exact scalar-dereference uses without altering historical evidence or unrelated runtime code.
  Dependencies: Remaining required source/book/policy reading before tracked recipe repair; .1.56 owns discovery and the corrected diagnostic recipe.
  Acceptance: Use parser_source_ref or an explicit join over validated ARRAY chunks; execute each corrected current recipe through managed project storage, demonstrate nonempty captured source and no reference-type error, preserve all supported capture outputs, update Knowledge and relevant public guidance, then commit.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.12`
  Status: `pending`
  Goal: Correct Phase0 assignment descriptions that claim list-context flattening for scalar-held array results.
  Evidence: .1.71 completes the exact four-phrase census at Phase0 lines 37778/37890/38110/38218. Public call_spec_handler_subst outputs for sorted_keys, sorted_values, sorted and reversed assign scalar-held ARRAY references; all four exact lowered expressions execute with expected contents. The four authored subtests pass 16 assertions. Root mismatch is assertion prose versus scalar-binding observation; inner list construction remains valid. Reproduction: docs/knowledge/phase0-array-assignment-description-drift.md.
  Scope: The four current Phase0 descriptions containing list-context flattening, with precise input/lowering/result evidence for each; preserve existing runtime behavior and assertion strength.
  Dependencies: Required source/book/policy reading before tracked test edits; .1.71 owns diagnosis and current-claim reconciliation only.
  Acceptance: Complete the four-case inventory, describe scalar assignment of array-valued results accurately, retain useful lowering assertions, execute the exact focused subtests and public lowering/result controls, verify no source-list flattening claim remains, synchronize Knowledge/book and commit. Do not reintroduce retired namespace selectors or change production lowering to satisfy stale wording.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.13`
  Status: `pending`
  Goal: Make the Phase0 rule-local cursor generated-source check detect missing or wrong source.
  Evidence: .1.77 public dump_parser_source capture returns 11,417 bytes with the current default-family three-argument LinkedRE::or call. The exact twelve-assertion subtest passes both pristine and after its subprocess observation is replaced with an empty string; the negative-only source assertion cannot detect missing output. Canonical diagnosis: docs/knowledge/phase0-cursor-source-observation-gap.md.
  Scope: Correct return_descriptor_and_generated_source_share_rule_local_cursor_contract and audit equivalent negative-only source observations in its bounded cursor-contract test family. Keep descriptor and runtime cursor proofs distinct.
  Dependencies: Required source/book/policy reading, including the remaining Phase0 body, before tracked test edits. Current .1.77 owns diagnosis and current-claim correction only.
  Acceptance: Require nonempty captured source and a positive current rule-specific dispatch observation; retain the consume-override denial, descriptor metadata and seek/consume runtime positives; reject empty and wrong-dispatch observations without changing production to fit stale text. Synchronize Knowledge and the book, then close only after pristine and independent negative controls pass.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.2.14`
  Status: `pending`
  Goal: Align Phase0 working-variable declaration observations and descriptions with current scalar-held typed bindings.
  Evidence: .1.78 public source capture of the exact fluent .push(items) fixture produces one my $items and no my @items, while the test labels absence of my @items as deferred auto-declaration. The adjacent wrapped/setup dedup test now uses bare targets/reads, including two byte-identical scalar fixture strings. Canonical diagnosis: docs/knowledge/phase0-working-variable-observation-drift.md.
  Scope: Audit the contiguous spec_format_terse_1_1_1 and spec_format_terse_1_2_1 test family, including the unread .1.79 continuation, for stale wrapper/sigil/channel claims and vacuous legacy-sigil denials. Preserve genuinely distinct setup, per-invocation and recursion controls; reconcile associated maintained working-variable guidance.
  Dependencies: Required source/book/policy reading, including the complete working-variable test family, before tracked test edits. Current .1.78 owns public diagnosis and current-claim correction only.
  Acceptance: Assert the actual nonempty scalar-held binding declarations, reject removal/duplication of the intended lexical declaration, preserve current helper lowering and run-twice scoping positives, replace obsolete wrapper/deferred descriptions with accurate current observations, avoid restoring retired syntax, and independently verify the focused family plus book/Knowledge alignment.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.3`
  Status: `pending`
  Goal: Independently reconcile all source/range/reading-commit/repair evidence and close only the required reading lane with applicable verification.
  Dependencies: All143 required reading children committed; every finding repair-owned; canonical closeout proof or a new explicit applicable exception.
  Acceptance: Reconcile original/current inventory, decoded inputs, exact once-only coverage, comprehension, source deltas, commit activations and retained repairs. Preserve later startup/book/policy requirements and distinguish reading from runtime signoff.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.4`
  Status: `done`
  Goal: Resolve measured evidence capacity before the remaining 93 reading children, without losing history or silently increasing controls.
  Children: `.4.1`, `.4.2`
  Dependencies: .1.50 committed clean; .1.51 remains unread and pending.
  Acceptance: Preserve exact prior content, derive a finite reviewable reserve, obtain explicit disposition before any capacity implementation and restore the source-reading frontier only after governed admission.
  Verification: Explicit Granted disposition recorded under accepted indexed ADR0122. Containment .15 independently proves exact fourteen controls, finite remaining reserve, prior source/task/history preservation and production boundary/authorization behavior; its ordinary exact staged canonical receipt governs landing. Reading stays 50/143 and all repairs remain open.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.15 - admit approved conformance evidence capacity`

- ID: `CONFORMANCE-SOURCE-READING.4.1`
  Status: `done`
  Activation commit: `7b921a1954b1a8cf4089315491474979c580046b`.
  Verification tier: `focused`
  Focused checks: Exact clean history/source census, bounded reserve and production rollover model, prior-content preservation, existing pressure controls, Knowledge/memory/book, direct public-documentation checks and normal doctrines.
  Canonical trigger: Proposal and continuity only; no registry, infrastructure, source or policy changes. Implementation requires separate explicit before-reading authority and the ordinary canonical tier.
  Goal: Produce and commit a concrete finite capacity proposal for remaining conformance reading.
  Scope: Existing history pressure, a finite 99-unit evidence forecast, exact old/proposed controls, unchanged source/range/repair evidence and durable disposition pointers.
  Acceptance: Reproduce current measurements and required rollover, preserve every prior record, explain why current routing cannot absorb the reserve, bound any proposed increases and retain all implementation/prerequisite controls. Do not apply proposed controls or claim new source-reading credit.
  Verification: Clean 7b921a195 has notes241/58910 and changes273/58671 lines/bytes. Both archive file/manifest limits are full; next notes allowance is only72 bytes below mandatory90% rollover. Fifty exact reading commits establish bounded positive-growth maxima. Independent and extracted-production 99-record models agree on eight rollovers per history with exact reconstruction. The actual routing predicate passes187 below/equal/above and old/proposed reserve executions. Full actual-candidate-plus99-unit census is required after all proposal edits; registry, sources, repairs and historical records remain unchanged.
  Candidate proof: All five recipes replay directly from this maintained proposal; fifty exact comparable commits, independent/production eight-rollover models,187 actual-validator cases and full resulting-candidate-plus99-unit reserve pass. Preservation verifies2,845 other files/50,563,139 bytes and506 prior task nodes; every earlier repair, all143 original reading scopes, registry/policy/source bytes and immutable histories remain exact. Existing public-book content and headings remain byte-exact around the inserted proposal. Memory, both history checks, book rendering, public mutation69/50 and public selector68/11 checks pass. Knowledge is1,151 facts/9,228 keys; notes245/58977 and changes277/58911 lines/bytes stay below required rollover. Normal nine-doctrine hooks govern landing; no approval or canonical admission is claimed.
  Commit: `CONFORMANCE-SOURCE-READING.4.1 - propose finite remaining-reading evidence capacity`

- ID: `CONFORMANCE-SOURCE-READING.4.2`
  Status: `done`
  Goal: Record the director's explicit disposition and route an approved bounded implementation from a clean checkpoint.
  Dependencies: .4.1 committed; explicit approval of exact proposed controls and implementation before completion of required reading.
  Acceptance: No elapsed-time or prior-ADR approval inference. After approval, create a bounded LIVE-DOCUMENT-PRESSURE-CONTAINMENT implementation owner, newly accepted indexed ADR and canonical staged proof; independently verify exact changes and preservation before resuming .1.51. Otherwise retain the proposal and select an authorized alternative with the director.
  Authorization: The director answered Granted on 2026-09-21 to the exact fourteen controls and bounded implementation before required reading finishes; no CI or hook exception. LIVE-DOCUMENT-PRESSURE-CONTAINMENT.15 owns implementation from clean 5fab5aa6, with accepted indexed ADR0122.
  Verification: Explicit Granted disposition recorded under accepted indexed ADR0122. Containment .15 independently proves exact fourteen controls, finite remaining reserve, prior source/task/history preservation and production boundary/authorization behavior; its ordinary exact staged canonical receipt governs landing. Reading stays 50/143 and all repairs remain open.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.15 - admit approved conformance evidence capacity`

## Approved capacity disposition — 2026-09-21

The director answered **Granted** to all fourteen exact controls and bounded
before-reading implementation. Containment `.15` owns admission from clean
5fab5aa6 with accepted indexed ADR0122, independent preservation/reserve proof
and the ordinary exact staged canonical receipt. The original proposal below
is preserved as historical evidence; its pending language describes its date.
Source reading remains 50/143; `.1.51` resumes after clean admission. Repairs
`.2.5` and `.2.6` remain open with unchanged acceptance and prerequisites.

## Remaining-reading capacity proposal

Owner: `CONFORMANCE-SOURCE-READING.4.1`. **Proposal only; explicit director approval
is required before implementation.** Source reading remains 50/143; `.1.51` is
unread. No limit, runtime, test, policy, dependency pin or immutable history changes.

At activation the notes root is 58,910 bytes. Mandatory rollover starts at 58,983 bytes,
leaving 72 bytes. Changes is 58,671 bytes, leaving 311. Both collections and both
manifest file/line/byte capacities are already full. ADR0121 explicitly covers
integration delivery and excludes unlimited later PNT reading. README_POLICY.md
requires a newly accepted indexed decision for every increase. The current
startup exception permits reading checkpoints, not this infrastructure admission.

Approve exactly these fourteen scalar changes and one bounded capacity implementation
before completion of required source/book/policy reading. Implementation will use
ordinary receipt-bound canonical CI and all normal hooks; no CI exception is requested.
Keep all hot-file, generic member, archive-size, schema, routing, authority, immutable
history and unrelated limits unchanged. Existing responsibilities remain unchanged.

| Controlled surface and scalar | Current | Proposed |
| --- | ---: | ---: |
| change_history / limits.max_files | 39 | 47 |
| change_history / docs/history/changes/manifest.jsonl.max_lines | 38 | 46 |
| change_history / docs/history/changes/manifest.jsonl.max_bytes | 21,647 | 26,255 |
| engineering_notes / limits.max_files | 35 | 43 |
| engineering_notes / limits.max_total_lines | 28,000 | 29,000 |
| engineering_notes / limits.max_total_bytes | 3,145,728 | 3,407,872 |
| engineering_notes / docs/history/development-notes/manifest.jsonl.max_lines | 34 | 42 |
| engineering_notes / docs/history/development-notes/manifest.jsonl.max_bytes | 20,514 | 25,410 |
| knowledge_cards / limits.max_files | 1,152 | 1,350 |
| knowledge_cards / limits.max_total_lines | 93,000 | 108,000 |
| knowledge_cards / limits.max_total_bytes | 7,340,032 | 8,388,608 |
| knowledge_map / limits.max_lines | 20,000 | 22,500 |
| task_evidence / limits.max_total_lines | 92,000 | 120,000 |
| task_evidence / limits.max_total_bytes | 10,485,760 | 12,582,912 |

The finite envelope is 99 units: 93 remaining reading children, this proposal,
capacity admission, independent capacity verification, conformance closeout and
two contingencies. These support slots do not require extra commits merely to
consume an allowance. The resulting-candidate check conservatively charges the
full reserve after this proposal's actual overhead as well. Runtime repairs,
later startup lanes and unlimited future PNT activities are outside this reserve.

Per-unit maxima come from the exact first fifty conformance-reading commits:
Knowledge 158 lines / 11,634 bytes / two files; derived map 28 lines / 9,624 bytes;
tasks 262 lines / 19,416 bytes. The task maximum includes `.1.34`'s integration
intake, so it conservatively exceeds ordinary reading-node growth. Reading updates
existing owners; eight additional task members are reserved for governed partitioning
or bounded intake within the unchanged 128-file and per-member controls. A later
partition must preserve stable IDs and use the existing task-tree contract; this
proposal does not admit a new partition format or checker change. One future ADR
including its index row reserves 192 lines / 16,384 bytes and one file. Existing
decision limits suffice. Knowledge may need new cards instead of ever-growing ones;
all per-card limits remain. Every real leaf must remeasure rather than treating
these empirical bounds as a guarantee about unknown findings.

Each history reserves 99 complete records of at most 14 lines / 2,048 bytes.
Both independent and extracted production models roll changes after records
1, 15, 29, 43, 57, 71, 85 and 99; notes after 1, 14, 28, 42, 56, 70, 84 and 98.
A changes manifest row is bounded at576 bytes; a notes row at612. Eight rows require exactly the proposed file/manifest limits.
Notes additionally need aggregate line/byte room; changes keep both aggregate caps.
The complete compact proposal records leave notes at58,977 bytes (five bytes below
required rollover) and changes at58,911 bytes (71 bytes below). Every prior record
remains exact, with full proposal details here and one canonical Knowledge pointer.

Deleting unique evidence or rewriting immutable archives is prohibited. Moving
required evidence elsewhere does not reduce its aggregate size. Splitting files
cannot solve aggregate pressure. No sufficient removable duplication was established.
The earlier merged MethodExpr finding preserved its full recipe within current
limits; that one-file routing repair cannot supply this finite remaining reserve.
This proposal neither erases records nor raises limits to conceal a defect.

### Exact detached proposal objects

Each object below pairs baseline and proposed limits/member overrides; every other
registry field remains byte-identical. Implementation must add an accepted indexed
ADR and change only the fourteen reviewed scalars, then remeasure the actual roots
and use the existing rollover tool wherever required. Approval alone is not proof
of admission. `.4.2` owns disposition; a clean, bounded containment implementation
must complete before `.1.51` resumes. All earlier repairs, including `.2.5/.2.6`,
retain their prerequisites. No response or an earlier unrelated Granted is approval.

- Surface `change_history`
  old_limits: `{"max_bytes_per_file":524288,"max_files":39,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
  proposed_limits: `{"max_bytes_per_file":524288,"max_files":47,"max_lines_per_file":4096,"max_total_bytes":4194304,"max_total_lines":55000}`
  old_member_limits: `{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":21647,"max_lines":38}}`
  proposed_member_limits: `{"CHANGES.md":{"max_bytes":65536,"max_lines":512},"docs/history/changes/manifest.jsonl":{"max_bytes":26255,"max_lines":46}}`
- Surface `engineering_notes`
  old_limits: `{"max_bytes_per_file":524288,"max_files":35,"max_lines_per_file":4096,"max_total_bytes":3145728,"max_total_lines":28000}`
  proposed_limits: `{"max_bytes_per_file":524288,"max_files":43,"max_lines_per_file":4096,"max_total_bytes":3407872,"max_total_lines":29000}`
  old_member_limits: `{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":20514,"max_lines":34}}`
  proposed_member_limits: `{"DEVELOPMENT_NOTES.md":{"max_bytes":65536,"max_lines":512},"docs/history/development-notes/manifest.jsonl":{"max_bytes":25410,"max_lines":42}}`
- Surface `knowledge_cards`
  old_limits: `{"max_bytes_per_file":65536,"max_files":1152,"max_lines_per_file":512,"max_total_bytes":7340032,"max_total_lines":93000}`
  proposed_limits: `{"max_bytes_per_file":65536,"max_files":1350,"max_lines_per_file":512,"max_total_bytes":8388608,"max_total_lines":108000}`
  old_member_limits: `{}`
  proposed_member_limits: `{}`
- Surface `knowledge_map`
  old_limits: `{"max_bytes":8388608,"max_lines":20000}`
  proposed_limits: `{"max_bytes":8388608,"max_lines":22500}`
  old_member_limits: `{}`
  proposed_member_limits: `{}`
- Surface `task_evidence`
  old_limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":10485760,"max_total_lines":92000}`
  proposed_limits: `{"max_bytes_per_file":1048576,"max_files":128,"max_lines_per_file":8000,"max_total_bytes":12582912,"max_total_lines":120000}`
  old_member_limits: `{"docs/tasks/FUTURE-PARITY-BACKLOG.00-08.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.09.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.0-6.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.7-10.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.11-13.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.history.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl":{"max_bytes":16384,"max_lines":10},"docs/tasks/FUTURE-PARITY-BACKLOG.md":{"max_bytes":786432,"max_lines":5000}}`
  proposed_member_limits: `{"docs/tasks/FUTURE-PARITY-BACKLOG.00-08.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.09.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.0-6.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.10.7-10.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.11-13.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.6.5-8.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.14.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.history.md":{"max_bytes":786432,"max_lines":5000},"docs/tasks/FUTURE-PARITY-BACKLOG.index.jsonl":{"max_bytes":16384,"max_lines":10},"docs/tasks/FUTURE-PARITY-BACKLOG.md":{"max_bytes":786432,"max_lines":5000}}`

### Reproduction

Run these five snippets in order through the stated repository-data wrapper, saving
them only under `.linkedspec-data/scratch/conformance-capacity/`. The first pins all
fifty comparable commits and the clean baseline; the next two independently agree
on exact record movement without publishing an archive. The fourth remeasures the
current candidate plus full reserve. The fifth tests the actual production predicate
against detached proposed controls. No recipe changes a maintained source or limit.
These are proposal checks, not canonical admission or source-reading credit.

```bash
bash tools/project_data_run.sh python3 - <<'CONFORMANCE_CAPACITY_MEASURE'
from pathlib import Path
import subprocess,json,fnmatch,re
BASE='7b921a1954b1a8cf4089315491474979c580046b';w=Path('.linkedspec-data/scratch/conformance-capacity')
w.mkdir(parents=True,exist_ok=True)
def git(*args):return subprocess.check_output(['git',*args])
def lc(data):return data.count(b'\n')+int(bool(data) and not data.endswith(b'\n'))
registry=[json.loads(x) for x in git('show',BASE+':doctrine/readme_stability/routes.jsonl').splitlines()];ids=['change_history','engineering_notes','knowledge_cards','knowledge_map','task_evidence','decisions']
surfaces={r['id']:r for r in registry if r.get('id') in ids}
paths=git('ls-tree','-r','--name-only',BASE).decode().splitlines();current={}
for id,r in surfaces.items():
 selected=[p for p in paths if any(fnmatch.fnmatchcase(p,g) for g in r['members'])];data=[git('show',BASE+':'+p) for p in selected]
 current[id]={'files':len(data),'lines':sum(map(lc,data)),'bytes':sum(map(len,data)),'limits':r['limits'],'member_limits':r['member_limits']}
print(json.dumps(current,indent=2));(w/'current.json').write_text(json.dumps(current,indent=2)+'\n')
commits=[]
for line in git('log','--format=%H\t%s','--grep','^CONFORMANCE-SOURCE-READING[.]1[.]').decode().splitlines():
 h,subject=line.split('\t',1);m=re.match(r'CONFORMANCE-SOURCE-READING\.1\.(\d+) - ',subject)
 if m and int(m[1])<=50:commits.append((int(m[1]),h))
assert sorted(x[0] for x in commits)==list(range(1,51))
rows=[]
for n,h in sorted(commits):
 changes=git('diff-tree','--no-commit-id','--name-only','-r',h).decode().splitlines();row={'ordinal':n,'commit':h,'deltas':{}}
 for id,r in surfaces.items():
  if id in ['change_history','engineering_notes']:continue
  selected=[p for p in changes if any(fnmatch.fnmatchcase(p,g) for g in r['members'])];delta={'files':0,'lines':0,'bytes':0}
  for p in selected:
   pair=[]
   for rev in [h+'^',h]:
    result=subprocess.run(['git','show',rev+':'+p],capture_output=True);assert result.returncode in [0,128];pair.append(result.stdout if result.returncode==0 else None)
   delta['files']+=int(pair[1] is not None)-int(pair[0] is not None);delta['lines']+=lc(pair[1] or b'')-lc(pair[0] or b'');delta['bytes']+=len(pair[1] or b'')-len(pair[0] or b'')
  row['deltas'][id]=delta
 rows.append(row)
maxima={id:{k:max(row['deltas'][id][k] for row in rows) for k in ['files','lines','bytes']} for id in rows[0]['deltas']}
print('MAXIMA',json.dumps(maxima,indent=2));(w/'comparables.json').write_text(json.dumps({'base':BASE,'commits':rows,'maxima':maxima},indent=2)+'\n')
CONFORMANCE_CAPACITY_MEASURE
```

```bash
bash tools/project_data_run.sh python3 - <<'CONFORMANCE_CAPACITY_HISTORY'
from pathlib import Path
import subprocess,re,json,hashlib,math
BASE='7b921a1954b1a8cf4089315491474979c580046b'
def enc(x):return (json.dumps(x,sort_keys=True,separators=(',',':'))+'\n').encode()
def digest(x):return hashlib.sha256(x).hexdigest()
def lc(x):return x.count(b'\n')+int(bool(x) and not x.endswith(b'\n'))
def reached(x,pct):return lc(x)*100>=512*pct or len(x)*100>=65536*pct
def exceeded(x,pct):return lc(x)*100>512*pct or len(x)*100>65536*pct
def split(x):
 starts=[m.start() for m in re.finditer(rb'(?m)^## ',x)]
 assert starts
 return x[:starts[0]],[x[a:b] for a,b in zip(starts,starts[1:]+[len(x)])]
def future(i):
 prefix=('## Projected conformance evidence record '+str(i)+'\n\n').encode()
 rows=[b'bounded evidence\n']*12
 extra=2048-len(prefix)-sum(map(len,rows));assert extra>0
 rows[0]=b'x'*extra+rows[0]
 raw=prefix+b''.join(rows);assert lc(raw)==14 and len(raw)==2048
 return raw
registry=[json.loads(x) for x in subprocess.check_output(['git','show',BASE+':doctrine/readme_stability/routes.jsonl']).decode().splitlines()]
results=[]
for id,root,family in [('change_history','CHANGES.md','changes'),('engineering_notes','DEVELOPMENT_NOTES.md','development-notes')]:
 surface=next(x for x in registry if x.get('id')==id)
 source=subprocess.check_output(['git','show',BASE+':'+root])
 preamble,records=split(source);assert b''.join([preamble,*records])==source
 original_records=list(records)
 manifest_path='docs/history/'+family+'/manifest.jsonl'
 manifest=subprocess.check_output(['git','show',BASE+':'+manifest_path]);parsed=[json.loads(x) for x in manifest.splitlines()];metadata,history=parsed[0],parsed[1:]
 assert b''.join(enc(x) for x in parsed)==manifest
 for row in history:
  raw=Path(row['target_path']).read_bytes();assert digest(raw)==row['sha256'] and len(raw)==row['byte_count'] and lc(raw)==row['line_count']
 query=b''.join(Path(row['target_path']).read_bytes() for row in history)
 actual_query=subprocess.check_output(['perl','tools/read_document_history.pl','--surface',id,'--all']);assert actual_query.endswith(query)
 old_paths={Path(root),Path(manifest_path),*(Path(row['target_path']) for row in history)}
 baseline_bytes=[source,manifest]+[Path(row['target_path']).read_bytes() for row in history]
 old_total_lines=sum(map(lc,baseline_bytes));old_total_bytes=sum(map(len,baseline_bytes))
 rollovers=[]
 current=source;archived_total=b'';all_future=[]
 for i in range(1,100):
  added=future(i);all_future.insert(0,added);before=current
  records.insert(0,added);candidate=preamble+b''.join(records)
  if reached(candidate,90):
   keep=len(records)
   while keep>1 and exceeded(preamble+b''.join(records[:keep]),50):keep-=1
   retained=preamble+b''.join(records[:keep]);assert keep>=1 and not exceeded(retained,50)
   archive=b''.join(records[keep:]);assert archive and before.endswith(archive)
   # Runtime source range points into this simulated prior clean root, never a real commit.
   start=lc(before[:-len(archive)])+1;end=lc(before)
   nr=int(history[0]['segment_id'])-1;sid=f'{nr:04d}';sha=digest(archive)
   row=dict(byte_count=len(archive),current_path=root,immutable=True,line_count=lc(archive),
    retrieval_command='perl tools/read_document_history.pl --surface '+id+' --segment '+sid,
    segment_id=sid,sha256=sha,source_blob='0'*40,source_commit='0'*40,
    source_end_line=end,source_path=root,source_start_line=start,surface=id,
    target_path='docs/history/'+family+'/segment-'+sid+'-'+sha[:12]+'.md',type='segment')
   history.insert(0,row);metadata['segment_count']=len(history)
   rollovers.append(dict(after_record=i,candidate=[lc(candidate),len(candidate)],retained=[lc(retained),len(retained)],archived=[lc(archive),len(archive)],manifest_row_bytes=len(enc(row))))
   archived_total=archive+archived_total
   records=records[:keep];current=retained
  else:current=candidate
  assert preamble+b''.join(all_future)+b''.join(original_records)==current+archived_total
 new_manifest=enc(metadata)+b''.join(enc(row) for row in history)
 # Bound every potential new record by actual schema widths, not favorable model coordinates.
 template=dict(history[0]);template.update(byte_count=65536,line_count=512,source_start_line=512,source_end_line=512,source_blob='f'*40,source_commit='f'*40,sha256='f'*64)
 template['target_path']='docs/history/'+family+'/segment-0001-'+'f'*12+'.md';template['segment_id']='0001';template['retrieval_command']='perl tools/read_document_history.pl --surface '+id+' --segment 0001'
 per_row_bound=len(enc(template))
 allowance=len(rollovers)
 new_limits=dict(surface['limits'],max_files=max(surface['limits']['max_files'],len(old_paths)+allowance))
 if id=='engineering_notes':new_limits.update(max_total_lines=29000,max_total_bytes=3407872)
 new_member=dict(surface['member_limits'][manifest_path],max_lines=max(surface['member_limits'][manifest_path]['max_lines'],lc(manifest)+allowance),max_bytes=max(surface['member_limits'][manifest_path]['max_bytes'],len(manifest)+allowance*per_row_bound))
 forecast_lines=old_total_lines+99*14+allowance;forecast_bytes=old_total_bytes+99*2048+allowance*per_row_bound
 assert forecast_lines<=new_limits['max_total_lines'] and forecast_bytes<=new_limits['max_total_bytes']
 assert len(new_manifest)<=new_member['max_bytes']
 result=dict(surface=id,root=root,baseline=BASE,source_blob=subprocess.check_output(['git','rev-parse',BASE+':'+root]).decode().strip(),current=[lc(source),len(source)],collection=[len(old_paths),old_total_lines,old_total_bytes],manifest=[lc(manifest),len(manifest),digest(manifest)],query=[lc(query),len(query),digest(query)],record_budget=[99,14,2048],rollovers=rollovers,new_limits=new_limits,old_limits=surface['limits'],old_manifest_limit=surface['member_limits'][manifest_path],new_manifest_limit=new_member,manifest_row_byte_bound=per_row_bound,forecast=[forecast_lines,forecast_bytes],modeled_final=[lc(current),len(current)])
 results.append(result)
 print(json.dumps(result,indent=2))
Path('.linkedspec-data/scratch/conformance-capacity').mkdir(parents=True,exist_ok=True)
Path('.linkedspec-data/scratch/conformance-capacity/model.json').write_text(json.dumps(results,indent=2)+'\n')
print('PASS 99-record dual-axis simulation per surface, all prefix/suffix byte reconstruction, current manifests/archives, full history queries, aggregate forecasts; no history or registry mutation.')
CONFORMANCE_CAPACITY_HISTORY
```

```bash
bash tools/project_data_run.sh perl - <<'CONFORMANCE_CAPACITY_PRODUCTION'
use strict;use warnings;use JSON::PP;use Digest::SHA qw(sha256_hex);
my $MAX_LINES=512;my $MAX_BYTES=65536;my $code;
{open my $fh,'<:raw','tools/roll_document_history.pl' or die $!;local $/;$code=<$fh>}
my $extracted='';
for my $bounds (['sub split_current {','sub validate_preamble {'],['sub threshold_reached {','sub read_manifest {'],['sub segment_record {','sub usage {']) {
 my ($a,$b)=map {index($code,$_)} @$bounds;die 'subroutine source boundary' if $a<0||$b<$a;$extracted.=substr($code,$a,$b-$a)."\n";
}
eval $extracted;die $@ if $@;
my $expected;{open my $fh,'<:raw','.linkedspec-data/scratch/conformance-capacity/model.json' or die $!;local $/;$expected=JSON::PP->new->decode(<$fh>)}
my $json=JSON::PP->new->canonical->utf8;
for my $model (@$expected) {
 my $root=$model->{root};open my $git,'-|','git','show',"$model->{baseline}:$root" or die $!;binmode $git;my $raw=do {local $/;<$git>};close $git or die 'git source';
 my ($pre,$records)=split_current($raw,{boundary=>($root eq 'CHANGES.md'?qr/^## /m:qr/^(?:- 20[0-9]{2}-[0-9]{2}\b|## )/m),current=>$root});
 my @rolls;
 for my $i (1..99) {
  my $prefix="## Projected conformance evidence record $i\n\n";my @rows=("bounded evidence\n")x12;my $extra=2048-length($prefix)-length(join('',@rows));$rows[0]=('x'x$extra).$rows[0];my $new=$prefix.join('',@rows);
  die 'synthetic bound' unless line_count($new)==14 && length($new)==2048;
  unshift @$records,$new;my $candidate=$pre.join_prefix($records,scalar @$records);
  if(threshold_reached(line_count($candidate),length($candidate),90)) {
   my $keep=scalar @$records;
   while($keep>1 && threshold_exceeded(line_count($pre.join_prefix($records,$keep)),length($pre.join_prefix($records,$keep)),50)) {--$keep}
   my $retained=$pre.join_prefix($records,$keep);my $archived=join('',@$records[$keep..$#$records]);
   push @rolls,{after_record=>$i,candidate=>[line_count($candidate),length($candidate)],retained=>[line_count($retained),length($retained)],archived=>[line_count($archived),length($archived)]};
   @$records=@$records[0..$keep-1];
  }
 }
 die 'rollover count' unless @rolls==@{$model->{rollovers}};
 for my $i (0..$#rolls) {
  my %expected=%{$model->{rollovers}[$i]};delete $expected{manifest_row_bytes};
  die 'actual function model mismatch' unless $json->encode($rolls[$i]) eq $json->encode(\%expected);
 }
 my $family=$root eq 'CHANGES.md'?'changes':'development-notes';my $id=$model->{surface};
 my $record=segment_record($id,{current=>$root},'0001',"docs/history/$family/segment-0001-".('f'x12).'.md','f'x64,'f'x40,'f'x40,512,512,512,65536);
 die 'row byte-bound mismatch' unless length($json->encode($record)."\n")==$model->{manifest_row_byte_bound};
 print "PASS $id: 99 source-function simulations; ".scalar(@rolls)." exact rollovers; maximal future row $model->{manifest_row_byte_bound} bytes\n";
}
CONFORMANCE_CAPACITY_PRODUCTION
```

```bash
bash tools/project_data_run.sh python3 - <<'CONFORMANCE_CAPACITY_RESERVE'
from pathlib import Path
import json,subprocess
BASE='7b921a1954b1a8cf4089315491474979c580046b';w=Path('.linkedspec-data/scratch/conformance-capacity');units=99
cmp=json.loads((w/'comparables.json').read_text());assert cmp['base']==BASE and len(cmp['commits'])==50
models=json.loads((w/'model.json').read_text());reserve={}
for name in ['knowledge_cards','task_evidence','knowledge_map']:
 reserve[name]={k:units*cmp['maxima'][name][k] for k in ['lines','bytes']}
reserve['knowledge_cards']['files']=units*cmp['maxima']['knowledge_cards']['files']
# Reading updates existing owners; eight slots cover bounded repartitioning/intake.
reserve['task_evidence']['files']=8
reserve['decisions']={'files':1,'lines':192,'bytes':16384}
for m in models:
 assert m['baseline']==BASE and m['record_budget']==[99,14,2048] and len(m['rollovers'])==8
 reserve[m['surface']]={'files':8,'lines':units*14+8,'bytes':units*2048+8*m['manifest_row_byte_bound']}
p=Path('doctrine/readme_stability/routes.jsonl');assert p.read_bytes()==subprocess.check_output(['git','show',BASE+':'+str(p)])
report={};changes=[]
for row in map(json.loads,p.read_text().splitlines()):
 name=row.get('id')
 if name not in reserve:continue
 limits=dict(row['limits']);overrides=json.loads(json.dumps(row['member_limits']))
 if name=='knowledge_cards':limits.update(max_files=1350,max_total_lines=108000,max_total_bytes=8388608)
 if name=='knowledge_map':limits['max_lines']=22500
 if name=='task_evidence':limits.update(max_total_lines=120000,max_total_bytes=12582912)
 if name in ['change_history','engineering_notes']:
  m=next(m for m in models if m['surface']==name);limits=m['new_limits'];path='docs/history/'+('changes' if name=='change_history' else 'development-notes')+'/manifest.jsonl';overrides[path]=m['new_manifest_limit'];raw=Path(path).read_bytes()
  assert raw.count(b'\n')+8<=overrides[path]['max_lines'] and len(raw)+8*m['manifest_row_byte_bound']<=overrides[path]['max_bytes']
 paths=sorted({q for pattern in row['members'] for q in Path('.').glob(pattern) if q.is_file()});assert all(not q.is_symlink() for q in paths)
 current={'files':len(paths),'lines':sum(q.read_bytes().count(b'\n') for q in paths),'bytes':sum(q.stat().st_size for q in paths)}
 projected={key:value+reserve[name].get(key,0) for key,value in current.items()}
 for key,value in projected.items():
  cap=limits.get('max_'+key,limits.get('max_total_'+key))
  if cap is not None:assert value<=cap,(name,key,value,cap)
 for q in paths:
  override=overrides.get(str(q),{});raw=q.read_bytes()
  for key,value in [('lines',raw.count(b'\n')),('bytes',len(raw))]:
   cap=override.get('max_'+key,limits.get('max_'+key+'_per_file',limits.get('max_'+key)))
   if cap is not None:assert value<=cap,(str(q),key,value,cap)
 for key,new in limits.items():
  old=row['limits'][key]
  if new!=old:changes.append([name,'limits.'+key,old,new])
 for path,values in overrides.items():
  for key,new in values.items():
   old=row['member_limits'][path][key]
   if new!=old:changes.append([name,path+'.'+key,old,new])
 report[name]={'current':current,'reserve':reserve[name],'projected':projected,'old_limits':row['limits'],'proposed_limits':limits,'old_member_limits':row['member_limits'],'proposed_member_limits':overrides}
assert set(report)==set(reserve) and len(changes)==14
(w/'reserve.json').write_text(json.dumps(report,indent=2)+'\n');(w/'changes.json').write_text(json.dumps(changes,indent=2)+'\n')
for name,r in report.items():print(name,json.dumps({'current':r['current'],'reserve':r['reserve'],'projected':r['projected']},sort_keys=True))
print('EXACT 14 SCALARS',json.dumps(changes));print('PASS current candidate plus full 99-unit reserve; all hot-file and general per-file controls unchanged; registry unchanged.')
CONFORMANCE_CAPACITY_RESERVE
```

```bash
bash tools/project_data_run.sh perl - <<'CONFORMANCE_CAPACITY_BOUNDARIES'
use strict;use warnings;use JSON::PP;
sub read_raw {my($p)=@_;open my $f,'<:raw',$p or die $!;local $/;return <$f>}
my $source=read_raw('scripts/check_readme_routing_pressure.pl');my($fn)=$source=~/(^sub exceeds_limits \{.*?^\})/ms;die 'validator missing' unless $fn;eval($fn."\n1;") or die $@;
my $json=JSON::PP->new->canonical;my $report=$json->decode(read_raw('.linkedspec-data/scratch/conformance-capacity/reserve.json'));my $n=0;
for my $name(sort keys %$report){
 my $r=$report->{$name};my @objects=([$r->{proposed_limits},'collection']);push @objects,map {[$r->{proposed_member_limits}{$_},$_]} sort keys %{$r->{proposed_member_limits}};
 for my $object(@objects){my($limits,$label)=@$object;
  for my $key(sort keys %$limits){for my $offset(-1,0,1){
   my $m={files=>0,lines=>0,bytes=>0,members=>['sample.md'],per_file=>{'sample.md'=>{lines=>0,bytes=>0}}};my $value=$limits->{$key}+$offset;
   if($key=~/^max_(lines|bytes)_per_file$/){$m->{per_file}{'sample.md'}{$1}=$value}
   elsif($key=~/^max_(?:total_)?(lines|bytes|files)$/){$m->{$1}=$value}else{die "unhandled $key"}
   my @errors=exceeds_limits($m,$limits);die "$name $label $key $offset: @errors" unless @errors==($offset==1?1:0);++$n;
  }}
 }
 my $m={%{$r->{projected}},members=>[],per_file=>{}};my @old=exceeds_limits($m,$r->{old_limits});my @new=exceeds_limits($m,$r->{proposed_limits});die "$name proposed reserve rejected: @new" if @new;
 die "$name unchanged decision reserve unexpectedly fails" if $name eq 'decisions' && @old;
 die "$name existing controls unexpectedly accept full reserve" if $name ne 'decisions' && !@old;
 print "$name old-control reserve rejection: ",join('; ',@old)||'none; unchanged decision reserve fits',"\n";$n+=2;
}
my $models=$json->decode(read_raw('.linkedspec-data/scratch/conformance-capacity/model.json'));
for my $m(@$models){my $name=$m->{surface};my $path='docs/history/'.($name eq 'change_history'?'changes':'development-notes').'/manifest.jsonl';my $raw=read_raw($path);my $metrics={lines=>scalar(split /\n/,$raw)+8,bytes=>length($raw)+8*$m->{manifest_row_byte_bound}};
 my @old=exceeds_limits($metrics,$report->{$name}{old_member_limits}{$path});my @new=exceeds_limits($metrics,$report->{$name}{proposed_member_limits}{$path});die "$name manifest reserve" unless @old==2 && !@new;$n+=2;
}
print "PASS $n actual production-validator executions: independent below/equal/above boundaries and old/proposed aggregate reserve controls. No registry edits.\n";
CONFORMANCE_CAPACITY_BOUNDARIES
```

## Current Frontier

Integration .2.1 intentionally updates the already-read cursor contract inventory
from74 to75 for its new public guide, plus current marker mirrors in the checker.
Original reading windows and counters remain historical and unchanged; the
post-activity source-delta audit must retain this explicit documentation-only delta.
The same integration leaf updates the mutation public-file census63->64 and
selector public-file census62->63. It classifies three existing Julia limitation
references (32->35 total) with one invalid-example comment; runtime contracts and
the existing Julia repair remain unchanged. Preserve these checker-only deltas
in the later tooling/source audit without rewriting historical reading evidence.
Integration .6 later advances current public counts to mutation69/selector68 and
cursor76, with count-only checker/mirror changes. Integration .8.6 replaces one
Lua test input with an owned inline marker fixture; production semantics remain
unchanged. Retain these deltas in the eventual source reconciliation, with no
additional reading credit from integration delivery.

| Rank | Leaf | Status | Next action |
| --- | --- | --- | --- |
| 1 | `CONFORMANCE-SOURCE-READING.1.79` | `pending` | Read Phase0 lines 45064–46191 (1,128 fragments / 65,516 baseline bytes), reading the bare-mutation repeated-invocation test body and subsequent declaration checks. Repairs .2.5–.2.14 and earlier repairs retain required source/book/policy reading prerequisites. |

## Decisions

- `2026-09-13` .1.1: Extend existing startup .41.6/.41.7 with exact guide-current contradictions and checker coverage; preserve historical milestones and keep code repairs behind startup prerequisites. No duplicate repair owner or current runtime failure is invented.
- `2026-09-13`: All160 inputs remain required by startup .3.8; gzip coordinates describe decoded source. The exact existing1500-fragment/65536-byte budgets yield143 groups; no source or capacity policy changes.

## Blockers

- None at decomposition. Ordinary source repairs retain startup prerequisites; later collection pressure must be measured rather than assumed away.

## Verification Log

- `2026-09-21` .1.78: 11 complete windows cover 1,147 fragments / 65,472 baseline bytes; ordered window SHA-256 5ad019d2a261916fd5179bd2fc9ec14efb9946c205d1841bd9d0d9c8420ac52f. Cumulative reading is 78/143 groups, 94,558 fragments / 4,150,753 baseline bytes and 97 complete files. Phase0 is partial through line 45063. Unchanged canonical commit ec10be6b retains PASS for 22 completed subtests, ordinals 961–982 with 392 direct assertions and no nested plans. Exact TAP numbering and source identity are verified. The selected Markdown scan covers 65 current files, not all tracked Markdown. Self-hosting smokes check bounded completion/defined results; function-body tests check exact AST metadata, spans, jobs, diagnostics and runtime values. Recursion checks distinguish termination, LX sequence results and entry/local match ownership. Genuine declaration-count and repeated-call checks coexist with stale wrapper/channel labels. Public capture plus declaration-removal controls establish .2.14; the next bare-mutation test has only its declaration read. Fresh diagnosis confirms .2.14 without closing a repair; no production change, dependency build, canonical run or push is claimed; .2.5–.2.14 and all prerequisites remain.

- `2026-09-21` .1.77: 11 complete windows cover 1,029 fragments / 65,477 baseline bytes; ordered window SHA-256 8e331eed03bfb3e6fd8e61d9b3dc8908326dabcadd7d88ce8b1e36d4c805a25c. Cumulative reading is 77/143 groups, 93,411 fragments / 4,085,281 baseline bytes and 97 complete files. Phase0 is partial through line 43916. Unchanged canonical commit ec10be6b retains PASS for 35 completed subtests, ordinals 926–960 with 479 direct assertions and no nested plans. Exact TAP numbering and source identity are verified. Tkgui and simenv check exact ASTs and quiet output; Lispish checks its historical AST, while VHDL/EBNF smoke checks cover selected tags/names. Trace checks include scopes, mark positions/caret excerpts, exact capture output and nonempty file routing. Five uppercase-slot comparisons retain .2.10 limits. Default seek and AND consume execute input controls; parse_mode rejection checks structured prepare-options diagnostics. The Markdown path scan is partial after leak-array initialization; .1.78 owns its suffix. Fresh diagnosis confirms .2.13 without closing a repair; no production change, dependency build, canonical run or push is claimed; .2.5–.2.13 and all prerequisites remain.

- `2026-09-21` .1.76: 11 complete windows cover 800 fragments / 65,456 baseline bytes; ordered window SHA-256 4cf7775ac2ba5691da7e40961a1fffa66cb8f9db6837120d880949270205683c. Cumulative reading is 76/143 groups, 92,382 fragments / 4,019,804 baseline bytes and 97 complete files. Phase0 is partial through line 42887. Unchanged canonical commit ec10be6b retains PASS for 33 completed subtests, ordinals 893–925 with 650 direct assertions and no nested plans. Exact TAP numbering and source identity are verified. VHDL source migrations and shipped-spec readiness remain bounded metadata/source checks. Runtime smokes cover ifelse undef/quiet stdout, three hlink ASTs, lib_reader grouped attributes, EBNF logging annotations and seven portmap classifications. Pplugin preserves body text before its legacy Perl adapter creates and executes coderefs. Tkgui is partial after its three-rule metadata loop; .1.77 owns node/summary assertions. No new defect, fresh target execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.12 and all prerequisites remain.

- `2026-09-21` .1.75: Eleven complete windows cover 892 fragments / 65,464 baseline bytes; ordered window SHA-256 0fd9f0f9d1f4d1539f116ce5aeaa7290432c1c7c3c0115ce1d88086f81689311. Cumulative reading is 75/143: 91,582 fragments / 3,954,348 baseline bytes and 97 complete files. Phase0 is partial through line 42087. Unchanged canonical commit ec10be6b retains PASS for thirty-six completed subtests, ordinals 857–892 with 470 direct assertions and no nested plans. Exact TAP numbering and source identity are verified. Quote-aware statement boundaries preserve nested and quoted semicolons. EBNF, ds_vhistory, regdef, tablegrep and VHDL checks primarily observe descriptor metadata and helper source spelling; regdef also executes a parser and checks an exact AST. Readiness metadata is not arbitrary grammar acceptance or cross-backend runtime proof. The concurrent VHDL assignment source test remains partial after its positive reorder assertion; .1.76 owns the suffix. No new defect, fresh target execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.12 and all prerequisites remain.

- `2026-09-21` .1.74: Eleven complete windows cover 753 fragments / 65,404 baseline bytes; ordered window SHA-256 2bb4a08a7e319a21ab3cfdfcd732a88e1045c54ae0a07d25fc4bc4db88c717ce. Cumulative reading is 74/143: 90,690 fragments / 3,888,884 baseline bytes and 97 complete files. Phase0 is partial through line 41195. Unchanged canonical commit ec10be6b retains PASS for twenty-nine completed subtests, ordinals 828–856 with 323 direct assertions and no nested plans. Exact TAP numbering and source identity are verified. Typed source-location runtime-call substrings, trace operations, canonical nodes and readiness are observed; these checks do not execute endpoint arithmetic or mark advancement. Direct capture_slice_len has an exact anonymous-boundary expression. Legacy print/declaration/position/regex/assignment forms preserve authored text; print_each uses typed diagnostic output. No parser-result assertions or uppercase descriptor-code comparisons occur in these completed tests. Split/trim/filter remains partial after descriptor build; .1.75 owns the suffix. No new defect, fresh target execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.12 and all prerequisites remain.

- `2026-09-21` .1.73: Eleven complete windows cover 1088 fragments / 65,436 baseline bytes; ordered window SHA-256 67008351310e458e80937388d3cc69050216d09547fd38070cc9e80cd583192f. Cumulative reading is 73/143: 89,937 fragments / 3,823,480 baseline bytes and 97 complete files. Phase0 is partial through line 40442. Unchanged canonical commit ec10be6b retains PASS for twenty-eight completed subtests, ordinals 800–827 with 291 direct plan entries including five nested-subtest results; those five nested plans contain 40 further assertions. Exact TAP numbering and source identity are verified. Switch cases execute first/later/default selection; while cases execute false-entry skip, condition mutation and a nonterminating-loop guard returning a failed match with diagnostic. Six uppercase-slot assertions retain .2.10 limits; the five-tag semicolonless loop checks metadata and hits without reading its code-key variables. Compatibility/readiness summaries remain distinct from runtime portability. Prefix-newline linecount is partial after descriptor build; .1.74 owns the suffix. No new defect, fresh target execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.12 and all prerequisites remain.

- `2026-09-21` .1.72: Eleven complete windows cover 851 fragments / 65,534 baseline bytes; ordered window SHA-256 3a7f14ed253714738cfc2014066b4b868b00667ab0c90726df1c48cc538a6f06. Cumulative reading is 72/143: 88,849 fragments / 3,758,044 baseline bytes and 97 complete files. Phase0 is partial through line 39354. Unchanged canonical commit ec10be6b retains PASS for seventeen completed subtests, ordinals 783–799 with 235 direct assertions and no nested plans. Seven descriptor plans contribute 84 assertions; three numeric text plans contribute 14; flat-list/string/tagged-record plans contribute 48; three conditional/lifecycle plans contribute 89, including nine parser-result assertions and seven positive marker source checks. Exact TAP numbering and source identity are verified. Meaningful bounded source/runtime observations remain distinct from .2.10 uppercase-slot equality and startup .27 lifecycle drift. Switch coverage is partial before its first expected pattern; .1.73 owns the suffix. No new defect, fresh target execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.12 and all prerequisites remain.

- `2026-09-21` .1.71: Eleven complete windows cover 759 fragments / 65,504 baseline bytes; ordered window SHA-256 59d454151dbf825b3c0242fd66d004452f8a6c21093d9cca573fdba96c46dce7. Cumulative reading is 71/143: 87,998 fragments / 3,692,510 baseline bytes and 97 complete files. Phase0 is partial through line 38503. Unchanged canonical commit ec10be6b retains PASS for twenty-one completed subtests, ordinals 762–782 with 196 direct assertions and no nested plans: fourteen descriptor plans contribute 168 and seven direct-lowering plans contribute 28. Exact TAP numbering/source identity are verified. Four freshly extracted subtests pass 16 assertions; four public assignment executions return expected ARRAY references. Their list-context-flattening descriptions are stale; .2.12 owns correction after prerequisites, with exact reproduction in phase0-array-assignment-description-drift. Inner list construction remains valid; descriptor uppercase-slot limits remain .2.10-owned. Lifecycle num_avg is partial after assertion four. No tracked test repair, dependency build, canonical run or push; .2.5–.2.12 and earlier repairs remain.

- `2026-09-21` .1.70: Eleven complete windows cover 797 fragments / 65,524 baseline bytes; ordered window SHA-256 4fb287cc34d0db219abf17c32d98bf8a374eeea673663960ca7ddc882f7d6611. Cumulative reading is 70/143: 87,239 fragments / 3,627,006 baseline bytes and 97 complete files. Phase0 is partial through line 37744. Unchanged canonical commit ec10be6b retains PASS for twenty-one completed subtests, ordinals 741–761 with 196 direct assertions and no nested plans. Fourteen descriptor comparisons contribute 168 assertions; seven four-assertion direct-lowering plans contribute 28 textual checks. Exact TAP numbering and source identity are verified. Hash lookup, merge, snapshot and key-transform expectations inspect expressions and patterns; they do not execute copy isolation, collision outcomes or mutation behavior. Descriptor uppercase-slot comparisons remain .2.10-owned. Lifecycle pick_keys is partial after ten assertions at the opening of readiness; .1.71 owns the final two. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.

- `2026-09-21` .1.69: Eleven complete windows cover 657 fragments / 65,437 baseline bytes; ordered window SHA-256 69327ea77a1e57cca29663241de96f0d256a4301a3ac06781867c8b6e43a1ec7. Cumulative reading is 69/143: 86,442 fragments / 3,561,482 baseline bytes and 97 complete files. Phase0 is partial through line 36947. Unchanged canonical commit ec10be6b retains PASS for nineteen completed subtests, ordinals 722–740 with 150 direct assertions and no nested plans. Nine descriptor comparisons contribute 108 assertions; ten direct-lowering plans (nine of four and one of six) contribute 42 textual assertions. Exact TAP numbering and source identity are verified. Membership, literal replacement, boundary removal, concatenation, emptiness, index and reducer expectations observe lowering text, not evaluated target results. Descriptor uppercase-slot comparisons remain .2.10-owned. Lifecycle count_keys is partial after its two descriptor-build assertions; .1.70 owns the remaining ten. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.

- `2026-09-21` .1.68: Eleven complete windows cover 861 fragments / 65,511 baseline bytes; ordered window SHA-256 01426c078629e81653e48b56bc551044f7f812cbf5fa75dce094c2a97194a1e7. Cumulative reading is 68/143: 85,785 fragments / 3,496,045 baseline bytes and 97 complete files. Phase0 is partial through line 36290. Unchanged canonical commit ec10be6b retains PASS for twenty-two completed subtests, ordinals 700–721 with 221 direct assertions and no nested plans. Seventeen descriptor comparisons contribute 204 assertions; five direct-lowering plans of 2,3,4,5,3 contribute seventeen textual assertions. Exact TAP numbering and source identity are verified. Lowering observations distinguish fallback, definedness, aggregate emptiness and scalar normalization; they do not execute generated target code. Descriptor uppercase-slot comparisons remain .2.10-owned. The next action scalar-normalization comparison is partial after its fluent fixture; .1.69 owns the structured fixture and assertions. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.

- `2026-09-21` .1.67: Eleven complete windows cover 884 fragments / 65,500 baseline bytes; ordered window SHA-256 bb1fc116fa44e396ffb67f08fc017e0f2445fde3899c086284da032f9ceb07ed. Cumulative reading is 67/143: 84,924 fragments / 3,430,534 baseline bytes and 97 complete files. Phase0 is partial through line 35429. Unchanged canonical commit ec10be6b retains PASS for twenty completed subtests, ordinals 680–699 with 240 direct assertions, twelve per subtest and no nested plans. Exact TAP numbering and source identity are verified. Modulo/clamp and drop helpers precede action/LX join-values and flat-list branches, direct call capture and action if/elseif call capture. Existing .2.10 owns meaningful code observation; descriptor checks do not establish helper values, executed branch choices or Leaf call results. The action switch call-value test has eleven complete assertions and a partial final node predicate after CALL; .1.68 owns its suffix. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.

- `2026-09-21` .1.66: Eleven complete windows cover 830 fragments / 65,423 baseline bytes; ordered window SHA-256 c8fbb8436dda0ca3c4c2e13fb09209cb1a87ac3e54995f521ad690153ddf6b00. Cumulative reading is 66/143: 84,040 fragments / 3,365,034 baseline bytes and 97 complete files. Phase0 is partial through line 34545. Unchanged canonical commit ec10be6b retains PASS for twenty completed subtests, ordinals 660–679 with 240 direct assertions, twelve per subtest and no nested plans. Exact TAP numbering and source identity are verified. Action/LX pairs cover take_last, scalar boundaries and transforms, substring operations, concatenation, regex predicates, arithmetic and product/division; the action min/max comparison is complete. Existing .2.10 owns meaningful code observation; descriptor-node comparisons do not establish helper results or hit-map equality. The lifecycle min/max test is partial after its first build assertion; .1.67 owns the remaining eleven assertions. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.

- `2026-09-21` .1.65: Eleven complete windows cover 957 fragments / 65,498 baseline bytes; ordered window SHA-256 3086a7521b7042366071ae5a8e16d12033568731a8b5d5a28bf2bbc24d27a8e0. Cumulative reading is 65/143: 83,210 fragments / 3,299,611 baseline bytes and 97 complete files. Phase0 is partial through line 33715. Unchanged canonical commit ec10be6b retains PASS for nineteen completed subtests, ordinals 641–659 with 222 direct assertions, including seven nested results. The seven-tag lifecycle loop separately verifies 63 inner assertions with nine assertions per tag and exact TAP numbering. Seventeen complete fluent/structured helper comparisons have twelve assertions each. Their uppercase-slot equality remains .2.10-owned; metadata node presence and node-list equality do not establish runtime helper semantics, copy isolation or hit-map equality. The lifecycle slice-array test is partial after assertion ten; .1.66 owns readiness and final node checks. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.

- `2026-09-21` .1.64: Nine complete windows cover 1,500 fragments / 54,211 baseline bytes; ordered window SHA-256 c37e9c1631c4bbf54e5fa1eb9af15a2b8914e9fbb8c941937902c704e6ad8963. Cumulative reading is 64/143: 82,253 fragments / 3,234,113 baseline bytes and 97 complete files. Phase0 is partial through line 32758. Unchanged canonical commit ec10be6b retains PASS for eleven completed subtests, ordinals 630–640 with 95 direct assertions, including 42 nested results. Six seven-tag lifecycle loops separately verify 329 inner assertions with per-tag plans 7,9,9,9,6,7 and exact TAP numbering. The next composite-if deep-marker action test is partial in its first fixture; .1.65 owns its suffix. Minimum helper-hit and node-presence assertions establish bounded descriptor metadata coverage. Code-output-labelled slot comparisons remain in existing .2.10 inventory and do not establish emitted-code or target execution equivalence. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.

- `2026-09-21` .1.63: Nine complete windows cover 1,500 fragments / 52,166 baseline bytes; ordered window SHA-256 0cadf02b6261aa31c991d3633f7a8f54d3be2cb18e830ab57632a8da02d29bd8. Cumulative reading is 63/143: 80,753 fragments / 3,179,902 baseline bytes and 97 complete files. Phase0 is partial through line 31258. Unchanged canonical commit ec10be6b retains PASS for ten completed subtests, ordinals 620–629 with 90 direct assertions, including 35 nested results. Five seven-tag lifecycle loops separately verify 252 inner assertions: one loop with eight assertions per tag and four with seven, with exact TAP numbering and plans. The following composite-if multi-case inline-switch lifecycle loop is partial inside its first fixture; .1.64 owns its suffix. Selected marker-node presence is not equality of node lists or hit maps. Code-output-labelled slot comparisons remain in existing .2.10 inventory and do not establish emitted-code or target execution equivalence. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.

- `2026-09-21` .1.62: Ten complete windows cover 1,500 fragments / 60,456 baseline bytes; ordered window SHA-256 b606ad20c57aada668dd3790b00eecd8df6f00237325af1a7718a8662c05f99d. Cumulative reading is 62/143: 79,253 fragments / 3,127,736 baseline bytes and 97 complete files. Phase0 is partial through line 29758. Unchanged canonical commit ec10be6b retains PASS for eleven completed subtests, ordinals 609–619 with 111 direct assertions, including 35 nested results. Five seven-tag lifecycle loops separately verify 308 inner assertions: four loops with nine assertions per tag and one with eight, with exact TAP numbering and plans. The next outer-family multi-case lifecycle declaration has only its I and LS entries read; .1.63 owns its suffix. Cross-family node coverage does not claim equal hit counts. Code-output-labelled slot comparisons remain in existing .2.10 inventory and do not establish emitted-code or target execution equivalence. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.

- `2026-09-21` .1.61: Ten complete windows cover 1,500 fragments / 60,428 baseline bytes; ordered window SHA-256 2c976b6b4b826194edf2787f6fc80ba2b2b7e692c21740b5f43795c6ceba63f5. Cumulative reading is 61/143: 77,753 fragments / 3,067,280 baseline bytes and 97 complete files. Phase0 is partial through line 28258. Unchanged canonical commit ec10be6b retains PASS for eleven completed subtests, ordinals 598–608 with 107 direct assertions, including 42 nested results. Six seven-tag lifecycle loops separately verify 364 inner assertions: one loop with seven assertions per tag and five with nine, with exact TAP numbering and plans. The following deep-marker action pair has both fixtures and five of thirteen assertions read; .1.62 owns its suffix. Code-output-labelled slot comparisons remain in existing .2.10 inventory and do not establish emitted-code or target execution equivalence. No independently reproduced new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.

- `2026-09-21` .1.60: Nine complete windows cover 1,500 fragments / 55,852 baseline bytes; ordered window SHA-256 a72b414e4aba4d0b75d5895dc4bb7520ff47518e158903ab2d3d1882064ffb91. Cumulative reading is 60/143: 76,253 fragments / 3,006,852 baseline bytes and 97 complete files. Phase0 is partial through line 26758. Unchanged canonical commit ec10be6b retains PASS for twelve completed subtests, ordinals 586–597 with 108 direct assertions, including 42 nested results. Six seven-tag lifecycle loops separately verify 336 inner assertions: three loops with nine assertions per tag and three with seven, with exact TAP numbering and plans. The following marker/marker multi-case lifecycle loop has its plan read but is partial inside the first fixture; .1.61 owns its suffix. Explicit slot-shape and metadata checks do not establish code or target execution equivalence. No new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.

- `2026-09-21` .1.59: Nine complete windows cover 1,500 fragments / 55,331 baseline bytes; ordered window SHA-256 8820745511b704f049a371d28568870836a228096b590b1193370fa18000a75f. Cumulative reading is 59/143: 74,753 fragments / 2,951,000 baseline bytes and 97 complete files. Phase0 is partial through line 25258. Unchanged canonical commit ec10be6b retains PASS for nine completed subtests, ordinals 577–585 with 93 direct assertions, including 28 nested results. Four seven-tag lifecycle loops separately verify 252 inner assertions, each nine assertions per tag, with exact TAP numbering and plans. The following marker-outer multi-case lifecycle loop has its plan read but is partial inside the first fixture; .1.60 owns its suffix. Explicit slot-shape and metadata checks do not establish code or target execution equivalence. No new defect, runtime execution, repair, dependency build, canonical run or push is claimed; .2.5–.2.11 and all prerequisites remain.

- `2026-09-21` .1.58: Ten complete windows cover 1,500 fragments / 62,624 baseline bytes; ordered window SHA-256 617330f9895feb45a764ca6838fc3682994e771eac5a675bab8c3c71517ffbe6. Cumulative reading is 58/143: 73,253 fragments / 2,895,669 baseline bytes and 97 complete files. Phase0 is partial through line 23758. Unchanged canonical commit ec10be6b retains PASS for 18 completed subtests, ordinals 559–576 with 160 direct assertions, including 63 nested results. Nine seven-tag loops separately verify 476 inner assertions with exact tag order, TAP numbering and plans. The next marker-outer nested if/elseif inline-switch test is partial inside its first fixture; .1.59 owns the suffix. Current-slot-shape checks are distinguished from absent-slot equivalence claims, which remain .2.10-owned. No new defect, target runtime execution, repair, dependency build, canonical run or push is claimed; all prerequisites remain.

- `2026-09-21` .1.57: Eleven complete windows cover 1,201 fragments / 65,530 baseline bytes; ordered window SHA-256 52807d4d6bde6106e84ccdb9edaf0b565589a4457e5959109722e984b50e87cb. Cumulative reading is 57/143: 71,753 fragments / 2,833,045 baseline bytes and 97 complete files. Phase0 is partial through line 22258. Unchanged canonical commit ec10be6b retains PASS for 18 completed subtests, ordinals 541–558 with 195 direct assertions, including 59 nested results. Six lifecycle loops separately verify 472 inner assertions with exact tag order, TAP numbering and plans. The last fluent outer-switch test is partial after ten of eleven assertions; .1.58 owns its final ok expression. Existing .2.10 owns uppercase code-slot comparisons; those assertions are not generated-code equivalence proof. Snapshot descriptors do not establish runtime copy isolation. No new defect, runtime execution, source repair, dependency build, canonical run or push is claimed; all prerequisites remain.

- `2026-09-21` .1.56: Ten complete windows cover 1,500 fragments / 64,289 baseline bytes; ordered window SHA-256 212809d8081a3124d296fa3477c4a77a790ef50ce94329103c5f75a4ccbc8ce1. Cumulative reading is 56/143: 70,552 fragments / 2,767,515 baseline bytes and 97 complete files. Phase0 is partial through line 21057. Unchanged canonical commit ec10be6b retains PASS for 18 completed subtests, ordinals 523–540 with 148 direct assertions, including 74 nested results. Eleven lifecycle loops separately verify 557 inner assertions, with exact tag order, TAP numbering and plans. Fresh original and changed-payload probes each pass all 48 inner assertions while twelve descriptors lack uppercase code slots; captured generated returns distinguish the payloads. Public source capture confirms ARRAY chunks and working explicit scalar capture. New .2.10 and .2.11 own both defects; prior slot-equality claims are superseded. The LX flat-list test is partial after eight of twelve assertions; .1.57 owns its suffix. No production runtime defect, source repair, dependency build, new canonical run or push is claimed.

- `2026-09-21` .1.55: Ten complete windows cover 1,500 fragments / 63,518 baseline bytes; ordered window SHA-256 0f2a18bc08cda6675d7eb1014ca0f86d1b7ab4751e5fabf8b998980ea9faf881. Cumulative reading is 55/143: 69,052 fragments / 2,703,226 baseline bytes and 97 complete files. Phase0 is partial through line 19557. Unchanged canonical commit ec10be6b retains PASS for16 completed subtests, ordinals507–522 with151 direct assertions, including56 nested subtest results. Eight seven-tag lifecycle loops separately verify448 inner assertions, with exact tag order, sequential TAP numbers and plans. Phase0/own Perl/spec identities remain unchanged. The next lifecycle test is read only through the I/LS/LE/E prefix of its cases list; .1.56 owns the remaining list, plan, fixtures and assertions. No new defect, target runtime execution, repair, dependency build, canonical run or push is claimed. Whole-gate1032 proof remains retained, and all existing repair prerequisites remain.

- `2026-09-21` .1.54: Eleven complete windows cover 1,178 fragments / 65,522 baseline bytes; ordered window SHA-256 dfbb974fc119147c1fa1ef5035b4098fd8430e1190a99a873d6e51382ff77abb. Cumulative reading is 54/143: 67,552 fragments / 2,639,708 baseline bytes and 97 complete files. Phase0 is partial through line 18057. Unchanged canonical commit ec10be6b retains PASS for 20 completed subtests, ordinals 487–506 with 227 direct assertions, including12 nested subtest results. Those12 nested plans independently pass96 inner assertions (six lifecycle tags/eight assertions in each of two loops); every TAP sequence and unchanged Phase0/own Perl/spec identity is verified. The next seven-tag lifecycle loop has fixtures and two descriptor-build assertions read per iteration, stopping at its first metadata assignment; .1.55 owns the remaining six assertions per tag. No new defect, runtime execution, repair, dependency build, canonical run or push is claimed. Whole-gate1032 proof remains retained, and all existing repair prerequisites remain.

- `2026-09-21` .1.53: Eleven complete windows cover 818 fragments / 65,478 baseline bytes; ordered window SHA-256 81bcf143f79f0bceb1342b47b28ffae9f64dec588fbb8daa76da2a9ad35d14c8. Cumulative reading is 53/143: 66,374 fragments / 2,574,186 baseline bytes and 97 complete files. Phase0 is partial through line 16879. Unchanged canonical commit ec10be6b retains PASS for 13 completed subtests, ordinals 474–486 with 224 assertions; sequential TAP numbers and unchanged Phase0/own Perl/spec identities are verified. Fresh Toolbox extraction confirms exactly two wrapped-target descriptions actually exercise bare items bindings; .2.9 owns correction while preserving the two-bare-token static-handler precedence. The lifecycle switch/case equivalence test has11 completed assertions and the final compound assertion read only through its DEFAULT predicate; .1.54 owns its suffix. Retained whole-gate proof remains1032 top-level tests, separate from fresh focused diagnosis. The malformed num_min fixture remains .2.8-owned; no runtime repair, dependency build, new canonical run or push is claimed.

- `2026-09-21` .1.52: Eleven complete windows cover 1,077 fragments / 65,180 baseline bytes; ordered window SHA-256 0cd7ac0599e5f1aaa474cb501b73cd912672f6a43f5401f814707576d3b10737. Cumulative reading is 52/143: 65,556 fragments / 2,508,708 baseline bytes and 97 complete files. Phase0 is partial through line 16061. Unchanged canonical commit ec10be6b retains PASS for 27 completed subtests, ordinals 447–473 with 129 assertions; sequential TAP numbers and unchanged Phase0/own Perl/spec identities are verified. Fresh Toolbox lowering reproduces the num_min fixture expectation but independent compilation rejects its extra closing parenthesis; removing that one authored character compiles and returns 2 for raw_name=abcd, limit=2. New .2.8 owns positive-fixture repair. The 79-assertion method-contract test has 41 complete assertions read and only the actual argument of assertion42; .1.53 owns the suffix. Retained whole-gate proof remains1032 top-level tests, separate from fresh focused diagnosis. No production repair, dependency build, new canonical run or push is claimed.

- `2026-09-21` .1.51: Eleven complete windows cover 1,353 fragments / 65,519 baseline bytes; ordered window SHA-256 8b0f53760e7cc18be9d701d37d8d7f0c56a1a7a0c93727d97ef64ea4a3f69563. Cumulative reading is 51/143: 64,479 fragments / 2,443,528 baseline bytes and 97 complete files. Phase0 is partial through line 14984. Unchanged canonical commit ec10be6b retains PASS for forty completed subtests, ordinals 407–446 with 266 assertions; sequential TAP numbers and unchanged Phase0/own Perl/spec identities are verified. Fresh four-case mark_copy diagnosis confirms original4/4 and deletion-no-op original4/4 both pass, while a seeded-zero pristine control passes4/4 and its deletion-no-op twin fails exactly assertion2 with target0 instead of undef. New .2.7 owns fixture repair; production clears the seeded target correctly. The final capture_slice_col test has its first assertion read and the second opened through the expected array; .1.52 owns the suffix. Retained whole-gate proof is1032 top-level tests, not fresh execution for this reading leaf. No runtime repair, dependency build, new full gate or push is claimed.

- `2026-09-21` .4.1: Clean 7b921a195 has notes241/58910 and changes273/58671 lines/bytes. Both archive file/manifest limits are full; next notes allowance is only72 bytes below mandatory90% rollover. Fifty exact reading commits establish bounded positive-growth maxima. Independent and extracted-production 99-record models agree on eight rollovers per history with exact reconstruction. The actual routing predicate passes187 below/equal/above and old/proposed reserve executions. Full actual-candidate-plus99-unit census is required after all proposal edits; registry, sources, repairs and historical records remain unchanged.

- `2026-09-21` .1.50: Eleven complete windows cover 782 fragments / 65,470 baseline bytes; ordered window SHA-256 519c197576d4307f13e2b7fa04bbf2d6b053a89aa3ef03d698cd9c570849a4c8. Cumulative reading is 50/143: 63,126 fragments / 2,378,009 baseline bytes and 97 complete files. Phase0 is partial through line 13631. Unchanged canonical commit 87b35665e retains PASS for thirteen completed subtests, ordinals 394–406 with 118 assertions; sequential TAP numbers and unchanged Phase0/own Perl/spec identities are verified. Fresh TOOLBOX6.2 extraction passes six lazy-load subtests with 42 assertions; exact child probes show EmitContext 0/1/1 before require/after require/after helper while each ActionIR owner goes 0/1. New .2.6 owns inaccurate EmitContext assertion descriptions. The helper-substitution test has 73 of 90 assertions read, followed by the opening of assertion 74; .1.51 owns the suffix. Historical whole-gate proof remains 1032 top-level tests; no fresh full gate, runtime repair, dependency build or push is claimed.

- `2026-09-21` .1.49: Eleven complete windows cover 994 fragments / 65,520 baseline bytes; ordered window SHA-256 d73aae559d4b4280080e5d3df87d2300a07cc2f30f85439045cde24f95689a60. Cumulative reading is 49/143: 62,344 fragments / 2,312,539 baseline bytes and 97 complete files. Phase0 is partial through line 12849. Unchanged canonical commit 87b35665e retains PASS for 29 completed subtests, ordinals 365–393 with 202 assertions; sequential TAP numbers and unchanged Phase0/own Perl/spec identities are verified. Fresh TOOLBOX6.2 extraction passes the MethodExpr test with all7 assertions both unchanged and with an inert post-parse Deps fixture load; independent cold probes observe 0/0 versus 0/1. Repair .2.5 owns the wrong-time observation. The Diagnostics lazy-load heredoc remains partial before its assertions; .1.50 owns the suffix. Targeted helper inspection at48608–48631 grants no reading credit outside this scope. Historical whole-gate proof remains 1032 top-level tests; no new full gate, runtime repair, dependency build or push is claimed.

- `2026-09-21` .1.48: Eleven complete windows cover 1,032 fragments / 65,524 baseline bytes; ordered window SHA-256 d84f1017d31b0bd33fb239a44e9da6beebddfb6e5ea680e820ef93ff495cd896. Cumulative reading is 48/143: 61,350 fragments / 2,247,019 baseline bytes and 97 complete files. Phase0 is partial through line 11855. Unchanged canonical commit 87b35665e retains PASS for 27 completed subtests, ordinals 338–364 with 313 assertions. Phase0, own Perl sources and shipped specs remain unchanged; TAP replay verifies every sequential assertion number. The compiler success-cleanup test stops after its first of eight assertions; .1.49 owns the seven remaining assertions and invocation. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.

- `2026-09-21` .1.47: Eleven complete windows cover 979 fragments / 65,510 baseline bytes; ordered window SHA-256 b46257ef9b64fa75fb31c9e49bc403bc3d5c96e59c69f3e6b13d44b040baa1a4. Cumulative reading is 47/143: 60,318 fragments / 2,181,495 baseline bytes and 97 complete files. Phase0 is partial through line 10823. Unchanged canonical commit 87b35665e retains PASS for 28 completed subtests, ordinals 310–337 with 280 assertions. Phase0, own Perl sources and shipped specs remain unchanged; TAP replay verifies every sequential assertion number. The reused-context resolution-failure test stops after eight of nine assertions; .1.48 owns its final assertion. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.

- `2026-09-21` .1.46: Eleven complete windows cover 973 fragments / 65,483 baseline bytes; ordered window SHA-256 84b8930f933767a2b8b7a091aa173d1b18171640995e77a1813f700a1ce6124d. Cumulative reading is 46/143: 59,339 fragments / 2,115,985 baseline bytes and 97 complete files. Phase0 is partial through line 9844. Unchanged canonical commit 87b35665e retains PASS for 30 completed subtests, ordinals 280–309 with 274 assertions. Phase0, own Perl sources and shipped specs remain unchanged; TAP replay verifies every sequential assertion number. The non-coderef compile callback test stops inside setup before its callback and assertions; .1.47 owns the unread suffix. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.

- `2026-09-21` .1.45: Eleven complete windows cover 1,045 fragments / 65,409 baseline bytes; ordered window SHA-256 57fa586148e84cf02124246fd1ea0621df41394f0111f36e7fa069638e3ac60c. Cumulative reading is 45/143: 58,366 fragments / 2,050,502 baseline bytes and 97 complete files. Phase0 is partial through line 8871. Unchanged canonical commit 87b35665e retains PASS for 26 completed subtests, ordinals 254–279 with 289 assertions. Phase0, own Perl sources and shipped specs remain unchanged; TAP replay verifies every sequential assertion number. The compile-entry exception test is partial after four of twelve assertions; .1.46 owns the remaining eight. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.

- `2026-09-21` .1.44: Eleven complete windows cover 1,190 fragments / 65,521 baseline bytes; ordered window SHA-256 1482c40e24c0dc3b8c8985c7a8bd3a70ae78c9f2085dbd86f727dafff9d3039a. Cumulative reading is 44/143: 57,321 fragments / 1,985,093 baseline bytes and 97 complete files. Phase0 is partial through line 7826. Unchanged canonical commit 87b35665e retains PASS for 37 completed subtests, ordinals 217–253 with 295 assertions. Phase0, own Perl sources and all shipped specs remain unchanged. TAP replay checks every assertion number, including four valid description-free ok lines. The owner-default-error test is partial after five assertions and its final fallback call; .1.45 owns the sixth assertion. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.

- `2026-09-21` .1.43: Eleven complete windows cover 1,500 fragments / 64,877 baseline bytes; ordered window SHA-256 8749a8dc08b927f83439d0e9056e12252e8206c7243c342095145adc4d72a28d. Cumulative reading is 43/143: 56,131 fragments / 1,919,572 baseline bytes and 97 complete files. Phase0 is partial through line 6636. Unchanged canonical commit 87b35665e retains PASS for 54 completed subtests, ordinals 163–216 with 311 assertions. Phase0, own Perl sources and Lispish.spec remain unchanged. The unclosed-multiline-block test is partial at its spec heredoc; .1.44 owns its invocation and all four assertions. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.

- `2026-09-21` .1.42: Eleven complete windows cover 1,397 fragments / 65,472 baseline bytes; ordered window SHA-256 a8d3e208ff956277f6f6e0ca38e9e3beab59d8c3c22b83c97132d8845352e4af. Cumulative reading is 42/143: 54,631 fragments / 1,854,695 baseline bytes and 97 complete files. Phase0 is partial through line 5136. Unchanged canonical commit 87b35665e retains PASS for 41 completed subtests, ordinals 122–162 with 353 assertions. Phase0, own Perl sources and Lispish.spec remain unchanged. The AND+ comparison is partial after both parser-build assertions and the first invocation; .1.43 owns its result assertions. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.

- `2026-09-21` .1.41: Eleven complete windows cover 1,173 fragments / 65,484 baseline bytes; ordered window SHA-256 e3f5aa84a083b491167df80df3b8e73afb6c8c14b89e69c206f02aba094241a4. Cumulative reading is 41/143: 53,234 fragments / 1,789,223 baseline bytes and 97 complete files. Phase0 is partial through line 3739. Unchanged canonical commit 87b35665e retains PASS for 42 completed subtests, ordinals 80–121 with 282 assertions. Phase0, own Perl sources and Lispish.spec remain unchanged. The missing-dot-spec-name test is partial after three of six assertions; .1.42 owns the suffix. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.

- `2026-09-21` .1.40: Eleven complete windows cover 1,040 fragments / 65,471 baseline bytes; ordered window SHA-256 3afe1dca0df301909510c1f6c86f4f5c27613121cd041c866262d2fd9acd3f44. Cumulative reading is 40/143: 52,061 fragments / 1,723,739 baseline bytes and 97 complete files. Phase0 is partial through line 2566. Unchanged canonical commit 87b35665e retains PASS for thirty completed subtests, ordinals 50–79 with 181 assertions. Phase0 and LinkedSpec-owned Perl sources remain unchanged. The ActionIR dependency-builder test is partial in fixture setup; .1.41 owns its assertions. Historical whole-gate proof remains 1032 top-level tests. No new runtime execution, runtime repair, dependency build, full CI or push is claimed; all repair prerequisites remain.

- `2026-09-21` .1.39: Eleven complete windows cover 416 fragments / 64,842 baseline bytes; ordered window SHA-256 637b617933d223c8317d6c27901ead86ed5835131a0fc2201b1422db311bae5f. Cumulative reading is 39/143: 51,021 fragments / 1,658,268 baseline bytes and 97 complete files. Phase0 is partial through line 1526. Unchanged canonical commit 87b35665e retains PASS for ten completed subtests, ordinals 40–49 with 344 assertions: the crossing facade test, shared-owner structural checks and eight inline-validation checks. All 28 inspected source targets remain byte-identical. ParserFactory validation crosses into .1.40. Historical whole-gate proof remains 1032 top-level tests; no new runtime execution, dependency build, full CI or push is claimed. All runtime repairs retain their prerequisites.

- `2026-09-21` .1.38: Eleven complete windows cover 1,067 fragments / 65,529 baseline bytes; ordered window SHA-256 f57116fee0db80f49969546da5cd033988e06b55191fc88358b7c6d6d334fd3e. Cumulative reading is 38/143: 50,605 fragments / 1,593,426 baseline bytes and 97 complete files. Phase0 is partial through line 1110. Exact unchanged canonical commit 87b35665e supplies PASS for all 38 fully read subtests (ordinals 2–39). The crossing facade error-state test remains partial; its suffix is .1.39-owned. The complete 1032-test gate remains retained historical proof, not new execution or reading credit. No new defect, runtime repair, dependency build, full CI or push is claimed; all existing repairs retain their prerequisites.

- `2026-09-21` .1.37: Fourteen complete windows cover 1,500 fragments / 63,613 baseline bytes; ordered window SHA-256 98d4de26a6f747975c45fe91277d218c6947936925d1ae233586706bef952d64. Cumulative reading is 37/143: 49,538 fragments / 1,527,897 baseline bytes and 97 complete files. Phase0 remains partial at lines 1–43. Fresh managed metadata/oracle checks pass 9 top-level tests. Unchanged integration commit 87b35665e retains native-loader (5), MCP binding/dispatch/stdio (23), admission (13) and Phase0 1032 proof. Full-target execution grants no reading credit to the unread Phase0 body. Header correction .2.4 is pending after prerequisites; helper repair .2.3 and existing runtime repairs remain open. No dependency build, new canonical run or push is claimed.

- `2026-09-21` .1.36: Eleven complete windows cover 1,500 fragments / 58,957 baseline bytes; ordered window SHA-256 071b58880845a0a7108956fb5110d4cc52fb015640fdb95b9e4d286d3e472f1f. Cumulative reading is 36/143: 48,038 fragments / 1,464,284 baseline bytes and 91 complete files. MCP admission remains partial through line 451. Fresh managed logical/map-leaves tests pass 16 top-level tests. Exact unchanged integration proof retains gap (124) and admission (13), plus the binding target within the earlier three-target MCP group (23 tests). Three bounded helper controls confirm the literal include-path defect and its mechanism; .2.3 owns implementation and independent verification after required prerequisites. No production repair, dependency build, new canonical CI or push is claimed.

- `2026-09-21` .1.35: Ten complete windows cover 1,500 fragments / 51,804 baseline bytes; ordered window SHA-256 1164b42887bab92a4ea03d85fcaf4a9dc0c6913fc7607fe21a0d66cb0a424992. Cumulative reading is 35/143, 46,538 fragments / 1,405,327 baseline bytes and 86 complete files; gap tests remain partial through line 1026. Retained exact integration commit 87b35665e proof passes generated-source (6), inspector (2) and gap (124) tests (132 total), with unchanged source identities. The old uniform-identity audit fails on the approved integration delta; its corrected recipe passes all 160 inputs/143 groups/302 ranges and six rejected snapshot mutations. No new runtime execution, native build, full CI or push is claimed for this focused reading leaf. Existing runtime repairs remain open.

- `2026-09-13` .1.34: Conformance .1.34 reads 11 complete windows, 1,500 fragments and 56,255 baseline-identical bytes. Physical reading is 34/143: 45,038 fragments, 1,353,523 bytes and 84 complete files. Five more test files are fully read; generated-source reading stops at153. Five managed Perl targets pass43 tests and three neutral contracts pass. Evidence distinguishes adapted diagnostic fixtures and in-process generated loading. The director requests a temporary clean-checkpoint pivot to BACKEND-INTEGRATION-GUIDES.0, covering all five backends; return to conformance .1.35 after that activity. Existing repairs remain open.
- `2026-09-13` .1.33: Conformance .1.33 reads 11 complete windows, 1,381 fragments and 65,521 baseline-identical bytes. Physical reading is 33/143: 43,538 fragments, 1,297,268 bytes and 79 complete files. The complete ActionIR test file is read, preserving the distinction between AST-field lowering checks and authored-syntax admission. Callable literal reading covers inert records, dynamic invocation, in-process generated execution, precedence and typed failure/restoration checks. Fresh callable target10/10 and neutral governance pass; unchanged AST23 proof is retained. Next .1.34 owns later callable tests. Existing boolean and receiver-guard defects and all other repairs remain open.
- `2026-09-13` .1.32: Conformance .1.32 reads 9 complete windows, 1,500 fragments and 55,235 baseline-identical bytes. Physical reading is 32/143: 42,157 fragments, 1,231,747 bytes and 78 complete files. All 66 CLI cases are read:2 help,20 usage,12 success,8 Unicode,4 operational failure and20 trace cases. The ActionIR test prefix distinguishes typed reads/writes, trailing blocks and control nodes, then checks if-lowering against deliberately inconsistent source text. Fresh Perl CLI default/POSIX and the complete AST test target pass within their separate scopes. Next .1.33 owns the crossing test body and continuation; all repairs remain open.
- `2026-09-13` .1.31: Conformance .1.31 reads 32 complete windows, 1,226 fragments and 65,536 baseline-identical bytes. Physical reading is 31/143: 40,657 fragments, 1,176,512 bytes and 77 complete files. Uniform binding and both write contracts are fully read, along with the CLI guide and selected exact output fixtures. Frozen mutation metadata is reconciled with later admitted owners. Neutral write/map checks and both managed Perl help cases pass. New .2.2 owns missing storage setup in the standalone guide example. The bounded reading checkpoint is named for its broader conformance scope. Next .1.32 owns later CLI manifest cases; existing repairs remain open.
- `2026-09-13` .1.30: Conformance .1.30 reads 5 complete windows, 1,500 fragments and 23,627 baseline-identical bytes. Physical reading is 30/143: 39,431 fragments, 1,110,976 bytes and 53 complete files. All 806 rule-label ranges and 9 positive/8 negative/2 distinct fixtures are read. The uniform-binding prefix specifies typed bare reads, mutation results, exact selector retirement and retained constructors. Fresh neutral binding proof passes; new .2.1 owns stale rollout guidance with repair and independent verification children. Next .1.31 owns the final fixture expectations and later contracts; runtime repairs remain open.
- `2026-09-13` .1.29: Conformance .1.29 reads 3 complete windows, 1,500 fragments and 15,123 baseline-identical bytes. Physical reading is 29/143: 37,931 fragments, 1,087,349 bytes and 52 complete files. Rule-label reading now covers 494 complete XID_Continue ranges, including Indic scripts, Hangul, compatibility forms and supplementary scalars, with every gap preserved. The next lower endpoint 10A3F remains .1.30-owned. Unchanged offline generation proof from .1.28 is retained; all runtime repairs remain open.
- `2026-09-13` .1.28: Conformance .1.28 reads 3 complete windows, 1,500 fragments and 17,109 baseline-identical bytes. Physical reading is 28/143: 36,431 fragments, 1,072,226 bytes and 52 complete files. The casing contract is fully read: 464 Case_Ignorable ranges, the separate Final Sigma rule and all 12 fixtures. The rule-label prefix fixes exact scalar identity and admits XID_Continue at every position, with 119 complete ranges read. Fresh offline rule-label regeneration passes. Next .1.29 owns the crossing 0B8E range and continuation; runtime repairs remain open.
- `2026-09-13` .1.27: Conformance .1.27 reads 3 complete windows, 1,500 fragments and 15,135 baseline-identical bytes. Physical reading is 27/143: 34,931 fragments, 1,055,117 bytes and 51 complete files. All Cased property ranges are read, followed by the first 239 complete Case_Ignorable ranges and the next lower endpoint. The separate property sets can overlap; the existing Lua audit already owns that fact and its scoped context proof. Two direct Knowledge questions improve retrieval without altering its historical evidence. The bounded checkpoint is updated in place; unchanged Unicode generation proof is retained. Next .1.28 owns the crossing A82C range and continuation; all runtime repairs remain open.
- `2026-09-13` .1.26: Conformance .1.26 reads 3 complete windows, 1,500 fragments and 14,999 baseline-identical bytes. Physical reading is 26/143: 33,431 fragments, 1,039,982 bytes and 51 complete files. Both Unicode case mapping arrays are fully read. Supplementary uppercase rows close before the initial Cased property ranges, whose classification role remains distinct from conversion sequences. The required change-history rollover preserves exact committed suffix records and unchanged capacity limits. The bounded checkpoint is updated in place; unchanged offline Unicode proof is retained. Next .1.27 owns later property ranges and all runtime repairs remain open.
- `2026-09-13` .1.25: Conformance .1.25 reads 3 complete windows, 1,500 fragments and 14,739 baseline-identical bytes. Physical reading is 25/143: 31,931 fragments, 1,024,983 bytes and 51 complete files. Uppercase reading covers further Latin and Cherokee rows, ordered Latin/Armenian ligature expansions, fullwidth pairs and supplementary scalars. Exact scalar sequences and encoded forms remain distinct. The bounded checkpoint is updated in place. Unchanged offline Unicode proof is retained. Next .1.26 owns the crossing 104F8-to-104D0 entry and continuation; all runtime repairs remain open.
- `2026-09-13` .1.24: Conformance .1.24 reads 3 complete windows, 1,500 fragments and 14,500 baseline-identical bytes. Physical reading is 24/143: 30,431 fragments, 1,010,244 bytes and 51 complete files. Uppercase reading covers numeral, circled-letter, Glagolitic, Coptic, Georgian and extended Cyrillic/Latin mappings. Sparse entries and non-adjacent targets remain explicit, including the Georgian 2Dxx family. The bounded checkpoint is updated in place. Unchanged offline Unicode proof is retained. Next .1.25 starts after the closed A74F-to-A74E entry; all runtime repairs remain open.
- `2026-09-13` .1.23: Conformance .1.23 reads 3 complete windows, 1,500 fragments and 15,108 baseline-identical bytes. Physical reading is 23/143: 28,931 fragments, 995,744 bytes and 51 complete files. Uppercase reading completes the Latin additional and Greek extended rows in this range, including ordered two- and three-scalar expansions and shared titlecase/lowercase results. It then reaches the first Roman numeral uppercase entry. The bounded checkpoint is updated in place. Unchanged offline Unicode proof is retained. Next .1.24 starts after the closed 2170-to-2160 entry; all runtime repairs remain open.
- `2026-09-13` .1.22: Conformance .1.22 reads 3 complete windows, 1,500 fragments and 14,510 baseline-identical bytes. Physical reading is 22/143: 27,431 fragments, 980,636 bytes and 51 complete files. Uppercase reading continues through Cyrillic, Armenian, Georgian, short Cherokee and further Latin rows. Armenian 0587 expands to two ordered uppercase scalars; Cyrillic variants preserve shared target values. The bounded checkpoint is updated in place. Unchanged offline Unicode proof is retained. Next .1.23 starts after the closed 1E5B-to-1E5A entry; all runtime repairs remain open.
- `2026-09-13` .1.21: Conformance .1.21 reads 3 complete windows, 1,500 fragments and 14,528 baseline-identical bytes. Physical reading is 21/143: 25,931 fragments, 966,126 bytes and 51 complete files. Uppercase reading covers further Latin, Greek and Cyrillic mappings. Titlecase/lowercase pairs converge on common uppercase values, and Greek expansions retain ordered combining scalars. The existing bounded checkpoint is updated in place. Unchanged offline Unicode proof is retained. Next .1.22 owns the newly opened entry after 045F-to-040F; all runtime repairs remain open.
- `2026-09-13` .1.20: Conformance .1.20 reads 3 complete windows, 1,500 fragments and 14,781 baseline-identical bytes. Physical reading is 20/143: 24,431 fragments, 951,598 bytes and 51 complete files. The complete lowercase mapping array is read, and uppercase reading reaches the closed 016F-to-016E entry. Uppercase expansions preserve ordered scalar sequences rather than reversing lowercase mappings. The Unicode reading card now retains one bounded current checkpoint; earlier exact evidence remains in Git and its task leaves. Unchanged offline Unicode proof is retained. Next .1.21 owns subsequent uppercase entries; all runtime repairs remain open.
- `2026-09-13` .1.19: Conformance .1.19 reads 3 complete windows, 1,500 fragments and 14,848 baseline-identical bytes. Physical reading is 19/143: 22,931 fragments, 936,817 bytes and 51 complete files. Lowercase reading covers the remaining Latin extended rows in this range, identity ligatures, fullwidth Latin pairs and supplementary scalar mappings. Sparse ranges and non-adjacent targets remain explicit. Unchanged offline Unicode proof is retained. Next .1.20 owns the crossing 10D5B entry and continuation; all runtime repairs remain open.
- `2026-09-13` .1.18: Conformance .1.18 reads 3 complete windows, 1,500 fragments and 14,500 baseline-identical bytes. Physical reading is 18/143: 21,431 fragments, 921,969 bytes and 51 complete files. Lowercase reading completes Roman numeral and circled-letter rows, then covers Glagolitic, Coptic, Cyrillic extended and further Latin mappings. Exact non-adjacent Latin results remain distinct from adjacent pairs. Unchanged offline Unicode proof is retained. Next .1.19 owns the crossing A79E entry and continuation; all runtime repairs remain open.
- `2026-09-13` .1.17: Conformance .1.17 reads 3 complete windows, 1,500 fragments and 14,500 baseline-identical bytes. Physical reading is 17/143: 19,931 fragments, 907,469 bytes and 51 complete files. Lowercase reading completes the Latin additional and Greek extended mapping families, including identity rows, titlecase convergence and non-adjacent mappings. Letterlike symbols map to their exact lowercase values; Roman numeral reading begins. Unchanged offline Unicode proof remains valid, and .1.18 owns the crossing 2160 entry and following mappings. Runtime repairs remain open.
- `2026-09-13` .1.16: Conformance .1.16 reads 3 complete windows, 1,500 fragments and 14,500 baseline-identical bytes. Physical reading is 16/143: 18,431 fragments, 892,969 bytes and 51 complete files. Lowercase reading covers Armenian, Georgian and Cherokee families, preserving sparse entries and their distinct target ranges, then continues into Latin additional mappings. Existing offline Unicode generation proof remains applicable to unchanged inputs. Next .1.17 owns the crossing 1E3E entry and following mappings; all runtime repairs remain open.
- `2026-09-13` .1.15: Conformance .1.15 reads 3 complete windows, 1,500 fragments and 14,500 baseline-identical bytes. Physical reading is 15/143: 16,931 fragments, 878,469 bytes and 51 complete files. The lowercase table continues through Latin, Greek and Cyrillic mappings, retaining exact non-adjacent mappings and the default Sigma entry. Existing Final Sigma context remains a separate rule. Unicode generation proof from clean704e261b remains valid for unchanged inputs; no behavior, native admission or runtime repair changes. Next .1.16 owns the crossing0522 mapping and continuation.
- `2026-09-13` .1.14: Conformance .1.14 reads six complete windows, 1,500 fragments and 33,332 baseline-identical bytes. The typed-source contract reaches EOF; Unicode-case reading reaches line 1138, inside the lowercase mapping table. Physical reading is 14/143: 15,431 fragments, 863,969 bytes and 51 complete files. Typed composition retains six distinct recurring authorities and all14 completed rollout rows. Unicode 17 full default conversion uses pinned offline data, Final Sigma and no locale tailoring or normalization. The casing card separates historical host probes from current generated-table verification. Focused Unicode and governed-book checks pass; all runtime repairs remain owned.
- `2026-09-13` .1.13: Conformance .1.13 reads 11 complete windows, 841 fragments and 65,510 baseline-identical bytes. Staged enrichment and standalone lifecycle contracts reach EOF; typed-source reading reaches line 452, inside public rollout assertions. Physical reading is 13/143: 13,931 fragments, 830,637 bytes and 50 complete files. Lifecycle normalization preserves authored order and earlier brace owners; typed positions, invocation state, transactions and detached recursive observations remain distinct. The typed Knowledge card explicitly qualifies its older 75-mutation narrative. Focused lifecycle/typed and governed-book checks pass without expanding native carrier evidence or closing runtime repairs.
- `2026-09-13` .1.12: Conformance .1.12 reads 11 complete windows, 1,012 fragments and 65,472 baseline-identical bytes. The semantic model reaches EOF; staged enrichment is read through line 996, inside the ownership inventory. Physical reading is 12/143: 13,090 fragments, 765,127 bytes and 48 complete files. Staged reading separates deferred declaration, caller-prepared parser selection, typed provenance, deterministic identity, breadth-first scheduling, shared bounds, isolated child state and detached stitching. Focused staged neutral/public proof passes; prior semantic proof remains scoped to unchanged inputs. No runtime, admission or dependency change; .1.13 owns the remaining ownership/public records and following contracts.
- `2026-09-13` .1.11: Conformance .1.11 reads 12 complete windows, 554 fragments and 65,425 baseline-identical bytes. The semantic-introspection contract reaches EOF; model reading reaches line 201, inside the identity-limited snapshot. Physical reading is 11/143: 12,078 fragments, 699,655 bytes and 47 complete files. The model separates duplicate slots, staged payload/job/result provenance, generated plans, compilation failure and captured runtime observation. The staged-schema card now explicitly dates its private implementation milestones and points to completed public rollout. Existing semantic neutral proof is retained and rechecked after governed documentation edits; no native admission or runtime repair is claimed.
- `2026-09-13` .1.10: Conformance .1.10 reads 18 complete windows, 789 fragments and 65,489 baseline-identical bytes. Cursor ownership, numeric/text contracts and six semantic fixture inputs reach EOF; semantic-introspection contract reading reaches line 363. Physical reading is 10/143: 11,524 fragments, 634,230 bytes and 46 complete files. Numeric 55-case/18-helper, Perl scalar-text 7-test and semantic neutral proof pass. Numeric rejection of booleans remains distinct from scalar-text conversion; paging budgets and source-detail ceilings remain explicit. No source or runtime defect changes; .1.11 owns the crossing Dart admission consumer and semantic model prefix.
- `2026-09-13` .1.9: Conformance .1.9 reads 11 complete windows, 1,445 fragments and 65,519 baseline-identical bytes. Repetition and root-selection contracts reach EOF; the cursor contract is read through line 160. Physical reading is 9/143: 10,735 fragments, 568,741 bytes and 37 complete files. Fresh repetition8/10/8-complete/54, root8/3/3/7-complete/54 and cursor36/18/8/74-files/8-complete/60 neutral proof passes. Repetition values, lifecycle exits, authored marker identity, execution selection, strict-unused edges and intrinsic child cursor policy remain distinct. Current root public24/18 and cursor public30/28 inventories reconcile their dated milestones. No source or runtime defect changes; .1.10 owns the crossing Rust cursor-role list and following scalar/semantic inputs.
- `2026-09-13` .1.8: Conformance .1.8 reads 15 complete windows, 1,500 fragments and 65,525 baseline-identical bytes. Progressive dispatch, punctuation aliases, recognition transactions and three explicit-OR fixture files reach EOF; the repetition contract is read through line 157. Physical reading is 8/143: 9,290 fragments, 503,222 bytes and 35 complete files. Fresh punctuation6/4/6 and recognition138/250/58 plus public3/26/45 proof pass. The contracts separate parent recognition progress, bounded child dispatch, strict match booleans, staged payloads and per-hit repetition returns. The older punctuation fact card now qualifies its pre-emitter Lua milestone using existing generated-source admission. All runtime repairs remain open; .1.9 owns the crossing bounded-repetition case and following contracts.
- `2026-09-13` .1.7: Conformance .1.7 reads 12 complete windows, 1,500 fragments and 60,106 baseline-identical bytes. Validator cases, transport manifest, native resolution and outward descriptors reach EOF; progressive dispatch is read through line 540. Physical reading is 7/143: 7,790 fragments, 437,697 bytes and 29 complete files. Fresh native-resolution14/9/4 and progressive9/9/116 plus public6/12/10/60 neutral checks pass. Exact paths, ordered named roots, preserved UTF-8, three outward function variants and bounded same-source child dispatch retain distinct authorities. The general descriptor fact card now explicitly qualifies its fixed-v1 field list. Existing progressive resource/nesting, MCP EOF/validation-order and other repair obligations remain open; .1.8 owns the crossing cancellation case and following contracts.
- `2026-09-13` .1.6: Conformance .1.6 reads 12 complete windows covering 1,500 fragments and 63,045 baseline-identical bytes. Canonical frames, corpus, schema and four semantic payloads reach EOF; validator cases are read through line 51. Physical reading is 6/143, cumulatively 6,290 fragments and 377,591 bytes with 25 complete files. The contract separates JSON-RPC errors, tool errors and semantic ok:false results, retains canonical text/structured identity, and bounds policy projection and query input independently. The .1.5 materializer/transport/admission results remain dated unchanged-source proof; no redundant native or dependency build runs. Existing Rust EOF and validation-order defects remain owned and open. Next .1.7 completes validator cases and continues neutral contracts.
- `2026-09-13` .1.5: Conformance .1.5 reads 11 complete source windows in 13 presentations, covering 690 fragments/65,516 baseline-identical bytes. Map-leaves and MCP admission reach EOF; canonical frames1-12 are read, including the complete14,687-byte tools-list line in three contiguous chunks. Physical reading is5/143, cumulatively4,790 fragments/314,546 bytes with21 complete files. MCP materialization matches35 frames/10 raw inputs/10 lifecycle cases; independent transport validation rejects76 mutations, and admission reports5/5 implementations plus6/6 runtimes with141 mutations. Prior mutation167+592 proof remains unchanged-source dated evidence. Receiver identity, callback atomicity and post-commit continuation remain distinct from runtime admission and transport payload identity. All existing repairs, source/history and capacity limits remain; frames13-35 and following sources belong to .1.6.
- `2026-09-13` .1.4: Conformance .1.4 reads 13 complete windows, 1,022 fragments and 65,375 baseline-identical bytes. Gap, logical-helper and capability-manifest reading reaches EOF; map-leaves reading covers only lines1-33. Physical reading is 4/143, cumulatively 4,100 fragments/249,030 bytes and 19 complete files. Logical proof passes 17 truthiness/10 helper/3 effect/26 mutation cases; capability schema v2 records 20 capabilities/100 pass states/one legacy exclusion; map-leaves neutral proof rejects 167 base plus 592 composition mutations. Frozen mutation status and later external admission remain distinct, and current logical/gap public inventories reconcile with their dated milestones. Existing source, runtime repair and capacity obligations remain. The prescribed change-history rollover preserves exact clean-HEAD suffix records; next .1.5 owns map-leaves34-461 and subsequent MCP sources.
- `2026-09-13` .1.3: Conformance .1.3 reads 19 complete windows, 1,500 fragments and 52,668 baseline-identical bytes across 13 ranges. Diagnostic, duplicate-slot, six capability fixtures, three generated fixture files and the generated-source contract are complete; gap reading stops at line 805. Physical reading is 3/143, cumulatively 3,078 fragments and 183,655 bytes with 16 complete files. Fresh structural/neutral proof passes duplicate identity 5 fixtures/59 mutations, generated roles 10 families, language coverage 250 calls/126 public contracts and gap semantics 63/public 34 mutations. Authored slot identity, independent generated execution, gap state and user effects retain separate contracts. No new defect or runtime signoff is inferred; all existing repair, source, history and capacity obligations remain. Next .1.4 owns the exact gap suffix and following contracts.
- `2026-09-13` .1.2: Conformance .1.2 reads12 complete windows/808 fragments/65,502 baseline-identical bytes: capability guide EOF, complete callable/signature/named-mark contracts and diagnostic lines1-268. Physical reading is2/143, cumulatively1,578 fragments/130,987 bytes and four complete files; diagnostic269-273 remains .1.3-owned. Current positional-only call contracts preserve the approved parked named-argument direction; mark isolation is by rule label, and diagnostics use a quiet per-invocation typed sink. Fresh named-mark and diagnostic neutral checks pass; prior unchanged callable/signature proof remains dated. Guide-suffix current17/80 claims extend existing startup .41.7, while current diagnostic metadata measures15 public documents/9 denials. Source, prior evidence, all repairs and capacity limits remain; no backend matrix, dependency build or parent closeout is claimed.
- `2026-09-13` .1.1: Conformance .1.1 reads all 11 complete windows of capability_conformance/README.md lines1-770: 770 fragments/65,485 baseline-identical bytes. Physical conformance reading is1/143; the README suffix771-897 and later contracts remain .1.2-owned. Seven focused structural/neutral checks pass, while exact current census, mutation/inventory/public-count and generic-callable claims remain stale. Existing startup .41.7 and .41.6 now own those actual paragraphs and meaningful recurrence; the marker/denial-only cause is recorded without changing source or runtime. All143 groups/302 ranges, prior source/history, six supporting repair roots and existing capacity limits remain. No fresh backend matrix, dependency build or parent closeout is claimed.
- `2026-09-13`: Startup .3.8.0 independently verifies all160 files/143 groups/302 ranges and four decoded hashes; Unicode casing and rule-label checks PASS. Source/task/history, actual capacity, memory, Knowledge, histories, rendered book and normal hooks govern planning. Physical reading remains0/143.

## Commit Log

- `2026-09-21` .1.78: `CONFORMANCE-SOURCE-READING.1.78 - read function staging and own working variable observation drift`; activation 2defd6def; .1.79 follows clean handoff and empty brief.

- `2026-09-21` .1.77: `CONFORMANCE-SOURCE-READING.1.77 - read trace and cursor tests and own missing source observation`; activation c57bd928e; .1.78 follows clean handoff and empty brief.

- `2026-09-21` .1.76: `CONFORMANCE-SOURCE-READING.1.76 - read shipped grammar runtime smokes and adapter boundaries`; activation cadf2cc0d; .1.77 follows clean handoff and empty brief.

- `2026-09-21` .1.75: `CONFORMANCE-SOURCE-READING.1.75 - read quote boundaries and shipped grammar migration checks`; activation 90235115c; .1.76 follows clean handoff and empty brief.

- `2026-09-21` .1.74: `CONFORMANCE-SOURCE-READING.1.74 - read source boundary projections and legacy classification checks`; activation 8bb0fd15c; .1.75 follows clean handoff and empty brief.

- `2026-09-21` .1.73: `CONFORMANCE-SOURCE-READING.1.73 - read switch safety and compatibility migration observations`; activation 1e74f9842; .1.74 follows clean handoff and empty brief.

- `2026-09-21` .1.72: `CONFORMANCE-SOURCE-READING.1.72 - read reducers and meaningful lifecycle source and result locks`; activation fa907be6e; .1.73 follows clean handoff and empty brief.

- `2026-09-21` .1.71: `CONFORMANCE-SOURCE-READING.1.71 - read array ordering and own assignment description drift`; activation a9b874f7b; .1.72 follows clean handoff and empty brief.

- `2026-09-21` .1.70: `CONFORMANCE-SOURCE-READING.1.70 - read hash transformations and snapshot lowering checks`; activation ff9a9b83c; .1.71 follows clean handoff and empty brief.

- `2026-09-21` .1.69: `CONFORMANCE-SOURCE-READING.1.69 - read scalar membership and reducer lowering checks`; activation e057c0336; .1.70 follows clean handoff and empty brief.

- `2026-09-21` .1.68: `CONFORMANCE-SOURCE-READING.1.68 - read fallback lowering and normalization metadata`; activation c69ece0e6; .1.69 follows clean handoff and empty brief.

- `2026-09-21` .1.67: `CONFORMANCE-SOURCE-READING.1.67 - read payload branches and captured-call descriptor comparisons`; activation b193bfa9d; .1.68 follows clean handoff and empty brief.

- `2026-09-21` .1.66: `CONFORMANCE-SOURCE-READING.1.66 - read scalar and numeric descriptor comparisons`; activation 4c25d22ac; .1.67 follows clean handoff and empty brief.

- `2026-09-21` .1.65: `CONFORMANCE-SOURCE-READING.1.65 - read fluent container helper comparisons and observation limits`; activation e0123d86e; .1.66 follows clean handoff and empty brief.

- `2026-09-21` .1.64: `CONFORMANCE-SOURCE-READING.1.64 - read mutual marker nesting and bounded helper coverage`; activation 55cb6fdf9; .1.65 follows clean handoff and empty brief.

- `2026-09-21` .1.63: `CONFORMANCE-SOURCE-READING.1.63 - read outer-family selected-node checks and comparison limits`; activation 04d32b093; .1.64 follows clean handoff and empty brief.

- `2026-09-21` .1.62: `CONFORMANCE-SOURCE-READING.1.62 - read switch outer-family comparisons and exact metadata limits`; activation 335267bf1; .1.63 follows clean handoff and empty brief.

- `2026-09-21` .1.61: `CONFORMANCE-SOURCE-READING.1.61 - read structured switch branch comparisons and preserve observation limits`; activation 618e60c86; .1.62 follows clean handoff and empty brief.

- `2026-09-21` .1.60: `CONFORMANCE-SOURCE-READING.1.60 - read multi-case switch composition and metadata coverage`; activation b196e4175; .1.61 follows clean handoff and empty brief.

- `2026-09-21` .1.59: `CONFORMANCE-SOURCE-READING.1.59 - read deep switch nesting and descriptor slot shape`; activation 67f38c76c; .1.60 follows clean handoff and empty brief.

- `2026-09-21` .1.58: `CONFORMANCE-SOURCE-READING.1.58 - read mixed switch and nested marker metadata`; activation cebbd8466; .1.59 follows clean handoff and empty brief.

- `2026-09-21` .1.57: `CONFORMANCE-SOURCE-READING.1.57 - read snapshot and bare-marker descriptor coverage`; activation 1983e2fc4; .1.58 follows clean handoff and empty brief.

- `2026-09-21` .1.56: `CONFORMANCE-SOURCE-READING.1.56 - read switch coverage and own vacuous code comparisons`; activation e258190c8; .1.57 follows clean handoff and empty brief.

- `2026-09-21` .1.55: `CONFORMANCE-SOURCE-READING.1.55 - read mixed branches and nested switch equivalence`; activation bbb20ca7c; .1.56 follows clean handoff and empty brief.

- `2026-09-21` .1.54: `CONFORMANCE-SOURCE-READING.1.54 - read structured branch and lifecycle equivalence coverage`; activation c7585a960; .1.55 follows clean handoff and empty brief.

- `2026-09-21` .1.53: `CONFORMANCE-SOURCE-READING.1.53 - read collection and branch lowering contracts`; activation 0e7552f9f; .1.54 follows clean handoff and empty brief.

- `2026-09-21` .1.52: `CONFORMANCE-SOURCE-READING.1.52 - read entry and match helpers and diagnose invalid numeric fixture`; activation b71ea10ae; .1.53 follows clean handoff and empty brief.

- `2026-09-21` .1.51: `CONFORMANCE-SOURCE-READING.1.51 - read capture boundaries and diagnose mark-copy clearing test gap`; activation ec10be6b0; .1.52 follows clean handoff and empty brief.

- `2026-09-21` .4.1: `CONFORMANCE-SOURCE-READING.4.1 - propose finite remaining-reading evidence capacity`; activation 7b921a195; approval remains pending under .4.2.

- `2026-09-21` .1.50: `CONFORMANCE-SOURCE-READING.1.50 - read ActionIR lazy-loading and capture lowering tests`; activation d70f77f4d; .1.51 follows clean handoff and empty brief.

- `2026-09-21` .1.49: `CONFORMANCE-SOURCE-READING.1.49 - read compiler owner paths and diagnose lazy-load test blind spot`; activation 7a166581c; .1.50 follows clean handoff and empty brief.

- `2026-09-21` .1.48: `CONFORMANCE-SOURCE-READING.1.48 - read public diagnostic propagation and handler lifecycle contracts`; activation 0a8c217a1; .1.49 follows clean handoff and empty brief.

- `2026-09-21` .1.47: `CONFORMANCE-SOURCE-READING.1.47 - read mode-result validation and runtime-context reuse contracts`; activation 3e0468533; .1.48 follows clean handoff and empty brief.

- `2026-09-21` .1.46: `CONFORMANCE-SOURCE-READING.1.46 - read compiler-state composition and parser-factory error contracts`; activation 38997866e; .1.47 follows clean handoff and empty brief.

- `2026-09-21` .1.45: `CONFORMANCE-SOURCE-READING.1.45 - read context preparation and compiler failure attribution`; activation f4a9ea296; .1.46 follows clean handoff and empty brief.

- `2026-09-21` .1.44: `CONFORMANCE-SOURCE-READING.1.44 - read validation compiler and runtime-context contracts`; activation cc3a8591f; .1.45 follows clean handoff and empty brief.

- `2026-09-21` .1.43: `CONFORMANCE-SOURCE-READING.1.43 - read bounded AND and paragraph validation contracts`; activation 6c5dc205a; .1.44 follows clean handoff and empty brief.

- `2026-09-21` .1.42: `CONFORMANCE-SOURCE-READING.1.42 - read Perl resolution errors and rule-family contracts`; activation 83f86d57c; .1.43 follows clean handoff and empty brief.

- `2026-09-21` .1.41: `CONFORMANCE-SOURCE-READING.1.41 - read Perl plugin compatibility and spec lookup tests`; activation 8eff21340; .1.42 follows clean handoff and empty brief.

- `2026-09-21` .1.40: `CONFORMANCE-SOURCE-READING.1.40 - read Perl wrapper and dependency-map contracts`; activation cea5e399b; .1.41 follows clean handoff and empty brief.

- `2026-09-21` .1.39: `CONFORMANCE-SOURCE-READING.1.39 - read Perl owner dispatch structural contracts`; activation fc5fad04f; .1.40 follows clean handoff and empty brief.

- `2026-09-21` .1.38: `CONFORMANCE-SOURCE-READING.1.38 - read Phase0 lazy-loading and plugin contracts`; activation a1c65b959; .1.39 follows clean handoff and empty brief.

- `2026-09-21` .1.37: `CONFORMANCE-SOURCE-READING.1.37 - read MCP and loader tests and own header correction`; activation 22e0b2d46; next .1.38 after clean handoff and empty brief.

- `2026-09-21` .1.36: `CONFORMANCE-SOURCE-READING.1.36 - read Perl contracts and own helper path repair`; activation bd4ffa4ca; .1.37 follows clean handoff and empty brief.

- `2026-09-21` .1.35: `CONFORMANCE-SOURCE-READING.1.35 - read generated and gap consumers and reconcile source delta`; activation 87b35665e; next .1.36 after clean handoff and zero-byte brief.

- `2026-09-13` .1.34: `CONFORMANCE-SOURCE-READING.1.34 - read Perl conformance consumers and schedule integration guides`; activation d10305097eb502c0fe29309ec230437396e26d82; next .1.35 after clean handoff and zero-byte brief.
- `2026-09-13` .1.33: `CONFORMANCE-SOURCE-READING.1.33 - complete AST lowering tests and read callable literal coverage`; activation 3d633f3b650aec95a283d36cc494cae076d41c6c; next .1.34 after clean handoff and zero-byte brief.
- `2026-09-13` .1.32: `CONFORMANCE-SOURCE-READING.1.32 - complete CLI manifest and read ActionIR parser tests`; activation 62f79df1aa84da1c7c1c5dea01c78a73508c305c; next .1.33 after clean handoff and zero-byte brief.
- `2026-09-13` .1.31: `CONFORMANCE-SOURCE-READING.1.31 - read write composition and CLI fixture contracts`; activation 74ecae96ebe59e4d40856ea62ee6ba2f73eea4ff; next .1.32 after clean handoff and zero-byte brief.
- `2026-09-13` .1.30: `CONFORMANCE-SOURCE-READING.1.30 - complete rule-label data and read uniform-binding contract`; activation 1fe980f972a650b77e7f1e55e18da67e4f12a8f5; next .1.31 after clean handoff and zero-byte brief.
- `2026-09-13` .1.29: `CONFORMANCE-SOURCE-READING.1.29 - read rule-label ranges through supplementary scripts`; activation ddbdbbc9a442d48ea150224d4ae45bfa1303b6cb; next .1.30 after clean handoff and zero-byte brief.
- `2026-09-13` .1.28: `CONFORMANCE-SOURCE-READING.1.28 - complete casing contract and read rule-label policy`; activation 7f0d7ffd3b40c0fed3f24088750e69f32615e30f; next .1.29 after clean handoff and zero-byte brief.
- `2026-09-13` .1.27: `CONFORMANCE-SOURCE-READING.1.27 - complete Cased ranges and read Case Ignorable prefix`; activation 0660046fb9b9afdc2f6e8266c404139f261763b8; next .1.28 after clean handoff and zero-byte brief.
- `2026-09-13` .1.26: `CONFORMANCE-SOURCE-READING.1.26 - complete case mapping arrays and begin property ranges`; activation 38c45c2883d9932f38ec4a511130c1f5bd94de1b; next .1.27 after clean handoff and zero-byte brief.
- `2026-09-13` .1.25: `CONFORMANCE-SOURCE-READING.1.25 - read Cherokee ligature and supplementary uppercase mappings`; activation 66c75ec5c83c00880cfaed4bb7ca4921b003a1a6; next .1.26 after clean handoff and zero-byte brief.
- `2026-09-13` .1.24: `CONFORMANCE-SOURCE-READING.1.24 - read numeral circled and extended uppercase mappings`; activation a4c9bd63e5127bff0b92d49dfd4bfdad15b04ebd; next .1.25 after clean handoff and zero-byte brief.
- `2026-09-13` .1.23: `CONFORMANCE-SOURCE-READING.1.23 - read Latin and Greek full uppercase expansions`; activation f1c84738402881b281a897f33eb001c8c0111b3f; next .1.24 after clean handoff and zero-byte brief.
- `2026-09-13` .1.22: `CONFORMANCE-SOURCE-READING.1.22 - read Cyrillic Armenian and Georgian uppercase mappings`; activation 5a2d859875a8f2993a1de630aacdf5374e15f53d; next .1.23 after clean handoff and zero-byte brief.
- `2026-09-13` .1.21: `CONFORMANCE-SOURCE-READING.1.21 - read Latin Greek and Cyrillic uppercase mappings`; activation 93e5b62c4b6df38fb2812db47a52e05d20a91f7e; next .1.22 after clean handoff and zero-byte brief.
- `2026-09-13` .1.20: `CONFORMANCE-SOURCE-READING.1.20 - complete lowercase array and read uppercase prefix`; activation 978ed9f903dee68026a35ce5885035dc9bc0541d; next .1.21 after clean handoff and zero-byte brief.
- `2026-09-13` .1.19: `CONFORMANCE-SOURCE-READING.1.19 - read fullwidth and supplementary lowercase mappings`; activation bc85702ad289269970310852645ddfce35c9eecd; next .1.20 after clean handoff and zero-byte brief.
- `2026-09-13` .1.18: `CONFORMANCE-SOURCE-READING.1.18 - read numeral circled and extended lowercase mappings`; activation 90067fbfea184b29a1f5c936a5fc99df9b8d7419; next .1.19 after clean handoff and zero-byte brief.
- `2026-09-13` .1.17: `CONFORMANCE-SOURCE-READING.1.17 - read Latin and Greek extended lowercase mappings`; activation e2ef71ff62406dcc82b35840e3b1d8ebc71a22fe; next .1.18 after clean handoff and zero-byte brief.
- `2026-09-13` .1.16: `CONFORMANCE-SOURCE-READING.1.16 - read Armenian Georgian and Cherokee lowercase mappings`; activation d7daa22753c1a6065d26bcfaeefdb776aaabd5f8; next .1.17 after clean handoff and zero-byte brief.
- `2026-09-13` .1.15: `CONFORMANCE-SOURCE-READING.1.15 - read Unicode Latin Greek and Cyrillic lowercase mappings`; activation 704e261b9032d121e6ffa2d7402c648ac5e2f2ab; next .1.16 after clean handoff and zero-byte brief.
- `2026-09-13` .1.14: `CONFORMANCE-SOURCE-READING.1.14 - read typed closeout and Unicode case prefix`; activation 6bc8f569ce36642381b3cd25451ac059e1c43113; next .1.15 after clean handoff and zero-byte brief.
- `2026-09-13` .1.13: `CONFORMANCE-SOURCE-READING.1.13 - read lifecycle normalization and typed source boundaries`; activation a7b6ba42d639c970420fd14bf9ac03823e4b2571; next .1.14 after clean handoff and zero-byte brief.
- `2026-09-13` .1.12: `CONFORMANCE-SOURCE-READING.1.12 - read staged enrichment scheduling and policy boundaries`; activation abdfb235ff8cc15829af187d4dd26b9972b684e6; next .1.13 after clean handoff and zero-byte brief.
- `2026-09-13` .1.11: `CONFORMANCE-SOURCE-READING.1.11 - read semantic rollout and model identities`; activation 388f09aec9b7fe4c71362bae29a3f9b39b78259b; next .1.12 after clean handoff and zero-byte brief.
- `2026-09-13` .1.10: `CONFORMANCE-SOURCE-READING.1.10 - read scalar contracts and semantic query prefix`; activation d4ea5c63d7d87b7b113c9ebac846b58ab700654f; next .1.11 after clean handoff and zero-byte brief.
- `2026-09-13` .1.9: `CONFORMANCE-SOURCE-READING.1.9 - read repetition root selection and cursor ownership`; activation 445764d606459a8ff43ecb4c985b0a189593d3b3; next .1.10 after clean handoff and zero-byte brief.
- `2026-09-13` .1.8: `CONFORMANCE-SOURCE-READING.1.8 - read progressive recognition and repetition boundaries`; activation 708ecbff2b1741c666f4399986270f002b8a6162; next .1.9 after clean handoff and zero-byte brief.
- `2026-09-13` .1.7: `CONFORMANCE-SOURCE-READING.1.7 - read resolution descriptor and progressive dispatch contracts`; activation 421f22390a01faf444454f54951816be099f576c; next .1.8 after clean handoff and zero-byte brief.
- `2026-09-13` .1.6: `CONFORMANCE-SOURCE-READING.1.6 - complete transport corpus schema and semantic payload reading`; activation cc278a5c692aa7da1004d51a1d7a7bcc19c3dade; next .1.7 after clean handoff and zero-byte brief.
- `2026-09-13` .1.5: `CONFORMANCE-SOURCE-READING.1.5 - read mutation and MCP admission with complete transport chunks`; activation 24d3b9347d30254d4e3e2bc1a7b1df238aa3cad5; next .1.6 after clean handoff and zero-byte brief.
- `2026-09-13` .1.4: `CONFORMANCE-SOURCE-READING.1.4 - read gap logical and capability authorities with frozen mutation prefix`; activation baaebc8ef62baf84447767c2b361458c3ac57d9e; next .1.5 after clean handoff and zero-byte brief.
- `2026-09-13` .1.3: `CONFORMANCE-SOURCE-READING.1.3 - read slot identity fixtures generated roles and gap prefix`; activation 51c7ea8fe89e4f96b5927ec02bc5b629d33d8986; next .1.4 after clean handoff and zero-byte brief.
- `2026-09-13` .1.2: `CONFORMANCE-SOURCE-READING.1.2 - complete guide and read callable mark and diagnostic contracts`; activation 724185e83987bcd7597dae3840efd23af352859f; next .1.3 after clean handoff and zero-byte brief.
- `2026-09-13` .1.1: `CONFORMANCE-SOURCE-READING.1.1 - read capability guide prefix and own stale current claims`; activation d3cfa5973beed85de5ae58dc81798262cafe18ad; next .1.2 after clean handoff and zero-byte brief.
- `2026-09-13`: Decomposition lands under `SESSION-STARTUP-READING.3.8.0`; Git owns the resulting commit identity.

## Changelog

- `2026-09-21` .1.78: Function staging, runtime values and recursion checks retain bounded claims; new .2.14 owns working-variable observation and description drift.

- `2026-09-21` .1.77: Trace and runtime cursor observations remain distinct from descriptor equality; new .2.13 owns the reproduced negative-only source check.

- `2026-09-21` .1.76: Grammar metadata and source checks remain distinct from bounded parser results and legacy Perl adapter execution.

- `2026-09-21` .1.75: Read quote-aware statement boundaries and shipped grammar migration checks; distinguish metadata/source observations from the exact regdef runtime result.

- `2026-09-21` .1.74: Read typed source-boundary projections and legacy classification checks; preserve the difference between observed lowering text and executed state transitions.

- `2026-09-21` .1.73: Read switch/loop controls, semicolonless metadata and compatibility migration observations; preserve runtime, metadata and descriptor-slot boundaries.

- `2026-09-21` .1.72: Read numeric reducers, flat-list/typed transforms and bounded conditional/lifecycle source and runtime locks; preserve distinct observation and repair boundaries.

- `2026-09-21` .1.71: Read array ordering/concatenation and numeric reduction expectations; own four stale scalar-assignment descriptions under .2.12 with public execution proof.

- `2026-09-21` .1.70: Read hash lookup, merge, snapshots and key-transform expectations; distinguish lowering observations from executed isolation and mutation behavior.

- `2026-09-21` .1.69: Read scalar membership, replacement, boundaries, concatenation, index and reducer expectations; distinguish textual lowering from evaluated target results.

- `2026-09-21` .1.68: Read normalization descriptors and direct fallback/definedness/emptiness lowering assertions; preserve the boundary between textual lowering and target execution.

- `2026-09-21` .1.67: Read numeric/drop helpers, payload branches and captured calls; distinguish descriptor coverage from executed branches and values.

- `2026-09-21` .1.66: Read fluent/structured scalar and numeric helper descriptors; keep metadata checks distinct from evaluated helper results.

- `2026-09-21` .1.65: Read fluent/structured snapshot branches and container helper descriptors; keep node observations distinct from execution proof.

- `2026-09-21` .1.64: Read same-family nested switch comparisons and deep mutual marker fixtures; distinguish minimum helper-hit and node-presence checks from execution proof.

- `2026-09-21` .1.63: Read outer-family switch comparisons; distinguish selected marker-node presence from complete node-list equality and retain .2.10 observation limits.

- `2026-09-21` .1.62: Read same-family and cross-family switch branch comparisons; distinguish node coverage from hit-count equality and retain .2.10 observation limits.

- `2026-09-21` .1.61: Read structured/list/attached switch branches and deeper marker nesting. Preserve metadata proof and existing .2.10 ownership of code-output-labelled slot comparisons.

- `2026-09-21` .1.60: Read multi-case switch composition with and without intervening if/elseif branches. Preserve exact metadata and explicit slot-shape limits; all prior repairs remain.

- `2026-09-21` .1.59: Read deeper nested if/elseif switches with inline/marker and multi-case branches. Keep explicit slot-shape and metadata proof bounded; all prior repairs remain.

- `2026-09-21` .1.58: Read mixed attached/plain switch branches and nested marker/composite flow. Distinguish explicit current-slot shape checks from .2.10-owned equivalence claims; no new repair or target execution.

- `2026-09-21` .1.57: Read snapshots, optional semicolons, bare marker chains and attached switch forms. Preserve .2.10 ownership and the correction that absent-slot equality is not emitted-code proof; no new repair or runtime claim.

- `2026-09-21` .1.56: Read nested switch/lifecycle and flat-list coverage. Own absent-code-slot equality and invalid scalar source-capture recipes; correct current interpretation while preserving historical reading and test results.

- `2026-09-21` .1.55: Read mixed branch carriers and nested marker/inline switch equivalence, with eight seven-tag nested plans verified separately. Preserve all earlier repairs and runtime evidence boundaries.

- `2026-09-21` .1.54: Read action/LX branch forms and six-tag lifecycle equivalence loops; preserve code/metadata versus runtime boundaries, exact nested TAP proof and all earlier repairs.

- `2026-09-21` .1.53: Read collection/push/structured-return and branch equivalence coverage; own two stale wrapped-target descriptions under .2.9 and preserve .2.8 and all earlier repairs.

- `2026-09-21` .1.52: Read entry/local-match projections and stable marks; own the invalid num_min positive fixture under .2.8 with independent compilation evidence. Preserve all earlier repairs.

- `2026-09-21` .1.51: Read capture and named-mark execution, preserve generated-text evidence boundaries and own the confirmed clearing-observation gap under .2.7; earlier repairs remain open.

- `2026-09-21` .4.1: Own and quantify finite remaining-reading evidence capacity without applying any control or changing source-reading credit.

- `2026-09-21` .1.50: Read ActionIR owner loading and partial capture/mark lowering checks; own the six inaccurate bridge-load assertion descriptions under .2.6 and preserve .2.5 and all prerequisites.

- `2026-09-21` .1.49: Read compiler owner/state and ActionIR bridge controls; root-cause the wrong-time Deps observation and own repair .2.5 while preserving all prerequisites.

- `2026-09-21` .1.48: Read public diagnostic propagation, handler invocation and compile-once controls; preserve the partial success-cleanup test and all repair prerequisites.

- `2026-09-21` .1.47: Read single-mode result validation, preserved error ownership and context reuse; keep combined-mode repair and the partial resolution-failure test open.

- `2026-09-21` .1.46: Read compiler-state composition and parser-factory error contracts; preserve the partial non-coderef callback case and all repair prerequisites.

- `2026-09-21` .1.45: Read owner-specific context preparation and compiler failure attribution; preserve the partial compile-entry exception case and all repair prerequisites.

- `2026-09-21` .1.44: Read validation, typed marker lowering, compiler boundary failures and runtime-context identity; preserve all repair prerequisites.

- `2026-09-21` .1.43: Read bounded AND, paragraph normalization and validation boundaries; qualify the superseded global cursor-axis card and preserve all repair prerequisites.

- `2026-09-21` .1.42: Read resolution/runtime errors, descriptor families and bounded execution; preserve the partial AND+ comparison and repair prerequisites.

- `2026-09-21` .1.41: Read plugin compatibility and spec lookup tests; preserve the partial path diagnostic case and all repair prerequisites.

- `2026-09-21` .1.40: Read source-shape, wrapper and owner-map contracts; keep substituted behavior and unread dependency-builder assertions distinct.

- `2026-09-21` .1.39: Complete facade and owner-dispatch structural reading, correct the canonical card count and preserve all repair ownership.

- `2026-09-21` .1.38: Read Phase0 lazy-loading, statement-splitting and plugin contracts; preserve the crossing facade assertions and all prior repair ownership.

- `2026-09-21` .1.37: Complete six more source files, begin Phase0 imports and own stale header correction .2.4.

- `2026-09-21` .1.36: Complete five more source files, read MCP admission through line 451, and own the exported helper include-path repair under .2.3.

- `2026-09-21` .1.35: Complete generated/inspector source reading, read gap consumer 1–1026, and repair baseline/current audit separation for the approved 113-byte integration delta.

- `2026-09-13` .1.34: Five more test files are fully read; generated-source reading stops at153. Five managed Perl targets pass43 tests and three neutral contracts pass. Evidence distinguishes adapted diagnostic fixtures and in-process generated loading. The director requests a temporary clean-checkpoint pivot to BACKEND-INTEGRATION-GUIDES.0, covering all five backends; return to conformance .1.35 after that activity. Existing repairs remain open.
- `2026-09-13` .1.33: The complete ActionIR test file is read, preserving the distinction between AST-field lowering checks and authored-syntax admission. Callable literal reading covers inert records, dynamic invocation, in-process generated execution, precedence and typed failure/restoration checks. Fresh callable target10/10 and neutral governance pass; unchanged AST23 proof is retained. Next .1.34 owns later callable tests. Existing boolean and receiver-guard defects and all other repairs remain open.
- `2026-09-13` .1.32: All 66 CLI cases are read:2 help,20 usage,12 success,8 Unicode,4 operational failure and20 trace cases. The ActionIR test prefix distinguishes typed reads/writes, trailing blocks and control nodes, then checks if-lowering against deliberately inconsistent source text. Fresh Perl CLI default/POSIX and the complete AST test target pass within their separate scopes. Next .1.33 owns the crossing test body and continuation; all repairs remain open.
- `2026-09-13` .1.31: Uniform binding and both write contracts are fully read, along with the CLI guide and selected exact output fixtures. Frozen mutation metadata is reconciled with later admitted owners. Neutral write/map checks and both managed Perl help cases pass. New .2.2 owns missing storage setup in the standalone guide example. The bounded reading checkpoint is named for its broader conformance scope. Next .1.32 owns later CLI manifest cases; existing repairs remain open.
- `2026-09-13` .1.30: All 806 rule-label ranges and 9 positive/8 negative/2 distinct fixtures are read. The uniform-binding prefix specifies typed bare reads, mutation results, exact selector retirement and retained constructors. Fresh neutral binding proof passes; new .2.1 owns stale rollout guidance with repair and independent verification children. Next .1.31 owns the final fixture expectations and later contracts; runtime repairs remain open.
- `2026-09-13` .1.29: Rule-label reading now covers 494 complete XID_Continue ranges, including Indic scripts, Hangul, compatibility forms and supplementary scalars, with every gap preserved. The next lower endpoint 10A3F remains .1.30-owned. Unchanged offline generation proof from .1.28 is retained; all runtime repairs remain open.
- `2026-09-13` .1.28: The casing contract is fully read: 464 Case_Ignorable ranges, the separate Final Sigma rule and all 12 fixtures. The rule-label prefix fixes exact scalar identity and admits XID_Continue at every position, with 119 complete ranges read. Fresh offline rule-label regeneration passes. Next .1.29 owns the crossing 0B8E range and continuation; runtime repairs remain open.
- `2026-09-13` .1.27: All Cased property ranges are read, followed by the first 239 complete Case_Ignorable ranges and the next lower endpoint. The separate property sets can overlap; the existing Lua audit already owns that fact and its scoped context proof. Two direct Knowledge questions improve retrieval without altering its historical evidence. The bounded checkpoint is updated in place; unchanged Unicode generation proof is retained. Next .1.28 owns the crossing A82C range and continuation; all runtime repairs remain open.
- `2026-09-13` .1.26: Both Unicode case mapping arrays are fully read. Supplementary uppercase rows close before the initial Cased property ranges, whose classification role remains distinct from conversion sequences. The required change-history rollover preserves exact committed suffix records and unchanged capacity limits. The bounded checkpoint is updated in place; unchanged offline Unicode proof is retained. Next .1.27 owns later property ranges and all runtime repairs remain open.
- `2026-09-13` .1.25: Uppercase reading covers further Latin and Cherokee rows, ordered Latin/Armenian ligature expansions, fullwidth pairs and supplementary scalars. Exact scalar sequences and encoded forms remain distinct. The bounded checkpoint is updated in place. Unchanged offline Unicode proof is retained. Next .1.26 owns the crossing 104F8-to-104D0 entry and continuation; all runtime repairs remain open.
- `2026-09-13` .1.24: Uppercase reading covers numeral, circled-letter, Glagolitic, Coptic, Georgian and extended Cyrillic/Latin mappings. Sparse entries and non-adjacent targets remain explicit, including the Georgian 2Dxx family. The bounded checkpoint is updated in place. Unchanged offline Unicode proof is retained. Next .1.25 starts after the closed A74F-to-A74E entry; all runtime repairs remain open.
- `2026-09-13` .1.23: Uppercase reading completes the Latin additional and Greek extended rows in this range, including ordered two- and three-scalar expansions and shared titlecase/lowercase results. It then reaches the first Roman numeral uppercase entry. The bounded checkpoint is updated in place. Unchanged offline Unicode proof is retained. Next .1.24 starts after the closed 2170-to-2160 entry; all runtime repairs remain open.
- `2026-09-13` .1.22: Uppercase reading continues through Cyrillic, Armenian, Georgian, short Cherokee and further Latin rows. Armenian 0587 expands to two ordered uppercase scalars; Cyrillic variants preserve shared target values. The bounded checkpoint is updated in place. Unchanged offline Unicode proof is retained. Next .1.23 starts after the closed 1E5B-to-1E5A entry; all runtime repairs remain open.
- `2026-09-13` .1.21: Uppercase reading covers further Latin, Greek and Cyrillic mappings. Titlecase/lowercase pairs converge on common uppercase values, and Greek expansions retain ordered combining scalars. The existing bounded checkpoint is updated in place. Unchanged offline Unicode proof is retained. Next .1.22 owns the newly opened entry after 045F-to-040F; all runtime repairs remain open.
- `2026-09-13` .1.20: The complete lowercase mapping array is read, and uppercase reading reaches the closed 016F-to-016E entry. Uppercase expansions preserve ordered scalar sequences rather than reversing lowercase mappings. The Unicode reading card now retains one bounded current checkpoint; earlier exact evidence remains in Git and its task leaves. Unchanged offline Unicode proof is retained. Next .1.21 owns subsequent uppercase entries; all runtime repairs remain open.
- `2026-09-13` .1.19: Lowercase reading covers the remaining Latin extended rows in this range, identity ligatures, fullwidth Latin pairs and supplementary scalar mappings. Sparse ranges and non-adjacent targets remain explicit. Unchanged offline Unicode proof is retained. Next .1.20 owns the crossing 10D5B entry and continuation; all runtime repairs remain open.
- `2026-09-13` .1.18: Lowercase reading completes Roman numeral and circled-letter rows, then covers Glagolitic, Coptic, Cyrillic extended and further Latin mappings. Exact non-adjacent Latin results remain distinct from adjacent pairs. Unchanged offline Unicode proof is retained. Next .1.19 owns the crossing A79E entry and continuation; all runtime repairs remain open.
- `2026-09-13` .1.17: Lowercase reading completes the Latin additional and Greek extended mapping families, including identity rows, titlecase convergence and non-adjacent mappings. Letterlike symbols map to their exact lowercase values; Roman numeral reading begins. Unchanged offline Unicode proof remains valid, and .1.18 owns the crossing 2160 entry and following mappings. Runtime repairs remain open.
- `2026-09-13` .1.16: Lowercase reading covers Armenian, Georgian and Cherokee families, preserving sparse entries and their distinct target ranges, then continues into Latin additional mappings. Existing offline Unicode generation proof remains applicable to unchanged inputs. Next .1.17 owns the crossing 1E3E entry and following mappings; all runtime repairs remain open.
- `2026-09-13` .1.15: The lowercase table continues through Latin, Greek and Cyrillic mappings, retaining exact non-adjacent mappings and the default Sigma entry. Existing Final Sigma context remains a separate rule. Unicode generation proof from clean704e261b remains valid for unchanged inputs; no behavior, native admission or runtime repair changes. Next .1.16 owns the crossing0522 mapping and continuation.
- `2026-09-13` .1.14: Complete typed composition and read Unicode metadata/lowercase prefix. Preserve historical host probes while pointing current casing verification to the generated-table checker; all later ranges and runtime repairs remain owned.
- `2026-09-13` .1.13: Complete staged and lifecycle contract reading; qualify dated typed-envelope milestones and preserve exact consumer proof limits. Typed public assertions and all repairs remain owned.
- `2026-09-13` .1.12: Complete semantic model and staged scheduling/policy reading. Preserve narrow-v1 compatibility, all existing runtime repairs and remaining ownership/public-contract reading.
- `2026-09-13` .1.11: Complete semantic rollout reading and five model snapshots; qualify dated private-projection milestones. Keep the identity-limited suffix, history controls and all repairs owned.
- `2026-09-13` .1.10: Complete cursor/scalar and semantic fixture reading; read semantic schema/query prefix without changing source, historical evidence or repair state.
- `2026-09-13` .1.9: Complete repetition/root-selection reading and cursor prefix; reconcile current public inventories without changing source, authority, historical evidence or repair state.
- `2026-09-13` .1.8: Complete progressive, punctuation, recognition and repetition fixtures; qualify the dated no-emitter projection through existing Lua admission. Repetition suffix and all runtime repairs remain owned.
- `2026-09-13` .1.7: Complete validator/transport/native-resolution/outward sources; qualify the fixed-v1 fact-card list against the existing three-variant union. Progressive cancellation continues in .1.8; all repairs remain.
- `2026-09-13` .1.6: Complete transport frames, corpus, schema and semantic payloads; preserve all previous source, reading and repair evidence. Validator suffix remains .1.7-owned.
- `2026-09-13` .1.5: Complete mutation/MCP admission and twelve canonical frames, with independently replayable full long-line chunks; all repairs and later source scopes remain.
- `2026-09-13` .1.4: Complete gap/logical/manifest sources and frozen mutation prefix; retain all existing repairs and apply the required exact history rollover.
- `2026-09-13` .1.3: Complete diagnostic/duplicate-slot/fixtures/generated-source reading and gap prefix; preserve all prior findings and the exact unread suffix.
- `2026-09-13` .1.2: Complete guide and three contract files; preserve the diagnostic suffix boundary, current metadata and all existing repair ownership.
- `2026-09-13` .1.1: Complete the first11 guide windows; retain clear suffix ownership and concrete repair acceptance for current-claim drift.
- `2026-09-13`: Own every conformance/test/Unicode range before reading; preserve all existing source, history, repair and capacity obligations.
