# TYPE-REFERENCE-BOOK: Complete navigable per-type language reference

## Metadata

- Tree ID: `TYPE-REFERENCE-BOOK`
- Status: `active` / joined String result assessment after bounded numeric result rollout
- Roadmap lane: `.spec language documentation / complete type and method reference`
- Created: `2026-10-10`
- Last updated: `2026-10-26`
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
  Goal: Reconcile the read-only shared live-document containment guide updates with local adoption.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.3`
  Intake: October23 read-only external policy review found new general derived-state/local-doctrine/checker material in the partially adopted FSMGen guide (SHA256 8f77fa39c9bcb9cfc43166259a627a6ced64682030088400b727dccc5d674a53). README policy digest 882682fa1ace703ae68726b8532a4ad24fe2c8a271bae4e07b859bd197a621c9 and claim policy 9f99df25209c43afb74d77e348dd2d0cdb68ce96cf17a4f272ede8328f6046bd were checked; claim policy remains ADR0126's adopted source. No cross-repository write occurred.
  Schedule: Deferred maintenance until feature coverage under the latest director instruction; do not block inventory1 or implementation23. Compare exact source/local adoption, own any applicable changes under bounded containment children, copy adopted rules locally, and verify doctrines/public explanation. External repositories stay read-only and no build may depend on them.
  Planned tier: `canonical`
  Claim verification: none: Policy intake and queue only; the implementation comparison and adoption evidence belong to this future leaf.

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
  Goal: Reconcile the syntax/helper/receiver inventories against current authority roles, then select bounded implementation gaps under23. Broad semantic validation remains deferred until feature coverage.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1.3`
  Planned tier: `focused`; no full suite for inventory closeout under the current director policy.
  Claim verification: none: Not yet activated; declare any aggregate population measurement before publication.

- ID: `TYPE-REFERENCE-BOOK.1.2.2`
  Status: `pending`
  Goal: Map the complete reconciled operation/spelling population to actual book coverage and proposed canonical per-type homes.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1`, `TYPE-REFERENCE-BOOK.1.2.23`
  Planned tier: `focused`; reclassify before public/mechanical movement.
  Claim verification: none: Unactivated coverage mapping; declare complete source/book evidence before measurement.
  Acceptance: Retain exact current entries/anchors/includes/examples/backend qualifications for every inventory item, mark precise depth/navigation gaps, preserve old anchors and schedule bounded family work. Close .1.2 only after all inventory children agree; independent layout review .1.3 follows. No exhaustive public-reference coverage claim from an inventory closeout.

- ID: `TYPE-REFERENCE-BOOK.1.2.23`
  Status: `active` / selected first/last transition; complete family matrix remains open
  Goal: Establish comprehensive fluent method families for every supported type and complete inter-type chaining.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.1`
  Children: `TYPE-REFERENCE-BOOK.1.2.23.1`, `TYPE-REFERENCE-BOOK.1.2.23.2`, `TYPE-REFERENCE-BOOK.1.2.23.3`, `TYPE-REFERENCE-BOOK.1.2.23.4`.
  Schedule: Director's comprehensive-method requirement plus current feature-first steering selects the concrete first/last result transition before exhaustive inventory/matrix completion. Freeze that bounded contract, then implement native children; full inventory, transition matrix and final admission remain parent closeout dependencies. Do not resume superseded Rust17.3 work.
  Acceptance: Assess useful semantic operation families as well as implemented names. Own and resolve missing fluent operations/transitions before declaring a type complete. Dispatch each chain continuation by its returned value's actual type; preserve container element types, mutation/detachment, callback/error/empty behavior and backend limits. Do not invent a new type or meaningless method merely for symmetry.
  Planned tier: Select per child; new public methods/contracts and final admission require canonical proof.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.1`
  Status: `pending`
  Goal: Build the per-type fluent coverage and gap matrix from the complete inventory and project use cases.
  Acceptance: Cover the actual scalar/string/numeric, array, harray, boolean/null and codeblock model, generic versus type-specific operations, meaningful free-helper/receiver counterparts, signatures, accepted inputs, return/element types, mutation/identity, empty/missing/error and backend boundaries. Identify required method-family gaps explicitly; a registered-name count is insufficient. Split new implementation work before writes.
  Planned tier: Focused source/contract audit; declare measurements at activation.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.2`
  Status: `active` / bounded selection contract; full matrix remains open
  Children: `TYPE-REFERENCE-BOOK.1.2.23.2.1`, `TYPE-REFERENCE-BOOK.1.2.23.2.2`, `TYPE-REFERENCE-BOOK.1.2.23.2.3`, `TYPE-REFERENCE-BOOK.1.2.23.2.4`, `TYPE-REFERENCE-BOOK.1.2.23.2.5`, `TYPE-REFERENCE-BOOK.1.2.23.2.6`, `TYPE-REFERENCE-BOOK.1.2.23.2.7`, `TYPE-REFERENCE-BOOK.1.2.23.2.8`
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

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3`
  Status: `active` / bounded selected-value rollout; full gap matrix remains open
  Children: `TYPE-REFERENCE-BOOK.1.2.23.3.1`, `.23.3.2`, `.23.3.3`, `.23.3.4`, `.23.3.5`, `.23.3.6`, `.23.3.7`, `.23.3.8`, `.23.3.9`
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
  Status: `pending`
  Goal: Independently assess and implement/confirm Rust ordinary emptiness result targets.
  Dependencies: .23.3.9.1.2.
  Acceptance: Public native/generated assessment before classification; preserve actual producer kinds and canonical empty/null/String/container domains, zero receiver operands, false retention, scalar guards/explicit bridges and ordered snapshots. Repair only confirmed bounded gaps; compile/small direct checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 remain separate.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.3`
  Status: `pending`
  Goal: Independently assess and implement/confirm Dart ordinary emptiness result targets.
  Dependencies: .23.3.9.2.
  Acceptance: Public native/generated assessment before classification; preserve actual producer kinds and canonical empty/null/String/container domains, zero receiver operands, false retention, scalar guards/explicit bridges and ordered snapshots. Repair only confirmed bounded gaps; compile/small direct checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 remain separate.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.4`
  Status: `pending`
  Goal: Independently assess and implement/confirm Julia ordinary emptiness result targets.
  Dependencies: .23.3.9.3.
  Acceptance: Public native/generated assessment before classification; preserve actual producer kinds and canonical empty/null/String/container domains, zero receiver operands, false retention, scalar guards/explicit bridges and ordered snapshots. Repair only confirmed bounded gaps; compile/small direct checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 remain separate.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.3.9.5`
  Status: `pending`
  Goal: Independently assess and implement/confirm Lua ordinary emptiness result targets.
  Dependencies: .23.3.9.4.
  Acceptance: Public native/generated assessment before classification; preserve actual producer kinds and canonical empty/null/String/container domains, zero receiver operands, false retention, scalar guards/explicit bridges and ordered snapshots. Repair only confirmed bounded gaps; compile/small direct checks/docs/commit. Full domain/portable admission23.4 and Lua declared5.4 remain separate.

