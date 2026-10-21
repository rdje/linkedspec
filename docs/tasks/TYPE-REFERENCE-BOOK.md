# TYPE-REFERENCE-BOOK: Complete navigable per-type language reference

## Metadata

- Tree ID: `TYPE-REFERENCE-BOOK`
- Status: `active` / next deferred count/first .1.2.10; before enumeration
- Roadmap lane: `.spec language documentation / complete type and method reference`
- Created: `2026-10-10`
- Last updated: `2026-10-21`
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
  Children: `TYPE-REFERENCE-BOOK.1.2.0`, `TYPE-REFERENCE-BOOK.1.2.3`, `TYPE-REFERENCE-BOOK.1.2.4`, `TYPE-REFERENCE-BOOK.1.2.5`, `TYPE-REFERENCE-BOOK.1.2.6`, `TYPE-REFERENCE-BOOK.1.2.7`, `TYPE-REFERENCE-BOOK.1.2.9`, `TYPE-REFERENCE-BOOK.1.2.13`, `TYPE-REFERENCE-BOOK.1.2.10`, `TYPE-REFERENCE-BOOK.1.2.11`, `TYPE-REFERENCE-BOOK.1.2.12`, `TYPE-REFERENCE-BOOK.1.2.1`, `TYPE-REFERENCE-BOOK.1.2.2`.
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
  Status: `pending` / P2 defect owned
  Goal: Execute deferred count/first array receiver helpers.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.13`
  Reproduce/impact: Final9 separately confirms ordinary count2/first1 and deferred unknown_helper:count/first after sorted/take succeeds. followup-confirmation.json.gz and its full context retain all four actual routes; the original baseline stopped at sorted.
  Schedule: After13, before11/inventory. Fix existing count/first forms with shape/empty/kind/terminal/effect controls.
  Evidence: docs/checkpoints/type-array-pipelines/findings.md; whole source epochs remain retained.
  Planned tier: `canonical`
  Claim verification: none: Pending repair; actual intake diagnosis is bound to claim9.

- ID: `TYPE-REFERENCE-BOOK.1.2.11`
  Status: `pending` / P2 defect owned
  Goal: Repair registered sorted receiver pipelines and ordinary length continuation.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.10`
  Reproduce/impact: Registered fn select_items marks sorted unresolved, returning[] ordinarily and user_function_body_unsupported from a codeblock. Ordinary sorted().take(2).length() stays raw and calls an undefined host sorted; deferred length works. candidate1/inspection retain sources.
  Schedule: After10, before12/inventory. Use public lowering to identify both bounded owners; split at clean activation if necessary.
  Evidence: docs/checkpoints/type-array-pipelines/findings.md; whole source epochs remain retained.
  Planned tier: `canonical`
  Claim verification: none: Pending repair; actual intake diagnosis is bound to claim9.

