# CONFORMANCE-SOURCE-READING: Neutral contracts, regression tests and Unicode sources

## Metadata

- Tree ID: `CONFORMANCE-SOURCE-READING`
- Status: `active` / exact decomposition; physical reading 1/143
- Roadmap lane: `Session required reading / SESSION-STARTUP-READING.3.8`
- Created: `2026-09-13`
- Last updated: `2026-09-13`
- Owner: repo-local workflow
- Decomposition owner: `SESSION-STARTUP-READING.3.8.0`

## Goal

Read and understand the complete current conformance/test/Unicode source lane.
Keep source comprehension, actual runtime proof and defect repair status distinct.

## Scope and acceptance

- Baseline: `baeb984e36a94a15951cd23d4c52def5064cdaca`; clean planning activation `9833430954c3999769045abbcaa4d20389a7af4c`.
- Exact ordered selectors: `capability_conformance/`, `cli_conformance/`, `t/`, `tests/`, `unicode_case/`.
- All160 baseline/current modes, blobs and paths match;5,422,313 stored bytes decode to8,257,059 UTF-8 bytes,167,604 LF delimiters and167,606 line fragments. No empty or binary decoded input.
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
  Children: `.1`, `.2`, `.3`

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
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 2.
  Scope: `capability_conformance/README.md` lines 771-897; `capability_conformance/callable_codeblock_contract.json` lines 1-237; `capability_conformance/callable_signature_contract.json` lines 1-125; `capability_conformance/complete_named_mark_contract.json` lines 1-51; `capability_conformance/diagnostic_output_contract.json` lines 1-268
  Baseline evidence: 808 fragments / 65502 decoded bytes; ordered range SHA-256 `57a805392c2ad3942b7e69818bd3389acd38f5fdf6d73c225f2d094b14377cc4`.
  Dependencies: .1.1 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.3`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 3.
  Scope: `capability_conformance/diagnostic_output_contract.json` lines 269-273; `capability_conformance/duplicate_regex_slot_identity_contract.json` lines 1-280; `capability_conformance/fixtures/capability_capture_anonymous_surface.spec` lines 1-51; `capability_conformance/fixtures/capability_capture_named_surface.spec` lines 1-61; `capability_conformance/fixtures/capability_control_marker_surface.spec` lines 1-26; `capability_conformance/fixtures/capability_cursor_control_surface.spec` lines 1-24; `capability_conformance/fixtures/capability_position_helper_surface.spec` lines 1-41; `capability_conformance/fixtures/capability_pure_helper_surface.spec` lines 1-38; `capability_conformance/generated_source/fixtures/default_action_result_trace_identity/expected.json` lines 1-1; `capability_conformance/generated_source/fixtures/default_action_result_trace_identity/input.spec` lines 1-5; `capability_conformance/generated_source/fixtures/default_action_result_trace_identity/input.txt` lines 1-1; `capability_conformance/generated_source_contract.json` lines 1-162; `capability_conformance/inter_match_gap_capture_contract.json` lines 1-805
  Baseline evidence: 1500 fragments / 52668 decoded bytes; ordered range SHA-256 `b50f26b02c97ce5b04829dc991161454d9cf979b990caae89fa249ed3ecb2f08`.
  Dependencies: .1.2 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.4`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 4.
  Scope: `capability_conformance/inter_match_gap_capture_contract.json` lines 806-1213; `capability_conformance/logical_helper_contract.json` lines 1-303; `capability_conformance/manifest.json` lines 1-278; `capability_conformance/map_leaves_mutation_contract.json` lines 1-33
  Baseline evidence: 1022 fragments / 65375 decoded bytes; ordered range SHA-256 `5be3f9bc37cea2f28b36f750b93cf0b640df9cdb2187bc8078d9d25598a0b62d`.
  Dependencies: .1.3 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.5`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 5.
  Scope: `capability_conformance/map_leaves_mutation_contract.json` lines 34-461; `capability_conformance/mcp_implementation_admission.json` lines 1-250; `capability_conformance/mcp_semantic_transport/canonical_frames.jsonl` lines 1-12
  Baseline evidence: 690 fragments / 65516 decoded bytes; ordered range SHA-256 `10df429dd735f3791c7272b059b52cbf97b77fdc2ea97335fc23b39429df526d`.
  Dependencies: .1.4 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.6`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 6.
  Scope: `capability_conformance/mcp_semantic_transport/canonical_frames.jsonl` lines 13-35; `capability_conformance/mcp_semantic_transport/corpus.json` lines 1-471; `capability_conformance/mcp_semantic_transport/schema.json` lines 1-664; `capability_conformance/mcp_semantic_transport/semantic_payloads.json` lines 1-291; `capability_conformance/mcp_semantic_transport/validator_cases.json` lines 1-51
  Baseline evidence: 1500 fragments / 63045 decoded bytes; ordered range SHA-256 `87a78c4a97a46dd8fa85dc223a0c839ef1e0f4cf89a96c0cf0c3c4580032b0d1`.
  Dependencies: .1.5 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.7`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 7.
  Scope: `capability_conformance/mcp_semantic_transport/validator_cases.json` lines 52-343; `capability_conformance/mcp_semantic_transport_contract.json` lines 1-230; `capability_conformance/native_spec_resolution_contract.json` lines 1-311; `capability_conformance/outward_descriptor_contract.json` lines 1-127; `capability_conformance/progressive_span_dispatch_contract.json` lines 1-540
  Baseline evidence: 1500 fragments / 60106 decoded bytes; ordered range SHA-256 `a9c824478084ba0d345cc6f750a131554c686936a48531859ba614196ec78343`.
  Dependencies: .1.6 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.8`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 8.
  Scope: `capability_conformance/progressive_span_dispatch_contract.json` lines 541-1540; `capability_conformance/punctuation_light_zero_arg_contract.json` lines 1-67; `capability_conformance/recognition_transaction_contract.json` lines 1-271; `capability_conformance/repeated_action_result/explicit_or_distinct.expected.json` lines 1-1; `capability_conformance/repeated_action_result/explicit_or_distinct.input` lines 1-1; `capability_conformance/repeated_action_result/explicit_or_distinct.spec` lines 1-3; `capability_conformance/repeated_action_result_contract.json` lines 1-157
  Baseline evidence: 1500 fragments / 65525 decoded bytes; ordered range SHA-256 `685f1722e7c38726e6185295ae4d6b0cdf92d6e7eacd8735366b8dd514156397`.
  Dependencies: .1.7 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.9`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 9.
  Scope: `capability_conformance/repeated_action_result_contract.json` lines 158-847; `capability_conformance/root_rule_selection_contract.json` lines 1-595; `capability_conformance/rule_local_cursor_contract.json` lines 1-160
  Baseline evidence: 1445 fragments / 65519 decoded bytes; ordered range SHA-256 `135c54aa02b37554375ab204571cd6504dd495568402b442c3bed9e8babc32fa`.
  Dependencies: .1.8 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.10`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 10.
  Scope: `capability_conformance/rule_local_cursor_contract.json` lines 161-390; `capability_conformance/scalar_numeric_contract.json` lines 1-134; `capability_conformance/scalar_text_contract.json` lines 1-36; `capability_conformance/semantic_introspection/calls_and_staging.spec` lines 1-10; `capability_conformance/semantic_introspection/failed.spec` lines 1-2; `capability_conformance/semantic_introspection/graph.spec` lines 1-8; `capability_conformance/semantic_introspection/privacy.spec` lines 1-2; `capability_conformance/semantic_introspection/runtime.input` lines 1-1; `capability_conformance/semantic_introspection/runtime.spec` lines 1-3; `capability_conformance/semantic_introspection_contract.json` lines 1-363
  Baseline evidence: 789 fragments / 65489 decoded bytes; ordered range SHA-256 `cddda076aaee26145267ab1dbe015f1dcfc87420d1a0b3dac5ee11c5ed338308`.
  Dependencies: .1.9 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.11`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 11.
  Scope: `capability_conformance/semantic_introspection_contract.json` lines 364-716; `capability_conformance/semantic_introspection_model.json` lines 1-201
  Baseline evidence: 554 fragments / 65425 decoded bytes; ordered range SHA-256 `ee919b4d20cab4af9531868f266b574053ceeaa3171c285db6567437f5e4ff1c`.
  Dependencies: .1.10 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.12`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 12.
  Scope: `capability_conformance/semantic_introspection_model.json` lines 202-217; `capability_conformance/staged_ast_enrichment_contract.json` lines 1-996
  Baseline evidence: 1012 fragments / 65472 decoded bytes; ordered range SHA-256 `20ce86d11ec6bdd19057b8d37a8dd36ccd32f79cfa079026cd826bdf4f7f9c1a`.
  Dependencies: .1.11 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.13`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 13.
  Scope: `capability_conformance/staged_ast_enrichment_contract.json` lines 997-1136; `capability_conformance/standalone_lifecycle_block_contract.json` lines 1-249; `capability_conformance/typed_source_location_contract.json` lines 1-452
  Baseline evidence: 841 fragments / 65510 decoded bytes; ordered range SHA-256 `6f5ec2d872aecad8afdfe7fba6ac2c9996f67e0c121078103c767084cffdeaf6`.
  Dependencies: .1.12 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.14`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 14.
  Scope: `capability_conformance/typed_source_location_contract.json` lines 453-814; `capability_conformance/unicode_case_contract.json` lines 1-1138
  Baseline evidence: 1500 fragments / 33332 decoded bytes; ordered range SHA-256 `5e55d60ae1deea255552eb6fc86dc89cc255313c2f76adc93e7eeca1532d1b0c`.
  Dependencies: .1.13 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.15`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 15.
  Scope: `capability_conformance/unicode_case_contract.json` lines 1139-2638
  Baseline evidence: 1500 fragments / 14500 decoded bytes; ordered range SHA-256 `84f88e75f0b8cca02f4f43134f6a3b7771231539ff88198725049d1ced86e9e1`.
  Dependencies: .1.14 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.16`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 16.
  Scope: `capability_conformance/unicode_case_contract.json` lines 2639-4138
  Baseline evidence: 1500 fragments / 14500 decoded bytes; ordered range SHA-256 `2a4b9375c72ac8a810bdabe84850311c7fd96cf27ef1f67b75b9a963c1a7f683`.
  Dependencies: .1.15 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.17`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 17.
  Scope: `capability_conformance/unicode_case_contract.json` lines 4139-5638
  Baseline evidence: 1500 fragments / 14500 decoded bytes; ordered range SHA-256 `7ad11f24545aaf2ee3ba1d33f29ff9531d8b1624e93e1acc74f89b5baf3d05a5`.
  Dependencies: .1.16 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.18`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 18.
  Scope: `capability_conformance/unicode_case_contract.json` lines 5639-7138
  Baseline evidence: 1500 fragments / 14500 decoded bytes; ordered range SHA-256 `44c866b4499f10805ebccd70d094fa2c8f23baa623925827baccb887dc40fcaf`.
  Dependencies: .1.17 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.19`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 19.
  Scope: `capability_conformance/unicode_case_contract.json` lines 7139-8638
  Baseline evidence: 1500 fragments / 14848 decoded bytes; ordered range SHA-256 `2cbf40f146175f7b2ab44db632e7281fb13212e18bb824fe758ec395549d9be3`.
  Dependencies: .1.18 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.20`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 20.
  Scope: `capability_conformance/unicode_case_contract.json` lines 8639-10138
  Baseline evidence: 1500 fragments / 14781 decoded bytes; ordered range SHA-256 `6beeca8dab15540cef3744801644a02a1dc5bbfea2e7bf7f438b5f74cb19f8f4`.
  Dependencies: .1.19 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.21`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 21.
  Scope: `capability_conformance/unicode_case_contract.json` lines 10139-11638
  Baseline evidence: 1500 fragments / 14528 decoded bytes; ordered range SHA-256 `871a0b608f735bef80fb454cf49b81ae74b346acae999893fa357ec5ec7c1d3c`.
  Dependencies: .1.20 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.22`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 22.
  Scope: `capability_conformance/unicode_case_contract.json` lines 11639-13138
  Baseline evidence: 1500 fragments / 14510 decoded bytes; ordered range SHA-256 `1fe548621bf1779fe904e936b562cd512035806236c440e96006fa9ab1afac3d`.
  Dependencies: .1.21 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.23`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 23.
  Scope: `capability_conformance/unicode_case_contract.json` lines 13139-14638
  Baseline evidence: 1500 fragments / 15108 decoded bytes; ordered range SHA-256 `2715613a708624c2b9a4025d923915536a1856fbb4be08b98570748d73c68517`.
  Dependencies: .1.22 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.24`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 24.
  Scope: `capability_conformance/unicode_case_contract.json` lines 14639-16138
  Baseline evidence: 1500 fragments / 14500 decoded bytes; ordered range SHA-256 `26faa08194e1e3baf3ebe01eb0716ee4b3aac00bd6609c84cdc7cd76398956b8`.
  Dependencies: .1.23 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.25`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 25.
  Scope: `capability_conformance/unicode_case_contract.json` lines 16139-17638
  Baseline evidence: 1500 fragments / 14739 decoded bytes; ordered range SHA-256 `4e8f093eada059c9b5c6771609668311eeb7ccd8186f2b1d3a3c4d9e04fe7443`.
  Dependencies: .1.24 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.26`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 26.
  Scope: `capability_conformance/unicode_case_contract.json` lines 17639-19138
  Baseline evidence: 1500 fragments / 14999 decoded bytes; ordered range SHA-256 `60079fbb3044976bc23788a9f8c61b6236978340a87ead8d398d297a680f0419`.
  Dependencies: .1.25 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.27`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 27.
  Scope: `capability_conformance/unicode_case_contract.json` lines 19139-20638
  Baseline evidence: 1500 fragments / 15135 decoded bytes; ordered range SHA-256 `ee8c604e1d052100655a1374f5512223f967ae6dd1033dbd684e946dc0340f65`.
  Dependencies: .1.26 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.28`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 28.
  Scope: `capability_conformance/unicode_case_contract.json` lines 20639-21621; `capability_conformance/unicode_rule_label_contract.json` lines 1-517
  Baseline evidence: 1500 fragments / 17109 decoded bytes; ordered range SHA-256 `20287f9706225c05dbb4d480ca10ab9c37e0ca0cdc032340616073f1ddb68ed8`.
  Dependencies: .1.27 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.29`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 29.
  Scope: `capability_conformance/unicode_rule_label_contract.json` lines 518-2017
  Baseline evidence: 1500 fragments / 15123 decoded bytes; ordered range SHA-256 `f993abf7d64e771d8d6462592c0853d61a40d719557d03fbf97de8a2e445b4ba`.
  Dependencies: .1.28 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.30`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 30.
  Scope: `capability_conformance/unicode_rule_label_contract.json` lines 2018-3349; `capability_conformance/uniform_binding_contract.json` lines 1-168
  Baseline evidence: 1500 fragments / 23627 decoded bytes; ordered range SHA-256 `d8b23804652a86775f9841bb1b8a6fd2466fdc04ff0a4c207d965d4a0d6da69c`.
  Dependencies: .1.29 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.31`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 31.
  Scope: `capability_conformance/uniform_binding_contract.json` lines 169-179; `capability_conformance/write_map_leaves_composition_contract.json` lines 1-279; `capability_conformance/write_vivification_contract.json` lines 1-551; `cli_conformance/README.md` lines 1-136; `cli_conformance/cases/failure/stderr.txt` lines 1-1; `cli_conformance/cases/help/stdout.txt` lines 1-50; `cli_conformance/cases/success/input.txt` lines 1-1; `cli_conformance/cases/success/nested.spec` lines 1-5; `cli_conformance/cases/trace/appended_low.txt` lines 1-7; `cli_conformance/cases/trace/debug_emoji_stdout.txt` lines 1-12; `cli_conformance/cases/trace/failure_input_low.txt` lines 1-4; `cli_conformance/cases/trace/failure_invoke_escaped_medium.txt` lines 1-7; `cli_conformance/cases/trace/failure_invoke_low.txt` lines 1-6; `cli_conformance/cases/trace/failure_low.txt` lines 1-2; `cli_conformance/cases/trace/full.txt` lines 1-10; `cli_conformance/cases/trace/full_stdout.txt` lines 1-11; `cli_conformance/cases/trace/high_stdout.txt` lines 1-10; `cli_conformance/cases/trace/high_utf8_stdout.txt` lines 1-10; `cli_conformance/cases/trace/low.txt` lines 1-6; `cli_conformance/cases/trace/low_emoji.txt` lines 1-6; `cli_conformance/cases/trace/low_stdout.txt` lines 1-7; `cli_conformance/cases/trace/medium_stdout.txt` lines 1-8; `cli_conformance/cases/trace/stale.txt` lines 1-1; `cli_conformance/cases/usage/stderr.txt` lines 1-52; `cli_conformance/manifest.json` lines 1-33
  Baseline evidence: 1226 fragments / 65536 decoded bytes; ordered range SHA-256 `46bcea6e2c386c833619c7de753c78fac9d9d74b90b549cad7fde095626a6908`.
  Dependencies: .1.30 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.32`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 32.
  Scope: `cli_conformance/manifest.json` lines 34-1150; `t/actionir_ast_parser.t` lines 1-383
  Baseline evidence: 1500 fragments / 55235 decoded bytes; ordered range SHA-256 `a18d6759757376a16e4e9227fe577ddbfb412e5e907e4b4f4ec1cac9264a2b7f`.
  Dependencies: .1.31 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.33`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 33.
  Scope: `t/actionir_ast_parser.t` lines 384-1419; `t/callable_codeblock_literal_contract.t` lines 1-345
  Baseline evidence: 1381 fragments / 65521 decoded bytes; ordered range SHA-256 `d599d85b6f3034b709e12a21de4e3eb5101ce70e14e0292f5b4a24674656b478`.
  Dependencies: .1.32 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.34`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 34.
  Scope: `t/callable_codeblock_literal_contract.t` lines 346-565; `t/cli_conformance_runner.t` lines 1-287; `t/complete_named_mark_contract.t` lines 1-79; `t/diagnostic_output_perl_contract.t` lines 1-461; `t/duplicate_regex_slot_identity_perl_contract.t` lines 1-300; `t/generated_source_contract.t` lines 1-153
  Baseline evidence: 1500 fragments / 56255 decoded bytes; ordered range SHA-256 `d7c3d32b96d69703881506fb7bf1454a585e47b91fb044b29570dd0fd23e180d`.
  Dependencies: .1.33 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.35`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 35.
  Scope: `t/generated_source_contract.t` lines 154-506; `t/inspect_spec_codegen.t` lines 1-121; `t/inter_match_gap_capture_perl_contract.t` lines 1-1026
  Baseline evidence: 1500 fragments / 51804 decoded bytes; ordered range SHA-256 `9811fc24e1ee0addc55fb94051e23da5ed0edc9ceffee39f36a655f6f8b88bee`.
  Dependencies: .1.34 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.36`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 36.
  Scope: `t/inter_match_gap_capture_perl_contract.t` lines 1027-1154; `t/lib/TestHelpers.pm` lines 1-137; `t/logical_helper_perl_contract.t` lines 1-285; `t/map_leaves_mutation_perl_contract.t` lines 1-374; `t/mcp_contract_perl_binding.t` lines 1-125; `t/mcp_server_perl_admission.t` lines 1-451
  Baseline evidence: 1500 fragments / 58957 decoded bytes; ordered range SHA-256 `5acc1fa20e3243969fc5a7d065139ece45aa08d6ff1f2d80cecd2cc91247147e`.
  Dependencies: .1.35 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.37`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 37.
  Scope: `t/mcp_server_perl_admission.t` lines 452-656; `t/mcp_server_perl_dispatch.t` lines 1-403; `t/mcp_server_perl_stdio.t` lines 1-472; `t/native_spec_resolution.t` lines 1-222; `t/noncurrent_helper_metadata.t` lines 1-68; `t/oracle_root_target_regex_semantics.t` lines 1-87; `t/phase0_regression.t` lines 1-43
  Baseline evidence: 1500 fragments / 63613 decoded bytes; ordered range SHA-256 `9d2fc07302eebc1f1dcc1294523f599be987d9834a59648e1c92f958cd06a42c`.
  Dependencies: .1.36 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.38`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 38.
  Scope: `t/phase0_regression.t` lines 44-1110
  Baseline evidence: 1067 fragments / 65529 decoded bytes; ordered range SHA-256 `681152e5cc921275d5cbca78f1f4becc67874dd7f772792c660a6eae479cfd21`.
  Dependencies: .1.37 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.39`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 39.
  Scope: `t/phase0_regression.t` lines 1111-1526
  Baseline evidence: 416 fragments / 64842 decoded bytes; ordered range SHA-256 `9e3895f7b13337a4a6b6f5241dacda61678065fde2cc2724367ae1bc2295036c`.
  Dependencies: .1.38 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.40`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 40.
  Scope: `t/phase0_regression.t` lines 1527-2566
  Baseline evidence: 1040 fragments / 65471 decoded bytes; ordered range SHA-256 `d5a9d405495fac023b401318c972eb0442e1db38717695e859a6046cd2dab759`.
  Dependencies: .1.39 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.41`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 41.
  Scope: `t/phase0_regression.t` lines 2567-3739
  Baseline evidence: 1173 fragments / 65484 decoded bytes; ordered range SHA-256 `2ae790e06398a17ba62a899d756c0a307f10d824187fb81288980b2beae8ee92`.
  Dependencies: .1.40 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.42`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 42.
  Scope: `t/phase0_regression.t` lines 3740-5136
  Baseline evidence: 1397 fragments / 65472 decoded bytes; ordered range SHA-256 `0dd54bbb3ae2b2e42b7ebdbbe61510dea667586119055340b8940a8b1c0c1c43`.
  Dependencies: .1.41 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.43`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 43.
  Scope: `t/phase0_regression.t` lines 5137-6636
  Baseline evidence: 1500 fragments / 64877 decoded bytes; ordered range SHA-256 `944f19375169eb35a0aa51939a66270a2f319c261ec2aca28544168ba7b3e4ef`.
  Dependencies: .1.42 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.44`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 44.
  Scope: `t/phase0_regression.t` lines 6637-7826
  Baseline evidence: 1190 fragments / 65521 decoded bytes; ordered range SHA-256 `33c4d12568f0ba14dad46d9ef28b7487fbe92dc765902e2cadb86d3d28acd150`.
  Dependencies: .1.43 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.45`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 45.
  Scope: `t/phase0_regression.t` lines 7827-8871
  Baseline evidence: 1045 fragments / 65409 decoded bytes; ordered range SHA-256 `97cf45f625d1e54cf5b43fdc91f19b8818e3c4c4dae41086065156c6db60dba2`.
  Dependencies: .1.44 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.46`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 46.
  Scope: `t/phase0_regression.t` lines 8872-9844
  Baseline evidence: 973 fragments / 65483 decoded bytes; ordered range SHA-256 `8292afe74aabb6ce967f52d6b6aea097a9398d4d3aac710c9f67f992d423d6ca`.
  Dependencies: .1.45 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.47`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 47.
  Scope: `t/phase0_regression.t` lines 9845-10823
  Baseline evidence: 979 fragments / 65510 decoded bytes; ordered range SHA-256 `d22df0a79db9e7b831352da4b823609578d2eefb18350f2dfb385770c8a98ef7`.
  Dependencies: .1.46 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.48`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 48.
  Scope: `t/phase0_regression.t` lines 10824-11855
  Baseline evidence: 1032 fragments / 65524 decoded bytes; ordered range SHA-256 `f1fd2107d5d3c0f983821b84deffb49bc48f347b073ea56d794f4bd18e5d3686`.
  Dependencies: .1.47 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.49`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 49.
  Scope: `t/phase0_regression.t` lines 11856-12849
  Baseline evidence: 994 fragments / 65520 decoded bytes; ordered range SHA-256 `935b7c9398809a4c668d89e6f3a6dcdf32bdf6e1d982d761ecffdf1cf6c9305d`.
  Dependencies: .1.48 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.50`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 50.
  Scope: `t/phase0_regression.t` lines 12850-13631
  Baseline evidence: 782 fragments / 65470 decoded bytes; ordered range SHA-256 `7e2fe3f81d5eb0a39d7995310a1985e283f54bf7967d3cbcaa2d378f841c3676`.
  Dependencies: .1.49 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.51`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 51.
  Scope: `t/phase0_regression.t` lines 13632-14984
  Baseline evidence: 1353 fragments / 65519 decoded bytes; ordered range SHA-256 `cfcddcd8f858ea6f0ddf8f0a3c1ddb2a0dae70684781aef6972b8c4843dc20c7`.
  Dependencies: .1.50 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.52`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 52.
  Scope: `t/phase0_regression.t` lines 14985-16061
  Baseline evidence: 1077 fragments / 65180 decoded bytes; ordered range SHA-256 `852040242decbd55b0baa1f102069209f4fc087a79ce760ead45cf170ceb6906`.
  Dependencies: .1.51 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.53`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 53.
  Scope: `t/phase0_regression.t` lines 16062-16879
  Baseline evidence: 818 fragments / 65478 decoded bytes; ordered range SHA-256 `fc27e709b2e0b8fedb8f69039e4b3a9beee175ac7f2ab8ae091a04dfedd8278e`.
  Dependencies: .1.52 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.54`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 54.
  Scope: `t/phase0_regression.t` lines 16880-18057
  Baseline evidence: 1178 fragments / 65522 decoded bytes; ordered range SHA-256 `f002e310ba21be1c3e18ddd52ff977d482292dcc9bf5150b6803b76517aa4f06`.
  Dependencies: .1.53 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.55`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 55.
  Scope: `t/phase0_regression.t` lines 18058-19557
  Baseline evidence: 1500 fragments / 63518 decoded bytes; ordered range SHA-256 `1790d16fffc4de8547c8c257f769911a5df93d965b512a195799268f50d9b948`.
  Dependencies: .1.54 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.56`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 56.
  Scope: `t/phase0_regression.t` lines 19558-21057
  Baseline evidence: 1500 fragments / 64289 decoded bytes; ordered range SHA-256 `1ef2959331e2e7b7ffdfb0b0ee3da905223bf608e022bad0b756e60646982c18`.
  Dependencies: .1.55 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.57`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 57.
  Scope: `t/phase0_regression.t` lines 21058-22258
  Baseline evidence: 1201 fragments / 65530 decoded bytes; ordered range SHA-256 `f6bd4ff7b48da261c1d399dc421744880009011be4b3f3b4e6b692061e965445`.
  Dependencies: .1.56 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.58`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 58.
  Scope: `t/phase0_regression.t` lines 22259-23758
  Baseline evidence: 1500 fragments / 62624 decoded bytes; ordered range SHA-256 `043f210793270c411dde8ae43deff76225538fd32effa094c0de5887c9f67705`.
  Dependencies: .1.57 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.59`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 59.
  Scope: `t/phase0_regression.t` lines 23759-25258
  Baseline evidence: 1500 fragments / 55331 decoded bytes; ordered range SHA-256 `7d72c94dee04a686c444c25f061c9aa75dfaefcc8e5854f2cc2b8f5bdcb2513d`.
  Dependencies: .1.58 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.60`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 60.
  Scope: `t/phase0_regression.t` lines 25259-26758
  Baseline evidence: 1500 fragments / 55852 decoded bytes; ordered range SHA-256 `0b1b9ef599543e4e054aa5eb7c9f33c5cef7f36686c6d6272acce4fe67f8c2e7`.
  Dependencies: .1.59 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.61`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 61.
  Scope: `t/phase0_regression.t` lines 26759-28258
  Baseline evidence: 1500 fragments / 60428 decoded bytes; ordered range SHA-256 `d63bc78bbc069074064e1eb2fb5fc845d90c690c719efb8dd8ef1c49d18a0e85`.
  Dependencies: .1.60 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.62`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 62.
  Scope: `t/phase0_regression.t` lines 28259-29758
  Baseline evidence: 1500 fragments / 60456 decoded bytes; ordered range SHA-256 `68339aadd8a590c268607deb3bf3b4adea0e958ea7ac4507ccf71b0bbced1048`.
  Dependencies: .1.61 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.63`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 63.
  Scope: `t/phase0_regression.t` lines 29759-31258
  Baseline evidence: 1500 fragments / 52166 decoded bytes; ordered range SHA-256 `9c6f31e671585a8f3ea8dbffd67bb2d7afef67fb63912cc57d7f146ad3c30967`.
  Dependencies: .1.62 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.64`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 64.
  Scope: `t/phase0_regression.t` lines 31259-32758
  Baseline evidence: 1500 fragments / 54211 decoded bytes; ordered range SHA-256 `55d15ae7d6a7c37ce5678f5b1fd42fa9463d2539c6c1f7efa08d5db9fda56b3e`.
  Dependencies: .1.63 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.65`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 65.
  Scope: `t/phase0_regression.t` lines 32759-33715
  Baseline evidence: 957 fragments / 65498 decoded bytes; ordered range SHA-256 `02117d7574f9a1c24d7cd383c22a319447676bf7a77dd87368f8d16d22bc3274`.
  Dependencies: .1.64 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.66`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 66.
  Scope: `t/phase0_regression.t` lines 33716-34545
  Baseline evidence: 830 fragments / 65423 decoded bytes; ordered range SHA-256 `6cb1c5c9962a88b5160eaf2ac09cb56d3de4c47d0ad116eb50c7978af9ec9db2`.
  Dependencies: .1.65 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.67`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 67.
  Scope: `t/phase0_regression.t` lines 34546-35429
  Baseline evidence: 884 fragments / 65500 decoded bytes; ordered range SHA-256 `ee0342959ecfbfb9c39a7587cf966140a5a97437980a38a35f168011be428850`.
  Dependencies: .1.66 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.68`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 68.
  Scope: `t/phase0_regression.t` lines 35430-36290
  Baseline evidence: 861 fragments / 65511 decoded bytes; ordered range SHA-256 `d9b5680c28c98724837615ea8b3b918129645c7170e1a4f0f434a213ccf5f38e`.
  Dependencies: .1.67 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.69`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 69.
  Scope: `t/phase0_regression.t` lines 36291-36947
  Baseline evidence: 657 fragments / 65437 decoded bytes; ordered range SHA-256 `1a359611867e9800e2915010b594ad8093c30ae4f37025d02c22f0a5bd1cacef`.
  Dependencies: .1.68 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.70`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 70.
  Scope: `t/phase0_regression.t` lines 36948-37744
  Baseline evidence: 797 fragments / 65524 decoded bytes; ordered range SHA-256 `5ac87a150611aa5dcb3f2d3748045d97d1264793f3696bfe51a3265a7f0e6cfa`.
  Dependencies: .1.69 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.71`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 71.
  Scope: `t/phase0_regression.t` lines 37745-38503
  Baseline evidence: 759 fragments / 65504 decoded bytes; ordered range SHA-256 `23ace6853a715825816ce55d79c7b975ce9fadef04e2c80d2073308c7c26b438`.
  Dependencies: .1.70 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.72`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 72.
  Scope: `t/phase0_regression.t` lines 38504-39354
  Baseline evidence: 851 fragments / 65534 decoded bytes; ordered range SHA-256 `79d7822ef3324308df225adc573dd141b794f0800065d8887448e0cf67c744bd`.
  Dependencies: .1.71 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.73`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 73.
  Scope: `t/phase0_regression.t` lines 39355-40442
  Baseline evidence: 1088 fragments / 65436 decoded bytes; ordered range SHA-256 `315ca951694090af2512c351d52c1e263ecf846bbe3f507805fd02a5ef9fe919`.
  Dependencies: .1.72 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.74`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 74.
  Scope: `t/phase0_regression.t` lines 40443-41195
  Baseline evidence: 753 fragments / 65404 decoded bytes; ordered range SHA-256 `d48cb6243066d0ed51cbdbc924791a016905e344777495e753a3ee284defd3f4`.
  Dependencies: .1.73 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.75`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 75.
  Scope: `t/phase0_regression.t` lines 41196-42087
  Baseline evidence: 892 fragments / 65464 decoded bytes; ordered range SHA-256 `a42abbcf06fb96fe881ee0f242527538ae9e53e0c423bbf4533f721ff2645978`.
  Dependencies: .1.74 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.76`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 76.
  Scope: `t/phase0_regression.t` lines 42088-42887
  Baseline evidence: 800 fragments / 65456 decoded bytes; ordered range SHA-256 `f7a4521038b590b5c26699bfeffe4a7e5f2a0c2aec8840bc80d881864bca9bac`.
  Dependencies: .1.75 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.77`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 77.
  Scope: `t/phase0_regression.t` lines 42888-43916
  Baseline evidence: 1029 fragments / 65477 decoded bytes; ordered range SHA-256 `b47206ff5e1b9e509629d9ecae475aebd9c311dc324d423db88e6948e6ce68a7`.
  Dependencies: .1.76 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.1.78`
  Status: `pending`
  Goal: Read and understand conformance/test/Unicode group 78.
  Scope: `t/phase0_regression.t` lines 43917-45063
  Baseline evidence: 1147 fragments / 65472 decoded bytes; ordered range SHA-256 `8e7281c18857a910da9a21947835cb4102bdb3c9f1931bc5516468d7d8ea4130`.
  Dependencies: .1.77 committed with clean handoff.
  Acceptance: Read every scoped byte in complete bounded windows; retain source identity, exact comprehension, canonical Knowledge reconciliation, concrete finding ownership, focused proof and per-leaf continuity. Unread crossing constructs retain the next range owner.
  Verification: `pending`
  Commit: `pending`

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
  Commit: `pending`

