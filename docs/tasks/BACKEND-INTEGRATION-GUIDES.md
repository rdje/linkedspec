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
  Retain compatible RGX/PGEN products; normal Cargo rebuilds are authorized by the September13 director update. Do not require building unrelated backends.
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
  preparation and a repeat run must report their actual dependency/build reuse or rebuilds.
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
  Status: `done`
  Goal: Deliver the Rust integration guide with the ARCHOGEN-relevant Lispish example.
  Children: `.2.1`, `.2.2`
  Dependencies: `.0`; coordinate existing startup .80 dependency-reuse and .41.7 toolchain/guide repairs.
  Acceptance: Cargo, initial preparation, direct values, Lispish adaptation, packaging and repeat-run evidence satisfy the shared criteria.
  Verification: PASS three Rust adapter tests; 34 native Lispish probes and nine exact Perl comparisons; maintained verifier's18 same-engine file values plus published settings, structured grammar/runtime failures, I/O/UTF-8/usage checks, earlier-output behavior and packaged/relocated outside-cwd execution. Clean-source bootstrap creates12 generated files/18576534 bytes including four Rust parsers. The200-package consumer lock preserves every version; isolated locked/offline builds complete in40.50s and4.87s, both reporting dependency compilation. Original checkout build4m34s and test build6m37s also pass. Pins and original PGEN full-index diff remain exact. Focused render/preservation/doctrine proof and receipt-bound canonical CI govern landing; no release-profile, empty-cache installation, all-backend malformed-input or actual ARCHOGEN application proof is claimed.
  Commit: `BACKEND-INTEGRATION-GUIDES.2.2 - deliver Rust Lispish file integration and deployment`

