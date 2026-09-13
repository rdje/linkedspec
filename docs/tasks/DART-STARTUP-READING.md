# DART-STARTUP-READING: Bounded Dart source reading and repair ownership

## Metadata

- Tree ID: `DART-STARTUP-READING`
- Status: `active` / reading closed under .3.2 / ADR0114; 25 repair roots remain open
- Roadmap lane: `Session required reading / SESSION-STARTUP-READING.3.4`
- Created: `2026-09-09`
- Last updated: `2026-09-12`
- Owner: repo-local workflow

## Goal

Read and understand every baseline Dart entry and every current delta through bounded, committed
leaves. Keep source coverage, comprehension, canonical facts and confirmed repair ownership durable.
The existing startup node `SESSION-STARTUP-READING.3.4` remains the Dart prerequisite and
reading-closeout owner; this separate bounded tree owns its decomposition and reading evidence.

## Non-Goals

- This admission grants no Dart source-reading credit and changes no parser/runtime behavior.
- Existing startup repairs retain their IDs and evidence; new findings reuse those owners when applicable.
- Repair implementation remains behind startup reading and policy gates; admission does not waive them.
- Generics, libraries, builders, fileless MCP debugging and the approved format/language ideas remain parked.
- Recovery/purge remains blocked by startup `.7`; capacity intakes .4/.5/.6 own proposals only. No infrastructure increase or artifact purge is implemented in this tree.

## Acceptance Criteria

- Decomposition `.0` accounts for all baseline/current paths and creates bounded source-reading children before reading.
- Each reading child preserves exact baseline coordinates, byte identity, current deltas and comprehension evidence.
- Confirmed defects have a precise existing or new repair owner before any fix; reading completion never claims zero defects.
- Closeout `.3` proves complete byte coverage, delta accounting, child commit identity and retained findings,
  then completes startup `.3.4` and routes the next required-reading activity.
- The whole tree closes only after its repair-intake work is done, deferred with a reason, or superseded by named owners.
- Every completed leaf follows COMMIT.md with proportional proof, synchronized book/live docs, a cleared brief and clean Git state.
- Current members and aggregate stores remain within ADR 0109's finite controls; no unique evidence is discarded.

## Baseline And Admission Boundary

- Reading baseline: `baeb984e36a94a15951cd23d4c52def5064cdaca`.
- Capacity implementation: `4489f5e9a3cf60fabf6c4f69d27aedfc87cbac6b`; independent proof:
  `a7d392a8ea61ed22cab1a397aacc854cc9b1139f`.
- Admission owner: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.4`, committed canonically at
  `a67a18bf8222bbc0bc63748f598d3a12a8191850`; clean state and zero-byte brief verified before `.0`.
- Measured inventory: 115 paths / 80,296 physical lines / 2,471,305 bytes, baseline-identical at admission.
  Physical lines use LF boundaries and count a nonempty final line without LF.
- Reproducible planning: 55 groups / 169 ranges / 80,297 per-window fragments; two ranges use byte coordinates
  for an oversized physical line. Every group fits 1,500 fragments / 65,536 bytes without splitting UTF-8.
- A separate 56-group control preserves the conservative allowance; it is not a reconstruction of older grouping.
- Canonical inventory/range audit: `docs/knowledge/startup-task-chronology-compaction.md`,
  DART_CAPACITY_AUDIT. Controls/reserve audit: `docs/knowledge/dart-reading-capacity-controls.md`.
- Decomposition `.0` freezes the 55-group plan as `.1.1-.1.55`; no baseline/current path or byte delta.
  Coordinates are one-based inclusive LF lines or absolute file bytes; byte windows preserve UTF-8 boundaries.
  No baseline entry is empty; the canonical audit retains explicit empty-entry handling.
- Ordered inventory SHA-256: `34ab5a05c63525c7c7537332e71ce8104c83b5efe2a7413714923a8745d35425`.
  Ordered range SHA-256: `68844356bf68df29531e689ff80fd06be16059621c678c4c8dbaa0b9adcb398f`.
  Every child pins its own ordered range digest; the independent declared-scope audit is in
  `docs/knowledge/dart-startup-reading-coverage.md`. Decomposition itself grants no physical-reading credit.
- Current reading: 55/55 children, 80,297/80,297 fragments and 2,471,305/2,471,305 bytes; all 115 entries through EOF.
  Physical and formal reading are complete under .3.2 / ADR0114; all repair work remains separately open. Exact credit and comprehension remain in each completed node.

## Task Tree

- ID: `DART-STARTUP-READING`
  Status: `active`
  Goal: Complete bounded Dart reading and durable repair intake while preserving startup prerequisite ownership.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`

- ID: `DART-STARTUP-READING.0`
  Status: `done`
  Goal: Freeze exact baseline/current membership and decompose all Dart source reading into bounded owned leaves.
  Dependencies: Clean canonical containment `.7.4` admission.
  Acceptance: Reconstruct every path/range and byte exactly once, preserve empty and oversized-line handling,
    turn `.1` into a container with scoped children, and route the first child without claiming physical reading.
  Verification tier: `focused`
  Focused checks: Exact baseline/current inventory, independently reconstructed declared ranges, child digests and counts; task/member/Knowledge pressure, all doctrines, both histories, Knowledge synchronization, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded reading decomposition under canonically admitted controls; no executable, contract or capacity changes.
  Verification: All 115 paths / 80,296 physical lines / 2,471,305 bytes remain baseline-identical. Independently reconstructed declared scopes cover every byte exactly once across 55 pending children / 169 ranges / 80,297 fragments; all child bounds/digests and the aggregate digest match. Focused doctrine, pressure, history, Knowledge, book and preservation results belong to this commit; no source-reading credit.
  Commit: `DART-STARTUP-READING.0 - freeze exact bounded Dart reading children`

- ID: `DART-STARTUP-READING.1`
  Status: `done`
  Goal: Read and understand the entire owned Dart scope through the bounded children defined by `.0`.
  Dependencies: `.0`; never execute this broad node as one reading slice.
  Acceptance: Every child accounts for its exact source bytes and deltas, reconciles Knowledge before re-derivation,
    records comprehension and confirmed findings, runs necessary focused diagnostics and commits before the next child.
  Children: `.1.1-.1.55`; exact scopes and baseline evidence below, read in numeric order.
  Verification: 55/55 children complete; `.1.1-.1.55` own exact reading/comprehension evidence. Independent .3.1/.3.2 audit verifies every child commit; .3.2 closes this reading container under the director-delegated one-time ADR0114 exception. Runtime gate failures and all repairs remain open.
  Commit: `DART-STARTUP-READING.3.2 - close verified Dart reading under delegated decision` (reading-container closure)

- ID: `DART-STARTUP-READING.1.1`
  Status: `done`
  Goal: Read bounded Dart group 1 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.0` committed; empty brief and clean repository.
  Scope: `dart/README.md` lines 1-528; `dart/analysis_options.yaml` lines 1-8; `dart/bin/corpus_runner.dart` lines 1-7; `dart/bin/linkedspec_dart.dart` lines 1-7; `dart/lib/linkedspec_dart.dart` lines 1-291; `dart/lib/src/action/action_ast.dart` lines 1-659
  Baseline evidence: 1500 fragments / 60321 bytes; ordered range SHA-256 `5b8b991130efbf43a7436c1be04c1e7714e523090e8444a6c3b99e95dcfa6c24`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart ActionIR/parser and spec-AST tests; exact owned-range/current-delta audit; prior evidence, all doctrines, both histories, Knowledge synchronization, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded source reading and documentation; no executable or contract changes and no new systemic uncertainty.
  Comprehension: Thin primary/corpus delegates; strict analyzer flags; 22 explicit public export directives; common kind/source/span JSON; private progressive/staged/recognition declarations; typed read/write paths and contextual-codeblock metadata. The literal-codeblock constructor ends this range; `.1.2` resumes its fields and serialization. Existing facts are reconciled in `docs/knowledge/dart-public-facade-startup-reading.md`.
  Findings: No new confirmed defect in this owned range; existing repairs and parked authoring ideas retain their owners.
  Verification: Physically read all six declared ranges in untruncated bounded outputs; 1,500 fragments / 60,321 bytes remain baseline-identical with the pinned range digest. Existing ActionIR/parser and spec-AST tests pass 9/9. Focused workflow, retention, pressure, Knowledge and book results belong to this commit; no claim beyond this reading/test scope.
  Commit: `DART-STARTUP-READING.1.1 - read Dart entrypoints and initial ActionIR declarations`

- ID: `DART-STARTUP-READING.1.2`
  Status: `done`
  Goal: Read bounded Dart group 2 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.1` committed; empty brief and clean repository.
  Scope: `dart/lib/src/action/action_ast.dart` lines 660-1470; `dart/lib/src/action/action_contracts.dart` lines 1-689
  Baseline evidence: 1500 fragments / 36093 bytes; ordered range SHA-256 `58e542868b01b0f47b075b76542d1d93b74e55fde28c0764719afb2404c5cb86`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart AST/parser, action-contract, uniform-binding and callable-codeblock tests; exact owned-range/current-delta audit; prior evidence, all doctrines, both histories, Knowledge synchronization, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded source reading and documentation; no executable or contract changes and no new systemic uncertainty.
  Comprehension: Complete literal-codeblock JSON, malformed nodes, assignments, typed receiver mutations/continuations and control bodies; exact single-variable aggregate-selector detection and its deferred-codeblock boundary. Contract tables separate canonical names, numeric/current aliases, accepted source-boundary aliases and helper families. This range ends inside _familyForCanonical; .1.3 owns its remainder and resolver implementation. Existing facts are reconciled in docs/knowledge/dart-actionir-contract-resolver.md and docs/knowledge/dart-callable-codeblock-literal-state.md.
  Findings: No new confirmed code defect. Refresh the resolver fact's historical verification command and explain current accepted alias tables; deferred literal bodies already have documented ownership and are not an eager-selector omission.
  Verification: Physically read both declared ranges in untruncated bounded outputs; 1,500 fragments / 36,093 bytes remain baseline-identical with the pinned digest. Existing AST/parser, contract, uniform-binding and callable-codeblock tests pass 50/50. Focused workflow, retention, pressure, Knowledge and book results belong to this commit; no claim beyond this reading/test scope.
  Commit: `DART-STARTUP-READING.1.2 - read remaining ActionIR nodes and helper tables`

- ID: `DART-STARTUP-READING.1.3`
  Status: `done`
  Goal: Read bounded Dart group 3 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.2` committed; empty brief and clean repository.
  Scope: `dart/lib/src/action/action_contracts.dart` lines 690-1191; `dart/lib/src/action/action_parser.dart` lines 1-998
  Baseline evidence: 1500 fragments / 43988 bytes; ordered range SHA-256 `86d0b11709fb23b89543bc7702a52e4de20e7a662abd45991fdbf49c039a25b2`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart AST/parser, action-contract, punctuation-light, variadic-function, nested-write and recognition-transaction tests; controlled switch AST/resolver/native/reconstructed probes; exact range/current-delta and prior-evidence audits; all doctrines, both histories, Knowledge synchronization, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded source reading, reproducible defect intake and documentation; no executable or contract changes. The defect has gated repair children rather than a behavior change in this leaf.
  Comprehension: Helper-family priority, immutable resolution output, structural/mutation traversal, deferred callable/intrinsic exclusions, registry positional/variadic matching and keyword rejection; parser dispatch order, literal/brace/control recognition, static recognition operands, access paths and initial nested-write checks. Ordinary offsets and explicit Unicode-character conversion remain distinct. The range ends in the nested-write diagnostic signature; .1.4 resumes that implementation.
  Findings: Attached-switch body omission and duplicate-default replacement are confirmed in docs/knowledge/dart-attached-switch-body-omission.md. New repair .2.1.1 resolves validation expectations and .2.1.2 implements them after startup .3/.4/.5. Existing marker-switch facts do not cover this attached-branch extraction gap.
  Verification: Physically read both ranges in untruncated bounded outputs: 1,500 fragments / 43,988 baseline-identical bytes, pinned digest unchanged. All 45 selected tests pass. Five controls show omitted trailing calls and overwritten defaults through AST/resolver, native and SpecFile reconstruction; no emitted or other-backend claim. Diagnostic runtime/test excerpts are additional reads, not whole-file credit. Workflow, retention and rendered-book results belong to this commit.
  Commit: `DART-STARTUP-READING.1.3 - read resolver and parser; own switch body omission`

- ID: `DART-STARTUP-READING.1.4`
  Status: `done`
  Goal: Read bounded Dart group 4 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.3` committed; empty brief and clean repository.
  Scope: `dart/lib/src/action/action_parser.dart` lines 999-2498
  Baseline evidence: 1500 fragments / 42924 bytes; ordered range SHA-256 `e1ee70f3b01280be2cc974032e13c752c5596dcb86203d0b981297bab62961c1`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart AST/parser, callable-codeblock, map-leaves mutation, punctuation-light, nested-write, progressive-dispatch and staged-enrichment tests; exact range/current-delta and prior-evidence audits; all doctrines, both histories, Knowledge synchronization, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded source reading and documentation; no executable, contract or infrastructure changes.
  Comprehension: Scalar/append/nested assignment lowering; exclusive parse_job/dispatch_span carriers; bang-only bare-receiver mutation with immediate callback and ordinary parenthesized continuation; contextual codeblock candidates; strict literal staged options and flattened provenance; fixed/rest signatures; quote/regex-aware delimiter, statement, CSV and fluent scanners. The quoted/regex scanner ends mid-function at line 2498; .1.5 owns its tail. Existing mutation, staged and callable facts remain canonical.
  Findings: No additional confirmed defect. Attached-switch omission/default replacement remains pending under .2.1; this passing test selection does not close it.
  Verification: Physically read all 1,500 scoped lines in five untruncated 300-line windows, 42,924 baseline-identical bytes with pinned digest unchanged. All 79 selected existing tests pass, including their covered generated/emitted routes. Exact proof remains limited to those tests; no whole parser/scanner completion is claimed before .1.5. Workflow, retention and rendered-book results belong to this commit.
  Commit: `DART-STARTUP-READING.1.4 - read assignment, mutation and scanner parsing`

- ID: `DART-STARTUP-READING.1.5`
  Status: `done`
  Goal: Read bounded Dart group 5 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.4` committed; empty brief and clean repository.
  Scope: `dart/lib/src/action/action_parser.dart` lines 2499-2536; `dart/lib/src/action/callable_contract.dart` lines 1-331; `dart/lib/src/action/function_registry.dart` lines 1-251; `dart/lib/src/ast/spec_ast.dart` lines 1-880
  Baseline evidence: 1500 fragments / 42210 bytes; ordered range SHA-256 `83113bdbe3a1f8bd8dcd844726c74d2571cc7c40582ff8a4b070f00b8808ec72`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart spec-AST, registry, action-contract, callable, validator, staged-registry and function-definition tests; five controlled regex AST/programmatic-spec probes; exact range/current-delta and evidence retention; all doctrines, both histories, Knowledge synchronization, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change. Concrete scanner repairs remain separately gated.
  Comprehension: Complete parser scanner tail; metadata-owned final-codeblock normalization, including structural normalization within retained callable bodies; immutable ordered one-name function registry, fixed/variadic matching and descriptor versions; SpecFile/function/staged-job/rule/mode/body/edge JSON shapes. SourceSpan line fields, staged offsets and ActionIR offsets remain distinct. Spec AST helper decoding ends inside optional-integer handling at line 880; .1.6 owns its remainder.
  Findings: Grouped regex-brace action scanning and lifecycle balance failures are confirmed by five controlled probes. DART-STARTUP-READING.2.2.1/.2.2.2 own fixes after startup .3/.4/.5; startup .54.3 coordinates existing cross-backend closeout. Exact source mechanism and reproduction live in docs/knowledge/dart-regex-brace-scanner-defects.md. Switch repair .2.1 remains pending.
  Verification: Physically read all four declared ranges, 1,500 fragments / 42,210 baseline-identical bytes with pinned digest unchanged. All 55 selected tests pass. Standalone /(})/ remains a regex, its attached-if use becomes raw_perl, and programmatic SpecFile validation rejects both /}/ and /(})/ as unmatched close; ordinary-group and quoted-pattern controls execute true. The validator excerpt is diagnostic reading only; no outer collector, emitted or other-backend outcome is inferred. Workflow/retention/book proof belongs to this commit.
  Commit: `DART-STARTUP-READING.1.5 - read callable and spec state; own regex scanner defects`

- ID: `DART-STARTUP-READING.1.6`
  Status: `done`
  Goal: Read bounded Dart group 6 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.5` committed; empty brief and clean repository.
  Scope: `dart/lib/src/ast/spec_ast.dart` lines 881-949; `dart/lib/src/cli/linkedspec_dart_cli.dart` lines 1-222; `dart/lib/src/cli/primary_cli.dart` lines 1-752; `dart/lib/src/compiler/compiled_spec.dart` lines 1-457
  Baseline evidence: 1500 fragments / 43571 bytes; ordered range SHA-256 `f6457805cd2c3fae84295255bf78d288bfee4a5d51589deb0093326aa03ad9b3`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing spec-AST, compiled-state, primary-CLI and root-selection-core tests plus four selected corpus/primary process tests; seven controlled trace-level/reset adapter probes; exact range/current-delta and evidence retention; all doctrines, both histories, Knowledge synchronization, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change. Trace repair remains separately gated.
  Comprehension: Spec-AST strict optional/list/map shape decoding; separate corpus and primary CLI arguments/exits; native parse/compile/invoke composition, strict UTF-8/BOM preservation, recursive key-sorted JSON, independent trace thresholds/escaping/sinks; ordered compiled-state construction and callable normalization, entry selection precedence, structural regex-slot validation and the aggregate-selector validator prefix. Compilation invokes further validators whose bodies remain owned by .1.7; no complete compiled_spec.dart reading is claimed yet.
  Findings: Numeric trace validation accepts decimal strings that int.tryParse cannot represent; trace construction resets the selected file before conversion throws StateError. .2.3 owns the gated repair and exact seven-case evidence in docs/knowledge/dart-primary-cli-trace-overflow.md. Existing switch .2.1 and regex .2.2 remain pending.
  Verification: Physically read all four declared ranges in untruncated windows, 1,500 fragments / 43,571 baseline-identical bytes with pinned digest unchanged. Existing selected tests pass 18 + 5 + 4 = 27. Seven adapter probes isolate signed-endpoint successes, adjacent-overflow exceptions after reset and an invalid-text usage failure preserving the file. Additional test excerpts are diagnostic reading only, not EOF credit. No whole CLI matrix, process overflow or other-backend proof is claimed. Workflow/retention/rendered-book results belong to this commit.
  Commit: `DART-STARTUP-READING.1.6 - read CLI and compiler entry; own trace overflow`

- ID: `DART-STARTUP-READING.1.7`
  Status: `done`
  Goal: Read bounded Dart group 7 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.6` committed; empty brief and clean repository.
  Scope: `dart/lib/src/compiler/compiled_spec.dart` lines 458-1921; `dart/lib/src/corpus/manifest_runner.dart` lines 1-36
  Baseline evidence: 1500 fragments / 47088 bytes; ordered range SHA-256 `8b79b09c5579c7f537d325f711d546a719e5ee5051b8a7b3ff1154212faa02c3`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing compiler, nested-write, receiver-mutation, progressive/staged, recursive-observation, recognition and cursor-descriptor tests; eight controlled native/authority recognition probes with lifecycle evidence; exact range/current-delta and preservation; all doctrines, both histories, Knowledge synchronization, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change. Recognition repair remains separately gated.
  Comprehension: Complete compiler validators and serialized payload walkers; fixed-point observation/dispatch closure through explicit calls/functions; compiled rule/edge/payload/dependency metadata and descriptor projection; mode-owned bare-edge lowering, named/index slot resolution, dependency-pattern expansion, optional payload selection, final-codeblock normalization and last-definition order. Corpus reading begins only through its fixture constructor prefix at line 36.
  Findings: The neutral recognition classifier is callable and rejects binding_write but has no production caller. A recognized child can mutate a binding and rollback leaves it changed. The special observation compiler closure omits action/blind transitions, allowing Observer lifecycle execution through both routes. Eight precise controls and source mechanisms are retained in docs/knowledge/dart-recognition-effect-integration-gap.md; .2.4.1-.2.4.3 own gated contract, implementation and carrier/public closeout. Earlier .2.1-.2.3 repairs remain pending.
  Verification: Physically read compiler lines 458-1921 through EOF and corpus lines 1-36 in untruncated windows: 1,500 fragments / 47,088 baseline-identical bytes with pinned digest unchanged. All 74 selected tests pass. Eight independent probes show ordinary observation-call rejection, action/blind bypass, pure controls, write persistence after rollback and direct authority rejection. Extra runtime/test excerpts are diagnostic reading only; the eight new probes establish native/authority outcomes, with no inferred reconstructed/generated/emitted or other-backend result. Workflow/retention/book results belong to this commit.
  Commit: `DART-STARTUP-READING.1.7 - read compiler; own recognition effect bypass`

- ID: `DART-STARTUP-READING.1.8`
  Status: `done`
  Goal: Read bounded Dart group 8 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.7` committed; empty brief and clean repository.
  Scope: `dart/lib/src/corpus/manifest_runner.dart` lines 37-563; `dart/lib/src/io/spec_loader.dart` lines 1-491; `dart/lib/src/mcp/mcp_contract.dart` lines 1-9
  Baseline evidence: 1027 fragments / 29012 bytes; ordered range SHA-256 `2a53e931922db03a565eb608c63819a85c69b122c2b2e416b864b50a807845e3`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart corpus-manifest, spec-loader, primary-CLI and MCP-binding tests; exact declared source ranges/current deltas and prior evidence retention; all doctrines, both histories, Knowledge freshness, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required source reading and documentation; no executable, contract or infrastructure change.
  Comprehension: Corpus validation loads every fixture before selection, preserves named/manifest order, compares matched runtime output with [expectedJson] by structural JSON equality and records execution failures per fixture. The loader separates portable names from exact host paths, selects the first regular file across ordered direct roots, preserves strict UTF-8 text/BOM and composes staged parse/validate/compile with structured stages, source identity and balanced trace scopes. MCP credit stops at the generated format/digest prefix and JSON declaration; payload reading starts in .1.9.
  Findings: No new confirmed defect in this range. Existing corpus, loader and MCP facts retain their original evidence with dated current qualifications; prior .2.1-.2.4 repairs remain pending.
  Verification: Physically read all three declared ranges in untruncated windows: 1,027 fragments / 29,012 baseline-identical bytes with pinned digest unchanged. All 42 selected corpus, loader, primary CLI and MCP binding tests pass, including the full 105-fixture corpus and direct 14/9/4 neutral loader cases. No test/runtime/MCP payload EOF credit is inferred from these tests. Exact current-delta, prior-evidence, doctrine, history, Knowledge and rendered-book proof belongs to this commit.
  Commit: `DART-STARTUP-READING.1.8 - read corpus runner and spec loader`

- ID: `DART-STARTUP-READING.1.9`
  Status: `done`
  Goal: Read bounded Dart group 9 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.8` committed; empty brief and clean repository.
  Scope: `dart/lib/src/mcp/mcp_contract.dart` bytes 320-65855
  Baseline evidence: 1 fragments / 65536 bytes; ordered range SHA-256 `0f1840a572eb4dae75c8b885cb994bf9844681670769813b98485144628d1342`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart MCP contract binding tests and neutral contract checker; generator freshness and independent embedded contract/schema/corpus equality; exact owned byte window/current deltas and prior evidence retention; all doctrines, both histories, Knowledge freshness, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded generated-source reading and documentation; no executable, contract or infrastructure change.
  Comprehension: Raw generated JSON contains canonical discovery/list/capability/query/error frames, complete transport policy and corpus, then the schema prefix through semanticQueryRequest.page. It distinguishes semantic ok=false from tool errors and JSON-RPC errors, fixes host-only opaque handles and explicit-component lowering policy, and declares bounded framing/IDs/nesting, cancellation, EOF and output discipline. Tool schemas retain native semantic structure, closed fact keys and extensible bounded query contract IDs. .1.10 resumes the remaining schema and payloads; runtime enforcement is not inferred from data reading.
  Findings: No new confirmed defect. Existing MCP facts retain dated admission evidence; generated-file size is qualified against the current 83,214-byte file. Parked authoring APIs remain proposed.
  Verification: Physically read every owned byte in six complete UTF-8 windows: 320-6463, 6464-18751, 18752-31039, 31040-43327, 43328-55615 and 55616-65855. One initial combined output was truncated and replaced by a complete bounded reread; no missing bytes receive credit. All 65,536 bytes remain baseline-identical with pinned range digest unchanged. Four existing binding tests pass; neutral validation passes 35 frames / 10 raw inputs / 10 lifecycle cases / 76 rejected mutations; generator check is byte-fresh and independent decoded contract/schema/corpus equality passes. These whole-bundle checks grant no EOF or runtime reading credit. Workflow, retention and book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.9 - read generated MCP contract window`

- ID: `DART-STARTUP-READING.1.10`
  Status: `done`
  Goal: Read bounded Dart group 10 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.9` committed; empty brief and clean repository.
  Scope: `dart/lib/src/mcp/mcp_contract.dart` bytes 65856-83214; `dart/lib/src/mcp/mcp_contract_runtime.dart` lines 1-480; `dart/lib/src/mcp/mcp_server.dart` lines 1-1019
  Baseline evidence: 1500 fragments / 61935 bytes; ordered range SHA-256 `25354cec292d3b79780830dd1954708b52f5622be1848300a7fdb035e2cc596c`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart MCP binding and decoded dispatch tests; four direct canonical serializer controls against the neutral checker and one controlled public-dispatch query-result injection; exact source ranges/current deltas, canonical Knowledge reconciliation and prior evidence retention; all doctrines, both histories, Knowledge freshness, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded source reading and defect intake; no executable, contract or infrastructure change. Canonical JSON repair remains separately gated.
  Comprehension: Completes generated schema/payload/source-digest data and the contract runtime: digest initialization, detached frame copies, frozen schema validation, response construction and canonical serialization. Server reading covers typed policy/registry state, bounded authorization/entropy/expiry, native index registration, decoded method/error dispatch, cancellation/prepared-response state, same-error authorization checks, explicit-component lowering/projection and JSON-map helpers. _copyJson is only declared at line 1019; its body and wire transport remain .1.11.
  Findings: Default SplayTreeMap string ordering reverses U+E000/U+10000 relative to the neutral canonical byte owner, at root and nested map levels. Four helper probes plus a schema-valid query-result injection through public decoded dispatch establish the mismatch with equal JSON values. .2.5.1-.2.5.2 own portable contract/affected-route proof and repair; docs/knowledge/dart-mcp-unicode-key-order-gap.md preserves exact replay. Native-produced payload, wire, other serializers and other backends are not inferred.
  Verification: Read both remaining generated byte windows through EOF, all 480 contract-runtime lines and server lines 1-1019 in complete bounded outputs, replacing truncated combined reads. All 1,500 fragments / 61,935 bytes remain baseline-identical with pinned digest unchanged. Eleven existing binding/dispatch tests pass. ASCII/BMP controls match neutral bytes; root/nested supplementary-plane controls and injected dispatch diverge. The exact range/current-delta, retained evidence, doctrines, histories, Knowledge and rendered-book proof belongs to this commit.
  Commit: `DART-STARTUP-READING.1.10 - read MCP runtime; own Unicode key-order gap`

- ID: `DART-STARTUP-READING.1.11`
  Status: `done`
  Goal: Read bounded Dart group 11 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.10` committed; empty brief and clean repository.
  Scope: `dart/lib/src/mcp/mcp_server.dart` lines 1020-1092; `dart/lib/src/mcp/mcp_wire.dart` lines 1-683; `dart/lib/src/parser/spec_parser.dart` lines 1-744
  Baseline evidence: 1500 fragments / 39800 bytes; ordered range SHA-256 `cbec781fdd0ee92e762837ad3b13c4c958e458a052e5cb44ecab17b1166bb36c`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart MCP strict-stdio and spec-parser tests, and fourteen parsed-AST/validation/normal-compilation body-suffix controls; exact source ranges/current deltas and prior evidence retention; all doctrines, both histories, Knowledge freshness, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change.
  Comprehension: Completes detached JSON copying with ancestor-cycle, depth, finite-number and string-key checks; strict wire preflight tracks decoded duplicate keys, surrogate pairs, numeric ID token kinds, safe ranges and depth. Line framing drains overlong input, strips CR only at LF and rechecks final EOF payload size; borrowed I/O cleanup balances pending requests, flush, cancellation and shutdown. Spec parsing covers line/header/mode collection, inline/body loops, fluent continuation and element selection through regex/action/blind/lifecycle/split prefixes; .1.12 resumes at line 745.
  Findings: Both body loops silently drop @unexpected after regex or lifecycle-E elements in header/body layouts; normal validation/compilation accept all four malformed cases. Six own-line/I/edge rejection controls retain Raw and four valid controls compile. .2.6 owns repair with exact replay in docs/knowledge/dart-body-suffix-omission.md, coordinated with Rust startup .53 and existing lifecycle diagnostic precedence. The wire source has an explicit final-EOF size recheck; no new EOF runtime probe or other-backend outcome is claimed.
  Verification: Read all 73 remaining server lines, all 683 wire lines and spec-parser lines 1-744 in complete bounded outputs. All 1,500 fragments / 39,800 bytes remain baseline-identical with pinned digest unchanged. Sixteen existing strict-stdio/spec-parser tests and all fourteen pre-repair probe assertions pass. The exact range/current-delta, retained evidence, doctrines, histories, Knowledge and rendered-book proof belongs to this commit; source repairs remain gated.
  Commit: `DART-STARTUP-READING.1.11 - read wire and parser; own body suffix loss`

- ID: `DART-STARTUP-READING.1.12`
  Status: `done`
  Goal: Read bounded Dart group 12 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.11` committed; empty brief and clean repository.
  Scope: `dart/lib/src/parser/spec_parser.dart` lines 745-1567; `dart/lib/src/parser/staged_parser_registry.dart` lines 1-677
  Baseline evidence: 1500 fragments / 41630 bytes; ordered range SHA-256 `279ad70c6021662ca7bc2c67131b1b6e57ddc8770d7213cb55ecebb560c57410`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart spec-parser and staged-registry tests, and ten authored-source AST/compiler/native lexical controls; exact source ranges/current deltas and prior evidence retention; all doctrines, both histories, Knowledge freshness, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change.
  Comprehension: Completes spec-parser conditional/fluent/bare element selection, typed action selectors, blind/bare numeric indexes, allowed edge remainders, block collection, attached when/otherwise origin tracking, compact fluent completeness/extraction and lexical helpers. Staged v1 prefix defines result records, normalized sorted dispatch, fixed builtin resolve/load/compile metadata, direct parseActionBlock execution, cache-key descriptors and function-body stitch validation through failure_policy. General v2 authority has a separate owner; .1.13 resumes the remaining index/copy/equality helpers.
  Findings: Compact I.return("(") loses its argument, becomes return() and executes null/matched=false; quoted-close truncates and rejects, while braced/plain/spaced controls succeed. New .2.7 owns extraction, coordinated with Rust .52.2. Authored /}/ and /(})/ lifecycle controls also prove outer regex-brace truncation under existing .2.2.2; ordinary regex/quoted-brace controls execute true. Exact ten-case replay lives in docs/knowledge/dart-spec-lexical-boundary-defects.md. Earlier evidence remains intact; no generated/emitted or fresh other-backend outcome.
  Verification: Read spec-parser lines 745-1567 through EOF and staged registry lines 1-677 in complete bounded outputs. All 1,500 fragments / 41,630 bytes remain baseline-identical with pinned digest unchanged. Seventeen existing parser/registry tests pass; ten pre-repair assertions distinguish six successful values, one silent empty-call rewrite and three truncated/rejected payloads. Exact range/current-delta, retained evidence, doctrines, histories, Knowledge and rendered-book proof belongs to this commit; source repairs remain gated.
  Commit: `DART-STARTUP-READING.1.12 - finish spec parser; own lexical defects`

- ID: `DART-STARTUP-READING.1.13`
  Status: `done`
  Goal: Read bounded Dart group 13 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.12` committed; empty brief and clean repository.
  Scope: `dart/lib/src/parser/staged_parser_registry.dart` lines 678-761; `dart/lib/src/parser/unicode_rule_label.dart` lines 1-882; `dart/lib/src/parser/user_function_definition_parser.dart` lines 1-282; `dart/lib/src/parser/user_function_definition_shell.dart` lines 1-252
  Baseline evidence: 1500 fragments / 48522 bytes; ordered range SHA-256 `3aac67289b62a4b64af576c4fc7be021e226241b1a3b5d5a57ed0a0bf30e9a2e`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart staged registry, Unicode label identity/isolation and user-function parser/shell tests; seven body-fluent AST/validation/compiler controls; exact source ranges/current deltas, canonical Unicode table identity and prior evidence retention; all doctrines, both histories, Knowledge freshness, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required reading and evidence reconciliation; no executable, contract or infrastructure change.
  Comprehension: Completes staged v1 function-index parsing, metadata-preserving bodyAst copying, list/map/signature equality and contextual phase errors. Reads all 806 pinned Unicode ranges plus binary-search membership, nonempty complete-label validation and supplementary-safe UTF-16 prefix slicing. Completes function parser construction/execution, output-wrapper normalization, default cached parser and upward logical-spec lookup. Shell prefix covers projection/trace/error boundaries, definition node dispatch and fixed/typed-v1 versus variadic-v2 parameter metadata; .1.14 resumes arity/body/sidecar projection at line 253.
  Findings: Seven targeted controls establish standalone body-fluent suffix loss: .Töp() becomes T; .Top-Rule() and .Top() @unexpected match the accepted .Top() AST and compile. Own-line/no-ASCII-prefix controls retain Raw and reject. Existing .2.6 now owns the fluent adapter's hardcoded empty remainder before the already-owned body-loop loss. Exact replay is in docs/knowledge/dart-body-fluent-suffix-loss.md. The generated Unicode authority passes; no runtime invocation or fresh other-backend behavior is inferred from these seven probes.
  Verification: Read staged registry 678-761, all 882 Unicode classifier lines, all 282 function-parser lines and shell 1-252 in complete bounded outputs. All 1,500 fragments / 48,522 bytes remain baseline-identical with pinned digest unchanged. Twenty-five selected tests pass, including Unicode emitted execution; neutral regeneration passes 806 ranges, nine positive/eight negative fixtures and two distinct pairs. All seven pre-repair probe assertions pass. Exact range/current-delta, retained evidence, doctrines, histories, Knowledge and rendered-book proof belongs to this commit; repairs remain gated.
  Commit: `DART-STARTUP-READING.1.13 - read Unicode and function bridge; own fluent suffix loss`

