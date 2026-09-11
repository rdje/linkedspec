# JULIA-STARTUP-READING: Bounded Julia reading and repair ownership

## Metadata

- Tree ID: `JULIA-STARTUP-READING`
- Status: `active` / reading 29/52; selector, switch, recognition, pattern, observer, token, callback, numeric, bounds, arity, matching, staged, diagnostic, static, entry and selector-projection repairs pending
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
- Current physical reading: 29/52 children, 41,925/75,984 lines and 1,469,930/2,693,170 bytes; thirty-seven complete files.
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
  Verification: Julia .1.29 completes SemanticStaticProjection and SourceEmitter and reads spec/Ast1-101: 29/52 groups, 41,925 fragments /1,469,930 bytes and thirty-seven complete files. Fresh emitter65/semantic389 and seven selector controls99 assertions pass. Regex/action/label-substring decoys make typed unindexed edges report indexed metadata and selects_regex relations; Julia .2.18 owns typed projection and supported-route/public repair. Both neutral semantic6/20/128 and generated-source checks pass. All prior repairs, source, history and ADR0115 controls remain. Julia .1.30 is next; no full component/canonical gate or dependency build.
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
  Status: `done`
  Goal: Read bounded Julia group 15 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.14` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 3116-4615
  Baseline evidence: 1500 fragments / 50914 bytes; ordered range SHA-256 `a5b0d3b0bdd6afbedc84dd3d6fea762fe6f1c49d572a1a10cc1ed412ef37584c`.
  Activation commit: `867f5cc8be3699fbd0cab40fd3c02988d97a6258`.
  Verification tier: `focused`
  Focused checks: Exact bounded source/range reconstruction; existing marker/control/function/cursor/progressive/staged/recognition suites; four-route token preflight diagnostic; neutral progressive/staged/recognition checks; source/prior-task/history preservation, Knowledge, memory, rendered book and normal doctrines.
  Canonical trigger: `none` — ordinary reading and defect intake; no source, contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes attached-switch selection and marker if/switch depth-aware range selection; value blocks distinguish local return from rule flow and evaluate only selected control bodies. While guards retain the known exact-limit issue. The expression dispatcher copies aggregates, guards every binding write, creates inert staged markers from live source/match authority, dispatches progressive spans under private authority, and handles recognition and observation nodes. RecognizeOnce invokes the child before token lookup/state validation, the new .2.7 defect. Callable values retain cached body AST and detached JSON. Call dispatch prioritizes structural with/if/switch, then registered functions before ordinary helpers; statement-only transforms precede value dispatch. Source/capture/gap helpers delegate typed projections, cursor operations validate boundaries, and explicit child calls share action-edge memoization. Helper-value fallback continues in .1.16.
  Knowledge: Runtime value/control card owns focused replay and exact comprehension; progressive/staged cards qualify historical authority/effect claims against existing .37/.2.3 repairs. docs/knowledge/julia-recognition-attempt-preflight-gap.md owns exact public token diagnostic and mechanism; recognition integration links it without changing dated admission evidence.
  Findings: New .2.7/.2.7.1/.2.7.2 own token preflight and static-sequence/carrier proof. Child::AND consumes exactly one character: missing-token calls emit position1 before recognition_token_expected, repeated and post-commit calls emit positions1,2 before attempt_count/token_expected. All four native/generated-plan conveniences agree. Initial default-mode Child consumed both characters, so only the corrected AND control proves second-child matching. Enabled trace, fresh emitted routes and private post-error state remain unmeasured. Existing while/backlog .5, effect .2.3, observer .2.6 and startup .38 retain separate ownership.
  Verification: Six untruncated windows read1500 fragments /50914 baseline-identical bytes; ordered-range digest a5b0d3b0bdd6afbedc84dd3d6fea762fe6f1c49d572a1a10cc1ed412ef37584c, raw-range SHA0e8518061a57734c4a554c54f894f196c2ccb0ffbb26d758072e133a132a6e7e. Existing marker1/control6/function9/cursor17/progressive62/staged491/recognition207 pass (793 plus selected-set equality1). Token diagnostic80 spans16 source/route combinations. Neutral progressive116/public60, staged123/public129 and recognition138/250/58 pass. Full exact source/coverage/prior-node/history preservation, Knowledge, memory, bounded histories, book and normal doctrines govern landing. No source/test change, unread-source credit, complete backend/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.15 - read control dispatch and own token preflight repair`.

- ID: `JULIA-STARTUP-READING.1.16`
  Status: `done`
  Goal: Read bounded Julia group 16 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.15` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 4616-6115
  Baseline evidence: 1500 fragments / 47167 bytes; ordered range SHA-256 `7d4512f98e5f1be18f67db7b2c2c70d445da22d7cc6edafe6d8bcffe2804b463`.
  Activation commit: `bfd68cd6ec4dc3a8801ea51e12f2d666f735b275`.
  Verification tier: `focused`
  Focused checks: Exact bounded source/range reconstruction; existing array/hash/function/tree/callable/contextual/construction/map-mutation suites; native/reconstructed callback identity diagnostic; neutral callable/mutation/write checks; exact probe preservation/cleanup, source/prior-task/history, Knowledge, memory, book and normal doctrines.
  Canonical trigger: `none` — ordinary reading and defect intake; no source, contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes ordinary helper fallback and bound-codeblock validation, eager ordered/copied arguments, arity/cycle checks, cached body execution and reverse scoped-binding restoration. Helper names incorrectly become callback recursion identities. User functions instead replace all three stores and binding identities, normalize/cache body source and restore caller state in finally. Inline branches remain lazy; with callbacks resolve before scoped value installation. Set/push guard the target before operands/child dispatch; aggregate constructors retain splice behavior. Helper-family sets lead into map_leaves! original-shape traversal with detached frames, atomic publication, guard release and post-commit continuation. Fluent execution handles leading array-end mutation, lazy coalesce, receiver with/tree and helper projections; the tree reduce suffix continues in .1.17.
  Knowledge: Dynamic-callable and user-function cards now record exact scope/cache differences and qualify old generic-normalization status. Map-mutation fact reconciles current source and496-assertion proof. docs/knowledge/julia-callback-helper-recursion-identity-gap.md owns exact diagnostic and separate repair.
  Findings: New .2.8/.2.8.1/.2.8.2 own false same-helper recursion and helper-mediated bound callback identity. Four nested anonymous cases reject as with→with/map_leaves→map_leaves; direct cb recursion correctly reports cb→cb while helper-mediated cb reports with→with. Single, sequential and mixed map/reduce controls succeed on native and SpecFile-JSON routes. No unbounded escape, repeated-body count, enabled trace or fresh emitted defect proof. Dart .2.10 and dated Lua identity evidence remain separate.
  Verification: Six untruncated windows cover1500 fragments /47167 baseline-identical bytes; ordered-range digest7d4512f98e5f1be18f67db7b2c2c70d445da22d7cc6edafe6d8bcffe2804b463 and raw SHA8f184e3932db3eeec4f415e24172b8aef2c9fd920903a7922ae12166bc471872. Existing array2/hash1/function9/tree2/callable125/contextual118/construction239/mutation496 pass (992 plus selected-set equality1). Diagnostic84 spans18 outcomes; initial raw-string JSON encoding failed before runtime and direct literal rows corrected the harness. Neutral callable23, mutation167+592 and write105 pass. Exact executed probe is copied into the fact and its single scratch file safely removed with absence verified. Exact source/coverage/prior-node/history, Knowledge, memory, bounded histories, book and normal doctrines govern landing; no unread-source credit, complete backend/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.16 - read callable execution and own callback identity repair`.

- ID: `JULIA-STARTUP-READING.1.17`
  Status: `done`
  Goal: Read bounded Julia group 17 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.16` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 6116-7615
  Baseline evidence: 1500 fragments / 47705 bytes; ordered range SHA-256 `39ff025eeb973cba92aae38f19201eb5256ab85bfc4f047d247f80cd7225d145`.
  Activation commit: `975c78a30550f875a24ef17f29ad4e9bd77ff61d`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; existing scalar-text/numeric/string/array/hash/tree/uniform/mutation suites; native/reconstructed numeric/range diagnostics and Perl Get reference; neutral numeric/uniform checks; source/prior-task/history preservation, Knowledge, memory, book and normal doctrines.
  Canonical trigger: `none` — ordinary reading and defect intake; no source, contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes copied tree traversal and callback-name forwarding, lazy coalesce, guarded array-end and hash replacement, bare-target split, statement transforms, structural aggregate splicing and shared pure-helper dispatch. String/regex paths retain strict flags, character indexing, substitution capture expansion and guarded writeback. Numeric adapters reject boolean/aggregate inputs but host integer arithmetic and integral-to-Int conversion introduce boundary defects. Action-edge child dispatch is memoized before execution and conditionally bypasses blind terminals when observation does not require entry; trace-cursor construction continues in .1.18.
  Knowledge: Numeric, aggregate and regex facts reconcile with source; current split(target, source, delimiter) supersedes the older selector example. docs/knowledge/julia-large-number-and-slice-boundaries.md preserves exact paired replay, source mechanisms and remaining carrier/domain limits.
  Findings: New .2.9.1-.3 own integer-literal overflow, finite integral-float loss and wrapped addition/abs; .2.10.1/.2 own overflow-safe drop_front/slice/substr. Native and SpecFile-JSON agree, while Perl Get preserves tested magnitudes and expected bounded ranges. Startup .55.2 retains decimal/scientific spelling and .60.2 the equivalent-backend census. No arbitrary-precision promise or fresh Julia generated/emitted defect proof.
  Verification: Six untruncated windows cover1500 fragments /47705 baseline-identical bytes; ordered-range SHA39ff025eeb973cba92aae38f19201eb5256ab85bfc4f047d247f80cd7225d145 and raw SHA9201732de367ce671696f54f731931e0fd398e8e3c3abe4a8860cea5ebb83bfd. Existing suites pass585 plus selected-set equality1; diagnostic128 spans32 Julia outcomes and Perl Get reference64 covers16 controls. Neutral numeric55/18 and uniform11/7/6/8 pass. Initial integer-only probe hid runtime normalization behind compile failure; decimal/string controls isolate it. A guessed neutral-text checker path was absent; no separate text-checker pass is claimed. Supporting ActionParser482-502 and Interpreter8996-9010 diagnosis grants no advance reading credit. Exact coverage/prior-node/history, Knowledge, memory, histories, rendered book and normal doctrines govern landing; no full backend/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.17 - read helper boundaries and own numeric and range repairs`.

