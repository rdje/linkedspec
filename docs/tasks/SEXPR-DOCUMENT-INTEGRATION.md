# SEXPR-DOCUMENT-INTEGRATION: Deliver and admit complete document integration

## Metadata

- Tree ID: `SEXPR-DOCUMENT-INTEGRATION`
- Status: `done`
- Roadmap lane: `Native integration / ARCHOGEN and SEMULITH document reports`
- Created: `2026-09-23`
- Last updated: `2026-09-23`
- Owner: repo-local workflow
- Intake owners: `SESSION-STARTUP-READING.83.2.3` and `.83.3`

## Goal

Finish native file delivery and independent admission of ADR0124's complete,
kind-preserving s-expression document contract. The grammar and six-runtime
contract implementation are committed at `77d7b3db1b65a2c83072447a6aec77456ca7aede`.
The remaining reports are ARCHOGEN/LS-002 complete input/all forms,
ARCHOGEN/LS-003 token kinds, and SEMULITH/LS-002 token kinds.

## Non-Goals

- Do not change historical Lispish behavior, its adapter, the authored contract,
  runtime APIs, dependency implementation, pins or build procedures.
- Do not implement a downstream application's schema or claim its acceptance.
- Source-layout relocation is not a cross-platform or release-profile guarantee.

## Acceptance Criteria

- Deliver a separate native Rust `sexpr_file` example through public loader and
  engine APIs, preserving the tagged document directly.
- Verify all 37 authored cases as real files, including all report examples;
  strict UTF-8, paths, failures, multiple files, packaging and relocation.
- Retain historical Lispish file-consumer checks.
- Independently recompose six-runtime grammar proof and native integration
  boundaries; synchronize every backend integration guide and the shared book.
- Keep all project data on the repository volume, preserve task/history evidence
  and limits, and commit each leaf through `COMMIT.md`.

## Task Tree

- ID: `SEXPR-DOCUMENT-INTEGRATION`
  Status: `done`
  Goal: Deliver native file integration and close the verified document-report scope.
  Children: `SEXPR-DOCUMENT-INTEGRATION.1`, `SEXPR-DOCUMENT-INTEGRATION.2`