- ID: `DART-STARTUP-READING.1.14`
  Status: `done`
  Goal: Read bounded Dart group 14 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.13` committed; empty brief and clean repository.
  Scope: `dart/lib/src/parser/user_function_definition_shell.dart` lines 253-1006; `dart/lib/src/runtime/bounded_child_parse_authority.dart` lines 1-746
  Baseline evidence: 1500 fragments / 44607 bytes; ordered range SHA-256 `0b7f74ece3a18212c310d4d07fcbd1c737cc20f0e1ba63fa7c49c45705b4e4b1`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart function-shell/parser/staged-registry, dormant progressive authority and admitted progressive carrier consumers; exact source ranges/current deltas and prior evidence retention; all doctrines, both histories, Knowledge freshness, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change.
  Comprehension: Completes shell arity, scalar text/span containment, sidecar kind/name/signature/text/span/policy checks, deterministic parent/job normalization, nonoverlapping source stripping preserving CR/LF, strict variadic signature fields and typed declaration errors. Function SourceSpan retains line fields; scalar body spans remain in sidecars. Bounded authority prefix covers immutable registry/configuration, host-only fresh execution seed, shared cancellation identity, defensive arguments and callback-scoped source view. View operations rebase local scalar positions/spans/diagnostics, enforce offset and diagnostic byte bounds, and guard retained nested requests against expiry. Invocation setup validates decoded sources, limits and active-chain spans; .1.15 resumes constructor state and the actual dispatch algorithm.
  Findings: No new confirmed defect in this owned range. Shell validation and private authority evidence remain bounded to the inspected source and selected consumers; .2.1-.2.7 repairs and parked authoring proposals retain their owners.
  Verification: Read shell 253-1006 through EOF and authority 1-746 in complete bounded outputs. All 1,500 fragments / 44,607 bytes remain baseline-identical with the pinned range digest. Twenty-four selected tests pass, including four authority groups and seven admitted carrier groups with independently analyzed/executed emitted Dart source. Exact range/current-delta, retained evidence, doctrines, histories, Knowledge and rendered-book proof belongs to this commit; no fresh complete-backend/all-runtime gate is inferred.
  Commit: `DART-STARTUP-READING.1.14 - finish function projection and read bounded authority`

- ID: `DART-STARTUP-READING.1.15`
  Status: `done`
  Goal: Read bounded Dart group 15 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.14` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/bounded_child_parse_authority.dart` lines 747-1504; `dart/lib/src/runtime/generated_plan.dart` lines 1-68; `dart/lib/src/runtime/interpreter.dart` lines 1-674
  Baseline evidence: 1500 fragments / 45477 bytes; ordered range SHA-256 `0a7059216664bb263dfa5684aebe8ad64a2769a48daf82180f825023cee8e587`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing progressive authority/carrier, runtime interpreter, rule-local cursor and source-emitter consumers; neutral progressive checker and ten private-authority controls; exact ranges/current deltas and prior evidence retention; all doctrines, both histories, Knowledge freshness, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change.
  Comprehension: Completes bounded dispatch identity/span/transaction/registry/top-rule checks, capability/policy intersections, ceiling minima, shared token/deadline/call/depth accounting, repeated-span decrease, pre-charge, callback cleanup and result detachment. Reads generated families and their derived seek/consume/blind policy plus ordered row equality. Interpreter prefix covers typed diagnostics/results, compiled-state and entry validation, fresh execution context, leading-trivia skip, staged result completion, observer/sink error boundaries and rule-entry recursion/register/binding/recognition setup. .1.16 begins rule execution at line 675.
  Findings: Ten private-authority controls distinguish enforced direct Dart cost/result/diagnostic bounds from missing inherited nested limits. A child reporting zero remaining steps still nests; supplied wider grants regain extra capability and max_steps/result_nodes 100. Existing startup .37.1 owns budget/grant inheritance; .37.2 owns the separate source-detail/diagnostic observations. Exact replay lives in docs/knowledge/dart-progressive-nested-authority-gap.md. No new repair ID or executable change.
  Verification: Read authority 747-1504 and generated plan 1-68 through EOF, plus interpreter 1-674, in complete bounded outputs. All 1,500 fragments / 45,477 bytes remain baseline-identical with pinned digest. Eighty-two selected Dart tests and neutral 9/9/116/public60 checks pass; existing emitted-source consumers execute. All ten exact pre-repair assertions pass through private callbacks; no authored/emitted/other-backend reproduction of the new gap is inferred. Exact ranges, retained evidence, doctrines, histories, Knowledge and rendered-book proof belongs to this commit.
  Commit: `DART-STARTUP-READING.1.15 - read dispatch and runtime; own nested authority gap`

- ID: `DART-STARTUP-READING.1.16`
  Status: `done`
  Goal: Read bounded Dart group 16 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.15` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 675-2174
  Baseline evidence: 1500 fragments / 43183 bytes; ordered range SHA-256 `8f0321e727ef887a325ffc9316ba3d84943f99e8876f52a10940a4f4adcd676a`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart interpreter/cursor, recognition/recursive observation, gap/repeated-result/slot and semantic observer consumers; six public native observer failure controls; exact ranges/current deltas and prior evidence retention; all doctrines, both histories, Knowledge freshness, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change.
  Comprehension: Rule execution handles initialization, blind/regex dispatch, return/error capture and nested recognition/binding/register cleanup. Blind AND retains implicit ordered child values; repetition owns lifecycle order and progress/min/max handling. Capture-enabled regex repetition installs a candidate before LS and commits the post-LE cursor before IT, while unflagged order stays unchanged. Selected slot identity drives trace/semantic events, action edges dispatch once and repeated explicit values are collected. Lifecycle I pre-registers owned bindings. Action statements distinguish attached/marker if/switch and attached while; value-block flow begins here and continues at .1.17.
  Findings: Six public native controls confirm semantic observer failure identity loss only when a selected-slot callback unwinds through an explicit action child call. Direct/blind/final-result controls preserve the original object/stack; a successful call returns ok. _executeActionBlock translates the private semantic failure wrapper before _parse can restore it. New .2.8 owns gated passthrough and carrier/trace cleanup proof; exact replay is in docs/knowledge/dart-semantic-observer-action-failure-wrapping.md. Existing .2.1 switch and .2.4 effect defects remain owned.
  Verification: Read interpreter 675-2174 in six complete 250-line outputs. All 1,500 fragments / 43,183 bytes remain baseline-identical with pinned digest unchanged. One hundred selected tests pass, including existing emitted gap/recognition/semantic consumers and the gap primary route. All six exact pre-repair observer assertions pass via public native parse. No fresh emitted/other-backend reproduction of the new defect is inferred. Exact ranges, retained evidence, doctrines, histories, Knowledge and rendered-book proof belongs to this commit.
  Commit: `DART-STARTUP-READING.1.16 - read rule execution; own observer error wrapping`

- ID: `DART-STARTUP-READING.1.17`
  Status: `done`
  Goal: Read bounded Dart group 17 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.16` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 2175-3674
  Baseline evidence: 1500 fragments / 40984 bytes; ordered range SHA-256 `481c979fa65c5cbb5e3b55b57950c4821a34d76ba4f9807361e0e3900b1337f9`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart interpreter/ActionIR/callable/binding/write/mutation consumers; ten typed-AST/contract/native/SpecFile-JSON mixed-control probes; exact ranges/current deltas and prior evidence retention; all doctrines, both histories, Knowledge freshness, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change.
  Comprehension: Value execution intercepts direct local returns, selects marker ranges with nesting-aware boundaries and handles attached value if/while/switch separately. Inline controls evaluate selected branches lazily. Helper/receiver with and tree callbacks use copied values and finally-restored bindings; hash traversal sorts keys and recurses into maps, array traversal recurses into lists, with the other aggregate treated as a leaf. Expression dispatch preserves literal/aggregate values, cached typed codeblocks, named writes and read paths, and delegates recognition/staged/progressive authority. The range ends inside observe-recognition child execution; .1.18 continues it.
  Findings: Ten typed-AST/contract/native/SpecFile-JSON controls confirm that _executeValueStatementRange sends attached controls into the action executor: four nested cases escape the value block and return from the surrounding rule. A single-statement attached-if adapter also loses sibling else, yielding the tail instead. Five direct/marker-only/attached-only controls retain local return; all diagnostics are empty. New .2.9 owns value-aware dispatch, mixed nesting and carrier proof; exact replay is in docs/knowledge/dart-mixed-control-value-block-gap.md. Earlier repairs remain intact.
  Verification: Read interpreter 2175-3674 in six complete 250-line outputs. All 1,500 fragments / 40,984 bytes remain baseline-identical with pinned digest unchanged. All 124 selected tests pass, including their emitted and CLI consumers. Ten exact pre-repair probes pass for native and SpecFile reconstruction; no generated/emitted or other-backend defect outcome is inferred. Exact ranges, retained evidence, doctrines, histories, Knowledge and rendered-book proof belongs to this commit.
  Commit: `DART-STARTUP-READING.1.17 - read value execution; own mixed control gap`

- ID: `DART-STARTUP-READING.1.18`
  Status: `done`
  Goal: Read bounded Dart group 18 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.17` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 3675-5174
  Baseline evidence: 1500 fragments / 45330 bytes; ordered range SHA-256 `f406ef9dc15561cb17edf029f5c24ecefffe483fa9508ac0046337ce4d28726f`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart interpreter/callable/variadic/mutation/observation/source/logical/diagnostic consumers; nine native/SpecFile-JSON callback identity controls; exact ranges/current deltas and prior evidence retention; all doctrines, both histories, Knowledge freshness, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change.
  Comprehension: Observation completion binds the record before returning or rethrowing. Receiver mutation validates the binding/root kind, snapshots original shape, guards identity during copied/restored callback traversal, commits once and releases before continuation. Helper dispatch separates statement mutations, registered functions, logical arity, lazy controls, typed capture/position/cursor projections, diagnostic sinks and bound-codeblock fallback. Codeblocks evaluate arguments, reject arity/cycles and restore temporary parameters; functions use fresh local stores and restore caller stores. Receiver helpers preserve special with/tree/coalesce/split dispatch. The range ends at _callSet; .1.19 continues helper implementations.
  Findings: Nine native/SpecFile-JSON controls confirm four false recursion rejections for distinct nested with/map_leaves callbacks and wrong with identity/cycle for real helper-mediated cb recursion. Three successful single/sequential/different-helper controls and direct cb recursion distinguish the defect. _executeCodeblockValue keys its active list by the supplied name, while helper/receiver/tree callers supply helper names. New .2.10 owns callback identity and exact real-cycle/carrier proof; Lua's existing fact is comparison evidence only. Existing .2.4/.2.8/.2.9 and other repairs remain intact.
  Verification: Read interpreter 3675-5174 in six complete 250-line outputs. All 1,500 fragments / 45,330 bytes remain baseline-identical with pinned digest unchanged. All 140 selected tests pass, including existing emitted and CLI consumers. Nine exact pre-repair native/reconstructed controls pass; no new generated/emitted or other-backend defect result is inferred. Exact ranges, retained evidence, doctrines, histories, Knowledge and rendered-book proof belongs to this commit.
  Commit: `DART-STARTUP-READING.1.18 - read helper dispatch; own callback identity gap`

- ID: `DART-STARTUP-READING.1.19`
  Status: `done`
  Goal: Read bounded Dart group 19 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.18` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 5175-6674
  Baseline evidence: 1500 fragments / 43446 bytes; ordered range SHA-256 `6773e512221317f9ae4d6328c1b6e5ac2637b40deb6df0354011c5848b64b768`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart interpreter/binding/source/logical/diagnostic/mutation consumers; nine native/SpecFile-JSON hash controls and nine Perl facade/generated-source comparisons; exact ranges/current deltas and prior evidence retention; all doctrines, both histories, Knowledge freshness, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change.
  Comprehension: Explicit writes and helper mutations guard identity before evaluating operands; push distinguishes implicit edge/rule accumulators from explicit targets. Array construction expands explicit splice values while hash construction pairs raw arguments before a map-only merge. Diagnostic/logical arity checks precede effects; fluent receiver dispatch selects copied typed views. Split/substitution/end mutations rebind only their documented statement shapes. Capture helpers project through source authority, update marks/cursors only after successful projection, and boundary capture selects the earliest valid target match. Eager logical arguments differ from lazy coalesce. The range ends inside passive action-child tracing; .1.20 finishes dispatch and begins supporting value helpers.
  Findings: Nine Dart native/reconstructed controls and nine source-backed Perl comparisons establish constructor splice pairing/order loss. Leading/middle map splices create container-text keys and lose fields; late map merging defeats authored duplicate order; flat_array is not recognized as a hash splice. Perl's flat_array control succeeds, while six map forms lower to its already-owned unsupported hash sentinel. New .2.11.1-.2.11.3 own Dart contract reconciliation, repair and carrier/public proof alongside FUTURE-PARITY-BACKLOG.5, which also already owns the three dropped array-transform rebindings seen here.
  Verification: Read interpreter 5175-6674 in six complete 250-line outputs. All 1,500 fragments / 43,446 bytes remain baseline-identical with pinned digest unchanged. All 122 selected tests pass, including existing emitted and CLI consumers. Nine exact native/reconstructed outputs and nine Perl facade/source comparisons pass; new Dart emitted or other-backend results are not inferred. The splice-classifier diagnostic excerpt beyond 6674 adds no whole-file reading credit. Exact ranges, retained evidence, doctrines, histories, Knowledge and rendered-book proof belongs to this commit.
  Commit: `DART-STARTUP-READING.1.19 - read helper implementations; own hash splice pairing`

- ID: `DART-STARTUP-READING.1.20`
  Status: `done`
  Goal: Read bounded Dart group 20 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.19` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 6675-8174
  Baseline evidence: 1500 fragments / 41244 bytes; ordered range SHA-256 `d782685b64732f0f5b9e4c2ad7602a6dd5a5bb86c4d04d113ede296f2c8695a5`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Existing Dart interpreter/contracts/binding/source/recognition/observation/gap/scalar-text consumers; neutral numeric 55-case authority; eleven number, eight Unicode-order and six slice controls through native/SpecFile-JSON and Perl facade/generated source; exact ranges/current deltas and prior retention; all doctrines, both histories, Knowledge freshness, mdBook rendering and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change.
  Comprehension: Complete action-child dispatch and splice classifiers, pure/array/hash helper families, copied selection and key transforms, scalar conversion/predicates and rune-based substring/split behavior. Numeric helpers enforce strict finite decimal inputs, arities and invalid-null policy, then delegate arithmetic and integral normalization to host num operations. Runtime context initializes source, progressive, staged and recognition authorities; invocation frames snapshot/restore marks, retain original errors during cleanup and record accepted/failed/aborted/rejected observations. The range ends after noteRecognitionMatch; .1.21 continues context/frame and binding machinery.
  Findings: Eleven paired number cases show six sign/magnitude corruptions with five controls (.2.12); eight Unicode cases show five lexical-order differences with three controls (.2.13); six slice cases show two wrapped end-overflow RangeErrors with four controls (.2.14). Every case has native/SpecFile-JSON plus Perl Get/generated-source evidence. Existing startup .55/.60, MCP .2.5 and FUTURE-PARITY-BACKLOG.5 retain disjoint numeric/text, slice, canonical-order and helper-caveat ownership. No runtime repair or fresh Dart emitted defect result is claimed.
  Verification: Read interpreter 6675-8174 in six complete 250-line outputs: 1,500 fragments / 41,244 baseline-identical bytes with unchanged digest. The corrected complete selection passes 111 tests, including exact scalar-numeric/text fixtures and existing emitted/CLI consumers; the initial command misspelled the gap test filename, then the actual gap test passed separately before final selection. Neutral numeric proof passes 55 cases / 18 helpers. Exact pre-repair 11/8/6 case assertions, source-backed Perl comparisons, range/retention audits, doctrines, histories, Knowledge and rendered-book evidence belong to this commit.
  Commit: `DART-STARTUP-READING.1.20 - read value helpers; own numeric order and slice gaps`

- ID: `DART-STARTUP-READING.1.21`
  Status: `done`
  Goal: Read bounded Dart group 21 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.20` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 8175-9674
  Baseline evidence: 1500 fragments / 39933 bytes; ordered range SHA-256 `39c0601fbb75a0036aca7ac6561644e83545c0b6a25617a053ddd6a49e4b2cf7`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: 124 interpreter/binding/source/recognition/observation/gap/write/mutation tests plus six ActionIR contract tests; nine native/SpecFile-JSON and Perl Get/generated-source controls; exact ranges/current deltas, prior retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change.
  Comprehension: Gap candidates/entry slots and recursive observations use recognition/source authorities; observation writes are guarded by their expression caller before child execution. Recognition checkpoints copy state, commit accepted state and rollback cursor/boundary/marks. Typed position/span/materialization projections convert SourceLocationException to absence. Binding identities distinguish visible stores from active mutation guards; rule-local first-write snapshots, callback scopes and whole-store snapshots restore copied values and identities. Cursor anchors validate source boundaries; binding views preserve absence/kind, copy aggregates and keep legacy stores distinct. The range ends inside legacy _assignHashIndex; .1.22 finishes interpreter helpers then starts matching.dart.
  Findings: Nine exact paired controls show two typed input-slice overflow nulls, six successful controls and one zero-argument discrepancy. Existing .2.14 now owns typed-source clipping alongside array/substr overflow; new .2.15 owns documented two-argument arity and early rejection, coordinated with FUTURE-PARITY-BACKLOG.5. The suspected observation binding guard bypass is ruled out by the caller's _assertReceiverMutationWritable at 3664. No source repair or fresh Dart emitted defect proof is claimed.
  Verification: Read interpreter 8175-9674 in six complete 250-line outputs: 1,500 fragments / 39,933 baseline-identical bytes with unchanged digest. All 124 selected tests and six contract tests pass, including existing emitted/CLI consumers. Nine exact native/reconstructed and Perl facade/source assertions retain values, matched/cursor, helper diagnostics and the zero-argument Perl handler context. Range/retention audits, doctrines, histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.21 - read context bindings; own input slice boundaries`

- ID: `DART-STARTUP-READING.1.22`
  Status: `done`
  Goal: Read bounded Dart group 22 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.21` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 9675-10274; `dart/lib/src/runtime/matching.dart` lines 1-900
  Baseline evidence: 1500 fragments / 42836 bytes; ordered range SHA-256 `2bb30b2905fecc8005a1de903fa1c7d3f1f15f876f4eb7d4590cb943c25056b9`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: 132 interpreter/matcher/write/mutation/callable/staged/slot/self-hosted Unicode tests and the 31-case structural corpus window; exact ranges/current deltas, prior retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading/reconciliation; no executable, contract or infrastructure change.
  Comprehension: Finish legacy hash-index mutation, identity guard diagnostics, typed nested-write evaluation/classification/copy/atomic publish, callable record decoding and detached aggregate helpers. Nested writes evaluate all selectors and RHS before reading the root and create only missing dense containers, retaining structural diagnostics and completed expression effects. Matching compiles authored alternatives separately, retains whole and compact participating captures plus original group indexes/options, and projects code-unit boundaries to scalar/line locations. Staged capture recovery lazily instruments named suffix probes and caches only whole-match/text-proven ranges; numeric backreferences and unprovable instrumentation return absence. Structural pattern dispatch recognizes bounded shipped families, derives Unicode rule-label atoms and retains regex options. The range ends inside _matchEbnfReturnScalar; .1.23 completes matching then begins recognition_transaction.dart.
  Findings: No new defect is established. Existing write-vivification, callable-literal, staged-provenance and bounded structural-PCRE cards match the read mechanisms. Numeric index conversion inventory remains .2.12; input slicing .2.14/.2.15 and all earlier owners stay pending. Bounded structural matchers do not imply general PCRE support; no fresh cross-backend comparison or repaired behavior is claimed.
  Verification: Read interpreter 9675-10274 through EOF and matching 1-900 in five complete 300-line windows: 1,500 fragments / 42,836 baseline-identical bytes with unchanged digest. All 132 selected tests pass, including generated/emitted/CLI consumers and staged four-route admission; the shipped structural corpus window passes 31/31. Exact range/retention audits, doctrines, histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.22 - finish interpreter; read matching and provenance`

- ID: `DART-STARTUP-READING.1.23`
  Status: `done`
  Goal: Read bounded Dart group 23 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.22` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/matching.dart` lines 901-1917; `dart/lib/src/runtime/recognition_transaction.dart` lines 1-483
  Baseline evidence: 1500 fragments / 41162 bytes; ordered range SHA-256 `b8c607a80450ab598246cff0a98def4fa05b730b63509fbfabb57587ee3d090d`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: 99 matcher/interpreter/recognition/observation/gap/self-hosted/source tests; six public-alternation/native/SpecFile-JSON and Perl regex/Get/source controls; exact ranges/current deltas, prior retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no executable, contract or infrastructure change.
  Comprehension: Complete structural block/fluent/function/EBNF matching, immutable match/register handoff, scalar offset and line/column projections, earliest-start/authored-order seek choice, dialect normalization and bounded lexical helpers. Structural codeblocks balance quotes/braces; physical-line surfaces require suffix closure. Normalization lifts supported inline flags, maps POSIX classes, named captures and lower bounds, and removes possessive markers. Recognition begins with private detached frame state, typed diagnostics, opaque token/frame wrappers, authority/source/lineage identities and gap snapshots. Invocation entry accepts only a matching active parent gap slot; leave requires stack order and restores/invalidates an unfinished token before terminal-required rejection. .1.24 continues state synchronization and remaining authority methods.
  Findings: Six exact controls prove lower-unbounded quantifier normalization rewrites escaped literal braces and character-class text: three parser-level literal corruptions and three agreements, including actual quantifier support. New .2.16 owns lexical normalization and carriers. Existing regex-brace scanners .2.2/startup .54 and disconnected recognition effect enforcement .2.4 remain distinct. No repair or fresh Dart emitted defect proof is claimed.
  Verification: Read matching 901-1917 through EOF and recognition_transaction 1-483 in full bounded outputs: 1,500 fragments / 41,162 baseline-identical bytes with unchanged digest. All 99 selected tests pass, including existing emitted/CLI consumers. Final six-case probe uses public RuntimeRegexAlternation after correcting an initial harness call to internal compileRuntimeRegex; raw host, exact normalized pattern, native/reconstructed results and two Perl generated-pattern occurrences are asserted. Range/retention audits, doctrines, histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.23 - finish matching; own regex literal normalization`

- ID: `DART-STARTUP-READING.1.24`
  Status: `done`
  Goal: Read bounded Dart group 24 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.23` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/recognition_transaction.dart` lines 484-965; `dart/lib/src/runtime/semantic_observation.dart` lines 1-113; `dart/lib/src/runtime/source_location.dart` lines 1-599; `dart/lib/src/runtime/staged_ast_enrichment.dart` lines 1-306
  Baseline evidence: 1500 fragments / 48312 bytes; ordered range SHA-256 `a09f9b09d23941bc183e07f9407082cdcd58bf093f1687190fff3e4c691d2725`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: 58 recognition/recursive-observation/gap/typed-source/semantic-index/staged tests; exact draft engineering-history rollover/source/manifest proof and restoration; exact ranges/current deltas, prior retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading/reconciliation and a Knowledge link correction; no executable, contract or infrastructure change; .5 is a capacity proposal only.
  Comprehension: Finish source-local recognition frame/gap synchronization, candidate/commit/tail transitions and detached entry slots. Checkpoint rejects any active stack token after restoration; attempts distinguish match presence from payload, terminal operations enforce exact attempt count, and misuse restores state before invalidation. Effect classification computes a recursive fixed point but its known production integration gap remains .2.4. Semantic observations detach two event kinds, hash UTF-8 input identity and use a synchronous optional sink; immutable derivation validates retained observations separately. Typed source uses private authority/source/scalar identities, exact code-unit boundary lookup, Unicode line/column/UTF-8 tables and ordered concatenation with owned-span validation. Staged entry definitions deep-own reusable snapshots/options, validate frozen registries, create fresh per-execution authority/cache and reject expired recursive contexts. .1.25 continues staged execution from line 307.
  Findings: No new runtime defect is established. Mandatory engineering-history draft rollover exposes two exhausted count controls; .5 owns the exact unapproved proposal. A concise new record preserves this completed slice within current limits, leaving 50 bytes below rollover; full comprehension stays here and in linked cards. Existing recognition .2.4, semantic wrapper .2.8, numeric .2.12 and typed input_slice .2.14/.2.15 owners retain their evidence. Correct the recognition card's nonexistent Dart source-location link to the existing typed-source rollout authority; prior dated facts remain unchanged. Private source authority validation does not repair input_slice arithmetic or admit a parser-builder API.
  Verification: Read recognition 484-965 through EOF, semantic_observation 1-113 through EOF, source_location 1-599 through EOF and staged_ast_enrichment 1-306 in full bounded outputs: 1,500 fragments / 48,312 baseline-identical bytes with unchanged digest. All 58 selected tests pass, including the existing gap primary and staged carrier consumers. The draft archive exactly preserves clean source lines 249-447 (199 lines / 31,079 bytes); routing rejects only files 27/26 and manifest lines 26/25. After verified restoration of only this uncommitted rollover, every old history byte remains unchanged and the root is 453 lines / 58,932 bytes. Range/retention audits, doctrines, histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.24 - finish recognition and source authority reading`

