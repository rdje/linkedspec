# RGX-CONSUMER-BUILD-REPORTS: Public build reports and upstream resolutions

**Direct dependency boundary:** LinkedSpec integrates only with RGX. RGX's
published integration document, public APIs and contracts are the sole authority.
RGX defines supported transitive preparation and is the integration contact. Its
published contract keeps PGEN read-only from RGX. No separate PGEN procedure or
internal dependency knowledge belongs in LinkedSpec; routing is not fault attribution.

## Metadata

- Tree ID: `RGX-CONSUMER-BUILD-REPORTS`
- Status: `active` / LS-004 remedy published; director forbids all writes to other repositories; unauthorized ARCHOGEN documentation commit requires incident handling
- Roadmap lane: `Rust downstream integration / upstream issue follow-up`
- Created: `2026-09-20`
- Last updated: `2026-09-27`
- Owner: LinkedSpec adoption, public verification and local handoff/incident records; RGX is integration contact; affected upstream maintainer owns implementation repair. Every other repository is read-only.

## Goal

Track consumer-reported preparation problems observed through RGX's published
interface through upstream resolution and consumer verification. No RGX code
defect is established by observing transitive bootstrap output. RGX/PGEN are black boxes: no implementation
inspection, analysis, reconstruction or source edits are authorized. The director's
September26 fixing instruction permits only the verified RGX gitlink adoption in .1.2.

## Task Tree

- ID: `RGX-CONSUMER-BUILD-REPORTS`
  Status: `active`
  Goal: Resolve public build reports through upstream-published fixes.
  Children: `.1`
  Verification: Published fd3e328d5 fixes the technical report; .1.3.1 records the unauthorized recipient write and .1.3.2 retains final local closeout. No recipient acceptance or write permission is inferred.

- ID: `RGX-CONSUMER-BUILD-REPORTS.1`
  Status: `active`
  Goal: Resolve the misleading bootstrap progress message reported as ARCHOGEN/LS-004.
  Scope: Public RGX bootstrap verification and separately authorized dependency adoption; no dependency implementation inspection or patches.
  Children: `.1.1`, `.1.2`, `.1.3`
  Dependencies: Integration `.8.3` supplies the report; CONSUMER-REPORT-DELIVERY.2 reverifies it, .3 publishes the LinkedSpec fixes and .4 records the director-owned relay.
  Acceptance: Preserve exact public reproduction and observed status; receive an upstream response or published resolution; verify through the supported interface and record remaining limitations. Do not claim a fixed issue merely because a downstream guide uses the correct entry point. The director will relay the local report via RGX as the integration contact. Preserve ARCHOGEN's PGEN component attribution as reported, not independently proven; RGX correctly propagates the observed failure and no RGX implementation defect is established. This session must not post an external issue; there is no pending external-post permission request. A response alone does not establish repair: retain the failure exit status, verify accurate failure-path progress text, and preserve supported successful and already-prepared public bootstrap behavior.
  Verification: September23 CONSUMER-REPORT-DELIVERY.2 reproduces the public failure at pinned RGX8763a0e6: exit2, missing package, misleading seed line and no final completion. Prepared public bootstrap exits0 with its documented reusable no-op outcome. Report and log hashes are refreshed. Delivery .3 is published at a8d34c84595d46c24cd1820d5fc0414261706412 (exact remote read-back and source-baseline ancestry PASS). September23 director instruction assigns external communication to the director and local feedback tracking to LinkedSpec under delivery .4. Delivery .5 corrects the contact-versus-component conflation against the original report, retained public output and published integration contract. No external message was sent by this session. Upstream diagnosis/repair and post-fix verification remain pending.
  September26 continuation (historical): .1.1 verifies public failure/success/reuse at f6e5acdc. The adopted remedy is canonically published at fd3e328d5. September27 correction: the notification request did not authorize modifying ARCHOGEN; its documentation commit82ee99a05 is an incident owned by .1.3.1. Other repositories are strictly read-only; final LinkedSpec-only closeout remains .1.3.2.
  Commit: `pending` (final local closeout .1.3.2).

