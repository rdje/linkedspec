# JULIA-STARTUP-READING: Bounded Julia reading and repair ownership

## Metadata

- Tree ID: `JULIA-STARTUP-READING`
- Status: `active` / reading 3/52; callable-selector repair pending
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
- Current physical reading: 3/52 children, 4,071/75,984 lines and 145,809/2,693,170 bytes; seven complete files.
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
  Verification: Julia .1.3 completes ActionAst and reads ActionContracts through 766: 3/52 groups, 4,071 fragments /145,809 bytes and seven complete files. Twenty causal controls prove callable bodies bypass retired array/hash selector validation across native, reconstructed, generated-plan and in-process emitted-module routes; .2.1.1/.2.1.2 own repair. Existing uniform-binding 61 and projection/alias 8 pass without closing the gap. All source bytes and prior repairs remain. Julia .1.4 is next, with .4 capacity intake before history rollover.
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
  Status: `pending`
  Goal: Read bounded Julia group 4 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.3` committed; empty brief and clean repository.
  Scope: `julia/src/action/ActionContracts.jl` lines 767-1128; `julia/src/action/ActionParser.jl` lines 1-1138
  Baseline evidence: 1500 fragments / 51329 bytes; ordered range SHA-256 `f843c537312ac86af4aa48af1c6b5a1019a10e24c11db64c325fcf6afea3a0e7`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.5`
  Status: `pending`
  Goal: Read bounded Julia group 5 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.4` committed; empty brief and clean repository.
  Scope: `julia/src/action/ActionParser.jl` lines 1139-2276; `julia/src/action/CallableContract.jl` lines 1-268; `julia/src/action/FunctionRegistry.jl` lines 1-94
  Baseline evidence: 1500 fragments / 51510 bytes; ordered range SHA-256 `f2c058898ca5dacca8b16509e0c906c61ed94924ae42a18ada83cfe5b57b6d63`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.6`
  Status: `pending`
  Goal: Read bounded Julia group 6 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.5` committed; empty brief and clean repository.
  Scope: `julia/src/action/FunctionRegistry.jl` lines 95-235; `julia/src/cli/LinkedSpecJuliaCli.jl` lines 1-838; `julia/src/compiler/CompiledSpec.jl` lines 1-521
  Baseline evidence: 1500 fragments / 47482 bytes; ordered range SHA-256 `28d2afda026ea2191355ea3ed8b2370f8e836bdb953834a27427696514ebbdda`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.7`
  Status: `pending`
  Goal: Read bounded Julia group 7 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.6` committed; empty brief and clean repository.
  Scope: `julia/src/compiler/CompiledSpec.jl` lines 522-1860; `julia/src/corpus/CorpusManifest.jl` lines 1-161
  Baseline evidence: 1500 fragments / 57108 bytes; ordered range SHA-256 `5699c12ffd786ae5a813d86ae2696b2f6d5114967e496777f49b02c002aaa89e`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.8`
  Status: `pending`
  Goal: Read bounded Julia group 8 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.7` committed; empty brief and clean repository.
  Scope: `julia/src/corpus/CorpusManifest.jl` lines 162-626; `julia/src/io/SpecLoader.jl` lines 1-387; `julia/src/mcp/McpContract.jl` lines 1-372
  Baseline evidence: 1224 fragments / 65496 bytes; ordered range SHA-256 `80857a09d16e202d83c90ff1a21e51c5bdf6b61782a137ad946c3cdcad39c136`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.9`
  Status: `pending`
  Goal: Read bounded Julia group 9 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.8` committed; empty brief and clean repository.
  Scope: `julia/src/mcp/McpContract.jl` lines 373-1002
  Baseline evidence: 630 fragments / 65520 bytes; ordered range SHA-256 `3f731f7393feeb143ccc65d4a2407e10e0d5cb9cb8f102834a0761b27479ec84`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.10`
  Status: `pending`
  Goal: Read bounded Julia group 10 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.9` committed; empty brief and clean repository.
  Scope: `julia/src/mcp/McpContract.jl` lines 1003-1159; `julia/src/mcp/McpContractRuntime.jl` lines 1-462; `julia/src/mcp/McpServer.jl` lines 1-826; `julia/src/mcp/McpWire.jl` lines 1-55
  Baseline evidence: 1500 fragments / 65039 bytes; ordered range SHA-256 `7d5bde5484ffd4f8d8785281363543a87af6ec9580aa0797c2f429dbe69edd48`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.11`
  Status: `pending`
  Goal: Read bounded Julia group 11 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.10` committed; empty brief and clean repository.
  Scope: `julia/src/mcp/McpWire.jl` lines 56-672; `julia/src/parser/StagedParserRegistry.jl` lines 1-652; `julia/src/parser/UserFunctionDefinitionParser.jl` lines 1-231
  Baseline evidence: 1500 fragments / 52503 bytes; ordered range SHA-256 `9b0a9a06f22ffcbadc1d8f64cae7112375a32605cf4b9df3c38c6b9a1add0ed5`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.12`
  Status: `pending`
  Goal: Read bounded Julia group 12 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.11` committed; empty brief and clean repository.
  Scope: `julia/src/parser/UserFunctionDefinitionParser.jl` lines 232-249; `julia/src/runtime/BoundedChildParseAuthority.jl` lines 1-1367; `julia/src/runtime/Interpreter.jl` lines 1-115
  Baseline evidence: 1500 fragments / 45686 bytes; ordered range SHA-256 `36214acfe302f4b357bf9eb244fdbd0c49c1fa3cb930def44c6d7386505c5d43`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.13`
  Status: `pending`
  Goal: Read bounded Julia group 13 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.12` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 116-1615
  Baseline evidence: 1500 fragments / 46530 bytes; ordered range SHA-256 `16a40fcfac63e5a0917aeb1e75e49a62f54cb5b4fcfa2c89d9081c297b0eb344`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.1.14`
  Status: `pending`
  Goal: Read bounded Julia group 14 and reconcile its source evidence.
  Dependencies: `JULIA-STARTUP-READING.1.13` committed; empty brief and clean repository.
  Scope: `julia/src/runtime/Interpreter.jl` lines 1616-3115
  Baseline evidence: 1500 fragments / 49525 bytes; ordered range SHA-256 `0914279799290aee44fe36a02242403bdd98e702c3a897550583ad732459d8bf`.
  Acceptance: Physically read every owned byte, inspect current deltas, reconcile Knowledge and own confirmed repairs; record comprehension and relevant focused proof before commit. Do not count truncated output or unread consumer suffixes.
  Verification: `pending`
  Commit: `pending`

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
  Children: .2.1 (callable-body selector validation); prior README findings retain startup .41.2/.41.3/.41.7.
  Verification: `pending` repair; .1.3 confirms the callable-body gap and routes two bounded repair children. Earlier documentation and helper-arity owners remain intact.
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

