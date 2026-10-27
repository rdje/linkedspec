# TYPE-REFERENCE-BOOK: Complete navigable per-type language reference

## Metadata

- Tree ID: `TYPE-REFERENCE-BOOK`
- Status: `active` / joined String result assessment after bounded numeric result rollout
- Roadmap lane: `.spec language documentation / complete type and method reference`
- Created: `2026-10-10`
- Last updated: `2026-10-27`
- Owner: LinkedSpec repo-local PNT
- Priority: P1 discovered runtime repairs; P2 documentation completeness; P3 legacy status repair
- Intake owner: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2`
- Schedule: First documentation phase after the active private factory/callback implementation lane; before claiming the book supplies an exhaustive per-type reference.

## Goal

Give readers one clearly navigable canonical section for every supported value/type family, and a thorough,
example-rich entry for every currently supported operation. Inventory actual contracts and supported spellings
before deciding headings, moving text or asserting completeness. The bounded callback handoff is accepted at 1a8b202018a387c87425442375f53c3ee5e820d4; its stale-recipe prerequisite is complete; full inventory .1.2 is next.

Director clarification (October24, DBIQNP): every supported type needs a comprehensive, coherent fluent method
family, including chains that change type. The motivating journey is string -> regex split -> array of strings
-> available array operations -> selected entry -> string operations. Inventory must identify and own missing
method families or broken transitions; documenting only today's registered names cannot establish completeness.
This acceptance work belongs to .1.2.23; the precise current feature selection is recorded in the frontier below.

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
- Every supported type has an assessed fluent method family, and an explicit result-type transition matrix
  covers cross-type chaining. Missing useful operations/transitions are owned and resolved before family closeout;
  legitimate semantic exclusions are explained rather than hidden by an implemented-name-only inventory.
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
  Children: `TYPE-REFERENCE-BOOK.1.2.0`, `TYPE-REFERENCE-BOOK.1.2.3`, `TYPE-REFERENCE-BOOK.1.2.4`, `TYPE-REFERENCE-BOOK.1.2.5`, `TYPE-REFERENCE-BOOK.1.2.6`, `TYPE-REFERENCE-BOOK.1.2.7`, `TYPE-REFERENCE-BOOK.1.2.9`, `TYPE-REFERENCE-BOOK.1.2.13`, `TYPE-REFERENCE-BOOK.1.2.10`, `TYPE-REFERENCE-BOOK.1.2.11`, `TYPE-REFERENCE-BOOK.1.2.12`, `TYPE-REFERENCE-BOOK.1.2.17`, `TYPE-REFERENCE-BOOK.1.2.22`, `TYPE-REFERENCE-BOOK.1.2.14`, `TYPE-REFERENCE-BOOK.1.2.16`, `TYPE-REFERENCE-BOOK.1.2.19`, `TYPE-REFERENCE-BOOK.1.2.21`, `TYPE-REFERENCE-BOOK.1.2.20`, `TYPE-REFERENCE-BOOK.1.2.1`, `TYPE-REFERENCE-BOOK.1.2.23`, `TYPE-REFERENCE-BOOK.1.2.2`.
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
  Status: `completed`
  Goal: Execute deferred last array selectors.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.6`
  Activation: Clean0a9d3a560c2bd07391777d29bf37cec5734c8bf0 after Lua17.6, post-pointer PASS and brief0. Follow compile/quick targeted check/commit/next-feature policy; broad validation stays deferred.
  Owned paths: perl/LinkedSpec/CodeblockRuntime.pm; t/deferred_last_contract.t and its callable_codeblock_literal_contract.t registration; current count/first/last book and existing terse type Knowledge; normal roadmap/task/live continuity.
  Verification tier: `focused`
  Focused checks: perl module syntax and one small public LinkedSpec::Get/native/emitted last regression, covering value/empty/kind, free/receiver shape, terminal effects and copied nested results. Build changed book and run fast continuity checks. No full Phase0/package/corpus/proof matrix or global registry scan.
  Canonical trigger: None for this implementation leaf under director's explicit feature-completion policy; exhaustive verification is deferred.
  Claim verification: none: Deterministic helper implementation/docs and a quick regression only; no quantified corpus, benchmark or exhaustive admission measurement is published.
  Reproduce/impact: Canonical public Top:: I probe returns ordinary last/receiver values, while the deferred probe records typed unknown_helper with name last. Source dispatch currently enrolls count/first only. The initial multiline E probe did not execute the intended action and supplies no feature evidence.
  Acceptance: Match existing ordinary free/receiver arity, array/nonarray/empty results, stored-value kinds and terminal/effect/copy behavior. Quick syntax/native/emitted checks pass; comprehensive verification stays deferred.

  Completion: Deferred free/receiver dispatch now enrolls last alongside count/first. The shared selector returns the stored tail value unchanged; receiver last shares the existing arity/terminal preflight so rejected shapes skip effects. Perl syntax and the standalone native/fresh-emitted regression pass. The existing callable suite includes this focused test; broad suite execution remains deferred.
  Focused command: `bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/deferred_last_contract.t`.
  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get on canonical Top:: I reports unknown_helper:last in the deferred route; ordinary last/receiver return the final stored value.
  - [x] **ROOT CAUSE (WHY + WHERE)** — perl/LinkedSpec/CodeblockRuntime.pm::_eval_call and _apply_methods enroll count/first only; the element-selection fallback chooses index0.
  - [x] **FIX** — Enroll last in free/receiver dispatch and terminal preflight; choose index-1 through the shared selector.
  - [x] **ADDRESSED (verified)** — Module syntax and the small public native/fresh-emitted regression pass.
  - [x] **NO REGRESSION** — Targeted empty/kind/copy/arity/effect controls pass; full Phase0/compatibility matrices remain explicitly deferred.
  - [x] **LOCKSTEP** — Current book/examples, canonical method card/map, roadmaps/task/live handoff agree; next feature is deferred with16.
  Continuity: Required engineering-notes rollover preserves the committed suffix in docs/history/development-notes/segment-4958-e8e03c2de937.md plus its manifest row; bounded history checks pass.
  Commit: `TYPE-REFERENCE-BOOK.1.2.14 - execute last inside deferred Perl codeblocks`.

- ID: `TYPE-REFERENCE-BOOK.1.2.17`
  Status: `active` / six-runtime implementation complete; broad admission17.7 deferred
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
  Status: `completed` / neutral target, source custody and bounded storage enrollment
  Goal: Freeze the signed neutral contract/checker and historical-v1 transition.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.0`, `TYPE-REFERENCE-BOOK.1.2.17.8`
  Owned paths: .gitignore (two exact regenerated recovery aliases); tools/test_tool_project_data_storage.sh; docs/knowledge/tool-project-data-ssd-storage.md; docs/linkedspec-book/src/development/local-ci-and-regression.md; capability_conformance/signed_array_selector_contract.json; tools/check_signed_array_selector_contract.py; docs/checkpoints/signed-array-contract/; canonical write and routing-pressure Knowledge cards, pending-extension book section and normal task/roadmap/continuity; docs/checkpoints/signed-array-contract-admission/ retains the canonical format qualification and bounded recovery chunks. Frozen v1 authorities/checkers/history and all runtime code remain unchanged.
  Verification tier: `canonical`
  Focused checks: Actual storage census/direct FAIL-PASS and signed-checker hostile-root wrapper execution; Source-bound neutral arithmetic/read/write/diagnostic/effect/identity/copy cases; full historical-v1 compatibility; actual finite oracle/source controls and input/scope denials; complete affected book render; memory/history/Knowledge/whitespace and all normal doctrines.
  Canonical trigger: Separate cross-backend target contract/checker; exact staged canonical receipt before landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.1.json`
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.

  Activation: Clean 9dd5e35550036c5093a35986a2b3149f8ea79f9a after CLI17.8 canonical/all10 hooks/post-pointer/brief0. Whole prior publication/manifest/claim and actual clean readonly0 plus independently Git-verified images precede first writes; complete checked-live census has no planned-path intersections. No runtime or signed capability admission.

  Completion: 12 arithmetic/14 read/33 write targets,30 exact historical write outcomes,122 fixture denials; five actual physical source faults with healthy/restored controls;book91/three source denials;input3/scope2 bypass/restoration; no backend admission. Read-only: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-contract/publish.py. New underflow code/fields, conditional-negative structural ordering and authored-value path prefixes are frozen before backend writes. Missing negative targets keep the v1 diagnostic; exact historical authorities/checker remain unchanged. Three unpublished builder/capture/document mistakes retain whole original source and distinct exact-source reproduction channels without product RED credit. Whole prior CLI outputs/actual clean readonly0 and72 Git-verified images precede writes; no live intersections. Signed target facts/questions are consolidated into the existing canonical write card; the routing card records README membership. Derived map and target teaching stay within unchanged collection limits. Exact staged canonical CI and normal hooks govern landing.
  Acceptance checklist:
  - [x] **REPRODUCE / ISSUE** — Dependency intake17.0 retains LinkedSpec::Get/return_descriptor/dump_parser_source/native/fresh differences before runtime edits; this leaf defines their separately owned neutral target.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Frozen write-v1 rejects every negative selector; the separate signed model qualifies existing array positions during the post-expression structural walk while preserving all30 old outcomes.
  - [x] **FIX** — Freeze a separate authority/checker with exact underflow/invalid/kind/gap/guard boundaries, arithmetic, read purity, effects and detachment. Runtime implementation remains17.2–6; portable admission remains17.7.
  - [x] **ADDRESSED (verified)** — Five actual altered physical model sources exit1 at independent authored controls,122 fixture mutations reject, three changed book sources render but fail, and input3/scope2 controls distinguish actual bypass/restoration.
  - [x] **NO REGRESSION** — All frozen-v1 outcome tuples and byte/digest identities agree; old write/map neutral checkers, current public-surface and capability consumers pass. Exact canonical receipt and normal hooks govern acceptance.
  - [x] **LOCKSTEP** — Explicit target-only book table/status/snapshot teaching, canonical Knowledge card/map, source-bound claim, roadmap/index/task/live pointer agree. No backend or generated support is inferred.
  Commit: `TYPE-REFERENCE-BOOK.1.2.17.1 - freeze signed array selector target contract`

  Canonical format qualification: The first exact staged attempt reports TASK-ACCEPTANCE because its checked LOCKSTEP line describes rollout with the forbidden literal. The canonical task-acceptance-evidence-gate-boundary card already documents this whole-file predicate. Retain the complete original staged binary diff, task/rule/card/producer and actual direct FAIL before wording repair; owned canonical job terminates143 with no PASS credit. Clarify only that checked line as target-only teaching, preserve open backend statuses, and observe the unchanged direct checker PASS. The neutral40-input publication stays live/unchanged before and after; final exact canonical candidate is separate. Evidence: docs/checkpoints/signed-array-contract-admission/.

  Knowledge containment: Canonical attempt2 and the unchanged direct routing checker reject knowledge_cards1351/1350 because the new card adds one file and README also counts. Preserve the complete candidate, all original card bytes/questions, full census and actual failure before edits. Merge all four signed questions/facts into the canonical write card, route seven repetitive historical header rows to accepted Git/whole before image, document collection membership in the existing routing card and regenerate the map. The first containment actor rejects the generator's normal stderr success notice after writing the correct map; a distinct captured idempotent run and source-defined notice qualify that wrapper mistake, without original-channel credit. Actual unchanged routing checker PASS at1350 files; registry/caps and neutral40-input publication remain unchanged. Attempt2 terminates143 with no canonical PASS credit. Evidence: docs/checkpoints/signed-array-contract-admission/knowledge-before.json.gz, knowledge-generation.json.gz and knowledge-result.json.gz.

  Owned custody issue / fix now before landing: artifact-controls-inputs records review.py SHA ea8c35069e44e70b25ca2485a61a75ff311fc46930eca272c96da0d8b1ed567d, but the later retained reader is0cdbc550a60c153ee0128d81d64aef508b31b97c0cd9f95d3b7106c1362f6240. The publisher imports review during the original validator runs. Removing the subsequently added artifact_detail helper/call recovers the exact recorded earlier bytes. Retain that epoch, all imported source modules and the actual recovery/replay producers; reject the later epoch by identity even when its unused added functions leave all control outcomes identical. Whole original40-input publication and actual readonly0 precede changes; canonical attempt3 is deliberately terminated143 without final PASS credit. No authority/model/runtime change or retargeting of old observations. This current leaf owns closure before the next staged canonical run.

  Custody closure: Retain the exact recorded pre-artifact_detail reader (SHA ea8c35069e44e70b25ca2485a61a75ff311fc46930eca272c96da0d8b1ed567d), all four project-source modules, actual recovery/replay producers and complete original40-input state. Both module epochs reproduce20 original validator outcomes each (40 exact rc/stdout/stderr comparisons), while the source-identity oracle rejects the later epoch and restores the original. New default source/custody/floor checks and unchanged publisher pass with48 bounded inputs; old cases, targets, book/model/source-fault and validator observations remain unchanged. Original publication/manifest/claim copies are explicitly unpublished raw history, not retroactively accepted Git. Exact canonical candidate must be rerun after this evidence repair; no final credit from interrupted attempt3. Read-only: docs/checkpoints/signed-array-contract/import_epoch.py and the default publisher. Independent admission reader also verifies the original40-input archive and source reconstruction.

  Owned storage integration defect / fix now: Canonical4 and a distinct direct run reject the exact Python-entrypoint census42/43 in tools/test_tool_project_data_storage.sh. The new signed checker is the sole added entrypoint; existing temporary-owner membership is unchanged. This blocks canonical landing. Retain the complete failed staged candidate, actual producer/source populations, log and direct failure before enrolling it in the census and hostile-root managed-wrapper controls. Evidence: docs/checkpoints/signed-array-contract-admission/storage-before.json.gz. No runtime or neutral authority change and no canonical PASS credit.

  Storage integration closure: The actual unchanged direct oracle rejects42/43; independently accepted9dd5e3555 source bytes identify42 old entrypoints and the signed checker as the sole addition. Enroll43 and explicitly execute the new checker under hostile-root managed-wrapper controls. The full storage oracle exits0; four Python temporary owners and15 shell allocator owners remain unchanged. The source-bound reader rejects missing-checker, incomplete-population and relabelled-failure records. Full original canonical4 log/candidate, all Python/shell source images, actual actors/imports and before/after channels survive; the48-input neutral publication remains unchanged and passes. This is an integration correction, with no new runtime admission. Fresh exact staged canonical CI is required; canonical4 supplies no complete receipt. Original reader: docs/checkpoints/signed-array-contract-admission/storage_inventory.py.

  Owned archive representation issue / fix now: The storage capture retains a190,794,162-byte full staged binary diff inside a191,179,508-byte gzip packet; its documentation input packet recursively copies that stream. These newly generated recovery files need the existing bounded-chunk convention before staging. Preserve exact raw gzip bytes, whole hashes/counts/modes and actual reader behavior; copy/verify/use the chunked representation before removing duplicate originals. Only two exact rehydratable aliases enter .gitignore. No measurement, source epoch or neutral publication is regenerated or reclassified.

  Recovery representation closure: Both raw gzip streams retain exact whole bytes/counts/modes through24 bounded payload chunks and independent physical/payload/whole hashes. Three actually altered indexes reject and restore. Original aliases are moved aside before the unchanged retained reader executes through actual chunk reconstruction; complete output equals the original direct run. Only verified duplicate backups are removed afterward. Two exact ignored aliases are reproducible from committed chunks alone. The existing generic partition reader is retained at its original source identity; no old observation or producer is edited. Current review: bash tools/run_python_project_data.sh docs/checkpoints/signed-array-contract-admission/review_storage.py. New input snapshots hash-gate immutable gzip/part inputs instead of recursively embedding them.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.2`
  Status: `completed`
  Goal: Implement signed ordinary/deferred reads/writes on Perl.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.1`
  Owned paths: perl/LinkedSpec/BindingRuntime.pm; perl/LinkedSpec/CodeblockRuntime.pm; t/signed_array_selector_perl_contract.t; tests/numeric-codeblocks/signed-array-selectors.json; tools/run_ci_local.sh (register the focused Perl regression consumer); tests/language-readiness/verify_objectives.py (exact owned CI-registration inverse/denials only); docs/checkpoints/signed-array-perl/; docs/checkpoints/perl-literal-number-intake/ (late numeric-kind issue custody/intake only); docs/checkpoints/signed-array-perl-ci/ (canonical2 custody and bounded governance registration); docs/knowledge/write-vivification-perl-reference.md; docs/knowledge/phase0-compiler-scanner-mock-historical-inverse.md; current signed-selector and development CI book sections and new ordinary/callable write examples; normal task/roadmap/continuity including ROADMAP_V2.md. Frozen authorities/checkers, prior proof and other runtimes remain unchanged.
  Verification tier: `canonical`
  Focused checks: Public LinkedSpec::Get/return_descriptor/dump_parser_source/native and independently emitted execution before/after; frozen signed and historical-v1 fixtures; integer/string/coercion/read-purity, bounds, effects/order, identity, detachment, copied parameters and exact diagnostic spans; actual SUT inverse/source controls; direct Perl consumers, complete book, Knowledge/history/storage/whitespace and normal doctrines.
  Canonical trigger: Public Perl ordinary/deferred signed-selector semantics; exact staged canonical receipt and normal hooks before landing.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.2.json`
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.

  Activation: Clean ed658fb839184ddaad2c7ebc8566616024a0fd18 after17.1 exact canonical/all10 hooks/post-pointer/receipt promotion/brief0. The complete checked-live census has no planned runtime/test/book/card intersections. Retain the accepted51-image neutral publication and actual read-only success before production edits. Activation changes task metadata first; source-bound baseline/custody follows before runtime changes. Use source epochs with whole mutable overlays and immutable byte/mode identities, without recursively embedding old archives.

  Before-change mechanism / owned read-path gap: At unchanged ed658fb83 runtime sources, nine public sources run through separate descriptor/native/generated processes. Bare-binding negative reads work; callable reads return null. pick()[-1].count() returns0 while the positive twin returns1; both native dump and emitted source explicitly invoke CodeblockRuntime::read_path. This third array reader shares the digit-only restriction with indexed_var/nested_access. Child17.2 owns all three read routes now. The callable-result form retains its pre-existing raw-dependency marker1, with no fallback count; repairing its negative selection does not claim a new pure-source classification. Inventory1.2.1 must preserve that distinction. Float negative selectors remain null with NV-only return flags; dynamic-string array and harray-collision behaviors are separate preserved controls. Inputs/channels: docs/checkpoints/signed-array-perl/explore-inputs.json.gz and explore-runs.json.gz. Read-only: review_explore.py under the project Python wrapper. No production source has changed at this baseline.

  Regression enrollment: Extend ownership to the permanent public-source fixture and exact Perl CI consumer registration. A complete additional live-claim census reports no intersections for tools/run_ci_local.sh or tests/numeric-codeblocks/signed-array-selectors.json before either edit. The new test uses in-process emitted packages and introduces no new temporary allocator or Python tool entrypoint.

  Instrument qualification: The original120-source before/after epochs and full permanent channels remain unchanged. The first implementation meets118 public targets per route and all33 projected writes,14 shared-path reads,12 arithmetic and detachment controls. Two effect-oracle programs mistakenly use unsupported infix trail*10+n; LinkedSpec::Get dump retains raw_perl nodes and unsupported_codeblock_actionir before the write. Qualify only those instrument sources to established cat(trail,"n") calls and independently authored string1234, retaining original bytes/channels and distinct corrected epochs. They earn no product RED. No additional language/arithmetic repair is claimed.

  Verification interruption qualification: A coordinator edit to the newly added read-only reviewer overlaps the original nested-reader restoration epoch. The conservative all-input unchanged check correctly rejects that run; an independent complete mismatch census identifies only review.py, and both runtime sources restore exactly in finally. Preserve the whole original actor/epochs/channels and both reviewer versions; do not count the partial suite as completed proof. A distinct verified-prefixed entire eight-variant actor runs next without concurrent edits. No product defect or new source-fault credit is inferred from this interruption.

  Actual implementation proof: Corrected120 authored sources pass native/emitted, with zero fallback and unchanged four compatibility marker1 cases. Nine direct suites pass781 top-level tests; all33 frozen writes execute actual deferred callbacks/guards and detachment probes. The distinct full eight-variant physical run catches inverse55 per route, each reader, literal-float widening, wrong underflow fields, missing-array creation and shared binding/result roots; every restored oracle passes. Seven variants fail public targets; aliasing is caught by the independent host-mutation consumer. Complete actual rerun producer bytes precede commands in its whole epoch; a bridge resolves its inherited convenience field pointing to the original controller, without replacing any packet/observation. Book synchronization/render and canonical CI follow.

  Completion: 120 authored native/emitted programs; 12 arithmetic/14 read/33 actual deferred write records; 10 direct suites/789 top-level tests; eight physical source faults with restored controls; book93/four executed examples/three rendered denials and executed wrong-selector RED; input3/scope2 actual bypass/restoration. Perl scope only; no portable admission. Read-only publication validates the dated complete source/input population; exact staged canonical receipt and normal hooks govern this commit. No optional whole-backend matrices or portable signed admission are inferred.

  Owned continuity defect / verified repair: At accepted ed65, ROADMAP_V2.md still points to hygiene21 (last edit92c98fb3) while ROADMAP.md names17.1. This can misdirect a resumed session. The complete additional live-claim census precedes writes and has no intersections. Synchronize both bounded current paragraphs to verified Perl17.2/next Rust17.3 in this leaf; roadmap-census.json.gz retains both original files, exact Git history query and all live records.

  Review qualification: Sorted-key packet transport reorders map-field failure reasons. The first reader's order-sensitive comparison rejects; every case/reason membership and multiplicity is independently identical across all eight variants. Preserve the original reader/log and normalize only derived field-name reports. Actual outcomes, typed diagnostics and authored effect/case order are unchanged.

  Acceptance checklist:
  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/return_descriptor/dump_parser_source retains original53 genuine public signed failures per route, plus separately qualified two invalid instrument sources.
  - [x] **ROOT CAUSE (WHY + WHERE)** — BindingRuntime.pm::_selector rejects negative writes; CodeblockRuntime.pm::indexed_var/nested_access/read_path use digit-only reads. Actual Get dump names the callable-result reader; serialized number spelling explains the float boundary.
  - [x] **FIX** — Shared bounded callable lookup and encountered-array write normalization preserve missing/underflow distinctions and all earlier evaluation/copy/guard interfaces; enroll the permanent Perl consumer.
  - [x] **ADDRESSED (verified)** — Corrected120 native/emitted GREEN, actual inverse55 RED per route, eight physical variants and exact restored controls; all33 frozen writes execute real deferred callbacks and host detachment mutations.
  - [x] **NO REGRESSION** — Ten focused suites/789 top-level TAP pass, including old write/map contracts; exact staged canonical Phase0/local-CI receipt is required at commit.
  - [x] **LOCKSTEP** — Book93/four native-emitted examples/three source denials and executed wrong selector, Knowledge/history/live pointers and both roadmaps agree; frozen authority bytes remain unchanged.

  Late issue intake: Current/accepted byte-shadow native/emitted observations prove pre-existing whole-float and boolean literal kind erasure in _eval_expr before selectors. Own P1 repair22 immediately after this clean commit, before Rust17.3. Preserve the sealed118-input finite signed publication unchanged. Canonical1 is deliberately superseded143; exact original129-file candidate/fingerprint and full actual log are retained in perl-literal-number-intake/candidate-before.json.gz. This intake admits no producer repair; child22 owns fresh source-bound signoff. Current book now states the limitation.

  Owned CI enrollment defect / fix now: Canonical2 passes all10 doctrines, header176, syntax, capability/closure/composed checks, then exits1 in the isolated historical recovery producer. The new signed consumer sits between the callable fixture and its exact protected PUSH_CI_INSERTIONS suffix; verify_objectives.py:525 correctly rejects the missing adjacency before any historical hash comparison. Extend only its named owned insertion inverse and distinguishing registration denials, stripping the later signed addition first so every earlier anchor and historical byte/hash remains exact. A complete additional live-claim census has no intersections for the auditor, canonical fact card or CI book page before edits. Preserve the exact143-file candidate/fingerprint, whole actual log, original auditor and direct before rejection. No gate or historical observation is weakened/refreshed; fresh canonical proof remains required.

  CI enrollment closure: Three exact owned insertion pairs cover tracked test/fixture inputs, syntax and execution. The unchanged full isolated recovery producer passes134 inputs/84613241 bytes/22 recovery controls and690 evolution denials. Independent14 CI inputs admit only healthy; inverse verifier source rejects healthy, bypass source admits13 bad inputs, and actual restored source rejects all13 again. Original canonical2 candidate143/fingerprint179d413b1 and full exit1 log remain retained. The sealed118-input signed publication is unchanged; fresh exact canonical proof and normal hooks govern landing.

  Owned book pressure / fix now: Canonical3 correctly rejects the newly expanded CI chapter2057/2048 lines and public-reference aggregate50006/50000. Stop/join that candidate with exit143 and no canonical credit; preserve its exact161-file staged images/fingerprintd2056c827 and whole actual log before edits. Remove only redundant blank separators before headings, outside code fences, and require complete before/after rendered-page byte equality plus an effective changed-heading control before writing the candidate. Existing route, content, examples, and line/byte ceilings remain unchanged. Run the focused README routing-pressure check before starting fresh canonical CI.

  Pressure closure: Twelve empty heading separators are removed after actual complete renders prove all90 files/21277844 bytes and modes identical; a changed-heading source produces different output. Only then write the candidate. Chapter2045 and public-reference49994 fit unchanged2048/50000 ceilings. Full original output is retained once, the after manifest matches it exactly, and the original failed161-file candidate/log stay recoverable. Read-only signed-array-perl-ci/read.py verifies the actual source/control/output records; no semantic text, example, route or policy-cap change.

- ID: `TYPE-REFERENCE-BOOK.1.2.22`
  Status: `done` / verified finite Perl repair
  Goal: Preserve deferred primitive kinds, numeric payloads and copied scalar validity before continuing signed backend work.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.2`
  Owned paths: perl/LinkedSpec/CodeblockRuntime.pm; perl/LinkedSpec/BindingRuntime.pm (scalar validity classification only); t/callable_codeblock_literal_contract.t; tests/numeric-codeblocks/cases.json (one resolved startup35 control only); docs/checkpoints/perl-literal-kinds/; docs/claims/TYPE-REFERENCE-BOOK.1.2.22.json; existing primitive/boolean/write/type-method Knowledge cards; affected value/callable book teaching and examples/deferred-literal-kinds-perl.spec / examples/deferred-literal-precision-perl.spec; SESSION-STARTUP-READING.35 and its mutable partition/index cross-reference; normal task/roadmap/continuity. Preserve frozen contracts, sealed historical proofs and all other runtime sources.
  Verification tier: `canonical`
  Focused checks: Source-bound public descriptor/native/independently emitted literal and compiled-argument controls; pre-serialization scalar flags and JSON boolean identity; fixed/rest/contextual/copy/helper/selector effects; actual faulty/restored producer variants; callable, signed selector, numeric, logical, binding, generated and variadic direct consumers; rendered book, Knowledge/history/pressure and all doctrines.
  Canonical trigger: Public deferred primitive-value kind repair and exact staged canonical receipt before normal commit hooks.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.22.json`
  Activation: Clean3c8f69c88992d7d3aacccf701eecf602f6544e07 after17.2 canonical PASS (Phase01035), all10 normal hooks, post-commit pointer and promoted exact receipt; brief0 and clean Git. The boolean component is the existing SESSION-STARTUP-READING.35 defect, canonically recorded in docs/knowledge/perl-codeblock-boolean-literal-kind-drift.md, rather than a new discovery. This leaf executes that issue's complete acceptance together with the newly identified whole-float loss. ADR0123 removes its obsolete blanket full-reading prerequisite; preserve the original dated diagnosis and verify every semantic acceptance item before closing35 through this repair.
  Numeric construction intake: The source-bound number_flags.pl host probe shows that adding floating zero or multiplying by floating one still produces integer-only whole values on this Perl. Coercing the retained decimal spelling preserves floating flags. Its large-fraction control also shows a JSON round-trip can lose the fractional payload of1000000000000000.5. Before choosing the repair, distinguish a display-only loss from actual public native/emitted value loss with pre-serialization hexadecimal observations and compiled-literal twins. Own this investigation and any same-boundary repair here; do not infer a public defect from the host probe alone. Original diagnostics remain in number-flags-inputs/runs.json.gz under docs/checkpoints/perl-literal-kinds/.
  Public precision root cause: Eight exact public observations confirm actual value loss on both routes. The direct1000000000000000.5 literal has hexadecimal0x1.c6bf526340004p+49; its deferred twin has0x1.c6bf52634p+49 and loses the half before final reporting. Both emitted records retain source1000000000000000.5 but round their numeric value payload. AST::Parser::_parse_literal_expr creates numbers with0+the authored token; MethodLowering::_actionir_ast_plain_data_expr JSON-encodes that record; CodeblockRuntime::_eval_expr then ignores the preserved token and applies0+the rounded payload. Root correction belongs to this same literal reconstruction boundary. Preserve grammar/range and source-less-record compatibility; add independent precision controls alongside whole-float/boolean kind proof. Actual inputs/producer/channels and full native dumps/emitted source: precision-inputs/runs.json.gz.
  Genuine RED / implementation: The unchanged new consumer completes35 programs/70 native-emitted observations with no instrument errors.23 programs fail on each route (46 observations); direct compiled/argument, string/null, logical and integer controls distinguish the defects. Five direct assigned-kind write cases also cover RHS effects and unchanged receiver identity; source-less/nonliteral record controls preserve their old payload fallback. The repair reconstructs validated ASCII decimal tokens with the parser's0+source conversion and creates JSON::PP booleans; no AST/serialized-format, integer range or read-coercion change. Numeric equality treats signed zero as zero while checking floating kind; nonzero hexadecimal payloads expose precision loss. Source-bound before inputs/full TAP/dumps/emitted programs: docs/checkpoints/perl-literal-kinds/before-inputs/runs.json.gz. GREEN and source inverses remain required.
  First-after investigation: The first candidate remains incomplete and its full actual inputs/TAP are preserved.70 public executions have no instrument errors, but7 observations mismatch. Four nested/copied observations still lose whole-float kind; three helper-result observations retain correct values with additional numeric-cache flags. Direct parsed-record float writes also remain incorrectly accepted. Diagnose the public cloning API and cached literal-token conversion before another repair; distinguish incidental helper caches from semantic selector failures with a public counterexample. No success credit is assigned to this first after-run.
  Copy/cache root follow-up: The actual Storable public-API twin and CodeblockRuntime::_copy_value both turn nested whole-float copies into integer-only scalars; BindingRuntime's typed clone differs. Storable also adds numeric caches to source scalars. A public native callback computes index=-0.5 with num_sub(-1.5,-1) and incorrectly reads30 from[10,20,30], while the emitted and compiled-argument controls return null. Own this fractional-selector defect now with the same kind-boundary repair; compare an accepted3c8 runtime-byte shadow before attributing it to the new candidate. Distinguish public validity flags from private conversion-cache flags with primary B documentation and exact observed controls before changing classification or the oracle. Copy source/commands/channels and four public observations remain in copy-inputs/runs.json.gz.
  Validity diagnosis: Installed Perl5.34.1 and accepted3c8 owned-module byte shadows both reproduce the fractional native read; actual INC identifies the shadow modules. A private integer cache is set on-0.5 while its public integer-validity flag remains unset. The existing classifier wrongly admits that cache. Storable also changes original whole-float validity and emits integer copies, so restoring copied leaves after cloning would not preserve source kinds. Use a memoized typed-container copy while retaining opaque-reference fallback and callable identities. Reparse decimal tokens from a fresh string to avoid existing caches. The first oracle's private-cache equality overconstrains computed numeric results; retain it and qualify three after observations rather than count them as product defects. Corrected proof must distinguish public validity and retain raw cache observations. Before BindingRuntime edits, the complete added-path live census finds no intersection. Evidence: validity-inputs/runs.json.gz; primary read-only API reference: perl-api-reference.json.
  Second candidate / corrected instrument: Typed arrays/harrays now clone by scalar assignment with identity memoization; internal aliases/cycles and callable origin survive, and opaque references retain their existing fallback. Decimal reconstruction starts from a fresh substring. BindingRuntime classifies public validity rather than private conversion caches. The revised oracle compares canonical public kinds and nonzero numeric payloads while retaining all six raw flags; a valid integer's additional floating cache is not a second type. Two fractional-selector public controls expand the finite plan to37 programs/74 observations. Direct typed-copy topology/source-kind, opaque fallback and cached fractional read/write controls are added. Retain the original35-program before/first-after packets and actual instrument versions; capture a corrected full baseline against original accepted sources with exact candidate restoration before new GREEN proof.
  Compatibility expectation correction: The repaired37/74 and full28-root callable consumer pass. The eleven direct-dependent suites reach784 roots; ten pass and the only failed group is numeric10, specifically control/boolean-literal-owned-startup35. Its live fixture deliberately expects integer1 for return(true) in a callback, matching the old documented defect. The new result is typed true on both routes, as the existing primitive contract and issue35 require. Own changing only that current expected value, preserving all431 case identities/source bytes and the immutable historical numeric producer/proof. The complete added-path census for cases.json and its consumer has no live-claim intersections. Retain the failed full run; rerun the affected numeric suite after exact one-field correction rather than repeating ten unchanged passing suites.
  Numeric correction closure: The sole live expected value changes integer1 to JSON true with all431 source/id rows retained; the complete affected numeric suite passes10 roots, including all1008 nested program cases through both routes. Its first failure/full eleven-suite stream remains unchanged. The ten unaffected passing suites are not rerun without cause. Runtime bytes remain identical to verified-after. Book synchronization and actual source inverses still govern completion.
  Book preparation qualification: The first containment attempt exits1 before capturing its epoch or editing the book: the reused historical renderer inserts its own directory into sys.path, so document resolves to the old module without updated(). The later source-bound diagnostic confirms its actual __file__, retains the unchanged original helper/actor and whole log, and discloses the unavailable original pre-command census. It earns no product RED or render credit. The new wrapper preloads its own context and restores the caller path in finally; only pure render/manifest functions are reused, never the historical main. Evidence: book-import-qualification.json.gz. A fresh complete containment/render follows.
  DBIQNP discussion intake (2026-10-24; continuity only, no implementation pivot): Director asked about a LinkedSpec OpenAI plugin. Recommendation: reuse the MCP foundation for a future grammar/sample/result/failure-trace workflow, optionally adding a UI. Existing native MCP exposes two semantic-inspection tools over stdio, not parser execution or a ChatGPT connection (ADR0055; perl-mcp-decoded-server). Official OpenAI documentation fetched today describes shared ChatGPT/Codex MCP plugins with optional UI (https://developers.openai.com/plugins/build/app-quickstart), and ChatGPT custom connections using HTTP/SSE or Secure MCP Tunnel (https://developers.openai.com/api/docs/guides/custom-mcp-server). These facts establish a plausible integration direction, not tested compatibility with LinkedSpec's modern-only protocol. Future evaluation must own execution contracts, protocol/transport compatibility and instance authorization before implementation. No roadmap priority, delivery promise, publication or plugin implementation is authorized by this discussion; continue22 and the existing PNT frontier.
  Historical reproduction before22: With items=[10,20,30], cb={|| chosen=-1.0; return([items[chosen],chosen]) }; return(cb()) returns [30,-1] with integer-only B flags. Direct callable items[-1.0] and passing -1.0 as a compiled argument both return null. Get dump retains source -1.0 with serialized numeric value -1; CodeblockRuntime.pm::_eval_expr number uses 0+value and loses authored floating kind before assignment.
  Impact: Whole-float and boolean literals inside deferred bodies lose kind before assignment, return or container construction. Assigned1.0/false can incorrectly enter integer-only write selectors, while literal typed-write twins reject. Assigned-1.0 becomes an integer before negative selection. The signed runtime-kind contract is implemented; the preceding scalar producers need separate repair and broader numeric/boolean compatibility proof.
  Pre-repair root-cause verification: Sixteen exact public sources complete descriptor/current native/emitted and accepted-runtime-byte-shadow native/emitted routes. Accepted ed65 sources already return integral-float literals as integer-only scalars and boolean literals as integer0/1; compiled argument twins preserve NV/boolean kinds. _eval_expr number uses0+serialized value and boolean uses native1/0. Actual INC confirms preloaded accepted sources; no historical environment reconstruction is claimed. Intake: docs/checkpoints/perl-literal-number-intake/read.py. No producer repair/admission was claimed at that intake.
  Original schedule: P1 immediately after clean17.2 commit and before Rust17.3. Do not pivot while17.2 is dirty. Preserve the sealed118-input signed publication and every original outcome; repair and admit this producer in a distinct committed slice.
  Acceptance: Preserve supported integer/float/boolean source kind through deferred literal values, assignments, copied parameters/containers and helper operands; independently test negative selectors, scalar flags, direct literal and compiled-argument controls. Keep general numeric values/ranges, string/boolean/null, effects/copy/guard and frozen old/signed contracts intact. Add distinguishing actual producer inverse/restoration, current book teaching and exact canonical proof.

  Completion: Corrected accepted47/74 RED becomes74/74 native/emitted GREEN, with28 complete callable roots. Eight required physical runtime inverses are RED and all nine restored consumers GREEN; the optional fresh-token diagnostic is reported as actually observed. Eleven compatibility suites reach784 roots: ten pass unchanged; the sole startup35 numeric expectation is corrected and the full affected10-root/1008-program suite passes. All431 source/id rows and immutable old generator stay exact. Book95 inputs/six native-emitted examples/three rendered denials, executed wrong selector and18 blank-only separators with all90 outputs byte/mode-identical pass. Actual input3/scope2 inverse/bypass/restoration and whole source epochs support the dated finite proof. The three original overstrict cache comparisons and pre-epoch import setup failure earn no product RED credit. Startup35 closes through this owner only; all signed/intake history and other runtime sources remain exact. Current tests/Knowledge/book/roadmaps align. Required exact canonical CI and normal hooks govern landing; no other-runtime/portable admission.
  - [x] **ADDRESSED (verified)** — typed booleans/whole floats, large fractional payloads, source/copy kinds, cached fractional selectors; actual old-source RED and restored controls.
  - [x] **NO REGRESSION** — complete callable and direct consumers; only the deliberately old boolean expectation changes. Exact staged canonical receipt is required before commit.
  - [x] **LOCKSTEP** — current teaching/examples, original anchor, Knowledge routes, existing issue35 and both roadmaps agree; historical proofs remain immutable.
  DBIQNP clarification: The proposed plugin exposes structured LinkedSpec tools; ChatGPT/Codex interprets the conversation, calls those operations, and explains results. LinkedSpec need not parse chat. Director acknowledged this tool-API distinction and explicitly requested a deferred LinkedSpec integration task-tree (the FSMGen name was corrected). Create that planning-only tree at the next clean commit boundary; do not implement or reprioritize the integration. Official concept reference fetched: https://developers.openai.com/plugins/concepts/mcp-server. This remains discussion only.
  Owned review-instrument correction: First readonly review exits1 at noncore/AmbiTiming.pm before semantic review because Sources.recover equates full captured filesystem permissions with Git's executable-bit mode. Actual bytes match accepted3c8 exactly; every captured epoch records0640 while Git records100644. The existing project-root-evidence-filesystem-modes card already explains this distinction. Preserve the original reader (also retained in input-controls-inputs), whole actual failure log and later source-bound diagnostic before correction. Guard bytes against accepted Git, retain/validate observed full modes separately, and keep actual supplied-byte/mode denials effective. No chmod, runtime-result refresh or product RED credit; complete corrected readonly review remains required.
  Review closure: Corrected complete review, one-shot seal and actual readonly publication all pass with39 recoverable source epochs/10132 accepted plain blobs. Full captured permissions remain separate from Git executable status; actual input3/scope2 physical controls remain effective. reader-mode-qualification.json.gz retains the original source/log and later exact original-method rejection, disclosing the unavailable original readonly pre-census. The optional fresh-token variant is also RED on its direct controls; all nine complete restorations are GREEN. No general necessity claim or refreshed historical result follows. The declared22 claim binds the sealed actual producers/artifacts; exact staged canonical CI and normal hooks still govern landing.
  DBIQNP UI clarification: Director wants the proposed UI to serve as LinkedSpec's interface through the OpenAI host. Current official documentation confirms an optional interactive ChatGPT UI alongside shared ChatGPT/Codex tools; support in the selected Codex client must be verified separately. Include grammar/sample inputs, results, errors and traces as proposed UI requirements in the deferred tree; no current implementation pivot.
  Continuity hygiene: Replace the primitive/write cards' unwrapped reverify commands with project-data wrappers, and replace issue35's obsolete blanket reading dependencies with the actual22 repair owner/diagnosis under ADR0123. Original source/metadata remain retained in knowledge-before and accepted Git. No extra runtime/parity measurement is claimed.
  Landing checks: Actual readonly publication, final Knowledge regeneration, both bounded-history checks, whitespace and routing/README pressure pass. The pressure gate overlapped the final metadata-only reverify-wrapper correction; exact staged canonical CI rechecks the resulting documents before normal commit hooks. No sealed proof file changed after publication.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.3`
  Status: `done` / selected and admission proof; exact canonical receipt governs landing
  Goal: Implement the same policy through Rust native/generated interfaces.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.2`, `TYPE-REFERENCE-BOOK.1.2.22`
  Activation: Clean `691d2d87690ce3f9052c1d032a3e862ee5d76211`; hygiene22 all10 hooks/post-pointer, brief0 and clean Git verified. API planning1 is committed and implementation stays deferred. Native typed-binding/write Knowledge, signed target, relevant ADR0036 guard/evaluation rules and current book transition section reviewed; inspect current public Rust observations before runtime source diagnosis.
  Owned paths: Rust runtime/direct-dependent tests, permanent signed consumer, docs/checkpoints/signed-array-rust/, signed-array-rust-admission/ and this leaf's claim; verify_objectives.py exact engine evolution and canonical historical-audit Knowledge/ledger/book explanation; current Rust Knowledge/book/examples and normal continuity. Preserve every sealed predecessor prefix, frozen authority, submodule/pin and unrelated read-coercion contract.
  Verification tier: `canonical`
  Focused checks: Source-bound Rust public CLI/trace and typed native/generated consumers against the frozen signed target; changed behavior RED/GREEN, actual runtime fault/restoration, direct write/receiver/copy/numeric compatibility, independent emitted compilation, retained producer/input controls, executable book examples/render and normal history/memory/Knowledge/doctrine checks. Resolve exact affected suites from the current interfaces before runtime edits.
  Canonical trigger: Rust runtime/generated behavior and the new typed underflow diagnostic; run exact staged-candidate canonical CI before the normal commit workflow. Portable admission stays with17.7.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.3.json`
  Acceptance Checklist
  - [x] REPRODUCE / ISSUE — Reconfirm the dated Rust negative-to-zero coercion and rejected writes through public interfaces, retaining actual producer inputs and complete channels.
  - [x] ROOT CAUSE (WHY + WHERE) — Use the native tools/trace and canonical facts to identify read and isolated-write mechanisms before changes.
  - [x] FIX — Normalize supported negative integers against each encountered existing post-expression array; preserve missing-target, type, evaluation, guard and detachment boundaries.
  - [x] ADDRESSED (verified) — Independent target, exact native/generated/emitted observations and actual source inverses/restoration; no stronger scope than retained proof.
  - [x] NO REGRESSION — Positive/quoted-key/coercion, diagnostics, copies/effects/guards and frozen predecessors pass direct checks; fresh readiness parent6/emitted4/4/3 and isolated historical proof pass. Exact canonical receipt required before landing.
  - [x] LOCKSTEP — Current book examples/backend row, Knowledge, roadmaps/frontier and clean commit handoff agree before numeric55.1 then Dart17.4.
  Continuity repair: The root still labelled completed scalar22 as next. This activation corrects that stale label and advances the eligible frontier after the committed hygiene review; no historical result changes.
  Numeric boundary finding / owned plan: Current source confirms the already tracked .55.1 finite Number-to-i64 JSON saturation and rounded positive usize boundary; that broad repair stays with its existing owner. Signed underflow must retain authored index and exact encountered-length arithmetic. Use a checked signed internal index and explicitly owned exact JSON-integer support if required, without changing the DSL's f64 value model or expanding selector range. Add distinguishing signed-boundary controls and broad serde/carrier compatibility before any dependency-feature decision; record actual observations rather than inferring them from normal-sized cases.
  Fixture setup qualification: The first inline fixture draft assumed every non-write-error intake case had requested_value. The old read-underflow row deliberately has none, so AssertionError read-underflow stops before directory/file creation; no runtime or test change occurs. The original whole inline stdin was not separately retained. This earns no product/control RED credit; retain a named final builder with explicit read-underflow/empty expectations instead of inferring them from the old optional field.
  Before-runtime evidence: Public CLI32 and fresh calibration reproduce [-2,10,10,10,10]. The unchanged runtime then completes40 authored cases across native, SpecFile JSON, CompiledSpec JSON and generated-plan routes:160 observations,104 independent-target mismatches and56 controls. All original Rust images match real691d2d876 Git bytes/executable status, separately from full filesystem permissions; actual executables and complete channels are retained. review_before.py re-derives the original population without rerunning historical producers. Four unsigned-magnitude observer rows coarsen the expected resolved_index under the original JSON configuration; their product mismatch is independently the wrong error code, with no pre-fix numeric-field precision credit. A new direct JSON-token control isolates that observer boundary before dependency/runtime changes.
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.
  Numeric boundary resolution: The generic Value SDK-token proposal coarsens a wide integer; this is an observer/configuration limit, not a separate engine defect. Its original failed control/source/channels are retained. The corrected typed i128 serde token control passes all three exact tokens before runtime changes. Native diagnostics and generated failures retain original error strings, so typed nested-write serialization supplies exact index/path/arithmetic without a Cargo feature or scalar-value-model change. Corrected fixture markers decode to exactly the original targets.
  Candidate1: Add a checked signed index, preserve raw authored negative prefixes, reject missing negative containers, resolve existing arrays after expression effects, and serialize exact typed diagnostic integers. Keep positive classification and unrelated read coercions/order. run_test.py after1 completes all160 semantic rows and the exact typed SDK controls. The extended after2 consumer fails to build because the installed digest output does not implement LowerHex; no emitted runtime observation or product RED is claimed. Its source/build channels are retained. Render each digest byte as two hexadecimal digits, then run a fresh after3 epoch for independent emitted compilation; no repaired/admitted Rust claim yet.
  Candidate continuation: Fresh after3 builds and runs all40 cases across six routes (240 exact observations), including independently compiled emitted source and exact typed JSON tokens; source/executable custody and independent Python raw-integer review pass. Five added private boundary tests pass within all187 runtime unit tests. Expanded137 authored cases add all14 frozen read and29 write projections in both ordinary/callable forms, exact Unicode diagnostics, distinct parameter identity, snapshots/copies and four shared book examples. The supplied95-input book renders and rejects three actual rendered source faults. Expanded1/2 stop at an invalid public dispatch_span probe; they also expose the observer's omission of Rust's existing named callable error prefix. Whole source/channels and the failed first qualifier survive. Independent qualification confirms131 reached cases/524 rows with60 context-only observer mismatches and no target-payload mismatch; no full or emitted success is credited. Expanded2 was inadvertently launched after qualifier failure and is explicitly redundant. A valid effectful guard and exact named-context decoder replace those instruments; unreached quoted-key coercion expectations are calibrated publicly without changing runtime policy. Expanded3 reaches685 rows across five routes; its five mismatches are solely the Unicode span oracle counting one trimmed outer padding character. A source-derived26..28 scalar expectation, separate byte28/padded27 controls and permanent three-padding public AST probe correct the instrument. Expanded4 then passes all137 cases through six routes (822 observations), exact raw-integer review and actual emitted binary custody. Five actual runtime variants reject320/24/32/8/4 observations; each exact engine source/mode restores, and restored-final completes six routes with exit0. Late first-party include custody retains63 unchanged accepted-Git inputs without inventing earlier permission observations; final epochs explicitly enroll them. Independent restored review passes. First focused attempt captures a no-run batch, then Cargo --lib rebuilds the same binary path; its real188-test success is provisional and the driver correctly stops on changed SHA. Preserve original code/build/run/old bytes and the qualification; no complete compatibility or executed-binary custody credit. New focused_resume.py captures current executables immediately before direct execution in package cwd, reuses earlier archives only after exact current identity confirmation, and verifies post-run bytes/mode. Corrected direct compatibility passes all eight suites/443 top-level tests with exact pre/post executable identities (188 runtime units,5 write,15 receiver,1 numeric,18 callable,16 bindings,197 integration,3 corpus). CLI four exact examples and actual wrong selector, formatting, both model checkers and current95-input book pass. Both public book fragments are preserved with original missing/actual changed-alias denials. Actual readonly publication passes195 bound physical inputs. Four physical input controls are in flight; canonical admission remains required.
  Documentation regression ownership: The current heading rename changes the old public signed-array-selectors-in-perl fragment. Preserve that anchor alongside the new Perl/Rust heading before landing, even without a current internal backlink. This is a current-leaf compatibility repair, not a new campaign; retain original missing-anchor render, whole updated inputs and an actual changed-alias render denial.
  Existing numeric defect schedule: P1 SESSION-STARTUP-READING.55.1 is the sole owner of broad finite-number saturation and the pre-existing rounded positive index boundary. It is first after this clean Rust17.3 commit and before Dart17.4; no dirty pivot or partial .55.1 completion credit. The focused typed diagnostic path does not close that broader repair.

  Root cause / tooling: The public CLI calibration retains [-2,10,10,10,10] before source diagnosis. Legacy negative-to-usize reads and blanket negative write rejection are replaced at rust/linkedspec-runtime/src/engine.rs:5388 (array_selector_value), :4875/:4889 (checked negative classification), :4810/:4987 (post-expression isolated walk) and :413/:523 (exact typed diagnostic String serialization). No parser format, Cargo feature or dependency pin changes.
  Verified closure: Five runtime faults, restored822/6, eight direct suites443,95-input book/CLI and alias proof, readonly195/input4 actual bypass/restoration all pass. Claim198 is docs/claims/TYPE-REFERENCE-BOOK.1.2.17.3.json. Every provisional source/observer/capture-order limit remains durable. Exact staged canonical receipt and normal hooks are mandatory landing gates; derive admission identity from Git.

  Canonical blocker / owned repair: canonical1 passes all10 doctrines and early structural/model checks, then isolated historical-artifact recovery rejects current executable evidence drift at rust/linkedspec-runtime/src/engine.rs (verify_objectives.py audit_evidence). Reproduce with the unchanged canonical gate and retained signed-rust-canonical1.log; impact is blocked admission of the verified Rust change. Preserve the exact failed215-file staged candidate/actual channels before implementation edits, investigate the canonical historical-source boundary, and repair its replay/integration with independent before/reapply controls. New admission evidence belongs to docs/checkpoints/signed-array-rust-admission/ under this same leaf; every existing sealed prefix stays unchanged. P1 blocking, fixed before landing; no numeric55.1 pivot.

  Admission repair verified: Complete failed215-file candidate (17 whole mutable images/198 sealed references) and gate1 survive. The auditor permits only the exact historical/current Rust engine pair and reports its owner separately, preserving every historical identity/result. Unchanged isolated recovery retains134 streams/84613241 bytes/22 controls, byte-exact archive reconstruction and original guard0. Three source mutations/four direct path/history/image denials reject. Actual old-auditor rollback reproduces RED; physical hash-guard removal admits drift and the original driver rejects it; exact bytes/mode restoration returns the identical healthy report. Fresh unchanged Rust nesting/context/lossless/child consumers pass parent6/emitted4/4/3 with actual source/workspace/executable custody; no old runtime is rerun. Current book95 and actual changed admission statement reject correctly. New readonly49 and input4/bypass/restoration pass; the original unpublished claim remains unchanged within the combined record, which adds58 admission inputs. Canonical facts/ledger/book and continuation agree. No dependency implementation, old checkpoint or sealed prefix changes. Exact staged canonical receipt and normal hooks govern landing; numeric55.1 is next from clean Git.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.4`
  Status: `done` / exact canonical receipt and normal hooks govern landing
  Goal: Implement the same policy through Dart native/generated interfaces.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.3`, `SESSION-STARTUP-READING.55.1`
  Activation: Clean 4e6ece603bbdf7c77b83a2e8c1f79946e7da0490 after numeric55.1 exact canonical receipt, all10 normal hooks, post-memory/receipt promotion/check-head, brief0 and clean Git. No pending numeric job or source lease. Current signed authority (12 arithmetic/14 read/33 write targets), write-v1/map composition, affected book and Dart public native/compiled/generated interfaces are reviewed. Implementation source diagnosis follows actual public probes, not source-only guesses.
  Owned paths: Dart signed-selector read/write producers and diagnostic projection identified by public probes; affected permanent Dart consumers and required public examples/book; exact Dart historical source evolution in tests/language-readiness/verify_objectives.py and its ledger/readonly recovery proof; docs/checkpoints/signed-array-dart/, this leaf's claim, canonical Knowledge and normal live continuity. Preserve every sealed predecessor, frozen authority, backend admission status, dependency pin and other repository.
  Verification tier: `canonical`
  Focused checks: Retain complete first-party producer/fixture inputs and actual public RED/GREEN channels; independent signed arithmetic/value/diagnostic targets; ordinary/callable, native/SpecFile/compiled/generated-plan/fresh emitted/CLI carriers; exact guards/effects/copies/Unicode spans and source inverses/restoration; unchanged write/map/binding/callable/direct dependents, complete Dart package tests and non-writing format/strict-analysis observations; current book/executed examples, Knowledge/history/memory/doctrine checks.
  Canonical trigger: Planned backend signed-selector implementation boundary; exact staged approved-host canonical CI and normal hooks before landing. Keep the canonical process sandbox intact; no push during PNT.
  Claim verification: `docs/claims/TYPE-REFERENCE-BOOK.1.2.17.4.json`
  Component baseline boundary: docs/knowledge/dart-component-gate-sdk-compatibility.md already owns six formatter changes and two deprecated SDK-interface analysis warnings under DART-STARTUP-READING.2.24/.2.25. Reverify with non-writing commands; do not run the old mutating formatter over unrelated sources or imply a green complete component gate. Those repairs keep their scheduled owners. Temporary-owner inventory remains exact if any new allocator is required.
  Public baseline: Retained SDK3.13.3/compiler/CLI help and stable full first-party Dart/specification inputs precede an actual AOT executable archived before execution. Ten authored programs produce30 native/SpecFile-JSON/generated-plan observations:21 independently targeted,12 signed read/write mismatches,9 passing positive/quoted-key/missing-read controls and9 separately qualified coercion/error calibrations. All ten sources compile. No Dart production source changed. Complete source AST/compiled JSON and channels are retained under signed-array-dart/.
  Root cause / boundary: Public compiled nodes retain signed integer values in indexed_var and expression-bearing assign_nested_access. interpreter.dart::_indexValue (9622) excludes all negative coerced offsets; _classifyWriteSelectors (9930) rejects negative int before structural walking. Preserve old Map/string/float coercions, receiver ordering, legacy programmatic hash-index carriers and the nonnegative-only child-push overload gate. Writes accept int, while double -1.0 retains fractional_number rejection. New signed positions normalize only in existing arrays after effects, with raw negative path prefixes.
  First implementation/instrument boundary: Integer-only reads now resolve against the retained array; typed write ints normalize during the post-expression structural walk, missing negative targets preserve invalid-segment errors, and RuntimeDiagnostic forwards resolved_index. Changed-file format and strict analysis pass. First after1 actual source/AOT run has all21 targeted outcomes correct and preserves read/float-write calibrations, but its observer assumes native diagnostic objects for the generated wrapper and stops with KeyError. Complete actual packets/traceback are retained in generated-error-qualification.json.gz. Existing generated_source_error metadata/detail is the supported wrapper contract; qualify its fields separately and rerun after2 without changing runtime source. No product-RED credit or completed wide/carrier proof from that observer failure.
  Required historical admission (P1, same leaf): Numeric55.1's retained final report lists dart/lib/src/runtime/interpreter.dart among exact latest_source_inputs. Before production edits preserve whole current claim namespace and this boundary. Retain actual unregistered-candidate rejection, then admit only reviewed before/after whole Dart images with owner17.4 and unchanged historical identities. Actual old-auditor/guard-bypass denials and exact restored recovery must accompany fresh Dart readiness; never refresh an old checkpoint or broaden the Rust exceptions. This is admission work required by the signed slice, not a new implementation direction.
  Director steering 2026-10-25: Read the authorized external disk-notes index and LinkedSpec note. REPO-HYGIENE.23 owns exact source intake and measured safe cleanup at the next clean boundary, before Julia17.5. Finish and commit this dirty Dart leaf before activating maintenance; no current experiment, cache, Git object or dependency artifact is deleted on the strength of the old estimates.
  Verified proof: Initial public21 targets/12 signed RED/9 controls become113 programs/452 public observations and114 permanent tests passing. Private51 plus arithmetic12 uses41 exact first-party library copies and a separate observer suffix, adding no production export. Fresh113 emitted modules and107 CLI programs/214 quiet-trace runs pass. All16 actual AOT artifacts and full producer/source/fixture inputs are retained before execution. Five physical production inverses fail244/32/36/24/8 and exact source/mode restoration returns452/0. Native/SpecFile/validated-engine typed diagnostics, generic generated runtime errors, preserved caller exceptions and generic CLI phase failures are separately qualified.
  Compatibility / admission: Original package discovery636, primary CLI66x2, corpus105 and storage25 pass; changed-file strict analysis passes while existing SDK non-writing format1/analysis2 debt stays separately owned. Actual unregistered Dart source and old-auditor rollback reject. Exact whole-image admission preserves134 historical streams/84613241 bytes/22 controls and every Rust admission; nine primary/five support/four direct denials, actual guard bypass and exact restored healthy report pass. Book95/90 preserves aliases and four executed examples; four actual rendered-source denials pass. Original v1/signed/map/composition authorities and dependency pins are unchanged.
  Publication: Readonly publish.py re-derives all retained channels and whole binary/source identities. Four physical missing/byte/mode/required-omission faults reject, discarded actual validation admits each, exact restoration rejects each and restores identical healthy channels. Closed172 base/180 final custody/181 claim inputs retain all provisional compile/observer/namespace/mode qualifications without product-RED credit. Every source/auditor/input lease is closed. Canonical CI and normal hooks must accept the exact staged candidate before this completed state lands; then hygiene23, not a dirty pivot to Julia.
  Handoff correction: Recovery review found that the newly queued hygiene23 node/index/pointer existed while its Current Frontier table still listed only completed leaves. Add its pending frontier row and preserve distinct ordering before landing this slice. Canonical1 survived the daemon restart but was intentionally stopped during doctrine checks, before any acceptance receipt; its original log/watch refusal stay in project-local verification data. Rerun canonical2 for the corrected exact candidate. This is an owned continuity repair, with no runtime, book, authority, sealed181-input proof or measured result changes.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Complete clean140-file Dart/spec Git contents and actual original AOT channels show12 signed failures among21 targets, preserving9 controls; three coercion/error calibrations stay separate.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Public AST/value probes locate _indexValue's nonnegative bound and _classifyWriteSelectors' blanket negative rejection. Existing Map/string/float reads, retained read receivers, guarded child-push overload and historical programmatic carriers remain bounded.
  - [x] **FIX** — Existing integer positions normalize during the post-expression isolated walk; missing negatives retain legacy invalid errors, underflow adds exact resolved_index, and all original write-v1/map boundaries remain.
  - [x] **ADDRESSED (verified)** — Independent public/private/arithmetic/emitted/CLI targets, exact native diagnostics, effects/copies/identity/Unicode geometry and five physical source inverses/restored452/0 pass.
  - [x] **NO REGRESSION** — Complete636 package tests, CLI66x2, corpus105/storage25 and exact historical integrity/fault/restoration pass. Existing SDK format/analyzer debt is explicit; exact canonical receipt and normal hooks govern landing.
  - [x] **LOCKSTEP** — Current book95/90/four denials, canonical Knowledge, claim181, task/roadmap/handoff and four actual publication-input controls agree. Portable17.7 and Julia/Lua remain open; hygiene23 activates only from clean committed Git.
  Acceptance: Preserve positive/quoted-key, copy, atomicity, effect, diagnostic and guard contracts. Negative selectors require an existing in-range array position and never create gaps. No full portable admission before child7.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.5`
  Status: `completed`
  Goal: Implement the same signed-array policy through Julia native/generated interfaces.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.4`
  Activation: Clean96ce9700460a2f18d6938c647032e08a872d12fa after cleanup23, post-commit pointer PASS and brief0. Director prioritizes100% feature implementation: compile, quick targeted check, commit, next feature. Exhaustive suites/matrices/proof and global registry scans are deferred until feature coverage is complete; repair24 stays deferred.
  Owned paths: julia/src/runtime/Interpreter.jl read/write helpers and any direct Julia interface forwarding required by those helpers; julia/test/signed_array_selector_test.jl and its runtests.jl registration; current signed-selector book/Julia guide and existing Julia write Knowledge; normal task/roadmap/live continuity. Frozen neutral contracts, prior evidence, dependencies and other backends stay fixed.
  Verification tier: `focused`
  Focused checks: Load/compile LinkedSpecJulia through tools/run_julia_project_data.sh and run one small signed-selector regression covering native/generated reads/writes, underflow/missing target and positive/quoted-key controls. Build the changed book; fast manual memory/task/diff checks before commit. No full suite, corpus, exhaustive fault matrix or global registry scan for this feature.
  Canonical trigger: None for this implementation leaf under the director's explicit feature-completion policy. Broad validation belongs to the deferred validation phase; no portable admission is claimed here.
  Claim verification: none: Deterministic implementation/docs and a small regression check; no quantified corpus, benchmark, exhaustive or portable-admission measurement is published. Later comprehensive verification stays owned by17.7.
  Acceptance: Existing-array negative selectors resolve against each encountered array's length. Preserve positive/quoted-key, kind/copy, atomicity/effect, diagnostic and guard contracts; negative selectors never create gaps or missing arrays. Compile and focused regression pass before committing; full portable admission stays open.

  Completion: Shared Interpreter read normalization and nested-write traversal now resolve actual Integer negatives against each encountered array. Missing negative arrays retain invalid-segment errors, existing underflow reports authored index/path plus length/resolved_index, and optional diagnostic serialization leaves older shapes unchanged. Native/generated and a fresh emitted callable regression pass; package load compiles successfully. The check also covers copied results, RHS growth, positive append/quoted keys and typed failure precedence. No full package/corpus/fault matrix or portable admission is claimed.
  Focused command: `bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, Test; include("julia/test/signed_array_selector_test.jl")'`.
  Root cause / Toolbox: The public Julia primary read example returned null for[-1]; _runtime_index_value called _runtime_nonnegative_int, and _runtime_write_selectors rejected negative integers globally. Native/generated actions share these Interpreter helpers; the quick regression exercises their corrected public paths.
  - [x] **REPRODUCE / ISSUE** — Public Julia primary probe on examples/negative-array-current-perl.spec returned null for[-1] before implementation.
  - [x] **ROOT CAUSE (WHY + WHERE)** — julia/src/runtime/Interpreter.jl::_runtime_index_value used _runtime_nonnegative_int; _runtime_write_selectors rejected negative integers globally.
  - [x] **FIX** — Shared read arithmetic, conditionally valid write selectors, checked missing-container creation and isolated underflow diagnostics implement the signed contract.
  - [x] **ADDRESSED (verified)** — LinkedSpecJulia package compilation and the dedicated signed_array_selector_test.jl native/generated/emitted regression pass.
  - [x] **NO REGRESSION** — Quick positive append/quoted-key/copy/effect controls pass. Full package/corpus and exhaustive verification are explicitly deferred by the director; this is scoped assurance only.
  - [x] **LOCKSTEP** — Current book support, Julia write Knowledge/derived map, task/frontier/roadmaps and live handoff agree; portable admission remains open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.17.5 - support signed Julia array selectors`.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.6`
  Status: `completed`
  Goal: Implement the signed-array policy in shared Lua for PUC Lua and LuaJIT.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.5`
  Activation: Cleanceb92c320d20faeb287eba1f3935d55785605be7 after Julia17.5, post-commit pointer PASS and brief0. Follow director's compile/quick targeted check/commit/next-feature cadence; broad verification remains deferred.
  Owned paths: lua/src/linkedspec/interpreter.lua shared read/write and diagnostic helpers; lua/test/signed_array_selector_test.lua and lua/test/run.lua registration; signed-selector book and existing Lua write/core Knowledge; normal task/roadmap/live continuity. Frozen contracts, prior evidence, dependencies and other backends stay fixed.
  Verification tier: `focused`
  Focused checks: Compile/load the shared module and run the small signed-selector regression through tools/run_lua_project_data.sh on puc and luajit. Cover native/generated/emitted values and immediate missing/underflow/coercion controls; build changed book and run fast manual continuity checks. No full gate/corpus/exhaustive matrices/global registry scan.
  Canonical trigger: None for this implementation leaf under the director's explicit feature-completion policy. Broad validation belongs to deferred17.7 after feature coverage.
  Claim verification: none: Deterministic implementation/docs and a quick regression only; no quantified corpus/benchmark, exhaustive or portable-admission measurement is published.
  Acceptance: Existing-array negative selectors use L+index without creating missing arrays or gaps. Preserve positive/key, copy, atomicity/effect, diagnostic and guard behavior. Compile/targeted checks pass on both Lua ABIs; portable admission remains open.

  Completion: Shared Lua read normalization and isolated writes now support existing-position negatives; invalid computed read indexes use nil rather than the newly valid -1. Checked creation preserves missing-negative rejection, raw paths remain authored and underflow fields survive diagnostic serialization. Module compilation and the dedicated native/generated/emitted regression pass on PUC Lua and LuaJIT. The first test used an unavailable root to_json alias; correcting it to the existing interpreter.to_json public module API resolves that test-only error. No full suite/corpus/portable admission is claimed.
  Focused commands: `bash tools/run_lua_project_data.sh puc lua/test/signed_array_selector_test.lua`; same command with `luajit`.
  - [x] **REPRODUCE / ISSUE** — Public Lua runtime_parse on the shared read example returned null for[-1] before implementation.
  - [x] **ROOT CAUSE (WHY + WHERE)** — lua/src/linkedspec/interpreter.lua read_index/global write classification rejected negatives; nested/value reads also used -1 as an invalid-index sentinel.
  - [x] **FIX** — Single existing-array normalization, conditionally valid write selectors, checked container creation and underflow diagnostic forwarding implement the target policy.
  - [x] **ADDRESSED (verified)** — Both ABI wrappers compile/load and pass the dedicated native/generated/emitted regression.
  - [x] **NO REGRESSION** — Quick copy/RHS/positive/key/coercion and typed-failure controls pass. Broad validation remains deferred by director instruction; assurance is scoped.
  - [x] **LOCKSTEP** — Book, current Lua Knowledge/map, roadmap/frontier and handoff describe implemented support with portable admission open.
  Continuity: Required change-history rollover archives the committed suffix as docs/history/changes/segment-4960-dc390426c51b.md with its manifest row; the new feature record stays hot. History checks pass afterward.
  Commit: `TYPE-REFERENCE-BOOK.1.2.17.6 - support signed selectors on Lua and LuaJIT`.

- ID: `TYPE-REFERENCE-BOOK.1.2.17.7`
  Status: `pending`
  Goal: Admit the complete six-runtime policy, recurring compatibility and public examples; split capability/recurrence/public children before writes when needed.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.17.6`
  Schedule: Deferred comprehensive validation after100% feature implementation, per the director. Continue implementation after17.6 rather than running a broad verification campaign here.
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
  Status: `completed`
  Goal: Execute scoped with inside deferred callable bodies.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.14`
  Activation: Cleand5142f0292645e72f28209b89d1189860025771e after last14, post-pointer PASS/brief0. Director's compile/quick-targeted/commit cadence applies; broad verification stays deferred.
  Owned paths: perl/LinkedSpec/CodeblockRuntime.pm; t/deferred_with_contract.t and callable_codeblock_literal_contract.t registration; current with book and canonical Perl final-codeblock card; normal task/roadmap/live continuity.
  Verification tier: `focused`
  Focused checks: Module syntax and one small public ordinary/deferred/native/emitted with regression, plus scoped binding/presence restoration on a typed error. Cover metadata-approved helper/receiver/contextual/explicit forms, nesting, caller context and shape/effect guards. Build book and run fast manual continuity checks; no full suite/corpus/exhaustive proof/global registry scan.
  Canonical trigger: None for this implementation leaf under director feature-completion policy; broad validation is deferred.
  Claim verification: none: Deterministic implementation/docs and a quick regression; no quantified corpus, benchmark, exhaustive or portable-admission measurement is published.
  Reproduce/impact: Public Get on canonical Top:: I returns[7,outer] for immediate with but records typed unknown_helper:with inside a callable. ActionIR inspection shows metadata-normalizable block_value final arguments. The existing runtime lacks with dispatch, while ordinary lowering scopes value and restores caller slots.
  Acceptance: Metadata-approved helper/receiver forms execute in caller context with temporary present value binding, correct block-local return and restoration on success/error. Reject unsupported shapes before effects; retain explicit callback invocation rules and unrelated caller effects. Quick syntax/native/emitted checks pass.

  Completion: Helper/receiver with now consults CallableContract metadata and normalizes contextual final blocks. The runtime evaluates the input before temporarily shadowing value and presence slots; contextual bodies keep caller context, and explicit callbacks use the existing invocation ABI. Perl localization restores both slots on normal/error exits. Syntax and the small ordinary/deferred/native/fresh-emitted regression pass, including registered caller frames, nesting, null, shape/effect guards and the original typed-null-write conflict. Broad suites/admission remain deferred.
  Focused command: `bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/deferred_with_contract.t`.
  - [x] **REPRODUCE / ISSUE** — LinkedSpec::Get/ActionIR inspection shows valid contextual with and immediate[7,outer], while deferred with reports unknown_helper.
  - [x] **ROOT CAUSE (WHY + WHERE)** — perl/LinkedSpec/CodeblockRuntime.pm lacked with helper/receiver dispatch; ordinary MethodLowering already defines metadata and scoped-value behavior.
  - [x] **FIX** — Metadata-based callback normalization, temporary binding/presence slots and existing block/callback execution add deferred with without changing its syntax.
  - [x] **ADDRESSED (verified)** — Module syntax and the focused ordinary/deferred/native/fresh regression pass.
  - [x] **NO REGRESSION** — Quick caller/nesting/explicit-callback/null/shape/effect and error-restoration controls pass. Full suites remain deferred under director instruction.
  - [x] **LOCKSTEP** — Book and canonical with/write facts, derived map, task/roadmap/live handoff agree; grouped assignment19 is next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.16 - execute scoped with inside deferred codeblocks`.

- ID: `TYPE-REFERENCE-BOOK.1.2.19`
  Status: `done` / ordinary grouped assignment values
  Activation commit: `224754044cf11733a3918889723c440bc6022e7f`
  Goal: Resolve grouped indexed-assignment values against the supported mutation-expression contract.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.16`
  Reproduce/impact: Initial indexed-write12 copy control out=(chosen[0][0]=2) produced generated compilation failure near chosen[. Exact source/native/fresh channels survive in baseline.json.gz, not silently reclassified as unsupported syntax. The canonical perl-raw-readiness-source-unit-provenance card admits balanced ordinary mutation receiver groups for reporting; stored assignment-value contexts require separate adjudication.
  Schedule: After signed17/last14/with16, before inventory1. Establish Toolbox AST/lowering/source/runtime/effect/span evidence; fix supported value contexts or accurately document a contract exclusion with proof. Preserve prior reporting-only and deferred raw-group distinctions.
  Owned paths: perl/LinkedSpec/ActionIR/MethodLowering.pm; t/grouped_assignment_value_contract.t; t/callable_codeblock_literal_contract.t; canonical grouping fact, derived Knowledge Map, book and live continuity documents.
  Verification tier: `focused`
  Focused checks: Module/test syntax and one small grouped-value native/fresh regression; book render and fast continuity checks. Exhaustive suites/global scans stay deferred under director instruction.
  Canonical trigger: None for this bounded implementation phase; broad validation follows feature coverage.
  Claim verification: none: Deterministic lowering repair and a small regression; no quantified corpus, exhaustive or portable-admission measurement.
  Completion: Balanced ordinary assignment groups reach existing typed lowering, including compatibility-bridge helper operands. Inner parsing preserves offsets and function-local declaration/presence discovery follows the assignment; AST/reporting/deferred execution are unchanged.
  Focused command: `bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/grouped_assignment_value_contract.t` passes after reproducing native/fresh handler compilation failures. Module and callable-suite syntax pass; book render and fast continuity checks pass. Full suites remain deferred.
  - [x] **REPRODUCE / ISSUE** — Public AST/Get/substitution probes expose raw grouped RHS and emitted chosen[ syntax errors; focused regression is RED before repair.
  - [x] **ROOT CAUSE (WHY + WHERE)** — MethodLowering's top-level raw bypass and compatibility-bridge bypass omit typed group lowering; function declaration discovery also cannot see the raw assignment.
  - [x] **FIX** — Balanced assignment-only decomposition feeds existing value lowering and local discovery without altering deferred ASTs.
  - [x] **ADDRESSED (verified)** — Small native/fresh regression and module/callable-suite syntax pass.
  - [x] **NO REGRESSION** — Quick scalar/append/hash/nested, copy, ordering, receiver/argument/local and deferred-rejection controls pass; exhaustive verification is deferred.
  - [x] **LOCKSTEP** — Book, canonical grouping fact, map and live handoff agree; raw-regex21 is next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.19 - lower ordinary grouped assignment values`.

- ID: `TYPE-REFERENCE-BOOK.1.2.21`
  Status: `done` / raw multiline regex source-fidelity repair
  Activation commit: `28ce9b3e897efe3e1453d474c7b555b57465ed5b`
  Goal: Preserve complete assigned raw-regex payloads across statement splitting and native/fresh Perl execution.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.19`
  Reproduce/impact: rx = /(14,2) \\} followed by LF then tail/; return(rx), with explicit host subject x14,2 } followed by LF then tail. Both accepted24e9 compiler and current12 return false; a subject with an inserted semicolon returns true. Direct authored Perl regex gives the inverse. Generated handlers contain an added semicolon before the physical newline, changing match meaning without an error. Two subject controls and both native/fresh channels are retained in docs/checkpoints/type-deferred-indexed-writes/compatibility2.json.gz with raw_regex_oracle.pl and exact source rollback/restoration.
  Schedule: After signed17/last14/with16/grouped19, before policy20 and complete inventory1. Coordinate the distinct bootstrap .54.1/unescaped-brace and attached-tail .9 owners; do not silently promote their exclusions.
  Acceptance: Toolbox statement-boundary/source/pattern/value evidence identifies the exact producer. Preserve authored LF/CRLF, escapes, classes, delimiters and source spans; retain numeric slash calls and helper regex boundaries. Add independent match/mismatch and mutation controls, native/fresh recurrence and accurate legacy scope. No new portable raw-host capability is implied.
  Owned paths: First-party action statement splitting/lowering and a small focused test; canonical regex fact, derived map, book and live continuity documents. No submodule or external-repository writes.
  Verification tier: `focused`
  Focused checks: Compile the changed module and run a small source/match regression; fast continuity checks and book render. Broad verification stays deferred under director instruction.
  Canonical trigger: None for bounded source-fidelity implementation; stop/re-scope before a new slash-precedence or runtime-type contract.
  Claim verification: none: Bounded deterministic repair/diagnosis; no quantified corpus or portable raw-host capability admission.
  Completion: StatementSplit::Core protects a complete multiline slash token after a bare assignment only when its first physical line is still a raw expression. Complete typed first-line expressions retain their prior boundary, including numeric slash division. Existing quote state retains payload bytes and whole-literal ownership prevents DSL effects inside the pattern; no new value type or validator expansion.
  Focused command: `bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/assigned_raw_regex_payload.t` passes after observed RED; changed module/test syntax, book render and fast continuity checks pass. Full verification remains deferred.
  - [x] **REPRODUCE / ISSUE** — Public splitter/substitution/descriptor probes show partial assignment, RAW_PERL tail and an inserted semicolon; authored host literal oracle and native/fresh test reproduce the mismatch.
  Producer: RewritePipeline::_insert_pending_newline_terminator.
  - [x] **ROOT CAUSE (WHY + WHERE)** — StatementSplit::Core splits the unprotected raw newline; RewritePipeline newline-terminator insertion adds syntax before the raw tail.
  - [x] **FIX** — Protect complete multiline raw assignment tokens without changing complete first-line DSL expression precedence.
  - [x] **ADDRESSED (verified)** — Focused native/fresh exact-payload and authored match/mismatch check passes, with syntax/book checks.
  - [x] **NO REGRESSION** — Small LF/CRLF, escapes/classes/helper-looking text, binding-effect and numeric slash/quote continuation controls pass; full suites remain deferred.
  - [x] **LOCKSTEP** — Book, canonical regex fact/map and live handoff agree. Correct stale frontier19 status against its committed done node; inventory1 is next.
  Continuity defect owned/fixed here: frontier19 still said pending after28ce9b3e8 despite its done node and MEMORY next21; the table now agrees and no completed feature is reopened.
  Commit: `TYPE-REFERENCE-BOOK.1.2.21 - preserve assigned raw multiline regex payloads`.

- ID: `TYPE-REFERENCE-BOOK.1.2.20`
  Status: `pending` / policy update reconciliation
  Children: `.1.2.20.1` admission pressure repair intake.
  Goal: Reconcile the read-only shared live-document containment guide updates with local adoption.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.3`
  Intake: October23 read-only external policy review found new general derived-state/local-doctrine/checker material in the partially adopted FSMGen guide (SHA256 8f77fa39c9bcb9cfc43166259a627a6ced64682030088400b727dccc5d674a53). README policy digest 882682fa1ace703ae68726b8532a4ad24fe2c8a271bae4e07b859bd197a621c9 and claim policy 9f99df25209c43afb74d77e348dd2d0cdb68ce96cf17a4f272ede8328f6046bd were checked; claim policy remains ADR0126's adopted source. No cross-repository write occurred.
  Schedule: Deferred maintenance until feature coverage under the latest director instruction; do not block inventory1 or implementation23. Compare exact source/local adoption, own any applicable changes under bounded containment children, copy adopted rules locally, and verify doctrines/public explanation. External repositories stay read-only and no build may depend on them.
  Planned tier: `canonical`
  Claim verification: none: Policy intake and queue only; the implementation comparison and adoption evidence belong to this future leaf.

- ID: `TYPE-REFERENCE-BOOK.1.2.20.1`
  Status: `pending` / P1 mandatory document-pressure repair before admission or push
  Goal: Own the actual resulting-tree pressure/freshness failures exposed during Julia21.4, through verified containment repair.
  Discovered by: Focused optional document-pressure gate during valid reduction implementation21.4; runtime43 strict checks/book render pass independently. This intake does not activate a containment migration while the current feature tree is dirty.
  Reproduction: bash tools/project_data_run.sh bash scripts/check_readme_stability.sh with the preserved staged-index epoch at base0b9046522682d308b26d7935e09b0a279a7ab291. docs/checkpoints/type-operation-inventory/document-pressure-intake.md, metadata, exact staged binary patch and raw stdout retain the failed command/source context.
  Impact / ownership: Full admission/push is blocked by change_history/engineering_notes archive file/member controls, engineering aggregate controls, knowledge card count/bytes and task collection bytes. Document-history freshness additionally rejects non-dated current CHANGES headings, propagating to live status; task collection overflow propagates to task-index freshness. Ordinary focused runtime feature proof is not a full-doctrine receipt.
  Root cause: Completed chronology/immutable archives and cards have outgrown fixed resulting-tree controls, while the ignored feature doc writer formats CHANGES headings without an ISO date. Controlled HEAD/index deltas show the baseline already violates these controls: this Julia slice adds no archive/card files and its bounded existing-card/task edits cannot account for the excess. No deletion of immutable history or baseline/budget refresh is authorized by this intake.
  Schedule: Follow existing20 feature-first deferral through ordinary valid feature coverage; resolve before23.4/signature admission/final canonical push. Canonical owner LIVE-DOCUMENT-PRESSURE-CONTAINMENT is currently done through16; reactivate/split the required containment work only at a clean boundary, keeping this intake responsible until transferred to explicit repair leaves. No policy migration pivot inside the dirty Julia feature.
  Planned repair lanes: (1) Fix/clarify dated CHANGES production and normalize bounded current headings from retained history while preserving exact prior bytes; current Julia heading and ongoing local writer are corrected now to stop new recurrence. (2) Choose a governed bounded archive/index retention representation from canonical containment policy with exact ordered retrieval and immutable old evidence, addressing file/member/aggregate pressure. (3) Consolidate current Knowledge homes/lookup questions within unchanged controls, retaining provenance/current links. (4) Contain completed task chronology while retaining every stable ID/status/acceptance route and partition snapshots. (5) Run exact resulting-tree/freshness and designated canonical admission proof after all repairs, then close this owner.
  Acceptance: Reconcile adopted containment guide and registry/canonical memory/history rules before changes; preserve all unique facts, history, claims/producer inputs and current user reference. Use bounded separate commits, no arbitrary cap increases or hidden loss. Existing feature cadence remains focused; do not present current ordinary feature commits as a clean canonical doctrine receipt. Track each failure until fixed and verified.
  Planned verification tier: canonical at migration/admission activation; split ordinary bounded corrections when the existing policy permits.
  Claim verification: none: first-time deterministic gate-failure intake and source/index provenance, not an accepted population/capacity measurement. Actual repair must declare any measured admission claim and retain its producer/inputs/observed RED-GREEN.

- ID: `TYPE-REFERENCE-BOOK.1.2.1`
  Status: `active` / bounded operation inventory children
  Children: `TYPE-REFERENCE-BOOK.1.2.1.1`, `TYPE-REFERENCE-BOOK.1.2.1.2`, `TYPE-REFERENCE-BOOK.1.2.1.3`, `TYPE-REFERENCE-BOOK.1.2.1.4`
  Goal: Enumerate every supported operation and spelling from the retained authority population, grouped by actual type and syntax role.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.21`
  Planned tier: `focused`; reclassify before public/mechanical movement.
  Claim verification: none: Unactivated enumeration; declare actual source-bound proof before counting.
  Acceptance: Distinguish literals, constructors, operators, free helpers, receiver methods, aliases, callable invocation, generic and type-specific operations, plus private/retired recognition. Record signatures/arity, result/mutation/aliasing, callback/chain boundaries and backend limits; use public probes for uncertainty. Treat registered-name counts as one input, not completeness. Include the complete per-type fluent/result-type matrix inputs required by .23, and distinguish current methods from missing useful families; do not equate enumerating implemented names with a comprehensive API.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.1`
  Status: `done`
  Activation commit: `cedc5420dd26af910946a0c5fa573ce6a4ca81db`
  Goal: Index non-call value syntax, binding/path operators and callable forms against canonical authorities, without confusing syntax roles with methods or promoting raw host forms.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.21`
  Owned paths: docs/checkpoints/type-operation-inventory/syntax.md; existing per-type gap fact/map; public book value-model explanation and normal live/task continuity.
  Verification tier: `focused`
  Focused checks: One small public AST syntax probe for representative role boundaries; existing contracts/grammar and current signed/group/raw limits. Book render and fast continuity/history/diff checks only.
  Canonical trigger: None; existing syntax index, no runtime/public contract change or exhaustive admission.
  Claim verification: none: Qualitative source-linked syntax catalog, not a measured method count, coverage claim or backend execution census.
  Acceptance: Each syntax family records authored shape, role, result/mutation/callback/alias boundaries and canonical source; helpers, receiver methods, compatibility and private syntax remain separate. Leave helper/method enumeration to the next children and own encountered ambiguities instead of guessing support.

  Completion: syntax.md separates primitive/container literals, eager/deferred blocks, bare reads, typed paths/signed selectors, binding/append/path writes, grouped values, definitions/invocation/callbacks/receivers and separators. Each records result/effect/context boundaries and canonical authority; retired/private/raw compatibility stays qualified. Helper/method populations and actual missing transitions are not declared complete.
  Verification: A small LinkedSpec::ActionIR::AST::parse_action_expr probe confirms representative literal/container/eager/deferred/group boundaries. Book render and fast memory/cadence/history/diff checks pass; no full suite or exhaustive source census is run.
  Commit: `TYPE-REFERENCE-BOOK.1.2.1.1 - index value syntax and operation roles`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.2`
  Status: `active`
  Children: `TYPE-REFERENCE-BOOK.1.2.1.2.1`, `TYPE-REFERENCE-BOOK.1.2.1.2.2`
  Current implementation selection: Dynamic split_each scalar delimiters are owned by FUTURE-PARITY-BACKLOG.5.5; value/standalone5.5.1-.2 and retained standalone numeric kinds5.4.4 are implemented. Resume bounded helper enumeration/selection here; full enumeration is not complete.
  Goal: Enumerate current free-helper and alias spellings with canonical families, signatures, results, mutation/callback contracts and source links. Separate private/retired/compatibility-only names.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1.1`
  Planned tier: `focused`; use source/metadata checks, not a full runtime matrix.
  Claim verification: none: Spelling child is indexed; semantic mapping remains open and no aggregate completeness/counts are published.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.2.1`
  Status: `done`
  Activation commit: `63d1735d0561046bd6a5610ba0dabcdfb53c07da`
  Goal: Index current helper spellings by source resolver family, canonical/compatibility alias mapping and dedicated/private syntax roles. Establish a usable source spine before per-helper signature/effect mapping.
  Owned paths: docs/checkpoints/type-operation-inventory/helpers.md; current book inventory boundary and existing per-type/array facts/map; TYPE task and normal live continuity.
  Verification tier: `focused`
  Focused checks: Source-linked spelling/alias consistency check against the actual Dart registry and checker classifications; book build and fast continuity/history checks. No runtime census.
  Canonical trigger: None; qualitative source index only, no new language/runtime/helper admission or complete semantic coverage claim.
  Claim verification: none: Qualitative name/role index of explicit current source registries, not measured execution parity, API completeness, per-type coverage or corpus census.
  Acceptance: Preserve overloaded roles and source-family limits; canonicalize aliases without promoting source-only compatibility or private/dedicated forms. Keep signatures/results/effects with next1.2.1.2.2, receiver transitions with1.2.1.3/.23. Correct the encountered stale array fact's Dart/Julia pending wording against already committed5.3.2/.3; no replay of old producers.

  Completion: helpers.md indexes actual registry spellings by resolver category and canonical numeric/current/source-boundary alias mapping, with explicit reverse-check exclusions. Source categories are not input types/method admission; book/reference-only spellings and semantic mapping remain open. Correct the array card's stale Dart/Julia pending wording using accepted5.3.2/.3 records.
  Focused result: An exact source-spelling/alias consistency check passes: primary spellings appear in the index, alias targets are primary, compatibility names remain separate and dedicated diagnostics are not promoted. Book and fast continuity/history checks pass; no runtime census or old producer replay.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Existing syntax index delegates call spellings to this owner; no current helper spine existed. Array fact still labels accepted Dart/Julia implementations as unimplemented.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Registry sets mix resolver categories and syntax roles; old fact status was not advanced after5.3.2/.3. Current source/accepted task records distinguish those roles and dates.
  - [x] **FIX** — Index current spellings/aliases/exclusions with precise authority and semantic limits; correct stale fact status and advance the precise child frontier.
  - [x] **ADDRESSED (verified)** — Focused source consistency and book rendering PASS.
  - [x] **NO REGRESSION** — No runtime/contract changes; aliases keep their canonical and marker/attached restrictions, while private/compatibility names are not admitted as public methods.
  - [x] **LOCKSTEP** — Book explanation, contained current facts/derived map, task frontier and live handoff agree. Signature/effect child1.2.1.2.2 follows; comprehensive fluent/runtime validation stays open.
  Extraction note: The initial read-only extractor assumed every set ended on its own line and stopped at the inline output set before writing. The corrected source check accepts both layouts; no product defect or false runtime RED is claimed.
  Commit: `TYPE-REFERENCE-BOOK.1.2.1.2.1 - index helper spellings and syntax roles`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.2.2`
  Status: `pending`
  Goal: Map each indexed free helper to its actual signature/arity, input/result kinds, mutation/copy/callback boundaries and backend limits; select missing implementations as bounded feature leaves. Do not equate resolver families with input types or mark a method complete from a name.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1.2.1`
  Planned tier: `focused`; source/contract mapping and tiny public probes for uncertainty only. Broad semantic census follows feature coverage.
  Claim verification: none: No complete method coverage measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.3`
  Status: `pending`
  Owned reconciliation: Current Helper Catalog still says booleans/flow results are terminal, while the authority/model ledger records generic false.with()/cat observations. Confirm current behavior with a tiny public probe and repair the per-method wording here; do not promote a stale blanket statement or historical observation to a complete method table.
  Goal: Index actual receiver methods by input and returned type, chain/terminal behavior, argument and callback shapes, mutation/copy rules and backend limits; route actual missing methods/transitions to23.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1.2`
  Planned tier: `focused`; use tiny public probes only where current contracts are uncertain.
  Claim verification: none: Not yet activated; no complete fluent API claim.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4`
  Status: `pending`
  Children: `.1.2.1.4.1`, `.1.2.1.4.2`.
  Goal: Reconcile the syntax/helper/receiver inventories against current authority roles, then select bounded implementation gaps under23. Broad semantic validation remains deferred until feature coverage.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1.3`
  Planned tier: `focused`; no full suite for inventory closeout under the current director policy.
  Claim verification: none: Not yet activated; declare any aggregate population measurement before publication.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.1`
  Status: `pending` / P2 invalid-callback diagnostic parity
  Goal: Reconcile malformed reduction callback arity failure phase/diagnostics against admitted callable metadata and canonical parity.
  Discovered by: Rust21.2 independent producer/shared intake; no valid-input producer defect.
  Reproduction: [1].reduce_leaves() {return(value)} and reduce_leaves(0,1) with a later consumer return null/no effects through Perl Get/fresh (permanent t/reduction_result_receiver_contract.t), while Rust Core, Dart and Julia compile report callable_contract_arity_mismatch before execution (their reduction_result_receivers tests). Lua compiles those shapes but native/plan/fresh raises its existing RuntimeInterpreterException arity text (generated wrappers add their execution prefix), now before source effects after21.5. The shared valid-value fixture therefore excludes malformed signatures and local tests preserve each current policy.
  Impact / ownership: ADR0023 requires equivalent accepted-input/results/diagnostics; existing malformed-program timing/error identity differs despite both skipping effects. Keep this distinction explicit rather than treating source rejection as a runtime value. No signature/policy normalization inside the valid reduction-result feature.
  Schedule: Reconcile canonical ADR0030/0031/0032 and final-codeblock registry/neutral cases immediately after ordinary fluent feature coverage, before signature1.2.1.4/23.4 parity admission/final push. Own the necessary bounded backend fixes and typed diagnostic regressions there; broad matrices remain deferred.
  Acceptance: Select the existing canonical signature/diagnostic authority, independently distinguish both malformed shapes on all active routes/backends, preserve no-effects and valid reduction behavior, repair actual phase/diagnostic drift and update public error guidance. No universal invalid-program policy inferred from a few samples.
  Planned verification tier: Select at activation for any governed diagnostic contract movement.
  Planned claim verification: none: Owned deterministic invalid-program parity gap, no aggregate completeness measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2`
  Status: `active` / P2 scalar/null copy domain and result parity
  Goal: Resolve accepted scalar/null copy domains and repair the resulting portable copy/method gaps.
  Discovered by: Dart23.3 producer-first compatibility control; existing copy facts/book already qualify backend domains and depths. Logical receiver work must preserve those policies while this owner resolves the public contract.
  Reproduction: Rust logical_receiver_methods existing_with_prefix_keeps_scalar_copy_boundary_and_container_recovery and Dart logical_receiver_methods_test existing-with value-copy case use the same source: scalar="x".with() {return(false)}.not().copy(); return(scalar). Rust native/restored/plan yields null; Dart native/restored/plan yields real true. Independent Dart controls and(true).copy(), true.copy(), copy(false) give true/true/false before production changes. Scope restoration, typed Bool production and container copy recovery are healthy; the difference concerns accepted copy inputs/result guarding.
  Impact / ownership: A generic fluent program cannot assume one portable scalar-copy result across current backends. Do not misclassify preserved Dart value copying as a new logical producer defect, silently bless portable skew or normalize free helpers inside the logical feature.
  Schedule: Select immediately after ordinary logical23 backend coverage, before declaring remaining ordinary feature coverage exhausted and before1.2.1.4/23.4 admission/final push. Reconcile canonical copy/value/reference authority first, then own bounded backend feature/repair leaves and focused checks; broad matrices remain deferred.
  Acceptance: Establish admitted function/receiver copy domains from current canonical contracts/book/Perl reference and retained compatibility records; choose a coherent target with explicit authority for any domain movement. Cover scalar Bool/Number/String/null and existing Array/Hash copies without losing source snapshots/kinds, arity-before-effects, mutability/detachment bounds or callable origin. Fix every accepted-domain mismatch (or consistently implement the explicitly reviewed unsupported-input boundary); documentation alone does not close this owner. Preserve dated prior compatibility evidence; no blind oracle refresh or unrelated depth-policy expansion.
  Planned verification tier: Select at activation for actual public contract/domain movement under the director's feature-first cadence; complete canonical admission remains23.4.
  Planned claim verification: none: deterministic authored compatibility/domain intake; no population/completeness measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.1`
  Status: `completed`
  Goal: Reconcile scalar/null copy authority and current reference behavior before bounded parity repairs.
  Parent: TYPE-REFERENCE-BOOK.1.2.1.4.2; authority ADR0006/0007, current book, canonical copy facts and public Perl reference.
  Activation: clean `73735f4fb01747348cd6d136aee7d4bd8c552aa7`; Lua logical feature committed/tree clean/brief0.
  Owned paths: Deterministic public Perl copy-domain probe/retained focused contract intake, task/roadmap/current book/facts/map/live continuity. No production/domain change in this assessment.
  Verification tier: `focused`
  Focused checks: Public Get/substitution/fresh emitted execution of scalar/null/free/receiver/prefix/selected copy and container controls; inspect explicit contract authorities before selecting repair children. Compile authored probe, render changed book, bounded history and staged continuity checks. No broad matrix/full CI.
  Canonical trigger: Actual public domain/contract movement requires explicit authority and designated admission; complete portable copy/method admission remains23.4 after feature coverage.
  Claim verification: none: Deterministic authored contract/reproduction intake, no completeness/population measurement.
  Acceptance: Distinguish supported container inputs from scalar/null fallbacks, avoid deriving target from backend majority, preserve existing nested/detachment/arity/callable boundaries, retain exact prior evidence, own bounded fixes rather than documentation-only closure. Any genuinely conflicting policy or required language-evolution decision is surfaced with concrete alternatives.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Eight authored public Get/fresh cases reproduce ordinary scalar/null[] versus logical-result null and retain container kinds/false/null, source SR and malformed no-effects. Exact observations and producer are tracked.
  - [x] **ROOT CAUSE (WHY + WHERE)**: Public substitution shows aggregate copy explicit[] fallback while MethodLowering logical-result chains emit terminal rejection/undef. Full Get/fresh establishes with behavior; isolated substitution does not reconstruct its scope.
  - [x] **FIX**: Reconcile existing container-only authority and current backend qualifications; correct the book's overbroad scalar[] wording to distinguish logical-result rejection. Request the genuine scalar-domain decision before changing reference semantics; own decision/repair child4.2.2 and preserve parent open.
  - [x] **ADDRESSED (verified)**: Native/fresh observations agree without compile/runtime errors; probe syntax passes. No target selected from backend majority or blind expectation refresh. Recommended generic value copy versus explicit container-only compatibility path is concrete and durable.
  - [x] **NO REGRESSION**: No runtime/grammar/schema/expected-result/domain change; source/arity/container/copy-depth/callable boundaries retained. Book/history/continuity/diff checks run before landing.
  - [x] **LOCKSTEP**: Retained intake/observations/probe/current book/array-copy fact/map/roadmap/task/live pointer align. Parent4.2 stays open for verified implementation; next independent selection23.1.4 is owned while director choice remains open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.1.4.2.1 - reconcile copy-domain authority and reference`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2`
  Status: `active` / director-approved value-preserving scalar/null extension
  Goal: Adopt the director's scalar/null copy choice, then own bounded reference/backend repairs to completion.
  Dependencies:4.2.1 copy-domains.md and the October27 director approval of the value-preserving extension.
  Acceptance: Adopt the approved value-preserving Bool/Number/String/null extension; advance Perl first then Rust and independently check Dart/Julia/safe Lua. The container-only alternative was not selected. Preserve container depth/detachment/arity/snapshots/callable origin; own exact bounded children before production changes and retain prior observations. Documentation alone does not close parent4.2; broad admission23.4 remains later.
  Planned verification tier: Select for adopted contract movement under current director cadence; canonical admission before push remains mandatory.
  Planned claim verification: none: Deterministic contract decision and bounded feature repairs, not a completeness measurement.

  Director decision (October27): Extend copy(value) and value.copy() to preserve Bool, Number, String and null; retain existing container-copy depth rules. This is explicit authority for the recommended language extension; do not ask again or choose the container-only alternative. Finish the in-flight deferred-body compatibility repair and commit it cleanly, then adopt this target and implement Perl first followed by owned backend children. Direct computed-call work stays queued while copy-domain work proceeds.
  Children:4.2.2.0 implementation-target adoption;4.2.2.1 Perl (producer1.1, receiver1.2, existing interpreted-copy context1.3 if admitted);4.2.2.2 Rust;4.2.2.3 Dart;4.2.2.4 Julia;4.2.2.5 safe Lua. Full canonical admission remains23.4.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.0`
  Status: `completed`
  Goal: Record the director-approved scalar/null value-copy implementation target and own bounded rollout before code.
  Dependencies:4.2.1 retained authority/reference observations; October27 explicit director choice.
  Activation: clean `c2b1142c7221d47670efc14527f6e3d7f21f99f3`; deferred-boundary repair committed/tree clean/brief0.
  Owned paths: ADR0138/index and copy-value preservation target; planned-only public reference qualification, copy fact/map/roadmap/task/live continuity and required bounded engineering-history rollover. No runtime/current capability or frozen neutral JSON movement in this design leaf.
  Verification tier: `focused`
  Focused checks: Exact director decision/ADR0006/0007 and retained copy-domain facts, existing signatures/guards/depths; clear target/current implementation distinction, small document/history/map/book/continuity checks only. No invented runtime PASS or broad gate.
  Canonical trigger: Full public/portable/context/canonical admission23.4 after reference/backend implementation; this leaf records the approved future implementation target and does not admit an existing backend capability.
  Claim verification: none: Normative director-approved target and bounded implementation ownership, no new runtime/population/completeness measurement.
  Acceptance: copy(expr) and expr.copy() preserve accepted Bool/Number/String/null values/kinds, evaluate the source once, and continue by actual returned kind. Retain current container depths, no implicit numeric/Boolean/text conversion, callable-origin rights, binding/noncreation, source errors, existing free malformed signatures and receiver arity-before-effects. Scope existing interpreted copy contexts independently; do not add new deferred vocabulary. Perl first; keep past observations and superseded scalar fallback evidence historical and own old expectation changes under explicit approval.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Retained4.2.1 public reference and backend controls distinguish ordinary Perl/Rust scalar fallback/rejection from Dart/Julia/Lua value preservation; the director explicitly selects generic primitive value copy, resolving the authority question.
  - [x] **ROOT CAUSE (WHY + WHERE)**: Existing copy authority unified containers without an admitted scalar target; result-family guards and producer domains differ. ADR0138 supplies explicit extension authority without inferring a policy from backend majority or changing historical observations.
  - [x] **FIX**: Freeze scalar/null value-copy implementation target and own Perl producer/receiver/interpreted-context plus independent backend leaves before code. Retain container/context depths, actual kind, no conversion, source/error/arity/provenance and existing vocabulary boundaries.
  - [x] **ADDRESSED (verified)**: Target/ADR/director choice and canonical reference/signature/depth sources agree; planned-only book status and task rollout are checked. No runtime implementation/parity/completeness result is invented for this design leaf.
  - [x] **NO REGRESSION**: No runtime/current capability/frozen neutral JSON or old measured artifact changes. Bounded engineering-history rollover preserves exact committed records; map/book/history/continuity/diff checks complete before landing. Full canonical admission remains separate.
  - [x] **LOCKSTEP**: ADR/index/frozen target/planned public book/copy fact/map/roadmap/task/live pointer align. Perl4.2.2.1.1 is next, followed by receiver/context and independent backends. Direct computed calls remain owned/queued; no new approval request is needed.
  Commit: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.0 - adopt scalar and null value-copy target`.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.1`
  Status: `completed` / bounded producer, receiver and existing-context children
  Goal: Implement the approved primitive value-copy target on Perl without changing container/context/provenance bounds.
  Dependencies:4.2.2.0 ADR0138/frozen target.
  Children:4.2.2.1.1 ordinary producer/results;4.2.2.1.2 ordinary receiver/results;4.2.2.1.3 already-supported interpreted copy preservation/repair.
  Acceptance: All three bounded children verify and commit before Rust rollout. Preserve historical observations and update only scalar/null expectations explicitly superseded by the director's decision. Full source/context/portable/canonical admission remains23.4.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.1.1`
  Status: `completed`
  Goal: Make ordinary Perl function copy preserve primitive values and actual-kind result continuations.
  Dependencies:4.2.2.0.
  Acceptance: Typed one-argument producer preserves Bool/Number/String/null, source-once/order/snapshots and errors; Number0 versus String0 remains independently distinguishable before serialization. Existing Array/Hash ordinary depth, rule accumulator/legacy storage, valid expression materialization and retired-source boundaries remain. A copied scalar result cannot acquire Array semantics or run incompatible consumer operands. Preserve malformed free signature policy; generic receiver rollout is next1.2. Own any necessary actual-result classifier changes in this producer slice, splitting before edits if too large.
  Planned verification tier: focused
  Planned focused checks: Independent producer-first scalar/null/control RED/GREEN on native/fresh, actual-kind/source/error/container controls and direct copy/result tests, source syntax/book/history/continuity only.
  Planned canonical trigger: Complete source/context/portable/contract admission23.4 after all feature children and final clean push.
  Planned claim verification: none: Deterministic authored feature/preservation controls, no population/completeness measurement.

  Activation: clean `e236d026fe4108c7a6923a9d88c9f53d61964ecd`; approved copy target committed/tree clean/brief0.
  Owned paths: Ordinary Perl typed function-copy producer and necessary actual-result flow in MethodLowering, strict native/fresh producer regression/diagnostic input and existing expectation changes only where ADR0138 applies; current book/copy target/facts/task/live continuity. Preserve legacy rule/argument materialization and source-retirement boundaries before code. No new parser/deferred/opaque-callable domain or depth policy.
  Verification tier: `focused`
  Focused checks: Public producer-first scalar/null/typed source/shape/error/container distinction, strict native/fresh primitive identity/kinds/source snapshots and actual-result guards plus direct copy/container/result compatibility and syntax; book/history/staged continuity. No full suite/matrix.
  Canonical trigger: Complete copy/source/context/portable/admission23.4 and final clean push after feature coverage. Generic receiver1.2 and existing interpreted context1.3 remain separate.
  Claim verification: none: Deterministic authored feature/regression/preservation controls, no population/completeness measurement.

  - [x] **REPRODUCE / ISSUE**: Public Get/independently emitted source in probe_value_copy_producer.pl retain primitive copy[] and consumers null/[]/SCRA; numeric and String selectors both fail as Array. New t/value_copy_function.t observes the target RED; source-error field is helper_name, and emitted selector errors are structured objects (test diagnostic extraction corrected from those observations).
  - [x] **ROOT CAUSE (WHY + WHERE)**: call_spec_handler_subst/dump_parser_source show MethodLowering aggregate copy reconstructing true/undef as bare names, 0 as legacy array storage and computed primitives through [] fallback. Free-copy chains infer Array rather than guarding actual kind. Existing source error remains helper_arity_mismatch/and with arguments_evaluated0.
  - [x] **FIX**: Lower non-variable/non-splice one-argument copy from typed AST; share an outer-only copy emitter preserving no-ref scalar flags/null and JSON Boolean identity, retaining opaque fallback. Variables keep legacy kind-provider/storage selection. Free-copy and repeated-copy results use default_result actual-kind continuation; do not change receiver/deferred grammar or depth. ADR0138 explicitly authorizes text/zero expectations advancing in the existing bound receiver test and the missing selected-copy expectation changing from[] to null in selected_container_receiver_contract.t.
  - [x] **ADDRESSED (verified)**: t/value_copy_function.t native/fresh target cases pass: true/false/0/7/-2.5/String0/empty/Unicode/null/missing, named/computed/selected/function-local values, SCR guarded operands, source snapshot0!/7/2, repeated-copy/default recovery, Number write success versus String harray/array conflict, original and source error and retired selector rejection. Containers retain outer distinction/nested sharing before JSON.
  - [x] **NO REGRESSION**: New producer plus existing scalar-bound/legacy copy tests PASS499; direct selected-scalar/selected-container/logical-method tests and changed module/test syntax pass. No full suite, canonical coverage or new interpreted/callable admission is claimed.
  - [x] **LOCKSTEP**: Current book/catalog, copy target, canonical copy facts/map, roadmap/task/live/resume align. Historical captures remain unchanged. New t/value_copy_function.t registration is owned by23.4.1 before admission/push; ordinary receiver1.2 then context1.3 and backends follow after this commit.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.1.2`
  Status: `completed`
  Goal: Complete ordinary Perl value.copy() primitive/result-flow counterparts after the typed producer.
  Dependencies:4.2.2.1.1.
  Acceptance: Named/literal/selected/block/function/prior scalar-result and scoped flows preserve copied primitive kind/value; repeated copy and compatible scalar/default/container-recovery continuations work by actual kind. Wrong container consumers skip their operands after valid source/prefix effects. Zero authored operands and pre-effect malformed shapes remain; preserve container depths and legacy callable/scoped provenance. Update old fallback/rejection expectations only with ADR0138 authority.
  Planned verification tier: focused
  Planned focused checks: Strict native/fresh finite copy-result/method/scope/shape/error/source-kind controls and direct existing copy/scalar-result regressions, syntax/book/history/continuity.
  Planned canonical trigger: Full context/source/portable/canonical admission23.4 after feature coverage.
  Planned claim verification: none: Deterministic finite feature/regression controls, no population/completeness measurement.

  Activation: clean `82dfc9556dc12aa4cd52146ee3c662afaaafe58f`; producer1.1 committed/tree clean/brief0.
  Owned paths: Ordinary Perl receiver/result dispatch in MethodLowering, finite native/fresh source/continuation/scope/shape regression and ADR0138-superseded scalar expectations; public copy documentation/facts/task/live continuity. Keep the legacy variable-only single-copy producer path and callback/storage contracts; no parser/deferred/context/depth expansion.
  Verification tier: `focused`
  Focused checks: Producer-first receiver RED/GREEN; strict native/fresh primitive kinds, prior-result/repeated/default/scoped/source snapshots/errors/shape and container controls; direct copy/logical result checks, syntax/book/history/continuity. No full suite/matrix.
  Canonical trigger: Complete source/context/portable/admission23.4 and final clean push after feature coverage; independent interpreted context1.3 and backend children follow.
  Claim verification: none: Deterministic authored finite feature/regression controls, no completeness measurement.

  - [x] **REPRODUCE / ISSUE**: t/value_copy_receiver.t public Get/fresh source observes primitive-result/typed write failure and malformed block-operand copy compilation failure. Existing canonical copy facts identify scalar_result rejection and Array inference; call_spec_handler_subst on copied block/trim/take and copied block/set_key shows the exact guarded source.
  - [x] **ROOT CAUSE (WHY + WHERE)**: Ordinary fluent MethodLowering routes copy through container-family inference or rejects it after scalar_result. Malformed copy lacks early shape preflight for block sources. Independently, the selected set_key chain passes an authored block key to the compatibility key lowerer, emitting $__ls_set_key{{order=cat(...);"a"}}, which cannot compile even inside a false runtime Hash guard. This encountered compile defect is owned/fixed here because it blocks the accepted wrong-kind-operand control.
  - [x] **FIX**: Add zero-operand copy shape preflight retaining its unsupported-helper sentinel; fold each valid copy link with typed prefixes into the existing function producer alongside logical links. Primitive kinds and actual-result continuations now share the committed producer. Lower selected-chain set_key block keys from typed AST before compatibility embedding; retain its existing operand order/depth and guard semantics. No deferred vocabulary, parser format, callable origin, new conversion or malformed free-helper policy.
  - [x] **ADDRESSED (verified)**: New native/fresh t/value_copy_receiver.t PASS23. Strict values include primitive literals/bindings/repeated copy, and(false), arithmetic4, StringA, false default0!, missing recovery7, with/not true, guards null/null/SR, once-only snapshot0!/7/2, function-local outer/9 preservation, copied containers and Number0 write success. Compatible Hash block key yields {a:1}/K; wrong-Hash block operands skip. Malformed extra operands reject before effects; original and() helper_arity_mismatch/arguments_evaluated0 propagates.
  - [x] **NO REGRESSION**: Direct t/actionir_receiver_scalar_copy.t and t/value_copy_function.t PASS499 on final production; legacy callbacks, source poisoning, exact rule return[@Top], outer-distinct/nested-shared identities and producer source errors/retired selector controls remain. Changed module/new-test syntax and book/history/fast staged continuity pass. No full CI or canonical coverage claim.
  - [x] **LOCKSTEP**: Current book/catalog/examples, copy target/facts/map, roadmap/task/live/resume align. Add t/value_copy_receiver.t to the mandatory23.4.1 registration owner. Existing interpreted context1.3 is next, then independent Rust/Dart/Julia/safe Lua rollout; direct computed calls/full admission remain separate.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.1.3`
  Status: `completed` / existing supported path preserved
  Goal: Independently assess already-supported Perl interpreted copy paths against the approved scalar target.
  Dependencies:4.2.2.1.2.
  Acceptance: Public producer-first literal/callable invocation controls establish existing free/receiver copy vocabulary before changes. CodeblockRuntime already routes free copy through _copy_value; do not infer a defect or ordinary shallow-depth promise from that source pointer. Preserve current invocation/origin/context/depth behavior and malformed signatures. Fix only actual scalar/result drift; add no new deferred vocabulary. Close as preserved if existing supported paths are healthy; full contexts remain23.4.
  Planned verification tier: focused
  Planned focused checks: Named safe native/fresh copy/input/result/source/malformed/origin controls and relevant component checks only; no full callable/write matrix.
  Planned canonical trigger: Complete copy/context/portable admission23.4 after feature coverage.
  Planned claim verification: none: Deterministic finite preservation/repair controls, no completeness measurement.

  Activation: clean `637be796640fd0b5bcc9b1891d010e8d1a2b5fbf`; receiver1.2 committed/tree clean/brief0.
  Owned paths: Public native/fresh interpreted-copy regression/probe and current copy/context book/fact/task/live records; CodeblockRuntime only if an admitted-path defect is observed. Keep unsupported method vocabulary, malformed helper errors, recursive copies/origins and existing boundary guards; do not derive identity solely from equal JSON or masked invocation copies.
  Verification tier: `focused`
  Focused checks: Finite public native/fresh interpreted free-copy primitive kinds, source snapshots/errors, scalar-result guards, method-vocabulary and callable-origin controls; changed/new source syntax and direct deferred-boundary test, book/history/continuity.
  Canonical trigger: Full source/context/portable/admission23.4 and final clean push after feature coverage; independent backends follow Perl.
  Claim verification: none: Deterministic finite preservation/repair controls, no completeness measurement.

  - [x] **REPRODUCE / ISSUE**: Public native/fresh t/value_copy_interpreted.t independently assesses explicit deferred invocation before any runtime edits. Supported free copy already preserves primitives/null; method copy and malformed free arity retain unknown_helper/copy. No scalar-copy defect was observed in this admitted free-helper path; do not invent a runtime repair.
  - [x] **ROOT CAUSE (WHY + WHERE)**: CodeblockRuntime::_eval_call(copy) dispatches valid one-source values to _copy_value, retaining scalar flags and JSON Boolean kind. Existing Array/Hash recursion and body-AST origin inheritance differ from ordinary shallow copying. _eval_fluent_chain has no copy vocabulary; actual public rejection confirms that boundary. Returned equal containers alone cannot establish producer depth because invocation/container boundaries also copy.
  - [x] **FIX**: Preserve runtime bytes and freeze the existing path with a finite regression/current context documentation. Add no deferred method/helper vocabulary or change malformed signature, wrong-kind take, depth, invocation or origin policies. Ordinary function/receiver implementation remains in committed1.1/1.2.
  - [x] **ADDRESSED (verified)**: t/value_copy_interpreted.t PASS10 top-level tests/subtests on native/fresh. Bool/Number/String/Unicode/empty/null/missing, named/logical/numeric/selected values, source snapshot0!/7/2, wrong-Array count suppression/S and typed Number write/String harray-conflict controls pass. Original and() arity fields/zero operands, malformed free signature, unavailable receiver copy and copied-callable codeblock_recursion_unsupported remain explicit controls.
  - [x] **NO REGRESSION**: Direct t/computed_selection_deferred_boundary.t PASS22 retains raw1/not-ready and original raw_perl rejection, ordinary/inline/named reads and grammar-scope restoration. New test syntax/book/history/fast staged continuity pass. No runtime changes, full callable/write matrix, full CI or complete context/portable admission.
  - [x] **LOCKSTEP**: Context qualifiers in public book/catalog, copy target/canonical facts/map, roadmap/task/live/resume align. New test registration is owned by23.4.1. All bounded Perl producer/receiver/context children are complete; independent Rust2 follows after this commit. Full admission and queued direct computed calls remain separate.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.2`
  Status: `completed`
  Goal: Independently assess and complete Rust scalar/null value-copy function and receiver behavior.
  Dependencies:4.2.2.1; ADR0138/copy-value-preservation.md.
  Acceptance: Preserve Bool/Number/String/null kinds, named/literal/selected/block/function/prior-result/scoped flows, source-once/snapshots and compatible continuations. Reject incompatible container consumers before operands after valid prefix effects. Keep receiver shapes, free malformed-signature behavior, current container depth/detachment and callable-origin/context/serialization bounds. Observe own producer/method behavior before changes; update old scalar expectations only under explicit approved target. Safe Lua uses only named PUC5.5.1/LuaJIT fixtures/loadfile, no unsafe patterns/full runner/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Strict finite native/generated kind/value/order/shape/result RED/GREEN where needed and direct copy/scalar-result compatibility plus changed compile/format checks; book/history/continuity only.
  Planned canonical trigger: Complete source/context/portable/copy admission23.4 and final clean push after feature coverage.
  Planned claim verification: none: Deterministic authored feature/preservation controls, no population/completeness measurement.

  Activation: clean `54ec394387b658c0a2f707280883c2ba1d94785d`; bounded Perl children committed/tree clean/brief0.
  Owned paths: Rust engine copy/helper/actual-result routes, finite native/restored/generated-plan regression/shared value-copy source and superseded scalar expectations, current copy book/facts/task/live continuity. Preserve rule accumulator reads, callable copy domain, malformed signatures, recursive container clone/serialization and source effects before code. Split before a larger context/dispatcher change if needed.
  Verification tier: `focused`
  Focused checks: Independent Rust producer/method/actual-kind native/restored/plan RED/GREEN, source/shape/snapshot/typed selector/container/legacy controls, direct copy/logical-result checks and changed Rust format/compile; book/history/continuity. No full suite/matrix.
  Canonical trigger: Full source/context/portable/admission23.4 and final clean push after feature coverage; Dart3 follows.
  Claim verification: none: Deterministic finite authored feature/preservation controls, no completeness measurement.

  - [x] **REPRODUCE / ISSUE**: New public Rust value_copy native/restored/generated-plan baseline observes nested_write_segment_invalid/actual_kind array at copy(0), and wrong-container copy consumers return[]/[1]/AKV rather than null/null/no effects. Malformed receiver pre-effect control passes. Native/restored legacy rule array control passes; its initial generated harness supplied only Top for a two-rule spec, so the harness was corrected to derive every actual fixture row (static API labels), not classified as a runtime defect.
  - [x] **ROOT CAUSE (WHY + WHERE)**: engine call_helper_with_args(copy) falls back from primitive values to array/hash target lookup. Initial copy infers a container family; selected scalar results reject copy, and the with/logical route explicitly rejects scalar copying. Dynamic copy consumers lack an actual-kind boundary, so incompatible operands execute. Existing source diagnostics and root malformed-method preflight remain healthy.
  - [x] **FIX**: Valid one-source primitive copy clones the captured RuntimeValue without lookup/conversion; retain no-source/extra-argument and Codeblock fallback branches. Make copy a generic typed receiver method, remove obsolete copy-family lookahead/next-call argument and transfer copy continuations to a dedicated actual-kind dispatcher. Preserve unrelated selected-result policies; with/traversal prefixes track copied results and drop only the approved scalar-copy rejection. Keep recursive container clone/type/format/callable domains unchanged.
  - [x] **ADDRESSED (verified)**: Shared value_copy_values.spec/json and value_copy.rs PASS6 on native/restored/generated-plan routes: primitive kinds/names/literals/prior results/default recovery, SR guards,0!/7/2 snapshots, function locals, containers, Number write success/String harray conflict, incompatible Array/Hash operand suppression, malformed receiver/free policies, literal StringTop preservation and legacy rule accumulator copies. Only the old receiver text/missing and with/logical scalar-copy expectations advance under ADR0138.
  - [x] **NO REGRESSION**: Final focused Cargo selection PASS15: value_copy6, receiver_copy_arity1, logical_receiver_methods7 and selected_value_receivers1. This compiles changed Rust surfaces; rustfmt check and book/history/fast staged continuity pass. Existing logical typed source error/native-restored-plan controls retain code/helper/arity; no full suite, new standalone-crate proof or complete context/portable admission.
  - [x] **LOCKSTEP**: Shared fixture/new test, current catalog/Perl-context qualifiers/copy target, canonical generic/Rust copy fact/map, roadmap/task/live/resume align. Historical scalar observations remain historical. Dart3 independently assesses next; Julia4/safe Lua5 and full23.4 admission/canonical registration/pressure repair remain separate.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.3`
  Status: `pending`
  Goal: Independently assess and complete Dart scalar/null value-copy function and receiver behavior.
  Dependencies:4.2.2.2; ADR0138/copy-value-preservation.md.
  Acceptance: Preserve Bool/Number/String/null kinds, named/literal/selected/block/function/prior-result/scoped flows, source-once/snapshots and compatible continuations. Reject incompatible container consumers before operands after valid prefix effects. Keep receiver shapes, free malformed-signature behavior, current container depth/detachment and callable-origin/context/serialization bounds. Observe own producer/method behavior before changes; update old scalar expectations only under explicit approved target. Safe Lua uses only named PUC5.5.1/LuaJIT fixtures/loadfile, no unsafe patterns/full runner/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Strict finite native/generated kind/value/order/shape/result RED/GREEN where needed and direct copy/scalar-result compatibility plus changed compile/format checks; book/history/continuity only.
  Planned canonical trigger: Complete source/context/portable/copy admission23.4 and final clean push after feature coverage.
  Planned claim verification: none: Deterministic authored feature/preservation controls, no population/completeness measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.4`
  Status: `pending`
  Goal: Independently assess and complete Julia scalar/null value-copy function and receiver behavior.
  Dependencies:4.2.2.3; ADR0138/copy-value-preservation.md.
  Acceptance: Preserve Bool/Number/String/null kinds, named/literal/selected/block/function/prior-result/scoped flows, source-once/snapshots and compatible continuations. Reject incompatible container consumers before operands after valid prefix effects. Keep receiver shapes, free malformed-signature behavior, current container depth/detachment and callable-origin/context/serialization bounds. Observe own producer/method behavior before changes; update old scalar expectations only under explicit approved target. Safe Lua uses only named PUC5.5.1/LuaJIT fixtures/loadfile, no unsafe patterns/full runner/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Strict finite native/generated kind/value/order/shape/result RED/GREEN where needed and direct copy/scalar-result compatibility plus changed compile/format checks; book/history/continuity only.
  Planned canonical trigger: Complete source/context/portable/copy admission23.4 and final clean push after feature coverage.
  Planned claim verification: none: Deterministic authored feature/preservation controls, no population/completeness measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.5`
  Status: `pending`
  Goal: Independently assess and complete safe Lua scalar/null value-copy function and receiver behavior.
  Dependencies:4.2.2.4; ADR0138/copy-value-preservation.md.
  Acceptance: Preserve Bool/Number/String/null kinds, named/literal/selected/block/function/prior-result/scoped flows, source-once/snapshots and compatible continuations. Reject incompatible container consumers before operands after valid prefix effects. Keep receiver shapes, free malformed-signature behavior, current container depth/detachment and callable-origin/context/serialization bounds. Observe own producer/method behavior before changes; update old scalar expectations only under explicit approved target. Safe Lua uses only named PUC5.5.1/LuaJIT fixtures/loadfile, no unsafe patterns/full runner/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Strict finite native/generated kind/value/order/shape/result RED/GREEN where needed and direct copy/scalar-result compatibility plus changed compile/format checks; book/history/continuity only.
  Planned canonical trigger: Complete source/context/portable/copy admission23.4 and final clean push after feature coverage.
  Planned claim verification: none: Deterministic authored feature/preservation controls, no population/completeness measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.4`
  Status: `completed`
  Goal: Select the next independent ordinary fluent feature while copy-domain4.2.2 awaits the director.
  Dependencies: Logical family23 all five bounded children targeted-checked; copy authority intake4.2.1 complete.
  Acceptance: Use current helper/signature/receiver inventory and canonical facts; assess public reference before inferring a missing feature or backend defect. Own a bounded family/producer repair and frozen target before changes. Do not change scalar-copy domains without the requested decision. Preserve feature-first focused checks/docs/commit cadence; full admission/context/matrices remain separate.
  Planned verification tier: focused
  Planned focused checks: Exact public producer/receiver probes and changed documentation/continuity only; no full CI or registry audit.
  Planned canonical trigger: Actual contract movement/full family admission and final clean push after ordinary feature coverage.
  Planned claim verification: none: Deterministic feature selection, no population/completeness measurement.

  Activation: clean `d98e139d712cb28a9b4c5bb1504a43e5c8fd13b1`; copy authority review committed/tree clean/brief0.
  Owned paths: Public computed-value read-selection probe/target and task/book/fact/live continuity; no production change in selection. Reconcile existing value_access versus bare-binding access and grouping owner87.4; do not expand mutation/grouped syntax or copy domains implicitly.
  Verification tier: `focused`
  Focused checks: Canonical typed read/signed-selector and existing value_access contracts, public Perl Get/substitution/native/fresh comparisons against equivalent intermediate-binding controls; source syntax/book/history/staged continuity. No broad matrix or full CI.
  Canonical trigger: Full input/context/portable and new surface admission remain23.4 after feature coverage; any actual generated-format movement must be owned explicitly before code.
  Claim verification: none: Bounded normative feature selection and deterministic authored public controls, no population/completeness measurement.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Named signed/typed control Get/fresh values B/[true,1,0!,missing,B] pass; five computed-source forms fail both routes, with native rule_handler_compile and matching fresh raw bracket syntax errors. Retain exact observations, never classify these as successful null reads.
  - [x] **ROOT CAUSE (WHY + WHERE)**: Perl AST parse order has binding-based access/fluent call segments but no general typed value_access; MethodLowering's special callable-result bridge is narrower. Other runtimes carry value_access with restricted source shapes; no inferred runtime failure there.
  - [x] **FIX**: Freeze computed-selection.md additive read-only target and shared authored value/effect fixture; own24.1-.5 independent backend work, Perl first. Preserve grouping87.4, lvalues, dynamic-key/coercion, copy-domain/depth, callback/deferred/context and actual schema boundaries.
  - [x] **ADDRESSED (verified)**: Public controls and RED classification asserted from actual routes; diagnostic probe syntax passes. Existing read/signed/type authorities establish expected admitted subset and source/selector ordering; no new portable runtime support claimed.
  - [x] **NO REGRESSION**: No production/grammar/serialized artifact or previous expectation edits. Existing named-binding lookup order, callable provenance and snapshot/copy semantics stay; complete matrices/canonical admission deferred.
  - [x] **LOCKSTEP**: Frozen target/fixture/retained probe-observations/planned-only book qualification/new causal fact/map/roadmap/task/live pointer align. Perl24.1 next; copy decision4.2.2 remains owned/open rather than silently selected.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.4 - define computed-value bracket selection`.

- ID: `TYPE-REFERENCE-BOOK.1.2.2`
  Status: `pending`
  Goal: Map the complete reconciled operation/spelling population to actual book coverage and proposed canonical per-type homes.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1`, `TYPE-REFERENCE-BOOK.1.2.23`
  Planned tier: `focused`; reclassify before public/mechanical movement.
  Claim verification: none: Unactivated coverage mapping; declare complete source/book evidence before measurement.
  Acceptance: Retain exact current entries/anchors/includes/examples/backend qualifications for every inventory item, mark precise depth/navigation gaps, preserve old anchors and schedule bounded family work. Close .1.2 only after all inventory children agree; independent layout review .1.3 follows. No exhaustive public-reference coverage claim from an inventory closeout.

- ID: `TYPE-REFERENCE-BOOK.1.2.23`
  Status: `active` / bounded ordinary families1-22 targeted-checked; logical counterparts selected
  Goal: Establish comprehensive fluent method families for every supported type and complete inter-type chaining.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1`
  Children: `TYPE-REFERENCE-BOOK.1.2.23.1`, `TYPE-REFERENCE-BOOK.1.2.23.2`, `TYPE-REFERENCE-BOOK.1.2.23.3`, `TYPE-REFERENCE-BOOK.1.2.23.4`.
  Schedule: Director's comprehensive-method requirement plus current feature-first steering selects the concrete first/last result transition before exhaustive inventory/matrix completion. Freeze that bounded contract, then implement native children; full inventory, transition matrix and final admission remain parent closeout dependencies. Do not resume superseded Rust17.3 work.
  Acceptance: Assess useful semantic operation families as well as implemented names. Own and resolve missing fluent operations/transitions before declaring a type complete. Dispatch each chain continuation by its returned value's actual type; preserve container element types, mutation/detachment, callback/error/empty behavior and backend limits. Do not invent a new type or meaningless method merely for symmetry.
  Planned tier: Select per child; new public methods/contracts and final admission require canonical proof.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1`
  Status: `active` / bounded remaining-feature selection child; full matrix open
  Children: `.23.1.1`, `.23.1.2`, `.23.1.3`, `.23.1.4`.
  Goal: Build the per-type fluent coverage and gap matrix from the complete inventory and project use cases.
  Acceptance: Cover the actual scalar/string/numeric, array, harray, boolean/null and codeblock model, generic versus type-specific operations, meaningful free-helper/receiver counterparts, signatures, accepted inputs, return/element types, mutation/identity, empty/missing/error and backend boundaries. Identify required method-family gaps explicitly; a registered-name count is insufficient. Split new implementation work before writes.
  Planned tier: Focused source/contract audit; declare measurements at activation.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.1`
  Status: `completed`
  Goal: Select the next missing ordinary fluent family from canonical helper/role inventory after bounded result families1-20.
  Dependencies: .23.3.20.3.
  Acceptance: Read retained spelling/role/source inventory and the relevant current contract/book, reconcile remaining operation families with committed bounded result work, choose a small roadmap-aligned feature and create its owning leaf before production. Use public tooling only for missing distinctions; no full suite/matrix/coverage measurement or assumption that every helper needs a method. Preserve deferred/context/control exclusions and prior open defect ownership. Feature-first focused checks/docs/commit.
  Planned verification tier: focused
  Planned focused checks: Targeted canonical inventory/contracts/book and any small distinguishing public observation necessary for selection; normal continuity.
  Planned canonical trigger: Full input-domain/context/portable admission and final clean push remain separate.
  Planned claim verification: none: bounded feature selection, no aggregate completeness/population measurement.

  Activation: clean `7222ff78668d6fd08ee0dc448d1c8bb4d3da9855`; all bounded optional slice repairs committed, brief0/tree clean.
  Selection: Retained helpers.md and current array-tree-traversal-contract/catalog show reduce_leaves(initial) returns an actual accumulator but is deliberately terminal, unlike already extensible mapped/walked containers. Assess this bounded useful result transition as a feature addition, not a producer defect. Preserve receiver-only traversal, Array/Hash root-kind rules/callback scope/order/copy/restoration, invalid-root/shape precedence and existing callback errors. No blanket free helper/codeblock method promotion or complete fluent matrix claim.
  Owned paths: Small public Perl native/fresh reduction producer/nested/fluent/source/shape/effect distinctions with AST/substitution/dump as needed, frozen bounded reduction-result contract and per-backend scheduling if justified, relevant traversal book/fact/map and task/live continuity. No production before the feature target is frozen/committed.
  Verification tier: `focused`
  Focused checks: Canonical role/traversal records/book, public producer-first native/fresh small distinguishing controls and syntax, book/history/staged continuity guards; no full runtime matrix.
  Canonical trigger: None for bounded feature selection under director feature-first cadence; full signature/context/portable admission/final clean push separate.
  Claim verification: none: normative feature selection and deterministic authored distinctions; no aggregate coverage/population measurement.

  Frozen target: reduction-result-continuations.md extends existing receiver-only terminal reduction to compatible consumers of its actual accumulator. Existing Array/Hash traversal rules, source/initial/callback order/copy/scope restoration, invalid-root/shape precedence and callback/mutation/free domains remain unchanged. Schedule independent backend21.1-.5; no full matrix/completeness claim.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Perl native/fresh producer results[6,ab,[1,2,3],{key:B},false,null,[empty],3] and nested num_add result7 already work. Appended numeric/Array/Hash consumers give null. Healthy source capture is[3,SILL,1,[9]]; appended cat gives[null,empty,0,[1,2]]. Scalar root[null,S] skips initial/callback; malformed zero/two initials[null,null,empty] skip all effects.
  - [x] ROOT CAUSE (WHY + WHERE): Public AST retains callback/add link, while substitution is return undef. MethodLowering tree return classification/lowered result pair and Hash receiver metadata explicitly mark reduce_leaves terminal. Appended coalesce independently bypasses dedicated traversal in emitted-default flow and leaks raw DSL to compilation; the same actual-result extension must own this boundary.
  - [x] FIX: Freeze bounded actual final accumulator transitions and precise order/copy/shape/domain boundaries; schedule Perl21.1, Rust21.2, Dart21.3, Julia21.4, safe Lua21.5 before production. No producer/callback/root traversal change or new free helper follows from name discovery.
  - [x] ADDRESSED (verified): Retained native/fresh public producer/nested/fluent/effect/invalid/shape distinctions support the target independently of source guesses. Dedicated callback scope/root records and current catalog align. Existing terminal behavior remains current until each backend implementation is targeted-checked.
  - [x] NO REGRESSION: Production unchanged; retained probe syntax and public healthy source/null/empty/Bool/Array/Hash/numeric/String controls pass native/fresh. Book demonstrates the already working nested consumer workaround; no full gate/context/deferred/standalone/portable admission.
  - [x] LOCKSTEP: Frozen contract/probe and canonical traversal fact/map, current book terminal guidance, TYPE/SESSION/live/resume align; book/history/diff/final staged memory/cadence/diagnosis checked before commit. Perl21.1 first; comprehensive23.1 matrix remains open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.1 - select reduction result continuations`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.2`
  Status: `completed`
  Goal: Select the next ordinary fluent feature after bounded data-result and reduction families through21.
  Dependencies: .23.3.21.5.
  Acceptance: Reconcile remaining String/Array/Hash-producing helper and wrapper roles from retained helpers.md, canonical contracts/book and current fact cards against implemented useful methods. Resolver categories are not input types or method admission. Select a small meaningful missing family/transition from the actual contracts, use public producer/result distinctions only if needed, and own/freeze its implementation before production. Do not promote constructor/list-splice, control, parser-state, callback/deferred or mutation-only roles by spelling alone. No exhaustive coverage claim or full matrix; keep error-signature/pressure/admission owners explicit and feature-first focused cadence.
  Planned verification tier: focused
  Planned focused checks: Targeted canonical role/domain/method records and small public distinctions needed for next selection, current book/normal continuity.
  Planned canonical trigger: Full signature/context/portable/doctrine admission and final clean push remain separate.
  Planned claim verification: none: bounded normative feature selection and authored distinctions, no aggregate completeness/population measurement.

  Activation: clean `f7e06ce7422b36e0790f399ed7bd3759830852bf`; all bounded reduction21 children committed, brief0/tree clean. Error-phase1.2.1.4.1 and broader pressure1.2.20.1 remain scheduled before admission; no policy migration pivot.
  Owned paths: Targeted remaining helper-domain/wrapper/method selection and any small public producer/result distinctions, frozen next feature scheduling before production, scoped current book/fact/map/task/live continuity. Read count-length-results.md: it explicitly preserves existing invalid-domain helper behavior and establishes no universal wrong-kind policy, so do not silently recast those older exclusions as defects. Prioritize useful positive result/method transitions; assess split_tagged_records roles/current facts before assuming its resolver category is its input type.
  Verification tier: `focused`
  Focused checks: Canonical spelling/role/producer domains/book and small public native/fresh distinguishing controls, source syntax/book/history/staged memory/cadence/diagnosis only; no broad matrix/global registry replay.
  Canonical trigger: None for ordinary bounded feature selection under director feature-first cadence; full domain/context/portable/admission pressure and final push remain separate.
  Claim verification: none: normative selection and authored distinctions, no aggregate completeness/population measurement.
  Owned teaching defect: Array pipeline reference still says Rust scalar-null61.1/.2 remain open beyond trim, while committed startup/current String19 facts show both bounded source/operand repairs implemented. Correct this stale current qualification to the still-open complete domain/context admission; preserve old chapter bytes at activation Git, without replaying old whole suites.

  Frozen target: tagged-record-string-bridge.md repairs the already-documented scalar text-to-tagged-Array transition. Existing helper fields are ordinary eager operands, not per-row callbacks; Perl22.1.1 first materializes arguments once and reuses its admitted pure split, then22.1.2 repairs receiver composition. Other backend22.2-.5 independently follow. String-tag/ordinary delimiter targets do not decide wider source/tag conversion, empty/zero-width/variable-regex policy or SESSION33 full admission.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Perl native/fresh basic helper returns two records with numeric/Array fields and healthy later DSL copy independence. Literal/named receiver tails instead call an undefined host split_tagged_records, while trim-prefix returns null. Tagged carried increment on a,b, yields only a/1,b/2/counter2 beside pure split retaining trailing empty; empty source counter0 confirms arguments skipped when no rows.
  - [x] ROOT CAUSE (WHY + WHERE): Toolbox substitution retains raw receiver DSL; the documented input is text despite Array producer/dispatcher categorization. Tagged expansion places field effects inside map, omits pure split's trailing -1 and leaves eager delimiter/tag block DSL unlowered. These reproduce SESSION33's known basic issue rather than establishing a new global split policy. The Array reference's Rust61.1/.2 current-open qualification is also stale after committed repairs.
  - [x] FIX: Freeze current documented eager argument/record/method behavior and producer-before-receiver children, preserve current conversion/pure-split domains and broader33 review. Qualify the currently broken Perl teaching rather than declaring target examples already portable; correct stale Rust source-null progress wording. No production in this assessment.
  - [x] ADDRESSED (verified): Retained primary producer/receiver/derived/named/field-empty/trailing/eager-block/copy distinctions run native/fresh and show exact mechanism/source; healthy copying is retained. Existing helper/reference, Lua tagged contract, normal eager value rules and authoritative33 source/index are read; needed basic repairs are owned before implementation.
  - [x] NO REGRESSION: Production unchanged; probe syntax and healthy direct record/copy controls pass. Count-like invalid-domain exclusions remain explicit, with no policy normalization. No CLI rebuild/full six-runtime boundary matrix/old oracle rewrite or complete type-family admission.
  - [x] LOCKSTEP: Frozen target/probe, current tagged/Rust teaching qualifiers, canonical tagged fact/map and TYPE/SESSION33/root/index/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit; broad pressure FAIL20.1 remains owned, no global-gate receipt. Perl22.1.1 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.2 - freeze tagged-record String bridge repairs`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1.3`
  Status: `completed`
  Goal: Select the next meaningful ordinary fluent family/transition after bounded data-result, reduction and tagged-record families1-22.
  Dependencies: .23.3.22.5.
  Acceptance: Reconcile retained helper/wrapper/receiver roles, current canonical facts/contracts/book and ordinary exclusions against implemented bounded families. Choose a useful missing operation/transition without treating resolver output category as input type, reviving compatibility spellings or inventing meaningless symmetry. Small independent public producer-first distinction as needed; freeze one safe target and schedule backend leaves before production. Full type/context/domain matrix/admission, error parity and pressure maintenance stay separately owned.
  Planned verification tier: focused
  Planned focused checks: Targeted canonical inventory/contracts/book and small distinguishing public observation, syntax/book/history/staged continuity. No full suite/population census or historical replay campaign.
  Planned canonical trigger: Full domain/context/portable admission and final clean push remain separate under director feature-first cadence.
  Planned claim verification: none: normative bounded feature selection and authored examples; no population/completeness measurement.

  Activation: clean `27dba179f410218b487f147adf31fac1b6ea54fe`; all bounded tagged-record children committed/tree clean/brief0.
  Selection candidate: The retained logical-results.md explicitly excludes .and/.or/.not counterparts while preserving eager free helpers under ADR0043. Assess useful ordinary receiver counterparts as a distinct Boolean/generic truthiness family; do not change source helper arity/eagerness/result kinds or absorb lazy controls/callback admission.
  Owned paths: Small public Perl producer/native/fresh receiver/typed-truth/eager/snapshot/shape distinctions, frozen bounded logical-method target and backend scheduling if justified, affected logical facts/current book/live continuity. Production follows separate owned leaves.
  Verification tier: `focused`
  Focused checks: ADR0043 and neutral logical-helper policy/helper cases, canonical role inventory/current book, small public Get/runtime_ctx_ref/substitution/native/fresh distinction and syntax/book/history/staged continuity. No broad matrix/history campaign.
  Canonical trigger: New method/domain/context/portable admission and final canonical push remain23.4 after feature coverage, including signature parity/canonical registration/pressure repair. Director small-check implementation cadence governs ordinary leaves.
  Claim verification: none: normative bounded feature selection and deterministic authored controls; no population/completeness measurement.

  Frozen target: logical-receiver-methods.md deliberately adds useful .and(rhs,...)/.or(rhs,...) and .not() counterparts as generic truth operations. Method and/or minimum one authored RHS expresses composition; unchanged free and(value)/or(value) retain unary Boolean projection. Real Bool, eager typed truth, snapshots, actual-result transitions and current ordinary malformed/no-effects policy; no new lazy/deferred/callable/context/bang vocabulary. Family23.3.23 owns independent backend implementations before writes.
  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Public LinkedSpec::Get/runtime_ctx_ref/native and fresh emitted controls confirm real Bool free producers; well-shaped logical input methods leak .and/.or/.not raw DSL and fail. Longer not/coalesce loads but fails through an undefined host coalesce. Substitution retains the exact unsupported prefixes.
  - [x] **ROOT CAUSE (WHY + WHERE)**: Existing MethodLowering receiver admission/family tables omit ordinary logical input methods, while typed free logical ownership is healthy. Result17 expressly excluded counterparts; resolver control registration does not admit a receiver or imply lazy semantics.
  - [x] **FIX**: Freeze logical-receiver-methods.md generic input/Bool output/eager shape/snapshot/result rules and schedule Perl/Rust/Dart/Julia/safe Lua23.1-.5. Preserve free helper contract/typed diagnostics and lazy control domains.
  - [x] **ADDRESSED (verified)**: Diagnostic native/fresh producer exact JSON/kinds and well-shaped receiver rejection assertions PASS; retained producer/method/typed/order/snapshot/shape source evidence supports independent targets. New methods remain planned until backend implementation; no false support claim.
  - [x] **NO REGRESSION**: Production unchanged; probe perl -c and healthy public free producers pass. No neutral logical-helper JSON, registry, truth, conversion, serialization or old oracle data modified; full matrix/admission stays separate.
  - [x] **LOCKSTEP**: Frozen contract/public probe/current book planned-only qualifier/roadmap/neutral logical fact/map/task/live pointer align. Child leaves own all production; known canonical registration/error parity/pressure and declared Lua5.4 prerequisites remain scheduled.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.1.3 - freeze eager logical receiver counterparts`.

  Associated continuity defect owned/resolved: SESSION root still named completed Perl22.1.1 as pending; its only cross-tree table row also failed the existing startup stable-child/status schema. Focused perl scripts/check_startup_task_partitions.pl observes RED root frontier lacks a stable child/status row. This root duplicated changing TYPE status even though MEMORY/TYPE are authoritative; restore own pending33.1 status row (confirmed in mutable part), route the changing feature leaf solely through MEMORY/TYPE and retain dated prior bytes. Partition snapshot refreshed and the same focused validator GREEN after RED; no broad containment/CI detour or immutable history edit. Canonical targeted-session-startup fact records the stable routing rule.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2`
  Status: `active` / bounded selection contract; full matrix remains open
  Children: `TYPE-REFERENCE-BOOK.1.2.23.2.1`, `TYPE-REFERENCE-BOOK.1.2.23.2.2`, `TYPE-REFERENCE-BOOK.1.2.23.2.3`, `TYPE-REFERENCE-BOOK.1.2.23.2.4`, `TYPE-REFERENCE-BOOK.1.2.23.2.5`, `TYPE-REFERENCE-BOOK.1.2.23.2.6`, `TYPE-REFERENCE-BOOK.1.2.23.2.7`, `TYPE-REFERENCE-BOOK.1.2.23.2.8`, `TYPE-REFERENCE-BOOK.1.2.23.2.9`, `TYPE-REFERENCE-BOOK.1.2.23.2.10`, `TYPE-REFERENCE-BOOK.1.2.23.2.11`, `TYPE-REFERENCE-BOOK.1.2.23.2.12`, `TYPE-REFERENCE-BOOK.1.2.23.2.13`, `TYPE-REFERENCE-BOOK.1.2.23.2.14`, `TYPE-REFERENCE-BOOK.1.2.23.2.15`, `TYPE-REFERENCE-BOOK.1.2.23.2.16`, `TYPE-REFERENCE-BOOK.1.2.23.2.17`, `TYPE-REFERENCE-BOOK.1.2.23.2.18`, `TYPE-REFERENCE-BOOK.1.2.23.2.19`, `TYPE-REFERENCE-BOOK.1.2.23.2.20`
  Goal: Define and verify the result-type transition matrix and cross-type fluent contracts.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.1`
  Acceptance: Include the director's string -> regex split -> array<string> -> array methods -> selected string -> string methods journey, plus supported conversion/collection/callback results that return another family. Specify regex/Unicode/empty/no-match behavior, indexing or extraction, dynamic returned types, side effects and wrong-type rejection. A continuation must use the current returned value; do not retain the chain's original receiver family or silently stringify it.
  Planned tier: Select from actual contract scope; freeze new public authority before code.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.1`
  Status: `done`
  Activation commit: `122da1d88acae6fc4412f2a31fef5d8314776ef3`
  Goal: Freeze the bounded ordinary first/last selected-value continuation contract before code, using existing helper semantics and the director's exact inter-type journey.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1.2.1`
  Owned paths: docs/checkpoints/type-operation-inventory/selected-values.md; current array book/fact/map and TYPE/live continuity.
  Verification tier: `focused`
  Focused checks: Canonical existing first/last/string/numeric/container signatures and public Get/substitution distinction; book build and fast continuity/history checks only. No runtime census.
  Canonical trigger: None for planning/freeze of this bounded feature under director feature-first phase; portable/public implementation admission remains with23.4 after feature coverage.
  Claim verification: none: Normative selected-value contract and qualitative observed Perl gap, no implementation/parity/completeness measurement.
  Reproduce: Public Get returns [null,"A",null] for [" a :b ".split(":").first().trim().uppercase(), uppercase(trim(first(split(" a :b ",":")))), [" A "," B "].last().trim().lowercase()]. Substitution emits undef for both receiver journeys while the nested helper control works without last_error.
  Root cause: MethodLowering's array chain return-family callback marks every non-array-returning method terminal, including first/last, and the string/array fluent loops stop before the next compatible family. This is the requested extraction-to-result-method gap, not a missing trim/uppercase implementation.
  Acceptance: Specify selection result kinds, source/argument evaluation, inherited wrong-kind/null/empty/copy behavior and pure continuation limits. Schedule bounded per-backend implementation children. Preserve full matrix/admission as open, with no new type or unsupported mutation/callback promise.

  Completion: selected-values.md freezes first/last selection into existing compatible pure string/number/array/harray helper semantics, with null/invalid/effect/copy limits inherited from nested equivalents. It names expected journeys without claiming current cross-backend support. Perl implementation23.3.1.1 is next, with separate backend children and broad admission deferred.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Public Get and substitution distinguish failing fluent first/last string journeys from a working nested helper result, with no runtime error.
  - [x] **ROOT CAUSE (WHY + WHERE)** — MethodLowering's array return-family classification and fluent-loop terminal guards stop the extraction result before its next compatible method.
  - [x] **FIX** — Freeze the bounded normative contract and explicit implementation schedule before code; no runtime repair claimed in this leaf.
  - [x] **ADDRESSED (verified)** — Contract examples/limits agree with existing helper signatures, and book render plus fast continuity checks PASS.
  - [x] **NO REGRESSION** — No runtime/schema/type change; mutation/callback admission, existing helper domain policies and full matrices stay separately owned.
  - [x] **LOCKSTEP** — Book discloses current Perl gap/workaround, canonical array fact/map and live frontier name the contract and next backend leaf. No portable implementation completeness claim.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.1 - define selected-value receiver continuations`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.2`
  Status: `done`
  Activation: clean `b6f7029bc218d5dac33a92345a6584e7fd1a8869` after bounded scalar/default/copy implementations.
  Public finding: Perl returns [null,5,null,6] for fluent count/length addition beside working nested controls, without last_error; public substitution emits return undef for both chains.
  Hash-count intake correction: The failed combined control did not establish a free-helper defect. Five isolated public Get/substitution controls show meta.count_keys(), count_keys(meta), literal count_keys and num_add(meta.count_keys(),3) work (2/2/2/5). Only meta.count_keys().add(3) fails, retaining raw DSL and reaching an undefined host subroutine. The earlier free-helper attribution is rejected; this is a count_keys continuation gap in the same bounded feature, with no separate free-helper repair.
  Goal: Probe and freeze bounded count/count_keys/length numeric-result receiver continuations before implementation.
  Owned paths: docs/checkpoints/type-operation-inventory/count-length-results.md, public helper reference, canonical array fact/map and TYPE/live continuity.
  Schedule: Next feature-first selection after scalar/default helper repairs; precede exhaustive signature/matrix work with a concrete source-backed inter-type journey, as23.2.1 did for first/last.
  Reproduce at activation: For values=[1,2], compare values.count().add(3) with num_add(count(values),3), and "abcd".length().add(2) with num_add(length("abcd"),2). Nested controls should return5/6; establish actual fluent outcomes publicly before claiming a defect.
  Verification tier: `focused`
  Focused checks: Public Perl Get/substitution distinctions for array/string/hash counts, existing helper and selected-value authorities, book build and fast continuity/history/diff guards. No runtime census.
  Canonical trigger: None for freezing this bounded feature under director feature-first direction, following23.2.1; implementation/portable admission stays with23.3.3/23.4 after feature coverage.
  Claim verification: none: Normative count/length contract and qualitative observed Perl gap, no implementation/parity/completeness measurement.
  Acceptance: Define count/count_keys/length results feeding existing compatible pure scalar/number methods, actual value identity, once-only source/argument evaluation and inherited null/domain/error rules. Explicitly reconcile the earlier count-terminal control as prior bounded policy. Add implementation children only after the contract/probe, commit per backend and retain comprehensive signatures/matrix, numeric reducer/boolean/control/mutation/callback scope separately.
  Completion: count-length-results.md freezes three numeric-result producers, zero-extra receiver arity, existing pure consumer/domain/copy rules and direct/selected/pipeline targets before code. Perl .23.3.3.1 is next; other backends require individual assessment.
  Acceptance Checklist:
  - [x] REPRODUCE / ISSUE: Public Get/substitution confirms count/length chains stop beside working nested5/6 controls. Isolated hash probes distinguish a raw chained-count host-call failure from working single-step/free count_keys controls; reject the initial incorrect free-helper attribution.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering's array chain return-family callback and hash/string return-family functions mark count/count_keys/length terminal. Loop rejection emits null or retains hash DSL instead of feeding the numeric result to the existing consumer.
  - [x] FIX: Freeze the bounded ordinary result-flow contract, supersede the old ordinary count-terminal negative control explicitly, and schedule the confirmed Perl implementation before code. Preserve other terminal/admission boundaries.
  - [x] ADDRESSED (verified): Normative examples and limits agree with existing helper signatures and independently working controls; book and fast continuity/history checks pass before landing. No runtime repair is claimed.
  - [x] NO REGRESSION: No runtime/type/schema/format change; reducers, predicate/control outputs, deferred/callback contexts and mutation remain separately owned. No broad suite.
  - [x] LOCKSTEP: Public gap/workarounds, canonical array fact/map, task/current frontier and live handoff agree; next child names exact first-party scope. No complete fluent-family claim.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.2 - define count and length result continuations`.


- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.3`
  Status: `done`
  Activation: clean `80d9809216282d1f077e1eac1b302cd608f75ae9`.
  Goal: Publicly assess and freeze bounded ordinary aggregate numeric reducer result continuations.
  Dependencies: .23.3.3.5.
  Owned paths: type-operation-inventory contract/public diagnostic probe, helper/numeric reference including stale Count/Length family summaries, canonical reducer facts/map and task/live records; no production edit in this assessment leaf.
  Verification tier: `focused`
  Focused checks: Existing six reducer/public helper contracts, public Perl Get/substitution distinguishing fluent/nested results, book build and fast continuity/history/diff guards; no runtime census or full replay.
  Canonical trigger: None for bounded normative freeze under director feature-first phase; implementation per backend and complete portable/public admission remain separate.
  Claim verification: none: Normative bounded result contract and qualitative public observations; no quantified corpus, completeness or portable admission measurement.
  Acceptance: Read existing six aggregate helper domains and callable boundaries, compare reducer-result fluent arithmetic/string methods with nested public Perl controls, and isolate any actual gap before choosing code. Preserve min/max array/scalar overloads, null/error/source rules, argument order, copy and deferred boundaries. Freeze only meaningful existing pure consumer transitions, supersede old terminal policy explicitly, then schedule per-backend implementation children. Keep broad signatures/matrices/admission separate.
  Documentation defect / ownership: Helper catalog Array/Hash and Receiver-Dot Method Families summaries still classify ordinary count/count_keys/length as terminal despite23.3.3 implementations and corrected individual entries. Reconcile only those stale summaries to current public examples in this leaf; preserve unrelated predicate/control policies.
  Public finding: Six fluent/nested addition pairs return [null,13,null,5,null,5,null,5,null,3,null,7] with no last_error; substitution emits return undef for sum-result addition. Retained public diagnostic probe reproduces the same distinction.
  Completion: aggregate-numeric-results.md freezes ordinary pure reducer-result continuations, preserving existing source/result/overload/deferred boundaries and reducer-kind owner95. Schedule Perl23.3.4.1 first; independently assess later backends. Reconcile stale Count/Length summary rows to completed23.3.3 without changing unrelated endpoint policy.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Get/substitution and retained diagnostic distinguish six stopped fluent results from working nested helpers. Catalog family summaries contradict current Count/Length entries and targeted-checked implementations.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering's ordinary reducer preflight rejects nonfinal calls and array return-family defaults to terminal. Old book summary classifications were not advanced with individual Count/Length entries.
  - [x] FIX: Freeze the bounded reducer-result contract before production edits, explicitly supersede compatible ordinary terminal policy and schedule per-backend implementation; correct existing Count/Length summaries.
  - [x] ADDRESSED (verified): Retained public probe agrees with observed activation values; helper/overload/source-kind authorities and worked normative examples agree. Book and fast continuity/history/diff checks pass.
  - [x] NO REGRESSION: No production/schema/type change, blanket input normalization or new callback/deferred admission. Existing reducer-kind95 and comprehensive matrices/admission remain separately owned.
  - [x] LOCKSTEP: New contract/retained diagnostic, current helper reference, bounded reducer fact/map and task/live frontier identify the same next Perl slice and limitations.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.3 - define aggregate numeric result continuations`.


- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.4`
  Status: `done`
  Activation: clean `185d26ed3fcafe3a26fe367b1a542ae94241c22a`.
  Goal: Publicly assess and freeze ordinary Array join_values result continuations into existing compatible String methods.
  Dependencies: .23.3.4.5.
  Owned paths: type-operation-inventory contract/public diagnostic if needed, helper/String reference, canonical Array result facts/map and task/live records; no production edit in this assessment leaf.
  Verification tier: `focused`
  Focused checks: Existing join helper signatures/domains, public Perl Get/substitution fluent/nested and receiver snapshot/effect controls, book and fast continuity/history/diff guards; no runtime census or broad replay.
  Canonical trigger: None for bounded normative freeze under director feature-first phase; implementation per backend and complete public/portable admission remain separate.
  Claim verification: none: Normative bounded result contract and qualitative public observations; no quantified corpus, completeness or portable admission measurement.
  Public intake / owned diagnosis: Single-step joined receivers preserve snapshot/order ["a,b","SDN",["a","b","c"],"x-y",["x","y","z"]]; do not change correct producer behavior. The combined continuation/nested six-expression probe returns null with structured last_error, while direct sum-style substitution emits return undef. Isolate expressions/error fields publicly before attributing the failure; own any confirmed join result-flow/lowering defect here and schedule immediate implementation after contract freeze.
  Isolated result / attribution: Direct and selected chains return null beside nested "A,B"/"A-B" controls; only the hash-view chain raises an undefined host sorted_values call, while its nested control returns "X:Y". Public substitution retains the entire hash chain as DSL but fully lowers the nested equivalent. This is continuation lowering/fallthrough, not a free sorted_values helper defect. Preserve already-correct snapshot/order; assess exact one-delimiter shapes independently.
  Acceptance: Read existing join_values delimiter-first free/receiver signatures, source/argument/effect/null/empty and domain rules. Compare ordinary joined-result chains with nested public Perl controls, including selected/pipeline/hash-view sources, before classifying a gap. Freeze only compatible existing pure result continuations and explicitly supersede old join-terminal policy; retain invalid-shape, copy/deferred and complete admission boundaries. Schedule per-backend implementation after concrete findings; no broad matrix/replay.

  Shape findings: Missing/extra delimiter shapes fail to lower and produce handler compile errors rather than clean null/effect results. Their accepted DSL block operands use the same grammar as the working snapshot control; own clean one-delimiter shape rejection in the implementation.
  Completion: joined-string-results.md freezes actual joined String continuation, one delimiter, unchanged producer snapshots/order/domains and explicit split/length bridges. Preserve source normalization ownerFUTURE5 and dated Lua false-delimiter owner2.9. Exact copies of all three executed diagnostic producers are retained; isolated lowerings distinguish raw-DSL fallthrough from working free helpers. Schedule Perl23.3.5.1 before code.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Get/substitution isolates direct/selected stopped chains and a hash-view host error beside three working nested controls. Invalid arity emits handler compile errors; source snapshot/SDN control already passes.
  - [x] ROOT CAUSE (WHY + WHERE): append_array_chain_call marks join terminal; Array/Hash loops stop or fail to lower following consumers. Public substitution leaves the failed hash DSL intact, causing host sorted_values lookup, while the nested helper fully lowers.
  - [x] FIX: Freeze only the bounded result/one-delimiter contract and schedule implementation. Preserve correct receiver snapshots/effects, free delimiter-first roles, existing source/null/empty/copy policies and separate deferred/admission boundaries.
  - [x] ADDRESSED (verified): Retained diagnostic scripts are byte-identical copies of the executed compound/order, isolated and shape producers; normative examples and existing helper authorities agree. Book and fast continuity/history/diff checks pass.
  - [x] NO REGRESSION: No production/schema/type change or free-helper/domain normalization. Lua false-delimiter2.9, invalid sourceFUTURE5 and full context/portable admission23.4 remain separately owned.
  - [x] LOCKSTEP: Contract/public diagnostics, helper target/workaround, condensed Array fact/map and current task/live frontier identify the same next Perl implementation and limits.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.4 - define joined String result continuations`.


- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.5`
  Status: `completed`
  Goal: Assess container-valued default selections continuing through the actual returned kind.
  Dependencies: .23.3.5.5.
  Schedule: After bounded joined-result rollout, before exhaustive signatures/matrices; feature assessment, not a current-task pivot.
  Intake / latent risk: Perl String-family metadata classifies coalesce_nonempty as String, while the helper can select a container. Check whether scalar_result propagation blocks a valid later Array/Hash consumer. This is a source-backed assessment question, not an asserted runtime defect or new admission.
  Public reproduction target: Compare [].join_values(",").coalesce_nonempty(["a","b"]).join_values("-").uppercase() with the nested helper equivalent; expected actual-value flow is "A-B" if the existing helper admits that fallback. Include defined/empty/null and Hash fallback controls without assuming backend failures.
  Owned paths: bounded type-operation contract/public probes, canonical default/receiver facts and task/live planning; split production children only after findings.
  Activation: clean `949790b510f8ad29b744730ac379a8952d987d9f`; Lua split committed, brief empty, tree clean before switch.
  Verification tier: `focused`
  Focused checks: Small public Get/substitution/native/fresh assessment of documented nonempty defaults and selected Array/Hash compatibility; preserve scalar/empty/null/lazy/effect controls, syntax, book and fast continuity/history/diff checks. No full suites or cross-backend campaign.
  Canonical trigger: None for bounded diagnostic/frozen transition under director feature-first cadence; complete public/domain/portable admission remains23.4 and final clean push.
  Claim verification: none: deterministic authored diagnostic value/order examples; no quantified corpus, support/completeness or portable measurement.
  Acceptance: Establish public actual behavior and domains before classification, retain laziness/once-only effects/copy/kinds, freeze a bounded transition if needed and schedule backend repairs. Preserve current joined-result scope and complete admission as separate.

  Completion: Freeze bounded ordinary coalesce_nonempty selected-value flow in docs/checkpoints/type-operation-inventory/default-selection-results.md after public domain and nested distinctions. Existing scalar signatures stay qualified; no complete domain or cross-backend claim.
  Findings / ownership: Joined Array/Hash continuations lower to undef; nested controls return A-B/X:Y. Direct String continuation reaches a host coalesce_nonempty error. Static String/scalar_result classification blocks actual containers. Own ordinary flow as23.3.6.1.1. Separately, direct valid colon Hash fallback emits hash_literal_use_colon/null; named Hash and nested views work. Value-only AST lowering reparses lowered host fat arrows through the legacy DSL path; own P1 repair23.3.6.1.2 immediately after flow, before backend rollout. The compound first effect probe is rejected as passing evidence; isolated joined versus nested SDJ controls establish the bounded effect gap.
  Verification:
  - [x] REPRODUCE / ISSUE: Retained public probes print exact value/error/lowering distinctions for selected Arrays/Hashes, retained scalars, empty/null and lazy controls.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering return-family metadata and scalar_result propagation stop container flow. lower_ast_value_only_call_node reconstructs legacy helper input from lowered Hash host source; public marker identifies the separate literal boundary.
  - [x] FIX: Freeze the actual-kind transition and schedule separate bounded flow/literal repairs; no production change in this diagnostic slice.
  - [x] ADDRESSED (verified): Public native plus fresh emitted joined control return null beside nested A-B; fresh named Hash retains fields. Supported scalar/lazy/selected-null controls remain distinct from broken flow.
  - [x] NO REGRESSION: Probe syntax, book rendering and fast continuity/history/diff checks pass. No exhaustive suite, other-backend failure, full signature/portable or final admission claim.
  - [x] LOCKSTEP: Contract/probes, qualified catalog, canonical default fact/map and live/task/resume records align. Next23.3.6.1.1 after clean commit; literal repair scheduled next, not merely reported.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.5 - freeze selected default result flow`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.6`
  Status: `completed`
  Goal: Assess ordinary index_of integer/null results continuing through compatible scalar/numeric methods.
  Dependencies: .23.3.6.5.
  Schedule: Next bounded producer-result feature after default rollout, before exhaustive signature/matrix work.
  Existing authority: Catalog index_of(arr,needle) returns the first matching zero-based index, including numeric0, or undef for missing/non-array/no-match. Do not invent -1 sentinel behavior or change equality/domain policies.
  Public reproduction target: Compare ["a","b"].index_of("b").add(1) with num_add(index_of(["a","b"],"b"),1); include zero/empty/no-match/null, scalar boundaries and source/needle/consumer effects. Read actual public results before classifying a backend gap.
  Owned paths: Bounded result contract/public probes, current array/index facts and task/live planning; production children only after findings.
  Activation: clean `05cd2f8074894f012d56c3410e9366eb67dd2f97`; Lua committed, brief empty, tree clean.
  Verification tier: `focused`
  Focused checks: Small public Perl Get/substitution/native/fresh index-result and nested controls; producer snapshot/order, zero/no-match/null, scalar boundaries and malformed shapes. Probe syntax, book and fast continuity/history/diff guards; no full suite/cross-backend campaign.
  Canonical trigger: None for bounded diagnostic/frozen transition under director feature-first cadence; full public/domain/portable admission23.4 and final clean push remain separate.
  Claim verification: none: deterministic authored diagnostic values/order; no quantified corpus, support/completeness or portable measurement.
  Acceptance: Freeze a bounded actual-result transition if needed, preserve existing helper/needle/source/snapshot/once-only/arity/null policies, schedule backend repairs and commit. Full domain/portable admission remains23.4.

  Completion: Freeze ordinary index_of integer/null handoff in index-results.md after public native/lowering/fresh distinctions. Exact-one-needle shape follows the existing helper signature and ordinary fluent rejection policy. Schedule bounded backend children; no production change here.
  Findings / preservation: Direct fluent add lowers undef while nested returns2; zero/selected/pipeline/String forms stop and Hash-view raw DSL reaches host sorted_values. append_array_chain_call leaves index_of terminal. Native/fresh named/computed single-step snapshots already return null with N/SN and source[a,b]; nested consumer effects yield2/SNA/source[a,b,c,d]. Preserve the producer; do not turn the inspected legacy live-array branch into an assumed defect.
  Verification:
  - [x] REPRODUCE / ISSUE: Retained public Get/substitution diagnostic distinguishes fluent null from nested2 and captures the Hash-view lowering fallback plus malformed-shape no-effect controls.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering append_array_chain_call delegates index_of to array_chain_return_family, whose default is terminal; later compatible methods stop or fall through to raw DSL.
  - [x] FIX: Freeze the bounded result contract and schedule ordinary backend repair/confirmation children before code. Preserve zero-based/null/domain/producer policies.
  - [x] ADDRESSED (verified): Fresh emitted direct/nested pair agrees with native; named/computed single-step snapshot controls agree across both routes. No producer repair or other-backend failure is claimed.
  - [x] NO REGRESSION: Probe syntax, book and fast continuity/history/diff checks pass. No runtime change, full suite, equality/domain normalization or portable admission claim.
  - [x] LOCKSTEP: Contract/probes, catalog gap/nested alternative, current array fact/map and live/task/resume docs align. Perl23.3.7.1 next after clean commit; full signatures/admission stay separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.6 - freeze index result continuations`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.7`
  Status: `completed`
  Goal: Assess ordinary has_key truth-value results continuing through existing compatible scalar/text methods.
  Dependencies: .23.3.7.5.
  Schedule: Next bounded producer-result feature after index rollout, before exhaustive signature/matrix work.
  Existing authority: Catalog has_key(h:hash,key:string) returns boolean key presence. Reconcile actual return kind, key/arity and existing scalar-text rules before classification; preserve helper/domain/copy behavior and false/null stored-value presence. No new logical receiver vocabulary or numeric-Boolean normalization is inferred.
  Public reproduction target: Compare meta.has_key("a").cat("!") with cat(has_key(meta,"a"),"!"); include present/missing/false-valued/null-valued keys, retained actual kinds, scalar boundaries and source/key/consumer order/snapshots.
  Owned paths: Bounded result contract/public probes, canonical hash/scalar facts and task/live planning; production children only after findings.
  Activation: clean `617eb85069719f32d36779e521a438ae595df088`; index rollout committed, brief empty, tree clean.
  Verification tier: `focused`
  Focused checks: Canonical hash/scalar-text/arity rules, small public Get/substitution/native/fresh has_key and nested/presence/snapshot/effect/shape controls; probe syntax, book and fast continuity/history/diff guards. No full suite or cross-backend campaign.
  Canonical trigger: None for bounded diagnostic/frozen transition under director feature-first cadence; full domain/portable admission23.4 and final clean push remain separate.
  Claim verification: none: deterministic authored diagnostic values/order; no quantified corpus, support/completeness or portable measurement.
  Acceptance: Establish public behavior/domains before classification, freeze bounded compatible result flow if needed and schedule repairs. Existing contains missing-needle calibration/helper normalization remains FUTURE-PARITY-BACKLOG.5; do not silently change it here. Full domain/portable admission remains23.4.
  Confirmed P1 producer defect / schedule: A valid key block returning String remains raw inside exists ->{{DSL}}, causing native handler compilation failure even without a following consumer. has_key passes the authored block through lower_scalar_access_key_expr; complete it in the current MethodLowering context before host key emission. Own first as23.3.8.1.1, then separate result handoff23.3.8.1.2. Literal present/missing/false/null keys already return numeric1/0 correctly; preserve them. Nested effect controls are currently compile failures, not passing snapshot evidence.

  Verification:
  - [x] REPRODUCE / ISSUE: Public native/fresh direct fluent cat fails raw host dispatch while nested cat returns1!; valid String key blocks fail compilation even without chaining.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering has_key key delegation leaves authored blocks raw; _hash_receiver_value_chain_return_family marks has_key terminal.
  - [x] FIX: Freeze bounded presence/result/key/shape targets; schedule P1 producer repair before result flow and independent backend assessments.
  - [x] ADDRESSED (verified): Native/fresh literal/variable/helper String keys work; producer presence[1,0,1,1] agrees. Effect blocks are failing evidence, not passing snapshots.
  - [x] NO REGRESSION: Probe syntax/book/fast continuity/history/diff checks pass; production unchanged, no broad admission or type normalization.
  - [x] LOCKSTEP: Retain probes/contract; align catalog gap, hash fact/map and task/live/resume owners. Key-block23.3.8.1.1 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.7 - freeze has_key result continuations`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.8`
  Status: `completed`
  Goal: Assess ordinary is_empty/is_nonempty predicate results continuing through existing compatible scalar/text methods.
  Dependencies: .23.3.8.5.
  Schedule: Next bounded result-family feature after has_key rollout, before exhaustive signatures/matrices.
  Existing authority: Catalog is_empty(value:array|hash|expr) includes undef as empty; is_nonempty is its inverse. Reconcile actual kinds, source domains and arity before classifying flow. Preserve current source/null/String/false/zero/copy policies; no numeric-Boolean normalization or new logical vocabulary.
  Public reproduction target: Compare [].is_empty().cat("!") and ["a"].is_nonempty().cat("!") with nested cat(is_empty(...),"!") / cat(is_nonempty(...),"!"). Include Array/Hash/String/null sources, selected/pipeline/default/function forms, false retention, scalar boundaries/explicit bridges and source/consumer snapshots/order.
  Acceptance: Establish public results before classification; freeze bounded compatible handoff/shape targets and schedule independent backend children if needed. Existing contains missing-needle calibration remains FUTURE-PARITY-BACKLOG.5. Full domains/comprehensive/portable admission remains23.4.

  Activation: clean `e449e4c233ab4df02aa3e002ac1ece5614c0bcad`; has_key rollout committed, brief empty, tree clean.
  Owned paths: Bounded public predicate result probes/targets and current docs; production children only after findings.
  Verification tier: `focused`
  Focused checks: Canonical emptiness/scalar-text/arity rules and existing producer defect owners16.1/.16.2; small public Get/substitution/native/fresh fluent/nested, domain/presence/effect/shape controls; syntax/book/fast continuity/history/diff guards.
  Canonical trigger: None for bounded diagnostic/freeze under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored diagnostic values/order, no quantified population or portable measurement.
  Known producer prerequisite: Knowledge card perl-emptiness-expression-and-host-slot-drift and SESSION-STARTUP-READING.16.1/.16.2 already own literal-zero/host-slot and general-expression truthiness defects. Inspect public current behavior before selecting producer/result repair ordering; do not silently preserve those defects as normative semantics or infer broad repair from a bounded result fixture.

  Completion: Freeze emptiness-results.md before production. P1 bounded ordinary producer repair23.3.9.1.1 precedes result flow1.2; existing SESSION16 owns broader conditional/global literal-slot surfaces.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Get/fresh fluent empty cat null versus nested1!; literal0 text versus binding0!/1! and empty-Array block wrong0!/SA agree across native/fresh.
  - [x] ROOT CAUSE (WHY + WHERE): Substitution return undef follows array_chain_return_family terminal default. MethodLowering producer general fallback emits host !($value), treating an empty Array reference as true; existing SESSION16 card owns related source-spelling/host-slot defects.
  - [x] FIX: Freeze canonical actual-value emptiness and compatible scalar/text handoff; schedule producer before flow and independent backends. Do not normalize Boolean/numeric result or bless old wrong emptiness.
  - [x] ADDRESSED (verified): Native/fresh basic Array/Hash producer vector[1,0,0,1,1,1] agrees; public extra-argument fluent control[null,""] has no effects. Wrong nested block result is failure evidence, not a passing snapshot.
  - [x] NO REGRESSION: Production unchanged; probe syntax, book and fast memory/cadence/diagnosis/history/diff pass. No broad suite/portable admission.
  - [x] LOCKSTEP: Contract/probe, catalog caveat/nested alternative, existing emptiness fact/map and task/live/resume updated. Producer1.1 next after clean commit; broader16 remains owned.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.8 - freeze emptiness result continuations`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.9`
  Status: `completed`
  Goal: Assess ordinary String predicate results continuing through existing compatible scalar/text methods.
  Dependencies: .23.3.9.5.
  Schedule: Next bounded result-family feature after generic emptiness rollout, before exhaustive signatures/matrices.
  Existing authority: Canonical starts_with/ends_with/contains_substr scalar operands, matches literal regex/flags and null/empty boundaries, scalar-text truth rendering and actual producer kinds. Preserve helpers/regex/source/copy domains; no Boolean/numeric normalization or new logical methods.
  Public reproduction target: Compare "abc".starts_with("a").cat("!") and equivalent ends_with/contains_substr/matches fluent/nested pairs; retain true/false/null/empty, selected/pipeline/default/function String sources, literal/computed operands, false retention, explicit bridges/scalar boundaries, source/operand/consumer snapshots/order and malformed-shape controls.
  Acceptance: Establish actual availability/value/kind/shape behavior before classification; freeze bounded compatible handoff/backend children if needed. Exact String comparison receiver additions require separate inventory/contract work; contains missing-needle calibration remains FUTURE-PARITY-BACKLOG.5. Full domain/fluent/portable admission stays23.4.

  Activation: clean `e19f3ce83543d8befff3abc381d85a6b6285da15`; emptiness rollout committed, brief empty, tree clean.
  Owned paths: Bounded public String predicate result probes/targets, scalar facts and current docs; production children only after findings.
  Verification tier: `focused`
  Focused checks: Canonical String/regex/scalar-text/arity rules and existing Rust61.2 boundary record; small public Get/substitution/native/fresh fluent/nested, false/null/empty, source/order/snapshot and shape probes; syntax/book/fast continuity/history/diff guards.
  Canonical trigger: None for bounded diagnostic/freeze under director feature-first cadence; complete regex/domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored diagnostic values/order, no quantified population or portable measurement.

  Completion: Freeze string-predicate-results.md and schedule ordinary backend children. Producers and nested SOC snapshots already work; preserve them.
  Current-fact drift owned: July String receiver card still calls Length terminal and describes retired scalar()/concat syntax as current. Refresh this directly affected family card; retain exact original details at Gite19f3ce83543d8befff3abc381d85a6b6285da15 for the path rather than replaying historical broad tests.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Get/fresh direct fluent starts cat null versus nested1!; native ends/contains_substr/matches pairs agree. Correct nested effects[1!,SOC,zzztail] versus stopped fluent[null,"",abc].
  - [x] ROOT CAUSE (WHY + WHERE): call_spec_handler_subst emits return undef; MethodLowering _string_receiver_value_chain_return_family marks these four helpers terminal.
  - [x] FIX: Freeze compatible scalar/text handoff/one-operand shapes and independent backend owners; no producer/domain/regex/copy normalization or new methods.
  - [x] ADDRESSED (verified): Native/fresh producer vector[1,1,1,1,0,0], selected null/empty vector and nested SOC snapshots agree. Native malformed controls[null,""] have no effects. No other-backend failure inferred.
  - [x] NO REGRESSION: Production unchanged; retained probe syntax/book/fast memory/cadence/diagnosis/history/diff pass. No full suite/admission or historical gate replay.
  - [x] LOCKSTEP: Contract/probe, catalog gap/nested alternative, refreshed String fact/map and task/live/resume align. Perl23.3.10.1 next after clean commit; full regex/domain/portable admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.9 - freeze String predicate result handoff`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.10`
  Status: `completed`
  Goal: Assess/freeze ordinary is_defined/is_undefined results and compatible continuations across actual supported value kinds.
  Dependencies: .23.3.10.6 committed cleanly.
  Schedule: Next bounded family from helpers.md generic-helper inventory; before broad fluent admission or comparison-receiver additions.
  Scope: Reconcile catalog and actual producers first; null versus defined empty/false/zero/scalar/Array/Hash, source families/copy, result kind, one source evaluation, malformed zero-operand receiver shapes before effects, scalar/generic consumers and explicit container bridges. Retain correct producer/definedness domains; no Boolean normalization or deferred/callable/full admission.
  Acceptance: Public Perl native/fresh producers and fluent/nested distinctions with exact source/effect mechanism before classifying gaps; freeze bounded contract/fixture and schedule independent backend implementation/confirmation children. Small checks/docs/commit, no broad matrix.
  Activation: clean `db751b4ea97a786f7205b75ea8547fa24808c1b0`; prior repair committed, brief empty/tree clean, post-commit pointer passed.
  Owned paths: Bounded definedness result contract/public probes, relevant condition-only catalog teaching and canonical fact/task/live planning. Production only after assessment.
  Verification tier: `focused`
  Focused checks: Read generic inventory/catalog and canonical returned-definedness observation; public Get/substitution plus independent fresh emitted producer/fluent/nested/source/effect controls, probe syntax/book/history/diff and final staged memory/cadence/diagnosis.
  Canonical trigger: None for bounded normative/result assessment under director feature-first cadence; independent backend implementation and complete public/domain/portable admission23.4/final push separate.
  Claim verification: none: deterministic authored diagnostic values/order and bounded normative transition, no quantified population or portable completeness measurement.
  Known overlap: startup-public-teaching-checker-blind-spots/SESSION-STARTUP-READING.28.5 already observe returned/nested Perl definedness1/empty-string despite condition-only catalog text. Reverify current public producer before changing prose; preserve actual result/text/default domains, not a numeric-Boolean normalization.

  Completion: Freeze definedness-results.md and retained public probe before production; schedule generic receiver/result children23.3.11.1-.5. Correct only the catalog's unsupported condition-only denial, with scope-qualified actual Perl truth/text/default examples. Broad SESSION28.5 cat/checker admission remains open and cross-referenced.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Get native/fresh free producer returns[empty-text,1,1,1,1,1,1,empty-text]; nested true returns1!, false renders! and selects late! fallback. Ordinary receiver emits raw DSL and reaches undefined host helpers; computed receiver blocks can fail handler compilation.
  - [x] ROOT CAUSE (WHY + WHERE): call_spec_handler_subst leaves value.is_defined().cat(...) unchanged. MethodLowering _string_receiver_value_chain_return_family lacks definedness; typed free helpers already accept one expression and emit defined()/!defined(). Condition-only book text contradicts actual native/fresh contexts.
  - [x] FIX: Freeze generic zero-operand receiver/result contract, schedule independent backend children and correct bounded current expression teaching. Preserve actual definedness/result kind, scalar/default semantics and correct producer behavior; no runtime change or portable encoding claim.
  - [x] ADDRESSED (verified): Native/fresh producers and six empty/false/zero/Array/Hash/null boundary texts agree; nested source/result control is[1!,SC,changed]. Raw fluent compile failures do not establish a snapshot defect. Retained probe reproduces the distinctions independently of transcript.
  - [x] NO REGRESSION: Probe syntax/book and fast continuity/history/diff checks pass. No full suite, other-backend finding or generic/codeblock/domain admission. Broad SESSION28.5 teaching/checker and full fluent23.4 remain separate.
  - [x] LOCKSTEP: Contract/probe, catalog, canonical teaching fact/map, task/live/resume and SESSION28.5/index align. Perl23.3.11.1 next after clean commit; actual producer kind preservation is explicit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.10 - freeze generic definedness receiver results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.11`
  Status: `completed`
  Goal: Assess/freeze receiver/result counterparts for existing str_eq/str_ne/str_gt/str_ge/str_lt/str_le helpers.
  Dependencies: .23.3.11.5 committed cleanly.
  Schedule: Next String-family feature from helpers.md inventory, before broad fluent admission or numeric comparison changes.
  Scope: Read canonical comparison bridge/catalog and actual producers first; compare public Perl free/nested/receiver forms, true/false/null/empty and source/operand/result order. Preserve lexical/Unicode/scalar-text domains and actual result kinds; no use of numeric eq aliases for String comparisons, no domain normalization. Keep existing Dart Unicode-order defect ownership separate unless it blocks the selected ordinary transition.
  Acceptance: Retained public Get/substitution/native/fresh distinctions and exact mechanism before classification; freeze bounded contract and ordinary one-operand/no-effect malformed policy; schedule independent backend implementation/confirmation children. Small focused checks/docs/commit, no broad suite/full admission.

  Activation: clean `d9d81fa9a491380ca6d7b2a24cca727c581399ba`; Lua committed, brief empty/tree clean; post-commit pointer passed; identity derived from Git.
  Owned paths: Bounded String comparison receiver/result contract/public probes and qualified canonical/book/task/live planning; production only after assessment.
  Verification tier: `focused`
  Focused checks: Canonical bridge/catalog and public Perl Get/substitution plus independent fresh producer/fluent/nested/null/empty/order controls, probe syntax/book/history/diff and final staged continuity guards. No broad suite.
  Canonical trigger: None for bounded normative assessment under director feature-first cadence; independent backend implementation/full domain/portable admission23.4 and final push separate.
  Claim verification: none: deterministic authored diagnostic values/order and bounded normative transition, no quantified population or portable completeness measurement.
  Authority reconciliation: Historical bridge3.2.3.2 deliberately ships free helpers only; ordinary receiver counterparts are a new bounded feature under the director's comprehensive per-type fluent directive. Preserve free signatures and lexical versus numeric namespaces; do not misreport the prior documented scope as an old promised receiver defect.

  Completion: Freeze string-comparison-results.md after public assessment; schedule new ordinary receiver/result counterparts23.3.12.1-.5 under the comprehensive fluent directive. Historical free-only scope is explicitly superseded only as an implementation target, with numeric aliases/free/domain policies preserved. Give earlier residual Dart regex exclusions an explicit P1 assessment23.2.12 after this family, rather than only an admission qualifier.
  Verification:
  - [x] REPRODUCE / ISSUE: Public LinkedSpec::Get/native/fresh producer gives six1/six0; receiver .str_* chains remain raw DSL/undefined host calls or compile failures, while nested true gives1! and false/default gives0!. call_spec_handler_subst retains unchanged direct .str_eq chain.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering's String return-family map intentionally omits free-only bridge helpers. Existing typed/legacy free helpers already evaluate lhs/rhs into temporaries and compare lexically; no producer/snapshot repair is established. Canonical bridge3.2.3.1/.2 defines historical scope.
  - [x] FIX: Freeze one-operand-before-effects receiver/result target and schedule independent backend children; no production change. Reconcile book/current fact with free/nested alternatives and planned counterparts, retaining numeric namespace and actual null/Unicode/result domains.
  - [x] ADDRESSED (verified): Native/fresh null/empty/zero-text compatibility and six true/false producers agree. Perl undef compares as empty text (undef/empty equality1); nested blocks retain1!/SOC/final-null, null-source control0/SO. These are preservation controls, not new portable null-domain promises.
  - [x] NO REGRESSION: Probe syntax/book and fast continuity/history/diff checks pass; no full suite/other-backend failure or full admission claim. Existing Dart Unicode-order and scanner owners stay separate; residual mode assessment23.2.12 is explicit and not represented as an observed defect.
  - [x] LOCKSTEP: Contract/probe, qualified catalog/guide and canonical String comparison fact/map align with task/live/resume. Perl23.3.12.1 next after clean commit; full domain/context/portable23.4 and mandatory Perl canonical registration23.4.1 remain separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.11 - freeze explicit String comparison receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.12`
  Status: `completed`
  Priority: P1 bounded residual regex-feature assessment; existing exclusions are now given an explicit frontier before full admission, not a newly measured failure claim.
  Goal: Assess remaining Dart action literal x/go/unknown suffix and invalid-pattern behavior against the documented matches/regex contracts.
  Dependencies: .23.3.12.5 committed cleanly.
  Schedule: Immediately after the String comparison counterpart family and before another family/full admission; preserve current feature focus.
  Existing scope: String predicate3.10.3 restored i/m/s only; grouped-literal3.10.6 explicitly left x/unknown and invalid/context policies unassessed. The generic catalog lists imsx, go no-ops and false-on-invalid; reconcile actual context/authority before changing behavior.
  Planned public controls: matches("ab",/^ a b $/x), /x/i split/filter, matches("abc",/^abc$/go), /^abc$/q and malformed/grouped literals through native/restored/plan, with inline/no-flag and operand-effect controls. Distinguish AST suffix loss from bridge/error-boundary behavior; own bounded first-party repairs after actual reproduction. Broader grouped-brace scanner/validator and engine/dialect work stay with existing owners.
  Acceptance: Reconcile every stated exclusion with a bounded observed result/owner and implement missing documented features or correct unsupported-domain claims before admission. No public regex type, submodule internals, full suite or unmeasured failure classification.
  Planned verification tier: focused; declare exact proof/no-measurement rationale at activation.

  Activation: clean `d08fb16f5d709964351903c32fce6cfadcaa4dbe`; five comparison counterparts committed, brief0/tree clean.
  Owned paths: Public Dart action-literal mode/invalid matches assessment, bounded first-party normalization/failure-boundary repair where demonstrated, focused native/restored/plan/direct String checks/docs. Catalog matches355-356 and split801-802 prescribe imsx, go no-ops, unknown/invalid false or empty; inline x/scoped regex semantics and broader scanner owners are not inferred.
  Verification tier: `focused`
  Focused checks: Public authored distinguishing literal x/go/unknown/invalid and split/filter/effect controls native/restored/plan, existing String predicate fixture, selected-file fatal analysis/formatting, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded existing documented ordinary feature repair under director feature-first cadence; full regex/context/portable admission and final clean push separate.
  Claim verification: none: deterministic authored regression decisions, no dialect population/completeness measurement.

  Completion: Existing published ordinary literal mode/error contracts reconciled with public controls. _regexLiteralPattern rejects unknown suffixes via existing invalid-pattern handling and preprocesses suffix x with a class/escape/comment-aware ASCII scanner before existing i/m/s normalization; go remain no-ops. _callMatches catches only regex FormatException and returns false; operand errors and existing sequence remain unchanged. No public Regex kind/schema or inline-x/scoped-flag admission.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native RED distinguishes lost x (false/un-split/empty-filter), ignored q/iq (true/matches), and invalid text pattern FormatException. No-x and go controls already pass. Grouped malformed /(/ instead becomes raw action code before compilation; retained public AST/native probe distinguishes standalone RegexLiteral, raw nested call, ordinary invalid a** call and working symbolic division.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart _regexLiteralPattern selects only ims and ignores other flags; _callMatches compiles without FormatException handling while split/filter already catch it. Separate action_parser.dart _looksLikeRegexStart rejects next '(' and _findMatchingDelimiter counts pattern parentheses: P1 repair23.3.10.7 is immediate next; broader DART2.2.1/.2.2.2 stay open.
  - [x] FIX: Add bounded literal x normalization, unknown-mode invalid sentinel and matches-only FormatException boundary. ASCII whitespace/comments removed only outside classes; escaped whitespace/hash become literals (including supplementary Unicode), non-ASCII spaces stay significant, terminal escapes remain invalid.
  - [x] ADDRESSED (verified): Native/restored/plan targeted controls pass suffix x, duplicate/combined modes, class/escaped spaces/hash, comments, non-ASCII-space and supplementary controls, unchanged go/no-x, unknown free/receiver/split/filter, invalid a**/text free/receiver/split/filter and eager SO. Grouped malformed remains explicitly owned next; no promise of its acceptance here.
  - [x] NO REGRESSION: Existing String predicate result/mode/grouped-complete controls pass;27 selected Dart tests, fatal analysis and formatting pass. No broad matching/corpus/full suite or engine/dialect inference.
  - [x] LOCKSTEP: Public mode fixture and retained grouped probe, scoped book examples, canonical regex facts/map and task/live/resume align; book/history/diff/final staged memory/cadence/diagnosis checked before commit. Immediate next23.3.10.7 precedes contains23.2.13.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.12 - preserve Dart extended regex modes and helper failures`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.13`
  Status: `completed`
  Goal: Assess ordinary Array contains result handoff and compatible scalar/generic/explicit-container consumers.
  Dependencies: .23.2.12 and immediate grouped-invalid operand repair23.3.10.7 committed cleanly.
  Scope: Read membership/equality/element/needle contract and actual producers before classification; preserve source snapshots/result kinds and all published domains. Reconcile FUTURE-PARITY-BACKLOG.5's known missing-needle and punctuation-light twins explicitly before any receiver-arity change. No missing-needle/equality normalization inferred from prior index/has_key families.
  Acceptance: Retained public native/generated producer/fluent/nested/source/effect distinctions; freeze only observed-authorized ordinary result/shape transition and schedule independent backend children. Small compile/direct checks/docs/commit, full domain/portable admission separate. No current consumer failure or uniform terminal behavior claimed before assessment.
  Planned verification tier: focused; declare proof/no-measurement rationale at activation.

  Activation: clean `39d8f85ebe9f954bc716d083083850604624e86f`; grouped scanner committed/brief0/tree clean.
  Owned paths: Public Perl producer/fluent/nested/source/arity controls and generated-source mechanism; frozen ordinary contains result transition and explicitly reconciled FUTURE5 required-needle/punctuation-light policy, backend child ownership/docs. No runtime changes in assessment.
  Verification tier: `focused`
  Focused checks: Retained public LinkedSpec::Get/substitution/dump_parser_source/native/fresh controls and canonical membership/signature/arity owners, small syntax/doc/book/history/final staged continuity checks.
  Canonical trigger: None for bounded assessment/freeze under director feature-first phase; complete domains/context/portable admission23.4 separate.
  Claim verification: none: normative bounded contract and authored public distinction, no quantified population/completeness measurement.

  Decision: Existing canonical contains function arity[2,2] and one authored receiver needle remain authority. Activate FUTURE-PARITY-BACKLOG.5.6 for bounded required-receiver-arity normalization coordinated by implementations23.3.13.1-.5: missing/extra ordinary receiver operands become null before effects, both bare/parenthesized missing forms identical. Free helper signatures, equality/null/empty/kinds and other helper caveats are unchanged. This intentionally replaces four-backend missing-needle0 drift; update each affected named calibration test in its backend slice.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Perl native/fresh free membership returns numeric[1,0,0,1,0,0,1,1,1] for hit/miss/empty/null-distinct/zero/false controls; nested cat1! works. Ordinary result chains return null (positive lowers return undef), including selected/bridge/generic; fluent blocks are wholly skipped. Native/fresh nested producer/consumer already yields1!/SOC/final-null, null-source0/SO, named-source snapshot1/O/[z]. Preserve those producers/snapshots.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering.pm array_chain_return_family omits contains and marks it terminal; global one-operand preflight omits it too. Public substitution direct missing/extra returns unsupported-helper undef before effects, but nested Array elements emit raw items.contains() and fail undefined host contains. Both bare/parenthesized nested forms do this, so no alias-only divergence is inferred.
  - [x] FIX: Freeze contains-results.md and schedule five independent backend children. Activate original FUTURE5 required-needle owner as5.6; coordinate exact aliases, source/effect and named calibration changes before any production arity normalization. Perl child owns malformed nested host-call leak immediately.
  - [x] ADDRESSED (verified): Retained public Get/substitution/native/fresh probe distinguishes raw producer kind, helper/result dispatch, source snapshots and direct-versus-nested malformed boundaries. No runtime repair or other-backend result-kind measurement claimed by this assessment.
  - [x] NO REGRESSION: No runtime edits; probe syntax, book/history/diff/final staged memory/cadence/diagnosis checked. Full equality/domain/function-arity/portable admission and unrelated FUTURE5 caveats stay with existing owners.
  - [x] LOCKSTEP: Frozen contract/retained probe, current nested book examples, new canonical contains fact and qualified arity history/map align with TYPE/FUTURE5.6/index/live/resume. Perl23.3.13.1 follows clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.13 - freeze Array contains result transitions`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.14`
  Status: `completed`
  Priority: P1 immediately after contains23.3.13.5, before another family/full admission.
  Goal: Reconcile membership null/empty equality and aggregate-consuming source snapshots with the Perl reference and typed value contracts.
  Dependencies: Bounded contains rollout23.3.13.1-.5 committed; coordinate FUTURE-PARITY-BACKLOG.5 caveat authority.
  Confirmed intake: Rust contains raw producer native returns1 for [undef] versus empty-string needle and for [empty-string] versus undef, where retained Perl native/fresh returns0. Dart23.3.13.3 independently confirms the same null/empty merging on native/restored/plan, with correct source captures already present; no Dart producer repair is claimed. Julia23.3.13.4 independently confirms numeric/text-key merging and correct source captures on native/plan/fresh too; no Julia producer repair is claimed. Lua23.3.13.5 independently confirms the same numeric/text-key merging and correct captures on native/plan/fresh on both available hosts; no Lua producer repair is claimed. Rust named Array source rebinding during needle returns0 versus expected captured1; current23.3.13.2 fixes that contains snapshot seam. engine.rs array_consuming_arg/hash_consuming_arg prefer current binding after evaluated arguments, so sibling consumers require assessment; no new index_of/other-helper failure or cross-backend mismatch is claimed without public controls.
  Acceptance: Resolve accepted scalar/null/equality authority before normalization; independently compare actual membership/index selection and remaining array/hash consumer source/operand effects. Fix confirmed bounded first-party defects with small producer/direct checks and explicit original-owner coordination, preserve unrelated source kinds/equality/copy/arity and published caveats. No broad census or portable admission from samples.
  Planned verification tier: focused; declare exact metadata at activation.

  Activation: clean `0b474336c4bc96977edb5fd3e6316f4b4095a58d`; five contains slices committed, brief0/tree clean.
  Owned paths: Bounded public membership/null selection and named Array/Hash source/operand controls, existing scalar/null/reference authority, original FUTURE5 coordination and retained producers. Split confirmed repairs into bounded subsequent leaves before code; no production changes in this assessment.
  Verification tier: `focused`
  Focused checks: Retained public Perl Get/native/fresh and Rust Engine producer probes, canonical typed values/membership/selection/source snapshot contracts, source syntax/book/history/diff/final staged continuity guards. No corpus/full verification.
  Canonical trigger: None for bounded assessment under director feature-first cadence; complete portable/context/domain admission23.4 separate.
  Claim verification: none: deterministic authored distinctions and bounded contract reconciliation, no population/completeness measurement.

  Decision / authority: README behavioral reference and explicit Perl contains/index_of undef branches select null-only matches for a null needle; defined scalar text coercion stays unchanged. Catalog uniq already explicitly retains undef distinct from empty. Treat null as a distinct internal Array comparison/uniqueness key for contains/index_of/uniq only, preserving first value/kind/order and all defined-value conversion behavior. No new strict Boolean/number/container/callable equality policy. Uniform binding read plus frozen index/has_key source-before-operand rules require cached typed operands; preserve existing named wrong-kind/absent empty-container fallback without re-reading later bindings. Ordinary has_key must evaluate its key once after source capture even when source null; move key expression before validity check in both typed/legacy lowering. These bounded original-helper repairs are activated as FUTURE5.7 and implementations23.3.14.1-.6.
  Verification:
  - [x] REPRODUCE / ISSUE: Retained shared spec/public Perl Get+dumps/native/fresh and Rust Engine native/restored/plan agree within carriers. Perl membership=[1,0,0,1,1,1,0,1,1], indexes=[0,null,null,0,1,1,null,0,0], uniq=[null,"",0]; Rust merges null/empty, indexes picks0 instead of1, uniq=[null,0]. Other variants’ contains merging is already independently confirmed; index/uniq require each backend assessment.
  - [x] ROOT CAUSE (WHY + WHERE): Rust contains/index_of/uniq use to_str keys merging Undef/empty. array_consuming_arg/hash_consuming_arg replace evaluated typed args with current named bindings. Public named index result null vs reference0, has_key0 vs1, appended index1 vsnull and merged{z,b} vs{a,b} distinguish re-read; concat control already preserves[a,b] Array values. get_bare_value in runtime.rs already captures typed Array/Hash clones, and uniform_binding_contract policy.read is authoritative.
  - [x] FIX: Freeze aggregate-null-and-snapshot-contract.md and six bounded implementation leaves, activating original FUTURE5.7. First Rust adapters consume cached typed arguments while preserving prior named wrong-kind/absent empty fallback; then Perl key evaluation; then Rust/Dart/Julia/Lua null-key primitives. No production changes in assessment.
  - [x] ADDRESSED (verified): Source-null controls distinguish output policy from effects. Rust named absent index returns0 despite literal absent controlnull, absent has_key1 despite control0; both rebind sources during operands. Perl absent has_key returns0 but skips key binding (finalnull). dump_parser_source and typed4501/4511 plus legacy6840/6863 show key expression inside defined(hash) ternary: own repair23.3.14.2; do not bless or obscure that suppression.
  - [x] NO REGRESSION: Public probes compile/execute exact source with no diagnostics; no runtime edits. Source/test syntax, book/history/diff/final staged memory/cadence/diagnosis checked. Defined coercion/invalid-kind/copy/target-mutation/lazy-control/deferred contexts and complete portable admission remain separately owned.
  - [x] LOCKSTEP: Retained source/Perl producer/Rust public example, frozen contract, known book limitations, new canonical source/null fact and current pure-pipeline/history qualifier align with TYPE/FUTURE5.7/index/live/resume. Rust snapshot1 is next after clean commit; no fixed-behavior claim at this freeze.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.14 - freeze aggregate operand and null-key repairs`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.15`
  Status: `completed`
  Goal: Assess ordinary numeric comparison receiver results and compatible inter-type continuations.
  Dependencies: Six bounded aggregate/null repairs23.3.14.1-.6 committed.
  Authority: Comprehensive-method directive and current helper spelling spine; existing num_eq/ne/gt/ge/lt/le and short eq/ne/gt/ge/lt/le receiver semantics, numeric conversion/invalid-input policies and intentional prior terminal boundaries remain authoritative until this bounded transition is frozen.
  Acceptance: Publicly compare raw/free/nested/current fluent producers, Number/Bool/null kinds, true/false/default/numeric/String/Array bridges, literal/named/selected/pipeline/function/default sources, source/operand/consumer order and malformed receiver shapes. Preserve current numeric domains and free signatures; do not conflate numeric and lexical comparisons or invent strict Bool equality. Freeze only observed-authorized ordinary result transition and schedule independent backend implementation children before code. Small syntax/direct checks/docs/commit; full domain/context/portable admission separate.
  Planned verification tier: focused
  Planned focused checks: Retained public Get/substitution/dump/native/fresh and canonical numeric owners, bounded direct current consumers; no exhaustive matrix/full suite.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: bounded normative contract and deterministic authored distinctions; no population/completeness measurement.

  Activation: clean `77a853d50d4cfbcd02d125b6e591cf987e2f2786`; six aggregate/null child commits complete, brief0/tree clean.
  Owned paths: Retained public numeric producer/result/source/arity probes, scoped existing numeric authority and frozen ordinary result contract, independent backend child scheduling and current book/facts/task/live docs. No production changes in assessment.
  Verification tier: `focused`
  Focused checks: Public Perl Get/substitution/dump/native/fresh probe and canonical numeric contract/receiver owners; syntax/direct current comparison checks, book/history/staged continuity guards.
  Canonical trigger: None for bounded contract selection under director feature-first cadence; complete domain/context/portable admission and clean push separate.
  Claim verification: none: normative bounded transition and deterministic authored distinctions, no population/completeness measurement.

  Decision: Extend existing six short numeric comparison methods with compatible scalar result continuation under numeric-comparison-results.md. Keep scalar-numeric-v1 numeric1/0/invalid-null/strict decimal rules, free names/arities and lexical str_* separate. One receiver RHS before effects; actual null can feed existing defaults/definedness. Prior terminal boundary is intentional; this is a bounded new feature. Canonical .num_* receiver names are unpromised/outside this short-method scope.
  Verification:
  - [x] REPRODUCE / ISSUE: Retained Get/substitution/dump/native/fresh probe confirms six true/false raw numeric pairs, decimal String and strict invalid controls. Nested consumers yield[1!,0!,2,X]; named/first/length/Hash/default/numeric String terminal producers work. Ordinary continued comparisons return null, source blocks skipped.
  - [x] ROOT CAUSE (WHY + WHERE): Public substitution lowers each continued short comparison to undef; MethodLowering _number_receiver_value_chain_return_family returns terminal and common preflight rejects any following link. This is prior intentional scope, not an existing promised consumer defect. Numeric.pm already returns contracted numeric1/0 or null.
  - [x] FIX: Freeze numeric-comparison-results.md and five independent implementation children23.3.15.1-.5. Require actual result-kind handoff, exact-one-RHS preflight, strict numeric domains, false/default/numeric/String/Array transitions and captured SOC values. No production change in assessment.
  - [x] ADDRESSED (verified): Native/fresh nested effects already give1!/SOC/final-null; fluent givesnull/no-effects/original2, so do not infer a source re-read. Missing/extra short shapes already reject before effects. Corrected one extra nested-probe delimiter before successful replay; opt-in canonical .num_* diagnostic is unpromised, excluded from normal replay, not producer RED credit.
  - [x] NO REGRESSION: Normal retained public probe executes/loads all authored native/fresh cases without diagnostics, source syntax passes. No numeric conversion/arity/producer/runtime change, broad suite or portable admission.
  - [x] LOCKSTEP: Retained probe, frozen contract, per-backend tasks, current scoped book numeric kind/nested examples and canonical number-chain fact/map plus live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Perl15.1 next, then Rust/Dart/Julia/Lua independently.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.15 - freeze numeric comparison result continuations`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.16`
  Status: `completed`
  Goal: Assess compatible scalar/text/generic/inter-type continuations of ordinary scalar numeric arithmetic results.
  Dependencies: Numeric comparison result implementations23.3.15.1-.5 committed.
  Authority: Comprehensive fluent directive; helper spine and scalar-numeric-v1 arithmetic/rounding/clamp/min/max conversions/arities. Existing Number methods abs/floor/ceil/round/add/sub/mul/div/mod/clamp/min/max and scalar-versus-Array min/max overloads stay authoritative until this bounded transition is frozen.
  Acceptance: Independently compare raw/free/nested/current fluent results and actual Number/null kinds, zero/negative/decimal/invalid inputs, source families and source/operand/consumer effects. Assess numeric->text->split Array->selected String, explicit defaults/generic/scalar boundaries and shape controls; preserve numeric domain/free signatures and existing scalar/Array min/max overload selection. No general strict equality, Array reducer repair or unsupported canonical method-name expansion. Freeze only observed-authorized result transitions and schedule bounded backend children before production; small syntax/direct checks/docs/commit, full admission separate.
  Planned verification tier: focused
  Planned focused checks: Retained public Get/substitution/dump/native/fresh distinctions and existing arithmetic/overload owners; no exhaustive matrix or full suite.
  Planned canonical trigger: Complete admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: bounded normative transition and deterministic authored distinctions, no population/completeness measurement.

  Activation: clean `3bfda7204a4c6b19d8d9f5a6145399afff8d6168`; five numeric comparison children committed, brief0/tree clean.
  Owned paths: Retained public scalar arithmetic producer/result/overload/effect/shape probes and bounded ordinary result contract/backend scheduling, relevant numeric book/facts/task/live docs; no production change in assessment.
  Verification tier: `focused`
  Focused checks: Public Get/substitution/dump/native/fresh arithmetic/overload distinctions, canonical numeric contracts, small syntax/direct checks and book/history/staged continuity guards.
  Canonical trigger: None for bounded contract selection under director feature-first cadence; complete domain/context/portable admission and clean push separate.
  Claim verification: none: bounded normative transition and deterministic authored distinctions, no population/completeness measurement.
  Owned documentation defect: Catalog numeric intro and guide Number-chain overview still say comparison methods terminate (catalog also calls them boolean), contradicting committed15.1-.5/current examples. Reproduce by reading helper-contract-catalog1095-1116 and value-container-flow-helper-reference970-984 against retained numeric comparison tests. Missed long summary sentences in prior focused search caused stale prose; correct both in this leaf and check all scoped comparison boundary wording. No code change is needed for that documentation defect.

  Decision: Freeze scalar-arithmetic-results.md for twelve existing short arithmetic/rounding/clamp/scalar min/max methods. Actual Number/null results feed scalar/text/generic/explicit-container consumers, retaining strict scalar numeric contracts, helper/free names and overload semantics. Unambiguous malformed receiver shapes reject before effects; no global min/max or free-helper normalization. Five independent backend children16.1-.5 own implementation; prior Number-only scope is intentional, not an old promised consumer defect.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Get/substitution/dump/native/fresh twelve free producers give[3,3,4,3,5,3,6,3.5,1,10,3,5] and corresponding nested texts. Plain arithmetic-to-cat/bridge/default/effect chains fail handler compile with raw DSL residue; source-family group identifies String-prefix raw trim host failure. Independent canonical-call/first/count/reducer controls give four5! values; no source-family regression inferred wholesale.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering _number_receiver_value_chain_return_family yields number for arithmetic; Number loop accepts only Number links until a scalar producer. String loop's existing numeric handoff only covers six comparisons. Public substitution retains raw arithmetic .cat links; source error is undefined host trim. Existing source/effect helpers are correct: nested5!/SOC/final-null.
  - [x] FIX: Freeze bounded actual-value result contract and five backend leaves; no production change. Own/fix missed catalog intro/guide overview comparison-terminal/boolean prose against committed15.1-.5 results; scoped comparison boundary wording is checked, and current examples remain accurate.
  - [x] ADDRESSED (verified): Healthy controls preserve raw numeric/invalid-null, nested fallback8/zero0!, existing selected sources, Array/scalar min/max[3,4,ASO,5,4] and bad abs/add/clamp null/no-effects on native/fresh. Preserve overloaded invalid-kind/effect/copy rules and Array reducer95 defects; do not silently normalize them while adding flow.
  - [x] NO REGRESSION: Retained public baseline/independent source/invalid controls execute/load healthy routes and expose expected unimplemented transition compile/eval diagnostics; source syntax passes. No runtime/parser/numeric-helper/free-arity changes, broad matrix or complete portable admission.
  - [x] LOCKSTEP: Retained probe/frozen contract/per-backend tasks, corrected current comparison overview prose and canonical Number result fact/map plus live/resume align. Prior complete comparison rollout detail remains behind exact Git pointer; no cap raise. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Perl16.1 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.16 - freeze scalar arithmetic result continuations`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.17`
  Status: `completed`
  Goal: Assess ordinary logical-helper Boolean result continuations from the helper spelling/role spine and existing logical-helper-v1 authority.
  Dependencies: Bounded scalar arithmetic23.3.16.1-.5 committed.
  Authority: ADR0043, capability_conformance/logical_helper_contract.json and canonical logical-helper-neutral-contract/public-no-drift records. Existing and/or/not eager evaluation, typed truthiness, real Bool results and pre-effect typed arity errors remain authoritative; do not invent receiver counterparts from resolver categories.
  Acceptance: Use small public producer/nested/fluent native/fresh distinctions for all three logical helper results, valid eager effects/snapshots, false/default/generic/numeric/text/explicit-container boundaries and selected Boolean sources. Preserve existing errors, free signatures, lazy-control contrast, callbacks and admitted behavior. Freeze only needed compatible actual-value transitions and schedule bounded backend children after concrete observations; no full matrix/replay or new truthiness policy.
  Planned verification tier: focused
  Planned focused checks: Existing canonical fact/neutral contract and public producer/nested/result distinctions, small syntax/direct logical checks, current book/task/live continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: normative bounded feature selection and deterministic authored distinctions, no population/completeness measurement.

  Activation: clean `285d7a8a5c20ad2c9f9265a8fbdb725ac5b33578`; all five bounded arithmetic implementations committed, brief0/tree clean.
  Owned paths: Retained public logical producer/nested/fluent/source/effect/diagnostic assessment and any needed frozen transition/backend scheduling, scoped logical book/facts/task/live docs. No production change before concrete public observations; preserve logical-helper-v1.
  Verification tier: `focused`
  Focused checks: Public Get/substitution/dump/native/fresh authored distinctions and direct logical contract checks, syntax/book/history/staged continuity guards.
  Canonical trigger: None for bounded feature assessment; full domain/context/portable admission/final clean push separate.
  Claim verification: none: normative bounded selection and deterministic authored distinctions, no population/completeness measurement.

  In-flight owned findings: Public native/fresh raw Bool, direct text/nested/eager LRC and truthiness controls pass. Logical->cat->split->last->uppercase gives null with unsupported-helper:cat, while a compound default/source probe has host compile residue. Malformed not(two).cat unexpectedly returns null/no typed error; isolate against direct/nested error controls before classification or implementation. Literal Hash indexing in the initial source compound is not admitted evidence; replace with named Hash and isolate fields. Own confirmed result/diagnostic gaps here and schedule immediate bounded repairs after root-cause freeze; preserve established producer semantics.

  Decision: Freeze logical-results.md for ordinary real-Boolean result flow and scalar boundaries, retaining existing eager typed truthiness/free signatures/source arity diagnostics and no new .and/.or/.not methods. Schedule independent backend children23.3.17.1-.5 immediately. These are broader result-family repairs/extensions, not a reopened historical5.2 projection admission.
  Verification:
  - [x] REPRODUCE / ISSUE: Retained native/fresh raw six Bool values, direct text/false-default/named-selected-Hash-block-literal sources, strict numeric-null recoveryB, generic definedness, truthiness and eager direct/nested LRC controls pass. Longer bridge returnsnull/unsupported cat versus nestedX; Hash-only tail leaves raw logical DSL, breaking the compound handler; direct Array-only tail returnsnull with binding_kind_mismatch.
  - [x] ROOT CAUSE (WHY + WHERE): Public AST keeps a logical call plus four bridge links; String-first fluent composition lacks typed logical actual-result handoff when rebuilding aggregate DSL. Direct Array route uses BindingRuntime on a Boolean. Malformed not(two).cat with unknown fail operands is intercepted by first_unknown_value_call_name before lower_ast_logical_call_node's arity validation; direct/nested/known-helper-operand controls raise the correct typed error.
  - [x] FIX: Frozen bounded transition/scalar rejection/typed-error precedence and five independent implementation children; no production change in assessment. Correct probe instrumentation to stringify thrown typed objects before JSON encoding; native/fresh producer results stay unchanged. Initial literal-Hash index compound is replaced with named Hash controls, not credited as a defect. Preserve direct logical contracts.
  - [x] ADDRESSED (verified): Retained public producer/substitution/dump/native/fresh and optional AST mode isolate mechanisms without blaming truthiness, operand evaluation or emitter. Direct logical fixture passes eight top-level subtests, covering old values/effects/with/lazy/typed errors. New probe syntax passes; isolated source/default/shape observations remain owned implementation RED.
  - [x] NO REGRESSION: No runtime/parser/neutral JSON/truthiness/free signature or callback change. No full matrix/replay/portable admission or fabricated logical receiver-method promise. Initial direct-arity probe stopped when serializing a thrown object; corrected instrumentation reruns direct/nested/known/unknown cases successfully and retains the distinction.
  - [x] LOCKSTEP: Retained probe/frozen contract/backend tasks, current qualified catalog and canonical logical fact/map plus live/resume agree. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Perl17.1 owns the confirmed staging/scalar/diagnostic gaps next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.17 - freeze logical Boolean result continuations`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.18`
  Status: `completed`
  Goal: Assess useful ordinary defined-only coalesce receiver surface and actual selected-result continuations from the helper spelling/role spine.
  Dependencies: Bounded logical result23.3.17.1-.5 and Perl rejection-effect follow-up committed.
  Authority: Existing lazy coalesce public helper, scalar-text/default contracts and current default owner23.2.5/23.3.6; that older nonempty-default target explicitly excludes new coalesce receiver promises. Comprehensive fluent directive authorizes a separate assessment, not inferred method admission from a resolver category.
  Acceptance: Public producer/nested/current receiver/source/arity/kind/effect distinctions before production. Preserve defined empty String/zero/false selections, null exhaustion, left-to-right lazy fallback selection, actual values/copies and skipped later errors. Establish existing scalar/Array/Hash domains, source-before-fallback/consumer snapshots and method arities without normalizing free helpers or broadening portable domains. Freeze only a bounded useful counterpart/result rule if warranted, then own backend children; small syntax/direct checks/docs/commit, no full matrix/replay.
  Planned verification tier: focused
  Planned focused checks: Canonical default facts/contracts and public Get/substitution/dump/native/fresh distinctions, small direct defaults/strict kinds and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: normative bounded feature selection and deterministic authored distinctions, no population/completeness measurement.

  Activation: clean `8e9f1b9936628a8b9c450a965303801401886688`; all bounded logical result implementations committed, brief0/tree clean.
  Owned paths: Retained public defined-default producer/nested/receiver/domain/source/arity/effect assessment and any needed bounded counterpart contract/backend scheduling, scoped default book/facts/task/live docs. No production change before observations. Existing Perl value-only default arity metadata starts at2 total operands; verify public behavior rather than assuming a zero-RHS identity method.
  Verification tier: `focused`
  Focused checks: Public Get/substitution/dump/native/fresh distinctions and direct default contracts, syntax/book/history/staged continuity guards.
  Canonical trigger: None for bounded feature assessment under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: normative bounded feature selection and deterministic authored distinctions, no population/completeness measurement.

  Public intake: Free/nested native/fresh coalesce preserves defined empty String/zero/false and observed Array/Hash values, nested text[CHOSEN,!,1,0!,CHOSEN], retained aggregate controls[0,0,B,A] and explicit captured selection A:B/SDC/once-only. Current receiver counterparts retain raw DSL and fail host compilation; this is missing useful method scope, not a violation of the older explicitly excluded target. Initial combined stdout/stderr caused interleaved JSON in a failing diagnostic record; add autoflush/separate channels and rerun needed lazy/arity/exhaustion/AST cases before crediting them.

  Decision: Freeze defined-default-results.md for a separate ordinary .coalesce(fallback,...) counterpart with one-or-more fallbacks, defined-only lazy selection, actual String/Number/Boolean/Array/Hash continuations and ordinary copies/snapshots. Preserve all free signatures and old nonempty-default scope; schedule independent backend18.1-.5 before production. No portable aggregate-domain promotion.
  Verification:
  - [x] REPRODUCE / ISSUE: Intact public native/fresh producers/nested/retained/copy/selector controls preserve defined empty/zero/false, null exhaustion and actual containers/numeric indices. Current receiver chains retain raw DSL, causing host compile/eval errors; AST retains the intended chain. Explicit captured nested control gives[A:B,SDC,1,1,[z]], lazy controls[empty,false,0,safe,0].
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering already has complete lazy typed lowering and minimum-two free metadata for both defaults, but receiver return-family admission includes only coalesce_nonempty. Missing coalesce receiver dispatch is a new bounded method gap, not a breach of23.2.5's explicit exclusion. Free one-operand coalesce currently returnsnull on Perl; require a fallback for the new receiver rather than infer identity.
  - [x] FIX: Retain corrected public producer/AST probe, frozen counterpart/result contract and independent backend children. No production edit. Copy controls preserve original selected Array/Hash after mutation; independent selector write proves actual numeric kind. Initial interleaved failing output is not credited; isolated reruns retain structured fresh errors.
  - [x] ADDRESSED (verified): Public diagnostic/source syntax and direct existing default checks pass; ordinary preserved values/copies/SDC/skipped supported runtime error controls establish the bounded baseline. Preserve named/selected/Hash/block/function/prefix sources and source effects before incompatible consumers in implementation. No assumptions from emitter internals or inferred backend failures.
  - [x] NO REGRESSION: No parser/runtime/free/domain/callback/source contract changes. Lazy nested oracle explicitly captures selection before delimiter effects because free join_values evaluates delimiter first. No full matrix/replay/portable admission or callable/Regex/scoped receiver expansion.
  - [x] LOCKSTEP: Frozen contract, retained probe and backend tasks, qualified coalesce catalog and canonical default fact/map plus live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Perl18.1 is next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.18 - freeze defined-only default receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.19`
  Status: `completed`
  Goal: Assess ordinary scalar String-helper result continuations and scalar boundaries from the helper spelling/role spine.
  Dependencies: Bounded defined-only default23.3.18.1-.5 committed.
  Authority: Existing trim/lowercase/uppercase/replace_substr/rm_prefix/rm_suffix/substr/cat public contracts, String/numeric/Unicode/copy facts and actual-result flow owners. length/predicates/comparisons/defaults/split/statement regex substitution retain their existing separate contracts; no resolver category is a receiver guarantee.
  Acceptance: Read canonical String helper signatures/semantics and relevant current book before public producer/nested/fluent/source/arity/effect native/fresh distinctions. Preserve actual scalar/null results, including original Number/Boolean kinds on identity replacement/removal, empty/Unicode/conversion/domain/arity policies, source-first once-only operands/snapshots and compatible scalar/generic/explicit Array bridges. Assess incompatible container consumers and malformed shapes without changing free helpers, known source-context differences or callbacks. Freeze only concrete bounded gaps/needed flow and schedule independent backend children after observations; small checks/docs/commit, no full matrix/replay.
  Planned verification tier: focused
  Planned focused checks: Canonical String facts/contracts and small public producer/nested/receiver distinctions with direct String checks/syntax/book/continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: normative bounded feature selection and deterministic authored distinctions, no population/completeness measurement.

  Activation: clean `cab79913dc53b0b810aa3308e9612a533a195b0c`; all bounded defined-only default implementations committed, brief0/tree clean.
  Owned paths: Retained public scalar String-helper producer/nested/receiver/source/effect/kind/Unicode/shape assessment and any needed bounded contract/backend scheduling, scoped book/fact/task/live docs. No production change before observations. Canonical catalog preserves original kinds for empty-old replacement/unmatched or empty affix removal; do not infer every String helper always returns String.
  Verification tier: `focused`
  Focused checks: Canonical String facts/contracts and public Get/substitution/dump/native/fresh distinctions, small direct String checks/syntax/book/history/staged continuity guards.
  Canonical trigger: None for bounded feature assessment under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: normative bounded feature selection and deterministic authored distinctions, no population/completeness measurement.

  Owned intake findings: Eight valid fluent/nested texts and all eight split-to-Array bridges pass native/fresh; direct/nested replacement captures SONC/once-only/final-null. Boundary/malformed compounds fail handler/fresh compilation with raw DSL blocks. Producer cat(undef,"x") returnsnull, correctly matching scalar-text-v1; current catalog's undef-as-empty sentence is a known stale teaching defect (SESSION28.5), repair its exact line here without changing the producer. Identity Number selector fails typed nested_write_kind_conflict; the first probe then tries serializing a blessed context error and stops. Correct instrumentation and isolate free/fluent/named producer/index controls plus AST/substitution before classifying or freezing that issue. Own any confirmed kind/staging defect immediately in the bounded implementation schedule.

  Decision: Freeze scalar-string-results.md for eight existing ordinary scalar String-helper result flows, clean scalar boundaries and precise pre-effect shapes. Preserve actual identity Number/Boolean/String kinds, Unicode/null/strict cat/free/domain/callback policies. Schedule independent backend19.1-.5; Perl19.1 first owns the newly confirmed affix identity flag defect. Correct only the stale cat null teaching line here, leaving broad SESSION28.5/61.3 and reducer95 admission open.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/fresh eight fluent/nested texts and all split bridges agree; direct/nested replacement SONC/once-only/final-null, selected/named/Hash/block/canonical sources, empty/null and Unicode controls pass. Container tails retain raw DSL, producing undefined host trim/compile failures; malformed compounds similarly fail compile.
  - [x] ROOT CAUSE (WHY + WHERE): String-family metadata/composition lacks an actual scalar boundary after transforms. Separate public free/fluent/named affix identity selectors fail typed harray-vs-array; substitution inspects the original source with index/length/substr. B flags before JSON show prefix/suffix integer+string versus replacement/literal0 integer-only/String0 string-only; BindingRuntime correctly prioritizes POK. Inspect a copy in Perl19.1, without weakening selectors or fixing separate reducer95.
  - [x] FIX: Frozen actual scalar/identity/shape/effect contract and five backend owners; no production change. Correct stale cat undef-as-empty catalog prose using scalar-text-v1/public controls and qualify identity selector limitation until19.1. Recursive diagnostic snapshots replace shallow error copying; incomplete records are not credited.
  - [x] ADDRESSED (verified): Native/fresh identity JSON[0,0,false,1,String0] is distinguished from actual selector kind by failing affix/free/named writes and passing empty-old replacement control. Greek final sigma/STRASSE FFI/emoji substring and source/effect controls retain existing behavior. Direct scalar-text contract7 and probe syntax pass; unknown contexts/domains are not inferred.
  - [x] NO REGRESSION: No parser/runtime/Unicode/conversion/free helper/typed selector or callback change. No full matrix/replay/portable admission; cat unary51/large-number55.2, source-null61.3, reducer95 and Lua declared5.4 remain separate.
  - [x] LOCKSTEP: Retained probe/frozen contract/backend schedule, corrected current cat teaching/qualified identity limit and canonical String/null/teaching facts/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Perl19.1 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.19 - freeze scalar String-helper result flow`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2.20`
  Status: `completed` / frozen existing-reference repair target
  Goal: Reconcile explicitly supplied null optional substring width and Boolean offset policies across supported backends without inferring domains from return-value samples.
  Dependencies: Scalar String implementation19.1-.5; signature/domain owners1.2.1.4 and SESSION-STARTUP-READING61.3 remain authoritative.
  Reproduction: Retained probe_scalar_string_results.pl substring_bounds gives Perl native/fresh null for substr("abc",0,undef) and bc for substr("abc",true); repaired Rust controls agree. Dart scalar_string_results_test.dart independently returns abc for both, treating null width as omitted and Bool as invalid offset0. Julia probe_scalar_string_julia.jl/native-plan-fresh tests instead preserve null-width-as-omitted (abc) and Bool-offset1 (bc). Both safe Lua hosts/native-plan-fresh preserve null-width-as-omitted/Bool-invalid0, matching Dart. The catalog currently qualifies the provided-null width behavior to Perl/Rust; no complete portable optional-argument domain is admitted.
  Impact / ownership: A cross-backend caller cannot infer these optional/null/Boolean input policies from ordinary String result parity. Own exact signature/omitted-versus-null/domain authority and any resulting bounded repairs here; preserve current qualified compatibility until policy is frozen, with no silent promotion during result work.
  Schedule: Assess immediately after19.1-.5 feature implementations and before23.4/full signature/portable admission; schedule concrete backend fixes from the selected authority before changing behavior.
  Acceptance: Independently distinguish omitted width, explicit null width, null source/start, Boolean/integer/fractional offsets and existing scalar text carriers on native/generated routes. Reconcile primary records/contracts/book with explicit per-backend domain rows, then freeze needed changes and own implementation children. No full matrix or unsupported universal domain claim from a few examples; broad61.3 remains open until its own admission.
  Planned verification tier: focused
  Planned focused checks: Canonical domain records and small retained public argument distinctions, book/continuity.
  Planned canonical trigger: Any actual public input-domain contract movement requires its designated implementation/admission tier; final clean push remains separate.
  Planned claim verification: none: normative bounded policy assessment and deterministic authored distinctions, no population/completeness measurement.

  Activation: clean `b73b56c36075e79472adbb822d6cdb5bb34a01e0`; all bounded scalar String implementations committed, brief0/tree clean.
  Owned paths: Bounded canonical signature/domain assessment and consolidated optional substring argument ledger, scoped book/facts/task/live docs and any justified frozen follow-up scheduling. Use retained current producer/control facts rather than replaying unchanged backend observations. No production or new universal input policy before authority is reconciled.
  Verification tier: `focused`
  Focused checks: Canonical signature/domain/decision records and retained current native/generated distinguishing inputs, small new public checks only if a fact is missing, book/history/staged continuity guards.
  Canonical trigger: None for bounded assessment/qualification under director feature-first cadence; any actual public input-domain movement gets its own designated owner/tier, full admission/final push separate.
  Claim verification: none: normative bounded policy assessment and deterministic authored distinctions, no population/completeness measurement.

  Authority resolution: ADR0006 explicitly makes Perl the canonical behavioral oracle; ADR0023 requires equivalent accepted inputs/results and permits only owned temporary skew. ADR0029 is expressly the num_* scalar arithmetic contract, not a global integer-parameter converter. Use existing Perl character-slice behavior for this bounded reconciliation: omitted width selects through end, explicit null propagates, Boolean integer compatibility is helper-specific. Confirm unrecorded Boolean width/false and ordered free/receiver controls before freezing; do not change any backend production in the assessment.
  Owned continuity defect: Reading SESSION61.3 exposes its root Current Frontier still naming completed TYPE23.3.10.3 as next and retaining old numeric return instructions. Root current prose accumulated chronology without advancing through completed19.5, despite current MEMORY/TYPE pointer. Repair that bounded cross-reference/root view under this assessment, preserving exact prior bytes at clean b73b56c36075e79472adbb822d6cdb5bb34a01e0; do not pivot to or close the broader startup tree/61.3 or edit immutable history. Current task ownership stays TYPE20.

  Frozen result: substring-optional-arguments.md resolves the target from ADR0006/0023, not a new universal input policy. Omitted width alone means through end; explicit null propagates and Boolean start/width retains helper-specific1/0. Existing num_* strictness/global integer/Array selector/mutation contracts stay unchanged. Independent Dart/Julia/safe Lua observations schedule three local existing-reference repairs20.1-.3. Broader signature1.2.1.4/SESSION61.3/23.4 admission stays open.
  Verification:
  - [x] REPRODUCE / ISSUE: New independent public argument controls preserve omitted/integer/text/fraction/negative/source-start-null behavior. Perl native/fresh and Rust native/restored/plan agree with explicit oracle. Dart and both safe Lua hosts instead give bc for null width, invalid0 for Boolean arguments, [abc!,SIWC,1,null]/[!,SIWC,1,null] effects. Julia gives bc/null-width and [bc!,SIWC,1,null], retaining correct Boolean1/0 and [b!,SIWC,1,null].
  - [x] ROOT CAUSE (WHY + WHERE): Existing optional-argument handling collapses omission and explicit null in Dart/Julia/Lua; Dart/Lua integer converters reject Bool. Canonical Perl reference authority is explicit in ADR0006; ADR0029's Bool rejection belongs only to arithmetic. SESSION root current view is also stale at completed predicate10.3 despite current MEMORY/TYPE19.5.
  - [x] FIX: Freeze local slice-only target and schedule Dart20.1/Julia20.2/safe Lua20.3, without production edits or new schemas. Retain reference fixture/Rust test/Perl strict probe and independent diagnostics; refresh bounded SESSION root next pointer with exact prior Git preservation.
  - [x] ADDRESSED (verified): Reference fixture passes native/fresh Perl and all three Rust consumers; independent diagnostics retain distinct null/Bool/ordered effects and existing controls. Dart diagnostic format/fatal analysis passes. Each concrete skew has a scheduled implementation owner before broader admission.
  - [x] NO REGRESSION: Production unchanged; reference Rust compile/test, Perl/diagnostic syntax, safe Lua/Julia native-plan-fresh controls, current book/history/diff/staged continuity checks pass. No matrix, malformed native regex, full gate or completeness claim.
  - [x] LOCKSTEP: Frozen ledger/fixture/reference proof, canonical fact/map and current book target/temporary backend qualifications, TYPE/SESSION bounded frontier/live/resume align. Precise prior SESSION root bytes remain at b73b56c36075e79472adbb822d6cdb5bb34a01e0. Dart20.1 is next; broad61.3/62.3/.4 and23.4 remain open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.2.20 - reconcile ordinary substring argument parity`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3`
  Status: `active` / bounded selected-value rollout; full gap matrix remains open
  Children: `TYPE-REFERENCE-BOOK.1.2.23.3.1`, `.23.3.2`, `.23.3.3`, `.23.3.4`, `.23.3.5`, `.23.3.6`, `.23.3.7`, `.23.3.8`, `.23.3.9`, `.23.3.10`, `.23.3.11`, `.23.3.12`, `.23.3.13`, `.23.3.14`, `.23.3.15`, `.23.3.16`, `.23.3.17`, `.23.3.18`, `.23.3.19`, `.23.3.20`, `.23.3.21`, `.23.3.22`, `.23.3.23`, `.23.3.24`
  Goal: Resolve every verified method-family and type-transition gap through bounded implementation leaves.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.2`
  Acceptance: Before activation create per-operation/family and backend children from the gap matrix. Each owns its contract, native/generated implementation, independent RED/GREEN and source inverses, compatibility, current book examples and separate commit. Existing defect owners remain authoritative. Generic, boolean/null and codeblock operations must follow their real semantics, including dispatch on a callable's yielded value rather than a fabricated codeblock method table.
  Planned tier: Select for each bounded child; public contract/admission changes require canonical proof.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.1`
  Status: `active` / all bounded backend implementations targeted-checked; helper/target admission remains open
  Goal: Implement the frozen first/last selected-value continuation contract in ordinary native/generated actions, one bounded backend leaf per commit.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.2.1`
  Children: `.23.3.1.1` Perl, `.23.3.1.2` Rust, `.23.3.1.3` Dart, `.23.3.1.4` Julia, `.23.3.1.5` Lua.
  Schedule: Next after clean contract23.2.1 under feature-first direction. Probe each backend through its public interface; reuse existing correct behavior rather than invent a repair. Broader type/fluent matrices remain open.
  Claim verification: none: Implementation scheduling, no measured parity.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.1.1`
  Status: `done` / bounded ordinary implementation targeted-checked; full23.4 admission remains open
  Children: `.23.3.1.1.1` selected scalar methods; `.23.3.1.1.2` selected container methods.
  Slicing: Commit string/numeric continuations first, then the array/harray result cases; do not claim the whole frozen contract from the first subset.
  Goal: Add ordinary Perl first/last result continuations using selected-values.md and existing helper/value-kind semantics; preserve source snapshots and evaluate each step once.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.2.1`
  Planned tier: `focused`; module compilation and one small native/fresh regression, current book/fact and fast continuity checks. Broader23.4 admission follows feature coverage.
  Claim verification: none: No implementation measurement yet.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.1.1.1`
  Status: `done`
  Activation commit: `b54f0ab291c15de2461f3350e215780d8d3a41b4`
  Goal: Continue ordinary Perl first/last results through existing pure string and numeric methods, preserving scalar helper semantics, source/effect order and earlier array/hash/string paths.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.2.1`
  Owned paths: perl/LinkedSpec/ActionIR/MethodLowering.pm; one small native/fresh scalar-selection regression and callable-suite registration; current book/array fact/map and TYPE/live continuity.
  Verification tier: `focused`
  Focused checks: Changed-module/test/registration syntax and one small native/fresh selected-string/numeric regression with named/function/computed sources, compatible earlier pipeline/hash bridges, null and once-only effects; book and fast continuity/history checks only.
  Canonical trigger: None for this bounded director-authorized feature implementation; full selected-container/matrix/portable admission remains separately owned.
  Claim verification: none: Deterministic implementation and focused regression, no quantified corpus/exhaustive/portable admission measurement.
  Reproduce/root cause: Frozen23.2.1's public Get/substitution shows fluent first/last string null beside working nested helpers; the array return-family callback and each outer-family loop treat extraction as terminal. Separate selected-value flow from terminal predicates; preserve existing helper arity/domain rules.
  Acceptance: No repeated receiver/argument evaluation or original-family reuse. Ordinary first/last scalar results continue through existing string/numeric methods; earlier pure string/array/hash chains and unsupported mutation/callback boundaries remain governed. Selected array/harray continuation work is next1.1.2 and must stay explicitly open.

  Completion: first/last carry a selected-value flow state instead of terminal; preflight retains zero-argument validation without rejecting first continuations. Each outer-family loop routes selected results through existing pure string/numeric helper composition, preserving actual payload/domain/null/effect semantics and compatible prior pipeline/hash steps. Register the small regression; selected array/harray cases remain next1.1.2.
  Focused result: MethodLowering/new-test/registration syntax and t/selected_scalar_receiver_contract.t PASS on final production after actual native/fresh RED. Direct-dependent t/array_pipeline_value_contract.t, book and fast continuity/history checks pass; no full suite.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Public fluent/nested controls and the focused native/fresh regression fail before repair. A hash-to-array extraction continuation also leaks an unlowered sorted_keys call on that failing path, covered by this selected-result repair.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Fluent preflight unconditionally rejects a nonfinal first; array return classification marks first/last terminal and outer-family loops cannot route their results. The captured substitution and exact preflight/loop locations identify these mechanisms.
  - [x] **FIX** — Preserve extraction arity validation, mark selected-result flow and compose existing scalar helpers after extraction in every outer-family loop. No runtime value type, raw readiness waiver or new scalar-domain policy.
  - [x] **ADDRESSED (verified)** — Module/test/registration syntax and focused native/fresh scalar-selection regression PASS.
  - [x] **NO REGRESSION** — Direct-dependent pipeline regression PASS; function/computed/named sources, scalar arithmetic, empty selection, earlier pipeline/hash steps, retained snapshots and once-only receiver/argument effects pass. Invalid first arity suppresses receiver/argument effects and existing count terminal behavior stays null; these guard controls cover the changed preflight. Broad suites remain deferred.
  - [x] **LOCKSTEP** — Public scalar recipes, partial contract status, canonical fact/map and live/task frontier agree; selected array/harray1.1.2 and other backend children remain explicitly open.
  Continuity guard correction: The earlier completed spelling-index checklist used a reserved unfinished-state word to describe historical stale text; rephrase it as unimplemented. The whole-file evidence checker now recognizes the already completed checklist without altering historical behavior or checker policy.
  Edit-script note: An initial loop-layout assertion stopped before production writes; account for the root array loop's early terminal guard. The accidental unchanged-source rerun is not GREEN evidence; final GREEN uses the actual six-loop edit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.1.1.1 - continue selected scalar receiver values`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.1.1.2`
  Status: `done`
  Activation commit: `7b5b29b6ff69a6cc65168317c386991f95d9fa15`
  Owned paths: MethodLowering.pm; small native/fresh selected-container regression and suite registration; current contract/book/array fact/map and TYPE/live continuity.
  Verification tier: `focused`
  Focused checks: Changed-module/test/registration syntax and one small native/fresh selected-container regression plus the direct-dependent scalar regression; book and fast continuity/history checks only.
  Canonical trigger: None for this bounded director-authorized implementation; complete native/public matrices and23.4 admission remain after feature coverage.
  Reproduce: Public Get/call_spec_handler_subst at7b5b returns7 for num_add(last(sorted(first([[3,1],[2]]))),4) and B for uppercase(last(sorted_keys(first([{"b":2,"a":1}])))). Fluent twins fail as an unlowered first call or harray syntax in generated host code. Scalar selection is already implemented.
  Root cause: The selected-result dispatcher only composes scalar methods; container operations and ambiguous copy lack a value-flow path. Pipeline source recognition and copy lowering also infer container type from source spelling, which cannot determine an extracted item's runtime kind.
  Acceptance: Compose existing pure array/harray helpers over selected values, keep generic copy's runtime kind and actual source snapshot, preserve repeated extraction/type transitions, arity/domain/null/copy and once-only evaluation. No first-class type, raw readiness waiver or extra callback/mutation admission.
  Claim verification: none: Deterministic implementation and small targeted regression, no quantified corpus/exhaustive/portable admission measurement.
  Goal: Complete the frozen Perl selected array/harray continuations and repeated result-kind transitions using existing helper/copy/domain policies; preserve the scalar subset and avoid inferring selected content kind from the original array.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.3.1.1.1`

  Completion: The selected-value dispatcher composes existing array/harray methods, preserving dynamic copy as a selected value and distinguishing min/max reducer arity from numeric operand forms. Pure pipeline sources lower actual expressions and check runtime array kind; generic copy evaluates unknown-kind expression results once and snapshots their actual array/harray kind. Reuse existing helper domain/null/copy behavior, with no new value type or callback/mutation admission.
  Focused result: MethodLowering/test/registration syntax and t/selected_container_receiver_contract.t PASS on final production after native/fresh RED. Direct-dependent scalar and pipeline regressions PASS; book and fast continuity/history checks pass. No full suite or portable admission.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Public fluent container journeys fail as raw host calls/syntax while nested helpers return7/B. The new native/fresh regression is RED before repair, including failed generated compilation.
  - [x] **ROOT CAUSE (WHY + WHERE)** — The selected dispatcher excludes container operations; pipeline source/copy branches infer kind from spelling and cannot determine extracted item types. Exact public substitution and MethodLowering branches identify both constraints.
  - [x] **FIX** — Compose existing container helpers over selected values, retain runtime-kind copy, read expression array sources once with runtime guards and preserve scalar/arity dispatch. Array arguments are lowered by their existing owner once.
  - [x] **ADDRESSED (verified)** — Changed-module/test/registration syntax and small native/fresh selected-container regression PASS.
  - [x] **NO REGRESSION** — Direct scalar/pipeline regressions PASS; selected array/harray copy under one function, repeated extraction, named/computed/function sources, snapshots, empty results, min/max shape and once-only source/value effects pass. No broad suite.
  - [x] **LOCKSTEP** — Ordinary Perl scalar/container examples and bounded contract status, canonical fact/map, task/live handoff agree. Rust23.3.1.2 is next; other backends/full family admission remain open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.1.1.2 - continue selected container receiver values`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.1.2`
  Status: `done`
  Activation commit: `5e442f518deecfb657acd10bda8f983a7cd6e66e`
  Goal: Confirm/implement the same selected-value transition on Rust via public Engine and generated-plan execution.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.3.1.1`
  Owned paths: rust/linkedspec-runtime/src/engine.rs if repair is needed; rust/linkedspec-runtime/tests/selected_value_receivers.rs; current book/array fact/map and TYPE/live continuity. Blocking trim-null correction also owns the current rust-scalar-helper-null-and-empty-drift fact and indexed61.1 partial-repair cross-reference; existing61.1/.61.2 scope remains open.
  Verification tier: `focused`
  Focused checks: Locked/offline compilation and a small public Engine/restored/generated-plan selected-value regression; book and fast continuity/history checks only. No full crate suite or corpus matrix.
  Canonical trigger: None for bounded existing pure-helper result composition under director feature-first phase; full23.4 admission remains deferred.
  Claim verification: none: Deterministic implementation/confirmation with targeted regression, no quantified corpus/exhaustive/portable admission measurement.
  Acceptance: Probe the frozen examples through public parse/validate/compile/Engine interfaces first; reuse correct existing behavior and claim no false RED. Preserve actual selected kinds, dynamic copy, repeated transitions, null/empty, existing domain/arity rules, snapshots and once-only evaluation on native/restored/generated-plan routes. Other repositories/submodules remain read-only.

  Blocking helper subtask: After transition repair all nonempty frozen examples pass, but [].first().trim() returns empty text instead of null. Existing canonical rust-scalar-helper-null-and-empty-drift and SESSION-STARTUP-READING.61.1 already own this mechanism: call_helper's trim arm converts RuntimeValue::Undef with to_str before trimming. Fix this one helper's null propagation here, with direct undef/empty controls; do not silently change the expected contract. Remaining61.1/.61.2 helpers keep their existing owners and block full scalar/fluent admission.

  Completion: Existing array/string/hash outer-family loops hand first/last results to the existing dynamic value dispatcher, preserving the actual selected kind through compatible scalar/container operations and copy. Dynamic array dispatch no longer ends first/last results; extraction arity rejects before receiver/operand effects. The blocking trim-null guard preserves null while empty text remains empty;61.1 cross-references that partial repair.
  Focused result: Locked/offline cargo test --test selected_value_receivers compiles and PASSes public native/restored/generated-plan assertions after actual six-example RED. Direct-dependent --test array_transform_writeback PASSes; first-party rustfmt, book and fast continuity/history checks pass. No full crate suite or corpus matrix.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — The initial public Engine frozen-example vector returns null for every nonempty journey. After transition repair, the empty-selection trim control independently exposes the known null-to-empty helper defect.
  - [x] **ROOT CAUSE (WHY + WHERE)** — Static array/string/hash family loops and the dynamic array terminal check stop extraction before the next family. Existing trim coerces RuntimeValue::Undef with to_str before trimming, as documented by the canonical61.1 fact.
  - [x] **FIX** — Reuse dynamic receiver dispatch for the selected tail, preserve first/last arity boundaries and add the small trim-null guard. No dependency/submodule, schema, value type or broad helper-domain change.
  - [x] **ADDRESSED (verified)** — Locked/offline compilation and targeted public Engine/restored/generated-plan regression PASS; direct array-transform regression PASS.
  - [x] **NO REGRESSION** — Dynamic array/harray copy under one function, repeated transitions, min/max shape, snapshots, source/value effects, invalid extraction arity and direct trim undef/empty controls pass. Broader scalar61.1/.61.2 scope remains open.
  - [x] **LOCKSTEP** — Current Perl/Rust recipes, bounded contract, canonical array/null facts/map, indexed61.1 cross-reference and task/live handoff agree. Dart23.3.1.3 is next; no full fluent-family/portable admission.
  Scope note: The trim edit was saved before an edit-script assertion stopped adding the intended extra test fields; those controls were then added and the final target rerun successfully. No false GREEN is attributed to unadded controls or any unrelated helper.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.1.2 - continue Rust selected receiver values`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.1.3`
  Status: `done`
  Activation commit: `143198c356a7c7ecdf50c5d5c8f31d60068ebe84`
  Goal: Confirm/implement the same selected-value transition on Dart via public runtime/restored/generated-plan execution.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.3.1.2`
  Owned paths: dart/lib/src/runtime/interpreter.dart if needed; dart/test/selected_value_receivers_test.dart; current book/Dart/array facts/map and TYPE/live continuity.
  Verification tier: `focused`
  Focused checks: One small public native/restored/generated-plan selected-value regression and selected-file Dart analysis/format; directly affected compatibility check only when needed; book and fast continuity/history checks. No full package suite.
  Canonical trigger: None for bounded feature implementation/confirmation under director phase policy; full23.4 admission remains deferred.
  Claim verification: none: Deterministic implementation/confirmation and targeted regression, no quantified corpus/exhaustive/portable admission measurement.
  Acceptance: Probe the frozen journeys through public parseSpec/compileSpec/runtime interfaces before classifying a gap. Reuse correct existing behavior; preserve selected kinds, copy, repeated transitions, empty/null, existing arity/domain rules, snapshots and once-only effects. Correct the encountered stale Dart card's Julia5.3.3 pending wording against accepted work; no historical producer replay.

  Reproduce/impact: Initial frozen journeys PASS natively/restored/generated-plan without production changes. The expanded public fixture shows an extra-argument first call returns trimmed a and runs receiver/argument effects twice instead of returning null with no effects. This violates the frozen zero-method-argument boundary.
  Root cause: _evaluateExpression's fluent-chain branch evaluates its receiver and _evaluateFluentCall evaluates array helper arguments; the array helper then ignores the extra first/last values. Add a chain-level extraction arity guard before receiver/operand evaluation; do not rewrite the already correct dynamic value loop.

  Completion: Reuse Dart's existing per-value fluent dispatch; add only an early first/last zero-method-argument guard in _evaluateExpression before receiver/operand effects. The focused fixture uses the public function-aware parser for its dynamic-copy function and retains native/restored/generated-plan assertions.
  Focused result: Targeted selected-value and direct array-transform test files PASS; selected interpreter/test analysis with fatal infos/warnings reports no issues. Formatter/book/fast continuity/history checks pass. No full package suite.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Initial ordinary selected journeys PASS without production changes. The expanded function-aware public fixture is RED for invalid first arity, returning a and two effects instead of null and zero effects.
  - [x] **ROOT CAUSE (WHY + WHERE)** — _evaluateExpression's dynamic loop and _evaluateFluentCall already pass each result correctly; extra extraction operands are evaluated and ignored by array helper dispatch without a pre-effect shape guard.
  - [x] **FIX** — Add a chain-level first/last arity guard before source/argument evaluation; retain existing dynamic value composition.
  - [x] **ADDRESSED (verified)** — Focused native/restored/generated-plan regression and direct array-transform test PASS; changed-file analysis reports no issues.
  - [x] **NO REGRESSION** — Selected scalar/container/copy kinds, repeated extraction, min/max shape, function/computed sources, snapshots, empty values and once-only effects pass. No full package suite.
  - [x] **LOCKSTEP** — Perl/Rust/Dart book recipes, partial contract, contained Dart/array facts/map and task/live handoff agree. Correct stale Julia transform wording; Julia23.3.1.4 is next and full admission remains open.
  Containment: Condense redundant historical milestone prose in the existing Dart card while retaining its current helper/ordering/slice facts and canonical links; keep the collection within its existing budget.
  Harness note: The expanded function fixture initially used rule-only parseSpec and failed before runtime. Use public parseSpecWithStagedUserFunctionDefinitions as existing function tests do; no product-defect credit for that setup error.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.1.3 - guard Dart selected-value receiver arity`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.1.4`
  Status: `done`
  Activation commit: `bdeae4121aaad3659f5c117e08f66e1dc3cdb931`
  Goal: Confirm/implement the same selected-value transition on Julia via public native/generated-plan/emitted execution.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.3.1.3`
  Owned paths: julia/src/runtime/Interpreter.jl if needed; julia/test/selected_value_receivers_test.jl and runtests registration; current book/Julia/array facts/map and TYPE/live continuity.
  Verification tier: `focused`
  Focused checks: Package compilation and one small native/generated-plan/fresh-emitted selected-value regression; direct compatibility check only when needed; book and fast continuity/history checks. No full Julia suite or historical selected-suite replay.
  Canonical trigger: None for bounded implementation/confirmation under director feature-first phase; full23.4 admission remains deferred.
  Claim verification: none: Deterministic implementation/confirmation and targeted regression, no quantified corpus/exhaustive/portable admission measurement.
  Acceptance: Probe frozen examples through public parse/compile/runtime APIs before classifying a gap. Preserve actual selected kinds, copy, repeated transitions, empty/null/arity boundaries, snapshots and once-only effects. Reuse existing correct behavior. Contain redundant historical Julia fact replay chronology with an exact prechange Git pointer; never replay old captures as startup commands.

  Reproduce/impact: Frozen examples PASS on native/generated-plan/fresh-emitted routes before production edits. Expanded valid transitions also agree, but an extra-argument first returns a and runs receiver/operand effects twice instead of null with zero effects; the same vector is RED on all three routes.
  Root cause: _evaluate_runtime_fluent_chain! evaluates the receiver before iterating calls, and the array helper ignores the extra extraction operand after evaluating it. Validate first/last call shape before source evaluation while preserving the already correct per-value loop.

  Completion: Preserve Julia's existing per-value fluent loop; validate first/last zero-method-argument shapes before evaluating the receiver. Register one small selected-value fixture in the normal Julia runner, with native/generated-plan/fresh-emitted routes and direct transform compatibility.
  Focused result: Project-local package precompile succeeds; selected_value_receivers_test.jl and array_transform_writeback_test.jl PASS on final production after actual arity RED. Book and fast continuity/history checks pass; no full Julia suite or historical replay.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Frozen journeys PASS before source changes. The expanded public fixture is RED on all three routes for extra first arguments, producing a and two effects instead of null and zero effects.
  - [x] **ROOT CAUSE (WHY + WHERE)** — _evaluate_runtime_fluent_chain! evaluates the source before dispatch and the helper ignores extra extraction values; the dynamic selected-value loop itself is already correct.
  - [x] **FIX** — Validate first/last shapes before source/operand evaluation and preserve ordinary dynamic dispatch. No new type, schema or callback/mutation admission.
  - [x] **ADDRESSED (verified)** — Package compilation and focused native/generated-plan/fresh-emitted selected-value fixture PASS, with direct array-transform checks.
  - [x] **NO REGRESSION** — Dynamic function copies, repeated transitions, exact copy recipes, source/value ordering, snapshots, empty values, min/max shape and invalid-arity suppression pass. No broad replay/suite.
  - [x] **LOCKSTEP** — Current four-backend recipes, remaining terminal classifications in string/array reference, partial contract, contained Julia/array facts/map and task/live handoff agree. Lua23.3.1.5 is next; full admission remains open.
  Containment: Preserve exact older Julia replay commands/ranges/totals at prechange Git bdeae4121aaad3659f5c117e08f66e1dc3cdb931; retain current structural/boundary facts and point reverify to the small fixture. Copy-arity source risk is owned/scheduled under23.3.2 without a runtime conclusion or pivot.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.1.4 - guard Julia selected-value receiver arity`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.1.5`
  Status: `done`
  Activation commit: `3764311f3575cb3a5df369a32ab12aa5476060c6`
  Goal: Confirm/implement selected-value transitions via Lua's public native/generated APIs on the available PUC/LuaJIT pair, retaining declared-target qualification.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.3.1.4`
  Owned paths: lua/src/linkedspec/interpreter.lua if needed; lua/test/selected_value_receivers_test.lua and lua/test/run.lua registration; current book/Lua/array facts/map and TYPE/live continuity. Project-local disposable native builds use the published targeted wrapper.
  Verification tier: `focused`
  Focused checks: Fresh matching native products, source syntax and one small public native/generated-plan/fresh-emitted fixture per available ABI; directly affected compatibility check only when needed; book and fast continuity/history checks. No full Lua suite/corpus.
  Canonical trigger: None for bounded implementation/confirmation under director feature-first phase; full23.4 admission remains deferred.
  Claim verification: none: Deterministic implementation/confirmation and targeted regression, no quantified corpus/exhaustive/portable admission measurement.
  Environment: Direct lua/luajit banners and matching pkg-config report PUC5.5.1, LuaJIT2.1.1788460057 and PCRE2 10.48, consistent with the public integration guide. Declared PUC5.4.8 proof remains LUA-STARTUP-READING.2.2; no unversioned pass establishes5.4 conformance. Toolchain/native-formatter repairs are not silently closed here.
  Acceptance: Probe frozen journeys through public APIs first, reuse correct behavior, preserve selected kinds/copy/repeated transitions/null/empty/arity/effects and source snapshots. Check both available hosts with exact identity limits. Correct the Lua fact's stale Rust/Dart/Julia transform omissions against accepted5.3.1-.3; full admission remains separate.

  Reproduce/impact: Frozen selected journeys PASS on available PUC5.5.1 and LuaJIT through native/generated-plan/fresh-emitted routes before production edits. Expanded valid cases agree, but an extra first argument returns a with two effects instead of null and zero effects on both hosts.
  Root cause: interpreter.evaluate_expr's fluent_chain branch evaluates the receiver before typed_source.receiver_mutation.evaluate_fluent_calls; helper processing evaluates and ignores extra extraction operands. Validate first/last shapes before evaluating the receiver; preserve the existing per-value dispatcher.

  Completion: Preserve Lua's existing dynamic selected-value dispatcher and add first/last arity rejection before receiver/operand effects. Retain json.null slots, register the small fixture in lua/test/run.lua and syntax-load the interpreter/runner without executing the full package suite.
  Focused result: Published targeted wrappers build fresh ABI-matching native products and PASS the fixture on available PUC5.5.1 and LuaJIT. Native/generated-plan/fresh-emitted results agree, including dynamic function copies, repeated transitions, exact recipes, min/max, snapshots, nulls and effects. Book and fast continuity/history checks pass; no PUC5.4/full suite claim.
  Acceptance Checklist
  - [x] **REPRODUCE / ISSUE** — Frozen journeys PASS before production changes on both available hosts. The expanded fixture is RED for ignored first arguments, returning a and two effects instead of null and zero effects.
  - [x] **ROOT CAUSE (WHY + WHERE)** — interpreter.evaluate_expr evaluates fluent_chain receivers before delegating to the dynamic call loop; helper processing evaluates and ignores extra extraction values without prevalidation.
  - [x] **FIX** — Validate first/last call shape before receiver/operand evaluation, preserve the existing dynamic dispatcher and json.null representation, and enroll the focused producer in the normal runner.
  - [x] **ADDRESSED (verified)** — Fresh matching native builds, syntax loads and public native/generated-plan/fresh-emitted fixture PASS on available PUC5.5.1/LuaJIT.
  - [x] **NO REGRESSION** — Valid selected scalar/container/copy kinds, repeated extraction, functions/computed sources, snapshots, empty values, min/max and once-only effects pass. No full Lua suite/corpus or unsupported target claim.
  - [x] **LOCKSTEP** — Current five-backend implementation recipes include Lua host qualification; stale transform omissions are corrected in its fact. Contract/facts/map/task/live handoff agree; P1 Rust61.1/.61.2 repairs are next and full admission stays open.
  Harness note: Initial Lua long-string delimiters collided with nested array closing brackets and failed syntax before runtime. Use levelled long strings; no product-defect credit for that fixture setup error.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.1.5 - guard Lua selected-value receiver arity`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.2`
  Status: `active` / bounded copy-arity implementations complete; broad admission deferred
  Activation: clean `804f9657c47d62157e9f77b4f76749d24f11e7ab`; Rust scalar61.1/.61.2 repairs are committed. Start the distinguishing public Julia probe; create implementation children only for observed defects.
  Children: `TYPE-REFERENCE-BOOK.1.2.23.3.2.1`, `TYPE-REFERENCE-BOOK.1.2.23.3.2.2`, `TYPE-REFERENCE-BOOK.1.2.23.3.2.3`, `TYPE-REFERENCE-BOOK.1.2.23.3.2.4`, `TYPE-REFERENCE-BOOK.1.2.23.3.2.5`.
  Public Lua/Perl findings (October26): Both available PUC5.5.1/LuaJIT return [1,2], copying the extra operand after both effects; .2.4 owns the confirmed Lua repair. Perl Get returns [null,0] for the selected misuse, already correct; direct/generated controls follow without a fabricated implementation defect.
  Public Rust finding (October26): Fresh locked/offline public CLI probe returns [["a"],2], evaluating both receiver and extra operand. Child .2.3 owns early rejection. Tiny Rust/Perl controls return [[],[],[],[]] for scalar/selected-scalar/missing/free-scalar copy; canonical perl-scalar-bound-receiver-copy already documents scalar fallback and shallow container copies. The book's universal deep/scalar-copy wording is overbroad; .2.3 owns its correction, while complete copy-domain reconciliation remains23.2/23.4 scope.
  Public Dart finding (October26): The same probe returns [["a"],1], confirming an ignored copy operand after receiver effects. Child .2.2 owns this repair; Julia .2.1 is committed at08098f3.
  Public finding (October26): Julia's proposed probe returns [["a"],1] instead of invalid-shape null with zero effects. The receiver is evaluated and extra argument ignored. Child .2.1 owns the confirmed repair; other backends remain unassessed.
  Planned tier: `focused`; public reproduction and bounded per-backend implementation children before writes.
  Goal: Confirm and repair extra-argument copy receiver shapes without changing valid copy/value-kind semantics.
  Intake: Julia's _evaluate_runtime_fluent_value_call! returns _runtime_copy(value) for copy without inspecting call.args. This is source-observed risk; no runtime conclusion is yet claimed. Similar dispatchers must be assessed individually, not assumed identical.
  Reproduce at activation: effects=0; out={effects=num_add(effects,1); [["a"]]}.first().copy({effects=num_add(effects,1); 1}); return([out,effects]). Receiver copy takes no extra operands; compare expected invalid-shape rejection/effect suppression against its actual public contract and observed output before repair.
  Schedule: After selected-value23.3.1 native rollout and committed P1 Rust scalar61.1/.61.2 repairs, before complete fluent admission. Split per-backend implementation leaves only from actual public reproduction; commit each bounded repair before the next assessment.
  Claim verification: none: Bounded deterministic invalid-shape reproduction/repair, not a quantified corpus, exhaustive or portable parity claim.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.2.1`
  Status: `done`
  Activation: clean `804f9657c47d62157e9f77b4f76749d24f11e7ab`.
  Goal: Reject extra Julia copy receiver operands before receiver/operand effects while preserving valid runtime-kind deep copies.
  Owned paths: julia/src/runtime/Interpreter.jl, targeted Julia test/registration and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public probe; Julia package compilation and small receiver_copy_arity test on native/generated-plan/fresh-emitted routes; direct selected_value_receivers test; book and fast continuity/history/diff guards.
  Canonical trigger: None for this bounded invalid receiver-shape repair under director feature-first cadence; complete fluent admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored shape/effect regression; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Require zero extra copy receiver arguments at any link before effects; keep valid array/harray/scalar copies, selected kind, nulls and source detachment. No helper vocabulary, function-copy or other-backend change without evidence.
  Completion: Extend Julia's existing first/last chain preflight to copy. The existing dynamic copy remains unchanged; invalid direct/selected shapes return null before receiver/operand effects.
  Acceptance Checklist:
  - [x] REPRODUCE / ISSUE: Public Julia probe returns copied array/effects1; the retained receiver_copy_arity test fails all three execution assertions before repair (invalid copies/effects2). Authored invalid-shape expectations are null/null/effects0; valid controls already agree.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_value_call! copies the current value without inspecting call.args; _evaluate_runtime_fluent_chain! only preflights first/last, allowing copy receiver effects before ignoring operands.
  - [x] FIX: Include canonical copy in the existing zero-extra-operand chain guard before evaluating the receiver. Preserve the actual deep-copy implementation and per-value continuation.
  - [x] ADDRESSED (verified): Julia package precompilation and targeted receiver_copy_arity native/generated-plan/fresh-emitted checks PASS after actual RED.
  - [x] NO REGRESSION: Valid array detachment, scalar continuation, missing/null and once-only receiver controls PASS; direct selected_value_receivers test PASS. No full package suite or broad matrix.
  - [x] LOCKSTEP: Register the regression; public copy boundary, scalar duplicate status, Julia fact/map, current frontier and live handoff agree. Book and fast continuity/history/diff checks pass before landing.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.2.1 - guard Julia receiver copy arity`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.2.2`
  Status: `done`
  Activation: clean `08098f3ef2075389279207e421cbc1b6986a2d5a`.
  Goal: Reject extra Dart copy receiver operands before receiver/operand effects while preserving valid deep-copy and selected-value behavior.
  Owned paths: dart/lib/src/runtime/interpreter.dart, dart/test/receiver_copy_arity_test.dart and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public probe; Dart receiver_copy_arity and direct selected_value_receivers tests (native/restored/generated-plan); changed-file analysis/format, book and fast continuity/history/diff guards.
  Canonical trigger: None for this bounded invalid receiver-shape repair under director feature-first cadence; full fluent admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored shape/effect regression; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Reject any extra copy receiver operands before effects at direct/selected links. Preserve valid copies/kinds, detachment, null/scalar continuation and once-only receiver evaluation; no unrelated helper or backend changes.
  Acceptance Checklist:
  - [x] REPRODUCE / ISSUE: Public Dart probe returns copied array/effects1. The retained regression returns two invalid copies/effects2 instead of null/null/effects0 before repair; valid controls already agree.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluateFluentCall's copy arm ignores call.args, while ActionFluentChainExpr only preflights first/last before receiver evaluation. The public runtime probe distinguishes this from correct deep-copy semantics.
  - [x] FIX: Add canonical copy to existing zero-extra-operand preflight. Preserve _copyValue and valid per-value dispatch.
  - [x] ADDRESSED (verified): Small native/restored/generated-plan receiver_copy_arity test PASS after actual RED; changed-file analyzer reports no issues and formatter passes.
  - [x] NO REGRESSION: Valid copy detachment/kinds, scalar/null continuation and once-only controls plus direct selected_value_receivers test PASS. No full Dart suite.
  - [x] LOCKSTEP: Public copy boundary, canonical Dart fact/map, current frontier and live handoff synchronized; book and fast continuity/history/diff checks pass before landing.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.2.2 - guard Dart receiver copy arity`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.2.3`
  Status: `done`
  Activation: clean `a929c92e8c3a4209375302d443792a306a5b1cf6`.
  Goal: Reject extra Rust copy receiver operands before effects and document the actual valid copy-domain boundary.
  Owned paths: rust/linkedspec-runtime/src/engine.rs, targeted receiver_copy_arity test and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Fresh public CLI probe; locked/offline Rust receiver_copy_arity and direct selected_value_receivers tests on native/restored/generated-plan; first-party rustfmt, book and fast continuity/history/diff guards.
  Canonical trigger: None for this bounded invalid-shape repair/documentation correction under director feature-first cadence; complete copy/fluent admission stays23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored shape/effect and current-domain controls; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Reject extra copy receiver operands before receiver/argument effects; retain valid container copies/kinds, detachment and once-only evaluation. Retain existing scalar/missing empty-array fallback, qualify backend-specific scalar/depth book wording and preserve canonical Perl authority; no unrelated helper-domain change.
  Acceptance Checklist:
  - [x] REPRODUCE / ISSUE: Fresh public CLI returns copied array/effects2; retained receiver_copy_arity test returns invalid copies/effects4 before repair. Expected shape is null/null/effects0. Tiny public Rust/Perl value controls confirm existing scalar/missing fallback instead of assuming universal copy semantics.
  - [x] ROOT CAUSE (WHY + WHERE): Expr::FluentChain preflights first/last only; copy reaches receiver_call_args and call_helper, evaluating extra arguments and copying the source. The overbroad book paragraph conflates Lua/Dart/Julia scalar preservation with Perl/Rust container-oriented copy.
  - [x] FIX: Add copy to existing pre-effect arity guard. Keep copy implementation/fallback unchanged; qualify the book using current public value controls and canonical Perl shallow-container authority.
  - [x] ADDRESSED (verified): Locked/offline compilation and authored receiver_copy_arity native/restored/generated-plan regression PASS after actual RED.
  - [x] NO REGRESSION: Valid container detachment, once-only receiver, selected copy and existing scalar/missing fallback plus direct selected_value_receivers test PASS; first-party rustfmt passes. No full crate suite.
  - [x] LOCKSTEP: Public copy boundary, canonical array fact/map, task/current frontier and live handoff agree. Book and fast continuity/history/diff checks pass before landing; full copy-domain reconciliation remains23.2/23.4-owned.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.2.3 - guard Rust receiver copy arity`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.2.4`
  Status: `done`
  Activation: clean `222db28a32a4047ca9fccba03927c3eb975a29bb`.
  Goal: Reject extra Lua copy receiver operands before effects; confirm the already-correct bounded Perl copy-arity path.
  Owned paths: lua/src/linkedspec/interpreter.lua, targeted Lua test/registration and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Lua/Perl probes; fresh matching available PUC5.5.1/LuaJIT native builds, Lua syntax and small receiver_copy_arity native/generated-plan/fresh-emitted test plus direct selected-value regression; Perl native/fresh controls, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded invalid-shape repair under director feature-first cadence; complete copy/fluent admission stays23.4 and eventual clean push proof. Declared PUC5.4 target proof remains LUA-STARTUP-READING.2.2.
  Claim verification: none: deterministic authored shape/effect regression; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Reject extra copy operands before receiver/argument effects, preserve valid copy/kind/detachment/null/scalar behavior and once-only evaluation. Do not change Perl's already-correct public result; retain copy-domain/depth qualifications and Lua host limitations.
  Acceptance Checklist:
  - [x] REPRODUCE / ISSUE: Both available Lua public probes return [1,2]; retained native fixture returns extra operand copies/effects4 instead of null/null/effects0. Perl Get independently returns the correct selected null/effects0; no false Perl RED.
  - [x] ROOT CAUSE (WHY + WHERE): Lua fluent copy recognizes zero arguments only; extra-argument shapes fall through to function-copy evaluation and copy the operand. The chain preflight guards first/last only, after which receiver effects run.
  - [x] FIX: Extend canonical zero-extra-operand preflight to copy before receiver evaluation; retain copy_value and dynamic continuation. Register the small Lua regression.
  - [x] ADDRESSED (verified): Fresh matching available PUC5.5.1/LuaJIT products, syntax and authored native/generated-plan/fresh-emitted fixture PASS after actual RED.
  - [x] NO REGRESSION: Valid container detachment, scalar/null, once-only and direct selected-value controls PASS on both hosts. Perl direct/selected invalid shapes plus valid copies PASS through native Get and fresh emitted execution without runtime edits. No full Lua/Perl suite.
  - [x] LOCKSTEP: Public copy boundary, canonical Lua fact/map, task/current frontier and live handoff agree; book and fast continuity/history/diff checks pass. Declared5.4 and broader copy admission remain open under .2.5/23.4.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.2.4 - guard Lua receiver copy arity`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.2.5`
  Status: `pending`
  Goal: Admit bounded copy arity at the later supported-target/canonical boundary.
  Dependencies: .2.1-.2.4; LUA-STARTUP-READING.2.2 for declared PUC5.4 proof.
  Schedule: After feature coverage, compose existing targeted fixtures with23.4 admission and eventual clean push proof; do not launch duplicate broad suites during implementation.
  Planned tier: `canonical`; declare actual receipt/claim scope at activation.
  Claim verification: none: Future admission owner, no new measurement.
  Acceptance: Retain per-backend domain/depth distinctions, reject wrong shapes before effects through supported consumers, restore the declared Lua target and close the bounded parent without inferring complete fluent families.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.3`
  Status: `active` / bounded implementations complete; full admission remains23.4
  Goal: Implement the frozen count/count_keys/length result contract on ordinary backends, preserving correct existing behavior.
  Dependencies: .23.2.2.
  Children: `TYPE-REFERENCE-BOOK.1.2.23.3.3.1`, `TYPE-REFERENCE-BOOK.1.2.23.3.3.2`, `TYPE-REFERENCE-BOOK.1.2.23.3.3.3`, `TYPE-REFERENCE-BOOK.1.2.23.3.3.4`, `TYPE-REFERENCE-BOOK.1.2.23.3.3.5`; assess later backends individually after each clean implementation commit.
  Schedule: Feature/compile/quick-check/docs/commit per backend; full signatures/matrix/admission stays open and deferred.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.3.1`
  Status: `done`
  Activation: clean `4666667d09d3c133cd5e07a725fb08f718f533a5`.
  Goal: Implement Perl count/count_keys/length result continuations using existing selected-value scalar/number dispatch.
  Dependencies: .23.2.2.
  Owned paths: perl/LinkedSpec/ActionIR/MethodLowering.pm, targeted t/count_length_receiver_contract.t and existing suite registration, book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Small native/fresh count_length_receiver_contract and direct selected_scalar_receiver_contract/selected_container_receiver_contract tests, changed-module/new-test/registration syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for this bounded frozen feature under director feature-first cadence; full signatures/matrix/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored result/order/arity/scope regression; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Cover three producers after direct/selected/earlier pipeline sources, compatible scalar/number consumers, empty/null and source/argument order. Guard zero-extra producer shapes before effects, explicitly update the old ordinary count-uppercase terminal expectation, preserve helper domains/copy/deferred/callback boundaries and keep raw hash-chain DSL out of valid lowering. Small native/fresh checks and syntax, then commit before assessing the next backend.
  Completion: Route array count/length, string length and hash count_keys results through existing selected-value dispatch; replace the ordinary count/length continuation preflight stop with zero-extra shape validation, including count_keys. Existing helper implementations and the separate CodeblockRuntime evaluator are unchanged.
  Acceptance Checklist:
  - [x] REPRODUCE / ISSUE: Authored native/fresh fixture fails before repair, including stopped numeric chains and unlowered hash-chain syntax/host failures. Earlier isolated public count/length/hash controls distinguish the result-flow gap from working helper implementations.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering's ordinary fluent preflight rejects nonfinal count/length, and three return-family callbacks classify the producers as terminal. Hash rejection falls through with DSL residue; existing selected-value branches already support the required consumers.
  - [x] FIX: Preserve zero-extra arity but remove the producer continuation stop; classify count/count_keys/length as selected values and reuse all existing continuation loops. Explicitly supersede the ordinary count-uppercase negative control; keep deferred count behavior and other terminal families separate.
  - [x] ADDRESSED (verified): Small native/fresh count_length_receiver_contract PASS after actual RED for direct/selected/pipeline and ordinary function results, Unicode/array lengths, scalar conversion, empty/null and invalid-shape effects.
  - [x] NO REGRESSION: Count/length/key-count source/operand order is SALHK; later mutations retain the previously computed values and saved snapshots. Deferred count control stays null; direct selected-scalar/container tests and changed-module/new-test/registration syntax checks PASS. No full suite.
  - [x] LOCKSTEP: Register the regression; public working examples, contract status, canonical fact/map, current frontier and live handoff agree. Book and fast continuity/history/diff checks pass before landing; next Rust leaf begins with a public probe, not an assumed defect.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.3.1 - continue Perl count and length results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.3.2`
  Status: `done`
  Activation: clean `0d474c2e801270342a642e029eff28ac3b1a3218`.
  Goal: Publicly assess and implement/confirm the frozen count/count_keys/length result contract on Rust.
  Dependencies: .23.3.3.1.
  Owned paths: rust/linkedspec-runtime/src/engine.rs if repair is needed, focused Rust count/length receiver test and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Fresh public Rust CLI probe; locked/offline count_length_receivers and direct selected_value_receivers tests on native/restored/generated-plan, first-party rustfmt, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen feature implementation under director feature-first cadence; full signatures/matrix/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored result/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Begin with public Engine/primary-CLI controls beside nested helper equivalents, preserve already-correct behavior and claim no false RED. Cover three producers on direct/selected/earlier pipelines (including array length), numeric/scalar consumers, empty/null, source/operand effects and zero-extra shape rejection. Reuse existing helper domains/copy and callable vocabulary; run compilation plus a small native/restored/generated-plan check and direct dependents, then commit before the next backend.
  Acceptance Checklist:
  - [x] REPRODUCE / ISSUE: Fresh public CLI returns [null,5,null,6,null,5]. The authored fixture returns null producers, SH instead of SALHK and six invalid-shape effects before repair, distinguishing helper success from missing result flow and shape guards.
  - [x] ROOT CAUSE (WHY + WHERE): Engine static array/hash/string loops and dynamic endpoint checks stop count/count_keys/length; array-pipeline method checks exclude length. Expr::FluentChain's zero-extra guard covers extraction/copy only.
  - [x] FIX: Share is_selected_receiver_result_method for value handoff and dynamic endpoint exemptions; admit length within array links while keeping initial method dispatch unchanged. Extend the separate zero-extra guard to three count/length producers. Existing helper domains and callable vocabulary are unchanged.
  - [x] ADDRESSED (verified): Locked/offline compilation and small count_length_receivers native/restored/generated-plan assertions PASS after actual RED for direct/selected/pipeline/function results, scalar conversion, Unicode/array length, empty/null and invalid shapes.
  - [x] NO REGRESSION: SALHK effects, later source mutations, saved snapshots and zero invalid-shape effects agree; direct selected_value_receivers test and first-party rustfmt PASS. No full crate suite or broad context/portable admission.
  - [x] LOCKSTEP: Public Perl/Rust examples, contract status, canonical fact/map, task/current frontier and live handoff agree. Book and fast continuity/history/diff checks pass before landing; Dart begins with an independent public probe.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.3.2 - continue Rust count and length results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.3.3`
  Status: `completed`
  Activation: clean `d3f6fb4fc5eb63785e7b03f81a7fa9f724f27219`.
  Goal: Publicly assess and implement/confirm the frozen count/count_keys/length result contract on Dart.
  Dependencies: .23.3.3.2.
  Owned paths: dart/lib/src/runtime/interpreter.dart if needed, targeted count/length receiver test and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Dart producer/consumer and invalid-shape probes; small native/restored/generated-plan count/length plus direct selected-value tests, changed-file analysis/format, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen feature implementation/confirmation under director feature-first cadence; full signatures/matrix/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public reproduction / owned defects: Valid pairs return [5,5,6,6,5,5], so retain dynamic dispatch. count(extra) returns1 and runs receiver/operand effects twice instead of null/zero. Free count on [String,Hash,Number,Bool,undef,Array] returns [2,1,1,1,0,2], beside documented and public Perl [0,0,0,0,0,2]. Count incorrectly reuses _lengthValue; restrict Count to arrays while preserving Length and independent helper domains. Both small defects are owned and fixed in this leaf.
  Acceptance: Probe public valid producer/consumer pairs and preserve correct existing per-value dispatch. Independently check zero-extra shape/effect rejection; repair only observed defects. Cover direct/selected/earlier pipelines, values/kinds, Unicode/array length, source/argument snapshots and documented scope on native/restored/generated-plan consumers. Analyze/format changed files, compile/quick-check/docs/commit before the next backend.

  Completion: Preserve existing actual-value continuations. Extend zero-extra producer preflight to count/count_keys/length and restrict free/receiver count to Lists instead of reusing general length. Length Unicode/scalar/container behavior stays unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public valid pairs pass; invalid count(extra) runs effects, and non-array free count disagrees with the documented/public Perl oracle. Retained fixture RED shows bad producers returning2 with six effects and domain [2,1,1,1,0,2].
  - [x] ROOT CAUSE (WHY + WHERE): ActionFluentChainExpr guards extraction/copy only; helper argument collection evaluates ignored count/length extras. _callArrayHelper count delegates to _lengthValue, whose wider domains belong to length.
  - [x] FIX: Include three zero-extra producers in preflight; count only List values. Reuse existing dynamic continuation and length logic.
  - [x] ADDRESSED (verified): Small count_length_receivers native/restored/generated-plan fixture PASS after RED, including direct/selected/pipeline/function values, source snapshots, Unicode, SALHK order, nulls, zero invalid effects and array-only count.
  - [x] NO REGRESSION: Direct selected_value_receivers, changed-file fatal analysis and format PASS; no broad suite or complete family/portable admission is inferred.
  - [x] LOCKSTEP: Public examples/contract, Dart/central fact/map, current task/live records and bounded-history handling align; fast memory/cadence/diff/book checks pass.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.3.3 - guard Dart count and length producers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.3.4`
  Status: `completed`
  Activation: clean `bc7ae21edd999bee8217ce35b6fa990512d70633`.
  Goal: Publicly assess and implement/confirm the frozen count/count_keys/length result contract on Julia.
  Dependencies: .23.3.3.3.
  Owned paths: julia public runtime, small count/length receiver test and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Julia value/arity probes, small native/generated-plan/fresh-emitted count/length and direct selected-value tests, package compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen feature implementation/confirmation under director feature-first cadence; full context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public reproduction / owned defects: Valid producer pairs return [5,5,6,6,5,5]; count(extra) returns1 with two effects. Retained native/generated-plan/fresh-emitted RED confirms all three invalid producers return2 with six effects, and non-array count returns [2,1,1,1,0,2] instead of documented/public Perl [0,0,0,0,0,2]. Chain preflight omits producers; array count delegates to wider _runtime_value_length. Both bounded defects are owned and repaired in this leaf.
  Focused harness repair: Julia1.12 warns when the emitted parser execute binding is fetched outside invokelatest. Resolve that binding through invokelatest in the new/direct selected-value fixtures; verify both with --depwarn=error. Broader old fixture compatibility remains part of23.4 admission.
  Acceptance: Preserve correct existing value dispatch, probe valid chains and zero-extra shape/effect boundaries publicly, and repair only observed defects. Use a small native/generated-plan/fresh-emitted fixture plus direct selected-value checks, package compilation and docs; commit before Lua. Full context/portable admission stays separate.

  Completion: Preserve existing value continuations, extend producer arity preflight and restrict count to AbstractVectors; leave general length unchanged. Register the focused test and fetch fresh emitted execute bindings through invokelatest in new/direct fixtures.
  Verification:
  - [x] REPRODUCE / ISSUE: Public valid pairs pass, but count(extra) returns1/two effects. Native/generated-plan/fresh-emitted fixture RED confirms ignored extras/six effects and non-array count [2,1,1,1,0,2] beside the documented/public Perl oracle.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! omits count/count_keys/length from zero-extra validation; _call_runtime_array_helper count reuses wider _runtime_value_length. Julia1.12 separately diagnoses fresh emitted binding access outside invokelatest in the focused harnesses.
  - [x] FIX: Guard producer extras before source/operand evaluation, count only AbstractVectors and preserve existing dynamic dispatch/Length. Fetch emitted execute bindings through invokelatest in both focused fixtures.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted count/length and array-domain checks PASS after RED, retaining direct/selected/pipeline/function values, Unicode, SALHK effects, snapshots, nulls and zero invalid effects.
  - [x] NO REGRESSION: Package compilation and direct selected-value checks PASS; strict --depwarn=error rerun passes. Broader old harness compatibility and full portable admission remain23.4.
  - [x] LOCKSTEP: Public examples/contract, Julia/central fact/map, task/live records, book and fast continuity/history/diff checks align.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.3.4 - guard Julia count and length producers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.3.5`
  Status: `completed`
  Activation: clean `f61b2eaace135b711e2c300f2689de1d4a2857ec`.
  Goal: Publicly assess and implement/confirm the frozen count/count_keys/length result contract on shared Lua.
  Dependencies: .23.3.3.4.
  Owned paths: lua public interpreter, small count/length receiver test and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Lua value/arity probes; small native/generated-plan/fresh-emitted count/length and direct selected-value tests on available PUC5.5.1/LuaJIT with matching native products, loadfile compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; declared5.4 and full context/portable admission remain separately owned plus eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public reproduction / owned defects: Available PUC public pairs return [5,5,null,6,null,5], so count already continues but length/hash-count stop beside working nested controls. count(extra) returns1 with two effects. Shared evaluate_fluent_calls rejects nonfinal length through TERMINAL_STRING_HELPERS and count_keys through an explicit hash endpoint fence; chain preflight guards extraction/copy only. Repair these observed gaps here, preserving Count’s existing array-only domain and other endpoint policies.
  Acceptance: Preserve correct value dispatch, probe valid chains and zero-extra shape/effect boundaries through the public runtime, and repair only observed defects. Use small native/generated-plan/fresh-emitted and direct selected-value checks on available PUC5.5.1/LuaJIT with matching native products. Keep declared5.4 proof with LUA-STARTUP-READING.2.2 and full context/portable admission with23.4; commit before selecting the next feature.

  Completion: Keep correct Count and actual-value dispatch; remove only length/count_keys endpoint stops and extend zero-extra preflight. Retain other predicates/reducer/control boundaries and existing source domains. Register one small test.
  Verification:
  - [x] REPRODUCE / ISSUE: Public PUC pairs [5,5,null,6,null,5] distinguish stopped length/key-count from working Count and nested helpers. Retained fixture RED shows stopped values, skipped required operands, SAH order and six invalid effects.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls stops Length through TERMINAL_STRING_HELPERS and count_keys through a hash endpoint fence. evaluate_expr fluent preflight omits all three producers; later helper collection runs ignored extras.
  - [x] FIX: Remove only Length and key-count endpoint restrictions, retain existing Count/domain/dispatcher and add producer shape guards before receiver/operand effects.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted fixture PASS after RED on available PUC5.5.1/LuaJIT, including direct/selected/pipeline/function values, Unicode, SALHK effects, later-mutation snapshots, array-only Count and zero invalid effects.
  - [x] NO REGRESSION: Direct selected-value fixture and loadfile compilation of interpreter/runner pass with fresh matching native products on both available hosts. Declared5.4 proof remains LUA-STARTUP-READING.2.2; full method/context/portable admission stays23.4.
  - [x] LOCKSTEP: Public examples/contract, Lua/central facts/map, tasks/live records, book and fast continuity/history/diff checks align. Next source-backed feature selection is aggregate numeric result flow23.2.3, before exhaustive signatures/matrices.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.3.5 - continue Lua count and length results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.4`
  Status: `active` / bounded implementations complete; full admission remains23.4
  Goal: Implement the frozen ordinary aggregate numeric reducer result contract on each backend, preserving correct existing behavior.
  Dependencies: .23.2.3.
  Children: `TYPE-REFERENCE-BOOK.1.2.23.3.4.1`, `TYPE-REFERENCE-BOOK.1.2.23.3.4.2`, `TYPE-REFERENCE-BOOK.1.2.23.3.4.3`, `TYPE-REFERENCE-BOOK.1.2.23.3.4.4`, `TYPE-REFERENCE-BOOK.1.2.23.3.4.5`; assess later backends individually after clean implementation commits.
  Planned tier: Focused bounded children; complete context/portable admission remains23.4.
  Claim verification: none: Unactivated implementation family; no support/completeness measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.4.1`
  Status: `completed`
  Activation: clean `a71e0a0fe293783d27881cf131476fb30c42a6f6`.
  Goal: Continue ordinary Perl six aggregate reducer results through existing compatible pure scalar/number methods.
  Dependencies: .23.2.3.
  Owned paths: perl/LinkedSpec/ActionIR/MethodLowering.pm, small native/fresh regression and suite registration, helper reference/reducer fact/map/task/live records.
  Verification tier: `focused`
  Focused checks: Small native/fresh aggregate_numeric_receiver_contract and direct count_length_receiver_contract tests after actual RED, changed-module/test/registration syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation under director feature-first cadence; full signatures/context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Boundary finding / repair: Initial selected-value handoff passes valid results but changes old incompatible .sum().drop_front()/.min().sorted() null controls to empty arrays. Public substitution shows generic array fallback applied to the scalar reducer result. Preserve the frozen boundary with scalar_result flow metadata, restricted scalar/number consumers and propagation until an explicit string-to-array bridge. Do not relax those controls.
  Acceptance: Preserve zero-extra aggregate arity and scalar min/max overloads, actual source/results, null/error/empty policy, once-only ordered operands and mutation snapshots. Supersede only compatible ordinary reducer terminal controls, keep deferred and reducer-kind95 policies separately owned, and use small native/fresh plus direct Count/Length checks. Commit before assessing Rust; no full replay.

  Completion: Reuse selected-value continuation machinery with scalar_result metadata until an explicit string-to-array bridge. Remove ordinary reducer continuation stops, retain zero-extra shape checks and route zero-extra initial min/max through array handling while scalar overloads keep their numeric path. No helper implementation or separate deferred evaluator change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public probe and native/fresh fixture RED show stopped six-producer results, skipped source/consumer effects and missing mutations. Working scalar min/max controls distinguish overloads. An intermediate handoff exposes [] for old incompatible-array null controls; substitution identifies generic array fallback.
  - [x] ROOT CAUSE (WHY + WHERE): Ordinary MethodLowering preflight rejects nonfinal reducers; append_array_chain_call marks results terminal, while initial numeric dispatch claims zero-extra min/max. Generic selected dispatch needs a scalar boundary to preserve old incompatible consumers.
  - [x] FIX: Keep producer arity, hand reducer values to scalar_result flow using the existing selected dispatcher, propagate scalar metadata and release it only through an explicit Array bridge. Preserve scalar min/max operands and zero-extra Array min/max classification across all six loops.
  - [x] ADDRESSED (verified): Small native/fresh aggregate_numeric_receiver_contract PASS after actual RED for six direct/selected/pipeline/function results, even median, text/Array bridge, empty/null, scalar overloads, SA order, later mutation snapshots and invalid-shape suppression.
  - [x] NO REGRESSION: Direct count_length_receiver_contract and changed-module/new-test/registration syntax PASS. Old incompatible-array results and separate deferred reducer continuation remain null; existing source domains/kind95 remain unchanged. No broad suite or portable admission.
  - [x] LOCKSTEP: Register regression, update helper/guide/contract examples and stale guide Length summary, retain scalar-boundary fact/map and current task/live records; book and fast continuity/history/diff checks pass.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.4.1 - continue Perl aggregate numeric results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.4.2`
  Status: `completed`
  Activation: clean `e08a85b291554c98fd5636907104057246ab777e`.
  Goal: Publicly assess and implement/confirm ordinary aggregate numeric result continuations on Rust.
  Dependencies: .23.3.4.1.
  Owned paths: Rust engine if needed, focused native/restored/generated-plan regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Fresh public Rust CLI fluent/nested producer probes; locked/offline small aggregate_numeric_receivers and direct count_length_receivers native/restored/generated-plan tests, first-party rustfmt, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; complete context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / ownership: Fresh CLI returns [null,13,null,5,null,5,null,5,null,3,null,7]. Static Array-family loops classify reducers as terminal, dynamic endpoint checks exclude them from selected-result handoff, and the chain preflight lacks unambiguous aggregate zero-extra guards. Implement observed result-flow/shape gaps here, preserving source domains and old incompatible-array null boundaries.
  Empty-sum defect / owned repair: Public compiled CLI returns [null,null,null,null] for [num_sum([]),num_add(num_sum([]),1),num_sum(["bad"]),num_avg([])] instead of [0,1,null,null]. The shared num_sum/avg/median/range arm rejects every empty numeric list before considering sum; return zero only for an actually empty Array sum. Keep nonempty filtering/domain differences unchanged. Retain the direct helper control in this fixture.
  Edit-script note: A Rustfmt-layout assertion stopped the first edit before production writes; the resulting unchanged-source rerun is retained as RED, never GREEN evidence. The corrected edit validates all matches before writing.
  Acceptance: Preserve correct existing dispatch, helper domains and scalar min/max overloads. Check six valid producer-result chains publicly before classifying defects; retain scalar-only boundaries until an explicit Array bridge, order/snapshots/nulls/empty shapes and existing callable vocabulary. Compile and focused/direct checks, docs/commit before the next backend; no broad replay or complete admission.

  Completion: Include six reducers in existing result handoff/static/dynamic endpoint exemptions, carry scalar-result boundaries until an actual container bridge, and guard zero-extra sum/avg/median/range before effects. Preserve scalar min/max overloads and callable vocabulary. Repair empty Array sum to zero without changing nonempty filtering.
  Verification:
  - [x] REPRODUCE / ISSUE: Fresh public CLI six pairs and authored fixture are RED for stopped result flow and ignored-argument effects. Independent public empty helper probe returns [null,null,null,null] beside normative [0,1,null,null].
  - [x] ROOT CAUSE (WHY + WHERE): Engine static/dynamic endpoints exclude reducers from selected-result flow; Expr::FluentChain guard omits unambiguous aggregates. The shared numeric arm rejects empty terms before sum can return its additive identity.
  - [x] FIX: Share reducer result classification across existing handoffs, retain scalar-only consumer validation and clear it when a helper produces a container. Add early shape guards and the actually-empty-Array sum identity; keep other helper domains/callable vocabulary/serialized formats unchanged.
  - [x] ADDRESSED (verified): Locked/offline aggregate_numeric_receivers native/restored/generated-plan PASS after actual RED for six producers, overloads, empty/direct helpers, nulls, selected/pipeline/function values, even median, text/Array bridge, SA effects, source mutation snapshots and zero invalid effects.
  - [x] NO REGRESSION: Direct count_length_receivers, compilation and first-party rustfmt PASS; old incompatible consumers remain null. Nonempty generic filtering, existing callback vocabulary and broad context/portable admission stay separately owned.
  - [x] LOCKSTEP: Public helper/guide/contract examples, canonical reducer fact/map, tasks/live records, book and fast continuity/history/diff checks align. Dart assessment follows after this clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.4.2 - continue Rust aggregate numeric results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.4.3`
  Status: `completed`
  Activation: clean `f0596ea0430566608988500c04fd5ddf4da67e45`.
  Goal: Publicly assess and implement/confirm ordinary aggregate numeric result continuations on Dart.
  Dependencies: .23.3.4.2.
  Owned paths: Dart public interpreter if needed, focused native/restored/generated-plan regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Dart producer/shape/domain probes, small native/restored/generated-plan aggregate_numeric_receivers and direct Count/Length tests, changed-file fatal analysis/format, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; complete context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / owned defects: Valid six fluent/nested pairs agree [13,13,5,5,5,5,5,5,3,3,7,7], and empty helper controls already pass [0,1,null,null]. sum(extra) returns1 with two effects; incompatible Array consumers yield []/[] instead of the frozen null boundary. Preserve existing valid dispatch/empty identity, guard unambiguous aggregate shape before effects and carry scalar-result validation across ordinary/mutating-source value loops.
  Acceptance: Preserve correct dispatch, helper domains and scalar min/max overloads. Probe six producer results, unambiguous zero-extra shapes, scalar-only boundaries until an explicit Array bridge and empty helper controls before classifying defects. Small native/restored/generated-plan and direct Count/Length checks, changed-file analysis/format, docs/commit before Julia; no broad replay or complete admission.

  Completion: Keep valid result dispatch/empty identity, add canonical zero-extra num_sum/num_avg/num_median/num_range preflight and share ordinary/mutating-source continuation iteration. Track actual Array reduction results as scalars until a helper returns a container; reject array/hash-only consumers at that boundary.
  Verification:
  - [x] REPRODUCE / ISSUE: Public valid pairs/empty controls pass; sum(extra) runs two effects and incompatible Array consumers yield []/[]. Retained native fixture RED additionally shows invalid reducer operands mutate a named source and run eight effects.
  - [x] ROOT CAUSE (WHY + WHERE): ActionFluentChainExpr preflight omits canonical aggregate helpers, and its two value loops call generic helper dispatch without retaining scalar reduction boundaries.
  - [x] FIX: Extend zero-extra preflight and reuse _evaluateFluentCallsWithValue in both loops. Preserve existing helpers and dynamic min/max selection; retain scalar boundaries until actual container output.
  - [x] ADDRESSED (verified): Small native/restored/generated-plan aggregate fixture PASS after RED for six producers, overloads, empty helpers, selected/pipeline/function and named-mutation sources, explicit split, SA order, snapshots, incompatible nulls and zero invalid effects.
  - [x] NO REGRESSION: Direct count_length_receivers, changed-file fatal analysis and format PASS. Existing valid result flow, source domains/empty sum and callable vocabulary remain unchanged; full context/portable admission stays23.4.
  - [x] LOCKSTEP: Worked helper/guide/contract examples, Dart/reducer facts/map, current task/live records, book and fast continuity/history/diff checks align; Julia assessment follows the clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.4.3 - guard Dart aggregate result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.4.4`
  Status: `completed`
  Activation: clean `b9c37c64c3653344dbcbde093026bdb5627873ee`.
  Goal: Publicly assess and implement/confirm ordinary aggregate numeric result continuations on Julia.
  Dependencies: .23.3.4.3.
  Owned paths: Julia public interpreter if needed, focused native/generated-plan/fresh-emitted regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Julia producer/shape/domain probes, small native/generated-plan/fresh-emitted aggregate and direct Count/Length tests, strict Julia1.12 harness/package compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; complete context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / owned defects: Valid six fluent/nested pairs agree and empty helpers pass [0,1,null,null]. sum(extra) returns1/two effects; incompatible Array consumers yield []/[] instead of frozen null boundaries. Preserve correct value/min-max/empty behavior; guard canonical unambiguous aggregate shapes and retain scalar-result boundaries in the existing loop.
  Acceptance: Preserve correct dispatch, helper domains and scalar min/max overloads. Probe six result chains, unambiguous zero-extra shapes, scalar-only boundaries until an explicit Array bridge and empty helper controls before classifying defects. Small native/generated-plan/fresh-emitted and direct Count/Length checks with strict Julia1.12 harness/package compilation, docs/commit before Lua; no broad replay or complete admission.

  Completion: Preserve correct result dispatch/empty identity, extend canonical unambiguous aggregate preflight and retain scalar reduction boundaries in the existing loop until a helper returns a container. Register the focused fixture; no helper implementation or public format changes.
  Verification:
  - [x] REPRODUCE / ISSUE: Public valid pairs and empty controls agree; sum(extra) runs two effects and incompatible Array consumers yield []/[]. Native/generated-plan/fresh-emitted fixture RED retains invalid named mutation/effects and scalar-boundary differences.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! omits canonical aggregate methods from shape preflight and carries no scalar-result boundary between calls; generic wrong-kind Array helpers supply empty arrays.
  - [x] FIX: Guard num_sum/avg/median/range extras before source/operand effects and preserve scalar-only compatibility after actual Array reductions until a helper returns a container. Keep existing helper/domain/min-max/empty policies.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted aggregate fixture PASS after RED for six producers, overloads, empty helpers, direct/selected/pipeline/function/named-mutation sources, explicit split, SA order, snapshots, incompatible nulls and zero invalid effects.
  - [x] NO REGRESSION: Direct Count/Length tests, package compilation and strict Julia1.12 --depwarn=error harness checks PASS. Existing callable vocabulary and full context/portable admission remain separate.
  - [x] LOCKSTEP: Register fixture; update worked helper/guide/contract examples, Julia/reducer facts/map and current task/live records; book and fast continuity/history/diff checks pass. Lua assessment follows the clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.4.4 - guard Julia aggregate result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.4.5`
  Status: `completed`
  Activation: clean `629cdf0337d8a4847f9459f68db3139177acb558`.
  Goal: Publicly assess and implement/confirm ordinary aggregate numeric result continuations on shared Lua.
  Dependencies: .23.3.4.4.
  Owned paths: Lua public interpreter if needed, focused native/generated-plan/fresh-emitted regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Lua producer/shape/domain probes; small native/generated-plan/fresh-emitted aggregate and direct Count/Length tests on available PUC5.5.1/LuaJIT with matching native products, loadfile compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; declared5.4 and complete context/portable admission remain separately owned plus eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / ownership: Fresh PUC pairs are [null,13,null,5,null,5,null,5,null,3,null,7]; invalid sum(extra) already returns null but runs two effects. Empty helpers and old incompatible consumers already pass. evaluate_fluent_calls has a blanket reducer endpoint stop; remove it for compatible scalar consumers, retain scalar boundaries (including lowercase_each/uppercase_each routed via String helpers) and guard unambiguous canonical aggregate shapes before effects.
  Acceptance: Preserve correct dispatch, source domains and scalar min/max overloads. Probe six result chains, unambiguous zero-extra shapes, scalar boundaries until an explicit Array bridge and empty helper controls before classifying defects. Use small native/generated-plan/fresh-emitted and direct Count/Length checks on available PUC5.5.1/LuaJIT with matching products, loadfile compilation, docs/commit. Keep declared5.4 proof with LUA-STARTUP-READING.2.2 and full context/portable admission separate; no broad replay.

  Completion: Remove the reducer endpoint stop, retain scalar-result compatibility until actual container output and guard canonical unambiguous aggregate extras before effects. Preserve correct empty identity/min-max/domain behavior and old incompatible consumers, including Array case maps routed through String helpers. Register the fixture.
  Verification:
  - [x] REPRODUCE / ISSUE: Public PUC six pairs and retained fixture are RED for stopped results, skipped operands and ignored-argument effects. Empty helpers and old incompatible consumers already pass; preserve them. Invalid shapes mutate named arrays and run eight effects before repair.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls unconditionally stops after evaluate_numeric_reducer_values; evaluate_expr preflight omits canonical aggregate shapes. Generic consumers need a scalar boundary when the endpoint stop is removed; lowercase_each/uppercase_each live in String dispatch.
  - [x] FIX: Carry reducer results through compatible Scalar/Number consumers and release scalar boundaries only on actual container output. Include Array case maps in compatibility guards; reject num_sum/avg/median/range extras before source/operand effects.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted aggregate fixture PASS after RED on available PUC5.5.1/LuaJIT, with six producers, overloads, empty helpers, named mutation suppression, explicit split, SA order, snapshots and old incompatible nulls.
  - [x] NO REGRESSION: Direct Count/Length fixture and interpreter/runner loadfile compilation PASS with matching fresh native products on both hosts. Existing source domains, empty sum and callable vocabulary remain unchanged; declared5.4/full admission stay separately owned.
  - [x] LOCKSTEP: Register fixture; update worked helper/guide/contract, Lua/reducer facts/map and current task/live records; book and fast continuity/history/diff checks pass. Join-result assessment23.2.4 is next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.4.5 - continue Lua aggregate numeric results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.5`
  Status: `active` / bounded implementations complete; full admission remains23.4
  Goal: Implement the frozen ordinary joined String result contract on each backend, preserving correct existing behavior.
  Dependencies: .23.2.4.
  Children: `TYPE-REFERENCE-BOOK.1.2.23.3.5.1`, `TYPE-REFERENCE-BOOK.1.2.23.3.5.2`, `TYPE-REFERENCE-BOOK.1.2.23.3.5.3`, `TYPE-REFERENCE-BOOK.1.2.23.3.5.4`, `TYPE-REFERENCE-BOOK.1.2.23.3.5.5`; assess later backends individually after clean commits.
  Planned tier: Focused bounded children; complete context/portable admission remains23.4.
  Claim verification: none: Unactivated implementation family; no support/completeness measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.5.1`
  Status: `completed`
  Activation: clean `6978191195862cb74c0f6bd20081c5b3dba28d86`.
  Goal: Continue ordinary Perl join_values String results through compatible pure methods using existing result dispatch.
  Dependencies: .23.2.4.
  Owned paths: MethodLowering.pm, small native/fresh regression and suite registration, helper/guide/contract/fact/map/task/live records.
  Verification tier: `focused`
  Focused checks: Small native/fresh joined_string_receiver_contract after actual RED plus direct aggregate_numeric_receiver_contract, changed-module/test/registration syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation under director feature-first cadence; complete public/context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Acceptance: Add joined-result flow and exact one-delimiter pre-effect shape rejection, remove raw DSL from the valid hash-view chain and preserve correct producer snapshots/SDN order. Check direct/selected/pipeline/hash/function and empty sources, actual String/length/split transitions, old incompatible/deferred boundaries and later mutations. Small native/fresh plus direct aggregate checks, syntax/docs/commit before Rust assessment; source-domain normalization and Lua false-delimiter repair stay separately owned.

  Completion: Classify join_values as scalar_result using existing six-loop continuation handling and add exact one-delimiter preflight before effects. Preserve the join helper, free delimiter-first roles, existing snapshots/order/domains and separate deferred evaluator; no new formats/types.
  Verification:
  - [x] REPRODUCE / ISSUE: Public isolated Get/substitution confirms stopped direct/selected results and raw hash DSL/host sorted_values lookup. Retained native/fresh fixture RED exposes invalid-shape handler compile failure and stopped joined results.
  - [x] ROOT CAUSE (WHY + WHERE): append_array_chain_call returns terminal for join_values; later loops stop or fall through to raw DSL. Ordinary preflight lacks an exact one-delimiter check.
  - [x] FIX: Return scalar_result from the join handoff and reject other arities before lowering source/operand effects, reusing existing continuation/compatibility machinery.
  - [x] ADDRESSED (verified): Small native/fresh joined_string_receiver_contract PASS after RED for named/literal/function/selected/pipeline/hash/String sources, empty/Unicode, split/length bridges, SDAN order, mutation snapshots, clean invalid-shape nulls/zero effects and incompatible Array nulls.
  - [x] NO REGRESSION: Direct aggregate_numeric_receiver_contract and changed-module/new-test/registration syntax PASS. Existing join source domains/copy/null policies and separate deferred evaluation are unchanged; no additional context/portable admission.
  - [x] LOCKSTEP: Register fixture; update helper/guide/contract examples, Array fact/map and current task/live records; book and fast continuity/history/diff checks pass. Rust assessment follows the clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.5.1 - continue Perl joined String results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.5.2`
  Status: `completed`
  Activation: clean `5581d074d63bb32824280fad9243407f0ed7847c`.
  Goal: Publicly assess and implement/confirm ordinary joined String result continuations on Rust.
  Dependencies: .23.3.5.1.
  Owned paths: Rust public engine if needed, focused native/restored/generated-plan regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Fresh public Rust joined-result/nested probe; locked/offline small joined_string_receivers and direct aggregate_numeric_receivers native/restored/generated-plan tests, first-party rustfmt, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; complete public/context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / owned repair: Fresh Rust CLI returns [null,"A,B",null,"A-B",null,"X:Y"] for direct/selected/hash-view fluent/nested pairs. Join is absent from result handoff classification and retains Array endpoint rejection; preflight validates zero-extra methods only. Assess exact shape effects/snapshots in the focused fixture and reuse existing scalar-result boundaries rather than weakening incompatible Array consumers.
  Direct-dependent route / owned assessment: Expr::FluentChain’s named Array-end mutation tail iterates the generic dispatcher outside the scalar-result loop. The shared join handoff classifier affects this documented ordinary value route; add a valid mutating-source join and incompatible Array-consumer control before landing. Reuse the common continuation loop if the current candidate exposes a missing scalar boundary.
  Candidate regression / verified root: The added public Engine fixture returns "A,B,C" correctly for named_parts.push_back("c").join_values(",").uppercase(), but push_back("d").join_values(",").sorted() returns [] instead of prior/frozen null. The named mutation tail bypasses scalar-result tracking, allowing generic wrong-kind Array fallback. Reuse eval_selected_receiver_value_chain with an initial non-scalar flag for that tail; keep the distinguishing negative intact and verify before landing.
  Acceptance: Preserve correct dispatch and join source/domains/snapshot behavior. Probe valid joined-result chains, exact one-delimiter shapes, scalar boundaries until explicit Array bridge and receiver/delimiter/consumer order before classifying defects. Small native/restored/generated-plan and direct aggregate checks, compile/rustfmt/docs/commit before Dart. No new callable vocabulary, source-domain normalization or broad replay/admission.

  Completion: Include join_values in scalar-result classification/shared handoff and exact one-delimiter preflight. Generalize the private classifier to is_scalar_result_receiver_method and reuse selected continuation for named Array-end tails so they retain scalar guards. Preserve helper/source/copy/null behavior and callable vocabulary.
  Verification:
  - [x] REPRODUCE / ISSUE: Fresh public CLI and authored native fixture RED show stopped direct/selected/hash joins, skipped consumer effects and four invalid-shape effects. Added named-mutation control exposes [] instead of null after the initial candidate; valid mutating join already passes.
  - [x] ROOT CAUSE (WHY + WHERE): Join is excluded from result handoff/endpoint exemptions and exact arity preflight. The separate named mutation tail calls generic dispatch without scalar-result tracking, allowing wrong-kind Array fallback.
  - [x] FIX: Share scalar-result classification for six reducers/joins, retain scalar boundaries until container output and guard one delimiter before effects. Route Array-end tails through the same existing continuation loop with an initial non-scalar value.
  - [x] ADDRESSED (verified): Locked/offline joined_string_receivers native/restored/generated-plan PASS after initial/result and candidate-boundary RED, including named mutation sources, functions/selected/pipeline/hash/String sources, empty/Unicode, split/length bridges, SDAN order, snapshots, incompatible nulls and zero invalid effects.
  - [x] NO REGRESSION: Direct aggregate_numeric_receivers, compilation and first-party rustfmt PASS. Existing helper/source/deferred vocabulary and serialized formats remain unchanged; no additional complete context/portable admission.
  - [x] LOCKSTEP: Worked helper/guide/contract, Array fact/map and current task/live records align; book and fast continuity/history/diff checks pass. Dart assessment follows the clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.5.2 - continue Rust joined String results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.5.3`
  Status: `completed`
  Activation: clean `c5a06feebbbffd204004154a5c0bf5c0916e2f0c`.
  Goal: Publicly assess and implement/confirm ordinary joined String result continuations on Dart.
  Dependencies: .23.3.5.2.
  Owned paths: Dart public interpreter if needed, focused native/restored/generated-plan regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Dart joined-result/shape probes, small native/restored/generated-plan joined and direct aggregate fixtures, changed-file fatal analysis/format, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; complete public/context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / owned boundaries: Valid Dart direct/selected/hash joined-result pairs already agree. A missing delimiter returns "a" and runs its receiver effect; a joined scalar followed by sorted yields [] instead of frozen null. Preserve correct result flow, add exact one-delimiter preflight and extend existing shared scalar-producer tracking to join_values.
  Acceptance: Preserve correct dispatch, producer snapshots/order/source domains and inherited null/copy behavior. Probe joined-result chains, exact one-delimiter shapes, scalar boundaries until explicit Array bridge and named-mutation sources before classifying defects. Small native/restored/generated-plan and direct aggregate checks, changed-file fatal analysis/format, docs/commit before Julia. No source normalization or broad replay/admission.

  Completion: Keep already-correct joined-result dispatch/snapshots and add exact one-delimiter preflight. Extend shared Array scalar-producer tracking to join_values while preserving generic helper/source/null/copy behavior.
  Verification:
  - [x] REPRODUCE / ISSUE: Public valid direct/selected/hash pairs pass, but missing delimiter returns a/runs one effect and incompatible sorted returns []. Retained native fixture RED also catches named-mutation fallback and malformed arity effects.
  - [x] ROOT CAUSE (WHY + WHERE): ActionFluentChainExpr guards zero-extra methods only; _evaluateFluentCallsWithValue tracks numeric aggregates but omits joined String producers.
  - [x] FIX: Validate one delimiter before receiver/operand effects and include join_values in scalarProducer tracking until an actual container result. Preserve existing valid helper/value behavior.
  - [x] ADDRESSED (verified): Small native/restored/generated-plan joined fixture PASS after RED for named mutations, functions/selected/pipeline/hash/String sources, empty/Unicode, split/length bridges, SDAN order, snapshots, incompatible nulls and zero invalid effects.
  - [x] NO REGRESSION: Direct aggregate fixture, changed-file fatal analysis and format PASS. Existing producer domains/null/copy behavior and callable vocabulary remain unchanged; no complete context/portable admission.
  - [x] LOCKSTEP: Worked helper/guide/contract, Dart/Array facts/map and current task/live records align; book and fast continuity/history/diff checks pass. Julia assessment follows the clean commit; container-default transition assessment is scheduled after bounded joins.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.5.3 - guard Dart joined String boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.5.4`
  Status: `completed`
  Activation: clean `e84864bf19e2eec290f5163b6dc6506c923f71ad`.
  Goal: Publicly assess and implement/confirm ordinary joined String result continuations on Julia.
  Dependencies: .23.3.5.3.
  Owned paths: Julia public interpreter if needed, focused native/generated-plan/fresh-emitted regression and synchronized book/fact/task/live records.
  Verification tier: `focused`
  Focused checks: Public Julia joined-result/shape probes, small native/generated-plan/fresh-emitted joined and direct aggregate fixtures, strict Julia1.12 harness/package compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; complete public/context/portable admission remains23.4 and eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public finding / owned boundaries: Julia valid direct/selected/hash joined-result pairs already agree; missing delimiter returns "a"/runs one effect, and sorted after joined String yields []. Preserve correct result/snapshot behavior; add exact one-delimiter preflight and include join_values in scalar-producer tracking within the existing loop.
  Acceptance: Preserve correct dispatch, producer snapshots/order/source domains and inherited null/copy behavior. Probe joined chains, exact one-delimiter shapes, scalar boundaries until explicit Array bridge and named mutation sources before classifying defects. Small native/generated-plan/fresh-emitted and direct aggregate checks with strict Julia1.12 harness/package compilation, docs/commit before Lua. No source normalization or broad replay/admission.

  Completion: Preserve correct result/snapshot behavior and add one-delimiter preflight plus join_values scalar-producer tracking in the existing value loop. Register the focused fixture; no helper/domain/copy/format changes.
  Verification:
  - [x] REPRODUCE / ISSUE: Public valid direct/selected/hash pairs agree; missing delimiter runs one effect and incompatible sorted yields []. Native/generated-plan/fresh-emitted fixture RED confirms malformed arity and scalar-boundary differences.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! guards zero-extra methods and tracks numeric reductions only; joined String producers receive no arity/scalar-result boundary.
  - [x] FIX: Reject non-one-delimiter shapes before effects and include join_values in scalar_producer tracking until actual container output. Keep existing helpers and producer behavior.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted joined fixture PASS after RED for named mutations, functions/selected/pipeline/hash/String sources, empty/Unicode, split/length bridges, SDAN order, snapshots, incompatible nulls and zero invalid effects.
  - [x] NO REGRESSION: Direct aggregate fixture, package compilation and strict Julia1.12 --depwarn=error harness PASS. Existing source/null/copy behavior and callable vocabulary stay unchanged; complete context/portable admission remains separate.
  - [x] LOCKSTEP: Register fixture and align worked helper/guide/contract, Julia/Array facts/map, current task/live records; book and fast continuity/history/diff checks pass. Lua assessment follows the clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.5.4 - guard Julia joined String boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.5.5`
  Status: `completed`
  Activation: clean `5856cfcb630f08df2ff9532241c38a78e6138de1`.
  Goal: Publicly assess and implement/confirm ordinary joined String result continuations on shared Lua.
  Dependencies: .23.3.5.4.
  Owned paths: Lua public interpreter if needed, focused native/generated-plan/fresh-emitted regression and synchronized book/fact/task/live records, including any confirmed join-only update to the existing false-delimiter owner2.9.
  Verification tier: `focused`
  Focused checks: Public Lua joined-result/shape/false-delimiter probes; small native/generated-plan/fresh-emitted joined and direct aggregate fixtures on available PUC5.5.1/LuaJIT with matching products, loadfile compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; declared5.4 and complete public/context/portable admission remain separately owned plus eventual clean push proof.
  Claim verification: none: deterministic authored value/order/arity regression; no quantified corpus, exhaustive or portable admission measurement.
  Public findings / owned repair: PUC direct/selected/hash fluent pairs stop beside working nested controls. Missing delimiter returns a/runs one effect. The tracked false-delimiter issue reproduces: free join gives a0b, receiver ab, nested uppercase A0B and joined continuation null. evaluate_array_values uses an and/evaluate/or-empty fallback, replacing evaluated false. Repair the join route here with literal/computed false controls; retain mutable split under LUA-STARTUP-READING.2.9.1 for its next bounded leaf.
  Acceptance: Preserve correct source/snapshots/null/copy behavior, probe joined chains, one-delimiter shapes, scalar boundaries and named mutations. Reverify the existing LUA-STARTUP-READING.2.9 join false-delimiter route and own a small confirmed join repair here; mutable split stays with its existing owner. Small native/generated-plan/fresh-emitted and direct aggregate checks on available PUC5.5.1/LuaJIT with matching products, loadfile/docs/commit. Declared5.4/full admission remain separate; no broad replay/source normalization.

  Completion: Remove join endpoint rejection, retain scalar boundaries until container output and enforce one delimiter before effects. Replace the truthy evaluated-delimiter fallback with an explicit argument-presence branch, preserving false and once-only evaluation. Register the focused fixture; mutable split remains a separate next leaf.
  Verification:
  - [x] REPRODUCE / ISSUE: Public joined/nested pairs show stopped results; missing delimiter runs its receiver. Free false join gives a0b while receiver gives ab. Retained native fixture RED independently captures false loss, skipped consumers, malformed arity effects and named-mutation boundaries.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls stops after join and evaluate_expr lacks one-delimiter validation. evaluate_array_values uses expr.args[1] and evaluate_expr(...) or empty text, replacing an evaluated false before scalar conversion.
  - [x] FIX: Carry joined scalars through compatible methods, validate arity before effects and default only for absent delimiter expressions. Preserve helper/source/copy semantics and retain scalar compatibility guards.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted joined fixture PASS after RED on available PUC5.5.1/LuaJIT, including literal/computed false equality and once-only effects, named mutations, functions/selected/pipeline/hash/String sources, Unicode, explicit bridges, SDAN order, snapshots and invalid shapes.
  - [x] NO REGRESSION: Direct aggregate fixture and interpreter/runner loadfile compilation PASS with matching fresh products on both hosts. Source normalization, mutable split and declared5.4/full admission remain separately owned; no new callable vocabulary/format.
  - [x] LOCKSTEP: Register fixture and align worked helper/guide/contract, current Lua/Array/false-delimiter facts/map, partial2.9 ownership and current task/live records; book and fast continuity/history/diff checks pass. Reverify/repair remaining mutable split next, then container-default23.2.5.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.5.5 - continue Lua joined String results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6`
  Status: `active` / bounded default rollout targeted-checked on recorded hosts; full admission open
  Goal: Implement/confirm bounded actual-kind default-selection continuations across maintained backends.
  Dependencies: .23.2.5.
  Children: `.23.3.6.1`, `.23.3.6.2`, `.23.3.6.3`, `.23.3.6.4`, `.23.3.6.5`.
  Acceptance: Existing ordinary nonempty default selections preserve actual kinds, lazy required-prefix effects and scalar/container boundaries per default-selection-results.md. Assess each backend publicly; full domain/portable admission remains23.4.

  Follow-up: TYPE23.3.16.1 fixes the confirmed existing Hash-default->Array-view->successor staging gap via the established compatibility bridge. Direct/default/call/numeric/Array/String roots and first/last/count/join/contains/index/reducer/transform/selection plus SDC/numeric-kind controls are targeted-checked; original62/full admission stay separate.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.1`
  Status: `completed` / bounded Perl flow/literal repairs targeted-checked
  Goal: Repair Perl default result flow and valid literal operand lowering in separate slices.
  Dependencies: .23.2.5.
  Children: `.23.3.6.1.1`, `.23.3.6.1.2`.
  Acceptance: Both bounded repairs committed/targeted-checked; broader signature/deferred/admission remains separate.
  Completion: Children1.1/1.2 are committed separately with focused native/fresh/direct proof. Full helper-domain/deferred/portable admission remains23.4.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.1.1`
  Status: `completed`
  Goal: Continue ordinary Perl coalesce_nonempty results by their actual selected kind.
  Dependencies: .23.2.5.
  Reproduce: Direct String Array consumer reaches host helper; joined Array/Hash paths lower undef beside working nested A-B/X:Y. String-family metadata and scalar_result propagation retain the producer kind.
  Owned paths: MethodLowering ordinary receiver flow, one focused native/fresh fixture, direct joined/default compatibility and public/current docs.
  Acceptance: Reuse existing lazy helper semantics; preserve retained Scalar incompatible nulls, selected Array/Hash methods, empty/null/zero/false, source/default/consumer SDJ order, skipped late operands and snapshots. Small compile/targeted checks/docs/commit; no full suite.
  Activation: clean `59556bc75e143d68ba5001330133e2b13bf82e14`; assessment committed, brief empty, tree clean.
  Verification tier: `focused`
  Focused checks: Public native/fresh selected-default regression after RED, direct joined/default-exhaustion compatibility, MethodLowering/test syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; literal operand repair1.2, full domain/portable admission23.4 and final clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.

  Completion: Give nonempty defaults a default_result family, bind the selected value once, guard Array/Hash consumers by runtime kind and retain scalar-result boundaries after scalar helpers. Lower source and consumer helpers before enclosing them in host guards/do blocks; preserve existing lazy helper semantics.
  Candidate correction: First guarded candidate enclosed still-authored helpers/blocks in host do source; native/fresh compilation failed. Public Get dump shows unlowered coalesce_nonempty/join_values/uppercase and bare effect bindings. Lower both expressions before host guard construction; the intermediate guarded-helper attempt still left the consumer raw and is also RED, not passing proof. Final focused native/fresh fixture is GREEN.
  Verification:
  - [x] REPRODUCE / ISSUE: Frozen Get/substitution/fresh pairs and retained target fixture RED show stopped Array/Hash flow/direct host-helper failure; old retained-scalar negatives stay null.
  - [x] ROOT CAUSE (WHY + WHERE): String metadata and scalar_result propagation retain source kind. Public generated source additionally identifies the candidate's DSL-inside-host wrapper boundary before correction.
  - [x] FIX: Dispatch default_result through a once-bound actual value with Array/Hash guards; fully lower source/consumer before host wrapping. Preserve existing free-helper and deferred domains.
  - [x] ADDRESSED (verified): t/default_selected_receiver_contract.t PASS native/fresh after RED: direct/joined Array, named Harray, selected-null, scalar retention, empty containers, zero/false, exhausted/null, skipped fallback and SDJ snapshot controls.
  - [x] NO REGRESSION: Direct joined and nonempty-exhaustion tests plus MethodLowering/test compilation PASS; no broad suite, new callable vocabulary or serialized format. Literal operands remain owned1.2.
  - [x] LOCKSTEP: Bounded contract/catalog, default fact/derived map and live/task/resume docs align; book and fast memory/cadence/diagnosis/history/diff checks pass. Literal repair1.2 next after clean commit, other backend assessments later.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.6.1.1 - continue selected Perl default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.1.2`
  Status: `completed`
  Goal: Preserve valid Hash literal operands through Perl lazy default lowering.
  Dependencies: .23.3.6.1.1.
  Reproduce / impact: coalesce_nonempty("",{"b":"y","a":"x"}) returns null with hash_literal_use_colon marker despite valid source; named Hash and nested view controls succeed. The AST value-only lowerer passes lowered host fat arrows through legacy DSL parsing. This silently discards a valid chosen fallback; assess ordinary coalesce twin and typed nested values with public probes before repair.
  Owned paths: bounded lazy default AST/legacy bridge and native/fresh fixture, qualified book/default facts/current docs.
  Acceptance: Lower typed operands without reparsing host Hash syntax as DSL, preserve laziness/kinds/effects and genuine retired authored-fat-arrow rejection. Do not normalize unrelated helper domains or deferred evaluation. Compile/small checks/docs/commit.
  Activation: clean `e01bf90551f70b8e5648baea6eb0052eebb4f19c`; flow committed, brief empty, tree clean.
  Verification tier: `focused`
  Focused checks: Public direct coalesce/nonempty Hash twins and nested typed/lazy controls, retained native/fresh literal regression after RED, direct selected-default/exhaustion compatibility, MethodLowering/test syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded existing typed operand repair under director feature-first cadence; full helper-domain/portable admission23.4 and final clean push remain separate.
  Claim verification: none: deterministic authored literal/kind/order regression; no quantified or portable measurement.

  Completion: Construct both lazy selectors from fully lowered typed operands via _lower_lazy_default_value_args. Reuse the same host-source builder from legacy paths, retaining original coalesce tail semantics and copied nonempty comparison. No host Hash source is reparsed as DSL.
  Public findings / candidate correction: Native/fresh RED confirms direct coalesce and coalesce_nonempty Hash twins plus fluent literal fallback are null; nested Array, empty Hash, block Hash and SDK order already work. The first candidate reused generic value-only argument reconstruction, which intentionally leaves authored variable/call source for the legacy phase; native/fresh/direct compatibility exposes host join_values/bare-binding compile errors. Lower default operands completely with bare_scalar_read before the shared builder; do not pass that mixed intermediate directly to host emission.
  Verification:
  - [x] REPRODUCE / ISSUE: Frozen public marker/named controls and t/default_literal_operand_contract.t RED distinguish direct valid Hash/default twins and fluent literal fallback from working typed nested/block controls.
  - [x] ROOT CAUSE (WHY + WHERE): lower_ast_value_only_call_node feeds lowered Hash host fat arrows into legacy_method_value_expr, triggering hash_literal_use_colon. Its generic intermediate also retains authored source, requiring complete typed operand lowering for the direct builder.
  - [x] FIX: Dedicated typed coalesce/nonempty operands plus shared lazy host builder avoid reparsing; legacy callers reuse the same selector construction after their existing normalization/lowering.
  - [x] ADDRESSED (verified): New native/fresh fixture PASS after RED for coalesce/nonempty Hash twins, nested Hash/Array bound numbers/false, fluent selected literal, empty Hash, lazy SDK order, skipped arms and numeric/false preservation. Genuine authored retired fat-arrow literal still produces the rejection marker.
  - [x] NO REGRESSION: Direct selected-default and nonempty-exhaustion fixtures plus MethodLowering/test compilation PASS. No broad suite, helper-domain normalization, callable vocabulary or serialized format change.
  - [x] LOCKSTEP: Contract/catalog, default fact/map and live/task/resume records align; book and fast memory/cadence/diagnosis/history/diff checks pass. Bounded Perl parent complete; Rust assessment2 next after clean commit, full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.6.1.2 - preserve typed lazy default operands`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.2`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Rust default-selection result flow.
  Dependencies: .23.3.6.1.
  Acceptance: Follow frozen default-selection-results.md with existing helper domains and actual-kind/lazy/effect/snapshot controls. Public native/generated distinguishing checks before repair; no inferred backend failure. Small compile/targeted checks/docs/commit; Lua declared5.4/full admission stays separate.
  Activation: clean `3fbd7be94e36e50241fd2665b97ddf520a59f4bb`; bounded Perl repairs committed, brief empty, tree clean.
  Owned paths: Rust public receiver dispatcher only for confirmed gaps, one focused native/restored/generated-plan fixture and direct default/join compatibility, public/current docs.
  Verification tier: `focused`
  Focused checks: Public CLI fluent/nested selected-default controls; small native/restored/generated-plan default regression plus direct joined/default-receiver checks, compilation/rustfmt, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public finding / owned repair: Rust public CLI returns null for direct String-selected Array continuation while joined/nested Array and joined Hash controls give A-B/X:Y with correct SDJ snapshots. eval_string_receiver_value_chain handles coalesce_nonempty then continues its original String-family loop. Route that selected result through existing dynamic continuation with actual scalar/container boundary; retain correct joined/default helpers. Shared authored fixture adds a direct Hash counterpart.

  Completion: After direct String coalesce_nonempty selection, return through eval_selected_receiver_value_chain with scalar guarding derived from the actual selected kind. Preserve existing joined/default helper behavior and source snapshots.
  Verification:
  - [x] REPRODUCE / ISSUE: Public CLI shows direct String-selected Array null beside working joined/nested controls. New shared authored fixture RED independently shows direct Array/Hash null with all other values unchanged.
  - [x] ROOT CAUSE (WHY + WHERE): eval_string_receiver_value_chain's coalesce_nonempty special branch continues its local String family after selection rather than handing off the selected result.
  - [x] FIX: Reuse existing dynamic continuation and set scalar guarding from actual Array/Hash versus scalar/null output; no helper, copy, lazy or serialized policy changes.
  - [x] ADDRESSED (verified): Small native/restored/generated-plan default fixture PASS after RED, including direct/joined Array/Hash, scalar incompatible nulls, empty/null/zero/false, skipped arms and SDJ snapshots.
  - [x] NO REGRESSION: Direct joined and default-receiver fixtures plus compilation/rustfmt PASS. Existing selected-null and source/helper differences remain unchanged; no broad suite/admission claim.
  - [x] LOCKSTEP: Shared fixture, contract/catalog, canonical defaults fact/map and live/task/resume docs align; book and fast memory/cadence/diagnosis/history/diff checks pass. Dart assessment3 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.6.2 - continue Rust selected default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.3`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Dart default-selection result flow.
  Dependencies: .23.3.6.2.
  Acceptance: Follow frozen default-selection-results.md with existing helper domains and actual-kind/lazy/effect/snapshot controls. Public native/generated distinguishing checks before repair; no inferred backend failure. Small compile/targeted checks/docs/commit; Lua declared5.4/full admission stays separate.
  Activation: clean `1a1e6ea6d37fa16ad174fd310332cc7373e35189`; Rust committed, brief empty, tree clean.
  Owned paths: Dart public fluent dispatcher only for confirmed gaps, focused native/restored/generated-plan default fixture, direct joined compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Public engine native/restored/generated-plan shared selected-default and direct retained-Scalar controls, existing default-receiver fixture plus direct joined test, selected-file fatal analysis/format, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Shared direct/joined Array/Hash flow, lazy SDJ snapshots and the existing receiver fixture already pass. Direct retained/fallback String followed by sorted/sorted_values yields [] instead of frozen null. _evaluateFluentCallsWithValue starts scalarResult only for List reducers/join; a direct coalesce_nonempty scalar selection never activates it. Treat nonempty selection as a possible scalar producer, then retain/clear the guard by its actual output kind.

  Completion: Retain already-correct actual container flow. Mark nonempty defaults as possible scalar results, then keep/clear the existing scalar guard from actual List/Map versus scalar/null output. Existing lazy/copy/helper policies stay unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared public native/restored/generated-plan values already pass; retained/fallback direct String sorted/sorted_values independently RED as [] instead of null.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluateFluentCallsWithValue only starts scalarResult for List reducers/join. Direct String nonempty selection does not activate the boundary, though _callCoalesceWithReceiver already selects lazily and copies actual values correctly.
  - [x] FIX: Include coalesce_nonempty in mayProduceScalar and retain/clear guarding after evaluation according to actual List/Map output. Preserve the existing dispatcher and producer semantics.
  - [x] ADDRESSED (verified): New native/restored/generated-plan regression PASS after boundary RED for direct scalar negatives; shared Array/Hash, empty/null/zero/false, skipped fallbacks and SDJ snapshots still pass.
  - [x] NO REGRESSION: Existing default receiver fixture and direct joined test PASS; selected-file fatal analysis/format and compilation PASS. Generic coalesce/deferred/domain policies and generated formats stay unchanged; no broad suite.
  - [x] LOCKSTEP: Register focused test via normal test discovery, align contract/catalog/default and Dart facts/map plus live/task/resume records; book and fast memory/cadence/diagnosis/history/diff checks pass. Julia assessment4 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.6.3 - guard Dart scalar default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.4`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Julia default-selection result flow.
  Dependencies: .23.3.6.3.
  Acceptance: Follow frozen default-selection-results.md with existing helper domains and actual-kind/lazy/effect/snapshot controls. Public native/generated distinguishing checks before repair; no inferred backend failure. Small compile/targeted checks/docs/commit; Lua declared5.4/full admission stays separate.
  Activation: clean `220c0a37d9a308eb07c7a0a6347f78c9a799ce44`; Dart committed, brief empty, tree clean.
  Owned paths: Julia public fluent dispatcher only for confirmed gaps, focused native/generated-plan/fresh-emitted default fixture and runner registration, direct joined compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Public native/generated-plan/fresh-emitted shared selected-default and direct Scalar controls, existing default-receiver fixture plus direct joined test under strict Julia flags, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Shared direct/joined container and existing default receiver controls pass on native/generated-plan/fresh-emitted routes. Direct retained/fallback String sorted/sorted_values returns empty Arrays instead of null on all three routes. _evaluate_runtime_fluent_chain! only activates scalar_result for AbstractVector reducers/join; include nonempty selection as a possible scalar producer, clearing the guard for actual AbstractVector/AbstractDict output.

  Completion: Preserve correct selected container flow and include nonempty defaults as possible scalar results. Retain/clear the existing guard using actual AbstractVector/AbstractDict output; keep lazy/copy/helper policies unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared/default-receiver controls already pass; direct retained/fallback String sorted/sorted_values returns empty Arrays instead of null on native/generated-plan/fresh-emitted routes.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! only activates scalar_result for AbstractVector reducers/join. Direct String default selection never activates it; _evaluate_runtime_fluent_value_call! already selects lazily and copies actual values.
  - [x] FIX: Include coalesce_nonempty in may_produce_scalar, then keep/clear guarding from actual container output. Preserve shared dispatch and default semantics.
  - [x] ADDRESSED (verified): Focused native/generated-plan/fresh-emitted default regression PASS after boundary RED, including direct scalar nulls, actual Array/Hash, empty/null/zero/false, skipped fallbacks and SDJ snapshots.
  - [x] NO REGRESSION: Existing default receiver fixture and direct joined test PASS under startup/history disabled and depwarn=error; package compilation succeeds. Generic coalesce/deferred/domain policies and generated formats stay unchanged; no broad suite.
  - [x] LOCKSTEP: Register fixture, align contract/catalog/default and Julia facts/map plus live/task/resume records; book and fast memory/cadence/diagnosis/history/diff checks pass. Lua assessment5 next after clean commit, declared5.4/full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.6.4 - guard Julia scalar default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.6.5`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Lua default-selection result flow.
  Dependencies: .23.3.6.4.
  Acceptance: Follow frozen default-selection-results.md with existing helper domains and actual-kind/lazy/effect/snapshot controls. Public native/generated distinguishing checks before repair; no inferred backend failure. Small compile/targeted checks/docs/commit; Lua declared5.4/full admission stays separate.
  Activation: clean `e8bd3f389fe1ceb79c43d9fd702fa19a68865dfa`; Julia committed, brief empty, tree clean.
  Owned paths: Shared Lua fluent dispatcher only for confirmed gaps, focused native/generated-plan/fresh-emitted fixture and runner registration, direct joined compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Public native/generated-plan/fresh-emitted shared selected-default and direct Scalar controls, existing default-receiver fixture plus direct joined test on available PUC5.5.1/LuaJIT with matching products, loadfile, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen implementation/confirmation under director feature-first cadence; declared5.4/full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Shared actual Array/Hash selections pass on native/generated-plan/fresh-emitted routes on both available hosts. Direct retained/fallback String sorted/sorted_values returns [] instead of null on native controls. evaluate_fluent_calls handles lazy coalesce without activating scalar_result; set the existing guard for nonempty selection and let the existing actual array/harray result check release it.

  Completion: Preserve correct actual container flow and activate scalar_result after nonempty selection; the existing array/harray result-kind check releases it for actual containers. Keep lazy/copy/helper semantics unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared Array/Hash selections already pass; direct retained/fallback String sorted/sorted_values independently RED as [] instead of null on both available hosts.
  - [x] ROOT CAUSE (WHY + WHERE): typed_source.receiver_mutation.evaluate_fluent_calls handles coalesce selection without activating scalar_result. Its existing result-kind check can already release that guard for actual array/harray output.
  - [x] FIX: Activate the existing guard for coalesce_nonempty and preserve the shared actual-kind release. Generic coalesce/deferred/helper policies remain unchanged.
  - [x] ADDRESSED (verified): Focused native/generated-plan/fresh-emitted default fixture PASS after boundary RED on available PUC5.5.1/LuaJIT, including direct scalar nulls, actual Array/Hash, empty/null/zero/false, lazy skipped arms and SDJ snapshots.
  - [x] NO REGRESSION: Existing default receiver fixture, direct joined fixture and interpreter/runner loadfile checks PASS on both hosts with matching native products. No broad suite, source normalization, declared5.4 or full admission claim.
  - [x] LOCKSTEP: Register fixture, align contract/catalog/default and Lua facts/map plus live/task/resume records; book and fast memory/cadence/diagnosis/history/diff checks pass. Bounded default rollout targeted-checked; index_of result assessment23.2.6 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.6.5 - guard Lua scalar default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.7`
  Status: `active` / bounded index rollout targeted-checked on recorded hosts; full admission open
  Goal: Implement/confirm ordinary index_of integer/null result continuations across maintained backends.
  Dependencies: .23.2.6.
  Children: `.23.3.7.1`, `.23.3.7.2`, `.23.3.7.3`, `.23.3.7.4`, `.23.3.7.5`.
  Acceptance: Frozen index-results.md targets preserve index/domain/equality/kind, one-needle preflight, once-only source/needle/consumer order, snapshots and scalar boundaries. Assess each backend independently; full admission remains23.4.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.7.1`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Perl index_of result continuation.
  Dependencies: .23.2.6.
  Acceptance: Follow index-results.md through current public/native/generated carriers. Preserve correct producer/equality/source/null/copy policies, exact-one-needle preflight before effects, zero/nonmatch, actual scalar kinds, snapshots and incompatible container nulls. Source/code children only for confirmed bounded gaps; compile/small checks/docs/commit. Lua declared5.4/full admission stays separate.
  Activation: clean `434fe1abcd703ff1041991b62d43aa470cedc895`; index contract committed, brief empty, tree clean.
  Owned paths: Perl ordinary array result-family/arity lowering, focused native/fresh index fixture, direct selected-default compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Native/fresh index continuation fixture after RED, direct selected-default regression, MethodLowering/test syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable/deferred admission23.4 and final clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.

  Completion: Classify index_of as scalar_result in the existing Array return-family callback and preflight exactly one needle before source/operand effects. Reuse shared scalar/default/String/Array continuation; leave the correct producer/equality/source/copy implementation unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public frozen direct/nested distinctions and retained target fixture RED show stopped numeric/String consumers and Hash-view fallback. Existing incompatible-container and producer snapshot controls remain valid.
  - [x] ROOT CAUSE (WHY + WHERE): array_chain_return_family defaults index_of to terminal, preventing later compatible consumers. Common arity preflight lacks its one-needle check.
  - [x] FIX: Return scalar_result for index_of and reject missing/extra needles before effects. Existing selected/scalar/default bridges handle the returned integer/null.
  - [x] ADDRESSED (verified): t/index_result_receiver_contract.t PASS native/fresh after RED for direct/selected/pipeline/hash/String/function/default sources, zero/no-match/empty/null, numeric selector writes, String bridges/defaults, scalar negatives and malformed-shape no-effects.
  - [x] NO REGRESSION: Direct selected-default fixture, MethodLowering/test compilation and original N/SN producer/SNA consumer snapshot controls PASS. No producer, equality/domain, deferred vocabulary or generated-format change; no broad suite.
  - [x] LOCKSTEP: Worked catalog/guide examples and former terminal summaries align with bounded Perl support; contract, array fact/map and live/task/resume records align. Book and fast memory/cadence/diagnosis/history/diff checks pass. Fresh-current Rust assessment2 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.7.1 - continue Perl index results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.7.2`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Rust index_of result continuation.
  Dependencies: .23.3.7.1.
  Acceptance: Follow index-results.md through current public/native/generated carriers. Preserve correct producer/equality/source/null/copy policies, exact-one-needle preflight before effects, zero/nonmatch, actual scalar kinds, snapshots and incompatible container nulls. Source/code children only for confirmed bounded gaps; compile/small checks/docs/commit. Lua declared5.4/full admission stays separate.
  Activation: clean `58833111dd2fc8c62f00afc4733c1d1422f14bac`; Perl committed, brief empty, tree clean.
  Owned paths: Rust public receiver result/arity dispatch only for confirmed gaps, focused native/restored/generated-plan index fixture, direct default compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Fresh-current public CLI fluent/nested/shape controls; small native/restored/generated-plan index regression after RED and direct selected-default test, compilation/rustfmt, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Fresh-current CLI gives fluent direct/hash/default/zero null beside nested2; valid effect control stops after SN with source[a,b,c], and malformed missing/extra needles run four effects. is_selected_receiver_result_method/is_scalar_result_receiver_method omit index_of; Expr::FluentChain preflight guards one join delimiter but not one index needle. Extend those existing owners, preserving the index producer/equality/copy behavior.

  Completion: Include index_of in is_scalar_result_receiver_method, which also admits the existing selected-value handoff, and add it to exact-one-operand fluent preflight. Keep the index helper/equality/source/copy implementation unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Fresh-current CLI returns fluent null beside nested2, runs SN without the consumer and runs four malformed-shape effects. Retained shared fixture RED reaches a selector write with the derived null instead of numeric0; the selector validator correctly rejects it.
  - [x] ROOT CAUSE (WHY + WHERE): is_scalar_result_receiver_method/is_selected_receiver_result_method omit index_of, so the Array loop stops after that producer. Expr::FluentChain lacks its one-needle preflight.
  - [x] FIX: Extend existing scalar handoff and common one-operand preflight; preserve the correct producer and existing domain/equality/copy behavior.
  - [x] ADDRESSED (verified): Small native/restored/generated-plan index fixture PASS after RED, including direct/selected/pipeline/hash/String/default/function sources, numeric0 selector writes, zero/null, scalar boundaries, explicit bridges, malformed-shape no-effects and N/SN/SNA snapshots.
  - [x] NO REGRESSION: Direct selected-default test plus compilation/rustfmt PASS. No source normalization, helper/deferred vocabulary, serialized format or broad admission change; no full suite.
  - [x] LOCKSTEP: Shared fixture, worked catalog/guide and terminal summaries, contract, array fact/map and live/task/resume records align; book and fast memory/cadence/diagnosis/history/diff checks pass. Dart assessment3 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.7.2 - continue Rust index results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.7.3`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Dart index_of result continuation.
  Dependencies: .23.3.7.2.
  Acceptance: Follow index-results.md through current public/native/generated carriers. Preserve correct producer/equality/source/null/copy policies, exact-one-needle preflight before effects, zero/nonmatch, actual scalar kinds, snapshots and incompatible container nulls. Source/code children only for confirmed bounded gaps; compile/small checks/docs/commit. Lua declared5.4/full admission stays separate.
  Activation: clean `3f00457cac9a96b9a9b1bcc7f914f174db21d29c`; Rust committed, brief empty, tree clean.
  Owned paths: Dart public fluent scalar/arity dispatch only for confirmed gaps, focused native/restored/generated-plan index fixture, direct default compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Public native/restored/generated-plan shared index fixture before/after repair and direct selected-default test; selected-file fatal analysis/format, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation/confirmation under director feature-first cadence; full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Native shared values already carry numeric results and N/SN/SNA snapshots, but scalar consumers sorted/after-cat return [], extra shape returns2 and malformed shapes run four effects. A separate null-source index followed by sorted also returns []. Common fluent preflight only checks one join delimiter; mayProduceScalar omits index_of. Guard index results independently of source kind (the documented result is integer/null), and add one-needle preflight.

  Completion: Preserve correct native numeric flow; include index_of in mayProduceScalar independently of source kind, and require one needle in common fluent preflight. Integer/null results retain scalar guarding until a compatible container output.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared native values expose [] scalar negatives, extra-shape result2 and four effects. A separate null-source index then sorted independently REDs as [] instead of null; retained native JSON reasons show the actual untruncated values.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluateFluentCallsWithValue omits index_of from mayProduceScalar; common ActionFluentChainExpr preflight checks one join delimiter but not one index needle. Correct integer/null flow and producer snapshots already work natively.
  - [x] FIX: Guard index results regardless of source kind and reject missing/extra needles before effects. Preserve existing helper/equality/source/copy behavior and dynamic bridges.
  - [x] ADDRESSED (verified): Small native/restored/generated-plan index regression PASS after RED, including integer/null scalar negatives, shape no-effects, zero selector use, direct/selected/pipeline/hash/String/function/default sources and N/SN/SNA snapshots.
  - [x] NO REGRESSION: Direct selected-default regression plus selected-file fatal analysis/format and compilation PASS. No producer, equality/domain, generic/deferred or generated-format changes; no broad suite.
  - [x] LOCKSTEP: Worked catalog/guide, contract, Dart/array facts/map and live/task/resume records align; book and fast memory/cadence/diagnosis/history/diff checks pass. Julia assessment4 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.7.3 - guard Dart index result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.7.4`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Julia index_of result continuation.
  Dependencies: .23.3.7.3.
  Acceptance: Follow index-results.md through current public/native/generated carriers. Preserve correct producer/equality/source/null/copy policies, exact-one-needle preflight before effects, zero/nonmatch, actual scalar kinds, snapshots and incompatible container nulls. Source/code children only for confirmed bounded gaps; compile/small checks/docs/commit. Lua declared5.4/full admission stays separate.
  Activation: clean `15ab79ad75834eab7350c090e8fe90d6e3308c0c`; Dart committed, brief empty, tree clean.
  Owned paths: Julia public fluent scalar/arity dispatch only for confirmed gaps, focused native/generated-plan/fresh-emitted index fixture and runner registration, direct default compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Public shared index and null-source scalar controls on native/generated-plan/fresh-emitted routes before/after repair, direct selected-default fixture under strict flags, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation/confirmation under director feature-first cadence; full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Three-carrier RED shows numeric0 selector use, extra2 and four malformed effects; separate null-source index then sorted returns [] on all routes. _evaluate_runtime_fluent_chain! lacks one-needle preflight and index_of in may_produce_scalar. Guard its guaranteed integer/null output independently of source kind and extend the existing shape check; preserve helper/equality/source/copy behavior.

  Completion: Preserve correct numeric flow; include index_of in source-independent may_produce_scalar and one-operand fluent preflight. Integer/null results keep scalar guarding until an actual container output.
  Evidence retention: Preserve the exact earlier Rust CLI input as docs/checkpoints/type-operation-inventory/rust-index-probe.spec, byte-compared to the executed local input; its historical pre-repair source base is58833111dd2fc8c62f00afc4733c1d1422f14bac. This is retention of existing family evidence, not a new Rust run/admission.
  Verification:
  - [x] REPRODUCE / ISSUE: Native/generated-plan/fresh-emitted shared RED shows extra2/four effects; separate null-source index then sorted returns [] instead of null on every route. Current numeric0 selector and producer snapshot controls remain distinct from those gaps.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! omits index_of from one-needle preflight and may_produce_scalar, so nullable/scalar consumers lack the existing boundary.
  - [x] FIX: Include index_of in both shared checks independently of receiver kind. Preserve helper/equality/source/copy and dynamic bridge behavior.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted index regression PASS after RED, including integer/null scalar boundaries, zero/null, numeric selector writes, direct/selected/pipeline/hash/String/function/default sources, shape no-effects and N/SN/SNA snapshots.
  - [x] NO REGRESSION: Direct selected-default fixture and package compilation PASS under startup/history disabled and depwarn=error. No producer/deferred/generic/equality/domain or generated-format changes; no broad suite.
  - [x] LOCKSTEP: Register fixture; preserve exact CLI input and align worked catalog/guide, contract, Julia/array facts/map and live/task/resume records. Book and fast memory/cadence/diagnosis/history/diff checks pass. Lua assessment5 next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.7.4 - guard Julia index result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.7.5`
  Status: `completed`
  Goal: Publicly assess and implement/confirm ordinary Lua index_of result continuation.
  Dependencies: .23.3.7.4.
  Acceptance: Follow index-results.md through current public/native/generated carriers. Preserve correct producer/equality/source/null/copy policies, exact-one-needle preflight before effects, zero/nonmatch, actual scalar kinds, snapshots and incompatible container nulls. Source/code children only for confirmed bounded gaps; compile/small checks/docs/commit. Lua declared5.4/full admission stays separate.
  Activation: clean `5e105be6536b53cfe99a9d726cd3b8a972a51158`; Julia committed, brief empty, tree clean.
  Owned paths: Shared Lua fluent scalar/arity dispatch only for confirmed gaps, focused native/generated-plan/fresh-emitted index fixture and runner registration, direct default compatibility and public/current docs.
  Verification tier: `focused`
  Focused checks: Public shared index/null-source scalar controls before/after repair and direct selected-default fixture on native/generated-plan/fresh-emitted routes on available PUC5.5.1/LuaJIT with matching products, loadfile, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation/confirmation under director feature-first cadence; declared5.4/full domain/portable admission23.4 and eventual clean push remain separate.
  Claim verification: none: deterministic authored value/order regression; no quantified corpus or portable measurement.
  Public findings / owned repair: Both available native hosts already produce correct numeric0 selector writes and N/SN/SNA snapshots, but integer scalar negatives are [], extra-shape result2 and four effects. evaluate_fluent_calls only marks join_values after Array helpers; fluent preflight only checks one join delimiter. Include index_of in those existing checks, preserving helper/equality/source/copy policies and covering its integer/null output independently of source kind.

  Completion: Include index_of in common one-operand preflight and activate scalar_result after its Array-helper evaluation, independently of source kind. The existing actual array/harray output check releases the guard for explicit bridges.
  Verification:
  - [x] REPRODUCE / ISSUE: Both available native hosts show correct numeric flow but [] integer scalar negatives, extra2 and four malformed effects; the full native JSON is retained in the failing fixture output.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls only marks join_values after Array helpers, and evaluate_expr's fluent preflight only checks one join delimiter. index_of is absent from both owners.
  - [x] FIX: Add index_of to those existing checks. Preserve helper/equality/source/copy and dynamic bridge behavior.
  - [x] ADDRESSED (verified): Small native/generated-plan/fresh-emitted index fixture PASS after RED on available PUC5.5.1/LuaJIT, including integer/null boundaries, zero/null, numeric0 selector writes, source families, shape no-effects and N/SN/SNA snapshots.
  - [x] NO REGRESSION: Direct selected-default fixture and interpreter/runner loadfile checks PASS on both hosts with matching native products. No producer/generic/deferred/domain or generated-format change; declared5.4/full admission stays separate.
  - [x] LOCKSTEP: Register fixture; align worked catalog/guide, contract, Lua/array facts/map and live/task/resume records. Book and fast memory/cadence/diagnosis/history/diff checks pass. Bounded index rollout targeted-checked; has_key result assessment23.2.7 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.7.5 - guard Lua index result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8`
  Status: `active` / bounded implementation planned; full admission open
  Goal: Implement frozen has_key result/key targets in has-key-results.md without changing producer kinds/domains.
  Children: `.23.3.8.1`, `.23.3.8.2`, `.23.3.8.3`, `.23.3.8.4`, `.23.3.8.5`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.1`
  Status: `active` / bounded Perl producer/result repairs targeted-checked; full admission open
  Goal: Repair confirmed Perl key-block producer compilation, then compatible result continuation.
  Children: `.23.3.8.1.1`, `.23.3.8.1.2`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.1.1`
  Status: `completed`
  Goal: Repair valid String key blocks failing has_key native/fresh compilation; priority P1.
  Dependencies: .23.2.7.
  Reproduction / impact: meta.has_key({order=cat(order,"K");"a"}) leaves raw DSL inside exists ->{{...}}, failing compilation even without chaining. Literal/variable/helper String keys already work.
  Acceptance: Complete key lowering in its current context without disturbing generic callback contracts; establish once-only/source-before-key snapshots, false/null-valued presence and literal/variable/helper compatibility on native/fresh routes. Compile/small checks/docs/commit before result flow.

  Activation: clean `34167dfba3fbddec13ad4da8013d6cdd484117c6`; assessment committed, brief empty, tree clean.
  Owned paths: Perl has_key current-context key lowering; focused native/fresh producer fixture and current contract/book/hash fact/live records.
  Verification tier: `focused`
  Focused checks: Native/fresh key-block producer RED/GREEN, literal/variable/helper presence and source/key snapshot/order controls; direct index compatibility, Perl syntax, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded producer repair under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored value/order regression, no quantified population or portable measurement.

  Completion: Complete key expressions with _lower_method_value_expr before existing scalar-key fallback; no generic/private callback contract change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Get/fresh key-block regression RED3/4 with raw DSL syntax errors near {{, while prior literal/variable/helper controls work.
  - [x] ROOT CAUSE (WHY + WHERE): call_spec_handler_subst retains authored key blocks inside exists; MethodLowering has_key delegates only to scalar access key lowering.
  - [x] FIX: Finish key lowering in current MethodLowering context, then retain original fallback. No producer kind/domain/copy policy change.
  - [x] ADDRESSED (verified): Native/fresh fixture passes key once-only, literal/variable/helper presence, false/null stored values and named/computed/free snapshots with K/SK order. Later-added key stays absent from captured source.
  - [x] NO REGRESSION: Direct native/fresh index fixture and Perl source/test syntax pass; no broad suite or result-flow change.
  - [x] LOCKSTEP: Current contract/book/key fact/map and task/live/resume records updated; fast memory/cadence/diagnosis/history/diff and book pass. Result handoff1.2 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.8.1.1 - lower has_key key blocks in context`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.1.2`
  Status: `completed`
  Goal: Continue Perl has_key truth-valued results through existing compatible scalar/text methods.
  Dependencies: .23.3.8.1.1.
  Acceptance: Frozen has-key-results.md, actual kind retained, one-key preflight before effects, direct/selected/pipeline/default/function sources, explicit bridges/scalar boundaries and source/key/consumer snapshots; native/fresh/direct compatibility and docs/commit. No Boolean normalization/new vocabulary.

  Activation: clean `1cc204148d3053d07857c08ebc89c7873455b87e`; producer committed, brief empty, tree clean.
  Owned paths: Shared ordinary has_key scalar-result classification/one-key preflight, focused native/fresh receiver fixture, contract/book/hash fact and live records.
  Verification tier: `focused`
  Focused checks: Native/fresh has_key result RED/GREEN, scalar/bridge/false retention, source/key/consumer snapshots and malformed no-effects; direct key producer compatibility, Perl syntax/book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen result implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored values/order, no quantified population or portable measurement.
  Additional owned flow defect: make_meta().has_key("a").cat("!") alone remains null after classifier repair while make_meta(), free has_key and single-step receiver return Hash/1/1. Public generated-source dump shows unsupported has_key inside cat. The generic aggregate bridge reparses an already lowered function Hash operand as DSL; complete typed has_key operands before host presence emission within this leaf.

  Completion: scalar_result plus exact-one-key preflight; typed has_key aggregate operands, typed nested has_key arguments and preserved authored root calls prevent function Hash host output from being reparsed as DSL.
  Verification:
  - [x] REPRODUCE / ISSUE: Native/fresh shared fixture RED with raw host DSL compilation errors. First scalar/shape change leaves only function result null on both routes; public Get returns Hash/1/1/null for function/free/single-step/chained forms.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering hash return-family marks has_key terminal; fluent shape lacks one-key guard. Generated source additionally shows unsupported has_key inside cat after ast_expr_source_node prematurely lowers a function Hash into compatibility DSL.
  - [x] FIX: Reuse scalar_result, preflight exact one key and finish typed has_key operands/nested arguments while retaining authored root calls until that lowering. No producer Boolean/numeric normalization or new methods.
  - [x] ADDRESSED (verified): Native/fresh shared fixture passes direct/selected/pipeline/literal/function/default and String keys, false retention, scalar boundaries/explicit bridge, zero malformed effects and K/SK/SKA snapshots after RED.
  - [x] NO REGRESSION: Direct native/fresh key producer fixture and source/test syntax pass;12 checks across two fixtures. No broad suite/domain/deferred/copy/generated-format change.
  - [x] LOCKSTEP: Contract/worked catalog/guide, hash fact/map and task/live/resume updated. Book and fast memory/cadence/diagnosis/history/diff pass. Rust2 assessment next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.8.1.2 - continue has_key scalar results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust has_key result/key/shape targets.
  Dependencies: .23.3.8.1.2.
  Acceptance: Public native/generated assessment before classification; repair only confirmed gaps under has-key-results.md, preserving actual producer kinds/domains/source/copy. One-key preflight, presence/false retention, scalar boundaries/bridges and ordered snapshots; compile/small checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 separate.

  Activation: clean `ce4372bdef73e4db1b61a0a16c0d2ab54cdca2bb`; Perl committed, brief empty, tree clean.
  Owned paths: Confirmed Rust has_key fluent scalar/arity gaps only; shared native/restored/generated-plan fixture, direct index compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public Engine native/restored/generated-plan has_key fixture before/after repair, direct index fixture, targeted offline Cargo compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored value/order regression, no quantified corpus or portable measurement.

  Completion: Include has_key in existing scalar-result classification and exact-one-operand fluent preflight; existing Number1/0 presence helper untouched.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Engine native fixture RED shows fluent null, nested1!, SK-only order and four malformed effects; producer keys still run.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs hash dynamic dispatcher stops terminal has_key unless selected-result; scalar-result classifier and one-operand preflight omit it.
  - [x] FIX: Add has_key to existing scalar-result classifier and preflight; no helper/domain/source/copy normalization.
  - [x] ADDRESSED (verified): Native/restored/generated-plan result fixture passes presence/false retention, literal/variable/helper/block String keys, selected/pipeline/literal/function/default sources, explicit bridge/scalar nulls, zero malformed effects and K/SK/SKA snapshots.
  - [x] NO REGRESSION: Direct native/restored/generated-plan index fixture and targeted offline Cargo compilation pass. No broad suite, new methods or serialized-format change.
  - [x] LOCKSTEP: Contract/worked catalog/guide, hash fact/map and task/live/resume updated; book and fast memory/cadence/diagnosis/history/diff pass. Dart3 assessment next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.8.2 - continue Rust has_key scalar results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart has_key result/key/shape targets.
  Dependencies: .23.3.8.2.
  Acceptance: Public native/generated assessment before classification; repair only confirmed gaps under has-key-results.md, preserving actual producer kinds/domains/source/copy. One-key preflight, presence/false retention, scalar boundaries/bridges and ordered snapshots; compile/small checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 separate.

  Activation: clean `5ffc8c82350d6ef738b19cd0ef6cf87127879e91`; Rust committed, brief empty, tree clean.
  Owned paths: Confirmed Dart has_key fluent result/shape gaps only; native/restored/generated-plan shared fixture, direct index compatibility, selected-file analysis and current docs.
  Verification tier: `focused`
  Focused checks: Public native/restored/generated-plan has_key fixture before/after confirmed repair, direct index fixture, fatal selected-file analysis, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored value/order regression, no quantified corpus or portable measurement.

  Completion: Include has_key in existing exact-one-operand preflight and mayProduceScalar independently of source kind; actual List/Map output still releases the guard.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native shared fixture RED retains correct result/order/snapshots but incompatible/after-text consumers return[], missing0!, extra1! and four malformed effects; full native JSON retained in test reason.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart _evaluateFluentCallsWithValue omits has_key from scalar producers, and ActionFluentChainExpr preflight omits its one-key shape.
  - [x] FIX: Add has_key to those existing checks independently of source kind; actual container output enables explicit bridges. Presence helper Number0/1 remains unchanged.
  - [x] ADDRESSED (verified): Native/restored/generated-plan shared fixture passes presence/false retention, String keys, source families, scalar nulls/explicit bridge, zero malformed effects and K/SK/SKA snapshots after RED.
  - [x] NO REGRESSION: Direct index native/restored/generated-plan checks and fatal selected-file analysis pass;3 tests total. No broad suite, helper/domain/source/copy or format change.
  - [x] LOCKSTEP: Contract/worked catalog/guide, Dart/hash facts/map and task/live/resume updated; book and fast memory/cadence/diagnosis/history/diff pass. Julia4 assessment next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.8.3 - guard Dart has_key result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia has_key result/key/shape targets.
  Dependencies: .23.3.8.3.
  Acceptance: Public native/generated assessment before classification; repair only confirmed gaps under has-key-results.md, preserving actual producer kinds/domains/source/copy. One-key preflight, presence/false retention, scalar boundaries/bridges and ordered snapshots; compile/small checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 separate.

  Activation: clean `99167513535ddb39eff8932e481f4744d8b0a076`; Dart committed, brief empty, tree clean.
  Owned paths: Confirmed Julia has_key ordinary scalar/shape gaps only; native/generated-plan/fresh-emitted shared fixture, direct index compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Strict Julia native/generated-plan/fresh-emitted has_key fixture before/after repair, direct index fixture, package compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored values/order, no quantified corpus or portable measurement.

  Completion: Include has_key in existing exact-one-operand fluent preflight and source-independent may_produce_scalar; actual AbstractVector/AbstractDict output releases the guard.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native shared fixture JSON retains correct flow/order/snapshots but incompatible/after-text [], missing0!, extra1! and four effects; native/plan/fresh expectations all RED.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _evaluate_runtime_fluent_chain! omits has_key from scalar producers and exact-one-operand preflight.
  - [x] FIX: Add has_key to those existing checks independently of source kind; explicit container outputs release the guard. Integer0/1 presence helper remains unchanged.
  - [x] ADDRESSED (verified): Strict native/generated-plan/fresh-emitted shared fixture passes presence/false retention, String keys, source families, scalar nulls/explicit bridge, zero malformed effects and K/SK/SKA snapshots after RED.
  - [x] NO REGRESSION: Direct three-route index fixture and package compilation pass under startup/history disabled and depwarn=error;9 assertions total. No broad suite/helper/domain/source/copy/format change.
  - [x] LOCKSTEP: Register fixture; contract/worked catalog/guide, Julia/hash facts/map and task/live/resume updated; book and fast memory/cadence/diagnosis/history/diff pass. Lua5 assessment next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.8.4 - guard Julia has_key result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.8.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua has_key result/key/shape targets.
  Dependencies: .23.3.8.4.
  Acceptance: Public native/generated assessment before classification; repair only confirmed gaps under has-key-results.md, preserving actual producer kinds/domains/source/copy. One-key preflight, presence/false retention, scalar boundaries/bridges and ordered snapshots; compile/small checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 separate.

  Activation: clean `07d65e85378ed248a0a324e307e0eee4eaafbb05`; Julia committed, brief empty, tree clean.
  Owned paths: Confirmed Lua ordinary has_key scalar/shape gaps only; native/generated-plan/fresh-emitted shared fixture and runner registration, direct index compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public native/generated-plan/fresh-emitted has_key before/after repair on available PUC5.5.1/LuaJIT with matching products, direct index fixture, interpreter/runner loadfile, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; declared5.4/full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified corpus or portable measurement.

  Completion: Replace has_key terminal continuation fence with scalar_result tracking; add has_key to existing exact-one-operand fluent preflight. Actual container results still release the scalar guard.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native shared fixture RED on both available hosts shows fluent null versus nested1!, SK-only order and four malformed effects; full expected/actual JSON retained.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua evaluate_fluent_calls explicitly returns null after nonfinal has_key, and evaluate_expr fluent preflight omits its one-key shape.
  - [x] FIX: Replace that fence with scalar_result=true and include has_key in one-key preflight; presence numeric0/1/helper/domain/source/copy unchanged.
  - [x] ADDRESSED (verified): Both installed hosts pass native/generated-plan/fresh-emitted shared fixture after RED, preserving presence/false retention, String keys/source families, explicit bridge/scalar nulls, zero malformed effects and K/SK/SKA snapshots.
  - [x] NO REGRESSION: Direct three-route index fixture and interpreter/runner loadfile pass on available PUC5.5.1/LuaJIT with matching products. No broad suite/new methods/generated-format change; declared5.4/full admission separate.
  - [x] LOCKSTEP: Register fixture; contract/worked catalog/guide, Lua/hash facts/map and task/live/resume updated; book and fast memory/cadence/diagnosis/history/diff pass. Bounded has_key rollout targeted-checked; predicate assessment23.2.8 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.8.5 - continue Lua has_key scalar results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9`
  Status: `active` / bounded emptiness implementation planned
  Goal: Canonical actual-value emptiness and compatible predicate-result continuation under emptiness-results.md.
  Children: `.23.3.9.1`, `.23.3.9.2`, `.23.3.9.3`, `.23.3.9.4`, `.23.3.9.5`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.1`
  Status: `active` / bounded Perl producer before flow
  Children: `.23.3.9.1.1`, `.23.3.9.1.2`.
  Existing owner: SESSION-STARTUP-READING16.1/.16.2 retain broader conditions/global literal-slot acceptance; these children own only the ordinary value/result dependency and must record the exact overlap.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.1.1`
  Status: `completed`
  Goal: Repair P1 bounded ordinary Perl emptiness value-producer expression/kind defects before chaining.
  Dependencies: .23.2.8.
  Reproduction / impact: Public nested cat(is_empty({order=cat(order,"S");parts}),consumer) gives0!/SA for parts=[]; literal String0 differs from its bound twin. Empty Array/Hash expression results and source spellings must obey canonical value-based emptiness.
  Acceptance: Typed literal/binding/block/nested/function ordinary producers, empty/nonempty Array/Hash/String, undef and String0, inverse helpers/once-only/source snapshots; native/fresh/direct compatibility plus syntax/book/fast checks/commit. Update existing SESSION16 fact/owner overlap without claiming full conditional/global-selector repair.

  Activation: clean `e73cfce42d13f3e08a0285de494cc9f6472d8d19`; assessment committed, brief empty, tree clean.
  Owned paths: MethodLowering typed ordinary is_empty/is_nonempty producer operands and value-based predicate emission, native/fresh focused fixture, current contract/book/emptiness fact/live records. SESSION16 condition/global scalar-name audit remains separate.
  Verification tier: `focused`
  Focused checks: Public native/fresh literal/binding/block/nested/function producer RED/GREEN, inverse/presence/once-only/SA and host-program-name controls; direct has_key producer fixture, Perl syntax/book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded ordinary value-producer repair under director feature-first cadence; broader SESSION16 conditions/consumer audit, full23.4 admission and final clean push separate.
  Claim verification: none: deterministic authored values/order/host-state regression, no quantified corpus or portable measurement.
  Wrapper note: Previous probe syntax completed exit0 despite known child setpgid EPERM warning; SESSION-STARTUP-READING7 retains that infrastructure defect. No recovery/deletion or wrapper repair is part of this feature.

  Completion: Register existing emptiness helpers on typed ordinary value-call arities and fully lower their single operand before actual-kind emptiness emission. No FlowExpr/global scalar-name callback change.
  Verification:
  - [x] REPRODUCE / ISSUE: Retained public native/fresh probe shows wrong empty-Array block0!/SA and literal/bound String0 mismatch. New full producer fixture additionally RED8/11 on raw empty_items host invocation.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering's legacy fallback uses host truthiness and source-name extraction; missing typed value-only emptiness registration also leaves function operands raw. Public Get error identifies undefined host empty_items.
  - [x] FIX: Complete typed single operands and emit once-only actual undef/String/Array/Hash emptiness tests, with inverse numeric flags. Preserve actual data values and keep conditional/global callback repair with SESSION16.
  - [x] ADDRESSED (verified): Native/fresh producer fixture passes literals/bindings/blocks/nested/functions, empty/nonempty containers/String, String0/numeric0/false, inverse helpers, two host-program-name states and1!/SA/one-call source snapshots after RED.
  - [x] NO REGRESSION: Direct native/fresh has_key key-producer fixture and source/test syntax pass;17 assertions across two fixtures. No broad suite/FlowExpr/global selector/source/copy/format change.
  - [x] LOCKSTEP: Contract/worked catalog, existing emptiness fact/map, SESSION16 overlap and task/live/resume updated; refresh mutable SESSION index. Book and fast memory/cadence/diagnosis/history/diff pass. Result flow1.2 next after clean commit; broader16/full admission remain open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.9.1.1 - evaluate typed emptiness values`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.1.2`
  Status: `completed`
  Goal: Continue Perl is_empty/is_nonempty results through existing compatible scalar/text methods.
  Dependencies: .23.3.9.1.1.
  Acceptance: Frozen emptiness-results.md, actual result kinds, zero-operand shape before effects, named/literal/selected/pipeline/default/function sources, false retention, scalar nulls/explicit bridge and source/consumer snapshots. Native/fresh/direct small checks/docs/commit; no new logic or contains calibration change.

  Activation: clean `e003bd9e7d30e0f41643c2dab4e625841b9e6e08`; producer committed, brief empty, tree clean.
  Owned paths: Confirmed ordinary Perl emptiness receiver/result classification and zero-operand preflight, actual generic source handling, native/fresh shared fixture and current docs.
  Verification tier: `focused`
  Focused checks: Native/fresh shared receiver/result RED/GREEN across actual source kinds, false retention/scalar/bridge, zero-extra no-effects and SA snapshots; direct typed producer fixture, source/test syntax/book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary result implementation under director feature-first cadence; broader SESSION16/full23.4 admission and final clean push separate.
  Claim verification: none: deterministic authored value/order regression, no quantified population or portable measurement.
  Additional owned receiver findings: Classifier/shape-only candidate fixes basic flow but native/fresh expose wrong block/function0!, nonempty named Hash treated empty, String0/numeric0 treated empty, and repeated generic predicate null. Legacy compatibility producer still uses host truthiness; initial Array wrapper coerces broad emptiness sources and selected/default guards classify the generic predicates as container-only. Share actual-kind producer emission, retain broad source values, and admit these existing generic helpers through scalar/default/Hash continuations in this leaf.
  Candidate regression caught/owned: Registering generic predicates for Hash continuations makes copy's next-method hint infer Hash for a scalar binding carrying a nonempty Array; native/fresh copied_binding becomes1! rather than0!. Generic emptiness must not infer a container kind. Exclude it from copy's Hash hint and preserve the evaluated source through copy/predicate routing; retain this distinguishing bound-function Array case in the shared fixture.

  Completion: Scalar-result/zero-operand preflight, shared _lower_emptiness_value_test for typed/legacy ordinary producers, generic source preservation and scalar/default/Hash continuation. Copy lookahead excludes generic predicates; its source remains uncoerced before emptiness. FlowExpr/global scalar recognition unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Native/fresh shared result fixture RED shows stopped chains. Classifier-only candidate exposes wrong block/function0!, named Hash empty1!, String0/numeric0 nonempty0! and repeated predicate null. Bound function Array copy then predicate additionally RED1! versus0! after Hash registration.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering terminal family, legacy host-truthiness fallback, initial Array wrapper, generic methods treated as container-only in selected/default guards, function calls entering compatibility-only lowering and copy next-method Hash inference. Public Get/substitution errors and retained fixture JSON distinguish each candidate failure.
  - [x] FIX: Share actual-kind predicate emission; preserve generic receiver/typed-root values, admit existing generic predicates through scalar/default/Hash continuations and zero-operand preflight. Exclude predicates from Hash type inference; no copy helper/domain normalization.
  - [x] ADDRESSED (verified): Native/fresh shared result fixture passes Array/Hash/String/null/zero/selected/pipeline/function/default sources, repeated generic predicates, false retention, explicit bridge/scalar nulls, zero malformed effects and1!/SA/once-only source snapshots. Both function-bound Array and Hash copy cases pass after distinguishing Array RED.
  - [x] NO REGRESSION: Direct native/fresh typed producer fixture passes after shared-emitter refactor; final receiver fixture rechecked after copy/source corrections. Source/test syntax pass. No broad suite, FlowExpr/global scalar-name, helper-copy or serialized-format change.
  - [x] LOCKSTEP: Contract/worked catalog/guide, existing emptiness fact/map, SESSION16 overlap and task/live/resume align; refresh mutable SESSION index. Book and fast memory/cadence/diagnosis/history/diff pass. Rust2 assessment next after clean commit; broader16/full admission remain open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.9.1.2 - continue actual-value emptiness results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary emptiness result targets.
  Dependencies: .23.3.9.1.2.
  Acceptance: Public native/generated assessment before classification; preserve actual producer kinds and canonical empty/null/String/container domains, zero receiver operands, false retention, scalar guards/explicit bridges and ordered snapshots. Repair only confirmed bounded gaps; compile/small direct checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 remain separate.

  Activation: clean `61dd294d9394cfffc52abf0648a3c0530ecfd91a`; Perl committed, brief empty, tree clean.
  Owned paths: Confirmed Rust ordinary emptiness result/source/shape gaps only; shared native/restored/generated-plan fixture and direct has_key compatibility plus current docs.
  Verification tier: `focused`
  Focused checks: Public native/restored/generated-plan emptiness fixture before/after repair, direct has_key fixture, targeted offline Cargo compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored value/order regression, no quantified population or portable measurement.
  Confirmed findings / preservation: Public Engine native RED gives fluent null versus nested1!, S-only snapshot order and four malformed effects. Existing producer is Boolean-valued; preserve it. Add scalar-result/zero-operand shape handling and generic current-value dispatch, including ordinary family prefixes. First candidate then exposes copied Hash bindings/pipeline wrong1! versus0!: static Array inference from next is_empty loses a scalar-held Hash. Route initial copy followed by generic emptiness through evaluated actual-value dispatch, preserving the copy helper and retaining Array/Hash twins in the fixture.

  Completion: Zero-operand preflight/scalar-result flags and generic evaluated-value predicate dispatch, including ordinary Array/Hash/String/Number prefixes. Initial copy before a predicate avoids static Array inference; helper/copy/RuntimeValue emptiness policy unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Engine native RED gives fluent null versus nested1!, S-only order and four malformed effects. First candidate then exposes copied Hash binding/pipeline1! rather than0! while other fields pass.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs omits predicates from scalar-result/shape handling, routes generic sources through family-specific snapshots/validation and uses next is_empty Array classification for initial copy. Existing call_helper returns Bool from RuntimeValue::is_nonempty; preserve it.
  - [x] FIX: Classify scalar results, reject extra operands before effects, dispatch generic predicates by current evaluated value at initial/prefix/selected positions, and route initial copy before generic predicates the same way. No producer/copy/domain normalization or new vocabulary.
  - [x] ADDRESSED (verified): Native/restored/generated-plan shared fixture passes Array/Hash/String/null/zero/selected/pipeline/default/function and copied dynamic Array/Hash bindings, false retention/repeated predicates, explicit bridge/scalar nulls, zero malformed effects and1!/SA/once-only snapshots after RED.
  - [x] NO REGRESSION: Direct has_key native/restored/generated-plan fixture and targeted offline Cargo compilation pass; existing Boolean/Number0/false/data policy remains unchanged. No broad suite/format/source/copy changes.
  - [x] LOCKSTEP: Contract/worked catalog/guide, array/emptiness facts/map and task/live/resume align; bounded-history rollover if required is part of this commit. Book and fast memory/cadence/diagnosis/history/diff pass. Dart3 next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.9.2 - continue Rust generic emptiness results`.
  Continuity: Required engineering-notes pressure rollover archived the clean committed suffix as docs/history/development-notes/segment-4956-d41121f01c2b.md with its manifest/root update; --apply and --check pass. No immutable old segment edited or runtime verification scope expanded.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary emptiness result targets.
  Dependencies: .23.3.9.2.
  Acceptance: Public native/generated assessment before classification; preserve actual producer kinds and canonical empty/null/String/container domains, zero receiver operands, false retention, scalar guards/explicit bridges and ordered snapshots. Repair only confirmed bounded gaps; compile/small direct checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 remain separate.

  Activation: clean `796a3fdbaf2664f3a4922d7f552f4a574b99481b`; Rust committed, brief empty, tree clean.
  Owned paths: Confirmed Dart ordinary emptiness result/source/shape gaps only; native/restored/generated-plan shared fixture, direct has_key compatibility, selected-file analysis and current docs.
  Verification tier: `focused`
  Focused checks: Public native/restored/generated-plan shared emptiness fixture before/after repair, direct has_key fixture, fatal selected-file analysis, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored value/order regression, no quantified population or portable measurement.

  Completion: Include predicates in zero-operand preflight/source-independent scalar tracking and exempt these generic consumers from scalar container-only rejection. Bool helpers/source/copy and free-helper argument handling unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native fixture JSON RED retains correct source kinds/copy bindings/results/order, but incompatible/after-text consumers return[], bad empty1!, bad nonempty0! and four malformed effects.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart fluent preflight/scalar tracking omit emptiness predicates, while the Array-helper registry also puts their generic consumers in the scalar container-only guard.
  - [x] FIX: Add zero-operand preflight/scalar producer tracking independently of source; allow the existing generic predicates on scalar results without changing free-helper selector classifications or Bool/domain/source/copy behavior.
  - [x] ADDRESSED (verified): Native/restored/generated-plan shared fixture passes source kinds/copied Array/Hash bindings, repeated predicates, false retention/explicit bridge/scalar nulls, zero malformed effects and1!/SA/once-only snapshots after RED.
  - [x] NO REGRESSION: Direct has_key three-route fixture and fatal selected-file analysis pass; two targeted tests, no broad suite or serialized-format change.
  - [x] LOCKSTEP: Contract/worked catalog/guide, Dart/array facts/map and task/live/resume updated; book and fast memory/cadence/diagnosis/history/diff pass. Julia4 assessment next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.9.3 - guard Dart generic emptiness results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary emptiness result targets.
  Dependencies: .23.3.9.3.
  Acceptance: Public native/generated assessment before classification; preserve actual producer kinds and canonical empty/null/String/container domains, zero receiver operands, false retention, scalar guards/explicit bridges and ordered snapshots. Repair only confirmed bounded gaps; compile/small direct checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 remain separate.

  Activation: clean `10251b858e1fc20a3329d5bfc8e5fb9bbb6ec9f9`; Dart committed, brief empty, tree clean.
  Owned paths: Confirmed Julia ordinary emptiness result/source/shape gaps only; shared native/generated-plan/fresh-emitted fixture/registration, direct has_key compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Strict public native/generated-plan/fresh-emitted shared emptiness fixture before/after repair, direct has_key fixture, package compilation, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Completion: Add predicates to zero-operand preflight/source-independent scalar tracking and permit these generic consumers on scalar results; existing Bool helpers/domains/source/copy unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native shared JSON RED retains correct flow/source kinds/copied bindings/order but incompatible/after-text [], bad empty1!, bad nonempty0! and four effects; native/plan/fresh all fail before repair.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _evaluate_runtime_fluent_chain! omits predicates from zero-operand/scalar tracking and treats generic predicate consumers as array-only at the scalar guard.
  - [x] FIX: Include predicates in those existing checks, independently of source, and exempt generic consumers from scalar container-only rejection. No Boolean normalization or helper/domain/source/copy change.
  - [x] ADDRESSED (verified): Strict native/generated-plan/fresh-emitted shared fixture passes source kinds/copied Array/Hash bindings, repeated predicates, false retention/explicit bridge/scalar nulls, no malformed effects and1!/SA/once-only snapshots after RED.
  - [x] NO REGRESSION: Direct has_key three-route fixture and package compilation pass under startup/history disabled and depwarn=error;6 assertions. No broad suite or generated-format change.
  - [x] LOCKSTEP: Register fixture; contract/worked catalog/guide, Julia/array facts/map and task/live/resume align. Book and fast memory/cadence/diagnosis/history/diff pass. Lua5 next after clean commit; full admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.9.4 - guard Julia generic emptiness results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary emptiness result targets.
  Dependencies: .23.3.9.4.
  Acceptance: Public native/generated assessment before classification; preserve actual producer kinds and canonical empty/null/String/container domains, zero receiver operands, false retention, scalar guards/explicit bridges and ordered snapshots. Repair only confirmed bounded gaps; compile/small direct checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 remain separate.

  Activation: clean `3959d9a60ce2023f92753bcd43cefb7487a86cf8`; Julia committed, brief empty, tree clean.
  Owned paths: Confirmed Lua ordinary emptiness result/source/shape gaps only; shared native/generated-plan/fresh-emitted fixture/runner registration, direct has_key compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public native/generated-plan/fresh-emitted emptiness before/after repair on available PUC5.5.1/LuaJIT with matching products, direct has_key fixture, interpreter/runner loadfile, book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; declared5.4/full domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Completion: Remove is_empty/is_nonempty from TERMINAL_STRING_HELPERS, mark their pure-string-dispatch results scalar and include zero-operand preflight. Generic consumers were already allowed by the Lua guard; actual container outputs release it.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native shared fixture RED on both installed hosts shows fluent null versus nested1!, S-only order and four malformed effects; full JSON retained.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua evaluate_fluent_calls stops these generic helpers via TERMINAL_STRING_HELPERS; evaluate_expr preflight omits their zero-operand shapes.
  - [x] FIX: Remove that endpoint fence, track existing Boolean results as scalar and preflight zero operands before effects. No producer/domain/source/copy/Boolean normalization.
  - [x] ADDRESSED (verified): Both hosts pass native/generated-plan/fresh-emitted shared fixture after RED, including source kinds/copied Array/Hash bindings, repeated predicates, false retention, explicit bridge/scalar nulls, no malformed effects and1!/SA/once-only snapshots.
  - [x] NO REGRESSION: Direct three-route has_key fixture and interpreter/runner loadfile pass on available PUC5.5.1/LuaJIT with matching products. No broad suite or generated-format change; declared5.4/full admission separate.
  - [x] LOCKSTEP: Register fixture; contract/worked catalog/guide, Lua/array/emptiness facts/map and task/live/resume align. Book and fast memory/cadence/diagnosis/history/diff pass. Bounded emptiness rollout targeted-checked; String predicate assessment23.2.9 next after clean commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.9.5 - continue Lua generic emptiness results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10`
  Status: `active` / bounded children targeted-checked; broad admission23.4 separate
  Goal: Compatible result handoff for existing starts_with/ends_with/contains_substr/matches under string-predicate-results.md.
  Children: `.23.3.10.1`, `.23.3.10.2`, `.23.3.10.3`, `.23.3.10.4`, `.23.3.10.5`, `.23.3.10.6`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary String predicate result handoff.
  Dependencies: .23.2.9.
  Acceptance: Frozen string-predicate-results.md through public native/generated routes; preserve correct producers, actual kinds, null/empty/regex/source/operand/copy domains and SOC snapshots. One receiver operand before effects, source families, false retention, explicit bridges/scalar nulls; compile/small direct checks/docs/commit. No String-comparison registration, contains calibration or broader admission; Lua declared5.4 separate.

  Activation: clean `d58ea4478b36aff1c3c293fecbb3bb89c97f72be`; assessment committed, brief empty, tree clean.
  Owned paths: Existing Perl String predicate result-family/one-operand preflight only for confirmed gaps; shared native/fresh fixture, direct emptiness compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Native/fresh String predicate RED/GREEN across four methods, boundaries/source families/SOC and SC snapshots, false retention/bridges/scalar guards and malformed no-effects; direct emptiness fixture, source/test syntax/book and fast continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full regex/domain/portable admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Completion: Use scalar_result for the four existing String predicate methods and include them in exact-one-operand ordinary preflight. Producer bodies/domains/regex/source/copy unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/fresh shared fixture RED2/6 on fluent-null results; nested vectors/producer controls remain correct. Retained Get/substitution diagnostic identifies terminal lowering.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering _string_receiver_value_chain_return_family labels all four methods terminal, ending compatible later links. Preflight needs one-operand shape before enabling flow.
  - [x] FIX: Return scalar_result and reject missing/extra operands before source/operand effects; reuse existing scalar/text/generic/explicit-container bridge dispatch. No producer/kind/domain/regex policy normalization.
  - [x] ADDRESSED (verified): Native/fresh shared fixture passes all four true/false pairs, null/empty/regex-i boundaries, selected/pipeline/Hash-view/split/function/default/join sources, false retention/repeated generic predicates, bridges/scalar nulls, eight malformed no-effect controls and SOC/SC/once-only snapshots after RED.
  - [x] NO REGRESSION: Direct native/fresh emptiness fixture and source/test syntax pass;12 assertions across two targeted fixtures. No broad suite/comparison registration/contains calibration/format change.
  - [x] LOCKSTEP: Contract/worked catalog/guide, String fact/map and task/live/resume align. Book and fast memory/cadence/diagnosis/history/diff pass. Rust2 independent assessment next after clean commit; full regex/domain/portable admission separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.1 - continue Perl String predicate results`.
  Surfaced gate ownership: New predicate t files are not automatically selected by canonical CI; exact named no-match controls and required before-admission/push repair are owned by23.4.1. Current directly executed focused proof remains valid; no canonical-coverage claim is made here.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary String predicate result handoff.
  Dependencies: .23.3.10.1.
  Acceptance: Frozen string-predicate-results.md through public native/generated routes; preserve correct producers, actual kinds, null/empty/regex/source/operand/copy domains and SOC snapshots. One receiver operand before effects, source families, false retention, explicit bridges/scalar nulls; compile/small direct checks/docs/commit. No String-comparison registration, contains calibration or broader admission; Lua declared5.4 separate.

  Activation: clean `7f5c87cb72aae96cca15a03a703e19e969042ee5`; Perl committed, brief empty, tree clean; committed memory invariants rechecked PASS.
  Owned paths: Confirmed Rust String predicate scalar/terminal/shape dispatch gaps only; native/restored/generated-plan shared fixture, direct predicate-boundary compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public native/restored/generated-plan shared String predicate fixture before/after repair, direct scalar_predicate_boundaries fixture, targeted offline Cargo compilation, book and fast staged continuity/history/diff guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full regex/domain/portable admission23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.
  Prior continuity clarification: The prior leaf's last pre-stage memory check rejected its temporary staged/unstaged pointer split. Final staging removed that split, but the check was not rerun before commit; committed-state rerun passes all invariants in string-predicate-perl-memory-final.log. No content repair is needed. Run final memory checks after all staging and branch on their exit status before subsequent commits.
  Newly confirmed P1 producer issue / own now: After scalar/shape dispatch repair, every shared native field passes except matches("ABC",/^a/i) renders0! rather than canonical1!. Existing catalog explicitly supports i; do not weaken the expected result or infer unsupported flags. Isolate free/fluent producer, serialized literal representation and public matcher path using owned Rust/public interfaces; repair a bounded LinkedSpec flag-loss cause if possible before accepting this leaf, otherwise split a concrete upstream/access blocker. RGX/PGEN remain read-only black boxes.
  Producer root cause / bounded repair authority: Free matches flag controls serialize /^a/i and /^a/ identically as regex pattern ^a; direct (?i), (?m), (?s), (?x) controls work through the public Engine/matcher. Owned rust/linkedspec-core/src/expr.rs parse_regex explicitly consumes/discards adjacent suffix letters before Expr::RegexLiteral {pattern}. Restore catalog imsx/go/unknown semantics in the existing pattern-string representation, with no new regex value kind/schema field or RGX/PGEN implementation/pin change. Add native/restored/plan flag controls and focused Core regex parser compatibility; old compiled artifacts require regeneration because lost flags cannot be recovered.

  Completion: Scalar-result/one-operand guards for four existing predicates; restore literal imsx suffix modes as inline flags in the existing Expr::RegexLiteral pattern string, keep go no-ops, and lower unknown suffixes to an invalid pattern for existing contextual failure handling. No regex value variant/serialized field/dependency change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Engine native shared fixture RED has fluent null, SO/S-only effects and12 malformed effects. Dispatch-only candidate leaves regex-i0!; free matches controls serialize /^a/i and /^a/ as identical pattern ^a. Native suffix imsx fail while equivalent inline controls work; unknownq is wrongly accepted.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs scalar/preflight lists omit predicates; existing terminal guards already honor selected results. Core expr.rs parse_regex explicitly skips adjacent flag letters then emits only body. This is LinkedSpec producer loss, not an inferred RGX defect.
  - [x] FIX: Add four methods to existing dispatch/shape lists; encode declared modes in existing pattern payload, deduplicate modes, ignore go and fail unsupported flags using existing invalid-regex handling. Preserve numeric substring flags/Boolean matches and all unrelated producer/domain/source/copy policies; no schema/type or black-box writes.
  - [x] ADDRESSED (verified): Native/restored/generated-plan shared result fixture passes true/false/null/empty/regex-i, source families, false retention/generic/bridges/scalar guards, no malformed effects and SOC/SC/once-only snapshots. Same three routes pass imsx, inline/no-flag controls, duplicatei, go/unknownq and flagged split/filter consumers after RED.
  - [x] NO REGRESSION: Direct scalar_predicate_boundaries and18 focused Core regex parser/compiler/validation tests pass with targeted offline compilation. No full suite or new serialized field/regex type. Older compiled nodes retain recorded patterns; regenerate from source to acquire previously lost suffix modes.
  - [x] LOCKSTEP: Contract/worked catalog/guide, String/regex facts/map and task/live/resume align. Book/history/diff and final staged memory/cadence/diagnosis checks pass; no canonical-coverage claim. Dart3 next after clean commit; full regex/admission and mandatory Perl registration23.4.1 remain separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.2 - carry Rust predicate results and regex flags`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary String predicate result handoff.
  Dependencies: .23.3.10.2.
  Acceptance: Frozen string-predicate-results.md through public native/generated routes; preserve correct producers, actual kinds, null/empty/regex/source/operand/copy domains and SOC snapshots. One receiver operand before effects, source families, false retention, explicit bridges/scalar nulls; compile/small direct checks/docs/commit. No String-comparison registration, contains calibration or broader admission; Lua declared5.4 separate.

  Activation: clean `d42199d00ee1f5a4712a3d8151c9dc8d1e9a2d1a`; Rust committed, brief empty, tree clean; final staged checks passed.
  Owned paths: Confirmed Dart ordinary String predicate dispatch/shape gaps only; shared native/restored/generated-plan fixture, direct emptiness compatibility, selected-file analysis and current docs.
  Verification tier: `focused`
  Focused checks: Public native/restored/generated-plan shared predicate fixture before/after repair, direct emptiness fixture, fatal selected-file analysis, book/history/diff and final staged memory/cadence/diagnosis checks.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full regex/domain/portable admission23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Newly confirmed P1 producer defects / own now: Native shared RED renders null suffix/needle operands1! instead of0!, regex /^a/i0! instead of1!, container negatives[] and malformed shapes execute12 effects. _callStringPredicate explicitly coerces null operands to empty text; ActionRegexLiteralExpr retains flags in AST/JSON but interpreter evaluation and contextual pattern conversion drop them. Restore null handling and existing inline i/m/s modes without changing producer kinds or introducing a public regex type. Other regex dialect/flag admission remains separate.

  Completion: Add four existing predicates to scalar/one-operand guards; stop null text operand coercion; retain literal i/m/s suffix modes in existing pattern strings/contextual helper operands using the existing inline bridge. No new type/schema or producer-kind normalization.
  Verification:
  - [x] REPRODUCE / ISSUE: Native shared RED has null suffix/needle1! instead of0!, regex-i0! instead of1!, container negatives[] and12 malformed effects. Valid result flow and SOC/SC snapshots already work.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart scalar/shape lists omit four predicates; _callStringPredicate sets nullAsEmpty; regex literal evaluation/contextual conversion return body without already-serialized flags. Extra inline grouped/dotted control fails separately because action_parser.dart rejects slash before (, exposing its dot as a fluent separator; owned P1 sibling6.
  - [x] FIX: Extend only existing guards; preserve null operands; encode suffix i/m/s for existing runtime bridge in action/contextual pattern conversion. Preserve numeric substring/Boolean matches and eager source/operand snapshots; no regex bridge/domain expansion.
  - [x] ADDRESSED (verified): Shared native/restored/plan expected JSON passes source families, all four true/false pairs, null/empty/regex-i, false retention/generic/bridges/scalar guards, SOC/SC/once-only effects and malformed no-effects. Added i/m/s no-flag/inline controls, duplicatei and flagged split/filter pass on all three routes.
  - [x] NO REGRESSION: Direct emptiness fixture and fatal selected-file analysis pass; three targeted tests. Added flag control initially had one extra expected Boolean after extracting the separately owned grouped-pattern case; corrected expected vector to authored eleven values, with all distinguishing false/true controls retained. No full suite or broad regex/comparison/contains admission.
  - [x] LOCKSTEP: Contract/book/String+regex facts/map and task/live/resume align. Book/history/diff and final staged memory/cadence/diagnosis checks pass; canonical coverage not claimed. Julia4 next after clean commit; P1 grouped Dart regex6 follows Julia/Lua before further families.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.3 - carry Dart predicate results and literal modes`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary String predicate result handoff.
  Dependencies: .23.3.10.3.
  Acceptance: Frozen string-predicate-results.md through public native/generated routes; preserve correct producers, actual kinds, null/empty/regex/source/operand/copy domains and SOC snapshots. One receiver operand before effects, source families, false retention, explicit bridges/scalar nulls; compile/small direct checks/docs/commit. No String-comparison registration, contains calibration or broader admission; Lua declared5.4 separate.

  Activation: clean `860e231f93714da4076ab477d6934b75b5d5e0d8`; Dart committed, brief empty and tree clean; post-commit pointer passed.
  Owned paths: Confirmed Julia ordinary String predicate result/shape gaps; shared native/generated-plan/fresh emitted fixture and registration, direct emptiness compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Shared public native/plan/fresh String predicate fixture before/after repair plus direct emptiness fixture with strict depwarn compilation; book/history/diff and final staged memory/cadence/diagnosis checks.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full regex/domain/portable admission23.4, Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Confirmed P1 producer boundary / own now: Native/plan/fresh shared RED renders null suffix/needle1! rather than0!, scalar negatives[], malformed predicate values with12 effects. Valid true/false/regex-i/SOC/SC/source-family behavior already works. _runtime_string_predicate explicitly coerces null operands to empty text; restore canonical undefined-operand false alongside existing scalar/shape lists, preserving actual numeric/Bool kinds and regex/eager evaluation policies.

  Completion: Extend existing scalar/one-operand lists for four predicates; reject undefined text operands instead of empty-text coercion. Existing correct result flow, regex flags, source/operand/result snapshots and numeric/Bool producer kinds remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared native/plan/fresh fixture RED renders null suffix/needle1!, scalar negatives[] and12 malformed effects; valid flow/regex-i/SOC/SC already correct.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _evaluate_runtime_fluent_chain! omits four predicates from scalar/preflight lists; _runtime_string_predicate sets null_as_empty on operand.
  - [x] FIX: Add four existing methods to lists and remove operand null coercion. No producer-kind/regex/source/copy normalization or new method/domain admission.
  - [x] ADDRESSED (verified): Native/plan/fresh exact shared JSON passes true/false/null/empty/regex-i, source families, false retention/generic/explicit bridges/scalar guards, eight malformed no-effect controls and SOC/SC/once-only snapshots.
  - [x] NO REGRESSION: Direct emptiness fixture and strict depwarn compilation pass; six targeted assertions across public native/plan/fresh routes. Full regex/domain/context admission remains separate.
  - [x] LOCKSTEP: Registered new Julia fixture; contract/book/String+Julia fact/map and task/live/resume align. Book/history/diff and final staged memory/cadence/diagnosis pass; Lua5 next after clean commit, P1 Dart grouped regex6 follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.4 - guard Julia predicate results and null operands`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary String predicate result handoff.
  Dependencies: .23.3.10.4.
  Acceptance: Frozen string-predicate-results.md through public native/generated routes; preserve correct producers, actual kinds, null/empty/regex/source/operand/copy domains and SOC snapshots. One receiver operand before effects, source families, false retention, explicit bridges/scalar nulls; compile/small direct checks/docs/commit. No String-comparison registration, contains calibration or broader admission; Lua declared5.4 separate.

  Activation: clean `4584d0b41e12581a7bc68e9ad80336abf968d72f`; Julia committed, brief empty and tree clean; post-commit pointer passed.
  Owned paths: Confirmed Lua ordinary String predicate terminal/result/shape gaps; shared native/plan/fresh fixture on available hosts and named runner registration, direct emptiness compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Shared public native/plan/fresh String predicate RED/GREEN on PUC5.5.1/LuaJIT, direct emptiness fixture and loadfile compilation, book/history/diff and final staged memory/cadence/diagnosis checks.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full regex/domain/portable admission23.4, declared5.4 proof, Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression on named hosts, no quantified population or portable measurement.

  Newly confirmed P1 producer boundary / own now: Both hosts show terminal-null/SO/S/12-effect RED. Flow-only candidate additionally exposes null suffix/needle1! rather than0!; string_predicate explicitly uses scalar_string(...,true), matching Dart/Julia cause. Restore canonical null-operand false. Existing run.lua matches terminal_chain expectation contradicts new flow; its neighboring length().trim() terminal expectation is also stale after23.3.3. Update and run only those exact direct String/regex cases alongside shared/direct emptiness; no full suite.

  Known native failure recovered / no new defect: The added existing full regex helper compatibility case re-enters the recorded malformed-pattern PUC5.5.1 crash (exit139). Canonical lua-native-readme-and-action-ast-reading and pending LUA-STARTUP-READING.2.3 already locate unsupported %lu in regex_pcre2.c luaL_error; that exact group was explicitly excluded under reading1.42. This slice mistakenly selected it before checking the known exclusion. No repeat crash or native patch; keep repair/re-admission with existing owner and prerequisite2.2 runtime/header identity. JIT whole case passes; PUC pass counts exclude it. Safe shared/direct checks pass on both hosts.
  Completion: Remove four String predicate terminal fences; mark results scalar, preflight one operand and reject null text operands. Existing numeric/Bool kinds, regex/source/copy and correct snapshots remain. Register named fixture and update stale matches/length terminal expectations in directly affected runner cases.
  Verification:
  - [x] REPRODUCE / ISSUE: Both hosts' shared native RED has fluent null/SO/S and12 malformed effects while nested controls work. Dispatch candidate exposes null suffix/needle1! instead of0!; initial candidate accidentally retained starts_with last map entry, removed before acceptance.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua TERMINAL_STRING_HELPERS fences four methods, scalar/preflight omit them, and string_predicate calls scalar_string operand with null-as-empty. Existing runner terminal assertions lag result features. Native malformed-pattern failure has separate canonical cause/owner above.
  - [x] FIX: Remove only four fences, extend scalar/shape lists and reject null operand coercion; update direct runner expectations. No producer kind/regex/domain/source/copy normalization or native dependency change.
  - [x] ADDRESSED (verified): Both hosts' shared native/plan/fresh exact JSON passes four true/false pairs, null/empty/regex-i, source families, false retention/generic/bridges/scalar guards, eight malformed no-effect controls and SOC/SC/once-only snapshots.
  - [x] NO REGRESSION: Both hosts pass shared/direct emptiness plus affected deterministic String case; JIT also passes whole strict regex helper case, PUC excludes its known native invalid-pattern crash. Selected runner gives3 PUC /4 JIT named cases; all changed Lua files loadfile-compile. No whole suite/declared5.4/full regex admission claim.
  - [x] LOCKSTEP: Contract/book/String+Lua fact/map and task/live/resume align. Book/history/diff and final staged memory/cadence/diagnosis checks pass; P1 Dart grouped regex6 next after clean commit. Native crash remains owned2.3 with runtime/header prerequisite2.2; do not relabel as fixed.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.5 - continue Lua predicates and reject null operands`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.6`
  Status: `completed`
  Priority: P1; owned Dart grouped-regex action scanner repair, immediately after Julia4/Lua5 result handoff and before further family/admission work.
  Goal: Repair the newly reproduced grouped literal/dot parsing boundary without confusing division or receiver syntax.
  Reproduction: Public native execution of Top:: I { return(matches(input_text(),/(?s)^a.b$/)) } raises unsupported raw action expression for /(?s)^a.b$/; same mode as /^a.b$/s executes. Additional mode control failed in string-predicate-dart-green.log while the shared String fixture/direct emptiness passed.
  Root cause: action_parser.dart _looksLikeRegexStart explicitly rejects slash followed by open parenthesis; _splitTopLevelFluentSegments consequently sees the pattern's dot, and _parseFluentChain emits ActionRawExpr(reason invalid_fluent_chain) before _parseLiteral can recognize it. Existing matching.dart supports inline i/m/s; do not classify this as an engine limitation.
  Acceptance: Focused public AST/native/restored/plan grouped/dotted and slash/division/receiver controls, minimal lexical repair, direct predicate compatibility and current book/fact/task/live docs. Assess extended x/unknown suffix modes independently before claiming full catalog support; current i/m/s repair is bounded. No dependency implementation inspection, public regex type or full gate.
  Activation: clean `5bf0009e421a35f99aaa4b4fae5c08c2e5f8bf74`; Lua committed, brief empty/tree clean, post-commit pointer passed.
  Scope reconciliation: Canonical dart-regex-brace-scanner-defects already owns the same slash-before-( scanner cause under DART-STARTUP-READING.2.2.1; broader attached-block/grouped-brace and validator/outer collector repairs stay there/2.2.2. This leaf repairs complete standalone action literal recognition before fluent splitting, including grouped dots, without globally reclassifying slash/division or closing those owners. No x/unknown-mode expansion in this bounded leaf.
  Verification tier: `focused`
  Focused checks: Public grouped-literal AST/native/restored/generated-plan RED/GREEN, slash symbolic-call/ordinary fluent controls, direct String predicate fixture, fatal selected-file analysis and small parser test; book/history/diff and final staged memory/cadence/diagnosis.
  Canonical trigger: None for bounded first-party action literal priority repair under director feature-first cadence; broad scanner/domain/portable admission and final clean push remain separate.
  Claim verification: none: deterministic authored lexical/result regressions, no quantified population or portable measurement.

  Completion: Recognize a complete ActionRegexLiteralExpr before assignment/fluent scanning; do not change global slash classification. Grouped dotted literals retain pattern payload/source spans through existing AST/JSON and runtime bridge. Broader scanner/brace owners remain open.
  Verification:
  - [x] REPRODUCE / ISSUE: Public parseActionExpression(/(?s)^a.b$/) RED returns ActionRawExpr; prior native result test raises unsupported raw expression. Suffix /^a.b$/s works.
  - [x] ROOT CAUSE (WHY + WHERE): action_parser.dart _parseExpr tries fluent splitting before _parseLiteral; existing _looksLikeRegexStart rejects slash before (, so the pattern dot is treated as a method separator. Canonical broader scanner owner2.2.1 is retained, not duplicated/closed.
  - [x] FIX: At _parseExpr entry, recognize only complete slash literals using existing anchored literal parser. Symbolic division calls/ordinary receiver expressions fail this literal check and follow the original route. No general delimiter/validator/outer collector change or new regex type/mode.
  - [x] ADDRESSED (verified): Public AST and native/restored/generated-plan grouped dotted regex and fluent/nested matches return exact [true,1!,true,4,A.B] with symbolic division/ordinary receiver controls. Existing shared predicate/mode tests pass.
  - [x] NO REGRESSION: Direct action_ast_parser_test plus changed result test pass10 targeted tests; fatal selected-file analysis passes. No whole suite or broader grouped-brace/x/unknown regex admission.
  - [x] LOCKSTEP: Contract/book/String+regex facts/map and task/live/resume align. Book/history/diff and final staged memory/cadence/diagnosis pass. Definedness assessment23.2.10 next after clean commit; broader DART-STARTUP-READING.2.2.1/.2.2.2 and Lua native crash2.3 remain owned.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.6 - parse complete grouped regex literals before fluent dots`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.10.7`
  Status: `completed`
  Priority: P1 immediate next after23.2.12, before contains23.2.13.
  Goal: Preserve complete grouped or whitespace-prefixed action regex literal boundaries inside ordinary helper calls, including invalid grouped regex reaching its helper failure boundary.
  Dependencies: .23.2.12 committed cleanly; coordinate existing DART-STARTUP-READING.2.2.1/.2.2.2 without claiming their full scanner/validator closeout.
  Reproduce: Public authored matches("abc",/(/), receiver matches(/(/), split/filter(/(/) become raw action expressions instead of reaching false/empty helper behavior. The same malformed text as a quoted runtime pattern reaches a FormatException;23.2.12 owns that helper boundary.
  Root cause: action_parser.dart _looksLikeRegexStart rejects slash followed by opening parenthesis/whitespace; _findMatchingDelimiter therefore counts the regex's opening parenthesis as action syntax and misses the enclosing call end. Complete standalone /(/ still has literal priority. Retained public AST/native probe: docs/checkpoints/type-operation-inventory/probe_dart_grouped_invalid_pattern.dart.
  Acceptance: Reconcile operand-position slash literals against symbolic /(8,2) and / (8,2), ordinary numeric division, escaped delimiters, classes and valid grouped patterns. Confirm exact AST/source spans and native/restored/plan false/empty invalid-group consumers; small direct parser/String checks and docs/commit. No global regex type, engine/dialect, unassessed brace-scanner/validator closure or full suite.
  Planned verification tier: focused; declare metadata at activation.

  Activation: clean `dc7b9950764bdf717b07de3429c7de9dd9336098`; modes committed, brief0/tree clean.
  Owned paths: Complete grouped/whitespace-prefixed action operand recognition, exact public AST/source and native/restored/plan consumers, direct bounded parser/String checks and docs. Broader brace-scanner/validator admission remains DART2.2.
  Verification tier: `focused`
  Focused checks: Retained public grouped-invalid AST/native probe, exact operand AST/spans/division and native/restored/plan RED/GREEN, prior mode/String fixture, selected-file fatal analysis/formatting and book/history/diff/final staged continuity checks.
  Canonical trigger: None for bounded ordinary syntax preservation under director feature-first cadence; broad scanner/validator/context admission remains separate.
  Claim verification: none: deterministic authored parse/runtime regression controls, no grammar population/completeness measurement.

  Completion: _looksLikeRegexStart accepts complete grouped/whitespace-prefixed slash operands only at existing operand-start positions. Reuse literal escape/body/flags shape with a following operand boundary after optional whitespace; no closing slash means symbolic division remains a call. Matching/statement/fluent scanners reuse this classification. No validator/dialect/schema change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public AST/native probe and new exact operand fixture RED: nested /(/ is ActionRawExpr and helper/receiver/split/filter are unsupported raw code. Five valid grouped/escaped/class/whitespace/division/quoted controls already pass. Standalone /(/ is RegexLiteral.
  - [x] ROOT CAUSE (WHY + WHERE): action_parser.dart _looksLikeRegexStart unconditionally rejects next '(' or whitespace; _findMatchingDelimiter and shared _consumeScanChar then count regex punctuation as action syntax. A complete literal prefix must have escaped delimiters and a real following operand boundary, not just a slash somewhere later.
  - [x] FIX: Add one compiled complete-prefix recognizer and retain existing preceding-operand classification. Right-boundary lookahead skips whitespace before requiring delimiter/end; this prevents a second spaced division call from closing a supposed regex over adjacent array entries. Preserve symbolic calls and source text/spans.
  - [x] ADDRESSED (verified): Exact RegexLiteral operand pattern/source/span14-17 passes; native/restored/plan grouped invalid matches/receiver false and split/filter empty, valid escaped delimiter/class/whitespace groups and nested/adjacent/continued symbolic divisions pass. Retained probe now reports typed call/false and division4, with no new Regex kind.
  - [x] NO REGRESSION: Prior mode/String fixtures and direct ActionIR parser controls pass;44 targeted Dart tests plus fatal selected-file analysis/formatting. No full suite, broad brace/scoped-regex/emitted admission or existing validator repair inferred.
  - [x] LOCKSTEP: Book removes obsolete ordinary grouped-invalid caveat and teaches helper false/empty; canonical mode/operand/brace facts, DART2.2.1 partial repair note and current task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Contains23.2.13 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.10.7 - recognize complete Dart grouped regex operands`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.11`
  Status: `active` / bounded children targeted-checked; broad admission23.4 separate
  Goal: Ordinary is_defined/is_undefined generic receiver/result handoff under definedness-results.md; preserve actual producer kinds/domains.
  Children: `.23.3.11.1`, `.23.3.11.2`, `.23.3.11.3`, `.23.3.11.4`, `.23.3.11.5`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.11.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary generic definedness receiver/result handoff.
  Dependencies: .23.2.10.
  Acceptance: Frozen definedness-results.md through public native/generated routes; preserve actual non-null definition, true/false kinds/text/default behavior and correct source/result snapshots. Zero receiver operands before effects, source families/all admitted value kinds, compatible scalar/generic consumers/explicit bridges and scalar guards. Small compile/direct check/docs/commit; full regex/domain/portable admission and Lua declared5.4 separate.

  Activation: clean `152208bb63b82cf30b52e9eba483dc8027093062`; assessment committed, brief empty/tree clean; post-commit pointer passed.
  Owned paths: Existing Perl generic definedness receiver routing/result/shape registrations only; actual free helpers already correct. Shared source fixture with explicit Perl expected variant, native/fresh regression, direct String predicate compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public native/fresh generic definedness RED/GREEN fixture, direct String predicate fixture, source/test syntax, book/history/diff and final staged memory/cadence/diagnosis. Preserve1/empty-string and correct nested SC snapshot control; no broad suite.
  Canonical trigger: None for bounded frozen implementation under director feature-first cadence; full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored regression values/order, no quantified population or portable measurement.

  Newly exposed P1 operand lowering / own now: Registration-only native/fresh fixture compiles but reaches undefined host first; public dump_parser_source emits defined(word)/!defined(missing), defined(first(...)) and an unlowered is_defined(word) inside the explicit split bridge. The existing typed free helper's generic variable_source operand path is unsuitable when synthetic receiver source is reconstructed; literal/free-nested assessment remains correct. Lower the definedness operand as an actual typed value (bare_scalar_read), preserving defined()/!defined() result representation and once-only behavior. Include names in existing legacy nested helper recognition only as required by the demonstrated bridge.

  Completion: Register definedness generic/scalar/zero-operand routes, preserve actual source-kind/copy/default dispatch and add handoff after numeric prefixes. Typed actual-value operands plus a corresponding legacy definedness branch finish synthetic producers; remove dead generic typed cases. Keep defined()/!defined()1/empty-string results unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: LinkedSpec::Get native/fresh shared fixture RED has raw-host/compile failures. Registration candidate emits defined(word), defined(first(...)) and raw is_defined inside split bridge, reaching undefined host first. call_spec_handler_subst/dump_parser_source retain exact mechanisms and locations.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering's generic/return-family/shape/copy guards omit definedness. Reconstructed call operands need bare_scalar_read typed lowering; selected/bridge paths enter the compatibility lowerer, which has no definedness branch. Free literal/nested assessment semantics already correct.
  - [x] FIX: Extend existing registrations/guards; keep first generic sources on actual-kind route, permit numeric-prefix handoff, lower typed operands fully and add explicit legacy producer lowering. Preserve1/empty-string actual kinds, definedness/domain/source/copy/default policies; no Boolean normalization.
  - [x] ADDRESSED (verified): Native/fresh shared source with explicit Perl expected JSON passes true/false/null/empty/zero/Array/Hash, named/selected/pipeline/numeric/function/default/copied sources, false text/fallback, repeated generic/explicit bridges/scalar guards, malformed no-effects and1!/SC/one source call.
  - [x] NO REGRESSION: Direct native/fresh String predicate fixture passes; final definedness rerun6 assertions passes after completing the missing legacy path. Source/test syntax pass; no phase0/full suite or other-backend/portable admission claim. Known wrapper setpgid warning occurs only in the failed intermediate log; existing SESSION7 owner unchanged.
  - [x] LOCKSTEP: Contract/source/Perl expected variant/native+fresh fixture, book/guide and canonical fact/map align with task/live/resume and SESSION28.5/index. Histories/book/diff and final staged memory/cadence/diagnosis checks pass; Rust2 next after clean commit. New Perl fixture canonical registration remains mandatory23.4.1 before admission/push.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.11.1 - add Perl generic definedness receiver flow`.

  Same-slice history containment: CHANGES reached its90% byte rollover trigger; tool archived only a complete clean-HEAD suffix as docs/history/changes/segment-4958-c104128986da.md and refreshed the manifest/root. Apply/check pass; no immutable prior evidence edited.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.11.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary generic definedness receiver/result handoff.
  Dependencies: .23.3.11.1.
  Acceptance: Frozen definedness-results.md through public native/generated routes; preserve actual non-null definition, true/false kinds/text/default behavior and correct source/result snapshots. Zero receiver operands before effects, source families/all admitted value kinds, compatible scalar/generic consumers/explicit bridges and scalar guards. Small compile/direct check/docs/commit; full regex/domain/portable admission and Lua declared5.4 separate.

  Activation: clean `c9986d985378fdf5ec80ce828e766784bb5093cd`; Perl committed, brief empty/tree clean; post-commit pointer passed.
  Owned paths: Confirmed Rust ordinary generic definedness dispatch/result/shape gaps; shared source/current Boolean expected variant and public native/restored/plan fixture, native free producer preservation control, direct String compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public actual free producer kind/text/default control and native/restored/generated-plan shared definedness fixture before/after repair, direct String result fixture, targeted offline Cargo compilation, rustfmt and book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression and explicit backend producer preservation, no quantified population or portable measurement.

  Newly confirmed P1 literal receiver parse gap / own now: Public Engine free producer control passes Bool/0!/retained false, but shared source compilation fails at false.is_defined() (expected comma or closing array). Core expr.rs parse primary immediately returns BooleanLiteral/Undef while numeric/String primaries enter parse_fluent_chain. Add the same existing postfix path for true/false/undef; preserve whole-word prefix checks and existing AST/schema. This is a first-party syntax handoff needed by the frozen generic value-kind contract, not a numeric-dot or dependency defect. Then independently assess runtime dispatch/guards without weakening source literal cases.

  Runtime baseline after literal syntax repair: Native free producer vector retains Bool/text/default controls; newly parsed true/false/undef receiver controls return null. Shared receiver values are null while nested controls give1!; malformed calls execute4 effects. Source/consumer already execute once in SC order and source becomes changed. is_emptiness_receiver_method currently gates actual-kind generic dispatch and prefix/copy/selected handoffs; extend that shared classification to all four existing generic predicates, scalar-result and zero-operand lists without changing helper producer semantics.

  Snapshot distinguishing control: Strengthen only the shared consumer mutation from one defined String to actual null; expected predicate result stays1!, orderSC/calls1 and final source null on both backend-specific goldens. This distinguishes capturing the earlier predicate from reading the mutated binding later. Recheck the same Perl native/fresh and Rust native/restored/plan fixture because its shared input changed; no broader suite. Historical assessment probe remains its recorded changed-String baseline.

  Completion: Core true/false/undef literals use existing fluent parsing; runtime generic classification covers definedness in initial/selected/copy/family-prefix dispatch and scalar/zero-operand lists. Existing Bool producer, scalar-text/default/null/source/copy policies and AST/schema stay unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Engine free Bool/text/default control passes; shared compile RED stops at false.is_defined(). Added true/false/undef postfix control also fails compilation. Parser-only candidate gives native null receiver values beside nested1!, three literal controls null and4 malformed effects.
  - [x] ROOT CAUSE (WHY + WHERE): Core expr.rs returns BooleanLiteral/Undef before parse_fluent_chain; number/String primaries already enter it. engine.rs is_emptiness_receiver_method restricts existing actual-kind generic/prefix/copy/selected dispatch; scalar/zero-operand lists omit definedness. Producer/source/order already correct.
  - [x] FIX: Add existing postfix parser calls at three literal returns with whole-word checks unchanged; rename/extend shared generic receiver classification and scalar/shape lists. No helper producer, type/schema, regex/dependency or Boolean normalization change.
  - [x] ADDRESSED (verified): Native/restored/plan shared exact Boolean expected JSON passes source/null/defined/empty/false/zero/container/copy families, false retention/generic/bridges/scalar guards, malformed no-effects and1!/SC/one-call snapshots. Native free producer/literal vector preserves actual Bool/text/default. Strengthened consumer mutates source to null yet earlier result staystrue; same Perl native/fresh fixture recheck passes.
  - [x] NO REGRESSION: Direct String predicate result/flag fixtures pass; four focused Rust tests pass; after the shared snapshot input change, the same definedness2 and Perl6 assertions recheck successfully. Targeted offline compilation and rustfmt pass. No broad suite or portable/full-domain claim; Perl1/empty-string and RustBool variants are explicit.
  - [x] LOCKSTEP: Shared source/Boolean+Perl expectations, contract/book/guide and generic/teaching facts/map align with task/live/resume. Book/history/diff and final staged memory/cadence/diagnosis checks pass; Dart3 next after clean commit. Full admission/Perl canonical registration23.4.1 remain separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.11.2 - carry Rust definedness and literal receiver chains`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.11.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary generic definedness receiver/result handoff.
  Dependencies: .23.3.11.2.
  Acceptance: Frozen definedness-results.md through public native/generated routes; preserve actual non-null definition, true/false kinds/text/default behavior and correct source/result snapshots. Zero receiver operands before effects, source families/all admitted value kinds, compatible scalar/generic consumers/explicit bridges and scalar guards. Small compile/direct check/docs/commit; full regex/domain/portable admission and Lua declared5.4 separate.

  Activation: clean `01e9d8aae02e76ead8575468c743490a431926a7`; Rust committed, brief empty/tree clean; post-commit pointer passed; identity derived from Git.
  Owned paths: Confirmed Dart ordinary generic definedness result/shape gaps; shared native/restored/generated-plan fixture and actual Bool/text/default controls, direct String compatibility, fatal selected-file analysis and current docs.
  Verification tier: `focused`
  Focused checks: Public actual producer and shared native/restored/plan RED/GREEN including null-mutating snapshot, direct String fixture and selected-file fatal analysis, book/history/diff and final staged memory/cadence/diagnosis.
  Canonical trigger: None for bounded frozen implementation under director feature-first cadence; full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Public baseline: Shared native valid source/result/null/empty/false/zero/copy/default/generic/bridge and1!/SC/one-call/final-null snapshot fields already match. Only container negatives[] and malformed[1!,1!]/four effects fail; free Bool/text/default/true-false-undef literal controls pass native/restored/plan. interpreter.dart scalar-result and zero-operand lists omit definedness; extend only those lists, preserving producer/domain/source/copy behavior.

  Completion: Add definedness to existing scalar-result and zero-operand lists only. Valid generic helper dispatch, Bool/text/default/source/copy and primitive literal parsing were already correct; preserve them.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native shared exact JSON differs only at container negatives[] and malformed[1!,1!]/four effects. Free Bool/text/default and true/false/undef literal control passes native/restored/plan before repair.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart fluent preflight and mayProduceScalar lists omit is_defined/is_undefined. Existing generic/pure helper dispatch already accepts actual kinds and snapshots.
  - [x] FIX: Four list entries across those two guards; no producer/parser/type/schema/domain/source/copy change or Boolean normalization.
  - [x] ADDRESSED (verified): Shared native/restored/plan exact Boolean JSON passes true/false/null/empty/zero/containers, source/copy families, false retention/repeated generic/bridges/scalar guards, malformed no-effects and1!/SC/one-call/final-null snapshot; free producer controls continue passing on all three routes.
  - [x] NO REGRESSION: Direct String predicate/mode/grouped-literal fixture and fatal selected-file analysis pass; five targeted Dart tests. No broad suite or full-domain/portable admission.
  - [x] LOCKSTEP: Contract/book/guide and canonical Dart fact/map align with task/live/resume. Book/history/diff and final staged memory/cadence/diagnosis pass; Julia4 next after clean commit. Mandatory Perl canonical registration23.4.1/full admission stay separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.11.3 - guard Dart definedness result boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.11.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary generic definedness receiver/result handoff.
  Dependencies: .23.3.11.3.
  Acceptance: Frozen definedness-results.md through public native/generated routes; preserve actual non-null definition, true/false kinds/text/default behavior and correct source/result snapshots. Zero receiver operands before effects, source families/all admitted value kinds, compatible scalar/generic consumers/explicit bridges and scalar guards. Small compile/direct check/docs/commit; full regex/domain/portable admission and Lua declared5.4 separate.

  Activation: clean `4423e5131ef76fd046d54438aae1470731050b1c`; Dart committed, brief empty/tree clean; post-commit pointer passed; identity derived from Git.
  Owned paths: Confirmed Julia ordinary generic definedness result/shape gaps; shared native/generated-plan/fresh fixture and producer controls/runner registration, direct String compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Shared public native/plan/fresh RED/GREEN plus free Bool/text/default/literal controls and direct String fixture with strict depwarn compilation; book/history/diff and final staged memory/cadence/diagnosis.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order regression, no quantified population or portable measurement.

  Public baseline: Native/plan/fresh shared valid fields including null/empty/false/zero/copy/default/generic/bridge and1!/SC/one-call/final-null snapshot agree; container negatives[] and malformed[1!,1!]/four effects fail. Existing Bool producer and generic dispatch are preserved; extend scalar/zero-operand lists only. Initial top-level failing testset stops before later free-control testset; consolidate both calls into one testset so all six route assertions execute in the final focused check, without claiming unrun baseline producer controls.

  Producer-kind oracle / fixed now: Existing Julia == value comparison alone can accept Boolean/integer equality; add explicit isa Bool assertions at Boolean expected positions of the retained producer vector on native/plan/fresh routes. Shared value controls and runtime producer stay unchanged; rerun only this same fixture after adding its distinguishing type assertion, no broader matrix.

  Completion: Add definedness to scalar-result/zero-operand lists only; register new fixture. Preserve Bool/text/default/actual-kind source/copy/literal semantics and correct snapshots. Explicit Bool producer-type assertions strengthen the value oracle on all three routes.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/plan/fresh shared RED has container negatives[] and malformed[1!,1!]/four effects while other expected fields including1!/SC/one-call/final-null match. Initial top-level failure prevents later producer set; no unrun baseline control is claimed.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl fluent scalar-result and zero-operand lists omit definedness; existing generic dispatch/producer already handle actual kinds. Value equality alone does not establish Bool identity, so producer assertions need isa Bool.
  - [x] FIX: Extend two existing lists; preserve producer/parser/schema/domain/source/copy. Consolidate shared and producer checks into one testset and assert Bool at expected Boolean vector positions for native/plan/fresh. No numeric-Boolean normalization.
  - [x] ADDRESSED (verified): Exact shared Boolean expected JSON passes source/null/defined/empty/false/zero/copy/default/selected/numeric/function families, false retention/generic/bridges/scalar guards, malformed no-effects and1!/SC/one-call/final-null. Native/plan/fresh free producer/text/default/literal controls and type assertions pass.
  - [x] NO REGRESSION: Definedness6 value and direct String3 assertions pass with strict depwarn compilation; after type-assertion addition, the same definedness fixture passes9 assertions. No whole suite/full-domain/portable admission or producer/parser repair claim.
  - [x] LOCKSTEP: New runner include, contract/book/guide and Julia/generic facts/map align with task/live/resume. Book/history/diff and final staged memory/cadence/diagnosis pass; Lua5 next after clean commit. Perl canonical registration23.4.1 and full admission remain separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.11.4 - guard Julia definedness scalar and arity flow`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.11.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary generic definedness receiver/result handoff.
  Dependencies: .23.3.11.4.
  Acceptance: Frozen definedness-results.md through public native/generated routes; preserve actual non-null definition, true/false kinds/text/default behavior and correct source/result snapshots. Zero receiver operands before effects, source families/all admitted value kinds, compatible scalar/generic consumers/explicit bridges and scalar guards. Small compile/direct check/docs/commit; full regex/domain/portable admission and Lua declared5.4 separate.

  Activation: clean `77dad432e0851e4071f09ad47bc36294526dbd39`; Julia committed, brief empty/tree clean; post-commit pointer passed; identity derived from Git.
  Owned paths: Confirmed Lua ordinary generic definedness terminal/result/shape gaps; shared native/plan/fresh fixture and producer controls/runner registration on available hosts, direct String compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Shared native/plan/fresh definedness RED/GREEN and free Bool/text/default/literal controls on PUC5.5.1/LuaJIT, direct String fixture/loadfile compilation, book/history/diff and final staged memory/cadence/diagnosis.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; declared5.4/full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored regression values/order on named hosts, no quantified population or portable measurement.
  Known exclusion: Do not select the existing malformed regex groups; native crash LUA-STARTUP-READING.2.3 and declared-primary identity2.2 remain independently owned. Valid direct String fixture uses no malformed regex.

  Public baseline: Both hosts' shared native RED has terminal-null results, nested1!, orderS/sourceabc and4 malformed effects; source call remains once. Producer-first recheck confirms all native/plan/fresh Bool/text/default and true/false/undef literal controls before reaching the same shared failure. Only remaining TERMINAL_STRING_HELPERS entries are definedness; remove that now-empty fence/map and extend scalar/zero-operand lists, keeping String comparison policy and existing producers unchanged.

  Completion: Remove definedness's last two terminal fences and the empty private map; mark results scalar and preflight zero operands. Register named fixture; String comparison terminal policy and existing Bool/source/copy/domain semantics remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Both hosts' shared native RED gives fluent null beside nested1!, orderS/sourceabc and4 malformed effects. Producer-first recheck passes native/plan/fresh Bool/text/default and true/false/undef literal controls before reaching the same shared failure.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua TERMINAL_STRING_HELPERS retains only is_defined/is_undefined; scalar and zero-operand lists omit them. Producers already yield correct Bool/text/default values and source evaluation is once.
  - [x] FIX: Delete only those remaining entries/map and simplify its sole fence to the unchanged String comparison condition; extend scalar/shape lists. No producer/parser/type/schema/domain/source/copy normalization.
  - [x] ADDRESSED (verified): Both hosts' native/plan/fresh exact shared JSON and free producer controls pass source/null/defined/empty/false/zero/copy/default/pipeline/numeric/function families, false retention/generic/bridges/scalar guards, malformed no-effects and1!/SC/one-call/final-null snapshot.
  - [x] NO REGRESSION: Direct String fixture and loadfile compilation pass on PUC5.5.1/LuaJIT alongside shared/producer checks. No whole suite, malformed native regex case, declared5.4 or full-domain/portable claim; native crash2.3 remains owned.
  - [x] LOCKSTEP: Named runner include, contract/book/guide and canonical Lua fact/map align with task/live/resume. Book/history/diff and final staged memory/cadence/diagnosis pass; String comparison assessment23.2.11 next after clean commit. Full admission/canonical Perl registration23.4.1 remain separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.11.5 - continue Lua definedness receiver results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.12`
  Status: `active` / bounded explicit String comparison counterparts planned
  Goal: Ordinary receiver/result counterparts for six str_* helpers under string-comparison-results.md; preserve actual producer and lexical domains.
  Children: `.23.3.12.1`, `.23.3.12.2`, `.23.3.12.3`, `.23.3.12.4`, `.23.3.12.5`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.12.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary str_eq/str_ne/str_gt/str_ge/str_lt/str_le receivers and compatible result handoff.
  Dependencies: .23.2.11.
  Acceptance: Frozen string-comparison-results.md through public native/generated routes; preserve actual producer kinds, existing null/scalar/Unicode/empty/source/copy domains and correct source/operand/result snapshots. One operand before effects, all six true/false pairs, source families/false retention/generic/bridges/scalar guards; small compile/direct checks/docs/commit. Numeric aliases, deferred/callable/full admission and declared Lua5.4 remain separate.

  Activation: clean `789dc307a8bd6706a68038bb4aea8d4703ea3ddf`; assessment committed, brief empty/tree clean; post-commit pointer passed; identity derived from Git.
  Owned paths: Existing Perl six String comparison receiver/result/shape registrations and any newly confirmed bounded operand-lowering gap; shared native/fresh fixture, distinguishing zero-text producer control, direct definedness compatibility and current docs.
  Verification tier: `focused`
  Focused checks: Public free zero-text literal/binding control before classification; native/fresh six-method shared RED/GREEN with actual1/0/null compatibility and SOC snapshots, direct definedness fixture, source/test syntax/book/history/diff and final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored values/order and producer-preservation controls, no quantified population or portable measurement.

  Completion: Add six str_* names to existing one-operand and scalar-result String receiver lists only. Existing numeric1/0 producers, lexical/undef-as-empty behavior and correct eager snapshots remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public free literal/bound zero-text control gives[1,1,1!] and substitution preserves quoted0 versus $zero_text. New shared native/fresh fixture RED has raw receiver/handler compile failures before counterparts; no producer repair is inferred.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering String return-family and one-operand lists omit six free-only bridge names. Existing str_* branch captures lhs/rhs into temporaries and returns1/0 with lexical operators; source/operand/order already correct.
  - [x] FIX: Two registration/preflight lines enable ordinary counterparts and current-value scalar/generic/bridge continuation; keep numeric aliases and existing producers/domains/source/copy semantics.
  - [x] ADDRESSED (verified): Native/fresh exact shared Perl JSON passes all six true/false pairs and raw numeric flags, null/empty/zero literal-binding twins, named/selected/pipeline/Hash/split/function/default/join sources, retained0!/generic/bridges/scalar guards,12 malformed no-effects and1!/SOC/once-only/final-null snapshot. Null-source operand control remains0!/SO.
  - [x] NO REGRESSION: Direct native/fresh definedness fixture passes;12 assertions across two focused fixtures. Source/test syntax pass. Undef comparisons retain enabled legacy uninitialized warnings; no suppression/domain change or portable-null claim. No full suite/global scalar-slot audit.
  - [x] LOCKSTEP: Contract/shared source/Perl expected/test, six true/false worked receiver examples, canonical fact/map and task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis pass; Rust2 independent assessment next. New Perl canonical selection remains mandatory23.4.1; residual Dart mode assessment23.2.12 follows all five counterparts.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.12.1 - add Perl explicit String comparison receivers`.

  Additional live-doc defect / fix now: Catalog String summary439/441 still calls the four already-implemented predicate continuations outside scope/terminal, and Array summary669 still calls is_empty/is_nonempty terminal. These contradict23.3.9/.10/.11 implementations and their individual entries. Reconcile these exact summary lines and the formal grammar's explicit comparison-name paragraph with current scoped support; remove the unassessed membership-terminal generalization and give contains result assessment an explicit pending leaf23.2.13. No new runtime/contains behavior is claimed.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.12.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary str_eq/str_ne/str_gt/str_ge/str_lt/str_le receivers and compatible result handoff.
  Dependencies: .23.3.12.1.
  Acceptance: Frozen string-comparison-results.md through public native/generated routes; preserve actual producer kinds, existing null/scalar/Unicode/empty/source/copy domains and correct source/operand/result snapshots. One operand before effects, all six true/false pairs, source families/false retention/generic/bridges/scalar guards; small compile/direct checks/docs/commit. Numeric aliases, deferred/callable/full admission and declared Lua5.4 remain separate.

  Activation: clean `e227e9e8199527dc358e81c588c49afe210a5ef3`; Perl committed, brief empty/tree clean; post-commit pointer passed; identity derived from Git.
  Owned paths: Confirmed Rust ordinary six explicit String comparison receiver/result/shape gaps; public existing producer kind/null/text/order control, shared native/restored/plan regression and direct definedness compatibility, current docs.
  Verification tier: `focused`
  Focused checks: Public native free producer first, native/restored/generated-plan shared RED/GREEN with actual backend expectations, direct definedness fixture, targeted offline Cargo compilation/rustfmt and book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/portable23.4, mandatory Perl registration23.4.1 and final clean push separate.
  Claim verification: none: deterministic authored preservation/regression values/order, no quantified population or portable measurement.

  Public existing producer / preservation: Native free control returns12 Boolean flags (sixtrue/sixfalse), five true null/empty/zero twins, null-resultfalse with SO order and false/default texts0!/0!. engine.rs existing str_* branch compares evaluated to_str() values and returns RuntimeValue::Bool. Keep this Bool/null/text behavior; shared Boolean expected variant differs from Perl only at raw flags. No producer or undefined-domain normalization is inferred.

  Shared baseline: Native producer control passes; receiver values are null beside six nested1!, rawBool flags correct, and24 malformed effects execute. Existing source/operand/result blocks already run1/1 calls in SOC order with final source null; null-source block orderSO also works. Register six names in String result-family, scalar-producer and one-operand preflight lists; no producer/snapshot repair or numeric alias change.

  Completion: Add six names to existing String-result/scalar-producer/one-operand lists. Existing Bool producers, to_str lexical/null compatibility, zero/false/default and correct source/operand/result snapshots remain unchanged; no parser/schema/numeric alias change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native free control confirms twelve Bool flags, null/empty/zero true twins, null-resultfalse/SO and false/default0!/0!. Shared receiver RED gives null beside nested1!, rawBool correct,24 malformed effects; existing1/1 source/operand calls and SOC/final-null already work.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs String result-family, scalar-result and one-operand lists omit six explicit comparison names. Existing helper branch compares evaluated to_str operands and returns RuntimeValue::Bool; no producer or snapshot defect inferred.
  - [x] FIX: Extend only the three method lists, using existing selected/dynamic consumer dispatch and scalar guards. Preserve literal/text/null/Unicode/source/copy domains and numeric aliases; no Bool-number normalization.
  - [x] ADDRESSED (verified): Native/restored/generated-plan exact Boolean shared JSON passes six true/false/raw-kind pairs, null/empty/zero twins, source families, retained0!/generic/bridges/scalar guards, twelve malformed no-effects and1!/SOC/once-only/final-null; null-source operand remains0!/SO. Free producer control stays passing.
  - [x] NO REGRESSION: Direct definedness result/producer fixtures pass; four targeted Rust tests with offline compilation/rustfmt. No broad suite/standalone emitted/full-domain/portable claim or Core/schema change.
  - [x] LOCKSTEP: Shared Boolean expected/test, contract/book/guide/formal grammar and canonical comparison fact/map align with task/live/resume. Predicate-arity prose is scoped to the above admitted families. Book/history/diff/final staged memory/cadence/diagnosis pass; Dart3 next after clean commit. Residual modes23.2.12/full admission/Perl registration23.4.1 remain separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.12.2 - add Rust explicit String comparison receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.12.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary str_eq/str_ne/str_gt/str_ge/str_lt/str_le receivers and compatible result handoff.
  Dependencies: .23.3.12.2.
  Acceptance: Frozen string-comparison-results.md through public native/generated routes; preserve actual producer kinds, existing null/scalar/Unicode/empty/source/copy domains and correct source/operand/result snapshots. One operand before effects, all six true/false pairs, source families/false retention/generic/bridges/scalar guards; small compile/direct checks/docs/commit. Numeric aliases, deferred/callable/full admission and declared Lua5.4 remain separate.

  Activation: clean `a9f7b0bb766934ba25fe0c4cc106d5df2486fe7d`; Rust committed, brief0/tree clean; identity derived from Git.
  Owned paths: Dart six explicit comparison receiver shape/scalar guards, independently assessed producer/null kinds, shared native/restored/plan regression and direct definedness compatibility/docs. Existing UTF-16 ordering stays scheduled under DART-STARTUP-READING.2.13; its unresolved portable consumer contract is outside this preservation slice.
  Verification tier: `focused`
  Focused checks: Public free producer control and shared native/restored/plan RED/GREEN, direct definedness fixture, selected-file fatal analysis/formatting, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full admission23.4 and final clean push separate.
  Claim verification: none: deterministic authored regression and preservation controls, no population or portable completeness measurement.

  Completion: Add six names only to existing one-operand preflight and scalar-producer lists. Existing Bool producers and null-propagating comparison remain unchanged. No Unicode ordering, numeric alias, parser/schema or snapshot change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public free producer control passes native/restored/plan with twelve Bool flags, null comparison results, empty/zero true twins, false/default0!/0! and eager SO. Shared RED has incompatible/after_text empty Arrays and24 malformed effects; other six pairs/source families and1!/SOC/once-only/final-null already work.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart ActionFluentChainExpr one-operand preflight and _evaluateFluentCallsWithValue mayProduceScalar omit six comparison names. _callStringCompareHelper already returns Bool for scalar operands and null for absent operands; preserve its domains. Known UTF-16 order remains DART2.13, not closed here.
  - [x] FIX: Extend only the two lists; add explicit Dart null-propagating golden variant based on observed public producer behavior, retaining Boolean identity.
  - [x] ADDRESSED (verified): Shared native/restored/generated-plan passes all six true/false pairs, raw kinds, empty/zero/null boundaries, source families, false/generic/bridges/scalar guards, twelve malformed no-effects,1!/SOC/source and operand once/final-null; null source remains null/SO.
  - [x] NO REGRESSION: Direct definedness result/producer checks pass; four focused Dart tests and selected-file fatal analysis/formatting pass. No broad suite, fresh emitted, full-domain or portable-null claim.
  - [x] LOCKSTEP: Current contract/shared Dart expected/test, catalog/guide/formal grammar, canonical fact/map and live/resume align. Correct stale Receiver-Dot summary of the already-implemented four String predicates to all five recorded hosts. Book/history/diff/final staged memory/cadence/diagnosis checked before commit; Julia4 follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.12.3 - guard Dart String comparison result receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.12.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary str_eq/str_ne/str_gt/str_ge/str_lt/str_le receivers and compatible result handoff.
  Dependencies: .23.3.12.3.
  Acceptance: Frozen string-comparison-results.md through public native/generated routes; preserve actual producer kinds, existing null/scalar/Unicode/empty/source/copy domains and correct source/operand/result snapshots. One operand before effects, all six true/false pairs, source families/false retention/generic/bridges/scalar guards; small compile/direct checks/docs/commit. Numeric aliases, deferred/callable/full admission and declared Lua5.4 remain separate.

  Activation: clean `d103e63ccf2dd9c3f3309bc37c3f5ad40ff3a991`; Dart committed/brief0/tree clean.
  Owned paths: Julia ordinary comparison shape/scalar guards, independently assessed actual producer kinds/null semantics, shared native/plan/fresh producer/result fixture and direct definedness/docs.
  Verification tier: `focused`
  Focused checks: Public free producer control first; shared native/plan/fresh RED/GREEN with explicit Bool identity, direct definedness, strict depwarn compilation, book/history/diff/final staged continuity checks.
  Canonical trigger: None for bounded ordinary implementation under director feature-first cadence; complete domain/portable admission23.4/final clean push separate.
  Claim verification: none: deterministic authored preservation/regression controls, no quantified population/portable measurement.

  Completion: Extend two existing one-operand/scalar-producer lists only. Producer Bool/null/zero/text behavior and snapshots stay unchanged; reuse the independently confirmed null-propagating expected variant, renamed .null.json with Dart consumer updated.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/plan/fresh free producers pass with12 Bool flags, null boundaries/null-result, empty/zero true twins, false/default0!/0! and eager SO. All three shared routes RED with incompatible/after_text empty Arrays and24 malformed effects;1!/SOC/once-only/final-null snapshots already work.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _evaluate_runtime_fluent_chain! omits six names from exactly-one-operand and may_produce_scalar lists. Existing _call_runtime_string_comparison returns Bool for defined scalar operands and nothing for null. Julia == alone accepts numeric lookalikes; raw flag assertions additionally require isa Bool.
  - [x] FIX: Add six names to the two guards; preserve producer/domain/numeric aliases and correct source/result capture. Register fixture in runtests.jl; no parser/schema change.
  - [x] ADDRESSED (verified): Native/generated-plan/fresh emitted exact shared case passes six pairs/raw kinds, source families, null/empty/zero, retained0!/generic/bridge/scalar guards, twelve malformed no-effects and1!/SOC/once-only/final-null; null source remains null/SO.
  - [x] NO REGRESSION: Twelve comparison and nine direct definedness assertions pass with strict depwarn compilation. Dart two comparison tests pass after shared expected rename. No broad suite/full-domain/portable admission claim.
  - [x] LOCKSTEP: Shared null expected/test/registration, contract, six worked book examples/support qualifiers, canonical fact/map and task/live/resume align; book/history/diff/final staged memory/cadence/diagnosis checked before commit. Lua5 follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.12.4 - guard Julia String comparison result receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.12.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary str_eq/str_ne/str_gt/str_ge/str_lt/str_le receivers and compatible result handoff.
  Dependencies: .23.3.12.4.
  Acceptance: Frozen string-comparison-results.md through public native/generated routes; preserve actual producer kinds, existing null/scalar/Unicode/empty/source/copy domains and correct source/operand/result snapshots. One operand before effects, all six true/false pairs, source families/false retention/generic/bridges/scalar guards; small compile/direct checks/docs/commit. Numeric aliases, deferred/callable/full admission and declared Lua5.4 remain separate.

  Activation: clean `71047c4791dddd79877a9c658fb161a4166e749c`; Julia committed, brief0/tree clean.
  Owned paths: Lua ordinary comparison terminal/scalar/shape dispatch, actual producer kind/null controls, shared native/plan/fresh and direct definedness fixtures/registration/docs. Known malformed native patterns remain excluded under LUA-STARTUP-READING.2.3; measured PUC5.5.1/LuaJIT do not establish declared5.4.
  Verification tier: `focused`
  Focused checks: Public free producer then shared native/plan/fresh RED/GREEN and direct definedness on both available hosts, source load checks, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded ordinary implementation under director feature-first cadence; full admission23.4/declared5.4/final clean push separate.
  Claim verification: none: deterministic authored preservation/regression controls, no population or portable completeness measurement.

  Completion: Remove the obsolete comparison-only terminal fence, mark its actual result scalar and include six names through existing is_string_comparison in one-operand preflight. Preserve Bool/null/zero/text producers, lexical domains and eager source/operand capture.
  Verification:
  - [x] REPRODUCE / ISSUE: Public free producer controls pass native/plan/fresh on PUC5.5.1/LuaJIT with twelve Bool flags, null propagation, empty/zero true twins, false/default0!/0! and SO. Shared RED yields terminal nulls beside nested1!,24 malformed effects and SO/sourcezzz because the fence suppresses consumer C.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua evaluate_fluent_calls rejects continued is_string_comparison, omits it from scalar producers; evaluate_expr fluent preflight omits its one-operand rule. Existing producer retains lexical Bool/null behavior; no source snapshot defect inferred from suppressed continuation.
  - [x] FIX: Remove the fence, reuse is_string_comparison in scalar/preflight guards and register a separate named fixture. No producer/parser/schema/numeric-alias change.
  - [x] ADDRESSED (verified): Native/plan/fresh exact .null.json passes on both hosts: six true/false/raw-Bool pairs, source families, null/empty/zero, retained0!/generic/bridge/scalar guards, twelve malformed no-effects and1!/SOC/once-only/final-null; null-source remains null/SO.
  - [x] NO REGRESSION: Direct definedness producer/result fixtures pass on both hosts; loadfile checks interpreter and named runner syntax. No known malformed native pattern executed; declared5.4/full-domain/portable admission remains separate.
  - [x] LOCKSTEP: Contract/book six examples/support and actual kind/null qualifications, canonical comparison fact/map and task/live/resume align. Qualify obsolete July Lua76/76 closeout as historical, preserving exact old record in Git; it is not current completeness or frontier. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Residual Dart mode assessment23.2.12 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.12.5 - continue Lua String comparison result receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.13`
  Status: `active` / bounded contains rollout; full admission23.4 separate
  Goal: Ordinary contains receiver/result handoff and coordinated required-needle guards under contains-results.md and FUTURE-PARITY-BACKLOG.5.6.
  Children: `.23.3.13.1`, `.23.3.13.2`, `.23.3.13.3`, `.23.3.13.4`, `.23.3.13.5`.
  Acceptance: Independently preserve actual producer kinds/equality/null/empty/source snapshots; implement compatible scalar/generic/explicit-container flow and one authored needle before effects. Normalize old four-backend missing-needle0 only under activated original owner5.6; update named punctuation-light tests and preserve both zero-argument twins. No free helper/equality/full-domain/deferred/portable admission inference.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.13.1`
  Status: `completed`
  Goal: Independently assess and implement Perl ordinary Array contains result handoff and required-needle guards.
  Dependencies: .23.2.13; coordinate original arity owner FUTURE-PARITY-BACKLOG.5.6.
  Acceptance: Frozen contains-results.md through public native/generated routes; actual kinds/equality/null/empty/source/eager snapshots unchanged. Hit/miss/false-retention/generic/bridge/scalar guards, source families and missing/extra no-effects, with both bare/parenthesized zero-arg aliases; update actual named calibration expectation after normalization. Small compile/direct checks/docs/commit; full domains/free signatures/portable admission and Lua declared5.4 remain separate.
  Immediate defect: Malformed contains nested in an Array currently emits raw items.contains() and fails an undefined host subroutine on native/fresh; eliminate this fallthrough with guard before effects. Valid free/nested/named source snapshots already work.

  Activation: clean `299a3f67a30b991aa07b1d38922d8582a321146d`; contains assessment/explicit FUTURE5.6 activation committed, brief0/tree clean.
  Owned paths: Perl contains ordinary result/scalar/shape routing and nested malformed host-call leak, shared native/fresh fixture and direct comparison compatibility/docs; producer/equality/snapshot semantics preserved.
  Verification tier: `focused`
  Focused checks: Public shared native/fresh RED/GREEN with existing producer values, direct String comparison fixture, source/test syntax and book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; complete domains/portable23.4 and mandatory Perl fixture selection23.4.1 separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Completion: Add contains only to global exactly-one-operand preflight and Array scalar-result return-family map. Existing numeric1/0 membership/equality/null/empty/zero/source snapshots remain unchanged. Global guard also removes malformed nested host-call/complex-block syntax fallthrough.
  Verification:
  - [x] REPRODUCE / ISSUE: Assessment public native/fresh producer/nested controls work while valid result chains lower undef. Shared RED produces native/fresh handler compilation errors from complex malformed bodies and raw contains fallthrough; no valid snapshot defect is inferred from wholly skipped receiver continuation.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering.pm global one-operand list and array_chain_return_family omit contains. The terminal classification rejects compatible later methods; malformed nested operands can fall through source text rather than a complete null expression. Existing free producer captures source before needle and computes before consumer.
  - [x] FIX: Extend only the two lists, using existing dynamic scalar/result dispatch and preflight. No producer/parser/schema/equality/free-arity change. Required receiver policy follows activated FUTURE5.6; Perl direct baseline already rejected missing/extra.
  - [x] ADDRESSED (verified): Native/fresh exact shared numeric JSON passes hit/miss/raw kinds, empty/null/zero, literal/named/selected/split/concat/Hash/function/default/copied Arrays, false retention/generic/bridge/scalar guards,1!/SOC/once-only/final-null. Missing bare/parenthesized and extra no-effects now work inside Arrays too, without host calls or compile failures.
  - [x] NO REGRESSION: Direct String comparison fixture passes;12 assertions/two files and source/test syntax pass. Existing enabled undef-comparison warnings remain. No broad suite/full domain/portable admission.
  - [x] LOCKSTEP: Shared source/Perl expected/test, contract/book/guide, canonical contains/arity facts/map and TYPE/FUTURE5.6/index/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Rust2 independent producer/calibration assessment next; new Perl fixture selection remains mandatory23.4.1.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.13.1 - continue Perl Array contains results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.13.2`
  Status: `completed`
  Goal: Independently assess and implement Rust ordinary Array contains result handoff and required-needle guards.
  Dependencies: .23.3.13.1; coordinate original arity owner FUTURE-PARITY-BACKLOG.5.6.
  Acceptance: Frozen contains-results.md through public native/generated routes; actual kinds/equality/null/empty/source/eager snapshots unchanged. Hit/miss/false-retention/generic/bridge/scalar guards, source families and missing/extra no-effects, with both bare/parenthesized zero-arg aliases; update actual named calibration expectation after normalization. Small compile/direct checks/docs/commit; full domains/free signatures/portable admission and Lua declared5.4 remain separate.

  Activation: clean `45d7c13869dd94cb54b3bdd58ef74e8f3c1944d5`; Perl committed, brief0/tree clean.
  Owned paths: Rust contains ordinary result/scalar/required-needle dispatch, independent public producer kind/equality/snapshot control, native/restored/plan shared and named punctuation-light calibration, direct comparison/docs. FUTURE5.6 explicitly authorizes missing0-to-null receiver normalization; no free/equality policy changes.
  Verification tier: `focused`
  Focused checks: Native public producer and shared RED/GREEN, native/restored/plan result/shape/source fixtures, exact named punctuation-light required-needle test, direct comparison, targeted offline Cargo compilation/rustfmt, book/history/diff/final staged continuity checks.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/equality/portable23.4/final push separate.
  Claim verification: none: deterministic authored preservation/regression controls, no population/completeness measurement.

  Newly confirmed producer defect / fix now: Public native producer raw flags are numeric[1,0,0,1,1,1,1,1,1] (null/empty membership merges unlike Perl); named items=[a], needle rebinds items=[z], returns0 instead of captured1/O/[z]. engine.rs contains calls array_consuming_arg after all arguments: that helper prefers current ctx binding over evaluated get_bare_value snapshot. Use the already-evaluated contains source only, preserving actual equality/kinds. Own source-null rebound control and native/restored/plan producer regression here. Other aggregate-consuming re-read seams and null/empty reference mismatch are assessed immediately after rollout by23.2.14, coordinated with original helper-caveat owner FUTURE5; no unexecuted sibling failure is claimed.

  Completion: Add contains to existing scalar-result/one-operand lists and consume its already-evaluated typed source in the producer instead of re-reading context after the needle. Preserve numeric1/0 and existing text equality/null-empty compatibility. Update named missing-needle calibration to null with identical bare/parenthesized results under FUTURE5.6.
  Verification:
  - [x] REPRODUCE / ISSUE: Native producer RED shows raw numeric[1,0,0,1,1,1,1,1,1], correct0!/default0!, but named source changed by needle returns0/O/[z] instead of captured1. Shared RED is terminal nulls beside nested1!, five malformed effects, missing twins0/0, stopped consumer SO/source[z]. No block-source snapshot defect is inferred from the stopped continuation.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs scalar/one-operand lists omit contains. Its producer calls array_consuming_arg, which replaces evaluated args[0] with a current named binding after needle evaluation; Expr::Variable already captured typed get_bare_value. Numeric text equality merges undef/empty; preserve it in this feature slice and own reference reconciliation23.2.14 immediately after rollout.
  - [x] FIX: Extend the two lists; contains consumes args.first() as Array and returns0 for other actual kinds, preserving the captured source/null rather than reading later bindings. Update actual named punctuation-light test from old0 to null; no AST/parser/schema/free-arity/equality changes.
  - [x] ADDRESSED (verified): Native/restored/generated-plan producer and shared .rust.json pass: actual raw kinds/null-empty compatibility, rebound Array snapshot1/O/[z], absent-source snapshot0/O/[a], hit/miss/source families, false/generic/bridge/scalar guards, missing/extra and both missing aliases null/no-effects,1!/SOC/once-only/final-null.
  - [x] NO REGRESSION: Two contains, two direct comparison tests and exact named punctuation-light resolution test pass (five focused Rust tests) with offline Cargo compilation/rustfmt. No broad suite, standalone emitted/full equality/domain/portable admission.
  - [x] LOCKSTEP: Shared Rust expected/producer/result test and calibration, contract/book/guide, canonical contains/arity facts/map and TYPE/FUTURE5.6/index/live/resume align; newP1 .23.2.14 owns actual null-empty reference mismatch and unassessed sibling re-read seams. Book/history/diff/final staged memory/cadence/diagnosis checked before commit; Dart3 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.13.2 - capture Rust contains sources and continue results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.13.3`
  Status: `completed`
  Goal: Independently assess and implement Dart ordinary Array contains result handoff and required-needle guards.
  Dependencies: .23.3.13.2; coordinate original arity owner FUTURE-PARITY-BACKLOG.5.6.
  Acceptance: Frozen contains-results.md through public native/generated routes; actual kinds/equality/null/empty/source/eager snapshots unchanged. Hit/miss/false-retention/generic/bridge/scalar guards, source families and missing/extra no-effects, with both bare/parenthesized zero-arg aliases; update actual named calibration expectation after normalization. Small compile/direct checks/docs/commit; full domains/free signatures/portable admission and Lua declared5.4 remain separate.

  Activation: clean `b29781fb5ac3afb0a4339b2d560a838525ccdf7a`; Rust committed, brief0/tree clean.
  Owned paths: Dart contains receiver/scalar/required-needle guards, independently observed actual producer kinds/null/equality/source snapshots, native/restored/plan shared/direct comparison and named punctuation-light calibration/docs. FUTURE5.6 explicitly authorizes missing0-to-null; equality reconciliation23.2.14 remains next after rollout.
  Verification tier: `focused`
  Focused checks: Public native/restored/plan producer and shared RED/GREEN, direct comparison, exact named punctuation-light required-needle test, selected-file fatal analysis/formatting, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; complete equality/domain/portable23.4/final push separate.
  Claim verification: none: deterministic authored preservation/regression controls, no population/completeness measurement.

  Completion: Add contains only to existing one-operand preflight and scalar-producer lists. Preserve numeric1/0, actual null/empty merging and already-correct named/source-null snapshots. Update exact named missing-needle calibration to null/no-effects with identical aliases under FUTURE5.6.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/restored/plan producer passes before code changes: numeric raw[1,0,0,1,1,1,1,1,1], named rebound1/O/[z], absent-source0/O/[a], false/default0!/0!. Shared RED has incompatible/after_text empty Arrays, five malformed effects and missing twins0/0; valid hit/miss/source families and1!/SOC/once-only/final-null already work.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart ActionFluentChainExpr exactly-one-operand and _evaluateFluentCallsWithValue mayProduceScalar lists omit contains. _callArrayContains already consumes the captured List and returns numeric flags; nullAsEmpty comparison matches Rust but differs from Perl. No Dart producer/snapshot repair needed; actual equality mismatch added to P1 assessment23.2.14.
  - [x] FIX: Extend two lists and update actual named punctuation-light expectation from0 to null, retaining identical bare/parenthesized behavior. Rename shared .rust.json to .text.json after independent Dart agreement; update Rust include and rerun its focused consumers. No parser/schema/free-signature/equality changes.
  - [x] ADDRESSED (verified): Native/restored/plan producer/shared pass numeric/raw/null/empty/zero, source families, false/generic/bridge/scalar guards, missing/extra and both missing aliases null/no-effects,1!/SOC/once-only/final-null.
  - [x] NO REGRESSION: Direct comparison and exact named alias checks pass (five Dart tests), selected-file fatal analysis/formatting pass; two Rust contains tests pass after shared expected rename. No broad suite/full-domain/portable admission.
  - [x] LOCKSTEP: Shared text expected/Dart producer/result test/calibration, contract/book/guide, current contains/arity/Dart array facts/map and TYPE/FUTURE5.6/index/live/resume align. Correct stale generic Dart fact calling already-implemented numeric reducers terminal. Book/history/diff/final staged memory/cadence/diagnosis checked before commit; Julia4 next with explicit numeric-kind guards.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.13.3 - guard Dart Array contains result receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.13.4`
  Status: `completed`
  Goal: Independently assess and implement Julia ordinary Array contains result handoff and required-needle guards.
  Dependencies: .23.3.13.3; coordinate original arity owner FUTURE-PARITY-BACKLOG.5.6.
  Acceptance: Frozen contains-results.md through public native/generated routes; actual kinds/equality/null/empty/source/eager snapshots unchanged. Hit/miss/false-retention/generic/bridge/scalar guards, source families and missing/extra no-effects, with both bare/parenthesized zero-arg aliases; update actual named calibration expectation after normalization. Small compile/direct checks/docs/commit; full domains/free signatures/portable admission and Lua declared5.4 remain separate.

  Activation: clean `10e1005299b9a3b24ecdc08870b3046bbd5a22cd`; Dart committed, brief0/tree clean.
  Owned paths: Julia contains scalar/required-needle receiver guards, independent producer numeric-kind/equality/source controls, native/plan/fresh shared and direct comparison/calibration/registration/docs. FUTURE5.6 explicitly authorizes missing0-to-null; P1 equality/sibling snapshots23.2.14 stays next after rollout.
  Verification tier: `focused`
  Focused checks: Public native/plan/fresh producer and shared RED/GREEN with explicit Number/not-Bool raw identity, direct comparison and small changed punctuation-light fixture, strict depwarn compilation, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full equality/domain/portable23.4/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Completion: Add contains only to existing one-operand and scalar-producer lists; update actual small punctuation-light calibration to null with identical aliases under FUTURE5.6. Preserve numeric1/0, actual null/empty text-key equality and already-correct source snapshots; no producer/parser/schema/free-signature change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/plan/fresh producer and explicit Number/not-Bool checks already pass: numeric raw[1,0,0,1,1,1,1,1,1], named rebound1/O/[z], absent-source0/O/[a], false/default0!/0!. Three shared REDs show incompatible/after_text empty Arrays, five malformed effects and missing twins0/0; valid source families and1!/SOC/once-only/final-null already work.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _evaluate_runtime_fluent_chain! omits contains from one-operand and may_produce_scalar lists. _call_runtime_array_contains already consumes captured values and returns numeric1/0; null_as_empty merges null/empty as Rust/Dart do. Julia == accepts Bool-number lookalikes, so raw result checks explicitly reject Bool.
  - [x] FIX: Extend two guard lists, register the new fixture and update the actual missing-needle calibration from0 to nothing; both spellings stay equal. Existing .text.json independently agrees with Julia. No source/equality normalization; actual null/empty reference mismatch joins P1 .23.2.14.
  - [x] ADDRESSED (verified): Native/generated-plan/fresh emitted producer/shared passes raw numeric identity/null/empty/zero, source families, false/generic/bridge/scalar guards, missing/extra and both missing aliases null/no-effects,1!/SOC/once-only/final-null.
  - [x] NO REGRESSION: Twelve membership and twelve direct comparison assertions plus55 in the small changed punctuation-light fixture pass with strict depwarn compilation. No full suite, broad equality/domain/portable admission.
  - [x] LOCKSTEP: Shared text expected/Julia test/registration/calibration, contract/book/guide, compact current contains/arity/Julia array facts/map and TYPE/FUTURE5.6/index/live/resume align. Correct stale generic Julia fact calling already-implemented numeric reducers terminal. Book/history/diff/final staged memory/cadence/diagnosis checked before commit; Lua5 next, excluding known malformed native regexes.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.13.4 - guard Julia Array contains result receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.13.5`
  Status: `completed`
  Goal: Independently assess and implement Lua ordinary Array contains result handoff and required-needle guards.
  Dependencies: .23.3.13.4; coordinate original arity owner FUTURE-PARITY-BACKLOG.5.6.
  Acceptance: Frozen contains-results.md through public native/generated routes; actual kinds/equality/null/empty/source/eager snapshots unchanged. Hit/miss/false-retention/generic/bridge/scalar guards, source families and missing/extra no-effects, with both bare/parenthesized zero-arg aliases; update actual named calibration expectation after normalization. Small compile/direct checks/docs/commit; full domains/free signatures/portable admission and Lua declared5.4 remain separate.

  Activation: clean `7bb011b4eea5129faf334a57c50871d695ffb92c`; Julia committed, brief0/tree clean.
  Owned paths: Lua ordinary contains scalar/required-needle dispatch, independently assessed producer kinds/equality/source captures, shared native/plan/fresh and direct comparison/named punctuation-light calibration/registration/docs. FUTURE5.6 authorizes missing0-to-null; available PUC5.5.1/LuaJIT only, declared5.4 remains LUA2.2. Known malformed native patterns stay excluded under LUA2.3.
  Verification tier: `focused`
  Focused checks: Public native/plan/fresh producer/shared RED/GREEN and direct comparison on both hosts, exact safe named punctuation-light calibration, source/runner load checks, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full equality/domain/portable23.4/declared5.4/final push separate.
  Claim verification: none: deterministic authored preservation/regression controls, no population/completeness measurement.

  Completion: Add contains only to existing Array scalar-producer and one-operand preflight lists; update the actual named punctuation-light missing expectation0->json.null and register a separate shared fixture. Existing numeric flags/text-key equality/source snapshots remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/plan/fresh free producers pass on both hosts before changes: numeric raw[1,0,0,1,1,1,1,1,1], rebound Array1/O/[z], absent-source0/O/[a], false/default0!/0!. Shared RED has incompatible/after_text empty Arrays, five malformed effects and missing twins0/0; valid source families and1!/SOC/once-only/final-null already work.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua evaluate_fluent_calls marks join/index scalars but omits contains; evaluate_expr preflight omits its one-needle rule. evaluate_array_helper already returns numeric1/0 from captured Array values and scalar_array_key null-as-empty text comparison. No producer/snapshot repair needed; confirmed Lua null/empty mismatch joins P1 .23.2.14.
  - [x] FIX: Extend only those two lists; named alias expectation now null under FUTURE5.6. Both terminal zero-argument spellings reject identically before effects. No producer/parser/schema/free-signature/equality change.
  - [x] ADDRESSED (verified): Native/plan/fresh exact .text.json passes on PUC5.5.1/LuaJIT: raw numeric/null/empty/zero, source families, retained false/generic/bridges/scalar guards, missing/extra and both missing aliases null/no-effects,1!/SOC/once-only/final-null.
  - [x] NO REGRESSION: Direct comparison producer/result fixtures and exact named punctuation-light contract pass on both hosts; source/runner load checks pass. Only the named safe contract is selected from run.lua; no malformed native pattern/full suite/declared5.4/full domain/portable admission executed or inferred.
  - [x] LOCKSTEP: Shared Lua fixture/registration/actual calibration, contract/book/guide, current contains/arity/Lua selection facts/map and TYPE/FUTURE5.6/index/live/resume align. Historical July93/93 is qualified and full unsafe reverify replaced by this safe changed surface; no historical version evidence reclassified as current. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. P1 .23.2.14 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.13.5 - guard Lua Array contains result receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14`
  Status: `active` / six bounded repairs targeted-checked; full admission23.4 separate
  Goal: Implement frozen aggregate-null-and-snapshot-contract.md under original helper-caveat owner FUTURE-PARITY-BACKLOG.5.7.
  Children: `.23.3.14.1`, `.23.3.14.2`, `.23.3.14.3`, `.23.3.14.4`, `.23.3.14.5`, `.23.3.14.6`.
  Acceptance: Cached pure aggregate value operands; eager Perl has_key key effects; null distinct from empty in contains/index_of/uniq, original kinds/first occurrence/source snapshots retained. Preserve existing defined-scalar coercion, malformed arity, invalid-kind fallback, target mutation and lazy controls; bounded per-backend commits/quick checks. Full domain/portable admission remains23.4.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14.1`
  Status: `completed`
  Goal: Repair Rust aggregate-consuming named-source snapshots.
  Dependencies: .23.2.14; original helper owner FUTURE-PARITY-BACKLOG.5.7.
  Intake: Rust source re-read is confirmed on all three carriers; contains already has a local fix. Mutation-target resolvers and lazy helpers stay untouched.
  Acceptance: Use cached typed get_bare_value arguments in array_consuming_arg/hash_consuming_arg; preserve existing named wrong-kind/absent empty-container fallback without reading later ctx bindings. Public native/restored/plan index/has_key/append/merge and literal/null/concat controls plus direct contains/index/has_key/uniform checks; no null equality change. Small compile/changed-surface/direct checks/docs/commit under feature-first cadence; complete domain/context/admission remains23.4.

  Activation: clean `97faac2f753201be9a7c13753a86ad4c86864951`; aggregate/null freeze and original FUTURE5.7 activation committed, brief0/tree clean.
  Owned paths: Rust private aggregate-consuming value adapters, public native/restored/plan named source/append/merge/null snapshot regression, named valid/missing/wrong-kind defaults and direct contains/index/has_key/uniform checks/docs. Preserve null-key merging until14.3 and all target/lazy resolvers.
  Verification tier: `focused`
  Focused checks: Retained public source/native/restored/plan RED/GREEN plus named fallback controls, direct contains/index/has_key tests and one typed-constructor uniform control, offline compilation/rustfmt, book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded existing value-contract repair under director feature-first cadence; complete domains/context/portable23.4 separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Baseline compatibility control: Initial empty-Array expectation for flat_hash(wrong/undef) was incorrect; actual pre-change output is empty Hash{}. Pin that observed shape instead, without normalizing its existing context-sensitive/invalid-domain behavior owned by FUTURE5. Main snapshot RED independently distinguishes stale sources; the fallback control guards against widening this fix into raw-kind normalization.

  Completion: Replace live ctx reads in the two aggregate value adapters with already-evaluated typed arguments. Named wrong-kind/absent inputs still yield the prior empty Array/Hash fallback, preserving flat_hash’s observed empty Hash{} compatibility; nonvariable/literal inputs stay unchanged. Target/lazy resolvers and null-key equality untouched.
  Verification:
  - [x] REPRODUCE / ISSUE: Retained public probes and snapshot fixture RED on native/restored/plan: named index null instead of0, has_key0 instead of1, appended index1 instead ofnull, merge{z,b} instead of{a,b}, absent source result replaced by later binding. Concat control already works. Fallback baseline control passes separately before production after correcting an unproved Array[] expectation to actual Hash{}.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs array_consuming_arg/hash_consuming_arg prefer current ctx named storage after all operands, replacing cached args. runtime.rs get_bare_value already captures typed Array/Hash clones. Preserve the old raw-variable wrong-kind empty fallback but never inspect later bindings; other mutation-target and lazy protocols use separate resolvers.
  - [x] FIX: Both adapters return captured typed arguments, with only the prior named non-container fallback synthesized as empty. Keep call signatures/private context parameter unused, avoiding unrelated caller edits. No parser/schema/free signature/equality/target changes.
  - [x] ADDRESSED (verified): Native/restored/plan exact expected source controls now return index0/has_key1, absent indexnull/has_key0 despite later rebinding, appended indexnull and merged{a,b}; source mutations remain visible in separate after fields. Literal/concat/null controls and named first/last/copy/sorted/default/flat_hash shapes pass. Existing null/empty merging is intentionally unchanged for14.3.
  - [x] NO REGRESSION: Two snapshot/fallback tests, two direct contains, one index, one has_key and one retained typed-constructor uniform control pass (seven focused Rust tests), offline compilation/rustfmt. No full suite/standalone emitted/full domain/portable admission.
  - [x] LOCKSTEP: Retained source/shared Rust expected/test, current book free index/has_key/merge examples, canonical source/null fact/map and TYPE/FUTURE5.7/index/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit; Perl key14.2 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.14.1 - preserve captured Rust aggregate operands`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14.2`
  Status: `completed`
  Goal: Evaluate Perl has_key key after captured null sources.
  Dependencies: .23.3.14.1; original helper owner FUTURE-PARITY-BACKLOG.5.7.
  Intake: Public dump shows typed and legacy key expression nested inside defined(hash), suppressing valid key effects on a null source; result remains0 while key mutations must run once.
  Acceptance: Move key evaluation before source-validity ternary in typed/legacy ordinary lowering, preserving source snapshot/output kinds/domain/warnings and one-key guard. Native/fresh source-null/effect/valid source/malformed and direct has_key/contains checks. Small compile/changed-surface/direct checks/docs/commit under feature-first cadence; complete domain/context/admission remains23.4.

  Activation: clean `03ceddd1f251f41a1de9bc82d3f6b71fc027e39a`; Rust cached-source repair committed, brief0/tree clean.
  Owned paths: Perl typed/legacy has_key value lowering key temporaries, public native/fresh source-null/absent/effect/valid source/shape fixture and direct has_key/contains checks/docs. Source/output kinds/free arity and key domain remain unchanged.
  Verification tier: `focused`
  Focused checks: Public Get/substitution/dump source-null RED/GREEN, shared native/fresh key ordering/once-only/source/result snapshot fixture, direct has_key/contains fixtures, source/test syntax and book/history/diff/final staged continuity guards.
  Canonical trigger: None for bounded existing ordinary evaluation-contract repair under director feature-first cadence; complete contexts/domains/portable23.4 separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Completion: In typed and legacy conditional has_key value builders, capture source then key in separate lexical temporaries before defined(source)/exists. Null-source output stays numeric0, with key effects no longer suppressed. Key expressions remain untouched and evaluated once; no source/key domain/coercion/arity change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public dump located key in the defined(hash) ternary. After correcting a new fixture filename setup error (not semantic RED), native/fresh regression genuinely fails key effects: free/literal/missing calls stay0, source bindings remainnull, receiver orderSC/keycalls0. Valid/empty source controls and malformed guards already pass.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering.pm typed4501/4511 and legacy6840/6863 emit key inside exists on the true branch of defined(source). The existing source-then-key ordinary value contract requires key evaluation before this presence decision, including null/missing sources.
  - [x] FIX: Add one key temporary to each conditional builder and use that value in exists; source captured first, presence tested last. No try/catch or key rewriting, so actual operand behavior is retained. Existing named direct-hash branch already evaluates key and is unchanged.
  - [x] ADDRESSED (verified): Native/fresh exact expected passes free/literal/absent/null-source key once and binding effects, receiver0!/SKC/source1/key1, valid captured-source1/SK and empty-source0 despite later binding creation. Missing/extra receiver calls remain null with zero effects.
  - [x] NO REGRESSION: Direct has_key and contains fixtures pass;18 assertions across three focused files, source/test syntax pass. Both builders are updated; no claim of exhaustive independent legacy-route, exception, full-domain or portable admission.
  - [x] LOCKSTEP: New source/expected/test, frozen contract/current book example and canonical source/null fact/map align with TYPE/FUTURE5.7/index/live/resume. Book/history/diff/final staged memory/cadence/diagnosis checked before commit; Rust null-key14.3 next. Mandatory Perl fixture registration23.4.1 remains open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.14.2 - evaluate Perl has_key keys before source guards`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14.3`
  Status: `completed`
  Goal: Distinguish Rust null Array comparison and uniqueness keys.
  Dependencies: .23.3.14.2; original helper owner FUTURE-PARITY-BACKLOG.5.7.
  Intake: Public membership/index/uniq null-empty reference mismatch is confirmed; raw numeric flags and first value/kind/order stay unchanged.
  Acceptance: Preserve defined to_str conversion, but null matches only null in contains/index_of and has its own uniq key. Native/restored/plan literals/variables/receivers/nested consumers and existing contains expected updates; source adapters from1 stay correct. Small compile/changed-surface/direct checks/docs/commit under feature-first cadence; complete domain/context/admission remains23.4.

  Activation: clean `d90c6d5634a39a1affd174d56ca156b21186395d`; Perl key evaluation committed, brief0/tree clean.
  Owned paths: Rust private null-distinct Array keys for contains/index_of/uniq, retained reference native/fresh producer and native/restored/plan primitive/position/value/receiver/standalone/inter-type regressions, intentional current contains/snapshot expected updates/docs. Existing defined to_str/free-default/arity/source/value-kind semantics stay unchanged.
  Verification tier: `focused`
  Focused checks: Public Perl reference native/fresh and Rust native/restored/plan RED/GREEN, direct contains/index/snapshot fixtures, offline compilation/rustfmt and book/history/diff/final staged continuity guards. No broad equality/full suite.
  Canonical trigger: None for bounded existing reference-contract repair under director feature-first cadence; complete source/domain/context/portable23.4 separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Completion: Add private collision-free Option<String> Array key projection: Undef=None, every defined value retains Some(to_str). Use it only in contains/index_of/uniq, preserving raw numeric flags, index/null outputs, first original value/kind/order and standalone writeback. Missing free needles retain the old empty-text default branch; receiver arity/source adapters unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: New shared fixture passes six Perl native/fresh reference assertions. Rust RED merges null/empty, picks index0 where1 is correct, drops empty in value/receiver/standalone uniq, returns1!/numeric3/fallback1/count3 instead of0!/2/8/4. Input values, last numeric value and NC/one-needle control already work.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs contains/index_of compare to_str and uniq inserts to_str keys, making Undef and empty text indistinguishable. A typed internal absent key separates null from every String without changing public RuntimeValue or any defined conversion.
  - [x] FIX: Add array_scalar_key and use projected keys in three helpers; keep absent free-helper legacy matching explicit. Update current contains producer/shared expected to Perl reference and snapshot expected membership/index/uniq fields, intentionally replacing the old null-merging expectations. No global to_str/parser/schema/arity/source/target changes.
  - [x] ADDRESSED (verified): Native/restored/plan shared null keys pass mixed positions, empty/missing/defined number-string and bool controls, raw kinds/first values/source nonmutation, value/receiver/standalone uniq, false retention, numeric result2, absent/found index consumers8/2, count4/last4 and NC/one needle. Contains and aggregate snapshot consumers now agree with the selected reference; captured sources/fallbacks remain passing.
  - [x] NO REGRESSION: Six focused Rust tests across null/contains/index/snapshot fixtures with offline compilation/rustfmt, plus six independent Perl reference assertions and source/test syntax pass. No full suite, general strict/container/callable equality, free-signature normalization or portable admission.
  - [x] LOCKSTEP: Shared reference source/expected/test and Rust consumer updates, frozen contract/current scoped book examples, canonical contains/source-null facts/map and TYPE/FUTURE5.7/index/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Dart14.4 independent index/uniq assessment next; new Perl reference fixture selection remains mandatory23.4.1.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.14.3 - distinguish Rust null Array comparison keys`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14.4`
  Status: `completed`
  Goal: Distinguish Dart null Array comparison and uniqueness keys.
  Dependencies: .23.3.14.3; original helper owner FUTURE-PARITY-BACKLOG.5.7.
  Intake: Contains null/empty merging confirmed; index/uniq still require public controls. No new producer defect inferred before assessment.
  Acceptance: Independently assess index/uniq against public Perl authority, preserve defined conversions, implement null-only matching/own uniq key and current contains fixture expectations. Native/restored/plan and direct small checks/fatal analysis. Small compile/changed-surface/direct checks/docs/commit under feature-first cadence; complete domain/context/admission remains23.4.

  Activation: clean `2fedae957ba9a5e6765a2d7780976bf5c768b218`; Rust null-key child committed, brief0/tree clean.
  Owned paths: Dart contains/index_of/uniq null-distinct keys, shared-reference and defined-conversion preservation tests, current contains expected updates and synchronized book/facts/task/live docs.
  Verification tier: `focused`
  Focused checks: Native/restored/plan RED/GREEN, direct contains/index/standalone transforms, fatal analysis/format and book/history/staged continuity guards.
  Canonical trigger: None for this bounded reference-contract repair under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions and preservation controls; no population/completeness measurement.

  Completion: A private const Object token distinguishes actual null from every defined String key and unsupported/nonfinite projection. contains/index_of retain each defined scalar projection; uniq keeps its existing fallback-to-empty projection, copied first values/kinds and source order. No user String can collide with the token.
  Verification:
  - [x] REPRODUCE / ISSUE: Dart native shared-reference RED shows merged membership, wrong index0, lost empty uniq entries, 1!/numeric3/default1/count3. Null versus defined-container projection RED is[1,1,0,0,[[]]] instead of[0,0,null,null,[[],null]]. Independent defined conversion/free-missing controls already pass native/restored/plan.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart _callArrayContains/_callIndexOf compare _scalarString(nullAsEmpty:true), while _callUniq stores that projection with empty fallback. Null, empty and defined containers all project to empty. Actual-null token separation fixes only the selected reference defect without redefining defined-container or numeric/Bool comparisons.
  - [x] FIX: Private _arrayScalarKey token projection used in three helpers; preserve defined conversion and uniqueness fallback, result kinds, copied values, source capture and free defaults. Existing contains raw/shared expected intentionally switches from old text merging to selected Perl reference. No parser/schema/arity/global conversion changes.
  - [x] ADDRESSED (verified): Three new native/restored/plan tests pass shared positions/null/empty/number-string/Bool controls, value/receiver/standalone uniq, original source/kinds/order, numeric/default/count/last/text consumers and NC/one needle. Null stays distinct from defined-container projections; old defined-only comparison/uniq/free-default controls stay passing.
  - [x] NO REGRESSION: Nine tests across null keys/direct contains/index/standalone transforms pass with compilation, format and fatal analysis of changed runtime/tests. No exhaustive suite, strict equality policy or full context/portable admission.
  - [x] LOCKSTEP: Shared reference/current contains selection, scoped catalog examples, aggregate contract and contains/source-null facts/map, TYPE/FUTURE5.7/index/live/resume align; book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia14.5 follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.14.4 - distinguish Dart null Array comparison keys`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14.5`
  Status: `completed`
  Goal: Distinguish Julia null Array comparison and uniqueness keys.
  Dependencies: .23.3.14.4; original helper owner FUTURE-PARITY-BACKLOG.5.7.
  Intake: Contains null/empty merging confirmed; index/uniq still require public controls. Preserve copied values and current source effects.
  Acceptance: Independently assess index/uniq, preserve defined conversions, implement null-only matching/own uniq key and current contains expectations with explicit Number/not-Bool guards. Native/plan/fresh strict small checks. Small compile/changed-surface/direct checks/docs/commit under feature-first cadence; complete domain/context/admission remains23.4.

  Activation: clean `167ce311bad3f497bd500c775a401cc7cc2517eb`; Dart null child committed, brief0/tree clean.
  Owned paths: Julia null-distinct contains/index_of/uniq keys, retained native/plan/fresh shared and defined-projection controls, fixture registration, current contains expected and book/facts/task/live docs.
  Verification tier: `focused`
  Focused checks: Public native/plan/fresh RED/GREEN with explicit Number/not-Bool guards, direct contains/index/standalone transforms, strict compilation and book/history/staged continuity guards.
  Canonical trigger: None for bounded reference-contract repair under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Completion: Private (actual-null tag, prior scalar text) keys distinguish null without changing defined projections. contains/index_of compare tagged keys; uniq keeps its old empty fallback in a typed (Bool,String) key and preserves copied first values/kinds/order. No user String sentinel can collide.
  Verification:
  - [x] REPRODUCE / ISSUE: Public Julia native/plan/fresh RED returns merged membership, index0 instead of1, lost empty values in all uniq forms, 1!/numeric3/default1/count3. Null/container projection RED[1,1,0,0,[[]]] versus[0,0,null,null,[[],null]]. Defined-only/free-missing control passes before production changes. RED also exposed a test length-assumption error after lost entries; guard that assertion so it reports shape safely.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _call_runtime_array_contains/index_of compare _runtime_scalar_string(null_as_empty=true); uniq inserts the same projection with empty fallback into Set{String}. The actual-null tag separates null while retaining every defined key and uniqueness fallback.
  - [x] FIX: Add private tuple projection; compare it in two helpers, use typed tagged String keys in uniq. Intentionally select Perl reference in current contains producer/shared expected. Register the new retained fixture in runtests.jl. No parser/schema/global conversion/arity/source or free-default change.
  - [x] ADDRESSED (verified):36 new native/plan/fresh assertions pass shared positions/null/empty/number-string/Bool controls, value/receiver/standalone uniq, original source/kinds/order, numeric/default/count/last/text consumers and NC/one needle. Explicit Number/not-Bool guards reject Boolean lookalikes; null stays separate from defined containers while their old projection remains.
  - [x] NO REGRESSION:63 strict focused assertions across null keys/direct contains/index/standalone transforms pass with package precompilation and depwarn=error. No full suite, general equality or complete domain/context/portable admission.
  - [x] LOCKSTEP: Shared/current reference selection, catalog examples, aggregate contract and contains/source-null facts/map, TYPE/FUTURE5.7/index/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Lua14.6 safe named PUC/JIT fixtures follow; declared5.4 admission stays separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.14.5 - distinguish Julia null Array comparison keys`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.14.6`
  Status: `completed`
  Goal: Distinguish Lua null Array comparison and uniqueness keys.
  Dependencies: .23.3.14.5; original helper owner FUTURE-PARITY-BACKLOG.5.7.
  Intake: Contains null/empty merging confirmed; index/uniq still require controls. Known malformed native patterns remain excluded; declared5.4/full admission separate.
  Acceptance: Independently assess index/uniq, preserve defined conversions, implement null-only matching/own uniq key and current contains expectations. Native/plan/fresh/direct checks on PUC5.5.1/LuaJIT, safe named fixtures only. Small compile/changed-surface/direct checks/docs/commit under feature-first cadence; complete domain/context/admission remains23.4.

  Activation: clean `e49ecee4bb0d7f4304f549930514cda1c315ace3`; Julia null child committed, brief0/tree clean.
  Owned paths: Lua null-distinct scalar_array_key helper, shared/native-plan-fresh and defined-projection/free-default controls, safe fixture registration/current contains expected and synchronized book/facts/task/live docs.
  Verification tier: `focused`
  Focused checks: Independent safe public native/plan/fresh RED/GREEN and direct contains/index on available PUC5.5.1/LuaJIT, source/runner load checks and book/history/staged continuity guards.
  Canonical trigger: None for bounded reference-contract repair under director feature-first cadence; malformed native patterns excluded, declared5.4/full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls; no population/completeness measurement.

  Completion: scalar_array_key returns the existing json.null token for actual null before the unchanged defined scalar-to-text/fallback conversion. Its shared contains/index_of/uniq consumers now distinguish null without a String marker collision; output kinds/first copied values/order/free defaults stay unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent public PUC5.5.1/LuaJIT native RED confirms mixed null/empty membership, wrong index0, lost empty in value/receiver/standalone uniq, 1!/numeric3/default1/count3. Null-container RED[1,1,0,0,[[]]] versus[0,0,null,null,[[],null]]. Defined-only/free-default controls pass all three routes before production.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua scalar_array_key unconditionally uses scalar_string(value,true) or empty; json.null, empty and defined containers collapse. The existing opaque null token is a safe table key distinct from every defined String projection.
  - [x] FIX: One null guard in the shared key helper; retain the entire defined conversion/fallback branch and all three existing callers. Intentionally select reference raw/shared contains expectations and register safe new fixture in run.lua. No parser/schema/global conversion/arity/source/free-default changes.
  - [x] ADDRESSED (verified): Shared/native-plan-fresh null reference and null-versus-container checks pass on both hosts after RED; numeric/raw JSON kinds, mixed positions, value/receiver/standalone uniq, copied first values/order/nonmutation, numeric/default/count/last/text consumers and NC/one needle hold. Defined-only/container-projection/free-missing controls stay passing.
  - [x] NO REGRESSION: Direct contains/index fixtures and interpreter/runner load checks pass on both hosts. Only safe named fixtures run; no malformed native pattern/full suite/declared5.4 or complete domain/portable admission.
  - [x] LOCKSTEP: Shared/current reference selection, new fixture/registration, scoped catalog/current contract progress, source-null/contains/Lua-selection facts/map and TYPE/FUTURE5.7/index/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Six bounded repairs targeted-checked; next numeric-comparison result assessment23.2.15 is scheduled without presuming a defect or changing its prior intentional terminal policy yet.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.14.6 - distinguish Lua null Array comparison keys`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.15`
  Status: `active` / all five comparison result implementations targeted-checked; full admission separate
  Goal: Extend existing six short numeric comparison methods with actual numeric/null result continuations.
  Dependencies: .23.2.15 frozen numeric-comparison-results.md.
  Children: `.23.3.15.1`, `.23.3.15.2`, `.23.3.15.3`, `.23.3.15.4`, `.23.3.15.5`.
  Acceptance: Independently preserve scalar-numeric-v1 producers, strict domains, one-RHS preflight, once-only source/RHS/consumer order and numeric/null scalar boundaries, compatible defaults/generic/String/explicit-container bridges. Small changed-surface/direct checks/docs/commit per backend; full domain/context/portable admission23.4 separate.

  Follow-up: Rust String-prefix numeric comparison dispatch is independently repaired/tested with arithmetic16.2; existing numeric producer/domain policy is preserved.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.15.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary numeric comparison result continuations.
  Dependencies: .23.2.15.
  Acceptance: Follow numeric-comparison-results.md for six short eq/ne/gt/ge/lt/le methods, preserve actual contracted numeric1/0/invalid-null and scalar numeric domains/free signatures. Native/generated producer-first RED/GREEN, six pairs, source families, strict invalid/default/generic/numeric/String/Array transitions, shape-before-effects and captured SOC controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `26454b71bbcd1e5bff5fcb457a7759531bc161de`; numeric result freeze committed, brief0/tree clean.
  Owned paths: Perl ordinary numeric comparison result-family handoff, retained shared native/fresh result/type/shape/effect/selector fixture, intentional ordinary AST/Phase0/codeblock-outer expected updates and direct focused selectors, synchronized book/facts/task/live docs. Deferred callback vocabulary remains unchanged.
  Verification tier: `focused`
  Focused checks: Shared public native/fresh RED/GREEN, actual touched AST/Phase0 named cases and changed outer numeric-codeblock rows plus deferred preservation control; direct comparison, syntax/compile and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary result implementation under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored results and preservation controls; no population/completeness measurement.

  Implementation seams owned here: Initial result-family-only change makes ordinary numeric/text/default consumers work but exposes two frozen bridge gaps. Public generated handler retains score.eq(2).cat(...).split(...).last().uppercase() (compile error at .eq): Number loop cannot consume the actual Array after explicit split. Actual outside/cat-prefix-gt-tail fixture retains read().cat(...).gt(...), failing handler compile: String loop lacks the existing short numeric-comparison handoff. Add only the missing scoped actual-kind dispatches; retain deferred terminal policy and unsupported-tail no-effects.

  Completion: Classify six short numeric comparisons as scalar_result and preserve existing strict numeric helper mapping/one-RHS preflight. Number chains now hand actual explicit split Arrays to the shared Array dispatcher; String prefixes can hand six existing numeric comparison methods to shared scalar dispatch. Producers and deferred runtime remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared native/fresh RED returns raw/nested/invalid producers correctly but every continued comparison null, effects skipped/source2. Selector-kind control already works. Initial family-only repair exposes public generated-handler raw bridge .eq and outside/cat-prefix .gt compile residue; own both frozen transition gaps in this leaf, without blessing null/compile errors.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering _number_receiver_value_chain_return_family marks comparisons terminal. Public dump shows score.eq(...).cat(...).split(...).last().uppercase() residue because Number loop lacks actual Array handoff; actual outer callback fixture read().cat(...).gt(...) remains raw because String loop lacks numeric comparison handoff. CodeblockRuntime has its own deliberate terminal preflight, retained unchanged.
  - [x] FIX: scalar_result comparison classification plus scoped shared Array dispatch in Number loop and six-comparison scalar dispatch from String loop. Intentionally update actual AST poisoned-node/Phase0 ordinary comparison calibration and seven ordinary outer numeric-codeblock expectations; keep deferred/unknown-tail expectations and source/value policies.
  - [x] ADDRESSED (verified): Shared native/fresh six true/false pairs, numeric1/0 and strict invalid-null/decimal controls, source families, false retention/default8/definedness/numeric consumers, repeated comparison, explicit String/Array bridgeX, scalar negatives, source1/operand1/SOC/final-null, invalid-source SOC/default8 and twelve malformed no-effects pass. Numeric flag still writes Array index1. Actual modified outer callable rows now produce0x/1x with one read, deferred and unknown-tail no-effects stay passing.
  - [x] NO REGRESSION:59 assertions across shared fixture and exact actual AST/Phase0 named cases plus changed outer rows/deferred preservation pass after bridge repair. Direct lexical comparison, changed source/test syntax pass as recorded; no whole Phase0/parser/numeric suites, deferred vocabulary expansion or full admission.
  - [x] LOCKSTEP: Shared source/expected/test and current calibration rows, frozen contract progress, scoped book/grammar examples and canonical number-chain fact/map, live/task/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Engineering hot-root reached59008/65536 bytes: normal rollover archived143 lines as segment4955, leaving199 lines/32488 bytes; immutable prior history untouched. New Perl fixture selection remains mandatory23.4.1. Rust15.2 independent producer/transition assessment follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.15.1 - continue Perl numeric comparison results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.15.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary numeric comparison result continuations.
  Dependencies: .23.3.15.1.
  Acceptance: Follow numeric-comparison-results.md for six short eq/ne/gt/ge/lt/le methods, preserve actual contracted numeric1/0/invalid-null and scalar numeric domains/free signatures. Native/generated producer-first RED/GREEN, six pairs, source families, strict invalid/default/generic/numeric/String/Array transitions, shape-before-effects and captured SOC controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `7e47de7413c0ce0c84f33628921dddbc6473522f`; Perl comparison result child committed, brief0/tree clean.
  Owned paths: Rust short comparison scalar-result/one-RHS dispatch and actual affected named number calibration, native/restored/plan producer/shared/selector regression, scoped book/facts/task/live docs. Numeric domains/free signatures and unrelated arithmetic guards stay unchanged.
  Verification tier: `focused`
  Focused checks: Producer-first native/restored/plan controls, shared RED/GREEN and direct String/aggregate result tests, exact touched number integration cases, offline compilation/rustfmt and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary result implementation under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Producer setup correction: First Rust control used -.5 as a bare literal (not a JSON number) beside valid numeric String"-.5". Public Engine warns unknown helper5/returns null; Core primary parser recognizes negative numeric literals only when minus is followed by a digit. Use canonical -0.5 literal in shared fixture/probe while retaining String"-.5" conversion control. This is a source spelling correction, not numeric producer RED credit or a new leading-dot literal contract. Reconfirm the producer before runtime edits.

  Completion: Rename the private comparison classifier to reflect its nonterminal role; classify six methods as scalar-result producers and hand Number-chain comparisons to shared actual-value continuation. Remove obsolete terminal state/fences, retaining numeric helper/arity/domain evaluation. Add exact-one-RHS global preflight before effects. Shared String/Array bridges already work through dynamic dispatch after handoff.
  Verification:
  - [x] REPRODUCE / ISSUE: After source spelling correction, independent native/restored/plan raw/canonical/word/symbol/strict-domain/nested/source producer and selector controls pass. Shared continuation RED returns null, SO/source3 instead of SOC/final-null, and twelve malformed effects. Initial -.5 bare literal setup is not numeric producer RED credit; use canonical -0.5 and keep String"-.5" control.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs dynamic Number helper and Number loop enforce comparison-terminal fences/state; is_scalar_result_receiver_method omits six comparisons. Common Expr::FluentChain preflight omits their one-RHS guard. Correct producers capture source and return numeric1/0/invalid-null; do not copy String-comparison Bool policy.
  - [x] FIX: Reuse comparison classifier in scalar result selection, shared selected-value continuation and one-RHS preflight; remove obsolete private Terminal state/dynamic fence. Intentionally update actual integration comparison calibration from[null,null] to[2,1]. Canonical literal spelling only changes shared source/probe, not expected values; Perl reference rechecks pass. No parser/schema/numeric-adapter/free signature or unrelated arithmetic change.
  - [x] ADDRESSED (verified): Native/restored/plan shared six pairs/Number flags/strict domains, source families, false/default8/definedness/numeric/selector and repeated-comparison consumers, String/Array bridgesX and scalar negatives pass. Valid and invalid-source SOC/once-only/final snapshots and twelve malformed no-effects pass. Free aliases/producer controls stay correct.
  - [x] NO REGRESSION: Eight Rust tests across numeric producer/shared/selector, direct lexical/aggregate and two actual named number integration cases pass with offline compilation/rustfmt; twelve shared Perl reference assertions pass after literal spelling correction. No full suite, standalone emitted Rust, new leading-dot literal/strict equality or full domain/portable admission.
  - [x] LOCKSTEP: Retained Rust tests/current calibration/shared canonical literal, frozen contract progress, scoped book/catalog/grammar and canonical number-chain/deferred qualifier facts/map, TYPE/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Dart15.3 independent producer/continuation assessment next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.15.2 - continue Rust numeric comparison results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.15.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary numeric comparison result continuations.
  Dependencies: .23.3.15.2.
  Acceptance: Follow numeric-comparison-results.md for six short eq/ne/gt/ge/lt/le methods, preserve actual contracted numeric1/0/invalid-null and scalar numeric domains/free signatures. Native/generated producer-first RED/GREEN, six pairs, source families, strict invalid/default/generic/numeric/String/Array transitions, shape-before-effects and captured SOC controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `82635ca70466e0d475c31597c378a1bb2c7c2248`; Rust comparison result child committed, brief0/tree clean.
  Owned paths: Dart confirmed numeric comparison result/shape guard gaps, native/restored/plan producer/shared/selector tests and synchronized book/facts/task/live docs. Preserve numeric adapters/domains/free signatures/source behavior and existing aliases.
  Verification tier: `focused`
  Focused checks: Producer-first native/restored/plan controls and shared RED/GREEN, direct lexical/aggregate result checks, format/fatal analysis and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary result implementation under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls; no population/completeness measurement.

  Completion: Share a private six-name canonical numeric comparison set between one-RHS preflight and possible scalar-result classification. Existing dynamic result/alias/producer dispatch already works; guard boundaries by actual result and reject bad shapes before effects.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent native/restored/plan free canonical/word/symbol producers, strict numeric domains, nested SOC/source snapshot and numeric selector control pass before production. Shared native valid continuations/bridges/defaults/SOC already work; scalar incompatible/after-text results are[] and twelve bad shapes run24 effects instead of null/zero effects.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart common ActionFluentChainExpr preflight omits canonical num_eq/ne/gt/ge/lt/le; _evaluateFluentCallsWithValue mayProduceScalar omits them too. NumericCompare already returns numeric1/0/invalid-null with correct conversion; no producer or source defect inferred.
  - [x] FIX: Add private _numericComparisonHelperNames set used by both guards. Preserve every helper/alias conversion, shape-independent domain policy, raw kinds and current valid flows; no parser/schema/free signatures/arithmetic or calibration expectation change.
  - [x] ADDRESSED (verified): Native/restored/plan shared six pairs/raw Number flags/strict invalid/decimal inputs, source families, false/default8/generic/numeric/selector and repeated-comparison consumers, String/Array bridgesX and scalar negatives pass. Valid/invalid-source SOC/once-only/final snapshots stay correct; twelve malformed no-effects now pass.
  - [x] NO REGRESSION: Six tests across new numeric producer/shared/selector and direct lexical/aggregate result fixtures pass with compilation/format/fatal selected-file analysis. No full suite, new canonical method surface or complete domain/context/portable admission.
  - [x] LOCKSTEP: New retained shared-reference consumer, frozen contract progress, scoped guide/catalog/grammar and canonical number/Dart numeric facts/map, TYPE/live/resume align. Relevant Dart fact compacts the prior full generic guard record behind exact Git pointer; no budget increase or unrelated cleanup. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia15.4 independent assessment next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.15.3 - guard Dart numeric comparison result flow`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.15.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary numeric comparison result continuations.
  Dependencies: .23.3.15.3.
  Acceptance: Follow numeric-comparison-results.md for six short eq/ne/gt/ge/lt/le methods, preserve actual contracted numeric1/0/invalid-null and scalar numeric domains/free signatures. Native/generated producer-first RED/GREEN, six pairs, source families, strict invalid/default/generic/numeric/String/Array transitions, shape-before-effects and captured SOC controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `03f0036a8093e87db4af7c82ef6518448c9d9ee7`; Dart comparison guard child committed, brief0/tree clean.
  Owned paths: Julia confirmed numeric comparison result/shape gaps, native/plan/fresh producer/shared/selector tests with Number/not-Bool guards and fixture registration, synchronized scoped book/facts/task/live docs. Preserve numeric adapters/domains/free signatures and source/alias behavior.
  Verification tier: `focused`
  Focused checks: Independent producer-first native/plan/fresh RED/GREEN with raw numeric identity guards, direct lexical/aggregate result tests, strict compilation and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary result implementation under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls; no population/completeness measurement.

  Completion: Add canonical num_eq/ne/gt/ge/lt/le to common exact-one-RHS and possible scalar-result lists. Existing numeric producer/alias/dynamic continuation already works; actual container outputs still release scalar guarding.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent native/plan/fresh canonical/word/symbol and strict numeric-domain producers, raw Number/not-Bool flags/aliases, nested SOC and selector kinds pass before production. Three shared route REDs preserve all valid continuation/default/bridge/SOC results but expose incompatible/after-text[] and24 malformed effects.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _evaluate_runtime_fluent_chain! common one-operand and may_produce_scalar tuples omit canonical numeric comparisons. Existing numeric helper returns numeric1/0/invalid-nothing; shared helper implementation alone does not establish fluent shape/result guards.
  - [x] FIX: Two scoped tuple additions plus retained regression/runner registration. Preserve all helper conversions/aliases/free signatures/source evaluation and existing actual-kind dispatch; no parser/schema/arithmetic or calibration expectation changes.
  - [x] ADDRESSED (verified):27 new strict native/plan/fresh assertions pass six pairs/raw kinds/decimal and invalid inputs, source families, false/default8/generic/numeric/selector/repeated comparisons, String/Array bridgeX, scalar negatives and valid/invalid-source SOC/once-only/final snapshots. Explicit Number/not-Bool guards reject false passing from Julia ==; twelve malformed shapes now run zero effects.
  - [x] NO REGRESSION:42 focused assertions across numeric/direct lexical/aggregate result fixtures and strict package precompilation pass. No whole suite, arithmetic/domain expansion or complete context/portable admission.
  - [x] LOCKSTEP: New retained consumer/registration, frozen contract progress, scoped guide/catalog/grammar and canonical number/Julia numeric facts/map, TYPE/live/resume align. Qualify prior overly broad cannot-drift wording: helper reuse does not replace receiver guards; compact historical guard detail behind exact prior Git record. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Safe Lua15.5 independent assessment next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.15.4 - guard Julia numeric comparison result flow`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.15.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary numeric comparison result continuations.
  Dependencies: .23.3.15.4.
  Acceptance: Follow numeric-comparison-results.md for six short eq/ne/gt/ge/lt/le methods, preserve actual contracted numeric1/0/invalid-null and scalar numeric domains/free signatures. Native/generated producer-first RED/GREEN, six pairs, source families, strict invalid/default/generic/numeric/String/Array transitions, shape-before-effects and captured SOC controls. Small compile/direct checks/docs/commit; full admission separate. Lua available PUC5.5.1/LuaJIT safe named fixtures only; declared5.4 and malformed native patterns remain separately owned.

  Activation: clean `564157d106c526a7a3c6062744381ffc821cb2c5`; Julia comparison guard child committed, brief0/tree clean.
  Owned paths: Lua confirmed comparison scalar-result/one-RHS gaps, native/plan/fresh producer/shared/selector tests and safe registration, actual named numeric calibration expectation update, scoped book/facts/task/live docs. Numeric adapter/domains/free signatures stay unchanged; malformed native patterns excluded.
  Verification tier: `focused`
  Focused checks: Independent public producer-first native/plan/fresh RED/GREEN and direct lexical/aggregate fixtures, exact affected named numeric calibration/source loads on PUC5.5.1/LuaJIT, book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; declared5.4/full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Replace the numeric-comparison terminal fence with scalar-result marking and reuse scalar_numeric.is_comparison in common one-RHS preflight. Existing dynamic dispatcher now consumes actual numeric/null results through text/default/generic/numeric and explicit container bridges; producer/equality/adapter policy stays unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent PUC5.5.1/LuaJIT native/plan/fresh canonical/word/symbol/strict-domain numeric producers, nested SOC/false/default/bridge controls pass before production. Shared native RED stops every continuation at null/SO/source3 and runs24 malformed effects; correct raw numeric and incompatible scalar controls already hold.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua evaluate_fluent_calls returns json.null immediately after any nonfinal scalar_numeric comparison, and common fluent preflight omits its RHS guard. scalar_numeric evaluator already returns numeric1/0/invalid-null; actual source captures work, so do not infer a source or producer defect.
  - [x] FIX: Mark numeric comparison result scalar instead of stopping, add existing is_comparison classifier to one-RHS preflight, register retained fixture. Intentionally update six actual named numeric terminal_* expected values fromnull to2; stable historical field names retained. No parser/schema/numeric adapter/free signatures/arithmetic changes.
  - [x] ADDRESSED (verified): Strict canonical JSON/native-plan-fresh shared six pairs/raw numeric kinds/decimal and invalid inputs, source families, false/default8/generic/numeric/selector/repeated comparisons, String/Array bridgeX and scalar negatives pass on both hosts. Valid/invalid-source SOC/once-only/final snapshots and twelve malformed no-effects pass. Actual old numeric calibration now admits all six comparison arithmetic results2 while free alias/arithmetic controls stay green.
  - [x] NO REGRESSION: Direct lexical/aggregate fixtures, exact affected named numeric calibration and interpreter/runner load checks pass on both hosts. Only safe named operations selected; reviewed valid regex AST parsing in that calibration invokes no malformed native pattern. No full runner, declared5.4 or complete domain/portable admission.
  - [x] LOCKSTEP: New retained consumer/registration/current calibration, frozen contract/all-five bounded progress, scoped guide/catalog/grammar/Lua handoff and canonical number/Lua numeric facts/map, TYPE/live/resume align. Old unsafe full-runner reverify replaced by safe current public fixture, dated July gate retained via exact Git pointer. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Next scalar arithmetic result assessment23.2.16 is scheduled from the same helper spine, preserving overload/domain authority before code.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.15.5 - continue Lua numeric comparison results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.16`
  Status: `active` / all bounded arithmetic backends targeted-checked; full admission separate
  Goal: Extend ordinary scalar numeric arithmetic results into compatible scalar/text/generic/explicit-container continuations.
  Dependencies: .23.2.16 frozen scalar-arithmetic-results.md.
  Children: `.23.3.16.1`, `.23.3.16.2`, `.23.3.16.3`, `.23.3.16.4`, `.23.3.16.5`.
  Acceptance: Preserve scalar-numeric-v1 producer/input/arity rules and actual Number/null kinds, one-time source/operand/result snapshots, scalar/Array min/max overloads, current free/deferred boundaries and Array reducer defects. Independent backend small changed-surface/direct checks/docs/commit; full admission23.4 separate.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.16.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary scalar arithmetic result continuations.
  Dependencies: .23.2.16.
  Acceptance: Follow scalar-arithmetic-results.md for twelve existing short Number methods, preserving raw Number/null/strict domains/free signatures/overload policies. Public producer-first/native-generated RED/GREEN, source families, zero/invalid/default/generic/scalar boundaries, numeric->text->Array->String bridges, lazy actual-container defaults and captured SOC/arity controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `846a39094d1f0f1972169fc089098df43aad47d2`; scalar arithmetic result freeze committed, brief0/tree clean.
  Owned paths: Perl ordinary arithmetic scalar-result classification/String-prefix handoff, retained shared/native/fresh twelve-method/source/kind/shape/default/bridge/overload regression and selector control, scoped book/facts/task/live docs. Numeric adapters/free signatures/scalar-Array min-max/deferred/reducer95 policies stay unchanged.
  Verification tier: `focused`
  Focused checks: Public native/fresh shared RED/GREEN plus direct numeric comparison and actual named arithmetic AST/Phase0 cases, source/test syntax and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary result implementation under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  In-flight owned bridge defect: Initial arithmetic scalar classification/String-prefix handoff passes every shared field except invalid numeric -> explicit Hash default -> sorted_values -> first -> uppercase, which is null instead of A on native/fresh. Array defaults/copy, numeric snapshots/overloads/shapes and direct comparison/actual arithmetic calibrations pass. Keep the Hash expectation; investigate with public substitution/Get/dump and distinguishing default-source controls before any further repair.

  Hash bridge root/ownership: Public Get/substitution/dumps show numeric-root, canonical-call-root and direct undef.coalesce Hash projection all become unsupported-helper:first/null, while fully nested equivalent yields A. Once-bound default guards contain emitted host do expressions; later Array consumers reparse those as DSL. Repair the Array composition seam via the existing compatibility bridge only for already-emitted do sources, preserving the dedicated sorted/reversed path and authored syntax checks. Original default-selection62 / TYPE23.3.6 remain authoritative; this direct dependent repair/regression is owned here and fixes their confirmed projection-successor gap too.

  Completion: All existing short Number methods yield scalar_result for compatible actual-value continuation; String prefixes hand existing numeric methods to that same dispatcher. Numeric adapters, overload rules and shape preflight stay unchanged. Also repair confirmed existing default Hash-view successor staging: Array call composition uses the existing compatibility bridge when its source already contains emitted host do code, keeping the dedicated sorted/reversed path. No authored syntax or unsupported-AST fallback is widened.
  Verification:
  - [x] REPRODUCE / ISSUE: New shared native/fresh RED fails handler compile on raw arithmetic-to-text/default chains, while raw selector controls already work. Family/prefix change makes every field pass except Hash default sorted_values->first->uppercase. Independent numeric/call/direct-default public Get/substitution/dumps return unsupported-helper:first/null versus nested A; retained focused default projection fixture RED confirms the old staging defect.
  - [x] ROOT CAUSE (WHY + WHERE): Number return-family metadata and String-prefix numeric dispatch prevent compatible arithmetic flow. The separate Hash-view bug is append_array_chain_call constructing DSL over an already emitted default guard do expression; later typed lowering reparses host output and emits first's unsupported sentinel. Existing legacy composition flag is the established bridge for generated host expressions, not an invitation to parse authored retired syntax.
  - [x] FIX: Scalar arithmetic return family and existing Number-method handoff, plus local Array-call finishing through the compatibility bridge only for do-expression sources. Preserve sort/reverse's existing runtime route, all numeric/Array/default producers and free/deferred/overload policies. Add shared arithmetic and direct default-projection native/fresh regressions and numeric selector control; no public method/parser/schema changes.
  - [x] ADDRESSED (verified): Twelve arithmetic methods and variadic forms retain numeric/text results, strict invalid/rounding/modulo cases, all source families, zero retention/skipped fallback, numeric/default8/generic/comparison consumers, String/Array/Hash defaults, copied chosen Array and bridgeX. Valid/invalid-source SOC/once-only and ASO min/max overloads hold; fourteen bad shapes run zero effects. Numeric add/scalar min outputs remain Array indexes. Default Hash projections now support first/last/count/join/contains/index, sum/transform/reverse/take successors, multiple root families, numeric index kinds and SDC/once-only/source snapshots.
  - [x] NO REGRESSION:29 current focused assertions across arithmetic/projection/existing selected/literal default fixtures pass; the literal suite still rejects authored fat-arrow Hash syntax. Extended projection smoke and two actual AST/Phase0 numeric named cases pass, source/test syntax clean. Direct numeric comparison12 assertions already pass after arithmetic classification; final projection tests cover its affected Hash-root path. No whole suites, Array reducer95/deferred expansion or portable admission.
  - [x] LOCKSTEP: Shared and default-projection source/expected/tests, frozen contract/old default-family follow-up, current worked book examples and canonical Number/default facts/map plus live/task/resume align. Normal gate registration of both new Perl files remains mandatory23.4.1. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Rust16.2 independently assesses its producers and transitions next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.16.1 - continue Perl scalar arithmetic results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.16.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary scalar arithmetic result continuations.
  Dependencies: .23.3.16.1.
  Acceptance: Follow scalar-arithmetic-results.md for twelve existing short Number methods, preserving raw Number/null/strict domains/free signatures/overload policies. Public producer-first/native-generated RED/GREEN, source families, zero/invalid/default/generic/scalar boundaries, numeric->text->Array->String bridges, lazy actual-container defaults and captured SOC/arity controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `1d77f481bbe2222effd36bb946438a2d41093b37`; Perl arithmetic/default-projection slice committed, brief0/tree clean.
  Owned paths: Rust confirmed arithmetic result/shape dispatch gaps, native/restored/plan canonical/alias/strict-domain/shared/selector regression, scoped book/facts/task/live docs. Numeric adapters/free signatures/min-max overload/source/reducer policies stay unchanged.
  Verification tier: `focused`
  Focused checks: Producer-first native/restored/plan RED/GREEN and direct numeric comparison/aggregate/default fixtures, actual named number integration cases, offline compilation/rustfmt and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; complete domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Remaining prefix seam: Initial shared numeric result dispatch/shape repair passes every shared field except String trim->add, still null. Public Engine result and eval_string_receiver_value_chain show String loop validates its own whitelist before numeric result handoff; add focused arithmetic/comparison/invalid prefix controls and hand existing Number methods to shared dispatch before evaluating consumer operands. This also owns the same existing numeric-comparison prefix gap, without changing its producer/domain policy.

  Completion: Classify existing Number methods as scalar-result producers and use shared actual-value dispatch for Number chains, removing duplicate Number-only evaluation. String prefixes hand existing Number methods to that dispatcher too. Extend common unambiguous arity preflight for unary/sub/div/mod/clamp/add/mul; min/max zero-extra Array and scalar variadic modes remain untouched.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent native/restored/plan canonical/word/symbol arithmetic producers, strict invalid/null/decimal controls, nested5!/SOC and numeric add/scalar-min selector controls pass before production. Shared RED stops ten literal arithmetic text/default/bridge flows, leaves SO/source9 and runs14 malformed effects. min/max text/variadic and selected/call/count/reducer sources already work; preserve them.
  - [x] ROOT CAUSE (WHY + WHERE): engine.rs Number loop only accepts Number links, while scalar-result classification misses most arithmetic methods. Common fluent preflight lacks their shape checks. Initial shared dispatch repair fixes every field except String trim->add; String loop checks its whitelist before numeric handoff. Direct prefix RED independently returns[null,null,null] versus[5!,1!,8], covering existing numeric-comparison prefix too.
  - [x] FIX: Shared Number-method scalar classification and Number-chain dispatch, scoped String-family numeric handoff before consumer-argument evaluation, and reference-matching unambiguous shape guards. Remove obsolete duplicate Number-loop helper/argument construction. Numeric adapters/free signatures/parser/schema/min-max/reducer/deferred vocabulary stay unchanged; no old expectations require normalization.
  - [x] ADDRESSED (verified): Native/restored/plan shared twelve/variadic/domain/source/zero/default/copy/Array/Hash/bridge/selector/generic/comparison cases pass. Valid/invalid-source SOC, ASO overloads and fourteen malformed no-effects hold. Extra String prefix arithmetic/comparison/invalid-default controls now give5!/1!/8; existing source captures and numeric kinds remain.
  - [x] NO REGRESSION: Eleven Rust tests across four new numeric producer/shared/selector/prefix cases, direct comparison/aggregate/default fixtures and two actual named number integration cases pass with offline compilation/rustfmt. No whole suite, standalone emitted Rust, numeric domain/free signature or full portable admission claim.
  - [x] LOCKSTEP: New retained shared-reference/prefix consumer, frozen contract progress and comparison follow-up, current catalog/guide examples and canonical Number fact/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Dart16.3 independent producer/continuation assessment next; Perl host-staging repair remains separately evidenced.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.16.2 - continue Rust scalar arithmetic results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.16.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary scalar arithmetic result continuations.
  Dependencies: .23.3.16.2.
  Acceptance: Follow scalar-arithmetic-results.md for twelve existing short Number methods, preserving raw Number/null/strict domains/free signatures/overload policies. Public producer-first/native-generated RED/GREEN, source families, zero/invalid/default/generic/scalar boundaries, numeric->text->Array->String bridges, lazy actual-container defaults and captured SOC/arity controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `392b181b5865c5e424a85d8a863d3243bce5073b`; Rust arithmetic committed, brief0/tree clean.
  Owned paths: Dart independently confirmed arithmetic scalar/shape gaps, retained native/restored/plan producer/shared/selector/prefix controls, scoped book/facts/task/live docs. Preserve numeric adapters/free signatures/min-max modes and source/default snapshots.
  Verification tier: `focused`
  Focused checks: Producer-first public RED/GREEN and direct comparison/aggregate/default fixtures, format/fatal selected analysis and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Add canonical arithmetic scalar-result marking and common unambiguous unary/sub-div-mod/clamp/add-mul arity guards. Existing actual-value dispatcher already handles valid arithmetic/prefix/default/bridge flow; preserve numeric producers/free signatures/min-max modes.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent canonical/word/symbol producer, selector and String-prefix controls pass before production. Shared native RED has incompatible/after_text [] instead ofnull and28 malformed source/operand effects; valid twelve-method/variadic/source/default/bridge/SOC/ASO fields already pass.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart mayProduceScalar omits arithmetic methods, permitting scalar fallthrough into container helpers; common fluent preflight omits their unambiguous arities. Canonical numeric evaluator and captured source/default dispatch are already correct for this fixture.
  - [x] FIX: Add _numericArithmeticHelperNames to scalar marking and shape checks before source/operand evaluation. Leave min/max global shape handling unchanged for Array/scalar overloads. No new method/parser/schema/numeric adapter/free signature or domain normalization.
  - [x] ADDRESSED (verified): Four new native/restored/plan cases preserve raw twelve/alias/symbol kinds and strict invalid/rounding/modulo, text/variadic/source/numeric selector/prefix paths, zero/default/copy/Array/Hash/bridge/generic boundaries and SOC/ASO; fourteen malformed calls now have zero effects.
  - [x] NO REGRESSION: Eleven focused tests across arithmetic, numeric comparison, aggregate numeric and selected default fixtures pass. Format and fatal selected source/new-test analysis pass. No whole suite, large-magnitude repair or full portable admission claim.
  - [x] LOCKSTEP: Retained regression, frozen contract/current backend progress, worked catalog/guide and canonical Dart/Number facts/map plus live/task/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia16.4 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.16.3 - guard Dart scalar arithmetic results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.16.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary scalar arithmetic result continuations.
  Dependencies: .23.3.16.3.
  Acceptance: Follow scalar-arithmetic-results.md for twelve existing short Number methods, preserving raw Number/null/strict domains/free signatures/overload policies. Public producer-first/native-generated RED/GREEN, source families, zero/invalid/default/generic/scalar boundaries, numeric->text->Array->String bridges, lazy actual-container defaults and captured SOC/arity controls. Small compile/direct checks/docs/commit; full admission separate.

  Activation: clean `bec537d5b05ebfdd7750930bfb13ca1588a4da5e`; Dart arithmetic committed, brief0/tree clean.
  Owned paths: Julia confirmed arithmetic scalar/shape gaps, native/plan/fresh producer/shared/selector/prefix regression and runner registration, scoped book/facts/task/live docs. Preserve strict Number/not-Bool/null kinds and numeric/free/min-max/source/default policies.
  Verification tier: `focused`
  Focused checks: Independent producer-first RED/GREEN, direct comparison/aggregate/default tests with strict Number/not-Bool checks, compilation and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Extend common unambiguous arithmetic arity preflight and scalar marking tuples, reusing existing canonical actual-value dispatcher and unchanged numeric adapters/min-max modes. Retain/register strict native/plan/fresh producer/shared/selector/prefix regression.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent canonical/word/symbol/nested producer and selector/prefix cases pass before production. Shared RED has incompatible/after_text [] instead ofnull and28 source/operand effects; valid twelve/variadic/source/domain/default/bridge/SOC/ASO fields already hold on all three routes.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! omits arithmetic scalar marking and unambiguous common arity preflight. Canonical pure helper/actual-value source and default dispatch already satisfy retained valid controls; do not infer numeric producer defects.
  - [x] FIX: Add unary/sub-div-mod/clamp/add-mul guards and twelve arithmetic canonical names to scalar tuple; preserve min/max overload shape handling. No parser/schema/helper/domain/free signature changes. Register the new retained test in runtests.jl.
  - [x] ADDRESSED (verified): Thirty new assertions pass native/plan/fresh twelve/variadic/strict-domain/aliases/symbols/selector/prefix and shared source/zero/default/copy/actual Array-Hash/bridge/generic/comparison flow. Explicit Number && !Bool guards protect raw/alias/symbol/counter kinds. SOC/ASO and fourteen malformed zero-effects hold.
  - [x] NO REGRESSION:69 focused assertions across new arithmetic, direct numeric comparison, aggregate and selected-default tests pass with strict Julia compilation. No whole suite, known large-magnitude/slice repair or complete portable admission claim.
  - [x] LOCKSTEP: Retained test/runner, contract/current progress and book examples, compacted canonical Julia fact with exact prior Git history pointer and Number fact/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Safe Lua16.5 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.16.4 - guard Julia scalar arithmetic results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.16.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary scalar arithmetic result continuations.
  Dependencies: .23.3.16.4.
  Acceptance: Follow scalar-arithmetic-results.md for twelve existing short Number methods, preserving raw Number/null/strict domains/free signatures/overload policies. Public producer-first/native-generated RED/GREEN, source families, zero/invalid/default/generic/scalar boundaries, numeric->text->Array->String bridges, lazy actual-container defaults and captured SOC/arity controls. Small compile/direct checks/docs/commit; full admission separate. Safe PUC5.5.1/LuaJIT named fixtures only; malformed native patterns/declared5.4 remain separately owned.

  Activation: clean `a4385a108eac4c9c73e8b85c68f6710d52a3ba68`; Julia arithmetic committed, brief0/tree clean.
  Owned paths: Lua confirmed arithmetic scalar/shape gaps, native/plan/fresh producer/shared/selector/prefix regression and safe runner registration, scoped book/facts/task/live docs. Numeric adapters/free signatures/min-max modes/source/default snapshots remain unchanged.
  Verification tier: `focused`
  Focused checks: Producer-first public RED/GREEN on PUC5.5.1/LuaJIT, direct comparison/aggregate/default fixtures and actual affected safe numeric calibration, source loads and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; declared5.4/full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Mark all scalar_numeric fluent results scalar and extend common unambiguous unary/sub-div-mod/clamp/add-mul preflight. Reuse actual-value dispatcher, preserving min/max reducer/scalar modes and every numeric adapter/free signature. Register the safe retained producer/shared/selector/prefix fixture.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent PUC5.5.1/LuaJIT canonical/word/symbol/nested producers pass native/plan/fresh before production. Shared native RED exposes incompatible/after_text [] and28 malformed source/operand effects; valid arithmetic/source/default/copy/bridge/SOC/ASO already holds.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls marks only numeric comparisons scalar, leaving arithmetic fallthrough into container helpers; common fluent preflight lacks arithmetic shapes. Strict scalar_numeric evaluator and captured snapshots already satisfy valid controls.
  - [x] FIX: All scalar_numeric branch results set scalar_result=true; common unambiguous unary/binary/clamp/add-mul arity checks precede source/operand evaluation. min/max shape selection unchanged. Register new safe fixture; no parser/schema/numeric/domain/free signature changes.
  - [x] ADDRESSED (verified): Native/plan/fresh canonical JSON on both hosts distinguishes Number/Bool/String/null across producer aliases/symbols and twelve/variadic shared fields. Selector/prefix/default copy/actual Array-Hash/bridge/generic/comparison/source boundaries, SOC/ASO and fourteen malformed no-effects pass.
  - [x] NO REGRESSION: Both hosts pass direct numeric comparison/aggregate/default fixtures, exact affected safe named numeric calibration and interpreter/runner source loads. No full runner, malformed native regex, declared5.4 or complete portable admission claim.
  - [x] LOCKSTEP: Retained fixture/runner, frozen contract/all-five bounded progress and qualified catalog/guide, canonical Lua/Number facts/map plus live/task/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Next logical result assessment23.2.17 is owned before any new probe/change.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.16.5 - guard Lua scalar arithmetic results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17`
  Status: `active` / all bounded logical backends targeted-checked; full admission separate
  Goal: Complete bounded ordinary logical Boolean result continuation and clean scalar boundaries while retaining eager typed producer/error contracts.
  Dependencies: .23.2.17 frozen logical-results.md.
  Children: `.23.3.17.1`, `.23.3.17.2`, `.23.3.17.3`, `.23.3.17.4`, `.23.3.17.5`.
  Acceptance: Existing and/or/not free helper results remain actual Bool, typed truthiness/eager once-only operands unchanged. Compatible scalar/text/generic/default/explicit-container flow and source snapshots work; invalid logical source arity retains typed pre-effect errors. No new logical methods, numeric Bool coercion or full domain/context/portable admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17.1`
  Status: `completed` / primary implementation and rejection-effect follow-up17.1.1 verified
  Goal: Independently assess and implement/confirm Perl ordinary logical Boolean result continuations.
  Dependencies: .23.2.17.
  Acceptance: Follow logical-results.md, preserving actual Bool/strict numeric rejection, eager typed truthiness/source snapshots/free signatures, defaults/explicit Array-Hash bridges/scalar boundaries and pre-effect typed source arity errors. Public producer-first native/generated RED/GREEN and small direct checks/docs/commit; full admission separate.
  Owned confirmed defects: Logical-to-text-to-split staging unsupported cat; scalar-to-container raw DSL/accidental BindingRuntime error; unknown source operand scan suppressing not arity diagnostics. Repair immediately under this leaf, retaining direct/nested/effect source distinctions.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and small direct regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.


  Activation: clean `00fd9896e17386782689b2cdb6484f38820aad4b`; logical result freeze committed, brief0/tree clean.
  Owned paths: Perl logical-source typed scalar dispatch/bridge/scalar boundary and pre-effect source arity precedence, retained shared native/fresh logical result/error regression, scoped book/facts/task/live docs. Preserve existing logical/numeric/free/callback policies and emitted-host compatibility boundaries.
  Verification tier: `focused`
  Focused checks: Retained shared and typed source error RED/GREEN, direct logical/selected/default/arithmetic dependencies as warranted, syntax and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Validate malformed logical source arity before unknown-operand scanning. Materialize valid logical sources via the existing typed logical lowerer and scalar actual-result dispatcher; finish each composed helper through the established emitted-host compatibility bridge before a successor. Existing with/traversal normalization and all producer/free/numeric/typed truth policies stay unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: New native/fresh shared regression RED fails compound handler compile on raw and residue and misses the typed invalid-not/unknown-operand error. Independent retained intake already distinguishes unsupported cat bridge/null versus nestedX, source families/direct text/false/default/eager controls and accidental Array BindingRuntime error.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering chooses dispatch by first consumer before materializing the logical actual result; rebuilding later Array DSL loses typed source ownership. first_unknown_value_call_name also walks invalid source operands before typed logical arity checking. Numeric/truthiness and source snapshots are already correct; no producer or emitter repair inferred.
  - [x] FIX: Early malformed logical source arity validation, then a scoped logical-source loop reusing selected/Array/scalar families and existing compatibility finishing for already emitted logical host expressions. No broad raw fallback, new method, parser/schema/numeric/free signature or truth policy change.
  - [x] ADDRESSED (verified): Retained shared source/JSON/native/fresh regression passes six raw real-Bool/text/nested values, typed truthiness and named/selected/Hash/block/function/literal sources. All and/or/not split bridges giveX; Bool remains invalid numeric input with explicit8/ArrayB/HashA recovery, false default stays0!, incompatible scalar consumers are cleannull. Eager and/or LRC and not SC/calls/source snapshots hold. Five malformed source cases retain typed helper/arity/zero-evaluated fields, including unknown fail and known print operands.
  - [x] NO REGRESSION:26 current top-level checks across new12, direct logical8 and literal-default6 pass; source/new-test syntax clean. Existing logical with/typed sites/lazy contrast and default kinds remain. Additional new-route retired authored Hash-arrow assertion passes; no compatibility syntax widening or whole suite/portable admission.
  - [x] LOCKSTEP: Shared spec/expected/new test, frozen contract/current qualified catalog and canonical logical fact/map plus task/live/resume align. New Perl fixture registration remains mandatory23.4.1 before admission/push. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Independent Rust17.2 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.17.1 - continue Perl logical Boolean results`.
  Follow-up repaired: Rust17.2 intake exposed discarded source effects before incompatible rejection. Child17.1.1 now retains LR/LRC/S with the new rejected-effect regression; primary shared result fixture stays green.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17.1.1`
  Status: `completed`
  Priority: P1 immediate after clean Rust17.2, before Dart17.3.
  Goal: Preserve evaluated logical sources/prefix effects when a later incompatible container consumer rejects.
  Dependencies: Primary Perl17.1 implementation; finish/commit current Rust17.2 first.
  Reproduce: seen=0;bad=and({seen=num_add(seen,1);true}).sorted();return([bad,seen]) gives[null,0]; nested free sorted control gives[[],1]. Public substitution shows the new logical loop replaces the whole chain with undef when selected dispatch returns terminal, discarding the valid logical source. Source should execute once while incompatible consumer operands remain skipped; malformed-shape preflight policy unchanged.
  Root/impact: Newly introduced17.1 scalar-rejection branch loses the prior current_expr rather than evaluating it. This violates retained eager source behavior, although the original shared fixture lacks an effectful rejected consumer.
  Owned paths: Perl logical-loop rejection expression, shared logical_rejected_consumer_effects source/expected and focused native/fresh regression, retained public probe/current logical docs. Rust current leaf retains the independent cross-backend fixture/control without modifying Perl while dirty.
  Acceptance: Preserve LR/LRC/S prefix effects and null results, skip incompatible take operand, keep malformed logical typed errors and known consumer shape rules. Small current result/direct checks/docs/commit, then Dart17.3.
  Planned verification tier: focused
  Planned focused checks: Public native/fresh RED/GREEN rejection-effects plus current logical result regression and syntax/docs/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regression, no population/completeness measurement.

  Activation: clean `980c3c9ae171e7f4f17d885aaf78fca1759a44ee`; Rust17.2 committed, brief0/tree clean.
  Verification tier: `focused`
  Focused checks: Shared native/fresh rejection-effect RED/GREEN, existing logical result/error regression and Perl-only malformed consumer preflight control, syntax/book/history/staged continuity guards.
  Canonical trigger: None for immediate bounded regression repair under director feature-first cadence; full admission separate.
  Claim verification: none: deterministic authored regression/preservation controls, no population/completeness measurement.

  Completion: Capture the prior current_expr before applying each link; terminal scalar rejection now evaluates that prior emitted source/prefix once in scalar context, then returnsundef. It does not lower/evaluate incompatible consumer operands. Malformed-shape preflight and typed logical source arity remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: New shared native/fresh rejection regression RED returns empty order Strings instead ofLR/LRC/S; malformed sorted(1) control already gives[null,0]. Retained public comparison/substitution shows the whole chain becameundef, discarding source effects.
  - [x] ROOT CAUSE (WHY + WHERE): Newly added17.1 logical loop overwrites current_expr with the selected dispatch rejection before returning a constantundef. The previous logical/cat prefix remains unevaluated. This is our new continuation branch, not RuntimeLogical or emitter behavior.
  - [x] FIX: Preserve previous source_expr, bind it once in scalar context before terminal null rejection. No producer/truthiness/parser/schema/free-helper/domain or shared consumer-shape policy change.
  - [x] ADDRESSED (verified): Native/fresh shared bad Array/Hash/take fields returnnull and preserve LR/LRC/S; incompatible take operandA is skipped. The valid source/prefix runs once with its prior captured result. Perl-only malformed sorted(1) retains source-effect0.
  - [x] NO REGRESSION:24 focused top-level checks across new12 and current logical result/error12 pass; module/new-test syntax clean. Five malformed logical source cases retain typed pre-effect errors; raw Bool/false/default/bridge/source kinds and retired Hash-arrow assertion stay green. No whole suite/admission.
  - [x] LOCKSTEP: New retained Perl consumer of already checked shared rejected-effects fixture, frozen current contract and qualified catalog, logical/Rust facts/map plus task/live/resume align. Both new Perl logical tests remain mandatory23.4.1 registration before admission/push. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Parent17.1 closes; Dart17.3 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.17.1.1 - preserve rejected logical source effects`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary logical Boolean result continuations.
  Dependencies: .23.3.17.1.
  Acceptance: Follow logical-results.md, preserving actual Bool/strict numeric rejection, eager typed truthiness/source snapshots/free signatures, defaults/explicit Array-Hash bridges/scalar boundaries and pre-effect typed source arity errors. Public producer-first native/generated RED/GREEN and small direct checks/docs/commit; full admission separate.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and small direct regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.


  Activation: clean `a56732abcbf2af5968510246e23472c49d2fcadf`; Perl logical result repair committed, brief0/tree clean.
  Owned paths: Rust independently confirmed logical result/scalar/error gaps, native/restored/plan producer/shared/source error regression, scoped book/facts/task/live docs. Keep typed truthiness/eager Bool/numeric rejection/free signatures/source snapshots unchanged.
  Verification tier: `focused`
  Focused checks: Independent public producer-first RED/GREEN, direct named neutral logical/default cases as warranted, offline compilation/rustfmt and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Route known logical call receivers through existing selected scalar-result dispatch after dedicated trailing-block handling. Producer/eager typed truthiness/numeric rejection/source errors already work; only clean direct scalar->Array rejection needs repair.
  Verification:
  - [x] REPRODUCE / ISSUE: Correct the new harness to use public execute_value_with_diagnostics before crediting semantic RED. Producer and typed invalid source cases pass independently; shared RED differs only at incompatible Array[] instead ofnull. Valid three bridges/defaults/source kinds/LRC/SC already hold.
  - [x] ROOT CAUSE (WHY + WHERE): Common fluent dispatch chooses first Array consumer without marking the known logical source scalar. Existing selected dispatcher has the required scalar boundary; eval_expr already preserves source arity/eager Bool and snapshots.
  - [x] FIX: Evaluate and/or/not call receivers once, then selected scalar dispatch; keep existing trailing-block normalization first. No typed truthiness/parser/schema/helper/free/numeric/error changes.
  - [x] ADDRESSED (verified): Four new native/restored/plan tests pass canonical Bool producer/strict numeric-null, shared kinds/source/false/default/bridge/boundary/eager controls and five typed source-error shapes. Independent rejected-consumer fixture preserves LR/LRC/S while skipping incompatible take operand; no original operand substituted for Bool.
  - [x] NO REGRESSION: Six focused tests total include direct default and actual named neutral logical native/serialized/generated-plan consumer. Offline compilation/rustfmt pass. No whole suite or fresh standalone emitted Rust claim. Direct-dependent public Perl check exposes new17.1 rejection-effect loss; retained probe/fixture and immediate P1 child17.1.1 own repair after this clean commit, before Dart.
  - [x] LOCKSTEP: Retained Rust/shared rejected-effect controls and reference probe, frozen contract/current book qualification and compacted canonical Rust fact with exact prior Git pointer plus neutral fact/map/live/task/resume align. Normal change-history rollover is owned here. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Perl17.1.1 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.17.2 - guard Rust logical Boolean results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary logical Boolean result continuations.
  Dependencies: .23.3.17.2.
  Acceptance: Follow logical-results.md, preserving actual Bool/strict numeric rejection, eager typed truthiness/source snapshots/free signatures, defaults/explicit Array-Hash bridges/scalar boundaries and pre-effect typed source arity errors. Public producer-first native/generated RED/GREEN and small direct checks/docs/commit; full admission separate.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and small direct regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.


  Activation: clean `41b61a86bb51cdc872c71e3b6940f69bdec6f67d`; Perl rejection-effect follow-up committed, brief0/tree clean.
  Owned paths: Dart independently confirmed logical Boolean actual-result guards, retained native/restored/plan producer/shared/rejected-effect/source-error regression, scoped book/facts/task/live docs. Preserve typed truth/eager Bool/numeric rejection/free signatures/named context normalization and snapshots.
  Verification tier: `focused`
  Focused checks: Public producer-first RED/GREEN, direct selected neutral logical/default tests, format/fatal selected analysis and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Mark actual Boolean fluent input and any resulting Boolean scalar, reusing existing value dispatcher/container release and preserving named context normalization, helper/error/truth/numeric policies. Retain producer/shared/rejected-effect/actual-Bool/source-error regression.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent canonical Bool/nested/eager LRC/strict numeric-null producer and five typed source-error cases pass before production. Shared RED has container[] instead ofnull; rejected take runsA (SA). Actual selected/block/literal Bool sorted controls yield three[] values. Correct producer and source evaluation are not blamed.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluateFluentCallsWithValue initializes scalarResult=false and never recognizes actual Bool selected from another helper. Existing scalar guard therefore permits container dispatch/operand effects, although actual-value source/error logic is correct.
  - [x] FIX: Initialize scalar tracking from actual bool and retain it after Bool-yielding links; existing Array/Map results release the boundary. No method/parser/schema/eager truth/numeric/free signature, named container-context or typed source error changes.
  - [x] ADDRESSED (verified): Nine new native/restored/plan cases retain strict raw Bool/nested/typed truth/numeric-null/shared sources/defaults/bridges and five typed source-arity errors with unknown/known operands. Actual selected/block/literal Boolean boundaries rejectnull; LR/LRC/S prefix effects survive while incompatible take operandA is skipped.
  - [x] NO REGRESSION: Fifteen focused tests total include direct defaults and three actual named neutral logical native/normalized fixtures, preserving prior with/lazy controls. Format/fatal selected source/new-test analysis pass. No full suite, standalone emitted or full context/portable admission claim.
  - [x] LOCKSTEP: Retained current tests, contract/qualified public examples and compacted canonical Dart fact with exact prior Git pointer plus neutral fact/map/task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia17.4 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.17.3 - guard Dart logical Boolean results`.
  Continuity defect owned/fixed: Current Frontier paragraph still schedules assessment14 after its completed rollout and later15/16 work, despite the correct17.3 row. Prior slices advanced the row but accumulated stale summary prose. Replace the paragraph with a bounded current family/admission view; Git preserves the old chronology.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary logical Boolean result continuations.
  Dependencies: .23.3.17.3.
  Acceptance: Follow logical-results.md, preserving actual Bool/strict numeric rejection, eager typed truthiness/source snapshots/free signatures, defaults/explicit Array-Hash bridges/scalar boundaries and pre-effect typed source arity errors. Public producer-first native/generated RED/GREEN and small direct checks/docs/commit; full admission separate.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and small direct regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.


  Activation: clean `40cc7b4581a8826200c65f04b9fa1622515042d8`; Dart logical results committed, brief0/tree clean.
  Owned paths: Julia independently confirmed actual Boolean result/scalar guards, retained native/plan/fresh producer/shared/rejected-effect/selection/source-error test and runner registration, scoped book/facts/task/live docs. Preserve Bool identity/eager typed truth/numeric rejection/free/context/error policies.
  Verification tier: `focused`
  Focused checks: Public producer-first RED/GREEN and small direct neutral/default fixtures with explicit Bool/Number identity, strict compilation and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Initialize scalar_result from actual Bool and retain it after any Bool-yielding link, reusing existing selected dispatch and container release. Register strict native/plan/fresh producer/shared/rejected-effects/actual-Bool/source-error regression. All logical/free/numeric/named-context policies stay unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent producer/valid shared flow and source errors already pass. Nine native/plan/fresh RED assertions expose container[] andSA incompatible-operand effects plus selected/block/literal Bool sorted fallthrough. Raw Bool/eager truth/strict numeric-null/default/source fields remain healthy.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! starts scalar_result=false and omits actual Bool after result selection, so container dispatch/operands run despite a Boolean actual value. Logical evaluator/source snapshots/error validator already work.
  - [x] FIX: Initial and post-result Bool tracking, preserving actual container release, named normalization and all typed truth/arity/free/numeric/producer behavior. No new method/parser/schema or callback ABI change; register the retained test.
  - [x] ADDRESSED (verified): New100 assertions pass native/plan/fresh canonical Bool/typed truth/numeric-null/shared source/default/bridge/boundary/rejected-effect and five source-error cases. Explicit Bool identity/raw/meta/flag and Number-not-Bool counter checks avoid Julia equality lookalikes. LR/LRC/S remain, takeA skipped; selected/block/literal boundaries give null.
  - [x] NO REGRESSION:214 focused assertions total include direct defaults9 and three exact neutral logical fixtures105, preserving with/lazy controls and producer policies. Strict compilation passes. No whole suite, full context/portable admission or separately owned callback-identity repair.
  - [x] LOCKSTEP: New test/runner, frozen contract/current examples and compacted canonical Julia fact with exact prior Git pointer plus neutral fact/map/task/live/resume align. Current frontier paragraph/row advance together. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Safe Lua17.5 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.17.4 - guard Julia logical Boolean results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.17.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary logical Boolean result continuations.
  Dependencies: .23.3.17.4.
  Acceptance: Follow logical-results.md, preserving actual Bool/strict numeric rejection, eager typed truthiness/source snapshots/free signatures, defaults/explicit Array-Hash bridges/scalar boundaries and pre-effect typed source arity errors. Public producer-first native/generated RED/GREEN and small direct checks/docs/commit; full admission separate.
  Safety scope: Only safe available PUC5.5.1/LuaJIT fixtures; exclude malformed native patterns/full runner. Declared5.4 remains separately owned.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and small direct regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.


  Activation: clean `1b92335386b2bbe929646e66623a722b4351cba2`; Julia logical results committed, brief0/tree clean.
  Owned paths: Lua independently confirmed actual Boolean scalar guards, safe retained native/plan/fresh producer/shared/rejected-effect/actual-Bool/source-error test and runner registration, scoped book/facts/task/live docs. Preserve typed truth/eager Bool/numeric/free/named-context/error policies and existing module-local ceiling.
  Verification tier: `focused`
  Focused checks: Producer-first/source-error public RED/GREEN and direct neutral/default fixtures on safe PUC5.5.1/LuaJIT, source loads and book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen ordinary implementation under director feature-first cadence; declared5.4/full domain/context/portable admission separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Initialize scalar_result from actual boolean and retain it after Boolean results, with existing container release. No new module-level locals, helper/parser/schema/truth/numeric/free/named-context or error policy changes. Register safe retained producer/source-error/shared/rejected-effect/actual-Bool/direct-neutral test.
  Verification:
  - [x] REPRODUCE / ISSUE: Both hosts pass independent native/plan/fresh canonical Bool/nested/eager LRC/strict numeric-null producer and five typed source errors before production. Shared native RED differs at incompatible/after_text Array[] instead ofnull; valid source/default/bridge/effect fields already hold.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls starts scalar_result=false and does not recognize actual Boolean values from subsequent selections, permitting container fallthrough. Typed logical helper/source/eager/error behavior already works; do not infer a producer defect or earlier unmeasured rejected-operand failure from another backend.
  - [x] FIX: Actual boolean tracking at entry and after results, retaining container release. No module-local validator/helper addition or numeric/truth/free/context normalization; register new safe fixture.
  - [x] ADDRESSED (verified): Strict canonical JSON native/plan/fresh checks on PUC5.5.1/LuaJIT preserve raw Bool/false/default/source/generic/numeric-null/three bridges and typed source errors. Rejected-consumer fixture retains LR/LRC/S/null and skips takeA; actual selected/block/literal Bool boundaries give null. No integer/String lookalike passes canonical JSON.
  - [x] NO REGRESSION: Both hosts pass three exact neutral logical fixtures and direct selected defaults, plus interpreter/runner source loads; no new module locals at the historical chunk ceiling. No full runner, malformed native pattern, declared5.4 or complete portable/domain/context admission.
  - [x] LOCKSTEP: Retained test/runner, frozen contract/all-five bounded progress and qualified catalog, canonical Lua/neutral facts/map/task/live/resume align. Current frontier row/paragraph advance together. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Separate next18 assessment owns useful defined-only coalesce receiver/result breadth before any contract or code expansion.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.17.5 - guard Lua logical Boolean results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4`
  Status: `pending`
  Children: `TYPE-REFERENCE-BOOK.1.2.23.4.1`; remaining admission leaves split at activation.
  Count/length prerequisite: Bounded result rollout23.3.3 must land before complete fluent admission; the frozen contract is23.2.2 and bounded implementations23.3.3.1-.5 are targeted-checked; complete context/portable admission remains here.
  Known admission prerequisite: Rust scalar/default and bounded copy-arity implementations are targeted-checked; broad61.3/62.3/.62.4/copy23.3.2.5 remain open. Selected/count result implementations do not establish complete scalar families. Lua declared5.4 runtime/header proof remains LUA-STARTUP-READING.2.2.
  Goal: Independently admit complete fluent families and inter-type chains for the selected scope.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.3`
  Acceptance: Reconcile expected families and every transition in both directions against actual native/generated consumers and individual mdBook examples. Reject deliberate missing-method, wrong-return-type and continuation-dispatch faults; include empty/missing/error and backend controls. No family's final reference leaf .2-.6 or aggregate .7 closes over an unresolved assigned fluent gap. Keep scope exclusions explicit; publish no completeness claim from samples alone.
  Planned tier: Canonical admission; declare exact source-bound claim records before execution.

  Required gate prerequisite: TYPE-REFERENCE-BOOK.1.2.23.4.1 registers retained new Perl feature fixtures before this admission and any final push. Focused direct checks do not imply canonical selection.
  Artifact admission note: Rust23.3.10.2 restores action regex suffix modes in new compiled patterns. Rebuild current production derived artifacts from tracked source before promotion; previously stored nodes cannot infer discarded suffix information. Preserve immutable historical proof artifacts and their original results under their existing owners.

  Mandatory admission prerequisites: Resolve document-pressure/freshness intake1.2.20.1 and invalid-callback phase/diagnostic parity1.2.1.4.1, alongside explicit Perl registration23.4.1 and all existing backend/context prerequisites. Ordinary feature checks and known baseline gate failures do not constitute canonical admission.

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

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.18`
  Status: `active` / all bounded defined-only default backends targeted-checked; full admission separate
  Goal: Add bounded ordinary defined-only coalesce receivers and actual selected-result continuations.
  Dependencies: .23.2.18 frozen defined-default-results.md.
  Children: `.23.3.18.1`, `.23.3.18.2`, `.23.3.18.3`, `.23.3.18.4`, `.23.3.18.5`.
  Acceptance: One-or-more fallbacks, defined-only lazy once-only selection, actual String/Number/Boolean/Array/Hash kinds/copies/snapshots, compatible consumers/explicit bridges and scalar boundaries. Preserve existing free signatures/domains/callbacks and old nonempty-default behavior; no complete domain/context/portable admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.18.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary defined-only coalesce receivers and actual selected-result continuations.
  Dependencies: .23.2.18.
  Acceptance: Follow defined-default-results.md; preserve defined empty/zero/false, null exhaustion, source-first lazy once-only selection, actual scalar/container/copy/selector kinds and skipped runtime failures. One-or-more receiver fallbacks and scalar boundaries reject before forbidden effects. Public producer-first native/generated RED/GREEN plus small direct defaults/compile checks/docs/commit; no free signature/domain normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and shared result/effect/kind/shape controls, small direct default regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `c918f545af7c83b5ff0b93958a4ed141c849bc59`; defined-default freeze committed, brief0/tree clean.
  Owned paths: Perl ordinary coalesce receiver admission/lazy actual-result flow/shape boundaries, retained shared native/fresh values/effects/kinds/copies/selectors test and scoped book/fact/task/live docs. Reuse existing typed lazy/default and emitted-host machinery, preserving authored Hash colon validation and free signatures.
  Verification tier: `focused`
  Focused checks: Independent retained public producer/AST intake, shared native/fresh RED/GREEN and direct selected/literal default checks, syntax and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Owned implementation findings: Metadata-only admission fixes most shared cases, but a Hash-returning pick_keys successor falls out of the String-first loop and emits unsupported sorted_values; a text-prefix rejected Hash consumer lowers to constantundef and loses SC. Public Get/substitution/native/fresh reproduce both. Complete this new receiver chain through the existing actual-value/host compatibility loop, preserving source effects before rejection and actual Hash results.
  Additional P2 defect owned/scheduled: Public free pick_keys(chosen,{order=cat(order,"C");meta["a"]="z";"a"}) retains a raw DSL key block in emitted host foreach and fails handler/fresh compilation. A new explicit key-variable control separates this pre-existing free-key staging defect from receiver flow; The same key-block staging defect blocks the new fluent Hash snapshot consumer after dispatch repair, so repair it now within18.1 using the existing typed block lowerer and retain a direct free-key control; no separate18.1.1 pivot. The initial failing free-block expression is not a passing oracle.

  Completion: Admit coalesce as default_result with a pre-effect one-or-more-fallback guard. Chains containing this new method share the established logical/actual-value dispatcher and emitted-host finishing, retaining actual Hash/Array transitions and source/prefix effects before scalar rejection. Bind the fully lowered source once in scalar context inside the host bridge, preserving valid direct Hash literal identity without reparsing host fat arrows as retired authored syntax. Lower actual pick_keys key blocks with the existing typed block bridge; ordinary key forms/free signatures remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared native/fresh RED has raw receiver DSL compile errors. Metadata-only admission exposes Hash successor unsupported sorted_values and dropped SC before a rejected scalar tail; public substitution retains both mechanisms. Direct free pick_keys key-block control fails host compilation with raw DSL foreach operand; it also blocks the new fluent Hash consumer.
  - [x] ROOT CAUSE (WHY + WHERE): Missing receiver return family/shape metadata, String-first loop lacking Hash handoff and terminal constantundef discarding a valid prefix. The new scoped typed-source handoff initially reparses emitted Hash arrows, then an unbound bare Hash block loses reference kind; public AST/substitution distinguish authored hash_literal from emitted host syntax. pick_keys legacy key normalization lacks typed block lowering.
  - [x] FIX: Scoped actual-result/host compatibility composition, scalar-bound source and pre-effect coalesce shape guard; existing typed block lowerer for pick_keys key operands. No raw authored fallback, parser/schema/free signature/numeric/truth/callback/domain normalization. Fix the blocking key defect in this leaf rather than defer an unworking Hash snapshot consumer.
  - [x] ADDRESSED (verified): New13 native/fresh checks pass strict selected kinds, empty/zero/false/exhaustion, eight source families, String-to-Array bridge, numeric indices, chosen Array/Hash copies, SDC/SC/once-only snapshots, skipped effects/runtime error, Hash key C mutation/capture, rejected source/prefix effects and malformed zero-RHS no-effects. Retired authored Hash arrows still reject.
  - [x] NO REGRESSION: Direct existing selected-default5 and logical rejected-effect12 checks pass; source/test/probe syntax and final changed fixture pass,30 focused top-level checks across retained runs. Later source wrapping only affects new coalesce receiver chains. No broad suites/full matrix/portable admission; every new Perl fixture needs explicit23.4.1 runner registration.
  - [x] LOCKSTEP: Shared fixture/test, retained public Hash/prefix/AST controls, frozen contract/current qualified catalog/guide and canonical default fact/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Rust18.2 independently assesses its producer next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.18.1 - add Perl defined-only default receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.18.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary defined-only coalesce receivers and actual selected-result continuations.
  Dependencies: .23.3.18.1.
  Acceptance: Follow defined-default-results.md; preserve defined empty/zero/false, null exhaustion, source-first lazy once-only selection, actual scalar/container/copy/selector kinds and skipped runtime failures. One-or-more receiver fallbacks and scalar boundaries reject before forbidden effects. Public producer-first native/generated RED/GREEN plus small direct defaults/compile checks/docs/commit; no free signature/domain normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and shared result/effect/kind/shape controls, small direct default regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `1ad4335927d71adb22e331d61ebe7df2fd578046`; Perl defined-default receivers committed, brief0/tree clean.
  Owned paths: Rust independently confirmed defined-only receiver admission/lazy actual-result/scalar/shape flow and retained native/restored/in-process generated-plan public producer/shared regression, scoped book/fact/task/live docs. Preserve free signatures/domains/callbacks and compiled formats; no standalone emitted Rust admission.
  Verification tier: `focused`
  Focused checks: Producer-first public native/restored/plan and shared receiver RED/GREEN, direct selected/nonempty defaults as warranted, offline compile/rustfmt and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: Native/restored/plan free/nested producer controls pass strict defined kinds/laziness/copies/Number selector writes before production. Shared receiver RED reaches a deliberately unused typed nested-write failure, proving eager evaluation of a fallback. engine fluent String admission/lazy handling only knows coalesce_nonempty, so coalesce falls to generic eager helper invocation without receiver normalization. Add only the frozen counterpart metadata/lazy/scalar/pre-effect-shape handling; no free helper change.

  Completion: Admit coalesce alongside nonempty defaults in String/dynamic receiver dispatch, select the existing lazy default policy by helper spelling, hand actual selections to shared continuation and mark the new method's scalar results until a container is returned. Common zero-RHS preflight precedes source/consumer effects. No free helper/producer/domain/schema/callback change.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent native/restored/plan free/nested producer controls pass strict defined empty/zero/false/null/container values, skipped effects/failure, copies and numeric selector writes. Shared native RED reaches the deliberately unused nested_write_kind_conflict failure before returning a value; other pre-change shared fields are not inferred.
  - [x] ROOT CAUSE (WHY + WHERE): engine fluent String method admission, dynamic lazy branch and actual-selection handoff include only coalesce_nonempty. coalesce falls through generic eager helper invocation without the source operand. Common preflight and selected-result scalar tracking also lack the new counterpart's shape/result metadata.
  - [x] FIX: Add the bounded counterpart to existing String/lazy/result dispatch and one-or-more receiver preflight; reuse eval_coalesce_args/coalesce_accepts and selected actual-value flow. Preserve all free signatures/truth/numeric/context/copy policies and compiled formats.
  - [x] ADDRESSED (verified): Shared native/restored/in-process plan GREEN preserves exact scalar/container kinds, all source families, empty containers, SDC/SC/Hash-C snapshots, chosen copies/Number indices, skipped supported runtime errors and rejected-prefix/operand effects. Extra selected/named/Boolean/malformed controls give fournull/emptyorder, with no forbidden source or consumer effect.
  - [x] NO REGRESSION: New3 and direct nonempty/selected default3 tests pass, six focused tests total, with offline compilation and rustfmt. No broad suite/full matrix, standalone emitted Rust or complete portable domain/context admission.
  - [x] LOCKSTEP: Retained public producer/shared/selected controls, frozen contract/current qualified catalog/guide and canonical default fact/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Dart18.3 independently assesses next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.18.2 - add Rust defined-only default receivers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.18.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary defined-only coalesce receivers and actual selected-result continuations.
  Dependencies: .23.3.18.2.
  Acceptance: Follow defined-default-results.md; preserve defined empty/zero/false, null exhaustion, source-first lazy once-only selection, actual scalar/container/copy/selector kinds and skipped runtime failures. One-or-more receiver fallbacks and scalar boundaries reject before forbidden effects. Public producer-first native/generated RED/GREEN plus small direct defaults/compile checks/docs/commit; no free signature/domain normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and shared result/effect/kind/shape controls, small direct default regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `03008322bb320d137ebecc4c9f243bdde01ff887`; Rust defined-default receivers committed, brief0/tree clean.
  Owned paths: Dart independently confirmed defined-only receiver actual-result/scalar/shape flow and retained native/restored/generated-plan public producer/shared/selected regression, scoped book/fact/task/live docs. Preserve free signatures/domains/callbacks, named-context normalization and serialized formats.
  Verification tier: `focused`
  Focused checks: Producer-first public native/restored/plan and shared receiver RED/GREEN, direct selected/nonempty defaults, format/fatal selected analysis and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: Correct package-directory producer run passes native/restored/plan defined kinds/lazy copies/Number indices. Shared native RED preserves valid selection/source/default/SDC-SC-HashC flow but gives rejected/after_text [] and reject_order SA; zero-RHS malformed chain runs SC. Selected controls give[[],[],null,1!,SC]. Existing _callCoalesceWithReceiver already handles defined-only laziness; missing scalar-result tracking and common shape guard own the gaps. Initial root-directory test invocation only reports missing pubspec and is not semantic RED.

  Completion: Add coalesce to mayProduceScalar and common one-or-more receiver preflight. Reuse already-correct defined-only lazy selection/actual container release; preserve all free/helper/numeric/callback/named-context/format policies.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent native/restored/plan free/nested producers pass defined kinds/lazy skipped failure/copies/Number indices. Shared native RED yields rejected/after_text [] and reject_order SA, while valid selection/SDC-SC-HashC/snapshots already hold. Malformed zero-RHS executes SC; selected controls give[[],[],null,1!,SC].
  - [x] ROOT CAUSE (WHY + WHERE): _evaluateFluentCallsWithValue mayProduceScalar omits coalesce, permitting container fallthrough and operands; common ActionFluentChainExpr preflight lacks its shape. _callCoalesceWithReceiver already preserves required defined-only selection, so no producer repair inferred.
  - [x] FIX: Track the new method's scalar results until an actual List/Map releases the boundary; reject zero fallbacks before source/consumer effects. No free arity/domain/context/schema/callback or lazy helper change.
  - [x] ADDRESSED (verified): Shared native/restored/plan GREEN preserves exact kinds/empty/zero/false/exhaustion/containers/sources, SDC/SC/HashC snapshots, independent copies/indices/skipped errors, source/prefix effects before rejection and no forbidden consumer operands. Extra selected/named/Boolean/malformed controls yield fournull/emptyorder.
  - [x] NO REGRESSION: New3/direct selected/nonempty default3 tests pass, six focused tests, plus format/fatal selected analysis. Initial root-directory missing-pubspec invocation is corrected and not credited as semantic RED. No broad suite/matrix/standalone/complete portable admission; existing named-context normalization remains unchanged.
  - [x] LOCKSTEP: Retained producer/shared/selected test, frozen contract/current qualified catalog/guide and canonical default fact/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia18.4 independently assesses next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.18.3 - guard Dart defined-only default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.18.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary defined-only coalesce receivers and actual selected-result continuations.
  Dependencies: .23.3.18.3.
  Acceptance: Follow defined-default-results.md; preserve defined empty/zero/false, null exhaustion, source-first lazy once-only selection, actual scalar/container/copy/selector kinds and skipped runtime failures. One-or-more receiver fallbacks and scalar boundaries reject before forbidden effects. Public producer-first native/generated RED/GREEN plus small direct defaults/compile checks/docs/commit; no free signature/domain normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and shared result/effect/kind/shape controls, small direct default regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `3f1a386d0c9b48268b02b07e51aa68728b5a80fa`; Dart defined-default results committed, brief0/tree clean.
  Owned paths: Julia independently confirmed defined-only receiver actual-result/scalar/shape flow and retained native/plan/fresh public producer/shared/selected regression with strict Bool/Number distinctions, runner registration and scoped book/fact/task/live docs. Preserve free signatures/domains/callbacks/named-context/serialized formats.
  Verification tier: `focused`
  Focused checks: Producer-first public native/plan/fresh and shared receiver RED/GREEN, direct selected/nonempty defaults, strict compilation and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: Producer-first strict native/plan/fresh controls pass12 assertions before code. Shared all three routes preserve selection/snapshots/copies/indices/skipped errors but expose rejected/after_text [] with SA and malformed SC. Selected controls[[],[],null,1!,SC] on all three. _evaluate_runtime_fluent_chain! lacks coalesce in may_produce_scalar and one-or-more preflight; existing _runtime_coalesce_accepts/lazy receiver path already works. No producer/free repair inferred.

  Completion: Add coalesce to common one-or-more receiver preflight and may_produce_scalar. Reuse already-correct lazy defined-only selection, actual container release and ordinary copy/Hash-key/source flow. Register the retained strict native/plan/fresh producer/shared/selected test.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent strict native/plan/fresh producer-first12 pass. Shared all three routes expose rejected/after_text [] and SA, malformed SC; selected controls give[[],[],null,1!,SC]. Existing actual values/SDC-SC-HashC/copies/Number indices/skipped failures already hold.
  - [x] ROOT CAUSE (WHY + WHERE): _evaluate_runtime_fluent_chain! lacks coalesce in common shape preflight/may_produce_scalar, permitting scalar container normalization/operand effects and zero-RHS source effects. Existing lazy _runtime_coalesce_accepts/receiver/copy policy is correct; no producer defect inferred.
  - [x] FIX: New counterpart scalar-result tracking until AbstractVector/AbstractDict output releases the boundary and zero-RHS rejection before source/consumer effects. No parser/schema/free signature/domain/numeric/callback/named-context normalization; register the test in runtests.
  - [x] ADDRESSED (verified): New36 native/plan/fresh assertions pass shared exact values/bridges/source families, strict false identity and Number-not-Bool counters/results, empty containers/exhaustion, SDC/SC/HashC snapshots/copies/indices/skipped runtime errors, rejected-prefix effects and forbidden operand suppression. Selected/malformed controls yield fournull/emptyorder.
  - [x] NO REGRESSION: Direct selected/nonempty defaults9 assertions also pass,45 total with strict compilation. No full suite/matrix/complete portable admission, callback-identity or blanket named-context repair is claimed.
  - [x] LOCKSTEP: Retained test/runner, frozen contract/current qualified catalog/guide and canonical default fact/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Safe Lua18.5 independently assesses next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.18.4 - guard Julia defined-only default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.18.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary defined-only coalesce receivers and actual selected-result continuations.
  Dependencies: .23.3.18.4.
  Acceptance: Follow defined-default-results.md; preserve defined empty/zero/false, null exhaustion, source-first lazy once-only selection, actual scalar/container/copy/selector kinds and skipped runtime failures. One-or-more receiver fallbacks and scalar boundaries reject before forbidden effects. Public producer-first native/generated RED/GREEN plus small direct defaults/compile checks/docs/commit; no free signature/domain normalization or full admission.
  Safety scope: Only safe available PUC5.5.1/LuaJIT fixtures; exclude malformed native patterns/full runner. Declared5.4 remains separately owned.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and shared result/effect/kind/shape controls, small direct default regression, source compilation and book/continuity checks.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `266ae756e44eeb672c6e8752b42dab7e23c5d272`; Julia defined-default results committed, brief0/tree clean.
  Owned paths: Lua independently confirmed defined-only receiver actual-result/scalar/shape flow and safe retained native/plan/fresh public producer/shared/selected regression, safe named runner registration and scoped book/fact/task/live docs. Preserve free signatures/domains/callbacks/named-context/formats and module-local ceiling; no full runner or malformed native pattern execution.
  Verification tier: `focused`
  Focused checks: Producer-first public native/plan/fresh and shared receiver RED/GREEN plus direct selected/nonempty defaults/source loads on safe PUC5.5.1/LuaJIT, book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; declared5.4/full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: Both safe available hosts pass canonical JSON native/plan/fresh free/nested producer controls before production. Shared native RED gives scalar rejected/after_text [] with reject_order SA and malformed SC; valid selection/source/snapshot/copy/index/skipped-error values remain. evaluate_fluent_calls already invokes defined-only evaluate_coalesce but marks only nonempty defaults scalar; common preflight lacks the new one-or-more shape. Repair only these metadata guards, with no new module locals/free helper changes.

  Completion: Both coalesce receiver branches mark scalar_result before existing actual-container release; common zero-RHS preflight precedes source/consumer effects. Register safe retained producer/shared/selected checks, with no new module locals or helper/free/named-context/format/callback changes.
  Verification:
  - [x] REPRODUCE / ISSUE: Both PUC5.5.1/LuaJIT pass canonical JSON native/plan/fresh producer-first controls before code. Shared native RED has scalar[]/SA and malformed SC; valid source/selection/SDC-SC-HashC/copies/indices/skipped-runtime-error fields already hold. No unobserved backend error is inferred.
  - [x] ROOT CAUSE (WHY + WHERE): evaluate_fluent_calls already calls defined-only evaluate_coalesce, but marks only nonempty defaults scalar, permitting incompatible container helpers/operands. Common fluent preflight lacks the new counterpart's one-or-more fallback shape. No producer/domain/free-signature repair is needed.
  - [x] FIX: Mark both default selections scalar before actual Array/Harray release and add coalesce zero-RHS preflight. Retain existing lazy/copy/context/truth/numeric policies and module-local ceiling; register only a safe named test group.
  - [x] ADDRESSED (verified): Both hosts pass canonical JSON native/plan/fresh producer/shared/selected controls, preserving real Bool/Number/String/null/container kinds, empty/zero/false/exhaustion, source families, chosen copies/indices/SDC-SC-HashC snapshots, skipped supported failures and incompatible operands, source/prefix effects before rejection and malformed no-effects.
  - [x] NO REGRESSION: Direct existing selected/nonempty default fixtures and interpreter/runner source loads pass on both hosts. No full runner/malformed native patterns, declared5.4, broad matrix or complete portable domain/context admission claim.
  - [x] LOCKSTEP: Retained test/safe runner, frozen contract/all-five bounded progress and qualified catalog/guide, canonical default fact/map plus task/live/resume align. Next pure String result assessment23.2.19 is owned before any new diagnostic/change. Book/history/diff/final staged memory/cadence/diagnosis checked before commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.18.5 - guard Lua defined-only default results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.19`
  Status: `active` / all bounded scalar String backends targeted-checked; domain20/full admission separate
  Goal: Complete bounded actual scalar String-helper results, identity kinds and clean scalar/shape boundaries.
  Dependencies: .23.2.19 frozen scalar-string-results.md.
  Children: `.23.3.19.1`, `.23.3.19.2`, `.23.3.19.3`, `.23.3.19.4`, `.23.3.19.5`.
  Acceptance: Preserve existing eight helper/free/Unicode/null/conversion domains and actual identity kinds; compatible scalar/generic/numeric/explicit Array flow, once-only snapshots/effects, clean scalar rejection and pre-effect ordinary shapes. No full domain/context/portable admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.19.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl ordinary scalar String-helper result flow and boundaries.
  Dependencies: .23.2.19.
  Acceptance: Follow scalar-string-results.md; preserve eight helper domains/null/empty/Unicode/strict cat policies, actual identity Number/Boolean/String kinds, source-first once-only operands/snapshots and scalar/generic/numeric/explicit Array bridges. Clean incompatible-consumer and malformed-shape boundaries retain permitted effects and skip forbidden ones. Public producer-first native/generated RED/GREEN plus small direct String/compile checks/docs/commit; no free signature/selector/callback normalization or full admission.
  Owned P1 defect: Free/fluent/named unmatched affix numeric identity loses typed Array-index kind despite numeric JSON; inspect a copy during index/length/substr tests, preserving original Number/Boolean/String value. Retain exact selector/B-flag distinctions and unchanged String-key rejection. Repair here before Rust; reducer95 remains separate.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and retained result/effect/kind/shape controls, small direct String regression/source compilation/book/continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `9eb55615dc568652ae3cd8882f27be7d1ab9234e`; scalar String freeze committed, brief0/tree clean.
  Owned paths: Perl eight scalar String-helper actual-result/scalar/shape composition and affix identity copy inspection, retained shared native/fresh values/effects/Unicode/typed-selector regression and scoped book/facts/task/live docs. Preserve dedicated mutation/traversal/callback routes, authored Hash colon checks, typed selectors and free signatures.
  Verification tier: `focused`
  Focused checks: Public producer/AST/identity flag intake and retained shared native/fresh RED/GREEN, direct scalar-text/default/logical rejection checks as warranted, syntax and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Completion: Classify the eight scalar String helpers as scalar_result and validate ordinary receiver shapes through existing free arity metadata before effects. Ordinary transform chains reuse the established typed actual-result/emitted-host loop, preserving source/prefix effects before rejection and actual Array bridges. Dedicated mutation/traversal dispatch remains on its existing route. Affix matching inspects a scalar copy, returning the untouched original on identity and actual substring text on match.
  Verification:
  - [x] REPRODUCE / ISSUE: New native/fresh shared RED fails compilation on raw boundary/malformed DSL. Retained public free/fluent/named prefix/suffix Number indices fail typed harray-vs-array; replacement/literal0 controls pass. Pre-JSON flags distinguish contaminated IOK+POK from numeric IOK-only and String POK-only.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering String metadata/composition lacks a scalar rejection boundary after transforms, while common preflight lacks their ordinary shapes. rm_prefix/rm_suffix inspect the original Number via index/length/substr, adding POK honored by BindingRuntime. This is producer contamination, not a selector-kind bug or Number/JSON encoding policy change.
  - [x] FIX: Central scalar String helper classifier, existing arity metadata/typed result/host compatibility dispatch and once-bound scalar source; preserve dedicated routes and authored Hash colon checks. Inspect affix text copies and return original identities. No free signature/Unicode/null/strict cat/numeric/selector/callback normalization.
  - [x] ADDRESSED (verified): New7 native/fresh shared checks pass all eight texts/nested/bridges/boundaries/empty/null, Unicode expansion/final-sigma/emoji substring, eight source roots, numeric/generic consumers, identity Number/Bool/String and matched text keys. Free/fluent/named Array writes pass; String0/matched/empty keys remain Hash keys. SONC/SC/selected-S/once-only snapshots, eager null operands, rejected-consumer operand skipping and12 malformed no-effects hold. Public flags now show IOK-only numeric affix identities and POK-only String0 on both routes.
  - [x] NO REGRESSION: Direct scalar-text7/nonempty-default5 and new7 pass,19 focused top-level checks plus module/test/probe syntax. Authored retired Hash arrows still reject. No broad suite/matrix/portable admission, reducer95, large-number/unary-cat or mutation/callback admission claim. Every new Perl fixture still requires23.4.1 registration.
  - [x] LOCKSTEP: Shared fixture/test, retained public flags/probe/frozen contract, current qualified catalog/guide and canonical String/null facts/map plus task/live/resume align. Remove the temporary identity limitation from current book; typed Array-index examples now work. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Rust19.2 independently assesses next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.19.1 - preserve Perl scalar String result kinds`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.19.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust ordinary scalar String-helper result flow and boundaries.
  Dependencies: .23.3.19.1.
  Acceptance: Follow scalar-string-results.md; preserve eight helper domains/null/empty/Unicode/strict cat policies, actual identity Number/Boolean/String kinds, source-first once-only operands/snapshots and scalar/generic/numeric/explicit Array bridges. Clean incompatible-consumer and malformed-shape boundaries retain permitted effects and skip forbidden ones. Public producer-first native/generated RED/GREEN plus small direct String/compile checks/docs/commit; no free signature/selector/callback normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and retained result/effect/kind/shape controls, small direct String regression/source compilation/book/continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `ea6f82c2ac8e216bcfd721a42d10b713a24c5dc1`; Perl scalar String flow/affix identity repair committed, brief0/tree clean.
  Owned paths: Rust independently confirmed scalar String-helper actual-result/scalar/shape flow and retained native/restored/in-process generated-plan public producer/shared/selector regression, scoped book/facts/task/live docs. Preserve free domains/null/Unicode/strict cat/callbacks and compiled formats; no standalone Rust admission.
  Verification tier: `focused`
  Focused checks: Producer-first public native/restored/plan and shared result RED/GREEN, direct scalar-null/predicate/default checks as warranted, offline compile/rustfmt and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: Producer-first native/restored/plan free values/Unicode/identity selectors/order pass before code. Shared native RED preserves basic outputs/bridges/identities/Unicode but runs rejected SCA/selected SA, returns selected[] and malformed values with SASSSASSSSSSSSC. Null source substr also yields emptyString rather than the catalog's null; isolate free explicit-null source/start and eager operand order before classifying/repairing this additional source boundary. Own confirmed null defect here with the result/shape changes, without inferring other backend failure.

  Additional source defect: Independent Rust free/fluent null source/start test returns[empty,abc,empty,abc,SIL] instead ofnulls/SIL. The ordinary substr arm textifies undef and defaults its null start before guarding; dedicated regex mutation exits earlier and must stay untouched. Public Perl native boundary control also confirms fractional start/width normalize0, Boolean true keeps its existing offset1 compatibility, and provided-null width returnsnull. Retain the reference in the public probe and extend the independent Rust control before narrowing the ordinary slice fix. Preserve free unary/extra-arity policy and dedicated mutation; no global numeric normalization.

  Completion: Mark all eight String-helper results scalar in existing selected-result dispatch and add precise ordinary receiver shapes to common preflight. Independently confirmed ordinary substr source/start/provided-width null and fractional start/width defects now guard null before coercion and normalize nonnegative whole offsets, after dedicated regex mutation exits. Retain optional omitted width, Boolean offset compatibility, free unary/extra arity and named-target mutation policies.
  Verification:
  - [x] REPRODUCE / ISSUE: Producer-first native/restored/plan free values/Unicode/identity selectors/order pass. Shared native RED preserves valid output but runs rejected SCA/selected SA, returns selected[] and malformed nonnull/effects; null substr yields emptyString. Independent free/fluent null test gives[empty,abc,empty,abc,SIL], and expanded bounds RED truncates fractional start/width instead of normalizing0.
  - [x] ROOT CAUSE (WHY + WHERE): engine scalar-result list omits the eight methods and common preflight lacks their ordinary shapes; String loop evaluates incompatible operands before rejecting. Ordinary substr converts undef with to_str/as_number before guards and casts fractional numbers directly to usize. Retained public Perl native/fresh bounds return null/null/abc/a/empty/empty/bc/null, distinguishing the correct source/start/width/fraction/negative/Boolean rules. Regex mutation returns earlier in its dedicated arm.
  - [x] FIX: Existing scalar/result tracking and precise receiver preflight; ordinary two/three-operand null guard plus local whole-offset normalization after dedicated mutation dispatch. No global numeric/selector/Unicode/free-arity/schema/callback normalization or affix producer change.
  - [x] ADDRESSED (verified): Shared native/restored/in-process plan GREEN preserves all eight outputs/bridges/empty/null/Unicode/source roots, exact identity/matched keys/Array indices, scalar/generic/numeric flow, SONC/SC/selectedS snapshots/eager null operands, prefix effects/skipped incompatible operands and12 malformed no-effects. Independent substring null/fraction/negative/Boolean/optional-width controls retain SIL; both named-target substr/regex_subst mutation controls return xbx/yba.
  - [x] NO REGRESSION: New4/direct scalar-null1/scalar-predicate1/nonempty-default1 tests pass, seven focused tests, with offline compile/rustfmt and probe syntax. No broad suite/matrix, standalone Rust or complete portable/domain admission; old unary-cat/large-number/reducer95/callback owners remain separate.
  - [x] LOCKSTEP: Retained test/primary probe, frozen contract/current qualified catalog/guide and canonical String/null facts/map plus task/live/resume align. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Dart19.3 independently assesses next, including observed substring boundaries.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.19.2 - guard Rust scalar String results and slices`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.19.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart ordinary scalar String-helper result flow and boundaries.
  Dependencies: .23.3.19.2.
  Acceptance: Follow scalar-string-results.md; preserve eight helper domains/null/empty/Unicode/strict cat policies, actual identity Number/Boolean/String kinds, source-first once-only operands/snapshots and scalar/generic/numeric/explicit Array bridges. Clean incompatible-consumer and malformed-shape boundaries retain permitted effects and skip forbidden ones. Public producer-first native/generated RED/GREEN plus small direct String/compile checks/docs/commit; no free signature/selector/callback normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and retained result/effect/kind/shape controls, small direct String regression/source compilation/book/continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `bbb8d0dddc802a9637c678d818666eb155a28a7d`; Rust scalar String/slice fixes committed, brief0/tree clean.
  Owned paths: Dart independently confirmed scalar String-helper actual-result/scalar/shape and observed slice-boundary flow, retained native/restored/generated-plan public producer/shared/slice/mutation regression, scoped book/facts/task/live docs. Preserve free domains/Unicode/strict cat/identity/callbacks/named-context/serialized formats; assess producer defects independently.
  Verification tier: `focused`
  Focused checks: Producer-first public native/restored/plan and shared/slice RED/GREEN, direct selected/default or String checks as warranted, format/fatal selected analysis and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent producer finding: Initial free producer/index control fails native typed harray-vs-array before receiver code, so no producer-pass or shared result is credited. _callRemoveEdge and _callReplaceSubstr return coerced String on identity, violating published original Number/Boolean kinds. Their explicit null replacement/affix operands also use nullAsEmpty despite published null propagation; isolate raw identity/null and healthy String/Unicode/eager controls plus receiver boundaries before production. Preserve existing regex/other scalarization compatibility and do not infer argument domains from another backend.

  Confirmed intake: Basic String/Unicode/strict-null/SON controls pass native/restored/plan. Native identity/null operands yield[String0,String0,String0,String0,String0,String0,abc,bc,abc,abc]; receiver control gives[[],SCA,null,SAC]. Full shared aborts on prefix identity index. Existing named-target mutation passes. Slice source/start null already work; fractional Number indices truncate. Dart intentionally treats provided-null width as omitted and Boolean offset as invalid0, unlike the recorded Perl/Rust compatibility. Preserve those two existing input-domain conventions in this result slice; explicit reconciliation is P2 assessment20 before portable admission, not an inferred backend defect/promotion.

  Completion: Add eight-method scalar-result tracking and precise common receiver preflight. Preserve Number/Boolean identity for empty-old replacement/empty-unmatched affixes, retaining existing text behavior for other scalarized carriers. Guard explicit null replacement/affix operands without changing non-null scalarization admission. Normalize fractional slice offsets locally, preserving Dart provided-null-width/Boolean-offset conventions and dedicated mutation; concrete domain reconciliation20 is scheduled before portable admission.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent healthy basic String/Unicode/strict-null/eager SON producers pass native/restored/plan. Separate identity/null source RED gives six String0 then abc/bc/abc/abc instead of typed identities/nulls; typed Array index aborts original/shared producers. Receiver RED gives[[],SCA,null,SAC]; slice RED truncates fractional Numbers. Both named-target mutation aliases already pass.
  - [x] ROOT CAUSE (WHY + WHERE): _callReplaceSubstr/_callRemoveEdge return coerced text on identity and nullAsEmpty masks explicit null operands. _evaluateFluentCallsWithValue scalar list/common preflight omit eight methods/shapes. _callSubstr uses global _intValue truncation; its intentional null-width-as-omitted/Bool-invalid-zero rules are distinct domain conventions, not inferred failures against Perl expectations.
  - [x] FIX: Preserve only supported Number/Boolean originals on identity, keep other scalarized text behavior, add explicit positional null guards, eight-method result set/ordinary shape guards and local fractional offset normalization. No global numeric/int helper, selector, Unicode, free arity, regex/callback, named-context or aggregate domain normalization. Source input-domain assessment20 owns width/Bool policy before any promotion.
  - [x] ADDRESSED (verified): All seven new native/restored/plan tests pass: healthy/identity/null producers, source boundary control, full shared values/bridges/empty/null/Unicode/roots, strict Number/Bool/String/matched keys and free/fluent/named Array indices, SONC-SC-selectedS snapshots/eager null operands and12 malformed no-effects. Independent slice controls preserve SIL/current width/Bool conventions; both mutation aliases return xbx/yba.
  - [x] NO REGRESSION: Direct selected/nonempty default3 also pass, ten focused tests total, plus format/fatal selected analysis. Existing large-number2.12/Unicode ordering2.13/large-slice end overflow2.14 remain separately owned. No full suite/matrix/standalone/complete portable/domain admission; existing regex/other carrier scalarization is preserved rather than promoted.
  - [x] LOCKSTEP: Retained producer/shared/slice/mutation tests, frozen/current qualified catalog/guide and canonical Dart/String/null facts/map plus task/live/resume align. P2 assessment20 has exact reproduction, impact, mandatory schedule and repair ownership before23.4; no width/Bool universal promise. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia19.4 independently assesses next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.19.3 - preserve Dart scalar String result kinds`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.19.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia ordinary scalar String-helper result flow and boundaries.
  Dependencies: .23.3.19.3.
  Acceptance: Follow scalar-string-results.md; preserve eight helper domains/null/empty/Unicode/strict cat policies, actual identity Number/Boolean/String kinds, source-first once-only operands/snapshots and scalar/generic/numeric/explicit Array bridges. Clean incompatible-consumer and malformed-shape boundaries retain permitted effects and skip forbidden ones. Public producer-first native/generated RED/GREEN plus small direct String/compile checks/docs/commit; no free signature/selector/callback normalization or full admission.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and retained result/effect/kind/shape controls, small direct String regression/source compilation/book/continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `ebe047c11996a5f87c16777d4538cd8e022e79e7`; Dart scalar String fixes/qualified domain20 schedule committed, brief0/tree clean.
  Owned paths: Julia independently confirmed scalar String-helper producer/result/scalar/shape and qualified slice flow, retained public native/plan/fresh diagnostic and strict result/identity/selector/slice/mutation regression, runner and scoped book/facts/task/live docs. Preserve free domains/Unicode/strict cat/callbacks/formats and observed width/Bool conventions pending20; no inferred backend failures.
  Verification tier: `focused`
  Focused checks: Public producer-first native/plan/fresh and strict shared/kind/shape RED/GREEN, direct selected/default checks as warranted, strict compilation and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: Retained public probe observes all native/plan/fresh routes before code: identities are six String0 then abc/bc/abc/abc, numeric selector producers/shared abort with typed harray-vs-array, boundaries give[[],SCA,null,SAC]. Substring source/start null and fractional normalization already work; provided-null width is omitted, Bool offset keeps1 (abc/SIL/abc/a/empty/empty/bc). Both mutation aliases pass. Own identity/null operand/scalar/shape repairs here; preserve those qualified slice conventions under20 and existing large-slice2.10 owner. Add a healthy basic String/Unicode/SON control before implementation; do not infer unreturned shared fields.

  Completion: Preserve Number/Boolean original identities in empty-old replacement/empty-unmatched affix removal while other scalarized carriers retain text; guard explicit null operands without changing non-null scalarization. Add eight-method scalar-result tuple and precise receiver preflight. Fractional/null source/start slicing already works; preserve provided-null-width-as-omitted and Bool-offset1 conventions under scheduled20, with no substring/global int change.
  Verification:
  - [x] REPRODUCE / ISSUE: Public native/plan/fresh probe independently returns textified identity/null data, typed selector errors on producer/shared and boundary[[],SCA,null,SAC]. Healthy basic String/Unicode/strict-null/SON tests pass3 before code. Strict RED captures15 failures/two producer errors; bounds/mutation routes already work and their data is not inferred from Dart.
  - [x] ROOT CAUSE (WHY + WHERE): _call_runtime_replace_substr/_call_runtime_remove_edge return coerced text and null_as_empty masks explicit null operands. Common _evaluate_runtime_fluent_chain! omits eight methods in scalar tuple/shapes. Ordinary substring already normalizes fractions/null source/start, with its own qualified optional-width/Bool conventions.
  - [x] FIX: Supported scalar originals on identity (Number includes Bool; strict tests distinguish them), positional null guards retaining other conversion compatibility, eight-method scalar/ordinary shape tuples and runner registration. No global numeric/int/selector/Unicode/free signature/regex/callback/named-context/schema change; dedicated mutation routes stay.
  - [x] ADDRESSED (verified): Registered new54 native/plan/fresh assertions pass all seven groups: healthy/identity/null producers, boundary effects, typed free/fluent/named selector producers, shared eight helper values/bridges/empty/null/Unicode/roots, strict Number-not-Bool/false identity/counters and matched String keys, SONC-SC-selectedS snapshots/eager null operands, rejection/12 malformed no-effects, qualified slice domains/SIL and both mutation aliases.
  - [x] NO REGRESSION: Direct selected/nonempty defaults9 pass too,63 assertions with strict compilation. Retained diagnostic basic case executes on all three routes after cleanup of its unused parameter. Existing callback identity2.8/large-number2.9/unsafe large-slice2.10 remain separate; no full suite/matrix/portable admission or blanket producer-domain closure.
  - [x] LOCKSTEP: Retained public probe/test/runner, frozen/current qualified catalog/guide and canonical Julia/String/null facts/map plus task/live/resume align. Domain20 now records Julia width-omitted/Bool1 separately from Dart width-omitted/Bool0 and Perl/Rust null-width/Bool1; mandatory schedule stays after19.5 before admission. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Safe Lua19.5 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.19.4 - preserve Julia scalar String result kinds`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.19.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua ordinary scalar String-helper result flow and boundaries.
  Dependencies: .23.3.19.4.
  Acceptance: Follow scalar-string-results.md; preserve eight helper domains/null/empty/Unicode/strict cat policies, actual identity Number/Boolean/String kinds, source-first once-only operands/snapshots and scalar/generic/numeric/explicit Array bridges. Clean incompatible-consumer and malformed-shape boundaries retain permitted effects and skip forbidden ones. Public producer-first native/generated RED/GREEN plus small direct String/compile checks/docs/commit; no free signature/selector/callback normalization or full admission.
  Safety scope: Only safe available PUC5.5.1/LuaJIT fixtures; exclude malformed native patterns/full runner. Declared5.4 remains separately owned.
  Planned verification tier: focused
  Planned focused checks: Public producer-first native/generated and retained result/effect/kind/shape controls, small direct String regression/source compilation/book/continuity.
  Planned canonical trigger: Full admission/final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Activation: clean `1b69aba951d1e9748988e652430988e6f92ca584`; Julia scalar String fixes/qualified domain20 inventory committed, brief0/tree clean.
  Owned paths: Lua independently confirmed scalar String producer/result/scalar/shape and qualified slice flow, safe retained public native/plan/fresh diagnostic/test and named runner registration, scoped book/facts/task/live docs. Preserve module-local ceiling/free domains/Unicode/strict cat/callbacks/formats; observe width/Bool conventions under20. Only safe PUC5.5.1/LuaJIT; no full runner/malformed native patterns.
  Verification tier: `focused`
  Focused checks: Safe public producer-first native/plan/fresh and strict result/kind/shape RED/GREEN, direct selected/default fixtures/source loads on both hosts, book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary implementation under director feature-first cadence; declared5.4/full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regressions/preservation controls, no population/completeness measurement.

  Independent intake: After correcting the diagnostic metadata row to public json.harray (plain tables are intentionally ambiguous), both hosts pass basic String/Unicode/strict-null/SON on native/plan/fresh. All routes show textified identity/null data, typed producer/shared selector failures and boundaries[[],SCA,null,SAC]. Slice source/start null/fractions and both mutation aliases already work; width-null is omitted and Bool offset invalid0, matching Dart's qualified conventions under20. Own producer identity/null/scalar/shape repairs here; no result inferred from another backend. The same ordinary substring branch adds start+width before clipping; assess a single safe large-width public distinction before changing that arithmetic, without a magnitude matrix or malformed patterns.

  Owned P1 substring defect: Safe public large_end/native-plan-fresh gives PUC[abc,empty,empty] versus LuaJIT[abc,bc,bc] for width9223372036854775807 at offsets0/1. This matches the published clipping contract/retained primary large-slice reference; current start+width wraps the PUC integer before character conversion. Fix the small ordinary String interval by clipping against remaining character length before addition; keep global integer/argument-domain/regex mutation policies unchanged. Strict new test independently observes large-end RED on PUC and identity RED on LuaJIT after healthy producer controls.

  Completion: Preserve Number/Boolean identity (explicit branches retain false) for empty-old replacement/empty-unmatched affixes, guard explicit null operands retaining other scalarization, and add eight-method scalar/ordinary shape guards without new module locals. Clip ordinary substring width to remaining characters before addition, with early out-of-range empty result, fixing PUC wrap while preserving slice domains/dedicated mutation.
  Verification:
  - [x] REPRODUCE / ISSUE: Both safe hosts pass independent native/plan/fresh basic String/Unicode/strict-null/SON. All routes reproduce textified identity/null data, typed producer/shared selector failures and[[],SCA,null,SAC]. PUC large_end gives[abc,empty,empty] versus LuaJIT[abc,bc,bc]; strict test RED distinguishes large-end/identity failures after healthy controls. Initial plain-table diagnostic encoding error is corrected with json.harray and not credited as semantic evidence.
  - [x] ROOT CAUSE (WHY + WHERE): Pure string helper branches return scalarized text and mask explicit null operands, while fluent scalar/shape lists omit eight methods. Ordinary substr adds start+width before clipping, wrapping the PUC integer at nonzero start. Existing source/start null/fraction rules, null-width-as-omitted/Bool-invalid0 and mutation routes already work.
  - [x] FIX: Supported primitive identity returns without Lua and/or false loss, explicit null guards, existing scalar-result/shape lists and bounded character interval clipping before addition. No new module locals/global integer/numeric/selector/Unicode/free arity/regex/callback/format or aggregate-domain normalization. Preserve current width/Bool conventions for20.
  - [x] ADDRESSED (verified): Both PUC5.5.1/LuaJIT pass strict canonical JSON native/plan/fresh across eight retained groups: healthy/identity/null/index producers, large-end free/receiver clipping, boundary effects, shared eight helper results/bridges/empty/null/Unicode/source roots/identity-matched keys, SONC-SC-selectedS/eager null snapshots, rejection/12 malformed no-effects, qualified SIL/slice domains and both mutation aliases.
  - [x] NO REGRESSION: Direct selected/nonempty defaults and interpreter/runner source loads pass both hosts. No full runner/malformed native patterns, declared5.4, magnitude matrix, complete portable/domain admission or Dart/Julia large-slice repair claim. Existing source scalarization and callback behavior stay on their published routes.
  - [x] LOCKSTEP: Retained public probe/test/safe runner, frozen all-five bounded progress, current qualified catalog/guide and canonical Lua/String/null facts/map plus task/live/resume align. Domain20 records both Lua hosts' width-omitted/Bool0 convention and now owns the immediate next action before portable admission. Book/history/diff/final staged memory/cadence/diagnosis checked before commit.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.19.5 - preserve Lua scalar String kinds and slice bounds`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4.1`
  Status: `pending` / P1 canonical admission prerequisite
  Goal: Register new bounded Perl feature regressions in canonical CI before full admission/final push.
  Existing authority: docs/knowledge/perl-receiver-copy-canonical-selection.md states the runner uses exact explicit suites; future files require registration, with historical inverse/custody constraints.
  Reproduction: rg -n -F -e 't/string_predicate_result_receiver_contract.t' -e 't/emptiness_result_receiver_contract.t' -e 't/has_key_result_receiver_contract.t' tools/run_ci_local.sh returns no matches/exit1 after these fixtures are introduced. This confirms omission of these named direct selections; no complete omission population has been measured.
  Impact / ownership: Direct focused runs protect current feature commits, but merely retaining new t files does not add their execution to the final canonical receipt. This includes t/defined_default_receiver_contract.t, t/scalar_string_result_receiver_contract.t, t/reduction_result_receiver_contract.t, t/tagged_record_producer_contract.t, t/tagged_record_receiver_contract.t, t/logical_receiver_method_contract.t, t/computed_selection_noncall_contract.t, t/computed_selection_callable_compat.t and t/computed_selection_deferred_boundary.t; the approved primitive-copy producer/receiver add t/value_copy_function.t, t/value_copy_receiver.t and t/value_copy_interpreted.t. This owner must inventory all newly added feature fixtures/helpers, classify actual selection and repair every omission before admission/push; do not infer completeness from the three named controls.
  Schedule: Mandatory after feature coverage, before23.4 admission and before final clean push; no full-CI/policy detour during ordinary implementation.
  Acceptance: Inventory current feature fixtures and all producer/artifact inputs; add exact tracked-presence/syntax/execution selection through the published canonical runner/historical-inverse contract. Distinguish direct/indirect coverage; retain targeted selector RED/GREEN and actual full canonical receipt for exact staged candidate. Update runner docs/fact/card/current task records and commit as an infrastructure leaf before push.
  Planned verification tier: canonical; declare claim/inputs and focused selection at activation.


- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.20`
  Status: `active` / all bounded repairs targeted-checked; full admission separate
  Goal: Align three backend ordinary slice paths with existing Perl-reference optional/null/Boolean argument behavior.
  Dependencies: .23.2.20 substring-optional-arguments.md.
  Children: `.23.3.20.1` Dart, `.23.3.20.2` Julia, `.23.3.20.3` safe Lua.
  Acceptance: Preserve omitted versus explicit null, helper-specific Boolean1/0, source capture/eager SIWC, integer/fractional/negative/Unicode rules and dedicated mutation paths. Do not change global numeric converters/selectors/free arities or assert complete portable admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.20.1`
  Status: `completed`
  Goal: Repair Dart ordinary substring optional argument parity.
  Dependencies: .23.2.20.
  Acceptance: Follow substring-optional-arguments.md and shared reference fixture. Null width and Boolean start/width conversion; native/restored/plan. Independent RED/GREEN, direct scalar String/mutation and small compile checks; sync book/facts/task/live and commit before next backend. Full signature/context/portable admission remains23.4.
  Planned verification tier: focused
  Planned focused checks: Shared argument/effect fixture, direct scalar String controls and selected compilation/format, current book/history/staged continuity guards.
  Planned canonical trigger: None for bounded existing-ADR0006/0023 reference repair under director feature-first cadence; full admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `2bb2643d49498a7803466808502ad3d276d51de6`; frozen optional argument target committed, brief0/tree clean.
  Owned paths: Dart ordinary _callSubstr null-width/Boolean argument distinction, shared reference and direct scalar String tests/retained diagnostic; scoped frozen ledger/book/canonical facts/task/live continuity. Preserve global _intValue, free unary/extra-arity and dedicated mutation behavior.
  Verification tier: `focused`
  Focused checks: New shared native/restored/plan RED/GREEN, direct scalar String including named mutation/Unicode/eager effects and legacy arity controls, selected format/fatal analysis, book/history/staged continuity guards.
  Canonical trigger: None for bounded existing ADR0006/0023 reference repair under director feature-first cadence; full signature/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Completion: _callSubstr distinguishes a provided null width at ordinary three-argument arity and locally converts Bool slice arguments to1/0 only for supported ordinary two/three-argument forms. Global _intValue, numeric/selector conversion and existing unary/extra-argument behavior remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Shared reference test RED gives bc for null widths, abc/empty for true starts/widths and [abc!,SIWC,1,null]/[!,SIWC,1,null] rather than reference null/b!. Independent native/restored/plan observations were retained in20; legacy unary/extra-argument preservation test already passes before production.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart _callSubstr maps a provided null width to omitted and delegates Bool arguments to rejecting global _intValue. Eager operand staging/source capture already works, so repair the helper body only.
  - [x] FIX: Ordinary explicit-null width guard plus local Bool1/0 offset branch; preserve fractional/negative normalization and all other call arities. Update the older qualified substring expectations to the frozen reference; no global converter/selector or mutation change.
  - [x] ADDRESSED (verified): New shared fixture passes native/restored/plan with omitted/null/Bool/integer/text/fraction/negative/source-start-null distinctions and captured SIWC/one-source effects. Explicit legacy free unary/extra-arity controls remain passing; defined-width chain gives b!, present-null chain null.
  - [x] NO REGRESSION: New2/direct scalar String7 tests pass (nine total), preserving Unicode, identity kinds/typed Array indices, source roots/bridges, eager SIL/SONC/rejected prefix effects,12 malformed no-effects and both named regex mutation aliases. Selected runtime/tests format and fatal analysis pass. No full gate/large-slice2.14 repair or portable admission.
  - [x] LOCKSTEP: Frozen ledger/current book progress, canonical optional-argument/Dart facts/map and TYPE/SESSION/live/resume align; book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia20.2 next, safe Lua20.3 follows; broader signature/61.3/23.4 remain open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.20.1 - align Dart substring optional arguments`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.20.2`
  Status: `completed`
  Goal: Repair Julia ordinary substring optional argument parity.
  Dependencies: .23.3.20.1.
  Acceptance: Follow substring-optional-arguments.md and shared reference fixture. Null width distinction only; Boolean conversion already correct; strict native/plan/fresh. Independent RED/GREEN, direct scalar String/mutation and small compile checks; sync book/facts/task/live and commit before next backend. Full signature/context/portable admission remains23.4.
  Planned verification tier: focused
  Planned focused checks: Shared argument/effect fixture, direct scalar String controls and selected compilation/format, current book/history/staged continuity guards.
  Planned canonical trigger: None for bounded existing-ADR0006/0023 reference repair under director feature-first cadence; full admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `557efd381a16033fab2b5090d0104d2cf46a1f74`; Dart argument repair committed, brief0/tree clean.
  Owned paths: Julia ordinary _call_runtime_substr explicit-null width guard, strict shared/native-plan-fresh test/registration and direct scalar String expectation update; frozen ledger/book/Julia/optional-argument facts/task/live continuity. Existing Boolean argument conversion already correct; no global converter/free arity/selector/mutation or unsafe large-slice2.10 repair.
  Verification tier: `focused`
  Focused checks: New shared native/plan/fresh RED/GREEN with strict counter kinds and legacy arity controls, direct scalar String including Unicode/eager effects/named mutation, strict compilation and book/history/staged continuity guards.
  Canonical trigger: None for bounded existing ADR0006/0023 reference repair under director feature-first cadence; full signature/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Completion: Ordinary three-argument _call_runtime_substr now returns nothing for explicit null width before the unchanged character slicing body. Existing omitted width, Boolean1/0/global converter and unary/extra-arity paths are preserved; register the shared focused test.
  Verification:
  - [x] REPRODUCE / ISSUE: New strict native/plan/fresh shared reference has three observed value failures: null_width becomes bc/bc and null_effects bc! instead of null. Six counter-kind assertions and three legacy arity controls already pass; Boolean starts/widths and defined-width b!/SIWC are healthy.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl _call_runtime_substr's optional width conditional maps explicitly provided nothing to absence. _runtime_int already accepts Bool via Integer, so no converter repair is necessary.
  - [x] FIX: Add only ordinary three-argument explicit-null guard, update older qualified test expectations/names and register new shared fixture test. Keep all conversion/selector/free-arity/mutation/Unicode and large-slice2.10 behavior unchanged.
  - [x] ADDRESSED (verified): Shared9 and legacy3 strict assertions pass native/plan/fresh after RED. Omitted/null/Bool/integer/text/fraction/negative/source-start-null distinctions and SIWC captured one-source effects now match reference, with counter Number-not-Bool checks.
  - [x] NO REGRESSION: Direct scalar String54 assertions also pass (66 combined), retaining identities/typed indices, Unicode, source roots/bridges, eager SIL/SONC, rejection/12 malformed no-effects and both named regex mutation aliases. Strict compilation passes; no full suite, unsafe large-slice2.10 or portable admission.
  - [x] LOCKSTEP: Registered fixture/frozen ledger/current book progress, Julia/optional argument facts/map and TYPE/SESSION/live/resume align; book/history/diff/final staged memory/cadence/diagnosis checked before commit. Safe Lua20.3 follows; signature/61.3/23.4 remain open.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.20.2 - distinguish Julia null substring width`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.20.3`
  Status: `completed`
  Goal: Repair Lua ordinary substring optional argument parity.
  Dependencies: .23.3.20.2.
  Acceptance: Follow substring-optional-arguments.md and shared reference fixture. Null width and Boolean start/width conversion, preserving false and module-local ceiling; safe PUC5.5.1/LuaJIT native/plan/fresh only. No full runner/malformed native patterns/declared5.4 claim. Independent RED/GREEN, direct scalar String/mutation and small compile checks; sync book/facts/task/live and commit before next backend. Full signature/context/portable admission remains23.4.
  Planned verification tier: focused
  Planned focused checks: Shared argument/effect fixture, direct scalar String controls and selected compilation/format, current book/history/staged continuity guards.
  Planned canonical trigger: None for bounded existing-ADR0006/0023 reference repair under director feature-first cadence; full admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `2a4a655634c0a1971e6d70a42fac476414da8d85`; Julia null-width repair committed, brief0/tree clean.
  Owned paths: Lua ordinary substr branch explicit-null width/local Boolean arguments, strict shared/native-plan-fresh safe test/runner registration and direct String expectation update; frozen ledger/book/Lua/optional-argument facts/task/live continuity. Preserve module-local ceiling/global runtime_integer/free unary-extra arities/regex mutation/clipped intervals. Only safe available PUC5.5.1/LuaJIT; no malformed patterns/full runner/declared5.4.
  Verification tier: `focused`
  Focused checks: Independent both-host new shared/legacy arity RED/GREEN native/plan/fresh, direct scalar String Unicode/kinds/effects/mutation/large-end regression and interpreter/runner source loads, book/history/staged continuity guards.
  Canonical trigger: None for bounded existing ADR0006/0023 reference repair under director feature-first cadence; declared5.4/full signature/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Completion: Ordinary explicit-null width guard and branch-local Boolean1/0 offset conversion now match the frozen reference on both safe hosts. Preserve global runtime_integer, unary/extra-arity behavior, clipped intervals and dedicated mutation; no added module locals. Register the safe shared reference test.
  Verification:
  - [x] REPRODUCE / ISSUE: Independent strict shared test on both PUC5.5.1/LuaJIT observes native null-width bc/bc, Boolean starts abc/abc and widths empty/empty, null effects abc!/SIWC and defined effects !/SIWC. Legacy free unary/extra arities already pass native/plan/fresh; assessment20 separately retained all three-route RED observations.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua pure substr branch maps provided json.null width to omission and delegates Boolean offsets to rejecting runtime_integer. Existing eager values/source capture and safe clipped interval already work.
  - [x] FIX: Three-argument null-width guard and ordinary-arity local offset function with explicit Boolean true1/false0 returns. Keep runtime_integer/free extra arities/character slicing/mutation/module locals unchanged; update older qualified slice expectations and safe runner registration.
  - [x] ADDRESSED (verified): Shared reference and legacy arity groups pass strict canonical JSON native/plan/fresh on both hosts after independent RED. Omitted/null/Boolean/integer/text/fraction/negative/source-start-null controls and SIWC captured source/one call now agree with the fixed Perl/Rust/Dart/Julia reference.
  - [x] NO REGRESSION: Direct eight scalar String groups pass both hosts, retaining Unicode, identity/typed indices, source roots/bridges, eager SIL/SONC, rejection/12 malformed effects, dedicated mutation aliases and prior PUC large-end clipping. Interpreter/runner load checks pass; no malformed native patterns/full runner/declared5.4 or portable admission.
  - [x] LOCKSTEP: Registered fixture/frozen ledger/current book examples, Lua/optional-argument/String facts/map and TYPE/SESSION/live/resume align; book/history/diff/final staged memory/cadence/diagnosis checked before commit. All bounded20 repairs are targeted-checked; return to remaining fluent feature selection23.1.1, with full signature/61.3/23.4 separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.20.3 - align Lua substring optional arguments`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.21`
  Status: `active` / all bounded result implementations targeted-checked; full admission separate
  Goal: Extend ordinary reduce_leaves(initial) immediate receiver blocks with compatible consumers of the actual accumulator kind.
  Dependencies: .23.1.1 reduction-result-continuations.md.
  Children: `.23.3.21.1` Perl, `.23.3.21.2` Rust, `.23.3.21.3` Dart, `.23.3.21.4` Julia, `.23.3.21.5` safe Lua.
  Acceptance: Preserve admitted Array/Hash root traversal, producer/callback scope/copy/order/restoration/errors and invalid-root/shape precedence. Actual scalar/null/Array/Hash results continue through compatible existing methods, with clean incompatible rejection and retained permitted effects. No free helper/global converter/deferred/context/mutation-bang change or complete portable admission.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.21.1`
  Status: `completed`
  Goal: Independently assess and implement/confirm Perl reduction accumulator result continuations.
  Dependencies: .23.1.1.
  Acceptance: Follow reduction-result-continuations.md; producer-first native/generated controls for Number/String/Bool/null/Array/Hash and empty initial kinds, compatible scalar/generic/container selection, source capture/eager initial/callback order/scoped restoration, clean wrong-family rejection and malformed no-effects. Small changed/direct traversal/compile checks/docs/commit per backend. Preserve root-kind traversal/callback errors/free domains and separate full admission.
  Planned verification tier: focused
  Planned focused checks: Independent public producer/result/effect/shape RED/GREEN and direct traversal/source compilation, selected formatting/analysis, book/history/staged continuity guards. Lua safe PUC5.5.1/LuaJIT only; no malformed native patterns/full runner/declared5.4 claim.
  Planned canonical trigger: None for bounded feature implementation under director feature-first cadence; full domain/context/portable admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `bd06af6bdd7040553bb843683fe9c3d3ebfcc675`; reduction result target frozen/committed, brief0/tree clean.
  Owned paths: Perl dedicated reduction result-family/continuation lowering with existing actual-kind bridge, shared data-result/effect/shape/copy fixture and native/fresh regression plus direct admitted traversal controls, current traversal book/fact/map/task/live docs. Preserve callback bodies/root-kind traversal/global converters and dedicated mutation routes; no scoped/deferred/context expansion.
  Verification tier: `focused`
  Focused checks: Retained public producer/nested/terminal/effect/shape RED, new shared native/fresh data-kind/actual-consumer/scoped restoration/order/rejection/shape/copy RED/GREEN, small direct Array/Hash walk/map traversal controls and syntax/book/history/staged continuity guards.
  Canonical trigger: None for bounded frozen feature under director feature-first cadence; full domain/context/portable admission/final clean push separate.
  Claim verification: none: deterministic authored regressions/preservation controls; no population/completeness measurement.

  Owned implementation regression: First new feature run enables every shared value/kind/copy/scope/order/malformed/invalid-root field and direct wrong-family SIL rejection, but native/fresh prefix_effects is[null,empty] instead of[null,SILC]. Dedicated tree loop returns plain undef after a scalar-result incompatible tail, discarding the already-valid source/initial/callback/cat prefix. Reproduce via retained rejection_prefix Toolbox case; preserve that prefix once and skip incompatible operand before landing. Both source and expected fields remain fixed; no weakening of fixture.

  Completion: Reduction result classification/lowered pair use the existing default_result actual-kind bridge; first dedicated tree step starts as tree_source rather than prematurely using the result kind. Chains containing reduce stay on dedicated traversal instead of emitted-default bypass. Preserve source/initial/callback code and existing dynamic guards; terminal scalar-consumer rejection now evaluates its valid prefix once.
  Verification:
  - [x] REPRODUCE / ISSUE: Retained public native/fresh producer/nested controls pass, appended links return null and skip effects, appended coalesce leaks raw DSL. New permanent test initially passes six admitted traversal checks and fails result handler/value/fresh-load checks. First implementation fixes all shared fields except prefix effects, which give[null,empty] on native/fresh; Toolbox substitution confirms result=undef and drops the prefix.
  - [x] ROOT CAUSE (WHY + WHERE): MethodLowering tree result classification/pair/Hash metadata marks reduction terminal; first-step family rejection happens before traversal, and emitted-default composition bypasses its callback lowerer. After actual-result composition, the tree loop's plain terminal return still drops an already-valid reduction/cat source prefix.
  - [x] FIX: Reuse existing dynamic actual-kind guard, distinguish input tree step from result family, exclude reduction chains from the generic emitted-default loop and bind the rejected valid prefix once before undef. Callback bodies/root-kind traversal/initial staging/global converters/mutation paths stay intact; no new free helper or deferred/context expansion.
  - [x] ADDRESSED (verified): New shared fixture passes native/fresh Number/String/Array/Hash/false/null/empty initial results, numeric/generic/container selection, named/reversed roots, SI(L*)C source snapshots, callback-scope restoration before consumer, invalid-root initial/callback skipping, malformed no-effects and independent copies. Numeric initial0 remains a valid typed Array write index. Direct wrong-family[null,SIL] and prefix[null,SILC] skip incompatible operand A.
  - [x] NO REGRESSION: Twelve combined checks pass, including admitted Array/Hash walk/map root traversal/copies/sorted-key and index-path order plus unchanged plain reduction; source syntax passes. No full phase0/corpus/gate, callback errors/domain/context/standalone admission or mutation policy claim.
  - [x] LOCKSTEP: Shared fixture/retained probe/frozen progress/current book examples and canonical traversal fact/map, TYPE/SESSION/live/resume align; new Perl fixture explicitly queued in23.4.1 before admission/push. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Rust21.2 independently assesses next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.21.1 - compose Perl reduction accumulator results`.

  Remaining compatible-consumer boundary: The actual-kind bridge explicitly excludes trailing traversal blocks, so exercise an Array accumulator into immediate map_leaves and Hash accumulator into map/reduce before declaring compatible existing methods complete. These are existing immediate callback contracts, not deferred/context expansion. Retained traversal_consumer public case precedes any routing change; keep all work within21.1 until the bounded cases pass.

  Immediate traversal completion: Public traversal_consumer independently observes handler/fresh compile failure near the callback brace. The default_result bridge has no trailing traversal route. A forward-declared existing tree lowerer now handles immediate traversal consumers before generic result guards, preserving its source/root/callback contract. Shared traversal fields[3,B,b,4,4] pass native/fresh: Array and Hash reduction accumulators map with the correct root kind, a pipeline reduction reduces again, and a container selected by coalesce reduces. Final focused test remains twelve assertions with all added fields; source syntax passes. No deferred callback or mutation-bang expansion.
  Continuity maintenance: Required engineering-notes rollover archives exact prior records as segment4954/3557559e9da5; current bounded history check passes without changing immutable older segments.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.21.2`
  Status: `completed`
  Goal: Independently assess and implement/confirm Rust reduction accumulator result continuations.
  Dependencies: .23.3.21.1.
  Acceptance: Follow reduction-result-continuations.md; producer-first native/generated controls for Number/String/Bool/null/Array/Hash and empty initial kinds, compatible scalar/generic/container selection, source capture/eager initial/callback order/scoped restoration, clean wrong-family rejection and malformed no-effects. Small changed/direct traversal/compile checks/docs/commit per backend. Preserve root-kind traversal/callback errors/free domains and separate full admission.
  Planned verification tier: focused
  Planned focused checks: Independent public producer/result/effect/shape RED/GREEN and direct traversal/source compilation, selected formatting/analysis, book/history/staged continuity guards. Lua safe PUC5.5.1/LuaJIT only; no malformed native patterns/full runner/declared5.4 claim.
  Planned canonical trigger: None for bounded feature implementation under director feature-first cadence; full domain/context/portable admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `2eb98f833f712bfeb78d0cdb416060e1905ff72c`; Perl reduction actual-result/immediate traversal feature committed, brief0/tree clean.
  Owned paths: Rust independent ordinary reduction producer/result/shape and callback traversal assessment/repair through native/restored/in-process generated plan, new shared/direct traversal test and any small body fixes justified by concrete observations; current book/frozen/canonical fact/task/live continuity. Preserve root-kind walk/reduce/callback scope/copy/order/errors/global conversion/serialized schema and no standalone/context/deferred admission.
  Verification tier: `focused`
  Focused checks: Public producer-first native/restored/plan RED/GREEN, shared exact result/immediate traversal/shape/rejection/copy/scope snapshots plus direct admitted walk/map/plain reduction, offline compilation/selected rustfmt and book/history/staged continuity guards.
  Canonical trigger: None for frozen bounded ordinary feature under director feature-first cadence; full signature/context/standalone/portable admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Independent intake: Existing accumulator producer and Array/Hash walk/map/plain-reduce tests pass native/restored/plan before production. Shared test instead stops at compile with callable_contract_arity_mismatch for malformed zero-initial reduction; Core compile enforces the admitted final-codeblock signature. Preserve that existing compile-time policy rather than forcing Perl's runtime-null form. Own separating malformed controls from the valid shared fixture, retaining them in backend-specific permanent tests (including moving Perl shape checks so no proof is lost), then observe real continuation RED. No signature/diagnostic schema change.

  Actual continuation RED: After separating malformed signatures, shared execution reaches copied=null then reports binding_kind_mismatch at its append. A minimal valid effect control independently gives[null,SILL,1,[9]] instead of[3!,SILLC,1,null]. engine eval_receiver_with_trailing_block_chain explicitly terminates after nonfinal reduce_leaves. Reuse its existing immediate callback/dynamic dispatch while retaining actual-kind container guards before incompatible consumer operands. Malformed callback timing/diagnostic discrepancy is separately owned/scheduled by1.2.1.4.1 before admission; preserve current errors in this feature.

  Owned P1 producer defect: First result-flow implementation passes every valid shared result/kind/traversal/copy/scope/effect/rejection field, but invalid_effects order is SIC rather than SC. Runtime eval_tree_receiver_trailing_block_call evaluates the initial and constructs/requires the callback before matching current root kind. An invalid scalar root therefore runs initial side effects despite the existing invalid-root skip contract. Reproduce non-chained scalar/null controls independently, then guard invalid root after shape validation but before initial/callback evaluation; fix now as a frozen-contract prerequisite, retaining malformed diagnostics and valid traversal behavior.

  Completion: Existing trailing-block chain retains the actual reduction value instead of terminal fencing. Once a reduction has run, later container-only consumers check actual kind before operands, with generic/copy/scalar and scalar min/max overloads preserved. Dedicated immediate map/reduce/with dispatch and callback bodies remain unchanged. A reduction-only invalid-root guard after shape validation now precedes initial/callback evaluation.
  Verification:
  - [x] REPRODUCE / ISSUE: Existing producer and admitted traversal controls pass native/restored/plan. Initial shared fixture exposes preserved Core compile-time callback arity errors; valid-only shared then reaches terminal null and copied binding-kind failure. Minimal order RED[null,SILL,1,[9]] independently confirms skipped consumer. First implementation fixes every valid result/shape/copy/scope/traversal field except invalid-root order SIC; standalone scalar/null RED is[null,null,SII] instead of[null,null,S].
  - [x] ROOT CAUSE (WHY + WHERE): engine eval_receiver_with_trailing_block_chain fences every nonfinal reduction; generic dynamic helper routing lacks actual-kind container admission after that result. eval_tree_receiver_trailing_block_call evaluates reduction initial/callback before matching root kind, contrary to the existing invalid-root skip rule. Core callable_contract separately enforces one initial before final codeblock; preserve those errors under ADR0030/0032, with parity repair owned1.2.1.4.1.
  - [x] FIX: Remove reduction fence, guard incompatible container-only consumers by the actual reduction-derived value before operands, and reject invalid reduction roots before initial/callback evaluation while retaining shape precedence. Existing immediate traversal/callback/copy/order/schema/global converters remain. Separate malformed controls into local permanent backend tests rather than weakening signature validation.
  - [x] ADDRESSED (verified): Six focused Rust tests pass native/CompiledSpec-JSON-restored/in-process plan for producer kinds, valid shared Number/String/Bool/null/Array/Hash/empty results, immediate Array/Hash maps/repeated/coalesced reductions, numeric/default/selection/typed index0, copies, SI(L*)C snapshots/scoped restoration and SIL/SILC rejection without A. Scalar/null roots skip initial/callback on direct/chained routes. Existing compile-time zero/two-initial errors remain.
  - [x] NO REGRESSION: Admitted Array/Hash walk/map/plain reduction/root-kind/path-order controls pass all three routes, offline compilation and selected rustfmt pass. Shared-fixture separation preserves Perl shape coverage in a local group; its eighteen native/fresh reference checks pass. No full suite/corpus/gate, standalone/deferred/context/bang or portable admission.
  - [x] LOCKSTEP: Shared valid fixture/local malformed tests/frozen progress, current book examples/qualifiers, canonical traversal fact/map and TYPE/SESSION/live/resume align; invalid-arity phase/diagnostic parity is explicitly scheduled1.2.1.4.1 before admission. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Dart21.3 independently follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.21.2 - compose Rust reduction accumulator results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.21.3`
  Status: `completed`
  Goal: Independently assess and implement/confirm Dart reduction accumulator result continuations.
  Dependencies: .23.3.21.2.
  Acceptance: Follow reduction-result-continuations.md; producer-first native/generated controls for Number/String/Bool/null/Array/Hash and empty initial kinds, compatible scalar/generic/container selection, source capture/eager initial/callback order/scoped restoration, clean wrong-family rejection and malformed no-effects. Small changed/direct traversal/compile checks/docs/commit per backend. Preserve root-kind traversal/callback errors/free domains and separate full admission.
  Planned verification tier: focused
  Planned focused checks: Independent public producer/result/effect/shape RED/GREEN and direct traversal/source compilation, selected formatting/analysis, book/history/staged continuity guards. Lua safe PUC5.5.1/LuaJIT only; no malformed native patterns/full runner/declared5.4 claim.
  Planned canonical trigger: None for bounded feature implementation under director feature-first cadence; full domain/context/portable admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `339e185d1ec3594f33fc66035857aaf4e359abd0`; Rust result/invalid-root repair and valid fixture separation committed, brief0/tree clean.
  Owned paths: Dart independent ordinary reduction producer/result/immediate traversal/shape/effect assessment and any concrete runtime fixes, new shared-valid/local-invalid native/restored/plan test, selected compile/format/analysis and current book/frozen/Dart/traversal facts/task/live continuity. Preserve callback/root/copy/scope/order/global converters/serialization; current callback error phase remains with1.2.1.4.1 parity owner, no normalization here.
  Verification tier: `focused`
  Focused checks: Independent producer-first native/restored/plan shared/local malformed/direct Array-Hash walk/map/plain reduction and invalid-root/order RED/GREEN, selected format/fatal analysis, book/history/staged continuity guards.
  Canonical trigger: None for frozen ordinary feature under director feature-first cadence; full domain/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Independent intake: Existing producers/direct traversal, source/initial/callback/consumer snapshots, invalid-root skipping and compile-time malformed errors already pass native/restored/plan. Shared values/kinds/immediate traversals/copies/scope all agree except reduced Number.take returns[] and runs operand A (SILA) instead of null/SIL. interpreter _evaluateFluentCallsWithValue omits reduce_leaves from scalar producer metadata; its container checks also distinguish only scalar-result state, not Array versus Hash result family. Own direct wrong-container-family RED before the small result guard, leaving traversal bodies/root/initial/error behavior unchanged. Dart compile-time error phase joins scheduled1.2.1.4.1; no normalization here.

  Completion: Existing dynamic loop already preserves actual reduction values and immediate traversal consumers. Add reduce_leaves scalar producer metadata and a reduction-derived actual-kind guard for Array/Hash-only consumers before their operands. Traversal/root/initial/callback/copy/scope/order/serialization/global conversion bodies remain unchanged.
  Verification:
  - [x] REPRODUCE / ISSUE: Existing producers/direct traversal/source-initial-callback-consumer snapshots/invalid-root skipping and static malformed errors already pass native/restored/plan. Shared RED differs only in direct reduced Number.take: []/SILA rather than null/SIL. Independent opposite-container-family test gives[[],SILKV]/[[],SILA] rather than two null/SIL results; wrong operands K/V/A execute.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.dart _evaluateFluentCallsWithValue omits reduce_leaves from mayProduceScalar and guards only marked scalar results, without distinguishing actual Array from Hash after a reduction. Existing dedicated traversal/dynamic callback paths otherwise compose correctly, including repeated/coalesced reductions.
  - [x] FIX: Register possible scalar reduction result and retain reduction-derived state for actual Array/Hash-only admission before argument evaluation. Preserve generic/copy, numeric overload and existing callback/root/error policies. No new names, grammar, free arity/global converter/deferred/context or mutation-bang behavior.
  - [x] ADDRESSED (verified): Seven native/restored/plan tests pass shared exact Number/String/Bool/null/Array/Hash/empty results, immediate Array/Hash mapping/repeated/coalesced reductions, numeric/default/selection/typed index0, copies and scoped SI(L*)C snapshots. Direct scalar rejection retains SIL; scalar prefix SILC and both opposite-container-family SIL controls skip incompatible operands. Scalar/null roots already skip initial/callback; compile-time malformed errors remain.
  - [x] NO REGRESSION: Admitted Array/Hash walk/map/plain reduction and sorted-key/index path order pass before/after; direct source capture/initial rebind/one source and scoped restoration remain. Runtime/test formatting and fatal selected analysis pass. No full suite/matrix/gate or full signature/context/portable admission.
  - [x] LOCKSTEP: New permanent test/frozen ledger/current book support/error-phase qualifiers, Dart/traversal facts/map and TYPE/SESSION/live/resume align; existing1.2.1.4.1 explicitly includes Dart static errors. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. Julia21.4 independently follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.21.3 - guard Dart reduction result consumers`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.21.4`
  Status: `completed`
  Goal: Independently assess and implement/confirm Julia reduction accumulator result continuations.
  Dependencies: .23.3.21.3.
  Acceptance: Follow reduction-result-continuations.md; producer-first native/generated controls for Number/String/Bool/null/Array/Hash and empty initial kinds, compatible scalar/generic/container selection, source capture/eager initial/callback order/scoped restoration, clean wrong-family rejection and malformed no-effects. Small changed/direct traversal/compile checks/docs/commit per backend. Preserve root-kind traversal/callback errors/free domains and separate full admission.
  Planned verification tier: focused
  Planned focused checks: Independent public producer/result/effect/shape RED/GREEN and direct traversal/source compilation, selected formatting/analysis, book/history/staged continuity guards. Lua safe PUC5.5.1/LuaJIT only; no malformed native patterns/full runner/declared5.4 claim.
  Planned canonical trigger: None for bounded feature implementation under director feature-first cadence; full domain/context/portable admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `0b9046522682d308b26d7935e09b0a279a7ab291`; Dart result-consumer guards committed, brief0/tree clean.
  Owned paths: Julia independent reduction producer/result/immediate traversal/scope/effect/shape assessment and any concrete fixes, strict native/plan/fresh shared-valid/local-invalid test and runner registration, source compilation/current book/frozen/Julia/traversal facts/task/live continuity. Preserve root/callback/copy/order/global conversion/serialization and existing malformed failure phase (parity1.2.1.4.1); no deferred/context/bang expansion.
  Verification tier: `focused`
  Focused checks: Independent producer-first strict Number-not-Bool/false/native-plan-fresh shared/local malformed/direct Array-Hash walk/map/plain reduction, invalid-root/order/opposite-family RED/GREEN, strict compilation/book/history/staged continuity guards.
  Canonical trigger: None for frozen ordinary feature under director feature-first cadence; full signature/context/portable admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Independent intake: All twelve strict producer assertions pass before production; direct traversal/source/scoped order/invalid-root/static malformed controls also pass. Shared native/plan/fresh has three scalar-rejection failures (Any[]/SILA versus nothing/SIL), with strict counter-kind guards healthy. Opposite-container consumers independently give[[],SILKV]/[[],SILA] on all routes. Interpreter.jl fluent loop lacks reduce_leaves scalar metadata and reduction-derived actual container-kind guards; preserve its already-correct traversal/root/callback policies and repair only this boundary. Julia compile-time malformed errors match Rust/Dart and remain with1.2.1.4.1 before admission.

  Completion: Existing dynamic traversal/result loop already composes valid accumulator/immediate callback results. Add reduce_leaves may-produce-scalar metadata and actual reduction-derived Array/Hash consumer guards (including existing Array-only numeric reducers) before operands. Preserve callback/root/initial/copy/scope/order/registry/serialization and all converter bodies.
  Verification:
  - [x] REPRODUCE / ISSUE: Twelve strict producer assertions pass; direct traversal/source-scoped order/invalid-root and compile-time malformed controls also pass before production. Shared native/plan/fresh gives Any[]/SILA at scalar rejection instead of nothing/SIL, with counter kinds healthy. Opposite-family consumers give[[],SILKV]/[[],SILA] on all three routes.
  - [x] ROOT CAUSE (WHY + WHERE): Interpreter.jl fluent loop omits reduction from may_produce_scalar and has scalar state without reduction-derived actual container-family admission. Existing dedicated traversal/callback/root checks already preserve valid results and skip invalid-root initials.
  - [x] FIX: Mark reduction scalar possibilities and guard actual Array/Hash-only consumers before their operands while allowing the existing generic/copy/numeric overload and container transitions. No traversal body, callback scope/copy/order, malformed contract, global conversion or deferred/context/bang normalization.
  - [x] ADDRESSED (verified): Registered forty-three strict native/plan/fresh assertions pass after RED: exact Number/String/false/null/Array/Hash/empty accumulator kinds, Number-not-Bool/false identity/counters, typed index0/copies, numeric/default/selection and immediate/coalesced/repeated traversals, SI(L*)C source capture/scoped restoration, invalid-root skipping and SIL/SILC/opposite-family rejection without operands.
  - [x] NO REGRESSION: Admitted Array/Hash walk/map/plain reduction and sorted-key/index path controls remain passing. Existing compile-time zero/two-initial diagnostics stay; strict package/source compilation passes. No full package/corpus/matrix/gate or full signature/context/portable admission.
  - [x] LOCKSTEP: Registered fixture/frozen ledger/current book support/error-phase qualifiers, Julia/traversal facts/map and TYPE/SESSION/live/resume align;1.2.1.4.1 includes Julia static errors. Book/history/diff/final staged memory/cadence/diagnosis pass. Broader document-pressure check fails on baseline collection/freshness debt; exact intake is retained and1.2.20.1 owns repair before admission/push under the existing feature-first deferral. Safe Lua21.5 independently follows.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.21.4 - guard Julia reduction result consumers`.

  Broader gate disclosure: Resulting-tree README pressure checker exits1 after document mutation self-tests; raw failures/actual staged patch/base and HEAD/index delta evidence are preserved in document-pressure-intake.*. All runtime43 strict tests, source compile, book render and ordinary memory/cadence/diagnosis checks pass. Existing20 schedule expressly defers policy maintenance until feature coverage. Continue Lua21.5;1.2.20.1 remains mandatory before admission/push, with no broad-gate PASS claim. Current CHANGES date/writer recurrence is corrected; historical heading/collection repairs stay owned.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.21.5`
  Status: `completed`
  Goal: Independently assess and implement/confirm Lua reduction accumulator result continuations.
  Dependencies: .23.3.21.4.
  Acceptance: Follow reduction-result-continuations.md; producer-first native/generated controls for Number/String/Bool/null/Array/Hash and empty initial kinds, compatible scalar/generic/container selection, source capture/eager initial/callback order/scoped restoration, clean wrong-family rejection and malformed no-effects. Small changed/direct traversal/compile checks/docs/commit per backend. Preserve root-kind traversal/callback errors/free domains and separate full admission.
  Planned verification tier: focused
  Planned focused checks: Independent public producer/result/effect/shape RED/GREEN and direct traversal/source compilation, selected formatting/analysis, book/history/staged continuity guards. Lua safe PUC5.5.1/LuaJIT only; no malformed native patterns/full runner/declared5.4 claim.
  Planned canonical trigger: None for bounded feature implementation under director feature-first cadence; full domain/context/portable admission/final clean push separate.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `b871c827b492d46d2b71000aeeac38177e613eb4`; Julia result guards43 strict checks committed with broader document-pressure FAIL accurately retained/owned1.2.20.1 before admission, brief0/tree clean.
  Owned paths: Lua independent safe reduction producer/result/immediate traversal/effect/shape assessment and justified small runtime repair; retained malformed-phase probe, strict shared-valid/local-invalid native/plan/fresh test/runner registration, source loads and current book/frozen/Lua/traversal facts/task/live continuity. Preserve false/module-local ceiling/root/callback/copy/scope/order/global converters/current malformed policy. Only safe PUC5.5.1/LuaJIT; no full runner/native malformed patterns/declared5.4 claim.
  Verification tier: `focused`
  Focused checks: Independent both-host producer-first native/plan/fresh strict JSON shared/direct traversal/actual-kind/opposite-family/order/invalid-root/local malformed RED/GREEN, interpreter/runner loads, book/history/staged memory/cadence/diagnosis. Full document pressure repair remains1.2.20.1 under existing post-feature schedule, no repeated broad gate or PASS claim.
  Canonical trigger: None for frozen ordinary feature under director feature-first cadence; full signature/context/portable/declared5.4 admission/final push separate.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement or broad doctrine admission.

  Independent malformed intake: Both safe hosts compile malformed zero/two-initial cases, then native/plan/fresh raise the existing RuntimeInterpreterException helper-arity message (generated routes retain their wrapper prefix). A public diagnostic_sink probe independently captures REDUCTION_ARITY_SOURCE_EFFECT before the zero-initial error on every route. Own this P1 source-before-invalid-signature effect defect here: the fluent preflight omits registered reduction arity and only validates inside evaluate_fluent_calls after receiver evaluation. Invoke existing metadata validation before receiver effects, preserving error class/text/runtime phase; full error parity still belongs1.2.1.4.1. No native malformed patterns are used.

  Independent valid-input RED: Both hosts pass admitted accumulator producers, Array/Hash walk/map/plain traversal and invalid-root skipping on native/plan/fresh. Shared fixture fails at copied binding kind after terminal null; minimal valid order gives[null,SILL,1,[9]] instead of[3!,SILLC,1,null]. Local malformed permanent controls preserve existing runtime error text but observe arity-source before both zero/two-initial failures on every route. Opposite-container tests currently pass only because the terminal fence skips all consumers; retain them through the feature implementation.

  Completion: Remove the nonfinal reduction fence, retain actual reduction-derived kind for container-only consumer guards and preserve scalar-result metadata through compatible bridges. Existing immediate traversal/callback bodies stay. The fluent preflight now calls existing reduction final-codeblock metadata validation before source evaluation, preserving runtime arity messages while fixing source effects. No new module locals.
  Verification:
  - [x] REPRODUCE / ISSUE: Both hosts independently pass producer/root/path/direct traversal and invalid-root controls. Native/plan/fresh shared fails copied binding kind after terminal null; valid order RED[null,SILL,1,[9]] confirms consumer skipped. Public diagnostic_sink and permanent zero/two-initial controls capture source events before existing arity errors on every route. No malformed native regex is used.
  - [x] ROOT CAUSE (WHY + WHERE): interpreter.lua evaluate_fluent_calls terminates after nonfinal reduce_leaves and lacks actual reduction result kind/scalar metadata. Its registered arity validation runs only there, after evaluate_expr has evaluated the receiver; ordinary fluent preflight omits reduction final-codeblock validation.
  - [x] FIX: Continue using actual accumulator, guard Array/Hash-only consumers before operands, mark reduction scalar possibilities with actual-container release and invoke existing reduce metadata validation in preflight before source. Keep callback/root/initial/copy/scope/order/global numeric/Unicode/serialization/mutation paths and existing runtime error class/text/wrappers unchanged.
  - [x] ADDRESSED (verified): Strict canonical JSON shared/native-plan-fresh plus local controls pass both PUC5.5.1/LuaJIT. Exact Number/String/false/null/Array/Hash/empty kinds, typed index0/copies, numeric/default/selection and immediate/coalesced/repeated traversals, scoped SI(L*)C and scalar/prefix/opposite-family rejection retain permitted effects and skip operands. Diagnostic sinks now stay empty for both malformed initial counts while exact arity errors remain.
  - [x] NO REGRESSION: Admitted Array/Hash walk/map/plain reduction/root-kind/sorted-key/index paths and direct invalid-root/source snapshot controls pass. Interpreter/runner source loads pass on both hosts without adding module locals. Only safe named fixtures run; no full runner/unsafe native patterns/declared5.4, full context or portable admission.
  - [x] LOCKSTEP: Safe runner registration/permanent test/probe, frozen progress/current book all-five bounded support and error-phase qualifications, Lua/traversal facts/map and TYPE/SESSION/live/resume align. Lua runtime errors join1.2.1.4.1 diagnostic parity; broad document-pressure FAIL remains owned1.2.20.1 before admission/push, no repeated global-gate PASS claim. Book/history/diff/final staged memory/cadence/diagnosis checked before commit. All bounded21 backend children targeted-checked; next remaining ordinary fluent selection23.1.2.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.21.5 - compose Lua reduction accumulator results`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.22`
  Status: `active` / all five bounded backend children targeted-checked; full admission separate
  Goal: Repair existing split_tagged_records eager value construction and meaningful text-to-Array receiver composition.
  Dependencies: .23.1.2 tagged-record-string-bridge.md; SESSION33 retains broader split-domain/admission authority.
  Children: `.23.3.22.1` Perl prerequisite/receiver, `.23.3.22.2` Rust, `.23.3.22.3` Dart, `.23.3.22.4` Julia, `.23.3.22.5` safe Lua.
  Acceptance: Preserve existing helper domains and current backend pure-split policies, argument snapshots/kinds/copy and normal method min-two-RHS shape. Named/literal/derived String sources feed record Arrays then compatible Array/selected scalar/container methods. Independent native/generated producer-first checks before repair; no full boundary/context/portable admission or source-category method promotion.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.22.1`
  Status: `completed` / bounded eager producer and receiver targeted-checked
  Children: `.23.3.22.1.1`, `.23.3.22.1.2`.
  Goal: Repair the current documented Perl eager helper prerequisite before its scalar receiver bridge.
  Dependencies: .23.1.2.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.22.1.1`
  Status: `completed`
  Goal: Repair Perl tagged-record ordinary eager argument snapshots and pure-split reuse.
  Dependencies: .23.1.2.
  Acceptance: Follow tagged-record-string-bridge.md. Retain actual field/record kinds, source-delimiter-tag-field/consumer order and snapshots/copy, existing helper conversions/pure-split policies and free signatures. Producer22.1.1 repairs once-only/dynamic operand lowering and tagged reuse of the already-admitted split without global boundary normalization; subsequent receiver leaves enforce actual text input/Array output, minimum two RHS and compatible continuation through selected fields. Independent native/generated RED/GREEN, small direct split/record/compile checks/docs/commit. Old33 broad admission remains open.
  Planned verification tier: focused
  Planned focused checks: Authored producer/receiver/result/order/copy/minimum-shape controls and direct existing split/record compatibility, selected compile/format/book/history/staged continuity. Julia strict Number-not-Bool; Lua only safe PUC5.5.1/LuaJIT with no unsafe patterns/full runner/declared5.4 claim.
  Planned canonical trigger: Full split-domain/context/portable admission and final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `267cbeae940f89d73671b3564e6d7b307037e19c`; Git tree clean and git_message_brief.txt zero bytes.
  Owned paths: Perl MethodLowering ordinary split/tagged producer; new focused t/tagged_record_producer_contract.t; existing tagged-record fact/contract, SESSION33 mutable progress/index, current book/live continuity.
  Verification tier: `focused`
  Focused checks: Authored native/fresh eager-order/snapshot/empty/trailing/regex/dynamic-delimiter/kind/copy regression plus direct pure split preservation and Perl syntax; book/history/map/staged continuity.
  Canonical trigger: Full SESSION33 domain/context matrix, signature parity1.2.1.4.1 and pressure20.1 repairs before later admission/push.
  Claim verification: none: deterministic authored examples and producer regression; no aggregate measurement or portable completeness claim.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Public LinkedSpec::Get/runtime_ctx_ref/fresh emitted regression observes per-row increments, zero empty-result effects, missing trailing items, variable delimiter treated literally and raw tag/delimiter DSL; initial prove reports9 failures/28.
  - [x] **ROOT CAUSE (WHY + WHERE)**: MethodLowering split_tagged_records emitted carried expressions inside map, used a separate split without -1 and normalized tag/delimiter text without lowering eager blocks. Dump/substitution demonstrates the exact emitted mechanism.
  - [x] **FIX**: Stage all ordinary operands in host temporaries before record construction; lower dynamic delimiter/tag expressions while retaining tag atoms; share _emit_split_value_expr with ordinary split. Preserve existing value/DSL copy bounds.
  - [x] **ADDRESSED (verified)**: prove -q -Iperl t/tagged_record_producer_contract.t PASS36 native/fresh assertions, including SDTF and prior-field/source/delimiter/tag snapshots, empty/trailing/regex/dynamic controls.
  - [x] **NO REGRESSION**: Direct pure split, tag atom/number coercion, actual Bool/null/Array/Hash fields and source/row DSL copy controls PASS; MethodLowering perl -c PASS. No receiver/global-domain/schema changes.
  - [x] **LOCKSTEP**: Book/current fact/frozen contract/SESSION33 partial progress and refreshed index/live memory/history/map align; new fixture included in23.4.1 registration owner. Broad admission and known pressure20.1 remain separately disclosed.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.22.1.1 - stage eager Perl tagged-record arguments`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.22.1.2`
  Status: `completed`
  Goal: Repair Perl scalar/String-result to tagged-record Array receiver composition.
  Dependencies: .23.3.22.1.1.
  Acceptance: Follow tagged-record-string-bridge.md. Retain actual field/record kinds, source-delimiter-tag-field/consumer order and snapshots/copy, existing helper conversions/pure-split policies and free signatures. Producer22.1.1 repairs once-only/dynamic operand lowering and tagged reuse of the already-admitted split without global boundary normalization; subsequent receiver leaves enforce actual text input/Array output, minimum two RHS and compatible continuation through selected fields. Independent native/generated RED/GREEN, small direct split/record/compile checks/docs/commit. Old33 broad admission remains open.
  Planned verification tier: focused
  Planned focused checks: Authored producer/receiver/result/order/copy/minimum-shape controls and direct existing split/record compatibility, selected compile/format/book/history/staged continuity. Julia strict Number-not-Bool; Lua only safe PUC5.5.1/LuaJIT with no unsafe patterns/full runner/declared5.4 claim.
  Planned canonical trigger: Full split-domain/context/portable admission and final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `3510336e09dac9f741a2bcdd220a46302d60eab9`; producer committed; tree clean and brief0.
  Owned paths: Perl String/selected-result receiver lowering and malformed minimum-shape preflight; shared authored tagged-record receiver fixture and Perl native/fresh test; current book/fact/contract/SESSION33 index/live continuity.
  Verification tier: `focused`
  Focused checks: Native/fresh valid literal/named/derived String-to-Array/selected-field continuation, eager order/snapshots/kinds/copy, malformed two-RHS minimum before effects, direct producer and String-result checks, source syntax/book/history/staged guards.
  Canonical trigger: SESSION33 full split-domain/context/portable admission, fixture registration23.4.1, signature parity1.2.1.4.1 and pressure20.1 before later admission/push.
  Claim verification: none: deterministic authored regression and preservation examples; no aggregate/completeness measurement.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Retained public LinkedSpec::Get/runtime_ctx_ref/call_spec_handler_subst intake shows valid literal/named receiver raw DSL/undefined host split_tagged_records and trim-prefix null; malformed eager receiver operands also fail host compilation.
  - [x] **ROOT CAUSE (WHY + WHERE)**: MethodLowering _string_receiver_value_chain_return_family omits the tagged helper despite its text input/Array output. AST/compatibility chains lack its minimum two-RHS preflight; result category in aggregate registration is not an input guard.
  - [x] **FIX**: Register tagged records beside split in the String-to-Array return-family route; add AST/compatibility minimum-operand preflight before lowering effects. Reuse the repaired eager producer and existing Array/selected-value continuations.
  - [x] **ADDRESSED (verified)**: t/tagged_record_receiver_contract.t PASS12 native/fresh assertions for shared valid literal/named/trim/regex/selected Number/Bool/null/Array/Hash results, SDTFCE snapshots and malformed shapes without effects. Corrected new fixture spelling to established named-Array selection and false-preserving coalesce; the older definedness contract explicitly retains Perl numeric1, so this feature does not normalize it.
  - [x] **NO REGRESSION**: t/tagged_record_producer_contract.t and t/scalar_string_result_receiver_contract.t PASS43 combined; MethodLowering perl -c PASS. No free signature/domain/global selector/schema change.
  - [x] **LOCKSTEP**: Current book/record fact/frozen contract/SESSION33 partial progress/index/map/history/live pointer align; shared fixture and new Perl regression are owned for canonical registration23.4.1. Full split-domain/admission/error parity/pressure repair stay separately scheduled.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.22.1.2 - bridge Perl String receivers to tagged records`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.22.2`
  Status: `completed`
  Goal: Independently assess and repair/confirm Rust tagged-record text-to-Array bridge.
  Dependencies: .23.3.22.1.2.
  Acceptance: Follow tagged-record-string-bridge.md. Retain actual field/record kinds, source-delimiter-tag-field/consumer order and snapshots/copy, existing helper conversions/pure-split policies and free signatures. Producer22.1.1 repairs once-only/dynamic operand lowering and tagged reuse of the already-admitted split without global boundary normalization; subsequent receiver leaves enforce actual text input/Array output, minimum two RHS and compatible continuation through selected fields. Independent native/generated RED/GREEN, small direct split/record/compile checks/docs/commit. Old33 broad admission remains open.
  Planned verification tier: focused
  Planned focused checks: Authored producer/receiver/result/order/copy/minimum-shape controls and direct existing split/record compatibility, selected compile/format/book/history/staged continuity. Julia strict Number-not-Bool; Lua only safe PUC5.5.1/LuaJIT with no unsafe patterns/full runner/declared5.4 claim.
  Planned canonical trigger: Full split-domain/context/portable admission and final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `6a4d00d01c63ee06dbb9fda3589ff032add25282`; Perl producer/receiver committed; tree clean/brief0.
  Owned paths: Rust independent public producer/receiver tests and any bounded helper/String-result routing repair, current frozen contract/book/tagged fact/SESSION33 partial progress/index/live continuity.
  Verification tier: `focused`
  Focused checks: Native/restored/in-process generated plan producer-first/shared valid/eager order/copy/current malformed shape controls, direct pure split/source compile/rustfmt and book/history/staged guards. No standalone generated crate/full matrix.
  Canonical trigger: SESSION33 full split-domain/context/portable admission and signature parity1.2.1.4.1/pressure20.1 repairs before final admission/push.
  Claim verification: none: deterministic authored regression and preservation controls; no population/completeness measurement.

  Independent intake: Current public native producer/shared tests fail with unknown helper split_tagged_records warnings and null. Source/dynamic delimiter/tag/field effects already evaluate eagerly in order, but engine call_helper_with_args lacks the producer arm and its String-to-Array classifier omits the method. Both are bounded prerequisites within22.2; preserve each existing pure-split boundary and the current malformed ordinary-method null policy.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Public Rust native producer/shared tests emit unknown helper split_tagged_records warnings and null records/results despite once-only eager argument effects; focused cargo test RED0/2.
  - [x] **ROOT CAUSE (WHY + WHERE)**: engine.rs call_helper_with_args has no tagged-record arm; is_string_receiver_array_returning_method only recognizes split. The generic unknown fallback returns Undef after argument evaluation; record producer and routing are both missing.
  - [x] **FIX**: Construct fresh record Arrays from existing split_string_for_arg items and captured text tag/typed fields; register String-to-Array receiver role and min-two-RHS preflight. Preserve pure split/free malformed behavior and existing owned-value snapshots.
  - [x] **ADDRESSED (verified)**: tagged_record_receivers PASS5 native/restored/in-process plan tests: shared named/literal/trim/regex/trailing/typed Number-Bool-null-Array-Hash continuation, SDTFCE snapshots, empty fields once, copied independent rows and prior carried values, receiver malformed no-effects and short free eager null.
  - [x] **NO REGRESSION**: scalar_string_results PASS4 direct tests; offline build/rustfmt/git diff --check pass. Existing pure-split empty/trailing outputs are explicitly retained; no Unicode/converter/AST/schema/callback/mutation change.
  - [x] **LOCKSTEP**: Book/current record fact/frozen contract/SESSION33 partial progress/refreshed index/map/history/live pointer align. Full split-domain/context/portable admission, final canonical selection, error parity and known pressure repair remain separately scheduled; next Dart22.3.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.22.2 - implement Rust tagged-record String bridge`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.22.3`
  Status: `completed`
  Goal: Independently assess and repair/confirm Dart tagged-record text-to-Array bridge.
  Dependencies: .23.3.22.2.
  Acceptance: Follow tagged-record-string-bridge.md. Retain actual field/record kinds, source-delimiter-tag-field/consumer order and snapshots/copy, existing helper conversions/pure-split policies and free signatures. Producer22.1.1 repairs once-only/dynamic operand lowering and tagged reuse of the already-admitted split without global boundary normalization; subsequent receiver leaves enforce actual text input/Array output, minimum two RHS and compatible continuation through selected fields. Independent native/generated RED/GREEN, small direct split/record/compile checks/docs/commit. Old33 broad admission remains open.
  Planned verification tier: focused
  Planned focused checks: Authored producer/receiver/result/order/copy/minimum-shape controls and direct existing split/record compatibility, selected compile/format/book/history/staged continuity. Julia strict Number-not-Bool; Lua only safe PUC5.5.1/LuaJIT with no unsafe patterns/full runner/declared5.4 claim.
  Planned canonical trigger: Full split-domain/context/portable admission and final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `19a24e73f835d80a4fa7ced8ab6f4c877b68109c`; Rust feature committed/tree clean/brief0.
  Owned paths: Dart producer/receiver independent tests and bounded role/pattern/minimum-shape repair if needed; current book/frozen contract/tagged and Dart Array facts/SESSION33 index/live continuity.
  Verification tier: `focused`
  Focused checks: Producer-first native/restored/plan shared valid/eager/copy/shape controls, direct pure split/scalar String tests, Dart format/fatal analysis and book/history/staged guards.
  Canonical trigger: SESSION33 full split-domain/context/portable admission, fixture registration23.4.1/error parity1.2.1.4.1/pressure20.1 repairs before final admission/push.
  Claim verification: none: deterministic authored regression and preservation controls; no population/completeness measurement.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Public Dart native/restored/plan producer/copy/short-free controls PASS3 before changes; shared receiver/shape controls FAIL2. Named/trim results null, regex result aXbxend, malformed values0/[] with SSDC effects.
  - [x] **ROOT CAUSE (WHY + WHERE)**: interpreter.dart _arrayOnlyReceiverHelpers spreads a result-family dispatcher set containing tagged records, so named String source and scalar-result prefixes are forced/rejected as Array input. Generic fluent arguments skip pattern wrapping; preflight has no min-two rule.
  - [x] **FIX**: Derive an unmodifiable actual Array-input set excluding the text producer; add dedicated tagged receiver delimiter _evaluatePatternArgument and ordinary eager remaining fields, plus min-two-RHS preflight. Keep healthy producer/pure splitter/conversions/copy unchanged.
  - [x] **ADDRESSED (verified)**: tagged_record_receivers_test PASS5 native/restored/plan groups including shared typed chains, named/trim/regex/SDTFCE and earlier fields/copied independent rows, malformed no-effects and old short-free empty-array/eager behavior.
  - [x] **NO REGRESSION**: Seven scalar_string_results_test direct tests PASS (combined12); format and fatal analysis PASS after explicit empty-list test type annotations. No parser/schema/global-domain/callback/mutation change.
  - [x] **LOCKSTEP**: Book/frozen contract/current tagged and Dart role facts/SESSION33 partial progress/refreshed index/map/history/live pointer align. Julia22.4 next; full split-domain/context/admission/canonical selection/error parity/pressure remain separately owned.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.22.3 - repair Dart tagged-record receiver roles`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.22.4`
  Status: `completed`
  Goal: Independently assess and repair/confirm Julia tagged-record text-to-Array bridge.
  Dependencies: .23.3.22.3.
  Acceptance: Follow tagged-record-string-bridge.md. Retain actual field/record kinds, source-delimiter-tag-field/consumer order and snapshots/copy, existing helper conversions/pure-split policies and free signatures. Producer22.1.1 repairs once-only/dynamic operand lowering and tagged reuse of the already-admitted split without global boundary normalization; subsequent receiver leaves enforce actual text input/Array output, minimum two RHS and compatible continuation through selected fields. Independent native/generated RED/GREEN, small direct split/record/compile checks/docs/commit. Old33 broad admission remains open.
  Planned verification tier: focused
  Planned focused checks: Authored producer/receiver/result/order/copy/minimum-shape controls and direct existing split/record compatibility, selected compile/format/book/history/staged continuity. Julia strict Number-not-Bool; Lua only safe PUC5.5.1/LuaJIT with no unsafe patterns/full runner/declared5.4 claim.
  Planned canonical trigger: Full split-domain/context/portable admission and final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `521e9d6e882c6c82b0eb34e9cbbc3edc83500be7`; Dart feature committed/tree clean/brief0.
  Owned paths: Julia independent producer/receiver native-plan-fresh test/runner registration and any bounded role/pattern/minimum-shape repair; current book/frozen contract/tagged/Julia facts/SESSION33 index/live continuity.
  Verification tier: `focused`
  Focused checks: Strict Number-not-Bool/false/native-plan-fresh producer/shared/eager snapshot/copy/minimum-shape/free controls, direct split/String/source compilation and book/history/staged guards.
  Canonical trigger: SESSION33 full split-domain/context/portable admission, canonical registration/error parity1.2.1.4.1/pressure20.1 before later admission/push.
  Claim verification: none: deterministic authored regression and preservation controls; no population/completeness measurement.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Julia native/plan/fresh producer-first PASS15; shared trim-prefix null versus3 and malformed0/[]/SSDC generate15 failures among36 strict boundary assertions. Named/literal/regex/copy/free short shapes already retain their behavior.
  - [x] **ROOT CAUSE (WHY + WHERE)**: Interpreter.jl scalar/reduction guards use _RUNTIME_ARRAY_HELPER_NAMES dispatch result classification as actual Array-input requirement, rejecting the text-consuming producer after trim; receiver preflight lacks min-two-RHS check.
  - [x] **FIX**: Derive _RUNTIME_ARRAY_ONLY_RECEIVER_NAMES excluding tagged records, use it only for input guards, and add ordinary minimum shape preflight before receiver/operand/consumer effects. Preserve healthy producer/pattern/conversion/split/free error/copy paths.
  - [x] **ADDRESSED (verified)**: Registered tagged_record_receivers_test.jl PASS51 strict native/plan/fresh assertions: shared typed chains, Number-not-Bool/false/null, SDTFCE, prior fields/copied rows, empty/trailing/regex and malformed no-effects/free short preservation.
  - [x] **NO REGRESSION**: scalar_string_results_test.jl PASS54 direct assertions (combined105) and strict depwarn=error package compilation pass. No global selector/numeric/Unicode/callback/mutation/schema change; git diff --check passes.
  - [x] **LOCKSTEP**: Runner registration, book/frozen contract/current tagged and Julia role facts/SESSION33 partial progress/index/map/history/live pointer align. Safe Lua22.5 next; full split-domain/context/portable admission/error parity/pressure and declared Lua5.4 remain separately owned.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.22.4 - repair Julia tagged-record receiver roles`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.22.5`
  Status: `completed`
  Goal: Independently assess and repair/confirm safe Lua tagged-record text-to-Array bridge.
  Dependencies: .23.3.22.4.
  Acceptance: Follow tagged-record-string-bridge.md. Retain actual field/record kinds, source-delimiter-tag-field/consumer order and snapshots/copy, existing helper conversions/pure-split policies and free signatures. Producer22.1.1 repairs once-only/dynamic operand lowering and tagged reuse of the already-admitted split without global boundary normalization; subsequent receiver leaves enforce actual text input/Array output, minimum two RHS and compatible continuation through selected fields. Independent native/generated RED/GREEN, small direct split/record/compile checks/docs/commit. Old33 broad admission remains open.
  Planned verification tier: focused
  Planned focused checks: Authored producer/receiver/result/order/copy/minimum-shape controls and direct existing split/record compatibility, selected compile/format/book/history/staged continuity. Julia strict Number-not-Bool; Lua only safe PUC5.5.1/LuaJIT with no unsafe patterns/full runner/declared5.4 claim.
  Planned canonical trigger: Full split-domain/context/portable admission and final clean push separate under director feature-first cadence.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `6fa54bd6032fb9ee4d8a0cb5ad8bb9d801a6d0ad`; Julia feature committed/tree clean/brief0.
  Owned paths: Lua safe producer/receiver native-plan-fresh test/runner registration and bounded actual-input-role/minimum-shape repair if observed; current book/frozen contract/tagged/Lua facts/SESSION33 index/live continuity; own next ordinary selection leaf before handoff.
  Verification tier: `focused`
  Focused checks: Strict canonical JSON safe producer/shared/eager/snapshot/copy/minimum-shape/free controls plus direct scalar String and interpreter/runner loadfile only on PUC5.5.1/LuaJIT. No full runner/unsafe regex/declared5.4 claim. Book/history/staged guards.
  Canonical trigger: SESSION33 full split-domain/context/portable admission, canonical registration/error parity1.2.1.4.1/pressure20.1 and Lua5.4 prerequisites before later admission/push.
  Claim verification: none: deterministic authored regression and preservation controls; no population/completeness measurement.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Public safe PUC5.5.1/LuaJIT producer/copy/short-free groups pass before changes; shared trim-prefix gives null versus3 and malformed calls0/[]/SSDC on native/plan/fresh, six route failures per host.
  - [x] **ROOT CAUSE (WHY + WHERE)**: interpreter.lua evaluate_fluent_calls scalar/reduction guards use PURE_ARRAY_HELPERS output-family membership as input requirement. The existing tagged producer consumes text; fluent preflight lacks its min-two-RHS rule.
  - [x] **FIX**: Derive one function-local actual Array-input predicate excluding tagged records and reuse in both guards; add min-two-RHS preflight before receiver/operand/consumer effects. No new module-level local or producer/pattern/split/conversion/copy/free-error changes.
  - [x] **ADDRESSED (verified)**: tagged_record_receivers_test five strict canonical JSON groups PASS both safe hosts/native-plan-fresh: shared typed chains/SDTFCE/regex/empty-trailing, prior fields/independent rows, malformed no effects and short free eager empty Arrays.
  - [x] **NO REGRESSION**: Direct scalar_string_results_test passes both hosts/all routes; interpreter and runner loadfile-only checks pass. No full runner/unsafe native patterns/declared5.4/full context or portable admission claim; git diff --check passes.
  - [x] **LOCKSTEP**: Safe runner registration/current book/frozen contract/tagged and Lua facts/SESSION33 partial progress/refreshed index/map/history/live pointer align. New ordinary selection23.1.3 is owned before handoff; full domain/admission/parity/pressure/declared5.4 remain separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.22.5 - repair Lua tagged-record receiver roles`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.23`
  Status: `active` / all five bounded backend children targeted-checked; full admission separate
  Goal: Add meaningful .and/.or/.not method counterparts using existing eager typed logical helpers.
  Dependencies: .23.1.3 logical-receiver-methods.md; ADR0043/free logical-helper-v1 unchanged.
  Children: `.23.3.23.1` Perl, `.23.3.23.2` Rust, `.23.3.23.3` Dart, `.23.3.23.4` Julia, `.23.3.23.5` safe Lua.
  Acceptance: Generic typed inputs, real Bool output; and/or one-or-more RHS, not zero; once-only eager source/RHS snapshots then compatible consumers, malformed ordinary shapes before effects, valid prefix effects before kind rejection. Preserve free truth/arity/errors/lazy controls and existing copy/conversion/context/deferred/callable/mutation/serialization boundaries. Independent producer-first checks per backend; full public method/domain/context/portable admission remains23.4 after feature coverage.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.23.1`
  Status: `completed`
  Goal: Independently assess and implement Perl ordinary logical receiver counterparts.
  Dependencies: .23.1.3.
  Acceptance: Follow logical-receiver-methods.md. Reuse typed eager producers with source/RHS LTR snapshots, and/or one-plus RHS/not zero, real Bool/false/default/scalar/numeric-rejection/explicit container bridges and actual result kind. Generic existing value domains, pre-effect ordinary malformed method policy, valid prefix effects before incompatible consumers; unchanged free typed errors/truth/lazy/copy/callable/deferred/context/mutation/schema. Small native/generated/direct helper/compile checks/docs/commit, no inferred backend failure. Lua only safe named PUC5.5.1/LuaJIT fixtures/loadfile; no full runner/unsafe patterns/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Independent producer-first/new method typed value/order/snapshot/shape/result RED/GREEN and direct free logical/lazy/source-error/compile/format/analysis controls; current book/history/staged continuity. No full matrix or canonical registry scan.
  Planned canonical trigger: New method/domain/context/portable admission and final push after feature coverage under23.4, including canonical registration/signature parity/pressure repair and Lua declared-host prerequisites.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `a441361ff11e0d9d3b5fe172b342c5ceb84b5918`; logical target/startup routing committed/tree clean/brief0.
  Owned paths: Perl typed AST logical-method normalization and shape preflight; shared authored method fixture/new native-fresh Perl regression; scoped logical target/book/neutral fact/task/roadmap/live continuity. Source helper RuntimeLogical policies remain unchanged.
  Verification tier: `focused`
  Focused checks: New generic typed source/method/order/snapshot/shape/result native-fresh RED/GREEN, existing direct logical result/rejected-consumer/source-error checks and syntax, book/history/staged guards.
  Canonical trigger: New public method/domain/context/portable admission under23.4 after feature coverage, including canonical registration/signature parity/pressure repair; no full suite or registry scan for this ordinary implementation.
  Claim verification: none: deterministic authored regression/preservation examples; no population/completeness measurement.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Public native/fresh method/order/shape/prefix regression RED9/12 leaks raw .and/.or/.not/operand DSL; retained free producer real-Bool controls remain healthy.
  - [x] **ROOT CAUSE (WHY + WHERE)**: MethodLowering lower_ast_fluent_chain_node lacks input-method admission for logical helpers; free typed producer exists. Ordinary scalar/container family rebuilding leaves raw syntax or skips typed result ownership.
  - [x] **FIX**: Validate and/or minimum one RHS and not zero; fold logical links into existing typed call AST, retaining receiver/prefix/RHS nodes and spans, then use existing value/Bool result lowering. Free RuntimeLogical/truth/arity/lazy policies remain unchanged.
  - [x] **ADDRESSED (verified)**: logical_receiver_method_contract.t PASS20 top-level native/fresh tests including source-error subtests, shared real-Bool/kind/text/container/numeric-rejection transitions, SRTC snapshots, prior container values, malformed skip and preserved SR/SRC rejection prefixes.
  - [x] **NO REGRESSION**: Existing logical_result_receiver_contract.t and logical_rejected_consumer_effects.t PASS24; module perl -c passes. Original and0/not2 sources retain typed error/helper/count/arguments_evaluated0 through valid new methods. No host truth/operator, free signature, parser grammar, callback/deferred/context/mutation/schema changes.
  - [x] **LOCKSTEP**: Shared valid fixture/new test/frozen target/book Perl-only method status/current neutral fact/map/roadmap/task/live pointer align. Canonical registration23.4.1 owns the new test; full method/domain/context/admission/parity/pressure remain separate. Rust23.2 independently assesses next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.23.1 - add Perl eager logical receiver methods`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.23.2`
  Status: `completed`
  Goal: Independently assess and implement Rust ordinary logical receiver counterparts.
  Dependencies: .23.3.23.1.
  Acceptance: Follow logical-receiver-methods.md. Reuse typed eager producers with source/RHS LTR snapshots, and/or one-plus RHS/not zero, real Bool/false/default/scalar/numeric-rejection/explicit container bridges and actual result kind. Generic existing value domains, pre-effect ordinary malformed method policy, valid prefix effects before incompatible consumers; unchanged free typed errors/truth/lazy/copy/callable/deferred/context/mutation/schema. Small native/generated/direct helper/compile checks/docs/commit, no inferred backend failure. Lua only safe named PUC5.5.1/LuaJIT fixtures/loadfile; no full runner/unsafe patterns/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Independent producer-first/new method typed value/order/snapshot/shape/result RED/GREEN and direct free logical/lazy/source-error/compile/format/analysis controls; current book/history/staged continuity. No full matrix or canonical registry scan.
  Planned canonical trigger: New method/domain/context/portable admission and final push after feature coverage under23.4, including canonical registration/signature parity/pressure repair and Lua declared-host prerequisites.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `bead1f4cb1b444d3aa2dabe855e268434a20594e`; Perl methods committed/tree clean/brief0.
  Owned paths: Rust independent producer/shared/logical method/native-restored-plan regression and bounded generic-role/arity/result guarding; current contract/book/Rust/neutral facts/roadmap/task/live continuity. No new serialized model, free policy, callback or deferred vocabulary.
  Verification tier: `focused`
  Focused checks: Public producer-first/shared/new-shape/source-error/order/snapshot/result and existing-with-prefix controls, direct existing logical result tests, offline compile/rustfmt/book/history/staged guards. In-process generated plan only.
  Canonical trigger: New method/domain/context/portable admission and final canonical push after feature coverage under23.4, including canonical selection/signature parity/pressure and declared-host prerequisites.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Public Rust producer/source-error controls PASS2 while shared/not/shape/prefix/with controls FAIL4; fallback omits receiver, not reports arity0, malformed and runs source, consumers execute A/KV. After role repair five pass/one with-tail failure remains: producer true/W/outer passes, appended take gives[]/WA/outer.
  - [x] **ROOT CAUSE (WHY + WHERE)**: engine.rs generic predicate/scalar result roles and receiver preflight omit logical methods. Dedicated with/traversal loop guards only reduced values, leaving the new logical Boolean unguarded before container consumers.
  - [x] **FIX**: Admit generic logical methods and scalar results with correct preflight, reusing receiver_call_args and typed producers. Track logical-prefix actual kinds in the existing scoped loop, reject scalar copy only for logical prefixes and permit actual Array/Hash copies. Existing reduction-only copy policy remains unchanged.
  - [x] **ADDRESSED (verified)**: logical_receiver_methods PASS7 native/restored/plan tests including shared typed/SRTC/snapshots, ordinary malformed skip, SR/SRC prefixes, source error/helper/count tokens, existing with restoration and scalar-copy/explicit Array-Hash recovery.
  - [x] **NO REGRESSION**: logical_result_receivers PASS4 direct tests; offline compilation/rustfmt/git diff --check pass. Strengthened exact generated helper_name/actual_arity tokens pass focused source-error rerun. No free truth/arity/error, callback/deferred/mutation or serialized model change.
  - [x] **LOCKSTEP**: New test/shared valid fixture/current book Perl-Rust status/frozen contract/Rust-neutral facts/map/roadmap/task/live pointer align. Canonical selection/new-method/domain/context/portable admission and error parity/pressure/declared-host repair remain separately owned; Dart23.3 next.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.23.2 - add Rust eager logical receiver methods`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.23.3`
  Status: `completed`
  Goal: Independently assess and implement Dart ordinary logical receiver counterparts.
  Dependencies: .23.3.23.2.
  Acceptance: Follow logical-receiver-methods.md. Reuse typed eager producers with source/RHS LTR snapshots, and/or one-plus RHS/not zero, real Bool/false/default/scalar/numeric-rejection/explicit container bridges and actual result kind. Generic existing value domains, pre-effect ordinary malformed method policy, valid prefix effects before incompatible consumers; unchanged free typed errors/truth/lazy/copy/callable/deferred/context/mutation/schema. Small native/generated/direct helper/compile checks/docs/commit, no inferred backend failure. Lua only safe named PUC5.5.1/LuaJIT fixtures/loadfile; no full runner/unsafe patterns/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Independent producer-first/new method typed value/order/snapshot/shape/result RED/GREEN and direct free logical/lazy/source-error/compile/format/analysis controls; current book/history/staged continuity. No full matrix or canonical registry scan.
  Planned canonical trigger: New method/domain/context/portable admission and final push after feature coverage under23.4, including canonical registration/signature parity/pressure repair and Lua declared-host prerequisites.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `2d2407ae204d5c46be5b61476c0a55f45678859e`; Rust methods committed/tree clean/brief0.
  Owned paths: Dart producer-first/shared/new shape/source-error/order/result regression and bounded shared logical composition/receiver preflight; existing-with scope/copy controls; current contract/book/Dart-neutral facts/roadmap/task/live continuity.
  Verification tier: `focused`
  Focused checks: Native/restored/plan producer/shared/malformed/prefix/existing-with-copy/source-error tests and direct logical result checks, source format/fatal analysis/book/history/staged guards.
  Canonical trigger: New method/domain/context/portable admission and final push after feature coverage under23.4, including canonical selection/signature parity/pressure and declared-host prerequisites.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Dart public producer/source-error baseline PASS3; method/shared/shape/prefix/with cases FAIL5 with unsupported fluent and/not. Independent pre-change native/restored/plan and(true).copy()/true.copy()/copy(false) gives true/true/false, establishing local copy compatibility.
  - [x] **ROOT CAUSE (WHY + WHERE)**: interpreter.dart _evaluateFluentCall has no logical method branch and ordinary preflight lacks its shapes. Existing free logical functions combine argument evaluation and Boolean composition; actual Bool/result guards are already healthy.
  - [x] **FIX**: Preflight ordinary positional shapes, stage copied receiver then eager RHS and reuse the same evaluated-value logical composition as free calls. Keep free pre-effect validation/truth/eager loops and existing actual-result/container/copy/scope handling.
  - [x] **ADDRESSED (verified)**: logical_receiver_methods_test PASS9 native/restored/plan tests including shared real Bool/kinds/SRTC/snapshots, malformed no-effects, valid SR/SRC prefixes, with restoration, value copy/Array-Hash recovery and exact native/generated source-error fields.
  - [x] **NO REGRESSION**: logical_result_receivers_test PASS9 direct tests (combined18); format/fatal analysis/git diff --check pass. No free signature/error/truth/lazy/callback/deferred/mutation/serialized model change. Existing Dart scalar copy is retained; new domain reconciliation1.2.1.4.2 owns portable resolution before admission.
  - [x] **LOCKSTEP**: New test/shared fixture/current book three-backend status/frozen target/Dart-neutral facts/map/roadmap/task/live pointer align. Julia23.4 next; full admission/canonical selection/error parity/pressure/declared-host work remain separately owned.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.23.3 - add Dart eager logical receiver methods`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.23.4`
  Status: `completed`
  Goal: Independently assess and implement Julia ordinary logical receiver counterparts.
  Dependencies: .23.3.23.3.
  Acceptance: Follow logical-receiver-methods.md. Reuse typed eager producers with source/RHS LTR snapshots, and/or one-plus RHS/not zero, real Bool/false/default/scalar/numeric-rejection/explicit container bridges and actual result kind. Generic existing value domains, pre-effect ordinary malformed method policy, valid prefix effects before incompatible consumers; unchanged free typed errors/truth/lazy/copy/callable/deferred/context/mutation/schema. Small native/generated/direct helper/compile checks/docs/commit, no inferred backend failure. Lua only safe named PUC5.5.1/LuaJIT fixtures/loadfile; no full runner/unsafe patterns/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Independent producer-first/new method typed value/order/snapshot/shape/result RED/GREEN and direct free logical/lazy/source-error/compile/format/analysis controls; current book/history/staged continuity. No full matrix or canonical registry scan.
  Planned canonical trigger: New method/domain/context/portable admission and final push after feature coverage under23.4, including canonical registration/signature parity/pressure repair and Lua declared-host prerequisites.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `131d8e093e1779b8c6be134d777cd0c552583f08`; Dart methods/copy-domain owner committed/tree clean/brief0.
  Owned paths: Julia independent strict producer/shared/shape/source-error/with-copy tests and runner registration, any bounded ordinary logical preflight/routing repair, current book/contract/Julia-neutral facts/roadmap/task/live continuity.
  Verification tier: `focused`
  Focused checks: Strict Bool identity/Number-not-Bool counters across native/plan/fresh producer/shared/order/snapshot/shape/source-error/existing-with-copy controls, direct logical results and strict compilation/book/history/staged guards.
  Canonical trigger: Full new method/domain/context/portable admission/canonical selection/parity/pressure after feature coverage; scalar-copy1.2.1.4.2 follows logical23 before ordinary coverage closes.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Julia public native/plan/fresh producer/copy PASS12 and valid/diagnostic boundaries PASS91. Malformed methods give1!/0!/1!/SCSCSAC (three failures), and not(fail(...)) reaches the unknown helper (one error).
  - [x] **ROOT CAUSE (WHY + WHERE)**: Interpreter.jl already registers logical pure helpers for fluent value dispatch with copied eager operands and actual Bool guards. _evaluate_runtime_fluent_chain! lacks new ordinary logical method shape validation.
  - [x] **FIX**: Add only positional and/or minimum one RHS/not zero preflight before receiver/operand/consumer effects. Preserve healthy logical dispatch/composition/truth/copy/free typed errors/scopes.
  - [x] **ADDRESSED (verified)**: Registered logical_receiver_methods_test.jl PASS109 strict native/plan/fresh assertions, including malformed skip, unknown operand skip, real Bool, Number-not-Bool counters, SRTC/snapshots, SR/SRC, with restoration/value copy/container recovery and source-error fields/tokens.
  - [x] **NO REGRESSION**: Existing logical_result_receivers_test.jl PASS100; combined209 and strict depwarn=error package compilation pass. No new callback/deferred/context/mutation/serialized model or free policy; git diff --check passes.
  - [x] **LOCKSTEP**: Runner registration/current book/frozen target/Julia-neutral facts/map/roadmap/task/live pointer align. Safe Lua23.5 next; scalar-copy1.2.1.4.2 follows family23, with full method/domain/admission/canonical selection/parity/pressure/declared-host work separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.23.4 - enforce Julia logical receiver shapes`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.23.5`
  Status: `completed`
  Goal: Independently assess and implement safe Lua ordinary logical receiver counterparts.
  Dependencies: .23.3.23.4.
  Acceptance: Follow logical-receiver-methods.md. Reuse typed eager producers with source/RHS LTR snapshots, and/or one-plus RHS/not zero, real Bool/false/default/scalar/numeric-rejection/explicit container bridges and actual result kind. Generic existing value domains, pre-effect ordinary malformed method policy, valid prefix effects before incompatible consumers; unchanged free typed errors/truth/lazy/copy/callable/deferred/context/mutation/schema. Small native/generated/direct helper/compile checks/docs/commit, no inferred backend failure. Lua only safe named PUC5.5.1/LuaJIT fixtures/loadfile; no full runner/unsafe patterns/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Independent producer-first/new method typed value/order/snapshot/shape/result RED/GREEN and direct free logical/lazy/source-error/compile/format/analysis controls; current book/history/staged continuity. No full matrix or canonical registry scan.
  Planned canonical trigger: New method/domain/context/portable admission and final push after feature coverage under23.4, including canonical registration/signature parity/pressure repair and Lua declared-host prerequisites.
  Planned claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Activation: clean `2d035f44d4068fb496c5de3fdb5e421d4e52e10f`; Julia shapes committed/tree clean/brief0.
  Owned paths: Safe Lua independent producer/copy/shared/shape/source-error/with tests and runner registration, bounded logical receiver injection/preflight using existing producer and no new module locals; current book/contract/Lua-neutral facts/roadmap/task/live continuity.
  Verification tier: `focused`
  Focused checks: Strict JSON native/plan/fresh producer/new methods/eager snapshots/shapes/source errors/with-copy and direct logical result checks on PUC5.5.1/LuaJIT; interpreter/runner loadfile only, book/history/staged guards. No full runner/unsafe native patterns/declared5.4.
  Canonical trigger: Full method/domain/context/portable/canonical admission after feature coverage; scalar-copy1.2.1.4.2 immediately follows family23, with other diagnostic/pressure/declared-host prerequisites unchanged.
  Claim verification: none: deterministic authored regression/preservation controls; no population/completeness measurement.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Both safe hosts pass free producer/scalar copy/prefix controls but shared/new logical methods omit source and raise not actual_arity0 on native/plan/fresh. Baseline source-error checks remain healthy.
  - [x] **ROOT CAUSE (WHY + WHERE)**: interpreter.lua fluent dispatcher falls through to free evaluate_call without receiver; ordinary fluent preflight lacks logical positional/minimum shapes. Existing typed truth and actual-Bool result guards already suffice.
  - [x] **FIX**: Extend existing evaluate_runtime_logical with false-safe optional copied receiver and total arity, reuse it for fluent logical calls, and preflight and/or one-plus positional RHS/not zero before source effects. No new module-level locals or free signature/truth policy.
  - [x] **ADDRESSED (verified)**: logical_receiver_methods_test passes eight strict JSON value groups and two typed source errors, each native/plan/fresh on PUC5.5.1/LuaJIT. Shared kinds, eager SRTC/snapshots, real Bool/false/default/container bridges, malformed no-effects, with restoration and copy/recovery pass.
  - [x] **NO REGRESSION**: Direct logical_result_receivers_test passes both safe hosts; interpreter/runner loadfile checks and git diff --check pass. Free typed helper/count/source errors and existing scalar-copy behavior remain; no unsafe patterns/full runner/declared5.4 or broad admission claim.
  - [x] **LOCKSTEP**: Safe runner registration/book/frozen contract/Lua-neutral facts/map/roadmap/task/live pointer align. All five bounded logical backend children targeted-checked; scalar-copy1.2.1.4.2 next, with full admission/canonical/parity/pressure/declared-host prerequisites separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.23.5 - add Lua eager logical receiver methods`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.24`
  Status: `active` / frozen computed-value bracket reads; backend support not admitted
  Goal: Select arbitrary entries/fields from computed Array/Hash values and continue by actual selected kind.
  Dependencies:23.1.4 computed-selection.md and existing signed pure-read/result-family semantics.
  Children:24.1 Perl,24.2 Rust,24.3 Dart,24.4 Julia,24.5 safe Lua.
  Acceptance: Follow frozen read-only source/selector/result/effect rules; preserve named bindings, grouping/lvalues/coercion/copy/callable/deferred/context boundaries. Independent small producer-first/native/generated/direct checks and commit per backend; full portable/context/canonical admission23.4 remains separate.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.24.1`
  Status: `active` / split before commit at the direct-call compatibility boundary
  Goal: Implement the complete Perl ordinary computed-selection target without legacy callable drift.
  Dependencies:23.1.4 computed-selection.md; existing signed/result-path compatibility controls.
  Children:24.1.1 fluent/literal/block reads;24.1.2 direct pure/function calls with preserved callable-result reader/marker.
  Acceptance: Full frozen fixture must eventually pass; direct-call work cannot change four existing frozen result_path outcomes/raw marker1. Keep whole parent open until both bounded children verify/commit, then independently assess Rust24.2. No copy-domain/grouping/lvalue/deferred promotion.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.24.1.1`
  Status: `completed`
  Goal: Implement Perl fluent/literal/immediate-block computed reads while preserving existing direct-call compatibility.
  Dependencies: 23.1.4; computed-selection.md.
  Acceptance: Complete the fluent/literal/immediate-block subset in computed_selection_noncall_values only, including actual selected kinds, negative positions, interleaving/effects and scopes. Preserve four frozen callable-result outcomes and raw1 by retaining existing direct-call paths. Full computed_selection_values and direct pure/helper/function source support stay required in parent24.1/child24.1.2. Named readers, grouping/lvalues/coercions/copy/callable/deferred/format boundaries remain unchanged.
  Planned verification tier: focused
  Planned focused checks: Producer-first source/AST/shared-kind/effect native/generated controls, direct selected/signed regressions and changed-surface compile/format checks; current book/history/continuity only. No full suite/matrix.
  Planned canonical trigger: Full method/source-domain/context/portable and format admission23.4 after feature coverage and final clean push.
  Planned claim verification: none: Deterministic authored feature regression/preservation controls, no population/completeness measurement.

  Activation: clean `b4afbe7bc2897e90b898f844e4dfacd2da5a1425`; computed-selection target committed/tree clean/brief0.
  Owned paths: Perl AST Parser typed value_access/general postfix prefix parsing, MethodLowering typed receiver/segment/result continuation, ValueExpr shared guarded read emitter preserving named output; focused native/fresh/AST test and direct selected/signed controls, current book/contract/fact/map/task/live continuity. No CodeblockRuntime/domain or dependency change.
  Encountered direct-check defect owned: Exact clean b4afbe module preloads reproduce the same three actionir_ast_parser assertions (20/21/22), with original test bytes unchanged. Initial -I overlay was invalid because bootstrap selected working modules; corrected explicit preloads and standard %INC aliases verify all three baseline paths. Git ea6f82c2ac8e216bcfd721a42d10b713a24c5dc1 introduced scalar String result wrapping/minimum-shape null rejection, matching frozen scalar-string-results.md; assertions still require old private trim layout and substr sentinel. Update only those stale assertions to semantic lowered_observation oracles and verify the same component GREEN; do not change correct production to satisfy stale source-layout checks. New value_access must also recurse through declaration/unknown-call collectors and semantic source rendering.
  Verification tier: `focused`
  Focused checks: New shared strict JSON native/fresh and exact typed postfix AST/source spans, source/selector/consumer order and direct selected/signed regression/source syntax; book/history/staged continuity. No broad suite/matrix/canonical registry scan.
  Canonical trigger: Full new source/domain/context/portable admission23.4 after feature coverage; no existing serialized fields or global grouping/lvalue/copy policy movement is planned. Own any discovered format/custody issue before changing it.
  Claim verification: none: Deterministic authored feature/preservation regressions, not a population/completeness measurement.

  Required final compatibility boundary: Existing signed callable-result controls use CodeblockRuntime::read_path and preserve float/string negative rejection plus count-on-missing0/raw marker1. General value_access must not reroute those legacy programs to a different reader or promote their compatibility status; independently probe the four frozen result_path controls before commit and repair any actual drift under this leaf.
  Known environment recurrence: Fast commit guards emit child setpgid EPERM for37469/42122 while their actual required output completes; artifact/memory/cadence/acceptance results are inspected. Existing project-data-liveness-permission-denial fact and SESSION7 own establishment/liveness repair; no new cause/group identity or lifecycle success is inferred and no recovery/purge is run. Record recurrence without a feature-phase wrapper detour.
  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Retained public fluent/Array-literal/Hash-literal/block selections fail handler compilation versus named/typed controls. The wider candidate also changes two frozen callable-result values and raw markers; keep those source forms outside this accepted child.
  - [x] **ROOT CAUSE (WHY + WHERE)**: Parser lacks general typed computed access, MethodLowering lacks result routing and visitors. Including direct Call receivers bypasses CodeblockRuntime::read_path and count-on-missing behavior, and typed recognition removes raw1. Existing ValueExpr guarded rvalue emission supplies the noncall path safely.
  - [x] **FIX**: Add typed noncall value_access/postfix-prefix composition, shared guarded source emission, actual-kind result flow and declaration/unknown-call/semantic-source visitors. Preserve named/direct-call/grouped/lvalue paths. Own direct-call child24.1.2 rather than changing its frozen reader/status or weakening the full target.
  - [x] **ADDRESSED (verified)**: Bounded strict JSON native/fresh noncall regression PASS36 covers six basic sources/alternations, kinds, signed selectors, SIC/IJ effects, guards/container bridges/function locals, AST/spans/quote-regex. Frozen callable compatibility PASS5 top-level (four cases plus selection assertion), native/fresh values1/2/0/0 and raw1 retained. Representative noncall descriptor raw/unresolved/compatibility0 and ready1.
  - [x] **NO REGRESSION**: Parser component PASS24; direct selected scalar/container/indexed-book PASS36 and module syntax/diff pass. Three stale String-era assertions reproduce with clean-base producers and ea6f82c2a authority; retain baseline producer/JSON and replace only those with executed semantic oracles. Initial -I-only baseline was invalidated, then corrected via explicit source preloads. No full deferred-write matrix or broad gate.
  - [x] **LOCKSTEP**: Bounded noncall fixture/current book qualifier, complete full-target fixture for the next child, contracts/causal facts/map/task/live and retained callable RED/restored intake align. New t registrations stay with23.4.1 before admission/push. Parent24.1/direct-call24.1.2 and full context/portable/canonical remain open; copy decision4.2.2 awaits the director.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.24.1.1 - add Perl computed noncall selections`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.24.1.2`
  Status: `active` / P1 prerequisite for complete Perl computed-call selection
  Goal: Add direct pure/helper/typed-function result indexing while preserving existing bound-callable result compatibility.
  Reproduction: Candidate24.1's general typed call access changes frozen result_path_float from0 to2, result_path_string from0 to null and all four raw markers1 to0. Positive/negative integer values1/2 still pass. Public four-case probe confirms the drift; no existing fixture/oracle is refreshed.
  Root cause / schedule: Parser turns every callable result suffix into general value_access; its guarded Array reader bypasses CodeblockRuntime::read_path's prior negative-coercion boundary and generic consumer guards change count-on-missing. Typed recognition also removes the prior raw status. Immediately after24.1.1, before complete Perl/new-surface admission or Rust handoff.
  Acceptance: Distinguish statically owned pure helpers/user functions from legacy bound-callable programs using canonical owners/provenance; enable direct-call typed reads only with preserved existing signatures/truth/scopes/reader/coercion/count/marker behavior. Full computed_selection_values fixture and exact frozen four native/fresh/descriptor controls pass. No promotion or callback/copy/serialized policy change inferred from runtime values. Own any actual metadata/format movement before production; split again if needed.
  Planned verification tier: focused; complete portable/context/canonical admission23.4 remains separate.
  Planned focused checks: Direct pure/helper/function computed selection RED/GREEN plus four frozen callable-result values/raw metadata on native/fresh routes, direct noncall/control tests and changed source syntax/docs/continuity; no full deferred-write matrix.
  Planned claim verification: none: Deterministic finite feature/compatibility controls, not population/completeness measurement.

  Activation: clean `26c8f5daea5b2d0091e77a36bfbde83d7552b38c`; bounded noncall feature committed/tree clean/brief0.
  Owned paths: Direct-call/source-classification and legacy/deferred compatibility intake, then bounded Parser/MethodLowering/RawDependencies/EmitContext changes only after explicit ownership split. Actual accepted source, scope/readiness/provenance/error boundaries must be understood before enabling call receivers. Current contract/book/facts/task/live continuity.
  Additional boundary to establish: Parser value_access recognition is global while CodeblockRuntime lacks that node. Compare ordinary immediate and explicit/contextual deferred source forms before claiming unchanged deferred boundaries; own any newly introduced classification/error drift as a prerequisite rather than admitting new callback vocabulary.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.24.1.2.0`
  Status: `completed` / P1 introduced deferred-body boundary repair
  Goal: Preserve pre-feature explicit deferred parsing/diagnostics/readiness while ordinary computed reads remain supported.
  Parent:24.1.2; prerequisite before further direct-call recognition. Return to approved copy-domain4.2.2 after this bounded commit; direct calls remain queued.
  Activation: clean `26c8f5daea5b2d0091e77a36bfbde83d7552b38c`; current noncall feature is committed.
  Reproduction: probe_computed_deferred_boundary.pl explicit_deferred uses thunk={|| return(["a","b"][-1]) };return(thunk()). Before26c producers report raw1/ready0 and unsupported_codeblock_actionir kind raw_perl on native/fresh; current reports raw0/ready1 and kind value_access. Ordinary computed reads and inline with-blocks now execute correctly; named deferred read control remains healthy. No new deferred vocabulary was intended.
  Root cause: _parse_codeblock_literal_expr parses its body through the same unrestricted _parse_expr; new value_access/postfix recognition therefore changes deferred AST consumed by unchanged CodeblockRuntime. RawDependencies correctly sees typed nodes but cannot infer executor support from them.
  Owned paths: Parser scoped deferred-body grammar fence, small public native/fresh/AST/readiness regression and retained pre-feature/current controls; contract/book/facts/task/live continuity. No CodeblockRuntime/readiness-waiver policy or new deferred execution support.
  Verification tier: `focused`
  Focused checks: Producer-first before/current explicit-deferred diagnosis and exact error/raw/ready restoration, ordinary and named deferred/inline controls, source/span and scope-restoration parsing; focused existing computed/callable tests and syntax/book/history/continuity. No full callback/write matrix or canonical suite.
  Canonical trigger: Complete context/portable/source admission23.4 after feature coverage; no new deferred operation, diagnostics policy or serialized format is adopted here.
  Claim verification: none: Deterministic authored defect/recovery and preservation controls, no population/completeness measurement.
  Acceptance: Preserve old authored deferred AST/raw/error identities without admitting new executable nodes; keep new ordinary and inline computed reads and parser context restoration correct. Original baseline launcher completed all rows but require lacked a true file result (exit2); repair instrument postlude and reverify the distinguishing explicit case before acceptance, not a full-baseline PASS claim.

  Acceptance Checklist:
  - [x] **REPRODUCE / ISSUE**: Public before/current explicit-deferred native/fresh packets distinguish raw1/ready0/kind raw_perl from raw0/ready1/kind value_access; tracked regression raw/readiness/AST RED. Preserve ordinary/inline/named deferred controls rather than admitting literal executor vocabulary.
  - [x] **ROOT CAUSE (WHY + WHERE)**: Parser::_parse_codeblock_literal_expr shares unrestricted body parsing with ordinary expressions. New _parse_value_access_expr therefore changes deferred AST despite unchanged CodeblockRuntime; generic RawDependencies sees typed nodes and omits the former source blocker.
  - [x] **FIX**: Dynamically scope deferred-literal body parsing and fence new computed-access recognition in that scope. Existing ordinary/inline parsing resumes on success or exception. No CodeblockRuntime, dependency-waiver, diagnostic policy or serialized shape change.
  - [x] **ADDRESSED (verified)**: New native/fresh regression PASS22 preserves structured error code/kind, raw1/not-ready, exact Unicode source spans and named deferred/ordinary/inline values; scope restores after malformed-body errors. Direct frozen callable compatibility PASS5. Baseline module bytes match b4afbe objects; distinguishing corrected replay exits0.
  - [x] **NO REGRESSION**: Parser/probe/test syntax and git diff --check pass; direct compatibility values/raw status remain. Initial baseline launcher false require return is disclosed; blessed diagnostic maps are checked through structured fields. No full callback/write matrix or inferred full context/lifecycle proof.
  - [x] **LOCKSTEP**: Retained producer/baseline/candidate packet, current book explicit scope qualifier, contract/causal facts/map/task/live continuity agree. Approved scalar/null copy4.2.2 follows clean commit; direct calls stay owned/queued with full ordinary target unchanged. Full portable/context/canonical/pressure work remains separate.
  Commit: `TYPE-REFERENCE-BOOK.1.2.23.3.24.1.2.0 - preserve Perl deferred selection boundaries`.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.24.2`
  Status: `pending`
  Goal: Independently assess and implement Rust ordinary computed-value bracket reads.
  Dependencies: 24.1; computed-selection.md.
  Acceptance: Typed computed call/fluent/literal/block/function sources, repeated bracket/method alternation, signed valid positions and actual selected kinds; once-only source/ordered selectors/consumer, null missing/wrong-kind, compatible continuations/rejected consumer operands. Preserve named read lookup order, supported key/index classification, callable provenance, source/span construction, grouping/lvalue/copy/deferred/context/schema boundaries. Reuse existing value_access shape; own actual format movement explicitly before production. Split before edits if needed. Safe Lua only named PUC5.5.1/LuaJIT fixtures/loadfile, no unsafe patterns/full runner/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Producer-first source/AST/shared-kind/effect native/generated controls, direct selected/signed regressions and changed-surface compile/format checks; current book/history/continuity only. No full suite/matrix.
  Planned canonical trigger: Full method/source-domain/context/portable and format admission23.4 after feature coverage and final clean push.
  Planned claim verification: none: Deterministic authored feature regression/preservation controls, no population/completeness measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.24.3`
  Status: `pending`
  Goal: Independently assess and implement Dart ordinary computed-value bracket reads.
  Dependencies: 24.2; computed-selection.md.
  Acceptance: Typed computed call/fluent/literal/block/function sources, repeated bracket/method alternation, signed valid positions and actual selected kinds; once-only source/ordered selectors/consumer, null missing/wrong-kind, compatible continuations/rejected consumer operands. Preserve named read lookup order, supported key/index classification, callable provenance, source/span construction, grouping/lvalue/copy/deferred/context/schema boundaries. Reuse existing value_access shape; own actual format movement explicitly before production. Split before edits if needed. Safe Lua only named PUC5.5.1/LuaJIT fixtures/loadfile, no unsafe patterns/full runner/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Producer-first source/AST/shared-kind/effect native/generated controls, direct selected/signed regressions and changed-surface compile/format checks; current book/history/continuity only. No full suite/matrix.
  Planned canonical trigger: Full method/source-domain/context/portable and format admission23.4 after feature coverage and final clean push.
  Planned claim verification: none: Deterministic authored feature regression/preservation controls, no population/completeness measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.24.4`
  Status: `pending`
  Goal: Independently assess and implement Julia ordinary computed-value bracket reads.
  Dependencies: 24.3; computed-selection.md.
  Acceptance: Typed computed call/fluent/literal/block/function sources, repeated bracket/method alternation, signed valid positions and actual selected kinds; once-only source/ordered selectors/consumer, null missing/wrong-kind, compatible continuations/rejected consumer operands. Preserve named read lookup order, supported key/index classification, callable provenance, source/span construction, grouping/lvalue/copy/deferred/context/schema boundaries. Reuse existing value_access shape; own actual format movement explicitly before production. Split before edits if needed. Safe Lua only named PUC5.5.1/LuaJIT fixtures/loadfile, no unsafe patterns/full runner/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Producer-first source/AST/shared-kind/effect native/generated controls, direct selected/signed regressions and changed-surface compile/format checks; current book/history/continuity only. No full suite/matrix.
  Planned canonical trigger: Full method/source-domain/context/portable and format admission23.4 after feature coverage and final clean push.
  Planned claim verification: none: Deterministic authored feature regression/preservation controls, no population/completeness measurement.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.24.5`
  Status: `pending`
  Goal: Independently assess and implement safe Lua ordinary computed-value bracket reads.
  Dependencies: 24.4; computed-selection.md.
  Acceptance: Typed computed call/fluent/literal/block/function sources, repeated bracket/method alternation, signed valid positions and actual selected kinds; once-only source/ordered selectors/consumer, null missing/wrong-kind, compatible continuations/rejected consumer operands. Preserve named read lookup order, supported key/index classification, callable provenance, source/span construction, grouping/lvalue/copy/deferred/context/schema boundaries. Reuse existing value_access shape; own actual format movement explicitly before production. Split before edits if needed. Safe Lua only named PUC5.5.1/LuaJIT fixtures/loadfile, no unsafe patterns/full runner/declared5.4 claim.
  Planned verification tier: focused
  Planned focused checks: Producer-first source/AST/shared-kind/effect native/generated controls, direct selected/signed regressions and changed-surface compile/format checks; current book/history/continuity only. No full suite/matrix.
  Planned canonical trigger: Full method/source-domain/context/portable and format admission23.4 after feature coverage and final clean push.
  Planned claim verification: none: Deterministic authored feature regression/preservation controls, no population/completeness measurement.

## Current Frontier

Bounded selected/copy/count/length/aggregate/joined/default/index/has_key/emptiness/predicate/definedness/lexical-comparison/contains implementations and documented direct repairs are targeted-checked on recorded hosts. Aggregate-null/snapshot14, numeric comparison15, scalar arithmetic16 and logical Boolean17 bounded backend children are targeted-checked, including Perl17.1.1 rejected-source-effect repair. Complete domain/context/portable admission remains23.4. Defined-only coalesce assessment18 is frozen separately from the older nonempty-default exclusion; All five bounded defined-only default implementations18.1-.5 are targeted-checked. Scalar String-helper assessment19 is frozen; All five bounded scalar String implementations19.1-.5 and recorded producer/slice repairs are targeted-checked. Optional substring argument20 is frozen from existing ADR0006/0023 reference behavior; Dart20.1/Julia20.2/safe Lua20.3 are repaired/targeted-checked; remaining feature selection23.1.1 freezes reduction accumulator continuations21; All five bounded reduction implementations21.1-.5 are targeted-checked on recorded routes/hosts. Remaining selection23.1.2 freezes tagged-record String bridge22 and its Perl eager producer prerequisite; Perl22.1.1/.1.2 are repaired/targeted-checked; Rust22.2 producer/receiver are implemented/targeted-checked; Dart22.3 receiver roles/pattern/minimum shape repaired/targeted-checked; Julia22.4 receiver roles/minimum shape repaired/targeted-checked; Safe Lua22.5 receiver roles/minimum shape are repaired/targeted-checked; all five bounded22 children complete; selection23.1.3 freezes ordinary eager logical counterparts23; Perl23.1 methods are implemented/targeted-checked; Rust23.2 methods are implemented/targeted-checked; Dart23.3 methods are implemented/targeted-checked; Julia23.4 methods/shapes and safe Lua23.5 methods/shapes are targeted-checked; all five bounded23 children complete; scalar/null copy authority4.2.1 is complete; the director approved scalar/null value copying; ADR0138/target adoption4.2.2.0 is complete after explicit deferred-body repair24.1.2.0; Perl producer4.2.2.1.1 is implemented/targeted-checked; ordinary receiver1.2 is implemented/targeted-checked; existing interpreted context1.3 is preserved without runtime edits; bounded Perl parent complete; Rust2 implemented/targeted-checked and Dart3 next; independent selection23.1.4 freezes computed bracket reads24; Perl24.1.1 noncall sources are implemented/targeted-checked; direct-call24.1.2 preserves legacy callable boundaries before parent24.1/Rust24.2 handoff; error-phase parity1.2.1.4.1, document pressure1.2.20.1 and full admission remain separate. Explicit new Perl fixture registration23.4.1 and Lua declared5.4 proof remain prerequisites for later admission. Broad matrices/full verification stay deferred under the director feature-first cadence; family nodes retain exact evidence and open owners.

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `TYPE-REFERENCE-BOOK.1.2.1.4.2.2.3` | `pending` | Independently assess Dart primitive copy/result flows after the committed Perl/Rust rollout. |
| 2 | `FUTURE-PARITY-BACKLOG.5.4.2` | `pending` | Broad pure-pipeline recurrence deferred until feature coverage. |
| 3 | `FUTURE-PARITY-BACKLOG.5.3.4` | `pending` | Broad transform validation deferred after all three implementations. |
| 4 | `TYPE-REFERENCE-BOOK.1.2.23` | `pending` | Comprehensive fluent methods and returned-type transitions from inventory. |
| 5 | `TYPE-REFERENCE-BOOK.1.2.19` | `completed` | Grouped assignment native/fresh quick regression and syntax pass. |
| 6 | `TYPE-REFERENCE-BOOK.1.2.21` | `completed` | Raw multiline assignment payload and division controls targeted-checked. |
| 7 | `TYPE-REFERENCE-BOOK.1.2.17.6` | `completed` | Shared Lua signed selectors targeted-checked on PUC/LuaJIT. |
| 8 | `TYPE-REFERENCE-BOOK.1.2.17.5` | `completed` | Julia signed selectors targeted-checked. |
| 9 | `TYPE-REFERENCE-BOOK.1.2.14` | `completed` | Deferred last native/fresh targeted checks pass. |
| 10 | `TYPE-REFERENCE-BOOK.1.2.16` | `completed` | Deferred with native/fresh targeted checks pass. |
| 11 | `TYPE-REFERENCE-BOOK.1.2.2` | `pending` | Map inventory to book after method-gap implementation. |
| 12 | `TYPE-REFERENCE-BOOK.1.3` | `pending` | Independent inventory/layout review. |
| 13 | `TYPE-REFERENCE-BOOK.1.2.20` | `pending` | Policy maintenance deferred until feature coverage. |
| 14 | `TYPE-REFERENCE-BOOK.1.2.17.7` | `pending` | Broad verification deferred until feature coverage. |
| 15 | `TYPE-REFERENCE-BOOK.8` | `pending` | Legacy metadata maintenance deferred. |
| 16 | `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.13` | `pending` | Deferred literal-rendering question. |
| 17 | `TYPE-REFERENCE-BOOK.2` | `pending` | Inventory-backed reference families and closeout. |



## Decisions

- `2026-10-10`: DBIQNP authorizes discussion without pivot. Record and schedule the confirmed qualitative gap;
  do not claim unsupported missing-method counts or start reference restructuring during the current AST work.
- `2026-10-10`: Inventory actual language contracts before choosing the final type taxonomy or section layout.
  Historical book closeouts remain dated evidence; this tree owns the newly stated per-type completeness criterion.

## Open Questions

The inventory determines exact operation population, canonical section layout and any backend distinctions.
These are evidence questions owned by `.1`, not blockers requiring a director decision now.

## Blockers

No director input required. Implemented17 backends/14/16/19/21 lead to inventory1 and fluent gaps23. Latest feature-first steering defers policy20, hygiene24 and exhaustive17.7 until feature coverage. No dirty pivot.

## Verification Log

- `2026-10-25` — `.1.2.1.1`: source-linked non-call syntax index and small public AST role probe; book render and fast continuity/history checks pass. No exhaustive method/behavior admission; helper1.2 then receiver1.3 follow.

- `2026-10-25` — `.1.2.19` and `.1.2.21`: module/registration syntax, small native/fresh regressions, book rendering and fast memory/task/cadence/history/diff checks pass. Broad suites/global scans remain deferred by director instruction.

- `2026-10-25` — `.1.2.17.4`: Public113/452, private51+arithmetic12, emitted113/CLI214 and package636/CLI66x2/corpus105/storage25 pass. Five physical runtime inverses/restored452/0, exact historical134/84613241/22, nine primary/five support/four direct denials and actual auditor faults/restoration pass. Book95/90/four denials, readonly172/180/181 custody and physical input4/bypass/restoration pass. Existing SDK format1/analysis2 stays disclosed. Exact staged canonical receipt/normal hooks govern landing; hygiene23 precedes Julia17.5.

- `2026-10-25` — `.1.2.17.3`: Original40/160 has104 RED/56 controls; corrected137/822 on six routes and actual final restoration pass. Five physical runtime variants reject320/24/32/8/4; eight direct suites443 retain actual pre/post binaries. Book95/four executed examples/three source denials and old/new alias denials pass. Readonly195 and input4/bypass/restoration pass; claim198 preserves every qualified epoch and first-party include closure. Exact staged canonical receipt/normal hooks govern landing. Next clean owner55.1 precedes Dart17.4.

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

Syntax inventory1.1 subject: `TYPE-REFERENCE-BOOK.1.2.1.1 - index value syntax and operation roles`; derive identity from Git.

Grouped19: `28ce9b3e897efe3e1453d474c7b555b57465ed5b`. Raw-regex21 subject: `TYPE-REFERENCE-BOOK.1.2.21 - preserve assigned raw multiline regex payloads`; derive identity from Git.

Dart signed17.4 subject: `TYPE-REFERENCE-BOOK.1.2.17.4 - support signed Dart array selectors`; derive accepted identity from Git.

Rust signed17.3 subject: `TYPE-REFERENCE-BOOK.1.2.17.3 - support signed Rust array selectors`; derive accepted identity from Git.

CLI17.8 subject: `TYPE-REFERENCE-BOOK.1.2.17.8 - report context-only Perl CLI runtime failures`; derive accepted identity from Git.

Signed intake17.0 subject: `TYPE-REFERENCE-BOOK.1.2.17.0 - record signed-index baseline and CLI repair priority`; derive accepted identity from Git.

Deferred-write12 subject: `TYPE-REFERENCE-BOOK.1.2.12 - execute deferred indexed writes atomically`; derive accepted identity from Git.

Count/first10 subject: `TYPE-REFERENCE-BOOK.1.2.10 - execute callable count and first`; derive its accepted identity from Git.

Kind13 subject: `TYPE-REFERENCE-BOOK.1.2.13 - preserve sorted scalar kinds`; derive its accepted identity from Git.

Intake landed under `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2`. TYPE-REFERENCE-BOOK.1.1 is the first completed child; derive its accepted commit by subject from Git. Authority/model .1.2.0 is complete; derive its accepted commit by subject. P1 .1.2.3 completes the evaluated-value repair; derive its accepted commit by subject. Scoped-with .1.2.4 completes its finite repair; derive its accepted commit by subject. Numeric .1.2.5 completes scalar calls/snapshots; derive its commit by subject.

## Changelog

- `2026-10-25`: Complete bounded Dart signed implementation and exact historical admission; retain whole source/actual executable custody. Director disk notes are read and preserved exactly; hygiene23 activates only after clean landing, before Julia17.5.

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