- ID: `JULIA-STARTUP-READING.1.18`
  Status: `done`
  Goal: Read bounded Julia group 18 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.17` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 7616-9115
  Baseline evidence: 1500 fragments / 47712 bytes; ordered range SHA-256 `bf09ad52290a43634f12195618892db9d2b9a9cd5a0abb09909edcabcb52468c`.
  Activation commit: `d1af4b90f1f52b0b821d6078f55b9076840061b9`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; existing core/capture/cursor/mark/diagnostic/logical/typed-source/write suites; native/reconstructed slice and Perl Get/host diagnostics; neutral logical/typed/write checks; prior-task/source/history preservation, Knowledge, memory, book and normal doctrines.
  Canonical trigger: `none` — ordinary reading and defect intake; no source, contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes cursor-control tracing, passive-terminal classification and symbolic capture-name lookup. Anonymous/named marks project typed spans and advance only after successful validation; boundary lookahead seeks all usable labels and leaves the earliest boundary unconsumed. Diagnostic helpers enforce arity, wrap sink failures privately and retain exit as a typed outcome. Input slicing clips integer widths safely but leaves arity and float conversion unguarded. Codeblock decoding, binding kind/presence, store copying and non-creating reads remain distinct. Nested writes evaluate segments/RHS, validate selectors, snapshot the current root, build densely in isolation and publish once with precise path/span errors. Truthiness is shared; diagnostic construction continues in .1.19.
  Knowledge: Cursor/capture, diagnostic, logical, write-publication and Perl source-slice compatibility homes reconcile with current source. docs/knowledge/julia-input-slice-arity-and-count-boundaries.md records exact positive typed clipping and separate arity/conversion/reference-fallback mechanisms.
  Findings: New .2.11.1/.2 own zero/one/extra input_slice argument acceptance and ignored extra operand effects. Existing .2.9 owns integral-float conversion failures in input_slice/drop_front. Typed large-Int slicing is correct and does not inherit .2.10 array/string arithmetic. Startup .60.2 explicitly owns Perl scientific-count fallback, whose host substr returns ab and drop guard retains [1,2]; neither becomes the repair oracle without normative review. Dart .2.15 and backlog .5 retain coordinated arity review. No new nested-write failure, repair closure or emitted Julia defect reproduction.
  Verification: Six untruncated windows cover1500 fragments /47712 baseline-identical bytes; ordered SHA bf09ad52290a43634f12195618892db9d2b9a9cd5a0abb09909edcabcb52468c and raw SHA3ed6ee664b232238e29b0020d81d0e7d03fc120d59ed302fcd3f6e5a6b8827fa. Existing core4/capture2/scope3/cursor17/marks13/diagnostic82/logical232/typed127/write406 pass886 plus selection1. Exact saved diagnostics pass174 Julia assertions across14 native/reconstructed cases and44 Perl assertions across8 Get/lowering/source controls plus4 host-cause checks. Neutral logical26, typed231 and write105 mutations pass. All diagnostic jobs are consumed; exact coverage, prior nodes/source/history, Knowledge, memory, bounded histories, rendered book and normal doctrines govern landing. No full component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.18 - read capture and storage boundaries and own input slice arity`.

- ID: `JULIA-STARTUP-READING.1.19`
  Status: `done`
  Goal: Read bounded Julia group 19 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.18` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 9116-9285; `julia/src/runtime/Matching.jl` lines 1-509; `julia/src/runtime/RecognitionTransaction.jl` lines 1-821
  Baseline evidence: 1500 fragments / 46811 bytes; ordered range SHA-256 `197da31645415eaf6d9ea4669e3f53191264bb96a47e0921e29b738e108df89f`.
  Activation commit: `c746951cf298f103e48d1b20c6510c425109ca5c`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; existing matching/diagnostic/duplicate-slot/recognition/gap suites; direct matcher invalid-mode diagnostic; neutral recognition/gap checks; prior-task/source/history preservation, Knowledge, memory, book and normal doctrines.
  Canonical trigger: `none` — ordinary reading and defect intake; no source, contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes interpreter diagnostic/event/result serialization and all matching code. Native PCRE alternatives preserve authored slots, earliest-position/source-order ties and consume-at-cursor selection. Full/compact/named captures remain distinct; only live regex offsets grant staged capture provenance. UTF-8 offset checks, character/LF projections and immutable register replacement preserve child entry/local separation. Recognition authority prefixes own copied frame marks, monotonic source/invocation/token generations, parent/entry-slot identity, gap candidates/tails and snapshot-backed checkpoint/attempt state. Active misuse restores before invalidation; invalidated-token restoration is an early no-op. Commit and effect/progress suffixes continue in .1.20.
  Knowledge: Matching and private-authority cards now preserve exact complete/prefix coverage, focused replay and historical-count qualifications. docs/knowledge/julia-selected-slot-mode-validation-gap.md owns the new public low-level API diagnostic; source comparison is added to existing startup .38.1 without closing behavioral census.
  Findings: New .2.12.1/.2 own selected-slot mode preflight: invalid scan/integer7 rejects on x but silently misses on y for pattern x, while ordinary runtime_match rejects both. Four valid seek/consume controls remain correct. This does not reintroduce global parser mode or prove an authored failure. No new transaction failure or source repair; existing effects .2.3, attempt preflight .2.7 and startup .38 remain open.
  Verification: Seven untruncated windows cover1500 fragments /46811 baseline-identical bytes across Interpreter9116-9285, Matching1-509 and RecognitionTransaction1-821; ordered SHA197da31645415eaf6d9ea4669e3f53191264bb96a47e0921e29b738e108df89f. Existing matching60/diagnostics7/slots121/recognition207/gap319 pass714 plus selection1; direct mode diagnostic28 covers8 malformed and4 valid controls. Neutral recognition138/250/58 and gap63/public34 pass. Exact source/coverage/prior-node/history, Knowledge, memory, bounded histories, book and normal doctrines govern landing. No unread-source credit, full component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.19 - complete matching reading and own selected-slot mode validation`.

- ID: `JULIA-STARTUP-READING.1.20`
  Status: `done`
  Goal: Read bounded Julia group 20 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.19` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/RecognitionTransaction.jl` lines 822-1057; `julia/src/runtime/SemanticObservation.jl` lines 1-130; `julia/src/runtime/SourceLocation.jl` lines 1-646; `julia/src/runtime/StagedAstEnrichment.jl` lines 1-488
  Baseline evidence: 1500 fragments / 47696 bytes; ordered range SHA-256 `9dd223e7e32caf41690ace346aec1fa457dc7c035234cb3706d00c5d705a9cbd`.
  Activation commit: `7c856868b4e36eba189d7f41b37a6da295e98fff`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; existing recognition/typed-source/semantic-observation direct and generated-emitted/staged consumers; neutral typed/semantic/staged checks; corrected focused harness dependency order; prior-task/source/history preservation, Knowledge, memory, book and normal doctrines.
  Canonical trigger: `none` — ordinary source-reading evidence; no source, public contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes transaction commit/rollback/escape/discard, recursive effect fixed point, cursor-only progress and LIFO retirement. Semantic events are immutable scalar values with exact equality/hash; construction defers topology validation to derivation and final identity hashes input bytes. Source authority owns immutable decoded tables, guarded authority ids, exact codeunit/scalar conversion, same-source ordered spans, ordered derived materialization, detached records and92+7 projections. Staged prefix defines registry/cache/resource/context carriers, strict cost/cancel/clock/deadline safe points, copied errors, eager logical seed validation without factory invocation and fresh exact-key factory execution. Resolution/cache/stitching suffixes remain unread.
  Knowledge: Bounded docs/knowledge/julia-source-value-authority-reading.md preserves complete source/observation and authority-prefix comprehension, with a short pointer from the near-capacity typed rollout home. Recognition and staged current-depth facts record their precise source suffix/prefix. Historical counts, decoded-source preconditions and public semantic validation remain distinct.
  Findings: No new runtime defect or completed repair. Existing Julia .2.3 effects, .2.6 callback passthrough, .2.7 attempt preflight and startup .38 invalidation census remain open; passing finite consumers does not close them. Two missing focused-harness dependencies are corrected without changing test or production source.
  Verification: Seven untruncated windows cover1500 fragments /47696 baseline-identical bytes with ordered SHA9dd223e7e32caf41690ace346aec1fa457dc7c035234cb3706d00c5d705a9cbd. Complete saved focused recipe passes recognition207/typed127/observation66/routes51/staged491 (942 plus helper-selection1), including existing fresh emitted routes. Initial isolated routes had45 passes/6 errors from missing query digest helper; a separate retry lacked the direct-observation compile helper. The final complete dependency-order recipe passes and repeated assertions receive no additional credit. Neutral typed231, semantic6/20/128 at9/0 and6/0, and staged123/public129 pass. All jobs consumed; exact coverage/prior-node/source/history, Knowledge, memory, histories, rendered book and normal doctrines govern landing. No unread-source credit, full component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.20 - read source authorities and staged execution seeds`.

- ID: `JULIA-STARTUP-READING.1.21`
  Status: `done`
  Goal: Read bounded Julia group 21 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.20` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/StagedAstEnrichment.jl` lines 489-1988
  Baseline evidence: 1500 fragments / 56058 bytes; ordered range SHA-256 `38226654b3d608086ed3fc0bf96e8be319b6a987bb00fb43b4ec19cd1953652f`.
  Activation commit: `bd95e0fee7556b5e41d7899b7fcb437a2e3f0028`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; existing staged491 consumer and private registry/cache diagnostics; neutral pattern and staged/public checks; prior-task/source/history preservation, Knowledge, memory, book and normal doctrines.
  Canonical trigger: `none` — ordinary source-reading and repair intake; no source, public contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Owns copied finite acyclic data and canonical snapshot hashing with opaque callback normalization; freezes exact callback bindings and immutable logical collections. Pure alias/relative/root/provider selection precedes selected-top job identity; version/top/capability/policy intersections and minimum ceilings narrow authority. Cache retains callback plans under eight-field identity, not child results. Typed path/provenance ordering, bounded active-lineage extents, direct/derived source rebasing, plan preparation/cache and stitch-target preflight are read; settlement/scheduler suffix remains unread.
  Knowledge: Existing staged current-depth/recursive cards retain architecture and dated history. Bounded docs/knowledge/julia-staged-registry-pattern-boundaries.md owns full source-reading conclusions and exact diagnostic replay.
  Findings: New .2.13 owns trailing-LF admission, neutral-valid digit-component rejection and missing nondefault allowed-top validation. Six malformed host snapshots freeze and dispatch; four malformed cache fields hash. This is private registry/current-depth proof, not fresh authored/emitted malformed reproduction. All prior repairs remain open.
  Verification: Six untruncated windows cover1500 fragments /56058 baseline-identical bytes with ordered SHA38226654b3d608086ed3fc0bf96e8be319b6a987bb00fb43b4ec19cd1953652f. Existing staged491 plus Julia36 diagnostic assertions pass; neutral14 targeted and123/public129 governed mutations pass. Initial diagnostic callback used a raw Dict instead of the required success wrapper; corrected complete recipe passes with no repeated-assertion credit. Neutral harness wrapper/exception-class omissions are corrected in the saved recipe. All jobs consumed; exact coverage/prior-node/source/history, Knowledge, memory, histories, rendered book and all normal doctrines govern landing. No unread-source credit, full component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.21 - read staged resolution and own registry pattern validation`.