- ID: `DART-STARTUP-READING.1.25`
  Status: `done`
  Goal: Read bounded Dart group 25 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.24` committed; empty brief and clean repository.
  Activation: Clean `9c644ecb6de2dd2009f886f3fd0342dfc1c82947` after canonical containment .9; root status empty and brief zero bytes.
  Scope: `dart/lib/src/runtime/staged_ast_enrichment.dart` lines 307-1806
  Baseline evidence: 1500 fragments / 47254 bytes; ordered range SHA-256 `bf43c5c6f0b58628cc87531c45964101688d5d41528c3d4f7c0234980573a40f`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: 44 staged-AST, registry, progressive, typed-source and matching direct-dependent tests; exact owned range/current deltas, prior evidence retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading and documentation; no source, public contract or infrastructure changes.
  Comprehension: Execution state consumes completion before dispatch, rejects live recognition transactions and sanitizes outcome-sink failures. Frozen snapshots require exact opaque callback bindings and replace logical callback names before hashing. Resolution rejects alias/relative collisions and ambiguities, then uses ordered frozen roots/providers without loading. Effective authority checks versions/top, intersects capabilities/policies and narrows all ceilings; cache keys normalize the eight identity fields and cache callbacks only. Both schedulers prepare and reserve a complete depth before callbacks. Recursive dispatch checks shared resources, expires callback contexts on return/throw, detaches and node-bounds success, settles bounded failures, and queues returned markers with their full lineage for the next depth. This range ends after the per-plan recursive loop; .1.26 resumes its return and resource/projection helpers.
  Findings: No new confirmed defect in this range. The compatible one-depth API and production recursive authority remain distinct; reading does not admit dynamic loading, parser builders or a new serialization route. Existing Dart .2.1-.2.16 and startup owners retain their evidence.
  Verification: Physically read staged_ast_enrichment.dart 307-1806 in six complete, untruncated 250-line outputs: 1,500 fragments / 47,254 baseline-identical bytes with unchanged ordered digest. All 44 selected tests pass, including exact recursive predicates, breadth-first execution, shared bounds, diagnostic rebasing and existing four-route carrier proof. Full plan reconstruction retains 115 paths / 169 ranges / all 55 child bounds. Prior-record retention, doctrines, both histories, Knowledge and rendered-book results belong to this commit.
  Commit: `DART-STARTUP-READING.1.25 - read frozen staged registry and recursive dispatch`

- ID: `DART-STARTUP-READING.1.26`
  Status: `done`
  Goal: Read bounded Dart group 26 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.25` committed; empty brief and clean repository.
  Activation: Clean `692c5363e2dbdde7def2e8b3697aa65fac737858`; root status empty, brief zero bytes, and prior commit jobs consumed.
  Scope: `dart/lib/src/runtime/staged_ast_enrichment.dart` lines 1807-3306
  Baseline evidence: 1500 fragments / 43782 bytes; ordered range SHA-256 `66adc3328ccd2542542f637e13a637bf485b6c47c53e16fcbf39d39f430aaf3c`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: 44 staged-AST, registry, progressive, typed-source and matching direct-dependent tests; exact owned range/current deltas, prior evidence retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading and documentation; no source, public contract or infrastructure changes.
  Comprehension: Resource admission sanitizes cancellation/clock callbacks, rechecks post-callback authority and spends shared/job steps only after validation. Failure policies copy portable diagnostics and settle fail/text/node outcomes; local source positions/spans rebase through ordered scalar provenance, with invalid local ranges explicitly marked. Returned markers retain full lineage and mapped stitch paths; recurrence requires exact tuple uniqueness and strictly smaller contained source extent. Plain detachment rejects live/cyclic/nonfinite values under node bounds. Marker discovery, exact-target matching and result-policy stitching are separate validations. Typed path/canonical JSON ordering uses Unicode scalars; snapshot helpers enforce positive ceilings and immutable ordered candidates. The range ends after _deepEqual's Map branch; .1.27 owns the final 15 lines before EOF.
  Findings: Eleven exact private recursive scheduler controls confirm two defects: tiny positive diagnostic allowances retain fallback records larger than their remaining ceiling, including a second sentinel at zero (.2.17); a seeded exhausted signed-maximum call counter wraps and admits a callback (.2.18). Seven boundary/ordinary controls remain valid. Both repairs are decomposed, gated and reproduced in docs/knowledge/dart-staged-resource-boundary-gaps.md. No other-backend or fresh production-carrier defect proof is claimed; prior findings remain intact.
  Verification: Physically read staged_ast_enrichment.dart 1807-3306 in six complete untruncated 250-line windows: 1,500 fragments / 43,782 baseline-identical bytes with unchanged ordered digest. All 44 selected tests pass; neutral governance passes 123 semantic/129 public mutations. The durable generator and independent byte/callback/counter assertions reproduce all eleven controls. Full 115-path/169-range/55-child reconstruction, prior-record retention, doctrines, both histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.26 - own staged diagnostic and call-counter boundary gaps`

- ID: `DART-STARTUP-READING.1.27`
  Status: `done`
  Goal: Read bounded Dart group 27 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.26` committed; empty brief and clean repository.
  Activation: Clean `2b8b4bd7dc29f0915e804b9aaf99c70603daf305`; root status empty, brief zero bytes, and prior commit jobs consumed.
  Scope: `dart/lib/src/runtime/staged_ast_enrichment.dart` lines 3307-3321; `dart/lib/src/runtime/staged_parse_job.dart` lines 1-296; `dart/lib/src/runtime/unicode_case_mapping.dart` lines 1-1189
  Baseline evidence: 1500 fragments / 39481 bytes; ordered range SHA-256 `2836d0a3697feb9ee846814088e1568659dff5ca55cf22e0e63a4bcb4ddc3943`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: 33 staged-AST, typed-source, matching, scalar-text and Unicode casing tests; seventeen private/neutral provenance controls and generated Unicode byte/12-fixture proof; exact owned range/current deltas, prior evidence retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading and documentation; no source, public contract or infrastructure changes.
  Comprehension: Final staged-enrichment helpers compare scalar values and ordered string lists, completing that module. staged_parse_job.dart validates exact direct/derived record keys, materializes caller-authorized scalar spans, maps live entry/local match and capture code-unit ranges through SourceAuthority, and returns detached inert v2 marker/sidecar data. Source failures receive stable declaration code/phase/origin. The direct helper incorrectly promotes diagnostic fallback strings before validating original source/provenance types; derived segments reuse it. Generated Unicode 17 data is pinned to its contract/digest and read through lower-map U+A7A0, including dotted-I expansion and deliberate Greek/Latin identity entries. Remaining tables and the evaluator remain .1.28/.1.29 reading.
  Findings: Seventeen private validator cases compared with the existing neutral evaluator establish six malformed acceptances and eleven agreeing controls. Null/integer/object provenance becomes `<invalid>`; null/integer source_id selects an existing `<runtime>` source; derived segments repeat the coercion. Literal placeholder strings remain valid controls. DART-STARTUP-READING.2.19 and two children own strict original-type validation and actual-entrypoint/carrier proof; existing .2.1-.2.18 and startup evidence remains intact. No ordinary authored or other-backend runtime failure is inferred.
  Verification: Read staged enrichment 3307-3321 and staged_parse_job 1-296 through EOF plus Unicode case mapping 1-1189 in complete untruncated outputs: 1,500 fragments / 39,481 baseline-identical bytes with unchanged ordered digest. All 33 selected tests pass, including twelve Unicode fixtures through direct/helper/receiver/array paths and existing staged four-route proof. Unicode regeneration byte-compares the neutral artifact and all five modules and passes twelve neutral fixtures. The durable seventeen-case recipe/independent evaluator check, exact 115-path/169-range/55-child coverage, prior-record retention, doctrines, both histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.27 - read staged declarations and own provenance type gap`

- ID: `DART-STARTUP-READING.1.28`
  Status: `done`
  Goal: Read bounded Dart group 28 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.27` committed; empty brief and clean repository.
  Activation: Clean `dfc57ce191d4191b1d7e4fb957756bf35d63971b`; root status empty, brief zero bytes, and prior commit jobs consumed.
  Scope: `dart/lib/src/runtime/unicode_case_mapping.dart` lines 1190-2689
  Baseline evidence: 1500 fragments / 38936 bytes; ordered range SHA-256 `d3624127d86fe475310802502f59b8ef5c8d3cd1ef6f3d187603038f4d994e1c`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Managed Unicode contract regeneration and twelve independent neutral fixtures; retain .1.27 Dart execution proof by exact source identity; exact owned range/current deltas, prior evidence retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded generated-table reading and documentation; no source, public contract or infrastructure changes.
  Comprehension: The remaining lower table preserves fullwidth/supplementary mappings and deliberate ligature identities, ending at U+1E921. The upper table begins at ASCII and is read through U+A76F. Full mappings include sharp-s to SS, U+0149 to 02BC 004E, ordered Greek base/combining expansions, and shared uppercase targets for both lowercase sigma forms. These fixed sequences are full casing data, not reversible conversion, case folding or normalization. The remaining upper table, contextual property ranges and evaluator belong to .1.29; the previously documented Final Sigma evaluator is not replaced by the ordinary sigma table entry.
  Findings: No new confirmed defect in this generated-data range. All prior Dart .2.1-.2.19 and startup repairs retain their exact evidence and gates. The generator remains the sole author; no Unicode input, generated module, contract or runtime behavior changed.
  Verification: Physically read unicode_case_mapping.dart 1190-2689 in six complete untruncated 250-line outputs: 1,500 fragments / 38,936 baseline-identical bytes with unchanged ordered digest. Fresh managed checking regenerates the neutral artifact and all five backend modules byte-identically and passes twelve independent fixtures, retaining 1563/1581 mappings and 158/464 property ranges. The 33-test Dart execution and seventeen provenance controls remain dated .1.27/dfc57ce1 evidence, with exact source identity retained; no duplicate fresh runtime claim is made. Full 115-path/169-range/55-child reconstruction, prior-record retention, doctrines, both histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.28 - read Unicode lower completion and upper mappings`

- ID: `DART-STARTUP-READING.1.29`
  Status: `done`
  Goal: Read bounded Dart group 29 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.28` committed; empty brief and clean repository.
  Activation: Clean `17341bbe0b8822b1130bd346e3b966089786b68a`; root status empty, brief zero bytes, and prior commit jobs consumed.
  Scope: `dart/lib/src/runtime/unicode_case_mapping.dart` lines 2690-3835; `dart/lib/src/scaffold.dart` lines 1-7; `dart/lib/src/semantic/semantic_call_projection.dart` lines 1-347
  Baseline evidence: 1500 fragments / 37172 bytes; ordered range SHA-256 `83fc2f7982759ace4650de163a5476dec075705d2189a6b7dfaa62dbecd37b44`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Eleven Dart call/static/casing tests, including all twelve Unicode fixtures through direct/helper/receiver/array paths; neutral semantic contract; exact range/current deltas, retained .1.28 Unicode generation proof, prior evidence retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading and documentation; no source, public contract or infrastructure change.
  Comprehension: Complete upper mappings through U+1E943, merged Cased/Case_Ignorable ranges, binary-search membership and original-rune Final Sigma context. Lowercase sigma requires a preceding cased scalar and no following cased scalar after skipping case-ignorable characters; other mappings expand fixed sequences and preserve unmapped runes. Scaffold only names the package and existing 105-fixture/CLI status. Semantic projection merges typed function and rule definitions by authored UTF-8 start, correlates call occurrences monotonically inside bounded sources, seeds function parameter shapes, traverses function and edge ActionIR, and begins owner/name/occurrence binding construction. Its three explicit helper contracts and empty-function guard remain existing bounded behavior; traversal/binding completion belongs to .1.30.
  Findings: No new confirmed defect. The unchanged empty-function early return is already owned by SESSION-STARTUP-READING.22 and its three gated children; retain the dated zero-versus-five runtime evidence without claiming a fresh reproduction or broad call coverage from the finite fixtures. All Dart .2.1-.2.19 and earlier startup findings remain intact. No source or generated data changed.
  Verification: Physically read Unicode mapping 2690-3835 through EOF in four complete untruncated outputs, scaffold 1-7 through EOF, and semantic call projection 1-347 in two complete outputs: 1,500 fragments / 37,172 baseline-identical bytes with unchanged ordered digest. All eleven selected Dart tests pass: four exact call/staged/generated/Unicode/detachment tests, six static graph/privacy/failure/occurrence tests, and one casing test executing all twelve fixtures on direct/helper/receiver/array routes. Fresh neutral semantic checking passes six fixture groups, twenty exact queries and 128 rejected mutations; rollout 9/0 and admission 6/0 remain unchanged governance counts. Unicode regeneration/12 neutral fixtures remain .1.28/17341bbe proof by exact source identity; no other-backend fresh execution is claimed. Full coverage reconstruction, prior-record retention, doctrines, both histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.29 - complete Unicode and begin semantic call projection`

- ID: `DART-STARTUP-READING.1.30`
  Status: `done`
  Goal: Read bounded Dart group 30 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.29` committed; empty brief and clean repository.
  Activation: Clean `b80acc01545fa62662e3494f040b7b29f8ca4c00`; root status empty, brief zero bytes, and prior commit jobs consumed.
  Scope: `dart/lib/src/semantic/semantic_call_projection.dart` lines 348-1448; `dart/lib/src/semantic/semantic_index.dart` lines 1-399
  Baseline evidence: 1500 fragments / 43400 bytes; ordered range SHA-256 `dfb617b92de600f17db8c40cd395a7ae44ab3585fb9855bdee87194026c7b184`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Twenty-eight Dart semantic call/static/source/compilation/query tests; neutral semantic contract; nine public-query/typed-action/runtime controls and durable recipe; exact range/current deltas, prior evidence retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading, diagnostic intake and documentation; no source, public contract or infrastructure changes.
  Comprehension: Complete typed call/binding emission, accepted registry resolution, return-variable read relations, edge/rule shape propagation, function signature/source correlation, staged payload/job/result projection and selected generated-plan provenance. Staged body AST equality and contract checks are internal authority guards. Call traversal currently unwraps scalar assignment and calls but stops at array/composite nodes; source cursors scan the whole edge with string-only lexical skipping. Separate binding occurrence counters preserve repeated identity. The index prefix defines caller-selected source ceilings, immutable identity/span/snapshot/compilation/entry/generated-plan values, detached diagnostic fields, equality and hashing; constructor/source-map implementations remain for .1.31.
  Findings: Nine public Dart query/typed-action/runtime controls confirm array-call omission with null binding source under existing startup .67.2, and regex text supplying a real call/binding source under new .2.20/.2.20.1-.2.20.2. Seven valid/arity-rejection controls distinguish exact direct/nested/string/repeated sources and reject zero/two arguments; the earlier Perl/Rust false-acceptance and Rust repeated-ID failures are not reproduced on these Dart routes. All prior .2.1-.2.19/startup evidence and repair gates remain intact. No runtime repair or other-backend/MCP reproduction is claimed.
  Verification: Physically read semantic_call_projection.dart 348-1448 through EOF in five complete untruncated outputs and semantic_index.dart 1-399 in two complete outputs: 1,500 fragments / 43,400 baseline-identical bytes with unchanged ordered digest. All 28 selected Dart tests pass; neutral semantics passes six groups, twenty queries and 128 rejected mutations at unchanged rollout 9/0 / admission 6/0. The complete nine-case recipe cross-checks actual public responses against typed ActionIR, accepted contracts, exact source bytes and separate runtime results; array returns ["x"] with its active trim omitted, regex-decoy query cites bytes 44-51 instead of typed RHS 70-81. Seven controls pass. Full 115-path/169-range/55-child reconstruction, prior evidence retention, doctrines, both histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.30 - own semantic container and source-correlation findings`

- ID: `DART-STARTUP-READING.1.31`
  Status: `done`
  Goal: Read bounded Dart group 31 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.30` committed; empty brief and clean repository.
  Activation: Clean `3f21f3b084fbbd8c51ce2387ed8cc1c5bb6ffa3b`; root status empty, brief zero bytes, and prior commit jobs consumed.
  Scope: `dart/lib/src/semantic/semantic_index.dart` lines 400-1231; `dart/lib/src/semantic/semantic_query.dart` lines 1-668
  Baseline evidence: 1500 fragments / 43744 bytes; ordered range SHA-256 `97e9ea5dea6e3df014713a0e97e4da4901cea4492bc8a3882432076359c1459a`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Eighteen Dart source/compilation/query tests; neutral semantic contract; eight native raw-query rejection controls and durable recipe; exact range/current deltas, prior evidence retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading, diagnostic intake and documentation; no source, public contract or infrastructure changes.
  Comprehension: Index construction validates options and strict UTF-8/scalar input, copies private source authority, captures staged parse/validation/compile/entry/generated-plan outcomes, and builds detached static projection without target execution or path loading. Source maps preserve byte/code-unit/scalar boundaries and original newline positions; exact lookup rejects mid-scalar offsets. Caller source ceilings govern identity/spans/text. Observation creates a derived immutable projection; queries only read captured authority. Query prefix defines immutable typed request/response values, bounded page/budget defaults and exact neutral shape/operation/filter/order validation through after_id rejection. Shared plain-value helpers copy maps/lists but retain other values unchanged; remaining query evaluation belongs to .1.32.
  Findings: Eight native public queryNeutral controls establish four defective non-JSON rejected cursors: direct/nested mutable host objects change an existing response's serialization; plain objects and NaN leave unencodable responses. Three cases retain host identity, two mutate serialization and two fail encoding, with overlapping counts. Four ordinary JSON controls remain detached/serializable. New .2.21 and two children own native-domain rejection, recurrence and the shared-public-constructor census. The typed String? cursor cannot carry these host objects; no MCP, other-backend or parser-execution defect is inferred. Earlier .2.1-.2.20 and startup findings remain intact.
  Verification: Physically read semantic_index.dart 400-1231 through EOF in four complete untruncated outputs and semantic_query.dart 1-668 in three complete outputs: 1,500 fragments / 43,744 baseline-identical bytes with unchanged ordered digest. All 18 selected tests pass; neutral semantic checks pass six groups, twenty queries and 128 mutations at unchanged rollout9/0/admission6/0. Eight native controls independently verify rejection codes, detached JSON controls, caller identity and before/after JSON encoding; both durable recipe blocks replay. Diagnostic reads of query rejection helpers beyond 668 earn no extra reading credit. Full 115-path/169-range/55-child reconstruction, prior evidence retention, doctrines, both histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.31 - own native semantic rejection immutability gap`

- ID: `DART-STARTUP-READING.1.32`
  Status: `done`
  Goal: Read bounded Dart group 32 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.31` committed; empty brief and clean repository.
  Activation: Clean `26ea4d8e4f9dab177c4eb6665bc86dc379cdf88e`; root status empty, brief zero bytes, and prior commit jobs consumed.
  Scope: `dart/lib/src/semantic/semantic_query.dart` lines 669-1494; `dart/lib/src/semantic/semantic_runtime_projection.dart` lines 1-293; `dart/lib/src/semantic/semantic_static_projection.dart` lines 1-381
  Baseline evidence: 1500 fragments / 45289 bytes; ordered range SHA-256 `a9840cda06264c510391dbfee2973149c0b49d4bc166deae4ee728e56b2d8b43`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Twenty-one Dart query/runtime-projection/static-graph/runtime-observation tests and neutral semantic contract; retain earlier counterexamples by exact source identity; exact range/current deltas, prior evidence retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading and documentation; no source, public contract or infrastructure changes.
  Comprehension: Query validation completes exact integer bounds, source policy and operation combinations. Evaluation uses detached canonical records, rejects unknown subjects/cursors, pages the filtered primary stream and traverses relations breadth-first with relation/frontier deduplication before canonical output order. Logical costs count returned records/relations, not host work. Explain reserves one decision record and pages its steps; its secondary relations follow those steps under the existing neutral operation, not a newly inferred general resource contract. Source privacy redacts governed facts and projects identity/span/text/digest under immutable ceilings; raw rejected-cursor evidence retains the already-owned .2.21 boundary. Runtime projection validates a compiled unobserved base, typed event fields, exactly one final successful entry result, stable input identity and selector/slot membership. It copies static evidence, derives shapes from static rule/edge facts, appends execution/events/observed_as relations and preserves the base. Static prefix defines canonical kind order, detached internal oracle access and failed-compilation records, rule shape unknown, normalized diagnostics and the beginning of unknown-target explanations; remaining failed/compiled projection and lexical correlation belong to .1.33.
  Findings: No new confirmed defect. Existing .2.21 owns native non-JSON rejected-response detachment; .2.20 and startup .67 own source/container projection, and .2.8 owns action-mediated observer error identity. Older query-kernel wording is explicitly qualified with .2.21; all earlier findings and repair gates remain intact. Captured observations are caller evidence, not proof produced by query execution.
  Verification: Physically read semantic_query.dart 669-1494 through EOF in four complete untruncated outputs, semantic_runtime_projection.dart 1-293 through EOF in one complete output, and semantic_static_projection.dart 1-381 in two complete outputs: 1,500 fragments / 45,289 baseline-identical bytes with unchanged ordered digest. All 21 selected tests pass, including nineteen static typed/raw response digests, twenty-six malformed JSON boundaries and the twentieth observed-runtime digest. Neutral semantic checks pass six groups, twenty queries and 128 mutations at unchanged rollout9/0/admission6/0. Earlier native eight-case rejection and nine-case call-projection recipes remain retained evidence at unchanged source identity; no fresh counterexample/carrier/MCP rerun is claimed. Full 115-path/169-range/55-child reconstruction, prior evidence retention, doctrines, both histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.32 - complete query and runtime projection reading`

- ID: `DART-STARTUP-READING.1.33`
  Status: `done`
  Goal: Read bounded Dart group 33 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.32` committed; empty brief and clean repository.
  Activation: Clean `802582d27453e1e27c729c50c18bd5d19b3127cf`; root status empty, brief zero bytes, and prior commit jobs consumed.
  Scope: `dart/lib/src/semantic/semantic_static_projection.dart` lines 382-1664; `dart/lib/src/semantic/sha256.dart` lines 1-162; `dart/lib/src/source_emitter.dart` lines 1-55
  Baseline evidence: 1500 fragments / 42984 bytes; ordered range SHA-256 `cdfa9bab2bdb9a54c5384b022a6ad338b6cbc2270e520f2724562c92858f9faa`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Twenty-eight Dart static/source/compilation/call/query tests and neutral semantic contract; eight public native compiled/index/runtime controls and durable recipe; exact range/current deltas, prior evidence retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading, diagnostic intake and documentation; no source, public contract or infrastructure changes.
  Comprehension: Static completion normalizes missing-target failures, joins authored rule/member/edge/lifecycle identity to compiled owners, emits canonical graph/source/decision evidence and extends call/staged/generated projection. Action-edge guards require compiled selector agreement; grouped or regex-decoy target substring scanning can lose the authored selector before that guard. Regex slots retain authored self/standalone ownership; lifecycle payload count/marker checks reject mismatched joins. Member ranges track delimiters/quotes/leading regex, while explicit target scanning searches whole-member arrow/name substrings. Typed return shapes retain literals, containers and codeblock signatures; rule shape prefers whole-rule E then known edge shape, wrapping repetition. IDs escape exact UTF-8 bytes before canonical rank/order sorting. Dependency-free SHA-256 pads exact bytes, expands 64 words and masks 32-bit rounds; existing vectors and graph source identity remain selected proof. Emitter prefix defines generated v2/format2, diagnostic callback identity wrapper and begins the semantic counterpart; completion belongs to .1.34.
  Findings: Eight public native compiled/index/runtime controls establish four semantic constructor failures while every source compiles and executes its expected input. Shared-selector groups with both prefix/non-prefix targets extend existing startup .70.1/.70.3; regex-arrow absent/mismatched selector decoys are owned by new .2.22 and two children. Four separate/clean/same-index/direct controls preserve correct query source forms and byte spans. The strict identity guard exposes the earlier source-correlation error; do not weaken it. All earlier .2.1-.2.21/startup findings remain intact. No raw-query, UTF-8-constructor, observed/emitted/reconstructed, other-backend or MCP reproduction is claimed.
  Verification: Physically read semantic_static_projection.dart 382-1664 through EOF in six complete untruncated outputs, sha256.dart 1-162 through EOF, and source_emitter.dart 1-55 in complete outputs: 1,500 fragments / 42,984 baseline-identical bytes with unchanged ordered digest. All 28 selected tests and neutral semantic six-group/twenty-query/128-mutation checks pass at unchanged rollout9/0/admission6/0. Both complete eight-case recipe blocks replay; independent assertions verify compiled target/index/block facts, exact constructor failures, all eight runtime values and successful query source forms/member text/UTF-8 spans. Full 115-path/169-range/55-child reconstruction, prior evidence retention, doctrines, both histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.33 - own indexed edge source-correlation failures`

- ID: `DART-STARTUP-READING.1.34`
  Status: `done`
  Goal: Read bounded Dart group 34 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.33` committed; empty brief and clean repository.
  Activation: Clean `df88085f2b4e794582bfcf65fcad8fc5cb9fb2d3`; root status empty, brief zero bytes, and prior commit jobs consumed.
  Scope: `dart/lib/src/source_emitter.dart` lines 56-796; `dart/lib/src/trace/trace.dart` lines 1-404; `dart/lib/src/validation/spec_validator.dart` lines 1-355
  Baseline evidence: 1500 fragments / 45347 bytes; ordered range SHA-256 `eeb90e20a592b2b167b08f10280b0b86b5778fbb3912bf0d74e37b2cb4049cea`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Twenty-seven Dart emitter/trace/frontend-validation/spec-validation tests, including isolated offline emitted callers, ten families and the accepted manifest subset; neutral generated-source contract; exact range/current deltas, prior evidence retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading and documentation; no source, public contract or infrastructure changes.
  Comprehension: Emitter completes stable generated errors/metadata, exact ten-family classification and label/family plans, contract-first rejection, compiled invariant checks, direct/traced execution and original diagnostic/semantic callback failure passthrough. Normalized effective SpecFile state is strict UTF-8/Base64 inside deterministic Dart source with escaped identity/label literals; lazy reconstruction follows contract validation. Ordinary generated execute accepts opaque progressive/staged seeds; the traced convenience signature retains only its declared top-rule/config/sinks, and the admitted private seeded carrier remains execute. Plan validation checks row count, order, known family and exact classification before engine execution. Trace defines numeric/alias levels, explicit environment-derived config, immutable copies of observed event/line lists, synchronous stdout/file/mirror routing and balanced scope indentation; file setup/reset is constructor behavior independent of event filtering. Validation prefix defines portable fields and check order, Unicode declarations/targets, duplicates, named regex slots, registry/signature/parameter restrictions, malformed Raw rejection and balanced lifecycle checks. Remaining edge/gap/regex/strict validation belongs to .1.35.
  Findings: No new confirmed defect. Existing Dart .2.3 owns primary-CLI overflow/reset ordering, .2.8 owns action-mediated observer identity, .2.2 owns lifecycle/regex-brace scanning, .2.4 owns recognition effects, and .2.20-.2.22/startup .67/.70 retain semantic findings. The neutral generated-source v1 ledger is the documented shared semantic baseline, while current Dart artifacts remain v2/format2; no version movement or new traced seed capability is inferred.
  Verification: Physically read source_emitter.dart 56-796 through EOF in three complete untruncated 247-line outputs, trace.dart 1-404 through EOF in two complete 202-line outputs, and spec_validator.dart 1-355 in two complete outputs: 1,500 fragments / 45,347 baseline-identical bytes with unchanged ordered digest. All 27 selected tests pass, including isolated offline generated caller analysis/execution, ten structural families and interpreter-first accepted eight-case manifest proof. The neutral generated-source checker passes ten families/one behavior case, Dart/Julia/Lua8/105 plus strict Rust105/105 registered breadth and census100/0/0; this static contract check is not a fresh other-backend runtime run. Prior semantic and private counterexamples are retained at unchanged source identity. Full 115-path/169-range/55-child reconstruction, prior evidence retention, doctrines, both histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.34 - complete emitter and trace reading`

- ID: `DART-STARTUP-READING.1.35`
  Status: `done`
  Goal: Read bounded Dart group 35 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.34` committed; empty brief and clean repository.
  Activation: Clean `7f32f90b406581233272301855a7b0c505d89bd9`; root status empty, brief zero bytes, and prior commit jobs consumed.
  Scope: `dart/lib/src/validation/spec_validator.dart` lines 356-1072; `dart/pubspec.lock` lines 1-381; `dart/pubspec.yaml` lines 1-10; `dart/test/action_ast_parser_test.dart` lines 1-189; `dart/test/action_contracts_test.dart` lines 1-203
  Baseline evidence: 1500 fragments / 44700 bytes; ordered range SHA-256 `2d5776c4afc82f1631de7ea0df2208c2fe899ec5059b2cf1227e7db0d969181d`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Thirty-five Dart validator/action-parser/action-contract/root/gap/duplicate-slot tests, including existing emitted and primary roles; neutral gap and duplicate-slot contracts; ten public reconstructed selector controls and exact durable replay; exact range/current deltas, prior evidence retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading and defect intake; no source, public contract or infrastructure changes.
  Comprehension: Validation tail keeps quoted brace-depth scanning, bare/action/blind ownership diagnostics, grouped shared-block requirements, directive uniqueness and legacy-marker conflicts, loop/seek/action eligibility, same-line adjacency exclusion, named/numeric/unindexed target resolution, lightweight escaped/class/parenthesis regex checks and authored-edge-only strict-unused analysis. Entry selection and markers grant no strict exemption. Package inputs retain SDK >=3.9.0 <4.0.0, no production dependencies, one direct test development dependency and 47 hosted locked packages. Action parser tests cover value-drop statements, literals and nested access, typed assignments, fluent/trailing contextual blocks, quoted delimiters, structured controls and explicit Raw fallback. Contract tests cover canonical numeric/helper mappings, structural writes, unknown/Raw diagnostics, reserved built-in collisions, gap-family membership and exact-arity user calls before fallback; the helper tail continues in .1.36.
  Findings: Ten public SpecFile-JSON reconstruction/validation/compiled/descriptor/runtime controls confirm two malformed named/null acceptances selecting anonymous /a/ at index 0 or 1. Three valid selectors and three rejecting-name controls bound the defect. Numeric-null and unindexed-text provenance are separately accepted census inputs, not additional wrong-slot claims. Nullable equality in validation and compilation confuses missing names with anonymous slot IDs. New .2.23 plus two repair children own the required name guard, compatible carrier census and recurrence; all earlier Dart/startup owners remain intact.
  Verification: Physically read validator 356-1072 through EOF in three complete 239-line outputs, lock 1-381 through EOF in two outputs, manifest 1-10 and action-parser tests 1-189 through EOF, then action-contract tests 1-203: 1,500 fragments / 44,700 baseline-identical bytes with unchanged ordered digest. All 35 selected tests pass, including existing independently emitted/primary gap and duplicate-slot roles. Neutral gap passes 9/0/63 plus public8/15/10/34; duplicate identity passes 7/0/59. Both complete tracked reproduction blocks replay; independent assertions check every reconstructed selector, diagnostic, resolved descriptor and runtime value. This defect proof does not newly cover authored syntax, emitted/generated, semantic-index/MCP or other backends. Full 115-path/169-range/55-child reconstruction, prior evidence retention, doctrines, both histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.35 - own null named-selector validation gap`

- ID: `DART-STARTUP-READING.1.36`
  Status: `done`
  Goal: Read bounded Dart group 36 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.35` committed; empty brief and clean repository.
  Activation: Clean `6cb42d876d605830bdb429236e08d553a541fd9d`; root status empty, brief zero bytes, and prior commit jobs consumed.
  Scope: `dart/test/action_contracts_test.dart` lines 204-205; `dart/test/callable_codeblock_literal_contract_test.dart` lines 1-1080; `dart/test/compiled_spec_test.dart` lines 1-418
  Baseline evidence: 1500 fragments / 48187 bytes; ordered range SHA-256 `2e49dc784db23bc6db5df83e9df7a2f327a4e28701f862cbb723b876fb0f1c32`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Actual governed history rollover/rejection, exact restoration and read-only capacity proposal; thirty-eight Dart callable-codeblock/compiled-spec/action-contract/variadic tests, including standalone offline emitted execution; neutral callable contract; exact range/current deltas, prior evidence retention, all doctrines, both histories, Knowledge freshness, rendered mdBook and staged scope.
  Canonical trigger: `none` — bounded required reading and documentation; no source, public contract or infrastructure changes.
  Comprehension: Contract helper tail completes function fixtures. Callable tests cover exact neutral eight-field records, fixed/rest signatures, containing Unicode spans, malformed literal diagnostics, inert construction/copies/transport, deferred dependencies and semantic signature shapes. Dynamic invocation tests cover ordered argument effects, copied parameters/results, caller-time reads, local returns, static precedence, typed failures and direct/mutual cycles across native/reconstructed/generated routes. Metadata-owned contextual final blocks preserve eager/harray/control distinctions, descriptor-v3/staged sidecars, arity diagnostics and callback lookup before value binding. One standalone caller uses a fresh local offline package cache to execute the neutral fixture, contextual forms and all seven invalid calls, then cleans its scratch. Compiler tests cover ordered rule/dependency/descriptor state, stitched function jobs and runtime, edge-only regex indexes, explicit validation bypass for last-definition replacement, and ordinary undefined-target rejection. Descriptor fixture helpers continue through 418; remaining tail belongs to .1.37.
  Findings: No new confirmed code defect. Required history rollover rejects exactly collection32/31, manifest31/30 and17615/17039. Intake .6 owns a new director decision; the verified draft is restored and a complete concise .1.36 record fits 460 lines without changing prior history or limits. Existing .2.10 qualifies helper-mediated callback identity; .2.1/.2.2/.2.4/.2.6-.2.9 and semantic .2.20-.2.23/startup .67/.70 retain their evidence. Current generic final-block implementation is recorded in dart-generic-final-codeblock-gap; the older construction/invocation cards' historical .11.5.3-pending statements are explicitly qualified, with no capability change. The .1.35 malformed named-selector controls remain retained at unchanged source identity.
  Verification: Physically read action-contract tests 204-205 through EOF, all callable-codeblock tests 1-1080 in five complete 216-line outputs, and compiled-spec tests 1-418 in two complete 209-line outputs: 1,500 fragments / 48,187 baseline-identical bytes with unchanged ordered digest. All 38 selected tests pass, including the fresh offline standalone caller's fixture/contextual/seven-error execution. Neutral callable contract passes 7 literals/11 calls/9 invalid literals/7 invalid calls/4 invalid declarations/8 contextual forms and 23 governance mutations. Existing counterexamples remain retained rather than freshly replayed; no other-backend or MCP result is claimed. Governed draft archives exact clean 6cb42d87 CHANGES247-457 (211 lines/31668 bytes; SHA-25655830675f67c5814a5457a3c2adabc054d918b62582312c52d791fe268b78ef4); source/hash/prior-manifest/full-draft reconstruction passes. Routing rejects precisely three capacity axes; only the verified uncommitted draft is restored. New .6 and its Knowledge card retain the proposal. Full 115-path/169-range/55-child reconstruction, prior evidence retention, doctrines, both histories, Knowledge and rendered-book proof belong to this commit.
  Commit: `DART-STARTUP-READING.1.36 - complete callable contract test reading`

- ID: `DART-STARTUP-READING.1.37`
  Status: `done`
  Goal: Read bounded Dart group 37 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.36` committed; empty brief and clean repository.
  Activation: Clean `eaf4331e71bbc8e0c3f04162fb915bddc8cfea96`; intake .80.0 committed, root clean, brief zero bytes and commit jobs consumed.
  Scope: `dart/test/compiled_spec_test.dart` lines 419-478; `dart/test/complete_named_mark_contract_test.dart` lines 1-92; `dart/test/corpus_manifest_test.dart` lines 1-883; `dart/test/diagnostic_output_contract_test.dart` lines 1-342; `dart/test/duplicate_regex_slot_identity_contract_test.dart` lines 1-123
  Baseline evidence: 1500 fragments / 44134 bytes; ordered range SHA-256 `d8061f34d57331a6b1eb22b71e9db4b23ef20776e6fd224a393d33560af4e63e`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact scoped bytes/current deltas; compiled, named-mark, corpus, diagnostic and duplicate-slot Dart contracts; neutral named-mark/diagnostic/duplicate-slot checks; prior evidence preservation, Knowledge, doctrines, histories, mdBook, memory and staged whitespace/scope.
  Canonical trigger: `none` — bounded required reading and documentation; no source, contract or infrastructure changes.
  Comprehension: Compiled-test helpers finish function body payload/job metadata and 1-based LF source coordinates. Named-mark tests bind exactly seven names and compare the neutral Unicode fixture across native, generated-plan, emitted-state reconstruction and primary CLI routes; they do not compile an independent emitted module or prove same-label recursive isolation. Corpus tests retain concrete portmap/HLink/helper/accumulator/parser-smoke/function/vhistory shapes, full 105-fixture success, controlled scalar/aggregate/dispatch/lifecycle results, mismatch collection, named/bounded selection, dedicated corpus CLI and primary-command separation, manifest schema/count/name/directory/file rejection, and owned temporary-fixture cleanup. Diagnostic tests exercise quiet/eager aliases, scalar rendering, arity-before-effects, wrong-kind silence, immediate exit, synchronous caller error identity, trace separation and generated direct/traced outcomes. Duplicate-slot entry binds exactly fifteen roles, five fixtures and structural target/index identity, then covers native/choice/repetition/cross-target/loaded routes and begins reconstruction through line 123.
  Findings: No new confirmed defect. All earlier Dart .2.1-.2.23 and startup owners remain pending with their exact evidence. Diagnostic-output callback proof does not close the separately owned semantic-observer wrapping gap .2.8. Current capacity is canonical at bef5dafd; CI evidence intake is committed at eaf4331e under .80.0.
  Verification: Physically read compiled tests 419-478 through EOF, all 92 named-mark lines, corpus 1-883 in four complete outputs, diagnostic 1-342 in two complete ranges, and duplicate-slot 1-123: 1,500 fragments / 44,134 bytes with exact baseline/current identity and ordered digest. All 38 selected tests pass; the full-corpus test executes 105/105, and the duplicate consumer executes all fifteen declared roles. Neutral named-mark passes seven helpers/three mutations; diagnostic passes three helpers/eleven render cases/six scenarios/8 complete/0 pending/20 mutations; duplicate-slot passes five fixtures/two diagnostics/six runtime rows/7 complete/0 pending/59 mutations. Generated-plan execution and reconstructed emitted payload are distinct from independent emitted compilation; no new cross-backend or MCP proof is claimed. Full declared-scope reconstruction, previous evidence preservation, Knowledge, book, memory, both history checks, doctrines and staged scope/whitespace belong to this focused commit.
  Commit: `DART-STARTUP-READING.1.37 - complete corpus and diagnostic test reading`

- ID: `DART-STARTUP-READING.1.38`
  Status: `done`
  Goal: Read bounded Dart group 38 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.37` committed; empty brief and clean repository.
  Activation: Clean `7b9df4e722e056b6c264f1e6e7a4176bfe40bddc`; previous reading committed, root clean, brief zero bytes and all jobs consumed.
  Scope: `dart/test/duplicate_regex_slot_identity_contract_test.dart` lines 124-477; `dart/test/frontend_compiler_trace_test.dart` lines 1-112; `dart/test/function_registry_test.dart` lines 1-111; `dart/test/function_staged_trace_test.dart` lines 1-205; `dart/test/inter_match_gap_capture_contract_test.dart` lines 1-718
  Baseline evidence: 1500 fragments / 45409 bytes; ordered range SHA-256 `9e400f77481ca5ab9761503708762a188b01158025859d6ea88c923ca566962b`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact scoped bytes/current deltas; duplicate-slot/frontend/function-registry/function-staged/gap Dart tests; neutral gap and duplicate-slot checks; prior evidence preservation, Knowledge, doctrines, histories, mdBook, memory and staged scope/whitespace.
  Canonical trigger: `none` — bounded required reading and documentation; no source, contract or infrastructure changes.
  Comprehension: Duplicate-slot tests complete reconstructed state, detached descriptor target/index identities, emitted source markers, direct generated values, ordered/choice and file-routed generated trace roles, primary JSON output, malformed compiled-state rejection across runtime/emitter/plan validation, and ordered cross-target mismatch diagnostics. The emitted-source role checks strings; it does not independently compile that output. Frontend traces assert exact event order, quiet identical JSON and balanced failures with equal error type/text. Registry fixtures retain ordered zero/fixed-arity entries, body jobs and stitched AST, distinguish unknown name from arity mismatch, and reject duplicate names. Function traces assert topic coverage, stack-balanced entry/exit, quiet AST identity and unwrapped projection/resolve diagnostics. Gap tests through 718 cover named/anonymous Unicode declarations, stable selectors under reorder, directive eligibility, source-aware static errors and preserved legacy descriptor shapes; native cases cover prefix/interstitial/tail spans, falsey children, LS preselection, child cursor boundaries, nested isolation, recognition rollback, terminal hooks, unavailable context and cursor regression. The failed-minimum assertion continues in .1.39.
  Findings: No new confirmed defect. All earlier .2.1-.2.23/startup owners remain with their evidence; passing authored selector cases do not close reconstructed null-name .2.23. The historical Dart gap plan is explicitly qualified by current neutral9/0 and recurring-governance authority. CI intake stays committed at eaf4331e; source repairs remain gated.
  Verification: Physically read duplicate-slot 124-477 through EOF in two complete 177-line outputs; all frontend 112 / registry 111 / function-staged 205 lines; gap 1-718 in complete 239/239/240-line outputs. Exact 1,500 fragments / 45,409 bytes and ordered range digest match baseline/current source. All 15 selected tests pass, including existing fifteen-role duplicate and nine-role gap ledgers plus independently analyzed/executed gap emitted modules. Neutral gap reports 8 positive/10 negative fixtures,3 sources,16 transitions,10 segmentation cases,9 diagnostics,9 complete/0 pending/63 semantic mutations, public8/15/10/34 and Rust10/Dart10/Julia10/Lua16 admission mutations; duplicate reports 5 fixtures/2 diagnostics/6 runtimes/7 complete/0 pending/59 mutations. Current gap rollout qualifies the earlier Dart admission narrative; no standalone duplicate emission compilation, new cross-backend or MCP run is claimed. Full coverage, retained evidence, Knowledge/book/memory/history/doctrine and staged-scope checks belong to this focused commit.
  Commit: `DART-STARTUP-READING.1.38 - read identity and trace contracts`

