# BACKEND-INTEGRATION-GUIDES: Embed LinkedSpec in an application

## Metadata

- Tree ID: `BACKEND-INTEGRATION-GUIDES`
- Status: `active` / director-authorized temporary documentation activity
- Roadmap lane: `Phase 6 documentation and adoption / native backend integration`
- Created: `2026-09-13`
- Last updated: `2026-09-19`
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
  Status: `active`
  Goal: Deliver the Perl integration guide and executable consumer.
  Children: `.1.1`, `.1.2`
  Dependencies: `.0`
  Acceptance: Perl setup, native use, packaging, error and reuse examples satisfy the shared criteria.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.1.1`
  Status: `done`
  Activation commit: `ad290bdb427bc19a5af81de0f0b07e119c8999ff`.
  Verification tier: `canonical`
  Focused checks: Managed native Perl consumer with explicit module/grammar resolution and exact independent values; actual loaded-module closure and core-dependency census; clean pinned-source consumer setup and repeat runs; syntax and native-resolution contract; public-inventory projections/mutations, book rendering, source/task/history preservation and all doctrines.
  Canonical trigger: The new public guide requires current public-documentation census maintenance in existing contract checkers. Preserve their semantic checks and mutation cases; exact staged canonical proof governs these gate-owner edits. No dependency lock, backend source, shared wrapper or dependency pin change is planned.
  Scope: Create integration-perl.md and a runnable native word consumer using the shared grammar, explicit application-relative module setup and the portable loader. Identify actual core versus optional dependencies with in-process module inventory. Own only the direct-dependent new-page census and current count references. Deployment, comprehensive failures and diagnostic sinks remain .1.2.
  Direct-dependent evidence: New-page preflight reports mutation expected64/observed65 and selector expected63/observed64. Both public_markdown_paths functions include every book page. Change only their EXPECTED_PUBLIC_FILE_COUNT values and current census prose; all classifier logic, three frozen mutation authorities and existing mutations remain exact. The page adds no cursor-migration or selector reference.
  Candidate preservation: PASS 2796 prior files byte-exact and 2803 of2805 prior task nodes unchanged; only this leaf and Perl parent change. Every previous change/notes/history byte and all94 book limitation headings remain. Both checker projections differ only in their expected public-file count. Rendered consumer/grammar includes resolve, memory60 passes and histories remain below rollover pressure at232 lines/48275 bytes and192/47875. A clean native repeat returns the four expected values in10.85s; pre-existing PGEN full-index diff remains exact. No source-reading coverage or unrelated repair completion is claimed.
  Goal: Document and verify Perl checkout, module search path, managed setup and native parsing.
  Acceptance: A consumer loads the intended modules and grammar explicitly, compiles once, parses two independent inputs and checks exact direct values. Identify core versus optional Perl dependencies and portable loader versus legacy discovery; no accidental ambient module path.
  Verification: PASS native four-value setup and repeat; maintained verifier8 groups in both current and clean source consumers, including independent values, UTF-8 input/path rejection, Unicode cwd/path, exact module provenance and owned fixture cleanup. Module proof is66 repository modules/37 core modules/10 standard native libraries on Perl5.34.1 macOS arm64. Clean submodule ad290bdb4 preserves2814 files/58588415 bytes and leaves nested dependencies uninitialized; no CPAN installation or dependency build is required by this route. Native resolution passes5 subtests; public mutation65/14/11/10/50 and selector64/35/0/5/11 pass; cursor75/60 remains unchanged. Book rendering, source/task/history preservation and normal doctrines govern completion; exact staged canonical receipt and post-commit pointer proof remain required. Perl deployment/runtime-error/sink coverage remains .1.2, with no other-backend or minimum-version claim.
  Commit: `BACKEND-INTEGRATION-GUIDES.1.1 - document and verify native Perl integration`

- ID: `BACKEND-INTEGRATION-GUIDES.1.2`
  Status: `done`
  Activation commit: `5289471f9550bf9b103dd6563f84001147689681`.
  Verification tier: `focused`
  Focused checks: Existing native word/module proof plus packaged and relocated execution, structured loader/runtime failures, quiet/default and explicit diagnostic sinks, failure continuation boundaries, source/grammar preservation, targeted Perl contracts, book rendering, memory/history and all doctrines.
  Canonical trigger: None for this ordinary guide/example slice: extend the existing page and consumer without runtime, dependency, shared-wrapper, public-contract or checker changes. Independent replay and final parent closeout remain .7; any newly required infrastructure change must be classified before editing.
  Scope: Complete Perl integration assembly/deployment and accurate error/diagnostic examples using existing APIs. Preserve all source/runtime semantics and pre-existing nested dependency edits. Include the due read-only generated-artifact census; retain reusable caches, current evidence and ambiguous files, with no broad cleanup or recovery operation.
  Investigation: The first Unicode probe double-encoded its own JSON because empty PERL_UNICODE enables UTF-8 streams. Eight inline/file controls retain exact codepoints and emit exact Unicode after PERL_UNICODE=0; the maintained consumer already sets raw streams. Forced handler failure exposes known DUMP_NONE stdout tracing, not a new core defect; the example owns explicit trace policy and runtime-context inspection. Correct the existing trace card's stale no-output wording and the diagnostic card's missing related-fact pointer here.
  Goal: Verify Perl deployment, structured failures and diagnostic-sink examples.
  Dependencies: `.1.1`
  Acceptance: Relocated/outside-cwd use preserves module and grammar resolution; missing grammar and malformed input produce documented outcomes; runtime data remain consumer-local. Generated source dependencies are explicit if taught.
  Verification: PASS8 word/module groups with66 repository modules/37 core modules/10 standard native libraries on Perl5.34.1/macOS arm64. Deployment15 plus2 isolated trace controls pass in the working source; the complete17-group verifier passes using clean ad290bdb4 library source. Checks include exact Unicode events/raw streams, typed exit/arity, prior-output/stop-on-failure, undefined success, forced real handler last_error without outer throw, invalid UTF-8/malformed grammar, trace-file preservation, packaged and relocated caller-relative/outside-cwd use, same-volume data and exact source/grammar hashes. The old consumer fails the new diagnostic-option expectation as intended. Three focused Perl suites pass27 tests. Existing public mutation65 and selector64 inventories remain exact; book, memory/history, source/task preservation and all doctrines govern landing. Artifact census2864 candidates/5843871557 bytes deletes0 and retains caches/evidence. No runtime/dependency source, checker, pin, source-reading count or unrelated repair changes; independent parent closure and canonical push remain .7.
  Commit: `BACKEND-INTEGRATION-GUIDES.1.2 - verify Perl deployment and diagnostic handling`

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
  Status: `active`
  Goal: Deliver the Dart integration guide and executable consumer.
  Children: `.3.1`, `.3.2`
  Dependencies: `.0`
  Acceptance: Package wiring, native requirements, direct values, deployment and errors satisfy the shared criteria.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.3.1`
  Status: `done`
  Activation commit: `0aac639a94ed06e4cb5228c676ee33a7c61a2df4`.
  Verification tier: `canonical`
  Focused checks: Managed standalone Dart path-dependency consumer, exact independent native word values and module/package provenance; clean pinned source setup without nested dependencies; relative manifest and same-volume cache/output proof; formatter/analyzer and focused native loader/runtime suites; direct-dependent public inventories, book, source/task/history preservation and all doctrines.
  Canonical trigger: The new backend guide changes the existing exact public-page inventory constants, and a maintained application pubspec.lock is expected. Classify this designated public-inventory/dependency-metadata boundary before implementation; exact staged canonical CI is required before commit.
  Existing gate boundary: DART-STARTUP-READING.2.24/.2.25 own the September11 complete-component formatter and deprecated_implement failures; the unfiltered formatter mutates six unrelated tests. This source-preserving guide slice selects the consumer-only formatter/analyzer, native loader/function/trace tests and normal canonical core/required-consumer gate. No suppression, SDK downgrade or claim that the complete Dart component gate passes.
  Scope: Add the Dart setup/native-consumer guide and runnable package using existing APIs and the shared word grammar. Preserve runtime/compiler/dependency source semantics and pins. Initial package preparation and ordinary execution are measured separately. Deployment, comprehensive errors and sinks remain .3.2; independent parent closeout remains .7.
  Native asset evidence: The full staged file loader calls the default user-function parser even for the word grammar. Its cwd/script-ancestor discovery does not search the nested path package; an application-owned specs/user_function_definition.spec is copied from the pin. A bad owned copy yields parse_spec/spec_parse_failed; restoring exact bytes restores words, excluding accidental ancestor-checkout success.
  Goal: Verify Dart local package dependency, SDK/native prerequisites and in-process parsing.
  Acceptance: A managed consumer resolves its package cache locally, loads or embeds the grammar, reuses the compiled parser and asserts exact direct values. Required native-library discovery and supported target evidence are explicit.
  Verification: PASS9 native consumer groups in both the working checkout and clean pinned-source application: exact independent/repeated words, Unicode cwd/path, usage/missing source/strict UTF-8 failures, two exact package roots and controlled supporting-grammar selection/restoration. Clean source0aac639a9 matches2822 files/58656678 bytes; source/data remain on this volume and the original PGEN diff is exact. One local path dependency resolves offline with an initially empty app cache in0.90s; no hosted package payload or nested dependency initialization/build. Native runs pass in1.44s and1.37s. Consumer format/strict analysis and13 loader/function/pipeline-trace tests pass. New-page preflight fails65-to66 mutation and64-to65 selector inventories; only the two expected counts/current references advance, with classifier logic and frozen authorities intact. Mutation66/14/11/10/50 and selector65/35/0/5/11 pass. Book, memory/history, source/task preservation, all doctrines and exact staged canonical CI govern landing. Deployment/errors/sinks remain .3.2; independent parent closeout remains .7. Existing component formatting/SDK regex-interface failures remain Dart .2.24/.2.25; no runtime repair or source-reading credit is claimed.
  Commit: `BACKEND-INTEGRATION-GUIDES.3.1 - document and verify native Dart integration`