- ID: `JULIA-STARTUP-READING.1.22`
  Status: `done`
  Goal: Read bounded Julia group 22 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.21` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/StagedAstEnrichment.jl` lines 1989-2809; `julia/src/runtime/StagedParseJobDeclaration.jl` lines 1-336; `julia/src/runtime/UnicodeCaseMapping.jl` lines 1-343
  Baseline evidence: 1500 fragments / 49643 bytes; ordered range SHA-256 `6f963767f97a9b4d7cee21a930aec096d59bac417b13233e0408f4a500d30e24`.
  Activation commit: `7b70255e2986ff4e11c4f0c716adc7de84cafdf0`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; existing casing/typed/staged consumers and private diagnostic/call controls; neutral Unicode regeneration, typed and staged/public checks; prior-task/source/history preservation, Knowledge, memory, book and normal doctrines.
  Canonical trigger: `none` — ordinary reading and repair intake; no source, contract, data, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes duplicate/job/stitch-target reservation, finite acyclic detachment with marker-atomic node counts and deep live-key rejection, all settlement policies, copied child requests, expiring callback contexts and guarded call admission. Recursive execution budgets results/diagnostics, queues only detached returned markers by exact stitch destination and prepares each breadth-first depth; one-depth API remains distinct. Declaration validates exact direct/derived keys, live entry/local participating capture codeunit ranges through typed source authority and detached inert marker construction. Unicode17 metadata and lower mappings through U+042F include dotted-I expansion and identity entries; remaining table/evaluator unread.
  Knowledge: docs/knowledge/julia-staged-diagnostic-byte-boundaries.md preserves complete source conclusions, exact focused recipe, eleven resource controls and finite proof limits. Existing recursive/current-depth/marker and Unicode homes receive dated completion/prefix notes; Dart diagnostic policy owner records the separate Julia confirmation.
  Findings: Three private diagnostic-byte overruns now have .2.14 accounting/implementation/carrier owners coordinated with Dart .2.17.1. One-byte ceiling retains187 bytes;64 retains188, or375 across two siblings. Call counters reject both ordinary and maximum exhaustion before callbacks, with valid one-remaining controls. Existing .2.13 and all prior repairs remain open; no fresh malformed production-carrier proof is claimed.
  Verification: Six untruncated outputs cover1500 fragments /49643 baseline-identical bytes with ordered SHA6f963767f97a9b4d7cee21a930aec096d59bac417b13233e0408f4a500d30e24. Existing casing39/typed127/staged491 pass657 assertions plus selection1; diagnostic/call51 pass. Neutral Unicode regeneration preserves1563/1581 mappings,158/464 ranges,12 fixtures and every generated byte; typed231 and staged123/public129 pass. All jobs consumed; exact coverage/prior-node/source/history, Knowledge, memory, histories, rendered book and normal doctrines govern landing. No unread-source credit, full component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.22 - complete staged reading and own diagnostic byte retention`.

- ID: `JULIA-STARTUP-READING.1.23`
  Status: `done`
  Goal: Read bounded Julia group 23 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.22` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/UnicodeCaseMapping.jl` lines 344-1843
  Baseline evidence: 1500 fragments / 41147 bytes; ordered range SHA-256 `55d267826995d7ed9d00f3f55134f736b2dea43728218010b78f1233243efc6c`.
  Activation commit: `194265ff41c743b9dc195301445c7df35f49a7f3`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction and unchanged prior consumer identity; fresh neutral Unicode source-hash/regeneration/fixture proof; prior-task/source/history preservation, Knowledge, memory, book and all normal doctrines.
  Canonical trigger: `none` — ordinary generated-data reading; no source, data, public contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes lower mappings through U+1E921, including Cyrillic/Armenian/Georgian/Cherokee/Greek/Coptic, fullwidth and supplementary scalar ranges with retained identity rows. Reads upper table from ASCII through U+03B7, including sharp-s to SS, U+0149 to modifier apostrophe/N, U+01F0 to J/caron and Greek ordered combining expansions. Lower/upper tables are directional data, not inverses or normalization. Remaining upper mappings, properties and contextual evaluator remain unread.
  Knowledge: Existing docs/knowledge/dart-julia-unicode-17-case-mapping.md gains a dated bounded Julia completion/prefix record; prior generator/runtime and Dart evidence remain intact.
  Findings: No new defect or repair closure. Julia .2.1-.2.14 and all earlier owners remain pending; no fresh authored/generated/emitted or other-backend runtime proof is inferred from regeneration.
  Verification: Six untruncated250-line windows cover1500 fragments /41147 baseline-identical bytes with ordered SHA55d267826995d7ed9d00f3f55134f736b2dea43728218010b78f1233243efc6c and raw SHA2391125c2938a08870d0c764f6a73edeab0649ccfdd9adeb22f40992cb4db3ec. Fresh neutral Unicode checker validates pinned source hashes, all generated modules,1563/1581 mappings,158/464 property ranges and12 fixtures. Casing39 remains prior .1.22/194265ff4 proof against unchanged runtime/test source; no repeated runtime assertion credit. Exact coverage/prior-node/source/history, Knowledge, memory, histories, rendered book and normal doctrines govern landing. No unread-source credit, full component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.23 - read complete Unicode lower mappings and upper prefix`.

- ID: `JULIA-STARTUP-READING.1.24`
  Status: `done`
  Goal: Read bounded Julia group 24 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.23` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/UnicodeCaseMapping.jl` lines 1844-3343
  Baseline evidence: 1500 fragments / 41154 bytes; ordered range SHA-256 `e6e87e524024ec1138f9106dd805130466492085d4d0e2f60b5648ea3a54b8a9`.
  Activation commit: `c53cab85140692a0a494d7e3c7b99bffa237b882`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction and retained prior consumer identity; fresh neutral Unicode source-hash/regeneration/fixture proof; prior-task/source/history preservation, Knowledge, memory, book and normal doctrines.
  Canonical trigger: `none` — ordinary generated-data reading; no source, data, public contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes upper mappings through U+1E943, including both sigma forms to U+03A3, ordered Greek combining/iota expansions, Latin/Armenian ligatures, fullwidth and supplementary mappings. Reads all158 sorted inclusive cased-property ranges through U+1F189, then case-ignorable ranges through U+0605. Property membership is distinct from changing under upper/lower conversion; contextual evaluator and remaining ignorable ranges remain unread.
  Knowledge: Existing docs/knowledge/dart-julia-unicode-17-case-mapping.md gains a dated Julia upper/property record; earlier runtime/generator/Dart evidence is preserved.
  Findings: No new defect or repair closure. Julia .2.1-.2.14 and all prior owners remain pending; generated-data proof grants no new runtime or unread evaluator credit.
  Verification: Six untruncated250-line windows cover1500 fragments /41154 baseline-identical bytes with ordered SHAe6e87e524024ec1138f9106dd805130466492085d4d0e2f60b5648ea3a54b8a9 and raw SHA1a8b872ac6a9d952a1dedd9462ead2e1b83ea21836eb2fafaff861d5688ff997. Fresh neutral Unicode checker validates pinned source hashes, all generated modules,1563/1581 mappings,158/464 property ranges and12 fixtures. Casing39 remains .1.22/194265ff4 proof against unchanged source; no repeated runtime assertion credit. Exact coverage/prior-node/source/history, Knowledge, memory, histories, rendered book and normal doctrines govern landing. No full component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.24 - complete Unicode upper mappings and read property ranges`.

- ID: `JULIA-STARTUP-READING.1.25`
  Status: `done`
  Goal: Read bounded Julia group 25 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.24` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/UnicodeCaseMapping.jl` lines 3344-3832; `julia/src/semantic/SemanticCallProjection.jl` lines 1-1011
  Baseline evidence: 1500 fragments / 45333 bytes; ordered range SHA-256 `0d67f1cb35591030060caa6c2045c790da7b5cb4ff4e55c5936109a2dfceb2cb`.
  Activation commit: `f317c6cad543983f137d779e14ee20e88bfee225`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; fresh selected casing and six semantic source/outcome/static/call suites; neutral Unicode and semantic contracts; prior-task/source/history preservation, Knowledge, memory, book and normal doctrines.
  Canonical trigger: `none` — ordinary reading evidence; no source, data, public contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes464 case-ignorable ranges through U+E01EF and the binary-search/contextual evaluator. Final Sigma reads original code points, skips ignorable characters and requires preceding cased/no following cased character; full mapping expansions preserve order without host casing or normalization. Semantic prefix merges authored definitions; verifies native staged payload/job/signature against typed function ownership; validates retained generated plan identity/order/entry; emits deterministic outer-before-inner calls, occurrence-counted bindings and bounded shapes. User functions precede three governed helpers; child traversal covers aggregates, access/control nodes and mutation continuations, while callable literals remain deferred. Correlation/shape suffix remains unread.
  Knowledge: Append dated evidence to the existing Unicode, Julia call-plan and empty-function guard facts; prior historical and current repair evidence stays intact.
  Findings: The empty-function early return still precedes rule action traversal, preserving startup .22. No new defect, carrier admission or repair closure is claimed; finite projection tests do not close startup .22/.66/.67 or Julia .2.1-.2.14.
  Verification: Six untruncated windows cover1500 fragments /45333 baseline-identical bytes with ordered SHA0d67f1cb35591030060caa6c2045c790da7b5cb4ff4e55c5936109a2dfceb2cb. Raw Unicode suffix SHA872f4bc0fab0dbd27cf61880bbe9090fc54f9e5e4805096bde237d47d3ac736e; semantic prefix SHA91594bb5af8e2830d3095a4dd30026b6cefc5572953b17fefbcb1c21f8332249. Fresh Julia casing39 and semantic source135/outcome85/static70/remaining99/call79/staged62 pass (569 assertions plus selection1). Neutral Unicode preserves every generated byte,1563/1581 mappings,158/464 ranges and12 fixtures; semantic6/20/128 remains rollout9/0/admission6/0. Supporting diagnostic owner1105 reading receives no advance credit. Exact coverage/prior-node/source/history, Knowledge, memory, histories, rendered book and normal doctrines govern landing. No full component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.25 - complete Unicode evaluator and read semantic call projection`.