- ID: `DART-STARTUP-READING.1.39`
  Status: `done`
  Goal: Read bounded Dart group 39 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.38` committed; empty brief and clean repository.
  Activation: Clean `91d59b3c434c49387f1f9a424cacdbb38f50318c`; prior reading committed, root clean, zero-byte brief and all jobs consumed.
  Scope: `dart/test/inter_match_gap_capture_contract_test.dart` lines 719-1588; `dart/test/logical_helper_contract_test.dart` lines 1-454; `dart/test/map_leaves_mutation_contract_test.dart` lines 1-176
  Baseline evidence: 1500 fragments / 46756 bytes; ordered range SHA-256 `7532ddaf24a3a8d860edd53734f8510f02aab378c648049d8004df11b9240bbe`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact scoped bytes/current deltas; gap/logical-helper/map-leaves Dart contract tests and their neutral checks; prior evidence preservation, Knowledge, doctrines, histories, mdBook, memory and staged scope/whitespace.
  Canonical trigger: `none` — bounded required reading and documentation; no source, contract or infrastructure changes.
  Comprehension: Gap tests finish failed-minimum, direct-entry and unflagged controls; normalized descriptors retain logical source and separate gap fields without widening legacy edges or v2 plans. Direct/traced generated failures preserve typed causal detail. The exact nine-role admission ledger includes native, reconstruction, descriptor, plan, emission, lifecycle, recursion/rollback, diagnostics and primary routes. The emitted harness creates a fresh local offline package/cache, analyzes ten value and two error modules with fatal diagnostics, executes paired direct/traced calls and verifies trace identity; it is invoked by the separate emitted test and again within the ledger. Logical tests bind seventeen typed truth rows and ten helper cases, value/effect/receiver-lazy fixtures, four invalid arities before effects, normalized/generated/primary routes and an independent analyzed caller containing three value modules plus only the not_many invalid module. Mutation-test prefix uses the zero-regex Top-to-Done scaffold, reconstructs a deliberately corrupt typed receiver while preserving surrounding compiled metadata, and begins the four-valid/fourteen-invalid/five-excluded syntax inventory through 176.
  Findings: No new confirmed defect. All earlier .2.1-.2.23/startup evidence remains; existing nested callback identity .2.10 and malformed named-selector .2.23 are not closed by these passing fixture routes. Historical logical admission counts are explicitly qualified by the current8/0 neutral result; source changes stay gated.
  Verification: Physically read gap 719-1588 through EOF in four complete 217/218/218/217-line outputs, logical 1-454 through EOF in two 227-line outputs, and mutation 1-176: exact 1,500 fragments/46,756 baseline-identical bytes and unchanged ordered digest. All 40 selected tests pass. Gap remains 9 complete/0 pending/63 semantic mutations plus public8/15/10/34 and Rust10/Dart10/Julia10/Lua16 admission controls; logical passes 17 truth rows/10 helper/3 effect/8 complete/0 pending/19 public/14 denials/26 mutations; mutation passes 4 valid/14 invalid/5 excluded,10 successes,8 pre-commit failures, six callback/one continuation compositions and 167 base+592 composition mutations. Independent gap/logical emitted analysis and execution are source-backed; the existing full mutation test also passes its emitted caller while unread source remains .1.40. No fresh other-backend or MCP proof is claimed. Exact full coverage, preserved evidence, Knowledge/book/memory/history/doctrines and staged scope/whitespace belong to this focused commit.
  Commit: `DART-STARTUP-READING.1.39 - complete gap and logical contract reading`

- ID: `DART-STARTUP-READING.1.40`
  Status: `done`
  Goal: Read bounded Dart group 40 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.39` committed; empty brief and clean repository.
  Activation: Clean `5886ec15b777fe059495430e29e31d67269bd9e6`; prior reading committed, root clean, zero-byte brief and all jobs consumed.
  Scope: `dart/test/map_leaves_mutation_contract_test.dart` lines 177-829; `dart/test/mcp_contract_dart_binding_test.dart` lines 1-142; `dart/test/mcp_server_dart_admission_test.dart` lines 1-705
  Baseline evidence: 1500 fragments / 49088 bytes; ordered range SHA-256 `3e97998d6e2a3be4b40a67e64370b30d81f61d499448b1545199bd5c146aad18`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact scoped bytes/current deltas; receiver-mutation and MCP binding/admission Dart tests; neutral mutation/MCP transport/admission checks and generated-binding freshness; prior evidence preservation, Knowledge, doctrines, histories, mdBook, memory and staged scope/whitespace.
  Canonical trigger: `none` — bounded required reading and documentation; no source, contract or infrastructure changes.
  Comprehension: Mutation tests cover typed scalar spans, original-shape traversal and copied frames, shadow binding identity, six callback/one continuation compositions, detached outputs, invalid receiver and pre-effect reentrant guards across helper routes, exact diagnostic-sink error identity and corrupt serialized receiver rejection. One representative count_keys continuation traverses native/reconstructed/generated/primary and independent offline emitted direct execution after plain analyze. Binding tests verify digest isolation, closed schema/UTF-8 budgets, 28 accepted plus seven rejected canonical frames and nested key serialization. Admission reads all twelve role bodies: twenty native identities, ten raw outcomes, ten lifecycle cases, four indistinguishable handle states, policy lowering, borrowed sinks, fixed I/O sanitization, shutdown and source authority fences. Pre-emission cancellation and native hostile-failure roles additionally assert textual sentinels in separate focused consumers; they do not execute those seams here. Helpers after 705 remain .1.41.
  Findings: No new confirmed defect. MCP canonical-key ordering .2.5 and callback identity .2.10 remain open; passing representative fixtures do not close them. The mutation caller has plain analysis and direct execution only; strict/traced full-matrix emission is not claimed. Source repairs retain startup gates.
  Verification: Read mutation 177-829 through EOF in three complete outputs, binding 1-142 through EOF, and admission 1-705 in three 235-line outputs; exact 1,500 fragments / 49,088 baseline-identical bytes and ordered digest. All 16 selected tests pass. Mutation neutral passes 4 valid/14 invalid/5 exclusions/10 success/8 pre-commit failures, six callback/one continuation compositions and 167+592 mutations. MCP transport passes 35 frames/10 raw/10 lifecycle/76 mutations; admission remains 5/5 implementations, 6/6 runtimes, rollout complete/141 mutations; generated binding is byte-fresh at 83,214 bytes. These neutral ledger checks do not rerun the other runtimes. Full coverage/preservation, Knowledge/book/memory/histories, whitespace and staged scope plus commit-hook doctrines govern this focused commit.
  Commit: `DART-STARTUP-READING.1.40 - complete mutation and MCP contract reading`

- ID: `DART-STARTUP-READING.1.41`
  Status: `done`
  Goal: Read bounded Dart group 41 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.40` committed; empty brief and clean repository.
  Activation: Clean `d2fa7b4d97c3ceeedef172ef2934d5ad595682ab`; prior reading committed, root clean, zero-byte brief and all jobs consumed.
  Scope: `dart/test/mcp_server_dart_admission_test.dart` lines 706-962; `dart/test/mcp_server_dart_dispatch_test.dart` lines 1-665; `dart/test/mcp_server_dart_stdio_test.dart` lines 1-575; `dart/test/native_pipeline_trace_test.dart` lines 1-3
  Baseline evidence: 1500 fragments / 48287 bytes; ordered range SHA-256 `9d0046da1a830ed022b091666b7529eee81e6f5f9bf7f19ec0522674d09662f5`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact scoped bytes/current deltas; MCP binding/admission/dispatch/stdio tests; neutral MCP transport/admission checks and binding freshness; prior evidence preservation, Knowledge, doctrines, histories, mdBook, memory and staged scope/whitespace.
  Canonical trigger: `none` — bounded required reading and documentation; no source, contract or infrastructure changes.
  Comprehension: Admission helpers materialize six snapshots, including host-side parser execution with three A/B observations; this is host authority, not MCP parser authority. They bind frame order, raw encoding, response digest and borrowed sink probes. Dispatch verifies cloned requests, immutable index identity, explicit policy denial before native calls, omitted/partial overlay native diagnostics, four unavailable states, copied authorization, expiration/capacity, clock overflow, bounded entropy collisions, sanitized native failures and decoded cancellation. Stdio covers duplicate decoded keys, invalid surrogate/numeric forms, lexical IDs and safe/UTF-8 limits, exact CRLF maximum, overlong recovery/final EOF, chunked responses, injected pre-emission cancellation with zero bytes/active requests, late cancellation finality, release and I/O privacy. Sink failure uses consumer addStream; there is no separate flush-only fault injection. Native trace lines 1-3 are imports only.
  Findings: No new confirmed defect. Admission sort shares the known Unicode ordering qualification .2.5; passing fixtures add no native/wire Unicode result. Imports alone grant no native trace test-body credit. All source-repair gates remain.
  Verification: Physically read admission 706-962 through EOF, dispatch 1-665 through EOF in 222/222/221-line outputs, stdio 1-575 through EOF in 192/192/191-line outputs, and native trace 1-3: exact 1,500 fragments / 48,287 baseline-identical bytes and ordered digest. All 17 MCP binding/admission/dispatch/stdio tests pass, including cancellation and hostile-native seams referenced by admission. Neutral transport passes 35 frames/10 raw/10 lifecycle/76 mutations, admission remains 5/5 implementations plus 6/6 runtimes complete/141 mutations, and binding freshness passes at 83,214 bytes. Other runtimes are not rerun. Full coverage/preservation, Knowledge/book/memory/histories, whitespace/staged scope and commit-hook doctrines govern the focused commit.
  Commit: `DART-STARTUP-READING.1.41 - complete MCP dispatch and stdio reading`

- ID: `DART-STARTUP-READING.1.42`
  Status: `done`
  Goal: Read bounded Dart group 42 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.41` committed; empty brief and clean repository.
  Activation: Clean `0e832ae4e1f37091768d5335e87600522ae5c78d`; prior reading committed, root clean, zero-byte brief and all jobs consumed.
  Scope: `dart/test/native_pipeline_trace_test.dart` lines 4-182; `dart/test/primary_cli_test.dart` lines 1-303; `dart/test/progressive_span_dispatch_contract_test.dart` lines 1-614; `dart/test/punctuation_light_zero_arg_contract_test.dart` lines 1-188; `dart/test/recognition_transaction_contract_test.dart` lines 1-216
  Baseline evidence: 1500 fragments / 48485 bytes; ordered range SHA-256 `9c7110f9999de79d39fcbef6563d11e3074fa8cc0f1225ea72acde4a08d9b964`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact scoped bytes/current deltas; native trace, primary CLI, progressive, zero-argument and recognition Dart tests; neutral progressive/zero-argument/recognition contracts; prior evidence preservation, Knowledge, doctrines, histories, mdBook, memory and staged scope/whitespace.
  Canonical trigger: `none` — bounded required reading and documentation; no source, contract or infrastructure changes.
  Comprehension: Native pipeline tests reuse one emitter across loader/frontend/function/staged/compiler/runtime, compare compiled/result JSON and balanced scopes, keep disabled tracing quiet and preserve structured validation errors; temporary roots follow managed TMPDIR. CLI tests cover exact help/options, removed global mode, compile-before-input ordering, phase-owned malformed UTF-8, BOM/newline preservation, named lookup order, top-rule override, nested JSON, exact low trace, routed emoji reset and setup failure. Progressive consumer pins the complete neutral inventory but keeps v1 staged registry separate, requires one logical-only dedicated node, rejects malformed/static recognition forms and live transactions, starts fresh opaque host seeds, proves native/reconstructed/generated results and strictly analyzes/runs one emitted source in the current package. Punctuation aliases compare semantic ASTs with source metadata removed, retain variable/exclusion boundaries and preserve known contains-without-needle zero; emission reconstructs embedded state only. Recognition prefix pins current 138/250/58 and nine completed legs, isolates same-label invocation/mark generations and starts the eight-positive-token loop.
  Findings: No new confirmed defect. Known trace overflow .2.3, recognition effect integration .2.4, private nested progressive authority startup .37 and contains arity backlog .5 are not closed by these covered fixtures. Progressive emission uses the current package, not a newly resolved external package; punctuation emission is state reconstruction only. All source-repair gates remain.
  Verification: Read native trace 4-182 through EOF, primary CLI 1-303 through EOF in 152/151-line outputs, progressive 1-614 through EOF in 205/205/204-line outputs, punctuation 1-188 through EOF and recognition 1-216: exact 1,500 fragments / 48,485 baseline-identical bytes and ordered digest. All 39 selected tests pass, including progressive and existing recognition emitted consumers; unread recognition implementation remains .1.43. Progressive neutral is 9/9 complete/116 mutations plus public 6/12/10/60; punctuation is 6 standalone/4 receiver/6 invalid with exact fixture; recognition is 138 ActionIR/250 calls/58 mutations, 9/9 complete, public 3/26/45 and guide 1/14/18. No full process CLI matrix or other runtime is rerun. Full coverage/preservation, Knowledge/book/memory/histories, whitespace/staged scope and commit-hook doctrines govern this focused commit.
  Commit: `DART-STARTUP-READING.1.42 - read trace CLI and progressive consumers`

- ID: `DART-STARTUP-READING.1.43`
  Status: `done`
  Goal: Read bounded Dart group 43 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.42` committed; empty brief and clean repository.
  Activation: Clean `c162a5d7e576f3afe355decfa97189c2cf318a5d`; prior reading committed, root clean, zero-byte brief and all jobs consumed.
  Scope: `dart/test/recognition_transaction_contract_test.dart` lines 217-919; `dart/test/recursive_observation_contract_test.dart` lines 1-464; `dart/test/repeated_action_result_contract_test.dart` lines 1-333
  Baseline evidence: 1500 fragments / 45121 bytes; ordered range SHA-256 `f3d235974eaaeeea66058678ef238f7dc59b2f2ae3cbbebfdf45d2bd0f0c7ba9`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact scoped bytes/current deltas; recognition, recursive observation and repeated-action result Dart tests; neutral recognition/typed-source/repeated-action contracts; prior evidence preservation, Knowledge, doctrines, histories, mdBook, memory and staged scope/whitespace.
  Canonical trigger: `none` — bounded required reading and documentation; no source, contract or infrastructure changes.
  Comprehension: Recognition tests separate eight positive match/payload cases, cursor/boundary/mark commit/rollback, invocation-local gap snapshots and exact gap diagnostics; token escape, missing/repeated attempts, cross-owner use, nested checkpoint, reuse, discard and unwind restore/invalidate. Dedicated nodes retain unevaluated static children; effect and progress fixtures call authority methods directly. Native/reconstructed/generated false payloads and a strict offline independently resolved emitted caller pass. Recursive observation tests one non-eager node, five static failures, detached nine-field astral records, fresh invocation IDs, failed/zero-regex/action-edge child semantics, ordinary recursion cutoff, direct/mutual rejection and aborted diagnostic text. Its independently resolved offline emitted caller strictly analyzes one accepted false/astral case, without traced or failure-case emission. Repeated-action prefix binds fifteen unique role names, repetition metadata/eight modes/special cases, loaded/reconstructed/descriptor paths, and a fresh offline emitted caller with paired direct/traced results, two selected-slot trace records and stale-family rejection. That caller has no separate analyze command; remaining role bodies after 333 belong to .1.44.
  Findings: No new confirmed defect. Direct authority effect tests do not close production integration .2.4. Observation failure assertions inspect diagnostic text, not exception-object identity or every aborted observation record. Accepted emitted examples do not independently cover the complete failure matrix. All source-repair gates remain.
  Verification: Read recognition 217-919 through EOF in 235/234/234-line outputs, recursive observation 1-464 through EOF in two 232-line outputs, and repeated-action 1-333 in 167/166-line outputs: exact 1,500 fragments / 45,121 baseline-identical bytes and ordered digest. All 22 selected tests pass, including the three emitted consumers. Recognition neutral remains 138/250/58 with 9/9 complete, public 3/26/45 and guide 1/14/18; typed source is 14 complete/0 pending/231 mutations; repeated-action is eight modes/ten special/eight complete/zero pending/54 mutations. No other runtime or full CLI matrix is rerun. Full coverage/preservation, Knowledge/book/memory/histories, whitespace/staged scope and commit-hook doctrines govern the focused commit.
  Commit: `DART-STARTUP-READING.1.43 - read recognition and observation consumers`

- ID: `DART-STARTUP-READING.1.44`
  Status: `done`
  Goal: Read bounded Dart group 44 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.43` committed; empty brief and clean repository.
  Activation: Clean `f6e3382101b3fad031b5274c49f48ae16c2e3579`; prior reading committed, root clean, zero-byte brief and all jobs consumed.
  Scope: `dart/test/repeated_action_result_contract_test.dart` lines 334-498; `dart/test/root_rule_selection_admission_test.dart` lines 1-536; `dart/test/root_rule_selection_core_test.dart` lines 1-229; `dart/test/root_rule_selection_routes_test.dart` lines 1-272; `dart/test/rule_local_cursor_contract_test.dart` lines 1-298
  Baseline evidence: 1500 fragments / 45785 bytes; ordered range SHA-256 `9ef35e9b346de215c0aa27b98d902398b99af0c89cb80fb081025ad1300a0080`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact scoped bytes/current deltas; repeated-action, root-rule admission/core/routes and rule-local cursor Dart tests; neutral repeated-action/root-rule/cursor contracts; prior evidence preservation, Knowledge, doctrines, histories, mdBook, memory and staged scope/whitespace.
  Canonical trigger: `none` — bounded required reading and documentation; no source, contract or infrastructure changes.
  Comprehension: Repeated-action suffix checks native/generated slot traces, explicit repetition versus scalar pipe through the primary adapter, exact corpus bytes with trimmed input, whole-rule lifecycle return authority, optional/bounded/minimum behavior and one retained zero-width hit before stopping. Root admission binds fifteen unique roles; core resolves explicit selector/first marker/first rule without authored identity mutation, preserves zero-rule validation ownership and rejects missing selection before user code. Strict unused analysis remains authored-edge-only. Loaded/reconstructed descriptors, generated direct/traced basis fields, precise portable errors and stale-contract-before-selection ordering agree. Root emitted roles inspect source markers and selector plumbing only; standalone root emission remains source-emitter proof outside this selected suite. Cursor prefix binds fifteen roles, seek/consume examples, normalized/loaded policy, descriptor identity, minimal generated family rows, obsolete contract rejection, mixed/recursive/ordered/anchored execution and begins static retired-option scanning through 298; its emitted role also inspects source only.
  Findings: No new confirmed defect. Root/cursor emitted admission roles inspect source; independent emitted root/cursor execution cannot be inferred from their names. Repeated-action independently executes emitted code in this selection. Prior defects and source-repair gates remain.
  Verification: Read repeated-action 334-498 through EOF, root admission 1-536 through EOF in 179/179/178-line outputs, root core 1-229 through EOF, root routes 1-272 through EOF in two 136-line outputs and cursor admission 1-298 in two 149-line outputs: exact 1,500 fragments / 45,785 baseline-identical bytes and ordered digest. All 13 selected tests pass, including the existing independent repeated-action emitted caller. Repeated neutral is eight modes/ten special/eight complete/zero pending/54 mutations; root selection is eight selections/three failures/three strict/five backends/seven complete/zero pending/24 public/18 denials/54 mutations; cursor is 36 families/18 edges/eight parent-child/74 migration files/eight complete/zero pending/60 mutations. No root-specific independent emitted or full CLI/other-runtime gate is newly claimed. Full coverage/preservation, Knowledge/book/memory/histories, whitespace/staged scope and commit-hook doctrines govern the focused commit.
  Commit: `DART-STARTUP-READING.1.44 - complete root selection consumer reading`

- ID: `DART-STARTUP-READING.1.45`
  Status: `done`
  Goal: Read bounded Dart group 45 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.44` committed; empty brief and clean repository.
  Activation: Clean `4d2b242799b74db387eb5c010bb2e83bd923360b`; prior reading committed, root clean, zero-byte brief and all jobs consumed.
  Scope: `dart/test/rule_local_cursor_contract_test.dart` lines 299-456; `dart/test/rule_local_cursor_descriptor_test.dart` lines 1-257; `dart/test/rule_local_cursor_execution_test.dart` lines 1-411; `dart/test/rule_local_cursor_normalization_test.dart` lines 1-267; `dart/test/runtime_interpreter_test.dart` lines 1-407
  Baseline evidence: 1500 fragments / 41762 bytes; ordered range SHA-256 `acfee426913e8f0602f3c8d0e24984ed8845938126fad2a4903ee06830224de6`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact scoped bytes/current deltas; cursor admission/descriptor/execution/normalization and interpreter Dart tests; neutral rule-local cursor contract; prior evidence preservation, Knowledge, doctrines, histories, mdBook, memory and staged scope/whitespace.
  Canonical trigger: `none` — bounded required reading and documentation; no source, contract or infrastructure changes.
  Comprehension: Cursor admission finishes retired-option/CLI denial and exact diagnostic coverage after normalized reconstruction. Descriptor tests compare exact outer/meta/rule fields, authored identity and ordered resolved edges across direct/normalized-AST/loaded routes; action omitted slot becomes zero, blind slot is null, optional source_form is absent. This is an outward projection, not a descriptor decoder. Execution covers all 36 families, eight parent-child and two structural cases through live/reconstructed/generated-v2 routes; each entered rule rederives policy, generated rows contain only label/family, loaded native trace attributes consume/seek per entry, and obsolete global options are source-scanned. Normalization checks exact family metadata, typed complete-line/header-rest bare candidates, lifecycle priority, all contract edges/ownership sets, precise diagnostic fields and JSON roundtrips. These consumers do not independently compile and run emitted modules. Interpreter prefix covers lifecycle collection, child pushes and numeric payload selection, leading-trivia behavior, indexed reads, self-close slots, recursive aggregates, caller-visible undeclared mutations, sequential blind results, rule-local marks, BMP multibyte capture, OR miss/bounds/zero-progress behavior and begins the exact repetition lifecycle assertion.
  Findings: No new confirmed defect. Cursor generated-v2 execution is in-process; emitted entry-point source inspection does not establish standalone emitted execution. Full interpreter test success grants no unread-source credit and does not close earlier defects.
  Verification: Physically read cursor admission 299-456 EOF, descriptor 1-257 EOF, execution 1-206 and 207-411 EOF, normalization 1-267 EOF, and interpreter 1-207/208-407. Execution/normalization outputs lost at a context boundary were reread in full before granting credit. Exact 1,500 fragments / 41,762 bytes and ordered scope digest match the baseline. All 75 tests from the five selected files pass; the full interpreter test file runs, but physical reading stops at 407. Neutral cursor passes 36 family spellings/18 edges/eight parent-child/74 migration files/eight complete/zero pending/60 mutations. Existing emitted admission roles remain source-inspection proof only. Full coverage/preservation, Knowledge/book/memory/histories, whitespace/staged scope and commit-hook doctrines govern the focused commit.
  Commit: `DART-STARTUP-READING.1.45 - complete cursor consumer reading`

- ID: `DART-STARTUP-READING.1.46`
  Status: `done`
  Goal: Read bounded Dart group 46 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.45` committed; empty brief and clean repository.
  Activation: Clean `db762cd7b35b83243467dd117e7e965072e1ddf6`; prior reading committed, root clean, zero-byte brief and all jobs consumed.
  Scope: `dart/test/runtime_interpreter_test.dart` lines 408-1821; `dart/test/runtime_matching_test.dart` lines 1-86
  Baseline evidence: 1500 fragments / 39292 bytes; ordered range SHA-256 `3f375018241ada715ebede846b8f23a8eff225c44ab7717ee258974271afcc3f`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact scoped bytes/current deltas; runtime interpreter and matching Dart tests, plus direct-dependent contract proof when warranted by the read source; prior evidence preservation, Knowledge, doctrines, histories, mdBook, memory and staged scope/whitespace.
  Canonical trigger: `none` — bounded required reading and documentation; no source, contract or infrastructure changes.
  Finding ownership: This leaf owns correction of the stale current nested-write paragraph/status in dart-runtime-core-value-capture-helpers. The dated July 13 fact predates write-vivification-dart-runtime September 2; runtime_interpreter_test 732-789 now expects dense missing-root/intermediate creation. Preserve historical prose while making the current answer point to admitted write-vivification semantics; verify with the existing named regression and neutral contract. No runtime repair or scope pivot.
  Comprehension: Interpreter suffix completes repetition lifecycle order, explicit rewind/save-restore semantics, non-consuming capture boundaries, capture slices and ordinary BMP character helpers. It covers dense missing-root/intermediate writes and detached snapshots, named captures, string/regex/numeric aliases, the 55-case scalar contract, array/hash pure-versus-mutation boundaries, value/marker controls, callback traversal and binding restoration, pure user-function argument isolation/arity/recursion diagnostics, exact selection and callable failures, absent versus zero-width matches and exact pure/position/control/anonymous/named fixtures. Matching prefix tests seek/consume, authored tie and duplicate-slot identity, compiled regex lists, and begins astral capture assertions through 86. These two consumers execute native runtime/matcher routes only; passing normal numeric/Unicode/callback cases does not close earlier overflow, astral-helper, mixed-control or callback-identity defects.
  Capacity intake: .7 owns the next mandatory engineering archive; exact governed draft and 22 real-validator boundary checks pass, all 62 prior history files are restored, and a complete concise dated note lets this verified reading commit before waiting. No limit increase or pivot is applied.
  Findings: Corrected the stale current core-helper fact denying dense nested-write creation; retained the superseded paragraph as dated history and routed current semantics to the admitted September authority. No new runtime defect or repair completion is inferred from passing existing fixtures.
  Verification: Read interpreter 408-643, 644-879, 880-1115, 1116-1351, 1352-1587 and 1588-1821 EOF, then matching 1-86. Exact 1,500 fragments / 39,292 baseline-identical bytes and ordered scope digest pass. All 68 tests in the two selected files pass. Neutral write proof is 5 valid/7 invalid syntax, 11 successes, 16 structural and three evaluation failures, three read exclusions, eight compositions and 105 rejected mutations; numeric is 55 cases/18 helpers; named marks seven helpers/three mutations. The full matching file runs but its unread suffix receives no reading credit. The current July helper fact wrongly denied missing-container creation; the September write-vivification authority and existing dense-write regression establish its correction. Prior prose is retained as dated history. Full coverage/preservation, Knowledge/book/memory/histories, whitespace/staged scope and commit-hook doctrines govern the focused commit.
  Commit: `DART-STARTUP-READING.1.46 - complete interpreter consumer reading`

- ID: `DART-STARTUP-READING.1.47`
  Status: `done`
  Goal: Read bounded Dart group 47 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.46` committed; empty brief and clean repository.
  Activation: Clean `ad64f76fb0c9b79dac18d5b9723eaf108d68954b` after approved containment .11; brief empty, root clean and all jobs consumed.
  Scope: `dart/test/runtime_matching_test.dart` lines 87-256; `dart/test/scalar_text_contract_test.dart` lines 1-26; `dart/test/self_hosted_unicode_rule_label_test.dart` lines 1-60; `dart/test/semantic_index_call_projection_test.dart` lines 1-229; `dart/test/semantic_index_compilation_foundation_test.dart` lines 1-305; `dart/test/semantic_index_query_kernel_test.dart` lines 1-470; `dart/test/semantic_index_runtime_observation_routes_test.dart` lines 1-240
  Baseline evidence: 1500 fragments / 50626 bytes; ordered range SHA-256 `5a4ed53c1cb14de136ea8fbf17e38bdb4d8d0c6b2d7e7564a10f16c0b260ef8a`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact range/digest and complete baseline identity; selected matching/scalar/Unicode/semantic consumers and direct neutral contracts; Knowledge, history pressure, book, all doctrines and preservation.
  Canonical trigger: `None for this bounded required-reading leaf; no runtime, public contract or infrastructure change. Escalate if focused evidence exposes cross-cutting uncertainty.`
  Comprehension: Matching asserts astral/code-unit offsets, bounded structural regex forms, entry/local separation and zero progress. Scalar text executes the neutral fixture; self-hosted tests consume all twelve canonical label atoms and execute all Unicode edge forms. Call projection distinguishes private oracle access and typed staged/generated records. Compilation preserves phase-specific outcomes without executing target actions. Public query locks nineteen static digests, twenty-six malformed JSON boundaries and source ceilings; those controls do not close non-JSON rejection .2.21. Observation prefix runs generated direct/traced identity and exit omission, then begins the standalone emitted child source through its trace config; remaining child/harness bytes belong to .1.48.
  Verification: Physically read matching87-256 EOF, scalar1-26 EOF, Unicode1-60 EOF, call projection1-229 EOF, compilation1-160/161-305 EOF, query1-220/221-470 EOF and observation routes1-240. Exact1500 fragments/50626 bytes and digest pass; all115 baseline paths remain identical. All30 selected tests pass, including the full existing standalone emitted observer test; running that complete test grants no unread suffix credit. Neutral semantic is6 groups/20 exact queries/128 mutations, rollout9/0 and admission6/0; Unicode17 is806 ranges/9 positive/8 negative/2 distinct pairs. Prior .2.8/.2.20/.2.21 and startup .67/.70 remain open. Coverage/preservation, Knowledge/book/memory/histories, diff hygiene and all doctrines govern the focused commit.
  Commit: `DART-STARTUP-READING.1.47 - read matching and semantic consumer contracts`

- ID: `DART-STARTUP-READING.1.48`
  Status: `done`
  Goal: Read bounded Dart group 48 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.47` committed; empty brief and clean repository.
  Activation: Clean `af15ee1c818ea50bd63eab84bfb9938e2ef59869`; prior leaf committed, brief empty, root clean and all jobs consumed.
  Scope: `dart/test/semantic_index_runtime_observation_routes_test.dart` lines 241-462; `dart/test/semantic_index_runtime_observation_test.dart` lines 1-284; `dart/test/semantic_index_runtime_projection_test.dart` lines 1-281; `dart/test/semantic_index_source_foundation_test.dart` lines 1-299; `dart/test/semantic_index_static_graph_test.dart` lines 1-248; `dart/test/semantic_introspection_dart_admission_test.dart` lines 1-166
  Baseline evidence: 1500 fragments / 48937 bytes; ordered range SHA-256 `8ad7fb9cc1bf8824d136e740381789ad3cb097cc6ba3bb6f0856a909e44deb07`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact range/digest and complete baseline identity; selected observation/source/static consumers and direct neutral semantic contract; Knowledge, histories, book, all doctrines and preservation.
  Canonical trigger: `None for this bounded required-reading leaf; no runtime, public contract or infrastructure change. Escalate if focused evidence exposes cross-cutting uncertainty.`
  Comprehension: The emitted observer harness requires exit0 for offline pub get, fatal analysis and execution, checks direct/traced result, trace/diagnostic and callback identity, validates exact events/digest/exit omission and removes its owned scratch. Native capture covers direct/loaded/reconstructed/generated-plan/traced entries and Unicode positions. Observed-index derivation locks detached base/results, malformed-event rejection and static selector ownership. Source tests check strict byte/text, scalar/CRLF coordinates, ceilings and deterministic early failures; static tests separate raw foundation diagnostics from normalized oracle evidence and occurrence-specific lifecycle shapes. Admission prefix defines exactly twelve ordered roles, verifies registration/rollout, reads source/compiled/failed/direct and starts loaded/reconstructed runtime; .1.49 owns the remainder.
  Verification: Physically read observation routes241-462 EOF; observation1-150/151-284 EOF; projection1-155/156-281 EOF; source1-164/165-299 EOF; static1-248 EOF; admission1-166. Exact1500 fragments/48937 bytes and digest pass; all115 baseline paths remain identical. All24 tests from six selected files pass, including existing standalone emitted execution and twelve-role admission; no unread suffix credit is inferred. Neutral semantic passes6 groups/20 exact queries/128 mutations, rollout9/0 and admission6/0. Prior action-wrapped observer .2.8, non-JSON query .2.21 and source-correlation owners remain open. Coverage/preservation, Knowledge/book/memory/histories, diff hygiene and all doctrines govern the focused commit.
  Commit: `DART-STARTUP-READING.1.48 - read semantic observation and source consumers`

