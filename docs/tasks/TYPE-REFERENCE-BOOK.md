# TYPE-REFERENCE-BOOK: Complete navigable per-type language reference

## Metadata

- Tree ID: `TYPE-REFERENCE-BOOK`
- Status: `active` / signed contract17.1 next
- Roadmap lane: `.spec language documentation / complete type and method reference`
- Created: `2026-10-10`
- Last updated: `2026-10-23`
- Owner: LinkedSpec repo-local PNT
- Priority: P1 discovered runtime repairs; P2 documentation completeness; P3 legacy status repair
- Intake owner: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2`
- Schedule: First documentation phase after the active private factory/callback implementation lane; before claiming the book supplies an exhaustive per-type reference.

## Goal

Give readers one clearly navigable canonical section for every supported value/type family, and a thorough,
example-rich entry for every currently supported operation. Inventory actual contracts and supported spellings
before deciding headings, moving text or asserting completeness. The bounded callback handoff is accepted at 1a8b202018a387c87425442375f53c3ee5e820d4; its stale-recipe prerequisite is complete; full inventory .1.2 is next.

## Verified intake and limits

The director's October10 DBIQNP question asks about scalar string/integer/real, array, hash and codeblock coverage.
The current SUMMARY links general DSL chapters. `value-container-flow-helper-reference.md` contains scalar
normalization, scalar predicates/string comparisons, numeric helpers/comparisons, array helpers, hash helpers and
array pipelines. Constructor, mutation, fluent and traversal material is distributed across other sections.
`values-containers-and-flow-helpers.md` contains detailed codeblock literal, parameter, invocation, return and
dynamic-context prose under Returning payloads, without a clearly navigable dedicated codeblock type section.
Several sampled operation entries are brief table rows with shared examples rather than complete individual
method entries. This is a qualitative organization/depth finding: no complete implementation-to-book inventory
or missing-method count has been established. Existing historical book closeouts do not certify this new criterion.

Three encountered legacy task files also contain explicit status contradictions. Their precise repair owner is
`.8` below; these do not block the current runtime task. Record descriptions, dated results and Git history must
be reconciled before changing any legacy completion field.

## Scope boundaries

Use current canonical contracts, public capability/backend limits and LinkedSpec-owned source/test interfaces.
RGX/PGEN and every other repository remain read-only black boxes. Distinguish constructors, literals, operators,
free helpers, receiver methods and codeblock invocation rather than inventing methods or new language types.
The director's integer/real terminology must be reconciled with actual scalar/numeric semantics, including any
boolean/null distinctions. A codeblock's yielded value selecting a receiver family is not evidence of a separate
codeblock dot-method family. Preserve current examples, anchors, includes and governed contracts when reorganizing.
Runtime defects discovered by the audit receive their own scheduled repair owners and are not hidden by prose.

## Acceptance Criteria

- A source/contract-bound inventory maps every supported operation and spelling to one canonical type section.
- String/scalar, integer/real numeric behavior, arrays, hashes and codeblocks each have direct navigation and a
  complete supported-operation reference, using the actual type model established by inventory.
- Each entry describes accepted signatures/arguments, result type/value, mutation/aliasing, empty/missing/error
  cases, chaining and callback behavior where applicable, supported backend limits and worked executable examples.
- Every inventory item is covered, cross-links resolve, former anchors remain usable, and complete rendered-book
  review confirms navigation and content. Declare actual measured proof records before publishing coverage counts.
- Ordinary leaves use focused proof; public contract or mechanical infrastructure movement requires canonical
  tier. Split repair families into further leaves before writes when needed; commit each accepted leaf via COMMIT.md.

## Task Tree

- ID: `TYPE-REFERENCE-BOOK`
  Status: `active`
  Goal: Canonical per-type reference with complete current operation coverage and verified examples.
  Children: `TYPE-REFERENCE-BOOK.1`, `TYPE-REFERENCE-BOOK.2`, `TYPE-REFERENCE-BOOK.3`, `TYPE-REFERENCE-BOOK.4`, `TYPE-REFERENCE-BOOK.5`, `TYPE-REFERENCE-BOOK.6`, `TYPE-REFERENCE-BOOK.7`, `TYPE-REFERENCE-BOOK.8`.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.6`
  Acceptance: All inventory-backed reference and closeout leaves pass; legacy task contradictions are reconciled without refreshing historical claims.

- ID: `TYPE-REFERENCE-BOOK.1`
  Status: `active` / bounded child sequence
  Goal: Inventory the actual supported type/operation surface and map current book coverage before edits.
  Acceptance: Reconcile canonical grammar/contracts/capabilities, owned receiver dispatch and tests; enumerate literals, constructors, operators, free helpers, receiver methods, aliases and codeblock invocation separately. Map every item to current and proposed canonical sections, identify exact depth/navigation gaps, retain executable example requirements and backend limits, and choose a bounded section/layout plan under existing document pressure controls. No exhaustive claim from sampled tables.
  Planned tier: `focused`; reclassify before any public/mechanical contract change.
  Claim verification: none: Parent tracking only; child-specific source-bound records own repair and inventory measurements. No aggregate coverage admission.
  Children: `TYPE-REFERENCE-BOOK.1.1`, `TYPE-REFERENCE-BOOK.1.2`, `TYPE-REFERENCE-BOOK.1.3`.
  Activation: Clean 1a8b202018a387c87425442375f53c3ee5e820d4 after canonical CI, all10 normal hooks, brief0, explicit post-pointer/post-memory and clean Git. Primary uniform-binding contract and both dated retirement cards read. The large helper-catalog/formal-grammar retrieval was truncated; read the relevant bounded sections before edits. No complete operation inventory or missing-method count exists yet.
  Ancillary intake ownership: Carry the prior metadata review question into deferred PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.13, scheduled after inventory and legacy status repair; this queues diagnostics without a metadata implementation pivot.
  Owned intake (P2; scheduled first documentation phase after active implementation): PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1 found obsolete current-labelled migration recipes in docs/knowledge/retired-return-helpers-canonical-rewrite.md and docs/knowledge/actionir-return-node-retired-to-return.md. Public Toolbox return(array_copy(array(Top))) raises aggregate_selector_removed; return(array(copy(Top))) lowers. Audit/repair the complete dated recipe family before using it as current inventory authority, preserve original retirement measurements, and verify replacements against the admitted uniform-binding contract. At that October10 intake the callback activity remained selected; the clean October19 activation now owns the repair.

- ID: `TYPE-REFERENCE-BOOK.1.1`
  Status: `done` / verified current retirement migration guidance
  Goal: Audit and repair the complete dated return-helper migration family before it is used as current inventory authority.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12`
  Owned paths: The two retirement Knowledge cards, current TOOLBOX.md API examples that repeat these recipes, relevant canonical grammar/helper/book sections, bounded producer/reviewer/claim, current Knowledge routes and normal continuity. Root planning also owns the deferred scalar-metadata literal question intake; no metadata implementation change.
  Verification tier: `focused`
  Focused checks: Preserve all intersecting live claims and actual readonly baselines before bound writes; native-first Toolbox lowering/descriptor/execution observations for every current replacement and distinguishing retired/removed-selector controls; independent value/shape/aliasing review, retained original historical facts, effective semantic denials/restorations, current Knowledge, affected complete book and history/memory/task gates.
  Canonical trigger: none for documentation correction to already-admitted syntax; reclassify before changing runtime behavior, a public contract, or mechanical owners. No push before the PNT boundary.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.1.json`
  Acceptance: Preserve the June retirement observations as dated history. Establish actual current constructors/bare bindings/copy and group behavior through public tools; do not imply an unverified aliasing equivalence or full type inventory. Keep current examples and reverify routes valid. Commit this bounded repair before inventory .1.2.
  Pre-write custody: Complete actual claim namespace and all three live records are retained before bound writes. Only metadata208/full39111 intersects the planned fact/map/book edits; every input equals real accepted1a8b20201 with actual filesystem modes. Actual readonly baseline72049 exits0. Mode/revision-only freezer preserves all raw observations and both other live guards; historical claim now resolves to the actual accepted Git source. The relevant June14 Contracts source before/after is retained without executing the retired engine. The initial MethodLowering supplement stopped before its artifact write at the final-function EOF boundary; the exact failed source remains unchanged and the separate repair below retains a complete recurrence. This is the dated pre-write stage; verified completion follows.
  Owned instrument correction: history-supplement.py assumes a later newline-sub delimiter and asserts at line15 when _lower_return_array_statement is last in the immutable file. The original combined shell continued to a pointer update, so its outer exit was0 and separate inner channels/status were not retained. Preserve that limitation; supply exact writer/helper and both historical Git blobs before an isolated recurrence. A distinct final producer uses EOF as the final-function boundary and writes a new final artifact; do not rewrite original source or fabricate original channels. This is the dated pre-native instrument stage; verified completion follows.
  Confirmed guidance defect (P2; owned here): Exact pre-retirement pure Contracts callbacks produce return_m(Top) => ["?Top:","ab","c"] and return_ma(Top) => ["?Top:","ab","c", accumulator-reference]. The June21 card incorrectly described nested groups as faithful. Historical callback source and actual isolated lowering/value/after-mutation channels are retained before correction; no retired compiler or dependency implementation is loaded. Use current flat_array(entry_groups()) for this historical flat shape, and distinguish deliberate nested-group redesign. The original a/ma accumulator reference follows later source-array mutation; snapshot migration cannot claim full alias equivalence or unmeasured corpus absence.
  Bounded limits: TOOLBOX section2.2's assign/capture example is a separate known pending CONFORMANCE-SOURCE-READING.2.11 recipe family with reading prerequisites; this leaf repairs return-family examples in sections1.1/1.3 only and does not close that owner. Initial root-I probes have no incoming match; separate matched-child probes retain nonempty groups/whole text. Original native channels are saved; its subsequent summary reader fails on a real diagnostic stdout prelude, so independent parsing must retain/disclose that prelude.
  Owned focused public-reference correction: The unchanged public aggregate-selector check rejects the first rendered documentation candidate with42 classified negative references against its admitted40. The two extra occurrences are the new formal-grammar removal explanation, not executable selectors. Preserve the complete first uncommitted publication/context before removing this redundant spelling detail, retain the failed checker command/source, then render/review the corrected current epoch. Do not alter the checker, budget or public runtime contract.
  Owned proof-reader portability correction: The complete first355/full60395 uncommitted publication and all bound/source/public/live-guard bytes precede correction. Exact isolated old-reader replay exits1 because review_native.py compares captured original absolute INC module paths to the new fixture root and misclassifies LinkedRE.pm as an unsupplied external prerequisite. Native results stay unchanged. A distinct supplied adapter changes only that predicate to module-key/repository-relative identity, retains every original on-disk input and whole claim, and reruns all existing value/metadata/graph/book/old208 checks. Preserve original healthy main-context baseline and actual supplied RED separately; normalize current reader and retain distinguishing unsafe-key/suffix/unknown-module controls. No parser/runtime, gate or support contract changes.

  Final instrument/transport closeout: Complete original355/full60395 and actual readonly baseline precede all follow-up changes. The module-key adapter with the entire nested1487 graph reproduces the full original record/channels while all on-disk inputs remain exact; both prior failed readers remain retained. Four module-identity REDs distinguish unsafe/missing/mismatched/inconsistent identities. The composed public scanner then rejects unregistered negative Python capture text; four retired producer sources are retained losslessly as data with exact guarded stubs, without any scanner/allowlist change. The original prose producer and one exact fragment inverse remain recoverable. Current public70/40/zero-positive, native/source/book review and final396/full68960 publication pass. The root closeout writer initially inserts CHANGES at an inline preamble marker; continuity.json retains the full original writer/before/broken state, actual RED255 and line-start-heading GREEN. Standard JSON solidus preflight transport is exactly parsed/invertible and changes no bound input.
  Completion: TYPE-REFERENCE-BOOK.1.1 corrects the retired tagged-return recipes: exact historical m/ma callbacks splice groups, while current copy recipes have explicit snapshot/identity limits. Seventeen fixed parser/generated payloads, five alternate native-shape REDs and four module-identity REDs pass. Two Toolbox return examples and the complete89-input book/affected-page links pass; the actual worked source matches native execution. Whole prior208/full39111 and first uncommitted355/full60395 records, actual baselines and all inputs remain recoverable. Exact isolated original reader fails its absolute INC predicate; the distinct corrected predicate/full supplied context restores the whole original claim with identical channels. Redundant public42/40 references and executable negative capture sources are resolved without changing gates: exact original producers remain archived data with guarded stubs. Current Knowledge1487/1349/10455, all897 entries/248 fields, 8386601 bytes and map21249 fit unchanged controls. Current readonly publication binds396 inputs/full68960. No runtime, contract, budget, full alias/deep-copy, exhaustive type inventory or private/parent admission changes. Clean activation of .1.2 inventory follows; .8 legacy status repair and deferred metadata QA .13 remain owned.
  Verification: Readonly current publication, retained original/derived replay, module controls, current semantic/book review, uniform-binding contract and unchanged composed public selector gate PASS. Focused doctrine/history/memory/hook validation governs this ordinary documentation landing.