- ID: `BACKEND-INTEGRATION-GUIDES.3.2`
  Status: `done`
  Activation commit: `0826ca2d4df918f87962efc6dcf1dc132f45a2d6`.
  Verification tier: `focused`
  Focused checks: Native Dart value/diagnostic/exit/error examples and consumer-only formatting/strict analysis; focused loader, diagnostic-output and trace tests; packaged and moved application with outside-cwd execution, exact assets and same-volume storage; existing public inventories, rendered book, source/task/history preservation and all doctrines.
  Canonical trigger: Ordinary existing-guide/example extension using admitted native APIs; no runtime, dependency, public-inventory constant or gate change is planned. Independent parent closeout and the final clean push remain .7 canonical boundaries. Escalate before landing if that scope changes.
  Existing gate boundary: Preserve the complete-component formatter/SDK findings owned by DART-STARTUP-READING.2.24/.2.25. Select consumer-only nonwriting format/analysis and the direct native suites; do not run the unrelated mutating formatter gate or claim complete Dart component admission.
  Scope: Extend the maintained Dart consumer and guide with explicit diagnostic events, runtime failures, typed exit handling and verified native deployment. Prove supporting-grammar selection without borrowing an ancestor checkout. Preserve compiler/runtime source, dependency pins, prior reading credit and all unrelated findings; .7 retains independent parent closure.
  Shell portability: An unpublished launcher draft's empty-array expansion under nounset fails with exit127 in system Bash3.2.57. Replace it with scalar flags and positional arguments. The final 36-check working replay passes with Bash5.3.15 and the 36-check clean-source replay passes with system Bash3.2.57; no source-runtime defect or outstanding launcher failure remains.
  Goal: Verify Dart grammar/native-library packaging and diagnostic/error handling.
  Dependencies: `.3.1`
  Acceptance: Outside-cwd execution works with packaged assets; missing-source and parse/runtime errors match the documented API. Unsupported deployment surfaces are qualified without speculative claims; ordinary repeat runs reuse compatible preparation.
  Verification: PASS 36 application checks against both current and clean pinned 0826ca2d4 source: thirteen source and thirteen AOT diagnostic/value/error cases plus ten deployment controls. Exact Unicode events, typed exit status and prior-output/stop behavior, runtime source identity, null success, option-like grammar names and inherited trace separation pass. The six-file native bundle preserves hashes after moving to a Unicode path and read-only file modes; outside-cwd calls work without Dart on PATH. Bad caller/packaged assets prove selection, and missing packaged grammar/executable fail explicitly. Nine word/package groups and 23 native loader/diagnostic/trace tests pass; both consumers pass strict analysis and the maintained source passes nonwriting formatting. Clean source matches 2828 files/58692124 bytes; nested dependencies stay uninitialized, no hosted runtime packages are fetched, source/data stay on this volume and the original PGEN diff remains exact. Mutation 66/14/11/10/50 and selector 65/35/0/5/11 stay green without checker changes. Focused book, source/task/history preservation, Knowledge and all doctrines govern this ordinary commit. No runtime/pin change, complete Dart component-gate claim or reading credit; .7 retains independent parent closeout and canonical push.
  Commit: `BACKEND-INTEGRATION-GUIDES.3.2 - verify Dart native deployment and diagnostics`

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
| 1 | `BACKEND-INTEGRATION-GUIDES.4.1` | `pending` | Dart setup, diagnostics and native deployment are verified; next Julia setup/native consumer from the clean committed tree. Rust ad290bdb4 is pushed. Independent .7 retains parent closure before conformance .1.35. |