- ID: `CONFORMANCE-SOURCE-READING.3`
  Status: `pending`
  Goal: Independently reconcile all source/range/reading-commit/repair evidence and close only the required reading lane with applicable verification.
  Dependencies: All143 required reading children committed; every finding repair-owned; canonical closeout proof or a new explicit applicable exception.
  Acceptance: Reconcile original/current inventory, decoded inputs, exact once-only coverage, comprehension, source deltas, commit activations and retained repairs. Preserve later startup/book/policy requirements and distinguish reading from runtime signoff.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Rank | Leaf | Status | Next action |
| --- | --- | --- | --- |
| 1 | `CONFORMANCE-SOURCE-READING.1.2` | `pending` | Finish capability README771-897, read the three complete callable/signature/named-mark contracts and diagnostic prefix1-268 in exact bounded windows. |

## Decisions

- `2026-09-13` .1.1: Extend existing startup .41.6/.41.7 with exact guide-current contradictions and checker coverage; preserve historical milestones and keep code repairs behind startup prerequisites. No duplicate repair owner or current runtime failure is invented.
- `2026-09-13`: All160 inputs remain required by startup .3.8; gzip coordinates describe decoded source. The exact existing1500-fragment/65536-byte budgets yield143 groups; no source or capacity policy changes.