- ID: `TYPE-REFERENCE-BOOK.1.2`
  Status: `active` / bounded inventory children
  Goal: Reconcile the complete supported type/operation/spelling population with canonical authorities and actual book coverage.
  Dependencies: `TYPE-REFERENCE-BOOK.1.1`
  Planned tier: `focused`; reclassify before public/mechanical movement.
  Claim verification: none: Parent tracking only; separately committed children own source population/type model, operation/spelling enumeration and complete book mapping. No aggregate completeness admission yet.
  Children: `TYPE-REFERENCE-BOOK.1.2.0`, `TYPE-REFERENCE-BOOK.1.2.3`, `TYPE-REFERENCE-BOOK.1.2.4`, `TYPE-REFERENCE-BOOK.1.2.5`, `TYPE-REFERENCE-BOOK.1.2.6`, `TYPE-REFERENCE-BOOK.1.2.7`, `TYPE-REFERENCE-BOOK.1.2.9`, `TYPE-REFERENCE-BOOK.1.2.13`, `TYPE-REFERENCE-BOOK.1.2.10`, `TYPE-REFERENCE-BOOK.1.2.11`, `TYPE-REFERENCE-BOOK.1.2.12`, `TYPE-REFERENCE-BOOK.1.2.17`, `TYPE-REFERENCE-BOOK.1.2.14`, `TYPE-REFERENCE-BOOK.1.2.16`, `TYPE-REFERENCE-BOOK.1.2.19`, `TYPE-REFERENCE-BOOK.1.2.21`, `TYPE-REFERENCE-BOOK.1.2.20`, `TYPE-REFERENCE-BOOK.1.2.1`, `TYPE-REFERENCE-BOOK.1.2.2`.
  Acceptance: Retain the complete source/contract population, distinguish literals/constructors/operators/helpers/methods/aliases/invocation, reconcile integer/real and boolean/null semantics, and map every item and backend limit to current/proposed canonical sections. No completeness claim from sampled tables.
  Activation: Clean cf4dceccd24bc6642fc9c7d8d10b329e136849b6; .1.1 normal all10 hooks, post-pointer/post-memory and brief0 pass, all required jobs joined. July4 type-method and dated gap implementation cards are navigation/history pointers, not fresh complete inventories. The current gap card explicitly points beyond its old122 boundary; progressive/staged private intrinsics must not be promoted by name discovery alone.