- ID: `BACKEND-INTEGRATION-GUIDES.2.1`
  Status: `done`
  Activation commit: `4d32e895e08a9b1784f5ebcc384c72f577799338`.
  Verification tier: `canonical`
  Focused checks: Offline locked Cargo resolution/build and native consumer runs, reference grammar values, repeated Cargo run with actual freshness evidence, mdBook render, memory/history and normal doctrines.
  Canonical trigger: examples/integration/rust/Cargo.lock matches the registered dependency-infrastructure path rule. The first focused commit attempt was rejected by VERIFICATION-CADENCE before any commit; eight other doctrines passed. Upgrade this candidate to canonical and require the exact staged tools/run_ci_local.sh receipt. No gate bypass or dependency source/pin change; final .7 remains canonical.
  Direct-dependent scope: The new guide links the parse-mode-named cursor chapter and therefore joins the existing public documentation migration inventory. Register exactly this new path and its count, plus matching current census markers in the contract/checker and documentation. Preserve every behavioral/rollout/mutation field and dated history; update canonical Knowledge. The failed canonical run supplies the exact unowned-path reproduction. Keep the stable task-index marker and its closed-capability validator's census constant synchronized; preserve its location, eight families, twelve markers and fifteen consumers.
  Director update (2026-09-13): The director cancels the RGX/PGEN no-rebuild requirement and explicitly authorizes normal builds again. Cargo may rebuild either dependency whenever its ordinary checks request it. Retain caches and avoid gratuitous cleaning, but do not use a rejecting compiler guard or require startup .80 repair to continue this guide.
  Director delivery update: The director needs the complete Rust/Lispish file-integration document for another Rust project and requests a git push when it is ready, rather than a link. This leaf records that instruction; .2.2 owns completing and verifying that delivery, including clean pinned-source preparation, then the early clean push before other backend guides.
  Additional inventory scope: The third canonical attempt reaches the mutation public-surface check and fails at expected63/observed64 public Markdown files. This leaf owns identifying the exact added path, updating only the checker census and current references, and preserving all three frozen semantic authorities, fourteen governed documents, eleven example classes, ten stale-claim denials and fifty mutations. Verify the remaining documentation contracts before restarting canonical CI; this maintenance adds no startup source-reading credit.
  Remaining-check scope: Focused preflight also exposes the selector-public inventory's expected62/observed63 count for the same new book page. Own its census correction and current references here. Exact discovery then finds35 selector mentions: the original32 plus three in the existing Julia callable-validation limitation added by6308ff4e24. One fenced invalid example lacks classification context. Preserve the full example and open Julia repair, add an explicit invalid/retired label inside its fence, and reconcile32->35 classified references. Preserve zero current examples, five ordered migration contrasts, eleven contrast mutations and all composed runtime/source/capability checks.
  Goal: Document and verify recursive checkout, Cargo path dependencies, required PGEN preparation and native Rust parsing.
  Acceptance: Check the chosen pin's declared toolchain and locked consumer resolution; generate only missing required parser inputs, retain dependency products while permitting normal Cargo rebuilds, and verify a repeat consumer run. The example uses the full native loading pipeline and direct-value API. No separate Perl or CLI process parses the application input.
  Verification: PASS offline locked 200-package resolution with every manifest under the repository; Rust1.95.0 builds in3m12s and4m02s, both compiling PGEN/RGX/core/runtime/example. Two native four-value runs match the independent four-value Perl oracle; four usage/non-UTF-8 rejections exit1 with empty stdout. Rustfmt passes. Present generated EBNF/regex sources were retained; no fresh-clone/bootstrap proof is claimed. The new consumer Cargo.lock requires canonical tier; exact staged receipt-bound CI governs this commit. Earlier guard rejection and unsuccessful retained-library link are diagnostic failures, superseded by the successful normal Cargo builds.
  Inventory proof: The first canonical attempt stops at exactly one new unowned guide path. Registering that path and current census74->75 passes36 family spellings,18 edges,8 parent/child cases,30 public documents,28 forbidden claims and60 mutations. Exact JSON normalization proves every non-census field unchanged; dated ADR0067 stays exact. The stable-marker guard also passes8 families,12 markers,15 consumers and4 mutations after its one-literal census update. This delta does not advance startup source-reading coverage.
  Remaining public proof: PASS mutation64 files/14 documents/11 examples/10 denials/50 mutations; selector63 files/35 classified references/zero current examples/5 contrasts/11 mutations; composed source discovery and capability100/0/0. Exact comparison preserves the three frozen mutation authorities, all classifier/mutation logic and the entire known Julia example except its explicit invalid/retired comment. Generated-source, native-resolution and language-coverage checks also pass. Canonical attempt3's runtime results are partial evidence, not a completed gate or receipt.
  Candidate proof: Preserve2575 prior files byte-exact,2793 of2801 task nodes,seventeen fact cards' historical recipes and all94 book limitation headings. Only the Rust parent/native leaf, director-refined pending Lispish delivery and five explicitly updated startup .80 nodes change. Book render/includes and whitespace pass; both histories remain below rollover thresholds, with every prior record and trailing byte preserved. Normal memory/doctrine and post-commit pointer verification remain required.
  Commit: `BACKEND-INTEGRATION-GUIDES.2.1 - document and verify native Rust integration`

