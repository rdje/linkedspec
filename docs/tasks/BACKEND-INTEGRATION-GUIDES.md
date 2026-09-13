# BACKEND-INTEGRATION-GUIDES: Embed LinkedSpec in an application

## Metadata

- Tree ID: `BACKEND-INTEGRATION-GUIDES`
- Status: `active` / director-authorized temporary documentation activity
- Roadmap lane: `Phase 6 documentation and adoption / native backend integration`
- Created: `2026-09-13`
- Last updated: `2026-09-13`
- Owner: repo-local workflow
- Intake owner: `CONFORMANCE-SOURCE-READING.1.34`

## Goal

Give a new application author a verified path from a pinned LinkedSpec submodule
to native parsing, useful results and handled errors, for Perl, Rust, Dart, Julia
and Lua. The director identified the missing onboarding story while considering
ARCHOGEN's use of Lispish through Rust. The requested scope is every backend.

## Deliverables and shared acceptance

- One discoverable common integration entry and five backend-specific guides,
  with complete runnable consumer examples and exact prerequisites.
- Show submodule addition, recursive initialization, version pinning and deliberate
  update procedures. Distinguish checkout from dependency preparation and execution.
- Explain the minimum required modules/packages/native products for the chosen
  backend. Separate initial setup from routine builds and dependency updates.
  Retain compatible RGX/PGEN products; do not require rebuilding unrelated backends.
- Resolve paths from the consumer repository at runtime. Keep its package stores,
  caches, build output, temporary fixtures and logs on its own filesystem volume.
- Use native APIs inside the host process. Show grammar loading or embedding,
  compilation lifetime, direct result values, domain-model conversion, diagnostics
  and errors. Explain any legacy accumulator wrapper explicitly.
- Package required grammars/runtime/native libraries so deployment does not depend
  on the developer checkout or working directory. Qualify supported platforms and
  ABIs from actual evidence; do not infer them from README claims.
- Use a small common neutral grammar for comparable onboarding examples. Include
  a Rust Lispish example relevant to ARCHOGEN, with explicit head/tail output and
  documented input-consumption, quoting and multi-form limits. No Lispish semantics
  change or ARCHOGEN application implementation is implied by this documentation.
- Verify each documented command and example from a managed consumer workspace,
  including an outside-cwd or relocation check and an ordinary error case. Initial
  preparation and a repeat run must report their actual dependency/build reuse.
  A pre-populated development checkout alone is not fresh-clone proof.
- Keep one canonical source for each topic, following ADR0040. Reuse the content
  routing inventory from BACKEND-COMPANION-BOOKS where available. Link the existing
  book and backend landing pages; keep README.md bounded. Do not create competing
  integration prose or populate companion scaffolds before their governance exists.
- Record the selected verification tier at activation. Focused proof governs
  ordinary guide/example leaves; infrastructure changes and final public closeout
  retain canonical CI. Commit each leaf and clear the brief before the next.

## Task Tree

- ID: `BACKEND-INTEGRATION-GUIDES`
  Status: `active`
  Goal: Deliver tested native integration guidance for all five backends.
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`
  Acceptance: Every shared criterion has backend-specific evidence; navigation, examples and limits agree.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.0`
  Status: `done`
  Activation commit: `00f9783a1e4b625bc251a3e260ef1eef60c35888`.
  Verification tier: `focused`
  Focused checks: Canonical Knowledge and exact five-backend metadata/API/setup inventory; bounded content routing, example plan and dependency reuse evidence; source and prior task preservation, book render, memory/history and all normal doctrines.
  Canonical trigger: Read-only inventory and documentation planning; no runtime, dependency, workflow or public contract change. Final guide activity .7 retains canonical closeout.
  Goal: Inventory existing integration APIs, setup commands, content owners and consumer requirements.
  Dependencies: CONFORMANCE-SOURCE-READING.1.34 committed clean. The director explicitly authorizes this temporary documentation activity before the remaining startup reading; this scoped exception does not close that reading or unrelated runtime repairs.
  Scope: Existing Knowledge, native loader/API book pages, five backend manifests/landing pages, wrappers, ADR0040 and BACKEND-COMPANION-BOOKS inventory; no dependency build.
  Acceptance: Publish an exact per-backend dependency/runtime/API/error/packaging matrix and canonical page/example destinations. Identify reusable proof and missing proof, including Rust bootstrap/reuse and declared toolchain discrepancies. Give any newly confirmed defect its own repair leaf before implementation. Refine an oversized child before activation.
  Verification: PASS17 baseline-identical metadata/API/setup sources; six complete wrappers513 lines; version-only commands exit0 for Cargo1.95.0,Dart3.13.3,Julia1.12.7,Perl5.34.1,Lua5.5.1,LuaJIT2.1.1788460057 and three pkg-config identities. No consumer execution, dependency preparation or build. Focused source/task/history preservation, memory, book and normal doctrines govern this inventory; .7 retains canonical closeout.
  Outcome: docs/knowledge/backend-integration-inventory.md defines the five-path matrix and exact six book/example destinations. ADR0040 routing keeps current normative chapters intact and requires later companion governance before migration. Startup .80/.41.7 and Lua .2.2/.2.3 remain owned. Rust-first implementation is the next selected leaf; the return point remains conformance .1.35.
  Candidate proof: Preserve2497 prior files byte-exact,2799 of2801 prior task nodes,all94 book limitation headings,previous reading checkpoints and historical recipes. Only this root and .0 node change. Rendered inventory/return text passes; memory60 passes; both histories are OK at210 lines/42693 bytes and168/41728. Whitespace is clean; the known large book search-index warning remains owned. No guide or consumer build is claimed. Normal doctrines and post-commit pointer check remain required.
  Commit: `BACKEND-INTEGRATION-GUIDES.0 - inventory native integration setup and guide ownership`