- ID: `TYPE-REFERENCE-BOOK.1.2.0`
  Status: `done` / bounded authority/model prerequisite
  Goal: Retain the complete relevant authority population and reconcile the actual public value/type model before counting operations.
  Dependencies: `TYPE-REFERENCE-BOOK.1.1`
  Owned paths: New docs/checkpoints/type-reference-inventory/ source/contract/book captures and reviewers, its claim, relevant current Knowledge/book clarification and normal continuity. Preserve current396/full68960 and actual readonly baseline before any bound fact/book/map write. Other repositories/submodules remain read-only black boxes.
  Verification tier: `focused`
  Focused checks: Exact owned Git source/contract/book population and recoverable bytes/modes before producers; existing language-coverage and neutral type/callable/numeric authorities; public-tool probes where current acceptance is uncertain; independent completeness/category and distinguishing omission/private-promotion controls; changed Knowledge/book, histories, explicit memory and normal doctrines/hooks.
  Canonical trigger: none for inventory/clarification of existing admitted behavior; split/reclassify before any runtime, public contract, generated format or mechanical owner change.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.0.json`
  Acceptance: Produce a source-bound authority ledger and current type taxonomy with explicit admitted/private/retired and historical boundaries. Reconcile scalar/string/numeric integer-real and boolean/null distinctions, array/harray/codeblock bindings and yielded receiver dispatch without inventing separate method tables. Do not call the shared helper-name inventory a complete operation/spelling inventory. Commit this bounded prerequisite before .1.2.1.
  Native diagnostic hold (owned; do not classify away): The initial14-case public Get/descriptor/independently loaded generated probe exits0 with all1300 source inputs unchanged. Two surprising values require distinguishing follow-up before taxonomy conclusions: deferred-effects returns ["inside","inside","inside"] for [marker, cb(), marker]; emitted source places the mutable $marker lvalue directly around CodeblockRuntime::invoke. codeblock-generic-with returns null; emitted source binds scoped $value but lowers value() to LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:value, with zero reported fallback. Exact raw observations/source are retained in model-inputs/model-run capsules. Search found no matching direct-literal snapshot card; private compiler callback alias rules are a different interface. Determine normative mismatch and exact source location with the public tools; retain controls and assign verified repairs before continuing the operation inventory.
  Custody progress: Accepted396/full68960 matches actual real cf4dceccd inputs/modes and its actual readonly baseline exits0. Only that live record intersects planned book/map writes; other live6/14 guards stay exact. The conservative1300-input owned authority/test/book superset is retained before inventory commands; this is capture, not full reading or an operation count. Capability README and initial combined ADR retrieval were truncated; bounded relevant scalar/callable sections and ADR0028-0032 are now read, with remaining relevant dependencies pulled as needed. No bound book/fact/map/runtime input has changed.
  Current limit: No operation count, missing-method count or full reference admission exists. The July4 inventory's present-tense aliases/terminal wording must be checked before any current reuse; no new runtime defect is inferred from that dated text.

  Diagnostic resolution and completion: Authority/model .1.2.0 retains1300 owned inputs;14 descriptor/Get/generated cases include70 neutral scalar fields, and11 distinguishing cases isolate two owned P1 Perl defects. Actual private promotion has report0/strict RED/exact restoration. Current Knowledge1487/1349/10455, all897 list items/248 fields and8387566 bytes fit unchanged limits; complete89-input book and changed-heading control pass. Whole original396/full68960 replays with exact channels and bytes/modes unchanged. Only that accepted claim is frozen at real cf4dceccd; first no-write frontmatter writer failure and separate correction remain retained. No runtime, contract, gate, budget, complete operation inventory, cross-backend or private/parent admission. P1 scalar-evaluation .1.2.3 then scoped-with .1.2.4 precede complete enumeration .1.2.1.
  Verification: Current readonly source/model publication, exact whole prior replay, strict/private source controls, complete Knowledge and book/heading proof, uniform-binding and composed public selector checks PASS. Normal focused doctrines/history/memory/hooks govern landing.

- ID: `TYPE-REFERENCE-BOOK.1.2.3`
  Status: `done` / bounded evaluated-value and admission repair
  Goal: Preserve evaluated values across later side effects in array/harray literals and constructors and callable argument lists.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.0`
  Evidence/custody: docs/checkpoints/type-evaluated-values/README.md and accepted2fca7d848; complete prior root bytes also survive in aggregate7 docs-update.json.gz. Subsequent historical/required-consumer controls remain in their recorded source epochs.
  Verification tier: `canonical`
  Focused checks: Native-first Get/descriptor/fresh generated-source impact matrix; once/order/kind/caller/alias and name-collision controls; actual unchanged baseline RED and candidate GREEN/source inverses; direct AST/lowering/generated/uniform/callable/variadic consumers; current complete Knowledge/book, histories, memory and all doctrines.
  Canonical trigger: Observable evaluated-value/runtime correction; exact staged candidate must pass approved-host tools/run_ci_local.sh and normal receipt-bound hooks.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.3.json`
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get, return_descriptor and independently emitted generated source show earlier marker values changing from before to inside after a later callback. The accepted source rejects19 finite cases; four controls pass. Native/raw channels and generated source are retained in the evaluated-values capsules.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Generated source places a caller scalar directly on a Perl list stack around a later invocation. MethodLowering.pm:1256 owns the per-operand materialization boundary. This is a real engine defect; the140 later Phase0 spelling assertions are stale representation expectations, and the three missing caller-presence declarations are isolated fixture compile errors.
  - [x] **FIX** — MethodLowering::_materialize_list_operand_expr captures each operand in a private list temporary before its next sibling. Typed/legacy arrays, hash pairs/keys, explicit splices and callable arguments retain their existing shapes. Deferred interpretation and public contracts remain unchanged.
  - [x] **ADDRESSED (verified)** — Exact accepted-runtime19 RED becomes23 native/fresh-generated GREEN with the four controls retained. Six actual source inverses reject19/14/2/1/1/1 and restore. Phase0 observer execution bypass rejects129 value assertions, retains one genuine null control and restores all52 selected groups; missing selection rejects false acceptance. Actual comm -23 clears exactly the52 original failing root names; comm -13 is empty.
  - [x] **NO REGRESSION** — bash tools/project_data_run.sh prove -v -Iperl t/phase0_regression.t reaches its true stop ok1035 and plan1..1035: Result: PASS, exit0, no root exclusions and empty stderr. perl -c checks pass for LinkedSpec.pm and the ordinary test. The exact channels, syntax runs and comm -13 empty/new-set proof are retained in docs/checkpoints/type-values-admission/ordinary-phase0.json.gz.
  - [x] **LOCKSTEP** — Public book examples/current limits, Knowledge facts/map, CHANGES, DEVELOPMENT_NOTES, MEMORY, live status, roadmap and task-tree align with the bounded Perl repair. Current complete book/heading control and Knowledge checks pass; git diff --check is clean. Separate scoped-with, numeric and generated-drop owners retain their sequence.

- ID: `TYPE-REFERENCE-BOOK.1.2.4`
  Status: `done` / scoped callable repair; clean activation 2fca7d848
  Goal: Make the scoped with value callable inside its attached codeblock without silent null lowering.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.3`
  Reproduce: cb = {|| return("yes") }; return(cb.with() { return(value()) }) returns null through Get and fresh generated source. Copying value to a named local, calling cb directly, or supplying an explicit callback/value parameter returns yes. Fallback count remains zero in the failing case.
  Impact: A public scoped binding loses callable behavior and hides unsupported lowering behind null.
  Root cause: The attached with lowerer emits my $value but lowers its body with the original dependency vocabulary. _codeblock_variable_call_candidate cannot find that scalar-kind name and emits the unsupported-helper sentinel.
  Schedule: After .1.2.3, before .1.2.1 enumeration. Before creating new source files, run the current readonly publication from clean Git to ignored baseline logs; its exact scanner inventory treats added source files as a changed input population. Preserve that whole baseline before scoped writes.
  Verification tier: `canonical`
  Focused checks: Scoped descriptor/Get/fresh-source values and diagnostics, actual source faults, callable/with/direct consumers, Knowledge and rendered book.
  Canonical trigger: Scoped callable lowering and runtime-frame movement; exact staged candidate.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.4.json`
  Evidence: docs/checkpoints/type-scoped-with/;30 GREEN/19 RED/11 controls; source faults20/1/1/1/1 plus authored-span RED, all restored;14 suites/1924 TAP/549 declared inputs; book89/heading denial. Whole prior845/full130759 and clean readonly0 preserved at real2fca7d848. Publisher and exact canonical receipt govern landing. Canonical1 tier-spelling rejection and exact candidate remain in docs/checkpoints/type-scoped-with-admission/.
  Acceptance: Repair scoped dependency projection with nested scope/restoration, static helper/function precedence, false/null/noncallable and explicit-parameter controls; check actual unsupported-call diagnostics separately. Preserve existing call/with contracts, verify fresh emitted routes and direct consumers, document the fix and run canonical candidate proof.

- ID: `TYPE-REFERENCE-BOOK.1.2.5`
  Status: `done`
  Goal: Repair scalar numeric calls and snapshots.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.4`
  Evidence: docs/checkpoints/type-numeric-codeblocks/;318 GREEN/169 accepted RED; C1 extra9 RED;13 faults/restorations;17 suites/1962;book89/3. Prior4 qualified; admission/inverse22/66: type-numeric-admission/.
  Verification tier: `canonical`
  Focused checks: Native/fresh values/kinds/errors/effects, neutral contracts, direct consumers, source faults, book/Knowledge.
  Canonical trigger: Interpreter/generated behavior; exact staged receipt.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.5.json`
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Accepted dispatch/late-read failures retained.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Runtime dispatch and emitted scalar slots.
  - [x] **FIX** — Shared numeric adapter; operand materialization; shape guards.
  - [x] **ADDRESSED (verified)** —318 cases;13 source controls/restorations.
  - [x] **NO REGRESSION** —17/1962; canonical receipt gates landing.
  - [x] **LOCKSTEP** — Book/facts/live docs; startup87.3 closed;6/7 remain.

- ID: `TYPE-REFERENCE-BOOK.1.2.6`
  Status: `done` / bounded Perl drop producer repair
  Goal: Quiet scalar-key generated loading with copied harrays and evaluated key lists.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.5`
  Evidence/custody: docs/checkpoints/type-drop-generated/README.md; complete source epochs/10334-input publication at acceptedefad62ba7a70e0b9d930b761f9cacaad87a0210c.
  Verification tier: `canonical`
  Focused checks: Fixed48 descriptor/Get/lowering/fresh normal/FATAL routes;34 values/14 diagnostic controls;4 emitter faults;9 suites/1322 TAP; five real Phase0 roots with18 permanent assertions; book89/3/heading RED; exact historical644+6/134/22 and2 auditor faults/table denial; Knowledge.
  Canonical trigger: Observable generated compiler diagnostic; exact staged-candidate receipt required before normal landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.6.json`
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Accepted warning, splice and key-effect failures retained.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Toolbox identifies the drop scalar/list/shape emitter.
  - [x] **FIX** — Copied source and materialized key list; explicit splice/shape lowering.
  - [x] **ADDRESSED (verified)** —34 values/14 diagnostics; four actual faults/restorations.
  - [x] **NO REGRESSION** — Direct/history/book and canonical1035/CLI66x2; ten hooks/receipt.
  - [x] **LOCKSTEP** — Book/facts/handoff; no whole-family/backend admission.
  Final admission: first10304 draft/readonly0/10308 stage images and canonical143 retained in admission/.
  P3 cache cleanup: exact preserved cache removed; checkpoint ignore/residue proof retained.
  Commit subject: `TYPE-REFERENCE-BOOK.1.2.6 - materialize generated drop keys`.


- ID: `TYPE-REFERENCE-BOOK.1.2.7`
  Status: `done` / bounded Perl availability and portable evidence admission
  Goal: Execute deferred aggregate numeric calls/overloads and terminal receivers.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.6`
  Scope/custody: docs/checkpoints/type-aggregate-codeblocks/; whole drop10334/clean readonly0 preserved. Aggregates are separate from scalar ADR0029;95/94/35 retain ownership.
  Verification tier: `canonical`
  Focused checks: Public descriptor/Get/dump/fresh routes; six families/names/receivers, arity/kind/empty/effects; scalar5/drop6/direct tests; book/Knowledge/doctrines.
  Canonical trigger: Public callback availability and emitted invalid-shape diagnostics; exact staged receipt.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.7.json`
  Intake: baseline176/dump3 retain42 deferred and6 ordinary arity failures; fix dispatch/shapes here. Next9 owns sorted. Rejected instruments and exact sources survive in the checkpoint.
  Catalogue defect owned/fixed here: num_round half-up wording contradicted scalar ADR0029/round_negative_half; clarify halves away from zero without changing behavior.
  Guard intake: New numeric preflight dereferenced a non-hash serialized call before the existing typed guard. Public invoke reproduces raw Perl text; real accepted Runtime gives invalid_codeblock_body. Restore the guard and lock null/string/list members plus unchanged caller/record. The initial shadow comparison misloaded current code and remains rejected preparation. Final source replay and dependent verification follow.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Accepted missing dispatch and healthy ordinary controls.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Tool-identified runtime owner and separate aggregate authority.
  - [x] **FIX** — Bounded dispatch/overloads with existing family consumption rules.
  - [x] **ADDRESSED (verified)** — Values/diagnostics/effects and actual faults/restoration.
  - [x] **NO REGRESSION** — Scalar/drop consumers, relevant permanent tests and selected gates.
  - [x] **LOCKSTEP** — Worked book/facts/current pointer; known separate defects stay explicit.

  Verification:214/106 RED/108 controls;7 actual faults/restorations;14/1948;201+3 permanent/15 malformed;book89/3/heading RED;650 history controls unchanged. Claim publication and exact canonical receipt govern landing. Source epochs/rejected preparation remain explicit;95/9 stay owned.
  Render-comparator defect owned/fixed: complete whitespace-normalized HTML first rejected the generated search-index URL. Retained rejection plus actual89-input old/new rebuilds reproduce both pages; decoded indexes differ only in15 whitespace-only chapter-body strings. Verify that payload and every other decoded field before normalizing the one reference.
  Collection-pressure defect owned/fixed: canonical1 observed knowledge_cards1351/1350. Whole second10522/10525 images/actual readonly0 and joined143 failure survive before merging the complete new search finding/questions into the existing fact owner. No budget increase. publish_admitted.py and corrected exact canonical receipt govern landing.
  Notes containment: provisional4959 rollover/whole outputs remain retained. Frozen48-file/47-row archive controls reject it; final compaction restores only its uncommitted manifest/archive changes and shortens this new leaf record below90%. No committed immutable history or budget changes. The two failed pressure epochs remain explicit.
  Containment defects owned here: provisional archive4959 exceeds the frozen engineering_notes collection48-file/47-row controls. Preserve its full generated outputs, restore only that uncommitted rollover, and compact this leaf's new notes below90%; never change old immutable history or limits. Checkpoint context.snapshot also embeds every earlier changed gzip in subsequent snapshots (latest646MB). Preserve those actual epochs/source; retain immutable gzip identities without copying their whole bytes into future overrides. Require an observed old duplication RED and new hash-gated/no-gzip-override GREEN before canonical landing. No runtime/test/book change is involved.
  Git portability defect owned here: actual staged blob census finds158028137/336859903/677062765-byte draft inputs above GitHub100MiB. Whole third10540 publication/actual readonly0/full modes/10543 independently verified staged images survive before migration. Canonical2 is deliberately superseded143, not a success or test failure. Prepare37 independently hash-verified32MiB chunks for1171950805 exact bytes, then track chunks and reconstruct only ignored project-local logical aliases. Prove missing/byte/order/mode controls and fresh recovery before deleting any temporary old-copy backup. No outside storage or repository writes; exact portable canonical receipt governs landing.
  Portable output-root guard intake owned here: test the helper's root validation against the existing Gitlink boundary using metadata/path resolution only, without writing there or reading implementation. If the root itself bypasses the descendant check, retain the old helper/proof epoch, reject nested roots and re-run a fresh local cold recovery with the final helper.
  Commit subject: `TYPE-REFERENCE-BOOK.1.2.7 - execute deferred array reducers`.

  Admission owner: README pressure rejects public_reference50007/50000. Whole first10496 publication/actual readonly0/full modes/10499 Git-verified staged images survive before changes. Reflow prose only, preserve every non-whitespace character/fence and require rendered semantic identity; no budget increase. Failed old preflight intentionally joined143. Corrected49836/50000 passes;171 prose lines removed with complete normalized rendered content identity, unchanged fences and fresh89/3/heading RED. publish_final.py binds the final epoch; exact staged canonical receipt and normal hooks govern landing.

  Portable verification:37 chunks/3 cold aliases/1171950805 exact bytes/full modes; five actual pre-root-guard faults, one metadata-only root RED and final-helper cold replay. Recovered inputs feed actual maintained readers before verified backup deletion/residue0. Whole third10540/images10543 and all earlier epochs survive. Current publish_portable.py, prospective physical-size checks and exact staged Git/canonical receipt govern landing.

- ID: `TYPE-REFERENCE-BOOK.1.2.9`
  Status: `done` / activation49ce3fb
  Goal: Execute deferred sorted/take aggregate pipelines.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.7`
  Reproduce/impact: items.sorted().take(2).sum() yields4 for [3,1,8] outside; deferred raises unknown_helper:sorted.
  Scope/custody: docs/checkpoints/type-array-pipelines/; whole accepted7 claim/10608 physical/3 logical/full modes/10611 Git images and actual clean readonly0 precede changes.
  Verification tier: `canonical`
  Focused checks: Public descriptor/Get/dump/fresh routes; lexical sorting, take default/count/arity/kind/effects/copy/chain boundaries; aggregate/scalar/callable direct consumers; book/Knowledge/doctrines.
  Canonical trigger: Public deferred helper availability and terminal composition admission; exact staged canonical receipt required.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.9.json`
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Accepted deferred failures and ordinary healthy controls.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Toolbox mechanism and public contracts before owner inspection.
  - [x] **FIX** — Sorted/take availability and canonical fluent-argument validation.
  - [x] **ADDRESSED (verified)** — Values/arity/kind/effects/copy plus distinguishing source faults.
  - [x] **NO REGRESSION** — Permanent tests/direct consumers/canonical receipt.
  - [x] **LOCKSTEP** — Worked book, canonical fact and clean handoff; no complete inventory admission.

  Verified scope:85 fixed values/41 actual accepted RED/44 controls; six retained pre-argument-guard source faults plus one final guard fault. Final14/1949 TAP/history650/scanner pass.85 new permanent/one advanced old expectation/75 malformed assertions. First14/1948 failure retains only the old intentional unknown sorted expectation; no other failure is discarded. Book89/3/anchor RED is rerun on final docs/source before publication.
  Custody/admission: Whole accepted7 physical10608/logical3/images10611/full modes/actual clean readonly0 survives at real49ce. All rejected fixture/instrument/metadata epochs stay retained; closed publication/three artifact denials/actual validator fault and exact staged canonical receipt govern landing. No complete inventory/backend or kind13/95 admission.
  Reporting admission: Whole first10716 unpublished claim/publication/10719 source images/full modes/actual source-readonly0 survive before correcting its console6 versus structured7. Final console derives fields from the reviewed result; final artifact4 controls and publication3 bind the actual publisher. Earlier artifact2/3 epochs and whole second publication remain frozen; a stale artifact2 task reference was corrected before canonical admission. Runtime/test/book epochs stay unchanged.
  Commit subject: `TYPE-REFERENCE-BOOK.1.2.9 - execute deferred sorted take pipelines`.

- ID: `TYPE-REFERENCE-BOOK.1.2.13`
  Status: `done` / selected proof; exact canonical admission required
  Goal: Preserve numeric kinds through lexical sorting and container copies.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.9`
  Owned paths: docs/checkpoints/type-sort-copy-kinds/; MethodLowering sorted emitters, BindingRuntime sorted comparator, permanent numeric/kind tests, public book/fact and normal continuity. CodeblockRuntime cloning remains a direct consumer; reducer95 is separate.
  Verification tier: `canonical`
  Focused checks: Fixed native/Get-dump/descriptor/fresh values and typed-index errors; independent B flags, JSON and clone kinds; numeric-looking strings, null/boolean and lexical order; source/result independence, ordinary/deferred and implicit-accumulator paths; direct consumers, book/Knowledge/history/doctrines.
  Canonical trigger: Observable Perl scalar-kind and pure-sort correction; exact staged canonical receipt required before normal landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.13.json`
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Clean accepted9:16 flag/value routes and8 descriptor/Get/dump/emitted cases reproduce numeric-to-string clones and failed numeric indexes.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Generated sorted comparators compare aliased operands; BindingRuntime array_transform does the same on copied elements. String flags then change Storable clone and typed nested-write behavior.
  - [x] **FIX** — Preserve operand kinds without changing lexical/null ordering or coercing legitimate strings.
  - [x] **ADDRESSED (verified)** — Fixed kind/index/copy population and distinguishing actual source faults/restoration.
  - [x] **NO REGRESSION** — Permanent tests, direct consumers and exact canonical receipt.
  - [x] **LOCKSTEP** — Worked book, canonical fact, roadmap and clean handoff; no inventory/backend admission.
  Pre-write custody: Whole accepted9 physical10743/logical3/images10746/full modes, actual clean source-readonly0 and independently verified committed Git images survive at real eff23e489 before changes. All10746 inputs remain unchanged through the new16/8 public baseline.
  Continuity intake owned/fixed here: The tree header still named numeric5/October20 and the parent child list omitted9/13/10/11/12. Align current metadata and child order during activation; detailed dated child evidence stays unchanged.
  Observer correction owned here: First116-case run has unchanged inputs and exit0, but the old public observer prints unencoded wide-character JSON to byte stdout. Its exact warning rejects the strict transport check before loaded-source validation. Preserve all original channels/context; a distinct UTF-8 observer and accepted2 rerun repair transport without changing runtime or weakening diagnostics.
  Direct-test intake owned/fixed here: checks-test-run retains an actual decimals flag RED with unchanged inputs: result gains private iOK while all value/clone kinds pass. Actual assignment/sort preserve flags; dclone adds private iOK to floating-point sources. Capture sort flags before clone; all nine cases/72 assertions then pass. Failed test/diagnosis and broad-count writer rejection remain exact.
  Schedule: Finish13 before deferred count/first10, registered sorted/ordinary length11 and deferred indexed-write12. Keep reducer95 and complete operation inventory separately owned.

  Verified:116 fixed values/47 accepted RED/69 controls; all GREEN. Three old comparator paths, numeric order/coercion and source mutation each reject and exactly restore. Mandatory14/1950/history650/scanner,16 public flag routes and book89/5/heading RED pass. First flag epoch changed a proof-source input and is rejected; flags2 is stable. Three artifact denials and actual validator fault restore.
  Custody: Whole accepted9 and every supplied epoch recover; original transport/test/proof-writer failures stay retained. docs/checkpoints/type-sort-copy-kinds/publish.py is the readonly claim gateway; exact staged canonical receipt and normal hooks govern landing. Next10 only after clean handoff.
  Commit subject: `TYPE-REFERENCE-BOOK.1.2.13 - preserve sorted scalar kinds`.

- ID: `TYPE-REFERENCE-BOOK.1.2.10`
  Status: `done` / selected proof; exact canonical admission required
  Goal: Execute deferred count/first and align their free harray kind guards.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.13`
  Owned paths: docs/checkpoints/type-array-count-first/; CodeblockRuntime count/first dispatch and MethodLowering free-call array guards, permanent consumers, worked book/fact and continuity. Registered sorted/ordinary length11 and indexed writes12 remain separate.
  Verification tier: `canonical`
  Focused checks: Public descriptor/Get-dump/native/fresh values and typed errors; free/receiver shape, empty/kind/continuation/effects, copy/index/source controls; direct consumers, book/Knowledge/history/doctrines.
  Canonical trigger: Observable Perl callable helper availability; exact staged canonical receipt before normal landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.10.json`
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Fresh accepted13 four-case public probe: ordinary2/1; native/fresh typed unknown_helper:count/first. Every10860 full-mode input stays unchanged.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Public Get dumps and CodeblockRuntime::_eval_call/::_eval_fluent_chain show missing count/first dispatch. MethodLowering free harray count/first dereferences defined values without an ARRAY guard; accepted receiver forms give0/undef. The grid independently fixes terminal/arity/effect behavior.
  - [x] **FIX** — Implement only the measured count/first contract without absorbing11/12.
  - [x] **ADDRESSED (verified)** — Fixed typed value/effect population and distinguishing source faults/restoration.
  - [x] **NO REGRESSION** — Mandatory tests/direct consumers and exact canonical receipt.
  - [x] **LOCKSTEP** — Worked book, canonical fact, roadmap and clean handoff.
  Pre-write custody: Whole accepted13 physical10857/logical3/images10860/full modes, independently Git-verified images and actual clean readonly0 survive at real a8bd8620a. Exact old intake/oracle and current public observer remain committed inputs.
  Schedule: Finish10 before11/12, then inventory1/mapping2/layout3. Detailed proof lives in the checkpoint.
  Additional defect owned/fixed here: ordinary count(items)/first(items), with items={"k":"v"}, leaks raw Not an ARRAY reference in native/fresh execution. Match the already quiet receiver0/undef and scalar/undefined controls with narrow array-kind guards.
  Commit prerequisite owned here: Required complete change/note records trigger real history rollovers. Preserve every immutable member and exact clean-source suffix; ADR0137 admits only the two measured members/manifest overhead and its own decision/index lines. No runtime scope expansion or future archive reserve. Verification and claim include this prerequisite.
  Diagnostic correction owned here: A reported65,536-byte tree ceiling came from the one-shot activation actor's capture guard. The task_evidence registry and collection checker use1,048,576 bytes, with no TYPE override. task-limit-review.json.gz retains the actual capture-guard RED and production collection/metadata GREEN on the same above-guard source. The incorrect capacity warning is closed; count/first scope/order stays unchanged.

  Verified:232 fixed cases/107 accepted RED/125 controls;8 restored source faults;14/1950 TAP;history680;book89/5 and actual heading RED. Eight faults cover dispatch, arity, terminal effects, selection and both emitted kind guards. Permanent fixture is exact; full book/Knowledge follow current behavior.
  Documentation defect fixed: two first-selection result rows called every result scalar. The nested/callable fixed cases and worked selection example demonstrate stored values; both rows now say stored value. Distinct final doc3 proof renders all89 inputs and executes all five bodies.
  Corrections closed: duplicate-key plan/warning; shared fault marker; ordinary-only unused-interpreter loader; known root-LF reconstruction; rejected fact-budget proposal; reviewer keyword syntax; one stale AST emitted-source golden. Thirteen original suites pass; the sole AST source expectation is repaired and all23 AST groups independently pass. Production identities remain unchanged. Original sources and observations survive; distinct controls pass. First interrupted change apply channels were not retained; exact published state and later no-op/check channels reconstruct the real source without archive edits.
  Custody/claim: docs/checkpoints/type-array-count-first/publish.py; full prior13 and all supplied epochs recover. ADR0137 is solely the measured commit-continuity prerequisite. Commit subject: `TYPE-REFERENCE-BOOK.1.2.10 - execute callable count and first`. Next11 only after clean canonical/normal landing.

  Additional owned paths: t/phase0_regression.t guard literals, tests/language-readiness/count-first-regression-evolution.json, verify_objectives.py and the read-denied audit driver input closure. Canonical tier covers this exact inverse admission; older tables and runtime source stay unchanged.
  Final pre-CI source search owns ten stale Phase0 emitted-source expectations (eight count/two first). Reproduce through the exact selected real roots, update only guard literals, and admit a separate hash-gated inverse before the unchanged historical layers. Preserve old tables, all650 controls and add omission/duplication/corruption controls for every new hunk. Whole unpublished draft1/11015 inputs/full modes/actual readonly0 survives; no acceptance revision is fabricated.

  Final historical admission verified: 3 real Phase0 roots reject old expectations and pass all10 guard corrections;1031 roots explicitly skipped. The complete historical audit preserves650 older controls and adds30=680 denials. Actual inverse removal and table-byte/hash-check faults reject, admit under bypass, and restore exactly. The original unpublished draft1 remains whole and independently recoverable; publication2 governs this resulting tree. Older inverse tables and runtime producer bytes remain exact.

  Defect owned: Canonical production path checker rejects two new Phase0 summaries because the observer copies an absolute loader path into plain JSON. Reproduce with scripts/check_repo_root_path_portability.sh. Runtime and raw loader verification pass. Preserve whole unpublished draft2 and actual readonly0/production RED, normalize only published paths, retain original raw/producer bytes, and require fresh book/artifact/path/canonical proof. Original failed gate was terminated143 after its reported denial; no successful canonical claim is made.

  Portability defect verified fixed: both published Phase0 loader paths are repository-relative; exact raw outputs and original summaries remain in frozen draft2. The actual production path checker rejects the old candidate and passes the repair. Distinct doc4 re-renders89 inputs/executes five bodies with heading RED; artifact3 rejects missing/byte/mode declarations, admits them under an actual validator fault, and restores. Publication3 governs the resulting tree; prior publications stay immutable. Exact canonical receipt and normal hooks remain mandatory.

  Defect owned: Canonical attempt2 completes1 with three stale count-source expectations in t/actionir_method_kind_capture.t (outer/scalar, outer/function-present, outer/function-tied-bad). All90 other private files pass. Preserve whole unpublished draft3/actual readonly0 and complete failed channels, keep native capture bytes exact, update only these current expected guards, and independently execute every affected emitted expression against arrays/nonarrays. Require actual translation-omission and matched old-guard semantic RED, exact restoration, new publication and exact canonical admission.

  Private guard compatibility verified: three current expectations change only their reviewed count guards. Original native captures stay exact.236 assertions pass, including seven independent execution inputs per row. Actual expectation omission rejects; matched old guard/source expectations reject solely in behavior checks; exact production/test restoration passes. Draft3 retains11100 inputs/full modes, actual readonly0 and the completed canonical2 failure. Distinct doc5/artifact4/publication4 bind this candidate; all earlier publications remain immutable. Exact canonical receipt and normal hooks govern landing.

- ID: `TYPE-REFERENCE-BOOK.1.2.11`
  Status: `completed` / bounded behavior and conservative input closure verified
  Goal: Repair registered sorted receiver pipelines and ordinary length continuation.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.10`
  Reproduce/impact: Baseline registered fn select_items marks sorted unresolved, returning[] ordinarily and user_function_body_unsupported from a codeblock. Ordinary sorted().take(2).length() stays raw and calls an undefined host sorted; deferred length works. candidate1/inspection retain sources.
  Schedule: Completed after10/maintenance20; deferred indexed-write12 is next, then last14 before inventory1.
  Evidence: docs/checkpoints/type-array-pipelines/findings.md; whole source epochs remain retained.
  Verification tier: `canonical`
  Focused checks: Fixed public descriptor/Get/dump/native/fresh grid; registered parameter/local/rest/nested and free controls; lexical kind/copy/empty/nonarray/effects; permanent scalar consumer and direct dependents; actual source faults/restoration, full supplied book and artifact controls, Knowledge/history/doctrines.
  Canonical trigger: Public Perl pipeline availability and terminal/invalid-shape contract; exact staged canonical receipt required before normal landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.11.json`
  Activation: Clean afc58252ca36d53076929cd51e3ad445e4953341; no modified/untracked files and brief0. Four checked-live claims have no direct planned-surface intersection. Public Get/descriptor/native dump/fresh emitted execution confirms registered receiver[]/typed unsupported sorted and ordinary length raw host call; free registered calls and deferred length are controls. All initial sources/channels survive in the owned checkpoint before repair. The first deferred fixture used codeblock() rather than the documented {|| ... } literal; its value_not_callable result is an instrument error, retained without product-defect credit.
  Verified selected proof: 56 cases/31 accepted RED/25 controls;compatibility4;8 restored source faults;15/2186 direct TAP;book89/2+inline2 and actual anchor RED;artifact3. Exact canonical receipt and normal hooks govern admission; no full reference/backend claim.
  Additional defect owned here: The declared length controls reproduce deferred source().length().abs() evaluating source/continuing, while ordinary terminal length skips source; deferred length(extra) also evaluates effects and raises unknown_helper. Matched the documented terminal/no-argument receiver contract in the existing deferred preflight. Fixed56 baseline has31 failing cases/25 controls; complete public sources/channels and all regular repository input identities precede repair.
  Compatibility repair verified: The complete first direct15/2186 run passes14 suites but rejects two unchanged count/first10 ordinary receiver-extra-arity cases. Candidate3's bridge bypasses their former AST arity rejection, emitting raw host tap calls. Complete failed channels/source epoch and the old fixture remain exact. Actual single-bridge rollback GREEN/reapply RED attributes the regression; shared preflight restores all four old controls. Final selected/fault/book/direct proof passes; exact canonical receipt governs admission. The early documentation gate rejects only the not-yet-regenerated Knowledge Map; no pressure-limit change is proposed.

  Root cause/fix: MethodLowering::_lower_ast_fluent_chain_node reparsed synthetic expressions containing emitted function/callback values as DSL. Reuse its existing compatibility bridge; append length as an array terminal and reject sorted/take/length plus existing count/first shapes before effects. CodeblockRuntime adds length to the existing terminal preflight. No grammar, descriptor or dependency change.
  Review: Candidate1 introduced nested parameter arrays and lost computed take inputs; complete source/channels remain frozen. Candidate2 passed the new plan, but actual ablation proved its name/constructor edits redundant. Minimal candidate3 passes that plan but fails two old selectors in the first complete direct run. Candidate4 restores their shared preflight and passes56 new/four unchanged controls. Eight final faults require the bridge, array length, compiled guards, registered sorted/take guards and deferred length arity/terminal guards.
  Documentation: Both exact book bodies and two inline routes execute on final source; all89 supplied book inputs render, actual anchor removal rejects, reference/limits/fact align. The first fact proposal refuses before writes; distinct document2 plus precision correction preserve old questions and fit unchanged budgets. The unused faults.py draft has no observation credit; seven faults2 observations belong only to the intermediate source. A final-instrument exact-one marker refuses the actual three manifest literals before output creation; distinct counted producer succeeds.
  Durability: Current publish5.py conservatively gates every regular main-repository input, including continuity, with the complete measured epoch and independent required-fixture floor. Original unpublished publication2/714 inputs and actual readonly0 remain whole; README/claim before images preserve the only subsequently changed bound images. Gitlinks/symlinks and public tool/dependency outputs remain read-only prerequisites. No minimal I/O graph, fabricated accepted revision or wider historical-audit closure is inferred.
  Publication prerequisite verified: Initial live714 omits four named inputs: nested-tree/scoped-with case JSON and two private before-native captures; their complete measured epoch and Git recovery were already retained. Whole unpublished publication2/714 physical inputs/full modes and actual readonly0 precede expansion. Actual input-enumerator omission rejects against the measured floor, admits under actual scope-validator bypass, rejects after validator restoration and restores exactly. Three current publisher missing/byte/mode controls also reject/bypass/restore. The first scope3 instrument calls absent common.paths and all states fail before validation; it receives no RED credit. Distinct publisher4 owns the explicit regular Git/untracked census. Existing canonical closure fact is updated with old body/questions retained and no byte increase.

  Final admission: 56 cases/31 accepted RED/25 controls;compatibility4;8 restored faults;15/2186 TAP;book89/2+inline2;artifact3;fixture omission/bypass/restoration. Current gateway publish5.py; exact staged canonical receipt and normal hooks remain mandatory before clean landing. Runtime and all fixture expectations remain unchanged by the closure repair. Next12 only from clean Git.
  Controller repair verified: Capture4 writes its manifest then fails on imported review4/unbound review3; no publication/claim write and no normal-entrypoint success is claimed. Whole failed11350 identities, original source/log/status and every planned changed image precede repair; remaining inputs stay exact at their supplied paths. Distinct publisher5 shares review_result between readonly --review and capture and executes it before manifest creation. Current scope5/artifacts5 controls pass, with unchanged runtime and test expectations. The premature staging is superseded by restaging only after successful normal capture and readonly verification.
  Session health: Avoidable controller mistakes in this long session indicate that fresh context would help after a clean commit. Required publication/canonical/normal admission remains mandatory; no dirty pivot or unverified handoff is authorized. Source, test oracles and all observed failures remain retained.


- ID: `TYPE-REFERENCE-BOOK.1.2.12`
  Status: `completed` / bounded deferred-write foundation; exact canonical receipt governs landing
  Goal: Execute typed indexed writes inside deferred codeblocks.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.11`
  Verification tier: `canonical`
  Focused checks: Public LinkedSpec::Get/return_descriptor/dump_parser_source/native/fresh indexed-write cases; frozen write fixtures; copied parameters/alias/null/effect/guard/malformed controls; permanent callable/multiline and direct dependents; complete mdBook; source faults and input/scope denials.
  Canonical trigger: Public deferred typed-write availability; exact staged canonical CI and normal hooks required.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.12.json`
  Activation: Clean 24e9c72a31b7eb31ce94b09beab9655ae85378cb. Whole accepted11 readonly replay and original live claims precede writes in prior-accepted.json.gz. Pipeline11 is frozen at this actual accepted Git revision with observations unchanged.
  Completion: 84 public cases/54 accepted-source RED/30 controls; 16 source-fault9 controls plus the actual private-consumer inverse; 22 suites/3098 top-level TAP; private 296 rows/26 deliberate consumer changes; book 89 inputs/4 executed examples with heading/prose/URL denials; three identity denials and 3 required-fixture omission/bypass/restoration controls. Readonly: bash tools/run_python_project_data.sh docs/checkpoints/type-deferred-indexed-writes/publish4.py.
  Mechanism: CodeblockRuntime delegates assign_nested_access to BindingRuntime. Basic write/operand headers validate before effects; receiver guard precedes keys then RHS, each once; root snapshot follows their effects and publication is atomic with detached results. Caller scalar inventories pass presence independently of callback origin. Weak resolved-slot identity retains presence across separately forwarded callbacks. New slots reuse supplied flags. Copied fixed/rest parameters restore caller slots/flags on every exit. Standalone ordinary fragments keep their existing declaration contract.
  Canonical compatibility repairs: The first exact staged candidate reached1035 and failed only800/1034. Broader tracking exposed a statement result replaced by flag=1; return scalar(value) while preserving presence and quiet void/value/list use. The legacy splitter passes incomplete naked regex fragments; leave those fragments intact instead of wrapping an unfinished pattern. Ten permanent lifecycle/value controls and independently emitted LF/CRLF escaped-brace controls preserve prior behavior. The final direct set includes the unchanged multiline consumer. Exact staged canonical proof remains a separate admission requirement.
  Retained rejected epochs: rejected-canonical1.json.gz keeps the complete actual combined log, original unpublished claim/publication/manifest, exact source epoch, index/fingerprint and actual readonly PASS. It was never an accepted Git state. Every earlier attribution/fault/book/focused capture remains immutable; final9 sources earn current proof. First wrappers, fixture parentheses, negative-error adapter, wrong ordinary fault target, failed CODE serialization, allocation-fault marker, publication-preparation failure and mis-scoped fixture edit retain actual observations without successful-control credit. final-continuity-before.json.gz keeps the full preceding task narrative.
  Instrument qualifications: The first raw-host probe required quietness without initializing Perl's default subject; actual accepted replay has the same warning. Explicit subject calibration passes both epochs without suppression. focused7 failed a fixture-adapter edit in the wrong similar loop; the scoped correction is retained. Its two new void warnings led to assignment-result-context-before.json.gz and the permanent scalar-context regression, not diagnostic filtering. Unsaved first fact-budget draft channels remain unavailable.
  Additional defect owned: Two LF source/subject pairs on accepted and final current native/fresh routes match an inserted-semicolon raw regex rather than the authored pattern. An independent direct literal oracle distinguishes them. compatibility3 retains source/subjects/oracle and exact accepted rollback/restoration. P2 child21 owns payload repair after19 and before20/inventory. The book documents the bounded legacy limitation; general raw-regex fidelity is not admitted here.
  Render evidence: Original book4 HTML reproduces exactly. The sole authored limitation paragraph is an explicit retained overlay before comparing the current reflowed page. After that overlay, all page/code/script/style/link tokens and complete search data agree except body whitespace; native JSON.parse calibrates both payloads. Actual heading/prose-source/URL corruptions reject. Existing Accepted7 retrieval was missed before re-derivation; it is reconciled with the original rule, not claimed as a novel result.
  Durability/limits: publish4 watches the conservative complete regular main-repository superset, including the measured epoch floor and three independent named fixtures. Every capture retains its actual producer, sources and changing artifacts; final continuity is later authored state. No minimal I/O graph, recursive ActionIR-carrier admission, other-backend, signed17, last14, deferred-with16, complete inventory or broader historical-audit completion. System tools/public dependency outputs are read-only prerequisites; Gitlinks/symlinks/other repositories are excluded. Host process inspection was read-only and established active probes, not a performance cause.
  Final staging hygiene: Git flags the exact paragraph fixture's two-newline separator. publication2-whitespace-boundary.json.gz retains the whole completed second publication, actual readonly PASS and source epoch before any change. A path-specific blank-at-eof attribute preserves the measured input bytes, matching existing verbatim-delimiter exceptions. publish3/artifacts4 refresh only publication closure and validator controls; functional/frozen/book/source-fault9 observations remain exact.
  Canonical2 rejection owned here: The complete private population91/32246 fails only tracking_predicate_capture,26/516. Its old native consumer rows still expect a presence-only statement or a bare-variable result. The corrected statement now emits scalar(value); the overloaded target's source construction also stringifies one additional identifier occurrence. rejected-canonical2.json.gz keeps whole publication3, actual readonly PASS, complete log/source epoch and complete loaded/cold probe rows before writes. Compare every field and preserve original fixtures; qualify only the deliberate consumer-emission boundary, with independent executable value/quietness and actual inverse controls. Predicate selection, local aliases, tied fetches, boolean coercion/errors and private authority remain protected.
  Acceptance checklist:
  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/return_descriptor/dump_parser_source native/fresh observations in attribution9 retain actual accepted-source typed-write failures; forwarded/caller/missing-slot and compatibility REDs remain separately retained.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Missing runtime dispatch, caller/forwarded/allocation presence loss, late operand validation, and statement/raw-fragment wrapping are isolated through public probes and actual source controls.
  - [x] **FIX** — Atomic BindingRuntime delegation, pre-effect guard/headers, ordered operands, slot flags/parameter restoration, scalar assignment results and unfinished-pattern preservation.
  - [x] **ADDRESSED (verified)** — Actual accepted rollback/reapplication, frozen independent write/error/evaluation controls and 16 syntax-valid restored source faults distinguish faulty implementations.
  - [x] **NO REGRESSION** — 22 source-bound suites pass, including the complete516-check private consumer. Exact staged canonical3 and normal hooks govern admission; both prior failures remain retained.
  - [x] **LOCKSTEP** — Worked book/guide, canonical facts/derived map, roadmap/index/live docs, source-bound claim and queued21 agree. Due hygiene21 then director-priority signed17 follow clean12.
  Commit: `TYPE-REFERENCE-BOOK.1.2.12 - execute deferred indexed writes atomically`

  Private consumer completion: Complete296-row comparison isolates26 deliberate nested-consumer source changes and exactly one target conversion4->5; every other predicate/authority field stays exact. The original native JSON and probe match real clean Git. The test projects expected consumer source only, never observed rows. An actual syntax-valid old-result inverse rejects both this consumer and executable value/quietness assertions, then restores GREEN. Source9 is unchanged; earlier functional/fault/book observations retain their exact epochs. Focused10 adds the previously missed direct private consumer. Publication4/artifact5 independently require the original native fixture alongside the existing public/multiline fixtures. No distinct fault-family count is inflated by the extra inverse.

- ID: `TYPE-REFERENCE-BOOK.1.2.14`
  Status: `pending` / P2 defect owned
  Goal: Execute deferred last array selectors.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17`
  Reproduce/impact: Leaf10 contract-grid retains ordinary last(items)/items.last() returning1 for [2,10,1], while both deferred native/fresh routes report typed unknown_helper:last. Source bodies and loaded source identities survive in docs/checkpoints/type-array-count-first/.
  Schedule: After11/12, before inventory1. Establish shape, kind, empty, terminal/effect and copy/index controls; do not extend current10.
  Planned tier: `canonical`
  Claim verification: none: Pending repair; actual source-bound intake belongs to10, with no last admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.17`
  Status: `active` / intake17.0 and CLI17.8 complete; contract17.1 next
  Goal: Admit tail-relative negative array selectors across ordinary/deferred reads and writes on every runtime.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.12`
  Director instruction (October23): For array size L, [-n] selects [L-n], valid only when L-n >= 0. Therefore -1 is the last element and -L the first; a more negative selector is out of range and never creates elements. This supersedes the frozen nonnegative-only write policy for existing arrays. Quoted strings remain hash keys; positive indexing and exact-length append retain their existing contract.
  Schedule: First clean slice after deferred-write foundation12, before last14, deferred with16 and complete inventory1. Do not pivot or mutate shared contracts while12 is dirty. Foundation12 records the old nonnegative-only boundary as an explicitly pending transition and does not claim signed-selector support.
  Acceptance: Establish current public ordinary/deferred/native/fresh behavior before repair; freeze a complete signed-index contract with empty/out-of-range, dynamic/literal, nested mixed paths, copy/alias, atomicity, effects and diagnostic controls. Implement and verify the same shared policy on Perl/Rust/Dart/Julia/PUC Lua/LuaJIT through their owned interfaces; update recurring/public guards and book examples without consulting dependency internals. Keep every historical source-bound claim recoverable; use child leaves and one commit per bounded contract/backend/admission slice.
  Planned tier: `canonical`
  Claim verification: none: Director policy intake and scheduling only; source-bound measurements belong to child leaves after the clean12 boundary.

  Activation: Clean 92c98fb3de0f8392abde59043bd6f67ba0199452 after hygiene21 all10 normal hooks/post-pointer/brief0 and clean Git. Whole current bounded hygiene publication and actual readonly0 plus55 independently Git-verified images precede this first tracked write; no live claim intersects the explicit read/write/book plan. The unrelated private-capacity Knowledge card and its claim remain untouched.
  Children: `TYPE-REFERENCE-BOOK.1.2.17.0`, `TYPE-REFERENCE-BOOK.1.2.17.1`, `TYPE-REFERENCE-BOOK.1.2.17.2`, `TYPE-REFERENCE-BOOK.1.2.17.3`, `TYPE-REFERENCE-BOOK.1.2.17.4`, `TYPE-REFERENCE-BOOK.1.2.17.5`, `TYPE-REFERENCE-BOOK.1.2.17.6`, `TYPE-REFERENCE-BOOK.1.2.17.7`, `TYPE-REFERENCE-BOOK.1.2.17.8`.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.0`
  Status: `completed`
  Goal: Establish current signed-index behavior and a bounded v1 transition plan before changing runtime or shared authority.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.12`, `REPO-HYGIENE.21`
  Owned paths: docs/checkpoints/signed-array-selectors/ public-interface observations/reviewers; four indexed-read/write/Perl-CLI Knowledge cards, DSL values/flow and public Perl integration book pages, two exact examples; normal continuity/roadmap/index. Full checked-live census and before packets precede these bounded documentation writes. All frozen authorities and other repositories/submodules stay unchanged/read-only.
  Verification tier: `focused`
  Focused checks: Actual clean prior publication and complete checked-live claim census; source-bound owned contracts/public producers before native/fresh probes; ordinary/deferred literal/dynamic negative/empty/range/read-purity/effect controls on six runtime routes through published interfaces; independent oracle/reader denials; Knowledge/book/history/memory/whitespace and normal doctrines.
  Canonical trigger: none — diagnostic baseline and internal transition design only. Contract/checker, runtime, generated carrier and admission changes belong to canonical children.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.0.json`
  Acceptance: Retain exact current behavior without inferring support from a host language. Reconcile v1 creation/diagnostic/evaluation/read-purity constraints with the director's existing-array tail-relative rule. Enumerate affected public guards/direct consumers and choose a safe backend transition. No runtime or portable admission.
  Pre-write scope qualification: The first broad read-only proposal treats every Knowledge/book path as planned and correctly refuses an unrelated private-capacity-card live intersection before writes. This distinct explicit plan excludes that unrelated card; repeat baseline/full source/live census precede owner activation. Original whole first stdin/channels were not separately retained; its observed exit1/AssertionError identifies only that broad scope refusal, with no product/falsifier credit.

  Diagnostic hold (owned here): The32-source descriptor/Get-dump/native/fresh Perl packet is retained before any SUT edits. Ordinary literal/dynamic negative array reads work; callable negative reads yield null, and valid negative writes report nested_write_segment_invalid. One comparison control, tree={"-1":"key"}; chosen_index="-1"; return(tree[chosen_index]), yields null on both routes while the quoted-literal twin returns key. Do not classify it from the provisional expected value: reconcile the separately governed read-key policy and exact Toolbox emitted mechanism/source location first. Frozen write-v1 only treats its own negative absent-root case; no new runtime or contract claim is admitted.

  Diagnostic resolution: key-control-qualification.json preserves the original wrong target without changing any observed row. The canonical terse-direct-access-bare-path-atoms card classifies an ordinary bare variable as an array index. Get dump emits ValueExpr::_emit_guarded_direct_read_expr's ARRAY guard (ValueExpr.pm:504), so an harray receiver correctly yields null; the literal quoted-key twin yields key. No product defect is declared for that control. Existing-array ordinary negative reads use the retained Perl array cursor; CodeblockRuntime.pm:694/702 instead requires digit-only indexes, explaining callable null. BindingRuntime.pm:56 rejects negative integer write selectors. These exact source packets/observations are retained; the requested read/write repairs remain owned by canonical child17.2.

  Native survey completion:32 exact sources execute through all six public primary commands with full channels, source unchanged, actual Rust executable and both Lua native-adapter inputs retained. Get/fresh identifies12 typed Perl failures that the Perl CLI reports as exit0/null; all five other routes report invocation failure. P1 repair17.8 is mandatory immediately after this intake clean commit. Rust negative reads return the first element even for underflow; actual public binary calibration/source packets identify the unsigned conversion and existing negative-coercion unit, owned by Rust child17.3. No backend signed admission is inferred.

  Completion: 32 exact sources/192 native observations plus Perl descriptor/Get/fresh; eight signed-oracle RED routes; Perl CLI protocol RED/five other GREEN; book91/two native-fresh examples/three actual source denials; identity3/scope2 bypass-restoration; Knowledge -1824 bytes; no signed admission. Whole retained Rust/Lua products, eight complete source epochs, independent Git source review and complete actual channels remain recoverable. Read-only: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-selectors/publish.py. Original comparison/proposal failures are instrument qualifications, without product RED credit. Frozen-v1 and current runtimes are unchanged.
  Acceptance checklist:
  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/return_descriptor/dump_parser_source plus native/fresh32 and six public CLI routes retain exact signed gaps and context-only errors.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Source-bound Perl guarded/digit-only/write-selector branches, Rust unsigned cast and CLI exception-only branch explain the observed differences.
  - [x] **FIX** — Intake resolves the provisional key-control expectation, documents current limits and owns separate canonical contract/backend/P1 repair leaves; no runtime repair is claimed here.
  - [x] **ADDRESSED (verified)** — Independent13-case director oracle and CLI-protocol oracle observe diagnostic RED; three actual book-source denials and input3/scope2 bypass/restoration distinguish missing evidence.
  - [x] **NO REGRESSION** — Unchanged frozen authority/checker and focused typed-write/read consumers pass; Knowledge/history/memory/whitespace and normal hooks govern landing.
  - [x] **LOCKSTEP** — Two executed book examples/current qualifications, four canonical cards/derived map, roadmap/index/live pointer and source-bound claim agree. P1 CLI17.8 is first clean next action.
  Commit: `TYPE-REFERENCE-BOOK.1.2.17.0 - record signed-index baseline and CLI repair priority`

- ID: `TYPE-REFERENCE-BOOK.1.2.17.1`
  Status: `pending`
  Goal: Freeze the signed neutral contract/checker and historical-v1 transition.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.0`, `TYPE-REFERENCE-BOOK.1.2.17.8`
  Planned tier: `canonical`
  Claim verification: none: Pending transition child; declare source-bound measurements before activation.
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.2`
  Status: `pending`
  Goal: Implement signed ordinary/deferred reads/writes on Perl.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.1`
  Planned tier: `canonical`
  Claim verification: none: Pending transition child; declare source-bound measurements before activation.
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.3`
  Status: `pending`
  Goal: Implement the same policy through Rust native/generated interfaces.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.2`
  Planned tier: `canonical`
  Claim verification: none: Pending transition child; declare source-bound measurements before activation.
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.4`
  Status: `pending`
  Goal: Implement the same policy through Dart native/generated interfaces.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.3`
  Planned tier: `canonical`
  Claim verification: none: Pending transition child; declare source-bound measurements before activation.
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.5`
  Status: `pending`
  Goal: Implement the same policy through Julia native/generated interfaces.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.4`
  Planned tier: `canonical`
  Claim verification: none: Pending transition child; declare source-bound measurements before activation.
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.6`
  Status: `pending`
  Goal: Implement the same policy on shared Lua, independently verified on PUC Lua and LuaJIT.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.5`
  Planned tier: `canonical`
  Claim verification: none: Pending transition child; declare source-bound measurements before activation.
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.7`
  Status: `pending`
  Goal: Admit the complete six-runtime policy, recurring compatibility and public examples; split capability/recurrence/public children before writes when needed.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.6`
  Planned tier: `canonical`
  Claim verification: none: Pending transition child; declare source-bound measurements before activation.
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.8`
  Status: `completed` / P1 public-command defect repaired
  Goal: Report Perl library runtime failures through the primary CLI instead of successful null output.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.0`
  Original reproduce at329cee31c: Top: /x/ followed by I { items=[10,20,30]; items[1.5]=99; return(items) }. Public Get/runtime_ctx_ref and fresh emitted execution report nested_write_segment_invalid, but perl -Iperl bin/linkedspec --inline-spec SOURCE --input x exits0 with null plus LF and empty stderr. Twelve retained invalid-write sources have the same CLI success classification; all five other native runtime routes exit1 for those sources.
  Original impact: Scripts accept failed parsing/action execution as successful null data; the existing primary command invocation-failure protocol is violated independently of requested negative indexing.
  Original mechanism: bin/linkedspec already supplies runtime_ctx_ref, but its post-invocation branch checks only the exception in $@ and ignores context last_error when the library returns undef after a handler failure. Exact current source/complete channels are retained by intake0 and CLI-RUNTIME-ERROR.md.
  Schedule: First clean leaf after intake17.0, before neutral contract17.1. Intake17.0 finished unchanged and committed before this repair; no dirty pivot or silent baseline replacement.
  Owned paths: bin/linkedspec, t/trace_cli.t, docs/checkpoints/type-cli-runtime-errors/, current Perl CLI Knowledge card/public integration book and the related DSL flow error-reporting link; normal task/roadmap/continuity. The explicit flow-link extension is checked against the complete live census before its first write. Other repositories/submodules and frozen selector authorities remain unchanged.
  Verification tier: `canonical`
  Focused checks: Public Get/descriptor/dump/native/fresh and exact CLI before/after/source-inverse channels; valid null/false/no-match controls; permanent trace/CLI consumers and shared manifest default/POSIX; current Knowledge/complete rendered book; artifact/scope falsifiers, memory/history/whitespace and normal doctrines.
  Canonical trigger: Public primary-command runtime-error reporting repair; exact staged canonical CI and normal hooks before admission.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.8.json`
  Acceptance: Observe thrown and context-reported failures, preserve legitimate null/false/no-match results, emit the existing invocation-failure heading/exit and error trace, add distinguishing permanent CLI proof, retain actual before/after/source-inverse channels and all fixture inputs, update current book/Knowledge, and run exact canonical admission. Other repositories remain read-only.

  Original control hold: baseline.json.gz preserves nine public/library sources, eighteen CLI commands and actual permanent RED before any CLI change. The provisional no-match source uses I{return(42)} and returns42 on input y; its expected null is wrong. Canonical top-rule-reads-own-match-with-match-family and rust-lifecycle-i-return-dispatch-parity explain that I executes before matching and return exits immediately. Get/native/fresh source has direct return42 in the handler. Qualify the original target/rows without replacing them; probe a genuine post-match/no-match source before revising the permanent test. No separate product defect or successful no-match/product-RED credit is earned by this mistaken control.

  Control resolution: Complete Get/native/fresh alternative probes retain bare-rule0 and explicit self-edge input-y null/input-x42. The canonical action-and-lifecycle-placement chapter says selection alone does not test the selected rule's regex; an explicit incoming/self edge selects it. cases2/oracle2/baseline2 and the revised permanent controls are distinct from all original producers/targets/observations. Preserve I-return42 as a legitimate result and add both genuine matching twins. At that capture boundary no CLI/runtime change had occurred; only the three typed failures and their trace earn product RED credit. The original third permanent failure and original oracle's two no-match rows are instrument qualifications only.

  Corrected baseline: baseline2.json.gz retains11 source/input cases (10 distinct source texts),22 quiet/routed CLI commands, complete public descriptor/Get/dump/fresh output and actual permanent RED at unchanged bin/linkedspec. The source-inverse repair actor checks the independent corrected oracle before its first CLI write. Original producers, targets, outputs and failed-control channels remain unchanged. This leaf does not implement negative selectors.

  Activation: Clean 329cee31c566cfb054557b8a2ebab62bac015db1 after intake17.0/all10 hooks/post-pointer/brief0. Whole accepted intake publication/claim/manifest and actual readonly0 plus82 independently Git-verified images precede repair writes; complete checked-live census has zero planned-path intersections. Prior intake remains live/unchanged. Redundant standalone gate termination143 is qualified in activation evidence.

  Completion: 11 source/input cases/10 source texts,22 quiet/routed commands;6 corrected-baseline CLI RED; 7 successful controls and unchanged thrown-error protocol;6 permanent groups GREEN, actual old-predicate inverse2 failed groups/restored GREEN;book91/two executed commands/three source denials; identity3/scope2 bypass-restoration;Knowledge +263 bytes within unchanged limits. Read-only: bash tools/run_python_project_data.sh docs/checkpoints/type-cli-runtime-errors/publish.py. Full public scope is the separate green epoch; inverse/restored scope is the actual permanent consumer. Nine complete source epochs/11504 unique accepted Git blobs, exact one-condition source overlay, prior82-image custody, actual source packets/channels and qualified failures remain recoverable. No library/selector/trace-schema or wider backend admission. Exact canonical proof and normal hooks govern landing.
  Final staging hygiene: The first unpublished publication/claim/manifest and actual readonly0 precede containment in publication1-whitespace-boundary.json.gz. The copied source-epoch helper had one redundant EOF blank; trim only trailing LF, prove identical Python AST and retain every old input/source/mode. Exact old output copies and whitespace-containment.json.gz preserve the boundary. Rebind publication after containment; no functional, book, inverse or artifact observation changes.
  Acceptance checklist:
  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/return_descriptor/dump_parser_source/native/fresh identify three typed handler failures; corrected baseline22 CLI commands has six actual protocol RED observations.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Already supplied runtime_ctx_ref receives last_error while bin/linkedspec checked only saved $@. Canonical lifecycle teaching and exact dumps separately resolve the mistaken original no-match target.
  - [x] **FIX** — Check either failure channel before invoke:ok/JSON, using the unchanged invocation error exit/heading/trace.
  - [x] **ADDRESSED (verified)** — Full fixed11-pair public population passes. Actual exact old-predicate inverse restores two permanent failing groups; exact restoration passes all six. Identity3/scope2 and three actual book-source denials distinguish missing/stale proof.
  - [x] **NO REGRESSION** — Seven clear-channel controls and the existing thrown error remain compatible; six permanent groups pass. Exact staged canonical CI and normal hooks are required for admission.
  - [x] **LOCKSTEP** — Current book/two executed CLI commands/flow link, canonical card/derived map, roadmap/index/live pointer and source-bound claim agree. Signed contract17.1 follows clean landing.
  Commit: `TYPE-REFERENCE-BOOK.1.2.17.8 - report context-only Perl CLI runtime failures`

- ID: `TYPE-REFERENCE-BOOK.1.2.16`
  Status: `pending` / P2 defect owned
  Goal: Execute scoped with inside deferred callable bodies.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.14`
  Reproduce/impact: cb = {|| value["x"] = 2 }; case_runner = {|| return(with(undef) { return(cb()) }) }; return(case_runner()) raises unknown_helper:with before the scoped callback. The equivalent compiled with call site reaches the expected typed null conflict.
  Evidence: docs/checkpoints/type-deferred-indexed-writes/deferred-with-intake.json.gz retains the exact source, runtime producers and native/fresh channels after removing the original wrapper-name collision.
  Schedule: After last14, before complete inventory1; establish scoped value/caller frames, null, nesting, error restoration, call shape, effects and native/fresh controls.
  Planned tier: `canonical`
  Claim verification: none: Pending repair; measured intake will be bound to indexed-write12.