- ID: `JULIA-STARTUP-READING.1.26`
  Status: `done`
  Goal: Read bounded Julia group 26 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.25` committed; empty brief and clean repository.
  Scope: `julia/src/semantic/SemanticCallProjection.jl` lines 1012-1526; `julia/src/semantic/SemanticCompilationOutcome.jl` lines 1-472; `julia/src/semantic/SemanticIndex.jl` lines 1-513
  Baseline evidence: 1500 fragments / 51253 bytes; ordered range SHA-256 `f4210c34957b9291c52d017b260b35554056bfa7b40879e45602ce1ac9efe38b`.
  Activation commit: `0a7d2cdf26542c674831b988d1e774ef586bc37b`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; nine existing semantic source/outcome/static/call/query suites and twelve independent public-query/typed-runtime controls; neutral semantic contract; prior-task/source/history preservation, Knowledge, memory, book and normal doctrines.
  Canonical trigger: `none` — ordinary source-reading/defect-intake evidence; no source, public contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes typed action-owner count/contract checks, retained function-body reparse/normalization/equality and conservative fixed-point shapes. Function source uses a unique shell enclosing the exact staged body span. Call-site scanner balances parentheses and skips selected strings/regexes, but its regex-start exclusions cause confirmed wrong ownership. Compilation outcomes retain private parsed/validated/compiled state, native/fallback diagnostics and detached entry/generated-plan metadata; only fatal process exceptions rethrow. SemanticIndex copies strict UTF-8 text/bytes, applies source ceilings, hides ordinary properties, builds immutable byte/scalar/line/column maps and validates exact range boundaries. Options/source-integer/error-freezing suffix remains unread.
  Knowledge: New docs/knowledge/julia-semantic-regex-call-source-gap.md contains exact causal locations and full replay. Existing call-plan, semantic-authority and shared composite-gap facts gain dated evidence without replacing earlier observations.
  Findings: New .2.15.1/.2 own grouped/whitespace regex source correlation. Startup .67.2 additionally owns the confirmed null Julia aggregate binding source; array calls themselves are retained. Valid/arity-rejection/repeated-binding controls do not reproduce other specific Perl/Rust/Dart defects. Existing startup .22 and every earlier repair remain pending.
  Verification: Six untruncated windows read1500 fragments /51253 baseline-identical bytes, ordered SHAf4210c34957b9291c52d017b260b35554056bfa7b40879e45602ce1ac9efe38b. Raw ranges: call suffix61b8ecfa475aa072cfd5f8acaefed98baf6b23653d2eba4138ff202d0e589f23 (18864 bytes), outcome71d509a1df14d62a1397d4d56e47e7c9020935fecc2d8a596eb7ad622a68a7d2 (15063), indexe791be2dcbfa9db13fb4b107a965031e2a7cbfde5afa681dc4a823500815db1e (17326). Existing nine semantic suites pass1063; twelve public/typed/runtime controls pass92 assertions with three new miscorrelation cases, one existing aggregate-source defect and eight positive/rejection controls. Exact saved-fence replay preserves the result without duplicate credit. Neutral semantic6/20/128 remains rollout9/0/admission6/0. Exact coverage/prior-node/source/history, Knowledge, memory, histories, rendered book and normal doctrines govern landing. No full component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.26 - read semantic source authority and own regex call correlation`.

- ID: `JULIA-STARTUP-READING.1.27`
  Status: `done`
  Goal: Read bounded Julia group 27 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.26` committed; empty brief and clean repository.
  Scope: `julia/src/semantic/SemanticIndex.jl` lines 514-643; `julia/src/semantic/SemanticQuery.jl` lines 1-1370
  Baseline evidence: 1500 fragments / 52508 bytes; ordered range SHA-256 `7abb92b1c4c10d789dbe91f5a489f0c54e5d1e8e318a69e19c1ba7ae1fe8de15`.
  Activation commit: `7b43a264f2f71ca14059b134ff631a4e93c8b042`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; nine existing semantic suites; six Julia budget controls and full neutral-response comparison; neutral contract; prior-task/source/history preservation, Knowledge, memory, book and normal doctrines.
  Canonical trigger: `none` — ordinary source-reading/defect-intake evidence; no source, normative public contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes copied logical/entry validation, source-ceiling enforcement, Bool rejection and checked Int conversion, byte lookup and detached diagnostic conversion. Query prefix defines typed immutable requests/responses, separate object/array wrappers, exact raw request shape/order/numeric checks and one detached projection materialization. Kernel covers capabilities/list/get/relations/explain, primary-stream after-id paging, canonical filtered BFS, source redaction and logical emitted costs. Explain only applies record budget to steps; page budget flags the entire remaining stream before page selection, creating the confirmed shared inconsistencies. Final diagnostic/neutral normalization/freezing helpers remain unread.
  Knowledge: New docs/knowledge/semantic-query-budget-contract-gaps.md preserves exact six-case table, Julia26 assertions, full neutral equality and causal locations. Existing query kernel/traversal/public and semantic-authority facts gain dated evidence.
  Findings: Shared startup .82.1-.82.4 own budget contract/evaluator/native/transport correction; no assumption of fresh other-backend parity. The matching neutral oracle does not establish correctness. All Julia .2.1-.2.15, startup .22/.67 and prior repairs remain pending.
  Verification: Seven untruncated windows read1500 fragments /52508 baseline-identical bytes, ordered SHA7abb92b1c4c10d789dbe91f5a489f0c54e5d1e8e318a69e19c1ba7ae1fe8de15. Raw index suffix00f2dd2021226fff06bd6086e5b6bedf0342f4506f1ac3c39c6ab874bb761691 (4205 bytes); query prefix6e75bddd88ae790814eeb8bcbd09c63c647cba87baec278b66e96d390abe04d6 (48303). Nine existing suites pass1063; six public budget cases pass26 and match six complete neutral responses. Independent comparisons show two explain costs above maxima and one warning below record budget. Exact saved-fence replay grants no duplicate credit. Neutral semantic6/20/128 remains rollout9/0/admission6/0. The initial private loader harness required repository-derived absolute inputs and was corrected without a source change. Exact coverage/prior-node/source/history, Knowledge, memory, histories, rendered book and normal doctrines govern landing. No full component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.27 - read query policy and own shared budget contract gaps`.

- ID: `JULIA-STARTUP-READING.1.28`
  Status: `done`
  Goal: Read bounded Julia group 28 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.27` committed; empty brief and clean repository.
  Scope: `julia/src/semantic/SemanticQuery.jl` lines 1371-1587; `julia/src/semantic/SemanticRuntimeProjection.jl` lines 1-329; `julia/src/semantic/SemanticStaticProjection.jl` lines 1-954
  Baseline evidence: 1500 fragments / 51153 bytes; ordered range SHA-256 `d7d30edd5c05d59c1a8fe97eea8ec1067d24077c0cbcb85d4af6d19a8eb870c6`.
  Activation commit: `76a5299483e47b6494e8353c9b040b504be03760`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; eleven existing semantic source/outcome/static/call/query/observation suites; seven independent typed/runtime/public controls; neutral contract; prior-task/source/history preservation, Knowledge, memory, book and normal doctrines.
  Canonical trigger: `none` — ordinary source-reading/defect-intake evidence; no source, normative public contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes rejected-query envelopes, cursor freezing, raw/typed checked integer conversion and distinct immutable object/array conversion. Runtime derivation validates compiled/unobserved base, typed closed event topology, final entry/result and exact byte/hex input identity; source/shapes derive from retained static slots/edges/rules and produce a fresh frozen index without target execution. Static prefix builds compiled/failed graphs, preserves native/fallback diagnostics, correlates typed edge/lifecycle ownership and grouped authored members, and defines exact line ranges. Mixed slot filtering is incorrectly paired with an unfiltered compiled prefix; entry explanations depend on unrelated function/rule-count gates. Remaining static scanner/shape/canonicalization helpers are unread.
  Knowledge: New docs/knowledge/julia-semantic-static-correlation-gaps.md preserves all seven sources and67-assertion replay. Existing static-plan, observation-derivation, query-public and native-failure facts gain dated evidence without erasing earlier claims.
  Findings: New .2.16.1/.2 own mixed-slot correlation; .2.17.1/.2 own entry-explanation contract impact and implementation. Startup .23 receives positive Julia failure-class evidence, not closure. Shared .82, Julia .2.15 and every earlier repair remain pending. No other-backend, reconstructed/emitted or MCP recurrence is claimed.
  Verification: Seven untruncated windows read1500 fragments /51153 baseline-identical bytes, ordered SHAd7d30edd5c05d59c1a8fe97eea8ec1067d24077c0cbcb85d4af6d19a8eb870c6. Raw query suffix0e0e63c64166b1b5f9d7ec5386ab473a5eafd10d4bdb6c45cef8933dececb784 (6608 bytes), runtime0c7c4ffc995a93bfa380ce4cb25af704f761b7477b5fa5ea0dee46f6dfa87742 (11909), static prefix12abc5788001cfa8b7a248c6c3290359993f0bbe50d6d38bf3b7afe80a03e38d (32636). Eleven existing suites pass1286, including observation66/projection157; seven public/typed/runtime controls pass67 with three limitation cases and four comparisons. Exact saved-fence replay grants no duplicate credit. Neutral semantic6/20/128 remains rollout9/0/admission6/0. Exact coverage/prior-node/source/history, Knowledge, memory, histories, rendered book and normal doctrines govern landing. No full component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.28 - read semantic projections and own mixed slot and entry gaps`.