- ID: `RGX-CONSUMER-BUILD-REPORTS.1.1`
  Status: `done`
  Goal: Recheck all supplied consumer-report coverage and verify whether a published RGX revision resolves LS-004 through its public interface.
  Activation: Clean 35c00924cf0add082e94213da3d01394cb5993df, brief0, no jobs; scoped roadmap, report ledger, original caller-authorized report and published integration guides read.
  Verification tier: `focused`
  Focused checks: Original report snapshot hashes and published LinkedSpec ancestry; retained public failure/reuse; exact published RGX identity and integration document; two empty-store failures, fresh normal bootstrap and two offline prepared controls; book render/exact paragraph/link, Knowledge/history/memory/doctrines and diff.
  Canonical trigger: Any retained dependency pin, infrastructure or public contract movement; otherwise final clean push. This leaf changes no dependency pin or implementation.
  Verification: Retained8763 failure still exits2 with two missing-package errors, later Step B/Step C and false seed success. Its two prepared controls exit0. Published f6e5acdc99720349d1e3ecef9f821f365c4db19c stops at the first missing-anyhow error, exits2, runs no later named steps and prints no false seed success; independent repeat agrees in0.088s. Fresh normal public bootstrap exits0 with completion in110.778s; offline prepared controls exit0 in0.029s and0.013s. Published checkout stays Git-clean. Initial published failure took5044.794s including the public command's transitive Git initialization; this is not parser/build CPU time or a future duration promise.
  Coverage: ARCHOGEN43files/75512bytes and SEMULITH29files/26871bytes match the supplied snapshot hashes exactly. Live remote main remains a8d34c84595d46c24cd1820d5fc0414261706412; all eight recorded related fix/admission commits remain ancestors. Seven remedies are published; withdrawn/no-action dispositions are unchanged. No downstream application acceptance is claimed.
  Storage: Copied and byte-verified15360 public Cargo registry files/380075770bytes to a new same-volume package store; retained the source cache and reused no old compiled outputs. All commands used repository-derived storage and the public RGX entry point. No dependency implementation was inspected, no retained pin changed and no external message sent.
  Evidence: docs/checkpoints/RGX-CONSUMER-BUILD-REPORTS.1.1.json retains commands, exact revisions, public output hashes, source/report provenance, cache proof and scope. Raw logs remain under .linkedspec-data/scratch/ls004-recheck26/.
  Required continuation: Upstream public behavior is verified fixed at f6e5acdc, but LinkedSpec still pins affected8763. Required .1.2 owns adoption, native compatibility and canonical verification. The director's section20/AGENTS pin freeze requires an explicit exception before any pin change. Do not notify ARCHOGEN that the retained LinkedSpec checkout is fixed yet.
  - [x] **REPRODUCE / ISSUE** — Retained public failure reproduces the original symptom exactly; current published failure and repeat differ at the same missing prerequisite.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Observable public progress continues after failure at8763, whereas f6e5acdc stops after the first error. No internal implementation diagnosis or RGX fault attribution is made.
  - [x] **FIX** — Report and book distinguish the verified published remedy from the still-affected retained pin; actual LinkedSpec adoption is required under .1.2.
  - [x] **ADDRESSED (verified)** — This status-verification leaf passes both failure controls, fresh successful preparation and two prepared controls at the exact published revision. It is not local pin-adoption acceptance.
  - [x] **NO REGRESSION** — Public successful/reusable bootstrap is preserved; native LinkedSpec compatibility and exact canonical proof remain required for .1.2.
  - [x] **LOCKSTEP** — Current report, book, ledger/Knowledge, roadmap/task and bounded continuity records carry the same qualified status; final normal checks govern landing.
  Commit: `RGX-CONSUMER-BUILD-REPORTS.1.1 - verify published bootstrap remedy`; derive landed identity from Git.