- ID: `TYPE-REFERENCE-BOOK.1.2.19`
  Status: `pending` / P2 grouped-assignment value defect intake
  Goal: Resolve grouped indexed-assignment values against the supported mutation-expression contract.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.16`
  Reproduce/impact: Initial indexed-write12 copy control out=(chosen[0][0]=2) produced generated compilation failure near chosen[. Exact source/native/fresh channels survive in baseline.json.gz, not silently reclassified as unsupported syntax. The canonical perl-raw-readiness-source-unit-provenance card admits balanced ordinary mutation receiver groups for reporting; stored assignment-value contexts require separate adjudication.
  Schedule: After signed17/last14/with16, before inventory1. Establish Toolbox AST/lowering/source/runtime/effect/span evidence; fix supported value contexts or accurately document a contract exclusion with proof. Preserve prior reporting-only and deferred raw-group distinctions.
  Planned tier: `canonical`
  Claim verification: none: Diagnosis intake only; baseline observations remain owned by12, with no grouped-value admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.21`
  Status: `pending` / P2 raw multiline regex payload defect
  Goal: Preserve complete assigned raw-regex payloads across statement splitting and native/fresh Perl execution.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.19`
  Reproduce/impact: rx = /(14,2) \\} followed by LF then tail/; return(rx), with explicit host subject x14,2 } followed by LF then tail. Both accepted24e9 compiler and current12 return false; a subject with an inserted semicolon returns true. Direct authored Perl regex gives the inverse. Generated handlers contain an added semicolon before the physical newline, changing match meaning without an error. Two subject controls and both native/fresh channels are retained in docs/checkpoints/type-deferred-indexed-writes/compatibility2.json.gz with raw_regex_oracle.pl and exact source rollback/restoration.
  Schedule: After signed17/last14/with16/grouped19, before policy20 and complete inventory1. Coordinate the distinct bootstrap .54.1/unescaped-brace and attached-tail .9 owners; do not silently promote their exclusions.
  Acceptance: Toolbox statement-boundary/source/pattern/value evidence identifies the exact producer. Preserve authored LF/CRLF, escapes, classes, delimiters and source spans; retain numeric slash calls and helper regex boundaries. Add independent match/mismatch and mutation controls, native/fresh recurrence and accurate legacy scope. No new portable raw-host capability is implied.
  Planned tier: focused for a bounded existing-source-fidelity correction; reclassify before governed policy/carrier or infrastructure movement.
  Claim verification: none: Scheduled intake only; actual observed source/oracle results remain part of12's bounded diagnosis, with no repair admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.20`
  Status: `pending` / policy update reconciliation
  Goal: Reconcile the read-only shared live-document containment guide updates with local adoption.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.21`
  Intake: October23 read-only external policy review found new general derived-state/local-doctrine/checker material in the partially adopted FSMGen guide (SHA256 8f77fa39c9bcb9cfc43166259a627a6ced64682030088400b727dccc5d674a53). README policy digest 882682fa1ace703ae68726b8532a4ad24fe2c8a271bae4e07b859bd197a621c9 and claim policy 9f99df25209c43afb74d77e348dd2d0cdb68ce96cf17a4f272ede8328f6046bd were checked; claim policy remains ADR0126's adopted source. No cross-repository write occurred.
  Schedule: After21 and before inventory1. Compare exact source/local adoption, own any applicable changes under bounded containment children, copy adopted rules locally, and verify doctrines/public explanation. External repositories stay read-only and no build may depend on them.
  Planned tier: `canonical`
  Claim verification: none: Policy intake and queue only; the implementation comparison and adoption evidence belong to this future leaf.

- ID: `TYPE-REFERENCE-BOOK.1.2.1`
  Status: `pending`
  Goal: Enumerate every supported operation and spelling from the retained authority population, grouped by actual type and syntax role.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.20`
  Planned tier: `focused`; reclassify before public/mechanical movement.
  Claim verification: none: Unactivated enumeration; declare actual source-bound proof before counting.
  Acceptance: Distinguish literals, constructors, operators, free helpers, receiver methods, aliases, callable invocation, generic and type-specific operations, plus private/retired recognition. Record signatures/arity, result/mutation/aliasing, callback/chain boundaries and backend limits; use public probes for uncertainty. Treat registered-name counts as one input, not completeness.