- ID: `SEXPR-DOCUMENT-INTEGRATION.1`
  Status: `done`
  Activation commit: `77d7b3db1b65a2c83072447a6aec77456ca7aede`.
  Verification tier: `focused`
  Focused checks: Build the new native binary; run its maintained 37-case file verifier and UTF-8/argument/grammar/error/multi-file/packaging/relocation checks; rerun the historical Lispish verifier and adapter tests; check formatting, Python syntax, public documentation guards, mdBook, Knowledge/memory/history/diff and all doctrines.
  Canonical trigger: None for this bounded example/test/documentation delivery through the already admitted public APIs and committed grammar. No runtime, contract, dependency, CI or checker changes are planned. Final independent admission and parent closeout belong to .2 with exact canonical proof.
  Goal: Deliver startup .83.2.3's implementation through a separate native Rust document-file consumer; .2 owns formal parent closeout.
  Dependencies: Clean grammar checkpoint `77d7b3db1`.
  Scope: New Rust example and process verifier, integration/book examples, delivery-status metadata only in the existing contract (authored cases unchanged), continuity and report pointers; establish this bounded semantic execution tree while retaining all stable startup IDs and their requirements. Observe the due artifact census; retain reusable caches and current evidence, deleting only exact obsolete artifacts created by this session.
  Acceptance: Preserve every authored expected value; accept all valid files in one engine; reject malformed documents without their partial output; retain earlier successful files when a later file fails; preserve token kinds and lexical spelling without an adapter; verify strict UTF-8, caller-relative and Unicode paths, explicit/default assets and moved bundles. Keep old Lispish behavior green and all documentation accurate.
  Verification: PASS: 37 unchanged authored cases as real files (21 accepted in one engine and 16 typed rejections), 36 process-check groups including the published example, Unicode/relative paths, strict UTF-8, malformed grammar before input loading, earlier-output retention, default/explicit assets and relocation with all 21 valid cases. Binary/grammar/contract hashes stay exact and owned fixtures are removed. Historical Lispish passes 26 file values/18 groups and all three adapter tests. Native build, Rust formatting and Python syntax pass; the grammar and authored case array remain unchanged. Book/public guards, Knowledge/memory/history/diff and normal doctrines govern the focused landing; .2 owns independent canonical admission and formal parent closeout.
  Commit: `SEXPR-DOCUMENT-INTEGRATION.1 - deliver native s-expression file consumer`

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE** — Clean77d7b3db1 has no sexpr_file source. The unchanged historical adapter fails the new independent file verifier on the empty document, proving that swapping only the grammar path is insufficient.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Public LinkedSpec loader/Engine execution produces the tagged document; examples/integration/rust/src/bin/lispish_file.rs::decode_form requires historical array/head-tail values. Committed LinkedSpec::Get/return_descriptor proof at 77d7b3db1 establishes grammar readiness; no grammar or dependency repair is inferred from adapter output.
  - [x] **FIX** — Add the separate native sexpr_file executable, explicit Document selection, direct-value output, typed error causes with input identity and executable-relative grammar lookup.
  - [x] **ADDRESSED (verified)** — The maintained verifier passes all 37 authored file cases and 36 process groups, including published output, strict UTF-8, error order, prior-output retention and all valid files after relocation.
  - [x] **NO REGRESSION** — Historical Lispish remains unchanged and passes 26 file values/18 groups plus 3 adapter tests; the grammar and authored expectations remain exact. Rust formatting and Python syntax pass.
  - [x] **LOCKSTEP** — All backend guides retain one shared grammar contract; Rust file use, error records and packaging are documented and verified. Task, roadmap, Knowledge and live pointers retain separate final-admission ownership.

- ID: `SEXPR-DOCUMENT-INTEGRATION.2`
  Status: `done`
  Goal: Independently admit the complete document integration and close startup .83.3 and its completed parents.
  Dependencies: .1 committed at df845ce615df20929ac501b61984fbf9d29225ca; clean tree, post-commit pointer and zero-byte brief verified.
  Verification tier: `canonical`
  Focused checks: Six-runtime authored contract and same-engine recovery; maintained public-loader replay of the documented entry-rule adaptations, exact values/rejections and strict grammar UTF-8; native Rust file/relocation and historical Lispish checks; every backend guide, public guards, book, Knowledge/memory/history/diff and doctrines.
  Canonical trigger: Independent final admission and startup-parent closeout; exact staged canonical receipt required.
  Review correction: The first Julia replay used the library project. Before landing, select the documented integration example Project/Manifest and its prepared application-local depot, disable user load paths and keep offline mode. The corrected example-project replay passes all 37 cases and 21 groups (admission-julia-example.log). The initial canonical run was cancelled with status 143 before final verification; a revised exact-candidate run is required.
  Scope: Add a maintained public-loader integration verifier and document its per-backend commands. Exact six-runtime grammar replay, public loading and documented failure boundaries, native Rust file/UTF-8/packaging replay, historical Lispish compatibility and all-backend guide reconciliation. Preserve the distinction between library verification and downstream application acceptance.
  Acceptance: Recompose the unchanged authored values/rejections and same-engine reuse across six runtimes, verify native public loading/integration evidence, and rerun file/UTF-8/error/multi-file/relocation checks. Record exact supported routes and remaining limits, close only verified report scope, and require exact staged canonical CI before the final clean handoff.
  Verification: PASS: all 37 unchanged authored cases through each of six public-loader routes (222 outcomes), with 21 process groups per route covering exact values, typed rejection or the Rust text adapter Display, prior-output retention, relative Unicode grammar paths, invalid UTF-8 and missing grammar. Native Rust file replay passes 37 cases/36 groups; historical Lispish passes 26 values/18 groups. The recurring grammar driver adds token round trips and same-engine post-rejection reuse; exact staged canonical proof is mandatory for this admission and enforced by the landing hook.
  Commit: `SEXPR-DOCUMENT-INTEGRATION.2 - admit complete document integration`

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE** — Historical first-form extraction and atom-kind erasure are captured in the source-qualified report register; the independent 37-case authority predates implementation.
  - [x] **ROOT CAUSE (WHY + WHERE)** — LinkedSpec Get/return_descriptor and rejecting-edge mutation proof establish seek-skipping behavior; the document grammar supplies explicit rejection and tagged tokens. Public-loader adapters must select Document instead of their historical Top literal.
  - [x] **FIX** — Recompose the delivered grammar and native consumer through a maintained public-loader verifier; synchronize every backend guide and close only the verified local report scope.
  - [x] **ADDRESSED (verified)** — Six public-loader routes each pass all 37 cases and 21 process groups; Rust files pass all 37 cases and 36 groups, including relocation.
  - [x] **NO REGRESSION** — Historical Lispish passes 26 file values and 18 groups; grammar source and authored expectations remain exact. Canonical admission reruns six-runtime recovery and repository recurrence.
  - [x] **LOCKSTEP** — The five guides, shared book, ADR, report register, roadmap and continuity agree. Downstream application acceptance and upstream RGX work remain separately owned.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `SEXPR-DOCUMENT-INTEGRATION.2` | `done` | Local integration admission is complete; resume startup .46 from the clean landing. |