- ID: `BACKEND-INTEGRATION-GUIDES.2.2`
  Status: `done`
  Activation commit: `42490a9d917ec7e30d2703f0695aa6c225f49a5b`.
  Verification tier: `canonical`
  Focused checks: Native Rust Lispish values and independent-input reuse; UTF-8 file consumer and explicit domain adaptation; structured failures; pinned-source preparation with consumer-local stores; packaged grammar and outside-cwd/relocation runs; Rust formatting, book rendering, source/task/history preservation and all normal doctrines.
  Canonical trigger: Complete the Rust integration parent and the director-requested early push boundary. Consumer dependency-manifest/lock changes also require an exact staged canonical receipt. Preserve existing nested PGEN edits and dependency pins; use clean committed sources for preparation proof.
  Scope: Extend the existing Rust guide and runnable consumer with Lispish files, typed result adaptation, exact failure/consumption evidence and deployment. Verify and correct the initial bootstrap recipe against the pinned build sources, including its target-directory assumptions. Link the Rust landing page to its completed guide. No unrelated runtime change or other backend implementation belongs to this leaf.
  Initial native evidence: The 34 bounded prepared-checkout probes in .linkedspec-data/scratch/backend-integration22/native-results.jsonl reproduce the documented nested/head-tail values. Rust returns the first form for leading/trailing text and multiple forms, null for missing closing parentheses, and an exit_now error for a leading unmatched close. An unterminated double quote can still yield an atom; empty square brackets disappear; a comment without its required newline can become content. These are observed outcomes, not whole-file validation guarantees. Trace/descriptor diagnosis and durable classification remain required before guide completion. Quoted backslash output also needs an exact native/reference comparison before any preservation claim.
  Comparison and follow-up ownership: All nine independently compared Perl/Rust values agree, including exact escaped-string codepoints; capture, join_values and cat controls preserve those same bytes. No Rust escaping defect was found. LinkedSpec::Get descriptors show seek/default-scan policy; generated source shows first-child return at line82 and no-match null paths at lines55/132. This leaf now owns registering the already-described historical grammar follow-ons as pending SESSION-STARTUP-READING.83.1-.83.3 (contract, implementation, independent admission), without pivoting or changing the shipped grammar. Integration documentation must expose the limitation; it cannot count strict document parsing as delivered.
  Candidate proof: PASS2792 prior files byte-exact,2798 of2801 prior task nodes and all94 existing book limitation headings. Only this Rust parent/leaf and the startup root change; four new pending .83 nodes own the grammar follow-up. Every earlier change/notes/history byte and historical integration discussion is preserved. Rendered source/sample includes resolve. Existing word consumer still returns four exact values and rejects four bad argument cases. All nine doctrines and memory pass before staging; both histories remain below rollover thresholds. The exact staged canonical receipt and post-commit pointer check remain required. The evidence-gate card is additionally updated by the staged correction below.
  Staged evidence-format correction: Canonical attempt1 stops at TASK-ACCEPTANCE because the Rust landing path is governed and check_diagnosis_evidence.sh rejects the literal word pending on any checked-label line, including historical checklists in the same file. Wrap the retained repair qualifications onto continuation lines; every word, repair status and acceptance obligation remains unchanged. Update the existing evidence-gate Knowledge card, rerun the exact staged check and all doctrines, then restart canonical CI. This is evidence formatting, not a runtime repair or gate change.
  Goal: Add tested Lispish result adaptation, error handling and Rust deployment guidance.
  Dependencies: `.2.1`
  Acceptance: Demonstrate nested/empty forms, atom/string representation, comments and malformed-input outcomes. State and test complete-input and multiple-top-level-form behavior without importing a Perl-only finding as a Rust result. Package or embed the grammar, verify outside-cwd use and preserve consumer-local caches/artifacts.
  Director delivery: Provide the complete submodule-to-build-to-native-file-parsing path for a separate Rust application using specs/Lispish.spec. Verify preparation from recursively pinned source and actual UTF-8 file input, then commit and push this Rust checkpoint after exact canonical proof. Notify the director of the pushed commit; no link-only handoff. Continue other backend guides afterward.
  Verification: PASS three Rust adapter tests; 34 native Lispish probes and nine exact Perl comparisons; maintained verifier's18 same-engine file values plus published settings, structured grammar/runtime failures, I/O/UTF-8/usage checks, earlier-output behavior and packaged/relocated outside-cwd execution. Clean-source bootstrap creates12 generated files/18576534 bytes including four Rust parsers. The200-package consumer lock preserves every version; isolated locked/offline builds complete in40.50s and4.87s, both reporting dependency compilation. Original checkout build4m34s and test build6m37s also pass. Pins and original PGEN full-index diff remain exact. Focused render/preservation/doctrine proof and receipt-bound canonical CI govern landing; no release-profile, empty-cache installation, all-backend malformed-input or actual ARCHOGEN application proof is claimed.
  Commit: `BACKEND-INTEGRATION-GUIDES.2.2 - deliver Rust Lispish file integration and deployment`

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
| 1 | `BACKEND-INTEGRATION-GUIDES.1.1` | `pending` | First push the completed Rust checkpoint from a verified clean tree, then Perl setup/native parsing. Other guides and .7 remain required before returning to conformance .1.35. |