- ID: `TYPE-REFERENCE-BOOK.1.2.2`
  Status: `pending`
  Goal: Map the complete reconciled operation/spelling population to actual book coverage and proposed canonical per-type homes.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1`
  Planned tier: `focused`; reclassify before public/mechanical movement.
  Claim verification: none: Unactivated coverage mapping; declare complete source/book evidence before measurement.
  Acceptance: Retain exact current entries/anchors/includes/examples/backend qualifications for every inventory item, mark precise depth/navigation gaps, preserve old anchors and schedule bounded family work. Close .1.2 only after all inventory children agree; independent layout review .1.3 follows. No exhaustive public-reference coverage claim from an inventory closeout.

- ID: `TYPE-REFERENCE-BOOK.1.3`
  Status: `pending`
  Goal: Independently review the complete inventory and choose bounded canonical per-type sections and example requirements.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2`
  Planned tier: `focused`; determine any canonical trigger from actual layout/owner movement.
  Claim verification: none: Unactivated independent inventory/layout review; declare measured proof at activation.
  Acceptance: Reject distinguishing omissions/stale semantics, preserve existing anchors/includes and pressure controls, and schedule the type-specific implementation children. Inventory closeout does not admit complete reference coverage.

- ID: `TYPE-REFERENCE-BOOK.2`
  Status: `pending`
  Goal: Complete scalar/string reference and each supported associated operation.
  Dependencies: `TYPE-REFERENCE-BOOK.1`
  Acceptance: Add canonical navigation and per-operation signatures, arguments, conversions, results, empty/Unicode/missing/error cases, chaining/callback semantics and executable examples for every scalar/string inventory item. Preserve verified current behavior and existing anchors; split safely before implementation if needed.
  Planned tier: `focused`
  Claim verification: none: Future reference implementation; declare actual example/coverage proof at activation.