- ID: `TYPE-REFERENCE-BOOK.1.2.12`
  Status: `pending` / P2 defect owned
  Goal: Execute typed indexed writes inside deferred codeblocks.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.11`
  Reproduce/impact: chosen[0]="changed" in a callable body raises unsupported_codeblock_actionir:assign_nested_access; ordinary caller-side indexed writes succeed. candidate2 retains the typed failures.
  Schedule: After11, before inventory. Fix the typed write family with key validation, copy/alias/caller-slot/effect/malformed-record controls.
  Evidence: docs/checkpoints/type-array-pipelines/findings.md; whole source epochs remain retained.
  Planned tier: `canonical`
  Claim verification: none: Pending repair; actual intake diagnosis is bound to claim9.

- ID: `TYPE-REFERENCE-BOOK.1.2.1`
  Status: `pending`
  Goal: Enumerate every supported operation and spelling from the retained authority population, grouped by actual type and syntax role.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.12`
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
| 1 | `TYPE-REFERENCE-BOOK.1.2.3` | `done` |23 GREEN/19 RED; focused52, observer129 RED/restoration; canonical landing boundary. |
| 2 | `TYPE-REFERENCE-BOOK.1.2.4` | `done` | Scoped callable/frame/span repair; finite proof and canonical landing boundary. |
| 3 | `TYPE-REFERENCE-BOOK.1.2.5` | `done` | Scalar numeric dispatch/snapshots;6/7 next. |
| 4 | `TYPE-REFERENCE-BOOK.1.2.6` | `done` | Quiet generated drop, splices/key snapshots;7 next. |
| 5 | `TYPE-REFERENCE-BOOK.1.2.7` | `done` | Bounded availability/portable evidence; owned pipeline9 next. |
| 6 | `TYPE-REFERENCE-BOOK.1.2.9` | `done` | Callable sorted/take; bounded proof/typed argument guard; kind13 next. |
| 7 | `TYPE-REFERENCE-BOOK.1.2.13` | `done` |116 values/47 RED/six faults/14-1950/book89-5; canonical admission mandatory. |
| 8 | `TYPE-REFERENCE-BOOK.1.2.10` | `pending` | Deferred count/first after13. |
| 9 | `TYPE-REFERENCE-BOOK.1.2.11` | `pending` | Registered sorted/ordinary length after10. |
| 10 | `TYPE-REFERENCE-BOOK.1.2.12` | `pending` | Deferred indexed writes before inventory. |
| 11 | `TYPE-REFERENCE-BOOK.1.2.1` | `pending` | Enumerate complete supported operations/spellings after the owned P1 repairs. |
| 12 | `TYPE-REFERENCE-BOOK.1.2.2` | `pending` | Map every reconciled item to actual book coverage. |
| 13 | `TYPE-REFERENCE-BOOK.1.3` | `pending` | Independently review the complete inventory and bounded layout plan. |
| 14 | `TYPE-REFERENCE-BOOK.8` | `pending` | Reconcile owned legacy metadata contradictions from exact history. |
| 15 | `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.13` | `pending` | Deferred unconfirmed literal-rendering question after Type .1/.8. |
| 16 | `TYPE-REFERENCE-BOOK.2` | `pending` | Inventory-backed type-family references and independent .7 closeout follow. |

## Decisions

- `2026-10-10`: DBIQNP authorizes discussion without pivot. Record and schedule the confirmed qualitative gap;
  do not claim unsupported missing-method counts or start reference restructuring during the current AST work.
- `2026-10-10`: Inventory actual language contracts before choosing the final type taxonomy or section layout.
  Historical book closeouts remain dated evidence; this tree owns the newly stated per-type completeness criterion.

## Open Questions

The inventory determines exact operation population, canonical section layout and any backend distinctions.
These are evidence questions owned by `.1`, not blockers requiring a director decision now.

## Blockers

No director input required. Kind13 selected proof is complete; exact canonical/normal landing is mandatory. Activate10 only after clean handoff; then11/12 before inventory1. No dirty pivot.

## Verification Log

- `2026-10-21` — `.1.2.13`:116/47 RED/six faults;14/1950/history650;16 flag routes;9/72 direct;book89/5. Source-closed gateway and exact canonical receipt govern landing.

- `2026-10-20` — `.1.2.5`: See the complete numeric checkpoint above.

- `2026-10-20` — `.1.2.3`: Evaluated-list operands retain earlier values across later effects and preserve explicit splices. Accepted19 RED/four controls becomes23 native/fresh-generated GREEN; seven suites use277 declared test/data/bin inputs. Six emitter faults reject19/14/2/1/1/1 and restore. Focused52 preserves982 skips in1651 supplied files; ordinary all1035 passes separately. Observer129 RED/one null, missing-selector RED and restoration remain effective. Twelve recurring suites retain4998 assertions plus3 value/ABI goldens:5001 quiet PASS; mapper bypass fails198 and restores. Three exact owner/prior/current scanner admissions retain original registrations;28 denials and actual check-removal faults9/6/3 pass. Two oversized streams become31 bounded chunks with exact bytes/modes and retained-review use in explicit original scanner context;500733803 duplicate bytes are removed with residue0. Historical metadata has4 denials/actual guard RED1; current reads stay unchanged. Whole837/full130737 and actual readonly0 survive; one physical input becomes an index, preserving all original logical inputs. Fresh845/full130759 binds the complete4178-input closure including4163 scanner candidates, with no oversized files. Graph1487/1349/10462 preserves897 entries/248 fields at8388584 Knowledge bytes; book89/heading denial and whole388/full68814/2706 replay pass. Rejected/preparation epochs retain their original limits and bytes. Scoped-with4, numeric5 and generated-drop6 remain owned; no exhaustive type, cross-backend or private/parent admission. Exact staged canonical receipt and normal hooks govern landing; derive actual admission identity from Git.