- ID: `BACKEND-INTEGRATION-GUIDES.1`
  Status: `pending`
  Goal: Deliver the Perl integration guide and executable consumer.
  Children: `.1.1`, `.1.2`
  Dependencies: `.0`
  Acceptance: Perl setup, native use, packaging, error and reuse examples satisfy the shared criteria.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.1.1`
  Status: `pending`
  Goal: Document and verify Perl checkout, module search path, managed setup and native parsing.
  Acceptance: A consumer loads the intended modules and grammar explicitly, compiles once, parses two independent inputs and checks exact direct values. Identify core versus optional Perl dependencies and portable loader versus legacy discovery; no accidental ambient module path.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.1.2`
  Status: `pending`
  Goal: Verify Perl deployment, structured failures and diagnostic-sink examples.
  Dependencies: `.1.1`
  Acceptance: Relocated/outside-cwd use preserves module and grammar resolution; missing grammar and malformed input produce documented outcomes; runtime data remain consumer-local. Generated source dependencies are explicit if taught.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.2`
  Status: `pending`
  Goal: Deliver the Rust integration guide with the ARCHOGEN-relevant Lispish example.
  Children: `.2.1`, `.2.2`
  Dependencies: `.0`; coordinate existing startup .80 dependency-reuse and .41.7 toolchain/guide repairs.
  Acceptance: Cargo, initial preparation, direct values, Lispish adaptation, packaging and repeat-run evidence satisfy the shared criteria.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.2.1`
  Status: `pending`
  Goal: Document and verify recursive checkout, Cargo path dependencies, required PGEN preparation and native Rust parsing.
  Acceptance: Check the chosen pin's declared toolchain and locked consumer resolution; generate only missing required parser inputs, preserve compatible dependency products, and verify a repeat consumer run. The example uses the full native loading pipeline and direct-value API. No separate Perl or CLI process parses the application input.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.2.2`
  Status: `pending`
  Goal: Add tested Lispish result adaptation, error handling and Rust deployment guidance.
  Dependencies: `.2.1`
  Acceptance: Demonstrate nested/empty forms, atom/string representation, comments and malformed-input outcomes. State and test complete-input and multiple-top-level-form behavior without importing a Perl-only finding as a Rust result. Package or embed the grammar, verify outside-cwd use and preserve consumer-local caches/artifacts.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.3`
  Status: `pending`
  Goal: Deliver the Dart integration guide and executable consumer.
  Children: `.3.1`, `.3.2`
  Dependencies: `.0`
  Acceptance: Package wiring, native requirements, direct values, deployment and errors satisfy the shared criteria.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.3.1`
  Status: `pending`
  Goal: Verify Dart local package dependency, SDK/native prerequisites and in-process parsing.
  Acceptance: A managed consumer resolves its package cache locally, loads or embeds the grammar, reuses the compiled parser and asserts exact direct values. Required native-library discovery and supported target evidence are explicit.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.3.2`
  Status: `pending`
  Goal: Verify Dart grammar/native-library packaging and diagnostic/error handling.
  Dependencies: `.3.1`
  Acceptance: Outside-cwd execution works with packaged assets; missing-source and parse/runtime errors match the documented API. Unsupported deployment surfaces are qualified without speculative claims; ordinary repeat runs reuse compatible preparation.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.4`
  Status: `pending`
  Goal: Deliver the Julia integration guide and executable consumer.
  Children: `.4.1`, `.4.2`
  Dependencies: `.0`
  Acceptance: Project/module wiring, depot/native requirements, direct values, deployment and errors satisfy the shared criteria.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.4.1`
  Status: `pending`
  Goal: Verify Julia project activation, local module/package setup, depot placement and native parsing.
  Acceptance: A consumer follows the actual supported package/module surface, prepares required products once, loads the grammar and reuses the engine for exact independent results. No implicit home depot or unrelated dependency rebuild.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.4.2`
  Status: `pending`
  Goal: Verify Julia deployment, compilation/cache expectations and typed failure handling.
  Dependencies: `.4.1`
  Acceptance: Relocated/outside-cwd execution finds its grammar and required libraries; errors and diagnostics match the guide. Distinguish initial package preparation, Julia compilation and ordinary parser execution using measured repeat-run evidence.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.5`
  Status: `pending`
  Goal: Deliver Lua integration guidance for the supported PUC Lua and LuaJIT routes.
  Children: `.5.1`, `.5.2`
  Dependencies: `.0`; preserve LUA-STARTUP-READING.2.3 exclusions and missing-ABI proof boundaries.
  Acceptance: Module/native-library paths, exact ABI preparation, values and deployment satisfy the shared criteria without extending unverified host claims.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.5.1`
  Status: `pending`
  Goal: Verify Lua module search paths, ABI-specific native products and native parsing.
  Acceptance: Separate PUC Lua/LuaJIT setup and product compatibility; exercise the full staged loader with explicit module/library paths and exact direct values. Initial preparation is separate from repeated engine use; no excluded unfiltered runtime gate.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.5.2`
  Status: `pending`
  Goal: Verify Lua deployment, value conversion, structured errors and optional diagnostic sinks.
  Dependencies: `.5.1`
  Acceptance: Outside-cwd examples locate packaged grammar/modules/libraries; failure examples and nil/array conventions are accurate. Document only ABI routes actually verified and keep missing proof visibly owned.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.6`
  Status: `pending`
  Goal: Connect the common integration entry, all five guides and the executable example checks.
  Dependencies: `.1.1-.5.2`
  Acceptance: Book/backend landing navigation is complete with one canonical owner per topic; the common example produces equivalent direct values on verified runtime routes. Add only meaningful example checks; classify any workflow/governance infrastructure changes as canonical before editing them.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.7`
  Status: `pending`
  Goal: Independently verify and close the complete integration documentation delivery.
  Dependencies: `.6`
  Acceptance: Replay documented setup/use/deployment/error paths from managed consumer workspaces, consume all job outcomes, render affected books, verify links and evidence limits, run required canonical CI, and close all verified parent nodes. Commit cleanly before the final push boundary; no pending backend may be counted complete.
  Verification: `pending`
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `BACKEND-INTEGRATION-GUIDES.2.1` | `pending` | Rust-first guide and consumer from the completed five-backend inventory; preserve preparation/reuse boundaries. Return to conformance .1.35 after the full activity. |

The director explicitly requests a temporary pivot at the next clean handoff.
Conformance .1.34 is committed at 00f9783a1 and inventory .0 is complete.
Activate Rust .2.1 next and deliver this activity. Ordinary guide/example work needs no further permission.

Return point: `CONFORMANCE-SOURCE-READING.1.35`, whose unchanged Scope is
`t/generated_source_contract.t` lines154-506; `t/inspect_spec_codegen.t` lines1-121;
`t/inter_match_gap_capture_perl_contract.t` lines1-1026. The completed reading
commit is identified by subject `CONFORMANCE-SOURCE-READING.1.34` in Git history.
Resume that reading leaf only after integration .7 commits a clean handoff.
Remaining source reading, formal book/policy work and runtime repairs are retained,
not declared complete by this scoped documentation authorization.

## Decisions and existing obligations

- `2026-09-13`: The director requests integration documentation for every backend,
  prompted by ARCHOGEN. Native APIs and verified consumer setup are the product path.
- Existing companion-book architecture remains ADR0040; this delivery supplies
  integration content to its eventual owner, with links instead of duplicated text.
- Dependency reuse, declared Rust toolchain mismatch, Lua ABI proof gaps and
  historical Lispish limits keep their existing repair owners and evidence dates.
- No application repository, dependency pin or runtime is changed by this intake.

## Verification Log

- `2026-09-13` .0: PASS17 baseline-identical metadata/API/setup sources; six complete wrappers513 lines; version-only commands exit0 for Cargo1.95.0,Dart3.13.3,Julia1.12.7,Perl5.34.1,Lua5.5.1,LuaJIT2.1.1788460057 and three pkg-config identities. No consumer execution, dependency preparation or build. Focused source/task/history preservation, memory, book and normal doctrines govern this inventory; .7 retains canonical closeout.

- `2026-09-13`: Intake reads native Rust/Lispish and dependency authorities plus
  ADR0040 and the companion tree. Guide/example implementation and consumer proof
  are pending. CONFORMANCE-SOURCE-READING.1.34 owns intake validation and commit.

## Commit Log

- `.0`: `BACKEND-INTEGRATION-GUIDES.0 - inventory native integration setup and guide ownership`; activation 00f9783a1e4b625bc251a3e260ef1eef60c35888; next .2.1 after clean handoff.
- Intake: `CONFORMANCE-SOURCE-READING.1.34`; derive its commit from Git history.
- Guide/example leaves: pending.

## Changelog

- `2026-09-13` .0: Complete five-backend setup/API/content-routing inventory; choose Rust-first implementation and preserve the conformance return point.
- `2026-09-13`: Track the director-requested five-backend integration guides,
  consumer examples, dependency reuse, deployment/error proof and canonical closeout.