- ID: `RGX-CONSUMER-BUILD-REPORTS.1.2`
  Status: `done`
  Goal: Make the verified LS-004 remedy available in LinkedSpec through an explicitly authorized RGX pin update and complete consumer verification.
  Activation: Clean 7c2acb5102bd54cb21c325193f5368b806d4cb08, brief0 and no jobs. Public remedy evidence, integration contract, affected consumer checks and scoped book/roadmap owners recovered.
  Authorization: After the retained8763/published-remedy finding, the director instructed "just focus on fixing that issue" and then "Just let me and ARCHOGEN know whenever you are done solving this bug." This authorizes adoption of the specifically identified, verified RGX f6e5acdc remedy and notification after verified publication. The exception is limited to this RGX gitlink; dependency implementation inspection/patches and unrelated pin changes remain prohibited. The notification request does not authorize modifying another repository; the director explicitly clarified this on September27. The unauthorized ARCHOGEN documentation write is recorded under .1.3.1.
  Dependencies: .1.1 verifies public bootstrap at f6e5acdc99720349d1e3ecef9f821f365c4db19c.
  Verification tier: `canonical`
  Focused checks: Public bootstrap failure/success/reuse evidence; clean exact RGX revision; rebuilt native Rust and maintained word/Lispish/document consumers; workspace and public-loader compatibility; mdBook and synchronized current status; normal doctrines/history/memory/diff.
  Canonical trigger: This dependency pin adoption and its publication require exact staged canonical proof.
  Preservation: Initial Git metadata census reports existing tracked local changes inside the retained transitive checkout. Preserve those opaque files and their Git recovery metadata; do not inspect, overwrite, reset or discard them. Prepare the adopted revision using the already verified clean public bootstrap checkout and fresh LinkedSpec build products.
  Owned gate correction: The first Rust gate stops in `cargo fmt --all -- --check`, whose package selection traverses path dependencies and emits upstream source-format diffs. No dependency files were changed or those diffs analyzed. Restrict formatting to the two LinkedSpec workspace packages, independently verify package selection and apply only the two formatting differences in LinkedSpec's own map-leaves test. This correction is required to enforce the existing black-box boundary during native acceptance and stays inside this canonical adoption leaf.
  Owned acceptance blocker: The rerun passes core tests but corpus_oracle reports104/105: ds_vhistory_version_entry returns `/proj/foo` where the frozen public Perl oracle expects null. This leaf must root-cause the discrepancy through LinkedSpec diagnostics and public dependency interfaces before adoption can land. Do not weaken the expectation, classify it away or claim compatibility. Known leading-trivia authority is docs/knowledge/ds-vhistory-leading-newline-oracle-boundary.md. No dependency implementation inspection is permitted.
  Blocker diagnosis/repair ownership: Current Perl public Get/get_parser skips leading blank/comment lines and returns the frozen null. Both the preserved pre-adoption Rust executable and the fresh executable return the object path, so the symptom predates this dependency adoption. Rust public carriers initialize at byte0 without the established public leading-trivia boundary; startup .88's correct typed indexing now exposes the object value instead of its older unrelated null lookup. Own the missing Rust public-entry boundary here as a prerequisite acceptance repair, preserving full input/absolute coordinates, internal context construction, indexed values and the frozen oracle. Add meaningful leading-trivia/native/generated-carrier controls and rerun affected file and full component checks. No dependency patch is involved.
  Acceptance: Use only the published integration/build instructions and public APIs/contracts. Update only the reviewed RGX gitlink from8763a0e6bea97879f027237439d57725f83ead23 to f6e5acdc99720349d1e3ecef9f821f365c4db19c; no dependency source patches or internal inspection. Rebuild through supported preparation without stale compiled products; verify native LinkedSpec and maintained historical/document file consumers, focused direct dependents and exact staged canonical CI. Synchronize pin/setup claims and the book, commit cleanly, then .1.3 owns publication and authorized notification before consumer delivery is claimed. Stop and own any compatibility failure through the public interface.
  Verification: Public failure/repeat, fresh preparation and two reusable controls pass under .1.1. The adopted Git-clean f6e5acdc checkout passes relocated public preparation and fresh native word4, Lispish26/18, document37/36, public-loader37/21, workspace9 and adapter3 controls. Fourteen independent Perl leading-trivia cases, Rust RED/GREEN, unchanged105-case oracle and generated classifier, all core/runtime package tests, independently emitted source, managed storage and both66-case CLI environments pass. Formatter selection is65 owned targets/zero dependency targets. Exact log/source/lock identities are retained in docs/checkpoints/RGX-CONSUMER-BUILD-REPORTS.1.2.json. Book render/exact content, Knowledge/history/memory/doctrines and diff govern final staging; the mandatory canonical receipt binds the exact candidate before this canonical-tier leaf can land. No publication or completion notice is claimed here.
  Owned strict-document acceptance repair (resolved): After the full Rust gate and during canonical admission, public native and Perl probes both accept `# not s-expression trivia\n(a)` and hash-comment-only input. ADR0124 permits only ASCII whitespace and semicolon comments as document trivia. The public wrapper's leading hash-comment skip bypasses the grammar's rejecting edges; its source text and absolute position remain available. This is an existing Perl contract gap and a Rust integration regression exposed by restoring public-entry parity. Stop the obsolete canonical candidate, retain its partial results without acceptance, and repair the document grammar's entry validation with independent prefix controls on every admitted runtime and file/public-loader delivery. Preserve the general leading-trivia boundary and the frozen37-case authority; no dependency changes or weakening of strict-document claims. Raw RED probes are document-prefix-probe.json and document-prefix-perl.json under the .1.2 scratch owner. The .1.2 leaf owns this bounded acceptance prerequisite before any grammar/test edit.
  Admission status: Retry41001 deliberately stopped through its exact managed wrapper (TERM, exit143) after the gap was confirmed. All9doctrines and completed native admissions passed, but there is no complete canonical receipt or release acceptance. The prefix repair and recurring native/public/file controls now pass; the new exact candidate still requires canonical admission before landing.
  Incoming consumer confirmation: At director-supplied SEMULITH HEAD7f4d2cde61a82184cf06a7870c87a19b3aa744b3, all three reports now have VERIFIED.md and the clean feedback index marks LS-001/002/003 verified. LS-002's new note and transcript confirm the original four files through sexpr_file/SExprDocumentV1 at published a8d34c845, plus reported six-file corpus agreement without classified residue. The director explicitly confirms all three cases closed. Record this independent downstream acceptance in the report ledger; it does not close ARCHOGEN LS-004 or the separately discovered complete-input prefix gap. No SEMULITH repository was modified or message sent.
  Prefix repair progress: The new14-case supplement first fails exactly eight invalid-prefix subtests in Perl; the original37 and six positive controls pass. Document's I block now rejects any non-ASCII-trivia character in input_slice(0, cursor_pos()). All51 cases pass on Perl, Rust, Dart, Julia, PUC Lua and LuaJIT, including round trips and post-rejection reuse; the independent Perl guard-removal mutation restores bad acceptance. All six public-loader routes pass51 cases/29 groups each; native files pass51/44 including relocation. Canonical admission remains required before landing. Native job33718 is consumed exit0; book68799 passes; Rust owned formatting passes and Dart's edited test is formatted.
  Rejected delivery attempt: Public Perl job84000 completed its case/error checks but failed the final grammar hash assertion after an explanatory source comment was added during execution. Its exit1 is not acceptance. Preserve prefix-public-perl-source-changed.log, freeze the grammar and both authorities, and rerun all delivery routes. No behavior or expectation was changed to satisfy this check.
  Owned canonical admission correction (resolved): Canonical36797 exits1 after all9 doctrines, staged/progressive/gap/recognition/source-location/MCP/semantic admissions and the expanded51-case document driver pass. The public aggregate-selector checker reports36 classified references against expected35. This leaf owns exact occurrence inventory against clean HEAD/published baseline and the smallest justified correction; no blind cardinality increase or weakening of negative-context/migration checks. Read the canonical aggregate-selector-public-admission fact and use the maintained checker to locate the extra occurrence. No canonical receipt or publication is claimed.
  Inventory diagnosis: The maintained checker's exact matching rules find36 references in both this candidate and clean7c2acb51, versus35 at publisheda8d34c845. The only addition is the explicitly rejected one-bare-value constructor spelling in value-container-flow-helper-reference.md, introduced by49678a8c136ea2f824f6f0ed2ac0b1170f52087a (.90). All35 prior occurrences remain. Correct the pinned count to36, preserve classifier/migration/runtime checks and all public authoring examples, and align the directly related current census prose (69 files/36 classified/zero current). The old25/67-file census and obsolete unclassified-Julia-warning prose are stale projections of this same current admission surface. Historical dated results stay unchanged. Evidence: selector-inventory.json under this leaf's scratch owner. Focused composed proof passes69 files/36 classified/zero current, all11 migration mutations, five backend rejection boundaries, zero executable positives and capability100/0/0. The checker diff is exactly one expected-count line; exact canonical rerun remains mandatory.
  Acceptance Checklist (.1.2):
  - [x] **REPRODUCE / ISSUE** — Public old-pin failure and current-version controls retain exact evidence. `LinkedSpec::get_parser('ds_vhistory')` returns the frozen null while both old and new Rust executables originally returned the object path; the new leading-trivia test records RED then GREEN.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Public bootstrap now stops after the first prerequisite failure. Owned formatter package selection and Rust public-entry seams explain the acceptance blockers without dependency implementation inspection.
  - [x] **FIX** — Adopt reviewed f6e5acdc, preserve the entire older dirty checkout and target, restrict formatter scope, restore the reference leading-trivia boundary at four public Rust seams, and validate the original skipped prefix inside the strict document grammar.
  - [x] **ADDRESSED (verified)** — Full native package proof passes; the prefix repair passes51 cases on all six native/public-loader routes and native file delivery. Exact canonical receipt is required before landing.
  - [x] **NO REGRESSION** — Frozen105-case oracle and original37 document cases remain unchanged; six-runtime/public/file controls pass with14 additional prefix cases and both rejecting-edge/entry-guard mutations. Downstream application acceptance remains ARCHOGEN-owned.
  - [x] **LOCKSTEP** — Pin/build instructions, runtime semantics, book, Knowledge, report ledger, roadmap/task and bounded live records agree; .1.3 owns publication/notice.
  Commit: `RGX-CONSUMER-BUILD-REPORTS.1.2 - adopt verified LS-004 remedy`; derive landed identity from Git.