The director explicitly requests a temporary pivot at the next clean handoff.
Conformance .1.34 is committed at 00f9783a1 and inventory .0 is complete.
Rust .2.2 is committed and pushed atad290bdb427bc19a5af81de0f0b07e119c8999ff. Canonical CI PASS includes both CLI66/66 and Phase0 1032/1032 in1086s;25 optional extensions were skipped. Post-commit receipt promotion, empty brief, clean root status and remote main identity were verified. Perl .1.1 commits at5289471f9 and .1.2 verifies deployment/errors before Dart .3.1; final .7 retains independent parent closure. Ordinary guide/example work needs no further permission.

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

## Acceptance Checklist — .1.1

- [x] **REPRODUCE / ISSUE** — The missing Perl setup guide requires a native consumer and measured dependency closure; new-page preflight reports mutation expected64/observed65 and selector expected63/observed64.
- [x] **ROOT CAUSE (WHY + WHERE)** — LinkedSpec::SpecLoader composes LinkedSpec::Get and returns its parser coderef; the existing shared-grammar descriptor/oracle establishes word dispatch. Both public_markdown_paths functions include the new book page; their exact cardinality constants reject its unreviewed addition.
- [x] **FIX** — Add the canonical Perl guide, direct parser consumer and module/value verifier; advance only the two public-file cardinalities and current census references.
- [x] **ADDRESSED (verified)** — Both native environments pass eight verifier groups and module66/core37/native10 checks; clean source2814 files/58588415 bytes is exact, with nested dependencies uninitialized.
- [x] **NO REGRESSION** — Native resolution5, mutation50 and selector11 mutations pass; frozen authorities, classifier logic, cursor75/60 and pre-existing PGEN edits remain unchanged. Exact staged canonical CI governs landing.
- [x] **LOCKSTEP** — Source includes, navigation, Knowledge, roadmap, task and live/history records agree; Perl deployment/errors remain .1.2 and the post-activity return is conformance .1.35.