- ID: `JULIA-STARTUP-READING.3`
  Status: `pending`
  Goal: Independently close Julia reading and route Lua startup reading.
  Dependencies: Every .1 child committed and every finding repair-owned.
  Acceptance: Independently verify exact baseline/current coverage, comprehension, unique child commits and activation boundaries; preserve all repairs, close only .1/startup .3.5 and route startup .3.6 Lua decomposition.
  Verification: `pending`; canonical milestone proof remains required unless separately authorized otherwise. ADR0114 is Dart-only.
  Commit: `pending`

- ID: `JULIA-STARTUP-READING.4`
  Status: `active`
  Goal: Resolve evidence or history capacity before it blocks a safely committed Julia slice.
  Dependencies: Fresh resulting-tree/mandatory-rollover projection and clean prior reading checkpoint.
  Acceptance: Preserve existing evidence and all limits; route changing detail to its canonical owner. If a capacity increase is actually required, prepare exact old/new controls, source and immutable-history preservation proof, finite projected need and the required director decision before infrastructure implementation. Current history collections have no free member slots; no later archive slot is preapproved.
  Children: .4.1 prepares the proposal; pending LIVE-DOCUMENT-PRESSURE-CONTAINMENT.12 owns exact implementation/admission. Resume .1.4 only after that clean boundary.
  Verification: `pending` capacity decision; exact proposal and independent models are committed by .4.1. No allowance or future canonical exception is assumed.
  Commit: `pending`

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
| 1 | `LIVE-DOCUMENT-PRESSURE-CONTAINMENT.12` | `pending` | Await the exact capacity and one-time verification decision; no registry change before authorization. Julia .1.4 follows its clean admission. |

## Decisions