- ID: `TYPE-REFERENCE-BOOK.3`
  Status: `pending`
  Goal: Explain integer/real numeric behavior within the actual type model and every supported numeric operation.
  Dependencies: `TYPE-REFERENCE-BOOK.1`
  Acceptance: Resolve integer/real, scalar conversion, boolean/null and numeric validation distinctions from current contracts; document every inventoried constructor/operator/helper/method with results, precision/rounding/range/error boundaries where applicable and verified examples. State backend differences explicitly rather than inventing separate types.
  Planned tier: `focused`
  Claim verification: none: Future reference implementation; declare actual example/coverage proof at activation.

- ID: `TYPE-REFERENCE-BOOK.4`
  Status: `pending`
  Goal: Complete array reference across construction, access, mutation, pipelines and traversal.
  Dependencies: `TYPE-REFERENCE-BOOK.1`
  Acceptance: One navigable canonical array family covers every inventoried operation and alias, including updated independent mutation results, named receiver constraints, empty/non-array/error outcomes, order, chaining and callback behavior. Backfill individual worked examples rather than relying only on shared table examples; preserve existing pipeline and tree traversal contracts.
  Planned tier: `focused`
  Claim verification: none: Future reference implementation; declare actual example/coverage proof at activation.

- ID: `TYPE-REFERENCE-BOOK.5`
  Status: `pending`
  Goal: Complete hash reference across construction, lookup, mutation and traversal.
  Dependencies: `TYPE-REFERENCE-BOOK.1`
  Acceptance: Document every inventoried hash operation/alias with key/value arguments, missing-key behavior, returned values, order guarantees, mutation/aliasing and callable traversal semantics, supported forms/backend limits and individual verified examples. Preserve governed nested-write and map_leaves contracts.
  Planned tier: `focused`
  Claim verification: none: Future reference implementation; declare actual example/coverage proof at activation.

