# DART-STARTUP-READING: Bounded Dart source reading and repair ownership

## Metadata

- Tree ID: `DART-STARTUP-READING`
- Status: `active` / `.1.8` complete; next `.1.9`
- Roadmap lane: `Session required reading / SESSION-STARTUP-READING.3.4`
- Created: `2026-09-09`
- Last updated: `2026-09-09`
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
- Recovery/purge remains blocked by startup `.7`; `.4` owns a capacity proposal only. No infrastructure increase or artifact purge is implemented here.

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
- Current reading: 8/55 children, 11,527/80,297 fragments and 345,207/2,471,305 bytes; sixteen entries through EOF
  plus mcp_contract.dart through line 9. Exact credit and comprehension remain in each completed node.

## Task Tree

- ID: `DART-STARTUP-READING`
  Status: `active`
  Goal: Complete bounded Dart reading and durable repair intake while preserving startup prerequisite ownership.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`

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
  Status: `active`
  Goal: Read and understand the entire owned Dart scope through the bounded children defined by `.0`.
  Dependencies: `.0`; never execute this broad node as one reading slice.
  Acceptance: Every child accounts for its exact source bytes and deltas, reconciles Knowledge before re-derivation,
    records comprehension and confirmed findings, runs necessary focused diagnostics and commits before the next child.
  Children: `.1.1-.1.55`; exact scopes and baseline evidence below, read in numeric order.
  Verification: 8/55 children complete; `.1.1-.1.8` own exact reading/comprehension evidence, and all later children remain pending.
  Commit: `pending`

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
  Status: `pending`
  Goal: Read bounded Dart group 9 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.8` committed; empty brief and clean repository.
  Scope: `dart/lib/src/mcp/mcp_contract.dart` bytes 320-65855
  Baseline evidence: 1 fragments / 65536 bytes; ordered range SHA-256 `0f1840a572eb4dae75c8b885cb994bf9844681670769813b98485144628d1342`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.10`
  Status: `pending`
  Goal: Read bounded Dart group 10 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.9` committed; empty brief and clean repository.
  Scope: `dart/lib/src/mcp/mcp_contract.dart` bytes 65856-83214; `dart/lib/src/mcp/mcp_contract_runtime.dart` lines 1-480; `dart/lib/src/mcp/mcp_server.dart` lines 1-1019
  Baseline evidence: 1500 fragments / 61935 bytes; ordered range SHA-256 `25354cec292d3b79780830dd1954708b52f5622be1848300a7fdb035e2cc596c`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.11`
  Status: `pending`
  Goal: Read bounded Dart group 11 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.10` committed; empty brief and clean repository.
  Scope: `dart/lib/src/mcp/mcp_server.dart` lines 1020-1092; `dart/lib/src/mcp/mcp_wire.dart` lines 1-683; `dart/lib/src/parser/spec_parser.dart` lines 1-744
  Baseline evidence: 1500 fragments / 39800 bytes; ordered range SHA-256 `cbec781fdd0ee92e762837ad3b13c4c958e458a052e5cb44ecab17b1166bb36c`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.12`
  Status: `pending`
  Goal: Read bounded Dart group 12 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.11` committed; empty brief and clean repository.
  Scope: `dart/lib/src/parser/spec_parser.dart` lines 745-1567; `dart/lib/src/parser/staged_parser_registry.dart` lines 1-677
  Baseline evidence: 1500 fragments / 41630 bytes; ordered range SHA-256 `279ad70c6021662ca7bc2c67131b1b6e57ddc8770d7213cb55ecebb560c57410`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.13`
  Status: `pending`
  Goal: Read bounded Dart group 13 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.12` committed; empty brief and clean repository.
  Scope: `dart/lib/src/parser/staged_parser_registry.dart` lines 678-761; `dart/lib/src/parser/unicode_rule_label.dart` lines 1-882; `dart/lib/src/parser/user_function_definition_parser.dart` lines 1-282; `dart/lib/src/parser/user_function_definition_shell.dart` lines 1-252
  Baseline evidence: 1500 fragments / 48522 bytes; ordered range SHA-256 `3aac67289b62a4b64af576c4fc7be021e226241b1a3b5d5a57ed0a0bf30e9a2e`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.14`
  Status: `pending`
  Goal: Read bounded Dart group 14 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.13` committed; empty brief and clean repository.
  Scope: `dart/lib/src/parser/user_function_definition_shell.dart` lines 253-1006; `dart/lib/src/runtime/bounded_child_parse_authority.dart` lines 1-746
  Baseline evidence: 1500 fragments / 44607 bytes; ordered range SHA-256 `0b7f74ece3a18212c310d4d07fcbd1c737cc20f0e1ba63fa7c49c45705b4e4b1`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.15`
  Status: `pending`
  Goal: Read bounded Dart group 15 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.14` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/bounded_child_parse_authority.dart` lines 747-1504; `dart/lib/src/runtime/generated_plan.dart` lines 1-68; `dart/lib/src/runtime/interpreter.dart` lines 1-674
  Baseline evidence: 1500 fragments / 45477 bytes; ordered range SHA-256 `0a7059216664bb263dfa5684aebe8ad64a2769a48daf82180f825023cee8e587`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.16`
  Status: `pending`
  Goal: Read bounded Dart group 16 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.15` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 675-2174
  Baseline evidence: 1500 fragments / 43183 bytes; ordered range SHA-256 `8f0321e727ef887a325ffc9316ba3d84943f99e8876f52a10940a4f4adcd676a`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.17`
  Status: `pending`
  Goal: Read bounded Dart group 17 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.16` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 2175-3674
  Baseline evidence: 1500 fragments / 40984 bytes; ordered range SHA-256 `481c979fa65c5cbb5e3b55b57950c4821a34d76ba4f9807361e0e3900b1337f9`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.18`
  Status: `pending`
  Goal: Read bounded Dart group 18 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.17` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 3675-5174
  Baseline evidence: 1500 fragments / 45330 bytes; ordered range SHA-256 `f406ef9dc15561cb17edf029f5c24ecefffe483fa9508ac0046337ce4d28726f`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.19`
  Status: `pending`
  Goal: Read bounded Dart group 19 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.18` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 5175-6674
  Baseline evidence: 1500 fragments / 43446 bytes; ordered range SHA-256 `6773e512221317f9ae4d6328c1b6e5ac2637b40deb6df0354011c5848b64b768`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.20`
  Status: `pending`
  Goal: Read bounded Dart group 20 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.19` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 6675-8174
  Baseline evidence: 1500 fragments / 41244 bytes; ordered range SHA-256 `d782685b64732f0f5b9e4c2ad7602a6dd5a5bb86c4d04d113ede296f2c8695a5`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.21`
  Status: `pending`
  Goal: Read bounded Dart group 21 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.20` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 8175-9674
  Baseline evidence: 1500 fragments / 39933 bytes; ordered range SHA-256 `39c0601fbb75a0036aca7ac6561644e83545c0b6a25617a053ddd6a49e4b2cf7`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.22`
  Status: `pending`
  Goal: Read bounded Dart group 22 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.21` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/interpreter.dart` lines 9675-10274; `dart/lib/src/runtime/matching.dart` lines 1-900
  Baseline evidence: 1500 fragments / 42836 bytes; ordered range SHA-256 `2bb30b2905fecc8005a1de903fa1c7d3f1f15f876f4eb7d4590cb943c25056b9`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.23`
  Status: `pending`
  Goal: Read bounded Dart group 23 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.22` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/matching.dart` lines 901-1917; `dart/lib/src/runtime/recognition_transaction.dart` lines 1-483
  Baseline evidence: 1500 fragments / 41162 bytes; ordered range SHA-256 `b8c607a80450ab598246cff0a98def4fa05b730b63509fbfabb57587ee3d090d`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.24`
  Status: `pending`
  Goal: Read bounded Dart group 24 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.23` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/recognition_transaction.dart` lines 484-965; `dart/lib/src/runtime/semantic_observation.dart` lines 1-113; `dart/lib/src/runtime/source_location.dart` lines 1-599; `dart/lib/src/runtime/staged_ast_enrichment.dart` lines 1-306
  Baseline evidence: 1500 fragments / 48312 bytes; ordered range SHA-256 `a09f9b09d23941bc183e07f9407082cdcd58bf093f1687190fff3e4c691d2725`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.25`
  Status: `pending`
  Goal: Read bounded Dart group 25 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.24` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/staged_ast_enrichment.dart` lines 307-1806
  Baseline evidence: 1500 fragments / 47254 bytes; ordered range SHA-256 `bf43c5c6f0b58628cc87531c45964101688d5d41528c3d4f7c0234980573a40f`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.26`
  Status: `pending`
  Goal: Read bounded Dart group 26 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.25` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/staged_ast_enrichment.dart` lines 1807-3306
  Baseline evidence: 1500 fragments / 43782 bytes; ordered range SHA-256 `66adc3328ccd2542542f637e13a637bf485b6c47c53e16fcbf39d39f430aaf3c`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.27`
  Status: `pending`
  Goal: Read bounded Dart group 27 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.26` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/staged_ast_enrichment.dart` lines 3307-3321; `dart/lib/src/runtime/staged_parse_job.dart` lines 1-296; `dart/lib/src/runtime/unicode_case_mapping.dart` lines 1-1189
  Baseline evidence: 1500 fragments / 39481 bytes; ordered range SHA-256 `2836d0a3697feb9ee846814088e1568659dff5ca55cf22e0e63a4bcb4ddc3943`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.28`
  Status: `pending`
  Goal: Read bounded Dart group 28 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.27` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/unicode_case_mapping.dart` lines 1190-2689
  Baseline evidence: 1500 fragments / 38936 bytes; ordered range SHA-256 `d3624127d86fe475310802502f59b8ef5c8d3cd1ef6f3d187603038f4d994e1c`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.29`
  Status: `pending`
  Goal: Read bounded Dart group 29 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.28` committed; empty brief and clean repository.
  Scope: `dart/lib/src/runtime/unicode_case_mapping.dart` lines 2690-3835; `dart/lib/src/scaffold.dart` lines 1-7; `dart/lib/src/semantic/semantic_call_projection.dart` lines 1-347
  Baseline evidence: 1500 fragments / 37172 bytes; ordered range SHA-256 `83fc2f7982759ace4650de163a5476dec075705d2189a6b7dfaa62dbecd37b44`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.30`
  Status: `pending`
  Goal: Read bounded Dart group 30 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.29` committed; empty brief and clean repository.
  Scope: `dart/lib/src/semantic/semantic_call_projection.dart` lines 348-1448; `dart/lib/src/semantic/semantic_index.dart` lines 1-399
  Baseline evidence: 1500 fragments / 43400 bytes; ordered range SHA-256 `dfb617b92de600f17db8c40cd395a7ae44ab3585fb9855bdee87194026c7b184`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.31`
  Status: `pending`
  Goal: Read bounded Dart group 31 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.30` committed; empty brief and clean repository.
  Scope: `dart/lib/src/semantic/semantic_index.dart` lines 400-1231; `dart/lib/src/semantic/semantic_query.dart` lines 1-668
  Baseline evidence: 1500 fragments / 43744 bytes; ordered range SHA-256 `97e9ea5dea6e3df014713a0e97e4da4901cea4492bc8a3882432076359c1459a`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.32`
  Status: `pending`
  Goal: Read bounded Dart group 32 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.31` committed; empty brief and clean repository.
  Scope: `dart/lib/src/semantic/semantic_query.dart` lines 669-1494; `dart/lib/src/semantic/semantic_runtime_projection.dart` lines 1-293; `dart/lib/src/semantic/semantic_static_projection.dart` lines 1-381
  Baseline evidence: 1500 fragments / 45289 bytes; ordered range SHA-256 `a9840cda06264c510391dbfee2973149c0b49d4bc166deae4ee728e56b2d8b43`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.33`
  Status: `pending`
  Goal: Read bounded Dart group 33 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.32` committed; empty brief and clean repository.
  Scope: `dart/lib/src/semantic/semantic_static_projection.dart` lines 382-1664; `dart/lib/src/semantic/sha256.dart` lines 1-162; `dart/lib/src/source_emitter.dart` lines 1-55
  Baseline evidence: 1500 fragments / 42984 bytes; ordered range SHA-256 `cdfa9bab2bdb9a54c5384b022a6ad338b6cbc2270e520f2724562c92858f9faa`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.34`
  Status: `pending`
  Goal: Read bounded Dart group 34 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.33` committed; empty brief and clean repository.
  Scope: `dart/lib/src/source_emitter.dart` lines 56-796; `dart/lib/src/trace/trace.dart` lines 1-404; `dart/lib/src/validation/spec_validator.dart` lines 1-355
  Baseline evidence: 1500 fragments / 45347 bytes; ordered range SHA-256 `eeb90e20a592b2b167b08f10280b0b86b5778fbb3912bf0d74e37b2cb4049cea`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.35`
  Status: `pending`
  Goal: Read bounded Dart group 35 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.34` committed; empty brief and clean repository.
  Scope: `dart/lib/src/validation/spec_validator.dart` lines 356-1072; `dart/pubspec.lock` lines 1-381; `dart/pubspec.yaml` lines 1-10; `dart/test/action_ast_parser_test.dart` lines 1-189; `dart/test/action_contracts_test.dart` lines 1-203
  Baseline evidence: 1500 fragments / 44700 bytes; ordered range SHA-256 `2d5776c4afc82f1631de7ea0df2208c2fe899ec5059b2cf1227e7db0d969181d`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.36`
  Status: `pending`
  Goal: Read bounded Dart group 36 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.35` committed; empty brief and clean repository.
  Scope: `dart/test/action_contracts_test.dart` lines 204-205; `dart/test/callable_codeblock_literal_contract_test.dart` lines 1-1080; `dart/test/compiled_spec_test.dart` lines 1-418
  Baseline evidence: 1500 fragments / 48187 bytes; ordered range SHA-256 `2e49dc784db23bc6db5df83e9df7a2f327a4e28701f862cbb723b876fb0f1c32`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.37`
  Status: `pending`
  Goal: Read bounded Dart group 37 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.36` committed; empty brief and clean repository.
  Scope: `dart/test/compiled_spec_test.dart` lines 419-478; `dart/test/complete_named_mark_contract_test.dart` lines 1-92; `dart/test/corpus_manifest_test.dart` lines 1-883; `dart/test/diagnostic_output_contract_test.dart` lines 1-342; `dart/test/duplicate_regex_slot_identity_contract_test.dart` lines 1-123
  Baseline evidence: 1500 fragments / 44134 bytes; ordered range SHA-256 `d8061f34d57331a6b1eb22b71e9db4b23ef20776e6fd224a393d33560af4e63e`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.38`
  Status: `pending`
  Goal: Read bounded Dart group 38 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.37` committed; empty brief and clean repository.
  Scope: `dart/test/duplicate_regex_slot_identity_contract_test.dart` lines 124-477; `dart/test/frontend_compiler_trace_test.dart` lines 1-112; `dart/test/function_registry_test.dart` lines 1-111; `dart/test/function_staged_trace_test.dart` lines 1-205; `dart/test/inter_match_gap_capture_contract_test.dart` lines 1-718
  Baseline evidence: 1500 fragments / 45409 bytes; ordered range SHA-256 `9e400f77481ca5ab9761503708762a188b01158025859d6ea88c923ca566962b`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.39`
  Status: `pending`
  Goal: Read bounded Dart group 39 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.38` committed; empty brief and clean repository.
  Scope: `dart/test/inter_match_gap_capture_contract_test.dart` lines 719-1588; `dart/test/logical_helper_contract_test.dart` lines 1-454; `dart/test/map_leaves_mutation_contract_test.dart` lines 1-176
  Baseline evidence: 1500 fragments / 46756 bytes; ordered range SHA-256 `7532ddaf24a3a8d860edd53734f8510f02aab378c648049d8004df11b9240bbe`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.40`
  Status: `pending`
  Goal: Read bounded Dart group 40 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.39` committed; empty brief and clean repository.
  Scope: `dart/test/map_leaves_mutation_contract_test.dart` lines 177-829; `dart/test/mcp_contract_dart_binding_test.dart` lines 1-142; `dart/test/mcp_server_dart_admission_test.dart` lines 1-705
  Baseline evidence: 1500 fragments / 49088 bytes; ordered range SHA-256 `3e97998d6e2a3be4b40a67e64370b30d81f61d499448b1545199bd5c146aad18`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.41`
  Status: `pending`
  Goal: Read bounded Dart group 41 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.40` committed; empty brief and clean repository.
  Scope: `dart/test/mcp_server_dart_admission_test.dart` lines 706-962; `dart/test/mcp_server_dart_dispatch_test.dart` lines 1-665; `dart/test/mcp_server_dart_stdio_test.dart` lines 1-575; `dart/test/native_pipeline_trace_test.dart` lines 1-3
  Baseline evidence: 1500 fragments / 48287 bytes; ordered range SHA-256 `9d0046da1a830ed022b091666b7529eee81e6f5f9bf7f19ec0522674d09662f5`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.42`
  Status: `pending`
  Goal: Read bounded Dart group 42 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.41` committed; empty brief and clean repository.
  Scope: `dart/test/native_pipeline_trace_test.dart` lines 4-182; `dart/test/primary_cli_test.dart` lines 1-303; `dart/test/progressive_span_dispatch_contract_test.dart` lines 1-614; `dart/test/punctuation_light_zero_arg_contract_test.dart` lines 1-188; `dart/test/recognition_transaction_contract_test.dart` lines 1-216
  Baseline evidence: 1500 fragments / 48485 bytes; ordered range SHA-256 `9c7110f9999de79d39fcbef6563d11e3074fa8cc0f1225ea72acde4a08d9b964`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.43`
  Status: `pending`
  Goal: Read bounded Dart group 43 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.42` committed; empty brief and clean repository.
  Scope: `dart/test/recognition_transaction_contract_test.dart` lines 217-919; `dart/test/recursive_observation_contract_test.dart` lines 1-464; `dart/test/repeated_action_result_contract_test.dart` lines 1-333
  Baseline evidence: 1500 fragments / 45121 bytes; ordered range SHA-256 `f3d235974eaaeeea66058678ef238f7dc59b2f2ae3cbbebfdf45d2bd0f0c7ba9`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.44`
  Status: `pending`
  Goal: Read bounded Dart group 44 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.43` committed; empty brief and clean repository.
  Scope: `dart/test/repeated_action_result_contract_test.dart` lines 334-498; `dart/test/root_rule_selection_admission_test.dart` lines 1-536; `dart/test/root_rule_selection_core_test.dart` lines 1-229; `dart/test/root_rule_selection_routes_test.dart` lines 1-272; `dart/test/rule_local_cursor_contract_test.dart` lines 1-298
  Baseline evidence: 1500 fragments / 45785 bytes; ordered range SHA-256 `9ef35e9b346de215c0aa27b98d902398b99af0c89cb80fb081025ad1300a0080`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.45`
  Status: `pending`
  Goal: Read bounded Dart group 45 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.44` committed; empty brief and clean repository.
  Scope: `dart/test/rule_local_cursor_contract_test.dart` lines 299-456; `dart/test/rule_local_cursor_descriptor_test.dart` lines 1-257; `dart/test/rule_local_cursor_execution_test.dart` lines 1-411; `dart/test/rule_local_cursor_normalization_test.dart` lines 1-267; `dart/test/runtime_interpreter_test.dart` lines 1-407
  Baseline evidence: 1500 fragments / 41762 bytes; ordered range SHA-256 `acfee426913e8f0602f3c8d0e24984ed8845938126fad2a4903ee06830224de6`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.46`
  Status: `pending`
  Goal: Read bounded Dart group 46 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.45` committed; empty brief and clean repository.
  Scope: `dart/test/runtime_interpreter_test.dart` lines 408-1821; `dart/test/runtime_matching_test.dart` lines 1-86
  Baseline evidence: 1500 fragments / 39292 bytes; ordered range SHA-256 `3f375018241ada715ebede846b8f23a8eff225c44ab7717ee258974271afcc3f`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.47`
  Status: `pending`
  Goal: Read bounded Dart group 47 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.46` committed; empty brief and clean repository.
  Scope: `dart/test/runtime_matching_test.dart` lines 87-256; `dart/test/scalar_text_contract_test.dart` lines 1-26; `dart/test/self_hosted_unicode_rule_label_test.dart` lines 1-60; `dart/test/semantic_index_call_projection_test.dart` lines 1-229; `dart/test/semantic_index_compilation_foundation_test.dart` lines 1-305; `dart/test/semantic_index_query_kernel_test.dart` lines 1-470; `dart/test/semantic_index_runtime_observation_routes_test.dart` lines 1-240
  Baseline evidence: 1500 fragments / 50626 bytes; ordered range SHA-256 `5a4ed53c1cb14de136ea8fbf17e38bdb4d8d0c6b2d7e7564a10f16c0b260ef8a`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.48`
  Status: `pending`
  Goal: Read bounded Dart group 48 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.47` committed; empty brief and clean repository.
  Scope: `dart/test/semantic_index_runtime_observation_routes_test.dart` lines 241-462; `dart/test/semantic_index_runtime_observation_test.dart` lines 1-284; `dart/test/semantic_index_runtime_projection_test.dart` lines 1-281; `dart/test/semantic_index_source_foundation_test.dart` lines 1-299; `dart/test/semantic_index_static_graph_test.dart` lines 1-248; `dart/test/semantic_introspection_dart_admission_test.dart` lines 1-166
  Baseline evidence: 1500 fragments / 48937 bytes; ordered range SHA-256 `8ad7fb9cc1bf8824d136e740381789ad3cb097cc6ba3bb6f0856a909e44deb07`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.49`
  Status: `pending`
  Goal: Read bounded Dart group 49 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.48` committed; empty brief and clean repository.
  Scope: `dart/test/semantic_introspection_dart_admission_test.dart` lines 167-779; `dart/test/smoke_test.dart` lines 1-16; `dart/test/source_boundary_compatibility_aliases_test.dart` lines 1-342; `dart/test/source_emitter_test.dart` lines 1-529
  Baseline evidence: 1500 fragments / 48927 bytes; ordered range SHA-256 `e2a11d82a1f815d300cef855cb47bc8ecae541e94b10a673fd7aa343f8123b98`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.50`
  Status: `pending`
  Goal: Read bounded Dart group 50 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.49` committed; empty brief and clean repository.
  Scope: `dart/test/source_emitter_test.dart` lines 530-866; `dart/test/spec_ast_test.dart` lines 1-104; `dart/test/spec_loader_test.dart` lines 1-268; `dart/test/spec_parser_test.dart` lines 1-256; `dart/test/spec_validator_test.dart` lines 1-244; `dart/test/staged_ast_enrichment_contract_test.dart` lines 1-291
  Baseline evidence: 1500 fragments / 45895 bytes; ordered range SHA-256 `28ad1b8331d1a781e44aa8f0e1a1a83d54ff2a6431665ccca31ecf1caa7133d5`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.51`
  Status: `pending`
  Goal: Read bounded Dart group 51 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.50` committed; empty brief and clean repository.
  Scope: `dart/test/staged_ast_enrichment_contract_test.dart` lines 292-1791
  Baseline evidence: 1500 fragments / 50285 bytes; ordered range SHA-256 `fb9147ec31a50756ce20735ab8b49a432ec1b7dacc13e8a20ee11803f68abbae`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.52`
  Status: `pending`
  Goal: Read bounded Dart group 52 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.51` committed; empty brief and clean repository.
  Scope: `dart/test/staged_ast_enrichment_contract_test.dart` lines 1792-2399; `dart/test/staged_parser_registry_test.dart` lines 1-425; `dart/test/standalone_lifecycle_block_contract_test.dart` lines 1-207; `dart/test/trace_test.dart` lines 1-260
  Baseline evidence: 1500 fragments / 44374 bytes; ordered range SHA-256 `af4afe6ffa013327537799d74b93095449f46cf6d6238a6bbf316a8345f702e9`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.53`
  Status: `pending`
  Goal: Read bounded Dart group 53 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.52` committed; empty brief and clean repository.
  Scope: `dart/test/trace_test.dart` lines 261-269; `dart/test/typed_source_location_contract_test.dart` lines 1-420; `dart/test/unicode_case_mapping_test.dart` lines 1-58; `dart/test/unicode_rule_label_classifier_test.dart` lines 1-84; `dart/test/unicode_rule_label_identity_routes_test.dart` lines 1-416; `dart/test/unicode_rule_label_negative_isolation_test.dart` lines 1-443; `dart/test/unicode_rule_label_routes_test.dart` lines 1-70
  Baseline evidence: 1500 fragments / 44020 bytes; ordered range SHA-256 `e2e59b430e816290b10dd28f0d6aa8faed7bf523c673a86ee5532430e836a82a`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.54`
  Status: `pending`
  Goal: Read bounded Dart group 54 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.53` committed; empty brief and clean repository.
  Scope: `dart/test/unicode_rule_label_routes_test.dart` lines 71-259; `dart/test/uniform_binding_contract_test.dart` lines 1-487; `dart/test/user_function_definition_parser_test.dart` lines 1-93; `dart/test/user_function_definition_shell_test.dart` lines 1-210; `dart/test/variadic_user_function_contract_test.dart` lines 1-229; `dart/test/write_vivification_contract_test.dart` lines 1-292
  Baseline evidence: 1500 fragments / 44403 bytes; ordered range SHA-256 `fceaac51ed040029358f4fdc5c94bab56751241105a9b18d1270ee36a0932a87`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.1.55`
  Status: `pending`
  Goal: Read bounded Dart group 55 and reconcile its source evidence.
  Dependencies: `DART-STARTUP-READING.1.54` committed; empty brief and clean repository.
  Scope: `dart/test/write_vivification_contract_test.dart` lines 293-767; `dart/test_dormant/progressive_span_dispatch_authority_test.dart` lines 1-794
  Baseline evidence: 1269 fragments / 40299 bytes; ordered range SHA-256 `9b6f6e3fb70c306559fde67a2815ffad9a004e2c586bbd6e5f1663b2b3a25d0b`.
  Acceptance: Read every owned byte, inspect current deltas, reconcile canonical Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit.
  Verification: `pending`
  Commit: `pending`

- ID: `DART-STARTUP-READING.2`
  Status: `pending`
  Goal: Reconcile and retain ownership of every confirmed Dart finding established during the reading.
  Dependencies: Findings from `.1`; implementation additionally requires startup `.3`, `.4` and `.5`.
  Children: `.2.1`, `.2.2`, `.2.3`, `.2.4`; further confirmed findings receive disjoint owners here.
  Acceptance: Cross-reference existing owners for known defects; create disjoint bounded repair children here
    immediately for new confirmed defects, with mechanism, source, reproduction, acceptance and unblock conditions.
    If no new repair is needed, close this intake with an explicit complete reconciliation rather than inventing work.
  Verification: `pending`; `.1.3` owns attached-switch omission/default replacement under `.2.1`; `.1.5` confirms regex-brace action scanning and lifecycle validation defects under `.2.2`. Reading .1.6 confirms numeric trace overflow and reset-before-failure under .2.3. Reading .1.7 confirms disconnected recognition effect validation, leaked writes after rollback and observation edge-closure bypass under .2.4. No repair implementation is admitted before startup gates.
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

- ID: `DART-STARTUP-READING.3`
  Status: `pending`
  Goal: Close Dart reading with exact coverage, current-delta, comprehension and child-commit proof.
  Dependencies: `.0` and every `.1` child complete; all findings durably owned under `.2` or existing trees.
  Acceptance: Independently prove complete baseline/current coverage and all child commits; preserve every
    pending repair, complete only startup `.3.4` reading, and route startup Julia `.3.5`.
    Pending repairs keep this tree open; reading closeout is not defect remediation.
  Verification: `pending`; canonical milestone proof is required before reading-parent closeout.
  Commit: `pending`

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

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `DART-STARTUP-READING.1.9` | `pending` | Read the first UTF-8-safe byte window of the generated MCP bundle after .1.8 commits cleanly. |

## Decisions

- `2026-09-09`: Director greenlight approves .4 exactly; ADR0110 and containment .8 implement it from clean f8b626f0. Other startup gates remain.

- `2026-09-09`: `.0` selects the reproducible 55-group plan; 56 remains the conservative capacity allowance. Pending children declare their verification tier only when activated, preserving the one-owning-leaf commit rule.
- `2026-09-09`: ADRs 0108/0109 authorize separate bounded Dart ownership without moving startup evidence or increasing member limits.
- Keep startup `.3.4` as the existing reading prerequisite/closeout owner; this tree provides directly navigable execution evidence.
- Reading findings are tracked immediately, but repair implementation respects the remaining startup gates.

## Open Questions

- None for source reading. The director approved .4’s exact history exception; ADR0110 and containment .8 own its implementation.

## Blockers

- History capacity is admitted by containment .8 under ADR0110; no reading blocker remains at this boundary. Source repairs .2.1-.2.4 remain gated.
- Repair implementation remains gated by required reading and policy adoption; this does not block reading.

## Verification Log

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