- ID: `DART-STARTUP-READING.1.49`
  Status: `done`
  Goal: Read bounded Dart group 49 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.48` committed; empty brief and clean repository.
  Activation: Clean `df34dc4cc0a88e7ece0e056581bc88a6196f1269`; prior leaf committed, brief empty, root clean and all jobs consumed.
  Scope: `dart/test/semantic_introspection_dart_admission_test.dart` lines 167-779; `dart/test/smoke_test.dart` lines 1-16; `dart/test/source_boundary_compatibility_aliases_test.dart` lines 1-342; `dart/test/source_emitter_test.dart` lines 1-529
  Baseline evidence: 1500 fragments / 48927 bytes; ordered range SHA-256 `e2a11d82a1f815d300cef855cb47bc8ecae541e94b10a673fd7aa343f8123b98`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact range/digest and full baseline identity; admission, smoke, alias and emitter consumers plus semantic/typed-source/generated-source neutral authorities; Knowledge, histories, book, all doctrines and preservation.
  Canonical trigger: `None for this bounded required-reading leaf; no runtime, public contract or infrastructure change. Escalate if focused evidence exposes cross-cutting uncertainty.`
  Comprehension: Admission completes loaded/reconstructed/generated/traced routes, typed/raw query equality, twenty digests, privacy/budget/error/explanation and non-interference. Its one cached emitted probe uses inherited managed environment, successful offline resolution/run and trace presence; it is distinct from fresh empty PUB_CACHE/fatal-analysis alias and emitter consumers. All seven source-boundary aliases canonicalize with authored arity preserved, retain unknown-name diagnostics and match Unicode normal/reversed captures across native/reconstructed/generated/emitted routes. Emitter prefix verifies deterministic v2 metadata/errors/minimal plan, all ten family policies, early v1 rejection before corrupt lazy payload, selected-root traces and isolated ten-family execution, then starts the eight-case subset setup through529; .1.50 owns the remaining subset/harness/fixtures.
  Verification: Physically read admission167-380/381-580/581-779 EOF, smoke1-16 EOF, aliases1-176/177-342 EOF and emitter1-180/181-360/361-529. Exact1500 fragments/48927 bytes and digest pass; all115 baseline paths remain identical. All12 tests in four selected files pass, including fresh offline emitted alias/root/family/subset callers and the existing twelve-role admission; running complete emitter grants no unread suffix credit. Semantic6/20/128, typed-source14/0/231 with92+7 helper inventory, and generated-source v1 neutral ten-family/eight-case-subset topology checks pass; neutral ledger checks do not run other backends. Prior .2.8/.2.20/.2.21 and related owners remain open. Coverage/preservation, Knowledge/book/memory/histories, diff hygiene and all doctrines govern the focused commit.
  Commit: `DART-STARTUP-READING.1.49 - complete admission and read source-emitter consumers`

- ID: `DART-STARTUP-READING.1.50`
  Status: `done`
  Goal: Read bounded Dart group 50 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.49` committed; empty brief and clean repository.
  Activation: Clean `fd812044d894e95664258e6b2cac6bf8e02f5f8a`; prior leaf committed, brief empty, root clean and all jobs consumed.
  Scope: `dart/test/source_emitter_test.dart` lines 530-866; `dart/test/spec_ast_test.dart` lines 1-104; `dart/test/spec_loader_test.dart` lines 1-268; `dart/test/spec_parser_test.dart` lines 1-256; `dart/test/spec_validator_test.dart` lines 1-244; `dart/test/staged_ast_enrichment_contract_test.dart` lines 1-291
  Baseline evidence: 1500 fragments / 45895 bytes; ordered range SHA-256 `28ad1b8331d1a781e44aa8f0e1a1a83d54ff2a6431665ccca31ecf1caa7133d5`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact range/digest and full baseline identity; emitter/AST/loader/parser/validator/staged consumers and direct neutral authorities; Knowledge, histories, book, all doctrines and preservation.
  Canonical trigger: `None for this bounded required-reading leaf; no runtime, public contract or infrastructure change. Escalate if focused evidence exposes cross-cutting uncertainty.`
  Comprehension: Emitter completion executes the accepted eight-case subset with native/oracle comparison, generated metadata/plans, trace evidence, successful fresh-cache offline resolution/analysis/run and cleanup; the ten family fixtures and process helper finish the file. AST checks JSON round trips and mode helpers. Loader consumes exact neutral names/resolution/text plus staged-function execution and structured failure identity, using directories as non-regular surrogates. Parser/validator prove shipped sources and greater-than80 corpus rule files while skipping first-significant-line fn sources; those checks are parsing/validation, not complete runtime corpus proof. Staged prefix freezes current neutral/public status and unchanged legacy function-body v1 execution/failure/v2 rejection, then starts exclusive typed-assignment inspection through291. The old comment describes the original private admission; current public state comes from the contract, not that historical comment.
  Verification: Physically read emitter530-705/706-866 EOF, AST1-104 EOF, loader1-144/145-268 EOF, parser1-133/134-256 EOF, validator1-244 EOF and staged1-155/156-291. Exact1500 fragments/45895 bytes and digest pass; all115 baseline paths remain identical. All54 tests in six selected files pass, including complete existing emitted and four-route staged consumers; running whole staged consumer grants no unread suffix credit. Native resolution14/9/4, generated-source ten-family/eight-subset governance and staged123/public129 mutation checks pass. No fresh other-backend runtime claim, prior-defect closure or source change. Coverage/preservation, Knowledge/book/memory/histories, diff hygiene and all doctrines govern the focused commit.
  Commit: `DART-STARTUP-READING.1.50 - complete frontend and emitter consumer reading`

- ID: `DART-STARTUP-READING.1.51`
  Status: `done`
  Goal: Read bounded Dart group 51 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.50` committed; empty brief and clean repository.
  Activation: Clean `623844b2c7c4936efe216efbf264d8df1dcb0ec6`; prior leaf committed, brief empty, root clean and all jobs consumed.
  Scope: `dart/test/staged_ast_enrichment_contract_test.dart` lines 292-1791
  Baseline evidence: 1500 fragments / 50285 bytes; ordered range SHA-256 `fb9147ec31a50756ce20735ab8b49a432ec1b7dacc13e8a20ee11803f68abbae`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact range/digest and full baseline identity; staged consumer and direct staged/typed-source neutral authorities; Knowledge, histories, book, all doctrines and preservation.
  Canonical trigger: `None for this bounded required-reading leaf; no runtime, public contract or infrastructure change. Escalate if focused evidence exposes cross-cutting uncertainty.`
  Comprehension: Typed assignment becomes one inert marker across native/reconstructed/generated/emitted routes; emitted marker caller uses the existing Dart package context and requires fatal analysis/exit0. Eight provenance rows, distinct ordered capture spans and malformed annotation/recognition denials precede frozen registry resolution/cache/authority tests. One-depth callbacks get fresh sibling state and atomic detached policies; conflicts reject before dispatch and plan caching never caches results. Recursive tests pin BFS order, shared token/deadline/steps/cache, inert nested markers, revoked contexts, cycle/nondecrease/depth/call entry guards, callback safe points, result/diagnostic spending and direct/derived diagnostic rebasing. Four-route production admission begins through1791; its emitted execution assertions/helpers belong to .1.52. Existing tiny diagnostic allowance, wrapped call counter and malformed provenance-type defects remain open.
  Verification: Physically read292-1541 in five250-line windows, then1542-1666/1667-1791 after rereading truncated output without credit. Exact1500 fragments/50285 bytes and pinned digest pass; all115 baseline paths remain identical. All19 staged tests pass, including the complete existing four-route consumer; no unread suffix credit. Neutral staged123/public129 and typed-source14/0/231 pass. Coverage/preservation, Knowledge/book/memory/histories, diff hygiene and all doctrines govern this focused documentation commit. Reconcile the stale parent36/55 rollup to the verified child statuses without rewriting prior child evidence.
  Commit: `DART-STARTUP-READING.1.51 - read staged enrichment authority consumers`

- ID: `DART-STARTUP-READING.1.52`
  Status: `done`
  Goal: Read bounded Dart group 52 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.51` committed; empty brief and clean repository.
  Activation: Clean `9092add37febb1c57293d8dc2356ca36ade12379`; prior leaf committed, brief empty, root clean and all jobs consumed.
  Scope: `dart/test/staged_ast_enrichment_contract_test.dart` lines 1792-2399; `dart/test/staged_parser_registry_test.dart` lines 1-425; `dart/test/standalone_lifecycle_block_contract_test.dart` lines 1-207; `dart/test/trace_test.dart` lines 1-260
  Baseline evidence: 1500 fragments / 44374 bytes; ordered range SHA-256 `af4afe6ffa013327537799d74b93095449f46cf6d6238a6bbf316a8345f702e9`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact declared ranges and full baseline identity; staged enrichment/registry/lifecycle/trace tests and direct staged/lifecycle neutral authorities and trace API contract reconciliation; Knowledge, histories, rendered book, preservation and all doctrines.
  Canonical trigger: `none` — ordinary bounded reading and documentation; no executable, contract, infrastructure or dependency changes.
  Comprehension: Staged production admission requires fatal emitted-source analysis and successful execution in the existing package context, comparing native/reconstructed/generated/emitted records for two calls per seed. Helpers expose fresh authority starts, callback/cache/resource counters and identity projections, with no serialized host authority. V1 registry tests cover stable queues, exact cache descriptors, immutable body_ast stitching and resolve/compile/stitch errors; they do not implement v2 scheduling. Lifecycle twins preserve authored source/opening lines, normalized payloads and duplicate order through native/reconstructed/generated-plan execution; emitted source is only checked nonempty, and malformed twins compare exception type/nonempty messages. Legacy plain payloads remain inert. Trace tests cover level aliases, filtering, environment controls, reset/route/mirror, structured events and unchanged parse results with action/blind/cursor/boundary trace detail; the temporary-file helper tail belongs to .1.53.
  Verification: Physically read staged1792-1991/1992-2191/2192-2399 EOF, registry1-220/221-425 EOF, lifecycle1-207 EOF and trace1-130/131-260 in untruncated output. Exact 1500 fragments / 44374 bytes and digest pass; all 115 baseline paths remain identical. All 38 tests in four selected files pass, including complete existing staged emitted admission and trace consumer; no unread tail credit. Neutral staged123/public129 and lifecycle9/4/6/3 with14 mutations pass. Coverage/preservation, Knowledge/book/memory/histories, diff hygiene and all doctrines govern the focused commit. No fresh other-backend execution or closure of prior defects.
  Commit: `DART-STARTUP-READING.1.52 - complete staged and lifecycle consumer reading`

- ID: `DART-STARTUP-READING.1.53`
  Status: `done`
  Goal: Read bounded Dart group 53 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.52` committed; empty brief and clean repository.
  Activation: Clean `9bd2f680500ad85f76e45656805840b282538d73`; prior leaf committed, brief empty, root clean and all jobs consumed.
  Scope: `dart/test/trace_test.dart` lines 261-269; `dart/test/typed_source_location_contract_test.dart` lines 1-420; `dart/test/unicode_case_mapping_test.dart` lines 1-58; `dart/test/unicode_rule_label_classifier_test.dart` lines 1-84; `dart/test/unicode_rule_label_identity_routes_test.dart` lines 1-416; `dart/test/unicode_rule_label_negative_isolation_test.dart` lines 1-443; `dart/test/unicode_rule_label_routes_test.dart` lines 1-70
  Baseline evidence: 1500 fragments / 44020 bytes; ordered range SHA-256 `e2e59b430e816290b10dd28f0d6aa8faed7bf523c673a86ee5532430e836a82a`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact declared ranges and full baseline identity; trace/typed-source/Unicode tests and direct typed-source/Unicode neutral authorities; Knowledge, histories, rendered book, preservation and all doctrines.
  Canonical trigger: `none` — ordinary bounded reading and documentation; no executable, contract, infrastructure or dependency changes.
  Comprehension: Trace tail registers teardown for managed temporary directories. Typed-source tests exercise three source entries, seven coordinate rows, six direct spans, three ordered-derived cases, detached values, four exact privacy-filtered errors and 92 projection rows plus seven aliases. Three mark/cursor/alias fixtures execute through native/reconstructed/generated-plan routes without an independent emitted module. Casing consumes all twelve neutral fixtures through direct/helper/receiver/array paths. Classifier checks metadata, both endpoints of806 ranges, sentinel denials, fixture membership/distinctness and UTF-16-safe prefix splits. Unicode identity checks artifacts, loaders, in-process CLI, selector diagnostics/traces and a fresh offline package with fatal emitted analysis/exit0 execution; the file CLI covers the supplementary label, while inline CLI covers all labels. Eight negative fixtures reject four roles on two AST trust paths with exact diagnostics; source colon/newline exceptions and adjacent identifier grammars stay explicit. Existing body-fluent suffix loss .2.6 remains outside those passing isolation fixtures. Unicode routes1-70 begins declaration/edge identity and the invalid suffix list.
  Verification: Physically read trace261-269 EOF, typed-source1-210/211-420 EOF, casing1-58 EOF, classifier1-84 EOF, identity1-208/209-416 EOF, negative isolation1-222/223-443 EOF and routes1-70 in untruncated output. Exact1500 fragments/44020 bytes and pinned digest pass; all115 baseline paths remain identical. All29 tests in seven selected files pass, including fresh-cache emitted Unicode execution; whole routes-test execution adds no unread suffix credit. Neutral typed-source14/0/231, Unicode labels806/9/8/2 and casing1563/1581 mappings,158/464 ranges,12 fixtures pass. Coverage/preservation, Knowledge/book/memory/histories, diff hygiene and all doctrines govern the focused commit. Prior .2.3/.2.6/.2.13 defects remain open; no source or other-backend runtime change.
  Commit: `DART-STARTUP-READING.1.53 - read typed source and Unicode consumers`

- ID: `DART-STARTUP-READING.1.54`
  Status: `done`
  Goal: Read bounded Dart group 54 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.53` committed; empty brief and clean repository.
  Activation: Clean `0b06ccdc0951947be9a74936de7d108185c597af`; prior leaf committed, brief empty, root clean and all jobs consumed.
  Scope: `dart/test/unicode_rule_label_routes_test.dart` lines 71-259; `dart/test/uniform_binding_contract_test.dart` lines 1-487; `dart/test/user_function_definition_parser_test.dart` lines 1-93; `dart/test/user_function_definition_shell_test.dart` lines 1-210; `dart/test/variadic_user_function_contract_test.dart` lines 1-229; `dart/test/write_vivification_contract_test.dart` lines 1-292
  Baseline evidence: 1500 fragments / 44403 bytes; ordered range SHA-256 `fceaac51ed040029358f4fdc5c94bab56751241105a9b18d1270ee36a0932a87`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact declared ranges and full baseline identity; Unicode route/binding/function/write-vivification tests and direct Unicode/binding/variadic/write-vivification neutral authorities; Knowledge, histories, rendered book, preservation and all doctrines.
  Canonical trigger: `none` — ordinary bounded reading and documentation; no executable, contract, infrastructure or dependency changes.
  Comprehension: Unicode route tail rejects whole malformed declarations/targets and exact programmatic/JSON roles. Uniform binding rejects retired exact selectors even in dead/unused code and caller-constructed generated payloads, retains constructors, detached mutation results, rule-call precedence, pure/mutable split, kind diagnostics, recursive local bindings and empty rule accumulators on native/generated-plan routes. Function parser tests execute the owning spec, normalize wrappers and compose staged bodies; shell tests retain source lines and job identity, reject drift and do not raw-scan absent definition nodes. Variadic tests preserve exact fixed-v1/variadic-v2 records, fresh rest arrays, once-only left-to-right arguments, distinct arity failures and keyword rejection. Their emitted proof decodes/recompiles payload JSON rather than executing a separate module. Write prefix defines neutral literal/effect/diagnostic adapters, constructs an empty-segment malformed carrier and checks five typed AST cases through292; remaining syntax/runtime assertions belong to .1.55.
  Verification: Physically read Unicode routes71-259 EOF, binding1-165/166-330/331-487 EOF, function parser1-93 EOF, shell1-210 EOF, variadic1-229 EOF and write1-146/147-292 in untruncated output. Exact1500 fragments/44403 bytes and digest pass; all115 baseline paths remain identical. All43 tests in six selected files pass, including the complete existing emitted write-vivification consumer; no unread write suffix credit. Neutral Unicode806/9/8/2, binding11/7/6/8, callable3/9/7 and write5/7/11/16/3/3/8 with105 mutations pass. Coverage/preservation, Knowledge/book/memory/histories, diff hygiene and all doctrines govern the focused commit. No new runtime defect, repair or other-backend execution claim.
  Commit: `DART-STARTUP-READING.1.54 - read binding and function consumers`

- ID: `DART-STARTUP-READING.1.55`
  Status: `done`
  Goal: Read bounded Dart group 55 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.54` committed; empty brief and clean repository.
  Activation: Clean `d62f2463dfa21cbd2fe8d0142ebb67ffcc5e6fa6`; prior leaf committed, brief empty, root clean and all jobs consumed.
  Scope: `dart/test/write_vivification_contract_test.dart` lines 293-767; `dart/test_dormant/progressive_span_dispatch_authority_test.dart` lines 1-794
  Baseline evidence: 1269 fragments / 40299 bytes; ordered range SHA-256 `9b6f6e3fb70c306559fde67a2815ffad9a004e2c586bbd6e5f1663b2b3a25d0b`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification tier: `focused`
  Focused checks: Exact declared ranges and full baseline identity; write-vivification and private progressive-authority consumers, current admitted progressive consumer, direct write/progressive neutral authorities; Knowledge, histories, rendered book, preservation and all doctrines.
  Canonical trigger: `none` — ordinary bounded reading and documentation; no executable, contract, infrastructure or dependency changes.
  Comprehension: Write tests finish exact syntax/astral spans, eleven success/effect rows, sixteen structural failures after RHS, three identity-preserved exceptions injected through the diagnostic sink, three read exclusions, detached aggregates, fresh locals/bound-null conflicts and malformed compiled-carrier guards. The representative nested write survives reconstructed/generated/inline-CLI routes and a fresh offline emitted package with successful analysis/run and cleanup. Private progressive tests cover neutral views/grants/cancellation/chains/execution and all26 diagnostic codes, nested scalar rebasing/shared invocation counters, expired views/requests, detached/cyclic/node-limited results and one-byte diagnostic truncation. Its parent-state fixture is an isolated local copy, not an injected engine state. The authority-only test remains dormant/private; admitted carrier proof is separate. Historical RED/pending comments are superseded by current nine-leg complete governance. Startup .37 still owns nested effective-authority inheritance; passing permissive nested fixtures do not close it.
  Verification: Physically read write293-450/451-608/609-767 EOF and dormant authority1-200/201-400/401-600/601-794 EOF in untruncated output. Exact1269 fragments/40299 bytes and digest pass. All115 baseline files remain identical; all55 children cover80297 fragments/2471305 bytes through every EOF. All20 selected tests pass: nine write, four private authority and seven admitted progressive groups, including independent existing emitted callers. Neutral write105 and progressive9/9 complete/zero pending/116 plus public60 pass. Correct stale admission-status wording while retaining its historical evidence. Coverage/preservation, Knowledge/book/memory/histories, diff hygiene and all doctrines govern this ordinary focused leaf; .3 retains canonical milestone and child-commit proof, and no repair closes here.
  Commit: `DART-STARTUP-READING.1.55 - complete planned Dart source reading`

- ID: `DART-STARTUP-READING.2`
  Status: `pending`
  Goal: Reconcile and retain ownership of every confirmed Dart finding established during the reading.
  Dependencies: Findings from `.1`; implementation additionally requires startup `.3`, `.4` and `.5`.
  Children: `.2.1`, `.2.2`, `.2.3`, `.2.4`, `.2.5`, `.2.6`, `.2.7`, `.2.8`, `.2.9`, `.2.10`, `.2.11`, `.2.12`, `.2.13`, `.2.14`, `.2.15`, `.2.16`, `.2.17`, `.2.18`, `.2.19`, `.2.20`, `.2.21`, `.2.22`, `.2.23`, `.2.24`, `.2.25`; further confirmed findings receive disjoint owners here.
  Acceptance: Cross-reference existing owners for known defects; create disjoint bounded repair children here
    immediately for new confirmed defects, with mechanism, source, reproduction, acceptance and unblock conditions.
    If no new repair is needed, close this intake with an explicit complete reconciliation rather than inventing work.
  Verification: `pending`; `.1.3` owns attached-switch omission/default replacement under `.2.1`; `.1.5` confirms regex-brace action scanning and lifecycle validation defects under `.2.2`. Reading .1.6 confirms numeric trace overflow and reset-before-failure under .2.3. Reading .1.7 confirms disconnected recognition effect validation, leaked writes after rollback and observation edge-closure bypass under .2.4. Reading .1.10 confirms MCP Unicode key-order divergence under .2.5. Reading .1.11 confirms regex/lifecycle-E body suffix loss under .2.6. Reading .1.12 confirms compact fluent argument corruption under .2.7 and outer regex-brace truncation under existing .2.2.2. Reading .1.13 confirms standalone body-fluent suffix loss under existing .2.6. Reading .1.16 confirms semantic observer error/stack loss through action child calls under .2.8; startup .37 retains nested progressive authority findings from .1.15. Reading .1.17 confirms mixed-control return escape and skipped attached else under .2.9. Reading .1.18 confirms helper-name callback recursion collision and lost bound identity under .2.10. Reading .1.19 confirms hash splice pairing/order loss under .2.11, coordinated with FUTURE-PARITY-BACKLOG.5. Reading .1.20 confirms finite-number corruption (.2.12), lexical Unicode ordering (.2.13) and slice-end overflow (.2.14), with separate existing startup .55/.60 and MCP .2.5 coordination. Reading .1.21 extends .2.14 with typed-source overflow and owns input_slice zero-argument acceptance/late-reference failure under .2.15. Reading .1.23 confirms lower-unbounded quantifier rewriting of escaped literals/classes under .2.16. Reading .1.26 confirms staged diagnostic-byte overruns under .2.17 and wrapped staged call admission under .2.18 through eleven private scheduler controls. Reading .1.27 confirms malformed staged source/provenance types accepted after placeholder coercion under .2.19 through seventeen private/neutral controls. Reading .1.30 extends startup .67 with Dart container-call omission and owns regex call/source miscorrelation under .2.20 through nine public-query/typed-runtime controls. Reading .1.31 owns native non-JSON rejection response mutability/encoding under .2.21 through eight public raw-query controls, with four defective cases and four valid JSON controls. Reading .1.33 extends startup .70 with Dart grouped-selector constructor failures and owns regex-arrow selector correlation under .2.22 through eight public compiled/index/runtime controls. Reading .1.35 confirms null named-selector provenance selecting an anonymous regex through SpecFile reconstruction under .2.23; ten controls include two wrong-slot acceptances, six valid/rejecting controls and two additional provenance census inputs. Closeout audit .3.1 additionally owns current formatter drift/non-writing gate under .2.24 and deprecated structural-regex adapters under .2.25. No repair implementation is admitted before startup gates.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.1`
  Status: `pending`
  Goal: Prevent attached-switch parsing and resolution from silently discarding authored body content.
  Dependencies: Startup `.3`, `.4` and `.5`; source finding from `.1.3`.
  Children: `.2.1.1`, `.2.1.2`
  Evidence: `docs/knowledge/dart-attached-switch-body-omission.md` owns exact API probes and source locations. A trailing unknown helper survives in body.statements but is absent from extracted cases and contract diagnostics; native and SpecFile-reconstructed execution return the selected case value. A second default replaces the first in the extracted default field.

- ID: `DART-STARTUP-READING.2.1.1`
  Status: `pending`
  Goal: Define and lock complete attached-switch body validation against the normative control contract.
  Dependencies: Startup `.3`, `.4` and `.5`.
  Acceptance: Compare authored trailing/interleaved non-branch statements, duplicate defaults, malformed branches and valid nested/empty/default forms against the normative grammar and Perl reference. Establish independent expected diagnostics and precise source spans; preserve lazy branch execution. Own any affected cross-backend follow-ups before changing them; ask the director only if the intended syntax remains genuinely unresolved.
  Verification: `pending`; five controlled Dart native/reconstructed probes are durable in the finding card; no fresh proof for other backends or emitted carriers.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.1.2`
  Status: `pending`
  Goal: Implement the resolved attached-switch validation without partial AST acceptance or lost diagnostics.
  Dependencies: `.2.1.1` and startup gates.
  Acceptance: Reject or explicitly account for every authored body statement and duplicate default according to the resolved contract; preserve valid branch order, first-match selection, nested switches, returns and deferred callable bodies. Cover parser/resolver, normal compilation, supported reconstructed/generated/emitted carriers and public examples with focused negative/positive proof; use canonical verification if the shared/public contract moves.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.2`
  Status: `pending`
  Goal: Preserve regex-literal braces through Dart action parsing and lifecycle balance validation.
  Dependencies: Startup `.3`, `.4` and `.5`; coordinate existing startup `.54.3` cross-backend closeout.
  Children: `.2.2.1`, `.2.2.2`
  Evidence: `.1.5` public AST probes accept standalone /(})/ but turn its attached-if use into raw_perl; /}/, /(x)/ and quoted-pattern controls retain control_if. Programmatic SpecFile compilation rejects both regex-brace forms with one unmatched close, while ordinary-group and quoted-pattern controls execute true. Exact source/probes belong to docs/knowledge/dart-regex-brace-scanner-defects.md.

- ID: `DART-STARTUP-READING.2.2.1`
  Status: `pending`
  Goal: Repair ActionIR regex-start classification so grouped regex braces cannot end an enclosing block.
  Dependencies: Startup `.3`, `.4` and `.5`; .2.2.2 validator repair precedes combined execution proof.
  Acceptance: Lock standalone versus nested /(})/ parsing with /}/, /(x)/, quoted patterns and symbolic division controls. Reconcile _looksLikeRegexStart and delimiter/scanner callers; preserve regex groups, escapes, classes, whitespace, exact source spans and malformed diagnostics without widening division into a regex. Add focused parser and supported execution-carrier proof after the validator repair permits normal compilation.
  Verification: `pending`; current _looksLikeRegexStart returns false when slash is followed by opening parenthesis; _findMatchingDelimiter then counts the regex's closing brace as the enclosing block delimiter.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.2.2`
  Status: `pending`
  Goal: Repair lifecycle balance validation so accepted regex braces are not counted as block syntax.
  Dependencies: Startup `.3`, `.4` and `.5`; coordinate `.2.2.1`.
  Acceptance: Preserve quote/regex lexical boundaries in _braceDepthDelta and audit relevant Dart outer collectors before claiming authored-source coverage. Cover normal programmatic and source compilation, native/reconstructed/generated/emitted routes, valid regex-brace controls and truly malformed blocks; retain original diagnostic/source ownership. Freeze validator-specific controls independently of .2.2.1; combined grouped-regex execution follows that action-scanner repair. Route broad public/cross-backend recurrence through startup `.54.3` rather than duplicating that closeout.
  Verification: `pending`; programmatic SpecFile bypasses the outer source collector yet rejects both /}/ and /(})/ with unbalanced braces, one unmatched close. _braceDepthDelta tracks quotes/escapes and braces but no regex state. No Dart outer collector or emitted-carrier result is inferred.
  Reading update .1.12: Four additional authored-source controls now establish outer truncation at /}/ and /(})/: _scanLineForBraces at spec_parser.dart:1381 stops at the regex close, producing partial lifecycle code and a Raw suffix rejected by validation. Ordinary regex and quoted-brace controls execute true. This updates the earlier outer-collector uncertainty; emitted/other-backend proof remains separate. Exact replay: docs/knowledge/dart-spec-lexical-boundary-defects.md.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.3`
  Status: `pending`
  Goal: Make primary trace-level validation total and complete before trace-file reset.
  Dependencies: Startup `.3`, `.4` and `.5`; source finding from `.1.6`.
  Acceptance: Reconcile numeric range semantics with ADR 0024, the neutral CLI manifest and reference adapter; freeze signed boundary/overflow, ordinary numeric/named, invalid and help controls. Parse/validate trace configuration once before file mutation, preserving valid silent reset and routing. Oversized values must follow resolved portable behavior without uncaught host exceptions; rejected arguments must preserve an existing trace file. Cover the adapter API and process boundary, both option environments and source/input/error controls; own any affected other-backend contract work before changing it and use canonical proof if shared/public semantics move.
  Verification: `pending`; seven controlled adapter calls show signed 64-bit endpoints and 0/100 succeed; values immediately outside the endpoints throw StateError after truncation, while invalid text returns usage 2 and preserves the sentinel. Exact current source chain and executable replay live in docs/knowledge/dart-primary-cli-trace-overflow.md. No process-exit or other-backend result is inferred.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.4`
  Status: `pending`
  Goal: Enforce recognition effects on actual executable Dart rule paths before an attempted child can perform forbidden work.
  Dependencies: Startup `.3`, `.4` and `.5`; source finding from `.1.7`.
  Children: `.2.4.1`, `.2.4.2`, `.2.4.3`
  Evidence: docs/knowledge/dart-recognition-effect-integration-gap.md owns eight exact controls. The authority rejects binding_write, but a recognized child writes seen=1 and rollback retains it. Observation through ordinary call is compile-rejected; equivalent action/blind edges enter Observer and finish. The generic classifier has no production caller; compiler observation closure omits structural edges.