- ID: `TYPE-REFERENCE-BOOK.6`
  Status: `pending`
  Goal: Make codeblock values and all supported operations directly navigable and thoroughly documented.
  Dependencies: `TYPE-REFERENCE-BOOK.1`
  Acceptance: Canonical section covers literal/parameter forms, named and inline invocation, typed callback slots, result/return and dynamic-context behavior, mutation/composition and error cases established by inventory, with worked examples and exact backend limits. Distinguish invocation from receiver methods on a yielded typed value; list only actually supported codeblock operations.
  Planned tier: `focused`
  Claim verification: none: Future reference implementation; declare actual example/coverage proof at activation.

- ID: `TYPE-REFERENCE-BOOK.7`
  Status: `pending`
  Goal: Independently close complete per-type coverage and rendered navigation.
  Dependencies: `TYPE-REFERENCE-BOOK.2`, `TYPE-REFERENCE-BOOK.3`, `TYPE-REFERENCE-BOOK.4`, `TYPE-REFERENCE-BOOK.5`, `TYPE-REFERENCE-BOOK.6`
  Acceptance: Reconcile the entire retained inventory against canonical entries and runnable examples, verify old/new links and recursive includes, render and inspect all affected sections, and reject distinguishing omissions or stale semantics with retained controls before asserting exhaustive coverage. Update current book/status records and use canonical admission if the closeout moves public/mechanical contracts.
  Planned tier: Determine at activation from actual closeout scope.
  Claim verification: none: No coverage measurement yet; declare actual independent closeout proof before execution.

