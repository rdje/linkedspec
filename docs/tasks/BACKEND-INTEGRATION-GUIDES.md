# BACKEND-INTEGRATION-GUIDES: Embed LinkedSpec in an application

## Metadata

- Tree ID: `BACKEND-INTEGRATION-GUIDES`
- Status: `active` / director-authorized temporary documentation activity
- Roadmap lane: `Phase 6 documentation and adoption / native backend integration`
- Created: `2026-09-13`
- Last updated: `2026-09-20`
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
  Children: `.0`, `.1`, `.2`, `.3`, `.4`, `.5`, `.6`, `.7`, `.8`
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
  Status: `active`
  Goal: Deliver the Julia integration guide and executable consumer.
  Children: `.4.1`, `.4.2`
  Dependencies: `.0`
  Acceptance: Project/module wiring, depot/native requirements, direct values, deployment and errors satisfy the shared criteria.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.4.1`
  Status: `done`
  Activation commit: `49758cbc97745dabd1baf701686f843858cf0b94`.
  Verification tier: `canonical`
  Focused checks: Native Julia application with a relative local package path, explicit project activation and same-volume depot; exact independent word values and module/package provenance; clean pinned-source application preparation; focused native loader/frontend tests, direct-dependent public inventories, book, source/task/history preservation and all doctrines.
  Canonical trigger: A new backend guide changes exact public-page inventories, and maintained application project/manifest metadata is expected. Classify this public-inventory/dependency-metadata boundary before editing; exact staged canonical CI is required before commit.
  Scope: Document and verify Julia setup and a minimal native consumer using existing APIs. Separate package/source preparation, precompilation and repeated parser execution; retain required package sources and caches. Preserve runtime/compiler/dependency source and pins. Deployment and comprehensive diagnostics stay .4.2; independent parent closeout stays .7.
  Goal: Verify Julia project activation, local module/package setup, depot placement and native parsing.
  Acceptance: A consumer follows the actual supported package/module surface, prepares required products once, loads the grammar and reuses the engine for exact independent results. No implicit home depot or unrelated dependency rebuild.
  Verification: PASS 11 setup/value groups against both current and clean pinned 49758cbc9 source on Julia1.12.7/macOS arm64: explicit application project, relative manifest path, package/module provenance, source-first supporting grammar with controlled bad cwd asset, independent/repeated values, Unicode/relative paths, strict UTF-8, missing arguments/files and successful null. Native loader tests pass82 assertions (34/24/10/6/8), and the shared contract remains14/9/4. Initial online preparation writes only the application depot; subsequent offline preparation and fresh-process parsing pass. Clean preparation copies/verifies148 package-source files/734878 bytes and2 registry files/11419507 bytes from the owned depot without copying compiled caches. The app-generated manifest selects JSON3 1.14.3, Parsers2.8.8, PrecompileTools1.3.4, Preferences1.6.0 and StructTypes1.11.0; the backend manifest and source remain unchanged. Clean submodule source matches2832 files/58732023 bytes, retains the public origin and leaves nested dependencies uninitialized. Source/data stay on this volume and the original PGEN diff remains exact. Public RED expected66/observed67 and65/66 becomes GREEN mutation67/14/11/10/50 and selector66/35/0/5/11 by count-only updates; classifier/frozen authorities stay unchanged. Book, source/task/history preservation, Knowledge and all doctrines govern this leaf; exact staged canonical CI is required for landing. No runtime/pin changes, minimum-version/platform expansion or reading credit; .4.2 retains deployment/runtime diagnostics and .7 retains independent parent closeout and canonical push.
  Commit: `BACKEND-INTEGRATION-GUIDES.4.1 - document and verify native Julia integration`

- ID: `BACKEND-INTEGRATION-GUIDES.4.2`
  Status: `done`
  Activation commit: `29bf3fdd12c1f12b0fc414258229c78df1e4d5bc`.
  Verification tier: `focused`
  Focused checks: Existing Julia setup/value proof; optional diagnostic events and typed runtime failures; packaged, relocated and outside-cwd source application with retained package sources and explicit application storage; native loader/diagnostic/trace tests, public inventories, book, source/task/history preservation and all doctrines.
  Canonical trigger: Ordinary extension of the existing consumer and guide using admitted APIs, without runtime, dependency, public-inventory or shared-wrapper changes. Independent parent closeout and the final push remain .7 canonical boundaries; escalate if implementation requires a governed infrastructure change.
  Scope: Complete Julia source deployment, application-owned cache expectations and error/diagnostic examples. Preserve runtime/compiler sources, dependency manifests and pins, previous reading credit and pre-existing PGEN edits. Retain package sources and caches; no Julia standalone executable or unmeasured platform claim.
  Goal: Verify Julia deployment, compilation/cache expectations and typed failure handling.
  Dependencies: `.4.1`
  Acceptance: Relocated/outside-cwd execution finds its grammar and required libraries; errors and diagnostics match the guide. Distinguish initial package preparation, Julia compilation and ordinary parser execution using measured repeat-run evidence.
  Verification: PASS 24 deployment checks in both current and clean pinned 29bf3fdd1 applications on Julia 1.12.7/macOS arm64. Twelve source cases cover exact Unicode events, quiet defaults, typed exit/prior-output/stop behavior, runtime source identity, null success, four loader stages, usage and inherited trace separation. Git-archived source and verified package/registry copies prepare offline without copied compiled caches. Outside-cwd, option-like paths, controlled bad/missing packaged grammar, Unicode relocation and fresh-process reuse pass. The clean application manifest is copied byte-exactly; source, manifest and package hashes survive preparation/moving. Both word verifiers pass 11 groups; native loader 82 and diagnostic 82 assertions pass. Clean source matches 2838 files / 58774855 bytes; nested dependencies stay uninitialized, all project data remains on this volume and original PGEN edits remain exact. Public mutation 67/14/11/10/50 and selector 66/35/0/5/11 pass unchanged. Focused book, source/task/history preservation, Knowledge and all doctrines govern landing. No runtime/pin changes or reading credit; independent parent closeout and canonical push remain .7.
  Commit: `BACKEND-INTEGRATION-GUIDES.4.2 - verify Julia source deployment and diagnostics`

- ID: `BACKEND-INTEGRATION-GUIDES.5`
  Status: `active`
  Goal: Deliver Lua integration guidance for the supported PUC Lua and LuaJIT routes.
  Children: `.5.1`, `.5.2`, `.5.3`
  Dependencies: `.0`; preserve LUA-STARTUP-READING.2.3 exclusions and missing-ABI proof boundaries.
  Acceptance: Module/native-library paths, exact ABI preparation, values and deployment satisfy the shared criteria without extending unverified host claims.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.5.1`
  Status: `done`
  Activation commit: `0b409e30531ca898e84245220cde26606f65b7b9`.
  Verification tier: `canonical`
  Focused checks: Retained ABI-specific native products and explicit module paths for installed PUC Lua and LuaJIT; exact independent values, package/native/supporting-grammar provenance and clean pinned-source setup; selected loader/frontend tests within existing exclusions; public inventories, book, source/task/history preservation and all doctrines.
  Canonical trigger: A new backend integration chapter changes the two exact public-page inventory constants. Preserve classifier/frozen-contract semantics and require exact staged canonical CI before landing this designated public-inventory boundary. The director-approved six-control history admission is also canonical infrastructure.
  Scope: Document and verify Lua setup with existing native APIs and build tools, separate PUC Lua/LuaJIT products, source/runtime dependencies and owned same-volume output. Retain prepared products and caches. Preserve runtime source, pins, missing PUC5.4 proof and LUA-STARTUP-READING.2.3 malformed-regex/unfiltered-gate exclusions. Include the due generated-artifact census, deleting only provably unnecessary owned artifacts. Deployment and comprehensive diagnostics remain .5.2; parent closeout remains .7.
  Direct-dependent scope: Correct the existing Lua storage card's stale two-module wording to the current builder trio; document retained application products versus the disposable test wrapper. This is documentation alignment for the inspected existing builder, with no storage infrastructure change.
  Director disposition (2026-09-20): Granted the exact six history controls proposed below: changes files38->39, manifest lines37->38 and bytes21071->21647; notes files34->35, manifest lines33->34 and bytes19902->20514. Implement the accepted indexed ADR and only those six registry scalars within this active canonical leaf, preserve every earlier history byte and all other controls, then run exact staged canonical CI. No verification waiver, dirty-tree pivot or dependency restriction is introduced.
  Goal: Verify Lua module search paths, ABI-specific native products and native parsing.
  Acceptance: Separate PUC Lua/LuaJIT setup and product compatibility; exercise the full staged loader with explicit module/library paths and exact direct values. Initial preparation is separate from repeated engine use; no excluded unfiltered runtime gate.
  Verification: PASS 13 setup checks per runtime in working and clean pinned 0b409e305 applications on macOS arm64, PUC Lua 5.5.1, LuaJIT 2.1.1788460057 and PCRE2 10.48. Exact interpreter/header identities, source/module paths, native trio loading, module-owned supporting grammar and its one-build cache are verified. Independent/repeated values, Unicode grammar paths, missing arguments/files, strict UTF-8, successful null/false and ambient-init exclusion pass. Six retained native products preserve hashes and modification times across fresh processes. Five selected existing native loader tests pass per runtime; excluded malformed-regex and unfiltered Lua gates are not run, and the declared PUC 5.4 target remains unverified. Clean source matches 2842 files / 58811026 bytes with public submodule URL, uninitialized nested dependencies, same-volume source/data and exact original PGEN edits. Artifact census retains 3260 candidates / 6165392650 bytes and deletes zero. New-page RED counts are mutation 67/68 and selector 66/67; only expected counts and current prose advance to 68 and 67. Book, source/task/history preservation, Knowledge and all doctrines govern landing; exact staged canonical CI is required. No runtime, dependency pin or reading-credit change; .5.2 and independent .7 remain open.
  Commit: `BACKEND-INTEGRATION-GUIDES.5.1 - document and verify native Lua integration`

  Capacity admission: ADR0121 implements exactly the six director-approved controls. Production functions pass 44 threshold and 34 authorization cases, including exact/missing/altered authority and unauthorized limits. Prior histories reconstruct byte-exactly; normal doctrines and receipt-bound canonical CI govern landing. No verification exception.