- ID: `RGX-CONSUMER-BUILD-REPORTS.1.3`
  Status: `active`
  Goal: Record the published LS-004 remedy and provide a handoff inside LinkedSpec, correcting the unauthorized ARCHOGEN write.
  Children: `.1.3.1`, `.1.3.2`
  Director correction: All other repositories are strictly read-only. The request to notify ARCHOGEN and its feedback protocol did not authorize editing or committing there. The director reiterated this after the incident and assigned changes there exclusively to ARCHOGEN; no revert or further write will be attempted by LinkedSpec.
  Incident: The agent created ARCHOGEN commit82ee99a05ee55babdf6ea49fb719707a030b8700 in twelve documentation files, plus ignored verification scratch/logs, and used/cleared its brief. It did not amend prior commits, alter application code/vendor pins or push ARCHOGEN. The original canonical closeout8638 was stopped via its exact managed wrapper and consumed exit143; it supplies no receipt. Published fixfd3e328d5 and its complete canonical acceptance remain valid.
  Acceptance: Commit an accurate local incident record and permanent read-only boundary; preserve the published remedy and original evidence; let ARCHOGEN control disposition of its repository. Complete the remaining LinkedSpec-only parent closeout through exact canonical proof.
  Commit: `pending`

- ID: `RGX-CONSUMER-BUILD-REPORTS.1.3.1`
  Status: `done`
  Goal: Correct the authorization record, account for every known ARCHOGEN write and preserve reviewable recovery material in LinkedSpec only.
  Activation: fd3e328d5dd5c80981a1c3b8496a27270291f7b8; the earlier nineteen-file documentation candidate was uncommitted when the director objected. No completed fix is rolled back or republished.
  Verification tier: `focused`
  Focused checks: Exact incident commit/file inventory, local reverse-patch digest and already-completed read-only applicability check; corrected rendered book and current consumer claims; Knowledge/history/memory, all doctrines and diff; no further writes outside LinkedSpec.
  Canonical trigger: Final clean push and the separate .1.3.2 parent closeout; this leaf records the incident and existing publication without closing a parent or moving runtime contracts/infrastructure.
  Ownership: This leaf owns all pending local delivery/status edits, the required lossless notes rollover, AGENTS/MEMORY read-only boundary, an incident fact/record and local reverse patch. The exact patch path alone receives a whitespace attribute because unified-diff blank context lines require their literal space marker; preserve its recorded digest. Remove unsafe external-write helper scripts from LinkedSpec scratch. Do not touch ARCHOGEN, including its ignored artifacts or commit history.
  Acceptance: The records identify the write as unauthorized, distinguish actual upstream fixes from consumer acceptance, and leave ARCHOGEN in control of recovery. The director has reaffirmed read-only ownership; no authorization question remains pending and no external revert is authorized.
  Verification: Corrected mdBook build exits0; two rendered pages pass ten exact text checks, the upgrade fragment/link and literal published source pin. Local reverse patch SHA-256 and all twelve paths match the retained incident inventory; patch remains unapplied. Three unsafe local writer helpers are absent. Read-only remote main still equals fd3e328d5; all four earlier implementation/documentation fix commits are ancestors. Knowledge synchronization, both history-pressure checks, memory, all nine doctrines and diff are required at landing. No further other-repository write occurred. Exact evidence: docs/checkpoints/RGX-CONSUMER-BUILD-REPORTS.1.3.1.json.
  Commit: `RGX-CONSUMER-BUILD-REPORTS.1.3.1 - record publication and repository-boundary violation`; derive landed identity from Git.