- ID: `TYPE-REFERENCE-BOOK.8`
  Status: `pending` / P3 continuity defect owned
  Goal: Reconcile the exact legacy documentation task-status contradictions encountered during intake.
  Reproduce: BOOK-DOCUMENTATION-SYNC metadata says done while its root node says active and all children/frontier are done. DOC-DRIFT-SYNC.2 says pending despite its dated Done verification and done frontier/tree-complete assertion. DOC-CODEBASE-ALIGNMENT.4/.5 say pending despite completed verification and done frontier/tree-complete assertion; several commit fields still say pending. BOOK-DOCUMENTATION-SYNC also has a four-cell Commit Log delimiter under a three-cell header, impairing table rendering.
  Impact: Contradictory task definitions can misdirect resumption or falsely reopen/close historical work; no runtime defect is inferred.
  Owned paths: `docs/tasks/BOOK-DOCUMENTATION-SYNC.md`, `docs/tasks/DOC-DRIFT-SYNC.md`, `docs/tasks/DOC-CODEBASE-ALIGNMENT.md`, exact related index/history projections and this owner.
  Schedule: Repair during the first documentation phase after the active private callback lane, alongside the reference inventory; not an active-task pivot.
  Acceptance: Audit only relevant Git subjects/diffs and dated verification records, reconcile root/leaf/frontier/commit metadata to actual accepted work, preserve every old result and historical claim, check current definitions and ordinary task/memory doctrines, and commit separately. Do not treat a stale pending field as proof that implementation is missing.
  Planned tier: `focused`
  Claim verification: none: Qualitative contradiction intake only; any new historical census or measured repair proof is declared before publication.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `TYPE-REFERENCE-BOOK.1.2.17.1` | `pending` | Freeze new signed authority/checker with historical-v1 boundary. |
| 2 | `TYPE-REFERENCE-BOOK.1.2.17.2` | `pending` | Perl ordinary/deferred implementation. |
| 3 | `TYPE-REFERENCE-BOOK.1.2.17.3` | `pending` | Rust native/generated implementation. |
| 4 | `TYPE-REFERENCE-BOOK.1.2.17.4` | `pending` | Dart native/generated implementation. |
| 5 | `TYPE-REFERENCE-BOOK.1.2.17.5` | `pending` | Julia native/generated implementation. |
| 6 | `TYPE-REFERENCE-BOOK.1.2.17.6` | `pending` | Shared Lua; independently verify PUC and LuaJIT. |
| 7 | `TYPE-REFERENCE-BOOK.1.2.17.7` | `pending` | Recurring compatibility/public admission after all backends. |
| 8 | `TYPE-REFERENCE-BOOK.1.2.14` | `pending` | Deferred last after signed17. |
| 9 | `TYPE-REFERENCE-BOOK.1.2.16` | `pending` | Deferred scoped with after14. |
| 10 | `TYPE-REFERENCE-BOOK.1.2.19` | `pending` | Grouped indexed assignment value after16. |
| 11 | `TYPE-REFERENCE-BOOK.1.2.21` | `pending` | Raw assigned-regex payload fidelity after19. |
| 12 | `TYPE-REFERENCE-BOOK.1.2.20` | `pending` | Shared containment policy update reconciliation. |
| 13 | `TYPE-REFERENCE-BOOK.1.2.1` | `pending` | Complete supported operations/spellings. |
| 14 | `TYPE-REFERENCE-BOOK.1.2.2` | `pending` | Map every item to actual book coverage. |
| 15 | `TYPE-REFERENCE-BOOK.1.3` | `pending` | Independent complete inventory/layout review. |
| 16 | `TYPE-REFERENCE-BOOK.8` | `pending` | Relevant legacy metadata repair. |
| 17 | `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.13` | `pending` | Deferred literal-rendering question. |
| 18 | `TYPE-REFERENCE-BOOK.2` | `pending` | Inventory-backed family references and closeout. |

## Decisions

- `2026-10-10`: DBIQNP authorizes discussion without pivot. Record and schedule the confirmed qualitative gap;
  do not claim unsupported missing-method counts or start reference restructuring during the current AST work.
- `2026-10-10`: Inventory actual language contracts before choosing the final type taxonomy or section layout.
  Historical book closeouts remain dated evidence; this tree owns the newly stated per-type completeness criterion.

## Open Questions

The inventory determines exact operation population, canonical section layout and any backend distinctions.
These are evidence questions owned by `.1`, not blockers requiring a director decision now.

## Blockers

No director input required. Signed selectors17 follows the clean12 boundary, then14/16/19/raw-regex21/policy20 before inventory. No dirty pivot.

## Verification Log

- `2026-10-23` — `.1.2.12`: 84 public cases/54 accepted-source RED/30 controls; 16 source-fault9 controls plus the actual private-consumer inverse; 22 suites/3098 top-level TAP; private 296 rows/26 deliberate consumer changes; book 89 inputs/4 executed examples with heading/prose/URL denials; three identity denials and 3 required-fixture omission/bypass/restoration controls; exact canonical receipt governs admission.

- `2026-10-21` — `.1.2.10`:232 fixed cases/107 accepted RED/125 controls;8 restored source faults;14/1950 TAP;history680;book89/5 and actual heading RED; whole accepted13 custody; exact finite history0137 and artifact controls; canonical admission mandatory.

- `2026-10-21` — `.1.2.13`:116/47 RED/six faults;14/1950/history650;16 flag routes;9/72 direct;book89/5. Source-closed gateway and exact canonical receipt govern landing.

- `2026-10-20` — `.1.2.5`: See the complete numeric checkpoint above.

- `2026-10-20` — `.1.2.3`: Evaluated-list operands retain earlier values across later effects and preserve explicit splices. Accepted19 RED/four controls becomes23 native/fresh-generated GREEN; seven suites use277 declared test/data/bin inputs. Six emitter faults reject19/14/2/1/1/1 and restore. Focused52 preserves982 skips in1651 supplied files; ordinary all1035 passes separately. Observer129 RED/one null, missing-selector RED and restoration remain effective. Twelve recurring suites retain4998 assertions plus3 value/ABI goldens:5001 quiet PASS; mapper bypass fails198 and restores. Three exact owner/prior/current scanner admissions retain original registrations;28 denials and actual check-removal faults9/6/3 pass. Two oversized streams become31 bounded chunks with exact bytes/modes and retained-review use in explicit original scanner context;500733803 duplicate bytes are removed with residue0. Historical metadata has4 denials/actual guard RED1; current reads stay unchanged. Whole837/full130737 and actual readonly0 survive; one physical input becomes an index, preserving all original logical inputs. Fresh845/full130759 binds the complete4178-input closure including4163 scanner candidates, with no oversized files. Graph1487/1349/10462 preserves897 entries/248 fields at8388584 Knowledge bytes; book89/heading denial and whole388/full68814/2706 replay pass. Rejected/preparation epochs retain their original limits and bytes. Scoped-with4, numeric5 and generated-drop6 remain owned; no exhaustive type, cross-backend or private/parent admission. Exact staged canonical receipt and normal hooks govern landing; derive actual admission identity from Git.

- `2026-10-19` — `.1.2.0`: Authority/model .1.2.0 retains1300 owned inputs;14 descriptor/Get/generated cases include70 neutral scalar fields, and11 distinguishing cases isolate two owned P1 Perl defects. Actual private promotion has report0/strict RED/exact restoration. Current Knowledge1487/1349/10455, all897 list items/248 fields and8387566 bytes fit unchanged limits; complete89-input book and changed-heading control pass. Whole original396/full68960 replays with exact channels and bytes/modes unchanged. Only that accepted claim is frozen at real cf4dceccd; first no-write frontmatter writer failure and separate correction remain retained. No runtime, contract, gate, budget, complete operation inventory, cross-backend or private/parent admission. P1 scalar-evaluation .1.2.3 then scoped-with .1.2.4 precede complete enumeration .1.2.1.

- `2026-10-19` — `.1.1`: TYPE-REFERENCE-BOOK.1.1 corrects the retired tagged-return recipes: exact historical m/ma callbacks splice groups, while current copy recipes have explicit snapshot/identity limits. Seventeen fixed parser/generated payloads, five alternate native-shape REDs and four module-identity REDs pass. Two Toolbox return examples and the complete89-input book/affected-page links pass; the actual worked source matches native execution. Whole prior208/full39111 and first uncommitted355/full60395 records, actual baselines and all inputs remain recoverable. Exact isolated original reader fails its absolute INC predicate; the distinct corrected predicate/full supplied context restores the whole original claim with identical channels. Redundant public42/40 references and executable negative capture sources are resolved without changing gates: exact original producers remain archived data with guarded stubs. Current Knowledge1487/1349/10455, all897 entries/248 fields, 8386601 bytes and map21249 fit unchanged controls. Current readonly publication binds396 inputs/full68960. No runtime, contract, budget, full alias/deep-copy, exhaustive type inventory or private/parent admission changes. Clean activation of .1.2 inventory follows; .8 legacy status repair and deferred metadata QA .13 remain owned.

- `2026-10-10`: Intake reads current SUMMARY, value/container helper reference, Values/codeblock prose, fluent and
  declaration chapters, helper catalog and existing book task records. Structure and sampled entries establish a
  qualitative gap only. Exact legacy status contradictions are recorded above; no runtime or full coverage proof.

## Commit Log

CLI17.8 subject: `TYPE-REFERENCE-BOOK.1.2.17.8 - report context-only Perl CLI runtime failures`; derive accepted identity from Git.

Signed intake17.0 subject: `TYPE-REFERENCE-BOOK.1.2.17.0 - record signed-index baseline and CLI repair priority`; derive accepted identity from Git.

Deferred-write12 subject: `TYPE-REFERENCE-BOOK.1.2.12 - execute deferred indexed writes atomically`; derive accepted identity from Git.

Count/first10 subject: `TYPE-REFERENCE-BOOK.1.2.10 - execute callable count and first`; derive its accepted identity from Git.

Kind13 subject: `TYPE-REFERENCE-BOOK.1.2.13 - preserve sorted scalar kinds`; derive its accepted identity from Git.

Intake landed under `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2`. TYPE-REFERENCE-BOOK.1.1 is the first completed child; derive its accepted commit by subject from Git. Authority/model .1.2.0 is complete; derive its accepted commit by subject. P1 .1.2.3 completes the evaluated-value repair; derive its accepted commit by subject. Scoped-with .1.2.4 completes its finite repair; derive its accepted commit by subject. Numeric .1.2.5 completes scalar calls/snapshots; derive its commit by subject.

## Changelog

- `2026-10-23`: Complete P1 CLI17.8 with both error channels, permanent source inverse/restoration and accurate current book; preserve original control qualification and accepted intake. Signed contract17.1 is next.

- `2026-10-23`: Complete bounded signed intake17.0; retain diagnostic/oracle/source/product/book proof and qualify instrument mistakes. P1 Perl CLI17.8 precedes signed contract17.1/backend/admission children.

- `2026-10-23`: Complete bounded deferred-write12, preserve caller presence and standalone compatibility; signed17 is next, then14/16/19/raw-regex21/policy20 before inventory.

- `2026-10-10`: Queue inventory, five type-family reference slices, independent coverage closeout and the exact
  encountered legacy metadata repair without changing the active private callback frontier.

- `2026-10-19`: Clean accepted metadata handoff activates .1.1; split stale guidance, full inventory and independent layout review into separately committed leaves. Queue the unconfirmed scalar-format question without redirecting reference work.

- `2026-10-19`: Complete .1.1 with corrected historical flat groups, bounded snapshot guidance, preserved claims/producers, current rendered book and focused proof; hand off cleanly to .1.2.

- `2026-10-19`: Activate .1.2 from clean cf4dceccd; split authority/type model, complete operation/spelling enumeration and book mapping into independently committed children. Current .1.2.0 owns the pre-measurement source population and preservation.

- `2026-10-19`: Complete authority/model prerequisite; schedule both source-isolated P1 repairs before exhaustive operation enumeration.

- `2026-10-20`: Complete scoped callable .1.2.4 with typed errors, frame restoration and authored spans; numeric .1.2.5 is next.