- ID: `BACKEND-INTEGRATION-GUIDES.5.2`
  Status: `done`
  Activation commit: `6e37288f7564d99480f1353231b226a678a9568f`.
  Verification tier: `focused`
  Focused checks: Prepared PUC Lua/LuaJIT consumer diagnostics, typed failures, value identity and stop behavior; packaged/moved outside-cwd use with exact source/native products and required-asset failures; existing setup and native diagnostic tests; guide rendering/public guards, Knowledge, history/memory, preservation and all doctrines.
  Canonical trigger: None for the bounded example/guide leaf. Preserve runtime/native implementation, dependency pins, inventory checkers and workflow infrastructure; final .7 retains canonical proof. Escalate before changing any designated owner.
  Scope: Extend the existing consumer with opt-in diagnostic events and typed immediate-exit handling; supply a launcher, relocatable source/native bundle instructions and maintained deployment checks. Reuse compatible prepared ABI products. Preserve declared PUC5.4 and invalid-regex proof exclusions; do not run the excluded unfiltered Lua gate. Align the integration inventory's superseded capacity-proposal note with the committed .5.1 outcome.
  Verification investigation: Initial24 deployment checks pass on both runtimes; native diagnostic contract119 each passes. A subsequent four-way run passes all13 setup groups and three deployment routes, but working PUC emits non-JSON stderr at invalid-UTF8. The original harness omitted raw output from its decode exception; it now retains complete command/status/streams on decode failure. The complete four-route replay and120 managed/40 direct focused controls all pass. This resolves the harness evidence-loss defect, not the unexplained output's cause. New .5.3 owns that unresolved occurrence and gates parent closeout; do not erase it or infer a runtime fix from passing retries. Evidence: .linkedspec-data/scratch/backend-integration52.
  Goal: Verify Lua deployment, value conversion, structured errors and optional diagnostic sinks.
  Dependencies: `.5.1`
  Acceptance: Outside-cwd examples locate packaged grammar/modules/libraries; failure examples and nil/array conventions are accurate. Document only ABI routes actually verified and keep missing proof visibly owned.
  Verification: PASS final four-route replay:13 setup and24 deployment groups for each working/clean consumer on PUC5.5.1 and LuaJIT2.1.1788460057. Native diagnostic contract119 assertions per runtime and exact public error/projection probe pass. Clean6e37288f7 library has2852 files/58902045 bytes with no overlays; the checked runtime closure is172 files/3643774 bytes and diagnostic bundle179 files with only two native parsing modules. Unicode/moved/outside-cwd calls, read-only source files, exact source attribution, events, typed exit/arity, null/false, trace separation, and controlled wrong/missing assets pass. All six original native products retain hashes/mtimes; no build or dependency source/pin change. The earlier unexplained non-JSON stream is explicitly owned by .5.3; passing retries and160 focused controls do not close its cause. Book/public, source/history preservation, Knowledge, memory/history and all doctrines govern this focused commit; final .7 remains gated.
  Commit: `BACKEND-INTEGRATION-GUIDES.5.2 - verify Lua deployment and diagnostics`