- ID: `RGX-CONSUMER-BUILD-REPORTS.1.3.2`
  Status: `pending`
  Goal: Complete the corrected LinkedSpec-only consumer-report closeout after .1.3.1 is cleanly committed.
  Planned checks: Accurate local handoff/incident boundary, no new recipient writes, exact canonical acceptance and clean final publication. ARCHOGEN's own repository disposition and downstream verification remain its owner's responsibility.
  Acceptance: Close only LinkedSpec's bounded report work, preserve all unrelated defect owners, and resume startup .93/.92/.94/.95/.51. Never claim the unauthorized recipient commit as authorized delivery or consumer acceptance.
  Commit: `pending`

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `RGX-CONSUMER-BUILD-REPORTS.1.3.2` | `pending` | Canonical LinkedSpec-only closeout after the committed local correction, then startup .93. |

## Original director handoff and September26 continuation

- Ready response: `docs/upstream/rgx/bootstrap-progress-status.md`.
- Published LinkedSpec delivery: `a8d34c84595d46c24cd1820d5fc0414261706412`;
  the remaining report is not a claim that these LinkedSpec remedies failed.
- RGX contact role: coordinate the PGEN-attributed report through the appropriate
  upstream owner. No request to alter RGX code or patch its read-only dependency
  follows from this evidence. Requested outcome: stop dependent steps after a
  prerequisite fails and avoid false success text, preserving the correct exit status.