## Decisions

- `2026-09-23`: Activate from clean `77d7b3db1`; its canonical receipt, post-commit pointer check and zero-byte brief are verified.
- `2026-09-23`: The startup root is exactly 8,000 lines. Keep its stable intake IDs and delegate the remaining semantic work here, following the existing separate execution-tree pattern. No history is removed, no partition infrastructure is changed and no ceiling is increased.
- `2026-09-23`: Keep the old `lispish_file` consumer independently usable. The new consumer returns the grammar's tagged native value without reconstructing token kinds or imposing the old adapter's depth limit.
- `2026-09-23`: The final admission leaf owns formal startup-parent closeout. Its technical prerequisites remain every completed implementation committed at a clean boundary; delivery .1 is an ordinary focused example/test/documentation leaf.

## Open Questions

- None blocking the native delivery leaf. Downstream application acceptance remains caller-owned.

## Blockers

- None. RGX's separate bootstrap-report issue remains upstream-owned and is not part of document delivery.

## Verification Log

| Date | Leaf | Checks | Result |
| --- | --- | --- | --- |
| `2026-09-23` | `.1` | 37 authored file cases / 36 process groups; legacy 26/18 plus 3 adapter tests; build, formatting and source/expectation preservation | PASS; ordinary documentation/doctrine checks govern landing. |
| `2026-09-23` | `.2` | Six public-loader routes: 37 cases and 21 groups each; native files 37/36; legacy 26/18 | PASS; exact staged canonical proof governs landing. |

## Commit Log

| Leaf | Commit subject or reference | Notes |
| --- | --- | --- |
| `.1` | `SEXPR-DOCUMENT-INTEGRATION.1 - deliver native s-expression file consumer` | Focused native file delivery from clean 77d7b3db1. |
| `.2` | `SEXPR-DOCUMENT-INTEGRATION.2 - admit complete document integration` | Independent local admission; exact canonical receipt required. |

## Changelog

- `2026-09-23`: Own remaining native delivery and admission in a bounded semantic tree before changing code.

- `2026-09-23`: .1 delivers the verified native file consumer and updated public guidance; .2 is the independent admission frontier.

- `2026-09-23`: .2 independently admits local document integration and closes startup .83/.83.2/.83.2.3/.83.3; startup .46 is the next repair.
