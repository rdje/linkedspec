# JULIA-STARTUP-READING: Bounded Julia reading and repair ownership

## Metadata

- Tree ID: `JULIA-STARTUP-READING`
- Status: `active` / reading 14/52; selector, switch, recognition, pattern and observer repairs pending
- Roadmap lane: `Session required reading / SESSION-STARTUP-READING.3.5`
- Created: `2026-09-11`
- Last updated: `2026-09-11`
- Owner: repo-local workflow
- Decomposition owner: `SESSION-STARTUP-READING.3.5.0`

## Goal

Read every Julia baseline byte and current delta through bounded committed slices.
Preserve comprehension, exact coverage, confirmed defect ownership and the separate
startup reading prerequisites. Startup .3.5 remains the reading-closeout owner.

## Non-Goals

- Enumeration, packing and running a whole consumer grant no unread-source credit.
- Source repairs remain behind startup .3/.4/.5; previously owned findings retain their IDs.
- No capacity increase, archive rewrite, source change or parked-feature activation.
- ADR0114 closes only Dart reading and grants no Julia milestone verification exception.

## Acceptance Criteria

- Account for every baseline/current entry, mode/blob and byte exactly once.
- Each source-reading child is at most1,500 fragments /65,536 bytes and commits independently.
- Read physically in smaller untruncated windows before marking a child complete.
- Reconcile Knowledge before re-deriving facts; own confirmed repairs before implementation.
- Keep book, roadmap and current pointers accurate; run focused proof appropriate to each slice.
- Check resulting evidence/history pressure before each leaf; use .4 before a required rollover exceeds capacity.
- Close .1 and startup .3.5 only after .3 independently verifies coverage and child commits.
- Pending repairs keep this tree open; source comprehension is not runtime signoff.

## Exact Baseline And Range Plan

- Source baseline: `baeb984e36a94a15951cd23d4c52def5064cdaca`.
- Planning activation: `a2788b95369964880534d4d7b1d0e31b106bc023`.
- All 95 paths /75,984 physical lines /2,693,170 bytes remain baseline-identical.
- The 52 groups contain146 exact source ranges; no empty entry or oversized-line byte split is needed.
- Inventory SHA-256: `ca3cff4fe4c0e162448d6dbac82d89898673023951afaeced17d5b9a838ccd10`.
- Ordered range SHA-256: `fde325f80ae7b56c5890d149fbc965c09890890e963a1fa9aab08e8c9d962337`.
- Line coordinates are one-based, inclusive LF physical lines. Every child pins its range digest.
- Current physical reading: 14/52 children, 19,425/75,984 lines and 743,537/2,693,170 bytes; twenty-two complete files.
- Exact replay and capacity assessment: `docs/knowledge/julia-startup-reading-coverage.md`.

## Task Tree

- ID: `JULIA-STARTUP-READING`
  Status: `active`
  Goal: Complete bounded Julia reading and maintain precise ownership of all findings.
  Children: `.1`, `.2`, `.3`, `.4`

- ID: `JULIA-STARTUP-READING.1`
  Status: `active`
  Goal: Read and understand all 52 exact Julia groups in numeric order.
  Dependencies: Startup .3.5.0 decomposition committed; each child starts from a clean prior handoff.
  Children: `.1.1-.1.52`, with exact scopes below.
  Acceptance: Every child records physical coverage, comprehension, Knowledge reconciliation, findings and focused proof before its commit. Retain all current-delta and interrupted-range evidence.
  Verification: Julia .1.14 reads Interpreter1616-3115: 14/52 groups, 19,425 fragments /743,537 bytes and twenty-two complete files. Existing rule39/control6/emitter65/capture66 assertions pass (176 plus selection1); the 108-assertion public observer diagnostic isolates action-child exception identity loss across four routes. Neutral semantic6/20/128, rollout9/0 and admission6/0 pass. New .2.6.1/.2.6.2 own passthrough repair and supported-route recurrence; all prior repairs, source, evidence and ADR0115 controls remain. Julia .1.15 is next; no full component/canonical gate or dependency build.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.1`
  Status: `done`
  Goal: Read bounded Julia group 1 and reconcile its source evidence.
  Dependencies: `SESSION-STARTUP-READING.3.5.0` committed; empty brief and clean repository.
  Scope: `julia/Manifest.toml` lines 1-88; `julia/Project.toml` lines 1-20; `julia/README.md` lines 1-963
  Baseline evidence: 1071 fragments / 65410 bytes; ordered range SHA-256 `725354d673b21f42b20d33a74b82bd9535d39a13c9eb1b6d8cead4ae3c998e2c`.
  Activation commit: `f0f11f45986ee231b0b02a43d88cfac2137caf22`.
  Verification tier: `focused`
  Focused checks: Exact bounded source reading and baseline identity; manifest/package loading and documented native entry smoke through the managed Julia wrapper; Knowledge reconciliation, memory, both histories, rendered book, scope/whitespace and normal doctrines.
  Canonical trigger: `none` — ordinary source-reading evidence; no source, public contract, gate, dependency or infrastructure change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Package metadata locks five external source trees and four direct dependencies, with package-relative manifest identity and Julia 1.12 compatibility. README spans staged rule/function compilation, immutable semantic source/query/observation ownership, caller-authorized read-only MCP, native/generated callbacks, callable/contextual codeblocks, eager logical truthiness, managed depot commands, progressive loading, diagnostics/trace and historical rollout chronology. It distinguishes no-file native source compilation from an MCP adapter over host-created indexes. The final six README lines remain unread for .1.2.
  Knowledge: Reconciled Julia package, depot, local gate, mdBook usage, and startup public-teaching facts; dated current evidence is in docs/knowledge/julia-package-readme-reading.md.
  Findings: Reuse startup .41.2/.41.3/.41.7 for exact README status/privacy/locality teaching; no new runtime defect or completed repair. No duplicate repair root.
  Verification: Physically read Manifest 1–88, Project 1–20 and README 1–963 in eight untruncated windows; exact 1071-fragment/65410-byte digest and baseline identity pass. Managed Julia 1.12.7 loads matching package metadata; seven exact README fences pass; documented primary output is exact canonical JSON with empty stderr. Semantic 6/20/128, rollout 9/9 and admission 6/6 pass. No full component/canonical gate or dependency build; continuity, book and normal doctrine proof accompany this commit.
  Commit: `JULIA-STARTUP-READING.1.1 - read package manifests and README examples`.

- ID: `JULIA-STARTUP-READING.1.2`
  Status: `done`
  Goal: Read bounded Julia group 2 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.1` committed; empty brief and clean repository.
  Scope: `julia/README.md` lines 964-969; `julia/bin/corpus_runner.jl` lines 1-5; `julia/bin/linkedspec_julia.jl` lines 1-5; `julia/src/LinkedSpecJulia.jl` lines 1-520; `julia/src/action/ActionAst.jl` lines 1-964
  Baseline evidence: 1500 fragments / 38998 bytes; ordered range SHA-256 `102f0726d6ff496e806c63dcd6656b52fdcb4b7e2db3fcd7507a9da2adf33ff7`.
  Activation commit: `2f3129f880f6a1481daf23eeec982a57c631bb81`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading and baseline identity; focused native ActionIR/parser tests and entrypoint smoke through managed Julia; Knowledge, memory, histories, rendered book, scope/whitespace and normal doctrines.
  Canonical trigger: `none` — ordinary reading evidence with no source, contract, dependency, gate or infrastructure change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: The two five-line commands delegate to one native module; its 37 includes assemble tracing, source/action parsing, compiled/runtime authorities, generated source, semantic projection/query and MCP before native loading/CLI. Stable status helpers retain repo-relative entrypoint data. The ActionAst prefix defines typed source spans, statements/calls, recognition and progressive operations, inert staged text/options declarations, variable/access/write nodes, aggregates and explicit/contextual callable bodies, scalar/nested assignments, receiver mutation/continuation and control nodes. Immediate vector copies do not imply recursive AST immutability; tuple-backed staged sequences retain typed logical data. The switch struct continues in .1.3. Separately inspected punctuation proof removes source metadata for alias AST equality, preserves exclusions/known contains drift and reconstructs emitted JSON without independent emitted-module execution.
  Knowledge: Reconciled action AST/parser, frontend JSON, helper contracts and receiver-arity facts; current boundary is docs/knowledge/julia-facade-action-model-reading.md. The parser fact now labels its original structural-only stage historical.
  Findings: No new runtime defect. Preserve FUTURE-PARITY-BACKLOG.5 contains-arity ownership and extend existing startup .41.7 to README lines 964–965; no unmanaged command ran.
  Verification: Five exact ranges read untruncated: 1500 fragments /38998 baseline-identical bytes, child digest 102f0726d6ff496e806c63dcd6656b52fdcb4b7e2db3fcd7507a9da2adf33ff7. Managed Julia 1.12.7 defines all 452 public names; package entrypoint assertions and both help exits pass. Existing punctuation consumer 55/55 and neutral 6 standalone/4 receiver/6 invalid pass. No full component/canonical gate, dependency build, emitted child or later reading credit. Source/old-evidence preservation, Knowledge, memory, histories, rendered book and normal doctrines accompany the commit.
  Commit: `JULIA-STARTUP-READING.1.2 - read facade and typed action model`.

- ID: `JULIA-STARTUP-READING.1.3`
  Status: `done`
  Goal: Read bounded Julia group 3 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.2` committed; empty brief and clean repository.
  Scope: `julia/src/action/ActionAst.jl` lines 965-1698; `julia/src/action/ActionContracts.jl` lines 1-766
  Baseline evidence: 1500 fragments / 41401 bytes; ordered range SHA-256 `baad93ccbbfbb2c116e6adb15afd3ecf2b8d95e7e11565e4f0a529aec454b900`.
  Activation commit: `3fe9346d3dd62f59b32ab1aa4a49d7044e4a5370`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading/baseline identity; native AST JSON and contract-resolution controls through managed Julia; Knowledge, memory, histories, rendered book, scope/whitespace and normal doctrines.
  Canonical trigger: `none` — ordinary reading evidence; no source, public contract, dependency, gate or infrastructure change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: ActionAst completes switch/case/default/raw nodes, recursively searches structural expressions for retired one-bare-variable selectors, and emits fresh JSON for every typed family with exact optional fields, callable source_text/signature/body and receiver mutation continuation. Its selector visitor skips explicit/contextual callable bodies, creating the confirmed .2.1 gap. ActionContracts defines typed resolution/diagnostic output, public entrypoints, canonical numeric/control/source-boundary aliases and helper-family sets; the visitor prefix distinguishes grammar-owned intrinsics from ordinary helper calls. The fluent visitor and remaining resolver continue in .1.4. Supporting compiler/emitter and contract-visitor ranges were inspected only for diagnosis and receive no advance credit.
  Knowledge: Reconciled selector retirement, action contract resolution and staged marker facts; docs/knowledge/julia-callable-selector-validation-gap.md owns exact causal evidence and replay. Original selector admission is now explicitly historical with its current limitation.
  Findings: Confirmed callable-body selector validation defect owns pending .2.1/.2.1.1/.2.1.2; no repair or broader backend conclusion.
  Verification: Exact two owned ranges total 1500 fragments /41401 baseline-identical bytes, digest baad93ccbbfbb2c116e6adb15afd3ecf2b8d95e7e11565e4f0a529aec454b900. Twenty asserted two-family/five-form/before-after controls bind the skipped callable branch causally while valid computed constructors remain supported; all four array-source Perl Get controls reject. Existing uniform-binding 61/61 and projection/alias 8/8 pass. Emitted controls load fresh modules in one process, not child processes. Diagnostic body descent is process-local; repository sources/tests/formats unchanged. Coverage, preservation, Knowledge, memory, histories, book and normal doctrines accompany the commit; no complete component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.3 - read action projection and own callable selector gap`.