- ID: `BACKEND-INTEGRATION-GUIDES.5.3`
  Status: `done` / diagnosis and canonical repair handoff; defect not fixed
  Activation commit: `1ab8e8ac394900f68eaf55f5ca012787bbfb3331`.
  Verification tier: `focused`
  Focused checks: Bounded exact four-way setup/deployment workload with complete command/status/raw-stream capture; compare any recurrence against direct and managed native controls; source/native preservation, evidence ownership, Knowledge/book/continuity and all doctrines.
  Canonical trigger: None for initial read-only diagnosis and evidence recording. Escalate before any workflow, storage, gate, dependency or public-contract implementation change. No RGX/PGEN internals or native rebuilds are involved.
  Initial experiment: Replay at most eight complete four-way rounds, retaining every subprocess result and stopping after the first unexpected result. Each route runs13 setup groups then24 deployment groups; previous160 focused invalid-UTF8 controls passed. Do not change the expected result or infer a cause without the actual stream.
  Goal: Identify a reproducible source of unexpected consumer stderr and attach the measured repair obligation to its canonical owner.
  Dependencies: `.5.2` supplies complete failure capture and retained initial/replay/control evidence.
  Scope: The original PUC stream was lost and remains unidentified. A captured clean-LuaJIT recurrence emits the existing managed Bash process-group warning while returning correct values/status0. Investigation remains read-only; wrapper implementation belongs to existing startup .7, whose required-reading dependencies are unchanged.
  Acceptance: Capture exact command/status/raw streams, identify the emitting layer for actual captured evidence, measure the warned child's group when possible, and preserve uncertainty about the original lost stream and kernel cause. Consolidate an already-owned infrastructure defect into its existing repair instead of duplicating or bypassing its prerequisites. Final .7 must consume the qualified outcome; no warning filter, inferred Lua defect or false repair closure.
  Scope disposition: Startup .7 already owns this exact warning, establishment verification and denied/unknown liveness handling. It depends on required reading .3/.4/.5. The integration leaf therefore closes diagnosis/evidence handoff only; the infrastructure defect remains open there. Common .6 and final documentation review may proceed with that limitation explicit.
  Verification: PASS captured evidence: four complete concurrent rounds plus three routes in round5 give19 complete13-setup/24-deployment routes. The remaining clean-LuaJIT setup call returns correct values/status0 with child-setpgid EPERM for child571. A separate bounded probe completes1000 invocations; all exit0 with matching child PID/PGID and999 have empty stderr. The warned invocation's PID/PGID29222 matches the warning's child; parent28526. This establishes that invocation's final group, not the denied-call cause or a lifecycle guarantee. Read-only listing reports found0/removed0/skipped0. No recover/purge, source change, native build, dependency analysis or fix. Canonical facts and startup .7 acceptance retain the actual warned-group control. Book/public, preservation, Knowledge, memory/history and all doctrines govern focused landing.
  Commit: `BACKEND-INTEGRATION-GUIDES.5.3 - trace consumer stderr to managed wrapper`

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
  Dependencies: `.6`, `.8.2`, `.8.3`, `.8.4`, `.5.3`
  Acceptance: Replay documented setup/use/deployment/error paths from managed consumer workspaces, consume all job outcomes, render affected books, verify links and evidence limits, run required canonical CI, and close all verified parent nodes. Commit cleanly before the final push boundary; no pending backend may be counted complete.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.8`
  Status: `active`
  Goal: Incorporate the director-supplied ARCHOGEN and SEMULITH consumer reports without losing the ongoing integration delivery.
  Children: `.8.1`, `.8.2`, `.8.3`, `.8.4`
  Dependencies: Clean .5.1 checkpoint 7f2afcbf428a6a29b7c82d8c618e2312eaa16e6c.
  Acceptance: Every report has a qualified disposition and an executable repair owner where action is required. Integration setup repairs precede final .7; grammar/runtime repairs keep their startup prerequisites and explicit implementation ownership.
  Verification: `pending`
  Commit: `pending`

- ID: `BACKEND-INTEGRATION-GUIDES.8.1`
  Status: `done`
  Activation commit: `7f2afcbf428a6a29b7c82d8c618e2312eaa16e6c`.
  Verification tier: `focused`
  Focused checks: Read every supplied report, setup/validation document, reproducer and fixture; verify report identity/state, same-volume input provenance and deterministic report manifests; reconcile existing Knowledge and task owners, preserve source and prior task/history evidence, render the book and run all doctrines plus memory/history checks.
  Canonical trigger: None for this bounded documentation/intake leaf. No source, dependency, manifest, workflow, checker or public-language contract changes; all actual reproductions and fixes remain explicit subsequent leaves. Final integration .7 retains canonical proof.
  Scope: Own the September20 director-supplied read-only inputs from ARCHOGEN docs/feedback/linkedspec and SEMULITH docs/upstream/linkedspec. Persist source-qualified report IDs, duplicate relationships, supplied observations versus local evidence, and concrete repair ownership. Keep both application repositories and all nested dependency edits unchanged. Give new setup defects bounded leaves before implementation and attach Lispish findings to startup .83.
  Goal: Preserve and qualify all ten consumer reports and their repair routes.
  Acceptance: Account for seven ARCHOGEN and three SEMULITH reports, including the withdrawn and no-action reports. Never label a supplied reproducer result as locally executed. Record blocked consumer requirements, source snapshots, verification limits and the next integration repair, while preserving the Lua deployment and conformance return points.
  Verification: PASS complete read of seven ARCHOGEN and three SEMULITH reports, their setup/validation instructions, reproducers, fixtures and frozen evidence. Same-volume snapshots preserve 43 files/75512 bytes and29/26871 bytes with exact sorted per-file manifests; source-qualified state and duplicate mapping account for all ten reports. No supplied reproducer or patch was executed. The canonical Knowledge card records exact manifests, provenance and verification boundaries; focused book/public, source/task/history and normal doctrine checks govern landing. No source-reading credit, runtime repair, consumer application mutation or strict-parser admission is claimed.
  Outcome: docs/knowledge/archogen-rust-lispish-integration.md is the canonical ten-report register. Integration .8.2/.8.3/.8.4 own concrete setup remedies; startup .83.1/.83.2/.83.3 own grammar contract, actual fixes and independent admission. Lua .5.2 and conformance .1.35 remain intact. The supplied LF patch and workspace/bootstrap symptoms require the subsequent local proof; withdrawn/no-action findings remain unchanged.
  Candidate proof: PASS2836 prior files byte-exact and2801/2805 prior task nodes unchanged; only the integration root/.7 and startup .83/.83.1 acquire the declared ownership/dependencies, with five new .8 nodes. All archived/history bytes, runtime sources, dependency pins, existing PGEN edits and94 book limitation headings remain exact. Rendered reports/limits and local links pass; public mutation68/14/11/10/50 and selector67/35/0/5/11 stay green without checker edits. Memory60 passes; history pressure is150 lines/33127 bytes and118/33067. The known large book search-index warning remains startup .41.9; normal doctrines remain required.
  Commit: `BACKEND-INTEGRATION-GUIDES.8.1 - own ARCHOGEN and SEMULITH consumer reports`

- ID: `BACKEND-INTEGRATION-GUIDES.8.2`
  Status: `done`
  Activation commit: `ff74b4c3b1977c2762ecd99a3f2a45cd460a4170`.
  Verification tier: `canonical`
  Focused checks: Isolated committed-source Cargo workspace reproduction for the example and PGEN manifests; standalone and enclosing-workspace metadata boundaries; successful managed native consumer build/use after the supported remedy; byte-exact dependency/source/lock preservation, guide rendering, public guards and all doctrines.
  Canonical trigger: The example Cargo manifest/workspace-boundary change is dependency/build infrastructure and requires the exact staged canonical receipt before landing. The remedy was selected from actual reproduction. No PGEN source/pin change or arbitrary dependency refresh is part of this leaf.
  Goal: Reproduce and repair Rust onboarding inside an enclosing Cargo workspace.
  Dependencies: `.8.1` committed clean.
  Scope: ARCHOGEN/LS-001 and SEMULITH/LS-003 item1; example manifest and PGEN preparation route, preserving the library's existing workspace boundary and all pre-existing nested edits.
  Acceptance: Use isolated clean committed source under a real host workspace; prove the reported failure and a supported remedy for both affected manifests. Verify an existing multi-crate application path and standalone use. Record the verification tier before any manifest or infrastructure edit. Do not patch the director's dirty PGEN checkout or claim metadata-only success proves a consumer build; split any necessary dependency work before changing pins.
  Reproduction: Cargo 1.95.0 reproduces both reported exit 101 workspace errors in an actual isolated Git submodule at ff74b4c3b with unchanged RGX 8763a0e6/PGEN db6f8c68. Twelve controlled metadata cases establish that excluding vendor/linkedspec in the host workspace isolates example, native library and PGEN; an example-only empty workspace leaves PGEN failing. Inputs are restored byte-exactly after each probe; no bootstrap or build is inferred from metadata.
  Selected remedy: The maintained example owns an empty workspace; enclosing applications merge vendor/linkedspec into their exclusion list before bootstrap/build. The pinned PGEN manifest and native library workspace remain unchanged. A two-member host consumer and separate example use verified same-pin generated inputs; standalone metadata, exact locks/source and native values pass.
  Verification: PASS two exit 101 baselines and twelve remedy probes in an actual isolated Git submodule at ff74b4c3b, with unchanged RGX/PGEN pins. The maintained committed-source verifier passes ten standalone/host/exclusion checks. A two-member application and separate example build locked/offline in 28.17s/18.72s; exact word values, three adapter tests and 18 Lispish file/deployment groups per consumer pass, including outside-cwd and relocation. Source blobs, 12 generated files/18576534 bytes and 15360 registry files/380075770 bytes are byte-verified. The 200-package reference lock is exact; the 201-package host graph changes only local identities. No PGEN source/pin/dirty-file mutation, new bootstrap, minimum-version/platform expansion or actual downstream application build is claimed. Book/public, preservation and all doctrines govern landing; exact staged canonical CI is required before commit.
  Candidate proof: PASS 2836 prior files and 2809/2810 prior task nodes unchanged, all previous history bytes and 94 book limitation headings preserved. Only this leaf changes a prior task node. Public mutation68/14/11/10/50 and selector67/35/0/5/11, book/includes/links, Knowledge1151/9198, memory60, both history checks and all nine doctrines pass. History roots are156 lines/34168 bytes and124/34121. The known search-index warning (10811336 bytes) remains startup .41.9. No source-reading credit or grammar repair claimed.
  Commit: `BACKEND-INTEGRATION-GUIDES.8.2 - repair Rust consumer workspace boundaries`

- ID: `BACKEND-INTEGRATION-GUIDES.8.3`
  Status: `done`
  Activation commit: `effe3e7b2544abf79f7786a7aa54e77b1893880e`.
  Verification tier: `focused`
  Focused checks: Isolated committed-source RGX public bootstrap and repeat; native two-member consumer build, word/file/deployment values and adapter tests; public-interface failure evidence; source/pin/lock preservation; dependency-knowledge residue audit; rendered guidance, public guards, Knowledge and all doctrines.
  Canonical trigger: None for the corrected documentation-only leaf. The proposed helper/test are removed; no source, manifest, dependency pin, workflow implementation or checker changes remain. Existing RGX and managed-runner interfaces are used. Final integration .7 retains canonical proof; the stopped obsolete candidate run is diagnostic only.
  Goal: Use RGX's published integration interface and remove dependency-internal knowledge from maintained guidance and plans.
  Dependencies: `.8.1`, `.8.2` committed clean.
  Scope: ARCHOGEN/LS-004 public-interface reporting and the September20 director correction. LinkedSpec integrates only with RGX; RGX owns PGEN and transitive preparation. Remove the uncommitted internal-procedure helper/test, dependency implementation assumptions and contrary pending plans. Preserve published contracts, observable results and upstream report ownership.
  Acceptance: Use RGX's documented make bootstrap command through existing managed storage. Prove normal supported use without source overlays and report failure-path behavior without internal investigation. Keep unresolved upstream reports open. RGX/PGEN source and pins are read-only; do not inspect or analyze implementation. Agent instructions, Knowledge, book and task plans must enforce this boundary.
  Director correction: The candidate incorrectly reconstructed transitive preparation despite the already-adopted RGX public build contract. It was discarded before commit; original dependency edits/pins remained unchanged. Canonical session87814 was deliberately stopped/consumed with exit143 and grants no receipt. Prior implementation-derived experiments do not certify the replacement and are removed from maintained knowledge.
  Public verification: RGX's documented command succeeds on Git-archived LinkedSpec effe3e7b2 and unchanged dependency revisions, with no source overlays. Offline preparation56.19s and repeat0.22s use a verified local registry copy. Native two-member host build26.65s, exact outside-cwd word result,18 Lispish file/deployment groups and three adapter tests pass. Locks remain exact. Evidence: .linkedspec-data/scratch/backend-integration83/public-interface. No actual downstream application, empty-cache network, release/cross-platform, grammar repair or upstream message fix claimed.
  Upstream ownership: RGX-CONSUMER-BUILD-REPORTS.1 owns the reported misleading progress message through public-interface reproduction and upstream response; no dependency diagnosis or patch is authorized. This documentation correction does not close that report.
  Verification: PASS public bootstrap/repeat and native consumer proof above; empty-store offline public bootstrap exits2 with misleading intermediate progress and no final success message. The self-contained report is docs/upstream/rgx/bootstrap-progress-status.md; no internal diagnosis or fix is claimed. Retired implementation knowledge/helper/tests are removed; 29 obsolete scratch paths (33940 files/5503577031 bytes) are deleted with exact absence and unchanged original submodule diff. Mechanical preservation verifies2828 unchanged parent files, all three consumer source snapshots with zero overlays, exact locks and unchanged original sources/pins. Knowledge1151/9193, rendered book, public mutation68/14/11/10/50, selector67/35/0/5/11 and all nine doctrines pass. Final memory/history/staged checks govern landing; no canonical receipt is claimed.
  Commit: `BACKEND-INTEGRATION-GUIDES.8.3 - use RGX public integration`

- ID: `BACKEND-INTEGRATION-GUIDES.8.4`
  Status: `done`
  Activation commit: `a1166ee1d9ce8fce0dfc8f75903d0734ab41c975`.
  Verification tier: `focused`
  Focused checks: Rendered forward/back prerequisite links and command ordering; qualified downstream checkout observation; unchanged runnable examples, source, dependencies and locks; public documentation guards, Knowledge, both history checks and all doctrines.
  Canonical trigger: None for navigation and qualification prose only. No code, manifests, dependency pins, public contract or infrastructure change; final .7 retains canonical proof.
  Goal: Close first-consumer setup-ordering and checkout-cost gaps in the Rust guide.
  Dependencies: `.8.1`, and the supported setup remedies from `.8.2` and `.8.3`.
  Scope: ARCHOGEN/LS-005 and SEMULITH/LS-003 items2-3; forward prerequisite pointer after checkout, a prerequisite back-reference at file parsing, and clear targeted dependency initialization.
  Acceptance: A reader entering either setup or file parsing reaches all required preparation before building. Explain optional recursive checkout cost with qualified evidence; do not turn a downstream disk measurement into a universal size guarantee. Verify the rendered navigation and final runnable sequence without duplicating the canonical setup instructions.
  Verification: PASS two rendered prerequisite entry points and56 local links across the Rust guide/status pages; all includes resolve. All21 fenced examples match clean a1166ee1d byte-for-byte, preserving the previously verified public RGX/native sequence. SEMULITH's reported1.7GB/30-submodule observation is explicitly dated and qualified, not a measurement of the targeted route. Mutation68/14/11/10/50 and selector67/35/0/5/11 pass without checker changes. Source/pins/locks and prior history remain unchanged; Knowledge, memory/history and all doctrines govern focused landing. No dependency rebuild, fresh network checkout, upstream repair or grammar fix is claimed. Evidence: .linkedspec-data/scratch/backend-integration84.
  Commit: `BACKEND-INTEGRATION-GUIDES.8.4 - clarify Rust integration prerequisites`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `BACKEND-INTEGRATION-GUIDES.6` | `pending` | Connect common navigation after clean .5.3 diagnosis/handoff; the managed-wrapper defect stays owned by startup .7 with unchanged reading prerequisites. |

The director explicitly requests a temporary pivot at the next clean handoff.
Conformance .1.34 is committed at 00f9783a1 and inventory .0 is complete.
Rust .2.2 is committed and pushed at ad290bdb427bc19a5af81de0f0b07e119c8999ff. Perl, Dart and Julia guide leaves are committed. Lua setup .5.1 commits at 7f2afcbf428a6a29b7c82d8c618e2312eaa16e6c after exact canonical CI, both CLI66/66 and Phase0 1032/1032 in1168s;25 optional extensions were skipped. Its post-commit pointer, promoted receipt, empty brief, clean root and unchanged PGEN edits are verified. The director's consumer reports now require bounded integration setup repairs before final .7. Ordinary guide/example work needs no further permission.

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

## Acceptance Checklist — .4.1

- [x] **REPRODUCE / ISSUE** — No Julia application integration page or standalone consumer project exists at activation. The new page deliberately makes the exact public inventory gates RED until count-only reconciliation.
- [x] **ROOT CAUSE (WHY + WHERE)** — Native loading APIs are already admitted, but application project activation, relative local source selection, own dependency lock/depot and package-owned supporting grammar are not assembled into a runnable onboarding path.
- [x] **FIX** — Add the application project, Pkg-generated manifest, direct-value consumer, setup verifier and source-included chapter. Keep application grammar resolution explicit because the managed Julia wrapper changes cwd.
- [x] **ADDRESSED (verified)** — Eleven groups pass on both working and clean pinned-source applications. Fresh owned online preparation and separately prepared offline source/registry reuse pass; exact package and supporting-grammar provenance are checked.
- [x] **NO REGRESSION** — Eighty-two native loader assertions and the14/9/4 contract pass. Inventory changes are count-only; source, pins, existing task nodes, book limitations and immutable history are preserved. Exact staged canonical CI governs this public-page/manifest landing.
- [x] **LOCKSTEP** — Guide, runnable includes, Knowledge, roadmap, task and bounded history agree. Julia deployment/errors .4.2 follows clean commit; independent .7 retains parent closeout and canonical push before conformance .1.35.

## Acceptance Checklist — .4.2

- [x] **REPRODUCE / ISSUE** — The previous adapter rejects --diagnostics as a missing grammar; there is no application deployment launcher. Its native library already exposes the required typed events and exits.
- [x] **ROOT CAUSE (WHY + WHERE)** — The adapter does not supply runtime_execute's diagnostic_output_sink or classify RuntimeExitNow. Julia package-source grammar discovery and relative application manifests must remain valid in a deployed source tree.
- [x] **FIX** — Extend only the consumer, add diagnostic/exit fixtures and an application-rooted launcher, and document pinned Git archive assembly with retained package sources and explicit offline preparation.
- [x] **ADDRESSED (verified)** — Both applications pass 24 deployment checks and11 setup/value groups. Bad packaged assets prove selection; missing assets fail before ancestor fallback. Exact source, manifest and package hashes survive Unicode relocation and repeated outside-cwd calls.
- [x] **NO REGRESSION** — Native loader 82 plus diagnostic 82 assertions pass. Public inventories remain67/66 with unchanged semantic checkers; runtime source, pins, prior tasks, history and book limitations are preserved.
- [x] **LOCKSTEP** — Runnable includes, guide, Knowledge, roadmap and task records agree. Focused proof governs this leaf; Lua .5.1 follows clean commit and independent .7 retains final parent closeout/canonical push.

## Lua integration history capacity — September 20 proposal and approval

The director granted the exact proposal below on September 20. Its pre-admission
measurements remain historical evidence; ADR0121 records the accepted implementation.

Owner: `BACKEND-INTEGRATION-GUIDES.5.1`; preserve its unfinished native-guide candidate.
No pivot or threshold change has occurred. The current canonical leaf cannot land
while the README routing-pressure doctrine rejects the required history rollover.

Both new complete records crossed the existing 90% hot-shard rollover threshold:
CHANGES was 268 lines / 59031 bytes; DEVELOPMENT_NOTES was 224 / 60008.
The normal rollover tool preserved clean 0b409e305 history as two exact new segments:
changes 4974, 126 lines / 27065 bytes, SHA256
38bd13bb0125cfb12dbba6255586b14c13c541438a7904a29547e5135143ef92;
notes 4973, 114 lines / 28169 bytes, SHA256
2fb7ebaade12c0117e9f726745d8ec73fd615d8b99d0166f396e830437ec3bd7.
Earlier segment bytes and manifest rows are unchanged. Removing the new record
from each hot shard and appending its new archive reconstructs the prior HEAD
file exactly. The gate rejects only these six current history controls:

| Surface | Control | Current limit | Proposed limit / actual candidate |
| --- | --- | ---: | ---: |
| change_history | Collection files, including root and manifest | 38 | 39 |
| change_history | Manifest lines | 37 | 38 |
| change_history | Manifest bytes | 21071 | 21647 |
| engineering_notes | Collection files, including root and manifest | 34 | 35 |
| engineering_notes | Manifest lines | 33 | 34 |
| engineering_notes | Manifest bytes | 19902 | 20514 |

This proposal adds one archive slot per collection. All live-file, per-archive and
aggregate byte/line limits, routes, schemas, checkers and stable responsibilities
remain unchanged. It requests no CI exception. After approval, an accepted indexed
ADR must record the exact old/new objects before the six registry values change;
canonical CI and all normal hooks must pass before .5.1 can commit.

Finite scope: the remaining integration deployment, navigation and final review,
plus four capacity/closeout allowances, are modeled as seven complete records of
at most 14 lines / 2048 bytes each. After the current rollover, the resulting hot
shards would be at most 240 lines / 46302 bytes and 208 / 46175: no additional
rollover. This allowance does not cover the later unlimited PNT/source-reading
activity. Remeasure each actual candidate.

Alternatives considered: retaining the longer hot shards violates the mandatory
90% rollover rule; deleting or repacking immutable history breaks preservation.
Shorter current summaries could defer this one rollover, but do not provide the
measured space for the remaining activity. The proposed two slots retain ordinary
readable per-slice records and existing retrieval. README_POLICY.md requires an
accepted decision for a routed-limit increase, and ADR0118 explicitly says its
finite Lua-reading allowance does not authorize later capacity increases.

Validation already consumed: 13 checks per consumer/runtime (four runs), five
selected native tests per runtime, neutral contract 14/9/4, mutation 68/14/11/10/50,
selector 67/35/0/5/11, book render and exact preservation of 2821 prior files,
2803/2805 task nodes, 94 known book limitation headings and original PGEN edits.
All nine worktree doctrines were consumed: eight pass; README-STABILITY alone
fails on those six capacity controls. No inputs are staged, so this is not a
canonical receipt or pre-commit acceptance claim. The remaining blockers are
capacity disposition, accepted authority if approved, all-doctrine closeout and
exact staged canonical CI. No gate receipt or commit is
claimed. Replay the maintained Lua verifier and both history pressure checks;
scripts/check_readme_stability.sh reproduces the six denials before admission.

### Approved implementation and verification

The September 20 **Granted** reply authorizes exactly the six controls above.
ADR0121 is accepted and indexed; only those six registry scalars change.
Forty-four production threshold checks and 34 production authorization cases pass,
including absent/altered ADR, missing index, wrong surface and unauthorized limits.
The pre-admission eight-pass/one-fail report above remains dated RED evidence;
the complete resulting candidate must pass normal doctrines and canonical CI.
Original history, classifier behavior and runtime sources remain unchanged.
Final preservation verifies 2819 prior files, 2803 of 2805 prior task nodes, all
94 book limitation headings, the original PGEN edits and every earlier history
byte. Exactly six approved registry scalars differ; the decision index retains
all earlier bytes. With final admission overhead, seven further records produce
at most 242 lines / 46536 bytes and 210 lines / 46409 bytes. All hot-shard,
archive and aggregate controls remain unchanged.
No verification waiver is requested or applied. Lua .5.2 follows clean landing.

## Acceptance Checklist — .5.1

- [x] **REPRODUCE / ISSUE** — Lua lacks an application integration chapter and retained-product consumer; the existing targeted test wrapper rebuilds disposable modules. Adding the page exposes exact public inventory counts 67/68 and 66/67.
- [x] **ROOT CAUSE (WHY + WHERE)** — Module search paths, selected ABI products and module-relative supporting grammar must agree. The generic managed wrapper preserves caller cwd; the targeted Lua wrapper creates and deletes native products per invocation.
- [x] **FIX** — Add explicit-path native consumer, setup verifier and guide; document matching interpreter/header identities, per-ABI builds, application storage, direct values and native reuse. Reconcile only current public-file counts and stale storage-card wording.
- [x] **ADDRESSED (verified)** — Both working and clean pinned applications pass 13 groups per runtime, including supporting grammar identity/cache, Unicode paths, null/false, failures and ambient initialization exclusion. All six native hashes and mtimes remain exact.
- [x] **NO REGRESSION** — Five selected loader tests pass per runtime. Existing PUC 5.4 proof and malformed-regex exclusions remain visible and owned; runtime source, pins, prior tasks and book limitations remain unchanged.
- [x] **LOCKSTEP** — Guide/includes, Knowledge and live records agree. ADR0121 implements the six approved history controls with exact preservation and 44/34 production-function checks; all normal doctrines and exact staged canonical CI govern landing. Deployment is .5.2; independent parent closure and final push remain .7.

## Acceptance Checklist — .8.3

- [x] **REPRODUCE / ISSUE** — Verify RGX's published bootstrap route on isolated committed sources; retain any failure-path report with exact public command/environment/output.
- [x] **ROOT CAUSE (WHY + WHERE)** — LinkedSpec's guide bypassed the existing RGX integration contract. Correct the caller boundary; dependency implementation diagnosis remains upstream.
- [x] **FIX** — Remove the uncommitted custom helper/test, use only RGX's documented interface, and remove internal dependency knowledge and contrary plans.
- [x] **ADDRESSED (verified)** — Prove native consumer use and preserved sources/pins/locks. Keep unresolved upstream and Lispish reports explicitly open.
- [x] **PREVENT** — AGENTS, MEMORY, Knowledge and task guidance enforce RGX-only public integration without implementation inspection.
- [x] **VERIFY / COMMIT** — Finish residue/preservation, book/public, Knowledge/history/memory and doctrine checks; commit this leaf and clear the brief before .8.4.


## Acceptance Checklist — .8.4

- [x] **REPRODUCE / ISSUE** — Source-qualified ARCHOGEN/LS-005 and SEMULITH/LS-003 items2-3 identify missing preparation pointers and recursive-checkout cost guidance.
- [x] **ROOT CAUSE (WHY + WHERE)** — Rust checkout and file-parsing entry points lacked direct links to the existing required workspace, storage and RGX sections.
- [x] **FIX** — Add forward/back prerequisite links and a dated, qualified checkout observation; retain one canonical setup sequence and RGX's public authority.
- [x] **ADDRESSED (verified)** — Both entry points resolve all three prerequisites;56 rendered local links and includes pass. All21 fenced examples remain byte-exact.
- [x] **NO REGRESSION** — Native examples, runtime, manifests, dependency source/pins/locks and grammar limits are unchanged; public guards pass.
- [x] **VERIFY / COMMIT** — Focused book/navigation/preservation, Knowledge/history/memory and doctrine checks govern this leaf's commit and brief cleanup; Lua .5.2 follows only from a clean tree.

## Acceptance Checklist — .5.2

- [x] **REPRODUCE / ISSUE** — Managed native old-consumer probes reject --diagnostics as a grammar path and classify typed exit as consumer_error. Existing Lua runtime_parse/diagnostic APIs supply the required events/control type.
- [x] **ROOT CAUSE (WHY + WHERE)** — examples/integration/lua/bin/parse_words.lua lacks option/sink/exit branches. Public native error/projection output and interpreter.lua to_json establish why optional arity fields need explicit adapter copying. No runtime serializer defect is inferred.
- [x] **FIX** — Add the bounded adapter, relative-root launcher, grammar examples, deployment verifier and matching guide; preserve runtime and native implementation.
- [x] **ADDRESSED (verified)** — Final working/clean applications pass13 setup and24 deployment groups per ABI; native diagnostic contract119 per ABI passes. Exact events, typed records, source attribution, earlier outputs and stopping behavior match expectations.
- [x] **NO REGRESSION** — Native hashes/mtimes, source/pins/locks and immutable history stay exact. LINKEDSPEC_TRACE_LEVEL hostile controls preserve caller trace bytes. Prior malformed-regex and PUC5.4 exclusions remain; the unexplained initial stderr is owned by .5.3, not classified as fixed.
- [x] **LOCKSTEP** — Guide, project status, Knowledge, task/index, roadmaps, bounded histories and MEMORY describe the verified routes and unresolved observation. Focused public/book/doctrines and git diff --check govern landing; .7 retains canonical proof.

## Acceptance Checklist — .5.3

- [x] **REPRODUCE / ISSUE** — Exact four-way Lua consumer replay captures a correct-value/status0 command with non-JSON child-setpgid stderr in round5; full raw streams retained.
- [x] **ROOT CAUSE (WHY + WHERE)** — Captured stderr names the managed Bash wrapper. rg -n and its monitor-mode launch identify the emitting layer; the Knowledge Map maps the same warning to existing startup .7. Kernel/timing cause and the original lost PUC stream remain unproved.
- [x] **FIX** — Correct integration guidance and route concrete evidence to the existing mandatory-reading-gated infrastructure repair. No implementation fix, warning suppression or prerequisite bypass is claimed.
- [x] **ADDRESSED (verified)** — A1000-command public PID/PGID probe captures one warned invocation with actual matching PID/PGID29222; all outcomes consumed. This closes the integration investigation/handoff, not startup .7.
- [x] **NO REGRESSION** — Source/native/dependency/history bytes remain unchanged; no rebuild or recovery/purge. Read-only list finds0 runs. Public documentation guards and git diff --check govern the documentation-only slice.
- [x] **LOCKSTEP** — Book, canonical Knowledge, existing repair acceptance, task/index, roadmaps and bounded continuity retain the exact evidence and remaining limitations.

## Verification Log

- `2026-09-20` .5.3: Capture the managed-wrapper warning with correct Lua values/status0;19 complete consumer routes precede/parallel the failing quiet-stderr expectation. A1000-command probe captures matching actual/warned PID/PGID29222. Existing startup .7 remains the repair owner; original lost stream and denied-call cause remain unknown. No implementation change or defect closure.

- `2026-09-20` .5.2: Final13 setup/24 deployment groups pass in four consumer/runtime routes;119 native diagnostic assertions pass per ABI. Clean2852-file library,172-file runtime closure and179-file diagnostic bundle are verified without native builds. Original non-JSON stderr remains .5.3 despite full replay plus160 clean focused controls; harness now preserves raw failure evidence.

- `2026-09-20` .8.4: PASS two prerequisite entry points,56 rendered local links,21 unchanged fenced examples and both public guards. Recursive cost is a qualified downstream report; no new build or grammar proof. Final focused preservation/continuity/doctrines govern landing.

- `2026-09-20` .8.3: Use RGX public integration only; discarded procedure and internal dependency knowledge removed. Public bootstrap, native consumer, preserved sources/pins, report and focused documentation checks pass. Upstream message issue remains open; guidance .8.4 follows clean commit.

- `2026-09-20` .8.2: PASS two exit 101 baselines and twelve remedy probes in an actual isolated Git submodule at ff74b4c3b, with unchanged RGX/PGEN pins. The maintained committed-source verifier passes ten standalone/host/exclusion checks. A two-member application and separate example build locked/offline in 28.17s/18.72s; exact word values, three adapter tests and 18 Lispish file/deployment groups per consumer pass, including outside-cwd and relocation. Source blobs, 12 generated files/18576534 bytes and 15360 registry files/380075770 bytes are byte-verified. The 200-package reference lock is exact; the 201-package host graph changes only local identities. No PGEN source/pin/dirty-file mutation, new bootstrap, minimum-version/platform expansion or actual downstream application build is claimed. Book/public, preservation and all doctrines govern landing; exact staged canonical CI is required before commit.

- `2026-09-20` .8.1: Read all ten source-qualified reports and supporting instructions/reproducers/fixtures/evidence. Byte-exact same-volume snapshots contain ARCHOGEN43 files/75512 bytes and SEMULITH29/26871, with manifest identities in the canonical Knowledge card. Five open ARCHOGEN reports, one withdrawn, one no-action and three draft SEMULITH reports are all accounted for. Runtime reproduction count is zero for this intake; supplied patch and build observations are not promoted into local proof. Setup repairs are .8.2-.8.4; grammar fixes retain startup .83 prerequisites and implementation/admission owners. Focused preservation, book/public checks, Knowledge, memory/history and all doctrines govern landing.

- `2026-09-20` .5.1: PASS 13 setup checks per runtime in working and clean pinned 0b409e305 applications on macOS arm64, PUC Lua 5.5.1, LuaJIT 2.1.1788460057 and PCRE2 10.48. Exact interpreter/header identities, source/module paths, native trio loading, module-owned supporting grammar and its one-build cache are verified. Independent/repeated values, Unicode grammar paths, missing arguments/files, strict UTF-8, successful null/false and ambient-init exclusion pass. Six retained native products preserve hashes and modification times across fresh processes. Five selected existing native loader tests pass per runtime; excluded malformed-regex and unfiltered Lua gates are not run, and the declared PUC 5.4 target remains unverified. Clean source matches 2842 files / 58811026 bytes with public submodule URL, uninitialized nested dependencies, same-volume source/data and exact original PGEN edits. Artifact census retains 3260 candidates / 6165392650 bytes and deletes zero. New-page RED counts are mutation 67/68 and selector 66/67; only expected counts and current prose advance to 68 and 67. Book, source/task/history preservation, Knowledge and all doctrines govern landing; exact staged canonical CI is required. No runtime, dependency pin or reading-credit change; .5.2 and independent .7 remain open.

- `2026-09-20` .4.2: PASS 24 deployment checks in both current and clean pinned 29bf3fdd1 applications on Julia 1.12.7/macOS arm64. Twelve source cases cover exact Unicode events, quiet defaults, typed exit/prior-output/stop behavior, runtime source identity, null success, four loader stages, usage and inherited trace separation. Git-archived source and verified package/registry copies prepare offline without copied compiled caches. Outside-cwd, option-like paths, controlled bad/missing packaged grammar, Unicode relocation and fresh-process reuse pass. The clean application manifest is copied byte-exactly; source, manifest and package hashes survive preparation/moving. Both word verifiers pass 11 groups; native loader 82 and diagnostic 82 assertions pass. Clean source matches 2838 files / 58774855 bytes; nested dependencies stay uninitialized, all project data remains on this volume and original PGEN edits remain exact. Public mutation 67/14/11/10/50 and selector 66/35/0/5/11 pass unchanged. Focused book, source/task/history preservation, Knowledge and all doctrines govern landing. No runtime/pin changes or reading credit; independent parent closeout and canonical push remain .7.

- `2026-09-20` .4.1: PASS 11 setup/value groups against both current and clean pinned 49758cbc9 source on Julia1.12.7/macOS arm64: explicit application project, relative manifest path, package/module provenance, source-first supporting grammar with controlled bad cwd asset, independent/repeated values, Unicode/relative paths, strict UTF-8, missing arguments/files and successful null. Native loader tests pass82 assertions (34/24/10/6/8), and the shared contract remains14/9/4. Initial online preparation writes only the application depot; subsequent offline preparation and fresh-process parsing pass. Clean preparation copies/verifies148 package-source files/734878 bytes and2 registry files/11419507 bytes from the owned depot without copying compiled caches. The app-generated manifest selects JSON3 1.14.3, Parsers2.8.8, PrecompileTools1.3.4, Preferences1.6.0 and StructTypes1.11.0; the backend manifest and source remain unchanged. Clean submodule source matches2832 files/58732023 bytes, retains the public origin and leaves nested dependencies uninitialized. Source/data stay on this volume and the original PGEN diff remains exact. Public RED expected66/observed67 and65/66 becomes GREEN mutation67/14/11/10/50 and selector66/35/0/5/11 by count-only updates; classifier/frozen authorities stay unchanged. Book, source/task/history preservation, Knowledge and all doctrines govern this leaf; exact staged canonical CI is required for landing. No runtime/pin changes, minimum-version/platform expansion or reading credit; .4.2 retains deployment/runtime diagnostics and .7 retains independent parent closeout and canonical push.

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

- `.5.3`: `BACKEND-INTEGRATION-GUIDES.5.3 - trace consumer stderr to managed wrapper`; activation1ab8e8ac3; focused diagnosis/public-evidence handoff, then common .6.

- `.5.2`: `BACKEND-INTEGRATION-GUIDES.5.2 - verify Lua deployment and diagnostics`; activation6e37288f7; focused examples/book proof. Unexplained stderr .5.3 follows; common .6 and final .7 remain.

- `.8.4`: `BACKEND-INTEGRATION-GUIDES.8.4 - clarify Rust integration prerequisites`; activation a1166ee1d; focused navigation proof, then Lua .5.2.

- `.8.3`: `BACKEND-INTEGRATION-GUIDES.8.3 - use RGX public integration`; activation effe3e7b2; focused documentation/public-interface proof, then guidance .8.4.

- `.8.2`: `BACKEND-INTEGRATION-GUIDES.8.2 - repair Rust consumer workspace boundaries`; activation ff74b4c3b; manifest infrastructure requires exact staged canonical proof, then bootstrap .8.3.

- `.8.1`: `BACKEND-INTEGRATION-GUIDES.8.1 - own ARCHOGEN and SEMULITH consumer reports`; activation7f2afcbf4; next isolated Rust workspace repair .8.2.

- `.5.1`: `BACKEND-INTEGRATION-GUIDES.5.1 - document and verify native Lua integration`; activation 0b409e305. Native setup and approved ADR0121 capacity proof verified; exact staged canonical receipt governs landing.

- `.4.2`: `BACKEND-INTEGRATION-GUIDES.4.2 - verify Julia source deployment and diagnostics`; activation29bf3fdd1; next Lua .5.1 after clean focused handoff.

- `.4.1`: `BACKEND-INTEGRATION-GUIDES.4.1 - document and verify native Julia integration`; activation49758cbc9; next Julia .4.2 after clean canonical handoff.

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

- `2026-09-20` .5.3: Capture unexpected stderr's managed-wrapper layer and a warned child with the expected group; consolidate repair evidence into startup .7 without source changes or a false fix claim.

- `2026-09-20` .5.2: Deliver Lua deployment/diagnostic examples with dual-runtime proof; own unexplained initial stderr separately under .5.3 without a false fix claim.

- `2026-09-20` .8.4: Correct Rust setup/file-entry navigation and qualify recursive-checkout cost; source/examples and public RGX preparation stay unchanged.

- `2026-09-20` .8.3: Use RGX public integration only; discarded procedure and internal dependency knowledge removed. Public bootstrap, native consumer, preserved sources/pins, report and focused documentation checks pass. Upstream message issue remains open; guidance .8.4 follows clean commit.

- `2026-09-20` .8.2: Repair Cargo example/host boundaries with committed-source regression and native two-member consumer proof; preserve pins, locks and all earlier dependency edits.

- `2026-09-20` .8.1: Own the director-supplied ARCHOGEN and SEMULITH reports, preserve their distinct states and route concrete fixes without closing unverified scope.

- `2026-09-20` .5.1: Verify Lua native setup and retained products on both installed runtimes; preserve target/formatter exclusions and independent .7 closeout.

- `2026-09-20` .4.2: Verify Julia source deployment, optional diagnostic events and typed failures; retain independent parent closeout at .7.

- `2026-09-20` .4.1: Verify native Julia application setup, local package/depot ownership and exact source/grammar provenance; retain deployment and runtime diagnostics for .4.2.

- `2026-09-19` .3.2: Verify native Dart diagnostic events, typed failures and relocated AOT deployment; retain all runtime/gate repair ownership.

- `2026-09-19` .3.1: Deliver Dart native integration with local package and required supporting-grammar proof; preserve existing runtime/gate repair ownership.

- `2026-09-19` .1.2: Verify Perl deployment/errors/sinks; retain independent parent closeout at .7 and advance to Dart .3.1.

- `2026-09-14` .1.1: Deliver native Perl setup and measured core/module closure; preserve dependency sources and update the two direct public inventories. Rust checkpoint push is verified.

- `2026-09-13` .2.2: Complete Rust Lispish file/deployment guide and clean pinned-source proof; record exact extraction limits and own strict parsing under startup .83.

- `2026-09-13` .2.1: Deliver Rust setup/native guide and runnable locked consumer; cancel the no-dependency-build restriction as directed; retain startup .80 performance ownership.

- `2026-09-13` .0: Complete five-backend setup/API/content-routing inventory; choose Rust-first implementation and preserve the conformance return point.
- `2026-09-13`: Track the director-requested five-backend integration guides,
  consumer examples, dependency reuse, deployment/error proof and canonical closeout.