- ID: `JULIA-STARTUP-READING.1.29`
  Status: `done`
  Goal: Read bounded Julia group 29 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.28` committed; empty brief and clean repository.
  Scope: `julia/src/semantic/SemanticStaticProjection.jl` lines 955-1505; `julia/src/source/SourceEmitter.jl` lines 1-848; `julia/src/spec/Ast.jl` lines 1-101
  Baseline evidence: 1500 fragments / 50139 bytes; ordered range SHA-256 `4f5a83ded7635541cdcf772c884177b09886590a6743fbd52477d8107384d987`.
  Activation commit: `71328d860453dbeaab5c1cc4f4b02bfd15c741d7`.
  Verification tier: `focused`
  Focused checks: Exact source/range reconstruction; existing source emitter and four semantic source/outcome/static suites; seven independent typed/runtime/public selector controls; neutral semantic/generated contracts; prior-task/source/history preservation, Knowledge, memory, book and normal doctrines.
  Canonical trigger: `none` — ordinary source-reading evidence; no source, contract, format, infrastructure or dependency change.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Comprehension: Completes static member scanning, selector inference, entry explanations, bounded literal/container/callable shape inference, neutral modes, byte-safe source registration, canonical graph ordering, percent-escaped names and recursive frozen/detached storage. Full emitter validates contract before compiled state and plan, derives ten family policies, forwards invocation-local authorities/sinks, preserves selected callback/control failures and translates typed runtime errors. Effective ordered AST becomes canonical JSON and ASCII-hex payload/identity; emitted modules validate before reconstruction. Spec AST prefix defines line/byte spans, callable signatures and staged-job fields; constructor suffix remains unread.
  Knowledge: New docs/knowledge/julia-semantic-authored-selector-gap.md preserves seven exact sources and99 assertions; static-plan and generated-source-scaffold facts gain dated source/proof reconciliation.
  Findings: New .2.18.1/.2 owns typed authored selector identity and public recurrence. Three valid unindexed edges are reported as indexed because unrelated member text matches a target/index substring; four controls distinguish actual zero/nonzero and different-index spelling. Every prior Julia/shared/startup repair remains pending. No new counterpart, reconstructed/observed or MCP recurrence is claimed.
  Verification: Eight untruncated source windows read1500 fragments /50139 baseline-identical bytes, ordered SHA4f5a83ded7635541cdcf772c884177b09886590a6743fbd52477d8107384d987. Raw static suffix369402dcb0ed4b41c10b8b6aafb1761ccc8743263b3c7fc5501a659ac60aaedd (18320 bytes), emitter76828ce9b6ecfa995aace3e2e87620789d183bd0a24a005c97a505f22ad39567 (29367), AST prefix1ab4362f87bd954d111fdcbf01f610c38fde89eaaa5d36c939f5f66804a4a68a (2452). Existing emitter65 and source/outcome/static389 pass454; seven controls pass99 with exact typed selector, runtime, source span, public form/shape and relation checks. Neutral semantic6/20/128 stays rollout9/0/admission6/0; generated contract retains ten families/census100/0/0. Exact coverage/prior-node/source/history, Knowledge, memory, histories, rendered book and normal doctrines govern landing. No full component/canonical gate or dependency build.
  Commit: `JULIA-STARTUP-READING.1.29 - complete semantic and emitter reading and own selector projection`.

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
  Children: .2.1 callable-body selector validation; .2.2 attached-switch body/duplicate-default validation; .2.3 recognition-effect integration; .2.4 MCP pattern full matching; .2.5 progressive identity full matching; .2.6 semantic callback action passthrough; .2.7 recognition attempt preflight; .2.8 helper callback recursion identity; .2.9 numeric boundaries; .2.10 safe slice/drop arithmetic; .2.11 input_slice arity; .2.12 selected-slot mode preflight; .2.13 staged pattern validation; .2.14 diagnostic byte retention; .2.15 semantic regex call source; .2.16 mixed slot correlation; .2.17 conditional entry explanation; .2.18 authored edge selector identity. Nested authority and diagnostic review retain startup .37.1/.37.2. Prior README findings retain startup .41.2/.41.3/.41.7.
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

- ID: `JULIA-STARTUP-READING.2.7`
  Status: `pending`
  Goal: Validate recognition attempt authority before executing the child.
  Dependencies: Startup .3/.4/.5; .1.15 diagnostic intake.
  Evidence: Interpreter3856-3871 invokes the child before _runtime_recognition_attempt! looks up the token at1062 and RecognitionTransaction.attempt! checks its state. Missing tokens emit a child slot before recognition_token_expected; repeated attempts emit a second slot before recognition_attempt_count; post-commit attempts emit a second slot before recognition_token_expected. Four public native/generated-plan direct/traced routes agree.
  Children: .2.7.1 attempt preflight; .2.7.2 static-sequence and carrier recurrence.
  Acceptance: A missing, terminal or already-attempted token must not enter its requested child or emit that child's observations. Preserve valid falsey payloads, exactly one attempt, diagnostic precedence, existing rollback/unwind and no duplicate child execution. Effect closure .2.3 and startup .38 stale-snapshot restoration remain distinct owners.
  Verification: `pending` repair; docs/knowledge/julia-recognition-attempt-preflight-gap.md owns80 exact diagnostic assertions and the bounded source mechanism.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.7.1`
  Status: `pending`
  Goal: Move recognition attempt validation ahead of child dispatch without consuming authority twice.
  Dependencies: Startup .3/.4/.5; .1.15 committed; relevant source fully read.
  Acceptance: Design one private preflight/attempt protocol covering missing, active-unattempted, staged, terminal and wrong-owner tokens. Add RED/GREEN assertions of child non-entry and unchanged event/cursor/mark state for rejected attempts; preserve valid child match/miss/falsey commit and primary errors. Reconcile implicit action-edge child memoization before selecting the implementation.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.7.2`
  Status: `pending`
  Goal: Close authored token-sequence and supported-carrier claims after attempt preflight repair.
  Dependencies: .2.7.1; startup prerequisites.
  Acceptance: Reconcile the primary static linear-token requirement and defensive runtime checks for missing/repeated/post-terminal attempts. Verify native, reconstructed, generated-plan and fresh isolated emitted direct/traced routes, including action-edge calls and enabled observation/trace ordering. Retain neutral diagnostics and valid sequences; run designated canonical public/admission proof and update Knowledge/book without broadening transaction effects or changing terminal restoration ownership.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.8`
  Status: `pending`
  Goal: Keep callback recursion identity separate from helper names.
  Dependencies: Startup .3/.4/.5; .1.16 diagnostic intake.
  Evidence: Interpreter4750/4776 uses supplied name as active-codeblock identity; helper/receiver with passes with at5141/6039, and tree callbacks carry method at6080. Four distinct nested callback cases falsely reject; bound cb recursion through with reports with→with instead of cb→cb. Nine native/SpecFile-JSON controls pass84 assertions.
  Children: .2.8.1 callback identity repair; .2.8.2 supported-route and public recurrence.
  Acceptance: Distinct anonymous callbacks may nest without false recursion; a callback passed by variable retains its binding identity and true direct/mutual/helper-mediated recursion remains bounded with exact ordered diagnostics. Preserve dynamic scope, three-store restoration and separate map_leaves! receiver-write identities. Dart .2.10 is a separate backend owner; dated Lua behavior is comparison evidence only.
  Verification: `pending` repair; docs/knowledge/julia-callback-helper-recursion-identity-gap.md owns exact replay and limitations.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.8.1`
  Status: `pending`
  Goal: Repair helper/receiver/tree callback identities at the shared executor seam.
  Dependencies: Startup .3/.4/.5; .1.16 committed; relevant source fully read.
  Acceptance: Inventory anonymous, contextual, literal and bound-variable callback origins; preserve the originating binding identity through helper dispatch without assigning helper names to anonymous values. Add RED/GREEN same-helper/mixed-helper nesting and true direct/mutual/helper-mediated recursion controls, including copied/restored scopes after failure. Do not weaken recursion protection or receiver mutation guards.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.8.2`
  Status: `pending`
  Goal: Verify callback identity across supported carriers and reconcile public claims.
  Dependencies: .2.8.1; startup prerequisites.
  Acceptance: Exercise native, reconstructed, generated-plan and fresh isolated emitted direct/traced routes with exact values, ordered cycles, parameter restoration and unrelated effects. Keep final-block normalization, callable signatures, source formats and map_leaves! behavior unchanged; run designated canonical public/admission proof and update book/Knowledge before closure.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.9`
  Status: `pending`
  Goal: Preserve supported finite numeric magnitudes and reject arithmetic overflow coherently.
  Dependencies: Startup .3/.4/.5; .1.17 diagnostic intake; coordinate startup .20 and .55.
  Evidence: ActionParser494 parses integer literals directly as Int; Interpreter7527 normalizes integral results through Int, while numeric folds/abs use unchecked host integer operations. A large integer literal throws; equivalent finite Float64 survives directly but adding zero yields nothing; max-int addition wraps and abs(min-int) stays negative. Native/reconstructed controls agree; Perl Get preserves the tested magnitudes.
  Children: .2.9.1 boundary inventory; .2.9.2 numeric implementation; .2.9.3 supported-route/public recurrence.
  Acceptance: Separate authored literal parsing, arithmetic/result normalization and scalar-text spelling. Preserve valid finite values within the declared supported representation, small numeric results, null/nonfinite policy and negative zero; never silently wrap sign/magnitude. Do not promise arbitrary precision. Startup .55.2 owns portable decimal/scientific spelling and .20 owns Unicode-digit grammar.
  Verification: `pending` repair; docs/knowledge/julia-large-number-and-slice-boundaries.md owns exact paired controls.
  Additional evidence: Reading .1.18 measures _runtime_int at8996-9000: integral Float64 1e20 used as input_slice width or drop_front count throws InexactError before fallback. Existing .2.9.1/.2 retain generic conversion inventory and repair; startup .60.2 owns cross-backend count acceptance.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.9.1`
  Status: `pending`
  Goal: Inventory Julia numeric parsing/conversion/arithmetic and fix independent boundary expectations.
  Dependencies: Startup .3/.4/.5; .1.17 committed.
  Acceptance: Cover Int endpoints and adjacent supported floats, positive/negative large literals and strings, fractions, signed zero, invalid/nonfinite inputs and JSON round trips. Inventory folds, unary/modulo, reducers, scalar text and index/diagnostic consumers; distinguish measured failures from source-only risk. Reconcile ADR0029 and representation limits before changing the authority.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.9.2`
  Status: `pending`
  Goal: Repair numeric literal range handling, finite-result conversion and overflow arithmetic.
  Dependencies: .2.9.1; startup prerequisites.
  Acceptance: Add RED/GREEN tests preventing raw parser overflow, valid finite-result loss and wrapped addition/absolute value. Implement one coherent supported representation and explicit invalid-result policy; preserve neutral scalar semantics and avoid replacing wrapping with silent saturation. Keep slicing arithmetic under .2.10.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.9.3`
  Status: `pending`
  Goal: Close numeric carrier and public claims with declared precision/range.
  Dependencies: .2.9.2; startup .55.2 for any scalar-text spelling change.
  Acceptance: Verify native, reconstructed, generated-plan, fresh emitted and primary CLI cases with exact values/kinds, neutral numeric/text proof and cross-runtime recurrence. Document supported limits and remaining gaps without claiming arbitrary precision; run designated canonical public/admission proof.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.10`
  Status: `pending`
  Goal: Make Julia array/string range arithmetic safe at large valid counts.
  Dependencies: Startup .3/.4/.5; .1.17 diagnostic intake; coordinate startup .60.2.
  Evidence: Interpreter6863 adds count+1 before clipping in drop_front;6879/7114 add start+width before clipping in slice/substr. Int maximum wraps: drop_front throws BoundsError, while slice([1,2],1,max) returns [] and substr(ab,1,max) returns empty text. Perl Get returns [],[2],b respectively; ordinary count2 controls agree.
  Children: .2.10.1 range repair; .2.10.2 carrier/public recurrence.
  Acceptance: Bound counts before arithmetic/index construction, preserve zero-based starts, exact-end/beyond-end results, omitted counts, Unicode characters and source nonmutation. Inventory adjacent take/drop/slice helpers and integer conversion without silently saturating diagnostics; numeric representation remains .2.9.
  Verification: `pending` repair; exact paired replay lives in docs/knowledge/julia-large-number-and-slice-boundaries.md.
  Additional evidence: Reading .1.18 confirms typed input_slice clips width before addition at1420, preserving large-Int controls. Float-to-Int conversion remains .2.9; this positive typed route must remain intact.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.10.1`
  Status: `pending`
  Goal: Repair overflow-safe drop_front, array slice and substring bounds.
  Dependencies: Startup .3/.4/.5; .1.17 committed; related source fully read.
  Acceptance: Add RED/GREEN cases for ordinary/zero/omitted/negative/fractional counts, endpoint starts, Int endpoints and out-of-range numeric conversion. Clip or compare before addition, keep character-aware substring behavior, and prove helper/receiver source immutability. Retain exact errors where invalid values are contractually rejected.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.10.2`
  Status: `pending`
  Goal: Verify range behavior across Julia carriers and portable examples.
  Dependencies: .2.10.1; startup .60.2 equivalent-backend census.
  Acceptance: Run independent helper/receiver native/reconstructed/generated/emitted/CLI controls, including empty and Unicode inputs. Compare supported reference ranges, preserve all earlier numeric findings and update book/Knowledge with canonical public/admission proof before closure.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.11`
  Status: `pending`
  Goal: Enforce the documented two-argument input_slice signature before operand effects.
  Dependencies: Startup .3/.4/.5; .1.18 intake; coordinate Dart .2.15 and FUTURE-PARITY-BACKLOG.5.
  Evidence: Interpreter8183-8215 returns whole input for zero arguments, defaults one to the suffix and ignores operands after the second. ActionContracts995-1009 records counts without enforcing this signature. Native/reconstructed sources accept zero/one/three arguments and ignore an extra print. Perl Get leaves these malformed calls raw and reports late generated-handler failure. Exact controls: docs/knowledge/julia-input-slice-arity-and-count-boundaries.md.
  Children: .2.11.1 arity authority and repair; .2.11.2 carrier/public recurrence.
  Acceptance: Preserve input_text() and valid input_slice(start, length); reject malformed positional/keyword/block forms before effects with early structured diagnostics. Do not admit undocumented overloads or copy Perl's late error. Numeric conversion stays .2.9; safe typed integer clipping is separate from .2.10 array/string overflow.
  Verification: `pending` repair.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.11.1`
  Status: `pending`
  Goal: Repair Julia input_slice arity at the shared validation boundary.
  Dependencies: Startup prerequisites; .1.18 committed; coordinate Dart .2.15.1 reference/arity review.
  Acceptance: Inventory direct/helper/receiver and reconstructed call shapes. Add independent RED/GREEN zero/one/three/keyword/block cases and valid two-argument effect-order controls. Use one authority for compile and defensive runtime validation; coordinate reference late rejection with the existing helper-arity owner.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.11.2`
  Status: `pending`
  Goal: Prove input_slice arity through supported carriers and align public teaching.
  Dependencies: .2.11.1 and startup prerequisites.
  Acceptance: Verify native, reconstructed, generated-plan, fresh emitted and primary CLI positive/negative routes; preserve valid typed clipping and source-location results, run designated canonical public/admission proof and update book/Knowledge. Keep cross-backend count coercion under startup .60.2 rather than choosing a host fallback silently.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.12`
  Status: `pending`
  Goal: Validate selected-slot matching mode independently of regex success.
  Dependencies: Startup .3/.4/.5; .1.19 diagnostic intake.
  Evidence: Exported match_runtime_regex_slot in Matching175-205 matches first and returns nothing on miss before _normalize_parse_mode. Both scan and integer7 therefore reject for input x but silently miss for y with pattern x. Ordinary runtime_match rejects both inputs; four valid seek/consume controls remain correct. docs/knowledge/julia-selected-slot-mode-validation-gap.md preserves28 assertions.
  Children: .2.12.1 preflight repair; .2.12.2 direct-dependent/public proof.
  Acceptance: Invalid mode names/kinds fail before regex execution on every valid selected slot, preserving legitimate no-match, seek/consume behavior, authored slot identity and established index/cursor diagnostic precedence. This low-level matcher parameter is separate from the removed global engine/CLI parse mode.
  Verification: `pending` repair.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.12.1`
  Status: `pending`
  Goal: Normalize the low-level selected-slot mode before matching.
  Dependencies: Startup prerequisites and .1.19 committed.
  Acceptance: Add independent RED/GREEN invalid-name and invalid-kind hit/miss cases, empty input and valid-mode controls. Establish index/cursor precedence from existing matcher contracts, then reuse the shared normalizer before matching; preserve every valid regex and structural identity result.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.12.2`
  Status: `pending`
  Goal: Recur matching preflight and its callers without reintroducing global mode.
  Dependencies: .2.12.1 and startup prerequisites.
  Acceptance: Prove exported ordinary/selected matcher agreement, duplicate authored slots, compiled rule-local seek/consume callers and existing generated/emitted carriers. Reconcile matching documentation and tests; run designated canonical proof only where public/admission scope requires it. Keep the parser/CLI global mode removal intact.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.13`
  Status: `pending`
  Goal: Align staged registry and cache identity validation with the complete neutral patterns.
  Dependencies: Startup .3/.4/.5; .1.21 diagnostic intake.
  Evidence: StagedAstEnrichment619-626 uses dollar-anchored occursin, admitting trailing LF in parser/top/digest fields and rejecting neutral-valid digit-led components. Registry construction omits pattern checks for nondefault allowed tops. Six malformed snapshots freeze and dispatch; four malformed cache fields hash successfully. Exact36 Julia/14 neutral assertions live in docs/knowledge/julia-staged-registry-pattern-boundaries.md.
  Children: .2.13.1 pattern/all-top repair; .2.13.2 supported-boundary recurrence.
  Acceptance: Reject complete malformed identities and every invalid allowed top before callback execution while preserving neutral-valid digit components, valid selected defaults, deterministic identity/cache behavior and frozen caller authority. Do not conflate this private host boundary with MCP .2.4 or progressive .2.5.
  Verification: `pending` repair; no new authored or generated/emitted malformed reproduction claimed.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.13.1`
  Status: `pending`
  Goal: Use complete neutral-equivalent staged patterns and validate all allowed tops.
  Dependencies: Startup prerequisites and .1.21 committed.
  Acceptance: Add independent RED/GREEN trailing LF/CRLF, embedded newline, digit-led component, invalid nondefault top and valid identity/digest controls. Validate snapshot, direct resolution, options, job and cache boundaries at their owning diagnostics before callback execution. Preserve exact existing fixture digests and lookup ordering; no trimming or silent normalization of malformed fields.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.13.2`
  Status: `pending`
  Goal: Recur staged validation through supported host seed and runtime carriers.
  Dependencies: .2.13.1 and startup prerequisites.
  Acceptance: Prove private registry/cache/current-depth and fresh native/reconstructed/generated-plan/emitted seed rejection before callback entry, with exact neutral-valid identity controls. Census corresponding backend validators without assuming parity, route confirmed defects to owners, update public limitations and run designated canonical admission/public proof.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.14`
  Status: `pending`
  Goal: Enforce retained staged diagnostic byte ceilings including fallback and exhaustion.
  Dependencies: Startup .3/.4/.5; .1.22 diagnostic intake; coordinate Dart .2.17.1 and ADR0088.
  Evidence: StagedAstEnrichment2435-2462 measures a truncation sentinel but returns it without checking whether it fits. Allowances1/64 retain187/188 bytes; two64-byte siblings retain375 after the counter reaches zero. Existing491 assertions omit retained size. Exact51 diagnostic/call assertions live in docs/knowledge/julia-staged-diagnostic-byte-boundaries.md; maximum call exhaustion is a positive Julia control.
  Children: .2.14.1 shared accounting decision; .2.14.2 implementation; .2.14.3 supported-route/public proof.
  Acceptance: Bound actual retained diagnostics under an explicit accounting unit, preserve caller narrowing and useful governed context, and define behavior when the sentinel cannot fit. Never use a clamped remaining counter as proof of retained size. All source repairs retain startup gates.
  Verification: `pending` repair; private recursive-host proof only.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.14.1`
  Status: `pending`
  Goal: Reconcile Julia diagnostic accounting with the shared tiny-ceiling policy.
  Dependencies: Startup prerequisites; Dart .2.17.1 coordinates the shared contract decision.
  Acceptance: Fix the accounting unit and compatible treatment of required sentinel fields, initial tiny positive limits, exhausted cumulative allowance, lineage growth, sidecar copies and diagnostic-node policy. Preserve exact existing evidence; do not create a conflicting backend policy or silently exempt metadata. Route independently confirmed counterpart failures to owners.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.14.2`
  Status: `pending`
  Goal: Repair Julia fallback and cumulative diagnostic retention under the accepted byte contract.
  Dependencies: .2.14.1 and startup prerequisites.
  Acceptance: Add independent RED/GREEN canonical UTF-8 byte measurements for small/exact/large ceilings, multiple siblings/depths, non-ASCII diagnostics and growing chains. Check the chosen fallback before retention; ensure failure/keep_text/diagnostic_node obey the shared contract without exposing partial ASTs or resetting cumulative limits. Preserve guarded maximum-call admission.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.14.3`
  Status: `pending`
  Goal: Close Julia diagnostic budget proof across supported host seeds and carriers.
  Dependencies: .2.14.2 and startup prerequisites.
  Acceptance: Verify native, reconstructed, generated-plan and fresh emitted host seeds with independent retained-byte measurements and unchanged caller AST. Reconcile neutral/reference and existing staged suites, public budget claims and Knowledge; run designated canonical admission/public proof before closure.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.15`
  Status: `pending`
  Goal: Correlate semantic calls to their typed action source without regex-prefix decoys.
  Dependencies: Startup .3/.4/.5 and .1.26 diagnostic intake.
  Evidence: SemanticCallProjection1436-1447 rejects regex starts followed by parenthesis or whitespace. Public queries for /(trim(x))/, /(?:trim(x))/ and / trim(x)/ assign the matcher substring trim(x) to the real trim(" x ") call; /trim(x)/ is a positive control. The action-owner cursor scans the whole authored member. Exact twelve-control/92-assertion typed/runtime and public-query recurrence is in docs/knowledge/julia-semantic-regex-call-source-gap.md.
  Children: .2.15.1 implementation and independent correlation proof; .2.15.2 supported-route and public closeout.
  Acceptance: Derive call occurrences from typed/authored action boundaries or complete lexical state; exclude every matcher/string/comment decoy without breaking nested call order or scalar/byte coordinates. Preserve dated wrong-source evidence and existing fixture identities. No source repair before startup prerequisites.
  Verification: `pending` repair.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.15.1`
  Status: `pending`
  Goal: Repair Julia semantic call and binding source correlation.
  Dependencies: Startup prerequisites and .1.26 committed.
  Acceptance: Independent RED/GREEN queries compare actual typed RHS source with returned byte/scalar spans across grouped/noncapturing/whitespace/escaped/character-class regex starts, strings/comments, nested and repeated calls, functions and action/blind owners. Retain positive /trim(x)/ handling and reject ambiguous ownership; do not silently bless the observed matcher ranges.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.15.2`
  Status: `pending`
  Goal: Recur exact semantic source evidence through supported Julia carriers and transport.
  Dependencies: .2.15.1 and startup prerequisites.
  Acceptance: Verify native typed/raw-neutral queries, supported reconstructed/generated routes, source ceilings and MCP with independent authored-byte expectations. Census counterpart scanners without assumed parity; coordinate Dart .2.20 and startup .67. Update book/Knowledge and run designated canonical public proof before closing this repair.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.16`
  Status: `pending`
  Goal: Correlate mixed structural regex slots and cross-rule parent matchers without positional mismatch.
  Dependencies: Startup .3/.4/.5 and .1.28 diagnostic intake.
  Evidence: Top with /a/ -> Child before standalone /b/ compiles and executes to "a" but semantic_index rejects authored/compiled regex-slot identity. Reversing these members permits semantic construction. SemanticStaticProjection748-769 filters parent matchers from authored slots then compares retained slots against the unfiltered compiled.regex_patterns prefix.
  Children: .2.16.1 implementation and independent ordering proof; .2.16.2 supported-route/public proof.
  Acceptance: Correlate by actual typed slot ownership and preserve both authored identity and runtime index semantics. Do not delete compiler matcher evidence or adapt expected order to conceal the mismatch. Keep ordinary/duplicate/self-indexed and cross-rule cases correct.
  Verification: `pending` repair; exact .1.28 controls remain dated diagnostic evidence.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.16.1`
  Status: `pending`
  Goal: Repair mixed Julia static regex-slot source/identity correlation.
  Dependencies: Startup prerequisites and .1.28 committed.
  Acceptance: Add independent RED/GREEN parent-first/slot-first/interleaved/multiple-parent/duplicate-pattern/self-indexed controls, comparing authored ranges and typed compiled target indices with public semantic records/relations. Preserve runtime values and every existing fixture digest; split any required shared slot-contract decision before implementation.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.16.2`
  Status: `pending`
  Goal: Recur mixed-slot semantic construction through supported carriers and transport.
  Dependencies: .2.16.1 and startup prerequisites.
  Acceptance: Verify native typed/raw-neutral queries, supported reconstructed/generated/observed indexes and MCP with independent slot/source expectations. Census counterparts without assumed parity, update public/Knowledge evidence and run designated canonical admission/public proof before closure.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.17`
  Status: `pending`
  Goal: Make semantic entry-explanation availability independent of unrelated function and rule-count gates.
  Dependencies: Startup .3/.4/.5 and .1.28 diagnostic intake; coordinate startup .22 without conflating reverse guards.
  Evidence: SemanticStaticProjection399 gates entry explanation on an empty function list and more than one compiled rule. A two-rule source exposes an entry decision; prepending an unused function removes it. A single-rule source also has no entry decision despite retaining a selected entry.
  Children: .2.17.1 contract-impact audit and implementation; .2.17.2 supported-route/public proof.
  Acceptance: Preserve selected entry authority and exact truthful explanation for the agreed supported surface; audit frozen model/hash impact before removing fixture-shaped conditions. Document any deliberate contract boundary explicitly instead of leaving unrelated source shape to decide explainability.
  Verification: `pending` repair/contract reconciliation; no silent model expansion is authorized by the intake.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.17.1`
  Status: `pending`
  Goal: Audit and repair conditional Julia entry-explanation projection.
  Dependencies: Startup prerequisites and .1.28 committed.
  Acceptance: Freeze one-rule/multi-rule/unused-function/interleaved-function and explicit/default/marker selector expectations from real entry authority. Own any neutral model/hash migration separately before implementation; add independent RED/GREEN list/explain evidence and retain function-call/staged projection without adding fabricated decisions.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.17.2`
  Status: `pending`
  Goal: Close entry-explanation recurrence across supported semantic carriers and MCP.
  Dependencies: .2.17.1 and startup prerequisites.
  Acceptance: Recur exact entry decisions and source evidence through typed/raw-neutral queries, supported generated/reconstructed/observed and transport paths. Census counterparts, preserve budgets/privacy/immutability, update public limits and run designated canonical proof before declaring closure.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.18`
  Status: `pending`
  Goal: Derive semantic direct/indexed edge identity from the authored typed selector.
  Dependencies: Startup .3/.4/.5 and .1.29 diagnostic intake; coordinate .2.15/.2.16 without conflating different source-correlation failures.
  Evidence: SemanticStaticProjection886 and1046-1053 searches whole-member text for a target/index substring. A regex or action-string Child[0] can make an unindexed compiled edge project as indexed with regex_slot target shape and a selects_regex relation. Plain and actual numeric-selector controls distinguish spelling from resolved slot zero.
  Children: .2.18.1 typed selector/source projection repair; .2.18.2 supported-route/public proof.
  Acceptance: Preserve authored selector kind separately from resolved regex index; unrelated regex/action/comment text must not change edge form, target shape or relations. Keep compiler validation and exact source ranges; add independent RED/GREEN controls rather than accepting matching but wrong oracle responses.
  Verification: `pending` repair; native typed/public counterexamples established in .1.29.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.18.1`
  Status: `pending`
  Goal: Repair Julia semantic edge selector projection from typed authored ownership.
  Dependencies: Startup prerequisites and .1.29 committed.
  Acceptance: Cover plain unindexed, explicit zero/nonzero, named selectors, grouped/repeated targets and regex/action/comment/label-prefix decoys. Separate source identity from resolved index, preserve exact graph relations and keep malformed/out-of-range rejection. Review existing neutral fixtures before any necessary contract migration; do not silently re-bless metadata.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.2.18.2`
  Status: `pending`
  Goal: Close authored-selector recurrence across supported semantic routes and transport.
  Dependencies: .2.18.1 and startup prerequisites.
  Acceptance: Recur exact edge facts, target shapes, relations and spans through typed/raw-neutral queries and supported byte/text, generated/reconstructed/observed and MCP paths; census counterpart behavior under separate owners, preserve privacy/budgets/isolation, update the book and run designated canonical proof before closure.
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
| 1 | `JULIA-STARTUP-READING.1.30` | `pending` | Read spec/Ast102-909 and spec/Parser1-692 after clean .1.29; reconcile focused proof and preserve repairs. |

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