## Acceptance Checklist — .1.2

- [x] **REPRODUCE / ISSUE** — Prior consumer fails the new diagnostic-option expectation. Native probes distinguish quiet events, typed exit, successful undef, and a real generated-handler error returned through runtime context.
- [x] **ROOT CAUSE (WHY + WHERE)** — LinkedSpec::Get generated source calls RuntimeDiagnosticOutput; SpecEntry records ordinary handler errors and emits level-zero native trace. Empty PERL_UNICODE caused the scratch observer's double encoding; runtime codepoints stayed exact.
- [x] **FIX** — Extend only the application adapter and existing guide; add a relative-layout launcher, diagnostic/exit fixtures and deployment verifier. Own JSON channels through explicit native trace configuration, context inspection and selected typed-error projection.
- [x] **ADDRESSED (verified)** — Fifteen working-checkout groups plus two trace controls and the complete17-group clean-source replay pass, including packaged/relocated outside-cwd execution and unchanged source/grammar hashes.
- [x] **NO REGRESSION** — Word/module8 and focused Perl27 pass; public inventories/checker logic, runtime sources, dependency pins and original PGEN edits remain unchanged. The artifact census deletes nothing ambiguous or reusable.
- [x] **LOCKSTEP** — Book source includes, Knowledge, roadmap, task and bounded history agree. Dart .3.1 follows clean commit; final .7 retains parent closure/canonical push before conformance .1.35.