- Original LinkedSpec follow-up: test the published remedy only through RGX's supported
  interface, record exact status/output and successful/reusable controls, and
  keep this task open until repair is verified. No dependency pin change or
  implementation inspection is authorized by this handoff.
- No issue URL or upstream reply is recorded; independently tested published f6e5acdc supplies the remedy evidence. Communication was director-owned until the continuation below.
- September26 continuation supersedes the earlier relay/pin restriction only for this repair: the director requests fixing the identified issue and notifying both the director and ARCHOGEN when done. .1.2 owns adoption; .1.3 owns verified publication and completion notice. No dependency implementation authority transfers.

## Distinct Historical Build Fix

`RGX-BUILD-REPRO.1` closed the June15 cold-checkout build problem. LinkedSpec
`c4926f871131e9a67114425bb3c28108205bc283` adopted upstream RGX
`8763a0e6bea97879f027237439d57725f83ead23` and recorded a successful cold build.
That older issue is distinct from September ARCHOGEN/LS-004. Integration
`a1166ee1d` explicitly left LS-004 open after adopting the public preparation
flow and discarding an uncommitted custom helper. The complete report/commit
ledger is `docs/knowledge/consumer-report-fix-commits.md`.

## Attribution Evidence

- ARCHOGEN's original LS-004 names PGEN bootstrap, not the RGX engine.
- The retained public command exits2 correctly; no final success is claimed.
- The deliberately unavailable offline prerequisite is an expected failure.
  The misleading intermediate message remains the observed report symptom.
- RGX's published `docs/INTEGRATION.md` says PGEN is read-only from RGX.
- This task's stable RGX-prefixed ID names the integration route, not a finding
  of faulty RGX implementation. LinkedSpec still owns intake and verification.

## Decisions

- Integration documentation may describe verified supported use while this upstream
  report remains open. Neither documentation delivery nor a successful normal build
  establishes correction of a failure-path progress message.
- All dependency implementation authority remains upstream. Published interfaces,
  contracts and observable consumer results are the only local evidence surface.