- `2026-10-19` — `.1.2.0`: Authority/model .1.2.0 retains1300 owned inputs;14 descriptor/Get/generated cases include70 neutral scalar fields, and11 distinguishing cases isolate two owned P1 Perl defects. Actual private promotion has report0/strict RED/exact restoration. Current Knowledge1487/1349/10455, all897 list items/248 fields and8387566 bytes fit unchanged limits; complete89-input book and changed-heading control pass. Whole original396/full68960 replays with exact channels and bytes/modes unchanged. Only that accepted claim is frozen at real cf4dceccd; first no-write frontmatter writer failure and separate correction remain retained. No runtime, contract, gate, budget, complete operation inventory, cross-backend or private/parent admission. P1 scalar-evaluation .1.2.3 then scoped-with .1.2.4 precede complete enumeration .1.2.1.

- `2026-10-19` — `.1.1`: TYPE-REFERENCE-BOOK.1.1 corrects the retired tagged-return recipes: exact historical m/ma callbacks splice groups, while current copy recipes have explicit snapshot/identity limits. Seventeen fixed parser/generated payloads, five alternate native-shape REDs and four module-identity REDs pass. Two Toolbox return examples and the complete89-input book/affected-page links pass; the actual worked source matches native execution. Whole prior208/full39111 and first uncommitted355/full60395 records, actual baselines and all inputs remain recoverable. Exact isolated original reader fails its absolute INC predicate; the distinct corrected predicate/full supplied context restores the whole original claim with identical channels. Redundant public42/40 references and executable negative capture sources are resolved without changing gates: exact original producers remain archived data with guarded stubs. Current Knowledge1487/1349/10455, all897 entries/248 fields, 8386601 bytes and map21249 fit unchanged controls. Current readonly publication binds396 inputs/full68960. No runtime, contract, budget, full alias/deep-copy, exhaustive type inventory or private/parent admission changes. Clean activation of .1.2 inventory follows; .8 legacy status repair and deferred metadata QA .13 remain owned.

- `2026-10-10`: Intake reads current SUMMARY, value/container helper reference, Values/codeblock prose, fluent and
  declaration chapters, helper catalog and existing book task records. Structure and sampled entries establish a
  qualitative gap only. Exact legacy status contradictions are recorded above; no runtime or full coverage proof.

## Commit Log

Kind13 subject: `TYPE-REFERENCE-BOOK.1.2.13 - preserve sorted scalar kinds`; derive its accepted identity from Git.

Intake landed under `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2`. TYPE-REFERENCE-BOOK.1.1 is the first completed child; derive its accepted commit by subject from Git. Authority/model .1.2.0 is complete; derive its accepted commit by subject. P1 .1.2.3 completes the evaluated-value repair; derive its accepted commit by subject. Scoped-with .1.2.4 completes its finite repair; derive its accepted commit by subject. Numeric .1.2.5 completes scalar calls/snapshots; derive its commit by subject.

## Changelog

- `2026-10-10`: Queue inventory, five type-family reference slices, independent coverage closeout and the exact
  encountered legacy metadata repair without changing the active private callback frontier.

- `2026-10-19`: Clean accepted metadata handoff activates .1.1; split stale guidance, full inventory and independent layout review into separately committed leaves. Queue the unconfirmed scalar-format question without redirecting reference work.

- `2026-10-19`: Complete .1.1 with corrected historical flat groups, bounded snapshot guidance, preserved claims/producers, current rendered book and focused proof; hand off cleanly to .1.2.

- `2026-10-19`: Activate .1.2 from clean cf4dceccd; split authority/type model, complete operation/spelling enumeration and book mapping into independently committed children. Current .1.2.0 owns the pre-measurement source population and preservation.

- `2026-10-19`: Complete authority/model prerequisite; schedule both source-isolated P1 repairs before exhaustive operation enumeration.

- `2026-10-20`: Complete scoped callable .1.2.4 with typed errors, frame restoration and authored spans; numeric .1.2.5 is next.