- ID: `JULIA-STARTUP-READING.1.4`
  Status: `done`
  Goal: Read bounded Julia group 4 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.3` committed; empty brief and clean repository.
  Scope: `julia/src/action/ActionContracts.jl` lines 767-1128; `julia/src/action/ActionParser.jl` lines 1-1138
  Baseline evidence: 1500 fragments / 51329 bytes; ordered range SHA-256 `f843c537312ac86af4aa48af1c6b5a1019a10e24c11db64c325fcf6afea3a0e7`.
  Activation commit: `4ad1e3cd2eab98aa324e0e90568952a477e62eba`.
  Verification tier: `focused`
  Focused checks: Exact owned reading and baseline identity; native contract/parser direct-dependent controls through managed Julia; Knowledge, memory, histories, rendered book, source/evidence preservation and normal doctrines.
  Canonical trigger: `none` — ordinary reading evidence; no source, contract, dependency, gate or infrastructure change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: ActionContracts completes structural set/push/set-key/nested-write traversal, eager containers/blocks/control bodies, deferred callable dependencies, fixed/variadic registered-call arity and keyword rejection, callable-binding priority and canonical helper families. Its attached-switch visitor prefers extracted branches over the retained body. ActionParser1-1138 covers typed Unicode diagnostics, statement precedence and bare-next context, the sole map_leaves! receiver grammar, brace/callable fixed-rest classification, literals, typed attached controls, helper/static-recognition calls and the nested-access prefix. Switch branch extraction discards non-branches and replaces earlier defaults. Parser suffix and consumers remain for later children; supporting runtime/Perl diagnostics receive no advance credit.
  Knowledge: Current contract/callable claims reconciled; docs/knowledge/julia-attached-switch-body-omission.md records exact mechanism, outcomes, caveats and self-contained replay.
  Findings: Pending .2.2/.2.2.1/.2.2.2 own switch repair; existing .2.1 selector and startup .27 lifecycle owners remain. Current pointers also correct stale pre-approval capacity wording without altering historical evidence.
  Verification: Both exact owned ranges total 1,500 fragments / 51,329 baseline-identical bytes, digest f843c537312ac86af4aa48af1c6b5a1019a10e24c11db64c325fcf6afea3a0e7. Existing parser 74 / resolver 40 and callable 125 + 118 + 239 assertions pass (596 total). Five asserted AST/resolver/four-carrier outcomes, ten before/after diagnostic cases and five exact shared-source Perl outcomes pass. Emitted Julia loads fresh modules in the same process; compile success is distinguished from resolver diagnostics and Perl lazy handler failure. Toolbox descriptor/source isolates the initial E-only non-execution as existing startup .27, excluded from switch parity. Exact source/coverage, prior task/evidence/history preservation, Knowledge, memory, histories, rendered book and all normal doctrines govern the commit; no source/test change, complete component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.4 - read contracts and own attached switch omission`.

- ID: `JULIA-STARTUP-READING.1.5`
  Status: `done`
  Goal: Read bounded Julia group 5 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.4` committed; empty brief and clean repository.
  Scope: `julia/src/action/ActionParser.jl` lines 1139-2276; `julia/src/action/CallableContract.jl` lines 1-268; `julia/src/action/FunctionRegistry.jl` lines 1-94
  Baseline evidence: 1500 fragments / 51510 bytes; ordered range SHA-256 `f2c058898ca5dacca8b16509e0c906c61ed94924ae42a18ada83cfe5b57b6d63`.
  Activation commit: `21b3855ad02df0440a74fedc7292ba934acac058`.
  Verification tier: `focused`
  Focused checks: Exact owned reading and baseline identity; managed callable-normalization/function-registry direct-dependent tests; Knowledge, memory, histories, rendered book, evidence preservation and normal doctrines.
  Canonical trigger: `none` — ordinary source reading and diagnostic intake; no source, contract, dependency or infrastructure change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: ActionParser1139-2276 completes string-key versus expression-index reads, exclusive progressive and staged assignment nodes with literal identities/options and direct/concatenated capture plans, append/scalar/nested writes with typed root/segment diagnostics, generic receiver attachment, keyword/positional parsing, balanced statement/CSV/token scans, control aliases and Unicode-coordinate string utilities. CallableContract fully defines helper/receiver/user final-block bounds, post-registry promotion into zero-positional contextual state, source-preserving function reconstruction and recursive normalization through retained switch bodies, extracted branches and explicit/contextual callables. FunctionRegistry1-94 defines resolution and ordered registry data, rejects duplicate names, preserves zero-based entries and body-job order, and begins lookup; its suffix remains .1.6.
  Knowledge: Generic-final-codeblock and registry cards reconcile current traversal/arity metadata; staged marker, progressive assignment and nested-write facts match the exact read source.
  Findings: No new confirmed defect or repair closure. Existing .2.1/.2.2 remain open; full-body callable normalization already traverses the sites skipped by their distinct validators.
  Verification: Three exact owned ranges total 1,500 fragments /51,510 baseline-identical bytes, digest f2c058898ca5dacca8b16509e0c906c61ed94924ae42a18ada83cfe5b57b6d63. Existing contextual-final-block 118, registry 23 and variadic 55 assertions pass (196 total). Eight direct-normalizer outcomes reject undeclared attached helpers and preserve valid with blocks at direct, omitted-switch-body, explicit-callable and contextual-body locations; four valid normalizations are idempotent. These diagnostic-only native outcomes grant no additional emitted or repair credit. Exact coverage/source/task/history preservation, Knowledge, memory, bounded histories, rendered book and normal doctrines govern landing; no source/test change, complete component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.5 - read parser and callable normalization`.