The director explicitly requests a temporary pivot at the next clean handoff.
Conformance .1.34 is committed at 00f9783a1 and inventory .0 is complete.
Rust .2.1 is committed at42490a9d9 with canonical CI PASS, both CLI66/66 and Phase0 1032/1032; its brief is empty and its root handoff is clean. Lispish/deployment .2.2 completes from that boundary; its exact staged canonical receipt and clean push remain the delivery boundary. Ordinary guide/example work needs no further permission.

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
- `2026-09-13`: Complete and verify Rust/Lispish first, including files and clean
  pinned-source preparation, then push that checkpoint and notify the director.
  This explicitly authorizes an early push before the other backend guides and .7.
- Existing companion-book architecture remains ADR0040; this delivery supplies
  integration content to its eventual owner, with links instead of duplicated text.
- Dependency reuse, declared Rust toolchain mismatch, Lua ABI proof gaps and
  historical Lispish limits keep their existing repair owners and evidence dates.
- No application repository, dependency pin or runtime is changed by this intake.

## Acceptance Checklist — .2.1

- [x] **REPRODUCE / ISSUE** — Cursor discovery reports unowned integration-rust.md; canonical attempt3 reports mutation expected63/observed64; selector preflight reports expected62/observed63 and one unclassified existing Julia example. Native consumer values independently pass.
- [x] **ROOT CAUSE (WHY + WHERE)** — Cursor observed_inventory rejects the new chapter link at tools/check_rule_local_cursor_contract.py:1194. The other two public_markdown_paths functions include every book page; selector sentence_at isolates the old Julia code fence from its negative-language prose. Git6308ff4e24 owns all three added Julia references. LinkedSpec::Get/generated-source probes establish the word grammar's child-dispatch mechanism.
- [x] **FIX** — Register the new guide in all three current inventories, reconcile the three Julia historical references and add an explicit invalid/retired fence comment.
  Preserve complete examples, pending runtime repairs and every semantic/rollout field.
- [x] **ADDRESSED (verified)** — Cursor75/60 mutations, mutation64/50 mutations and selector63/35 references/11 mutations all PASS; native build/run and four argument rejections also PASS. The selector check retains zero current examples and composes capability100/0/0.
- [x] **NO REGRESSION** — Exact contract/checker projections remove only census deltas and equal clean HEAD; all existing mutations pass. The Julia example loses no source or limitation text; all three mutation authorities and backend source bytes are unchanged. Receipt-bound canonical CI governs landing.
- [x] **LOCKSTEP** — Guide/source includes, current census docs, Knowledge, task/memory/history pointers and mdBook are synchronized; conformance .1.35 remains the unchanged post-activity return point.

## Acceptance Checklist — .2.2

- [x] **REPRODUCE / ISSUE** — Missing end-to-end Rust file integration;34 probes expose historical whole-file/token limitations.
- [x] **ROOT CAUSE (WHY + WHERE)** — Descriptors/generated source and execution trace show seek scanning, first-child return and token-regex boundaries. Nine independent Perl results match Rust, including exact backslashes; no Rust escaping defect.
- [x] **FIX** — Complete consumer-local pinned preparation, file adapter, structured errors, grammar packaging and canonical guide;
  strict grammar repairs remain explicit pending .83 children, not a claimed implementation.