- `2026-09-11` .1.29: Julia .1.29 completes SemanticStaticProjection and SourceEmitter and reads spec/Ast1-101: 29/52 groups, 41,925 fragments /1,469,930 bytes and thirty-seven complete files. Fresh emitter65/semantic389 and seven selector controls99 assertions pass. Regex/action/label-substring decoys make typed unindexed edges report indexed metadata and selects_regex relations; Julia .2.18 owns typed projection and supported-route/public repair. Both neutral semantic6/20/128 and generated-source checks pass. All prior repairs, source, history and ADR0115 controls remain. Julia .1.30 is next; no full component/canonical gate or dependency build.

- `2026-09-11` .1.28: Julia .1.28 completes SemanticQuery and SemanticRuntimeProjection and reads SemanticStaticProjection1-954: 28/52 groups, 40,425 fragments /1,419,791 bytes and thirty-five complete files. Fresh semantic1,286 and diagnostic67 assertions pass. Valid mixed parent/structural slot order can reject semantic construction; single-rule or unused-function sources omit entry explanations. Julia .2.16/.2.17 own separate implementation and public proof. Missing-rule and out-of-range-slot diagnostics remain distinct under startup .23. Neutral semantic6/20/128 passes. All prior repairs, source, history and ADR0115 controls remain. Julia .1.29 is next; no full component/canonical gate or dependency build.