- ID: `JULIA-STARTUP-READING.1.6`
  Status: `done`
  Goal: Read bounded Julia group 6 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.5` committed; empty brief and clean repository.
  Scope: `julia/src/action/FunctionRegistry.jl` lines 95-235; `julia/src/cli/LinkedSpecJuliaCli.jl` lines 1-838; `julia/src/compiler/CompiledSpec.jl` lines 1-521
  Baseline evidence: 1500 fragments / 47482 bytes; ordered range SHA-256 `28d2afda026ea2191355ea3ed8b2370f8e836bdb953834a27427696514ebbdda`.
  Activation commit: `a858b781d8befc5cf5ba3af2932e4e9877d6fcf3`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading/baseline reconstruction; managed registry/compiled-state/root/variadic tests and ten-family primary CLI process conformance; Knowledge, memory, histories, rendered book, source/evidence preservation and normal doctrines.
  Canonical trigger: `none` — ordinary source-reading evidence; no runtime, public contract, dependency, gate or infrastructure change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Registry resolution accepts fixed exact or variadic minimum arities and preserves definition metadata while stitching body_ast into a new SpecFile. Descriptor version 1/2/3 follows fixed/signature/parameter-kind shape. The primary CLI separates usage exit 2 from compile/input/invoke exit 1, compiles before deferred input IO, delegates named/file loading, and serializes the direct runtime value with recursive key sorting. run_cli emits independent canonical phase traces; the internal execute helper retains native tracing. CompiledSpec1-521 defines typed rule/edge/slot/gap/payload state, ordered entry selection and errors, selector validation with deferred parse-failure timing, and nested-write carrier traversal; receiver-mutation validation continues in .1.7.
  Knowledge: Reconciled registry, CLI argument/loading, native execution/canonical trace, compiled-state and root-selection facts. Exact focused replay is in docs/knowledge/julia-compiled-spec-state.md. All three supplied policy files retain the hashes recorded in startup .31; their adoption/update review stays .5-owned.
  Findings: No new confirmed defect or repair closure. Existing callable selector .2.1, attached-switch .2.2 and all prior startup/Dart repairs remain pending.
  Verification: Untruncated windows cover all three owned ranges: 1500 fragments /47482 baseline-identical bytes, digest 28d2afda026ea2191355ea3ed8b2370f8e836bdb953834a27427696514ebbdda. Independent 95-path/146-range reconstruction passes; registry23, compiled41, root79 and variadic55 pass (198 assertions plus the selected-set equality assertion). The unchanged ten-family primary CLI process checker passes exact output/status and routed/mirrored trace checks. Supporting test parsing/execution grants no future reading credit. All source bytes and earlier evidence remain; standard continuity/Knowledge/history/book/doctrine checks govern landing. No complete backend/canonical gate or dependency build ran.
  Commit: `JULIA-STARTUP-READING.1.6 - read function registry CLI and compiled state`.

- ID: `JULIA-STARTUP-READING.1.7`
  Status: `done`
  Goal: Read bounded Julia group 7 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.6` committed; empty brief and clean repository.
  Scope: `julia/src/compiler/CompiledSpec.jl` lines 522-1860; `julia/src/corpus/CorpusManifest.jl` lines 1-161
  Baseline evidence: 1500 fragments / 57108 bytes; ordered range SHA-256 `5699c12ffd786ae5a813d86ae2696b2f6d5114967e496777f49b02c002aaa89e`.
  Activation commit: `e2f8edeceeaf5b59d5efa2ccc2ebe93dcb2fcc70`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; existing recognition/observation/mutation/write/manifest suites; native causal and reference diagnostic controls; neutral recognition checker; Knowledge, memory, histories, rendered book and normal doctrines.
  Canonical trigger: `none` — ordinary reading and repair intake; no executable contract, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Compiler validation traverses action payload carriers for nested writes and receiver mutation, normalizes ordered rule/edge/slot state and builds last-definition rule order and dependency regexes. The observation/progressive effect collectors use action expressions and call fixed points; action/blind targets are absent from the former, demonstrated by add/remove-edge causal controls. Generic recognition classification has no production caller in the source census. Descriptors serialize compiled structures; CorpusManifest1-161 defines typed records, result helpers and the CLI parser prefix.
  Knowledge: New recognition-effect integration card records exact native, causal, neutral and Perl-reference replay. Corpus cards distinguish historical 99-case admission from current 105-fixture validation. Existing Perl lifecycle card extends the same no-edge E-only mode matrix.
  Findings: Confirmed recognition binding-write persistence and structural observation-edge omission are owned by .2.3.1-.2.3.3; no repair is claimed. Perl ordinary E-only omission reuses startup .27.1-.27.3. Diagnostic extraction initially required correcting whitespace matching; final 11-assertion reference replay passes.
  Verification: Two untruncated owned ranges total 1500 fragments /57108 baseline-identical bytes, digest 5699c12ffd786ae5a813d86ae2696b2f6d5114967e496777f49b02c002aaa89e. Recognition207, observation30, mutation496, write406 and manifest20 pass (1159 plus selected-set equality1); native17 plus causal8 and reference11 diagnostics pass. Neutral checker remains138 nodes/250calls/58mutations. Independent full coverage replay, prior source/task/history preservation and focused continuity/book/doctrine checks govern landing. No future reading credit, full Julia/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.7 - read compiler and own recognition effect repair`.

- ID: `JULIA-STARTUP-READING.1.8`
  Status: `done`
  Goal: Read bounded Julia group 8 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.7` committed; empty brief and clean repository.
  Scope: `julia/src/corpus/CorpusManifest.jl` lines 162-626; `julia/src/io/SpecLoader.jl` lines 1-387; `julia/src/mcp/McpContract.jl` lines 1-372
  Baseline evidence: 1224 fragments / 65496 bytes; ordered range SHA-256 `80857a09d16e202d83c90ff1a21e51c5bdf6b61782a137ad946c3cdcad39c136`.
  Activation commit: `3a4073ab3d458e51ce3596daf8198441e765abdd`.
  Verification tier: `focused`
  Focused checks: Exact physical source/range replay; existing controlled-corpus, loader, MCP binding and removed-option suites; check-only MCP generator and neutral resolution; Knowledge, memory, histories, rendered book, preservation and normal doctrines.
  Canonical trigger: `none` — ordinary source-reading and factual reconciliation; no executable, contract, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Corpus execution validates the complete manifest before selecting named or bounded ordered fixtures, compares wrapped output and retains detached values, cursor, trace and diagnostics across per-fixture failures; CLI exits distinguish execution failures from validation/usage. SpecLoader validates portable names/exact paths, de-duplicates ordered candidates, selects the first regular file and preserves UTF-8/BOM bytes before attributed parse/validate/compile stages; absolute requests use basename source identity. McpContract prefix contains generated format/digest/Base64 frame/schema data, with consumers and remaining literals still unread.
  Knowledge: Reconcile controlled-corpus signature with the removed global cursor contract, use managed example commands, qualify historical99 counts and generated119538-byte evidence, and preserve named-loader authority. Exact combined replay is in docs/knowledge/julia-controlled-corpus-execution.md; current generated binding is120030 bytes.
  Findings: No new confirmed runtime defect or repair closure. Existing selector/switch/recognition and all prior backend/startup repairs remain pending.
  Verification: Three untruncated owned ranges total1224 fragments /65496 baseline-identical bytes, digest80857a09d16e202d83c90ff1a21e51c5bdf6b61782a137ad946c3cdcad39c136. Controlled corpus58, loader34+24+10+6+8, MCP53 and removed-option53 pass (246 plus selected-set equality1). Check-only generator is byte-fresh120030; neutral resolution14/9/4 passes. Exact coverage/source/task/history preservation and focused continuity/book/doctrine checks govern landing; no future reading credit, full Julia/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.8 - read corpus loader and MCP binding prefix`.

- ID: `JULIA-STARTUP-READING.1.9`
  Status: `done`
  Goal: Read bounded Julia group 9 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.8` committed; empty brief and clean repository.
  Scope: `julia/src/mcp/McpContract.jl` lines 373-1002
  Baseline evidence: 630 fragments / 65520 bytes; ordered range SHA-256 `3f731f7393feeb143ccc65d4a2407e10e0d5cb9cb8f102834a0761b27479ec84`.
  Activation commit: `1fa6cab75558de3339e17ecd799b51f0ced5b468`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; check-only generator and independent bundle digest decoding; existing Julia MCP binding suite and neutral transport checker; Knowledge, memory, histories, rendered book, preservation and normal doctrines.
  Canonical trigger: `none` — ordinary generated-data reading; no contract, runtime, generator, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Owned Base64 literals continue tool input/output schemas, canonical errors, neutral artifact identities and authority limits, deployment/handle policies, lifecycle/raw-input fixtures and schema definitions. The generator encodes canonical UTF-8 JSON in 96-character literals; the binding is data, while decoded consumers remain separately owned. The neutral authority constrains four methods, two tools, opaque host registration, lower-only policy, strict frame limits and canonical response text.
  Knowledge: Reconcile the generated-data boundary with docs/knowledge/julia-mcp-decoded-server.md, including an independent digest/shape replay. All generated bytes remain baseline-identical; no hand edit or runtime-read behavior is introduced.
  Findings: No new confirmed defect or repair closure. Previous Julia and startup findings retain their existing owners and prerequisites.
  Verification: Three untruncated physical windows cover all 630 fragments /65520 bytes, digest 3f731f7393feeb143ccc65d4a2407e10e0d5cb9cb8f102834a0761b27479ec84. Generator compares120030 bytes; independent decoding matches82882 bytes and SHA a1d2857c57ef93ea0e62403977105fdf6380f6fcb4d7a89ed5749c1bfdd64001. Existing binding53 and neutral35 frames/10raw/10lifecycle/76mutations pass. Full source/range/task/history preservation and focused continuity/book/doctrine checks govern landing. No credit for unread suffix/consumers, full backend/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.9 - read generated MCP contract data`.

- ID: `JULIA-STARTUP-READING.1.10`
  Status: `done`
  Goal: Read bounded Julia group 10 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.9` committed; empty brief and clean repository.
  Scope: `julia/src/mcp/McpContract.jl` lines 1003-1159; `julia/src/mcp/McpContractRuntime.jl` lines 1-462; `julia/src/mcp/McpServer.jl` lines 1-826; `julia/src/mcp/McpWire.jl` lines 1-55
  Baseline evidence: 1500 fragments / 65039 bytes; ordered range SHA-256 `7d5bde5484ffd4f8d8785281363543a87af6ec9580aa0797c2f429dbe69edd48`.
  Activation commit: `9431f6c8aeac4b95933c3683b5fa77bf5054acb0`.
  Verification tier: `focused`
  Focused checks: Exact bounded reading and baseline reconstruction; existing MCP binding/dispatch/stdio suites, native/neutral pattern and decoded/wire precedence probes, check-only generator and neutral transport; Knowledge, memory, histories, rendered book, evidence preservation and normal doctrines.
  Canonical trigger: `none` — ordinary source reading and repair intake; no executable, frozen contract, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Generated data finishes the neutral payload and source digests. ContractRuntime verifies the embedded bundle, clones JSON with depth/cycle/key guards, validates the frozen schema subset, sorts canonical object keys and emits sanitized cloned responses. Server registration uses random opaque handles, copied auth digests, bounded monotonic lifetime/capacity and lower-only native budgets; dispatch orders envelope/method/version/schema/lookup/native execution and tracks preparation/cancellation/shutdown. Dollar-anchored occursin admits one final LF in handle/digest schema patterns while host handle validation rejects its length. Wire1-55 defines frame constants, tokens and containers; its scanner remains .1.11.
  Knowledge: New julia-mcp-pattern-terminal-newline-gap card contains exact native/neutral replay; existing perl-mcp-validation-error-order-drift card gains Julia public decoded/stdio evidence. Current MCP runtime understanding and finite suite counts reconcile with decoded-server Knowledge.
  Findings: Julia .2.4.1/.2.4.2 own complete-pattern repair and public recurrence; startup .36.1 retains the existing shared precedence owner. No repair is closed. Current metadata and secondary roadmap pointers are reconciled with exact reading totals; historical records remain intact.
  Verification: Four untruncated owned ranges total1500 fragments /65039 baseline-identical bytes, digest7d5bde5484ffd4f8d8785281363543a87af6ec9580aa0797c2f429dbe69edd48. Existing binding53/dispatch145/stdio170 pass (368); native pattern20 and order12 assertions compare complete decoded/stdio responses, and eight neutral outcomes reject every nonempty suffix. Generator remains120030 bytes and neutral transport35/10/10/76 passes. Exact coverage/source/task/history preservation, focused continuity/book and normal doctrines govern landing. No unread-source credit, complete Julia/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.10 - read MCP runtime and own pattern validation repair`.

- ID: `JULIA-STARTUP-READING.1.11`
  Status: `done`
  Goal: Read bounded Julia group 11 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.10` committed; empty brief and clean repository.
  Scope: `julia/src/mcp/McpWire.jl` lines 56-672; `julia/src/parser/StagedParserRegistry.jl` lines 1-652; `julia/src/parser/UserFunctionDefinitionParser.jl` lines 1-231
  Baseline evidence: 1500 fragments / 52503 bytes; ordered range SHA-256 `9b0a9a06f22ffcbadc1d8f64cae7112375a32605cf4b9df3c38c6b9a1add0ed5`.
  Activation commit: `88fce698f07b6a77955c22f33e8cc38677f5c341`.
  Verification tier: `focused`
  Focused checks: Exact owned physical reading and baseline reconstruction; existing staged registry/descriptor/trace/function-shell, MCP stdio and variadic suites; neutral staged/public and MCP governance; Knowledge, memory, histories, rendered book, preservation and normal doctrines.
  Canonical trigger: `none` — ordinary reading and factual reconciliation; no executable, contract, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: McpWire completes iterative container/token scanning, decoded duplicate-key and Unicode checks, exact integer versus fraction/exponent reconstruction, strict safe-id validation, bounded chunk framing/drain/recovery, final EOF handling, pre-emission cancellation and sanitized IO release. StagedParserRegistry normalizes and lexically sorts legacy string paths, runs fixed built-in resolve/load/compile/execute phases, records cache identity without retaining a plan cache, validates fixed/variadic/final-codeblock metadata and immutably stitches body_ast. UserFunctionDefinitionParser1-231 compiles and executes the checked-in definition spec with attributed trace/error phases, routes neutral projection/stitching and begins ancestor file search behind a locked default-parser cache; final helper suffix remains .1.12.
  Knowledge: Reconcile narrow v1 staged registry with already admitted general v2; update current stdio and function-shell evidence while retaining dated admission counts. Exact focused replay is in docs/knowledge/julia-staged-function-body-registry.md.
  Findings: No new confirmed defect or repair closure. Initial focused harness omitted CORPUS_ROOT; affected trace and function-parser groups pass after supplying the existing constant. Source and all prior repairs remain unchanged.
  Verification: Three untruncated owned ranges total1500 fragments /52503 baseline-identical bytes, digest9b0a9a06f22ffcbadc1d8f64cae7112375a32605cf4b9df3c38c6b9a1add0ed5. Registry39, descriptor28, corrected trace28/function-parser7, stdio170 and variadic55 pass (327 total plus selected-set equality1). Neutral staged123/public129 and MCP35/10/10/76 pass. Full coverage/source/task/history preservation and focused continuity/book/doctrine checks govern landing; no future reading credit, full backend/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.11 - read wire and staged function parser paths`.

- ID: `JULIA-STARTUP-READING.1.12`
  Status: `done`
  Goal: Read bounded Julia group 12 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.11` committed; empty brief and clean repository.
  Scope: `julia/src/parser/UserFunctionDefinitionParser.jl` lines 232-249; `julia/src/runtime/BoundedChildParseAuthority.jl` lines 1-1367; `julia/src/runtime/Interpreter.jl` lines 1-115
  Baseline evidence: 1500 fragments / 45686 bytes; ordered range SHA-256 `36214acfe302f4b357bf9eb244fdbd0c49c1fa3cb930def44c6d7386505c5d43`.
  Activation commit: `f9d5b78553cb3e9b5441ede8e0cf2bdec89fc033`.
  Verification tier: `focused`
  Focused checks: Exact bounded source/range reconstruction; existing progressive authority and admitted carrier suites, native nested/direct/pattern probes and independent neutral pattern comparison; progressive/public governance; Knowledge, memory, histories, rendered book, preservation and normal doctrines.
  Canonical trigger: `none` — ordinary reading and repair intake; no executable, contract, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Function-parser suffix terminates ancestor search and checks whitespace-only unmatched remainder. BoundedChildParseAuthority defines immutable logical registry entries, copied source snapshots, execution seeds and invocation-local state, typed same-source views/rebasing/expiry, cancellation identity and absolute deadline, shared calls/depth/steps and strictly decreasing repeated spans. It intersects fresh caller grants with entry ceilings and detaches bounded results; nested arguments bypass inherited effective grants and local remaining steps. Three dollar-anchored identity patterns accept final LF. Interpreter1-115 introduces RuntimeDiagnostic fields and begins its normalization constructor; all execution bodies remain unread.
  Knowledge: New julia-progressive-authority-boundary-gaps card stores complete64-assertion native and12-outcome neutral replay. Existing progressive authority and function-shell facts reconcile exact current source and limitations.
  Findings: Startup .37.1/.37.2 retain nested inheritance and source-detail review; new .2.5.1/.2.5.2 own progressive identity/top/fingerprint matching. Direct cost/result/diagnostic caps work in tested controls. Julia showerror quotes a thrown string; the first diagnostic-prefix expectation was corrected from the Dart spelling after inspecting actual output. No repair or authored/emitted gap reproduction is claimed.
  Verification: Three untruncated ranges total1500 fragments /45686 baseline-identical bytes, digest36214acfe302f4b357bf9eb244fdbd0c49c1fa3cb930def44c6d7386505c5d43. Existing dormant authority210 and admitted carrier62 pass; native nested30/direct14/pattern20 assertions and neutral pattern12 outcomes pass. Neutral progressive116/public60 remains green. Full coverage/source/task/history preservation and focused continuity/book/doctrine checks govern landing; no future reading credit, complete Julia/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.12 - read child authority and own boundary repairs`.

- ID: `JULIA-STARTUP-READING.1.13`
  Status: `done`
  Goal: Read bounded Julia group 13 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.12` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 116-1615
  Baseline evidence: 1500 fragments / 46530 bytes; ordered range SHA-256 `16a40fcfac63e5a0917aeb1e75e49a62f54cb5b4fcfa2c89d9081c297b0eb344`.
  Activation commit: `ba485700ca257c8d0480eac47c602e39a36bc25b`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; existing diagnostics, typed source, recognition, observation, gap and removed-option suites; neutral typed/recognition checks; governed rollover source/blob/hash/full-query preservation; Knowledge, memory, histories, rendered book and normal doctrines.
  Canonical trigger: `none` — ordinary reading and existing governed history rollover; no source, contract, registry limit, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Interpreter116-1615 completes diagnostic construction and defines portable slot-identity errors, event/result records and engine validation of removed options, private seeds, regex slots and serialized mutation state. Every context starts fresh source/recognition authorities, stores, identity maps, frame stacks, caches and sinks. Recognition adapters snapshot cursor/boundary/marks, preserve primary unwind failures and isolated mark buckets; observation and gap adapters retain invocation/entry-slot identity and typed detached records. Compatibility projections convert codeunits/scalars through SourceLocation and return absence for its typed failures. Trace wrappers, flow records and initial leading-trivia cursor complete the range; execution methods remain later reading.
  Knowledge: Structured runtime diagnostics now carries focused replay and exact state/projection boundaries. Recognition integration/observation and pre-typed alias cards explicitly qualify historical counts and the known effect-integration gap.
  Findings: No new confirmed runtime defect or repair closure. Existing .2.3 and all other repairs remain. The normal notes rollover consumes one already-approved archive slot without changing limits or immutable prior bytes.
  Verification: Six untruncated windows cover1500 fragments /46530 baseline-identical bytes, digest16a40fcfac63e5a0917aeb1e75e49a62f54cb5b4fcfa2c89d9081c297b0eb344. Diagnostics7, typed127, recognition207, observation30, gap105+33+46+105+30 and options53 pass (743 plus selected-set equality1). Neutral typed14/0/231 and recognition138/250/58 pass. Notes segment4979 preserves clean source247-459, blob0a3d47254f94d368bf67186f98ca837e1246b8dc,213 lines/12898 bytes/SHA63966e071583c27d1bd80cfbad47b49f0aa5c535bfb70aa27af8cb2b2f760046. Exact root-plus-record and full archive-query reconstruction pass, restoring the one separator LF removed only from the hot root for whitespace hygiene; current root252 lines/15589 bytes, manifest28 lines/16842 bytes, collection29 files. Full coverage/source/prior-task/history preservation and focused continuity/book/doctrine checks govern landing; no unread-source credit, full backend/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.13 - read runtime state and source projections`.

- ID: `JULIA-STARTUP-READING.1.14`
  Status: `done`
  Goal: Read bounded Julia group 14 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.13` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 1616-3115
  Baseline evidence: 1500 fragments / 49525 bytes; ordered range SHA-256 `0914279799290aee44fe36a02242403bdd98e702c3a897550583ad732459d8bf`.
  Activation commit: `ef676281fa8841dedcfaf5f3951d009d4088a95a`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; existing rule/control/source-emitter/semantic-capture suites; public native/generated-plan callback diagnostic; neutral semantic checker; source/prior-task/history preservation, Knowledge, memory, rendered book and normal doctrines.
  Canonical trigger: `none` — ordinary reading and confirmed-defect intake; no source, contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: runtime_parse selects the root, creates invocation-local authority, handles leading trivia, executes the parent, enriches copied output and emits a final semantic event after result construction. Rule execution validates family identity, guards identical recursion entries and restores bindings, marks, recognition frames and registers while retaining the primary failure. Blind/regex loops distinguish match, failure, next, minimum/maximum and zero progress; regex selection records ordered identity before effects, while child action dispatch is memoized. Lifecycle I predeclares direct local bindings. Semantic sinks return early when absent and mark thrown caller objects, but the action-block catch translates those objects on nested child calls. Control dispatch is read through attached-switch selector setup only; its suffix remains .1.15.
  Knowledge: Semantic capture and generated-route cards now qualify their historical broad passthrough claims. docs/knowledge/julia-semantic-observer-action-failure-wrapping.md owns causal source locations, exact 24-route replay, return-type distinction and focused suite commands.
  Findings: Confirmed .2.6/.2.6.1/.2.6.2 own original semantic callback error propagation and supported-route proof. Native/traced parse wraps the Child slot sentinel in RuntimeInterpreterException; plan/traced-plan wraps it again in GeneratedSourceException. Direct, blind-child and final-result controls preserve identity. Actual enabled trace closure, original backtrace and fresh emitted defect reproduction remain unmeasured; Dart .2.8 remains separate.
  Verification: Six untruncated windows cover1500 fragments /49525 baseline-identical bytes, digest0914279799290aee44fe36a02242403bdd98e702c3a897550583ad732459d8bf. Existing rule39/control6/emitter13+32+20/capture66 pass (176 plus selected-set equality1). Corrected diagnostic passes108 assertions across24 cases/routes; an earlier value-only generated-return assumption caused four harness field errors, corrected without source changes. Neutral semantic6/20/128, rollout9/0 and admission6/0 pass. Exact source/coverage/prior-node/history preservation, Knowledge, memory, bounded histories, rendered book and normal doctrines govern landing; no unread-source credit, full backend/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.14 - read rule execution and own observer passthrough repair`.

- ID: `JULIA-STARTUP-READING.1.15`
  Status: `pending`
  Goal: Read bounded Julia group 15 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.14` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 3116-4615
  Baseline evidence: 1500 fragments / 50914 bytes; ordered range SHA-256 `a5b0d3b0bdd6afbedc84dd3d6fea762fe6f1c49d572a1a10cc1ed412ef37584c`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.16`
  Status: `pending`
  Goal: Read bounded Julia group 16 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.15` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 4616-6115
  Baseline evidence: 1500 fragments / 47167 bytes; ordered range SHA-256 `7d4512f98e5f1be18f67db7b2c2c70d445da22d7cc6edafe6d8bcffe2804b463`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.17`
  Status: `pending`
  Goal: Read bounded Julia group 17 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.16` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 6116-7615
  Baseline evidence: 1500 fragments / 47705 bytes; ordered range SHA-256 `39ff025eeb973cba92aae38f19201eb5256ab85bfc4f047d247f80cd7225d145`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.18`
  Status: `pending`
  Goal: Read bounded Julia group 18 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.17` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 7616-9115
  Baseline evidence: 1500 fragments / 47712 bytes; ordered range SHA-256 `bf09ad52290a43634f12195618892db9d2b9a9cd5a0abb09909edcabcb52468c`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.19`
  Status: `pending`
  Goal: Read bounded Julia group 19 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.18` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 9116-9285; `julia/src/runtime/Matching.jl` lines 1-509; `julia/src/runtime/RecognitionTransaction.jl` lines 1-821
  Baseline evidence: 1500 fragments / 46811 bytes; ordered range SHA-256 `197da31645415eaf6d9ea4669e3f53191264bb96a47e0921e29b738e108df89f`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.20`
  Status: `pending`
  Goal: Read bounded Julia group 20 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.19` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/RecognitionTransaction.jl` lines 822-1057; `julia/src/runtime/SemanticObservation.jl` lines 1-130; `julia/src/runtime/SourceLocation.jl` lines 1-646; `julia/src/runtime/StagedAstEnrichment.jl` lines 1-488
  Baseline evidence: 1500 fragments / 47696 bytes; ordered range SHA-256 `9dd223e7e32caf41690ace346aec1fa457dc7c035234cb3706d00c5d705a9cbd`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.21`
  Status: `pending`
  Goal: Read bounded Julia group 21 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.20` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/StagedAstEnrichment.jl` lines 489-1988
  Baseline evidence: 1500 fragments / 56058 bytes; ordered range SHA-256 `38226654b3d608086ed3fc0bf96e8be319b6a987bb00fb43b4ec19cd1953652f`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.22`
  Status: `pending`
  Goal: Read bounded Julia group 22 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.21` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/StagedAstEnrichment.jl` lines 1989-2809; `julia/src/runtime/StagedParseJobDeclaration.jl` lines 1-336; `julia/src/runtime/UnicodeCaseMapping.jl` lines 1-343
  Baseline evidence: 1500 fragments / 49643 bytes; ordered range SHA-256 `6f963767f97a9b4d7cee21a930aec096d59bac417b13233e0408f4a500d30e24`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.23`
  Status: `pending`
  Goal: Read bounded Julia group 23 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.22` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/UnicodeCaseMapping.jl` lines 344-1843
  Baseline evidence: 1500 fragments / 41147 bytes; ordered range SHA-256 `55d267826995d7ed9d00f3f55134f736b2dea43728218010b78f1233243efc6c`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.24`
  Status: `pending`
  Goal: Read bounded Julia group 24 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.23` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/UnicodeCaseMapping.jl` lines 1844-3343
  Baseline evidence: 1500 fragments / 41154 bytes; ordered range SHA-256 `e6e87e524024ec1138f9106dd805130466492085d4d0e2f60b5648ea3a54b8a9`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.25`
  Status: `pending`
  Goal: Read bounded Julia group 25 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.24` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/UnicodeCaseMapping.jl` lines 3344-3832; `julia/src/semantic/SemanticCallProjection.jl` lines 1-1011
  Baseline evidence: 1500 fragments / 45333 bytes; ordered range SHA-256 `0d67f1cb35591030060caa6c2045c790da7b5cb4ff4e55c5936109a2dfceb2cb`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.26`
  Status: `pending`
  Goal: Read bounded Julia group 26 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.25` committed; empty brief and clean repository.
  Scope: `julia/src/semantic/SemanticCallProjection.jl` lines 1012-1526; `julia/src/semantic/SemanticCompilationOutcome.jl` lines 1-472; `julia/src/semantic/SemanticIndex.jl` lines 1-513
  Baseline evidence: 1500 fragments / 51253 bytes; ordered range SHA-256 `f4210c34957b9291c52d017b260b35554056bfa7b40879e45602ce1ac9efe38b`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.27`
  Status: `pending`
  Goal: Read bounded Julia group 27 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.26` committed; empty brief and clean repository.
  Scope: `julia/src/semantic/SemanticIndex.jl` lines 514-643; `julia/src/semantic/SemanticQuery.jl` lines 1-1370
  Baseline evidence: 1500 fragments / 52508 bytes; ordered range SHA-256 `7abb92b1c4c10d789dbe91f5a489f0c54e5d1e8e318a69e19c1ba7ae1fe8de15`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.28`
  Status: `pending`
  Goal: Read bounded Julia group 28 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.27` committed; empty brief and clean repository.
  Scope: `julia/src/semantic/SemanticQuery.jl` lines 1371-1587; `julia/src/semantic/SemanticRuntimeProjection.jl` lines 1-329; `julia/src/semantic/SemanticStaticProjection.jl` lines 1-954
  Baseline evidence: 1500 fragments / 51153 bytes; ordered range SHA-256 `d7d30edd5c05d59c1a8fe97eea8ec1067d24077c0cbcb85d4af6d19a8eb870c6`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.29`
  Status: `pending`
  Goal: Read bounded Julia group 29 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.28` committed; empty brief and clean repository.
  Scope: `julia/src/semantic/SemanticStaticProjection.jl` lines 955-1505; `julia/src/source/SourceEmitter.jl` lines 1-848; `julia/src/spec/Ast.jl` lines 1-101
  Baseline evidence: 1500 fragments / 50139 bytes; ordered range SHA-256 `4f5a83ded7635541cdcf772c884177b09886590a6743fbd52477d8107384d987`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.30`
  Status: `pending`
  Goal: Read bounded Julia group 30 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.29` committed; empty brief and clean repository.
  Scope: `julia/src/spec/Ast.jl` lines 102-909; `julia/src/spec/Parser.jl` lines 1-692
  Baseline evidence: 1500 fragments / 47322 bytes; ordered range SHA-256 `49eee5f7067937c59a9c17fc925dda6def91e39bdf0183c5c0fb7fd00821dfac`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.31`
  Status: `pending`
  Goal: Read bounded Julia group 31 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.30` committed; empty brief and clean repository.
  Scope: `julia/src/spec/Parser.jl` lines 693-1370; `julia/src/spec/UnicodeRuleLabel.jl` lines 1-822
  Baseline evidence: 1500 fragments / 40694 bytes; ordered range SHA-256 `778dbe14584f490c8ce5a2dc306f0dcafb4390a8d05bd1443280abfc4704cc61`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.32`
  Status: `pending`
  Goal: Read bounded Julia group 32 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.31` committed; empty brief and clean repository.
  Scope: `julia/src/spec/UnicodeRuleLabel.jl` lines 823-872; `julia/src/spec/UserFunctionDefinitionShell.jl` lines 1-810; `julia/src/spec/Validator.jl` lines 1-640
  Baseline evidence: 1500 fragments / 54143 bytes; ordered range SHA-256 `8141dca93ba8508087a5aeb72fa2fca3bafbc3147f5fe7448cc7be322259e3b1`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.33`
  Status: `pending`
  Goal: Read bounded Julia group 33 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.32` committed; empty brief and clean repository.
  Scope: `julia/src/spec/Validator.jl` lines 641-1047; `julia/src/trace/Trace.jl` lines 1-424; `julia/test/callable_codeblock_literal_contract_test.jl` lines 1-669
  Baseline evidence: 1500 fragments / 53501 bytes; ordered range SHA-256 `19f76b05c49c993c31531d46010cf38756152123d3bd01e06b93bde50471b8af`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.34`
  Status: `pending`
  Goal: Read bounded Julia group 34 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.33` committed; empty brief and clean repository.
  Scope: `julia/test/callable_codeblock_literal_contract_test.jl` lines 670-1012; `julia/test/complete_named_mark_contract_test.jl` lines 1-94; `julia/test/diagnostic_output_contract_test.jl` lines 1-310; `julia/test/duplicate_regex_slot_identity_contract_test.jl` lines 1-434; `julia/test/inter_match_gap_capture_contract_test.jl` lines 1-319
  Baseline evidence: 1500 fragments / 55896 bytes; ordered range SHA-256 `8e34677c9b2e371c510b70845f6215389eab67c0bdbf9aa5cf86ccd3fcc9be04`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.35`
  Status: `pending`
  Goal: Read bounded Julia group 35 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.34` committed; empty brief and clean repository.
  Scope: `julia/test/inter_match_gap_capture_contract_test.jl` lines 320-1623; `julia/test/logical_helper_contract_test.jl` lines 1-196
  Baseline evidence: 1500 fragments / 48303 bytes; ordered range SHA-256 `607ea66a1461b2b143e4b7715c52a12da5ed7ad85949c26f61b0c34e37e7f080`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.36`
  Status: `pending`
  Goal: Read bounded Julia group 36 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.35` committed; empty brief and clean repository.
  Scope: `julia/test/logical_helper_contract_test.jl` lines 197-387; `julia/test/map_leaves_mutation_contract_test.jl` lines 1-905; `julia/test/mcp_contract_julia_binding_test.jl` lines 1-100; `julia/test/mcp_server_julia_admission_test.jl` lines 1-304
  Baseline evidence: 1500 fragments / 56141 bytes; ordered range SHA-256 `bfa4c4f3f08c79eea5116e2868c09196594d5a49493ca465ec9150549e6ee8ce`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.37`
  Status: `pending`
  Goal: Read bounded Julia group 37 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.36` committed; empty brief and clean repository.
  Scope: `julia/test/mcp_server_julia_admission_test.jl` lines 305-930; `julia/test/mcp_server_julia_dispatch_test.jl` lines 1-645; `julia/test/mcp_server_julia_stdio_test.jl` lines 1-229
  Baseline evidence: 1500 fragments / 54668 bytes; ordered range SHA-256 `772640d8801fe9ded328f607342886dd284383527fdf5f0397904265f706defb`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.38`
  Status: `pending`
  Goal: Read bounded Julia group 38 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.37` committed; empty brief and clean repository.
  Scope: `julia/test/mcp_server_julia_stdio_test.jl` lines 230-656; `julia/test/progressive_span_dispatch_contract_test.jl` lines 1-437; `julia/test/punctuation_light_zero_arg_contract_test.jl` lines 1-167; `julia/test/recognition_transaction_contract_test.jl` lines 1-469
  Baseline evidence: 1500 fragments / 57682 bytes; ordered range SHA-256 `afac43325ace4e0249c3a282589951a82f6ad188d8a17ade2ee865d12972bcd8`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.39`
  Status: `pending`
  Goal: Read bounded Julia group 39 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.38` committed; empty brief and clean repository.
  Scope: `julia/test/recognition_transaction_contract_test.jl` lines 470-800; `julia/test/recursive_observation_contract_test.jl` lines 1-381; `julia/test/repeated_action_result_contract_test.jl` lines 1-444; `julia/test/root_rule_selection_admission_test.jl` lines 1-344
  Baseline evidence: 1500 fragments / 53180 bytes; ordered range SHA-256 `fec8c6dd25fb28a6c949e576eec0371f02fba65596c9026f5040737a6808fa30`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.40`
  Status: `pending`
  Goal: Read bounded Julia group 40 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.39` committed; empty brief and clean repository.
  Scope: `julia/test/root_rule_selection_admission_test.jl` lines 345-513; `julia/test/root_rule_selection_core_test.jl` lines 1-217; `julia/test/root_rule_selection_routes_test.jl` lines 1-351; `julia/test/rule_local_cursor_contract_test.jl` lines 1-422; `julia/test/rule_local_cursor_descriptor_test.jl` lines 1-232; `julia/test/rule_local_cursor_execution_test.jl` lines 1-109
  Baseline evidence: 1500 fragments / 52652 bytes; ordered range SHA-256 `d36bb12c8c3293220c7cba6454377e5280e9acd23e10ed50a382ec661e2b67cb`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.41`
  Status: `pending`
  Goal: Read bounded Julia group 41 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.40` committed; empty brief and clean repository.
  Scope: `julia/test/rule_local_cursor_execution_test.jl` lines 110-288; `julia/test/rule_local_cursor_normalization_test.jl` lines 1-198; `julia/test/rule_local_cursor_option_removal_test.jl` lines 1-159; `julia/test/runtests.jl` lines 1-964
  Baseline evidence: 1500 fragments / 52739 bytes; ordered range SHA-256 `34807cdd7369669c856af84f11fcbfb01556a57b857e7dd2fec82541c1126e01`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.42`
  Status: `pending`
  Goal: Read bounded Julia group 42 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.41` committed; empty brief and clean repository.
  Scope: `julia/test/runtests.jl` lines 965-2464
  Baseline evidence: 1500 fragments / 52753 bytes; ordered range SHA-256 `d79c2761894f3f3b212f8a4f4abb45f297e44ca874be01c7dfe17a4581e7b1b2`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.43`
  Status: `pending`
  Goal: Read bounded Julia group 43 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.42` committed; empty brief and clean repository.
  Scope: `julia/test/runtests.jl` lines 2465-3964
  Baseline evidence: 1500 fragments / 47116 bytes; ordered range SHA-256 `f987be2affddfc40bdb60cc7a24933a5a27df50fde762399533046441c41903d`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.44`
  Status: `pending`
  Goal: Read bounded Julia group 44 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.43` committed; empty brief and clean repository.
  Scope: `julia/test/runtests.jl` lines 3965-5014; `julia/test/semantic_index_call_core_test.jl` lines 1-408; `julia/test/semantic_index_call_staged_test.jl` lines 1-42
  Baseline evidence: 1500 fragments / 56276 bytes; ordered range SHA-256 `7b47b4f02251fe40d23d847a2eabb47ae6de844ac0f3ba3979aa55b132fcf209`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.45`
  Status: `pending`
  Goal: Read bounded Julia group 45 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.44` committed; empty brief and clean repository.
  Scope: `julia/test/semantic_index_call_staged_test.jl` lines 43-311; `julia/test/semantic_index_compilation_foundation_test.jl` lines 1-329; `julia/test/semantic_index_query_kernel_test.jl` lines 1-264; `julia/test/semantic_index_query_public_test.jl` lines 1-293; `julia/test/semantic_index_query_traversal_test.jl` lines 1-196; `julia/test/semantic_index_runtime_observation_routes_test.jl` lines 1-149
  Baseline evidence: 1500 fragments / 59750 bytes; ordered range SHA-256 `eddbaaf9a7df865c269b3d8f30cafa8c4e50cf03ef4e0a4da7eccdfea7c02588`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.46`
  Status: `pending`
  Goal: Read bounded Julia group 46 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.45` committed; empty brief and clean repository.
  Scope: `julia/test/semantic_index_runtime_observation_routes_test.jl` lines 150-489; `julia/test/semantic_index_runtime_observation_test.jl` lines 1-419; `julia/test/semantic_index_runtime_projection_test.jl` lines 1-356; `julia/test/semantic_index_source_foundation_test.jl` lines 1-276; `julia/test/semantic_index_static_graph_test.jl` lines 1-109
  Baseline evidence: 1500 fragments / 55751 bytes; ordered range SHA-256 `b2596c830b8fb70487cc84a152f0eae9f76231e65eb8c3c50913b3a90446ead5`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.47`
  Status: `pending`
  Goal: Read bounded Julia group 47 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.46` committed; empty brief and clean repository.
  Scope: `julia/test/semantic_index_static_graph_test.jl` lines 110-239; `julia/test/semantic_index_static_remaining_test.jl` lines 1-327; `julia/test/semantic_introspection_julia_admission_test.jl` lines 1-689; `julia/test/source_boundary_compatibility_aliases_test.jl` lines 1-289; `julia/test/source_emitter_test.jl` lines 1-65
  Baseline evidence: 1500 fragments / 56328 bytes; ordered range SHA-256 `c57322277e4b0d44f2c613ee1dc3f75dfccae9985a505bfed82556e25366a9c9`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.48`
  Status: `pending`
  Goal: Read bounded Julia group 48 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.47` committed; empty brief and clean repository.
  Scope: `julia/test/source_emitter_test.jl` lines 66-594; `julia/test/spec_loader_test.jl` lines 1-172; `julia/test/staged_ast_enrichment_contract_test.jl` lines 1-799
  Baseline evidence: 1500 fragments / 55261 bytes; ordered range SHA-256 `b4a720ab1e7e8c8f73e6a1d8df05b7a51e6cba6a31b02dca402fab037749b602`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.49`
  Status: `pending`
  Goal: Read bounded Julia group 49 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.48` committed; empty brief and clean repository.
  Scope: `julia/test/staged_ast_enrichment_contract_test.jl` lines 800-2299
  Baseline evidence: 1500 fragments / 62034 bytes; ordered range SHA-256 `392dad07b63af70a34619bae3739bda164187fd9ee28bf749e065de702af0a4c`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.50`
  Status: `pending`
  Goal: Read bounded Julia group 50 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.49` committed; empty brief and clean repository.
  Scope: `julia/test/staged_ast_enrichment_contract_test.jl` lines 2300-2568; `julia/test/standalone_lifecycle_block_contract_test.jl` lines 1-155; `julia/test/typed_source_location_contract_test.jl` lines 1-449; `julia/test/unicode_rule_label_classifier_test.jl` lines 1-62; `julia/test/unicode_rule_label_identity_routes_test.jl` lines 1-347; `julia/test/unicode_rule_label_negative_isolation_test.jl` lines 1-218
  Baseline evidence: 1500 fragments / 54647 bytes; ordered range SHA-256 `b7206b21f4f0cb2923ecb0a75f76189431cf6bfea386809d800c7c51a1fc21f5`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.51`
  Status: `pending`
  Goal: Read bounded Julia group 51 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.50` committed; empty brief and clean repository.
  Scope: `julia/test/unicode_rule_label_negative_isolation_test.jl` lines 219-456; `julia/test/unicode_rule_label_routes_test.jl` lines 1-163; `julia/test/uniform_binding_contract_test.jl` lines 1-465; `julia/test/variadic_user_function_contract_test.jl` lines 1-181; `julia/test/write_vivification_contract_test.jl` lines 1-453
  Baseline evidence: 1500 fragments / 55360 bytes; ordered range SHA-256 `d1dc28e662a03774d9df789ad105aba2c9eb250aa94e24cc999e19eca54d05a3`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.52`
  Status: `pending`
  Goal: Read bounded Julia group 52 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.51` committed; empty brief and clean repository.
  Scope: `julia/test/write_vivification_contract_test.jl` lines 454-659; `julia/test_dormant/progressive_span_dispatch_authority_test.jl` lines 1-853
  Baseline evidence: 1059 fragments / 41043 bytes; ordered range SHA-256 `37a0286dea1b9ed8e5dfb7388ef5fd0ce9c0f0899819a13bcdb103ba4bc13e9c`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2`
  Status: `pending`
  Goal: Preserve disjoint repair ownership for every confirmed Julia finding.
  Dependencies: Findings from .1; source repair additionally requires startup .3/.4/.5.
  Acceptance: Reuse exact existing startup owners when applicable; otherwise add bounded repair children with source mechanism, reproduction, acceptance and unblock conditions. No finding is closed by reading alone.
  Children: .2.1 callable-body selector validation; .2.2 attached-switch body/duplicate-default validation; .2.3 recognition-effect integration; .2.4 MCP pattern full matching; .2.5 progressive identity full matching; .2.6 semantic callback action passthrough. Nested authority and diagnostic review retain startup .37.1/.37.2. Prior README findings retain startup .41.2/.41.3/.41.7.
  Verification: `pending` repairs; .1.3 owns the callable-body selector gap, and .1.4 confirms attached-switch projection omission and default replacement. Earlier documentation and helper-arity owners remain intact.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.1`
  Status: `pending`
  Goal: Reject removed aggregate selectors inside explicit and contextual callable bodies before execution.
  Dependencies: Startup .3/.4/.5; .1.3 preserves the exact current defect and reference controls.
  Children: .2.1.1, .2.1.2
  Acceptance: Preserve deferred execution and binding semantics while applying structural selector retirement recursively through every callable body and all compiled/generated entry routes. Do not weaken the existing selector contract or treat alias tests as repair proof.
  Verification: Pending repair; .1.3 proves both array/hash direct controls reject, while inert/called/contextual callable forms compile across all four measured carriers. Twenty asserted outcomes isolate body descent as causal; both computed controls remain valid. Perl Get rejects all four array sources. Existing uniform-binding61 remains green. Exact mechanisms/replay: docs/knowledge/julia-callable-selector-validation-gap.md.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.1.1`
  Status: `pending`
  Goal: Repair structural selector descent through literal and contextual codeblock bodies.
  Dependencies: Startup .3/.4/.5; exact .1.3 diagnostic intake committed.
  Acceptance: Read the complete normalization/validation path first. Traverse typed callable bodies for forbidden structural selectors without executing them or promoting deferred helper dependencies. Cover array/hash, nested literals, unused/dead bodies, parameters, valid literal/computed constructors and precise source diagnostics with RED/GREEN tests; preserve unrelated late-bound behavior.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.1.2`
  Status: `pending`
  Goal: Close reconstructed/generated selector validation and public claim coverage after the visitor repair.
  Dependencies: .2.1.1; source-reading and policy prerequisites.
  Acceptance: Prove native, normalized SpecFile, caller-constructed compiled state, generated-plan validation/execution and independently loaded emitted routes reject forbidden callable-body selectors before effects. Preserve valid deferred callbacks and source-v2 identity, run direct-dependent selector/callable/contextual suites plus appropriate admission proof, and reconcile the book/Knowledge claim against actual coverage.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.2`
  Status: `pending`
  Goal: Preserve complete authored attached-switch content and diagnose invalid branch structure.
  Dependencies: .1.4 diagnostic intake; source repairs retain startup .3/.4/.5.
  Evidence: ActionParser906 extracts only cases/default and replaces each earlier default; ActionContracts871 prefers that projection over the complete retained body. Runtime Interpreter3110 selects only extracted branches. Five controlled sources reproduce lost diagnostics/content and last-default replacement across native, normalized SpecFile, generated-plan and in-process emitted-module routes. A process-local full-body visitor restores lost diagnostics in ten asserted before/after cases; no repository source changed.
  Reading update .1.5: CallableContract already traverses the complete retained body and extracted branches; eight native normalization controls pass. Repair must target the actual parser/resolver/runtime gap without weakening contextual-block normalization. Replay: docs/knowledge/julia-generic-final-codeblock-gap.md.
  Children: .2.2.1 resolves and implements complete-body/duplicate-default validation; .2.2.2 closes carrier and public evidence.
  Acceptance: Preserve valid first-match/default and marker-switch behavior; resolve non-branch placement and duplicate-default diagnostics against the current control contract and exact Perl oracle before implementation. No authored statement may silently disappear from semantic accounting.
  Verification: `pending` repair; intake evidence: docs/knowledge/julia-attached-switch-body-omission.md.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.2.1`
  Status: `pending`
  Goal: Resolve and repair attached-switch body coverage and duplicate-default handling.
  Dependencies: Startup .3/.4/.5; complete parser/validation/runtime reading; .1.4 intake committed.
  Acceptance: Establish the exact normative rule and reference behavior for leading/interleaved/trailing non-branches, duplicate defaults, nested switches and empty/malformed bodies. Add RED/GREEN diagnostic/source-span and no-side-effect controls; require complete source coverage or explicit rejection while preserving valid attached/marker and lazy value-form controls. Keep eager switch validation distinct from deferred callable dependencies.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.2.2`
  Status: `pending`
  Goal: Verify repaired attached-switch invariants across supported carriers and public claims.
  Dependencies: .2.2.1; source-reading/policy prerequisites.
  Acceptance: Cover native, normalized/reconstructed and caller-constructed state, generated-plan validation/execution and independently loaded emitted output; reject invalid structure before effects. Run direct-dependent control suites and required admission proof, preserve valid first-match/default behavior, and reconcile book/Knowledge against the exact tested routes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.3`
  Status: `pending`
  Goal: Enforce forbidden recognition effects before executing recognized child rules.
  Dependencies: Startup .3/.4/.5; .1.7 diagnostic intake.
  Evidence: Native Julia controls reject explicit call(Observer) but admit action/blind edges entering its observation-writing lifecycle. A recognized child writes seen=1 and rollback leaves [true,1]; the pure twin leaves [true,0]. classify_effects occurs only in its definition and direct fixture tests, while compiler special-effect closure omits structural rule edges. Bindings are outside the intended cursor/boundary/mark snapshot.
  Children: .2.3.1 graph/contract reconciliation; .2.3.2 executable enforcement; .2.3.3 carrier/public proof.
  Acceptance: Reject the closed forbidden effect vocabulary before effects, including transitive structural and explicit calls, without silently widening rollback to arbitrary bindings. Preserve pure recognition, false payloads, marks and cursor-only progress. No repair is implied by reading or passing the isolated classifier fixtures.
  Verification: Pending repair; native diagnostic controls and source census belong to .1.7. The independent Dart defect remains under DART-STARTUP-READING.2.4.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.3.1`
  Status: `pending`
  Goal: Reconcile the neutral recognition effect vocabulary with every Julia executable path.
  Dependencies: Startup .3/.4/.5; full compiler/runtime/authority reading; .1.7 intake committed.
  Acceptance: Enumerate AST/helper effects and actual edge dispatch semantics, ordinary and structural rule calls, functions, callable blocks and generated carriers. Distinguish forbidden writes from allowed frame state, validate unknown/raw failures and compare existing reference behavior. Derive graph membership from executable producers; preserve the original admission and diagnostic evidence.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.3.2`
  Status: `pending`
  Goal: Integrate complete recognition-effect validation before recognized execution.
  Dependencies: .2.3.1; source-reading/policy prerequisites.
  Acceptance: Add RED/GREEN direct and transitive forbidden-effect tests, including observed action/blind-edge gaps and persistent binding writes. Cover recursive rule/function paths, callable invocation, unknown effects and timing before operands or IO. Preserve pure actions, payload falsehood, explicit commit/rollback, invocation-local marks and progress; keep unrelated observation and progressive contracts compatible.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.3.3`
  Status: `pending`
  Goal: Verify recognition-effect enforcement across supported carriers and reconcile public claims.
  Dependencies: .2.3.2; source-reading/policy prerequisites.
  Acceptance: Prove native, reconstructed, caller-constructed compiled, generated-plan and independently loaded emitted routes reject before effects. Exercise all neutral rejected families and pure controls, direct-dependent recognition/observation/staged tests and required canonical admission. Update Knowledge and the book to the exact proven scope without closing other backend repairs.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.4`
  Status: `pending`
  Goal: Make Julia MCP schema pattern matching enforce the exact frozen string boundary.
  Dependencies: Startup .3/.4/.5; .1.10 intake committed.
  Evidence: The handle and content-digest schema patterns use occursin with a terminal dollar anchor. A trailing LF passes both patterns, while the neutral validator rejects it. Public decoded and stdio calls with a 43-character handle plus LF return handle_unavailable instead of invalid_params; the separate host handle validator rejects its length. Exact replay is in docs/knowledge/julia-mcp-pattern-terminal-newline-gap.md.
  Children: .2.4.1 complete-match repair; .2.4.2 public/carrier recurrence.
  Acceptance: Preserve the normative schema/generator bytes and implement complete pattern matching for both frozen patterns. Reject malformed handles before lookup, preserve valid values and URI-prefix semantics, and keep error precedence ownership separate under startup .36.
  Verification: `pending` repair; .1.10 has native/public20 and independent-neutral8 diagnostic outcomes.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.4.1`
  Status: `pending`
  Goal: Repair both Julia MCP pattern boundaries with independent negative controls.
  Dependencies: .2.4; startup reading and policy prerequisites.
  Acceptance: Add RED/GREEN controls for exact valid strings, terminal LF/CRLF, extra ASCII, non-ASCII and embedded line breaks. Reconcile the neutral full-match authority and source length/alphabet requirements; ensure handles and digest-bearing sourceReference values agree across the runtime validator and applicable host APIs. Do not regenerate or weaken expected schemas to accept the defect.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.4.2`
  Status: `pending`
  Goal: Prove repaired pattern handling through decoded and stdio MCP and close public claims.
  Dependencies: .2.4.1; startup reading and policy prerequisites.
  Acceptance: Use public requests with valid, unknown and malformed handles; prove invalid_params precedes lookup/native dispatch for malformed input, exact decoded/wire response identity, valid registration/revocation behavior and digest-schema rejection. Run direct-dependent binding/dispatch/stdio, neutral/admission and required canonical boundary proof; update Knowledge/book without closing startup .36 or unrelated defects.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.5`
  Status: `pending`
  Goal: Enforce complete progressive parser identity, top-rule and fingerprint patterns.
  Dependencies: Startup .3/.4/.5; .1.12 diagnostic intake.
  Evidence: BoundedChildParseAuthority1334-1339 uses dollar-anchored occursin for three fields. Each accepts a final LF; constructor and dispatch controls preserve it through a callback while neutral fullmatch rejects it. Native20 and neutral12 pattern assertions isolate this host-authority boundary without claiming authored or emitted reproduction.
  Children: .2.5.1 complete matching; .2.5.2 supported-boundary recurrence and public evidence.
  Acceptance: Preserve exact neutral identities, valid static operands and registry lookup; malformed syntax must fail at the owning boundary. MCP .2.4 is a separate validator owner; startup .37 retains nested inheritance and diagnostic review.
  Verification: `pending` repair; exact replay in docs/knowledge/julia-progressive-authority-boundary-gaps.md.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.5.1`
  Status: `pending`
  Goal: Reject progressive identity/top/fingerprint terminal newlines using complete matching.
  Dependencies: Startup .3/.4/.5; .1.12 committed; all relevant source read.
  Acceptance: Add independently justified RED/GREEN tests for exact valid strings, final LF, CRLF, embedded newlines, extra punctuation and Unicode suffixes at registry configuration and private dispatch. Preserve the neutral pattern strings and diagnostic owner; do not normalize away invalid authored or host input.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.5.2`
  Status: `pending`
  Goal: Verify repaired progressive identity boundaries across supported carriers and claims.
  Dependencies: .2.5.1; startup prerequisites.
  Acceptance: Reconcile static ActionIR validation, host registry construction, direct dispatch and reconstructed/generated/emitted routes with precise boundary-specific diagnostics. Retain valid private authority, ordinary carrier tests and the independent authority matrix; run designated canonical admission/public proof and update book/Knowledge without widening the private API.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.6`
  Status: `pending`
  Goal: Preserve original semantic observer failures through action-mediated child execution.
  Dependencies: Startup .3/.4/.5; .1.14 diagnostic intake.
  Evidence: Interpreter2716 marks the original callback error, but action-block catch2873 omits marked semantic failure passthrough. Native parse returns RuntimeInterpreterException and validated generated plans return GeneratedSourceException for a Child slot callback thrown inside Top I return(call(Child)); direct, blind-child and final-result controls preserve identity.
  Children: .2.6.1 nested catch repair; .2.6.2 supported-route recurrence and public evidence.
  Acceptance: Preserve exact caller error identity and original callback backtrace, ordinary action diagnostics, trace closure, result/event ordering and no-sink fast path. Reuse the existing semantic failure authority rather than creating another public API. Dart .2.8 remains its separate backend repair owner.
  Verification: `pending` repair; exact diagnostic and limitations belong to docs/knowledge/julia-semantic-observer-action-failure-wrapping.md.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.6.1`
  Status: `pending`
  Goal: Repair semantic callback passthrough at all intervening Julia action catches.
  Dependencies: Startup .3/.4/.5; .1.14 committed; relevant source fully read.
  Acceptance: Inventory child calls nested in lifecycle, edge, function, callable and control blocks; add independently justified RED/GREEN controls for callback failures at slot and final seams. Preserve ordinary action error translation, control transfers, output sink behavior and detached observation data. Prove exact caller object and callback backtrace propagation without broad suppression.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.6.2`
  Status: `pending`
  Goal: Recur repaired callback composition through every supported Julia carrier.
  Dependencies: .2.6.1; startup prerequisites.
  Acceptance: Verify native, loaded/reconstructed, validated generated-plan and fresh isolated emitted direct/traced routes. Require actual enabled trace closure, failure identity/backtrace, successful values/events and unchanged no-sink behavior. Run designated canonical admission/public proof and reconcile book and Knowledge claims without generated-format or semantic-contract widening.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.3`
  Status: `pending`
  Goal: Independently close Julia reading and route Lua startup reading.
  Dependencies: Every .1 child committed and every finding repair-owned.
  Acceptance: Independently verify exact baseline/current coverage, comprehension, unique child commits and activation boundaries; preserve all repairs, close only .1/startup .3.5 and route startup .3.6 Lua decomposition.
  Verification: `pending`; canonical milestone proof remains required unless separately authorized otherwise. ADR0114 is Dart-only.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.4`
  Status: `done`
  Goal: Resolve evidence or history capacity before it blocks a safely committed Julia slice.
  Dependencies: Fresh resulting-tree/mandatory-rollover projection and clean prior reading checkpoint.
  Acceptance: Preserve existing evidence and all limits; route changing detail to its canonical owner. If a capacity increase is actually required, prepare exact old/new controls, source and immutable-history preservation proof, finite projected need and the required director decision before infrastructure implementation. Current history collections have no free member slots; no later archive slot is preapproved.
  Children: .4.1 proposal; containment .12 implements approved capacity under ADR0115. Julia .1.4 resumes after its clean admission.
  Verification: Containment .12 admits the six approved limits with exact history preservation, 44 actual threshold and 22 actual authorization executions, normal doctrines and the explicit .12-only focused exception. Implementation proof: docs/knowledge/julia-reading-history-capacity-admission.md. All .1 source children and .2 repairs remain unchanged.
  Commit: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.12 - admit approved Julia history capacity`.

- ID: `JULIA-STARTUP-READING.4.1`
  Status: `done`
  Goal: Prepare exact finite history capacity for remaining Julia reading and closeout while the intake still fits.
  Dependencies: Clean .1.3 commit; no pending jobs; empty brief.
  Activation commit: `6308ff4e2426de216cf702b86107e4ebda33a026`.
  Verification tier: `focused`
  Focused checks: Actual registry/history census, immutable reconstruction and bounded future-rollover model; exact old/new proposal with finite record budget, source/evidence preservation, Knowledge, memory, histories, book and normal doctrines.
  Canonical trigger: `none` — proposal-only intake; implementation remains a separate canonical infrastructure boundary.
  Scope: Current history collection/manifest limits and a finite remaining-Julia envelope; preserve all immutable records and root/segment/aggregate controls. No registry, verifier, CI, source or dependency change.
  Acceptance: State exact proposed controls, measured need and evidence-preserving alternatives; reserve the proposal commit before future reading consumes its space. Identify any necessary verification decision concretely before implementation.
  Verification: Baseline roots 443/26500 and 378/23613; collections 32/48964/3554933 and 28/26202/2797491; all manifest/segment counts, bytes and hashes plus archived-history queries pass. Independent Python and extracted production-Perl functions agree on 55 records of 14 lines/2048 bytes, exactly four rollovers per surface, maximal manifest rows 576/612 bytes, and aggregate forecasts 49738/3669877 and 26976/2912579. Proposal changes only files 32→36, changes manifest 31→35/17615→19919, files 28→32 and notes manifest 27→31/16384→18678. Full reproduction and limits live in docs/knowledge/julia-reading-history-capacity-proposal.md. Preservation confirms 541 prior task nodes, all existing fact/ADR/history bytes, 95 unchanged Julia sources and unchanged 3/52 credit. Both hot roots pass current checks at 455/27314 and 387/24159; Knowledge regeneration and mdBook build pass. No registry, source or history mutation; all nine normal doctrines govern this focused intake.
  Commit: `JULIA-STARTUP-READING.4.1 - prepare finite history capacity and verification decision`.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `JULIA-STARTUP-READING.1.15` | `pending` | Read Interpreter3116-4615 after clean .1.14; keep all repair prerequisites and evidence intact. |

## Decisions

- `2026-09-11` .4 closeout: The director answers YES to .12 capacity and its one-time focused exception. ADR0115 implements the finite allowance and records proportionate governance.

- `2026-09-11`: Prepare one finite remaining-Julia allowance, with all other ceilings unchanged; record the proposed verification exception before asking. Earlier waivers do not extend automatically.
- `2026-09-11`: Keep Julia execution evidence in this separate bounded member; the startup file has insufficient room for the full plan. No aggregate/member/control change.
- `2026-09-11`: Use52 exact groups with per-child source digests; store source identities in Git and scopes here rather than duplicating an unbounded inventory.

## Open Questions

- None for source ownership. Future history capacity belongs to .4 and has no automatic increase authorization.

## Blockers

- `2026-09-11` .4 closeout: The .12 capacity decision below is resolved by ADR0115 and verified admission. Julia .1.4 resumes; actual per-leaf pressure checks remain.

- `2026-09-11`: Pending .12 needs the six exact capacity controls and explicit proposed one-time canonical-receipt boundary. After this intake CHANGES is 455 lines; the next ordinary seven-line reading record would require a disallowed archive.
- None for the first reading group at decomposition. Later mandatory rollovers require .4 before exceeding unchanged history limits.
- Source repairs retain startup prerequisites; those dependencies do not block source reading.

## Verification Log

- `2026-09-11` .1.14: Julia .1.14 reads Interpreter1616-3115: 14/52 groups, 19,425 fragments /743,537 bytes and twenty-two complete files. Existing rule39/control6/emitter65/capture66 assertions pass (176 plus selection1); the 108-assertion public observer diagnostic isolates action-child exception identity loss across four routes. Neutral semantic6/20/128, rollout9/0 and admission6/0 pass. New .2.6.1/.2.6.2 own passthrough repair and supported-route recurrence; all prior repairs, source, evidence and ADR0115 controls remain. Julia .1.15 is next; no full component/canonical gate or dependency build.
- `2026-09-11` .1.13: Julia .1.13 reads Interpreter116-1615: 13/52 groups, 17,925 fragments /694,012 bytes and twenty-two complete files. Existing diagnostics7/typed127/recognition207/observation30/gap319/options53 assertions pass (743); neutral typed231 and recognition138/250/58 pass. Runtime state, recognition/gap adapters and typed projections reconcile with Knowledge while effect repair .2.3 remains open. Governed notes rollover preserves213 lines/12898 bytes as segment4979; prior history and ADR0115 limits remain unchanged. Julia .1.14 is next; no full component/canonical gate or dependency build.
- `2026-09-11` .1.12: Julia .1.12 completes UserFunctionDefinitionParser and BoundedChildParseAuthority and reads Interpreter through115: 12/52 groups, 16,425 fragments /647,482 bytes and twenty-two complete files. Existing authority210/carrier62 and native64 diagnostic assertions pass; neutral pattern12 and progressive116/public60 pass. Startup .37.1/.37.2 retain nested grant/budget and diagnostic review; Julia .2.5.1/.2.5.2 own progressive pattern full matching. Direct cost/result/diagnostic limits work in the measured controls. All source, earlier evidence, repairs and ADR0115 controls remain. Julia .1.13 is next; no full component/canonical gate or dependency build.
- `2026-09-11` .1.11: Julia .1.11 completes McpWire and StagedParserRegistry and reads UserFunctionDefinitionParser through 231: 11/52 groups, 14,925 fragments /601,796 bytes and twenty complete files. Existing registry39/descriptor28/trace28/function-parser7/stdio170/variadic55 assertions pass (327 total); neutral staged123/public129 and MCP35/10/10/76 pass. Narrow function-body adapter and general-v2 authority remain separate; source-driven shell parsing and strict wire framing reconcile with Knowledge. All source, prior evidence, repairs and ADR0115 controls remain. Julia .1.12 is next; no full component/canonical gate or dependency build.
- `2026-09-11` .1.10: Julia .1.10 completes McpContract, McpContractRuntime and McpServer, and reads McpWire through 55: 10/52 groups, 13,425 fragments /549,293 bytes and eighteen complete files. Existing MCP binding53/dispatch145/stdio170 pass (368 assertions); native pattern20 and order12 diagnostics plus neutral pattern8 outcomes isolate the documented boundaries. Pending Julia .2.4.1/.2.4.2 own full-pattern matching; startup .36 retains validation precedence. Generator and neutral transport35/10/10/76 remain green. All source, prior evidence, repairs and ADR0115 controls remain. Julia .1.11 is next; no full component/canonical gate or dependency build.
- `2026-09-11` .1.9: Julia .1.9 reads McpContract lines 373-1002: 9/52 groups, 11,925 fragments /484,254 bytes and fifteen complete files. Check-only generation confirms 120,030 source bytes; independent decoding verifies the 82,882-byte bundle digest. Existing binding tests pass 53 assertions and neutral transport passes 35 frames /10 raw inputs /10 lifecycle cases /76 rejected mutations. Generated schema, frame and policy data reconcile with their neutral authority. All source, prior evidence, repairs and ADR0115 controls remain. Julia .1.10 is next; no full component/canonical gate or dependency build.
- `2026-09-11` .1.8: Julia .1.8 completes CorpusManifest and SpecLoader, and reads McpContract through 372: 8/52 groups, 11,295 fragments /418,734 bytes and fifteen complete files. Existing controlled-corpus58, loader82, MCP-binding53 and cursor-option53 assertions pass (246 total); the generator verifies120,030 source bytes and neutral resolution remains14/9/4. Corpus selection/loading, historical counts and removed-option teaching reconcile with current source. All source, prior evidence, repairs and ADR0115 controls remain. Julia .1.9 is next; no complete component/canonical gate or dependency build.
- `2026-09-11` .1.7: Julia .1.7 completes CompiledSpec and reads CorpusManifest through 161: 7/52 groups, 10,071 fragments /353,238 bytes and thirteen complete files. Existing recognition207, observation30, mutation496, write406 and manifest20 assertions pass (1,159 total); native/causal25 and reference11 diagnostic assertions isolate forbidden recognition writes and omitted structural observation edges. Pending .2.3.1-.2.3.3 own graph reconciliation, enforcement and carrier proof; reference E-only omission stays startup .27-owned. All sources, prior evidence, repairs and ADR0115 controls remain. Julia .1.8 is next; no complete component/canonical gate or dependency build.
- `2026-09-11` .1.6: Julia .1.6 completes FunctionRegistry and the primary CLI, and reads CompiledSpec through 521: 6/52 groups, 8,571 fragments /296,130 bytes and twelve complete files. Registry 23, compiled state 41, root selection 79 and variadic 55 assertions pass (198 total); the ten-family primary CLI process checker passes. Canonical phase traces remain separate from native internal traces; current registry metadata and compiled-state boundaries reconcile with Knowledge. All source, earlier evidence, pending repairs and ADR0115 controls remain; Julia .1.7 is next, with no complete component/canonical gate or dependency build.
- `2026-09-11` .1.5: Julia .1.5 completes ActionParser and CallableContract, and reads FunctionRegistry through 94: 5/52 groups, 7,071 fragments /248,648 bytes and ten complete files. Existing contextual 118 / registry 23 / variadic 55 assertions pass (196 total); eight native normalization outcomes also pass, including idempotence for all four valid forms. Normalization traverses retained switch and callable bodies, so prior selector/contract visitor gaps remain precisely scoped and repair-owned. Staged/progressive/nested-write facts and registry metadata reconcile with current source. All source, earlier evidence and ADR0115 controls remain; Julia .1.6 is next, with no complete component/canonical gate or dependency build.
- `2026-09-11` .1.4: Julia .1.4 completes ActionContracts and reads ActionParser through 1138: 4/52 groups, 5,571 fragments /197,138 bytes and eight complete files. Existing parser 74 / resolver 40 / callable 482 assertions pass. Five four-carrier switch controls and ten causal resolver cases confirm retained-body omission and last-default replacement; .2.2.1/.2.2.2 own normative reconciliation, repair and carrier/public proof. The shared Perl oracle qualifies non-branch behavior; its initial E-only carrier reuses startup .27. All source bytes, prior repairs and approved ADR0115 capacity remain. Julia .1.5 is next; no complete component/canonical gate or dependency build.
- `2026-09-11` .4 closeout: Approved containment .12 / ADR0115 admits four extra archive slots per history through six exact limits. The governed change-history rollover preserves 217 lines /13,128 bytes from clean 107170da7; all prior history and unrelated controls remain exact. Production-validator proof passes 44 threshold and 22 authorization cases under the explicit one-time focused exception. Julia reading remains 3/52 groups and seven complete files; .1.4 is next. All parser repairs, startup prerequisites and future canonical/push requirements remain.

- `2026-09-11` .4.1: Julia reading remains 3/52 groups, 4,071 fragments /145,809 bytes and seven complete files. Julia .4.1 prepares four extra archive slots per history for the remaining reading/closeout envelope; six proposed controls leave root, segment and aggregate limits unchanged. Independent models agree on eight rollovers and preserve all history. Pending containment .12 owns implementation and its requested one-time canonical exception; approval is not assumed. Julia .1.4 waits behind that decision. The callable selector gap and all prior repairs remain open.
- `2026-09-11` .1.3: Julia .1.3 completes ActionAst and reads ActionContracts through 766: 3/52 groups, 4,071 fragments /145,809 bytes and seven complete files. Twenty causal controls prove callable bodies bypass retired array/hash selector validation across native, reconstructed, generated-plan and in-process emitted-module routes; .2.1.1/.2.1.2 own repair. Existing uniform-binding 61 and projection/alias 8 pass without closing the gap. All source bytes and prior repairs remain. Julia .1.4 is next, with .4 capacity intake before history rollover.
- `2026-09-11` .1.2: Julia .1.2 finishes README, both command delegates and the facade, and reads ActionAst through line 964: 2/52 groups, 2,571 fragments /104,408 bytes and six complete files. All 452 public names are defined; both CLI help paths, 55 punctuation assertions and neutral 6/4/6 pass. The existing missing-needle contains defect remains under backlog .5; startup .41.7 owns the remaining bare README commands. Sources, Dart failures and all repairs stay unchanged. Julia .1.3 is next; .4 owns future capacity pressure.
- `2026-09-11` .1.1: Julia .1.1 completes the manifests and README lines 1–963: 1/52 groups, 1,071 fragments / 65,410 bytes and two complete files. Seven exact README examples and the primary JSON example pass on Julia 1.12.7; semantic governance remains 6/20/128, rollout 9/9 and admission 6/6. Existing startup .41.2/.41.3/.41.7 own the stale status and unmanaged-command guidance. All sources, prior repairs and Dart gate failures remain unchanged. Julia .1.2 is next; .4 owns future capacity pressure.
- `2026-09-11`: Startup .3.5.0 independently reconstructs all 95 baseline-identical paths,52 groups,146 ranges and every byte once; all child bounds/digests pass. No physical-reading credit.

## Commit Log

- `2026-09-11` .1.14: `JULIA-STARTUP-READING.1.14 - read rule execution and own observer passthrough repair`.
- `2026-09-11` .1.13: `JULIA-STARTUP-READING.1.13 - read runtime state and source projections`.
- `2026-09-11` .1.12: `JULIA-STARTUP-READING.1.12 - read child authority and own boundary repairs`.
- `2026-09-11` .1.11: `JULIA-STARTUP-READING.1.11 - read wire and staged function parser paths`.
- `2026-09-11` .1.10: `JULIA-STARTUP-READING.1.10 - read MCP runtime and own pattern validation repair`.
- Reconciled .1.7-.1.9 commit references: `3a4073ab3d458e51ce3596daf8198441e765abdd`, `1fa6cab75558de3339e17ecd799b51f0ced5b468`, `9431f6c8aeac4b95933c3683b5fa77bf5054acb0`; exact subjects/evidence remain in their done nodes and Git.
- `2026-09-11` .1.6: `JULIA-STARTUP-READING.1.6 - read function registry CLI and compiled state`.
- `2026-09-11` .1.5: `JULIA-STARTUP-READING.1.5 - read parser and callable normalization`.
- `2026-09-11` .1.4: `JULIA-STARTUP-READING.1.4 - read contracts and own attached switch omission`.
- `2026-09-11` .4 closeout: `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.12 - admit approved Julia history capacity`.

- .4.1: `JULIA-STARTUP-READING.4.1 - prepare finite history capacity and verification decision`.
- .1.3: `JULIA-STARTUP-READING.1.3 - read action projection and own callable selector gap`.
- .1.2: `JULIA-STARTUP-READING.1.2 - read facade and typed action model`.
- .1.1: `JULIA-STARTUP-READING.1.1 - read package manifests and README examples`.
- Decomposition: `SESSION-STARTUP-READING.3.5.0 - freeze exact bounded Julia reading plan`.

## Changelog

- `2026-09-11` .1.14: Reads rule/action execution, owns observer passthrough repair and qualifies historical callback claims.
- `2026-09-11` .1.13: Reads runtime state/projections, reconciles historical claims, and preserves exact notes history through the governed rollover.
- `2026-09-11` .1.12: Completes child-authority reading, extends startup .37 with Julia evidence and owns progressive identity matching under .2.5.
- `2026-09-11` .1.11: Completes wire and narrow staged-registry reading; reconciles the separate general-v2 boundary and keeps all repairs open.
- `2026-09-11` .1.10: Completes MCP runtime/server reading, owns pattern repair and reuses precedence repair; reconciles current metadata/frontiers while preserving earlier node evidence.
- `2026-09-11` .1.6: .1.6 completes registry/CLI reading and the first compiled-state range, reconciles current facts and keeps all repairs open.
- `2026-09-11` .1.5: .1.5 completes parser/normalizer reading and qualifies registry/traversal facts without changing source or closing defects.
- `2026-09-11` .1.4: .1.4 completes the fourth exact reading group, reconciles current pointers and owns the switch finding without source repair.
- `2026-09-11` .4 closeout: Approved containment .12 closes .4; no reading credit or defect status changes.

- `2026-09-11`: .4.1 prepares the exact proposal and routes pending containment .12; no capacity or source change.
- `2026-09-11`: .1.3 completes the third reading group and owns the confirmed callable-body selector defect under .2.1.
- `2026-09-11`: .1.2 completes six files cumulatively and the first typed ActionAst range; prior repairs remain pending.
- `2026-09-11`: .1.1 closes the first exact source-reading group and routes existing public-teaching repairs.
- `2026-09-11`: Created bounded Julia reading ownership with 52 pending source children and explicit repair, closeout and capacity owners.