- ID: `DART-STARTUP-READING.2.4.1`
  Status: `pending`
  Goal: Freeze complete executable recognition-effect graph ownership and independent negative controls.
  Dependencies: Startup `.3`, `.4` and `.5`.
  Acceptance: Reconcile neutral closed node/helper effects and reference behavior with all actual Dart lifecycle, payload, fluent, function, callable and structural action/blind routes. Account for direct/mutual recursion, unknown or dynamic calls and lazy bodies without executing them. Freeze the eight intake controls plus each applicable forbidden-effect family; define exact diagnostic/phase expectations and route any other-backend findings to distinct owners. Do not widen rollback into binding snapshots as a substitute for the rejected-effect contract.
  Verification: `pending`; intake proves one generic binding-write leak and two structural observation bypasses, not every effect family or carrier.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.4.2`
  Status: `pending`
  Goal: Connect complete recognition-effect validation to compilation and executable-state admission.
  Dependencies: `.2.4.1` and startup gates.
  Acceptance: Build and validate the resolved executable graph before attempted child effects, including action/blind transitions and user functions; preserve the closed neutral vocabulary and fail-closed unknown behavior. Eliminate the detached-classifier gap and the special observation closure bypass while retaining valid pure/source/cursor/mark/staged-return paths. Cover ordinary parsed and caller-constructed compiled state, invalidated tokens and runtime admission ordering; preserve valid rollback semantics and existing diagnostics.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.4.3`
  Status: `pending`
  Goal: Close recognition effect integration through supported carriers and public evidence.
  Dependencies: `.2.4.2`.
  Acceptance: Prove negative and positive paths through native, normalized reconstruction, generated plans and fresh emitted Dart, with graph-derived proof that the classifier is connected rather than tested only by direct neutral calls. Run direct-dependent recognition/observation/progressive/staged and public no-drift checks; qualify earlier admission evidence accurately, update the book and execute canonical closeout. Other backends retain separate evidence and owners.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.5`
  Status: `pending`
  Goal: Make Dart MCP canonical JSON ordering agree with the neutral owner for valid Unicode keys.
  Dependencies: Startup `.3`, `.4` and `.5`; source finding from `.1.10`.
  Children: `.2.5.1`, `.2.5.2`
  Evidence: docs/knowledge/dart-mcp-unicode-key-order-gap.md owns four direct production-helper controls. ASCII and BMP ordering match the neutral canonical_bytes owner; a U+10000 key sorts before U+E000 in Dart, contrary to the neutral order, both at the root and nested. SplayTreeMap uses Dart's default string comparison. A fifth probe reaches public decoded dispatch through an injected schema-valid query-result seam and preserves equal JSON values with unequal neutral text bytes. Native-produced payload reach, wire and other serializers still require proof.

- ID: `DART-STARTUP-READING.2.5.1`
  Status: `pending`
  Goal: Freeze the exact portable Unicode key-order contract and affected Dart serializer routes.
  Dependencies: Startup `.3`, `.4` and `.5`.
  Acceptance: Compare the neutral canonical byte owner with MCP helper, public dispatch/wire and native semantic payload routes using ASCII, BMP, supplementary-plane, nested and normalization-distinct controls. Inventory other Dart canonical serializers and give each confirmed affected surface explicit ownership. Distinguish injected test payloads from values produced by native SemanticIndex; retain admitted ASCII bytes and establish independent expected UTF-8 output and digests.
  Verification: `pending`; four helper probes have two passing controls and two mismatches; a fifth controlled query-result injection proves public decoded-dispatch text divergence. No native-produced payload, wire, emitted carrier or other-backend outcome is inferred.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.5.2`
  Status: `pending`
  Goal: Implement the resolved canonical Unicode ordering and recurring byte-identity coverage.
  Dependencies: `.2.5.1` and startup gates.
  Acceptance: Use the resolved portable comparison on every confirmed affected owned path without normalizing keys, changing array order or weakening duplicate/string validation. Cover direct helpers and proven public native/dispatch/wire carriers with exact nested Unicode bytes, neutral identity, unchanged generated bundle and existing MCP contracts. Update public qualifications and require canonical proof if shared/public canonical behavior moves.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.6`
  Status: `pending`
  Goal: Preserve unsupported Dart body suffixes so validation cannot accept partially consumed source.
  Dependencies: Startup `.3`, `.4` and `.5`; source finding from `.1.11`. Coordinate Rust startup `.53` and the standalone lifecycle diagnostic-precedence contract.
  Acceptance: Lock all fourteen intake controls, including header/body regex and lifecycle-E suffixes, own-line rejection, valid comments, explicit/bare lifecycle-I rejection and malformed action-edge rejection. Preserve unconsumed source and its exact origin through both body loops without breaking recognized successor/header handling or existing typed-diagnostic precedence. Reconcile intentional permissive AST/legacy Raw handling against the normative grammar, then require ordinary validation/compilation to reject the confirmed invalid tails. Cover supported source/reconstructed/generated routes, multiline positions and valid neighboring constructs; update public evidence and use canonical proof if the shared/public contract moves. Other backends retain their own owners and evidence.
  Verification: `pending`; parseSpec drops @unexpected after /x/ or E { return("ok") } in both header and body layouts, then validateSpec and normal compileSpec accept. The own-line, explicit/bare I and malformed action-edge controls retain Raw and reject. Both body loops preserve failed suffixes only for an empty element list, an edge-token prefix or an unsupported I remainder. Exact probe and source locations are in docs/knowledge/dart-body-suffix-omission.md. No runtime invocation, emitted carrier or fresh other-backend behavior is inferred.
  Reading update .1.13: Seven body-fluent source/AST/validation/compiler controls confirm that .Töp(), .Top-Rule() and .Top() @unexpected lose their tails and compile; ASCII/comment controls compile, own-line/no-ASCII-prefix controls retain Raw and reject. The standalone fluent adapter at spec_parser.dart:766 hardcodes an empty remainder before the already-owned body-loop loss. Include adapter remainder propagation plus all seven controls in this repair; preserve narrow ASCII method grammar and do not infer runtime execution. Exact replay: docs/knowledge/dart-body-fluent-suffix-loss.md.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.7`
  Status: `pending`
  Goal: Preserve quoted and regex argument boundaries in Dart compact fluent extraction.
  Dependencies: Startup `.3`, `.4` and `.5`; source finding from `.1.12`; coordinate Rust startup `.52.2` and Dart suffix retention `.2.6`.
  Acceptance: Lock I.return("(") against its braced twin and require the authored argument to survive parsing and normal execution; lock I.return(")") against its successful braced twin. Reconcile completeness and extraction scanners across all callers, covering quoted/escaped delimiters, regexes, nesting, multiline calls, attached when conditions and truly malformed input. Never turn failed argument extraction into a valid empty call or silently consume its suffix. Preserve accepted horizontal whitespace, exact source origins, diagnostics and existing bare-call semantics. Cover parsed/reconstructed/generated/emitted carriers and public examples; use canonical verification if shared/public semantics move.
  Verification: `pending`; six quoted/plain/spacing controls establish that compact quoted-open lowers to return(), compiles and returns null with matched=false, while its braced twin returns "(" with matched=true. Compact quoted-close truncates the argument and leaves a Raw suffix rejected by validation; its braced twin returns ")". Plain and spaced forms return "ok". _extractParenContentWithEnd counts every parenthesis without lexical state; _parseFluentChainWithRemainder replaces failed extraction with empty arguments and clears the remainder. Exact replay is in docs/knowledge/dart-spec-lexical-boundary-defects.md; no generated/emitted or fresh other-backend outcome.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.8`
  Status: `pending`
  Goal: Preserve original semantic observer errors and stacks through action-mediated child execution.
  Dependencies: Startup `.3`, `.4` and `.5`; source finding from `.1.16`.
  Acceptance: Preserve the exact caller error object and original stack through explicit child calls inside lifecycle/action/function/control bodies, including nested wrappers, while keeping trace scopes and rule/recognition/binding cleanup balanced. Audit catch boundaries rather than fixing only the first example; preserve diagnostic-output failures, exits, next/return signals and normal runtime diagnostics. Lock direct/blind/explicit-call selected-slot failures, final-result failures and successful observer controls through native, reconstructed, generated-plan and fresh emitted direct/traced routes. Retain invocation-local observation order and absence of final events on failure; update public evidence and use canonical proof at public closeout.
  Verification: `pending`; six public native controls show only the explicit child-call slot failure loses both object and stack identity, becoming RuntimeInterpreterException with the private wrapper type in its message. _executeActionBlock lacks the semantic failure passthrough that _parse already provides. Exact replay and source locations live in docs/knowledge/dart-semantic-observer-action-failure-wrapping.md; no fresh defect reproduction through emitted or other-backend routes.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.9`
  Status: `pending`
  Goal: Preserve block-local return and complete attached-branch selection inside marker-selected value ranges.
  Dependencies: Startup `.3`, `.4` and `.5`; source finding from `.1.17`.
  Acceptance: Route mixed marker/attached controls through one value-aware statement authority, retaining sibling if/elseif/else selection and local return flow through nested if/while/switch. Lock continuation after the enclosing value block, skipped dead branches and the distinction from rule-level action returns. Cover return_undef, nested marker and attached combinations, callback/function value contexts, ordinary statements and iteration guards; preserve lazy single evaluation, diagnostics and scope cleanup. Add focused negative/positive proof through native, reconstructed, generated-plan and fresh emitted execution. Compare any uncertain shared semantics with the normative contract and Perl reference before changing them; own affected backend follow-ups. Update public evidence and use canonical proof at public closeout.
  Verification: `pending`; ten typed-AST/contract/native/SpecFile-JSON controls reproduce four premature surrounding-rule returns and one skipped attached else. Five direct/marker-only/attached-only controls preserve the local result. All have empty diagnostic lists and matched=true at cursor 1. _executeValueStatementRange routes attached controls to the action evaluator; its single-statement if adapter cannot see sibling else. Exact replay and source locations live in docs/knowledge/dart-mixed-control-value-block-gap.md. No fresh generated/emitted or other-backend defect outcome is claimed.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.10`
  Status: `pending`
  Goal: Separate callback recursion identity from helper names while preserving real bound-codeblock recursion rejection.
  Dependencies: Startup `.3`, `.4` and `.5`; source finding from `.1.18`.
  Acceptance: Allow distinct nested contextual/explicit callbacks through helper and receiver with and tree traversal without treating the helper name as callable identity. Preserve the bound callback identity through helper/receiver dispatch so direct, mutual and helper-mediated cycles report the correct ordered callable cycle. Resolve callbacks before installing scoped values; preserve once-only argument evaluation, copied parameter/rest values, restoration on success/failure and the separate map_leaves! receiver guard. Cover nested same/different helpers, sequential calls, named callbacks and real recursion through native, reconstructed, generated-plan and fresh emitted execution. Use the existing neutral contract and Lua identity record as evidence, not fresh backend proof; own any cross-backend follow-up. Update public evidence and use canonical proof at public closeout.
  Verification: `pending`; nine native/SpecFile-JSON controls confirm four false recursion rejections for distinct nested with/map_leaves callbacks and incorrect with identity/cycle for real helper-mediated cb recursion. Single/sequential with and mixed map/reduce succeed; direct cb recursion reports cb correctly. _executeCodeblockValue keys activeCodeblocks by its name argument; helper/receiver/tree callers pass their helper name. Exact replay and locations live in docs/knowledge/dart-callback-helper-recursion-identity-gap.md. No fresh generated/emitted or other-backend defect result is claimed.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.11`
  Status: `pending`
  Goal: Preserve authored hash-constructor splices and pair order in Dart.
  Dependencies: Startup `.3`, `.4` and `.5`; finding from `.1.19`; coordinate existing FUTURE-PARITY-BACKLOG.5 helper-context decisions.
  Children: `.2.11.1`, `.2.11.2`, `.2.11.3`
  Evidence: docs/knowledge/dart-hash-splice-pairing-gap.md retains nine native/SpecFile-JSON cases and nine Perl facade comparisons. Dart pairs raw aggregate arguments before a late map-only merge, creating container-text keys, losing following fields and overriding later authored duplicates. flat_array is absent from hash splice classification. Perl handles the flat_array control correctly; all six map-splice cases lower to its already-owned unsupported hash sentinel. Plain pairs and ordinary nested maps succeed on both backends.

- ID: `DART-STARTUP-READING.2.11.1`
  Status: `pending`
  Goal: Resolve exact constructor token and map splice expectations without selecting a host's incidental behavior.
  Dependencies: Startup gates; coordinate FUTURE-PARITY-BACKLOG.5.
  Acceptance: Freeze independent expected results for leading, middle, trailing, repeated and empty splices, duplicate order, direct/receiver aliases and ordinary nested values. Reconcile current Dart documentation, Lua's dated ordered-splice contract and the fresh Perl flat-array success/map-sentinel distinction. Separate already-owned odd-arity and map list-context decisions from the Dart loss of authored pairs; route other backend findings to their existing owners. Preserve explicit syntax, once-only ordered evaluation, copy isolation and removed-selector rejection.
  Verification: `pending`; intake verifies nine Dart native/reconstructed cases and nine Perl facade comparisons, not all accepted spellings or backend carriers.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.11.2`
  Status: `pending`
  Goal: Implement the resolved Dart constructor splice stream before key/value insertion.
  Dependencies: `.2.11.1` and startup gates.
  Acceptance: Remove raw aggregate pairing and the out-of-order second map merge; recognize the resolved direct/receiver splice shapes, including flat_array, and preserve subsequent ordinary pairs and last-authored duplicate behavior. Keep ordinary aggregates nested, copy results deeply and evaluate arguments exactly once in authored order. Lock empty/multiple splices, alias forms, mutation isolation and invalid/odd-shape diagnostics against the resolved contract.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.11.3`
  Status: `pending`
  Goal: Close Dart constructor splice repair across supported carriers and public evidence.
  Dependencies: `.2.11.2`.
  Acceptance: Prove native, SpecFile reconstruction, generated-plan and fresh emitted execution with independent output/effect/copy controls; run direct-dependent constructor, binding, corpus and public checks. Update the book and canonical facts, retain separately unresolved FUTURE-PARITY-BACKLOG.5 semantics, and use canonical verification at public closeout. Do not infer other backend success from Dart carrier agreement.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.12`
  Status: `pending`
  Goal: Preserve finite Dart numeric values through arithmetic and scalar-text conversion.
  Dependencies: Startup `.3`, `.4` and `.5`; finding from `.1.20`; coordinate startup .55 numeric/text boundaries and .20 numeric input grammar.
  Children: `.2.12.1`, `.2.12.2`, `.2.12.3`
  Evidence: docs/knowledge/dart-large-number-helper-corruption.md retains eleven native/SpecFile-JSON and Perl facade/source controls. Direct positive/negative 1e20 survives, but adding zero or cat clamps to signed-64 endpoints. max-int plus one wraps negative, and abs(min-int) remains negative. Perl preserves the corresponding finite values. Five direct/small/invalid controls agree; these are value changes, not a claim to arbitrary-precision arithmetic.

- ID: `DART-STARTUP-READING.2.12.1`
  Status: `pending`
  Goal: Freeze numeric range, conversion and scalar-text expectations for the affected Dart consumers.
  Dependencies: Startup gates; coordinate SESSION-STARTUP-READING.55.1/.55.2 and .20.
  Acceptance: Lock all eleven intake cases against independent finite-value expectations and the scalar-numeric contract. Audit integral conversion and arithmetic in helpers, reducers, scalar text, indexes/diagnostics and actual callers; distinguish measured failures from source inventory. Reconcile decimal/scientific spelling separately from magnitude and sign preservation. Define supported adjacent integer/double boundaries, fractions, nonfinite results and signed zero without promising arbitrary precision or silently adopting a host's overflow.
  Verification: `pending`; two helper saturations, two text saturations, integer addition wrap and negative abs reproduce through both Dart carriers; five controls agree with Perl.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.12.2`
  Status: `pending`
  Goal: Remove Dart helper saturation and unchecked host-integer arithmetic at the resolved boundaries.
  Dependencies: `.2.12.1` and startup gates.
  Acceptance: Preserve accepted finite results without unconditional out-of-range toInt conversion; prevent integer wrap and negative absolute values. Apply one resolved conversion policy to the confirmed numeric and text consumers; audit reducers and remainder/rounding paths without claiming untested repair. Preserve invalid-to-null, exact arities, boolean rejection, strict decimal inputs, small integer kinds and signed zero. Add focused independent boundary and regression controls.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.12.3`
  Status: `pending`
  Goal: Close Dart numeric boundary repair through carriers and public evidence.
  Dependencies: `.2.12.2`.
  Acceptance: Verify native, reconstructed, generated-plan and fresh emitted/primary execution, with exact value/kind/sign/text controls and nested outward consumers. Run scalar-numeric/text and direct-dependent checks, coordinate separately owned backend work, update public limitations and use canonical verification at public closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.13`
  Status: `pending`
  Goal: Align Dart lexical helper ordering with the resolved portable character order.
  Dependencies: Startup gates; finding from `.1.20`; coordinate the separate MCP canonical-order repair .2.5.
  Children: `.2.13.1`, `.2.13.2`, `.2.13.3`
  Evidence: docs/knowledge/dart-helper-unicode-order-gap.md retains eight native/SpecFile-JSON and Perl facade/source controls. sorted, sorted_keys, sorted_values and str_lt/str_gt put U+10000 before U+E000 on Dart, opposite Perl. ASCII, BMP-only and equality controls agree. Four helper seams use host UTF-16 ordering; callback-key sorting is source inventory, not freshly executed defect proof.

- ID: `DART-STARTUP-READING.2.13.1`
  Status: `pending`
  Goal: Freeze portable lexical order and all affected helper consumers.
  Dependencies: Startup gates; coordinate .2.5 and existing string/hash helper contracts.
  Acceptance: Reconcile the preserved Perl lexical comparison contract with Unicode scalar ordering and the separately governed MCP canonical-byte contract; do not infer a public helper policy solely from the serializer. Lock the eight intake cases plus supplementary/BMP boundaries, prefixes, equality and normalization-distinct text. Audit sorted arrays, hash views, all str_* relations and sorted callback traversal with exact route/effect ownership.
  Verification: `pending`; five paired helper differences and three agreements are measured; no fresh callback-order, emitted or other-backend result.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.13.2`
  Status: `pending`
  Goal: Apply the resolved comparison consistently across confirmed Dart helper paths.
  Dependencies: `.2.13.1` and startup gates.
  Acceptance: Replace incidental UTF-16 ordering at owned seams with the resolved comparator without normalizing strings, changing equality, array source order, duplicate handling or copied values. Keep sorted_values aligned with sorted_keys. Preserve callback sequencing and diagnostics where the inventory proves an affected traversal, and add independent positive/negative tests for each repaired route.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.13.3`
  Status: `pending`
  Goal: Close lexical-order repair through supported carriers and public evidence.
  Dependencies: `.2.13.2`.
  Acceptance: Prove direct/receiver and native/reconstructed/generated/emitted helper results against independent code-point expectations; verify callback order only on established affected routes. Run direct-dependent helper, scalar and public checks, coordinate MCP .2.5 without conflating contracts, update public teaching and execute canonical closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.14`
  Status: `pending`
  Goal: Clip Dart array/string/typed-input slice lengths without overflowing start plus length.
  Dependencies: Startup gates; findings from `.1.20`/`.1.21`; coordinate Rust startup .60 and separate Dart numeric conversion .2.12.
  Children: `.2.14.1`, `.2.14.2`
  Evidence: docs/knowledge/dart-slice-end-overflow.md retains six Dart native/SpecFile-JSON and Perl facade/source controls. slice([1,2,3],1,9223372036854775807) and substr("abc",1,9223372036854775807) throw wrapped RangeError with end -9223372036854775808; Perl returns [2,3] and "bc". Small lengths and the same large length at zero succeed. Both Dart helpers add before clipping. Reading .1.21 adds two public input_slice overflow nulls with six valid controls in docs/knowledge/dart-input-slice-boundary-gaps.md: typedSourceSlice also adds before clipping, then source projection converts the invalid endpoint to null; Perl retains the suffix/empty end. Zero-argument discrepancy stays under .2.15.

- ID: `DART-STARTUP-READING.2.14.1`
  Status: `pending`
  Goal: Repair array, scalar-string and typed-source end clipping with overflow-safe bounds arithmetic.
  Dependencies: Startup gates; coordinate existing slice contract and .2.12 numeric conversion inventory.
  Acceptance: Preserve the complete remaining suffix for a valid oversized width without computing an overflowing end first. Lock all six array/string intake cases and the eight two-argument typed input controls from .1.21 plus exact end, beyond end, zero/omitted lengths, empty values, Unicode scalar substrings and adjacent integer bounds. Keep negative/invalid count policy under its existing helper owner; retain copies, once-only evaluation and structured diagnostics. Cover direct and receiver forms, and audit the shared substring consumer before changing statement mutation behavior.
  Verification: `pending`; .1.20 retains two array/string failures and four controls; .1.21 adds two typed-input null failures and six valid controls, all native/reconstructed with source-backed Perl comparisons. Arity .2.15 stays separate; no repair or emitted defect result.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.14.2`
  Status: `pending`
  Goal: Close overflow-safe slicing through carriers and public evidence.
  Dependencies: `.2.14.1`.
  Acceptance: Prove repaired direct/receiver and established mutation consumers through native, reconstructed, generated-plan and fresh emitted/primary routes, with independent expected suffixes and the confirmed typed input_slice route, preserving valid typed positions/spans and absence diagnostics. Run helper/binding/source/corpus dependents, retain Rust .60 ownership, update public examples and execute canonical closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.15`
  Status: `pending`
  Goal: Enforce the documented input_slice(start, length) arity consistently.
  Dependencies: Startup gates; reading .1.21; coordinate FUTURE-PARITY-BACKLOG.5 helper-arity decisions.
  Children: `.2.15.1`, `.2.15.2`
  Evidence: docs/knowledge/dart-input-slice-boundary-gaps.md retains nine exact native/SpecFile-JSON and Perl facade/source controls. The zero-argument call has empty Dart diagnostics and returns the whole input; Perl leaves return input_slice() unlowered and records runtime_handler/rule_handler_eval with an undefined-subroutine detail. Eight two-argument controls separate the arity gap from overflow .2.14. The public catalog requires two arguments; omitted forms are not admitted by this finding.

- ID: `DART-STARTUP-READING.2.15.1`
  Status: `pending`
  Goal: Diagnose unsupported input_slice arity before operand effects or handler execution.
  Dependencies: Startup gates; .2.15 documented signature and existing helper diagnostic conventions.
  Acceptance: Retain the two-argument scalar-source contract. Reject missing or surplus arguments consistently at the appropriate typed boundary, including the confirmed zero-argument path and permanent one/three-argument, keyword, receiver and effect-order controls. Remove the Dart whole-input fallback only with deliberate compatibility evidence; whole input remains input_text(). Prevent Perl raw undefined-subroutine fallback. Coordinate existing helper-arity policy without silently enlarging the language or conflating width overflow .2.14.
  Verification: `pending`; one zero-argument native/reconstructed and Perl source-backed discrepancy is confirmed; unmeasured arities/carriers remain repair work.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.15.2`
  Status: `pending`
  Goal: Close input_slice arity parity through supported carriers and public evidence.
  Dependencies: `.2.15.1`.
  Acceptance: Exercise the exact signature and rejection boundary on all backends and supported native/reconstructed/generated/emitted/primary carriers, keeping source offsets, valid slice behavior and structured diagnostics intact. Update the helper catalog, book and Knowledge with measured scope; run direct dependents and canonical closeout. Do not infer other backend failures from this Dart/Perl intake.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.16`
  Status: `pending`
  Goal: Preserve regex literals and character classes during lower-unbounded quantifier normalization.
  Dependencies: Startup gates; reading .1.23; coordinate existing bounded dialect support without conflating regex-brace scanner .2.2/startup .54.
  Children: `.2.16.1`, `.2.16.2`
  Evidence: docs/knowledge/dart-regex-quantifier-literal-corruption.md retains six exact public-alternation/native/SpecFile-JSON and Perl Get/source controls. The global {,n} rewrite changes escaped literal text and adds characters inside classes: three parser-level false negatives/positives with three successful controls. Raw host matching independently confirms literal meaning; the genuine a{,2} bridge control remains necessary.

- ID: `DART-STARTUP-READING.2.16.1`
  Status: `pending`
  Goal: Normalize only actual regex lower-unbounded quantifier tokens.
  Dependencies: Startup gates; retain current regex-versus-literal contract.
  Acceptance: Lock all six intake cases and preserve escaped delimiters, escape parity, bracket classes, literal braces, adjacent quantifiers and malformed syntax. Keep actual a{,2} support. Use lexical context rather than an unconditional textual replacement; inspect adjacent rewrite passes for the same mechanism and own any separately confirmed defects. Preserve regex options, capture identity, authored pattern/source and diagnostic boundaries; do not silently broaden general PCRE support or change existing scoped-flag/possessive policy in this repair.
  Verification: `pending`; three confirmed literal corruptions and three controls, with exact normalized pattern, raw host/reference matching and public parser results; no repair or fresh emitted defect result.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.16.2`
  Status: `pending`
  Goal: Close literal-safe normalization through supported carriers and public evidence.
  Dependencies: `.2.16.1`.
  Acceptance: Prove the repaired literal/quantifier boundary through public alternation, authored native, reconstructed, generated-plan and fresh emitted/primary carriers. Reverify direct regex/helper, source/capture/staged and shipped structural consumers with independent expected matches; update book/KM and run canonical closeout. Preserve scanner .2.2/startup .54 and documented dialect limitations as separate owners.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.17`
  Status: `pending`
  Goal: Make retained staged diagnostics obey an explicit, enforceable byte-ceiling contract.
  Dependencies: Startup .3/.4/.5; reading .1.26; coordinate ADR0088 and FUTURE-PARITY-BACKLOG.14.7 without changing accepted history.
  Children: `.2.17.1`, `.2.17.2`, `.2.17.3`
  Evidence: docs/knowledge/dart-staged-resource-boundary-gaps.md owns seven private recursive scheduler controls. A 1-byte allowance retains 187 bytes; a 64-byte allowance retains 188 bytes, or 375 across two siblings after remaining capacity reaches zero. Zero is correctly rejected; 256/4096 single and 4096 sibling controls fit. _boundedDiagnostic measures the fallback but returns it without another ceiling decision, saturating the remaining counter at zero. Existing 44 tests and neutral 123/129 governance pass; no cross-backend or fresh production-carrier defect result is claimed.

- ID: `DART-STARTUP-READING.2.17.1`
  Status: `pending`
  Goal: Reconcile hard diagnostic byte ceilings with the required truncation-sentinel fields.
  Dependencies: Startup gates; preserve exact measured .1.26 intake.
  Acceptance: Define the accounting unit and behavior when the governed sentinel itself cannot fit, including initial tiny positive limits, exhausted cumulative allowance, stage-chain growth, sidecar copies and diagnostic-node policy. Preserve authority narrowing; do not silently exempt unlimited fallback metadata. Audit the reference and other staged backend authorities with exact probes and route separately confirmed gaps before selecting the compatible repair.
  Additional evidence: Julia .1.22 independently confirms the same187/188/375-byte retained overruns and correct maximum-call rejection. Julia .2.14 depends on this shared accounting decision and owns its backend implementation/carrier proof; docs/knowledge/julia-staged-diagnostic-byte-boundaries.md preserves exact controls. Original Dart measurements and .2.18 call repair remain unchanged.
  Additional Lua evidence: Lua .1.24 confirms the same 187/188/375-byte retained overruns with complete private recursive results and correct maximum-exact call exhaustion. Lua .2.26 depends on this shared accounting decision and owns backend repair/carrier proof; docs/knowledge/lua-staged-completion-reading-and-boundary-gaps.md preserves the independent observations. Original Dart/Julia evidence remains unchanged.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.17.2`
  Status: `pending`
  Goal: Enforce the selected staged diagnostic-byte contract in Dart.
  Dependencies: `.2.17.1`.
  Acceptance: Lock the seven intake controls and reject or represent diagnostics within the selected effective and cumulative boundary, including repeated siblings and long lineage. Preserve zero-limit validation, ordinary complete diagnostics, portable error fields and failure-policy behavior. Measure canonical UTF-8 bytes independently of the remaining counter; never treat saturation at zero as sufficient proof.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.17.3`
  Status: `pending`
  Goal: Close staged diagnostic limits through supported carriers and public evidence.
  Dependencies: `.2.17.2` and any separately owned contract/backend corrections from .2.17.1.
  Acceptance: Prove native, reconstructed, generated-plan and fresh emitted routes under narrowing per-entry/caller and shared sibling/depth limits. Strengthen neutral/runtime consumers to check retained bytes, update book and Knowledge with exact scope, and run canonical closeout. Keep progressive startup .37 and ordinary source-detail policy as separate owners.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.18`
  Status: `pending`
  Goal: Reject an exhausted staged call allowance before integer increment can wrap.
  Dependencies: Startup .3/.4/.5; reading .1.26; coordinate existing numeric .2.12 without conflating scalar helper behavior with host resource counters.
  Children: `.2.18.1`, `.2.18.2`
  Evidence: docs/knowledge/dart-staged-resource-boundary-gaps.md owns four private recursive controls. Initial totalCalls=maxCalls=9223372036854775807 invokes one extra callback and returns totalCalls=-9223372036854775808. Ordinary 31/32 success, 32/32 denial before callback, and max-minus-one success remain controls. _dispatchResourceCheck adds one before comparison at staged_ast_enrichment.dart:1892, then stores the wrapped value at 1905.

- ID: `DART-STARTUP-READING.2.18.1`
  Status: `pending`
  Goal: Make staged call admission and counter updates overflow-safe.
  Dependencies: Startup gates.
  Acceptance: Lock all four intake controls; compare available authority before incrementing, reject exhausted or already-exceeded counts without a child callback, and retain monotone nonnegative totals across siblings and depths. Audit adjacent staged resource arithmetic with bounded independent controls and own any distinct findings; preserve existing cancellation/deadline/step/lineage ordering.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.18.2`
  Status: `pending`
  Goal: Close staged call-counter safety across host seeds and supported production carriers.
  Dependencies: `.2.18.1`.
  Acceptance: Exercise native, reconstructed, generated-plan and fresh emitted seeds with exact near-limit and exhausted counters; prove denied calls have no effects. Update direct consumers, book and Knowledge, retain startup numeric owners, and run canonical closeout without changing authored numeric semantics.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.19`
  Status: `pending`
  Goal: Reject malformed staged provenance field types before diagnostic placeholders can become source data.
  Dependencies: Startup .3/.4/.5; reading .1.27; preserve existing staged .2.17/.2.18 and Rust startup .74 as separate owners.
  Children: `.2.19.1`, `.2.19.2`
  Evidence: docs/knowledge/dart-staged-provenance-type-validation-gap.md owns seventeen private validateAndMaterializeStagedProvenance controls compared with the neutral materialize_provenance evaluator. Six malformed records are accepted only by Dart: null/numeric/object provenance becomes the literal `<invalid>`, malformed source_id can select an existing caller source named `<runtime>`, and a derived segment repeats the provenance coercion. Eleven valid/rejected controls agree, including explicitly supplied string placeholder labels. _typedDirectSpan computes diagnostic fallback strings before validating original field types. All 33 selected runtime tests and Unicode regeneration/12 neutral fixtures pass; no authored-production or other-backend runtime failure is inferred.
  Lua reading .1.25 extension: Independent current Lua evidence confirms the same original-field/diagnostic-placeholder mechanism. Lua .2.29 owns eight malformed type acceptances, eleven agreeing neutral controls and separate derived host-array membership repair. Original Dart seventeen-case evidence remains dated and unchanged; this is not a fresh Dart execution. Cross-link docs/knowledge/lua-declaration-trace-reading-and-validation-gaps.md for coordinated proof.


- ID: `DART-STARTUP-READING.2.19.1`
  Status: `pending`
  Goal: Separate staged provenance schema validation from diagnostic fallback labels in Dart.
  Dependencies: Startup gates; .1.27 intake.
  Acceptance: Lock all seventeen exact controls; require original source_id/provenance strings and nonempty provenance before constructing typed positions/spans. Apply identical validation to direct and every ordered-derived segment. Preserve diagnostic code/phase/origin and diagnostic-only placeholders without promoting them to source authority. Retain valid literal `<runtime>`/`<invalid>` strings, exact-key checks, unknown-source rejection, scalar boundaries and reversed-span rejection; never reserve otherwise valid names merely to mask coercion.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.19.2`
  Status: `pending`
  Goal: Close malformed staged provenance through the neutral consumer and actual supported entrypoints.
  Dependencies: `.2.19.1`.
  Acceptance: Extend neutral/runtime consumers with type-malformed direct and derived records and exact accepted/rejected twins. Audit declaration, host-validation and returned-marker boundaries; prove the affected routes and explicitly distinguish ordinary typed authored constructors from injectable malformed host data. Exercise applicable native/reconstructed/generated/emitted paths without inventing unsupported inputs or claiming untested backends. Preserve frozen source identity and authority-free marker bytes, update book/Knowledge, and run canonical closeout; route any distinct confirmed gap to its own task.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.20`
  Status: `pending`
  Goal: Correlate semantic calls and binding sources with typed authored action occurrences instead of same-name regex text.
  Dependencies: startup .3/.4/.5; coordinate SESSION-STARTUP-READING.22/.67 without conflating empty-function or container traversal causes.
  Children: `.2.20.1`, `.2.20.2`.
  Verification: .1.30 public Dart query on /trim(x)/ with value = trim(" x ") reports trim(x) at regex bytes 44-51 as both call and binding source; typed ActionIR identifies trim(" x ") and direct runtime returns "x". The quote-only scanner traverses the whole edge and the name cursor takes the first match. Direct/nested/string/repeated controls retain exact sources; no other-backend or MCP reproduction is claimed.