- `2026-09-11` .1.27: Julia .1.27 completes SemanticIndex and reads SemanticQuery1-1370: 27/52 groups, 38,925 fragments /1,368,638 bytes and thirty-three complete files. Fresh semantic1,063 and budget26 assertions pass; six full Julia/neutral responses agree while exposing explain relation/depth overruns and a premature page-budget warning. Shared startup .82.1-.82.4 own contract expectations, neutral repair, bounded backend implementation and transport/public proof. Neutral semantic6/20/128 passes. All prior repairs, source, history and ADR0115 controls remain. Julia .1.28 is next; no full component/canonical gate or dependency build.

- `2026-09-11` .1.26: Julia .1.26 completes SemanticCallProjection and SemanticCompilationOutcome and reads SemanticIndex1-513: 26/52 groups, 37,425 fragments /1,316,130 bytes and thirty-two complete files. Fresh semantic1,063 and diagnostic92 assertions pass; three public queries cite grouped/whitespace matcher text for real action calls. New Julia .2.15 owns source correlation; startup .67.2 retains the null aggregate binding source despite correct Julia array-call traversal. Neutral semantic6/20/128 passes. All prior repairs, source, history and ADR0115 controls remain. Julia .1.27 is next; no full component/canonical gate or dependency build.

- `2026-09-11` .1.25: Julia .1.25 completes UnicodeCaseMapping and reads SemanticCallProjection1-1011: 25/52 groups, 35,925 fragments /1,264,877 bytes and thirty complete files. Final Sigma uses original code points and generated properties; call projection retains typed ownership, staged authority and deterministic call/binding evidence. Fresh casing39 plus semantic530 assertions pass, alongside Unicode regeneration and semantic6/20/128. The unchanged empty-function guard remains startup .22-owned; all prior repairs, source, history and ADR0115 controls remain. Julia .1.26 is next; no full component/canonical gate or dependency build.