## Acceptance Checklist — .3.1

- [x] **REPRODUCE / ISSUE** — The native Dart setup guide is absent; new-page preflight fails exact public inventories65-to66 and64-to65. A controlled bad supporting grammar rejects the word consumer instead of finding a convenient ancestor copy.
- [x] **ROOT CAUSE (WHY + WHERE)** — loadAndCompileSpec composes the staged native frontend, whose default function parser searches cwd/script ancestors for specs/user_function_definition.spec. Package path resolution alone does not provide that asset. Both public_markdown_paths functions intentionally inventory the new page.
- [x] **FIX** — Add the source-pinned package/asset setup, runnable direct-value consumer and meaningful verifier. Adjust only reviewed public-file cardinalities/current references; keep runtime/checker semantics intact.
- [x] **ADDRESSED (verified)** — Both consumers pass9 groups with2 exact local package roots and no hosted dependency; clean2822-file source and independently copied assets match the pin. Cold offline setup and two native runs pass without nested initialization/build.
- [x] **NO REGRESSION** — Consumer format/analysis and13 native tests pass; mutation50/selector11 remain. Existing full-component formatting/SDK-adapter failures stay owned by Dart .2.24/.2.25; exact staged canonical core/required-consumer proof governs landing.
- [x] **LOCKSTEP** — Guide/source includes, Knowledge, roadmap, task and bounded history agree; .3.2 follows clean commit and .7 retains final independent closeout before conformance .1.35.

## Acceptance Checklist — .3.2

- [x] **REPRODUCE / ISSUE** — The prior consumer treats --diagnostics as a missing grammar; the guide has no deployed native bundle. Controlled caller/packaged support assets distinguish frontend selection from accidental ancestor success.
- [x] **ROOT CAUSE (WHY + WHERE)** — The admitted Dart API already supplies diagnosticOutputSink and RuntimeExitNow, but the example does not project them. Default function-parser discovery searches cwd before script ancestors; an AOT executable still needs the support grammar at runtime.
- [x] **FIX** — Extend the application adapter with optional typed events/exit handling, and package the compiled executable with a caller-relative-path-preserving Bash launcher and exact grammar assets. Library/runtime semantics and pins remain unchanged.
- [x] **ADDRESSED (verified)** — Both current and clean pinned-source applications pass 36 source/AOT/deployment checks; moved Unicode paths, read-only files, missing assets and no Dart on PATH are verified. Every bundle byte survives the move and calls.
- [x] **NO REGRESSION** — Nine word/package checks, 23 native API tests, consumer analysis/formatting, unchanged public inventory checks and source preservation pass. Existing complete Dart component failures stay separately owned by .2.24/.2.25.
- [x] **LOCKSTEP** — Runnable includes, guide, Knowledge, roadmap, task and bounded history agree. Julia .4.1 follows clean commit; independent .7 retains parent closeout and canonical push before conformance .1.35.

## Verification Log

- `2026-09-19` .3.2: PASS 36 application checks against both current and clean pinned 0826ca2d4 source: thirteen source and thirteen AOT diagnostic/value/error cases plus ten deployment controls. Exact Unicode events, typed exit status and prior-output/stop behavior, runtime source identity, null success, option-like grammar names and inherited trace separation pass. The six-file native bundle preserves hashes after moving to a Unicode path and read-only file modes; outside-cwd calls work without Dart on PATH. Bad caller/packaged assets prove selection, and missing packaged grammar/executable fail explicitly. Nine word/package groups and 23 native loader/diagnostic/trace tests pass; both consumers pass strict analysis and the maintained source passes nonwriting formatting. Clean source matches 2828 files/58692124 bytes; nested dependencies stay uninitialized, no hosted runtime packages are fetched, source/data stay on this volume and the original PGEN diff remains exact. Mutation 66/14/11/10/50 and selector 65/35/0/5/11 stay green without checker changes. Focused book, source/task/history preservation, Knowledge and all doctrines govern this ordinary commit. No runtime/pin change, complete Dart component-gate claim or reading credit; .7 retains independent parent closeout and canonical push.