## Blockers

- None at decomposition. Ordinary source repairs retain startup prerequisites; later collection pressure must be measured rather than assumed away.

## Verification Log

- `2026-09-13` .1.1: Conformance .1.1 reads all 11 complete windows of capability_conformance/README.md lines1-770: 770 fragments/65,485 baseline-identical bytes. Physical conformance reading is1/143; the README suffix771-897 and later contracts remain .1.2-owned. Seven focused structural/neutral checks pass, while exact current census, mutation/inventory/public-count and generic-callable claims remain stale. Existing startup .41.7 and .41.6 now own those actual paragraphs and meaningful recurrence; the marker/denial-only cause is recorded without changing source or runtime. All143 groups/302 ranges, prior source/history, six supporting repair roots and existing capacity limits remain. No fresh backend matrix, dependency build or parent closeout is claimed.
- `2026-09-13`: Startup .3.8.0 independently verifies all160 files/143 groups/302 ranges and four decoded hashes; Unicode casing and rule-label checks PASS. Source/task/history, actual capacity, memory, Knowledge, histories, rendered book and normal hooks govern planning. Physical reading remains0/143.

## Commit Log

- `2026-09-13` .1.1: `CONFORMANCE-SOURCE-READING.1.1 - read capability guide prefix and own stale current claims`; activation d3cfa5973beed85de5ae58dc81798262cafe18ad; next .1.2 after clean handoff and zero-byte brief.
- `2026-09-13`: Decomposition lands under `SESSION-STARTUP-READING.3.8.0`; Git owns the resulting commit identity.

## Changelog

- `2026-09-13` .1.1: Complete the first11 guide windows; retain clear suffix ownership and concrete repair acceptance for current-claim drift.
- `2026-09-13`: Own every conformance/test/Unicode range before reading; preserve all existing source, history, repair and capacity obligations.