- `2026-09-11` .1.24: Julia .1.24 reads UnicodeCaseMapping1844-3343: 24/52 groups, 34,425 fragments /1,219,544 bytes and twenty-nine complete files. Both mapping tables and all158 cased ranges are read; case-ignorable ranges reach U+0605. Fresh Unicode regeneration preserves1563/1581 mappings,158/464 ranges,12 fixtures and every generated byte. Julia casing39 remains .1.22/194265ff4 evidence against unchanged source. No new defect or repair closure; all prior repairs, source, history and ADR0115 controls remain. Julia .1.25 is next; no full component/canonical gate or dependency build.

- `2026-09-11` .1.23: Julia .1.23 reads UnicodeCaseMapping344-1843: 23/52 groups, 32,925 fragments /1,178,390 bytes and twenty-nine complete files. Lower mappings are fully read through U+1E921; upper mappings reach U+03B7. Fresh neutral regeneration preserves1563/1581 mappings,158/464 property ranges,12 fixtures and every generated byte. Julia casing39 remains .1.22/194265ff4 evidence against unchanged source. No new defect or repair closure; all prior repairs, source, history and ADR0115 controls remain. Julia .1.24 is next; no full component/canonical gate or dependency build.

- `2026-09-11` .1.22: Julia .1.22 completes StagedAstEnrichment/Declaration and reads UnicodeCaseMapping1-343: 22/52 groups, 31,425 fragments /1,137,243 bytes and twenty-nine complete files. Existing casing39/typed127/staged491 assertions pass657 plus selection1; private diagnostic/call51 and neutral Unicode/typed231/staged123/public129 checks pass. Three diagnostic-byte overruns now have .2.14 repair ownership coordinated with Dart .2.17.1; maximum call exhaustion correctly rejects. All prior repairs, source, history and ADR0115 controls remain. Julia .1.23 is next; no full component/canonical gate or dependency build.

- `2026-09-11` .1.21: Julia .1.21 reads StagedAstEnrichment489-1988: 21/52 groups, 29,925 fragments /1,087,600 bytes and twenty-seven complete files. Existing staged491, diagnostic Julia36/neutral14 and neutral123/public129 checks pass. Registry/cache patterns admit trailing LF, reject valid digit-led parser components and omit nondefault top validation; .2.13 owns repair. No source or prior repair changes; history and ADR0115 controls remain. Julia .1.22 is next; no full component/canonical gate or dependency build.

- `2026-09-11` .1.20: Julia .1.20 completes RecognitionTransaction, SemanticObservation and SourceLocation and reads StagedAstEnrichment1-488: 20/52 groups, 28,425 fragments /1,031,542 bytes and twenty-seven complete files. Existing recognition207/typed127/observation66/routes51/staged491 assertions pass (942 plus helper-selection1); neutral typed231, semantic6/20/128 and staged123/public129 pass. Two isolated-harness omissions are corrected by the saved complete dependency-order recipe. No new defect is established; all prior repairs, source, history and ADR0115 controls remain. Julia .1.21 is next; no full component/canonical gate or dependency build.
- `2026-09-11` .1.19: Julia .1.19 completes Interpreter and Matching and reads RecognitionTransaction1-821: 19/52 groups, 26,925 fragments /983,846 bytes and twenty-four complete files. Existing matching60/diagnostics7/slots121/recognition207/gap319 assertions pass (714 plus selection1); low-level selected-slot mode diagnostic28 isolates miss-before-validation. New .2.12 owns mode preflight; startup .38 retains transaction misuse census despite the positive Julia invalidation guard. Neutral recognition138/250/58 and gap63/public34 pass. All prior repairs, source, history and ADR0115 controls remain. Julia .1.20 is next; no full component/canonical gate or dependency build.
- `2026-09-11` .1.18: Julia .1.18 reads Interpreter7616-9115: 18/52 groups, 25,425 fragments /937,035 bytes and twenty-two complete files. Existing core4/capture2/scope3/cursor17/marks13/diagnostic82/logical232/typed127/write406 assertions pass (886 plus selection1); slice diagnostics pass174 Julia and44 Perl assertions. Typed integer clipping is correct; new .2.11 owns input_slice arity, .2.9 retains float conversion and startup .60.2 owns measured reference count fallbacks. Neutral logical26/typed231/write105 mutations pass. All prior repairs, source, history and ADR0115 controls remain. Julia .1.19 is next; no full component/canonical gate or dependency build.
- `2026-09-11` .1.17: Julia .1.17 reads Interpreter6116-7615: 17/52 groups, 23,925 fragments /889,323 bytes and twenty-two complete files. Existing scalar-text5/numeric4/string-numeric14/array2/hash1/tree2/uniform61/mutation496 assertions pass (585 plus selection1); numeric/range diagnostics pass128 Julia and64 Perl assertions. New .2.9/.2.10 own finite-number loss/wrapping and unsafe range arithmetic; startup .55.2/.60.2 retain cross-backend coordination. Neutral numeric55/18 and uniform11/7/6/8 pass. All prior repairs, source, history and ADR0115 controls remain. Julia .1.18 is next; no full component/canonical gate or dependency build.
- `2026-09-11` .1.16: Julia .1.16 reads Interpreter4616-6115: 16/52 groups, 22,425 fragments /841,618 bytes and twenty-two complete files. Existing array2/hash1/function9/tree2/callable125/contextual118/construction239/mutation496 assertions pass (992 plus selection1); nine native/reconstructed callback cases pass84 diagnostic assertions. New .2.8.1/.2.8.2 own false helper-name recursion and lost bound callback identity. Neutral callable23, mutation167+592 and write105 checks pass. All prior repairs, source, history and ADR0115 controls remain. Julia .1.17 is next; no full component/canonical gate or dependency build.
- `2026-09-11` .1.15: Julia .1.15 reads Interpreter3116-4615: 15/52 groups, 20,925 fragments /794,451 bytes and twenty-two complete files. Existing marker1/control6/function9/cursor17/progressive62/staged491/recognition207 assertions pass (793 plus selection1); token preflight diagnostic80 proves child execution before missing/repeated/post-commit rejection across four public routes. Neutral progressive116/public60, staged123/public129 and recognition138/250/58 pass. New .2.7.1/.2.7.2 own preflight and static-sequence/carrier recurrence; all prior repairs, source, history and ADR0115 controls remain. Julia .1.16 is next; no full component/canonical gate or dependency build.
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

- `.1.29`: `JULIA-STARTUP-READING.1.29 - complete semantic and emitter reading and own selector projection`.

- `.1.28`: `JULIA-STARTUP-READING.1.28 - read semantic projections and own mixed slot and entry gaps`.

- `.1.27`: `JULIA-STARTUP-READING.1.27 - read query policy and own shared budget contract gaps`.

- `.1.26`: `JULIA-STARTUP-READING.1.26 - read semantic source authority and own regex call correlation`.

- `.1.25`: `JULIA-STARTUP-READING.1.25 - complete Unicode evaluator and read semantic call projection`.

- `2026-09-11` .1.20: `JULIA-STARTUP-READING.1.20 - read source authorities and staged execution seeds`.
- `2026-09-11` .1.19: `JULIA-STARTUP-READING.1.19 - complete matching reading and own selected-slot mode validation`.
- `2026-09-11` .1.18: `JULIA-STARTUP-READING.1.18 - read capture and storage boundaries and own input slice arity`.
- `2026-09-11` .1.17: `JULIA-STARTUP-READING.1.17 - read helper boundaries and own numeric and range repairs`.
- `2026-09-11` .1.16: `JULIA-STARTUP-READING.1.16 - read callable execution and own callback identity repair`.
- `2026-09-11` .1.15: `JULIA-STARTUP-READING.1.15 - read control dispatch and own token preflight repair`.
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

- `2026-09-11`: Completed .1.29 from clean 71328d860; static/emitter source read, authored selector repair .2.18 owned, all previous evidence preserved and .1.30 next.

- `2026-09-11`: Completed .1.28 from clean 76a52994; query/observation projection and static prefix read, .2.16/.2.17 repair-owned, startup .23 evidence preserved and .1.29 next.

- `2026-09-11`: Completed .1.27 from clean 7b43a264; query reading and paired budget evidence open shared startup .82, preserve all prior source/repairs and route .1.28.

- `2026-09-11`: Completed .1.26 from clean 0a7d2cdf; semantic outcome/source reading and exact query diagnostics own .2.15, extend startup .67.2 and route .1.27 without source repairs.

- `2026-09-11`: Completed .1.25 from clean f317c6ca; Unicode evaluator and semantic prefix read,569 existing assertions pass, all repairs preserved and .1.26 next.

- `2026-09-11` .1.20: Completes transaction/source/event authorities, reads staged seed prefix and preserves exact focused harness dependencies; all repairs stay open.
- `2026-09-11` .1.19: Completes interpreter/matching reading, owns selected-slot mode preflight and preserves authority-prefix comprehension with prior repairs intact.
- `2026-09-11` .1.18: Reads capture/storage boundaries, owns input_slice arity and extends conversion/reference-count review; preserves correct typed integer clipping.
- `2026-09-11` .1.17: Reads helper boundaries, owns separate numeric/range repairs and reconciles current split teaching; all prior repairs remain open.
- `2026-09-11` .1.16: Reads callable/scope/mutation/fluent execution and owns helper callback recursion identity repair; prior defects remain open.
- `2026-09-11` .1.15: Reads value/control/helper dispatch and owns recognition-token preflight repair; earlier defects remain open.
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