- `2026-09-19` .3.1: PASS9 native consumer groups in both the working checkout and clean pinned-source application: exact independent/repeated words, Unicode cwd/path, usage/missing source/strict UTF-8 failures, two exact package roots and controlled supporting-grammar selection/restoration. Clean source0aac639a9 matches2822 files/58656678 bytes; source/data remain on this volume and the original PGEN diff is exact. One local path dependency resolves offline with an initially empty app cache in0.90s; no hosted package payload or nested dependency initialization/build. Native runs pass in1.44s and1.37s. Consumer format/strict analysis and13 loader/function/pipeline-trace tests pass. New-page preflight fails65-to66 mutation and64-to65 selector inventories; only the two expected counts/current references advance, with classifier logic and frozen authorities intact. Mutation66/14/11/10/50 and selector65/35/0/5/11 pass. Book, memory/history, source/task preservation, all doctrines and exact staged canonical CI govern landing. Deployment/errors/sinks remain .3.2; independent parent closeout remains .7. Existing component formatting/SDK regex-interface failures remain Dart .2.24/.2.25; no runtime repair or source-reading credit is claimed.

- `2026-09-19` .1.2: PASS8 word/module groups with66 repository modules/37 core modules/10 standard native libraries on Perl5.34.1/macOS arm64. Deployment15 plus2 isolated trace controls pass in the working source; the complete17-group verifier passes using clean ad290bdb4 library source. Checks include exact Unicode events/raw streams, typed exit/arity, prior-output/stop-on-failure, undefined success, forced real handler last_error without outer throw, invalid UTF-8/malformed grammar, trace-file preservation, packaged and relocated caller-relative/outside-cwd use, same-volume data and exact source/grammar hashes. The old consumer fails the new diagnostic-option expectation as intended. Three focused Perl suites pass27 tests. Existing public mutation65 and selector64 inventories remain exact; book, memory/history, source/task preservation and all doctrines govern landing. Artifact census2864 candidates/5843871557 bytes deletes0 and retains caches/evidence. No runtime/dependency source, checker, pin, source-reading count or unrelated repair changes; independent parent closure and canonical push remain .7.

- `2026-09-14` .1.1: PASS native four-value setup and repeat; maintained verifier8 groups in both current and clean source consumers, including independent values, UTF-8 input/path rejection, Unicode cwd/path, exact module provenance and owned fixture cleanup. Module proof is66 repository modules/37 core modules/10 standard native libraries on Perl5.34.1 macOS arm64. Clean submodule ad290bdb4 preserves2814 files/58588415 bytes and leaves nested dependencies uninitialized; no CPAN installation or dependency build is required by this route. Native resolution passes5 subtests; public mutation65/14/11/10/50 and selector64/35/0/5/11 pass; cursor75/60 remains unchanged. Book rendering, source/task/history preservation and normal doctrines govern completion; exact staged canonical receipt and post-commit pointer proof remain required. Perl deployment/runtime-error/sink coverage remains .1.2, with no other-backend or minimum-version claim.

- `2026-09-13` .2.2: PASS three Rust adapter tests; 34 native Lispish probes and nine exact Perl comparisons; maintained verifier's18 same-engine file values plus published settings, structured grammar/runtime failures, I/O/UTF-8/usage checks, earlier-output behavior and packaged/relocated outside-cwd execution. Clean-source bootstrap creates12 generated files/18576534 bytes including four Rust parsers. The200-package consumer lock preserves every version; isolated locked/offline builds complete in40.50s and4.87s, both reporting dependency compilation. Original checkout build4m34s and test build6m37s also pass. Pins and original PGEN full-index diff remain exact. Focused render/preservation/doctrine proof and receipt-bound canonical CI govern landing; no release-profile, empty-cache installation, all-backend malformed-input or actual ARCHOGEN application proof is claimed.