- ID: `DART-STARTUP-READING.2.20.1`
  Status: `pending`
  Goal: Use typed action ownership and lexical boundaries for exact semantic call and binding source correlation.
  Acceptance: Reproduce the same-name regex decoy before repair. Exclude matcher literals and unrelated source occurrences; preserve outer-before-inner call order, source privacy ceilings and exact UTF-8/scalar coordinates. Cover escaped regex delimiters/classes, quoted strings, repeated same-name calls and Unicode. Coordinate composite binding RHS ownership under startup .67.2; do not simply skip a hardcoded spelling or rewrite expected evidence.
  Verification: `pending` repair; .1.30 owns the public query/typed ActionIR/runtime control and complete reproducible recipe.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.20.2`
  Status: `pending`
  Goal: Prove source-correlation recurrence across supported semantic entrypoints and close public documentation.
  Dependencies: .2.20.1.
  Acceptance: Lock independent expected source bytes/spans and graph relations; test public typed/raw queries, source/UTF-8 constructors and supported MCP registration/query routes. Audit other backends before claiming recurrence or parity; own discrepancies. Preserve the seven valid/arity-rejection controls and startup .67 container evidence, update book/Knowledge, and run canonical proof at the public closeout boundary.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.21`
  Status: `pending`
  Goal: Keep native raw-query rejection responses detached and serializable when callers supply values outside the JSON domain.
  Dependencies: startup .3/.4/.5; preserve exact valid and malformed JSON request/response contracts.
  Children: `.2.21.1`, `.2.21.2`.
  Verification: .1.31 eight native queryNeutral cursor controls confirm two caller-object mutations changing existing rejected response serialization, one plain object retained by identity with encoding failure, and a NaN cursor encoding failure. Four ordinary JSON controls remain detached/serializable. The error path echoes raw after_id through helpers that copy maps/lists but retain other values. No typed-request or MCP reproduction is claimed.

- ID: `DART-STARTUP-READING.2.21.1`
  Status: `pending`
  Goal: Admit or reject native raw-request evidence before it can retain arbitrary host values in an immutable response.
  Acceptance: Pin the native non-JSON boundary explicitly and choose a typed rejection or safe plain diagnostic representation without invoking caller serialization/stringification hooks. Preserve existing JSON invalid-cursor evidence, response fields, privacy ceilings, deterministic serialization and all 26 malformed JSON boundaries. Cover direct/nested mutable objects, plain objects and nonfinite values; coordinate shared copy-helper behavior before edits.
  Verification: `pending` repair; .1.31 owns the exact eight-case public-native reproduction and four passing JSON controls.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.21.2`
  Status: `pending`
  Goal: Prove native semantic response immutability and document the supported input domain.
  Dependencies: .2.21.1.
  Acceptance: Assert caller mutation cannot change returned response values or serialized bytes; rejected evidence must not retain caller object identity. Census public diagnostic/page/record/value constructors sharing the same helpers and own each supported-surface discrepancy. Keep native host-object handling distinct from standard JSON/MCP transport; test supported typed/raw/MCP routes without inventing JSON representations for host objects. Update book/Knowledge and run canonical proof at the public closeout boundary.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.22`
  Status: `pending`
  Goal: Preserve valid indexed action-edge identity when a regex contains arrow-like target text.
  Dependencies: startup .3/.4/.5; coordinate .2.20 lexical source correlation and SESSION-STARTUP-READING.70 grouped-selector repair.
  Children: `.2.22.1`, `.2.22.2`.
  Verification: .1.33 eight public native index/compiled/runtime controls establish two regex-arrow construction failures and two grouped-selector failures owned by startup .70, with four valid controls. All eight sources compile and execute to the exact selected input. The index rejects /-> Child/ and /-> Child[0]/ followed by real -> Child[1], because the static helper selects the first arrow/name substring and returns no explicit selector; its strict compiled identity guard then throws semantic_static_correlation_failed. No other-backend/MCP proof is claimed.

- ID: `DART-STARTUP-READING.2.22.1`
  Status: `pending`
  Goal: Correlate explicit edge selectors using authored target identity and lexical occurrence.
  Acceptance: Exclude arrows, labels and brackets inside regex/string literals when locating the actual target selector; prefer retained typed source ownership over whole-member substring searches. Preserve the compiled identity guard, direct/indexed distinctions, exact spans, Unicode labels and no-silent-fallback behavior. Coordinate shared-selector groups with startup .70.1 and call-source lexical handling with .2.20.1; keep these distinct findings and controls.
  Verification: `pending` repair; .1.33 preserves two regex failures, two grouped failures and four valid public native controls.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.22.2`
  Status: `pending`
  Goal: Close indexed semantic source-correlation recurrence and public evidence.
  Dependencies: .2.22.1; coordinate startup .70.3.
  Acceptance: Compare parsed/compiled selectors, public source/UTF-8 index construction, typed/raw query facts and exact source ranges; include arrow/label/bracket decoys, escaped delimiters/classes and prefix/repeated targets. Check supported MCP registration/query and other backends before claiming parity; own discrepancies. Preserve runtime results and all eight controls, update book/Knowledge and run canonical proof at public closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.23`
  Status: `pending`
  Goal: Reject malformed named selector provenance before it can select an anonymous regex slot.
  Dependencies: startup .3/.4/.5; finding from .1.35; coordinate the existing inter-match-gap and duplicate-slot identity contracts.
  Children: `.2.23.1`, `.2.23.2`.
  Evidence: docs/knowledge/dart-null-named-selector-validation-gap.md retains ten public SpecFile-JSON reconstruction/validation/compiled/runtime controls. Two null named selectors bind the first anonymous declaration at index 0 or 1 and execute /a/; valid head selects /b/. Three valid selectors and three rejecting malformed-name controls bound the failure. Numeric-null and unindexed-text provenance are separately accepted census inputs, not additional wrong-slot claims.
  Additional evidence: Julia .1.33 independently reproduces the same ten configurations with96 assertions. JULIA-STARTUP-READING.2.23.1/.2 owns its null-name repair and supported-carrier recurrence; existing Dart evidence remains unchanged and no fresh Dart run is claimed. See docs/knowledge/julia-null-selector-and-identifier-validation-gaps.md.

- ID: `DART-STARTUP-READING.2.23.1`
  Status: `pending`
  Goal: Enforce the named selector's required identity at supported reconstructed and native AST boundaries.
  Dependencies: Startup gates and the existing selector syntax/provenance contracts.
  Acceptance: Require a valid nonempty named identity before nullable slot lookup; an anonymous slot must never satisfy a named selector. Preserve valid named/numeric/unindexed selectors, exact Unicode identity, numeric position semantics, authored order and deliberate historical carrier defaults. Lock the two anonymous-slot reorder failures plus all named-only/number/empty and valid controls. Audit selector-kind, authored-selector and index consistency, including numeric-null/unindexed-text intake, before defining additional rejection or normalization behavior; do not silently break legacy reconstructed carriers. Use the existing portable diagnostic convention and retain compiled slot identity checks.
  Verification: `pending` repair; .1.35 confirms two malformed named acceptances, six valid/rejecting controls and two additional accepted provenance shapes.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.23.2`
  Status: `pending`
  Goal: Close named-selector validation repair across supported carriers and public evidence.
  Dependencies: .2.23.1.
  Acceptance: Prove native AST, ordinary SpecFile reconstruction, compiled/descriptor, generated-plan and independently emitted routes with independent expected target identity and runtime values. Census semantic-index/MCP registration and other backends before claiming exposure or parity, routing any findings to disjoint owners. Preserve existing gap/duplicate-slot diagnostics and all ten intake controls, update the book and Knowledge, run direct dependents and canonical proof at public closeout.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.24`
  Status: `pending`
  Goal: Restore Dart formatter compatibility and make format verification non-mutating.
  Dependencies: Startup .3/.4/.5 before source or gate repair; discovered by .3.1 component verification.
  Children: `.2.24.1`, `.2.24.2`.
  Evidence: Dart 3.13.3 / dart_style 3.1.13 rejects six baseline-identical tests; tools/run_dart_local.sh writes those files before exiting1. Exact original/formatted hashes and non-writing replay live in docs/knowledge/dart-component-gate-sdk-compatibility.md. Both diagnostic writes were restored byte-for-byte; no source repair is claimed.

- ID: `DART-STARTUP-READING.2.24.1`
  Status: `pending`
  Goal: Apply and verify the six owned formatter corrections.
  Dependencies: Startup reading and policy prerequisites.
  Acceptance: Reproduce with the supported SDK and explicit package language3.9; inspect every edit and preserve strings/comments and executable tokens. Format only the six confirmed test files, account for baseline deltas, verify zero-change repeat formatting and relevant generated-source/contract tests. Keep runtime behavior, SDK constraints, analyzer severity and parser contracts unchanged.
  Verification: `pending` repair; .3.1 retains exact six-file hashes and non-writing reproduction.
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.24.2`
  Status: `pending`
  Goal: Ensure the Dart format gate reports drift without modifying the workspace.
  Dependencies: .2.24.1; gate change is separately owned infrastructure.
  Acceptance: Use the formatter's non-writing verification mode while retaining failure on drift. Prove a deliberately unformatted repository-local fixture fails with bytes unchanged, a formatted fixture passes, and the real package is unchanged by both focused and complete gate execution. Preserve all remaining gate stages and storage containment; run canonical infrastructure proof under the applicable dependency-build policy.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.25`
  Status: `pending`
  Goal: Remove deprecated SDK interface implementation from structural regex adapters.
  Dependencies: Startup .3/.4/.5; finding from .3.1 strict analyzer.
  Children: `.2.25.1`, `.2.25.2`, `.2.25.3`.
  Evidence: Strict Dart3.13.3 analysis exits2 with deprecated_implement at matching.dart:725:42 and1173:47. Installed SDK lib/core/regexp.dart marks RegExp and RegExpMatch implementation deprecated, with future final classes and Pattern/Match alternatives. Exact source/SDK evidence lives in docs/knowledge/dart-component-gate-sdk-compatibility.md; no current execution failure is inferred.

- ID: `DART-STARTUP-READING.2.25.1`
  Status: `pending`
  Goal: Freeze structural regex adapter and caller compatibility before migration.
  Acceptance: Inventory compileRuntimeRegex and all public/internal return, parameter and match consumers, including pattern identity, options, named groups, alternations and capture provenance. Define an adapter/composition boundary compatible with supported SDKs and existing source/reconstructed/generated/emitted routes. Preserve the bounded shipped structural-PCRE contract; if a public signature must change, obtain an explicit contract decision before implementation. Do not suppress warnings or silently downgrade the SDK.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.25.2`
  Status: `pending`
  Goal: Migrate structural regex and match adapters without deprecated implementation.
  Dependencies: .2.25.1 compatibility decision.
  Acceptance: Implement the agreed adapter boundary with exact captures, named groups, code-unit/scalar offsets, ordered alternatives, zero-progress behavior and staged provenance intact. Cover both ordinary SDK regexes and every supported structural family plus negative controls. Strict analysis must pass with fatal infos/warnings; no warning suppression or capability broadening.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2.25.3`
  Status: `pending`
  Goal: Close SDK adapter repair across supported callers and the complete Dart gate.
  Dependencies: .2.25.2 and .2.24 repairs.
  Acceptance: Run the complete Dart gate with every stage enabled, independently emitted/generated callers and relevant structural, Unicode, capture, staged and CLI contracts. Reconcile public signatures and book/Knowledge, prove zero unexpected source deltas and route any other-backend findings. Canonical admission remains required at this contract/infrastructure boundary under the applicable dependency-build policy.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.3`
  Status: `done`
  Goal: Close Dart reading with exact coverage, current-delta, comprehension and child-commit proof.
  Dependencies: `.0` and every `.1` child complete; all findings durably owned under `.2` or existing trees.
  Acceptance: Independently prove complete baseline/current coverage and all child commits; preserve every
    pending repair, complete only startup `.3.4` reading, and route startup Julia `.3.5`.
    Pending repairs keep this tree open; reading closeout is not defect remediation.
  Children: `.3.1` independent committed-reading audit; `.3.2` reading-parent closeout under ADR0114.
  Verification: .3.1 audit is committed at 28329ce13; .3.2 independently reexecutes it and preserves all69 pending repair nodes. The engineer exercises the director's explicit delegated authority under ADR0114 for this one-time focused reading closeout. The complete Dart gate remains failed; no canonical receipt, defect closure or new source-reading credit beyond the55 children is claimed. Startup .3.4 closes and .3.5 Julia decomposition is next.
  Commit: `DART-STARTUP-READING.3.2 - close verified Dart reading under delegated decision` (reading-closeout container)

- ID: `DART-STARTUP-READING.3.1`
  Status: `done`
  Goal: Independently verify and durably commit complete Dart reading evidence before the separate canonical closeout.
  Dependencies: .0 and all55 .1 children committed; all findings already have repair owners.
  Activation: Clean `1f8f226f0c34d77e21886ccfc3163c2992359deb`; prior leaf committed, brief empty, root clean and all jobs consumed.
  Scope: Exact source coverage/mode/blob/current-delta census; unique child commits, committed metadata and activation boundaries; retained repair/Knowledge evidence; complete Dart component gate and proposal for .3.2 closeout.
  Acceptance: Verify every child commit and all115 baseline entries independently; retain every pending repair and source finding; run the unchanged complete Dart component gate without building PGEN/RGX; record a concrete .3.2 closeout and any unresolved canonical-policy conflict. Commit audit evidence before requesting a separate exception. Do not complete .1, .3 or startup .3.4 here.
  Verification tier: `focused`
  Focused checks: Independent coverage/commit/activation/mode/blob/delta/repair/Knowledge audits; complete tools/run_dart_local.sh component gate, dormant authority proof from .1.55; all doctrines, both histories, Knowledge generation, rendered book and exact preservation.
  Canonical trigger: `none` — preparatory reading-evidence audit only; .3.2 retains the canonical milestone and parent-status changes. No source, gate, dependency, infrastructure or public contract change.
  Verification: All55 unique committed children retain exact scope, comprehension, verification fields and first-parent MEMORY activation; every child/current Dart tree retains baseline modes/blobs. Independent coverage is115 files/80296 physical lines/80297 fragments/2471305 bytes. All100 touched Knowledge cards and62 prior pending repair nodes remain exact. The unchanged full Dart gate FAILS at formatting (six tests, exit1); strict analyzer separately FAILS with two deprecated_implement warnings (exit2). Mechanisms and exact restored-byte hashes are durable, with new .2.24/.2.25 repair owners. Remaining original stages independently PASS461 tests, storage25/47, CLI66x2 and corpus105; dormant authority proof remains the committed four-group .1.55 result. This is not complete-gate success. Doctrine/history/Knowledge/book/preservation checks govern this documentation audit. No source/gate/pin changes, PGEN/RGX build or canonical CI; .3.2 retains its explicit decision boundary.
  Commit: `DART-STARTUP-READING.3.1 - audit committed Dart reading and gate failures`

- ID: `DART-STARTUP-READING.3.2`
  Status: `done`
  Goal: Close Dart reading from independently committed evidence and route Julia startup reading.
  Dependencies: .3.1 committed; director explicitly delegates this decision and the engineer selects the bounded ADR0114 exception for this exact reading boundary.
  Acceptance: Reverify .3.1 audit against clean HEAD; complete only reading container .1, this .3 closeout and startup .3.4, preserve all pending repairs and route startup .3.5 Julia decomposition. Synchronize all current pointers and book. Existing one-time containment .11 waiver grants no authorization here; do not silently rebuild PGEN/RGX contrary to the director's build-on-update requirement.
  Proposal: One-time reading-only exception: accept the committed .3.1 source/commit audit plus separately passing runtime/storage/CLI/corpus diagnostics to close only Dart .1/.3/startup .3.4 and route Julia. Waive canonical receipt and green complete Dart gate for this reading boundary only; keep six-file formatting and two-warning adapter repair .2.24/.2.25 pending behind startup .3/.4/.5. Do not rebuild PGEN/RGX, change source/gates, close defects, waive future admission/push proof or extend the earlier containment exception. The alternative requires authorized repair sequencing and dependency-compatible canonical proof before closeout.
  Activation: Clean `28329ce13af062eb431cdcff783aac2ca41192ba`; .3.1 committed, root clean, empty brief and no running jobs.
  Decision authority: On 2026-09-11 the director explicitly delegated this closeout decision to the engineer. Choose the proposed one-time reading-only exception on the independently committed audit; ADR0114 records the rationale and limits. The failed Dart gate and every repair owner remain open; no dependency rebuild, source repair or standing-policy change.
  Verification tier: `focused`
  Focused checks: Reexecute the committed reading audit; verify all69 pending Dart repair nodes and all55 child records unchanged; confirm no source/tool/gate/pin delta; all doctrines, Knowledge synchronization, both histories, rendered book and exact prior-evidence preservation. Reuse the unchanged .3.1 component diagnostics without claiming a full-gate pass.
  Canonical trigger: Reading-parent closeout; the engineer exercises the director's explicit delegated authority for this one-time exception under ADR0114. No canonical receipt or complete Dart gate success is claimed; all future admission, repair and push boundaries retain existing requirements.
  Verification: The committed audit reexecutes successfully: all55 reading commits/scopes/comprehension/proof/first-parent activations,115 source modes/blobs and exact80297 fragments/2471305 bytes remain verified. All100 touched Knowledge cards and all69 pending repair nodes retain exact checkpoint bytes; ordered69-node SHA256 aad0e43b150c3b94505848d51cd49b3d153740974f08881cc49de38ae9063126. Reuse the unchanged .3.1 passing461 tests/storage25-47/CLI66x2/corpus105 diagnostics and explicitly failed format/analyzer results. Only reading parents .1/.3 and startup .3.4 close. Normal doctrine, history, Knowledge, rendered book, current-pointer and exact prior-evidence checks govern this commit. No canonical CI, receipt, PGEN/RGX build, source/gate/pin change or defect closure. ADR0114 does not waive a later gate or push.
  Commit: `DART-STARTUP-READING.3.2 - close verified Dart reading under delegated decision`

- ID: `DART-STARTUP-READING.4`
  Status: `done`
  Goal: Obtain and durably route the additional history-capacity exception needed for continued committed reading.
  Dependencies: `.1.7` committed and repository clean; director decision is required before any additional capacity increase under ADR 0109.
  Scope: Proposal/intake only; stable storage responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3. After approval, create a bounded implementation leaf in that tree from a clean repository before editing infrastructure.
  Proposal: change_history max_files 30 to 31; manifest max_lines 29 to 30; manifest max_bytes 16463 to 17039. Every root, segment and aggregate byte/line ceiling, route identity, owner, verifier and immutable record remains unchanged.
  Evidence: The mandatory .1.7 draft rollover copied clean c2682cf9 CHANGES lines 217-389 into segment 4982, 173 lines / 26767 bytes, SHA-256 c00b7a2471b553ab83c98d104a731ac521966e5219be58daa289cd012c754aa7. The routing checker rejected 31/30 files and manifest 30/29 lines, 17039/16463 bytes. Exact generated output is reproducible from that clean source. A concise new .1.7 record restores every earlier history byte and leaves CHANGES at 58814 bytes, only 168 bytes below the largest integer size under its 90% rollover threshold.
  Acceptance: Record the director decision; if approved, create/index an exact-limit ADR and a separately owned canonical implementation with independent source/hash/count, full-history preservation, boundary mutation and resulting-tree proof. Remeasure before applying; this proposal grants no future member or unrelated threshold increase. Resume `.1.8` only after the necessary capacity boundary is durable. If declined, retain history and ask for an alternative that preserves it; no archive rewrite or threshold bypass.
  Verification: Director “Greenlighted !” approves exactly the three proposed controls. Implementation is separately owned by LIVE-DOCUMENT-PRESSURE-CONTAINMENT.8 from clean f8b626f0, with indexed ADR0110, actual-source remeasurement, exact history preservation, 22 real-validator executions and canonical proof. This intake grants no reading credit or further capacity; .1.8 resumes after that clean boundary.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.8 - admit approved history member` (proposal intake routed and closed by its separately owned implementation)

- ID: `DART-STARTUP-READING.5`
  Status: `done`
  Goal: Obtain and route the engineering-history capacity exception required before further committed reading.
  Dependencies: .1.24 committed with an empty brief and clean repository; director decision before additional infrastructure changes under ADR0109.
  Scope: Proposal/intake only. Stable responsibility stays LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3; after approval, create a separately owned canonical implementation from a clean repository.
  Proposal: engineering_notes max_files 26 to 27; its manifest max_lines 25 to 26. All byte, root, segment and aggregate limits, ownership, routes, verifier and prior immutable content remain unchanged.
  Evidence: docs/knowledge/dart-reading-engineering-history-capacity-blocker.md retains the exact governed draft: clean 62b02fec DEVELOPMENT_NOTES lines 249-447, 199 lines / 31079 bytes, SHA-256 dc8219d5abb8a57b27ca22971d1ae48d19b192277585cf7d98529bdfea90cf8c. The routing gate rejects precisely 27/26 files and 26/25 manifest lines; manifest 15618/16384 bytes and aggregate 25860/27000 lines, 2775501/3145728 bytes fit. The verified draft was restored before .1.24 landing; a concise current record retains full linked evidence and leaves only 50 bytes under mandatory rollover.
  Acceptance: Record the director decision. If approved, add/index an exact-limit ADR and a separately owned canonical implementation with actual-source remeasurement, immutable-history reconstruction, real-validator boundary checks and receipt-bound canonical proof; admit only these two controls. If declined, preserve history and obtain an alternative. Resume .1.25 only after a clean admitted capacity boundary; no further slot is preapproved.
  Verification: Director “ok for increasing the allowance” approves exactly files 26→27 and manifest lines 25→26. LIVE-DOCUMENT-PRESSURE-CONTAINMENT.9 implements from clean 4d5af8e9 under indexed ADR0111 with actual-source remeasurement, exact history preservation, 22 actual-validator executions and canonical proof. .1.24 retains the historical draft; no further slot is authorized.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.9 - admit approved engineering-history member` (intake closed by its separately owned implementation)

- ID: `DART-STARTUP-READING.6`
  Status: `done`
  Goal: Obtain and route the next change-history member capacity decision before .1.37.
  Dependencies: Completed .1.36 reading/intake; director decision before any additional infrastructure allowance under ADR0110.
  Scope: Proposal/intake only; stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3. Activate a separately owned canonical implementation only after approval and a clean repository.
  Proposal: change_history max_files31 to32, manifest max_lines30 to31 and manifest max_bytes17039 to17615. All root, segment, aggregate, ownership, route, schema and other collection limits remain unchanged; no further member is preapproved.
  Evidence: docs/knowledge/dart-reading-second-history-capacity-blocker.md retains the actual required rollover and exact routing rejection. Clean 6cb42d87 CHANGES247-457 is 211 lines/31668 bytes, SHA-25655830675f67c5814a5457a3c2adabc054d918b62582312c52d791fe268b78ef4. Draft manifest31/17615 and collection32/48767/3543340 exceed precisely the three proposed controls; all other ceilings fit. Every prior history byte is restored; a complete concise .1.36 record leaves CHANGES460/47004 below the unchanged90% threshold.
  Acceptance: Record the director decision. If approved, create/index an exact-limit ADR and separately owned canonical implementation, remeasure its actual source, preserve all prior history and prove actual validator boundaries before landing. If declined, retain history and obtain an alternative without archive rewriting or bypassing controls. Resume .1.37 only after a clean admitted boundary. This intake grants no source-reading credit, cleanup or parked feature activation.
  Verification: Director “Granted” approves exactly files31→32, manifest lines30→31 and bytes17039→17615. LIVE-DOCUMENT-PRESSURE-CONTAINMENT.10 implements from clean e55f7703 under indexed ADR0112 with fresh source/range/hash/count, complete prior-history retention, 22 actual-validator executions and exact staged canonical proof. The .1.36 draft remains historical evidence; no further capacity is authorized.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.10 - admit approved change-history member` (intake closed by its separately owned implementation)