- ID: `TYPE-REFERENCE-BOOK.1.2.23.4`
  Status: `pending`
  Count/length prerequisite: Bounded result rollout23.3.3 must land before complete fluent admission; the frozen contract is23.2.2 and bounded implementations23.3.3.1-.5 are targeted-checked; complete context/portable admission remains here.
  Known admission prerequisite: Rust scalar/default and bounded copy-arity implementations are targeted-checked; broad61.3/62.3/.62.4/copy23.3.2.5 remain open. Selected/count result implementations do not establish complete scalar families. Lua declared5.4 runtime/header proof remains LUA-STARTUP-READING.2.2.
  Goal: Independently admit complete fluent families and inter-type chains for the selected scope.
  Dependencies: `TYPE-REFERENCE-BOOK.1.2.23.3`
  Acceptance: Reconcile expected families and every transition in both directions against actual native/generated consumers and individual mdBook examples. Reject deliberate missing-method, wrong-return-type and continuation-dispatch faults; include empty/missing/error and backend controls. No family's final reference leaf .2-.6 or aggregate .7 closes over an unresolved assigned fluent gap. Keep scope exclusions explicit; publish no completeness claim from samples alone.
  Planned tier: Canonical admission; declare exact source-bound claim records before execution.

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

Bounded selected/copy/Count/Length/aggregate/joined implementations and Lua delimiter repairs are targeted-checked on recorded hosts. Default selection flow/literal repairs are targeted-checked on Perl; Rust2 direct String selection flow is repaired/targeted-checked too. Dart3/Julia4/Lua5 scalar-default boundaries are repaired/targeted-checked too on recorded hosts. Index_of result contract23.2.6 is frozen; Perl23.3.7.1 is implemented/targeted-checked; Rust2 is implemented/targeted-checked too; Dart3 scalar/shape boundaries are repaired/targeted-checked too; Julia4/Lua5 scalar/shape boundaries are repaired/targeted-checked too on recorded hosts. Has_key23.2.7 is frozen; Perl key-block23.3.8.1.1 and result flow1.2 are repaired/targeted-checked; Rust2 result/shape implementation is targeted-checked; Dart3 scalar/shape repair is targeted-checked; Julia4 scalar/shape repair is targeted-checked; Lua5 result/shape implementation is targeted-checked on available hosts. Bounded has_key rollout is targeted-checked; is_empty/is_nonempty23.2.8 is frozen; bounded Perl producer23.3.9.1.1 is repaired/targeted-checked; result flow1.2 is repaired/targeted-checked too; independent Rust2 assessment follows. Full signatures, comprehensive fluent/public/portable admission and Lua declared5.4 remain open; broad proof stays deferred under the director feature-first cadence.

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `TYPE-REFERENCE-BOOK.1.2.23.3.9.2` | `pending` | Independent Rust emptiness result/source/shape assessment after bounded Perl rollout. |
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