- `2026-09-13` .2.1: PASS offline locked 200-package resolution with every manifest under the repository; Rust1.95.0 builds in3m12s and4m02s, both compiling PGEN/RGX/core/runtime/example. Two native four-value runs match the independent four-value Perl oracle; four usage/non-UTF-8 rejections exit1 with empty stdout. Rustfmt passes. Present generated EBNF/regex sources were retained; no fresh-clone/bootstrap proof is claimed. The new consumer Cargo.lock requires canonical tier; exact staged receipt-bound CI governs this commit. Earlier guard rejection and unsuccessful retained-library link are diagnostic failures, superseded by the successful normal Cargo builds.

- `2026-09-13` .0: PASS17 baseline-identical metadata/API/setup sources; six complete wrappers513 lines; version-only commands exit0 for Cargo1.95.0,Dart3.13.3,Julia1.12.7,Perl5.34.1,Lua5.5.1,LuaJIT2.1.1788460057 and three pkg-config identities. No consumer execution, dependency preparation or build. Focused source/task/history preservation, memory, book and normal doctrines govern this inventory; .7 retains canonical closeout.

- `2026-09-13`: Intake reads native Rust/Lispish and dependency authorities plus
  ADR0040 and the companion tree. Guide/example implementation and consumer proof
  are pending. CONFORMANCE-SOURCE-READING.1.34 owns intake validation and commit.

## Commit Log

- `.3.2`: `BACKEND-INTEGRATION-GUIDES.3.2 - verify Dart native deployment and diagnostics`; activation 0826ca2d4; next Julia .4.1 after clean handoff.

- `.3.1`: `BACKEND-INTEGRATION-GUIDES.3.1 - document and verify native Dart integration`; activation0aac639a9; next .3.2 after clean handoff.

- `.1.2`: `BACKEND-INTEGRATION-GUIDES.1.2 - verify Perl deployment and diagnostic handling`; activation5289471f9; next Dart .3.1 after clean handoff.

- `.1.1`: `BACKEND-INTEGRATION-GUIDES.1.1 - document and verify native Perl integration`; activationad290bdb4; next .1.2 after clean handoff.

- `.2.2`: `BACKEND-INTEGRATION-GUIDES.2.2 - deliver Rust Lispish file integration and deployment`; activation42490a9d917e; requested early push then Perl .1.1.

- `.2.1`: `BACKEND-INTEGRATION-GUIDES.2.1 - document and verify native Rust integration`; activation4d32e895e; next .2.2 after clean handoff.

- `.0`: `BACKEND-INTEGRATION-GUIDES.0 - inventory native integration setup and guide ownership`; activation 00f9783a1e4b625bc251a3e260ef1eef60c35888; next .2.1 after clean handoff.
- Intake: `CONFORMANCE-SOURCE-READING.1.34`; derive its commit from Git history.
- Guide/example leaves: pending.

## Changelog

- `2026-09-19` .3.2: Verify native Dart diagnostic events, typed failures and relocated AOT deployment; retain all runtime/gate repair ownership.

- `2026-09-19` .3.1: Deliver Dart native integration with local package and required supporting-grammar proof; preserve existing runtime/gate repair ownership.

- `2026-09-19` .1.2: Verify Perl deployment/errors/sinks; retain independent parent closeout at .7 and advance to Dart .3.1.

- `2026-09-14` .1.1: Deliver native Perl setup and measured core/module closure; preserve dependency sources and update the two direct public inventories. Rust checkpoint push is verified.

- `2026-09-13` .2.2: Complete Rust Lispish file/deployment guide and clean pinned-source proof; record exact extraction limits and own strict parsing under startup .83.

- `2026-09-13` .2.1: Deliver Rust setup/native guide and runnable locked consumer; cancel the no-dependency-build restriction as directed; retain startup .80 performance ownership.

- `2026-09-13` .0: Complete five-backend setup/API/content-routing inventory; choose Rust-first implementation and preserve the conformance return point.
- `2026-09-13`: Track the director-requested five-backend integration guides,
  consumer examples, dependency reuse, deployment/error proof and canonical closeout.