- ID: `DART-STARTUP-READING.7`
  Status: `done`
  Goal: Obtain and route the next engineering-history capacity decision before further committed reading.
  Dependencies: `.1.46` committed with empty brief and clean repository; director decision before an additional infrastructure allowance under ADR0111.
  Scope: Proposal/intake only, owned by .1.46 discovery. Stable responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3; a separately owned canonical implementation requires approval and a clean repository.
  Proposal: engineering_notes max_files 27 to 28 and manifest max_lines 26 to 27. The projected manifest is 16230/16384 bytes; all root, segment, aggregate, ownership, route and other controls remain unchanged. No further member is authorized.
  Acceptance: Preserve every prior history byte and complete record; verify the actual governed draft against clean-source coordinates, bytes/hash, manifest order, full history and the actual routing validator. Record the director decision; if approved, create/index an exact-limit ADR and canonical implementation. No future slot, purge or parked-feature activation is granted.
  Evidence: docs/knowledge/dart-reading-next-engineering-history-capacity.md pins the actual .1.46 rollover: clean db762cd7 DEVELOPMENT_NOTES247-457, 211 lines/24521 bytes, SHA-256 b29e3bd321a1357afe2e779c7e138986e96bef3258c4408d785fc06b11bb58f5. Draft manifest27/16230 and collection28/26074/2789760 reject exactly files28/27 and manifest lines27/26. Full archive reconstruction and all 62 prior history hashes pass; the verified uncommitted draft is restored. A complete 285-byte dated note leaves the root459/40321 with every earlier record preserved.
  Verification: Director explicitly grants the proposed engineering-history capacity. Containment .11 implements exactly files27→28 and manifest lines26→27 from clean01a2159c under indexed ADR0113. Fresh source249-459, exact prior-history reconstruction and 22 production-validator executions pass; the explicit 2026-09-11 one-time focused/receipt exception governs closure. Earlier .1.46 proposal evidence remains historical; no future slot is authorized.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.11 - admit approved engineering-history member` (intake closed by its separately owned implementation)
  Decision update (2026-09-11): On 2026-09-11 the director explicitly granted a one-time canonical-receipt exception for .11 using passing focused checks, to avoid the current gate’s repeated PGEN/RGX builds. Normal commit hooks and all nine doctrines remain enabled; no full CI, dependency build or canonical receipt is claimed. All future verification boundaries retain their existing requirements.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `SUPPORTING-SOURCE-READING.1.17` | `pending` | After clean .4, read only pplugin.spec1–33 and spec.spec1–146 (179 fragments/26444 bytes); retained historical fixtures and quarantined code receive no new reading credit. |

## Decisions

- `2026-09-11`: The director delegates the .3.2 decision to the engineer. ADR0114 accepts the one-time reading-only exception on reverified source/commit evidence, keeps the complete Dart gate failed and every repair mandatory, and routes Julia. This is separate from the earlier .11 capacity exception.

- `2026-09-10`: Director grants the .7 engineering-history proposal. ADR0113 and containment .11 admit only files27→28/manifest lines26→27, with fresh clean-source preservation; the 2026-09-11 one-time receipt exception authorizes focused landing.

- `2026-09-10`: Director “Granted” approves .6 exactly. ADR0112 and containment .10 implement three change-history controls from clean e55f7703; all prior history and other gates/limits remain.

- `2026-09-10`: Director “ok for increasing the allowance” approves .5 exactly. ADR0111 and containment .9 implement the two engineering-history count controls from clean 4d5af8e9; all other limits/gates remain.

- `2026-09-09`: Director greenlight approves .4 exactly; ADR0110 and containment .8 implement it from clean f8b626f0. Other startup gates remain.

- `2026-09-09`: `.0` selects the reproducible 55-group plan; 56 remains the conservative capacity allowance. Pending children declare their verification tier only when activated, preserving the one-owning-leaf commit rule.
- `2026-09-09`: ADRs 0108/0109 authorize separate bounded Dart ownership without moving startup evidence or increasing member limits.
- Keep startup `.3.4` as the existing reading prerequisite/closeout owner; this tree provides directly navigable execution evidence.
- Reading findings are tracked immediately, but repair implementation respects the remaining startup gates.

## Open Questions

- `2026-09-11` resolution: .3.2 is decided under the director's explicit delegation and ADR0114. The earlier request below is historical; no closeout answer remains outstanding.

- .3.2 requires the director decision on its concrete reading-only exception. The earlier containment .11 waiver does not apply. Source/commit proof passes; format/analyzer failures remain repair-owned.

- `.7`: Director approved exactly engineering_notes files27→28 and manifest rows26→27; ADR0113/.11 implement the decision. No further capacity is preapproved.

- None for source reading. The director approved .6; ADR0112 and containment .10 own its canonical implementation.

## Blockers

- `2026-09-11` resolution: ADR0114 closes only the reading boundary. The .3.2 hold described below is historical; format/SDK repairs .2.24/.2.25 and build-on-update .80 remain required at their existing startup/admission gates.

- .3.2: canonical milestone proof conflicts with the still-unimplemented build-on-update policy; the complete Dart gate also has diagnosed format/analyzer failures under .2.24/.2.25. Reading-only exception is proposed, not granted. No PGEN/RGX rebuild or source repair is authorized by this audit.

- `.7`: The approved member is implemented by containment .11 / ADR0113; .1.47 resumes after its approved focused landing. Other startup/repair gates remain.

- Engineering-history capacity .5 is admitted by containment .9 / ADR0111; change-history .6 is admitted by .10 / ADR0112. No capacity decision remains at this boundary. Source repairs .2.1-.2.23 remain gated.
- Repair implementation remains gated by required reading and policy adoption; this does not block reading.

## Verification Log

- `2026-09-11` .3.2: Dart reading closes under .3.2 / ADR0114, exercising the director's explicit delegated decision for this reading-only boundary. Independent proof covers all 55 commits, 115 baseline-identical files, 80,297 fragments and 2,471,305 bytes. All 25 repair roots / 69 pending nodes remain open. Committed diagnostics pass 461 tests, storage25/47, CLI66 twice and corpus105; the full Dart gate remains failed on formatting and two SDK warnings. No canonical CI or PGEN/RGX build ran. Next is startup .3.5 Julia decomposition. All69 repair bodies remain exact; all55 child and100 touched Knowledge records are preserved; all source modes/blobs are unchanged.

- `2026-09-11` .3.1: Dart .3.1 independently verifies all 55 reading commits and 115 baseline-identical files: 80,297 fragments / 2,471,305 bytes. All 100 touched Knowledge cards and 62 prior repair nodes are preserved. Separate diagnostics pass 461 tests, storage25/47, CLI66 twice and corpus105; the complete Dart gate fails formatting in six tests and strict analysis reports two SDK deprecations. New .2.24/.2.25 own repairs. Formal .3.2 and startup .3.4 await a separate verification decision. Exact audit digests and replay live in docs/knowledge/dart-reading-commit-closeout-audit.md; diagnosed gate evidence is in dart-component-gate-sdk-compatibility.md. No full-gate pass or reading-parent completion is claimed.

- `2026-09-11` .1.55: Dart .1.55 completes write vivification and private progressive-authority reading: 1,269 fragments / 40,299 baseline-identical bytes. All 20 selected tests and write/progressive neutral checks pass. All 55 reading children now cover all 115 files and 2,471,305 bytes; formal .3 closeout and startup .3.4 remain pending. Existing nested-authority and other defects remain owned and open. Complete physical coverage is80297 fragments,80296 physical lines,2471305 bytes across115 EOF entries. Parent .1 and startup .3.4 await separate .3 canonical closeout; no defect remediation.

- `2026-09-11` .1.54: Dart .1.54 completes Unicode routes, uniform binding, function parser/shell and variadic consumers, then reads write vivification through line 292: 1,500 fragments / 44,403 baseline-identical bytes. All 43 tests and four neutral checks pass, including the existing emitted nested-write caller. Binding and variadic generated-state proof stays distinct from independent emitted execution; prior defects remain open. Cumulative54/55,79028 fragments/2431006 bytes,113 EOF plus write292; prior source findings remain owned.

- `2026-09-11` .1.53: Dart .1.53 completes trace, typed-source, casing, classifier, identity and negative-isolation consumers, then reads Unicode routes through line 70: 1,500 fragments / 44,020 baseline-identical bytes. All 29 tests and three neutral checks pass, including fresh-cache emitted Unicode execution. Exact source and label boundaries remain distinct from previously owned fluent-suffix, helper-order and CLI defects. Cumulative53/55,77528 fragments/2386603 bytes,108 EOF plus Unicode routes70; prior source findings remain owned.

- `2026-09-11` .1.52: Dart .1.52 completes staged enrichment, v1 registry and standalone lifecycle consumers, then reads trace through line 260: 1,500 fragments / 44,374 baseline-identical bytes. All 38 selected tests and staged/lifecycle neutral checks pass. Record four-route staged execution, narrow lifecycle emitted-text and malformed-twin assertions, and trace result preservation; prior defects remain open. Cumulative 52/55, 76028 fragments / 2342583 bytes, 102 EOF plus trace260; prior source findings remain owned.

- `2026-09-11` .1.51: Dart .1.51 reads staged enrichment tests292-1791: 1,500 fragments / 50,285 baseline-identical bytes. All 19 tests and staged/typed-source neutral checks pass, covering private provenance, frozen authority, atomic stitching, recursive budgets and rebasing. Prior .2.17/.2.18/.2.19 defects remain open; whole-consumer execution adds no unread source credit or MCP exposure. Cumulative51/55,74528 fragments/2298209 bytes,99 EOF plus staged1791. Parent .1 verification had remained at36/55 despite completed children; this leaf corrects that current rollup, preserving all child evidence.

- `2026-09-11` .1.50: Dart .1.50 completes source-emitter, AST, loader, parser and validator consumers, then reads staged enrichment through line 291: 1,500 fragments / 45,895 baseline-identical bytes. All 54 selected tests and generated-source/native-resolution/staged neutral checks pass, including existing emitted and four-route staged consumers. Prior defects remain open; parser-only corpus and non-regular-file fixture limits stay explicit. Cumulative50/55,73028 fragments/2247924 bytes,99 EOF plus staged291; no new defect or repair.

- `2026-09-11` .1.49: Dart .1.49 completes semantic admission, smoke and source-boundary alias consumers, then reads source emission through line 529: 1,500 fragments / 48,927 baseline-identical bytes. All 12 selected tests and semantic/typed-source/generated-source neutral checks pass, including fresh emitted alias and emitter callers. Prior defects remain open; no source, runtime or MCP change. Cumulative49/55,71528 fragments/2202029 bytes,94 EOF plus emitter529; no new defect or repair.

- `2026-09-11` .1.48: Dart .1.48 completes observation-route, runtime-capture, observed-index, source-foundation and static-graph consumers, then reads admission through line 166: 1,500 fragments / 48,937 baseline-identical bytes. All 24 selected tests and semantic 6/20/128 checks pass, including existing emitted execution and the twelve-role admission consumer. Earlier defects remain open; no source, runtime or MCP change. Cumulative48/55,70028 fragments/2153102 bytes,91 EOF plus admission166; no new defect or repair.

- `2026-09-11` .1.47: Dart .1.47 completes matching, scalar-text, self-hosted Unicode, call-projection, compilation-foundation and query consumers, then reads observation routes through240: 1,500 fragments / 50,626 baseline-identical bytes. All 30 selected tests and semantic/Unicode neutral checks pass, including the existing isolated emitted observer test. Prior query/call/observer defects remain open; no source or MCP behavior changes. Cumulative47/55,68528 fragments/2104165 bytes,86 EOF plus observation routes240; all baseline and prior-evidence checks pass.

- `2026-09-10`: .7 approval closes under containment .11 / ADR0113 after exact two-control/source/history and 22-validator proof; the explicit one-time focused commit precedes .1.47. Reading remains46/55.

- `2026-09-10`: Dart .1.46 completes interpreter tests and reads matching through 86: 1,500 fragments / 39,292 baseline-identical bytes. All 68 selected tests and write/numeric/named-mark neutral checks pass. The stale current Knowledge answer about absent-container writes is corrected with its historical prose preserved. No new runtime defect; prior findings, CI .80/.81 and source-repair gates remain. Reading reaches 46/55 children, 67,028 fragments / 2,053,539 bytes.

- `2026-09-10`: Dart .1.45 completes cursor admission, descriptor, execution and normalization consumers and reads interpreter tests through 407: 1,500 fragments / 41,762 baseline-identical bytes. All 75 selected tests and the neutral cursor check pass. No new defect; prior findings, CI .80/.81 and all source-repair gates remain. Reading reaches 45/55 children, 65,528 fragments / 2,014,247 bytes.

- `2026-09-10`: Dart .1.44 completes repeated-action and root-selection admission/core/routes tests and reads cursor admission through 298: 1,500 fragments / 45,785 baseline-identical bytes. All 13 selected tests and repeated-action/root-selection/cursor neutral checks pass. No new defect; prior findings, CI .80/.81 and all source-repair gates remain. Reading reaches 44/55 children, 64,028 fragments / 1,972,485 bytes.

- `2026-09-10`: Dart .1.43 finishes recognition and recursive-observation tests and reads repeated-action results through 333: 1,500 fragments / 45,121 baseline-identical bytes. All 22 selected tests and recognition/typed-source/repeated-action neutral checks pass, including existing independent emitted consumers. No new defect; the recognition-effect integration gap .2.4 and earlier repair gates remain. Reading reaches 43/55 children, 62,528 fragments / 1,926,700 bytes.

- `2026-09-10`: Dart .1.42 completes native trace, primary CLI, progressive and zero-argument tests and reads recognition through 216: 1,500 fragments / 48,485 baseline-identical bytes. All 39 selected tests and three neutral contracts pass, including independent emitted consumers. No new defect; trace .2.3, recognition .2.4, progressive startup .37 and helper-arity backlog .5 retain their repair owners. Reading reaches 42/55 children, 61,028 fragments / 1,881,579 bytes.

- `2026-09-10`: Dart .1.41 finishes MCP admission, dispatch and stdio tests and reads three native-trace import lines: 1,500 fragments / 48,287 baseline-identical bytes. All 17 selected MCP tests, neutral transport/admission and binding freshness pass. No new defect; Unicode key ordering .2.5, earlier repairs and CI .80/.81 remain owned and gated. Reading reaches 41/55 children, 59,528 fragments / 1,833,094 bytes.

- `2026-09-10`: Dart .1.40 finishes receiver-mutation and MCP binding tests and reads MCP admission through 705: 1,500 fragments / 49,088 baseline-identical bytes. All 16 selected tests pass, including the independent emitted mutation caller. Neutral mutation, MCP transport/admission and binding freshness pass; no new defect. Earlier repairs and CI .80/.81 remain owned and gated. Reading reaches 40/55 children, 58,028 fragments / 1,784,807 bytes.

- `2026-09-10`: Dart .1.39 completes gap and logical-helper tests and reads map-leaves mutation tests through 176: 1,500 fragments / 46,756 baseline-identical bytes. All 40 selected tests pass, including existing independent emitted consumers. Neutral gap, logical and map-leaves contracts pass; no new defect. Earlier repairs and CI .80/.81 remain owned and gated. Reading reaches 39/55 children, 56,528 fragments / 1,735,719 bytes.

- `2026-09-10`: Dart .1.38 completes duplicate-slot, frontend-trace, function-registry and function-staged-trace tests; gap tests reach line 718. The 1,500 fragments / 45,409 bytes remain baseline-identical. All 15 selected tests pass, including independently analyzed/executed emitted gap modules; neutral gap 9/0/63 plus public8/15/10/34 and duplicate-slot7/0/59 pass. No new defect; earlier repairs and CI .80/.81 retain their gates. Reading reaches 38/55 children, 55,028 fragments / 1,688,963 bytes.

- `2026-09-10`: Dart .1.37 completes compiled, named-mark, corpus and diagnostic tests and reads duplicate-slot tests through 123: 1,500 fragments / 44,134 baseline-identical bytes. All 38 selected tests pass, including the 105-fixture corpus and fifteen duplicate-slot roles; named-mark 7/3, diagnostic 3/11/6/8/0/20 and duplicate-slot 5/2/6/7/0/59 neutral checks pass. No new defect; previous findings and CI .80/.81 owners retain evidence and gates. Reading reaches 37/55 children, 53,528 fragments / 1,643,554 bytes.

- `2026-09-10`: .6 approval closes under containment .10 / ADR0112: exactly three controls, fresh clean-source reconstruction and 22 actual-validator executions; exact canonical proof precedes .1.37. Reading remains 36/55.

- `2026-09-10`: `.1.36` completes callable-codeblock/action-contract tests and reads compiled tests through 418: 1,500 fragments / 48,187 baseline-identical bytes. All 38 selected tests and neutral callable7/11/9/7/4/8/23 pass, including fresh offline standalone emitted fixture/contextual/seven-error proof. Earlier findings remain intact; no new code defect. Required rollover rejects three exact history-capacity axes; the verified draft is restored and .6 owns the director decision. Reading reaches 36/55.

- `2026-09-10`: `.1.35` completes validation/package/action-parser reading and contracts through 203: 1,500 fragments / 44,700 baseline-identical bytes. All 35 tests and neutral gap9/0/63/public8/15/10/34 plus duplicate7/0/59 checks pass. Ten reconstructed controls own .2.23 with two repair children: two null-name wrong-slot acceptances, six valid/rejecting controls and two provenance census inputs. Reading reaches 35/55.

- `2026-09-10`: `.1.34` completes emitter/trace and reads validation through 355: 1,500 fragments / 45,347 baseline-identical bytes. All 27 selected tests, isolated emitted callers, ten-family/eight-case proof and neutral generated-source checks pass. Earlier owners remain intact; no new defect or artifact-version change. Reading reaches 34/55.

- `2026-09-10`: `.1.33` completes static projection/SHA-256 and reads emitter through 55: 1,500 fragments / 42,984 baseline-identical bytes. All 28 tests and semantic 6/20/128 checks pass. Eight public native controls extend startup .70 grouped evidence and own regex-arrow .2.22 with two children: four constructor failures and four valid controls; all eight runtime results agree. Reading reaches 33/55.

- `2026-09-10`: `.1.32` completes query/runtime projection and reads static projection through 381: 1,500 fragments / 45,289 baseline-identical bytes. All 21 selected tests and semantic 6/20/128 checks pass. Earlier Dart .2.21/.2.20/.2.8, startup .67 and all other findings retain evidence; no new defect. Reading reaches 32/55.

- `2026-09-10`: `.1.31` completes semantic index and reads query through 668: 1,500 fragments / 43,744 baseline-identical bytes. All 18 tests and semantic 6/20/128 checks pass. Eight native controls own rejection detachment/encoding .2.21 with two children: four non-JSON defective cases and four detached JSON controls. Reading reaches 31/55.

- `2026-09-10`: `.1.30` completes call projection and reads semantic index through 399: 1,500 fragments / 43,400 baseline-identical bytes. All 28 semantic tests and neutral 6/20/128 checks pass. Nine public-query/typed-runtime controls extend startup .67 container evidence and own regex correlation .2.20 with two children, retaining seven valid/arity-rejection controls. Reading reaches 30/55.

- `2026-09-10`: `.1.29` completes Unicode mapping/scaffold and reads semantic call projection through 347: 1,500 fragments / 37,172 baseline-identical bytes. Eleven Dart tests and semantic 6/20/128 checks pass; all twelve Unicode runtime fixtures pass. Existing startup .22 evidence remains owned; no new defect. Reading reaches 29/55.

- `2026-09-10`: `.1.28` reads Unicode mapping 1190–2689: 1,500 fragments / 38,936 baseline-identical bytes. The lower table is complete and the upper table reaches U+A76F. Fresh generation/12 neutral fixtures pass; .1.27 runtime evidence is retained by source identity. No new defect; reading reaches 28/55.

- `2026-09-10`: `.1.27` completes staged enrichment and parse-job declarations, then reads Unicode lower mappings through 1189: 1,500 fragments / 39,481 baseline-identical bytes. All 33 selected tests and Unicode generation/12 neutral fixtures pass. Seventeen private/neutral controls own six malformed provenance acceptances under .2.19 with eleven agreeing controls. Reading reaches 27/55; prior evidence is retained.

- `2026-09-10`: `.1.26` reads staged enrichment 1807–3306: 1,500 fragments / 43,782 baseline-identical bytes. All 44 selected tests and neutral 123/129 mutations pass. Eleven independent private controls reproduce diagnostic-byte overruns (.2.17) and call-count wrap (.2.18), with seven valid controls; both repairs are owned. Reading reaches 26/55.

- `2026-09-10`: `.1.25` reads staged enrichment 307–1806: 1,500 fragments / 47,254 baseline-identical bytes. All 44 selected tests pass; frozen resolution/cache and recursive preflight/dispatch reconcile without a new defect. Reading reaches 25/55; prior evidence and repairs remain intact.

- `2026-09-10`: `.1.24` reads 1,500 fragments / 48,312 bytes, completing recognition, semantic observation and source location plus staged entry through 306; 58 tests pass. No new runtime defect; one stale Knowledge link corrected; prior owners remain intact.

- `2026-09-09`: `.1.23` reads 1,500 fragments / 41,162 bytes, completing matching and recognition through 483; 99 tests pass. Six exact Dart/Perl regex controls own three literal corruptions under .2.16 with three agreements; prior mechanisms and owners remain intact.

- `2026-09-09`: `.1.22` reads 1,500 fragments / 42,836 bytes, completing interpreter and matching through 900; 132 tests and structural corpus 31/31 pass. No new defect; prior mechanisms, limitations and repair owners remain intact.

- `2026-09-09`: `.1.21` reads 1,500 fragments / 39,933 bytes; 124 runtime and six contract tests pass. Nine exact input-slice comparisons extend .2.14 typed overflow and own .2.15 arity; prior findings and source bytes remain intact.

- `2026-09-09`: `.1.20` reads 1,500 fragments / 41,244 bytes; corrected 111-test selection and neutral numeric 55/18 pass. Eleven number, eight Unicode and six slice controls own .2.12-.2.14 with exact native/reconstructed and Perl facade/source comparisons; earlier owners remain intact.

- `2026-09-09`: `.1.19` reads 1,500 fragments / 43,446 bytes; 122 selected tests pass. Nine Dart native/reconstructed controls and nine Perl facade/source comparisons own hash splice pairing/order repair under .2.11; existing helper caveats retain FUTURE-PARITY-BACKLOG.5.

- `2026-09-09`: `.1.18` reads 1,500 fragments / 45,330 bytes; 140 selected tests pass. Nine native/reconstructed controls own false nested-callback cycles and helper-mediated identity loss under .2.10; earlier repairs remain intact.

- `2026-09-09`: `.1.17` reads 1,500 fragments / 40,984 bytes; 124 selected tests pass. Ten AST/native/reconstructed controls establish mixed-control return escape and skipped else under new .2.9; earlier repairs remain intact.

- `2026-09-09`: `.1.16` reads 1,500 fragments / 43,183 bytes; 100 selected tests pass. Six public native controls establish action-mediated semantic observer identity loss under new .2.8; prior repairs remain intact.

- `2026-09-09`: `.1.15` reads 1,500 fragments / 45,477 bytes; 82 selected tests and neutral progressive checks pass. Ten private-authority controls route nested budget/grant inheritance and diagnostic review to existing startup .37.1/.37.2.

- `2026-09-09`: `.1.14` reads 1,500 fragments / 44,607 bytes, completes function projection and reads bounded authority through line 746. All 24 selected function/progressive tests pass, including emitted analysis/execution; no new confirmed defect.

- `2026-09-09`: `.1.13` reads 1,500 fragments / 48,522 bytes, passes 25 selected tests and neutral Unicode 806/9/8/2 checks. Seven body-fluent controls extend existing suffix-retention repair .2.6; no repair is implemented.

- `2026-09-09`: `.1.12` reads 1,500 fragments / 41,630 bytes and passes 17 selected tests. Ten native/source controls establish compact argument corruption (.2.7) and outer regex-brace truncation (existing .2.2.2), with six successful controls.

- `2026-09-09`: `.1.11` reads 1,500 fragments / 39,800 bytes and passes 16 selected tests. Fourteen source/validation/compiler probes distinguish four discarded invalid tails, four valid controls and six retained/rejected malformed controls; .2.6 owns repair.

- `2026-09-09`: `.1.10` reads 1,500 fragments / 61,935 bytes and passes 11 selected tests. Four helper controls and one injected public-dispatch probe establish Unicode key-order divergence, owned by .2.5; no repair is implemented.

- `2026-09-09`: `.1.9` reads 65,536 generated bytes; four binding tests, neutral 35/10/10/76 validation, byte freshness and independent embedded-value identity pass. Reading is 9/55; no additional defect confirmed.

- `2026-09-09`: `.1.8` completes corpus/loader reading and MCP lines 1-9; all 42 selected tests pass, including 105/105 corpus execution. No additional defect confirmed; reading is 8/55.

- `2026-09-09`: .4 approval/intake closes through separately owned containment .8; exact preservation and 22 validator executions support its canonical landing. Reading remains 7/55.

- `2026-09-09`: `.1.7` completes compiler reading and passes 74 selected tests; eight controls confirm disconnected effect validation, rollback write persistence and structural observation bypasses, owned by .2.4.
- `2026-09-09`: `.1.6` reads four ranges and passes 27 selected tests; seven adapter probes confirm trace integer overflow after file reset, owned by .2.3.
- `2026-09-09`: `.1.5` reads four ranges and passes 55 selected tests; five probes confirm separate action-scanner and lifecycle-validator regex-brace failures, owned by .2.2 and routed to startup .54.3.
- `2026-09-09`: `.1.4` reads 1,500 lines / 42,924 bytes and passes 79 selected tests. No additional defect is confirmed; existing switch repair remains pending.
- `2026-09-09`: `.1.3` reads both ranges and passes 45 selected tests; five probes confirm attached-switch omission/default replacement, durably owned under .2.1 with exact reproduction.
- `2026-09-09`: `.1.2` reads both scoped ranges, preserves baseline identity and passes 50 existing AST/contract/binding/codeblock tests. Deferred literal traversal matches its canonical fact; next .1.3 resumes helper-family resolution.
- `2026-09-09`: `.1.1` reads all six scoped ranges, retains exact baseline bytes/digests and passes nine existing AST/parser tests. No new defect is confirmed; next `.1.2` resumes the literal-codeblock fields.
- `2026-09-09`: `.0` freezes 55 children and independently replays declared coordinates/digests with zero current source deltas. All resulting-store and focused checks are recorded in its commit; no reading or repair completion is claimed.
- Admission verifies inventory and bounded ownership only. Canonical outcome and exact receipt belong to the
  containment `.7.4` commit; no Dart reading verification is claimed here.

## Commit Log

- .3.2: `DART-STARTUP-READING.3.2 - close verified Dart reading under delegated decision`.

- .3.1: `DART-STARTUP-READING.3.1 - audit committed Dart reading and gate failures`.

- .1.55: `DART-STARTUP-READING.1.55 - complete planned Dart source reading`.

- .1.54: `DART-STARTUP-READING.1.54 - read binding and function consumers`.

- .1.53: `DART-STARTUP-READING.1.53 - read typed source and Unicode consumers`.

- .1.52: `DART-STARTUP-READING.1.52 - complete staged and lifecycle consumer reading`.

- .1.51: `DART-STARTUP-READING.1.51 - read staged enrichment authority consumers`.

- .1.50: `DART-STARTUP-READING.1.50 - complete frontend and emitter consumer reading`.

- .1.49: `DART-STARTUP-READING.1.49 - complete admission and read source-emitter consumers`.

- .1.48: `DART-STARTUP-READING.1.48 - read semantic observation and source consumers`.

- .1.47: `DART-STARTUP-READING.1.47 - read matching and semantic consumer contracts`.

- `.1.46`: `DART-STARTUP-READING.1.46 - complete interpreter consumer reading`.

- `.1.45`: `DART-STARTUP-READING.1.45 - complete cursor consumer reading`.

- `.1.44`: `DART-STARTUP-READING.1.44 - complete root selection consumer reading`.

- `.1.43`: `DART-STARTUP-READING.1.43 - read recognition and observation consumers`.

- `.1.42`: `DART-STARTUP-READING.1.42 - read trace CLI and progressive consumers`.

- `.1.41`: `DART-STARTUP-READING.1.41 - complete MCP dispatch and stdio reading`.

- `.1.40`: `DART-STARTUP-READING.1.40 - complete mutation and MCP contract reading`.

- `.1.39`: `DART-STARTUP-READING.1.39 - complete gap and logical contract reading`.

- `.1.38`: `DART-STARTUP-READING.1.38 - read identity and trace contracts`.

- `.1.37`: `DART-STARTUP-READING.1.37 - complete corpus and diagnostic test reading`.

- `2026-09-10`: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.10 - admit approved change-history member` closes approved intake .6.

- `.1.36`: `DART-STARTUP-READING.1.36 - complete callable contract test reading`.

- `.1.35`: `DART-STARTUP-READING.1.35 - own null named-selector validation gap`.

- `.1.34`: `DART-STARTUP-READING.1.34 - complete emitter and trace reading`.

- `.1.33`: `DART-STARTUP-READING.1.33 - own indexed edge source-correlation failures`.

- `.1.32`: `DART-STARTUP-READING.1.32 - complete query and runtime projection reading`.

- `.1.31`: `DART-STARTUP-READING.1.31 - own native semantic rejection immutability gap`.

- `.1.30`: `DART-STARTUP-READING.1.30 - own semantic container and source-correlation findings`.

- `.1.29`: `DART-STARTUP-READING.1.29 - complete Unicode and begin semantic call projection`.

- `.1.28`: `DART-STARTUP-READING.1.28 - read Unicode lower completion and upper mappings`.

- `.1.27`: `DART-STARTUP-READING.1.27 - read staged declarations and own provenance type gap`.

- `.1.26`: `DART-STARTUP-READING.1.26 - own staged diagnostic and call-counter boundary gaps`.

- `.1.25`: `DART-STARTUP-READING.1.25 - read frozen staged registry and recursive dispatch`.

- `2026-09-10`: `DART-STARTUP-READING.1.24 - finish recognition and source authority reading` closes the twenty-fourth reading child from clean 62b02fec.

- `2026-09-09`: `DART-STARTUP-READING.1.23 - finish matching; own regex literal normalization` closes the twenty-third reading child from clean f9020412.

- `2026-09-09`: `DART-STARTUP-READING.1.22 - finish interpreter; read matching and provenance` closes the twenty-second reading child from clean 4e872956.

- `2026-09-09`: `DART-STARTUP-READING.1.21 - read context bindings; own input slice boundaries` closes the twenty-first reading child from clean c8940411.

- `2026-09-09`: `DART-STARTUP-READING.1.20 - read value helpers; own numeric order and slice gaps` closes the twentieth reading child from clean 218f7f52.

- `2026-09-09`: `DART-STARTUP-READING.1.19 - read helper implementations; own hash splice pairing` closes the nineteenth reading child from clean a19fbe2f.

- `2026-09-09`: `DART-STARTUP-READING.1.18 - read helper dispatch; own callback identity gap` closes the eighteenth reading child from clean 8975ac84.

- `2026-09-09`: `DART-STARTUP-READING.1.17 - read value execution; own mixed control gap` closes the seventeenth reading child from clean 8b7a4a1a.

- `2026-09-09`: `DART-STARTUP-READING.1.16 - read rule execution; own observer error wrapping` closes the sixteenth reading child from clean abc06ebd.

- `2026-09-09`: `DART-STARTUP-READING.1.15 - read dispatch and runtime; own nested authority gap` closes the fifteenth reading child from clean 8aa9fa88.

- `2026-09-09`: `DART-STARTUP-READING.1.14 - finish function projection and read bounded authority` closes the fourteenth reading child from clean ced8f47a.

- `2026-09-09`: `DART-STARTUP-READING.1.13 - read Unicode and function bridge; own fluent suffix loss` closes the thirteenth reading child from clean 6c2e3ca4.

- `2026-09-09`: `DART-STARTUP-READING.1.12 - finish spec parser; own lexical defects` closes the twelfth reading child from clean 9a86da13.

- `2026-09-09`: `DART-STARTUP-READING.1.11 - read wire and parser; own body suffix loss` closes the eleventh reading child from clean 6f596d7b.

- `2026-09-09`: `DART-STARTUP-READING.1.10 - read MCP runtime; own Unicode key-order gap` closes the tenth reading child from clean c7e49a55.

- `2026-09-09`: `DART-STARTUP-READING.1.9 - read generated MCP contract window` closes the ninth reading child from clean 6d9776ca.

- `2026-09-09`: `DART-STARTUP-READING.1.8 - read corpus runner and spec loader` closes the eighth reading child from clean 7d52c98e.

- `2026-09-09`: containment .8 commits the approved history exception and .4 intake closeout; next .1.8.

- `2026-09-09`: `DART-STARTUP-READING.1.7 - read compiler; own recognition effect bypass` closes the seventh reading child and owns recognition effect integration repair.
- `2026-09-09`: `DART-STARTUP-READING.1.6 - read CLI and compiler entry; own trace overflow` closes the sixth reading child and owns the trace validation repair.
- `2026-09-09`: `DART-STARTUP-READING.1.5 - read callable and spec state; own regex scanner defects` closes the fifth reading child and owns the two regex-scanner repairs.
- `2026-09-09`: `DART-STARTUP-READING.1.4 - read assignment, mutation and scanner parsing` closes the fourth reading child.
- `2026-09-09`: `DART-STARTUP-READING.1.3 - read resolver and parser; own switch body omission` closes the third reading child and owns the first new Dart repair.
- `DART-STARTUP-READING.1.2 - read remaining ActionIR nodes and helper tables` completes AST reading and the first contract-table range.
- Created by `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.7.4 - admit bounded Dart reading ownership`.
- `DART-STARTUP-READING.0 - freeze exact bounded Dart reading children` defines ownership only; no reading child was complete at that boundary.
- `DART-STARTUP-READING.1.1 - read Dart entrypoints and initial ActionIR declarations` closes the first exact source-reading child.

## Changelog

- `2026-09-11`: .3.2 / ADR0114 close verified Dart reading under delegated authority and route Julia. Failed gates, all69 pending repair nodes and future canonical requirements remain.

- `2026-09-11`: .3.1 audits all reading commits, owns .2.24/.2.25 gate repairs and presents the exact .3.2 reading-only exception; all prior reading/repair evidence remains.

- `2026-09-11`: .1.55 completes the 55-child physical reading plan, refreshes stale progressive admission wording and routes formal .3 closeout. Existing repairs and startup gates remain.

- `2026-09-11`: .1.54 completes binding/function consumers and begins write vivification; next .1.55 after clean focused commit. Preserve exact route coverage and existing defects.

- `2026-09-11`: .1.53 completes typed-source and core Unicode consumers; next .1.54 after clean focused commit. Preserve exact route coverage and existing defects.

- `2026-09-11`: .1.52 completes staged/registry/lifecycle consumer reading and starts trace; next .1.53 after clean focused commit. Keep emitted-test and malformed-twin evidence boundaries explicit.

- `2026-09-11`: .1.51 reads staged authority consumers through1791; next .1.52 after clean focused commit. Synchronize parent coverage; prior findings and repair gates remain.

- `2026-09-11`: .1.50 completes frontend/emitter consumer reading and starts staged admission; next .1.51 after clean focused commit. Prior evidence and repair gates remain.

- `2026-09-11`: .1.49 completes admission/alias reading and starts emitter consumers; next .1.50 after clean focused commit. Prior evidence and repair gates remain.

- `2026-09-11`: .1.48 completes semantic observation/source/static consumer reading and starts admission; next .1.49 after clean focused commit. Prior evidence and repair gates remain.

- `2026-09-11`: .1.47 completes matching/scalar/Unicode/semantic consumer reading through the bounded observation prefix; next .1.48 after clean focused commit. No repair or new runtime claim.

- `2026-09-10`: Completed .1.46 from clean db762cd7; interpreter complete, matching through 86; stale nested-write fact corrected and .7 capacity proposal owned before .1.47.

- `2026-09-10`: Completed .1.45 from clean 4d2b2427; cursor consumers complete, interpreter through 407; next .1.46.

- `2026-09-10`: Completed .1.44 from clean f6e33821; repeated-action/root-selection complete, cursor admission through 298; next .1.45.

- `2026-09-10`: Completed .1.43 from clean c162a5d7; recognition/observation complete, repeated-action through 333; next .1.44.

- `2026-09-10`: Completed .1.42 from clean 0e832ae4; trace/CLI/progressive/zero-argument complete, recognition through 216; next .1.43.

- `2026-09-10`: Completed .1.41 from clean d2fa7b4d; MCP consumers complete, native trace imports through 3; next .1.42.

- `2026-09-10`: Completed .1.40 from clean 5886ec15; finished mutation/binding tests and read all MCP admission role bodies; no new defect; next .1.41.

- `2026-09-10`: Completed .1.39 from clean 91d59b3c; finished gap/logical tests and began receiver-mutation tests; no new defect; next .1.40.

- `2026-09-10`: Completed .1.38 from clean 7b9df4e7; completed identity/trace/registry tests and read gap tests through 718; no new defect; next .1.39.

- `2026-09-10`: Completed .1.37 from clean eaf4331e; finished corpus/diagnostic/compiled/named-mark tests, began duplicate-slot tests and routed .1.38; no new defect.

- `2026-09-10`: Approved capacity intake .6 is implemented by containment .10 with fresh provenance and canonical proof; next .1.37.

- `2026-09-10`: Completed .1.36 from clean 6cb42d87; completed callable test reading, began compiled tests, retained prior findings and owned capacity decision .6 before .1.37.

- `2026-09-10`: Completed .1.35 from clean 7f32f90b; retained prior findings, owned null named-selector validation .2.23 and routed .1.36.

- `2026-09-10`: Completed .1.34 from clean df88085f; finished emitter/trace reading, began validation, retained prior findings and routed .1.35.

- `2026-09-10`: Completed .1.33 from clean 802582d2; retained earlier findings, extended startup .70, owned regex-arrow indexed correlation .2.22 and routed .1.34.

- `2026-09-10`: Completed .1.32 from clean 26ea4d8e; finished query/runtime projection, began failed static projection, retained earlier findings and routed .1.33.

- `2026-09-10`: Completed .1.31 from clean 3f21f3b0; retained earlier findings, owned native non-JSON semantic rejection .2.21 with two children, and routed .1.32.

- `2026-09-10`: Completed .1.30 from clean b80acc01; retained all earlier findings, extended startup .67, owned semantic regex-source correlation .2.20 and two children, and routed .1.31.

- `2026-09-10`: Completed .1.29 from clean 17341bbe; finished Unicode/scaffold reading, began typed call projection, retained startup .22 and all earlier findings, and routed .1.30.

- `2026-09-10`: Completed .1.28 from clean dfc57ce1; completed lower-map reading, continued upper mappings, retained all prior findings and routed .1.29.

- `2026-09-10`: Completed .1.27 from clean 2b8b4bd7; owned the staged provenance type-validation gap and two repair children, completed both staged runtime modules, began Unicode mappings and routed .1.28.

- `2026-09-10`: Completed .1.26 from clean 692c5363; owned two staged resource boundary defects and seven repair nodes, preserved all prior evidence, and routed .1.27.

- `2026-09-10`: Completed .1.25 from clean canonical 9c644ecb; continued frozen staged registry and recursive dispatch reading, retained all prior owners, and routed .1.26.

- `2026-09-10`: `.1.24` completes three runtime files and reads staged entry through 306. Reading is 24/55; .5 owns engineering-history capacity before .1.25; no new runtime repair intake.

- `2026-09-09`: `.1.23` completes matching and reads recognition through 483; .2.16 owns regex literal normalization. Reading is 23/55; next .1.24.

- `2026-09-09`: `.1.22` completes interpreter and reads matching through 900. Reading is 22/55; next .1.23; no new repair intake.

- `2026-09-09`: `.1.21` reads interpreter through 9674, extends .2.14 and owns .2.15. Reading is 21/55; next .1.22.

- `2026-09-09`: `.1.20` reads interpreter through 8174 and owns numeric, Unicode-order and slice-end repairs .2.12-.2.14. Reading is 20/55; next .1.21.

- `2026-09-09`: `.1.19` reads interpreter through 6674 and owns hash splice repair .2.11. Reading is 19/55; next .1.20.

- `2026-09-09`: `.1.18` reads interpreter through 5174 and owns callback recursion identity repair .2.10. Reading is 18/55; next .1.19.

- `2026-09-09`: `.1.17` reads interpreter through 3674 and owns mixed value-control repair .2.9. Reading is 17/55; next .1.18.

- `2026-09-09`: `.1.16` reads interpreter through 2174 and owns observer error passthrough repair .2.8. Reading is 16/55; next .1.17.

- `2026-09-09`: `.1.15` completes bounded authority/generated plan and reads interpreter through 674; startup .37 owns nested authority findings. Reading is 15/55; next .1.16.

- `2026-09-09`: `.1.14` completes function-shell reading and begins bounded source-view authority; cumulative reading is 14/55. Next .1.15; earlier repairs remain gated.

- `2026-09-09`: `.1.13` completes staged v1 registry, Unicode classifier and function parser, reads shell through line 252 and owns the body-fluent suffix mechanism under .2.6; next .1.14.

- `2026-09-09`: `.1.12` completes spec parser, reads staged v1 registry through line 677 and records exact lexical defect ownership; next .1.13.

- `2026-09-09`: `.1.11` completes MCP server/wire, reads spec parser through line 744 and owns unsupported body suffix repair .2.6; next .1.12.

- `2026-09-09`: `.1.10` completes generated bundle/runtime reading, reads server through line 1019 and owns canonical Unicode ordering repair .2.5; next .1.11.

- `2026-09-09`: `.1.9` records complete first-window comprehension and retains the remaining schema/payload/runtime reading boundary at .1.10.

- `2026-09-09`: `.1.8` records validated corpus selection, structural output comparison and strict named/path loading; next .1.9 reads the generated bundle.

- `2026-09-09`: approved history capacity closes .4 through containment .8 / ADR0110, unblocking .1.8 reading.

- `2026-09-09`: `.1.7` completes compiler reading, begins corpus, owns .2.4 and routes capacity intake .4 before .1.8.
- `2026-09-09`: `.1.6` completes spec AST/CLI reading, starts compiler state, owns trace repair .2.3 and routes .1.7.
- `2026-09-09`: `.1.5` completes parser/callable/registry reading, begins spec AST, owns regex repair .2.2 and routes .1.6.
- `2026-09-09`: `.1.4` completes assignment/mutation/staged/scanner reading through line 2498 and routes .1.5.
- `2026-09-09`: `.1.3` completes resolver/initial-parser reading, owns attached-switch repair .2.1 and routes .1.4.
- `2026-09-09`: `.1.2` completes the second physical-reading checkpoint and routes `.1.3`.
- `2026-09-09`: `.1.1` completes the first physical-reading checkpoint and routes `.1.2`.
- `2026-09-09`: `.0` completes exact decomposition and routes `.1.1`; source-reading credit remains zero.
- `2026-09-09`: Admit pending ownership, exact baseline pointers and the startup bridge; decomposition is next.