- [x] **ADDRESSED (verified)** — Three adapter tests and maintained real-file/error/deployment verifier pass; clean-source bootstrap and locked/offline repeat builds pass.
- [x] **NO REGRESSION** — Existing word consumer and dependency versions/pins are retained; original nested PGEN diff is byte-exact. Canonical CI governs landing.
- [x] **LOCKSTEP** — Book, Rust landing, Knowledge, roadmap and live/task pointers describe verified integration and the still-open strict parsing scope.

## Verification Log

- `2026-09-13` .2.2: PASS three Rust adapter tests; 34 native Lispish probes and nine exact Perl comparisons; maintained verifier's18 same-engine file values plus published settings, structured grammar/runtime failures, I/O/UTF-8/usage checks, earlier-output behavior and packaged/relocated outside-cwd execution. Clean-source bootstrap creates12 generated files/18576534 bytes including four Rust parsers. The200-package consumer lock preserves every version; isolated locked/offline builds complete in40.50s and4.87s, both reporting dependency compilation. Original checkout build4m34s and test build6m37s also pass. Pins and original PGEN full-index diff remain exact. Focused render/preservation/doctrine proof and receipt-bound canonical CI govern landing; no release-profile, empty-cache installation, all-backend malformed-input or actual ARCHOGEN application proof is claimed.

- `2026-09-13` .2.1: PASS offline locked 200-package resolution with every manifest under the repository; Rust1.95.0 builds in3m12s and4m02s, both compiling PGEN/RGX/core/runtime/example. Two native four-value runs match the independent four-value Perl oracle; four usage/non-UTF-8 rejections exit1 with empty stdout. Rustfmt passes. Present generated EBNF/regex sources were retained; no fresh-clone/bootstrap proof is claimed. The new consumer Cargo.lock requires canonical tier; exact staged receipt-bound CI governs this commit. Earlier guard rejection and unsuccessful retained-library link are diagnostic failures, superseded by the successful normal Cargo builds.

- `2026-09-13` .0: PASS17 baseline-identical metadata/API/setup sources; six complete wrappers513 lines; version-only commands exit0 for Cargo1.95.0,Dart3.13.3,Julia1.12.7,Perl5.34.1,Lua5.5.1,LuaJIT2.1.1788460057 and three pkg-config identities. No consumer execution, dependency preparation or build. Focused source/task/history preservation, memory, book and normal doctrines govern this inventory; .7 retains canonical closeout.

- `2026-09-13`: Intake reads native Rust/Lispish and dependency authorities plus
  ADR0040 and the companion tree. Guide/example implementation and consumer proof
  are pending. CONFORMANCE-SOURCE-READING.1.34 owns intake validation and commit.

## Commit Log

- `.2.2`: `BACKEND-INTEGRATION-GUIDES.2.2 - deliver Rust Lispish file integration and deployment`; activation42490a9d917e; requested early push then Perl .1.1.

- `.2.1`: `BACKEND-INTEGRATION-GUIDES.2.1 - document and verify native Rust integration`; activation4d32e895e; next .2.2 after clean handoff.

- `.0`: `BACKEND-INTEGRATION-GUIDES.0 - inventory native integration setup and guide ownership`; activation 00f9783a1e4b625bc251a3e260ef1eef60c35888; next .2.1 after clean handoff.
- Intake: `CONFORMANCE-SOURCE-READING.1.34`; derive its commit from Git history.
- Guide/example leaves: pending.

## Changelog

- `2026-09-13` .2.2: Complete Rust Lispish file/deployment guide and clean pinned-source proof; record exact extraction limits and own strict parsing under startup .83.

- `2026-09-13` .2.1: Deliver Rust setup/native guide and runnable locked consumer; cancel the no-dependency-build restriction as directed; retain startup .80 performance ownership.

- `2026-09-13` .0: Complete five-backend setup/API/content-routing inventory; choose Rust-first implementation and preserve the conformance return point.
- `2026-09-13`: Track the director-requested five-backend integration guides,
  consumer examples, dependency reuse, deployment/error proof and canonical closeout.