- `2026-09-11`: Prepare one finite remaining-Julia allowance, with all other ceilings unchanged; record the proposed verification exception before asking. Earlier waivers do not extend automatically.
- `2026-09-11`: Keep Julia execution evidence in this separate bounded member; the startup file has insufficient room for the full plan. No aggregate/member/control change.
- `2026-09-11`: Use52 exact groups with per-child source digests; store source identities in Git and scopes here rather than duplicating an unbounded inventory.

## Open Questions

- None for source ownership. Future history capacity belongs to .4 and has no automatic increase authorization.

## Blockers

- `2026-09-11`: Pending .12 needs the six exact capacity controls and explicit proposed one-time canonical-receipt boundary. After this intake CHANGES is 455 lines; the next ordinary seven-line reading record would require a disallowed archive.
- None for the first reading group at decomposition. Later mandatory rollovers require .4 before exceeding unchanged history limits.
- Source repairs retain startup prerequisites; those dependencies do not block source reading.

## Verification Log

- `2026-09-11` .4.1: Julia reading remains 3/52 groups, 4,071 fragments /145,809 bytes and seven complete files. Julia .4.1 prepares four extra archive slots per history for the remaining reading/closeout envelope; six proposed controls leave root, segment and aggregate limits unchanged. Independent models agree on eight rollovers and preserve all history. Pending containment .12 owns implementation and its requested one-time canonical exception; approval is not assumed. Julia .1.4 waits behind that decision. The callable selector gap and all prior repairs remain open.
- `2026-09-11` .1.3: Julia .1.3 completes ActionAst and reads ActionContracts through 766: 3/52 groups, 4,071 fragments /145,809 bytes and seven complete files. Twenty causal controls prove callable bodies bypass retired array/hash selector validation across native, reconstructed, generated-plan and in-process emitted-module routes; .2.1.1/.2.1.2 own repair. Existing uniform-binding 61 and projection/alias 8 pass without closing the gap. All source bytes and prior repairs remain. Julia .1.4 is next, with .4 capacity intake before history rollover.
- `2026-09-11` .1.2: Julia .1.2 finishes README, both command delegates and the facade, and reads ActionAst through line 964: 2/52 groups, 2,571 fragments /104,408 bytes and six complete files. All 452 public names are defined; both CLI help paths, 55 punctuation assertions and neutral 6/4/6 pass. The existing missing-needle contains defect remains under backlog .5; startup .41.7 owns the remaining bare README commands. Sources, Dart failures and all repairs stay unchanged. Julia .1.3 is next; .4 owns future capacity pressure.
- `2026-09-11` .1.1: Julia .1.1 completes the manifests and README lines 1–963: 1/52 groups, 1,071 fragments / 65,410 bytes and two complete files. Seven exact README examples and the primary JSON example pass on Julia 1.12.7; semantic governance remains 6/20/128, rollout 9/9 and admission 6/6. Existing startup .41.2/.41.3/.41.7 own the stale status and unmanaged-command guidance. All sources, prior repairs and Dart gate failures remain unchanged. Julia .1.2 is next; .4 owns future capacity pressure.
- `2026-09-11`: Startup .3.5.0 independently reconstructs all 95 baseline-identical paths,52 groups,146 ranges and every byte once; all child bounds/digests pass. No physical-reading credit.

## Commit Log

- .4.1: `JULIA-STARTUP-READING.4.1 - prepare finite history capacity and verification decision`.
- .1.3: `JULIA-STARTUP-READING.1.3 - read action projection and own callable selector gap`.
- .1.2: `JULIA-STARTUP-READING.1.2 - read facade and typed action model`.
- .1.1: `JULIA-STARTUP-READING.1.1 - read package manifests and README examples`.
- Decomposition: `SESSION-STARTUP-READING.3.5.0 - freeze exact bounded Julia reading plan`.

## Changelog

- `2026-09-11`: .4.1 prepares the exact proposal and routes pending containment .12; no capacity or source change.
- `2026-09-11`: .1.3 completes the third reading group and owns the confirmed callable-body selector defect under .2.1.
- `2026-09-11`: .1.2 completes six files cumulatively and the first typed ActionAst range; prior repairs remain pending.
- `2026-09-11`: .1.1 closes the first exact source-reading group and routes existing public-teaching repairs.
- `2026-09-11`: Created bounded Julia reading ownership with 52 pending source children and explicit repair, closeout and capacity owners.
